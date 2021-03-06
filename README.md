## Overview

The Sharp MZ80A came with 48K RAM and 4K ROM and apart from the option to add a 2K User RAM/ROM and a 4K Floppy Drive ROM, there was no further possibility to expand the machine memory
capabilities at the hardware level and thus no additional firmware could be added for use at power-on. Add-ons had to rely on loading control firmware into RAM via tape or floppy, thus depleting valuable application space. Some machines of the same era
utilised a scheme called 'banking' whereby much larger memories would occupy a smaller block within the CPU address space and be selected according to features required and hardware attached. The 
BBC Micro was such a machine with upto 16 banks of 16Kb, it made the machine much more useable.

One of the seperate projects I've been working on was a 40/80 Column switchable display and colour output. This upgrade requires different software, either a complete rewrite of the original
monitor or a patched copy for 80 column mode. Wanting to keep the machine as original as possible, using a rewritten ROM is out of the question thus I would need 2 ROMS, original for 40Column
and a patched one for 80Column.

Thus was born the need for Rom Paging in the Sharp MZ80A, ie. Use a modern Flash RAM to house multiple 4K Roms which can be *switched in* to the 4K Monitor ROM address space according to the
hardware upgrade being used.

It was also seen when using large Flash RAM's it was possible to store programs that would normally be present on tape or floppy and load at much higher speed making use of the computer that
much easier.

This upgrade goes a bit further and uses the 4K Monitor ROM and 2K User ROM space to map in 2x512Kbyte Flash RAM's providing multiple paged roms (theoretical 256 x 2K slots and 128 x 4K slots)
and the required custom software to control the banking called the Rom Filing System.

This page along with the [CP/M](/sharpmz-upgrades-cpm) page forms the start of the RFS documentation which is still in its infancy. Within this repository are the schematics, PCB Gerber files and the software to implement the Rom Filing
System hardware and software.

## Rom Filing System


The Rom Filing System is a hardware and software upgrade for the Sharp MZ80A. The hardware replaces the Monitor and User ROM's on the motherboard by a daughter card with lifter sockets where 2x512Kbyte Flash RAM's are sited.
One of the Flash RAM's is paged into the Monitor ROM socket and the other into the User ROM socket. The first 32Kbytes (8 slots x 4K) of the Monitor Flash RAM and the first 24Kybtes (12 slots of 2K) of the User Flash RAM is
dedicated to paged ROMs with the remainder being used to store Sharp MZF format binary images compacted within 256byte sectors. (*NB. This may change to 128 byte sectors as the original reason for choosing 256 byte
sectors no longer exists*).

### RFS Hardware

It is quite easy to make upgrades for older tech these days by using one of the plethora of ready made development boards such as the Raspberry Pi or standalone microcontrollers such as the STM32 series. I did consider using an STM32F series
microcontroller as a ROM emulator as they have the price, performance and packaging advantages but then the goal of this project and the goals of the other Sharp MZ80A upgrades (excluding the Tranzputer) was to use old tech and keep the machine
original. Unlike a commercial project where part choice to provide the required functionality is imperative to keep costs low, with this project the focus is on the learning journey using parts such as the 74 series which were available at the
time of the Sharp, excepting of course the larger Flash RAM and Static RAMs which came a few years later but necessary for the functionality.

![image](../images/MZ80A_RFS_v2_0-2.png)

Version 2 of the hardware builds on the experiences learnt making version 1. It adds a coded latch (a programmable number of reads required in the 0xEFF8-0xEFFF region) in order to enable access to the control registers and I/O otherwise
both read and write access is performed on memory. It also adds two additional (optional) memories for increased storage and RAM. The additional two devices can be both Flash RAM or 1 Flash RAM and 1 Static RAM. The Static RAM is to
increase the capability of CP/M, such as number of SD drives available and the memory available to TPA applications.

The schematic has been split into two distinct functions, Memory and Control logic. Above is the new Memory schematic which retains the single 512K Flash RAM which replaces the Monitor ROM, write access is not possible as the underlying
Sharp hardware blocks write on Monitor ROM select. In the User ROM socket are 3 devices, the 512K Flash RAM from version 1 but with write access and an additional 2 devices.

![image](../images/MZ80A_RFS_v2_0-3.png)


The second schematic is the control logic. This creates the needed memory select lines from the main board in combination with address decoding and programmable latches for the upper address lines.

A coded latch is added (74HCT191) which only enables I/O when a read is made to the region 0xEFF8-0xEFFF for a programmable number of times, set by the latch U14 bits 3:5. At start up these bits will be 0 and to enable the I/O a read 
will be needed in the region 0xE800-exEFF7 to reset the 74HCT191 which must then be followed by 16 reads to the range 0xEFF8-0xEFFF. Once the I/O is enabled, the latch value can be changed along with other registers. As soon as a read is made
into the region 0xE800-0xEFF7 then the I/O control is disabled and reads/writes are sent to the selected memory device.

In addition it adds 2 SPI circuits, only one of which will be assembled on the PCB according to choice. The first is a software bitbang SPI using the Z80 to form the correct serial and clock signals in order to talk to an SD Card.
This method uses few hardware components but is much slower. The second is a hardware SPI running at 8MHz which is capable of transferring/receiving a byte in less time that the Z80 takes to perform a read, this allows for performance
similar to the Flash RAM storage. On the hardware SPI it is possible via U14 bit 0 to manually clock the SPI logic, this is intentional as initial connections with an SD Card should begin at 100KHz or less, once established and parameters
set then the 8MHz hardware clock is used.

### RFS Software

In order to use the RFS Hardware, a comprehensive set of Z80 assembler methods needed to be written to allow bank paging and with it came the option, which was taken, to upgrade the machines monitor functionality. This Z80
software forms the Rom Filing System which can be found in the repository within the \<software\> directory.

The following table describes each major file which forms the Rom Filing System:

| Module                 | Target ROM | Size | Bank | Description                                                                                                                                                             |
|------------------------|------------|------|------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| rfs.asm                | User       | 2K   | 0    | Primary Rom Filing System and MZ700/MZ800 Monitor tools.                                                                                                                |
| rfs_bank1.asm          | User       | 2K   | 1    | Floppy disk controller functions.                                                                                                                                       |
| rfs_bank2.asm          | User       | 2K   | 2    | SD Card controller functions.                                                                                                                                           |
| rfs_bank3.asm          | User       | 2K   | 3    | Memory monitor utility functions and tape/SD copy utilities.                                                                                                            |
| rfs_bank4.asm          | User       | 2K   | 4    | CMT functions.                                                                                                                                                          |
| rfs_bank5.asm          | User       | 2K   | 5    | Unused.                                                                                                                                                                 |
| rfs_bank6.asm          | User       | 2K   | 6    | Message printing routines, static messages, ascii conversion and help screen.                                                                                           |
| rfs_bank7.asm          | User       | 2K   | 7    | Memory Test utility and 8253 Timer test.                                                                                                                                |
| cbios_bank1.asm        | User       | 2K   | 8    | CPM CBIOS Utilities and Audio functions.                                                                                                                                |
| cbios_bank2.asm        | User       | 2K   | 9    | CPM CBIOS Screen and ANSI Terminal functions.                                                                                                                           |
| cbios_bank3.asm        | User       | 2K   | 10   | CPM CBIOS SD Card Controller functions.                                                                                                                                 |
| cbios_bank4.asm        | User       | 2K   | 11   | CPM CBIOS Floppy Disk Controller functions.                                                                                                                             |
| monitor_SA1510.asm     | Monitor    | 4K   | 0    | Original SA1510 Monitor for 40 character display.                                                                                                                       |
| monitor_80c_SA1510.asm | Monitor    | 4K   | 1    | Original SA1510 Monitor patched for 80 character display.                                                                                                               |
| cbios.asm              | Monitor    | 4K   | 2    | CPM CBIOS (exec location 0xC000:0xCFFFF).                                                                                                                               |
| rfs_mrom.asm           | Monitor    | 4K   | 3    | Rom Filing System helper functions located in the Monitor ROM space in Bank 3. These functions are used to scan and process MZF files stored within the User ROM space. |
| unassigned             | Monitor    | 4K   | 4    | Unused slot.                                                                                                                                                            |
| unassigned             | Monitor    | 4K   | 5    | Unused slot.                                                                                                                                                            |
| unassigned             | Monitor    | 4K   | 6    | Unused slot.                                                                                                                                                            |
| unassigned             | Monitor    | 4K   | 7    | Unused slot.                                                                                                                                                            |


In the User ROM, the rfs.asm module and  all the rfs_bank\<x\>.asm modules form the Rom Filing System and are invoked by the original SA-1510 monitor on startup of the MZ80A (or reset). The functionality in these files provides
the Rom Filing System and additional MZ700/800 style monitor utilities. The way the code is structured, a call can be made from one bank to another without issue (stack and execution point manipulation is taken care of) thus
providing almost 16K program space in the User ROM slot.

Sharing the User ROM banks are the cbios_bank\<x\>.asm modules which form part of the CP/M Custom BIOS. They extend the functionality of the CBIOS without impacting RAM usage which is crucial within CP/M in order
to run as many applications as possible.
  
In the Monitor ROM, the rfs_mrom.asm module is located within the 4th bank (bank 3, bank 0 = original SA1510 ROM, bank 1 = 80 column modified SA1510 ROM) and provides utilities needed by the Rom Filing
System. These utilities are specifically needed for scanning and loading MZF files stored in the User ROM Flash RAM (because code executing in the User ROM cant page itself out to scan the
remainder of the ROM).

CPM v2.2 has been added with the CBIOS (Custom BIOS) being implemented within an MROM Bank (bank 2) along with User ROM Banks 8-11 mentioned above. This saves valuable RAM leaving only the CPM CCP and BDOS in RAM which can
be overwritten by programs, this gives a feasible 47K of useable program RAM. An intention is to include a paged RAM chip in the next release of the RFS Hardware which will allow upto 52K of program RAM.

There are several rapidly written shell scripts to aid in the building of the RFS software (which in all honesty need to be written into a single Python or Java tool). These can be seen in the following table along with their purpose:

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
| sdtool            | A binary created from the src/tools repository which builds the RFS SD Card image, creating a directory and adding MZF/Binary applications into the drive image. |

To build the software, the assemble_\<name\> shell scripts are used. These scripts requires the [GLASS Z80 Assembler](https://bitbucket.org/grauw/glass/src/default/) which is freely downloadable.

The procedure to build a ROM is:-<br/>
1. Take a set of MZF files and convert them into correct sector padded binary files. The proc_mzf.sh file takes a directory and processes all files within it, transforming originalfile.mzf to originalfile.mzf.\<sector size>.bin<br/>
2. Build the Z80 code using \<tools\>/assemble_rfs.sh for the RFS components, \<tools\>/assemble_roms.sh for assembling all original ROM source including the SA1510 monitor ROM, \<tools\>/assemble_cpm.sh for
   assembling the CPM binaries and dependencies.<br/>
3. Build the ROM using the \<tools\>/make_roms.sh script - before using this you need to create your own selection of MZF files by listing the files with ls -l then converting them into a set of ROM_INCLUDE variables for programs that
   will go into the User and Monitor Flash RAM's.<br/>

### RFS Monitor
  
Upon boot, the typical SA-1510 monitor signon banner will appear and be appended with "+ RFS" if all works well. The usual '\* ' prompt appears and you can then issue any of the original SA-1510 commands along with a set of enhanced
commands, some of which were seen on the MZ700/ MZ800 range and others are custom. The full set of commands are listed in the table below:


| Command | Parameters                          | Description                                                                        |
|---------|-------------------------------------|------------------------------------------------------------------------------------|
| 4       | n/a                                 | Switch to 40 Character mode if the 40/80 Column display upgrade has been added\.   |
| 8       | n/a                                 | Switch to 80 Character mode if the 40/80 Column display upgrade has been added\.   |
| B       | n/a                                 | Enable/Disable key entry beep\.                                                    |
| C       | \[\<8 bit value\>\]                 | Initialise memory from 0x1200 \- Top of RAM with 0x00 or provided value\.          |
| D       | \<address>\[\<address2>\]           | Dump memory from \<address> to \<address2> (or 20 lines) in hex and ascii. When a screen is full, the output is paused until a key is pressed\. <br><br>Subsequent 'D' commands without an address value continue on from last displayed address\.<br><br> Recognised keys during paging are:<br> 'D' - page down, 'U' - page up, 'X' - exit, all other keys list another screen of data\.|
| EC      | \<name> or <br>\<file number>       | Erase file from SD Card\. The SD Card is searched for a file with \<name> or \<file number> and if found, erased\. |
| F       | \[\<drive number\>\]                | Boot from the given Floppy Disk, if no disk number is given, you will be prompted to enter one\. |
| f       | n/a                                 | Execute the original Floppy Disk AFI code @ 0xF000                                 |
| H       | n/a                                 | Help screen of all these commands\.                                                |
| IR      | n/a                                 | Paged directory listing of the files stored in ROM\. Each file title is preceded with a hex number which can be used to identify the file\. |
| IC      | n/a/                                | Paged directory listing of the files stored on the SD Card\. Each file title is preceded with a hex number which can be used to identify the file\. |
| J       | \<address>                          | Jump \(start execution\) at location \<address>\.                                  |
| L \| LT | n/a                                 | Load file into memory from Tape and execute\.                                      |
| LTNX    | n/a                                 | Load file into memory from Tape, dont execute\.                                    |
| LR      | \<name> or <br>\<file number>       | Load file into memory from ROM\. The ROM is searched for a file with \<name> or \<file number> and if found, loaded and executed\. |
| LRNX    | \<name> or <br>\<file number>       | Load file into memory from ROM\. The ROM is searched for a file with \<name> or \<file number> and if found, loaded and not executed\. |
| LC      | \<name> or <br>\<file number>       | Load file into memory from SD Card\. The SD Card is searched for a file with \<name> or \<file number> and if found, loaded and executed\. |
| LCNX    | \<name> or <br>\<file number>       | Load file into memory from SD Card\. The SD Card is searched for a file with \<name> or \<file number> and if found, loaded and not executed\. |
| M       | \<address>                          | Edit and change memory locations starting at \<address>\.                          |
| P       | n/a                                 | Run a test on connected printer\.                                                  |
| R       | n/a                                 | Run a memory test on main mmemory\.                                                |
| S       | \<start addr> \<end addr> \<exec addr> | Save a block of memory to tape\. You will be prompted to enter the filename\. <br><br>Ie\. S120020001203 - Save starting at 0x1200 up until 0x2000 and set execution address to 0x1203\.  |
| SC      | \<start addr> \<end addr> \<exec addr> | Save a block of memory to SD Card\. You will be prompted to enter the filename\. |
| SD2T    | \<name> or <br>\<file number>       | Copy a file from SD Card to Tape\. The SD Card is searched for a file with \<name> or \<file number> and if found, copied to a tape in the CMT\. |
| T       | n/a                                 | Test the 8253 timer\.                                                              |
| T2SD    | n/a                                 | Copy a file from Tape onto the SD Card. A program is loaded from Tape and written to a free position in the SD Card\. |
| V       | n/a                                 | Verify a file just written to tape with the original data stored in memory         |


If the 40/80 column card is installed, typing '4' switches to 40 Column display, typing '8' switches to 80 Column display. For the directory listing commands, 4 columns of output will be shown when in 80 column mode.

## Building RFS

Building the Rom Filing System involves assembling the Z80 Assembly language source into a machine code binary and packaging it into an image suitable for writing onto a 512Kbyte Flash RAM. You may also want to include MZF applications
in the ROMS for rapid exection via the RFS system. If you intend to use CPM, see also the CPM documentation.

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
| \<src\>         | \[\<ABS PATH>\]/MZ80A_RFS/software/src                                      |
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

Building the software and final ROM images can be done by cloning the [repository](https://github.com/pdsmart/MZ80A_RFS.git) and running some of the shell scripts and binaries provided.


The RFS is built as follows:

   1. Make the RFS binary using \<tools\>/assemble_rfs.sh, this creates \<roms\>/rfs.rom for the User Bank Flash RAM and \<roms\>/rfs_mrom.rom for the Monitor Bank Flash RAM.
   2. Make the original MZ80A monitor roms using \<tools\>/assemble_roms.sh, this creates \<roms\>/monitor_SA1510.rom and \<roms\>/monitor_80c_SA1510.rom for the Monitor Bank Flash RAM.
   3. Make the rom images using \<tools\>/make_roms.sh, this creates \<roms\>/USER_ROM_256.bin for the User Bank Flash RAM and \<roms\>/MROM_256.bin for the Monitor Bank Flash RAM.
      The rom images also contain a packed set of MZF applications found in the \<MZF\> directory. Edit the script \<tools\>/make_roms.sh to add or remove applications from the rom images.

The above procedure has been encoded in a set of shell scripts and C tools, which at the simplest level, is to run these commands:
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

The applications which can be stored in the Flash RAMS are located in the \<MZF\> directory. In order to use them within the Flash RAM's, the applications need to be converted into sector rounded binary images and stored in the
\<MZB\> directory. The tool \<tool\>/processMZFiles.sh has been created for this purpose. Simply copy any MZF application into the \<MZF\> directory and run this tool:

````bash
cd <software>
tools/processMZFfiles.sh
````
The files will be converted and stored in the \<MZB\> directory and then used by the \<tools\>/make_roms.sh script when creating the ROM images.  The \<tools\>/make_roms.sh script lists all the applications to be added into the 
Flash RAM's and it will pack as many as space permits. To ensure your application appears in the Flash RAM, add it to the top of the list (just the filename not the .MZF extension), ie:

````bash
Edit the file <tools>/make_roms.sh
Locate the line: ROM_INCLUDE=
Below this line, add your application in the format: ROM_INCLUDE+="${MZBPATH}/<YOUR APPLICATION>.${SECTORSIZE}.bin"
ie. ROM_INCLUDE+="${MZB_PATH}/A-BASIC_SA-5510.${SECTORSIZE}.bin:"
Save the file and run the commands above to build the MonitorROM and USERROM's.
````

The SD Card image is created by the \<tools\>/make_sdcard.sh script and in its basic form creates an image which can be directly copied onto an SD Card. This image contains the SD Card Filing System which is populated with
MZF applications from the \<MZF\> directory. Edit the \<tools\>/make_sdcard.sh script to add/remove MZF applications which are installed into the SDCFS. CP/M images are also added to the SD Card and this is covered in the 
[CP/M](sharpmz-upgrades-cpm/) section.



## SD Card 

A recent addition to the Rom Filing System is an SD Card. In hardware it is implemented using the bitbang technique and provides performance comparable with a floppy disk without the seek overhead or interleave
times, but in all honesty, this would be better catered for by dedicated shift registers in order to gain performance on par with the ROM drives.

I worked on using the [Petit FatFS by El CHaN](http://elm-chan.org/fsw/ff/00index_p.html)  for the SD Card filing system, which is excellent having previously used the full Fat version with my ZPU project, but the Z80 isnt the best
architecture for code size when using C. In the repository in \<src\>/tools is my developments along this line with a C program called 'sdtest' and a modularized PetitFS along with manually coded Z80 assembler to handle the bitbang
algorithm and SD Card initialisation and communications.  The program compiles into an MZF application and when run performs flawlessly. The only issue as mentioned is size and when your limited to 2K and 4K banked roms with a 12K
filing system you have an immediate storage issue. It is feasible to build PetitFS into a set of ROM banks using the z88dk C Compiler which supports banked targets and __far constructs but it would be a lot of effort for something
which really isnt required.

I thus took a step back and decided to create my own simple filing system which is described below. This filing system is used for Sharp MZ80A MZF applications and is for both read and write operations.

### SD Card Filing System

The SD Card Filing System resides at the beginning of the SD Card and is followed by several CPM disk drive images. The SDCFS image is constructed of a directory plus 256 file blocks. The directory can contain upto 256 entries, 
each entry being 32 bytes long. The SDCFS directory entry is based on the MZF Header format and is as follows:

| FLAG1  | FLAG2  | FILE NAME | START SECTOR | SIZE    | LOAD ADDR | EXEC ADDR | RESERVED |
|--------|--------|-----------|--------------|---------|-----------|-----------|----------|
| 1 Byte | 1 Byte | 17 Bytes  | 4 Bytes      | 2 Bytes | 2 Bytes   | 2 Bytes   | 3 Bytes  |


| Parameter     | Description                                                                                   |
| ------------- | --------------------------------------------------------------------------------------------- |
|  FLAG1        | BIT 7 = 1, Valid directory entry, 0 = inactive.                                               |
|  FLAG2        | MZF Execution Code, 0x01 = Binary                                                             |
|  FILENAME     | Standard MZF format filename.                                                                 |
|  START SECTOR | Sector in the SD card where the program starts. It always starts at position 0 of the sector. |
|  SIZE         | Size in bytes of the program. Each file block occupies 64Kbyte space (as per a tape) and this parameter provides the actual space occupied by the program at the current time. |
|  LOAD ADDR    | Start address in memory where data should be loaded.                                          |
|  EXEC ADDR    | If a binary then this parameter specifies the location to auto execute once loaded.           |
|  RESERVED     | Not used at the moment.                                                                       |

Each file block, 1 per directory entry, is 64K long which is intentional as it keeps a fixed size which is in line
with the maximum tape (CMT) length and can be freely read/written to just as if it were a tape. This allows for easy
use within tape based applications such as Basic SA-1510 or for copying SD Card \<-\> CMT.

The remainder of the SD Card is filled with 16MByte CPM Disk drive images. Each image is organised as 32 (512byte) Sectors x 1024 tracks
and 1 head. Each image will be mounted in CPM under its own drive letter.

Visually, the SD Card is organised as follows:

```
SECTOR   FUNCTION
00000000 ---------------------------------------------------------------------------
         | ROM FILING SYSTEM IMAGE                                                 |
         |                                                                         |
00000000 | RFS DIRECTORY ENTRY 000 (32BYTE)                                        |
         | ..                                                                      |
         | ..                                                                      |
00001FE0 | RFS DIRECTORY ENTRY 255 (32BYTE)                                        |
00002000 ---------------------------------------------------------------------------
         | RFS FILE BLOCK 0                                                        |
00003000 ---------------------------------------------------------------------------
         ...

00FF0000 ---------------------------------------------------------------------------
         | RFS FILE BLOCK 255                                                      |
01000000 ---------------------------------------------------------------------------
01000000 ---------------------------------------------------------------------------
         |                                                                         |
         |  CP/M DISK IMAGE 0                                                      |
         |                                                                         |
02000000 ---------------------------------------------------------------------------
         |                                                                         |
         |  CP/M DISK IMAGE 1                                                      |
         |                                                                         |
03000000 ---------------------------------------------------------------------------
         |                                                                         |
         |  CP/M DISK IMAGE 2                                                      |
         |                                                                         |
XX000000 ---------------------------------------------------------------------------
         |                                                                         |
         |  CP/M DISK IMAGE <n>                                                    |
         |                                                                         |
         ---------------------------------------------------------------------------
```




#### To Do
1) Update Basic SA-5510 so that it loads/saves from SD Card.<br/>

## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice within the headers or given due credit. All 3rd party software, to my knowledge and research, is open source and freely useable, if there is found to be any component with licensing restrictions, it will be removed from this repository and a suitable link/config provided.


## Licenses

This design, hardware and software, is licensed under the GNU Public Licence v3.

### The Gnu Public License v3
 The source and binary files in this project marked as GPL v3 are free software: you can redistribute it and-or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

 The source files are distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with this program.  If not, see http://www.gnu.org/licenses/.


