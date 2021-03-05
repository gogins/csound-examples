<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1; Dont change it!
gimaxn = 20
;allocate some zak space
zakinit 1,4*gimaxn; we should need a 4-dimensional array here 
;(actual, previous and next positions, and actual forces)
;imaxn is the maximum number of discrete masses youll use


;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
instr 1; string with arbitrary n masses. Constant linear density
;coded by Josep M Comajuncosas / gelida@intercom.es
;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

inm = 20; 18 effective masses (both grounds act like infinite masses)
kndx init 0

;set initial position and velocity of the mass
ziw 15, 3 + inm; initialize one position - here, the previous position of the 4th mass
ziw 15, 3; initialize one position - here, the actual position of the 4th mass

;set k, z and m
ik = p4
iz = p5
im = 30

;normalize (don't touch this!)
ik = ik/(sr*sr)
iz = iz/(1000000000*sr); z given in N*s/(kg*10e-9)
im = im/1000000000; mass given in kg*10e-9


;calculate actual forces and positions of masses

;"mass" on the left - ground
krightx zkr kndx +1
kprevrightx zkr kndx + inm +1
kf = ik*(krightx) + iz*((krightx-kprevrightx))
zkw kf, kndx + 3*inm
kndx = kndx + 1

;central masses
loop1:
kx zkr kndx
kprevx zkr kndx + inm
krightx zkr kndx +1
kprevrightx zkr kndx + inm +1
kleftf zkr kndx + 3*inm -1

kf = -kleftf + ik*(krightx-kx) + iz*((krightx-kprevrightx)-(kx-kprevx))
knextx = kf/im + 2*kx-kprevx
zkw kf, kndx + 3*inm
zkw knextx, kndx + 2*inm

kndx = kndx + 1
if kndx < inm-1 goto loop1

;"mass" on the right - ground
kx zkr kndx 
kprevx zkr kndx + inm
kleftf zkr kndx + 3*inm -1
kf = -kleftf + ik*(-kx) + iz*(-(kx-kprevx))
zkw kf, kndx + 3*inm

;update variables for next pass
kndx = 1
loop2:
kx zkr kndx
knextx zkr kndx + 2*inm

zkw kx, kndx + inm
zkw knextx, kndx
zkw 0, kndx + 2*inm; this shouldt be necessary (?)
zkw 0, kndx + 3*inm; id. (?)

kndx = kndx + 1
if kndx < inm -1 goto loop2

	kout zkr 3
	aout upsamp kout; Im afraid this is the best way to do it...
	out aout

kndx = 0
endin

instr 2
zkcl 0, 4*gimaxn; sorry for the trick !
endin

</CsInstruments>
<CsScore>
;         k  damping
i2 0 .01
i1 .02 2 .4  1300
s
i2 0 .01
i1 .02 2 .3  1100
s
i2 0 .01
i1 .02 2 .5  1800
s
i2 0 .01
i1 .02 2 .6  600
s
i2 0 .01
i1 .02 5 .2  500
s
i2 0 .01
i1 .02 10 .5  300

e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>12</height>
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
