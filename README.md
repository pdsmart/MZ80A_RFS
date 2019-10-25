## Foreword

This document is a work in progress.



## Overview

The Sharp MZ80A as with most vintage computers had limited storage. In order to expand the hardware it is often the case that the resident software has to be enhanced which was impossible given the storage space (ie. 4K Monitor rom). The Sharp MZ80A has a 4K Monitor ROM, a 2K User ROM/RAM and space within the memory map to add a further 4K ROM.

One of the seperate projects I've been working on was a 40/80 Column switchable display and colour output. This upgrade requires different software, either a complete rewrite of the original monitor or a patched copy for 80 column mode.

Thus was born the need for Rom Paging, ie. Use a modern Flash ROM to house multiple 4K Roms which can be switched in according to the hardware upgrade.

It was also seen that using large Flash ROMS it was possible to store programs that would normally be present on tape or floppy and load at much higher speed making use of the computer that much easier.

This upgrade uses the 4K Monitor ROM and 2K User ROM space to map in 2x512Kbyte Flash ROMS providing paged roms and a Rom Filing System storing most commonly used programs.

I havent yet documented this upgrade as it is still undergoing minor tweaks, but within this repository are the schematics, PCB Gerber files and the software to implement the Rom Filing System.

## Rom Filing System v1.0


##### 

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9625.jpg)

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9626.jpg)

![alt text](https://github.com/pdsmart/MZ80A_RFS/blob/master/docs/IMG_9624.jpg)



## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice.



## Licenses

This design, hardware and software, is licensed under th GNU Public Licence v3.


