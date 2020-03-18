;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module pff
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _disk_initialize
	.globl _disk_readp
	.globl _disk_writep
	.globl _pf_mount
	.globl _pf_open
	.globl _pf_read
	.globl _pf_write
	.globl _pf_lseek
	.globl _pf_opendir
	.globl _pf_readdir
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_FatFs:
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;diskio.c:12: DSTATUS disk_initialize (void)
;	---------------------------------
; Function disk_initialize
; ---------------------------------
_disk_initialize::
;diskio.c:18: return stat;
	ld	iy, #-1
	add	iy, sp
	ld	l, 0 (iy)
l_disk_initialize_00101$:
;diskio.c:19: }
	ret
;diskio.c:27: DRESULT disk_readp (
;	---------------------------------
; Function disk_readp
; ---------------------------------
_disk_readp::
;diskio.c:38: return res;
	ld	iy, #-1
	add	iy, sp
	ld	l, 0 (iy)
l_disk_readp_00101$:
;diskio.c:39: }
	ret
;diskio.c:47: DRESULT disk_writep (
;	---------------------------------
; Function disk_writep
; ---------------------------------
_disk_writep::
;diskio.c:71: return res;
	ld	iy, #-1
	add	iy, sp
	ld	l, 0 (iy)
l_disk_writep_00103$:
;diskio.c:72: }
	ret
;pff.c:384: static WORD ld_word (const BYTE* ptr)	/*	 Load a 2-byte little-endian word */
;	---------------------------------
; Function ld_word
; ---------------------------------
_ld_word:
	call	___sdcc_enter_ix
;pff.c:388: rv = ptr[1];
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	inc	hl
	ld	c, (hl)
	ld	b, #0x00
;pff.c:389: rv = rv << 8 | ptr[0];
	ld	b, c
	ld	c, #0x00
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	e, (hl)
	ld	d, #0x00
	ld	a, c
	or	a, e
	ld	l, a
	ld	a, b
	or	a, d
	ld	h, a
;pff.c:390: return rv;
l_ld_word_00101$:
;pff.c:391: }
	pop	ix
	ret
;pff.c:393: static DWORD ld_dword (const BYTE* ptr)	/* Load a 4-byte little-endian word */
;	---------------------------------
; Function ld_dword
; ---------------------------------
_ld_dword:
	call	___sdcc_enter_ix
	push	af
	push	af
;pff.c:397: rv = ptr[3];
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	c, (hl)
	ld	b, #0x00
	ld	e, #0x00
	ld	d, #0x00
;pff.c:398: rv = rv << 8 | ptr[2];
	ld	-3 (ix), c
	ld	-2 (ix), b
	ld	-1 (ix), e
	xor	a, a
	ld	-4 (ix), a
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	inc	hl
	inc	hl
	ld	c, (hl)
	ld	b, #0x00
	ld	e, #0x00
	ld	d, #0x00
	ld	a, c
	or	a, -4 (ix)
	ld	c, a
	ld	a, b
	or	a, -3 (ix)
	ld	b, a
	ld	a, e
	or	a, -2 (ix)
	ld	e, a
	ld	a, d
	or	a, -1 (ix)
	ld	d, a
;pff.c:399: rv = rv << 8 | ptr[1];
	ld	-3 (ix), c
	ld	-2 (ix), b
	ld	-1 (ix), e
	xor	a, a
	ld	-4 (ix), a
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	inc	hl
	ld	c, (hl)
	ld	b, #0x00
	ld	e, #0x00
	ld	d, #0x00
	ld	a, c
	or	a, -4 (ix)
	ld	c, a
	ld	a, b
	or	a, -3 (ix)
	ld	b, a
	ld	a, e
	or	a, -2 (ix)
	ld	e, a
	ld	a, d
	or	a, -1 (ix)
	ld	d, a
;pff.c:400: rv = rv << 8 | ptr[0];
	ld	-3 (ix), c
	ld	-2 (ix), b
	ld	-1 (ix), e
	xor	a, a
	ld	-4 (ix), a
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	c, (hl)
	ld	b, #0x00
	ld	e, #0x00
	ld	d, #0x00
	ld	a, -4 (ix)
	or	a, c
	ld	l, a
	ld	a, -3 (ix)
	or	a, b
	ld	h, a
	ld	a, -2 (ix)
	or	a, e
	ld	e, a
	ld	a, -1 (ix)
	or	a, d
	ld	d, a
;pff.c:401: return rv;
l_ld_dword_00101$:
;pff.c:402: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:411: static void mem_set (void* dst, int val, int cnt) {
;	---------------------------------
; Function mem_set
; ---------------------------------
_mem_set:
	call	___sdcc_enter_ix
;pff.c:412: char *d = (char*)dst;
	ld	e, 4 (ix)
	ld	d, 5 (ix)
;pff.c:413: while (cnt--) *d++ = (char)val;
	ld	c, 8 (ix)
	ld	b, 9 (ix)
l_mem_set_00101$:
	ld	l, c
	ld	h, b
	dec	bc
	ld	a, h
	or	a, l
	jp	Z, l_mem_set_00104$
	ld	a, 6 (ix)
	ld	(de), a
	inc	de
	jp	l_mem_set_00101$
l_mem_set_00104$:
;pff.c:414: }
	pop	ix
	ret
;pff.c:417: static int mem_cmp (const void* dst, const void* src, int cnt) {
;	---------------------------------
; Function mem_cmp
; ---------------------------------
_mem_cmp:
	call	___sdcc_enter_ix
	push	af
	push	af
;pff.c:418: const char *d = (const char *)dst, *s = (const char *)src;
	ld	a, 4 (ix)
	ld	-4 (ix), a
	ld	a, 5 (ix)
	ld	-3 (ix), a
	ld	a, 6 (ix)
	ld	-2 (ix), a
	ld	a, 7 (ix)
	ld	-1 (ix), a
;pff.c:419: int r = 0;
	ld	hl, #0x0000
;pff.c:420: while (cnt-- && (r = *d++ - *s++) == 0) ;
	ld	c, 8 (ix)
	ld	b, 9 (ix)
l_mem_cmp_00102$:
	ld	e, c
	ld	d, b
	dec	bc
	ld	a, d
	or	a, e
	jp	Z, l_mem_cmp_00104$
	pop	hl
	push	hl
	ld	e, (hl)
	inc	-4 (ix)
	jp	NZ, l_mem_cmp_00118$
	inc	-3 (ix)
l_mem_cmp_00118$:
	ld	d, #0x00
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	l, (hl)
	inc	-2 (ix)
	jp	NZ, l_mem_cmp_00119$
	inc	-1 (ix)
l_mem_cmp_00119$:
	ld	h, #0x00
	ld	a, e
	sub	a, l
	ld	e, a
	ld	a, d
	sbc	a, h
	ld	d, a
	ld	l, e
	ld	h, d
	ld	a, d
	or	a, e
	jp	Z, l_mem_cmp_00102$
l_mem_cmp_00104$:
;pff.c:421: return r;
l_mem_cmp_00105$:
;pff.c:422: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:430: static CLUST get_fat (	/* 1:IO error, Else:Cluster status */
;	---------------------------------
; Function get_fat
; ---------------------------------
_get_fat:
	call	___sdcc_enter_ix
	ld	hl, #-14
	add	hl, sp
	ld	sp, hl
;pff.c:435: FATFS *fs = FatFs;
	ld	bc, (_FatFs)
;pff.c:440: if (clst < 2 || clst >= fs->n_fatent) return 1;	/* Range check */
	ld	a, 4 (ix)
	sub	a, #0x02
	ld	a, 5 (ix)
	sbc	a, #0x00
	ld	a, 6 (ix)
	sbc	a, #0x00
	ld	a, 7 (ix)
	sbc	a, #0x00
	jp	C, l_get_fat_00101$
	ld	l, c
	ld	h, b
	ld	de, #0x0006
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
	ld	h, a
	ld	a, 4 (ix)
	sub	a, e
	ld	a, 5 (ix)
	sbc	a, d
	ld	a, 6 (ix)
	sbc	a, l
	ld	a, 7 (ix)
	sbc	a, h
	jp	C, l_get_fat_00102$
l_get_fat_00101$:
	ld	l, #0x01
	ld	h, #0x00
	ld	e, #0x00
	ld	d, #0x00
	jp	l_get_fat_00108$
l_get_fat_00102$:
;pff.c:442: switch (fs->fs_type) {
	ld	a, (bc)
	sub	a, #0x03
	jp	NZ,l_get_fat_00125$
	jp	l_get_fat_00126$
l_get_fat_00125$:
	jp	l_get_fat_00107$
l_get_fat_00126$:
;pff.c:464: if (disk_readp(buf, fs->fatbase + clst / 128, ((UINT)clst % 128) * 4, 4)) break;
	ld	l, 4 (ix)
	ld	a, 5 (ix)
	res	7, l
	ld	h, #0x00
	add	hl, hl
	add	hl, hl
	ld	-10 (ix), l
	ld	-9 (ix), h
	ld	l, c
	ld	h, b
	ld	de, #0x000a
	add	hl, de
	ld	a, (hl)
	ld	-8 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-7 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-6 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-5 (ix), a
	ld	e, 4 (ix)
	ld	d, 5 (ix)
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	ld	b, #0x07
l_get_fat_00127$:
	srl	h
	rr	l
	rr	d
	rr	e
l_get_fat_00128$:
	djnz	l_get_fat_00127$
	ld	a, -8 (ix)
	add	a, e
	ld	-4 (ix), a
	ld	a, -7 (ix)
	adc	a, d
	ld	-3 (ix), a
	ld	a, -6 (ix)
	adc	a, l
	ld	-2 (ix), a
	ld	a, -5 (ix)
	adc	a, h
	ld	-1 (ix), a
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	c, e
	ld	b, d
	push	de
	ld	hl, #0x0004
	push	hl
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	push	bc
	call	_disk_readp
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ld	a, l
	pop	de
	or	a, a
	jp	NZ, l_get_fat_00107$
;pff.c:465: return ld_dword(buf) & 0x0FFFFFFF;
	push	de
	call	_ld_dword
	pop	af
	ld	a, d
	and	a, #0x0f
	ld	d, a
	jp	l_get_fat_00108$
;pff.c:467: }
l_get_fat_00107$:
;pff.c:469: return 1;	/* An error occured at the disk I/O layer */
	ld	l, #0x01
	ld	h, #0x00
	ld	e, #0x00
	ld	d, #0x00
l_get_fat_00108$:
;pff.c:470: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:479: static DWORD clust2sect (	/* !=0: Sector number, 0: Failed - invalid cluster# */
;	---------------------------------
; Function clust2sect
; ---------------------------------
_clust2sect:
	call	___sdcc_enter_ix
	push	af
	push	af
;pff.c:483: FATFS *fs = FatFs;
	ld	bc, (_FatFs)
;pff.c:486: clst -= 2;
	ld	a, 4 (ix)
	add	a, #0xfe
	ld	4 (ix), a
	ld	a, 5 (ix)
	adc	a, #0xff
	ld	5 (ix), a
	ld	a, 6 (ix)
	adc	a, #0xff
	ld	6 (ix), a
	ld	a, 7 (ix)
	adc	a, #0xff
	ld	7 (ix), a
;pff.c:487: if (clst >= (fs->n_fatent - 2)) return 0;		/* Invalid cluster# */
	ld	l, c
	ld	h, b
	ld	de, #0x0006
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
	ld	h, a
	ld	a, e
	add	a, #0xfe
	ld	e, a
	ld	a, d
	adc	a, #0xff
	ld	d, a
	ld	a, l
	adc	a, #0xff
	ld	l, a
	ld	a, h
	adc	a, #0xff
	ld	h, a
	ld	a, 4 (ix)
	sub	a, e
	ld	a, 5 (ix)
	sbc	a, d
	ld	a, 6 (ix)
	sbc	a, l
	ld	a, 7 (ix)
	sbc	a, h
	jp	C, l_clust2sect_00102$
	ld	l, #0x00
	ld	h, #0x00
	ld	e, #0x00
	ld	d, #0x00
	jp	l_clust2sect_00103$
l_clust2sect_00102$:
;pff.c:488: return (DWORD)clst * fs->csize + fs->database;
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	e, (hl)
	ld	d, #0x00
	ld	l, #0x00
	ld	h, #0x00
	push	bc
	push	hl
	push	de
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	pop	bc
	ld	l, c
	ld	h, b
	ld	de, #0x0012
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, -4 (ix)
	add	a, c
	ld	l, a
	ld	a, -3 (ix)
	adc	a, b
	ld	h, a
	ld	a, -2 (ix)
	adc	a, e
	ld	e, a
	ld	a, -1 (ix)
	adc	a, d
	ld	d, a
l_clust2sect_00103$:
;pff.c:489: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:492: static CLUST get_clust (
;	---------------------------------
; Function get_clust
; ---------------------------------
_get_clust:
	call	___sdcc_enter_ix
	push	af
	push	af
;pff.c:501: clst = ld_word(dir+DIR_FstClusHI);
	ld	a, 4 (ix)
	add	a, #0x14
	ld	c, a
	ld	a, 5 (ix)
	adc	a, #0x00
	ld	b, a
	push	bc
	call	_ld_word
	pop	af
	ld	c, #0x00
	ld	b, #0x00
;pff.c:502: clst <<= 16;
	ld	-2 (ix), l
	ld	-1 (ix), h
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
;pff.c:504: clst |= ld_word(dir+DIR_FstClusLO);
	ld	a, 4 (ix)
	add	a, #0x1a
	ld	c, a
	ld	a, 5 (ix)
	adc	a, #0x00
	ld	b, a
	push	bc
	call	_ld_word
	pop	af
	ld	c, #0x00
	ld	b, #0x00
	ld	a, -4 (ix)
	or	a, l
	ld	l, a
	ld	a, -3 (ix)
	or	a, h
	ld	h, a
	ld	a, -2 (ix)
	or	a, c
	ld	e, a
	ld	a, -1 (ix)
	or	a, b
	ld	d, a
;pff.c:506: return clst;
l_get_clust_00105$:
;pff.c:507: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:514: static FRESULT dir_rewind (
;	---------------------------------
; Function dir_rewind
; ---------------------------------
_dir_rewind:
	call	___sdcc_enter_ix
	push	af
	push	af
	push	af
	push	af
;pff.c:519: FATFS *fs = FatFs;
	ld	hl, (_FatFs)
	ex	(sp), hl
;pff.c:522: dj->index = 0;
	ld	a, 4 (ix)
	ld	-6 (ix), a
	ld	a, 5 (ix)
	ld	-5 (ix), a
	pop	bc
	pop	hl
	push	hl
	push	bc
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;pff.c:523: clst = dj->sclust;
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	de, #0x0004
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;pff.c:524: if (clst == 1 || clst >= fs->n_fatent) {	/* Check start cluster range */
	ld	a, c
	dec	a
	or	a, b
	or	a, e
	or	a, d
	jp	NZ,l_dir_rewind_00128$
	jp	l_dir_rewind_00101$
l_dir_rewind_00128$:
	pop	hl
	push	hl
	push	bc
	ld	bc, #0x0006
	add	hl, bc
	pop	bc
	ld	a, (hl)
	ld	-4 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-2 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-1 (ix), a
	ld	a, c
	sub	a, -4 (ix)
	ld	a, b
	sbc	a, -3 (ix)
	ld	a, e
	sbc	a, -2 (ix)
	ld	a, d
	sbc	a, -1 (ix)
	jp	C, l_dir_rewind_00106$
l_dir_rewind_00101$:
;pff.c:525: return FR_DISK_ERR;
	ld	l, #0x01
	jp	l_dir_rewind_00109$
;pff.c:527: if (PF_FS_FAT32 && !clst && (_FS_32ONLY || fs->fs_type == FS_FAT32)) {	/* Replace cluster# 0 with root cluster# if in FAT32 */
l_dir_rewind_00106$:
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jp	NZ, l_dir_rewind_00105$
;pff.c:528: clst = (CLUST)fs->dirbase;
	pop	hl
	push	hl
	ld	de, #0x000e
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
l_dir_rewind_00105$:
;pff.c:530: dj->clust = clst;						/* Current cluster */
	ld	a, -6 (ix)
	add	a, #0x08
	ld	l, a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	h, a
	ld	(hl), c
	inc	hl
	ld	(hl), b
	inc	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
;pff.c:531: dj->sect = (_FS_32ONLY || clst) ? clust2sect(clst) : fs->dirbase;	/* Current sector */
	ld	a, -6 (ix)
	add	a, #0x0c
	ld	l, a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	h, a
	push	hl
	push	de
	push	bc
	call	_clust2sect
	pop	af
	pop	af
	ld	c, l
	ld	b, h
	pop	hl
	ld	(hl), c
	inc	hl
	ld	(hl), b
	inc	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
;pff.c:533: return FR_OK;	/* Seek succeeded */
	ld	l, #0x00
l_dir_rewind_00109$:
;pff.c:534: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:543: static FRESULT dir_next (	/* FR_OK:Succeeded, FR_NO_FILE:End of table */
;	---------------------------------
; Function dir_next
; ---------------------------------
_dir_next:
	call	___sdcc_enter_ix
	ld	hl, #-14
	add	hl, sp
	ld	sp, hl
;pff.c:549: FATFS *fs = FatFs;
	ld	hl, (_FatFs)
	ex	(sp), hl
;pff.c:552: i = dj->index + 1;
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	l, c
	ld	h, b
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	de
	ld	-12 (ix), e
	ld	-11 (ix), d
;pff.c:553: if (!i || !dj->sect) return FR_NO_FILE;	/* Report EOT when index has reached 65535 */
	ld	a, -11 (ix)
	or	a, -12 (ix)
	jp	Z, l_dir_next_00101$
	ld	hl, #0x000c
	add	hl, bc
	ld	-10 (ix), l
	ld	-9 (ix), h
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
	ld	h, a
	ld	a, h
	or	a, l
	or	a, d
	or	a, e
	jp	NZ, l_dir_next_00102$
l_dir_next_00101$:
	ld	l, #0x03
	jp	l_dir_next_00117$
l_dir_next_00102$:
;pff.c:555: if (!(i % 16)) {		/* Sector changed? */
	ld	a, -12 (ix)
	ld	-8 (ix), a
	ld	a, -11 (ix)
	ld	-7 (ix), a
	ld	a, -8 (ix)
	and	a, #0x0f
	jp	NZ,l_dir_next_00154$
	jp	l_dir_next_00155$
l_dir_next_00154$:
	jp	l_dir_next_00116$
l_dir_next_00155$:
;pff.c:556: dj->sect++;			/* Next sector */
	ld	a, e
	add	a, #0x01
	ld	-4 (ix), a
	ld	a, d
	adc	a, #0x00
	ld	-3 (ix), a
	ld	a, l
	adc	a, #0x00
	ld	-2 (ix), a
	ld	a, h
	adc	a, #0x00
	ld	-1 (ix), a
	push	bc
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	hl, #0x000c
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:558: if (dj->clust == 0) {	/* Static table */
	ld	hl, #0x0008
	add	hl, bc
	ld	-6 (ix), l
	ld	-5 (ix), h
	push	bc
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	hl, #0x000c
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
	ld	a, -1 (ix)
	or	a, -2 (ix)
	or	a, -3 (ix)
	or	a, -4 (ix)
	jp	NZ, l_dir_next_00113$
;pff.c:559: if (i >= fs->n_rootdir) return FR_NO_FILE;	/* Report EOT when end of table */
	pop	hl
	push	hl
	ld	de, #0x0004
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, -12 (ix)
	sub	a, e
	ld	a, -11 (ix)
	sbc	a, d
	jp	C, l_dir_next_00116$
	ld	l, #0x03
	jp	l_dir_next_00117$
l_dir_next_00113$:
;pff.c:562: if (((i / 16) & (fs->csize - 1)) == 0) {	/* Cluster changed? */
	ld	e, -8 (ix)
	ld	d, -7 (ix)
	ld	a, #0x04
l_dir_next_00156$:
	srl	d
	rr	e
	dec	a
	jp	NZ, l_dir_next_00156$
	pop	hl
	push	hl
	inc	hl
	inc	hl
	ld	l, (hl)
	ld	h, #0x00
	dec	hl
	ld	a, l
	and	a, e
	ld	e, a
	ld	a, h
	and	a, d
	or	a, e
	jp	NZ, l_dir_next_00116$
;pff.c:563: clst = get_fat(dj->clust);		/* Get next cluster */
	push	bc
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	call	_get_fat
	pop	af
	pop	af
	pop	bc
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
;pff.c:564: if (clst <= 1) return FR_DISK_ERR;
	ld	a, #0x01
	cp	a, -4 (ix)
	ld	a, #0x00
	sbc	a, -3 (ix)
	ld	a, #0x00
	sbc	a, -2 (ix)
	ld	a, #0x00
	sbc	a, -1 (ix)
	jp	C, l_dir_next_00107$
	ld	l, #0x01
	jp	l_dir_next_00117$
l_dir_next_00107$:
;pff.c:565: if (clst >= fs->n_fatent) return FR_NO_FILE;	/* Report EOT when it reached end of dynamic table */
	pop	hl
	push	hl
	ld	de, #0x0006
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
	ld	h, a
	ld	a, -4 (ix)
	sub	a, e
	ld	a, -3 (ix)
	sbc	a, d
	ld	a, -2 (ix)
	sbc	a, l
	ld	a, -1 (ix)
	sbc	a, h
	jp	C, l_dir_next_00109$
	ld	l, #0x03
	jp	l_dir_next_00117$
l_dir_next_00109$:
;pff.c:566: dj->clust = clst;				/* Initialize data for new cluster */
	push	bc
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	hl, #0x000c
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:567: dj->sect = clust2sect(clst);
	push	bc
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	call	_clust2sect
	pop	af
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	pop	bc
	push	bc
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	hl, #0x000c
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
l_dir_next_00116$:
;pff.c:572: dj->index = i;
	ld	a, -12 (ix)
	ld	(bc), a
	inc	bc
	ld	a, -11 (ix)
	ld	(bc), a
;pff.c:574: return FR_OK;
	ld	l, #0x00
l_dir_next_00117$:
;pff.c:575: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:584: static FRESULT dir_find (
;	---------------------------------
; Function dir_find
; ---------------------------------
_dir_find:
	call	___sdcc_enter_ix
	ld	hl, #-9
	add	hl, sp
	ld	sp, hl
;pff.c:593: res = dir_rewind(dj);			/* Rewind directory object */
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_dir_rewind
	pop	af
;pff.c:594: if (res != FR_OK) return res;
	ld	a, l
	or	a, a
	jp	Z, l_dir_find_00122$
	jp	l_dir_find_00113$
;pff.c:596: do {
l_dir_find_00122$:
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	-5 (ix), c
	ld	-4 (ix), b
l_dir_find_00110$:
;pff.c:597: res = disk_readp(dir, dj->sect, (dj->index % 16) * 32, 32)	/* Read an entry */
	ld	l, c
	ld	h, b
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, e
	and	a, #0x0f
	ld	l, a
	ld	h, #0x00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	e, l
	ld	d, h
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	push	bc
	ld	bc, #0x000c
	add	hl, bc
	pop	bc
	ld	a, (hl)
	ld	-9 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-8 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-7 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-6 (ix), a
	push	bc
	ld	hl, #0x0020
	push	hl
	push	de
	ld	l, -7 (ix)
	ld	h, -6 (ix)
	push	hl
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	push	hl
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	call	_disk_readp
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ld	a, l
	pop	bc
	or	a, a
	jp	Z, l_dir_find_00115$
;pff.c:598: ? FR_DISK_ERR : FR_OK;
	ld	de, #0x0001
	jp	l_dir_find_00116$
l_dir_find_00115$:
	ld	de, #0x0000
l_dir_find_00116$:
	ld	-3 (ix), e
;pff.c:599: if (res != FR_OK) break;
	ld	a, -3 (ix)
	or	a, a
	jp	NZ, l_dir_find_00112$
;pff.c:600: c = dir[DIR_Name];	/* First character */
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	ld	a, (hl)
;pff.c:601: if (c == 0) { res = FR_NO_FILE; break; }	/* Reached to end of table */
	or	a, a
	jp	NZ, l_dir_find_00106$
	ld	-3 (ix), #0x03
	jp	l_dir_find_00112$
l_dir_find_00106$:
;pff.c:602: if (!(dir[DIR_Attr] & AM_VOL) && !mem_cmp(dir, dj->fn, 11)) break;	/* Is it a valid entry? */
	ld	de, #0x000b
	add	hl, de
	ld	a, (hl)
	bit	3, a
	jp	NZ,l_dir_find_00147$
	jp	l_dir_find_00148$
l_dir_find_00147$:
	jp	l_dir_find_00108$
l_dir_find_00148$:
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	e, 6 (ix)
	ld	d, 7 (ix)
	push	bc
	ld	hl, #0x000b
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	push	de
	call	_mem_cmp
	pop	af
	pop	af
	pop	af
	pop	bc
	ld	a, h
	or	a, l
	jp	Z, l_dir_find_00112$
l_dir_find_00108$:
;pff.c:603: res = dir_next(dj);					/* Next entry */
	push	bc
	push	bc
	call	_dir_next
	pop	af
	pop	bc
	ld	-3 (ix), l
;pff.c:604: } while (res == FR_OK);
	ld	a, -3 (ix)
	or	a, a
	jp	Z, l_dir_find_00110$
l_dir_find_00112$:
;pff.c:606: return res;
	ld	l, -3 (ix)
l_dir_find_00113$:
;pff.c:607: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:616: static FRESULT dir_read (
;	---------------------------------
; Function dir_read
; ---------------------------------
_dir_read:
	call	___sdcc_enter_ix
	push	af
	push	af
	push	af
;pff.c:625: res = FR_NO_FILE;
	ld	e, #0x03
;pff.c:626: while (dj->sect) {
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	hl, #0x000c
	add	hl, bc
	ex	(sp), hl
l_dir_read_00111$:
	push	de
	push	bc
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	hl, #0x0006
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
	pop	de
	ld	a, -1 (ix)
	or	a, -2 (ix)
	or	a, -3 (ix)
	or	a, -4 (ix)
	jp	Z, l_dir_read_00113$
;pff.c:627: res = disk_readp(dir, dj->sect, (dj->index % 16) * 32, 32)	/* Read an entry */
	ld	l, c
	ld	h, b
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, e
	and	a, #0x0f
	ld	l, a
	ld	h, #0x00
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	bc
	ld	de, #0x0020
	push	de
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	call	_disk_readp
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ld	a, l
	pop	bc
	or	a, a
	jp	Z, l_dir_read_00118$
;pff.c:628: ? FR_DISK_ERR : FR_OK;
	ld	de, #0x0001
	jp	l_dir_read_00119$
l_dir_read_00118$:
	ld	de, #0x0000
l_dir_read_00119$:
;pff.c:629: if (res != FR_OK) break;
	ld	a, e
	or	a, a
	jp	NZ, l_dir_read_00113$
;pff.c:630: c = dir[DIR_Name];
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	ld	a, (hl)
;pff.c:631: if (c == 0) { res = FR_NO_FILE; break; }	/* Reached to end of table */
	or	a, a
	jp	NZ, l_dir_read_00104$
	ld	e, #0x03
	jp	l_dir_read_00113$
l_dir_read_00104$:
;pff.c:632: a = dir[DIR_Attr] & AM_MASK;
	push	bc
	ld	bc, #0x000b
	add	hl, bc
	pop	bc
	ld	d, (hl)
	push	af
	ld	a, d
	and	a, #0x3f
	ld	d, a
	pop	af
;pff.c:633: if (c != 0xE5 && c != '.' && !(a & AM_VOL))	break;	/* Is it a valid entry? */
	cp	a, #0xe5
	jp	NZ,l_dir_read_00160$
	jp	l_dir_read_00106$
l_dir_read_00160$:
	sub	a, #0x2e
	jp	NZ,l_dir_read_00161$
	jp	l_dir_read_00106$
l_dir_read_00161$:
	bit	3, d
	jp	NZ,l_dir_read_00162$
	jp	l_dir_read_00113$
l_dir_read_00162$:
l_dir_read_00106$:
;pff.c:634: res = dir_next(dj);			/* Next entry */
	push	bc
	push	bc
	call	_dir_next
	pop	af
	ld	a, l
	pop	bc
	ld	e, a
;pff.c:635: if (res != FR_OK) break;
	ld	a, e
	or	a, a
	jp	Z, l_dir_read_00111$
l_dir_read_00113$:
;pff.c:638: if (res != FR_OK) dj->sect = 0;
	ld	a, e
	or	a, a
	jp	Z, l_dir_read_00115$
	pop	hl
	push	hl
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
l_dir_read_00115$:
;pff.c:640: return res;
	ld	l, e
l_dir_read_00116$:
;pff.c:641: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:651: static FRESULT create_name (
;	---------------------------------
; Function create_name
; ---------------------------------
_create_name:
	call	___sdcc_enter_ix
	push	af
	push	af
	push	af
	dec	sp
;pff.c:663: sfn = dj->fn;
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	inc	hl
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
;pff.c:664: mem_set(sfn, ' ', 11);
	ld	e, c
	ld	d, b
	push	bc
	ld	hl, #0x000b
	push	hl
	ld	l, #0x20
	push	hl
	push	de
	call	_mem_set
	pop	af
	pop	af
	pop	af
	pop	bc
;pff.c:665: si = i = 0; ni = 8;
	xor	a, a
	ld	-1 (ix), a
	ld	-7 (ix), #0x08
;pff.c:666: p = *path;
	ld	a, 6 (ix)
	ld	-6 (ix), a
	ld	a, 7 (ix)
	ld	-5 (ix), a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	a, (hl)
	ld	-4 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	ld	e, #0x00
l_create_name_00120$:
;pff.c:668: c = p[si++];
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	d, #0x00
	add	hl, de
	inc	e
	ld	d, (hl)
;pff.c:669: if (c <= ' ' || c == '/') break;	/* Break on end of segment */
	ld	a, #0x20
	sub	a, d
	ld	a, #0x00
	rla
	ld	-2 (ix), a
	bit	0, -2 (ix)
	jp	Z, l_create_name_00119$
	ld	a, d
	sub	a, #0x2f
	jp	NZ,l_create_name_00161$
	jp	l_create_name_00119$
l_create_name_00161$:
;pff.c:670: if (c == '.' || i >= ni) {
	ld	a, d
	sub	a, #0x2e
	jp	NZ,l_create_name_00162$
	ld	a,#0x01
	jp	l_create_name_00163$
l_create_name_00162$:
	xor	a,a
l_create_name_00163$:
	ld	l, a
	ld	a, l
	or	a, a
	jp	NZ, l_create_name_00107$
	ld	a, -1 (ix)
	sub	a, -7 (ix)
	jp	C, l_create_name_00111$
l_create_name_00107$:
;pff.c:671: if (ni != 8 || c != '.') break;
	ld	a, -7 (ix)
	sub	a, #0x08
	jp	NZ,l_create_name_00164$
	jp	l_create_name_00165$
l_create_name_00164$:
	jp	l_create_name_00119$
l_create_name_00165$:
	bit	0, l
	jp	Z, l_create_name_00119$
;pff.c:672: i = 8; ni = 11;
	ld	-1 (ix), #0x08
	ld	-7 (ix), #0x0b
;pff.c:673: continue;
	jp	l_create_name_00120$
;pff.c:683: if (PF_USE_LCC && IsLower(c)) c -= 0x20;	/* toupper */
l_create_name_00111$:
;pff.c:684: sfn[i++] = c;
	ld	l, -1 (ix)
	inc	-1 (ix)
	ld	h, #0x00
	add	hl, bc
	ld	(hl), d
	jp	l_create_name_00120$
l_create_name_00119$:
;pff.c:687: *path = &p[si];						/* Rerurn pointer to the next segment */
	ld	a, e
	add	a, -4 (ix)
	ld	e, a
	ld	a, #0x00
	adc	a, -3 (ix)
	ld	d, a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	(hl), e
	inc	hl
	ld	(hl), d
;pff.c:689: sfn[11] = (c <= ' ') ? 1 : 0;		/* Set last segment flag if end of path */
	ld	hl, #0x000b
	add	hl, bc
	bit	0, -2 (ix)
	jp	NZ, l_create_name_00123$
	ld	bc, #0x0001
	jp	l_create_name_00124$
l_create_name_00123$:
	ld	bc, #0x0000
l_create_name_00124$:
	ld	(hl), c
;pff.c:691: return FR_OK;
	ld	l, #0x00
l_create_name_00121$:
;pff.c:692: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:701: static void get_fileinfo (		/* No return code */
;	---------------------------------
; Function get_fileinfo
; ---------------------------------
_get_fileinfo:
	call	___sdcc_enter_ix
	push	af
	push	af
	push	af
;pff.c:711: p = fno->fname;
	ld	c, 8 (ix)
	ld	b, 9 (ix)
	ld	hl, #0x0009
	add	hl, bc
	ex	(sp), hl
;pff.c:712: if (dj->sect) {
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	de, #0x000c
	add	hl, de
	ld	a, (hl)
	ld	-4 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-2 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-1 (ix), a
	ld	a, -1 (ix)
	or	a, -2 (ix)
	or	a, -3 (ix)
	or	a, -4 (ix)
	jp	Z, l_get_fileinfo_00112$
;pff.c:713: for (i = 0; i < 8; i++) {	/* Copy file name body */
	pop	de
	push	de
	xor	a, a
	ld	-1 (ix), a
l_get_fileinfo_00113$:
;pff.c:714: c = dir[i];
	ld	a, 6 (ix)
	add	a, -1 (ix)
	ld	l, a
	ld	a, 7 (ix)
	adc	a, #0x00
	ld	h, a
	ld	a, (hl)
;pff.c:715: if (c == ' ') break;
	cp	a, #0x20
	jp	NZ,l_get_fileinfo_00156$
	jp	l_get_fileinfo_00126$
l_get_fileinfo_00156$:
;pff.c:716: if (c == 0x05) c = 0xE5;
	cp	a, #0x05
	jp	NZ,l_get_fileinfo_00157$
	jp	l_get_fileinfo_00158$
l_get_fileinfo_00157$:
	jp	l_get_fileinfo_00104$
l_get_fileinfo_00158$:
	ld	a, #0xe5
l_get_fileinfo_00104$:
;pff.c:717: *p++ = c;
	ld	(de), a
	inc	de
;pff.c:713: for (i = 0; i < 8; i++) {	/* Copy file name body */
	inc	-1 (ix)
	ld	a, -1 (ix)
	sub	a, #0x08
	jp	C, l_get_fileinfo_00113$
l_get_fileinfo_00126$:
	inc	sp
	inc	sp
	push	de
;pff.c:719: if (dir[8] != ' ') {		/* Copy file name extension */
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	bc
	ld	bc, #0x0008
	add	hl, bc
	pop	bc
	ld	a, (hl)
	sub	a, #0x20
	jp	NZ,l_get_fileinfo_00159$
	jp	l_get_fileinfo_00110$
l_get_fileinfo_00159$:
;pff.c:720: *p++ = '.';
	ld	a, #0x2e
	ld	(de), a
	inc	de
;pff.c:721: for (i = 8; i < 11; i++) {
	ld	-1 (ix), #0x08
l_get_fileinfo_00115$:
;pff.c:722: c = dir[i];
	ld	a, 6 (ix)
	add	a, -1 (ix)
	ld	l, a
	ld	a, 7 (ix)
	adc	a, #0x00
	ld	h, a
	ld	a, (hl)
;pff.c:723: if (c == ' ') break;
	cp	a, #0x20
	jp	NZ,l_get_fileinfo_00160$
	jp	l_get_fileinfo_00127$
l_get_fileinfo_00160$:
;pff.c:724: *p++ = c;
	ld	(de), a
	inc	de
;pff.c:721: for (i = 8; i < 11; i++) {
	inc	-1 (ix)
	ld	a, -1 (ix)
	sub	a, #0x0b
	jp	C, l_get_fileinfo_00115$
l_get_fileinfo_00127$:
	inc	sp
	inc	sp
	push	de
l_get_fileinfo_00110$:
;pff.c:727: fno->fattrib = dir[DIR_Attr];				/* Attribute */
	ld	hl, #0x0008
	add	hl, bc
	ex	de, hl
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	bc
	ld	bc, #0x000b
	add	hl, bc
	pop	bc
	ld	a, (hl)
	ld	(de), a
;pff.c:728: fno->fsize = ld_dword(dir+DIR_FileSize);	/* Size */
	ld	a, 6 (ix)
	add	a, #0x1c
	ld	e, a
	ld	a, 7 (ix)
	adc	a, #0x00
	ld	d, a
	push	bc
	push	de
	call	_ld_dword
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	pop	bc
	push	bc
	ld	e, c
	ld	d, b
	ld	hl, #0x0004
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:729: fno->fdate = ld_word(dir+DIR_WrtDate);		/* Date */
	ld	hl, #0x0004
	add	hl, bc
	ld	a, 6 (ix)
	add	a, #0x18
	ld	e, a
	ld	a, 7 (ix)
	adc	a, #0x00
	ld	d, a
	push	hl
	push	bc
	push	de
	call	_ld_word
	pop	af
	ld	e, l
	ld	d, h
	pop	bc
	pop	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
;pff.c:730: fno->ftime = ld_word(dir+DIR_WrtTime);		/* Time */
	ld	hl, #0x0006
	add	hl, bc
	ld	a, 6 (ix)
	add	a, #0x16
	ld	c, a
	ld	a, 7 (ix)
	adc	a, #0x00
	ld	b, a
	push	hl
	push	bc
	call	_ld_word
	pop	af
	ld	c, l
	ld	b, h
	pop	hl
	ld	(hl), c
	inc	hl
	ld	(hl), b
l_get_fileinfo_00112$:
;pff.c:732: *p = 0;
	pop	hl
	push	hl
	ld	(hl), #0x00
l_get_fileinfo_00117$:
;pff.c:733: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:742: static FRESULT follow_path (	/* FR_OK(0): successful, !=0: error code */
;	---------------------------------
; Function follow_path
; ---------------------------------
_follow_path:
	call	___sdcc_enter_ix
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;pff.c:751: while (*path == ' ') path++;		/* Strip leading spaces */
	ld	l, 8 (ix)
	ld	h, 9 (ix)
l_follow_path_00101$:
	ld	a, (hl)
	ld	e, l
	ld	d, h
	inc	de
	cp	a, #0x20
	jp	NZ,l_follow_path_00168$
	jp	l_follow_path_00169$
l_follow_path_00168$:
	jp	l_follow_path_00131$
l_follow_path_00169$:
	ld	l, e
	ld	h, d
	ld	8 (ix), e
	ld	9 (ix), d
	jp	l_follow_path_00101$
l_follow_path_00131$:
	ld	8 (ix), l
	ld	9 (ix), h
;pff.c:752: if (*path == '/') path++;			/* Strip heading separator if exist */
	sub	a, #0x2f
	jp	NZ,l_follow_path_00170$
	jp	l_follow_path_00171$
l_follow_path_00170$:
	jp	l_follow_path_00105$
l_follow_path_00171$:
	ld	8 (ix), e
	ld	9 (ix), d
l_follow_path_00105$:
;pff.c:753: dj->sclust = 0;						/* Set start directory (always root dir) */
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	hl, #0x0004
	add	hl, bc
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
;pff.c:755: if ((BYTE)*path < ' ') {			/* Null path means the root directory */
	ld	e, 8 (ix)
	ld	d, 9 (ix)
	ld	a, (de)
	sub	a, #0x20
	jp	NC, l_follow_path_00130$
;pff.c:756: res = dir_rewind(dj);
	push	bc
	call	_dir_rewind
	pop	af
	ld	a, l
	ld	e, a
;pff.c:757: dir[0] = 0;
	ld	c, 6 (ix)
	ld	b, 7 (ix)
	xor	a, a
	ld	(bc), a
	jp	l_follow_path_00117$
l_follow_path_00130$:
	inc	sp
	inc	sp
	push	bc
	ld	a, 6 (ix)
	ld	-8 (ix), a
	ld	a, 7 (ix)
	ld	-7 (ix), a
	ld	-6 (ix), c
	ld	-5 (ix), b
l_follow_path_00118$:
;pff.c:761: res = create_name(dj, &path);	/* Get a segment */
	ld	hl, #18
	add	hl, sp
	push	bc
	push	hl
	push	bc
	call	_create_name
	pop	af
	pop	af
	ld	a, l
	pop	bc
	ld	e, a
;pff.c:762: if (res != FR_OK) break;
	ld	a, e
	or	a, a
	jp	NZ, l_follow_path_00117$
;pff.c:763: res = dir_find(dj, dir);		/* Find it */
	push	bc
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	push	bc
	call	_dir_find
	pop	af
	pop	af
	ld	a, l
	pop	bc
	ld	e, a
;pff.c:764: if (res != FR_OK) break;		/* Could not find the object */
	ld	a, e
	or	a, a
	jp	NZ, l_follow_path_00117$
;pff.c:765: if (dj->fn[11]) break;			/* Last segment match. Function completed. */
	pop	hl
	push	hl
	inc	hl
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, d
	push	bc
	ld	bc, #0x000b
	add	hl, bc
	pop	bc
	ld	a, (hl)
	or	a, a
	jp	NZ, l_follow_path_00117$
;pff.c:766: if (!(dir[DIR_Attr] & AM_DIR)) { /* Cannot follow path because it is a file */
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	de, #0x000b
	add	hl, de
	ld	a, (hl)
	bit	4, a
	jp	NZ,l_follow_path_00172$
	jp	l_follow_path_00173$
l_follow_path_00172$:
	jp	l_follow_path_00113$
l_follow_path_00173$:
;pff.c:767: res = FR_NO_FILE; break;
	ld	e, #0x03
	jp	l_follow_path_00117$
l_follow_path_00113$:
;pff.c:769: dj->sclust = get_clust(dir);	/* Follow next */
	ld	a, -6 (ix)
	add	a, #0x04
	ld	e, a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	d, a
	push	bc
	push	de
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	call	_get_clust
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	pop	de
	pop	bc
	push	bc
	ld	hl, #0x0008
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
	jp	l_follow_path_00118$
l_follow_path_00117$:
;pff.c:773: return res;
	ld	l, e
l_follow_path_00120$:
;pff.c:774: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:783: static BYTE check_fs (	/* 0:The FAT boot record, 1:Valid boot record but not an FAT, 2:Not a boot record, 3:Error */
;	---------------------------------
; Function check_fs
; ---------------------------------
_check_fs:
	call	___sdcc_enter_ix
;pff.c:788: if (disk_readp(buf, sect, 510, 2)) {	/* Read the boot record */
	ld	hl, #0x0002
	push	hl
	ld	hl, #0x01fe
	push	hl
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_disk_readp
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ld	a, l
	or	a, a
	jp	Z, l_check_fs_00102$
;pff.c:789: return 3;
	ld	l, #0x03
	jp	l_check_fs_00113$
l_check_fs_00102$:
;pff.c:791: if (ld_word(buf) != 0xAA55) {			/* Check record signature */
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_ld_word
	pop	af
	ld	a, l
	sub	a, #0x55
	jp	NZ,l_check_fs_00135$
	ld	a, h
	sub	a, #0xaa
	jp	NZ,l_check_fs_00135$
	jp	l_check_fs_00111$
l_check_fs_00135$:
;pff.c:792: return 2;
	ld	l, #0x02
	jp	l_check_fs_00113$
;pff.c:798: if (PF_FS_FAT32 && !disk_readp(buf, sect, BS_FilSysType32, 2) && ld_word(buf) == 0x4146) {	/* Check FAT32 */
l_check_fs_00111$:
	ld	hl, #0x0002
	push	hl
	ld	l, #0x52
	push	hl
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_disk_readp
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ld	a, l
	or	a, a
	jp	NZ, l_check_fs_00110$
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_ld_word
	pop	af
	ld	a, l
	sub	a, #0x46
	jp	NZ,l_check_fs_00136$
	ld	a, h
	sub	a, #0x41
	jp	NZ,l_check_fs_00136$
	jp	l_check_fs_00137$
l_check_fs_00136$:
	jp	l_check_fs_00110$
l_check_fs_00137$:
;pff.c:799: return 0;
	ld	l, #0x00
	jp	l_check_fs_00113$
l_check_fs_00110$:
;pff.c:801: return 1;
	ld	l, #0x01
l_check_fs_00113$:
;pff.c:802: }
	pop	ix
	ret
;pff.c:819: FRESULT pf_mount (
;	---------------------------------
; Function pf_mount
; ---------------------------------
_pf_mount::
	call	___sdcc_enter_ix
	ld	hl, #-60
	add	hl, sp
	ld	sp, hl
;pff.c:827: FatFs = 0;
	ld	hl, #0x0000
	ld	(_FatFs), hl
;pff.c:828: if (disk_initialize() & STA_NOINIT) {	/* Check if the drive is ready or not */
	call	_disk_initialize
	ld	a, l
	rrca
	jp	C,l_pf_mount_00194$
	jp	l_pf_mount_00102$
l_pf_mount_00194$:
;pff.c:829: return FR_NOT_READY;
	ld	l, #0x02
	jp	l_pf_mount_00137$
l_pf_mount_00102$:
;pff.c:833: bsect = 0;
	xor	a, a
	ld	-60 (ix), a
	ld	-59 (ix), a
	ld	-58 (ix), a
	ld	-57 (ix), a
;pff.c:834: fmt = check_fs(buf, bsect);			/* Check sector 0 as an SFD format */
	ld	hl, #4
	add	hl, sp
	ld	-20 (ix), l
	ld	-19 (ix), h
	ld	c, -20 (ix)
	ld	b, -19 (ix)
	ld	hl, #0x0000
	push	hl
	ld	hl, #0x0000
	push	hl
	push	bc
	call	_check_fs
	pop	af
	pop	af
	pop	af
	ld	-5 (ix), l
;pff.c:840: if (buf[4]) {					/* Is the partition existing? */
	ld	a, -20 (ix)
	add	a, #0x04
	ld	-2 (ix), a
	ld	a, -19 (ix)
	adc	a, #0x00
	ld	-1 (ix), a
;pff.c:835: if (fmt == 1) {						/* Not an FAT boot record, it may be FDISK format */
	ld	a, -5 (ix)
	dec	a
	jp	NZ,l_pf_mount_00195$
	jp	l_pf_mount_00196$
l_pf_mount_00195$:
	jp	l_pf_mount_00109$
l_pf_mount_00196$:
;pff.c:837: if (disk_readp(buf, bsect, MBR_Table, 16)) {	/* 1st partition entry */
	ld	a, -20 (ix)
	ld	-4 (ix), a
	ld	a, -19 (ix)
	ld	-3 (ix), a
	ld	hl, #0x0010
	push	hl
	ld	hl, #0x01be
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	call	_disk_readp
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ld	a, l
	or	a, a
	jp	Z, l_pf_mount_00106$
;pff.c:838: fmt = 3;
	ld	-5 (ix), #0x03
	jp	l_pf_mount_00109$
l_pf_mount_00106$:
;pff.c:840: if (buf[4]) {					/* Is the partition existing? */
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	a, (hl)
	or	a, a
	jp	Z, l_pf_mount_00109$
;pff.c:841: bsect = ld_dword(&buf[8]);	/* Partition offset in LBA */
	ld	a, -20 (ix)
	add	a, #0x08
	ld	c, a
	ld	a, -19 (ix)
	adc	a, #0x00
	ld	b, a
	push	bc
	call	_ld_dword
	pop	af
	ld	-60 (ix), l
	ld	-59 (ix), h
	ld	-58 (ix), e
	ld	-57 (ix), d
;pff.c:842: fmt = check_fs(buf, bsect);	/* Check the partition */
	ld	c, -20 (ix)
	ld	b, -19 (ix)
	ld	l, -58 (ix)
	ld	h, -57 (ix)
	push	hl
	ld	l, -60 (ix)
	ld	h, -59 (ix)
	push	hl
	push	bc
	call	_check_fs
	pop	af
	pop	af
	pop	af
	ld	-5 (ix), l
l_pf_mount_00109$:
;pff.c:846: if (fmt == 3) return FR_DISK_ERR;
	ld	a, -5 (ix)
	sub	a, #0x03
	jp	NZ,l_pf_mount_00197$
	jp	l_pf_mount_00198$
l_pf_mount_00197$:
	jp	l_pf_mount_00111$
l_pf_mount_00198$:
	ld	l, #0x01
	jp	l_pf_mount_00137$
l_pf_mount_00111$:
;pff.c:847: if (fmt) return FR_NO_FILESYSTEM;	/* No valid FAT patition is found */
	ld	a, -5 (ix)
	or	a, a
	jp	Z, l_pf_mount_00113$
	ld	l, #0x06
	jp	l_pf_mount_00137$
l_pf_mount_00113$:
;pff.c:850: if (disk_readp(buf, bsect, 13, sizeof (buf))) return FR_DISK_ERR;
	ld	c, -20 (ix)
	ld	b, -19 (ix)
	ld	hl, #0x0024
	push	hl
	ld	l, #0x0d
	push	hl
	ld	l, -58 (ix)
	ld	h, -57 (ix)
	push	hl
	ld	l, -60 (ix)
	ld	h, -59 (ix)
	push	hl
	push	bc
	call	_disk_readp
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ld	a, l
	or	a, a
	jp	Z, l_pf_mount_00115$
	ld	l, #0x01
	jp	l_pf_mount_00137$
l_pf_mount_00115$:
;pff.c:852: fsize = ld_word(buf+BPB_FATSz16-13);				/* Number of sectors per FAT */
	ld	a, -20 (ix)
	add	a, #0x09
	ld	c, a
	ld	a, -19 (ix)
	adc	a, #0x00
	ld	b, a
	push	bc
	call	_ld_word
	pop	af
	ld	c, l
	ld	b, h
	ld	e, #0x00
	ld	d, #0x00
;pff.c:853: if (!fsize) fsize = ld_dword(buf+BPB_FATSz32-13);
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jp	NZ, l_pf_mount_00117$
	ld	a, -20 (ix)
	add	a, #0x17
	ld	c, a
	ld	a, -19 (ix)
	adc	a, #0x00
	ld	b, a
	push	bc
	call	_ld_dword
	pop	af
	ld	c, l
	ld	b, h
l_pf_mount_00117$:
;pff.c:855: fsize *= buf[BPB_NumFATs-13];						/* Number of sectors in FAT area */
	ld	l, -20 (ix)
	ld	h, -19 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	a, (hl)
	ld	-6 (ix), a
	xor	a, a
	ld	-5 (ix), a
	ld	-4 (ix), a
	ld	-3 (ix), a
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	push	de
	push	bc
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-18 (ix), l
	ld	-17 (ix), h
	ld	-16 (ix), e
	ld	-15 (ix), d
;pff.c:856: fs->fatbase = bsect + ld_word(buf+BPB_RsvdSecCnt-13); /* FAT start sector (lba) */
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	hl, #0x000a
	add	hl, bc
	ld	-14 (ix), l
	ld	-13 (ix), h
	ld	a, -20 (ix)
	add	a, #0x01
	ld	-6 (ix), a
	ld	a, -19 (ix)
	adc	a, #0x00
	ld	-5 (ix), a
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	push	bc
	push	de
	call	_ld_word
	pop	af
	pop	bc
	ld	e, #0x00
	ld	d, #0x00
	ld	a, -60 (ix)
	add	a, l
	ld	-10 (ix), a
	ld	a, -59 (ix)
	adc	a, h
	ld	-9 (ix), a
	ld	a, -58 (ix)
	adc	a, e
	ld	-8 (ix), a
	ld	a, -57 (ix)
	adc	a, d
	ld	-7 (ix), a
	push	bc
	ld	e, -14 (ix)
	ld	d, -13 (ix)
	ld	hl, #0x0034
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:857: fs->csize = buf[BPB_SecPerClus-13];					/* Number of sectors per cluster */
	ld	hl, #0x0002
	add	hl, bc
	ld	-12 (ix), l
	ld	-11 (ix), h
	ld	l, -20 (ix)
	ld	h, -19 (ix)
	ld	a, (hl)
	ld	l, -12 (ix)
	ld	h, -11 (ix)
	ld	(hl), a
;pff.c:858: fs->n_rootdir = ld_word(buf+BPB_RootEntCnt-13);		/* Nmuber of root directory entries */
	ld	hl, #0x0004
	add	hl, bc
	ld	-10 (ix), l
	ld	-9 (ix), h
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	push	bc
	push	de
	call	_ld_word
	pop	af
	ld	e, l
	ld	d, h
	pop	bc
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	(hl), e
	inc	hl
	ld	(hl), d
;pff.c:859: tsect = ld_word(buf+BPB_TotSec16-13);				/* Number of sectors on the file system */
	ld	a, -20 (ix)
	add	a, #0x06
	ld	e, a
	ld	a, -19 (ix)
	adc	a, #0x00
	ld	d, a
	push	bc
	push	de
	call	_ld_word
	pop	af
	pop	bc
	ld	e, #0x00
	ld	d, #0x00
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
;pff.c:860: if (!tsect) tsect = ld_dword(buf+BPB_TotSec32-13);
	ld	a, d
	or	a, e
	or	a, h
	or	a, l
	jp	NZ, l_pf_mount_00119$
	ld	a, -20 (ix)
	add	a, #0x13
	ld	e, a
	ld	a, -19 (ix)
	adc	a, #0x00
	ld	d, a
	push	bc
	push	de
	call	_ld_dword
	pop	af
	pop	bc
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
l_pf_mount_00119$:
;pff.c:862: - ld_word(buf+BPB_RsvdSecCnt-13) - fsize - fs->n_rootdir / 16
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	push	bc
	push	de
	call	_ld_word
	pop	af
	pop	bc
	ld	e, #0x00
	ld	d, #0x00
	ld	a, -4 (ix)
	sub	a, l
	ld	l, a
	ld	a, -3 (ix)
	sbc	a, h
	ld	h, a
	ld	a, -2 (ix)
	sbc	a, e
	ld	e, a
	ld	a, -1 (ix)
	sbc	a, d
	ld	d, a
	ld	a, l
	sub	a, -18 (ix)
	ld	-8 (ix), a
	ld	a, h
	sbc	a, -17 (ix)
	ld	-7 (ix), a
	ld	a, e
	sbc	a, -16 (ix)
	ld	-6 (ix), a
	ld	a, d
	sbc	a, -15 (ix)
	ld	-5 (ix), a
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, #0x04
l_pf_mount_00199$:
	srl	d
	rr	e
	dec	a
	jp	NZ, l_pf_mount_00199$
	ld	l, #0x00
	ld	h, #0x00
	ld	a, -8 (ix)
	sub	a, e
	ld	-4 (ix), a
	ld	a, -7 (ix)
	sbc	a, d
	ld	-3 (ix), a
	ld	a, -6 (ix)
	sbc	a, l
	ld	-2 (ix), a
	ld	a, -5 (ix)
	sbc	a, h
	ld	-1 (ix), a
;pff.c:863: ) / fs->csize + 2;
	ld	l, -12 (ix)
	ld	h, -11 (ix)
	ld	e, (hl)
	ld	d, #0x00
	ld	l, #0x00
	ld	h, #0x00
	push	bc
	push	hl
	push	de
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	call	__divulong
	pop	af
	pop	af
	pop	af
	pop	af
	pop	bc
	ld	a, l
	add	a, #0x02
	ld	-4 (ix), a
	ld	a, h
	adc	a, #0x00
	ld	-3 (ix), a
	ld	a, e
	adc	a, #0x00
	ld	-2 (ix), a
	ld	a, d
	adc	a, #0x00
	ld	-1 (ix), a
;pff.c:864: fs->n_fatent = (CLUST)mclst;
	ld	hl, #0x0006
	add	hl, bc
	ex	de, hl
	push	bc
	ld	hl, #0x003a
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:866: fmt = 0;							/* Determine the FAT sub type */
	ld	e, #0x00
;pff.c:869: if (PF_FS_FAT32 && mclst >= 0xFFF7) fmt = FS_FAT32;
	ld	a, -4 (ix)
	sub	a, #0xf7
	ld	a, -3 (ix)
	sbc	a, #0xff
	ld	a, -2 (ix)
	sbc	a, #0x00
	ld	a, -1 (ix)
	sbc	a, #0x00
	jp	C, l_pf_mount_00128$
	ld	e, #0x03
l_pf_mount_00128$:
;pff.c:870: if (!fmt) return FR_NO_FILESYSTEM;
	ld	a, e
	or	a, a
	jp	NZ, l_pf_mount_00131$
	ld	l, #0x06
	jp	l_pf_mount_00137$
l_pf_mount_00131$:
;pff.c:871: fs->fs_type = fmt;
	ld	a, e
	ld	(bc), a
;pff.c:874: fs->dirbase = ld_dword(buf+(BPB_RootClus-13));	/* Root directory start cluster */
	ld	hl, #0x000e
	add	hl, bc
	ex	de, hl
	ld	a, -20 (ix)
	add	a, #0x1f
	ld	l, a
	ld	a, -19 (ix)
	adc	a, #0x00
	ld	h, a
	push	bc
	push	de
	push	hl
	call	_ld_dword
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	pop	de
	pop	bc
	push	bc
	ld	hl, #0x003a
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:878: fs->database = fs->fatbase + fsize + fs->n_rootdir / 16;	/* Data start sector (lba) */
	ld	hl, #0x0012
	add	hl, bc
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	l, -14 (ix)
	ld	h, -13 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
	ld	h, a
	ld	a, e
	add	a, -18 (ix)
	ld	-6 (ix), a
	ld	a, d
	adc	a, -17 (ix)
	ld	-5 (ix), a
	ld	a, l
	adc	a, -16 (ix)
	ld	-4 (ix), a
	ld	a, h
	adc	a, -15 (ix)
	ld	-3 (ix), a
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, #0x04
l_pf_mount_00200$:
	srl	d
	rr	e
	dec	a
	jp	NZ, l_pf_mount_00200$
	ld	l, #0x00
	ld	h, #0x00
	ld	a, e
	add	a, -6 (ix)
	ld	-10 (ix), a
	ld	a, d
	adc	a, -5 (ix)
	ld	-9 (ix), a
	ld	a, l
	adc	a, -4 (ix)
	ld	-8 (ix), a
	ld	a, h
	adc	a, -3 (ix)
	ld	-7 (ix), a
	push	bc
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	hl, #0x0034
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:880: fs->flag = 0;
	ld	e, c
	ld	d, b
	inc	de
	xor	a, a
	ld	(de), a
;pff.c:881: FatFs = fs;
	ld	(_FatFs), bc
;pff.c:883: return FR_OK;
	ld	l, #0x00
l_pf_mount_00137$:
;pff.c:884: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:893: FRESULT pf_open (
;	---------------------------------
; Function pf_open
; ---------------------------------
_pf_open::
	call	___sdcc_enter_ix
	ld	hl, #-68
	add	hl, sp
	ld	sp, hl
;pff.c:900: FATFS *fs = FatFs;
	ld	bc, (_FatFs)
;pff.c:903: if (!fs) return FR_NOT_ENABLED;		/* Check file system */
	ld	a, b
	or	a, c
	jp	NZ, l_pf_open_00102$
	ld	l, #0x05
	jp	l_pf_open_00108$
l_pf_open_00102$:
;pff.c:905: fs->flag = 0;
	ld	hl, #0x0001
	add	hl, bc
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	(hl), #0x00
;pff.c:906: dj.fn = sp;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, #0x0002
	add	hl, de
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	hl, #16
	add	hl, sp
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	a, -2 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -1 (ix)
	ld	(hl), a
;pff.c:907: res = follow_path(&dj, dir, path);	/* Follow the file path */
	ld	hl, #28
	add	hl, sp
	ld	-6 (ix), l
	ld	-5 (ix), h
	ld	a, -6 (ix)
	ld	-2 (ix), a
	ld	a, -5 (ix)
	ld	-1 (ix), a
	push	bc
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	push	de
	call	_follow_path
	pop	af
	pop	af
	pop	af
	ld	a, l
	pop	bc
	ld	l, a
;pff.c:908: if (res != FR_OK) return res;		/* Follow failed */
	or	a, a
	jp	Z, l_pf_open_00104$
	jp	l_pf_open_00108$
l_pf_open_00104$:
;pff.c:909: if (!dir[0] || (dir[DIR_Attr] & AM_DIR)) return FR_NO_FILE;	/* It is a directory */
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	a, (hl)
	or	a, a
	jp	Z, l_pf_open_00105$
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	de, #0x000b
	add	hl, de
	ld	a, (hl)
	bit	4, a
	jp	NZ,l_pf_open_00125$
	jp	l_pf_open_00106$
l_pf_open_00125$:
l_pf_open_00105$:
	ld	l, #0x03
	jp	l_pf_open_00108$
l_pf_open_00106$:
;pff.c:911: fs->org_clust = get_clust(dir);		/* File start cluster */
	ld	hl, #0x001e
	add	hl, bc
	ex	de, hl
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	bc
	push	de
	push	hl
	call	_get_clust
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	pop	de
	pop	bc
	push	bc
	ld	hl, #0x0042
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:912: fs->fsize = ld_dword(dir+DIR_FileSize);	/* File size */
	ld	hl, #0x001a
	add	hl, bc
	ex	de, hl
	ld	a, -6 (ix)
	add	a, #0x1c
	ld	l, a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	h, a
	push	bc
	push	de
	push	hl
	call	_ld_dword
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	pop	de
	pop	bc
	push	bc
	ld	hl, #0x0042
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:913: fs->fptr = 0;						/* File pointer */
	ld	hl, #0x0016
	add	hl, bc
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
;pff.c:914: fs->flag = FA_OPENED;
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	(hl), #0x01
;pff.c:916: return FR_OK;
	ld	l, #0x00
l_pf_open_00108$:
;pff.c:917: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:927: FRESULT pf_read (
;	---------------------------------
; Function pf_read
; ---------------------------------
_pf_read::
	call	___sdcc_enter_ix
	ld	hl, #-34
	add	hl, sp
	ld	sp, hl
;pff.c:937: BYTE cs, *rbuff = buff;
	ld	a, 4 (ix)
	ld	-2 (ix), a
	ld	a, 5 (ix)
	ld	-1 (ix), a
;pff.c:938: FATFS *fs = FatFs;
	ld	hl, (_FatFs)
	ld	-4 (ix), l
	ld	-3 (ix), h
;pff.c:941: *br = 0;
	ld	a, 8 (ix)
	ld	-30 (ix), a
	ld	a, 9 (ix)
	ld	-29 (ix), a
	ld	l, -30 (ix)
	ld	h, -29 (ix)
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;pff.c:942: if (!fs) return FR_NOT_ENABLED;		/* Check file system */
	ld	a, -3 (ix)
	or	a, -4 (ix)
	jp	NZ, l_pf_read_00102$
	ld	l, #0x05
	jp	l_pf_read_00127$
l_pf_read_00102$:
;pff.c:943: if (!(fs->flag & FA_OPENED)) return FR_NOT_OPENED;	/* Check if opened */
	ld	a, -4 (ix)
	add	a, #0x01
	ld	-28 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-27 (ix), a
	ld	l, -28 (ix)
	ld	h, -27 (ix)
	ld	a, (hl)
	rrca
	jp	C,l_pf_read_00194$
	jp	l_pf_read_00195$
l_pf_read_00194$:
	jp	l_pf_read_00104$
l_pf_read_00195$:
	ld	l, #0x04
	jp	l_pf_read_00127$
l_pf_read_00104$:
;pff.c:945: remain = fs->fsize - fs->fptr;
	ld	a, -4 (ix)
	ld	-6 (ix), a
	ld	a, -3 (ix)
	ld	-5 (ix), a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	de, #0x001a
	add	hl, de
	ld	a, (hl)
	ld	-16 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-15 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-14 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-13 (ix), a
	ld	a, -4 (ix)
	add	a, #0x16
	ld	-26 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-25 (ix), a
	ld	e, -26 (ix)
	ld	d, -25 (ix)
	ld	hl, #0x0016
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	a, -16 (ix)
	sub	a, -12 (ix)
	ld	-8 (ix), a
	ld	a, -15 (ix)
	sbc	a, -11 (ix)
	ld	-7 (ix), a
	ld	a, -14 (ix)
	sbc	a, -10 (ix)
	ld	-6 (ix), a
	ld	a, -13 (ix)
	sbc	a, -9 (ix)
	ld	-5 (ix), a
;pff.c:946: if (btr > remain) btr = (UINT)remain;			/* Truncate btr by remaining bytes */
	ld	a, 6 (ix)
	ld	-12 (ix), a
	ld	a, 7 (ix)
	ld	-11 (ix), a
	xor	a, a
	ld	-10 (ix), a
	ld	-9 (ix), a
	ld	a, -8 (ix)
	sub	a, -12 (ix)
	ld	a, -7 (ix)
	sbc	a, -11 (ix)
	ld	a, -6 (ix)
	sbc	a, -10 (ix)
	ld	a, -5 (ix)
	sbc	a, -9 (ix)
	jp	NC, l_pf_read_00140$
	ld	a, -8 (ix)
	ld	6 (ix), a
	ld	a, -7 (ix)
	ld	7 (ix), a
;pff.c:948: while (btr)	{									/* Repeat until all data transferred */
l_pf_read_00140$:
	ld	a, -4 (ix)
	add	a, #0x22
	ld	-24 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-23 (ix), a
	ld	a, -4 (ix)
	ld	-22 (ix), a
	ld	a, -3 (ix)
	ld	-21 (ix), a
	ld	a, -4 (ix)
	ld	-20 (ix), a
	ld	a, -3 (ix)
	ld	-19 (ix), a
	ld	a, -4 (ix)
	add	a, #0x26
	ld	-18 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-17 (ix), a
l_pf_read_00124$:
	ld	a, 7 (ix)
	or	a, 6 (ix)
	jp	Z, l_pf_read_00126$
;pff.c:949: if ((fs->fptr % 512) == 0) {				/* On the sector boundary? */
	ld	e, -26 (ix)
	ld	d, -25 (ix)
	ld	hl, #0x0019
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	a, -9 (ix)
	or	a, a
	jp	NZ,l_pf_read_00196$
	bit	0, -8 (ix)
	jp	NZ,l_pf_read_00196$
	jp	l_pf_read_00197$
l_pf_read_00196$:
	jp	l_pf_read_00117$
l_pf_read_00197$:
;pff.c:950: cs = (BYTE)(fs->fptr / 512 & (fs->csize - 1));	/* Sector offset in the cluster */
	ld	a, -8 (ix)
	ld	-13 (ix), a
	ld	a, -7 (ix)
	ld	-12 (ix), a
	ld	a, -6 (ix)
	ld	-11 (ix), a
	xor	a, a
	ld	-10 (ix), a
	srl	-11 (ix)
	rr	-12 (ix)
	rr	-13 (ix)
	ld	l, -20 (ix)
	ld	h, -19 (ix)
	inc	hl
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	dec	-3 (ix)
	ld	a, -3 (ix)
	ld	-5 (ix), a
	ld	a, -13 (ix)
	ld	-3 (ix), a
	ld	a, -3 (ix)
	and	a, -5 (ix)
	ld	-3 (ix), a
	ld	a, -3 (ix)
	ld	-4 (ix), a
;pff.c:951: if (!cs) {								/* On the cluster boundary? */
	ld	a, -3 (ix)
	or	a, a
	jp	NZ, l_pf_read_00113$
;pff.c:952: if (fs->fptr == 0) {				/* On the top of the file? */
	ld	a, -6 (ix)
	or	a, -7 (ix)
	or	a, -8 (ix)
	or	a, -9 (ix)
	jp	NZ, l_pf_read_00108$
;pff.c:953: clst = fs->org_clust;
	ld	l, -22 (ix)
	ld	h, -21 (ix)
	ld	de, #0x001e
	add	hl, de
	ld	a, (hl)
	ld	-8 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-7 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-6 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-5 (ix), a
	jp	l_pf_read_00109$
l_pf_read_00108$:
;pff.c:955: clst = get_fat(fs->curr_clust);
	ld	l, -24 (ix)
	ld	h, -23 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	push	bc
	call	_get_fat
	pop	af
	pop	af
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	-6 (ix), e
	ld	-5 (ix), d
l_pf_read_00109$:
;pff.c:957: if (clst <= 1) ABORT(FR_DISK_ERR);
	ld	a, #0x01
	cp	a, -8 (ix)
	ld	a, #0x00
	sbc	a, -7 (ix)
	ld	a, #0x00
	sbc	a, -6 (ix)
	ld	a, #0x00
	sbc	a, -5 (ix)
	jp	C, l_pf_read_00111$
	ld	l, -28 (ix)
	ld	h, -27 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_read_00127$
l_pf_read_00111$:
;pff.c:958: fs->curr_clust = clst;				/* Update current cluster */
	ld	e, -24 (ix)
	ld	d, -23 (ix)
	ld	hl, #0x001a
	add	hl, sp
	ld	bc, #0x0004
	ldir
l_pf_read_00113$:
;pff.c:960: sect = clust2sect(fs->curr_clust);		/* Get current sector */
	ld	e, -24 (ix)
	ld	d, -23 (ix)
	ld	hl, #0x001a
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	call	_clust2sect
	pop	af
	pop	af
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	hl, #21
	add	hl, sp
	ex	de, hl
	ld	hl, #26
	add	hl, sp
	ld	bc, #4
	ldir
;pff.c:961: if (!sect) ABORT(FR_DISK_ERR);
	ld	a, -5 (ix)
	or	a, -6 (ix)
	or	a, -7 (ix)
	or	a, -8 (ix)
	jp	NZ, l_pf_read_00115$
	ld	l, -28 (ix)
	ld	h, -27 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_read_00127$
l_pf_read_00115$:
;pff.c:962: fs->dsect = sect + cs;
	ld	a, -4 (ix)
	ld	-9 (ix), a
	xor	a, a
	ld	-8 (ix), a
	ld	-7 (ix), a
	ld	-6 (ix), a
	ld	a, -13 (ix)
	add	a, -9 (ix)
	ld	-34 (ix), a
	ld	a, -12 (ix)
	adc	a, -8 (ix)
	ld	-33 (ix), a
	ld	a, -11 (ix)
	adc	a, -7 (ix)
	ld	-32 (ix), a
	ld	a, -10 (ix)
	adc	a, -6 (ix)
	ld	-31 (ix), a
	ld	e, -18 (ix)
	ld	d, -17 (ix)
	ld	hl, #0x0000
	add	hl, sp
	ld	bc, #0x0004
	ldir
l_pf_read_00117$:
;pff.c:945: remain = fs->fsize - fs->fptr;
	ld	l, -26 (ix)
	ld	h, -25 (ix)
	ld	c, (hl)
	inc	hl
	ld	a, (hl)
;pff.c:964: rcnt = 512 - (UINT)fs->fptr % 512;			/* Get partial sector data from sector buffer */
	ld	-4 (ix), c
	and	a, #0x01
	ld	-3 (ix), a
	xor	a, a
	sub	a, -4 (ix)
	ld	-16 (ix), a
	ld	a, #0x02
	sbc	a, -3 (ix)
	ld	-15 (ix), a
;pff.c:965: if (rcnt > btr) rcnt = btr;
	ld	a, 6 (ix)
	sub	a, -16 (ix)
	ld	a, 7 (ix)
	sbc	a, -15 (ix)
	jp	NC, l_pf_read_00119$
	ld	a, 6 (ix)
	ld	-16 (ix), a
	ld	a, 7 (ix)
	ld	-15 (ix), a
l_pf_read_00119$:
;pff.c:966: dr = disk_readp(rbuff, fs->dsect, (UINT)fs->fptr % 512, rcnt);
	ld	l, -18 (ix)
	ld	h, -17 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, -16 (ix)
	ld	h, -15 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	push	de
	push	bc
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	call	_disk_readp
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ld	a, l
;pff.c:967: if (dr) ABORT(FR_DISK_ERR);
	or	a, a
	jp	Z, l_pf_read_00121$
	ld	l, -28 (ix)
	ld	h, -27 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_read_00127$
l_pf_read_00121$:
;pff.c:968: fs->fptr += rcnt;							/* Advances file read pointer */
	ld	e, -26 (ix)
	ld	d, -25 (ix)
	ld	hl, #0x0014
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	a, -16 (ix)
	ld	-10 (ix), a
	ld	a, -15 (ix)
	ld	-9 (ix), a
	xor	a, a
	ld	-8 (ix), a
	ld	-7 (ix), a
	ld	a, -14 (ix)
	add	a, -10 (ix)
	ld	-6 (ix), a
	ld	a, -13 (ix)
	adc	a, -9 (ix)
	ld	-5 (ix), a
	ld	a, -12 (ix)
	adc	a, -8 (ix)
	ld	-4 (ix), a
	ld	a, -11 (ix)
	adc	a, -7 (ix)
	ld	-3 (ix), a
	ld	e, -26 (ix)
	ld	d, -25 (ix)
	ld	hl, #0x001c
	add	hl, sp
	ld	bc, #0x0004
	ldir
;pff.c:969: btr -= rcnt; *br += rcnt;					/* Update read counter */
	ld	a, 6 (ix)
	sub	a, -16 (ix)
	ld	6 (ix), a
	ld	a, 7 (ix)
	sbc	a, -15 (ix)
	ld	7 (ix), a
	ld	l, -30 (ix)
	ld	h, -29 (ix)
	ld	a, (hl)
	ld	-6 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-5 (ix), a
	ld	a, -6 (ix)
	add	a, -16 (ix)
	ld	-4 (ix), a
	ld	a, -5 (ix)
	adc	a, -15 (ix)
	ld	-3 (ix), a
	ld	l, -30 (ix)
	ld	h, -29 (ix)
	ld	a, -4 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -3 (ix)
	ld	(hl), a
;pff.c:970: if (rbuff) rbuff += rcnt;					/* Advances the data pointer if destination is memory */
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jp	Z, l_pf_read_00124$
	ld	a, -16 (ix)
	add	a, -2 (ix)
	ld	-2 (ix), a
	ld	a, -15 (ix)
	adc	a, -1 (ix)
	ld	-1 (ix), a
	jp	l_pf_read_00124$
l_pf_read_00126$:
;pff.c:973: return FR_OK;
	ld	l, #0x00
l_pf_read_00127$:
;pff.c:974: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:984: FRESULT pf_write (
;	---------------------------------
; Function pf_write
; ---------------------------------
_pf_write::
	call	___sdcc_enter_ix
	ld	hl, #-27
	add	hl, sp
	ld	sp, hl
;pff.c:992: const BYTE *p = buff;
	ld	a, 4 (ix)
	ld	-2 (ix), a
	ld	a, 5 (ix)
	ld	-1 (ix), a
;pff.c:995: FATFS *fs = FatFs;
	ld	hl, (_FatFs)
	ld	-23 (ix), l
	ld	-22 (ix), h
;pff.c:998: *bw = 0;
	ld	a, 8 (ix)
	ld	-21 (ix), a
	ld	a, 9 (ix)
	ld	-20 (ix), a
	ld	l, -21 (ix)
	ld	h, -20 (ix)
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;pff.c:999: if (!fs) return FR_NOT_ENABLED;		/* Check file system */
	ld	a, -22 (ix)
	or	a, -23 (ix)
	jp	NZ, l_pf_write_00102$
	ld	l, #0x05
	jp	l_pf_write_00139$
l_pf_write_00102$:
;pff.c:1000: if (!(fs->flag & FA_OPENED)) return FR_NOT_OPENED;	/* Check if opened */
	ld	a, -23 (ix)
	add	a, #0x01
	ld	-19 (ix), a
	ld	a, -22 (ix)
	adc	a, #0x00
	ld	-18 (ix), a
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	a, (hl)
	bit	0, a
	jp	NZ,l_pf_write_00236$
	jp	l_pf_write_00237$
l_pf_write_00236$:
	jp	l_pf_write_00104$
l_pf_write_00237$:
	ld	l, #0x04
	jp	l_pf_write_00139$
l_pf_write_00104$:
;pff.c:1003: if ((fs->flag & FA__WIP) && disk_writep(0, 0)) ABORT(FR_DISK_ERR);
	and	a, #0x40
	ld	c, a
	ld	b, #0x00
;pff.c:1002: if (!btw) {		/* Finalize request */
	ld	a, 7 (ix)
	or	a, 6 (ix)
	jp	NZ, l_pf_write_00111$
;pff.c:1003: if ((fs->flag & FA__WIP) && disk_writep(0, 0)) ABORT(FR_DISK_ERR);
	ld	a, b
	or	a, c
	jp	Z, l_pf_write_00106$
	ld	hl, #0x0000
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	call	_disk_writep
	pop	af
	pop	af
	pop	af
	ld	a, l
	or	a, a
	jp	Z, l_pf_write_00106$
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_write_00139$
l_pf_write_00106$:
;pff.c:1004: fs->flag &= ~FA__WIP;
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	a, (hl)
	res	6, a
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	(hl), a
;pff.c:1005: return FR_OK;
	ld	l, #0x00
	jp	l_pf_write_00139$
l_pf_write_00111$:
;pff.c:1008: fs->fptr &= 0xFFFFFE00;
	ld	a, -23 (ix)
	add	a, #0x16
	ld	-4 (ix), a
	ld	a, -22 (ix)
	adc	a, #0x00
	ld	-3 (ix), a
;pff.c:1007: if (!(fs->flag & FA__WIP)) {	/* Round-down fptr to the sector boundary */
	ld	a, b
	or	a, c
	jp	NZ, l_pf_write_00112$
;pff.c:1008: fs->fptr &= 0xFFFFFE00;
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	hl, #0x000f
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	-8 (ix), #0x00
	ld	a, -11 (ix)
	and	a, #0xfe
	ld	-7 (ix), a
	ld	a, -10 (ix)
	ld	-6 (ix), a
	ld	a, -9 (ix)
	ld	-5 (ix), a
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	hl, #0x0013
	add	hl, sp
	ld	bc, #0x0004
	ldir
l_pf_write_00112$:
;pff.c:1011: remain = fs->fsize - fs->fptr;
	ld	l, -23 (ix)
	ld	h, -22 (ix)
	ld	de, #0x001a
	add	hl, de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, -4 (ix)
	ld	-17 (ix), a
	ld	a, -3 (ix)
	ld	-16 (ix), a
	push	de
	push	bc
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	hl, #0x0019
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
	pop	de
	ld	a, c
	sub	a, -6 (ix)
	ld	c, a
	ld	a, b
	sbc	a, -5 (ix)
	ld	b, a
	ld	a, e
	sbc	a, -4 (ix)
	ld	e, a
	ld	a, d
	sbc	a, -3 (ix)
	ld	d, a
;pff.c:1012: if (btw > remain) btw = (UINT)remain;			/* Truncate btw by remaining bytes */
	ld	a, 6 (ix)
	ld	-6 (ix), a
	ld	a, 7 (ix)
	ld	-5 (ix), a
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
	ld	a, c
	sub	a, -6 (ix)
	ld	a, b
	sbc	a, -5 (ix)
	ld	a, e
	sbc	a, -4 (ix)
	ld	a, d
	sbc	a, -3 (ix)
	jp	NC, l_pf_write_00157$
	ld	6 (ix), c
	ld	7 (ix), b
;pff.c:1014: while (btw)	{									/* Repeat until all data transferred */
l_pf_write_00157$:
	ld	a, -23 (ix)
	add	a, #0x22
	ld	-15 (ix), a
	ld	a, -22 (ix)
	adc	a, #0x00
	ld	-14 (ix), a
	ld	a, -23 (ix)
	ld	-13 (ix), a
	ld	a, -22 (ix)
	ld	-12 (ix), a
	ld	a, -23 (ix)
	ld	-11 (ix), a
	ld	a, -22 (ix)
	ld	-10 (ix), a
l_pf_write_00136$:
	ld	a, 7 (ix)
	or	a, 6 (ix)
	jp	Z, l_pf_write_00138$
;pff.c:1015: if ((UINT)fs->fptr % 512 == 0) {			/* On the sector boundary? */
	ld	l, -17 (ix)
	ld	h, -16 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, c
	ld	h, b
	ld	a, l
	or	a, a
	jp	NZ,l_pf_write_00238$
	bit	0, h
	jp	NZ,l_pf_write_00238$
	jp	l_pf_write_00239$
l_pf_write_00238$:
	jp	l_pf_write_00127$
l_pf_write_00239$:
;pff.c:1016: cs = (BYTE)(fs->fptr / 512 & (fs->csize - 1));	/* Sector offset in the cluster */
	ld	-6 (ix), b
	ld	-5 (ix), e
	ld	-4 (ix), d
	xor	a, a
	ld	-3 (ix), a
	srl	-4 (ix)
	rr	-5 (ix)
	rr	-6 (ix)
	ld	l, -11 (ix)
	ld	h, -10 (ix)
	inc	hl
	inc	hl
	ld	l, (hl)
	dec	l
	ld	a, -6 (ix)
	and	a, l
	ld	-9 (ix), a
;pff.c:1017: if (!cs) {								/* On the cluster boundary? */
	or	a, a
	jp	NZ, l_pf_write_00121$
;pff.c:1018: if (fs->fptr == 0) {				/* On the top of the file? */
	ld	a, d
	or	a, e
	or	a, b
	or	a, c
	jp	NZ, l_pf_write_00116$
;pff.c:1019: clst = fs->org_clust;
	ld	l, -13 (ix)
	ld	h, -12 (ix)
	ld	de, #0x001e
	add	hl, de
	ld	a, (hl)
	ld	-6 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-5 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-4 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	jp	l_pf_write_00117$
l_pf_write_00116$:
;pff.c:1021: clst = get_fat(fs->curr_clust);
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	push	bc
	call	_get_fat
	pop	af
	pop	af
	ld	-6 (ix), l
	ld	-5 (ix), h
	ld	-4 (ix), e
	ld	-3 (ix), d
l_pf_write_00117$:
;pff.c:1023: if (clst <= 1) ABORT(FR_DISK_ERR);
	ld	a, #0x01
	cp	a, -6 (ix)
	ld	a, #0x00
	sbc	a, -5 (ix)
	ld	a, #0x00
	sbc	a, -4 (ix)
	ld	a, #0x00
	sbc	a, -3 (ix)
	jp	C, l_pf_write_00119$
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_write_00139$
l_pf_write_00119$:
;pff.c:1024: fs->curr_clust = clst;				/* Update current cluster */
	ld	e, -15 (ix)
	ld	d, -14 (ix)
	ld	hl, #0x0015
	add	hl, sp
	ld	bc, #0x0004
	ldir
l_pf_write_00121$:
;pff.c:1026: sect = clust2sect(fs->curr_clust);		/* Get current sector */
	ld	l, -15 (ix)
	ld	h, -14 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	push	bc
	call	_clust2sect
	pop	af
	pop	af
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	-6 (ix), e
	ld	-5 (ix), d
;pff.c:1027: if (!sect) ABORT(FR_DISK_ERR);
	ld	a, d
	or	a, e
	or	a, h
	or	a, l
	jp	NZ, l_pf_write_00123$
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_write_00139$
l_pf_write_00123$:
;pff.c:1028: fs->dsect = sect + cs;
	ld	a, -23 (ix)
	add	a, #0x26
	ld	-4 (ix), a
	ld	a, -22 (ix)
	adc	a, #0x00
	ld	-3 (ix), a
	ld	c, -9 (ix)
	ld	b, #0x00
	ld	e, #0x00
	ld	d, #0x00
	ld	a, -8 (ix)
	add	a, c
	ld	c, a
	ld	a, -7 (ix)
	adc	a, b
	ld	b, a
	ld	a, -6 (ix)
	adc	a, e
	ld	e, a
	ld	a, -5 (ix)
	adc	a, d
	ld	d, a
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	(hl), c
	inc	hl
	ld	(hl), b
	inc	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
;pff.c:1029: if (disk_writep(0, fs->dsect)) ABORT(FR_DISK_ERR);	/* Initiate a sector write operation */
	push	de
	push	bc
	ld	hl, #0x0000
	push	hl
	call	_disk_writep
	pop	af
	pop	af
	pop	af
	ld	a, l
	or	a, a
	jp	Z, l_pf_write_00125$
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_write_00139$
l_pf_write_00125$:
;pff.c:1030: fs->flag |= FA__WIP;
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	a, (hl)
	set	6, a
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	(hl), a
l_pf_write_00127$:
;pff.c:1032: wcnt = 512 - (UINT)fs->fptr % 512;			/* Number of bytes to write to the sector */
	ld	l, -17 (ix)
	ld	h, -16 (ix)
	ld	c, (hl)
	inc	hl
	ld	a, (hl)
	and	a, #0x01
	ld	b, a
	xor	a, a
	sub	a, c
	ld	c, a
	ld	a, #0x02
	sbc	a, b
	ld	e, a
;pff.c:1033: if (wcnt > btw) wcnt = btw;
	ld	a, 6 (ix)
	sub	a, c
	ld	a, 7 (ix)
	sbc	a, e
	jp	NC, l_pf_write_00129$
	ld	c, 6 (ix)
	ld	e, 7 (ix)
l_pf_write_00129$:
;pff.c:1034: if (disk_writep(p, wcnt)) ABORT(FR_DISK_ERR);	/* Send data to the sector */
	ld	-27 (ix), c
	ld	-26 (ix), e
	xor	a, a
	ld	-25 (ix), a
	ld	-24 (ix), a
	push	bc
	push	de
	ld	l, -25 (ix)
	ld	h, -24 (ix)
	push	hl
	ld	l, -27 (ix)
	ld	h, -26 (ix)
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	call	_disk_writep
	pop	af
	pop	af
	pop	af
	ld	a, l
	pop	de
	pop	bc
	or	a, a
	jp	Z, l_pf_write_00131$
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_write_00139$
l_pf_write_00131$:
;pff.c:1035: fs->fptr += wcnt; p += wcnt;				/* Update pointers and counters */
	ld	l, -17 (ix)
	ld	h, -16 (ix)
	ld	b, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
	ld	h, a
	ld	a, b
	add	a, -27 (ix)
	ld	-6 (ix), a
	ld	a, d
	adc	a, -26 (ix)
	ld	-5 (ix), a
	ld	a, l
	adc	a, -25 (ix)
	ld	-4 (ix), a
	ld	a, h
	adc	a, -24 (ix)
	ld	-3 (ix), a
	push	de
	push	bc
	ld	e, -17 (ix)
	ld	d, -16 (ix)
	ld	hl, #0x0019
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
	pop	de
	ld	a, -2 (ix)
	add	a, c
	ld	-2 (ix), a
	ld	a, -1 (ix)
	adc	a, e
	ld	-1 (ix), a
;pff.c:1036: btw -= wcnt; *bw += wcnt;
	ld	a, 6 (ix)
	sub	a, c
	ld	6 (ix), a
	ld	a, 7 (ix)
	sbc	a, e
	ld	7 (ix), a
	ld	l, -21 (ix)
	ld	h, -20 (ix)
	ld	b, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, b
	add	a, c
	ld	-8 (ix), a
	ld	a, d
	adc	a, e
	ld	-7 (ix), a
	ld	l, -21 (ix)
	ld	h, -20 (ix)
	ld	a, -8 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -7 (ix)
	ld	(hl), a
;pff.c:1037: if ((UINT)fs->fptr % 512 == 0) {
	ld	a, -6 (ix)
	ld	-4 (ix), a
	ld	a, -5 (ix)
	ld	-3 (ix), a
	ld	a, -4 (ix)
	or	a, a
	jp	NZ,l_pf_write_00242$
	bit	0, -3 (ix)
	jp	NZ,l_pf_write_00242$
	jp	l_pf_write_00243$
l_pf_write_00242$:
	jp	l_pf_write_00136$
l_pf_write_00243$:
;pff.c:1038: if (disk_writep(0, 0)) ABORT(FR_DISK_ERR);	/* Finalize the currtent secter write operation */
	ld	hl, #0x0000
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	l, #0x00
	push	hl
	call	_disk_writep
	pop	af
	pop	af
	pop	af
	ld	a, l
	or	a, a
	jp	Z, l_pf_write_00133$
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_write_00139$
l_pf_write_00133$:
;pff.c:1039: fs->flag &= ~FA__WIP;
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	a, (hl)
	res	6, a
	ld	l, -19 (ix)
	ld	h, -18 (ix)
	ld	(hl), a
	jp	l_pf_write_00136$
l_pf_write_00138$:
;pff.c:1043: return FR_OK;
	ld	l, #0x00
l_pf_write_00139$:
;pff.c:1044: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:1054: FRESULT pf_lseek (
;	---------------------------------
; Function pf_lseek
; ---------------------------------
_pf_lseek::
	call	___sdcc_enter_ix
	ld	hl, #-26
	add	hl, sp
	ld	sp, hl
;pff.c:1060: FATFS *fs = FatFs;
	ld	bc, (_FatFs)
;pff.c:1063: if (!fs) return FR_NOT_ENABLED;		/* Check file system */
	ld	a, b
	or	a, c
	jp	NZ, l_pf_lseek_00102$
	ld	l, #0x05
	jp	l_pf_lseek_00121$
l_pf_lseek_00102$:
;pff.c:1064: if (!(fs->flag & FA_OPENED)) return FR_NOT_OPENED;	/* Check if opened */
	ld	hl, #0x0001
	add	hl, bc
	ld	-22 (ix), l
	ld	-21 (ix), h
	ld	l, -22 (ix)
	ld	h, -21 (ix)
	ld	a, (hl)
	rrca
	jp	C,l_pf_lseek_00173$
	jp	l_pf_lseek_00174$
l_pf_lseek_00173$:
	jp	l_pf_lseek_00104$
l_pf_lseek_00174$:
	ld	l, #0x04
	jp	l_pf_lseek_00121$
l_pf_lseek_00104$:
;pff.c:1066: if (ofs > fs->fsize) ofs = fs->fsize;	/* Clip offset with the file size */
	ld	l, c
	ld	h, b
	ld	de, #0x001a
	add	hl, de
	ld	a, (hl)
	ld	-4 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-2 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-1 (ix), a
	ld	a, -4 (ix)
	sub	a, 4 (ix)
	ld	a, -3 (ix)
	sbc	a, 5 (ix)
	ld	a, -2 (ix)
	sbc	a, 6 (ix)
	ld	a, -1 (ix)
	sbc	a, 7 (ix)
	jp	NC, l_pf_lseek_00106$
	push	bc
	ld	hl, #32
	add	hl, sp
	ex	de, hl
	ld	hl, #24
	add	hl, sp
	ld	bc, #4
	ldir
	pop	bc
l_pf_lseek_00106$:
;pff.c:1067: ifptr = fs->fptr;
	ld	hl, #0x0016
	add	hl, bc
	ld	-20 (ix), l
	ld	-19 (ix), h
	push	bc
	ld	e, -20 (ix)
	ld	d, -19 (ix)
	ld	hl, #0x0002
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:1068: fs->fptr = 0;
	ld	l, -20 (ix)
	ld	h, -19 (ix)
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
;pff.c:1069: if (ofs > 0) {
	ld	a, 7 (ix)
	or	a, 6 (ix)
	or	a, 5 (ix)
	or	a, 4 (ix)
	jp	Z, l_pf_lseek_00120$
;pff.c:1070: bcs = (DWORD)fs->csize * 512;		/* Cluster size (byte) */
	ld	hl, #0x0002
	add	hl, bc
	ld	-18 (ix), l
	ld	-17 (ix), h
	ld	l, -18 (ix)
	ld	h, -17 (ix)
	ld	e, (hl)
	ld	d, #0x00
	ld	l, #0x00
	ld	h, #0x00
	ld	-15 (ix), e
	ld	-14 (ix), d
	ld	-13 (ix), l
	ld	-16 (ix), #0x00
	sla	-15 (ix)
	rl	-14 (ix)
	rl	-13 (ix)
;pff.c:1075: clst = fs->curr_clust;
	ld	hl, #0x0022
	add	hl, bc
	ld	-12 (ix), l
	ld	-11 (ix), h
;pff.c:1071: if (ifptr > 0 &&
	ld	a, -23 (ix)
	or	a, -24 (ix)
	or	a, -25 (ix)
	or	a, -26 (ix)
	jp	Z, l_pf_lseek_00108$
;pff.c:1072: (ofs - 1) / bcs >= (ifptr - 1) / bcs) {	/* When seek to same or following cluster, */
	ld	a, 4 (ix)
	add	a, #0xff
	ld	-4 (ix), a
	ld	a, 5 (ix)
	adc	a, #0xff
	ld	-3 (ix), a
	ld	a, 6 (ix)
	adc	a, #0xff
	ld	-2 (ix), a
	ld	a, 7 (ix)
	adc	a, #0xff
	ld	-1 (ix), a
	push	bc
	ld	l, -14 (ix)
	ld	h, -13 (ix)
	push	hl
	ld	l, -16 (ix)
	ld	h, -15 (ix)
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	call	__divulong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	-6 (ix), e
	ld	-5 (ix), d
	pop	bc
	ld	a, -26 (ix)
	add	a, #0xff
	ld	-4 (ix), a
	ld	a, -25 (ix)
	adc	a, #0xff
	ld	-3 (ix), a
	ld	a, -24 (ix)
	adc	a, #0xff
	ld	-2 (ix), a
	ld	a, -23 (ix)
	adc	a, #0xff
	ld	-1 (ix), a
	push	bc
	ld	l, -14 (ix)
	ld	h, -13 (ix)
	push	hl
	ld	l, -16 (ix)
	ld	h, -15 (ix)
	push	hl
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	call	__divulong
	pop	af
	pop	af
	pop	af
	pop	af
	pop	bc
	ld	a, -8 (ix)
	sub	a, l
	ld	a, -7 (ix)
	sbc	a, h
	ld	a, -6 (ix)
	sbc	a, e
	ld	a, -5 (ix)
	sbc	a, d
	jp	C, l_pf_lseek_00108$
;pff.c:1073: fs->fptr = (ifptr - 1) & ~(bcs - 1);	/* start from the current cluster */
	ld	a, -16 (ix)
	add	a, #0xff
	ld	e, a
	ld	a, -15 (ix)
	adc	a, #0xff
	ld	d, a
	ld	a, -14 (ix)
	adc	a, #0xff
	ld	l, a
	ld	a, -13 (ix)
	adc	a, #0xff
	cpl
	ld	h, a
	ld	a, e
	cpl
	push	af
	ld	a, d
	cpl
	ld	e, a
	ld	a, l
	cpl
	ld	l, a
	pop	af
	and	a, -4 (ix)
	ld	-8 (ix), a
	ld	a, e
	and	a, -3 (ix)
	ld	-7 (ix), a
	ld	a, l
	and	a, -2 (ix)
	ld	-6 (ix), a
	ld	a, h
	and	a, -1 (ix)
	ld	-5 (ix), a
	push	bc
	ld	e, -20 (ix)
	ld	d, -19 (ix)
	ld	hl, #0x0014
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:1074: ofs -= fs->fptr;
	ld	a, 4 (ix)
	sub	a, -8 (ix)
	ld	4 (ix), a
	ld	a, 5 (ix)
	sbc	a, -7 (ix)
	ld	5 (ix), a
	ld	a, 6 (ix)
	sbc	a, -6 (ix)
	ld	6 (ix), a
	ld	a, 7 (ix)
	sbc	a, -5 (ix)
	ld	7 (ix), a
;pff.c:1075: clst = fs->curr_clust;
	push	bc
	ld	e, -12 (ix)
	ld	d, -11 (ix)
	ld	hl, #0x0012
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
	jp	l_pf_lseek_00131$
l_pf_lseek_00108$:
;pff.c:1077: clst = fs->org_clust;			/* start from the first cluster */
	ld	l, c
	ld	h, b
	ld	de, #0x001e
	add	hl, de
	ld	a, (hl)
	ld	-10 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-9 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-8 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-7 (ix), a
;pff.c:1078: fs->curr_clust = clst;
	push	bc
	ld	e, -12 (ix)
	ld	d, -11 (ix)
	ld	hl, #0x0012
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:1080: while (ofs > bcs) {				/* Cluster following loop */
l_pf_lseek_00131$:
	ld	-6 (ix), c
	ld	-5 (ix), b
l_pf_lseek_00114$:
	ld	a, -16 (ix)
	sub	a, 4 (ix)
	ld	a, -15 (ix)
	sbc	a, 5 (ix)
	ld	a, -14 (ix)
	sbc	a, 6 (ix)
	ld	a, -13 (ix)
	sbc	a, 7 (ix)
	jp	NC, l_pf_lseek_00116$
;pff.c:1081: clst = get_fat(clst);		/* Follow cluster chain */
	push	bc
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	push	hl
	call	_get_fat
	pop	af
	pop	af
	pop	bc
	ld	-10 (ix), l
	ld	-9 (ix), h
	ld	-8 (ix), e
	ld	-7 (ix), d
;pff.c:1082: if (clst <= 1 || clst >= fs->n_fatent) ABORT(FR_DISK_ERR);
	ld	a, #0x01
	cp	a, -10 (ix)
	ld	a, #0x00
	sbc	a, -9 (ix)
	ld	a, #0x00
	sbc	a, -8 (ix)
	ld	a, #0x00
	sbc	a, -7 (ix)
	jp	NC, l_pf_lseek_00111$
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	de, #0x0006
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
	ld	h, a
	ld	a, -10 (ix)
	sub	a, e
	ld	a, -9 (ix)
	sbc	a, d
	ld	a, -8 (ix)
	sbc	a, l
	ld	a, -7 (ix)
	sbc	a, h
	jp	C, l_pf_lseek_00112$
l_pf_lseek_00111$:
	ld	l, -22 (ix)
	ld	h, -21 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_lseek_00121$
l_pf_lseek_00112$:
;pff.c:1083: fs->curr_clust = clst;
	push	bc
	ld	e, -12 (ix)
	ld	d, -11 (ix)
	ld	hl, #0x0012
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:1084: fs->fptr += bcs;
	ld	l, -20 (ix)
	ld	h, -19 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	inc	hl
	ld	a, (hl)
	dec	hl
	ld	l, (hl)
	ld	h, a
	ld	a, e
	add	a, -16 (ix)
	ld	-4 (ix), a
	ld	a, d
	adc	a, -15 (ix)
	ld	-3 (ix), a
	ld	a, l
	adc	a, -14 (ix)
	ld	-2 (ix), a
	ld	a, h
	adc	a, -13 (ix)
	ld	-1 (ix), a
	push	bc
	ld	e, -20 (ix)
	ld	d, -19 (ix)
	ld	hl, #0x0018
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:1085: ofs -= bcs;
	ld	a, 4 (ix)
	sub	a, -16 (ix)
	ld	4 (ix), a
	ld	a, 5 (ix)
	sbc	a, -15 (ix)
	ld	5 (ix), a
	ld	a, 6 (ix)
	sbc	a, -14 (ix)
	ld	6 (ix), a
	ld	a, 7 (ix)
	sbc	a, -13 (ix)
	ld	7 (ix), a
	jp	l_pf_lseek_00114$
l_pf_lseek_00116$:
;pff.c:1087: fs->fptr += ofs;
	push	bc
	ld	e, -20 (ix)
	ld	d, -19 (ix)
	ld	hl, #0x000e
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
	ld	a, -14 (ix)
	add	a, 4 (ix)
	ld	-4 (ix), a
	ld	a, -13 (ix)
	adc	a, 5 (ix)
	ld	-3 (ix), a
	ld	a, -12 (ix)
	adc	a, 6 (ix)
	ld	-2 (ix), a
	ld	a, -11 (ix)
	adc	a, 7 (ix)
	ld	-1 (ix), a
	push	bc
	ld	e, -20 (ix)
	ld	d, -19 (ix)
	ld	hl, #0x0018
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
;pff.c:1088: sect = clust2sect(clst);		/* Current sector */
	push	bc
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	hl
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	push	hl
	call	_clust2sect
	pop	af
	pop	af
	pop	bc
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
;pff.c:1089: if (!sect) ABORT(FR_DISK_ERR);
	ld	a, d
	or	a, e
	or	a, h
	or	a, l
	jp	NZ, l_pf_lseek_00118$
	ld	l, -22 (ix)
	ld	h, -21 (ix)
	ld	(hl), #0x00
	ld	l, #0x01
	jp	l_pf_lseek_00121$
l_pf_lseek_00118$:
;pff.c:1090: fs->dsect = sect + (fs->fptr / 512 & (fs->csize - 1));
	ld	hl, #0x0026
	add	hl, bc
	ld	-6 (ix), l
	ld	-5 (ix), h
	ld	l, -20 (ix)
	ld	h, -19 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	e, (hl)
	ld	c, b
	ld	b, d
	ld	d, #0x00
	srl	e
	rr	b
	rr	c
	ld	l, -18 (ix)
	ld	h, -17 (ix)
	ld	l, (hl)
	ld	h, #0x00
	dec	hl
	ld	-10 (ix), l
	ld	a, h
	ld	-9 (ix), a
	rla
	sbc	a, a
	ld	-8 (ix), a
	ld	-7 (ix), a
	ld	a, c
	and	a, -10 (ix)
	ld	c, a
	ld	a, b
	and	a, -9 (ix)
	ld	b, a
	ld	a, e
	and	a, -8 (ix)
	ld	e, a
	ld	a, d
	and	a, -7 (ix)
	ld	d, a
	ld	a, c
	add	a, -4 (ix)
	ld	c, a
	ld	a, b
	adc	a, -3 (ix)
	ld	b, a
	ld	a, e
	adc	a, -2 (ix)
	ld	e, a
	ld	a, d
	adc	a, -1 (ix)
	ld	d, a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	(hl), c
	inc	hl
	ld	(hl), b
	inc	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
l_pf_lseek_00120$:
;pff.c:1093: return FR_OK;
	ld	l, #0x00
l_pf_lseek_00121$:
;pff.c:1094: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:1104: FRESULT pf_opendir (
;	---------------------------------
; Function pf_opendir
; ---------------------------------
_pf_opendir::
	call	___sdcc_enter_ix
	ld	hl, #-48
	add	hl, sp
	ld	sp, hl
;pff.c:1114: if (!fs) {				/* Check file system */
	ld	iy, #_FatFs
	ld	a, 1 (iy)
	or	a, 0 (iy)
	jp	NZ, l_pf_opendir_00111$
;pff.c:1115: res = FR_NOT_ENABLED;
	ld	c, #0x05
	jp	l_pf_opendir_00112$
l_pf_opendir_00111$:
;pff.c:1117: dj->fn = sp;
	ld	a, 4 (ix)
	ld	-2 (ix), a
	ld	a, 5 (ix)
	ld	-1 (ix), a
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	inc	bc
	inc	bc
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	a, e
	ld	(bc), a
	inc	bc
	ld	a, d
	ld	(bc), a
;pff.c:1118: res = follow_path(dj, dir, path);		/* Follow the path to the directory */
	ld	hl, #12
	add	hl, sp
	ex	de, hl
	ld	c, e
	ld	b, d
	push	de
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	push	bc
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	call	_follow_path
	pop	af
	pop	af
	pop	af
	ld	a, l
	pop	de
	ld	c, a
;pff.c:1119: if (res == FR_OK) {						/* Follow completed */
	ld	a, c
	or	a, a
	jp	NZ, l_pf_opendir_00112$
;pff.c:1120: if (dir[0]) {						/* It is not the root dir */
	ld	a, (de)
	or	a, a
	jp	Z, l_pf_opendir_00105$
;pff.c:1121: if (dir[DIR_Attr] & AM_DIR) {	/* The object is a directory */
	ld	l, e
	ld	h, d
	push	bc
	ld	bc, #0x000b
	add	hl, bc
	pop	bc
	ld	a, (hl)
	bit	4, a
	jp	NZ,l_pf_opendir_00140$
	jp	l_pf_opendir_00102$
l_pf_opendir_00140$:
;pff.c:1122: dj->sclust = get_clust(dir);
	ld	a, -2 (ix)
	add	a, #0x04
	ld	l, a
	ld	a, -1 (ix)
	adc	a, #0x00
	ld	h, a
	push	hl
	push	bc
	push	de
	call	_get_clust
	pop	af
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-2 (ix), e
	ld	-1 (ix), d
	pop	bc
	pop	hl
	push	bc
	ld	e, l
	ld	d, h
	ld	hl, #0x002e
	add	hl, sp
	ld	bc, #0x0004
	ldir
	pop	bc
	jp	l_pf_opendir_00105$
l_pf_opendir_00102$:
;pff.c:1124: res = FR_NO_FILE;
	ld	c, #0x03
l_pf_opendir_00105$:
;pff.c:1127: if (res == FR_OK) {
	ld	a, c
	or	a, a
	jp	NZ, l_pf_opendir_00112$
;pff.c:1128: res = dir_rewind(dj);			/* Rewind dir */
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_dir_rewind
	pop	af
	ld	a, l
	ld	c, a
l_pf_opendir_00112$:
;pff.c:1133: return res;
	ld	l, c
l_pf_opendir_00113$:
;pff.c:1134: }
	ld	sp, ix
	pop	ix
	ret
;pff.c:1143: FRESULT pf_readdir (
;	---------------------------------
; Function pf_readdir
; ---------------------------------
_pf_readdir::
	call	___sdcc_enter_ix
	ld	hl, #-46
	add	hl, sp
	ld	sp, hl
;pff.c:1153: if (!fs) {				/* Check file system */
	ld	iy, #_FatFs
	ld	a, 1 (iy)
	or	a, 0 (iy)
	jp	NZ, l_pf_readdir_00111$
;pff.c:1154: res = FR_NOT_ENABLED;
	ld	l, #0x05
	jp	l_pf_readdir_00112$
l_pf_readdir_00111$:
;pff.c:1156: dj->fn = sp;
	ld	c, 4 (ix)
	ld	b, 5 (ix)
	ld	e, c
	ld	d, b
	inc	de
	inc	de
	ld	hl, #0
	add	hl, sp
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	a, -2 (ix)
	ld	(de), a
	inc	de
	ld	a, -1 (ix)
	ld	(de), a
;pff.c:1157: if (!fno) {
	ld	a, 7 (ix)
	or	a, 6 (ix)
	jp	NZ, l_pf_readdir_00108$
;pff.c:1158: res = dir_rewind(dj);
	push	bc
	call	_dir_rewind
	pop	af
	jp	l_pf_readdir_00112$
l_pf_readdir_00108$:
;pff.c:1160: res = dir_read(dj, dir);	/* Get current directory item */
	ld	hl, #12
	add	hl, sp
	ex	de, hl
	ld	l, e
	ld	h, d
	push	bc
	push	de
	push	hl
	push	bc
	call	_dir_read
	pop	af
	pop	af
	pop	de
	pop	bc
;pff.c:1161: if (res == FR_NO_FILE) res = FR_OK;
	ld	a, l
	sub	a, #0x03
	jp	NZ,l_pf_readdir_00140$
	jp	l_pf_readdir_00141$
l_pf_readdir_00140$:
	jp	l_pf_readdir_00102$
l_pf_readdir_00141$:
	ld	l, #0x00
l_pf_readdir_00102$:
;pff.c:1162: if (res == FR_OK) {				/* A valid entry is found */
	ld	a, l
	or	a, a
	jp	NZ, l_pf_readdir_00112$
;pff.c:1163: get_fileinfo(dj, dir, fno);	/* Get the object information */
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	push	hl
	push	de
	push	bc
	call	_get_fileinfo
	pop	af
	pop	af
	pop	af
;pff.c:1164: res = dir_next(dj);			/* Increment read index for next */
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_dir_next
	pop	af
;pff.c:1165: if (res == FR_NO_FILE) res = FR_OK;
	ld	a, l
	sub	a, #0x03
	jp	NZ,l_pf_readdir_00142$
	jp	l_pf_readdir_00143$
l_pf_readdir_00142$:
	jp	l_pf_readdir_00112$
l_pf_readdir_00143$:
	ld	l, #0x00
l_pf_readdir_00112$:
;pff.c:1170: return res;
l_pf_readdir_00113$:
;pff.c:1171: }
	ld	sp, ix
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
