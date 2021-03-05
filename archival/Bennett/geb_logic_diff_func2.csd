<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 4410
nchnls = 1

instr 1
kterm phasor 1 / p3
ireiterate = 100
iamp = p4
istart = p5
iend = p6
iextent = iend - istart
irange = p7 - p8

krvar = kterm * iextent + istart
kcounter = 1
kx = 0.5
jumpback:
if (kcounter == ireiterate) kgoto jump
kx1 = kx * krvar * (1.0 - kx)
kx = kx1
kcounter = kcounter + 1
kgoto jumpback

jump:
kpitch = kx * irange
printk 0.1, krvar
a1 oscili iamp, kpitch, 1

out a1
endin

</CsInstruments>
<CsScore>
f 1 0 32768 10 1
i 1 0 60 20000 3.7 3.9 500 125
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>398</width>
 <height>246</height>
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
