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

#ifndef PF_FUNC_DEFINED
#define PF_FUNC_DEFINED    8088    /* Revision ID */

#ifdef __cplusplus
extern "C" {
#endif


/*--------------------------------------------------------------*/
/* Petit FatFs module application interface                     */
WORD ld_word (const BYTE* ptr);
DWORD ld_dword (const BYTE* ptr);
void mem_set (void* dst, int val, int cnt);
int mem_cmp (const void* dst, const void* src, int cnt);
CLUST get_fat(CLUST clst);
DWORD clust2sect( CLUST clst);
FRESULT create_name (DIR *dj, const char **path);
FRESULT follow_path ( DIR *dj, BYTE *dir, const char *path);
CLUST get_clust(BYTE* dir);
BYTE check_fs(BYTE *buf, DWORD sect);

extern FRESULT dir_rewind(DIR *dj);
extern FRESULT dir_find(DIR *dj, BYTE *dir);

#ifdef __cplusplus
}
#endif

#endif

