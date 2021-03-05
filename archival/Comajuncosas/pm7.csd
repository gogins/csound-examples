<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1; Dont change it!

;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
instr 1; hammer action simulator
;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

;set initial position and velocity of the mass
iv0 = 0
ix0 = 25000

;set k, z and m
ik = p4
iz = p5
im2 = 30
im3 = 22

;normalize (don't touch this!)
ik = ik/(sr*sr)
iz = iz/(1000000000*sr); z given in N*s/(kg*10e-9)
im2 = im2/1000000000; mass given in kg*10e-9
im3 = im3/1000000000; mass given in kg*10e-9

kx3 init ix0
kxprev3 init ix0-1000*iv0/sr

kx2 init 0
kxprev2 init 0

kf1 = ik*(kx2) + iz*((kx2-kxprev2))
if kx3 > kx2 goto nolink
kf2 = -kf1 + ik*(kx3-kx2) + iz*((kx3-kxprev3)-(kx2-kxprev2))
kf3 = -kf2 + ik*(-kx3) + iz*(-(kx3-kxprev3))
goto next

nolink:
kf2 = -kf1
kf3 = ik*(-kx3) + iz*(-(kx3-kxprev3))

next:
knext2 = kf2/im2 + 2*kx2-kxprev2
knext3 = kf3/im3 + 2*kx3-kxprev3

	aout upsamp knext2	
	out aout

kxprev2 = kx2
kxprev3 = kx3
kx2 = knext2
kx3 = knext3
endin

</CsInstruments>
<CsScore>
;      k  damping
i1 0 2 .1  300
i1 2 2 .05 500
i1 4 2 .2  200
i1 6 6 .01  50
i1 12 25 .03  5

e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
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
