<CsoundSynthesizer>
<CsOptions>
csound -RWm7o ./popcorn.wav ./temp.orc ./temp.sco
</CsOptions>
<CsInstruments>
sr=44100 ; sr must equal kr
kr=44100
ksmps=1
nchnls=2

instr 2

idur = p3 ; Duration
iamp = p4 ; Amplitude
ifqc = cpspch(p5) ; Pitch to Frequency
ifade = p6 ; Fade in and out
ih = .004 ; delta t
axn init 1 ; Initial x value
ayn init -.5 ; Initial y value

aamp linseg 0, ifade, iamp, idur-2*ifade, iamp, ifade, 0 ; Amp envelope

; Popcorn fractal
axnp1 = axn - ih*sin(ayn + tan(3*ayn))
aynp1 = ayn - ih*sin(axn + tan(3*axn))
axn = axnp1
ayn = aynp1

arnd rand 2 ; Generate noise

aenv1 linseg 200, idur, 1000 ; Frequency ramp
aenv2 linseg 40, idur, 400 ; Frequency modulation ramp

aout rezzy arnd, aenv1+ayn*aenv2, 50 ; Filter noise and sweep frequency

outs aout*aamp, aout*aamp ; Output

endin

</CsInstruments>
<CsScore>
; SCORE
f1 0 65536 10 1 ; Not used sine wave

; Sta Dur Amp Pitch Fade
i2 0 60 9000 6.00 2

</CsScore>
</CsoundSynthesizer>
