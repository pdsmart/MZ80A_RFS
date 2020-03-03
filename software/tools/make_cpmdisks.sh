#!/bin/bash
#########################################################################################################
##
## Name:            make_cpmdisks.sh
## Created:         January 2020
## Author(s):       Philip Smart
## Description:     Script to build CPM Disks for the MZ80A
##                  This is a very basic script to assemble all the CPM source disks into a format
##                  which can be read by the MZ80A version of CPM.
##                  The source are composed of directories of actual disks assembled from the original
##                  CPM applications of packaged by people on the internet.

## Credits:         
## Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
##
## History:         January 2020   - Initial script written.
##
#########################################################################################################
## This source file is free software: you can redistribute it and#or modify
## it under the terms of the GNU General Public License as published
## by the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This source file is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
#########################################################################################################

ROOTDIR=`realpath ../../MZ80A_RFS`
CPM_PATH=${ROOTDIR}/software/CPM
SECTORSIZE=256
FD1M44_PATH=${CPM_PATH}/1M44
FD1M44_CYLS=80
FD1M44_HEADS=2
FD1M44_SECTORS=36
FD1M44_GAP3=78
FD1M44_INTERLEAVE=4

SOURCEDIRS="CPM[0-9][0-9]_* CPM_MC_5 CPM_MC_C? CPM_MC_D? CPM_MC_E? CPM_MC_F?"

echo "Creating CPM Disks from all the directories in:$CPM_PATH} matching this filter:${SOURCEDIRS}.."
(cd ${CPM_PATH}
 for src in ${SOURCEDIRS}
 do
     # Copy a blank image to create the new disk.
     cp ${CPM_PATH}/BLANKFD/BLANK_1M44.RAW ${FD1M44_PATH}/RAW/${src}.RAW;
 
     # Copy the CPM files from the linux filesystem into the CPM Disk under the CPM filesystem.
     cpmcp -f MZ80A-1440 ${FD1M44_PATH}/RAW/${src}.RAW ${CPM_PATH}/${src}/*.* 0:
 
     # Convert the raw image into an Extended DSK format suitable for writing to a Floppy or using with the Lotharek HxC Floppy Emulator.
     samdisk copy ${FD1M44_PATH}/RAW/${src}.RAW ${FD1M44_PATH}/DSK/${src}.DSK --cyls=${FD1M44_CYLS} --head=${FD1M44_HEADS} --gap3=${FD1M44_GAP3} --sectors=${FD1M44_SECTORS} --interleave=${FD1M44_INTERLEAVE}
 done
)
 echo "Done, all EDSK images can be found in:${FD1M44_PATH}."

exit 0
