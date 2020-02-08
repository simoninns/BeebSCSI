/************************************************************************
	hostadapter.h

	BeebSCSI Acorn host adapter functions
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

#ifndef HOSTADAPTER_H_
#define HOSTADAPTER_H_

// Host adapter hardware definitions

// SCSI control signals (inputs)
#define NRST_PORT		PORTD
#define NRST_PIN		PIND
#define NRST_DDR		DDRD
#define NRST			(1 << 0)

#define NRST_INT		INT0
#define NRST_INT_VECT	INT0_vect
#define NRST_ISC0		ISC00
#define NRST_ISC1		ISC01
#define NRST_INTF		INTF0
#define NRST_EICR		EICRA

#define NCONF_PORT		PORTD
#define NCONF_PIN		PIND
#define NCONF_DDR		DDRD
#define NCONF			(1 << 1)

#define NCONF_INT		INT1
#define NCONF_INT_VECT	INT1_vect
#define NCONF_ISC0		ISC10
#define NCONF_ISC1		ISC11
#define NCONF_INTF		INTF1
#define NCONF_EICR		EICRA

#define NACK_PORT		PORTC
#define NACK_PIN		PINC
#define NACK_DDR		DDRC
#define NACK			(1 << 7)

#define NSEL_PORT		PORTC
#define NSEL_PIN		PINC
#define NSEL_DDR		DDRC
#define NSEL			(1 << 6)

#define INTNEXT_PORT	PORTC
#define INTNEXT_PIN		PINC
#define INTNEXT_DDR		DDRC
#define INTNEXT			(1 << 5)

// SCSI status signals (outputs)
#define STATUS_NMSG_PORT	PORTC
#define STATUS_NMSG_PIN		PINC
#define STATUS_NMSG_DDR		DDRC
#define STATUS_NMSG			(1 << 0)

#define STATUS_NBSY_PORT	PORTC
#define STATUS_NBSY_PIN		PINC
#define STATUS_NBSY_DDR		DDRC
#define STATUS_NBSY			(1 << 1)

#define STATUS_NREQ_PORT	PORTC
#define STATUS_NREQ_PIN		PINC
#define STATUS_NREQ_DDR		DDRC
#define STATUS_NREQ			(1 << 2)

#define STATUS_INO_PORT		PORTC
#define STATUS_INO_PIN		PINC
#define STATUS_INO_DDR		DDRC
#define STATUS_INO			(1 << 3)

#define STATUS_CND_PORT		PORTC
#define STATUS_CND_PIN		PINC
#define STATUS_CND_DDR		DDRC
#define STATUS_CND			(1 << 4)

// Host adapter data bus (all of port A)
#define DATABUS_PORT	PORTA
#define DATABUS_PIN		PINA
#define DATABUS_DDR		DDRA

// Function prototypes
void hostadapterInitialise(void);
void hostadapterReset(void);

uint8_t hostadapterReadDatabus(void);
void hostadapterWritedatabus(uint8_t databusValue);

void hostadapterDatabusInput(void);
void hostadapterDatabusOutput(void);

uint8_t hostadapterReadByte(void);
void hostadapterWriteByte(uint8_t databusValue);

uint16_t hostadapterPerformReadDMA(uint8_t *dataBuffer);
uint16_t hostadapterPerformWriteDMA(uint8_t *dataBuffer);

bool hostadapterConnectedToExternalBus(void);

void hostadapterWriteResetFlag(bool flagState);
bool hostadapterReadResetFlag(void);
void hostadapterWriteDataPhaseFlags(bool message, bool commandNotData, bool inputNotOutput);

void hostadapterWriteBusyFlag(bool flagState);
void hostadapterWriteRequestFlag(bool flagState);
bool hostadapterReadSelectFlag(void);

#endif /* HOSTADAPTER_H_ */