/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            mz-fdc.c
// Created:         January 2019
// Author(s):       Philip Smart
// Description:     MZ-80A FDC file image manipulator.
//                  This program manipulates stored floppy images from the format used on physical disks 
//                  to/from an ordered linear image.
//
// Credits:         
// Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
//
// History:         January 2020   - Initial script written.
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

// MZ-80A/B Floppy disk description.
#define MAX_FDC_TRACKS     100
#define MAX_FDC_SECTORS    20
#define MAX_FDC_SECTORSIZE 256
#define MAX_FDC_SIDES      2

typedef struct {
    char      name[34];
    char      creator[14];
    uint8_t   tracks;
    uint8_t   sides;
    uint8_t   unused[2];
    uint8_t   track_table[MAX_FDC_TRACKS * MAX_FDC_SIDES ];
} t_diskinfoblock;

typedef struct {
    uint8_t   track;
    uint8_t   side;
    uint8_t   sectorid;
    uint8_t   sectorsize;
    uint8_t   fdcstatus1;
    uint8_t   fdcstatus2;
    uint8_t   datalen[2];
} t_sectorinfolist;

typedef struct {
    char       id[13];
    uint8_t    unused[3];
    uint8_t    track;
    uint8_t    side;
    uint8_t    unused2[2];
    uint8_t    sectorsize;
    uint8_t    numsectors;
    uint8_t    gap3len;
    uint8_t    filler;
    t_sectorinfolist sectorinfolist[MAX_FDC_SECTORS];
} t_trackinfoblock;

// Store the track data in preallocated memory, no point using dynamic memory as the floppy is so small.
typedef struct {
    char   track[MAX_FDC_SECTORS * MAX_FDC_SECTORSIZE];
} t_track;
static t_track tracks[MAX_FDC_TRACKS];
typedef struct {
    char   block[ MAX_FDC_SECTORSIZE ];
} t_block;
typedef struct {
    char   block1[ 128 ];
    char   block2[ 128 ];
} t_infoblock;
static t_block blocks[MAX_FDC_TRACKS * MAX_FDC_SIDES * MAX_FDC_SECTORS ];
t_diskinfoblock *diskInfoBlock;
t_sectorinfolist *sectorInfoList;
t_trackinfoblock *trackInfoBlock;
t_infoblock infoBlock;

char *sectors[MAX_FDC_TRACKS][MAX_FDC_SIDES][MAX_FDC_SECTORS];

int main(int argc, char *argv[])
{

    int  opt; 
    int  option_index      = 0; 
    int  mode_flag         = -1;
    int  idx;
    int  idx2;
    int  secidx;
    int  sideidx;
    int  trkidx;
    int  numTracks;
    int  numSides;
    int  numSectors;
    int  maxBlocks;
    int  trackNo;
    int  sectorNo;
    int  sideNo;
    int  sectorSize;
    int  FDC_TRACKS;
    int  FDC_SECTORS;
    int  FDC_SECTORSIZE;
    int  FDC_INVERT = 0;
    int  trackSize;
    char inputFile[1024];
    char outputFile[1024];
    long fileSize;
    FILE *inFile;
    FILE *outFile;

    static struct option long_options[] =
    {
        {"from-linear", no_argument,       0,   'f'},
        {"to-linear",   no_argument,       0,   't'},
        {"input",       required_argument, 0,   'i'},
        {"output",      required_argument, 0,   'o'},
        {0,             0,                 0,   0}
    };

    // Initialise variables to defaults.
    inputFile[0] = 0x00;
    outputFile[0] = 0x00;
      
    // Parse the command line options.
    //
    while((opt = getopt_long(argc, argv, ":tfi:o:", long_options, &option_index)) != -1)  
    {  
        switch(opt)  
        {  
            case 'f':
                mode_flag = 0;
                printf("Mode flag set to 0\n");
                break;

            case 't':
                mode_flag = 1;
                printf("Mode flag set to 1\n");
                break;

            case 'i':
                strcpy(inputFile, optarg);
                printf("Input file set to:%s\n", inputFile);
                break;

            case 'o':
                strcpy(outputFile, optarg);
                printf("Output file set to:%s\n", outputFile);
                break;
 
            case ':':  
                printf("Option %s needs a value\n", argv[optind-1]);  
                break;  
            case '?':  
                printf("Unknown option: %s, ignoring!\n", argv[optind-1]); 
                break;  
        }  
    } 

    if(strlen(inputFile) == 0 )
    {
        printf("Input file not specified.\n");
        exit(10);     
    }
    if(strlen(outputFile) == 0 )
    {
        printf("Output file not specified.\n");
        exit(11);     
    }
    if(mode_flag == -1)
    {
        printf("Mode not set, should be --to-linear or --from-linear.\n");
        exit(12);
    }
    inFile  = fopen(inputFile,  "r");
    outFile = fopen(outputFile, "w");
    if(inFile == NULL)
    {
        printf("Couldnt open the input file:%s.\n", inputFile);
        exit(20);     
    }
    if(outFile == NULL)
    {
        printf("Couldnt open the output file:%s.\n", outputFile);
        exit(21);     
    }
    fseek(inFile, 0, SEEK_END);
    fileSize = ftell(inFile);
    fseek(inFile, 0, SEEK_SET);
    switch(fileSize)
    {
        case 358144:
            FDC_TRACKS     = 82;
            FDC_SECTORS    = 17;
            FDC_SECTORSIZE = 256;
            FDC_INVERT     = 2;
            break;

        case 357632:
            FDC_TRACKS     = 82;
            FDC_SECTORS    = 17;
            FDC_SECTORSIZE = 256;
            FDC_INVERT     = 2;
            break;

        case 304640:
            FDC_TRACKS     = 70;
            FDC_SECTORS    = 17;
            FDC_SECTORSIZE = 256;
            FDC_INVERT     = 2;
            break;

        case 286720:
            FDC_TRACKS     = 70;
            FDC_SECTORS    = 16;
            FDC_SECTORSIZE = 256;
            FDC_INVERT     = 2;
            break;

        case 327680:
            FDC_TRACKS     = 80;
            FDC_SECTORS    = 16;
            FDC_SECTORSIZE = 256;
            FDC_INVERT     = 1;
            break;

        case 348416:
            FDC_TRACKS     = 80;
            FDC_SECTORS    = 17;
            FDC_SECTORSIZE = 256;
            FDC_INVERT     = 1;
            break;

        case 184576:
            FDC_TRACKS     = 80;
            FDC_SECTORS    = 16;
            FDC_SECTORSIZE = 128;
            FDC_INVERT     = 0;
            break;

        default:
            printf("Unrecognised file size:%d\n", fileSize);
            exit(22); 
    }
    trackSize = FDC_SECTORS * FDC_SECTORSIZE;

//    FDC_TRACKS = fileSize / (FDC_SECTORSIZE * 
//    if(fileSize < (FDC_TRACKS * FDC_SECTORS * FDC_SECTORSIZE))
//    {
//        printf("Input file is too small, configuration is:\n    Tracks = %d, Sectors = %d, Sector Size = %d, Total Floppy Size = %ld\n", FDC_TRACKS, FDC_SECTORS, FDC_SECTORSIZE, (FDC_TRACKS * FDC_SECTORS * FDC_SECTORSIZE));
//        exit(22);     
//    }
//    if(fileSize > (FDC_TRACKS * FDC_SECTORS * FDC_SECTORSIZE))
//    {
//        printf("Input file is too large, configuration is:\n    Tracks = %d, Sectors = %d, Sector Size = %d, Total Floppy Size = %ld\n", FDC_TRACKS, FDC_SECTORS, FDC_SECTORSIZE, (FDC_TRACKS * FDC_SECTORS * FDC_SECTORSIZE));
//        exit(23);     
//    }
//
    idx = 0;
    while(!feof(inFile))
    {
        fread(blocks[idx].block, 1, FDC_SECTORSIZE, inFile);
        idx++;
    }
    maxBlocks = idx;
    printf("Read in %d blocks\n", maxBlocks);

    // Verify disk information block.
    //
    diskInfoBlock = (t_diskinfoblock *)&blocks[0].block;
    if(strncmp(diskInfoBlock->name, "EXTENDED CPC DSK File\r\nDisk-Info\r\n", 34) == 0)
    {
        memcpy((char *)&infoBlock.block1, blocks[0].block, sizeof(blocks[0].block));
        memcpy((char *)&infoBlock.block2, blocks[1].block, sizeof(blocks[1].block));
        diskInfoBlock = (t_diskinfoblock *)&infoBlock;

        printf("Image is in Extended CPC DiSK Format\n");
        printf("Name of creator:%s\n", diskInfoBlock->creator);
        numTracks = (int)diskInfoBlock->tracks;
        numSides  = (int)diskInfoBlock->sides;
        printf("Number of tracks:%d\n", numTracks);
        printf("Number of sides:%d\n",  numSides);
    } else
    {
        printf("Image header is not correct, name=%s\n", diskInfoBlock->name);
        exit(30);
    }

    idx = 2;
    while(idx < maxBlocks)
    {
        trackInfoBlock = (t_trackinfoblock *)&blocks[idx].block;
        if(strncmp(trackInfoBlock->id, "Track-Info\r\n", 13) == 0)
        {
            memcpy((char *)&infoBlock.block1, blocks[idx].block, 128); //sizeof(blocks[idx].block));
            memcpy((char *)&infoBlock.block2, blocks[idx+1].block, 128); //sizeof(blocks[idx+1].block));
            trackInfoBlock = (t_trackinfoblock *)&infoBlock;
            idx+=2;

            printf("Block %d is a track information block.\n", idx);
            trackNo     = (int)trackInfoBlock->track;
            sideNo      = (int)trackInfoBlock->side;
            sectorSize  = (int)trackInfoBlock->sectorsize;
            numSectors  = (int)trackInfoBlock->numsectors;
            switch(sectorSize) 
            {
                case 1:
                    sectorSize = 128;
                    break;

                case 2:
                    sectorSize = 256;
                    //numSectors *= 2;
                    break;

                default:
                    break;
            }

            printf("Track Number: %d\n", trackNo);
            printf("Side Number:  %d\n", sideNo);
            printf("Sector Size:  %d\n", sectorSize);
            printf("# Sectors:    %d\n", numSectors);

            for(secidx=0; secidx < numSectors; secidx++)
            {
                sectorInfoList = (t_sectorinfolist *)&trackInfoBlock->sectorinfolist[secidx];
                printf("--> Sector ID:    %d\n", (int)sectorInfoList->sectorid);
                sectors[trackNo][sideNo][(int)sectorInfoList->sectorid - 1] = (char *)&blocks[idx].block;
                printf("%08lx, %08lx\n", &sectors[trackNo][sideNo][((int)sectorInfoList->sectorid - 1)], blocks[idx].block );
                idx++;
                if(sectorSize == 256)
                {
                    secidx++;
                    sectorInfoList = (t_sectorinfolist *)&trackInfoBlock->sectorinfolist[secidx];
                    printf("--> Sector ID:    %d\n", (int)sectorInfoList->sectorid);
                    sectors[trackNo][sideNo][(int)sectorInfoList->sectorid - 1] = (char *)&blocks[idx].block;
                    printf("%08lx, %08lx\n", &sectors[trackNo][sideNo][((int)sectorInfoList->sectorid - 1)], blocks[idx].block );
                    idx++;
                }
                //idx++;
                //fwrite(blocks[idx].block, 1, sectorSize, outFile);
            }
        } else
        {
            idx++;
        }
    }

    for(idx=0; idx < numTracks; idx++)
    {
        for(sideidx=0; sideidx <numSides; sideidx++)
        {
            for(secidx=0; secidx < numSectors*2; secidx++)
            {
                printf("%08lx, Side:%d, Track:%d, Sector:%d\n", sectors[idx][sideidx][secidx], sideidx, idx, secidx);
                if(sectors[idx][sideidx][secidx] != NULL)
                    fwrite((char *)sectors[idx][sideidx][secidx], 1, sectorSize, outFile);
            }
        }
    }

/*
    for(idx=0; idx < FDC_TRACKS; idx++)
    {
        switch(mode_flag)
        {
            // from linear
            case 0:
                for(trkidx=0; trkidx < FDC_TRACKS && trackMapping[trkidx].linearTrack != idx; trkidx++);
                printf("Mapping track:%d for src track:%d\n", trkidx, idx);
                break;

            // to linear
            case 1:
                for(trkidx=0; trkidx < FDC_TRACKS && trackMapping[trkidx].srcTrack != idx; trkidx++);
                printf("Mapping track:%d to track:%d\n", idx, trkidx);
                break;

        }
        if(trkidx < FDC_TRACKS)
        {
            if(FDC_INVERT == 2 || (FDC_INVERT == 1 && trkidx == 1))
            {
                for(idx2=0; idx2 < (FDC_SECTORS * FDC_SECTORSIZE); idx2++)
                {
                    tracks[trkidx].track[idx2] = ~tracks[trkidx].track[idx2];
                }
            }
            fwrite(tracks[trkidx].track, 1, trackSize, outFile);
        }
    }
*/

    fclose(inFile);
    fclose(outFile);
}
