<CsoundSynthesizer>
<CsOptions>
DirectCsound -RWdo test.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 48000
kr = 4800
ksmps = 10
nchnls = 2

; ORC
;---------------------------------------------------------
; Percussion
;---------------------------------------------------------
       instr     18

idur   =         p3            ; Duration
iamp   =         p4            ; Amplitude
ifqc   =         cpspch(p5)    ; Pitch to frequency
ipanl  =         sqrt(p6)      ; Pan left
ipanr  =         sqrt(1-p6)    ; Pan right
itime  =         p7            ; Reverb time
ifdbk  =         p8            ; Feedback level
idecay =         p9            ; Impulse decay time
isweep =         p10           ; Delay sweep
iq     =         p11           ; Resonance/Q

adel   init      0

kdclck linseg    1, idur-.002, 1, .002, 0 ; Declick envelope
kclk   linseg    1, idecay, 0, idur-idecay, 0 ; Generate a click
ktime  expseg    itime, idur, itime*isweep

anois  rand      kclk                         ; Genrate impulse
asig   rezzy     anois*5, ifqc, iq, 1         ; High pass rezzy



adel   vdelay3    (asig+adel)*ifdbk, ktime*1000, 1000

aout   =         (adel+asig)*iamp*kdclck
       outs      aout*ipanl, aout*ipanr            ; Output the sound

       endin
</CsInstruments>
<CsScore>
f1 0 65536 10 1

; Percussion 1
;    Sta     Dur  Amp     Pitch  Pan  DelTime  FdBack Decay  DelaySweep  Q
i18  1.375   .2   16000   9.00   .2   0.02     .7      .01   .5          20
i18  2.625   .2   14000   9.00   .8   0.02     .8      .01   .4          10
i18  3.375   .2   16000   9.00   .2   0.02     .7      .01   .5          20
i18  3.625   .2   14000   9.00   .8   0.02     .8      .01   .4          10
i18  5.375   .2   16000   9.00   .2   0.02     .7      .01   .5          20
i18  6.625   .2   14000   9.00   .8   0.02     .8      .01   .4          10
i18  7.375   .2   16000   9.00   .2   0.02     .7      .01   .5          20
;i18  7.625   .2   12000   9.00   .8   0.02     .8      .01   .4          10
i18  7.750   .25  0       9.00   .8   0.02     .8      .01   .4          10

; Perc sound 2
i18  0.125   .2   25000   8.00   .4   0.1      .2      .05   .8          10
i18  1.125   .2   35000   8.00   .4   0.1      .2      .05   .8          60
i18  2.125   .2   25000   8.00   .4   0.1      .2      .05   .8          10
i18  3.125   .2   35000   8.00   .4   0.1      .2      .05   .8          60
i18  4.125   .2   25000   8.00   .4   0.1      .2      .05   .8          10
i18  5.125   .2   35000   8.00   .4   0.1      .2      .05   .8          60
i18  6.125   .2   25000   8.00   .4   0.1      .2      .05   .8          10
i18  7.125   .2   35000   8.00   .4   0.1      .2      .05   .8          60

; Perc sound 3
i18  0.875   .4   15000   10.00  .0   0.04     .7      .02   2           5
i18  2.875   .4   15000   10.00  .0   0.04     .7      .02   1.8         10
i18  4.875   .4   15000   10.00  .0   0.04     .7      .02   2           20
i18  6.875   .4   15000   10.00  .0   0.04     .7      .02   2.2         10

; Perc sound 4
i18  5.625   .25  20000   8.07   .4   0.18     .7      .01   .1          10
i18  7.626   .25  19000   8.07   .6   0.18     .7      .01   .1          10


</CsScore>
</CsoundSynthesizer>
