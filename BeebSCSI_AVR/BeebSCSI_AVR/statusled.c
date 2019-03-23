/************************************************************************
	statusled.c

	BeebSCSI status LED functions
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

#include <avr/interrupt.h>
#include <stdbool.h>
#include <stdio.h>

// Local includes
#include "uart.h"
#include "debug.h"
#include "statusled.h"

// LED brightness can be between 0 (off) and 19 (on)
volatile uint8_t ledActualBrightness = 0;
volatile uint8_t ledTargetBrightness = 0;
volatile uint8_t fadeCounter = 0;
volatile uint8_t pwmCounter = 0;

// Interrupt Service Routine based on Timer0 for LED PWM output
ISR(TIMER2_COMPA_vect)
{
	// Set the LED to on or off depending on the required brightness level
	if (ledActualBrightness > pwmCounter) STATUS_LED_PORT &= ~STATUS_LED; // Pin = 0 (on)
	else STATUS_LED_PORT |= STATUS_LED; // Pin = 1 (off)
	
	// Update and range check the PWM counter
	pwmCounter++;
	if (pwmCounter > 19) pwmCounter = 0;
	
	// Perform fading control
	if (ledTargetBrightness >= ledActualBrightness)
	ledActualBrightness = ledTargetBrightness;
	else {
		fadeCounter++;
		if (fadeCounter == 12) {
			ledActualBrightness--;
			fadeCounter = 0;
		}
	}
}

// Initialise status LED
void statusledInitialise(void)
{
	// Configure the status LED
	STATUS_LED_DDR |= STATUS_LED; // Output
	STATUS_LED_PORT |= STATUS_LED; // Pin = 1 (off)
	
	// Configure Timer2 to interrupt (8-bit timer) for PWM output
	//
	// The required duty-cycle is 50Hz (20,000 us)
	// The required number of brightness levels is 20
	// This means we require an interrupt every 1,000 us
	//
	// fOSC is 16,000,000 ticks per second
	// 16,000,000 / 64 prescale = 250,000 ticks per second
	// 250,000 ticks per second = 1 tick per 4 us
	// @4us per tick, 250 ticks = 1,000 us
	//
	OCR2A = 200; // 200 = 1,000 us
	
	// Set OC0A on Compare Match, clear OC0A at TOP - Fast PWM
	TCCR2A = (1 << WGM22) | (1 << WGM21) | (1 << WGM20);
	
	// Set /64 clock prescale
	TCCR2B = (1 << CS21) | (1 << CS20);
	
	// Enable timer0 interrupt
	TIMSK2 = (1 << OCIE2A);
	
	// Set the initial brightness (note: lowest brightness is used to show "powered" status)
	ledTargetBrightness = 1;
}

// Reset the status LED
void statusledReset(void)
{
	// Turn the activity indication off
	statusledActivity(0);
}

// Show activity using the status LED
void statusledActivity(uint8_t state)
{
	// If the activity light is on, set to full brightness
	if (state == 1) ledTargetBrightness = 19; else ledTargetBrightness = 1;
}