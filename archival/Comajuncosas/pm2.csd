<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1

;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
instr 1; Two masses, 1 end. Scheme : m1<-->m2<-->(grnd)
;coded by Josep M Comajuncosas / gelida@intercom.es
;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

i2pi2 =   39.47841760436; (2pi)^2

;set initial position and velocity of the mass
iv0 = 0
ix0 = 10000

;set frequency, z and m
;;;ifreq = cpspch(p4)
ifreq = 500
ifreq = cpspch(p4)
iz = p5
im1 = 30
im2 = 30

;normalize (don't touch this!)
iz = iz/(1000000000*sr); z given in N*s/(kg*10e-9)
im1 = im1/1000000000; mass given in kg*10e-9
im2 = im2/1000000000; mass given in kg*10e-9

;calculate k according to given freq
ik = i2pi2*ifreq*ifreq*im1
ik = ik/(sr*sr)

ax1 init ix0
axprev1 init ix0-1000*iv0/sr

ax2 init 0
axprev2 init 0

af1 = ik*(ax2-ax1) + iz*((ax2-axprev2)-(ax1-axprev1))
af2 = -af1 + ik*(-ax2) + iz*(-(ax2-axprev2))

anext1 = af1/im1 + 2*ax1-axprev1
anext2 = af2/im2 + 2*ax2-axprev2

	out anext2

axprev1 = ax1
axprev2 = ax2
ax1 = anext1
ax2 = anext2
endin


</CsInstruments>
<CsScore>
;      freq  damping
i1 0 2 8.00  5000
i1 2 2 8.00  1000
i1 4 2 8.00  200
i1 6 2 8.00  50
i1 8 2 8.00  10
;;;e
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
 <width>396</width>
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
