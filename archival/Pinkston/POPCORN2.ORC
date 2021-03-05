        sr      =       22050
        kr      =       4410
        ksmps   =       5
        nchnls  =       2

;======================================================================;
;                 Texture Generation Instrumnent                       ;
;                                                                      ;
; This instrument generates a texture using random number generators   ;
; whose outputs are contstrained by lookup tables before being applied ;
; to various parameters which can change over time:                    ;
;                                                                      ;
; Density - the probability that an event will occur at a given time   ;
; Grain size - the envelope duration of individual events (grains)     ;
; Max gap time - the maximum time between events                       ;
; Pitch - in terms of a moving band of variable width                  ;
; Pan position - in terms of a moving band of variable width           ;
;                                                                      ;
; RFP 10-29-93                                                         ;
;======================================================================;

        instr   1
icpitfn =       p5      ;fn containing center pitch in oct
ivpitfn =       p6      ;fn containing amount of pitch variation
igapfn  =       p7      ;fn containing maximum gap time between events
igrnfn  =       p8      ;fn containing grain size
iprbfn  =       p9      ;fn containing density curve (0 - 1)
igatefn =       p10     ;fn containing envelope shape for grains
icpanfn =       p11     ;fn containing central pan position (-1 - +1)
ivpanfn =       p12     ;fn containing max variation around center
iseed1  =       p13     ;seeds for random number generators
iseed2  =       p14
iseed3  =       p15
iseed4  =       p16

inote   =       0                       ;initialize note flag to off

ktime   line    0,p3,1                  ;time line for this i-card

krndtst rand    .5,iseed1               ;get some random numbers
krndgap rand    .5,iseed2
krndpch rand    .5,iseed3
krndpan rand    .5,iseed4

start:                                  ;start of reinit pass

irndtst =       i(krndtst)+.5           ;offset to between 0 and 1
ilim    table   i(ktime),iprbfn,1       ;note probability function
inote   =       (irndtst < ilim ? 1 : 0)   ;set note flag on or off

imaxgap table   i(ktime),igapfn,1       ;maximum gap between events
idur    =       (i(krndgap)+.5)*imaxgap ;offset krndgap and scale to max gap
igrain  table   i(ktime),igrnfn,1       ;duration of the grain
idur    =       (idur < igrain ? igrain : idur) ;can't be less than grain dur

icpch   table   i(ktime),icpitfn,1      ;moving center pitch in oct
ivpch   table   i(ktime),ivpitfn,1      ;varying band width in oct
irndpch =       i(krndpch)              ;random choice within band around cpch
icps    =       cpsoct(icpch+irndpch*ivpch)
ibwmin  =       icps/20                 ;set up the filter for noise pops
ibwvar  =       3*icps-ibwmin

icpan   table   i(ktime),icpanfn,1      ;moving central pan position (-1 - +1)
icpan   =       icpan/2 + .5            ;offset and rescale to 0 - 1
ivpan   table   i(ktime),ivpanfn,1      ;maximum variation around center
ipanpos =       icpan+ivpan*i(krndpan)  ;compute pan position
ipanpos =       (ipanpos < 0 ? 0 : ipanpos)     ;constrain to between 0 - 1
ipanpos =       (ipanpos > 1 ? 1 : ipanpos)
ileft   =       sqrt(ipanpos)           ;compute channel factors
iright  =       sqrt(1-ipanpos)

        timout  0,idur,continue         ;wait idur secs til next event
        reinit  start                   ;then reinit from start label
continue:

        if      (inote == 0) kgoto end  ;skip out if a rest
kgate   oscil1i 0,1,igrain,igatefn      ;note envelope
kbw     expseg  1,igrain,.001
        print   i(ktime),inote,idur,icps
        rireturn                        ;stop the reinit pass here

anoise  rand    p4
asig    reson   anoise,icps,ibwmin+ibwvar*kbw,2
asig    =       asig*kgate
        outs    asig*ileft,asig*iright
end:
        endin

