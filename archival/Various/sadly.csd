<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo sadly.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr 	= 	44100
kr     	=      	44100
ksmps  	=      	1
nchnls 	=      	1


          instr     1
;p4=AMP
;p5=FREQ
;p6=ATTACK TIME
;p7=RELEASE TIME
k1        linen     p4, p6, p3, p7
a1        oscil     k1, p5, 1
          out       a1
          endin


          instr     2
iamp      =         ampdb(p4)
iscale    =         iamp*.333
inote     =         cpspch(p5)
k1        linen     iscale, p6, p3, p7
a3        oscil     k1, inote*.996, 1
a2        oscil     k1, inote*1.004, 1
a1        oscil     k1, inote, 1
a1        =         a1 + a2 + a3
          out       a1
          endin

          instr     3
irel      =         .01
idel1     =         p3 - (p10 * p3)
isus      =         p3 - (idel1 - irel)
iamp      =         ampdb(p4)
iscale    =         iamp * .333
inote     =         cpspch(p5)
k3        linseg    0, idel1, p9, isus, p9, irel, 0
k2        oscil     k3, p8, 1
k1        linen     iscale, p6, p3, p7
a3        oscil     k1, inote*.995+k2, 1
a2        oscil     k1, inote*1.005+k2, 1
a1        oscil     k1, inote+2, 1
          out       a1 + a2 + a3
          endin

          instr     4
ifunc     =         p11
irel      =         .01
idel1     =         p3 - (p10 * p3)
isus      =         p3 - (idel1 - irel)
iamp      =         ampdb(p4)
iscale    =         iamp * .333
inote     =         cpspch(p5)
k3        linseg    0, idel1, p9, isus, p9, irel, 0
k2        oscil     k3, p8, 1
k1        linen     iscale, p6, p3, p7
a3        oscil     k1, inote*.999+k2, ifunc
a2        oscil     k1, inote*1.001+k2, ifunc
a1        oscil     k1, inote+k2, ifunc
          out       a1 + a2 + a3
          endin

          instr     5
ifunc1    =         p11
ifunc2    =         p12
ifad1     =         p3 - (p13*p3)
ifad2     =         p3 - ifad1
irel      =         .01
idel1     =         p3 - (p10*p3)
isus      =         p3 - (idel1-irel)
iamp      =         ampdb(p4)
iscale    =         iamp * .166
inote     =         cpspch(p5)
k3        linseg    0, idel1, p9, isus, p9, irel, 0
k2        oscil     k3, p8, 1
k1        linen     iscale, p6, p3, p7
a6        oscil     k1, inote * .998+k2, ifunc2
a5        oscil     k1, inote*1.002+k2, ifunc2
a4        oscil     k1, inote+k2, ifunc2
a3        oscil     k1, inote*.997+k2, ifunc1
a2        oscil     k1, inote*1.003+k2, ifunc1
a1        oscil     k1, inote+k2, ifunc1
kfade     linseg    1, ifad1, 0, ifad2, 1
afunc1    =         kfade * (a1 + a2 +a3)
afunc2    =         (1-kfade) * (a4+a5+a6)
          out       afunc1 + afunc2
          endin


          instr     6
idur      =         p3
ifqm      =         400
imax      =         2
aform     line      400, idur, 800       ; CONTOUR OF FORMANT
amod      oscili    imax*ifqm, ifqm, 1   ; FM MODULATOR STABLE AT 400 Hz
;KOCT     IFNA      IDUR IFMODE
;XAMP     XFUND  XFORM    KBAND KRIS KDUR KDEC IOLAPS IFNB  IPHS
a1        fof       8000,  p4, aform+amod,0, 1, .0003, .5,  7,    3,  1, 19,idur,0, 1
          out       a1
          endin

          instr     7
idur      =         p3
iamp      =         p4/3
ifq       =         p5
if1       =         p6
if2       =         p7
a3        oscili    iamp, 1/idur, 52
a3        rand      a3, 400
a3        oscili    a3, 500, 11
a2        oscili    iamp, 1/idur, 52
a2        oscili    a2, ifq, if2     
a1        oscili    iamp, 1/idur, 51
a1        oscili    a1, ifq, if1            
          out       (a1+a2+a3) * 6
          endin

</CsInstruments>
<CsScore>
f1 0 2048 10 1 0
f2 0 2048 10 1 .5 .3 .25 .2 .167 .14 .111    ; SAWTOOTH
f3 0 2048 10 1 0 .3 0 .2 0 .14 0 .111        ; SQUARE
f4 0 2048 10 1 1 1 1 .7 .5 .3 .1             ; PULSE
f19 0 1024  19 .5 .5 270 .5
f11  0   512   9  1  1  0f12  0   512   9  10 1 0  16 1.5 0  22 2.  0  23 1.5 0
f13  0   512   9  25 1 0  29  .5 0  32  .2 0
f14  0   512   9  16 1 0  20 1.  0  22 1   0  34 2   0  38 1 0   47 1 0
f15  0   512   9  50 2 0  53 1   0  65 1   0  70 1   0  77 1 0  100 1 0
f51  0   513   5  4096 512 1 ; EQUALS '1 512 .00024' AFTER NORMALIZATION
f52  0   513   5   128 512 1 ; EQUALS '1 512 .0078'


; INSTR   START     DUR  AMP(P4)        FREQ(P5)  ATTACK(P6)     RELEASE(P7)
 i1  3    .5   10000          440       .7        .3
 i1  3.5  .5   10000          220       .7        .3
 i1  6    .5   10000          220       .7        .3
 i1  6.5  .5   10000          440       .7        .3
 i1  53   .5   10000          440       .7        .3
 i1  53.5 .5   10000          220       .7        .3
 i1  55.5 .5   10000          220       .7        .3
 i1     56     .5   10000          440       .7        .3
   
 i2  4    3    80        8.00      .1        .7
 i2  5    3    80        8.00      .1        .7
 i2  7    7    80        8.04      .07       6
 i2  54   3    80        8.0       .07       6
 i2  55   3    80        8.0       .07       6
    
 i4  15   3    80   8.00 .03  .1   6    1000 .8   1
 i4  18   3    80   8.04 .03  .1   6    5000 .8   2
 i4  21   3    80   8.00 .03  .1   6    100  .8   3
 i4  24   3    80   8.04 .03  .1   6    50   .8   4
 i4  51   4    80   8.00 .03  .1   6    1000 .8   1


;INSTR    STRT DUR  AMP  FRQ  ATK  REL  VIBRT     VBDPT     VIBDEL    STWAVE    ENDWAVE   CROOSTIME
 i5  37   3    80   8.00 .03  .1   5    6    .99  1    2    .1
 i5  40   5    80   8.04 .03  .1   5    6    .99  1    3    .1
 i5  45   3    80   8.00 .03  .1   5    6    .99  1    4    .1
 i5  48   5    80   8.04 .03  .1   5    6    .99  1    2    .1
i6   27   10   4


;        IDUR       IAMP   IFQ  IF1  IF2
i7   0         .5        3000      5    13   12
i7   .5        .5
i7   1    1.5
i7        2.5       .5
i7        3         .5
i7        3.5       1.5
i7        5         .5
i7        5.5       .5
i7        6         1.5
i7        7.5       .5
i7        8         .5
i7        8.5       1.5
i7        10   .5
i7        10.5      .5
i7        11        1.5
i7        12.5      .5
i7        13        .5
i7        13.5      1.5
i7        15        .5   1000 5    13   12
i7        15.5      .5 
i7        16        1.5
i7        17.5      .5
i7        18      .5
i7        18.5    1.5    500  5    13   12
i7        20   .5  
i7        20.5    .5
i7   40.5 .5
i7   41   .5   1000 5    13   12
i7   41.5 1.5
i7   43   .5
i7   43.5 .5
i7   44   1.5
i7   45.5 .5   3000 5    13   12
i7   46   .5
i7   46.5 1.5
i7   48   .5
i7   48.5 .5
i7   49   2.5
i7   51.5 .5
i7   52   .5
i7   52.5 1.5
i7   54   .5
i7   54.5 .5
i7   55   1.5
i7   56.5 .5
i7   57   .5
i7   57.5 1.5
i7   59   .5
i7   59.5 .5
i7   60   5




</CsScore>
</CsoundSynthesizer>
