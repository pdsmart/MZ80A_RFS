;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cbios_bank1.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM BIOS System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade for the CPM CBIOS in order to preserve RAM for actual
;-                  CPM TPA programs.
;-
;- Credits:         
;- Copyright:       (c) 2018-23 Philip Smart <philip.smart@net2net.org>
;-
;- History:         Jan 2020 - Seperated Bank from RFS for dedicated use with CPM CBIOS.
;-                  May 2020 - Advent of the new RFS PCB v2.0, quite a few changes to accommodate the
;-                             additional and different hardware. The SPI is now onboard the PCB and
;-                             not using the printer interface card.
;-                  Mar 2021 - Updates for the RFS v2.1 board.
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

            ; Bring in definitions and macros.
            INCLUDE "cpm_buildversion.asm"
            INCLUDE "cpm_definitions.asm"
            INCLUDE "macros.asm"

            ;======================================
            ;
            ; USER ROM CPM CBIOS BANK 1
            ;
            ;======================================
            ORG     UROMADDR

            ;-----------------------------------------------------------------------------------------
            ; Common code spanning all banks to ensure that a Monitor is selected upon power up/reset.
            ;-----------------------------------------------------------------------------------------
            NOP
            LD      B,16                                                 ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
CBIOS1_0:   LD      A,(BNKCTRLRST)
            DJNZ    CBIOS1_0                                             ; Apply the default number of coded latch reads to enable the bank control registers.
CBIOS1_1:   LD      A,BNKCTRLDEF                                         ; Set coded latch, SDCS high, BBMOSI to high and BBCLK to high which enables SDCLK.
            LD      (BNKCTRL),A
            NOP
            NOP
            NOP
            XOR     A                                                    ; We shouldnt arrive here after a reset, if we do, select MROM bank 0
            LD      (BNKSELMROM),A
            NOP
            NOP
            NOP
            LD      (BNKSELUSER),A                                       ; and start up - ie. SA1510 Monitor - this occurs as User Bank 0 is enabled and the jmp to 0 is coded in it.
            ;
            ; No mans land... this should have switched to Bank 0 and at this point there is a jump to 00000H.
            JP      00000H                                               ; This is for safety!!


            ;-------------------------------------------------------------------------------
            ; Jump table for entry into this pages functions.
            ;-------------------------------------------------------------------------------
            ALIGN_NOPS UROMJMPTBL
            JP      ?REBOOT                                              ; REBOOT
            JP      ?MLDY                                                ; QMELDY
            JP      ?TEMP                                                ; QTEMP
            JP      MLDST                                                ; QMSTA
            JP      MLDSP                                                ; QMSTP
            JP      ?BEL                                                 ; QBEL
            JP      ?MODE                                                ; QMODE
            JP      ?TIMESET                                             ; QTIMESET
            JP      ?TIMEREAD                                            ; QTIMEREAD
            JP      ?CHKKY                                               ; QCHKKY
            JP      ?GETKY                                               ; QGETKY



            ; Method to reboot the machine into startup mode, ie. Monitor at MROM Bank 0, UROM at Bank 0.
?REBOOT:    LD      A,(MEMSWR)                                           ; Switch memory to power up state, ie. Monitor ROM at 00000H
            JP      CBIOS1_1                                             ; Now run the code at the bank start which switches to bank 0, intitialises and then calls 00000H
            
            ;-------------------------------------------------------------------------------
            ; START OF AUDIO CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Melody function.
?MLDY:      PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      A,002H
            LD      (OCTV),A
            LD      B,001H
MLD1:       LD      A,(DE)
            CP      00DH
            JR      Z,MLD4                 
            CP      0C8H
            JR      Z,MLD4                 
            CP      0CFH
            JR      Z,MLD2                 
            CP      02DH
            JR      Z,MLD2                 
            CP      02BH
            JR      Z,MLD3                 
            CP      0D7H
            JR      Z,MLD3                 
            CP      023H
            LD      HL,MTBL
            JR      NZ,MLD1A                
            LD      HL,M?TBL
            INC     DE
MLD1A:      CALL    ONPU
            JR      C,MLD1                 
            CALL    RYTHM
            JR      C,MLD5                 
            CALL    MLDST
            LD      B,C
            JR      MLD1                   
MLD2:       LD      A,003H
MLD2A:      LD      (OCTV),A
            INC     DE
            JR      MLD1                   
MLD3:       LD      A,001H
            JR      MLD2A                   
MLD4:       CALL    RYTHM
MLD5:       PUSH    AF
            CALL    MLDSP
            POP     AF
            POP     HL
            POP     DE
            POP     BC
            RET     

ONPU:       PUSH    BC
            LD      B,008H
            LD      A,(DE)
ONP1A:      CP      (HL)
            JR      Z,ONP2                 
            INC     HL
            INC     HL
            INC     HL
            DJNZ    ONP1A                   
            SCF     
            INC     DE
            POP     BC
            RET     

ONP2:       INC     HL
            PUSH    DE
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            EX      DE,HL
            LD      A,H
            OR      A
            JR      Z,ONP2B                 
            LD      A,(OCTV)
ONP2A:      DEC     A
            JR      Z,ONP2B                 
            ADD     HL,HL
            JR      ONP2A                   
ONP2B:      LD      (RATIO),HL
            LD      HL,OCTV
            LD      (HL),002H
            DEC     HL
            POP     DE
            INC     DE
            LD      A,(DE)
            LD      B,A
            AND     0F0H
            CP      030H
            JR      Z,ONP2C                 
            LD      A,(HL)
            JR      ONP2D                   
ONP2C:      INC     DE
            LD      A,B
            AND     00FH
            LD      (HL),A
ONP2D:      LD      HL,OPTBL
            ADD     A,L
            LD      L,A
            LD      C,(HL)
            LD      A,(TEMPW)
            LD      B,A
            XOR     A
            JP      MLDDLY

RYTHM:      LD      HL,KEYPA
            LD      (HL),0F0H
            INC     HL
            LD      A,(HL)
            AND     081H
            JR      NZ,L02D5                
            SCF     
            RET     

L02D5:      LD      A,(SUNDG)
            RRCA    
            JR      C,L02D5                 
L02DB:      LD      A,(SUNDG)
            RRCA    
            JR      NC,L02DB                
            DJNZ    L02D5                   
            XOR     A
            RET

MLDST:      LD      HL,(RATIO)
            LD      A,H
            OR      A
            JR      Z,MLDSP                 
            PUSH    DE
            EX      DE,HL
            LD      HL,CONT0
            LD      (HL),E
            LD      (HL),D
            LD      A,001H
            POP     DE
            JR      L02C4                   
MLDSP:      LD      A,034H
            LD      (CONTF),A
            XOR     A
L02C4:      LD      (SUNDG),A
            RET   

MLDDLY:     ADD     A,C
            DJNZ    MLDDLY                   
            POP     BC
            LD      C,A
            XOR     A
            RET   


?TEMP:      PUSH    AF
            PUSH    BC
            AND     00FH
            LD      B,A
            LD      A,008H
            SUB     B
            LD      (TEMPW),A
            POP     BC
            POP     AF
            RET  

            ;
            ; Method to sound the bell, basically play a constant tone.
            ; 
?BEL:       PUSH    DE
            LD      DE,00DB1H
            CALL    ?MLDY
            POP     DE
            RET

            ;
            ; Melody (note) lookup table.
            ;
MTBL:       DB      043H
            DB      077H
            DB      007H
            DB      044H
            DB      0A7H
            DB      006H
            DB      045H
            DB      0EDH
            DB      005H
            DB      046H
            DB      098H
            DB      005H
            DB      047H
            DB      0FCH
            DB      004H
            DB      041H
            DB      071H
            DB      004H
            DB      042H
            DB      0F5H
            DB      003H
            DB      052H
            DB      000H
            DB      000H
M?TBL:      DB      043H
            DB      00CH
            DB      007H
            DB      044H
            DB      047H
            DB      006H
            DB      045H
            DB      098H
            DB      005H
            DB      046H
            DB      048H
            DB      005H
            DB      047H
            DB      0B4H
            DB      004H
            DB      041H
            DB      031H
            DB      004H
            DB      042H
            DB      0BBH
            DB      003H
            DB      052H
            DB      000H
            DB      000H

OPTBL:      DB      001H
            DB      002H
            DB      003H
            DB      004H
            DB      006H
            DB      008H
            DB      00CH
            DB      010H
            DB      018H
            DB      020H
            ;-------------------------------------------------------------------------------
            ; END OF AUDIO CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------


            ;-------------------------------------------------------------------------------
            ; START OF RTC FUNCTIONALITY (INTR HANDLER IN MAIN CBIOS)
            ;-------------------------------------------------------------------------------
            ; 
            ; BC:DE:HL contains the time in milliseconds (100msec resolution) since 01/01/1980. In IX is held the interrupt service handler routine address for the RTC.
            ; HL contains lower 16 bits, DE contains middle 16 bits, BC contains upper 16bits, allows for a time from 00:00:00 to 23:59:59, for > 500000 days!
            ; NB. Caller must disable interrupts before calling this method.
?TIMESET:   LD      (TIMESEC),HL                                         ; Load lower 16 bits.
            EX      DE,HL
            LD      (TIMESEC+2),HL                                       ; Load middle 16 bits.
            PUSH    BC
            POP     HL
            LD      (TIMESEC+4),HL                                       ; Load upper 16 bits.
            ;
            LD      HL,CONTF
            LD      (HL),074H                                            ; Set Counter 1, read/load lsb first then msb, mode 2 rate generator, binary
            LD      (HL),0B0H                                            ; Set Counter 2, read/load lsb first then msb, mode 0 interrupt on terminal count, binary
            DEC     HL
            LD      DE,TMRTICKINTV                                       ; 100Hz coming into Timer 2 from Timer 1, set divisor to set interrupts per second.
            LD      (HL),E                                               ; Place current time in Counter 2
            LD      (HL),D
            DEC     HL
            LD      (HL),03BH                                            ; Place divisor in Counter 1, = 315, thus 31500/315 = 100
            LD      (HL),001H
            NOP     
            NOP     
            NOP     
            ;
            LD      A, 0C3H                                              ; Install the interrupt vector for when interrupts are enabled.
            LD      (00038H),A
            LD      (00039H),IX
            RET    

            ; Time Read;
            ; Returns BC:DE:HL where HL is lower 16bits, DE is middle 16bits and BC is upper 16bits of milliseconds since 01/01/1980.
?TIMEREAD:  LD      HL,(TIMESEC+4)
            PUSH    HL
            POP     BC
            LD      HL,(TIMESEC+2)
            EX      DE,HL
            LD      HL,(TIMESEC)
            RET
            ;-------------------------------------------------------------------------------
            ; END OF RTC FUNCTIONALITY
            ;-------------------------------------------------------------------------------


            ;-------------------------------------------------------------------------------
            ; START OF KEYBOARD FUNCTIONALITY (INTR HANDLER SEPERATE IN CBIOS)
            ;-------------------------------------------------------------------------------

?MODE:      LD      HL,KEYPF
            LD      (HL),08AH
            LD      (HL),007H                                            ; Set Motor to Off.
            LD      (HL),004H                                            ; Disable interrupts by setting INTMSK to 0.
            LD      (HL),001H                                            ; Set VGATE to 1.
            RET     

            ; Method to check if a key has been pressed and stored in buffer.. 
?CHKKY:     LD      A, (KEYCOUNT)
            OR      A
            JR      Z,CHKKY2
            LD      A,0FFH
            RET
CHKKY2:     XOR     A
            RET

?GETKY:     PUSH    HL
            LD      A,(KEYCOUNT)
            OR      A
            JR      Z,GETKY2
GETKY1:     DI                                                           ; Disable interrupts, we dont want a race state occurring.
            LD      A,(KEYCOUNT)
            DEC     A                                                    ; Take 1 off the total count as we are reading a character out of the buffer.
            LD      (KEYCOUNT),A
            LD      HL,(KEYREAD)                                         ; Get the position in the buffer where the next available character resides.
            LD      A,(HL)                                               ; Read the character and save.
            PUSH    AF
            INC     L                                                    ; Update the read pointer and save.
            LD      A,L
            AND     KEYBUFSIZE-1
            LD      L,A
            LD      (KEYREAD),HL
            POP     AF
            EI                                                           ; Interrupts back on so keys and RTC are actioned.
            JR      ?PRCKEY                                              ; Process the key, action any non ASCII keys.
            ;
GETKY2:     LD      A,(KEYCOUNT)                                         ; No key available so loop until one is.
            OR      A
            JR      Z,GETKY2                 
            JR      GETKY1
            ;
?PRCKEY:    CP      CR                                                   ; CR
            JR      NZ,?PRCKY3
            JR      ?PRCKYE
?PRCKY3:    CP      HOMEKEY                                              ; HOME
            JR      NZ,?PRCKY4
            JR      GETKY2
?PRCKY4:    CP      CLRKEY                                               ; CLR
            JR      NZ,?PRCKY5
            JR      GETKY2
?PRCKY5:    CP      INSERT                                               ; INSERT
            JR      NZ,?PRCKY6
            JR      GETKY2
?PRCKY6:    CP      DBLZERO                                              ; 00
            JR      NZ,?PRCKY7
            LD      A,'0'
            LD      (KEYBUF),A                                           ; Place a character into the keybuffer so we double up on 0
            JR      ?PRCKYX
?PRCKY7:    CP      BREAKKEY                                             ; Break key processing.
            JR      NZ,?PRCKY8
            JR      ?PRCKYE
?PRCKY8:     CP      DELETE
            JR      NZ,?PRCKYX
            LD      A,BACKS                                              ; Map DELETE to BACKSPACE, BACKSPACE is Rubout, DELETE is echo in CPM.
?PRCKYX:    
?PRCKYE:    
            POP     HL
            RET

            ;-------------------------------------------------------------------------------
            ; END OF KEYBOARD FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Align to end of bank.
            ALIGN   UROMADDR + 07F8h
            ORG     UROMADDR + 07F8h
            DB      0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
