;* * * * *  Small-C/Plus z88dk * * * * *
;  Version: 16120-f784809cf-20200301
;
;	Reconstructed for z80 Module Assembler
;
;	Module compile time: Fri Mar 13 16:31:35 2020



	MODULE	pff_c


	INCLUDE "z80_crt0.hdr"


	SECTION	code_compiler

; Function ld_word flags 0x00000200 __smallc 
; unsigned int WORDld_word(const unsigned char BYTE*ptr)
; parameter 'const unsigned char BYTE*ptr' at 2 size(2)
._ld_word
	push	bc
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	ld	l,(hl)
	ld	h,0
	pop	bc
	push	hl
	ld	h,l
	ld	l,0
	push	hl
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	ld	l,(hl)
	pop	de
	ld	h,d
	ld	a,l
	or	e
	ld	l,a
	pop	bc
	ret



; Function ld_dword flags 0x00000200 __smallc 
; unsigned long DWORDld_dword(const unsigned char BYTE*ptr)
; parameter 'const unsigned char BYTE*ptr' at 2 size(2)
._ld_dword
	push	bc
	push	bc
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	inc	hl
	ld	l,(hl)
	ld	h,0
	ld	de,0
	pop	bc
	call	l_plong
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	a,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	h,a
	ld	l,0
	push	de
	push	hl
	ld	hl,12	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	ld	l,(hl)
	pop	de
	ld	h,d
	ld	a,l
	or	e
	ld	l,a
	pop	de
	pop	bc
	call	l_plong
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	a,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	h,a
	ld	l,0
	push	de
	push	hl
	ld	hl,12	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	ld	l,(hl)
	pop	de
	ld	h,d
	ld	a,l
	or	e
	ld	l,a
	pop	de
	pop	bc
	call	l_plong
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	a,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	h,a
	ld	l,0
	push	de
	push	hl
	ld	hl,12	;const
	add	hl,sp
	call	l_gint	;
	ld	l,(hl)
	pop	de
	ld	h,d
	ld	a,l
	or	e
	ld	l,a
	pop	de
	pop	bc
	call	l_plong
	ld	hl,0	;const
	add	hl,sp
	call	l_glong
	pop	bc
	pop	bc
	ret



; Function mem_set flags 0x00000200 __smallc 
; void mem_set(void *dst, int val, int cnt)
; parameter 'int cnt' at 2 size(2)
; parameter 'int val' at 4 size(2)
; parameter 'void *dst' at 6 size(2)
._mem_set
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	push	hl
.i_2
	ld	hl,4	;const
	add	hl,sp
	dec	(hl)
	ld	a,(hl)
	inc	hl
	cp	255
	jr	nz,ASMPC+3
	dec	(hl)
	ld	h,(hl)
	ld	l,a
	inc	hl
	ld	a,h
	or	l
	jp	z,i_3
	pop	hl
	inc	hl
	push	hl
	dec	hl
	push	hl
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	a,l
	call	l_sxt
	ld	a,l
	call	l_sxt
	pop	de
	ld	a,l
	ld	(de),a
	jp	i_2
.i_3
	pop	bc
	ret



; Function mem_cmp flags 0x00000200 __smallc 
; int mem_cmp(const void *dst, const void *src, int cnt)
; parameter 'int cnt' at 2 size(2)
; parameter 'const void *src' at 4 size(2)
; parameter 'const void *dst' at 6 size(2)
._mem_cmp
	ld	hl,6	;const
	call	l_g2intspsp	;
	ld	hl,0	;const
	push	hl
.i_4
	ld	hl,8	;const
	add	hl,sp
	dec	(hl)
	ld	a,(hl)
	inc	hl
	cp	255
	jr	nz,ASMPC+3
	dec	(hl)
	ld	h,(hl)
	ld	l,a
	inc	hl
	ld	a,h
	or	l
	jp	z,i_6
	ld	hl,4	;const
	add	hl,sp
	inc	(hl)
	ld	a,(hl)
	inc	hl
	jr	nz,ASMPC+3
	inc	(hl)
	ld	h,(hl)
	ld	l,a
	dec	hl
	call	l_gchar
	push	hl
	ld	hl,4	;const
	add	hl,sp
	inc	(hl)
	ld	a,(hl)
	inc	hl
	jr	nz,ASMPC+3
	inc	(hl)
	ld	h,(hl)
	ld	l,a
	dec	hl
	call	l_gchar
	pop	de
	ex	de,hl
	and	a
	sbc	hl,de
	pop	bc
	push	hl
	ld	a,h	
	or	l
	jp	nz,i_6
	inc	hl
	jr	i_7
.i_6
	ld	hl,0	;const
.i_7
	ld	a,h
	or	l
	jp	nz,i_4
.i_5
	pop	hl
	pop	bc
	pop	bc
	ret



; Function get_fat flags 0x00000200 __smallc 
; unsigned long DWORDget_fat(unsigned long clst)
; parameter 'unsigned long clst' at 2 size(4)
._get_fat
	push	bc
	push	bc
	ld	hl,(_FatFs)
	push	hl
	ld	hl,8	;const
	add	hl,sp
	call	l_glong
	ld	a,l
	sub	2
	ld	a,h
	sbc	0
	ld	a,e
	sbc	0
	ld	a,d
	sbc	0
	jp	c,i_9
	ld	hl,8	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,6
	add	hl,bc
	call	l_glong
	call	l_long_uge
	jp	nc,i_8
.i_9
	ld	hl,1	;const
	ld	de,0
	pop	bc
	pop	bc
	pop	bc
	ret


.i_8
	pop	hl
	push	hl
	ld	l,(hl)
	ld	h,0
.i_13
	ld	a,l
	cp	+(3% 256)
	jp	nz,i_12
.i_14
	ld	hl,2	;const
	add	hl,sp
	push	hl
	dec	hl
	dec	hl
	call	l_gint	;
	ld	bc,10
	add	hl,bc
	call	l_glong2sp
	ld	hl,14	;const
	add	hl,sp
	call	l_glong2sp
	ld	l,+(7 % 256)
	call	l_long_asr_u
	call	l_long_add
	push	de
	push	hl
	ld	hl,14	;const
	add	hl,sp
	call	l_glong
	ld	a,l
	and	+(127 % 256)
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	push	hl
	ld	hl,4	;const
	push	hl
	call	_disk_readp
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jp	nz,i_12
.i_15
	ld	hl,2	;const
	add	hl,sp
	push	hl
	call	_ld_dword
	pop	bc
	ld	a,d
	and	+(15 % 256)
	ld	d,a
	pop	bc
	pop	bc
	pop	bc
	ret


.i_12
	ld	hl,1	;const
	ld	de,0
	pop	bc
	pop	bc
	pop	bc
	ret



; Function clust2sect flags 0x00000200 __smallc 
; unsigned long DWORDclust2sect(unsigned long clst)
; parameter 'unsigned long clst' at 2 size(4)
._clust2sect
	ld	hl,(_FatFs)
	push	hl
	ld	hl,4	;const
	add	hl,sp
	push	hl
	call	l_glong
	ld	bc,65534
	add	hl,bc
	jr	c,ASMPC+3
	dec	de
	pop	bc
	call	l_plong
	ld	hl,4	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,6
	add	hl,bc
	call	l_glong
	ld	bc,65534
	add	hl,bc
	jr	c,ASMPC+3
	dec	de
	call	l_long_uge
	jp	nc,i_16
	ld	hl,0	;const
	ld	d,h
	ld	e,l
	pop	bc
	ret


.i_16
	ld	hl,4	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	ld	l,(hl)
	ld	h,0
	ld	de,0
	call	l_long_mult
	push	de
	push	hl
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,18
	add	hl,bc
	call	l_glong
	call	l_long_add
	pop	bc
	ret



; Function get_clust flags 0x00000200 __smallc 
; unsigned long DWORDget_clust(unsigned char BYTE*dir)
; parameter 'unsigned char BYTE*dir' at 2 size(2)
._get_clust
	ld	hl,(_FatFs)
	push	hl
	ld	hl,0	;const
	ld	d,h
	ld	e,l
	push	de
	push	hl
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,20
	add	hl,bc
	push	hl
	call	_ld_word
	pop	bc
	ld	de,0
	pop	bc
	call	l_plong
	ld	hl,0	;const
	add	hl,sp
	push	hl
	call	l_glong
	ex	de,hl
	ld	hl,0	;const
	pop	bc
	call	l_plong
	ld	hl,0	;const
	add	hl,sp
	push	hl
	call	l_glong2sp
	ld	hl,14	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,26
	add	hl,bc
	push	hl
	call	_ld_word
	pop	bc
	pop	de
	call	l_or
	pop	de
	pop	bc
	call	l_plong
	ld	hl,0	;const
	add	hl,sp
	call	l_glong
	pop	bc
	pop	bc
	pop	bc
	ret



; Function dir_rewind flags 0x00000200 __smallc 
; const int FRESULTdir_rewind(struct 0__anonstruct_5 DIR*dj)
; parameter 'struct 0__anonstruct_5 DIR*dj' at 2 size(2)
._dir_rewind
	push	bc
	push	bc
	ld	hl,(_FatFs)
	push	hl
	ld	hl,8	;const
	add	hl,sp
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	ld	hl,2	;const
	add	hl,sp
	push	hl
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,4
	add	hl,bc
	call	l_glong
	pop	bc
	call	l_plong
	ld	hl,2	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,1	;const
	ld	de,0
	call	l_long_eq
	jp	c,i_18
	ld	hl,2	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,6
	add	hl,bc
	call	l_glong
	call	l_long_uge
	jp	nc,i_17
.i_18
	ld	hl,1	;const
	pop	bc
	pop	bc
	pop	bc
	ret


.i_17
	ld	hl,2	;const
	add	hl,sp
	call	l_glong
	call	l_long_lneg
	jp	nc,i_20
	ld	hl,2	;const
	add	hl,sp
	push	hl
	dec	hl
	dec	hl
	call	l_gint	;
	ld	bc,14
	add	hl,bc
	call	l_glong
	pop	bc
	call	l_plong
.i_20
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,8
	add	hl,bc
	push	hl
	ld	hl,4	;const
	add	hl,sp
	call	l_glong
	pop	bc
	call	l_plong
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	push	hl
	jp	i_21
	ld	hl,4	;const
	add	hl,sp
	call	l_glong
	ld	a,h
	or	l
	or	d
	or	e
	jp	nz,i_21
	ld	hl,0	;const
	jr	i_22
.i_21
	ld	hl,1	;const
.i_22
	jp	nc,i_23
	ld	hl,4	;const
	add	hl,sp
	call	l_glong
	push	de
	push	hl
	call	_clust2sect
	pop	bc
	pop	bc
	jp	i_24
.i_23
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	bc,14
	add	hl,bc
	call	l_glong
.i_24
	pop	bc
	call	l_plong
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	push	hl
	ld	hl,4	;const
	add	hl,sp
	call	l_glong
	push	de
	push	hl
	call	_clust2sect
	pop	bc
	pop	bc
	pop	bc
	call	l_plong
	ld	hl,0	;const
	pop	bc
	pop	bc
	pop	bc
	ret



; Function dir_next flags 0x00000200 __smallc 
; const int FRESULTdir_next(struct 0__anonstruct_5 DIR*dj)
; parameter 'struct 0__anonstruct_5 DIR*dj' at 2 size(2)
._dir_next
	push	bc
	push	bc
	push	bc
	ld	hl,(_FatFs)
	push	hl
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	call	l_gint	;
	inc	hl
	pop	de
	pop	bc
	push	hl
	push	de
	call	l_lneg
	jp	c,i_26
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	call	l_glong
	call	l_long_lneg
	jp	nc,i_25
.i_26
	ld	hl,3	;const
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret


.i_25
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	a,l
	and	+(15 % 256)
	jp	nz,i_28
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	push	hl
	call	l_glong
	call	l_inclong
	pop	bc
	call	l_plong
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,8
	add	hl,bc
	call	l_glong
	ld	a,d
	or	e
	or	h
	or	l
	jp	nz,i_29
	ld	hl,2	;const
	call	l_gintspsp	;
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	bc,4
	add	hl,bc
	call	l_gint	;
	pop	de
	call	l_uge
	jp	nc,i_30
	ld	hl,3	;const
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret


.i_30
	jp	i_31
.i_29
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	de,4
	call	l_asr_u_hl_by_e
	pop	de
	push	de
	push	hl
	ex	de,hl
	inc	hl
	inc	hl
	ld	l,(hl)
	ld	h,0
	dec	hl
	pop	de
	call	l_and
	ld	a,h
	or	l
	jp	nz,i_32
	ld	hl,4	;const
	add	hl,sp
	push	hl
	ld	hl,12	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,8
	add	hl,bc
	call	l_glong
	push	de
	push	hl
	call	_get_fat
	pop	bc
	pop	bc
	pop	bc
	call	l_plong
	ld	hl,4	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,1	;const
	ld	de,0
	call	l_long_ule
	jp	nc,i_33
	ld	hl,1	;const
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret


.i_33
	ld	hl,4	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,6
	add	hl,bc
	call	l_glong
	call	l_long_uge
	jp	nc,i_34
	ld	hl,3	;const
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret


.i_34
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,8
	add	hl,bc
	push	hl
	ld	hl,6	;const
	add	hl,sp
	call	l_glong
	pop	bc
	call	l_plong
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	push	hl
	ld	hl,6	;const
	add	hl,sp
	call	l_glong
	push	de
	push	hl
	call	_clust2sect
	pop	bc
	pop	bc
	pop	bc
	call	l_plong
.i_32
.i_31
.i_28
	ld	hl,10	;const
	call	l_gintspsp	;
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	pop	de
	call	l_pint
	ld	hl,0	;const
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret



; Function dir_find flags 0x00000200 __smallc 
; const int FRESULTdir_find(struct 0__anonstruct_5 DIR*dj, unsigned char BYTE*dir)
; parameter 'unsigned char BYTE*dir' at 2 size(2)
; parameter 'struct 0__anonstruct_5 DIR*dj' at 4 size(2)
._dir_find
	push	bc
	dec	sp
	ld	hl,1	;const
	add	hl,sp
	push	hl
	ld	hl,9	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_dir_rewind
	pop	bc
	pop	de
	call	l_pint
	ld	hl,1	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	z,i_35
	ld	hl,1	;const
	add	hl,sp
	call	l_gint	;
	inc	sp
	pop	bc
	ret


.i_35
.i_38
	ld	hl,1	;const
	add	hl,sp
	push	hl
	ld	hl,7	;const
	call	l_gintspsp	;
	ld	hl,11	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	call	l_glong2sp
	ld	hl,15	;const
	add	hl,sp
	call	l_gint	;
	ld	a,(hl)
	and	+(15 % 256)
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	push	hl
	ld	hl,32	;const
	push	hl
	call	_disk_readp
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jp	z,i_39
	ld	hl,1	;const
	jp	i_40
.i_39
	ld	hl,0	;const
.i_40
	pop	de
	call	l_pint
	ld	hl,1	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	nz,i_37
.i_41
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	hl,7	;const
	add	hl,sp
	call	l_gint	;
	ld	a,(hl)
	pop	de
	ld	(de),a
	pop	hl
	push	hl
	ld	h,0
	ld	a,l
	and	a
	jp	nz,i_42
	ld	hl,1	;const
	add	hl,sp
	ld	de,3	;const
	ex	de,hl
	call	l_pint
	jp	i_37
.i_42
	ld	hl,5	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,11
	add	hl,bc
	ld	a,(hl)
	and	+(8 % 256)
	jp	nz,i_44
	ld	hl,5	;const
	call	l_gintspsp	;
	ld	hl,9	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	de
	ld	hl,11	;const
	push	hl
	call	_mem_cmp
	pop	bc
	pop	bc
	pop	bc
	call	l_lneg
	jr	c,i_45_i_44
.i_44
	jp	i_43
.i_45_i_44
	jp	i_37
.i_43
	ld	hl,1	;const
	add	hl,sp
	push	hl
	ld	hl,9	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_dir_next
	pop	bc
	pop	de
	call	l_pint
.i_36
	ld	hl,1	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	z,i_38
.i_37
	ld	hl,1	;const
	add	hl,sp
	call	l_gint	;
	inc	sp
	pop	bc
	ret



; Function dir_read flags 0x00000200 __smallc 
; const int FRESULTdir_read(struct 0__anonstruct_5 DIR*dj, unsigned char BYTE*dir)
; parameter 'unsigned char BYTE*dir' at 2 size(2)
; parameter 'struct 0__anonstruct_5 DIR*dj' at 4 size(2)
._dir_read
	ld	hl,3	;const
	push	hl
	push	bc
.i_46
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	call	l_glong
	ld	a,h
	or	l
	or	d
	or	e
	jp	z,i_47
	ld	hl,i_1+0
	push	hl
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	call	l_glong2sp
	ld	hl,14	;const
	add	hl,sp
	call	l_gint	;
	call	l_gint	;
	push	hl
	ld	a,4
	call	printf
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ld	hl,6	;const
	call	l_gintspsp	;
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	call	l_glong2sp
	ld	hl,14	;const
	add	hl,sp
	call	l_gint	;
	ld	a,(hl)
	and	+(15 % 256)
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	push	hl
	ld	hl,32	;const
	push	hl
	call	_disk_readp
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jp	z,i_48
	ld	hl,1	;const
	jp	i_49
.i_48
	ld	hl,0	;const
.i_49
	pop	de
	pop	bc
	push	hl
	push	de
	ld	a,h
	or	l
	jp	nz,i_47
.i_50
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	a,(hl)
	pop	de
	ld	(de),a
	pop	hl
	push	hl
	ld	h,0
	ld	a,l
	and	a
	jp	nz,i_51
	ld	hl,3	;const
	pop	de
	pop	bc
	push	hl
	push	de
	jp	i_47
.i_51
	ld	hl,1	;const
	add	hl,sp
	push	hl
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,11
	add	hl,bc
	ld	a,(hl)
	and	+(63 % 256)
	ld	l,a
	ld	h,0
	pop	de
	ld	a,l
	ld	(de),a
	ld	hl,0	;const
	add	hl,sp
	ld	a,(hl)
	cp	229
	jp	z,i_53
	pop	hl
	push	hl
	ld	h,0
	ld	de,46
	and	a
	sbc	hl,de
	scf
	jr	nz,ASMPC+3
	ccf
	jp	nc,i_53
	pop	hl
	push	hl
	ld	l,h
	ld	h,0
	ld	a,+(8 % 256)
	and	l
	ld	l,a
	call	l_lneg
	jr	c,i_54_i_53
.i_53
	jp	i_52
.i_54_i_53
	jp	i_47
.i_52
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_dir_next
	pop	bc
	pop	de
	pop	bc
	push	hl
	push	de
	ld	a,h
	or	l
	jr	nz,i_47
.i_55
	jp	i_46
.i_47
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	a,h
	or	l
	jp	z,i_56
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	push	hl
	ld	hl,0	;const
	ld	d,h
	ld	e,l
	pop	bc
	call	l_plong
.i_56
	pop	bc
	pop	hl
	ret



; Function create_name flags 0x00000200 __smallc 
; const int FRESULTcreate_name(struct 0__anonstruct_5 DIR*dj, const char **path)
; parameter 'const char **path' at 2 size(2)
; parameter 'struct 0__anonstruct_5 DIR*dj' at 4 size(2)
._create_name
	push	bc
	push	bc
	push	bc
	push	bc
	dec	sp
	ld	hl,13	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	call	l_gint	;
	pop	de
	pop	bc
	push	hl
	push	de
	ld	hl,2	;const
	call	l_gintspsp	;
	ld	hl,32	;const
	push	hl
	ld	hl,11	;const
	push	hl
	call	_mem_set
	pop	bc
	pop	bc
	pop	bc
	ld	hl,5	;const
	add	hl,sp
	push	hl
	ld	hl,6	;const
	add	hl,sp
	ld	(hl),+(0 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	pop	de
	ld	a,l
	ld	(de),a
	ld	hl,6	;const
	add	hl,sp
	ld	(hl),+(8 % 256 % 256)
	ld	hl,11	;const
	add	hl,sp
	call	l_gint	;
	call	l_gint	;
	pop	bc
	push	hl
.i_57
.i_59
	ld	hl,8	;const
	add	hl,sp
	push	hl
	ld	hl,2	;const
	call	l_gintspsp	;
	ld	hl,9	;const
	add	hl,sp
	inc	(hl)
	ld	l,(hl)
	ld	h,0
	dec	l
	pop	de
	add	hl,de
	pop	de
	ld	a,(hl)
	ld	(de),a
	ld	hl,8	;const
	add	hl,sp
	ld	e,(hl)
	ld	d,0
	ld	hl,32
	and	a
	sbc	hl,de
	ccf
	jp	c,i_61
	ld	hl,8	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,47
	and	a
	sbc	hl,de
	jr	nz,i_60
.i_61
	jp	i_58
.i_60
	ld	hl,8	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,46
	and	a
	sbc	hl,de
	scf
	jr	z,ASMPC+3
	ccf
	jp	c,i_64
	ld	hl,4	;const
	add	hl,sp
	ld	e,(hl)
	ld	d,0
	ld	hl,6	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	call	l_uge
	jp	nc,i_63
.i_64
	ld	hl,6	;const
	add	hl,sp
	ld	a,(hl)
	cp	8
	jr	z,ASMPC+3
	scf
	jp	c,i_67
	ld	hl,8	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,46
	and	a
	sbc	hl,de
	scf
	jr	nz,ASMPC+3
	ccf
	jr	nc,i_66
.i_67
	jp	i_58
.i_66
	ld	hl,4	;const
	add	hl,sp
	ld	(hl),+(8 % 256 % 256)
	ld	hl,6	;const
	add	hl,sp
	ld	(hl),+(11 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_57
.i_63
	jp	i_70
	ld	hl,4	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	push	hl
	ld	hl,8	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	dec	hl
	pop	de
	ex	de,hl
	and	a
	sbc	hl,de
	jr	c,i_71_i_70
.i_70
	jp	i_69
.i_71_i_70
	ld	hl,7	;const
	add	hl,sp
	push	hl
	ld	hl,2	;const
	call	l_gintspsp	;
	ld	hl,9	;const
	add	hl,sp
	inc	(hl)
	ld	l,(hl)
	ld	h,0
	dec	l
	pop	de
	add	hl,de
	pop	de
	ld	a,(hl)
	ld	(de),a
	ld	hl,2	;const
	call	l_gintspsp	;
	ld	hl,6	;const
	add	hl,sp
	inc	(hl)
	ld	l,(hl)
	ld	h,0
	dec	l
	pop	de
	add	hl,de
	ex	de,hl
	ld	hl,8	;const
	add	hl,sp
	ld	a,(hl)
	ld	(de),a
	ld	hl,2	;const
	call	l_gintspsp	;
	ld	hl,6	;const
	add	hl,sp
	inc	(hl)
	ld	l,(hl)
	ld	h,0
	dec	l
	pop	de
	add	hl,de
	push	hl
	ld	hl,9	;const
	add	hl,sp
	ld	a,(hl)
	pop	de
	ld	(de),a
	ld	l,a
	ld	h,0
	jp	i_72
.i_69
	jp	i_74
	ld	hl,8	;const
	add	hl,sp
	ld	e,(hl)
	ld	d,0
	ld	hl,97
	call	l_uge
	jp	nc,i_75
	ld	hl,8	;const
	add	hl,sp
	ld	e,(hl)
	ld	d,0
	ld	hl,122
	and	a
	sbc	hl,de
	ccf
	jr	c,i_76_i_75
.i_75
	jp	i_74
.i_76_i_75
	jr	i_77_i_74
.i_74
	jp	i_73
.i_77_i_74
	ld	hl,8	;const
	add	hl,sp
	ld	a,(hl)
	add	a,+(-32 % 256)
	ld	(hl),a
.i_73
	ld	hl,2	;const
	call	l_gintspsp	;
	ld	hl,6	;const
	add	hl,sp
	inc	(hl)
	ld	l,(hl)
	ld	h,0
	dec	l
	pop	de
	add	hl,de
	push	hl
	ld	hl,10	;const
	add	hl,sp
	ld	a,(hl)
	pop	de
	ld	(de),a
	ld	l,a
	ld	h,0
.i_72
	jp	i_57
.i_58
	ld	hl,11	;const
	call	l_gintspsp	;
	ld	hl,2	;const
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,7	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	add	hl,de
	pop	de
	call	l_pint
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	bc,11
	add	hl,bc
	push	hl
	ld	hl,10	;const
	add	hl,sp
	ld	e,(hl)
	ld	d,0
	ld	hl,32
	and	a
	sbc	hl,de
	ccf
	jp	nc,i_78
	ld	hl,1	;const
	jp	i_79
.i_78
	ld	hl,0	;const
.i_79
	pop	de
	ld	a,l
	ld	(de),a
	ld	hl,0	;const
	inc	sp
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret



; Function get_fileinfo flags 0x00000200 __smallc 
; void get_fileinfo(struct 0__anonstruct_5 DIR*dj, unsigned char BYTE*dir, struct 0__anonstruct_6 FILINFO*fno)
; parameter 'struct 0__anonstruct_6 FILINFO*fno' at 2 size(2)
; parameter 'unsigned char BYTE*dir' at 4 size(2)
; parameter 'struct 0__anonstruct_5 DIR*dj' at 6 size(2)
._get_fileinfo
	push	bc
	push	bc
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,9
	add	hl,bc
	pop	bc
	push	hl
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,12
	add	hl,bc
	call	l_glong
	ld	a,h
	or	l
	or	d
	or	e
	jp	z,i_80
	ld	hl,3	;const
	add	hl,sp
	ld	(hl),+(0 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_83
.i_81
	ld	hl,3	;const
	add	hl,sp
	inc	(hl)
.i_83
	ld	hl,3	;const
	add	hl,sp
	ld	a,(hl)
	sub	8
	jp	nc,i_82
	ld	hl,2	;const
	add	hl,sp
	push	hl
	ld	hl,10	;const
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,5	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	add	hl,de
	ld	a,(hl)
	pop	de
	ld	(de),a
	ld	hl,2	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,32
	and	a
	sbc	hl,de
	jp	z,i_82
.i_84
	ld	hl,2	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	5
	jp	nz,i_85
	ld	hl,2	;const
	add	hl,sp
	ld	(hl),+(229 % 256 % 256)
.i_85
	pop	hl
	inc	hl
	push	hl
	dec	hl
	push	hl
	ld	hl,4	;const
	add	hl,sp
	ld	l,(hl)
	ld	a,l
	rla
	sbc	a
	ld	h,a
	pop	de
	ld	a,l
	ld	(de),a
	jp	i_81
.i_82
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,8
	add	hl,bc
	ld	l,(hl)
	ld	h,0
	ld	de,32
	and	a
	sbc	hl,de
	scf
	jr	nz,ASMPC+3
	ccf
	jp	nc,i_86
	pop	hl
	ld	(hl),+(46 % 256)
	inc	hl
	push	hl
	ld	hl,3	;const
	add	hl,sp
	ld	(hl),+(8 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_89
.i_87
	ld	hl,3	;const
	add	hl,sp
	inc	(hl)
.i_89
	ld	hl,3	;const
	add	hl,sp
	ld	a,(hl)
	sub	11
	jp	nc,i_88
	ld	hl,2	;const
	add	hl,sp
	push	hl
	ld	hl,10	;const
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,5	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	add	hl,de
	ld	a,(hl)
	pop	de
	ld	(de),a
	ld	hl,2	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,32
	and	a
	sbc	hl,de
	jp	z,i_88
.i_90
	pop	hl
	inc	hl
	push	hl
	dec	hl
	push	hl
	ld	hl,4	;const
	add	hl,sp
	ld	l,(hl)
	ld	a,l
	rla
	sbc	a
	ld	h,a
	pop	de
	ld	a,l
	ld	(de),a
	jp	i_87
.i_88
.i_86
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,8
	add	hl,bc
	push	hl
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,11
	add	hl,bc
	ld	a,(hl)
	pop	de
	ld	(de),a
	ld	hl,6	;const
	call	l_gintspsp	;
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,28
	add	hl,bc
	push	hl
	call	_ld_dword
	pop	bc
	pop	bc
	call	l_plong
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,4
	add	hl,bc
	push	hl
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,24
	add	hl,bc
	push	hl
	call	_ld_word
	pop	bc
	pop	de
	call	l_pint
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,6
	add	hl,bc
	push	hl
	ld	hl,10	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,22
	add	hl,bc
	push	hl
	call	_ld_word
	pop	bc
	pop	de
	call	l_pint
.i_80
	pop	de
	push	de
	ld	hl,0	;const
	ld	a,l
	ld	(de),a
	pop	bc
	pop	bc
	ret



; Function follow_path flags 0x00000200 __smallc 
; const int FRESULTfollow_path(struct 0__anonstruct_5 DIR*dj, unsigned char BYTE*dir, const char *path)
; parameter 'const char *path' at 2 size(2)
; parameter 'unsigned char BYTE*dir' at 4 size(2)
; parameter 'struct 0__anonstruct_5 DIR*dj' at 6 size(2)
._follow_path
	push	bc
.i_91
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	ld	a,(hl)
	cp	32
	jp	nz,i_92
	ld	hl,4	;const
	add	hl,sp
	inc	(hl)
	ld	a,(hl)
	inc	hl
	jr	nz,ASMPC+3
	inc	(hl)
	ld	h,(hl)
	ld	l,a
	dec	hl
	jp	i_91
.i_92
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	ld	a,(hl)
	cp	47
	jp	nz,i_93
	ld	hl,4	;const
	add	hl,sp
	inc	(hl)
	ld	a,(hl)
	inc	hl
	jr	nz,ASMPC+3
	inc	(hl)
.i_93
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,4
	add	hl,bc
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	ld	l,(hl)
	ld	h,0
	ld	de,32
	and	a
	sbc	hl,de
	jp	nc,i_94
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_dir_rewind
	pop	bc
	pop	bc
	push	hl
	ld	hl,6	;const
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,0 % 256	;const
	ld	a,l
	ld	(de),a
	jp	i_95
.i_94
.i_96
.i_98
	ld	hl,8	;const
	call	l_gintspsp	;
	ld	hl,6	;const
	add	hl,sp
	push	hl
	call	_create_name
	pop	bc
	pop	bc
	pop	bc
	push	hl
	ld	a,h
	or	l
	jp	nz,i_97
.i_99
	ld	hl,8	;const
	call	l_gintspsp	;
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_dir_find
	pop	bc
	pop	bc
	pop	bc
	push	hl
	ld	a,h
	or	l
	jp	nz,i_97
.i_100
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	call	l_gint	;
	ld	bc,11
	add	hl,bc
	ld	l,(hl)
	ld	h,0
	ld	a,h
	or	l
	jp	nz,i_97
.i_101
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,11
	add	hl,bc
	ld	a,(hl)
	and	+(16 % 256)
	jp	nz,i_102
	ld	hl,3	;const
	pop	bc
	push	hl
	jp	i_97
.i_102
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,4
	add	hl,bc
	push	hl
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_get_clust
	pop	bc
	pop	bc
	call	l_plong
	jp	i_96
.i_97
.i_95
	pop	hl
	ret



; Function check_fs flags 0x00000200 __smallc 
; unsigned char BYTEcheck_fs(unsigned char BYTE*buf, unsigned long sect)
; parameter 'unsigned long sect' at 2 size(4)
; parameter 'unsigned char BYTE*buf' at 6 size(2)
._check_fs
	ld	hl,6	;const
	call	l_gintspsp	;
	ld	hl,4	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,510	;const
	push	hl
	ld	hl,2	;const
	push	hl
	call	_disk_readp
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jp	z,i_103
	ld	hl,3 % 256	;const
	ret


.i_103
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_ld_word
	pop	bc
	ld	de,43605
	and	a
	sbc	hl,de
	scf
	jr	nz,ASMPC+3
	ccf
	jp	nc,i_104
	ld	hl,2 % 256	;const
	ret


.i_104
	ld	hl,6	;const
	call	l_gintspsp	;
	ld	hl,4	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,82	;const
	push	hl
	ld	hl,2	;const
	push	hl
	call	_disk_readp
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	call	l_lneg
	jp	nc,i_106
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_ld_word
	pop	bc
	ld	de,16710
	and	a
	sbc	hl,de
	jr	z,i_107_i_106
.i_106
	jp	i_105
.i_107_i_106
	ld	hl,0 % 256	;const
	ret


.i_105
	ld	hl,1 % 256	;const
	ret



; Function pf_mount flags 0x00000200 __smallc 
; const int FRESULTpf_mount(struct 0__anonstruct_4 FATFS*fs)
; parameter 'struct 0__anonstruct_4 FATFS*fs' at 2 size(2)
._pf_mount
	ld	hl,65483	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,0	;const
	ld	(_FatFs),hl
	call	_disk_initialize
	ld	a,l
	and	+(1 % 256)
	jp	z,i_108
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,2	;const
	ret


.i_108
	ld	hl,12	;const
	add	hl,sp
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	ld	hl,52	;const
	add	hl,sp
	push	hl
	ld	hl,18	;const
	add	hl,sp
	push	hl
	ld	hl,16	;const
	add	hl,sp
	call	l_glong
	push	de
	push	hl
	call	_check_fs
	pop	bc
	pop	bc
	pop	bc
	pop	de
	ld	a,l
	ld	(de),a
	ld	hl,52	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	1
	jp	nz,i_109
	ld	hl,16	;const
	add	hl,sp
	push	hl
	ld	hl,14	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,446	;const
	push	hl
	ld	hl,16	;const
	push	hl
	call	_disk_readp
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jp	z,i_110
	ld	hl,52	;const
	add	hl,sp
	ld	(hl),+(3 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_111
.i_110
	ld	hl,20	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	z,i_112
	ld	hl,12	;const
	add	hl,sp
	push	hl
	ld	hl,26	;const
	add	hl,sp
	push	hl
	call	_ld_dword
	pop	bc
	pop	bc
	call	l_plong
	ld	hl,52	;const
	add	hl,sp
	push	hl
	ld	hl,18	;const
	add	hl,sp
	push	hl
	ld	hl,16	;const
	add	hl,sp
	call	l_glong
	push	de
	push	hl
	call	_check_fs
	pop	bc
	pop	bc
	pop	bc
	pop	de
	ld	a,l
	ld	(de),a
.i_112
.i_111
.i_109
	ld	hl,52	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	3
	jp	nz,i_113
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_113
	ld	hl,52	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	z,i_114
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,6	;const
	ret


.i_114
	ld	hl,16	;const
	add	hl,sp
	push	hl
	ld	hl,14	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,13	;const
	push	hl
	ld	hl,36	;const
	push	hl
	call	_disk_readp
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jp	z,i_115
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_115
	ld	hl,8	;const
	add	hl,sp
	push	hl
	ld	hl,27	;const
	add	hl,sp
	push	hl
	call	_ld_word
	pop	bc
	ld	de,0
	pop	bc
	call	l_plong
	ld	hl,8	;const
	add	hl,sp
	call	l_glong
	call	l_long_lneg
	jp	nc,i_116
	ld	hl,8	;const
	add	hl,sp
	push	hl
	ld	hl,41	;const
	add	hl,sp
	push	hl
	call	_ld_dword
	pop	bc
	pop	bc
	call	l_plong
.i_116
	ld	hl,8	;const
	add	hl,sp
	push	hl
	call	l_glong2sp
	ld	hl,25	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,0
	call	l_long_mult
	pop	bc
	call	l_plong
	ld	hl,55	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,10
	add	hl,bc
	push	hl
	ld	hl,14	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,23	;const
	add	hl,sp
	push	hl
	call	_ld_word
	pop	bc
	ld	de,0
	call	l_long_add
	pop	bc
	call	l_plong
	ld	hl,55	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	ex	de,hl
	ld	hl,16	;const
	add	hl,sp
	ld	a,(hl)
	ld	(de),a
	ld	hl,55	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,4
	add	hl,bc
	push	hl
	ld	hl,22	;const
	add	hl,sp
	push	hl
	call	_ld_word
	pop	bc
	pop	de
	call	l_pint
	ld	hl,4	;const
	add	hl,sp
	push	hl
	ld	hl,24	;const
	add	hl,sp
	push	hl
	call	_ld_word
	pop	bc
	ld	de,0
	pop	bc
	call	l_plong
	ld	hl,4	;const
	add	hl,sp
	call	l_glong
	call	l_long_lneg
	jp	nc,i_117
	ld	hl,4	;const
	add	hl,sp
	push	hl
	ld	hl,37	;const
	add	hl,sp
	push	hl
	call	_ld_dword
	pop	bc
	pop	bc
	call	l_plong
.i_117
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	hl,6	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,23	;const
	add	hl,sp
	push	hl
	call	_ld_word
	pop	bc
	ld	de,0
	call	l_long_sub
	push	de
	push	hl
	ld	hl,14	;const
	add	hl,sp
	call	l_glong
	call	l_long_sub
	push	de
	push	hl
	ld	hl,61	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,4
	add	hl,bc
	call	l_gint	;
	ld	de,4
	call	l_asr_u_hl_by_e
	ld	de,0
	call	l_long_sub
	push	de
	push	hl
	ld	hl,61	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	ld	l,(hl)
	ld	h,0
	ld	de,0
	call	l_long_div_u
	ld	bc,2
	add	hl,bc
	jr	nc,ASMPC+3
	inc	de
	pop	bc
	call	l_plong
	ld	hl,55	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,6
	add	hl,bc
	push	hl
	ld	hl,2	;const
	add	hl,sp
	call	l_glong
	pop	bc
	call	l_plong
	ld	hl,52	;const
	add	hl,sp
	ld	(hl),+(0 % 256 % 256)
	ld	hl,0	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,65527	;const
	ld	de,0
	call	l_long_uge
	jp	nc,i_118
	ld	hl,52	;const
	add	hl,sp
	ld	(hl),+(3 % 256 % 256)
.i_118
	ld	hl,52	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	nz,i_119
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,6	;const
	ret


.i_119
	ld	hl,55	;const
	call	l_gintspsp	;
	ld	hl,54	;const
	add	hl,sp
	ld	a,(hl)
	pop	de
	ld	(de),a
	ld	hl,55	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,14
	add	hl,bc
	push	hl
	ld	hl,49	;const
	add	hl,sp
	push	hl
	call	_ld_dword
	pop	bc
	pop	bc
	call	l_plong
	ld	hl,55	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,18
	add	hl,bc
	push	hl
	ld	hl,57	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,10
	add	hl,bc
	call	l_glong2sp
	ld	hl,14	;const
	add	hl,sp
	call	l_glong
	call	l_long_add
	push	de
	push	hl
	ld	hl,61	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,4
	add	hl,bc
	call	l_gint	;
	ld	de,4
	call	l_asr_u_hl_by_e
	ld	de,0
	call	l_long_add
	pop	bc
	call	l_plong
	ld	hl,55	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,55	;const
	add	hl,sp
	call	l_gint	;
	ld	(_FatFs),hl
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,0	;const
	ret



; Function pf_open flags 0x00000200 __smallc 
; const int FRESULTpf_open(const char *path)
; parameter 'const char *path' at 2 size(2)
._pf_open
	ld	hl,65474	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,(_FatFs)
	push	hl
	call	l_lneg
	jp	nc,i_120
	ld	hl,64	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,5	;const
	ret


.i_120
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,48	;const
	add	hl,sp
	push	hl
	ld	hl,36	;const
	add	hl,sp
	pop	de
	call	l_pint
	ld	hl,62	;const
	add	hl,sp
	push	hl
	ld	hl,48	;const
	add	hl,sp
	push	hl
	ld	hl,6	;const
	add	hl,sp
	push	hl
	ld	hl,72	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_follow_path
	pop	bc
	pop	bc
	pop	bc
	pop	de
	call	l_pint
	ld	hl,62	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	z,i_121
	ld	hl,62	;const
	add	hl,sp
	call	l_gint	;
	exx
	ld	hl,64	;const
	add	hl,sp
	ld	sp,hl
	exx
	ret


.i_121
	ld	hl,2	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	z,i_123
	ld	hl,13	;const
	add	hl,sp
	ld	a,+(16 % 256)
	and	(hl)
	jp	z,i_122
.i_123
	ld	hl,64	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,3	;const
	ret


.i_122
	pop	hl
	push	hl
	ld	bc,30
	add	hl,bc
	push	hl
	ld	hl,4	;const
	add	hl,sp
	push	hl
	call	_get_clust
	pop	bc
	pop	bc
	call	l_plong
	pop	hl
	push	hl
	ld	bc,26
	add	hl,bc
	push	hl
	ld	hl,32	;const
	add	hl,sp
	push	hl
	call	_ld_dword
	pop	bc
	pop	bc
	call	l_plong
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(1 % 256 % 256)
	ld	hl,64	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,0	;const
	ret



; Function pf_read flags 0x00000200 __smallc 
; const int FRESULTpf_read(void *buff, unsigned int btr, unsigned int UINT*br)
; parameter 'unsigned int UINT*br' at 2 size(2)
; parameter 'unsigned int btr' at 4 size(2)
; parameter 'void *buff' at 6 size(2)
._pf_read
	ld	hl,65519	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,23	;const
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	de
	ld	hl,(_FatFs)
	push	hl
	ld	hl,23	;const
	add	hl,sp
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	pop	hl
	push	hl
	call	l_lneg
	jp	nc,i_125
	ld	hl,21	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,5	;const
	ret


.i_125
	pop	hl
	push	hl
	inc	hl
	ld	a,(hl)
	and	+(1 % 256)
	jp	nz,i_126
	ld	hl,21	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,4	;const
	ret


.i_126
	ld	hl,7	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,26
	add	hl,bc
	call	l_glong2sp
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,22
	add	hl,bc
	call	l_glong
	call	l_long_sub
	pop	bc
	call	l_plong
	ld	hl,25	;const
	call	l_gintspsp	;
	ld	hl,9	;const
	add	hl,sp
	call	l_glong
	exx
	pop	hl
	ld	de,0
	push	de
	push	hl
	exx
	call	l_long_ugt
	jp	nc,i_127
	ld	hl,25	;const
	add	hl,sp
	push	hl
	ld	hl,9	;const
	add	hl,sp
	call	l_glong
	pop	de
	call	l_pint
.i_127
.i_128
	ld	hl,25	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	z,i_129
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	call	l_glong2sp
	ld	hl,512	;const
	ld	de,0
	call	l_long_div_u
	exx
	ld	a,d
	or	e
	or	h
	or	l
	jp	nz,i_130
	ld	hl,4	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,22
	add	hl,bc
	call	l_glong2sp
	ld	hl,512	;const
	ld	de,0
	call	l_long_div_u
	push	de
	push	hl
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	ld	l,(hl)
	ld	h,0
	dec	hl
	ld	de,0
	call	l_long_and
	pop	de
	ld	a,l
	ld	(de),a
	ld	hl,4	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	nz,i_131
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	call	l_glong
	ld	a,d
	or	e
	or	h
	or	l
	jp	nz,i_132
	ld	hl,15	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,30
	add	hl,bc
	call	l_glong
	pop	bc
	call	l_plong
	jp	i_133
.i_132
	ld	hl,15	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,34
	add	hl,bc
	call	l_glong
	push	de
	push	hl
	call	_get_fat
	pop	bc
	pop	bc
	pop	bc
	call	l_plong
.i_133
	ld	hl,15	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,1	;const
	ld	de,0
	call	l_long_ule
	jp	nc,i_134
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,21	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_134
	pop	hl
	push	hl
	ld	bc,34
	add	hl,bc
	push	hl
	ld	hl,17	;const
	add	hl,sp
	call	l_glong
	pop	bc
	call	l_plong
.i_131
	ld	hl,11	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,34
	add	hl,bc
	call	l_glong
	push	de
	push	hl
	call	_clust2sect
	pop	bc
	pop	bc
	pop	bc
	call	l_plong
	ld	hl,11	;const
	add	hl,sp
	call	l_glong
	call	l_long_lneg
	jp	nc,i_135
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,21	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_135
	pop	hl
	push	hl
	ld	bc,38
	add	hl,bc
	push	hl
	ld	hl,13	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,10	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,0
	call	l_long_add
	pop	bc
	call	l_plong
.i_130
	ld	hl,5	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,22
	add	hl,bc
	call	l_gint
	ld	de,512
	ex	de,hl
	call	l_div_u
	ld	hl,512
	and	a
	sbc	hl,de
	pop	de
	call	l_pint
	ld	hl,5	;const
	call	l_gintspsp	;
	ld	hl,27	;const
	add	hl,sp
	call	l_gint	;
	pop	de
	and	a
	sbc	hl,de
	jp	nc,i_136
	ld	hl,5	;const
	add	hl,sp
	ex	de,hl
	ld	hl,25	;const
	add	hl,sp
	call	l_gint	;
	call	l_pint
.i_136
	ld	hl,19	;const
	add	hl,sp
	push	hl
	ld	hl,4	;const
	call	l_gintspsp	;
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,38
	add	hl,bc
	call	l_glong2sp
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,22
	add	hl,bc
	call	l_gint
	ld	de,512
	ex	de,hl
	call	l_div_u
	ex	de,hl
	push	hl
	ld	hl,15	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_disk_readp
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	de
	call	l_pint
	ld	hl,19	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	z,i_137
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,21	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_137
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	push	hl
	call	l_glong2sp
	ld	hl,11	;const
	add	hl,sp
	call	l_gint	;
	ld	de,0
	call	l_long_add
	pop	bc
	call	l_plong
	ld	hl,25	;const
	add	hl,sp
	push	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,7	;const
	add	hl,sp
	call	l_gint
	ex	de,hl
	and	a
	sbc	hl,de
	pop	de
	call	l_pint
	ld	hl,23	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,7	;const
	add	hl,sp
	call	l_gint
	add	hl,de
	pop	de
	call	l_pint
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	a,h
	or	l
	jp	z,i_138
	ld	hl,2	;const
	call	l_gintspsp	;
	ld	hl,7	;const
	add	hl,sp
	call	l_gint	;
	pop	de
	add	hl,de
	pop	de
	pop	bc
	push	hl
	push	de
.i_138
	jp	i_128
.i_129
	ld	hl,21	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,0	;const
	ret



; Function pf_write flags 0x00000200 __smallc 
; const int FRESULTpf_write(const void *buff, unsigned int btw, unsigned int UINT*bw)
; parameter 'unsigned int UINT*bw' at 2 size(2)
; parameter 'unsigned int btw' at 4 size(2)
; parameter 'const void *buff' at 6 size(2)
._pf_write
	ld	hl,65524	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,18	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	push	bc
	dec	sp
	ld	hl,(_FatFs)
	push	hl
	ld	hl,21	;const
	add	hl,sp
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	pop	hl
	push	hl
	call	l_lneg
	jp	nc,i_139
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,5	;const
	ret


.i_139
	pop	hl
	push	hl
	inc	hl
	ld	a,(hl)
	and	+(1 % 256)
	jp	nz,i_140
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,4	;const
	ret


.i_140
	ld	hl,23	;const
	add	hl,sp
	call	l_gint	;
	call	l_lneg
	jp	nc,i_141
	pop	hl
	push	hl
	inc	hl
	ld	a,+(64 % 256)
	and	(hl)
	jp	z,i_143
	ld	hl,0	;const
	push	hl
	ld	d,h
	ld	e,l
	push	de
	push	hl
	call	_disk_writep
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jr	nz,i_144_i_143
.i_143
	jp	i_142
.i_144_i_143
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_142
	pop	hl
	push	hl
	inc	hl
	push	hl
	ld	a,(hl)
	and	191
	ld	l,a
	ld	h,0
	pop	de
	ld	a,l
	ld	(de),a
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,0	;const
	ret


.i_141
	pop	hl
	push	hl
	inc	hl
	ld	a,(hl)
	and	+(64 % 256)
	jp	nz,i_146
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	push	hl
	call	l_glong2sp
	ld	hl,65024	;const
	ld	de,65535
	call	l_long_and
	pop	bc
	call	l_plong
.i_146
.i_145
	ld	hl,7	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,26
	add	hl,bc
	call	l_glong2sp
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,22
	add	hl,bc
	call	l_glong
	call	l_long_sub
	pop	bc
	call	l_plong
	ld	hl,23	;const
	call	l_gintspsp	;
	ld	hl,9	;const
	add	hl,sp
	call	l_glong
	exx
	pop	hl
	ld	de,0
	push	de
	push	hl
	exx
	call	l_long_ugt
	jp	nc,i_147
	ld	hl,23	;const
	add	hl,sp
	push	hl
	ld	hl,9	;const
	add	hl,sp
	call	l_glong
	pop	de
	call	l_pint
.i_147
.i_148
	ld	hl,23	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	z,i_149
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	call	l_gint
	ld	de,512
	ex	de,hl
	call	l_div_u
	ex	de,hl
	ld	a,h
	or	l
	jp	nz,i_150
	ld	hl,4	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,22
	add	hl,bc
	call	l_glong2sp
	ld	hl,512	;const
	ld	de,0
	call	l_long_div_u
	push	de
	push	hl
	ld	hl,6	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	ld	l,(hl)
	ld	h,0
	dec	hl
	ld	de,0
	call	l_long_and
	pop	de
	ld	a,l
	ld	(de),a
	ld	hl,4	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	nz,i_151
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	call	l_glong
	ld	a,d
	or	e
	or	h
	or	l
	jp	nz,i_152
	ld	hl,15	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,30
	add	hl,bc
	call	l_glong
	pop	bc
	call	l_plong
	jp	i_153
.i_152
	ld	hl,15	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,34
	add	hl,bc
	call	l_glong
	push	de
	push	hl
	call	_get_fat
	pop	bc
	pop	bc
	pop	bc
	call	l_plong
.i_153
	ld	hl,15	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,1	;const
	ld	de,0
	call	l_long_ule
	jp	nc,i_154
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_154
	pop	hl
	push	hl
	ld	bc,34
	add	hl,bc
	push	hl
	ld	hl,17	;const
	add	hl,sp
	call	l_glong
	pop	bc
	call	l_plong
.i_151
	ld	hl,11	;const
	add	hl,sp
	pop	de
	push	de
	push	hl
	ex	de,hl
	ld	bc,34
	add	hl,bc
	call	l_glong
	push	de
	push	hl
	call	_clust2sect
	pop	bc
	pop	bc
	pop	bc
	call	l_plong
	ld	hl,11	;const
	add	hl,sp
	call	l_glong
	call	l_long_lneg
	jp	nc,i_155
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_155
	pop	hl
	push	hl
	ld	bc,38
	add	hl,bc
	push	hl
	ld	hl,13	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,10	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,0
	call	l_long_add
	pop	bc
	call	l_plong
	pop	hl
	push	hl
	ld	bc,0
	push	bc
	ld	bc,38
	add	hl,bc
	call	l_glong
	push	de
	push	hl
	call	_disk_writep
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jp	z,i_156
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_156
	pop	hl
	push	hl
	inc	hl
	ld	a,(hl)
	or	64
	ld	(hl),a
.i_150
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	call	l_gint
	ld	de,512
	ex	de,hl
	call	l_div_u
	ld	hl,512
	and	a
	sbc	hl,de
	pop	de
	pop	bc
	push	hl
	push	de
	ld	hl,2	;const
	call	l_gintspsp	;
	ld	hl,25	;const
	add	hl,sp
	call	l_gint	;
	pop	de
	and	a
	sbc	hl,de
	jp	nc,i_157
	ld	hl,23	;const
	add	hl,sp
	call	l_gint	;
	pop	de
	pop	bc
	push	hl
	push	de
.i_157
	ld	hl,5	;const
	call	l_gintspsp	;
	ld	hl,4	;const
	add	hl,sp
	call	l_gint	;
	ld	de,0
	push	de
	push	hl
	call	_disk_writep
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jp	z,i_158
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_158
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	push	hl
	call	l_glong2sp
	ld	hl,8	;const
	add	hl,sp
	call	l_gint	;
	ld	de,0
	call	l_long_add
	pop	bc
	call	l_plong
	ld	hl,5	;const
	add	hl,sp
	push	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,4	;const
	add	hl,sp
	call	l_gint
	add	hl,de
	pop	de
	call	l_pint
	ld	hl,23	;const
	add	hl,sp
	push	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,4	;const
	add	hl,sp
	call	l_gint
	ex	de,hl
	and	a
	sbc	hl,de
	pop	de
	call	l_pint
	ld	hl,21	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,4	;const
	add	hl,sp
	call	l_gint
	add	hl,de
	pop	de
	call	l_pint
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	call	l_gint
	ld	de,512
	ex	de,hl
	call	l_div_u
	ex	de,hl
	ld	a,h
	or	l
	jp	nz,i_159
	push	hl
	ld	hl,0	;const
	ld	d,h
	ld	e,l
	push	de
	push	hl
	call	_disk_writep
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jp	z,i_160
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_160
	pop	hl
	push	hl
	inc	hl
	push	hl
	ld	a,(hl)
	and	191
	ld	l,a
	ld	h,0
	pop	de
	ld	a,l
	ld	(de),a
.i_159
	jp	i_148
.i_149
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,0	;const
	ret



; Function pf_opendir flags 0x00000200 __smallc 
; const int FRESULTpf_opendir(struct 0__anonstruct_5 DIR*dj, const char *path)
; parameter 'const char *path' at 2 size(2)
; parameter 'struct 0__anonstruct_5 DIR*dj' at 4 size(2)
._pf_opendir
	ld	hl,65490	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,(_FatFs)
	push	hl
	call	l_lneg
	jp	nc,i_161
	ld	hl,46	;const
	add	hl,sp
	ld	de,5	;const
	ex	de,hl
	call	l_pint
	jp	i_162
.i_161
	ld	hl,i_1+33
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,52	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	push	hl
	ld	hl,36	;const
	add	hl,sp
	pop	de
	call	l_pint
	ld	hl,46	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	call	l_gintspsp	;
	ld	hl,6	;const
	add	hl,sp
	push	hl
	ld	hl,56	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_follow_path
	pop	bc
	pop	bc
	pop	bc
	pop	de
	call	l_pint
	ld	hl,i_1+42
	push	hl
	ld	hl,48	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	ld	a,2
	call	printf
	pop	bc
	pop	bc
	ld	hl,46	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	nz,i_163
	ld	hl,2	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	z,i_164
	ld	hl,i_1+55
	push	hl
	ld	hl,4	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	push	hl
	ld	a,2
	call	printf
	pop	bc
	pop	bc
	ld	hl,13	;const
	add	hl,sp
	ld	a,+(16 % 256)
	and	(hl)
	jp	z,i_165
	ld	hl,52	;const
	add	hl,sp
	call	l_gint	;
	ld	bc,4
	add	hl,bc
	push	hl
	ld	hl,4	;const
	add	hl,sp
	push	hl
	call	_get_clust
	pop	bc
	pop	bc
	call	l_plong
	jp	i_166
.i_165
	ld	hl,46	;const
	add	hl,sp
	ld	de,3	;const
	ex	de,hl
	call	l_pint
.i_166
.i_164
	ld	hl,46	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	nz,i_167
	ld	hl,46	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_dir_rewind
	pop	bc
	pop	de
	call	l_pint
.i_167
.i_163
.i_162
	ld	hl,46	;const
	add	hl,sp
	call	l_gint	;
	exx
	ld	hl,48	;const
	add	hl,sp
	ld	sp,hl
	exx
	ret



; Function pf_readdir flags 0x00000200 __smallc 
; const int FRESULTpf_readdir(struct 0__anonstruct_5 DIR*dj, struct 0__anonstruct_6 FILINFO*fno)
; parameter 'struct 0__anonstruct_6 FILINFO*fno' at 2 size(2)
; parameter 'struct 0__anonstruct_5 DIR*dj' at 4 size(2)
._pf_readdir
	ld	hl,65490	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,(_FatFs)
	push	hl
	call	l_lneg
	jp	nc,i_168
	ld	hl,46	;const
	add	hl,sp
	ld	de,5	;const
	ex	de,hl
	call	l_pint
	jp	i_169
.i_168
	ld	hl,52	;const
	add	hl,sp
	call	l_gint	;
	inc	hl
	inc	hl
	push	hl
	ld	hl,36	;const
	add	hl,sp
	pop	de
	call	l_pint
	ld	hl,50	;const
	add	hl,sp
	call	l_gint	;
	call	l_lneg
	jp	nc,i_170
	ld	hl,46	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_dir_rewind
	pop	bc
	pop	de
	call	l_pint
	jp	i_171
.i_170
	ld	hl,i_1+70
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,46	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	call	l_gintspsp	;
	ld	hl,6	;const
	add	hl,sp
	push	hl
	call	_dir_read
	pop	bc
	pop	bc
	pop	de
	call	l_pint
	ld	hl,46	;const
	add	hl,sp
	call	l_gint	;
	ld	a,h
	or	l
	jp	nz,i_172
	ld	hl,52	;const
	call	l_gintspsp	;
	ld	hl,4	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_get_fileinfo
	pop	bc
	pop	bc
	pop	bc
	ld	hl,46	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	add	hl,sp
	call	l_gint	;
	push	hl
	call	_dir_next
	pop	bc
	pop	de
	call	l_pint
	ld	hl,46	;const
	add	hl,sp
	call	l_gint	;
	ld	de,3
	and	a
	sbc	hl,de
	jp	nz,i_173
	ld	hl,46	;const
	add	hl,sp
	ld	de,0	;const
	ex	de,hl
	call	l_pint
.i_173
.i_172
.i_171
.i_169
	ld	hl,46	;const
	add	hl,sp
	call	l_gint	;
	exx
	ld	hl,48	;const
	add	hl,sp
	ld	sp,hl
	exx
	ret


	SECTION	rodata_compiler
.i_1
	defm	"dir_read: sector:%ld, index:%l"
	defm	"d"
	defb	10

	defm	""
	defb	0

	defm	"OPENDIR"
	defb	10

	defm	""
	defb	0

	defm	"RESDIR:%02x"
	defb	10

	defm	""
	defb	0

	defm	"IS A DIR:%02x"
	defb	10

	defm	""
	defb	0

	defm	"Readdir"
	defb	10

	defm	""
	defb	0


; --- Start of Static Variables ---

	SECTION	bss_compiler
._FatFs	defs	2
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


; --- End of Scope Defns ---


; --- End of Compilation ---
