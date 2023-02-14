;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_mrom.asm
;- Created:         September 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series Rom Filing System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade.
;-                  The purpose of this program is to provide helper utilities to the RFS in order that
;-                  the RFS can read the User Banks and extract required programs.
;-
;- Credits:         
;- Copyright:       (c) 2018-2023 Philip Smart <philip.smart@net2net.org>
;-
;- History:         Sep 2019  - Initial version.
;                   May 2020  - Bank switch changes with release of v2 pcb with coded latch. The coded
;                               latch adds additional instruction overhead as the control latches share
;                               the same address space as the Flash RAMS thus the extra hardware to
;                               only enable the control registers if a fixed number of reads is made
;                               into the upper 8 bytes which normally wouldnt occur. Caveat - ensure
;                               that no loop instruction is ever placed into EFF8H - EFFFH.
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

            ;    MONITOR WORK AREA
            ;    (MZ-80A)

STACK:      EQU     010F0H

            ORG     STACK
SPV:
IBUFE:                                                                   ; TAPE BUFFER (128 BYTES)
ATRB:       DS      virtual 1                                            ; ATTRIBUTE
NAME:       DS      virtual FNSIZE                                       ; FILE NAME
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
ROMCTL:     EQU     0101AH                                               ; Current Bank control register setting.
SCRNMODE:   EQU     0101BH                                               ; Mode of screen, 0 = 40 char, 1 = 80 char.
TMPADR:     EQU     0101CH                                               ; TEMPORARY ADDRESS STORAGE
TMPSIZE:    EQU     0101EH                                               ; TEMPORARY SIZE
TMPCNT:     EQU     01020H                                               ; TEMPORARY COUNTER
TMPLINECNT: EQU     01022H                                               ; Temporary counter for displayed lines.
TMPSTACKP:  EQU     01024H                                               ; Temporary stack pointer save.

        ;    EQU TABLE I/O REPORT

;-----------------------------------------------
; Memory mapped ports in hardware.
;-----------------------------------------------
SCRN:       EQU     0D000H
ARAM:       EQU     0D800H
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
BNKCTRLRST: EQU     0EFF8H                                               ; Bank control reset, returns all registers to power up default.
BNKCTRLDIS: EQU     0EFF9H                                               ; Disable bank control registers by resetting the coded latch.
HWSPIDATA:  EQU     0EFFBH                                               ; Hardware SPI Data register (read/write).
HWSPISTART: EQU     0EFFCH                                               ; Start an SPI transfer.
BNKSELMROM: EQU     0EFFDh                                               ; Select RFS Bank1 (MROM) 
BNKSELUSER: EQU     0EFFEh                                               ; Select RFS Bank2 (User ROM)
BNKCTRL:    EQU     0EFFFH                                               ; Bank Control register (read/write).

;
; RFS v2 Control Register constants.
;
BBCLK       EQU     1                                                    ; BitBang SPI Clock.
SDCS        EQU     2                                                    ; SD Card Chip Select, active low.
BBMOSI      EQU     4                                                    ; BitBang MOSI (Master Out Serial In).
CDLTCH1     EQU     8                                                    ; Coded latch up count bit 1
CDLTCH2     EQU     16                                                   ; Coded latch up count bit 2
CDLTCH3     EQU     32                                                   ; Coded latch up count bit 3
BK2A19      EQU     64                                                   ; User ROM Device Select Bit 0 (or Address bit 19).
BK2A20      EQU     128                                                  ; User ROM Device Select Bit 1 (or Address bit 20).
                                                                         ; BK2A20 : BK2A19
                                                                         ;    0        0   = Flash RAM 0 (default).
                                                                         ;    0        1   = Flash RAM 1.
                                                                         ;    1        0   = Flasm RAM 2 or Static RAM 0.
                                                                         ;    1        1   = Reserved.`

BNKCTRLDEF  EQU     BBMOSI+SDCS+BBCLK                                    ; Default on startup for the Bank Control register.

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
; ROM Banks, 0-7 are reserved for alternative
;            Monitor versions, CPM and RFS
;            code in MROM bank,
;            0-7 are reserved for RFS code in
;            the User ROM bank.
;            8-15 are reserved for CPM code in
;            the User ROM bank.
;-----------------------------------------------
MROMPAGES   EQU     8
USRROMPAGES EQU     12                                                   ; Monitor ROM         :  User ROM
ROMBANK0    EQU     0                                                    ; MROM SA1510 40 Char :  RFS Bank 0 - Main RFS Entry point and functions.
ROMBANK1    EQU     1                                                    ; MROM SA1510 80 Char :  RFS Bank 1 - Floppy disk controller and utilities.
ROMBANK2    EQU     2                                                    ; CPM 2.2 CBIOS       :  RFS Bank 2 - SD Card controller and utilities.
ROMBANK3    EQU     3                                                    ; RFS Utilities       :  RFS Bank 3 - Cmdline tools (Memory, Printer, Help)
ROMBANK4    EQU     4                                                    ; Free                :  RFS Bank 4 - CMT Utilities.
ROMBANK5    EQU     5                                                    ; Free                :  RFS Bank 5
ROMBANK6    EQU     6                                                    ; Free                :  RFS Bank 6
ROMBANK7    EQU     7                                                    ; Free                :  RFS Bank 7 - Memory and timer test utilities.
ROMBANK8    EQU     8                                                    ;                     :  CBIOS Bank 1 - Utilities
ROMBANK9    EQU     9                                                    ;                     :  CBIOS Bank 2 - Screen / ANSI Terminal
ROMBANK10   EQU     10                                                   ;                     :  CBIOS Bank 3 - SD Card
ROMBANK11   EQU     11                                                   ;                     :  CBIOS Bank 4 - Floppy disk controller.

; File types.
OBJCD       EQU     001H                                                 ; MZF contains a binary object.
BTX1CD      EQU     002H                                                 ; MZF contains a BASIC program.
BTX2CD      EQU     005H                                                 ; MZF contains a BASIC program.
TZOBJCD0    EQU     0F8H                                                 ; MZF contains a TZFS binary object for page 0.
TZOBJCD1    EQU     0F8H
TZOBJCD2    EQU     0F8H
TZOBJCD3    EQU     0F8H
TZOBJCD4    EQU     0F8H
TZOBJCD5    EQU     0F8H
TZOBJCD6    EQU     0F8H
TZOBJCD7    EQU     0F8H                                                 ; MZF contains a TZFS binary object for page 7.

; Address definitions.
;
UROMADDR    EQU     0E800H                                               ; Start of User ROM Address space.
MROMJMPTBL  EQU     00070H                                               ; Fixed location of the Monitor ROM Jump Table.
;
; User ROM Jump Table definitions.
;
RFSJMPTABLE EQU     UROMADDR + 00080H                                    ; Entry point to the bank switching table.
PRTMZF      EQU     RFSJMPTABLE + 00000H                                 ; Entry point into User ROM for the PRTMZF function.
PRTDBG      EQU     RFSJMPTABLE + 00003H                                 ; Entry point into User ROM for the PRTDBG function.
;
MZFHDRSZ    EQU     128
RFSSECTSZ   EQU     256
MROMSIZE    EQU     4096
UROMSIZE    EQU     2048
FNSIZE      EQU     17                                                   ; Size of tape filename.

;ROW        EQU      25
;COLW40     EQU      80
;SCRNSZ40   EQU      COLW40 * ROW
;COLW80     EQU      80
;SCRNSZ80   EQU      COLW80 * ROW
;MODE80C    EQU      0

           ;======================================
           ;
           ; MONITOR ROM BANK 3 - RFS Utilities
           ;
           ;======================================
           ORG      00000h

MONIT:
MROMBK3:   JP       START                                                ; The lower part of the rom mimics the SA1510 MROM such that if a reset occurs when
                                                                         ; this bank is paged in, it starts up and reverts to the SA1510 MROM.

           ALIGN_NOPS 0038H
           ORG      0038H                                                ; NMI Vector
           JP       1038H                                                ; Interrupt routine

           ALIGN_NOPS 004AH
           ORG      004Ah

           ; As this is not the monitor ROM, if we arrive at START it means a reset without the monitor rom bank being selected
           ; so we switch it in and do a jump to 0 for reset.
START:     LD       SP, STACK
           IM       1
           CALL     ?MODE
           LD       B,0FFH
           LD       HL,NAME
           CALL     ?CLER
           ;
           CALL     INITBNKCTL
           NOP
           NOP
           NOP
           ; 
           LD       A,(ROMBK2)                                           ; User ROM to default.
           LD       (BNKSELUSER), A
           LD       A, (ROMBK1)                                          ; Monitor ROM to default.
           LD       (BNKSELMROM), A

           ; Location for STRT1 in monitor ROM (just after Colour RAM clear call). After the bank switch we should
           ; resume at this point in original monitor - ie. line commencing LD HL,TIMIN @ 006CH.
           ORG      0006Ch
           JR       START

           ALIGN_NOPS MROMJMPTBL
           ORG      MROMJMPTBL

           ;-----------------------------------------
           ; Enhanced function Jump table.
           ;-----------------------------------------
DIRMROM:   JP       _DIRMROM 
MFINDMZF:  JP       _MFINDMZF 
MROMLOAD:  JP       _MROMLOAD 
           ;-----------------------------------------

           ;====================================
           ;
           ; ROM File System Commands
           ;
           ;====================================

           ; Method to initialise the bank control registers to a default state.
           ;
INITBNKCTL:LD       B,16                                                 ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
INITBNK_1: LD       A,(BNKCTRLRST)
           DJNZ     INITBNK_1                                            ; Apply the default number of coded latch reads to enable the bank control registers.
           LD       A,BNKCTRLDEF                                         ; Set coded latch, SDCS high, BBMOSI to high and BBCLK to high which enables SDCLK.
           LD       (BNKCTRL),A
           LD       (ROMCTL),A                                           ; Save to memory the value in the bank control register - this register is used for SPI etc so need to remember its setting.
           RET


           ; Function to select a User Bank. If Carry is clear upon entry, on exit the control registers will be disabled. If carry is set then the control registers are left active.
           ;

SELUSRBNK: PUSH     BC
           PUSH     AF
           LD       A,(ROMCTL)                                           ; Get current setting for the coded latch, ie. number of reads needed to enable it.
           LD       C,A
           RRA
           RRA
           CPL
           AND      00FH                                                 ; Preserve bits 3-1, bit 0 is always 0 on the 74HCT191 latch.
           LD       B,A                                                  ; Set value to B for loop.
           LD       A,(BNKCTRLDIS)
SELUSRBNK1:LD       A,(BNKSELUSER)
           DJNZ     SELUSRBNK1
           POP      AF
           LD       (BNKSELUSER),A                                       ; Select the required bank.
           LD       A,C
           POP      BC
           JR       NC,SELUSRBNK2                                        ; If Carry is set by caller then leave the control registers active.
           AND      03FH                                                 ; When we leave the registers active, set upper bank bits to 0 to select Flash RAM I, the default.
           LD       (BNKCTRL),A
           RET
SELUSRBNK2:LD       (BNKCTRL),A                                          ; Update the upper address lines according to in-memory value.
           LD       (BNKCTRLDIS),A                                       ; Disable the control registers, value of A is not important.
           RET

           ; Function to select a User Bank. If Carry is clear upon entry, on exit the control registers will be disabled. If carry is set then the control registers are left active.
           ; During normal operations the control registers are enabled. When access is needed to the full User ROM space, ie for drive read/write then the registers are disabled after
           ; setting the correct bank. The upper bits of the User ROM address space (ie. bits 20:19 which select the device) are set to by the ROMCTL variable.
           ;
;SELUSRBNK: PUSH     BC
;           PUSH     AF
;           ; Reset to a known state to allow for spurious read/writes to control area clocking the up counter.
;           LD       B,15
;SEL1:      LD       A,(BNKCTRLDIS)
;           DJNZ     SEL1
;           ; Now loop for the correct up counter required to enable the latches.
;           LD       B,15                                                 ; Set value to B for loop.
;SELUSRBNK1:LD       A,(BNKCTRL)                                          ; Read the latch and compare with sample. Either we reach the count limit or the read differs indicating latch control.
;           DJNZ     SELUSRBNK1
;           POP      AF
;           POP      BC
;           LD       (BNKSELUSER),A                                       ; Select the required bank.
;           LD       A,(ROMCTL)
;           JR       NC,SELUSRBNK2
;           AND      03FH                                                 ; When we leave the registers active, set upper bank bits to 0 to select Flash RAM I, the default.
;           LD       (BNKCTRL),A
;           RET
;SELUSRBNK2:LD       (BNKCTRL),A
;           LD       (BNKCTRLDIS),A                                       ; Disable the control registers, value of A is not important.
;           RET


           ; HL contains address of block to check.
ISMZF:     PUSH     BC
           PUSH     DE
           PUSH     HL
           ;
           LD       A,(HL)
           CP       001h                                                 ; Only interested in machine code images.
           JR       NZ, ISMZFNOT
           ;
           INC      HL
           LD       DE,NAME                                              ; Checks to confirm this is an MZF header.
           LD       B,FNSIZE                                             ; Maximum of 17 characters, including terminator in filename.
ISMZFNXT:  LD       A,(HL)
           LD       (DE),A
           CP       00DH                                                 ; If we find a terminator then this indicates potentially a valid name.
           JR       Z, ISMZFNXT3
           CP       000H                                                 ; Same applies for NULL terminator.
           JR       Z, ISMZFNXT3
           CP       020h                                                 ; >= Space
           JR       C, ISMZFNOT
           CP       05Dh                                                 ; =< ]
           JR       C, ISMZFNXT3
ISMZFNXT2: CP       091h
           JR       C, ISMZFNOT                                          ; DEL or > 0x7F, cant be a valid filename so this is not an MZF header.
ISMZFNXT3: INC      DE
           INC      HL
           DJNZ     ISMZFNXT
ISMZFYES:  CP       A                                                    ; Set zero flag to indicate match.
ISMZFNOT:  POP      HL
           POP      DE
           POP      BC
           RET

           ; B contains Bank to select.
           ; D = File sequence number.
           ; HL contains the Block page address.
_DIRMROM:  PUSH     BC
           ;
           ; Scan MROM Bank
           ; B = Bank Page
           ; C = Block in page
           ;
           LD       B,USRROMPAGES                                        ; First 16x2K pages are reserved in User bank.
           LD       A,(ROMCTL)
           AND      03FH                                                 ; Mask out the upper bank address lines so we start with Flash RAM I.
           ;
DIRNXTDVC: LD       (ROMCTL),A
           LD       C,0                                                  ; Block in page.
DIRNXTPG:  LD       A,B
           LD       (WRKROMBK2), A
           OR       A                                                    ; Select the required user bank and Clear carry so that the control registers are disabled.
           CALL     SELUSRBNK 
           PUSH     BC                                                   ; Preserve bank count/block number.
           PUSH     DE                                                   ; Preserve file numbering.
           LD       A,C
           IF RFSSECTSZ >= 512
             RLCA
           ENDIF
           IF RFSSECTSZ >= 1024
             RLCA
           ENDIF
           LD       B,A
           LD       C,0
           LD       HL,0E800h + RFS_ATRB                                 ; Add block offset to get the valid block address.
           ADD      HL,BC
           CALL     ISMZF
           POP      DE
           POP      BC
           JR       NZ, DIRNOTMZF
           ;
           CALL     _PRTMZF
           INC      D                                                    ; Next file sequence number.
DIRNOTMZF: INC      C
           LD       A,C
           CP       UROMSIZE/RFSSECTSZ                                   ; Max blocks per page reached?
           JR       C, DIRNXTPG2
           LD       C,0
           INC      B
DIRNXTPG2: LD       A,B
           CP       000h                                                 ; User rom has 256 banks of 2K, so stop when we wrap round to 0.
           JR       NZ, DIRNXTPG
           LD       A,(ROMCTL)
           ADD      A, 64
           CP       0C0H                                                 ; If both upper address bits are set then we have come to the end.
           JR       C,DIRNXTDVC
           AND      03FH
           LD       (ROMCTL),A                                           ; Switch back to primary Flash RAM I device.
           LD       A,(ROMBK2)
           SCF                                                           ; Select the required user bank and Set carry so that the control registers remain enabled.
           CALL     SELUSRBNK 
           POP      BC
           RET


           ; Wrapper to call the User ROM function to display the MZF filename.
           ; This function needs to manipulate the banks such that the calling bank is accessible.
_PRTMZF:   LD       A,(ROMBK2)
           SCF                                                           ; Select the required user bank and Set carry so that the control registers remain enabled.
           CALL     SELUSRBNK 
           CALL     PRTMZF
          ;CALL     PRTDBG
           LD       A,(WRKROMBK2)
           OR       A                                                    ; Select the required user bank and Clear carry so that the control registers are disabled.
           CALL     SELUSRBNK 
           RET
     

           ; In:
           ;      HL = filename
           ;      D = File sequence number.
           ; Out:
           ;      B = Bank Page file found
           ;      C = Block where found.
           ;      D = File sequence number.
           ;      Z set if found.
_MFINDMZF: PUSH     DE
           LD       (TMPADR), HL                                         ; Save name of program to load.  
           EX       DE, HL                                               ; String needed in DE for conversion.
           LD       HL,0FFFFh                                            ; Tag the filenumber as invalid.
           LD       (TMPCNT), HL
           CALL     ConvertStringToNumber                                ; See if a file number was given instead of a filename.
           JR       NZ, FINDMZF0                                         ; 
           LD       (TMPCNT), HL                                         ; Store filenumber making load by filenumber valid.
           
           ;
           ; Scan MROM Bank
           ; B = Bank Page
           ; C = Block in page
           ; D = File sequence number.
           ;
           ; Output: B      = Bank where file found
           ;         C      = Block within bank where page found.
           ;         A[7:6] = Upper bits of bank where page found.
           ;
FINDMZF0:  POP      DE                                                   ; Get file sequence number in D.
           LD       B,USRROMPAGES                                        ; First 8 pages are reserved in User ROM bank.
          ;LD       D,0                                                  ; File numbering start.
           LD       A,(ROMCTL)
           AND      03FH                                                 ; Mask out the upper bank address lines so we start with Flash RAM I.
           ;
FINDNXTDVC:LD       (ROMCTL),A
           LD       C,0                                                  ; Block in page.
           ;
FINDMZF1:  LD       A,B
           LD       (WRKROMBK2), A
           OR       A                                                    ; Select the required user bank and Clear carry so that the control registers are disabled.
           CALL     SELUSRBNK 
FINDMZF2:  PUSH     BC                                                   ; Preserve bank count/block number.
           PUSH     DE                                                   ; Preserve file numbering.
           LD       HL,0E800h + RFS_ATRB                                 ; Add block offset to get the valid block.
           LD       A,C
           IF RFSSECTSZ >= 512
             RLCA
           ENDIF
           IF RFSSECTSZ >= 1024
             RLCA
           ENDIF
           LD       B,A
           LD       C,0
           ADD      HL,BC

           CALL     ISMZF
           POP      DE
           POP      BC
           JR       NZ, FINDMZF4                                         ; Z set if we found an MZF record.
           INC      HL                                                   ; Save address of filename.
           PUSH     HL
           LD       HL,(TMPCNT)
           LD       A,H
           CP       0FFh                                                 ; If TMPCNT tagged as 0xFF then we dont have a filenumber so must match filename.
           JR       Z, FINDMZF3
           LD       A,L                                                  ; Check file number, load if match
           CP       D
           JR       NZ, FINDMZF3                                         ; Check name just in case.
           POP      HL
           JR       FINDMZFYES                                           ; Else the filenumber matches so load the file.

FINDMZF3:  POP      HL
           PUSH     DE
           PUSH     BC
           LD       DE,(TMPADR)                                          ; Original DE put onto stack, original filename into DE 
           LD       BC,FNSIZE
           CALL     CMPSTRING
           POP      BC
           POP      DE
           JR       Z, FINDMZFYES
           INC      D                                                    ; Next file sequence number.           
FINDMZF4:  INC      C
           LD       A,C
           CP       UROMSIZE/RFSSECTSZ                                   ; Max blocks per page reached?
           JR       C, FINDMZF5
           LD       C,0
           INC      B
FINDMZF5:  LD       A,B
           CP       000h                                                 ; User ROM has 256 banks of 2K, so stop when we wrap around to zero.
           JR       NZ, FINDMZF1
           ;
           LD       A,(ROMCTL)
           ADD      A, 64
           CP       0C0H                                                 ; If both upper address bits are set then we have come to the end.
           JR       C,FINDNXTDVC
           AND      03FH
           LD       (ROMCTL),A                                           ; Switch back to primary Flash RAM I device.
           ;
           INC      B
           JR       FINDMZFNO
FINDMZFYES:                                                              ; Flag set by previous test.
FINDMZFNO: PUSH     AF
           LD       A,(ROMBK2)
           SCF                                                           ; Select the required user bank and Set carry so that the control registers remain enabled.
           CALL     SELUSRBNK 
           POP      AF
           RET

           LD       A,(ROMCTL)
           AND      03FH
           LD       (ROMCTL),A                                           ; Switch back to primary Flash RAM I device.

           ; Load Program from ROM
           ; Input: B      = Bank of MZF File to load
           ;        C      = Block within bank of start of MZF file.
           ;        A[7:6] = Upper bits of bank containing MZF File to load.
           ; Output:Zero   = Set if file loaded, reset if an error occurred.
           ;
           ; Load program from User ROM Banks I, II or III
           ;
_MROMLOAD: PUSH     BC
           ;
           AND      0C0H                                                 ; Ensure only top two bits are used.
           LD       D,A
           LD       A,(ROMCTL)
           AND      03FH                                                 ; Mask out the upper bank address lines so we can OR in the value given.
           OR       D
           LD       (ROMCTL),A
           ;
           LD       A,B
           LD       (WRKROMBK2),A
           OR       A                                                    ; Select the required user bank and Clear carry so that the control registers are disabled.
           CALL     SELUSRBNK 
           ;
           LD       DE, IBUFE                                            ; Copy the header into the work area.
           LD       HL, 0E800h                                           ; Add block offset to get the valid block.
           LD       A,C
           IF RFSSECTSZ >= 512
             RLCA
           ENDIF
           IF RFSSECTSZ >= 1024
             RLCA
           ENDIF
           LD       B,A
           LD       C,0
           ADD      HL,BC
           LD       BC, MZFHDRSZ

LROMLOAD1: LD       A,(HL)                                               ; Issues with LDIR and a signal artifact from the mainboard, so manual copy.
           INC      HL
           LD       (DE),A
           INC      DE
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,LROMLOAD1

           PUSH     HL
           LD       DE, (DTADR)
           LD       HL, (SIZE)
           LD       BC, RFSSECTSZ - MZFHDRSZ
           OR       A
           SBC      HL, BC
           JR       NC, LROMLOAD4
           LD       HL, (SIZE)
           JR       LROMLOAD4

           ; HL = address in active block to read.
           ;  B = Bank
           ;  C = Block 
LROMLOAD2: LD       A, B
           LD       (WRKROMBK2), A
           OR       A                                                    ; Select the required user bank and Clear carry so that the control registers are disabled.
           CALL     SELUSRBNK 

LROMLOAD3: PUSH     BC
           LD       HL, 0E800h
           LD       A, C
           IF RFSSECTSZ >= 512
             RLCA
           ENDIF
           IF RFSSECTSZ >= 1024
             RLCA
           ENDIF
           LD       B, A
           LD       C, 0
           ADD      HL,BC
           PUSH     HL

           LD       DE, (TMPADR)
           LD       HL, (TMPSIZE)
           LD       BC, RFSSECTSZ
           OR       A
           SBC      HL, BC
           JR       NC, LROMLOAD4
           LD       BC, (TMPSIZE)
           LD       HL, 0
LROMLOAD4: LD       (TMPSIZE), HL                                        ; HL contains remaining amount of bytes to load.
           POP      HL
           ;
           LD       A, B                                                 ; Pre check to ensure BC is not zero.
           OR       C
           JR       Z, LROMLOAD8

LROMLOAD9: LD       (BNKCTRLDIS),A                                       ; There exists an issue with using the mainboard decoder signal which I havent quite understood, random activation of the upcounter occurs which appears to be the refresh circuit. 
           LD       A,(HL)                                               ; Issues with LDIR and a signal artifact from the mainboard, so manual copy.
           INC      HL
           LD       (DE),A
           INC      DE
           DEC      BC
           LD       A,B
           OR       C
           JR       NZ,LROMLOAD9

           LD       BC, (TMPSIZE)
           LD       A, B                                                 ; Post check to ensure we still have bytes
           OR       C
           JR       Z, LROMLOAD8
           ;
           LD       (TMPADR),DE                                          ; Address we are loading into.
           POP      BC
LROMLOAD6: INC      C
           LD       A, C
           CP       UROMSIZE/RFSSECTSZ                                   ; Max blocks per page reached?
           JR       C, LROMLOAD2 ;LROMLOAD3         ;LROMLOAD7
           LD       C, 0
           INC      B
           ;
LROMLOAD7: LD       A, B
           CP       000h
           JR       NZ, LROMLOAD2
           OR       1
           JR       LROMLOAD5
           ;
LROMLOAD8: POP      BC
LROMLOAD5: PUSH     AF
           LD       A,(ROMCTL)
           AND      03FH
           LD       (ROMCTL),A                                           ; Switch back to primary Flash RAM I device.
           LD       A,(ROMBK2)
           SCF                                                           ; Select the required user bank and Set carry so that the control registers remain enabled.
           CALL     SELUSRBNK 
           POP      AF
           RET



           ;======================================
           ;
           ;       SA1510 mirrored functions. 
           ;
           ;======================================

?MODE:     LD       HL,KEYPF
           LD       (HL),08AH
           LD       (HL),007H
           LD       (HL),005H
           LD       (HL),001H
           RET

?CLER:     XOR      A
           JR       ?DINT                   
?CLRFF:    LD       A,0FFH
?DINT:     LD       (HL),A
           INC      HL
           DJNZ     ?DINT                   
           RET      


           ;======================================
           ;
           ;       Message table
           ;
           ;======================================




           ; Bring in additional resources.
           USE_CMPSTRING:    EQU   1
           USE_SUBSTRING:    EQU   0
           USE_INDEX:        EQU   0
           USE_STRINSERT:    EQU   0
           USE_STRDELETE:    EQU   0
           USE_CONCAT:       EQU   0
           USE_CNVUPPER:     EQU   1
           USE_CNVCHRTONUM:  EQU   1
           USE_ISNUMERIC:    EQU   1
           USE_CNVSTRTONUM:  EQU   1
           ;
           INCLUDE "macros.asm"
          ;INCLUDE "rfs_definitions.asm"
           INCLUDE "rfs_utilities.asm"

           ; Ensure we fill the entire 4K by padding with FF's.
           ALIGN    1000H

