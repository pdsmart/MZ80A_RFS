## Foreword

This document is a work in progress.



## Overview

The Sharp MZ80A as with most vintage computers had limited storage. In order to expand the hardware it is often the case that the resident software has to be enhanced which was impossible given the storage space (ie. 4K Monitor rom). The Sharp MZ80A has a 4K Monitor ROM, a 2K User ROM/RAM and space within the memory map to add a further 4K ROM typically for the floppy disk drive.

One of the seperate projects I've been working on was a 40/80 Column switchable display and colour output. This upgrade requires different software, either a complete rewrite of the original monitor or a patched copy for 80 column mode. Wanting to keep the machine as original as possible, using a rewritten ROM is out of the question thus I would need 2 ROMS, original for 40Column and a patched one for 80Column.

Thus was born the need for Rom Paging, ie. Use a modern Flash ROM to house multiple 4K Roms which can be switched in according to the hardware upgrade.

It was also seen that using large Flash ROMS it was possible to store programs that would normally be present on tape or floppy and load at much higher speed making use of the computer that much easier.

This upgrade uses the 4K Monitor ROM and 2K User ROM space to map in 2x512Kbyte Flash ROMS providing paged roms and a Rom Filing System storing most commonly used programs.

I havent yet documented this upgrade as it is still undergoing minor tweaks, but within this repository are the schematics, PCB Gerber files and the software to implement the Rom Filing System.

## Rom Filing System v1.0

The Rom Filing System replaces the Monitor ROM and User ROM by lifters onto a daughter card where 2 512Kbyte Flash RAMS are sited. One Flash RAM is paged into the Monitor ROM socket and the other into the User ROM socket. The first 16Kbyte of each Flash RAM is dedicated to paged ROMs with the remainder being used to store Sharp MZF format binary images compacted within 256byte sectors.

The necessary software has been written and can be found in software/asm, in the files:-
rfs.asm  rfs_bank1.asm  rfs_bank2.asm  rfs_bank3.asm  rfs_bank4.asm  rfs_bank5.asm  rfs_bank6.asm  rfs_bank7.asm  rfs_mrom.asm

rfs.asm and all the rfs_bank< x >.asm are for the User ROM software which is invoked by the original Monitor ROM on startup. This provide the RFS file system and additional MZ700/800 style utilities. The way the code is structured, a call can be made from one bank to another thus providing almost 16K program space in the User ROM slot.
  
rfs_mrom.asm is located in the 3rd bank of the Monitor ROM (bank 1 = original SA1510 ROM, bank 2 = 80 column modified SA1510 ROM) and provides utilities needed by the Rom Filing System.

The two shell scripts software/proc_mzf.sh and software/make_roms.sh are used to convert MZF files into a ROM image. proc_mzf.sh takes a set of MZF files and pads them to the desired sector size, ie. 256 bytes. make_roms.sh is a manually coded shell script to enable copying of required software and MZF files into a ROM image suitable for flashing into the Flash RAMS.

To assemble the software, in the tools directory is the shell script assemble_rfs.sh. This script requires the GLASS Z80 Assembler which is freely downloadable.

The procedure to build a ROM is:-<br/>
1. Convert required MZF files into correct sector padded files. The proc_mzf.sh file takes a directory and processes all files within, creating originalfile.mzf as originalfile.mzf.<sector size>.bin<br/>
2. Assemble the Z80 code using software/tools/assemble_rfs.sh (or software/tools/assemble_roms.sh for compiling all source including the SA1510 monitor ROM).<br/>
3. Build the ROM using the software/make_roms.sh - before using you need to create your own section of MZF files by listing the files with ls -l then converting them into a set of ROM256_USER variables for programs that will go into the User Socket Flash RAM and ROM256_MROM variables for programs that will go into the Monitor Socket Flash RAM.<br/>
  
Upon boot, the typical SA1510 signon banner will be appended with "+ RFS" if all works well. You can then issue MZ700/MZ800 monitor commands or I to list Rom Filing System contents. To Load a program from the Rom Filing System, type:-<br/>
L< RFS number - as seen in the I command output ><br/>
  or<br/>
L< program name ><br/>
(Using lower case 'l' in place of 'L' doesnt auto execute the program once loaded into memory)  
  
If the 40/80 column card is installed, typing '4' switches to 40 Column disolay, typeing '8' switches to 80 Column display.

##### 

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9625.jpg)

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9626.jpg)

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9624.jpg)



## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice.



## Licenses

This design, hardware and software, is licensed under th GNU Public Licence v3.


