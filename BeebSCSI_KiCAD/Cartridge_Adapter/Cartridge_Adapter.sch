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
LIBS:acorncartridgeedgeconnector
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
LIBS:Cartridge_Adapter-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "BeebSCSI - Master Cartridge Adapter"
Date "2018-05-19"
Rev "1_2"
Comp "https://www.domesday.com"
Comment1 "(c)2018 Simon Inns"
Comment2 "License: Attribution-ShareAlike International (CC BY-SA 4.0)"
Comment3 "EXPERIMENTAL UNTESTED DESIGN!"
Comment4 ""
$EndDescr
Text GLabel 1550 1700 0    60   Input ~ 0
A7
Text GLabel 1550 1800 0    60   Input ~ 0
A5
Text GLabel 1550 1900 0    60   Input ~ 0
A3
Text GLabel 1550 2000 0    60   Input ~ 0
A1
Text GLabel 1550 2200 0    60   Input ~ 0
D6
Text GLabel 1550 2300 0    60   Input ~ 0
D4
Text GLabel 1550 2400 0    60   Input ~ 0
D2
Text GLabel 1550 2500 0    60   Input ~ 0
D0
Text GLabel 1550 2600 0    60   Input ~ 0
ADIN
Text GLabel 1550 2700 0    60   Input ~ 0
RST
Text GLabel 1550 2800 0    60   Input ~ 0
NPGFD
Text GLabel 1550 2900 0    60   Input ~ 0
NPGFC
Text GLabel 1550 3000 0    60   Input ~ 0
NIRQ
Text GLabel 1550 3100 0    60   Input ~ 0
NNMI
Text GLabel 1550 3300 0    60   Input ~ 0
R/~W
Text GLabel 2050 1700 2    60   Input ~ 0
A6
Text GLabel 2050 1800 2    60   Input ~ 0
A4
Text GLabel 2050 1900 2    60   Input ~ 0
A2
Text GLabel 2050 2000 2    60   Input ~ 0
A0
Text GLabel 2050 2100 2    60   Input ~ 0
D7
Text GLabel 2050 2200 2    60   Input ~ 0
D5
Text GLabel 2050 2300 2    60   Input ~ 0
D3
Text GLabel 2050 2400 2    60   Input ~ 0
D1
$Comp
L Conn_02x17_Odd_Even J2
U 1 1 5AEEBE05
P 1850 2500
F 0 "J2" H 1900 3400 50  0000 C CNN
F 1 "2 MHz Bus" H 1900 1600 50  0000 C CNN
F 2 "Socket_Strips:Socket_Strip_Straight_2x17_Pitch2.54mm" H 1850 2500 50  0001 C CNN
F 3 "" H 1850 2500 50  0001 C CNN
	1    1850 2500
	-1   0    0    1   
$EndComp
Text GLabel 1550 3200 0    60   Input ~ 0
2MHZE
Wire Wire Line
	1550 2100 1150 2100
Wire Wire Line
	1150 2100 1150 3600
Wire Wire Line
	2050 2500 2100 2500
Wire Wire Line
	2100 2500 2100 3450
Wire Wire Line
	2100 3450 1150 3450
Connection ~ 1150 3450
Wire Wire Line
	2050 2600 2100 2600
Connection ~ 2100 2600
Wire Wire Line
	2050 2700 2100 2700
Connection ~ 2100 2700
Wire Wire Line
	2050 2800 2100 2800
Connection ~ 2100 2800
Wire Wire Line
	2050 2900 2100 2900
Connection ~ 2100 2900
Wire Wire Line
	2050 3000 2100 3000
Connection ~ 2100 3000
Wire Wire Line
	2050 3100 2100 3100
Connection ~ 2100 3100
Wire Wire Line
	2050 3200 2100 3200
Connection ~ 2100 3200
Wire Wire Line
	2050 3300 2100 3300
Connection ~ 2100 3300
$Comp
L GND #PWR01
U 1 1 5AEEBEFE
P 1150 3600
F 0 "#PWR01" H 1150 3350 50  0001 C CNN
F 1 "GND" H 1150 3450 50  0000 C CNN
F 2 "" H 1150 3600 50  0001 C CNN
F 3 "" H 1150 3600 50  0001 C CNN
	1    1150 3600
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR02
U 1 1 5AEEBF18
P 4050 1000
F 0 "#PWR02" H 4050 850 50  0001 C CNN
F 1 "+5V" H 4050 1140 50  0000 C CNN
F 2 "" H 4050 1000 50  0001 C CNN
F 3 "" H 4050 1000 50  0001 C CNN
	1    4050 1000
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR03
U 1 1 5AEEBF30
P 4050 4100
F 0 "#PWR03" H 4050 3850 50  0001 C CNN
F 1 "GND" H 4050 3950 50  0000 C CNN
F 2 "" H 4050 4100 50  0001 C CNN
F 3 "" H 4050 4100 50  0001 C CNN
	1    4050 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 1150 3950 1050
Wire Wire Line
	3800 1050 4400 1050
Wire Wire Line
	4050 1050 4050 1000
Wire Wire Line
	4150 1050 4150 1150
Connection ~ 4050 1050
Wire Wire Line
	3950 3950 3950 4050
Wire Wire Line
	3950 4050 4450 4050
Wire Wire Line
	4050 4050 4050 4100
Wire Wire Line
	4150 4050 4150 3950
Connection ~ 4050 4050
$Comp
L Conn_01x02 J5
U 1 1 5AEEBFBD
P 4050 6950
F 0 "J5" H 4050 7050 50  0000 C CNN
F 1 "5V out" H 4050 6750 50  0000 C CNN
F 2 "Connectors_JST:JST_EH_B02B-EH-A_02x2.50mm_Straight" H 4050 6950 50  0001 C CNN
F 3 "" H 4050 6950 50  0001 C CNN
	1    4050 6950
	-1   0    0    -1  
$EndComp
Text GLabel 3300 1450 0    60   Input ~ 0
D0
Text GLabel 3300 1550 0    60   Input ~ 0
D1
Text GLabel 3300 1650 0    60   Input ~ 0
D2
Text GLabel 3300 1750 0    60   Input ~ 0
D3
Text GLabel 3300 1850 0    60   Input ~ 0
D4
Text GLabel 3300 1950 0    60   Input ~ 0
D5
Text GLabel 3300 2050 0    60   Input ~ 0
D6
Text GLabel 3300 2150 0    60   Input ~ 0
D7
Text GLabel 3300 2350 0    60   Input ~ 0
A0
Text GLabel 3300 2450 0    60   Input ~ 0
A1
Text GLabel 3300 2550 0    60   Input ~ 0
A2
Text GLabel 3300 2650 0    60   Input ~ 0
A3
Text GLabel 3300 2750 0    60   Input ~ 0
A4
Text GLabel 3300 2850 0    60   Input ~ 0
A5
Text GLabel 3300 2950 0    60   Input ~ 0
A6
Text GLabel 3300 3050 0    60   Input ~ 0
A7
Text GLabel 4800 3450 2    60   Input ~ 0
ADIN
Text GLabel 4800 2050 2    60   Input ~ 0
NPGFD
Text GLabel 4800 1950 2    60   Input ~ 0
NPGFC
Text GLabel 4800 1450 2    60   Input ~ 0
2MHZE
NoConn ~ 4800 1550
NoConn ~ 4800 2750
NoConn ~ 4800 2950
NoConn ~ 4800 3050
NoConn ~ 4800 3250
NoConn ~ 4800 3350
Text GLabel 4800 2250 2    60   Input ~ 0
RST
Text GLabel 4800 2450 2    60   Input ~ 0
NIRQ
Text GLabel 4800 2350 2    60   Input ~ 0
NNMI
Text GLabel 4800 1850 2    60   Input ~ 0
R/~W
NoConn ~ 4800 3650
$Comp
L +5V #PWR04
U 1 1 5AEEC327
P 4350 6750
F 0 "#PWR04" H 4350 6600 50  0001 C CNN
F 1 "+5V" H 4350 6890 50  0000 C CNN
F 2 "" H 4350 6750 50  0001 C CNN
F 3 "" H 4350 6750 50  0001 C CNN
	1    4350 6750
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR05
U 1 1 5AEEC33B
P 4350 7250
F 0 "#PWR05" H 4350 7000 50  0001 C CNN
F 1 "GND" H 4350 7100 50  0000 C CNN
F 2 "" H 4350 7250 50  0001 C CNN
F 3 "" H 4350 7250 50  0001 C CNN
	1    4350 7250
	1    0    0    -1  
$EndComp
Wire Wire Line
	4350 6950 4250 6950
Wire Wire Line
	4350 6750 4350 6950
Wire Wire Line
	4250 7050 4350 7050
Wire Wire Line
	4350 7050 4350 7250
$Comp
L C C1
U 1 1 5AEEC39A
P 4550 7000
F 0 "C1" H 4575 7100 50  0000 L CNN
F 1 "100nF" H 4575 6900 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 4588 6850 50  0001 C CNN
F 3 "" H 4550 7000 50  0001 C CNN
	1    4550 7000
	1    0    0    -1  
$EndComp
Wire Wire Line
	4550 6850 4550 6800
Wire Wire Line
	4550 6800 4350 6800
Connection ~ 4350 6800
Wire Wire Line
	4550 7150 4550 7200
Wire Wire Line
	4550 7200 4350 7200
Connection ~ 4350 7200
$Comp
L Conn_01x04 J3
U 1 1 5AEEC7BD
P 2300 6750
F 0 "J3" H 2300 6950 50  0000 C CNN
F 1 "USB" H 2300 6450 50  0000 C CNN
F 2 "Connectors_JST:JST_EH_B04B-EH-A_04x2.50mm_Straight" H 2300 6750 50  0001 C CNN
F 3 "" H 2300 6750 50  0001 C CNN
	1    2300 6750
	1    0    0    -1  
$EndComp
$Comp
L USB_A J1
U 1 1 5AEEC80C
P 1400 6850
F 0 "J1" H 1200 7300 50  0000 L CNN
F 1 "USB_A" H 1200 7200 50  0000 L CNN
F 2 "USB Female:Amphenol_87583-2010BLF" H 1550 6800 50  0001 C CNN
F 3 "" H 1550 6800 50  0001 C CNN
	1    1400 6850
	1    0    0    -1  
$EndComp
Wire Wire Line
	1700 6650 2100 6650
Wire Wire Line
	2100 6750 1800 6750
Wire Wire Line
	1800 6750 1800 6950
Wire Wire Line
	1800 6950 1700 6950
Wire Wire Line
	2100 6850 1700 6850
Wire Wire Line
	1400 7250 1400 7350
Wire Wire Line
	1300 7350 1900 7350
Wire Wire Line
	1900 6950 1900 7450
Wire Wire Line
	1300 7350 1300 7250
Connection ~ 1400 7350
Wire Wire Line
	1900 6950 2100 6950
$Comp
L GND #PWR06
U 1 1 5AEEC9D2
P 1900 7450
F 0 "#PWR06" H 1900 7200 50  0001 C CNN
F 1 "GND" H 1900 7300 50  0000 C CNN
F 2 "" H 1900 7450 50  0001 C CNN
F 3 "" H 1900 7450 50  0001 C CNN
	1    1900 7450
	1    0    0    -1  
$EndComp
Connection ~ 1900 7350
Text Notes 2400 7000 0    60   ~ 0
VBus\nD-\nD+\nGND
$Comp
L PWR_FLAG #FLG07
U 1 1 5AEECD4A
P 4400 1000
F 0 "#FLG07" H 4400 1075 50  0001 C CNN
F 1 "PWR_FLAG" H 4400 1150 50  0000 C CNN
F 2 "" H 4400 1000 50  0001 C CNN
F 3 "" H 4400 1000 50  0001 C CNN
	1    4400 1000
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG08
U 1 1 5AEECD88
P 4450 4100
F 0 "#FLG08" H 4450 4175 50  0001 C CNN
F 1 "PWR_FLAG" H 4450 4250 50  0000 C CNN
F 2 "" H 4450 4100 50  0001 C CNN
F 3 "" H 4450 4100 50  0001 C CNN
	1    4450 4100
	-1   0    0    1   
$EndComp
Wire Wire Line
	4450 4050 4450 4100
Connection ~ 4150 4050
Wire Wire Line
	4400 1050 4400 1000
Connection ~ 4150 1050
$Comp
L PWR_FLAG #FLG09
U 1 1 5AEECE8D
P 1900 6450
F 0 "#FLG09" H 1900 6525 50  0001 C CNN
F 1 "PWR_FLAG" H 1900 6600 50  0000 C CNN
F 2 "" H 1900 6450 50  0001 C CNN
F 3 "" H 1900 6450 50  0001 C CNN
	1    1900 6450
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 6450 1900 6650
Connection ~ 1900 6650
$Comp
L Mounting_Hole MK1
U 1 1 5AEED53B
P 5650 6750
F 0 "MK1" H 5650 6950 50  0000 C CNN
F 1 "Mounting_Hole" H 5650 6875 50  0000 C CNN
F 2 "Mounting_Holes:MountingHole_3.2mm_M3" H 5650 6750 50  0001 C CNN
F 3 "" H 5650 6750 50  0001 C CNN
	1    5650 6750
	1    0    0    -1  
$EndComp
$Comp
L Mounting_Hole MK3
U 1 1 5AEED5FB
P 6300 6750
F 0 "MK3" H 6300 6950 50  0000 C CNN
F 1 "Mounting_Hole" H 6300 6875 50  0000 C CNN
F 2 "Mounting_Holes:MountingHole_3.2mm_M3" H 6300 6750 50  0001 C CNN
F 3 "" H 6300 6750 50  0001 C CNN
	1    6300 6750
	1    0    0    -1  
$EndComp
$Comp
L Mounting_Hole MK2
U 1 1 5AEED63F
P 5650 7100
F 0 "MK2" H 5650 7300 50  0000 C CNN
F 1 "Mounting_Hole" H 5650 7225 50  0000 C CNN
F 2 "Mounting_Holes:MountingHole_3.2mm_M3" H 5650 7100 50  0001 C CNN
F 3 "" H 5650 7100 50  0001 C CNN
	1    5650 7100
	1    0    0    -1  
$EndComp
$Comp
L Mounting_Hole MK4
U 1 1 5AEED69C
P 6300 7100
F 0 "MK4" H 6300 7300 50  0000 C CNN
F 1 "Mounting_Hole" H 6300 7225 50  0000 C CNN
F 2 "Mounting_Holes:MountingHole_3.2mm_M3" H 6300 7100 50  0001 C CNN
F 3 "" H 6300 7100 50  0001 C CNN
	1    6300 7100
	1    0    0    -1  
$EndComp
$Comp
L 27C128 U2
U 1 1 5B002D01
P 9950 1900
F 0 "U2" H 9700 2900 50  0000 C CNN
F 1 "27C128" H 9950 900 50  0000 C CNN
F 2 "Housings_DIP:DIP-28_W15.24mm" H 9950 1900 50  0001 C CNN
F 3 "" H 9950 1900 50  0001 C CNN
	1    9950 1900
	1    0    0    -1  
$EndComp
$Comp
L 27C128 U3
U 1 1 5B002D87
P 9950 4050
F 0 "U3" H 9700 5050 50  0000 C CNN
F 1 "27C128" H 9950 3050 50  0000 C CNN
F 2 "Housings_DIP:DIP-28_W15.24mm" H 9950 4050 50  0001 C CNN
F 3 "" H 9950 4050 50  0001 C CNN
	1    9950 4050
	1    0    0    -1  
$EndComp
Text GLabel 3300 3150 0    60   Input ~ 0
A8
Text GLabel 3300 3250 0    60   Input ~ 0
A9
Text GLabel 3300 3350 0    60   Input ~ 0
A10
Text GLabel 3300 3450 0    60   Input ~ 0
A11
Text GLabel 3300 3550 0    60   Input ~ 0
A12
Text GLabel 3300 3650 0    60   Input ~ 0
A13
Text GLabel 9100 1000 0    60   Input ~ 0
A0
Text GLabel 9100 1100 0    60   Input ~ 0
A1
Text GLabel 9100 1200 0    60   Input ~ 0
A2
Text GLabel 9100 1300 0    60   Input ~ 0
A3
Text GLabel 9100 1400 0    60   Input ~ 0
A4
Text GLabel 9100 1500 0    60   Input ~ 0
A5
Text GLabel 9100 1600 0    60   Input ~ 0
A6
Text GLabel 9100 1700 0    60   Input ~ 0
A7
Text GLabel 9100 1800 0    60   Input ~ 0
A8
Text GLabel 9100 1900 0    60   Input ~ 0
A9
Text GLabel 9100 2000 0    60   Input ~ 0
A10
Text GLabel 9100 2100 0    60   Input ~ 0
A11
Text GLabel 9100 2200 0    60   Input ~ 0
A12
Text GLabel 9100 2300 0    60   Input ~ 0
A13
Text GLabel 9100 3150 0    60   Input ~ 0
A0
Text GLabel 9100 3250 0    60   Input ~ 0
A1
Text GLabel 9100 3350 0    60   Input ~ 0
A2
Text GLabel 9100 3450 0    60   Input ~ 0
A3
Text GLabel 9100 3550 0    60   Input ~ 0
A4
Text GLabel 9100 3650 0    60   Input ~ 0
A5
Text GLabel 9100 3750 0    60   Input ~ 0
A6
Text GLabel 9100 3850 0    60   Input ~ 0
A7
Text GLabel 9100 3950 0    60   Input ~ 0
A8
Text GLabel 9100 4050 0    60   Input ~ 0
A9
Text GLabel 9100 4150 0    60   Input ~ 0
A10
Text GLabel 9100 4250 0    60   Input ~ 0
A11
Text GLabel 9100 4350 0    60   Input ~ 0
A12
Text GLabel 9100 4450 0    60   Input ~ 0
A13
Text GLabel 10800 1000 2    60   Input ~ 0
D0
Text GLabel 10800 1100 2    60   Input ~ 0
D1
Text GLabel 10800 1200 2    60   Input ~ 0
D2
Text GLabel 10800 1300 2    60   Input ~ 0
D3
Text GLabel 10800 1400 2    60   Input ~ 0
D4
Text GLabel 10800 1500 2    60   Input ~ 0
D5
Text GLabel 10800 1600 2    60   Input ~ 0
D6
Text GLabel 10800 1700 2    60   Input ~ 0
D7
Text GLabel 10800 3150 2    60   Input ~ 0
D0
Text GLabel 10800 3250 2    60   Input ~ 0
D1
Text GLabel 10800 3350 2    60   Input ~ 0
D2
Text GLabel 10800 3450 2    60   Input ~ 0
D3
Text GLabel 10800 3550 2    60   Input ~ 0
D4
Text GLabel 10800 3650 2    60   Input ~ 0
D5
Text GLabel 10800 3750 2    60   Input ~ 0
D6
Text GLabel 10800 3850 2    60   Input ~ 0
D7
Wire Wire Line
	9100 1000 9250 1000
Wire Wire Line
	9250 1100 9100 1100
Wire Wire Line
	9100 1200 9250 1200
Wire Wire Line
	9250 1300 9100 1300
Wire Wire Line
	9100 1400 9250 1400
Wire Wire Line
	9250 1500 9100 1500
Wire Wire Line
	9100 1600 9250 1600
Wire Wire Line
	9250 1700 9100 1700
Wire Wire Line
	9100 1800 9250 1800
Wire Wire Line
	9250 1900 9100 1900
Wire Wire Line
	9100 2000 9250 2000
Wire Wire Line
	9250 2100 9100 2100
Wire Wire Line
	9100 2200 9250 2200
Wire Wire Line
	9250 2300 9100 2300
Wire Wire Line
	10650 1000 10800 1000
Wire Wire Line
	10800 1100 10650 1100
Wire Wire Line
	10650 1200 10800 1200
Wire Wire Line
	10800 1300 10650 1300
Wire Wire Line
	10650 1400 10800 1400
Wire Wire Line
	10800 1500 10650 1500
Wire Wire Line
	10650 1600 10800 1600
Wire Wire Line
	10800 1700 10650 1700
Wire Wire Line
	9100 3150 9250 3150
Wire Wire Line
	9250 3250 9100 3250
Wire Wire Line
	9100 3350 9250 3350
Wire Wire Line
	9250 3450 9100 3450
Wire Wire Line
	9100 3550 9250 3550
Wire Wire Line
	9250 3650 9100 3650
Wire Wire Line
	9100 3750 9250 3750
Wire Wire Line
	9250 3850 9100 3850
Wire Wire Line
	9100 3950 9250 3950
Wire Wire Line
	9250 4050 9100 4050
Wire Wire Line
	9100 4150 9250 4150
Wire Wire Line
	9250 4250 9100 4250
Wire Wire Line
	9100 4350 9250 4350
Wire Wire Line
	9250 4450 9100 4450
Wire Wire Line
	10650 3150 10800 3150
Wire Wire Line
	10800 3250 10650 3250
Wire Wire Line
	10650 3350 10800 3350
Wire Wire Line
	10800 3450 10650 3450
Wire Wire Line
	10650 3550 10800 3550
Wire Wire Line
	10800 3650 10650 3650
Wire Wire Line
	10650 3750 10800 3750
Wire Wire Line
	10800 3850 10650 3850
Wire Wire Line
	9250 2400 8750 2400
Wire Wire Line
	8750 2400 8750 4550
Wire Wire Line
	8750 4550 9250 4550
Wire Wire Line
	8650 4650 9250 4650
Wire Wire Line
	8650 850  8650 4650
Wire Wire Line
	9250 2500 8650 2500
Connection ~ 8650 2500
$Comp
L +5V #PWR010
U 1 1 5B004272
P 8650 850
F 0 "#PWR010" H 8650 700 50  0001 C CNN
F 1 "+5V" H 8650 990 50  0000 C CNN
F 2 "" H 8650 850 50  0001 C CNN
F 3 "" H 8650 850 50  0001 C CNN
	1    8650 850 
	1    0    0    -1  
$EndComp
$Comp
L C C2
U 1 1 5B0042A3
P 10550 2400
F 0 "C2" H 10575 2500 50  0000 L CNN
F 1 "100nF" H 10575 2300 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 10588 2250 50  0001 C CNN
F 3 "" H 10550 2400 50  0001 C CNN
	1    10550 2400
	1    0    0    -1  
$EndComp
$Comp
L C C3
U 1 1 5B00432B
P 10850 2400
F 0 "C3" H 10875 2500 50  0000 L CNN
F 1 "100nF" H 10875 2300 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 10888 2250 50  0001 C CNN
F 3 "" H 10850 2400 50  0001 C CNN
	1    10850 2400
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR011
U 1 1 5B004371
P 10550 2050
F 0 "#PWR011" H 10550 1900 50  0001 C CNN
F 1 "+5V" H 10550 2190 50  0000 C CNN
F 2 "" H 10550 2050 50  0001 C CNN
F 3 "" H 10550 2050 50  0001 C CNN
	1    10550 2050
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR012
U 1 1 5B0043A6
P 10550 2750
F 0 "#PWR012" H 10550 2500 50  0001 C CNN
F 1 "GND" H 10550 2600 50  0000 C CNN
F 2 "" H 10550 2750 50  0001 C CNN
F 3 "" H 10550 2750 50  0001 C CNN
	1    10550 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	10550 2050 10550 2250
Wire Wire Line
	10550 2550 10550 2750
Wire Wire Line
	10850 2550 10850 2650
Wire Wire Line
	10850 2650 10550 2650
Connection ~ 10550 2650
Wire Wire Line
	10850 2250 10850 2150
Wire Wire Line
	10850 2150 10550 2150
Connection ~ 10550 2150
Wire Wire Line
	9250 2800 8550 2800
Wire Wire Line
	8550 2800 8550 4950
Wire Wire Line
	8550 4950 9250 4950
$Comp
L 74LS139 U1
U 1 1 5B004873
P 7250 2100
F 0 "U1" H 7250 2200 50  0000 C CNN
F 1 "74HCT139" H 7250 2000 50  0000 C CNN
F 2 "SMD_Packages:SO-16-N" H 7250 2100 50  0001 C CNN
F 3 "" H 7250 2100 50  0001 C CNN
	1    7250 2100
	1    0    0    -1  
$EndComp
$Comp
L 74LS139 U1
U 2 1 5B0048DA
P 7250 3200
F 0 "U1" H 7250 3300 50  0000 C CNN
F 1 "74HCT139" H 7250 3100 50  0000 C CNN
F 2 "SMD_Packages:SO-16-N" H 7250 3200 50  0001 C CNN
F 3 "" H 7250 3200 50  0001 C CNN
	2    7250 3200
	1    0    0    -1  
$EndComp
Text GLabel 4800 1750 2    60   Input ~ 0
CS_R/~W
Text GLabel 6400 1850 0    60   Input ~ 0
CS_R/~W
Text GLabel 4800 2850 2    60   Input ~ 0
ROM_~QA
Text GLabel 6400 2000 0    60   Input ~ 0
ROM_~QA
Wire Wire Line
	6400 2350 5750 2350
Wire Wire Line
	5750 2250 5750 3100
$Comp
L GND #PWR013
U 1 1 5B004AEE
P 5750 3100
F 0 "#PWR013" H 5750 2850 50  0001 C CNN
F 1 "GND" H 5750 2950 50  0000 C CNN
F 2 "" H 5750 3100 50  0001 C CNN
F 3 "" H 5750 3100 50  0001 C CNN
	1    5750 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	6400 2950 5750 2950
Connection ~ 5750 2950
$Comp
L AcornCartridgeEdgeConnector J4
U 1 1 5AEEBC8D
P 4050 2550
F 0 "J4" H 4550 1300 60  0000 C CNN
F 1 "AcornCartridgeEdgeConnector" V 3800 3000 60  0000 C CNN
F 2 "Acorn Cartridge edge-connector:Acorn_Cartridge" H 4050 2550 60  0001 C CNN
F 3 "" H 4050 2550 60  0001 C CNN
	1    4050 2550
	1    0    0    -1  
$EndComp
Text GLabel 4800 2650 2    60   Input ~ 0
ROM_~OE
Text GLabel 6400 3450 0    60   Input ~ 0
ROM_~OE
Text GLabel 6400 3100 0    60   Input ~ 0
R/~W
Wire Wire Line
	8100 2200 8400 2200
Wire Wire Line
	8400 2200 8400 2700
Wire Wire Line
	8400 2700 9250 2700
Wire Wire Line
	8100 2400 8300 2400
Wire Wire Line
	8300 2400 8300 4850
Wire Wire Line
	8300 4850 9250 4850
Wire Wire Line
	8100 3100 8550 3100
Connection ~ 8550 3100
Wire Wire Line
	8100 2900 8750 2900
Connection ~ 8750 2900
NoConn ~ 8100 3500
NoConn ~ 8100 3300
NoConn ~ 8100 2000
NoConn ~ 8100 1800
$Comp
L VCC #PWR014
U 1 1 5B003B18
P 3800 1000
F 0 "#PWR014" H 3800 850 50  0001 C CNN
F 1 "VCC" H 3800 1150 50  0000 C CNN
F 2 "" H 3800 1000 50  0001 C CNN
F 3 "" H 3800 1000 50  0001 C CNN
	1    3800 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	3800 1000 3800 1050
Connection ~ 3950 1050
$Comp
L C C4
U 1 1 5B00678A
P 5750 2100
F 0 "C4" H 5775 2200 50  0000 L CNN
F 1 "100nF" H 5775 2000 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 5788 1950 50  0001 C CNN
F 3 "" H 5750 2100 50  0001 C CNN
	1    5750 2100
	1    0    0    -1  
$EndComp
Connection ~ 5750 2350
$Comp
L VCC #PWR015
U 1 1 5B006941
P 5750 1850
F 0 "#PWR015" H 5750 1700 50  0001 C CNN
F 1 "VCC" H 5750 2000 50  0000 C CNN
F 2 "" H 5750 1850 50  0001 C CNN
F 3 "" H 5750 1850 50  0001 C CNN
	1    5750 1850
	1    0    0    -1  
$EndComp
Wire Wire Line
	5750 1950 5750 1850
$EndSCHEMATC
