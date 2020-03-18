/*----------------------------------------------------------------------*/
/* Petit FatFs sample project for generic uC  (C)ChaN, 2010             */
/*----------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include "pff.h"
#include "sdmmc.h"

FATFS *FatFs;	/* Pointer to the file system object (logical drive) */
extern BYTE SDBUF[];

void die (        /* Stop with dying message */
    FRESULT rc    /* FatFs return value */
)
{
    printf("Failed with rc=%u.\n", rc);
    printf("Please press reset.\n");
    sleep(10);
    for (;;) ;
}

/*-----------------------------------------------------------------------*/
/* Program Main                                                          */
/*-----------------------------------------------------------------------*/

int main (void)
{
    FATFS fatfs;            /* File system object */
    DIR dir;                /* Directory object */
    FILINFO fno;            /* File information object */
    UINT bw, br, i;
    BYTE buff[64];
    FRESULT rc;    /* FatFs return value */
    unsigned char idx;
    unsigned char b;
    unsigned char ib;

    printf("Petit FatFS Test Program, Sharp MZ80A\n");

    printf("Firstly, initialise SD card\n");
    rc = FR_NOT_ENABLED;
    DSTATUS res = disk_initialize();
    if(!res)
    {
        printf("\nNow Mount a volume.\n");
        rc = pf_mount(&fatfs);
        if (rc)
        {
            printf("Failed to initialise sd card 0, please init manually.\n");
            die(rc);
        } else
        {
            printf("Volume mounted.\n");
        }
    } else
    {
        printf("Failed disk initialise, RES=%02x.\n", res);
        die(res);
    }
    BYTE *p = SDBUF;
    for(i = 0; i < 11; i++)
        printf("%02x", *p++);
    printf("\n");
    printf("SDVER:%02x, SDCAP:%02x\n", SDVER, SDCAP);
    sleep(1);

    printf("FSTYPE:%d, FLAG:%d, CSIZE:%d, PADL:%d, N_FATENT:%ld, FATBASE:%;d\n", fatfs.fs_type, fatfs.flag, fatfs.csize, fatfs.pad1, fatfs.n_fatent, fatfs.fatbase);
    printf("DIRBASE:%ld, DATABASE:%ld, FPTR:%ld, FSIZE:%ld, ORG_CLUST:%ld, CURR_CLUST:%ld, DSECT:%ld\n", fatfs.dirbase, fatfs.database,fatfs.fptr, fatfs.fsize, fatfs.org_clust, fatfs.curr_clust, fatfs.dsect);
    sleep(1);

    printf("\nOpen root directory.\n");
    rc = pf_opendir(&dir, "");
    if (rc) die(rc);

    printf("\nDirectory listing...\n");
    for (;;) {
        rc = pf_readdir(&dir, &fno);    /* Read a directory item */
        if (rc || !fno.fname[0]) break;    /* Error or end of dir */
        if (fno.fattrib & AM_DIR)
            printf("   <dir>  %s\n", fno.fname);
        else
            printf("%8lu  %s\n", fno.fsize, fno.fname);
    }
    if (rc && rc != FR_NO_FILE) die(rc);

    printf("\nOpen file to read (message.txt).\n");
    rc = pf_open("MESSAGE.TXT");
    if (rc) die(rc);

    printf("\nOutput contents.\n");
    while(1)
    {
        rc = pf_read(buff, sizeof(buff), &br);    /* Read a chunk of file */
        if (rc || !br) break;            /* Error or end of file */
        for (i = 0; i < br; i++)        /* Type the data */
            if(buff[i] != 0x0d)
                putchar(buff[i]);
    }
    if (rc) die(rc);

    sleep(5);

    printf("\nOpen file to write (readme.txt).\n");
    rc = pf_open("README.TXT");
    if (rc) die(rc);

    printf("\nWrite some repetitive text. (Hello world!)\n");
    for (;;) {
        rc = pf_write("Hello world!\r\n", 14, &bw);
        if (rc || !bw) break;
    }
    if (rc) die(rc);

    printf("\nClose the file.\n");
    rc = pf_write(0, 0, &bw);
    if (rc) die(rc);


    printf("\nTest completed.\n");
    for (;;) ;
}
