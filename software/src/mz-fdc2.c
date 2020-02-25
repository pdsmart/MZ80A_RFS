/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            mz-fdc2.c
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

// Store the track data in preallocated memory, no point using dynamic memory as the floppy is so small.
typedef struct {
    char   track[MAX_FDC_SECTORS * MAX_FDC_SECTORSIZE];
} t_track;

static t_track tracks[MAX_FDC_TRACKS];

typedef struct {
    int    srcTrack;
    int    linearTrack;
    int    physicalTrack;
    int    physicalHead;
    int    offset;
} t_trackmapping;

// Mapping table from Floppy image (Amstrad CPC Extended as raw) to linear image.
static t_trackmapping trackMapping[] = {
    { 1,    0,    31,   1,        0 },
    { 0,    1,    32,   0,     4352 },
    { 3,    2,    32,   1,     8704 },
    { 2,    3,    33,   0,    13056 },
    { 5,    4,    33,   1,    17408 },
    { 4,    5,    34,   0,    21760 },
    { 7,    6,    34,   1,    26112 },
    { 6,    7,    28,   0,    30464 },
    { 9,    8,    28,   1,    34816 },
    { 8,    9,    29,   0,    39168 },
    { 11,   10,   29,   1,    43520 },
    { 10,   11,   30,   0,    47872 },
    { 13,   12,   30,   1,    52224 },
    { 12,   13,   31,   0,    56576 },
    { 15,   14,   24,   1,    60928 },
    { 14,   15,   25,   0,    65280 },
    { 17,   16,   25,   1,    69632 },
    { 16,   17,   26,   0,    73984 },
    { 19,   18,   26,   1,    78336 },
    { 18,   19,   27,   0,    82688 },
    { 21,   20,   27,   1,    87040 },
    { 20,   21,   21,   0,    91392 },
    { 23,   22,   21,   1,    95744 },
    { 22,   23,   22,   0,   100096 },
    { 25,   24,   22,   1,   104448 },
    { 24,   25,   23,   0,   108800 },
    { 27,   26,   23,   1,   113152 },
    { 26,   27,   24,   0,   117504 },
    { 29,   28,   17,   1,   121856 },
    { 28,   29,   18,   0,   126208 },
    { 31,   30,   18,   1,   130560 },
    { 30,   31,   19,   0,   134912 },
    { 33,   32,   19,   1,   139264 },
    { 32,   33,   20,   0,   143616 },
    { 35,   34,   20,   1,   147968 },
    { 34,   35,   14,   0,   152320 },
    { 37,   36,   14,   1,   156672 },
    { 36,   37,   15,   0,   161024 },
    { 39,   38,   15,   1,   165376 },
    { 38,   39,   16,   0,   169728 },
    { 41,   40,   16,   1,   174080 },
    { 40,   41,   17,   0,   178432 },
    { 43,   42,   10,   1,   182784 },
    { 42,   43,   11,   0,   187136 },
    { 45,   44,   11,   1,   191488 },
    { 44,   45,   12,   0,   195840 },
    { 47,   46,   12,   1,   200192 },
    { 46,   47,   13,   0,   204544 },
    { 49,   48,   13,   1,   208896 },
    { 48,   49,    7,   0,   213248 },
    { 51,   50,    7,   1,   217600 },
    { 50,   51,    8,   0,   221952 },
    { 53,   52,    8,   1,   226304 },
    { 52,   53,    9,   0,   230656 },
    { 55,   54,    9,   1,   235008 },
    { 54,   55,    10,  0,   239360 },
    { 57,   56,    3,   1,   243712 },
    { 56,   57,    4,   0,   248064 },
    { 59,   58,    4,   1,   252416 },
    { 58,   59,    5,   0,   256768 },
    { 61,   60,    5,   1,   261120 },
    { 60,   61,    6,   0,   265472 },
    { 63,   62,    6,   1,   269824 },
    { 62,   63,    0,   0,   274176 },
    { 65,   64,    0,   1,   278528 },
    { 64,   65,    1,   0,   282880 },
    { 67,   66,    1,   1,   287232 },
    { 66,   67,    2,   0,   291584 },
    { 69,   68,    2,   1,   295936 },
    { 68,   69,    3,   0,   300288 },
    { 71,   70,    2,   1,   295936 },
    { 70,   71,    3,   0,   300288 },
    { 73,   72,    2,   1,   295936 },
    { 72,   73,    3,   0,   300288 },
    { 75,   74,    2,   1,   295936 },
    { 74,   75,    3,   0,   300288 },
    { 77,   76,    2,   1,   295936 },
    { 76,   77,    3,   0,   300288 },
    { 79,   78,    2,   1,   295936 },
    { 78,   79,    3,   0,   300288 },
    { 81,   80,    2,   1,   295936 },
    { 80,   81,    3,   0,   300288 },
};


int main(int argc, char *argv[])
{

    int  opt; 
    int  option_index      = 0; 
    int  mode_flag         = -1;
    int  idx;
    int  idx2;
    int  trkidx;
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

    for(idx=0; idx < FDC_TRACKS; idx++)
    {
        fread(tracks[idx].track, 1, trackSize, inFile);
    }

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

    fclose(inFile);
    fclose(outFile);
}
