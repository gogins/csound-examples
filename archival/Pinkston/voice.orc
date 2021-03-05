;*********************************************************;
;                 VOICE FORMANT ORCHESTRA                 ;
;                                                         ;     
;     p3 = duration           p4 = amplitude              ;
;     p5 = pitch in pch       p6 = phase for look-up      ;
;     p7 = envlpx rise time   p8 = envlpx decay time      ;
;                                                         ;
;     FUNCTIONS                                           ;
;                                                         ;     
;     f1 = sine wave         f2 = linear rise             ;
;     f3 = linear fall       f4 = exponential rise        ;
;     f5 = exponential fall  f6 = cosine for buzz         ;
;     f7 = func for vibamp   f8 = func for vibfrq         ;
;     f9 = func for kbwbase f10 = look-up table for icps  ;
;    f11 = look-up table for idb                          ;
;                                                         ;
;*********************************************************;
          sr = 44100
          kr = 4410
       ksmps = 10
      nchnls = 1 
;
       instr   1
;
; *****  look-up table info ******
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  The look-up table contains center frequencies and db levels  ;
;  for five voice formants.  The first eight are for a male     ;
;  voice, the next five are for a female voice.  The data was   ;
;  taken directly from page 205 in Charles Dodge's book,        ;
;  Computer Music.  The following is a list of numbers          ;
;  associated with a vowel sound:                               ;
;                                                               ;
;   1  A        4  O    7  ER       10  E                       ;
;   2  E        5  OO   8  UH       11  IY                      ;
;   3  IY       6  U    9  A        12  0                       ;
;                       13  OO                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    icf1     table   (p6*5)-5,10,0
    icf2     table   (p6*5)-4,10,0
    icf3     table   (p6*5)-3,10,0
    icf4     table   (p6*5)-2,10,0
    icf5     table   (p6*5)-1,10,0
    idb1raw  table   (p6*5)-5,11,0
    idb2raw  table   (p6*5)-4,11,0
    idb3raw  table   (p6*5)-3,11,0
    idb4raw  table   (p6*5)-2,11,0
    idb5raw  table   (p6*5)-1,11,0
    idb1     =   ampdb(idb1raw)
    idb2     =   ampdb(idb2raw)
    idb3     =   ampdb(idb3raw)
    idb4     =   ampdb(idb4raw)
    idb5     =   ampdb(idb5raw)
; *****  vibrato design  *********
        kvamp    randi   .003,5,-1
        kvstdy   oscil1  0.0,.013,(p3),7
        kvibamp  =       kvstdy+kvamp
        kvfrq    randi   1,7,-1
        ksfrq    oscil1  0.5,7.9,(p3),8
        kvibfrq  =       kvfrq+ksfrq+1
        kvib     oscil   kvibamp,kvibfrq,1
        ibaseoct ioctpch (p5)
        ipitch   icpspch (p5)
        kcpsvib  kcpsoct ibaseoct+kvib
;
; *****  tremolo design  ***********
        iampfac  =       (p4)*.06
        irfac    =       iampfac*.05
        ktrnd    randi   irfac,4,-1
        ktsamp   oscil1  0.41,iampfac,(p3),7
        ktamp    =       ktsamp+ktrnd+irfac
        kvtfrq   randi   1,5,-1
        kstfrq   oscil1  0.38,4,(p3),8
        ktfrq    =       kvtfrq+kstfrq+1
        ktrem    oscil   ktamp,ktfrq,1
        kamp     =       (p4)+ktrem
;
; *****  main instrument design  ***********
;
        knh      =       int((sr*.4)/ipitch)
        asrce    buzz    kamp,kcpsvib,knh,6
    ibw  =   icf1*.05   ;N.B. This was chosen by trial & error.
        aflt1    reson   asrce,icf1,ibw,1
        aflt2    reson   asrce,icf2,ibw,1
        aflt3    reson   asrce,icf3,ibw,1
        aflt4    reson   asrce,icf4,ibw,1
        aflt5    reson   asrce,icf5,ibw,1
    af1  =   aflt1 * idb1
    af2  =   aflt2 * idb2
    af3  =   aflt3 * idb3
    af4  =   aflt4 * idb4
    af5  =   aflt5 * idb5
        afltbnk  =       af1 + af2 + af3 + af4 + af5
    kbwbase  oscil1  0.0,(icf1*.5),p3,9
    kbwrnd   randi   .05,50,-1
    kbwfac   =   1+kbwrnd
    kbw  =   kbwbase * kbwfac
    amain    reson   afltbnk,kcpsvib,kbw,1
        asnd     balance amain,asrce 
        asig     envlpx  asnd,p7,p3,p8,2,1,.01
                 out     asig
                 endin
