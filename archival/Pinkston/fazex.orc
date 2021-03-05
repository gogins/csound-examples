sr       =        44100
kr       =        4410
ksmps    =        10
nchnls   =        2
;=======================================================================;
; FAZEX           Phasing Instrument                                    ;
;                 University of Texas at Austin Computer Music Studio   ;
;=======================================================================;
; p6     =        decay time                                            ;
; p7     =        vibrato frequency                                     ;
; p8     =        steady state attenuation factor                       ; 
; p9     =        attack component as percentage of total amplitude     ;
; p10    =        crude stereo placement ( 1 or 0 flipflop )            ;
; p11    =        phasing vibrato frequency                             ;     
;=======================================================================; 
         instr    1         
ifamp    =        p9                            ; rel amp: attack transient
ivibamp  =        (1-p9)/2                      ; rel amp: phasing component   
iamp     =        ivibamp                       ; rel amp: fund timbre
ifreq    =        cpspch(p5)
ifunc    =        3                             ; fundamental timbre func
iarand   =        .1
ifrqrnd  =        15
ifrqvib  =        p7
ifrise   =        .02                           ; attack transient speed
iat      =        .01                           ; fundamental attack speed
idec     =        p6 
idelt    =        .1                            ; delay time
ifazamp  =        .002                          ; phasing amplitude
iatten   =        p8
ifazvib  =        p11                           ; phasing speed
                                        
kgate    envlpx   p4,iat,p3,idec,2,iatten,.01  
kfgate   oscil1i  0,ifamp,ifrise,5              ; attack envelope

ifac     table    ifreq,6                       ; vibrato scaling
krand    randi    iarand,ifrqrnd,-1             ; vibrato random factor
kvib     oscil    krand+ifac,ifrqvib+krand,1    ; "beating" vibrato
afazvib  oscili   ifazamp,ifazvib,1             ; "phasing" vibrato 

aform    oscili   kfgate,ifreq,4                ; 3 phasing components
avibsig  oscili   ivibamp,ifreq+kvib,ifunc
asig     oscili   iamp,ifreq,ifunc              

ktrango  oscil1i  0,1,p3*.2,7                   ; transient removal gate...
adelin   =        (asig+avibsig)*ktrango        ; ...for the delayed signal
adelsig  delayr   idelt                         ; delay for phase filtering
aphasig  deltapi  idelt-ifazamp+afazvib-.0001   ; scaled within defined... 
         delayw   adelin                        ; ...limits
         if       (p10 == 1) goto flipflop
         outs     (avibsig+asig+aform)*kgate*2,aphasig*kgate*2
         if       (p10 != 1) goto continue
flipflop:
         outs     aphasig*kgate*2,(avibsig+asig+aform)*kgate*2 
continue:        
         endin
