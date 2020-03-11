;--------------------------------------------------------------------------------------------------------
;-
;- Name:            CPM_Definitions.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM v2.23
;-                  Definitions for the Sharp MZ80A CPM v2.23 OS used in the RFS
;-
;- Credits:         
;- Copyright:       (c) 2019-20 Philip Smart <philip.smart@net2net.org>
;-
;- History:         Janaury 2020 - Initial version.
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
; Entry/compilation start points.
;-----------------------------------------------
CBIOSSTART  EQU     0C000h
CBIOSDATA   EQU     CBIOSSTART - 0400H
UROMADDR    EQU     0E800H                                               ; Start of User ROM Address space.
FDCROMADDR  EQU     0F000H
CBASE       EQU     0A000H
CPMCCP      EQU     CBASE                                                ; CP/M System entry
CPMBDOS     EQU     CPMCCP + 0806H                                       ; BDOS entry
CPMBIOS     EQU     CPMCCP + 01600H                                      ; Original CPM22 BIOS entry
BOOT        EQU     CBIOSSTART + 0
WBOOT       EQU     CBIOSSTART + 3
WBOOTE      EQU     CBIOSSTART + 3
CONST       EQU     CBIOSSTART + 6
CONIN       EQU     CBIOSSTART + 9
CONOUT      EQU     CBIOSSTART + 12
LIST        EQU     CBIOSSTART + 15
PUNCH       EQU     CBIOSSTART + 18
READER      EQU     CBIOSSTART + 21
HOME        EQU     CBIOSSTART + 24
SELDSK      EQU     CBIOSSTART + 27
SETTRK      EQU     CBIOSSTART + 30
SETSEC      EQU     CBIOSSTART + 33
SETDMA      EQU     CBIOSSTART + 36
READ        EQU     CBIOSSTART + 39
WRITE       EQU     CBIOSSTART + 42
FRSTAT      EQU     CBIOSSTART + 45
SECTRN      EQU     CBIOSSTART + 48
UNUSED      EQU     CBIOSSTART + 51
CCP         EQU     CBASE
CCPCLRBUF   EQU     CBASE + 3
CPMDPBASE   EQU     CPMBIOS
IOBYT       EQU     00003H                                               ; IOBYTE address
CDISK       EQU     00004H                                               ; Address of Current drive name and user number
CPMUSERDMA  EQU     00080h                                               ; Default CPM User DMA address.
DPSIZE      EQU     16                                                   ; Size of a Disk Parameter Block
DPBLOCK0    EQU     SCRN - (8 * DPSIZE)                                  ; Location of the 1st DPB in the CBIOS Rom.
DPBLOCK1    EQU     DPBLOCK0 + DPSIZE
DPBLOCK2    EQU     DPBLOCK1 + DPSIZE
DPBLOCK3    EQU     DPBLOCK2 + DPSIZE
DPBLOCK4    EQU     DPBLOCK3 + DPSIZE
DPBLOCK5    EQU     DPBLOCK4 + DPSIZE
DPBLOCK6    EQU     DPBLOCK5 + DPSIZE
DPBLOCK7    EQU     DPBLOCK6 + DPSIZE

; BIOS equates
NDISKS      EQU     4                                                    ; Number of Disk Drives
KEYBUFSIZE  EQU     16                                                   ; Ensure this is a power of 2, max size 256.

; Debugging
ENADEBUG    EQU     0                                                    ; Enable debugging logic, 1 = enable, 0 = disable

;-----------------------------------------------
; Configurable settings.
;-----------------------------------------------
MAXRDRETRY  EQU     002h 
MAXWRRETRY  EQU     002h
BLKSIZ      EQU     4096                                                 ; CP/M allocation size
HSTSIZ      EQU     512                                                  ; host disk sector size
HSTSPT      EQU     32                                                   ; host disk sectors/trk
HSTBLK      EQU     HSTSIZ/128                                           ; CP/M sects/host buff
CPMSPT      EQU     HSTBLK * HSTSPT                                      ; CP/M sectors/track
SECMSK      EQU     HSTBLK-1                                             ; sector mask
WRALL       EQU     0                                                    ; write to allocated
WRDIR       EQU     1                                                    ; write to directory
WRUAL       EQU     2                                                    ; write to unallocated
TMRTICKINTV EQU     5                                                    ; Number of 0.010mSec ticks per interrupt, ie. resolution of RTC.
MTROFFMSECS EQU     100                                                  ; Time from last access to motor being switched off in seconds in TMRTICKINTV ticks.
COLW:       EQU     80                                                   ; Width of the display screen (ie. columns).
ROW:        EQU     25                                                   ; Number of rows on display screen.
SCRNSZ:     EQU     COLW * ROW                                           ; Total size, in bytes, of the screen display area.
SCRLW:      EQU     COLW / 8                                             ; Number of 8 byte regions in a line for hardware scroll.
MODE80C:    EQU     1

;-------------------------------------------------------
; Function entry points in the CBIOS ROMS
;-------------------------------------------------------

; Public functions in CBIOS User ROM Bank 1.
QREBOOT     EQU      9 + UROMADDR
QMELDY      EQU     12 + UROMADDR
QTEMP       EQU     15 + UROMADDR
QMSTA       EQU     18 + UROMADDR
QMSTP       EQU     21 + UROMADDR
QBEL        EQU     24 + UROMADDR

; Public functions in CBIOS User ROM Bank 1.
QPRNT       EQU      9 + UROMADDR
QPRTHX      EQU     12 + UROMADDR
QPRTHL      EQU     15 + UROMADDR
QANSITERM   EQU     18 + UROMADDR


;-----------------------------------------------
; Memory mapped ports in hardware.
;-----------------------------------------------
SCRN:       EQU     0D000H
ARAM:       EQU     0D800H
DSPCTL:     EQU     0DFFFH                                               ; Screen 40/80 select register (bit 7)
KEYPA:      EQU     0E000h
KEYPB:      EQU     0E001h
KEYPC:      EQU     0E002h
KEYPF:      EQU     0E003h
CSTR:       EQU     0E002h
CSTPT:      EQU     0E003h
CONT0:      EQU     0E004h
CONT1:      EQU     0E005h
CONT2:      EQU     0E006h
CONTF:      EQU     0E007h
SUNDG:      EQU     0E008h
TEMP:       EQU     0E008h
MEMSW:      EQU     0E00CH
MEMSWR:     EQU     0E010H
INVDSP:     EQU     0E014H
NRMDSP:     EQU     0E015H
SCLDSP:     EQU     0E200H
SCLBASE:    EQU     0E2H
RFSBK1:     EQU     0EFFCh                                               ; Select RFS Bank1 (MROM) 
RFSBK2:     EQU     0EFFDh                                               ; Select RFS Bank2 (User ROM)
RFSRST1:    EQU     0EFFEh                                               ; Reset RFS Bank1 to original.
RFSRST2:    EQU     0EFFFh                                               ; Reset RFS Bank2 to original.

;-----------------------------------------------
; Rom File System Header (MZF)
;-----------------------------------------------
RFS_ATRB:   EQU     00000h                                               ; Code Type, 01 = Machine Code.
RFS_NAME:   EQU     00001h                                               ; Title/Name (17 bytes).
RFS_SIZE:   EQU     00012h                                               ; Size of program.
RFS_DTADR:  EQU     00014h                                               ; Load address of program.
RFS_EXADR:  EQU     00016h                                               ; Exec address of program.
RFS_COMNT:  EQU     00018h                                               ; COMMENT
MZFHDRSZ    EQU     128                                                  ; Full MZF Header size
MZFHDRNCSZ  EQU     24                                                   ; Only the primary MZF data, no comment field.
RFSSECTSZ   EQU     256
MROMSIZE    EQU     4096
UROMSIZE    EQU     2048
BANKSPERTRACK EQU (ROMSECTORSIZE * ROMSECTORS) / UROMSIZE                ; (8) We currently only use the UROM for disk images.
SECTORSPERBANK EQU UROMSIZE / ROMSECTORSIZE                              ; (16)
SECTORSPERBLOCK EQU RFSSECTSZ/ROMSECTORSIZE                              ; (2)
ROMSECTORSIZE EQU   128
ROMSECTORS    EQU   128
ROMBK1:    EQU      01016H                                               ; CURRENT MROM BANK 
ROMBK2:    EQU      01017H                                               ; CURRENT USERROM BANK 
WRKROMBK1: EQU      01018H                                               ; WORKING MROM BANK 
WRKROMBK2: EQU      01019H                                               ; WORKING USERROM BANK

;-----------------------------------------------
; ROM Banks, 0-3 are reserved for alternative
;            Monitor versions in MROM bank,
;            0-7 are reserved for RFS code in the
;            User ROM bank.
;-----------------------------------------------
ROMBANK0    EQU     0
ROMBANK1    EQU     1
ROMBANK2    EQU     2
ROMBANK3    EQU     3
ROMBANK4    EQU     4
ROMBANK5    EQU     5
ROMBANK6    EQU     6
ROMBANK7    EQU     7

OBJCD       EQU     001h

;-----------------------------------------------
; IO Registers
;-----------------------------------------------
FDC         EQU     0D8h                                                 ; MB8866 IO Region 0D8h - 0DBh
FDC_CR      EQU     000h + FDC                                           ; Command Register
FDC_STR     EQU     000h + FDC                                           ; Status Register
FDC_TR      EQU     001h + FDC                                           ; Track Register
FDC_SCR     EQU     002h + FDC                                           ; Sector Register
FDC_DR      EQU     003h + FDC                                           ; Data Register
FDC_MOTOR   EQU     004h + FDC                                           ; DS[0-3] and Motor control. 4 drives  DS= BIT 0 -> Bit 2 = Drive number, 2=1,1=0,0=0 DS0, 2=1,1=0,0=1 DS1 etc
                                                                         ;  bit 7 = 1 MOTOR ON LOW (Active)
FDC_SIDE    EQU     005h + FDC                                           ; Side select, Bit 0 when set = SIDE SELECT LOW

;-----------------------------------------------
; Common character definitions.
;-----------------------------------------------
SCROLL      EQU     001H            ;Set scroll direction UP.
BELL        EQU     007H
SPACE       EQU     020H
TAB         EQU     009H            ;TAB ACROSS (8 SPACES FOR SD-BOARD)
CR          EQU     00DH
LF          EQU     00AH
FF          EQU     00CH
DELETE      EQU     07FH
BACKS       EQU     008H
SOH         EQU     1            ; For XModem etc.
EOT         EQU     4
ACK         EQU     6
NAK         EQU     015H
NUL         EQU     000H
NULL        EQU     000H
CTRL_A      EQU     001H
CTRL_B      EQU     002H
CTRL_C      EQU     003H
CTRL_D      EQU     004H
CTRL_E      EQU     005H
CTRL_F      EQU     006H
CTRL_G      EQU     007H
CTRL_H      EQU     008H
CTRL_I      EQU     009H
CTRL_J      EQU     00AH
CTRL_K      EQU     00BH
CTRL_L      EQU     00CH
CTRL_M      EQU     00DH
CTRL_N      EQU     00EH
CTRL_O      EQU     00FH
CTRL_P      EQU     010H
CTRL_Q      EQU     011H
CTRL_R      EQU     012H
CTRL_S      EQU     013H
CTRL_T      EQU     014H
CTRL_U      EQU     015H
CTRL_V      EQU     016H
CTRL_W      EQU     017H
CTRL_X      EQU     018H
CTRL_Y      EQU     019H
CTRL_Z      EQU     01AH
ESC         EQU     01BH
CTRL_SLASH  EQU     01CH
CTRL_RB     EQU     01DH
CTRL_CAPPA  EQU     01EH
CTRL_UNDSCR EQU     01FH
CTRL_AT     EQU     000H
NOKEY       EQU     0F0H
CURSRIGHT   EQU     0F1H
CURSLEFT    EQU     0F2H
CURSUP      EQU     0F3H
CURSDOWN    EQU     0F4H
DBLZERO     EQU     0F5H
INSERT      EQU     0F6H
CLRKEY      EQU     0F7H
HOMEKEY     EQU     0F8H
BREAKKEY    EQU     0FBH

;-----------------------------------------------
;    BIOS WORK AREA (MZ80A)
;-----------------------------------------------
            ORG     CBIOSDATA

            ; Keyboard processing, ensure starts where LSB = 0.
VARSTART    EQU     $                                                    ; Start of variables.
KEYBUF:     DS      virtual KEYBUFSIZE                                   ; Interrupt driven keyboard buffer.
KEYCOUNT:   DS      virtual 1
KEYWRITE:   DS      virtual 2                                            ; Pointer into the buffer where the next character should be placed.
KEYREAD:    DS      virtual 2                                            ; Pointer into the buffer where the next character can be read.
KEYLAST:    DS      virtual 1                                            ; KEY LAST VALUE
KEYRPT:     DS      virtual 1                                            ; KEY REPEAT COUNTER
;
SPV:
IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
ATRB:       DS      virtual 1                                            ; ATTRIBUTE
NAME:       DS      virtual 17                                           ; FILE NAME
SIZE:       DS      virtual 2                                            ; BYTESIZE
DTADR:      DS      virtual 2                                            ; DATA ADDRESS
EXADR:      DS      virtual 2                                            ; EXECUTION ADDRESS
SWPW:       DS      virtual 10                                           ; SWEEP WORK
KDATW:      DS      virtual 2                                            ; KEY WORK
;KANAF:      DS      virtual 1                                            ; KANA FLAG (01=GRAPHIC MODE)
DSPXY:      DS      virtual 2                                            ; DISPLAY COORDINATES
DSPXYLST:   DS      virtual 2                                            ; Last known cursor position, to compare with DSPXY to detect changes.
FLASHCTL:   DS      virtual 1                                            ; CURSOR FLASH CONTROL. BIT 0 = Cursor On/Off, BIT 1 = Cursor displayed.
DSPXYADDR:  DS      virtual 2                                            ; Address of last known position.
MANG:       DS      virtual 6                                            ; COLUMN MANAGEMENT
MANGE:      DS      virtual 1                                            ; COLUMN MANAGEMENT END
PBIAS:      DS      virtual 1                                            ; PAGE BIAS
ROLTOP:     DS      virtual 1                                            ; ROLL TOP BIAS
MGPNT:      DS      virtual 1                                            ; COLUMN MANAG. POINTER
PAGETP:     DS      virtual 2                                            ; PAGE TOP
ROLEND:     DS      virtual 1                                            ; ROLL END
            DS      virtual 14                                           ; BIAS
FLASH:      DS      virtual 1                                            ; FLASHING DATA
SFTLK:      DS      virtual 1                                            ; SHIFT LOCK
REVFLG:     DS      virtual 1                                            ; REVERSE FLAG
FLSDT:      DS      virtual 1                                            ; CURSOR DATA
STRGF:      DS      virtual 1                                            ; STRING FLAG
DPRNT:      DS      virtual 1                                            ; TAB COUNTER
AMPM:       DS      virtual 1                                            ; AMPM DATA
TIMFG:      DS      virtual 1                                            ; TIME FLAG
SWRK:       DS      virtual 1                                            ; KEY SOUND FLAG
TEMPW:      DS      virtual 1                                            ; TEMPO WORK
ONTYO:      DS      virtual 1                                            ; ONTYO WORK
OCTV:       DS      virtual 1                                            ; OCTAVE WORK
RATIO:      DS      virtual 2                                            ; ONPU RATIO
;BUFER:      DS      virtual 81                                           ; GET LINE BUFFER
;KEYBUF:     DS      virtual 1                                            ; KEY BUFFER
TIMESEC     DS      virtual 6                                            ; RTC 48bit TIME IN MILLISECONDS
FDCCMD      DS      virtual 1                                            ; LAST FDC COMMAND SENT TO CONTROLLER.
MOTON       DS      virtual 1                                            ; MOTOR ON = 1, OFF = 0
INVFDCDATA: DS      virtual 1                                            ; INVERT DATA COMING FROM FDC, 1 = INVERT, 0 = AS IS
TRK0FD1     DS      virtual 1                                            ; FD 1 IS AT TRACK 0 = BIT 0 set 
TRK0FD2     DS      virtual 1                                            ; FD 2 IS AT TRACK 0 = BIT 0 set
TRK0FD3     DS      virtual 1                                            ; FD 3 IS AT TRACK 0 = BIT 0 set
TRK0FD4     DS      virtual 1                                            ; FD 4 IS AT TRACK 0 = BIT 0 set
RETRIES     DS      virtual 2                                            ; DATA READ RETRIES
TMPADR      DS      virtual 2                                            ; TEMPORARY ADDRESS STORAGE
TMPSIZE     DS      virtual 2                                            ; TEMPORARY SIZE
TMPCNT      DS      virtual 2                                            ; TEMPORARY COUNTER
;
CPMROMLOC:  DS      virtual 2                                            ; Upper Byte = ROM Bank, Lower Byte = Page of CPM Image.
CPMROMDRV0: DS      virtual 2                                            ; Upper Byte = ROM Bank, Lower Byte = Page of CPM Rom Drive Image Disk 0.
CPMROMDRV1: DS      virtual 2                                            ; Upper Byte = ROM Bank, Lower Byte = Page of CPM Rom Drive Image Disk 1.
DISKMAP:    DS      virtual NDISKS                                       ; Disk map of CPM logical to physical controller disk.
FDCDISK:    DS      virtual 1                                            ; Physical disk number.
SECPERTRK:  DS      virtual 1                                            ; Sectors per track for 1 head.
SECPERHEAD: DS      virtual 1                                            ; Sectors per head.
SECTORCNT:  DS      virtual 1                                            ; Sector size as a count of how many sectors make 512 bytes.
DISKTYPE:   DS      virtual 1                                            ; Disk type of current selection.
ROMDRV:     DS      virtual 1                                            ; ROM Drive Image to use.
MTROFFTIMER:DS      virtual 1                                            ; Second down counter for FDC motor off.
;
SEKDSK:     DS      virtual 1                                            ; Seek disk number
SEKTRK:     DS      virtual 2                                            ; Seek disk track
SEKSEC:     DS      virtual 1                                            ; Seek sector number
SEKHST:     DS      virtual 1                                            ; Seek sector host
;
HSTDSK:     DS      virtual 1                                            ; Host disk number
HSTTRK:     DS      virtual 2                                            ; Host track number
HSTSEC:     DS      virtual 1                                            ; Host sector number
HSTWRT:     DS      virtual 1                                            ; Host write flag
HSTACT:     DS      virtual 1                                            ; 
;
UNACNT:     DS      virtual 1                                            ; Unalloc rec cnt
UNADSK:     DS      virtual 1                                            ; Last unalloc disk
UNATRK:     DS      virtual 2                                            ; Last unalloc track
UNASEC:     DS      virtual 1                                            ; Last unalloc sector
;
ERFLAG:     DS      virtual 1                                            ; Error number, 0 = no error.
READOP:     DS      virtual 1                                            ; If read operation then 1, else 0 for write.
RSFLAG:     DS      virtual 1                                            ; Read sector flag.
WRTYPE:     DS      virtual 1                                            ; Write operation type.
TRACKNO:    DS      virtual 2                                            ; Host controller track number
SECTORNO:   DS      virtual 1                                            ; Host controller sector number
DMAADDR:    DS      virtual 2                                            ; Last DMA address
HSTBUF:     DS      virtual 512                                          ; Host buffer for disk sector storage
HSTBUFE:

CURSORPSAV  DS      virtual 2                                            ; Cursor save position;default 0,0
HAVELOADED  DS      virtual 1                                            ; To show that a value has been put in for Ansi emualtor.
ANSIFIRST   DS      virtual 1                                            ; Holds first character of Ansi sequence
NUMBERBUF   DS      virtual 20                                           ; Buffer for numbers in Ansi
NUMBERPOS   DS      virtual 2                                            ; Address within buffer
CHARACTERNO DS      virtual 1                                            ; Byte within Ansi sequence. 0=first,255=other
CURSORCOUNT DS      virtual 1                                            ; 1/50ths of a second since last change
FONTSET     DS      virtual 1                                            ; Ansi font setup.
JSW_FF      DS      virtual 1                                            ; Byte value to turn on/off FF routine
JSW_LF      DS      virtual 1                                            ; Byte value to turn on/off LF routine
CHARACTER   DS      virtual 1                                            ; To buffer character to be printed.    
CURSORPOS   DS      virtual 2                                            ; Cursor position, default 0,0.
BOLDMODE    DS      virtual 1
HIBRITEMODE DS      virtual 1                                            ; 0 means on, &C9 means off
UNDERSCMODE DS      virtual 1
ITALICMODE  DS      virtual 1
INVMODE     DS      virtual 1
CHGCURSMODE DS      virtual 1
ANSIMODE    DS      virtual 1                                            ; 1 = on, 0 = off
COLOUR      EQU     0

SPSAVE:     DS      virtual 2                                            ; CPM Stack save.
SPISRSAVE:  DS      virtual 2
VAREND      EQU     $                                                    ; End of variables

            ; Stack space for the CBIOS.
            DS      virtual 128 
BIOSSTACK   EQU     $
            ; Stack space for the Interrupt Service Routine.
            DS      virtual 32                                           ; Max 8 stack pushes.
ISRSTACK    EQU     $
