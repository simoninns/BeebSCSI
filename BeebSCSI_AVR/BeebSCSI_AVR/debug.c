/************************************************************************
	debug.c

	BeebSCSI serial debug functions
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

#include <avr/io.h>
#include <avr/pgmspace.h>
#include <stdbool.h>
#include <stdio.h>

#include "debug.h"
#include "uart.h"

// Define default debug output flags (all debug off)
// Note: these are modified by the configure interrupt, so they all
// need to be volatile variables
#ifdef DEBUG
	// Default debug settings for debug builds
	volatile bool debugFlag_filesystem = true;
	volatile bool debugFlag_scsiCommands = true;
	volatile bool debugFlag_scsiBlocks = false;
	volatile bool debugFlag_scsiFcodes = true;
	volatile bool debugFlag_scsiState = true;
	volatile bool debugFlag_fatfs = true;
#else
	// Default debug settings for release builds
	volatile bool debugFlag_filesystem = false;
	volatile bool debugFlag_scsiCommands = false;
	volatile bool debugFlag_scsiBlocks = false;
	volatile bool debugFlag_scsiFcodes = false;
	volatile bool debugFlag_scsiState = false;
	volatile bool debugFlag_fatfs = false;
#endif

// This function outputs a string stored in program space to the UART
// It should be called with a statement such as:
// debugString_P(PSTR("This is an example\r\n"));
//
// This prevents debug strings using valuable RAM space
void debugString_P(const char *addr)
{
	char c;
	
	while ((c = pgm_read_byte(addr++))) uartWrite(c);
}

// This function outputs a string stored in RAM space to the UART
void debugString(char *string)
{
	printf("%s", string);
}

// This function outputs a string stored in program space to the UART
// It should be called with a statement such as:
// debugStringInt16_P(PSTR("My value = "), value, newLineFlag);
//
// This prevents debug strings using valuable RAM space
// The 8 bit unsigned integer is displayed as hex
void debugStringInt8Hex_P(const char *addr, uint8_t integerValue, bool newLine)
{
	char c;
	
	// Output the debug message string
	while ((c = pgm_read_byte(addr++))) uartWrite(c);
	
	// Output the integer
	if (newLine) printf("0x%02x\r\n", integerValue);
	else printf("0x%02x", integerValue);
}

// This function outputs a string stored in program space to the UART
// It should be called with a statement such as:
// debugStringInt16_P(PSTR("My value = "), value, newLineFlag);
//
// This prevents debug strings using valuable RAM space
void debugStringInt16_P(const char *addr, uint16_t integerValue, bool newLine)
{
	char c;
	
	// Output the debug message string
	while ((c = pgm_read_byte(addr++))) uartWrite(c);
	
	// Output the integer
	if (newLine) printf("%u\r\n", integerValue);
	else printf("%u", integerValue);
}

// This function outputs a string stored in program space to the UART
// It should be called with a statement such as:
// debugStringInt32_P(PSTR("My value = "), value, newLineFlag);
//
// This prevents debug strings using valuable RAM space
void debugStringInt32_P(const char *addr, uint32_t integerValue, bool newLine)
{
	char c;
	
	// Output the debug message string
	while ((c = pgm_read_byte(addr++))) uartWrite(c);
	
	// Output the integer
	if (newLine) printf("%lu\r\n", integerValue);
	else printf("%lu", integerValue);
}

// This function outputs a hex dump of the passed buffer
void debugSectorBufferHex(uint8_t *buffer, uint16_t numberOfBytes)
{
	uint16_t i = 0;
	uint16_t index = 16;
	uint16_t width = 16; // Width of output in bytes

	for (uint16_t byteNumber = 0; byteNumber < numberOfBytes; byteNumber += 16)
	{
		for (i = 0; i < index; i++) {
			printf("%02x ", buffer[i + byteNumber]);
		}
		for (uint16_t spacer = index; spacer < width; spacer++)
		printf("	");
		
		printf(": ");
		
		for (i=0; i < index; i++) {
			if (buffer[i + byteNumber] < 32 || buffer[i + byteNumber] >126) printf(".");
			else printf("%c",buffer[i + byteNumber]);
		}
		
		printf("\r\n");
	}
	
	printf("\r\n");
}

// This function decodes the contents of the LUN descriptor and outputs it to debug
void debugLunDescriptor(uint8_t *buffer)
{
	debugString_P(PSTR("File system: LUN Descriptor contents:\r\n"));
	
	// The first 4 bytes are the Mode Select Parameter List (ACB-4000 manual figure 5-18)
	debugString_P(PSTR("File system: Mode Select Parameter List:\r\n"));
	debugStringInt16_P(PSTR("File system:   Reserved (0) = "), buffer[0], true);
	debugStringInt16_P(PSTR("File system:   Reserved (0) = "), buffer[1], true);
	debugStringInt16_P(PSTR("File system:   Reserved (0) = "), buffer[2], true);
	debugStringInt16_P(PSTR("File system:   Length of Extent Descriptor List (8) = "), buffer[3], true);
	
	// The next 8 bytes are the Extent Descriptor list (there can only be one of these
	// and it's always 8 bytes) (ACB-4000 manual figure 5-19)
	debugString_P(PSTR("File system: Extent Descriptor List:\r\n"));
	debugStringInt16_P(PSTR("File system:   Density code = "), buffer[4], true);
	debugStringInt16_P(PSTR("File system:   Reserved (0) = "), buffer[5], true);
	debugStringInt16_P(PSTR("File system:   Reserved (0) = "), buffer[6], true);
	debugStringInt16_P(PSTR("File system:   Reserved (0) = "), buffer[7], true);
	debugStringInt16_P(PSTR("File system:   Reserved (0) = "), buffer[8], true);
	debugStringInt32_P(PSTR("File system:   Block size = "), ((uint32_t)buffer[9] << 16) +
	((uint32_t)buffer[10] << 8) + (uint32_t)buffer[11], true);
	
	// The next 12 bytes are the Drive Parameter List (ACB-4000 manual figure 5-20)
	debugString_P(PSTR("File system: Drive Parameter List:\r\n"));
	debugStringInt16_P(PSTR("File system:   List format code = "), buffer[12], true);
	debugStringInt16_P(PSTR("File system:   Cylinder count = "), (buffer[13] << 8) + buffer[14], true);
	debugStringInt16_P(PSTR("File system:   Data head count = "), buffer[15], true);
	debugStringInt16_P(PSTR("File system:   Reduced write current cylinder = "), (buffer[16] << 8) + buffer[17], true);
	debugStringInt16_P(PSTR("File system:   Write pre-compensation cylinder = "), (buffer[18] << 8) + buffer[19], true);
	debugStringInt16_P(PSTR("File system:   Landing zone position = "), buffer[20], true);
	debugStringInt16_P(PSTR("File system:   Step pulse output rate code = "), buffer[21], true);

	// Note:
	//
	// The drive size (actual data storage) is calculated by the following formula:
	//
	// tracks = heads * cylinders
	// sectors = tracks * 33
	// (the '33' is because SuperForm uses a 2:1 interleave format with 33 sectors per
	// track (F-2 in the ACB-4000 manual))
	// bytes = sectors * block size (block size is always 256 bytes)
}