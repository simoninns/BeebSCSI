/************************************************************************
	fcode.h

	BeebSCSI F-Code emulation functions
    BeebSCSI - BBC Micro SCSI Drive Emulator
    Copyright (C) 2018-2019 Simon Inns

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

#ifndef FCODE_H_
#define FCODE_H_

// External global
extern uint8_t scsiFcodeBuffer[256];

// Function prototypes
void fcodeWriteBuffer(uint8_t lunNumber);
void fcodeReadBuffer(void);

#endif /* FCODE_H_ */