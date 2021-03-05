<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo mixture.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
        sr      =       44100
        kr      =       44100
        ksmps   =       1
        nchnls  =       2

;====================================================================;
;       Sampler instrument                                           ;
;                                                                    ;
;       p4      p5    p6        p7         p8                        ;
;       midinn  vel   smptable  datatable  amptable                  ;
;                                                                    ;
;====================================================================;
        instr   1
ismpno  table   p4,p6                   ;look up this midi note # in smpno table
ismpno  =       int(ismpno)             ;clean off any fraction
index   =       (ismpno-1)*4
iroot   table   index,p7                ;root key
imode   table   index+1,p7              ;loop mode
iloops  table   index+2,p7              ;loop start sample
iloope  table   index+3,p7              ;loop end sample
iamp    table   p5,p8                   ;map midi velocity to amp
ipitch  =       3.00 + p4/12            ;convert midi nn to oct
iroot   =       3.00 + iroot/12         ;convert root nn to oct
kgate   expseg  1,p3*.9,.1,p3*.1,.001
asig    loscil  iamp,cpsoct(ipitch),ismpno,cpsoct(iroot),imode,iloops,iloope
asig    =       asig*kgate
ileft   =       p5/127                  ;velocity pan
iright  =       1-ileft
ileft   =       sqrt(ileft)
iright  =       sqrt(iright)
        outs    asig*ileft,asig*iright
        endin

;====================================================================;
;       Rachet instrument                                            ;
;                                                                    ;
;       p4      p5      p6      p7      p8      p9      p10     p11  ;
;       amp     pch     lfohz   gatefn  envfn   panfn   cutoff  Q    ;
;                                                                    ;
;====================================================================;
        instr   2
icf     =       cpspch(p5)
ifc     =       (p10 == 0 ? sr/4 : p10)         ;HP cutoff defaults to sr/4
iq      =       (p11 == 0 ? 1 : p11)            ;Q of filter, can't be zero
ibw     =       icf/iq
kgate   oscili  1,p6,p7,0
kenv    oscil1i 0,1,p3,p8
kpan    oscil1i 0,.5,p3,p9
kpan    =       .5+kpan
anoise  rand    p4
asig    reson   anoise,cpspch(p5),ibw,2         ;band pass
asig    atone   asig,ifc                        ;high pass
asig    atone   asig,ifc                        ;sharply
asig    balance asig,anoise
asig    =       asig*kgate*kenv                 ;apply envelopes after balance
aleft   =       sqrt(kpan)
aright  =       sqrt(1-kpan)

        outs    asig*aleft,asig*aright
endin
</CsInstruments>
<CsScore>
f01     0       16384   1       "conga1.sf"     0       4       0       0
f02     0       16384   1       "conga1a.sf"    0       4       0       0
f03     0       8192    1       "conga3.sf"     0       4       0       0
f04     0       16384   1       "conga4.sf"     0       4       0       0
f05     0       16384   1       "conga5.sf"     0       4       0       0
f06     0       4096    1       "conga6.sf"     0       4       0       0
f07     0       16384   1       "conga7.sf"     0       4       0       0
f08     0       16384   1       "conga8.sf"     0       4       0       0
;conga9 is a bad EPS sample
f10     0       32768   1       "conga10.sf"    0       4       0       0
f11     0       16384   1       "conga11.sf"    0       4       0       0
f12     0       8192    1       "conga12.sf"    0       4       0       0
f13     0       32768   1       "conga13.sf"    0       4       0       0
f14     0       8192    1       "conga14.sf"    0       4       0       0
f15     0       4096    1       "conga15.sf"    0       4       0       0
f16     0       32768   1       "conga16.sf"    0       4       0       0
f17     0       16384   1       "conga17.sf"    0       4       0       0
f18     0       16384   1       "conga18.sf"    0       4       0       0
f19     0       32768   1       "conga19.sf"    0       4       0       0
;table mapping midi note numbers to sample #s:
                                s#      mn#s
f20     0       128     -7      1       36              ;locs 0 to 35
                                1       1               ;loc 36
                                2       2               ;locs 37 to 38
                                3       2               ;locs 39 to 40
                                4       1               ;loc 41
                                5       2               ;locs 42 to 43
                                6       2               ;locs 44 to 45
                                7       2               ;locs 46 to 47
                                8       1               ;loc 48
                                10      4               ;locs 49 to 52
                                11      1               ;loc 53
                                12      2               ;locs 54 to 55
                                13      2               ;locs 56 to 57
                                14      2               ;locs 58 to 59
                                15      1               ;loc 60
                                16      3               ;locs 61 to 63
                                17      1               ;loc 64
                                18      1               ;loc 65
                                19      62      19      ;loc 66 on
;table of root keys, loop mode, loop start, loop end, indexed by (fn-1)*4
f21     0      128      -2
;                               root    mode    loops   loope
                                36      1       10310   10675   ;smp 1
                                38      1       10662   10823   ;smp 2
                                40      1       7791    7967    ;smp 3
                                41      0       0       1       ;smp 4
                                43      0       0       1       ;smp 5
                                45      0       0       1       ;smp 6
                                47      0       0       1       ;smp 7
                                48      1       5962    6123    ;smp 8
                                52      1       20043   20200   ;smp 9
                                52      1       20043   20200   ;smp 10
                                53      0       0       1       ;smp 11
                                55      1       5190    5537    ;smp 12
                                57      0       0       1       ;smp 13
                                59      0       0       1       ;smp 14
                                60      0       0       1       ;smp 15
                                62      0       0       1       ;smp 16
                                63      0       0       1       ;smp 17
                                65      0       0       1       ;smp 18
                                67      0       0       1       ;smp 19
;vel to amp scaling function
f22     0     129    -5    400  129     32767
;gatefn
f23     0       512     7       0       64      1       16      0
;envfn  (exp rise)
f24     0       513     5       .05     512     1
;pan right func (lin rise)
f25     0       129     7      -1       129     1
;pan left func (lin decay)
f26     0       129     7       1       129     -1
; congas...           nn    vel  smptab datatab amptab
i 1     0.00  0.21    48    58   20     21      22
i 1     0.09  0.18    55    74
i 1     0.22  0.11    60    86
i 1     0.33  0.14    63   124
i 1     0.43  1.22    52   126
i 1     .      .1     68   127
; rachet
;                     amp     pch     lfohz   gatefn  envfn   panfn   cutoff  Q    ;
i 2     0.43  .6      20000   13.08   20      23      24      26      0       16
; congas...           nn    vel  smptab datatab amptab
i 1     1.00  0.19    46    58   20     21      22
i 1     1.10  0.13    53    89
i 1     1.22  0.08    55    84
i 1     1.27  0.12    56    98
i 1     1.35  0.15    58   110
i 1     1.46  0.14    63   110
i 1     1.56  0.12    66   127
e



</CsScore>
</CsoundSynthesizer>
