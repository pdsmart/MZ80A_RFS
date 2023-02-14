;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cbios_bank2.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM BIOS System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade for the CPM CBIOS in order to preserve RAM for actual
;-                  CPM TPA programs.
;-
;- Credits:         ANSITERM utilises a heavily customised version of Ewen McNeill's Amstrad CPC EwenTerm
;                   Ansi Parser.
;
;                   (C) Oct 2000 - only the ansiterm.22b module was used with a lot stripped out.
;- Copyright:       (c) 2018-23 Philip Smart <philip.smart@net2net.org>
;-
;- History:         Jan 2020 - Seperated Bank from RFS for dedicated use with CPM CBIOS.
;-                  May 2020 - Advent of the new RFS PCB v2.0, quite a few changes to accommodate the
;-                             additional and different hardware. The SPI is now onboard the PCB and
;-                             not using the printer interface card.
;-                  Mar 2021 - Updates for the RFS v2.1 board.
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
            ; USER ROM CPM CBIOS BANK 2
            ;
            ;======================================
            ORG      UROMADDR

            ;-----------------------------------------------------------------------------------------
            ; Common code spanning all banks to ensure that a Monitor is selected upon power up/reset.
            ;-----------------------------------------------------------------------------------------
            NOP
            LD      B,16                                                 ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
CBIOS2_0:   LD      A,(BNKCTRLRST)
            DJNZ    CBIOS2_0                                             ; Apply the default number of coded latch reads to enable the bank control registers.
            LD      A,BNKCTRLDEF                                         ; Set coded latch, SDCS high, BBMOSI to high and BBCLK to high which enables SDCLK.
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
            JP      ?PRNT                                                ; QPRNT
            JP      ?PRTHX                                               ; QPRTHX
            JP      ?PRTHL                                               ; QPRTHL
            JP      ?ANSITERM                                            ; QANSITERM

            ;-------------------------------------------------------------------------------
            ; START OF SCREEN FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; CR PAGE MODE1
.CR:        CALL    .MANG
            RRCA    
            JP      NC,CURS2
            LD      L,000H
            INC     H
            CP      ROW - 1                 ; End of line?
            JR      Z,.CP1                 
            INC     H
            JP      CURS1

.CP1:       LD      (DSPXY),HL

            ; SCROLLER
.SCROL:     LD      BC,SCRNSZ - COLW        ; Scroll COLW -1 lines
            LD      DE,SCRN                 ; Start of the screen.
            LD      HL,SCRN + COLW          ; Start of screen + 1 line.
            LDIR    
            EX      DE,HL
            LD      B,COLW                  ; Clear last line at bottom of screen.
            CALL    ?CLER
            LD      BC,0001AH
            LD      DE,MANG
            LD      HL,MANG + 1
            LDIR    
            LD      (HL),000H
            LD      A,(MANG)
            OR      A
            JP      Z,?RSTR
            LD      HL,DSPXY + 1
            DEC     (HL)
            JR      .SCROL                   

?DPCT:      PUSH    AF                      ; Display control, character is mapped to a function call.
            PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      B,A
            AND     0F0H
            CP      0C0H
            JP      NZ,?RSTR
            XOR     B
            RLCA    
            LD      C,A
            LD      B,000H
            LD      HL,.CTBL
DPCT1:      ADD     HL,BC
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            EX      DE,HL
            JP      (HL)


?PRT:       LD      A,C
            CALL    ?ADCN
            LD      C,A
            AND     0F0H
            CP      0F0H
            RET     Z

            CP      0C0H
            LD      A,C
            JR      NZ,PRNT3                
PRNT5:      CALL    ?DPCT
            CP      0C3H
            JR      Z,PRNT4                 
            CP      0C5H
            JR      Z,PRNT2                 
            CP      0CDH                   ; CR
            JR      Z,PRNT2                 
            CP      0C6H
            RET     NZ

PRNT2:      XOR     A
PRNT2A:     LD      (DPRNT),A
            RET     

PRNT3:      CALL    ?DSP
PRNT4:      LD      A,(DPRNT)
            INC     A
            CP      COLW*2                 ; 050H
            JR      C,PRNT4A                 
            SUB     COLW*2                 ; 050H
PRNT4A:     JR      PRNT2A                   

?NL:        LD      A,(DPRNT)
            OR      A
            RET     Z

?LTNL:      LD      A,0CDH
            JR      PRNT5                   
?PRTT:      CALL    ?PRTS
            LD      A,(DPRNT)
            OR      A
            RET     Z

L098C:      SUB     00AH
            JR      C,?PRTT                 
            JR      NZ,L098C                
            RET     

            ; Delete a character on screen.
?DELCHR:    LD      A,0C7H
            CALL    ?DPCT
            JR      ?PRNT1

?NEWLINE:   CALL    ?NL
            JR      ?PRNT1

            ;
            ; Function to disable the cursor display.
            ;
CURSOROFF:  DI
            CALL    CURSRSTR                                             ; Restore character under the cursor.
            LD      HL,FLASHCTL                                          ; Indicate cursor is now off.
            RES     7,(HL)
            EI
            RET

            ;
            ; Function to enable the cursor display.
            ;
CURSORON:   DI
            CALL    DSPXYTOADDR                                          ; Update the screen address for where the cursor should appear.
            LD      HL,FLASHCTL                                          ; Indicate cursor is now on.
            SET     7,(HL)
            EI
            RET

            ;
            ; Function to restore the character beneath the cursor iff the cursor is being dislayed.
            ;
CURSRSTR:   PUSH    HL
            PUSH    AF
            LD      HL,FLASHCTL                                          ; Check to see if there is a cursor at the current screen location.
            BIT     6,(HL)
            JR      Z,CURSRSTR1
            RES     6,(HL)
            LD      HL,(DSPXYADDR)                                       ; There is so we must restore the original character before further processing.
            LD      A,(FLASH)
            LD      (HL),A
CURSRSTR1:  POP     AF
            POP     HL
            RET

            ;
            ; Function to convert XY co-ordinates to a physical screen location and save.
            ;
DSPXYTOADDR:PUSH    HL
            PUSH    DE
            PUSH    BC
            LD      BC,(DSPXY)                                           ; Calculate the new cursor position based on the XY coordinates.
            LD      DE,COLW
            LD      HL,SCRN - COLW
DSPXYTOA1:  ADD     HL,DE
            DEC     B
            JP      P,DSPXYTOA1
            LD      B,000H
            ADD     HL,BC
            RES     3,H
            LD      (DSPXYADDR),HL                                       ; Store the new address.
            LD      A,(HL)                                               ; Store the new character.
            LD      (FLASH),A
DSPXYTOA2:  POP     BC
            POP     DE
            POP     HL
            RET

            ;
            ; Function to print a space.
            ;
?PRTS:      LD      A,020H

            ; Function to print a character to the screen. If the character is a control code it is processed as necessary
            ; otherwise the character is converted from ASCII display and displayed.
            ;
?PRNT:      DI
            CALL    CURSRSTR                                             ; Restore char under cursor.
            CP      00DH
            JR      Z,?NEWLINE                 
            CP      00AH
            JR      Z,?NEWLINE                 
            CP      07FH
            JR      Z,?DELCHR
            CP      BACKS
            JR      Z,?DELCHR
            PUSH    BC
            LD      C,A
            LD      B,A
            CALL    ?PRT
            LD      A,B
            POP     BC
?PRNT1:     CALL    DSPXYTOADDR
            EI
            RET     

            ;
            ; Function to print out the contents of HL as 4 digit Hexadecimal.
            ;
?PRTHL:     LD      A,H
            CALL    ?PRTHX
            LD      A,L
            JR      ?PRTHX                   
            RET

            ;
            ; Function to print out the contents of A as 2 digit Hexadecimal
            ;
?PRTHX:     PUSH    AF
            RRCA    
            RRCA    
            RRCA    
            RRCA    
            CALL    ASC
            CALL    ?PRNT
            POP     AF
            CALL    ASC
            JP      ?PRNT

ASC:        AND     00FH
            CP      00AH
            JR      C,NOADD                 
            ADD     A,007H
NOADD:      ADD     A,030H
            RET     

CLR8Z:      XOR     A
            LD      BC,00800H
            PUSH    DE
            LD      D,A
L09E8:      LD      (HL),D
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,L09E8                
            POP     DE
            RET   

REV:        LD      HL,REVFLG
            LD      A,(HL)
            OR      A
            CPL     
            LD      (HL),A
            JR      Z,REV1                 
            LD      A,(INVDSP)
            JR      REV2                   
REV1:       LD      A,(NRMDSP)
REV2:       JP      ?RSTR

.MANG:      LD      HL,MANG
.MANG2:     LD      A,(DSPXY + 1)
            ADD     A,L
            LD      L,A
            LD      A,(HL)
            INC     HL
            RL      (HL)
            OR      (HL)
            RR      (HL)
            RRCA    
            EX      DE,HL
            LD      HL,(DSPXY)
            RET     

L09C7:      PUSH    DE
            PUSH    HL
            LD      HL,PBIAS
            XOR     A
            RLD     
            LD      D,A
            LD      E,(HL)
            RRD     
            XOR     A
            RR      D
            RR      E
            LD      HL,SCRN
            ADD     HL,DE
            LD      (PAGETP),HL
            POP     HL
            POP     DE
            RET

?DSP:       PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      B,A
            CALL    ?PONT
            LD      (HL),B
            LD      HL,(DSPXY)
            LD      A,L
DSP01:      CP      COLW - 1                ; End of line.
            JP      NZ,CURSR                
            CALL    .MANG
            JR      C,CURSR                 
.DSP03:     EX      DE,HL
            LD      (HL),001H
            INC     HL
            LD      (HL),000H
            JP      CURSR

CURSD:      LD      HL,(DSPXY)
            LD      A,H
            CP      ROW - 1
            JR      Z,CURS4                 
            INC     H
CURS1:                                ;CALL    MGP.I
CURS3:      LD      (DSPXY),HL
            JR      ?RSTR                   

CURSU:      LD      HL,(DSPXY)
            LD      A,H
            OR      A
            JR      Z,CURS5                 
            DEC     H
CURSU1:     JR      CURS3                   

CURSR:      LD      HL,(DSPXY)
            LD      A,L
            CP      COLW - 1                ; End of line
            JR      NC,CURS2                
            INC     L
            JR      CURS3                   
CURS2:      LD      L,000H
            INC     H
            LD      A,H
            CP      ROW 
            JR      C,CURS1                 
            LD      H,ROW - 1
            LD      (DSPXY),HL
CURS4:      JP      .SCROL

CURSL:      LD      HL,(DSPXY)
            LD      A,L
            OR      A
            JR      Z,CURS5A                 
            DEC     L
            JR      CURS3                   
CURS5A:     LD      L,COLW - 1              ; End of line
            DEC     H
            JP      P,CURSU1
            LD      H,000H
            LD      (DSPXY),HL
CURS5:      JR      ?RSTR

CLRS:       LD      HL,MANG
            LD      B,01BH
            CALL    ?CLER
            LD      HL,SCRN
            PUSH    HL
            CALL    CLR8Z
            POP     HL
CLRS1:      LD      A,(SCLDSP)
HOM0:       LD      HL,00000H
            JP      CURS3

?RSTR:      POP     HL
?RSTR1:     POP     DE
            POP     BC
            POP     AF
            RET     

DEL:        LD      HL,(DSPXY)
            LD      A,H
            OR      L
            JR      Z,?RSTR                 
            LD      A,L
            OR      A
            JR      NZ,DEL1                
            CALL    .MANG
            JR      C,DEL1                 
            CALL    ?PONT
            DEC     HL
            LD      (HL),000H
            JR      CURSL                   
DEL1:       CALL    .MANG
            RRCA    
            LD      A,COLW
            JR      NC,L0F13                
            RLCA    
L0F13:      SUB     L
            LD      B,A
            CALL    ?PONT
            PUSH    HL
            POP     DE
            DEC     DE
            SET     4,D
DEL2:       RES     3,H
            RES     3,D
            LD      A,(HL)
            LD      (DE),A
            INC     HL
            INC     DE
            DJNZ    DEL2                   
            DEC     HL
            LD      (HL),000H
            JP      CURSL

INST:       CALL    .MANG
            RRCA    
            LD      L,COLW - 1              ; End of line
            LD      A,L
            JR      NC,INST1A                
            INC     H
INST1A:     CALL    ?PNT1
            PUSH    HL
            LD      HL,(DSPXY)
            JR      NC,INST2                
            LD      A,(COLW*2)-1            ; 04FH
INST2:      SUB     L
            LD      B,A
            POP     DE
            LD      A,(DE)
            OR      A
            JR      NZ,?RSTR                
            CALL    ?PONT
            LD      A,(HL)
            LD      (HL),000H
INST1:      INC     HL
            RES     3,H
            LD      E,(HL)
            LD      (HL),A
            LD      A,E
            DJNZ    INST1                   
            JR      ?RSTR                   

?PONT:      LD      HL,(DSPXY)
?PNT1:      PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            POP     BC
            LD      DE,COLW
            LD      HL,SCRN - COLW
?PNT2:      ADD     HL,DE
            DEC     B
            JP      P,?PNT2
            LD      B,000H
            ADD     HL,BC
            RES     3,H
            POP     DE
            POP     BC
            POP     AF
            RET     

?CLER:      XOR     A
            JR      ?DINT                   
?CLRFF:     LD      A,0FFH
?DINT:      LD      (HL),A
            INC     HL
            DJNZ    ?DINT                   
            RET     

?ADCN:      PUSH    BC
            PUSH    HL
            LD      HL,ATBL      ;00AB5H
            LD      C,A
            LD      B,000H
            ADD     HL,BC
            LD      A,(HL)
            JR      DACN3                   

?DACN:      PUSH    BC
            PUSH    HL
            PUSH    DE
            LD      HL,ATBL
            LD      D,H
            LD      E,L
            LD      BC,00100H
            CPIR    
            JR      Z,DACN1                 
            LD      A,0F0H
DACN2:      POP     DE
DACN3:      POP     HL
            POP     BC
            RET     

DACN1:      OR      A
            DEC     HL
            SBC     HL,DE
            LD      A,L
            JR      DACN2     

            ; CTBL PAGE MODE1
.CTBL:      DW      .SCROL
            DW      CURSD
            DW      CURSU
            DW      CURSR
            DW      CURSL
            DW      HOM0
            DW      CLRS
            DW      DEL
            DW      INST
            DW      ?RSTR
            DW      ?RSTR
            DW      ?RSTR
            DW      REV
            DW      .CR
            DW      ?RSTR
            DW      ?RSTR

; ASCII TO DISPLAY CODE TABLE
ATBL:       DB      0CCH   ; NUL '\0' (null character)     
            DB      0E0H   ; SOH (start of heading)     
            DB      0F2H   ; STX (start of text)        
            DB      0F3H   ; ETX (end of text)          
            DB      0CEH   ; EOT (end of transmission)  
            DB      0CFH   ; ENQ (enquiry)              
            DB      0F6H   ; ACK (acknowledge)          
            DB      0F7H   ; BEL '\a' (bell)            
            DB      0F8H   ; BS  '\b' (backspace)       
            DB      0F9H   ; HT  '\t' (horizontal tab)  
            DB      0FAH   ; LF  '\n' (new line)        
            DB      0FBH   ; VT  '\v' (vertical tab)    
            DB      0FCH   ; FF  '\f' (form feed)       
            DB      0FDH   ; CR  '\r' (carriage ret)    
            DB      0FEH   ; SO  (shift out)            
            DB      0FFH   ; SI  (shift in)                
            DB      0E1H   ; DLE (data link escape)        
            DB      0C1H   ; DC1 (device control 1)     
            DB      0C2H   ; DC2 (device control 2)     
            DB      0C3H   ; DC3 (device control 3)     
            DB      0C4H   ; DC4 (device control 4)     
            DB      0C5H   ; NAK (negative ack.)        
            DB      0C6H   ; SYN (synchronous idle)     
            DB      0E2H   ; ETB (end of trans. blk)    
            DB      0E3H   ; CAN (cancel)               
            DB      0E4H   ; EM  (end of medium)        
            DB      0E5H   ; SUB (substitute)           
            DB      0E6H   ; ESC (escape)               
            DB      0EBH   ; FS  (file separator)       
            DB      0EEH   ; GS  (group separator)      
            DB      0EFH   ; RS  (record separator)     
            DB      0F4H   ; US  (unit separator)       
            DB      000H   ; SPACE                         
            DB      061H   ; !                             
            DB      062H   ; "                          
            DB      063H   ; #                          
            DB      064H   ; $                          
            DB      065H   ; %                          
            DB      066H   ; &                          
            DB      067H   ; '                          
            DB      068H   ; (                          
            DB      069H   ; )                          
            DB      06BH   ; *                          
            DB      06AH   ; +                          
            DB      02FH   ; ,                          
            DB      02AH   ; -                          
            DB      02EH   ; .                          
            DB      02DH   ; /                          
            DB      020H   ; 0                          
            DB      021H   ; 1                          
            DB      022H   ; 2                          
            DB      023H   ; 3                          
            DB      024H   ; 4                          
            DB      025H   ; 5                          
            DB      026H   ; 6                          
            DB      027H   ; 7                          
            DB      028H   ; 8                          
            DB      029H   ; 9                          
            DB      04FH   ; :                          
            DB      02CH   ; ;                          
            DB      051H   ; <                          
            DB      02BH   ; =                          
            DB      057H   ; >                          
            DB      049H   ; ?                          
            DB      055H   ; @
            DB      001H   ; A
            DB      002H   ; B
            DB      003H   ; C
            DB      004H   ; D
            DB      005H   ; E
            DB      006H   ; F
            DB      007H   ; G
            DB      008H   ; H
            DB      009H   ; I
            DB      00AH   ; J
            DB      00BH   ; K
            DB      00CH   ; L
            DB      00DH   ; M
            DB      00EH   ; N
            DB      00FH   ; O
            DB      010H   ; P
            DB      011H   ; Q
            DB      012H   ; R
            DB      013H   ; S
            DB      014H   ; T
            DB      015H   ; U
            DB      016H   ; V
            DB      017H   ; W
            DB      018H   ; X
            DB      019H   ; Y
            DB      01AH   ; Z
            DB      052H   ; [
            DB      059H   ; \  '\\'
            DB      054H   ; ]
            DB      0BEH   ; ^
            DB      03CH   ; _
            DB      0C7H   ; `
            DB      081H   ; a
            DB      082H   ; b
            DB      083H   ; c
            DB      084H   ; d
            DB      085H   ; e
            DB      086H   ; f
            DB      087H   ; g
            DB      088H   ; h
            DB      089H   ; i
            DB      08AH   ; j
            DB      08BH   ; k
            DB      08CH   ; l
            DB      08DH   ; m
            DB      08EH   ; n
            DB      08FH   ; o
            DB      090H   ; p
            DB      091H   ; q
            DB      092H   ; r
            DB      093H   ; s
            DB      094H   ; t
            DB      095H   ; u
            DB      096H   ; v
            DB      097H   ; w
            DB      098H   ; x
            DB      099H   ; y
            DB      09AH   ; z
            DB      0BCH   ; {
            DB      080H   ; |
            DB      040H   ; }
            DB      0A5H   ; ~
            DB      0C0H   ; DEL
            DB      040H  
            DB      0BDH
            DB      09DH
            DB      0B1H
            DB      0B5H
            DB      0B9H
            DB      0B4H
            DB      09EH
            DB      0B2H
            DB      0B6H
            DB      0BAH
            DB      0BEH
            DB      09FH
            DB      0B3H
            DB      0B7H
            DB      0BBH
            DB      0BFH
            DB      0A3H
            DB      085H
            DB      0A4H
            DB      0A5H
            DB      0A6H
            DB      094H
            DB      087H
            DB      088H
            DB      09CH
            DB      082H
            DB      098H
            DB      084H
            DB      092H
            DB      090H
            DB      083H
            DB      091H
            DB      081H
            DB      09AH
            DB      097H
            DB      093H
            DB      095H
            DB      089H
            DB      0A1H
            DB      0AFH
            DB      08BH
            DB      086H
            DB      096H
            DB      0A2H
            DB      0ABH
            DB      0AAH
            DB      08AH
            DB      08EH
            DB      0B0H
            DB      0ADH
            DB      08DH
            DB      0A7H
            DB      0A8H
            DB      0A9H
            DB      08FH
            DB      08CH
            DB      0AEH
            DB      0ACH
            DB      09BH
            DB      0A0H
            DB      099H
            DB      0BCH
            DB      0B8H
            DB      080H
            DB      03BH
            DB      03AH
            DB      070H
            DB      03CH
            DB      071H
            DB      05AH
            DB      03DH
            DB      043H
            DB      056H
            DB      03FH
            DB      01EH
            DB      04AH
            DB      01CH
            DB      05DH
            DB      03EH
            DB      05CH
            DB      01FH
            DB      05FH
            DB      05EH
            DB      037H
            DB      07BH
            DB      07FH
            DB      036H
            DB      07AH
            DB      07EH
            DB      033H
            DB      04BH
            DB      04CH
            DB      01DH
            DB      06CH
            DB      05BH
            DB      078H
            DB      041H
            DB      035H
            DB      034H
            DB      074H
            DB      030H
            DB      038H
            DB      075H
            DB      039H
            DB      04DH
            DB      06FH
            DB      06EH
            DB      032H
            DB      077H
            DB      076H
            DB      072H
            DB      073H
            DB      047H
            DB      07CH
            DB      053H
            DB      031H
            DB      04EH
            DB      06DH
            DB      048H
            DB      046H
            DB      07DH
            DB      044H
            DB      01BH
            DB      058H
            DB      079H
            DB      042H
            DB      060H
            DB      0FDH
            DB      0CBH
            DB      000H
            DB      01EH
            ;-------------------------------------------------------------------------------
            ; END OF SCREEN FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;----------------------------------------
            ;
            ;    ANSI EMULATION
            ;
            ;    Emulate the Ansi standard
            ;    N.B. Turned on when Chr
            ;         27 recieved.
            ;    Entry - A = Char
            ;    Exit  - None
            ;    Used  - None
            ;
            ;----------------------------------------
?ANSITERM:  PUSH    HL
            PUSH    DE
            PUSH    BC
            PUSH    AF
            LD      C,A                                                  ; Move character into C for safe keeping
            ;
            LD      A,(ANSIMODE)
            OR      A
            JR      NZ,ANSI2
            LD      A,C
            CP      27
            JP      NZ,NOTANSI                                           ; If it is Chr 27 then we haven't just
                                                                         ; been turned on, so don't bother with
                                                                         ; all the checking.
            LD      A,1                                                  ; Turn on.
            LD      (ANSIMODE),A
            JP      AnsiMore

ANSI2:      LD      A,(CHARACTERNO)                                      ; CHARACTER number in sequence
            OR      A                                                    ; Is this the first character?
            JP      Z,AnsiFirst                                          ; Yes, deal with this strange occurance!

            LD      A,C                                                  ; Put character back in C to check

            CP      ";"                                                  ; Is it a semi colon?
            JP      Z,AnsiSemi
    
            CP      "0"                                                  ; Is it a number?
            JR      C,ANSI_NN                                            ; If <0 then no
            CP      "9"+1                                                ; If >9 then no
            JP      C,AnsiNumber

ANSI_NN:    CP      "?"                                                  ; Simple trap for simple problem!
            JP      Z,AnsiMore

            CP      "@"                                                  ; Is it a letter?
            JP      C,ANSIEXIT                                           ; Abandon if not letter; something wrong

ANSIFOUND:  CALL    CURSRSTR                                             ; Restore any character under the cursor.
            LD      HL,(NUMBERPOS)                                       ; Get value of number buffer
            LD      A,(HAVELOADED)                                       ; Did we put anything in this byte?
            OR      A
            JR      NZ,AF1
            LD      (HL),255                                             ; Mark the fact that nothing was put in
AF1:        INC      HL
            LD      A,254
            LD      (HL),A                                               ; Mark end of sequence (for unlimited length sequences)

            ;Disable cursor as unwanted side effects such as screen flicker may occur.
            LD      A,(FLASHCTL)
            BIT     7,A
            CALL    NZ,CURSOROFF

            XOR     A
            LD      (CURSORCOUNT),A                                      ; Restart count
            LD      A,0C9h
            LD      (CHGCURSMODE),A                                      ; Disable flashing temp.

            LD      HL,NUMBERBUF                                         ; For the routine called.
            LD      A,C                                                  ; Restore number
            ;
            ;    Now work out what happens...
            ;
            CP      "A"                                                  ; Check for supported Ansi characters
            JP      Z,CUU                                                ; Upwards
            CP      "B"
            JP      Z,CUD                                                ; Downwards
            CP      "C"
            JP      Z,CUF                                                ; Forward
            CP      "D"
            JP      Z,CUB                                                ; Backward
            CP      "H"
            JP      Z,CUP                                                ; Locate
            CP      "f"
            JP      Z,HVP                                                ; Locate
            CP      "J"
            JP      Z,ED                                                 ; Clear screen
            CP      "m"
            JP      Z,SGR                                                ; Set graphics renditon
            CP      "K"
            JP      Z,EL                                                 ; Clear to end of line
            CP      "s"
            JP      Z,SCP                                                ; Save the cursor position
            CP      "u"
            JP      Z,RCP                                                ; Restore the cursor position

ANSIEXIT:   CALL    CURSORON                                             ; If t
            LD      HL,NUMBERBUF                                         ; Numbers buffer position
            LD      (NUMBERPOS),HL
            XOR     A
            LD      (CHARACTERNO),A                                      ; Next time it runs, it will be the
                                                                         ; first character
            LD      (HAVELOADED),A                                       ; We haven't filled this byte!
            LD      (CHGCURSMODE),A                                      ; Cursor allowed back again!
            XOR     A
            LD      (ANSIMODE),A
            JR      AnsiMore
NOTANSI:    CP      000h                                                 ; Filter unprintable characters.
            JR      Z,AnsiMore
            CALL    ?PRNT
AnsiMore:   POP     AF
            POP     BC
            POP     DE
            POP     HL
            RET

            ;
            ;    The various routines needed to handle the filtered characters
            ;
AnsiFirst:  LD      A,255
            LD      (CHARACTERNO),A                                      ; Next character is not first!
            LD      A,C                                                  ; Get character back
            LD      (ANSIFIRST),A                                        ; Save first character to check later
            CP      "("                                                  ; ( and [ have characters to follow
            JP      Z,AnsiMore                                           ; and are legal.
            CP      "["
            JP      Z,AnsiMore
            CP      09Bh                                                 ; CSI
            JP      Z,AnsiF1                                             ; Pretend that "[" was first ;-)
            JP      ANSIEXIT                                             ; = and > don't have anything to follow
                                                                         ; them but are legal.  
                                                                         ; Others are illegal, so abandon anyway.
AnsiF1:     LD      A,"["                                                ; Put a "[" for first character
            LD      (ANSIFIRST),A
            JP      ANSIEXIT

AnsiSemi:   LD      HL,(NUMBERPOS)                                       ; Move the number pointer to the
            LD      A,(HAVELOADED)                                       ; Did we put anything in this byte?
            OR      A
            JR      NZ,AS1
            LD      (HL),255                                             ; Mark the fact that nothing was put in
AS1:        INC     HL                                                   ; move to next byte
            LD      (NUMBERPOS),HL
            XOR     A
            LD      (HAVELOADED),A                                       ; New byte => not filled!
            JP      AnsiMore

AnsiNumber: LD      HL,(NUMBERPOS)                                       ; Get address for number
            LD      A,(HAVELOADED)
            OR      A                                                    ; If value is zero
            JR      NZ,AN1
            LD      A,C                                                  ; Get value into A
            SUB     "0"                                                  ; Remove ASCII offset
            LD      (HL),A                                               ; Save and Exit
            LD      A,255
            LD      (HAVELOADED),A                                       ; Yes, we _have_ put something in!
            JP      AnsiMore

AN1:        LD      A,(HL)                                               ; Stored value in A; TBA in C
            ADD     A,A                                                  ; 2 *
            LD      D,A                                                  ; Save the 2* for later
            ADD     A,A                                                  ; 4 *
            ADD     A,A                                                  ; 8 *
            ADD     A,D                                                  ; 10 *
            ADD     A,C                                                  ; 10 * + new num
            SUB     "0"                                                  ; And remove offset from C value!
            LD      (HL),A                                               ; Save and Exit.
            JP      AnsiMore                                             ; Note routine will only work up to 100
                                                                         ; which should be okay for this application.

            ;--------------------------------
            ;    GET NUMBER
            ;
            ;    Gets the next number from
            ;    the list
            ;
            ;    Entry - HL = address to get
            ;            from
            ;    Exit  - HL = next address
            ;        A  = value
            ;        IF a=255 then default value
            ;        If a=254 then end of sequence
            ;    Used  - None
            ;--------------------------------
GetNumber:  LD      A,(HL)                                               ; Get number
            CP      254
            RET     Z                                                    ; Return if end of sequence,ie still point to
                                                                         ; end
            INC     HL                                                   ; Return pointing to next byte
            RET                                                          ; Else next address and return

            ;***    ANSI UP
            ;
CUU:        CALL    GetNumber                                            ; Number into A
            LD      B,A                                                  ; Save value into B
            CP      255
            JR      NZ,CUUlp
            LD      B,1                                                  ; Default value
CUUlp:      LD      A,(DSPXY+1)                                          ; A <- Row
            CP      B                                                    ; Is it too far?
            JR      C,CUU1
            SUB     B                                                    ; No, then go back that far.
            JR      CUU2
CUU1:       LD      A,0                                                  ; Make the choice, top line.
CUU2:       LD      (DSPXY+1),A                                          ; Row <- A
            JP      ANSIEXIT

            ;***    ANSI DOWN
            ;
CUD:        LD      A,(ANSIFIRST)
            CP      "["
            JP      NZ,ANSIEXIT                                          ; Ignore ESC(B
            CALL    GetNumber
            LD      B,A                                                  ; Save value in b
            CP      255
            JR      NZ,CUDlp
            LD      B,1                                                  ; Default
CUDlp:      LD      A,(DSPXY+1)                                          ; A <- Row
            ADD     A,B
            CP      ROW                                                  ; Too far?
            JP      C,CUD1
            LD      A,ROW-1                                              ; Too far then bottom of screen
CUD1:       LD      (DSPXY+1),A                                          ; Row <- A
            JP      ANSIEXIT

            ;***    ANSI RIGHT
            ;
CUF:        CALL    GetNumber                                            ; Number into A
            LD      B,A                                                  ; Value saved in B
            CP      255
            JR      NZ,CUFget
            LD      B,1                                                  ; Default
CUFget:     LD      A,(DSPXY)                                            ; A <- Column
            ADD     A,B                                                  ; Add movement.
            CP      80                                                   ; Too far?
            JR      C,CUF2
            LD      A,79                                                 ; Yes, right edge
CUF2:       LD      (DSPXY),A                                            ; Column <- A
            JP      ANSIEXIT

            ;***    ANSI LEFT
            ;
CUB:        CALL    GetNumber                                            ; Number into A
            LD      B,A                                                  ; Save value in B
            CP      255
            JR      NZ,CUBget
            LD      B,1                                                  ; Default
CUBget:     LD      A,(DSPXY)                                            ; A <- Column
            CP      B                                                    ; Too far?
            JR      C,CUB1a
            SUB     B
            JR      CUB1b
CUB1a:      LD      A,0
CUB1b:      LD      (DSPXY),A                                            ; Column <-A
            JP      ANSIEXIT

            ;***    ANSI LOCATE
            ;
HVP:
CUP:        CALL    GetNumber
            CP      255
            CALL    Z,DefaultLine                                        ; Default = 1
            CP      254                                                  ; Sequence End -> 1
            CALL    Z,DefaultLine
            CP      ROW+1                                                ; Out of range then don't move
            JP      NC,ANSIEXIT
            OR      A
            CALL    Z,DefaultLine                                        ; 0 means default, some strange reason
            LD      D,A
            CALL    GetNumber
            CP      255                                                  ; Default = 1
            CALL    Z,DefaultColumn
            CP      254                                                  ; Sequence End -> 1
            CALL    Z,DefaultColumn
            CP      81                                                   ; Out of range, then don't move
            JP      NC,ANSIEXIT
            OR      A
            CALL    Z,DefaultColumn                                      ; 0 means go with default
            LD      E,A
            EX      DE,HL
            DEC     H                                                    ; Translate from Ansi co-ordinates to hardware
            DEC     L                                                    ; co-ordinates
            LD      (DSPXY),HL                                           ; Set the cursor position.
            JP      ANSIEXIT

DefaultColumn:
DefaultLine:LD      A,1
            RET

            ;***    ANSI CLEAR SCREEN
            ;
ED:         CALL    GetNumber
            OR      A
            JP      Z,ED1                                                ; Zero means first option
            CP      254                                                  ; Also default
            JP      Z,ED1
            CP      255
            JP      Z,ED1
            CP      1
            JP      Z,ED2
            CP      2
            JP      NZ,ANSIEXIT

            ;***    Option 2
            ;
ED3:        LD      HL,0
            LD      (DSPXY),HL                                           ; Home the cursor
            LD      A,(JSW_FF)
            OR      A
            JP      NZ,ED_Set_LF
            CALL    CALCSCADDR
            CALL    CLRSCRN
            JP      ANSIEXIT

ED_Set_LF:  XOR     A                                                    ; Note simply so that
            LD      (JSW_LF),A                                           ; ESC[2J works the same as CTRL-L
            JP      ANSIEXIT

            ;***    Option 0
            ;
ED1:        LD      HL,(DSPXY)                                           ; Get and save cursor position
            LD      A,H
            OR      L
            JP      Z,ED3                                                ; If we are at the top of the
                                                                         ; screen and clearing to the bottom
                                                                         ; then we are clearing all the screen!
            PUSH    HL
            LD      A,ROW-1
            SUB     H                                                    ; ROW - Row
            LD      HL,0                                                 ; Zero start
            OR      A                                                    ; Do we have any lines to add?
            JR      Z,ED1_2                                              ; If no bypass that addition!
            LD      B,A                                                  ; Number of lines to count
            LD      DE,80
ED1_1:      ADD     HL,DE
            DJNZ    ED1_1
ED1_2:      EX      DE,HL                                                ; Value into DE
            POP     HL
            LD      A,80
            SUB     L                                                    ; 80 - Columns
            LD      L,A                                                  ; Add to value before
            LD      H,0
            ADD     HL,DE
            PUSH    HL                                                   ; Value saved for later
            LD      HL,(DSPXY)                                           ; _that_ value again!
            POP     BC                                                   ; Number to blank
            CALL    CALCSCADDR
            CALL    CLRSCRN                                              ; Now do it!
            JP      ANSIEXIT                                             ; Then exit properly

            ;***    Option 1 - clear from cursor to beginning of screen
            ;
ED2:        LD      HL,(DSPXY)                                           ; Get and save cursor position
            PUSH    HL
            LD      A,H
            LD      HL,0                                                 ; Zero start
            OR      A                                                    ; Do we have any lines to add?
            JR      Z,ED2_2                                              ; If no bypass that addition!
            LD      B,A                                                  ; Number of lines
            LD      DE,80
ED2_1:      ADD     HL,DE
            DJNZ    ED2_1
ED2_2:      EX      DE,HL                                                ; Value into DE
            POP     HL
            LD      H,0
            ADD     HL,DE
            PUSH    HL                                                   ; Value saved for later
            LD      HL,0                                                 ; Find the begining!
            POP     BC                                                   ; Number to blank
            CALL    CLRSCRN                                              ; Now do it!
            JP      ANSIEXIT                                             ; Then exit properly

            ; ***    ANSI CLEAR LINE
            ;
EL:         CALL    GetNumber                                            ; Get value
            CP      0
            JP      Z,EL1                                                ; Zero & Default are the same
            CP      255
            JP      Z,EL1
            CP      254
            JP      Z,EL1
            CP      1
            JP      Z,EL2
            CP      2
            JP      NZ,ANSIEXIT                                          ; Otherwise don't do a thing

            ;***    Option 2 - clear entire line.
            ;
            LD      HL,(DSPXY)
            LD      L,0
            LD      (DSPXY),HL
            CALL    CALCSCADDR
            LD      BC,80                                                ; 80 bytes to clear (whole line)
            CALL    CLRSCRN
            JP      ANSIEXIT

            ;***    Option 0 - Clear from Cursor to end of line.
            ;
EL1:        LD      HL,(DSPXY)
            LD      A,80                                                 ; Calculate distance to end of line
            SUB     L
            LD      C,A
            LD      B,0
            LD      (DSPXY),HL
            PUSH HL
            POP DE
            CALL    CALCSCADDR
            CALL    CLRSCRN
            JP      ANSIEXIT

            ;***    Option 1 - clear from cursor to beginning of line.
            ;
EL2:        LD      HL,(DSPXY)
            LD      C,L                                                  ; BC = distance from start of line
            LD      B,0
            LD      L,0
            LD      (DSPXY),HL
            CALL    CALCSCADDR
            CALL    CLRSCRN
            JP      ANSIEXIT

            ; In HL = XY Pos
            ; Out   = Screen address.
CALCSCADDR: PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            LD      A,H
            LD      B,H
            LD      C,L
            LD      HL,SCRN
            OR      A
            JR      Z,CALC3
            LD      DE,80
CALC2:      ADD     HL,DE
            DJNZ    CALC2
CALC3:      POP     DE
            ADD     HL,BC
            POP     DE
            POP     BC
            POP     AF
            RET

            ;    HL = address
            ;    BC = length
CLRSCRN:    PUSH    HL                                                   ; 1 for later!
            LD      D,H
            LD      E,L
            INC     DE                                                   ; DE <- HL +1
            PUSH    BC                                                   ; Save the value a little longer!
            XOR     A
            LD      (HL), A                                              ; Blank this area!
            LDIR                                                         ; *** just like magic ***
                                                                         ;     only I forgot it in 22a!
            POP     BC                                                   ; Restore values
            POP     HL
            LD      DE,2048                                              ; Move to attributes block
            ADD     HL,DE
            LD      D,H
            LD      E,L
            INC     DE                                                   ; DE = HL + 1
            LD      A,(FONTSET)                                          ; Save in the current values.
            LD      (HL),A
            LDIR
            RET
        
            ;***    ANSI SET GRAPHICS RENDITION
            ;
SGR:        CALL    GetNumber
            CP      254                                                  ; 254 signifies end of sequence
            JP      Z,ANSIEXIT
            OR      A
            CALL    Z,AllOff
            CP      255                                                  ; Default means all off
            CALL    Z,AllOff
            CP      1
            CALL    Z,BoldOn
            CP      2
            CALL    Z,BoldOff
            CP      4
            CALL    Z,UnderOn
            CP      5
            CALL    Z,ItalicOn
            CP      6
            CALL    Z,ItalicOn
            CP      7
            CALL    Z,InverseOn
            JP      SGR                                                  ; Code is re-entrant
        
            ;--------------------------------
            ;
            ;    RESET GRAPHICS
            ;
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
AllOff:     PUSH    AF                                                   ; Save registers
            LD      A,0C9h                                               ; = off
            LD      (BOLDMODE),A                                         ; Turn the flags off
            LD      (ITALICMODE),A
            LD      (UNDERSCMODE),A
            LD      (INVMODE),A
            LD      A,007h                                               ; Black background, white chars.
            LD      (FONTSET),A                                          ; Reset the bit map store
            POP     AF                                                   ; Restore register
            RET
        
            ;--------------------------------
            ;
            ;    TURN BOLD ON
            ;
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
BoldOn:     PUSH    AF                                                   ; Save register
            XOR     A                                                    ; 0 means on
            LD      (BOLDMODE),A
BOn1:       LD      A,(FONTSET)
            SET     0,A                                                  ; turn ON indicator flag
            LD      (FONTSET),A
            POP     AF                                                   ; Restore register
            RET
        
            ;--------------------------------
            ;
            ;    TURN BOLD OFF
            ;
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
BoldOff:    PUSH    AF                                                   ; Save register
            PUSH    BC
            LD      A,0C9h                                               ; &C9 means off
            LD      (BOLDMODE),A
BO1:        LD      A,(FONTSET)
            RES     0,A                                                  ; turn OFF indicator flag
            LD      (FONTSET),A
            POP     BC
            POP     AF                                                   ; Restore register
            RET
        
            ;--------------------------------
            ;
            ;    TURN ITALICS ON
            ;    (replaces flashing)
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
ItalicOn:   PUSH    AF                                                   ; Save AF
            XOR     A
            LD      (ITALICMODE),A                                       ; 0 means on
            LD      A,(FONTSET)
            SET     1,A                                                  ; turn ON indicator flag
            LD      (FONTSET),A
            POP     AF                                                   ; Restore register
            RET
        
            ;--------------------------------
            ;
            ;    TURN UNDERLINE ON
            ;
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
UnderOn:    PUSH    AF                                                   ; Save register
            XOR     A                                                    ; 0 means on
            LD      (UNDERSCMODE),A
            LD      A,(FONTSET)
            SET     2,A                                                  ; turn ON indicator flag
            LD      (FONTSET),A
            POP     AF                                                   ; Restore register
            RET
        
            ;--------------------------------
            ;
            ;    TURN INVERSE ON
            ;
            ;    Entry - None
            ;    Exit  - None
            ;    Used  - None
            ;--------------------------------
InverseOn:  PUSH    AF                                                   ; Save register
            XOR     A                                                    ; 0 means on
            LD      (INVMODE),A
            LD      A,(FONTSET)
            SET     3,A                                                  ; turn ON indicator flag
            LD     (FONTSET),A
            POP    AF                                                    ; Restore AF
            RET
        
            ;***    ANSI SAVE CURSOR POSITION
            ;
SCP:        LD      HL,(DSPXY)                                           ; (backup) <- (current)
            LD      (CURSORPSAV),HL
            JP      ANSIEXIT
        
            ;***    ANSI RESTORE CURSOR POSITION
            ;
RCP:        LD      HL,(CURSORPSAV)                                      ; (current) <- (backup)
            LD      (DSPXY),HL
            JP      ANSIEXIT

            ;-------------------------------------------------------------------------------
            ; END OF ANSI TERMINAL FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Align to end of bank.
            ALIGN   UROMADDR + 07F8h
            ORG     UROMADDR + 07F8h
            DB      0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
