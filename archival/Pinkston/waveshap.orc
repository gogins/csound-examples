sr       =        44100
kr       =        4410
ksmps    =        10
nchnls   =        1
;=======================================================================;
; WAVSHAPE        General Purpose Waveshaping Instrument                ; 
;                 Coded by Russell Pinkston, Director                   ;
;                 University of Texas at Austin Computer Music Studio   ;
;=======================================================================;
         instr    1
idur     =        p3
iamp     =        p4
ihertz   =        cpspch(p5)
        
kgate    linen    1,.01,idur,.1                 ; overall amp envelope
kctrl    linseg   0,idur/2,.999,idur/2,0
aindex   oscili   kctrl/2,ihertz,1
asignal  tablei   .5+aindex,4,1    
knormal  tablei   kctrl,5,1                     ; amp normalization func
         out      asignal*knormal*iamp*kgate
         endin
