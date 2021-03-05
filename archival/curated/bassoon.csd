<CsoundSynthesizer>
<CsOptions>
directcsound -odac

</CsOptions>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 1; Surface generator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p3 = .01;I don´t know why on hell I need this time to load ftables!!
gisize = 256;number and size of the tables
gifn0 = 301
krow init 0

; fill isize tables of size isize to create the surface

iafno ftgen 3, 0, gisize+1 , 19, .5, 1, 0, 1

loop:
irow = i(krow)
imult tablei irow, 3
iftnum = gifn0+i(krow)
iafno ftgen iftnum, 0, gisize+1 , 11, 50, 1, imult

krow = krow + 1
if krow >= gisize + 2 goto end
reinit loop

end:
endin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 2; Orbit & waveform generator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

p3 = p3*.9;non legato playing
inote = cpspch(p4)
iamp  = p5
kdeclick linseg 0, .001,1,p3-.02,1,.001,0

; set a spiral of kradius to index the surface

kradius linen .5,20/inote, p3, p3-50/inote
kx oscili kradius, inote, 1; sine
ky oscili kradius, inote, 2, 1/4; cosine

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

end:
az init 0
;final output & endin
aout atone az,900
out iamp*aout*kdeclick
endin

</CsInstruments>
<CsScore>
f1 0 8193 10 1; a sine wave from -1 to 1 for table index
f2 0 8193 19 1 1 0 1; a sine wave from 0 to 1 for table number

i1 0 1
s
t 0 120
i2 0 1  6.07 10000
i2 + .  7.00 12000
i2 . 2  7.06 13000
i2 . 1  7.07 15000
i2 . .  7.03 13000
i2 . .5 7.01 16000
i2 . .  7.04 15000
i2 . .  7.01 14000
i2 . .  7.00 12000
i2 . 1  6.11 11000
i2 . .  6.09 10000
i2 . 2  6.07  9000
i2 . 4  5.07 15000



</CsScore>
<CsArrangement>
</CsArrangement>
</CsoundSynthesizer>
