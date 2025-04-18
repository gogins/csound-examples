;
; ""
; by Michael Bechard
;
; 
;
; Generated by blue 0.124.2 (http://csounds.com/stevenyi/blue/index.html)
;

<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr=44100
ksmps=1
nchnls=2
0dbfs=100000




gitbrat_2	ftgen	0, 0, 8, 2, 1, 0.6, 10, 100, 0.001
gitbrub_2	ftgen	0, 0, 8, 2, 1, 0.7, 50, 500, 1000



	instr 2	;PrePiano
; p3 - duration
; p4 - frequency (pch)
; p5 - strike velocity (0-100)
; p6 - strike position (-.1-?)
; p7 - decay time
;;; Begin Boilerplate ;;;
ipitch	=	p4
idur	=	abs(p3)
;;; End Boilerplate ;;;
kgain	=	6.931684
iNS	=	10
iD	=	28.193323
iK	=	3.3322678
iT30	=	-3.937931 + p7
iB	=	0.0
kbcl	=	3
kbcr	=	1
imass	=	4.79901
ihfreq	=	12000.0
iinit	=	0.49005866
ipos	=	0.0 + p6
ivel	=	0.0 + p5
isfreq	=	0.026400002
isspread =	5.0
print ipitch
aL, aR	prepiano	ipitch, iNS, iD, iK, iT30, iB, kbcl, kbcr, imass, ihfreq, iinit, ipos, ivel, isfreq, isspread, gitbrat_2, gitbrub_2
aL	=	aL * kgain
aR	=	aR * kgain
aL2	dcblock	aL
aR2	dcblock	aR
aL3	clip	aL2, 0, 30000
aR3	clip	aL3, 0, 30000
aL4	=	aL3 * .75
aR4	=	aR3 * .75
outc	aL4, aR4

	endin


</CsInstruments>

<CsScore>







i2	0.0	45	65.406395	70	0	1

e

</CsScore>

</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>30</width>
 <height>105</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>231</r>
  <g>46</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>slider1</objectName>
  <x>5</x>
  <y>5</y>
  <width>20</width>
  <height>100</height>
  <uuid>{3b38c40f-4fd8-465c-82a3-a92e3a1d6a42}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
