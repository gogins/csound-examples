<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 1; band limited triangle wave
; coded by Josep M Comajuncosas / jan98
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

iamp = 10000; intended max. amplitude
kenv linen 1, .2,p3,.2; volume envelope
kfreq = cpspch(p4)
kfreqn = kfreq/sr
ibound = sr/4; set it to sr/2 for true BL square wave

apulse1 buzz 1, kfreq, ibound/kfreq, 1
apulse2 buzz 1, kfreq, ibound/kfreq, 1, .5
apulse3 = apulse1 - apulse2

asqrdc integ apulse3
asqr = asqrdc - .5
asqr = asqr*2*kfreqn/.25

atridc tone asqr,5; leaky integrator
atri atone atridc, 5;this is convenient to  remove DC
out atri*iamp*kenv*500; 500 is empyrical again
endin

</CsInstruments>
<CsScore>
f1 0 65537 10 1
i1 0 2 6.00
i1 2 2 7.00
i1 4 2 8.00
i1 6 2 9.00
i1 8 2 10.00
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView nobackground {0, 0, 0}
</MacGUI>
