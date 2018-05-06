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
Date "2018-05-06"
Rev "1_0"
Comp "https://www.domesday.com"
Comment1 "(c)2018 Simon Inns"
Comment2 "License: Attribution-ShareAlike International (CC BY-SA 4.0)"
Comment3 "EXPERIMENTAL UNTESTED DESIGN!"
Comment4 ""
$EndDescr
$Comp
L AcornCartridgeEdgeConnector J5
U 1 1 5AEEBC8D
P 6800 3550
F 0 "J5" H 7300 2300 60  0000 C CNN
F 1 "AcornCartridgeEdgeConnector" V 6550 4000 60  0000 C CNN
F 2 "Acorn Cartridge edge-connector:Acorn_Cartridge" H 6800 3550 60  0001 C CNN
F 3 "" H 6800 3550 60  0001 C CNN
	1    6800 3550
	1    0    0    -1  
$EndComp
Text GLabel 4000 1500 0    60   Input ~ 0
A7
Text GLabel 4000 1600 0    60   Input ~ 0
A5
Text GLabel 4000 1700 0    60   Input ~ 0
A3
Text GLabel 4000 1800 0    60   Input ~ 0
A1
Text GLabel 4000 2000 0    60   Input ~ 0
D6
Text GLabel 4000 2100 0    60   Input ~ 0
D4
Text GLabel 4000 2200 0    60   Input ~ 0
D2
Text GLabel 4000 2300 0    60   Input ~ 0
D0
Text GLabel 4000 2400 0    60   Input ~ 0
ADIN
Text GLabel 4000 2500 0    60   Input ~ 0
RST
Text GLabel 4000 2600 0    60   Input ~ 0
NPGFD
Text GLabel 4000 2700 0    60   Input ~ 0
NPGFC
Text GLabel 4000 2800 0    60   Input ~ 0
NIRQ
Text GLabel 4000 2900 0    60   Input ~ 0
NNMI
Text GLabel 4000 3100 0    60   Input ~ 0
R/~W
Text GLabel 4500 1500 2    60   Input ~ 0
A6
Text GLabel 4500 1600 2    60   Input ~ 0
A4
Text GLabel 4500 1700 2    60   Input ~ 0
A2
Text GLabel 4500 1800 2    60   Input ~ 0
A0
Text GLabel 4500 1900 2    60   Input ~ 0
D7
Text GLabel 4500 2000 2    60   Input ~ 0
D5
Text GLabel 4500 2100 2    60   Input ~ 0
D3
Text GLabel 4500 2200 2    60   Input ~ 0
D1
$Comp
L Conn_02x17_Odd_Even J3
U 1 1 5AEEBE05
P 4300 2300
F 0 "J3" H 4350 3200 50  0000 C CNN
F 1 "2 MHz Bus" H 4350 1400 50  0000 C CNN
F 2 "Socket_Strips:Socket_Strip_Straight_2x17_Pitch2.54mm" H 4300 2300 50  0001 C CNN
F 3 "" H 4300 2300 50  0001 C CNN
	1    4300 2300
	-1   0    0    1   
$EndComp
Text GLabel 4000 3000 0    60   Input ~ 0
2MHZE
Wire Wire Line
	4000 1900 3600 1900
Wire Wire Line
	3600 1900 3600 3400
Wire Wire Line
	4500 2300 4550 2300
Wire Wire Line
	4550 2300 4550 3250
Wire Wire Line
	4550 3250 3600 3250
Connection ~ 3600 3250
Wire Wire Line
	4500 2400 4550 2400
Connection ~ 4550 2400
Wire Wire Line
	4500 2500 4550 2500
Connection ~ 4550 2500
Wire Wire Line
	4500 2600 4550 2600
Connection ~ 4550 2600
Wire Wire Line
	4500 2700 4550 2700
Connection ~ 4550 2700
Wire Wire Line
	4500 2800 4550 2800
Connection ~ 4550 2800
Wire Wire Line
	4500 2900 4550 2900
Connection ~ 4550 2900
Wire Wire Line
	4500 3000 4550 3000
Connection ~ 4550 3000
Wire Wire Line
	4500 3100 4550 3100
Connection ~ 4550 3100
$Comp
L GND #PWR01
U 1 1 5AEEBEFE
P 3600 3400
F 0 "#PWR01" H 3600 3150 50  0001 C CNN
F 1 "GND" H 3600 3250 50  0000 C CNN
F 2 "" H 3600 3400 50  0001 C CNN
F 3 "" H 3600 3400 50  0001 C CNN
	1    3600 3400
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR02
U 1 1 5AEEBF18
P 6800 2000
F 0 "#PWR02" H 6800 1850 50  0001 C CNN
F 1 "+5V" H 6800 2140 50  0000 C CNN
F 2 "" H 6800 2000 50  0001 C CNN
F 3 "" H 6800 2000 50  0001 C CNN
	1    6800 2000
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR03
U 1 1 5AEEBF30
P 6800 5100
F 0 "#PWR03" H 6800 4850 50  0001 C CNN
F 1 "GND" H 6800 4950 50  0000 C CNN
F 2 "" H 6800 5100 50  0001 C CNN
F 3 "" H 6800 5100 50  0001 C CNN
	1    6800 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	6700 2150 6700 2050
Wire Wire Line
	6700 2050 7150 2050
Wire Wire Line
	6800 2050 6800 2000
Wire Wire Line
	6900 2050 6900 2150
Connection ~ 6800 2050
Wire Wire Line
	6700 4950 6700 5050
Wire Wire Line
	6700 5050 7200 5050
Wire Wire Line
	6800 5050 6800 5100
Wire Wire Line
	6900 5050 6900 4950
Connection ~ 6800 5050
$Comp
L Conn_01x02 J2
U 1 1 5AEEBFBD
P 3900 4100
F 0 "J2" H 3900 4200 50  0000 C CNN
F 1 "5V out" H 3900 3900 50  0000 C CNN
F 2 "Connectors_JST:JST_EH_B02B-EH-A_02x2.50mm_Straight" H 3900 4100 50  0001 C CNN
F 3 "" H 3900 4100 50  0001 C CNN
	1    3900 4100
	-1   0    0    -1  
$EndComp
Text GLabel 6050 2450 0    60   Input ~ 0
D0
Text GLabel 6050 2550 0    60   Input ~ 0
D1
Text GLabel 6050 2650 0    60   Input ~ 0
D2
Text GLabel 6050 2750 0    60   Input ~ 0
D3
Text GLabel 6050 2850 0    60   Input ~ 0
D4
Text GLabel 6050 2950 0    60   Input ~ 0
D5
Text GLabel 6050 3050 0    60   Input ~ 0
D6
Text GLabel 6050 3150 0    60   Input ~ 0
D7
Text GLabel 6050 3350 0    60   Input ~ 0
A0
Text GLabel 6050 3450 0    60   Input ~ 0
A1
Text GLabel 6050 3550 0    60   Input ~ 0
A2
Text GLabel 6050 3650 0    60   Input ~ 0
A3
Text GLabel 6050 3750 0    60   Input ~ 0
A4
Text GLabel 6050 3850 0    60   Input ~ 0
A5
Text GLabel 6050 3950 0    60   Input ~ 0
A6
Text GLabel 6050 4050 0    60   Input ~ 0
A7
NoConn ~ 6050 4150
NoConn ~ 6050 4250
NoConn ~ 6050 4350
NoConn ~ 6050 4450
NoConn ~ 6050 4550
NoConn ~ 6050 4650
Text GLabel 7550 4450 2    60   Input ~ 0
ADIN
Text GLabel 7550 3050 2    60   Input ~ 0
NPGFD
Text GLabel 7550 2950 2    60   Input ~ 0
NPGFC
Text GLabel 7550 2450 2    60   Input ~ 0
2MHZE
NoConn ~ 7550 2550
NoConn ~ 7550 3650
NoConn ~ 7550 3750
NoConn ~ 7550 3850
NoConn ~ 7550 3950
NoConn ~ 7550 4050
NoConn ~ 7550 4250
NoConn ~ 7550 4350
Text GLabel 7550 3250 2    60   Input ~ 0
RST
Text GLabel 7550 3450 2    60   Input ~ 0
NIRQ
Text GLabel 7550 3350 2    60   Input ~ 0
NNMI
Text GLabel 7550 2850 2    60   Input ~ 0
R/~W
NoConn ~ 7550 4650
NoConn ~ 7550 2750
$Comp
L +5V #PWR04
U 1 1 5AEEC327
P 4200 3900
F 0 "#PWR04" H 4200 3750 50  0001 C CNN
F 1 "+5V" H 4200 4040 50  0000 C CNN
F 2 "" H 4200 3900 50  0001 C CNN
F 3 "" H 4200 3900 50  0001 C CNN
	1    4200 3900
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR05
U 1 1 5AEEC33B
P 4200 4400
F 0 "#PWR05" H 4200 4150 50  0001 C CNN
F 1 "GND" H 4200 4250 50  0000 C CNN
F 2 "" H 4200 4400 50  0001 C CNN
F 3 "" H 4200 4400 50  0001 C CNN
	1    4200 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4100 4100 4200 4100
Wire Wire Line
	4200 4100 4200 3900
Wire Wire Line
	4100 4200 4200 4200
Wire Wire Line
	4200 4200 4200 4400
$Comp
L C C1
U 1 1 5AEEC39A
P 4400 4150
F 0 "C1" H 4425 4250 50  0000 L CNN
F 1 "100nF" H 4425 4050 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 4438 4000 50  0001 C CNN
F 3 "" H 4400 4150 50  0001 C CNN
	1    4400 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4400 4000 4400 3950
Wire Wire Line
	4400 3950 4200 3950
Connection ~ 4200 3950
Wire Wire Line
	4400 4300 4400 4350
Wire Wire Line
	4400 4350 4200 4350
Connection ~ 4200 4350
$Comp
L Conn_01x04 J4
U 1 1 5AEEC7BD
P 4650 5350
F 0 "J4" H 4650 5550 50  0000 C CNN
F 1 "USB" H 4650 5050 50  0000 C CNN
F 2 "Connectors_JST:JST_EH_B04B-EH-A_04x2.50mm_Straight" H 4650 5350 50  0001 C CNN
F 3 "" H 4650 5350 50  0001 C CNN
	1    4650 5350
	1    0    0    -1  
$EndComp
$Comp
L USB_A J1
U 1 1 5AEEC80C
P 3750 5450
F 0 "J1" H 3550 5900 50  0000 L CNN
F 1 "USB_A" H 3550 5800 50  0000 L CNN
F 2 "USB Female:Amphenol_87583-2010BLF" H 3900 5400 50  0001 C CNN
F 3 "" H 3900 5400 50  0001 C CNN
	1    3750 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	4450 5250 4050 5250
Wire Wire Line
	4450 5350 4150 5350
Wire Wire Line
	4150 5350 4150 5550
Wire Wire Line
	4150 5550 4050 5550
Wire Wire Line
	4450 5450 4050 5450
Wire Wire Line
	3750 5850 3750 5950
Wire Wire Line
	4250 5950 3650 5950
Wire Wire Line
	4250 5550 4250 6050
Wire Wire Line
	3650 5950 3650 5850
Connection ~ 3750 5950
Wire Wire Line
	4250 5550 4450 5550
$Comp
L GND #PWR06
U 1 1 5AEEC9D2
P 4250 6050
F 0 "#PWR06" H 4250 5800 50  0001 C CNN
F 1 "GND" H 4250 5900 50  0000 C CNN
F 2 "" H 4250 6050 50  0001 C CNN
F 3 "" H 4250 6050 50  0001 C CNN
	1    4250 6050
	1    0    0    -1  
$EndComp
Connection ~ 4250 5950
Text Notes 4750 5600 0    60   ~ 0
VBus\nD-\nD+\nGND
$Comp
L PWR_FLAG #FLG07
U 1 1 5AEECD4A
P 7150 2000
F 0 "#FLG07" H 7150 2075 50  0001 C CNN
F 1 "PWR_FLAG" H 7150 2150 50  0000 C CNN
F 2 "" H 7150 2000 50  0001 C CNN
F 3 "" H 7150 2000 50  0001 C CNN
	1    7150 2000
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG08
U 1 1 5AEECD88
P 7200 5100
F 0 "#FLG08" H 7200 5175 50  0001 C CNN
F 1 "PWR_FLAG" H 7200 5250 50  0000 C CNN
F 2 "" H 7200 5100 50  0001 C CNN
F 3 "" H 7200 5100 50  0001 C CNN
	1    7200 5100
	-1   0    0    1   
$EndComp
Wire Wire Line
	7200 5050 7200 5100
Connection ~ 6900 5050
Wire Wire Line
	7150 2050 7150 2000
Connection ~ 6900 2050
$Comp
L PWR_FLAG #FLG09
U 1 1 5AEECE8D
P 4250 5050
F 0 "#FLG09" H 4250 5125 50  0001 C CNN
F 1 "PWR_FLAG" H 4250 5200 50  0000 C CNN
F 2 "" H 4250 5050 50  0001 C CNN
F 3 "" H 4250 5050 50  0001 C CNN
	1    4250 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 5050 4250 5250
Connection ~ 4250 5250
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
$EndSCHEMATC
