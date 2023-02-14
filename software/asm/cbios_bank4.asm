;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cbios_bank4.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM BIOS System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade for the CPM CBIOS in order to preserve RAM for actual
;-                  CPM TPA programs.
;-
;- Credits:         
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

            ;============================================================
            ;
            ; USER ROM CPM CBIOS BANK 4 - Floppy Disk Controller functions.
            ;
            ;============================================================
            ORG      UROMADDR

            ;-----------------------------------------------------------------------------------------
            ; Common code spanning all banks to ensure that a Monitor is selected upon power up/reset.
            ;-----------------------------------------------------------------------------------------
            NOP
            LD      B,16                                                 ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
CBIOS1_0:   LD      A,(BNKCTRLRST)
            DJNZ    CBIOS1_0                                             ; Apply the default number of coded latch reads to enable the bank control registers.
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
            JP      ?DSKINIT                                             ; DSKINIT
            JP      ?SETDRVCFG                                           ; SETDRVCFG
            JP      ?SETDRVMAP                                           ; SETDRVMAP
            JP      ?SELDRIVE                                            ; SELDRIVE
            JP      ?GETMAPDSK                                           ; GETMAPDSK
            JP      ?DSKREAD                                             ; DSKREAD
            JP      ?DSKWRITE                                            ; DSKWRITE


            ;-------------------------------------------------------------------------------
            ; START OF FDC CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;------------------------------------------------------------------------------------------------
            ; Initialise drive and reset flags, Set motor off
            ;
            ;------------------------------------------------------------------------------------------------
?DSKINIT:   XOR     A                                                        
            OUT     (FDC_MOTOR),A                                        ; Motor off
            LD      (TRK0FD1),A                                          ; Track 0 flag drive 1
            LD      (TRK0FD2),A                                          ; Track 0 flag drive 2
            LD      (TRK0FD3),A                                          ; Track 0 flag drive 3
            LD      (TRK0FD4),A                                          ; Track 0 flag drive 4
            LD      (MOTON),A                                            ; Motor on flag
            LD      (MTROFFTIMER),A                                      ; Clear the down counter for motor off.
            LD      A,(FDCROMADDR)                                       ; Check to see if the FDC AFI ROM is installed, use this as
            OR      A                                                    ; an indicator that the FDC is present.
            RET

            ; Function to create a mapping table between a CPM disk and a physical disk.
?SETDRVMAP: PUSH    HL
            PUSH    DE
            PUSH    BC

            ; Zero out the map.
            LD      B,MAXDISKS
            LD      HL,DISKMAP
            LD      A,0FFH
SETDRVMAP1: LD      (HL),A
            INC     HL
            DJNZ    SETDRVMAP1
            LD      HL,DISKMAP                                           ; Place in the Map for next drive.
            ; Now go through each disk from the Disk Parameter Base list.
            LD      B,0                                                  ; Disk number count = CDISK.
            LD      DE,0                                                 ; Physical disk number, D = FDC, E = SDC.
SETDRVMAP2: LD      A,B
            CP      MAXDISKS
            JR      Z,SETDRVMAP6
            INC     B
            PUSH    HL
            PUSH    DE
            PUSH    BC
            ; For the Disk in A, find the parameter table.
            RLC     A                                                    ; *2
            RLC     A                                                    ; *4
            RLC     A                                                    ; *8
            RLC     A                                                    ; *16
            LD      HL,DPBASE                                            ; Base of disk description block.
            LD      B,0
            LD      C,A 
            ADD     HL,BC                                                ; HL contains address of actual selected disk block.
            LD      C,10
            ADD     HL,BC                                                ; HL contains address of pointer to disk parameter block.
            LD      E,(HL)
            INC     HL
            LD      D,(HL)                                               ; DE contains address of disk parameter block.
            EX      DE,HL
            LD      A,(HL)
            LD      E,A
            LD      BC,15
            ADD     HL,BC                                                ; Move to configuuration byte which identifies the disk type.
            ;
            POP     BC
            POP     DE
            LD      A,(HL)
            POP     HL

            BIT     4,A                                                  ; Disk type = FDC?
            JR      NZ,SETDRVMAP2A        
            BIT     3,A
            JR      Z,SETDRVMAP4                                         ; Is this an FDC controlled disk, if so store the mapping number in the map unchanged.
            ;
            LD      A,E
            OR      020H                                                 ; This is a RAM drive, add 020H to the mapping number and store.
            INC     E
            JR      SETDRVMAP5
            ;
SETDRVMAP2A:BIT     3,A                                                  ; Is this an SD Card disk, if so, add 080H to the mapping number and store.
            JR      Z,SETDRVMAP3
            LD      A,E
            OR      080H
            INC     E
            JR      SETDRVMAP5
SETDRVMAP3: LD      A,E                                                  ; This is a ROM drive, add 040H to the mapping number and store.
            OR      040H
            INC     E
            JR      SETDRVMAP5
            ;
SETDRVMAP4: LD      A,D
            INC     D
SETDRVMAP5: LD      (HL),A
            INC     HL
            JR      SETDRVMAP2
            ;
SETDRVMAP6: POP     BC
            POP     DE
            POP     HL
            RET

            ; Function to setup the drive parameters according to the CFG byte in the disk parameter block.
?SETDRVCFG: PUSH    HL
            PUSH    DE
            PUSH    BC
            LD      A,(CDISK)
            RLC     A                                                    ; *2
            RLC     A                                                    ; *4
            RLC     A                                                    ; *8
            RLC     A                                                    ; *16
            LD      HL,DPBASE                                            ; Base of disk description block.
            LD      B,0
            LD      C,A 
            ADD     HL,BC                                                ; HL contains address of actual selected disk block.
            LD      C,10
            ADD     HL,BC                                                ; HL contains address of pointer to disk parameter block.
            LD      E,(HL)
            INC     HL
            LD      D,(HL)                                               ; DE contains address of disk parameter block.
            EX      DE,HL
            LD      A,(HL)
            LD      E,A

            LD      BC,15
            ADD     HL,BC                                                ; Move to configuuration byte.
            XOR     A
            BIT     2,(HL)
            JR      Z,SETDRV0
            INC     A
SETDRV0:    LD      (INVFDCDATA),A                                       ; Data inversion is set according to drive parameter.
            LD      A,4
            BIT     1,(HL)
            JR      Z,SETDRV1
            LD      A,2
            BIT     0,(HL)
            JR      Z,SETDRV1
            LD      A,1
SETDRV1:    LD      (SECTORCNT),A                                        ; Set the disk sector size.
            LD      D,A
            CP      4
            LD      A,E
            JR      Z,SETDRV1A
            OR      A
            RR      A
            LD      E,A
            LD      A,D
            CP      2
            LD      A,E
            JR      Z,SETDRV1A
            OR      A
            RR      A                                                    ; Convert sectors per track from 128 bytes to 256 byte sectors.
SETDRV1A:   INC     A                                                    ; Add 1 to ease comparisons.
            LD      (SECPERTRK),A                                        ; Only cater for 8bit, ie. 256 sectors.
            DEC     A
            OR      A
            RR      A
            INC     A                                                    ; Add 1 to ease comparisons.
            LD      (SECPERHEAD),A                                       ; Convert sectors per track to sectors per head.
            ;
            XOR     A                                                    ; Disk type = FDC
            BIT     4,(HL)
            JR      NZ,SETDRV1B                                          ; 4 = 1?
            BIT     3,(HL)
            JR      Z,SETDRV2                                            ; 3 = 0 - FDC
            LD      A,DSKTYP_RAM
            JR      SETDRV2
SETDRV1B:   LD      A,DSKTYP_ROM                                         ; Disk type = ROMFS
            BIT     3,(HL)                                               ; 3 = 0? Thus 1:0 = ROM
            JR      Z,SETDRV2
            LD      A,DSKTYP_SDC                                         ; Disk type = SD Card, ie. 1:1 
SETDRV2:    LD      (DISKTYPE),A
            POP     BC
            POP     DE
            POP     HL
            RET

            ; Method to get the current disk drive mapped to the correct controller.
            ; The CPM CDISK is mapped via MAPDISK[CDISK] and the result:
            ; Bit 7 = 1 - SD Card drive.
            ; Bit 6 = 1 - ROM Drive.
            ; BIT 7:6 = 00 - Floppy drive.
?GETMAPDSK: PUSH    HL
            PUSH    BC
            LD      A,(CDISK)
            LD      HL,DISKMAP
            LD      C,A
            LD      B,0
            ADD     HL,BC
            LD      A,(HL)                                               ; Get the physical number after mapping from the CDISK.
            POP     BC
            POP     HL
            RET

            ; Select FDC drive (make active) based on value in DISKMAP[CDISK].
?SELDRIVE:  CALL    ?GETMAPDSK
            CP      020H                                                 ; Anything with bit 7:5 set is not an FDC drive.
            RET     NC                                                   ; This isnt a physical floppy disk, no need to perform any actions, exit.
            LD      (FDCDISK),A
            CALL    DSKMTRON                                             ; yes, set motor on and wait
            LD      A,(FDCDISK)                                          ; select drive no
            OR      084H                                                     
            OUT     (FDC_MOTOR),A                                        ; Motor on for drive 0-3
            XOR     A                                                        
            LD      (FDCCMD),A                                           ; clr latest FDC command byte
            LD      HL,00000H                                                
SELDRV2:    DEC     HL                                                       
            LD      A,H                                                      
            OR      L                                                        
            JP      Z,SELDRVERR                                          ; Reset and print message that this is not a valid disk.
            IN      A,(FDC_STR)                                          ; Status register.
            CPL                                                              
            RLCA                                                             
            JR      C,SELDRV2                                            ; Wait on Drive Ready Bit (bit 7)
            LD      A,(FDCDISK)                                          ; Drive number
            LD      C,A
            LD      HL,TRK0FD1                                           ; 1 track 0 flag for each drive
            LD      B,000H                                                   
            ADD     HL,BC                                                ; Compute related flag 1002/1003/1004/1005
            BIT     0,(HL)                                                   
            JR      NZ,SELDRV3                                           ; If the drive hasnt been intialised to track 0, intialise and set flag.
            CALL    DSKSEEKTK0                                           ; Seek track 0.
            SET     0,(HL)                                               ; Set bit 0 of trk 0 flag
SELDRV3:    CALL    ?SETDRVCFG
            RET

            ; Turn disk motor on if not already running.
DSKMTRON:   LD      A,255                                                ; Ensure motor is kept running whilst we read/write.
            LD      (MTROFFTIMER),A
            LD      A,(MOTON)                                            ; Test to see if motor is on, if it isnt, switch it on.
            RRCA
            JR      NC, DSKMOTORON
            RET
DSKMOTORON: PUSH    BC
            LD      A,080H
            OUT     (FDC_MOTOR),A                                        ; Motor on
            LD      B,010H                                               ; 
DSKMTR2:    CALL    MTRDELAY                                             ; 
            DJNZ    DSKMTR2                                              ; Wait until becomes ready.
            LD      A,001H                                               ; Set motor on flag.
            LD      (MOTON),A                                            ; 
            POP     BC
            RET      

FDCDLY1:    PUSH    DE
            LD      DE,00007H
            JP      MTRDEL2

MTRDELAY:   PUSH    DE
            LD      DE,01013H
MTRDEL2:    DEC     DE
            LD      A,E
            OR      D
            JR      NZ,MTRDEL2                                           
            POP     DE
            RET    

?DSKWRITE:  LD      A,MAXWRRETRY
            LD      (RETRIES),A
            LD      A,(SECTORCNT)
            LD      B,A
            LD      A,(HSTSEC)
DSKWRITE0A: DJNZ    DSKWRITE0B
            JR      DSKWRITE1
DSKWRITE0B: OR      A
            RL      A
            JR      DSKWRITE0A
DSKWRITE1:  INC     A
            LD      (SECTORNO), A                                        ; Convert from Host 512 byte sector into local sector according to paraameter block.
            LD      HL,(HSTTRK)
            LD      (TRACKNO),HL

DSKWRITE2:  CALL    SETTRKSEC                                            ; Set current track & sector, get load address to HL
DSKWRITE3:  CALL    SETHEAD                                              ; Set side reg
            CALL    SEEK                                                 ; Command 1b output (seek)
            JP      NZ,SEEKRETRY                                         ; 
            CALL    OUTTKSEC                                             ; Set track & sector reg

            LD      IX, 0F3FEH                                           ; As below. L03FE
            LD      IY,WRITEDATA                                         ; Write sector from memory.
            DI     
            ;
            LD      A,0B4H                                               ; Write Sector multipe with Side Compare for side 1.
            CALL    DISKCMDWAIT
            LD      D,2                                                  ; Regardless of 4x128, 2x256 or 1x512, we always read 512bytes by the 2x INI instruction with B=256.
STRTDATWR:  LD      B,0                                                  ; 256 bytes to load.
            JP      (IX)

WRITEDATA:  OUTI    
            JP      NZ, 0F3FEH                                           ; This is crucial, as the Z80 is running at 2MHz it is not fast enough so needs
                                                                         ; hardware acceleration in the form of a banked ROM, if disk not ready jumps to IX, if
                                                                         ; data ready, jumps to IY.
            DEC     D
            JP      NZ,0F3FEH                                            ; If we havent read all sectors to form a 512 byte block, go for next sector.
            JR      DATASTOP      

            ; Read disk starting at the first logical sector in param block 1009/100A
            ; Continue reading for the given size 100B/100C and store in the location 
            ; Pointed to by the address stored in the parameter block. 100D/100E
?DSKREAD:   LD      A,MAXRDRETRY
            LD      (RETRIES),A
            LD      A,(SECTORCNT)
            LD      B,A
            LD      A,(HSTSEC)
DSKREAD0A:  DJNZ    DSKREAD0B
            JR      DSKREAD1
DSKREAD0B:  OR      A
            RL      A
            JR      DSKREAD0A
DSKREAD1:   INC     A
            LD      (SECTORNO), A                                        ; Convert from Host 512 byte sector into local sector according to paraameter block.
            LD      HL,(HSTTRK)
            LD      (TRACKNO),HL
DSKREAD2:   CALL    SETTRKSEC                                            ; Set current track & sector, get load address to HL
DSKREAD3:   CALL    SETHEAD                                              ; Set side reg
            CALL    SEEK                                                 ; Command 1b output (seek)
            JP      NZ,SEEKRETRY                                         ; 
            CALL    OUTTKSEC                                             ; Set track & sector reg
            LD      IX, 0F3FEH                                           ; As below. L03FE
            LD      IY,READDATA                                          ; Read sector into memory.
            DI     
            ;
            LD      A,094H                                               ; Read Sector multiple with Side Compare for side 1.
            CALL    DISKCMDWAIT
            LD      D,2                                                  ; Regardless of 4x128, 2x256 or 1x512, we always read 512bytes by the 2x INI instruction with B=256.
STRTDATRD:  LD      B,0                                                  ; 256 bytes to load.
            JP      (IX)

            ; Get data from disk sector to staging area.
READDATA:   INI     
            JP      NZ,0F3FEH                                            ; This is crucial, as the Z80 is running at 2MHz it is not fast enough so needs
                                                                         ; hardware acceleration in the form of a banked ROM, if disk not ready jumps to IX, if
                                                                         ; data ready, jumps to IY.
            DEC     D
            JP      NZ,0F3FEH                                            ; If we havent read all sectors to form a 512 byte block, go for next sector.
            ;
            ;
DATASTOP:   LD      A,0D8H                                               ; Force interrupt command, Immediate interrupt (I3 bit 3=1) of multiple sector read.
            CPL    
            OUT     (FDC_CR),A
            CALL    WAITRDY                                              ; Wait for controller to become ready, acknowledging interrupt.
            IN      A,(FDC_STR)                                          ; Check for errors.
            CPL     
            AND     0FFH
            JR      NZ,SEEKRETRY   
UPDSECTOR:  PUSH    HL
            LD      A,(SECTORCNT)
            LD      HL,SECTORNO
            ADD     A,(HL)                                               ; Update sector to account for sectors read. NB. All reads will start at such a position
            LD      (HL), A                                              ; that a read will not span a track or head. Ensure that disk formats meet an even 512byte format.
            POP     HL
MOTOROFF:   LD      A,MTROFFMSECS                                         ; Schedule motor to be turned off.
            LD      (MTROFFTIMER),A
            XOR     A                                                    ; Successful read, return 0
            EI
            RET    

SEEKRETRY:  LD      B,A                                                  ; Preserve the FDC Error byte.
            LD      A,(RETRIES)
            DEC     A
            LD      (RETRIES),A
            LD      A,B
            JP      Z,RETRIESERR
            CALL    DSKSEEKTK0
            LD      A, (READOP) 
            OR      A
            LD      A,(TRACKNO)                                          ; NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            JP      Z, DSKWRITE2                                         ; Try write again.
            JP      DSKREAD2                                             ; Try the read again.

DISKCMDWAIT:LD      (FDCCMD),A
            CPL    
            OUT     (FDC_CR),A
            CALL    WAITBUSY
            RET     

            ; Send a command to the disk controller.
DSKCMD:     LD      (FDCCMD),A                                           ; Store latest FDC command.
            CPL                                                          ; Compliment it (FDC bit value is reversed).
            OUT     (FDC_CR),A                                           ; Send command to FDC.
            CALL    WAITRDY                                              ; Wait to become ready.
            IN      A,(FDC_STR)                                          ; Get status register.
            CPL                                                          ; Inverse (FDC is reverse bit logic).
            RET   

            ; Seek to programmed track.
SEEK:       LD      A,01BH                                               ; Seek command, load head, verify stepping 6ms.
            CALL    DSKCMD
            AND     099H
            RET

            ; Set current track & sector, get load address to HL
SETTRKSEC:  CALL    ?SELDRIVE
            LD      A,(TRACKNO)                                          ; NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            LD      HL, HSTBUF
            RET     

            ; Compute side/head.
SETHEAD:    CPL                                                          ; 
            OUT     (FDC_DR),A                                           ; Output track no for SEEK command.
            PUSH    HL
            LD      HL,SECPERHEAD
            LD      A,(SECTORNO)                                         ; Check sector, if greater than sector per track, change head.
            CP      (HL)
            POP     HL
            JR      NC,SETHD2                                            ; Yes, even, set side/head 1
            LD      A,001H                                               ; No, odd, set side/head 0
            JR      SETHD3                   

            ; Set side/head register.
SETHD2:     XOR     A                                                    ; Side 0
SETHD3:     CPL                                                          ; Side 1
            OUT     (FDC_SIDE),A                                         ; Side/head register.
            RET     

            ; Set track and sector register.
OUTTKSEC:   PUSH    HL
            LD      HL,SECPERHEAD
            ;
            LD      C,FDC_DR                                             ; Port for data retrieval in the INI instruction in main block.                 
            LD      A,(TRACKNO)                                          ; Current track number, NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            CPL                             
            OUT     (FDC_TR),A                                           ; Track reg
            ;
            LD      A,(SECTORNO)                                         ; Current sector number
            CP      (HL)
            JR      C,OUTTKSEC2
            SUB     (HL)
            INC     A                                                    ; Account for the +1 added to ease comparisons.
OUTTKSEC2:  CPL                             
            OUT     (FDC_SCR),A                                          ; Sector reg
            POP     HL
            RET                       

            ; Seek to track 0.
DSKSEEKTK0: CALL    DSKMTRON                                             ; Make sure disk is spinning.
            LD      A,00BH                                               ; Restore command, seek track 0.
            CALL    DSKCMD                                               ; Send command to FDC.
            AND     085H                                                 ; Process result.
            XOR     004H   
            RET     Z      
            JP      DSKSEEKERR

            ; Wait for the drive to become ready.
WAITRDY:    PUSH    DE
            PUSH    HL
            CALL    FDCDLY1
            LD      E,007H
WAITRDY2:   LD      HL,00000H
WAITRDY3:   DEC     HL
            LD      A,H
            OR      L
            JR      Z,WAITRDY4                                           
            IN      A,(FDC_STR)
            CPL     
            RRCA    
            JR      C,WAITRDY3                                          
            POP     HL
            POP     DE
            RET     

WAITRDY4:   DEC     E
            JR      NZ,WAITRDY2                                        
            POP     HL
            POP     DE
            JP      WAITRDYERR

WAITBUSY:   PUSH    DE
            PUSH    HL
            CALL    FDCDLY1
            LD      E,007H                                               ; 7 Chances of a 16bit down count delay waiting for DRQ.
WAITBUSY2:  LD      HL,00000H
WAITBUSY3:  DEC     HL
            LD      A,H
            OR      L
            JR      Z,WAITBUSY4                                          ; Down counter expired, decrement retries, error on 0.
            IN      A,(FDC_STR)                                          ; Get the FDC Status
            CPL                                                          ; Switch to positive logic.
            RRCA                                                         ; Shift Busy flag into Carry.
            JR      NC,WAITBUSY3                                         ; Busy not set, decrement counter and retry.
            POP     HL
            POP     DE
            RET     

WAITBUSY4:  DEC     E
            JR      NZ,WAITBUSY2                                         
            POP     HL
            POP     DE
            JP      DSKERR


            ; Error processing. Consists of printing a message followed by debug data (if enabled) and returning with carry set
            ; to indicate error.
DSKERR:     LD      DE,LOADERR                                           ; Loading error message
            JR      HDLERROR                                             

SELDRVERR:  LD      DE,SELDRVMSG                                         ; Select drive error message.
            JR      HDLERROR                                              
            
WAITRDYERR: LD      DE,WAITRDYMSG                                        ; Waiting for ready timeout error message.
            JR      HDLERROR                                               
 
DSKSEEKERR: LD      DE,DSKSEEKMSG                                        ; Disk seek to track error message.
            JR      HDLERROR                                                

RETRIESERR: BIT     2,A                                                  ; Data overrun error if 1.
            LD      DE,DATAOVRMSG
            JR      NZ, RETRIESERR2
            BIT     3,A                                                  ; CRC error if 1.
            LD      DE,CRCERRMSG
            JR      NZ,RETRIESERR2
            LD      DE,RETRIESMSG                                        ; Data sector read error message.
RETRIESERR2:

            ; Process error, dump debug data and return fail code.
HDLERROR:   LD      HL,MSGSTRBUF                                         ; Copy the error messae
HOLERR1:    LD      A,(DE)
            LD      (HL),A
            CP      NUL
            JR      Z,HOLERR2
            INC     DE
            INC     HL
            JR      HOLERR1
HOLERR2:    LD      DE,MSGSTRBUF
HOLPRTSTR:  LD      A,(DE)
            OR      A
            JR      Z,HOLERR3
            INC     DE
HOLPRTSTR2: LD      HL,QPRNT
            PUSH    AF
            LD      A,ROMBANK9 << 4 | ROMBANK11                          ; Call CBIOS Bank 2 from CBIOS Bank 4
            CALL    BANKTOBANK
            JR      HOLPRTSTR
HOLERR3:    XOR     A
            CALL    ?DSKINIT
            CALL    DSKMTRON
            LD      A,001H                                               ; Indicate error by setting 1 in A register.
            EI
            RET

            ;-------------------------------------------------------------------------------
            ; END OF FDC CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------


            ;--------------------------------------
            ;
            ; Message table
            ;
            ;--------------------------------------
LOADERR:    DB      "DISK ERROR - LOADING",         CR, NUL
SELDRVMSG:  DB      "DISK ERROR - SELECT",          CR, NUL
WAITRDYMSG: DB      "DISK ERROR - WAIT",            CR, NUL
DSKSEEKMSG: DB      "DISK ERROR - SEEK",            CR, NUL
RETRIESMSG: DB      "DISK ERROR - RETRIES",         CR, NUL
DATAOVRMSG: DB      "DISK ERROR - DATA OVERRUN",    CR, NUL
CRCERRMSG:  DB      "DISK ERROR - CRC ERROR",       CR, NUL

            ; Align to end of bank.
            ALIGN   UROMADDR + 07F8h
            ORG     UROMADDR + 07F8h
            DB      0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
