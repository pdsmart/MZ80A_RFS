;* * * * *  Small-C/Plus z88dk * * * * *
;  Version: 16120-f784809cf-20200301
;
;	Reconstructed for z80 Module Assembler
;
;	Module compile time: Fri Mar 13 22:51:17 2020



	MODULE	pff_write_c


	INCLUDE "z80_crt0.hdr"


	SECTION	code_compiler

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
	call	l_gintsp	;
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
	jp	nc,i_2
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,5	;const
	ret


.i_2
	pop	hl
	push	hl
	inc	hl
	ld	a,(hl)
	and	+(1 % 256)
	jp	nz,i_3
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,4	;const
	ret


.i_3
	ld	hl,23	;const
	call	l_gintsp	;
	call	l_lneg
	jp	nc,i_4
	pop	hl
	push	hl
	inc	hl
	ld	a,+(64 % 256)
	and	(hl)
	jp	z,i_6
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
	jr	nz,i_7_i_6
.i_6
	jp	i_5
.i_7_i_6
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_5
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


.i_4
	pop	hl
	push	hl
	inc	hl
	ld	a,(hl)
	and	+(64 % 256)
	jp	nz,i_9
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
.i_9
.i_8
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
	call	l_gintsp	;
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
	jp	nc,i_10
	ld	hl,23	;const
	add	hl,sp
	push	hl
	ld	hl,9	;const
	add	hl,sp
	call	l_glong
	call	l_pint_pop
.i_10
.i_11
	ld	hl,23	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_12
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
	jp	nz,i_13
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
	call	l_gintsp	;
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
	jp	nz,i_14
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	call	l_glong
	ld	a,d
	or	e
	or	h
	or	l
	jp	nz,i_15
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
	jp	i_16
.i_15
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
.i_16
	ld	hl,15	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,1	;const
	ld	de,0
	call	l_long_ule
	jp	nc,i_17
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_17
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
.i_14
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
	jp	nc,i_18
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_18
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
	jp	z,i_19
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_19
	pop	hl
	push	hl
	inc	hl
	ld	a,(hl)
	or	64
	ld	(hl),a
.i_13
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
	call	l_gintsp	;
	pop	de
	and	a
	sbc	hl,de
	jp	nc,i_20
	ld	hl,23	;const
	call	l_gintsp	;
	pop	de
	pop	bc
	push	hl
	push	de
.i_20
	ld	hl,5	;const
	call	l_gintspsp	;
	ld	hl,4	;const
	call	l_gintsp	;
	ld	de,0
	push	de
	push	hl
	call	_disk_writep
	pop	bc
	pop	bc
	pop	bc
	ld	a,h
	or	l
	jp	z,i_21
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_21
	pop	hl
	push	hl
	ld	bc,22
	add	hl,bc
	push	hl
	call	l_glong2sp
	ld	hl,8	;const
	call	l_gintsp	;
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
	call	l_pint_pop
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
	call	l_pint_pop
	ld	hl,21	;const
	call	l_gintsp	;
	push	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,4	;const
	add	hl,sp
	call	l_gint
	add	hl,de
	call	l_pint_pop
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
	jp	nz,i_22
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
	jp	z,i_23
	pop	hl
	push	hl
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_23
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
.i_22
	jp	i_11
.i_12
	ld	hl,19	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,0	;const
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
