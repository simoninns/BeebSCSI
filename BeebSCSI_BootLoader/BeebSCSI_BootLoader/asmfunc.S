
/************************************************************************
	asmfunc.S

	SD Card hardware and flashing functions
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

#define	DDR_CS	_SFR_IO_ADDR(DDRB), 0	// MMC CS pin (DDR, PORT)
#define	PORT_CS	_SFR_IO_ADDR(PORTB), 0

#define	DDR_CK	_SFR_IO_ADDR(DDRB), 1	// MMC SCLK pin (DDR, PORT)
#define	PORT_CK	_SFR_IO_ADDR(PORTB), 1

#define	DDR_DI	_SFR_IO_ADDR(DDRB), 2	// MMC DI pin (DDR, PORT)
#define	PORT_DI	_SFR_IO_ADDR(PORTB), 2

#define	PIN_DO	_SFR_IO_ADDR(PINB), 3	// MMC DO pin (PIN, PORT)
#define	PORT_DO	_SFR_IO_ADDR(PORTB), 3

#define	DDR_PWR	 _SFR_IO_ADDR(DDRB), 4	// MMC POWER pin (DDR, PORT)
#define	PORT_PWR _SFR_IO_ADDR(PORTB), 4

#define	DDR_LED	 _SFR_IO_ADDR(DDRE), 0	// Status LED pin (DDR, PORT)
#define	PORT_LED _SFR_IO_ADDR(PORTE), 0


;---------------------------------------------------------------------------;
.nolist
#include <avr/io.h>
.list
.text

;---------------------------------------------------------------------------;
; Initialise status LED
;
; void init_led (void)
.global init_led
.func init_led
init_led:
	sbi DDR_LED		; LED: output
	ret
.endfunc

;---------------------------------------------------------------------------;
; Status LED On
;
; void led_on (void)
.global led_on
.func led_on
led_on:
	cbi PORT_LED		; LED pin off (= led on)
	ret
.endfunc

;---------------------------------------------------------------------------;
; Status LED Off
;
; void led_off (void)
.global led_off
.func led_off
led_off:
	sbi PORT_LED		; LED pin on (= led off)
	ret
.endfunc

;---------------------------------------------------------------------------;
; Initialise card power control
;
; void init_pwr (void)
.global init_pwr
.func init_pwr
init_pwr:
	sbi DDR_PWR		; PWR: output
	ret
.endfunc

;---------------------------------------------------------------------------;
; Card power on
;
; void pwr_on (void)
.global pwr_on
.func pwr_on
pwr_on:
	cbi PORT_PWR		; Card power on
	ret
.endfunc

;---------------------------------------------------------------------------;
; Card power off
;
; void pwr_off (void)
.global pwr_off
.func pwr_off
pwr_off:
	sbi PORT_PWR		; Card power off
	ret
.endfunc

;---------------------------------------------------------------------------;
; Delay 100 microseconds
;
; void dly_100us (void);

.global dly_100us
.func dly_100us
dly_100us:
	ldi		r24, lo8(16000000 / 100000)	/* Loop counter */
1:	sbiw	r30, 1		/* 10 clocks per loop */
	sbiw	r30, 1
	sbiw	r30, 1
	nop
	dec	r24
	brne	1b
	ret
.endfunc



;---------------------------------------------------------------------------;
; Initialize MMC port
;
; void init_spi (void);

.global init_spi
.func init_spi
init_spi:
	sbi	DDR_CS		; CS: output
	sbi	DDR_DI		; DI: output
	sbi	DDR_CK		; SCLK: output
	sbi	PORT_DO		; DO: pull-up
	ret
.endfunc



;---------------------------------------------------------------------------;
; Select MMC
;
; void select (void);

.global select
.func select
select:
	rcall	deselect
	cbi	PORT_CS
	rjmp	rcv_spi
.endfunc



;---------------------------------------------------------------------------;
; Deselect MMC
;
; void deselect (void);

.global deselect
.func deselect
deselect:
	sbi	PORT_CS
	; Goto next function
.endfunc



;---------------------------------------------------------------------------;
; Receive a byte
;
; BYTE rcv_spi (void);

.global rcv_spi
.func rcv_spi
rcv_spi:
	ldi	r24, 0xFF	; Send 0xFF to receive data
	; Goto next function
.endfunc



;---------------------------------------------------------------------------;
; Transmit a byte
;
; void xmit_spi (BYTE);

.global xmit_spi
.func xmit_spi
xmit_spi:
	ldi	r25, 8
1:	sbrc	r24, 7		; DI = Bit to sent
	sbi	PORT_DI		; 
	sbrs	r24, 7		; 
	cbi	PORT_DI		; /
	lsl	r24		; Get DO from MMC
	sbic	PIN_DO		; 
	inc	r24		; /
	sbi	PORT_CK		; A positive pulse to SCLK
	cbi	PORT_CK		; /
	dec	r25		; Repeat 8 times
	brne	1b		; /
	ret
.endfunc



;---------------------------------------------------------------------------
; Erase a flash page
;
; void flash_erase (DWORD flash_addr);

#ifndef SPMCSR
#define SPMCSR SPMCR
#endif

.global flash_erase
.func flash_erase
flash_erase:

	movw	ZL, r22
#if FLASHEND >= 0x10000
	out	_SFR_IO_ADDR(RAMPZ), r24
#endif

	; Initiate erase operation
	ldi	r24, 0b00000011
	sts	_SFR_MEM_ADDR(SPMCSR), r24
	spm

	; Wait for end of erase operation
1:	lds	r24, _SFR_MEM_ADDR(SPMCSR)
	sbrc	r24, 0
	rjmp	1b

	; Re-enable read access to the flash
	ldi	r24, 0b00010001
	sts	_SFR_MEM_ADDR(SPMCSR), r24
	spm

9:	ret
.endfunc



;---------------------------------------------------------------------------
; Write a flash page
;
; void flash_write (DWORD flash_addr, const BYTE* data);

.global flash_write
.func flash_write
flash_write:
	push	r0
	push	r1

#if FLASHEND >= 0x10000
	out	_SFR_IO_ADDR(RAMPZ), r24
#endif

	; Fill page buffer
	movw	ZL, r22
	movw	XL, r20
	ldi	r25, lo8(SPM_PAGESIZE/2)
1:	ld	r0, X+
	ld	r1, X+
	ldi	r24, 0b00000001
	sts	_SFR_MEM_ADDR(SPMCSR), r24
	spm
	adiw	ZL, 2
	dec	r25
	brne	1b

	; Initiate write operation
	movw	ZL, r22
	ldi	r24, 0b00000101
	sts	_SFR_MEM_ADDR(SPMCSR), r24
	spm

	; Wait for end of write operation
2:	lds	r24, _SFR_MEM_ADDR(SPMCSR)
	sbrc	r24, 0
	rjmp	2b

	; Re-enable read access to the flash
	ldi	r24, 0b00010001
	sts	_SFR_MEM_ADDR(SPMCSR), r24
	spm

9:	pop	r1
	pop	r0
	ret
.endfunc
