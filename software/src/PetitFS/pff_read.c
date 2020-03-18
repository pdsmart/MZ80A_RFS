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
#define  PFF_READ_C

/*-----------------------------------------------------------------------*/
/* Read File                                                             */
/*-----------------------------------------------------------------------*/
FRESULT pf_read (
	void* buff,		/* Pointer to the read buffer (NULL:Forward data to the stream)*/
	UINT btr,		/* Number of bytes to read */
	UINT* br		/* Pointer to number of bytes read */
)
{
	DRESULT dr;
	CLUST clst;
	DWORD sect, remain;
	UINT rcnt;
	BYTE cs, *rbuff = buff;
	FATFS *fs = FatFs;


	*br = 0;
	if (!fs) return FR_NOT_ENABLED;		/* Check file system */
	if (!(fs->flag & FA_OPENED)) return FR_NOT_OPENED;	/* Check if opened */

	remain = fs->fsize - fs->fptr;
	if (btr > remain) btr = (UINT)remain;			/* Truncate btr by remaining bytes */

	while (btr)	{									/* Repeat until all data transferred */
		if ((fs->fptr % 512) == 0) {				/* On the sector boundary? */
			cs = (BYTE)(fs->fptr / 512 & (fs->csize - 1));	/* Sector offset in the cluster */
			if (!cs) {								/* On the cluster boundary? */
				if (fs->fptr == 0) {				/* On the top of the file? */
					clst = fs->org_clust;
				} else {
					clst = get_fat(fs->curr_clust);
				}
				if (clst <= 1) ABORT(FR_DISK_ERR);
				fs->curr_clust = clst;				/* Update current cluster */
			}
			sect = clust2sect(fs->curr_clust);		/* Get current sector */
			if (!sect) ABORT(FR_DISK_ERR);
			fs->dsect = sect + cs;
		}
		rcnt = 512 - (UINT)fs->fptr % 512;			/* Get partial sector data from sector buffer */
		if (rcnt > btr) rcnt = btr;
		dr = disk_readp(rbuff, fs->dsect, (UINT)fs->fptr % 512, rcnt);
		if (dr) ABORT(FR_DISK_ERR);
		fs->fptr += rcnt;							/* Advances file read pointer */
		btr -= rcnt; *br += rcnt;					/* Update read counter */
		if (rbuff) rbuff += rcnt;					/* Advances the data pointer if destination is memory */
	}

	return FR_OK;
}
