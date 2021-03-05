<CsoundSynthesizer>
<CsOptions>
DirectCsound -RWdo test.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
;ORC
; Coded by Hans Mikelson October 1999

sr      =        44100                      ; Sample rate
kr      =        4410                       ; Kontrol rate
ksmps   =        10                         ; Samples/Kontrol period
nchnls  =        2                          ; Normal stereo
        zakinit  50,50                      ; May need this later

;---------------------------------------------------------
; Terrain Lead 1
;---------------------------------------------------------
       instr     1

idur   =         p3            ; Duration
iamp   =         p4            ; Amplitude
ifqc   =         cpspch(p5)    ; Pitch to frequency
ipanl  =         sqrt(p6)      ; Pan left
ipanr  =         sqrt(1-p6)    ; Pan right
iplsf  =         p7            ; Frequency modifier
iwahrt =         p8            ; Wah rate
iwahtb =         p9            ; Wah table
ipbnd  =         p10           ; Pitch Bend Table

kpbnd  oscili    1, 1/idur, ipbnd                      ; Pitch bend
kwrt   linseg    1, idur*.3, 1.5, idur*.7, .2          ; Pulse width rate
kdclk  linseg    0, idur*.3, 1, idur*.4, 1, idur*.3, 0 ; Declick

asin   oscili    1, iplsf, 1         ; Sine wave pulse frequency
ar     =         asin*asin           ; Make it positive

armp   oscili    100, iwahrt*kwrt, iwahtb ; PWM
ayi    oscili    ar*armp, iplsf, 1   ; Y
ayf    =         .1/(.1+ayi*ayi)     ; Sort of a square pulse wave at this point

asig   oscili    1, ifqc*kpbnd, 1    ; Sine oscillator with pitch bend

       outs      ayf*iamp*asig*kdclk*ipanl, ayf*iamp*asig*kdclk*ipanr ;Output the sound

       endin
</CsInstruments>
<CsScore>
;SCO
f1  0 65537 10 1

f20 0 1025  5  .01 512 1 513 .01
f21 0 1025  7  .01 512 1 513 .01
f22 0 1025  10 .8 .5 .1 .2

f11 0 1025 -5  .5  256 1  256 4   256 2  257 2
f12 0 1025 -5  1   256 1  256 2   256 2  257 .25
f13 0 1025 -5  .75 256 1  256 1   256 .5 257 1
f14 0 1025 -5  2   256 .5 256 1   256 1  257 2
f15 0 1025 -5  1   256 2  256 2   256 2  257 2

t 0 20

;    Sta     Dur  Amp    Pitch  Pan  PlsFqc WahRate  WahTable  PtchBend
i1   0       16   8000   7.06   .5   80     .5       20        13
i1   8       15   6000   8.00   0    32     .2       21        11
i1   11      17  13000   7.00   1    10     .4       22        12
i1   12      16  12000   8.07   .3   30     .2       20        14
i1   16      20  11000   9.05   .8   120    .3       21        15
i1   18      23   7000   10.03  .5   25     .1       22        11
i1   20      22   5000   7.00   .5   46     .4       20        12








</CsScore>
</CsoundSynthesizer>
