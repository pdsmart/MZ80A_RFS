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
#define  PFF_SEEK_C

/*-----------------------------------------------------------------------*/
/* Seek File R/W Pointer                                                 */
/*-----------------------------------------------------------------------*/
FRESULT pf_lseek ( DWORD ofs )	/* File pointer from top of file */
{
	CLUST clst;
	DWORD bcs, sect, ifptr;
	FATFS *fs = FatFs;


	if (!fs) return FR_NOT_ENABLED;		/* Check file system */
	if (!(fs->flag & FA_OPENED)) return FR_NOT_OPENED;	/* Check if opened */

	if (ofs > fs->fsize) ofs = fs->fsize;	/* Clip offset with the file size */
	ifptr = fs->fptr;
	fs->fptr = 0;
	if (ofs > 0) {
		bcs = (DWORD)fs->csize * 512;		/* Cluster size (byte) */
		if (ifptr > 0 &&
			(ofs - 1) / bcs >= (ifptr - 1) / bcs) {	/* When seek to same or following cluster, */
			fs->fptr = (ifptr - 1) & ~(bcs - 1);	/* start from the current cluster */
			ofs -= fs->fptr;
			clst = fs->curr_clust;
		} else {							/* When seek to back cluster, */
			clst = fs->org_clust;			/* start from the first cluster */
			fs->curr_clust = clst;
		}
		while (ofs > bcs) {				/* Cluster following loop */
			clst = get_fat(clst);		/* Follow cluster chain */
			if (clst <= 1 || clst >= fs->n_fatent) ABORT(FR_DISK_ERR);
			fs->curr_clust = clst;
			fs->fptr += bcs;
			ofs -= bcs;
		}
		fs->fptr += ofs;
		sect = clust2sect(clst);		/* Current sector */
		if (!sect) ABORT(FR_DISK_ERR);
		fs->dsect = sect + (fs->fptr / 512 & (fs->csize - 1));
	}

	return FR_OK;
}
