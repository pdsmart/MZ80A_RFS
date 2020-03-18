;* * * * *  Small-C/Plus z88dk * * * * *
;  Version: 16120-f784809cf-20200301
;
;	Reconstructed for z80 Module Assembler
;
;	Module compile time: Fri Mar 13 22:51:17 2020



	MODULE	pff_func_c


	INCLUDE "z80_crt0.hdr"


	SECTION	code_compiler

; Function ld_word flags 0x00000200 __smallc 
; unsigned int WORDld_word(const unsigned char BYTE*ptr)
; parameter 'const unsigned char BYTE*ptr' at 2 size(2)
._ld_word
	push	bc
	ld	hl,4	;const
	call	l_gintsp	;
	inc	hl
	ld	l,(hl)
	ld	h,0
	pop	bc
	push	hl
	ld	h,l
	ld	l,0
	push	hl
	ld	hl,6	;const
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
	inc	hl
	inc	hl
	ld	l,(hl)
	ld	h,0
	ld	de,0
	call	l_long_mult
	push	de
	push	hl
	ld	hl,4	;const
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	ld	a,(hl)
	pop	de
	ld	(de),a
	ld	hl,6	;const
	add	hl,sp
	ld	(hl),+(8 % 256 % 256)
	ld	hl,11	;const
	call	l_gintsp	;
	call	l_gint	;
	pop	bc
	push	hl
.i_17
.i_19
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
	jp	c,i_21
	ld	hl,8	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	de,47
	and	a
	sbc	hl,de
	jr	nz,i_20
.i_21
	jp	i_18
.i_20
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
	jp	c,i_24
	ld	hl,4	;const
	add	hl,sp
	ld	e,(hl)
	ld	d,0
	ld	hl,6	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	call	l_uge
	jp	nc,i_23
.i_24
	ld	hl,6	;const
	add	hl,sp
	ld	a,(hl)
	cp	8
	jr	z,ASMPC+3
	scf
	jp	c,i_27
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
	jr	nc,i_26
.i_27
	jp	i_18
.i_26
	ld	hl,4	;const
	add	hl,sp
	ld	(hl),+(8 % 256 % 256)
	ld	hl,6	;const
	add	hl,sp
	ld	(hl),+(11 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_17
.i_23
	jp	i_30
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
	jr	c,i_31_i_30
.i_30
	jp	i_29
.i_31_i_30
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
	jp	i_32
.i_29
	jp	i_34
	ld	hl,8	;const
	add	hl,sp
	ld	e,(hl)
	ld	d,0
	ld	hl,97
	call	l_uge
	jp	nc,i_35
	ld	hl,8	;const
	add	hl,sp
	ld	e,(hl)
	ld	d,0
	ld	hl,122
	and	a
	sbc	hl,de
	ccf
	jr	c,i_36_i_35
.i_35
	jp	i_34
.i_36_i_35
	jr	i_37_i_34
.i_34
	jp	i_33
.i_37_i_34
	ld	hl,8	;const
	add	hl,sp
	ld	a,(hl)
	add	a,+(-32 % 256)
	ld	(hl),a
.i_33
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
.i_32
	jp	i_17
.i_18
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
	call	l_pint_pop
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
	jp	nc,i_38
	ld	hl,1	;const
	jp	i_39
.i_38
	ld	hl,0	;const
.i_39
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



; Function follow_path flags 0x00000200 __smallc 
; const int FRESULTfollow_path(struct 0__anonstruct_5 DIR*dj, unsigned char BYTE*dir, const char *path)
; parameter 'const char *path' at 2 size(2)
; parameter 'unsigned char BYTE*dir' at 4 size(2)
; parameter 'struct 0__anonstruct_5 DIR*dj' at 6 size(2)
._follow_path
	push	bc
.i_40
	ld	hl,4	;const
	call	l_gintsp	;
	ld	a,(hl)
	cp	32
	jp	nz,i_41
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
	jp	i_40
.i_41
	ld	hl,4	;const
	call	l_gintsp	;
	ld	a,(hl)
	cp	47
	jp	nz,i_42
	ld	hl,4	;const
	add	hl,sp
	inc	(hl)
	ld	a,(hl)
	inc	hl
	jr	nz,ASMPC+3
	inc	(hl)
.i_42
	ld	hl,8	;const
	call	l_gintsp	;
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
	call	l_gintsp	;
	ld	l,(hl)
	ld	h,0
	ld	de,32
	and	a
	sbc	hl,de
	jp	nc,i_43
	ld	hl,8	;const
	call	l_gintsp	;
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
	jp	i_44
.i_43
.i_45
.i_47
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
	jp	nz,i_46
.i_48
	ld	hl,8	;const
	call	l_gintspsp	;
	ld	hl,8	;const
	call	l_gintsp	;
	push	hl
	call	_dir_find
	pop	bc
	pop	bc
	pop	bc
	push	hl
	ld	a,h
	or	l
	jp	nz,i_46
.i_49
	ld	hl,8	;const
	call	l_gintsp	;
	inc	hl
	inc	hl
	call	l_gint	;
	ld	bc,11
	add	hl,bc
	ld	l,(hl)
	ld	a,l
	and	a
	jp	nz,i_46
.i_50
	ld	hl,6	;const
	call	l_gintsp	;
	ld	bc,11
	add	hl,bc
	ld	a,(hl)
	and	+(16 % 256)
	jp	nz,i_51
	ld	hl,3	;const
	pop	bc
	push	hl
	jp	i_46
.i_51
	ld	hl,8	;const
	call	l_gintsp	;
	ld	bc,4
	add	hl,bc
	push	hl
	ld	hl,8	;const
	call	l_gintsp	;
	push	hl
	call	_get_clust
	pop	bc
	pop	bc
	call	l_plong
	jp	i_45
.i_46
.i_44
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
	jp	z,i_52
	ld	hl,3 % 256	;const
	ret


.i_52
	ld	hl,6	;const
	call	l_gintsp	;
	push	hl
	call	_ld_word
	pop	bc
	ld	de,43605
	and	a
	sbc	hl,de
	scf
	jr	nz,ASMPC+3
	ccf
	jp	nc,i_53
	ld	hl,2 % 256	;const
	ret


.i_53
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
	jp	nc,i_55
	ld	hl,6	;const
	call	l_gintsp	;
	push	hl
	call	_ld_word
	pop	bc
	ld	de,16710
	and	a
	sbc	hl,de
	jr	z,i_56_i_55
.i_55
	jp	i_54
.i_56_i_55
	ld	hl,0 % 256	;const
	ret


.i_54
	ld	hl,1 % 256	;const
	ret



; --- Start of Static Variables ---

	SECTION	bss_compiler
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
	GLOBAL	_ld_word
	GLOBAL	_ld_dword
	GLOBAL	_mem_set
	GLOBAL	_mem_cmp
	GLOBAL	_get_fat
	GLOBAL	_clust2sect
	GLOBAL	_create_name
	GLOBAL	_follow_path
	GLOBAL	_get_clust
	GLOBAL	_check_fs
	GLOBAL	_dir_rewind
	GLOBAL	_dir_find


; --- End of Scope Defns ---


; --- End of Compilation ---
