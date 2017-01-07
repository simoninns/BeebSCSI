/************************************************************************
	statusled.c

	BeebSCSI status LED functions
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

#include <stdbool.h>
#include <stdio.h>

// Local includes
#include "uart.h"
#include "debug.h"
#include "statusled.h"

// Initialise status LED (called on a cold-start of the AVR)
void statusledInitialise(void)
{
	// Configure the status LED
	STATUS_LED_DDR |= STATUS_LED; // Output
	STATUS_LED_PORT |= STATUS_LED; // Pin = 1 (off)
}

// Reset the status LED (called when the host signals reset)
void statusledReset(void)
{
	// Turn the status LED off
	statusledOff();
}

// Turn status LED on
void statusledOn(void)
{
	STATUS_LED_PORT &= ~STATUS_LED; // Pin = 0 (on)
}

// Turn status LED off
void statusledOff(void)
{
	STATUS_LED_PORT |= STATUS_LED; // Pin = 1 (off)
}