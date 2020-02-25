#!/bin/bash

ROOTDIR=/dvlp/Projects/dev/github
MZFDIR=${ROOTDIR}/MZF
MZBDIR=${ROOTDIR}/MZB

ls -l *.MZF *.mzf | sed 's/  / /g' | sed 's/  / /g' | cut -d' ' -f5,9- > /tmp/filelist

IFS=' '; while read -r FSIZE FNAME;
do
  TNAME=`echo $FNAME | sed 's/mzf/MZF/g'`
  if [ "$FNAME" != "$TNAME" ]; then
      mv "$FNAME" "$TNAME"
  fi
  for BLOCKSIZE in 256 512 1024 2048 4096
  do
      for SECTORSIZE in `seq -s ' ' ${BLOCKSIZE} ${BLOCKSIZE} 65536`
      do
        BASE=`basename "$TNAME" .MZF`
        if [ `echo ${FSIZE} - ${SECTORSIZE}   | bc` -le 0 ];
        then
            echo $BASE $TNAME $SECTORSIZE
            dd if=/dev/zero ibs=1 count=$SECTORSIZE 2>/dev/null | tr "\000" "\377" > "${MZBDIR}/$BASE.${BLOCKSIZE}.bin"
            dd if="${MZFDIR}/$TNAME" of="${MZBDIR}/$BASE.${BLOCKSIZE}.bin" conv=notrunc 2>/dev/null
            break;
        fi
      done
  done
done </tmp/filelist

