;--------------------------------------------------------------------------------------------------------
;-
;- Name:            RFS_Definitions.asm
;- Created:         September 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series Rom Filing System.
;-                  Definitions for the RFS including SA1510 locations.
;-
;- Credits:         
;- Copyright:       (c) 2019-20 Philip Smart <philip.smart@net2net.org>
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

;-------------------------------------------------------
; Function entry points in the standard SA-1510 Monitor.
;-------------------------------------------------------
GETL:       EQU     00003h
LETNL:      EQU     00006h
NL:         EQU     00009h
PRNTS:      EQU     0000Ch
PRNT:       EQU     00012h
MSG:        EQU     00015h
MSGX:       EQU     00018h
GETKY       EQU     0001Bh
BRKEY       EQU     0001Eh
?WRI        EQU     00021h
?WRD        EQU     00024h
?RDI        EQU     00027h
?RDD        EQU     0002Ah
?VRFY       EQU     0002Dh
MELDY       EQU     00030h
?TMST       EQU     00033h
MONIT:      EQU     00000h
SS:         EQU     00089h
ST1:        EQU     00095h
MSGE1       EQU     00118h
HLHEX       EQU     00410h
_2HEX       EQU     0041Fh
?MODE:      EQU     0074DH
?KEY        EQU     008CAh
PRNT3       EQU     0096Ch
MSG?2       EQU     000F7h
?ADCN       EQU     00BB9h
?DACN       EQU     00BCEh
?BLNK       EQU     00DA6h
?DPCT       EQU     00DDCh
PRTHL:      EQU     003BAh
PRTHX:      EQU     003C3h
HEX:        EQU     003F9h
DPCT:       EQU     00DDCh
DLY12:      EQU     00DA7h
DLY12A:     EQU     00DAAh
?RSTR1:     EQU     00EE6h

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

;-----------------------------------------------
; Entry/compilation start points.
;-----------------------------------------------
TPSTART:    EQU     010F0h
MEMSTART:   EQU     01200h
MSTART:     EQU     0E900h
DIRMROM:    EQU     0006Eh
MFINDMZF:   EQU     00071h
MROMLOAD:   EQU     00074h
MZFHDRSZ    EQU     128
RFSSECTSZ   EQU     256
MROMSIZE    EQU     4096
UROMSIZE    EQU     2048

;-----------------------------------------------
; ROM Banks, 0-7 are reserved for alternative
;            Monitor versions, CPM and RFS
;            code in MROM bank,
;            0-7 are reserved for RFS code in
;            the User ROM bank.
;            8-15 are reserved for CPM code in
;            the User ROM bank.
;-----------------------------------------------
MROMPAGES   EQU     8
USRROMPAGES EQU     12
ROMBANK0    EQU     0
ROMBANK1    EQU     1
ROMBANK2    EQU     2
ROMBANK3    EQU     3
ROMBANK4    EQU     4
ROMBANK5    EQU     5
ROMBANK6    EQU     6
ROMBANK7    EQU     7
ROMBANK8    EQU     8
ROMBANK9    EQU     9
ROMBANK10   EQU     10
ROMBANK11   EQU     11

OBJCD       EQU     001h

;-----------------------------------------------
; Common character definitions.
;-----------------------------------------------
SCROLL      EQU     01H                                                  ; Set scrool direction UP.
BELL        EQU     07H
SPACE       EQU     20H
TAB         EQU     09H                                                  ; TAB ACROSS (8 SPACES FOR SD-BOARD)
CR          EQU     0DH
LF          EQU     0AH
FF          EQU     0CH
ESC         EQU     1BH
DELETE      EQU     7FH
BACKS       EQU     08H
SOH         EQU     1                                                    ; For XModem etc.
EOT         EQU     4
ACK         EQU     6
NAK         EQU     15H
NUL         EQU     00H


SPI_OUT     EQU     0FFH
SPI_IN      EQU     0FEH
DOUT_LOW    EQU     000H
DOUT_HIGH   EQU     004H
DOUT_MASK   EQU     004H
DIN_LOW     EQU     000H
DIN_HIGH    EQU     001H
CLOCK_LOW   EQU     000H
CLOCK_HIGH  EQU     002H
CLOCK_MASK  EQU     0FDH
CS_LOW      EQU     000H
CS_HIGH     EQU     001H

; MMC/SD command (SPI mode)
CMD0        EQU     64 + 0                                               ; GO_IDLE_STATE 
CMD1        EQU     64 + 1                                               ; SEND_OP_COND 
ACMD41      EQU     0x40+41                                              ; SEND_OP_COND (SDC) 
CMD8        EQU     64 + 8                                               ; SEND_IF_COND 
CMD9        EQU     64 + 9                                               ; SEND_CSD 
CMD10       EQU     64 + 10                                              ; SEND_CID 
CMD12       EQU     64 + 12                                              ; STOP_TRANSMISSION 
CMD13       EQU     64 + 13                                              ; SEND_STATUS 
ACMD13      EQU     0x40+13                                              ; SD_STATUS (SDC) 
CMD16       EQU     64 + 16                                              ; SET_BLOCKLEN 
CMD17       EQU     64 + 17                                              ; READ_SINGLE_BLOCK 
CMD18       EQU     64 + 18                                              ; READ_MULTIPLE_BLOCK 
CMD23       EQU     64 + 23                                              ; SET_BLOCK_COUNT 
ACMD23      EQU     0x40+23                                              ; SET_WR_BLK_ERASE_COUNT (SDC)
CMD24       EQU     64 + 24                                              ; WRITE_BLOCK 
CMD25       EQU     64 + 25                                              ; WRITE_MULTIPLE_BLOCK 
CMD32       EQU     64 + 32                                              ; ERASE_ER_BLK_START 
CMD33       EQU     64 + 33                                              ; ERASE_ER_BLK_END 
CMD38       EQU     64 + 38                                              ; ERASE 
CMD55       EQU     64 + 55                                              ; APP_CMD 
CMD58       EQU     64 + 58                                              ; READ_OCR 
SD_SECSIZE  EQU     512                                                  ; Default size of an SD Sector 

; Card type flags (CardType)
CT_MMC      EQU     001H                                                 ; MMC ver 3 
CT_SD1      EQU     002H                                                 ; SD ver 1 
CT_SD2      EQU     004H                                                 ; SD ver 2 
CT_SDC      EQU     CT_SD1|CT_SD2                                        ; SD 
CT_BLOCK    EQU     008H                                                 ; Block addressing 

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
SDDIR_FLAG1 EQU     000H
SDDIR_FLAG2 EQU     001H
SDDIR_FILEN EQU     002H
SDDIR_SSEC  EQU     013H
SDDIR_SIZE  EQU     015H
SDDIR_LOAD  EQU     017H
SDDIR_EXEC  EQU     019H
SDDIR_FNSZ  EQU     17
SDDIR_ENTSZ EQU     32

;-----------------------------------------------
;    SA-1510 MONITOR WORK AREA (MZ80A)
;-----------------------------------------------
STACK:      EQU     010F0H
;
            ORG     STACK
;
SPV:
IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
ATRB:       DS      virtual 1                                            ; ATTRIBUTE
NAME:       DS      virtual 17                                           ; FILE NAME
SIZE:       DS      virtual 2                                            ; BYTESIZE
DTADR:      DS      virtual 2                                            ; DATA ADDRESS
EXADR:      DS      virtual 2                                            ; EXECUTION ADDRESS
COMNT:      DS      virtual 92                                           ; COMMENT
SWPW:       DS      virtual 10                                           ; SWEEP WORK
KDATW:      DS      virtual 2                                            ; KEY WORK
KANAF:      DS      virtual 1                                            ; KANA FLAG (01=GRAPHIC MODE)
DSPXY:      DS      virtual 2                                            ; DISPLAY COORDINATES
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
SPAGE:      DS      virtual 1                                            ; PAGE CHANGE
FLSDT:      DS      virtual 1                                            ; CURSOR DATA
STRGF:      DS      virtual 1                                            ; STRING FLAG
DPRNT:      DS      virtual 1                                            ; TAB COUNTER
TMCNT:      DS      virtual 2                                            ; TAPE MARK COUNTER
SUMDT:      DS      virtual 2                                            ; CHECK SUM DATA
CSMDT:      DS      virtual 2                                            ; FOR COMPARE SUM DATA
AMPM:       DS      virtual 1                                            ; AMPM DATA
TIMFG:      DS      virtual 1                                            ; TIME FLAG
SWRK:       DS      virtual 1                                            ; KEY SOUND FLAG
TEMPW:      DS      virtual 1                                            ; TEMPO WORK
ONTYO:      DS      virtual 1                                            ; ONTYO WORK
OCTV:       DS      virtual 1                                            ; OCTAVE WORK
RATIO:      DS      virtual 2                                            ; ONPU RATIO
BUFER:      DS      virtual 81                                           ; GET LINE BUFFER

; Starting 1000H - Generally unused bytes not cleared by the monitor.
ROMBK1:     EQU     01016H                                               ; CURRENT MROM BANK 
ROMBK2:     EQU     01017H                                               ; CURRENT USERROM BANK 
WRKROMBK1:  EQU     01018H                                               ; WORKING MROM BANK 
WRKROMBK2:  EQU     01019H                                               ; WORKING USERROM BANK 
SCRNMODE:   EQU     0101AH                                               ; Mode of screen, 0 = 40 char, 1 = 80 char.
TMPADR:     EQU     0101BH                                               ; TEMPORARY ADDRESS STORAGE
TMPSIZE:    EQU     0101DH                                               ; TEMPORARY SIZE
TMPCNT:     EQU     0101FH                                               ; TEMPORARY COUNTER
TMPLINECNT: EQU     01021H                                               ; Temporary counter for displayed lines.
TMPSTACKP:  EQU     01023H                                               ; Temporary stack pointer save.
SDVER:      EQU     01025H
SDCAP:      EQU     01026H
; Variables sharing the CMT buffer, normally the CMT and SD are not used at the same 
; time. This frees up memory needed by the SD card.
SECTORBUF:  EQU     0CE00H                                               ; Working buffer to place an SD card sector.
SDBYTECNT   EQU     COMNT+2                                              ; Bytes to read/write to/from a sector.
SDOFFSET    EQU     COMNT+4                                              ; Offset into sector prior to data read/write.
SDSTARTSEC  EQU     COMNT+6                                              ; Starting sector of data to read/write from/to SD card.
SDLOADADDR  EQU     COMNT+10                                             ; Address to read/write data from/to SD card.
SDLOADSIZE  EQU     COMNT+12                                             ; Total remaining byte count data to read/write from/to SD card.
SDAUTOEXEC  EQU     COMNT+14                                             ; Flag to indicate if a loaded image should be executed (=0xFF)
SDBUF:      EQU     COMNT+15                                             ; SD Card command fram buffer for the command and response storage.
DIRSECBUF:  EQU     COMNT+26                                             ; Directory sector in cache.
RESULT:     EQU     COMNT+27
BYTECNT:    EQU     COMNT+29
WRITECNT:   EQU     COMNT+31

; Quickdisk work area
;QDPA       EQU     01130h                                               ; QD code 1
;QDPB       EQU     01131h                                               ; QD code 2
;QDPC       EQU     01132h                                               ; QD header startaddress
;QDPE       EQU     01134h                                               ; QD header length
;QDCPA      EQU     0113Bh                                               ; QD error flag
;HDPT       EQU     0113Ch                                               ; QD new headpoint possition
;HDPT0      EQU     0113Dh                                               ; QD actual headpoint possition
;FNUPS      EQU     0113Eh
;FNUPF      EQU     01140h
;FNA        EQU     01141h                                               ; File Number A (actual file number)
;FNB        EQU     01142h                                               ; File Number B (next file number)
;MTF        EQU     01143h                                               ; QD motor flag
;RTYF       EQU     01144h
;SYNCF      EQU     01146h                                               ; SyncFlags
;RETSP      EQU     01147h
;BUFER      EQU     011A3h
;QDIRBF     EQU     0CD90h



;SPV:
;IBUFE:                                                                  ; TAPE BUFFER (128 BYTES)
;ATRB:      DS      virtual 1                                            ; Code Type, 01 = Machine Code.
;NAME:      DS      virtual 17                                           ; Title/Name (17 bytes).
;SIZE:      DS      virtual 2                                            ; Size of program.
;DTADR:     DS      virtual 2                                            ; Load address of program.
;EXADR:     DS      virtual 2                                            ; Exec address of program.
;COMNT:     DS      virtual 104                                          ; COMMENT
;KANAF:     DS      virtual 1                                            ; KANA FLAG (01=GRAPHIC MODE)
;DSPXY:     DS      virtual 2                                            ; DISPLAY COORDINATES
;MANG:      DS      virtual 27                                           ; COLUMN MANAGEMENT
;FLASH:     DS      virtual 1                                            ; FLASHING DATA
;FLPST:     DS      virtual 2                                            ; FLASHING POSITION
;FLSST:     DS      virtual 1                                            ; FLASHING STATUS
;FLSDT:     DS      virtual 1                                            ; CURSOR DATA
;STRGF:     DS      virtual 1                                            ; STRING FLAG
;DPRNT:     DS      virtual 1                                            ; TAB COUNTER
;TMCNT:     DS      virtual 2                                            ; TAPE MARK COUNTER
;SUMDT:     DS      virtual 2                                            ; CHECK SUM DATA
;CSMDT:     DS      virtual 2                                            ; FOR COMPARE SUM DATA
;AMPM:      DS      virtual 1                                            ; AMPM DATA
;TIMFG:     DS      virtual 1                                            ; TIME FLAG
;SWRK:      DS      virtual 1                                            ; KEY SOUND FLAG
;TEMPW:     DS      virtual 1                                            ; TEMPO WORK
;ONTYO:     DS      virtual 1                                            ; ONTYO WORK
;OCTV:      DS      virtual 1                                            ; OCTAVE WORK
;RATIO:     DS      virtual 2                                            ; ONPU RATIO
