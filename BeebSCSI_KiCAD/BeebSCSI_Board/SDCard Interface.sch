EESchema Schematic File Version 2
LIBS:BeebSCSI-rescue
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
Sheet 5 5
Title "BeebSCSI - SDCard Interface"
Date "2018-05-18"
Rev "7_7"
Comp "https://www.domesday86.com"
Comment1 "(c)2018 Simon Inns"
Comment2 "License: Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)"
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L 74LS125 U3
U 1 1 5AE87173
P 3950 3750
F 0 "U3" H 3950 3850 50  0000 L BNN
F 1 "74AHC125S" H 4000 3600 50  0000 L TNN
F 2 "SMD_Packages:SOIC-14_N" H 3950 3750 50  0001 C CNN
F 3 "" H 3950 3750 50  0001 C CNN
	1    3950 3750
	1    0    0    -1  
$EndComp
$Comp
L 74LS125 U3
U 2 1 5AE871AC
P 3950 4300
F 0 "U3" H 3950 4400 50  0000 L BNN
F 1 "74AHC125S" H 4000 4150 50  0000 L TNN
F 2 "SMD_Packages:SOIC-14_N" H 3950 4300 50  0001 C CNN
F 3 "" H 3950 4300 50  0001 C CNN
	2    3950 4300
	1    0    0    -1  
$EndComp
$Comp
L 74LS125 U3
U 3 1 5AE871E7
P 3950 4850
F 0 "U3" H 3950 4950 50  0000 L BNN
F 1 "74AHC125S" H 4000 4700 50  0000 L TNN
F 2 "SMD_Packages:SOIC-14_N" H 3950 4850 50  0001 C CNN
F 3 "" H 3950 4850 50  0001 C CNN
	3    3950 4850
	1    0    0    -1  
$EndComp
$Comp
L 74LS125 U3
U 4 1 5AE87240
P 3950 5400
F 0 "U3" H 3950 5500 50  0000 L BNN
F 1 "74AHC125S" H 4000 5250 50  0000 L TNN
F 2 "SMD_Packages:SOIC-14_N" H 3950 5400 50  0001 C CNN
F 3 "" H 3950 5400 50  0001 C CNN
	4    3950 5400
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR029
U 1 1 5AE8738C
P 3400 5850
F 0 "#PWR029" H 3400 5600 50  0001 C CNN
F 1 "GND" H 3400 5700 50  0000 C CNN
F 2 "" H 3400 5850 50  0001 C CNN
F 3 "" H 3400 5850 50  0001 C CNN
	1    3400 5850
	1    0    0    -1  
$EndComp
NoConn ~ 4400 5400
Text HLabel 3200 3750 0    60   Input ~ 0
SDCARD_CS0
Text HLabel 3200 4300 0    60   Input ~ 0
SDCARD_MOSI
Text HLabel 3200 4850 0    60   Input ~ 0
SDCARD_CLK
Text HLabel 3200 3200 0    60   Input ~ 0
SDCARD_MISO
Text HLabel 6200 5150 0    60   Input ~ 0
SDCARD_CD
Text HLabel 6500 2000 2    60   Input ~ 0
SDCARD_POWER
$Comp
L GND #PWR030
U 1 1 5AE89828
P 6450 5550
F 0 "#PWR030" H 6450 5300 50  0001 C CNN
F 1 "GND" H 6450 5400 50  0000 C CNN
F 2 "" H 6450 5550 50  0001 C CNN
F 3 "" H 6450 5550 50  0001 C CNN
	1    6450 5550
	1    0    0    -1  
$EndComp
$Comp
L R R7
U 1 1 5AE8988C
P 6300 1750
F 0 "R7" V 6380 1750 50  0000 C CNN
F 1 "47K" V 6300 1750 50  0000 C CNN
F 2 "Resistors_SMD:R_0805" V 6230 1750 50  0001 C CNN
F 3 "" H 6300 1750 50  0001 C CNN
	1    6300 1750
	1    0    0    -1  
$EndComp
$Comp
L R R4
U 1 1 5AE89918
P 5700 2600
F 0 "R4" V 5780 2600 50  0000 C CNN
F 1 "47K" V 5700 2600 50  0000 C CNN
F 2 "Resistors_SMD:R_0805" V 5630 2600 50  0001 C CNN
F 3 "" H 5700 2600 50  0001 C CNN
	1    5700 2600
	1    0    0    -1  
$EndComp
$Comp
L R R5
U 1 1 5AE8994D
P 5900 2600
F 0 "R5" V 5980 2600 50  0000 C CNN
F 1 "47K" V 5900 2600 50  0000 C CNN
F 2 "Resistors_SMD:R_0805" V 5830 2600 50  0001 C CNN
F 3 "" H 5900 2600 50  0001 C CNN
	1    5900 2600
	1    0    0    -1  
$EndComp
$Comp
L R R6
U 1 1 5AE8997D
P 6100 2600
F 0 "R6" V 6180 2600 50  0000 C CNN
F 1 "47K" V 6100 2600 50  0000 C CNN
F 2 "Resistors_SMD:R_0805" V 6030 2600 50  0001 C CNN
F 3 "" H 6100 2600 50  0001 C CNN
	1    6100 2600
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 4050 3950 4100
Wire Wire Line
	3950 4100 3400 4100
Wire Wire Line
	3400 4100 3400 5850
Wire Wire Line
	3950 4600 3950 4650
Wire Wire Line
	3950 4650 3400 4650
Connection ~ 3400 4650
Wire Wire Line
	3950 5150 3950 5200
Wire Wire Line
	3950 5200 3400 5200
Connection ~ 3400 5200
Wire Wire Line
	3950 5700 3950 5750
Wire Wire Line
	3950 5750 3400 5750
Connection ~ 3400 5750
Wire Wire Line
	3500 5400 3400 5400
Connection ~ 3400 5400
Wire Wire Line
	3200 3750 3500 3750
Wire Wire Line
	3500 4300 3200 4300
Wire Wire Line
	3200 4850 3500 4850
Wire Wire Line
	4400 3750 4650 3750
Wire Wire Line
	4650 3750 4650 4450
Wire Wire Line
	4650 4450 6550 4450
Wire Wire Line
	4400 4300 4550 4300
Wire Wire Line
	4550 4300 4550 4550
Wire Wire Line
	4550 4550 6550 4550
Wire Wire Line
	4400 4850 4550 4850
Wire Wire Line
	4550 4850 4550 4750
Wire Wire Line
	4550 4750 6550 4750
Wire Wire Line
	3200 3200 5700 3200
Wire Wire Line
	4750 3200 4750 4950
Wire Wire Line
	4750 4950 6550 4950
Wire Wire Line
	6550 4850 6450 4850
Wire Wire Line
	6450 4850 6450 5550
Wire Wire Line
	6450 4650 6550 4650
Wire Wire Line
	6450 2350 6450 4650
Wire Wire Line
	6550 5050 5900 5050
Wire Wire Line
	5900 5050 5900 2750
Wire Wire Line
	6550 4350 6100 4350
Wire Wire Line
	6100 4350 6100 2750
Wire Wire Line
	5700 3200 5700 2750
Connection ~ 4750 3200
Wire Wire Line
	4750 2350 6450 2350
Wire Wire Line
	6100 2350 6100 2450
Connection ~ 5900 2350
Wire Wire Line
	5700 2450 5700 2350
Wire Wire Line
	8250 5250 8300 5250
Wire Wire Line
	8300 5250 8300 5500
Wire Wire Line
	8300 5500 5400 5500
Connection ~ 6450 5500
$Comp
L +5V #PWR031
U 1 1 5AE8A265
P 6300 1500
F 0 "#PWR031" H 6300 1350 50  0001 C CNN
F 1 "+5V" H 6300 1640 50  0000 C CNN
F 2 "" H 6300 1500 50  0001 C CNN
F 3 "" H 6300 1500 50  0001 C CNN
	1    6300 1500
	1    0    0    -1  
$EndComp
$Comp
L Q_PMOS_GSD Q1
U 1 1 5AE8A3CA
P 6000 2000
F 0 "Q1" H 6200 2050 50  0000 L CNN
F 1 "ZXMP3A13FTA" H 6200 1950 50  0000 L CNN
F 2 "TO_SOT_Packages_SMD:SOT-23" H 6200 2100 50  0001 C CNN
F 3 "" H 6000 2000 50  0001 C CNN
	1    6000 2000
	-1   0    0    1   
$EndComp
Wire Wire Line
	5900 2200 5900 2450
Wire Wire Line
	6200 2000 6500 2000
Wire Wire Line
	6300 1900 6300 2000
Connection ~ 6300 2000
Wire Wire Line
	6300 1600 6300 1500
$Comp
L +3V3 #PWR032
U 1 1 5AE8A695
P 5900 1500
F 0 "#PWR032" H 5900 1350 50  0001 C CNN
F 1 "+3V3" H 5900 1640 50  0000 C CNN
F 2 "" H 5900 1500 50  0001 C CNN
F 3 "" H 5900 1500 50  0001 C CNN
	1    5900 1500
	1    0    0    -1  
$EndComp
Wire Wire Line
	5900 1800 5900 1500
$Comp
L C C13
U 1 1 5AE8A76C
P 5650 4100
F 0 "C13" H 5675 4200 50  0000 L CNN
F 1 "1uF" H 5675 4000 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 5688 3950 50  0001 C CNN
F 3 "" H 5650 4100 50  0001 C CNN
	1    5650 4100
	0    1    1    0   
$EndComp
Wire Wire Line
	5800 4100 6450 4100
Connection ~ 6450 4100
Wire Wire Line
	5500 4100 5400 4100
Wire Wire Line
	5400 4100 5400 5500
$Comp
L VCC #PWR033
U 1 1 5AE8AE10
P 5100 2100
F 0 "#PWR033" H 5100 1950 50  0001 C CNN
F 1 "VCC" H 5100 2250 50  0000 C CNN
F 2 "" H 5100 2100 50  0001 C CNN
F 3 "" H 5100 2100 50  0001 C CNN
	1    5100 2100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5100 2100 5100 2350
Connection ~ 5700 2350
$Comp
L PWR_FLAG #FLG034
U 1 1 5AE8AEBC
P 4750 2100
F 0 "#FLG034" H 4750 2175 50  0001 C CNN
F 1 "PWR_FLAG" H 4750 2250 50  0000 C CNN
F 2 "" H 4750 2100 50  0001 C CNN
F 3 "" H 4750 2100 50  0001 C CNN
	1    4750 2100
	1    0    0    -1  
$EndComp
Wire Wire Line
	4750 2100 4750 2350
Connection ~ 5100 2350
Text Notes 4100 1800 0    60   ~ 0
Note: Vcc is the 3V3 input to the\n74AHC125S which is turned on\nand off by SDCARD_POWER\nvia the MOSFET
Connection ~ 6100 2350
$Comp
L Micro_SD_Card_Det J6
U 1 1 5AE99A4E
P 7450 4750
F 0 "J6" H 6800 5450 50  0000 C CNN
F 1 "Micro_SD_Card_Det" H 8100 5450 50  0000 R CNN
F 2 "Molex-47309-3751:microSD_Holder_Molex-47309-3751" H 9500 5450 50  0001 C CNN
F 3 "" H 7450 4850 50  0001 C CNN
	1    7450 4750
	1    0    0    -1  
$EndComp
Wire Wire Line
	6200 5150 6550 5150
Wire Wire Line
	6550 5250 6450 5250
Connection ~ 6450 5250
$EndSCHEMATC
