/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            sdmmc.c
// Created:         March 2020
// Author(s):       ChaN (framework), Philip Smart (Sharp MZ80A/RFS Z80 code and customisation)
// Description:     Functionality to enable connectivity between the PetitFS ((C) ChaN) and the RFS
//                  subsystem of the Sharp MZ80A for SD drives. This module provides the public
//                  interfaces to interact with the hardware.
//                  Low level functions were written in C and the two disk_<func> methods were
//                  initially written in C but then converted into Z80 and optimised. The end purpose is
//                  to use the functions in this module inside the RFS roms.
//
// Credits:         
// Copyright:       (C) 2013, ChaN, all rights reserved - framework.
// Copyright:       (C) 2020 Philip Smart <philip.smart@net2net.org>
//
// History:         March 2020   - Initial development.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// This source file is free software: you can redistribute it and#or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
/////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include "pff.h"                 /* Obtains integer types for Petit FatFs */
#include "sdmmc.h"               /* Common include file for the disk I/O layer */

/*-------------------------------------------------------------------------*/
/* Platform dependent macros and functions needed to be modified           */
/*-------------------------------------------------------------------------*/

#define SPI_OUT     0xFF
#define SPI_IN      0xFE
#define DOUT_LOW    0x00
#define DOUT_HIGH   0x04
#define DOUT_MASK   0x04
#define DIN_LOW     0x00
#define DIN_HIGH    0x01
#define CLOCK_LOW   0x00
#define CLOCK_HIGH  0x02
#define CLOCK_MASK  0xFD
#define CS_LOW      0x00
#define CS_HIGH     0x01

/*--------------------------------------------------------------------------
   Module Private Functions
---------------------------------------------------------------------------*/

/* MMC/SD command (SPI mode) */
#define CMD0        64 + 0         /* GO_IDLE_STATE */
#define CMD1        64 + 1         /* SEND_OP_COND */
#define ACMD41      0x40+41        /* SEND_OP_COND (SDC) */
#define CMD8        64 + 8         /* SEND_IF_COND */
#define CMD9        64 + 9         /* SEND_CSD */
#define CMD10       64 + 10        /* SEND_CID */
#define CMD12       64 + 12        /* STOP_TRANSMISSION */
#define CMD13       64 + 13        /* SEND_STATUS */
#define ACMD13      0x40+13        /* SD_STATUS (SDC) */
#define CMD16       64 + 16        /* SET_BLOCKLEN */
#define CMD17       64 + 17        /* READ_SINGLE_BLOCK */
#define CMD18       64 + 18        /* READ_MULTIPLE_BLOCK */
#define CMD23       64 + 23        /* SET_BLOCK_COUNT */
#define ACMD23      0x40+23        /* SET_WR_BLK_ERASE_COUNT (SDC) */
#define CMD24       64 + 24        /* WRITE_BLOCK */
#define CMD25       64 + 25        /* WRITE_MULTIPLE_BLOCK */
#define CMD32       64 + 32        /* ERASE_ER_BLK_START */
#define CMD33       64 + 33        /* ERASE_ER_BLK_END */
#define CMD38       64 + 38        /* ERASE */
#define CMD55       64 + 55        /* APP_CMD */
#define CMD58       64 + 58        /* READ_OCR */
#define SECTOR_SIZE 512            /* Default size of an SD Sector */

/* Card type flags (CardType) */
#define CT_MMC      0x01        /* MMC ver 3 */
#define CT_SD1      0x02        /* SD ver 1 */
#define CT_SD2      0x04        /* SD ver 2 */
#define CT_SDC      CT_SD1|CT_SD2 /* SD */
#define CT_BLOCK    0x08        /* Block addressing */

static DSTATUS Stat =  STA_NOINIT; /* Disk status */
BYTE SDBUF[11];
BYTE SDVER;
BYTE SDCAP;
static    DRESULT RESULT;
static    UINT BYTECNT;
static    UINT WRITECNT;
//static    BYTE d;


/*--------------------------------------------------------------------------
   Public Functions
---------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------*/
/* Initialize Disk Drive                                                 */
/*-----------------------------------------------------------------------*/
DSTATUS disk_initialize (void)
{
#asm
            ; Method to initialise the SD card.
            ;
SDINIT:     LD      A,$00                                                ; CS to high
            CALL    SPICS
            ;
            CALL    SPIINIT                                              ; Train SD with our clock.
            ;
            LD      A,$FF                                                ; CS to low
            CALL    SPICS
            LD      BC,$FFFF
     
SDINIT1:    LD      A,CMD0                                               ; Command 0
            LD      HL,$0000                                             ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,$0000                                             ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD

            PUSH    BC
            LD      A,(_SDBUF+6)                                          ; Get response code.
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
            LD      HL,$0000                                             ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,$AA01                                             ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD

            ; Version 2 card, check its voltage range. IF not in the 2.7-3.6V dont try the ACMD41 to get capabilities.
SDINIT3:    LD      A,1                                                  ; Check that we receive 0x0001AA in response.
            LD      (_SDVER),A                                           ; Indicate this is not a version 2 card.
            LD      A,(_SDBUF+9)
            CP      1
            JP      NZ,SDINIT8
            LD      A,(_SDBUF+10)
            CP      $AA
            JP      NZ,SDINIT8

SDINIT4:    LD      A,2                                                  ; This is a version 2 card.
SDINIT5:    LD      (_SDVER),A                                           ; Indicate this is not a version 2 card.

            CALL    SDACMD41 
            JR      Z,SDINIT6
            LD      A,2                                                  ; Error, card is not responding to ACMD41
            JP      SD_EXIT

SDINIT6:    LD      A,CMD58                                              ; CMD58 has 0x00000000 as parameter, load up registers and call command routine.
            LD      HL,$0000                                             ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,$0000                                             ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(_SDBUF+6)
            CP      $40
            LD      A,CT_SD2
            JR      Z,SDINIT7
            LD      A,CT_SD2 | CT_BLOCK
SDINIT7:    LD      (_SDCAP),A                                           ; Set the capabilities according to the returned flag.
            JR      SDINIT14


            ; Version 1 card or MMC v3.
SDINIT8:    CALL    SDACMD41
            LD      A, CT_SD1
            LD      E,ACMD41                                             ; SD1 cards we use the ACMD41 command.
            JR      Z,SDINIT9
            LD      A,CT_MMC
            LD      E,CMD1                                               ; MMC cards we use the CMD1 command.
SDINIT9:    LD      (_SDCAP),A
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
            LD      HL,$0000                                             ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,$0000                                             ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(_SDBUF+6)                                         ; Should be a response of 0 whereby the card has left idle.
            OR      A
            JR      Z,SDINIT13
            LD      BC,$FFFF                                             ; Delay for at least 200mS for the card to recover and be ready.
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
            LD      HL,$0000                                             ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,$0002                                             ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(_SDBUF+6)
            OR      A
            JR      Z,SDINIT14
            LD      A,0
            LD      (_SDCAP),A                                           ; No capabilities on this unknown card.
SDINIT14:   LD      A,0
            JR      SD_EXIT
SD_EXIT:    LD      L,A                                                  ; Return value goes into HL.
            LD      H,0
#endasm
}


#asm
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
SDCMD:      LD      (_SDBUF),A
            LD      (_SDBUF+1),HL
            EX      DE,HL
            LD      (_SDBUF+3),HL
            ;
            LD      B,5                                                  ; R1 + 32bit argument for CMD8, CMD58
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
            LD      (_SDBUF+5),A
            LD      A,255                                                ; Preamble byte
            CALL    SPIOUT
            LD      HL,_SDBUF
            LD      B,6
SDCMD1:     PUSH    BC
            LD      A,(HL)
            INC     HL
            CALL    SPIOUT                                               ; Send the command and parameters.
            POP     BC
            DJNZ    SDCMD1
            PUSH    HL
SDCMD2:     CALL    SPIIN
            CP      $FF
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
            LD      HL,$0000                                             ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,$0000                                             ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(_SDBUF+6)                                         ; Should be a response of 0 whereby the card has left idle.
            DEC     A
            JR      NZ,SDACMD

            POP     HL
            POP     DE
            POP     AF
            CALL    SDCMD
            LD      A,(_SDBUF+6)                                         ; Should be a response of 0 whereby the card has left idle.
            OR      A
            RET

            ; Method to send Application Command 41 to the SD card. This command involves retries and delays
            ; hence coded seperately.
            ;
            ; Returns Z set if successful, else NZ.
            ;
SDACMD41:   LD      BC,10                                                ; ACMD41/CMD55 may take some cards time to process or respond, so give a large number of retries.
SDACMD1:    PUSH    BC
            LD      A,ACMD41                                             ; ACMD41 has 0x40000000 as parameter, load up registers and call command routine.
            LD      HL,$0040                                             ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,$0000                                             ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDACMD
            LD      A,(_SDBUF+6)                                         ; Should be a response of 0 whereby the card has left idle.
            OR      A
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
SDACMD3:    OR      A
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
SPIIN:      LD      BC,$800 | SPI_OUT                                    ; B = Bit count, C = clock port
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
            ; We take the value off the stack, shift left 9 times then store the result back onto the stack.
            ;
            ; Input: HL = Stack offset.
LBATOADDR:  ADD     HL,SP                                                ; Retrieve sector from stack.
            PUSH    HL
            LD      A,(HL)
            INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            LD      H,A
            LD      L,0
            SLA     H                                                    ; Shift the long left by 9 to effect a x512
            RL      E
            RL      D
            POP     BC
            LD      A,L
            LD      (BC),A
            INC     BC
            LD      A,H
            LD      (BC),A
            INC     BC
            LD      A,E
            LD      (BC),A
            INC     BC
            LD      A,D
            LD      (BC),A
            RET
#endasm


/*-----------------------------------------------------------------------*/
/* Read partial sector                                                   */
/*-----------------------------------------------------------------------*/
DRESULT disk_readp ( BYTE *buff,        /* Pointer to the read buffer (NULL:Read bytes are forwarded to the stream) */
                     DWORD sector,      /* Sector number (LBA) */
                     UINT offset,       /* Byte offset to read from (0..511) */
                     UINT count  )      /* Number of bytes to read (ofs + cnt mus be <= 512) */
{
#asm
            ; parameter 'unsigned int count' at 2 size(2)
            ; parameter 'unsigned int offset' at 4 size(2)
            ; parameter 'unsigned long sector' at 6 size(4)
            ; parameter 'unsigned char BYTE*buff' at 10 size(2)

            LD      A,0
            CALL    SPICS                                                ; Set CS low (active).

            LD      HL,(_SDCAP)                                          ; Test to see if CT_BLOCK is available.
            LD      H,0
            LD      A,CT_BLOCK
            AND     L
            JP      NZ,READP_3                                           ; If it has CT_BLOCK then use sector numbers otherwise multiply up to bytes.

            LD      HL,6 + 2                                             ; It isnt so we need to convert the block to bytes by x512.
            CALL    LBATOADDR

READP_3:    LD      HL,1    
            LD      (_RESULT),HL

            ; A = ACMD to send
            ; LHED = Argument, ie. ACMD = A, L, H, E, D, CRC
            LD      HL,6                                                 ; Sector is stored as 3rd paramneter at offset 6, retrieve and arrange in little endian order in LHED
            ADD     HL,SP
            LD      D,(HL)
            INC     HL
            LD      E,(HL)
            INC     HL
            PUSH    DE
            LD      D,(HL)
            INC     HL
            LD      E,(HL)
            LD      A,CMD17                                              ; Send CMD17 to read a sector.
            POP     HL
            EX      DE,HL
            CALL    SDCMD
            LD      A,(_SDBUF+6)                                         ; Fetch result and store.
            AND     A
            JP      NZ,READP_4

            LD      HL,1000                                              ; Sit in a tight loop waiting for the data packet arrival (ie. not 0xFF).
READP_7:    PUSH    HL
            LD      HL,200    
            CALL    T_DELAY
            CALL    SPIIN
            POP     HL
            CP      255
            JP      NZ,READP_6 
            DEC     HL
            LD      A,H
            OR      L
            JR      NZ,READP_7

READP_6:    CP      254
            JP      NZ,READP_4
            LD      HL,4    
            ADD     HL,SP
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            LD      HL,514
            AND     A
            SBC     HL,DE
            EX      DE,HL
            POP     BC
            POP     HL
            PUSH    HL
            PUSH    BC
            EX      DE,HL
            AND     A
            SBC     HL,DE
            LD      (_BYTECNT),HL

            LD      HL,4    
            ADD     HL,SP
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            LD      A,H
            OR      L
            JP      Z,READP_11

            PUSH    HL
            POP     BC
            CALL    SPISKIP

READP_11:   LD      HL,10                                                ; Get the buffer pointer from where to read data.
            ADD     HL,SP
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            LD      A,H
            OR      L
            JP      Z,READP_12

READP_15:   PUSH    HL
            CALL    SPIIN
            POP     HL
            LD      (HL),A
            INC     HL
            PUSH    HL
            POP     BC

            LD      HL,10                                                ; Update the pointer on the stack with register copy.
            ADD     HL,SP
            LD      (HL),C
            INC     HL
            LD      (HL),B
READP_13:   POP     DE                                                   ; Return address.
            POP     HL                                                   ; Count
            DEC     HL                                                   ; Decrement count
            PUSH    HL                                                   ; And return stack to previous state.
            PUSH    DE
            LD      A,H
            OR      L
            PUSH    BC
            POP     HL
            JP      NZ,READP_15

READP_12:   LD      HL,(_BYTECNT)
            PUSH    HL
            POP     BC
            CALL    SPISKIP
            LD      HL,0    
            LD      (_RESULT),HL
READP_4:
            LD      A,0
            CALL    SPICS
            LD      HL,(_RESULT)
#endasm
}



/*-----------------------------------------------------------------------*/
/* Write partial sector                                                  */
/*-----------------------------------------------------------------------*/
DRESULT disk_writep ( const BYTE *buff,    /* Pointer to the bytes to be written (NULL:Initiate/Finalize sector write) */
                      DWORD sc          )  /* Number of bytes to send, Sector number (LBA) or zero */
{
#asm
            ; parameter 'unsigned long sc' at 2 size(4)
            ; parameter 'const unsigned char BYTE*buff' at 6 size(2)
            LD      HL,1        
            LD      (_RESULT),HL

            LD      A,$FF                                                ; Activate CS (set low).
            CALL    SPICS

            LD      HL,6                                                 ; If buffer is not null, we are writing data, otherwise we are instigating a write transaction.
            ADD     HL,SP
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            LD      A,H
            OR      L
            JP      Z,WRITEP_3                                           ; NULL so we are performing a transaction open/close.

            LD      HL,2                                                 ; Get the sector into DEHL.
            ADD     HL,SP
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            LD      (_BYTECNT),HL                                        ; Only interested in the lower 16bit value of the long.

WRITEP_4:   LD      A,H                                                  ; So long as we have bytes in the buffer, send to the card for writing.
            OR      L
            JP      Z,WRITEP_5
            LD      HL,(_WRITECNT)                                       ; Count of bytes to write.
            LD      A,H
            OR      L
            JR      Z,WRITEP_5                                           ; If either the max count (512) or the requested count (_BYTECNT) have expired, exit.

            LD      HL,6                                                 ; Load the buffer pointer.
            ADD     HL,SP
            INC     (HL)
            LD      A,(HL)
            INC     HL
            JR      NZ,WRITEP_2                                          ; Increment by 1 carrying overflow into MSB.
            INC     (HL)
WRITEP_2:   LD      H,(HL)
            LD      L,A
            DEC     HL                                                   ; Back to current byte.
            LD      A,(HL)
            CALL    SPIOUT
            LD      HL,(_WRITECNT)                                       ; Decrement the max count.
            DEC     HL
            LD      (_WRITECNT),HL
            LD      HL,(_BYTECNT)                                        ; Decrement the requested count.
            DEC     HL
            LD      (_BYTECNT),HL
            JP      WRITEP_4

WRITEP_5:   LD      HL,0        
            LD      (_RESULT),HL
            JP      WRITEP_8

WRITEP_3:   LD      HL,2                                                 ; Get the sector number into DEHL to test.
            ADD     HL,SP
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            EX      DE,HL
            LD      A,H
            OR      L
            OR      D
            OR      E
            JP      Z,WRITEP_9                                           ; Sector is 0 so finalise the write transaction.

            LD      HL,(_SDCAP)                                          ; Check to see if the card has block addressing.
            LD      H,0
            LD      A,CT_BLOCK
            AND     L
            JP      NZ,WRITEP_10                                         ; If it hasnt then we need to multiply up to the correct byte.

            LD      HL,2 + 2                                             ; Fetch the sector number, multiply (by left shift x 9) x512 and store.
            CALL    LBATOADDR

            ; A = ACMD to send
            ; LHED = Argument, ie. ACMD = A, L, H, E, D, CRC
WRITEP_10:  LD      HL,2                                                 ; Sector is stored as 3rd paramneter at offset 6, retrieve and arrange in little endian order in LHED
            ADD     HL,SP
            LD      D,(HL)
            INC     HL
            LD      E,(HL)
            INC     HL
            PUSH    DE
            LD      D,(HL)
            INC     HL
            LD      E,(HL)
            LD      A,CMD24                                              ; Send CMD24 to write a sector.
            POP     HL
            EX      DE,HL
            CALL    SDCMD
            LD      A,(_SDBUF+6)                                         ; Fetch result and store.
           ;LD      (_d),A
            AND     A
            JP      NZ,WRITEP_8
            LD      A,255
            CALL    SPIOUT
            LD      A,254
            CALL    SPIOUT
            LD      HL,512        
            LD      (_WRITECNT),HL
            LD      HL,0        
            LD      (_RESULT),HL
            JP      WRITEP_8

WRITEP_9:   LD      HL,(_WRITECNT)
            INC     HL
            INC     HL
            LD      (_BYTECNT),HL
WRITEP_13:
            LD      HL,(_BYTECNT)
            DEC     HL
            LD      (_BYTECNT),HL
            INC     HL
            LD      A,H
            OR      L
            JP      Z,WRITEP_14
            LD      A,0
            CALL    SPIOUT
            JP      WRITEP_13
WRITEP_14:
            CALL    SPIIN
            AND     $1F
            LD      L,A
            LD      H,0
            CP      5
            JP      NZ,WRITEP_15

            LD      HL,10000        
            PUSH    HL
            JR      WRITEP_18
WRITEP_20:  DEC     HL
            PUSH    HL
            LD      HL,200        
            CALL    T_DELAY
WRITEP_18:  CALL    SPIIN
            POP     HL
            CP      255
            JP      Z,WRITEP_17
            LD      A,H
            OR      L
            JR      NZ,WRITEP_20

WRITEP_17:  LD      A,H
            OR      L
            JP      Z,WRITEP_15
            LD      HL,0        
            LD      (_RESULT),HL
WRITEP_15:  LD      A,$00
            CALL    SPICS
WRITEP_8:   LD      HL,(_RESULT)               

#endasm
}
