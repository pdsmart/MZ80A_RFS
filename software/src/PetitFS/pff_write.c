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
#define  PFF_WRITE_C

/*-----------------------------------------------------------------------*/
/* Write File                                                            */
/*-----------------------------------------------------------------------*/
FRESULT pf_write (
	const void* buff,	/* Pointer to the data to be written */
	UINT btw,			/* Number of bytes to write (0:Finalize the current write operation) */
	UINT* bw			/* Pointer to number of bytes written */
)
{
	CLUST clst;
	DWORD sect, remain;
	const BYTE *p = buff;
	BYTE cs;
	UINT wcnt;
	FATFS *fs = FatFs;


	*bw = 0;
	if (!fs) return FR_NOT_ENABLED;		/* Check file system */
	if (!(fs->flag & FA_OPENED)) return FR_NOT_OPENED;	/* Check if opened */

	if (!btw) {		/* Finalize request */
		if ((fs->flag & FA__WIP) && disk_writep(0, 0)) ABORT(FR_DISK_ERR);
		fs->flag &= ~FA__WIP;
		return FR_OK;
	} else {		/* Write data request */
		if (!(fs->flag & FA__WIP)) {	/* Round-down fptr to the sector boundary */
			fs->fptr &= 0xFFFFFE00;
		}
	}
	remain = fs->fsize - fs->fptr;
	if (btw > remain) btw = (UINT)remain;			/* Truncate btw by remaining bytes */

	while (btw)	{									/* Repeat until all data transferred */
		if ((UINT)fs->fptr % 512 == 0) {			/* On the sector boundary? */
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
			if (disk_writep(0, fs->dsect)) ABORT(FR_DISK_ERR);	/* Initiate a sector write operation */
			fs->flag |= FA__WIP;
		}
		wcnt = 512 - (UINT)fs->fptr % 512;			/* Number of bytes to write to the sector */
		if (wcnt > btw) wcnt = btw;
		if (disk_writep(p, wcnt)) ABORT(FR_DISK_ERR);	/* Send data to the sector */
		fs->fptr += wcnt; p += wcnt;				/* Update pointers and counters */
		btw -= wcnt; *bw += wcnt;
		if ((UINT)fs->fptr % 512 == 0) {
			if (disk_writep(0, 0)) ABORT(FR_DISK_ERR);	/* Finalize the currtent secter write operation */
			fs->flag &= ~FA__WIP;
		}
	}

	return FR_OK;
}
