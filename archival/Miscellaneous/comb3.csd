<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo comb3.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 44100
kr        =         4410
ksmps     =         10
nchnls    =         1
iafno ftgen 1, 0, 65537, 10, 1 ; Sine wave.

        instr 1
a1      soundin 5
a2      comb        a1*p4*.5, p5, p6, 0
        out     a2
        endin

</CsInstruments>
<CsScore>
;p1  p2   p3   p4   p5   p6
;i   time dur  amp  rvt  loopt
i1   0    .5   1    0    .008
i1   +    .    .37  <    .
i1   .    .    .32  <    .
i1   .    .    .32  <    .
i1   .    .    .3   4    .
e


</CsScore>
</CsoundSynthesizer>
