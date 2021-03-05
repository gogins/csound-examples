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

; generate tables to control the strenght of partials generated
;strength for partial 1
iafno ftgen 3, 0, gisize, 7, 1, gisize/2, 1, gisize/4, 0, gisize/4, 0
;strength for partials 3, 5 & 7
iafno ftgen 4, 0, gisize, 7, 0, gisize/4, 0, gisize/4, 1, gisize/4, 0, gisize/4, 0
;strength for partials 2, 4 & 6
iafno ftgen 5, 0, gisize, 7, 0, gisize/2, 0, gisize/4, 1, gisize/4, 1

loop:
irow = i(krow)
ip1 tablei irow, 3
ip2 tablei irow, 4
ip3 tablei irow, 5

iftnum = gifn0+i(krow)
iafno ftgen iftnum, 0, gisize+1 , 13, 1, 1, 0, ip1, ip2, ip3, ip2, ip3, ip2, ip3

krow = krow + 1
if krow >= gisize goto end
reinit loop

end:
endin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 2; Orbit & waveform generator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

inote = p4
iamp  = 20000

; set an ascending ellipse to index the surface

kx oscili .5, inote, 1; sine
kycosine oscili .05, inote, 2, 1/4; cosine
kyline line .1, p3, .9
ky = kycosine + kyline

; map the orbit through the surface
; table indexes

kfndown  = int(ky*gisize) + gifn0 
kfnup    = int(1+ky*gisize) + gifn0
kndx     = kx; normalized 0 to 1

igoto end

;table read

azdown tableikt kndx,kfndown, 1, .5, 1
azup   tableikt kndx,kfnup,   1, .5, 1


;linear interpolation

ay upsamp frac(ky*gisize)

az = (1-ay)*azdown + ay*azup

;final output & endin
out iamp*az

end:
endin

</CsInstruments>
<CsScore>
f1 0 8193 10 1; a sine wave from -1 to 1 for table index
f2 0 8193 19 1 1 0 1; a sine wave from 0 to 1 for table number

i1 0 1
s
i2 0  6 100
i2 6  6 200
i2 12 6 400
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>1312768</width>
 <height>0</height>
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
