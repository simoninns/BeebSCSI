/************************************************************************
	statusled.c

	BeebSCSI status LED functions
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

#ifndef STATUSLED_H_
#define STATUSLED_H_

// Status LED hardware definitions
#define STATUS_LED_PORT		PORTE
#define STATUS_LED_PIN		PINE
#define STATUS_LED_DDR		DDRE
#define STATUS_LED			(1 << 0)

// Function prototypes
void statusledInitialise(void);
void statusledReset(void);

void statusledActivity(uint8_t state);

#endif /* STATUSLED_H_ */