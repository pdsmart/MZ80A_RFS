;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cbios.asm
;- Created:         January 2020
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM BIOS System.
;-                  This is the CPM CBIOS for the Sharp MZ80A hardware plus RFS/80 char upgrades.
;-                  It makes extensive use of the paged roms to add functionality and conserve
;-                  RAM for the CPM applications.
;-
;- Credits:         Some of the comments and parts of the standard CPM deblocking/blocking algorithm 
;-                  come from the Z80-MBC2 project, (C) SuperFabius.
;- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
;-
;- History:         January 2020 - Seperated Bank from RFS for dedicated use with CPM CBIOS.
;--------------------------------------------------------------------------------------------------------
;- This source file is free software: you can redistribute it and-or modify
;- it under the terms of the GNU General Public License as published
;- by the Free Software Foundation, either version 3 of the License, or
;- (at your option) any later version.
;-
;- This source file is distributed in the hope that it will be useful,
;- but WITHOUT ANY WARRANTY; without even the implied warranty of
;- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;- GNU General Public License for more details.
;-
;- You should have received a copy of the GNU General Public License
;- along with this program.  If not, see <http://www.gnu.org/licenses/>.
;--------------------------------------------------------------------------------------------------------

            ORG     CBIOSSTART

            ;-------------------------------------------------------------------------------
            ;                                                                              
            ;  BIOS jump table                                                             
            ;                                                                              
            ;-------------------------------------------------------------------------------
            JP      BOOT_
            JP      WBOOT_
            JP      CONST_
            JP      CONIN_
            JP      CONOUT_
            JP      LIST_
            JP      PUNCH_
            JP      READER_
            JP      HOME_
            JP      SELDSK_
            JP      SETTRK_
            JP      SETSEC_
            JP      SETDMA_
            JP      READ_
            JP      WRITE_
            JP      LISTST_
            JP      SECTRN_
            RET

; Methods to access public functions in paged User Rom. The User Rom bank
; is switched in and a jump made to the public function. The page remains
; selected until the next public access call and the page changed accordingly.

BANK4:      PUSH    AF
            LD      A,ROMBANK4
            LD      (RFSBK2),A
            POP     AF
            RET
BANK5:      PUSH    AF
            LD      A,ROMBANK5
            LD      (RFSBK2),A
            POP     AF
            RET

; Public methods for User Rom CBIOS Bank 1
?REBOOT:    CALL    BANK4
            JP      QREBOOT

?MLDY:      CALL    BANK4
            JP      QMELDY

?BEL:       CALL    BANK4
            JP      QBEL

?TEMP:      CALL    BANK4
            JP      QTEMP

?MLDST:     CALL    BANK4
            JP      QMSTA

?MLDSP:     CALL    BANK4
            JP      QMSTP

; Public methods for User Rom CBIOS Bank 2

?PRNT:      CALL    BANK5
            JP      QPRNT

?PRTHX:     CALL    BANK5
            JP      QPRTHX

?PRTHL:     CALL    BANK5
            JP      QPRTHL

?ANSITERM:  CALL    BANK5
            JP      QANSITERM

?NL:        LD      A,LF
            JR      ?PRNT

?PRTS:      LD      A,SPACE
            JR      ?PRNT

; Public methods for User Rom CBIOS Bank 3
            LD      A,ROMBANK6
            LD      (RFSBK2),A
            JP      00000h
; Public methods for User Rom CBIOS Bank 4
            LD      A,ROMBANK7
            LD      (RFSBK2),A
            JP      00000h


            ;-------------------------------------------------------------------------------
            ;  BOOT                                                                        
            ;                                                                              
            ;  The BOOT entry point gets control from the cold start loader and is         
            ;  responsible for basic system initialization, including sending a sign-on    
            ;  message, which can be omitted in the first version.                         
            ;  If the IOBYTE function is implemented, it must be set at this point.        
            ;  The various system parameters that are set by the WBOOT entry point must be 
            ;  initialized, and control is transferred to the CCP at 3400 + b for further  
            ;  processing. Note that register C must be set to zero to select drive A.     
            ;
            ; NB. This code is executed by the MZF loader. The following code is assembled
            ; in the header at $1108 to ensure correct startup.
            ; LD A,($E00C)   ; - Switch ROM to location $C000
            ; LD A,ROMBANK2  ; - Switch to the CBIOS rom in bank 2 of the monitor rom bank.
            ; LD ($EFFC),A   ; - Perform the bank switch.
            ; JP $C000       ; - Go to BOOT_
            ;-------------------------------------------------------------------------------
BOOT_:      LD      SP,BIOSSTACK
            CALL    INIT                                                ; Initialise CBIOS.
            ;
            LD      DE,CPMSIGNON
            CALL    MONPRTSTR
            ;
            JP      GOCPM

            ;-------------------------------------------------------------------------------
            ;  WBOOT                                                                       
            ;                                                                               
            ;  The WBOOT entry point gets control when a warm start occurs.                
            ;  A warm start is performed whenever a user program branches to location      
            ;  0000H, or when the CPU is reset from the front panel. The CP/M system must  
            ;  be loaded from the first two tracks of drive A up to, but not including,    
            ;  the BIOS, or CBIOS, if the user has completed the patch. System parameters  
            ;  must be initialized as follows:                                             
            ;                                                                              
            ;  location 0,1,2                                                              
            ;      Set to JMP WBOOT for warm starts (000H: JMP 4A03H + b)                  
            ;                                                                              
            ;  location 3                                                                  
            ;      Set initial value of IOBYTE, if implemented in the CBIOS                
            ;                                                                              
            ;  location 4                                                                  
            ;      High nibble = current user number, low nibble = current drive           
            ;                                                                              
            ;  location 5,6,7                                                              
            ;      Set to JMP BDOS, which is the primary entry point to CP/M for transient 
            ;      programs. (0005H: JMP 3C06H + b)                                        
            ;                                                                              
            ;  Refer to Section 6.9 for complete details of page zero use. Upon completion 
            ;  of the initialization, the WBOOT program must branch to the CCP at 3400H+b  
            ;  to restart the system.                                                      
            ;  Upon entry to the CCP, register C is set to the drive to select after system
            ;  initialization. The WBOOT routine should read location 4 in memory, verify  
            ;  that is a legal drive, and pass it to the CCP in register C.                
            ;-------------------------------------------------------------------------------
WBOOT_:     LD      SP,BIOSSTACK
            CALL    WINIT
GOCPM:      JP      CCP                                                  ; Start the CCP.


            ;-------------------------------------------------------------------------------
            ;  CONOUT                                                                      
            ;                                                                              
            ;  The character is sent from register C to the console output device.         
            ;  The character is in ASCII, with high-order parity bit set to zero. You      
            ;  might want to include a time-out on a line-feed or carriage return, if the  
            ;  console device requires some time interval at the end of the line (such as  
            ;  a TI Silent 700 terminal). You can filter out control characters that cause 
            ;  the console device to react in a strange way (CTRL_Z causes the Lear-       
            ;  Siegler terminal to clear the screen, for example).                         
            ;-------------------------------------------------------------------------------
CONOUT_:    LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            LD      A,C
            CALL    ?ANSITERM
            LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET

            ;-------------------------------------------------------------------------------
            ;  CONIN                                                                       
            ;                                                                              
            ;  The next console character is read into register A, and the parity bit is   
            ;  set, high-order bit, to zero. If no console character is ready, wait until  
            ;  a character is typed before returning.                                      
            ;-------------------------------------------------------------------------------
CONIN_:     LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            CALL    GETKY
            LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET

            ;-------------------------------------------------------------------------------
            ;  CONST                                                                       
            ;                                                                              
            ;  You should sample the status of the currently assigned console device and   
            ;  return 0FFH in register A if a character is ready to read and 00H in        
            ;  register A if no console characters are ready.                              
            ;-------------------------------------------------------------------------------
CONST_:     LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            CALL    CHKKY
            LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET

            ;-------------------------------------------------------------------------------
            ;  READER                                                                      
            ;                                                                              
            ;  The next character is read from the currently assigned reader device into   
            ;  register A with zero parity (high-order bit must be zero); an end-of-file   
            ;  condition is reported by returning an ASCII CTRL_Z(1AH).                    
            ;-------------------------------------------------------------------------------
READER_:    LD      A, 01AH                                              ; Reader not implemented.
            RET

            ;-------------------------------------------------------------------------------
            ;  PUNCH                                                                       
            ;                                                                              
            ;  The character is sent from register C to the currently assigned punch       
            ;  device. The character is in ASCII with zero parity.                         
            ;-------------------------------------------------------------------------------
PUNCH_:     RET             ; Punch not implemented

            ;-------------------------------------------------------------------------------
            ;  LIST                                                                        
            ;                                                                              
            ;  The character is sent from register C to the currently assigned listing     
            ;  device. The character is in ASCII with zero parity bit.                     
            ;-------------------------------------------------------------------------------
LIST_:      RET

            ;-------------------------------------------------------------------------------
            ;  LISTST                                                                      
            ;                                                                              
            ;  You return the ready status of the list device used by the DESPOOL program  
            ;  to improve console response during its operation. The value 00 is returned  
            ;  in A if the list device is not ready to accept a character and 0FFH if a    
            ;  character can be sent to the printer. A 00 value should be returned if LIST 
            ;  status is not implemented.                                                  
            ;-------------------------------------------------------------------------------
LISTST_:    XOR      A    ; Not implemented.
            RET

            ;-------------------------------------------------------------------------------
            ;  HOME                                                                        
            ;                                                                              
            ;  The disk head of the currently selected disk (initially disk A) is moved to 
            ;  the track 00 position. If the controller allows access to the track 0 flag  
            ;  from the drive, the head is stepped until the track 0 flag is detected. If  
            ;  the controller does not support this feature, the HOME call is translated   
            ;  into a call to SETTRK with a parameter of 0.                                
            ;-------------------------------------------------------------------------------
HOME_:      LD      BC,00000H

            ;-------------------------------------------------------------------------------
            ;  SETTRK                                                                      
            ;                                                                              
            ;  Register BC contains the track number for subsequent disk accesses on the   
            ;  currently selected drive. The sector number in BC is the same as the number 
            ;  returned from the SECTRN entry point. You can choose to seek the selected   
            ;  track at this time or delay the seek until the next read or write actually  
            ;  occurs. Register BC can take on values in the range 0-76 corresponding to   
            ;  valid track numbers for standard floppy disk drives and 0-65535 for         
            ;  nonstandard disk subsystems.                                                
            ;-------------------------------------------------------------------------------
SETTRK_:    LD      (SEKTRK),BC ; Set track passed from BDOS in register BC.
            RET     

            ;-------------------------------------------------------------------------------
            ;  SETSEC                                                                      
            ;                                                                              
            ;  Register BC contains the sector number, 1 through 26, for subsequent disk   
            ;  accesses on the currently selected drive. The sector number in BC is the    
            ;  same as the number returned from the SECTRAN entry point. You can choose to 
            ;  send this information to the controller at this point or delay sector       
            ;  selection until a read or write operation occurs.                           
            ;-------------------------------------------------------------------------------
SETSEC_:    LD      A,C   ; Set sector passed from BDOS in register BC.
            LD      (SEKSEC), A
            RET     

            ;-------------------------------------------------------------------------------
            ;  SETDMA                                                                      
            ;                                                                              
            ;  Register BC contains the DMA (Disk Memory Access) address for subsequent    
            ;  read or write operations. For example, if B = 00H and C = 80H when SETDMA   
            ;  is called, all subsequent read operations read their data into 80H through  
            ;  0FFH and all subsequent write operations get their data from 80H through    
            ;  0FFH, until the next call to SETDMA occurs. The initial DMA address is      
            ;  assumed to be 80H. The controller need not actually support Direct Memory   
            ;  Access. If, for example, all data transfers are through I/O ports, the      
            ;  CBIOS that is constructed uses the 128 byte area starting at the selected   
            ;  DMA address for the memory buffer during the subsequent read or write       
            ;  operations.                                                                 
            ;-------------------------------------------------------------------------------
SETDMA_:    LD      (DMAADDR),BC
            RET     

            ;-------------------------------------------------------------------------------
            ;  SELDSK                                                                      
            ;                                                                              
            ;  The disk drive given by register C is selected for further operations,      
            ;  where register C contains 0 for drive A, 1 for drive B, and so on up to 15  
            ;  for drive P (the standard CP/M distribution version supports four drives).  
            ;  On each disk select, SELDSK must return in HL the base address of a 16-byte 
            ;  area, called the Disk Parameter Header, described in Section 6.10.          
            ;  For standard floppy disk drives, the contents of the header and associated  
            ;  tables do not change; thus, the program segment included in the sample      
            ;  CBIOS performs this operation automatically.                                
            ;                                                                              
            ;  If there is an attempt to select a nonexistent drive, SELDSK returns        
            ;  HL = 0000H as an error indicator. Although SELDSK must return the header    
            ;  address on each call, it is advisable to postpone the physical disk select  
            ;  operation until an I/O function (seek, read, or write) is actually          
            ;  performed, because disk selects often occur without ultimately performing   
            ;  any disk I/O, and many controllers unload the head of the current disk      
            ;  before selecting the new drive. This causes an excessive amount of noise    
            ;  and disk wear. The least significant bit of register E is zero if this is   
            ;  the first occurrence of the drive select since the last cold or warm start. 
            ;-------------------------------------------------------------------------------
SELDSK_:    LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            LD      HL, 00000H                                           ; HL = error code
            LD      A, C                                                 ; A = disk number
            CP      NDISKS
            JR      C, SELDSK0                                           ; Ensure we dont select a non existant disk.
            XOR     A                                                    ; No, set disk 0 as current disk
SELDSK0:    LD      (CDISK),A                                            ; Setup drive.
            CALL    SETDRVCFG                                
          ; CALL    SELDRIVE
            LD      A,(DISKTYPE)
            CP      1
            JR      Z,SELROMDSK
            LD      A,C                                                  ; Check again and if disk valid, calculate the DPB address.
            CP      NDISKS                                               ; Drive number ok?
            JR      C, CALCHL                                            ; Yes, jump
SELDSK1:    LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET


SELROMDSK:  LD      A,(ROMDRV)
            OR      A
            JR      NZ,SELDSK2
            LD      DE,(CPMROMDRV0)                                      ; Retrieve the bank and page the image is located at.
            JR      SELDSK3
SELDSK2:    LD      DE,(CPMROMDRV1)                                      ; Retrieve the bank and page the image is located at.
SELDSK3:    INC     DE
            LD      A,D
            OR      E
            JR      Z,SELDSK1                                            ; If the bank and page are FFFFh then no drive, exit.
            ;
            LD      A,C
            ;
            ; Code for blocking and deblocking algorithm
            ; (see CP/M 2.2 Alteration Guide p.34 and APPENDIX G)
CALCHL:     LD      (SEKDSK),A
            RLC     A                                                    ; *2
            RLC     A                                                    ; *4
            RLC     A                                                    ; *8
            RLC     A                                                    ; *16
            LD      HL,CPMDPBASE
            LD      B,0
            LD      C,A 
            ADD     HL,BC
            JR      SELDSK1

            ;-------------------------------------------------------------------------------
            ;  SECTRAN                                                                     
            ;                                                                              
            ;  Logical-to-physical sector translation is performed to improve the overall  
            ;  response of CP/M. Standard CP/M systems are shipped with a skew factor of   
            ;  6, where six physical sectors are skipped between each logical read         
            ;  operation. This skew factor allows enough time between sectors for most     
            ;  programs to load their buffers without missing the next sector. In          
            ;  particular computer systems that use fast processors, memory, and disk      
            ;  subsystems, the skew factor might be changed to improve overall response.   
            ;  However, the user should maintain a single-density IBM-compatible version   
            ;  of CP/M for information transfer into and out of the computer system, using 
            ;  a skew factor of 6.                                                         
            ;                                                                              
            ;  In general, SECTRAN receives a logical sector number relative to zero in BC 
            ;  and a translate table address in DE. The sector number is used as an index  
            ;  into the translate table, with the resulting physical sector number in HL.  
            ;  For standard systems, the table and indexing code is provided in the CBIOS  
            ;  and need not be changed.                                                    
            ;-------------------------------------------------------------------------------
SECTRN_:    LD      H,B
            LD      L,C
            RET     


            ;-------------------------------------------------------------------------------
            ;  READ                                                                        
            ;                                                                              
            ;  Assuming the drive has been selected, the track has been set, and the DMA   
            ;  address has been specified, the READ subroutine attempts to read one sector 
            ;  based upon these parameters and returns the following error codes in        
            ;  register A:                                                                 
            ;                                                                              
            ;      0 - no errors occurred                                                  
            ;      1 - non recoverable error condition occurred                            
            ;                                                                              
            ;  Currently, CP/M responds only to a zero or nonzero value as the return      
            ;  code. That is, if the value in register A is 0, CP/M assumes that the disk  
            ;  operation was completed properly. If an error occurs the CBIOS should       
            ;  attempt at least 10 retries to see if the error is recoverable. When an     
            ;  error is reported the BDOS prints the message BDOS ERR ON x: BAD SECTOR.    
            ;  The operator then has the option of pressing a carriage return to ignore    
            ;  the error, or CTRL_C to abort.                                              
            ;-------------------------------------------------------------------------------
            ;
            ; Code for blocking and deblocking algorithm
            ; (see CP/M 2.2 Alteration Guide p.34 and APPENDIX G)
            ;
READ_:      LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            XOR     A
            LD      (UNACNT), A
            LD      A, 1
            LD      (READOP), A                                          ; read operation
            LD      (RSFLAG), A                                          ; must read data
            LD      A, WRUAL
            LD      (WRTYPE), A                                          ; treat as unalloc
            CALL    RWOPER                                               ; to perform the read, returns with A=0 no errors or A > 0 errors.
            LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET

            ;-------------------------------------------------------------------------------
            ;  WRITE                                                                       
            ;                                                                              
            ;  Data is written from the currently selected DMA address to the currently    
            ;  selected drive, track, and sector. For floppy disks, the data should be     
            ;  marked as nondeleted data to maintain compatibility with other CP/M         
            ;  systems. The error codes given in the READ command are returned in register 
            ;  A, with error recovery attempts as described above.                         
            ;-------------------------------------------------------------------------------
            ;
            ; Code for blocking and deblocking algorithm
            ; (see CP/M 2.2 Alteration Guide p.34 and APPENDIX G)
            ;
WRITE_:     LD      (SPSAVE),SP                                          ; The original monitor routines and the enhancements can use
            LD      SP,BIOSSTACK                                         ; more stack space than the 16 words provided by CPM.
            XOR     A                                                    ; 0 to accumulator
            LD      (READOP), A                                          ; not a read operation
            LD      A, C                                                 ; write type in c
            LD      (WRTYPE), A
            CP      WRUAL                                                ; write unallocated?
            JR      NZ, CHKUNA                                           ; check for unalloc
            ; write to unallocated, set parameters
            LD      A, BLKSIZ/128                                        ; next unalloc recs
            LD      (UNACNT), A
            LD      A, (SEKDSK)                                          ; disk to seek
            LD      (UNADSK), A                                          ; unadsk = sekdsk
            LD      HL, (SEKTRK)
            LD      (UNATRK), HL                                         ; unatrk = sectrk
            LD      A, (SEKSEC)
            LD      (UNASEC), A                                          ; unasec = seksec
            ; check for write to unallocated sector
CHKUNA:     LD      A,(UNACNT)                                           ; any unalloc remain?
            OR      A   
            JR      Z, ALLOC                                             ; skip if not
            ; more unallocated records remain
            DEC     A                                                    ; unacnt = unacnt-1
            LD      (UNACNT), A
            LD      A, (SEKDSK)                                          ; same disk?
            LD      HL, UNADSK
            CP      (HL)                                                 ; sekdsk = unadsk?
            JP      NZ, ALLOC                                            ; skip if not
            ; disks are the same
            LD      HL, UNATRK
            CALL    SEKTRKCMP                                            ; sektrk = unatrk?
            JP      NZ, ALLOC                                            ; skip if not
            ;   tracks are the same
            LD      A, (SEKSEC)                                          ; same sector?
            LD      HL, UNASEC
            CP      (HL)                                                 ; seksec = unasec?
            JP      NZ, ALLOC                                            ; skip if not
            ; match, move to next sector for future ref
            INC     (HL)                                                 ; unasec = unasec+1
            LD      A, (HL)                                              ; end of track?
            CP      CPMSPT                                               ; count CP/M sectors
            JR      C, NOOVF                                             ; skip if no overflow
            ; overflow to next track
            LD      (HL), 0                                              ; unasec = 0
            LD      HL, (UNATRK)
            INC     HL
            LD      (UNATRK), HL                                         ; unatrk = unatrk+1
            ; match found, mark as unnecessary read
NOOVF:      XOR     A                                                    ; 0 to accumulator
            LD      (RSFLAG), A                                          ; rsflag = 0
            JR      ALLOC2                                               ; to perform the write
            ; not an unallocated record, requires pre-read
ALLOC:      XOR     A                                                    ; 0 to accum
            LD      (UNACNT), A                                          ; unacnt = 0
            INC     A                                                    ; 1 to accum
ALLOC2:     LD      (RSFLAG), A                                          ; rsflag = 1
            CALL    RWOPER
            LD      SP,(SPSAVE)                                          ; Restore the CPM stack.
            RET

            ;-------------------------------------------------------------------------------
            ;  INIT                                                                      
            ;                                                                              
            ;  Cold start initialisation routine. Called on CPM first start.
            ;-------------------------------------------------------------------------------
INIT:       DI
            IM      1
            LD      HL,VARSTART                                          ; Start of variable area
            LD      BC,VAREND-VARSTART                                   ; Size of variable area.
            XOR     A
            CALL    CLRMEM                                               ; Clear memory.
            CALL    ?MODE
            LD      A,016H
            CALL    ?PRNT
            LD      A,017H                                               ; Blue background, white characters in colour mode. Bit 7 is set as a write to bit 7 @ DFFFH selects 80Char mode.
            LD      HL,ARAM
STRT1:      CALL    CLR8
            LD      A,004H
            LD      (TEMPW),A

            ; Setup keyboard buffer control.
            LD      A,0
            LD      (KEYCOUNT),A                                         ; Set keyboard buffer to empty.
            LD      HL,KEYBUF
            LD      (KEYWRITE),HL                                        ; Set write pointer to beginning of keyboard buffer.
            LD      (KEYREAD),HL                                         ; Set read pointer to beginning of keyboard buffer.

            ; Setup keyboard rate control and set to CAPSLOCK mode.
            ; (0 = Off, 1 = CAPSLOCK, 2 = SHIFTLOCK).
            LD      HL,00002H                                            ; Initialise key repeater.
            LD      (KEYRPT),HL
            LD      A,001H
            LD      (SFTLK),A                                            ; Setup shift lock, default = off.

            ; Setup the initial cursor, for CAPSLOCK this is a double underscore.
            LD      A,03EH
            LD      (FLSDT),A
            LD      A,080H                                               ; Cursor on (Bit D7=1).
            LD      (FLASHCTL),A

            ; Change to 80 character mode.
            LD      A, 128                                               ; 80 char mode.
            LD      (DSPCTL), A
            CALL    ?MLDSP
            CALL    ?NL
            LD      DE,CBIOSSIGNON
            CALL    MONPRTSTR
            CALL    ?NL
            CALL    ?BEL
            LD      A,0FFH
            LD      (SWRK),A

            ; Setup timer interrupts
            LD      BC,00000H                                            ; Time starts at 00:00:00 01/01/1980 on initialisation.
            LD      DE,00000H
            LD      HL,00000H
            CALL    TIMESET

            ; Locate the CPM Image and store the Bank/Block to speed up warm boot.
            LD      HL,CPMROMFNAME                                       ; Name of CPM File in rom.
            CALL    FINDMZF
            JP      NZ,ROMFINDERR                                        ; Failed to find CPM in the ROM!
            LD      (CPMROMLOC),BC

            ; Locate the ROMFS CPM Disk Image to be mapped as drive D.
            LD      HL,0FFFFh
            LD      (CPMROMDRV0),HL
            LD      (CPMROMDRV1),HL
            LD      HL,CPMRDRVFN0                                        ; Name of CPM Rom Drive File 0 in rom.
            CALL    FINDMZF
            JR      NZ,STRT2                                             ; Failed to find the drive image in the ROM!
            LD      (CPMROMDRV0),BC                                      ; If found store the bank and page the image is located at.
STRT2:      LD      HL,CPMRDRVFN1                                        ; Name of CPM Rom Drive File 1 in rom.
            CALL    FINDMZF
            JR      NZ,STRT3                                             ; Failed to find the drive image in the ROM!
            LD      (CPMROMDRV1),BC                                      ; If found store the bank and page the image is located at.

STRT3:      LD      HL,NUMBERBUF
            LD      (NUMBERPOS),HL
            ;
            XOR     A
            LD      (IOBYT),A
            LD      (CDISK),A            
            ;
            JR      CPMINIT
            
            ;-------------------------------------------------------------------------------
            ;  WINIT                                                                      
            ;                                                                              
            ; Warm start initialisation routine. Called whenever CPM is restarted by an
            ; exitting TPA program or a simple warm start call to vector 00000h.
            ;
            ; Warm boot initialisation. Called by CPM when a warm restart is
            ; required, reinitialise any needed hardware and reload CCP+BDOS.
            ;-------------------------------------------------------------------------------
WINIT:      DI
            ; Reload the CCP and BDOS from ROM.
            LD      DE,CPMBIOS-CBASE                                     ; Only want to load in CCP and BDOS.
            LD      BC,(CPMROMLOC)                                       ; Load up the Bank and Page where the CPM Image can be found.
            CALL    MROMLOAD
            LD      A,ROMBANK5
            LD      (RFSBK2),A    
            ;
CPMINIT:    CALL    DSKINIT                                              ; Initialise the disk subsystem.
            XOR     A                                                    ; 0 to accumulator
            LD      (HSTACT),A                                           ; Host buffer inactive
            LD      (UNACNT),A                                           ; Clear unalloc count
            ; CP/M init
            LD      A, 0C3H                                              ; C3 IS A JMP INSTRUCTION
            LD      (00000H), A                                          ; FOR JMP TO WBOOT
            LD      HL,WBOOTE                                            ; WBOOT ENTRY POINT
            LD      (00001H), HL                                         ; SET ADDRESS FIELD FOR JMP AT 0
            LD      (00005H), A                                          ; FOR JMP TO BDOS
            LD      HL, CPMBDOS                                          ; BDOS ENTRY POINT
            LD      (00006H), HL                                         ; ADDRESS FIELD OF JUMP AT 5 TO BDOS
            LD      HL,TIMIN                                             ; Install interrupt vector for RTC.
            LD      (00038H),A
            LD      (00039H),HL
            LD      BC,CPMUSERDMA
            CALL    SETDMA_
            EI                                                           ; Interrupts on for the RTC.
            ; check if current disk is valid
            LD      A, (CDISK)                                           ; GET CURRENT USER/DISK NUMBER (UUUUDDDD)
            AND     00FH                                                 ; Isolate the disk number.
            CP      NDISKS                                               ; Drive number ok?
            JR      C, WBTDSKOK2                                         ; Yes, jump (Carry set if A < NDISKS)
            LD      A, (CDISK)                                           ; No, set disk 0 (previous user)
            AND     0F0H
            LD      (CDISK), A                                           ; Save User/Disk    
WBTDSKOK2:  CALL    SETDRVMAP                                            ; Refresh the map of physical floppies to CPM drive number.
            CALL    SETDRVCFG
            LD      A,(DISKTYPE)
            OR      A
            CALL    Z,SELDRIVE                                           ; Select and start disk drive motor if floppy disk.
            LD      A, (CDISK)
            LD      C, A                                                 ; C = current User/Disk for CCP jump (UUUUDDDD)
            RET


            ;-------------------------------------------------------------------------------
            ; TIMER INTERRUPT                                                                      
            ;                                                                              
            ; This is the RTC interrupt, which interrupts every 100msec. RTC is maintained
            ; by keeping an in memory count of seconds past 00:00:00 and an AMPM flag.
            ;-------------------------------------------------------------------------------
TIMIN:      LD      (SPISRSAVE),SP                                       ; CP/M has a small working stack, an interrupt could exhaust it so save interrupts stack and use a local stack.
            LD      SP,ISRSTACK
            ;
            PUSH    AF                                                   ; Save used registers.
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            ; Reset the interrupt counter.
            LD      HL,CONTF                                             ; CTC Control register, set to reload the 100ms interrupt time period.
            LD      (HL),080H                                              ; Select Counter 2, latch counter, read lsb first, mode 0 and binary.
            PUSH    HL
            DEC     HL
            LD      E,(HL)
            LD      D,(HL)                                               ; Obtain the overrun count if any (due to disabled interrupts).
            LD      HL, 00001H                                           ; Add full range to count to obtain the period of overrun time.
            SBC     HL,DE
            EX      DE,HL
            POP     HL
            LD      (HL),0B0H                                            ; Select Counter 2, load lsb first, mode 0 interrupt on terminal count, binary
            DEC     HL
            LD      (HL),TMRTICKINTV
            LD      (HL),000H                                            ; Another 100msec delay till next interrupt.
            ;
            ; Update the RTC with the time period.
            LD      HL,(TIMESEC)                                         ; Lower 16bits of counter.
            ADD     HL,DE
            LD      (TIMESEC),HL
            JR      NC,TIMIN1                                            ; On overflow we increment middle 16bits.
            ; 
            LD      HL,(TIMESEC+2)
            INC     HL 
            LD      (TIMESEC+2),HL
            LD      A,H
            OR      L
            JR      NZ,TIMIN1                                            ; On overflow we increment upper 16bits.
            ;
            LD      HL,(TIMESEC+4)
            INC     HL 
            LD      (TIMESEC+4),HL

            ;
            ; Flash a cursor at the current XY location.
            ;
TIMIN1:     LD      HL,FLASHCTL
            BIT     7,(HL)                                               ; Is cursor enabled? If it isnt, skip further processing.
            JR      Z,TIMIN2
            ;
FLSHCTL0:   LD      A,(KEYPC)                                            ; Flashing component, on each timer tick, display the cursor or the original screen character.
            LD      C,A
            XOR     (HL)                                                 ; Detect a cursor change signal.
            RLCA    
            RLCA    
            JR      NC,TIMIN2                                            ; No change, skip.

            RES     6,(HL)
            LD      A,C                                                  ; We know there was a change, so decide what to display and write to screen.
            RLCA
            RLCA
            LD      A,(FLASH)
            JR      NC,FLSHCTL1
            SET     6,(HL)                                               ; We are going to display the cursor, so save the underlying character.
            LD      A,(FLSDT)                                            ; Retrieve the cursor character.
FLSHCTL1:   LD      HL,(DSPXYADDR)                                       ; Load the desired cursor or character onto the screen.
            LD      (HL),A

            ; 
            ; FDC Motor Off Timer
            ;
TIMIN2:     LD      A,(MTROFFTIMER)                                      ; Is the timer non-zero?
            OR      A
            JR      Z,TIMIN3
            DEC     A                                                    ; Decrement.
            LD      (MTROFFTIMER),A                                      
            JR      NZ,TIMIN3                                            ; If zero after decrement, turn off the motor.
            OUT     (FDC_MOTOR),A                                        ; Turn Motor off
            LD      (MOTON),A                                            ; Clear Motor on flag

            ;
            ; Keyboard processing.
            ;
TIMIN3:     CALL    ?SWEP                                                ; Perform keyboard sweep
            LD      A,B
            RLCA    
            JR      C,ISRKEY2                                            ; CY=1 then data available.
            LD      HL,KDATW
            LD      A,(HL)                                               ; Is a key being held down?
            OR      A
            JR      NZ, ISRAUTORPT                                       ; It is so process as an auto repeat key.
            XOR     A
            LD      (KEYRPT),A                                           ; No key held then clear the auto repeat initial pause counter.
            LD      A,NOKEY                                              ; No key code.
ISRKEY1:    LD      E,A
            LD      A,(HL)                                               ; Current key scan line position.
            INC     HL
            LD      D,(HL)                                               ; Previous key position.
            LD      (HL),A                                               ; Previous <= current
            SUB     D                                                    ; Are they the same?
            JR      NC,ISRKEY11
            INC     (HL)                                                 ; 
ISRKEY11:   LD      A,E
ISRKEY10:   CP      NOKEY
            JR      Z,ISREXIT
            LD      (KEYLAST),A
ISRKEYRPT:  LD      A,(KEYCOUNT)                                         ; Get current count of bytes in the keyboard buffer.
            CP      KEYBUFSIZE - 1
            JR      NC, ISREXIT                                          ; Keyboard buffer full, so waste character.
            INC     A
            LD      (KEYCOUNT),A
            LD      HL,(KEYWRITE)                                        ; Get the write buffer pointer.
            LD      (HL), E                                              ; Store the character.
            INC     L
            LD      A,L
            AND     KEYBUFSIZE-1                                           ; Circular buffer, keep boundaries.
            LD      L,A
            LD      (KEYWRITE),HL                                        ; Store updated pointer.
ISREXIT:    POP     HL
            POP     DE
            POP     BC
            POP     AF
            ;
            LD      SP,(SPISRSAVE)
            EI      
            RET     

            ;
            ; Helper to determine if a key is being held down and autorepeat should be applied.
            ; The criterion is a timer, if this expires then autorepeat is applied.
            ;
ISRAUTORPT: LD      A,(KEYRPT)                                           ; Increment an initial pause counter.
            INC     A
            CP      10
            JR      C,ISRAUTO1                                           ; Once expired we can auto repeat the last key.
            LD      A,(KEYLAST)
            CP      080H
            JR      NC,ISREXIT                                           ; Dont auto repeat control keys.
            LD      E,A
            JR      ISRKEYRPT 
ISRAUTO1:   LD      (KEYRPT),A
            JR      ISREXIT

            ;
            ; Method to alternate through the 3 shift modes, CAPSLOCK=1, SHIFTLOCK=2, NO LOCK=0
            ;
LOCKTOGGLE: LD      HL,FLSDT
            LD      A,(SFTLK)
            INC     A
            CP      3
            JR      C,LOCK0
            XOR     A
LOCK0:      LD      (SFTLK),A
            OR      A
            LD      (HL),043H                                            ; Thick block cursor when lower case.
            JR      Z,LOCK1
            CP      1
            LD      (HL),03EH                                            ; Thick underscore when CAPS lock.
            JR      Z,LOCK1
            LD      (HL),0EFH                                            ; Block cursor when SHIFT lock.
LOCK1:      JP      ISREXIT


ISRKEY2:    RLCA    
            RLCA    
            RLCA    
            JP      C,LOCKTOGGLE                                         ; GRAPH key which acts as the Shift Lock.
            RLCA    
            JP      C,ISRBRK                                             ; BREAK key.
            LD      H,000H
            LD      L,C
            LD      A,C
            CP      038H                                                 ; TEN KEY check.
            JR      NC,ISRKEY6                                           ; Jump if TENKEY.
            LD      A,B
            RLCA    
            LD      B,A
            LD      A,(SFTLK)
            OR      A
            LD      A,B
            JR      Z,ISRKEY14                 
            RLA     
            CCF     
            RRA     
ISRKEY14:   RLA     
            RLA     
            JR      NC,ISRKEY3                
ISRKEY15:   LD      DE,KTBLC
ISRKEY5:    ADD     HL,DE
            LD      A,(HL)
            JP      ISRKEY1                   

ISRKEY3:    RRA     
            JR      NC,ISRKEY6                
            LD      A,(SFTLK)
            CP      1
            LD      DE,KTBLCL
            JR      Z,ISRKEY5
            LD      DE,KTBLS
            JR      ISRKEY5                   

ISRKEY6:    LD      DE,KTBL
            JR      ISRKEY5                   
ISRKEY4:    RLCA    
            RLCA    
            JR      C,ISRKEY15                 
            LD      DE,KTBL
            JR      ISRKEY5                   

            ; Break key pressed, handled in getkey routine.
ISRBRK:     LD      A,(KEYLAST)
            CP      BREAKKEY
            JP      Z,ISREXIT
            XOR     A                                                    ; Reset the keyboard buffer.
            LD      (KEYCOUNT),A
            LD      HL,KEYBUF
            LD      (KEYWRITE),HL
            LD      (KEYREAD),HL
            LD      A,BREAKKEY
            JP      ISRKEY10

            ; KEYBOARD SWEEP
            ;
            ; EXIT B,D7=0    NO DATA
            ;          =1    DATA
            ;        D6=0    SHIFT OFF
            ;          =1    SHIFT ON
            ;      C   =     ROW & COLUMN
            ;
?SWEP:      XOR     A
            LD      (KDATW),A                                            ; Reset key counter
            LD      B,0FAH                                               ; Starting scan line, D3:0 = scan = line 10. D5:4 not used, D7=Cursor flash.
            LD      D,A

            ; BREAK TEST
            ; BREAK ON  : ZERO = 1
            ;       OFF : ZERO = 0
            ; NO KEY    : CY = 0
            ; KEY IN    : CY = 1
            ;     A D6=1: SHIFT ON
            ;         =0: SHIFT OFF
            ;       D5=1: CTRL ON
            ;         =0: CTRL OFF
            ;       D4=1: GRAPH ON
            ;         =0: GRAPH OFF
BREAK:      LD      A,0F0H
            LD      (KEYPA),A                                            ; Port A scan line 0
            NOP     
            LD      A,(KEYPB)                                            ; Read back key data.
            OR      A
            RLA     
            JR      NC,BREAK3                                            ; CTRL/BREAK key pressed?
            RRA     
            RRA                                                          ; Check if SHIFT key pressed/
            JR      NC,BREAK1                                            ; SHIFT BREAK not pressed, jump.
            RRA     
            JR      NC,BREAK2                                            ; Check for GRAPH.
            CCF     
            JR      SWEP6 ;SWEP1     

BREAK1:     LD      A,040H                                               ; A D6=1 SHIFT ON
            SCF     
            JR      SWEP6

BREAK2:     LD      A,001H                                               ; No keys found to be pressed on scanline 0.
            LD      (KDATW),A
            LD      A,010H                                               ; A D4=1 GRAPH
            SCF     
            JR      SWEP6

BREAK3:     AND     006H                                                 ; SHIFT + GRAPH + BREAK?
            JR      Z,SWEP1A
            AND     002H                                                 ; SHIFT ?
            JR      Z,SWEP1                                              ; Z = 1 = SHIFT BREAK pressed/
            LD      A,020H                                               ; A D5=1 CTRL
            SCF     
            JR      SWEP6

SWEP1:      LD      D,088H                                               ; Break ON
            JR      SWEP9                   
SWEP1A:     JP      ?REBOOT                                              ; Shift + Graph + Break ON = RESET.
            ;
            JR      SWEP9                   
SWEP6:      LD      HL,SWPW
            PUSH    HL
            JR      NC,SWEP11                
            LD      D,A
            AND     060H                                                 ; Shift & Ctrl =no data.
            JR      NZ,SWEP11                
            LD      A,D                                                  ; Graph Check
            XOR     (HL)
            BIT     4,A
            LD      (HL),D
            JR      Z,SWEP0                 
SWEP01:     SET     7,D                                                  ; Data available, set flag.
SWEP0:      DEC     B
            POP     HL                                                   ; SWEP column work
            INC     HL
            LD      A,B
            LD      (KEYPA),A                                            ; Port A (8255) D3:0 = Scan line output.
            CP      0F0H
            JR      NZ,SWEP3                                             ; If we are not at scan line 0 then check for key data.              
            LD      A,(HL)                                               ; SWPW
            CP      003H                                                 ; Have we scanned all lines, if yes then no data?
            JR      C,SWEP9                 
            LD      (HL),000H                                            ;
            RES     7,D                                                  ; Reset data in as no data awailable.
SWEP9:      LD      B,D
            RET     

SWEP11:     LD      (HL),000H
            JR      SWEP0                   
SWEP3:      LD      A,(KEYPB)                                            ; Port B (8255) D7:0 = Key data in for given scan line.
            LD      E,A
            CPL     
            AND     (HL)
            LD      (HL),E
            PUSH    HL
            LD      HL,KDATW
            PUSH    BC
            LD      B,008H
SWEP8:      RLC     E
            JR      C,SWEP7                 
            INC     (HL)
SWEP7:      DJNZ    SWEP8                   
            POP     BC
            OR      A
            JR      Z,SWEP0                 
            LD      E,A
SWEP2:      LD      H,008H
            LD      A,B
            DEC     A                                                    ; TBL adjust
            AND     00FH
            RLCA    
            RLCA    
            RLCA    
            LD      C,A
            LD      A,E
SWEP12:     DEC     H
            RRCA    
            JR      NC,SWEP12                
            LD      A,H
            ADD     A,C
            LD      C,A
            JP      SWEP01



            ;-------------------------------------------------------------------------------
            ; END OF TIMER INTERRUPT                                                                      
            ;-------------------------------------------------------------------------------

            ; 
            ; BC:DE:HL contains the time in milliseconds (100msec resolution) since 01/01/1980.
            ; HL contains lower 16 bits, DE contains middle 16 bits, BC contains upper 16bits, allows for a time from 00:00:00 to 23:59:59, for > 500000 days!
TIMESET:    DI      
            PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            LD      (TIMESEC),HL                                         ; Load lower 16 bits.
            EX      DE,HL
            LD      (TIMESEC+2),HL                                       ; Load middle 16 bits.
            PUSH    BC
            POP     HL
            LD      (TIMESEC+4),HL                                       ; Load upper 16 bits.
            ;
            LD      HL,CONTF
            LD      (HL),074H                                            ; Set Counter 1, read/load lsb first then msb, mode 2 rate generator, binary
            LD      (HL),0B0H                                            ; Set Counter 2, read/load lsb first then msb, mode 0 interrupt on terminal count, binary
            DEC     HL
            LD      DE,TMRTICKINTV                                       ; 100Hz coming into Timer 2 from Timer 1, set divisor to set interrupts per second.
            LD      (HL),E                                               ; Place current time in Counter 2
            LD      (HL),D
            DEC     HL
            LD      (HL),03BH                                            ; Place divisor in Counter 1, = 315, thus 31500/315 = 100
            LD      (HL),001H
            NOP     
            NOP     
            NOP     
            ;
            POP     HL
            POP     DE
            POP     BC
           ;EI      
            RET    

            ; Time Read;
            ; Returns BC:DE:HL where HL is lower 16bits, DE is middle 16bits and BC is upper 16bits of milliseconds since 01/01/1980.
TIMEREAD:   LD      HL,(TIMESEC+4)
            PUSH    HL
            POP     BC
            LD      HL,(TIMESEC+2)
            EX      DE,HL
            LD      HL,(TIMESEC)
            RET

?MODE:      LD      HL,KEYPF
            LD      (HL),08AH
            LD      (HL),007H
            LD      (HL),005H
            LD      (HL),001H
            RET     

            ; Method to check if a key has been pressed and stored in buffer.. 
CHKKY:     ;CALL    ?SAVE
            LD      A, (KEYCOUNT)
            OR      A
            JR      Z,CHKKY2
           ;CALL    ?LOAD
            LD      A,0FFH
            RET
CHKKY2:    ;CALL    ?FLAS
           ;CALL    ?LOAD
            XOR     A
            RET

GETKY:      PUSH    HL
            LD      A,(KEYCOUNT)
            OR      A
            JR      Z,GETKY2
GETKY1:     DI                                                           ; Disable interrupts, we dont want a race state occurring.
            LD      A,(KEYCOUNT)
            DEC     A                                                    ; Take 1 off the total count as we are reading a character out of the buffer.
            LD      (KEYCOUNT),A
            LD      HL,(KEYREAD)                                         ; Get the position in the buffer where the next available character resides.
            LD      A,(HL)                                               ; Read the character and save.
            PUSH    AF
            INC     L                                                    ; Update the read pointer and save.
            LD      A,L
            AND     KEYBUFSIZE-1
            LD      L,A
            LD      (KEYREAD),HL
            POP     AF
            EI                                                           ; Interrupts back on so keys and RTC are actioned.
            JR      ?PRCKEY                                              ; Process the key, action any non ASCII keys.
            ;
GETKY2:    ;CALL    ?SAVE                                                ; No key available so loop and exercise the flashing cursor until one becomes
GETKY3:     LD      A,(KEYCOUNT)                                         ; available.
            OR      A
           ;CALL    ?FLAS
            JR      Z,GETKY3                 
           ;CALL    ?LOAD
            JR      GETKY1
            ;
?PRCKEY:    ;PUSH   AF
            ;CALL   ?PRTHX
            ;POP    AF
            CP      CR                                                   ; CR
            JR      NZ,?PRCKY3
            JR      ?PRCKYE
;?PRCKY1:    CP      GRAPHALPHA                                           ; GRAPH -> ALPHA
;            JR      NZ,?PRCKY2
;            XOR     A
;            LD      (KANAF),A
;            JR      GETKY2
;?PRCKY2:    CP      ALPHAGRAPH                                           ; ALPHA -> GRAPH
;            JR      NZ,?PRCKY3
;            LD      A,001H
;            LD      (KANAF),A
;            JR      GETKY2
?PRCKY3:    CP      HOMEKEY                                              ; HOME
            JR      NZ,?PRCKY4
            JR      GETKY2
?PRCKY4:    CP      CLRKEY                                               ; CLR
            JR      NZ,?PRCKY5
            JR      GETKY2
?PRCKY5:    CP      INSERT                                               ; INSERT
            JR      NZ,?PRCKY6
            JR      GETKY2
?PRCKY6:    CP      DBLZERO                                              ; 00
            JR      NZ,?PRCKY7
            LD      A,'0'
            LD      (KEYBUF),A                                           ; Place a character into the keybuffer so we double up on 0
            JR      ?PRCKYX
?PRCKY7:    CP      BREAKKEY                                             ; Break key processing.
            JR      NZ,?PRCKY8

?PRCKY8:
?PRCKYX:    
?PRCKYE:    
            POP     HL
            RET

CLR8Z:      XOR     A
CLR8:       LD      BC,00800H
CLRMEM:     PUSH    DE
            LD      D,A
L09E8:      LD      (HL),D
            INC     HL
            DEC     BC
            LD      A,B
            OR      C
            JR      NZ,L09E8                
            POP     DE
            RET     

?CLER:      XOR     A
            JR      ?DINT                   
?CLRFF:     LD      A,0FFH
?DINT:      LD      (HL),A
            INC     HL
            DJNZ    ?DINT                   
            RET  


            ; HL = Start
            ; DE = End
DUMPX:      LD      A,1
DUM1:       LD      (TMPCNT),A
DUM3:       LD      B,010h
            LD      C,02Fh
            CALL    NLPHL
DUM2:       CALL    SPHEX
            INC     HL
            PUSH    AF
            LD      A,(DSPXY)
            ADD     A,C
            LD      (DSPXY),A
            POP     AF
            CP      020h
            JR      NC,L0D51
            LD      A,02Eh
L0D51:     ;CALL    ?ADCN
           ;CALL    ?PRNT3
            CALL    ?PRNT
            LD      A,(DSPXY)
            INC     C
            SUB     C
            LD      (DSPXY),A
            DEC     C
            DEC     C
            DEC     C
            PUSH    HL
            SBC     HL,DE
            POP     HL
            JR      NC,DUM7
            LD      A,0F8h
            LD      (0E000h),A
            NOP
            LD      A,(0E001h)
            CP      0FEh
            JR      NZ,L0D78
L0D78:      DJNZ    DUM2
            LD      A,(TMPCNT)
            DEC     A
            LD      (TMPCNT),A
            JR      NZ,DUM3
DUM4:       LD      A,(KEYBUF)
            CP      0FFH
            ;CALL    ?KEY
            JR      Z,DUM4
           ;CALL    ?DACN
            CP      'D'
            JR      NZ,DUM5
            LD      A,8
            JR      DUM1
DUM5:       CP      'U'
            JR      NZ,DUM6
            PUSH    DE
            LD      DE,000FFH
            SCF
            SBC     HL,DE
            POP     DE
            LD      A,8
            JR      DUM1
DUM6:       CP      'X'
            JR      Z,DUM7
            JR      DUMPX
DUM7:       CALL    ?NL
            RET

NLPHL:      CALL    ?NL
            CALL    ?PRTHL
            RET

            ; SPACE PRINT AND DISP ACC
            ; INPUT:HL=DISP. ADR.
SPHEX:      CALL    ?PRTS                       ; SPACE PRINT
            LD      A,(HL)
            CALL    ?PRTHX                      ; DSP OF ACC (ASCII)
            LD      A,(HL)
            RET   

            ; Comparing Strings
            ; IN    HL     Address of string1.
            ;       DE     Address of string2.
            ;       BC     Max bytes to compare, 0x00 or 0x0d will early terminate.
            ; OUT   zero   Set if string1 = string2, reset if string1 != string2.
            ;       carry  Set if string1 > string2, reset if string1 <= string2.
CMPSTRING:  PUSH    HL
            PUSH    DE

CMPSTR1:    LD      A, (DE)          ; Compare bytes.
            CP      000h             ; Check for end of string.
            JR      Z,  CMPSTR3
            CP      00Dh
            JR      Z,  CMPSTR3
            CPI                      ; Compare bytes.
            JR      NZ, CMPSTR2      ; If (HL) != (DE), abort.
            INC     DE               ; Update pointer.
            JP      PE, CMPSTR1      ; Next byte if BC not zero.

CMPSTR2:    DEC     HL
            CP      (HL)            ; Compare again to affect carry.
CMPSTR4:    POP     DE
            POP     HL
            RET

CMPSTR3:    LD      A, (HL)
            CP      000h             ; Check for end of string.
            JR      Z, CMPSTR4
            CP      00Dh
            JR      Z, CMPSTR4
            SCF                      ; String 1 greater than string 2
            JR      CMPSTR4

            ; HL contains address of block to check.
ISMZF:      PUSH    BC
            PUSH    DE
            PUSH    HL
            ;
            LD      A,(HL)
            CP      001h                        ; Only interested in machine code images.
            JR      NZ, ISMZFNOT
            ;
            INC     HL
            LD      DE,NAME                     ; Checks to confirm this is an MZF header.
            LD      B,17                        ; Maximum of 17 characters, including terminator in filename.
ISMZFNXT:   LD      A,(HL)
            LD      (DE),A
            CP      00Dh                        ; If we find a terminator then this indicates potentially a valid name.
            JR      Z, ISMZFVFY
            CP      020h                        ; >= Space
            JR      C, ISMZFNOT
            CP      05Dh                        ; =< ]
            JR      C, ISMZFNXT3
ISMZFNXT2:  CP      091h
            JR      C, ISMZFNOT                 ; DEL or > 0x7F, cant be a valid filename so this is not an MZF header.
ISMZFNXT3:  INC     DE
            INC     HL
            DJNZ    ISMZFNXT
            JR      ISMZFNOT                    ; No end of string terminator, this cant be a valid filename.
ISMZFVFY:   LD      A,B
            CP      17
            JR      Z,ISMZFNOT                  ; If the filename has no length it cant be valid, so loop.
ISMZFYES:   CP      A                           ; Set zero flag to indicate match.
ISMZFNOT:   POP     HL
            POP     DE
            POP     BC
            RET

            ; In:
            ;     HL = filename
            ; Out:
            ;      B = Bank Page file found
            ;      C = Block where found.
            ;      D = File sequence number.
            ;      Z set if found.
FINDMZF:    LD       (TMPADR), HL                ; Save name of program to load.  
            ;
            ; Scan MROM Bank
            ; B = Bank Page
            ; C = Block in page
            ; D = File sequence number.
            ;
FINDMZF0:   LD      B,8                         ; First 8 pages are reserved in User ROM bank.
            LD      C,0                         ; Block in page.
            LD      D,0                         ; File numbering start.
FINDMZF1:   LD      A,B
            LD      (RFSBK2), A                 ; Select bank.
FINDMZF2:   PUSH    BC                          ; Preserve bank count/block number.
            PUSH    DE                          ; Preserve file numbering.
            LD      HL,0E800h + RFS_ATRB        ; Add block offset to get the valid block.
            LD      A,C
            IF RFSSECTSZ >= 512
              RLCA
            ENDIF
            IF RFSSECTSZ >= 1024
              RLCA
            ENDIF
            LD      B,A
            LD      C,0
            ADD     HL,BC
            CALL    ISMZF                       ; Check to see if this looks like a header entry.
            POP     DE
            POP     BC
            JR      NZ, FINDMZF4                ; Z set if we found an MZF record.
            INC     HL                          ; Save address of filename.
FINDMZF3:   PUSH    DE
            PUSH    BC
            LD      DE,(TMPADR)                 ; Original DE put onto stack, original filename into DE 
            LD      BC,17
            CALL    CMPSTRING
            POP     BC
            POP     DE
            JR      Z, FINDMZFYES
            INC     D                           ; Next file sequence number.           
FINDMZF4:   INC     C
            LD      A,C
            CP      UROMSIZE/RFSSECTSZ          ; Max blocks per page reached?
            JR      C, FINDMZF5
            LD      C,0
            INC     B
FINDMZF5:   LD      A,B
            CP      000h                        ; User ROM has 256 banks of 2K, so stop when we wrap around to zero.
            JR      NZ, FINDMZF1
            INC     B
            JR      FINDMZFNO

FINDMZFYES:                                     ; Z Flag set by previous test.
FINDMZFNO:  RET


           ; Load Program from ROM
           ; IN    BC     Bank and Block of MZF file.
           ;       DE     0 - use file size in header, > 0 file size to load.
           ; OUT   zero   Set if file loaded, reset if an error occurred.
           ;
           ; Load program from RFS Bank 1 (MROM Bank)
           ;
MROMLOAD:   PUSH    BC
            PUSH    DE
            LD      A,B
            LD      (RFSBK2), A
            ;
            LD      DE, IBUFE                   ; Copy the header into the work area.
            LD      HL, 0E800h                  ; Add block offset to get the valid block.
            LD      A,C
            IF RFSSECTSZ >= 512
              RLCA
            ENDIF
            IF RFSSECTSZ >= 1024
              RLCA
            ENDIF
            LD      B,A
            LD      C,0
            ADD     HL,BC
            LD      BC, MZFHDRNCSZ
            LDIR
            LD      DE,MZFHDRSZ - MZFHDRNCSZ    ; Account for the full MZF header (we only load the initial part to save RAM).
            ADD     HL,DE
            POP     DE
            LD      A,D                         ; Test DE, if 0 the use the size to load from header.
            OR      E                           ;          if not 0, use size to load in DE.
            JR      Z,LROMLOAD1
            LD      (SIZE),DE                   ; Overwrite the header size with the new size to load.

LROMLOAD1:  PUSH    HL
            LD      DE, (DTADR)
            LD      HL, (SIZE)
            LD      BC, RFSSECTSZ - MZFHDRSZ
            SBC     HL, BC
            JR      NC, LROMLOAD4
            LD      HL, (SIZE)
            JR      LROMLOAD4

            ; HL = address in active block to read.
            ;  B = Bank
            ;  C = Block 
LROMLOAD2:  LD      A, B
            LD      (RFSBK2), A

LROMLOAD3:  PUSH    BC
            LD      HL, 0E800h
            LD      A, C
            IF RFSSECTSZ >= 512
              RLCA
            ENDIF
            IF RFSSECTSZ >= 1024
              RLCA
            ENDIF
            LD      B, A
            LD      C, 0
            ADD     HL,BC
            PUSH    HL

            LD      DE, (TMPADR)
            LD      HL, (TMPSIZE)
            LD      BC, RFSSECTSZ
            CCF
            SBC     HL, BC
            JR      NC, LROMLOAD4
            LD      BC, (TMPSIZE)
            LD      HL, 0
LROMLOAD4:  LD      (TMPSIZE), HL               ; HL contains remaining amount of bytes to load.
            POP     HL
            ;
            LD      A, B                        ; Pre check to ensure BC is not zero.
            OR      C
            JR      Z, LROMLOAD8
            LDIR
            LD      BC, (TMPSIZE)
            LD      A, B                        ; Post check to ensure we still have bytes
            OR      C
            JR      Z, LROMLOAD8
            ;
            LD      (TMPADR),DE                 ; Address we are loading into.
            POP     BC
LROMLOAD6:  INC     C
            LD      A, C
            CP      UROMSIZE/RFSSECTSZ          ; Max blocks per page reached?
            JR      C, LROMLOAD7
            LD      C, 0
            INC     B
            ;
LROMLOAD7:  LD      A, B
            CP      000h
            JR      NZ, LROMLOAD2
            OR      1
            JR      LROMLOAD5
            ;
LROMLOAD8:  POP     BC
LROMLOAD5:  PUSH    AF
            LD      A,ROMBANK7
            LD      (RFSBK2), A                 ; Set the MROM bank back to original.
            POP     AF
            RET

            ; Calculate offset into the ROM of the required sector.
            ; The sector size is 128 bytes due to the MZF header creating a 128 byte offset. Larger sector
            ; sizes will need to see the math enhanced to cater for the offset.
ROMREAD:    LD      DE,(HSTTRK)                                          ; To cater for larger RFS images in the future we use the full 16bit track number.
            LD      (TRACKNO),DE
            LD      A, BANKSPERTRACK * SECTORSPERBANK
            LD      B,8 
            LD      HL,0 
ROMREAD2:   ADD     HL,HL 
            RLCA 
            JR      NC,ROMREAD3
            ADD     HL,DE
ROMREAD3:   DJNZ    ROMREAD2
            ; HL contains the number of sectors for the given tracks.
            LD      A,(HSTSEC)
            OR      A
            RL      A
            RL      A
            LD      (SECTORNO), A                                        ; Sector number converted from host 512 byte to local RFS 128 byte.
            LD      E,A
            LD      D,0
            ADD     HL,DE                                                ; Add the number of sectors.
            ; HL contains the number of sectors for the given tracks and sector.
            PUSH    HL
            LD      A,(ROMDRV)
            OR      A
            JR      NZ,ROMREAD3A
            LD      BC,(CPMROMDRV0)
            JR      ROMREAD3B
ROMREAD3A:  LD      BC,(CPMROMDRV1)
ROMREAD3B:  LD      A,C
            LD      E,B                                                  ; Place number of banks offset and multiply into sectors.
            LD      D,0
            LD      A,SECTORSPERBANK
            LD      B,8 
            LD      HL,0 
ROMREAD4:   ADD     HL,HL 
            RLCA 
            JR      NC,ROMREAD5
            ADD     HL,DE                                                
ROMREAD5:   DJNZ    ROMREAD4                                             ; HL contains the number of sectors for the offset to the drive image.
            POP     DE
            ADD     HL,DE
            ; HL contains the sectors for the number of tracks plus the sectors for the offset to the drive image.
                                                                          ; C contains current block number.
            LD      D,SECTORSPERBLOCK                                     ; Calculate the sectors in the block offset (as RFS uses a different sector size).
            LD      B,8 
ROMREAD6:   XOR     A 
            RLCA
            RLC     C
            JR      NC,ROMREAD7
            ADD     A,D 
ROMREAD7:   DJNZ    ROMREAD6
            LD      E,A
            LD      D,0
            INC     HL                                                   ; The MZF Header consumes 1 sector so skip it.
            ADD     HL,DE                                                ; HL contains the final absolute sector number to read in ROM.

            ; Divide HL by SECTORSPERBANK to obtain the starting bank.
            LD      C,SECTORSPERBANK
            LD      B,16
            XOR     A
ROMREAD8:   ADD     HL,HL
            RLA
            CP      C
            JR      C,ROMREAD9
            INC     L
            SUB     C
ROMREAD9:   DJNZ    ROMREAD8
            ; HL contains the absolute bank number. A contains the block sector.
            PUSH    HL
            LD      DE,ROMSECTORSIZE
            LD      B,8 
            LD      HL,0
ROMREAD10:  ADD     HL,HL 
            RLCA 
            JR      NC,ROMREAD11
            ADD     HL,DE
ROMREAD11:  DJNZ    ROMREAD10
            LD      DE,UROMADDR
            ADD     HL,DE
            POP     DE                                                   ; DE contains the absolute bank number, HL contains the address offset in that bank.
            LD      C,A
            LD      B,E                                                  ; Currently only 8bit bank number, store in B.
            LD      A, E
            LD      (RFSBK2), A                                          ; Starting bank.
            PUSH    BC
            PUSH    HL
            LD      DE,HSTBUF                                            ; Target is the host buffer.
            LD      HL,384                                               ; Size of host sector.
            LD      BC,ROMSECTORSIZE
            JR      ROMREAD14

            ; HL = address in active block to read.
            ;  B = Bank
            ;  C = Block 
ROMREAD12:  LD      A, B
            LD      (RFSBK2), A
            ;
            LD      A,H                                                  ; If we reach the top of the user rom space, wrap around.
            CP      FDCROMADDR / 0100H                                   ; Compare high byte against high byte of floppy rom.
            JR      NZ,ROMREAD13
            LD      HL,UROMADDR
            ;
ROMREAD13:  PUSH    BC
            PUSH    HL
            LD      DE, (TMPADR)
            LD      HL, (TMPSIZE)
            LD      BC, ROMSECTORSIZE ;128 ;RFSSECTSZ
            CCF
            SBC     HL, BC
            JR      NC, ROMREAD14
            LD      BC, (TMPSIZE)
            LD      HL, 0
ROMREAD14:  LD      (TMPSIZE), HL                                        ; HL contains remaining amount of bytes to load.
            POP     HL
            ;
            LD      A, B                                                 ; Pre check to ensure BC is not zero.
            OR      C
            JR      Z, ROMREAD17
            LDIR
            LD      BC, (TMPSIZE)
            LD      A, B                                                 ; Post check to ensure we still have bytes
            OR      C
            JR      Z, ROMREAD17
            ;
            LD      (TMPADR),DE                                          ; Address we are loading into.
            POP     BC
ROMREAD15:  INC     C
            LD      A, C
            CP      SECTORSPERBANK                                       ; Max blocks per page reached?
            JR      C, ROMREAD16
            LD      C, 0
            INC     B
            ;
ROMREAD16:  LD      A, B
            CP      000h
            JR      NZ, ROMREAD12
            OR      1
            JR      ROMREAD18
            ;
ROMREAD17:  POP     BC
ROMREAD18:  PUSH    AF
            LD      A,ROMBANK7                                           ; Reselect utilities bank.
            LD      (RFSBK2), A                                          ; Set the MROM bank back to original.
            POP     AF
            POP     HL
            POP     BC
            RET

            ; Rom filing system error messages.
ROMLOADERR: LD      DE,ROMLDERRMSG
            JR      MONPRTSTR                                                

ROMFINDERR: LD      DE,ROMFDERRMSG
            JR      MONPRTSTR 

            ; Function to print a string with control character interpretation.
MONPRTSTR:  LD      A,(DE)
            OR      A
            RET     Z
            INC     DE
            CP      LF
            JR      NZ,MONPRTSTR2
            CALL    ?NL
            JR      MONPRTSTR
MONPRTSTR2: CALL    ?PRNT
            JR      MONPRTSTR


            ;-------------------------------------------------------------------------------
            ; RWOPER                                                                      
            ;                                                                              
            ; The common blocking/deblocking algorithm provided by DR to accommodate devices
            ; which have sector sizes bigger than the CPM 128byte standard sector.
            ; In this implementation a sector size of 512 has been chosen regardless of
            ; what the underlying hardware uses (ie. FDC is 256 byte for a standard MZ800
            ; format disk).
            ;-------------------------------------------------------------------------------
RWOPER:     XOR     A                                                    ; zero to accum
            LD      (ERFLAG), A                                          ; no errors (yet)
            LD      A, (SEKSEC)                                          ; compute host sector
            OR      A                                                    ; carry = 0
            RRA                                                          ; shift right
            OR      A                                                    ; carry = 0
            RRA                                                          ; shift right
            LD      (SEKHST), A                                          ; host sector to seek
            ; active host sector?
            LD      HL, HSTACT                                           ; host active flag
            LD      A, (HL)
            LD      (HL), 1                                              ; always becomes 1
            OR      A                                                    ; was it already?
            JR      Z, FILHST                                            ; fill host if not
            ; host buffer active, same as seek buffer?
            LD      A, (SEKDSK)
            LD      HL, HSTDSK                                           ; same disk?
            CP      (HL)                                                 ; sekdsk = hstdsk?
            JR      NZ, NOMATCH
            ; same disk, same track?
            LD      HL, HSTTRK
            CALL    SEKTRKCMP                                            ; sektrk = hsttrk?
            JR      NZ, NOMATCH
            ; same disk, same track, same buffer?
            LD      A, (SEKHST)
            LD      HL, HSTSEC                                           ; sekhst = hstsec?
            CP      (HL)
            JR      Z, MATCH                                             ; skip if match
            ; proper disk, but not correct sector
NOMATCH:    LD      A, (HSTWRT)                                          ; host written?
            OR      A
            CALL    NZ, WRITEHST                                         ; clear host buff
            ; may have to fill the host buffer
FILHST:     LD      A, (SEKDSK)
            LD      (HSTDSK), A
            LD      HL, (SEKTRK)
            LD      (HSTTRK), HL
            LD      A, (SEKHST)
            LD      (HSTSEC), A
            LD      A, (RSFLAG)                                          ; need to read?
            OR      A
            CALL    NZ, READHST                                          ; yes, if 1
            OR      A
            JR      NZ,RWEXIT                                            ; If A > 0 then read error occurred.
            XOR     A                                                    ; 0 to accum
            LD      (HSTWRT), A                                          ; no pending write
            ; copy data to or from buffer
MATCH:      LD      A,  (SEKSEC)                                         ; mask buffer number
            AND     SECMSK                                               ; least signif bits
            LD      L,  A                                                ; ready to shift
            LD      H,  0                                                ; double count
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ADD     HL, HL
            ; hl has relative host buffer address
            LD      DE, HSTBUF
            ADD     HL, DE                                               ; hl = host address
            EX      DE, HL                                               ; now in DE
            LD      HL, (DMAADDR)                                        ; get/put CP/M data
            LD      C, 128                                               ; length of move
            LD      A, (READOP)                                          ; which way?
            OR      A
            JR      NZ, RWMOVE                                           ; skip if read
            ; write operation, mark and switch direction
            LD      A, 1
            LD      (HSTWRT), A                                          ; hstwrt = 1
            EX      DE, HL                                               ; source/dest swap
            ; c initially 128, DE is source, HL is dest
RWMOVE:     LD      A,(INVFDCDATA)                                       ; Check to see if FDC data needs to be inverted. MB8866 controller works on negative logic.
            RRCA
            JR      NC,RWMOVE3
RWMOVE2:    LD      A, (DE)                                              ; source character
            CPL                                                          ; Change to positive values.
            INC     DE
            LD      (HL), A                                              ; to dest
            INC     HL
            DEC     C                                                    ; loop 128 times
            JR      NZ, RWMOVE2
            JR      RWMOVE4
RWMOVE3:    LD      A, (DE)                                              ; source character
            INC     DE
            LD      (HL), A                                              ; to dest
            INC     HL
            DEC     C                                                    ; loop 128 times
            JR      NZ, RWMOVE3
            ; data has been moved to/from host buffer
RWMOVE4:    LD      A, (WRTYPE)                                          ; write type
            CP      WRDIR                                                ; to directory?
            LD      A, (ERFLAG)                                          ; in case of errors
            RET     NZ                                                   ; no further processing
            ; clear host buffer for directory write
            OR      A                                                    ; errors?
            RET     NZ                                                   ; skip if so
            XOR     A                                                    ; 0 to accum
            LD      (HSTWRT), A                                          ; buffer written
            CALL    WRITEHST
RWEXIT:     LD      A, (ERFLAG)
            RET
        
            ; utility subroutine for 16-bit compare
            ; HL = .unatrk or .hsttrk, compare with sektrk
SEKTRKCMP:  EX      DE, HL
            LD      HL, SEKTRK
            LD      A, (DE)                                              ; low byte compare
            CP      (HL)                                                 ; same?
            RET     NZ                                                   ; return if not
            ; low bytes equal, test high 1s
            INC     DE
            INC     HL
            LD      A, (DE)
            CP      (HL)                                                 ; sets flags
            RET


            ;------------------------------------------------------------------------------------------------
            ; Read physical sector from host
            ;
            ; Read data from the floppy disk or RFS. A = 1 if an error occurred.
            ;------------------------------------------------------------------------------------------------
READHST:    PUSH    BC
            PUSH    HL
            LD      A,(DISKTYPE)
            CP      1
            JP      Z,ROMREAD
READHST2:   CALL    DSKREAD
READHST3:   POP     HL
            POP     BC
            RET
        
            ;------------------------------------------------------------------------------------------------
            ; Write physical sector to host
            ;
            ; Write data to the floppy disk or RFS. A = 1 if an error occurred.
            ;------------------------------------------------------------------------------------------------
WRITEHST:   PUSH    BC
            PUSH    HL
            CALL    DSKWRITE
            POP     HL
            POP     BC
            RET


           ;------------------------------------------------------------------------------------------------
            ; Initialise drive and reset flags, Set motor off
            ;
            ;------------------------------------------------------------------------------------------------
DSKINIT:    XOR     A                                                        
            OUT     (FDC_MOTOR),A                                        ; Motor off
            LD      (TRK0FD1),A                                          ; Track 0 flag drive 1
            LD      (TRK0FD2),A                                          ; Track 0 flag drive 2
            LD      (TRK0FD3),A                                          ; Track 0 flag drive 3
            LD      (TRK0FD4),A                                          ; Track 0 flag drive 4
            LD      (MOTON),A                                            ; Motor on flag
            LD      (MTROFFTIMER),A                                      ; Clear the down counter for motor off.
            RET

            ; Function to create a mapping table between a CPM disk and a physical disk.
SETDRVMAP:  PUSH    HL
            PUSH    DE
            PUSH    BC
            ; Zero out the map.
            LD      B,NDISKS
            LD      HL,DISKMAP
            LD      A,0FFH
SETDRVMAP1: LD      (HL),A
            INC     HL
            DJNZ    SETDRVMAP1
            LD      HL,DISKMAP                                           ; Place in the Map for next drive.
            ; Now go through each disk from the Disk Parameter Base list.
            LD      B,0                                                  ; Disk number count = CDISK.
            LD      C,0                                                  ; Physical disk number.
SETDRVMAP2: LD      A,B
            CP      NDISKS
            JR      Z,SETDRVMAP3
            INC     B
            PUSH    HL
            PUSH    BC
            ; For the Disk in A, find the parameter table.
            RLC     A                                                    ; *2
            RLC     A                                                    ; *4
            RLC     A                                                    ; *8
            RLC     A                                                    ; *16
            LD      HL,CPMDPBASE                                         ; Base of disk description block.
            LD      B,0
            LD      C,A 
            ADD     HL,BC                                                ; HL contains address of actual selected disk block.
            LD      C,10
            ADD     HL,BC                                                ; HL contains address of pointer to disk parameter block.
            LD      E,(HL)
            INC     HL
            LD      D,(HL)                                               ; DE contains address of disk parameter block.
            EX      DE,HL
            LD      A,(HL)
            LD      E,A
            LD      BC,15
            ADD     HL,BC                                                ; Move to configuuration byte which identifies the disk type.
            ;
            POP     BC
            BIT     4,(HL)                                               ; Disk type = FDC
            POP     HL
            JR      NZ,SETDRVMAP4                                        ; Loop to next drive if it isnt an FDC controlled disk.
            LD      A,C
            INC     C
            LD      (HL),A
   ;    SCF
   ;    CCF
   ;    CALL DEBUG
SETDRVMAP4: INC     HL
            JR      SETDRVMAP2
            ;
SETDRVMAP3: POP     BC
            POP     DE
            POP     HL
            RET

            ; Function to setup the drive parameters according to the CFG byte in the disk parameter block.
SETDRVCFG:  PUSH    HL
            PUSH    DE
            PUSH    BC
            LD      A,(CDISK)
            RLC     A                                                    ; *2
            RLC     A                                                    ; *4
            RLC     A                                                    ; *8
            RLC     A                                                    ; *16
            LD      HL,CPMDPBASE                                         ; Base of disk description block.
            LD      B,0
            LD      C,A 
            ADD     HL,BC                                                ; HL contains address of actual selected disk block.
            LD      C,10
            ADD     HL,BC                                                ; HL contains address of pointer to disk parameter block.
            LD      E,(HL)
            INC     HL
            LD      D,(HL)                                               ; DE contains address of disk parameter block.
            EX      DE,HL
            LD      A,(HL)
            LD      E,A

            LD      BC,15
            ADD     HL,BC                                                ; Move to configuuration byte.
            XOR     A
            BIT     2,(HL)
            JR      Z,SETDRV0
            INC     A
SETDRV0:    LD      (INVFDCDATA),A                                       ; Data inversion is set according to drive parameter.
            LD      A,4
            BIT     1,(HL)
            JR      Z,SETDRV1
            LD      A,2
            BIT     0,(HL)
            JR      Z,SETDRV1
            LD      A,1
SETDRV1:    LD      (SECTORCNT),A                                        ; Set the disk sector size.
            LD      D,A
            CP      4
            LD      A,E
            JR      Z,SETDRV1A
            OR      A
            RR      A
            LD      E,A
            LD      A,D
            CP      2
            LD      A,E
            JR      Z,SETDRV1A
            OR      A
            RR      A                                                    ; Convert sectors per track from 128 bytes to 256 byte sectors.
SETDRV1A:   INC     A                                                    ; Add 1 to ease comparisons.
            LD      (SECPERTRK),A                                        ; Only cater for 8bit, ie. 256 sectors.
            DEC     A
            OR      A
            RR      A
            INC     A                                                    ; Add 1 to ease comparisons.
            LD      (SECPERHEAD),A                                       ; Convert sectors per track to sectors per head.
            ;
            XOR     A                                                    ; Disk type = FDC
            BIT     4,(HL)
            JR      Z,SETDRV2
            LD      A,1                                                  ; Disk type = ROMFS
            BIT     3,(HL)
            JR      Z,SETDRV2
            LD      A,2                                                  ; Disk type = SD Card
SETDRV2:    LD      (DISKTYPE),A
            XOR     A                                                    ; Select ROMFS Image 0 = DRV0
            BIT     5,(HL)
            JR      Z,SETDRV3
            LD      A,1                                                  ; Select ROMFS Image 1 = DRV1
SETDRV3:    LD      (ROMDRV),A      
            POP     BC
            POP     DE
            POP     HL
            RET

            ; Select fdc drive (make active) based on value in DISKMAP[CDISK].
SELDRIVE:   LD      A,(CDISK)
            LD      HL,DISKMAP
            LD      C,A
            LD      B,0
            ADD     HL,BC
            LD      A,(HL)                                               ; Get the physical number after mapping from the CDISK.
            CP      0FFH
            RET     Z                                                    ; This isnt a physical disk, no need to perform any actions, exit.
            LD      (FDCDISK),A
       ;SCF
       ;CCF
       ;CALL DEBUG
            LD      A,(MOTON)                                            ; motor on flag
            RRCA                                                         ; motor off?
            CALL    NC,DSKMTRON                                          ; yes, set motor on and wait
            LD      A,(FDCDISK)                                          ; select drive no
            OR      084H                                                     
            OUT     (FDC_MOTOR),A                                        ; Motor on for drive 0-3
            XOR     A                                                        
            LD      (FDCCMD),A                                           ; clr latest FDC command byte
            LD      HL,00000H                                                
SELDRV2:    DEC     HL                                                       
            LD      A,H                                                      
            OR      L                                                        
            JP      Z,SELDRVERR                                          ; Reset and print message that this is not a valid disk.
            IN      A,(FDC_STR)                                          ; Status register.
            CPL                                                              
            RLCA                                                             
            JR      C,SELDRV2                                            ; Wait on Drive Ready Bit (bit 7)
            LD      A,(FDCDISK)                                          ; Drive number
            LD      C,A
            LD      HL,TRK0FD1                                           ; 1 track 0 flag for each drive
            LD      B,000H                                                   
            ADD     HL,BC                                                ; Compute related flag 1002/1003/1004/1005
            BIT     0,(HL)                                                   
            JR      NZ,SELDRV3                                           ; If the drive hasnt been intialised to track 0, intialise and set flag.
            CALL    DSKSEEKTK0                                           ; Seek track 0.
            SET     0,(HL)                                               ; Set bit 0 of trk 0 flag
SELDRV3:    CALL    SETDRVCFG
            RET

            ; Turn disk motor on if not already running.
DSKMTRON:   LD      A,(MOTON)                                            ; Test to see if motor is on, if it isnt, switch it on.
            RRCA
            JR      NC, DSKMOTORON
            RET
DSKMOTORON: PUSH    BC
            LD      A,080H
            OUT     (FDC_MOTOR),A                                        ; Motor on
            LD      B,010H                                               ; 
DSKMTR2:    CALL    MTRDELAY                                             ; 
            DJNZ    DSKMTR2                                              ; Wait until becomes ready.
            LD      A,001H                                               ; Set motor on flag.
            LD      (MOTON),A                                            ; 
            POP     BC
            RET      

FDCDLY1:    PUSH    DE
            LD      DE,00007H
            JP      MTRDEL2

MTRDELAY:   PUSH    DE
            LD      DE,01013H
MTRDEL2:    DEC     DE
            LD      A,E
            OR      D
            JR      NZ,MTRDEL2                                           
            POP     DE
            RET    

DSKWRITE:   LD      A,MAXWRRETRY
            LD      (RETRIES),A
            LD      A,(SECTORCNT)
            LD      B,A
            LD      A,(HSTSEC)
DSKWRITE0A: DJNZ    DSKWRITE0B
            JR      DSKWRITE1
DSKWRITE0B: OR      A
            RL      A
            JR      DSKWRITE0A
DSKWRITE1:  INC     A
            LD      (SECTORNO), A                                        ; Convert from Host 512 byte sector into local sector according to paraameter block.
            LD      HL,(HSTTRK)
            LD      (TRACKNO),HL

DSKWRITE2:  CALL    SETTRKSEC                                            ; Set current track & sector, get load address to HL
DSKWRITE3:  CALL    SETHEAD                                              ; Set side reg
            CALL    SEEK                                                 ; Command 1b output (seek)
            JP      NZ,SEEKRETRY                                         ; 
            CALL    OUTTKSEC                                             ; Set track & sector reg

            LD      IX, 0F3FEH                                           ; As below. L03FE
            LD      IY,WRITEDATA                                         ; Write sector from memory.
            DI     
            ;
        SCF
        CALL DEBUG
            LD      A,0B4H                                               ; Write Sector multipe with Side Compare for side 1.
            CALL    DISKCMDWAIT
            LD      D,2                                                  ; Regardless of 4x128, 2x256 or 1x512, we always read 512bytes by the 2x INI instruction with B=256.
STRTDATWR:  LD      B,0                                                  ; 256 bytes to load.
            JP      (IX)

WRITEDATA:  OUTI    
            JP      NZ, 0F3FEH                                           ; This is crucial, as the Z80 is running at 2MHz it is not fast enough so needs
                                                                         ; hardware acceleration in the form of a banked ROM, if disk not ready jumps to IX, if
                                                                         ; data ready, jumps to IY.
            DEC     D
            JP      NZ,0F3FEH                                            ; If we havent read all sectors to form a 512 byte block, go for next sector.
            JR      DATASTOP      

            ; Read disk starting at the first logical sector in param block 1009/100A
            ; Continue reading for the given size 100B/100C and store in the location 
            ; Pointed to by the address stored in the parameter block. 100D/100E
DSKREAD:    LD      A,MAXRDRETRY
            LD      (RETRIES),A
            LD      A,(SECTORCNT)
            LD      B,A
            LD      A,(HSTSEC)
DSKREAD0A:  DJNZ    DSKREAD0B
            JR      DSKREAD1
DSKREAD0B:  OR      A
            RL      A
            JR      DSKREAD0A
DSKREAD1:   INC     A
            LD      (SECTORNO), A                                        ; Convert from Host 512 byte sector into local sector according to paraameter block.
            LD      HL,(HSTTRK)
            LD      (TRACKNO),HL
DSKREAD2:   CALL    SETTRKSEC                                            ; Set current track & sector, get load address to HL
DSKREAD3:   CALL    SETHEAD                                              ; Set side reg
            CALL    SEEK                                                 ; Command 1b output (seek)
            JP      NZ,SEEKRETRY                                         ; 
            CALL    OUTTKSEC                                             ; Set track & sector reg
    ;   SCF
    ;   CALL DEBUG
            LD      IX, 0F3FEH                                           ; As below. L03FE
            LD      IY,READDATA                                          ; Read sector into memory.
            DI     
            ;
            LD      A,094H                                               ; Read Sector multiple with Side Compare for side 1.
            CALL    DISKCMDWAIT
            LD      D,2                                                  ; Regardless of 4x128, 2x256 or 1x512, we always read 512bytes by the 2x INI instruction with B=256.
STRTDATRD:  LD      B,0                                                  ; 256 bytes to load.
            JP      (IX)

            ; Get data from disk sector to staging area.
READDATA:   INI     
            JP      NZ,0F3FEH                                            ; This is crucial, as the Z80 is running at 2MHz it is not fast enough so needs
                                                                         ; hardware acceleration in the form of a banked ROM, if disk not ready jumps to IX, if
                                                                         ; data ready, jumps to IY.
            DEC     D
            JP      NZ,0F3FEH                                            ; If we havent read all sectors to form a 512 byte block, go for next sector.
            ;
            ;
DATASTOP:   LD      A,0D8H                                               ; Force interrupt command, Immediate interrupt (I3 bit 3=1) of multiple sector read.
            CPL    
            OUT     (FDC_CR),A
            CALL    WAITRDY                                              ; Wait for controller to become ready, acknowledging interrupt.
           ;CALL    CHECKTIMER
            IN      A,(FDC_STR)                                          ; Check for errors.
            CPL     
            AND     0FFH
       ;SCF
       ;CCF
       ;CALL DEBUG
            JR      NZ,SEEKRETRY   
UPDSECTOR:  PUSH    HL
            LD      A,(SECTORCNT)
            LD      HL,SECTORNO
            ADD     A,(HL)                                               ; Update sector to account for sectors read. NB. All reads will start at such a position
            LD      (HL), A                                              ; that a read will not span a track or head. Ensure that disk formats meet an even 512byte format.
            POP     HL
MOTOROFF:   LD      A,MTROFFMSECS                                         ; Schedule motor to be turned off.
            LD      (MTROFFTIMER),A
    ;   SCF
    ;   CCF
    ;   CALL DEBUG
            XOR     A                                                    ; Successful read, return 0
            EI
            RET    

SEEKRETRY:  LD      B,A                                                  ; Preserve the FDC Error byte.
            LD      A,(RETRIES)
            DEC     A
            LD      (RETRIES),A
            LD      A,B
            JP      Z,RETRIESERR
            CALL    DSKSEEKTK0
            LD      A, (READOP) 
            OR      A
            LD      A,(TRACKNO)                                          ; NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            JP      Z, DSKWRITE2                                         ; Try write again.
            JP      DSKREAD2                                             ; Try the read again.

DISKCMDWAIT:LD      (FDCCMD),A
            CPL    
            OUT     (FDC_CR),A
            CALL    WAITBUSY
            RET     

            ; Send a command to the disk controller.
DSKCMD:     LD      (FDCCMD),A                                           ; Store latest FDC command.
            CPL                                                          ; Compliment it (FDC bit value is reversed).
            OUT     (FDC_CR),A                                           ; Send command to FDC.
            CALL    WAITRDY                                              ; Wait to become ready.
            IN      A,(FDC_STR)                                          ; Get status register.
            CPL                                                          ; Inverse (FDC is reverse bit logic).
            RET   

;CHECKTIMER: PUSH    AF
;            LD      A,(TIMFG)
;            CP      0F0H
;            JR      NZ,CHKTIM1                                          
;            EI     
;CHKTIM1:    POP     AF
;            RET     

            ; Seek to programmed track.
SEEK:       LD      A,01BH                                               ; Seek command, load head, verify stepping 6ms.
            CALL    DSKCMD
            AND     099H
            RET

            ; Set current track & sector, get load address to HL
SETTRKSEC:  CALL    SELDRIVE
            LD      A,(TRACKNO)                                          ; NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            LD      HL, HSTBUF
            RET     

            ; Compute side/head.
SETHEAD:    CPL                                                          ; 
            OUT     (FDC_DR),A                                           ; Output track no for SEEK command.
            PUSH    HL
            LD      HL,SECPERHEAD
            LD      A,(SECTORNO)                                         ; Check sector, if greater than sector per track, change head.
            CP      (HL)
            POP     HL
            JR      NC,SETHD2                                            ; Yes, even, set side/head 1
            LD      A,001H                                               ; No, odd, set side/head 0
            JR      SETHD3                   

            ; Set side/head register.
SETHD2:     XOR     A                                                    ; Side 0
SETHD3:    ;CALL DEBUG 
            CPL                                                           ; Side 1
            OUT     (FDC_SIDE),A                                         ; Side/head register.
            RET     

            ; Set track and sector register.
OUTTKSEC:   PUSH    HL
            LD      HL,SECPERHEAD
            ;
            LD      C,FDC_DR                                             ; Port for data retrieval in the INI instruction in main block.                 
            LD      A,(TRACKNO)                                          ; Current track number, NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            CPL                             
            OUT     (FDC_TR),A                                           ; Track reg
            ;
            LD      A,(SECTORNO)                                         ; Current sector number
            CP      (HL)
            JR      C,OUTTKSEC2
            SUB     (HL)
            INC     A                                                    ; Account for the +1 added to ease comparisons.
OUTTKSEC2: ;CALL DEBUG 
            CPL                             
            OUT     (FDC_SCR),A                                          ; Sector reg
            POP     HL
            RET                       

            ; Seek to track 0.
DSKSEEKTK0: CALL    DSKMTRON                                             ; Make sure disk is spinning.
            LD      A,00BH                                               ; Restore command, seek track 0.
            CALL    DSKCMD                                               ; Send command to FDC.
            AND     085H                                                 ; Process result.
            XOR     004H   
            RET     Z      
            JP      DSKSEEKERR

            ; Wait for the drive to become ready.
WAITRDY:    PUSH    DE
            PUSH    HL
            CALL    FDCDLY1
            LD      E,007H
WAITRDY2:   LD      HL,00000H
WAITRDY3:   DEC     HL
            LD      A,H
            OR      L
            JR      Z,WAITRDY4                                           
            IN      A,(FDC_STR)
            CPL     
            RRCA    
            JR      C,WAITRDY3                                          
            POP     HL
            POP     DE
            RET     

WAITRDY4:   DEC     E
            JR      NZ,WAITRDY2                                        
            POP     HL
            POP     DE
            JP      WAITRDYERR

WAITBUSY:   PUSH    DE
            PUSH    HL
            CALL    FDCDLY1
            LD      E,007H                                               ; 7 Chances of a 16bit down count delay waiting for DRQ.
WAITBUSY2:  LD      HL,00000H
WAITBUSY3:  DEC     HL
            LD      A,H
            OR      L
            JR      Z,WAITBUSY4                                          ; Down counter expired, decrement retries, error on 0.
            IN      A,(FDC_STR)                                          ; Get the FDC Status
            CPL                                                          ; Switch to positive logic.
            RRCA                                                         ; Shift Busy flag into Carry.
            JR      NC,WAITBUSY3                                         ; Busy not set, decrement counter and retry.
            POP     HL
            POP     DE
            RET     

WAITBUSY4:  DEC     E
            JR      NZ,WAITBUSY2                                         
            POP     HL
            POP     DE
            JP      DSKERR


            ; Error processing. Consists of printing a message followed by debug data (if enabled) and returning with carry set
            ; to indicate error.
DSKERR:     LD      DE,LOADERR                                           ; Loading error message
            JR      HDLERROR                                             

SELDRVERR:  LD      DE,SELDRVMSG                                         ; Select drive error message.
            JR      HDLERROR                                              
            
WAITRDYERR: LD      DE,WAITRDYMSG                                        ; Waiting for ready timeout error message.
            JR      HDLERROR                                               
 
DSKSEEKERR: LD      DE,DSKSEEKMSG                                        ; Disk seek to track error message.
            JR      HDLERROR                                                

RETRIESERR: BIT     2,A                                                  ; Data overrun error if 1.
            LD      DE,DATAOVRMSG
            JR      NZ, RETRIESERR2
            BIT     3,A                                                  ; CRC error if 1.
            LD      DE,CRCERRMSG
            JR      NZ,RETRIESERR2
            LD      DE,RETRIESMSG                                        ; Data sector read error message.
RETRIESERR2:

            ; Process error, dump debug data and return fail code.
HDLERROR:   CALL    ERRPRTSTR
            XOR     A
            IF ENADEBUG = 1
              CALL  DEBUG
            ENDIF
            CALL    DSKINIT
            CALL    DSKMTRON
            LD      A,001H                                               ; Indicate error by setting 1 in A register.
            EI
            RET

ERRPRTSTR:  EX      DE,HL
            LD      DE,DISKERRMSG
            CALL    MONPRTSTR
            EX      DE,HL
            JP      MONPRTSTR



            ; Debug routine to print out all registers and dump a section of memory for analysis.
            ;
DEBUG:      IF ENADEBUG = 1
            PUSH    AF
            PUSH    BC
            PUSH    DE
            PUSH    HL

            PUSH    AF
            PUSH    HL
            PUSH    DE
            PUSH    BC
            PUSH    AF
            LD      DE, INFOMSG
            CALL    MONPRTSTR
            POP     BC
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            LD      DE, INFOMSG2
            CALL    MONPRTSTR
            POP     BC
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            LD      DE, INFOMSG3
            CALL    MONPRTSTR
            POP     DE
            LD      A,D
            CALL    ?PRTHX
            LD      A,E
            CALL    ?PRTHX
            LD      DE, INFOMSG4
            CALL    MONPRTSTR
            POP     HL
            LD      A,H
            CALL    ?PRTHX
            LD      A,L
            CALL    ?PRTHX
            LD      DE, INFOMSG5
            CALL    MONPRTSTR
            LD      HL,00000H
            ADD     HL,SP
            LD      A,H
            CALL    ?PRTHX
            LD      A,L
            CALL    ?PRTHX
            CALL    ?NL

            LD      DE, DRVMSG
            CALL    MONPRTSTR
            LD      A, (CDISK)
            CALL    ?PRTHX

            LD      DE, FDCDRVMSG
            CALL    MONPRTSTR
            LD      A, (FDCDISK)
            CALL    ?PRTHX
           
            LD      DE, SEKTRKMSG
            CALL    MONPRTSTR
            LD      BC,(SEKTRK)
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            CALL    ?PRTS 
            LD      A,(SEKSEC)
            CALL    ?PRTHX
            CALL    ?PRTS 
            LD      A,(SEKHST)
            CALL    ?PRTHX
           
            LD      DE, HSTTRKMSG
            CALL    MONPRTSTR
            LD      BC,(HSTTRK)
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            CALL    ?PRTS 
            LD      A,(HSTSEC)
            CALL    ?PRTHX
           
            LD      DE, UNATRKMSG
            CALL    MONPRTSTR
            LD      BC,(UNATRK)
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            CALL    ?PRTS 
            LD      A,(UNASEC)
            CALL    ?PRTHX
           
            LD      DE, CTLTRKMSG
            CALL    MONPRTSTR
            LD      A,(TRACKNO)                                          ; NB. Track number is 16bit, FDC only uses lower 8bit and assumes little endian read.
            CALL    ?PRTHX
            CALL    ?PRTS 
            LD      A,(SECTORNO)
            CALL    ?PRTHX
           
            LD      DE, DMAMSG
            CALL    MONPRTSTR
            LD      BC,(DMAADDR)
            LD      A,B
            CALL    ?PRTHX
            LD      A,C
            CALL    ?PRTHX
            CALL    ?NL
           
            POP     AF
            JR      C, SKIPDUMP
            LD      HL,00000h                                            ; Dump the startup vectors.
            LD      DE, 00A0H
            ADD     HL, DE
            EX      DE,HL
            LD      HL,00000h
            CALL    DUMPX
           
            LD      HL,IBUFE                                             ; Dump the data area.
            LD      DE, 0300H 
            ADD     HL, DE
            EX      DE,HL
            LD      HL,IBUFE
            CALL    DUMPX

            LD      HL,CBASE                                             ; Dump the CCP + BDOS area.
            LD      DE,CBIOSSTART - CBASE                                
            ADD     HL, DE
            EX      DE,HL
            LD      HL,CBASE
            CALL    DUMPX

SKIPDUMP:   POP     HL
            POP     DE
            POP     BC
            POP     AF
            RET
           
DRVMSG:     DB      "DRV=",  000H
FDCDRVMSG:  DB      ",FDC=", 000H
SEKTRKMSG:  DB      ",S=",   000H
HSTTRKMSG:  DB      ",H=",   000H
UNATRKMSG:  DB      ",U=",   000H
CTLTRKMSG:  DB      ",C=",   000H
DMAMSG:     DB      ",D=",   000H
INFOMSG:    DB      "AF=",   NUL
INFOMSG2:   DB      ",BC=",  000H
INFOMSG3:   DB      ",DE=",  000H
INFOMSG4:   DB      ",HL=",  000H
INFOMSG5:   DB      ",SP=",  000H
            ENDIF

KTBL:       ; Strobe 0           
            DB      '"'
            DB      '!'
            DB      'W'
            DB      'Q'
            DB      'A'
            DB      INSERT
            DB      NULL
            DB      'Z'
            ; Strobe 1
            DB      '$'
            DB      '#'
            DB      'R'
            DB      'E'
            DB      'D'
            DB      'S'
            DB      'X'
            DB      'C'
            ; Strobe 2
            DB      '&'
            DB      '%'
            DB      'Y'
            DB      'T'
            DB      'G'
            DB      'F'
            DB      'V'
            DB      'B'
            ; Strobe 3
            DB      '('
            DB      '\''
            DB      'I'
            DB      'U'
            DB      'J'
            DB      'H'
            DB      'N'
            DB      SPACE
            ; Strobe 4
            DB      '_'
            DB      ')'
            DB      'P'
            DB      'O'
            DB      'L'
            DB      'K'
            DB      '<'
            DB      'M'
            ; Strobe 5
            DB      '~'
            DB      '='
            DB      '{'
            DB      '`'
            DB      '*'
            DB      '+'
            DB      CURSLEFT
            DB      '>'
            ; Strobe 6
            DB      HOMEKEY
            DB      '|'
            DB      CURSRIGHT
            DB      CURSUP
            DB      CR
            DB      '}'
            DB      NULL
            DB      CURSUP     
            ; Strobe 7
            DB      '8'
            DB      '7'
            DB      '5'
            DB      '4'
            DB      '2'
            DB      '1'
            DB      DBLZERO
            DB      '0'
            ; Strobe 8
            DB      '*'
            DB      '9'
            DB      '-'
            DB      '6'
            DB      NULL
            DB      '3'
            DB      NULL
            DB      ','         

KTBLS:      ; Strobe 0          
            DB      '2'         
            DB      '1'         
            DB      'w'         
            DB      'q'         
            DB      'a'         
            DB      DELETE      
            DB      NULL        
            DB      'z'         
            ; Strobe 1          
            DB      '4'         
            DB      '3'         
            DB      'r'         
            DB      'e'         
            DB      'd'         
            DB      's'         
            DB      'x'         
            DB      'c'         
            ; Strobe 2          
            DB      '6'         
            DB      '5'         
            DB      'y'         
            DB      't'         
            DB      'g'         
            DB      'f'         
            DB      'v'         
            DB      'b'         
            ; Strobe 3          
            DB      '8'         
            DB      '7'         
            DB      'i'         
            DB      'u'         
            DB      'j'         
            DB      'h'         
            DB      'n'         
            DB      SPACE       
            ; Strobe 4          
            DB      '0'         
            DB      '9'         
            DB      'p'         
            DB      'o'         
            DB      'l'         
            DB      'k'         
            DB      ','         
            DB      'm'         
            ; Strobe 5          
            DB      '^'         
            DB      '-'         
            DB      '['         
            DB      '@'         
            DB      ':'         
            DB      ';'         
            DB      '/'         
            DB      '.'         
            ; Strobe 6          
            DB      CLRKEY      
            DB      '\\'        
            DB      CURSLEFT    
            DB      CURSDOWN    
            DB      CR          
            DB      ']'         
            DB      NULL        
            DB      '?'         

KTBLCL:     ; Strobe 0          
            DB      '2'         
            DB      '1'         
            DB      'W'         
            DB      'Q'         
            DB      'A'         
            DB      DELETE      
            DB      NULL        
            DB      'Z'         
            ; Strobe 1          
            DB      '4'         
            DB      '3'         
            DB      'R'         
            DB      'E'         
            DB      'D'         
            DB      'S'         
            DB      'X'         
            DB      'C'         
            ; Strobe 2          
            DB      '6'         
            DB      '5'         
            DB      'Y'         
            DB      'T'         
            DB      'G'         
            DB      'F'         
            DB      'V'         
            DB      'B'         
            ; Strobe 3          
            DB      '8'         
            DB      '7'         
            DB      'I'         
            DB      'U'         
            DB      'J'         
            DB      'H'         
            DB      'N'         
            DB      SPACE       
            ; Strobe 4          
            DB      '0'         
            DB      '9'         
            DB      'P'         
            DB      'O'         
            DB      'L'         
            DB      'K'         
            DB      ','         
            DB      'M'         
            ; Strobe 5          
            DB      '^'         
            DB      '-'         
            DB      '['         
            DB      '@'         
            DB      ':'         
            DB      ';'         
            DB      '/'         
            DB      '.'         
            ; Strobe 6          
            DB      CLRKEY      
            DB      '\\'        
            DB      CURSLEFT    
            DB      CURSDOWN    
            DB      CR          
            DB      ']'         
            DB      NULL        
            DB      '?'         
                                
KTBLC:      ; CTRL ON
            ; Strobe 0
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_W
            DB      CTRL_Q
            DB      CTRL_A
            DB      NOKEY
            DB      000H
            DB      CTRL_Z
            ; Strobe 1
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_R
            DB      CTRL_E
            DB      CTRL_D
            DB      CTRL_S
            DB      CTRL_X
            DB      CTRL_C
            ; Strobe 2
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_Y
            DB      CTRL_T
            DB      CTRL_G
            DB      CTRL_F
            DB      CTRL_V
            DB      CTRL_B
            ; Strobe 3
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_I
            DB      CTRL_U
            DB      CTRL_J
            DB      CTRL_H
            DB      CTRL_N
            DB      NOKEY
            ; Strobe 4
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_P
            DB      CTRL_O
            DB      CTRL_L
            DB      CTRL_K
            DB      NOKEY
            DB      CTRL_M
            ; Strobe 5
            DB      CTRL_CAPPA
            DB      CTRL_UNDSCR
            DB      ESC
            DB      CTRL_AT
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            ; Strobe 6
            DB      NOKEY
            DB      CTRL_SLASH
            DB      NOKEY
            DB      NOKEY
            DB      NOKEY
            DB      CTRL_RB
            DB      NOKEY

            ; SIGN ON BANNER
CBIOSSIGNON:DB      "** CBIOS v1.11, (C) P.D. Smart, 2020 **", CR, NUL
CPMSIGNON:  DB      "CP/M v2.23 (48K) COPYRIGHT(C) 1979, DIGITAL RESEARCH",CR, LF, NUL
CPMROMFNAME:DB      "CPM223",              NUL
CPMRDRVFN0: DB      "CPM22-DRV0",          NUL
CPMRDRVFN1: DB      "CPM22-DRV1",          NUL
ROMLDERRMSG:DB      "ROM LOAD",        CR, NUL
ROMFDERRMSG:DB      "ROM FIND",        CR, NUL
DISKERRMSG: DB      "DISK ERROR - ",   NUL
LOADERR:    DB      "LOADING",         CR, NUL
SELDRVMSG:  DB      "SELECT",          CR, NUL
WAITRDYMSG: DB      "WAIT",            CR, NUL
DSKSEEKMSG: DB      "SEEK",            CR, NUL
RETRIESMSG: DB      "RETRIES",         CR, NUL
DATAOVRMSG: DB      "DATA OVERRUN",    CR, NUL
CRCERRMSG:  DB      "CRC ERROR",       CR, NUL


            ; Allocate space for 8 disk parameter block definitions in ROM.
            ;
            ALIGN_NOPS SCRN - (8 * 16)
;------------------------------------------------------------------------------------------------------------
; DISK PARAMETER BLOCK
;
; +----+----+------+-----+-----+------+----+----+-----+----+
; |SPT |BSH |BLM   |EXM  |DSM  |DRM   |AL0 |AL1 |CKS  |OFF |
; +----+----+------+-----+-----+------+----+----+-----+----+  
;  16B  8B   8B     8B    16B   16B    8B   8B   16B   16B
;
; -SPT is the total number of sectors per track.   
; -BSH is the data allocation block shift factor, determined by the data block allocation size.   
; -BLM is the data allocation block mask (2[BSH-1]).   
; -EXM is the extent mask, determined by the data block allocation size and the number of disk blocks.   
; -DSM determines the total storage capacity of the disk drive.   
; -DRM determines the total number of directory entries that can be stored on this drive.    
; -AL0, AL1   determine reserved directory blocks.   
; -CKS is the size of the directory check vector.   
; -OFF is the number of reserved tracks at the beginning of the (logical) disk
;
; BLS   BSH BLM  EXM (DSM < 256)  EXM (DSM > 255)
; 1,024  3    7   0                N/A
; 2,048  4   15   1                 0
; 4,096  5   31   3                 1
; 8,192  6   63   7                 3
; 16,384 7  127  15                 7
;------------------------------------------------------------------------------------------------------------

; MZ-800 drive but using both heads per track rather than the original
; 1 head for all  tracks on side A switching to second head and
; restarting at track 0.
DPB0:       DW      64                                                   ; SPT - 128 bytes sectors per track
            DB      4                                                    ; BSH - block shift factor
            DB      15                                                   ; BLM - block mask
            DB      1                                                    ; EXM - Extent mask
            DW      155                                                  ; DSM - Storage size (blocks - 1)
            DW      63                                                   ; DRM - Number of directory entries - 1
            DB      128                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      16                                                   ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      1                                                    ; OFF - Reserved tracks
            DB      6                                                    ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 10 = ROM, 11 = SD Card, 01 = Unused
                                                                         ;       Bit 5   = ROMFS Image, 0 = DRV0, 1 = DRV1
                                                                         

; Rom Filing System File Image acting as a drive.
; There are two definitions, 1 for each ROM drive, they can be identical but the CFG bit 5 will differ.
DPB1:       DW      128                                                  ; SPT - 128 bytes sectors per track
            DB      3                                                    ; BSH - block shift factor
            DB      7                                                    ; BLM - block mask
            DB      0                                                    ; EXM - Extent mask
            DW      240                                                  ; DSM - Storage size (blocks - 1)
            DW      31                                                   ; DRM - Number of directory entries - 1
            DB      128                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      8                                                    ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      0                                                    ; OFF - Reserved tracks
            DB      16                                                   ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 10 = ROM, 11 = SD Card, 01 = Unused
                                                                         ;       Bit 5   = ROMFS Image, 0 = DRV0, 1 = DRV1

; Rom Filing System File Image acting as a drive.
; There are two definitions, 1 for each ROM drive, they can be identical but the CFG bit 5 will differ.
DPB2:       DW      128                                                  ; SPT - 128 bytes sectors per track
            DB      3                                                    ; BSH - block shift factor
            DB      7                                                    ; BLM - block mask
            DB      0                                                    ; EXM - Extent mask
            DW      240                                                  ; DSM - Storage size (blocks - 1)
            DW      31                                                   ; DRM - Number of directory entries - 1
            DB      128                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      8                                                    ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      0                                                    ; OFF - Reserved tracks
            DB      48                                                   ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 10 = ROM, 11 = SD Card, 01 = Unused
                                                                         ;       Bit 5   = ROMFS Image, 0 = DRV0, 1 = DRV1


; 1.44MB Floppy
DPB3:       DW      144                                                  ; SPT - 128 bytes sectors per track (= 36 sectors of 512 bytes)
            DB      4                                                    ; BSH - block shift factor
            DB      15                                                   ; BLM - block mask
            DB      0                                                    ; EXM - Extent mask
            DW      719                                                  ; DSM - Storage size (blocks - 1)
            DW      127                                                  ; DRM - Number of directory entries - 1
            DB      192                                                  ; AL0 - 1 bit set per directory block
            DB      0                                                    ; AL1 -            "
            DW      32                                                   ; CKS - DIR check vector size (DRM+1)/4 (0=fixed disk)
            DW      0                                                    ; OFF - Reserved tracks
            DB      7                                                    ; CFG - MZ80A Addition, configuration flag:
                                                                         ;       Bit 1:0 = FDC: Sector Size, 00 = 128, 10 = 256, 11 = 512, 01 = Unused.
                                                                         ;       Bit 2   = Invert, 1 = Invert data, 0 = Use data as read (on MB8866 this is inverted).
                                                                         ;       Bit 4:3 = Disk type, 00 = FDC, 10 = ROM, 11 = SD Card, 01 = Unused
                                                                         ;       Bit 5   = ROMFS Image, 0 = DRV0, 1 = DRV1

            ALIGN_NOPS SCRN

            ; Bring in additional macros.
            INCLUDE "CPM_Definitions.asm"
            INCLUDE "Macros.asm"
