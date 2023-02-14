;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_bank5.asm
;- Created:         July 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series Rom Filing System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade.
;-
;- Credits:         
;- Copyright:       (c) 2018-2023 Philip Smart <philip.smart@net2net.org>
;-
;- History:         July 2019 - Merged 2 utilities to create this compilation.
;                   May 2020  - Bank switch changes with release of v2 pcb with coded latch. The coded
;                               latch adds additional instruction overhead as the control latches share
;                               the same address space as the Flash RAMS thus the extra hardware to
;                               only enable the control registers if a fixed number of reads is made
;                               into the upper 8 bytes which normally wouldnt occur. Caveat - ensure
;                               that no loop instruction is ever placed into EFF8H - EFFFH.
;                   Mar 2021 -  Add mapping utilities for Sharp<->ASCII conversion.
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
            ; USER ROM BANK 5 - Utilities
            ;
            ;======================================
            ORG     UROMADDR

            ;--------------------------------
            ; Common code spanning all banks.
            ;--------------------------------
            NOP
            LD      B,16                                                     ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
ROMFS5_0:   LD      A,(BNKCTRLRST)
            DJNZ    ROMFS5_0                                                 ; Apply the default number of coded latch reads to enable the bank control registers.
            LD      A,BNKCTRLDEF                                             ; Set coded latch, SDCS high, BBMOSI to high and BBCLK to high which enables SDCLK.
            LD      (BNKCTRL),A
            NOP
            NOP
            NOP
            XOR     A                                                        ; We shouldnt arrive here after a reset, if we do, select UROM bank 0
            LD      (BNKSELMROM),A
            NOP
            NOP
            NOP
            LD      (BNKSELUSER),A                                           ; and start up - ie. SA1510 Monitor - this occurs as User Bank 0 is enabled and the jmp to 0 is coded in it.
            ;
            ; No mans land... this should have switched to Bank 0 and at this point there is a jump to 00000H.
            JP      00000H                                                   ; This is for safety!!


            ;------------------------------------------------------------------------------------------
            ; Bank switching code, allows a call to code in another bank.
            ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
            ;------------------------------------------------------------------------------------------     
            ALIGN_NOPS UROMBSTBL
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
            LD      (BNKSELUSER), A                                          ; Repeat the bank switch B times to enable the bank control register and set its value.
            JP      (HL)                                                     ; Jump to required function.
BKSWRET5:   POP     AF                                                       ; Get bank which called us.
            LD      (BNKSELUSER), A                                          ; Return to that bank.
            POP     AF
            RET  


            ; Method to convert a string with Sharp ASCII codes into standard ASCII codes via map lookup.
            ; Inputs: DE = pointer to string for conversion.
            ;         B  = Maximum number of characters to convert if string not terminated.
            ;
CNVSTR_SA:  PUSH    HL
            PUSH    DE
            PUSH    BC
CNVSTRSA1:  LD      A,(DE)                                                   ; Get character for conversion.
            OR      A                                                        ; Exit at End of String (NULL, CR)
            JR      Z,CNVSTRSAEX
            CP      00DH
            JR      Z,CNVSTRSAEX
            CP      020H                                                     ; No point mapping control characters.
            JR      C,CNVSTRSA2
            ;
            LD      HL,SHARPTOASC                                            ; Start of mapping table.
            PUSH    BC
            LD      C,A
            LD      B,0
            ADD     HL,BC                                                    ; Add in character offset.
            POP     BC
            LD      A,(HL)
            LD      (DE),A                                                   ; Map character.
CNVSTRSA2:  INC     DE
            DJNZ    CNVSTRSA1
CNVSTRSAEX: POP     BC                                                       ; Restore all registers used except AF.
            POP     DE
            POP     HL
            RET

            ; Method to convert a string with standard ASCII into Sharp ASCII codes via scan lookup in the mapping table.
            ; Inputs: DE = pointer to string for conversion.
            ;         B  = Maximum number of characters to convert if string not terminated.
CNVSTR_AS:  PUSH    HL
            PUSH    DE
            PUSH    BC
CNVSTRAS1:  LD      A,(DE)                                                   ; Get character for conversion.
            OR      A                                                        ; Exit at End of String (NULL, CR)
            JR      Z,CNVSTRSAEX
            CP      00DH
            JR      Z,CNVSTRSAEX
            CP      020H                                                     ; No point mapping control characters.
            JR      C,CNVSTRAS5

            LD      HL,SHARPTOASC + 020H
            PUSH    BC
            LD      B, 0100H - 020H
CNVSTRAS2:  CP      (HL)                                                     ; Go through table looking for a match.
            JR      Z,CNVSTRAS3
            INC     HL
            DJNZ    CNVSTRAS2
            JR      CNVSTRAS4                                                ; No match then dont convert.
CNVSTRAS3:  LD      BC,SHARPTOASC                                            ; On match or expiration of BC subtract table starting point to arrive at index.
            OR      A
            SBC     HL,BC
            LD      A,L                                                      ; Index is used as the converted character.
CNVSTRAS4:  LD      (DE),A
            POP     BC
CNVSTRAS5:  INC     DE
            DJNZ    CNVSTRAS1
            JR      CNVSTRSAEX

            ; Mapping table to convert between Sharp ASCII and standard ASCII.
            ; Sharp -> ASCII : Index with Sharp value into table to obtain conversion.
            ; ASCII -> Sharp : Scan into table looking for value, on match the idx is the conversion. NB 0x20 = 0x20.
SHARPTOASC: DB      000H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  000H,  020H,  020H ; 0x0F
            DB      020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H ; 0x1F
            DB      020H,  021H,  022H,  023H,  024H,  025H,  026H,  027H,  028H,  029H,  02AH,  02BH,  02CH,  02DH,  02EH,  02FH ; 0x2F
            DB      030H,  031H,  032H,  033H,  034H,  035H,  036H,  037H,  038H,  039H,  03AH,  03BH,  03CH,  03DH,  03EH,  03FH ; 0x3F
            DB      040H,  041H,  042H,  043H,  044H,  045H,  046H,  047H,  048H,  049H,  04AH,  04BH,  04CH,  04DH,  04EH,  04FH ; 0x4F
            DB      050H,  051H,  052H,  053H,  054H,  055H,  056H,  057H,  058H,  059H,  05AH,  05BH,  05CH,  05DH,  05EH,  05FH ; 0x5F
            DB      020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H ; 0x6F
            DB      020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H ; 0x7F
            DB      020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H ; 0x8F
            DB      020H,  020H,  065H,  020H,  020H,  020H,  074H,  067H,  068H,  020H,  062H,  078H,  064H,  072H,  070H,  063H ; 0x9F
            DB      071H,  061H,  07AH,  077H,  073H,  075H,  069H,  020H,  04FH,  06BH,  066H,  076H,  020H,  075H,  042H,  06AH ; 0xAF
            DB      06EH,  020H,  055H,  06DH,  020H,  020H,  020H,  06FH,  06CH,  041H,  06FH,  061H,  020H,  079H,  020H,  020H ; 0xBF
            DB      020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H ; 0xCF
            DB      020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H ; 0xDF
            DB      020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H ; 0xEF
            DB      020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H,  020H ; 0xFF

            ALIGN   0EFF8h
            ORG     0EFF8h
            DB      0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
