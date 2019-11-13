Please consult my [GitHub](https://pdsmart.github.io) website for more upto date information.

## Overview

The Sharp MZ80A as with most vintage computers had limited storage. In order to expand the hardware it is often the case that the resident software has to be enhanced which was impossible given the storage space (ie. 4K Monitor rom). The Sharp MZ80A has a 4K Monitor ROM, a 2K User ROM/RAM and space within the memory map to add a further 4K ROM typically for the floppy disk drive.

One of the seperate projects I've been working on was a 40/80 Column switchable display and colour output. This upgrade requires different software, either a complete rewrite of the original monitor or a patched copy for 80 column mode. Wanting to keep the machine as original as possible, using a rewritten ROM is out of the question thus I would need 2 ROMS, original for 40Column and a patched one for 80Column.

Thus was born the need for Rom Paging, ie. Use a modern Flash ROM to house multiple 4K Roms which can be switched in according to the hardware upgrade.

It was also seen that using large Flash ROMS it was possible to store programs that would normally be present on tape or floppy and load at much higher speed making use of the computer that much easier.

This upgrade uses the 4K Monitor ROM and 2K User ROM space to map in 2x512Kbyte Flash ROMS providing paged roms and a Rom Filing System storing most commonly used programs.

I havent yet documented this upgrade as it is still undergoing minor tweaks, but within this repository are the schematics, PCB Gerber files and the software to implement the Rom Filing System.

## Rom Filing System v1.0

The Rom Filing System replaces the Monitor ROM and User ROM by lifter sockets onto a daughter card where 2x512Kbyte Flash RAM's are sited. One Flash RAM is paged into the Monitor ROM socket and the other into the User ROM socket. The first 16Kbyte of each Flash RAM is dedicated to paged ROMs with the remainder being used to store Sharp MZF format binary images compacted within 256byte sectors.

The necessary software to alow bank paging and the Rom Filing System additions has been written and can be found in software/asm, the following table describes each file.

| Module                 | Target ROM | Size | Bank | Description                                                                                                                                                             |
|------------------------|------------|------|------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| rfs.asm                | User       | 2K   | 0    | Primary Rom Filing System and MZ700/MZ800 Monitor tools.                                                                                                     |
| rfs_bank1.asm          | User       | 2K   | 1    | Empty - further functionality can be placed here.                                                                                                                       |
| rfs_bank2.asm          | User       | 2K   | 2    | Empty - further functionality can be placed here.                                                                                                                       |
| rfs_bank3.asm          | User       | 2K   | 3    | Memory Test utility and 8253 Timer test.                                                                                                                                |
| rfs_bank4.asm          | User       | 2K   | 4    | Empty - further functionality can be placed here.                                                                                                                       |
| rfs_bank5.asm          | User       | 2K   | 5    | Empty - further functionality can be placed here.                                                                                                                       |
| rfs_bank6.asm          | User       | 2K   | 6    | Empty - further functionality can be placed here.                                                                                                                       |
| rfs_bank7.asm          | User       | 2K   | 7    | Empty - further functionality can be placed here.                                                                                                                       |
| monitor_SA1510.asm     | Monitor    | 4K   | 0    | Original SA1510 Monitor for 40 character display.                                                                                                                       |
| monitor_80c_SA1510.asm | Monitor    | 4K   | 1    | Original SA1510 Monitor patched for 80 character display.                                                                                                               |
| rfs_mrom.asm           | Monitor    | 4K   | 2    | Rom Filing System helper functions located in the Monitor ROM space in Bank 3. These functions are used to scan and process MZF files stored within the User ROM space. |
| unused                 | Monitor    | 4K   | 3    | Unused slot for further functionality.                                                                                                                                  |

rfs.asm and all the rfs_bank< x >.asm are for the User ROM software which is invoked by the original Monitor ROM on startup. The functionality in these files provides the RFS file system and additional MZ700/800 style utilities. The way the code is structured, a call can be made from one bank to another without issue (stack and execution point manipulation is taken care of) thus providing almost 16K program space in the User ROM slot.
  
rfs_mrom.asm is located in the 3rd bank (bank 2) of the Monitor ROM (bank 0 = original SA1510 ROM, bank 1 = 80 column modified SA1510 ROM) and provides utilities needed by the Rom Filing System. These utilities are specifically needed for scanning and loading MZF files stored in the User ROM Flash RAM (because code executing in the User ROM cant page itself out to scan the remainder of the ROM).

The two shell scripts software/proc_mzf.sh and software/make_roms.sh are simple shell scripts used to convert MZF files into a ROM images. proc_mzf.sh takes a set of MZF files and pads them to the desired sector size, ie. 256 bytes. make_roms.sh is a manually coded shell script to enable copying of required software and MZF files into a ROM image suitable for flashing into the Flash RAM's

To build the software, there is a shell script in the tools directory called assemble_rfs.sh. This script requires the GLASS Z80 Assembler which is freely downloadable (https://bitbucket.org/grauw/glass/src/default/).

The procedure to build a ROM is:-<br/>
1. Take a set of MZF files and convert them into correct sector padded binary files. The proc_mzf.sh file takes a directory and processes all files within it, transforming originalfile.mzf to originalfile.mzf.<sector size>.bin<br/>
2. Build the Z80 code using software/tools/assemble_rfs.sh (or software/tools/assemble_roms.sh for compiling all source including the SA1510 monitor ROM).<br/>
3. Build the ROM using the software/make_roms.sh - before using you need to create your own section of MZF files by listing the files with ls -l then converting them into a set of ROM256_USER variables for programs that will go into the User Socket Flash RAM and ROM256_MROM variables for programs that will go into the Monitor Socket Flash RAM.<br/>
  
Upon boot, the typical SA1510 signon banner will be appended with "+ RFS" if all works well. You can then issue MZ700/MZ800 monitor commands or I to list Rom Filing System contents. To Load a program from the Rom Filing System, type:-<br/>
L\<RFS number - as seen in the I command output ><br/>
  or<br/>
L\<program name ><br/>
(Using lower case 'l' in place of 'L' doesnt auto execute the program once loaded into memory)  
  
If the 40/80 column card is installed, typing '4' switches to 40 Column display, typing '8' switches to 80 Column display.

The supported commands can be found in the table below:

| Command | Parameters                          | Description                                                                                                                                                                                             |
|---------|-------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 4       | n/a                                 | Switch to 40 Character mode if the 40/80 Column display upgrade has been added\.                                                                                                                        |
| 8       | n/a                                 | Switch to 80 Character mode if the 40/80 Column display upgrade has been added\.                                                                                                                        |
| B       | n/a                                 | Enable/Disable key entry beep\.                                                                                                                                                                         |
| C       | n/a                                 | Initialise memory from 0x1200 \- Top of RAM\.                                                                                                                                                           |
| D       | \<address>                           | List/Dump memory from \<address> in hex and ascii\.                                                                                                                                                      |
| F       | n/a                                 | Boot from Floppy Disk                                                                                                                                                                                   |
| I       | n/a                                 | List the files stored in ROM\. Each file title is preceded with a hex number which can be used to identify the file\.                                                                                   |
| J       | \<address>                           | Jump \(start execution\) at location \<address>\.                                                                                                                                                        |
| L       | \<name> or \<file number>             | Load file into memory from Tape or Rom Filing System\. If a \<name> or \<file number> is given, the RFS is searched, if no parameter is given then the first program encountered on tape will be loaded\. |
| l       | \<name> or \<file number>             | Same as above but once the program is loaded it will not be executed\. Control will return to the monitor\.                                                                                             |
| M       | \<address>                           | Edit and change memory locations starting at \<address>\.                                                                                                                                                |
| P       | n/a                                 | Run a connected printer test\.                                                                                                                                                                          |
| R       | n/a                                 | Run a memory test on the main memory\.                                                                                                                                                                  |
| S       | \<start addr> \<end addr> \<exec addr> | Save a block of memory to tape\. You will be prompted to enter the filename\.                                                                                                                           |
| T       | n/a                                 | Test the 8253 timer\.                                                                                                                                                                                   |
| V       | n/a                                 | Verify a file just written to tape with the original data stored in memory                                                                                                                              |
#### To Do
1) Remake the PCB to use standard DIP Flash RAM packages.<br/>
2) Add Mux to allow Z80 writing into the Monitor ROM Flash.<br/>
3) Add a coded latch such that it is possible to write to the Flash RAM (didnt originally consider writing to the Flash RAM) without upsetting the page register.<br/>
4) Write routines such that any files (ie. Basic) can be stored in the RFS and retrieved by an application such as Basic. Currently the stored files are only accessible to the Monitor.<br/>
5) Write routines which allow storing/saving of files into the RFS via the Flash RAM writing mechanism (needs 3 fixing first).<br/>

### Images of the RFS Command Output
##### 

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9784.jpg)
Issuing the 'I' command to list the Rom directory contents. Note the hex number followed by the MZF filename. The hex number can be used as a quick way to reference a file.
![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9789.jpg)
Directory listing in 80 Character mode.

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9788.jpg)
Issuing a Load command to load Basic SA-5510 using the short hex number abbreviation.
![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9790.jpg)
Load command in 80 character mode.


### Images of the RFS Daughter Board
##### 

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9625.jpg)
The topside without the Flash RAM's being sited. The first PCB was intended to use a Skinny DIP device but I ordered the wrong part so had to make an adapter to fan out the Skinny DIP footprint to a standard DIP footprint.

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9626.jpg)
The underside has 2x28pin adapters such that the board plugs into the original Monitor/User ROM sockets. This keeps the upgrade reversible and doesnt change the original motherboard.

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9624.jpg)
The RFS daughter board plugged into the original motherboard via the Monitor/User ROM sockets.


## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice.



## Licenses

This design, hardware and software, is licensed under th GNU Public Licence v3.


