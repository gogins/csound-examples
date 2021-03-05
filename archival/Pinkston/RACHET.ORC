        sr      =       44100
        kr      =       4410
        ksmps   =       10
        nchnls  =       2

;====================================================================;
;       Rachet instrument                                            ;
;                                                                    ;
;       p4      p5      p6      p7      p8      p9      p10     p11  ;
;       amp     pch     lfohz   gatefn  envfn   panfn   cutoff  Q    ;
;                                                                    ;
;====================================================================;
        instr   1
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
