/*---------------------------------------------------------------------------/
/  Petit FatFs - FAT file system module include file  R0.03a
/----------------------------------------------------------------------------/
/ Petit FatFs module is an open source software to implement FAT file system to
/ small embedded systems. This is a free software and is opened for education,
/ research and commercial developments under license policy of following trems.
/
/  Copyright (C) 2019, ChaN, all right reserved.
/  Modifications for RFS/Sharp MZ80A: Philip Smart, 2020
/
/ * The Petit FatFs module is a free software and there is NO WARRANTY.
/ * No restriction on use. You can use, modify and redistribute it for
/   personal, non-profit or commercial use UNDER YOUR RESPONSIBILITY.
/ * Redistributions of source code must retain the above copyright notice.
/
/----------------------------------------------------------------------------*/

#ifndef PF_MOUNT_DEFINED
#define PF_MOUNT_DEFINED    8088    /* Revision ID */

#ifdef __cplusplus
extern "C" {
#endif


/*--------------------------------------------------------------*/
/* Petit FatFs module application interface                     */
extern FRESULT dir_rewind(DIR *dj);
extern FRESULT dir_find(DIR *dj, BYTE *dir);

#ifdef __cplusplus
}
#endif

#endif

