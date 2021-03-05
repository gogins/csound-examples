<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
;HORGAN.ORC
sr=44100
kr=44100
ksmps=1
nchnls=1
instr 1
idur =p3
iamp =p4
ipch11 =cpspch(p5)
ipch12 =cpspch(p5+1.00)
ipch13 =cpspch(p5+2.00)
ipch14 =cpspch(p5+3.00)
asig11 poscil3 iamp, ipch11, 1
asig12 poscil3 iamp, ipch12, 1
asig13 poscil3 iamp, ipch13, 1
asig14 poscil3 iamp, ipch14, 1
asig15 =asig11+0.5*asig12+0.25*asig13+0.125*asig14
kvib1  poscil 0.1, 4, 2
kvib1  =kvib1+1
asig15 =asig15*kvib1
ipch21 =cpspch(p5+0.07)
ipch22 =cpspch(p5+1.07)
ipch23 =cpspch(p5+2.07)
ipch24 =cpspch(p5+3.07)
asig21 poscil3 iamp, ipch21, 1
asig22 poscil3 iamp, ipch22, 1
asig23 poscil3 iamp, ipch23, 1
asig24 poscil3 iamp, ipch24, 1
asig25 =asig21+0.5*asig22+0.25*asig23+0.125*asig24
kvib2  poscil 0.2, 8, 2
kvib2  =kvib2+1
asig25 =asig25*kvib2
kcut1  linseg 10000, 0.1, 1000, 0.101, 0
kcut2  linseg 10000, 0.1, 1000, 0.011, 0
asig15 butterlp asig15, kcut1
asig25 butterlp asig25, kcut2
kamp1  linseg 0, 0.001, 1, 0.1, 1, 0.1, 0
kamp2  linseg 0, 0.001, 1, 0.1, 1, 0.01, 0
asigs  =kamp1*asig15+kamp2*asig25
asigout =asigs
out  asigout
endin
</CsInstruments>
<CsScore>
;HORGAN.SCO
f1 0 8192 10 1 0.5 0.25 0.125   ;organ sine
f2 0 8192 10 1    ;organ sine 2
t 0 130 
i1 0 0.75 4000 8.00
i1 0 0.75 4000 8.04
i1 0.75 0.75 4000 8.00
i1 0.75 0.75 4000 8.04
i1 1.50 1.00 4000 8.00
i1 1.50 1.00 4000 8.04
i1 2.50 1.00 4000 8.00
i1 2.50 1.00 4000 8.04
i1 3.50 0.50 4000 8.00
i1 3.50 0.50 4000 8.04
i1 4 0.75 4000 8.02
i1 4 0.75 4000 8.05
i1 4.75 0.75 4000 8.02
i1 4.75 0.75 4000 8.05
i1 5.50 1.00 4000 8.02
i1 5.50 1.00 4000 8.05
i1 6.50 1.00 4000 8.02
i1 6.50 1.00 4000 8.05
i1 7.50 0.50 4000 8.02
i1 7.50 0.50 4000 8.05
i1 8 0.75 4000 8.05
i1 8 0.75 4000 8.09
i1 8.75 0.75 4000 8.05
i1 8.75 0.75 4000 8.09
i1 9.50 1.00 4000 8.05
i1 9.50 1.00 4000 8.09
i1 10.50 1.00 4000 8.05
i1 10.50 1.00 4000 8.09
i1 11.50 0.50 4000 8.05
i1 11.50 0.50 4000 8.09
i1 12 0.75 4000 8.04
i1 12 0.75 4000 8.07
i1 12.75 0.75 4000 8.04
i1 12.75 0.75 4000 8.07
i1 13.50 1.00 4000 8.04
i1 13.50 1.00 4000 8.07
i1 14.50 1.00 4000 8.04
i1 14.50 1.00 4000 8.07
i1 15.50 0.50 4000 8.04
i1 15.50 0.50 4000 8.07


</CsScore>
</CsoundSynthesizer>
