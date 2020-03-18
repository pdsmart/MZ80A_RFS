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
;- Copyright:       (c) 2018 Philip Smart <philip.smart@net2net.org>
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

           ;    MONITOR WORK AREA
           ;    (MZ-80A)

STACK:     EQU     010F0H

           ORG     STACK
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
ROMBK1:    EQU      01016H                                               ; CURRENT MROM BANK 
ROMBK2:    EQU      01017H                                               ; CURRENT USERROM BANK 
WRKROMBK1: EQU      01018H                                               ; WORKING MROM BANK 
WRKROMBK2: EQU      01019H                                               ; WORKING USERROM BANK 
SCRNMODE:  EQU      0101AH                                               ; Screen Mode
TMPADR:    EQU      0101BH                                               ; TEMPORARY ADDRESS STORAGE
TMPSIZE:   EQU      0101DH                                               ; TEMPORARY SIZE
TMPCNT:    EQU      0101FH                                               ; TEMPOARY COUNTER
TMPLINECNT:EQU      01021H                                               ; Temporary counter for displayed lines.
TMPSTACKP: EQU      01023H                                               ; Temporary stack pointer save.

        ;    EQU TABLE I/O REPORT

;-----------------------------------------------
; Memory mapped ports in hardware.
;-----------------------------------------------
SCRN:      EQU      0D000H
ARAM:      EQU      0D800H
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
RFSBK1:    EQU      0EFFCh
RFSBK2:    EQU      0EFFDh
RFSRST1:   EQU      0EFFEh
RFSRST2:   EQU      0EFFFh

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

PRTMZF     EQU      0E880H
MZFHDRSZ   EQU      128
RFSSECTSZ  EQU      256
MROMSIZE   EQU      4096
UROMSIZE   EQU      2048

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
MROMBK3:   JP       START                        ; The lower part of the rom mimics the SA1510 MROM such that if a reset occurs when
                                                 ; this bank is paged in, it starts up and reverts to the SA1510 MROM.

           ALIGN_NOPS 0038H
           ORG      0038H                        ; NMI Vector
           JP       1038H                        ; Interrupt routine


           ; As this is not the monitor ROM, if we arrive at START it means a reset without the monitor rom bank being selected
           ; so we switch it in and do a jump to 0 for reset.
           ALIGN_NOPS 004AH
           ORG      004Ah
START:     LD       SP, STACK
           IM       1
           CALL     ?MODE
           LD       B,0FFH
           LD       HL,NAME
           CALL     ?CLER
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           LD       A,(ROMBK2)                  ; User ROM to default.
           LD       (RFSBK2), A
           LD       A, (ROMBK1)                 ; Monitor ROM to default.
           LD       (RFSBK1), A

           ; Location for STRT1 in monitor ROM (just after Colour RAM clear call). After the bank switch we should
           ; resume at this point in original monitor.
           ORG      06Ch
           JR       START

           ;-----------------------------------------
           ; Enhanced function Jump table.
           ;-----------------------------------------
DIRMROM:   JP       _DIRMROM 
MFINDMZF:  JP       _MFINDMZF 
MROMLOAD:  JP       _MROMLOAD 
           ;-----------------------------------------

;
;====================================
;
; ROM File System Commands
;
;====================================

           ; HL contains address of block to check.
ISMZF:     PUSH     BC
           PUSH     DE
           PUSH     HL
           ;
           LD       A,(HL)
           CP       001h                        ; Only interested in machine code images.
           JR       NZ, ISMZFNOT
           ;
           INC      HL
           LD       DE,NAME                     ; Checks to confirm this is an MZF header.
           LD       B,17                        ; Maximum of 17 characters, including terminator in filename.
ISMZFNXT:  LD       A,(HL)
           LD       (DE),A
           CP       00Dh                        ; If we find a terminator then this indicates potentially a valid name.
           JR       Z, ISMZFVFY
           CP       020h                        ; >= Space
           JR       C, ISMZFNOT
           CP       05Dh                        ; =< ]
           JR       C, ISMZFNXT3
ISMZFNXT2: CP       091h
           JR       C, ISMZFNOT                 ; DEL or > 0x7F, cant be a valid filename so this is not an MZF header.
ISMZFNXT3: INC      DE
           INC      HL
           DJNZ     ISMZFNXT
           JR       ISMZFNOT                    ; No end of string terminator, this cant be a valid filename.
ISMZFVFY:  LD       A,B
           CP       17
           JR       Z,ISMZFNOT                  ; If the filename has no length it cant be valid, so loop.
ISMZFYES:  CP       A                           ; Set zero flag to indicate match.
ISMZFNOT:  POP      HL
           POP      DE
           POP      BC
           RET

           ; B contains Bank to select.
           ; HL contains the Block page address.
_DIRMROM:  PUSH     BC
           PUSH     DE
           ;
           ; Scan MROM Bank
           ; B = Bank Page
           ; C = Block in page
           ; D = File sequence number.
           ;
           LD       B,USRROMPAGES               ; First 16x2K pages are reserved in User bank.
           LD       C,0                         ; Block in page.
DIRNXTPG:  LD       A,B
           LD       (WRKROMBK2), A
           LD       (RFSBK2), A                 ; Select bank.
           PUSH     BC                          ; Preserve bank count/block number.
           PUSH     DE                          ; Preserve file numbering.
           LD       A,C
           IF RFSSECTSZ >= 512
             RLCA
           ENDIF
           IF RFSSECTSZ >= 1024
             RLCA
           ENDIF
           LD       B,A
           LD       C,0
           LD       HL,0E800h + RFS_ATRB        ; Add block offset to get the valid block address.
           ADD      HL,BC
           CALL     ISMZF
           POP      DE
           POP      BC
           JR       NZ, DIRNOTMZF
           ;
           CALL     _PRTMZF
           INC      D                           ; Next file sequence number.
DIRNOTMZF: INC      C
           LD       A,C
           CP       UROMSIZE/RFSSECTSZ       ; Max blocks per page reached?
           JR       C, DIRNXTPG2
           LD       C,0
           INC      B
DIRNXTPG2: LD       A,B
           CP       000h                        ; User rom has 256 banks of 2K, so stop when we wrap round to 0.
           JR       NZ, DIRNXTPG
           LD       A,(ROMBK2)
           LD       (RFSBK2), A                 ; Set the User bank back to original.
           POP      DE
           POP      BC
           RET


           ; Wrapper to call the User ROM function to display the MZF filename.
_PRTMZF:   LD       A,(ROMBK2)
           LD       (RFSBK2), A
           CALL     PRTMZF
           LD       A,(WRKROMBK2)
           LD       (RFSBK2), A
           RET
     

           ; In:
           ;     HL = filename
           ; Out:
           ;      B = Bank Page file found
           ;      C = Block where found.
           ;      D = File sequence number.
           ;      Z set if found.
_MFINDMZF: PUSH     DE
           LD       (TMPADR), HL                ; Save name of program to load.  
           EX       DE, HL                      ; String needed in DE for conversion.
           LD       HL,0FFFFh                   ; Tag the filenumber as invalid.
           LD       (TMPCNT), HL
           CALL     ConvertStringToNumber       ; See if a file number was given instead of a filename.
           JR       NZ, FINDMZF0                ; 
           LD       (TMPCNT), HL                ; Store filenumber making load by filenumber valid.
           
           ;
           ; Scan MROM Bank
           ; B = Bank Page
           ; C = Block in page
           ; D = File sequence number.
           ;
FINDMZF0:  POP      DE                          ; Get file sequence number in D.
           LD       B,USRROMPAGES               ; First 8 pages are reserved in User ROM bank.
           LD       C,0                         ; Block in page.
          ;LD       D,0                         ; File numbering start.
FINDMZF1:  LD       A,B
           LD       (WRKROMBK2), A
           LD       (RFSBK2), A                 ; Select bank.
FINDMZF2:  PUSH     BC                          ; Preserve bank count/block number.
           PUSH     DE                          ; Preserve file numbering.
           LD       HL,0E800h + RFS_ATRB        ; Add block offset to get the valid block.
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
           JR       NZ, FINDMZF4                ; Z set if we found an MZF record.
           INC      HL                          ; Save address of filename.
           PUSH     HL
           LD       HL,(TMPCNT)
           LD       A,H
           CP       0FFh                        ; If TMPCNT tagged as 0xFF then we dont have a filenumber so must match filename.
           JR       Z, FINDMZF3
           LD       A,L                         ; Check file number, load if match
           CP       D
           JR       NZ, FINDMZF3                ; Check name just in case.
           POP      HL
           JR       FINDMZFYES                  ; Else the filenumber matches so load the file.

FINDMZF3:  POP      HL
           PUSH     DE
           PUSH     BC
           LD       DE,(TMPADR)                 ; Original DE put onto stack, original filename into DE 
           LD       BC,17
           CALL     CMPSTRING
           POP      BC
           POP      DE
           JR       Z, FINDMZFYES
           INC      D                           ; Next file sequence number.           
FINDMZF4:  INC      C
           LD       A,C
           CP       UROMSIZE/RFSSECTSZ          ; Max blocks per page reached?
           JR       C, FINDMZF5
           LD       C,0
           INC      B
FINDMZF5:  LD       A,B
           CP       000h                        ; User ROM has 256 banks of 2K, so stop when we wrap around to zero.
           JR       NZ, FINDMZF1
           INC      B
           JR       FINDMZFNO

FINDMZFYES:                                     ; Flag set by previous test.
FINDMZFNO: PUSH     AF
           LD       A,(ROMBK2)
           LD       (RFSBK2), A                 ; Set the MROM bank back to original.
           POP      AF
           RET


           ; Load Program from ROM
           ; IN    BC     Bank and Block to of MZF file.
           ; OUT   zero   Set if file loaded, reset if an error occurred.
           ;
           ; Load program from RFS Bank 1 (MROM Bank)
           ;
_MROMLOAD: PUSH     BC
           LD       A,B
           LD       (WRKROMBK2),A
           LD       (RFSBK2), A
           ;
           LD       DE, IBUFE                   ; Copy the header into the work area.
           LD       HL, 0E800h                  ; Add block offset to get the valid block.
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
           LDIR

           PUSH     HL
           LD       DE, (DTADR)
           LD       HL, (SIZE)
           LD       BC, RFSSECTSZ - MZFHDRSZ
           SBC      HL, BC
           JR       NC, LROMLOAD4
           LD       HL, (SIZE)
           JR       LROMLOAD4

           ; HL = address in active block to read.
           ;  B = Bank
           ;  C = Block 
LROMLOAD2: LD       A, B
           LD       (WRKROMBK2), A
           LD       (RFSBK2), A

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
           SBC      HL, BC
           JR       NC, LROMLOAD4
           LD       BC, (TMPSIZE)
           LD       HL, 0
LROMLOAD4: LD       (TMPSIZE), HL               ; HL contains remaining amount of bytes to load.
           POP      HL
           ;
           LD       A, B                        ; Pre check to ensure BC is not zero.
           OR       C
           JR       Z, LROMLOAD8
           LDIR
           LD       BC, (TMPSIZE)
           LD       A, B                        ; Post check to ensure we still have bytes
           OR       C
           JR       Z, LROMLOAD8
           ;
           LD       (TMPADR),DE                 ; Address we are loading into.
           POP      BC
LROMLOAD6: INC      C
           LD       A, C
           CP       UROMSIZE/RFSSECTSZ          ; Max blocks per page reached?
           JR       C, LROMLOAD7
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
           LD       A,(ROMBK2)
           LD       (RFSBK2), A                 ; Set the MROM bank back to original.
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
           INCLUDE "Macros.asm"
          ;INCLUDE "RFS_Definitions.asm"
           INCLUDE "RFS_Utilities.asm"

           ; Ensure we fill the entire 4K by padding with FF's.
           ALIGN    1000H

;
;======================================
;
;       Message table
;
;======================================
