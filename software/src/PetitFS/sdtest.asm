;* * * * *  Small-C/Plus z88dk * * * * *
;  Version: 16120-f784809cf-20200301
;
;	Reconstructed for z80 Module Assembler
;
;	Module compile time: Fri Mar 13 22:46:08 2020



	MODULE	sdtest_c


	INCLUDE "z80_crt0.hdr"


	SECTION	code_compiler

; Function die flags 0x00000200 __smallc 
; void die(const int rc)
; parameter 'const int rc' at 2 size(2)
._die
	ld	hl,i_1+0
	push	hl
	ld	hl,4	;const
	call	l_gintsp	;
	push	hl
	ld	a,2
	call	printf
	pop	bc
	pop	bc
	ld	hl,i_1+20
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,10	;const
	call	sleep
	ret



; Function main flags 0x00000000 __stdc 
; int main()
._main
	ld	hl,65381	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,i_1+41
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,i_1+86
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,3	;const
	add	hl,sp
	ld	de,5	;const
	ex	de,hl
	call	l_pint
	call	_disk_initialize
	call	l_lneg
	jp	nc,i_2
	ld	hl,i_1+115
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,3	;const
	add	hl,sp
	push	hl
	ld	hl,115	;const
	add	hl,sp
	push	hl
	call	_pf_mount
	pop	bc
	call	l_pint_pop
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_3
	ld	hl,i_1+137
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,3	;const
	call	l_gintsp	;
	push	hl
	call	_die
	pop	bc
.i_3
	ld	hl,i_1+192
	push	hl
	ld	a,1
	call	printf
	pop	bc
.i_2
	ld	hl,i_1+209
	push	hl
	ld	hl,115	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	push	hl
	ld	hl,118	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	push	hl
	ld	hl,121	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	push	hl
	ld	hl,124	;const
	add	hl,sp
	ld	l,(hl)
	ld	h,0
	push	hl
	ld	hl,129	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,137	;const
	call	l_glongsp	;
	ld	a,9
	call	printf
	ld	hl,18	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,i_1+275
	push	hl
	ld	hl,129	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,137	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,145	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,153	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,161	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,169	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,177	;const
	call	l_glongsp	;
	ld	a,15
	call	printf
	ld	hl,30	;const
	add	hl,sp
	ld	sp,hl
	ld	hl,10	;const
	call	sleep
	ld	hl,i_1+365
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,3	;const
	add	hl,sp
	push	hl
	ld	hl,99	;const
	add	hl,sp
	push	hl
	ld	hl,i_1+19
	push	hl
	call	_pf_opendir
	pop	bc
	pop	bc
	call	l_pint_pop
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_4
	ld	hl,3	;const
	call	l_gintsp	;
	push	hl
	call	_die
	pop	bc
.i_4
	ld	hl,i_1+388
	push	hl
	ld	a,1
	call	printf
	pop	bc
.i_5
.i_7
	ld	hl,3	;const
	add	hl,sp
	push	hl
	ld	hl,99	;const
	add	hl,sp
	push	hl
	ld	hl,79	;const
	add	hl,sp
	push	hl
	call	_pf_readdir
	pop	bc
	pop	bc
	call	l_pint_pop
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	nz,i_9
	ld	hl,75	;const
	call	l_gcharsp	;
	call	l_lneg
	jr	nc,i_8
.i_9
	jp	i_6
.i_8
	ld	hl,83	;const
	add	hl,sp
	ld	a,+(16 % 256)
	and	(hl)
	jp	z,i_11
	ld	hl,i_1+411
	push	hl
	ld	hl,86	;const
	add	hl,sp
	push	hl
	ld	a,2
	call	printf
	pop	bc
	pop	bc
	jp	i_12
.i_11
	ld	hl,i_1+425
	push	hl
	ld	hl,77	;const
	add	hl,sp
	call	l_glong2sp
	ld	hl,90	;const
	add	hl,sp
	push	hl
	ld	a,4
	call	printf
	pop	bc
	pop	bc
	pop	bc
	pop	bc
.i_12
	jp	i_5
.i_6
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_13
	ld	hl,3	;const
	call	l_gintsp	;
	push	hl
	call	_die
	pop	bc
.i_13
	ld	hl,i_1+435
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,3	;const
	add	hl,sp
	push	hl
	ld	hl,i_1+469
	push	hl
	call	_pf_open
	pop	bc
	call	l_pint_pop
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_14
	ld	hl,3	;const
	call	l_gintsp	;
	push	hl
	call	_die
	pop	bc
.i_14
	ld	hl,i_1+481
	push	hl
	ld	a,1
	call	printf
	pop	bc
.i_15
	ld	hl,3	;const
	add	hl,sp
	push	hl
	ld	hl,7	;const
	add	hl,sp
	push	hl
	ld	hl,64	;const
	push	hl
	ld	hl,77	;const
	add	hl,sp
	push	hl
	call	_pf_read
	pop	bc
	pop	bc
	pop	bc
	call	l_pint_pop
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	nz,i_18
	ld	hl,71	;const
	call	l_gintsp	;
	call	l_lneg
	jr	nc,i_17
.i_18
	jp	i_16
.i_17
	ld	hl,69	;const
	add	hl,sp
	ld	de,0	;const
	ex	de,hl
	call	l_pint
	jp	i_22
.i_20
	ld	hl,69	;const
	add	hl,sp
	inc	(hl)
	ld	a,(hl)
	inc	hl
	jr	nz,ASMPC+3
	inc	(hl)
.i_22
	ld	hl,69	;const
	call	l_gintspsp	;
	ld	hl,73	;const
	call	l_gintsp	;
	pop	de
	ex	de,hl
	and	a
	sbc	hl,de
	jp	nc,i_21
	ld	hl,5	;const
	add	hl,sp
	ex	de,hl
	ld	hl,69	;const
	call	l_gintsp	;
	add	hl,de
	ld	a,(hl)
	cp	13
	jp	z,i_23
	ld	hl,5	;const
	add	hl,sp
	ex	de,hl
	ld	hl,69	;const
	call	l_gintsp	;
	add	hl,de
	ld	l,(hl)
	ld	h,0
	push	hl
	ld	hl,__sgoioblk+10
	push	hl
	call	fputc_callee
.i_23
	jp	i_20
.i_21
	jp	i_15
.i_16
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_24
	ld	hl,3	;const
	call	l_gintsp	;
	push	hl
	call	_die
	pop	bc
.i_24
	ld	hl,20	;const
	call	sleep
	ld	hl,i_1+506
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,3	;const
	add	hl,sp
	push	hl
	ld	hl,i_1+543
	push	hl
	call	_pf_open
	pop	bc
	call	l_pint_pop
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_25
	ld	hl,3	;const
	call	l_gintsp	;
	push	hl
	call	_die
	pop	bc
.i_25
	ld	hl,i_1+554
	push	hl
	ld	a,1
	call	printf
	pop	bc
.i_26
.i_28
	ld	hl,3	;const
	add	hl,sp
	push	hl
	ld	hl,i_1+590
	push	hl
	ld	hl,14	;const
	push	hl
	ld	hl,79	;const
	add	hl,sp
	push	hl
	call	_pf_write
	pop	bc
	pop	bc
	pop	bc
	call	l_pint_pop
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	nz,i_30
	ld	hl,73	;const
	call	l_gintsp	;
	call	l_lneg
	jr	nc,i_29
.i_30
	jp	i_27
.i_29
	jp	i_26
.i_27
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_32
	ld	hl,3	;const
	call	l_gintsp	;
	push	hl
	call	_die
	pop	bc
.i_32
	ld	hl,i_1+605
	push	hl
	ld	a,1
	call	printf
	pop	bc
	ld	hl,3	;const
	add	hl,sp
	push	hl
	ld	hl,0	;const
	push	hl
	push	hl
	ld	hl,79	;const
	add	hl,sp
	push	hl
	call	_pf_write
	pop	bc
	pop	bc
	pop	bc
	call	l_pint_pop
	ld	hl,3	;const
	call	l_gintsp	;
	ld	a,h
	or	l
	jp	z,i_33
	ld	hl,3	;const
	call	l_gintsp	;
	push	hl
	call	_die
	pop	bc
.i_33
	ld	hl,i_1+641
	push	hl
	ld	a,1
	call	printf
	pop	bc
.i_34
.i_36
	jp	i_34
.i_35
	ld	hl,155	;const
	add	hl,sp
	ld	sp,hl
	ret


	SECTION	rodata_compiler
.i_1
	defm	"Failed with rc=%u."
	defb	10

	defm	""
	defb	0

	defm	"Please press reset."
	defb	10

	defm	""
	defb	0

	defm	"Hello Philip, this C program i"
	defm	"s working...."
	defb	10

	defm	""
	defb	0

	defm	"Firstly, initialise SD card"
	defb	10

	defm	""
	defb	0

	defm	""
	defb	10

	defm	"Now Mount a volume."
	defb	10

	defm	""
	defb	0

	defm	"Failed to initialise sd card 0"
	defm	", please init manually."
	defb	10

	defm	""
	defb	0

	defm	"Volume mounted."
	defb	10

	defm	""
	defb	0

	defm	"FSTYPE:%d, FLAG:%d, CSIZE:%d, "
	defm	"PADL:%d, N_FATENT:%ld, FATBASE"
	defm	":%;d"
	defb	10

	defm	""
	defb	0

	defm	"DIRBASE:%ld, DATABASE:%ld, FPT"
	defm	"R:%ld, FSIZE:%ld, ORG_CLUST:%l"
	defm	"d, CURR_CLUST:%ld, DSECT:%ld"
	defb	10

	defm	""
	defb	0

	defm	""
	defb	10

	defm	"Open root directory."
	defb	10

	defm	""
	defb	0

	defm	""
	defb	10

	defm	"Directory listing..."
	defb	10

	defm	""
	defb	0

	defm	"   <dir>  %s"
	defb	10

	defm	""
	defb	0

	defm	"%8lu  %s"
	defb	10

	defm	""
	defb	0

	defm	""
	defb	10

	defm	"Open a test file (message.txt)"
	defm	"."
	defb	10

	defm	""
	defb	0

	defm	"MESSAGE.TXT"
	defb	0

	defm	""
	defb	10

	defm	"Type the file content."
	defb	10

	defm	""
	defb	0

	defm	""
	defb	10

	defm	"Open a file to write (readme.t"
	defm	"xt)."
	defb	10

	defm	""
	defb	0

	defm	"README.TXT"
	defb	0

	defm	""
	defb	10

	defm	"Write a text data. (Hello worl"
	defm	"d!)"
	defb	10

	defm	""
	defb	0

	defm	"Hello world!"
	defb	13

	defm	""
	defb	10

	defm	""
	defb	0

	defm	""
	defb	10

	defm	"Terminate the file write proce"
	defm	"ss."
	defb	10

	defm	""
	defb	0

	defm	""
	defb	10

	defm	"Test completed."
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
	GLOBAL	_FatFs
	GLOBAL	_disk_initialize
	GLOBAL	_disk_readp
	GLOBAL	_disk_writep
	GLOBAL	_die
	GLOBAL	_main


; --- End of Scope Defns ---


; --- End of Compilation ---
