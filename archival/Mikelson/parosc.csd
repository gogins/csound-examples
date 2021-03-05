<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo parosc.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
; Parametric Equation oscillators
sr=44100
kr=22050
ksmps=2
nchnls=2

; Cycloid curve
; This set of parametric equations defines the path traced by
; a point on a circle of radius B rotating outside or inside
; a circle of radius A.
         instr  2

idur     =      p3           ; Duration
iamp     =      p4           ; Amplitude
ifqc     =      cpspch(p5)   ; Convert pitch to frequency
ia       =      p6           ; Radius circle a
ib       =      p7           ; Radius circle b
ihole    =      p8           ; Position along circle b radius which is followed
isgn     =      p9           ; Sign +=outside circle, -=inside circle
ipbnd    =      p10          ; Pitch bend table
ibndrt   =      p11          ; Pitch bend rate
iscale   =      1/(ia+2*ib)  ; Scaling factor to normalize volume

apbnd    oscil  1, ibndrt/idur, ipbnd              ; Pitch bend
aamp     linseg 0, .02, iamp*iscale, idur-.04, iamp*iscale, .02, 0 ; DeClick envelope
afqc     =      apbnd*ifqc                         ; Bend the pitch

; Sine and Cosine
acos1    oscil  ia+ib*isgn, afqc, 1, .25           ; Cosine equation 1
acos2    oscil  ib*ihole, (ia-ib)/ib*afqc, 1, .25  ; Cosine equation 2
ax       =      acos1 + acos2                      ; X value is the sum of the cosines

asin1    oscil  ia+ib*isgn, afqc, 1                ; Sine equation 1
asin2    oscil  ib*ihole, (ia-ib)/ib*afqc, 1       ; Sine equation 2
ay       =      asin1 - asin2                      ; Y value is the difference of the sines

         outs   aamp*ax, aamp*ay                   ; Declick and output

         endin

; Butterfly Curves
        instr  7

idur    =      p3          ; Duration
iamp    =      p4          ; Amplitude
ifqc    =      cpspch(p5)  ; Convert pitch to frequency
ia      =      p6          ; Parameter A
ib      =      p7          ; Parameter B
ic      =      p8          ; Parameter C
id      =      p9          ; Parameter D
ie      =      p10         ; Parameter E

kamp    linseg 0, .001, iamp, idur-.002, iamp, .001, 0 ; Declick amplitude envelope

klfo1   oscil  .01, 6, 1                            ; LFO 1
krmp1   linseg 0, .1, 0, .2, 1, p3-.3, 1            ; Ramp 1

klfo2   oscil  .02, 4, 1                            ; LFO 2
krmp2   linseg 0, .4, 1, p3-.2, 1                   ; Ramp 2

kc      linseg .5*ic, idur*.5, ic*2, idur*.5, .5*ic ; Modulate C with an envelope
kb      =      ib*(1+klfo1*krmp1)                   ; Modulate B with an LFO
kd      =      id*(1+klfo2*krmp2)                   ; Modulate D with an LFO

; Cosines
acos1   oscil  1,  ifqc,    1, .25                  ; Cosine 1
acos2   oscil  ia, kb*ifqc, 1, .25                  ; Cosine 2
acos3   oscil  1, ifqc/kd,  1, .25                  ; Cosine 3

; Sines
asin1   oscil  1, ifqc,   1                         ; Sine 1
asin2   pow    asin1, ic                            ; Sine 2
asin3   oscil  1, ifqc/kd,   1                      ; Sine 3

arho    =      exp(ie*acos1)-acos2+asin2            ; Generate the radius

ax      =      arho*acos3                           ; Generate X value
ay      =      arho*asin3                           ; Generate Y value

        outs   ax*kamp, ay*kamp                     ; Declick and output

        endin

; Spherical Lissajous Figures
        instr   8

idur    =       p3          ; Duration
iamp    =       p4          ; Amplitude
ifqc    =       cpspch(p5)  ; Convert pitch to frequency
iu      =       p6          ; U parameter
iv      =       p7          ; V parameter
irt2    =       sqrt(2)     ; Square root of 2
iradius =       1           ; Radius is 1

kamp    linseg  0, .002, iamp, idur-.004, iamp, .002, 0 ; Declick envelope

acos1   oscil   1, .5, 1, .25
asin1   oscil   1, .5, 1

; Cosines
acosu   oscil   1, iu*ifqc,   1, .25       ; Cosine of frequency U
acosv   oscil   1, iv*ifqc,   1, .25       ; Cosine of frequency V

; Sines
asinu   oscil   1, iu*ifqc,   1            ; Sine of frequency U
asinv   oscil   1, iv*ifqc,   1            ; Sine of frequency V

; Compute X and Y
ax      =       iradius*asinu*acosv        ; Compute X value
ay      =       iradius*asinu*asinv        ; Compute Y value
az      =       iradius*acosu              ; Compute Z value
az1     =       az*acos1                   ; Modulate Z value for X
az2     =       az*asin1                   ; Modulate Z value for Y
        outs    (ax+az1)*kamp/2, (ay+az2)*kamp/2 ; Scale X and Y values and add Z

        endin


</CsInstruments>
<CsScore>
f1 0 65536 10 1
f2 0 1024  -7 1 1024 1
f3 0 1024  -7 1 400  1 224 1.5 400 1.5
f4 0 1024  -7 1 400  1 224 0.5 400 0.5
f5 0 1024  -8 1 256 3 256 .2 256 2 256 1


; Cycloid
;    Sta   Dur  Amp     Pitch   A    B    Hole  Sign  PBend BRate
i2   0     .4   20000   8.00    8    2    1     1     3     1
i2   +     .    .       7.11    5.6  .4   .8   -1     2     .
i2   .     .    .       8.05    2    8.5  .7   -1     4     .
i2   .     .    .       8.07    5    3    2     1     2     .

i2   .     .4   20000   8.00    8    2    1     1     3     .
i2   .     .    .       7.07    5.6  .4   .8   -1     2     .
i2   .     .    .       8.03    2    8.5  .7   -1     4     .
i2   .     .    .       8.00    5    3    2     1     2     .

i2   .     1.6  20000   8.00    5    3    2     1     5     8

; Butterfly Curves
;    Sta  Dur  Amp    Frqc   A    B     C     D    E
i7   5    .4   4000   7.00   2    4     5     22   1
i7   +    .    .      7.07   2.1  6     7     30   .9
i7   .    .    .      8.00   3.1  8     15    48   1
i7   .    .    .      7.00   3.1  8     7     50   1
i7   .    .    .      7.07   2.5  3     3     90   .8
i7   .    .    .      8.00   3.1  8     9     80   1

; Spherical Lissajous
;    Sta  Dur  Amp    Frqc    U    V
i8   7.5  .2   25000   6.00   3    4
i8   +    .    26000   5.09   2    7
i8   .    .    25000   6.04   5.3  4.7
i8   .    .    26000   6.08   1    2
i8   .    .    25000   6.04   5.3  4.7
i8   .    .    26000   6.08   .7   3
i8   .    .    25000   6.04   2.1  3.6
i8   .    .    26000   6.08   .99  2.01
;
i8   .    .    25000   6.00   3    4
i8   .    .    26000   5.09   2    7
i8   .    .    25000   6.04   5.3  4.7
i8   .    .    26000   6.08   1    2
i8   .    .    25000   6.04   5.3  4.7
i8   .    .    26000   6.08   .7   3
i8   .    .    25000   6.04   2.1  3.6
i8   .    .8   26000   6.08   .99  2.01


</CsScore>
</CsoundSynthesizer>
