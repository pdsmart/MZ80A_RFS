;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_bank5.asm
;- Created:         October 2018
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series Rom Filing System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade.
;-
;- Credits:         
;- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
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
            ; USER ROM BANK 5
            ;
            ;======================================
            ORG     0E800h

            ;--------------------------------
            ; Common code spanning all banks.
            ;--------------------------------
ROMFS5:     NOP
            XOR     A                                                         ; We shouldnt arrive here after a reset, if we do, select UROM bank 0
            LD      (RFSBK1),A
            LD      (RFSBK2),A                                                ; and start up - ie. SA1510 Monitor.
            ALIGN_NOPS 0E829H

            ;
            ; Bank switching code, allows a call to code in another bank.
            ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
            ;
BKSW5to0:   PUSH    AF
            LD      A, ROMBANK5                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK0                                              ; Required bank to call.
            JR      BKSW5_0
BKSW5to1:   PUSH    AF
            LD      A, ROMBANK5                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK1                                              ; Required bank to call.
            JR      BKSW5_0
BKSW5to2:   PUSH    AF
            LD      A, ROMBANK5                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK2                                              ; Required bank to call.
            JR      BKSW5_0
BKSW5to3:   PUSH    AF
            LD      A, ROMBANK5                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK3                                              ; Required bank to call.
            JR      BKSW5_0
BKSW5to4:   PUSH    AF
            LD      A, ROMBANK5                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK4                                              ; Required bank to call.
            JR      BKSW5_0
BKSW5to5:   PUSH    AF
            LD      A, ROMBANK5                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK5                                              ; Required bank to call.
            JR      BKSW5_0
BKSW5to6:   PUSH    AF
            LD      A, ROMBANK5                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK6                                              ; Required bank to call.
            JR      BKSW5_0
BKSW5to7:   PUSH    AF
            LD      A, ROMBANK5                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK7                                              ; Required bank to call.
            ;
BKSW5_0:    PUSH    HL                                                       ; Place function to call on stack
            LD      HL, BKSWRET5                                             ; Place bank switchers return address on stack.
            EX      (SP),HL
            LD      (TMPSTACKP),SP                                           ; Save the stack pointer as some old code corrupts it.
            LD      (RFSBK2), A                                              ; Bank switch in user rom space, A=bank.
            JP      (HL)                                                     ; Jump to required function.
BKSWRET5:   POP     AF                                                       ; Get bank which called us.
            LD      (RFSBK2), A                                              ; Return to that bank.
            POP     AF
            RET                                                              ; Return to caller.



            ALIGN   0EFFFh
            DB      0FFh
