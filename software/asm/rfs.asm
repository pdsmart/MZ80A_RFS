;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs.asm
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
;                   July 2020 - Updated for the v2.1 hardware. RFS can run with a tranZPUter board with
;                               or without the K64 I/O processor. RFS wont use the K64 processor all
;                               operations are done by the Z80 under RFS.
;-                  April 2021- Updates for the v2.1 RFS board.
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
            INCLUDE "rfs_definitions.asm"


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
            LD      B,16                                                 ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
ROMFS_0:    LD      A,(BNKCTRLRST)
            DJNZ    ROMFS_0                                              ; Apply the default number of coded latch reads to enable the bank control registers.
            LD      A,BNKCTRLDEF                                         ; Set coded latch, SDCS high, BBMOSI to high and BBCLK to high which enables SDCLK.
            LD      (BNKCTRL),A
            LD      (ROMCTL),A                                           ; Save to memory the value in the bank control register - this register is used for SPI etc so need to remember its setting.
            XOR     A                                                    ; We shouldnt arrive here after a reset, if we do, select UROM bank 0
            LD      (BNKSELMROM),A
            LD      (BNKSELUSER),A                                       ; and start up - ie. SA1510 Monitor - this occurs as User Bank 0 is enabled and the jmp to 0 is coded in it.
            JP      ROMFS_1                                              ; Skip the reset vector.
            JP      00000H                                               ; Other banks will switch at this point thus forcing a full reset.

            ALIGN_NOPS UROMBSTBL

            ;------------------------------------------------------------------------------------------
            ; Bank switching code, allows a call to code in another bank.
            ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
            ;------------------------------------------------------------------------------------------
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
            LD      (BNKSELUSER), A                                      ; Repeat the bank switch B times to enable the bank control register and set its value.
            JP      (HL)                                                 ; Jump to required function.
BKSWRET0:   POP     AF                                                   ; Get bank which called us.
            LD      (BNKSELUSER), A                                      ; Return to that bank.
            POP     AF
            RET                                                          ; Return to caller.

            ALIGN   RFSJMPTABLE
            ORG     RFSJMPTABLE

            ;------------------------------------------------------------------------------------------
            ; Enhanced function Jump table.
            ; This table is generally used by the monitor ROM to call functions within the User ROM.
            ;------------------------------------------------------------------------------------------
PRTMZF:     JP       _PRTMZF                                             ; UROMADDR+80H - Print out an MZF header stored in the IBUFE location.
PRTDBG:     JP       _PRTDBG                                             ; UROMADDR+83H - Print out debug information, if enabled.
CMT_RDINF:  JP       _CMT_RDINF                                          ; UROMADDR+86H - Tape/SD intercept handler - Read Header
CMT_RDDATA: JP       _CMT_RDDATA                                         ; UROMADDR+89H - Tape/SD intercept handler - Read Data
CMT_WRINF:  JP       _CMT_WRINF                                          ; UROMADDR+80H - Tape/SD intercept handler - Write Header
CMT_WRDATA: JP       _CMT_WRDATA                                         ; UROMADDR+8FH - Tape/SD intercept handler - Write Data
CMT_VERIFY: JP       _CMT_VERIFY                                         ; UROMADDR+92H - Tape/SD intercept handler - Verify Data
CMT_DIR:    JP       _CMT_DIR                                            ; UROMADDR+95H - SD card directory listing command.
CNV_ATOS:   JP       _CNV_ATOS                                           ; UROMADDR+98H - Convert string from Ascii to Sharp Ascii
            ;-----------------------------------------


            ;-----------------------------------------
            ; Initialisation and startup.
            ;-----------------------------------------
            ;
            ; NB. Bank control registers are left selected. Any software needing access to the top 8 bytes of a
            ;     ROM/RAM page need to disable them, perform their actions then re-emable.
            ;
            JP      ROMFS_1                                              ; Skip the reset vector.
            ;
ROMFS_1:    
            LD      A, (ROMBK1)                                          ; Ensure all banks are at default 
            CP      8                                                    ; If the ROMBK1 value is 255, an illegal value, then the machine has just started so initialise memory.
            JR      C, ROMFS_3
            XOR     A                                                    ; Clear the lower stack space as we use it for variables.
            LD      B, 7*8
            LD      HL, 01000H
ROMFS_2:    LD      (HL),A
            INC     HL
            DJNZ    ROMFS_2              
            LD      A,BNKCTRLDEF                                         ; Set coded latch, SDCS high, BBMOSI to high and BBCLK to high which enables SDCLK.
            LD      (ROMCTL),A                                           ; Save to memory the value in the bank control register - this register is used for SPI etc so need to remember its setting.
            LD      A,(ROMBK1)
ROMFS_3:    LD      (BNKSELMROM),A                                       ; start up.
            LD      A, (ROMBK2)
            LD      (BNKSELUSER),A

            ;-------------------------------------------------------------------------------
            ; START OF RFS INITIALISATION AND COMMAND ENTRY PROCESSOR FUNCTIONALITY.
            ;-------------------------------------------------------------------------------
            ;
            ; Replacement command processor in place of the SA1510 command processor.
            ;
MONITOR:    IF FUSIONX_ENA = 0
              IN      A,(CPLDINFO)                                         ; See if a tranZPUter board is present.
              AND     0E7H                                                 ; Mask out the CPLD Version and host HW.
              LD      C,A
              CP      020H                                                 ; Upper bits specify the version, should be at least 1.
              JR      C,CHKTZ1
              AND     007H                                                 ; Get Hardware, should be an MZ-80A for RFS.
              CP      MODE_MZ80A
              LD      A,C
              JR      Z,CHKTZ1
              XOR     A
CHKTZ1:       AND     0E0H
            ELSE
              XOR     A
            ENDIF
            LD      (TZPU), A                                            ; Flag = 0 if no tranZPUter present otherwise contains version (1 - 15).
            LD      HL,DSPCTL                                            ; Setup address of display control register latch.
            ;
            XOR     A                                                    ; Set the initial SDCFS active drive number.
            LD      (SDDRIVENO),A
            ;
            LD      A, (ROMBK1)
            CP      1
            JR      Z, SET80CHAR
            CP      0
            JR      NZ, SIGNON
            ;
SET40CHAR:  LD      A, 0                                                 ; Using MROM in Bank 0 = 40 char mode.
            LD      E,(HL)                                               ; Dummy operation to enable latch write via multivibrator.
            LD      (HL), A
            LD      (SCRNMODE), A
            LD      (SPAGE), A                                           ; Allow MZ80A scrolling
            JR      SIGNON
SET80CHAR:  LD      A, 128                                               ; Using MROM in Bank 1 = 80 char mode.
            LD      E,(HL)                                               ; Dummy operation to enable latch write via multivibrator.
            LD      (HL), A
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
            ;
            LD      A,(TZPU)
            OR      A
            JR      Z,SIGNON2
            LD      DE,MSGSONTZ
            JR      SIGNON3
            ;
SIGNON2:    LD      DE,MSGSON                                            ; Sign on message,
SIGNON3:    LD      HL,PRINTMSG
            CALL    BKSW0to6
        ; JR ST1X

            ; Initialise SD card, report any errors.
            LD      HL, SDINIT                                           ; SD Card Initialisation
            CALL    BKSW0to2                                             ; Call the initialisation routine.
            LD      A,L
            OR      A                                                    ; 0 = No error.
            JR      Z,ST1X

            ; Place error code in C to print as a number and report with the error message.
            ADD     A,'0'
            LD      C,A
            LD      DE,MSGSDINITER
            LD      HL,PRINTMSG
            CALL    BKSW0to6

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
            LD      A,(BUFER+1)                                          ; Drive change number 0..9. Each number represents an RFS SDCFS Drive number.
            CP      '0'
            JR      C,CMDCMP
            CP      ':'
            JR      NC,CMDCMP
            SUB     '0'
            LD      D,A
            LD      A,(BUFER+2)
            CP      CR                                                   ; If a CR is present then we match, a drive selection number was entered.
            LD      A,D
            JR      NZ,CMDCMP
            ; Simple command, just update the active drive number.
            LD      (SDDRIVENO),A
            JR      ST1X
            ;
CMDCMP:     XOR     A                                                    ; Clear the result variable used by interbank calls. Some functions set this variable and we act on it.
            LD      (RESULT),A
            LD      HL,CMDTABLE
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
CMDCMPEND:  LD      A,(RESULT)
            CP      0FEH                                                 ; A Result code of 0FEH means execute loaded code, address is in the CMT Header EXADR location.
            JP      NZ,ST1X
            LD      HL,(EXADR)
            JP      (HL)

            ; Monitor command table. This table contains the list of recognised commands along with the 
            ; handler function and bank in which it is located.
            ;
            ;         7       6     5:3    2:0
            ;         END   MATCH  BANK   SIZE 
CMDTABLE:   DB      000H | 000H | 000H | 002H                            ; Bit 2:0 = Command Size, 5:3 = Bank, 6 = Command match, 7 = Command table end.
            DB      "40"                                                 ; 40 Char screen mode.
            DW      SETMODE40
            DB      000H | 000H | 000H | 002H
            DB      "80"                                                 ; 80 Char screen mode.
            DW      SETMODE80
           ;DB      000H | 000H | 000H | 004H
           ;DB      "7008"                                               ; Switch to 80 column MZ700 mode.
           ;DW      SETMODE7008
           ;DB      000H | 000H | 000H | 003H
           ;DB      "700"                                                ; Switch to 40 column MZ700 mode.
           ;DW      SETMODE700
            DB      000H | 000H | 000H | 005H
            DB      "BASIC"                                              ; Load and run BASIC SA-5510.
            DW      LOADBASIC
            DB      000H | 000H | 020H | 001H
            DB      'B'                                                  ; Bell.
            DW      SGX
            DB      000H | 000H | 000H | 003H
            DB      "CPM"                                                ; Load and run CPM.
            DW      LOADCPM
            DB      000H | 000H | 018H | 002H
            DB      "CP"                                                 ; Copy Memory.
            DW      MCOPY
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
            DB      000H | 000H | 000H | 004H
            DB      "TEST"                                               ; A test function used in debugging.
            DW      LOCALTEST
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

            ; A method used when testing hardware, scope and code will change but one of its purposes is to generate a scope signal pattern.
            ;
LOCALTEST:  LD      A,64
            LD      (0EFFBH),A
            JP      LOCALTEST


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
            LD      (BNKSELMROM),A                                       ; Switch to the hiload rom in bank 2.
            JP      0C000H

SETMODE40:  LD      A, ROMBANK0                                          ; Switch to 40Char monitor.
            LD      (ROMBK1),A
            LD      (BNKSELMROM),A
            LD      HL,DSPCTL                                            ; Setup address of display control register latch.
            LD      A, 0
            LD      E,(HL)                                               ; Dummy operation to enable latch write via multivibrator.
            LD      (HL), A
            JP      MONIT
 
SETMODE80:  LD      A, ROMBANK1                                          ; Switch to 80char monitor.
            LD      (ROMBK1),A
            LD      (BNKSELMROM),A
            LD      HL,DSPCTL                                            ; Setup address of display control register latch.
            LD      A, 128
            LD      E,(HL)                                               ; Dummy operation to enable latch write via multivibrator.
            LD      (HL), A
            JP      MONIT

NOTZPU:     LD      DE,MSGNOTZINST                                        ; No tranZPUter installed.
            LD      HL,PRINTMSG
            CALL    BKSW0to6
            RET

            ; The RFS depends on variables stored in unused parts of the Monitor scratch area.
            ; When switching into a compatibility mode the memory is switched and these variables go
            ; out of scope. This routine clears the memory and sets any crucial variables after 
            ; memory switch so that a restart functions as expected.
            ;
SETMODECLR: POP     HL                                                   ; Get return address, will go OOS after memory mode change.
            LD      A,TZMM_COMPAT
            OUT     (MMCFG),A                                            ; Set memory mode to compatibility.
            XOR     A                                                    ; Clear out the RFS variable area in the tranZPUter memory.
            LD      DE, 01000H
            LD      B, 030H
SETCLR_1:   LD      (DE),A
            INC     DE 
            DJNZ    SETCLR_1 
            JP      (HL)                                                 ; Return to caller.
            
            ; Command to switch to the MZ700 compatibility mode with 80 column display.
            ;
;SETMODE7008:LD      A,(TZPU)                                             ; Check there is a tranZPUter card installed.
;            OR      A
;            JR      Z,NOTZPU
;            LD      HL,DSPCTL                                            ; Setup address of display control register latch.
;            LD      A, 128                                               ; Setup for 80char display.
;            LD      E,(HL)                                               ; Dummy operation to enable latch write via multivibrator.
;            LD      (HL), A
;            CALL    SETMODECLR                                           ; Set memory mode and clear variable area.
;            LD      A,ROMBANK5                                           ; Select the 80 column version of the 1Z-013A ROM.
;SETMODE_2:  LD      (ROMBK1),A
;            LD      (BNKSELMROM),A
;            LD      A,MODE_MZ700                                         ; Set the CPLD compatibility mode.
;SETMODE_3:  OUT     (CPLDCFG),A
;            JP      MONIT                                                ; Cold start the monitor.

            ; Command to switch to the MZ700 compatibility mode with original 40 column display.
            ;
;SETMODE700: LD      A,(TZPU)                                             ; Check there is a tranZPUter card installed.
;            OR      A
;            JR      Z,NOTZPU
;            LD      HL,DSPCTL                                            ; Setup address of display control register latch.
;            LD      A, 0                                                 ; Setup for 40char display.
;            LD      E,(HL)                                               ; Dummy operation to enable latch write via multivibrator.
;            LD      (HL), A
;            CALL    SETMODECLR                                           ; Set memory mode and clear variable area.
;            LD      A,ROMBANK4                                           ; Select the 40 column version of the 1Z-013A ROM.
;            JR      SETMODE_2

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
            CP      OBJCD                                                ; Only interested in machine code images.
            JR      NZ, ISMZFNOT
            ;
            INC     HL
            LD      DE,NAME                                              ; Checks to confirm this is an MZF header.
            LD      B,FNSIZE                                             ; Maximum of 17 characters, including terminator in filename.
ISMZFNXT:   LD      A,(HL)
            LD      (DE),A
            CP      00DH                                                 ; If we find a terminator then this indicates potentially a valid name.
            JR      Z, ISMZFNXT3
            CP      000H                                                 ; Same applies for NULL terminator.
            JR      Z, ISMZFNXT3
            CP      020H                                                 ; >= Space
            JR      C, ISMZFNOT
            CP      05DH                                                 ; =< ]
            JR      C, ISMZFNXT3
ISMZFNXT2:  CP      091H
            JR      C, ISMZFNOT                                          ; DEL or > 0x7F, cant be a valid filename so this is not an MZF header.
ISMZFNXT3:  INC     DE
            INC     HL
            DJNZ    ISMZFNXT
ISMZFYES:   CP      A                                                    ; Set zero flag to indicate match.

ISMZFNOT:   POP     HL
            POP     DE
            POP     BC
            RET

            
_PRTDBG:    IF ENADEBUG = 1
            PUSH    HL
            PUSH    DE
            PUSH    BC
            PUSH    AF
            LD      A,(ROMBK1)
            LD      (BNKSELMROM),A                                       ; Set the MROM bank back to original.
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
      ;     CALL    NL
      ; CALL GETKY
            LD      A,(WRKROMBK1)
            LD      (BNKSELMROM),A                                       ; Set the MROM bank back to scanned bank.
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
            LD      (BNKSELMROM),A
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
            LD      A, '.'                                               ; File type is MACHINE CODE program.
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
            LD      (BNKSELMROM),A
            POP     AF
            POP     HL
            POP     DE
            POP     BC
            RET


            ; Method to list the directory of the ROM devices.
            ;
DIRROM:    ;DI                                                           ; Disable interrupts as we are switching out the main rom.
            ;
            LD      A,1                                                  ; Account for the title.
            LD      (TMPLINECNT),A
            ;
            LD      DE,MSGRDIRLST                                        ; Print out header.
            LD      HL,PRINTMSG
            CALL    BKSW0to6

            ; D = File sequence number.
            LD      D,0                                                  ; File numbering start.

            ;
            ; Get directory of User ROM.
            ;
            LD      A,ROMBANK3
            LD      (WRKROMBK1),A
            LD      (BNKSELMROM),A
            CALL    DIRMROM
            ;
            ; Scan MROM Bank
            ; B = Bank Page
            ; C = Block in page
            ;
            LD      B,MROMPAGES                                          ; First 8 pages are reserved in MROM bank.
            LD      C,0                                                  ; Block in page.
            ;
DIRNXTPG:   LD      A,B
            LD      (WRKROMBK1), A
            LD      (BNKSELMROM),A                                       ; Select bank.

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

DIRNXTPGX:  LD      A,(ROMBK1)
            LD      (BNKSELMROM),A                                       ; Set the MROM bank back to original.
           ;EI                                                           ; No need to block interrupts now as MROM bank restored.
            RET                                                          ; End of scan, return to monitor


            ; In:
            ;      HL = filename
            ;      D = File sequence number.
            ; Out:
            ;      B = Bank Page file found
            ;      C = Block where found.
            ;      D = File sequence number.
            ;      Z set if found.
FINDMZF:    PUSH    DE
            LD      (TMPADR), HL                                         ; Save name of program to load.  
            EX      DE, HL                                               ; String needed in DE for conversion.
            LD      HL,0FFFFh                                            ; Tag the filenumber as invalid.
            LD      (TMPCNT), HL 
            CALL    ConvertStringToNumber                                ; See if a file number was given instead of a filename.
            JR      NZ, FINDMZF0                                         ; 
            LD      (TMPCNT), HL                                         ; Store filenumber making load by filenumber valid.
            ;
            ; Scan MROM Bank
            ; B = Bank Page
            ; C = Block in page
            ;
FINDMZF0:   POP     DE                                                   ; Get file sequence number in D.
            LD      B,MROMPAGES                                          ; First 4 pages are reserved in User ROM bank.
            LD      C,0                                                  ; Block in page.
FINDMZF1:   LD      A,B
            LD      (WRKROMBK1), A
            LD      (BNKSELMROM),A                                       ; Select bank.
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
            LD      (BNKSELMROM),A                                       ; Set the MROM bank back to original.
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
            LD      (BNKSELMROM),A                                       ; Select correct bank for comparison.
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

FINDMZFYES:                                                              ; Flag set by previous test.
FINDMZFNO:  PUSH    AF
            LD      A,(ROMBK1)
            LD      (BNKSELMROM),A                                       ; Set the MROM bank back to original.
            POP     AF
            RET


            ; Load Program from ROM
            ; IN    DE     Name of program to load.
            ; OUT   zero   Set if string1 = string2, reset if string1 != string2.
            ;       carry  Set if string1 > string2, reset if string1 <= string2.
LOADROMNX:  LD      L,0FFH
            JR      LOADROM1
LOADROM:    LD      L,000H
LOADROM1:  ;DI
            PUSH    HL                                                   ; Preserve execute flag.
            EX      DE,HL                                                ; User ROM expects HL to have the filename pointer.

            PUSH    HL                                                   ; Save pointer to filename for FINDMZF in Monitor ROM.

            ; D = File sequence number.
            LD      D,0                                                  ; File numbering start.
            ;
            LD      A,ROMBANK3                                           ; Activate the RFS Utilities MROM bank.
            LD      (WRKROMBK1), A
            LD      (BNKSELMROM),A
            CALL    MFINDMZF                                             ; Try and find the file in User ROM via MROM utility.
            POP     HL
            JR      Z,MROMLOAD0
            ;
            CALL    FINDMZF                                              ; Find the bank and block where the file resides. HL = filename.
            JR      Z, LROMLOAD
            ;
            JR      LROMNTFND                                            ; Requested file not found.
            ;
MROMLOAD0:  PUSH    BC                                                   ; Preserve bank and block where MZF file found.
            PUSH    AF
            LD      A,(ROMBK1)                                           ; Page in monitor so we can print a message.
            LD      (BNKSELMROM),A
            LD      DE,MSGLOAD+1                                         ; Skip initial CR.
            LD      BC,NAME
            LD      HL,PRINTMSG
            CALL    BKSW0to6
            LD      A,(WRKROMBK1)                                        ; Revert to MROM bank to load the application.
            LD      (BNKSELMROM),A
            POP     AF
            POP     BC
            ;
            CALL    MROMLOAD                                             ; Load the file from User ROM via MROM utility.
            JP      Z, LROMLOAD5

LROMNTFND:  POP     HL                                                   ; Dont need execute flag anymore so waste it.
            LD      A,(ROMBK1)
            LD      (BNKSELMROM),A
            LD      HL,PRINTMSG
            LD      DE,MSGNOTFND                                         ; Not found
            CALL    BKSW0to6
LOADROMEND:;EI
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
            LD      (BNKSELMROM),A
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
            LD      (BNKSELMROM),A

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
            LD      (BNKSELMROM),A                                       ; Set the MROM bank back to original.
            LD      A,L                                                  ; Autoexecute turned off?
            CP      0FFh
            JP      Z,LROMLOAD9                                          ; Go back to monitor if it has been, else execute.
            LD      HL,(EXADR)
           ;EI                                                           ; No need to block interrupts now as MROM bank restored.
            JP      (HL)                                                 ; Execution address.
LROMLOAD9:  RET


            ; Quick method to load CPM. So long as the filename doesnt change this method will load and boot CPM.
LOADCPM:    LD      DE,CPMFN48                                           ; Load up the 48K version of CPM
LOADPRGNM:  PUSH    HL
            LD      HL,BUFER
LOADPRGNM1: LD      A,(DE)
            LD      (HL),A
            CP      CR
            JR      Z,LOADPRGNM2
            INC     DE
            INC     HL
            JR      LOADPRGNM1
LOADPRGNM2: POP     HL
            LD      DE,BUFER
            JP      LOADROM

            ; Quick method to load the basic interpreter. So long as the filename doesnt change this method will load and boot Basic.
LOADBASIC:  LD      DE,BASICFILENM
            JR      LOADPRGNM

LOADPROG:   LD      HL,LOADSDCARD
            CALL    BKSW0to2
            RET

            ;-------------------------------------------------------------------------------
            ; END OF RFS COMMAND FUNCTIONS.
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; DEVICE DRIVERS - Intercept handlers to provide enhanced services to 
            ;                  existing MA-80A BIOS API functions.
            ;-------------------------------------------------------------------------------

            ; Method to set the RFS Drive number from the Load/Save string provided.
SETDRIVE:   LD      A,(DE)                                               ; If a drive is given it will be in format <driveno>:<filename>
            OR      A                                                    ; Exit if null or CR found, no drive specifier present.
            JR      Z,SETDRV3
            CP      00DH
            JR      Z,SETDRV3
            CP      '"'                                                  ; String quotes, skip over.
            JR      NZ,SETDRV1
            INC     DE
            JR      SETDRIVE
            ;
SETDRV1:    LD      A,(DE)                                               ; Check for <digit>:, if no colon exit.
            LD      C,A
            INC     DE
            LD      A,(DE)
            DEC     DE
            CP      ':'
            JR      NZ, SETDRV3
            ;
            LD      A,C
            CP      'C'                                                  ; CMT unit specified by C:
            JR      Z,SETDRV2
            SUB     '0'                                                  ; Check the drive number, should be in range 0..9
            JP      C,SD_INVDRV
            CP      10
            JP      NC,SD_INVDRV
SETDRV2:    INC     DE
            LD      (SDDRIVENO),A                                        ; Store drive number for later use.
            XOR     A
            LD      (CMTFILENO),A                                        ; Setup the starting file number for sequential file reads (ie. when no filename given).
            ;
            PUSH    DE                                                   ; Need to remove the drive qualifier once processed.
            PUSH    DE
            INC     DE
            INC     DE                                                   ; Move onto filename.
            EX      DE,HL
            POP     DE
            LD      BC,SDDIR_FNSZ
            LDIR
            POP     DE
            ;
SETDRV3:    XOR     A
            RET

            ; Method to check if the active drive is the CMT.
CHECKCMT:   LD      A,(SDDRIVENO)
            CP      'C'
            RET

            ; Convert the lower 4 bits of A into a Hex character.
TOHEXDIGIT: AND     00FH                                                 ; Simple logic, add 30H to get 0..9, add additional 7 if value >= 10 to get digits A..F.
            CP      00AH
            JR      C,NOADD                 
            ADD     A,007H
NOADD:      ADD     A,030H
            RET    

            ; Convert a number into Hex string and store in buffer pointed to by DE.
            ;
TOHEX:      PUSH    DE
            PUSH    AF                                                   ; Save AF to retrieve lower 4 bits.
            RRCA                                                         ; Shift upper 4 bits to lower to convert to hex.
            RRCA    
            RRCA    
            RRCA    
            CALL    TOHEXDIGIT
            LD      (DE),A                                               ; Store and convert lower 4 bits.
            INC     DE
            POP     AF
            CALL    TOHEXDIGIT
            LD      (DE),A
            INC     DE
            LD      A,CR                                                 ; Terminate with a CR.
            LD      (DE),A
            POP     DE                                                   ; DE back to start of string.
            RET

            ; Handler to intercept the CMT Read Header Information call and insert selectable
            ; SD Card RFS Drive functionality. 
            ; DE contains a pointer to memory containing the file to load. If (DE) = NULL then
            ; load the next sequential file from the SD card directory.
            ; DE = Filename. Can contain a drive specifier in format <driveno>:<filename>
            ;
            ; No registers or flags should be affected as we dont know the caller state.
_CMT_RDINF: CALL    SETDRIVE                                             ; Set drive if specified.
            RET     NZ
            CALL    CHECKCMT                                             ; If drive is set to the CMT Unit exit with Z set so that the original CMT handlers are called.
            JP      Z,?RDI
            LD      A,(DE)                                               ; Check to see if empty string given, if so expand the default Next file number into the buffer.
            CP      CR
            JR      NZ,_CMT_RDINF1
            LD      A,(CMTFILENO)                                        ; Get next sequential number and convert to hex.
            PUSH    AF
            CALL    TOHEX                         
            POP     AF
            INC     A                                                    ; Increment number so next call retrieves the next sequential file.
            LD      (CMTFILENO),A
            ;
_CMT_RDINF1:PUSH    DE
            LD      HL,LOADSDINF                                         ; DE already points to the filename, call LOADSDINF to locate it on the SD card and setup the header.
            CALL    BKSW0to2
            ; Copy the filename into the Buffer provided allowing for file number to name expansion.
            POP     DE
            LD      HL,NAME
            LD      BC,SDDIR_FNSZ
            LDIR
            ;
            LD      A,(RESULT)
            OR      A
            RET     Z                                                    ; 0 = success, return with carry clear.
            SCF                                                          ; > 0 = fail, return with carry set.
            RET

            ; Handler to intercept the CMT Read Data call and insert selectable SD Card RFS
            ; Drive functionality. 
            ;
            ; No registers or flags should be affected as we dont know the caller state.
_CMT_RDDATA:LD      HL,LOADSDDATA
            CALL    BKSW0to2
            LD      A,(RESULT)
            OR      A
            JR      NZ,_CMT_RDERR
            RET
_CMT_RDERR: SCF
            RET

            ; Handler to intercept the CMT Write Header Information call and insert selectable
            ; SD Card RFS Drive functionality. 
            ;
            ; No registers or flags should be affected as we dont know the caller state.
            ;
            ; At the moment, the WRINF call only creates a filename if non specified. The actual write to file occurs in WRDATA. Once I have more understanding of
            ; how the sequential data mode works I can adapt it to be compatible.
_CMT_WRINF: LD      DE,NAME                                              ; Caller has already setup the CMT header so we use this for processing.
            ;
            CALL    SETDRIVE                                             ; Set drive if specified.
            RET     NZ
            CALL    CHECKCMT
            JP      Z,?WRI
            ;
            LD      A,(DE)                                               ; Check to see if empty string given, if so create a default name.
            CP      CR
            JR      NZ,_CMT_WRINF1
            ;
            LD      HL,DEFAULTFN
            LD      BC,DEFAULTFNE - DEFAULTFN
            LDIR
            LD      A,(CMTFILENO)                                        ; Get next sequential number and convert to hex.
            PUSH    AF
            CALL    TOHEX                         
            POP     AF
            INC     A                                                    ; Increment number so next call retrieves the next sequential file.
            LD      (CMTFILENO),A
            ;
_CMT_WRINF1:LD      A,0                                                  ; Always success as nothing is written.
            OR      A
            RET

            ; Handler to intercept the CMT Write Data call and insert selectable SD Card RFS
            ; Drive functionality. 
            ;
            ; No registers or flags should be affected as we dont know the caller state.
_CMT_WRDATA: LD      HL,SAVESDDATA
            CALL    BKSW0to2
            LD      A,(RESULT)
            OR      A
            JR      NZ,_CMT_RDERR
            RET

            ; Handler to intercept the CMT Verify Data call and insert selectable SD Card
            ; RFS Drive functionality. 
            ;
            ; No registers or flags should be affected as we dont know the caller state.
_CMT_VERIFY:CALL    SETDRIVE                                             ; Set drive if specified.
            RET     NZ
            CALL    CHECKCMT
            JR      Z,_VERIFY
            LD      DE,MSGNOVERIFY
            JR      SD_ERRMSG

_VERIFY:    JP      ?VRFY

SD_INVDRV:  LD      DE,MSGINVDRV                                         ; Invalid drive specified.
            JR      SD_ERRMSG
SD_NOTFND:  LD      DE,MSGNOTFND
SD_ERRMSG:  LD      HL,PRINTMSG
            CALL    BKSW0to6                                             ; Print message that file wasnt found.
            LD      A,1
            OR      A
            RET

            ; Method to list the contents of the active RFS drive number.
_CMT_DIR:   CALL    SETDRIVE                                             ; Change to the given drive.
            RET     NZ
            CALL    CHECKCMT                                             ; Cannot DIR tape drive so give error.
            JP      Z,_CMT_NODIR
            LD      HL,DIRSDCARD
            CALL    BKSW0to2                                             ; Call the standard RFS directory command.
            RET
_CMT_NODIR: LD      DE,MSGNOCMTDIR
            JR      SD_ERRMSG

            ; Stub to call the ASCII to Sharp ASCII conversion routine stored in Bank 5.
            ; Inputs: DE = String to convert, NULL or CR terminated.
            ;          B = Maximum number of characters to convert.
            ; All registers except AF preserved.
            ;
_CNV_ATOS:  PUSH    HL
            LD      HL,CNVSTR_AS
            CALL    BKSW0to5
            POP     HL
            RET

            ;-------------------------------------------------------------------------------
            ; END OF DEVICE DRIVERS
            ;-------------------------------------------------------------------------------

            ;--------------------------------------
            ;
            ; Message table - Refer to bank 6 for
            ;                 all messages.
            ;
            ;--------------------------------------

            ; Quick load program names.
CPMFN48:    DB      "CPM223RFS",        00DH
BASICFILENM:DB      "BASIC SA-5510RFS", 00DH            
DEFAULTFN:  DB      "DEFAULT"
DEFAULTFNE: EQU     $
           
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
            INCLUDE "macros.asm"
            INCLUDE "rfs_utilities.asm"
            ;
            ; Ensure we fill the entire 2K by padding with FF's.
            ;
            ALIGN   0EFF8h
            ORG     0EFF8h
            DB      0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh

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
