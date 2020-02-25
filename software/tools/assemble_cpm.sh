#!/bin/bash
#########################################################################################################
##
## Name:            assemble_cpm.sh
## Created:         August 2018
## Author(s):       Philip Smart
## Description:     Sharp MZ series CPM assembly tool
##                  This script builds a CPM version compatible with the MZ-80A RFS system.
##
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

ROOTDIR=../../MZ80A_RFS
TOOLDIR=${ROOTDIR}/software/tools
JARDIR=${ROOTDIR}/software/tools
ASM=glass.jar
BUILDROMLIST="cbios cbios_bank1 cbios_bank2 cbios_bank3 cbios_bank4 cpm22"
BUILDMZFLIST=""
BUILDCPMLIST="cpm22 CPM_RFS_1"
ASMDIR=${ROOTDIR}/software/asm
ASMTMPDIR=${ROOTDIR}/software/tmp
INCDIR=${ROOTDIR}/software/asm/include
ROMDIR=${ROOTDIR}/software/roms                     # Compiled or source ROM files.
MZFDIR=${ROOTDIR}/software/MZF                      # MZF Format source files.
HDRDIR=${ROOTDIR}/software/hdr                      # MZF Header directory for building images.
MZBDIR=${ROOTDIR}/software/MZB                      # MZF Binary sectored output files to go into ROMS.
DISKSDIR=${ROOTDIR}/software/disks                  # MZF Binary sectored output files to go into ROMS.
#BLOCKSIZELIST="256 512 1024 4096"                  # List of required output files in target RFS sector size.
BLOCKSIZELIST="128 256"                             # List of required output files in target RFS sector size.
MAXIMAGESIZE=524288                                 # Largest expected image size (generally 1 ROM less 16K Rom Banks).

# Go through list and build images.
#
for f in ${BUILDROMLIST} ${BUILDMZFLIST}
do
    echo "Assembling: $f..."

    # Assemble the source.
    echo "java -jar ${JARDIR}/${ASM} ${ASMDIR}/${f}.asm ${ASMTMPDIR}/${f}.obj ${ASMTMPDIR}/${f}.sym"
    java -jar ${JARDIR}/${ASM} ${ASMDIR}/${f}.asm ${ASMTMPDIR}/${f}.obj ${ASMTMPDIR}/${f}.sym -I ${INCDIR}

    # On successful compile, perform post actions else go onto next build.
    #
    if [ $? = 0 ]
    then
        # The object file is binary, no need to link, copy according to build group.
        if [[ ${BUILDROMLIST} = *"${f}"* ]]; then
            echo "Copy ${ASMDIR}/${f}.obj to ${ROMDIR}/${f}.rom"
            cp ${ASMTMPDIR}/${f}.obj ${ROMDIR}/${f}.rom
        else
            echo "Copy ${ASMDIR}/${f}.obj to ${MZFDIR}/${f}.mzf"
            cp ${ASMTMPDIR}/${f}.obj ${MZFDIR}/${f}.mzf
        fi
    fi
done

# Create the CPM boot image and Drive images.
echo "Building CPM images..."
for f in ${BUILDCPMLIST}
do
    if [ -f "${ROMDIR}/${f}.rom" ]; then
        CPMIMAGE="${ROMDIR}/${f}.rom"
    elif [ -f "${DISKSDIR}/${f}.RAW" ]; then
        CPMIMAGE="${DISKSDIR}/${f}.RAW"
    fi

    # Building is just a matter of concatenating together the heaader and the rom image.
    cat "${HDRDIR}/${f}.HDR" "${CPMIMAGE}" > "${MZFDIR}/${f}.MZF"
done

# Now go and pack the images into sectored MZF files ready for adding directly into a ROM output image.
cd ${MZFDIR}
ls -l *.MZF *.mzf 2>/dev/null | sed 's/  / /g' | sed 's/  / /g' | cut -d' ' -f5,9- > /tmp/filelist.tmp 2>/dev/null
cat /tmp/filelist.tmp | grep -i cpm > /tmp/filelist
cd ..

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

