;* * * * *  Small-C/Plus z88dk * * * * *
;  Version: 16120-f784809cf-20200301
;
;	Reconstructed for z80 Module Assembler
;
;	Module compile time: Fri Mar 13 16:31:35 2020



	MODULE	sdmmc_c


	INCLUDE "z80_crt0.hdr"


	SECTION	data_compiler
._Stat
	defb	1
	SECTION	code_compiler

; Function spi_init flags 0x00000200 __smallc 
; int spi_init()
._spi_init
            LD      A, 0x04  |  0x00   |  0x00                     ; Clock and MOSI High.
            OUT     ( 0xFF ),A
            LD      B,80
            LD      A, 0x04  |  0x00   |  0x00                     ; Output a 1
SPIINIT1:   OUT     ( 0xFF ),A
            NOP
            NOP
            LD      A, 0x04  |  0x02  |  0x00                     ; Output a 1
            OUT     ( 0xFF ),A
            NOP
            NOP
            DJNZ    SPIINIT1
            LD      A, 0x04  |  0x00   |  0x00                     ; Output a 1
            OUT     ( 0xFF ),A
            LD      HL,0                                                 ; hl is the return parameter
	ret



; Function spi_cs flags 0x00000200 __smallc 
; int spi_cs(unsigned char b)
; parameter 'unsigned char b' at 2 size(1)
._spi_cs
	ret



; Function spi_out flags 0x00000200 __smallc 
; int spi_out(unsigned char b)
; parameter 'unsigned char b' at 2 size(1)
._spi_out
            LD      HL,2
            ADD     HL,SP                                                ; skip over return address on stack
            LD      A,(HL)                                               ; a = b, "char b" occupies 16 bits on stack
                                                                         ;  but only the LSB is relevant
            LD      E,A                                                  ; E = Character to send.
            LD      B,08H                                                ; B = Bit count
SPIOUT0:    RL      E
            LD      A, 0x00   |  0x00   |  0x00                     ; Output a 0
            JR      NC,SPIOUT1
            LD      A, 0x04  |  0x00   |  0x00                     ; Output a 1
SPIOUT1:    OUT     ( 0xFF ),A
            LD      D,A
            OR       0x02 
            OUT     ( 0xFF ),A
            LD      A,D
            OUT     ( 0xFF ),A
            DJNZ    SPIOUT0                                              ; Perform actions for the full 8 bits.
           ;LD      A, 0x04  |  0x00  |  0x00                     ; Return clock and MOSI to high.
           ;OUT     ( 0xFF ),A
            LD      HL,0                                                 ; hl is the return parameter
	ret



; Function spi_in flags 0x00000200 __smallc 
; unsigned char uint8_tspi_in()
._spi_in
            LD      BC,0800H                                             ; B = Bit count, C = Character being read.
SPIIN0:     LD      A, 0x04  |  0x00   |  0x00                     ; Output a 0
SPIIN1:     OUT     ( 0xFF ),A
            LD      D,A
            OR       0x02 
            OUT     ( 0xFF ),A
            NOP
            IN      A,( 0xFE )                                           ; Input the received bit
            SRL     A
            RL      C
            LD      A,D
            OUT     ( 0xFF ),A
            DJNZ    SPIIN0                                               ; Perform actions for the full 8 bits.
            LD      L,C                                                  ; hl is the return parameter
            LD      H,0
	ret



; Function spi_skip flags 0x00000200 __smallc 
; void spi_skip(unsigned int n)
; parameter 'unsigned int n' at 2 size(2)
._spi_skip
	dec	sp
.i_5
	ld	hl,0	;const
	add	hl,sp
	push	hl
	call	_spi_in
	pop	de
	ld	a,l
	ld	(de),a
.i_3
	ld	hl,3	;const
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
	jp	nz,i_5
.i_4
	inc	sp
	ret



; Function send_cmd flags 0x00000200 __smallc 
; unsigned char BYTEsend_cmd(unsigned char cmd, unsigned long arg)
; parameter 'unsigned long arg' at 2 size(4)
; parameter 'unsigned char cmd' at 6 size(1)
._send_cmd
	push	bc
	ld	hl,8	;const
	add	hl,sp
	ld	a,+(128 % 256)
	and	(hl)
	jp	z,i_6
	ld	hl,8	;const
	add	hl,sp
	push	hl
	ld	a,(hl)
	and	+(127 % 256)
	ld	l,a
	ld	h,0
	pop	de
	ld	a,l
	ld	(de),a
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	hl,55	;const
	push	hl
	ld	hl,0	;const
	ld	d,h
	ld	e,l
	push	de
	push	hl
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	pop	de
	ld	a,l
	ld	(de),a
	pop	hl
	push	hl
	ld	h,0
	ld	a,1
	sub	l
	jp	nc,i_7
	pop	hl
	push	hl
	ld	h,0
	pop	bc
	ret


.i_7
.i_6
	ld	hl,255	;const
	push	hl
	call	_spi_cs
	pop	bc
	ld	hl,8	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	push	hl
	call	_spi_out
	pop	bc
	ld	hl,7	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,0
	push	hl
	call	_spi_out
	pop	bc
	ld	hl,6	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,0
	push	hl
	call	_spi_out
	pop	bc
	ld	hl,5	;const
	add	hl,sp
	ld	e,(hl)
	inc	hl
	inc	hl
	ld	l,(hl)
	ld	h,0
	ex	de,hl
	ld	h,0
	push	hl
	call	_spi_out
	pop	bc
	ld	hl,4	;const
	add	hl,sp
	call	l_glong
	ld	h,0
	push	hl
	call	_spi_out
	pop	bc
	ld	hl,1	;const
	add	hl,sp
	ld	(hl),+(1 % 256 % 256)
	ld	hl,8	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	nz,i_8
	ld	hl,1	;const
	add	hl,sp
	ld	(hl),+(149 % 256 % 256)
.i_8
	ld	hl,8	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	8
	jp	nz,i_9
	ld	hl,1	;const
	add	hl,sp
	ld	(hl),+(135 % 256 % 256)
.i_9
	pop	hl
	push	hl
	ld	l,h
	ld	h,0
	push	hl
	call	_spi_out
	pop	bc
	ld	hl,1	;const
	add	hl,sp
	ld	(hl),+(10 % 256 % 256)
.i_12
	ld	hl,0	;const
	add	hl,sp
	push	hl
	call	_spi_in
	pop	de
	ld	a,l
	ld	(de),a
.i_10
	pop	hl
	push	hl
	ld	h,0
	ld	a,l
	and	+(128 % 256)
	jp	z,i_13
	ld	hl,1	;const
	add	hl,sp
	dec	(hl)
	ld	a,(hl)
	and	a
	jr	nz,i_14_i_13
.i_13
	jp	i_11
.i_14_i_13
	jp	i_12
.i_11
	pop	hl
	push	hl
	ld	h,0
	pop	bc
	ret



; Function disk_initialize flags 0x00000200 __smallc 
; unsigned char DSTATUSdisk_initialize()
._disk_initialize
	push	bc
	push	bc
	push	bc
	push	bc
	dec	sp
	call	_spi_init
	ld	hl,6	;const
	add	hl,sp
	ld	(hl),+(0 % 256 % 256)
	ld	hl,0	;const
	push	hl
	ld	d,h
	ld	e,l
	push	de
	push	hl
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,l
	cp	1
	jp	nz,i_15
	ld	hl,8	;const
	push	hl
	ld	hl,426	;const
	ld	de,0
	push	de
	push	hl
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,l
	cp	1
	jp	nz,i_16
	ld	hl,i_1+0
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,8	;const
	add	hl,sp
	ld	(hl),+(0 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_19
.i_17
	ld	hl,8	;const
	add	hl,sp
	inc	(hl)
.i_19
	ld	hl,8	;const
	add	hl,sp
	ld	a,(hl)
	sub	4
	jp	nc,i_18
	ld	hl,2	;const
	add	hl,sp
	ex	de,hl
	ld	hl,8	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	add	hl,de
	push	hl
	call	_spi_in
	pop	de
	ld	a,l
	ld	(de),a
	jp	i_17
.i_18
	ld	hl,4	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	1
	jp	nz,i_21
	ld	hl,5	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	170
	jr	z,i_22_i_21
.i_21
	jp	i_20
.i_22_i_21
	ld	hl,1000	;const
	pop	bc
	push	hl
	jp	i_25
.i_23
	pop	hl
	dec	hl
	push	hl
	inc	hl
.i_25
	pop	hl
	push	hl
	ld	a,h
	or	l
	jp	z,i_24
	ld	hl,169	;const
	push	hl
	ld	hl,0	;const
	ld	de,16384
	push	de
	push	hl
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,l
	and	a
	jp	z,i_24
.i_26
	ld	hl,2000	;const
	call	t_delay
	jp	i_23
.i_24
	pop	hl
	push	hl
	ld	a,h
	or	l
	jp	z,i_28
	ld	hl,58	;const
	push	hl
	ld	hl,0	;const
	ld	d,h
	ld	e,l
	push	de
	push	hl
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,l
	and	a
	jr	z,i_29_i_28
.i_28
	jp	i_27
.i_29_i_28
	ld	hl,8	;const
	add	hl,sp
	ld	(hl),+(0 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_32
.i_30
	ld	hl,8	;const
	add	hl,sp
	inc	(hl)
.i_32
	ld	hl,8	;const
	add	hl,sp
	ld	a,(hl)
	sub	4
	jp	nc,i_31
	ld	hl,2	;const
	add	hl,sp
	ex	de,hl
	ld	hl,8	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	add	hl,de
	push	hl
	call	_spi_in
	pop	de
	ld	a,l
	ld	(de),a
	jp	i_30
.i_31
	ld	hl,6	;const
	add	hl,sp
	push	hl
	ld	hl,4	;const
	add	hl,sp
	ld	a,+(64 % 256)
	and	(hl)
	jp	z,i_33
	ld	hl,12	;const
	jp	i_34
.i_33
	ld	hl,4	;const
.i_34
	pop	de
	ld	a,l
	ld	(de),a
.i_27
.i_20
	jp	i_35
.i_16
	ld	hl,i_1+20
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,169	;const
	push	hl
	ld	hl,0	;const
	ld	d,h
	ld	e,l
	push	de
	push	hl
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,1
	sub	l
	ccf
	jp	nc,i_36
	ld	hl,6	;const
	add	hl,sp
	ld	(hl),+(2 % 256 % 256)
	ld	hl,7	;const
	add	hl,sp
	ld	(hl),+(169 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_37
.i_36
	ld	hl,6	;const
	add	hl,sp
	ld	(hl),+(1 % 256 % 256)
	ld	hl,7	;const
	add	hl,sp
	ld	(hl),+(1 % 256 % 256)
.i_37
	ld	hl,1000	;const
	pop	bc
	push	hl
	jp	i_40
.i_38
	pop	hl
	dec	hl
	push	hl
	inc	hl
.i_40
	pop	hl
	push	hl
	ld	a,h
	or	l
	jp	z,i_39
	ld	hl,7	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	push	hl
	ld	hl,0	;const
	ld	d,h
	ld	e,l
	push	de
	push	hl
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,l
	and	a
	jp	z,i_39
.i_41
	ld	hl,2000	;const
	call	t_delay
	jp	i_38
.i_39
	pop	hl
	push	hl
	call	l_lneg
	jp	c,i_43
	ld	hl,16	;const
	push	hl
	ld	hl,512	;const
	ld	de,0
	push	de
	push	hl
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,l
	and	a
	jp	z,i_42
.i_43
	ld	hl,6	;const
	add	hl,sp
	ld	(hl),+(0 % 256 % 256)
	ld	l,(hl)
	ld	h,0
.i_42
.i_35
.i_15
	ld	hl,6	;const
	add	hl,sp
	ld	a,(hl)
	ld	(_CardType),a
	ld	hl,255	;const
	push	hl
	call	_spi_cs
	pop	bc
	ld	hl,6	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	z,i_45
	ld	hl,0	;const
	jp	i_46
.i_45
	ld	hl,1	;const
.i_46
	ld	h,0
	inc	sp
	pop	bc
	pop	bc
	pop	bc
	pop	bc
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
	ld	hl,(_CardType)
	ld	h,0
	ld	a,+(8 % 256)
	and	l
	ld	l,a
	call	l_lneg
	jp	nc,i_47
	ld	hl,13	;const
	add	hl,sp
	push	hl
	call	l_glong2sp
	ld	hl,512	;const
	ld	de,0
	call	l_long_mult
	pop	bc
	call	l_plong
.i_47
	ld	hl,5	;const
	add	hl,sp
	ld	(hl),+(1 % 256)
	inc	hl
	ld	(hl),+(1 / 256)
	ld	hl,17	;const
	push	hl
	ld	hl,15	;const
	add	hl,sp
	call	l_glong
	push	de
	push	hl
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,l
	and	a
	jp	nz,i_48
	ld	hl,1000	;const
	pop	bc
	push	hl
.i_51
	ld	hl,200	;const
	call	t_delay
	ld	hl,4	;const
	add	hl,sp
	push	hl
	call	_spi_in
	pop	de
	ld	a,l
	ld	(de),a
.i_49
	ld	hl,4	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	255
	jp	nz,i_52
	pop	hl
	dec	hl
	push	hl
	ld	a,h
	or	l
	jr	nz,i_53_i_52
.i_52
	jp	i_50
.i_53_i_52
	jp	i_51
.i_50
	ld	hl,4	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	254
	jp	nz,i_54
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
	add	hl,sp
	call	l_gint	;
	ex	de,hl
	and	a
	sbc	hl,de
	pop	de
	pop	bc
	push	hl
	push	de
	ld	hl,11	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	z,i_55
	ld	hl,11	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_spi_skip
	pop	bc
.i_55
	ld	hl,17	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	z,i_56
.i_59
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
.i_57
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
	jp	nz,i_59
.i_58
	jp	i_60
.i_56
.i_63
	ld	hl,4	;const
	add	hl,sp
	push	hl
	call	_spi_in
	pop	de
	ld	a,l
	ld	(de),a
.i_61
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
	jp	nz,i_63
.i_62
.i_60
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
.i_54
.i_48
	ld	hl,255	;const
	push	hl
	call	_spi_cs
	pop	bc
	ld	hl,5	;const
	add	hl,sp
	call	l_gint	;
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
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	z,i_64
	ld	hl,8	;const
	add	hl,sp
	call	l_glong
	pop	de
	pop	bc
	push	hl
	push	de
.i_65
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	a,h
	or	l
	jp	z,i_67
	ld	hl,(_st_disk_writep_wc)
	ld	a,h
	or	l
	jr	nz,i_68_i_67
.i_67
	jp	i_66
.i_68_i_67
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
	jp	i_65
.i_66
	ld	hl,4	;const
	add	hl,sp
	ld	de,0	;const
	ex	de,hl
	call	l_pint
	jp	i_69
.i_64
	ld	hl,8	;const
	add	hl,sp
	call	l_glong
	ld	a,h
	or	l
	or	d
	or	e
	jp	z,i_70
	ld	hl,(_CardType)
	ld	h,0
	ld	a,+(8 % 256)
	and	l
	ld	l,a
	call	l_lneg
	jp	nc,i_71
	ld	hl,8	;const
	add	hl,sp
	push	hl
	call	l_glong2sp
	ld	hl,512	;const
	ld	de,0
	call	l_long_mult
	pop	bc
	call	l_plong
.i_71
	ld	hl,24	;const
	push	hl
	ld	hl,10	;const
	add	hl,sp
	call	l_glong
	push	de
	push	hl
	call	_send_cmd
	pop	bc
	pop	bc
	pop	bc
	ld	a,l
	and	a
	jp	nz,i_72
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
.i_72
	jp	i_73
.i_70
	ld	hl,(_st_disk_writep_wc)
	inc	hl
	inc	hl
	pop	de
	pop	bc
	push	hl
	push	de
.i_74
	pop	de
	pop	hl
	dec	hl
	push	hl
	push	de
	inc	hl
	ld	a,h
	or	l
	jp	z,i_75
	ld	hl,0	;const
	push	hl
	call	_spi_out
	pop	bc
	jp	i_74
.i_75
	call	_spi_in
	ld	a,l
	and	+(31 % 256)
	ld	l,a
	ld	h,0
	cp	5
	jp	nz,i_76
	ld	hl,10000	;const
	pop	bc
	push	hl
	jp	i_79
.i_77
	pop	hl
	dec	hl
	push	hl
	inc	hl
.i_79
	call	_spi_in
	ld	a,l
	cp	255
	jp	z,i_80
	pop	hl
	push	hl
	ld	a,h
	or	l
	jr	nz,i_81_i_80
.i_80
	jp	i_78
.i_81_i_80
	ld	hl,200	;const
	call	t_delay
	jp	i_77
.i_78
	pop	hl
	push	hl
	ld	a,h
	or	l
	jp	z,i_82
	ld	hl,4	;const
	add	hl,sp
	ld	de,0	;const
	ex	de,hl
	call	l_pint
.i_82
.i_76
	ld	hl,255	;const
	push	hl
	call	_spi_cs
	pop	bc
.i_73
.i_69
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	pop	bc
	pop	bc
	pop	bc
	ret


	SECTION	rodata_compiler
.i_1
	defm	"Identified v2 card"
	defb	10

	defm	""
	defb	0

	defm	"Identified v1 card"
	defb	10

	defm	""
	defb	0


; --- Start of Static Variables ---

	SECTION	bss_compiler
._CardType	defs	1
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
	GLOBAL	_disk_initialize
	GLOBAL	_disk_readp
	GLOBAL	_disk_writep
	GLOBAL	_spi_init
	GLOBAL	_spi_cs
	GLOBAL	_spi_out
	GLOBAL	_spi_in
	GLOBAL	_spi_skip


; --- End of Scope Defns ---


; --- End of Compilation ---
