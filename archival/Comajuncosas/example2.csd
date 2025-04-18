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

iafno ftgen 3, 0, gisize, 5, .1, gisize, 1

loop:
irow = i(krow)
ip1 tablei irow, 3

iftnum = gifn0+i(krow)
iafno ftgen iftnum, 0, gisize+1 , 21, 10, 1, ip1
krow = krow + 1
if krow >= gisize goto end
reinit loop

end:
endin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 2; Orbit & waveform generator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

inote = cpspch(p4)
iamp  = 20000

; set an ascending orbit to index the surface

kamp1 expseg .5, .5, .000001
kamp2 randi .3, .4, p5
kamp = kamp1 + kamp2 + .3
kradius expon .4, p3, .3
kx oscili kradius+ .1*kamp2, inote, 1; sine
ky expseg .99, .2, .3,p3-.2, .01

; map the orbit through the surface
; table indexes

kfndown  = int(ky*gisize) + gifn0 
kfnup    = int(1+ky*gisize) + gifn0
kndx     = kx; normalized 0 to 1

igoto end

;table read

azdown tableikt kndx,kfndown, 1, .5
azup   tableikt kndx,kfnup,   1, .5

;linear interpolation

ay upsamp frac(ky*gisize)

az = (1-ay)*azdown + ay*azup
az tone az, 500

;final output & endin
out iamp*az*kamp*3

end:
endin

</CsInstruments>
<CsScore>
f1 0 8193 10 1; a sine wave from -1 to 1 for table index
f2 0 8193 19 1 1 0 1; a sine wave from 0 to 1 for table number

i1 0 1
s
t 0 180

i2  0    5  5.00 .24
i2  4    5  5.00 .43
i2  5    5  5.00 .23
i2  8    5  5.00 .96
i2 11    5  5.00 .01
i2 12    5  5.00 .27
i2 14    5  5.00 .72
i2 18    30 5.00 .54
i2 18.12 30 5.00 .73

e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
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
