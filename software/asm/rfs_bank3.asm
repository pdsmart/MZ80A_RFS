;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_bank3.asm
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

ROW         EQU     25
COLW        EQU     40
SCRNSZ      EQU     COLW * ROW
MODE80C     EQU     0

            ;===========================================================
            ;
            ; USER ROM BANK 3 - Monitor memory utilities.
            ;
            ;===========================================================
            ORG     UROMADDR

            ;--------------------------------
            ; Common code spanning all banks.
            ;--------------------------------
            NOP
            LD      B,16                                                     ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
ROMFS3_0:   LD      A,(BNKCTRLRST)
            DJNZ    ROMFS3_0                                                 ; Apply the default number of coded latch reads to enable the bank control registers.
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
BKSW3to0:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK0                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to1:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK1                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to2:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK2                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to3:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK3                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to4:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK4                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to5:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK5                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to6:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK6                                              ; Required bank to call.
            JR      BKSW3_0
BKSW3to7:   PUSH    AF
            LD      A, ROMBANK3                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK7                                              ; Required bank to call.
            ;
BKSW3_0:    PUSH    HL                                                       ; Place function to call on stack
            LD      HL, BKSWRET3                                             ; Place bank switchers return address on stack.
            EX      (SP),HL
            LD      (TMPSTACKP),SP                                           ; Save the stack pointer as some old code corrupts it.
            LD      (BNKSELUSER), A                                          ; Repeat the bank switch B times to enable the bank control register and set its value.
            JP      (HL)                                                     ; Jump to required function.
BKSWRET3:   POP     AF                                                       ; Get bank which called us.
            LD      (BNKSELUSER), A                                          ; Return to that bank.
            POP     AF
            RET  

            ;-------------------------------------------------------------------------------
            ; START OF TAPE/SD CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Method to copy an application on a tape to an SD stored application. The tape drive is read and the first
            ; encountered program is loaded into memory at 0x1200. The CMT header is populated with the correct details (even if
            ; the load address isnt 0x1200, the CMT Header contains the correct value).
            ; A call is then made to write the application to the SD card.
            ;
TAPE2SD:    ; Load from tape into memory, filling the tape CMT header and loading data into location 0x1200.
            LD      HL,LOADTAPECP                                        ; Call the Loadtape command, non execute version to get the tape contents into memory.
            CALL    BKSW3to4
            LD      A,(RESULT)
            OR      A
            JR      NZ,TAPE2SDERR
            ; Save to SD Card.
            LD      HL,SAVESDCARDX
            CALL    BKSW3to2
            LD      A,(RESULT)
            OR      A
            JR      NZ,TAPE2SDERR
            LD      DE,MSGT2SDOK
            JR      TAPE2SDERR2
TAPE2SDERR: LD      DE,MSGT2SDERR
TAPE2SDERR2:LD      HL,PRINTMSG
            CALL    BKSW3to6
            RET

            ; Method to copy an SD stored application to a Cassette tape in the CMT.
            ; The directory entry number or filename is passed to the command and the entry is located within the SD
            ; directory structure. The file is then loaded into memory and the CMT header populated. A call is then made
            ; to write out the data to tap.
            ;
SD2TAPE:    ; Load from SD, fill the CMT header then call CMT save.
            LD      HL,LOADSDCP
            CALL    BKSW3to2
            LD      A,(RESULT)
            OR      A
            JR      NZ,SD2TAPEERR
            LD      HL,SAVECMT
            CALL    BKSW3to4
            LD      A,(RESULT)
            OR      A
            JR      NZ,SD2TAPEERR
            RET
SD2TAPEERR: LD      DE,MSGSD2TERR
            JR      TAPE2SDERR2
            RET
            ;-------------------------------------------------------------------------------
            ; END OF TAPE/SD CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------


            ;-------------------------------------------------------------------------------
            ; START OF MEMORY CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;
            ;       Memory correction
            ;       command 'M'
            ;
MCORX:      CALL    READ4HEX                                             ; correction address
            RET     C
MCORX1:     CALL    NLPHL                                                ; corr. adr. print
            CALL    SPHEX                                                ; ACC ASCII display
            CALL    PRNTS                                                ; space print
            LD      DE,BUFER                                             ; Input the data.
            CALL    GETL
            LD      A,(DE)
            CP      01Bh                                                 ; If . pressed, exit.
            RET     Z
            PUSH    HL
            POP     BC
            CALL    HLHEX                                                ; If the existing address is no longer hex, reset. HLASCII(DE). If it is hex, take as the address to store data into.
            JR      C,MCRX3                                              ; Line is corrupted as the address is no longer in Hex, reset.
            INC     DE
            INC     DE
            INC     DE
            INC     DE
            INC     DE                                                   ;
            CALL    _2HEX                                                ; Get value entered.
            JR      C,MCORX1                                             ; Not hex, reset.
            CP      (HL)                                                 ; Not same as memory, reset.
            JR      NZ,MCORX1
            INC     DE                                                   ; 
            LD      A,(DE)                                               ; Check if no data just CR, if so, move onto next address.
            CP      00Dh                                                 ; not correction
            JR      Z,MCRX2
            CALL    _2HEX                                                ; Get the new entered data. ACCHL(ASCII)
            JR      C,MCORX1                                             ; New data not hex, reset.
            LD      (HL),A                                               ; data correct so store.
MCRX2:      INC     HL
            JR      MCORX1
MCRX3:      LD      H,B                                                  ; memory address
            LD      L,C
            JR      MCORX1

            ; Memory copy command 'CPY'
            ; Parameters: XXXYYYZZZ - XXXX = Source, YYYY = Destination, ZZZZ = Size
MCOPY:      CALL    READ4HEX                                             ; Source
            JR      C,MCOPYER1
            PUSH    HL
            CALL    READ4HEX                                             ; Destination
            JR      C,MCOPYER2
            PUSH    HL
            CALL    READ4HEX                                             ; Size
            JR      C,MCOPYER3
            PUSH    HL
            POP     BC                                                   ; Size
            POP     DE                                                   ; Destination
            POP     HL                                                   ; Source
            LDIR
            RET
            ;
MCOPYER3:   POP     HL
MCOPYER2:   POP     HL
MCOPYER1:   RET


            ; Dump method when called interbank as HL cannot be passed.
            ;
            ; BC = Start
            ; DE = End
DUMPBC:     PUSH    BC
            POP     HL
            JR      DUMP

            ; Command line utility to dump memory.
            ; Get start and optional end addresses from the command line, ie. XXXX[XXXX]
            ; Paging is implemented, 23 lines at a time, pressing U goes back 100H, pressing D scrolls down 100H
            ;
DUMPX:      CALL    HLHEX                                                ; Get start address if present into HL
            JR      NC,DUMPX1
            LD      DE,(DUMPADDR)                                        ; Setup default start and end.
            JR      DUMPX2
DUMPX1:     INC     DE
            INC     DE
            INC     DE
            INC     DE
            PUSH    HL
            CALL    HLHEX                                                ; Get end address if present into HL
            POP     DE                                                   ; DE = Start address
            JR      NC,DUMPX4                                            ; Both present? Then display.
DUMPX2:     LD      A,(SCRNMODE)
            OR      A
            LD      HL,000A0h                                            ; Make up an end address based on 160 bytes from start for 40 column mode.
            JR      Z,DUMPX3
            LD      HL,00140h                                            ; Make up an end address based on 320 bytes from start for 80 column mode.
DUMPX3:     ADD     HL,DE
DUMPX4:     EX      DE,HL
            ;
            ; HL = Start
            ; DE = End
DUMP:       LD      A,23
DUMP0:      LD      (TMPCNT),A
            LD      A,(SCRNMODE)                                         ; Configure output according to screen mode, 40/80 chars.
            OR      A
            JR      NZ,DUMP1
            LD      B,008H                                               ; 40 Char, output 23 lines of 40 char.
            LD      C,017H
            JR      DUMP2
DUMP1:      LD      B,010h                                               ; 80 Char, output 23 lines of 80 char.
            LD      C,02Fh
DUMP2:      CALL    NLPHL
DUMP3:      CALL    SPHEX
            INC     HL
            PUSH    AF
            LD      A,(DSPXY)
            ADD     A,C
            LD      (DSPXY),A
            POP     AF
            CP      020h
            JR      NC,DUMP4
            LD      A,02Eh
DUMP4:      CALL    ?ADCN
            CALL    PRNT3
            LD      A,(DSPXY)
            INC     C
            SUB     C
            LD      (DSPXY),A
            DEC     C
            DEC     C
            DEC     C
            PUSH    HL
            SBC     HL,DE
            POP     HL
            JR      NC,DUMP9
DUMP5:      DJNZ    DUMP3
            LD      A,(TMPCNT)
            DEC     A
            JR      NZ,DUMP0
DUMP6:      CALL    GETKY                                                ; Pause, X to quit, D to go down a block, U to go up a block.
            OR      A
            JR      Z,DUMP6
            CP      'D'
            JR      NZ,DUMP7
            LD      A,8
            JR      DUMP0
DUMP7:      CP      'U'
            JR      NZ,DUMP8
            PUSH    DE
            LD      DE,00100H
            OR      A
            SBC     HL,DE
            POP     DE
            LD      A,8
            JR      DUMP0
DUMP8:      CP      'X'
            JR      Z,DUMP9
            JR      DUMP
DUMP9:      LD      (DUMPADDR),HL                                        ; Store last address so we can just press D for next page,
            CALL    NL
            RET


            ; Cmd tool to clear memory.
            ; Read cmd line for an init byte, if one not present, use 00H
            ;
INITMEMX:   CALL    _2HEX
            JR      NC,INITMEMX1
            LD      A,000H
INITMEMX1:  PUSH    AF
            LD      DE,MSGINITM
            LD      HL,PRINTMSG
            CALL    BKSW1to6
            LD      HL,1200h
            LD      BC,0D000h - 1200h
            POP     DE
CLEAR1:     LD      A,D
            LD      (HL),A
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JP      NZ,CLEAR1
            RET


            ; Method to get the CMT parameters from the command line.
            ; The parameters which should be given are:
            ; XXXXYYYYZZZZ - where XXXX = Start Address, YYYY = End Address, ZZZZ = Execution Address.
            ; If the start, end and execution address parameters are correct, prompt for a filename which will be written into the CMT header.
            ; Output:  Reg C = 0 - Success
            ;                = 1 - Error.
GETCMTPARM: CALL    READ4HEX                                             ; Start address
            JR      C,GETCMT1
            LD      (DTADR),HL                                           ; data adress buffer
            LD      B,H
            LD      C,L
            CALL    READ4HEX                                             ; End address
            JR      C,GETCMT1
            SBC     HL,BC
            INC     HL
            LD      (SIZE),HL                                            ; byte size buffer
            CALL    READ4HEX                                             ; Execution address
            JR      C,GETCMT1
            LD      (EXADR),HL                                           ; buffer
            CALL    NL
            LD      DE,MSGSAVE                                           ; 'FILENAME? '
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            LD      DE,BUFER
            CALL    GETL
            LD      HL,BUFER+10
            LD      DE,NAME                                              ; name buffer
            LD      BC,FNSIZE
            LDIR                                                         ; C = 0 means success.
            RET 
GETCMT1:    LD      C,1                                                  ; C = 1 means an error occured.
            RET 

    
            ; Method to read 4 bytes from a buffer pointed to by DE and attempt to convert to a 16bit number. If it fails, print out an error
            ; message and return with C set.
            ;
            ; Input:  DE = Address of digits to conver.
            ; Output: HL = 16 bit number.

READ4HEX:   CALL    HLHEX
            JR      C,READ4HEXERR
            INC     DE
            INC     DE
            INC     DE
            INC     DE
            OR      A                                                    ; Clear carry flag.
            RET
READ4HEXERR:LD      DE,MSGREAD4HEX                                       ; Load up error message, print and exit.
READ4HEXPRE:LD      HL,PRINTMSG
            CALL    BKSW1to6
            SCF
            RET

            ;    SPACE PRINT AND DISP ACC
            ;    INPUT:HL=DISP. ADR.
SPHEX:      CALL    PRNTS                                                ; SPACE PRINT
            LD      A,(HL)
            CALL    PRTHX                                                ; DSP OF ACC (ASCII)
            LD      A,(HL)
            RET

            ;    NEW LINE AND PRINT HL REG (ASCII)
NLPHL:      CALL    NL
            CALL    PRTHL
            RET  
            ;-------------------------------------------------------------------------------
            ; END OF MEMORY CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF PRINTER CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------
PTESTX:     LD      A,(DE)
            CP      '&'                                                  ; plotter test
            JR      NZ,PTST1X
PTST0X:     INC     DE
            LD      A,(DE)
            CP      'L'                                                  ; 40 in 1 line
            JR      Z,.LPTX
            CP      'S'                                                  ; 80 in 1 line
            JR      Z,..LPTX
            CP      'C'                                                  ; Pen change
            JR      Z,PENX
            CP      'G'                                                  ; Graph mode
            JR      Z,PLOTX
            CP      'T'                                                  ; Test
            JR      Z,PTRNX
;
PTST1X:     CALL    PMSGX
ST1X2:      RET
.LPTX:      LD      DE,LLPT                                              ; 01-09-09-0B-0D
            JR      PTST1X
..LPTX:     LD      DE,SLPT                                              ; 01-09-09-09-0D
            JR      PTST1X
PTRNX:      LD      A,004h                                               ; Test pattern
            JR      LE999
PLOTX:      LD      A,002h                                               ; Graph mode
LE999:      CALL    LPRNTX
            JR      PTST0X
PENX:       LD      A,01Dh                                               ; 1 change code (text mode)
            JR      LE999
;
;
;       1 char print to $LPT
;
;        in: ACC print data
;
;
LPRNTX:     LD      C,000h                                               ; RDAX test
            LD      B,A                                                  ; print data store
            CALL    RDAX
            LD      A,B
            OUT     (0FFh),A                                             ; data out
            LD      A,080h                                               ; RDP high
            OUT     (0FEh),A
            LD      C,001h                                               ; RDA test
            CALL    RDAX
            XOR     A                                                    ; RDP low
            OUT     (0FEh),A
            RET
;
;       $LPT msg.
;       in: DE data low address
;       0D msg. end
;
PMSGX:      PUSH    DE
            PUSH    BC
            PUSH    AF
PMSGX1:     LD      A,(DE)                                               ; ACC = data
            CALL    LPRNTX
            LD      A,(DE)
            INC     DE
            CP      00Dh                                                 ; end ?
            JR      NZ,PMSGX1
            POP     AF
            POP     BC
            POP     DE
            RET

;
;       RDA check
;
;       BRKEY in to monitor return
;       in: C RDA code
;
RDAX:       IN      A,(0FEh)
            AND     00Dh
            CP      C
            RET     Z
            CALL    BRKEY
            JR      NZ,RDAX
            LD      SP,ATRB
            JR      ST1X2

            ;    40 CHA. IN 1 LINE CODE (DATA)
LLPT:       DB      01H                                                  ; TEXT MODE
            DB      09H
            DB      09H
            DB      0BH
            DB      0DH

            ;    80 CHA. 1 LINE CODE (DATA)
SLPT:       DB      01H                                                  ; TEXT MODE
            DB      09H
            DB      09H
            DB      09H
            DB      0DH

            ;-------------------------------------------------------------------------------
            ; END OF PRINTER CMDLINE TOOLS FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;--------------------------------------
            ;
            ; Message table - Refer to bank 6 for
            ;                 all messages.
            ;
            ;--------------------------------------

            ALIGN   0EFF8h
            ORG     0EFF8h
            DB      0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
