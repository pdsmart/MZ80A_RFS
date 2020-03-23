;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cbios_bank1.asm
;- Created:         October 2018
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM BIOS System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade for the CPM CBIOS in order to preserve RAM for actual
;-                  CPM TPA programs.
;-
;- Credits:         
;- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
;-
;- History:         January 2020 - Seperated Bank from RFS for dedicated use with CPM CBIOS.
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
            ; USER ROM CPM CBIOS BANK 1
            ;
            ;======================================
            ORG     UROMADDR

            ;-----------------------------------------------------------------------------------------
            ; Common code spanning all banks to ensure that a Monitor is selected upon power up/reset.
            ;-----------------------------------------------------------------------------------------
            NOP
            XOR     A                                                    ; We shouldnt arrive here after a reset, ensure MROM and UROM are set to bank 0
            LD      (RFSBK1),A                                           ; then a restart will take place as Bank 0 will jump to vector 00000H
            LD      (RFSBK2),A                                           
            NOP
            ; After switching in Bank 0, it will automatically continue processing in Bank 0 at the XOR A instructionof ROMFS:

            ;-------------------------------------------------------------------------------
            ; Jump table for entry into this pages functions.
            ;-------------------------------------------------------------------------------
            JP      ?REBOOT                                              ;  9  REBOOT
            JP      ?MLDY                                                ; 12  QMELDY
            JP      ?TEMP                                                ; 15  QTEMP
            JP      MLDST                                                ; 18  QMSTA
            JP      MLDSP                                                ; 21  QMSTP
            JP      ?BEL                                                 ; 24  QBEL
            JP      ?MODE                                                ; 27  QMODE
            JP      ?TIMESET                                             ; 30  QTIMESET
            JP      ?TIMEREAD                                            ; 33  QTIMEREAD
            JP      ?CHKKY                                               ; 36  QCHKKY
            JP      ?GETKY                                               ; 39  QGETKY



            ; Method to reboot the machine into startup mode, ie. Monitor at MROM Bank 0, UROM at Bank 0.
?REBOOT:    LD      A,(MEMSWR)                                           ; Switch memory to power up state, ie. Monitor ROM at 00000H
            JP      UROMADDR                                             ; Now run the code at the bank start which switches to bank 0, intitialises and then calls 00000H
            
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
?TIMESET:   DI      
            ;
            LD      (TIMESEC),HL                                         ; Load lower 16 bits.
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
           ;EI      
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
            LD      (HL),007H
            LD      (HL),005H
            LD      (HL),001H
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

?PRCKY8:
?PRCKYX:    
?PRCKYE:    
            POP     HL
            RET

            ;-------------------------------------------------------------------------------
            ; END OF KEYBOARD FUNCTIONALITY
            ;-------------------------------------------------------------------------------




            ALIGN_NOPS    UROMADDR + 0800h

            ; Bring in additional macros.
            INCLUDE "CPM_Definitions.asm"
            INCLUDE "Macros.asm"
