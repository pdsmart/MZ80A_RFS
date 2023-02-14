;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cbios_bank3.asm
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
            ; USER ROM CPM CBIOS BANK 3 - SD Card Controller functions.
            ;
            ;============================================================
            ORG      UROMADDR

            ;-----------------------------------------------------------------------------------------
            ; Common code spanning all banks to ensure that a Monitor is selected upon power up/reset.
            ;-----------------------------------------------------------------------------------------
            NOP
            LD      B,16                                                 ; If we read the bank control reset register 15 times then this will enable bank control and then the 16th read will reset all bank control registers to default.
CBIOS3_0:   LD      A,(BNKCTRLRST)
            DJNZ    CBIOS3_0                                             ; Apply the default number of coded latch reads to enable the bank control registers.
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
            JP      ?SD_INIT                                             ; SD_INIT
            JP      ?SD_READ                                             ; SD_READ
            JP      ?SD_WRITE                                            ; SD_WRITE
            JP      ?SD_GETLBA                                           ; SD_GETLBA
            JP      ?SDC_READ                                            ; SDC_READ
            JP      ?SDC_WRITE                                           ; SDC_WRITE


            ;-------------------------------------------------------------------------------
            ; START OF SD CARD CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ;-------------------------------------------------------------------------------
            ; Hardware SPI SD Controller (HW_SPI_ENA = 1)
            ; This logic uses the RFS PCB v2+ hardware shift registers to communicate with
            ; an SD Card. It is the fastest solution available but has a high IC count.
            ;
            ; Software SPI SD Controller (SW_SPI_ENA = 1)
            ; This logic uses the RFS PCB v2+ logic to simulate the SPI interface with 
            ; bitbanging techniques. It is similar to the Parallel Port SD Controller
            ; but uses logic on the RFS board rather than the parallel port interface.
            ;
            ; Parallel Port SD Controller (PP_SPI_ENA = 1)
            ; This logic uses the standard Sharp MZ-80A Parallel Port for simulating the
            ; SPI interface with bitbanging techniques. This interface is then used to 
            ; communicate with an SD Card.
            ;-------------------------------------------------------------------------------

            ; Method to initialise the SD card.
            ;
?SD_INIT:   LD      A,0FFH                                               ; CS to high (inactive)
            CALL    SPICS
            ;
            CALL    SPIINIT                                              ; Train SD with our clock.
            ;
            LD      A,000H                                               ; CS to low (active)
            CALL    SPICS

            LD      BC,SD_RETRIES                                        ; Number of retries before deciding card is not present.
SD_INIT1:   LD      A,CMD0                                               ; Command 0
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,00000H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            PUSH    BC
            ;
            CALL    SDCMD
            ;
            LD      A,(SDBUF+6)                                          ; Get response code.
            DEC     A                                                    ; Set Z flag to test if response is 0x01
            POP     BC
            JP      Z,SD_INIT2                                           ; Command response 0x01? Exit if match.

            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,SD_INIT1                                          ; Retry for BC times.
            LD      A,1
            JP      SD_EXIT                                              ; Error, card is not responding to CMD0

SD_INIT2:   ; Now send CMD8 to get card details. This command can only be sent 
            ; when the card is idle.
            LD      A,CMD8                                               ; CMD8 has 0x00001AA as parameter, load up registers and call command routine.
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,0AA01H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD

            ; Version 2 card, check its voltage range. IF not in the 2.7-3.6V dont try the ACMD41 to get capabilities.
SD_INIT3:   LD      A,1                                                  ; Check that we receive 0x0001AA in response.
            LD      (SDVER),A                                            ; Indicate this is not a version 2 card.
            LD      A,(SDBUF+9)
            CP      1
            JP      NZ,SD_INIT8
            LD      A,(SDBUF+10)
            CP      0AAH
            JP      NZ,SD_INIT8

SD_INIT4:   LD      A,2                                                  ; This is a version 2 card.
SD_INIT5:   LD      (SDVER),A                                            ; Indicate this is not a version 2 card.

            CALL    SDACMD41 
            JR      Z,SD_INIT6
            LD      A,2                                                  ; Error, card is not responding to ACMD41
            JP      SD_EXIT

SD_INIT6:   LD      A,CMD58                                              ; CMD58 has 0x00000000 as parameter, load up registers and call command routine.
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,00000H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(SDBUF+6)
            CP      040H
            LD      A,CT_SD2
            JR      Z,SD_INIT7
            LD      A,CT_SD2 | CT_BLOCK
SD_INIT7:   LD      (SDCAP),A                                            ; Set the capabilities according to the returned flag.
            JR      SD_INIT14


            ; Version 1 card or MMC v3.
SD_INIT8:   CALL    SDACMD41
            LD      A, CT_SD1
            LD      E,ACMD41                                             ; SD1 cards we use the ACMD41 command.
            JR      Z,SD_INIT9
            LD      A,CT_MMC
            LD      E,CMD1                                               ; MMC cards we use the CMD1 command.
SD_INIT9:   LD      (SDCAP),A
            LD      A,E
            CP      ACMD41
            JR      NZ,SD_INIT10
            CALL    SDACMD41
            JR      Z,SD_INIT14
            LD      A,3                                                  ; Exit code, failed to initialise v1 card.
            JR      SD_EXIT

SD_INIT10:  LD      BC,10                                                ; ACMD41/CMD55 may take some cards time to process or respond, so give a large number of retries.
SD_INIT11:  PUSH    BC
            LD      A,CMD1                                               ; CMD1 has 0x00000000 as parameter, load up registers and call command routine.
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,00000H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(SDBUF+6)                                          ; Should be a response of 0 whereby the card has left idle.
            OR      A
            JR      Z,SD_INIT13
            LD      BC,0FFFFH                                            ; Delay for at least 200mS for the card to recover and be ready.
SD_INIT12:  DEC     BC                                                   ; 6T
            LD      A,B                                                  ; 9T
            OR      C                                                    ; 4T
            JR      NZ,SD_INIT12                                         ; 12T = 31T x 500ns = 15.5uS x 12903 = 200mS
            ;
            POP     BC
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,SD_INIT11
            LD      A,4                                                  ; Exit code, failed to initialise v1 MMC card.
            JR      SD_EXIT

SD_INIT13:  POP     BC
            LD      A,CMD16                                              ; No response from the card for an ACMD41/CMD1 so try CMD16 with parameter 0x00000200
            LD      HL,00000H                                            ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,00002H                                            ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(SDBUF+6)
            OR      A
            JR      Z,SD_INIT14
            LD      A,0
            LD      (SDCAP),A                                            ; No capabilities on this unknown card.
SD_INIT14:  XOR     A
            JR      SD_EXIT
SD_EXIT:    OR      A                                                    ; Return value is in A.
            RET

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
            LD      HL,SD_RETRIES
SDCMD2:     PUSH    HL
            CALL    SPIIN
            POP     HL
            CP      0FFH
            JR      NZ,SDCMD4
            DEC     HL
            LD      A,H
            OR      L
            JR      NZ,SDCMD2
            ;
            ; Error as we are not receiving data.
            ;
            POP     HL
            POP     BC
            LD      A,1                                                  ; Force return code to be error.
            LD      (SDBUF+6),A
            RET            

SDCMD3:     PUSH    BC
            PUSH    HL
            CALL    SPIIN                                                ; 
SDCMD4:     POP     HL
            LD      (HL),A
            INC     HL
            POP     BC                                                   ; Get back number of expected bytes. HL = place in buffer to store response.
            DJNZ    SDCMD3
            IF HW_SPI_ENA = 0
             LD      A,DOUT_HIGH | CLOCK_LOW  | CS_HIGH
             OUT     (SPI_OUT),A
            ENDIF
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
            JR      NC,SDACMDE
            POP     AF
            CALL    SDCMD
SDACMD0:    LD      A,(SDBUF+6)                                          ; Should be a response of 0 whereby the card has left idle.
            OR      A
            RET
SDACMDE:    POP     AF
            JR      SDACMD0

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
            JR      Z,SDACMD3                                            ; Should be a response of 0 whereby the card has left idle.
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
            LD      A,1                                                  ; Retries exceeded, return error.
            OR      A
            RET
SDACMD3:    POP     BC                                                   ; Success, tidy up stack and exit with Z set.
            XOR     A
            RET



            ; Method to initialise communications with the SD card. We basically train it to our clock characteristics.
            ; This is important, as is maintaining the same clock for read or write otherwise the card may not respond.
SPIINIT:    IF HW_SPI_ENA = 1
              ; Hardware SPI on the RFS v2+ PCB.
              LD      B,10
              LD      A, 0FFH                                            ; We need to send 80 '1's, so preload the data register with all 1's, future transmits dont require this as it self loads with 1's.
              LD      (HWSPIDATA),A
SPIINIT1:     LD      (HWSPISTART),A                                     ; Commence transmission of an 8bit byte. Runs 1 8MHz, so 1 byte in 1uS, it takes the Z80 2uS for its quickest instruction at 2MHz clock.
              DJNZ    SPIINIT1
              RET

            ELSE

              ; Software SPI on the RFS v2+ PCB.
              IF SW_SPI_ENA = 1

              ELSE

              ; Software SPI on the centronics parallel port.
              LD      B,80
SPIINIT1:     LD      A,DOUT_HIGH | CLOCK_HIGH  | CS_HIGH                ; Output a 1
              OUT     (SPI_OUT),A
              LD      A,DOUT_HIGH | CLOCK_LOW   | CS_HIGH                ; Output a 1
              OUT     (SPI_OUT),A
              DJNZ    SPIINIT1
              RET
              ENDIF
            ENDIF

            ; Method to set the Chip Select level on the SD card. The Chip Select is active LOW.
            ;
            ; A = 0    - Set CS LOW (active)
            ; A = 0xFF - Set CS HIGH (active)
SPICS:      IF HW_SPI_ENA = 1
              ; Hardware SPI on the RFS v2+ PCB.
              OR    A
              LD    A,(ROMCTL)
              SET   1,A                                                  ; If we are inactivating CS then set CS high and disable clock by setting BBCLK to low.
              RES   0,A
              JR    NZ, SPICS0
              RES   1,A                                                  ; If we are activating CS then set CS low and enable clock by setting BBCLK to high.
              SET   0,A
SPICS0:       LD    (BNKCTRL),A
              LD    (ROMCTL),A
              RET

            ELSE

              ; Software SPI on the RFS v2+ PCB.
              IF SW_SPI_ENA = 1

              ELSE

              ; Software SPI on the centronics parallel port.
              OR    A
              LD    A,DOUT_HIGH | CLOCK_LOW  | CS_LOW                    ; Set CS Low if parameter = 0 (ie. enable)
              JR    Z, SPICS0
              LD    A,DOUT_HIGH | CLOCK_LOW  | CS_HIGH                   ; Set CS High if parameter != 0 (ie. disable)
SPICS0:       OUT   (SPI_OUT),A
              RET
              ENDIF
            ENDIF

            ; Method to send a byte to the SD card via the SPI protocol.
            ; This method uses the hardware shift registers.
            ;
            ; Input A = Byte to send.
            ;
SPIOUT:     IF HW_SPI_ENA = 1
              ; Hardware SPI on the RFS v2+ PCB.
              LD    (HWSPIDATA),A
              LD    (HWSPISTART),A
              RET

            ELSE

              ; Software SPI on the RFS v2+ PCB.
              IF SW_SPI_ENA = 1

              ELSE

              ; Software SPI on the centronics parallel port.
              RLCA                                                       ; 65432107
              RLCA                                                       ; 54321076
              RLCA                                                       ; 43210765  - Adjust so that starting bit is same position as Data line.
              LD    E,A                                                  ; E = Character to send.
              LD    B,8                                                  ; B = Bit count
SPIOUT0:      LD    A,E
              AND   DOUT_MASK                                            ; Data bit to data line, clock and cs low.
              RLC   E
SPIOUT1:      OUT   (SPI_OUT),A
              OR    CLOCK_HIGH                                           ; Clock high
              OUT   (SPI_OUT),A
              AND   CLOCK_MASK                                           ; Clock low
              OUT   (SPI_OUT),A
              DJNZ  SPIOUT0                                              ; Perform actions for the full 8 bits.
              RET
              ENDIF
            ENDIF

            ; Method to receive a byte from the SD card via the SPI protocol.
            ; This method uses the hardware shift registers.
            ; NB. Timing must be very similar in SPIOUT and SPIIN.
            ;
            ; Output: A = received byte.
            ;
SPIIN:      IF HW_SPI_ENA = 1
              ; Hardware SPI on the RFS v2+ PCB.
              LD    (HWSPISTART),A                                       ; Commence transmission to receive back data from the SD card, we just send 1's.
              LD    A,(HWSPIDATA)                                        ; Get the data byte.
              RET
            
            ELSE

              ; Software SPI on the RFS v2+ PCB.
              IF SW_SPI_ENA = 1

              ELSE

              ; Software SPI on the centronics parallel port.
              LD    BC,00800H | SPI_OUT                                  ; B = Bit count, C = clock port
              LD    L,0                                                  ; L = Character being read.
              LD    D,DOUT_HIGH | CLOCK_LOW   | CS_LOW                   ; Output a 0
              OUT   (C),D                                                ; To start ensure clock is low and CS is low.
              LD    E,DOUT_HIGH | CLOCK_HIGH  | CS_LOW                   ; Output a 0
SPIIN1:       OUT   (C),E                                                ; Clock to high.
              IN    A,(SPI_IN)                                           ; Input the received bit
              OUT   (C),D                                                ; Clock to low.
              SRL   A
              RL    L
              DJNZ  SPIIN1                                               ; Perform actions for the full 8 bits.
              LD    A,L                                                  ; return value
              RET
              ENDIF
            ENDIF
            ;-------------------------------------------------------------------------------
            ; End of SPI SD Controller
            ;-------------------------------------------------------------------------------            


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


            ; Method to read a sector or partial sector contents to an SD Card.
            ;
            ; This method was originally a C routine I was using for FatFS but optimised it (still more can be done). The C->ASM is not so optimal.
            ;
            ; Input: Memory variables: SDSTARTSEC= unsigned long sector.   - The sector number or direct byte address for older cards. This is big endian as per card.
            ;                      HL: Address where to store data read from sector.
            ; Output: A = 0 - All ok. A > 0 - error occurred.
            ;
?SD_READ:   DI 
            PUSH    HL                                                   ; Store the load address.
            LD      A,000H
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

            LD      BC,SD_SECSIZE                                        ; Size of full sector + 2 bytes CRC.
            POP     HL                                                   ; Get the store address into HL.
SD_READ4:   PUSH    HL                                                   ; Start reading bytes into the buffer.
            PUSH    BC
            CALL    SPIIN
            POP     BC
            POP     HL
            LD      (HL),A
            INC     HL                                                   ; Update buffer pointer.
            DEC     BC
            LD      A,B
            OR      C
            JP      NZ,SD_READ4                                          ; Not zero, keep reading.

            INC     BC                                                   ; Were not interested in the CRC so skip it.
            INC     BC
            CALL    SPISKIP

            LD      A,0                                                  ; And exit with success.
SD_READ5:   PUSH    AF
            LD      A,0FFH                                               ; Disable CS therefore deselecting the SD Card.
            CALL    SPICS
            POP     AF
     EI
            RET
SD_READ6:   POP     HL
            LD      A,1
            JR      SD_READ5


            ; Method to write a 512byte sector to an SD Card.
            ;
            ; Input: Memory variables: SDSTARTSEC= unsigned long sector.   - The sector number or direct byte address for older cards. This is big endian as per card.
            ;                      HL: Address of buffer to read data from.
            ; Output: A = 0 - All ok. A > 0 - error occurred.
?SD_WRITE:  PUSH    HL

            LD      A,000H                                               ; Activate CS (set low).
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
            LD      DE,SD_SECSIZE
            POP     HL                                                   ; Address to read data from.
SD_WRITE2:  LD      A,D                                                  ; So long as we have bytes in the buffer, send to the card for writing.
            OR      E
            JP      Z,SD_WRITE3

            PUSH    DE
            LD      A,(HL)                                               ; Get the byte to transmit.
            INC     HL                                                   ; And update the pointer.
            CALL    SPIOUT                                               ; Transmit value in A.
            POP     DE
            DEC     DE
            JR      SD_WRITE2

            ; Close transaction.
SD_WRITE3:  INC     DE                                                   ; Add 2 bytes for CRC
            INC     DE 
SD_WRITE4:  LD      A,D                                                  ; Test to see if we are already at zero, ie. all bytes sent. Exit if so.
            OR      E
            JP      Z,SD_WRITE5                    
            DEC     DE
            PUSH    DE
            LD      A,0                                                  ; Send 0's as padding bytes and CRC.
            CALL    SPIOUT
            POP     DE
            JP      SD_WRITE4

SD_WRITE5:  CALL    SPIIN                                                ; Check received response, if 0x05 which indicates write under way inside SD Card.
            AND     01FH
            LD      L,A
            LD      H,0
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

SD_WRITE9:  PUSH    AF
            LD      A,0FFH                                               ; Disable SD Card Chip Select to finish.
            CALL    SPICS
            POP     AF
            RET
SD_WRITE10: POP     HL                                                   ; Waste the load address.
SD_WRITE11: LD      A,1                                                  ; Error exit.
            JR      SD_WRITE9



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

            ; Method to get the LBA sector from the current CP/M Track and Sector.
            ; This method needs to account for the Rom Filing System image and the other CPM disk images on the SD card.
            ;
            ; Input:  (CDISK)  = Disk number
            ;         (HSTTRK) = Track
            ;         (HSTSEC) = Sector
            ; Output: (SDSTARTSEC) = LBA on SD Card for the desired sector.
            ;         DEHL         = LBA on SD Card for the desired sector.
            ;
?SD_GETLBA: PUSH    AF                                                   ; If needed, pass A and flags via the stack. NB This push is removed by BANKTOBANK so no need to pop after the call.
            LD      A,ROMBANK11 << 4 | ROMBANK10                         ; Calling a function in Bank 11 (CBIOS Bank 4) and returning to current bank 10 (CBIOS Bank 3).
            LD      HL,QGETMAPDSK                                        ; Calling the map disk function.
            CALL    BANKTOBANK                                           ; Now make a bank to bank function call.
            CP      0FFH
            JR      Z,SDGETLBAX                                          ; This isnt a physical, ROM disk or SD disk, no need to perform any actions, exit.
            CP      040H
            JR      C,SDGETLBAX                                          ; This isnt a ROM disk or an SD disk, no need to perform any actions, exit.
            AND     03FH                                                 ; Get the SD disk number.

            LD      B,0
            LD      C,A
            LD      DE,CPM_SD_IMGSZ / SD_SECSIZE
            CALL    MULT16X16
            LD      (SDSTARTSEC),DE
            LD      (SDSTARTSEC+2),HL

            ; DEHL contains the offset for the Disk number, ie. 0 for drive 1, CPM IMAGE SIZE for drive 2, 2x CPM IMAGE SIZE for drive 3 etc.
            LD      B,0
            LD      C, SD_SECPTRK                                        ; Number of sectors per track.
            LD      DE,(HSTTRK)                                          ; For the SD Card we use the full 16bit track number.
            CALL    MULT16X16

            ; Add the two.
            CALL    ADD32

            ; Add the number of sectors directly to the current sum.
            LD      A,(HSTSEC)
            LD      C,A
            LD      B,0
            CALL    ADD3216

            ; Now add the offset to account for the RFS image.
            IF      RFS_END_ADDR/SD_SECSIZE < 010000H
              LD      BC, RFS_END_ADDR/SD_SECSIZE                        ; Sector offset for the RFS Image.
              CALL    ADD3216
            ELSE
              LD      BC,0                                               ; Padding is to an even address so lower word will always be zero.
              ADD     HL,BC
              EX      DE,HL
              LD      BC,(RFS_END_ADDR/SD_SECSIZE) / 010000H             ; Upper word addition.
              ADC     HL,BC
              EX      DE,HL
            ENDIF

            ; Store the final sum as the start sector.
            PUSH    HL
            LD      HL,SDSTARTSEC
            LD      (HL),D
            INC     HL
            LD      (HL),E
            INC     HL
            POP     DE
            LD      (HL),D
            INC     HL
            LD      (HL),E
            LD      HL,(SDSTARTSEC)                                     
            OR      1                                                    ; Indicate we successfully mapped the track/sector to an LBA.
SDGETLBAX:  RET


            ; Method to read a sector for CPM using its track/sector addressing. All reads occur in a 512byte sector.
            ;
            ; Inputs: (HSTTRK) - 16bit track number.
            ;         (HSTSEK) - 8bit sector number.
            ;         (CDISK)  - Disk drive number.
?SDC_READ:  CALL    ?SD_GETLBA                                           ; Get the SD card sector in LBA,
            LD      A,1
            JP      Z,SDC_READ1                                          ; Error in read, exit with stack tidy.
            LD      HL,HSTBUF                                            ; Address of the host buffer to hold the sector.
            CALL    ?SD_READ                                             ; Read in the sector.
            OR      A
            JR      NZ,SDC_READ1                                         ; Check for errors and report.
            XOR     A                                                    ; Indicate success.
SDC_READ1:  RET

            ; Method to write a sector for CPM using its track/sector addressing. All writes occur in a 512byte sector.
            ;
            ; Inputs: (HSTTRK) - 16bit track number.
            ;         (HSTSEK) - 8bit sector number.
            ;         (CDISK)  - Disk drive number.
            ; Outputs: A = 1 - Error.
            ;          A = 0 - Success.
?SDC_WRITE: CALL    ?SD_GETLBA                                           ; Get the SD card sector in LBA,
            LD      A,1
            JP      Z,SDC_WRITE1                                         ; Error in read, exit with stack tidy.
            LD      HL,HSTBUF                                            ; Setup the location of the buffer to write.
            CALL    ?SD_WRITE                                            ; Call write to write the buffer into the given sector.
            JR      NZ,SDC_WRITE1
            XOR     A
SDC_WRITE1: RET

            ;-------------------------------------------------------------------------------
            ; END OF SD CARD CONTROLLER FUNCTIONALITY
            ;-------------------------------------------------------------------------------

            ; Align to end of bank.
            ALIGN   UROMADDR + 07F8h
            ORG     UROMADDR + 07F8h
            DB      0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh

