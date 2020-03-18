;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module diskio
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _disk_initialize
	.globl _disk_readp
	.globl _disk_writep
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
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
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;diskio.c:18: return stat;
	ld	l, -1 (ix)
00101$:
;diskio.c:19: }
	inc	sp
	pop	ix
	ret
;diskio.c:27: DRESULT disk_readp (
;	---------------------------------
; Function disk_readp
; ---------------------------------
_disk_readp::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;diskio.c:38: return res;
	ld	l, -1 (ix)
00101$:
;diskio.c:39: }
	inc	sp
	pop	ix
	ret
;diskio.c:47: DRESULT disk_writep (
;	---------------------------------
; Function disk_writep
; ---------------------------------
_disk_writep::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;diskio.c:71: return res;
	ld	l, -1 (ix)
00103$:
;diskio.c:72: }
	inc	sp
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
