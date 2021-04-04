#!/bin/bash
#########################################################################################################
##
## Name:            processMZFfiles.sh
## Created:         August 2018
## Author(s):       Philip Smart
## Description:     Sharp MZ series MZF sectoring tool
##                  This is a very basic tool which takes MZF images and resizes them to the correct
##                  sector size used in the RFS Flash Roms. It currently generates many sector size
##                  variants and the packaging tool make_roms.sh chooses the correct sector size 
##                  according to its configuration.
##
## Credits:         
## Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
##
## History:         January 2020   - Initial script written.
##                  March 2021     - Small updates to pull programs from machine model sorted directories.
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

ROOTDIR=../../MZ80A_RFS/
MZFDIR=${ROOTDIR}/software/MZF
MZBDIR=${ROOTDIR}/software/MZB
#BLOCKSIZELIST="256 512 1024 2048 4096"
BLOCKSIZELIST="128 256"

# Build list of files to process.
for SUBDIR in Common MZ-80A MZ-80K MZ-700 MZ-800 MZ-1500 MZ-2000 MZ-80B 
do
    cd ${MZFDIR}
    ls -l ${SUBDIR}/*.MZF ${SUBDIR}/*.mzf 2>/dev/null |\
           	sed 's/  / /g' | sed 's/  / /g' | cut -d' ' -f5,9- > /tmp/filelist.tmp 2>/dev/null
    if [ $# = 1 ]; then
        cat /tmp/filelist.tmp | grep $1 > /tmp/filelist
    else
        cat /tmp/filelist.tmp > /tmp/filelist
    fi
    cd ..
    
    # Clear out the old staging directory. Checks to ensure the variable has value otherwise delete could take place in root!
    mkdir -p ${MZBDIR}/${SUBDIR}
    if [ "x${MZBDIR}/${SUBDIR}" != "x" ]; then
        echo "Clearing directory:${SUBDIR}..."
        rm -f ${ROOTDIR}/software/MZB/${SUBDIR}/*
    fi
    
    IFS=' '; while read -r FSIZE FNAME;
    do
      FDIRNAME=`dirname ${FNAME}`
      FILENAME=`basename ${FNAME}`
      TNAME=`echo $FILENAME | sed 's/mzf/MZF/g'`
      if [ "${FILENAME}" != "${TNAME}" ]; then
          mv "${FILENAME}" "${TNAME}"
      fi
      set +x
      for BLOCKSIZE in ${BLOCKSIZELIST}
      do
          for SECTORSIZE in `seq -s ' ' ${BLOCKSIZE} ${BLOCKSIZE} 524288`
          do
            BASE=`basename "$TNAME" .MZF`
            if [ `echo ${FSIZE} - ${SECTORSIZE}   | bc` -le 0 ];
            then
                echo $BASE $TNAME $SECTORSIZE
                dd if=/dev/zero ibs=1 count=$SECTORSIZE 2>/dev/null | tr "\000" "\377" > "${MZBDIR}/${FDIRNAME}/${BASE}.${BLOCKSIZE}.bin"
                dd if="${MZFDIR}/${FDIRNAME}/$TNAME" of="${MZBDIR}/${FDIRNAME}/${BASE}.${BLOCKSIZE}.bin" conv=notrunc 2>/dev/null
                break;
            fi
          done
      done
    done </tmp/filelist
done
