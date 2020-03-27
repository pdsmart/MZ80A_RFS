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


            ;============================================================
            ;
            ; USER ROM BANK 0 - Main RFS Entry point and functions.
            ;
            ;============================================================
            ORG     UROMADDR


            ;--------------------------------
            ; Common code spanning all banks.
            ;--------------------------------
ROMFS:      NOP
            JR      ROMFS_0                                              ; Skip the reset vector.
            NOP
            NOP
            NOP
            NOP
            NOP
            NOP
            JP      00000H                                               ; Common point when an alternate bank needs to reset the system.
ROMFS_0:    LD      A, (ROMBK1)                                          ; Ensure all banks are at default on
            CP      4                                                    ; If the ROMBK1 value is 255, an illegal value, then the machine has just started so skip.
            JR      C, ROMFS_2
            XOR     A                                                    ; Clear the lower stack space as we use it for variables.
            LD      B, 7*8
            LD      HL, 01000H
ROMFS_1:    LD      (HL),A
            INC     HL
            DJNZ    ROMFS_1              
ROMFS_2:    LD      (RFSBK1),A                                           ; start up.
            LD      A, (ROMBK2)
            LD      (RFSBK2),A
            JP      MONITOR

            ;
            ; Bank switching code, allows a call to code in another bank.
            ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
            ;
BKSW0to0:   PUSH    AF
            LD      A, ROMBANK0                                          ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK0                                          ; Required bank to call.
            JR      BKSW0_0
BKSW0to1:   PUSH    AF
            LD      A, ROMBANK0                                          ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK1                                          ; Required bank to call.
            JR      BKSW0_0
BKSW0to2:   PUSH    AF
            LD      A, ROMBANK0                                          ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK2                                          ; Required bank to call.
            JR      BKSW0_0
BKSW0to3:   PUSH    AF
            LD      A, ROMBANK0                                          ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK3                                          ; Required bank to call.
            JR      BKSW0_0
BKSW0to4:   PUSH    AF
            LD      A, ROMBANK0                                          ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK4                                          ; Required bank to call.
            JR      BKSW0_0
BKSW0to5:   PUSH    AF
            LD      A, ROMBANK0                                          ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK5                                          ; Required bank to call.
            JR      BKSW0_0
BKSW0to6:   PUSH    AF
            LD      A, ROMBANK0                                          ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK6                                          ; Required bank to call.
            JR      BKSW0_0
BKSW0to7:   PUSH    AF
            LD      A, ROMBANK0                                          ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK7                                          ; Required bank to call.
            ;
BKSW0_0:    PUSH    HL                                                   ; Place function to call on stack
            LD      HL, BKSWRET0                                         ; Place bank switchers return address on stack.
            EX      (SP),HL
            LD      (TMPSTACKP),SP                                       ; Save the stack pointer as some old code corrupts it.
            LD      (RFSBK2), A                                          ; Bank switch in user rom space, A=bank.
            JP      (HL)                                                 ; Jump to required function.
BKSWRET0:   POP     AF                                                   ; Get bank which called us.
            LD      (RFSBK2), A                                          ; Return to that bank.
            POP     AF
            RET                                                          ; Return to caller.

            ALIGN   RFSJMPTABLE
            ORG     RFSJMPTABLE

            ;-----------------------------------------
            ; Enhanced function Jump table.
            ;-----------------------------------------
PRTMZF:     JP       _PRTMZF
            ;-----------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF RFS INITIALISATION AND COMMAND ENTRY PROCESSOR FUNCTIONALITY.
            ;-------------------------------------------------------------------------------
            ;
            ; Replacement command processor in place of the SA1510 command processor.
            ;
MONITOR:    LD      A, (ROMBK1)
            CP      1
            JR      Z, SET80CHAR
            CP      0
            JR      NZ, SIGNON
            ;
SET40CHAR:  LD      A, 0                                                 ; Using MROM in Bank 0 = 40 char mode.
            LD      (DSPCTL), A
            LD      A, 0
            LD      (SCRNMODE), A
            LD      (SPAGE), A                                           ; Allow MZ80A scrolling
            JR      SIGNON
SET80CHAR:  LD      A, 128                                               ; Using MROM in Bank 1 = 80 char mode.
            LD      (DSPCTL), A
            LD      A, 1
            LD      (SCRNMODE), A
            LD      A, 0FFH
            LD      (SPAGE), A                                           ; MZ80K Scrolling in 80 column mode for time being.
            ;
SIGNON:     LD      A,0C4h                                               ; Move cursor left to overwrite part of SA-1510 monitor banner.
            LD      E,004h                                               ; 2 times.
SIGNON1:    CALL    DPCT
            DEC     E
            JR      NZ,SIGNON1
            LD      DE,MSGSON                                            ; Sign on message,
            LD      HL,PRINTMSG
            CALL    BKSW0to6

            LD      HL, SDINIT                                           ; SD Card Initialisation
            CALL    BKSW0to2                                             ; Call the initialisation routine.

            ; Command processor, table based.
            ; A line is inpt then a comparison made with entries in the table. If a match is found then the bank and function
            ; address are extracted and a call to the function @ given bank made. The commands can be of variable length
            ; but important to not that longer commands using the same letters as shorter commands must appear first in the table.
            ;
ST1X:       CALL    NL                                                   ; Command line monitor extension.
            LD      A,'*'
            CALL    PRNT
            LD      DE,BUFER
            CALL    GETL
            ;
CMDCMP:     LD      HL,CMDTABLE
CMDCMP0:    LD      DE,BUFER+1                                           ; First command byte after the * prompt.
            LD      A,(HL)
            CP      000H
            JR      Z,ST1X                                               ; Skip processing on lines where just CR pressed.
            BIT     7,A                                                  ; Bit 7 set on command properties indicates table end, exit if needed.
            JR      NZ,CMDNOCMP
            LD      C,A                                                  ; Command properties into C
            SET     6,C                                                  ; Assume command match.
            AND     007H                                                 ; Mask out bytes in command mask.
            LD      B,A                                                  ; Number of bytes in command.
            INC     HL
CMDCMP1:    LD      A,(DE)                                               ; Compare all bytes and reset match bit if we find a difference.
            CP      (HL)
            JR      Z, CMDCMP2
            RES     6,C                                                  ; No command match.
CMDCMP2:    INC     DE
            INC     HL
            DJNZ    CMDCMP1
            BIT     6,C                                                  ; Bit 7 is still set then we have a command match.
            JR      NZ,CMDCMP3
            INC     HL
            INC     HL                                                   ; Skip over function address
            JR      CMDCMP0                                              ; Try match next command.
CMDCMP3:    LD      A,(HL)                                               ; Command function address into HL
            INC     HL
            LD      H,(HL)
            LD      L,A
            PUSH    HL
            LD      (TMPADR),DE                                          ; Store the key buffer location where arguments start.
            LD      A,C
            SRL     A
            SRL     A
            SRL     A
            AND     007H                                                 ; Mask out just the bank number of the command.  
            CP      000H
            JR      Z,CMDCMP6                                            ; No point using the bank switching logic for the current bank 0.
            LD      B,A
            LD      HL,BKSW0to0                                          ; Base address of bank switching functions.
            LD      DE,BKSW0to1 - BKSW0to0                               ; DE is the number of bytes between bank switch calls.
            OR      A
            JR      Z,CMDCMP5
CMDCMP4:    ADD     HL,DE
            DJNZ    CMDCMP4
CMDCMP5:    EX      DE,HL                                                ; Address of bank switch function into DE.
            POP     HL                                                   ; Get address of command into HL.
            LD      BC,CMDCMPEND
            PUSH    BC                                                   ; Address to return to after command is executed.
            PUSH    DE                                                   ; Now jump to DE which will switch to the correct bank and execute function at HL.
            LD      DE,(TMPADR)
            RET
CMDCMP6:    LD      DE,CMDCMPEND                                         ; Put return address onto stack.
            PUSH    DE
            LD      DE,(TMPADR)                                          ; For the current bank, just jump to the function.
            JP      (HL)

CMDNOCMP:   LD      DE,MSGBADCMD
            LD      HL,PRINTMSG
            CALL    BKSW0to6
CMDCMPEND:  JP      ST1X

            ; Monitor command table. This table contains the list of recognised commands along with the 
            ; handler function and bank in which it is located.
            ;
            ;         7       6     5:3    2:0
            ;         END   MATCH  BANK   SIZE 
CMDTABLE:   DB      000H | 000H | 000H | 001H                            ; Bit 2:0 = Command Size, 5:3 = Bank, 6 = Command match, 7 = Command table end.
            DB      '4'                                                  ; 40 Char screen mode.
            DW      SETMODE40
            DB      000H | 000H | 000H | 001H
            DB      '8'                                                  ; 80 Char screen mode.
            DW      SETMODE80
            DB      000H | 000H | 000H | 001H
            DB      'B'                                                  ; Bell.
            DW      SGX
            DB      000H | 000H | 018H | 001H
            DB      'C'                                                  ; Clear Memory.
            DW      INITMEMX
            DB      000H | 000H | 018H | 001H
            DB      'D'                                                  ; Dump Memory.
            DW      DUMPX
            DB      000H | 000H | 010H | 002H
            DB      "EC"                                                 ; Erase file.
            DW      ERASESD
            DB      000H | 000H | 008H | 001H
            DB      'F'                                                  ; RFS Floppy boot code.
            DW      FLOPPY
            DB      000H | 000H | 008H | 001H
            DB      0AAH                                                 ; Original Floppy boot code.
            DW      FDCK
            DB      000H | 000H | 030H | 001H
            DB      'H'                                                  ; Help screen.
            DW      HELP
            DB      000H | 000H | 000H | 002H
            DB      "IR"                                                 ; List ROM directory.
            DW      DIRROM
            DB      000H | 000H | 010H | 002H
            DB      "IC"                                                 ; List SD Card directory.
            DW      DIRSDCARD
            DB      000H | 000H | 000H | 001H
            DB      'J'                                                  ; Jump to address.
            DW      GOTOX
            DB      000H | 000H | 020H | 004H
            DB      "LTNX"                                               ; Load from CMT without auto execution.
            DW      LOADTAPENX
            DB      000H | 000H | 020H | 002H
            DB      "LT"                                                 ; Load from CMT
            DW      LOADTAPE
            DB      000H | 000H | 000H | 004H
            DB      "LRNX"                                               ; Load from ROM without auto execution.
            DW      LOADROMNX
            DB      000H | 000H | 000H | 002H
            DB      "LR"                                                 ; Load from ROM
            DW      LOADROM
            DB      000H | 000H | 010H | 004H
            DB      "LCNX"                                               ; Load from SDCARD without auto execution.
            DW      LOADSDCARDX
            DB      000H | 000H | 010H | 002H
            DB      "LC"                                                 ; Load from SD CARD
            DW      LOADSDCARD
            DB      000H | 000H | 020H | 001H
            DB      "L"                                                  ; Original Load from CMT
            DW      LOADTAPE
            DB      000H | 000H | 018H | 001H
            DB      'M'                                                  ; Edit Memory.
            DW      MCORX
            DB      000H | 000H | 018H | 001H
            DB      'P'                                                  ; Printer test.
            DW      PTESTX
            DB      000H | 000H | 038H | 001H
            DB      'R'                                                  ; Memory test.
            DW      MEMTEST
            DB      000H | 000H | 018H | 004H
            DB      "SD2T"                                               ; Copy SD Card to Tape.
            DW      SD2TAPE
            DB      000H | 000H | 010H | 002H
            DB      "SC"                                                 ; Save to SD CARD
            DW      SAVESDCARD
            DB      000H | 000H | 020H | 002H
            DB      "ST"                                                 ; Save to CMT
            DW      SAVEX
            DB      000H | 000H | 020H | 001H
            DB      'S'                                                  ; Save to CMT
            DW      SAVEX
            DB      000H | 000H | 018H | 004H
            DB      "T2SD"                                               ; Copy Tape to SD Card.
            DW      TAPE2SD
            DB      000H | 000H | 038H | 001H
            DB      'T'                                                  ; Timer test.
            DW      TIMERTST
            DB      000H | 000H | 000H | 001H
            DB      'V'                                                  ; Verify CMT Save.
            DW      VRFYX
            DB      000H | 000H | 000H | 001H
            DB      'X'                                                  ; Exchange to hi load rom so DRAM = 0000:0CFFF
            DW      HIROM
            DB      080H | 000H | 000H | 001H

            ;-------------------------------------------------------------------------------
            ; END OF RFS INITIALISATION AND COMMAND ENTRY PROCESSOR FUNCTIONALITY.
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF RFS COMMAND FUNCTIONS.
            ;-------------------------------------------------------------------------------

            ; Method to branch execution to a user given address.
            ;
GOTOX:      CALL    HEXIYX
            JP      (HL)

HEXIYX:     EX      (SP),IY
            POP     AF
            CALL    HLHEX
            JR      C,HEXIYX2
            JP      (IY)
HEXIYX2:    POP     AF                                                   ; Waste the intermediate caller address
            RET    


            ;====================================
            ;
            ; Screen Width Commands
            ;
            ;====================================

HIROM:      LD      A, (MEMSW)                                           ; Swap ROM into high range slot.
            LD      A, ROMBANK2
            LD      (ROMBK1),A                                           ; Save bank being enabled.
            LD      (RFSBK1),A                                           ; Switch to the hiload rom in bank 2.
            JP      0C000H

SETMODE40:  LD      A, ROMBANK0                                          ; Switch to 40Char monitor.
            LD      (ROMBK1),A
            LD      (RFSBK1),A
            LD      A, 0
            LD      (DSPCTL), A
            JP      MONIT
 
SETMODE80:  LD      A, ROMBANK1                                          ; Switch to 80char monitor.
            LD      (ROMBK1),A
            LD      (RFSBK1),A
            LD      A, 128
            LD      (DSPCTL), A
            JP      MONIT

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
            LD      B,FNSIZE                                             ; Maximum of 17 characters, including terminator in filename.
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
            CP      FNSIZE 
            JR      Z,ISMZFNOT                                           ; If the filename has no length it cant be valid, so loop.
ISMZFYES:   CP      A                                                    ; Set zero flag to indicate match.

ISMZFNOT:   POP     HL
            POP     DE
            POP     BC
            RET

            
PRTDBG:     IF ENADEBUG = 1
            PUSH    HL
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
            ENDIF

_PRTMZF:    PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            LD      A,(ROMBK1)                                           ; Ensure main MROM is switched in.
            LD      (RFSBK1), A
            ;
            LD      A,(SCRNMODE)
            CP      0
            LD      H,47
            JR      Z,PRTMZF0
            LD      H,93
PRTMZF0:    LD      A,(TMPLINECNT)                                       ; Pause if we fill the screen.
            LD      E,A
            INC     E
            CP      H
            JR      NZ,PRTNOPAUSE
            LD      E, 0
PRTPAUSE:   CALL    GETKY
            CP      ' '
            JR      Z,PRTNOPAUSE
            CP      'X'                                                  ; Exit from listing.
            LD      A,001H
            JR      Z,PRTMZF4
            JR      PRTPAUSE
PRTNOPAUSE: LD      A,E
            LD      (TMPLINECNT),A
            ;
            LD      A, D                                                 ; Print out file number and increment.
            CALL    PRTHX
            LD      A, '.'
            CALL    PRNT
            LD      DE,NAME                                              ; Print out filename.
            LD      B,FNSIZE                                             ; Maximum size of filename.
_PRTMSG:    LD      A,(DE)
            INC     DE
            CP      000H
            JR      Z,_PRTMSGE
            CP      00DH
            JR      Z,_PRTMSGE
            CALL    PRNT
            DJNZ    _PRTMSG
            ;
_PRTMSGE:   LD      HL, (DSPXY)
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
PRTMZF3:    XOR     A
PRTMZF4:    OR      A
            PUSH    AF
            LD      A, (WRKROMBK1)
            LD      (RFSBK1), A
            POP     AF
            POP     HL
            POP     DE
            POP     BC
            RET


DIRROM:     DI                                                           ; Disable interrupts as we are switching out the main rom.
            ;
            LD      A,1                                                  ; Account for the title.
            LD      (TMPLINECNT),A
            ;
            LD      DE,MSGRDIRLST                                        ; Print out header.
            LD      HL,PRINTMSG
            CALL    BKSW0to6
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
            JR      NZ,DIRNXTPGX
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
DIRNXTPGX:  LD      A,(ROMBK1)
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
            LD      BC,FNSIZE
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
            ;
            LD      A,(ROMBK1)
            LD      (RFSBK1), A
            LD      DE,MSGLOAD+1                                         ; Skip initial CR.
            LD      BC,NAME
            LD      HL,PRINTMSG
            CALL    BKSW0to6
            LD      A,(WRKROMBK1)
            LD      (RFSBK1), A

            ;
            CALL    MROMLOAD                                             ; Load the file from User ROM via MROM utility.
            JP      Z, LROMLOAD5

LROMNTFND:  POP     HL                                                   ; Dont need execute flag anymore so waste it.
            LD      A,(ROMBK1)
            LD      (RFSBK1),A
            LD      HL,PRINTMSG
            LD      DE,MSGNOTFND                                         ; Not found
            CALL    BKSW0to6
LOADROMEND: EI
            RET

            ;
            ; Load program from RFS Bank 1 (MROM Bank)
            ;
LROMLOAD:   PUSH    BC
            ;
            PUSH    BC
            LD      DE,MSGLOAD+1
            LD      BC,NAME
            LD      HL,PRINTMSG
            CALL    BKSW0to6
            POP     BC
            ;
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

            ;-------------------------------------------------------------------------------
            ; END OF RFS COMMAND FUNCTIONS.
            ;-------------------------------------------------------------------------------


            ;--------------------------------------
            ;
            ; Message table - Refer to bank 6 for
            ;                 all messages.
            ;
            ;--------------------------------------
           
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
