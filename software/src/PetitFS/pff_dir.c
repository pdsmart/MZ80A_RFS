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
#include "pff_func.h"
#define  PFF_DIR_C
#include "pff_dir.h"


/*-----------------------------------------------------------------------*/
/* Directory handling - Rewind directory index                           */
/*-----------------------------------------------------------------------*/

FRESULT dir_rewind (
	DIR *dj			/* Pointer to directory object */
)
{
	CLUST clst;
	FATFS *fs = FatFs;


	dj->index = 0;
	clst = dj->sclust;
	if (clst == 1 || clst >= fs->n_fatent) {	/* Check start cluster range */
		return FR_DISK_ERR;
	}
    if(!clst)
    {
		clst = (CLUST)fs->dirbase;
	}
	dj->clust = clst;						/* Current cluster */
	dj->sect = clust2sect(clst);	/* Current sector */
	return FR_OK;	/* Seek succeeded */
}




/*-----------------------------------------------------------------------*/
/* Directory handling - Move directory index next                        */
/*-----------------------------------------------------------------------*/

FRESULT dir_next (	/* FR_OK:Succeeded, FR_NO_FILE:End of table */
	DIR *dj			/* Pointer to directory object */
)
{
	CLUST clst;
	WORD i;
	FATFS *fs = FatFs;


	i = dj->index + 1;
	if (!i || !dj->sect) return FR_NO_FILE;	/* Report EOT when index has reached 65535 */

	if (!(i % 16)) {		/* Sector changed? */
		dj->sect++;			/* Next sector */

		if (dj->clust == 0) {	/* Static table */
			if (i >= fs->n_rootdir) return FR_NO_FILE;	/* Report EOT when end of table */
		}
		else {					/* Dynamic table */
			if (((i / 16) & (fs->csize - 1)) == 0) {	/* Cluster changed? */
				clst = get_fat(dj->clust);		/* Get next cluster */
				if (clst <= 1) return FR_DISK_ERR;
				if (clst >= fs->n_fatent) return FR_NO_FILE;	/* Report EOT when it reached end of dynamic table */
				dj->clust = clst;				/* Initialize data for new cluster */
				dj->sect = clust2sect(clst);
			}
		}
	}

	dj->index = i;

	return FR_OK;
}




/*-----------------------------------------------------------------------*/
/* Directory handling - Find an object in the directory                  */
/*-----------------------------------------------------------------------*/

FRESULT dir_find (
	DIR *dj,		/* Pointer to the directory object linked to the file name */
	BYTE *dir		/* 32-byte working buffer */
)
{
	FRESULT res;
	BYTE c;


	res = dir_rewind(dj);			/* Rewind directory object */
	if (res != FR_OK) return res;

	do {
		res = disk_readp(dir, dj->sect, (dj->index % 16) * 32, 32)	/* Read an entry */
			? FR_DISK_ERR : FR_OK;
		if (res != FR_OK) break;
		c = dir[DIR_Name];	/* First character */
		if (c == 0) { res = FR_NO_FILE; break; }	/* Reached to end of table */
		if (!(dir[DIR_Attr] & AM_VOL) && !mem_cmp(dir, dj->fn, 11)) break;	/* Is it a valid entry? */
		res = dir_next(dj);					/* Next entry */
	} while (res == FR_OK);

	return res;
}




/*-----------------------------------------------------------------------*/
/* Read an object from the directory                                     */
/*-----------------------------------------------------------------------*/
FRESULT dir_read (
	DIR *dj,		/* Pointer to the directory object to store read object name */
	BYTE *dir		/* 32-byte working buffer */
)
{
	FRESULT res;
	BYTE a, c;


	res = FR_NO_FILE;
	while (dj->sect) {

		res = disk_readp(dir, dj->sect, (dj->index % 16) * 32, 32)	/* Read an entry */
			? FR_DISK_ERR : FR_OK;
		if (res != FR_OK) break;
		c = dir[DIR_Name];
		if (c == 0) { res = FR_NO_FILE; break; }	/* Reached to end of table */
		a = dir[DIR_Attr] & AM_MASK;
		if (c != 0xE5 && c != '.' && !(a & AM_VOL))	break;	/* Is it a valid entry? */
		res = dir_next(dj);			/* Next entry */
		if (res != FR_OK) break;
	}

	if (res != FR_OK) dj->sect = 0;

	return res;
}


/*-----------------------------------------------------------------------*/
/* Get file information from directory entry                             */
/*-----------------------------------------------------------------------*/
void get_fileinfo (		/* No return code */
	DIR *dj,			/* Pointer to the directory object */
	BYTE *dir,			/* 32-byte working buffer */
	FILINFO *fno	 	/* Pointer to store the file information */
)
{
	BYTE i, c;
	char *p;


	p = fno->fname;
	if (dj->sect) {
		for (i = 0; i < 8; i++) {	/* Copy file name body */
			c = dir[i];
			if (c == ' ') break;
			if (c == 0x05) c = 0xE5;
			*p++ = c;
		}
		if (dir[8] != ' ') {		/* Copy file name extension */
			*p++ = '.';
			for (i = 8; i < 11; i++) {
				c = dir[i];
				if (c == ' ') break;
				*p++ = c;
			}
		}
		fno->fattrib = dir[DIR_Attr];				/* Attribute */
		fno->fsize = ld_dword(dir+DIR_FileSize);	/* Size */
		fno->fdate = ld_word(dir+DIR_WrtDate);		/* Date */
		fno->ftime = ld_word(dir+DIR_WrtTime);		/* Time */
	}
	*p = 0;
}




/*--------------------------------------------------------------------------

   Public Functions

--------------------------------------------------------------------------*/



/*-----------------------------------------------------------------------*/
/* Create a Directroy Object                                             */
/*-----------------------------------------------------------------------*/
FRESULT pf_opendir (
	DIR *dj,			/* Pointer to directory object to create */
	const char *path	/* Pointer to the directory path */
)
{
	FRESULT res;
	BYTE sp[12], dir[32];
	FATFS *fs = FatFs;


	if (!fs) {				/* Check file system */
		res = FR_NOT_ENABLED;
	} else {
		dj->fn = sp;
		res = follow_path(dj, dir, path);		/* Follow the path to the directory */
		if (res == FR_OK) {						/* Follow completed */
			if (dir[0]) {						/* It is not the root dir */
				if (dir[DIR_Attr] & AM_DIR) {	/* The object is a directory */
					dj->sclust = get_clust(dir);
				} else {							/* The object is not a directory */
					res = FR_NO_FILE;
				}
			}
			if (res == FR_OK) {
				res = dir_rewind(dj);			/* Rewind dir */
			}
		}
	}

	return res;
}



/*-----------------------------------------------------------------------*/
/* Read Directory Entry in Sequense                                      */
/*-----------------------------------------------------------------------*/

FRESULT pf_readdir (
	DIR *dj,			/* Pointer to the open directory object */
	FILINFO *fno		/* Pointer to file information to return */
)
{
	FRESULT res;
	BYTE sp[12], dir[32];
	FATFS *fs = FatFs;


	if (!fs) {				/* Check file system */
		res = FR_NOT_ENABLED;
	} else {
		dj->fn = sp;
		if (!fno) {
			res = dir_rewind(dj);
		} else {
			res = dir_read(dj, dir);	/* Get current directory item */
			if (res == FR_NO_FILE) res = FR_OK;
			if (res == FR_OK) {				/* A valid entry is found */
				get_fileinfo(dj, dir, fno);	/* Get the object information */
				res = dir_next(dj);			/* Increment read index for next */
			//	if (res == FR_NO_FILE) res = FR_OK;
			}
		}
	}

	return res;
}
