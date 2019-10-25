;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_bank6.asm
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
           ; USER ROM BANK 6
           ;
           ;======================================
           ORG      0E800h

           ;--------------------------------
           ; Common code spanning all banks.
           ;--------------------------------
ROMFS6:    NOP
           LD       A, (ROMBK1)                                              ; Ensure all banks are at default on
           CP       4                                                        ; If the ROMBK1 value is 255, an illegal value, then the machine has just started so skip.
           JR       C, ROMFS6_2
           XOR      A                                                        ; Clear the lower stack space as we use it for variables.
           LD       B, 7*8
           LD       HL, 01000H
ROMFS6_1:  LD       (HL),A
           INC      HL
           DJNZ     ROMFS6_1              
ROMFS6_2:  LD       (RFSBK1),A                                               ; start up.
           LD       A, (ROMBK2)
           LD       (RFSBK2),A
           JP       MONITOR

           ;
           ; Bank switching code, allows a call to code in another bank.
           ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
           ;
BKSW6to0:  PUSH     AF
           LD       A, ROMBANK6                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK0                                              ; Required bank to call.
           JR       BKSW6_0
BKSW6to1:  PUSH     AF
           LD       A, ROMBANK6                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK1                                              ; Required bank to call.
           JR       BKSW6_0
BKSW6to2:  PUSH     AF
           LD       A, ROMBANK6                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK2                                              ; Required bank to call.
           JR       BKSW6_0
BKSW6to3:  PUSH     AF
           LD       A, ROMBANK6                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK3                                              ; Required bank to call.
           JR       BKSW6_0
BKSW6to4:  PUSH     AF
           LD       A, ROMBANK6                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK4                                              ; Required bank to call.
           JR       BKSW6_0
BKSW6to5:  PUSH     AF
           LD       A, ROMBANK6                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK5                                              ; Required bank to call.
           JR       BKSW6_0
BKSW6to6:  PUSH     AF
           LD       A, ROMBANK6                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK6                                              ; Required bank to call.
           JR       BKSW6_0
BKSW6to7:  PUSH     AF
           LD       A, ROMBANK6                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK7                                              ; Required bank to call.
           ;
BKSW6_0:   PUSH     BC                                                       ; Save BC for caller.
           LD       BC, BKSWRET6                                             ; Place bank switchers return address on stack.
           PUSH     BC
           LD       (RFSBK2), A                                              ; Bank switch in user rom space, A=bank.
           JP       (HL)                                                     ; Jump to required function.
BKSWRET6:  POP      BC
           POP      AF                                                       ; Get bank which called us.
           LD       (RFSBK2), A                                              ; Return to that bank.
           POP      AF
           RET                                                               ; Return to caller.

           ALIGN    0EFFFh
           DB       0FFh
