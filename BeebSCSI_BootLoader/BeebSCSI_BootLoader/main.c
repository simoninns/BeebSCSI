/************************************************************************
    main.c

    BeebSCSI BootLoader main functions
    BeebSCSI_BootLoader
    Copyright (C) 2017 Simon Inns

    This file is part of BeebSCSI_BootLoader.

    BeebSCSI_BootLoader is free software: you can redistribute it and/or
    modify it under the terms of the GNU General Public License as 
    published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Email: simon.inns@gmail.com

************************************************************************/

/*
This source code contains portions of the Petit FS library by ChaN:

Copyright (C) 2010, ChaN, all right reserved.

	* This software is a free software and there is NO WARRANTY.
	* No restriction on use. You can use, modify and redistribute it for
	  personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.
	* Redistributions of source code must retain the above copyright notice.
*/

#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/wdt.h>
#include <string.h>
#include "pff.h"

void init_led(void);
void init_pwr(void);
void led_on(void);
void led_off(void);
void pwr_on(void);
void pwr_off(void);
void flash_erase (DWORD);				// Erase a flash page (asmfunc.S)
void flash_write (DWORD, const BYTE*);	// Program a flash page (asmfunc.S)
void dly_100us(void);

FATFS Fatfs;				// Petit-FatFs work area
BYTE Buff[SPM_PAGESIZE];	// Page data buffer (SPM_PAGESIZE defined by avr/io.h

// Note:
//
// The boot loader will load every time the device is reset (due to the setting of the BOOTRST
// fuse (which should be set).  The bootloader will look for a file called BEEBSCSI.BIN - if not
// found, the bootloader will jump to the BeebSCSI application code.
//
// If the BeebSCSI application code is not found the bootloader will flash the status LED on for
// 2 seconds and then off for 1 second (Application not found status).
//
// If a BEEBSCSI.BIN file is found the bootloader will flash it to the AVR.  Once complete the
// bootloader will rapidly flash the status LED (Flash complete).  The SD card should be removed
// and BeebSCSI should be power-cycled.  This will boot the new firmware.

int main (void)
{
	DWORD fa;	// Flash address
	UINT br;	// Bytes read
	
	// Disable the WDT
	wdt_disable();
	
	// Disable the Clock division by 8 fuse
	CLKPR = (1 << CLKPCE);
	CLKPR = 0;

	// Initialise the status LED
	init_led();
	led_off();
	
	// Initialise the card power control
	init_pwr();
	
	// Turn the SD card power on
	pwr_on();

	// Initialise the file system
	if (pf_mount(&Fatfs) == FR_OK)
	{
		// Open firmware image file
		if (pf_open("BEEBSCSI.BIN") == FR_OK)
		{
			// Update all application pages
			for (fa = 0; fa < BOOT_ADR; fa += SPM_PAGESIZE)
			{
				memset(Buff, 0xFF, SPM_PAGESIZE);	/* Clear buffer */
				pf_read(Buff, SPM_PAGESIZE, &br);	/* Load a page data */
				
				flash_erase(fa);					/* Erase a page */
				if (br) flash_write(fa, Buff);		/* Write it if the data is exist */
			}
			
			// Flashing complete - pulse the status LED to show we are done
			while(1)
			{
				led_on();
				for (br = 0; br < 500; br++) dly_100us();
				led_off();
				for (br = 0; br < 500; br++) dly_100us();
			}
		}
	}

	// Boot the application code
	if (pgm_read_word(0) != 0xFFFF) ((void(*)(void))0)(); 

	// If no application is present - flash the status led to show error state
	while(1)
	{
		led_on();
		for (br = 0; br < 20000; br++) dly_100us();
		led_off();
		for (br = 0; br < 10000; br++) dly_100us();
	}
}

