;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_bank4.asm
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


            ;===========================================================
            ;
            ; USER ROM BANK 7 - Memory and timer test utilities.
            ;
            ;===========================================================
            ORG     UROMADDR

            ;--------------------------------
            ; Common code spanning all banks.
            ;--------------------------------
            NOP
            LD      B,16                                                     ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
ROMFS7_0:   LD      A,(BNKCTRLRST)
            DJNZ    ROMFS7_0                                                 ; Apply the default number of coded latch reads to enable the bank control registers.
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
BKSW7to0:   PUSH    AF
            LD      A, ROMBANK7                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK0                                              ; Required bank to call.
            JR      BKSW7_0
BKSW7to1:   PUSH    AF
            LD      A, ROMBANK7                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK1                                              ; Required bank to call.
            JR      BKSW7_0
BKSW7to2:   PUSH    AF
            LD      A, ROMBANK7                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK2                                              ; Required bank to call.
            JR      BKSW7_0
BKSW7to3:   PUSH    AF
            LD      A, ROMBANK7                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK3                                              ; Required bank to call.
            JR      BKSW7_0
BKSW7to4:   PUSH    AF
            LD      A, ROMBANK7                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK4                                              ; Required bank to call.
            JR      BKSW7_0
BKSW7to5:   PUSH    AF
            LD      A, ROMBANK7                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK5                                              ; Required bank to call.
            JR      BKSW7_0
BKSW7to6:   PUSH    AF
            LD      A, ROMBANK7                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK6                                              ; Required bank to call.
            JR      BKSW7_0
BKSW7to7:   PUSH    AF
            LD      A, ROMBANK7                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK7                                              ; Required bank to call.
            ;
BKSW7_0:    PUSH    HL                                                       ; Place function to call on stack
            LD      HL, BKSWRET7                                             ; Place bank switchers return address on stack.
            EX      (SP),HL
            LD      (TMPSTACKP),SP                                           ; Save the stack pointer as some old code corrupts it.
            LD      (BNKSELUSER), A                                          ; Repeat the bank switch B times to enable the bank control register and set its value.
            JP      (HL)                                                     ; Jump to required function.
BKSWRET7:   POP     AF                                                       ; Get bank which called us.
            LD      (BNKSELUSER), A                                          ; Return to that bank.
            POP     AF
            RET  

           ;-------------------------------------------------------------------------------
           ; START OF MEMORY TEST FUNCTIONALITY
           ;-------------------------------------------------------------------------------

MEMTEST:    LD      B,240       ; Number of loops
LOOP:       LD      HL,MEMSTART ; Start of checked memory,
            LD      D,0CFh      ; End memory check CF00
LOOP1:      LD      A,000h
            CP      L
            JR      NZ,LOOP1b
            CALL    PRTHL       ; Print HL as 4digit hex.
            LD      A,0C4h      ; Move cursor left.
            LD      E,004h      ; 4 times.
LOOP1a:     CALL    DPCT
            DEC     E
            JR      NZ,LOOP1a
LOOP1b:     INC     HL
            LD      A,H
            CP      D           ; Have we reached end of memory.
            JR      Z,LOOP3     ; Yes, exit.
            LD      A,(HL)      ; Read memory location under test, ie. 0.
            CPL                 ; Subtract, ie. FF - A, ie FF - 0 = FF.
            LD      (HL),A      ; Write it back, ie. FF.
            SUB     (HL)        ; Subtract written memory value from A, ie. should be 0.
            JR      NZ,LOOP2    ; Not zero, we have an error.
            LD      A,(HL)      ; Reread memory location, ie. FF
            CPL                 ; Subtract FF - FF
            LD      (HL),A      ; Write 0
            SUB     (HL)        ; Subtract 0
            JR      Z,LOOP1     ; Loop if the same, ie. 0
LOOP2:      LD      A,16h
            CALL    PRNT        ; Print A
            CALL    PRTHX       ; Print HL as 4 digit hex.
            CALL    PRNTS       ; Print space.
            XOR     A
            LD      (HL),A
            LD      A,(HL)      ; Get into A the failing bits.
            CALL    PRTHX       ; Print A as 2 digit hex.
            CALL    PRNTS       ; Print space.
            LD      A,0FFh      ; Repeat but first load FF into memory
            LD      (HL),A
            LD      A,(HL)
            CALL    PRTHX       ; Print A as 2 digit hex.
            NOP
            JR      LOOP4

LOOP3:      CALL    PRTHL
            LD      DE,OKCHECK
            CALL    MSG          ; Print check message in DE
            LD      A,B          ; Print loop count.
            CALL    PRTHX
            LD      DE,OKMSG
            CALL    MSG          ; Print ok message in DE
            CALL    NL
            DEC     B
            JR      NZ,LOOP
            LD      DE,DONEMSG
            CALL    MSG          ; Print check message in DE
            JP      ST1X

LOOP4:      LD      B,09h
            CALL    PRNTS        ; Print space.
            XOR     A            ; Zero A
            SCF                  ; Set Carry
LOOP5:      PUSH    AF           ; Store A and Flags
            LD      (HL),A       ; Store 0 to bad location.
            LD      A,(HL)       ; Read back
            CALL    PRTHX        ; Print A as 2 digit hex.
            CALL    PRNTS        ; Print space
            POP     AF           ; Get back A (ie. 0 + C)
            RLA                  ; Rotate left A. Bit LSB becomes Carry (ie. 1 first instance), Carry becomes MSB
            DJNZ    LOOP5        ; Loop if not zero, ie. print out all bit locations written and read to memory to locate bad bit.
            XOR     A            ; Zero A, clears flags.
            LD      A,80h
            LD      B,08h
LOOP6:      PUSH    AF           ; Repeat above but AND memory location with original A (ie. 80) 
            LD      C,A          ; Basically walk through all the bits to find which one is stuck.
            LD      (HL),A
            LD      A,(HL)
            AND     C
            NOP
            JR      Z,LOOP8      ; If zero then print out the bit number
            NOP
            NOP
            LD      A,C
            CPL
            LD      (HL),A
            LD      A,(HL)
            AND     C
            JR      NZ,LOOP8     ; As above, if the compliment doesnt yield zero, print out the bit number.
LOOP7:      POP     AF
            RRCA
            NOP
            DJNZ    LOOP6
            JP      ST1X

LOOP8:      CALL    LETNL        ; New line.
            LD      DE,BITMSG    ; BIT message
            CALL    MSG          ; Print message in DE
            LD      A,B
            DEC     A
            CALL    PRTHX        ; Print A as 2 digit hex, ie. BIT number.
            CALL    LETNL        ; New line
            LD      DE,BANKMSG   ; BANK message
            CALL    MSG          ; Print message in DE
            LD      A,H
            CP      50h          ; 'P'
            JR      NC,LOOP9     ; Work out bank number, 1, 2 or 3.
            LD      A,01h
            JR      LOOP11

LOOP9:      CP      90h
            JR      NC,LOOP10
            LD      A,02h
            JR      LOOP11

LOOP10:     LD      A,03h
LOOP11:     CALL    PRTHX        ; Print A as 2 digit hex, ie. BANK number.
            JR      LOOP7

DLY1S:      PUSH    AF
            PUSH    BC
            LD      C,10
L0324:      CALL    DLY12
            DEC     C
            JR      NZ,L0324
            POP     BC
            POP     AF
            RET
            
           ;-------------------------------------------------------------------------------
           ; END OF MEMORY TEST FUNCTIONALITY
           ;-------------------------------------------------------------------------------

           ;-------------------------------------------------------------------------------
           ; START OF TIMER TEST FUNCTIONALITY
           ;-------------------------------------------------------------------------------

            ; Test the 8253 Timer, configure it as per the monitor and display the read back values.
TIMERTST:   CALL    NL
            LD      DE,MSG_TIMERTST
            CALL    MSG
            CALL    NL
            LD      DE,MSG_TIMERVAL
            CALL    MSG
            LD      A,01h
            LD      DE,8000h
            CALL    TIMERTST1
NDE:        JP      NDE
            JP      ST1X
TIMERTST1: ;DI      
            PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      (AMPM),A
            LD      A,0F0H
            LD      (TIMFG),A
ABCD:       LD      HL,0A8C0H
            XOR     A
            SBC     HL,DE
            PUSH    HL
            INC     HL
            EX      DE,HL

            LD      HL,CONTF    ; Control Register
            LD      (HL),0B0H   ; 10110000 Control Counter 2 10, Write 2 bytes 11, 000 Interrupt on Terminal Count, 0 16 bit binary
            LD      (HL),074H   ; 01110100 Control Counter 1 01, Write 2 bytes 11, 010 Rate Generator, 0 16 bit binary
            LD      (HL),030H   ; 00110100 Control Counter 1 01, Write 2 bytes 11, 010 interrupt on Terminal Count, 0 16 bit binary

            LD      HL,CONT2    ; Counter 2
            LD      (HL),E
            LD      (HL),D

            LD      HL,CONT1    ; Counter 1
            LD      (HL),00AH
            LD      (HL),000H

            LD      HL,CONT0    ; Counter 0
            LD      (HL),00CH
            LD      (HL),0C0H

;            LD      HL,CONT2    ; Counter 2
;            LD      C,(HL)
;            LD      A,(HL)
;            CP      D
;            JP      NZ,L0323H                
;            LD      A,C
;            CP      E
;            JP      Z,CDEF                
            ;

L0323H:     PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),080H
            LD      HL,CONT2    ; Counter 2
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            CALL    PRNTS
            ;CALL    DLY1S
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),040H
            LD      HL,CONT1    ; Counter 1
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            CALL    PRNTS
            ;CALL    DLY1S
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),000H
            LD      HL,CONT0    ; Counter 0
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            ;CALL    DLY1S
            ;
            LD      A,0C4h      ; Move cursor left.
            LD      E,0Eh      ; 4 times.
L0330:      CALL    DPCT
            DEC     E
            JR      NZ,L0330
            ;
;            LD      C,20
;L0324:      CALL    DLY12
;            DEC     C
;            JR      NZ,L0324
            ;
            POP     HL
            POP     DE
            POP     BC
            POP     AF
            ;
            LD      HL,CONT2    ; Counter 2
            LD      C,(HL)
            LD      A,(HL)
            CP      D
            JP      NZ,L0323H                
            LD      A,C
            CP      E
            JP      NZ,L0323H                
            ;
            ;
            PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            CALL    NL
            CALL    NL
            CALL    NL
            LD      DE,MSG_TIMERVAL2
            CALL    MSG
            POP     HL
            POP     DE
            POP     BC
            POP     AF

            ;
CDEF:       POP     DE
            LD      HL,CONT1
            LD      (HL),00CH
            LD      (HL),07BH
            INC     HL

L0336H:     PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),080H
            LD      HL,CONT2    ; Counter 2
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            CALL    PRNTS
            CALL    DLY1S
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),040H
            LD      HL,CONT1    ; Counter 1
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            CALL    PRNTS
            CALL    DLY1S
            ;
            LD      HL,CONTF    ; Control Register
            LD      (HL),000H
            LD      HL,CONT0    ; Counter 0
            LD      C,(HL)
            LD      A,(HL)
            CALL    PRTHX
            LD      A,C
            CALL    PRTHX
            ;
            CALL    DLY1S
            ;
            LD      A,0C4h      ; Move cursor left.
            LD      E,0Eh      ; 4 times.
L0340:      CALL    DPCT
            DEC     E
            JR      NZ,L0340
            ;
            POP     HL
            POP     DE
            POP     BC
            POP     AF

            LD      HL,CONT2    ; Counter 2
            LD      C,(HL)
            LD      A,(HL)
            CP      D
            JR      NZ,L0336H                
            LD      A,C
            CP      E
            JR      NZ,L0336H                
            CALL    NL
            LD      DE,MSG_TIMERVAL3
            CALL    MSG
            POP     HL
            POP     DE
            POP     BC
           ;EI      
            RET   
            ;-------------------------------------------------------------------------------
            ; END OF TIMER TEST FUNCTIONALITY
            ;-------------------------------------------------------------------------------
  
            ;--------------------------------------
            ;
            ; Message table
            ;
            ;--------------------------------------             
OKCHECK:    DB      ", CHECK: ", 0Dh
OKMSG:      DB      " OK.", 0Dh
DONEMSG:    DB      11h
            DB      "RAM TEST COMPLETE.", 0Dh
           
BITMSG:     DB      " BIT:  ", 0Dh
BANKMSG:    DB      " BANK: ", 0Dh
MSG_TIMERTST:
            DB      "8253 TIMER TEST", 0Dh, 00h
MSG_TIMERVAL:
            DB      "READ VALUE 1: ", 0Dh, 00h
MSG_TIMERVAL2:
            DB      "READ VALUE 2: ", 0Dh, 00h
MSG_TIMERVAL3:
            DB      "READ DONE.", 0Dh, 00h

            ALIGN   0EFF8h
            ORG     0EFF8h
            DB      0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh            
