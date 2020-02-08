/************************************************************************
	uart.c

	UART serial functions (with Tx and Rx ring-buffers)
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
#include <avr/interrupt.h>
#include <stdio.h>
#include <stdbool.h>

// Local includes
#include "uart.h"

#define UART_BAUDRATE 57600
#define BAUD_PRESCALE ((( F_CPU / ( UART_BAUDRATE * 16UL))) - 1)

// Definitions for buffers (size should be a power of 2)
#define UART_RX_BUFFER_SIZE	256
#define UART_TX_BUFFER_SIZE	512

#define UART_RX_BUFFER_MASK (UART_RX_BUFFER_SIZE - 1)
#define UART_TX_BUFFER_MASK (UART_TX_BUFFER_SIZE - 1)

// Input and output buffers for UART communication
static volatile uint8_t uartRxBuffer[UART_RX_BUFFER_SIZE];
static volatile uint8_t uartTxBuffer[UART_TX_BUFFER_SIZE];

// Buffer pointer globals
static volatile uint16_t uartTxHead;
static volatile uint16_t uartTxTail;
static volatile uint16_t uartRxHead;
static volatile uint16_t uartRxTail;
static volatile uint8_t uartLastRxError;

// UART Rx interrupt handler
ISR(USART1_RX_vect)
{
	uint16_t tmpHead;
	uint8_t lastRxError;

	// Check for Frame Error and Data OverRun errors
	lastRxError = (UCSR1A & ((1 << FE1) | (1<< DOR1)));
	    
	// Calculate the buffer index
	tmpHead = (uartRxHead + 1) & UART_RX_BUFFER_MASK;
	    
	if (tmpHead == uartRxTail) {
		// Error: receive buffer overflow
		lastRxError = UART_BUFFER_OVERFLOW >> 8;
	} else {
		// Store the new index
		uartRxHead = tmpHead;
		
		// Place the received data in the buffer
		uartRxBuffer[tmpHead] = UDR1;
	}
	
	// Store any errors
	uartLastRxError = lastRxError;
}

// UART UDRE interrupt handler (ready to send)
ISR(USART1_UDRE_vect)
{
	uint16_t tmpTail;

	if ( uartTxHead != uartTxTail) {
		// Calculate and store the new buffer index
		tmpTail = (uartTxTail + 1) & UART_TX_BUFFER_MASK;
		uartTxTail = tmpTail;
		
		// Get a byte from the Tx buffer and write it to the UART
		UDR1 = uartTxBuffer[tmpTail];
	} else {
		// The Tx buffer is empty; disable the UDRE interrupt
		UCSR1B &= ~(1 << UDRIE1);
	}
}

void uartInitialise(void)
{
	// Initialise buffer pointers
	uartTxHead = 0;
	uartTxTail = 0;
	uartRxHead = 0;
	uartRxTail = 0;

	// Set baud rate
	unsigned int baud = BAUD_PRESCALE;
	UBRR1H = (unsigned char)(baud >> 8);
	UBRR1L = (unsigned char)baud;
	
	// Enable UART RX and TX
	UCSR1B = (1 << RXEN1) | (1 << TXEN1);
	
	// Set 8N1 length, parity and stop-bit
	UCSR1C = (1 << UCSZ11) | (1 << UCSZ10);
	
	// Enable receive interrupt
	UCSR1B |= (1 << RXCIE1);
	
	// Open a STDIO handler for printf and other functions to STDOUT/STDIN
	fdevopen(&uartPutChar, &uartGetChar);
}

// Write to the UART
void uartWrite(uint8_t data)
{
	uint16_t tmpHead;

	tmpHead  = (uartTxHead + 1) & UART_TX_BUFFER_MASK;

	// If transmit buffer is full, wait for there to be space
	while (tmpHead == uartTxTail) {
		// wait for free space in buffer
	}

	uartTxBuffer[tmpHead] = data;
	uartTxHead = tmpHead;

	// Enable UDRE interrupt
	UCSR1B |= (1 << UDRIE1);
}

// Read from the UART, returns two bytes:
// MSB is the error status
// LSB is the read byte
uint16_t uartRead(void)
{
	uint16_t tmpTail;
	uint8_t data;

	if (uartRxHead == uartRxTail) {
		// Buffer is empty
		return UART_NO_DATA;
	}

	// Calculate Rx buffer index
	tmpTail = (uartRxTail + 1) & UART_RX_BUFFER_MASK;
	uartRxTail = tmpTail;

	// Get data from the receive buffer
	data = uartRxBuffer[tmpTail];

	return (uartLastRxError << 8) + data;
}

// Peek from the UART, returns two bytes:
// MSB is the error status
// LSB is the read byte
// Note: Peek does not remove the read byte from the buffer
uint16_t uartPeek(void)
{
	uint16_t tmpTail;
	uint8_t data;

	if (uartRxHead == uartRxTail) {
		// Buffer is empty
		return UART_NO_DATA;
	}

	tmpTail = (uartRxTail + 1) & UART_RX_BUFFER_MASK;

	// Get data from the receive buffer
	data = uartRxBuffer[tmpTail];

	return (uartLastRxError << 8) + data;
}

// Peek from the UART and check for a CR terminated string
// in the buffer (this is used to ensure we have a complete
// F-Code response before sending it to the host
bool uartPeekForString(void)
{
	uint16_t bytesAvailable;
	uint16_t byteCounter;
	uint16_t tmpRxTail;
	uint16_t tmpTail;
	uint8_t data;
	
	bytesAvailable = uartAvailable();
	tmpRxTail = uartRxTail;
	
	// Are there any bytes available in the buffer?
	if (bytesAvailable != 0) {
		// Look through the available bytes
		for (byteCounter = 0; byteCounter < bytesAvailable; byteCounter++) {
			// Calculate Rx buffer index
			tmpTail = (tmpRxTail + 1) & UART_RX_BUFFER_MASK;
			tmpRxTail = tmpTail;

			// Get data from the receive buffer
			data = uartRxBuffer[tmpTail];
			
			// If the data is a CR, return with true
			if (data == 0x0D) return true;
		}
	}

	// No CR found in data	
	return false;
}

// Returns the number of bytes waiting in the receive buffer
uint16_t uartAvailable(void)
{
	return (UART_RX_BUFFER_SIZE + uartRxHead - uartRxTail) & UART_RX_BUFFER_MASK;
}

// Flush the receive buffer
void uartFlush(void)
{
	uartRxHead = uartRxTail;
}

// Put character function for stdio stream
int16_t uartPutChar(char data, FILE *stream)
{
	uartWrite(data);
	return 0;
}

// Get character function for stdio stream
int16_t uartGetChar(FILE *stream)
{
	uint16_t data;
	
	data = uartRead();
	
	// Strip the error byte and return the character
	return (int)(data & 0x00FF);
}