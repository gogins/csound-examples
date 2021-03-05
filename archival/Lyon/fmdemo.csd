<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo fmdemo.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr=44100
kr=4410
ksmps=10
;cheesy FM

;f1 0 4096 10 1
;i1 0 dur freq amp

instr 1 ; accent
icar = 1.
icps = p4
imod = 1.0 * icar
igain = p5 * 25000
isust = p3 - .2
	kenv linseg 0, .1, igain, isust, igain, .1, 0
	kindex line 1, p3,  2.
	kmod line icar, p3, icar * 2
	afm foscil kenv, icps, icar, kmod, kindex, 1; sine
	out afm
endin
</CsInstruments>
<CsScore>
f1 0 4096 10 1
i1 0 10 450 1

</CsScore>
</CsoundSynthesizer>
