/************************************************************************
	hostadapter.c

	BeebSCSI Acorn host adapter functions
    BeebSCSI - BBC Micro SCSI Drive Emulator
    Copyright (C) 2016 Simon Inns

	This file is part of BeebSCSI.

    BeebSCSI is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

	Email: simon.inns@gmail.com

************************************************************************/

// Global includes
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>

#include <stdbool.h>
#include <stdio.h>

// Local includes
#include "uart.h"
#include "debug.h"
#include "hostadapter.h"

// Timeout counter (used when interrupts are not available to ensure
// DMA read and writes do not hang the AVR waiting for host response
// Note: This is an unsigned 32 bit integer and should therefore be
// smaller than 4,294,967,295
#define TOC_MAX 100000

// Globals for the interrupt service routines
volatile bool nrstFlag = false;

// Interrupt service functions to handle host adapter input signals ---------------------

// Function to handle ReSeT signal interrupt
ISR(NRST_INT_VECT)
{
	// Here we just set a flag to show the main code that the
	// ISR was serviced
	nrstFlag = true;
}

// Function to handle CONFigure signal interrupt
ISR(NCONF_INT_VECT)
{
	uint8_t databusValue;
	
	// Read the databus value (containing the configuration command)
	// Don't invert the databus if we are connected to the internal bus
	if (hostadapterConnectedToExternalBus()) databusValue = ~PINA;
	else databusValue = PINA;
	
	// All debug off (Command 0)
	if (databusValue == 0)
	{
		debugFlag_filesystem = false;
		debugFlag_scsiCommands = false;
		debugFlag_scsiBlocks = false;
		debugFlag_scsiFcodes = false;
		debugFlag_scsiState = false;
		debugFlag_fatfs = false;
	}
	
	// All debug on (Command 1)
	if (databusValue == 1)
	{
		debugFlag_filesystem = true;
		debugFlag_scsiCommands = true;
		debugFlag_scsiBlocks = false;
		debugFlag_scsiFcodes = true;
		debugFlag_scsiState = true;
		debugFlag_fatfs = true;
	}
	
	// File system debug on/off (Command 10/11)
	if (databusValue == 10) debugFlag_filesystem = true;
	if (databusValue == 11) debugFlag_filesystem = false;
	
	// SCSI commands debug on/off (Command 12/13)
	if (databusValue == 12) debugFlag_scsiCommands = true;
	if (databusValue == 13) debugFlag_scsiCommands = false;
	
	// SCSI blocks debug on/off (Command 14/15)
	if (databusValue == 14) debugFlag_scsiBlocks = true;
	if (databusValue == 15) debugFlag_scsiBlocks = false;
	
	// SCSI F-codes debug on/off (Command 16/17)
	if (databusValue == 16) debugFlag_scsiFcodes = true;
	if (databusValue == 17) debugFlag_scsiFcodes = false;
	
	// SCSI state debug on/off (Command 18/19)
	if (databusValue == 18) debugFlag_scsiState = true;
	if (databusValue == 19) debugFlag_scsiState = false;
	
	// FAT FS debug on/off (Command 20/21)
	if (databusValue == 20) debugFlag_fatfs = true;
	if (databusValue == 21) debugFlag_fatfs = false;
}

// This ISR is really only for debug.  If an unhandled interrupt is
// called it will hang the AVR; otherwise such an event can go
// unnoticed and cause weird side-effects.
ISR(BADISR_vect)
{
	debugString_P(PSTR("ISR(BADISR_vect): ERROR: Unhandled AVR interrupt has occurred!\r\n"));
}

// Initialise the host adapter hardware (called on a cold-start of the AVR)
void hostadapterInitialise(void)
{
	// Initialise the host adapter input/output pins

	// Set the host adapter databus to input
	hostadapterDatabusInput();
	
	// Configure the status byte output pins to output
	STATUS_NMSG_DDR |= STATUS_NMSG; // Output
	STATUS_NBSY_DDR |= STATUS_NBSY; // Output

	STATUS_NREQ_DDR |= STATUS_NREQ; // Output
	STATUS_INO_DDR  |= STATUS_INO;  // Output
	STATUS_CND_DDR  |= STATUS_CND;  // Output
	
	STATUS_NMSG_PORT |= STATUS_NMSG; // Pin = 1 (inactive)
	STATUS_NBSY_PORT |= STATUS_NBSY; // Pin = 1 (inactive)
	STATUS_NREQ_PORT |= STATUS_NREQ; // Pin = 1 (inactive)
	STATUS_INO_PORT  |= STATUS_INO;  // Pin = 1 (inactive)
	STATUS_CND_PORT  |= STATUS_CND;  // Pin = 1 (inactive)
	
	// Configure the SCSI signal input pins to input
	NRST_DDR &= ~NRST; // Input
	NCONF_DDR &= ~NCONF; // Input
	NSEL_DDR &= ~NSEL; // Input
	NACK_DDR &= ~NACK; // Input
	INTNEXT_DDR &= ~INTNEXT; // Input
	
	NRST_PORT &= ~NRST; // Turn off weak pull-up
	NCONF_PORT &= ~NCONF; // Turn off weak pull-up
	NSEL_PORT &= ~NSEL; // Turn off weak pull-up
	NACK_PORT &= ~NACK; // Turn off weak pull-up
	INTNEXT_PORT &= ~INTNEXT; // Turn off weak pull-up
	
	// Set up the interrupt service routines for reset and configure signals
	EICRA = 0;
	EICRB = 0;
	EIMSK = 0;
	
	NRST_EICR |= (1 << NRST_ISC1);		// Failing edge of NRST
	NCONF_EICR |= (1 << NCONF_ISC1);	// Failing edge of NCONF
	EIMSK |= (1 << NRST_INT);			// Enable NRST interrupt
	EIMSK |= (1 << NCONF_INT);			// Enable NCONF interrupt
}

// Reset the host adapter (called when the host signals reset)
void hostadapterReset(void)
{
	// Set the host adapter databus to input
	hostadapterDatabusInput();
	
	// Turn off all host adapter signals
	STATUS_NMSG_PORT |= STATUS_NMSG;
	STATUS_NBSY_PORT |= STATUS_NBSY;
	STATUS_NREQ_PORT |= STATUS_NREQ;
	STATUS_INO_PORT  |= STATUS_INO;
	STATUS_CND_PORT  |= STATUS_CND;
}

// Databus manipulation functions -------------------------------------------------------

// Set the databus direction to input
inline void hostadapterDatabusInput(void)
{
	// Set the host adapter databus to input
	DDRA = 0x00;
	
	// Turn off weak pull-ups
	PORTA = 0x00;
}

// Set the databus direction to output
inline void hostadapterDatabusOutput(void)
{
	// Set the databus direction to output
	DDRA = 0xFF;
}

// Read a byte from the databus (directly)
inline uint8_t hostadapterReadDatabus(void)
{
	return ~PINA;
}

// Write a byte to the databus (directly)
inline void hostadapterWritedatabus(uint8_t databusValue)
{
	PORTA = ~databusValue;
}

// SCSI Bus action functions ------------------------------------------------------------

// Function to read a byte from the host (using REQ/ACK)
inline uint8_t hostadapterReadByte(void)
{
	uint8_t databusValue = 0;

	// Set the REQuest signal
	STATUS_NREQ_PORT &= ~STATUS_NREQ; // REQ = 0 (active)
	
	// Wait for ACKnowledge
	while(((NACK_PIN & NACK) != 0) && nrstFlag == false);
	
	// Clear the REQuest signal
	STATUS_NREQ_PORT |= STATUS_NREQ; // REQ = 1 (inactive)
	
	// Read the databus value
	databusValue = ~PINA;
	
	return databusValue;
}

// Function to write a byte to the host (using REQ/ACK)
inline void hostadapterWriteByte(uint8_t databusValue)
{
	// Write the byte of data to the databus
	PORTA = ~databusValue;
	
	// Set the REQuest signal
	STATUS_NREQ_PORT &= ~STATUS_NREQ; // REQ = 0 (active)
	
	// Wait for ACKnowledge
	while(((NACK_PIN & NACK) != 0) && nrstFlag == false);
	
	// Clear the REQuest signal
	STATUS_NREQ_PORT |= STATUS_NREQ; // REQ = 1 (inactive)
}

// Host DMA transfer functions ----------------------------------------------------------

// Host reads data from SCSI device using DMA transfer (reads a 256 byte block)
// Returns number of bytes transferred (for debug in case of DMA failure)
uint16_t hostadapterPerformReadDMA(uint8_t *dataBuffer)
{
	uint16_t currentByte = 0;
	uint32_t timeoutCounter = 0;

	// Loop to write bytes (unless a reset condition is detected)
	while(currentByte < 256 && timeoutCounter != TOC_MAX)
	{
		// Write the current byte to the databus and point to the next byte
		PORTA = ~dataBuffer[currentByte++];

		// Set the REQuest signal
		STATUS_NREQ_PORT &= ~STATUS_NREQ; // REQ = 0 (active)
		
		// Wait for ACKnowledge
		timeoutCounter = 0; // Reset timeout counter
		
		while((NACK_PIN & NACK) != 0)
		{
			if (++timeoutCounter == TOC_MAX)
			{
				// Set the host reset flag and quit
				nrstFlag = true;
				return currentByte - 1;
			}
		}
		
		// Clear the REQuest signal
		STATUS_NREQ_PORT |= STATUS_NREQ; // REQ = 1 (inactive)
	}
	
	return currentByte - 1;
}

// Host writes data to SCSI device using DMA transfer (writes a 256 byte block)
// Returns number of bytes transferred (for debug in case of DMA failure)
uint16_t hostadapterPerformWriteDMA(uint8_t *dataBuffer)
{
	uint16_t currentByte = 0;
	uint32_t timeoutCounter = 0;

	// Loop to read bytes (unless a reset condition is detected)
	while(currentByte < 256 && timeoutCounter != TOC_MAX)
	{
		// Set the REQuest signal
		STATUS_NREQ_PORT &= ~STATUS_NREQ; // REQ = 0 (active)
		
		// Wait for ACKnowledge
		timeoutCounter = 0; // Reset timeout counter
		
		while((NACK_PIN & NACK) != 0)
		{
			if (++timeoutCounter == TOC_MAX)
			{
				// Set the host reset flag and quit
				nrstFlag = true;
				return currentByte;
			}
		}
		
		// Read the current byte from the databus and point to the next byte
		dataBuffer[currentByte++] = ~PINA;
		
		// Clear the REQuest signal
		STATUS_NREQ_PORT |= STATUS_NREQ; // REQ = 1 (inactive)
	}
	
	return currentByte - 1;
}

// Host adapter signal control and detection functions ------------------------------------

// Function to determine if the host adapter is connected to the external or internal
// host bus
bool hostadapterConnectedToExternalBus(void)
{
	if ((INTNEXT_PIN & INTNEXT) != 0) return false; // Internal bus
	
	return true; // External bus
}

// Function to write the host reset flag
void hostadapterWriteResetFlag(bool flagState)
{
	nrstFlag = flagState;
}

// Function to return the state of the host reset flag
bool hostadapterReadResetFlag(void)
{
	return nrstFlag;
}

// Function to write the data phase flags and control databus direction
// Note: all SCSI signals are inverted logic
void hostadapterWriteDataPhaseFlags(bool message, bool commandNotData, bool inputNotOutput)
{
	if (message) STATUS_NMSG_PORT &= ~STATUS_NMSG; // MSG = active
	else STATUS_NMSG_PORT |= STATUS_NMSG; // MSG = inactive
	
	if (commandNotData) STATUS_CND_PORT &= ~STATUS_CND; //  CD = active
	else STATUS_CND_PORT |= STATUS_CND; //  CD = inactive
	
	if (inputNotOutput)
	{
		STATUS_INO_PORT &= ~STATUS_INO; //  IO = active
		hostadapterDatabusOutput();
	}
	else
	{
		STATUS_INO_PORT |= STATUS_INO; //  IO = inactive
		hostadapterDatabusInput();
	}
}

// Function to write the host busy flag
// Note: all SCSI signals are inverted logic
void hostadapterWriteBusyFlag(bool flagState)
{
	if (flagState) STATUS_NBSY_PORT &= ~STATUS_NBSY; // BSY = inactive
	else STATUS_NBSY_PORT |= STATUS_NBSY; // BSY = active
}

// Function to write the host request flag
// Note: all SCSI signals are inverted logic
void hostadapterWriteRequestFlag(bool flagState)
{
	if (flagState) STATUS_NREQ_PORT &= ~STATUS_NREQ; // REQ = inactive
	else STATUS_NREQ_PORT |= STATUS_NREQ; // REQ = active
}

// Function to read the state of the host select flag
// Note: all SCSI signals are inverted logic
bool hostadapterReadSelectFlag(void)
{
	if ((NSEL_PIN & NSEL) != 0) return false;
	
	return true;
}