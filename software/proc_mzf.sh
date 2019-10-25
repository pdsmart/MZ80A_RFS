#!/bin/bash

ls -l *.MZF *.mzf | sed 's/  / /g' | sed 's/  / /g' | sed 's/mzf/MZF/g'| cut -d' ' -f5,9 > /tmp/filelist

IFS=' '; while read -r FSIZE FNAME;
do
  for BLOCKSIZE in 2048 4096
  do
    BASE=`basename $FNAME .MZF`
    ROUNDEDSIZE=0
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 2048   | bc` -le 0 ]; then ROUNDEDSIZE=2048; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 4096   | bc` -le 0 ]; then ROUNDEDSIZE=4096; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 6144   | bc` -le 0 ]; then ROUNDEDSIZE=6144; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 8192   | bc` -le 0 ]; then ROUNDEDSIZE=8192; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 10240  | bc` -le 0 ]; then ROUNDEDSIZE=10240; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 12288  | bc` -le 0 ]; then ROUNDEDSIZE=12288; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 14336  | bc` -le 0 ]; then ROUNDEDSIZE=14336; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 16384  | bc` -le 0 ]; then ROUNDEDSIZE=16384; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 18432  | bc` -le 0 ]; then ROUNDEDSIZE=18432; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 20480  | bc` -le 0 ]; then ROUNDEDSIZE=20480; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 22528  | bc` -le 0 ]; then ROUNDEDSIZE=22528; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 24576  | bc` -le 0 ]; then ROUNDEDSIZE=24576; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 26624  | bc` -le 0 ]; then ROUNDEDSIZE=26624; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 28672  | bc` -le 0 ]; then ROUNDEDSIZE=28672; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 30720  | bc` -le 0 ]; then ROUNDEDSIZE=30720; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 32768  | bc` -le 0 ]; then ROUNDEDSIZE=32768; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 34816  | bc` -le 0 ]; then ROUNDEDSIZE=34816; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 36864  | bc` -le 0 ]; then ROUNDEDSIZE=36864; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 38912  | bc` -le 0 ]; then ROUNDEDSIZE=38912; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 40960  | bc` -le 0 ]; then ROUNDEDSIZE=40960; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 43008  | bc` -le 0 ]; then ROUNDEDSIZE=43008; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 45056  | bc` -le 0 ]; then ROUNDEDSIZE=45056; fi
    if [ $ROUNDEDSIZE -eq 0 -a $BLOCKSIZE -eq 2048 -a `echo $FSIZE - 47104  | bc` -le 0 ]; then ROUNDEDSIZE=47104; fi
    if [ $ROUNDEDSIZE -eq 0 -a `echo $FSIZE - 49152  | bc` -le 0 ]; then ROUNDEDSIZE=49152; fi
    
    if [ $ROUNDEDSIZE -eq 0 ];
    then
        echo "File:$FNAME is of uncatered size:$FSIZE"
        exit 1
    fi
    echo $BASE $FNAME $ROUNDEDSIZE
    dd if=/dev/zero ibs=1 count=$ROUNDEDSIZE | tr "\000" "\377" > $BASE.$BLOCKSIZE.bin
    dd if=$FNAME of=$BASE.$BLOCKSIZE.bin conv=notrunc
  done
done </tmp/filelist

