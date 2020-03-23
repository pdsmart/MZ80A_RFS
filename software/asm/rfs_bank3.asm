;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_bank3.asm
;- Created:         October 2018
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series Rom Filing System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade.
;-
;- Credits:         
;- Copyright:       (c) 2018 Philip Smart <philip.smart@net2net.org>
;-
;- History:         October 2018 - Merged 2 utilities to create this compilation.
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

ROW         EQU     25
COLW        EQU     40
SCRNSZ      EQU     COLW * ROW
MODE80C     EQU     0

            ;===========================================================
            ;
            ; USER ROM BANK 3 - Monitor memory and help utilities.
            ;
            ;===========================================================
            ORG     UROMADDR

            ;--------------------------------
            ; Common code spanning all banks.
            ;--------------------------------
ROMFS3:     NOP
            XOR     A                                                         ; We shouldnt arrive here after a reset, if we do, select UROM bank 0
            LD      (RFSBK1),A
            LD      (RFSBK2),A                                                ; and start up - ie. SA1510 Monitor.
            ALIGN_NOPS 0E829H

            ;
            ; Bank switching code, allows a call to code in another bank.
            ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
            ;
BKSW3to0:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK0                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to1:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK1                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to2:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK2                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to3:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK3                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to4:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK4                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to5:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK5                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to6:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK6                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to7:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK7                                              ; Required bank to call.
            ;
BKSW3_0:    PUSH    BC                                                       ; Save BC for caller.
            LD      BC, BKSWRET3                                             ; Place bank switchers return address on stack.
            PUSH    BC
            LD      (RFSBK2), A                                              ; Bank switch in user rom space, A=bank.
            LD      (TMPSTACKP),SP                                           ; Save the stack pointer as some old code corrupts it.
            JP      (HL)                                                     ; Jump to required function.
BKSWRET3:   POP     BC
            POP     AF                                                       ; Get bank which called us.
            LD      (RFSBK2), A                                              ; Return to that bank.
            POP     AF
            RET                                                              ; Return to caller.



           ;-------------------------------------------------------------------------------
           ; START OF MEMORY CMDLINE TOOLS FUNCTIONALITY
           ;-------------------------------------------------------------------------------

;
;       Memory correction
;       command 'M'
;
MCORX:      CALL    GETHEX                                               ; correction address
MCORX1:     CALL    NLPHL                                                ; corr. adr. print
            CALL    SPHEX                                                ; ACC ASCII display
            CALL    PRNTS                                                ; space print
            CALL    BGETLX                                               ; get data & check data
            CALL    HLHEX                                                ; HLASCII(DE)
            JR      C,MCRX3
            CALL    DOT4DE                                               ; INC DE * 4
            INC     DE
            CALL    _2HEX                                                ; data check
            JR      C,MCORX1
            CP      (HL)
            JR      NZ,MCORX1
            INC     DE
            LD      A,(DE)
            CP      00Dh                                                 ; not correction
            JR      Z,MCRX2
            CALL    _2HEX                                                ; ACCHL(ASCII)
            JR      C,MCORX1
            LD      (HL),A                                               ; data correct
MCRX2:      INC     HL
            JR      MCORX1
MCRX3:      LD      H,B                                                  ; memory address
            LD      L,C
            JR      MCORX1


DUMPX:      CALL    GETHEX
            CALL    DOT4DE
            PUSH    HL
            CALL    HLHEX
            POP     DE
            JR      C,DUM4
DUM1:       EX      DE,HL
DUM3:       LD      B,008h
            LD      C,017h
            CALL    NLPHL
DUM2:       CALL    SPHEX
            INC     HL
            PUSH    AF
            LD      A,(DSPXY)
            ADD     A,C
            LD      (DSPXY),A
            POP     AF
            CP      020h
            JR      NC,L0D51
            LD      A,02Eh
L0D51:      CALL    ?ADCN
            CALL    PRNT3
            LD      A,(DSPXY)
            INC     C
            SUB     C
            LD      (DSPXY),A
            DEC     C
            DEC     C
            DEC     C
            PUSH    HL
            SBC     HL,DE
            POP     HL
            JR      Z,L0D85
            LD      A,0F8h
            LD      (0E000h),A
            NOP
            LD      A,(0E001h)
            CP      0FEh
            JR      NZ,L0D78
            CALL    ?BLNK
L0D78:      DJNZ    DUM2
L0D7A:      CALL    ?KEY
            OR      A
            JR      Z,L0D7A
            CALL    BRKEY
            JP      NZ,DUM3
L0D85:      RET                     ; JR       LEA76
DUM4:       LD      HL,000A0h
            ADD     HL,DE
            JR      DUM1            

           ; Clear memory.
INITMEMX:   LD      DE,MSG_INITM
            CALL    MSG
            CALL    LETNL
            LD      HL,1200h
            LD      BC,0D000h - 1200h
CLEAR1:     LD      A,00h
            LD      (HL),A
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JP      NZ,CLEAR1
            RET

BGETLX:     EX      (SP),HL
            POP     BC
            LD      DE,BUFER
            CALL    GETL
            LD      A,(DE)
            CP      01Bh
            JP      Z,GETHEX2
            JP      (HL)

GETHEX:     EX      (SP),IY
            POP     AF
            CALL    HLHEX
            JR      C,GETHEX2
            JP      (IY)
GETHEX2:    POP     AF                                                   ; Waste the intermediate caller address
            RET    

    
           ;    INCREMENT DE REG.
DOT4DE:    INC      DE
           INC      DE
           INC      DE
           INC      DE
           RET   

           ;    SPACE PRINT AND DISP ACC
           ;    INPUT:HL=DISP. ADR.
SPHEX:     CALL     PRNTS                                                ; SPACE PRINT
           LD       A,(HL)
           CALL     PRTHX                                                ; DSP OF ACC (ASCII)
           LD       A,(HL)
           RET

           ;    NEW LINE AND PRINT HL REG (ASCII)
NLPHL:     CALL     NL
           CALL     PRTHL
           RET  
           ;-------------------------------------------------------------------------------
           ; END OF MEMORY CMDLINE TOOLS FUNCTIONALITY
           ;-------------------------------------------------------------------------------

           ;-------------------------------------------------------------------------------
           ; START OF PRINTER CMDLINE TOOLS FUNCTIONALITY
           ;-------------------------------------------------------------------------------
PTESTX:    LD       A,(DE)
           CP       '&'                                                  ; plotter test
           JR       NZ,PTST1X
PTST0X:    INC      DE
           LD       A,(DE)
           CP       'L'                                                  ; 40 in 1 line
           JR       Z,.LPTX
           CP       'S'                                                  ; 80 in 1 line
           JR       Z,..LPTX
           CP       'C'                                                  ; Pen change
           JR       Z,PENX
           CP       'G'                                                  ; Graph mode
           JR       Z,PLOTX
           CP       'T'                                                  ; Test
           JR       Z,PTRNX
;
PTST1X:    CALL     PMSGX
ST1X2:     RET
.LPTX:     LD       DE,LLPT                                              ; 01-09-09-0B-0D
           JR       PTST1X
..LPTX:    LD       DE,SLPT                                              ; 01-09-09-09-0D
           JR       PTST1X
PTRNX:     LD       A,004h                                               ; Test pattern
           JR       LE999
PLOTX:     LD       A,002h                                               ; Graph mode
LE999:     CALL     LPRNTX
           JR       PTST0X
PENX:      LD       A,01Dh                                               ; 1 change code (text mode)
           JR       LE999
;
;
;       1 char print to $LPT
;
;        in: ACC print data
;
;
LPRNTX:    LD       C,000h                                               ; RDAX test
           LD       B,A                                                  ; print data store
           CALL     RDAX
           LD       A,B
           OUT      (0FFh),A                                             ; data out
           LD       A,080h                                               ; RDP high
           OUT      (0FEh),A
           LD       C,001h                                               ; RDA test
           CALL     RDAX
           XOR      A                                                    ; RDP low
           OUT      (0FEh),A
           RET
;
;       $LPT msg.
;       in: DE data low address
;       0D msg. end
;
PMSGX:     PUSH     DE
           PUSH     BC
           PUSH     AF
PMSGX1:    LD       A,(DE)                                               ; ACC = data
           CALL     LPRNTX
           LD       A,(DE)
           INC      DE
           CP       00Dh                                                 ; end ?
           JR       NZ,PMSGX1
           POP      AF
           POP      BC
           POP      DE
           RET

;
;       RDA check
;
;       BRKEY in to monitor return
;       in: C RDA code
;
RDAX:       IN      A,(0FEh)
            AND     00Dh
            CP      C
            RET     Z
            CALL    BRKEY
            JR      NZ,RDAX
            LD      SP,ATRB
            JR      ST1X2

            ;    40 CHA. IN 1 LINE CODE (DATA)
LLPT:       DB      01H                                                  ; TEXT MODE
            DB      09H
            DB      09H
            DB      0BH
            DB      0DH

            ;    80 CHA. 1 LINE CODE (DATA)
SLPT:       DB      01H                                                  ; TEXT MODE
            DB      09H
            DB      09H
            DB      09H
            DB      0DH

            ;-------------------------------------------------------------------------------
            ; END OF PRINTER CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF HELP SCREEN FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Simple help screen to display commands.
HELP:       CALL    NL
            LD      DE, HELPSCR
            CALL    PRTSTR
            RET

            ; Modification of original MSG function, use NULL terminated strings not CR terminated and include page pause.
PRTSTR:     PUSH    AF
            PUSH    BC
            PUSH    DE
            LD      A,0
            LD      (TMPLINECNT),A
PRTSTR1:    LD      A,(DE)
            CP      000H
            JR      Z,PRTSTRE
            CP      00DH
            JR      Z,PRTSTR3
PRTSTR2:    CALL    PRNT
            INC     DE
            JR      PRTSTR1                   
PRTSTR3:    PUSH    AF
            LD      A,(TMPLINECNT)
            CP      24
            JR      Z,PRTSTR5
            INC     A
PRTSTR4:    LD      (TMPLINECNT),A
            POP     AF
            JR      PRTSTR2
PRTSTR5:    CALL    GETKY
            CP      ' '
            JR      NZ,PRTSTR5
            XOR     A
            JR      PRTSTR4
PRTSTRE:    POP     DE
            POP     BC
            POP     AF
            RET     

            ; Help text. Use of lower case, due to Sharp's non standard character set, is not easy, you have to manually code each byte
            ; hence using upper case.
HELPSCR:    DB      "4     - 40 COL MODE.",                                 00DH
            DB      "8     - 80 COL MODE.",                                 00DH
            DB      "B     - TOGGLE KEYBOARD BELL.",                        00DH
            DB      "C     - CLEAR MEMORY $1200-$D000.",                    00DH
            DB      "DXXXX[YYYY] - DUMP MEM XXXX TO YYYY.",                 00DH
            DB      "F[X]  - BOOT FD DRIVE X.",                             00DH
            DB  0AAH,"     - BOOT FD ORIGINAL ROM.",                        00DH
            DB      "H     - THIS HELP SCREEN.",                            00DH
            DB      "IR/IC - RFS DIR LISTING ROM/SD CARD.",                 00DH
            DB      "JXXXX - JUMP TO LOCATION XXXX.",                       00DH
            DB      "LT[FN]- LOAD TAPE, FN=FILENAME",                       00DH
            DB      "LR[FN]- LOAD ROM, FN=NO OR NAME",                      00DH
            DB      "LC[FN]- LOAD SDCARD, FN=NO OR NAME",                   00DH
            DB      "      - ADD NX FOR NO EXEC, IE.LRNX.",                 00DH
            DB      "MXXXX - EDIT MEMORY STARTING AT XXXX.",                00DH
            DB      "P     - TEST PRINTER.",                                00DH
            DB      "R     - TEST DRAM MEMORY.",                            00DH
            DB      "ST[XXXXYYYYZZZZ] - SAVE MEM TO TAPE.",                 00DH
            DB      "SC[XXXXYYYYZZZZ] - SAVE MEM TO CARD.",                 00DH
            DB      "        XXXX=START,YYYY=END,ZZZZ=EXEC",                00DH
            DB      "T     - TEST TIMER.",                                  00DH
            DB      "V     - VERIFY TAPE SAVE.",                            00DH
            DB      000H

            ;-------------------------------------------------------------------------------
            ; END OF HELP SCREEN FUNCTIONALITY
            ;-------------------------------------------------------------------------------


            ;--------------------------------------
            ;
            ; Message table
            ;
            ;--------------------------------------

MSG_INITM:  DB      "INIT MEMORY",           00DH

            ALIGN   0EFFFh
            DB      0FFh
