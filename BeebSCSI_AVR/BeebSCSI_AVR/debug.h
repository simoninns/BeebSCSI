/************************************************************************
	debug.h

	BeebSCSI serial debug functions
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

#ifndef DEBUG_H_
#define DEBUG_H_

// External globals
extern volatile bool debugFlag_filesystem;
extern volatile bool debugFlag_scsiCommands;
extern volatile bool debugFlag_scsiBlocks;
extern volatile bool debugFlag_scsiFcodes;
extern volatile bool debugFlag_scsiState;
extern volatile bool debugFlag_fatfs;
extern volatile bool debugFlag_fatTransfer;

// Function prototypes
void debugString_P(const char *addr);
void debugString(char *string);
void debugStringInt8Hex_P(const char *addr, uint8_t integerValue, bool newLine);
void debugStringInt16_P(const char *addr, uint16_t integerValue, bool newLine);
void debugStringInt32_P(const char *addr, uint32_t integerValue, bool newLine);

void debugSectorBufferHex(uint8_t *buffer, uint16_t numberOfBytes);
void debugLunDescriptor(uint8_t *buffer);

#endif /* DEBUG_H_ */