/************************************************************************
	usb.h

	BeebSCSI USB functions
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

#ifndef USB_H_
#define USB_H_

// USB hardware indicator (indicates board 7_7 and above)
#define USBIND_PORT	PORTF
#define USBIND_PIN	PINF
#define USBIND_DDR	DDRF
#define USBIND		(1 << 3)

// Function prototypes
void usbInitialise(void);
bool usbHardwareDetect(void);

#endif /* USB_H_ */