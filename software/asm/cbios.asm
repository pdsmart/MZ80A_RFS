;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cbios.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM BIOS System.
;-                  This is the CPM CBIOS for the Sharp MZ80A hardware plus RFS/80 char upgrades.
;-                  It makes extensive use of the paged roms to add functionality and conserve
;-                  RAM for the CPM applications.
;-
;- Credits:         Some of the comments and parts of the standard CPM deblocking/blocking algorithm 
;-                  come from the Z80-MBC2 project, (C) SuperFabius.
;- Copyright:       (c) 2018-23 Philip Smart <philip.smart@net2net.org>
;-
;- History:         Jan 2020 - Seperated Bank from RFS for dedicated use with CPM CBIOS.
;-                  May 2020 - Advent of the new RFS PCB v2.0, quite a few changes to accommodate the
;-                             additional and different hardware. The SPI is now onboard the PCB and
;-                             not using the printer interface card.
;-                  Mar 2021 - Updates for the RFS v2.1 board.
;-                  Apr 2021 - Removed ROM and RAM Drive functionality as it provided no performance or
;-                             use benefit over SD which are much larger and RW.
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

            ORG     CBIOSSTART

            ;----------------------------------------------------------------------------------------------------------------------------------------------
            ; CBIOS organisation.
            ;
            ; Source File     Size ROM Type            Address          Location       Description
            ; cbios.asm       4K   MROM (relocated                                     CBIOS providing the CP/M API, initialisation routines, ROM Disk
            ;                      Monitor ROM from                                    controller routines, Interrupt routines.
            ;                      0x0000 - 0x0FFF)    0xC000 - 0xCFFF  MRON Bank 2    
            ; cbios_bank1.asm 2K   Paged ROM           0xE800 - 0xEFFF, UROM Bank 8    Basic Sound and Melody, RTC, Keyboard and helper functionality.
            ; cbios_bank2.asm 2k   Paged ROM           0xE800 - 0xEFFF, UROM Bank 9    Screen I/O and ANSI Terminal Parser.
            ; cbios_bank2.asm 2k   Paged ROM           0xE800 - 0xEFFF, UROM Bank 10   SD Card Controller functionality.
            ; cbios_bank2.asm 2k   Paged ROM           0xE800 - 0xEFFF, UROM Bank 11   Floppy Disk Controller functionality.
            ;----------------------------------------------------------------------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ;                                                                              
            ;  BIOS jump table                                                             
            ;                                                                              
            ;-------------------------------------------------------------------------------
            JP      BOOT_
            JP      WBOOT_
            JP      CONST_
            JP      CONIN_
            JP      CONOUT_
            JP      LIST_
            JP      PUNCH_
            JP      READER_
            JP      HOME_
            JP      SELDSK_
            JP      SETTRK_
            JP      SETSEC_
            JP      SETDMA_
            JP      READ_
            JP      WRITE_
            JP      LISTST_
            JP      SECTRN_
            NOP
            NOP
            RET
            JP      BANKTOBANK_

; Methods to access public functions in paged User Rom. The User Rom bank
; is switched in and a jump made to the public function. The page remains
; selected until the next public access call and the page changed accordingly.

            ; CBIOS Bank 1 - Utilities and Audio.
BANK8:      PUSH    AF
            LD      A,ROMBANK8
            LD      (BNKSELUSER),A
            POP     AF
            RET
            ; CBIOS Bank 2 - Screen / ANSI Terminal
BANK9:      PUSH    AF
            LD      A,ROMBANK9
            LD      (BNKSELUSER),A
            POP     AF
            RET
            ; CBIOS Bank 3 - SD Card.
BANK10:     PUSH    AF
            LD      A,ROMBANK10
            LD      (BNKSELUSER),A
            POP     AF
            RET
            ; CBIOS Bank 4
BANK11:     PUSH    AF
            LD      A,ROMBANK11
            LD      (BNKSELUSER),A
            POP     AF
            RET

            ; Method to allow one bank to call a routine in another bank. It is costly in processing time
            ; and should only be used infrequently.
            ;
            ; Input: A [7:4] = Bank to Call
            ;          [3:0] = Calling Bank.
            ;        HL      = Address to call.
            ;        AF      = Stored on stack to pass to called function.
            ;        All other registers passed to called function.
            ; Stack; +2 = AF
            ; Output: All registers and flags returned to caller.
            ;
BANKTOBANK_:LD      (USRBANKSAV),A                                       ; Save the bank we return to.
            SRL     A                                                    ; Switch to required bank.
            SRL     A
            SRL     A
            SRL     A
            LD      (BNKSELUSER),A
            LD      (HLSAVE),HL                                          ; Save HL (exec address) whilst we get AF from stack.
            POP     HL                                                   ; HL = return address in original bank.
            POP     AF                                                   ; AF to pass to called routine.
            PUSH    HL                                                   ; Restore return address onto stack.
            LD      HL,BKTOBKRET                                         ; Push the address t
            PUSH    HL                                                   ; Called routine must return to this method so we can switch back the banks.
            LD      HL,(HLSAVE)                                          ; Get address to call.
            JP      (HL)                                                 ; No execute called routine
BKTOBKRET:  PUSH    AF
            LD      A,(USRBANKSAV)
            AND     00FH                                                 ; We just want the bank number we are returning to.
            LD      (BNKSELUSER),A                                           ; Switch back bank.
            POP     AF                                                   ; Restore A and flags to pass back to caller.
            RET


; Public methods for User Rom CBIOS Bank 1 - Utility functions.
?REBOOT:    LD      A,(ROMCTL)                                           ; Make sure Flash RAM I is active.
            AND     03FH
            LD      (ROMCTL),A
            LD      A,ROMBANK8                                           ; Method to exit CPM and return to the Sharp MZ80A Monitor.
            SCF
            CALL    SELUSRBNK                                            ; Ensure Rom Control is enabled
            JP      QREBOOT                                              ; Reboot has to take place from User ROM as the monitor ROM is swapped back to default position.

?MLDY:      CALL    BANK8                                                ; Method to sound a melody given an input array of notes to play.
            JP      QMELDY

?BEL:       CALL    BANK8                                                ; Method to sound a bell.
            JP      QBEL

?TEMP:      CALL    BANK8                                                ; Method to set the playback tempo.
            JP      QTEMP

?MLDST:     CALL    BANK8                                                ; Method to start playing a melody.
            JP      QMSTA

?MLDSP:     CALL    BANK8                                                ; Method to stop playing a melody.
            JP      QMSTP

?MODE:      CALL    BANK8                                                ; Method to setup the 8255 PIO.
            JP      QMODE

?TIMESET:   CALL    BANK8                                                ; Method to setup the RTC.
            JP      QTIMESET

?TIMEREAD:  CALL    BANK8                                                ; Method to read the RTC.
            JP      QTIMEREAD

?CHKKY:     CALL    BANK8                                                ; Method to see if a key has been pressed or available in the key buffer.
            JP      QCHKKY

?GETKY:     CALL    BANK8                                                ; Method to get the next key from the key buffer or wait until one is pressed.
            JP      QGETKY


; Public methods for User Rom CBIOS Bank 2 - Screen / ANSI Terminal functions.

?PRNT:      CALL    BANK9                                                ; Print a character onto the screen at current X/Y location.
            JP      QPRNT

?PRTHX:     CALL    BANK9                                                ; Print register A onto screen as 2 hex digits.
            JP      QPRTHX

?PRTHL:     CALL    BANK9                                                ; Print register HL onto screen as 4 hex digits.
            JP      QPRTHL

?ANSITERM:  CALL    BANK9                                                ; Send character into the ANSI terminal emulator and process.
            JP      QANSITERM

?NL:        LD      A,LF                                                 ; Print a newline.
            JR      ?PRNT

?PRTS:      LD      A,SPACE                                              ; Print a space.
            JR      ?PRNT

; Public methods for User ROM CBIOS Bank 3 - SD Card functions.

?SDINIT:    CALL    BANK10                                               ; Initialise the SD Card subsystem
            JP      SD_INIT

?SDREAD:    CALL    BANK10                                               ; Read a full or partial sector (512 bytes).
            JP      SD_READ

?SDWRITE:   CALL    BANK10                                               ; Write a full or partial sector (512 bytes).
            JP      SD_WRITE

?SDGETLBA:  CALL    BANK10                                               ; Get the LBA address for the given CPM Track and Sector.
            JP      SD_GETLBA

?SDCREAD:   CALL    BANK10                                               ; Read a CPM host sector according to stored values (512 bytes).
            JP      SDC_READ

?SDCWRITE:  CALL    BANK10                                               ; Write a CPM host sector according to stored values (512 bytes).
            JP      SDC_WRITE

; Public methods for User ROM CBIOS Bank 4 - Floppy Disk Controller functions.

?DSKINIT:   CALL    BANK11                                               ; Initialise the disk system.
            JP      QDSKINIT

?SETDRVCFG: CALL    BANK11                                               ; Set the drive configuration.
            JP      QSETDRVCFG

?SETDRVMAP: CALL    BANK11                                               ; Set the drive mapping, ie. CPM Drive C is FDC Drive.
            JP      QSETDRVMAP

?SELDRIVE:  CALL    BANK11                                               ; Select the requested drive and turn on motor.
            JP      QSELDRIVE

?GETMAPDSK: CALL    BANK11                                               ; Map the CPM Disk to an actual controller + disk number.
            JP      QGETMAPDSK

?DSKREAD:   CALL    BANK11                                               ; Read a sector from the selected disk
            JP      QDSKREAD

?DSKWRITE:  CALL    BANK11                                               ; Write a sector to the selected disk
            JP      QDSKWRITE




            ;-------------------------------------------------------------------------------
            ;  BOOT                                                                        
            ;                                                                              
            ;  The BOOT entry point gets control from the cold start loader and is         
            ;  responsible for basic system initialization, including sending a sign-on    
            ;  message, which can be omitted in the first version.                         
            ;  If the IOBYTE function is implemented, it must be set at this point.        
            ;  The various system parameters that are set by the WBOOT entry point must be 
            ;  initialized, and control is transferred to the CCP at 3400 + b for further  
            ;  processing. Note that register C must be set to zero to select drive A.     
            ;
            ; NB. This code is executed by the MZF loader. The following code is assembled
            ; in the header at $1108 to ensure correct startup.
            ; LD A,($E00C)   ; - Switch ROM to location $C000
            ; LD A,ROMBANK2  ; - Switch to the CBIOS rom in bank 2 of the monitor rom bank.
            ; LD ($EFFD),A   ; - Perform the bank switch.
            ; JP $C000       ; - Go to BOOT_
            ;-------------------------------------------------------------------------------
BOOT_:      DI                                                           ; Disable Interrupts and sat mode. NB. Interrupts are physically disabled by 8255 Port C2 set to low.
            IM      1
            ;
            LD      SP,BIOSSTACK                                         ; Setup to use local stack until CPM takes over.
            ;
            LD      HL,CPMBIOS                                           ; Start of CPM disk table and variable area
            LD      BC,VAREND-CPMBIOS                                    ; Size of CPM disk table and variable area.
            XOR     A
            LD      D,A
INIT1:      LD      (HL),D                                               ; Clear variable memory including stack space.
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,INIT1                
            ;
            LD      HL,00000H
            LD      BC,CBASE
INIT2:      LD      (HL),D                                               ; Clear TPA space.
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,INIT2                
            ;
            CALL    ?MODE                                                ; Configure 8255 port C, set Motor Off, VGATE to 1 (off) and INTMSK to 0 (interrupts disabled).
            LD      A,016H
            CALL    ?PRNT
            LD      A,017H                                               ; Blue background, white characters in colour mode. Bit 7 is set as a write to bit 7 @ DFFFH selects 80Char mode.
            LD      HL,ARAM
            CALL    CLR8
            LD      A,004H
            LD      (TEMPW),A                                            ; Setup the tempo for sound output.

            ; Initialise the Rom Paging Control Registers.
            LD      B,16                                                 ; If we read the bank control reset register 16 times then this will enable bank control and the 16th read will reset all bank control registers to default.
INIT3:      LD      A,(BNKCTRLRST)
            DJNZ    INIT3                                                ; Apply the default number of coded latch reads to enable the bank control registers.
            LD      A,BNKCTRLDEF                                         ; Set coded latch, SDCS high, BBMOSI to high and BBCLK to high which enables SDCLK.
            LD      (BNKCTRL),A
            LD      (ROMCTL),A                                           ; Save to memory the value in the bank control register - this register is used for SPI etc so need to remember its setting.
            LD      A,ROMBANK9                                           ; Screen Bank.
            LD      (BNKSELUSER),A    
            ;

            ; Setup keyboard buffer control.
            LD      A,0
            LD      (KEYCOUNT),A                                         ; Set keyboard buffer to empty.
            LD      HL,KEYBUF
            LD      (KEYWRITE),HL                                        ; Set write pointer to beginning of keyboard buffer.
            LD      (KEYREAD),HL                                         ; Set read pointer to beginning of keyboard buffer.

            ; Setup keyboard rate control and set to CAPSLOCK mode.
            ; (0 = Off, 1 = CAPSLOCK, 2 = SHIFTLOCK).
            LD      A,002H                                            ; Initialise key repeater.
            LD      (KEYRPT),A
            LD      A,001H
            LD      (SFTLK),A                                            ; Setup shift lock, default = off.

            ; Setup the initial cursor, for CAPSLOCK this is a double underscore.
            LD      A,03EH
            LD      (FLSDT),A
            LD      A,080H                                               ; Cursor on (Bit D7=1).
            LD      (FLASHCTL),A

            ; Change to 80 character mode if enabled.
            IF      BUILD_80C = 1
              LD    HL,DSPCTL                                            ; Setup address of display control register latch.
              LD    A, 128                                               ; 80 char mode.
              LD    E,(HL)                                               ; Dummy operation to enable latch write via multivibrator.
              LD    (HL), A
            ENDIF

            CALL    ?MLDSP
            CALL    ?NL
            LD      DE,CBIOSSIGNON                                       ; Start of sign on message, as devices are detected they are added to the sign on.
            CALL    MONPRTSTR
            CALL    ?BEL                                                 ; Beep to indicate startup - for cases where screen is slow to startup.
            LD      A,0FFH
            LD      (SWRK),A

            LD      HL,NUMBERBUF
            LD      (NUMBERPOS),HL
            ;
            XOR     A
            LD      (IOBYT),A
            LD      (CDISK),A            

            ; DRVAVAIL flag definition. Version 1.25 - removed ROM Drives and RAM drives as they provided no speed or use benefit compared with SD drives.
            ;
            ; 1 = Active.
            ;
            ; 7 6 5 4 3 2 1 0
            ; ^ ^ ^ ^ ^ ^ ^ ^
            ; | | | | | | | |-- Floppy Drive Present
            ; | | | | | | |---- ROM Drive Present
            ; | | | | | |------ SD Card Present
            ; | | | | |-------- RAM Drive Present
            ; | | | |----------          
            ; | | |------------
            ; | |--------------
            ; |---------------- Drives present                
            ;
            ; Initialise the SD Card subsystem (if connected).
            ;
        ;    CALL    ?SDINIT
            LD      A,0                                                  ; No drives yet detected so zero available mask.
        ;    JR      NZ,STRT2
            SET     2,A                                                  ; Assume the SD Card is present if it initialised.
            ;
            LD      DE,SDAVAIL
            CALL    PRTSTRTMSG                                           ; Print message and store Drive Availability flag in A
            ;
STRT2:      LD      (DRVAVAIL),A
            ;
            ; Locate the CPM binary Image in the ROM and store the Bank/Block to speed up warm boot.used for Warm restart CCP/BDOS reload. 
            LD      HL,CPMROMFNAME                                       ; Name of CPM File in rom.
            CALL    FINDMZF
            JP      NZ,ROMFINDERR                                        ; Failed to find CPM in the ROM! This shouldnt happen even if we boot from SD card, a copy needs to be in the ROM.
            LD      (CPMROMLOC),BC

STRT4:      CALL    ?DSKINIT                                             ; Initialise the disk subsystem.
            JR      NZ,STRT5
            LD      A,(DRVAVAIL)
            SET     0,A                                                  ; Indicate Floppy drives are available.

            LD      DE,FDCAVAIL
            CALL    PRTSTRTMSG                                           ; Print message and store Drive Availability flag in A
            ;
STRT5:      LD      DE,CBIOSIGNEND                                       ; Terminate the signon message which now includes list of drives detected.
            CALL    MONPRTSTR
           ;CALL    ?NL
            ;
            ; Allocate DPB according to drives detected in priorty, SD,FDC
            ;
            LD      DE,DPBASE                                            ; Base of parameter block.
            LD      A,0                                                  ; Using scratch area, setup the disk count, pointer to ALV memory and pointer to CSV memory.
            LD      (CDIRBUF),A
            LD      HL,CSVALVMEM
            LD      (CDIRBUF+1),HL

            ; Drives A,B default to SD card if present.
            CALL    ADDSDDRIVE
            CALL    ADDSDDRIVE

            ; Floppy drive controller always has 2 drives so set them up, which will be C,D when SD card present else A,B.
            CALL    ADDFLPYDRV
            CALL    ADDFLPYDRV

            ; Add additional SD card drives according to free space.
STRT9:      CALL    ADDSDDRIVE
            ;
            ; Now add as many additional SD drives as we have RAM available within the CBIOS.
            ;
            LD      BC,(CDIRBUF+1)
            LD      HL,CSVALVEND - 257                                   ; Subtract the size of the ALV (CSV has no size for a fixed SD drive)
            OR      A
            SBC     HL,BC
            JR      C,STRT10                                             ; If there is no more space, exit.
            JR      STRT9                                                ; Add another, keep on adding until there is no more ALV Memory free.

STRT10:     LD      A,(CDIRBUF)
            LD      (NDISKS),A                                           ; Setup max number of system disks found on this boot up.

            ; Setup timer interrupts
            LD      IX,TIMIN                                             ; Pass the interrupt service handler vector.
            LD      BC,00000H                                            ; Time starts at 00:00:00 01/01/1980 on initialisation.
            LD      DE,00000H
            LD      HL,00000H
            CALL    ?TIMESET

            ; Signon message after all the hardware has been initialised.
            LD      DE,CPMCOPYRMSG
            CALL    MONPRTSTR
           
            ; CP/M init
CPMINIT:    LD      A,(DRVAVAIL)
            BIT     0,A
            JR      Z,CPMINIT1
            ;
            CALL    ?DSKINIT                                             ; Re-initialise the disk subsystem if available.
            XOR     A                                                    ; 0 to accumulator
            LD      (HSTACT),A                                           ; Host buffer inactive
            LD      (UNACNT),A                                           ; Clear unalloc count
            ;
CPMINIT1:   LD      A, 0C3H                                              ; C3 IS A JMP INSTRUCTION
            LD      (00000H), A                                          ; FOR JMP TO WBOOT
            LD      HL,WBOOTE                                            ; WBOOT ENTRY POINT
            LD      (00001H), HL                                         ; SET ADDRESS FIELD FOR JMP AT 0
            LD      (00005H), A                                          ; FOR JMP TO BDOS
            LD      HL, CPMBDOS                                          ; BDOS ENTRY POINT
            LD      (00006H), HL                                         ; ADDRESS FIELD OF JUMP AT 5 TO BDOS
            LD      HL,TIMIN                                             ; Re-install interrupt vector for RTC incase it was overwritten.
            LD      (00038H),A
            LD      (00039H),HL
            LD      BC,CPMUSERDMA
            CALL    SETDMA_
            ;
            ; check if current disk is valid
            LD      A,(NDISKS)                                           ; Get the dynamic disk count.
            LD      L,A
            LD      A, (CDISK)                                           ; GET CURRENT USER/DISK NUMBER (UUUUDDDD)
            AND     00FH                                                 ; Isolate the disk number.
            CP      L                                                    ; Drive number ok?
            JR      C, WBTDSKOK2                                         ; Yes, jump (Carry set if A < NDISKS)
            LD      A, (CDISK)                                           ; No, set disk 0 (previous user)
            AND     0F0H
            LD      (CDISK), A                                           ; Save User/Disk    
WBTDSKOK2:  CALL    ?SETDRVMAP                                           ; Refresh the map of physical floppies to CPM drive number.
            CALL    ?SETDRVCFG
         ;  LD      A,(DISKTYPE)
         ;  OR      A
         ;  CALL    Z,?SELDRIVE                                          ; Select and start disk drive motor if floppy disk.
            ;
            LD      A,05H                                                ; Enable interrupts at hardware level.
            LD      (KEYPF),A
            ;
            LD      A, (CDISK)
            LD      C, A                                                 ; C = current User/Disk for CCP jump (UUUUDDDD)
            ;
GOCPM:      EI
            JP      CCP                                                  ; Start the CCP.

            ; Method to add an SD drive into the CPM disk definitions.
            ; If the SD controller hasnt been detected the routine exits without configuration.
ADDSDDRIVE: LD      A,(DRVAVAIL)
            BIT     2,A
            RET     Z                                                    ; No SD interface so skip.

            LD      BC,0                                                 ; Setup CSV/ALV parameters for a 16MB SD Card drive.
            LD      (CDIRBUF+3),BC
            LD      BC,257    ; 2048/8 + 1
            LD      (CDIRBUF+5),BC
            LD      BC,DPBLOCK4
            LD      (CDIRBUF+7),BC                                       ; Address of Disk Parameters
            CALL    COPYDPB                                              ; Add in an SD drive.
            RET

            ; Method to add a Floppy drive into the CPM disk definitions table.
            ; If the Floppy controller hasnt been detected then skip without configuration.
ADDFLPYDRV: LD      A,(DRVAVAIL)
            BIT     0,A
            RET     Z                                                    ; No Floppy drives available then skip.

            LD      BC,128/4                                             ; Setup CSV/ALV parameters for a 1.4MB Floppy drive.
            LD      (CDIRBUF+3),BC
            LD      BC,91   ; 720/8 + 1
            LD      (CDIRBUF+5),BC
            LD      BC,DPBLOCK3
            LD      (CDIRBUF+7),BC                                       ; Address of Disk Parameters
            CALL    COPYDPB                                              ; Add in a floppy drive.
            RET

            ; Helper method to print a message with a comma if Bit 7 of A is set.
PRTSTRTMSG: PUSH    AF
            BIT     7,A
            JR      Z,PRTCOMMA1
            LD      A,','
            CALL    ?PRNT
PRTCOMMA1:  CALL    MONPRTSTR
            POP     AF
            SET     7,A
            LD      (DRVAVAIL),A
            RET

            ;-------------------------------------------------------------------------------
            ;  WBOOT                                                                       
            ;                                                                               
            ;  The WBOOT entry point gets control when a warm start occurs.                
            ;  A warm start is performed whenever a user program branches to location      
            ;  0000H, or when the CPU is reset from the front panel. The CP/M system must  
            ;  be loaded from the first two tracks of drive A up to, but not including,    
            ;  the BIOS, or CBIOS, if the user has completed the patch. System parameters  
            ;  must be initialized as follows:                                             
            ;                                                                              
            ;  location 0,1,2                                                              
            ;      Set to JMP WBOOT for warm starts (000H: JMP 4A03H + b)                  
            ;                                                                              
            ;  location 3                                                                  
            ;      Set initial value of IOBYTE, if implemented in the CBIOS                
            ;                                                                              
            ;  location 4                                                                  
            ;      High nibble = current user number, low nibble = current drive           
            ;                                                                              
            ;  location 5,6,7                                                              
            ;      Set to JMP BDOS, which is the primary entry point to CP/M for transient 
            ;      programs. (0005H: JMP 3C06H + b)                                        
            ;                                                                              
            ;  Refer to Section 6.9 for complete details of page zero use. Upon completion 
            ;  of the initialization, the WBOOT program must branch to the CCP at 3400H+b  
            ;  to restart the system.                                                      
            ;  Upon entry to the CCP, register C is set to the drive to select after system
            ;  initialization. The WBOOT routine should read location 4 in memory, verify  
            ;  that is a legal drive, and pass it to the CCP in register C.                
            ;-------------------------------------------------------------------------------
WBOOT_:     DI
            ;
            LD      SP,BIOSSTACK

            ; Reload the CCP and BDOS from ROM.
            LD      DE,CPMBIOS-CBASE                                     ; Only want to load in CCP and BDOS.
            LD      BC,(CPMROMLOC)                                       ; Load up the Bank and Page where the CPM Image can be found.
            CALL    UROMLOAD
            LD      A,ROMBANK9                                           ; Screen Bank.
            LD      (BNKSELUSER),A    
            JP      Z,CPMINIT                                            ; Initialise CPM and run.
            LD      DE,NOBDOS
            CALL    MONPRTSTR
WBOOT2:     JR      WBOOT2                                               ; Nowhere to go!


            ;-------------------------------------------------------------------------------
            ;  CONOUT                                                                      
            ;                                                                              
            ;  The character is sent from register C to the console output device.         
            ;  The character is in ASCII, with high-order parity bit set to zero. You      
            ;  might want to include a time-out on a line-feed or carriage return, if the  
            ;  console device requires some time interval at the end of the line (such as  
            ;  a TI Silent 700 terminal). You can filter out control characters that cause 
            ;  the console device to react in a strange way (CTRL_Z causes the Lear-       
            ;  Siegler terminal to clear the screen, for example).                         
            ;-------------------------------------------------------------------------------
CONOUT_:    LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            LD      A,C
            CALL    ?ANSITERM
            LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET

            ;-------------------------------------------------------------------------------
            ;  CONIN                                                                       
            ;                                                                              
            ;  The next console character is read into register A, and the parity bit is   
            ;  set, high-order bit, to zero. If no console character is ready, wait until  
            ;  a character is typed before returning.                                      
            ;-------------------------------------------------------------------------------
CONIN_:     LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            CALL    ?GETKY
            LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET

            ;-------------------------------------------------------------------------------
            ;  CONST                                                                       
            ;                                                                              
            ;  You should sample the status of the currently assigned console device and   
            ;  return 0FFH in register A if a character is ready to read and 00H in        
            ;  register A if no console characters are ready.                              
            ;-------------------------------------------------------------------------------
CONST_:     LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            CALL    ?CHKKY
            LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET

            ;-------------------------------------------------------------------------------
            ;  READER                                                                      
            ;                                                                              
            ;  The next character is read from the currently assigned reader device into   
            ;  register A with zero parity (high-order bit must be zero); an end-of-file   
            ;  condition is reported by returning an ASCII CTRL_Z(1AH).                    
            ;-------------------------------------------------------------------------------
READER_:    LD      A, 01AH                                              ; Reader not implemented.
            RET

            ;-------------------------------------------------------------------------------
            ;  PUNCH                                                                       
            ;                                                                              
            ;  The character is sent from register C to the currently assigned punch       
            ;  device. The character is in ASCII with zero parity.                         
            ;-------------------------------------------------------------------------------
PUNCH_:     RET             ; Punch not implemented

            ;-------------------------------------------------------------------------------
            ;  LIST                                                                        
            ;                                                                              
            ;  The character is sent from register C to the currently assigned listing     
            ;  device. The character is in ASCII with zero parity bit.                     
            ;-------------------------------------------------------------------------------
LIST_:      RET

            ;-------------------------------------------------------------------------------
            ;  LISTST                                                                      
            ;                                                                              
            ;  You return the ready status of the list device used by the DESPOOL program  
            ;  to improve console response during its operation. The value 00 is returned  
            ;  in A if the list device is not ready to accept a character and 0FFH if a    
            ;  character can be sent to the printer. A 00 value should be returned if LIST 
            ;  status is not implemented.                                                  
            ;-------------------------------------------------------------------------------
LISTST_:    XOR      A    ; Not implemented.
            RET

            ;-------------------------------------------------------------------------------
            ;  HOME                                                                        
            ;                                                                              
            ;  The disk head of the currently selected disk (initially disk A) is moved to 
            ;  the track 00 position. If the controller allows access to the track 0 flag  
            ;  from the drive, the head is stepped until the track 0 flag is detected. If  
            ;  the controller does not support this feature, the HOME call is translated   
            ;  into a call to SETTRK with a parameter of 0.                                
            ;-------------------------------------------------------------------------------
HOME_:      LD      BC,00000H

            ;-------------------------------------------------------------------------------
            ;  SETTRK                                                                      
            ;                                                                              
            ;  Register BC contains the track number for subsequent disk accesses on the   
            ;  currently selected drive. The sector number in BC is the same as the number 
            ;  returned from the SECTRN entry point. You can choose to seek the selected   
            ;  track at this time or delay the seek until the next read or write actually  
            ;  occurs. Register BC can take on values in the range 0-76 corresponding to   
            ;  valid track numbers for standard floppy disk drives and 0-65535 for         
            ;  nonstandard disk subsystems.                                                
            ;-------------------------------------------------------------------------------
SETTRK_:    LD      (SEKTRK),BC ; Set track passed from BDOS in register BC.
            RET     

            ;-------------------------------------------------------------------------------
            ;  SETSEC                                                                      
            ;                                                                              
            ;  Register BC contains the sector number, 1 through 26, for subsequent disk   
            ;  accesses on the currently selected drive. The sector number in BC is the    
            ;  same as the number returned from the SECTRAN entry point. You can choose to 
            ;  send this information to the controller at this point or delay sector       
            ;  selection until a read or write operation occurs.                           
            ;-------------------------------------------------------------------------------
SETSEC_:    LD      A,C   ; Set sector passed from BDOS in register BC.
            LD      (SEKSEC), A
            RET     

            ;-------------------------------------------------------------------------------
            ;  SETDMA                                                                      
            ;                                                                              
            ;  Register BC contains the DMA (Disk Memory Access) address for subsequent    
            ;  read or write operations. For example, if B = 00H and C = 80H when SETDMA   
            ;  is called, all subsequent read operations read their data into 80H through  
            ;  0FFH and all subsequent write operations get their data from 80H through    
            ;  0FFH, until the next call to SETDMA occurs. The initial DMA address is      
            ;  assumed to be 80H. The controller need not actually support Direct Memory   
            ;  Access. If, for example, all data transfers are through I/O ports, the      
            ;  CBIOS that is constructed uses the 128 byte area starting at the selected   
            ;  DMA address for the memory buffer during the subsequent read or write       
            ;  operations.                                                                 
            ;-------------------------------------------------------------------------------
SETDMA_:    LD      (DMAADDR),BC
            RET     

            ;-------------------------------------------------------------------------------
            ;  SELDSK                                                                      
            ;                                                                              
            ;  The disk drive given by register C is selected for further operations,      
            ;  where register C contains 0 for drive A, 1 for drive B, and so on up to 15  
            ;  for drive P (the standard CP/M distribution version supports four drives).  
            ;  On each disk select, SELDSK must return in HL the base address of a 16-byte 
            ;  area, called the Disk Parameter Header, described in Section 6.10.          
            ;  For standard floppy disk drives, the contents of the header and associated  
            ;  tables do not change; thus, the program segment included in the sample      
            ;  CBIOS performs this operation automatically.                                
            ;                                                                              
            ;  If there is an attempt to select a nonexistent drive, SELDSK returns        
            ;  HL = 0000H as an error indicator. Although SELDSK must return the header    
            ;  address on each call, it is advisable to postpone the physical disk select  
            ;  operation until an I/O function (seek, read, or write) is actually          
            ;  performed, because disk selects often occur without ultimately performing   
            ;  any disk I/O, and many controllers unload the head of the current disk      
            ;  before selecting the new drive. This causes an excessive amount of noise    
            ;  and disk wear. The least significant bit of register E is zero if this is   
            ;  the first occurrence of the drive select since the last cold or warm start. 
            ;-------------------------------------------------------------------------------
SELDSK_:    LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            LD      HL, 00000H                                           ; HL = error code
            LD      A,(NDISKS)
            LD      B,A
            LD      A,C
            CP      B
            JR      NC,SELDSK1                                           ; Ensure we dont select a non existant disk.
            LD      (CDISK),A                                            ; Setup drive.
SELDSK0:    CALL    ?SETDRVCFG                                
            LD      A,(DISKTYPE)
            CP      DSKTYP_SDC
            JR      Z,SELSDCDSK                                          ; Select SD Card.
            ; If it is not an SD drive then it must be a floppy disk.
            LD      A,C
            JR      CALCHL
SELDSK1:    LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET

            ; For SD Cards, check that the SD Card is present, otherwise illegal disk.
SELSDCDSK:  LD      A,(DRVAVAIL)
            BIT     2,A
            JR      Z,SELDSK1                                            ; No SD Card drives available then skip.
            LD      A,C

            ;
            ; Code for blocking and deblocking algorithm
            ; (see CP/M 2.2 Alteration Guide p.34 and APPENDIX G)
CALCHL:     LD      (SEKDSK),A
            RLC     A                                                    ; *2
            RLC     A                                                    ; *4
            RLC     A                                                    ; *8
            RLC     A                                                    ; *16
            LD      HL,DPBASE
            LD      B,0
            LD      C,A 
            ADD     HL,BC
            JR      SELDSK1


            ;-------------------------------------------------------------------------------
            ;  SECTRAN                                                                     
            ;                                                                              
            ;  Logical-to-physical sector translation is performed to improve the overall  
            ;  response of CP/M. Standard CP/M systems are shipped with a skew factor of   
            ;  6, where six physical sectors are skipped between each logical read         
            ;  operation. This skew factor allows enough time between sectors for most     
            ;  programs to load their buffers without missing the next sector. In          
            ;  particular computer systems that use fast processors, memory, and disk      
            ;  subsystems, the skew factor might be changed to improve overall response.   
            ;  However, the user should maintain a single-density IBM-compatible version   
            ;  of CP/M for information transfer into and out of the computer system, using 
            ;  a skew factor of 6.                                                         
            ;                                                                              
            ;  In general, SECTRAN receives a logical sector number relative to zero in BC 
            ;  and a translate table address in DE. The sector number is used as an index  
            ;  into the translate table, with the resulting physical sector number in HL.  
            ;  For standard systems, the table and indexing code is provided in the CBIOS  
            ;  and need not be changed.                                                    
            ;-------------------------------------------------------------------------------
SECTRN_:    LD      H,B
            LD      L,C
            RET     


            ;-------------------------------------------------------------------------------
            ;  READ                                                                        
            ;                                                                              
            ;  Assuming the drive has been selected, the track has been set, and the DMA   
            ;  address has been specified, the READ subroutine attempts to read one sector 
            ;  based upon these parameters and returns the following error codes in        
            ;  register A:                                                                 
            ;                                                                              
            ;      0 - no errors occurred                                                  
            ;      1 - non recoverable error condition occurred                            
            ;                                                                              
            ;  Currently, CP/M responds only to a zero or nonzero value as the return      
            ;  code. That is, if the value in register A is 0, CP/M assumes that the disk  
            ;  operation was completed properly. If an error occurs the CBIOS should       
            ;  attempt at least 10 retries to see if the error is recoverable. When an     
            ;  error is reported the BDOS prints the message BDOS ERR ON x: BAD SECTOR.    
            ;  The operator then has the option of pressing a carriage return to ignore    
            ;  the error, or CTRL_C to abort.                                              
            ;-------------------------------------------------------------------------------
            ;
            ; Code for blocking and deblocking algorithm
            ; (see CP/M 2.2 Alteration Guide p.34 and APPENDIX G)
            ;
READ_:      LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            XOR     A
            LD      (UNACNT), A
            LD      A, 1
            LD      (READOP), A                                          ; read operation
            LD      (RSFLAG), A                                          ; must read data
            LD      A, WRUAL
            LD      (WRTYPE), A                                          ; treat as unalloc
            CALL    RWOPER                                               ; to perform the read, returns with A=0 no errors or A > 0 errors.
            LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET

            ;-------------------------------------------------------------------------------
            ;  WRITE                                                                       
            ;                                                                              
            ;  Data is written from the currently selected DMA address to the currently    
            ;  selected drive, track, and sector. For floppy disks, the data should be     
            ;  marked as nondeleted data to maintain compatibility with other CP/M         
            ;  systems. The error codes given in the READ command are returned in register 
            ;  A, with error recovery attempts as described above.                         
            ;-------------------------------------------------------------------------------
            ;
            ; Code for blocking and deblocking algorithm
            ; (see CP/M 2.2 Alteration Guide p.34 and APPENDIX G)
            ;
WRITE_:     LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            XOR     A                                                    ; 0 to accumulator
            LD      (READOP), A                                          ; not a read operation
            LD      A, C                                                 ; write type in c
            LD      (WRTYPE), A
            CP      WRUAL                                                ; write unallocated?
            JR      NZ, CHKUNA                                           ; check for unalloc
            ; write to unallocated, set parameters
            LD      A, BLKSIZ/128                                        ; next unalloc recs
            LD      (UNACNT), A
            LD      A, (SEKDSK)                                          ; disk to seek
            LD      (UNADSK), A                                          ; unadsk = sekdsk
            LD      HL, (SEKTRK)
            LD      (UNATRK), HL                                         ; unatrk = sectrk
            LD      A, (SEKSEC)
            LD      (UNASEC), A                                          ; unasec = seksec
            ; check for write to unallocated sector
CHKUNA:     LD      A,(UNACNT)                                           ; any unalloc remain?
            OR      A   
            JR      Z, ALLOC                                             ; skip if not
            ; more unallocated records remain
            DEC     A                                                    ; unacnt = unacnt-1
            LD      (UNACNT), A
            LD      A, (SEKDSK)                                          ; same disk?
            LD      HL, UNADSK
            CP      (HL)                                                 ; sekdsk = unadsk?
            JP      NZ, ALLOC                                            ; skip if not
            ; disks are the same
            LD      HL, UNATRK
            CALL    SEKTRKCMP                                            ; sektrk = unatrk?
            JP      NZ, ALLOC                                            ; skip if not
            ;   tracks are the same
            LD      A, (SEKSEC)                                          ; same sector?
            LD      HL, UNASEC
            CP      (HL)                                                 ; seksec = unasec?
            JP      NZ, ALLOC                                            ; skip if not
            ; match, move to next sector for future ref
            INC     (HL)                                                 ; unasec = unasec+1
            LD      A, (HL)                                              ; end of track?
            CP      CPMSPT                                               ; count CP/M sectors
            JR      C, NOOVF                                             ; skip if no overflow
            ; overflow to next track
            LD      (HL), 0                                              ; unasec = 0
            LD      HL, (UNATRK)
            INC     HL
            LD      (UNATRK), HL                                         ; unatrk = unatrk+1
            ; match found, mark as unnecessary read
NOOVF:      XOR     A                                                    ; 0 to accumulator
            LD      (RSFLAG), A                                          ; rsflag = 0
            JR      ALLOC2                                               ; to perform the write
            ; not an unallocated record, requires pre-read
ALLOC:      XOR     A                                                    ; 0 to accum
            LD      (UNACNT), A                                          ; unacnt = 0
            INC     A                                                    ; 1 to accum
ALLOC2:     LD      (RSFLAG), A                                          ; rsflag = 1
            CALL    RWOPER
            LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET


            ; Function to select a User Bank. If Carry is clear upon entry, on exit the control registers will be disabled. If carry is set then the control registers are left active.
            ; During normal operations the control registers are enabled. When access is needed to the full User ROM space, ie for drive read/write then the registers are disabled after
            ; setting the correct bank. The upper bits of the User ROM address space (ie. bits 20:19 which select the device) are set to by the ROMCTL variable.
            ;
SELUSRBNK:  DI
            PUSH    BC
            PUSH    AF
            ; Use a fixed number of reads to enable the control registers.
            LD      B,16
SELUSRBNK0: LD      A,(BNKCTRLRST)
            DJNZ    SELUSRBNK0
            POP     AF
            POP     BC
            LD      (BNKSELUSER),A                                       ; Select the required bank.
            LD      A,(ROMCTL)
            LD      (BNKCTRL),A
            JR      C,SELUSRBNK3
            LD      (BNKCTRLDIS),A                                       ; Disable the control registers, value of A is not important.
SELUSRBNK3: EI
            RET

;            EXX
;            EX      AF,AF'
;            LD      A,(ROMCTL)                                           ; Get current setting for the coded latch, ie. number of reads needed to enable it.
;            LD      C,A
;            RRA
;            RRA
;            CPL
;            AND     00FH                                                 ; Preserve bits 3-1, bit 0 is always 0 on the 74HCT191 latch.
;            LD      B,A                                                  ; Set value to B for loop.
;            LD      A,(BNKCTRLDIS)                                       ; Do a reset for the case where the above read enabled the latch, possible if external programs are reading/writing the latch area.
;            LD      A,(BNKCTRL)                                          ; Sample latch at start to detect change.
;            LD      E,A
;SELUSRBNK1: LD      A,(BNKCTRL)                                          ; Read the latch and compare with sample. Either we reach the count limit or the read differs indicating latch control.
;            CP      E
;            JR      NZ,SELUSRBNK2
;            DJNZ    SELUSRBNK1
;SELUSRBNK2: LD      A,C
;            LD      (BNKCTRL),A
;            EX      AF,AF'
;            LD      (BNKSELUSER),A                                       ; Select the required bank.
;            EXX
;            JR      C,SELUSRBNK3                                         ; If Carry is set by caller then leave the control registers active.
;            LD      (BNKCTRLDIS),A                                       ; Disable the control registers, value of A is not important.
;SELUSRBNK3: EI
;            RET


            ; Helper method to set up a Disk Parameter Block.
            ; Input: Drive Count = (CDIRBUF)
            ;        CSV/ALV Memory Pointer (CDIRBUF+1)
            ;        CSV Size (CDIRBUF+3)
            ;        ALV Size (CDIRBUF+5)
            ;        Disk parameters address CDIRBUF+7)
            ; Output: Updated CSV/ALV Pointer (CDIRBUF+1)
            ;         Updated disk count (CDIRBUF)
COPYDPB:    LD      HL,DPBTMPL                                           ; Base of parameter template for ROM Drive 0
            LD      BC,10
            LDIR                                                         ; Copy the lower part of the DPB as it is static.
            LD      HL,CDIRBUF+7                                         ; Get the address of the disk parameters.
            LDI
            LDI
            LD      BC,(CDIRBUF+3)                                       ; Add the CSV size for this entry to the pointer and store.
            LD      A,B                                                  ; Fixed drives dont have a CSV, so if 0, copy 0 and not allocate memory.
            OR      C
            LD      HL,CDIRBUF+1                                         ; Now get the free CSV/ALV pointer.
            JR      NZ,COPYDPB1
            LD      HL,CDIRBUF+3
COPYDPB1:   LDI
            LDI
            LD      HL,(CDIRBUF+1)
            LD      BC,(CDIRBUF+3)                                       ; Add the CSV size for this entry to the pointer and store.
            ADD     HL,BC
            LD      (CDIRBUF+1),HL
            LD      HL,CDIRBUF+1
            LDI
            LDI
            LD      HL,(CDIRBUF+1)
            LD      BC,(CDIRBUF+5)                                       ; Now add the size of the ALV for this drive to the pointer for the next drive.
            ADD     HL,BC
            LD      (CDIRBUF+1),HL                                       ; Store.
            LD      A,(CDIRBUF)
            INC     A
            LD      (CDIRBUF),A                                          ; Update drive count.
            RET


            ;-------------------------------------------------------------------------------
            ; TIMER INTERRUPT                                                                      
            ;                                                                              
            ; This is the RTC interrupt, which interrupts every 100msec. RTC is maintained
            ; by keeping an in memory count of seconds past 00:00:00 and an AMPM flag.
            ;-------------------------------------------------------------------------------
TIMIN:      LD      (SPISRSAVE),SP                                       ; CP/M has a small working stack, an interrupt could exhaust it so save interrupts stack and use a local stack.
            LD      SP,ISRSTACK
            ;
            PUSH    AF                                                   ; Save used registers.
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            ; Reset the interrupt counter.
            LD      HL,CONTF                                             ; CTC Control register, set to reload the 100ms interrupt time period.
            LD      (HL),080H                                            ; Select Counter 2, latch counter, read lsb first, mode 0 and binary.
            PUSH    HL
            DEC     HL
            LD      E,(HL)
            LD      D,(HL)                                               ; Obtain the overrun count if any (due to disabled interrupts).
            LD      HL, 00001H                                           ; Add full range to count to obtain the period of overrun time.
            SBC     HL,DE
            EX      DE,HL
            POP     HL
            LD      (HL),0B0H                                            ; Select Counter 2, load lsb first, mode 0 interrupt on terminal count, binary
            DEC     HL
            LD      (HL),TMRTICKINTV
            LD      (HL),000H                                            ; Another 100msec delay till next interrupt.
            ;
            ; Update the RTC with the time period.
            LD      HL,(TIMESEC)                                         ; Lower 16bits of counter.
            ADD     HL,DE
            LD      (TIMESEC),HL
            JR      NC,TIMIN1                                            ; On overflow we increment middle 16bits.
            ; 
            LD      HL,(TIMESEC+2)
            INC     HL 
            LD      (TIMESEC+2),HL
            LD      A,H
            OR      L
            JR      NZ,TIMIN1                                            ; On overflow we increment upper 16bits.
            ;
            LD      HL,(TIMESEC+4)
            INC     HL 
            LD      (TIMESEC+4),HL

            ;
            ; Flash a cursor at the current XY location.
            ;
TIMIN1:     LD      HL,FLASHCTL
            BIT     7,(HL)                                               ; Is cursor enabled? If it isnt, skip further processing.
            JR      Z,TIMIN2
            ;
FLSHCTL0:   LD      A,(KEYPC)                                            ; Flashing component, on each timer tick, display the cursor or the original screen character.
            LD      C,A
            XOR     (HL)                                                 ; Detect a cursor change signal.
            RLCA    
            RLCA    
            JR      NC,TIMIN2                                            ; No change, skip.

            RES     6,(HL)
            LD      A,C                                                  ; We know there was a change, so decide what to display and write to screen.
            RLCA
            RLCA
            LD      A,(FLASH)
            JR      NC,FLSHCTL1
            SET     6,(HL)                                               ; We are going to display the cursor, so save the underlying character.
            LD      A,(FLSDT)                                            ; Retrieve the cursor character.
FLSHCTL1:   LD      HL,(DSPXYADDR)                                       ; Load the desired cursor or character onto the screen.
            LD      (HL),A

            ; 
            ; FDC Motor Off Timer
            ;
TIMIN2:     LD      A,(MTROFFTIMER)                                      ; Is the timer non-zero?
            OR      A
            JR      Z,TIMIN3
            DEC     A                                                    ; Decrement.
            LD      (MTROFFTIMER),A                                      
            JR      NZ,TIMIN3                                            ; If zero after decrement, turn off the motor.
            OUT     (FDC_MOTOR),A                                        ; Turn Motor off
            LD      (MOTON),A                                            ; Clear Motor on flag

            ;
            ; Keyboard processing.
            ;
TIMIN3:     CALL    ?SWEP                                                ; Perform keyboard sweep
            LD      A,B
            RLCA    
            JR      C,ISRKEY2                                            ; CY=1 then data available.
            LD      HL,KDATW
            LD      A,(HL)                                               ; Is a key being held down?
            OR      A
            JR      NZ, ISRAUTORPT                                       ; It is so process as an auto repeat key.
            XOR     A
            LD      (KEYRPT),A                                           ; No key held then clear the auto repeat initial pause counter.
            LD      A,NOKEY                                              ; No key code.
ISRKEY1:    LD      E,A
            LD      A,(HL)                                               ; Current key scan line position.
            INC     HL
            LD      D,(HL)                                               ; Previous key position.
            LD      (HL),A                                               ; Previous <= current
            SUB     D                                                    ; Are they the same?
            JR      NC,ISRKEY11
            INC     (HL)                                                 ; 
ISRKEY11:   LD      A,E
ISRKEY10:   CP      NOKEY
            JR      Z,ISREXIT
            LD      (KEYLAST),A
ISRKEYRPT:  LD      A,(KEYCOUNT)                                         ; Get current count of bytes in the keyboard buffer.
            CP      KEYBUFSIZE - 1
            JR      NC, ISREXIT                                          ; Keyboard buffer full, so waste character.
            INC     A
            LD      (KEYCOUNT),A
            LD      HL,(KEYWRITE)                                        ; Get the write buffer pointer.
            LD      (HL), E                                              ; Store the character.
            INC     L
            LD      A,L
            AND     KEYBUFSIZE-1                                           ; Circular buffer, keep boundaries.
            LD      L,A
            LD      (KEYWRITE),HL                                        ; Store updated pointer.
ISREXIT:    POP     HL
            POP     DE
            POP     BC
            POP     AF
            ;
            LD      SP,(SPISRSAVE)
            EI      
            RET     

            ;
            ; Helper to determine if a key is being held down and autorepeat should be applied.
            ; The criterion is a timer, if this expires then autorepeat is applied.
            ;
ISRAUTORPT: LD      A,(KEYRPT)                                           ; Increment an initial pause counter.
            INC     A
            CP      10
            JR      C,ISRAUTO1                                           ; Once expired we can auto repeat the last key.
            LD      A,(KEYLAST)
            CP      080H
            JR      NC,ISREXIT                                           ; Dont auto repeat control keys.
            LD      E,A
            JR      ISRKEYRPT 
ISRAUTO1:   LD      (KEYRPT),A
            JR      ISREXIT

            ;
            ; Method to alternate through the 3 shift modes, CAPSLOCK=1, SHIFTLOCK=2, NO LOCK=0
            ;
LOCKTOGGLE: LD      HL,FLSDT
            LD      A,(SFTLK)
            INC     A
            CP      3
            JR      C,LOCK0
            XOR     A
LOCK0:      LD      (SFTLK),A
            OR      A
            LD      (HL),043H                                            ; Thick block cursor when lower case.
            JR      Z,LOCK1
            CP      1
            LD      (HL),03EH                                            ; Thick underscore when CAPS lock.
            JR      Z,LOCK1
            LD      (HL),0EFH                                            ; Block cursor when SHIFT lock.
LOCK1:      JP      ISREXIT


ISRKEY2:    RLCA    
            RLCA    
            RLCA    
            JP      C,LOCKTOGGLE                                         ; GRAPH key which acts as the Shift Lock.
            RLCA    
            JP      C,ISRBRK                                             ; BREAK key.
            LD      H,000H
            LD      L,C
            LD      A,C
            CP      038H                                                 ; TEN KEY check.
            JR      NC,ISRKEY6                                           ; Jump if TENKEY.
            LD      A,B
            RLCA    
            LD      B,A
            LD      A,(SFTLK)
            OR      A
            LD      A,B
            JR      Z,ISRKEY14                 
            RLA     
            CCF     
            RRA     
ISRKEY14:   RLA     
            RLA     
            JR      NC,ISRKEY3                
ISRKEY15:   LD      DE,KTBLC
ISRKEY5:    ADD     HL,DE
            LD      A,(HL)
            JP      ISRKEY1                   

ISRKEY3:    RRA     
            JR      NC,ISRKEY6                
            LD      A,(SFTLK)
            CP      1
            LD      DE,KTBLCL
            JR      Z,ISRKEY5
            LD      DE,KTBLS
            JR      ISRKEY5                   

ISRKEY6:    LD      DE,KTBL
            JR      ISRKEY5                   
ISRKEY4:    RLCA    
            RLCA    
            JR      C,ISRKEY15                 
            LD      DE,KTBL
            JR      ISRKEY5                   

            ; Break key pressed, handled in getkey routine.
ISRBRK:     LD      A,(KEYLAST)
            CP      BREAKKEY
            JP      Z,ISREXIT
            XOR     A                                                    ; Reset the keyboard buffer.
            LD      (KEYCOUNT),A
            LD      HL,KEYBUF
            LD      (KEYWRITE),HL
            LD      (KEYREAD),HL
            LD      A,BREAKKEY
            JP      ISRKEY10

            ; KEYBOARD SWEEP
            ;
            ; EXIT B,D7=0    NO DATA
            ;          =1    DATA
            ;        D6=0    SHIFT OFF
            ;          =1    SHIFT ON
            ;      C   =     ROW & COLUMN
            ;
?SWEP:      XOR     A
            LD      (KDATW),A                                            ; Reset key counter
            LD      B,0FAH                                               ; Starting scan line, D3:0 = scan = line 10. D5:4 not used, D7=Cursor flash.
            LD      D,A

            ; BREAK TEST
            ; BREAK ON  : ZERO = 1
            ;       OFF : ZERO = 0
            ; NO KEY    : CY = 0
            ; KEY IN    : CY = 1
            ;     A D6=1: SHIFT ON
            ;         =0: SHIFT OFF
            ;       D5=1: CTRL ON
            ;         =0: CTRL OFF
            ;       D4=1: GRAPH ON
            ;         =0: GRAPH OFF
BREAK:      LD      A,0F0H
            LD      (KEYPA),A                                            ; Port A scan line 0
            NOP     
            LD      A,(KEYPB)                                            ; Read back key data.
            OR      A
            RLA     
            JR      NC,BREAK3                                            ; CTRL/BREAK key pressed?
            RRA     
            RRA                                                          ; Check if SHIFT key pressed/
            JR      NC,BREAK1                                            ; SHIFT BREAK not pressed, jump.
            RRA     
            JR      NC,BREAK2                                            ; Check for GRAPH.
            CCF     
            JR      SWEP6 ;SWEP1     

BREAK1:     LD      A,040H                                               ; A D6=1 SHIFT ON
            SCF     
            JR      SWEP6

BREAK2:     LD      A,001H                                               ; No keys found to be pressed on scanline 0.
            LD      (KDATW),A
            LD      A,010H                                               ; A D4=1 GRAPH
            SCF     
            JR      SWEP6

BREAK3:     AND     006H                                                 ; SHIFT + GRAPH + BREAK?
            JR      Z,SWEP1A
            AND     002H                                                 ; SHIFT ?
            JR      Z,SWEP1                                              ; Z = 1 = SHIFT BREAK pressed/
            LD      A,020H                                               ; A D5=1 CTRL
            SCF     
            JR      SWEP6

SWEP1:      LD      D,088H                                               ; Break ON
            JR      SWEP9                   
SWEP1A:     JP      ?REBOOT                                              ; Shift + Graph + Break ON = RESET.
            ;
            JR      SWEP9                   
SWEP6:      LD      HL,SWPW
            PUSH    HL
            JR      NC,SWEP11                
            LD      D,A
            AND     060H                                                 ; Shift & Ctrl =no data.
            JR      NZ,SWEP11                
            LD      A,D                                                  ; Graph Check
            XOR     (HL)
            BIT     4,A
            LD      (HL),D
            JR      Z,SWEP0                 
SWEP01:     SET     7,D                                                  ; Data available, set flag.
SWEP0:      DEC     B
            POP     HL                                                   ; SWEP column work
            INC     HL
            LD      A,B
            LD      (KEYPA),A                                            ; Port A (8255) D3:0 = Scan line output.
            CP      0F0H
            JR      NZ,SWEP3                                             ; If we are not at scan line 0 then check for key data.              
            LD      A,(HL)                                               ; SWPW
            CP      003H                                                 ; Have we scanned all lines, if yes then no data?
            JR      C,SWEP9                 
            LD      (HL),000H                                            ;
            RES     7,D                                                  ; Reset data in as no data awailable.
SWEP9:      LD      B,D
            RET     

SWEP11:     LD      (HL),000H
            JR      SWEP0                   
SWEP3:      LD      A,(KEYPB)                                            ; Port B (8255) D7:0 = Key data in for given scan line.
            LD      E,A
            CPL     
            AND     (HL)
            LD      (HL),E
            PUSH    HL
            LD      HL,KDATW
            PUSH    BC
            LD      B,008H
SWEP8:      RLC     E
            JR      C,SWEP7                 
            INC     (HL)
SWEP7:      DJNZ    SWEP8                   
            POP     BC
            OR      A
            JR      Z,SWEP0                 
            LD      E,A
SWEP2:      LD      H,008H
            LD      A,B
            DEC     A                                                    ; TBL adjust
            AND     00FH
            RLCA    
            RLCA    
            RLCA    
            LD      C,A
            LD      A,E
SWEP12:     DEC     H
            RRCA    
            JR      NC,SWEP12                
            LD      A,H
            ADD     A,C
            LD      C,A
            JP      SWEP01

            ;-------------------------------------------------------------------------------
            ; END OF TIMER INTERRUPT                                                                      
            ;-------------------------------------------------------------------------------

            ; Method to clear memory either to 0 or a given pattern.
            ;
CLR8Z:      XOR     A
CLR8:       LD      BC,00800H
CLRMEM:     PUSH    DE
            LD      D,A
L09E8:      LD      (HL),D
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,L09E8                
            POP     DE
            RET     

?CLER:      XOR     A
            JR      ?DINT                   
?CLRFF:     LD      A,0FFH
?DINT:      LD      (HL),A
            INC     HL
            DJNZ    ?DINT                   
            RET  

MULT16x8:   LD      HL,0
            LD      B,8
MULT16x8_1: ADD     HL,HL
            RLCA
            JR      NC,MULT16x8_2
            ADD     HL,DE
MULT16x8_2: DJNZ    MULT16x8_1
            RET


            ;-------------------------------------------------------------------------------
            ; START OF ROM DRIVE FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Comparing Strings
            ; IN    HL     Address of string1.
            ;       DE     Address of string2.
            ;       BC     Max bytes to compare, 0x00 or 0x0d will early terminate.
            ; OUT   zero   Set if string1 = string2, reset if string1 != string2.
            ;       carry  Set if string1 > string2, reset if string1 <= string2.
CMPSTRING:  PUSH    HL
            PUSH    DE

CMPSTR1:    LD      A, (DE)                                              ; Compare bytes.
            CP      000h                                                 ; Check for end of string.
            JR      Z,  CMPSTR3
            CP      00Dh
            JR      Z,  CMPSTR3
            CPI                                                          ; Compare bytes.
            JR      NZ, CMPSTR2                                          ; If (HL) != (DE), abort.
            INC     DE                                                   ; Update pointer.
            JP      PE, CMPSTR1                                          ; Next byte if BC not zero.

CMPSTR2:    DEC     HL
            CP      (HL)                                                 ; Compare again to affect carry.
CMPSTR4:    POP     DE
            POP     HL
            RET

CMPSTR3:    LD      A, (HL)
            CP      000h                                                 ; Check for end of string.
            JR      Z, CMPSTR4
            CP      00Dh
            JR      Z, CMPSTR4
            SCF                                                          ; String 1 greater than string 2
            JR      CMPSTR4

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

            ; In:
            ;     HL = filename
            ; Out:
            ;      B = Bank Page file found
            ;      C = 7:6 = Upper Bank address where file found, 5:0 = Block where found.
            ;      D = File sequence number.
            ;      Z set if found.
FINDMZF:    LD       (TMPADR), HL                                         ; Save name of program to load.  
            ;
            ; Scan MROM Bank
            ; B = Bank Page
            ; C = Block in page
            ; D = File sequence number.
            ;
FINDMZF0:   LD      B,USRROMPAGES                                        ; First 16 pages are reserved in User ROM bank.
            ;
            LD      A,(ROMCTL)
            AND     03FH                                                 ; Mask out the upper bank address lines so we start with Flash RAM I.
            ;
FINDNXTDVC: LD      (ROMCTL),A
            LD      C,0                                                  ; Block in page.
            LD      D,0                                                  ; File numbering start.
FINDMZF1:   LD      A,B
            OR      A                                                    ; Select the required user bank and Clear carry so that the control registers are disabled.
            CALL    SELUSRBNK 
FINDMZF2:   PUSH    BC                                                   ; Preserve bank count/block number.
            PUSH    DE                                                   ; Preserve file numbering.
            LD      HL,0E800h + RFS_ATRB                                 ; Add block offset to get the valid block.
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

            CALL    ISMZF                                                ; Check to see if this looks like a header entry.
            POP     DE
            POP     BC
            JR      NZ, FINDMZF4                                         ; Z set if we found an MZF record.
            INC     HL                                                   ; Save address of filename.
FINDMZF3:   PUSH    DE
            PUSH    BC
            LD      DE,(TMPADR)                                          ; Original DE put onto stack, original filename into DE 
            LD      BC,17
            CALL    CMPSTRING
            POP     BC
            POP     DE
            JR      Z, FINDMZFYES
            INC     D                                                    ; Next file sequence number.           
FINDMZF4:   INC     C
            LD      A,C
            CP      UROMSIZE/RFSSECTSZ                                   ; Max blocks per page reached?
            JR      C, FINDMZF5
            LD      C,0
            INC     B
FINDMZF5:   LD      A,B
            CP      000h                                                 ; User ROM has 256 banks of 2K, so stop when we wrap around to zero.
            JR      NZ, FINDMZF1
            ;
            LD      A,(ROMCTL)
            ADD     A, 64
            CP      0C0H                                                 ; If both upper address bits are set then we have come to the end.
            JR      C,FINDNXTDVC
            AND     03FH
            LD      (ROMCTL),A                                           ; Switch back to primary Flash RAM I device.
            ;
            INC     B                                                    ; Clear Z flag.
            JR      FINDMZFNO
            ;
FINDMZFYES: LD      A,(ROMCTL)
            AND     0C0H                                                 ; Interested in the top two address bits 20:19
            OR      C
            LD      C,A                                                  ; Place the top address bits into the Block as the upper two bits.
            LD      A,(ROMCTL)
            AND     03FH
            LD      (ROMCTL),A                                           ; Reset upper address bits to the User ROM I device.
            XOR     A                                                    ; Clear Z flag to indicate we found the file and BC points to it.
            ;
FINDMZFNO:  PUSH    AF                                                   ; Preserve flags.
            LD      A,ROMBANK9
            SCF                                                          ; Select the required user bank and Set carry so that the control registers remain enabled.
            CALL    SELUSRBNK 
            POP     AF
            RET


            ; Load Program from ROM
            ; IN    BC     Bank and Block of MZF file. C contains Block in bits 5:0 and upper bank address bits in 7:6.
            ;       DE     0 - use file size in header, > 0 file size to load.
            ; OUT   zero   Set if file loaded, reset if an error occurred.
            ;
            ; Load program from RFS Bank 2 (User ROM Bank)
            ;
UROMLOAD:   PUSH    BC
            PUSH    DE
            ;
            LD      A,C                                                  ; Set upper address bits by masking out 7:6 and adding to ROMCTL variable.
            AND     0C0H
            LD      L,A
            LD      A,(ROMCTL)
            AND     03FH
            OR      L
            LD      (ROMCTL),A
            ;
            LD      A,C                                                  ; Remove upper address bits from starting block.
            AND     03FH
            LD      C,A
            ;
            LD      A,B
            OR      A                                                    ; Select the required user bank and Clear carry so that the control registers are disabled.
            CALL    SELUSRBNK 
            ;
            LD      DE, IBUFE                                            ; Copy the header into the work area.
            LD      HL, 0E800h                                           ; Add block offset to get the valid block.
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
            LD      BC, MZFHDRNCSZ
LROMLOAD0:  LD      A,(BNKCTRLDIS)
            LD      A,(HL)                                               ; Issues with LDIR and a signal artifact from the mainboard, so manual copy.
            INC     HL
            LD      (DE),A
            INC     DE
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,LROMLOAD0

            LD      DE,MZFHDRSZ - MZFHDRNCSZ                             ; Account for the full MZF header (we only load the initial part to save RAM).
            ADD     HL,DE
            POP     DE
            LD      A,D                                                  ; Test DE, if 0 the use the size to load from header.
            OR      E                                                    ;          if not 0, use size to load in DE.
            JR      Z,LROMLOAD1
            LD      (SIZE),DE                                            ; Overwrite the header size with the new size to load.

LROMLOAD1:  PUSH    HL
            LD      DE, (DTADR)
            LD      HL, (SIZE)
            LD      BC, RFSSECTSZ - MZFHDRSZ
            OR      A
            SBC     HL, BC
            JR      NC, LROMLOAD4
            LD      HL, (SIZE)
            JR      LROMLOAD4

            ; HL = address in active block to read.
            ;  B = Bank
            ;  C = Block 
LROMLOAD2:  LD      A, B
            OR      A                                                    ; Select the required user bank and Clear carry so that the control registers are disabled.
            CALL    SELUSRBNK 

LROMLOAD3:  PUSH    BC
            LD      HL, UROMADDR
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
            CCF
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

LROMLOAD9:  LD       (BNKCTRLDIS),A                                      ; There exists an issue with using the mainboard decoder signal which I havent quite understood, random activation of the upcounter occurs which appears to be the refresh circuit. 
            LD      A,(HL)                                               ; Issues with LDIR and a signal artifact from the mainboard, so manual copy.
            INC     HL
            LD      (DE),A
            INC     DE
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,LROMLOAD9

            LD      BC, (TMPSIZE)
            LD      A, B                                                 ; Post check to ensure we still have bytes
            OR      C
            JR      Z, LROMLOAD8
            ;
            LD      (TMPADR),DE                                          ; Address we are loading into.
            POP     BC
LROMLOAD6:  INC     C
            LD      A, C
            CP      UROMSIZE/RFSSECTSZ                                   ; Max blocks per page reached?
            JR      C, LROMLOAD3
            LD      C, 0
            INC     B
            ;
LROMLOAD7:  LD      A, B
            CP      000h
            JR      NZ, LROMLOAD2
            OR      1
            JR      LROMLOAD5
            ;
LROMLOAD8:  POP     BC
LROMLOAD5:  PUSH    AF
            LD      A,(ROMCTL)
            AND     03FH
            LD      (ROMCTL),A                                           ; Switch back to primary Flash RAM I device.
            LD      A,ROMBANK9
            SCF                                                          ; Select the required user bank and Set carry so that the control registers remain enabled.
            CALL    SELUSRBNK 
            POP     AF
            RET

            ; Rom filing system error messages.
ROMFINDERR: LD      DE,ROMFDERRMSG
            JR      MONPRTSTR 

            ; Function to print a string with control character interpretation.
MONPRTSTR:  LD      A,(DE)
            OR      A
            RET     Z
            INC     DE
MONPRTSTR2: CALL    ?PRNT
            JR      MONPRTSTR
            ;-------------------------------------------------------------------------------
            ; END OF ROM DRIVE FUNCTIONALITY
            ;-------------------------------------------------------------------------------


            ;-------------------------------------------------------------------------------
            ; START OF SD CARD DRIVE FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Method to read a sector from the SD Card.
            ; CPM Provides us with a track and sector, take these and calculate the LBA
            ; within the SD Card.
            ;
            ; The SD Card is organised as follows:
            ;       SECTOR   FUNCTION
            ;       00000000 ---------------------------------------------------------------------------
            ;                | ROM FILING SYSTEM IMAGE                                                 |
            ;                |                                                                         |
            ;       00000000 | RFS DIRECTORY ENTRY 000 (32BYTE)                                        |
            ;                | ..                                                                      |
            ;                | ..                                                                      |
            ;       00001FE0 | RFS DIRECTORY ENTRY 255 (32BYTE)                                        |
            ;       00002000 ---------------------------------------------------------------------------
            ;                |                                                                         |
            ;                |  CP/M DISK IMAGE 1                                                      |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                ---------------------------------------------------------------------------
            ;                |                                                                         |
            ;                |  CP/M DISK IMAGE 2                                                      |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                ---------------------------------------------------------------------------
            ;                |                                                                         |
            ;                |  CP/M DISK IMAGE 3                                                      |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                ---------------------------------------------------------------------------
            ;                |                                                                         |
            ;                |  CP/M DISK IMAGE ...                                                    |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                |                                                                         |
            ;                ---------------------------------------------------------------------------
            ;
            ;       The ROM FILING SYSTEM resides at the beginning of the disk so we add this to the start sector for the CPM drive.
            ;       Then the CPM disk is multiplied by the CPM disk size and this is added to the start sector.
            ;       The disk is organised as 32 Sectors x 1024 tracks and 1 head. Thus the track is
            ;       multiplied by 32 as we use LBA addressing (for older cards, the SD utilities will convert to byte
            ;       address if necessary. This is added to the start sector. We then take the CPM host sector (from the deblocking
            ;       algorithm) and add to the start sector. We now have the sector CPM is requesting.
            ;
SDCREAD:    CALL    ?SDCREAD
            JP      READHST3

SDCWRITE:   CALL    ?SDCWRITE
            JP      WRITEHST3

            ;-------------------------------------------------------------------------------
            ; END OF SD CARD DRIVE FUNCTIONALITY
            ;-------------------------------------------------------------------------------



            ;-------------------------------------------------------------------------------
            ; START OF CPM DEBLOCKING ALGORITHM
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; RWOPER                                                                      
            ;                                                                              
            ; The common blocking/deblocking algorithm provided by DR to accommodate devices
            ; which have sector sizes bigger than the CPM 128byte standard sector.
            ; In this implementation a sector size of 512 has been chosen regardless of
            ; what the underlying hardware uses (ie. FDC is 256 byte for a standard MZ800
            ; format disk).
            ;-------------------------------------------------------------------------------
RWOPER:     XOR     A                                                    ; zero to accum
            LD      (ERFLAG), A                                          ; no errors (yet)
            LD      A, (SEKSEC)                                          ; compute host sector
            OR      A                                                    ; carry = 0
            RRA                                                          ; shift right
            OR      A                                                    ; carry = 0
            RRA                                                          ; shift right
            LD      (SEKHST), A                                          ; host sector to seek
            ; active host sector?
            LD      HL, HSTACT                                           ; host active flag
            LD      A, (HL)
            LD      (HL), 1                                              ; always becomes 1
            OR      A                                                    ; was it already?
            JR      Z, FILHST                                            ; fill host if not
            ; host buffer active, same as seek buffer?
            LD      A, (SEKDSK)
            LD      HL, HSTDSK                                           ; same disk?
            CP      (HL)                                                 ; sekdsk = hstdsk?
            JR      NZ, NOMATCH
            ; same disk, same track?
            LD      HL, HSTTRK
            CALL    SEKTRKCMP                                            ; sektrk = hsttrk?
            JR      NZ, NOMATCH
            ; same disk, same track, same buffer?
            LD      A, (SEKHST)
            LD      HL, HSTSEC                                           ; sekhst = hstsec?
            CP      (HL)
            JR      Z, MATCH                                             ; skip if match
            ; proper disk, but not correct sector
NOMATCH:    LD      A, (HSTWRT)                                          ; host written?
            OR      A
            CALL    NZ, WRITEHST                                         ; clear host buff
            ; may have to fill the host buffer
FILHST:     LD      A, (SEKDSK)
            LD      (HSTDSK), A
            LD      HL, (SEKTRK)
            LD      (HSTTRK), HL
            LD      A, (SEKHST)
            LD      (HSTSEC), A
            LD      A, (RSFLAG)                                          ; need to read?
            OR      A
            CALL    NZ, READHST                                          ; yes, if 1
            OR      A
            JR      NZ,RWEXIT                                            ; If A > 0 then read error occurred.
            XOR     A                                                    ; 0 to accum
            LD      (HSTWRT), A                                          ; no pending write
            ; copy data to or from buffer
MATCH:      LD      A,  (SEKSEC)                                         ; mask buffer number
            AND     SECMSK                                               ; least signif bits
            LD      L,  A                                                ; ready to shift
            LD      H,  0                                                ; double count
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ; hl has relative host buffer address
            LD      DE, HSTBUF
            ADD     HL, DE                                               ; hl = host address
            EX      DE, HL                                               ; now in DE
            LD      HL, (DMAADDR)                                        ; get/put CP/M data
            LD      C, 128                                               ; length of move
            LD      A, (READOP)                                          ; which way?
            OR      A
            JR      NZ, RWMOVE                                           ; skip if read
            ; write operation, mark and switch direction
            LD      A, 1
            LD      (HSTWRT), A                                          ; hstwrt = 1
            EX      DE, HL                                               ; source/dest swap
            ; c initially 128, DE is source, HL is dest
RWMOVE:     LD      A,(INVFDCDATA)                                       ; Check to see if FDC data needs to be inverted. MB8866 controller works on negative logic.
            RRCA
            JR      NC,RWMOVE3
RWMOVE2:    LD      A, (DE)                                              ; source character
            CPL                                                          ; Change to positive values.
            INC     DE
            LD      (HL), A                                              ; to dest
            INC     HL
            DEC     C                                                    ; loop 128 times
            JR      NZ, RWMOVE2
            JR      RWMOVE4
RWMOVE3:    LD      A, (DE)                                              ; source character
            INC     DE
            LD      (HL), A                                              ; to dest
            INC     HL
            DEC     C                                                    ; loop 128 times
            JR      NZ, RWMOVE3
            ; data has been moved to/from host buffer
RWMOVE4:    LD      A, (WRTYPE)                                          ; write type
            CP      WRDIR                                                ; to directory?
            LD      A, (ERFLAG)                                          ; in case of errors
            RET     NZ                                                   ; no further processing
            ; clear host buffer for directory write
            OR      A                                                    ; errors?
            RET     NZ                                                   ; skip if so
            XOR     A                                                    ; 0 to accum
            LD      (HSTWRT), A                                          ; buffer written
            CALL    WRITEHST
RWEXIT:     LD      A, (ERFLAG)
            RET
        
            ; utility subroutine for 16-bit compare
            ; HL = .unatrk or .hsttrk, compare with sektrk
SEKTRKCMP:  EX      DE, HL
            LD      HL, SEKTRK
            LD      A, (DE)                                              ; low byte compare
            CP      (HL)                                                 ; same?
            RET     NZ                                                   ; return if not
            ; low bytes equal, test high 1s
            INC     DE
            INC     HL
            LD      A, (DE)
            CP      (HL)                                                 ; sets flags
            RET

            ;------------------------------------------------------------------------------------------------
            ; Read physical sector from host
            ;
            ; Read data from the floppy disk or RFS. A = 1 if an error occurred.
            ;------------------------------------------------------------------------------------------------
READHST:    PUSH    BC
            PUSH    HL
            LD      A,(DISKTYPE)
            CP      DSKTYP_SDC                                           ; Is the drive an SD Card?
            JP      Z,SDCREAD
READHST2:   CALL    ?DSKREAD                                             ; Floppy card, use the FDC Controller.
READHST3:   POP     HL
            POP     BC
            RET
        
            ;------------------------------------------------------------------------------------------------
            ; Write physical sector to host
            ;
            ; Write data to the floppy disk or RFS. A = 1 if an error occurred.
            ;------------------------------------------------------------------------------------------------
WRITEHST:   PUSH    BC
            PUSH    HL
            LD      A,(DISKTYPE)
            CP      DSKTYP_SDC                                           ; Is the drive an SD Card?
            JP      Z,SDCWRITE
            CALL    ?DSKWRITE
WRITEHST3:  POP     HL
            POP     BC
            RET
WRITEHST4:  LD      A,1                                                  ; Error, cannot write.
            JR      WRITEHST3

            ;-------------------------------------------------------------------------------
            ; END OF CPM DEBLOCKING ALGORITHM
            ;-------------------------------------------------------------------------------


            ;-------------------------------------------------------------------------------
            ; START OF DEBUGGING FUNCTIONALITY
            ;-------------------------------------------------------------------------------
            ; Debug routine to print out all registers and dump a section of memory for analysis.
            ;
DEBUG:      IF ENADEBUG = 1
            LD      (DBGSTACKP),SP
            LD      SP,DBGSTACK
            ;
            PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            PUSH    AF
            PUSH    HL
            PUSH    DE
            PUSH    BC
            PUSH    AF
            LD      DE, INFOMSG
            CALL    MONPRTSTR
            POP     BC
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            LD      DE, INFOMSG2
            CALL    MONPRTSTR
            POP     BC
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            LD      DE, INFOMSG3
            CALL    MONPRTSTR
            POP     DE
            LD      A,D
            CALL    ?PRTHX
            LD      A,E
            CALL    ?PRTHX
            LD      DE, INFOMSG4
            CALL    MONPRTSTR
            POP     HL
            LD      A,H
            CALL    ?PRTHX
            LD      A,L
            CALL    ?PRTHX
            LD      DE, INFOMSG5
            CALL    MONPRTSTR
            LD      HL,(DBGSTACKP)
            LD      A,H
            CALL    ?PRTHX
            LD      A,L
            CALL    ?PRTHX
            CALL    ?NL

            LD      DE, DRVMSG
            CALL    MONPRTSTR
            LD      A, (CDISK)
            CALL    ?PRTHX

            LD      DE, FDCDRVMSG
            CALL    MONPRTSTR
            LD      A, (FDCDISK)
            CALL    ?PRTHX
           
            LD      DE, SEKTRKMSG
            CALL    MONPRTSTR
            LD      BC,(SEKTRK)
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            CALL    ?PRTS 
            LD      A,(SEKSEC)
            CALL    ?PRTHX
            CALL    ?PRTS 
            LD      A,(SEKHST)
            CALL    ?PRTHX
           
            LD      DE, HSTTRKMSG
            CALL    MONPRTSTR
            LD      BC,(HSTTRK)
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            CALL    ?PRTS 
            LD      A,(HSTSEC)
            CALL    ?PRTHX
           
            LD      DE, UNATRKMSG
            CALL    MONPRTSTR
            LD      BC,(UNATRK)
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            CALL    ?PRTS 
            LD      A,(UNASEC)
            CALL    ?PRTHX
           
            LD      DE, CTLTRKMSG
            CALL    MONPRTSTR
            LD      A,(TRACKNO)                                          ; NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            CALL    ?PRTHX
            CALL    ?PRTS 
            LD      A,(SECTORNO)
            CALL    ?PRTHX
           
            LD      DE, DMAMSG
            CALL    MONPRTSTR
            LD      BC,(DMAADDR)
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            CALL    ?NL
           
            POP     AF
            JR      C, SKIPDUMP
            LD      HL,DPBASE                                            ; Dump the startup vectors.
            LD      DE, 1000H
            ADD     HL, DE
            EX      DE,HL
            LD      HL,DPBASE
            CALL    DUMPX

            LD      HL,00000h                                            ; Dump the startup vectors.
            LD      DE, 00A0H
            ADD     HL, DE
            EX      DE,HL
            LD      HL,00000h
            CALL    DUMPX
           
            LD      HL,IBUFE                                             ; Dump the data area.
            LD      DE, 0300H 
            ADD     HL, DE
            EX      DE,HL
            LD      HL,IBUFE
            CALL    DUMPX

            LD      HL,CBASE                                             ; Dump the CCP + BDOS area.
            LD      DE,CBIOSSTART - CBASE                                
            ADD     HL, DE
            EX      DE,HL
            LD      HL,CBASE
            CALL    DUMPX

SKIPDUMP:   POP     HL
            POP     DE
            POP     BC
            POP     AF
            ;
            LD      SP,(DBGSTACKP)
            RET

            ; HL = Start
            ; DE = End
DUMPX:      LD      A,23
DUM1:       LD      (TMPCNT),A
DUM3:       LD      B,010h
            LD      C,02Fh
            CALL    NLPHL
DUM2:       CALL    SPHEX
            INC     HL
            PUSH    AF
            LD      A,(DSPXY)
            ADD     A,C
            LD      (DSPXY),A
            POP     AF
            CP      020h
            JR      NC,L0D51
            LD      A,02Eh
L0D51:      CALL    ?PRNT
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
            JR      NC,DUM7
L0D78:      DJNZ    DUM2
            LD      A,(TMPCNT)
            DEC     A
            LD      (TMPCNT),A
            JR      NZ,DUM3
DUM4:       CALL    ?CHKKY
            CP      0FFH
            JR      NZ,DUM4
            CALL    ?GETKY
            CP      'D'
            JR      NZ,DUM5
            LD      A,8
            JR      DUM1
DUM5:       CP      'U'
            JR      NZ,DUM6
            PUSH    DE
            LD      DE,00100H
            OR      A
            SBC     HL,DE
            POP     DE
            LD      A,8
            JR      DUM1
DUM6:       CP      'X'
            JR      Z,DUM7
            JR      DUMPX
DUM7:       CALL    ?NL
            RET

NLPHL:      CALL    ?NL
            CALL    ?PRTHL
            RET

            ; SPACE PRINT AND DISP ACC
            ; INPUT:HL=DISP. ADR.
SPHEX:      CALL    ?PRTS                       ; SPACE PRINT
            LD      A,(HL)
            CALL    ?PRTHX                      ; DSP OF ACC (ASCII)
            LD      A,(HL)
            RET   
           
DRVMSG:     DB      "DRV=",  000H
FDCDRVMSG:  DB      ",FDC=", 000H
SEKTRKMSG:  DB      ",S=",   000H
HSTTRKMSG:  DB      ",H=",   000H
UNATRKMSG:  DB      ",U=",   000H
CTLTRKMSG:  DB      ",C=",   000H
DMAMSG:     DB      ",D=",   000H
INFOMSG:    DB      "AF=",   NUL
INFOMSG2:   DB      ",BC=",  000H
INFOMSG3:   DB      ",DE=",  000H
INFOMSG4:   DB      ",HL=",  000H
INFOMSG5:   DB      ",SP=",  000H
            ENDIF
            ;-------------------------------------------------------------------------------
            ; END OF DEBUGGING FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; START OF STATIC LOOKUP TABLES AND CONSTANTS
            ;-------------------------------------------------------------------------------

KTBL:       ; Strobe 0           
            DB      '"'
            DB      '!'
            DB      'W'
            DB      'Q'
            DB      'A'
            DB      INSERT
            DB      NULL
            DB      'Z'
            ; Strobe 1
            DB      '$'
            DB      '#'
            DB      'R'
            DB      'E'
            DB      'D'
            DB      'S'
            DB      'X'
            DB      'C'
            ; Strobe 2
            DB      '&'
            DB      '%'
            DB      'Y'
            DB      'T'
            DB      'G'
            DB      'F'
            DB      'V'
            DB      'B'
            ; Strobe 3
            DB      '('
            DB      '\''
            DB      'I'
            DB      'U'
            DB      'J'
            DB      'H'
            DB      'N'
            DB      SPACE
            ; Strobe 4
            DB      '_'
            DB      ')'
            DB      'P'
            DB      'O'
            DB      'L'
            DB      'K'
            DB      '<'
            DB      'M'
            ; Strobe 5
            DB      '~'
            DB      '='
            DB      '{'
            DB      '`'
            DB      '*'
            DB      '+'
            DB      CURSLEFT
            DB      '>'
            ; Strobe 6
            DB      HOMEKEY
            DB      '|'
            DB      CURSRIGHT
            DB      CURSUP
            DB      CR
            DB      '}'
            DB      NULL
            DB      CURSUP     
            ; Strobe 7
            DB      '8'
            DB      '7'
            DB      '5'
            DB      '4'
            DB      '2'
            DB      '1'
            DB      DBLZERO
            DB      '0'
            ; Strobe 8
            DB      '*'
            DB      '9'
            DB      '-'
            DB      '6'
            DB      NULL
            DB      '3'
            DB      NULL
            DB      ','         

KTBLS:      ; Strobe 0          
            DB      '2'         
            DB      '1'         
            DB      'w'         
            DB      'q'         
            DB      'a'         
            DB      DELETE      
            DB      NULL        
            DB      'z'         
            ; Strobe 1          
            DB      '4'         
            DB      '3'         
            DB      'r'         
            DB      'e'         
            DB      'd'         
            DB      's'         
            DB      'x'         
            DB      'c'         
            ; Strobe 2          
            DB      '6'         
            DB      '5'         
            DB      'y'         
            DB      't'         
            DB      'g'         
            DB      'f'         
            DB      'v'         
            DB      'b'         
            ; Strobe 3          
            DB      '8'         
            DB      '7'         
            DB      'i'         
            DB      'u'         
            DB      'j'         
            DB      'h'         
            DB      'n'         
            DB      SPACE       
            ; Strobe 4          
            DB      '0'         
            DB      '9'         
            DB      'p'         
            DB      'o'         
            DB      'l'         
            DB      'k'         
            DB      ','         
            DB      'm'         
            ; Strobe 5          
            DB      '^'         
            DB      '-'         
            DB      '['         
            DB      '@'         
            DB      ':'         
            DB      ';'         
            DB      '/'         
            DB      '.'         
            ; Strobe 6          
            DB      CLRKEY      
            DB      '\\'        
            DB      CURSLEFT    
            DB      CURSDOWN    
            DB      CR          
            DB      ']'         
            DB      NULL        
            DB      '?'         

KTBLCL:     ; Strobe 0          
            DB      '2'         
            DB      '1'         
            DB      'W'         
            DB      'Q'         
            DB      'A'         
            DB      DELETE      
            DB      NULL        
            DB      'Z'         
            ; Strobe 1          
            DB      '4'         
            DB      '3'         
            DB      'R'         
            DB      'E'         
            DB      'D'         
            DB      'S'         
            DB      'X'         
            DB      'C'         
            ; Strobe 2          
            DB      '6'         
            DB      '5'         
            DB      'Y'         
            DB      'T'         
            DB      'G'         
            DB      'F'         
            DB      'V'         
            DB      'B'         
            ; Strobe 3          
            DB      '8'         
            DB      '7'         
            DB      'I'         
            DB      'U'         
            DB      'J'         
            DB      'H'         
            DB      'N'         
            DB      SPACE       
            ; Strobe 4          
            DB      '0'         
            DB      '9'         
            DB      'P'         
            DB      'O'         
            DB      'L'         
            DB      'K'         
            DB      ','         
            DB      'M'         
            ; Strobe 5          
            DB      '^'         
            DB      '-'         
            DB      '['         
            DB      '@'         
            DB      ':'         
            DB      ';'         
            DB      '/'         
            DB      '.'         
            ; Strobe 6          
            DB      CLRKEY      
            DB      '\\'        
            DB      CURSLEFT    
            DB      CURSDOWN    
            DB      CR          
            DB      ']'         
            DB      NULL        
            DB      '?'         
                                
KTBLC:      ; CTRL ON
            ; Strobe 0
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_W
            DB      CTRL_Q
            DB      CTRL_A
            DB      NOKEY
            DB      000H
            DB      CTRL_Z
            ; Strobe 1
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_R
            DB      CTRL_E
            DB      CTRL_D
            DB      CTRL_S
            DB      CTRL_X
            DB      CTRL_C
            ; Strobe 2
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_Y
            DB      CTRL_T
            DB      CTRL_G
            DB      CTRL_F
            DB      CTRL_V
            DB      CTRL_B
            ; Strobe 3
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_I
            DB      CTRL_U
            DB      CTRL_J
            DB      CTRL_H
            DB      CTRL_N
            DB      NOKEY
            ; Strobe 4
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_P
            DB      CTRL_O
            DB      CTRL_L
            DB      CTRL_K
            DB      NOKEY
            DB      CTRL_M
            ; Strobe 5
            DB      CTRL_CAPPA
            DB      CTRL_UNDSCR
            DB      ESC
            DB      CTRL_AT
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            ; Strobe 6
            DB      NOKEY
            DB      CTRL_SLASH
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_RB
            DB      NOKEY



CBIOSSIGNON:IF      BUILD_80C = 1
              DB    "** CBIOS v1.25, (C) P.D. Smart, 2019-21. Drives:",                NUL
            ELSE
              DB    "CBIOS v1.25, (C) P.D. Smart, 2019-21.   " 
              DB    "Drives:",                                                         NUL
            ENDIF
CBIOSIGNEND:IF      BUILD_80C = 1
              DB    " **",                                                         CR, NUL
            ELSE
              DB                                                                   CR, NUL
            ENDIF
NOBDOS:     DB      "No BDOS, aborting!",                                      CR, LF, NUL
CPMROMFNAME:DB      "CPM223RFS",                                                       NUL
ROMFDERRMSG:DB      "ROM FIND ERR",                                                CR, NUL
SDAVAIL:    DB      "SD",                                                              NUL
FDCAVAIL:   DB      "FDC",                                                             NUL
            ;-------------------------------------------------------------------------------
            ; END OF STATIC LOOKUP TABLES AND CONSTANTS
            ;-------------------------------------------------------------------------------

; Disk Parameter Header template.
DPBTMPL:    DW      0000H, 0000H, 0000H, 0000H, CDIRBUF

            ; Allocate space for 8 disk parameter block definitions in ROM.
            ;
            ALIGN_NOPS SCRN - (8 * 16)
;------------------------------------------------------------------------------------------------------------
; DISK PARAMETER BLOCK
;
; +----+----+------+-----+-----+------+----+----+-----+----+
; |SPT |BSH |BLM   |EXM  |DSM  |DRM   |AL0 |AL1 |CKS  |OFF |
; +----+----+------+-----+-----+------+----+----+-----+----+  
;  16B  8B   8B     8B    16B   16B    8B   8B   16B   16B
;
; -SPT is the total number of sectors per track.   
; -BSH is the data allocation block shift factor, determined by the data block allocation size.   
; -BLM is the data allocation block mask (2[BSH-1]).   
; -EXM is the extent mask, determined by the data block allocation size and the number of disk blocks.   
; -DSM determines the total storage capacity of the disk drive.   
; -DRM determines the total number of directory entries that can be stored on this drive.    
; -AL0, AL1   determine reserved directory blocks.   
; -CKS is the size of the directory check vector.   
; -OFF is the number of reserved tracks at the beginning of the (logical) disk
;
; BLS   BSH BLM  EXM (DSM < 256)  EXM (DSM > 255)
; 1,024  3    7   0                N/A
; 2,048  4   15   1                 0
; 4,096  5   31   3                 1
; 8,192  6   63   7                 3
; 16,384 7  127  15                 7
;------------------------------------------------------------------------------------------------------------

; MZ-800 drive but using both heads per track rather than the original
; 1 head for all  tracks on side A switching to second head and
; restarting at track 0.
DPB0:       DW      64                                                   ; SPT - 128 bytes sectors per track
            DB      4                                                    ; BSH - block shift factor
            DB      15                                                   ; BLM - block mask
            DB      1                                                    ; EXM - Extent mask
            DW      155                                                  ; DSM - Storage size (blocks - 1)
            DW      63                                                   ; DRM - Number of directory entries - 1
            DB      128                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      16                                                   ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      1                                                    ; OFF - Reserved tracks
            DB      6                                                    ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 10 = ROM, 11 = SD Card, 01 = Unused
                                                                         ;       Bit 5   = ROMFS Image, 0 = DRV0, 1 = DRV1
                                                                         

; Rom Filing System File Image acting as a drive.
; There are two definitions, 1 for each ROM drive, they can be identical but the CFG bit 5 will differ.
DPB1:       DW      128                                                  ; SPT - 128 bytes sectors per track
            DB      4     ; 3                                            ; BSH - block shift factor                    (Set to 3 for a 240K RomRFS Image).
            DB      15    ; 7                                            ; BLM - block mask                            (Set to 7 for a 240K RomRFS Image).
            DB      0                                                    ; EXM - Extent mask
            DW      159   ; 240                                          ; DSM - Storage size (blocks - 1)             (Set to 240 for a 240K RomRFS Image).
            DW      63    ; 31                                           ; DRM - Number of directory entries - 1
            DB      128                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      0     ; 16                                           ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      0                                                    ; OFF - Reserved tracks
            DB      16                                                   ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 10 = ROM, 11 = SD Card, 01 = Unused
                                                                         ;       Bit 5   = ROMFS Image, 0 = DRV0, 1 = DRV1

; Rom Filing System File Image acting as a drive.
; There are two definitions, 1 for each ROM drive, they can be identical but the CFG bit 5 will differ.
DPB2:       DW      128                                                  ; SPT - 128 bytes sectors per track
            DB      4     ; 3                                            ; BSH - block shift factor                    (Set to 3 for a 240K RomRFS Image).
            DB      15    ; 7                                            ; BLM - block mask                            (Set to 7 for a 240K RomRFS Image).
            DB      0                                                    ; EXM - Extent mask
            DW      159   ; 240                                          ; DSM - Storage size (blocks - 1)             (Set to 240 for a 240K RomRFS Image).
            DW      63    ; 31                                           ; DRM - Number of directory entries - 1
            DB      128                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      0     ; 16                                           ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      0                                                    ; OFF - Reserved tracks
            DB      48                                                   ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 10 = ROM, 11 = SD Card, 01 = Unused
                                                                         ;       Bit 5   = ROMFS Image, 0 = DRV0, 1 = DRV1


; 1.44MB Floppy
DPB3:       DW      144                                                  ; SPT - 128 bytes sectors per track (= 36 sectors of 512 bytes)
            DB      4                                                    ; BSH - block shift factor
            DB      15                                                   ; BLM - block mask
            DB      0                                                    ; EXM - Extent mask
            DW      719                                                  ; DSM - Storage size (blocks - 1)
            DW      127                                                  ; DRM - Number of directory entries - 1
            DB      192                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      32                                                   ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      0                                                    ; OFF - Reserved tracks
            DB      7                                                    ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 10 = ROM, 11 = SD Card, 01 = Unused
                                                                         ;       Bit 5   = ROMFS Image, 0 = DRV0, 1 = DRV1

; 16Mb SD Hard Disk drives (not hot-swappable).
; This drive has 2048 blocks (small due to size of RAM needed, more blocks more RAM) of 8192 bytes = 16Mb
; There are 1024 directory entries thus AL0/AL1 needs to ave the top four bits set as each block can hold 256 directory entries.
; This implementation limits the sectors per track to 255 (8 bit) even though CPM supports 16bit sectors, so the
; physical drive make up is: 32 Sectors (128 CPM sectors of 128 bytes each) x 1024 tracks, 1 head = 16777216bytes.
; This size has been chosen to maximise the use of the SD Card space and the number of files/programs which can be online
; at the same time. On the MZ80A, memory is more of a premium so keeping the DRM as low as possible saves RAM.
;
DPB4:       DW      128                                                  ; SPT - 128 bytes sectors per track (= 36 sectors of 512 bytes)
            DB      6                                                    ; BSH - block shift factor
            DB      63                                                   ; BLM - block mask
            DB      3                                                    ; EXM - Extent mask
            DW      2047                                                 ; DSM - Storage size (blocks - 1)
            DW      511                                                  ; DRM - Number of directory entries - 1
            DB      192                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      0                                                    ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      0                                                    ; OFF - Reserved tracks
            DB      27                                                   ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 10 = ROM, 11 = SD Card, 01 = Unused
                                                                         ;       Bit 5   = ROMFS Image, 0 = DRV0, 1 = DRV1


; Rom Filing System RAM Drive.
; If the RFS v2.x board has the optional 512KRAM installed in slot 3 then this definition is used to create a RAM based disk drive within it.
;
DPB5:       DW      128                                                  ; SPT - 128 bytes sectors per track
            DB      4     ; 3                                            ; BSH - block shift factor                    (Set to 3 for a 240K RomRFS Image).
            DB      15    ; 7                                            ; BLM - block mask                            (Set to 7 for a 240K RomRFS Image).
            DB      0                                                    ; EXM - Extent mask
            DW      159   ; 240                                          ; DSM - Storage size (blocks - 1)             (Set to 240 for a 240K RomRFS Image).
            DW      63    ; 31                                           ; DRM - Number of directory entries - 1
            DB      128                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      0     ; 16                                           ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      0                                                    ; OFF - Reserved tracks
            DB      8                                                    ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 10 = ROM, 11 = SD Card, 01 = RAM
                                                                         ;       Bit 5   = ROMFS Image, 0 = DRV0, 1 = DRV1

            
            ALIGN_NOPS SCRN
