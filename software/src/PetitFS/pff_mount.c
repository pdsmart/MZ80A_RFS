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
#define  PFF_MOUNT_C
#include "pff_func.h"

/*-----------------------------------------------------------------------*/
/* Mount/Unmount a Locical Drive                                         */
/*-----------------------------------------------------------------------*/

FRESULT pf_mount (
	FATFS *fs		/* Pointer to new file system object */
)
{
	BYTE fmt, buf[36];
	DWORD bsect, fsize, tsect, mclst;


	FatFs = 0;
	if (disk_initialize() & STA_NOINIT) {	/* Check if the drive is ready or not */
		return FR_NOT_READY;
	}

	/* Search FAT partition on the drive */
	bsect = 0;
	fmt = check_fs(buf, bsect);			/* Check sector 0 as an SFD format */
	if (fmt == 1) {						/* Not an FAT boot record, it may be FDISK format */
		/* Check a partition listed in top of the partition table */
		if (disk_readp(buf, bsect, MBR_Table, 16)) {	/* 1st partition entry */
			fmt = 3;
		} else {
			if (buf[4]) {					/* Is the partition existing? */
				bsect = ld_dword(&buf[8]);	/* Partition offset in LBA */
				fmt = check_fs(buf, bsect);	/* Check the partition */
			}
		}
	}
	if (fmt == 3) return FR_DISK_ERR;
	if (fmt) return FR_NO_FILESYSTEM;	/* No valid FAT patition is found */

	/* Initialize the file system object */
	if (disk_readp(buf, bsect, 13, sizeof (buf))) return FR_DISK_ERR;

	fsize = ld_word(buf+BPB_FATSz16-13);				/* Number of sectors per FAT */
	if (!fsize) fsize = ld_dword(buf+BPB_FATSz32-13);

	fsize *= buf[BPB_NumFATs-13];						/* Number of sectors in FAT area */
	fs->fatbase = bsect + ld_word(buf+BPB_RsvdSecCnt-13); /* FAT start sector (lba) */
	fs->csize = buf[BPB_SecPerClus-13];					/* Number of sectors per cluster */
	fs->n_rootdir = ld_word(buf+BPB_RootEntCnt-13);		/* Nmuber of root directory entries */
	tsect = ld_word(buf+BPB_TotSec16-13);				/* Number of sectors on the file system */
	if (!tsect) tsect = ld_dword(buf+BPB_TotSec32-13);
	mclst = (tsect						/* Last cluster# + 1 */
		- ld_word(buf+BPB_RsvdSecCnt-13) - fsize - fs->n_rootdir / 16
		) / fs->csize + 2;
	fs->n_fatent = (CLUST)mclst;

	fmt = 0;							/* Determine the FAT sub type */
	if (mclst >= 0xFFF7) fmt = FS_FAT32;
	if (!fmt) return FR_NO_FILESYSTEM;
	fs->fs_type = fmt;

//	if (_FS_32ONLY || (PF_FS_FAT32 && fmt == FS_FAT32)) {
		fs->dirbase = ld_dword(buf+(BPB_RootClus-13));	/* Root directory start cluster */
//	} else {
//		fs->dirbase = fs->fatbase + fsize;				/* Root directory start sector (lba) */
//	}
	fs->database = fs->fatbase + fsize + fs->n_rootdir / 16;	/* Data start sector (lba) */

	fs->flag = 0;
	FatFs = fs;

	return FR_OK;
}
