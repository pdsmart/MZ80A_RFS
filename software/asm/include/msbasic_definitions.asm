;--------------------------------------------------------------------------------------------------------
;-
;- Name:            MSBASIC_Definitions.asm
;- Created:         June 2020
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM v2.23
;-                  Definitions for the Sharp MZ80A CPM v2.23 OS used in the RFS
;-
;- Credits:         
;- Copyright:       (c) 2019-23 Philip Smart <philip.smart@net2net.org>
;-
;- History:         Jan 2020 - Initial version.
;                   May 2020 - Advent of the new RFS PCB v2.0, quite a few changes to accommodate the
;                              additional and different hardware. The SPI is now onboard the PCB and
;                              not using the printer interface card.
;                   Jun 2020 - Copied and strpped from TZFS for BASIC.
;                   Mar 2021 - Updates to run on v2.1 RFS board and provide SD card CLOAD/CSAVE and DIR
;                              along with bug fixes.
;
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

;-----------------------------------------------

;-----------------------------------------------
; Configurable settings.
;-----------------------------------------------
; Build options. Set just one to '1' the rest to '0'.
; NB: As there are now 4 versions and 1 or more need to be built, ie. MZ-80A and RFS version for RFS, a flag is set in the file
; BASIC_build.asm which configures the equates below for the correct build.
                        IF BUILD_VERSION = 0
BUILD_MZ80A               EQU   1                                        ; Build for the standard Sharp MZ80A, no lower memory. Manually change MAXMEM above.
BUILD_RFS                 EQU   0                                        ; Build for standard RFS with SD enhancements.
BUILD_RFSTZ               EQU   0                                        ; Build for RFS where the tranZPUter board is available without the K64F and running under RFS.
BUILD_TZFS                EQU   0                                        ; Build for TZFS where extended memory is available.
BUILD_80C                 EQU   0
INCLUDE_ANSITERM          EQU   1                                        ; Include the Ansi terminal emulation processor in the build.
                        ENDIF
                        IF BUILD_VERSION = 1
BUILD_MZ80A               EQU   0
BUILD_RFS                 EQU   1
BUILD_RFSTZ               EQU   0
BUILD_TZFS                EQU   0
BUILD_80C                 EQU   1
INCLUDE_ANSITERM          EQU   1                                        ; Include the Ansi terminal emulation processor in the build.
                        ENDIF
                        IF BUILD_VERSION = 2
BUILD_MZ80A               EQU   0
BUILD_RFS                 EQU   1
BUILD_RFSTZ               EQU   0
BUILD_TZFS                EQU   0
BUILD_80C                 EQU   0
INCLUDE_ANSITERM          EQU   1                                        ; Include the Ansi terminal emulation processor in the build.
                        ENDIF
                        IF BUILD_VERSION = 3
BUILD_MZ80A               EQU   0
BUILD_RFS                 EQU   0
BUILD_RFSTZ               EQU   1
BUILD_TZFS                EQU   0
BUILD_80C                 EQU   1
INCLUDE_ANSITERM          EQU   1                                        ; Include the Ansi terminal emulation processor in the build.
                        ENDIF
                        IF BUILD_VERSION = 4
BUILD_MZ80A               EQU   0
BUILD_RFS                 EQU   0
BUILD_RFSTZ               EQU   0
BUILD_TZFS                EQU   1
BUILD_80C                 EQU   1
INCLUDE_ANSITERM          EQU   1                                        ; Include the Ansi terminal emulation processor in the build.
                        ENDIF
                        IF BUILD_80C = 1
COLW:                     EQU   80                                       ; Width of the display screen (ie. columns).
                        ELSE
COLW:                     EQU   40                                       ; Width of the display screen (ie. columns).
                        ENDIF
TMRTICKINTV             EQU     5                                        ; Number of 0.010mSec ticks per interrupt, ie. resolution of RTC.
ROW:                    EQU     25                                       ; Number of rows on display screen.
SCRNSZ:                 EQU     COLW * ROW                               ; Total size, in bytes, of the screen display area.
SCRLW:                  EQU     COLW / 8                                 ; Number of 8 byte regions in a line for hardware scroll.

; BIOS equates
KEYBUFSIZE              EQU     64                                       ; Ensure this is a power of 2, max size 256.
                        IF BUILD_MZ80A = 1
MAXMEM                    EQU   0CFFFH                                   ; Top of RAM on a standard Sharp MZ80A.
                        ENDIF
                        IF BUILD_RFS = 1
MAXMEM                    EQU   0CFFFH - TZSVCSECSIZE                    ; Top of RAM on a standard RFS equipped Sharp MZ80A. Top 512 bytes used by RFS SD sector buffer.
                        ENDIF
                        IF BUILD_TZFS+BUILD_RFSTZ > 0
MAXMEM                    EQU   10000H - TZSVCSIZE                       ; Top of RAM on the tranZPUter
                        ENDIF

; Tape load/save modes. Used as a flag to enable common code.
TAPELOAD                EQU     1
CTAPELOAD               EQU     2
TAPESAVE                EQU     3
CTAPESAVE               EQU     4

; Debugging
ENADEBUG                EQU     0                                        ; Enable debugging logic, 1 = enable, 0 = disable

;-----------------------------------------------
; CMT Object types.
;-----------------------------------------------
ATR_OBJ                 EQU     1
ATR_BASIC_PROG          EQU     2
ATR_BASIC_DATA          EQU     3
ATR_SRC_FILE            EQU     4
ATR_RELOC_FILE          EQU     5
ATR_BASIC_MSCAS         EQU     07EH
ATR_BASIC_MSTXT         EQU     07FH
ATR_PASCAL_PROG         EQU     0A0H
ATR_PASCAL_DATA         EQU     0A1H
CMTATRB                 EQU     010F0H
CMTNAME                 EQU     010F1H

;-------------------------------------------------------
; Function entry points in the standard SA-1510 Monitor.
;-------------------------------------------------------
QWRI                    EQU     00021h
QWRD                    EQU     00024h
QRDI                    EQU     00027h
QRDD                    EQU     0002Ah
QVRFY                   EQU     0002Dh

;-------------------------------------------------------
; Function entry points in the RFS ROM.
;-------------------------------------------------------
CMT_RDINF               EQU     0E886H                                   ; UROMADDR+86H - Tape/SD intercept handler - Read Header
CMT_RDDATA              EQU     0E889H                                   ; UROMADDR+89H - Tape/SD intercept handler - Read Data
CMT_WRINF               EQU     0E88CH                                   ; UROMADDR+80H - Tape/SD intercept handler - Write Header
CMT_WRDATA              EQU     0E88FH                                   ; UROMADDR+8FH - Tape/SD intercept handler - Write Data
CMT_VERIFY              EQU     0E892H                                   ; UROMADDR+92H - Tape/SD intercept handler - Verify Data
CMT_DIR                 EQU     0E895H                                   ; UROMADDR+95H - SD directory command.
CNV_ATOS                EQU     0E898H                                   ; UROMADDR+98H - Convert an ASCII string into Sharp ASCII

;-----------------------------------------------
; BASIC ERROR CODE VALUES
;-----------------------------------------------
NF                      EQU     00H                                      ; NEXT without FOR
SN                      EQU     02H                                      ; Syntax error
RG                      EQU     04H                                      ; RETURN without GOSUB
OD                      EQU     06H                                      ; Out of DATA
FC                      EQU     08H                                      ; Function call error
OV                      EQU     0AH                                      ; Overflow
OM                      EQU     0CH                                      ; Out of memory
UL                      EQU     0EH                                      ; Undefined line number
BS                      EQU     10H                                      ; Bad subscript
DDA                     EQU     12H                                      ; Re-DIMensioned array
DZ                      EQU     14H                                      ; Division by zero (/0)
ID                      EQU     16H                                      ; Illegal direct
TM                      EQU     18H                                      ; Type miss-match
OS                      EQU     1AH                                      ; Out of string space
LS                      EQU     1CH                                      ; String too long
ST                      EQU     1EH                                      ; String formula too complex
CN                      EQU     20H                                      ; Can't CONTinue
UF                      EQU     22H                                      ; UnDEFined FN function
MO                      EQU     24H                                      ; Missing operand
HX                      EQU     26H                                      ; HEX error
BN                      EQU     28H                                      ; BIN error
BV                      EQU     2AH                                      ; Bad Value error
IO                      EQU     2CH                                      ; IO error

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

;-----------------------------------------------
; IO Registers
;-----------------------------------------------
FDC                     EQU     0D8h                                     ; MB8866 IO Region 0D8h - 0DBh
FDC_CR                  EQU     FDC + 000h                               ; Command Register
FDC_STR                 EQU     FDC + 000h                               ; Status Register
FDC_TR                  EQU     FDC + 001h                               ; Track Register
FDC_SCR                 EQU     FDC + 002h                               ; Sector Register
FDC_DR                  EQU     FDC + 003h                               ; Data Register
FDC_MOTOR               EQU     FDC + 004h                               ; DS[0-3] and Motor control. 4 drives  DS= BIT 0 -> Bit 2 = Drive number, 2=1,1=0,0=0 DS0, 2=1,1=0,0=1 DS1 etc
                                                                         ;  bit 7 = 1 MOTOR ON LOW (Active)
FDC_SIDE                EQU     FDC + 005h                               ; Side select, Bit 0 when set = SIDE SELECT LOW

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
;NULL                    EQU     000H
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


;-----------------------------------------------
; Rom File System variable addresses.
;-----------------------------------------------
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

;--------------------------------------------------
; RFS ROM Banks, 0-7 are reserved for alternative
;                Monitor versions, CPM and RFS
;                code in MROM bank,
;                0-7 are reserved for RFS code in
;                the User ROM bank.
;                8-15 are reserved for CPM code in
;                the User ROM bank.
;--------------------------------------------------
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

;-----------------------------------------------
; IO ports in hardware and values.
;-----------------------------------------------
MMCFG                   EQU     060H                                     ; Memory management configuration latch.
SETXMHZ                 EQU     062H                                     ; Select the alternate clock frequency.
SET2MHZ                 EQU     064H                                     ; Select the system 2MHz clock frequency.
CLKSELRD                EQU     066H                                     ; Read clock selected setting, 0 = 2MHz, 1 = XMHz
SVCREQ                  EQU     068H                                     ; I/O Processor service request.

;-----------------------------------------------
; tranZPUter SW Memory Management modes
;-----------------------------------------------
TZMM_ORIG               EQU     000H                                     ; Original Sharp MZ80A mode, no tranZPUter features are selected except the I/O control registers (default: 0x60-063).
TZMM_BOOT               EQU     001H                                     ; Original mode but E800-EFFF is mapped to tranZPUter RAM so TZFS can be booted.
TZMM_TZFS               EQU     002H                                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-FFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected.
TZMM_TZFS2              EQU     003H                                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 1.
TZMM_TZFS3              EQU     004H                                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 2.
TZMM_TZFS4              EQU     005H                                     ; TZFS main memory configuration. all memory is in tranZPUter RAM, E800-EFFF is used by TZFS, SA1510 is at 0000-1000 and RAM is 1000-CFFF, 64K Block 0 selected, F000-FFFF is in 64K Block 3.
TZMM_CPM                EQU     006H                                     ; CPM main memory configuration, all memory on the tranZPUter board, 64K block 4 selected. Special case for F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
TZMM_CPM2               EQU     007H                                     ; CPM main memory configuration, F000-FFFF are on the tranZPUter board in block 4, 0040-CFFF and E800-EFFF are in block 5, mainboard for D000-DFFF (video), E000-E800 (Memory control) selected.
                                                                         ; Special case for 0000:003F (interrupt vectors) which resides in block 4, F3C0:F3FF & F7C0:F7FF (floppy disk paging vectors) which resides on the mainboard.
TZMM_COMPAT             EQU     008H                                     ; Original mode but with main DRAM in Bank 0 to allow bootstrapping of programs from other machines such as the MZ700.
TZMM_HOSTACCESS         EQU     009H                                     ; Mode to allow code running in Bank 0, address E800:FFFF to access host memory. Monitor ROM 0000-0FFF and Main DRAM 0x1000-0xD000, video and memory mapped I/O are on the host machine, User/Floppy ROM E800-FFFF are in tranZPUter memory. 
TZMM_MZ700_0            EQU     00AH                                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the mainboard.
TZMM_MZ700_1            EQU     00BH                                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
TZMM_MZ700_2            EQU     00CH                                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is on the tranZPUter in block 6.
TZMM_MZ700_3            EQU     00DH                                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 0, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
TZMM_MZ700_4            EQU     00EH                                     ; MZ700 Mode - 0000:0FFF is on the tranZPUter board in block 6, 1000:CFFF is on the tranZPUter board in block 0, D000:FFFF is inaccessible.
TZMM_MZ800              EQU     00FH                                     ; MZ800 Mode - Tracks original hardware mode offering MZ700/MZ800 configurations.
TZMM_FPGA               EQU     015H                                     ; Open up access for the K64F to the FPGA resources such as memory. All other access to RAM or mainboard is blocked.
TZMM_TZPUM              EQU     016H                                     ; Everything in on mainboard, no access to tranZPUter memory.
TZMM_TZPU               EQU     017H                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 0 is selected.
TZMM_TZPU0              EQU     018H                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 0 is selected.
TZMM_TZPU1              EQU     019H                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 1 is selected.
TZMM_TZPU2              EQU     01AH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 2 is selected.
TZMM_TZPU3              EQU     01BH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 3 is selected.
TZMM_TZPU4              EQU     01CH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 4 is selected.
TZMM_TZPU5              EQU     01DH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 5 is selected.
TZMM_TZPU6              EQU     01EH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 6 is selected.
TZMM_TZPU7              EQU     01FH                                     ; Everything is in tranZPUter domain, no access to underlying Sharp mainboard unless memory management mode is switched. tranZPUter RAM 64K block 7 is selected.

;-----------------------------------------------
; TZ File System Header (MZF)
;-----------------------------------------------
TZFS_ATRB:              EQU     00000h                                   ; Code Type, 01 = Machine Code.
TZFS_NAME:              EQU     00001h                                   ; Title/Name (17 bytes).
TZFS_SIZE:              EQU     00012h                                   ; Size of program.
TZFS_DTADR:             EQU     00014h                                   ; Load address of program.
TZFS_EXADR:             EQU     00016h                                   ; Exec address of program.
TZFS_COMNT:             EQU     00018h                                   ; Comment
TZFS_MZFLEN:            EQU     128                                      ; Length of the MZF header.
TZFS_CMTLEN:            EQU     104                                      ; Length of the comment field

;-----------------------------------------------
;    BIOS WORK AREA (MZ80A)
;-----------------------------------------------
                        ; Variables and control structure used by the I/O processor for service calls and requests.
                        ORG     TZSVCMEM

TZSVCMEM:               EQU     0FD80H                                   ; Start of a memory structure used to communicate with the K64F I/O processor for services such as disk access.
TZSVCSIZE:              EQU     00280H                                   ;
TZSVCDIRSZ:             EQU     20                                       ; Size of the directory/file name.
TZSVCFILESZ:            EQU     17                                       ; Size of a Sharp filename.
TZSVCLONGFILESZ:        EQU     31                                       ; Size of a standard filename.
TZSVCLONGFMTSZ:         EQU     20                                       ; Size of a formatted standard filename for use in directory listings.
TZSVCWILDSZ:            EQU     20                                       ; Size of the wildcard.
TZSVCSECSIZE:           EQU     512
TZSVCDIR_ENTSZ:         EQU     32                                       ; Size of a directory entry.
TZSVCWAITIORETRIES:     EQU     500                                      ; Wait retries for IO response.
TZSVCWAITCOUNT:         EQU     65535                                    ; Wait retries for IO request response.
TZSVC_FTYPE_MZF:        EQU     0                                        ; File type being handled is an MZF
TZSVC_FTYPE_CAS:        EQU     1                                        ; File type being handled is an CASsette BASIC script.
TZSVC_FTYPE_BAS:        EQU     2                                        ; File type being handled is an BASic script
TZSVC_FTYPE_ALL:        EQU     10                                       ; Handle any filetype.
TZSVC_FTYPE_ALLFMT:     EQU     11                                       ; Special case for directory listings, all files but truncated and formatted.
TZSVCCMD:               DS      virtual 1                                ; Service command.
TZSVCRESULT:            DS      virtual 1                                ; Service command result.
TZSVCDIRSEC:            DS      virtual 1                                ; Storage for the directory sector number.
TZSVC_FILE_SEC:         EQU     TZSVCDIRSEC                              ; Union of the file and directory sector as only one can be used at a time.
TZSVC_TRACK_NO:         DS      virtual 2                                ; Storage for the virtual drive track number.
TZSVC_SECTOR_NO:        DS      virtual 2                                ; Storage for the virtual drive sector number.
TZSVC_FILE_NO:          DS      virtual 1                                ; File number to be opened in a file service command.
TZSVC_FILE_TYPE:        DS      virtual 1                                ; Type of file being accessed to differentiate between Sharp MZF files and other handled files.
TZSVC_LOADADDR:         DS      virtual 2                                ; Dynamic load address for rom/images.
TZSVC_SAVEADDR:         EQU     TZSVC_LOADADDR                           ; Union of the load address and the cpu frequency change value, the address  of data to be saved.
TZSVC_CPU_FREQ:         EQU     TZSVC_LOADADDR                           ; Union of the load address and the save address value, only one can be used at a time.
TZSVC_LOADSIZE:         DS      virtual 2                                ; Size of image to load.
TZSVC_SAVESIZE:         EQU     TZSVC_LOADSIZE                           ; Size of image to be saved.
TZSVC_DIRNAME:          DS      virtual TZSVCDIRSZ                       ; Service directory/file name.
TZSVC_FILENAME:         DS      virtual TZSVCFILESZ                      ; Filename to be opened/created.
TZSVCWILDC:             DS      virtual TZSVCWILDSZ                      ; Directory wildcard for file pattern matching.
TZSVCSECTOR:            DS      virtual TZSVCSECSIZE                     ; Service command sector - to store directory entries, file sector read or writes.

TZSVC_CMD_READDIR:      EQU     01H                                      ; Service command to open a directory and return the first block of entries.
TZSVC_CMD_NEXTDIR:      EQU     02H                                      ; Service command to return the next block of an open directory.
TZSVC_CMD_READFILE:     EQU     03H                                      ; Service command to open a file and return the first block.
TZSVC_CMD_NEXTREADFILE: EQU     04H                                      ; Service command to return the next block of an open file.
TZSVC_CMD_WRITEFILE:    EQU     05H                                      ; Service command to create a file and save the first block.
TZSVC_CMD_NEXTWRITEFILE:EQU     06H                                      ; Service command to write the next block to the open file.
TZSVC_CMD_CLOSE:        EQU     07H                                      ; Service command to close any open file or directory.
TZSVC_CMD_LOADFILE:     EQU     08H                                      ; Service command to load a file directly into tranZPUter memory.
TZSVC_CMD_SAVEFILE:     EQU     09H                                      ; Service command to save a file directly from tranZPUter memory. 
TZSVC_CMD_ERASEFILE:    EQU     0aH                                      ; Service command to erase a file on the SD card.
TZSVC_CMD_CHANGEDIR:    EQU     0bH                                      ; Service command to change the active directory on the SD card.
TZSVC_CMD_LOAD40BIOS:   EQU     20H                                      ; Service command requesting that the 40 column version of the SA1510 BIOS is loaded.
TZSVC_CMD_LOAD80BIOS:   EQU     21H                                      ; Service command requesting that the 80 column version of the SA1510 BIOS is loaded.
TZSVC_CMD_LOAD700BIOS40:EQU     22H                                      ; Service command requesting that the MZ700 1Z-013A 40 column BIOS is loaded.
TZSVC_CMD_LOAD700BIOS80:EQU     23H                                      ; Service command requesting that the MZ700 1Z-013A 80 column patched BIOS is loaded.
TZSVC_CMD_LOAD80BIPL:   EQU     24H                                      ; Service command requesting the MZ-80B IPL is loaded.
TZSVC_CMD_LOADBDOS:     EQU     30H                                      ; Service command to reload CPM BDOS+CCP.
TZSVC_CMD_ADDSDDRIVE:   EQU     31H                                      ; Service command to attach a CPM disk to a drive number.
TZSVC_CMD_READSDDRIVE:  EQU     32H                                      ; Service command to read an attached SD file as a CPM disk drive.
TZSVC_CMD_WRITESDDRIVE: EQU     33H                                      ; Service command to write to a CPM disk drive which is an attached SD file.
TZSVC_CMD_CPU_BASEFREQ  EQU     40H                                      ; Service command to switch to the mainboard frequency.
TZSVC_CMD_CPU_ALTFREQ   EQU     41H                                      ; Service command to switch to the alternate frequency provided by the K64F.
TZSVC_CMD_CPU_CHGFREQ   EQU     42H                                      ; Service command to set the alternate frequency in hertz.
TZSVC_CMD_CPU_SETZ80    EQU     50H                                      ; Service command to switch to the external Z80 hard cpu.
TZSVC_CMD_CPU_SETT80    EQU     51H                                      ; Service command to switch to the internal T80 soft cpu.
TZSVC_STATUS_OK:        EQU     000H                                     ; Flag to indicate the K64F processing completed successfully.
TZSVC_STATUS_REQUEST:   EQU     0FEH                                     ; Flag to indicate the Z80 has made a request to the K64F.
TZSVC_STATUS_PROCESSING:EQU     0FFH                                     ; Flag to indicate the K64F is processing a command.
