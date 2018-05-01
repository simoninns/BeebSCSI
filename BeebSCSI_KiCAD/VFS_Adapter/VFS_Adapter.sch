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
LIBS:VFS_Adapter-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "BeebSCSI - Internal VFS Adapter"
Date "2018-05-01"
Rev "1_5"
Comp "https://www.domesday86.com"
Comment1 "(c)2018 Simon Inns"
Comment2 "License: Attribution-ShareAlike 4.0 (CC BY-SA 4.0)"
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Conn_01x20 J1
U 1 1 5AE83177
P 2450 2050
F 0 "J1" H 2450 3050 50  0000 C CNN
F 1 "Internal 1MHz Bus" H 2450 950 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Angled_1x20_Pitch2.54mm" H 2450 2050 50  0001 C CNN
F 3 "" H 2450 2050 50  0001 C CNN
	1    2450 2050
	-1   0    0    -1  
$EndComp
Text GLabel 2750 1150 2    60   Input ~ 0
BBC_~IRQ
Text GLabel 3350 1250 2    60   Input ~ 0
BBC_~RST
Text GLabel 2750 1350 2    60   Input ~ 0
BBC_BD0
Text GLabel 3350 1450 2    60   Input ~ 0
BBC_BD1
Text GLabel 2750 1550 2    60   Input ~ 0
BBC_BD2
Text GLabel 3350 1650 2    60   Input ~ 0
BBC_BD3
Text GLabel 2750 1750 2    60   Input ~ 0
BBC_BD4
Text GLabel 3350 1850 2    60   Input ~ 0
BBC_BD5
Text GLabel 2750 1950 2    60   Input ~ 0
BBC_BD6
Text GLabel 3350 2050 2    60   Input ~ 0
BBC_BD7
Text GLabel 2750 2150 2    60   Input ~ 0
BBC_~MODEM
Text GLabel 3350 2250 2    60   Input ~ 0
BBC_A0
Text GLabel 2750 2350 2    60   Input ~ 0
BBC_A1
Text GLabel 3350 2450 2    60   Input ~ 0
BBC_A2
Text GLabel 2750 2550 2    60   Input ~ 0
BBC_A3
Text GLabel 3350 2650 2    60   Input ~ 0
BBC_1MHZE
Text GLabel 2750 2750 2    60   Input ~ 0
BBC_R/~W
Wire Wire Line
	2650 1150 2750 1150
Wire Wire Line
	2650 1250 3350 1250
Wire Wire Line
	3350 1450 2650 1450
Wire Wire Line
	2650 1650 3350 1650
Wire Wire Line
	3350 1850 2650 1850
Wire Wire Line
	2650 2050 3350 2050
Wire Wire Line
	3350 2250 2650 2250
Wire Wire Line
	2650 2450 3350 2450
Wire Wire Line
	3350 2650 2650 2650
Wire Wire Line
	2650 2750 2750 2750
Wire Wire Line
	2650 2550 2750 2550
Wire Wire Line
	2650 2350 2750 2350
Wire Wire Line
	2650 2150 2750 2150
Wire Wire Line
	2650 1950 2750 1950
Wire Wire Line
	2650 1750 2750 1750
Wire Wire Line
	2650 1550 2750 1550
Wire Wire Line
	2650 1350 2750 1350
NoConn ~ 2650 2950
$Comp
L Conn_02x17_Odd_Even J2
U 1 1 5AE83436
P 4800 5800
F 0 "J2" H 4850 6700 50  0000 C CNN
F 1 "BeebSCSI IDC" H 4850 4900 50  0000 C CNN
F 2 "Connectors_Multicomp:Multicomp_MC9A12-3434_2x17x2.54mm_Straight" H 4800 5800 50  0001 C CNN
F 3 "" H 4800 5800 50  0001 C CNN
	1    4800 5800
	-1   0    0    1   
$EndComp
Wire Wire Line
	5100 5800 5000 5800
Wire Wire Line
	5100 5000 5100 7000
Wire Wire Line
	5000 5900 5100 5900
Connection ~ 5100 5900
Wire Wire Line
	5000 6000 5100 6000
Connection ~ 5100 6000
Wire Wire Line
	5000 6100 5100 6100
Connection ~ 5100 6100
Wire Wire Line
	5000 6200 5100 6200
Connection ~ 5100 6200
Wire Wire Line
	5000 6300 5100 6300
Connection ~ 5100 6300
Wire Wire Line
	5000 6400 5100 6400
Connection ~ 5100 6400
Wire Wire Line
	5000 6500 5100 6500
Connection ~ 5100 6500
Wire Wire Line
	5000 6600 5100 6600
Connection ~ 5100 6600
$Comp
L GND #PWR01
U 1 1 5AE835E1
P 5100 7000
F 0 "#PWR01" H 5100 6750 50  0001 C CNN
F 1 "GND" H 5100 6850 50  0000 C CNN
F 2 "" H 5100 7000 50  0001 C CNN
F 3 "" H 5100 7000 50  0001 C CNN
	1    5100 7000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5000 5000 5100 5000
Connection ~ 5100 5800
Wire Wire Line
	5000 5100 5100 5100
Connection ~ 5100 5100
Wire Wire Line
	4500 5000 4400 5000
Wire Wire Line
	4400 5000 4400 6800
Wire Wire Line
	4400 6800 5100 6800
Connection ~ 5100 6800
Wire Wire Line
	4500 5100 4400 5100
Connection ~ 4400 5100
Wire Wire Line
	2650 3050 2850 3050
Wire Wire Line
	2850 3050 2850 3350
$Comp
L GND #PWR02
U 1 1 5AE8370E
P 2850 3350
F 0 "#PWR02" H 2850 3100 50  0001 C CNN
F 1 "GND" H 2850 3200 50  0000 C CNN
F 2 "" H 2850 3350 50  0001 C CNN
F 3 "" H 2850 3350 50  0001 C CNN
	1    2850 3350
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR03
U 1 1 5AE83726
P 4100 2600
F 0 "#PWR03" H 4100 2450 50  0001 C CNN
F 1 "+5V" H 4100 2740 50  0000 C CNN
F 2 "" H 4100 2600 50  0001 C CNN
F 3 "" H 4100 2600 50  0001 C CNN
	1    4100 2600
	1    0    0    -1  
$EndComp
Text GLabel 4250 5800 0    60   Input ~ 0
BBC_BD0
Text GLabel 5250 5700 2    60   Input ~ 0
BBC_BD1
Text GLabel 3650 5700 0    60   Input ~ 0
BBC_BD2
Text GLabel 5750 5600 2    60   Input ~ 0
BBC_BD3
Text GLabel 4250 5600 0    60   Input ~ 0
BBC_BD4
Text GLabel 5250 5500 2    60   Input ~ 0
BBC_BD5
Text GLabel 3650 5500 0    60   Input ~ 0
BBC_BD6
Text GLabel 5750 5400 2    60   Input ~ 0
BBC_BD7
Wire Wire Line
	4250 5800 4500 5800
Wire Wire Line
	3650 5700 4500 5700
Wire Wire Line
	4250 5600 4500 5600
Wire Wire Line
	3650 5500 4500 5500
Wire Wire Line
	5250 5700 5000 5700
Wire Wire Line
	5250 5500 5000 5500
Wire Wire Line
	5750 5600 5000 5600
Wire Wire Line
	5750 5400 5000 5400
Text GLabel 4250 6300 0    60   Input ~ 0
BBC_~IRQ
Text GLabel 4250 6000 0    60   Input ~ 0
BBC_~RST
NoConn ~ 4500 6400
NoConn ~ 4500 6100
NoConn ~ 4500 5900
Wire Wire Line
	4250 6000 4500 6000
Wire Wire Line
	4250 6300 4500 6300
$Comp
L 74HC245 U1
U 1 1 5AE83B26
P 7100 2650
F 0 "U1" H 7200 3225 50  0000 L BNN
F 1 "74HC245DW" H 7150 2075 50  0000 L TNN
F 2 "Housings_SOIC:SOIC-20W_7.5x12.8mm_Pitch1.27mm" H 7100 2650 50  0001 C CNN
F 3 "" H 7100 2650 50  0001 C CNN
	1    7100 2650
	-1   0    0    -1  
$EndComp
Text GLabel 6200 2150 0    60   Input ~ 0
BBC_~MODEM
Text GLabel 5600 2250 0    60   Input ~ 0
BBC_A0
Text GLabel 6200 2350 0    60   Input ~ 0
BBC_A1
Text GLabel 5600 2450 0    60   Input ~ 0
BBC_A2
Text GLabel 6200 2550 0    60   Input ~ 0
BBC_A3
Text GLabel 5600 2650 0    60   Input ~ 0
BBC_1MHZE
Text GLabel 6200 2750 0    60   Input ~ 0
BBC_R/~W
Wire Wire Line
	6200 2150 6400 2150
Wire Wire Line
	5600 2250 6400 2250
Wire Wire Line
	6200 2350 6400 2350
Wire Wire Line
	5600 2450 6400 2450
Wire Wire Line
	5600 2650 6400 2650
Wire Wire Line
	6200 2750 6400 2750
Wire Wire Line
	6200 2550 6400 2550
Text GLabel 8100 2150 2    60   Input ~ 0
BS_~PGFC
Text GLabel 8600 2250 2    60   Input ~ 0
BS_A0
Text GLabel 8100 2350 2    60   Input ~ 0
BS_A1
Text GLabel 8600 2450 2    60   Input ~ 0
BS_A2
Text GLabel 8100 2550 2    60   Input ~ 0
BS_A3
Text GLabel 8600 2650 2    60   Input ~ 0
BS_1MHZE
Text GLabel 8100 2750 2    60   Input ~ 0
BS_R/~W
Text GLabel 8600 2850 2    60   Input ~ 0
BS_INT/~EXT
$Comp
L GND #PWR04
U 1 1 5AE83F29
P 7900 3250
F 0 "#PWR04" H 7900 3000 50  0001 C CNN
F 1 "GND" H 7900 3100 50  0000 C CNN
F 2 "" H 7900 3250 50  0001 C CNN
F 3 "" H 7900 3250 50  0001 C CNN
	1    7900 3250
	1    0    0    -1  
$EndComp
Wire Wire Line
	7800 2150 8100 2150
Wire Wire Line
	7800 2250 8600 2250
Wire Wire Line
	7800 2350 8100 2350
Wire Wire Line
	7800 2450 8600 2450
Wire Wire Line
	7800 2550 8100 2550
Wire Wire Line
	7800 2650 8600 2650
Wire Wire Line
	7800 2750 8100 2750
Wire Wire Line
	7800 2850 8600 2850
Wire Wire Line
	7800 3050 7900 3050
Wire Wire Line
	7900 3050 7900 3250
Wire Wire Line
	7800 3150 7900 3150
Connection ~ 7900 3150
$Comp
L C C1
U 1 1 5AE84284
P 9250 4850
F 0 "C1" H 9275 4950 50  0000 L CNN
F 1 "100nF" H 9275 4750 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 9288 4700 50  0001 C CNN
F 3 "" H 9250 4850 50  0001 C CNN
	1    9250 4850
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR05
U 1 1 5AE842C0
P 9250 4600
F 0 "#PWR05" H 9250 4450 50  0001 C CNN
F 1 "+5V" H 9250 4740 50  0000 C CNN
F 2 "" H 9250 4600 50  0001 C CNN
F 3 "" H 9250 4600 50  0001 C CNN
	1    9250 4600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR06
U 1 1 5AE842D7
P 9250 5100
F 0 "#PWR06" H 9250 4850 50  0001 C CNN
F 1 "GND" H 9250 4950 50  0000 C CNN
F 2 "" H 9250 5100 50  0001 C CNN
F 3 "" H 9250 5100 50  0001 C CNN
	1    9250 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	9250 4700 9250 4600
Wire Wire Line
	9250 5000 9250 5100
Text GLabel 3650 6200 0    60   Input ~ 0
BS_~PGFC
Text GLabel 5250 5300 2    60   Input ~ 0
BS_A0
Text GLabel 3650 5300 0    60   Input ~ 0
BS_A1
Text GLabel 4250 5200 0    60   Input ~ 0
BS_A3
Text GLabel 4250 6500 0    60   Input ~ 0
BS_1MHZE
Text GLabel 3650 6600 0    60   Input ~ 0
BS_R/~W
Text GLabel 4250 5400 0    60   Input ~ 0
BS_INT/~EXT
Wire Wire Line
	4250 5200 4500 5200
Wire Wire Line
	5000 5200 5750 5200
Wire Wire Line
	5250 5300 5000 5300
Wire Wire Line
	4500 5300 3650 5300
Wire Wire Line
	4250 5400 4500 5400
Wire Wire Line
	3650 6200 4500 6200
Wire Wire Line
	4250 6500 4500 6500
Wire Wire Line
	3650 6600 4500 6600
$Comp
L Polyfuse PF1
U 1 1 5AE848B5
P 3500 2850
F 0 "PF1" V 3400 2850 50  0000 C CNN
F 1 "Polyfuse" V 3600 2850 50  0000 C CNN
F 2 "Fuse_Holders_and_Fuses:Fuse_SMD1206_HandSoldering" H 3550 2650 50  0001 L CNN
F 3 "" H 3500 2850 50  0001 C CNN
	1    3500 2850
	0    1    1    0   
$EndComp
Wire Wire Line
	2650 2850 3350 2850
Wire Wire Line
	4100 2850 3650 2850
Wire Wire Line
	4100 2600 4100 2850
$Comp
L Conn_01x02 J3
U 1 1 5AE84AD1
P 8550 4800
F 0 "J3" H 8550 4900 50  0000 C CNN
F 1 "5V out" H 8550 4600 50  0000 C CNN
F 2 "Connectors_JST:JST_EH_B02B-EH-A_02x2.50mm_Straight" H 8550 4800 50  0001 C CNN
F 3 "" H 8550 4800 50  0001 C CNN
	1    8550 4800
	-1   0    0    -1  
$EndComp
$Comp
L +5V #PWR07
U 1 1 5AE84B2B
P 8850 4600
F 0 "#PWR07" H 8850 4450 50  0001 C CNN
F 1 "+5V" H 8850 4740 50  0000 C CNN
F 2 "" H 8850 4600 50  0001 C CNN
F 3 "" H 8850 4600 50  0001 C CNN
	1    8850 4600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR08
U 1 1 5AE84B48
P 8850 5100
F 0 "#PWR08" H 8850 4850 50  0001 C CNN
F 1 "GND" H 8850 4950 50  0000 C CNN
F 2 "" H 8850 5100 50  0001 C CNN
F 3 "" H 8850 5100 50  0001 C CNN
	1    8850 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	8750 4800 8850 4800
Wire Wire Line
	8850 4800 8850 4600
Wire Wire Line
	8750 4900 8850 4900
Wire Wire Line
	8850 4900 8850 5100
Text GLabel 5750 5200 2    60   Input ~ 0
BS_A2
$Comp
L PWR_FLAG #FLG09
U 1 1 5AE84DD8
P 4400 2600
F 0 "#FLG09" H 4400 2675 50  0001 C CNN
F 1 "PWR_FLAG" H 4400 2750 50  0000 C CNN
F 2 "" H 4400 2600 50  0001 C CNN
F 3 "" H 4400 2600 50  0001 C CNN
	1    4400 2600
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG010
U 1 1 5AE84DFC
P 3150 3350
F 0 "#FLG010" H 3150 3425 50  0001 C CNN
F 1 "PWR_FLAG" H 3150 3500 50  0000 C CNN
F 2 "" H 3150 3350 50  0001 C CNN
F 3 "" H 3150 3350 50  0001 C CNN
	1    3150 3350
	-1   0    0    1   
$EndComp
Wire Wire Line
	4400 2600 4400 2700
Wire Wire Line
	4100 2700 4700 2700
Connection ~ 4100 2700
Wire Wire Line
	3150 3350 3150 3200
Wire Wire Line
	3150 3200 2850 3200
Connection ~ 2850 3200
$Comp
L VCC #PWR011
U 1 1 5AE85290
P 4700 2600
F 0 "#PWR011" H 4700 2450 50  0001 C CNN
F 1 "VCC" H 4700 2750 50  0000 C CNN
F 2 "" H 4700 2600 50  0001 C CNN
F 3 "" H 4700 2600 50  0001 C CNN
	1    4700 2600
	1    0    0    -1  
$EndComp
Wire Wire Line
	4700 2700 4700 2600
Connection ~ 4400 2700
Wire Wire Line
	6400 2850 6250 2850
Wire Wire Line
	6250 2850 6250 3100
Wire Wire Line
	6250 3100 3100 3100
Wire Wire Line
	3100 3100 3100 2850
Connection ~ 3100 2850
Text Notes 4150 1450 0    60   ~ 0
Note: D[0..7] requires 2K2 pull up and pull down\nresistors in order to be at TTL levels.  Since \nBeebSCSI provides terminating resistors, there is\nno need for them here.
Text Notes 3700 4750 0    60   ~ 0
Note: Pin 26 (0V) is used by BeebSCSI to detect if\nit is connected to the internal bus, so this board\nprovides a logic level 1 on the pin.  This board\nshould not be used with ANY other 1 Mhz bus\ndevice unless this pin is disconnected.
$Comp
L Mounting_Hole F1
U 1 1 5AE87DDA
P 6300 7200
F 0 "F1" H 6300 7400 50  0000 C CNN
F 1 "Fiducial" H 6300 7325 50  0000 C CNN
F 2 "Fiducials:Fiducial_0.5mm_Dia_1mm_Outer" H 6300 7200 50  0001 C CNN
F 3 "" H 6300 7200 50  0001 C CNN
	1    6300 7200
	1    0    0    -1  
$EndComp
$Comp
L Mounting_Hole F2
U 1 1 5AE87E3C
P 6300 7550
F 0 "F2" H 6300 7750 50  0000 C CNN
F 1 "Fiducial" H 6300 7675 50  0000 C CNN
F 2 "Fiducials:Fiducial_0.5mm_Dia_1mm_Outer" H 6300 7550 50  0001 C CNN
F 3 "" H 6300 7550 50  0001 C CNN
	1    6300 7550
	1    0    0    -1  
$EndComp
$Comp
L Mounting_Hole F3
U 1 1 5AE87E72
P 6700 7200
F 0 "F3" H 6700 7400 50  0000 C CNN
F 1 "Fiducial" H 6700 7325 50  0000 C CNN
F 2 "Fiducials:Fiducial_0.5mm_Dia_1mm_Outer" H 6700 7200 50  0001 C CNN
F 3 "" H 6700 7200 50  0001 C CNN
	1    6700 7200
	1    0    0    -1  
$EndComp
$EndSCHEMATC
