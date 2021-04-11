; Disassembly of the file "XPATCH-5510.bin"
; 
; CPU Type: Z80
; 
; Created with dZ80 2.1
; 
; on Sunday, 04 of April 2021 at 03:43 PM
; 
PRTC        EQU     0FEH
PRTD        EQU     0FFH
GETL        EQU     00003H
LETNL       EQU     00006H
NL          EQU     00009H
PRNTS       EQU     0000CH
PRNTT       EQU     0000FH
PRNT        EQU     00012H
MSG         EQU     00015H
MSGX        EQU     00018H
GETKY       EQU     0001BH
BRKEY       EQU     0001EH
?WRI        EQU     00021H
?WRD        EQU     00024H
?RDI        EQU     00027H
?RDD        EQU     0002AH
?VRFY       EQU     0002DH
MELDY       EQU     00030H
?TMST       EQU     00033H
TIMRD       EQU     0003BH
BELL        EQU     0003EH
XTEMP       EQU     00041H
MSTA        EQU     00044H
MSTP        EQU     00047H
MONIT       EQU     00000H
SS          EQU     00089H
ST1         EQU     00095H
HLHEX       EQU     00410H
_2HEX       EQU     0041FH
?MODE       EQU     0074DH
?KEY        EQU     008CAH
PRNT3       EQU     0096CH
?ADCN       EQU     00BB9H
?DACN       EQU     00BCEH
?DSP        EQU     00DB5H
?BLNK       EQU     00DA6H
?DPCT       EQU     00DDCH
PRTHL       EQU     003BAH
PRTHX       EQU     003C3H
ASC         EQU     003DAH
HEX         EQU     003F9H
DPCT        EQU     00DDCH
DLY12       EQU     00DA7H
DLY12A      EQU     00DAAH
?RSTR1      EQU     00EE6H
MOTOR       EQU     006A3H
CKSUM       EQU     0071AH
GAP         EQU     0077AH
WTAPE       EQU     00485H
MSTOP       EQU     00700H
TAPECOPY    EQU     011FDH
COLDSTRT    EQU     01200H
WARMSTRTMON EQU     01250H
CMDWORDTBL  EQU     015A8H
CMDJMPTBL   EQU     01BB2H
CMTBUF      EQU     02E33H
CMTFNAME    EQU     02E34H
CMDREMDATA  EQU     01C3CH
SYNTAXERR   EQU     013ABH
CMDREAD     EQU     02D12H
CMDLIST     EQU     01C4DH
CMDRUN      EQU     01E91H
CMDNEW      EQU     01C42H
CMDPRINT    EQU     02B0DH
CMDLET      EQU     01D6AH
CMDFOR      EQU     01F2BH
CMDIF       EQU     021ADH
CMDTHEN     EQU     013ABH
CMDGOTO     EQU     01EA6H
CMDGOSUB    EQU     01EC7H
CMDRETURN   EQU     01EF8H
CMDNEXT     EQU     01FC0H
CMDSTOP     EQU     01D2CH
CMDEND      EQU     01D15H
CMDON       EQU     0203EH
CMDLOAD     EQU     02D75H
CMDSAVE     EQU     02D82H
CMDVERIFY   EQU     02EB3H
CMDPOKE     EQU     02191H
CMDDIM      EQU     02080H
CMDDEFFN    EQU     02201H
CMDINPUT    EQU     02BFFH
CMDRESTORE  EQU     01D4DH
CMDCLS      EQU     021A6H
CMDMUSIC    EQU     02269H
CMDTEMPO    EQU     02282H
CMDUSRN     EQU     02942H
CMDWOPEN    EQU     02D9FH
CMDROPEN    EQU     02D92H
CMDCLOSE    EQU     02DADH
CMDMON      EQU     028B6H
CMDLIMIT    EQU     02967H
CMDCONT     EQU     029CEH
CMDGET      EQU     02902H
CMDINP      EQU     029FEH
CMDOUT      EQU     02A1CH
CMDCURSOR   EQU     028B9H
CMDSET      EQU     02AA6H
CMDRESET    EQU     02AAAH
CMDAUTO     EQU     02A2FH
CMDCOPY     EQU     033ABH
CMDPAGE     EQU     032D4H
OVFLERR     EQU     013AEH
ILDATERR    EQU     013B1H
DATMISERR   EQU     013B4H
STRLENERR   EQU     013B7H
MEMERR      EQU     013BAH
LINELENERR  EQU     013C0H
GOSUBERR    EQU     013C3H
FORNEXTERR  EQU     013C6H
FUNCERR     EQU     013C9H
NEXTFORERR  EQU     013CCH
RETGOSBERR  EQU     013CFH
UNDEFFNERR  EQU     013D2H
LINEERR     EQU     013D5H
CONTERR     EQU     013D8H
BADWRERR    EQU     013DBH
CMDSTMTERR  EQU     013DEH
READDATAERR EQU     013E1H
OPENERR     EQU     013E4H
UNKNWNERR   EQU     013E7H
OUTFILEERR  EQU     013EAH
PRTNRDYERR  EQU     013EDH
PRTHWERR    EQU     013F0H
PRTPAPERERR EQU     013F3H
CHKSUMERR   EQU     013F6H
TITLEMSG    EQU     01347H
COPYRMSG    EQU     01364H
READYMSG    EQU     01384H
ERRORMSG    EQU     0138AH
INMSG       EQU     01391H
BREAKMSG    EQU     01395H
BYTESMSG    EQU     0139CH
ERRCODE     EQU     013A3H
MSGNL       EQU     01332H
UNUSEDTBL1  EQU     0167BH
UNUSEDTBL2  EQU     0167DH
WARMSTRT    EQU     0124EH
OPERATORTBL EQU     0167FH
STRTONUM    EQU     017FCH
GETNUM      EQU     01E88H
SKIPSPACE   EQU     0173FH
INCSKIPSPCE EQU     0173EH
EXECHL      EQU     0177BH
EXECNOTCHR  EQU     01795H
MATCHCHR    EQU     017A3H
LINEBUFR    EQU     0490DH
ATRB        EQU     010F0H
NAME        EQU     010F1H
SIZE        EQU     01102H
DTADR       EQU     01104H
EXADR       EQU     01106H
COMNT       EQU     01108H
SWPW        EQU     01164H
KDATW       EQU     0116EH
KANAF       EQU     01170H
DSPXY       EQU     01171H
MANG        EQU     01173H
MANGE       EQU     01179H
PBIAS       EQU     0117AH
ROLTOP      EQU     0117BH
MGPNT       EQU     0117CH
PAGETP      EQU     0117DH
ROLEND      EQU     0117FH
FLASH       EQU     0118EH
SFTLK       EQU     0118FH
REVFLG      EQU     01190H
SPAGE       EQU     01191H
FLSDT       EQU     01192H
STRGF       EQU     01193H
DPRNT       EQU     01194H
TMCNT       EQU     01195H
SUMDT       EQU     01197H
CSMDT       EQU     01199H
AMPM        EQU     0119BH
TIMFG       EQU     0119CH
SWRK        EQU     0119DH
TEMPW       EQU     0119EH
ONTYO       EQU     0119FH
OCTV        EQU     011A0H
RATIO       EQU     011A1H
BUFER       EQU     011A3H
PRGSTART    EQU     0505CH

            ORG     PRGSTART

L505C:      NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
            NOP     
L506B:      NOP     
            NOP     
L506D:      LD      BC,01B35H
            PUSH    BC
            CALL    L5098
            JP      Z,L5150
            LD      DE,L507D
            JP      MSGNL

L507D:      DB      "RANGE ERROR"
            DB      00DH
L5089:      DB      "OVERFLOW ERROR",00DH
L5098:      LD      DE,MONIT
            LD      (05063H),DE
            DEC     DE
            DEC     DE
            LD      (05065H),DE
            CALL    017D5H
            OR      C
            INC     DE
            LD      A,02DH
            CP      (HL)
            JR      NZ,L50C0            ; (+011H)
            LD      (05063H),DE
            INC     HL
            CALL    048A0H
            CPL     
            JR      Z,L50D2             ; (+018H)
            LD      (05065H),DE
            JR      L50D2               ; (+012H)

L50C0:      LD      A,E
            OR      D
            JR      Z,L50CC             ; (+008H)
            LD      (05063H),DE
            LD      (05065H),DE
L50CC:      LD      A,02FH
            CP      (HL)
            JR      NZ,L50D2            ; (+001H)
            INC     HL
L50D2:      CALL    048A0H
            INC     L
            JR      NZ,L50DB            ; (+003H)
            LD      DE,0000AH
L50DB:      LD      (05067H),DE
            CALL    048A0H
            NOP     
            JR      NZ,L50E8            ; (+003H)
            LD      DE,0000AH
L50E8:      LD      (05069H),DE
            LD      (05051H),HL
            LD      BC,(05063H)
            LD      HL,(05065H)
            OR      A
            SBC     HL,BC
L50F9:      JP      C,SYNTAXERR
            CALL    L52BB
            JR      C,L50F9             ; (-008H)
            CALL    01773H
            JR      Z,L5118             ; (+012H)
            EX      DE,HL
            CALL    01867H
            LD      HL,(05067H)
            EX      DE,HL
            SBC     HL,DE
            JR      C,L5118             ; (+006H)
            CALL    L5118
L5115:      XOR     A
            INC     A
            RET     

L5118:      LD      BC,(05065H)
            INC     BC
            CALL    L52BB
            JR      NC,L5136            ; (+014H)
            EX      DE,HL
            CALL    01867H
            CALL    L526C
            EX      DE,HL
            CCF     
            JR      C,L5149             ; (+01cH)
L512D:      LD      DE,L5089
            CALL    MSG
            JP      01438H

L5136:      PUSH    DE
            CALL    01867H
            EX      DE,HL
            EX      (SP),HL
            CALL    01867H
            CALL    L526C
            EX      DE,HL
            POP     DE
            JR      C,L512D             ; (-019H)
            CALL    01773H
L5149:      LD      (L506B),HL
            JR      NC,L5115            ; (-039H)
            XOR     A
            RET     

L5150:      CALL    01AF1H
            LD      HL,(01958H)
            PUSH    HL
            POP     DE
L5158:      PUSH    HL
            OR      A
            SBC     HL,DE
            JP      C,MEMERR
            LD      BC,00080H
            SBC     HL,BC
            POP     HL
            JR      NC,L517E            ; (+017H)
            LD      BC,00100H
            EX      DE,HL
            CALL    01888H
            EX      DE,HL
            ADD     HL,BC
            PUSH    HL
            PUSH    DE
            CALL    018EAH
            LD      HL,(04E94H)
            ADD     HL,BC
            LD      (04E94H),HL
            POP     DE
            POP     HL
L517E:      PUSH    DE
            LD      A,(HL)
            LDI     
            OR      (HL)
            JR      Z,L519C             ; (+017H)
            LDI     
            LD      A,(HL)
            LDI     
            LD      B,(HL)
            LD      C,A
            LDI     
            INC     BC
            CALL    L51D1
            POP     HL
            LD      C,(HL)
            LD      (HL),E
            INC     HL
            LD      B,(HL)
            LD      (HL),D
            PUSH    BC
            POP     HL
            JR      L5158               ; (-044H)

L519C:      LD      (DE),A
            INC     DE
            EX      DE,HL
            LD      (04E4EH),HL
            POP     HL
            CALL    0195AH
            LD      BC,(05063H)
            CALL    L52BB
            LD      BC,(05067H)
L51B1:      PUSH    HL
            CALL    01867H
            JR      Z,L51CF             ; (+018H)
            PUSH    HL
            LD      HL,(05065H)
            SBC     HL,DE
            POP     HL
            JR      C,L51CF             ; (+00fH)
            EX      (SP),HL
            INC     HL
            INC     HL
            LD      (HL),C
            INC     HL
            LD      (HL),B
            LD      HL,(05069H)
            ADD     HL,BC
            PUSH    HL
            POP     BC
            POP     HL
            JR      L51B1               ; (-01eH)

L51CF:      POP     HL
            RET     

L51D1:      CALL    L52D5
            RET     Z
            CP      080H
            JR      NZ,L51D1            ; (-008H)
            CALL    L52D5
            CP      08CH
            JR      Z,L51EC             ; (+00cH)
            CP      08DH
            JR      Z,L51EC             ; (+008H)
            CP      08EH
            JR      Z,L51EC             ; (+004H)
            CP      09CH
            JR      NZ,L51D1            ; (-01bH)
L51EC:      CALL    L52D5
            DEC     DE
            DEC     HL
            SUB     030H
            CP      00AH
            JR      NC,L51D1            ; (-026H)
            CALL    L5204
            LD      A,02CH
            CP      (HL)
            JR      NZ,L51D1            ; (-02eH)
            LD      (DE),A
            INC     DE
            INC     HL
            JR      L51EC               ; (-018H)

L5204:      PUSH    DE
            PUSH    BC
            CALL    017F6H
            POP     BC
            CALL    L526C
            EX      (SP),HL
            JR      NC,L523C            ; (+02cH)
            PUSH    DE
            PUSH    HL
            CALL    NL
            EX      DE,HL
            LD      DE,L5255
            LD      A,00DH
            LD      (DSPXY),A
            CALL    L5244
            LD      DE,L525C
            CALL    MSG
            XOR     A
            LD      (DSPXY),A
            LD      D,B
            LD      E,C
            CALL    L526C
            EX      DE,HL
            LD      DE,L5257
            CALL    L5244
            POP     HL
            LD      (HL),070H
            INC     HL
            POP     DE
L523C:      EX      DE,HL
            PUSH    BC
            CALL    01802H
            POP     BC
            POP     HL
            RET     

L5244:      PUSH    BC
            CALL    MSG
            LD      DE,L505C
            PUSH    DE
            CALL    STRTONUM
            POP     DE
            CALL    MSG
            POP     BC
            RET     

L5255:      DB      03AH
            DB      020H
L5257:      DB      "LINE"
            DB      00DH
L525C:      DB      " DOES NOT EXIST"
            DB      00DH
L526C:      PUSH    BC
            PUSH    HL
            PUSH    DE
            XOR     A
            LD      B,D
            LD      C,E
            LD      HL,(05065H)
            SBC     HL,DE
            JR      C,L52AB             ; (+032H)
            EX      DE,HL
            LD      DE,(05063H)
            SBC     HL,DE
            JR      C,L52AB             ; (+029H)
            LD      B,D
            LD      C,E
            CALL    L52BB
            JR      C,L52AB             ; (+022H)
            POP     BC
            LD      DE,(05067H)
            PUSH    DE
L528F:      CALL    01867H
            JR      Z,L52A7             ; (+013H)
            EX      DE,HL
            XOR     A
            SBC     HL,BC
            JR      Z,L52B2             ; (+018H)
            JR      NC,L52A7            ; (+00bH)
            EX      DE,HL
            EX      (SP),HL
            LD      DE,(05069H)
            ADD     HL,DE
            EX      (SP),HL
            JR      NC,L528F            ; (-017H)
            CPL     
L52A7:      OR      A
            CCF     
            JR      L52AC               ; (+001H)

L52AB:      XOR     A
L52AC:      POP     DE
L52AD:      LD      D,B
            LD      E,C
            POP     HL
            POP     BC
            RET     

L52B2:      LD      H,B
            LD      L,C
            POP     BC
            SBC     HL,BC
            SCF     
            CCF     
            JR      L52AD               ; (-00eH)

L52BB:      LD      HL,(01958H)
            PUSH    HL
            JR      L52C3               ; (+002H)

L52C1:      EX      (SP),HL
            EX      DE,HL
L52C3:      PUSH    HL
            CALL    01867H
            JR      Z,L52D1             ; (+008H)
            EX      DE,HL
            SBC     HL,BC
            POP     HL
            JR      C,L52C1             ; (-00eH)
            POP     DE
            RET     

L52D1:      POP     HL
            POP     DE
            SCF     
            RET     

L52D5:      LD      A,(HL)
            LD      (DE),A
            CP      020H
            INC     HL
            INC     DE
            JR      Z,L52D5             ; (-008H)
            CP      00DH
            RET     Z
            CP      022H
            RET     NZ
L52E3:      LD      A,(HL)
            LD      (DE),A
            INC     HL
            INC     DE
            CP      00DH
            RET     Z
            CP      022H
            JR      NZ,L52E3            ; (-00bH)
            OR      A
            RET     

L52F0:      CALL    03327H
            LD      HL,(04AB3H)
            CALL    018B0H
            OR      C
            INC     DE
            PUSH    HL
            POP     DE
L52FD:      PUSH    DE
            LD      A,(HL)
            LDI     
            OR      (HL)
            JR      Z,L532B             ; (+027H)
            LDI     
            LD      A,(HL)
            LDI     
            LD      B,(HL)
            LD      C,A
            LDI     
            PUSH    HL
            LD      HL,(04AB5H)
            OR      A
            SBC     HL,BC
            POP     HL
            JR      C,L531C             ; (+005H)
            CALL    L5338
            JR      L5323               ; (+007H)

L531C:      LD      A,(HL)
            LDI     
            CP      00DH
            JR      NZ,L531C            ; (-007H)
L5323:      EX      (SP),HL
            LD      (HL),E
            INC     HL
            LD      (HL),D
            EX      (SP),HL
            POP     AF
            JR      L52FD               ; (-02eH)

L532B:      LDI     
            EX      DE,HL
            LD      (04E4EH),HL
            POP     HL
            CALL    0195AH
            JP      01B35H

L5338:      PUSH    DE
L5339:      CALL    SKIPSPACE
            CALL    L52D5
            JR      NZ,L5343            ; (+002H)
            POP     BC
            RET     

L5343:      CP      080H
            JR      NZ,L5339            ; (-00eH)
            CP      (HL)
            JR      NZ,L5339            ; (-011H)
            DEC     DE
            CALL    0174EH
            INC     HL
            CP      03AH
            JR      Z,L5339             ; (-01aH)
            EX      (SP),HL
            OR      A
            SBC     HL,DE
            POP     HL
            DEC     DE
            LD      A,00DH
            LD      (DE),A
            INC     DE
            RET     C
            DEC     DE
            DEC     DE
            DEC     DE
            DEC     DE
            RET     

L5363:      XOR     A
            LD      (L5465),A
            CALL    L536D
            JP      WARMSTRT

L536D:      LD      A,(0504EH)
            OR      A
            JP      NZ,SYNTAXERR
            CALL    0193BH
            RET     Z
            LD      DE,LINEBUFR
            PUSH    DE
            CALL    0150AH
            POP     HL
            CALL    L546D
            LD      (L5467),A
            LD      DE,BUFER
            LDIR    
            LD      A,(L5465)
            CP      001H
            JR      NZ,L53B7            ; (+025H)
            LD      DE,L5446
            CALL    LETNL
            CALL    MSG
            LD      A,(DPRNT)
            PUSH    AF
            LD      DE,LINEBUFR
            PUSH    DE
            CALL    GETL
            POP     HL
            XOR     A
            LD      B,A
            POP     AF
            LD      C,A
            ADD     HL,BC
            CALL    L546D
            LD      DE,011CCH
            LD      (L5468),A
            LDIR    
L53B7:      LD      A,(L5467)
            LD      B,A
            LD      HL,(01958H)
L53BE:      PUSH    BC
            PUSH    HL
            CALL    01867H
            POP     HL
            JR      NZ,L53D3            ; (+00dH)
            CALL    LETNL
            POP     BC
            XOR     A
            RET     

L53CC:      POP     BC
            POP     DE
            LD      HL,(04A0EH)
            JR      L53BE               ; (-015H)

L53D3:      CALL    018F2H
            LD      DE,04A0EH
            CALL    018A5H
            CALL    014F8H
            POP     BC
            CALL    BRKEY
            JP      Z,WARMSTRT
            LD      DE,BUFER
            LD      HL,0490FH
L53EC:      LD      A,(HL)
            CP      020H
            INC     HL
            JR      NZ,L53EC            ; (-006H)
L53F2:      PUSH    DE
            PUSH    BC
            DEC     HL
L53F5:      INC     HL
            LD      A,(HL)
            CP      000H
            JR      Z,L53F5             ; (-006H)
            CP      00DH
            JR      Z,L53CC             ; (-033H)
            EX      DE,HL
            CP      (HL)
            EX      DE,HL
            JR      NZ,L53F5            ; (-00fH)
            LD      (L5469),HL
L5407:      INC     DE
            DEC     B
            JR      Z,L5423             ; (+018H)
            LD      A,(DE)
            CP      020H
            JR      Z,L5407             ; (-009H)
L5410:      INC     HL
            LD      A,(HL)
            CP      020H
            JR      Z,L5410             ; (-006H)
            CP      00DH
            JR      Z,L53CC             ; (-04eH)
            EX      DE,HL
            CP      (HL)
            EX      DE,HL
            JR      Z,L5407             ; (-018H)
            POP     BC
            POP     DE
            JR      L53F2               ; (-031H)

L5423:      INC     HL
            LD      (L546B),HL
            LD      DE,LINEBUFR
            CALL    LETNL
            CALL    L5589
            POP     BC
            POP     DE
            LD      A,(L5465)
            OR      A
            RET     NZ
            CALL    L543C
            JR      L53F2               ; (-04aH)

L543C:      CALL    03302H
            CALL    BRKEY
            JP      Z,L57D8
            RET     

L5446:      DB      " CHANGE TO? "
            DB      00DH
L5453:      DB      "CHANGE IT? (Y/N) "
            DB      00DH
L5465:      DB      000H
L5466:      DB      000H
L5467:      DB      001H
L5468:      DB      000H
L5469:      DB      000H
            DB      000H
L546B:      DB      000H
            DB      000H
L546D:      LD      A,(HL)
            CP      020H
            JP      C,WARMSTRT
            CP      022H
            JR      NZ,L5478            ; (+001H)
            INC     HL
L5478:      CALL    018FDH
            LD      A,C
            CP      028H
            JP      NC,ILDATERR
            INC     C
            RET     

L5483:      LD      A,(HL)
            CP      021H
            JR      NZ,L548A            ; (+002H)
            INC     HL
            XOR     A
L548A:      LD      (L5466),A
            RET     

L548E:      LD      A,001H
            LD      (L5465),A
            CALL    L5483
            CALL    L536D
L5499:      JP      Z,WARMSTRT
            CALL    LETNL
            LD      A,(L5466)
            OR      A
            JR      NZ,L54BC            ; (+017H)
            LD      DE,L5453
            CALL    L59E3
            JR      Z,L54BC             ; (+00fH)
            LD      HL,(L546B)
            LD      DE,BUFER
            LD      A,(L5467)
            LD      B,A
            CALL    L53F2
            JR      L5499               ; (-023H)

L54BC:      CALL    014F8H
            LD      HL,(L546B)
            LD      BC,(05469H)
            OR      A
            SBC     HL,BC
            LD      A,(L5468)
            CP      L
            JR      Z,L552E             ; (+05fH)
            JR      C,L5517             ; (+046H)
            PUSH    BC
            SUB     L
            LD      C,A
            LD      B,000H
            PUSH    BC
            LD      HL,LINEBUFR
            CALL    018FDH
            INC     C
            LD      A,C
            POP     BC
            PUSH    AF
            ADD     A,C
            LD      C,A
            CP      050H
            JR      C,L5501             ; (+01aH)
            LD      DE,L55B3
            CALL    LETNL
            CALL    MSG
            POP     AF
            POP     BC
            LD      HL,(04A0EH)
            LD      A,(L5467)
            LD      B,A
            LD      C,000H
            LD      DE,BUFER
            JP      L5565

L5501:      LD      HL,LINEBUFR
            PUSH    HL
            ADD     HL,BC
            EX      DE,HL
            POP     HL
            POP     AF
            LD      C,A
            ADD     HL,BC
            POP     BC
            PUSH    HL
            OR      A
            SBC     HL,BC
            LD      B,H
            LD      C,L
            POP     HL
            LDDR    
            JR      L552E               ; (+017H)

L5517:      LD      H,A
            LD      A,L
            SUB     H
            LD      L,A
            LD      H,000H
            PUSH    HL
            LD      HL,(L546B)
            CALL    018FDH
            INC     C
            POP     DE
            PUSH    HL
            OR      A
            SBC     HL,DE
            EX      DE,HL
            POP     HL
            LDIR    
L552E:      LD      HL,011CCH
            LD      DE,(05469H)
            LD      A,(L5468)
            OR      A
            JR      Z,L5540             ; (+005H)
            LD      C,A
            LD      B,000H
            LDIR    
L5540:      CALL    0146AH
L5543:      LD      HL,(04A10H)
            CALL    018B0H
            OR      C
            INC     DE
            CALL    01302H
            CALL    018B3H
            LD      D,E
            LD      D,L
            LD      A,(L5465)
            CP      001H
            RET     NZ
            CALL    012F3H
            LD      DE,LINEBUFR
            CALL    MSGX
            CALL    LETNL
L5565:      LD      BC,L5499
            PUSH    BC
            LD      DE,BUFER
            LD      HL,(L5469)
            LD      A,(L5468)
            ADD     A,L
            LD      L,A
            LD      A,(L5467)
            LD      B,A
            LD      C,000H
            PUSH    HL
            LD      HL,(04A0EH)
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            LD      (04A0EH),HL
            POP     HL
            JP      L53F2

L5589:      PUSH    DE
            LD      DE,L55AB
            CALL    MSG
            POP     DE
            PUSH    HL
            CALL    00FB1H
            CALL    MSGX
            LD      A,(L5469)
            ADD     A,01BH
            LD      C,A
            LD      B,000H
            XOR     A
            ADC     HL,BC
            LD      A,0C2H
            LD      (HL),A
            POP     HL
            CALL    LETNL
            RET     

L55AB:      LD      DE,01211H
            LD      (DE),A
            DEC     C
            NOP     
            NOP     
            NOP     
L55B3:      DB      "LINE IS TOO LONG!",00DH
L55C5:      LD      A,002H
            LD      (L5465),A
            CALL    L5483
            CALL    L536D
L55D0:      JP      Z,WARMSTRT
            CALL    LETNL
            LD      A,(L5466)
            OR      A
            JR      NZ,L55E9            ; (+00dH)
            LD      DE,L55F8
            CALL    L59E3
            JR      Z,L55E9             ; (+005H)
            LD      HL,(04A0EH)
            JR      L55EC               ; (+003H)

L55E9:      CALL    L5543
L55EC:      LD      DE,BUFER
            LD      A,(L5467)
            LD      B,A
            CALL    L53BE
            JR      L55D0               ; (-028H)

L55F8:      DB      "DELETE THIS LINE (Y/N)? ",00DH
L5611:      NOP     
L5612:      NOP     
            NOP     
            NOP     
            NOP     
L5616:      XOR     A
            LD      (L5611),A
            CALL    EXECNOTCHR
            CPL     
            DEC     HL
            LD      D,(HL)
            CALL    EXECNOTCHR
            LD      D,B
            XOR     E
            INC     DE
            LD      A,001H
            LD      (L5611),A
            CALL    03327H
            LD      HL,(04AB3H)
            CALL    018B0H
            OR      C
            INC     DE
            PUSH    HL
            CALL    01AF1H
            POP     HL
L563B:      LD      A,(HL)
            INC     HL
            OR      (HL)
            JP      Z,L574F
            INC     HL
            LD      C,(HL)
            INC     HL
            LD      B,(HL)
            PUSH    HL
            OR      A
            LD      HL,(04AB5H)
            SBC     HL,BC
            POP     HL
            JP      C,L574F
            PUSH    BC
            POP     IY
L5653:      INC     HL
L5654:      LD      A,(HL)
            INC     HL
            CP      020H
            JR      Z,L5654             ; (-006H)
            CP      00DH
            JR      Z,L563B             ; (-023H)
            CP      080H
            JR      C,L5676             ; (+014H)
            JR      NZ,L5654            ; (-010H)
            CP      (HL)
            JR      Z,L566C             ; (+005H)
            CALL    L588A
            JR      NZ,L5654            ; (-018H)
L566C:      CALL    0174EH
            INC     HL
            CP      00DH
            JR      Z,L563B             ; (-039H)
            JR      L5654               ; (-022H)

L5676:      CP      022H
            JR      NZ,L5686            ; (+00cH)
L567A:      LD      A,(HL)
            INC     HL
            CP      00DH
            JR      Z,L563B             ; (-045H)
            CP      022H
            JR      NZ,L567A            ; (-00aH)
            JR      L5654               ; (-032H)

L5686:      DEC     HL
            CALL    02640H
            JR      NC,L5653            ; (-039H)
            LD      A,046H
            CP      E
            JR      NZ,L5696            ; (+005H)
            LD      A,04EH
            CP      D
            JR      Z,L5653             ; (-043H)
L5696:      LD      BC,MONIT
            LD      A,(HL)
            CP      024H
            JR      NZ,L56A1            ; (+003H)
            LD      C,006H
            INC     HL
L56A1:      LD      (05614H),DE
            LD      (L5612),HL
            LD      A,(HL)
            CP      028H
            JR      Z,L56B3             ; (+006H)
            LD      A,C
            ADD     A,004H
            LD      C,A
            JR      L56CB               ; (+018H)

L56B3:      INC     HL
L56B4:      LD      A,(HL)
            INC     HL
            CP      028H
            JR      NZ,L56C1            ; (+007H)
L56BA:      LD      A,(HL)
            INC     HL
            CP      029H
            JR      NZ,L56BA            ; (-006H)
            LD      A,(HL)
L56C1:      CP      02CH
            JR      Z,L56CB             ; (+006H)
            CP      029H
            JR      NZ,L56B4            ; (-015H)
            INC     C
            INC     C
L56CB:      LD      HL,04E86H
            ADD     HL,BC
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            LD      DE,(05614H)
L56D7:      LD      A,(HL)
            INC     HL
            CP      E
            JR      C,L56E6             ; (+00aH)
            JR      NZ,L56F2            ; (+014H)
            LD      A,(HL)
            CP      D
            JR      C,L56E9             ; (+007H)
            JR      Z,L5705             ; (+021H)
            JR      L56F2               ; (+00cH)

L56E6:      OR      (HL)
            JR      Z,L56F2             ; (+009H)
L56E9:      INC     HL
            LD      C,(HL)
            LD      B,000H
            INC     HL
            ADD     HL,BC
            ADD     HL,BC
            JR      L56D7               ; (-01bH)

L56F2:      DEC     HL
            EX      DE,HL
            LD      BC,GETL
            CALL    019C0H
            LD      HL,(05614H)
            EX      DE,HL
            LD      (HL),E
            INC     HL
            LD      (HL),D
            INC     HL
            XOR     A
            JR      L570B               ; (+006H)

L5705:      INC     HL
            LD      A,(HL)
            CP      PRTD
            JR      Z,L573C             ; (+031H)
L570B:      INC     A
            LD      (HL),A
            PUSH    HL
            LD      B,A
L570F:      INC     HL
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            PUSH    HL
            PUSH    IY
            POP     HL
            OR      A
            SBC     HL,DE
            POP     HL
            JR      C,L5726             ; (+009H)
            JR      NZ,L5724            ; (+005H)
            DEC     A
            POP     HL
            LD      (HL),A
            JR      L5736               ; (+012H)

L5724:      DJNZ    L570F               ; (-017H)
L5726:      POP     AF
            DEC     HL
            EX      DE,HL
            LD      BC,00002H
            CALL    019C0H
            EX      DE,HL
            PUSH    IY
            POP     BC
            LD      (HL),C
            INC     HL
            LD      (HL),B
L5736:      LD      HL,(L5612)
            JP      L5654

L573C:      LD      A,E
            CALL    L57DE
            LD      A,D
            CALL    L57DE
            LD      DE,L5807
            CALL    L57FC
            CALL    L57ED
            JR      L5736               ; (-019H)

L574F:      LD      IX,04E84H
L5753:      CALL    L57FC
            INC     IX
            INC     IX
            PUSH    IX
            POP     HL
            LD      A,L
            CP      092H
            JR      NC,L57D8            ; (+076H)
            SUB     086H
            LD      B,000H
            LD      C,A
            RLC     C
            RLC     C
            LD      HL,L5820
            CP      005H
            JR      C,L5775             ; (+003H)
            LD      HL,L5807
L5775:      ADD     HL,BC
            PUSH    HL
            POP     IY
            LD      L,(IX+000H)
            LD      H,(IX+001H)
L577F:      PUSH    IY
            POP     DE
            LD      A,(HL)
            LD      B,A
            INC     HL
            OR      (HL)
            JR      Z,L5753             ; (-035H)
            LD      A,B
            CALL    L57DE
            LD      A,(HL)
            CP      020H
            JR      Z,L5799             ; (+008H)
            CALL    L57DE
            CALL    L57ED
            JR      L57A1               ; (+008H)

L5799:      CALL    L57ED
            LD      A,020H
            CALL    L57DE
L57A1:      LD      A,(DE)
            CP      024H
            LD      A,020H
            CALL    NZ,L57DE
            INC     HL
            LD      B,(HL)
            INC     HL
L57AC:      PUSH    BC
            LD      E,(HL)
            INC     HL
            LD      D,(HL)
            INC     HL
            PUSH    HL
            EX      DE,HL
            LD      DE,LINEBUFR
            PUSH    DE
            CALL    STRTONUM
            LD      C,020H
            EX      DE,HL
L57BD:      LD      A,L
            CP      015H
            JR      NC,L57C6            ; (+004H)
            LD      (HL),C
            INC     HL
            JR      L57BD               ; (-009H)

L57C6:      LD      (HL),00DH
            POP     DE
            CALL    L57ED
            POP     HL
            CALL    L543C
            POP     BC
            DJNZ    L57AC               ; (-027H)
            CALL    L57FC
            JR      L577F               ; (-059H)

L57D8:      CALL    01AF1H
            JP      WARMSTRT

L57DE:      PUSH    BC
            LD      B,A
            CALL    PRNT
            LD      A,(L5611)
            OR      A
            LD      A,B
            POP     BC
            RET     Z
            JP      03291H

L57ED:      PUSH    BC
            LD      B,A
            CALL    MSG
            LD      A,(L5611)
            OR      A
            LD      A,B
            POP     BC
            RET     Z
            JP      031B4H

L57FC:      CALL    LETNL
            LD      A,(L5611)
            OR      A
            RET     Z
            JP      031A7H

L5807:      DB      " HAS MORE THAN 255 REFS"
            DB      00DH
            DB      024H
L5820:      DB      028H
            DB      02CH
            DB      029H
            DB      020H
            DB      00DH
            DB      00DH
            DB      00DH
            DB      "$()  "
            DB      00DH
            DB      00DH
            DB      00DH
            DB      "$    "
            DB      00DH
            DB      00DH
            DB      00DH
            DB      000H
L5838:      CALL    014C7H
            JP      Z,01497H
            LD      B,0B8H
            LD      DE,L585D
            CALL    014C9H
            JP      01495H

L5849:      LD      A,B
            CP      039H
            JR      NC,L5854            ; (+006H)
            LD      HL,CMDWORDTBL
            JP      01541H

L5854:      SUB     038H
            LD      B,A
            LD      HL,L585D
            JP      01541H

L585D:      DB      "RENU"
            DB      0CDH
            DB      "APPEN"
            DB      0C4H
            DB      "COMPRES"
            DB      0D3H
            DB      "DELET"
            DB      0C5H
            DB      "FIN"
            DB      0C4H
            DB      "CHANG"
            DB      0C5H
            DB      "SDE"
            DB      0CCH
            DB      "XRE"
            DB      0C6H
            DB      000H
            DB      000H
L588A:      LD      A,(HL)
            CP      081H
            RET     Z
            RET     C
            CALL    INCSKIPSPCE
            CP      02FH
            RET     NZ
            INC     HL
            INC     HL
            OR      A
            RET     

L5899:      CALL    LETNL
            CALL    LETNL
            LD      DE,L58A5
            JP      01329H

L58A5:      LD      B,L
            LD      E,B
            LD      D,B
            LD      B,C
            LD      C,(HL)
            LD      B,H
            LD      B,L
            LD      B,H
            JR      NZ,L58F1            ; (+042H)
            LD      B,C
            LD      D,E
            LD      C,C
            LD      B,E
            JR      NZ,L58EA            ; (+035H)
            DEC     (HL)
            LD      SP,02035H
            DEC     L
            JR      NZ,L5905            ; (+049H)
            LD      C,(HL)
            LD      B,E
            LD      C,H
            LD      D,L
            LD      B,H
            LD      B,L
            LD      D,E
            LD      A,(0430DH)
            OR      A
            SBC     A,(HL)
            CP      L
            SBC     A,L
            AND     (HL)
            SUB     A
            SBC     A,B
            SUB     (HL)
            JR      NZ,L5913            ; (+043H)
            LD      L,044H
            LD      L,020H
            LD      C,B
            SUB     D
            AND     C
            SBC     A,L
            OR      B
            JR      NZ,L590C            ; (+031H)
            ADD     HL,SP
            JR      C,L5915             ; (+037H)
            JR      NZ,L58ED            ; (+00dH)
L58E0:      CALL    03296H
            LD      A,00AH
            CALL    03296H
            LD      A,00DH
L58EA:      RET     

L58EB:      CALL    SKIPSPACE
            CP      030H
            JR      NZ,L58F6            ; (+004H)
            LD      A,0C3H
            JR      L58FD               ; (+007H)

L58F6:      CP      031H
            JP      NZ,SYNTAXERR
            LD      A,0CDH
L58FD:      LD      (L58E0),A
            INC     HL
L5901:      LD      (05051H),HL
L5904:      JP      01B35H

L5907:      LD      A,0C6H
            CALL    ?DPCT
L590C:      JR      L5901               ; (-00dH)

L590E:      XOR     A
            LD      (L5466),A
            CALL    L5098
L5915:      JR      NZ,L591C            ; (+005H)
            CALL    L5150
            JR      L5904               ; (-018H)

L591C:      LD      BC,(05063H)
            CALL    L52BB
            JR      Z,L5935             ; (+010H)
            PUSH    HL
            LD      BC,(05065H)
            INC     BC
            CALL    L52BB
            POP     DE
            OR      A
            SBC     HL,DE
            JP      Z,WARMSTRT
L5935:      LD      HL,(01958H)
            JR      L593C               ; (+002H)

L593A:      POP     HL
            POP     AF
L593C:      PUSH    HL
            CALL    01867H
            JR      Z,L5989             ; (+047H)
            PUSH    HL
            LD      HL,(L506B)
            SBC     HL,DE
            JR      C,L593A             ; (-010H)
            LD      HL,(05067H)
            PUSH    DE
            EX      DE,HL
            SBC     HL,DE
            POP     DE
            JR      C,L593A             ; (-01aH)
            LD      HL,(05065H)
            SBC     HL,DE
            JR      C,L5963             ; (+008H)
            LD      HL,(05063H)
            EX      DE,HL
            SBC     HL,DE
            JR      NC,L593A            ; (-029H)
L5963:      LD      A,(L5466)
            OR      A
            JR      NZ,L597B            ; (+012H)
            LD      DE,L59C7
            CALL    L59E0
            JR      Z,L5976             ; (+005H)
            POP     HL
            POP     DE
            JP      01B35H

L5976:      LD      A,001H
            LD      (L5466),A
L597B:      POP     HL
            POP     DE
            OR      A
            SBC     HL,DE
            LD      B,H
            LD      C,L
            PUSH    DE
            CALL    01306H
            POP     HL
            JR      L593C               ; (-04dH)

L5989:      CALL    L5150
L598C:      LD      HL,(01958H)
            CALL    01867H
            JR      Z,L59C4             ; (+030H)
            PUSH    DE
            POP     BC
L5996:      PUSH    HL
            CALL    01867H
            JR      Z,L59C4             ; (+028H)
            LD      A,B
            SUB     D
            JR      NZ,L59A2            ; (+002H)
            LD      A,C
            SUB     E
L59A2:      LD      C,E
            LD      B,D
            POP     DE
            JR      C,L5996             ; (-011H)
            PUSH    BC
            SBC     HL,DE
            LD      B,H
            LD      C,L
            LD      HL,04A0EH
            EX      DE,HL
            PUSH    HL
            PUSH    BC
            LDIR    
            POP     BC
            POP     DE
            CALL    01306H
            POP     HL
            CALL    018B0H
            CP      A
            LD      E,C
            CALL    012F3H
            JR      L598C               ; (-038H)

L59C4:      JP      WARMSTRT

L59C7:      DB      "OK TO DELETE DUP LINES? "
            DB      00DH
L59E0:      CALL    LETNL
L59E3:      CALL    MSG
L59E6:      CALL    BRKEY
            JP      Z,01438H
            CALL    009B3H
            CALL    ?DACN
            CALL    02305H
            CP      059H
            JR      Z,L59FE             ; (+005H)
            CP      04EH
            JR      NZ,L59E6            ; (-017H)
            OR      A
L59FE:      PUSH    AF
            CALL    LETNL
            POP     AF
            RET     

L5A04:      DW      L58EB
            DW      CMDAUTO
            DW      L5907
            DW      L590E
            DW      CMDCOPY
            DW      CMDPAGE
            DW      L506D
            DW      04806H
            DW      L52F0
            DW      0488EH
            DW      L5363
            DW      L548E
            DW      L55C5
            DW      L5616
L5A20:      DB      "LIN"
            DB      0C5H
            DB      "AUT"
            DB      0CFH
            DB      "CL"
            DB      0D3H
            DB      "MOV"
            DB      0C5H
            DB      "COPY/"
            DB      0D0H
            DB      "PAGE/"
            DB      0D0H
            DB      000H
L5A3C:      CP      091H
            RET     C
            CP      0BEH
            RET     NC
            CALL    ?ADCN
            CP      081H
            JR      C,L5A4F             ; (+006H)
            CP      09BH
            JR      NC,L5A4F            ; (+002H)
            SUB     080H
L5A4F:      JP      ?DACN

L5A52:      DB      "XP BASIC SA-551"
L5A61:      DB      035H
            DB      00DH
XPINIT:     LD      HL,L5A04
            LD      DE,01C16H
            LD      BC,0001CH
            LDIR    
            LD      HL,L5A3C
            PUSH    HL
            LD      DE,L5A20
            SBC     HL,DE
            PUSH    HL
            POP     BC
            EX      DE,HL
            LD      DE,0165EH
            LDIR    
            POP     HL
            LD      DE,02305H
            LD      BC,00016H
            LDIR    
            LD      HL,03338H
            LD      (022C9H),HL
            LD      HL,03302H
            LD      (01CCDH),HL
            LD      HL,MONIT
            LD      (01CCFH),HL
            LD      (01CD1H),HL
            LD      HL,03311H
            LD      (02B11H),HL
            LD      HL,048C1H
            LD      (0307BH),HL
            LD      (0318CH),HL
            LD      (03199H),HL
            LD      HL,02F6CH
            LD      (0315BH),HL
            LD      A,0CDH
            LD      (03140H),A
            LD      HL,0330BH
            LD      (03141H),HL
            LD      A,0C3H
            LD      HL,L5849
            LD      (0153EH),A
            LD      (0153FH),HL
            LD      HL,L5838
            LD      (01492H),A
            LD      (01493H),HL
            LD      A,(0322EH)
            CP      0C3H
            JR      NZ,L5AF2            ; (+017H)
            LD      (031ADH),A
            LD      HL,L58E0
            LD      (031AEH),HL
            LD      A,036H
            JR      L5AF4               ; (+00cH)

            LD      A,0ABH
            LD      (01C16H),A
            LD      A,013H
            LD      (01C17H),A
L5AF2:      LD      A,035H
L5AF4:      LD      HL,L58B7
            LD      (HL),A
            LD      HL,L5A61
            LD      (HL),A
            XOR     A
            LD      (041ECH),A
            LD      HL,L5A52
            LD      DE,04224H
            LD      BC,00011H
            LDIR    
            LD      HL,L5A04
            LD      (01958H),HL
            LD      (018B4H),HL
            LD      (01AC8H),HL
            LD      (01AE2H),HL
            LD      (01B14H),HL
            LD      (01B1CH),HL
            LD      (01C7EH),HL
            LD      (01EC2H),HL
            LD      (02D44H),HL
            LD      (02F24H),HL
            LD      (0303CH),HL
            LD      (03042H),HL
            INC     HL
            LD      (01201H),HL
            LD      (041FFH),HL
            LD      HL,L5899
            LD      (01225H),HL
            LD      HL,RELOC3302
            LD      DE,03302H
            LD      BC,0005BH
            LDIR    
            LD      DE,04806H
            LD      BC,000F8H
            LDIR    
            JP      COLDSTRT

RELOC3302:  CALL    GETKY               ; Relocated to 0x3302 for 0x5B bytes.
            CP      020H
            JP      Z,009B3H
            RET     

            LD      HL,ATRB
            JP      02F67H

            CALL    EXECNOTCHR
            LD      B,B
            JR      L5B95               ; (+02bH)

            LD      A,0C9H
            LD      (028F5H),A
            CALL    CMDCURSOR
            LD      A,0C3H
            LD      (028F5H),A
            JP      02B18H

            LD      A,0C9H
            LD      (01C7DH),A
            CALL    01C68H
            LD      A,021H
            LD      (01C7DH),A
            RET     

            NOP     
            NOP     
            NOP     
            LD      A,B
            OR      C
            RET     Z
            LD      A,B
            SUB     C
            JR      NC,L5B93            ; (+001H)
            XOR     A
L5B93:      ADD     A,C
            LD      B,A
L5B95:      LD      A,(DE)
            CALL    02305H
            LD      C,A
            PUSH    AF
            LD      A,(HL)
            CALL    02305H
            LD      C,A
            POP     AF
            OR      A
            SUB     C
            JR      NZ,L5BAA            ; (+005H)
            INC     DE
            INC     HL
            DJNZ    L5B95               ; (-014H)
            RET     

L5BAA:      LD      A,001H
            RET     NC
            LD      A,080H
            RET     

RELOC4806:  CALL    048EEH              ; Relocated to 0x4806 for 0xF8 bytes.
            LD      HL,0FFFFH
            CALL    018B0H
            LD      DE,0E548H
            EX      DE,HL
            LD      BC,(SIZE)
            DEC     BC
            DEC     BC
            CALL    01888H
            CALL    019C3H
            LD      (DTADR),DE
            CALL    02F6CH
            CALL    ?RDD
            JR      C,L5BFB             ; (+026H)
            POP     HL
            CALL    01ACAH
            LD      HL,(DTADR)
            PUSH    HL
            INC     HL
            INC     HL
            LD      A,(HL)
            INC     HL
            LD      H,(HL)
            LD      L,A
            CALL    018B0H
            LD      A,048H
            POP     BC
            OR      A
            SBC     HL,BC
            JP      NC,01B35H
            LD      DE,(DTADR)
            CALL    0485EH
            LD      A,047H
            JP      01403H

L5BFB:      POP     DE
            PUSH    DE
            CALL    0485EH
            POP     HL
            XOR     A
            LD      (HL),A
            INC     HL
            LD      (HL),A
            JP      CHKSUMERR

            LD      BC,(SIZE)
            DEC     BC
            DEC     BC
            JP      02F59H

            CALL    03327H
            LD      HL,(04AB5H)
            LD      A,H
            AND     L
            CP      PRTD
            JP      Z,ILDATERR
            PUSH    HL
            LD      HL,(04AB3H)
            LD      A,H
            OR      L
            JP      Z,ILDATERR
            CALL    018B0H
            OR      C
            INC     DE
            EX      (SP),HL
            INC     HL
            CALL    018B0H
            ADC     A,C
            LD      C,B
            POP     DE
            OR      A
            SBC     HL,DE
            RET     

            CALL    04867H
            JR      Z,L5C44             ; (+007H)
            JR      C,L5C47             ; (+008H)
            PUSH    HL
            POP     BC
            CALL    01306H
L5C44:      JP      01B35H

L5C47:      JP      OVFLERR

            PUSH    BC
            CALL    017F6H
            POP     BC
            LD      A,E
            OR      D
            EX      (SP),HL
            LD      A,(HL)
            INC     HL
            EX      (SP),HL
            PUSH    AF
            CP      (HL)
            JR      Z,L5C66             ; (+00dH)
            LD      A,00DH
            CP      (HL)
            JR      Z,L5C63             ; (+005H)
            LD      A,03AH
            CP      (HL)
            JR      NZ,L5C47            ; (-01cH)
L5C63:      POP     AF
            SCF     
            RET     

L5C66:      CALL    INCSKIPSPCE
            POP     AF
            RET     

            DI      
            PUSH    DE
            PUSH    BC
            PUSH    HL
            LD      DE,0D753H
            LD      BC,(SIZE)
            LD      HL,(DTADR)
            LD      A,B
            OR      C
            JP      Z,004CBH
            CALL    CKSUM
            CALL    MOTOR
            JP      C,00552H
            CALL    048E3H
            JP      00461H

            PUSH    BC
            PUSH    DE
            LD      BC,00200H
            LD      DE,01414H
            JP      0078EH

            LD      A,0C9H
            LD      (02F19H),A
            CALL    02EDAH
            LD      A,0CDH
            LD      (02F19H),A
            JP      01AF1H

            NOP                         ; End of Relocated code.
            NOP     
            NOP     
            NOP     
            NOP     
