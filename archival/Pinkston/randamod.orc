sr       =        44100
kr       =        4410
ksmps    =        10
nchnls   =        2
;=======================================================================;
; RANDAMOD        Random Amplitude Modulation Instrument                ; 
;                 Designed by Russell Pinkston, Director                ;
;                 University of Texas at Austin Computer Music Studio   ;
;=======================================================================;
;                 Not really Amplitude Modulation, just LFO gating      ;
;                 at random rates with random panning. RP               ; 
;=======================================================================;
         instr    1
iamp     =        p4
ipitch   =        cpspch(p5)
ipanhz   =        p6
irandhz  =        p7
iminhz   =        p8
imaxhz   =        p9
idepth   =        p10
igatefn  =        p11
irise    =        p12
idecay   =        p13
iseed    =        p14
ivaramp  =        iamp*idepth
iminamp  =        iamp-ivaramp
kpanfac  randi    .5,ipanhz,iseed
kpanfac  =        .5+kpanfac                       	;offset to 0-1 range
kvarhz   randi    imaxhz-iminhz,irandhz,iseed
kgate    oscili   idepth,iminhz+kvarhz,igatefn,0   	;reinit each note
kenv     expseg   .01,irise,1,p3-irise-idecay,1,idecay,.001
asig     oscili   (iminamp+ivaramp*kgate)*kenv,ipitch,1
kleft    =        sqrt(kpanfac)
kright   =        sqrt(1-kpanfac)
         outs     asig*kleft,asig*kright
         endin

