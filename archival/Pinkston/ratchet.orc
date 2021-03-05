sr       =        44100
kr       =        4410
ksmps    =        10
nchnls   =        2
;=======================================================================;
; RACHET          Amplitude Modulated Filtered Noise Instrument         ;
;                 Coded by Russell Pinkston, Director                   ;
;                 University of Texas at Austin Computer Music Studio   ;
;=======================================================================;
; p6     =        lfo frequency                                         ;
; p7     =        gate function (f2)                                    ;
; p8     =        envelope function (f3)                                ;
; p9     =        pan function (f4 = pan right, f5 = pan left)          ;
; p10    =        cutoff frequency                                      ;
; p11    =        filter Q                                              ;
;=======================================================================;
         instr    1
icf      =        cpspch(p5)
ifc      =        (p10 == 0 ? sr/4:p10)         ; HP cutoff default: sr/4
iq       =        (p11 == 0 ? 1:p11)            ; Filter Q can't be zero
ibw      =        icf/iq

kgate    oscili   1,p6,p7,0
kenv     oscil1i  0,1,p3,p8
kpan     oscil1i  0,.5,p3,p9
kpan     =        .5+kpan

anoise   rand     p4
asig     reson    anoise,cpspch(p5),ibw,2       ; band pass...
asig     atone    asig,ifc                      ; ...then high pass...
asig     atone    asig,ifc                      ; ...sharply
asig     balance  asig,anoise

asig     =        asig*kgate*kenv               ; apply env after balance
aleft    =        sqrt(kpan)
aright   =        sqrt(1-kpan)
         outs     asig*aleft,asig*aright
         endin
