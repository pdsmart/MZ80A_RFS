/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            sdtool.c
// Created:         January 2019
// Author(s):       Philip Smart
// Description:     MZ-80A SD Card Drive file image manipulator.
//                  This program creates and manipulates an SD Card image for the Sharp MZ80A with the
//                  Rom Filing System addition. The image contains the Rom Filing System disk at 
//                  the beginning of the image (contains original Sharp MZ80A programs) along
//                  with 1 or more CPM disk drive images. The resultant image is copied directly
//                  onto an sd card using DD or equivalent.
//
//                  The format of the image is as follows:
//                  SECTOR   FUNCTION
//                  00000000 ---------------------------------------------------------------------------
//                           | ROM FILING SYSTEM IMAGE                                                 |
//                           |                                                                         |
//                  00000000 | RFS DIRECTORY ENTRY 000 (32BYTE)                                        |
//                           | ..                                                                      |
//                           | ..                                                                      |
//                  00001FE0 | RFS DIRECTORY ENTRY 255 (32BYTE)                                        |
//                  00002000 ---------------------------------------------------------------------------
//                           |                                                                         |
//                           |  CP/M DISK IMAGE 1                                                      |
//                           |                                                                         |
//                           |                                                                         |
//                           |                                                                         |
//                           |                                                                         |
//                           ---------------------------------------------------------------------------
//                           |                                                                         |
//                           |  CP/M DISK IMAGE 2                                                      |
//                           |                                                                         |
//                           |                                                                         |
//                           |                                                                         |
//                           |                                                                         |
//                           ---------------------------------------------------------------------------
//                           |                                                                         |
//                           |  CP/M DISK IMAGE 3                                                      |
//                           |                                                                         |
//                           |                                                                         |
//                           |                                                                         |
//                           |                                                                         |
//                           ---------------------------------------------------------------------------
//                           |                                                                         |
//                           |  CP/M DISK IMAGE ...                                                    |
//                           |                                                                         |
//                           |                                                                         |
//                           |                                                                         |
//                           |                                                                         |
//                           ---------------------------------------------------------------------------
//
//                           The Rom Filing System directory entry is based on the MZF Header format and is as follows:
//                  | FLAG1  | FLAG2  | FILE NAME | START SECTOR | SIZE    | LOAD ADDR | EXEC ADDR | RESERVED
//                  | 1 Byte | 1 Byte | 17 Bytes  | 4 Bytes      | 2 Bytes | 2 Bytes   | 2 Bytes   | 3 Bytes
//
//                  FLAG1        : BIT 7 = 1, Valid directory entry, 0 = inactive.
//                  FLAG2        : MZF Execution Code, 0x01 = Binary
//                  FILENAME     : Standard MZF format filename.
//                  START SECTOR : Sector in the SD card where the program starts. It always starts at position 0 of the sector.
//                  SIZE         : Size in bytes of the program. Each file block occupies 64Kbyte space (as per a tape) and this
//                                 parameter provides the actual space occupied by the program at the current time.
//                  LOAD ADDR    : Start address in memory where data should be loaded.
//                  EXEC ADDR    : If a binary then this parameter specifies the location to auto execute once loaded. 
//                  RESERVED     : Not used at the moemnt.
//
//                  Caveat: This program was just intended to be a simple helper hence not properly split into methods,
//                          it may need updating as it becomes more complex!!
//
// Credits:         
// Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
//
// History:         March 2020   - Initial program written.
//
// Notes:           
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// This source file is free software: you can redistribute it and#or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
/////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <getopt.h>
#include <libgen.h>

#define VERSION              "1.0"
#define RFS_MAX_DIR_ENTRIES  256
#define RFS_DIR_ENTRY_SIZE   32
#define RFS_DIRENT_INUSE     0x80
#define RFS_FILESIZE         65536
#define RFS_IMAGESIZE        (RFS_FILESIZE * RFS_MAX_DIR_ENTRIES) + (RFS_DIR_ENTRY_SIZE * RFS_MAX_DIR_ENTRIES)
#define RFS_FILEBLOCK_START  (RFS_DIR_ENTRY_SIZE * RFS_MAX_DIR_ENTRIES)
#define CPM_DRIVE_IMAGES     4
#define CPM_SECTOR_LEN       512
#define CPM_TRACKS           512
#define CPM_SECTORS          32
#define CPM_BLOCKSIZE        4096
#define CPM_MAXDIR_ENTRIES   512

// Structure to represent an RFS directory entry within the RFS SD Card druve image.
//
typedef struct __attribute__((__packed__)) {
    uint8_t   flag1;
    uint8_t   flag2;
    uint8_t   fileName[17];
    uint32_t  startSector;
    uint16_t  size;
    uint16_t  loadAddr;
    uint16_t  execAddr;
    uint8_t   reserved[3];
} rfs_dirent;

// Structure to represent an MZF header.
//
typedef struct __attribute__((__packed__)) {
    uint8_t   ATRB;
    uint8_t   NAME[17];
    uint16_t  SIZE;
    uint16_t  DTADR;
    uint16_t  EXADR;
    uint8_t   COMNT[104];
} mzf_dirent;

// Mapping table from Sharp MZ80A Ascii to real Ascii.
//
typedef struct {
    uint8_t    asciiCode;
    char       asciiPrintable[6];
} t_asciiMap;

static t_asciiMap asciiMap[] = {
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"}, // 0x0F
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"}, // 0x1F
    { 0x20, "SPACE"},
    { 0x21, "!"    },
    { 0x22, "\""   },
    { 0x23, "#"    },
    { 0x24, "$"    },
    { 0x25, "%"    },
    { 0x26, "&"    },
    { 0x27, "'"    },
    { 0x28, "("    },
    { 0x29, ")"    },
    { 0x2A, "*"    },
    { 0x2B, "+"    },
    { 0x2C, ","    },
    { 0x2D, "-"    },
    { 0x2E, "."    },
    { 0x2F, "/"    }, // 0x2F
    { 0x30, "0"    },
    { 0x31, "1"    },
    { 0x32, "2"    },
    { 0x33, "3"    },
    { 0x34, "4"    },
    { 0x35, "5"    },
    { 0x36, "6"    },
    { 0x37, "7"    },
    { 0x38, "8"    },
    { 0x39, "9"    },
    { 0x3A, ":"    },
    { 0x3B, ";"    },
    { 0x3C, "<"    },
    { 0x3D, "="    },
    { 0x3E, ">"    },
    { 0x3F, "?"    }, // 0x3F
    { 0x40, "@"    },
    { 0x41, "A"    },
    { 0x42, "B"    },
    { 0x43, "C"    },
    { 0x44, "D"    },
    { 0x45, "E"    },
    { 0x46, "F"    },
    { 0x47, "G"    },
    { 0x48, "H"    },
    { 0x49, "I"    },
    { 0x4A, "J"    },
    { 0x4B, "K"    },
    { 0x4C, "L"    },
    { 0x4D, "M"    },
    { 0x4E, "N"    },
    { 0x4F, "O"    }, // 0x4F
    { 0x50, "P"    },
    { 0x51, "Q"    },
    { 0x52, "R"    },
    { 0x53, "S"    },
    { 0x54, "T"    },
    { 0x55, "U"    },
    { 0x56, "V"    },
    { 0x57, "W"    },
    { 0x58, "X"    },
    { 0x59, "Y"    },
    { 0x5A, "Z"    },
    { 0x5B, "["    },
    { 0x5C, "\\"   },
    { 0x5D, "]"    },
    { 0x5E, "^"    },
    { 0x5F, "_"    }, // 0x5F
    { 0x20, "SPACE"}, // 0x60
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"}, // 0x6F
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"}, // 0x7F

    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"}, // 0x8F

    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x65, "e"    },
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x74, "t"    },
    { 0x67, "g"    },
    { 0x68, "h"    },
    { 0x20, "SPACE"},
    { 0x62, "b"    },
    { 0x78, "x"    },
    { 0x64, "d"    },
    { 0x72, "r"    },
    { 0x70, "p"    },
    { 0x63, "c"    }, // 0x9F

    { 0x71, "q"    },
    { 0x61, "a"    },
    { 0x7A, "z"    },
    { 0x77, "w"    },
    { 0x73, "s"    },
    { 0x75, "u"    },
    { 0x69, "i"    },
    { 0x20, "SPACE"},
    { 0x4F, "O"    }, // O with umlaut
    { 0x6B, "k"    },
    { 0x66, "f"    },
    { 0x76, "v"    },
    { 0x20, "SPACE"},
    { 0x75, "u"    }, // u with umlaut
    { 0x42, "B"    }, // Strasse S
    { 0x6A, "j"    }, // 0XAF

    { 0x6E, "n"    },
    { 0x20, "SPACE"},
    { 0x55, "U"    }, // U with umlaut
    { 0x6D, "m"    },
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x6F, "o"    },
    { 0x6C, "l"    },
    { 0x41, "A"    }, // A with umlaut
    { 0x6F, "o"    }, // o with umlaut
    { 0x61, "a"    }, // a with umlaut
    { 0x20, "SPACE"},
    { 0x79, "y"    },
    { 0x20, "SPACE"},
    { 0x20, "SPACE"}, // 0xBF

    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"}, // 0XCF

    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"}, // 0XDF

    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"}, // 0XEF

    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"},
    { 0x20, "SPACE"}  // 0XFF
};

// Simple function to convert an ascii filename into a Sharp filename using the asciimap table in reverse.
void convertToSharpFileName(char *filename)
{
    char *p = filename;

    while(*p != 0x00)
    {
        for(uint32_t idx=0; idx <= 255; idx++)
        {
            if(*p == asciiMap[idx].asciiPrintable[0] && strlen(asciiMap[idx].asciiPrintable) == 1)
            {
                *p = (char)idx;
            }
        }
        p++;
    }

}


// Simple help screen to remmber how this utility works!!
//
void usage(void)
{
    printf("SDTOOL v%s\n", VERSION);
    printf("\nOptions:-\n");
    printf("  -a | --add <file>        Add given file into the Image.\n");
    printf("  -A | --attribute <val>   For a binary file, set the MZF attribute to the given val, default=0x01.\n");
    printf("  -b | --binary            Indicate file being added is a binary file, not an MZF format file.\n");
    printf("  -c | --create-image      Create or re-initialise the given image file.\n");
    printf("  -e | --exec-addr <addr>  For a binary file, set the execution address to be written into the directory entry.\n");
    printf("  -h | --help              This help test.\n");
    printf("  -d | --list-dir          List the image directory contents.\n");
    printf("  -l | --load-addr         For a binary file, set the load address to be written into the directory entry.\n");
    printf("  -i | --image <file>      Image file to be created or manipulated.\n");
    printf("  -v | --verbose           Output more messages.\n");

    printf("\nExamples:\n");
    printf("  sdtool --image MZ80A_1.img --list-dir            List the directory entries in the image.\n");
    printf("  sdtool --image MZ80A_1.img --create-image        Initialise MZ80A_1.img to a new empty state.\n");
    printf("  sdtool --image MZ80A_1.img --add CLOCK.MZF       Add the CLOCK.MZF file into the image and update the directory with the MZF header details.\n");
    printf("  sdtool --image MZ80A_1.img --add CLOCK.BIN \\\n");
    printf("         --binary \\\n");
    printf("         --exec-addr 4608 --load-addr 4608         Add the CLOCK.BIN binary file into the image with the given load and exec addresses. Update directory.\n");

}

// Method to convert a little endian <-> big endian 32bit unsigned.
//
uint32_t swap_endian(uint32_t value)
{
    uint32_t b[4];
    b[0] = ((value & 0x000000ff) << 24u);
    b[1] = ((value & 0x0000ff00) <<  8u);
    b[2] = ((value & 0x00ff0000) >>  8u);
    b[3] = ((value & 0xff000000) >> 24u);

    return(b[0] | b[1] | b[2] | b[3]);
}


// Main program, to be split up into methods at a later date!! Just quick write as Im concentrating on the SD Card with RFS and CPM.
//
int main(int argc, char *argv[])
{

    int        opt; 
    int        option_index      = 0; 
    int        binary_flag       = 0;
    int        help_flag         = 0;
    int        listDir_flag      = 0;
    int        createImage_flag  = 0;
    int        verbose_flag      = 0;
    uint8_t    attribute         = 0x01;
    uint16_t   loadAddr          = 0x1200;
    uint16_t   execAddr          = 0x1200;
    char       imageFile[1024];
    char       addFile[1024];
    long       fileSize;
    FILE       *fpImage;
    FILE       *fpAdd;
    rfs_dirent rfs_directory[RFS_MAX_DIR_ENTRIES];
    mzf_dirent mzf_header;

    // Initialise other variables.
    //
    addFile[0] = 0x00;
    imageFile[0] = 0x00;

    // Modes of operation.
    // sdtool --add file [--binary] --image file --create-image
    // sdtool --add file [--binary] --image file
    // sdtool
    static struct option long_options[] =
    {
        {"add",         required_argument, 0,   'a'},
        {"attribute",   required_argument, 0,   'A'},
        {"binary",      no_argument,       0,   'b'},
        {"create-image",no_argument,       0,   'c'},
        {"exec-addr",   required_argument, 0,   'e'},
        {"help",        no_argument,       0,   'h'},
        {"list-dir",    no_argument,       0,   'd'},
        {"load-addr",   required_argument, 0,   'l'},
        {"image",       required_argument, 0,   'i'},
        {"verbose",     no_argument,       0,   'v'},
        {0,             0,                 0,   0}
    };

    // Parse the command line options.
    //
    while((opt = getopt_long(argc, argv, ":bcdha;A:i:l:e:", long_options, &option_index)) != -1)  
    {  
        switch(opt)  
        {  
            case 'a':
                strcpy(addFile, optarg);
                break;

            case 'A':
                attribute = (uint8_t)atoi(optarg);
                break;

            case 'b':
                binary_flag = 1;
                break;

            case 'c':
                createImage_flag = 1;
                break;

            case 'd':
                listDir_flag = 1;
                break;

            case 'e':
                execAddr = atoi(optarg);
                break;

            case 'h':
                help_flag = 1;
                break;

            case 'i':
                strcpy(imageFile, optarg);
                break;

            case 'l':
                loadAddr = atoi(optarg);
                break;

            case 'v':
                verbose_flag = 1;
                break;

            case ':':  
                printf("Option %s needs a value\n", argv[optind-1]);  
                break;  
            case '?':  
                printf("Unknown option: %s, ignoring!\n", argv[optind-1]); 
                break;  
        }  
    } 

    // Validate the input.
    if(help_flag == 1)
    {
        usage();
        exit(0);
    }
    if(strlen(imageFile) == 0 )
    {
        printf("Image file not specified.\n");
        exit(10);     
    }
    if(strlen(addFile) == 0 && listDir_flag == 0 && createImage_flag == 0)
    {
        printf("File to add not specified.\n");
        exit(11);     
    }
    if(createImage_flag == 1 && listDir_flag == 1)
    {
        printf("Meaningless option, create image will result in an empty directory so no point listing the directory!!\n");
        exit(12);
    }

    // If the create flag is set, initialise the base RFS image.
    if(createImage_flag)
    {
        fpImage  = fopen(imageFile,  "w");
        if(fpImage == NULL)
        {
            printf("Couldnt create the image file:%s.\n", imageFile);
            exit(30);     
        } else
        {
            for(uint32_t idx=0; idx < RFS_IMAGESIZE; idx++)
                fputc(0x00, fpImage);
        }
        fclose(fpImage);

        // All done if we are not adding a file.
        if(addFile[0] == 0x00)
        {
            if(verbose_flag)
                printf("Image file created.\n");
            exit(0);
        }
    }

    // Open the image file for read/write operations
    fpImage  = fopen(imageFile,  "r+");
    if(fpImage == NULL)
    {
        printf("Couldnt open the image file:%s.\n", imageFile);
        exit(20);     
    }

    // Get the directory into memory.
    size_t result=fread(&rfs_directory, 1, sizeof(rfs_dirent) * RFS_MAX_DIR_ENTRIES, fpImage);
    if(result < (RFS_MAX_DIR_ENTRIES * RFS_DIR_ENTRY_SIZE))
    {
        printf("Failed to read RFS directory from image, is image corrupt? (%d)\n", result);
        exit(40);
    }

    // List directory?
    if(listDir_flag == 1)
    {
        printf("FileName          Start Sector    Size    Load Addr    Exec Addr\n");
        printf("--------          ------------    ----    ---------    ---------\n"); 
        for(uint16_t idx=0; idx < RFS_MAX_DIR_ENTRIES; idx++)
        {
            if((rfs_directory[idx].flag1 & RFS_DIRENT_INUSE) != 0)
            {
                uint8_t canPrint = 1;
                for(uint16_t idx2=0; idx2 < 17; idx2++)
                {
                    if(rfs_directory[idx].fileName[idx2] == 0x0d || rfs_directory[idx].fileName[idx2] == 0x00)
                        canPrint = 0;

                    if(canPrint == 1)
                        putchar(asciiMap[rfs_directory[idx].fileName[idx2]].asciiCode);
                    else
                       putchar(' ');
                }

                printf(" %08lx        %04x       %04x         %04x\n", swap_endian(rfs_directory[idx].startSector), rfs_directory[idx].size, rfs_directory[idx].loadAddr, rfs_directory[idx].execAddr);
            }
        }
        exit(0);
    }

    // Open the MZF file to add in read only mode.
    fpAdd = fopen(addFile, "r");
    if(fpAdd == NULL)
    {
        printf("Couldnt open the file to add:%s.\n", addFile);
        exit(21);     
    }
   
    // Get size of image file.
    fseek(fpImage, 0, SEEK_END);
    fileSize = ftell(fpImage);
    fseek(fpImage, 0, SEEK_SET);
    if(fileSize < RFS_IMAGESIZE)
    {
        printf("Image size is too small, please recreate with --create-image flag.\n");
    }

    // Get size of file where adding.
    fseek(fpAdd, 0, SEEK_END);
    fileSize = ftell(fpAdd);
    fseek(fpAdd, 0, SEEK_SET);

    // If this is an MZF file, get header.
    if(binary_flag == 0)
    {
        result=fread(&mzf_header, 1, sizeof(mzf_dirent), fpAdd);
        if(result < sizeof(mzf_dirent))
        {
            printf("Failed to read MZF header from MZF file, is image an MZF file?\n");
            exit(50);
        }
    }

    // Locate the first empty slot to add the file.
    uint16_t dirEntry = 0;
    while((rfs_directory[dirEntry].flag1 & RFS_DIRENT_INUSE) != 0)
    {
        dirEntry++;
        if(dirEntry > 255)
        {
            printf("Image directory is full, cannot add file.\n");
            exit(60);
        }
    }

    // Ok, we now have a valid image file, slot in the directory which is free and the MZF file details, populate the directory entry, write it and then
    // write the file into the image.
    rfs_directory[dirEntry].flag1 = RFS_DIRENT_INUSE;
    if(binary_flag == 0)
    {
        rfs_directory[dirEntry].flag2 = mzf_header.ATRB;
        memcpy(rfs_directory[dirEntry].fileName, mzf_header.NAME, 17);
        rfs_directory[dirEntry].fileName[16] = 0x00;
        rfs_directory[dirEntry].startSector = swap_endian((RFS_FILEBLOCK_START + (dirEntry * RFS_FILESIZE))/512);;
        rfs_directory[dirEntry].size = mzf_header.SIZE;
        rfs_directory[dirEntry].loadAddr = mzf_header.DTADR;
        rfs_directory[dirEntry].execAddr = mzf_header.EXADR;
    } else
    {
        // Extract the filename for insertion into the MZF header.
        char *baseFileName = basename(addFile);
        if(baseFileName == NULL)
        {
            printf("Error processing filename to extract basename.\n");
            exit(50);
        }
        char *dot=strchr(baseFileName, '.');
        if(dot != NULL)
        {
            *dot = 0x00;
        }
        convertToSharpFileName(baseFileName);
            
        rfs_directory[dirEntry].flag2 = attribute;
        for(int idx=0; idx < 17; idx++)
        {
            rfs_directory[dirEntry].fileName[idx] = (idx >= strlen(baseFileName) ? 0x0d : baseFileName[idx]);
        }
        rfs_directory[dirEntry].startSector = swap_endian((RFS_FILEBLOCK_START + (dirEntry * RFS_FILESIZE))/512);
        rfs_directory[dirEntry].size = fileSize;
        rfs_directory[dirEntry].loadAddr = loadAddr;
        rfs_directory[dirEntry].execAddr = execAddr;
    }
    fseek(fpImage, 0, SEEK_SET);
    result=fwrite(&rfs_directory, 1, sizeof(rfs_dirent) * RFS_MAX_DIR_ENTRIES, fpImage);
    if(result < (RFS_MAX_DIR_ENTRIES * RFS_DIR_ENTRY_SIZE))
    {
        printf("Failed to write RFS directory into image file, disk full or wrong permissions?\n");
        exit(50);
    }

    // Seek to the correct 64K block then write out 64K.
    fseek(fpImage, (RFS_FILEBLOCK_START + (dirEntry * RFS_FILESIZE)), SEEK_SET);
    for(uint32_t idx=0; idx < RFS_FILESIZE; idx++)
    {
        int c = fgetc(fpAdd);
        if(feof(fpAdd))
            c = 0xFF;
        fputc(c, fpImage);
    }

    if(verbose_flag)
        printf("Added %s to image.\n", addFile);

    // Tidy up, close and finish.
    fclose(fpAdd);
    fclose(fpImage);
    if(verbose_flag)
        printf("Image file updated.\n");
}
