/************************************************************************
	filesystem.c

	BeebSCSI filing system functions
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

#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "debug.h"
#include "fatfs/ff.h"
#include "fatfs/mmc_avr.h"
#include "filesystem.h"

// File system state structure
struct filesystemStateStruct
{
	FATFS fsObject;			// FAT FS file system object
	DIR dirObject;			// FAT FS directory object
	FIL fileObject;			// FAT FS file objects

	FRESULT fsResult;		// FAT FS common result code
	UINT fsCounter;			// FAT FS byte counter
	FILINFO fsInfo;			// FAT FS file info object
	
	bool fsMountState;		// File system mount state (true = mounted, false = dismounted)
	
	uint8_t lunDirectory;	// Current LUN directory ID
	uint8_t lunNumber;	// Current LUN number
	bool fsLunStatus[8];	// LUN image availability flags for the currently selected LUN directory (true = started, false = stopped)
	uint8_t fsLunUserCode[8][5];	// LUN 5-byte User code (used for F-Code interactions - only present for laser disc images)
	
} filesystemState;

static char fileName[255];			// String for storing LFN filename
static char fatDirectory[255];		// String for storing FAT directory (for FAT transfer operations)

static uint8_t sectorBuffer[SECTOR_BUFFER_SIZE];	// Buffer for reading sectors
static bool lunOpenFlag = false; // Flag to track when a LUN is open for read/write (to prevent multiple file opens)

// Globals for multi-sector reading
static uint32_t sectorsInBuffer = 0;
static uint32_t currentBufferSector = 0;
static uint32_t sectorsRemaining = 0;

#define SZ_TBL 64 // support upto 63 fragments
uint32_t clmt[SZ_TBL];

// Service FAT FS 100Hz system timer
ISR(TIMER0_COMPA_vect)
{
	mmc_disk_timerproc();
}

static void filesystemFlush( void)
{
   // If a Lun is open close it
   if (lunOpenFlag)
   {
      //Close the open file object
      f_close(&filesystemState.fileObject);
      lunOpenFlag = false;
      if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemFlush(): Completed\r\n"));
   }
}

// Function to initialise the file system control functions (called on a cold-start of the AVR)
void filesystemInitialise(void)
{
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemInitialise(): Initialising file system\r\n"));
	filesystemState.lunDirectory = 0;		// Default to LUN directory 0
	filesystemState.fsMountState = false;	// FS default state is unmounted
	
	// Enable Timer0 running at 100Hz for the FAT FS library
	OCR0A = F_CPU / 1024 / 100 - 1;
	TCCR0A = (1 << WGM01);
	TCCR0B = 5; // 0b101
	TIMSK0 = (1 << OCIE0A);
	
	// Enable interrupts globally
	sei();
	
	// store table size at in the cluster array.
	clmt[0] = SZ_TBL;
	
	// Mount the file system
	filesystemMount();
	
	// Set the default FAT transfer directory
	sprintf(fatDirectory, "/Transfer");
}

// Reset the file system (called when the host signals reset)
void filesystemReset(void)
{
	uint8_t lunNumber;
	bool errorFlag = false;
	
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemReset(): Resetting file system\r\n"));
	
	// Reset the default FAT transfer directory
	sprintf(fatDirectory, "/Transfer");
	
	// Is the SD card/FAT file system  mounted?
	if (filesystemState.fsMountState == true)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemReset(): File system is flagged as mounted\r\n"));
		
		// Test mounted LUNs to make sure they are still available
		// Note: This is in case the SD card has been removed or changed since the last reset.
		for (lunNumber = 0; lunNumber < 8; lunNumber++)
		{
			// If the LUN status is available, test it to make sure
			if (filesystemReadLunStatus(lunNumber))
			{
				if (!filesystemTestLunStatus(lunNumber)) errorFlag = true;
			}
		}
		
		// If any of the LUN's had an invalid status we should remount to ensure everything is ok.
		if (errorFlag)
		{
			debugString_P(PSTR("File system: filesystemReset(): LUN status flags are incorrect!\r\n"));
			
			// Dismount and then mount file system to ensure it is correct
			filesystemDismount();
			filesystemMount();
		}
	}
	else
	{
		// If the file system is not currently mounted, attempt to mount it
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemReset(): File system is not mounted - attempting to mount\r\n"));
		filesystemMount();
	}
}

// File system mount and dismount functions -------------------------------------------------------------------------------------------------------------------

// Function to mount the file system
bool filesystemMount(void)
{
	filesystemFlush();
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemMount(): Mounting file system\r\n"));
	
	// Is the file system already mounted?
	if (filesystemState.fsMountState == true)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemMount(): ERROR: File system is already mounted\r\n"));
		return false;
	}
	
	// Set all LUNs to stopped
	filesystemSetLunStatus(0, false);
	filesystemSetLunStatus(1, false);
	filesystemSetLunStatus(2, false);
	filesystemSetLunStatus(3, false);
	filesystemSetLunStatus(4, false);
	filesystemSetLunStatus(5, false);
	filesystemSetLunStatus(6, false);
	filesystemSetLunStatus(7, false);
	
	// Mount the SD card
	filesystemState.fsResult = f_mount(&filesystemState.fsObject, "", 1);
	
	// Check the result
	if (filesystemState.fsResult != FR_OK)
	{
		if (debugFlag_filesystem)
		{
			switch(filesystemState.fsResult)
			{
				case FR_INVALID_DRIVE:
				debugString_P(PSTR("File system: filesystemMount(): ERROR: FR_INVALID_DRIVE\r\n"));
				break;
				
				case FR_DISK_ERR:
				debugString_P(PSTR("File system: filesystemMount(): ERROR: FR_DISK_ERR\r\n"));
				break;
				
				case FR_NOT_READY:
				debugString_P(PSTR("File system: filesystemMount(): ERROR: FR_NOT_READY - No SD Card reports not ready!\r\n"));
				break;
				
				case FR_NO_FILESYSTEM:
				debugString_P(PSTR("File system: filesystemMount(): ERROR: FR_NO_FILESYSTEM - SD Card not formatted?\r\n"));
				break;
				
				default:
				debugString_P(PSTR("File system: filesystemMount(): ERROR: Unknown error\r\n"));
			}	
		}
		
		// Exit with error status
		filesystemState.fsMountState = false;
		return false;
	}
	
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemMount(): Successful\r\n"));
	filesystemState.fsMountState = true;
	
	// Note: ADFS does not send a SCSI STARTSTOP command on reboot... it assumes that LUN 0 is already started.
	// This is theoretically incorrect... the host should not assume anything about the state of a SCSI LUN.
	// However, in order to support this buggy implementation we have to start LUN 0 here.
	filesystemSetLunStatus(0, true);
	
	return true;
}

// Function to dismount the file system
bool filesystemDismount(void)
{
	filesystemFlush();
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemDismount(): Dismounting file system\r\n"));
	
	// Is the file system mounted?
	if (filesystemState.fsMountState == false)
	{
		// Nothing to do...
		debugString_P(PSTR("File system: filesystemDismount(): No file system to dismount\r\n"));
		return false;
	}
	
	// Set all LUNs to stopped
	filesystemSetLunStatus(0, false);
	filesystemSetLunStatus(1, false);
	filesystemSetLunStatus(2, false);
	filesystemSetLunStatus(3, false);
	filesystemSetLunStatus(4, false);
	filesystemSetLunStatus(5, false);
	filesystemSetLunStatus(6, false);
	filesystemSetLunStatus(7, false);
	
	// Dismount the SD card
	filesystemState.fsResult = f_mount(&filesystemState.fsObject, "", 0);
	
	// Check the result
	if (filesystemState.fsResult != FR_OK)
	{
		if (debugFlag_filesystem)
		{
			switch(filesystemState.fsResult)
			{
				case FR_INVALID_DRIVE:
				debugString_P(PSTR("File system: filesystemDismount(): ERROR: FR_INVALID_DRIVE\r\n"));
				break;
				
				case FR_DISK_ERR:
				debugString_P(PSTR("File system: filesystemDismount(): ERROR: FR_DISK_ERR\r\n"));
				break;
				
				case FR_NOT_READY:
				debugString_P(PSTR("File system: filesystemDismount(): ERROR: FR_NOT_READY\r\n"));
				break;
				
				case FR_NO_FILESYSTEM:
				debugString_P(PSTR("File system: filesystemDismount(): ERROR: FR_NO_FILESYSTEM\r\n"));
				break;
				
				default:
				debugString_P(PSTR("File system: filesystemDismount(): ERROR: Unknown error\r\n"));
			}
		}
		
		// Exit with error status
		filesystemState.fsMountState = false;
		return false;
	}
	
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemDismount(): Successful\r\n"));
	filesystemState.fsMountState = false;
	return true;
}

// LUN status control functions -------------------------------------------------------------------------------------------------------------------------------

// Function to set the status of a LUN image
bool filesystemSetLunStatus(uint8_t lunNumber, bool lunStatus)
{
	// Is the requested status the same as the current status?
	if (filesystemState.fsLunStatus[lunNumber] == lunStatus)
	{
		if (debugFlag_filesystem)
		{
			debugStringInt16_P(PSTR("File system: filesystemSetLunStatus(): LUN number "), (uint16_t)lunNumber, false);
			if (filesystemState.fsLunStatus[lunNumber]) debugString_P(PSTR(" is started\r\n"));
			else debugString_P(PSTR(" is stopped\r\n"));
		}
		
		return true;
	}
	
	// Transitioning from stopped to started?
	if (filesystemState.fsLunStatus[lunNumber] == false && lunStatus == true)
	{
		// Is the file system mounted?
		if (filesystemState.fsMountState == false)
		{
			// Nothing to do...
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemSetLunStatus(): ERROR: No file system mounted - cannot set LUNs to started!\r\n"));
			return false;
		}
		
		// If the LUN image is starting the file system needs to recheck the LUN and LUN
		// descriptor to ensure everything is up to date
		
		// Check that the currently selected LUN directory exists (and, if not, create it)
		if (!filesystemCheckLunDirectory(filesystemState.lunDirectory))
		{
			// Failed!
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemSetLunStatus(): ERROR: Could not access LUN image directory!\r\n"));
			return false;
		}
		
		// Check that the LUN image exists
		if (!filesystemCheckLunImage(lunNumber))
		{
			// Failed!
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemSetLunStatus(): ERROR: Could not access LUN image file!\r\n"));
			return false;
		}
		
		// Exit with success
		filesystemState.fsLunStatus[lunNumber] = true;
		
		if (debugFlag_filesystem)
		{
			debugStringInt16_P(PSTR("File system: filesystemSetLunStatus(): LUN number "), (uint16_t)lunNumber, false);
			debugString_P(PSTR(" is started\r\n"));
		}
		
		return true;
	}
	
	// Transitioning from started to stopped?
	if (filesystemState.fsLunStatus[lunNumber] == true && lunStatus == false)
	{
		// If the LUN image is stopping the file system doesn't need to do anything other
		// than note the change of status
		filesystemState.fsLunStatus[lunNumber] = false;
		
		if (debugFlag_filesystem)
		{
			debugStringInt16_P(PSTR("File system: filesystemSetLunStatus(): LUN number "), (uint16_t)lunNumber, false);
			debugString_P(PSTR(" is stopped\r\n"));
		}
		
		// Exit with success
		return true;
	}
	
	return false;
}

// Function to read the status of a LUN image
bool filesystemReadLunStatus(uint8_t lunNumber)
{
	return filesystemState.fsLunStatus[lunNumber];
}

// Function to confirm that a LUN image is still available
bool filesystemTestLunStatus(uint8_t lunNumber)
{
	if (filesystemState.fsLunStatus[lunNumber] == true)
	{
		// Check that the LUN image exists
		if (!filesystemCheckLunImage(lunNumber))
		{
			// Failed!
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemTestLunStatus(): ERROR: Could not access LUN image file!\r\n"));
			return false;
		}
	}
	else
	{
		// LUN is not marked as available!
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemTestLunStatus(): LUN status is marked as stopped - cannot test\r\n"));
		return false;
	}
	
	// LUN tested OK
	return true;
}

// Function to read the user code for the specified LUN image
void filesystemReadLunUserCode(uint8_t lunNumber, uint8_t userCode[5])
{
	userCode[0] = filesystemState.fsLunUserCode[lunNumber][0];
	userCode[1] = filesystemState.fsLunUserCode[lunNumber][1];
	userCode[2] = filesystemState.fsLunUserCode[lunNumber][2];
	userCode[3] = filesystemState.fsLunUserCode[lunNumber][3];
	userCode[4] = filesystemState.fsLunUserCode[lunNumber][4];
}

// Check that the currently selected LUN directory exists (and, if not, create it)
bool filesystemCheckLunDirectory(uint8_t lunDirectory)
{
	// Is the file system mounted?
	if (filesystemState.fsMountState == false)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: No file system mounted\r\n"));
		return false;
	}
	
	// Does a directory exist for the currently selected LUN directory - if not, create it
	sprintf(fileName, "/BeebSCSI%d", lunDirectory);
	
	filesystemState.fsResult = f_opendir(&filesystemState.dirObject, fileName);
	
	// Check the result
	if (filesystemState.fsResult != FR_OK)
	{
		switch(filesystemState.fsResult)
		{
			case FR_NO_PATH:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): f_opendir returned FR_NO_PATH - Directory does not exist\r\n"));
			break;
			
			case FR_DISK_ERR:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned FR_DISK_ERR\r\n"));
			return false;
			break;
			
			case FR_INT_ERR:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned FR_INT_ERR\r\n"));
			return false;
			break;
			
			case FR_INVALID_NAME:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned FR_INVALID_NAME\r\n"));
			return false;
			break;
			
			case FR_INVALID_OBJECT:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned FR_INVALID_OBJECT\r\n"));
			return false;
			break;
			
			case FR_INVALID_DRIVE:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned FR_INVALID_DRIVE\r\n"));
			return false;
			break;
			
			case FR_NOT_ENABLED:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned FR_NOT_ENABLED\r\n"));
			return false;
			break;
			
			case FR_NO_FILESYSTEM:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned FR_NO_FILESYSTEM\r\n"));
			return false;
			break;
			
			case FR_TIMEOUT:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned FR_TIMEOUT\r\n"));
			return false;
			break;
			
			case FR_NOT_ENOUGH_CORE:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned FR_NOT_ENOUGH_CORE\r\n"));
			return false;
			break;
			
			case FR_TOO_MANY_OPEN_FILES:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned FR_TOO_MANY_OPEN_FILES\r\n"));
			return false;
			break;
			
			default:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: f_opendir returned unknown error\r\n"));
			return false;
			break;
		}
	}
	
	// Did a directory exist?
	if (filesystemState.fsResult == FR_NO_PATH)
	{
		f_closedir(&filesystemState.dirObject);
		
		// Create the LUN image directory - it's not present on the SD card
		filesystemState.fsResult = f_mkdir(fileName);
		
		// Now open the directory
		filesystemState.fsResult = f_opendir(&filesystemState.dirObject, fileName);
		
		// Check the result
		if (filesystemState.fsResult != FR_OK)
		{
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: Unable to create LUN directory\r\n"));
			f_closedir(&filesystemState.dirObject);
			return false;
		}
		
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): Created LUN directory entry\r\n"));
		f_closedir(&filesystemState.dirObject);
	}
	else
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): LUN directory found\r\n"));
		f_closedir(&filesystemState.dirObject);
	}
	
	return true;
}

// Function to scan for SCSI LUN image file on the mounted file system
// and check the image is valid.
bool filesystemCheckLunImage(uint8_t lunNumber)
{
	uint32_t lunFileSize;
	uint32_t lunDscSize;

	filesystemFlush();
	
	// Attempt to open the LUN image
	sprintf(fileName, "/BeebSCSI%d/scsi%d.dat", filesystemState.lunDirectory, lunNumber);
	if (debugFlag_filesystem) debugStringInt16_P(PSTR("File system: filesystemCheckLunImage(): Checking for (.dat) LUN image "), (uint16_t)lunNumber, 1);
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ);
		
	if (filesystemState.fsResult != FR_OK)
	{
		if (debugFlag_filesystem)
		{
			switch(filesystemState.fsResult)
			{
				case FR_DISK_ERR:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_DISK_ERR\r\n"));
				break;
					
				case FR_INT_ERR:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_INT_ERR\r\n"));
				break;
					
				case FR_NOT_READY:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_NOT_READY\r\n"));
				break;

				case FR_NO_FILE:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): LUN image not found\r\n"));
				break;
					
				case FR_NO_PATH:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_NO_PATH\r\n"));
				break;

				case FR_INVALID_NAME:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_INVALID_NAME\r\n"));
				break;

				case FR_DENIED:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_DENIED\r\n"));
				break;
					
				case FR_EXIST:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_EXIST\r\n"));
				break;
					
				case FR_INVALID_OBJECT:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_INVALID_OBJECT\r\n"));
				break;
					
				case FR_WRITE_PROTECTED:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_WRITE_PROTECTED\r\n"));
				break;
					
				case FR_INVALID_DRIVE:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_INVALID_DRIVE\r\n"));
				break;
					
				case FR_NOT_ENABLED:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_NOT_ENABLED\r\n"));
				break;
					
				case FR_NO_FILESYSTEM:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_NO_FILESYSTEM\r\n"));
				break;
					
				case FR_TIMEOUT:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_TIMEOUT\r\n"));
				break;
					
				case FR_LOCKED:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_LOCKED\r\n"));
				break;
					
				case FR_NOT_ENOUGH_CORE:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_NOT_ENOUGH_CORE\r\n"));
				break;
					
				case FR_TOO_MANY_OPEN_FILES:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned FR_TOO_MANY_OPEN_FILES\r\n"));
				break;
					
				default:
				debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: f_open on LUN image returned Funknown error\r\n"));
				break;
			}
		}
		
		// Exit with error
		f_close(&filesystemState.fileObject);
		return false;
	}

	// Opening the LUN image was successful
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): LUN image found\r\n"));
			
	// Get the size of the LUN image in bytes
	lunFileSize = (uint32_t)f_size(&filesystemState.fileObject);
	if (debugFlag_filesystem) debugStringInt32_P(PSTR("File system: filesystemCheckLunImage(): LUN size in bytes (according to .dat) = "), lunFileSize, 1);
			
	// Check that the LUN file size is actually a size which ADFS can support (the number of sectors is limited to a 21 bit number)
	// i.e. a maximum of 0x1FFFFF or 2,097,151 (* 256 bytes per sector = 512Mb = 536,870,656 bytes)
	if (lunFileSize > 536870656)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): WARNING: The LUN file size is greater than 512Mbs\r\n"));
	}
			
	// Close the LUN image file
	f_close(&filesystemState.fileObject);
			
	// Check if the LUN descriptor file (.dsc) is present
	sprintf(fileName, "/BeebSCSI%d/scsi%d.dsc", filesystemState.lunDirectory, lunNumber);
			
	if (debugFlag_filesystem) debugStringInt16_P(PSTR("File system: filesystemCheckLunImage(): Checking for (.dsc) LUN descriptor "), (uint16_t)lunNumber, 1);
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ);
			
	if (filesystemState.fsResult != FR_OK)
	{
		// LUN descriptor file is not found
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): LUN descriptor not found\r\n"));
		f_close(&filesystemState.fileObject);
				
		// Automatically create a LUN descriptor file for the LUN image
		if (filesystemCreateDscFromLunImage(filesystemState.lunDirectory, lunNumber, lunFileSize))
		{
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): Automatically created .dsc for LUN image\r\n"));
		}
		else
		{
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): ERROR: Automatically creating .dsc for LUN image failed\r\n"));
		}
	}
	else
	{
		// LUN descriptor file is present
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): LUN descriptor found\r\n"));
		f_close(&filesystemState.fileObject);
				
		// Calculate the LUN size from the descriptor file
		lunDscSize = filesystemGetLunSizeFromDsc(filesystemState.lunDirectory, lunNumber);
		if (debugFlag_filesystem) debugStringInt32_P(PSTR("File system: filesystemCheckLunImage(): LUN size in bytes (according to .dsc) = "), lunDscSize, 1);
				
		// Are the file size and DSC size consistent?
		if (lunDscSize != lunFileSize)
		{
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): WARNING: File size and DSC parameters are NOT consistent\r\n"));
		}
	}
	
	// Check if the LUN user code descriptor file (.ucd) is present
	sprintf(fileName, "/BeebSCSI%d/scsi%d.ucd", filesystemState.lunDirectory, lunNumber);
	
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): Checking for (.ucd) LUN user code descriptor\r\n"));
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ);
	
	if (filesystemState.fsResult != FR_OK)
	{
		// LUN descriptor file is not found
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): LUN user code descriptor not found\r\n"));
		f_close(&filesystemState.fileObject);
		
		// Set the user code descriptor to the default (probably not a laser disc image)
		filesystemState.fsLunUserCode[lunNumber][0] = 0x00;
		filesystemState.fsLunUserCode[lunNumber][1] = 0x00;
		filesystemState.fsLunUserCode[lunNumber][2] = 0x00;
		filesystemState.fsLunUserCode[lunNumber][3] = 0x00;
		filesystemState.fsLunUserCode[lunNumber][4] = 0x00;
	}
	else
	{
		// LUN user code descriptor file is present
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): LUN user code descriptor found\r\n"));
		
		// Close the .ucd file
		f_close(&filesystemState.fileObject);
		
		// Read the user code from the .ucd file
		filesystemGetUserCodeFromUcd(filesystemState.lunDirectory, lunNumber);
	}
	
	// Exit with success
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunImage(): Successful\r\n"));
	return true;
}

// Function to calculate the LUN image size from the LUN descriptor file parameters
uint32_t filesystemGetLunSizeFromDsc(uint8_t lunDirectory, uint8_t lunNumber)
{
	uint32_t lunSize = 0;
	uint16_t fsCounter;
	
	uint32_t blockSize;
	uint32_t cylinderCount;
	uint32_t dataHeadCount;
	
	filesystemFlush();
	
	// Assemble the DSC file name
	sprintf(fileName, "/BeebSCSI%d/scsi%d.dsc", lunDirectory, lunNumber);
		
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ);
	if (filesystemState.fsResult == FR_OK)
	{
		// Read the DSC data
		filesystemState.fsResult = f_read(&filesystemState.fileObject, sectorBuffer, 22, &fsCounter);
			
		// Check that the file was read OK and is the correct length
		if (filesystemState.fsResult != FR_OK  && fsCounter == 22)
		{
			// Something went wrong
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemGetLunSizeFromDsc(): ERROR: Could not read .dsc file\r\n"));
			f_close(&filesystemState.fileObject);
			return 0;
		}
		
		// Interpret the DSC information and calculate the LUN size
		if (debugFlag_filesystem) debugLunDescriptor(sectorBuffer);
		
		blockSize = (((uint32_t)sectorBuffer[9] << 16) + ((uint32_t)sectorBuffer[10] << 8) + (uint32_t)sectorBuffer[11]);
		cylinderCount = (((uint32_t)sectorBuffer[13] << 8) + (uint32_t)sectorBuffer[14]);
		dataHeadCount =  (uint32_t)sectorBuffer[15];

		// Note:
		//
		// The drive size (actual data storage) is calculated by the following formula:
		//
		// tracks = heads * cylinders
		// sectors = tracks * 33
		// (the '33' is because SuperForm uses a 2:1 interleave format with 33 sectors per
		// track (F-2 in the ACB-4000 manual))
		// bytes = sectors * block size (block size is always 256 bytes)
		lunSize = ((dataHeadCount * cylinderCount) * 33) * blockSize;
		f_close(&filesystemState.fileObject);
	}
	
	return lunSize;
}

// Function to automatically create a DSC file based on the file size of the LUN image
// Note, this function is specific to the BBC Micro and the ACB-4000 host adapter card
// If the DSC is inaccurate then, for the BBC Micro, it's not that important, since the 
// host only looks at its own file system data (Superform and other formatters use the DSC
// information though... so beware).
bool filesystemCreateDscFromLunImage(uint8_t lunDirectory, uint8_t lunNumber, uint32_t lunFileSize)
{
	uint32_t cylinders;
	uint32_t heads;
	uint16_t fsCounter;
	
	filesystemFlush();
	
	// Calculate the LUN file size in tracks (33 sectors per track, 256 bytes per sector)
	
	// Check that the LUN file size is actually a size which ADFS can support (the number of sectors is limited to a 21 bit number)
	// i.e. a maximum of 0x1FFFFF or 2,097,151 (* 256 bytes per sector = 512Mb = 536,870,656 bytes)
	if (lunFileSize > 536870656)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): WARNING: The LUN file size is greater than 512Mbs\r\n"));
	}
	
	// Check that the LUN file size is actually a size which the ACB-4000 card could have supported (given that the 
	// block and track sizes were fixed to 256 and 33 respectively)
	if (lunFileSize % (256 * 33) != 0)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): WARNING: The LUN file size could not be supported by an ACB-4000 card\r\n"));
	}
	lunFileSize = lunFileSize / (33 * 256);
	
	// The lunFileSize (in tracks) should be evenly divisible by the head count and the head count should be
	// 16 or less.
	heads = 16;
	while ((lunFileSize % heads != 0) && heads != 1) heads--;
	cylinders = lunFileSize / heads;
	
	if (debugFlag_filesystem) {
		debugStringInt32_P(PSTR("File system: filesystemCreateDscFromLunImage(): LUN size in tracks (33 * 256 bytes) = "), lunFileSize, true);
		debugStringInt32_P(PSTR("File system: filesystemCreateDscFromLunImage(): Number of heads = "), heads, true);
		debugStringInt32_P(PSTR("File system: filesystemCreateDscFromLunImage(): Number of cylinders = "), cylinders, true);
	}
	
	// The first 4 bytes are the Mode Select Parameter List (ACB-4000 manual figure 5-18)
	sectorBuffer[ 0] = 0;		// Reserved (0)
	sectorBuffer[ 1] = 0;		// Reserved (0)
	sectorBuffer[ 2] = 0;		// Reserved (0)
	sectorBuffer[ 3] = 8;		// Length of Extent Descriptor List (8)
	
	// The next 8 bytes are the Extent Descriptor list (there can only be one of these
	// and it's always 8 bytes) (ACB-4000 manual figure 5-19)
	sectorBuffer[ 4] = 0;		// Density code
	sectorBuffer[ 5] = 0;		// Reserved (0)
	sectorBuffer[ 6] = 0;		// Reserved (0)
	sectorBuffer[ 7] = 0;		// Reserved (0)
	sectorBuffer[ 8] = 0;		// Reserved (0)
	sectorBuffer[ 9] = 0;		// Block size MSB
	sectorBuffer[10] = 1;		// Block size
	sectorBuffer[11] = 0;		// Block size LSB = 256

	// The next 12 bytes are the Drive Parameter List (ACB-4000 manual figure 5-20)
	sectorBuffer[12] = 1;		// List format code
	sectorBuffer[13] = (uint8_t)((cylinders & 0x0000FF00) >> 8); // Cylinder count MSB
	sectorBuffer[14] = (uint8_t)( cylinders & 0x000000FF); // Cylinder count LSB
	sectorBuffer[15] = (uint8_t)(heads & 0x000000FF); // Data head count 
	sectorBuffer[16] = 0;		// Reduced write current cylinder MSB
	sectorBuffer[17] = 128;		// Reduced write current cylinder LSB = 128
	sectorBuffer[18] = 0;		// Write pre-compensation cylinder MSB
	sectorBuffer[19] = 128;		// Write pre-compensation cylinder LSB = 128
	sectorBuffer[20] = 0;		// Landing zone position
	sectorBuffer[21] = 1;		// Step pulse output rate code
	
	// Assemble the DSC file name
	sprintf(fileName, "/BeebSCSI%d/scsi%d.dsc", lunDirectory, lunNumber);
	
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_CREATE_NEW | FA_WRITE);
	if (filesystemState.fsResult == FR_OK)
	{
		// Write the DSC data
		filesystemState.fsResult = f_write(&filesystemState.fileObject, sectorBuffer, 22, &fsCounter);
		
		// Check that the file was written OK and is the correct length
		if (filesystemState.fsResult != FR_OK  && fsCounter == 22)
		{
			// Something went wrong
			if (debugFlag_filesystem)
			{
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: .dsc create failed\r\n"));
			
				switch(filesystemState.fsResult)
				{
					case FR_DISK_ERR:
					debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_write on LUN .dsc returned FR_DISK_ERR\r\n"));
					break;
					
					case FR_INT_ERR:
					debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_write on LUN .dsc returned FR_INT_ERR\r\n"));
					break;
					
					case FR_DENIED:
					debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_write on LUN .dsc returned FR_DENIED\r\n"));
					break;
										
					case FR_INVALID_OBJECT:
					debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_write on LUN .dsc returned FR_INVALID_OBJECT\r\n"));
					break;
					
					case FR_TIMEOUT:
					debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_write on LUN .dsc returned FR_TIMEOUT\r\n"));
					break;
					
					default:
					debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_write on LUN .dsc returned unknown error\r\n"));
					break;
				}
			}
			
			f_close(&filesystemState.fileObject);
			return false;
		}
	}
	else
	{
		// Something went wrong
		if (debugFlag_filesystem)
		{
			switch(filesystemState.fsResult)
			{
				case FR_DISK_ERR:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_DISK_ERR\r\n"));
				break;
				
				case FR_INT_ERR:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_INT_ERR\r\n"));
				break;
				
				case FR_NOT_READY:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_NOT_READY\r\n"));
				break;

				case FR_NO_FILE:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_NO_FILE\\r\n"));
				break;
				
				case FR_NO_PATH:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_NO_PATH\r\n"));
				break;

				case FR_INVALID_NAME:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_INVALID_NAME\r\n"));
				break;

				case FR_DENIED:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_DENIED\r\n"));
				break;
				
				case FR_EXIST:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_EXIST\r\n"));
				break;
				
				case FR_INVALID_OBJECT:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_INVALID_OBJECT\r\n"));
				break;
				
				case FR_WRITE_PROTECTED:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_WRITE_PROTECTED\r\n"));
				break;
				
				case FR_INVALID_DRIVE:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_INVALID_DRIVE\r\n"));
				break;
				
				case FR_NOT_ENABLED:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_NOT_ENABLED\r\n"));
				break;
				
				case FR_NO_FILESYSTEM:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_NO_FILESYSTEM\r\n"));
				break;
				
				case FR_TIMEOUT:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_TIMEOUT\r\n"));
				break;
				
				case FR_LOCKED:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_LOCKED\r\n"));
				break;
				
				case FR_NOT_ENOUGH_CORE:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_NOT_ENOUGH_CORE\r\n"));
				break;
				
				case FR_TOO_MANY_OPEN_FILES:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned FR_TOO_MANY_OPEN_FILES\r\n"));
				break;
				
				default:
				debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): ERROR: f_open on LUN .dsc returned unknown error\r\n"));
				break;
			}
		}
		
		f_close(&filesystemState.fileObject);
		return false;
	}
	
	// Descriptor write OK
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCreateDscFromLunImage(): .dsc file created\r\n"));
	f_close(&filesystemState.fileObject);
	
	return true;
}

// Function to read the user code data from the LUN user code descriptor file (.ucd)
void filesystemGetUserCodeFromUcd(uint8_t lunDirectoryNumber, uint8_t lunNumber)
{
	uint16_t fsCounter;
	
	filesystemFlush();
	// Assemble the UCD file name
	sprintf(fileName, "/BeebSCSI%d/scsi%d.ucd", lunDirectoryNumber, lunNumber);
	
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ);
	if (filesystemState.fsResult == FR_OK)
	{
		// Read the DSC data
		filesystemState.fsResult = f_read(&filesystemState.fileObject, filesystemState.fsLunUserCode[lunNumber], 5, &fsCounter);
		
		// Check that the file was read OK and is the correct length
		if (filesystemState.fsResult != FR_OK  && fsCounter == 5)
		{
			// Something went wrong
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemGetUserCodeFromUcd(): ERROR: Could not read .ucd file\r\n"));
			f_close(&filesystemState.fileObject);
			return;
		}

	if (debugFlag_filesystem)
	{
		debugStringInt16_P(PSTR("File system: filesystemGetUserCodeFromUcd(): User code bytes (from .ucd): "), (uint16_t)filesystemState.fsLunUserCode[lunNumber][0], false);
		debugStringInt16_P(PSTR(", "), (uint16_t)filesystemState.fsLunUserCode[lunNumber][1], false);
		debugStringInt16_P(PSTR(", "), (uint16_t)filesystemState.fsLunUserCode[lunNumber][2], false);
		debugStringInt16_P(PSTR(", "), (uint16_t)filesystemState.fsLunUserCode[lunNumber][3], false);
		debugStringInt16_P(PSTR(", "), (uint16_t)filesystemState.fsLunUserCode[lunNumber][4], true);
	}

		f_close(&filesystemState.fileObject);
	}
}

// Function to set the current LUN directory (for the LUN jukeboxing functionality)
void filesystemSetLunDirectory(uint8_t lunDirectoryNumber)
{
	// Change the current LUN directory number
	filesystemState.lunDirectory = lunDirectoryNumber;
	
	// Set all LUNs to stopped
	filesystemSetLunStatus(0, false);
	filesystemSetLunStatus(1, false);
	filesystemSetLunStatus(2, false);
	filesystemSetLunStatus(3, false);
	filesystemSetLunStatus(4, false);
	filesystemSetLunStatus(5, false);
	filesystemSetLunStatus(6, false);
	filesystemSetLunStatus(7, false);
}

// Function to read the current LUN directory (for the LUN jukeboxing functionality)
uint8_t filesystemGetLunDirectory(void)
{
	return filesystemState.lunDirectory;
}

// Functions for creating LUNs and LUN descriptors ------------------------------------------------------------------------------------------------------------

// Function to create a new LUN image (makes an empty .dat file)
bool filesystemCreateLunImage(uint8_t lunNumber)
{
	filesystemFlush();
	
	// Assemble the .dat file name
	sprintf(fileName, "/BeebSCSI%d/scsi%d.dat", filesystemState.lunDirectory, lunNumber);
	
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ);
	if (filesystemState.fsResult == FR_OK)
	{
		// File opened ok - which means it already exists...
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCreateLunImage(): .dat already exists - ignoring request to create a new .dat\r\n"));
		f_close(&filesystemState.fileObject);
		return true;
	}
	
	// Create a new .dat file
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_CREATE_NEW);
	if (filesystemState.fsResult != FR_OK)
	{
		// Create .dat file failed
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCreateLunImage(): ERROR: Could not create new .dat file!\r\n"));
		f_close(&filesystemState.fileObject);
		return false;
	}
	
	// LUN .dat file created successfully
	f_close(&filesystemState.fileObject);
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCreateLunImage(): Successful\r\n"));
	return true;
}

// Function to create a new LUN descriptor (makes an empty .dsc file)
bool filesystemCreateLunDescriptor(uint8_t lunNumber)
{
	filesystemFlush();
	
	// Assemble the .dsc file name
	sprintf(fileName, "/BeebSCSI%d/scsi%d.dsc", filesystemState.lunDirectory, lunNumber);
	
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ);
	if (filesystemState.fsResult == FR_OK)
	{
		// File opened ok - which means it already exists...
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCreateLunDescriptor(): .dsc already exists - ignoring request to create a new .dsc\r\n"));
		f_close(&filesystemState.fileObject);
		return true;
	}
	
	// Create a new .dsc file
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_CREATE_NEW);
	if (filesystemState.fsResult != FR_OK)
	{
		// Create .dsc file failed
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCreateLunDescriptor(): ERROR: Could not create new .dsc file!\r\n"));
		f_close(&filesystemState.fileObject);
		return false;
	}
	
	// LUN DSC file created successfully
	f_close(&filesystemState.fileObject);
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCreateLunDescriptor(): Successful\r\n"));
	return true;
}

// Function to read a LUN descriptor
bool filesystemReadLunDescriptor(uint8_t lunNumber, uint8_t buffer[])
{
	filesystemFlush();
	
	// Assemble the .dsc file name
	sprintf(fileName, "/BeebSCSI%d/scsi%d.dsc", filesystemState.lunDirectory, lunNumber);
	
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ);
	if (filesystemState.fsResult == FR_OK)
	{
		// Read the .dsc data
		filesystemState.fsResult = f_read(&filesystemState.fileObject, buffer, 22, &filesystemState.fsCounter);
		
		// Check that the file was read OK and is the correct length
		if (filesystemState.fsResult != FR_OK  && filesystemState.fsCounter == 22)
		{
			// Something went wrong
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemReadLunDescriptor(): ERROR: Could not read .dsc file for LUN\r\n"));
			f_close(&filesystemState.fileObject);
			return false;
		}
	}
	else
	{
		// Looks like the .dsc file is not present on the file system
		debugStringInt16_P(PSTR("File system: filesystemReadLunDescriptor(): ERROR: Could not open .dsc file for LUN "), lunNumber, true);
		f_close(&filesystemState.fileObject);
		return false;
	}
	
	// Descriptor read OK
	f_close(&filesystemState.fileObject);
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemReadLunDescriptor(): Successful\r\n"));
	return true;
}

// Function to write a LUN descriptor
bool filesystemWriteLunDescriptor(uint8_t lunNumber, uint8_t buffer[])
{
	filesystemFlush();
	
	// Assemble the .dsc file name
	sprintf(fileName, "/BeebSCSI%d/scsi%d.dsc", filesystemState.lunDirectory, lunNumber);
	
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ | FA_WRITE);
	if (filesystemState.fsResult == FR_OK)
	{
		// Write the .dsc data
		filesystemState.fsResult = f_write(&filesystemState.fileObject, buffer, 22, &filesystemState.fsCounter);
		
		// Check that the file was written OK and is the correct length
		if (filesystemState.fsResult != FR_OK  && filesystemState.fsCounter == 22)
		{
			// Something went wrong
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemWriteLunDescriptor(): ERROR: Could not write .dsc file for LUN\r\n"));
			f_close(&filesystemState.fileObject);
			return false;
		}
	}
	else
	{
		// Looks like the .dsc file is not present on the file system
		debugStringInt16_P(PSTR("File system: filesystemWriteLunDescriptor(): ERROR: Could not open .dsc file for LUN "), lunNumber, true);
		f_close(&filesystemState.fileObject);
		return false;
	}
	
	// Descriptor write OK
	f_close(&filesystemState.fileObject);
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemWriteLunDescriptor(): Successful\r\n"));
	return true;
}

// Function to format a LUN image
bool filesystemFormatLun(uint8_t lunNumber, uint8_t dataPattern)
{
	uint32_t requiredNumberOfSectors = 0;
	
	filesystemFlush();
	
	if (debugFlag_filesystem) debugStringInt16_P(PSTR("File system: filesystemFormatLun(): Formatting LUN image "), lunNumber, true);
	
	// Read the LUN descriptor for the LUN image into the sector buffer
	if (!filesystemReadLunDescriptor(lunNumber, sectorBuffer))
	{
		// Unable to read the LUN descriptor
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemFormatLun(): ERROR: Could not read .dsc file for LUN\r\n"));
		return false;
	}
	
	// Calculate the number of 256 byte sectors required to fulfill the drive geometry
	// tracks = heads * cylinders
	// sectors = tracks * 33
	requiredNumberOfSectors = ((uint32_t)sectorBuffer[15] * (((uint32_t)sectorBuffer[13] << 8) + (uint32_t)sectorBuffer[14])) * 33;
	if (debugFlag_filesystem) debugStringInt32_P(PSTR("File system: filesystemFormatLun(): Sectors required = "), requiredNumberOfSectors, true);
	
	// Assemble the .dat file name
	sprintf(fileName, "/BeebSCSI%d/scsi%d.dat", filesystemState.lunDirectory, lunNumber);
	
	// Note: We are using the expand FAT method to create the LUN image... the dataPattern byte
	// will be ignored.
	// Fill the sector buffer with the required data pattern
	// for (counter = 0; counter < 256; counter++) sectorBuffer[counter] = dataPattern;
	
	// Create the .dat file (the old .dat file, if present, will be unlinked (i.e. gone forever))
	filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ | FA_WRITE | FA_CREATE_ALWAYS);
	if (filesystemState.fsResult == FR_OK)
	{
		// Write the required number of sectors to the DAT file
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemFormatLun(): Performing format...\r\n"));
		
		// If we try to write 512MBs of data to the SD card in 256 byte chunks
		// via SPI it will take a very long time to complete...
		//
		// So instead we use the FAT FS expand command to allocate a file of the required
		// LUN size
		//
		// Note: This allocates a contiguous area for the file which can help to
		// speed up read/write times.  If you would prefer the file to be small
		// and grow as used, just remove the f_expand and the fsResult check.  Every
		// thing will work fine without them.
		//
		// This ignores the data pattern (since the file is only allocated - not
		// actually written).
		filesystemState.fsResult = f_expand(&filesystemState.fileObject, (FSIZE_t)(requiredNumberOfSectors * 256), 1);
		
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemFormatLun(): Format complete\r\n"));
		
		// Check that the file was written OK
		if (filesystemState.fsResult != FR_OK)
		{
			// Something went wrong writing to the .dat
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemFormatLun(): ERROR: Could not write .dat\r\n"));
			f_close(&filesystemState.fileObject);
			return false;
		}
	}
	else
	{
		// Something went wrong opening the .dat
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemFormatLun(): ERROR: Could not open .dat\r\n"));
		f_close(&filesystemState.fileObject);
		return false;
	}
	
	// Formatting successful
	f_close(&filesystemState.fileObject);
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemFormatLun(): Successful\r\n"));
	return true;
}

// Functions for reading and writing LUN images ---------------------------------------------------------------------------------------------------------------

// Function to open a LUN ready for reading
// Note: The read functions use a multi-sector buffer to lower the number of required
// reads from the physical media.  This is to allow more efficient (larger) reads of data.
bool filesystemOpenLunForRead(uint8_t lunNumber, uint32_t startSector, uint32_t requiredNumberOfSectors)
{
	uint32_t sectorsToRead = 0;
	
	if (lunOpenFlag) 
   	{
      		// check that it is the same LUN
      		if (filesystemState.lunNumber != lunNumber)
         	filesystemFlush();
   	}

   	if (!lunOpenFlag )
	{
		// Assemble the .dat file name
		sprintf(fileName, "/BeebSCSI%d/scsi%d.dat", filesystemState.lunDirectory, lunNumber);

		// Open the DAT file
		filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName, FA_READ | FA_WRITE);
		if (filesystemState.fsResult == FR_OK)
		{
#if FF_USE_FASTSEEK
     			((FIL*)(&filesystemState.fileObject))->cltbl = clmt;
         		filesystemState.fsResult  = f_lseek(&filesystemState.fileObject, CREATE_LINKMAP);
#endif
			// Move to the correct point in the DAT file
			// This is * 256 as each block is 256 bytes
			filesystemState.fsResult = f_lseek(&filesystemState.fileObject, startSector * 256);
			filesystemState.lunNumber = lunNumber;
			// Check that the file seek was OK
			if (filesystemState.fsResult != FR_OK)
			{
				// Something went wrong with seeking, do not retry
				if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemOpenLunForRead(): ERROR: Unable to seek to required sector in LUN image file!\r\n"));
				f_close(&filesystemState.fileObject);
				return false;
			}
		}
	} else
	      filesystemState.fsResult = f_lseek(&filesystemState.fileObject, startSector * 256);

	
	// Fill the file system sector buffer
	sectorsToRead = requiredNumberOfSectors;
	if (sectorsToRead > SECTOR_BUFFER_LENGTH) sectorsToRead = SECTOR_BUFFER_LENGTH;
	
	sectorsInBuffer = sectorsToRead;
	currentBufferSector = 0;
	sectorsRemaining = requiredNumberOfSectors - sectorsInBuffer;
	
	// Read the required data into the sector buffer
	filesystemState.fsResult = f_read(&filesystemState.fileObject, sectorBuffer, sectorsToRead * 256, &filesystemState.fsCounter);
	
	// Check that the file was read OK
	if (filesystemState.fsResult != FR_OK)
	{
		// Something went wrong
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemReadNextSector(): ERROR: Cannot read from LUN image!\r\n"));
		f_close(&filesystemState.fileObject);
		return false;
	}

	// Exit with success
	lunOpenFlag = true;
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemOpenLunForRead(): Successful\r\n"));
	return true;
}

// Function to read next sector from a LUN
bool filesystemReadNextSector(uint8_t buffer[])
{
	//uint16_t byteCounter;
	uint32_t sectorsToRead = 0;
	
	// Ensure there is a LUN image open
	if (!lunOpenFlag)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemReadNextSector(): ERROR: No LUN image open!\r\n"));
		return false;
	}
	
	// Is the required sector already in the sector buffer?
	if (currentBufferSector < sectorsInBuffer)
	{
		// Fill the function buffer from the sector buffer
		memcpy(buffer, sectorBuffer + (currentBufferSector * 256), 256);
		
		// Move to the next sector
		currentBufferSector++;
	}
	
	// Refill the sector buffer?
	if (currentBufferSector == sectorsInBuffer)
	{
		// Ensure we have sectors remaining to be read
		if (sectorsRemaining != 0)
		{
			sectorsToRead = sectorsRemaining;
			if (sectorsRemaining > SECTOR_BUFFER_LENGTH) sectorsToRead = SECTOR_BUFFER_LENGTH;
			
			sectorsInBuffer = sectorsToRead;
			currentBufferSector = 0;
			sectorsRemaining = sectorsRemaining - sectorsInBuffer;
			
			// Read the required data into the sector buffer
			filesystemState.fsResult = f_read(&filesystemState.fileObject, sectorBuffer, sectorsToRead * 256, &filesystemState.fsCounter);
			
			// Check that the file was read OK
			if (filesystemState.fsResult != FR_OK)
			{
				// Something went wrong
				if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemReadNextSector(): ERROR: Cannot read from LUN image!\r\n"));
				f_close(&filesystemState.fileObject);
				return false;
			}
		}
	}
	
	// Exit with success
	return true;
}

// Function to close a LUN for reading
bool filesystemCloseLunForRead(void)
{
	// Ensure there is a LUN image open
	if (!lunOpenFlag)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCloseLunForRead(): ERROR: No LUN image open!\r\n"));
	}
	return false;
}

// Function to open a LUN ready for writing
bool filesystemOpenLunForWrite(uint8_t lunNumber, uint32_t startSector, uint32_t requiredNumberOfSectors)
{
	// Ensure there isn't already a LUN image open
	if (lunOpenFlag)
	{
		// check that it is the same LUN Number 
      		if (filesystemState.lunNumber != lunNumber)
         		filesystemFlush();
	}
	
	if (!lunOpenFlag )
   	{
		// Assemble the .dat file name
		sprintf(fileName, "/BeebSCSI%d/scsi%d.dat", filesystemState.lunDirectory, lunNumber);

		// Open the DAT file
		filesystemState.fsResult = f_open(&filesystemState.fileObject, fileName,  FA_READ | FA_WRITE);
		if (filesystemState.fsResult == FR_OK)
		{
#if FF_USE_FASTSEEK
         		((FIL*)(&filesystemState.fileObject))->cltbl = clmt;
         		filesystemState.fsResult  = f_lseek(&filesystemState.fileObject, CREATE_LINKMAP);
#endif
			// Move to the correct point in the DAT file
			// This is * 256 as each block is 256 bytes
			filesystemState.fsResult = f_lseek(&filesystemState.fileObject, startSector * 256);
			filesystemState.lunNumber = lunNumber;
			// Check that the file seek was OK
			if (filesystemState.fsResult != FR_OK)
			{
				// Something went wrong with seeking, do not retry
				if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemOpenLunForWrite(): ERROR: Unable to seek to required sector in LUN image file!\r\n"));
				f_close(&filesystemState.fileObject);
				return false;
			}
		}
	} else
      		filesystemState.fsResult = f_lseek(&filesystemState.fileObject, startSector * 256);
 

	// Exit with success
	lunOpenFlag = true;
	if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemOpenLunForWrite(): Successful\r\n"));
	return true;
}

// Function to write next sector to a LUN
bool filesystemWriteNextSector(uint8_t buffer[])
{
	// Ensure there is a LUN image open
	if (!lunOpenFlag)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemWriteNextSector(): ERROR: No LUN image open!\r\n"));
		return false;
	}
	
	// Write the required data
	filesystemState.fsResult = f_write(&filesystemState.fileObject, buffer, 256, &filesystemState.fsCounter);
	
	// Check that the file was written OK
	if (filesystemState.fsResult != FR_OK)
	{
		// Something went wrong
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemWriteNextSector(): ERROR: Cannot write to LUN image!\r\n"));
		f_close(&filesystemState.fileObject);
		return false;
	}
	
	// Exit with success
	return true;
}

// Function to close a LUN for writing
bool filesystemCloseLunForWrite(void)
{
	// Ensure there is a LUN image open
	if (!lunOpenFlag)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCloseLunForWrite(): ERROR: No LUN image open!\r\n"));
	}
	return false;
}


// Functions for FAT Transfer support --------------

// Change the filesystem's FAT transfer directory
bool filesystemSetFatDirectory(uint8_t *buffer)
{
	sprintf(fatDirectory, "%s", buffer);
	if (debugFlag_filesystem) 
	{
		debugString_P(PSTR("File system: filesystemSetFatDirectory(): FAT transfer directory changed to: "));
		debugString(fatDirectory);
		debugString_P(PSTR("\r\n"));
	}
	return true;
}


// Read an entry from the FAT directory and place the information about the entry into the buffer
//
// The buffer format is as follows:
// Byte 0: Status of file (0 = does not exist, 1 = file exists, 2 = directory)
// Byte 1 - 4: Size of file in number of bytes (32-bit)
// Byte 5 - 126: Reserved (0)
// Byte 127- 255: File name string terminated with 0x00 (NULL)
//
bool filesystemGetFatFileInfo(uint32_t fileNumber, uint8_t *buffer)
{
	uint16_t byteCounter;
	uint32_t fileEntryNumber;
	
	filesystemFlush();
	
	// Is the file system mounted?
	if (filesystemState.fsMountState == false)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemGetFatFileInfo(): ERROR: No file system mounted\r\n"));
		return false;
	}
	
	// Clear the buffer
	for (byteCounter = 0; byteCounter < 256; byteCounter++) buffer[byteCounter] = 0;
	
	// Open the FAT transfer directory
	filesystemState.fsResult = f_opendir(&filesystemState.dirObject, fatDirectory);
	
	// Check the result
	if (filesystemState.fsResult != FR_OK)
	{
		switch(filesystemState.fsResult)
		{
			case FR_NO_PATH:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): f_opendir returned FR_NO_PATH - Directory does not exist\r\n"));
			break;
			
			case FR_DISK_ERR:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned FR_DISK_ERR\r\n"));
			return false;
			break;
			
			case FR_INT_ERR:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned FR_INT_ERR\r\n"));
			return false;
			break;
			
			case FR_INVALID_NAME:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned FR_INVALID_NAME\r\n"));
			return false;
			break;
			
			case FR_INVALID_OBJECT:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned FR_INVALID_OBJECT\r\n"));
			return false;
			break;
			
			case FR_INVALID_DRIVE:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned FR_INVALID_DRIVE\r\n"));
			return false;
			break;
			
			case FR_NOT_ENABLED:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned FR_NOT_ENABLED\r\n"));
			return false;
			break;
			
			case FR_NO_FILESYSTEM:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned FR_NO_FILESYSTEM\r\n"));
			return false;
			break;
			
			case FR_TIMEOUT:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned FR_TIMEOUT\r\n"));
			return false;
			break;
			
			case FR_NOT_ENOUGH_CORE:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned FR_NOT_ENOUGH_CORE\r\n"));
			return false;
			break;
			
			case FR_TOO_MANY_OPEN_FILES:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned FR_TOO_MANY_OPEN_FILES\r\n"));
			return false;
			break;
			
			default:
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): ERROR: f_opendir returned unknown error\r\n"));
			return false;
			break;
		}
	}
	
	// Did a directory exist?
	if (filesystemState.fsResult == FR_NO_PATH)
	{
		f_closedir(&filesystemState.dirObject);
		
		// Create the FAT transfer directory - it's not present on the SD card
		filesystemState.fsResult = f_mkdir(fatDirectory);
		
		// Now open the directory
		filesystemState.fsResult = f_opendir(&filesystemState.dirObject, fatDirectory);
		
		// Check the result
		if (filesystemState.fsResult != FR_OK)
		{
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckLunDirectory(): ERROR: Unable to create FAT transfer directory\r\n"));
			f_closedir(&filesystemState.dirObject);
			return false;
		}
		
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): Created FAT transfer directory entry\r\n"));
	}
	else
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemCheckFatDirectory(): FAT transfer directory found\r\n"));
	}
	
	// Get the requested file entry number object	
	for (fileEntryNumber = 0; fileEntryNumber <= fileNumber; fileEntryNumber++)
	{
		filesystemState.fsResult = f_readdir(&filesystemState.dirObject, &filesystemState.fsInfo);
			
		// Exit on error or end of directory object entries
		if (filesystemState.fsResult != FR_OK || filesystemState.fsInfo.fname[0] == 0)
		{
			// The requested directory entry does not exist
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemGetFatFileInfo(): Requested directory entry does not exist\r\n"));
			buffer[0] = 0; // file does not exist
			f_closedir(&filesystemState.dirObject);
			return true; // This is a valid (successful) return condition
		}
	}
	if (debugFlag_filesystem) debugStringInt32_P(PSTR("File system: filesystemGetFatFileInfo(): Requested directory entry found for entry number "), fileNumber, true);
		
	// Is the entry a file or sub-directory?
	if (filesystemState.fsInfo.fattrib & AM_DIR)
	{
		// Directory
		buffer[0] = 2; // directory entry is a directory
		if (debugFlag_filesystem)
		{
			debugString_P(PSTR("File system: filesystemGetFatFileInfo(): Directory entry is a directory called "));
			debugString(filesystemState.fsInfo.fname);
		 	debugString_P(PSTR("\r\n"));
		}
			
		// Directories always have a file size of 0
		buffer[1] = 0;
		buffer[2] = 0;
		buffer[3] = 0;
		buffer[4] = 0;
			
		// Store the file name of the directory entry in the buffer (limited to 126 characters and NULL (0x00) terminated)
		if (strlen(filesystemState.fsInfo.fname) > 125) filesystemState.fsInfo.fname[126] = '\0';
			
		// Copy the string into the buffer - starting from byte 127
		strcpy((char*)buffer+127, filesystemState.fsInfo.fname);
	}
	else
	{
		// File
		buffer[0] = 1; // directory entry is a file
		if (debugFlag_filesystem)
		{
			debugString_P(PSTR("File system: filesystemGetFatFileInfo(): Directory entry is a file called "));
			debugString(filesystemState.fsInfo.fname);
			debugString_P(PSTR("\r\n"));
		}
			
		// Get the directory entry's file size in bytes (64-bit as we have exFAT configured)
		uint64_t fileSize = (uint64_t)filesystemState.fsInfo.fsize;
			
		// The maximum supported file size in ADFS is 512Mbytes (524,288 Kbytes or 536,870,912)
		// If the file size is bigger than this, the file must be truncated.
		if (fileSize > 536870912)
		{
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemGetFatFileInfo(): Directory entry is > 536870912 bytes... it will be truncated.\r\n"));
			fileSize = 536870912; // Perhaps this limit should be ~500Mbytes, as file-system overhead will prevent 512Mb files being stored? Should be stress-tested...
		}
		else
		{
			if (debugFlag_filesystem) debugStringInt32_P(PSTR("File system: filesystemGetFatFileInfo(): Directory entry file size (in bytes) is "), (uint32_t)fileSize, true);
		}
			
		// Convert the file size into a 32 bit number and place it in 4 bytes of the buffer (1-4)
		buffer[1] = (fileSize & 0xFF000000UL) >> 24;
		buffer[2] = (fileSize & 0x00FF0000UL) >> 16;
		buffer[3] = (fileSize & 0x0000FF00UL) >>  8;
		buffer[4] = (fileSize & 0x000000FFUL);
			
		// Store the file name of the directory entry in the buffer (limited to 126 characters and NULL (0x00) terminated)
			
		// Truncate the string to 127 bytes
		if (strlen(filesystemState.fsInfo.fname) > 125) filesystemState.fsInfo.fname[126] = '\0';
			
		// Copy the string into the buffer - starting from byte 127
		strcpy((char*)buffer+127, filesystemState.fsInfo.fname);
	}

	// Close the directory object
	f_closedir(&filesystemState.dirObject);
		
	return true;
}

// Open a FAT file ready for reading
bool filesystemOpenFatForRead(uint32_t fileNumber, uint32_t blockNumber)
{
	char tempfileName[512];
	
	filesystemFlush();
	
	// Is the file system mounted?
	if (filesystemState.fsMountState == false)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: No file system mounted\r\n"));
		return false;
	}
	
	// Open the FAT transfer directory
	filesystemState.fsResult = f_opendir(&filesystemState.dirObject, fatDirectory);
	
	// Check the open directory action's result
	if (filesystemState.fsResult == FR_OK)
	{
		uint32_t fileEntryNumber;
		
		for (fileEntryNumber = 0; fileEntryNumber <= fileNumber; fileEntryNumber++)
		{
			filesystemState.fsResult = f_readdir(&filesystemState.dirObject, &filesystemState.fsInfo);
			
			// Exit on error or end of directory object entries
			if (filesystemState.fsResult != FR_OK || filesystemState.fsInfo.fname[0] == 0)
			{
				// The requested directory entry does not exist
				if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemOpenFatForRead(): Requested directory entry does not exist\r\n"));
				f_closedir(&filesystemState.dirObject);
				return false;
			}
		}
		
		// Is the entry a file or sub-directory?
		if (filesystemState.fsInfo.fattrib & AM_DIR)
		{
			// Directory
			if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemOpenFatForRead(): Requested directory entry was a directory - can not read!\r\n"));
			f_closedir(&filesystemState.dirObject);
			return false;
		}
		else
		{
			// Assemble the full path name and file name for the requested file
			sprintf(tempfileName, "%s/%s", fatDirectory, filesystemState.fsInfo.fname);
			f_closedir(&filesystemState.dirObject);

			// Open the requested file for reading
			filesystemState.fsResult = f_open(&filesystemState.fileObject, tempfileName, FA_READ);
			if (filesystemState.fsResult != FR_OK)
			{
				if (debugFlag_filesystem)
				{
					switch(filesystemState.fsResult)
					{
						case FR_DISK_ERR:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_DISK_ERR\r\n"));
						break;
						
						case FR_INT_ERR:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_INT_ERR\r\n"));
						break;
						
						case FR_NOT_READY:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_NOT_READY\r\n"));
						break;

						case FR_NO_FILE:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): FAT file not found\r\n"));
						break;
						
						case FR_NO_PATH:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_NO_PATH\r\n"));
						break;

						case FR_INVALID_NAME:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_INVALID_NAME\r\n"));
						break;

						case FR_DENIED:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_DENIED\r\n"));
						break;
						
						case FR_EXIST:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_EXIST\r\n"));
						break;
						
						case FR_INVALID_OBJECT:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_INVALID_OBJECT\r\n"));
						break;
						
						case FR_WRITE_PROTECTED:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_WRITE_PROTECTED\r\n"));
						break;
						
						case FR_INVALID_DRIVE:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_INVALID_DRIVE\r\n"));
						break;
						
						case FR_NOT_ENABLED:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_NOT_ENABLED\r\n"));
						break;
						
						case FR_NO_FILESYSTEM:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_NO_FILESYSTEM\r\n"));
						break;
						
						case FR_TIMEOUT:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_TIMEOUT\r\n"));
						break;
						
						case FR_LOCKED:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_LOCKED\r\n"));
						break;
						
						case FR_NOT_ENOUGH_CORE:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_NOT_ENOUGH_CORE\r\n"));
						break;
						
						case FR_TOO_MANY_OPEN_FILES:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned FR_TOO_MANY_OPEN_FILES\r\n"));
						break;
						
						default:
						debugString_P(PSTR("File system: filesystemOpenFatForRead(): ERROR: f_open on FAT file returned unknown error\r\n"));
						break;
					}
				}
				
				f_close(&filesystemState.fileObject);
				return false;
			}
			
			// Seek to the correct point in the file
			filesystemState.fsResult  = f_lseek(&filesystemState.fileObject, blockNumber * 256);
			if (filesystemState.fsResult != FR_OK)
			{
				if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemOpenFatForRead(): Could not seek to required block number!\r\n"));
				f_close(&filesystemState.fileObject);
				return false;
			}
		}
	}
	else
	{
		// Couldn't open directory object
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemOpenFatForRead(): Could not open transfer directory!\r\n"));
		f_closedir(&filesystemState.dirObject);
		return false;
	}
	
	// File opened successfully
	return true;
}

// Read the next block from a FAT file
bool filesystemReadNextFatBlock(uint8_t *buffer)
{
	uint16_t byteCounter = 0;
	
	// Clear the buffer
	for (byteCounter = 0; byteCounter < 256; byteCounter++) buffer[byteCounter] = 0;
	
	// Read 256 bytes of data into the buffer
	filesystemState.fsResult  = f_read(&filesystemState.fileObject, buffer, 256, &byteCounter);
	if (filesystemState.fsResult != FR_OK)
	{
		if (debugFlag_filesystem) debugString_P(PSTR("File system: filesystemReadNextFatBlock(): Could not read data from the target file!\r\n"));
		f_close(&filesystemState.fileObject);
		return false;
	}
	
	return true;
}

// Close a FAT file previously opened for reading
bool filesystemCloseFatForRead(void)
{
	f_close(&filesystemState.fileObject);
	return true;
}
