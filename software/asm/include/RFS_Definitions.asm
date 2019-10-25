;--------------------------------------------------------------------------------------------------------
;-
;- Name:            RFS_Definitions.asm
;- Created:         September 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series Rom Filing System.
;-                  Definitions for the RFS including SA1510 locations.
;-
;- Credits:         
;- Copyright:       (c) 2019 Philip Smart <philip.smart@net2net.org>
;-
;- History:         September 2019 - Initial version.
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
; Function entry points in the SA-1510 Monitor.
;-----------------------------------------------
GETL:      EQU      00003h
LETNL:     EQU      00006h
NL:        EQU      00009h
PRNTS:     EQU      0000Ch
PRNT:      EQU      00012h
MSG:       EQU      00015h
MSGX:      EQU      00018h
GETKY      EQU      0001Bh
BRKEY      EQU      0001Eh
?WRI       EQU      00021h
?WRD       EQU      00024h
?RDI       EQU      00027h
?RDD       EQU      0002Ah
?VRFY      EQU      0002Dh
?TMST      EQU      00033h
MONIT:     EQU      00000h
ST1:       EQU      00095h
MSGE1      EQU      00118h
HLHEX      EQU      00410h
_2HEX      EQU      0041Fh
?KEY       EQU      008CAh
PRNT3      EQU      0096Ch
MSG?2      EQU      000F7h
?ADCN      EQU      00BB9h
?DACN      EQU      00BCEh
?BLNK      EQU      00DA6h
?DPCT      EQU      00DDCh
PRTHL:     EQU      003BAh
PRTHX:     EQU      003C3h
DPCT:      EQU      00DDCh
DLY12:     EQU      00DA7h
DLY12A:    EQU      00DAAh
?RSTR1:    EQU      00EE6h

;-----------------------------------------------
; Memory mapped ports in hardware.
;-----------------------------------------------
SCRN:      EQU      0D000H
ARAM:      EQU      0D800H
DSPCTL:    EQU      0DFFFH                                               ; Screen 40/80 select register (bit 7)
KEYPA:     EQU      0E000h
KEYPB:     EQU      0E001h
KEYPC:     EQU      0E002h
KEYPF:     EQU      0E003h
CSTR:      EQU      0E002h
CSTPT:     EQU      0E003h
CONT0:     EQU      0E004h
CONT1:     EQU      0E005h
CONT2:     EQU      0E006h
CONTF:     EQU      0E007h
SUNDG:     EQU      0E008h
TEMP:      EQU      0E008h
MEMSW:     EQU      0E00CH
MEMSWR:    EQU      0E010H
INVDSP:    EQU      0E014H
NRMDSP:    EQU      0E015H
SCLDSP:    EQU      0E200H
SCLBASE:   EQU      0E2H
RFSBK1:    EQU      0EFFCh                                               ; Select RFS Bank1 (MROM) 
RFSBK2:    EQU      0EFFDh                                               ; Select RFS Bank2 (User ROM)
RFSRST1:   EQU      0EFFEh                                               ; Reset RFS Bank1 to original.
RFSRST2:   EQU      0EFFFh                                               ; Reset RFS Bank2 to original.

;-----------------------------------------------
; Rom File System Header (MZF)
;-----------------------------------------------
RFS_ATRB:  EQU      00000h                                               ; Code Type, 01 = Machine Code.
RFS_NAME:  EQU      00001h                                               ; Title/Name (17 bytes).
RFS_SIZE:  EQU      00012h                                               ; Size of program.
RFS_DTADR: EQU      00014h                                               ; Load address of program.
RFS_EXADR: EQU      00016h                                               ; Exec address of program.
RFS_COMNT: EQU      00018h                                               ; COMMENT

;-----------------------------------------------
; Entry/compilation start points.
;-----------------------------------------------
TPSTART:   EQU      010F0h
MEMSTART:  EQU      01200h
MSTART:    EQU      0E900h
DIRMROM:   EQU      0006Eh
MFINDMZF:  EQU      00071h
MROMLOAD:  EQU      00074h
MZFHDRSZ   EQU      128
RFSSECTSZ  EQU      256
MROMSIZE   EQU      4096
UROMSIZE   EQU      2048

;-----------------------------------------------
; ROM Banks, 0-3 are reserved for alternative
;            Monitor versions in MROM bank,
;            0-7 are reserved for RFS code in the
;            User ROM bank.
;-----------------------------------------------
ROMBANK0   EQU      0
ROMBANK1   EQU      1
ROMBANK2   EQU      2
ROMBANK3   EQU      3
ROMBANK4   EQU      4
ROMBANK5   EQU      5
ROMBANK6   EQU      6
ROMBANK7   EQU      7

;BRKCD      EQU      00
;NTFECD     EQU      40
;HDERCD     EQU      41
;WPRTCD     EQU      46
;QNTRCD     EQU      50
;NFSECD     EQU      53
;UNFMCD     EQU      54

;NAMSIZ     EQU      011h
OBJCD      EQU      001h

;-----------------------------------------------
; Common character definitions.
;-----------------------------------------------
SCROLL     EQU      01H            ;Set scrool direction UP.
BELL       EQU      07H
SPACE      EQU      20H
TAB        EQU      09H            ;TAB ACROSS (8 SPACES FOR SD-BOARD)
CR         EQU      0DH
LF         EQU      0AH
FF         EQU      0CH
ESC        EQU      1BH
DELETE     EQU      7FH
BACKS      EQU      08H
SOH        EQU      1            ; For XModem etc.
EOT        EQU      4
ACK        EQU      6
NAK        EQU      15H

;-----------------------------------------------
;    SA-1510 MONITOR WORK AREA (MZ80A)
;-----------------------------------------------
STACK:     EQU      010F0H
;
           ORG      STACK
;
SPV:
IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
ATRB:      DS       virtual 1                                            ; ATTRIBUTE
NAME:      DS       virtual 17                                           ; FILE NAME
SIZE:      DS       virtual 2                                            ; BYTESIZE
DTADR:     DS       virtual 2                                            ; DATA ADDRESS
EXADR:     DS       virtual 2                                            ; EXECUTION ADDRESS
COMNT:     DS       virtual 92                                           ; COMMENT
SWPW:      DS       virtual 10                                           ; SWEEP WORK
KDATW:     DS       virtual 2                                            ; KEY WORK
KANAF:     DS       virtual 1                                            ; KANA FLAG (01=GRAPHIC MODE)
DSPXY:     DS       virtual 2                                            ; DISPLAY COORDINATES
MANG:      DS       virtual 6                                            ; COLUMN MANAGEMENT
MANGE:     DS       virtual 1                                            ; COLUMN MANAGEMENT END
PBIAS:     DS       virtual 1                                            ; PAGE BIAS
ROLTOP:    DS       virtual 1                                            ; ROLL TOP BIAS
MGPNT:     DS       virtual 1                                            ; COLUMN MANAG. POINTER
PAGETP:    DS       virtual 2                                            ; PAGE TOP
ROLEND:    DS       virtual 1                                            ; ROLL END
           DS       virtual 14                                           ; BIAS
FLASH:     DS       virtual 1                                            ; FLASHING DATA
SFTLK:     DS       virtual 1                                            ; SHIFT LOCK
REVFLG:    DS       virtual 1                                            ; REVERSE FLAG
SPAGE:     DS       virtual 1                                            ; PAGE CHANGE
FLSDT:     DS       virtual 1                                            ; CURSOR DATA
STRGF:     DS       virtual 1                                            ; STRING FLAG
DPRNT:     DS       virtual 1                                            ; TAB COUNTER
TMCNT:     DS       virtual 2                                            ; TAPE MARK COUNTER
SUMDT:     DS       virtual 2                                            ; CHECK SUM DATA
CSMDT:     DS       virtual 2                                            ; FOR COMPARE SUM DATA
AMPM:      DS       virtual 1                                            ; AMPM DATA
TIMFG:     DS       virtual 1                                            ; TIME FLAG
SWRK:      DS       virtual 1                                            ; KEY SOUND FLAG
TEMPW:     DS       virtual 1                                            ; TEMPO WORK
ONTYO:     DS       virtual 1                                            ; ONTYO WORK
OCTV:      DS       virtual 1                                            ; OCTAVE WORK
RATIO:     DS       virtual 2                                            ; ONPU RATIO
BUFER:     DS       virtual 81                                           ; GET LINE BUFFER

; Starting 1000H - Generally unused bytes not cleared by the monitor.
ROMBK1:    EQU      01000H                                               ; CURRENT MROM BANK 
ROMBK2:    EQU      01001H                                               ; CURRENT USERROM BANK 
WRKROMBK1: EQU      01002H                                               ; WORKING MROM BANK 
WRKROMBK2: EQU      01003H                                               ; WORKING USERROM BANK 
SCRNMODE:  EQU      01004H                                               ; Mode of screen, 0 = 40 char, 1 = 80 char.
TMPADR:    EQU      01010H                                               ; TEMPORARY ADDRESS STORAGE
TMPSIZE:   EQU      01012H                                               ; TEMPORARY SIZE
TMPCNT:    EQU      01014H                                               ; TEMPOARY COUNTER
TMPLINECNT:EQU      01016H                                               ; Temporary counter for displayed lines.
; Quickdisk work area
;QDPA       EQU      01130h                                               ; QD code 1
;QDPB       EQU      01131h                                               ; QD code 2
;QDPC       EQU      01132h                                               ; QD header startaddress
;QDPE       EQU      01134h                                               ; QD header length
;QDCPA      EQU      0113Bh                                               ; QD error flag
;HDPT       EQU      0113Ch                                               ; QD new headpoint possition
;HDPT0      EQU      0113Dh                                               ; QD actual headpoint possition
;FNUPS      EQU      0113Eh
;FNUPF      EQU      01140h
;FNA        EQU      01141h                                               ; File Number A (actual file number)
;FNB        EQU      01142h                                               ; File Number B (next file number)
;MTF        EQU      01143h                                               ; QD motor flag
;RTYF       EQU      01144h
;SYNCF      EQU      01146h                                               ; SyncFlags
;RETSP      EQU      01147h
;BUFER      EQU      011A3h
;QDIRBF     EQU      0CD90h



;SPV:
;IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
;ATRB:      DS       virtual 1                                            ; Code Type, 01 = Machine Code.
;NAME:      DS       virtual 17                                           ; Title/Name (17 bytes).
;SIZE:      DS       virtual 2                                            ; Size of program.
;DTADR:     DS       virtual 2                                            ; Load address of program.
;EXADR:     DS       virtual 2                                            ; Exec address of program.
;COMNT:     DS       virtual 104                                          ; COMMENT
;KANAF:     DS       virtual 1                                            ; KANA FLAG (01=GRAPHIC MODE)
;DSPXY:     DS       virtual 2                                            ; DISPLAY COORDINATES
;MANG:      DS       virtual 27                                           ; COLUMN MANAGEMENT
;FLASH:     DS       virtual 1                                            ; FLASHING DATA
;FLPST:     DS       virtual 2                                            ; FLASHING POSITION
;FLSST:     DS       virtual 1                                            ; FLASHING STATUS
;FLSDT:     DS       virtual 1                                            ; CURSOR DATA
;STRGF:     DS       virtual 1                                            ; STRING FLAG
;DPRNT:     DS       virtual 1                                            ; TAB COUNTER
;TMCNT:     DS       virtual 2                                            ; TAPE MARK COUNTER
;SUMDT:     DS       virtual 2                                            ; CHECK SUM DATA
;CSMDT:     DS       virtual 2                                            ; FOR COMPARE SUM DATA
;AMPM:      DS       virtual 1                                            ; AMPM DATA
;TIMFG:     DS       virtual 1                                            ; TIME FLAG
;SWRK:      DS       virtual 1                                            ; KEY SOUND FLAG
;TEMPW:     DS       virtual 1                                            ; TEMPO WORK
;ONTYO:     DS       virtual 1                                            ; ONTYO WORK
;OCTV:      DS       virtual 1                                            ; OCTAVE WORK
;RATIO:     DS       virtual 2                                            ; ONPU RATIO
                                                                         ; QD command table
