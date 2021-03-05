<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1



 instr 2
asig oscil 10000, 440, 3
out asig
endin

;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
instr 1; Mass linked to ground (damped sine wave)
;coded by Josep M Comajuncosas / gelida@intercom.es
;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

i2pi2 =   39.47841760436; (2pi)^2

;set initial position and velocity of the mass
iv0 = 0
ix0 = 10000

;set frequency, z and m
ifreq = cpspch(p4)
iz = p5
im1 = 30

;normalize (dont touch this!)
iz = iz/(1000000000*sr); z given in N*s/(kg*10e-9)
im1 = im1/1000000000; mass given in kg*10e-9

;calculate k according to given freq
ik = i2pi2*ifreq*ifreq*im1
ik = ik/(sr*sr)

ax1 init ix0
axprev1 init ix0-1000*iv0/sr

;calculate actual force and then next position
af1 = ik*(-ax1) + iz*(-(ax1-axprev1))
anext1 = af1/im1 + 2*ax1-axprev1

	out anext1

;prepare for next pass
axprev1 = ax1
ax1 = anext1

endin

</CsInstruments>
<CsScore>
;      freq  damping
i1 0 2 8.00  5000
i1 2 2 8.00  1000
i1 4 2 8.00  200
i1 6 2 8.00  50
i1 8 2 8.00  10

s
i1 0 2 6.00  100
i1 2 2 7.00  100
i1 4 2 8.00  100
i1 6 2 9.00  100
i1 8 2 10.00 100
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>4</height>
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
