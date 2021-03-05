sr       =        44100
kr       =        44100
ksmps    =        1
nchnls   =        1
;=======================================================================;
; FILTDEMO        Filter Demo Orchestra - from  Dodge "Computer Music"  ;
;                 Coded by Russell Pinkston, Director                   ;
;                 University of Texas at Austin Computer Music Studio   ;
;=======================================================================;
; Note:           To work correctly, the Recursive Filter Instruments   ;
;                 (i7, i8 and i9) require kr = sr in this orchestra.    ;
;=======================================================================;
         instr    1                             ; Playback Instrument...
kgate    expseg   1,p3*.9,1,p3*.1,.001          ; ...unmodified...
ainput   soundin  p4, 0, 4                      ; ...for comparison
         out      ainput*kgate
         endin
;=======================================================================;
; Non-Recursive, All-Zero, Finite Impulse Response (FIR) Filters        ;
;================================================================ ======;
         instr    2                             ; First-Order Low-Pass
igain    =        (p5 != 0 ? p5:1)              ; Dodge p.182
kgate    expseg   igain,p3*.9,igain,p3*.1,.001
ainput   soundin  p4,0,4
aprev    delay1   ainput                        ; signal delayed 1 sample
asignal  =        (.5*ainput)+(.5*aprev)        ; average 2 successive inputs
         out      asignal*kgate
         endin

         instr    3                             ; First-Order High-Pass
igain    =        (p5 != 0 ? p5:1)              ; Dodge p.183
kgate    expseg   igain,p3*.9,igain,p3*.1,.001
ainput   soundin  p4,0,4
aprev    delay1   ainput                        ; signal delayed 1 sample
asignal  =        (.5*ainput)-(.5*aprev)        ; difference of 2 inputs
         out      asignal*kgate
         endin

         instr    4                             ; Second-Order Notch
igain    =        (p5 != 0 ? p5:1)              ; Dodge p.183
kgate    expseg   igain,p3*.9,igain,p3*.1,.001
ainput   soundin  p4,0,4                        ; x(n)
aprev1   delay1   ainput                        ; x(n - 1)
aprev2   delay1   aprev1                        ; x(n - 2)
asignal  =        (.5*ainput)+(.5*aprev2)       ; y(n) = .5x(n) + .5x(n - 2)
         out      asignal*kgate
         endin

         instr    5                             ; Second-Order Band-Pass
igain    =        (p5 != 0 ? p5:1)              ; Dodge p.183
kgate    expseg   igain,p3*.9,igain,p3*.1,.001
ainput   soundin  p4,0,4                        ; x(n)
aprev1   delay1   ainput                        ; x(n - 1)
aprev2   delay1   aprev1                        ; x(n - 2)
asignal  =        (.5*ainput)-(.5*aprev2)       ; y(n) = .5x(n) - .5x(n - 2)
         out      asignal*kgate
         endin

         instr    6                             ; Second-Order All-Zero Band-Reject
igain    =        (p7 != 0 ? p7:1)              ; Dodge p.184 - 5
i2pi     =        6.2831853
ibw      =        p6                            ; calculate coefficients...
icf      =        p5                            ; ...from center frq (p5)...
ic2      =        exp(-i2pi*ibw/sr)             ; ...and bandwidth (p6)
ic1      =        (-4*ic2/(1+ic2))*cos(i2pi*icf/sr)
iscl     =        1+ic1+ic2                      ; N.B., wrong in Dodge
ia0      =        1/iscl
ia1      =        ic1/iscl
ia2      =        ic2/iscl
kgate    expseg   igain,p3*.9,igain,p3*.1,.001
ainput   soundin  p4,0,4                        ; x(n)
aprev1   delay1   ainput                        ; x(n - 1)
aprev2   delay1   aprev1                        ; x(n - 2)
; y(n)   =           a0x(n)   + a1x(n - 1) + a2x(n - 2)
asignal  =        (ia0*ainput)+(ia1*aprev1)+(ia2*aprev2)
         out      asignal*kgate
         endin
;=======================================================================;
;  Recursive, All-Pole, Infinite Impulse Response (IIR) Filters         ;
;=======================================================================;
         instr    7                             ; First-Order Recursive
igain    =        (p6 != 0 ? p6:1)              ; Low-Pass Filter
i2pi     =        6.2831853                     ; Dodge p.186
ifc      =        p5                            ; Calculate coefficients...
ic       =        2-cos(i2pi*ifc/sr)            ; ...for Low-Pass Filter...
ib       =        sqrt(ic*ic-1)-ic              ; ...from cutoff frq (p5)
ia       =        1+ib
kgate    expseg   igain,p3*.9,igain,p3*.1,.001
aoutput  init     0                             ; init y(n - 1) to 0
ainput   soundin  p4,0,4                        ; x(n)
; y(n)   =         ia*x(n)   - ib*y(n - 1)
aoutput  =        (ia*ainput)-(ib*aoutput)
         out      aoutput*kgate
         endin

         instr    8                             ; First-Order Recursive
igain    =        (p6 != 0 ? p6:1)              ; High-Pass Filter
i2pi     =        6.2831853                     ; Dodge p.186
ifc      =        p5                            ; Calculate coefficients...
ic       =        2-cos(i2pi*ifc/sr)            ; ...for High-Pass Filter...
ib       =        ic-sqrt(ic*ic-1)              ; ...from cutoff frq (p5)
ia       =        1-ib
kgate    expseg   igain,p3*.9,igain,p3*.1,.001
aoutput  init     0                             ; init y(n - 1) to 0
ainput   soundin  p4,0,4                        ; x(n)
; y(n)   =         ia*x(n)   - ib*y(n - 1)
aoutput  =        (ia*ainput)-(ib*aoutput)
         out      aoutput*kgate
         endin

         instr    9                             ; Second-Order All-Pole
igain    =        (p8 == 0 ? 1:p8)              ; Band-Pass Filter
i2pi     =        6.2831853                     ; Dodge p.187
icf      =        p5                            ; Calculate coefficients...
ibw      =        p6                            ; ...for Band-Pass Filter...
ib2      =        exp(-i2pi*ibw/sr)             ; ...from center frq (p5)...
                                                ; ...and bandwidth (p6)
ib1      =        -4*ib2/(1+ib2)*cos(i2pi*icf/sr)
ib1sqrd  =        ib1*ib1
ib2sqrd  =        (1+ib2)*(1+ib2)
iscl1    =        (1-ib2)*sqrt(1-ib1sqrd/(4*ib2)); N.B., wrong in Dodge
iscl2    =        sqrt((ib2sqrd-ib1sqrd)*((1-ib2)/(1+ib2)))
iscl     =        (p7 == 1 ? iscl1:iscl2)       ; 1 = pitch, 2 = noise

kgate    expseg   igain,p3*.9,igain,p3*.1,.001
aprev1   init     0                             ; init y(n - 1) to 0
aprev2   init     0                             ; init y(n - 2) to 0
ainput   soundin  p4,0,4                         ; x(n)
; y(n)   =            a0x(n)   - b1y(n - 1) - b2y(n - 2)
aoutput  =        (iscl*ainput)-(ib1*aprev1)-(ib2*aprev2)
aprev2   =        aprev1
aprev1   =        aoutput
         out      aoutput*kgate
         endin
