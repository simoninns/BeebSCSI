/************************************************************************
	scsi.h

	BeebSCSI SCSI emulation functions
    BeebSCSI - BBC Micro SCSI Drive Emulator
    Copyright (C) 2018 Simon Inns

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

#ifndef SCSI_H_
#define SCSI_H_

// Global for the emulation mode (fixed or removable drive)
// Note: The fixed mode emulates SCSI-1 compliant hard drives for the Beeb
// The removable mode emulates the Laser Video Disc Player (LV-DOS) for Domesday
extern uint8_t emulationMode;

// SCSI emulation bus states
#define SCSI_BUSFREE	0
#define SCSI_COMMAND	1
#define SCSI_STATUS		2
#define SCSI_MESSAGE	3

// SCSI emulation command states (Group 0 commands)
#define SCSI_TESTUNITREADY	10
#define SCSI_REZEROUNIT		11
#define SCSI_REQUESTSENSE	12
#define SCSI_FORMAT			13
#define SCSI_READ6			14
#define SCSI_WRITE6			15
#define SCSI_SEEK			16
#define SCSI_TRANSLATE		17
#define SCSI_MODESELECT		18
#define SCSI_MODESENSE		19
#define SCSI_STARTSTOP		20
#define SCSI_VERIFY			21

// SCSI emulation command states (LV-DOS Group 6 commands)
#define SCSI_WRITE_FCODE	30
#define SCSI_READ_FCODE		31

// SCSI emulation command states (BeebSCSI Group 6 commands)
#define SCSI_BEEBSCSI_SENSE		40
#define SCSI_BEEBSCSI_SELECT	41

// SCSI Information transfer phases
#define ITPHASE_DATAOUT		0
#define ITPHASE_DATAIN		1
#define ITPHASE_COMMAND		2
#define ITPHASE_STATUS		3
#define ITPHASE_MESSAGEOUT	4
#define ITPHASE_MESSAGEIN	5

// Emulation mode (fixed / LV-DOS)
#define FIXED_EMULATION		0
#define LVDOS_EMULATION		1

// Function prototypes
void scsiInitialise(void);
void scsiReset(void);

void scsiProcessEmulation(void);
void scsiInformationTransferPhase(uint8_t transferPhase);

uint8_t scsiEmulationBusFree(void);
uint8_t scsiEmulationCommand(void);
uint8_t scsiEmulationStatus(void);
uint8_t scsiEmulationMessage(void);

uint8_t scsiCommandTestUnitReady(void);
uint8_t scsiCommandRezeroUnit(void);
uint8_t scsiCommandRequestSense(void);
uint8_t scsiCommandFormat(void);
uint8_t scsiCommandRead6(void);
uint8_t scsiCommandWrite6(void);
uint8_t scsiCommandSeek(void);
uint8_t scsiCommandTranslate(void);
uint8_t scsiCommandModeSelect(void);
uint8_t scsiCommandModeSense(void);
uint8_t scsiCommandStartStop(void);
uint8_t scsiCommandVerify(void);

uint8_t scsiWriteFCode(void);
uint8_t scsiReadFCode(void);

uint8_t scsiBeebScsiSense(void);
uint8_t scsiBeebScsiSelect(void);

#endif /* SCSI_H_ */