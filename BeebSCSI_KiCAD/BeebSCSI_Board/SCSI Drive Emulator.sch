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
Sheet 4 5
Title "BeebSCSI - SCSI Drive Emulator"
Date "2018-04-30"
Rev "7_6"
Comp "https://www.domesday86.com"
Comment1 "(c)2018 Simon Inns"
Comment2 "License: Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)"
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L AT90USB1287 IC1
U 1 1 5AE7CE35
P 5950 3500
F 0 "IC1" H 4850 5400 60  0000 C CNN
F 1 "AT90USB1287" H 5950 3400 60  0000 C CNN
F 2 "Housings_QFP:TQFP-64_14x14mm_Pitch0.8mm" H 5950 3100 60  0001 C CNN
F 3 "" H 5950 3100 60  0001 C CNN
	1    5950 3500
	1    0    0    -1  
$EndComp
Text HLabel 7650 1800 2    60   Input ~ 0
SCSI_D0
Text HLabel 7650 1900 2    60   Input ~ 0
SCSI_D1
Text HLabel 7650 2000 2    60   Input ~ 0
SCSI_D2
Text HLabel 7650 2100 2    60   Input ~ 0
SCSI_D3
Text HLabel 7650 2200 2    60   Input ~ 0
SCSI_D4
Text HLabel 7650 2300 2    60   Input ~ 0
SCSI_D5
Text HLabel 7650 2400 2    60   Input ~ 0
SCSI_D6
Text HLabel 7650 2500 2    60   Input ~ 0
SCSI_D7
Wire Wire Line
	7650 1800 7250 1800
Wire Wire Line
	7250 1900 7650 1900
Wire Wire Line
	7650 2000 7250 2000
Wire Wire Line
	7250 2100 7650 2100
Wire Wire Line
	7650 2200 7250 2200
Wire Wire Line
	7250 2300 7650 2300
Wire Wire Line
	7650 2400 7250 2400
Wire Wire Line
	7250 2500 7650 2500
Text HLabel 7650 2700 2    60   Input ~ 0
SDCARD_CS0
Text HLabel 7650 2800 2    60   Input ~ 0
SDCARD_CLK
Text HLabel 7650 2900 2    60   Input ~ 0
SDCARD_MOSI
Text HLabel 7650 3000 2    60   Input ~ 0
SDCARD_MISO
Text HLabel 7650 3100 2    60   Input ~ 0
SDCARD_POWER
Text HLabel 7650 3200 2    60   Input ~ 0
SDCARD_CD
NoConn ~ 7250 3300
NoConn ~ 7250 3400
Wire Wire Line
	7650 2700 7250 2700
Wire Wire Line
	7250 2800 7650 2800
Wire Wire Line
	7650 2900 7250 2900
Wire Wire Line
	7250 3000 7650 3000
Wire Wire Line
	7650 3100 7250 3100
Wire Wire Line
	7250 3200 7650 3200
Text HLabel 7650 3600 2    60   Input ~ 0
SCSI_~MSG
Text HLabel 7650 3700 2    60   Input ~ 0
SCSI_~BSY
Text HLabel 7650 3800 2    60   Input ~ 0
SCSI_~REQ
Text HLabel 7650 3900 2    60   Input ~ 0
SCSI_I/~O
Text HLabel 7650 4000 2    60   Input ~ 0
SCSI_C/~D
Text HLabel 7650 4100 2    60   Input ~ 0
SCSI_INT/~EXT
Text HLabel 7650 4200 2    60   Input ~ 0
SCSI_~SEL
Text HLabel 7650 4300 2    60   Input ~ 0
SCSI_~ACK
Text HLabel 7650 4500 2    60   Input ~ 0
SCSI_~RST
Text HLabel 7650 4600 2    60   Input ~ 0
SCSI_~CONF
Wire Wire Line
	7650 3600 7250 3600
Wire Wire Line
	7250 3700 7650 3700
Wire Wire Line
	7650 3800 7250 3800
Wire Wire Line
	7250 3900 7650 3900
Wire Wire Line
	7650 4000 7250 4000
Wire Wire Line
	7250 4100 7650 4100
Wire Wire Line
	7650 4200 7250 4200
Wire Wire Line
	7250 4300 7650 4300
Wire Wire Line
	7650 4500 7250 4500
Wire Wire Line
	7250 4600 7650 4600
NoConn ~ 7250 4900
NoConn ~ 7250 5000
NoConn ~ 7250 5100
NoConn ~ 7250 5200
$Comp
L Conn_01x06 J5
U 1 1 5AE7D325
P 8900 4600
F 0 "J5" H 8900 4900 50  0000 C CNN
F 1 "TTL Serial" H 8900 4200 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x06_Pitch2.54mm" H 8900 4600 50  0001 C CNN
F 3 "" H 8900 4600 50  0001 C CNN
	1    8900 4600
	1    0    0    -1  
$EndComp
Wire Wire Line
	7250 4700 8700 4700
Wire Wire Line
	8700 4800 7250 4800
Wire Wire Line
	8700 4400 8600 4400
Wire Wire Line
	8600 4400 8600 5150
NoConn ~ 8700 4500
NoConn ~ 8700 4600
NoConn ~ 8700 4900
$Comp
L GND #PWR020
U 1 1 5AE7D42A
P 8600 5150
F 0 "#PWR020" H 8600 4900 50  0001 C CNN
F 1 "GND" H 8600 5000 50  0000 C CNN
F 2 "" H 8600 5150 50  0001 C CNN
F 3 "" H 8600 5150 50  0001 C CNN
	1    8600 5150
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR021
U 1 1 5AE7D451
P 5850 5650
F 0 "#PWR021" H 5850 5400 50  0001 C CNN
F 1 "GND" H 5850 5500 50  0000 C CNN
F 2 "" H 5850 5650 50  0001 C CNN
F 3 "" H 5850 5650 50  0001 C CNN
	1    5850 5650
	1    0    0    -1  
$EndComp
Wire Wire Line
	5850 5500 5850 5650
Wire Wire Line
	6050 5600 6050 5500
Wire Wire Line
	5850 5600 6050 5600
Connection ~ 5850 5600
Wire Wire Line
	5950 5500 5950 5600
Connection ~ 5950 5600
$Comp
L +5V #PWR022
U 1 1 5AE7D737
P 5850 1350
F 0 "#PWR022" H 5850 1200 50  0001 C CNN
F 1 "+5V" H 5850 1490 50  0000 C CNN
F 2 "" H 5850 1350 50  0001 C CNN
F 3 "" H 5850 1350 50  0001 C CNN
	1    5850 1350
	1    0    0    -1  
$EndComp
Wire Wire Line
	5850 1350 5850 1500
Wire Wire Line
	6050 1400 6050 1500
Wire Wire Line
	4300 1400 6050 1400
Connection ~ 5850 1400
Wire Wire Line
	5950 1500 5950 1400
Connection ~ 5950 1400
NoConn ~ 4550 3900
NoConn ~ 4550 3800
NoConn ~ 4550 3700
NoConn ~ 4550 3600
NoConn ~ 4550 5200
NoConn ~ 4550 5100
NoConn ~ 4550 5000
NoConn ~ 4550 4900
NoConn ~ 4550 4800
NoConn ~ 4550 4700
NoConn ~ 4550 4600
$Comp
L C C7
U 1 1 5AE7D9F8
P 2600 7100
F 0 "C7" H 2625 7200 50  0000 L CNN
F 1 "100nF" H 2625 7000 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 2638 6950 50  0001 C CNN
F 3 "" H 2600 7100 50  0001 C CNN
	1    2600 7100
	1    0    0    -1  
$EndComp
$Comp
L C C8
U 1 1 5AE7DA30
P 2900 7100
F 0 "C8" H 2925 7200 50  0000 L CNN
F 1 "100nF" H 2925 7000 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 2938 6950 50  0001 C CNN
F 3 "" H 2900 7100 50  0001 C CNN
	1    2900 7100
	1    0    0    -1  
$EndComp
$Comp
L C C9
U 1 1 5AE7DA54
P 3200 7100
F 0 "C9" H 3225 7200 50  0000 L CNN
F 1 "100nF" H 3225 7000 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 3238 6950 50  0001 C CNN
F 3 "" H 3200 7100 50  0001 C CNN
	1    3200 7100
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR023
U 1 1 5AE7DA7D
P 2600 7400
F 0 "#PWR023" H 2600 7150 50  0001 C CNN
F 1 "GND" H 2600 7250 50  0000 C CNN
F 2 "" H 2600 7400 50  0001 C CNN
F 3 "" H 2600 7400 50  0001 C CNN
	1    2600 7400
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR024
U 1 1 5AE7DAB0
P 2600 6800
F 0 "#PWR024" H 2600 6650 50  0001 C CNN
F 1 "+5V" H 2600 6940 50  0000 C CNN
F 2 "" H 2600 6800 50  0001 C CNN
F 3 "" H 2600 6800 50  0001 C CNN
	1    2600 6800
	1    0    0    -1  
$EndComp
Wire Wire Line
	2600 6800 2600 6950
Wire Wire Line
	2600 7250 2600 7400
Wire Wire Line
	3200 6850 3200 6950
Wire Wire Line
	2600 6850 3200 6850
Connection ~ 2600 6850
Wire Wire Line
	2900 6950 2900 6850
Connection ~ 2900 6850
Wire Wire Line
	3200 7350 3200 7250
Wire Wire Line
	2600 7350 3200 7350
Connection ~ 2600 7350
Wire Wire Line
	2900 7250 2900 7350
Connection ~ 2900 7350
NoConn ~ 4550 3000
NoConn ~ 4550 2900
NoConn ~ 4550 2700
NoConn ~ 4550 2600
$Comp
L R R3
U 1 1 5AE7DF0F
P 4450 1650
F 0 "R3" V 4530 1650 50  0000 C CNN
F 1 "10K" V 4450 1650 50  0000 C CNN
F 2 "Resistors_SMD:R_0805" V 4380 1650 50  0001 C CNN
F 3 "" H 4450 1650 50  0001 C CNN
	1    4450 1650
	1    0    0    -1  
$EndComp
Wire Wire Line
	4100 1900 4550 1900
Wire Wire Line
	4450 1900 4450 1800
Wire Wire Line
	4450 1500 4450 1400
Wire Wire Line
	4550 3200 4300 3200
Wire Wire Line
	4300 3200 4300 1400
Connection ~ 4450 1400
$Comp
L C C12
U 1 1 5AE7E394
P 4050 2400
F 0 "C12" H 4075 2500 50  0000 L CNN
F 1 "100nF" H 4075 2300 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 4088 2250 50  0001 C CNN
F 3 "" H 4050 2400 50  0001 C CNN
	1    4050 2400
	0    1    1    0   
$EndComp
Wire Wire Line
	4550 2400 4200 2400
Wire Wire Line
	2700 3300 4550 3300
Wire Wire Line
	4300 3300 4300 3450
Wire Wire Line
	3900 2400 3800 2400
Wire Wire Line
	3800 2400 3800 3300
Connection ~ 4300 3300
$Comp
L GND #PWR025
U 1 1 5AE7E83C
P 4300 3450
F 0 "#PWR025" H 4300 3200 50  0001 C CNN
F 1 "GND" H 4300 3300 50  0000 C CNN
F 2 "" H 4300 3450 50  0001 C CNN
F 3 "" H 4300 3450 50  0001 C CNN
	1    4300 3450
	1    0    0    -1  
$EndComp
$Comp
L Crystal Y1
U 1 1 5AE7E85E
P 3050 2400
F 0 "Y1" H 3050 2550 50  0000 C CNN
F 1 "16MHz Crystal" H 3050 2250 50  0000 C CNN
F 2 "Crystals:Crystal_SMD_5032-2pin_5.0x3.2mm" H 3050 2400 50  0001 C CNN
F 3 "" H 3050 2400 50  0001 C CNN
	1    3050 2400
	1    0    0    -1  
$EndComp
$Comp
L C C10
U 1 1 5AE7E8E9
P 2700 2750
F 0 "C10" H 2725 2850 50  0000 L CNN
F 1 "22pF" H 2725 2650 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 2738 2600 50  0001 C CNN
F 3 "" H 2700 2750 50  0001 C CNN
	1    2700 2750
	1    0    0    -1  
$EndComp
$Comp
L C C11
U 1 1 5AE7E95A
P 3400 2750
F 0 "C11" H 3425 2850 50  0000 L CNN
F 1 "22pF" H 3425 2650 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 3438 2600 50  0001 C CNN
F 3 "" H 3400 2750 50  0001 C CNN
	1    3400 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	4550 2100 2700 2100
Wire Wire Line
	2700 2100 2700 2600
Wire Wire Line
	4550 2200 3400 2200
Wire Wire Line
	3400 2200 3400 2600
Wire Wire Line
	3200 2400 3400 2400
Connection ~ 3400 2400
Wire Wire Line
	2900 2400 2700 2400
Connection ~ 2700 2400
Wire Wire Line
	2700 2900 2700 3300
Connection ~ 3800 3300
Wire Wire Line
	3400 2900 3400 3300
Connection ~ 3400 3300
$Comp
L R R2
U 1 1 5AE7EC5E
P 4100 5550
F 0 "R2" V 4180 5550 50  0000 C CNN
F 1 "470R" V 4100 5550 50  0000 C CNN
F 2 "Resistors_SMD:R_0805" V 4030 5550 50  0001 C CNN
F 3 "" H 4100 5550 50  0001 C CNN
	1    4100 5550
	0    1    1    0   
$EndComp
$Comp
L LED D1
U 1 1 5AE7ECCE
P 3600 5550
F 0 "D1" H 3600 5650 50  0000 C CNN
F 1 "Status LED" H 3600 5450 50  0000 C CNN
F 2 "LEDs:LED_0805" H 3600 5550 50  0001 C CNN
F 3 "" H 3600 5550 50  0001 C CNN
	1    3600 5550
	-1   0    0    1   
$EndComp
Wire Wire Line
	3950 5550 3750 5550
Wire Wire Line
	3450 5550 3250 5550
$Comp
L +5V #PWR026
U 1 1 5AE7EEC4
P 3250 5450
F 0 "#PWR026" H 3250 5300 50  0001 C CNN
F 1 "+5V" H 3250 5590 50  0000 C CNN
F 2 "" H 3250 5450 50  0001 C CNN
F 3 "" H 3250 5450 50  0001 C CNN
	1    3250 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3250 5550 3250 5450
Connection ~ 4450 1900
Wire Wire Line
	4250 5550 4350 5550
Wire Wire Line
	4350 5550 4350 4500
Wire Wire Line
	4350 4500 4550 4500
Text HLabel 4100 1900 0    60   Input ~ 0
AVR_JTAG_RST
Text HLabel 4300 4000 0    60   Input ~ 0
AVR_JTAG_TCK
Text HLabel 4300 4100 0    60   Input ~ 0
AVR_JTAG_TMS
Text HLabel 4300 4200 0    60   Input ~ 0
AVR_JTAG_TDO
Text HLabel 4300 4300 0    60   Input ~ 0
AVR_JTAG_TDI
Wire Wire Line
	4300 4000 4550 4000
Wire Wire Line
	4300 4100 4550 4100
Wire Wire Line
	4300 4200 4550 4200
Wire Wire Line
	4300 4300 4550 4300
$EndSCHEMATC
