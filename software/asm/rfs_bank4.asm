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
            ; USER ROM BANK 4 - CMT Controller utilities.
            ;
            ;===========================================================
            ORG     UROMADDR

            ;--------------------------------
            ; Common code spanning all banks.
            ;--------------------------------
            NOP
            LD      B,16                                                     ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
ROMFS4_0:   LD      A,(BNKCTRLRST)
            DJNZ    ROMFS4_0                                                 ; Apply the default number of coded latch reads to enable the bank control registers.
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
BKSW4_0:    PUSH    HL                                                       ; Place function to call on stack
            LD      HL, BKSWRET4                                             ; Place bank switchers return address on stack.
            EX      (SP),HL
            LD      (TMPSTACKP),SP                                           ; Save the stack pointer as some old code corrupts it.
            LD      (BNKSELUSER), A                                          ; Repeat the bank switch B times to enable the bank control register and set its value.
            JP      (HL)                                                     ; Jump to required function.
BKSWRET4:   POP     AF                                                       ; Get bank which called us.
            LD      (BNKSELUSER), A                                          ; Return to that bank.
            POP     AF
            RET  

           ;-------------------------------------------------------------------------------
           ; START OF CMT CONTROLLER FUNCTIONALITY
           ;-------------------------------------------------------------------------------

            ; CMT Utility to Load a program from tape.
            ;
            ; Three entry points:
            ; LOADTAPE = Load the first program shifting to lo memory if required and execute.
            ; LOADTAPENX = Load the first program and return without executing.
            ; LOADTAPECP = Load the first program to address 0x1200 and return.
            ;
LOADTAPECP: LD      A,0FFH
            LD      (CMTAUTOEXEC),A
            JR      LOADTAPE2
LOADTAPENX: LD      A,0FFH
            JR      LOADTAPE1
LOADTAPE:   LD      A,000H
LOADTAPE1:  LD      (CMTAUTOEXEC),A
            XOR     A
LOADTAPE2:  LD      (CMTCOPY),A                                          ; Set cmt copy mode, 0xFF if we are copying.
            LD      A,0FFH                                               ; If called interbank, set a result code in memory to detect success.
            LD      (RESULT),A
            CALL    ?RDI
            JP      C,?ERX2
            LD      DE,MSGLOAD                                           ; 'LOADING '
            LD      BC,NAME
            LD      HL,PRINTMSG
            CALL    BKSW4to6
            XOR     A
            LD      (CMTLOLOAD),A

            LD      HL,(DTADR)                                           ; Common code, store load address in case we shift or manipulate loading.
            LD      (DTADRSTORE),HL

            LD      A,(CMTCOPY)                                          ; If were copying we always load at 0x1200.
            OR      A
            JR      Z,LOADTAPE3
            LD      HL,01200H
            LD      (DTADR),HL

LOADTAPE3:  LD      HL,(DTADR)                                           ; If were loading and the load address is below 0x1200, shift it to 0x1200 to load then move into correct location.
            LD      A,H
            OR      L
            JR      NZ,LOADTAPE4
            LD      A,0FFh
            LD      (CMTLOLOAD),A
            LD      HL,01200h
            LD      (DTADR),HL
LOADTAPE4:  CALL    ?RDD
            JP      C,?ERX2
            LD      HL,(DTADRSTORE)                                      ; Restore the original load address into the CMT header.
            LD      (DTADR),HL
            LD      A,(CMTCOPY)
            OR      A
            JR      NZ,LOADTAPE6
LOADTAPE5:  LD      A,(CMTAUTOEXEC)                                      ; Get back the auto execute flag.
            OR      A
            JR      NZ,LOADTAPE6                                         ; Dont execute..
            LD      A,(CMTLOLOAD)
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
            LD      HL,(EXADR)                                           ; Fetch exec address and run.
            JP      (HL)
LOADTAPE6:  LD      DE,MSGCMTDATA
            PUSH    HL                                                   ; Load address as parameter 2.
            LD      HL,(EXADR)
            PUSH    HL                                                   ; Execution address as parameter 1.
            LD      BC,(SIZE)                                            ; Size as BC parameter.
            LD      HL,PRINTMSG
            CALL    BKSW4to6
            POP     BC
            POP     BC                                                   ; Waste parameters.
            XOR     A                                                    ; Success.
            LD      (RESULT),A
            RET


            ; SA1510 Routine to write a tape header. Copied into the RFS and modified to merge better
            ; with the RFS interface.
            ;
CMTWRI:    ;DI      
            PUSH    DE
            PUSH    BC
            PUSH    HL
            LD      D,0D7H
            LD      E,0CCH
            LD      HL,IBUFE
            LD      BC,00080H
            CALL    CKSUM
            CALL    MOTOR
            JR      C,CMTWRI2                 
            LD      A,E
            CP      0CCH
            JR      NZ,CMTWRI1                
            PUSH    HL
            PUSH    DE
            PUSH    BC
            LD      DE,MSGCMTWRITE
            LD      BC,NAME
            LD      HL,PRINTMSG
            CALL    BKSW4to6
            POP     BC
            POP     DE
            POP     HL
CMTWRI1:    CALL    GAP
            CALL    WTAPE
CMTWRI2:    POP     HL
            POP     BC
            POP     DE
            CALL    MSTOP
            PUSH    AF
            LD      A,(TIMFG)
            CP      0F0H
            JR      NZ,CMTWRI3                
           ;EI      
CMTWRI3:    POP     AF
            RET     


            ; Method to save an application stored in memory to a cassette in the CMT. The start, size and execution address are either given in BUFER via the 
            ; command line and the a filename is prompted for and read, or alternatively all the data is passed into the function already set in the CMT header.
            ; The tape is then opened and the header + data are written out.
            ;
SAVECMT:    LD      A,0FFH                                               ; Set SDCOPY to indicate this is a copy command and not a command line save.
            JR      SAVEX1
            ;
            ; Normal entry point, the cmdline contains XXXXYYYYZZZZ where XXXX=start, YYYY=size, ZZZZ=exec addr. A filenname is prompted for and read.
            ; The data is stored in the CMT header prior to writing out the header and data..
            ;
SAVEX:      LD      HL,GETCMTPARM                                        ; Get the CMT parameters.
            CALL    BKSW4to3
            LD      A,C
            OR      A
            RET     NZ                                                   ; Exit if an error occurred.

            XOR     A
SAVEX1:     LD      (SDCOPY),A
            LD      A,0FFH
            LD      (RESULT),A                                           ; For interbank calls, pass result via a memory variable. Assume failure unless updated.
            LD      A,OBJCD                                              ; Set attribute: OBJ
            LD      (ATRB),A
            CALL    CMTWRI                                               ; Commence header write. Header doesnt need updating for header write.
?ERX1:      JP      C,?ERX2

            LD      A,(SDCOPY)
            OR      A
            JR      Z,SAVEX2
            LD      DE,(DTADR)
            LD      A,D                                                  ; If copying and address is below 1000H, then data is held at 1200H so update header for write.
            CP      001H
            JR      NC,SAVEX2
            LD      DE,01200H
            LD      (DTADR),DE
SAVEX2:     CALL    ?WRD                                                 ; data
            JR      C,?ERX1
            LD      DE,MSGSAVEOK                                         ; 'OK!'
            LD      HL,PRINTMSG
            CALL    BKSW4to6
            LD      A,0                                                  ; Success.
            LD      (RESULT),A
            RET
?ERX2:      CP      002h
            JR      NZ,?ERX3
            LD      (RESULT),A                                           ; Set break key pressed code.
            RET     Z
?ERX3:      LD      DE,MSGE1                                             ; 'CHECK SUM ER.'
            LD      HL,PRINTMSG
            CALL    BKSW4to6
            RET


            ; Method to verify that a tape write occurred free of error. After a write, the tape is read and compared with the memory that created it.
            ;
VRFYX:      CALL    ?VRFY
            JP      C,?ERX2
            LD      DE,MSGOK                                             ; 'OK!'
            LD      HL,PRINTMSG
            CALL    BKSW4to6
            RET

            ; Method to toggle the audible key press sound, ie a beep when a key is pressed.
            ;
SGX:        LD      A,(SWRK)
            RRA
            CCF
            RLA
            LD      (SWRK),A
            RET

            ;-------------------------------------------------------------------------------
            ; END OF CMT CONTROLLER FUNCTIONALITY
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
