#!/bin/bash
#########################################################################################################
##
## Name:            assemble_roms.sh
## Created:         August 2018
## Author(s):       Philip Smart
## Description:     Sharp MZ series ROM assembly tool
##                  This script takes Sharp MZ ROMS in assembler format and compiles/assembles them
##                  into a ROM file using the GLASS Z80 assembler.
##
## Credits:         
## Copyright:       (c) 2018-21 Philip Smart <philip.smart@net2net.org>
##
## History:         August 2018   - Initial script written.
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
#BUILDROMLIST="MZ80AFI rfs rfs_mrom IPL monitor_SA1510 monitor_80c_SA1510 monitor_mz-1r12 quickdisk_mz-1e05 quickdisk_mz-1e14 monitor_1Z-013A monitor_80c_1Z-013A"
BUILDROMLIST="monitor_SA1510_hiload monitor_80c_SA1510_hiload monitor_80c_SA1510 MZ80AFI monitor_SA1510 monitor_80c_SA1510 monitor_1Z-013A monitor_80c_1Z-013A IPL"
#BUILDMZFLIST="hi-ramcheck sharpmz-test"
BUILDMZFLIST="SA-5510_RFS sharpmz-test"
ASMDIR=${ROOTDIR}/software/asm
ASMTMPDIR=${ROOTDIR}/software/tmp
INCDIR=${ROOTDIR}/software/asm/include
ROMDIR=${ROOTDIR}/software/roms
MZFDIR=${ROOTDIR}/software/MZF/Common
MZBDIR=${ROOTDIR}/software/MZB/Common
BLOCKSIZELIST="128 256"

# Go through list and build image.
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
            echo "Copy ${ASMTMPDIR}/${f}.obj to ${ROMDIR}/${f}.rom"
            cp ${ASMTMPDIR}/${f}.obj ${ROMDIR}/${f}.rom
        else
            # Build standard MZF files for inclusion in the SD Drive.
            echo "Copy ${ASMTMPDIR}/${f}.obj to ${MZFDIR}/${f}.MZF"
            cp ${ASMTMPDIR}/${f}.obj ${MZFDIR}/${f}.MZF

            # Create sectored versions of file for inclusion into the ROM Drives.
            for BLOCKSIZE in ${BLOCKSIZELIST}
            do
                FILESIZE=$(stat -c%s "${ASMTMPDIR}/${f}.obj")
                if [ $((${FILESIZE} % ${BLOCKSIZE})) -ne 0 ]; then
                    FILESIZE=$(( ((${FILESIZE} / ${BLOCKSIZE})+1 ) * ${BLOCKSIZE} ))
                fi

                dd if=/dev/zero ibs=1 count=${FILESIZE} 2>/dev/null | tr "\000" "\377" > "${MZBDIR}/${f}.${BLOCKSIZE}.bin"
                dd if="${ASMTMPDIR}/${f}.obj" of="${MZBDIR}/${f}.${BLOCKSIZE}.bin" conv=notrunc 2>/dev/null
            done
        fi
    fi
done


