;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_bank4.asm
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


            ;===========================================================
            ;
            ; USER ROM BANK 4 - CMT Controller utilities.
            ;
            ;===========================================================
            ORG     UROMADDR

            ;--------------------------------
            ; Common code spanning all banks.
            ;--------------------------------
ROMFS4:     NOP
            XOR     A                                                         ; We shouldnt arrive here after a reset, if we do, select UROM bank 0
            LD      (RFSBK1),A
            LD      (RFSBK2),A                                                ; and start up - ie. SA1510 Monitor.
            ALIGN_NOPS 0E829H

            ;
            ; Bank switching code, allows a call to code in another bank.
            ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
            ;
BKSW4to0:   PUSH    AF
            LD      A, ROMBANK4                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK0                                              ; Required bank to call.
            JR      BKSW4_0
BKSW4to1:   PUSH    AF
            LD      A, ROMBANK4                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK1                                              ; Required bank to call.
            JR      BKSW4_0
BKSW4to2:   PUSH    AF
            LD      A, ROMBANK4                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK2                                              ; Required bank to call.
            JR      BKSW4_0
BKSW4to3:   PUSH    AF
            LD      A, ROMBANK4                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK3                                              ; Required bank to call.
            JR      BKSW4_0
BKSW4to4:   PUSH    AF
            LD      A, ROMBANK4                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK4                                              ; Required bank to call.
            JR      BKSW4_0
BKSW4to5:   PUSH    AF
            LD      A, ROMBANK4                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK5                                              ; Required bank to call.
            JR      BKSW4_0
BKSW4to6:   PUSH    AF
            LD      A, ROMBANK4                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK6                                              ; Required bank to call.
            JR      BKSW4_0
BKSW4to7:   PUSH    AF
            LD      A, ROMBANK4                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK7                                              ; Required bank to call.
            ;
BKSW4_0:    PUSH    BC                                                       ; Save BC for caller.
            LD      BC, BKSWRET4                                             ; Place bank switchers return address on stack.
            PUSH    BC
            LD      (RFSBK2), A                                              ; Bank switch in user rom space, A=bank.
            LD      (TMPSTACKP),SP                                           ; Save the stack pointer as some old code corrupts it.
            JP      (HL)                                                     ; Jump to required function.
BKSWRET4:   POP     BC
            POP     AF                                                       ; Get bank which called us.
            LD      (RFSBK2), A                                              ; Return to that bank.
            POP     AF
            RET                                                              ; Return to caller.


           ;-------------------------------------------------------------------------------
           ; START OF CMT CONTROLLER FUNCTIONALITY
           ;-------------------------------------------------------------------------------

;       Programm load
;
;       cmd. 'L'
;
LOADTAPENX: LD      L,0FFH
            JR      LOADTAPE1
LOADTAPE:   LD      L,000H
LOADTAPE1:  PUSH    HL                                                   ; Preserve auto execute flag.
            CALL    ?RDI
            JP      C,?ERX2
            CALL    NL
            LD      DE,MSG?2                                             ; 'LOADING '
            RST     018h
            LD      DE,NAME
            RST     018h
            XOR     A
            LD      (BUFER),A
            LD      HL,(DTADR)
            LD      A,H
            OR      L
            JR      NZ,LE941
            LD      HL,(EXADR)
            LD      A,H
            OR      L
            JR      NZ,LE941
            LD      A,0FFh
            LD      (BUFER),A
            LD      HL,01200h
            LD      (DTADR),HL
LE941:      CALL    ?RDD
            JP      C,?ERX2
            POP     HL                                                   ; Get back the auto execute flag.
            LD      A,L
            OR      A
            JR      Z,LOADTAPE4                                          ; Dont execute.
            LD      A,(BUFER)
            CP      0FFh
            JR      Z,LOADTAPELM                                         ; Execute at low memory?
            LD      BC,00100h
            LD      HL,(EXADR)
            JP      (HL)
LOADTAPELM: LD      A,(MEMSW)                                            ; Perform memory switch, mapping out ROM from $0000 to $C000
            LD      HL,01200h                                            ; Shift the program down to RAM at $0000
            LD      DE,00000h
            LD      BC,(SIZE)
            LDIR
            LD      BC,00100h
            JP      00000h
LOADTAPE4:  RET

;
;       Programm save
;
;       cmd. 'S'
;
SAVEX:      CALL    HEXIY                                                ; Start address
            LD      (DTADR),HL                                           ; data adress buffer
            LD      B,H
            LD      C,L
            CALL    INC4DE
            CALL    HEXIY                                                ; End address
            SBC     HL,BC                                                ; byte size
            INC     HL
            LD      (SIZE),HL                                            ; byte size buffer
            CALL    INC4DE
            CALL    HEXIY                                                ; execute address
            LD      (EXADR),HL                                           ; buffer
            CALL    NL
            LD      DE,MSGSAVE                                           ; 'FILENAME? '
            RST     018h
            CALL    GETLHEX                                              ; filename input
            CALL    INC4DE
            CALL    INC4DE
            LD      HL,NAME                                              ; name buffer
SAVX1:      INC     DE
            LD      A,(DE)
            LD      (HL),A                                               ; filename trans.
            INC     HL
            CP      00Dh                                                 ; end code
            JR      NZ,SAVX1
            LD      A,OBJCD                                              ; attribute: OBJ
            LD      (ATRB),A
            CALL    ?WRI
?ERX1:      JP      C,?ERX2
            CALL    ?WRD                                                 ; data
            JR      C,?ERX1
            CALL    NL
            LD      DE,MSGOK                                             ; 'OK!'
            RST     018h
            RET

VRFYX:      CALL    ?VRFY
            JP      C,?ERX2
            LD      DE,MSGOK                                             ; 'OK!'
            RST     018h
            RET

SGX:        LD      A,(SWRK)
            RRA
            CCF
            RLA
            LD      (SWRK),A
            RET

?ERX2:      CP      002h
            RET     Z
            CALL    NL
            LD      DE,MSGE1                                             ; 'CHECK SUM ER.'
            RST     018h
            RET

HEXIY:      EX      (SP),IY
            POP     AF
            CALL    HLHEX
            JR      C,HEXIY                                              ; Exit if the input is invalid
            JP      (IY)
HEXIY2:     POP     AF                                                   ; Waste the intermediate caller address
            RET                                                          ; Return to command processor.

        ;     INCREMENT DE REG.
INC4DE:     INC     DE
            INC     DE
            INC     DE
            INC     DE
            RET  

GETLHEX:    EX      (SP),HL
            POP     BC
            LD      DE,BUFER
            CALL    GETL
            LD      A,(DE)
            CP      01Bh
            JR      Z,HEXIY2
            JP      (HL)


;FNINP:     CALL     NL
;           LD       DE,MSGSV                                             ; 'FILENAME? '
;           RST      018h
;           LD       DE,BUFER
;           CALL     GETL
;           LD       A,(DE)
;           CP       #1B
;           JR       NZ,LEAF3
;          ;LD       HL,ST1X
;          ;EX       (SP),HL
;           RET
;
;LEAF3:     LD       B,000h
;           LD       DE,011ADh
;           LD       HL,BUFER
;           LD       A,(DE)
;           CP       00Dh
;           JR       Z,LEB20
;LEB00:     CP       020h
;           JR       NZ,LEB08
;           INC      DE
;           LD       A,(DE)
;           JR       LEB00
;LEB08:     CP       022h
;           JR       Z,LEB14
;LEB0C:     LD       (HL),A
;           INC      HL
;           INC      B
;           LD       A,011h
;           CP       B
;           JR       Z,FNINP
;LEB14:     INC      DE
;           LD       A,(DE)
;           CP       022h
;           JR       Z,LEB1E
;           CP       00Dh
;           JR       NZ,LEB0C
;LEB1E:     LD       A,00dh
;LEB20:     LD       (HL),A
;           RET
;

            ;-------------------------------------------------------------------------------
            ; END OF CMT CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;--------------------------------------
            ;
            ; Message table
            ;
            ;--------------------------------------
MSGSAVE:    DB      "FILENAME? ",            00DH

            ALIGN   0EFFFh
            DB      0FFh
