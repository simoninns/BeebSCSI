/************************************************************************
	main.c

	Main BeebSCSI functions
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
#include "filesystem.h"
#include "hostadapter.h"
#include "statusled.h"
#include "scsi.h"

/*
	BeebSCSI_7
	(c)2016 Simon Inns
	http://www.waitingforfriday.com

	Target PCB version: BeebSCSI 7_3
	CC Licensed Open Source Hardware
	GPL Licensed Open Source Software

	With thanks to Ian Smallshire

	Configure commands are:
	  External 1 MHz bus: *FX 147, 68, <command>
	  Internal 1 MHz bus: *FX 151, 132, <command>
	
	  0 = All debug output off
	  1 = All debug output on (except blocks)
	
	 10 = File system debug on
	 11 = File system debug off
	 12 = SCSI Commands debug on
	 13 = SCSI Commands debug off
	 14 = SCSI Blocks debug on
	 15 = SCSI Blocks debug off
	 16 = SCSI F-codes debug on
	 17 = SCSI F-codes debug off
	 18 = SCSI state debug on
	 19 = SCSI state debug off
	 20 = FAT FS debug on
	 21 = FAT FS debug off
*/

int main(void)
{
	// Initialise the UART serial transceiver
	uartInitialise();

	// Initialise the host adapter interface
	hostadapterInitialise();

	// Initialise the SD Card and FAT file system functions
	filesystemInitialise();
	
	// Initialise the status LED
	statusledInitialise();
	
	// Initialise the SCSI emulation
	scsiInitialise();
	
	// Main processing loop
    while (1) 
    {
		// Process the SCSI emulation
		scsiProcessEmulation();
		
		// Did the host reset?
		if (hostadapterReadResetFlag())
		{
			// Reset the host adapter
			hostadapterReset();
			
			// Reset the file system
			filesystemReset();
			
			// Reset the status LED
			statusledReset();
			
			// Reset the SCSI emulation
			scsiReset();
			
			// Clear the reset condition in the host adapter
			hostadapterWriteResetFlag(false);
		}
    }
}

