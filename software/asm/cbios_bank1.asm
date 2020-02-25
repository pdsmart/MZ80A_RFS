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
            ORG      UROMADDR

            ;-----------------------------------------------------------------------------------------
            ; Common code spanning all banks to ensure that a Monitor is selected upon power up/reset.
            ;-----------------------------------------------------------------------------------------
            NOP
            XOR      A                                                   ; We shouldnt arrive here after a reset, if we do, select MROM bank 0
            LD       (RFSBK1),A                                          ; and start up - ie. SA1510 Monitor.
            NOP
            JP       00000h                                                   

            ; Jump table for entry into this pages public functions.
            JP      ?MLDY                                                ;  9  QMELDY
            JP      ?TEMP                                                ; 12  QTEMP
            JP      MLDST                                                ; 15  QMSTA
            JP      MLDSP                                                ; 18  QMSTP
            JP      ?BEL                                                 ; 21  QBEL
            JP      ?TMST                                                ; 24  QTIMST
            JP      ?TMRD                                                ; 27  QTIMRD



?MLDY:  PUSH    BC
        PUSH    DE
        PUSH    HL
        LD      A,002H
        LD      (OCTV),A
        LD      B,001H
MLD1:   LD      A,(DE)
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
MLD1A:  CALL    ONPU
        JR      C,MLD1                 
        CALL    RYTHM
        JR      C,MLD5                 
        CALL    MLDST
        LD      B,C
        JR      MLD1                   
MLD2:   LD      A,003H
MLD2A:  LD      (OCTV),A
        INC     DE
        JR      MLD1                   
MLD3:   LD      A,001H
        JR      MLD2A                   
MLD4:   CALL    RYTHM
MLD5:   PUSH    AF
        CALL    MLDSP
        POP     AF
        POP     HL
        POP     DE
        POP     BC
        RET     

ONPU:   PUSH    BC
        LD      B,008H
        LD      A,(DE)
ONP1A:  CP      (HL)
        JR      Z,ONP2                 
        INC     HL
        INC     HL
        INC     HL
        DJNZ    ONP1A                   
        SCF     
        INC     DE
        POP     BC
        RET     

ONP2:   INC     HL
        PUSH    DE
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        EX      DE,HL
        LD      A,H
        OR      A
        JR      Z,ONP2B                 
        LD      A,(OCTV)
ONP2A:  DEC     A
        JR      Z,ONP2B                 
        ADD     HL,HL
        JR      ONP2A                   
ONP2B:  LD      (RATIO),HL
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
ONP2C:  INC     DE
        LD      A,B
        AND     00FH
        LD      (HL),A
ONP2D:  LD      HL,OPTBL
        ADD     A,L
        LD      L,A
        LD      C,(HL)
        LD      A,(TEMPW)
        LD      B,A
        XOR     A
        JP      MLDDLY

RYTHM:  LD      HL,KEYPA
        LD      (HL),0F0H
        INC     HL
        LD      A,(HL)
        AND     081H
        JR      NZ,L02D5                
        SCF     
        RET     

L02D5:  LD      A,(SUNDG)
        RRCA    
        JR      C,L02D5                 
L02DB:  LD      A,(SUNDG)
        RRCA    
        JR      NC,L02DB                
        DJNZ    L02D5                   
        XOR     A
        RET

MLDST:  LD      HL,(RATIO)
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
MLDSP:  LD      A,034H
        LD      (CONTF),A
        XOR     A
L02C4:  LD      (SUNDG),A
        RET   

MLDDLY: ADD     A,C
        DJNZ    MLDDLY                   
        POP     BC
        LD      C,A
        XOR     A
        RET   


?TEMP:  PUSH    AF
        PUSH    BC
        AND     00FH
        LD      B,A
        LD      A,008H
        SUB     B
        LD      (TEMPW),A
        POP     BC
        POP     AF
        RET  

        
?BEL:   PUSH    DE
        LD      DE,00DB1H
        CALL    ?MLDY
        POP     DE
        RET

?TMST:  DI      
        PUSH    BC
        PUSH    DE
        PUSH    HL
        LD      (AMPM),A
        LD      A,0F0H
        LD      (TIMFG),A
        LD      HL,0A8C0H
        XOR     A
        SBC     HL,DE
        PUSH    HL
        INC     HL
        EX      DE,HL
        LD      HL,CONTF
        LD      (HL),074H
        LD      (HL),0B0H
        DEC     HL
        LD      (HL),E
        LD      (HL),D
        DEC     HL
        LD      (HL),00AH
        LD      (HL),000H
        INC     HL
        INC     HL
        LD      (HL),080H
        DEC     HL
L0323:  LD      C,(HL)
        LD      A,(HL)
        CP      D
        JR      NZ,L0323                
        LD      A,C
        CP      E
        JR      NZ,L0323                
        DEC     HL
        NOP     
        NOP     
        NOP     
        LD      (HL),00CH
        LD      (HL),07BH
        INC     HL
        POP     DE
L0336:  LD      C,(HL)
        LD      A,(HL)
        CP      D
        JR      NZ,L0336                
        LD      A,C
        CP      E
        JR      NZ,L0336                
        POP     HL
        POP     DE
        POP     BC
        EI      
        RET     

?TMRD:  PUSH    HL
        LD      HL,CONTF
        LD      (HL),080H
        DEC     HL
        DI      
        LD      E,(HL)
        LD      D,(HL)
        EI      
        LD      A,E
        OR      D
        JR      Z,?TMR1                 
        XOR     A
        LD      HL,0A8C0H
        SBC     HL,DE
        JR      C,?TMR2                 
        EX      DE,HL
        LD      A,(AMPM)
        POP     HL
        RET     

?TMR1:  LD      DE,0A8C0H
?TMR1A: LD      A,(AMPM)
        XOR     001H
        POP     HL
        RET     

?TMR2:  DI      
        LD      HL,CONT2
        LD      A,(HL)
        CPL     
        LD      E,A
        LD      A,(HL)
        CPL     
        LD      D,A
        EI      
        INC     DE
        JR      ?TMR1A                   



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

            ALIGN_NOPS    UROMADDR + 0800h

            ; Bring in additional macros.
            INCLUDE "CPM_Definitions.asm"
            INCLUDE "Macros.asm"
