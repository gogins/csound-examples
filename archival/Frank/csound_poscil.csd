<CsoundSynthesizer>
<CsOptions>
--opcode-lib=csound_poscil.dll
</CsOptions>
<CsInstruments>

sr= 44100
kr=44100
ksmps = 1
nchnls= 1
0dbfs = 1

instr 1
;
asig  csound_poscil .5,600,1
out asig
endin



</CsInstruments>
<CsScore>

f1 0 16384 10 1
i1 0 10 


</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
