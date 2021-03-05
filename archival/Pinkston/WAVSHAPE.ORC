        sr      =       22050
        kr      =       4410
        ksmps   =       5
        nchnls  =       1

;=========================================================================;
;									  ;
;               General Purpose Waveshaping Instrument                    ;
;									  ;
;=========================================================================;
;                Coded by Russell Pinkston - Univ. of Texas               ;
;=========================================================================;

        instr   9

ihertz  =       cpspch(p4)
kgate   linen   1,.01,p3,.1             ;overall amp envelope
kctrl   linseg  0,p3/2,.999,p3/2,0
aindex  oscili  kctrl/2,ihertz,1
asignal tablei  .5+aindex,4,1
knormal tablei  kctrl,5,1               ;amplitude normalization function
        out     asignal*knormal*p5*kgate
        endin

