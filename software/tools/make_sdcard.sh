#!/bin/bash
#########################################################################################################
##
## Name:            make_sdcard.sh
## Created:         August 2018
## Author(s):       Philip Smart
## Description:     Sharp MZ series SD Card Packaging tool
##                  This is a very basic script to package programs into images for writing onto an
##                  SD Card as used in the Rom Filing System. The image is comprised of several parts,
##                  ie. <RFS IMAGE> + <CPM DISK IMAGE 0> .. <CPM DIK IMAGE n>.
##
## Credits:         
## Copyright:       (c) 2020-21 Philip Smart <philip.smart@net2net.org>
##
## History:         March 2020   - Initial script written.
##                  March 2021   - Updated the file list and filter out files stored in the ROM Drives.
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

ROOTDIR=../../MZ80A_RFS
MZF_PATH=${ROOTDIR}/software/MZF
TOOL_DIR=${ROOTDIR}/software/tools
IMAGE_DIR=${ROOTDIR}/software/roms
CPM_DIR=${ROOTDIR}/software/CPM/SDC16M/RAW
SDTOOL=${TOOL_DIR}/sdtool
RFS_IMAGE_FILE=${IMAGE_DIR}/SHARP_MZ80A_RFS_IMAGE_
RFS_IMAGE_EXT=img
RFS_IMAGE_DRIVES=10
RFS_IMAGE_DRIVE_LIST=`seq -s ' ' 0 $((${RFS_IMAGE_DRIVES}-1))`
CPM_IMAGE_FILES="SDCDISK0.RAW SDCDISK1.RAW SDCDISK2.RAW SDCDISK3.RAW SDCDISK4.RAW SDCDISK5.RAW SDCDISK6.RAW"
SD_IMAGE_FILE=${IMAGE_DIR}/SHARP_MZ80A_RFS_CPM_IMAGE_1.img
ROM_LIST_FILE=/tmp/ROMLIST
MZFTOOL=${ROOTDIR}/software/tools/mzftool.pl

# Function to add a given file/type into an RFS Drive.
function addFileToImage
{
    # Parameters.
    local DRIVENO=$1
    local FILETYPE=$2
    local FILTER=$3
    local FILENAME=$4
    local result=0

    # Identify type of file.
    ${MZFTOOL} --command=IDENT --mzffile=${FILENAME} >/dev/null
    ft=$?

    # Use the File Type and ROM File List to filter out duplicates.
    #
    if [ ${FILETYPE} == $ft ]; then
        grep `basename "${FILENAME}" .MZF` ${ROM_LIST_FILE} > /dev/null
        if [ $? -eq 1 -o ${FILTER} -eq 0 ]; then

            # Filter out CPM ROM Drive images.
            if [[ "${FILENAME}" != *CPM22-DRV* ]] && [[ "${FILENAME}" != *CPM_RFS_* ]]; then
                echo "Adding ${FILENAME} to RFS Drive:${DRIVENO}..."
                ${SDTOOL} --image ${RFS_IMAGE_FILE}${DRIVENO}.${RFS_IMAGE_EXT} --add ${FILENAME}
                result=$?
                if [ $result -ne 0 ]; then
                    if [ $result = 60 ]; then
                        result=10
                    else
                        echo "Failed to add:${FILENAME} into the RFS Drive Image:${RFS_IMAGE_FILE}${DRIVENO}.${RFS_IMAGE_EXT}, aborting."
                        result=11
                    fi
                fi
            fi
        fi
    else
        result=1
    fi
    return $result
}

# Function to add a directory of files belonging to a machine type to a given RFS image. Machine code files are added to the requested
# image, BASIC are added onto drives 7..9 according to type.
#
function addMachineFiles
{
    # Parameters.
    local DRIVENO=$1
    local SRCDIR=$2
    local FILTER=$3
    local result=0

    for f in `(cd ${MZF_PATH}/${SRCDIR}; ls *.MZF)`
    do
        addFileToImage ${DRIVENO} 1 ${FILTER} ${MZF_PATH}/${SRCDIR}/${f}
        result=$?
        if [[ ${result} -eq 1 ]] && [[ "${SRCDIR}" = "MZ-80A" ]]; then
            addFileToImage 5 2 ${FILTER} ${MZF_PATH}/${SRCDIR}/${f}
            result=$?
        fi
        if [[ ${result} -eq 1 ]] && [[ "${SRCDIR}" = "MZ-80K" ]]; then
            addFileToImage 6 2 ${FILTER} ${MZF_PATH}/${SRCDIR}/${f}
            result=$?
        fi
        if [[ ${result} -eq 1 ]] && [[ "${SRCDIR}" = "MZ-700" ]]; then
            addFileToImage 7 5 ${FILTER} ${MZF_PATH}/${SRCDIR}/${f}
            result=$?
        fi
        if [[ ${result} -eq 1 ]] && [[ "${SRCDIR}" = "MZ-800" ]]; then
            addFileToImage 7 5 ${FILTER} ${MZF_PATH}/${SRCDIR}/${f}
            result=$?
        fi
        if [ ${result} -ne 0 -a ${result} -ne 1 ]; then
            echo "Failed to add file:${MZF_PATH}/${SRCDIR}/${f} to Drive:0, aborting for manual check."
            result=1
        fi
    done
    return $result
}

# Initialise the target SD image.
> ${SD_IMAGE_FILE}

# Create the initial RFS drive images.
for d in ${RFS_IMAGE_DRIVE_LIST}
do
    ${SDTOOL} --image ${RFS_IMAGE_FILE}${d}.${RFS_IMAGE_EXT} --create
    if [ $? != 0 ]; then
        echo "Failed to create RFS Drive Image:${RFS_IMAGE_FILE}${d}.${RFS_IMAGE_EXT}, aborting."
        exit 1
    fi
done

# There are upto 10 RFS Drives so the software is apportioned as follows:
# Drive     Description
# -----     -----------
#   0       Common and MZ-80A Machine Code programs. 
#   1       MZ-80K Machine Code programs. 
#   2       MZ-700 Machine Code programs. 
#   3       MZ-800 Machine Code programs. 
#   3       MZ-1500 Machine Code programs. 
#   4       MZ-2000 Machine Code programs. 
#   4       MZ-80B Machine Code programs. 
#   5       BASIC programs, type 2 (MZ80A)
#   6       BASIC programs, type 2 (MZ80K)
#   7       BASIC programs, type 5 (MZ700/800) 
#   8       Other programs.
#   9       Other programs. 
#
# Files are filtered out if they already exist in the Flash RAMS. The script make_roms.sh creates
# a list of files it adds into the Flash RAMS which is used by this script.
# NB: A maximum of 256 files can be added due to the limit of the RFS directory.
#
addMachineFiles 0 Common 0
RESULT=$?
if [ ${RESULT} -eq 0 ]; then
    addMachineFiles 0 MZ-80A 1
    RESULT=$?
fi
if [ ${RESULT} -eq 0 ]; then
    addMachineFiles 1 MZ-80K 1
    RESULT=$?
fi
if [ ${RESULT} -eq 0 ]; then
    addMachineFiles 2 MZ-700 1
    RESULT=$?
fi
if [ ${RESULT} -eq 0 ]; then
    addMachineFiles 3 MZ-800 1
    RESULT=$?
fi
if [ ${RESULT} -eq 0 ]; then
    addMachineFiles 3 MZ-1500 1
    RESULT=$?
fi
if [ ${RESULT} -eq 0 ]; then
    addMachineFiles 4 MZ-2000 1
    RESULT=$?
fi
if [ ${RESULT} -eq 0 ]; then
    addMachineFiles 4 MZ-80B 1
    RESULT=$?
fi
if [ ${RESULT} -ne 0 ]; then
    echo "Aborting due to ealier errors..."
    exit 1
fi

# Confirmation listing of the drives and contents.
IFS=" "; for d in ${RFS_IMAGE_DRIVE_LIST}
do
    echo "RFS Drive: ${RFS_IMAGE_FILE}${d}.${RFS_IMAGE_EXT}"
    ${SDTOOL} --image ${RFS_IMAGE_FILE}${d}.${RFS_IMAGE_EXT} --list-dir
done

# Concatenate the RFS and CPM images to make a final SD card image.
#
IFS=" "; for d in ${RFS_IMAGE_DRIVE_LIST}
do
    echo "Adding RFS Drive Image:${RFS_IMAGE_FILE}${d}.${RFS_IMAGE_EXT} to start of SD Card image."
    cat ${RFS_IMAGE_FILE}${d}.${RFS_IMAGE_EXT} >> ${SD_IMAGE_FILE}
done
# Pad the file to 0x10000000 before adding CPM images. This takes into account the RFS Drives plus padding to a round address.
truncate -s 268435456 ${SD_IMAGE_FILE}
IFS=" "; for f in ${CPM_IMAGE_FILES}
do
    echo "Adding CPM Drive Image:${f} to SD Card image."
    cat ${CPM_DIR}/${f} >> ${SD_IMAGE_FILE}
done
echo "SD Card image generated, file:${SD_IMAGE_FILE}"
echo ""
echo ""
echo "Using a suitable tool, such as dd under Linux, copy the SD Card image onto an SD Card."
echo "ie. dd if=${SD_IMAGE_FILE} of=/dev/sdd bs=512"
echo "No disk partitioning is needed as the SDFS image starts at sector 0 on the SD Card."
echo "Once the image has been copied, place into the SD Card Reader on the RFS Board."

exit 0
