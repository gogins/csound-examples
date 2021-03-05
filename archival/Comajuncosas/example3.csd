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
;strength for brass partials (all)
iafno ftgen 4, 0, gisize, 9, .25, 1, 90
;strength for clarinet partials (1, 3, 5, 7)
iafno ftgen 3, 0, gisize, 9, .25, 1, 0

loop:
irow = i(krow)
ip1 tablei irow, 3
ip2 tablei irow, 4

iftnum = gifn0+i(krow)
iafno ftgen iftnum, 0, gisize+1 , 13, 1, 1, 0, .6*ip1+ip2, -.7*ip1, -.8*ip1-.7*ip2, ip1, .8*ip1+.4*ip2, -.6*ip1, -.4*ip1-.1*ip2

krow = krow + 1
if krow >= gisize goto end
reinit loop

end:
endin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 2; Orbit & waveform generator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

inote = cpspch(p4)
iamp  = 10000

; set an ascending orbit to index the surface
kportamento linseg -1, .1, .1, .1, 0, p3-.2, 0; add some portamento to the attack
kvibamp oscil1i 0, .05, p3, 3; add vibrato to the clarinet
kvib oscili kvibamp, 5, 1
kamp linseg 0, .03, 1, p3-1.3, .8, 1, .5, .2, 0
kx oscili .5*kamp*(1+kvib), inote*(1+.05*kportamento+.02*kvibamp), 1; sine
ky expon .99, p3, .01

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
out iamp*az*kamp

end:
endin

</CsInstruments>
<CsScore>
f1 0 8193 10 1; a sine wave from -1 to 1 for table index
f2 0 8193 19 1 1 0 1; a sine wave from 0 to 1 for table number

i1 0 1
s
t 0 120

i2 0    6    7.00
i2 6    1    7.03
i2 7    1    7.07
i2 8    2    7.11
i2 10  .5    7.08
i2 10  .5    7.11
i2 11   7    8.00

i2 0    6   7.07
i2 6    1   7.11
i2 7    1   8.00
i2 8    2.5 8.03
i2 10.5 7.5 8.07
i2 11   7   8.04

e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>1132134400</width>
 <height>1154613248</height>
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
