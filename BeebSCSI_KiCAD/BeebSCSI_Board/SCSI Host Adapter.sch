EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:switches
LIBS:relays
LIBS:motors
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:74xgxx
LIBS:ac-dc
LIBS:actel
LIBS:allegro
LIBS:Altera
LIBS:analog_devices
LIBS:battery_management
LIBS:bbd
LIBS:bosch
LIBS:brooktre
LIBS:cmos_ieee
LIBS:dc-dc
LIBS:diode
LIBS:elec-unifil
LIBS:ESD_Protection
LIBS:ftdi
LIBS:gennum
LIBS:graphic
LIBS:graphic_symbols
LIBS:hc11
LIBS:infineon
LIBS:intersil
LIBS:ir
LIBS:Lattice
LIBS:leds
LIBS:LEM
LIBS:logic_programmable
LIBS:logo
LIBS:maxim
LIBS:mechanical
LIBS:microchip_dspic33dsc
LIBS:microchip_pic10mcu
LIBS:microchip_pic12mcu
LIBS:microchip_pic16mcu
LIBS:microchip_pic18mcu
LIBS:microchip_pic24mcu
LIBS:microchip_pic32mcu
LIBS:modules
LIBS:motor_drivers
LIBS:msp430
LIBS:nordicsemi
LIBS:nxp
LIBS:nxp_armmcu
LIBS:onsemi
LIBS:Oscillators
LIBS:Power_Management
LIBS:powerint
LIBS:pspice
LIBS:references
LIBS:rfcom
LIBS:RFSolutions
LIBS:sensors
LIBS:silabs
LIBS:stm8
LIBS:stm32
LIBS:supertex
LIBS:transf
LIBS:triac_thyristor
LIBS:ttl_ieee
LIBS:video
LIBS:wiznet
LIBS:Worldsemi
LIBS:Xicor
LIBS:zetex
LIBS:Zilog
LIBS:xc9572xl
LIBS:AT90USB1287
LIBS:BeebSCSI-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 5
Title "BeebSCSI - SCSI Host Adapter"
Date "2018-05-18"
Rev "7_7"
Comp "https://www.domesday86.com"
Comment1 "(c)2018 Simon Inns"
Comment2 "License: Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)"
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L XC9572XL U2
U 1 1 5AE71FE6
P 5950 3450
F 0 "U2" H 5150 5150 60  0000 C CNN
F 1 "XC9572XL" H 6600 1750 60  0000 C CNN
F 2 "Housings_QFP:TQFP-64_10x10mm_Pitch0.5mm" H 5950 3350 60  0001 C CNN
F 3 "" H 5950 3350 60  0001 C CNN
	1    5950 3450
	1    0    0    -1  
$EndComp
$Comp
L C C3
U 1 1 5AE6AF1B
P 2100 6850
F 0 "C3" H 2125 6950 50  0000 L CNN
F 1 "100nF" H 2125 6750 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 2138 6700 50  0001 C CNN
F 3 "" H 2100 6850 50  0001 C CNN
	1    2100 6850
	1    0    0    -1  
$EndComp
$Comp
L C C4
U 1 1 5AE6AF79
P 2400 6850
F 0 "C4" H 2425 6950 50  0000 L CNN
F 1 "100nF" H 2425 6750 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 2438 6700 50  0001 C CNN
F 3 "" H 2400 6850 50  0001 C CNN
	1    2400 6850
	1    0    0    -1  
$EndComp
$Comp
L C C5
U 1 1 5AE6AF9A
P 2700 6850
F 0 "C5" H 2725 6950 50  0000 L CNN
F 1 "100nF" H 2725 6750 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 2738 6700 50  0001 C CNN
F 3 "" H 2700 6850 50  0001 C CNN
	1    2700 6850
	1    0    0    -1  
$EndComp
$Comp
L C C6
U 1 1 5AE6AFBE
P 3000 6850
F 0 "C6" H 3025 6950 50  0000 L CNN
F 1 "100nF" H 3025 6750 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 3038 6700 50  0001 C CNN
F 3 "" H 3000 6850 50  0001 C CNN
	1    3000 6850
	1    0    0    -1  
$EndComp
$Comp
L +3V3 #PWR016
U 1 1 5AE6AFF6
P 2100 6550
F 0 "#PWR016" H 2100 6400 50  0001 C CNN
F 1 "+3V3" H 2100 6690 50  0000 C CNN
F 2 "" H 2100 6550 50  0001 C CNN
F 3 "" H 2100 6550 50  0001 C CNN
	1    2100 6550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR017
U 1 1 5AE6B014
P 2100 7150
F 0 "#PWR017" H 2100 6900 50  0001 C CNN
F 1 "GND" H 2100 7000 50  0000 C CNN
F 2 "" H 2100 7150 50  0001 C CNN
F 3 "" H 2100 7150 50  0001 C CNN
	1    2100 7150
	1    0    0    -1  
$EndComp
Wire Wire Line
	2100 6550 2100 6700
Wire Wire Line
	2100 7000 2100 7150
Wire Wire Line
	2400 6700 2400 6600
Wire Wire Line
	2100 6600 3000 6600
Connection ~ 2100 6600
Wire Wire Line
	3000 6600 3000 6700
Connection ~ 2400 6600
Wire Wire Line
	2700 6700 2700 6600
Connection ~ 2700 6600
Wire Wire Line
	3000 7100 3000 7000
Wire Wire Line
	2100 7100 3000 7100
Connection ~ 2100 7100
Wire Wire Line
	2400 7000 2400 7100
Connection ~ 2400 7100
Wire Wire Line
	2700 7000 2700 7100
Connection ~ 2700 7100
$Comp
L GND #PWR018
U 1 1 5AE6B0AA
P 5800 5450
F 0 "#PWR018" H 5800 5200 50  0001 C CNN
F 1 "GND" H 5800 5300 50  0000 C CNN
F 2 "" H 5800 5450 50  0001 C CNN
F 3 "" H 5800 5450 50  0001 C CNN
	1    5800 5450
	1    0    0    -1  
$EndComp
$Comp
L +3V3 #PWR019
U 1 1 5AE6B0C4
P 5650 1400
F 0 "#PWR019" H 5650 1250 50  0001 C CNN
F 1 "+3V3" H 5650 1540 50  0000 C CNN
F 2 "" H 5650 1400 50  0001 C CNN
F 3 "" H 5650 1400 50  0001 C CNN
	1    5650 1400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5650 1400 5650 1600
Wire Wire Line
	6250 1500 6250 1600
Wire Wire Line
	5650 1500 6250 1500
Connection ~ 5650 1500
Wire Wire Line
	5750 1600 5750 1500
Connection ~ 5750 1500
Wire Wire Line
	6150 1600 6150 1500
Connection ~ 6150 1500
Wire Wire Line
	5800 5300 5800 5450
Wire Wire Line
	6100 5400 6100 5300
Wire Wire Line
	5800 5400 6100 5400
Connection ~ 5800 5400
Wire Wire Line
	5900 5300 5900 5400
Connection ~ 5900 5400
Wire Wire Line
	6000 5300 6000 5400
Connection ~ 6000 5400
Text HLabel 4600 3300 0    60   Input ~ 0
BBC_INT/~EXT
Text HLabel 4600 3400 0    60   Input ~ 0
BBC_D7
Text HLabel 4600 3500 0    60   Input ~ 0
BBC_D6
Text HLabel 4600 3600 0    60   Input ~ 0
BBC_D5
Text HLabel 4600 3700 0    60   Input ~ 0
BBC_D4
Text HLabel 4600 3800 0    60   Input ~ 0
BBC_D3
Text HLabel 4600 1900 0    60   Input ~ 0
BBC_D2
Text HLabel 4600 2000 0    60   Input ~ 0
BBC_D1
Text HLabel 4600 2100 0    60   Input ~ 0
BBC_D0
Text HLabel 4600 2200 0    60   Input ~ 0
BBC_~RESET
Text HLabel 4600 2300 0    60   Input ~ 0
BBC_~PGFC
Text HLabel 4600 2400 0    60   Input ~ 0
BBC_~IRQ
Text HLabel 4600 2500 0    60   Input ~ 0
BBC_1MHZE
Text HLabel 4600 2600 0    60   Input ~ 0
BBC_R/~W
Text HLabel 4600 4500 0    60   Input ~ 0
BBC_A0
Text HLabel 4600 4400 0    60   Input ~ 0
BBC_A1
Text HLabel 4600 4300 0    60   Input ~ 0
BBC_A2
Text HLabel 4600 4200 0    60   Input ~ 0
BBC_A3
Text HLabel 4600 4100 0    60   Input ~ 0
BBC_A4
Text HLabel 4600 4000 0    60   Input ~ 0
BBC_A5
Text HLabel 4600 3900 0    60   Input ~ 0
BBC_A6
Text HLabel 7300 4500 2    60   Input ~ 0
BBC_A7
Text HLabel 7300 2300 2    60   Input ~ 0
SCSI_DB0
Text HLabel 7300 2400 2    60   Input ~ 0
SCSI_DB1
Text HLabel 7300 2500 2    60   Input ~ 0
SCSI_DB2
Text HLabel 7300 2600 2    60   Input ~ 0
SCSI_DB3
Text HLabel 7300 2700 2    60   Input ~ 0
SCSI_DB4
Text HLabel 7300 2800 2    60   Input ~ 0
SCSI_DB5
Text HLabel 7300 2900 2    60   Input ~ 0
SCSI_DB6
Text HLabel 7300 3000 2    60   Input ~ 0
SCSI_DB7
Text HLabel 7300 3100 2    60   Input ~ 0
SCSI_~ACK
Text HLabel 7300 3200 2    60   Input ~ 0
SCSI_~SEL
Text HLabel 7300 3400 2    60   Input ~ 0
SCSI_INT/~EXT
Text HLabel 7300 3500 2    60   Input ~ 0
SCSI_C/~D
Text HLabel 7300 3600 2    60   Input ~ 0
SCSI_I/~O
Text HLabel 7300 3700 2    60   Input ~ 0
SCSI_~REQ
Text HLabel 7300 3800 2    60   Input ~ 0
SCSI_~BSY
Text HLabel 7300 3900 2    60   Input ~ 0
SCSI_~MSG
Text HLabel 7300 4000 2    60   Input ~ 0
SCSI_~RST
Text HLabel 7300 4100 2    60   Input ~ 0
SCSI_~CONF
Wire Wire Line
	7000 2300 7300 2300
Wire Wire Line
	7000 2400 7300 2400
Wire Wire Line
	7000 2500 7300 2500
Wire Wire Line
	7000 2600 7300 2600
Wire Wire Line
	7000 2700 7300 2700
Wire Wire Line
	7300 2800 7000 2800
Wire Wire Line
	7000 2900 7300 2900
Wire Wire Line
	7300 3000 7000 3000
Wire Wire Line
	7000 3100 7300 3100
Wire Wire Line
	7300 3200 7000 3200
Wire Wire Line
	7000 3400 7300 3400
Wire Wire Line
	7300 3500 7000 3500
Wire Wire Line
	7000 3600 7300 3600
Wire Wire Line
	7300 3700 7000 3700
Wire Wire Line
	7000 3800 7300 3800
Wire Wire Line
	7300 3900 7000 3900
Wire Wire Line
	7000 4000 7300 4000
Wire Wire Line
	7300 4100 7000 4100
Wire Wire Line
	7000 4500 7300 4500
Wire Wire Line
	4600 3300 4900 3300
Wire Wire Line
	4900 3400 4600 3400
Wire Wire Line
	4600 3500 4900 3500
Wire Wire Line
	4900 3600 4600 3600
Wire Wire Line
	4600 3700 4900 3700
Wire Wire Line
	4900 3800 4600 3800
Wire Wire Line
	4600 3900 4900 3900
Wire Wire Line
	4900 4000 4600 4000
Wire Wire Line
	4600 4100 4900 4100
Wire Wire Line
	4900 4200 4600 4200
Wire Wire Line
	4600 4300 4900 4300
Wire Wire Line
	4900 4400 4600 4400
Wire Wire Line
	4600 4500 4900 4500
Wire Wire Line
	4600 1900 4900 1900
Wire Wire Line
	4900 2000 4600 2000
Wire Wire Line
	4600 2100 4900 2100
Wire Wire Line
	4900 2200 4600 2200
Wire Wire Line
	4600 2300 4900 2300
Wire Wire Line
	4900 2400 4600 2400
Wire Wire Line
	4600 2500 4900 2500
Wire Wire Line
	4900 2600 4600 2600
Text HLabel 4600 4700 0    60   Input ~ 0
CPLD_JTAG_TDO
Text HLabel 4600 4800 0    60   Input ~ 0
CPLD_JTAG_TDI
Text HLabel 4600 4900 0    60   Input ~ 0
CPLD_JTAG_TMS
Text HLabel 4600 5000 0    60   Input ~ 0
CPLD_JTAG_TCK
Wire Wire Line
	4600 4700 4900 4700
Wire Wire Line
	4600 4800 4900 4800
Wire Wire Line
	4600 4900 4900 4900
Wire Wire Line
	4600 5000 4900 5000
$Comp
L GND #PWR020
U 1 1 5B0026E8
P 3650 3300
F 0 "#PWR020" H 3650 3050 50  0001 C CNN
F 1 "GND" H 3650 3150 50  0000 C CNN
F 2 "" H 3650 3300 50  0001 C CNN
F 3 "" H 3650 3300 50  0001 C CNN
	1    3650 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	4900 3100 3650 3100
Wire Wire Line
	3650 3100 3650 3300
Wire Wire Line
	4900 2700 4800 2700
Wire Wire Line
	4800 2700 4800 3100
Connection ~ 4800 3100
Wire Wire Line
	4900 2800 4800 2800
Connection ~ 4800 2800
Wire Wire Line
	4900 2900 4800 2900
Connection ~ 4800 2900
Wire Wire Line
	4900 3000 4800 3000
Connection ~ 4800 3000
Wire Wire Line
	7000 2200 8100 2200
Wire Wire Line
	8100 2200 8100 2350
Wire Wire Line
	7000 1900 7100 1900
Wire Wire Line
	7100 1900 7100 2200
Connection ~ 7100 2200
Wire Wire Line
	7000 2000 7100 2000
Connection ~ 7100 2000
Wire Wire Line
	7000 2100 7100 2100
Connection ~ 7100 2100
Wire Wire Line
	7000 4400 8100 4400
Wire Wire Line
	8100 4400 8100 4550
Wire Wire Line
	7000 4200 7100 4200
Wire Wire Line
	7100 4200 7100 4400
Connection ~ 7100 4400
Wire Wire Line
	7000 4300 7100 4300
Connection ~ 7100 4300
$Comp
L GND #PWR021
U 1 1 5B002B90
P 8100 2350
F 0 "#PWR021" H 8100 2100 50  0001 C CNN
F 1 "GND" H 8100 2200 50  0000 C CNN
F 2 "" H 8100 2350 50  0001 C CNN
F 3 "" H 8100 2350 50  0001 C CNN
	1    8100 2350
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR022
U 1 1 5B002BB4
P 8100 4550
F 0 "#PWR022" H 8100 4300 50  0001 C CNN
F 1 "GND" H 8100 4400 50  0000 C CNN
F 2 "" H 8100 4550 50  0001 C CNN
F 3 "" H 8100 4550 50  0001 C CNN
	1    8100 4550
	1    0    0    -1  
$EndComp
$EndSCHEMATC
