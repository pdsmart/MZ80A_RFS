EESchema Schematic File Version 4
LIBS:MZ80-ROMPG-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 3
Title "Sharp MZ80A Rom Filing System"
Date "2020-03-29"
Rev "2.0"
Comp ""
Comment1 "has no write signal from the motherboard)."
Comment2 "It is now possible to write into the Flash RAM (except the Monitor ROM Flash RAM which"
Comment3 "namely an additional 4Mb Flash RAM and a selectable 4Mb static RAM or 4Mb Flash RAM. "
Comment4 "Revised memory of the RFS, now 2 additional devices have been added which are optional,"
$EndDescr
$Comp
L MZ80-ROMPG-rescue:AS6C4008-55PCN-Memory_RAM U?
U 1 1 61C3440B
P 8800 4400
AR Path="/61C3440B" Ref="U?"  Part="1" 
AR Path="/61BF4B3D/61C3440B" Ref="U6"  Part="1" 
F 0 "U6" H 8800 4000 50  0000 C CNN
F 1 "AS6C4008-55PCN" H 8850 3900 39  0000 C CNN
F 2 "Package_DIP:DIP-32_W15.24mm_Socket" H 8800 4500 50  0001 C CNN
F 3 "https://www.alliancememory.com/wp-content/uploads/pdf/AS6C4008.pdf" H 8800 4500 50  0001 C CNN
	1    8800 4400
	1    0    0    -1  
$EndComp
Entry Bus Bus
	4150 2950 4250 2850
Wire Wire Line
	7550 5300 7800 5300
Wire Wire Line
	7550 5200 7800 5200
Wire Wire Line
	7550 5100 7800 5100
Wire Wire Line
	7550 4800 7800 4800
Wire Wire Line
	7550 4700 7800 4700
Wire Wire Line
	7550 4600 7800 4600
Wire Wire Line
	7550 4500 7800 4500
Wire Wire Line
	7550 4400 7800 4400
Wire Wire Line
	7550 4300 7800 4300
Wire Wire Line
	7550 4200 7800 4200
Wire Wire Line
	7550 4100 7800 4100
Wire Wire Line
	7550 4000 7800 4000
Wire Wire Line
	7550 3900 7800 3900
Wire Wire Line
	7550 3800 7800 3800
Wire Wire Line
	7550 3700 7800 3700
Wire Wire Line
	7550 3600 7800 3600
Wire Wire Line
	7550 3500 7800 3500
Entry Wire Line
	7800 4400 7900 4300
Entry Wire Line
	7800 4300 7900 4200
Entry Wire Line
	7800 4200 7900 4100
Entry Wire Line
	7800 4100 7900 4000
Entry Wire Line
	7800 4000 7900 3900
Entry Wire Line
	7800 3900 7900 3800
Entry Wire Line
	7800 3800 7900 3700
Entry Wire Line
	7800 3700 7900 3600
Entry Wire Line
	7800 3600 7900 3500
Entry Wire Line
	7800 3500 7900 3400
Wire Wire Line
	6200 4200 6350 4200
Wire Wire Line
	6200 4100 6350 4100
Wire Wire Line
	6200 4000 6350 4000
Wire Wire Line
	6200 3900 6350 3900
Wire Wire Line
	6200 3800 6350 3800
Wire Wire Line
	6200 3700 6350 3700
Wire Wire Line
	6200 3600 6350 3600
Wire Wire Line
	6200 3500 6350 3500
Entry Wire Line
	6100 3400 6200 3500
Entry Wire Line
	6100 3500 6200 3600
Entry Wire Line
	6100 3600 6200 3700
Entry Wire Line
	6100 3700 6200 3800
Entry Wire Line
	6100 3800 6200 3900
Entry Wire Line
	6100 3900 6200 4000
Entry Wire Line
	6100 4000 6200 4100
Entry Wire Line
	6100 4100 6200 4200
$Comp
L MZ80-ROMPG-rescue:SST39SF040-Memory_Flash U?
U 1 1 61C34448
P 6950 4700
AR Path="/61C34448" Ref="U?"  Part="1" 
AR Path="/61BF4B3D/61C34448" Ref="U5"  Part="1" 
F 0 "U5" H 6950 4750 50  0000 C CNN
F 1 "SST39SF040" H 7050 4600 39  0000 C CNN
F 2 "Package_DIP:DIP-32_W15.24mm_Socket" H 6950 5000 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 6950 5000 50  0001 C CNN
	1    6950 4700
	-1   0    0    -1  
$EndComp
Wire Wire Line
	5100 2550 5100 2750
Wire Wire Line
	2850 2550 2850 2750
Wire Wire Line
	1850 2350 2150 2350
Wire Wire Line
	4000 5500 4500 5500
Wire Wire Line
	4000 2250 4000 3150
Wire Wire Line
	4050 5800 4500 5800
Wire Wire Line
	4050 2350 4050 3000
Wire Wire Line
	4400 2350 4050 2350
Wire Wire Line
	5100 650  5100 950 
Wire Wire Line
	2850 650  3950 650 
Wire Wire Line
	3450 5550 3450 3250
Connection ~ 3450 5550
Wire Wire Line
	3350 5550 3450 5550
Wire Wire Line
	3350 6050 3350 5550
Wire Wire Line
	2100 6050 3350 6050
Wire Wire Line
	2100 5500 2100 6050
Wire Wire Line
	2200 5500 2100 5500
Connection ~ 2800 6000
Wire Wire Line
	2150 6000 2800 6000
Wire Wire Line
	2150 5800 2150 6000
Wire Wire Line
	2200 5800 2150 5800
Connection ~ 5100 3250
Connection ~ 3450 3250
Wire Wire Line
	3450 3250 3950 3250
Wire Wire Line
	3450 3250 2800 3250
Wire Wire Line
	3450 5600 3450 5550
Wire Wire Line
	3400 3500 3750 3500
Wire Wire Line
	3400 3600 3750 3600
Wire Wire Line
	3400 3700 3750 3700
Wire Wire Line
	3400 3800 3750 3800
Wire Wire Line
	3400 3900 3750 3900
Wire Wire Line
	3400 4000 3750 4000
Wire Wire Line
	3400 4100 3750 4100
Wire Wire Line
	3400 4200 3750 4200
Connection ~ 3450 6000
Wire Wire Line
	3450 5800 3450 6000
Wire Wire Line
	2800 6000 3450 6000
Wire Wire Line
	5100 3250 5750 3250
Wire Wire Line
	5750 5600 5750 5450
Wire Wire Line
	5100 6000 5750 6000
Wire Wire Line
	5750 6000 5750 5800
Entry Bus Bus
	1900 850  2000 750 
Wire Wire Line
	5800 1750 6000 1750
Wire Wire Line
	5800 1650 6000 1650
Wire Wire Line
	5800 1550 6000 1550
Wire Wire Line
	5800 1450 6000 1450
Wire Wire Line
	5800 1350 6000 1350
Wire Wire Line
	5800 1250 6000 1250
Wire Wire Line
	5800 1150 6000 1150
Wire Wire Line
	5800 1050 6000 1050
Wire Wire Line
	4250 2050 4400 2050
Wire Wire Line
	4250 1950 4400 1950
Wire Wire Line
	4250 1850 4400 1850
Wire Wire Line
	4250 1750 4400 1750
Wire Wire Line
	4250 1650 4400 1650
Wire Wire Line
	4250 1550 4400 1550
Wire Wire Line
	4250 1450 4400 1450
Wire Wire Line
	4250 1350 4400 1350
Wire Wire Line
	4250 1250 4400 1250
Wire Wire Line
	4250 1150 4400 1150
Wire Wire Line
	4250 1050 4400 1050
Wire Wire Line
	3550 1750 3750 1750
Wire Wire Line
	3550 1650 3750 1650
Wire Wire Line
	3550 1550 3750 1550
Wire Wire Line
	3550 1450 3750 1450
Wire Wire Line
	3550 1350 3750 1350
Wire Wire Line
	3550 1250 3750 1250
Wire Wire Line
	3550 1150 3750 1150
Wire Wire Line
	3550 1050 3750 1050
Entry Wire Line
	6000 1750 6100 1650
Entry Wire Line
	6000 1650 6100 1550
Entry Wire Line
	6000 1550 6100 1450
Entry Wire Line
	6000 1450 6100 1350
Entry Wire Line
	6000 1350 6100 1250
Entry Wire Line
	6000 1250 6100 1150
Entry Wire Line
	6000 1150 6100 1050
Entry Wire Line
	6000 1050 6100 950 
Wire Wire Line
	2850 650  2850 950 
Wire Wire Line
	5700 4200 6000 4200
Wire Wire Line
	5700 4100 6000 4100
Wire Wire Line
	5700 4000 6000 4000
Wire Wire Line
	5700 3900 6000 3900
Wire Wire Line
	5700 3800 6000 3800
Wire Wire Line
	5700 3700 6000 3700
Wire Wire Line
	5700 3600 6000 3600
Wire Wire Line
	5700 3500 6000 3500
Text Label 5800 1750 0    39   ~ 0
UD7
Text Label 5800 1650 0    39   ~ 0
UD6
Text Label 5800 1550 0    39   ~ 0
UD5
Text Label 5800 1450 0    39   ~ 0
UD4
Text Label 5800 1350 0    39   ~ 0
UD3
Text Label 5800 1250 0    39   ~ 0
UD2
Text Label 5800 1150 0    39   ~ 0
UD1
Text Label 5800 1050 0    39   ~ 0
UD0
Wire Wire Line
	3450 6100 3450 6000
$Comp
L power:GNDPWR #PWR?
U 1 1 61C344D2
P 3450 6100
AR Path="/61C344D2" Ref="#PWR?"  Part="1" 
AR Path="/61BF4B3D/61C344D2" Ref="#PWR04"  Part="1" 
F 0 "#PWR04" H 3450 5900 50  0001 C CNN
F 1 "GNDPWR" H 3650 6050 39  0000 C CNN
F 2 "" H 3450 6050 50  0001 C CNN
F 3 "" H 3450 6050 50  0001 C CNN
	1    3450 6100
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 61C344D8
P 2850 650
AR Path="/61C344D8" Ref="#PWR?"  Part="1" 
AR Path="/61BF4B3D/61C344D8" Ref="#PWR02"  Part="1" 
F 0 "#PWR02" H 2850 500 50  0001 C CNN
F 1 "+5V" H 2865 823 50  0000 C CNN
F 2 "" H 2850 650 50  0001 C CNN
F 3 "" H 2850 650 50  0001 C CNN
	1    2850 650 
	1    0    0    -1  
$EndComp
Wire Wire Line
	1850 5700 2200 5700
$Comp
L Device:C_Small C?
U 1 1 61C344F1
P 5750 5700
AR Path="/61C344F1" Ref="C?"  Part="1" 
AR Path="/61BF4B3D/61C344F1" Ref="C2"  Part="1" 
F 0 "C2" H 5850 5650 39  0000 L CNN
F 1 "100nF" H 5750 5600 39  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 5750 5700 50  0001 C CNN
F 3 "~" H 5750 5700 50  0001 C CNN
	1    5750 5700
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C?
U 1 1 61C344F7
P 3450 5700
AR Path="/61C344F7" Ref="C?"  Part="1" 
AR Path="/61BF4B3D/61C344F7" Ref="C1"  Part="1" 
F 0 "C1" H 3550 5650 39  0000 L CNN
F 1 "100nF" H 3450 5600 39  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 3450 5700 50  0001 C CNN
F 3 "~" H 3450 5700 50  0001 C CNN
	1    3450 5700
	1    0    0    -1  
$EndComp
Connection ~ 5100 6000
Text Label 5850 4200 0    39   ~ 0
UD7
Text Label 5850 4100 0    39   ~ 0
UD6
Text Label 5850 4000 0    39   ~ 0
UD5
Text Label 5850 3900 0    39   ~ 0
UD4
Text Label 5850 3800 0    39   ~ 0
UD3
Text Label 5850 3700 0    39   ~ 0
UD2
Text Label 5850 3600 0    39   ~ 0
UD1
Text Label 5850 3500 0    39   ~ 0
UD0
Text Label 3600 4200 0    39   ~ 0
RD7
Text Label 3600 4100 0    39   ~ 0
RD6
Text Label 3600 4000 0    39   ~ 0
RD5
Text Label 3600 3900 0    39   ~ 0
RD4
Text Label 3600 3800 0    39   ~ 0
RD3
Text Label 3600 3700 0    39   ~ 0
RD2
Text Label 3600 3600 0    39   ~ 0
RD1
Text Label 3600 3500 0    39   ~ 0
RD0
Text Label 4300 5300 0    39   ~ 0
BK2A18
Text Label 4300 5200 0    39   ~ 0
BK2A17
Text Label 4300 5100 0    39   ~ 0
BK2A16
Text Label 4300 5000 0    39   ~ 0
BK2A15
Text Label 4300 4900 0    39   ~ 0
BK2A14
Text Label 4300 4800 0    39   ~ 0
BK2A13
Text Label 4300 4700 0    39   ~ 0
BK2A12
Text Label 4300 4600 0    39   ~ 0
BK2A11
Text Label 4350 4500 0    39   ~ 0
UA10
Text Label 4350 4400 0    39   ~ 0
UA9
Text Label 4350 4300 0    39   ~ 0
UA8
Text Label 4350 4200 0    39   ~ 0
UA7
Text Label 4350 4100 0    39   ~ 0
UA6
Text Label 4350 4000 0    39   ~ 0
UA5
Text Label 4350 3900 0    39   ~ 0
UA4
Text Label 4350 3800 0    39   ~ 0
UA3
Text Label 4350 3700 0    39   ~ 0
UA2
Text Label 4350 3600 0    39   ~ 0
UA1
Text Label 4350 3500 0    39   ~ 0
UA0
Text Label 2100 4600 0    39   ~ 0
A11
Text Label 2100 4500 0    39   ~ 0
A10
Text Label 2100 4400 0    39   ~ 0
A9
Text Label 2100 4300 0    39   ~ 0
A8
Text Label 2100 4200 0    39   ~ 0
A7
Text Label 2100 4100 0    39   ~ 0
A6
Text Label 2100 4000 0    39   ~ 0
A5
Text Label 2100 3900 0    39   ~ 0
A4
Text Label 2100 3800 0    39   ~ 0
A3
Text Label 2100 3700 0    39   ~ 0
A2
Text Label 2100 3600 0    39   ~ 0
A1
Text Label 2100 3500 0    39   ~ 0
A0
Wire Wire Line
	5100 6000 5100 5950
Wire Wire Line
	2800 5950 2800 6000
Wire Wire Line
	5100 3250 5100 3350
Wire Wire Line
	2800 3350 2800 3250
Wire Wire Line
	4250 5300 4500 5300
Wire Wire Line
	4250 5200 4500 5200
Wire Wire Line
	4250 5100 4500 5100
Wire Wire Line
	4250 5000 4500 5000
Wire Wire Line
	4250 4900 4500 4900
Wire Wire Line
	4250 4800 4500 4800
Wire Wire Line
	4250 4700 4500 4700
Wire Wire Line
	4250 4600 4500 4600
Wire Wire Line
	4250 4500 4500 4500
Wire Wire Line
	4250 4400 4500 4400
Wire Wire Line
	4250 4300 4500 4300
Wire Wire Line
	4250 4200 4500 4200
Wire Wire Line
	4250 4100 4500 4100
Wire Wire Line
	4250 4000 4500 4000
Wire Wire Line
	4250 3900 4500 3900
Wire Wire Line
	4250 3800 4500 3800
Wire Wire Line
	4250 3700 4500 3700
Wire Wire Line
	4250 3600 4500 3600
Wire Wire Line
	4250 3500 4500 3500
Entry Wire Line
	4150 4400 4250 4500
Entry Wire Line
	4150 4300 4250 4400
Entry Wire Line
	4150 4200 4250 4300
Entry Wire Line
	4150 4100 4250 4200
Entry Wire Line
	4150 4000 4250 4100
Entry Wire Line
	4150 3900 4250 4000
Entry Wire Line
	4150 3800 4250 3900
Entry Wire Line
	4150 3700 4250 3800
Entry Wire Line
	4150 3600 4250 3700
Entry Wire Line
	4150 3500 4250 3600
Entry Wire Line
	4150 3400 4250 3500
Wire Wire Line
	2000 4500 2200 4500
Wire Wire Line
	2000 4400 2200 4400
Wire Wire Line
	2000 4300 2200 4300
Wire Wire Line
	2000 4200 2200 4200
Wire Wire Line
	2000 4100 2200 4100
Wire Wire Line
	2000 4000 2200 4000
Wire Wire Line
	2000 3900 2200 3900
Wire Wire Line
	2000 3800 2200 3800
Wire Wire Line
	2000 3700 2200 3700
Wire Wire Line
	2000 3600 2200 3600
Wire Wire Line
	2000 3500 2200 3500
Entry Wire Line
	1900 4400 2000 4500
Entry Wire Line
	1900 4300 2000 4400
Entry Wire Line
	1900 4200 2000 4300
Entry Wire Line
	1900 4100 2000 4200
Entry Wire Line
	1900 4000 2000 4100
Entry Wire Line
	1900 3900 2000 4000
Entry Wire Line
	1900 3800 2000 3900
Entry Wire Line
	1900 3700 2000 3800
Entry Wire Line
	1900 3600 2000 3700
Entry Wire Line
	1900 3500 2000 3600
Entry Wire Line
	1900 3400 2000 3500
Entry Wire Line
	6000 4200 6100 4100
Entry Wire Line
	6000 4100 6100 4000
Entry Wire Line
	6000 4000 6100 3900
Entry Wire Line
	6000 3900 6100 3800
Entry Wire Line
	6000 3800 6100 3700
Entry Wire Line
	6000 3700 6100 3600
Entry Wire Line
	6000 3600 6100 3500
Entry Wire Line
	6000 3500 6100 3400
Entry Wire Line
	3750 4200 3850 4100
Entry Wire Line
	3750 4100 3850 4000
Entry Wire Line
	3750 4000 3850 3900
Entry Wire Line
	3750 3900 3850 3800
Entry Wire Line
	3750 3800 3850 3700
Entry Wire Line
	3750 3700 3850 3600
Entry Wire Line
	3750 3600 3850 3500
Entry Wire Line
	3750 3500 3850 3400
$Comp
L MZ80-ROMPG-rescue:SST39SF040-Memory_Flash U?
U 1 1 61C345A8
P 5100 4700
AR Path="/61C345A8" Ref="U?"  Part="1" 
AR Path="/61BF4B3D/61C345A8" Ref="U4"  Part="1" 
F 0 "U4" H 5100 4750 50  0000 C CNN
F 1 "SST39SF040" H 5200 4600 39  0000 C CNN
F 2 "Package_DIP:DIP-32_W15.24mm_Socket" H 5100 5000 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 5100 5000 50  0001 C CNN
	1    5100 4700
	1    0    0    -1  
$EndComp
$Comp
L MZ80-ROMPG-rescue:SST39SF040-Memory_Flash U?
U 1 1 61C345AE
P 2800 4700
AR Path="/61C345AE" Ref="U?"  Part="1" 
AR Path="/61BF4B3D/61C345AE" Ref="U1"  Part="1" 
F 0 "U1" H 2800 4750 50  0000 C CNN
F 1 "SST39SF040" H 2850 4600 39  0000 C CNN
F 2 "Package_DIP:DIP-32_W15.24mm_Socket" H 2800 5000 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 2800 5000 50  0001 C CNN
	1    2800 4700
	1    0    0    -1  
$EndComp
Text Label 3550 1750 0    39   ~ 0
RD7
Text Label 3550 1650 0    39   ~ 0
RD6
Text Label 3550 1550 0    39   ~ 0
RD5
Text Label 3550 1450 0    39   ~ 0
RD4
Text Label 3550 1350 0    39   ~ 0
RD3
Text Label 3550 1250 0    39   ~ 0
RD2
Text Label 3550 1150 0    39   ~ 0
RD1
Text Label 3550 1050 0    39   ~ 0
RD0
Text Label 2100 2150 0    39   ~ 0
A11
Text Label 2100 2050 0    39   ~ 0
A10
Text Label 2100 1950 0    39   ~ 0
A9
Text Label 2100 1850 0    39   ~ 0
A8
Text Label 2100 1750 0    39   ~ 0
A7
Text Label 2100 1650 0    39   ~ 0
A6
Text Label 2100 1550 0    39   ~ 0
A5
Text Label 2100 1450 0    39   ~ 0
A4
Text Label 2100 1350 0    39   ~ 0
A3
Text Label 2100 1250 0    39   ~ 0
A2
Text Label 2100 1150 0    39   ~ 0
A1
Text Label 2100 1050 0    39   ~ 0
A0
Text Label 2000 2350 0    39   ~ 0
~CSMROM~
Text Label 4250 2350 0    39   ~ 0
~MRD~
Text Label 4250 2250 0    39   ~ 0
~MWR~
NoConn ~ 2150 2450
Wire Wire Line
	2000 2150 2150 2150
Wire Wire Line
	2000 2050 2150 2050
Wire Wire Line
	2000 1950 2150 1950
Wire Wire Line
	2000 1850 2150 1850
Wire Wire Line
	2000 1750 2150 1750
Wire Wire Line
	2000 1650 2150 1650
Wire Wire Line
	2000 1550 2150 1550
Wire Wire Line
	2000 1450 2150 1450
Wire Wire Line
	2000 1350 2150 1350
Wire Wire Line
	2000 1250 2150 1250
Wire Wire Line
	2000 1150 2150 1150
Wire Wire Line
	2000 1050 2150 1050
Entry Wire Line
	1900 2050 2000 2150
Entry Wire Line
	1900 1950 2000 2050
Entry Wire Line
	1900 1850 2000 1950
Entry Wire Line
	1900 1750 2000 1850
Entry Wire Line
	1900 1650 2000 1750
Entry Wire Line
	1900 1550 2000 1650
Entry Wire Line
	1900 1450 2000 1550
Entry Wire Line
	1900 1350 2000 1450
Entry Wire Line
	1900 1250 2000 1350
Entry Wire Line
	1900 1150 2000 1250
Entry Wire Line
	1900 1050 2000 1150
Entry Wire Line
	1900 950  2000 1050
$Comp
L Memory_EEPROM:2716_Socket U?
U 1 1 61C345E5
P 5100 1750
AR Path="/61C345E5" Ref="U?"  Part="1" 
AR Path="/61BF4B3D/61C345E5" Ref="U3"  Part="1" 
F 0 "U3" H 5100 1850 50  0000 C CNN
F 1 "(User ROM)" H 5100 1700 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W15.24mm_Socket" H 5100 1750 50  0001 C CNN
F 3 "" H 5100 1750 50  0001 C CNN
	1    5100 1750
	1    0    0    -1  
$EndComp
$Comp
L Memory_EEPROM:2732_Socket U?
U 1 1 61C345EB
P 2850 1750
AR Path="/61C345EB" Ref="U?"  Part="1" 
AR Path="/61BF4B3D/61C345EB" Ref="U2"  Part="1" 
F 0 "U2" H 2850 1850 50  0000 C CNN
F 1 "(Monitor ROM)" H 2850 1700 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W15.24mm_Socket" H 2850 1750 50  0001 C CNN
F 3 "" H 2850 1750 50  0001 C CNN
	1    2850 1750
	1    0    0    -1  
$EndComp
Text Label 4300 2050 0    39   ~ 0
UA10
Text Label 4300 1950 0    39   ~ 0
UA9
Text Label 4300 1850 0    39   ~ 0
UA8
Text Label 4300 1750 0    39   ~ 0
UA7
Text Label 4300 1650 0    39   ~ 0
UA6
Text Label 4300 1550 0    39   ~ 0
UA5
Text Label 4300 1450 0    39   ~ 0
UA4
Text Label 4300 1350 0    39   ~ 0
UA3
Text Label 4300 1250 0    39   ~ 0
UA2
Text Label 4300 1150 0    39   ~ 0
UA1
Text Label 4300 1050 0    39   ~ 0
UA0
Entry Wire Line
	7900 3400 8000 3500
Entry Wire Line
	7900 3500 8000 3600
Entry Wire Line
	7900 3600 8000 3700
Entry Wire Line
	7900 3700 8000 3800
Entry Wire Line
	7900 3800 8000 3900
Entry Wire Line
	7900 3900 8000 4000
Entry Wire Line
	7900 4000 8000 4100
Entry Wire Line
	7900 4100 8000 4200
Entry Wire Line
	7900 4200 8000 4300
Entry Wire Line
	7900 4300 8000 4400
Wire Wire Line
	8000 3500 8300 3500
Wire Wire Line
	8000 3600 8300 3600
Wire Wire Line
	8000 3700 8300 3700
Wire Wire Line
	8000 3800 8300 3800
Wire Wire Line
	8000 3900 8300 3900
Wire Wire Line
	8000 4000 8300 4000
Wire Wire Line
	8000 4100 8300 4100
Wire Wire Line
	8000 4200 8300 4200
Wire Wire Line
	8000 4300 8300 4300
Wire Wire Line
	8000 4400 8300 4400
Wire Wire Line
	8000 4500 8300 4500
Wire Wire Line
	8000 4600 8300 4600
$Comp
L Device:Jumper_NC_Dual JP3
U 1 1 61EE4C9E
P 10900 5900
F 0 "JP3" V 11350 5850 39  0000 L CNN
F 1 "A14/~WE~" V 11450 5800 39  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 10900 5900 50  0001 C CNN
F 3 "~" H 10900 5900 50  0001 C CNN
	1    10900 5900
	0    1    1    0   
$EndComp
Wire Wire Line
	7550 5500 7800 5500
Wire Wire Line
	10600 6300 10600 6150
Wire Wire Line
	4000 5500 4000 6300
Wire Wire Line
	4000 6300 7800 6300
Connection ~ 4000 5500
Wire Wire Line
	7800 5500 7800 6300
$Comp
L Device:Jumper_NC_Dual JP2
U 1 1 61EDFFDD
P 10600 5900
F 0 "JP2" V 11050 5850 39  0000 L CNN
F 1 "A15/~WE~" V 11150 5800 39  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 10600 5900 50  0001 C CNN
F 3 "~" H 10600 5900 50  0001 C CNN
	1    10600 5900
	0    1    1    0   
$EndComp
Wire Wire Line
	4050 5800 4050 6350
Wire Wire Line
	4050 6350 7750 6350
Wire Wire Line
	7750 6350 7750 5800
Wire Wire Line
	7750 5800 7550 5800
Connection ~ 4050 5800
Wire Wire Line
	9500 4600 9300 4600
Connection ~ 7750 6350
Wire Wire Line
	5750 3250 6950 3250
Wire Wire Line
	6950 3250 6950 3350
Connection ~ 5750 3250
Wire Wire Line
	6950 3250 8800 3250
Wire Wire Line
	8800 3250 8800 3300
Connection ~ 6950 3250
Text Label 6250 3500 0    39   ~ 0
UD0
Text Label 6250 3600 0    39   ~ 0
UD1
Text Label 6250 3700 0    39   ~ 0
UD2
Text Label 6250 3800 0    39   ~ 0
UD3
Text Label 6250 3900 0    39   ~ 0
UD4
Text Label 6250 4000 0    39   ~ 0
UD5
Text Label 6250 4100 0    39   ~ 0
UD6
Text Label 6250 4200 0    39   ~ 0
UD7
Wire Wire Line
	9300 4200 9600 4200
Wire Wire Line
	9300 4100 9600 4100
Wire Wire Line
	9300 4000 9600 4000
Wire Wire Line
	9300 3900 9600 3900
Wire Wire Line
	9300 3800 9600 3800
Wire Wire Line
	9300 3700 9600 3700
Wire Wire Line
	9300 3600 9600 3600
Wire Wire Line
	9300 3500 9600 3500
Text Label 9450 4200 0    39   ~ 0
UD7
Text Label 9450 4100 0    39   ~ 0
UD6
Text Label 9450 4000 0    39   ~ 0
UD5
Text Label 9450 3900 0    39   ~ 0
UD4
Text Label 9450 3800 0    39   ~ 0
UD3
Text Label 9450 3700 0    39   ~ 0
UD2
Text Label 9450 3600 0    39   ~ 0
UD1
Text Label 9450 3500 0    39   ~ 0
UD0
Entry Wire Line
	9600 4200 9700 4100
Entry Wire Line
	9600 4100 9700 4000
Entry Wire Line
	9600 4000 9700 3900
Entry Wire Line
	9600 3900 9700 3800
Entry Wire Line
	9600 3800 9700 3700
Entry Wire Line
	9600 3700 9700 3600
Entry Wire Line
	9600 3600 9700 3500
Entry Wire Line
	9600 3500 9700 3400
Entry Bus Bus
	9700 700  9800 600 
Text GLabel 10800 600  2    39   BiDi ~ 0
UD[0..7]
Text Label 8100 4500 0    39   ~ 0
UA10
Text Label 8100 4400 0    39   ~ 0
UA9
Text Label 8100 4300 0    39   ~ 0
UA8
Text Label 8100 4200 0    39   ~ 0
UA7
Text Label 8100 4100 0    39   ~ 0
UA6
Text Label 8100 4000 0    39   ~ 0
UA5
Text Label 8100 3900 0    39   ~ 0
UA4
Text Label 8100 3800 0    39   ~ 0
UA3
Text Label 8100 3700 0    39   ~ 0
UA2
Text Label 8100 3600 0    39   ~ 0
UA1
Text Label 8100 3500 0    39   ~ 0
UA0
Text Label 7700 3500 2    39   ~ 0
UA0
Text Label 7700 3600 2    39   ~ 0
UA1
Text Label 7700 3700 2    39   ~ 0
UA2
Text Label 7700 3800 2    39   ~ 0
UA3
Text Label 7700 3900 2    39   ~ 0
UA4
Text Label 7700 4000 2    39   ~ 0
UA5
Text Label 7700 4100 2    39   ~ 0
UA6
Text Label 7700 4200 2    39   ~ 0
UA7
Text Label 7700 4300 2    39   ~ 0
UA8
Text Label 7700 4400 2    39   ~ 0
UA9
Text Label 7750 4500 2    39   ~ 0
UA10
Entry Bus Bus
	6100 700  6200 600 
Text GLabel 10850 4500 2    39   Input ~ 0
~CSRAM~
Wire Wire Line
	9300 4500 10850 4500
Text GLabel 10750 5050 2    39   Input ~ 0
~CSUFLSH2~
Text GLabel 10750 5250 2    39   Input ~ 0
~CSUFLSH1~
Wire Wire Line
	4350 5700 4500 5700
Wire Wire Line
	5750 6000 6300 6000
Wire Wire Line
	6950 6000 6950 5950
Connection ~ 5750 6000
$Comp
L Device:C_Small C?
U 1 1 62571BA9
P 6300 5700
AR Path="/62571BA9" Ref="C?"  Part="1" 
AR Path="/61BF4B3D/62571BA9" Ref="C3"  Part="1" 
F 0 "C3" H 6100 5650 39  0000 L CNN
F 1 "100nF" H 6100 5600 39  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6300 5700 50  0001 C CNN
F 3 "~" H 6300 5700 50  0001 C CNN
	1    6300 5700
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 5800 6300 6000
Connection ~ 6300 6000
Wire Wire Line
	6300 6000 6950 6000
Wire Wire Line
	6300 5600 6300 5450
Wire Wire Line
	6300 5450 5750 5450
Connection ~ 5750 5450
Wire Wire Line
	5750 5450 5750 3250
Connection ~ 6950 6000
$Comp
L Device:C_Small C?
U 1 1 6266126F
P 9800 5250
AR Path="/6266126F" Ref="C?"  Part="1" 
AR Path="/61BF4B3D/6266126F" Ref="C4"  Part="1" 
F 0 "C4" H 9600 5200 39  0000 L CNN
F 1 "100nF" H 9550 5150 39  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 9800 5250 50  0001 C CNN
F 3 "~" H 9800 5250 50  0001 C CNN
	1    9800 5250
	1    0    0    -1  
$EndComp
Wire Wire Line
	8800 5500 9800 5500
Wire Wire Line
	9800 5500 9800 5350
Wire Wire Line
	9800 5150 9800 3250
Wire Wire Line
	9800 3250 8800 3250
Connection ~ 8800 3250
Connection ~ 2850 650 
Wire Wire Line
	3950 3250 3950 650 
Connection ~ 3950 3250
Wire Wire Line
	3950 3250 5100 3250
Connection ~ 3950 650 
Wire Wire Line
	3950 650  5100 650 
$Comp
L Device:Jumper_NC_Dual JP1
U 1 1 6278E4A6
P 10300 5900
F 0 "JP1" V 10750 5850 39  0000 L CNN
F 1 "A15/A14" V 10850 5750 39  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 10300 5900 50  0001 C CNN
F 3 "~" H 10300 5900 50  0001 C CNN
	1    10300 5900
	0    1    1    0   
$EndComp
Connection ~ 7800 6300
Wire Wire Line
	10750 5900 10800 5900
Wire Wire Line
	7800 6300 10600 6300
Wire Wire Line
	10600 6300 10900 6300
Wire Wire Line
	10900 6300 10900 6150
Connection ~ 10600 6300
Wire Wire Line
	8800 6000 8800 5500
Connection ~ 8800 5500
Wire Wire Line
	7550 5700 7850 5700
Wire Wire Line
	8000 5500 8650 5500
Wire Wire Line
	8650 5500 8650 5550
Wire Wire Line
	8650 5550 10150 5550
Wire Wire Line
	10900 5550 10900 5650
Wire Wire Line
	7550 4900 7800 4900
Wire Wire Line
	7550 5000 7800 5000
Wire Wire Line
	8000 5600 10300 5600
Wire Wire Line
	10300 5600 10300 5650
Wire Wire Line
	10300 5600 10600 5600
Wire Wire Line
	10600 5600 10600 5650
Connection ~ 10300 5600
Wire Wire Line
	10150 5550 10150 6150
Wire Wire Line
	10150 6150 10300 6150
Connection ~ 10150 5550
Wire Wire Line
	10150 5550 10900 5550
Wire Wire Line
	6950 6000 8800 6000
Wire Wire Line
	10200 5900 8250 5900
Wire Wire Line
	8250 4900 8300 4900
Wire Wire Line
	10500 5900 10400 5900
Wire Wire Line
	10400 5900 10400 6200
Wire Wire Line
	10400 6200 8200 6200
Wire Wire Line
	8200 6200 8200 5000
Wire Wire Line
	8200 5000 8300 5000
Wire Wire Line
	7750 6350 9500 6350
Wire Wire Line
	9500 6350 9500 4600
$Comp
L power:GNDPWR #PWR?
U 1 1 62AD6282
P 2850 2750
AR Path="/62AD6282" Ref="#PWR?"  Part="1" 
AR Path="/61BF4B3D/62AD6282" Ref="#PWR03"  Part="1" 
F 0 "#PWR03" H 2850 2550 50  0001 C CNN
F 1 "GNDPWR" H 3050 2700 50  0000 C CNN
F 2 "" H 2850 2700 50  0001 C CNN
F 3 "" H 2850 2700 50  0001 C CNN
	1    2850 2750
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 62AF1402
P 2800 3250
AR Path="/62AF1402" Ref="#PWR?"  Part="1" 
AR Path="/61BF4B3D/62AF1402" Ref="#PWR01"  Part="1" 
F 0 "#PWR01" H 2800 3100 50  0001 C CNN
F 1 "+5V" H 2815 3423 50  0000 C CNN
F 2 "" H 2800 3250 50  0001 C CNN
F 3 "" H 2800 3250 50  0001 C CNN
	1    2800 3250
	1    0    0    -1  
$EndComp
Text GLabel 10800 2650 2    39   Output ~ 0
~CSUSR~
Wire Wire Line
	4400 2450 4350 2450
Text GLabel 10900 3000 2    39   Output ~ 0
~RD~
Text GLabel 10900 3150 2    39   Output ~ 0
~WR~
Wire Wire Line
	10900 3000 4050 3000
Connection ~ 4050 3000
Wire Wire Line
	4050 3000 4050 5800
Wire Wire Line
	10900 3150 4000 3150
Connection ~ 4000 3150
Wire Wire Line
	4000 3150 4000 5500
Wire Wire Line
	10750 5900 10750 5450
Wire Wire Line
	10750 5450 10150 5450
Wire Wire Line
	10150 5450 10150 4700
Wire Wire Line
	10150 4700 9300 4700
Wire Wire Line
	10750 5250 10050 5250
Wire Wire Line
	10050 6450 4350 6450
Wire Wire Line
	10050 5250 10050 6450
Wire Wire Line
	4350 5700 4350 6450
Wire Wire Line
	10750 5050 10000 5050
Wire Wire Line
	10000 5050 10000 6400
Wire Wire Line
	10000 6400 7850 6400
Wire Wire Line
	7850 6400 7850 5700
Text GLabel 10800 750  2    39   Output ~ 0
A[0..11]
Wire Wire Line
	8000 5300 8250 5300
Wire Wire Line
	4350 2650 10800 2650
Wire Wire Line
	4350 2450 4350 2650
Wire Wire Line
	4000 2250 4400 2250
Wire Wire Line
	8250 5200 8250 5100
Wire Wire Line
	8000 5200 8300 5200
Wire Wire Line
	8250 5100 8250 4900
Wire Wire Line
	8000 5100 8300 5100
Wire Wire Line
	8250 5300 8300 5300
Wire Wire Line
	8250 5200 8250 5900
Wire Wire Line
	8000 4700 8300 4700
Wire Wire Line
	8000 4800 8300 4800
Wire Wire Line
	1850 2350 1850 5700
Wire Wire Line
	1800 4900 2200 4900
Entry Wire Line
	1900 4500 2000 4600
Wire Wire Line
	2000 4600 2200 4600
Entry Wire Line
	1700 4600 1800 4700
Entry Wire Line
	1700 4700 1800 4800
Entry Wire Line
	1700 4800 1800 4900
Entry Wire Line
	1700 4900 1800 5000
Entry Wire Line
	1700 5000 1800 5100
Entry Wire Line
	1700 5100 1800 5200
Wire Wire Line
	1800 4700 2200 4700
Wire Wire Line
	1800 4800 2200 4800
Wire Wire Line
	1800 5000 2200 5000
Wire Wire Line
	1800 5100 2200 5100
Wire Wire Line
	1800 5200 2200 5200
Wire Wire Line
	1800 5300 2200 5300
Text Label 2000 4800 0    39   ~ 0
BK1A13
Text Label 2000 4900 0    39   ~ 0
BK1A14
Text Label 2000 5000 0    39   ~ 0
BK1A15
Text Label 2000 5100 0    39   ~ 0
BK1A16
Text Label 2000 5200 0    39   ~ 0
BK1A17
Entry Bus Bus
	1600 4400 1700 4500
Connection ~ 2850 2750
Connection ~ 2800 3250
Text GLabel 950  4400 0    39   Input ~ 0
BK1A[12..18]
Text Label 2000 4700 0    39   ~ 0
BK1A12
Entry Wire Line
	3750 1050 3850 1150
Entry Wire Line
	3750 1150 3850 1250
Entry Wire Line
	3750 1250 3850 1350
Entry Wire Line
	3750 1350 3850 1450
Entry Wire Line
	3750 1450 3850 1550
Entry Wire Line
	3750 1550 3850 1650
Entry Wire Line
	3750 1650 3850 1750
Entry Wire Line
	3750 1750 3850 1850
Entry Bus Bus
	4050 6500 4150 6400
Text Label 2000 5300 0    39   ~ 0
BK1A18
Entry Wire Line
	1700 5200 1800 5300
Text GLabel 950  6500 0    39   Input ~ 0
BK2A[11..18]
Entry Wire Line
	4150 1150 4250 1050
Entry Wire Line
	4150 1250 4250 1150
Entry Wire Line
	4150 1350 4250 1250
Entry Wire Line
	4150 1450 4250 1350
Entry Wire Line
	4150 1550 4250 1450
Entry Wire Line
	4150 1650 4250 1550
Entry Wire Line
	4150 1750 4250 1650
Entry Wire Line
	4150 1850 4250 1750
Entry Wire Line
	4150 1950 4250 1850
Entry Wire Line
	4150 2050 4250 1950
Entry Wire Line
	4150 2150 4250 2050
Wire Bus Line
	4250 2850 7800 2850
Entry Bus Bus
	7800 2850 7900 2950
Wire Bus Line
	2000 750  10800 750 
Wire Bus Line
	950  4400 1600 4400
Entry Wire Line
	4150 4700 4250 4600
Entry Wire Line
	4150 4800 4250 4700
Entry Wire Line
	4150 4900 4250 4800
Entry Wire Line
	4150 5000 4250 4900
Entry Wire Line
	4150 5100 4250 5000
Entry Wire Line
	4150 5200 4250 5100
Entry Wire Line
	4150 5300 4250 5200
Entry Wire Line
	4150 5400 4250 5300
Entry Wire Line
	7800 4500 7900 4400
Entry Wire Line
	7800 4600 7900 4700
Entry Wire Line
	7800 4700 7900 4800
Entry Wire Line
	7800 4800 7900 4900
Entry Wire Line
	7800 4900 7900 5000
Entry Wire Line
	7800 5000 7900 5100
Entry Wire Line
	7800 5100 7900 5200
Entry Wire Line
	7800 5200 7900 5300
Entry Wire Line
	7800 5300 7900 5400
Entry Wire Line
	7900 4700 8000 4600
Entry Wire Line
	7900 4400 8000 4500
Entry Wire Line
	7900 4800 8000 4700
Entry Wire Line
	7900 4900 8000 4800
Entry Wire Line
	7900 5200 8000 5100
Entry Wire Line
	7900 5300 8000 5200
Entry Wire Line
	7900 5400 8000 5300
Entry Wire Line
	7900 5600 8000 5500
Entry Wire Line
	7900 5700 8000 5600
Text Label 7800 4600 2    39   ~ 0
BK2A11
Text Label 7800 4700 2    39   ~ 0
BK2A12
Text Label 7800 4800 2    39   ~ 0
BK2A13
Text Label 7800 4900 2    39   ~ 0
BK2A14
Text Label 7800 5000 2    39   ~ 0
BK2A15
Text Label 7800 5100 2    39   ~ 0
BK2A16
Text Label 7800 5200 2    39   ~ 0
BK2A17
Text Label 7800 5300 2    39   ~ 0
BK2A18
Text Label 8050 4600 0    39   ~ 0
BK2A11
Text Label 8050 4700 0    39   ~ 0
BK2A12
Text Label 8050 4800 0    39   ~ 0
BK2A13
Text Label 8050 5100 0    39   ~ 0
BK2A16
Text Label 8050 5200 0    39   ~ 0
BK2A17
Text Label 8050 5300 0    39   ~ 0
BK2A18
Text Label 8050 5500 0    39   ~ 0
BK2A14
Text Label 8050 5600 0    39   ~ 0
BK2A15
$Bitmap
Pos 1100 7200
Scale 4.000000
Data
89 50 4E 47 0D 0A 1A 0A 00 00 00 0D 49 48 44 52 00 00 00 2D 00 00 00 2D 08 03 00 00 00 0D C4 12 
A8 00 00 00 03 73 42 49 54 08 08 08 DB E1 4F E0 00 00 00 30 50 4C 54 45 02 00 00 10 00 00 42 00 
00 BD 00 00 8C 00 00 FF 00 00 21 00 00 73 00 00 DE 00 00 EF 00 00 31 00 00 52 00 00 9C 00 00 AD 
00 00 63 00 00 CE 00 00 24 3F 4B FE 00 00 00 01 74 52 4E 53 00 40 E6 D8 66 00 00 02 31 49 44 41 
54 48 89 95 95 E1 B6 A5 20 08 85 15 41 50 51 DE FF 6D 07 AD 33 77 2A 5B 73 2E 3F EA 2C FB A2 ED 
06 39 21 3C 22 3E 97 DE 03 D2 6F 68 A4 FC 3D CC 44 F2 3D 2E 44 C4 CF E5 08 2F 42 A8 D4 CB 4A 6E 
10 9B 50 DB E2 4A B7 34 9D 46 64 B2 BD 55 8D EA 6D 21 01 A4 BA 57 E2 B9 F5 5F BD F3 62 94 5F 8A 
10 0B FD 18 1E 53 81 8C 01 53 E6 3D 0E A5 E3 DF 27 D9 37 D7 A7 FF 42 7B DA 7A 85 8F C6 84 C0 11 
2A 8C 30 64 4F 23 46 3E E9 48 E6 DF 8A BE 93 B7 72 8D 81 71 F0 F9 B4 D5 90 48 20 EC AD 9E A9 07 
06 E5 D3 43 8E BD A0 15 78 A3 2B 36 A7 2B 9E AF 72 12 2F EE 9B D7 A1 A1 62 EC A1 9F C2 23 50 21 
7C D3 11 12 A4 11 2C A6 25 9C 5D 41 D3 4D 8B 9D 11 53 B0 1A A5 2E 64 CC A4 B5 8F 57 5A 2D 78 21 
09 72 9F 56 CE D7 85 DE 8F 52 1F 43 9C 46 26 D0 09 67 23 EA 6F 70 A5 AC 84 89 8A AD 94 11 0A 3D 
E9 CC 63 ED 2A 77 77 80 12 CE 5A 8A 0D F4 C4 1E 77 B3 FD B8 90 58 32 47 CB 00 AF 4C 1E BD D0 27 
6E 0D 92 9D 5D 4F CB BA 18 5D E3 6E 04 59 8E AE 02 73 45 2A 2D D7 44 1D 00 4F D8 EE 46 50 65 D2 
AA 55 24 0B B7 A2 20 B5 4B EC 07 7D B7 5B A9 1A A5 C8 3E 49 5A 6A 46 05 B0 12 E1 91 BC DC 9B 95 
89 AB 74 96 E8 A7 BD 60 4E 02 54 D5 F4 A0 1F 4D D2 7C 0D 3C 55 6A EA 63 03 1B B3 59 CB 98 64 63 
F6 AC 09 91 AE 0F A3 8E 75 75 4D 85 BB FA 16 9F 87 26 4F 79 8C 9E 2A 31 A7 F9 5B 75 6E CF 54 37 
87 71 E6 2E 8D A7 CF D8 79 7E 5E 35 CD DF DB 0E 39 68 9B B4 E0 E4 0A 8A 1B CF 70 1F 71 3F 4A 1A 
8D D5 14 EB 36 CC 86 93 69 7B D6 41 AD 03 35 29 6E 35 B9 95 56 DB 72 6E 5C 66 DC E5 0D 6F D1 E6 
A3 B7 AF 99 19 65 4D 65 DC 4D F2 83 96 75 C7 E3 AC 0C 5A C3 C9 EE 3D F5 11 5F 0A 1C F7 63 6F 7D 
69 81 37 29 7A 16 59 8F AE CB 8F 56 BD 04 9E 5B CA 67 DB 8D F7 C9 B0 72 9E ED 86 2F FF 30 97 18 
9F 7F 96 58 FF 43 2E 48 BF 48 F9 BB F8 03 46 6A 13 C0 29 E6 4E 60 00 00 00 00 49 45 4E 44 AE 42 
60 82 
EndData
$EndBitmap
Text Notes 3000 4950 2    39   ~ 0
Monitor ROM
Text Notes 5300 4950 2    39   ~ 0
User ROM
Text Notes 7050 4950 2    39   ~ 0
User ROM II
Text Notes 9100 5050 2    39   ~ 0
User Static RAM
Wire Wire Line
	2850 2750 5100 2750
Wire Wire Line
	3450 6000 5100 6000
Wire Bus Line
	950  6500 7900 6500
Wire Bus Line
	6200 600  10800 600 
Wire Bus Line
	1700 4500 1700 5200
Wire Bus Line
	9700 700  9700 4100
Wire Bus Line
	4150 4700 4150 6400
Wire Bus Line
	7900 4700 7900 6500
Wire Bus Line
	7900 2950 7900 4400
Wire Bus Line
	6100 700  6100 4100
Wire Bus Line
	3850 1150 3850 4100
Wire Bus Line
	4150 1150 4150 4400
Wire Bus Line
	1900 850  1900 4500
$EndSCHEMATC
