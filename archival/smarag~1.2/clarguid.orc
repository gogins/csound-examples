sr      =   44100
kr      =   4410
ksmps   =   10
nchnls  =   2

instr 1                 ;WAVEGUIDE CLARINET 

; Interesting points in the extended Csound implementation: The "am"
; factor for ipmax = 10 takes small values like .005 - .02.  If the
; value is small (.005) then the reed takes more time to respond to
; the mouth pressure.  For values bigger than .03 strange things
; happen.  I will assume that they are multiphonics or some overflow
; of air.  If "ipmax" is lowered then these numbers change.  "ipmax"
; does not need values much bigger than 10 since overflow and feedback
; show up.  "am" and" "ipmax" determine reed stiffness and embrochure
; ( how tight the reed is pressed by the player).  "idamp" according
; to my acoustics book should be between 1400Hz to 2000Hz.  1000Hz
; sounds fine to me!  For some reason pitch is in the wrong octave.  I
; try to bring it up by multiplying it by 2 but I thing it's still
; off.  "agrowl" is a simple simulation of the growling sax players do
; to get multiphonics.  If "agrowl" is used with "am" equal to .03 and
; a low cuttof frequency for the bell I get a harmonic.  In MIT's
; Csound implementation the instrument behaves and sounds much
; different.  The harmonic trick does not work and the cutoff
; frequency sounds good at 1800Hz.


;       INIT SECTION

idamp   =           1000        ;Determines brightness of clarinet
ipitch  =           4*cpspch(p4);Pitch (Something's wrong here! But it works)
ipmax   =           10          ;Max mouth pressure
ivol    =           1000        ;Bring to audible level factor
apbp    init        0           ;Init the returning pressure wave

;       CONTROL SECTION

apm     linseg      0, p3/2, ipmax, p3/2, 0 ;Mouth pressure
    
am      =           .01      ;Embrochure/reed stiffness factor

krand   rand        1                       ;Random element
krand   port        krand, 1/kr
apm     =           apm - (krand * ipmax)/10

kvs     line        0, p3, 1  ;Simple time varying vibrato
kpitch  oscil       kvs*50, kvs*5, 3
kpitch  =           ipitch - kpitch + krand * 50
agrowl oscil       apm, 100, 4             ;Growling
apm    =           apm + agrowl

;agrowl soundin       4,0,4                  ;Resonating a Soundfile
;apm    =           agrowl

;       WAVEGUIDE STARTS HERE

; The ugly variable names mean:

; apdp:         Closed reed pressure drop
; apbp, apbm:   Traveling pressure waves
; atr:          Reed responce to pressure
; abell:        Pressure wave at bell
; arefl:        Reflected pressure wave at bell
; aout:         Output from bell

apdp    =           2*apbp - apm
atr     =           1 - am*(apdp - ipmax)
;atr    reed        apdp, ipmax, am     ;My reed opcode (not used now)
apbm    =           apm/2 + atr * apdp/2;Start from reed

;       MIT CSOUND IMPLEMENTATION (no vibrato and pitch bends)

;abell   delay       apbm, .5/ipitch        ;Go to bell
;arefl   tone        -abell, idamp          ;Damp/reflect on bell
;aout    atone       abell, idamp           ;Get out of bell
;apbp    delay       arefl, .5/ipitch       ;Go back to reed
    

;       EXTENDED CSOUND IMPLEMENTATION

abell  vdelay      apbm, 500/kpitch, 1000 ;Go to bell
arefl  butterlp    -abell, idamp          ;Damp/reflect on bell
aout   butterhp    abell, idamp           ;Get out of bell
apbp   vdelay      arefl, 500/kpitch, 1000;Go back to reed

        outs        aout*ivol, aout*ivol   ;Give it to me!
endin
