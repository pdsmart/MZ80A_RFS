;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs.asm
;- Created:         September 2019
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series Rom Filing System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade.
;-
;- Credits:         
;- Copyright:       (c) 2019 Philip Smart <philip.smart@net2net.org>
;-
;- History:         September 2018 - Merged 2 utilities to create this compilation.
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

           ; Bring in additional resources.
           INCLUDE "RFS_Definitions.asm"


           ;======================================
           ;
           ; USER ROM BANK 0
           ;
           ;======================================
           ORG      0E800h


           ;--------------------------------
           ; Common code spanning all banks.
           ;--------------------------------
ROMFS:     NOP
           JR       ROMFS_0                                              ; Skip the reset vector.
           NOP
           NOP
           NOP
           NOP
           NOP
           NOP
           JP       00000H                                               ; Common point when an alternate bank needs to reset the system.
ROMFS_0:   LD       A, (ROMBK1)                                          ; Ensure all banks are at default on
           CP       4                                                    ; If the ROMBK1 value is 255, an illegal value, then the machine has just started so skip.
           JR       C, ROMFS_2
           XOR      A                                                    ; Clear the lower stack space as we use it for variables.
           LD       B, 7*8
           LD       HL, 01000H
ROMFS_1:   LD       (HL),A
           INC      HL
           DJNZ     ROMFS_1              
ROMFS_2:   LD       (RFSBK1),A                                           ; start up.
           LD       A, (ROMBK2)
           LD       (RFSBK2),A
           JP       MONITOR

           ;
           ; Bank switching code, allows a call to code in another bank.
           ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
           ;
BKSW0to0:  PUSH     AF
           LD       A, ROMBANK0                                          ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK0                                          ; Required bank to call.
           JR       BKSW0_0
BKSW0to1:  PUSH     AF
           LD       A, ROMBANK0                                          ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK1                                          ; Required bank to call.
           JR       BKSW0_0
BKSW0to2:  PUSH     AF
           LD       A, ROMBANK0                                          ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK2                                          ; Required bank to call.
           JR       BKSW0_0
BKSW0to3:  PUSH     AF
           LD       A, ROMBANK0                                          ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK3                                          ; Required bank to call.
           JR       BKSW0_0
BKSW0to4:  PUSH     AF
           LD       A, ROMBANK0                                          ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK4                                          ; Required bank to call.
           JR       BKSW0_0
BKSW0to5:  PUSH     AF
           LD       A, ROMBANK0                                          ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK5                                          ; Required bank to call.
           JR       BKSW0_0
BKSW0to6:  PUSH     AF
           LD       A, ROMBANK0                                          ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK6                                          ; Required bank to call.
           JR       BKSW0_0
BKSW0to7:  PUSH     AF
           LD       A, ROMBANK0                                          ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK7                                          ; Required bank to call.
           ;
BKSW0_0:   PUSH     BC                                                   ; Save BC for caller.
           LD       BC, BKSWRET0                                         ; Place bank switchers return address on stack.
           PUSH     BC
           LD       (RFSBK2), A                                          ; Bank switch in user rom space, A=bank.
           LD       (TMPSTACKP),SP                                       ; Save the stack pointer as some old code corrupts it.
           JP       (HL)                                                 ; Jump to required function.
BKSWRET0:  POP      BC
           POP      AF                                                   ; Get bank which called us.
           LD       (RFSBK2), A                                          ; Return to that bank.
           POP      AF
           RET                                                           ; Return to caller.

           ALIGN    0E880H
           ORG      0E880H

           ;-----------------------------------------
           ; Enhanced function Jump table.
           ;-----------------------------------------
PRTMZF:    JP       _PRTMZF
           ;-----------------------------------------

           ;
           ; Replacement command processor in place of the SA1510 command processor.
           ;
MONITOR:   LD       A, (ROMBK1)
           CP       1
           JR       Z, SET80CHAR
           CP       0
           JR       NZ, SIGNON
           ;
SET40CHAR: LD       A, 0                                                 ; Using MROM in Bank 0 = 40 char mode.
           LD       (DSPCTL), A
           LD       A, 0
           LD       (SCRNMODE), A
           LD       (SPAGE), A                                           ; Allow MZ80A scrolling
           JR       SIGNON
SET80CHAR: LD       A, 128                                               ; Using MROM in Bank 1 = 80 char mode.
           LD       (DSPCTL), A
           LD       A, 1
           LD       (SCRNMODE), A
           LD       A, 0FFH
           LD       (SPAGE), A                                           ; MZ80K Scrolling in 80 column mode for time being.
           ;
SIGNON:    LD       A,0C4h                                               ; Move cursor left to overwrite part of SA-1510 monitor banner.
           LD       E,004h                                               ; 2 times.
SIGNON1:   CALL     DPCT
           DEC      E
           JR       NZ,SIGNON1
           LD       DE,MSGSON                                            ; Sign on message,
           RST      018h

           LD       HL, SDINIT                                           ; SD Card Initialisation
           CALL     BKSW0to2                                             ; Call the initialisation routine.

           ; Command processor, table based.
           ; A line is inpt then a comparison made with entries in the table. If a match is found then the bank and function
           ; address are extracted and a call to the function @ given bank made. The commands can be of variable length
           ; but important to not that longer commands using the same letters as shorter commands must appear first in the table.
           ;
ST1X:      CALL     NL                                                   ; Command line monitor extension.
           LD       A,'*'
           CALL     PRNT
           LD       DE,BUFER
           CALL     GETL
           ;
CMDCMP:    LD       HL,CMDTABLE
CMDCMP0:   LD       DE,BUFER+1                                           ; First command byte after the * prompt.
           LD       A,(HL)
           BIT      7,A                                                  ; Bit 7 set on command properties indicates table end, exit if needed.
           JR       NZ,CMDNOCMP
           LD       C,A                                                  ; Command properties into C
           SET      6,C                                                  ; Assume command match.
           AND      007H                                                 ; Mask out bytes in command mask.
           LD       B,A                                                  ; Number of bytes in command.
           INC      HL
CMDCMP1:   LD       A,(DE)                                               ; Compare all bytes and reset match bit if we find a difference.
           CP       (HL)
           JR       Z, CMDCMP2
           RES      6,C                                                  ; No command match.
CMDCMP2:   INC      DE
           INC      HL
           DJNZ     CMDCMP1
           BIT      6,C                                                  ; Bit 7 is still set then we have a command match.
           JR       NZ,CMDCMP3
           INC      HL
           INC      HL                                                   ; Skip over function address
           JR       CMDCMP0                                              ; Try match next command.
CMDCMP3:   LD       A,(HL)                                               ; Command function address into HL
           INC      HL
           LD       H,(HL)
           LD       L,A
           PUSH     HL
           LD       (TMPADR),DE                                          ; Store the key buffer location where arguments start.
           LD       A,C
           SRL      A
           SRL      A
           SRL      A
           AND      007H                                                 ; Mask out just the bank number of the command.  
           LD       B,A
           LD       HL,BKSW0to0                                          ; Base address of bank switching functions.
           LD       DE,BKSW0to1 - BKSW0to0                               ; DE is the number of bytes between bank switch calls.
           OR       A
           JR       Z,CMDCMP5
CMDCMP4:   ADD      HL,DE
           DJNZ     CMDCMP4
CMDCMP5:   EX       DE,HL                                                ; Address of bank switch function into DE.
           POP      HL                                                   ; Get address of command into HL.
           LD       BC,CMDCMPEND
           PUSH     BC                                                   ; Address to return to after command is executed.
           PUSH     DE                                                   ; Now jump to DE which will switch to the correct bank and execute function at HL.
           LD       DE,(TMPADR)
           RET
CMDNOCMP:  LD       DE,MSGBADCMD
           RST      018H
CMDCMPEND: JP       ST1X

           ; Monitor command table. This table contains the list of recognised commands along with the 
           ; handler function and bank in which it is located.
           ;
           ;         7       6     5:3    2:0
           ;         END   MATCH  BANK   SIZE 
CMDTABLE:  DB       000H | 000H | 000H | 001H                            ; Bit 2:0 = Command Size, 5:3 = Bank, 6 = Command match, 7 = Command table end.
           DB       '4'                                                  ; 40 Char screen mode.
           DW       SETMODE40
           DB       000H | 000H | 000H | 001H
           DB       '8'                                                  ; 80 Char screen mode.
           DW       SETMODE80
           DB       000H | 000H | 000H | 001H
           DB       'B'                                                  ; Bell.
           DW       SGX
           DB       000H | 000H | 000H | 001H
           DB       'C'                                                  ; Clear Memory.
           DW       INITMEMX
           DB       000H | 000H | 000H | 001H
           DB       'D'                                                  ; Dump Memory.
           DW       DUMPX
           DB       000H | 000H | 008H | 001H
           DB       'F'                                                  ; RFS Floppy boot code.
           DW       FLOPPY
           DB       000H | 000H | 000H | 001H
           DB       0AAH                                                 ; Original Floppy boot code.
           DW       FDCK
           DB       000H | 000H | 018H | 001H
           DB       'H'                                                  ; Help screen.
           DW       HELP
           DB       000H | 000H | 000H | 002H
           DB       "IR"                                                 ; List ROM directory.
           DW       DIRROM
           DB       000H | 000H | 010H | 002H
           DB       "IC"                                                 ; List SD Card directory.
           DW       DIRSDCARD
           DB       000H | 000H | 000H | 001H
           DB       'J'                                                  ; Jump to address.
           DW       GOTOX
           DB       000H | 000H | 000H | 004H
           DB       "LTNX"                                               ; Load from CMT without auto execution.
           DW       LOADTAPENX
           DB       000H | 000H | 000H | 002H
           DB       "LT"                                                 ; Load from CMT
           DW       LOADTAPE
           DB       000H | 000H | 000H | 004H
           DB       "LRNX"                                               ; Load from ROM without auto execution.
           DW       LOADROMNX
           DB       000H | 000H | 000H | 002H
           DB       "LR"                                                 ; Load from ROM
           DW       LOADROM
           DB       000H | 000H | 000H | 004H
           DB       "LCNX"                                               ; Load from SDCARD without auto execution.
           DW       LOADSDCARDX
           DB       000H | 000H | 000H | 002H
           DB       "LC"                                                 ; Load from SD CARD
           DW       LOADSDCARD
           DB       000H | 000H | 000H | 001H
           DB       "L"                                                  ; Original Load from CMT
           DW       LOADTAPE
           DB       000H | 000H | 000H | 001H
           DB       'M'                                                  ; Edit Memory.
           DW       MCORX
           DB       000H | 000H | 000H | 001H
           DB       'P'                                                  ; Printer test.
           DW       PTESTX
           DB       000H | 000H | 018H | 001H
           DB       'R'                                                  ; Memory test.
           DW       MEMTEST
           DB       000H | 000H | 000H | 001H
           DB       'S'                                                  ; Save to CMT
           DW       SAVEX
           DB       000H | 000H | 018H | 001H
           DB       'T'                                                  ; Timer test.
           DW       TIMERTST
           DB       000H | 000H | 000H | 001H
           DB       'V'                                                  ; Verify CMT Save.
           DW       VRFYX
           DB       000H | 000H | 000H | 001H
           DB       'X'                                                  ; Exchange to hi load rom so DRAM = 0000:0CFFF
           DW       HIROM
           DB       080H | 000H | 000H | 001H


FDCK:      CALL     LEB22                                                ; Check to see if the Floppy ROM is present, exit if it isnt.
           CALL     Z,0F000h
           JP       CMDCMPEND
?ERX:      CP       002h
           JP       Z,CMDCMPEND
           CALL     NL
           LD       DE,MSGE1                                             ; 'CHECK SUM ER.'
           RST      018h
           JP       CMDCMPEND
BGETLX:    EX       (SP),HL
           POP      BC
           LD       DE,BUFER
           CALL     GETL
           LD       A,(DE)
           CP       01Bh
           JP       Z,CMDCMPEND
           JP       (HL)

HEXIYX:    EX       (SP),IY
           POP      AF
           CALL     HLHEX
           JP       C,CMDCMPEND
           JP       (IY)

GOTOX:     CALL     HEXIYX
           JP       (HL)
               
LOADTAPENX:LD       L,0FFH
           JR       LOADTAPE1
LOADTAPE:  LD       L,000H
LOADTAPE1: PUSH     HL                                                   ; Preserve auto execute flag.
           CALL     ?RDI
           JR       C,?ERX
           CALL     NL
           LD       DE,MSG?2                                             ; 'LOADING '
           RST      018h
           LD       DE,NAME
           RST      018h
           XOR      A
           LD       (BUFER),A
           LD       HL,(DTADR)
           LD       A,H
           OR       L
           JR       NZ,LE941
           LD       HL,(EXADR)
           LD       A,H
           OR       L
           JR       NZ,LE941
           LD       A,0FFh
           LD       (BUFER),A
           LD       HL,01200h
           LD       (DTADR),HL
LE941:     CALL     ?RDD
           JR       C,?ERX
           POP      HL                                                   ; Get back the auto execute flag.
           LD       A,L
           OR       A
           JR       Z,LOADTAPE4                                          ; Dont execute.
           LD       A,(BUFER)
           CP       0FFh
           JR       Z,LOADTAPELM                                         ; Execute at low memory?
           LD       BC,00100h
           LD       HL,(EXADR)
           JP       (HL)
LOADTAPELM:LD       A,(MEMSW)                                            ; Perform memory switch, mapping out ROM from $0000 to $C000
           LD       HL,01200h                                            ; Shift the program down to RAM at $0000
           LD       DE,00000h
           LD       BC,(SIZE)
           LDIR
           LD       BC,00100h
           JP       00000h
LOADTAPE4: RET

PTESTX:    LD       A,(DE)
           CP       '&'                                                  ; plotter test
           JR       NZ,PTST1X
PTST0X:    INC      DE
           LD       A,(DE)
           CP       'L'                                                  ; 40 in 1 line
           JR       Z,.LPTX
           CP       'S'                                                  ; 80 in 1 line
           JR       Z,..LPTX
           CP       'C'                                                  ; Pen change
           JR       Z,PENX
           CP       'G'                                                  ; Graph mode
           JR       Z,PLOTX
           CP       'T'                                                  ; Test
           JR       Z,PTRNX
;
PTST1X:    CALL     PMSGX
ST1X2:     JP       CMDCMPEND
.LPTX:     LD       DE,LLPT                                              ; 01-09-09-0B-0D
           JR       PTST1X
..LPTX:    LD       DE,SLPT                                              ; 01-09-09-09-0D
           JR       PTST1X
PTRNX:     LD       A,004h                                               ; Test pattern
           JR       LE999
PLOTX:     LD       A,002h                                               ; Graph mode
LE999:     CALL     LPRNTX
           JR       PTST0X
PENX:      LD       A,01Dh                                               ; 1 change code (text mode)
           JR       LE999
;
;
;       1 char print to $LPT
;
;        in: ACC print data
;
;
LPRNTX:    LD       C,000h                                               ; RDAX test
           LD       B,A                                                  ; print data store
           CALL     RDAX
           LD       A,B
           OUT      (0FFh),A                                             ; data out
           LD       A,080h                                               ; RDP high
           OUT      (0FEh),A
           LD       C,001h                                               ; RDA test
           CALL     RDAX
           XOR      A                                                    ; RDP low
           OUT      (0FEh),A
           RET
;
;       $LPT msg.
;       in: DE data low address
;       0D msg. end
;
PMSGX:     PUSH     DE
           PUSH     BC
           PUSH     AF
PMSGX1:    LD       A,(DE)                                               ; ACC = data
           CALL     LPRNTX
           LD       A,(DE)
           INC      DE
           CP       00Dh                                                 ; end ?
           JR       NZ,PMSGX1
           POP      AF
           POP      BC
           POP      DE
           RET
;
;       RDA check
;
;       BRKEY in to monitor return
;       in: C RDA code
;
RDAX:      IN       A,(0FEh)
           AND      00Dh
           CP       C
           RET      Z
           CALL     BRKEY
           JR       NZ,RDAX
           LD       SP,ATRB
           JR       ST1X2
;
;       Memory correction
;       command 'M'
;
MCORX:     CALL     HEXIYX                                               ; correction address
MCORX1:    CALL     NLPHL                                                ; corr. adr. print
           CALL     SPHEX                                                ; ACC ASCII display
           CALL     PRNTS                                                ; space print
           CALL     BGETLX                                               ; get data & check data
           CALL     HLHEX                                                ; HLASCII(DE)
           JR       C,MCRX3
           CALL     DOT4DE                                               ; INC DE * 4
           INC      DE
           CALL     _2HEX                                                ; data check
           JR       C,MCORX1
           CP       (HL)
           JR       NZ,MCORX1
           INC      DE
           LD       A,(DE)
           CP       00Dh                                                 ; not correction
           JR       Z,MCRX2
           CALL     _2HEX                                                ; ACCHL(ASCII)
           JR       C,MCORX1
           LD       (HL),A                                               ; data correct
MCRX2:     INC      HL
           JR       MCORX1
MCRX3:     LD       H,B                                                  ; memory address
           LD       L,C
           JR       MCORX1
;
;       Programm save
;
;       cmd. 'S'
;
SAVEX:     CALL     HEXIYX                                               ; Start address
           LD       (DTADR),HL                                           ; data adress buffer
           LD       B,H
           LD       C,L
           CALL     DOT4DE
           CALL     HEXIYX                                               ; End address
           SBC      HL,BC                                                ; byte size
           INC      HL
           LD       (SIZE),HL                                            ; byte size buffer
           CALL     DOT4DE
           CALL     HEXIYX                                               ; execute address
           LD       (EXADR),HL                                           ; buffer
           CALL     NL
           LD       DE,MSGSV                                             ; 'FILENAME? '
           RST      018h
           CALL     BGETLX                                               ; filename input
           CALL     DOT4DE
           CALL     DOT4DE
           LD       HL,NAME                                              ; name buffer
SAVX1:     INC      DE
           LD       A,(DE)
           LD       (HL),A                                               ; filename trans.
           INC      HL
           CP       00Dh                                                 ; end code
           JR       NZ,SAVX1
           LD       A,OBJCD                                              ; attribute: OBJ
           LD       (ATRB),A
           CALL     ?WRI
?ERX1:     JP       C,?ERX
           CALL     ?WRD                                                 ; data
           JR       C,?ERX1
           CALL     NL
           LD       DE,MSGOK                                             ; 'OK!'
           RST      018h
LEA5B:     JP       ST1X

VRFYX:     CALL     ?VRFY
           JP       C,?ERX
           LD       DE,MSGOK                                             ; 'OK!'
           RST      018h
           JR       LEA5B

SGX:       LD       A,(SWRK)
           RRA
           CCF
           RLA
           LD       (SWRK),A
LEA76:     JR       LEA5B

DUMPX:     CALL     HEXIYX
           CALL     DOT4DE
           PUSH     HL
           CALL     HLHEX
           POP      DE
           JR       C,DUM1
L0D36:     EX       DE,HL
DUM3:      LD       B,008h
           LD       C,017h
           CALL     NLPHL
DUM2:      CALL     SPHEX
           INC      HL
           PUSH     AF
           LD       A,(DSPXY)
           ADD      A,C
           LD       (DSPXY),A
           POP      AF
           CP       020h
           JR       NC,L0D51
           LD       A,02Eh
L0D51:     CALL     ?ADCN
           CALL     PRNT3
           LD       A,(DSPXY)
           INC      C
           SUB      C
           LD       (DSPXY),A
           DEC      C
           DEC      C
           DEC      C
           PUSH     HL
           SBC      HL,DE
           POP      HL
           JR       Z,L0D85
           LD       A,0F8h
           LD       (0E000h),A
           NOP
           LD       A,(0E001h)
           CP       0FEh
           JR       NZ,L0D78
           CALL     ?BLNK
L0D78:     DJNZ     DUM2
L0D7A:     CALL     ?KEY
           OR       A
           JR       Z,L0D7A
           CALL     BRKEY
           JR       NZ,DUM3
L0D85:     JR       LEA76
DUM1:      LD       HL,000A0h
           ADD      HL,DE
           JR       L0D36

FNINP:     CALL     NL
           LD       DE,MSGSV                                             ; 'FILENAME? '
           RST      018h
           LD       DE,BUFER
           CALL     GETL
           LD       A,(DE)
           CP       #1B
           JR       NZ,LEAF3
          ;LD       HL,ST1X
          ;EX       (SP),HL
           RET

LEAF3:     LD       B,000h
           LD       DE,011ADh
           LD       HL,BUFER
           LD       A,(DE)
           CP       00Dh
           JR       Z,LEB20
LEB00:     CP       020h
           JR       NZ,LEB08
           INC      DE
           LD       A,(DE)
           JR       LEB00
LEB08:     CP       022h
           JR       Z,LEB14
LEB0C:     LD       (HL),A
           INC      HL
           INC      B
           LD       A,011h
           CP       B
           JR       Z,FNINP
LEB14:     INC      DE
           LD       A,(DE)
           CP       022h
           JR       Z,LEB1E
           CP       00Dh
           JR       NZ,LEB0C
LEB1E:     LD       A,00dh
LEB20:     LD       (HL),A
           RET

LEB22:     LD       A,(0F000h)
           OR       A
           RET

        ;    INCREMENT DE REG.

DOT4DE:    INC      DE
           INC      DE
           INC      DE
           INC      DE
           RET     

        ;    SPACE PRINT AND DISP ACC
        ;    INPUT:HL=DISP. ADR.

SPHEX:     CALL     PRNTS                                                ; SPACE PRINT
           LD       A,(HL)
           CALL     PRTHX                                                ; DSP OF ACC (ASCII)
           LD       A,(HL)
           RET   
                  
           ;    NEW LINE AND PRINT HL REG (ASCII)

NLPHL:     CALL     NL
           CALL     PRTHL
           RET  

           ; Clear memory.
INITMEMX:  LD       DE,MSG_INITM
           CALL     MSG
           CALL     LETNL
           LD       HL,1200h
           LD       BC,0D000h - 1200h
CLEAR1:    LD       A,00h
           LD       (HL),A
           INC      HL
           DEC      BC
           LD       A,B
           OR       C
           JP       NZ,CLEAR1
           RET

        ;    40 CHA. IN 1 LINE CODE (DATA)

LLPT:      DB       01H                                                  ; TEXT MODE
           DB       09H
           DB       09H
           DB       0BH
           DB       0DH

        ;    80 CHA. 1 LINE CODE (DATA)

SLPT:      DB       01H                                                  ; TEXT MODE
           DB       09H
           DB       09H
           DB       09H
           DB       0DH

;====================================
;
; Screen Width Commands
;
;====================================

HIROM:     LD       A, (MEMSW)                                           ; Swap ROM into high range slot.
           LD       A, ROMBANK2
           LD       (ROMBK1),A                                           ; Save bank being enabled.
           LD       (RFSBK1),A                                           ; Switch to the hiload rom in bank 2.
           JP       0C000H

SETMODE40: LD       A, ROMBANK0                                          ; Switch to 40Char monitor.
           LD       (ROMBK1),A
           LD       (RFSBK1),A
           LD       A, 0
           LD       (DSPCTL), A
           JP       MONIT

SETMODE80: LD       A, ROMBANK1                                          ; Switch to 80char monitor.
           LD       (ROMBK1),A
           LD       (RFSBK1),A
           LD       A, 128
           LD       (DSPCTL), A
           JP       MONIT

;====================================
;
; ROM File System Commands
;
;====================================

            ; HL contains address of block to check.
ISMZF:      PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            LD      A,(HL)
            CP      001h                                                 ; Only interested in machine code images.
            JR      NZ, ISMZFNOT
            ;
            INC     HL
            LD      DE,NAME                                              ; Checks to confirm this is an MZF header.
            LD      B,17                                                 ; Maximum of 17 characters, including terminator in filename.
ISMZFNXT:   LD      A,(HL)
            LD      (DE),A
            CP      00Dh                                                 ; If we find a terminator then this indicates potentially a valid name.
            JR      Z, ISMZFVFY
            CP      020h                                                 ; >= Space
            JR      C, ISMZFNOT
            CP      05Dh                                                 ; =< ]
            JR      C, ISMZFNXT3
ISMZFNXT2:  CP      091h
            JR      C, ISMZFNOT                                          ; DEL or > 0x7F, cant be a valid filename so this is not an MZF header.
ISMZFNXT3:  INC     DE
            INC     HL
            DJNZ    ISMZFNXT
            JR      ISMZFNOT                                             ; No end of string terminator, this cant be a valid filename.
ISMZFVFY:   LD      A,B
            CP      17
            JR      Z,ISMZFNOT                                           ; If the filename has no length it cant be valid, so loop.
ISMZFYES:   CP      A                                                    ; Set zero flag to indicate match.

ISMZFNOT:   POP     HL
            POP     DE
            POP     BC
            RET

PRTDBG:     PUSH    HL
            PUSH    DE
            PUSH    BC
            PUSH    AF
            LD      A,(ROMBK1)
            LD      (RFSBK1), A                                          ; Set the MROM bank back to original.
            CALL    PRTHL                                                ; HL
            LD      A, ' '
            CALL    PRNT
            LD      H,B
            LD      L,C
            CALL    PRTHL                                                ; BC
            LD      A, ' '
            CALL    PRNT
            LD      H,D
            LD      L,E
            CALL    PRTHL                                                ; DE
            LD      A, ' '
            CALL    PRNT
            POP     HL                                                   ; Get AF into HL.
            PUSH    HL
            CALL    PRTHL                                                ; AF
            LD      A, ' '
            CALL    PRNT
            LD      A, ':'
            CALL    PRNT
            LD      A, ' '
            CALL    PRNT
            LD      A,(WRKROMBK1)
            LD      (RFSBK1), A                                          ; Set the MROM bank back to scanned bank.
            POP     AF
            POP     BC
            POP     DE
            POP     HL
            RET

_PRTMZF:    PUSH    DE
            PUSH    HL
            ;
            LD      A,(ROMBK1)                                           ; Ensure main MROM is switched in.
            LD      (RFSBK1), A
            ;
            LD      A,(SCRNMODE)
            CP      0
            LD      H,46
            JR      Z,PRTMZF0
            LD      H,92
PRTMZF0:    LD      A,(TMPLINECNT)                                       ; Pause if we fill the screen.
            LD      E,A
            INC     E
            CP      H
            JR      NZ,PRTNOPAUSE
            LD      E, 0
PRTPAUSE:   CALL    ?KEY
            JR      Z,PRTPAUSE
PRTNOPAUSE: LD      A,E
            LD      (TMPLINECNT),A
            ;
            LD      A, D                                                 ; Print out file number and increment.
            CALL    PRTHX
            LD      A, '.'
            CALL    PRNT
            LD      DE,NAME                                              ; Print out filename.
            RST     018h
            ;
            LD      HL, (DSPXY)
            ;
            LD      A,L
            CP      20
            LD      A,20
            JR      C, PRTMZF2
            ;
            LD      A,(SCRNMODE)                                         ; 40 Char mode? 2 columns of filenames displayed so NL.
            CP      0
            JR      Z,PRTMZF1
            ;
            LD      A,L                                                  ; 80 Char mode we print 4 columns of filenames.
            CP      40
            LD      A,40
            JR      C, PRTMZF2
            ;
            LD      A,L
            CP      60
            LD      A,60
            JR      C, PRTMZF2
            ;
PRTMZF1:    CALL    NL
            JR      PRTMZF3
PRTMZF2:    LD      L,A
            LD      (DSPXY),HL
PRTMZF3:    LD      A, (WRKROMBK1)
            LD      (RFSBK1), A
            POP     HL
            POP     DE
            RET


DIRROM:     DI                                                           ; Disable interrupts as we are switching out the main rom.
            ;
            LD      A,1                                                  ; Account for the title.
            LD      (TMPLINECNT),A
            ;
            LD      DE,MSGRDIRLST                                        ; Print out header.
            RST     018h
            CALL    NL
            ;
            ; Scan MROM Bank
            ; B = Bank Page
            ; C = Block in page
            ; D = File sequence number.
            ;
            LD      B,MROMPAGES                                          ; First 4 pages are reserved in MROM bank.
            LD      C,0                                                  ; Block in page.
            LD      D,0                                                  ; File numbering start.
            ;
DIRNXTPG:   LD      A,B
            LD      (WRKROMBK1), A
            LD      (RFSBK1), A                                          ; Select bank.
            PUSH    BC                                                   ; Preserve bank count/block number.
            PUSH    DE                                                   ; Preserve file numbering.
            LD      A,C
            IF RFSSECTSZ >= 512
              RLCA
            ENDIF
            IF RFSSECTSZ >= 1024
              RLCA
            ENDIF
            LD      B,A
            LD      C,0
            LD      HL,RFS_ATRB                                          ; Add block offset to get the valid block address.
            ADD     HL,BC
            CALL    ISMZF
            POP     DE
            POP     BC
            JR      NZ, DIRNOTMZF
            ;
            CALL    PRTMZF
            INC     D                                                    ; Next file sequence number.
            ;
DIRNOTMZF:  INC     C                                                    ; Next block.
            LD      A,C
            CP      MROMSIZE/RFSSECTSZ                                   ; Max blocks per page reached?
            JR      C, DIRNXTPG2
            LD      C,0
            INC     B
DIRNXTPG2:  LD      A,B
            CP      080h                                                 ; MROM has 128 banks of 4K, so stop when we reach 128.           
            JR      NZ, DIRNXTPG
            ;
            ; Get directory of User ROM.
            ;
            LD      A,ROMBANK3
            LD      (WRKROMBK1),A
            LD      (RFSBK1), A
            CALL    DIRMROM
            LD      A,(ROMBK1)
            LD      (RFSBK1), A                                          ; Set the MROM bank back to original.
            EI                                                            ; No need to block interrupts now as MROM bank restored.
            RET                                                           ; End of scan, return to monitor
          ; JP      ST1X                                                 ; End of scan, return to monitor


            ; In:
            ;     DE = filename
            ; Out:
            ;      B = Bank Page file found
            ;      C = Block where found.
            ;      D = File sequence number.
            ;      Z set if found.
FINDMZF:    PUSH    DE
            LD      (TMPADR), DE                                         ; Save name of program to load.  
            LD      HL,0FFFFh                                            ; Tag the filenumber as invalid.
            LD      (TMPCNT), HL 
            CALL    ConvertStringToNumber                                ; See if a file number was given instead of a filename.
            JR      NZ, FINDMZF0                                         ; 
            LD      (TMPCNT), HL                                         ; Store filenumber making load by filenumber valid.
            ;
            ; Scan MROM Bank
            ; B = Bank Page
            ; C = Block in page
            ; D = File sequence number.
            ;
FINDMZF0:   LD      B,MROMPAGES                                          ; First 4 pages are reserved in User ROM bank.
            LD      C,0                                                  ; Block in page.
            LD      D,0                                                  ; File numbering start.
FINDMZF1:   LD      A,B
            LD      (WRKROMBK1), A
            LD      (RFSBK1), A                                          ; Select bank.
FINDMZF2:   PUSH    BC                                                   ; Preserve bank count/block number.
            PUSH    DE                                                   ; Preserve file numbering.
            LD      HL,RFS_ATRB                                          ; Add block offset to get the valid block.
            LD      A,C
            IF RFSSECTSZ >= 512
              RLCA
            ENDIF
            IF RFSSECTSZ >= 1024
              RLCA
            ENDIF
            LD      B,A
            LD      C,0
            ADD     HL,BC

            CALL    ISMZF
            POP     DE
            POP     BC
            LD      A,(ROMBK1)
            LD      (RFSBK1), A                                          ; Set the MROM bank back to original.
            JR      NZ, FINDMZF4                                         ; Z set if we found an MZF record.
            INC     HL                                                   ; Save address of filename.
            PUSH    HL
          ; CALL    PRTMZF                                               ; Print out for confirmation.
            LD      HL,(TMPCNT)
            LD      A,H
            CP      0FFh                                                 ; If TMPCNT tagged as 0xFF then we dont have a filenumber so must match filename.
            JR      Z, FINDMZF3
            LD      A,L                                                  ; Check file number, load if match
            CP      D
            JR      NZ, FINDMZF3                                         ; Check name just in case.
            POP     HL
            JR      FINDMZFYES                                           ; Else the filenumber matches so load the file.

FINDMZF3:   POP     HL
            PUSH    DE
            PUSH    BC
            LD      DE,(TMPADR)                                          ; Original DE put onto stack, original filename into HL 
            LD      BC,17
            LD      A,(WRKROMBK1)
            LD      (RFSBK1), A                                          ; Select correct bank for comparison.
            CALL    CMPSTRING
            POP     BC
            POP     DE
            JR      Z, FINDMZFYES
            INC     D                                                    ; Next file sequence number.           
FINDMZF4:   INC     C
            LD      A,C
            CP      MROMSIZE/RFSSECTSZ                                   ; Max blocks per page reached?
            JR      C, FINDMZF5
            LD      C,0
            INC     B
FINDMZF5:   LD      A,B
            CP      080h                                                 ; MROM has 128 banks of 4K, so stop when we get to 128.
            JR      NZ, FINDMZF1
            INC     B
            JR      FINDMZFNO

FINDMZFYES:                                                               ; Flag set by previous test.
FINDMZFNO:  PUSH    AF
            LD      A,(ROMBK1)
            LD      (RFSBK1), A                                          ; Set the MROM bank back to original.
            POP     AF
            POP     HL
            RET


            ; Load Program from ROM
            ; IN    DE     Name of program to load.
            ; OUT   zero   Set if string1 = string2, reset if string1 != string2.
            ;       carry  Set if string1 > string2, reset if string1 <= string2.
LOADROMNX:  LD      L,0FFH
            JR      LOADROM1
LOADROM:    LD      L,000H
LOADROM1:   DI
            PUSH    HL                                                   ; Preserve execute flag.
            CALL    FINDMZF                                              ; Find the bank and block where the file resides. HL = filename.
            JR      Z, LROMLOAD

            LD      A,ROMBANK3                                           ; Activate the RFS Utilities MROM bank.
            LD      (WRKROMBK1), A
            LD      (RFSBK1), A
            CALL    MFINDMZF                                             ; Try and find the file in User ROM via MROM utility.
            JR      NZ, LROMNTFND
            CALL    MROMLOAD                                             ; Load the file from User ROM via MROM utility.
            JP      Z, LROMLOAD5

LROMNTFND:  POP     HL                                                   ; Dont need execute flag anymore so waste it.
            LD      A,(ROMBK1)
            LD      (RFSBK1),A
            LD      DE,MSGNOTFND                                         ; Not found
            RST     018h

LOADROMEND: EI
            RET

            ;
            ; Load program from RFS Bank 1 (MROM Bank)
            ;
LROMLOAD:   PUSH    BC
            LD      A,B
            LD      (WRKROMBK1),A
            LD      (RFSBK1), A
            ;
            LD      DE, IBUFE                                            ; Copy the header into the work area.
            LD      HL, 00000h                                           ; Add block offset to get the valid block.
            LD      A,C
            IF RFSSECTSZ >= 512
              RLCA
            ENDIF
            IF RFSSECTSZ >= 1024
              RLCA
            ENDIF
            LD      B,A
            LD      C,0
            ADD     HL,BC
            LD      BC, MZFHDRSZ
            LDIR

            PUSH    HL
            LD      DE, (DTADR)
            LD      HL, (SIZE)
            LD      BC, RFSSECTSZ - MZFHDRSZ
            SBC     HL, BC
            JR      NC, LROMLOAD4
            LD      HL, (SIZE)
            JR      LROMLOAD4

            ; HL = address in active block to read.
            ;  B = Bank
            ;  C = Block 
LROMLOAD2:  LD      A, B
            LD      (WRKROMBK1), A
            LD      (RFSBK1), A

LROMLOAD3:  PUSH    BC
            LD      HL, 00000h
            LD      A, C
            IF RFSSECTSZ >= 512
              RLCA
            ENDIF
            IF RFSSECTSZ >= 1024
              RLCA
            ENDIF
            LD      B, A
            LD      C, 0
            ADD     HL,BC
            PUSH    HL

            LD      DE, (TMPADR)
            LD      HL, (TMPSIZE)
            LD      BC, RFSSECTSZ
            SBC     HL, BC
            JR      NC, LROMLOAD4
            LD      BC, (TMPSIZE)
            LD      HL, 0
LROMLOAD4:  LD      (TMPSIZE), HL                                        ; HL contains remaining amount of bytes to load.
            POP     HL
            ;
            LD      A, B                                                 ; Pre check to ensure BC is not zero.
            OR      C
            JR      Z, LROMLOAD8
            LDIR
            LD      BC, (TMPSIZE)
            LD      A, B                                                 ; Post check to ensure we still have bytes
            OR      C
            JR      Z, LROMLOAD8
            ;
            LD      (TMPADR),DE                                          ; Address we are loading into.
            POP     BC
LROMLOAD6:  INC     C
            LD      A, C
            CP      MROMSIZE/RFSSECTSZ                                   ; Max blocks per page reached?
            JR      C, LROMLOAD7
            LD      C, 0
            INC     B
            ;
LROMLOAD7:  LD      A, B
            CP      080h
            JR      Z, LROMLOAD5
            JR      LROMLOAD2
            ;
LROMLOAD8:  POP     BC
LROMLOAD5:  POP     HL                                                   ; Retrieve execute flag.
            LD      A,(ROMBK1)
            LD      (RFSBK1), A                                          ; Set the MROM bank back to original.
            LD      A,L                                                  ; Autoexecute turned off?
            CP      0FFh
            JP      Z,LROMLOAD9                                          ; Go back to monitor if it has been, else execute.
            LD      HL,(EXADR)
            EI                                                           ; No need to block interrupts now as MROM bank restored.
            JP      (HL)                                                 ; Execution address.
LROMLOAD9:  RET


            ; Load a program from the SD Card into RAM and/or execute it.
            ;
            ; DE points to a number or filename to load.
LOADSDCARDX:LD      A,0FFH
            JR      LOADSDCARD0
LOADSDCARD: LD      A,000H
LOADSDCARD0:LD      (SDAUTOEXEC),A
            PUSH    DE
            LD      HL,0FFFFh                                            ; Tag the filenumber as invalid.
            LD      (TMPCNT), HL 
            CALL    ConvertStringToNumber                                ; See if a file number was given instead of a filename.
            JR      NZ, LOADSDCARD1                                      ; 
            LD      (TMPCNT), HL                                         ; Store filenumber making load by filenumber valid.
LOADSDCARD1:POP     DE
            LD      HL,LOADSDE
            CALL    BKSW0to2                                             ; Call the main functionality in Bank2.
LOADSDCARD2:RET

;
;======================================
;
;       Message table
;
;======================================
;
MSGSON:     DB      "+ RFS ", 0ABh, "1.1 **",00Dh
MSGOK:      DB      "OK!"
MSGNOTFND:  DB      "NOT FOUND", 00Dh
MSGRDIRLST: DB      "ROM DIRECTORY:", 00Dh
MSGTRM:     DB      00Dh
MSGSV:      DB      "FILENAME? ",  0DH
MSG_INITM:  DB      "INIT MEMORY", 0Dh
MSGBADCMD:  DB      "???", 0DH

            ; Bring in additional resources.
            USE_CMPSTRING:    EQU   1
            USE_SUBSTRING:    EQU   0
            USE_INDEX:        EQU   0
            USE_STRINSERT:    EQU   0
            USE_STRDELETE:    EQU   0
            USE_CONCAT:       EQU   0
            USE_CNVUPPER:     EQU   1
            USE_CNVCHRTONUM:  EQU   1
            USE_ISNUMERIC:    EQU   1
            USE_CNVSTRTONUM:  EQU   1
            ;
            INCLUDE "Macros.asm"
            INCLUDE "RFS_Utilities.asm"
            ;
            ; Ensure we fill the entire 2K by padding with FF's.
            ALIGN    0EFFFh
            DB       0FFh

MEND:

            ;
            ; Include all other banks which make up the RFS User cited ROM.
            ;
            INCLUDE  "rfs_bank1.asm"
            INCLUDE  "rfs_bank2.asm"
            INCLUDE  "rfs_bank3.asm"
            INCLUDE  "rfs_bank4.asm"
            INCLUDE  "rfs_bank5.asm"
            INCLUDE  "rfs_bank6.asm"
            INCLUDE  "rfs_bank7.asm"
