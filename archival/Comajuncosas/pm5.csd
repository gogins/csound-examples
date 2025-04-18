<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;pm5.orc
sr = 44100
kr = 44100
ksmps = 1; essential for this instrument. Dont change it!

gimaxn = 20;the maximum number of discrete masses youll use
;allocate some zak space
zakinit 1,4*gimaxn; we should need a 4-dimensional array here 
;(actual, previous and next positions, and actual forces)


;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
;strange plucked string. 20 masses! (be patient)
instr 1; as pm4 with arbitrary masses and positions
;coded by Josep M Comajuncosas / Barcelona - jan.98
;gelida@intercom.es
;variables to play with : inm (<=gimaxn), k (0 to 1), z
;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
inm = 20; 98 effective masses (both grounds act like infinite masses)
kndx init 1

;set k and z
ik = p4
iz = p5

;normalize (don't touch this!)
ik = ik/(sr*sr)
iz = iz/(1000000000*sr)

imaxx = 2000
imaxm = 40
kskip init 0
if kskip == 1 kgoto noinitveloc

;initialize positions with a waveform (f2)
;initial velocities are set to 0
loop0:
kiprevx table kndx/inm, 2, 1
zkw imaxx*(kiprevx), kndx
zkw imaxx*(kiprevx), inm + kndx

kndx = kndx +1
if kndx < inm -1 goto loop0
kndx = 0
kskip = 1

noinitveloc:

;calculate actual forces and positions of masses

;"mass" on the left - ground
krightx zkr kndx +1
kprevrightx zkr kndx + inm +1
kf = ik*(krightx) + iz*((krightx-kprevrightx))
zkw kf, kndx + 3*inm
kndx = kndx + 1

;central masses
loop1:

;initialize masses (f1)
km tablei kndx/inm, 1, 1
km = imaxm*(km+1)/2; for a table in (-1,1) - masses must be > 0!
;km = imaxm*km; for a table in (0,1)
km = km/1000000000; dont touch!

kx zkr kndx
kprevx zkr kndx + inm
krightx zkr kndx +1
kprevrightx zkr kndx + inm +1
kleftf zkr kndx + 3*inm -1

kf = -kleftf + ik*(krightx-kx) + iz*((krightx-kprevrightx)-(kx-kprevx))
knextx = kf/km + 2*kx-kprevx
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

	kout zkr int(inm/2)
	aout upsamp kout
	out aout

kndx = 0
endin

instr 2
zkcl 0, 4*gimaxn; sorry for the trick !
endin

;i fer turnon 2,0 i a 2 zkcl -> turnoff?
; o b zkcl turnon 2,p3 turnoff tot a instr 1, amb gip4 gip5

</CsInstruments>
<CsScore>
f1 0 1025 7 -1 1024 1; for a linear mass distribution
;f1 0 256 7 -1 1024 21 1; random values...

f2 0 256 11 50; initial pulse to excite the string

;         k  damping
; for lower damping values the instruments gets crazy (?) 
i2 0 .01
i1 .02 2 .4  1000
s
i2 0 .01
i1 .02 2 .3  300
s
i2 0 .01
i1 .02 15 .5  100
s
i2 0 .01
i1 .02 10 .6  200
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
