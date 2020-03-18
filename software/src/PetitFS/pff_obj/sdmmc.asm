;* * * * *  Small-C/Plus z88dk * * * * *
;  Version: 16120-f784809cf-20200301
;
;	Reconstructed for z80 Module Assembler
;
;	Module compile time: Sun Mar 15 00:33:56 2020



	MODULE	sdmmc_c


	INCLUDE "z80_crt0.hdr"


	SECTION	data_compiler
._Stat
	defb	1
	SECTION	code_compiler

; Function spi_init flags 0x00000200 __smallc 
; int spi_init()
._spi_init
            ; Method to initialise communications with the SD card. We basically train it to our clock characteristics.
            ; This is important, as is maintaining the same clock for read or write otherwise the card may not respond.
SPI_INIT:   LD      B,80
SPI_INIT1:  LD      A, 0x04  |  0x02   |  0x01                    ; Output a 1
            OUT     ( 0xFF ),A
            LD      A, 0x04  |  0x00    |  0x01                    ; Output a 1
            OUT     ( 0xFF ),A
            DJNZ    SPI_INIT1
            LD      HL,0                                                 ; hl is the return parameter
	ret



; Function spi_cs flags 0x00000200 __smallc 
; int spi_cs(unsigned char b)
; parameter 'unsigned char b' at 2 size(1)
._spi_cs
            ; Method to set the Chip Select level on the SD card. The Chip Select is active LOW.
            ;
            ; A = 0    - Set CS HIGH
            ; A = 0xFF - Set CS LOW
SPI_CS:     LD      HL,2
            ADD     HL,SP                                                ; skip over return address on stack
            LD      A,(HL)                                               ; a = b, "char b" occupies 16 bits on stack
                                                                         ;  but only the LSB is relevant
            OR      A
            LD      A, 0x04  |  0x00   |  0x01                    ; Set CS High if parameter = 0 (ie. disable)
            JR      Z, SPI_CS0
            LD      A, 0x04  |  0x00   |  0x00                     ; Set CS Low if parameter != 0 (ie. disable)
SPI_CS0:    OUT     ( 0xFF ),A
            LD      HL,0                                                 ; hl is the return parameter
	ret



; Function spi_out flags 0x00000200 __smallc 
; int spi_out(unsigned char b)
; parameter 'unsigned char b' at 2 size(1)
._spi_out
            ; Method to send a byte to the SD card via the SPI protocol.
            ; This method uses the bitbang technique, change if hardware spi is available.
            ;
            ; Input A = Byte to send.
            ;
            LD      HL,2
            ADD     HL,SP                                                ; skip over return address on stack
            LD      A,(HL)                                               ; a = b, "char b" occupies 16 bits on stack
                                                                         ;  but only the LSB is relevant
            RLCA                                                         ; 65432107
            RLCA                                                         ; 54321076
            RLCA                                                         ; 43210765  - Adjust so that starting bit is same position as Data line.
            LD      E,A                                                  ; E = Character to send.
            LD      B,8                                                  ; B = Bit count
SPI_OUT0:   LD      A,E
            AND      0x04                                             ; Data bit to data line, clock and cs low.
            RLC     E
SPI_OUT1:   OUT     ( 0xFF ),A
            OR       0x02                                            ; Clock high
            OUT     ( 0xFF ),A
            AND      0xFD                                            ; Clock low
            OUT     ( 0xFF ),A
            DJNZ    SPI_OUT0                                             ; Perform actions for the full 8 bits.
            LD      HL,0                                                 ; hl is the return parameter    
	ret



; Function spi_in flags 0x00000200 __smallc 
; unsigned char uint8_tspi_in()
._spi_in
            ; Method to receive a byte from the SD card via the SPI protocol.
            ; This method uses the bitbang technique, change if hardware spi is available.
            ; NB. Timing must be very similar in SPIOUT and SPIIN.
            ;
            ; Output: A = received byte.
            ;
            LD      BC,$800 |  0xFF                                     ; B = Bit count, C = clock port
            LD      L,0                                                  ; L = Character being read.
            LD      D, 0x04  |  0x00    |  0x00                    ; Output a 0
            OUT     (C),D                                                ; To start ensure clock is low and CS is low.
            LD      E, 0x04  |  0x02   |  0x00                    ; Output a 0
SPI_IN1:    OUT     (C),E                                                ; Clock to high.
            IN      A,( 0xFE )                                           ; Input the received bit
            OUT     (C),D                                                ; Clock to low.
            SRL     A
            RL      L
            DJNZ    SPI_IN1                                              ; Perform actions for the full 8 bits.
            LD      H,0                                                  ; hl is the return parameter, L already set to received byte.
	ret



; Function spi_skip flags 0x00000200 __smallc 
; void spi_skip(unsigned int n)
; parameter 'unsigned int n' at 2 size(2)
._spi_skip
            LD      HL,2
            ADD     HL,SP                                                ; skip over return address on stack
            LD      C,(HL)                                               ; n occupies 16 bits on stack
            INC     HL
            LD      B,(HL)
SPISKIP0:   PUSH    BC
            CALL    SPIIN
            POP     BC
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,SPISKIP0
	ret



; Function send_cmd flags 0x00000200 __smallc 
; unsigned char BYTEsend_cmd(unsigned char cmd, unsigned long arg)
; parameter 'unsigned long arg' at 2 size(4)
; parameter 'unsigned char cmd' at 6 size(1)
._send_cmd
            ; Method to send a command to the card and receive back a response.
            ;
            ; A = CMD to send
            ; LHED = Argument, ie. CMD = A, L, H, E, D, CRC
            ;
            LD      HL,2
            ADD     HL,SP                                                ; skip over return address on stack
            LD      A,(HL)
            LD      (_SDBUF+4),A
            INC     HL
            LD      A,(HL)
            LD      (_SDBUF+3),A
            INC     HL
            LD      A,(HL)
            LD      (_SDBUF+2),A
            INC     HL
            LD      A,(HL)
            LD      (_SDBUF+1),A
            INC     HL
            LD      A,(HL)
            LD      (_SDBUF),A
            ;
            LD      B,5                                                  ; R1 + 32bit argument for  (8) ,  (58) 
            CP       (8) 
            LD      C,135
            JP      Z,SD_CMD0
            LD      C,1                                                  ;  (58)  is not CRC checked so just set to 0x01.
            CP       (58) 
            LD      B,5                                                  ; R1 + 32bit argument
            JP      Z,SD_CMD0
            ;
            LD      B,1                                                  ; Default, expect R1 which is 1 byte.
            CP       (0)                                                  ; Work out the CRC based on the command. CRC checking is
            LD      C,149                                                ; not implemented but certain commands require a fixed argument and CRC.
            JP      Z,SD_CMD0
            LD      C,1                                                  ; Remaining commands are not CRC checked so just set to 0x01.
SD_CMD0:    PUSH    BC                                                   ; Save the CRC and the number of bytes to be returned,
            LD      A,C                                                  ; Store the CRC
            LD      (_SDBUF+5),A
            LD      A,255                                                ; Preamble byte
            CALL    SPIOUT
            LD      HL,_SDBUF
            LD      B,6
SD_CMD1:    PUSH    BC
            LD      A,(HL)
            INC     HL
            CALL    SPIOUT                                               ; Send the command and parameters.
            POP     BC
            DJNZ    SD_CMD1
            PUSH    HL
SD_CMD2:    CALL    SPIIN
            CP      $FF
            JR      Z,SD_CMD2
            JR      SD_CMD4
SD_CMD3:    PUSH    BC
            PUSH    HL
            CALL    SPIIN                                                ; 
SD_CMD4:    POP     HL
            LD      (HL),A
            INC     HL
            POP     BC                                                   ; Get back number of expected bytes. HL = place in buffer to store response.
            DJNZ    SD_CMD3
            LD      A, 0x04  |  0x00   |  0x01 
            OUT     ( 0xFF ),A
            LD      A,(_SDBUF+6)
            LD      L,A
            LD      H,0
	ret



; Function disk_initialize flags 0x00000200 __smallc 
; unsigned char DSTATUSdisk_initialize()
._disk_initialize
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
SDINIT1:    LD      A, (0)                                                ; Command 0
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
            JP      SD_EXIT                                              ; Error, card is not responding to  (0) 
SDINIT2:    POP     BC
            ; Now send  (8)  to get card details. This command can only be sent 
            ; when the card is idle.
            LD      A, (8)                                                ;  (8)  has 0x00001AA as parameter, load up registers and call command routine.
            LD      HL,$0000                                             ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,$AA01                                             ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            ; Version 2 card, check its voltage range. IF not in the 2.7-3.6V dont try the  (0x80+41)  to get capabilities.
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
            LD      A,2                                                  ; Error, card is not responding to  (0x80+41) 
            JP      SD_EXIT
SDINIT6:    LD      A, (58)                                               ;  (58)  has 0x00000000 as parameter, load up registers and call command routine.
            LD      HL,$0000                                             ; NB. Important, HL should be coded as LH due to little endian and the way it is used in SDCMD.
            LD      DE,$0000                                             ; NB. Important, DE should be coded as ED due to little endian and the way it is used in SDCMD.
            CALL    SDCMD
            LD      A,(_SDBUF+6)
            CP      $40
            LD      A, 0x04 
            JR      Z,SDINIT7
            LD      A, 0x04  |  0x08 
SDINIT7:    LD      (_SDCAP),A                                           ; Set the capabilities according to the returned flag.
            JR      SDINIT14
            ; Version 1 card or MMC v3.
SDINIT8:    CALL    SDACMD41
            LD      A,  0x02 
            LD      E, (0x80+41)                                              ; SD1 cards we use the  (0x80+41)  command.
            JR      Z,SDINIT9
            LD      A, 0x01 
            LD      E, (1)                                                ; MMC cards we use the  (1)  command.
SDINIT9:    LD      (_SDCAP),A
            LD      A,E
            CP       (0x80+41) 
            JR      NZ,SDINIT10
            CALL    SDACMD41
            JR      Z,SDINIT14
            LD      A,3                                                  ; Exit code, failed to initialise v1 card.
            JP      SD_EXIT
SDINIT10:   LD      BC,10                                                ;  (0x80+41) / (55)  may take some cards time to process or respond, so give a large number of retries.
SDINIT11:   PUSH    BC
            LD      A, (1)                                                ;  (1)  has 0x00000000 as parameter, load up registers and call command routine.
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
SDINIT13:   LD      A, (16)                                               ; No response from the card for an  (0x80+41) / (1)  so try  (16)  with parameter 0x00000200
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
            RET
            ; Method to initialise communications with the SD card. We basically train it to our clock characteristics.
            ; This is important, as is maintaining the same clock for read or write otherwise the card may not respond.
SPIINIT:    LD      B,80
SPIINIT1:   LD      A, 0x04  |  0x02   |  0x01                    ; Output a 1
            OUT     ( 0xFF ),A
            LD      A, 0x04  |  0x00    |  0x01                    ; Output a 1
            OUT     ( 0xFF ),A
            DJNZ    SPIINIT1
            RET
            ; Method to set the Chip Select level on the SD card. The Chip Select is active LOW.
            ;
            ; A = 0    - Set CS HIGH
            ; A = 0xFF - Set CS LOW
SPICS:      OR      A
            LD      A, 0x04  |  0x00   |  0x01                    ; Set CS High if parameter = 0 (ie. disable)
            JR      Z, SPICS0
            LD      A, 0x04  |  0x00   |  0x00                     ; Set CS Low if parameter != 0 (ie. disable)
SPICS0:     OUT     ( 0xFF ),A
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
            LD      B,5                                                  ; R1 + 32bit argument for  (8) ,  (58) 
            CP       (8) 
            LD      C,135
            JP      Z,SDCMD0
            LD      C,1                                                  ;  (58)  is not CRC checked so just set to 0x01.
            CP       (58) 
            LD      B,5                                                  ; R1 + 32bit argument
            JP      Z,SDCMD0
            ;
            LD      B,1                                                  ; Default, expect R1 which is 1 byte.
            CP       (0)                                                  ; Work out the CRC based on the command. CRC checking is
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
            LD      A, 0x04  |  0x00   |  0x01 
            OUT     ( 0xFF ),A
            RET
            ; Method to send an Application Command to the SD Card. This involves sending  (55)  followed by the required command.
            ;
            ; A = ACMD to send
            ; LHED = Argument, ie. ACMD = A, L, H, E, D, CRC
            ;
SDACMD:     PUSH    AF
            PUSH    DE
            PUSH    HL
            LD      A, (55)                                               ;  (55)  has 0x00000000 as parameter, load up registers and call command routine.
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
SDACMD41:   LD      BC,10                                                ;  (0x80+41) / (55)  may take some cards time to process or respond, so give a large number of retries.
SDACMD1:    PUSH    BC
            LD      A, (0x80+41)                                              ;  (0x80+41)  has 0x40000000 as parameter, load up registers and call command routine.
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
            AND      0x04                                             ; Data bit to data line, clock and cs low.
            RLC     E
SPIOUT1:    OUT     ( 0xFF ),A
            OR       0x02                                            ; Clock high
            OUT     ( 0xFF ),A
            AND      0xFD                                            ; Clock low
            OUT     ( 0xFF ),A
            DJNZ    SPIOUT0                                              ; Perform actions for the full 8 bits.
            RET
            ; Method to receive a byte from the SD card via the SPI protocol.
            ; This method uses the bitbang technique, change if hardware spi is available.
            ; NB. Timing must be very similar in SPIOUT and SPIIN.
            ;
            ; Output: A = received byte.
            ;
SPIIN:      LD      BC,$800 |  0xFF                                     ; B = Bit count, C = clock port
            LD      L,0                                                  ; L = Character being read.
            LD      D, 0x04  |  0x00    |  0x00                    ; Output a 0
            OUT     (C),D                                                ; To start ensure clock is low and CS is low.
            LD      E, 0x04  |  0x02   |  0x00                    ; Output a 0
SPIIN1:     OUT     (C),E                                                ; Clock to high.
            IN      A,( 0xFE )                                           ; Input the received bit
            OUT     (C),D                                                ; Clock to low.
            SRL     A
            RL      L
            DJNZ    SPIIN1                                               ; Perform actions for the full 8 bits.
            LD      A,L                                                  ; return value
            RET
	ret



; Function disk_readp flags 0x00000200 __smallc 
; const int DRESULTdisk_readp(unsigned char BYTE*buff, unsigned long sector, unsigned int offset, unsigned int count)
; parameter 'unsigned int count' at 2 size(2)
; parameter 'unsigned int offset' at 4 size(2)
; parameter 'unsigned long sector' at 6 size(4)
; parameter 'unsigned char BYTE*buff' at 10 size(2)
._disk_readp
	push	bc
	push	bc
	push	bc
	dec	sp
	ld	hl,0	;const
	push	hl
	call	_spi_cs
	pop	bc
	ld	hl,(_SDCAP)
	ld	h,0
	ld	a,+(8 % 256)
	and	l
	ld	l,a
	call	l_lneg
	jp	nc,i_3
	ld	hl,13	;const
	add	hl,sp
	push	hl
	call	l_glong2sp
	ld	hl,512	;const
	ld	de,0
	call	l_long_mult
	pop	bc
	call	l_plong
.i_3
	ld	hl,5	;const
	add	hl,sp
	ld	(hl),+(1 % 256)
	inc	hl
	ld	(hl),+(1 / 256)
	ld	hl,17	;const
	push	hl
	ld	hl,15	;const
	call	l_glongsp	;
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,l
	and	a
	jp	nz,i_4
	ld	hl,1000	;const
	pop	bc
	push	hl
.i_7
	ld	hl,200	;const
	call	t_delay
	ld	hl,4	;const
	add	hl,sp
	push	hl
	call	_spi_in
	pop	de
	ld	a,l
	ld	(de),a
.i_5
	ld	hl,4	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	255
	jp	nz,i_8
	pop	hl
	dec	hl
	push	hl
	ld	a,h
	or	l
	jr	nz,i_9_i_8
.i_8
	jp	i_6
.i_9_i_8
	jp	i_7
.i_6
	ld	hl,4	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	254
	jp	nz,i_10
	ld	hl,11	;const
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,514
	and	a
	sbc	hl,de
	ex	de,hl
	ld	hl,9	;const
	call	l_gintsp	;
	ex	de,hl
	and	a
	sbc	hl,de
	pop	de
	pop	bc
	push	hl
	push	de
	ld	hl,11	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_11
	ld	hl,11	;const
	call	l_gintsp	;
	push	hl
	call	_spi_skip
	pop	bc
.i_11
	ld	hl,17	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_12
.i_15
	ld	hl,4	;const
	add	hl,sp
	push	hl
	call	_spi_in
	pop	de
	ld	a,l
	ld	(de),a
	ld	hl,17	;const
	add	hl,sp
	inc	(hl)
	ld	a,(hl)
	inc	hl
	jr	nz,ASMPC+3
	inc	(hl)
	ld	h,(hl)
	ld	l,a
	dec	hl
	push	hl
	ld	hl,6	;const
	add	hl,sp
	ld	a,(hl)
	pop	de
	ld	(de),a
.i_13
	ld	hl,9	;const
	add	hl,sp
	dec	(hl)
	ld	a,(hl)
	inc	hl
	cp	255
	jr	nz,ASMPC+3
	dec	(hl)
	ld	h,(hl)
	ld	l,a
	ld	a,h
	or	l
	jp	nz,i_15
.i_14
	jp	i_16
.i_12
.i_19
	ld	hl,4	;const
	add	hl,sp
	push	hl
	call	_spi_in
	pop	de
	ld	a,l
	ld	(de),a
.i_17
	ld	hl,9	;const
	add	hl,sp
	dec	(hl)
	ld	a,(hl)
	inc	hl
	cp	255
	jr	nz,ASMPC+3
	dec	(hl)
	ld	h,(hl)
	ld	l,a
	ld	a,h
	or	l
	jp	nz,i_19
.i_18
.i_16
	pop	bc
	pop	hl
	push	hl
	push	bc
	push	hl
	call	_spi_skip
	pop	bc
	ld	hl,5	;const
	add	hl,sp
	ld	de,0	;const
	ex	de,hl
	call	l_pint
.i_10
.i_4
	ld	hl,255	;const
	push	hl
	call	_spi_cs
	pop	bc
	ld	hl,5	;const
	call	l_gintsp	;
	inc	sp
	pop	bc
	pop	bc
	pop	bc
	ret



; Function disk_writep flags 0x00000200 __smallc 
; const int DRESULTdisk_writep(const unsigned char BYTE*buff, unsigned long sc)
; parameter 'unsigned long sc' at 2 size(4)
; parameter 'const unsigned char BYTE*buff' at 6 size(2)
._disk_writep
	push	bc
	push	bc
	push	bc
	ld	hl,4	;const
	add	hl,sp
	ld	(hl),+(1 % 256)
	inc	hl
	ld	(hl),+(1 / 256)
	ld	hl,0	;const
	push	hl
	call	_spi_cs
	pop	bc
	ld	hl,12	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_20
	ld	hl,8	;const
	add	hl,sp
	call	l_glong
	pop	de
	pop	bc
	push	hl
	push	de
.i_21
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	a,h
	or	l
	jp	z,i_23
	ld	hl,(_st_disk_writep_wc)
	ld	a,h
	or	l
	jr	nz,i_24_i_23
.i_23
	jp	i_22
.i_24_i_23
	ld	hl,12	;const
	add	hl,sp
	inc	(hl)
	ld	a,(hl)
	inc	hl
	jr	nz,ASMPC+3
	inc	(hl)
	ld	h,(hl)
	ld	l,a
	dec	hl
	ld	l,(hl)
	ld	h,0
	push	hl
	call	_spi_out
	pop	bc
	ld	hl,(_st_disk_writep_wc)
	dec	hl
	ld	(_st_disk_writep_wc),hl
	pop	de
	pop	hl
	dec	hl
	push	hl
	push	de
	inc	hl
	jp	i_21
.i_22
	ld	hl,4	;const
	add	hl,sp
	ld	de,0	;const
	ex	de,hl
	call	l_pint
	jp	i_25
.i_20
	ld	hl,8	;const
	add	hl,sp
	call	l_glong
	ld	a,h
	or	l
	or	d
	or	e
	jp	z,i_26
	ld	hl,(_SDCAP)
	ld	h,0
	ld	a,+(8 % 256)
	and	l
	ld	l,a
	call	l_lneg
	jp	nc,i_27
	ld	hl,8	;const
	add	hl,sp
	push	hl
	call	l_glong2sp
	ld	hl,512	;const
	ld	de,0
	call	l_long_mult
	pop	bc
	call	l_plong
.i_27
	ld	hl,24	;const
	push	hl
	ld	hl,10	;const
	call	l_glongsp	;
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,l
	and	a
	jp	nz,i_28
	ld	hl,255	;const
	push	hl
	call	_spi_out
	pop	bc
	ld	hl,254	;const
	push	hl
	call	_spi_out
	pop	bc
	ld	hl,512	;const
	ld	(_st_disk_writep_wc),hl
	ld	hl,4	;const
	add	hl,sp
	ld	de,0	;const
	ex	de,hl
	call	l_pint
.i_28
	jp	i_29
.i_26
	ld	hl,(_st_disk_writep_wc)
	inc	hl
	inc	hl
	pop	de
	pop	bc
	push	hl
	push	de
.i_30
	pop	de
	pop	hl
	dec	hl
	push	hl
	push	de
	inc	hl
	ld	a,h
	or	l
	jp	z,i_31
	ld	hl,0	;const
	push	hl
	call	_spi_out
	pop	bc
	jp	i_30
.i_31
	call	_spi_in
	ld	a,l
	and	+(31 % 256)
	ld	l,a
	ld	h,0
	cp	5
	jp	nz,i_32
	ld	hl,10000	;const
	pop	bc
	push	hl
	jp	i_35
.i_33
	pop	hl
	dec	hl
	push	hl
	inc	hl
.i_35
	call	_spi_in
	ld	a,l
	cp	255
	jp	z,i_36
	pop	hl
	push	hl
	ld	a,h
	or	l
	jr	nz,i_37_i_36
.i_36
	jp	i_34
.i_37_i_36
	ld	hl,200	;const
	call	t_delay
	jp	i_33
.i_34
	pop	hl
	push	hl
	ld	a,h
	or	l
	jp	z,i_38
	ld	hl,4	;const
	add	hl,sp
	ld	de,0	;const
	ex	de,hl
	call	l_pint
.i_38
.i_32
	ld	hl,255	;const
	push	hl
	call	_spi_cs
	pop	bc
.i_29
.i_25
	ld	hl,4	;const
	call	l_gintsp	;
	pop	bc
	pop	bc
	pop	bc
	ret



; --- Start of Static Variables ---

	SECTION	bss_compiler
._SDBUF	defs	11
._SDVER	defs	1
._SDCAP	defs	1
._st_disk_writep_wc	defs	2
	SECTION	code_compiler


; --- Start of Scope Defns ---

	GLOBAL	open
	GLOBAL	creat
	GLOBAL	close
	GLOBAL	read
	GLOBAL	write
	GLOBAL	lseek
	GLOBAL	readbyte
	GLOBAL	writebyte
	GLOBAL	getcwd
	GLOBAL	chdir
	GLOBAL	getwd
	GLOBAL	rmdir
	GLOBAL	_RND_BLOCKSIZE
	GLOBAL	rnd_loadblock
	GLOBAL	rnd_saveblock
	GLOBAL	rnd_erase
	GLOBAL	__FOPEN_MAX
	GLOBAL	__sgoioblk
	GLOBAL	__sgoioblk_end
	GLOBAL	fopen_zsock
	GLOBAL	fopen
	GLOBAL	freopen
	GLOBAL	fdopen
	GLOBAL	_freopen1
	GLOBAL	fmemopen
	GLOBAL	funopen
	GLOBAL	fclose
	GLOBAL	fflush
	GLOBAL	closeall
	GLOBAL	fgets
	GLOBAL	fputs
	GLOBAL	fputc
	GLOBAL	fputs_callee
	GLOBAL	fputc_callee
	GLOBAL	fgetc
	GLOBAL	ungetc
	GLOBAL	feof
	GLOBAL	ferror
	GLOBAL	puts
	GLOBAL	ftell
	GLOBAL	fgetpos
	GLOBAL	fseek
	GLOBAL	fread
	GLOBAL	fwrite
	GLOBAL	gets
	GLOBAL	printf
	GLOBAL	fprintf
	GLOBAL	sprintf
	GLOBAL	snprintf
	GLOBAL	vfprintf
	GLOBAL	vsnprintf
	GLOBAL	printn
	GLOBAL	scanf
	GLOBAL	fscanf
	GLOBAL	sscanf
	GLOBAL	vfscanf
	GLOBAL	vsscanf
	GLOBAL	getarg
	GLOBAL	fchkstd
	GLOBAL	fgetc_cons
	GLOBAL	fgetc_cons_inkey
	GLOBAL	fputc_cons
	GLOBAL	fgets_cons
	GLOBAL	puts_cons
	GLOBAL	fabandon
	GLOBAL	fdtell
	GLOBAL	fdgetpos
	GLOBAL	rename
	GLOBAL	remove
	GLOBAL	getk
	GLOBAL	getk_inkey
	GLOBAL	printk
	GLOBAL	perror
	GLOBAL	atoi
	GLOBAL	atol
	GLOBAL	itoa
	GLOBAL	itoa_callee
	GLOBAL	ltoa
	GLOBAL	ltoa_callee
	GLOBAL	strtol
	GLOBAL	strtol_callee
	GLOBAL	strtoul
	GLOBAL	strtoul_callee
	GLOBAL	ultoa
	GLOBAL	ultoa_callee
	GLOBAL	utoa
	GLOBAL	utoa_callee
	GLOBAL	rand
	GLOBAL	srand
	GLOBAL	mallinit
	GLOBAL	sbrk
	GLOBAL	sbrk_callee
	GLOBAL	calloc
	GLOBAL	calloc_callee
	GLOBAL	free
	GLOBAL	malloc
	GLOBAL	realloc
	GLOBAL	realloc_callee
	GLOBAL	mallinfo
	GLOBAL	mallinfo_callee
	GLOBAL	HeapCreate
	GLOBAL	HeapSbrk
	GLOBAL	HeapSbrk_callee
	GLOBAL	HeapCalloc
	GLOBAL	HeapCalloc_callee
	GLOBAL	HeapFree
	GLOBAL	HeapFree_callee
	GLOBAL	HeapAlloc
	GLOBAL	HeapAlloc_callee
	GLOBAL	HeapRealloc
	GLOBAL	HeapRealloc_callee
	GLOBAL	HeapInfo
	GLOBAL	HeapInfo_callee
	GLOBAL	exit
	GLOBAL	atexit
	GLOBAL	getopt
	GLOBAL	_optarg
	GLOBAL	_opterr
	GLOBAL	_optind
	GLOBAL	_optopt
	GLOBAL	_optreset
	GLOBAL	l_bsearch
	GLOBAL	l_bsearch_callee
	GLOBAL	l_qsort
	GLOBAL	l_qsort_callee
	GLOBAL	qsort_sccz80
	GLOBAL	qsort_sccz80_callee
	GLOBAL	qsort_sdcc
	GLOBAL	qsort_sdcc_callee
	GLOBAL	_div_
	GLOBAL	_div__callee
	GLOBAL	_divu_
	GLOBAL	_divu__callee
	GLOBAL	_ldiv_
	GLOBAL	_ldiv__callee
	GLOBAL	_ldivu_
	GLOBAL	_ldivu__callee
	GLOBAL	abs
	GLOBAL	labs
	GLOBAL	isqrt
	GLOBAL	inp
	GLOBAL	outp
	GLOBAL	outp_callee
	GLOBAL	swapendian
	GLOBAL	bpoke
	GLOBAL	bpoke_callee
	GLOBAL	wpoke
	GLOBAL	wpoke_callee
	GLOBAL	bpeek
	GLOBAL	wpeek
	GLOBAL	t_delay
	GLOBAL	sleep
	GLOBAL	msleep
	GLOBAL	extract_bits
	GLOBAL	extract_bits_callee
	GLOBAL	wcmatch
	GLOBAL	unbcd
	GLOBAL	_pf_mount
	GLOBAL	_pf_open
	GLOBAL	_pf_read
	GLOBAL	_pf_write
	GLOBAL	_pf_lseek
	GLOBAL	_pf_opendir
	GLOBAL	_pf_readdir
	GLOBAL	_FatFs
	GLOBAL	_disk_initialize
	GLOBAL	_disk_readp
	GLOBAL	_disk_writep
	GLOBAL	_SDBUF
	GLOBAL	_SDVER
	GLOBAL	_SDCAP
	GLOBAL	_spi_init
	GLOBAL	_spi_cs
	GLOBAL	_spi_out
	GLOBAL	_spi_in
	GLOBAL	_spi_skip
	GLOBAL	_send_cmd


; --- End of Scope Defns ---


; --- End of Compilation ---
