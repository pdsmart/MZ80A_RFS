;--------------------------------------------------------------------------------------------------------
;-
;- Name:            RFS_Definitions.asm
;- Created:         September 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series Rom Filing System.
;-                  Definitions for the RFS including SA1510 locations.
;-
;- Credits:         
;- Copyright:       (c) 2019-23 Philip Smart <philip.smart@net2net.org>
;-
;- History:         Sep 2019  - Initial version.
;-                  May 2020  - Advent of the new RFS PCB v2.0, quite a few changes to accommodate the
;-                              additional and different hardware. The SPI is now onboard the PCB and
;-                              not using the printer interface card.
;-                  July 2020 - Updated for the tranZPUter v2.1 hardware. RFS can run with a tranZPUter
;-                              board with or without the K64 I/O processor. RFS wont use the K64
;-                              processor all operations are done by the Z80 under RFS.
;-                  March 2021- Updates to accommodate the RFS v2.1 board along with back porting TZFS
;-                              developments.
;-
;--------------------------------------------------------------------------------------------------------
;- This source file is free software: you can redistribute it and-or modify
;- it under the terms of the GNU General Public License as published
;- by the Free Software Foundation, either version 3 of the License, or
;- (at your option) any later version.
;-
;- This source file is distributed in the hope that it will be useful,
;- but WITHOUT ANY WARRANTY; without even the implied warranty of
;- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;- GNU General Public License for more details.
;-
;- You should have received a copy of the GNU General Public License
;- along with this program.  If not, see <http://www.gnu.org/licenses/>.
;--------------------------------------------------------------------------------------------------------

;-----------------------------------------------
; Features.
;-----------------------------------------------
HW_SPI_ENA              EQU     1                                        ; Set to 1 if hardware SPI is present on the RFS PCB v2 board.
SW_SPI_ENA              EQU     0                                        ; Set to 1 if software SPI is present on the RFS PCB v2 board.
PP_SPI_ENA              EQU     0                                        ; Set to 1 if using the SPI interface via the Parallel Port, ie. for RFS PCB v1 which doesnt have SPI onboard.
FUSIONX_ENA             EQU     1                                        ; Set to 1 if using RFS on the tranZPUter FusionX board.

; Debugging
ENADEBUG                EQU     0                                        ; Enable debugging logic, 1 = enable, 0 = disable

;-----------------------------------------------
; Entry/compilation start points.
;-----------------------------------------------
UROMADDR                EQU     0E800H                                   ; Start of User ROM Address space.
UROMBSTBL               EQU     UROMADDR + 020H                          ; Entry point to the bank switching table.
RFSJMPTABLE             EQU     UROMADDR + 00080H                        ; Start of jump table.
FDCROMADDR              EQU     0F000H


;-----------------------------------------------
; Common character definitions.
;-----------------------------------------------
SCROLL                  EQU     001H                                     ;Set scroll direction UP.
BELL                    EQU     007H
SPACE                   EQU     020H
TAB                     EQU     009H                                     ;TAB ACROSS (8 SPACES FOR SD-BOARD)
CR                      EQU     00DH
LF                      EQU     00AH
FF                      EQU     00CH
CS                      EQU     0CH                                      ; Clear screen
DELETE                  EQU     07FH
BACKS                   EQU     008H
SOH                     EQU     1                                        ; For XModem etc.
EOT                     EQU     4
ACK                     EQU     6
NAK                     EQU     015H
NUL                     EQU     000H
NULL                    EQU     000H
CTRL_A                  EQU     001H
CTRL_B                  EQU     002H
CTRL_C                  EQU     003H
CTRL_D                  EQU     004H
CTRL_E                  EQU     005H
CTRL_F                  EQU     006H
CTRL_G                  EQU     007H
CTRL_H                  EQU     008H
CTRL_I                  EQU     009H
CTRL_J                  EQU     00AH
CTRL_K                  EQU     00BH
CTRL_L                  EQU     00CH
CTRL_M                  EQU     00DH
CTRL_N                  EQU     00EH
CTRL_O                  EQU     00FH
CTRL_P                  EQU     010H
CTRL_Q                  EQU     011H
CTRL_R                  EQU     012H
CTRL_S                  EQU     013H
CTRL_T                  EQU     014H
CTRL_U                  EQU     015H
CTRL_V                  EQU     016H
CTRL_W                  EQU     017H
CTRL_X                  EQU     018H
CTRL_Y                  EQU     019H
CTRL_Z                  EQU     01AH
ESC                     EQU     01BH
CTRL_SLASH              EQU     01CH
CTRL_LB                 EQU     01BH
CTRL_RB                 EQU     01DH
CTRL_CAPPA              EQU     01EH
CTRL_UNDSCR             EQU     01FH
CTRL_AT                 EQU     000H
NOKEY                   EQU     0F0H
CURSRIGHT               EQU     0F1H
CURSLEFT                EQU     0F2H
CURSUP                  EQU     0F3H
CURSDOWN                EQU     0F4H
DBLZERO                 EQU     0F5H
INSERT                  EQU     0F6H
CLRKEY                  EQU     0F7H
HOMEKEY                 EQU     0F8H
BREAKKEY                EQU     0FBH
GRAPHKEY                EQU     0FCH
ALPHAKEY                EQU     0FDH


;-------------------------------------------------------
; Function entry points in the standard SA-1510 Monitor.
;-------------------------------------------------------
GETL:                   EQU     00003h
LETNL:                  EQU     00006h
NL:                     EQU     00009h
PRNTS:                  EQU     0000Ch
PRNT:                   EQU     00012h
MSG:                    EQU     00015h
MSGX:                   EQU     00018h
GETKY                   EQU     0001Bh
BRKEY                   EQU     0001Eh
?WRI                    EQU     00021h
?WRD                    EQU     00024h
?RDI                    EQU     00027h
?RDD                    EQU     0002Ah
?VRFY                   EQU     0002Dh
MELDY                   EQU     00030h
?TMST                   EQU     00033h
MONIT:                  EQU     00000h
SS:                     EQU     00089h
ST1:                    EQU     00095h
HLHEX                   EQU     00410h
_2HEX                   EQU     0041Fh
?MODE:                  EQU     0074DH
?KEY                    EQU     008CAh
PRNT3                   EQU     0096Ch
?ADCN                   EQU     00BB9h
?DACN                   EQU     00BCEh
?DSP:                   EQU     00DB5H
?BLNK                   EQU     00DA6h
?DPCT                   EQU     00DDCh
PRTHL:                  EQU     003BAh
PRTHX:                  EQU     003C3h
HEX:                    EQU     003F9h
DPCT:                   EQU     00DDCh
DLY12:                  EQU     00DA7h
DLY12A:                 EQU     00DAAh
?RSTR1:                 EQU     00EE6h
MOTOR:                  EQU     006A3H
CKSUM:                  EQU     0071AH
GAP:                    EQU     0077AH
WTAPE:                  EQU     00485H
MSTOP:                  EQU     00700H

;-----------------------------------------------
; Memory mapped ports in hardware.
;-----------------------------------------------
SCRN:                   EQU     0D000H
ARAM:                   EQU     0D800H
DSPCTL:                 EQU     0DFFFH                                   ; Screen 40/80 select register (bit 7)
KEYPA:                  EQU     0E000h
KEYPB:                  EQU     0E001h
KEYPC:                  EQU     0E002h
KEYPF:                  EQU     0E003h
CSTR:                   EQU     0E002h
CSTPT:                  EQU     0E003h
CONT0:                  EQU     0E004h
CONT1:                  EQU     0E005h
CONT2:                  EQU     0E006h
CONTF:                  EQU     0E007h
SUNDG:                  EQU     0E008h
TEMP:                   EQU     0E008h
MEMSW:                  EQU     0E00CH
MEMSWR:                 EQU     0E010H
INVDSP:                 EQU     0E014H
NRMDSP:                 EQU     0E015H
SCLDSP:                 EQU     0E200H
SCLBASE:                EQU     0E2H
BNKCTRLRST:             EQU     0EFF8H                                   ; Bank control reset, returns all registers to power up default.
BNKCTRLDIS:             EQU     0EFF9H                                   ; Disable bank control registers by resetting the coded latch.
HWSPIDATA:              EQU     0EFFBH                                   ; Hardware SPI Data register (read/write).
HWSPISTART:             EQU     0EFFCH                                   ; Start an SPI transfer.
BNKSELMROM:             EQU     0EFFDh                                   ; Select RFS Bank1 (MROM) 
BNKSELUSER:             EQU     0EFFEh                                   ; Select RFS Bank2 (User ROM)
BNKCTRL:                EQU     0EFFFH                                   ; Bank Control register (read/write).

;
; RFS v2 Control Register constants.
;
BBCLK                   EQU     1                                        ; BitBang SPI Clock.
SDCS                    EQU     2                                        ; SD Card Chip Select, active low.
BBMOSI                  EQU     4                                        ; BitBang MOSI (Master Out Serial In).
CDLTCH1                 EQU     8                                        ; Coded latch up count bit 1
CDLTCH2                 EQU     16                                       ; Coded latch up count bit 2
CDLTCH3                 EQU     32                                       ; Coded latch up count bit 3
BK2A19                  EQU     64                                       ; User ROM Device Select Bit 0 (or Address bit 19).
BK2A20                  EQU     128                                      ; User ROM Device Select Bit 1 (or Address bit 20).
                                                                         ; BK2A20 : BK2A19
                                                                         ;    0        0   = Flash RAM 0 (default).
                                                                         ;    0        1   = Flash RAM 1.
                                                                         ;    1        0   = Flasm RAM 2 or Static RAM 0.
                                                                         ;    1        1   = Reserved.`

BNKCTRLDEF              EQU     BBMOSI+SDCS+BBCLK                        ; Default on startup for the Bank Control register.

;-----------------------------------------------
; IO ports in hardware and values.
;-----------------------------------------------
SPI_OUT                 EQU     0FFH
SPI_IN                  EQU     0FEH
;
DOUT_LOW                EQU     000H
DOUT_HIGH               EQU     004H
DOUT_MASK               EQU     004H
DIN_LOW                 EQU     000H
DIN_HIGH                EQU     001H
CLOCK_LOW               EQU     000H
CLOCK_HIGH              EQU     002H
CLOCK_MASK              EQU     0FDH
CS_LOW                  EQU     000H
CS_HIGH                 EQU     001H
;
MMCFG                   EQU     060H                                     ; Memory management configuration latch.
SETXMHZ                 EQU     062H                                     ; Select the alternate clock frequency.
SET2MHZ                 EQU     064H                                     ; Select the system 2MHz clock frequency.
CLKSELRD                EQU     066H                                     ; Read clock selected setting, 0 = 2MHz, 1 = XMHz
SVCREQ                  EQU     068H                                     ; I/O Processor service request.
CPUCFG                  EQU     06CH                                     ; Version 2.2 CPU configuration register.
CPUSTATUS               EQU     06CH                                     ; Version 2.2 CPU runtime status register.
CPUINFO                 EQU     06DH                                     ; Version 2.2 CPU information register.
CPLDCFG                 EQU     06EH                                     ; Version 2.1 CPLD configuration register.
CPLDSTATUS              EQU     06EH                                     ; Version 2.1 CPLD status register.
CPLDINFO                EQU     06FH                                     ; Version 2.1 CPLD version information register.
MMIO0                   EQU     0E0H                                     ; MZ-700/MZ-800 Memory Management Set 0
MMIO1                   EQU     0E1H                                     ; MZ-700/MZ-800 Memory Management Set 1
MMIO2                   EQU     0E2H                                     ; MZ-700/MZ-800 Memory Management Set 2
MMIO3                   EQU     0E3H                                     ; MZ-700/MZ-800 Memory Management Set 3
MMIO4                   EQU     0E4H                                     ; MZ-700/MZ-800 Memory Management Set 4
MMIO5                   EQU     0E5H                                     ; MZ-700/MZ-800 Memory Management Set 5
MMIO6                   EQU     0E6H                                     ; MZ-700/MZ-800 Memory Management Set 6
MMIO7                   EQU     0E7H                                     ; MZ-700/MZ-800 Memory Management Set 7

;-----------------------------------------------
; CPLD Configuration constants.
;-----------------------------------------------
MODE_MZ80K              EQU     0                                        ; Set to MZ-80K mode.
MODE_MZ80C              EQU     1                                        ; Set to MZ-80C mode.
MODE_MZ1200             EQU     2                                        ; Set to MZ-1200 mode.
MODE_MZ80A              EQU     3                                        ; Set to MZ-80A mode (base mode on MZ-80A hardware).
MODE_MZ700              EQU     4                                        ; Set to MZ-700 mode (base mode on MZ-700 hardware).
MODE_MZ800              EQU     5                                        ; Set to MZ-800 mode.
MODE_MZ80B              EQU     6                                        ; Set to MZ-80B mode.
MODE_MZ2000             EQU     7                                        ; Set to MZ-2000 mode.
MODE_VIDEO_FPGA         EQU     8                                        ; Bit flag (bit 3) to switch CPLD into using the new FPGA video hardware.

;-----------------------------------------------
; tranZPUter SW Memory Management modes
;-----------------------------------------------
TZMM_ENIOWAIT           EQU     020H                                     ; Memory management IO Wait State enable - insert a wait state when an IO operation to E0-FF is executed.
TZMM_ORIG               EQU     000H                                     ; Original Sharp MZ80A mode, no tranZPUter features are selected except the I/O control registers (default: 0x60-063).
TZMM_BOOT               EQU     001H                                     ; Original mode but E800-EFFF is mapped to tranZPUter RAM so TZFS can be booted.
TZMM_TZFS               EQU     002H + TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-FFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected.
TZMM_TZFS2              EQU     003H + TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 1.
TZMM_TZFS3              EQU     004H + TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 2.
TZMM_TZFS4              EQU     005H + TZMM_ENIOWAIT                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 3.
TZMM_CPM                EQU     006H + TZMM_ENIOWAIT                     ; CPM main memory configuration, all memory on the tranZPUter board, 64K block 4 selected. Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
TZMM_CPM2               EQU     007H + TZMM_ENIOWAIT                     ; CPM main memory configuration, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
                                                                         ; Special case for 0000:003F (interrupt vectors) which resides in block 4, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
TZMM_COMPAT             EQU     008H + TZMM_ENIOWAIT                     ; Original mode but with main DRAM in Bank 0 to allow bootstrapping of programs from other machines such as the MZ700.
TZMM_HOSTACCESS         EQU     009H + TZMM_ENIOWAIT                     ; Mode to allow code running in Bank 0, address E800:FFFF to access host memory. Monitor ROM 0000-0FFF and Main DRAM 0x1000-0xD000, video and memory mapped I/O are on the host machine, User/Floppy ROM E800-FFFF are in tranZPUter memory. 
TZMM_MZ700_0            EQU     00AH + TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the mainboard.
TZMM_MZ700_1            EQU     00BH + TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
TZMM_MZ700_2            EQU     00CH + TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
TZMM_MZ700_3            EQU     00DH + TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
TZMM_MZ700_4            EQU     00EH + TZMM_ENIOWAIT                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
TZMM_MZ800              EQU     00FH + TZMM_ENIOWAIT                     ; MZ800 Mode - Tracks original hardware mode offering MZ700/MZ800 configurations.
TZMM_FPGA               EQU     015H + TZMM_ENIOWAIT                     ; Open up access for the K64F to the FPGA resources such as memory. All other access to RAM or mainboard is blocked.
TZMM_TZPUM              EQU     016H + TZMM_ENIOWAIT                     ; Everything in on mainboard, no access to tranZPUter memory.
TZMM_TZPU               EQU     017H + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 0 is selected.
TZMM_TZPU0              EQU     018H + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 0 is selected.
TZMM_TZPU1              EQU     019H + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 1 is selected.
TZMM_TZPU2              EQU     01AH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 2 is selected.
TZMM_TZPU3              EQU     01BH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 3 is selected.
TZMM_TZPU4              EQU     01CH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 4 is selected.
TZMM_TZPU5              EQU     01DH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 5 is selected.
TZMM_TZPU6              EQU     01EH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 6 is selected.
TZMM_TZPU7              EQU     01FH + TZMM_ENIOWAIT                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 7 is selected.

;-----------------------------------------------
; Rom File System Header (MZF)
;-----------------------------------------------
RFS_ATRB:               EQU     00000h                                   ; Code Type, 01 = Machine Code.
RFS_NAME:               EQU     00001h                                   ; Title/Name (17 bytes).
RFS_SIZE:               EQU     00012h                                   ; Size of program.
RFS_DTADR:              EQU     00014h                                   ; Load address of program.
RFS_EXADR:              EQU     00016h                                   ; Exec address of program.
RFS_COMNT:              EQU     00018h                                   ; COMMENT

;-----------------------------------------------
; Entry/compilation start points.
;-----------------------------------------------
TPSTART:                EQU     010F0h
MEMSTART:               EQU     01200h
MSTART:                 EQU     0E900h
MZFHDRSZ                EQU     128
RFSSECTSZ               EQU     256
MROMSIZE                EQU     4096
UROMSIZE                EQU     2048
FNSIZE                  EQU     17
;
; Monitor ROM Jump Table definitions.
;
MROMJMPTBL:             EQU     00070H
DIRMROM:                EQU     MROMJMPTBL + 00000H
MFINDMZF:               EQU     MROMJMPTBL + 00003H
MROMLOAD:               EQU     MROMJMPTBL + 00006H

;-----------------------------------------------
; ROM Banks, 0-7 are reserved for alternative
;            Monitor versions, CPM and RFS
;            code in MROM bank,
;            0-7 are reserved for RFS code in
;            the User ROM bank.
;            8-15 are reserved for CPM code in
;            the User ROM bank.
;-----------------------------------------------
MROMPAGES               EQU     8
USRROMPAGES             EQU     12                                       ; Monitor ROM         :  User ROM
ROMBANK0                EQU     0                                        ; MROM SA1510 40 Char :  RFS Bank 0 - Main RFS Entry point and functions.
ROMBANK1                EQU     1                                        ; MROM SA1510 80 Char :  RFS Bank 1 - Floppy disk controller and utilities.
ROMBANK2                EQU     2                                        ; CPM 2.2 CBIOS       :  RFS Bank 2 - SD Card controller and utilities.
ROMBANK3                EQU     3                                        ; RFS Utilities       :  RFS Bank 3 - Cmdline tools (Memory, Printer, Help)
ROMBANK4                EQU     4                                        ; MZ700 1Z-013A 40C   :  RFS Bank 4 - CMT Utilities.
ROMBANK5                EQU     5                                        ; MZ700-1Z-013A 80C   :  RFS Bank 5
ROMBANK6                EQU     6                                        ; MZ-80B IPL          :  RFS Bank 6
ROMBANK7                EQU     7                                        ; Free                :  RFS Bank 7 - Memory and timer test utilities.
ROMBANK8                EQU     8                                        ;                     :  CBIOS Bank 1 - Utilities
ROMBANK9                EQU     9                                        ;                     :  CBIOS Bank 2 - Screen / ANSI Terminal
ROMBANK10               EQU     10                                       ;                     :  CBIOS Bank 3 - SD Card
ROMBANK11               EQU     11                                       ;                     :  CBIOS Bank 4 - Floppy disk controller.


; MMC/SD command (SPI mode)
CMD0                    EQU     64 + 0                                   ; GO_IDLE_STATE 
CMD1                    EQU     64 + 1                                   ; SEND_OP_COND 
ACMD41                  EQU     0x40+41                                  ; SEND_OP_COND (SDC) 
CMD8                    EQU     64 + 8                                   ; SEND_IF_COND 
CMD9                    EQU     64 + 9                                   ; SEND_CSD 
CMD10                   EQU     64 + 10                                  ; SEND_CID 
CMD12                   EQU     64 + 12                                  ; STOP_TRANSMISSION 
CMD13                   EQU     64 + 13                                  ; SEND_STATUS 
ACMD13                  EQU     0x40+13                                  ; SD_STATUS (SDC) 
CMD16                   EQU     64 + 16                                  ; SET_BLOCKLEN 
CMD17                   EQU     64 + 17                                  ; READ_SINGLE_BLOCK 
CMD18                   EQU     64 + 18                                  ; READ_MULTIPLE_BLOCK 
CMD23                   EQU     64 + 23                                  ; SET_BLOCK_COUNT 
ACMD23                  EQU     0x40+23                                  ; SET_WR_BLK_ERASE_COUNT (SDC)
CMD24                   EQU     64 + 24                                  ; WRITE_BLOCK 
CMD25                   EQU     64 + 25                                  ; WRITE_MULTIPLE_BLOCK 
CMD32                   EQU     64 + 32                                  ; ERASE_ER_BLK_START 
CMD33                   EQU     64 + 33                                  ; ERASE_ER_BLK_END 
CMD38                   EQU     64 + 38                                  ; ERASE 
CMD55                   EQU     64 + 55                                  ; APP_CMD 
CMD58                   EQU     64 + 58                                  ; READ_OCR 
SD_SECSIZE              EQU     512                                      ; Default size of an SD Sector 
SD_RETRIES              EQU     00100H                                   ; Number of retries before giving up.

; Card type flags (CardType)
CT_MMC                  EQU     001H                                     ; MMC ver 3 
CT_SD1                  EQU     002H                                     ; SD ver 1 
CT_SD2                  EQU     004H                                     ; SD ver 2 
CT_SDC                  EQU     CT_SD1|CT_SD2                            ; SD 
CT_BLOCK                EQU     008H                                     ; Block addressing 

; SD Card Directory structure. The directory entries are based on the MZF Header format and constraints.
;
; FLAG1  | FLAG2  | FILE NAME | START SECTOR | SIZE    | LOAD ADDR | EXEC ADDR | RESERVED
; 1 Byte | 1 Byte | 17 Bytes  | 2 Bytes      | 2 Bytes | 2 Bytes   | 2 Bytes   | 5 Bytes
;
; FLAG1        : BIT 7 = 1, Valid directory entry, 0 = inactive.
; FLAG2        : MZF Execution Code, 0x01 = Binary
; FILENAME     : Standard MZF format filename.
; START SECTOR : Sector in the SD card where the program starts. It always starts at position 0 of the sector.
; SIZE         : Size in bytes of the program. Each file block occupies 64Kbyte space (as per a tape) and this
;                parameter provides the actual space occupied by the program at the current time.
; LOAD ADDR    : Start address in memory where data should be loaded.
; EXEC ADDR    : If a binary then this parameter specifies the location to auto execute once loaded. 
; RESERVED     : Not used at the moemnt.
SDDIR_FLAG1             EQU     000H
SDDIR_FLAG2             EQU     001H
SDDIR_FILEN             EQU     002H
SDDIR_SSEC              EQU     013H
SDDIR_SIZE              EQU     015H
SDDIR_LOAD              EQU     017H
SDDIR_EXEC              EQU     019H
SDDIR_FNSZ              EQU     FNSIZE
SDDIR_ENTSZ             EQU     32

;
; Rom Filing System constants for the SD Card.
;
SDDIR_DIRENT            EQU     256                                      ; Directory entries in the RFS directory.
SDDIR_DIRENTSZ          EQU     32                                       ; Size of a directory entry.
SDDIR_DIRSIZE           EQU     SDDIR_DIRENT * SDDIR_DIRENTSZ            ; Total size of the directory.
SDDIR_BLOCKSZ           EQU     65536                                    ; Size of a file block per directory entry.
SDDIR_IMGSZ             EQU     SDDIR_DIRSIZE + (SDDIR_DIRENT * SDDIR_BLOCKSZ) ; Total size of the RFS image.

OBJCD                   EQU     001H                                     ; MZF contains a binary object.
BTX1CD                  EQU     002H                                     ; MZF contains an MZ-80K/80A BASIC program.
BTX2CD                  EQU     005H                                     ; MZF contains an MZ-700/800 BASIC program.
BTX3CD                  EQU     07EH                                     ; MZF contains a NASCOM Cassette BASIC program.
BTX4CD                  EQU     07FH                                     ; MZF contains a NASCOM ASCII TEXT BASIC program.
TZOBJCD0                EQU     0F8H                                     ; MZF contains a TZFS binary object for page 0.
TZOBJCD1                EQU     0F9H
TZOBJCD2                EQU     0FAH
TZOBJCD3                EQU     0FBH
TZOBJCD4                EQU     0FCH
TZOBJCD5                EQU     0FDH
TZOBJCD6                EQU     0FEH
TZOBJCD7                EQU     0FFH                                     ; MZF contains a TZFS binary object for page 7.

;-----------------------------------------------
;    SA-1510 MONITOR WORK AREA (MZ80A)
;-----------------------------------------------
STACK:                  EQU     010F0H
;
                        ORG     STACK
;
SPV:
IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
ATRB:                   DS      virtual 1                                ; ATTRIBUTE
NAME:                   DS      virtual FNSIZE                           ; FILE NAME
SIZE:                   DS      virtual 2                                ; BYTESIZE
DTADR:                  DS      virtual 2                                ; DATA ADDRESS
EXADR:                  DS      virtual 2                                ; EXECUTION ADDRESS
COMNT:                  DS      virtual 92                               ; COMMENT
SWPW:                   DS      virtual 10                               ; SWEEP WORK
KDATW:                  DS      virtual 2                                ; KEY WORK
KANAF:                  DS      virtual 1                                ; KANA FLAG (01=GRAPHIC MODE)
DSPXY:                  DS      virtual 2                                ; DISPLAY COORDINATES
MANG:                   DS      virtual 6                                ; COLUMN MANAGEMENT
MANGE:                  DS      virtual 1                                ; COLUMN MANAGEMENT END
PBIAS:                  DS      virtual 1                                ; PAGE BIAS
ROLTOP:                 DS      virtual 1                                ; ROLL TOP BIAS
MGPNT:                  DS      virtual 1                                ; COLUMN MANAG. POINTER
PAGETP:                 DS      virtual 2                                ; PAGE TOP
ROLEND:                 DS      virtual 1                                ; ROLL END
                        DS      virtual 14                               ; BIAS
FLASH:                  DS      virtual 1                                ; FLASHING DATA
SFTLK:                  DS      virtual 1                                ; SHIFT LOCK
REVFLG:                 DS      virtual 1                                ; REVERSE FLAG
SPAGE:                  DS      virtual 1                                ; PAGE CHANGE
FLSDT:                  DS      virtual 1                                ; CURSOR DATA
STRGF:                  DS      virtual 1                                ; STRING FLAG
DPRNT:                  DS      virtual 1                                ; TAB COUNTER
TMCNT:                  DS      virtual 2                                ; TAPE MARK COUNTER
SUMDT:                  DS      virtual 2                                ; CHECK SUM DATA
CSMDT:                  DS      virtual 2                                ; FOR COMPARE SUM DATA
AMPM:                   DS      virtual 1                                ; AMPM DATA
TIMFG:                  DS      virtual 1                                ; TIME FLAG
SWRK:                   DS      virtual 1                                ; KEY SOUND FLAG
TEMPW:                  DS      virtual 1                                ; TEMPO WORK
ONTYO:                  DS      virtual 1                                ; ONTYO WORK
OCTV:                   DS      virtual 1                                ; OCTAVE WORK
RATIO:                  DS      virtual 2                                ; ONPU RATIO
BUFER:                  DS      virtual 81                               ; GET LINE BUFFER

; Starting 1000H - Generally unused bytes not cleared by the monitor.
ROMBK1:                 EQU     01016H                                   ; CURRENT MROM BANK 
ROMBK2:                 EQU     01017H                                   ; CURRENT USERROM BANK 
WRKROMBK1:              EQU     01018H                                   ; WORKING MROM BANK 
WRKROMBK2:              EQU     01019H                                   ; WORKING USERROM BANK 
ROMCTL:                 EQU     0101AH                                   ; Current Bank control register setting.
SCRNMODE:               EQU     0101BH                                   ; Mode of screen, 0 = 40 char, 1 = 80 char.
TMPADR:                 EQU     0101CH                                   ; TEMPORARY ADDRESS STORAGE
TMPSIZE:                EQU     0101EH                                   ; TEMPORARY SIZE
TMPCNT:                 EQU     01020H                                   ; TEMPORARY COUNTER
TMPLINECNT:             EQU     01022H                                   ; Temporary counter for displayed lines.
TMPSTACKP:              EQU     01024H                                   ; Temporary stack pointer save.
SDVER:                  EQU     01026H
SDCAP:                  EQU     01027H
SDDRIVENO               EQU     01028H                                   ; RFS SDCFS Active Drive Number
CMTFILENO               EQU     01029H                                   ; Next Sequential file number to read when file request given without name.
TZPU:                   EQU     0102AH                                   ; Tranzputer present flag (0 = not present, > 0 = present and version number).
; Variables sharing the BUFER buffer, normally the BUFER is only used to get keyboard input and so long as data in BUFER is processed
; before calling the CMT/SD commands and not inbetween there shouldnt be any issue. Also the space used is at the top end of the buffer which is not used so often.
; This frees up memory needed by the CMT and SD card.
SECTORBUF:              EQU     0CE00H                                   ; Working buffer to place an SD card sector.
SDSTARTSEC              EQU     BUFER+50+0                               ; Starting sector of data to read/write from/to SD card.
SDLOADADDR              EQU     BUFER+50+4                               ; Address to read/write data from/to SD card.
SDLOADSIZE              EQU     BUFER+50+6                               ; Total remaining byte count data to read/write from/to SD card.
SDAUTOEXEC              EQU     BUFER+50+8                               ; Flag to indicate if a loaded image should be executed (=0xFF)
SDBUF:                  EQU     BUFER+50+9                               ; SD Card command fram buffer for the command and response storage.
DIRSECBUF:              EQU     BUFER+50+20                              ; Directory sector in cache.
DUMPADDR:               EQU     BUFER+50+22                              ; Address used by the D(ump) command so that calls without parameters go onto the next block.
CMTLOLOAD:              EQU     BUFER+50+24                              ; Flag to indicate that a tape program is loaded into hi memory then shifted to low memory after ROM pageout.
CMTCOPY:                EQU     BUFER+50+25                              ; Flag to indicate that a CMT copy operation is taking place.
CMTAUTOEXEC:            EQU     BUFER+50+26                              ; Auto execution flag, run CMT program when loaded if flag clear.
DTADRSTORE:             EQU     BUFER+50+27                              ; Backup for load address if actual load shifts to lo memory or to 0x1200 for copy.
SDCOPY:                 EQU     BUFER+50+29                              ; Flag to indicate an SD copy is taking place, either CMT->SD or SD->CMT.
RESULT:                 EQU     BUFER+50+30                              ; Result variable needed for interbank calls when a result is needed.

; Quickdisk work area
;QDPA                   EQU     01130h                                   ; QD code 1
;QDPB                   EQU     01131h                                   ; QD code 2
;QDPC                   EQU     01132h                                   ; QD header startaddress
;QDPE                   EQU     01134h                                   ; QD header length
;QDCPA                  EQU     0113Bh                                   ; QD error flag
;HDPT                   EQU     0113Ch                                   ; QD new headpoint possition
;HDPT0                  EQU     0113Dh                                   ; QD actual headpoint possition
;FNUPS                  EQU     0113Eh
;FNUPF                  EQU     01140h
;FNA                    EQU     01141h                                   ; File Number A (actual file number)
;FNB                    EQU     01142h                                   ; File Number B (next file number)
;MTF                    EQU     01143h                                   ; QD motor flag
;RTYF                   EQU     01144h
;SYNCF                  EQU     01146h                                   ; SyncFlags
;RETSP                  EQU     01147h
;BUFER                  EQU     011A3h
;QDIRBF                 EQU     0CD90h



;SPV:
;IBUFE:                                                                  ; TAPE BUFFER (128 BYTES)
;ATRB:                  DS      virtual 1                                ; Code Type, 01 = Machine Code.
;NAME:                  DS      virtual 17                               ; Title/Name (17 bytes).
;SIZE:                  DS      virtual 2                                ; Size of program.
;DTADR:                 DS      virtual 2                                ; Load address of program.
;EXADR:                 DS      virtual 2                                ; Exec address of program.
;COMNT:                 DS      virtual 104                              ; COMMENT
;KANAF:                 DS      virtual 1                                ; KANA FLAG (01=GRAPHIC MODE)
;DSPXY:                 DS      virtual 2                                ; DISPLAY COORDINATES
;MANG:                  DS      virtual 27                               ; COLUMN MANAGEMENT
;FLASH:                 DS      virtual 1                                ; FLASHING DATA
;FLPST:                 DS      virtual 2                                ; FLASHING POSITION
;FLSST:                 DS      virtual 1                                ; FLASHING STATUS
;FLSDT:                 DS      virtual 1                                ; CURSOR DATA
;STRGF:                 DS      virtual 1                                ; STRING FLAG
;DPRNT:                 DS      virtual 1                                ; TAB COUNTER
;TMCNT:                 DS      virtual 2                                ; TAPE MARK COUNTER
;SUMDT:                 DS      virtual 2                                ; CHECK SUM DATA
;CSMDT:                 DS      virtual 2                                ; FOR COMPARE SUM DATA
;AMPM:                  DS      virtual 1                                ; AMPM DATA
;TIMFG:                 DS      virtual 1                                ; TIME FLAG
;SWRK:                  DS      virtual 1                                ; KEY SOUND FLAG
;TEMPW:                 DS      virtual 1                                ; TEMPO WORK
;ONTYO:                 DS      virtual 1                                ; ONTYO WORK
;OCTV:                  DS      virtual 1                                ; OCTAVE WORK
;RATIO:                 DS      virtual 2                                ; ONPU RATIO
