;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cpm22-bios.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     CPM BIOS for CPM v2.23 on the Sharp MZ80A with the Rom Filing System.
;-                  Most of the code is stored in the ROM based CBIOS which is part of the
;-                  Rom Filing System upgrade. Declarations in this file are for tables
;-                  which need to reside in RAM.
;-
;- Credits:         Some of the comments and parts of the deblocking/blocking algorithm come from the
;                   Z80-MBC2 project, (C) SuperFabius.
;- Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
;-
;- History:         January 2020 - Initial creation.
;-
;--------------------------------------------------------------------------------------------------------
;- This source file is free software: you can redistribute it and-or modify
;- it under the terms of the GNU General Public License as published
;- by the Free Software Foundation, either version 3 of the License, or
;- (at your option) any later version.
;-
;- This source file is distributed in the hope that it will be useful,
;- but WITHOUT ANY WARRANTY; without even the implied warranty of
;- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;- GNU General Public License for more details.
;-
;- You should have received a copy of the GNU General Public License
;- along with this program.  If not, see <http://www.gnu.org/licenses/>.
;--------------------------------------------------------------------------------------------------------

            ORG     CPMBIOS            

;------------------------------------------------------------------------------------------------------------
; DISK PARAMETER HEADER
;
; Disk parameter headers for disk 0 to 3                                      
;                                                                             
; +-------+------+------+------+----------+-------+-------+-------+
; |  XLT  | 0000 | 0000 | 0000 |DIRBUF    | DPB   | CSV   | ALV   |
; +------+------+------+-------+----------+-------+-------+-------+      
;   16B     16B    16B    16B    16B        16B     16B     16B
;
; -XLT    Address of the logical-to-physical translation vector, if used for this particular drive,
;         or the value 0000H if no sector translation takes place (that is, the physical and
;         logical sectornumbers are the same). Disk drives with identical sector skew factors share
;         the same translatetables.
; -0000   Scratch pad values for use within the BDOS, initial value is unimportant.
; -DIRBUF Address of a 128-byte scratch pad area for directory operations within BDOS. All DPHs
;         address the same scratch pad area. 
; -DPB    Address of a disk parameter block for this drive. Drives with identical disk characteristics
;         address the same disk parameter block.
; -CSV    Address of a scratch pad area used for software check for changed disks. This address is
;         different for each DPH.
; -ALV    Address of a scratch pad area used by the BDOS to keep disk storage allocation information.
;         This address is different for each DPH.
;------------------------------------------------------------------------------------------------------------
DPBASE:     DW      0000H, 0000H, 0000H, 0000H, CDIRBUF, DPBLOCK1, CSV0, ALV0 
            DW      0000H, 0000H, 0000H, 0000H, CDIRBUF, DPBLOCK1, CSV1, ALV1 
            DW      0000H, 0000H, 0000H, 0000H, CDIRBUF, DPBLOCK2, CSV2, ALV2 
            DW      0000H, 0000H, 0000H, 0000H, CDIRBUF, DPBLOCK2, CSV3, ALV3 

            ; NB. The Disk Parameter Blocks are stored in CBIOS ROM to save RAM space.

;------------------------------------------------------------------------------------------------------------
; CPN Disk work areas.
;------------------------------------------------------------------------------------------------------------
CDIRBUF:    DS      128                                                  ; scratch directory area
CSV0:       DS      32                                                   ; (DRM + 1)/4 = scratch area for drive 0.
ALV0:       DS      (720/8)+1                                            ; (DSM/8) + 1 = allocation vector 0 NB.Set to largest DSM declared in DPB tables as drives can be switched.
CSV1:       DS      32                                                   ; scratch area for drive 1.
ALV1:       DS      (720/8)+1                                            ; allocation vector 1
CSV2:       DS      32                                                   ; scratch area for drive 2.
ALV2:       DS      (720/8)+1                                            ; allocation vector 2
CSV3:       DS      32                                                   ; scratch area for drive 3.
ALV3:       DS      (720/8)+1                                            ; allocation vector 3

            ALIGN_NOPS  CBIOSDATA
