/*----------------------------------------------------------------------------/
/  Petit FatFs - FAT file system module  R0.03a
/-----------------------------------------------------------------------------/
/
/ Copyright (C) 2019, ChaN, all right reserved.
/ Modifications for RFS/Sharp MZ80A: Philip Smart, 2020
/
/ Petit FatFs module is an open source software. Redistribution and use of
/ Petit FatFs in source and binary forms, with or without modification, are
/ permitted provided that the following condition is met:
/
/ 1. Redistributions of source code must retain the above copyright notice,
/    this condition and the following disclaimer.
/
/ This software is provided by the copyright holder and contributors "AS IS"
/ and any warranties related to this software are DISCLAIMED.
/ The copyright owner or contributors be NOT LIABLE for any damages caused
/ by use of this software.
/-----------------------------------------------------------------------------/
/ Jun 15,'09  R0.01a  First release.
/
/ Dec 14,'09  R0.02   Added multiple code page support.
/                     Added write funciton.
/                     Changed stream read mode interface.
/ Dec 07,'10  R0.02a  Added some configuration options.
/                     Fixed fails to open objects with DBCS character.

/ Jun 10,'14  R0.03   Separated out configuration options to pffconf.h.
/                     Added _USE_LCC option.
/                     Added _FS_FAT16 option.
/
/ Jan 30,'19  R0.03a  Supported stdint.h for C99 and later.
/                     Removed _WORD_ACCESS option.
/                     Changed prefix of configuration options, _ to PF_.
/                     Added some code pages.
/                     Removed some code pages actually not valid.
/
/ Mar 12,'20  R0.04   Removal of all non-FAT32 code and adapted for use in 
/                     banked ROMS as part of the RFS on the Sharp MZ80A.
/----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include "pff.h"		/* Petit FatFs configurations and declarations */
#include "sdmmc.h"		/* Declarations of low level disk I/O functions */
#define  PFF_FUNC_C
#include "pff_func.h"

/*--------------------------------------------------------------------------

   Module Private Definitions

---------------------------------------------------------------------------*/


/*--------------------------------------------------------------------------

   Private Functions

---------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------*/
/* Load multi-byte word in the FAT structure                             */
/*-----------------------------------------------------------------------*/

WORD ld_word (const BYTE* ptr)	/*	 Load a 2-byte little-endian word */
{
	WORD rv;

	rv = ptr[1];
	rv = rv << 8 | ptr[0];
	return rv;
}

DWORD ld_dword (const BYTE* ptr)	/* Load a 4-byte little-endian word */
{
	DWORD rv;

	rv = ptr[3];
	rv = rv << 8 | ptr[2];
	rv = rv << 8 | ptr[1];
	rv = rv << 8 | ptr[0];
	return rv;
}



/*-----------------------------------------------------------------------*/
/* String functions                                                      */
/*-----------------------------------------------------------------------*/

/* Fill memory block */
void mem_set (void* dst, int val, int cnt) {
	char *d = (char*)dst;
	while (cnt--) *d++ = (char)val;
}

/* Compare memory block */
int mem_cmp (const void* dst, const void* src, int cnt) {
	const char *d = (const char *)dst, *s = (const char *)src;
	int r = 0;
	while (cnt-- && (r = *d++ - *s++) == 0) ;
	return r;
}

/*-----------------------------------------------------------------------*/
/* FAT access - Read value of a FAT entry                                */
/*-----------------------------------------------------------------------*/

CLUST get_fat (	/* 1:IO error, Else:Cluster status */
	CLUST clst	/* Cluster# to get the link information */
)
{
	BYTE buf[4];
	FATFS *fs = FatFs;

	if (clst < 2 || clst >= fs->n_fatent) return 1;	/* Range check */

	switch (fs->fs_type) {
	case FS_FAT32 :
		if (disk_readp(buf, fs->fatbase + clst / 128, ((UINT)clst % 128) * 4, 4)) break;
		return ld_dword(buf) & 0x0FFFFFFF;
	}

	return 1;	/* An error occured at the disk I/O layer */
}


/*-----------------------------------------------------------------------*/
/* Get sector# from cluster# / Get cluster field from directory entry    */
/*-----------------------------------------------------------------------*/

DWORD clust2sect (	/* !=0: Sector number, 0: Failed - invalid cluster# */
	CLUST clst		/* Cluster# to be converted */
)
{
	FATFS *fs = FatFs;

	clst -= 2;
	if (clst >= (fs->n_fatent - 2)) return 0;		/* Invalid cluster# */
	return (DWORD)clst * fs->csize + fs->database;
}


CLUST get_clust (
	BYTE* dir		/* Pointer to directory entry */
)
{
	FATFS *fs = FatFs;
	CLUST clst = 0;


	clst = ld_word(dir+DIR_FstClusHI);
	clst <<= 16;
	clst |= ld_word(dir+DIR_FstClusLO);

	return clst;
}

/*-----------------------------------------------------------------------*/
/* Pick a segment and create the object name in directory form           */
/*-----------------------------------------------------------------------*/


FRESULT create_name (
	DIR *dj,			/* Pointer to the directory object */
	const char **path	/* Pointer to pointer to the segment in the path string */
)
{
	BYTE c, d, ni, si, i, *sfn;
	const char *p;
#if PF_USE_LCC && defined(_EXCVT)
	static const BYTE cvt[] = _EXCVT;
#endif

	/* Create file name in directory form */
	sfn = dj->fn;
	mem_set(sfn, ' ', 11);
	si = i = 0; ni = 8;
	p = *path;
	for (;;) {
		c = p[si++];
		if (c <= ' ' || c == '/') break;	/* Break on end of segment */
		if (c == '.' || i >= ni) {
			if (ni != 8 || c != '.') break;
			i = 8; ni = 11;
			continue;
		}
#if PF_USE_LCC && defined(_EXCVT)
		if (c >= 0x80) c = cvt[c - 0x80];	/* To upper extended char (SBCS) */
#endif
		if (IsDBCS1(c) && i < ni - 1) {	/* DBC 1st byte? */
			d = p[si++];				/* Get 2nd byte */
			sfn[i++] = c;
			sfn[i++] = d;
		} else {						/* Single byte code */
			if (PF_USE_LCC && IsLower(c)) c -= 0x20;	/* toupper */
			sfn[i++] = c;
		}
	}
	*path = &p[si];						/* Rerurn pointer to the next segment */

	sfn[11] = (c <= ' ') ? 1 : 0;		/* Set last segment flag if end of path */

	return FR_OK;
}


/*-----------------------------------------------------------------------*/
/* Follow a file path                                                    */
/*-----------------------------------------------------------------------*/

FRESULT follow_path (	/* FR_OK(0): successful, !=0: error code */
	DIR *dj,			/* Directory object to return last directory and found object */
	BYTE *dir,			/* 32-byte working buffer */
	const char *path	/* Full-path string to find a file or directory */
)
{
	FRESULT res;


	while (*path == ' ') path++;		/* Strip leading spaces */
	if (*path == '/') path++;			/* Strip heading separator if exist */
	dj->sclust = 0;						/* Set start directory (always root dir) */

	if ((BYTE)*path < ' ') {			/* Null path means the root directory */
		res = dir_rewind(dj);
		dir[0] = 0;

	} else {							/* Follow path */
		for (;;) {
			res = create_name(dj, &path);	/* Get a segment */
			if (res != FR_OK) break;
			res = dir_find(dj, dir);		/* Find it */
			if (res != FR_OK) break;		/* Could not find the object */
			if (dj->fn[11]) break;			/* Last segment match. Function completed. */
			if (!(dir[DIR_Attr] & AM_DIR)) { /* Cannot follow path because it is a file */
				res = FR_NO_FILE; break;
			}
			dj->sclust = get_clust(dir);	/* Follow next */
		}
	}

	return res;
}


/*-----------------------------------------------------------------------*/
/* Check a sector if it is an FAT boot record                            */
/*-----------------------------------------------------------------------*/

BYTE check_fs (	/* 0:The FAT boot record, 1:Valid boot record but not an FAT, 2:Not a boot record, 3:Error */
	BYTE *buf,	/* Working buffer */
	DWORD sect	/* Sector# (lba) to check if it is an FAT boot record or not */
)
{
	if (disk_readp(buf, sect, 510, 2)) {	/* Read the boot record */
		return 3;
	}
	if (ld_word(buf) != 0xAA55) {			/* Check record signature */
		return 2;
	}

//	if (!_FS_32ONLY && !disk_readp(buf, sect, BS_FilSysType, 2) && ld_word(buf) == 0x4146) {	/* Check FAT12/16 */
//		return 0;
//	}
	if (!disk_readp(buf, sect, BS_FilSysType32, 2) && ld_word(buf) == 0x4146) {	/* Check FAT32 */
		return 0;
	}
	return 1;
}
