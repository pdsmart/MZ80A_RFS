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

ROW        EQU      25
COLW       EQU      40
SCRNSZ     EQU      COLW * ROW
MODE80C    EQU      0

           ;======================================
           ;
           ; USER ROM BANK 3
           ;
           ;======================================
           ORG      0E800h

           ;--------------------------------
           ; Common code spanning all banks.
           ;--------------------------------
ROMFS3:    NOP
           LD       A, (ROMBK1)                                              ; Ensure all banks are at default on
           CP       4                                                        ; If the ROMBK1 value is 255, an illegal value, then the machine has just started so skip.
           JR       C, ROMFS3_2
           XOR      A                                                        ; Clear the lower stack space as we use it for variables.
           LD       B, 7*8
           LD       HL, 01000H
ROMFS3_1:  LD       (HL),A
           INC      HL
           DJNZ     ROMFS3_1              
ROMFS3_2:  LD       (RFSBK1),A                                               ; start up.
           LD       A, (ROMBK2)
           LD       (RFSBK2),A
           JP       MONITOR

           ;
           ; Bank switching code, allows a call to code in another bank.
           ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
           ;
BKSW3to0:  PUSH     AF
           LD       A, ROMBANK3                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK0                                              ; Required bank to call.
           JR       BKSW3_0
BKSW3to1:  PUSH     AF
           LD       A, ROMBANK3                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK1                                              ; Required bank to call.
           JR       BKSW3_0
BKSW3to2:  PUSH     AF
           LD       A, ROMBANK3                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK2                                              ; Required bank to call.
           JR       BKSW3_0
BKSW3to3:  PUSH     AF
           LD       A, ROMBANK3                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK3                                              ; Required bank to call.
           JR       BKSW3_0
BKSW3to4:  PUSH     AF
           LD       A, ROMBANK3                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK4                                              ; Required bank to call.
           JR       BKSW3_0
BKSW3to5:  PUSH     AF
           LD       A, ROMBANK3                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK5                                              ; Required bank to call.
           JR       BKSW3_0
BKSW3to6:  PUSH     AF
           LD       A, ROMBANK3                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK6                                              ; Required bank to call.
           JR       BKSW3_0
BKSW3to7:  PUSH     AF
           LD       A, ROMBANK3                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK7                                              ; Required bank to call.
           ;
BKSW3_0:   PUSH     BC                                                       ; Save BC for caller.
           LD       BC, BKSWRET3                                             ; Place bank switchers return address on stack.
           PUSH     BC
           LD       (RFSBK2), A                                              ; Bank switch in user rom space, A=bank.
           JP       (HL)                                                     ; Jump to required function.
BKSWRET3:  POP      BC
           POP      AF                                                       ; Get bank which called us.
           LD       (RFSBK2), A                                              ; Return to that bank.
           POP      AF
           RET                                                               ; Return to caller.



MEMTEST:   LD       B,240       ; Number of loops
LOOP:      LD       HL,MEMSTART ; Start of checked memory,
           LD       D,0CFh      ; End memory check CF00
LOOP1:     LD       A,000h
           CP       L
           JR       NZ,LOOP1b
           CALL     PRTHL       ; Print HL as 4digit hex.
           LD       A,0C4h      ; Move cursor left.
           LD       E,004h      ; 4 times.
LOOP1a:    CALL     DPCT
           DEC      E
           JR       NZ,LOOP1a
LOOP1b:    INC      HL
           LD       A,H
           CP       D           ; Have we reached end of memory.
           JR       Z,LOOP3     ; Yes, exit.
           LD       A,(HL)      ; Read memory location under test, ie. 0.
           CPL                  ; Subtract, ie. FF - A, ie FF - 0 = FF.
           LD       (HL),A      ; Write it back, ie. FF.
           SUB      (HL)        ; Subtract written memory value from A, ie. should be 0.
           JR       NZ,LOOP2    ; Not zero, we have an error.
           LD       A,(HL)      ; Reread memory location, ie. FF
           CPL                  ; Subtract FF - FF
           LD       (HL),A      ; Write 0
           SUB      (HL)        ; Subtract 0
           JR       Z,LOOP1     ; Loop if the same, ie. 0
LOOP2:     LD       A,16h
           CALL     PRNT        ; Print A
           CALL     PRTHX       ; Print HL as 4 digit hex.
           CALL     PRNTS       ; Print space.
           XOR      A
           LD       (HL),A
           LD       A,(HL)      ; Get into A the failing bits.
           CALL     PRTHX       ; Print A as 2 digit hex.
           CALL     PRNTS       ; Print space.
           LD       A,0FFh      ; Repeat but first load FF into memory
           LD       (HL),A
           LD       A,(HL)
           CALL     PRTHX       ; Print A as 2 digit hex.
           NOP
           JR       LOOP4

LOOP3:     CALL     PRTHL
           LD       DE,OKCHECK
           CALL     MSG          ; Print check message in DE
           LD       A,B          ; Print loop count.
           CALL     PRTHX
           LD       DE,OKMSG
           CALL     MSG          ; Print ok message in DE
           CALL     NL
           DEC      B
           JR       NZ,LOOP
           LD       DE,DONEMSG
           CALL     MSG          ; Print check message in DE
           JP       ST1X

LOOP4:     LD       B,09h
           CALL     PRNTS        ; Print space.
           XOR      A            ; Zero A
           SCF                   ; Set Carry
LOOP5:     PUSH     AF           ; Store A and Flags
           LD       (HL),A       ; Store 0 to bad location.
           LD       A,(HL)       ; Read back
           CALL     PRTHX        ; Print A as 2 digit hex.
           CALL     PRNTS        ; Print space
           POP      AF           ; Get back A (ie. 0 + C)
           RLA                   ; Rotate left A. Bit LSB becomes Carry (ie. 1 first instance), Carry becomes MSB
           DJNZ     LOOP5        ; Loop if not zero, ie. print out all bit locations written and read to memory to locate bad bit.
           XOR      A            ; Zero A, clears flags.
           LD       A,80h
           LD       B,08h
LOOP6:     PUSH     AF           ; Repeat above but AND memory location with original A (ie. 80) 
           LD       C,A          ; Basically walk through all the bits to find which one is stuck.
           LD       (HL),A
           LD       A,(HL)
           AND      C
           NOP
           JR       Z,LOOP8      ; If zero then print out the bit number
           NOP
           NOP
           LD       A,C
           CPL
           LD       (HL),A
           LD       A,(HL)
           AND      C
           JR       NZ,LOOP8     ; As above, if the compliment doesnt yield zero, print out the bit number.
LOOP7:     POP      AF
           RRCA
           NOP
           DJNZ     LOOP6
           JP       ST1X

LOOP8:     CALL     LETNL        ; New line.
           LD       DE,BITMSG    ; BIT message
           CALL     MSG          ; Print message in DE
           LD       A,B
           DEC      A
           CALL     PRTHX        ; Print A as 2 digit hex, ie. BIT number.
           CALL     LETNL        ; New line
           LD       DE,BANKMSG   ; BANK message
           CALL     MSG          ; Print message in DE
           LD       A,H
           CP       50h          ; 'P'
           JR       NC,LOOP9     ; Work out bank number, 1, 2 or 3.
           LD       A,01h
           JR       LOOP11

LOOP9:     CP       90h
           JR       NC,LOOP10
           LD       A,02h
           JR       LOOP11

LOOP10:    LD       A,03h
LOOP11:    CALL     PRTHX        ; Print A as 2 digit hex, ie. BANK number.
           JR       LOOP7

DLY1S:     PUSH     AF
           PUSH     BC
           LD       C,10
L0324:     CALL     DLY12
           DEC      C
           JR       NZ,L0324
           POP      BC
           POP      AF
           RET

           ; Test the 8253 Timer, configure it as per the monitor and display the read back values.
TIMERTST:  CALL     NL
           LD       DE,MSG_TIMERTST
           CALL     MSG
           CALL     NL
           LD       DE,MSG_TIMERVAL
           CALL     MSG
           LD       A,01h
           LD       DE,8000h
           CALL     TIMERTST1
NDE:       JP       NDE
           JP       ST1X
TIMERTST1: DI      
           PUSH     BC
           PUSH     DE
           PUSH     HL
           LD       (AMPM),A
           LD       A,0F0H
           LD       (TIMFG),A
ABCD:      LD       HL,0A8C0H
           XOR      A
           SBC      HL,DE
           PUSH     HL
           INC      HL
           EX       DE,HL

           LD       HL,CONTF    ; Control Register
           LD       (HL),0B0H   ; 10110000 Control Counter 2 10, Write 2 bytes 11, 000 Interrupt on Terminal Count, 0 16 bit binary
           LD       (HL),074H   ; 01110100 Control Counter 1 01, Write 2 bytes 11, 010 Rate Generator, 0 16 bit binary
           LD       (HL),030H   ; 00110100 Control Counter 1 01, Write 2 bytes 11, 010 interrupt on Terminal Count, 0 16 bit binary

           LD       HL,CONT2    ; Counter 2
           LD       (HL),E
           LD       (HL),D

           LD       HL,CONT1    ; Counter 1
           LD       (HL),00AH
           LD       (HL),000H

           LD       HL,CONT0    ; Counter 0
           LD       (HL),00CH
           LD       (HL),0C0H

;           LD       HL,CONT2    ; Counter 2
;           LD       C,(HL)
;           LD       A,(HL)
;           CP       D
;           JP       NZ,L0323H                
;           LD       A,C
;           CP       E
;           JP       Z,CDEF                
           ;

L0323H:    PUSH     AF
           PUSH     BC
           PUSH     DE
           PUSH     HL
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),080H
           LD       HL,CONT2    ; Counter 2
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           CALL     PRNTS
           ;CALL     DLY1S
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),040H
           LD       HL,CONT1    ; Counter 1
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           CALL     PRNTS
           ;CALL     DLY1S
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),000H
           LD       HL,CONT0    ; Counter 0
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           ;CALL     DLY1S
           ;
           LD       A,0C4h      ; Move cursor left.
           LD       E,0Eh      ; 4 times.
L0330:     CALL     DPCT
           DEC      E
           JR       NZ,L0330
           ;
;           LD       C,20
;L0324:     CALL     DLY12
;           DEC      C
;           JR       NZ,L0324
           ;
           POP      HL
           POP      DE
           POP      BC
           POP      AF
           ;
           LD       HL,CONT2    ; Counter 2
           LD       C,(HL)
           LD       A,(HL)
           CP       D
           JP       NZ,L0323H                
           LD       A,C
           CP       E
           JP       NZ,L0323H                
           ;
           ;
           PUSH     AF
           PUSH     BC
           PUSH     DE
           PUSH     HL
           CALL     NL
           CALL     NL
           CALL     NL
           LD       DE,MSG_TIMERVAL2
           CALL     MSG
           POP      HL
           POP      DE
           POP      BC
           POP      AF

           ;
CDEF:      POP      DE
           LD       HL,CONT1
           LD       (HL),00CH
           LD       (HL),07BH
           INC      HL

L0336H:     PUSH     AF
           PUSH     BC
           PUSH     DE
           PUSH     HL
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),080H
           LD       HL,CONT2    ; Counter 2
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           CALL     PRNTS
           CALL     DLY1S
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),040H
           LD       HL,CONT1    ; Counter 1
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           CALL     PRNTS
           CALL     DLY1S
           ;
           LD       HL,CONTF    ; Control Register
           LD       (HL),000H
           LD       HL,CONT0    ; Counter 0
           LD       C,(HL)
           LD       A,(HL)
           CALL     PRTHX
           LD       A,C
           CALL     PRTHX
           ;
           CALL     DLY1S
           ;
           LD       A,0C4h      ; Move cursor left.
           LD       E,0Eh      ; 4 times.
L0340:     CALL     DPCT
           DEC      E
           JR       NZ,L0340
           ;
           POP      HL
           POP      DE
           POP      BC
           POP      AF

           LD       HL,CONT2    ; Counter 2
           LD       C,(HL)
           LD       A,(HL)
           CP       D
           JR       NZ,L0336H                
           LD       A,C
           CP       E
           JR       NZ,L0336H                
           CALL     NL
           LD       DE,MSG_TIMERVAL3
           CALL     MSG
           POP      HL
           POP      DE
           POP      BC
           EI      
           RET   

OKCHECK:   DB       ", CHECK: ", 0Dh
OKMSG:     DB       " OK.", 0Dh
DONEMSG:   DB       11h
           DB       "RAM TEST COMPLETE.", 0Dh
           
BITMSG:    DB       " BIT:  ", 0Dh
BANKMSG:   DB       " BANK: ", 0Dh
MSG_TIMERTST:
           DB       "8253 TIMER TEST", 0Dh, 00h
MSG_TIMERVAL:
           DB       "READ VALUE 1: ", 0Dh, 00h
MSG_TIMERVAL2:
           DB       "READ VALUE 2: ", 0Dh, 00h
MSG_TIMERVAL3:
           DB       "READ DONE.", 0Dh, 00h

           ALIGN    0EFFFh
           DB       0FFh
