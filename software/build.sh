#!/bin/bash

ROOT_DIR=/dvlp/Projects/dev/github/MZ80A_RFS/
SW_DIR=${ROO_DIR}/software
PROCESS_MZF_FILES=0
if [ "x$1" = '-m' ]; then
	PROCESS_MZF_FILES=1
fi


(
cd $SW_DIR
tools/assemble_rfs.sh
if [ $? != 0 ]; then
	echo "TZFS assembly failed..."
	exit 1
fi
tools/assemble_roms.sh
if [ $? != 0 ]; then
	echo "ROMS assembly failed..."
	exit 1
fi
tools/assemble_cpm.sh
if [ $? != 0 ]; then
	echo "CPM assembly failed..."
	exit 1
fi

# Only needed if the program source tree changes, takes too long to run on every build!
if [ ${PROCESS_MFZ_FILES} != 1 ]; then
	tools/processMZFfiles.sh
	if [ $? != 0 ]; then
		echo "Failed to process MZF files into sectored variants...."
		exit 1
	fi
fi
tools/make_roms.sh
if [ $? != 0 ]; then
	echo "ROM disk assembly failed..."
	exit 1
fi
tools/make_cpmdisks.sh
if [ $? != 0 ]; then
	echo "CPM disks assembly failed..."
	exit 1
fi
tools/make_sdcard.sh
if [ $? != 0 ]; then
	echo "SD card assembly failed..."
	exit 1
fi
)
if [ $? != 0 ]; then
	exit 1
fi
echo "Done!"
