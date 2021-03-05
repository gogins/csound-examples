<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr       = 30000
kr       = 3000
ksmps    = 10
nchnls   = 1

instr    1 ; Barberpole flanger

ilevl    = p4*.25                            ; Output level
idpth    = p5/1000                           ; Depth in ms
irate    = p6                                ; Rate
ifeed    = p7                                ; Feedback
imode    = p8 + 1                            ; Mode: 0=Up 1=Down

ain      soundin  "Sample"

asaw1    oscili  idpth, irate, imode         ; Saw 0 degrees
asaw2    wrap  asaw1 + idpth*.25, 0, idpth   ; Saw 90 degrees
asaw3    wrap  asaw1 + idpth*.50, 0, idpth   ; Saw 180 degrees
asaw4    wrap  asaw1 + idpth*.75, 0, idpth   ; Saw 270 degrees
asin1    oscili  1, irate, 3                 ; 1/2 Sine 0 degrees
asin2    oscili  1, irate, 3, .25            ; 1/2 Sine 90 degrees
asin3    oscili  1, irate, 3, .5             ; 1/2 Sine 180 degrees
asin4    oscili  1, irate, 3, .75            ; 1/2 Sine 270 degrees
adel1    flanger  ain, asaw1, ifeed, idpth   ; Flanger 1
adel2    flanger  ain, asaw2, ifeed, idpth   ; Flanger 2
adel3    flanger  ain, asaw3, ifeed, idpth   ; Flanger 3
adel4    flanger  ain, asaw4, ifeed, idpth   ; Flanger 4
aflange  maca  adel1, asin1, adel2, asin2, adel3, asin3, adel4, asin4
aflange  dcblock  aflange                    ; Remove offset
adirect  = ain*(asin1 + asin2 + asin3 + asin4)        ; Scale input 
out      aflange*ilevl + adirect*ilevl       ; Output

endin

</CsInstruments>
<CsScore>
f01 0 4097 -7 1 4096 0 ; Ramp down
f02 0 4097 -7 0 4096 1 ; Ramp up
f03 0 4097 19 .5 1 0 0 ; Half Sine

;Mode: 1=Up 2=Down

;     Strt  Leng  Levl  Depth Rate  Fdbk  Mode
i01   0.00  1.50  0.75  5.00  0.67  0.50  1
i01   2.00  .     .     .     .     0.66  2
i01   4.00  .     .     2.50  6.70  .     1
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
