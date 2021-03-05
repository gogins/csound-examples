<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>

sr=44100
ksmps=128
nchnls=2

; load the 3 basic waveform 

gitable_L  ftgen 0, 0, 1024, 1, "LEFT_1024.wav", 0,0,0		; PW at full left position   (positive pulse)
gitable_R  ftgen 0, 0, 1024, 1, "RIGHT_1024.wav", 0,0,0		; PW  at center (quasi sine)
gitable_C  ftgen 0, 0, 1024, 1, "CENTER_1024.wav", 0,0,0	; PW  at full right position (negative pulse)
; create bandlimited waveform copy of the previous 
gi_nextfree_L vco2init -gitable_L, 200, 1.05, 128, 1024, gitable_L
gi_nextfree_R vco2init -gitable_R, 400, 1.05, 128, 1024, gitable_R
gi_nextfree_C vco2init -gitable_C, 600, 1.05, 128, 2^16, gitable_C

gitable_bl_L = -gitable_L ; as manual...
gitable_bl_R = -gitable_R ; as manual...
gitable_bl_C = -gitable_C ; as manual...
instr 1



kfreq_0 invalue   "_FREQ"
kpw_0	invalue "_PW"


kfreq  port kfreq_0, 0.01
kpw   port kpw_0, 0.01



; 1st oscillator for positive bandlimited pulse
kfn_L    vco2ft kfreq, gitable_bl_L
asig_L   oscilikt 5000, kfreq, kfn_L  


;2nd oscillator for quasi-sine 
kfn_C   vco2ft kfreq, gitable_bl_C
asig_C   oscilikt 5000, kfreq, kfn_C, 0.11	

;3rd oscillator for negative bandlimited pulse
kfn_R   vco2ft kfreq, gitable_bl_R
asig_R   oscilikt 5000, kfreq, kfn_R, 0.22

if kpw <= 0  then    					; if PW is from left to center position

kpw = -kpw

asig = (1-kpw)*asig_C + (kpw)*asig_L  ; interpolate between positive pulse and quasi-sine



elseif kpw > 0 then					; if PW is from center to right position

asig = (1-kpw)*asig_C + (kpw)*asig_R ;  interpolate between quasi-sine to negative pulse
endif



       outs asig, asig

endin
</CsInstruments>
<CsScore>
i1 0 3600
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1039</x>
 <y>337</y>
 <width>594</width>
 <height>507</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>117</r>
  <g>94</g>
  <b>12</b>
 </bgcolor>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>61</x>
  <y>45</y>
  <width>350</width>
  <height>150</height>
  <uuid>{19166c6b-5717-428a-ac05-d5989cd06f26}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>1.00000000</value>
  <type>scope</type>
  <zoomx>2.00000000</zoomx>
  <zoomy>4.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>_FREQ</objectName>
  <x>110</x>
  <y>229</y>
  <width>20</width>
  <height>100</height>
  <uuid>{057fd96a-d57e-49f7-a6a8-ccf3d352e44f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>20.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <value>180.17700000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>_PW</objectName>
  <x>249</x>
  <y>249</y>
  <width>80</width>
  <height>80</height>
  <uuid>{49691d20-7169-4bff-8a49-1533c5183d28}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>-1.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>-0.94000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>_PW</objectName>
  <x>249</x>
  <y>226</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4669d3fb-c675-4142-a922-c21637df3b01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>-0.940</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>249</x>
  <y>330</y>
  <width>80</width>
  <height>25</height>
  <uuid>{250cb63e-1996-4184-b008-7c05b023b35e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>SHAPE</label>
  <alignment>center</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>_FREQ</objectName>
  <x>161</x>
  <y>323</y>
  <width>80</width>
  <height>25</height>
  <uuid>{5375a2fe-81f6-4dae-8494-29a1f77f4a48}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>180.17700000</value>
  <resolution>0.00100000</resolution>
  <minimum>20.00000000</minimum>
  <maximum>2000.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act="continuous"/>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
