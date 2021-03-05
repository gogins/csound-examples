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