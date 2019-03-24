/************************************************************************
	usb.c

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

// Global includes
#include <avr/io.h>
#include <avr/pgmspace.h>

#include <stdbool.h>
#include <stdio.h>

// Local includes
#include "uart.h"
#include "debug.h"
#include "usb.h"

// Function to initialise the USB subsystem
void usbInitialise(void)
{
	// Configure USB hardware indicator pin to input
	USBIND_DDR &= ~USBIND; // Input
	USBIND_PORT |= USBIND; // Turn on weak pull-up
}

// Function to determine if the BeebSCSI board has USB hardware
// (Boards 7_7 and above)
bool usbHardwareDetect(void)
{
	if ((USBIND_PIN & USBIND) != 0) return false; // Not present
	
	return true; // Present
}

// Note: This module is just a placeholder for now and does not provide
// any USB capabilities.