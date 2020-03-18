;* * * * *  Small-C/Plus z88dk * * * * *
;  Version: 16120-f784809cf-20200301
;
;	Reconstructed for z80 Module Assembler
;
;	Module compile time: Fri Mar 13 22:51:17 2020



	MODULE	pff_mount_c


	INCLUDE "z80_crt0.hdr"


	SECTION	code_compiler

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
	jp	z,i_2
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,2	;const
	ret


.i_2
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
	call	l_glongsp	;
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
	jp	nz,i_3
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
	jp	z,i_4
	ld	hl,52	;const
	add	hl,sp
	ld	(hl),+(3 % 256 % 256)
	ld	l,(hl)
	ld	h,0
	jp	i_5
.i_4
	ld	hl,20	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	z,i_6
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
	call	l_glongsp	;
	call	_check_fs
	pop	bc
	pop	bc
	pop	bc
	pop	de
	ld	a,l
	ld	(de),a
.i_6
.i_5
.i_3
	ld	hl,52	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	ld	a,l
	cp	3
	jp	nz,i_7
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_7
	ld	hl,52	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	z,i_8
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,6	;const
	ret


.i_8
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
	jp	z,i_9
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,1	;const
	ret


.i_9
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
	jp	nc,i_10
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
.i_10
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
	call	l_gintsp	;
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
	call	l_gintsp	;
	inc	hl
	inc	hl
	ex	de,hl
	ld	hl,16	;const
	add	hl,sp
	ld	a,(hl)
	ld	(de),a
	ld	hl,55	;const
	call	l_gintsp	;
	ld	bc,4
	add	hl,bc
	push	hl
	ld	hl,22	;const
	add	hl,sp
	push	hl
	call	_ld_word
	pop	bc
	call	l_pint_pop
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
	jp	nc,i_11
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
.i_11
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	jp	nc,i_12
	ld	hl,52	;const
	add	hl,sp
	ld	(hl),+(3 % 256 % 256)
.i_12
	ld	hl,52	;const
	add	hl,sp
	ld	a,(hl)
	and	a
	jp	nz,i_13
	ld	hl,53	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,6	;const
	ret


.i_13
	ld	hl,55	;const
	call	l_gintspsp	;
	ld	hl,54	;const
	add	hl,sp
	ld	a,(hl)
	pop	de
	ld	(de),a
	ld	hl,55	;const
	call	l_gintsp	;
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
	call	l_gintsp	;
	ld	bc,18
	add	hl,bc
	push	hl
	ld	hl,57	;const
	call	l_gintsp	;
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
	call	l_gintsp	;
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
	call	l_gintsp	;
	inc	hl
	ld	(hl),+(0 % 256 % 256)
	ld	hl,55	;const
	call	l_gintsp	;
	ld	(_FatFs),hl
	ld	hl,53	;const
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
