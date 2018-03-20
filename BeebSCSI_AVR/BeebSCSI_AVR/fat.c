/************************************************************************
	fat.c

	BeebSCSI FAT access functions
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

// Global includes
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <stdbool.h>
#include <stdio.h>

// Local includes
#include "uart.h"
#include "debug.h"
#include "filesystem.h"
#include "fat.h"

// Global FAT buffer (256 bytes)
uint8_t scsiFatBuffer[256];

// Function to fill the FAT buffer with FAT file information for reading by the host
void fatInfoBuffer(uint32_t fatFileId)
{
	uint16_t byteCounter = 0;
	
	// Check that the transfer directory exists
	if (!filesystemCheckFatDirectory())
	{
		if (debugFlag_fatTransfer) debugString_P(PSTR("FAT Transfer: Could not access or create transfer directory... returning empty buffer\r\n"));
		// Something went badly wrong, fill the buffer with zeros to ensure
		// the transfer doesn't fail (or the host could hang)
		for (byteCounter = 0; byteCounter < 256; byteCounter++) scsiFatBuffer[byteCounter] = 0;
		return;
	}
	
	// Clear the FAT buffer
	for (byteCounter = 0; byteCounter < 256; byteCounter++) scsiFatBuffer[byteCounter] = 0;
	
	// Check that the required file exists
	if (!filesystemGetFatFileInfo(fatFileId, scsiFatBuffer))
	{
		// Requested file does not exist
		if (debugFlag_fatTransfer) debugString_P(PSTR("FAT Transfer: Requested FAT file does not exist\r\n"));
		for (byteCounter = 0; byteCounter < 256; byteCounter++) scsiFatBuffer[byteCounter] = 0;
		return;
	}
	
	if (debugFlag_fatTransfer) debugString_P(PSTR("FAT Transfer: Requested FAT file information placed in buffer\r\n"));
}

// Function to fill the FAT buffer ready for reading by the host
void fatReadBuffer(void)
{
	uint16_t byteCounter = 0;
	
	// Clear the FAT buffer
	for (byteCounter = 0; byteCounter < 256; byteCounter++) scsiFatBuffer[byteCounter] = 0;
	
	// Fill the FAT buffer with test data
	for (byteCounter = 0; byteCounter < 256; byteCounter++)
	{
		scsiFatBuffer[byteCounter] = 255 - (char)byteCounter;
	}
}