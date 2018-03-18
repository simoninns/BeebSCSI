/************************************************************************
	uart.h

	UART serial functions
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

#ifndef UART_H_
#define UART_H_

// MSB error byte return code from uartRead()
#define UART_FRAME_ERROR		0x0800		// UART Framing Error
#define UART_OVERRUN_ERROR		0x0400		// UART overrun condition
#define UART_BUFFER_OVERFLOW	0x0200		// Rx ring buffer overflow
#define UART_NO_DATA			0x0100		// Receive data not available

// Global FILE stream for STDIO use
FILE uartStream;

// Function prototypes
void uartInitialise(void);
void uartWrite(uint8_t data);
uint16_t uartRead(void);
uint16_t uartPeek(void);
bool uartPeekForString(void);
uint16_t uartAvailable(void);
void uartFlush(void);
int uartPutChar(char data, FILE *stream);
int uartGetChar(FILE *stream);

#endif /* UART_H_ */