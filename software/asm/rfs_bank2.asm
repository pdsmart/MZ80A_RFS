;--------------------------------------------------------------------------------------------------------
;-
;- Name:            rfs_bank2.asm
;- Created:         October 2018
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series Rom Filing System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade.
;-
;- Credits:         
;- Copyright:       (c) 2018 Philip Smart <philip.smart@net2net.org>
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
            ; USER ROM BANK 2 - SD Card Controller functions.
            ;
            ;===========================================================
            ORG     UROMADDR

            ;--------------------------------
            ; Common code spanning all banks.
            ;--------------------------------
ROMFS2:     NOP
            XOR     A                                                         ; We shouldnt arrive here after a reset, if we do, select UROM bank 0
            LD      (RFSBK1),A
            LD      (RFSBK2),A                                                ; and start up - ie. SA1510 Monitor.
            ALIGN_NOPS 0E829H

            ; Bank switching code, allows a call to code in another bank.
            ; This code is duplicated in each bank such that a bank switch doesnt affect logic flow.
            ;
BKSW2to0:   PUSH    AF
            LD      A, ROMBANK2                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK0                                              ; Required bank to call.
            JR      BKSW2_0
BKSW2to1:   PUSH    AF
            LD      A, ROMBANK2                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK1                                              ; Required bank to call.
            JR      BKSW2_0
BKSW2to2:   PUSH    AF
            LD      A, ROMBANK2                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK2                                              ; Required bank to call.
            JR      BKSW2_0
BKSW2to3:   PUSH    AF
            LD      A, ROMBANK2                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK3                                              ; Required bank to call.
            JR      BKSW2_0
BKSW2to4:   PUSH    AF
            LD      A, ROMBANK2                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK4                                              ; Required bank to call.
            JR      BKSW2_0
BKSW2to5:   PUSH    AF
            LD      A, ROMBANK2                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK5                                              ; Required bank to call.
            JR      BKSW2_0
BKSW2to6:   PUSH    AF
            LD      A, ROMBANK2                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK6                                              ; Required bank to call.
            JR      BKSW2_0
BKSW2to7:   PUSH    AF
            LD      A, ROMBANK2                                              ; Calling bank (ie. us).
            PUSH    AF
            LD      A, ROMBANK7                                              ; Required bank to call.
            ;
BKSW2_0:    PUSH    HL                                                       ; Place function to call on stack
            LD      HL, BKSWRET2                                             ; Place bank switchers return address on stack.
            EX      (SP),HL
            LD      (TMPSTACKP),SP                                           ; Save the stack pointer as some old code corrupts it.
            LD      (RFSBK2), A                                              ; Bank switch in user rom space, A=bank.
            JP      (HL)                                                     ; Jump to required function.
BKSWRET2:   POP     AF                                                       ; Get bank which called us.
            LD      (RFSBK2), A                                              ; Return to that bank.
            POP     AF
            RET                                                               ; Return to caller.


            ;-------------------------------------------------------------------------------
            ; GENERAL PURPOSE FUNCTIONS.
            ;-------------------------------------------------------------------------------

            ; Method to multiply a 16bit number by another 16 bit number to arrive at a 32bit result.
            ; Input: DE = Factor 1
            ;        BC = Factor 2
            ; Output:DEHL = 32bit Product
            ;
MULT16X16:  LD      HL,0
            LD      A,16
MULT16X1:   ADD     HL,HL
            RL      E 
            RL      D
            JR      NC,$+6
            ADD     HL,BC
            JR      NC,$+3
            INC     DE
            DEC     A
            JR      NZ,MULT16X1
            RET

            ; Method to add a 16bit number to a 32bit number to obtain a 32bit product.
            ; Input: DEHL = 32bit Addend
            ;        BC   = 16bit Addend
            ; Output:DEHL = 32bit sum.
            ;
ADD3216:    ADD     HL,BC
            EX      DE,HL
            LD      BC,0
            ADC     HL,BC
            EX      DE,HL
            RET

            ; Method to add two 32bit numbers whilst calculating the SD Start Sector.
            ; Input: DEHL          = 32bit Addend
            ;        (SDSTARTSEC)  = 32bit Addend
            ; Output: (SDSTARTSEC) = 32bit Sum.
            ; Output; DEHL         = 32bit Sum.
            ;
ADD32:      LD      BC,(SDSTARTSEC+2)
            ADD     HL,BC
            LD      (SDSTARTSEC+2),HL
            LD      BC,(SDSTARTSEC)
            EX      DE,HL
            ADC     HL,BC
            LD      (SDSTARTSEC),HL
            EX      DE,HL
            RET



            ;-------------------------------------------------------------------------------
            ; START OF SD CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Method to initialise the SD card.
            ;
SDINIT:     LD      A,000H                                               ; CS to high
            CALL    SPICS
            ;
            CALL    SPIINIT                                              ; Train SD with our clock.
            ;
            LD      A,0FFH                                               ; CS to low
            CALL    SPICS
            LD      BC,0FFFFH
     
SDINIT1:    LD      A,CMD0                                               ; Command 0
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,00000H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD

            PUSH    BC
            LD      A,(SDBUF+6)                                          ; Get response code.
            DEC     A                                                    ; Set Z flag to test if response is 0x01
            JP      Z,SDINIT2                                            ; Command response 0x01? Exit if match.
            POP     BC
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,SDINIT1                                           ; Retry for BC times.
            LD      A,1
            JP      SD_EXIT                                              ; Error, card is not responding to CMD0
SDINIT2:    POP     BC
            ; Now send CMD8 to get card details. This command can only be sent 
            ; when the card is idle.
            LD      A,CMD8                                               ; CMD8 has 0x00001AA as parameter, load up registers and call command routine.
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,0AA01H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD

            ; Version 2 card, check its voltage range. IF not in the 2.7-3.6V dont try the ACMD41 to get capabilities.
SDINIT3:    LD      A,1                                                  ; Check that we receive 0x0001AA in response.
            LD      (SDVER),A                                            ; Indicate this is not a version 2 card.
            LD      A,(SDBUF+9)
            CP      1
            JP      NZ,SDINIT8
            LD      A,(SDBUF+10)
            CP      0AAH
            JP      NZ,SDINIT8

SDINIT4:    LD      A,2                                                  ; This is a version 2 card.
SDINIT5:    LD      (SDVER),A                                            ; Indicate this is not a version 2 card.

            CALL    SDACMD41 
            JR      Z,SDINIT6
            LD      A,2                                                  ; Error, card is not responding to ACMD41
            JP      SD_EXIT

SDINIT6:    LD      A,CMD58                                              ; CMD58 has 0x00000000 as parameter, load up registers and call command routine.
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,00000H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(SDBUF+6)
            CP      040H
            LD      A,CT_SD2
            JR      Z,SDINIT7
            LD      A,CT_SD2 | CT_BLOCK
SDINIT7:    LD      (SDCAP),A                                            ; Set the capabilities according to the returned flag.
            JR      SDINIT14


            ; Version 1 card or MMC v3.
SDINIT8:    CALL    SDACMD41
            LD      A, CT_SD1
            LD      E,ACMD41                                             ; SD1 cards we use the ACMD41 command.
            JR      Z,SDINIT9
            LD      A,CT_MMC
            LD      E,CMD1                                               ; MMC cards we use the CMD1 command.
SDINIT9:    LD      (SDCAP),A
            LD      A,E
            CP      ACMD41
            JR      NZ,SDINIT10
            CALL    SDACMD41
            JR      Z,SDINIT14
            LD      A,3                                                  ; Exit code, failed to initialise v1 card.
            JP      SD_EXIT

SDINIT10:   LD      BC,10                                                ; ACMD41/CMD55 may take some cards time to process or respond, so give a large number of retries.
SDINIT11:   PUSH    BC
            LD      A,CMD1                                               ; CMD1 has 0x00000000 as parameter, load up registers and call command routine.
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,00000H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(SDBUF+6)                                          ; Should be a response of 0 whereby the card has left idle.
            OR      A
            JR      Z,SDINIT13
            LD      BC,0FFFFH                                            ; Delay for at least 200mS for the card to recover and be ready.
SDINIT12:   DEC     BC                                                   ; 6T
            LD      A,B                                                  ; 9T
            OR      C                                                    ; 4T
            JR      NZ,SDINIT12                                          ; 12T = 31T x 500ns = 15.5uS x 12903 = 200mS
            ;
            POP     BC
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,SDINIT11
            LD      A,4                                                  ; Exit code, failed to initialise v1 MMC card.
            JP      SD_EXIT

SDINIT13:   LD      A,CMD16                                              ; No response from the card for an ACMD41/CMD1 so try CMD16 with parameter 0x00000200
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,00002H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(SDBUF+6)
            OR      A
            JR      Z,SDINIT14
            LD      A,0
            LD      (SDCAP),A                                            ; No capabilities on this unknown card.
SDINIT14:   LD      A,0
            JR      SD_EXIT
SD_EXIT:    LD      L,A                                                  ; Return value goes into HL.
            LD      H,0
            RET

            ; Method to initialise communications with the SD card. We basically train it to our clock characteristics.
            ; This is important, as is maintaining the same clock for read or write otherwise the card may not respond.
SPIINIT:    LD      B,80
SPIINIT1:   LD      A,DOUT_HIGH | CLOCK_HIGH  | CS_HIGH                   ; Output a 1
            OUT     (SPI_OUT),A
            LD      A,DOUT_HIGH | CLOCK_LOW   | CS_HIGH                   ; Output a 1
            OUT     (SPI_OUT),A
            DJNZ    SPIINIT1
            RET

            ; Method to set the Chip Select level on the SD card. The Chip Select is active LOW.
            ;
            ; A = 0    - Set CS HIGH
            ; A = 0xFF - Set CS LOW
SPICS:      OR      A
            LD      A,DOUT_HIGH | CLOCK_LOW  | CS_HIGH                   ; Set CS High if parameter = 0 (ie. disable)
            JR      Z, SPICS0
            LD      A,DOUT_HIGH | CLOCK_LOW  | CS_LOW                    ; Set CS Low if parameter != 0 (ie. disable)
SPICS0:     OUT     (SPI_OUT),A
            RET

            ; Method to send a command to the card and receive back a response.
            ;
            ; A = CMD to send
            ; LHED = Argument, ie. CMD = A, L, H, E, D, CRC
            ;
SDCMD:      LD      (SDBUF),A
            LD      (SDBUF+1),HL
            EX      DE,HL
            LD      (SDBUF+3),HL
            ;
            ; Send command but with parameters preloaded by caller.
SDCMDNP:    LD      B,5                                                  ; R1 + 32bit argument for CMD8, CMD58
            CP      CMD8
            LD      C,135
            JP      Z,SDCMD0
            LD      C,1                                                  ; CMD58 is not CRC checked so just set to 0x01.
            CP      CMD58
            LD      B,5                                                  ; R1 + 32bit argument
            JP      Z,SDCMD0
            ;
            LD      B,1                                                  ; Default, expect R1 which is 1 byte.
            CP      CMD0                                                 ; Work out the CRC based on the command. CRC checking is
            LD      C,149                                                ; not implemented but certain commands require a fixed argument and CRC.
            JP      Z,SDCMD0
            LD      C,1                                                  ; Remaining commands are not CRC checked so just set to 0x01.
SDCMD0:     PUSH    BC                                                   ; Save the CRC and the number of bytes to be returned,
            LD      A,C                                                  ; Store the CRC
            LD      (SDBUF+5),A
            LD      A,255                                                ; Preamble byte
            CALL    SPIOUT
            LD      HL,SDBUF
            LD      B,6
SDCMD1:     PUSH    BC
            LD      A,(HL)
            INC     HL
            CALL    SPIOUT                                               ; Send the command and parameters.
            POP     BC
            DJNZ    SDCMD1
            PUSH    HL
SDCMD2:     CALL    SPIIN
            CP      0FFH
            JR      Z,SDCMD2
            JR      SDCMD4
SDCMD3:     PUSH    BC
            PUSH    HL
            CALL    SPIIN                                                ; 
SDCMD4:     POP     HL
            LD      (HL),A
            INC     HL
            POP     BC                                                   ; Get back number of expected bytes. HL = place in buffer to store response.
            DJNZ    SDCMD3
            LD      A,DOUT_HIGH | CLOCK_LOW  | CS_HIGH
            OUT     (SPI_OUT),A
            RET

            ; Method to send an Application Command to the SD Card. This involves sending CMD55 followed by the required command.
            ;
            ; A = ACMD to send
            ; LHED = Argument, ie. ACMD = A, L, H, E, D, CRC
            ;
SDACMD:     PUSH    AF
            PUSH    DE
            PUSH    HL
            LD      A,CMD55                                              ; CMD55 has 0x00000000 as parameter, load up registers and call command routine.
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,00000H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            POP     HL
            POP     DE
            LD      A,(SDBUF+6)                                          ; Should be a response of 0 or 1.
            CP      2
            JR      NC,SDACMD0
            POP     AF
            CALL    SDCMD
            LD      A,(SDBUF+6)                                          ; Should be a response of 0 whereby the card has left idle.
            OR      A
            RET
SDACMD0:    POP     AF
            CP      1
            RET

            ; Method to send Application Command 41 to the SD card. This command involves retries and delays
            ; hence coded seperately.
            ;
            ; Returns Z set if successful, else NZ.
            ;
SDACMD41:   LD      BC,10                                                ; ACMD41/CMD55 may take some cards time to process or respond, so give a large number of retries.
SDACMD1:    PUSH    BC
            LD      A,ACMD41                                             ; ACMD41 has 0x40000000 as parameter, load up registers and call command routine.
            LD      HL,00040H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,00000H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDACMD
            JR      Z,SDACMD3
            LD      BC,12903                                             ; Delay for at least 200mS for the card to recover and be ready.
SDACMD2:    DEC     BC                                                   ; 6T
            LD      A,B                                                  ; 9T
            OR      C                                                    ; 4T
            JR      NZ,SDACMD2                                           ; 12T = 31T x 500ns = 15.5uS x 12903 = 200mS
            ;
            POP     BC
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,SDACMD1
            LD      A,1
            OR      A                                                    ; Retries exceeded, return error.
            RET
SDACMD3:    POP     BC                                                   ; Success, tidy up stack and exit with Z set.
            XOR     A
            RET

            ; Method to send a byte to the SD card via the SPI protocol.
            ; This method uses the bitbang technique, change if hardware spi is available.
            ;
            ; Input A = Byte to send.
            ;
SPIOUT:     RLCA                                                         ; 65432107
            RLCA                                                         ; 54321076
            RLCA                                                         ; 43210765  - Adjust so that starting bit is same position as Data line.
            LD      E,A                                                  ; E = Character to send.
            LD      B,8                                                  ; B = Bit count
SPIOUT0:    LD      A,E
            AND     DOUT_MASK                                            ; Data bit to data line, clock and cs low.
            RLC     E
SPIOUT1:    OUT     (SPI_OUT),A
            OR      CLOCK_HIGH                                           ; Clock high
            OUT     (SPI_OUT),A
            AND     CLOCK_MASK                                           ; Clock low
            OUT     (SPI_OUT),A
            DJNZ    SPIOUT0                                              ; Perform actions for the full 8 bits.
            RET

            ; Method to receive a byte from the SD card via the SPI protocol.
            ; This method uses the bitbang technique, change if hardware spi is available.
            ; NB. Timing must be very similar in SPIOUT and SPIIN.
            ;
            ; Output: A = received byte.
            ;
SPIIN:      LD      BC,00800H | SPI_OUT                                  ; B = Bit count, C = clock port
            LD      L,0                                                  ; L = Character being read.
            LD      D,DOUT_HIGH | CLOCK_LOW   | CS_LOW                   ; Output a 0
            OUT     (C),D                                                ; To start ensure clock is low and CS is low.
            LD      E,DOUT_HIGH | CLOCK_HIGH  | CS_LOW                   ; Output a 0
SPIIN1:     OUT     (C),E                                                ; Clock to high.
            IN      A,(SPI_IN)                                           ; Input the received bit
            OUT     (C),D                                                ; Clock to low.
            SRL     A
            RL      L
            DJNZ    SPIIN1                                               ; Perform actions for the full 8 bits.
            LD      A,L                                                  ; return value
            RET

            ; A function from the z88dk stdlib, a delay loop with T state accuracy.
            ; 
            ; enter : hl = tstates >= 141
            ; uses  : af, bc, hl
T_DELAY:    LD      BC,-141
            ADD     HL,BC
            LD      BC,-23
TDELAYLOOP: ADD     HL,BC
            JR      C, TDELAYLOOP
            LD      A,L
            ADD     A,15
            JR      NC, TDELAYG0
            CP      8
            JR      C, TDELAYG1
            OR      0
TDELAYG0:   INC     HL
TDELAYG1:   RRA
            JR      C, TDELAYB0
            NOP
TDELAYB0:   RRA
            JR      NC, TDELAYB1
            OR      0
TDELAYB1:   RRA
            RET     NC
            RET

            ; Method to skip over an SD card input stream to arrive at the required bytes,
            ;
            ; Input: BC = Number of bytes to skip.
            ;
SPISKIP:    PUSH    BC
            CALL    SPIIN
            POP     BC
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,SPISKIP
            RET

            ; Method to convert an LBA value into a physical byte address. This is achieved by multiplying the block x 512.
            ; We take the big endian sector value, shift left 9 times then store the result back onto the stack.
            ; This is done as follows: <MSB> <2> <1> <0> => <2> <1> <0> 0  (ie. 8 bit shift): Shift left <0> with carry, shift left <1> shift left <2>, 0 to <LSB>
            ;
            ; Input: HL = Stack offset.
            ;
LBATOADDR:  LD      HL,(SDSTARTSEC+1)
            LD      A,(HL)                                               ; Start ny retrieving bytes as HED0
            INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            LD      L,A

            SLA     D                                                    ; Shift the long left by 9 to effect a x512
            RL      E
            RL      H
            LD      BC,(SDSTARTSEC)
            LD      A,H                                                  ; Now save the results as LHED, big endian format as used by the SD Card argument
            LD      (BC),A
            INC     BC
            LD      A,E
            LD      (BC),A
            INC     BC
            LD      A,D
            LD      (BC),A
            INC     BC
            LD      A,0
            LD      (BC),A
            RET


            ;
            ; This method was originally a C routine I was using for FatFS but optimised it (still more can be done). The C->ASM is not so optimal.
            ;
            ; Input: Memory variables: SDSTARTSEC= unsigned long sector.   - The sector number or direct byte address for older cards. This is big endian as per card.
            ;                      HL: Address where to store data read from sector.
            ;                      BC: Size of data to read, upto a sector size.
            ; Output:               A: 0 - All ok. A > 0 - error occurred.
            ;                      HL: End address of data loaded,
            ;
SD_READ:    PUSH    HL                                                   ; Store the load address.
            PUSH    BC                                                   ; Store the read size.
            LD      A,0
            CALL    SPICS                                                ; Set CS low (active).

            LD      HL,(SDCAP)                                           ; Test to see if CT_BLOCK is available.
            LD      H,0
            LD      A,CT_BLOCK
            AND     L
            JP      NZ,SD_READ1                                          ; If it has CT_BLOCK then use sector numbers otherwise multiply up to bytes.
            CALL    LBATOADDR                                            ; Multiply the sector by 512 for byte addressing on older cards.

SD_READ1:   ; A = ACMD to send
            ; LHED = Argument, ie. ACMD = A, L, H, E, D, CRC
            LD      A,CMD17                                              ; Send CMD17 to read a sector.
            LD      (SDBUF),A
            LD      HL,(SDSTARTSEC)
            LD      (SDBUF+1),HL
            LD      HL,(SDSTARTSEC+2)
            LD      (SDBUF+3),HL
            CALL    SDCMDNP                                              ; Execute SD Command, parameters already loaded into command buffer.
            LD      A,(SDBUF+6)                                          ; Fetch result and store.
            AND     A
            JP      NZ,SD_READ6

            LD      HL,1000                                              ; Sit in a tight loop waiting for the data packet arrival (ie. not 0xFF).
SD_READ2:   PUSH    HL
            LD      HL,200    
            CALL    T_DELAY
            CALL    SPIIN
            POP     HL
            CP      255
            JP      NZ,SD_READ3
            DEC     HL
            LD      A,H
            OR      L
            JR      NZ,SD_READ2

SD_READ3:   CP      254                                                  ; Data? If not exit with error code.
            JP      NZ,SD_READ6

            LD      HL,SD_SECSIZE                                        ; Size of full sector + 2 bytes CRC.
            POP     BC
            OR      A
            SBC     HL,BC                                                ; Calculate the bytes to skip once we have read the required bytes.
            EX      DE,HL
            POP     HL                                                   ; Get the store address into HL.
SD_READ4:   PUSH    HL                                                   ; Start reading bytes into the buffer.
            PUSH    DE
            PUSH    BC
            CALL    SPIIN
            POP     BC
            POP     DE
            POP     HL
            LD      (HL),A
            INC     HL                                                   ; Update buffer pointer.
            DEC     BC
            LD      A,B
            OR      C
            JP      NZ,SD_READ4                                          ; Not zero, keep reading.
            PUSH    HL
            PUSH    DE
            POP     BC
            INC     BC                                                   ; Were not interested in the CRC so skip it.
            INC     BC
            CALL    SPISKIP                                              ; Skip unread bytes + CRC.
            POP     HL
            LD      A,0                                                  ; And exit with success.
SD_READ5:   PUSH    AF
            LD      A,0
            CALL    SPICS
            POP     AF
            RET
SD_READ6:   POP     BC
            POP     HL
            LD      A,1
            JR      SD_READ5

            ; Method to write a 512byte sector to an SD Card.
            ;
            ; Input: Memory variables: SDSTARTSEC= unsigned long sector.   - The sector number or direct byte address for older cards. This is big endian as per card.
            ;                      HL: Address of buffer to read data from.
            ;                      BC: Size of data to write, upto a sector size.
            ; Output:               A: 0 - All ok. A > 0 - error occurred.
            ;                      HL: Address of end of buffer.
SD_WRITE:   PUSH    HL
            PUSH    BC

            LD      A,0FFH                                               ; Activate CS (set low).
            CALL    SPICS

            ; Open transaction.
            LD      HL,(SDCAP)                                           ; Check to see if the card has block addressing.
            LD      H,0
            LD      A,CT_BLOCK
            AND     L
            JP      NZ,SD_WRITE1                                         ; If it hasnt then we need to multiply up to the correct byte.
            CALL    LBATOADDR                                            ; Multiply the sector by 512 for byte addressing.

            ; A = ACMD to send
            ; LHED = Argument, ie. ACMD = A, L, H, E, D, CRC
SD_WRITE1:  LD      A,CMD24                                              ; Send CMD24 to write a sector.
            LD      (SDBUF),A
            LD      HL,(SDSTARTSEC)                                      ; Place long endian sector into command buffer.
            LD      (SDBUF+1),HL
            LD      HL,(SDSTARTSEC+2)
            LD      (SDBUF+3),HL
            CALL    SDCMDNP                                              ; Send command using No Parameters version as we loaded them into the command buffer already.
            LD      A,(SDBUF+6)                                          ; Fetch result and store.
            AND     A
            JP      NZ,SD_WRITE10
            LD      A,255                                                ; Ok, so command sent successfully, mark the write by sending an 0xFF followed by 0xFE
            CALL    SPIOUT
            LD      A,254
            CALL    SPIOUT

            ; Write buffer.
            POP     BC
            LD      HL,SD_SECSIZE
            OR      A
            SBC     HL,BC                                                ; Calculate number of bytes to pad with 0.
            EX      DE,HL
            POP     HL                                                   ; Address to read data from.
            ;
SD_WRITE2:  LD      A,B                                                  ; So long as we have bytes in the buffer, send to the card for writing.
            OR      C
            JP      Z,SD_WRITE3

            PUSH    DE
            PUSH    BC
            LD      A,(HL)                                               ; Get the byte to transmit.
            INC     HL                                                   ; And update the pointer.
            CALL    SPIOUT                                               ; Transmit value in A.
            POP     BC
            POP     DE
            DEC     BC
            JR      SD_WRITE2

            ; Close transaction.
SD_WRITE3:  PUSH    HL                                                   ; Save the end of buffer address for return to caller.
            PUSH    DE                                                   ; DE contains number of padding bytes to send
            POP     BC
            INC     BC                                                   ; Add 2 bytes for CRC
            INC     BC 
SD_WRITE4:  LD      A,B                                                  ; Test to see if we are already at zero, ie. all bytes sent. Exit if so.
            OR      C
            JP      Z,SD_WRITE5                    
            DEC     BC
            PUSH    BC
            LD      A,0                                                  ; Send 0's as padding bytes and CRC.
            CALL    SPIOUT
            POP     BC
            JP      SD_WRITE4

SD_WRITE5:  CALL    SPIIN                                                ; Check received response, if 0x05 which indicates write under way inside SD Card.
            AND     01FH
            CP      5
            JP      NZ,SD_WRITE11

            LD      HL,10000                                             ; Now wait for the write to complete allowing 1000mS before timing out.
            PUSH    HL
            JR      SD_WRITE7
SD_WRITE6:  DEC     HL
            PUSH    HL
            LD      HL,200                                               ; 200T state delay = 200 x 1/2000000 = 100uS
            CALL    T_DELAY
SD_WRITE7:  CALL    SPIIN                                                ; Get a byte, if it is not 0xFF then we have our response so exit.
            POP     HL
            CP      255
            JP      Z,SD_WRITE8
            LD      A,H
            OR      L
            JR      NZ,SD_WRITE6

SD_WRITE8:  LD      A,H                                                  ; End of timeout? If so we exit with the preset fail code.
            OR      L
            JP      Z,SD_WRITE11
            XOR     A                                                    ; Success code.
            POP     HL                                                   ; Get the updated return address to pass back to caller.
SD_WRITE9:  PUSH    AF
            LD      A,000H                                               ; Disable SD Card Chip Select to finish.
            CALL    SPICS
            POP     AF
            RET
SD_WRITE10: POP     HL                                                   ; Waste the byte count and ..
SD_WRITE11: POP     HL                                                   ; ..load address.
            LD      A,1                                                  ; Error exit.
            JR      SD_WRITE9


            ; Method to print out an SDC directory entry name along with an incremental file number. The file number can be
            ; used as a quick reference to a file rather than the filename.
            ;
            ; Input: HL = Address of filename.
            ;         D = File number.
            ;
PRTDIR:     PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            LD      A,(SCRNMODE)
            CP      0
            LD      H,47
            JR      Z,PRTDIR0
            LD      H,93
PRTDIR0:    LD      A,(TMPLINECNT)                                       ; Pause if we fill the screen.
            LD      E,A
            INC     E
            CP      H
            JR      NZ,PRTNOWAIT
            LD      E, 0
PRTDIRWAIT: CALL    GETKY
            CP      ' '
            JR      Z,PRTNOWAIT
            CP      'X'                                                  ; Exit from listing.
            LD      A,001H
            JR      Z,PRTDIR4
            JR      PRTDIRWAIT
PRTNOWAIT:  LD      A,E
            LD      (TMPLINECNT),A
            ;
            LD      A, D                                                 ; Print out file number and increment.
            CALL    PRTHX
            LD      A, '.'
            CALL    PRNT
            POP     DE
            PUSH    DE                                                   ; Get pointer to the file name and print.

            LD      HL,PRTFN
            CALL    BKSW2to6                                             ; Print out the filename.
            ;
            LD      HL, (DSPXY)
            ;
            LD      A,L
            CP      20
            LD      A,20
            JR      C, PRTDIR2
            ;
            LD      A,(SCRNMODE)                                         ; 40 Char mode? 2 columns of filenames displayed so NL.
            CP      0
            JR      Z,PRTDIR1
            ;
            LD      A,L                                                  ; 80 Char mode we print 4 columns of filenames.
            CP      40
            LD      A,40
            JR      C, PRTDIR2
            ;
            LD      A,L
            CP      60
            LD      A,60
            JR      C, PRTDIR2
            ;
PRTDIR1:    CALL    NL
            JR      PRTDIR3
PRTDIR2:    LD      L,A
            LD      (DSPXY),HL
PRTDIR3:    XOR     A
PRTDIR4:    OR      A
            POP     HL
            POP     DE
            POP     BC
            RET


            ; Method to get an SD Directory entry.
            ; The SD Card works in 512byte sectors so a sector is cached and each call evaluates if the required request is in cache, if it is not, a new sector
            ; is read.
            ;
            ; Input:  E  = Directory entry number to retrieve.
            ; Output: HL = Address of directory entry.
            ;         A  = 0, no errors, A > 1 error.
GETSDDIRENT:PUSH    BC
            PUSH    DE;
            ;
            LD      A,E
            SRL     A
            SRL     A
            SRL     A
            SRL     A                                                    ; Divide by 16 to get sector number.
            LD      C,A
            LD      A,(DIRSECBUF)                                        ; Do we have this sector in the buffer? If we do, use it.
            CP      C
            JR      Z,GETDIRSD0
            LD      A,C
            LD      (DIRSECBUF),A                                        ; Save the sector number we will load into the buffer.
            ;
            LD      HL,SECTORBUF
            LD      (SDLOADADDR),HL
            LD      HL,0
            LD      (SDSTARTSEC),HL
            LD      B,C
            LD      C,0
            LD      (SDSTARTSEC+2),BC
            LD      HL,SD_SECSIZE
            LD      (SDLOADSIZE),HL
            LD      HL,(SDLOADADDR)
            LD      BC,SD_SECSIZE
            ;
            DI
            CALL    SD_READ                                              ; Read the sector.
            EI
            ;
            OR      A
            JR      NZ,DIRSDERR
            LD      (SDLOADADDR),HL                                      ; Save the updated address.
GETDIRSD0:  POP     DE
            PUSH    DE
            LD      A,E                                                  ; Retrieve the directory entry number required.
            AND     00FH
            LD      HL,SECTORBUF
            JR      Z,GETDIRSD2
            LD      B,A
            LD      DE,SDDIR_ENTSZ                                       ; Directory entry size
GETDIRSD1:  ADD     HL,DE                                                ; Directory entry address into HL.
            DJNZ    GETDIRSD1
GETDIRSD2:  POP     DE
            POP     BC
            LD      A,0
GETDIRSD3:  OR      A
            RET
            ;
DIRSDERR:   EX      DE,HL                                                ; Print error message, show HL as it contains sector number where error occurred.
            PUSH    HL
            POP     BC                                                   ; HL to BC as the call requires the value to be displayed in BC.
            LD      DE,MSGSDRERR
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            POP     DE
            POP     BC
            LD      A,1
            JR      GETDIRSD3

            ; Method to find a free slot in the directory.
            ;
            ; Input: None.
            ; Output: E = Free directory entry.
            ;         HL = Address of directory entry.
            ;         C = 1 if no free directory slot available.
            ; Unless other directory entry functions called, DIRSECBUF = directory sector in cache which contains the free entry found.
GETDIRFREE: LD      A,0FFH
            LD      (DIRSECBUF),A                                        ; Reset the sector buffer in memory indicator.
            ;
            LD      E,0                                                  ; Directory entry number
            LD      B,0                                                  ; Scanning 256 directory entries for a free slot.
GETDIRFREE1:CALL    GETSDDIRENT                                          ; Get SD Directory entry details for directory entry number stored in D.
            RET     NZ                                                   ; Error reading sector so abort.
            LD      A,(HL)
            BIT     7,A                                                  ; Look for an inactive directory entry slot, Bit 7 of lower flag = 0?
            JR      NZ,GETDIRFREE2
            OR      A
            RET                                                          ; Found an entry that is free.
GETDIRFREE2:INC     E                                                    ; Onto next directory entry number.
            DJNZ    GETDIRFREE1
            SCF
            RET


            ; Method to write the cached SD Directory entry sector back to SD card.
            ; Normal use would be to call GERSDDIRENT to locate a required entry or slot, update it then call
            ; this method to flush it back to SD disk.
WRSDDIRENT: LD      A,(DIRSECBUF)                                        ; Get the directory sector number of the cached directory sector.
            LD      B,A
            LD      C,0
            LD      (SDSTARTSEC+2),BC                                    ; Set the sector ready to perform the write.
            LD      HL,SECTORBUF                                         ; Address of the sector.
            LD      BC,SD_SECSIZE                                        ; Set the size as one full sector.
            ;
            DI
            CALL    SD_WRITE
            EI
            ;
            OR      A
            JR      NZ,DIRSDWERR
            LD      A,0
WRSDDIRENT1:OR      A
            RET
DIRSDWERR:  LD      DE,MSGSDWERR
            PUSH    HL
            POP     BC                                                   ; HL to BC as the call requires the value to be displayed in BC.
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            LD      A,1
            JR      WRSDDIRENT1



            ; Method to list the directory of the SD Card.
            ;
            ; This method creates a unique sequenced number starting at 0 and attaches to each successive valid directory entry
            ; The file number and file name are then printed out in tabular format. The file number can be used in Load/Save commands
            ; instead of the filename.
            ;
            ; No inputs or outputs.
            ;
DIRSDCARD:  LD      A,1                                                  ; Setup screen for printing, account for the title line. TMPLINECNT is used for page pause.
            LD      (TMPLINECNT),A
            LD      A,0FFH
            LD      (DIRSECBUF),A                                        ; Reset the sector buffer in memory indicator.
            ;
            LD      DE,MSGCDIRLST                                        ; Print out header.
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            ;
DIRSD0:     LD      E,0                                                  ; Directory entry number
            LD      D,0                                                  ; Directory file number (incr when a valid dirent is found).
            LD      B,0
DIRSD1:     CALL    GETSDDIRENT                                          ; Get SD Directory entry details for directory entry number stored in D.
            RET     NZ
DIRSD2:     LD      A,(HL)
            INC     HL
            INC     HL                                                   ; Hop over flags.
            BIT     7,A                                                  ; Is this entry active, ie. Bit 7 of lower flag = 1?
            JR      Z,DIRSD3
            CALL    PRTDIR                                               ; Valid entry so print directory number and name pointed to by HL.
            JR      NZ,DIRSD4
            INC     D
DIRSD3:     INC     E                                                    ; Onto next directory entry number.
            DJNZ    DIRSD1
DIRSD4:     RET
            ;


            ; Method to locate an entry in the SD directory based on a filenumber or a filename.
            ; This method is called with the raw parameter string in DE which is then parsed to determine if a filenumber
            ; or filename has been given.
            ; Input:   DE = String containing a filenumber of filename.
            ; Output:  (TMPCNT)  = 0xFFFF - DE contains a filename.
            ;          (TMPCNT) != 0xFFFF - DE contains a filenumber and (TMPCNT) is set to that number.
FINDSDX:    PUSH    DE
            LD      HL,0FFFFh                                            ; Tag the filenumber as invalid.
            LD      (TMPCNT), HL 
            CALL    _2HEX
            JR      C, FINDSDX1                                          ; 
            LD      L,A
            LD      H,0
            LD      (TMPCNT), HL                                         ; Store filenumber making load by filenumber valid.
FINDSDX1:   POP     DE

            ; Method to locate an entry in the SD directory based on a filenumber or a filename.
            ; Input: DE = String containing a filenumber or filename.
            ;        (TMPCNT)  = 0xFFFF - DE contains a filename.
            ;        (TMPCNT) != 0xFFFF - Filenumber.
FINDSD:     PUSH    DE
            LD      A,0FFH
            LD      (DIRSECBUF),A                                        ; Reset the sector buffer in memory indicator.
            LD      E,0                                                  ; Directory entry number start
            LD      D,0                                                  ; Directory file number (incr when a valid dirent is found).
            LD      B,0
FINDSD1:    CALL    GETSDDIRENT                                          ; Get SD Directory entry details for directory entry number stored in D.
FINDSD2:    BIT     7,(HL)                                               ; Is this entry active, ie. Bit 7 of lower flag = 1?
            JR      Z,FINDSD3
            PUSH    HL
            LD      HL,(TMPCNT)
            LD      H,(HL)
            LD      A,H
            CP      0FFH
            LD      A,L
            POP     HL
            JR      Z,FINDSD4                                            ; A filenumber wasnt given so will need to name match.
            CP      D                                                    ; Match on filenumber, does the given number match with the current?
            JR      Z,FINDSD9
            INC     D
FINDSD3:    INC     E
            DJNZ    FINDSD1
            POP     DE
            LD      A,1
            JP      FINDSD10                                             ; We didnt find a match so exit with code 1.

FINDSD4:    POP     DE                                                   ; Get back pointer to given filename. HL contains directory filename.
            PUSH    DE
            PUSH    BC                                                   ; Save BC as we need it for comparison.
            LD      B,SDDIR_FNSZ
            INC     HL
            INC     HL                                                   ; Hop over flags.
FINDSD5:    LD      A,(HL)
            LD      (DE),A
            CP      00Dh                                                 ; If we find a terminator then this is a valid name.
            JR      Z, FINDSD9A
            CP      020h                                                 ; >= Space
            JR      C, FINDSD8
            CP      05Dh                                                 ; =< ]
            JR      C, FINDSD6
            CP      091h
            JR      C, FINDSD8                                           ; DEL or > 0x7F, cant be a valid filename so this is not an MZF header.
FINDSD6:    INC     DE
            INC     HL
            DJNZ    FINDSD5
FINDSD7:    LD      A,B
            CP      SDDIR_FNSZ
            JR      Z,FINDSD9                                            ; If we matched all FNSIZE characters then this is a valid name.
FINDSD8:    POP     BC                                                   ; No match on filename so go back for next directory entry.
            POP     DE
            JR      FINDSD3
FINDSD9A:   POP     BC
FINDSD9:    POP     BC                                                   ; Waste the pointer to the input string.
            LD      A,0                                                  ; D contains the filenumber.
FINDSD10:   OR      A
            RET


            ; Method to erase a file in the SD RFS. This is a simple matter of resetting the valid entry flag (bit 7 of FLAG1) in the directory entry for
            ; the required file.
            ; Input:  DE = String containing filenumber or filename to erase.
            ; Output:  A = 0 Success, 1 = Fail.
ERASESD:    CALL    FINDSDX 
            JR      NZ,LOADSD3                                           ; Not found? Print message and exit.
            ; Directory entry in cache, HL points to FLAG1 of entry.
            LD      A,(HL)                                               ; Clear the valid entry flag, bit 7 of FLAG1
            AND     07FH
            LD      (HL),A
            PUSH    DE
            CALL    WRSDDIRENT                                           ; Flush the directory entry to disk to effect the delete.
            OR      A
            JR      NZ,ERASESD1                                          ; Failure, the report and exit.
            POP     BC                                                   ; Get the directory entry number.
            LD      B,0
            LD      DE,MSGERASEDIR
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            LD      A,0                                                  ; Success.
            RET
ERASESD1:   LD      DE,MSGERAFAIL                                        ; Fail, print out message.
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            LD      A,1
            RET


            ; Entry point when copying the SD file. Setup flags to indicate copying to effect any special processing.
            ; The idea is to load the file into memory, dont execute and pass back the parameters within the CMT header.
            ;
LOADSDCP:   LD      A,0FFH
            LD      (SDAUTOEXEC),A
            JR      LOADSD2

            ; Load a program from the SD Card into RAM and/or execute it.
            ;
            ; DE points to a number or filename to load.
LOADSDCARDX:LD      A,0FFH
            JR      LOADSD1
LOADSDCARD: LD      A,000H
LOADSD1:    LD      (SDAUTOEXEC),A
            XOR     A                                                    ; Clear copying flag.
LOADSD2:    LD      (SDCOPY),A   
            LD      A,0FFH                                               ; For interbank calls, save result in a memory variable.
            LD      (RESULT),A
            CALL    FINDSDX 
            JR      Z,LOADSD9
LOADSD3:    LD      DE,MSGNOTFND
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print message that file wasnt found.
            RET
            
            ; We have found the directory entry, so use it to load the program into memory.
            ; HL points to end of filename so requires an update to point to start of the directory entry.
            ; Copy all relevant information into the CMT header (for reference) and working variables.
            ;
LOADSD9:    LD      A,L
            AND     0E0H
            INC     A
            LD      L,A
            LD      A,(HL)
            LD      (ATRB),A                                             ; Type of file, store in the tape header memory.
            INC     HL
            LD      DE,NAME
            LD      BC,SDDIR_FNSZ
            LDIR                                                         ; Copy the filename into the CMT area.
            LD      E,(HL)
            INC     HL
            LD      D,(HL)                                               ; Start sector upper 16 bits, big endian.
            INC     HL
            LD      (SDSTARTSEC),DE
            LD      E,(HL)
            INC     HL
            LD      D,(HL)                                               ; Start sector lower 16 bits, big endian.
            INC     HL
            LD      (SDSTARTSEC+2),DE
            LD      E,(HL)
            INC     HL 
            LD      D,(HL)                                               ; Size of file.
            INC     HL
            LD      (SIZE),DE
            LD      (SDLOADSIZE),DE
            LD      E,(HL)
            INC     HL 
            LD      D,(HL)                                               ; Load address.
            INC     HL
            LD      A,D
            LD      (DTADRSTORE),DE                                      ; Save the original load address, use this to fill DTADR when complete if it has changed..
            CP      001H                                          
            JR      NC,LOADSD10
            LD      DE,01200H                                            ; If the file specifies a load address below 1000H then shift to 1200H as it is not valid.
LOADSD10:   LD      (DTADR),DE
            LD      (SDLOADADDR),DE
            LD      E,(HL)
            INC     HL 
            LD      D,(HL)                                               ; Execution address, store in tape header memory.
            LD      (EXADR),DE
            ;
            LD      DE,MSGLOAD+1                                         ; Skip initial CR.
            LD      BC,NAME
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            ;
LOADSD11:   LD      A,(SDLOADSIZE+1)
            CP      002H
            LD      BC,SD_SECSIZE                                        ; A full sector read if remaining bytes >=512
            JR      NC,LOADSD12
            LD      BC,(SDLOADSIZE)                                      ; Get remaining bytes size.
LOADSD12:   LD      HL,(SDLOADADDR)
            DI
            CALL    SD_READ                                              ; Read the sector.
            EI
            OR      A
            JP      NZ,LOADSDERR                                         ; Failure to read a sector, abandon with error message.
            LD      (SDLOADADDR),HL                                      ; Save the updated address.
            ;
            LD      HL,SDSTARTSEC+3
            INC     (HL)
            JR      NZ,LOADSD12A
            DEC     HL
            INC     (HL)
LOADSD12A:  LD      A,(SDLOADSIZE+1)
            CP      002H
            JR      C,LOADSD14                                           ; If carry then the last read obtained the remaining bytes.
            LD      HL,(SDLOADSIZE)
            LD      DE,SD_SECSIZE
            OR      A
            SBC     HL,DE
LOADSD13:   LD      (SDLOADSIZE),HL
            JR      LOADSD11

LOADSD14:   LD      A,(SDAUTOEXEC)                                       ; Autoexecute turned off?
            CP      0FFh
            JP      Z,LOADSD15                                           ; Go back to monitor if it has been, else execute.
            LD      A,(ATRB)
            CP      OBJCD
            JR      NZ,LOADSD17
            LD      HL,(EXADR)
            JP      (HL)                                                 ; Execution address.
LOADSD15:   LD      DE,MSGCMTDATA                                        ; Indicate where the program was loaded and the execution address.
            LD      HL,(DTADR)
            PUSH    HL
            LD      HL,(EXADR)
            PUSH    HL
            LD      BC,(SIZE)
LOADSD16:   LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            POP     BC
            POP     BC                                                   ; Remove parameters off stack.
LOADSDX:    LD      A,0                                                  ; Non error exit.
LOADSDX1:   LD      (RESULT),A
            RET
LOADSD17:   LD      DE,MSGNOTBIN
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            JR      LOADSD16

LOADSDERR:  LD      DE,MSGSDRERR
            LD      HL,PRINTMSG
            LD      BC,(TMPCNT)
            CALL    BKSW2to6                                             ; Print out the filename.
            LD      A,2
            JR      LOADSDX1

            ; Setup for saving an application to SD Card but using the CMT header. Also set the copy flag because the values in the header
            ; may not reflect where the image is stored (ie. CTM LOAD=0x0000 -> data is at 0x1200).
            ;
SAVESDCARDX:LD      A,0FFH    
            JR      SAVESD1

            ; Method to save a block of memory to the SD card as a program.
            ; The parameters which should be given are:
            ; XXXXYYYYZZZZ - where XXXX = Start Address, YYYY = End Address, ZZZZ = Execution Address.
            ; Prompt for a filename which will be written into the CMT header.
            ; All the values are stored in the CMT header and copied as needed into the SD directory.
            ;
SAVESDCARD: LD      HL,GETCMTPARM                                        ; Get the CMT parameters.
            CALL    BKSW2to3
            LD      A,C
            OR      A
            RET     NZ                                                   ; Exit if an error occurred.

            XOR     A                                                    ; Disable the copy flag.
SAVESD1:    LD      (SDCOPY),A
            LD      A,0FFH                                               ; Interbank calls, pass result via a memory variable. Assume failure unless updated.
            LD      (RESULT),A
            LD      A,OBJCD                                              ; Set attribute: OBJ
            LD      (ATRB),A

            ; Find free slot.
            CALL    GETDIRFREE
            JR      NC,SAVESD4
            LD      DE,MSGDIRFULL                                        ; Directory is full so abort command.
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            LD      A,1                                                  ; Directory full code.
            LD      (RESULT),A
            RET
            ;
SAVESD4:    PUSH    DE                                                   ; Save the directory entry number.
            PUSH    HL
            LD      B,0
            LD      C,E
            LD      DE,MSGSVDIRENT
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            POP     HL
            LD      A,080H
            LD      (HL),A                                               ; Set directory entry flag indicating that the entry is in use.
            INC     HL
            LD      A,(ATRB)
            LD      (HL),A                                               ; Copy attribute.
            INC     HL
            LD      BC,SDDIR_FNSZ
            LD      DE,NAME
            EX      DE,HL
            LDIR                                                         ; Copy filename across to directory.
            EX      DE,HL
            POP     DE                                                   ; Get directory entry number in E.
            ;
            PUSH    HL
            LD      D,0
            LD      BC,SDDIR_BLOCKSZ / SD_SECSIZE                        ; Put the blocksize as sectors into BC and multiply with E to get the block address.
            CALL    MULT16X16                                            ; DEHL to contain LBA address for given block.
            LD      BC,SDDIR_DIRSIZE / SD_SECSIZE
            CALL    ADD3216                                              ; Add in size of directory to arrive at correct LBA sector.
            PUSH    HL
            POP     BC                                                   ; 32bit LBA now in DEBC
            POP     HL
            LD      (HL),D                                               ; Now save the 32bit LBA sector number into the directory entry.
            LD      (SDSTARTSEC),DE                                      ; DE will always be 0 for RFS so we dont worry about endian, ie. (256 * 64K + 256 * 32)/512 = 0x00008010
            INC     HL
            LD      (HL),E
            INC     HL
            LD      A,B
            LD      (HL),A
            LD      (SDSTARTSEC+2),A
            INC     HL
            LD      A,C
            LD      (HL),A
            LD      (SDSTARTSEC+3),A
            INC     HL
            ;
            LD      DE,(SIZE)                                            ; Add in the size of the program.
            LD      (SDLOADSIZE),DE
            LD      (HL),E
            INC     HL
            LD      (HL),D
            INC     HL
            ;
            LD      DE,(DTADR)                                           ; Add in the load address of the program.
            LD      (HL),E
            INC     HL
            LD      (HL),D
            INC     HL
            ;
            LD      A,(SDCOPY)
            OR      A
            JR      Z,SAVEDS4A
            LD      DE,01200H                                            ; Copy mode -> data is always at 0x1200.
SAVEDS4A:   LD      (SDLOADADDR),DE
            ;
            LD      DE,(EXADR)                                           ; Add in the execution address of the program.
            LD      (HL),E
            INC     HL
            LD      (HL),D
            INC     HL
            ; 
            ; Header has been written into the cached directory sector, write out data and if successful, write out 
            ; the directory entry to complete.
            ;
SAVESD5:    LD      A,(SDLOADSIZE+1)
            CP      002H
            LD      BC,SD_SECSIZE                                        ; A full sector read if remaining bytes >=512
            JR      NC,SAVESD6
            LD      BC,(SDLOADSIZE)                                      ; Get remaining bytes size.
SAVESD6:    LD      HL,(SDLOADADDR)
            DI
            CALL    SD_WRITE                                             ; Write the sector.
            EI
            OR      A
            JR      NZ,SAVESD9                                           ; Failure to read a sector, abandon with error message.
            LD      (SDLOADADDR),HL                                      ; Save the updated address.
            ;
            LD      HL,SDSTARTSEC+3
            INC     (HL)
            JR      NZ,SAVESD7
            DEC     HL
            INC     (HL)
SAVESD7:    LD      A,(SDLOADSIZE+1)
            CP      002H
            JR      C,SAVESD8                                            ; If carry then the last read obtained the remaining bytes.
            LD      HL,(SDLOADSIZE)
            LD      DE,SD_SECSIZE
            OR      A
            SBC     HL,DE
            LD      (SDLOADSIZE),HL
            JR      SAVESD5
SAVESD8:    ; Data written, now write out the directory entry.
            CALL    WRSDDIRENT                                           ; Flush the directory entry to disk.
       ;PUSH HL
       ;PUSH DE
       ;PUSH BC
       ;LD   BC,01000H
       ;LD   DE,0D000H
       ;LD   HL,DUMPBC
       ;CALL BKSW2to3
       ;POP BC
       ;POP DE
       ;POP HL
            OR      A
            JR      NZ,SAVESD9
            LD      A,0                                                  ; Success.
            LD      (RESULT),A
            RET
SAVESD9:    LD      DE,MSGSVFAIL                                         ; Fail, print out message.
            LD      HL,PRINTMSG
            CALL    BKSW2to6                                             ; Print out the filename.
            LD      A,1                                                  ; Write failed code.
            LD      (RESULT),A
            RET

            ;-------------------------------------------------------------------------------
            ; END OF SD CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

             
            ;--------------------------------------
            ;
            ; Message table - Refer to Bank 6 for
            ;                 messages.
            ;
            ;--------------------------------------
            ALIGN   0EFFFh
            DB      0FFh
