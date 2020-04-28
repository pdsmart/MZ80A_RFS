## Overview

Linux and Windows are now the staple operating systems in use but years ago it all started with Digital Research creating the Control Program/Monitor (CP/M). CP/M was one of the first real operating systems for Microcomputers
providing common means to run applications across varying hardware. Any machine running CP/M has access to thousands of programs and thus started the quest to get CP/M running on the Sharp MZ80A.

A version of CP/M was created by Micro Technology for the Sharp MZ80A, but as it lacked an 80 column screen, it wasnt so useful without an upgrade. A look around showed third parties such as Kuma developed an 80 column
upgrade which you could later source from the SUC, but CP/M on the MZ80A, although mentioned in many articles is actually quite elusive to obtain in 2020. Various excellent sites such as original.sharpmz.org offer the 80K/80B/800
versions but not for the MZ80A.

I developed the 80 Column colour upgrade board and the Rom Filing System with the primary focus to realise CP/M on the MZ80A. It is very easy in the FPGA based hardware emulator project to add changes to accommodate various 
column outputs, colour or graphics, but to do it on the actual original hardware making minimal changes to a vintage machine was more of a challenge and also something of a personal desire since first owning this machine in 1983.
Most of the upgrades you see from the past require cuts and links to the original PCB which I specifically didnt want, I want to keep the original hardware as Sharp made it! The only change I make in my upgrades to the original
PCB is to socket a chip (IC8 74LS165 video shift register) which could quite easily be done if it failed in use and was replaced, that way the machine is 100% original and can be returned to it's original factory state very easily.

Thus I started to try and get CP/M working, even with a plethora of information on the net, wasnt an easy task. Firstly, obtaining Micro Technology's version of CP/M for the MZ80A proved very elusive so I fell back to the MZ80K
and MZ80B versions. I then hit upon the various odd-ball disk formats, with the MZ80A designed to read inverted data adding to the fray. Cut a long story short, I ended up deciding to write my own rom based version of the CBIOS
and blending it in with the BDOS+CCP of CP/M v2.23. This section details the information on this work accordingly.


## CP/M Boot Process

Booting CP/M occurs in two phases:
1. Using the original AFI Floppy Disk control software, read in an inverted boot sector, check it contains at 0x0000 the control code 0x02 + "IPLPRO", then pass control to the encapsulated boot loader
2. Load, starting at 0x9C00, the CCP, BDOS and CBIOS. The CBIOS now takes control and applies a different disk format and uses different FDC Controller logic (ie. re-inverts the data).

To this end I disassembled the MZ80A AFI ROM (which can be found in the repository) to understand what actions it was performing. The initial load checks to see if the disk is a bootable disk under the MZ80A. For the MZ80K the marker
for a bootable disk (besides the format being very different and not inverting the data) was for 01 + IPLPRO in the starting bytes of the first sector. For the MZ80B this was 03 + IPLPRO.

As I didnt have an MZ80A copy of CP/M I tried to get the MZ80K version to load, but the non-inverted data meant I had to convert an MZ80K boot disk into an MZ80A format. Once this was done, I tried to boot CP/M but there were
incompatibilities, for example the disk controller!! I then spent time looking at the MZ80B and MZ800 versions of Micro Technologies CP/M, which again used differing disk formats and in the end I decided the best approach would
be to build a custom CP/M and write my own CBIOS.

## CBIOS

CP/M is built from 3 distinct modules, CCP (Console Command Processor), BDOS (Basic Disk Operating System) and CBIOS (Custom Basic Input Output System). Generally CCP + BDOS are standard and the CBIOS is customised according
to the underlying hardware.

All 3 components would be bootstrapped off the floppy disk, loaded into memory (0x9C00 for the MZ80K/A) and control passed to the CBIOS which would setup the machine before handing control to the CCP. Under normal working conditions,
any loaded application would call the BDOS to perform services such as writing to the console, getting key input, disk access etc from a well defined API but if it didnt need the BDOS services it could call the CBIOS directly using
it's API and in turn could use the CCP+BDOS RAM to gain more program space. When an application completes, it jumps to vector 0x0000 initiating a Warm start involving reloading of the CCP+BDOS.

The way CPM is written it doesnt lend itself to be stored in ROM as it self modifies/uses embedded variables but for the CBIOS it is a different story. It is possible to place the CBIOS in ROM to gain more RAM and having access
to the Rom Filing System with its paged ROM banks, this is the route I took.

In order to create a CBIOS you have to provide the following API methods:

| API Method | Description                                                                        |
|------------|------------------------------------------------------------------------------------|
| BOOT       |  Cold start, initiate all hardware prior to invocation of the CCP.                 |
| WBOOT      |  Warm start, set back any hardware changes and then reload CCP+BDOS before invocation of CCP. |
| CONST      |  Console Status, see if a keyboard key entry is waiting to be read. |
| CONIN      |  Console Input, fetch a key from the keyboard, wait if non available. |
| CONOUT     |  Console Output, output a character to the screen. |
| LIST       |  List Device Output, output a character to the listing device (ie. Printer). |
| PUNCH      |  Punch Device Output, output a character to the puch device (yep, punch tape or cards were used in the 70's)! |
| READER     |  Reader Input, input a character from the Reader device (ie. paper tape)! |
| HOME       |  Move the head of the currently selected disk to Track 0. |
| SELDSK     |  Select/activate a disk. |
| SETTRK     |  Set the disk track for the next read/write operation. |
| SETSEC     |  Set the disk sector on the selected track for the next read/write operation. |
| SETDMA     |  Set the Disk Memory Address, the location where data will be read/stored. |
| READ       |  Read a disk sector. |
| WRITE      |  Write a disk sector. |
| LISTST     |  List Device Status, see if the listing device is ready to accept a new character. |
| SECTRN     |  Sector Translate, Logical to Physical sector translation to adapt to specific hardware or improve responsiveness of the disk subsystem. |

Looks a simple requirement but then you have to consider that a machine such as the MZ80A doesnt have it's own BIOS and the firmware in it's ROM when running under CP/M is relocated to 0xC000 and thus unuseable. Also the Floppy
Control Firmware is very basic and only deals with bootstrapping a disk.

A futher requirement above the basic mechanisms for character input/output CP/M provides, is that most applications expect a Smart Terminal to be sat in front of the CP/M machine to provide advanced Screen and keyboard functionality.
This would normally be in the form of a Terminal such as a DEC VT52 or VT100. As the MZ80A has it's own screen and keyboard, this smart functionality has to be written. 

Thus in order to write the CBIOS, the following firmware sub-modules need to be coded:

| Sub-Module          | Description                                                                        |
|-------------------- |------------------------------------------------------------------------------------|
| Basic Screen I/O    | The low level functions to place a character on the screen, clear the screen etc.  |
| Advanced Screen I/O | Intelligence to position display output, clear screen portions, special attributes such as Bold etc. |
| Keyboard I/O        | Scan and return keycodes, map to ASCII as required. |
| Disk I/O            | Provide facilities to read and write multiple disk sectors. |

Having previously disassembled the Sharp SA-1510 monitor I had a good starting position to provide the basic Screen and Keyboard facilities, disassembling the Floppy Disk AFI firmware provided an insite into the code required to 
read a floppy disk, more especially the short falls. The MZ80A is a 2MHz computer and does not have the speed to service the disk input/output stream, it has to rely on a piece of hardware which pages a ROM bank based on the Data Request/Ready
signal of the FDC. Thus the FDC components required significant work. For the Advanced Screen I/O, I decided to use the ANSI standard and sourced Ewen McNeill's Amstrad CPC Terminal Emulator. I initially thought it would be a simple extract and
drop in of his ANSI parser but this turned out to be a major amount of work. Sometimes the easiest option is the hardest!!

All this functionality takes space and it has been apportioned as follows:

| ROM            | Address        | Description                                                                        |
|--------------- | -------------- |------------------------------------------------------------------------------------|
| 4K MROM (relocated Monitor ROM from 0x0000 - 0x0FFF) | 0xC000 - 0xCFFF | CBIOS providing the CP/M API, initialisation routines, ROM Disk controller routines, Interrupt routines.
| 2K Paged ROM | 0xE800 - 0xEFFF, Bank 8  | Basic Sound and Melody, RTC, Keyboard and helper functionality. |
| 2k Paged ROM | 0xE800 - 0xEFFF, Bank 9  | Screen I/O and ANSI Terminal Parser. |
| 2k Paged ROM | 0xE800 - 0xEFFF, Bank 10 | SD Card Controller functionality. |
| 2k Paged ROM | 0xE800 - 0xEFFF, Bank 11 | Floppy Disk Controller functionality. |

#### *CPM Disk Drives*
As this implementation of CPM and Custom BIOS uses 3 different disk drive controllers, some of which may not be present at any one time, the drives are dynamically created within CPM during the cold boot.
The ordering of the drives is shown in the following table:

| Rom Drive #  | Present |   0       |  1      |  2      | Present  |     0       |  1        |  2       | 
|--------------|---------|-----------|---------|---------|----------|-------------|-----------|----------|
| Rom Drive    |  n/a    |           |  A      |  A,B    |  n/a     |             |  A        |  A,B     |
| Floppy Disk  |  Yes    |  A,B      |  B,C    |  C,D    |  No      |             |           |          |
| SD Card      |  Yes    |  C,D,E,F  |  D,E,F  |  E,F,G  |  Yes     |  A,B,C,D,E  |  B,C,D,E  |  C,D,E,F |
| SD Card      |  No     |           |         |         |  Yes     |             |           |          |

The limit on the number of drives is CPM (limit of 16 drives) and the amount of RAM allocated to the drives, governed by the variable 'CSVALVEND - CSVALVMEM' which is set in the CPM_Definitions.asm file in the repository. The drive
allocation is dynamic, so more memory allocated will see more drives available. The SD Card can contain 100's of 16MB SD Disk Drives, so the issue is purely RAM assigned for their use.

#### *Features*
Besides the standard BIOS functionality, the following features have been added to the CBIOS.

- Real Time Clock with 50mS granularity
- Interrupt driven keyboard with buffer and auto repeat.
- Tri-mode key lock, Normal, Caps Lock, Shift Lock
- Ansi Terminal Functionality
- Re-targettable Floppy Disk drives of size 1.44M, 720K & 320K
- Re-targettable ROM drives of size 240K (changeable via config)
- Re-targettable SD Card 16Mb Hard disks.
- Exit to Monitor via SHIFT+GRAPH+BREAK.


## Building CPM

Building CP/M involves assembling the Z80 Assembly language source into a machine code binary and then creating a boot disk, or in this implementations case, a ROM based CBIOS and an
MZF format bootable application which is stored in ROM.

To accomplish it you need several tools and at the moment it is quite a manual process.

## Paths

For ease of reading, the following shortnames refer to the corresponding path in this chapter.

|  Short Name      |                                                                            |
|------------------|----------------------------------------------------------------------------|
| \[\<ABS PATH>\]  | The path where this repository was extracted on your system.               |
| \<software\>     | \[\<ABS PATH>\]/MZ80A_RFS/software                                         |
| \<roms\>         | \[\<ABS PATH>\]/MZ80A_RFS/software/roms                                    |
| \<CPM\>          | \[\<ABS PATH>\]/MZ80A_RFS/software/CPM                                     |
| \<tools\>        | \[\<ABS PATH>\]/MZ80A_RFS/software/tools                                   |
| \<MZF\>          | \[\<ABS PATH>\]/MZ80A_RFS/software/MZF                                     |
| \<MZB\>          | \[\<ABS PATH>\]/MZ80A_RFS/software/MZB                                     |


## Tools

All development has been made under Linux, specifically Debian/Ubuntu. I use Windows for flashing the RAM's and using the GUI version of CP/M Tools but havent dedicated any time into building the RFS under Windows. I will in due course
create a Docker image with all necessary tools installed, but in the meantime, in order to assemble the Z80 code, the C programs and work with the CP/M software andCP/M disk images, you will need to obtain and install the following tools.

[Z80 Glass Assembler](http://www.grauw.nl/blog/entry/740/) - A Z80 Assembler for converting Assembly files into machine code.<br>
[samdisk](https://simonowen.com/samdisk/)   - A multi-os command line based low level disk manipulation tool.<br>
[cpmtools](https://www.cpm8680.com/cpmtools/) - A multi-os command line CP/M disk manipulation tool.<br>
[CPMToolsGUI](http://star.gmobb.jp/koji/cgi/wiki.cgi?page=CpmtoolsGUI) - A Windows based GUI CP/M disk manipulation tool.<br>
[z88dk](https://www.z88dk.org/forum/) - An excellent C development kit for the Z80 CPU.<br>
[sdcc](http://sdcc.sourceforge.net/) - Another excellent Small Device C compiler, the Z80 being one of its targets. z88dk provides an enhanced (for the Z80) version of this tool within its package.<br>

## Software

Building the software images can be done by cloning the [repository](https://github.com/pdsmart/MZ80A_RFS.git) and running some of the shell scripts and binaries provided.

| Script            |  Description                                                                                                             |
|------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| assemble_cpm.sh   | A shell script to build the CPM binary, the CPM MZF format application for loading via RFS and the CPM ROM Drives 0 & 1  |
| assemble_rfs.sh   | A bash script to build the Rom Filing System ROM images.                                                                 |
| assemble_roms.sh  | A bash script to build all the standard MZ80A ROMS, such as the SA-1510 monitor ROM.                                     |
| make_roms.sh      | A bash script to build the RFS ROMS suitable for programming in the 512KByte Flash RAMS. These images contain the banked RFS ROMS, the various system ROMS such as SA-1510 and all the MZF programs to be loaded by the RFS. |
| make_cpmdisks.sh  | A bash script to build a set of CPM disks, for use as Raw images in the SD Card or Rom drives and as CPC Extended Disk Formats for use in a Floppy disk emulator or copying to physical medium. |
| make_sdcard.sh    | A bash script to create an SD card image combining the RFS Image and several CPM disk drives. This image is then binary copied onto the SD card and installed into the RFS SD Card reader. |
| mzftool.pl        | A perl script to create/extract and manipulate MZF images.                                                               |
| processMZFfiles.sh| A bash script to convert a set of MZF programs into sectored images suitable for use in the Rom Filing System ROMS.      |
| sdtool            | A binary created in the src/tools repository which builds the RFS SD Card image, creating a directory and adding MZF/Binary applications into the drive image. |


The CP/M system is built in 4 parts,

    1. the cpm22.bin which contains the CCP, BDOS and a CBIOS stub.
    2. the banked CBIOS which has its primary source in a 4K ROM and 4 banked 2K ROMS. These
       are generated for adding into the RFS Banked Monitor ROM and the Banked User ROM.
    3. upto 2 (currently) Read Only CPM ROM Drive's which can be assigned to any CP/M drive
       letter.
    4. conversion of the binaries generated in 1. and 3. into sectored MZF images suitable
       for adding directly into the Rom Filing System as just another program.

All of the above are encoded into the assemble_cpm.sh bash script which can be executed as follows:

````bash
cd <software>
tools/assemble_cpm.sh
````

The script is currently set to generate 1 Read Only CPM ROM Drive. To add a second CPM ROM Drive, follows these instructions:

````bash
1. Edit the <tools>/make_cpmdisks.sh script and change the
   variable:
   from BUILDCPMLIST="cpm22 CPM_RFS_1"
   to   BUILDCPMLIST="cpm22 CPM_RFS_1 CPM_RFS_2"

   change the variable:
   from SOURCEDIRS="CPM_RFS_[1] CPM[0-9][0-9]_* CPM_MC_5 CPM_MC_C? CPM_MC_D? CPM_MC_E? CPM_MC_F? CPM[0-9][0-9]_MZ800*" to
   to   SOURCEDIRS="CPM_RFS_[1-2] CPM[0-9][0-9]_* CPM_MC_5 CPM_MC_C? CPM_MC_D? CPM_MC_E? CPM_MC_F? CPM[0-9][0-9]_MZ800*"
   
2. Create a directory (if it doesnt exist): 
   <CPM>/CPM_RFS_2

3. Fill the directory with required CPM files to be placed in the ROM.

4. Build the image by running the make_cpmdisks.sh script or as part of the sequence of commands listed below.
````

In order to use CPM, it is necessary to create the MonitorROM and USERROM images which can be programmed into the 2x512KByte Flash RAMS. Issue the following commands to build CPM along with all the RFS, ROMS and Applications in ROM:
````bash
cd <software>
tools/assemble_cpm.sh
tools/assemble_rfs.sh
tools/assemble_roms.sh
tools/make_cpmdisks.sh
tools/make_roms.sh
tools/make_sdcard.sh
````

The output of the above commands are ROM images \<roms\>/MROM_256.bin and \<roms\>/USER_ROM.256.bin which must be flashed into 512Kbyte Flash RAMS and inserted into the sockets on the
RFS adapter.

The CPM disk images can be found in \<CPM\>/1M44/RAW for the raw images or \<CPM\>/1M44/DSK for the CPC Extended format disk images. These images are built from the directories in
 \<CPM\>, each directory starting with CPM* is packaged into one 1.44MB drive image. NB. In addition, the directories are also packaged into all the other supported disks as
images in a corresponding directory, ie \<CPM\>/SDC16M for the 16MB SD Card drive image.

The SD Card image can be found in \<roms\>/SHARP_MZ80A_RFS_CPM_IMAGE_1.img which contains the RFS Disk image \<roms\>/SHARP_MZ80A_RFS_IMAGE_1.img at the start followed by
seven CPM format drive images which, as per above, are stored in \<CPM\>/SDC16M/RAW. These images are built from the directories in \<CPM\> but are manually added in to the
final images by hardcoding in the script make_cpmdisks.sh.

The applications which are stored in the ROM drives are located in the \<MZF\> directory. Copy any applications you want into this directory then issue the following command to process them into sector rounded images 
stored in the \<MZB\> directory.

````bash
cd <software>
tools/processMSFfiles.sh
````

The actual applications which are built into the ROM are selected in the \<tools\>/make_roms.sh script. This script lists all the applications required and it will pack as many as space permits into the ROM. To 
ensure your application appears in ROM, add it to the top of the list (just the filename not the .MZF extension), ie:

````bash
Edit the file <tools>/make_roms.sh
Locate the line: ROM_INCLUDE=
Below this line, add your application in the format: ROM_INCLUDE+="${MZBPATH}/<YOUR APPLICATION>.${SECTORSIZE}.bin"
ie. ROM_INCLUDE+="${MZB_PATH}/A-BASIC_SA-5510.${SECTORSIZE}.bin:"
Save the file and run the commands above to build the MonitorROM and USERROM's.
````

## Disk Formats

As I found out, there are 100's of CP/M disk formats and the Sharp series alone implements 2-3 per machine. In deciding on what format to
use for this implementation of CP/M I looked at the existing formats. Not having access to original Sharp MZ80A disks and with them being
in inverted non-standard format anyway, the MZ80B being similar to the MZ80A but slightly higher capacity, the MZ800 being a hybrid and the
MZ80K being low capacity, I opted to use standard formats for 1.44MB, 720K 3.5" Floppies, the same physical format as the Sharp MZ80A disks
and the ROM based 240K Rom Drive.

The formats I am using can be manipulated by cpmtools using the following diskdefs definitions, place the above into the diskdefs file
located with the cpmtools or CPMToolsGUI to use:

````bash
   # 320K Disk for the MZ80A - Same format as the MZ800
   # but implements a cylinder in uniform manner (ie. 1 cyl
   # = 1 track x 2(heads) where as the MZ800 implements as 
   # 160 tracks, 80 x Head 1 0->79 then 80 x Head 2 80->159.
   diskdef MZ80A-A
     seclen 256
     tracks 40
     sectrk 32
     blocksize 2048
     maxdir 64
     skew 0
     boottrk 1
     os 2.2
   end
   
   # A standard format 1.44Mb Floppy format for the MZ80A
   diskdef MZ80A-1440
     seclen 512
     tracks 80
     sectrk 36
     blocksize 2048
     maxdir 128
     skew 0
     boottrk 0
     os 2.2
   end
   
   # A standard format 720K Floppy format for the MZ80A.
   diskdef MZ80A-720
     seclen 256
     tracks 80
     sectrk 36
     blocksize 2048
     maxdir 128
     skew 0
     boottrk 0
     os 2.2
   end
   
   # A 240K Rom Filing System ROM Drive image.
   diskdef mz80a-rfs
     seclen 128
     tracks 15
     sectrk 128
     blocksize 1024
     maxdir 32
     skew 0
     boottrk 0
     os 2.2
   end

   # A 16Mb fixed disk SD Card Image.
   diskdef MZ80A-SDC16M
     seclen 512
     tracks 1024
     sectrk 32
     blocksize 8192
     maxdir 512
     skew 0
     boottrk 0
     os 2.2
   end   
````

Within CP/M these physical disk formats are represented in the disk parameter block as follows. Normally you dont need to be concerned
about these settings or the above diskdefs, just useful to know if you need to add your own custom format:

| Definition     | MZ80A 320K | Rom Filing System |  1.44MB 3.5"  |  720K 3.5"  |  16MB SD Card Image |
| SPT            | 64         |   128             |    144        |     72      |          128        |
| BSH            | 4          |   3               |    4          |     4       |          6          |
| BLM            | 15         |   7               |    15         |     15      |          63         |
| EXM            | 1          |   0               |    0          |     0       |          3          |
| DSM            | 155        |   240             |    719        |     359     |          2047       |
| DRM            | 63         |   31              |    127        |     127     |          511        |
| AL0            | 128        |   128             |    192        |     192     |          192        |
| AL1            | 0          |   0               |    0          |     0       |          0          |
| CKS            | 16         |   8               |    32         |     32      |          0          |
| OFF            | 1          |   0               |    0          |     0       |          0          |

In order to use existing Sharp CP/M programs it will be necessary to extract the programs off the disk and add to a format recognised by this implementation. To
this end, the following sections describe how to extract data off the relevant machines disks.

### Creating a CPM Disk

In my development I used a Lotharek HxC Floppy Emulator connected to a Sharp MZ80-AFI interface card. Using this arrangement it is possible to emulate any disk drive that the
Sharp MB8866 Floppy Disk Controller can talk to. This is how I arrived at and tested the 3.5" formats, as these drives are still obtainable and have sufficient capacity
for most CP/M operations.

In order to create a CP/M Disk which can be used on the Sharp MZ80A with this implementation of CP/M, you need to add the above definitions to your cpmtools diskdefs file. Once
added, either copy one of the blank images in \<CPM\>/BLANKFD to a new name and use as your target disk or create one from within CPMTools using
the disk definition. You then add required programs to the new disk which in CPMToolsGUI this is just a drag and drop procedure.

In order to use the new raw CP/M image in the Floppy Emulator or a real Floppy Disk drive, it is necessary to convert the raw image into a format that most
Floppy disk tools can read and write onto a floppy. In the case of the Lotharek Floppy Emulator, using their tool HxCFloppyEmulator v2.2.2.1 via the Load and 
Export to HFE will generate a suitable SD image to mimic a real floppy.

To convert the image, use one of the following:

    For 1.44MB Drives use:
    ./samdisk copy <RAW IMAGE FILE, ie. CPM00_SYSTEM.RAW> <DSK IMAGE FILE, ie.CPM00_SYSTEM.DSK> --cyls=80 --head=2 --gap3=78 --sectors=36 --interleave=4
    Samdisk will automatically recognise the format from the size of the file, ie. 1474560 bytes

    For 720K Drives use:
    ./samdisk copy <RAW IMAGE FILE, ie. CPM00_SYSTEM.RAW> <DSK IMAGE FILE, ie.CPM00_SYSTEM.DSK> --cyls=80 --head=2 --gap3=78 --sectors=36 --size=2 --interleave=4
    Samdisk will automatically recognise the format from the size of the file, ie. 737280 bytes

    For the MZ80A 320K Drives use:
    ./samdisk copy CPM00_320K_SYSTEM.RAW CPM00_320K_SYSTEM.DSK --cyls=40 --gap3=78 --head=2 --sectors=16
    Samdisk will automatically recognise the format from the size of the file, ie. 327680 bytes

    The RFS ROM Drive does not need conversion, the RFS functionality assumes a raw image.

    NB. Dont use Samdisk v4, it has a bug where it will place a random sector at the start of the disk. Many hours debugging were lost due to this bug. Best to use
    samdisk v3.8.8

The above samdisk commands create an Amstrad CPC Extended DSK format image which can be read and processed by Lotharek HxCFloppyEmulator or tools used to write
physical floppy disks.


### Extract MZ80A CP/M Disks

   Under construction.

### Extract MZ80K CP/M Disks

   Under construction.

### Extract MZ80B CP/M Disks

   Under construction.

### Extract MZ800 CP/M Disks

  The MZ800 series computers use a mixed format disk with the boot tracks using inverted data and the CP/M tracks using standard data. To make it worse, the ordering
  of the tracks is such that they put head 0 as track 0-39 and head 1 as track 40-79. In order to use these disks, it is best to extract the data and copy it to one of the
  formats I've created as I see no purpose in adding extra code to accommodate this strange format.

  Use samdisk to convert the EDSK (Extended DSK format created for the Amstrad CPC Machine, most MZ800 disks appear to be in this format) into a RAW image.

  ````bash
  samdisk copy <MZ800 DISK NAME>.DSK <MZ800 DISK NAME>.RAW --cyls=40 --head=2 --sectors=8 --size=256
  ````

  Run the following bash commands to convert the RAW format disk obtained above into something which can be read by CPMTools.

   ````bash
   mv <MZ800 DISK NAME>.RAW workingfile.raw
   > total
   dd if=workingfile.raw of=total count=8192 bs=1
   for i in $(seq 8192 8192 327680); do 
     dd if=workingfile.raw of=blob skip=$i bs=1 count=4096
     cat blob >> total
     echo $i
   done
   for i in $(seq 12288 8192 327680); do
     dd if=workingfile.raw of=blob skip=$i bs=1 count=4096
     cat blob >> total
     echo $i
   done
   mv total <MZ800 DISK NAME>.RAW
   ````

   You will need the following diskdefs definition in order to read the data from the processed RAW image.
   ````bash
   # Definition for the MZ800 CP/M Boot Disk. The reserved
   # track is in inverted data format but this is skipped in
   # CPM Tools.
   diskdef mz800-BOOT
     seclen 256
     tracks 80
     sectrk 16
     blocksize 2048
     maxdir 64
     skew 0
     boottrk 1
     os 2.2
   end

   # Definition for the MZ800 CP/M Data disk. No reserved tracks.
   diskdef mz800-DATA
     seclen 256
     tracks 80
     sectrk 16
     blocksize 2048
     maxdir 64
     skew 0
     boottrk 0
     os 2.2
   end
   ````

### CP/M Archives

Included in the repository are a collection of CP/M programs for use on the MZ80A. These are selected programs and come from various CP/M archives and are assembled in directories with the naming convention CPM[0-9[0-9]_<Contents>.
Also included (and due credit and (C) for his work in assembling the archive) is from Grant Searle's MultiComp computer which is multiple computers in one (or multiple CPU types) and one of it's modes is to run CP/M. The archive of 
Grant's is excellent and an ideal base to use CP/M on the MZ80A.    

To build the archives into a set of 1.4MB Floppy images suitable for use in a 3.5" Drive or Floppy Emulator, run the command:

````bash
cd <software>
tools/make_cpmdisks.sh
````

The disks will be created in the directory: \<CPM\>/1M44/DSK.

This script also builds the 16MB SD Card drive images using a combination of the archives. The combination is hardcoded inside the script.


## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice within the headers or given due credit. All 3rd party software, to my knowledge and research, is open source and freely useable,
if there is found to be any component with licensing restrictions, it will be removed from this repository and a suitable link/config provided.


## Licenses

This design, hardware and software, is licensed under the GNU Public Licence v3.

### The Gnu Public License v3
 The source and binary files in this project marked as GPL v3 are free software: you can redistribute it and-or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version
 3 of the License, or (at your option) any later version.

 The source files are distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with this program.  If not, see http://www.gnu.org/licenses/.


