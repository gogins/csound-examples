<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 1; Surface generator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p3 = .01
gisize = 256;number and size of the tables
gifn0 = 301
krow init 0

; fill isize tables of size isize to create the surface

iafno ftgen 3, 0, gisize+1 , 9, 1, 1, 270
loop:
irow = i(krow)
imult tablei irow, 3
iftnum = gifn0+i(krow)
iafno ftgen iftnum, 0, gisize+1 , 11, 30, 1, imult*1.15

krow = krow + 1
if krow >= gisize + 2 goto end
reinit loop

end:
endin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 2; Orbit & waveform generator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

inote = cpspch(p4)
iamp  = 10000
ixcenter = p5
iycenter = p6

; set a spiral of kradius and center (p5,p6) to index the surface

kamp linen 1, p3/3, p3, p3/3
kradius oscil .3, .2, 2

kx oscili kradius, inote*.999, 1; sine
ky oscili kradius, inote*1.001, 2, 1/4; cosine

ky = ky+(1-2*kradius)/2+ (iycenter-.5)

; map the orbit through the surface
; table indexes

kfndown  = int(ky*gisize) + gifn0 
kfnup    = int(1+ky*gisize) + gifn0
kndx     = kx; normalized 0 to 1

igoto end

;table read

azdown tableikt kndx,kfndown, 1, ixcenter, 1
azup   tableikt kndx,kfnup,   1, ixcenter, 1


;linear interpolation

ay upsamp frac(ky*gisize)

az = (1-ay)*azdown + ay*azup

;final output & endin
out iamp*az*kamp

end:
endin

</CsInstruments>
<CsScore>
f1 0 8193 10 1; a sine wave from -1 to 1 for table index
f2 0 8193 19 1 1 0 1; a sine wave from 0 to 1 for table number
i1 0 1
s

; As you cannot index tables outside the (normalized) range 0 to 1
; and the max. radius of the orbit is .3 (see the orc)
; DONT set p6 (the y coordinate) bigger than .7 or smaller than .3 !
; With the x theres not this problem as 
; the tableikt opcode is set to wrap mode 
; (which is consistent with the periodic nature of GEN11)
i2 0 2 5.07 .5 .5
i2 2 4 6.01 .5 .5
f0 2
s
i2 0   25 6.00 .5  .5
i2 1.5 25 5.00 .45 .48
i2 2.4 25 6.00 .63 .6
i2 3.3 25 5.00 .21 .59
i2 4.8 25 6.00 .12 .64
i2 5   25 6.00 .94 .4

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
