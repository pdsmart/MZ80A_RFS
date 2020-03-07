#!/bin/bash
#########################################################################################################
##
## Name:            make_cpmdisks.sh
## Created:         January 2020
## Author(s):       Philip Smart
## Description:     Script to build CPM Disks for the MZ80A
##                  This is a very basic script to assemble all the CPM source disks into a format
##                  which can be read by the MZ80A version of CPM.
##                  The source is composed of directories of actual original CPM disk contents which have
##                  been assembled or copied from original floppies by people on the internet.
##                  Credit goes to Grant Searle for the CPM_MC series of disks which can be found on his
##                  multicomputer project and to the various CPM archives on the net.
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

# These two variables configure which CPM images and disks to build. If only 1 CPM_RFS ROM Drive is needed,
# remove it fro the lists.
#BUILDCPMLIST="cpm22 CPM_RFS_1"
BUILDCPMLIST="cpm22 CPM_RFS_1 CPM_RFS_2"
#SOURCEDIRS="CPM_RFS_[1] CPM[0-9][0-9]_* CPM_MC_5 CPM_MC_C? CPM_MC_D? CPM_MC_E? CPM_MC_F? CPM[0-9][0-9]_MZ800*"
SOURCEDIRS="CPM_RFS_[1-2] CPM[0-9][0-9]_* CPM_MC_5 CPM_MC_C? CPM_MC_D? CPM_MC_E? CPM_MC_F? CPM[0-9][0-9]_MZ800*"

ROOTDIR=`realpath ../../MZ80A_RFS`
CPM_PATH=${ROOTDIR}/software/CPM
ROMDIR=${ROOTDIR}/software/roms                     # Compiled or source ROM files.
MZFDIR=${ROOTDIR}/software/MZF                      # MZF Format source files.
HDRDIR=${ROOTDIR}/software/hdr                      # MZF Header directory for building images.
MZBDIR=${ROOTDIR}/software/MZB                      # MZF Binary sectored output files to go into ROMS.
DISKSDIR=${ROOTDIR}/software/disks                  # MZF Binary sectored output files to go into ROMS.
ROMRFSDIR=${ROOTDIR}/software/CPM/ROMRFS/RAW        # ROM RFS Drive raw image.
FD1M44_PATH=${CPM_PATH}/1M44
FD1M44_CYLS=80
FD1M44_HEADS=2
FD1M44_SECTORS=36
FD1M44_GAP3=78
FD1M44_INTERLEAVE=4
ROMRFS_PATH=${CPM_PATH}/ROMRFS
ROMRFS_CYLS=15
ROMRFS_HEADS=1
ROMRFS_SECTORS=128
ROMRFS_GAP3=78
ROMRFS_INTERLEAVE=1
#BLOCKSIZELIST="256 512 1024 4096"                  # List of required output files in target RFS sector size.
BLOCKSIZELIST="128 256"                             # List of required output files in target RFS sector size.
MAXIMAGESIZE=524288                                 # Largest expected image size (generally 1 ROM less 16K Rom Banks).

echo "Creating CPM Disks from all the directories in:$CPM_PATH} matching this filter:${SOURCEDIRS}.."
(cd ${CPM_PATH}
 rm -f ${ROMRFS_PATH}/RAW/*.RAW
 rm -f ${FD1M44_PATH}/RAW/*.RAW
 rm -f ${FD1M44_PATH}/DSK/*.DSK
 for src in ${SOURCEDIRS}
 do
     # Different processing for the ROM RFS drives.
     if [[ ${src} == "CPM_RFS"* ]]; then

         # If the directory exists then build the ROM Drive image.
         if [ -d ${src} ]; then
 
             # Print out useful information so capactity can be seen on the ROM drive.
             echo "Building ROM Drive:${src}...Size:`du -sh --apparent-size ${src} | cut -f1`, Dir Entries:`ls -l ${src} | wc -l`"

             # Copy a blank image to create the new disk.
             cp ${CPM_PATH}/BLANKFD/BLANK_240K.RAW ${ROMRFS_PATH}/RAW/${src}.RAW;
         
             # Copy the CPM files from the linux filesystem into the CPM Disk under the CPM filesystem.
             cpmcp -f MZ80A-RFS ${ROMRFS_PATH}/RAW/${src}.RAW ${CPM_PATH}/${src}/*.* 0:
         fi
     else
         # Place size of disk in the name, useful when using the Floppy Emulator.
         NEWDSKNAME=`echo ${src} | sed 's/_/_1M44_/'`

         # Copy a blank image to create the new disk.
         cp ${CPM_PATH}/BLANKFD/BLANK_1M44.RAW ${FD1M44_PATH}/RAW/${NEWDSKNAME}.RAW;
     
         # Copy the CPM files from the linux filesystem into the CPM Disk under the CPM filesystem.
         cpmcp -f MZ80A-1440 ${FD1M44_PATH}/RAW/${NEWDSKNAME}.RAW ${CPM_PATH}/${src}/*.* 0:
     
         # Convert the raw image into an Extended DSK format suitable for writing to a Floppy or using with the Lotharek HxC Floppy Emulator.
         samdisk copy ${FD1M44_PATH}/RAW/${NEWDSKNAME}.RAW ${FD1M44_PATH}/DSK/${NEWDSKNAME}.DSK --cyls=${FD1M44_CYLS} --head=${FD1M44_HEADS} --gap3=${FD1M44_GAP3} --sectors=${FD1M44_SECTORS} --interleave=${FD1M44_INTERLEAVE}
     fi
 done
)

# Create the CPM boot image and Drive images.
echo "Building CPM images..."
> /tmp/filelist
for f in ${BUILDCPMLIST}
do
    if [ -f "${ROMDIR}/${f}.rom" ]; then
        CPMIMAGE="${ROMDIR}/${f}.rom"
    elif [ -f "${DISKSDIR}/${f}.RAW" ]; then
        CPMIMAGE="${DISKSDIR}/${f}.RAW"
    elif [ -f "${ROMRFSDIR}/${f}.RAW" ]; then
        CPMIMAGE="${ROMRFSDIR}/${f}.RAW"
    else
        CPMIMAGE=""
        echo "ALERT! ALERT! Couldnt find CPM image:${f}.RAW, not creating MZF file!"
    fi

    if [ "${CPMIMAGE}" != "" ]; then
        # Building is just a matter of concatenating together the heaader and the rom image.
        cat "${HDRDIR}/${f}.HDR" "${CPMIMAGE}" > "${MZFDIR}/${f}.MZF"

        # Place the name of the file into the MZF list so that we create an MZF format binary from this image.
        (cd ${MZFDIR}; ls -l ${f}.MZF ${f}.mzf 2>/dev/null | sed 's/  / /g' | sed 's/  / /g' | cut -d' ' -f5,9- >> /tmp/filelist 2>/dev/null)
    fi
done

# Build sectored images of the CPM Boot images and rom drives as they need to be stored in ROM in the RFS.
IFS=' '; while read -r FSIZE FNAME;
do
  TNAME=`echo $FNAME | sed 's/mzf/MZF/g'`
  if [ "$FNAME" != "$TNAME" ]; then
      mv "$FNAME" "$TNAME"
  fi
  for BLOCKSIZE in ${BLOCKSIZELIST}
  do
      for SECTORSIZE in `seq -s ' ' ${BLOCKSIZE} ${BLOCKSIZE} ${MAXIMAGESIZE}`
      do
        BASE=`basename "$TNAME" .MZF`
        if [ `echo ${FSIZE} - ${SECTORSIZE}   | bc` -le 0 ];
        then
            echo "Generating sectored MZF image: $BASE $TNAME $SECTORSIZE to target:${MZBDIR}/$BASE.${BLOCKSIZE}.bin"
            dd if=/dev/zero ibs=1 count=$SECTORSIZE 2>/dev/null | tr "\000" "\377" > "${MZBDIR}/${BASE}.${BLOCKSIZE}.bin"
            dd if="${MZFDIR}/$TNAME" of="${MZBDIR}/${BASE}.${BLOCKSIZE}.bin" conv=notrunc 2>/dev/null
            break;
        fi
      done
  done
done </tmp/filelist

ls ${ROMRFS_PATH}/RAW/ ${FD1M44_PATH}/DSK/
echo "Done, all EDSK images can be found in:${ROMRFS_PATH}/ & ${FD1M44_PATH}."

exit 0
