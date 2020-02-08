/************************************************************************
	scsi.c

	BeebSCSI SCSI emulation functions
    BeebSCSI - BBC Micro SCSI Drive Emulator
    Copyright (C) 2018-2020 Simon Inns

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
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include <stdio.h>

// Local includes
#include "uart.h"
#include "debug.h"
#include "hostadapter.h"
#include "filesystem.h"
#include "statusled.h"
#include "usb.h"
#include "scsi.h"
#include "fcode.h"

// Define the major and minor firmware version number returned
// by the BSSENSE command
#define FIRMWARE_MAJOR		0x02
#define FIRMWARE_MINOR		0x06
#define FIRMWARE_STRING		"V002.006"

// Global for the emulation mode (fixed or removable drive)
// Note: The fixed mode emulates SCSI-1 compliant hard drives for the Beeb
// The removable mode emulates the Laser Video Disc Player (LV-DOS) for Domesday
uint8_t emulationMode = FIXED_EMULATION;

// Global SCSI sector buffer (256 bytes)
uint8_t scsiSectorBuffer[256];

// REQUEST SENSE command error reporting structure
struct requestSenseDataStruct
{
	bool errorFlag;
	bool validAddressFlag;
	uint8_t errorClass;
	uint8_t errorCode;
	uint32_t logicalBlockAddress;
} requestSenseData[8];

// Global structure for storing SCSI CDBs
struct commandDataBlockStruct
{
	uint8_t data[10];
	uint8_t length;
	
	uint8_t opCode;
	uint8_t group;
	
	uint8_t targetLUN;
	
	uint8_t status;
	uint8_t message;
} commandDataBlock;

// Global for storing the current SCSI emulation state
uint8_t scsiState;

// Initialise the SCSI emulation (called on a cold-start of the AVR)
void scsiInitialise(void)
{
	uint8_t lunNumber;
	
	// On a cold-start we always output debug information (ignoring the setting of the
	// debug flags) - as this is useful for initial board testing
	
	debugString_P(PSTR("\r\n\r\nBeebSCSI - Acorn SCSI-1 Emulation\r\n\r\n"));
	debugString_P(PSTR("(c)2018-2019 Simon Inns\r\n"));
	debugString_P(PSTR("https://www.domesday86.com\r\n"));
	debugString_P(PSTR("Open-source GPLv3 firmware\r\n"));
	debugString_P(PSTR("\r\n"));
	debugString_P(PSTR("Firmware: "));
	debugString_P(PSTR(FIRMWARE_STRING));
	debugString_P(PSTR("\r\n"));
	
	// Determine the emulation mode (fixed or LV-DOS)
	if (hostadapterConnectedToExternalBus()) {
		emulationMode = FIXED_EMULATION;
		debugString_P(PSTR("Emulation mode is Winchester (ADFS SCSI-1 hard-drive)\r\n"));
	} else {
		emulationMode = LVDOS_EMULATION;
		debugString_P(PSTR("Emulation mode is Philips VP415 (VFS LaserDisc player)\r\n"));
	}
	
	// Show the USB status
	if (usbHardwareDetect()) {
		// USB hardware present
		debugString_P(PSTR("USB capable board detected\r\n"));
	} else {
		// No USB hardware
		debugString_P(PSTR("USB capable board not detected\r\n"));
	}
	
	debugString_P(PSTR("\r\n"));
	
	if (debugFlag_scsiState) debugString_P(PSTR("SCSI State: Initialising SCSI emulation\r\n"));
	
	// Clear the request sense error globals
	for (lunNumber = 0; lunNumber < 8; lunNumber++) {
		requestSenseData[lunNumber].errorFlag = false;
		requestSenseData[lunNumber].validAddressFlag = false;
		requestSenseData[lunNumber].errorClass = 0x00;
		requestSenseData[lunNumber].errorCode = 0x00;
		requestSenseData[lunNumber].logicalBlockAddress = 0x00;
	}
	
	// Set the initial SCSI emulation state
	scsiState = SCSI_BUSFREE;
}

// Reset the SCSI emulation (called when the host signals reset)
void scsiReset(void)
{
	uint8_t lunNumber;
	
	if (debugFlag_scsiState) {
		debugString_P(PSTR("\r\n\r\nSCSI State: Resetting SCSI emulation\r\n"));
		debugString_P(PSTR("SCSI State: Firmware: "));
		debugString_P(PSTR(FIRMWARE_STRING));
		debugString_P(PSTR("\r\n"));
		
		// Determine the emulation mode (fixed or LV-DOS)
		if (hostadapterConnectedToExternalBus()) {
			emulationMode = FIXED_EMULATION;
			debugString_P(PSTR("Emulation mode is Winchester (ADFS SCSI-1 hard-drive)\r\n"));
		} else {
			emulationMode = LVDOS_EMULATION;
			debugString_P(PSTR("Emulation mode is Philips VP415 (VFS LaserDisc player)\r\n"));
		}
		
		debugString_P(PSTR("\r\n"));
	}
	
	// Clear the request sense error globals
	for (lunNumber = 0; lunNumber < 8; lunNumber++) {
		requestSenseData[lunNumber].errorFlag = false;
		requestSenseData[lunNumber].validAddressFlag = false;
		requestSenseData[lunNumber].errorClass = 0x00;
		requestSenseData[lunNumber].errorCode = 0x00;
		requestSenseData[lunNumber].logicalBlockAddress = 0x00;
	}
	
	// Ensure the SCSI bus phase is BUS FREE
	scsiState = SCSI_BUSFREE;
}

// Process the SCSI emulation
void scsiProcessEmulation(void)
{
	// Process SCSI emulation state
	switch (scsiState) {
		// Handle SCSI bus states:
		case SCSI_BUSFREE:
		scsiState = scsiEmulationBusFree();
		break;
		
		case SCSI_COMMAND:
		scsiState = scsiEmulationCommand();
		break;
		
		case SCSI_STATUS:
		scsiState = scsiEmulationStatus();
		break;
		
		case SCSI_MESSAGE:
		scsiState = scsiEmulationMessage();
		break;

		// Handle SCSI commands:
		case SCSI_TESTUNITREADY:
		scsiState = scsiCommandTestUnitReady();
		break;
		
		case SCSI_REZEROUNIT:
		scsiState = scsiCommandRezeroUnit();
		break;
		
		case SCSI_REQUESTSENSE:
		scsiState = scsiCommandRequestSense();
		break;
		
		case SCSI_FORMAT:
		scsiState = scsiCommandFormat();
		break;
		
		case SCSI_READ6:
		scsiState = scsiCommandRead6();
		break;
		
		case SCSI_WRITE6:
		scsiState = scsiCommandWrite6();
		break;
		
		case SCSI_SEEK:
		scsiState = scsiCommandSeek();
		break;
		
		case SCSI_TRANSLATE:
		scsiState = scsiCommandTranslate();
		break;
		
		case SCSI_MODESELECT:
		scsiState = scsiCommandModeSelect();
		break;
		
		case SCSI_MODESENSE:
		scsiState = scsiCommandModeSense();
		break;
		
		case SCSI_STARTSTOP:
		scsiState = scsiCommandStartStop();
		break;
		
		case SCSI_VERIFY:
		scsiState = scsiCommandVerify();
		break;
		
		// Handle LV-DOS specific group 6 commands
		case SCSI_WRITE_FCODE:
		scsiState = scsiWriteFCode();
		break;
		
		case SCSI_READ_FCODE:
		scsiState = scsiReadFCode();
		break;
		
		// Handle BeebSCSI specific group 6 commands
		case SCSI_BEEBSCSI_SENSE:
		scsiState = scsiBeebScsiSense();
		break;
		
		case SCSI_BEEBSCSI_SELECT:
		scsiState = scsiBeebScsiSelect();
		break;
		
		case SCSI_BEEBSCSI_FATPATH:
		scsiState = scsiBeebScsiFatPath();
		break;
		
		case SCSI_BEEBSCSI_FATINFO:
		scsiState = scsiBeebScsiFatInfo();
		break;
		
		case SCSI_BEEBSCSI_FATREAD:
		scsiState = scsiBeebScsiFatRead();
		break;
		
		default:
		if (debugFlag_scsiState) debugString_P(PSTR("SCSI State: ERROR: Invalid SCSI state!\r\n"));
	}
	
	// Show activity using the status LED on whenever we are not in the bus free state
	if (scsiState == SCSI_BUSFREE) statusledActivity(0); else statusledActivity(1);
}

// SCSI Bus state emulation functions -------------------------------------------------------------

// Function to set the bus signals for the various
// Information transfer phases
void scsiInformationTransferPhase(uint8_t transferPhase)
{
	// Note: (from the SCSI specification documentation)
	// MSG	CD	IO
	// 0	0	0	Data out phase
	// 0	0	1	Data in phase
	// 0	1	0	Command phase
	// 0	1	1	Status phase
	// 1	0	0	*
	// 1	0	1	*
	// 1	1	0	Message out phase
	// 1	1	1	Message in phase
	
	switch(transferPhase) {
		case ITPHASE_DATAOUT:
		hostadapterWriteDataPhaseFlags(false, false, false); // MSG, CD, IO
		if (debugFlag_scsiState) debugString_P(PSTR("SCSI State: Information transfer phase: Data out\r\n"));
		break;
		
		case ITPHASE_DATAIN:
		hostadapterWriteDataPhaseFlags(false, false, true); // MSG, CD, IO
		if (debugFlag_scsiState) debugString_P(PSTR("SCSI State: Information transfer phase: Data in\r\n"));
		break;
		
		case ITPHASE_COMMAND:
		hostadapterWriteDataPhaseFlags(false, true, false); // MSG, CD, IO
		if (debugFlag_scsiState) debugString_P(PSTR("SCSI State: Information transfer phase: Command\r\n"));
		break;
		
		case ITPHASE_STATUS:
		hostadapterWriteDataPhaseFlags(false, true, true); // MSG, CD, IO
		if (debugFlag_scsiState) debugString_P(PSTR("SCSI State: Information transfer phase: Status\r\n"));
		break;
		
		case ITPHASE_MESSAGEOUT:
		hostadapterWriteDataPhaseFlags(true, true, false); // MSG, CD, IO
		if (debugFlag_scsiState) debugString_P(PSTR("SCSI State: Information transfer phase: Message out\r\n"));
		break;
		
		case ITPHASE_MESSAGEIN:
		hostadapterWriteDataPhaseFlags(true, true, true); // MSG, CD, IO
		if (debugFlag_scsiState) debugString_P(PSTR("SCSI State: Information transfer phase: Message in\r\n"));
		break;
	}
}

// SCSI Bus free state
uint8_t scsiEmulationBusFree(void)
{
	uint8_t hostIdentifier = 0;
	
	if (debugFlag_scsiState) debugString_P(PSTR("SCSI State: Bus Free\r\n"));
	
	// Clear reset condition
	hostadapterWriteResetFlag(false);
	
	// Reset bus to Data out IT phase
	scsiInformationTransferPhase(ITPHASE_DATAOUT);
	
	// Clear busy and request flags
	hostadapterWriteBusyFlag(false);
	hostadapterWriteRequestFlag(false);
	
	// Wait for selection (or reset condition)
	while ( (!hostadapterReadSelectFlag()) && (!hostadapterReadResetFlag()) );
	
	// If host signalled reset, go to the bus free state
	if (hostadapterReadResetFlag()) return SCSI_BUSFREE;
	
	// Read the host ID (from the host databus)
	hostIdentifier = hostadapterReadDatabus();
	
	// Set busy flag to active
	hostadapterWriteBusyFlag(true);
	
	// We are now in the selected state
	if (debugFlag_scsiState) debugStringInt16_P(PSTR("SCSI State: Selected by host ID "), hostIdentifier, true);
	
	// Transition to command state
	return SCSI_COMMAND;
}

// SCSI Command state
uint8_t scsiEmulationCommand(void)
{
	uint8_t commandDataBlockPointer = 0;
	
	if (debugFlag_scsiState) debugString_P(PSTR("SCSI State: Command phase\r\n"));
	
	// Set signals to indicate command state on the bus
	scsiInformationTransferPhase(ITPHASE_COMMAND);
	
	// Get the first byte of the command
	commandDataBlock.data[commandDataBlockPointer] = hostadapterReadByte();
	
	// Decode the CDB 1st byte
	commandDataBlock.group = (commandDataBlock.data[0] & 0xE0) >> 5;
	commandDataBlock.opCode = (commandDataBlock.data[0] & 0x1F);
	
	// Set the length of the CDB based on the command group
	switch (commandDataBlock.group) {
		case 0:
		commandDataBlock.length = 6;
		break;
		
		case 1:
		commandDataBlock.length = 10;
		break;
		
		case 6:
		commandDataBlock.length = 6;
		break;
		
		default:
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: ERROR: BAD command group received\r\n"));
		break;
	}
	
	// Show CDB byte 0 decode
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: CDB byte 0 decode: "));
		debugStringInt16_P(PSTR("Command group "), commandDataBlock.group, false);
		debugStringInt16_P(PSTR(" ("), commandDataBlock.length, false);
		debugStringInt16_P(PSTR(" bytes) opcode "), commandDataBlock.opCode, true);
	}

	// Show received byte value
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: Received command operand bytes:"));
		debugStringInt16_P(PSTR(" "), commandDataBlock.data[commandDataBlockPointer], false);
	}
	
	// Next byte...
	commandDataBlockPointer++;
	
	// Get the remainder of the CDB bytes;
	while (commandDataBlockPointer < commandDataBlock.length) {
		commandDataBlock.data[commandDataBlockPointer] = hostadapterReadByte();
		
		// Show received byte value
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR(" "), commandDataBlock.data[commandDataBlockPointer], false);
		
		commandDataBlockPointer++;
	}
	if (debugFlag_scsiCommands) debugString_P(PSTR("\r\n"));
	
	// Decode the target LUN
	commandDataBlock.targetLUN = (commandDataBlock.data[1] & 0xE0) >> 5;
	
	// Transition to command based on received opCode (group 0 commands)
	if (commandDataBlock.group == 0) {
		// Select group 0 command type
		switch (commandDataBlock.opCode) {
			case 0x00:
			return SCSI_TESTUNITREADY;
			break;
			
			case 0x01:
			return SCSI_REZEROUNIT;
			break;
			
			case 0x03:
			return SCSI_REQUESTSENSE;
			break;
			
			case 0x04:
			return SCSI_FORMAT;
			break;
			
			case 0x08:
			return SCSI_READ6;
			break;
			
			case 0x0A:
			return SCSI_WRITE6;
			break;
			
			case 0x0B:
			return SCSI_SEEK;
			break;
			
			case 0x0F:
			return SCSI_TRANSLATE;
			break;
			
			case 0x15:
			return SCSI_MODESELECT;
			break;
			
			case 0x1A:
			return SCSI_MODESENSE;
			break;
			
			case 0x1B:
			return SCSI_STARTSTOP;
			break;
		}
	}
	
	// Transition to command based on received opCode (group 1 commands)
	if (commandDataBlock.group == 1) {
		// Select group 1 command type
		switch (commandDataBlock.opCode) {
			case 0x0F:
			return SCSI_VERIFY;
			break;
		}
	}
	
	// Transition to command based on received opCode (group 6 LV-DOS commands)
	if (commandDataBlock.group == 6 && emulationMode == LVDOS_EMULATION) {
		// Select group 6 command type
		switch (commandDataBlock.opCode) {
			case 0x0A:
			return SCSI_WRITE_FCODE;
			break;
			
			case 0x08:
			return SCSI_READ_FCODE;
			break;
		}
	}
	
	// Transition to command based on received opCode (group 6 BeebSCSI commands)
	if (commandDataBlock.group == 6) {
		// Select group 6 command type
		switch (commandDataBlock.opCode) {
			case 0x10:
			return SCSI_BEEBSCSI_SENSE;
			break;
			
			case 0x11:
			return SCSI_BEEBSCSI_SELECT;
			break;
			
			case 0x12:
			return SCSI_BEEBSCSI_FATPATH;
			break;
			
			case 0x13:
			return SCSI_BEEBSCSI_FATINFO;
			break;
			
			case 0x14:
			return SCSI_BEEBSCSI_FATREAD;
			break;
		}
	}

	// Unrecognized command received!
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: ERROR: BAD opcode received - transitioning to bus free\r\n"));
	return SCSI_BUSFREE;
}

// SCSI status state
uint8_t scsiEmulationStatus(void)
{
	if (debugFlag_scsiState) debugStringInt16_P(PSTR("SCSI State: Status.  Status byte = "), commandDataBlock.status, true);
	
	// Set signals to indicate status state on the bus
	scsiInformationTransferPhase(ITPHASE_STATUS);
	
	// Write the status byte to the host
	hostadapterWriteByte(commandDataBlock.status);
	
	// Transition to SCSI message state
	return SCSI_MESSAGE;
}

// SCSI message in state
uint8_t scsiEmulationMessage(void)
{
	if (debugFlag_scsiState) debugStringInt16_P(PSTR("SCSI State: Message In.  Message byte = "), commandDataBlock.message, true);
	
	// Set signals to indicate message in state on the bus
	scsiInformationTransferPhase(ITPHASE_MESSAGEIN);
	
	// Write the message byte to the host
	hostadapterWriteByte(commandDataBlock.message);
	
	// Transition to the bus free state (command is complete)
	return SCSI_BUSFREE;
}

// SCSI command execution functions -----------------------------------------------------

// SCSI Command (0x00) TestUnitReady
//
// Adaptec ACB-4000 Manual notes:
// The TEST UNIT READY command verifies that the drive is powered on
// and the DRIVE READY line is true. Once the drive is re-zeroed,
// with no errors, this command will check to see that the drive is
// ready to write and read data. Drive write fault condition is also
// checked.
uint8_t scsiCommandTestUnitReady(void)
{
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: TESTUNITREADY command (0x00) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Check to see if the requested LUN is started
	if (filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// Indicate successful command in status and message
		commandDataBlock.status = 0x00; // 0x00 = Good
		commandDataBlock.message = 0x00;
	} else {
		// Indicate unsuccessful command in status and message
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Unavailable LUN #"), commandDataBlock.targetLUN, true);
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Failed
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x02; // Unit not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	return SCSI_STATUS;
}

// SCSI Command (0x01) ReZero Unit
//
// Only used by removable media in the LV-DOS emulation mode
//
// VP415 LVDP Manual notes:
// Displays the logical picture zero of the volume that is accessed through
// the logic unit number <>f the command. If successful, the status
// returned is 0x00; otherwise the status returned is 0x02.
uint8_t scsiCommandRezeroUnit(void)
{
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: REZEROUNIT command (0x01) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Check to see if the requested LUN is started
	if (filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// Indicate successful command in status and message
		commandDataBlock.status = 0x00; // 0x00 = Good
		commandDataBlock.message = 0x00;
	} else {
		// Indicate unsuccessful command in status and message
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Unavailable LUN #"), commandDataBlock.targetLUN, true);
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Failed
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x02; // Unit not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	return SCSI_STATUS;
}

// SCSI Command (0x03) RequestSense
//
// Adaptec ACB-4000 Manual notes:
// The REQUEST SENSE (03 hex) command is the command that gives the
// most detailed description of status from the controller. This
// command is needed whenever a CHECK STATUS is found in the
// COMPLETION STATUS BYTE. If the CHECK BIT is set after a command,
// a REQUEST SENSE must follow in order to read status and clear the
// check condition.
//
// Note: This command is used by the host after another command returns
// a 'bad' status (0x02).  It is a request for a more detailed error code.
// If the command is incorrectly handled it will cause ADFS to hang...
uint8_t scsiCommandRequestSense(void)
{
	uint8_t numberOfSenseBytes;
	uint8_t responseByte = 0;

	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: REQUESTSENSE command (0x03) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Since this command provides additional error information, it is available even if the
	// LUN is unavailable (no LUN image on file system).
	
	// Get the requested number of sense bytes
	numberOfSenseBytes = commandDataBlock.data[4];
	
	// The ACB-4000 manual (section 5.5.1) states that, if the number of sense bytes
	// is less than 4, it should default to four bytes
	if (numberOfSenseBytes < 4) numberOfSenseBytes = 4;
	
	// Note: The ACB-4000 manual is a little confusing around the subject of the
	// number of bytes.  There doesn't seem to be any condition in which the
	// number would be anything other than 4 (nor any result with less than 4 bytes).
	if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Sense bytes = "), numberOfSenseBytes, true);
	
	// Set up the control signals ready for the data in phase
	scsiInformationTransferPhase(ITPHASE_DATAIN);
	
	// Is there an error waiting to be reported?
	if (requestSenseData[commandDataBlock.targetLUN].errorFlag == false) {
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: No error flagged\r\n"));
		hostadapterWriteByte(0x00);
		hostadapterWriteByte(0x00);
		hostadapterWriteByte(0x00);
		hostadapterWriteByte(0x00);
	} else {
		// Assemble request sense error response
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Error flagged - sending to host\r\n"));
		if (requestSenseData[commandDataBlock.targetLUN].validAddressFlag == true) responseByte = 128; // set address valid flag
		responseByte += (requestSenseData[commandDataBlock.targetLUN].errorClass & 0x7) << 4; // set error class field
		responseByte += (requestSenseData[commandDataBlock.targetLUN].errorCode & 0x0F); // set error code field
		
		hostadapterWriteByte(responseByte);
		hostadapterWriteByte((uint8_t)((requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress & 0x1F0000) >> 16));
		hostadapterWriteByte((uint8_t)((requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress & 0x00FF00) >> 8));
		hostadapterWriteByte((uint8_t)((requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress & 0x0000FF)));
	}
	
	// Clear the request sense error reporting globals
	requestSenseData[commandDataBlock.targetLUN].errorFlag = false;
	requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
	requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00;
	requestSenseData[commandDataBlock.targetLUN].errorCode = 0x00;
	requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
	
	// Indicate successful command in status and message
	commandDataBlock.status =  0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	
	return SCSI_STATUS;
}

// SCSI Command (0x04) Format
//
// Adaptec ACB-4000 Manual notes:
// The FORMAT command writes drive characteristics, ID and data
// fields onto the drive and writes a fill pattern into the user
// data field. This fill pattern can be changed by use of the FORMAT
// command. This feature is useful in writing worst case data
// patterns onto the drive at format time.
//
// When using the FORMAT command, a drive defect list can be
// appended to the command in a cylinder, head and "bytes from
// index" form. This form is the same form that most drive
// manufacturers use. This form can also be generated from the drive
// by using the TRANSLATE with the SEARCH DATA NOT EQUAL command.
uint8_t scsiCommandFormat(void)
{
	uint8_t byteCounter;
	
	// Format unit command parameters:
	uint8_t formatOptions;
	uint8_t dataPattern;
	//uint16_t interleave;
	
	// Variables for reading the defect list
	uint16_t defectListLength = 0;
	uint16_t defectListRecords = 0;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: FORMAT command (0x04) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Make sure the target LUN is started
	if (!filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// If the LUN is unavailable we need to create the LUN image on the file system
		// before formatting it.
		if (!filesystemCreateLunImage(commandDataBlock.targetLUN)) {
			// Could not create LUN image... return with error status
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: ERROR: Could not create new LUN image for LUN #"), commandDataBlock.targetLUN, true);
			commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
			commandDataBlock.message = 0x00;
			
			// Set request sense error globals
			requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
			requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
			requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
			requestSenseData[commandDataBlock.targetLUN].errorCode = 0x1C; // Unformatted or Bad format
			requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
			
			// The LUN is in an unknown state... Stop the LUN
			filesystemSetLunStatus(commandDataBlock.targetLUN, false);
			return SCSI_STATUS;
		}
	}
	
	// Interpret command parameters
	formatOptions = (commandDataBlock.data[1] & 0x1F);
	dataPattern = commandDataBlock.data[2]; // Default fill pattern is 0x6C (108)
	//interleave = (commandDataBlock.data[3] << 8) + commandDataBlock.data[4];

	if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Format option = "), formatOptions,true);
	
	// Interleave cannot be greater than the number of sectors per track minus one, or we
	// should send a 1A error code (Interleave Error)
	// We don't really care about the interleave... you could uncomment this for a more
	// exact emulation...
	//if (interleave > 32)
	//{
	//// Indicate unsuccessful command in status and message
	//commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
	//commandDataBlock.message = 0x00;
	//
	//// Set request sense error globals
	//requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
	//requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
	//requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
	//requestSenseData[commandDataBlock.targetLUN].errorCode = 0x1A; // Interleave Error
	//requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
	//
	//return SCSI_STATUS;
	//}
	
	// Note: The defect list is ignored by the emulation since it does not apply
	// to the emulated file system; this code is included for debug completion.
	
	// If specified (by the options) read the defect list (ACB-4000 figure 5-6)
	if (formatOptions == 28 || formatOptions == 30) {
		// Read the defect list
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Reading the defect list:\r\n"));
		
		// Set up the control signals ready for the data out phase
		scsiInformationTransferPhase(ITPHASE_DATAOUT);
		
		// Read the defect list header
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Defect list header:\r\n"));
		for (byteCounter = 0; byteCounter < 4; byteCounter++)
		scsiSectorBuffer[byteCounter] = hostadapterReadByte();
		
		defectListLength = (((uint32_t)scsiSectorBuffer[2] << 8) + (uint32_t)scsiSectorBuffer[3]) / 8;
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands:   Length = "), defectListLength,true);
		
		// Read the defect records
		for (defectListRecords = 0; defectListRecords < defectListLength; defectListRecords++) {
			// Read the defect data
			for (byteCounter = 0; byteCounter < 8; byteCounter++)
			scsiSectorBuffer[byteCounter] = hostadapterReadByte();
			
			// Output defect to debug
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Defect #"), defectListRecords,true);
			if (debugFlag_scsiCommands) debugStringInt32_P(PSTR("SCSI Commands:   Cylinder = "),
			((uint32_t)scsiSectorBuffer[0] << 16) + ((uint32_t)scsiSectorBuffer[1] << 8) + (uint32_t)scsiSectorBuffer[2],
			true);
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands:   Head = "), scsiSectorBuffer[3],true);
			if (debugFlag_scsiCommands) debugStringInt32_P(PSTR("SCSI Commands:   Bytes = "),
			((uint32_t)scsiSectorBuffer[4] << 24) + ((uint32_t)scsiSectorBuffer[5] << 16) +
			((uint32_t)scsiSectorBuffer[6] << 8) + (uint32_t)scsiSectorBuffer[7],
			true);
		}
	}
	
	// Create/recreate the LUN data file according to the drive descriptor and fill
	// with the required data pattern byte:
	if (!filesystemFormatLun(commandDataBlock.targetLUN, dataPattern)) {
		// Formatting failed...
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Format failed\r\n"));
		
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x1C; // 1C Bad format
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		// The LUN is in an unknown state... Flag the LUN as unavailable
		filesystemSetLunStatus(commandDataBlock.targetLUN, false);
		
		return SCSI_STATUS;
	}
	
	// Tell the file system to start the new LUN
	filesystemSetLunStatus(commandDataBlock.targetLUN, true);
	
	// Indicate successful command in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	
	return SCSI_STATUS;
}

// SCSI Command (0x08) Read6
//
// Adaptec ACB-4000 Manual notes:
// The READ command is used to read data from the drive to the
// host.
//
// A COMPLETION STATUS may give a check condition that leads to the
// possible errors of: Bad Argument, all class 00 errors,
// 10 ECC error, 10 address mark not found, seek error and record
// not found, plus others.
//
// If a Data ECC error occurs during the read, the controller will
// re-read the block up to four times to establish a solid error
// correction block (syndrome). Correction may occur after two
// retries are completed if the error syndrome is repeated twice
// consecutively. Correction is done directly into the controller's
// data buffer, transparent to the host.
//
// The host now expects 255 blocks of data from the drive to follow.
// These will be read from the disk, starting at logical block 0
// and continuing to 254.
uint8_t scsiCommandRead6(void)
{
	uint32_t logicalBlockAddress = 0;
	uint32_t numberOfBlocks = 0;
	uint32_t currentBlock = 0;
	
	uint16_t bytesTransferred = 0;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: READ command (0x08) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, false);
	}
	
	// Make sure the target LUN is started
	if (!filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// Target LUN is not started.  If the LUN is present, then start it, otherwise
		// return an error.  Note: The original Adaptec SCSI host adapter would always
		// auto-start a LUN if it was present, so we duplicate that behavior here even 
		// though it is 'more correct' (according to the specs) to return with error
		
		// Is the requested LUN available?
		if (debugFlag_scsiCommands) debugString_P(PSTR("\r\nSCSI Commands: Attempting to Auto-Start LUN (as it is currently STOPped)\r\n"));
		
		// Auto-start the LUN
		if (!filesystemSetLunStatus(commandDataBlock.targetLUN, true)) {
			// Could not start LUN... return with error status
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Could not auto-start LUN #"), commandDataBlock.targetLUN,true);
			commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
			commandDataBlock.message = 0x00;
			
			// Set request sense error globals
			requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
			requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
			requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
			requestSenseData[commandDataBlock.targetLUN].errorCode = 0x1C; // 1C Bad format
			requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
			
			return SCSI_STATUS;
		}
		
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Requested LUN has been auto-started\r\n"));
		
		// Output the initial debug again (as the command debug information is appended to it)
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, false);
	}
	
	// Get the starting logical block address from the CDB
	logicalBlockAddress = (((uint32_t)commandDataBlock.data[1] & 0x1F) << 16) |
	((uint32_t)commandDataBlock.data[2] << 8) |
	((uint32_t)commandDataBlock.data[3]);
	
	// Get the requested number of blocks from the CDB
	numberOfBlocks = (uint32_t)commandDataBlock.data[4];
	if (numberOfBlocks == 0) numberOfBlocks = 256; // 0 = 256 blocks according to the SCSI specification
	
	// Show the command debug information
	if (debugFlag_scsiCommands) debugStringInt32_P(PSTR(", LBA = "), logicalBlockAddress, false);
	if (debugFlag_scsiCommands) debugStringInt32_P(PSTR(", Blocks = "), numberOfBlocks, true);
	
	// Set up the control signals ready for the data in phase
	scsiInformationTransferPhase(ITPHASE_DATAIN);
	
	// Open the required LUN image for reading
	if(!filesystemOpenLunForRead(commandDataBlock.targetLUN, logicalBlockAddress, numberOfBlocks)) {
		// Opening the LUN image failed... try to recover with a little grace...
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: ERROR: Open LUN image failed!\r\n"));
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		// The LUN is in an unknown state... Stop the LUN
		filesystemCloseLunForRead();
		filesystemSetLunStatus(commandDataBlock.targetLUN, false);
		
		return SCSI_STATUS;
	}

	// Transfer the requested blocks from the LUN image to the host
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Transferring requested blocks to the host...\r\n"));
	for (currentBlock = 0; currentBlock < numberOfBlocks; currentBlock++) {

		// Read the requested block from the LUN image
		if(!filesystemReadNextSector(scsiSectorBuffer)) {
			// Reading from the LUN image failed... try to recover with a little grace...
			if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: ERROR: Could not read next sector from LUN image!\r\n"));
			commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
			commandDataBlock.message = 0x00;
			
			// Set request sense error globals
			requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
			requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
			requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
			requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
			requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
			
			// The LUN is in an unknown state... Stop the LUN
			filesystemCloseLunForRead();
			filesystemSetLunStatus(commandDataBlock.targetLUN, false);
			
			return SCSI_STATUS;
		}
		
		// Send the data to the host
		cli();
		bytesTransferred = hostadapterPerformReadDMA(scsiSectorBuffer);
		sei();
		
		// Check for a host reset condition
		if (hostadapterReadResetFlag()) {
			sei();
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Read DMA interrupted by host reset at byte #"), bytesTransferred, true);
			
			// Close the currently open LUN image
			filesystemCloseLunForRead();
			
			return SCSI_BUSFREE;
		}
		
		// Show debug
		if (!debugFlag_scsiBlocks) {
			if (debugFlag_scsiCommands) debugStringInt32_P(PSTR(""), currentBlock, false);
			if (debugFlag_scsiCommands) debugString_P(PSTR(" "));
		} else {
			if (debugFlag_scsiBlocks) {
				debugStringInt32_P(PSTR("Hex dump for block #"), currentBlock, true);
				debugSectorBufferHex(scsiSectorBuffer, 256);
			}
		}
	}
	if (debugFlag_scsiCommands || debugFlag_scsiBlocks) debugString_P(PSTR("\r\n"));
	
	// Close the currently open LUN image
	filesystemCloseLunForRead();
	
	// Indicate successful transfer in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Read6 command successful\r\n"));
	
	// Transition to the successful state
	return SCSI_STATUS;
}

// SCSI Command (0x0A) Write6
//
// Adaptec ACB-4000 Manual notes:
// The WRITE command is used to write data from the host to the
// disk.
//
// A COMPLETION STATUS may give a check condition that leads to the
// possible errors of: Bad argument, all class 00 errors,
// ID ECC error, ID address mark not found, seek error and record
// not found, plus others.
//
// The controller now expects 255 blocks of data from the host
// adapter to follow. These will be written onto the disk, starting
// at logical block 0 and continuing to 254.
uint8_t scsiCommandWrite6(void)
{
	uint32_t logicalBlockAddress = 0;
	uint32_t numberOfBlocks = 0;
	uint32_t currentBlock = 0;
	
	uint16_t bytesTransferred = 0;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: WRITE command (0x0A) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, false);
	}
	
	// Make sure the target LUN is started
	if (!filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// Target LUN is not started.  If the LUN is present, then start it, otherwise
		// return an error.  Note: The original Adaptec SCSI host adapter would always
		// auto-start a LUN if it was present, so we duplicate that behavior here even
		// though it is 'more correct' (according to the specs) to return with error
		
		// Is the requested LUN available?
		if (debugFlag_scsiCommands) debugString_P(PSTR("\r\nSCSI Commands: Attempting to Auto-Start LUN (as it is currently STOPped)\r\n"));
		
		// Auto-start the LUN
		if (!filesystemSetLunStatus(commandDataBlock.targetLUN, true)) {
			// Could not start LUN... return with error status
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Could not auto-start LUN #"), commandDataBlock.targetLUN,true);
			commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
			commandDataBlock.message = 0x00;
			
			// Set request sense error globals
			requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
			requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
			requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
			requestSenseData[commandDataBlock.targetLUN].errorCode = 0x1C; // 1C Bad format
			requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
			
			return SCSI_STATUS;
		}
		
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Requested LUN has been auto-started\r\n"));
	}
	
	// Get the starting logical block address from the CDB
	logicalBlockAddress = (((uint32_t)commandDataBlock.data[1] & 0x1F) << 16) |
	((uint32_t)commandDataBlock.data[2] << 8) |
	((uint32_t)commandDataBlock.data[3]);
	
	// Get the requested number of blocks from the CDB
	numberOfBlocks = (uint32_t)commandDataBlock.data[4];
	if (numberOfBlocks == 0) numberOfBlocks = 256; // 0 = 256 blocks according to the SCSI specification
	
	// Show the command debug information
	if (debugFlag_scsiCommands) {
		debugStringInt32_P(PSTR(", LBA = "), logicalBlockAddress, false);
		debugStringInt32_P(PSTR(", Blocks = "), numberOfBlocks, true);	
	}
	
	// Set up the control signals ready for the data out phase
	scsiInformationTransferPhase(ITPHASE_DATAOUT);
	
	// Open the required LUN image for writing
	if(!filesystemOpenLunForWrite(commandDataBlock.targetLUN, logicalBlockAddress, numberOfBlocks)) {
		// Opening the LUN image failed... try to recover with a little grace...
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Command: ERROR: Could not open LUN image for writing!\r\n"));
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		// The LUN is in an unknown state... Stop the LUN
		filesystemCloseLunForWrite();
		filesystemSetLunStatus(commandDataBlock.targetLUN, false);
		
		return SCSI_STATUS;
	}
	
	// Transfer the requested blocks from the host to the LUN image
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Transferring requested blocks from the host...\r\n"));
	for (currentBlock = 0; currentBlock < numberOfBlocks; currentBlock++) {
		// Get the data from the host
		cli();
		bytesTransferred = hostadapterPerformWriteDMA(scsiSectorBuffer);
		sei();
		
		// Check for a host reset condition
		if (hostadapterReadResetFlag()) {
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Write DMA interrupted by host reset at byte #"), bytesTransferred, true);
			
			// Close the currently open LUN image
			filesystemCloseLunForWrite();
			
			return SCSI_BUSFREE;
		}
		
		// Write the requested block to the LUN image
		if(!filesystemWriteNextSector(scsiSectorBuffer)) {
			// Writing to the LUN image failed... try to recover with a little grace...
			if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: ERROR: Writing to LUN image failed!\r\n"));
			commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
			commandDataBlock.message = 0x00;
			
			// Set request sense error globals
			requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
			requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
			requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
			requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
			requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
			
			// The LUN is in an unknown state... Stop the LUN
			filesystemCloseLunForWrite();
			filesystemSetLunStatus(commandDataBlock.targetLUN, false);
			
			return SCSI_STATUS;
		}
		
		// Show debug
		if (!debugFlag_scsiBlocks) {
			if (debugFlag_scsiCommands) debugStringInt32_P(PSTR(""), currentBlock, false);
			if (debugFlag_scsiCommands) debugString_P(PSTR(" "));
		} else {
			if (debugFlag_scsiBlocks) {
				debugStringInt32_P(PSTR("Hex dump for block #"), currentBlock, true);
				debugSectorBufferHex(scsiSectorBuffer, 256);
			}
		}
	}
	if (debugFlag_scsiCommands || debugFlag_scsiBlocks) debugString_P(PSTR("\r\n"));
	
	// Close the currently open LUN image
	filesystemCloseLunForWrite();
	
	// Indicate successful transfer in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Write6 command successful\r\n"));
	
	// Transition to the successful state
	return SCSI_STATUS;
}

// SCSI Command (0x0B) Seek
//
// This command is reported to be used in some (unknown) ADFS utilities.  It
// doesn't serve a purpose for the file system implementation, but is included for
// completeness.  It simply returns successfully if the specified LUN is available.
uint8_t scsiCommandSeek(void)
{
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: SEEK command (0x0B) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Check to see if the requested LUN is started
	if (filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// Indicate successful command in status and message
		commandDataBlock.status = 0x00; // 0x00 = Good
		commandDataBlock.message = 0x00;
	} else {
		// Indicate unsuccessful command in status and message
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Unavailable LUN #"), commandDataBlock.targetLUN, true);
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Failed
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x02; // Unit not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	return SCSI_STATUS;
}

// SCSI Command (0x0F) Translate
//
// Adaptec ACB-4000 Manual notes:
// This command performs a logical address to physical address
// translation and returns the physical location of the requested
// block address in a cylinder, head, bytes from index format. This
// data can be used to build a defect list for the FORMAT command.
//
// Note: This translation isn't really required since
// the physical storage geometry doesn't have any head or cylinders.
// However, to emulate defect mapping (i.e. make the emulation act
// like a physical SCSI drive) it's good to include it anyway.
uint8_t scsiCommandTranslate(void)
{
	uint32_t cylinderNumber;
	uint32_t headNumber;
	uint32_t bytesFromIndex;
	uint32_t logicalBlockAddress;
	uint32_t headsPerCylinder;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: TRANSLATE command (0x0F) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Make sure the target LUN is started
	if (!filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// LUN unavailable... return with error status
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Unavailable LUN #"), commandDataBlock.targetLUN, true);
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Get the logical block address from the CDB
	logicalBlockAddress = ((uint32_t)(commandDataBlock.data[1] & 0x1F) << 16) |
	((uint32_t)commandDataBlock.data[2] << 8) |
	((uint32_t)commandDataBlock.data[3]);
	
	// We have to translate the LBA (in the CDB) into an 8 byte response:
	// 00 Cylinder number (MSB)
	// 01 Cylinder number
	// 02 Cylinder number (LSB)
	// 03 Head number
	// 04 Bytes from index (MSB)
	// 05 Bytes from index
	// 06 Bytes from index
	// 07 Bytes from index (LSB)
	
	// From Wikipedia (https://en.wikipedia.org/wiki/Logical_block_addressing):
	//
	// CHS tuples can be mapped to LBA address with the following formula:
	//
	// LBA = (C x HPC + H) x SPT + (S - 1)
	//
	// where
	//
	// C, H and S are the cylinder number, the head number, and the sector number
	// LBA is the logical block address
	// HPC is the maximum number of heads per cylinder (reported by disk drive, typically 16 for 28-bit LBA)
	// SPT is the maximum number of sectors per track (reported by disk drive, typically 63 for 28-bit LBA)
	//
	// LBA addresses can be mapped to CHS tuples with the following formula ("mod" is the modulo operation,
	// i.e. the remainder, and "/" is integer division, i.e. the quotient of the division where any fractional
	// part is discarded):
	//
	// C = LBA / (HPC * SPT)
	// H = (LBA / SPT) mod HPC
	// S = (LBA mod SPT) + 1
	
	// Note: The 'bytes from index' is the number of bytes from the start of the track (to the defect)
	
	// Read the geometry description for the LUN into the sector buffer
	if (!filesystemReadLunDescriptor(commandDataBlock.targetLUN, scsiSectorBuffer)) {
		// Unable to read drive descriptor! Exit with error status
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
	
		debugString_P(PSTR("SCSI Commands: ERROR: Could not read geometry from LUN descriptor\r\n"));
		
		// Transition to the STATUS state
		return SCSI_STATUS;
	}
	
	// Get the number of heads per cylinder (HPC)
	headsPerCylinder = (uint32_t)scsiSectorBuffer[15]; // Data head count
	
	// Convert LBA to CHS (sectors per track is always 33)
	cylinderNumber = logicalBlockAddress / (headsPerCylinder * 33);
	headNumber = (logicalBlockAddress / 33) % headsPerCylinder;
	bytesFromIndex = ((logicalBlockAddress % 33) + 1) * 256; // Sector number * block size (256)
	
	if (debugFlag_scsiCommands) {
		debugStringInt32_P(PSTR("SCSI Commands:   LBA = "), logicalBlockAddress,true);
		debugStringInt32_P(PSTR("SCSI Commands:   Heads/Cyl = "), headsPerCylinder,true);
		debugStringInt32_P(PSTR("SCSI Commands:   Cylinder = "), cylinderNumber,true);
		debugStringInt32_P(PSTR("SCSI Commands:   Head = "), headNumber,true);
		debugStringInt32_P(PSTR("SCSI Commands:   Bytes = "), bytesFromIndex,true);
	}
	
	// Set up the control signals ready for the data in phase
	scsiInformationTransferPhase(ITPHASE_DATAIN);
	
	// Send the translation data to the host
	hostadapterWriteByte((uint8_t)((cylinderNumber & 0xFF0000) >> 16));		// Cylinder number MSB
	hostadapterWriteByte((uint8_t)((cylinderNumber & 0xFF00) >> 8));		// Cylinder number
	hostadapterWriteByte((uint8_t)(cylinderNumber & 0xFF));					// Cylinder number LSB
	
	hostadapterWriteByte((uint8_t)headNumber);								// Head number
	
	hostadapterWriteByte((uint8_t)((bytesFromIndex & 0xFF000000) >> 24));	// Bytes from index MSB
	hostadapterWriteByte((uint8_t)((bytesFromIndex & 0x00FF0000) >> 16));	// Bytes from index
	hostadapterWriteByte((uint8_t)((bytesFromIndex & 0x0000FF00) >> 8));	// Bytes from index
	hostadapterWriteByte((uint8_t)( bytesFromIndex & 0x000000FF));			// Bytes from index LSB
	
	// Indicate successful command in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	
	return SCSI_STATUS;
}

// SCSI Command (0x15) ModeSelect
//
// Adaptec ACB-4000 Manual notes:
// This command is used in the ACB-4000 Series Controllers to
// specify format parameters and should always precede the FORMAT
// command. When a blown format error (code 1C) is detected
// due to the controller being unable to read the drive
// information from a drive already formatted, the user should use
// this command to inform the controller about the drive
// information. Once initialized, most data on the drive will be
// recoverable. The information can then be recovered and the drive
// reformatted, and writes to the drive will not be permitted.
//
// Note: This function writes the LUN descriptor to the file system
// containing the drive geometry information
uint8_t scsiCommandModeSelect(void)
{
	uint8_t byteCounter;

	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: MODESELECT command (0x15) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Make sure the target LUN is started
	if (!filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// If the target LUN is unavailable then the host is probably attempting to MODESELECT
		// a LUN for which no descriptor exists.  So here we create the LUN descriptor
		if(!filesystemCreateLunDescriptor(commandDataBlock.targetLUN)) {
			// LUN descriptor is unavailable and cannot be created... return with error status
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Create descriptor failed LUN #"), commandDataBlock.targetLUN,true);
			commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
			commandDataBlock.message = 0x00;
			
			// Set request sense error globals
			requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
			requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
			requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
			requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
			requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
			
			return SCSI_STATUS;
		}
		
		// LUN files created
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Created descriptor for LUN #"), commandDataBlock.targetLUN,true);
	}
	
	if (commandDataBlock.data[4] != 22) {
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Bad Argument error\r\n"));
		// Indicate unsuccessful command in status and message
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x24; // Bad argument
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Set up the control signals ready for the data out phase
	scsiInformationTransferPhase(ITPHASE_DATAOUT);
	
	// Read the 22 byte descriptor from the host
	for (byteCounter = 0; byteCounter < commandDataBlock.data[4]; byteCounter++)
	scsiSectorBuffer[byteCounter] = hostadapterReadByte();
	
	// Output the geometry to debug
	// TODO!
	
	// Write the descriptor information to the file system
	if(!filesystemWriteLunDescriptor(commandDataBlock.targetLUN, scsiSectorBuffer)) {
		// Write failed! - Indicate unsuccessful command in status and message
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Writing LUN descriptor failed!\r\n"));
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Error
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Indicate successful command in status and message
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Writing LUN descriptor successful\r\n"));
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	
	return SCSI_STATUS;
}

// SCSI Command (0x1A) ModeSense
//
// Adaptec ACB-4000 Manual notes:
// This command is used to interrogate the ACB-4000A and ACB-4070
// device parameter table to determine the specific characteristics
// of any disk drive currently attached. The attached drive must
// have been formatted by an ACB-4000A or ACB-4070 for this to be a
// legal command.
uint8_t scsiCommandModeSense(void)
{
	uint8_t byteCounter;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: MODESENSE command (0x1A) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// We do not check if the LUN is available since there (at this point) may only be a descriptor
	// file for the LUN.  If the descriptor cannot be read we assume that the LUN is completely unavailable
	
	// We emulate soft-sectored hard drives only, so the drive parameter list must be 22 bytes
	if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: List length = "), commandDataBlock.data[4],true);
	if (commandDataBlock.data[4] != 22) {
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Bad Argument error\r\n"));
		// Indicate unsuccessful command in status and message
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x24; // Bad argument
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Read the drive descriptor
	if (filesystemReadLunDescriptor(commandDataBlock.targetLUN, scsiSectorBuffer)) {
		// DSC read OK - Transfer the DSC contents to the host
		
		// Set up the control signals ready for the data in phase
		scsiInformationTransferPhase(ITPHASE_DATAIN);
		
		// Transfer the DSC contents
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Sending LUN descriptor to host\r\n"));
		for (byteCounter = 0; byteCounter < 22; byteCounter++)
		hostadapterWriteByte(scsiSectorBuffer[byteCounter]);
	} else {
		// DSC not OK
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Descriptor read error\r\n"));
		
		// Indicate unsuccessful command in status and message
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x24; // Bad argument
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Indicate successful command in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	
	return SCSI_STATUS;
}

// SCSI Command (0x1B) StartStop
//
// Adaptec ACB-4000 Manual notes:
// Byte 04, bit 00 of this command should be set to 01 if this is a
// START command, and 00 for a STOP command.
//
// This command is designed for use on drives with a designated
// shipping or landing zone.
//
// A STOP command will position the head to the landing zone
// position. See the MODE SELECT command for description of the
// landing zone value.
uint8_t scsiCommandStartStop(void)
{
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: STARTSTOP command (0x1B) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Is this a START or STOP command?
	if (commandDataBlock.data[4] == 0) {
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Stopping LUN\r\n"));
		
		// Make the target LUN unavailable
		filesystemSetLunStatus(commandDataBlock.targetLUN, false);
	} else {
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Starting LUN\r\n"));
		
		// Start the LUN
		if (!filesystemSetLunStatus(commandDataBlock.targetLUN, true)) {
			// Could not start LUN... return with error status
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Could not start LUN #"), commandDataBlock.targetLUN,true);
			commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
			commandDataBlock.message = 0x00;
			
			// Set request sense error globals
			requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
			requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
			requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
			requestSenseData[commandDataBlock.targetLUN].errorCode = 0x24; // Bad argument
			requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
			
			return SCSI_STATUS;
		}
	}
	
	// Exit with success
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	
	// Transition to the successful state
	return SCSI_STATUS;
}

// SCSI Command (0x2F) Verify
//
// Adaptec ACB-4000 Manual notes:
//
// This command is similar to the previous WRITE AND VERIFY except
// that it verifies the ECC of an already existing set of data
// blocks. No write Operation is performed. It is up to the host
// to provide data for rewriting and correcting if an ECC error
// is detected.
//
// Note: Group 1 commands accept an extended LBA (4 bytes) and
//       a 16-bit 'number of blocks' (i.e. up to 65536 blocks)
 
// Note: This function is used by the *VERIFY command provided in the
//       library directory of the BBC Master welcome disc
uint8_t scsiCommandVerify(void)
{
	uint32_t logicalBlockAddress = 0;
	uint32_t lunSizeInSectors = 0;
	uint32_t numberOfBlocks = 0;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: VERIFY command (0x2F) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, false);
	}
	
	// Make sure the target LUN is started
	if (!filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// LUN unavailable... return with error status
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("\r\nSCSI Commands: Unavailable LUN #"), commandDataBlock.targetLUN,true);
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Get the logical block address from the CDB (note: this is different from G0 commands
	// as 4 bytes of LBA are provided)
	logicalBlockAddress = 
		((uint32_t)commandDataBlock.data[2] << 24) |
		((uint32_t)commandDataBlock.data[3] << 16) |
		((uint32_t)commandDataBlock.data[4] << 8) |
		((uint32_t)commandDataBlock.data[5]);
		
	// Get the requested number of blocks
	// Get the requested number of blocks from the CDB
	numberOfBlocks =
		((uint32_t)commandDataBlock.data[7] << 8) |
		((uint32_t)commandDataBlock.data[8]);
		
	// If the number of blocks is 0, set to the maximum of 65536
	if (numberOfBlocks == 0) numberOfBlocks = 65536;
	
	// Show the command debug information
	if (debugFlag_scsiCommands) debugStringInt32_P(PSTR(", LBA = "), logicalBlockAddress, false);
	if (debugFlag_scsiCommands) debugStringInt32_P(PSTR(", number of blocks = "), numberOfBlocks, true);
	
	// Read the drive descriptor
	if (filesystemReadLunDescriptor(commandDataBlock.targetLUN, scsiSectorBuffer)) {
		// Get the LUN size (as number of available sectors)
		// The drive size (actual data storage) is calculated by the following formula:
		//
		// tracks = heads * cylinders
		// sectors = tracks * 33 (33 tracks per sector)
		lunSizeInSectors = ((uint32_t)scsiSectorBuffer[15] * (((uint32_t)scsiSectorBuffer[13] << 8) + (uint32_t)scsiSectorBuffer[14])) * 33;
	} else {
		// DSC not OK
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: DSC read error\r\n"));
		// Indicate unsuccessful command in status and message
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Check that the LBA is within range of the LUN size
	if (logicalBlockAddress >= lunSizeInSectors) {
		// Out of range
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: ERROR: Requested LBA is out-of-range for the LUN size - Verify failed\r\n"));
		
		// Set error status
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = true;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x21; // Illegal block address
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = logicalBlockAddress;
		
		return SCSI_STATUS;
	} else {
		// In range
		
		// Indicate successful command in status and message
		commandDataBlock.status = 0x00; // 0x00 = Good
		commandDataBlock.message = 0x00;
	}
	
	return SCSI_STATUS;
}

// LV-DOS specific group 6 commands -----------------------------------------------------------------------------------

// SCSI Command Write F-Code (group 6 - command 0x0A)
//
// Notes from the VP415 manual:
// This command allows the initiator to write an F-code to a specific logic
// unit. A data out phase is required, in which the F-code command is
// sent and terminated by a 'CR' character and null padded until the end
// of the block.
uint8_t scsiWriteFCode(void)
{
	uint16_t bytesTransferred = 0;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: WRITE F-Code command (G6 0x0A) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Make sure the target LUN is started
	if (!filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// LUN unavailable... return with error status
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("\r\nSCSI Commands: Unavailable LUN #"), commandDataBlock.targetLUN, true);
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x02; // Unit not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Set up the control signals ready for the data out phase
	scsiInformationTransferPhase(ITPHASE_DATAOUT);
	
	// Transfer a single block from the file system to the host
	// Note: Since VFS is slower than ADFS we do not disable interrupts here as
	// disabling interrupts can cause incoming serial bytes to be lost
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Transferring F-Code buffer from the host...\r\n"));
	bytesTransferred = hostadapterPerformWriteDMA(scsiFcodeBuffer);
		
	// Check for a host reset condition
	if (hostadapterReadResetFlag()) {
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Write DMA interrupted by host reset at byte #"), bytesTransferred, true);
		return SCSI_BUSFREE;
	}
		
	// Write the requested F-Code to the Laser Video Disc Player
	fcodeWriteBuffer(commandDataBlock.targetLUN);
	
	// Indicate successful transfer in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Write F-Code command successful\r\n"));
	
	// Transition to the successful state
	return SCSI_STATUS;
}

// SCSI Command Read F-Code (group 6 - command 0x08)
//
// Notes from the VP415 manual:
// This command allows the initiator to read the reply code from the reply
// code buffer for the specified logic unit in LV-DOS. If there is a reply
// code from the player then the reply code is sent; it is terminated by a
// 'CR' character and null padded until the end of the block. If there is no
// reply code the first character of the block is a 'CR' character. A data in
// phase is necessary.
uint8_t scsiReadFCode(void)
{
	uint16_t bytesTransferred = 0;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: READ F-Code command (G6 0x08) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Make sure the target LUN is started
	if (!filesystemReadLunStatus(commandDataBlock.targetLUN)) {
		// LUN unavailable... return with error status
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("\r\nSCSI Commands: Unavailable LUN #"), commandDataBlock.targetLUN,true);
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x02; // Unit not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Set up the control signals ready for the data in phase
	scsiInformationTransferPhase(ITPHASE_DATAIN);
	
	// Ensure the buffer is ready for the host to read
	fcodeReadBuffer();
		
	// Send the data to the host
	// Note: Since VFS is slower than ADFS we do not disable interrupts here as
	// disabling interrupts can cause incoming serial bytes to be lost
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Transferring F-Code buffer to the host...\r\n"));
	bytesTransferred = hostadapterPerformReadDMA(scsiFcodeBuffer);
		
	// Check for a host reset condition
	if (hostadapterReadResetFlag()) {
		sei();
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Read DMA interrupted by host reset at byte #"), bytesTransferred, true);
		
		return SCSI_BUSFREE;
	}
	
	// Indicate successful transfer in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Read F-Code command successful\r\n"));
	
	// Transition to the successful state
	return SCSI_STATUS;
}

// BeebSCSI specific group 6 commands -----------------------------------------------------------------------------------

// SCSI Command BeebSCSI Sense (group 6 - command 0x10)
//
// This is a BeebSCSI vendor specific command.
uint8_t scsiBeebScsiSense(void)
{
	uint8_t lunStatus = 0;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: BSSENSE command (G6 0x10) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// This command does not use the LUN number
	
	// The parameter list must be 8 bytes
	if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: List length = "), commandDataBlock.data[4],true);
	if (commandDataBlock.data[4] != 8) {
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Bad Argument error\r\n"));
		// Indicate unsuccessful command in status and message
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x24; // Bad argument
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Set up the control signals ready for the data in phase
	scsiInformationTransferPhase(ITPHASE_DATAIN);
		
	// Transfer the BSSENSE status bytes
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Sending BSSENSE descriptor to host\r\n"));
	
	// Byte 0 shows the START/STOP status of each LUN (1 = started)
	if (filesystemReadLunStatus(0)) lunStatus |= (1 << 0);
	if (filesystemReadLunStatus(1)) lunStatus |= (1 << 1);
	if (filesystemReadLunStatus(2)) lunStatus |= (1 << 2);
	if (filesystemReadLunStatus(3)) lunStatus |= (1 << 3);
	if (filesystemReadLunStatus(4)) lunStatus |= (1 << 4);
	if (filesystemReadLunStatus(5)) lunStatus |= (1 << 5);
	if (filesystemReadLunStatus(6)) lunStatus |= (1 << 6);
	if (filesystemReadLunStatus(7)) lunStatus |= (1 << 7);
	hostadapterWriteByte(lunStatus);
	
	if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: LUN status byte = "), lunStatus, true);
	
	// Byte 1 shows the current LUN directory number
	hostadapterWriteByte(filesystemGetLunDirectory());
	
	if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: LUN directory number = "), filesystemGetLunDirectory(), true);
	
	// Byte 2 shows if we are in fixed (0) or VP415 emulation mode (1)
	if (emulationMode == FIXED_EMULATION) {
		hostadapterWriteByte(0x00);
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Emulation mode fixed (0x00)\r\n"));
	} else {
		hostadapterWriteByte(0x01);
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Emulation mode LV-DOS (0x01)\r\n"));
	}
	
	// Bytes 3 and 4 show the major and minor firmware version numbers
	hostadapterWriteByte(FIRMWARE_MAJOR);
	hostadapterWriteByte(FIRMWARE_MINOR);
	
	// Bytes 5 to 7 are for future use
	hostadapterWriteByte(0x00);
	hostadapterWriteByte(0x00);
	hostadapterWriteByte(0x00);
	
	// Indicate successful command in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	
	return SCSI_STATUS;
}

// SCSI Command BeebSCSI Select (group 6 - command 0x11)
//
// This is a BeebSCSI vendor specific command.
uint8_t scsiBeebScsiSelect(void)
{
	uint8_t byteCounter;
	uint8_t availableLUNs = 0;

	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: BSSELECT command (G6 0x11) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Expect 8 bytes of data	
	if (commandDataBlock.data[4] != 8) {
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Bad Argument error\r\n"));
		// Indicate unsuccessful command in status and message
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x24; // Bad argument
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Set up the control signals ready for the data out phase
	scsiInformationTransferPhase(ITPHASE_DATAOUT);
	
	// Read the 8 bytes from the host
	for (byteCounter = 0; byteCounter < commandDataBlock.data[4]; byteCounter++) {
		scsiSectorBuffer[byteCounter] = hostadapterReadByte();
		if (debugFlag_scsiCommands) {
			debugStringInt16_P(PSTR("SCSI Commands: Received byte "), (uint16_t)byteCounter, false);
			debugStringInt16_P(PSTR(" = "), (uint16_t)scsiSectorBuffer[byteCounter], true);
		}
	}
	
	// Check if any LUNs are in the started state
	for (byteCounter = 0; byteCounter < 8; byteCounter++)
		if (filesystemReadLunStatus(byteCounter)) availableLUNs++;
		
	// Only jukebox if no LUNs are in the started state
	if (availableLUNs == 0) {
		// Perform jukeboxing
		filesystemSetLunDirectory(scsiSectorBuffer[0]);
		
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Jukeboxing successful - LUN directory set to "), scsiSectorBuffer[0], true);
	} else {
		// One or more LUNs are started... cannot perform jukeboxing
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Error - cannot jukebox if LUNs are started\r\n"));
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x02; // Class 02 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x02; // Unit not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Indicate successful command in status and message
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: BSSELECT command successful\r\n"));
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	
	return SCSI_STATUS;
}


// Vendor-specific FAT file manipulation functions --------------

// SCSI Command BeebSCSI FATPATH (group 6 - command 0x12)
//
// This is a BeebSCSI vendor specific command.
//
uint8_t scsiBeebScsiFatPath(void)
{
	uint16_t bytesTransferred = 0;

	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: BSFATPATH command (G6 0x12) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}

	// This command does not use the LUN number

	// Set up the control signals ready for the data out phase
	scsiInformationTransferPhase(ITPHASE_DATAOUT);

	// Transfer a single block from the file system to the host
	// Note: Since VFS is slower than ADFS we do not disable interrupts here as
	// disabling interrupts can cause incoming serial bytes to be lost
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Transferring FAT path buffer from the host...\r\n"));
	cli();
	bytesTransferred = hostadapterPerformWriteDMA(scsiSectorBuffer);
	sei();
	
	// Check for a host reset condition
	if (hostadapterReadResetFlag()) {
		sei();
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Write DMA interrupted by host reset at byte #"), bytesTransferred, true);
		return SCSI_BUSFREE;
	}

	// Change the filesystem's FAT transfer directory
	filesystemSetFatDirectory(scsiSectorBuffer);

	// Show debug
	if (debugFlag_scsiBlocks) {
		debugString_P(PSTR("Hex dump for FAT path block:\r\n"));
		debugSectorBufferHex(scsiSectorBuffer, 256);
	}

	// Indicate successful transfer in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: BSFATPATH command successful\r\n"));

	// Transition to the successful state
	return SCSI_STATUS;
}

// SCSI Command BeebSCSI FATINFO (group 6 - command 0x13)
//
// This is a BeebSCSI vendor specific command.
//
// This function accepts a FAT file identification number (in the 5th field of the command)
// and returns a 256 byte buffer containing information about the FAT file.
//
// The buffer format is as follows:
// Byte 0: Status of file (0 = does not exist, 1 = file exists, 2 = directory)
// Byte 1 - 4: Size of file in number of bytes (32-bit)
// Byte 5 - 126: Reserved (0)
// Byte 127- 255: File name string terminated with 0x00 (NULL)
uint8_t scsiBeebScsiFatInfo(void)
{
	uint32_t fatFileId = 0;
	uint16_t bytesTransferred = 0;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: BSFATINFO command (G6 0x13) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// Get the requested FAT file ID
	fatFileId = (uint32_t)commandDataBlock.data[5];
	
	// Show the command debug information
	if (debugFlag_scsiCommands) debugStringInt32_P(PSTR("SCSI Commands: FAT file ID = "), fatFileId, true);
	
	// Set up the control signals ready for the data in phase
	scsiInformationTransferPhase(ITPHASE_DATAIN);
	
	// Get the FAT file information into the buffer for the host to read
	if(!filesystemGetFatFileInfo(fatFileId, scsiSectorBuffer)) {
		// Reading from the FAT image failed... try to recover with a little grace...
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: ERROR: Could not read FAT file information!\r\n"));
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	// Send the data to the host
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: Transferring FAT info buffer to the host...\r\n"));
	cli();
	bytesTransferred = hostadapterPerformReadDMA(scsiSectorBuffer);
	sei();
	
	// Check for a host reset condition
	if (hostadapterReadResetFlag()) {
		sei();
		if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Read DMA interrupted by host reset at byte #"), bytesTransferred, true);
		
		return SCSI_BUSFREE;
	}
	
	// Show debug
	if (debugFlag_scsiBlocks) {
		debugString_P(PSTR("Hex dump for FAT info block:\r\n"));
		debugSectorBufferHex(scsiSectorBuffer, 256);
	}
	
	// Indicate successful transfer in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: BSFATINFO command successful\r\n"));
	
	// Transition to the successful state
	return SCSI_STATUS;
}

// SCSI Command BeebSCSI FATREAD (group 6 - command 0x14)
//
// This is a BeebSCSI vendor specific command.
//
// This function accepts a FAT file identification number (in the 5th field of the command),
// a block offset (the block to start reading from) and a number of blocks.
//
// The requested number of blocks from the FAT file are transfered to the host
//
uint8_t scsiBeebScsiFatRead(void)
{
	uint32_t blockOffset = 0;
	uint32_t numberOfBlocks = 0;
	uint32_t fatFileId = 0;
	uint32_t currentBlock = 0;
	
	uint16_t bytesTransferred = 0;
	
	if (debugFlag_scsiCommands) {
		debugString_P(PSTR("SCSI Commands: BSFATREAD command (G6 0x14) received\r\n"));
		debugStringInt16_P(PSTR("SCSI Commands: Target LUN = "), commandDataBlock.targetLUN, true);
	}
	
	// This command does not use the LUN number
	
	// Get block offset
	blockOffset = (((uint32_t)commandDataBlock.data[1] & 0x1F) << 16) |
	((uint32_t)commandDataBlock.data[2] << 8) |
	((uint32_t)commandDataBlock.data[3]);
	
	// Get the requested FAT file ID
	fatFileId = (uint32_t)commandDataBlock.data[5];
	
	// Get the number of blocks requested (1-255)
	numberOfBlocks = (uint32_t)commandDataBlock.data[4];
	
	// Show the command debug information
	if (debugFlag_scsiCommands) debugStringInt32_P(PSTR("SCSI Commands: FAT file ID = "), fatFileId, true);
	if (debugFlag_scsiCommands) debugStringInt32_P(PSTR("SCSI Commands: Block offset = "), blockOffset, true);
	if (debugFlag_scsiCommands) debugStringInt32_P(PSTR("SCSI Commands: Number of requested blocks = "), numberOfBlocks, true);
	
	// Set up the control signals ready for the data in phase
	scsiInformationTransferPhase(ITPHASE_DATAIN);
	
	// Transfer the requested blocks from the FAT file to the host
	if(!filesystemOpenFatForRead(fatFileId, blockOffset + currentBlock)) {
		// Reading from the FAT image failed... try to recover with a little grace...
		if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: ERROR: Could not read next block from FAT image!\r\n"));
		commandDataBlock.status = (commandDataBlock.targetLUN << 5) | 0x02; // 0x02 = Bad
		commandDataBlock.message = 0x00;
		
		// Set request sense error globals
		requestSenseData[commandDataBlock.targetLUN].errorFlag = true;
		requestSenseData[commandDataBlock.targetLUN].validAddressFlag = false;
		requestSenseData[commandDataBlock.targetLUN].errorClass = 0x00; // Class 00 error code
		requestSenseData[commandDataBlock.targetLUN].errorCode = 0x04; // Drive not ready
		requestSenseData[commandDataBlock.targetLUN].logicalBlockAddress = 0x00;
		
		return SCSI_STATUS;
	}
	
	for (currentBlock = 0; currentBlock < numberOfBlocks; currentBlock++) {
		if(!filesystemReadNextFatBlock(scsiSectorBuffer)) {
			// Could not read block from FAT file system!
			sei();
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Failed to read new FAT block at byte #"), bytesTransferred, true);
			
			filesystemCloseFatForRead();
			return SCSI_BUSFREE;
		}
		
		// Send the data to the host
		cli();
		bytesTransferred = hostadapterPerformReadDMA(scsiSectorBuffer);
		sei();
		
		// Check for a host reset condition
		if (hostadapterReadResetFlag()) {
			sei();
			if (debugFlag_scsiCommands) debugStringInt16_P(PSTR("SCSI Commands: Read DMA interrupted by host reset at byte #"), bytesTransferred, true);
			
			filesystemCloseFatForRead();
			return SCSI_BUSFREE;
		}
		
		// Show debug
		if (debugFlag_scsiBlocks) {
			debugStringInt32_P(PSTR("Hex dump for block #"), currentBlock, true);
			debugSectorBufferHex(scsiSectorBuffer, 256);
		} else {
			if (debugFlag_scsiCommands) debugStringInt32_P(PSTR(""), currentBlock, false);
			if (debugFlag_scsiCommands) debugString_P(PSTR(" "));
		}
	}
	filesystemCloseFatForRead();
	if (debugFlag_scsiCommands || debugFlag_scsiBlocks) debugString_P(PSTR("\r\n"));
	
	// Indicate successful transfer in status and message
	commandDataBlock.status = 0x00; // 0x00 = Good
	commandDataBlock.message = 0x00;
	if (debugFlag_scsiCommands) debugString_P(PSTR("SCSI Commands: BSFATREAD command successful\r\n"));
	
	// Transition to the successful state
	return SCSI_STATUS;	
}