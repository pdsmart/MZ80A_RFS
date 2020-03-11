;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_bank2.asm
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

           ;======================================
           ;
           ; USER ROM BANK 2
           ;
           ;======================================
           ORG      0E800h

           ;--------------------------------
           ; Common code spanning all banks.
           ;--------------------------------
ROMFS2:    NOP
           XOR     A                                                         ; We shouldnt arrive here after a reset, if we do, select UROM bank 0
           LD      (RFSBK1),A
           LD      (RFSBK2),A                                                ; and start up - ie. SA1510 Monitor.
           ALIGN_NOPS 0E829H

           ; Bank switching code, allows a call to code in another bank.
           ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
           ;
BKSW2to0:  PUSH     AF
           LD       A, ROMBANK2                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK0                                              ; Required bank to call.
           JR       BKSW2_0
BKSW2to1:  PUSH     AF
           LD       A, ROMBANK2                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK1                                              ; Required bank to call.
           JR       BKSW2_0
BKSW2to2:  PUSH     AF
           LD       A, ROMBANK2                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK2                                              ; Required bank to call.
           JR       BKSW2_0
BKSW2to3:  PUSH     AF
           LD       A, ROMBANK2                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK3                                              ; Required bank to call.
           ;
BKSW2_0:   PUSH     BC                                                       ; Save BC for caller.
           LD       BC, BKSWRET2                                             ; Place bank switchers return address on stack.
           PUSH     BC
           LD       (RFSBK2), A                                              ; Bank switch in user rom space, A=bank.
           LD       (TMPSTACKP),SP                                           ; Save the stack pointer as some old code corrupts it.
           JP       (HL)                                                     ; Jump to required function.
BKSWRET2:  POP      BC
           POP      AF                                                       ; Get bank which called us.
           LD       (RFSBK2), A                                              ; Return to that bank.
           POP      AF
           RET                                                               ; Return to caller.

           ; Simple help screen to display commands.
HELP:      CALL     NL
           LD       DE, HELPSCR
           CALL     PRTSTR
           RET

           ; Modification of original MSG function, use NULL terminated strings not CR terminated.
PRTSTR:    PUSH     AF
           PUSH     BC
           PUSH     DE
PRTSTR1:   LD       A,(DE)
           CP       000H
           JR       Z,PRTSTRE                 
           CALL     PRNT
           INC      DE
           JR       PRTSTR1                   
PRTSTRE:   POP      DE
           POP      BC
           POP      AF
           RET     

           ; Help text. Use of lower case, due to Sharp's non standard character set, is not easy, you have to manually code each byte
           ; hence using upper case.
HELPSCR:   DB       "4     - 40 COL MODE.",                                 00DH
           DB       "8     - 80 COL MODE.",                                 00DH
           DB       "B     - TOGGLE KEYBOARD BELL.",                        00DH
           DB       "C     - CLEAR MEMORY $1200-$D000.",                    00DH
           DB       "DXXXX[YYYY] - DUMP MEM XXXX TO YYYY.",                 00DH
           DB       "F[X]  - BOOT FD DRIVE X.",                             00DH
           DB  0AAH, "     - BOOT FD ORIGINAL ROM.",                        00DH
           DB       "H     - THIS HELP SCREEN.",                            00DH
           DB       "I     - RFS DIRECTORY LISTING.",                       00DH
           DB       "JXXXX - JUMP TO LOCATION XXXX.",                       00DH
           DB       "L[FN] - LOAD RFS/TAPE, FN=NO OR FN.",                  00DH
           DB  0B8H, "[FN] - AS ABOVE BUT DONT AUTO-EXEC.",                 00DH
           DB       "MXXXX - EDIT MEMORY STARTING AT XXXX.",                00DH
           DB       "P     - TEST PRINTER.",                                00DH
           DB       "R     - TEST DRAM MEMORY.",                            00DH
           DB       "S     - SAVE CURRENT PROG TO TAPE.",                   00DH
           DB       "T     - TEST TIMER.",                                  00DH
           DB       "V     - VERIFY TAPE SAVE.",                            00DH
           DB       000H

           ALIGN    0EFFFh
           DB       0FFh
