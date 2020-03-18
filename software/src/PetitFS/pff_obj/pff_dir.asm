;* * * * *  Small-C/Plus z88dk * * * * *
;  Version: 16120-f784809cf-20200301
;
;	Reconstructed for z80 Module Assembler
;
;	Module compile time: Fri Mar 13 22:51:17 2020



	MODULE	pff_dir_c


	INCLUDE "z80_crt0.hdr"


	SECTION	code_compiler

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
	call	l_gintsp	;
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
	jp	c,i_3
	ld	hl,2	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,4	;const
	call	l_gintsp	;
	ld	bc,6
	add	hl,bc
	call	l_glong
	call	l_long_uge
	jp	nc,i_2
.i_3
	ld	hl,1	;const
	pop	bc
	pop	bc
	pop	bc
	ret


.i_2
	ld	hl,2	;const
	add	hl,sp
	call	l_glong
	call	l_long_lneg
	jp	nc,i_5
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
.i_5
	ld	hl,8	;const
	call	l_gintsp	;
	ld	bc,8
	add	hl,bc
	push	hl
	ld	hl,4	;const
	add	hl,sp
	call	l_glong
	pop	bc
	call	l_plong
	ld	hl,8	;const
	call	l_gintsp	;
	ld	bc,12
	add	hl,bc
	push	hl
	ld	hl,4	;const
	call	l_glongsp	;
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
	call	l_gintsp	;
	call	l_gint	;
	inc	hl
	pop	de
	pop	bc
	push	hl
	push	de
	call	l_lneg
	jp	c,i_7
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,12
	add	hl,bc
	call	l_glong
	call	l_long_lneg
	jp	nc,i_6
.i_7
	ld	hl,3	;const
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret


.i_6
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	a,l
	and	+(15 % 256)
	jp	nz,i_9
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,12
	add	hl,bc
	push	hl
	call	l_glong
	call	l_inclong
	pop	bc
	call	l_plong
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,8
	add	hl,bc
	call	l_glong
	ld	a,d
	or	e
	or	h
	or	l
	jp	nz,i_10
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
	jp	nc,i_11
	ld	hl,3	;const
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret


.i_11
	jp	i_12
.i_10
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
	jp	nz,i_13
	ld	hl,4	;const
	add	hl,sp
	push	hl
	ld	hl,12	;const
	call	l_gintsp	;
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
	jp	nc,i_14
	ld	hl,1	;const
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret


.i_14
	ld	hl,4	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,4	;const
	call	l_gintsp	;
	ld	bc,6
	add	hl,bc
	call	l_glong
	call	l_long_uge
	jp	nc,i_15
	ld	hl,3	;const
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret


.i_15
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,8
	add	hl,bc
	push	hl
	ld	hl,6	;const
	add	hl,sp
	call	l_glong
	pop	bc
	call	l_plong
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,12
	add	hl,bc
	push	hl
	ld	hl,6	;const
	call	l_glongsp	;
	call	_clust2sect
	pop	bc
	pop	bc
	pop	bc
	call	l_plong
.i_13
.i_12
.i_9
	ld	hl,10	;const
	call	l_gintspsp	;
	ld	hl,4	;const
	call	l_gintsp	;
	call	l_pint_pop
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
	call	l_gintsp	;
	push	hl
	call	_dir_rewind
	pop	bc
	call	l_pint_pop
	ld	hl,1	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_16
	ld	hl,1	;const
	call	l_gintsp	;
	inc	sp
	pop	bc
	ret


.i_16
.i_19
	ld	hl,1	;const
	add	hl,sp
	push	hl
	ld	hl,7	;const
	call	l_gintspsp	;
	ld	hl,11	;const
	call	l_gintsp	;
	ld	bc,12
	add	hl,bc
	call	l_glong2sp
	ld	hl,15	;const
	call	l_gintsp	;
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
	jp	z,i_20
	ld	hl,1	;const
	jp	i_21
.i_20
	ld	hl,0	;const
.i_21
	call	l_pint_pop
	ld	hl,1	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	nz,i_18
.i_22
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	hl,7	;const
	call	l_gintsp	;
	ld	a,(hl)
	pop	de
	ld	(de),a
	pop	hl
	push	hl
	ld	h,0
	ld	a,l
	and	a
	jp	nz,i_23
	ld	hl,1	;const
	add	hl,sp
	ld	de,3	;const
	ex	de,hl
	call	l_pint
	jp	i_18
.i_23
	ld	hl,5	;const
	call	l_gintsp	;
	ld	bc,11
	add	hl,bc
	ld	a,(hl)
	and	+(8 % 256)
	jp	nz,i_25
	ld	hl,5	;const
	call	l_gintspsp	;
	ld	hl,9	;const
	call	l_gintsp	;
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
	jr	c,i_26_i_25
.i_25
	jp	i_24
.i_26_i_25
	jp	i_18
.i_24
	ld	hl,1	;const
	add	hl,sp
	push	hl
	ld	hl,9	;const
	call	l_gintsp	;
	push	hl
	call	_dir_next
	pop	bc
	call	l_pint_pop
.i_17
	ld	hl,1	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_19
.i_18
	ld	hl,1	;const
	call	l_gintsp	;
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
.i_27
	ld	hl,8	;const
	call	l_gintsp	;
	ld	bc,12
	add	hl,bc
	call	l_glong
	ld	a,h
	or	l
	or	d
	or	e
	jp	z,i_28
	ld	hl,6	;const
	call	l_gintspsp	;
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,12
	add	hl,bc
	call	l_glong2sp
	ld	hl,14	;const
	call	l_gintsp	;
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
	jp	z,i_29
	ld	hl,1	;const
	jp	i_30
.i_29
	ld	hl,0	;const
.i_30
	pop	de
	pop	bc
	push	hl
	push	de
	ld	a,h
	or	l
	jp	nz,i_28
.i_31
	ld	hl,0	;const
	add	hl,sp
	push	hl
	ld	hl,8	;const
	call	l_gintsp	;
	ld	a,(hl)
	pop	de
	ld	(de),a
	pop	hl
	push	hl
	ld	h,0
	ld	a,l
	and	a
	jp	nz,i_32
	ld	hl,3	;const
	pop	de
	pop	bc
	push	hl
	push	de
	jp	i_28
.i_32
	ld	hl,1	;const
	add	hl,sp
	push	hl
	ld	hl,8	;const
	call	l_gintsp	;
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
	jp	z,i_34
	pop	hl
	push	hl
	ld	h,0
	ld	de,46
	and	a
	sbc	hl,de
	scf
	jr	nz,ASMPC+3
	ccf
	jp	nc,i_34
	pop	hl
	push	hl
	ld	l,h
	ld	h,0
	ld	a,+(8 % 256)
	and	l
	ld	l,a
	call	l_lneg
	jr	c,i_35_i_34
.i_34
	jp	i_33
.i_35_i_34
	jp	i_28
.i_33
	ld	hl,8	;const
	call	l_gintsp	;
	push	hl
	call	_dir_next
	pop	bc
	pop	de
	pop	bc
	push	hl
	push	de
	ld	a,h
	or	l
	jr	nz,i_28
.i_36
	jp	i_27
.i_28
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	a,h
	or	l
	jp	z,i_37
	ld	hl,8	;const
	call	l_gintsp	;
	ld	bc,12
	add	hl,bc
	push	hl
	ld	hl,0	;const
	ld	d,h
	ld	e,l
	pop	bc
	call	l_plong
.i_37
	pop	bc
	pop	hl
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
	call	l_gintsp	;
	ld	bc,9
	add	hl,bc
	pop	bc
	push	hl
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,12
	add	hl,bc
	call	l_glong
	ld	a,h
	or	l
	or	d
	or	e
	jp	z,i_38
	ld	hl,3	;const
	add	hl,sp
	ld	(hl),+(0 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_41
.i_39
	ld	hl,3	;const
	add	hl,sp
	inc	(hl)
.i_41
	ld	hl,3	;const
	add	hl,sp
	ld	a,(hl)
	sub	8
	jp	nc,i_40
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
	jp	z,i_40
.i_42
	ld	hl,2	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	5
	jp	nz,i_43
	ld	hl,2	;const
	add	hl,sp
	ld	(hl),+(229 % 256 % 256)
.i_43
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
	jp	i_39
.i_40
	ld	hl,8	;const
	call	l_gintsp	;
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
	jp	nc,i_44
	pop	hl
	ld	(hl),+(46 % 256)
	inc	hl
	push	hl
	ld	hl,3	;const
	add	hl,sp
	ld	(hl),+(8 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_47
.i_45
	ld	hl,3	;const
	add	hl,sp
	inc	(hl)
.i_47
	ld	hl,3	;const
	add	hl,sp
	ld	a,(hl)
	sub	11
	jp	nc,i_46
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
	jp	z,i_46
.i_48
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
	jp	i_45
.i_46
.i_44
	ld	hl,6	;const
	call	l_gintsp	;
	ld	bc,8
	add	hl,bc
	push	hl
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,11
	add	hl,bc
	ld	a,(hl)
	pop	de
	ld	(de),a
	ld	hl,6	;const
	call	l_gintspsp	;
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,28
	add	hl,bc
	push	hl
	call	_ld_dword
	pop	bc
	pop	bc
	call	l_plong
	ld	hl,6	;const
	call	l_gintsp	;
	ld	bc,4
	add	hl,bc
	push	hl
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,24
	add	hl,bc
	push	hl
	call	_ld_word
	pop	bc
	call	l_pint_pop
	ld	hl,6	;const
	call	l_gintsp	;
	ld	bc,6
	add	hl,bc
	push	hl
	ld	hl,10	;const
	call	l_gintsp	;
	ld	bc,22
	add	hl,bc
	push	hl
	call	_ld_word
	pop	bc
	call	l_pint_pop
.i_38
	pop	de
	push	de
	ld	hl,0	;const
	ld	a,l
	ld	(de),a
	pop	bc
	pop	bc
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
	jp	nc,i_49
	ld	hl,46	;const
	add	hl,sp
	ld	de,5	;const
	ex	de,hl
	call	l_pint
	jp	i_50
.i_49
	ld	hl,52	;const
	call	l_gintsp	;
	inc	hl
	inc	hl
	push	hl
	ld	hl,36	;const
	add	hl,sp
	call	l_pint_pop
	ld	hl,46	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	call	l_gintspsp	;
	ld	hl,6	;const
	add	hl,sp
	push	hl
	ld	hl,56	;const
	call	l_gintsp	;
	push	hl
	call	_follow_path
	pop	bc
	pop	bc
	pop	bc
	call	l_pint_pop
	ld	hl,46	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	nz,i_51
	ld	hl,2	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	z,i_52
	ld	hl,13	;const
	add	hl,sp
	ld	a,+(16 % 256)
	and	(hl)
	jp	z,i_53
	ld	hl,52	;const
	call	l_gintsp	;
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
	jp	i_54
.i_53
	ld	hl,46	;const
	add	hl,sp
	ld	de,3	;const
	ex	de,hl
	call	l_pint
.i_54
.i_52
	ld	hl,46	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	nz,i_55
	ld	hl,46	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	call	l_gintsp	;
	push	hl
	call	_dir_rewind
	pop	bc
	call	l_pint_pop
.i_55
.i_51
.i_50
	ld	hl,46	;const
	call	l_gintsp	;
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
	jp	nc,i_56
	ld	hl,46	;const
	add	hl,sp
	ld	de,5	;const
	ex	de,hl
	call	l_pint
	jp	i_57
.i_56
	ld	hl,52	;const
	call	l_gintsp	;
	inc	hl
	inc	hl
	push	hl
	ld	hl,36	;const
	add	hl,sp
	call	l_pint_pop
	ld	hl,50	;const
	call	l_gintsp	;
	call	l_lneg
	jp	nc,i_58
	ld	hl,46	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	call	l_gintsp	;
	push	hl
	call	_dir_rewind
	pop	bc
	call	l_pint_pop
	jp	i_59
.i_58
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
	call	l_pint_pop
	ld	hl,46	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	nz,i_60
	ld	hl,52	;const
	call	l_gintspsp	;
	ld	hl,4	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	call	l_gintsp	;
	push	hl
	call	_get_fileinfo
	pop	bc
	pop	bc
	pop	bc
	ld	hl,46	;const
	add	hl,sp
	push	hl
	ld	hl,54	;const
	call	l_gintsp	;
	push	hl
	call	_dir_next
	pop	bc
	call	l_pint_pop
	ld	hl,46	;const
	call	l_gintsp	;
	ld	de,3
	and	a
	sbc	hl,de
	jp	nz,i_61
	ld	hl,46	;const
	add	hl,sp
	ld	de,0	;const
	ex	de,hl
	call	l_pint
.i_61
.i_60
.i_59
.i_57
	ld	hl,46	;const
	call	l_gintsp	;
	exx
	ld	hl,48	;const
	add	hl,sp
	ld	sp,hl
	exx
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
	GLOBAL	_dir_next
	GLOBAL	_dir_read
	GLOBAL	_get_fileinfo


; --- End of Scope Defns ---


; --- End of Compilation ---
