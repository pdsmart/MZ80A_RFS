;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_bank1.asm
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

           ;============================================================
           ;
           ; USER ROM BANK 1 - Floppy Disk Controller functions.
           ;
           ;============================================================
           ORG      UROMADDR

           ;--------------------------------
           ; Common code spanning all banks.
           ;--------------------------------
           NOP
           LD      B,16                                                      ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
ROMFS1_0:  LD      A,(BNKCTRLRST)
           DJNZ    ROMFS1_0                                                  ; Apply the default number of coded latch reads to enable the bank control registers.
           LD      A,BNKCTRLDEF                                              ; Set coded latch, SDCS high, BBMOSI to high and BBCLK to high which enables SDCLK.
           LD      (BNKCTRL),A
           NOP
           NOP
           NOP
           XOR     A                                                         ; We shouldnt arrive here after a reset, if we do, select UROM bank 0
           LD      (BNKSELMROM),A
           NOP
           NOP
           NOP
           LD      (BNKSELUSER),A                                            ; and start up - ie. SA1510 Monitor - this occurs as User Bank 0 is enabled and the jmp to 0 is coded in it.
           ;
           ; No mans land... this should have switched to Bank 0 and at this point there is a jump to 00000H.
           JP      00000H                                                    ; This is for safety!!

           ;------------------------------------------------------------------------------------------
           ; Bank switching code, allows a call to code in another bank.
           ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
           ;------------------------------------------------------------------------------------------
           ALIGN_NOPS UROMBSTBL
           ;
BKSW1to0:  PUSH     AF
           LD       A, ROMBANK1                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK0                                              ; Required bank to call.
           JR       BKSW1_0
BKSW1to1:  PUSH     AF
           LD       A, ROMBANK1                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK1                                              ; Required bank to call.
           JR       BKSW1_0
BKSW1to2:  PUSH     AF
           LD       A, ROMBANK1                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK2                                              ; Required bank to call.
           JR       BKSW1_0
BKSW1to3:  PUSH     AF
           LD       A, ROMBANK1                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK3                                              ; Required bank to call.
           JR       BKSW1_0
BKSW1to4:  PUSH     AF
           LD       A, ROMBANK1                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK4                                              ; Required bank to call.
           JR       BKSW1_0
BKSW1to5:  PUSH     AF
           LD       A, ROMBANK1                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK5                                              ; Required bank to call.
           JR       BKSW1_0
BKSW1to6:  PUSH     AF
           LD       A, ROMBANK1                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK6                                              ; Required bank to call.
           JR       BKSW1_0
BKSW1to7:  PUSH     AF
           LD       A, ROMBANK1                                              ; Calling bank (ie. us).
           PUSH     AF
           LD       A, ROMBANK7                                              ; Required bank to call.
           ;
BKSW1_0:   PUSH     HL                                                       ; Place function to call on stack
           LD       HL, BKSWRET1                                             ; Place bank switchers return address on stack.
           EX       (SP),HL
           LD       (TMPSTACKP),SP                                           ; Save the stack pointer as some old code corrupts it.
           LD       (BNKSELUSER), A                                          ; Repeat the bank switch B times to enable the bank control register and set its value.
           JP       (HL)                                                     ; Jump to required function.
BKSWRET1:  POP      AF                                                       ; Get bank which called us.
           LD       (BNKSELUSER), A                                          ; Return to that bank.
           POP      AF
           RET      

FDCCMD     EQU      01000H
MOTON      EQU      01001H
TRK0FD1    EQU      01002H
TRK0FD2    EQU      01003H
TRK0FD3    EQU      01004H
TRK0FD4    EQU      01005H
RETRIES    EQU      01006H
BPARA      EQU      01008H

           ;-------------------------------------------------------------------------------
           ; START OF FLOPPY DISK CONTROLLER FUNCTIONALITY
           ;-------------------------------------------------------------------------------

           ; Method to check if the floppy interface ROM is present and if it is, jump to its entry point.
           ;
FDCK:      CALL     FDCKROM                                                  ; Check to see if the Floppy ROM is present, exit if it isnt.
           CALL     Z,0F000h
           RET                                ; JP       CMDCMPEND
FDCKROM:   LD       A,(0F000h)
           OR       A
           RET

FLOPPY:    PUSH     DE                                                       ; Preserve pointer to input buffer.
           LD       DE,BPARA                                                 ; Copy disk parameter block into RAM work area. (From)
           LD       HL,PRMBLK                                                ; (To)
           LD       BC,0000BH                                                ; 11 bytes of config data.
           LDIR                                                              ; BC=0, HL=F0E8, DE=1013
           POP      DE                                                       ; init 1001-1005, port $DC mit $00
           LD       A,(DE)                                                   ; If not at the end of the line, then process as the boot disk number.
           CP       00Dh                                                     ; 
           JR       NZ,GETBOOTDSK                                            ; 
           CALL     DSKINIT                                                  ; Initialise disk and flags.
L000F:     LD       DE,MSGBOOTDRV                                            ; 
           LD       HL,PRINTMSG
           CALL     BKSW1to6
           LD       DE,011A3H                                                ; 
           CALL     GETL                                                     ; 
           LD       A,(DE)                                                   ; 
           CP       01BH                                                     ; Check input value is in range 1-4.
           JP       Z,SS                                                     ; 
           LD       HL,0000CH                                                ; 
           ADD      HL,DE                                                    ; 
           LD       A,(HL)                                                   ; 
           CP       00DH                                                     ; 
           JR       Z,L003A                                                  ; 
GETBOOTDSK:CALL     HEX                                                      ; Convert number to binary
           JR       C,L000F                                                  ; If illegal, loop back and re-prompt.
           DEC      A                                                        ; 
           CP       004H                                                     ; Check in range, if not loop back.
           JR       NC,L000F                                                 ; 
           LD       (BPARA),A                                                ; Store in parameter block.
L003A:     LD       IX,BPARA                                                 ; Point to drive number.,
           CALL     DSKREAD                                                  ; Read sector 1 of trk 0
           LD       HL,0CE00H                                                ; Now compare the first 7 bytes of what was read to see if this is a bootable disk.
           LD       DE,DSKID                                                 ; 
           LD       B,007H                                                   ; 
L0049:     LD       C,(HL)                                                   ; 
           LD       A,(DE)                                                   ; 
           CP       C                                                        ; 
           JP       NZ,L008C                                                 ; If NZ then this is not a master disk, ie not bootable, so error exit with message.
           INC      HL                                                       ; 
           INC      DE                                                       ; 
           DJNZ     L0049                                                    ; 
           LD       DE,MSGIPLLOAD                                            ; 
           LD       HL,PRINTMSG
           CALL     BKSW1to6
           LD       DE,0CE07H                                                ; Program name stored at 8th byte in boot sector.
           LD       HL,PRTFN
           CALL     BKSW1to6
           LD       HL,(0CE16H)                                              ; Get the load address
           LD       (IX+005H),L                                              ; And store in parameter block at 100D/100E
           LD       (IX+006H),H                                              ; 
           INC      HL
           DEC      HL
           JR       NZ, NOTCPM                                               ; If load address is 0 then where loading CPM.
    ;       LD       A,(MEMSW)                                                ; Page out ROM.
NOTCPM:    LD       HL,(0CE14H)                                              ; Get the size
           LD       (IX+003H),L                                              ; And store in parameter block at 100B/100C
           LD       (IX+004H),H                                              ; 
           LD       HL,(0CE1EH)                                              ; Get logical sector number
           LD       (IX+001H),L                                              ; And store in parameter block at 1009/100A
           LD       (IX+002H),H                                              ; 
           CALL     DSKREAD                                                  ; Read the required data and store in memory.
           CALL     DSKINIT                                                  ; Reset the disk ready for next operation.
           LD       HL,(0CE18H)                                              ; Get the execution address
           JP       (HL)                                                     ; And execute.

DSKLOADERR:LD       DE,MSGLOADERR                                            ; Loading error message
           JR       L008F                                                    ; (+003h)

L008C:     LD       DE,MSGDSKNOTMST                                          ; This is not a boot/master disk message.
L008F:     LD       HL,PRINTMSG
           CALL     BKSW1to6
           LD       DE,ERRTONE                                               ; Play error tone.
           CALL     MELDY
           ;
           LD       SP,(TMPSTACKP)                                           ; Recover the correct stack pointer before exit.
           RET                                                               ; JP       SS

L0104:     LD       A,(MOTON)                                                ; motor on flag
           RRCA                                                              ; motor off?
           CALL     NC,DSKMOTORON                                            ; yes, set motor on and wait
           LD       A,(IX+000H)                                              ;drive no
           OR       084H                                                     ;
           OUT      (0DCH),A                                                 ; Motor on for drive 0-3
           XOR      A                                                        ;
           LD       (FDCCMD),A                                               ; clr latest FDC command byte
           LD       HL,00000H                                                ;
L0119:     DEC      HL                                                       ;
           LD       A,H                                                      ;
           OR       L                                                        ;
           JP       Z,DSKERR                                                 ; Reset and print message that this is not a bootable disk.
           IN       A,(0D8H)                                                 ; Status register.
           CPL                                                               ;
           RLCA                                                              ;
           JR       C,L0119                                                  ; Wait on motor off (bit 7)
           LD       C,(IX+000H)                                              ; Drive number
           LD       HL,TRK0FD1                                               ; 1 track 0 flag for each drive
           LD       B,000H                                                   ;
           ADD      HL,BC                                                    ; Compute related flag 1002/1003/1004/1005
           BIT      0,(HL)                                                   ;
           JR       NZ,L0137                                                 ; 
           CALL     DSKSEEKTK0                                               ; Seek track 0.
           SET      0,(HL)                                                   ; Set bit 0 of trk 0 flag
L0137:     RET      
 
           ; Turn disk motor on.
DSKMOTORON:LD       A,080H
           OUT      (0DCH),A                                                 ; Motor on
           LD       B,010H                                                   ; 
L013E:     CALL     L02C7                                                    ; 
           DJNZ     L013E                                                    ; Wait until becomes ready.
           LD       A,001H                                                   ; Set motor on flag.
           LD       (MOTON),A                                                ; 
           RET      

L0149:     LD       A,01BH
           CALL     DSKCMD
           AND      099H
           RET      

           ; Initialise drive and reset flags, Set motor off
DSKINIT:   XOR      A                                                        
           OUT      (0DCH),A                                                 ; Motor on/off
           LD       (TRK0FD1),A                                              ; Track 0 flag drive 1
           LD       (TRK0FD2),A                                              ; Track 0 flag drive 2
           LD       (TRK0FD3),A                                              ; Track 0 flag drive 3
           LD       (TRK0FD4),A                                              ; Track 0 flag drive 4
           LD       (MOTON),A                                                ; Motor on flag
           RET      

DSKSEEKTK0:LD       A,00BH                                                   ; Restore command, seek track 0.
           CALL     DSKCMD                                                   ; Send command to FDC.
           AND      085H                                                     ; Process result.
           XOR      004H   
           RET      Z      
           JP       DSKERR

DSKCMD:    LD       (FDCCMD),A                                               ; Store latest FDC command.
           CPL                                                               ; Compliment it (FDC bit value is reversed).
           OUT      (0D8H),A                                                 ; Send command to FDC.
           CALL     L017E                                                    ; Wait to become ready.
           IN       A,(0D8H)                                                 ; Get status register.
           CPL                                                               ; Inverse (FDC is reverse bit logic).
           RET      

L017E:     PUSH     DE
           PUSH     HL
           CALL     L02C0
           LD       E,007H
L0185:     LD       HL,00000H
L0188:     DEC      HL
           LD       A,H
           OR       L
           JR       Z,L0196                                                  ; (+009h)
           IN       A,(0D8H)
           CPL     
           RRCA    
           JR       C,L0188                                                  ; (-00bh)
           POP      HL
           POP      DE
           RET     

L0196:     DEC      E
           JR       NZ,L0185                                                 ; (-014h)
           JP       DSKERR

L019C:     PUSH     DE
           PUSH     HL
           CALL     L02C0
           LD       E,007H
L01A3:     LD       HL,00000H
L01A6:     DEC      HL
           LD       A,H
           OR       L
           JR       Z,L01B4                                                  ; (+009h)
           IN       A,(0D8H)
           CPL     
           RRCA    
           JR       NC,L01A6                                                 ; (-00bh)
           POP      HL
           POP      DE
           RET      

L01B4:     DEC      E
           JR       NZ,L01A3                                                 ; (-014h)
           JP       DSKERR

           ; Read disk starting at the first logical sector in param block 1009/100A
           ; Continue reading for the given size 100B/100C and store in the location 
           ; Pointed to by the address stored in the parameter block. 100D/100E
DSKREAD:   CALL     L0220                                                    ; Compute logical sector-no to track-no & sector-no, retries=10
L01BD:     CALL     L0229                                                    ; Set current track & sector, get load address to HL
L01C0:     CALL     L0249                                                    ; Set side reg
           CALL     L0149                                                    ; Command 1b output (seek)
           JR       NZ,L0216                                                 ; 
           CALL     L0259                                                    ; Set track & sector reg
           PUSH     IX                                                       ; Save 1008H
           LD       IX, 0F3FEH                                               ; As below. L03FE
           LD       IY,L01DF                                                 ; Read sector into memory.
          ;DI      
           LD       A,094H                                                   ; Latest FDC command byte
           CALL     L028A
L01DB:     LD       B,000H
           JP       (IX)

           ; Get data from disk sector to staging area (CE00).
L01DF:     INI     
           LD       A,(DE)                                                   ; If not at the end of the line, then process as the boot disk number.
           JP       NZ, 0F3FEH                                               ; This is crucial, as the Z80 is running at 2MHz it is not fast enough so needs
                                                                             ; hardware acceleration in the form of a banked ROM, if disk not ready jumps to IX, if
                                                                             ; data ready, jumps to IY. L03FE
           POP      IX
           INC      (IX+008H)                                                ; Increment current sector number
           LD       A,(IX+008H)                                              ; Load current sector number
           PUSH     IX                                                       ; Save 1008H
           LD       IX, 0F3FEH                                               ; As above. L03FE
           CP       011H                                                     ; Sector 17? Need to loop to next track.
           JR       Z,L01FB                 
           DEC      D
           JR       NZ,L01DB                
           JR       L01FC                                                    ; (+001h)

L01FB:     DEC      D
L01FC:     CALL     L0294
           CALL     L02D2
           POP      IX
           IN       A,(0D8H)
           CPL      
           AND      0FFH
           JR       NZ,L0216                                                 ; (+00bh)
           CALL     L0278
           JP       Z,L021B
           LD       A,(IX+007H)
           JR       L01C0                                                    ; (-056h)

L0216:     CALL     L026A
           JR       L01BD                                                    ; (-05eh)

L021B:     LD       A,080H
           OUT      (0DCH),A                                                 ; Motor on
           RET     

L0220:     CALL     L02A3                                                    ; compute logical sector no to track no & sector no
           LD       A,00AH                                                   ; 10 retries
           LD       (RETRIES),A
           RET     

           ; Set current track & sector, get load address to HL
L0229:     CALL     L0104
           LD       D,(IX+004H)                                              ; Number of sectors to read
           LD       A,(IX+003H)                                              ; Bytes to read
           OR       A                                                        ; 0?
           JR       Z,L0236                                                  ; Yes
           INC      D                                                        ; Number of sectors to read + 1
L0236:     LD       A,(IX+00AH)                                              ; Start sector number
           LD       (IX+008H),A                                              ; To current sector number
           LD       A,(IX+009H)                                              ; Start track number
           LD       (IX+007H),A                                              ; To current track number
           LD       L,(IX+005H)                                              ; Load address low byte
           LD       H,(IX+006H)                                              ; Load address high byte
           RET     

           ; Compute side/head.
L0249:     SRL      A                                                        ; Track number even?
           CPL                                                               ; 
           OUT      (0DBH),A                                                 ; Output track no.
           JR       NC,L0254                                                 ; Yes, even, set side/head 1
           LD       A,001H                                                   ; No, odd, set side/head 0
           JR       L0255                   

           ; Set side/head register.
L0254:     XOR      A                                                        ; Side 0
L0255:     CPL                                                               ; Side 1
           OUT      (0DDH),A                                                 ; Side/head register.
           RET     

           ; Set track and sector register.
L0259:     LD       C,0DBH                  
           LD       A,(IX+007H)                                              ; Current track number
           SRL      A                       
           CPL                              
           OUT      (0D9H),A                                                 ; Track reg
           LD       A,(IX+008H)                                              ; Current sector number
           CPL                             
           OUT      (0DAH),A                                                 ; Sector reg
           RET                       

L026A:     LD       A,(RETRIES)
           DEC      A
           LD       (RETRIES),A
           JP       Z,DSKERR
           CALL     DSKSEEKTK0
           RET     

L0278:     LD       A,(IX+008H)
           CP       011H
           JR       NZ,L0287                                                 ; (+008h)
           LD       A,001H
           LD       (IX+008H),A
           INC      (IX+007H)
L0287:     LD       A,D
           OR       A
           RET     

L028A:     LD       (FDCCMD),A
           CPL     
           OUT      (0D8H),A
           CALL     L019C
           RET      

L0294:     LD       A,0D8H
           CPL     
           OUT      (0D8H),A
           CALL     L017E
           RET     

DSKERR:    CALL     DSKINIT
           JP       DSKLOADERR

           ; Logical sector number to physical track and sector.
L02A3:     LD       B,000H
           LD       DE,00010H                                                ; No of sectors per trk (16)
           LD       L,(IX+001H)                                              ; Logical sector number
           LD       H,(IX+002H)                                              ; 2 bytes in length
           XOR      A
L02AF:     SBC      HL,DE                                                    ; Subtract 16 sectors/trk 
           JR       C,L02B6                                                  ; Yes, negative value
           INC      B                                                        ; Count track
           JR       L02AF                                                    ; Loop
L02B6:     ADD      HL,DE                                                    ; Reset HL to the previous
           LD       H,B                                                      ; Track
           INC      L                                                        ; Correction +1
           LD       (IX+009H),H                                              ; Start track no
           LD       (IX+00AH),L                                              ; Start sector no
           RET     

L02C0:     PUSH     DE
           LD       DE,00007H
           JP       L02CB

L02C7:     PUSH     DE
           LD       DE,01013H
L02CB:     DEC      DE
           LD       A,E
           OR       D
           JR       NZ,L02CB                                                 ; (-005h)
           POP      DE
           RET     

L02D2:     PUSH     AF
           LD       A,(0119CH)
           CP       0F0H
           JR       NZ,L02DB                                                 ; (+001h)
          ;EI      
L02DB:     POP      AF
           RET     

;wait on bit 0 and bit 1 = 0 of state reg
L0300:     IN      A,(0D8H)	                                 	             ; State reg
           RRCA    
           JR      C,L0300	                                              	 ; Wait on not busy
           RRCA    
           JR      C,L0300	                                              	 ; Wait on data reg ready
           JP      (IY)	                                                     ; to f1df

           ;-------------------------------------------------------------------------------
           ; END OF FLOPPY DISK CONTROLLER FUNCTIONALITY
           ;-------------------------------------------------------------------------------

           ;--------------------------------------
           ;
           ; Message table - Refer to bank 6 for
           ;                 all messages.
           ;
           ;--------------------------------------

           ; Error tone.
ERRTONE:   DB       "A0", 0D7H, "ARA", 0D7H, "AR", 00DH

           ; Identifier to indicate this is a valid boot disk
DSKID:     DB       002H, "IPLPRO"

           ; Parameter block to indicate configuration and load area.
PRMBLK:    DB       000H, 000H, 000H, 000H, 001H, 000H, 0CEH, 000H, 000H, 000H, 000H

           ; Ensure we fill the entire 2K by padding with FF's.
           ALIGN    0EBFDh
           DB       0FFh

L03FE:     JP       (IY)

           ALIGN    0EFF8h
           ORG      0EFF8h
           DB       0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
