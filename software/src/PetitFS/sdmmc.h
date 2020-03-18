/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            sdmmc.c
// Created:         March 2020
// Author(s):       ChaN (framework), Philip Smart (Sharp MZ80A/RFS customisation)
// Description:     Low level disk interface module include file.
//                  Functionality to enable connectivity between the PetitFS ((C) ChaN) and the RFS
//                  subsystem of the Sharp MZ80A for SD drives. This module provides the public
//                  interfaces to interact with the hardware.
//
// Credits:         
// Copyright:       (C) 2013, ChaN, all rights reserved - framework.
// Copyright:       (C) 2020 Philip Smart <philip.smart@net2net.org>
//
// History:         March 2020   - Initial development.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// This source file is free software: you can redistribute it and#or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
/////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _SDMMC_H
#define _SDMCC_H

#ifdef __cplusplus
extern "C" {
#endif

#include "pff.h"


/* Status of Disk Functions */
typedef BYTE	DSTATUS;


/* Results of Disk Functions */
typedef enum {
	RES_OK = 0,		/* 0: Function succeeded */
	RES_ERROR,		/* 1: Disk error */
	RES_NOTRDY,		/* 2: Not ready */
	RES_PARERR		/* 3: Invalid parameter */
} DRESULT;


/*---------------------------------------*/
/* Prototypes for disk control functions */

DSTATUS disk_initialize (void);
DRESULT disk_readp (BYTE* buff, DWORD sector, UINT offser, UINT count);
DRESULT disk_writep (const BYTE* buff, DWORD sc);

#define STA_NOINIT		0x01	/* Drive not initialized */
#define STA_NODISK		0x02	/* No medium in the drive */

#ifdef __cplusplus
}
#endif

#endif	/* _SDMMC_H */
