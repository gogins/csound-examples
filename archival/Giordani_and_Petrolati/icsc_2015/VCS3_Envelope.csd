<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>

; Initialize the global variables.
sr = 44100
ksmps = 2048
nchnls = 2


;-------------------------------------------------
	opcode EnvelopeApe, a,kkkkk	;   ENVELOPE UDO 
;-------------------------------------------------
        setksmps 1      ; need sr=kr

kattack, kon, kdecay, koff, kATTACK xin

iThreshHold init 4.9
kLamp 	init 0
kManual 	init 0
kph 		init 0
asyncin 	init 0
kfreeze 	init 1

kdurLamp = kattack + kon
koffVal = (koff > iThreshHold ? 0 : koff)
kdur = kdurLamp + kdecay + koffVal
krate = 1/kdur ; Total env time

ksyncDown 	trigger kATTACK, 0.5, 0
ksyncUp 	trigger kATTACK, 0.5, 1

if ksyncDown == 1 then
	reinit reset
endif

if ksyncUp == 1 then

	kfreeze = 1
	reinit reset
endif

reset:
aphase, asyncout syncphasor krate * kfreeze, asyncin, i(kph)
;asyncin = 0

rireturn

ksyncout = asyncout
if ksyncout == 1 then
	if koff < iThreshHold then 
	ATTACK:
		kattack_ = kattack
		kdecay_ = kdecay
		kon_ = kon
		koff_ = koffVal;(kTRIGGER == 1 ? koff : koffVal)
			
		kdurLamp_ = kattack_ + kon_
		kdur_ = kdurLamp_ + kdecay_ + koff_
	;	krate_ = 1/kdur_ ; Total env time
	else
	
		kattack_ = 0
		kdecay_ = 0
		kon_ = 0
		koff_ = 0
		kdurLamp_ = 0
		kdur_ = 0
	
	endif
	
endif

kphase = aphase
kphTime = kphase * kdur_
				
	if(kphTime < kattack_) then 			/* ATTACK */

		kLamp = 1	
;		chnset kLamp, "env_lamp"
						
		kEnv = kphTime/kattack_
;		aEnv tablei kEnv, 110, 1	; use custom curve

		/* Calculate partial Attack phase */
		kph = (kattack_ / kdur_) * kEnv

		
	elseif(kphTime < kdurLamp_) then			/* ON */
		
		kLamp = 1
;		aEnv tablei kEnv, 110, 1	; use custom curve

		/* If ATTACK occur during on period, freeze phasor */
		kfreeze = 1 - kATTACK
	
	elseif(kphTime < kdurLamp_ + kdecay_) then	/* DECAY */

		kLamp = 0
		kEnv = 1 - ( (kphTime - kdurLamp_) / kdecay_)
;		aEnv tablei kEnv, 110, 1	; use custom curve

		/* Calculate partial Attack phase */
		kph = (kattack_ / kdur_) * kEnv
		
		kfreeze = 1 - kATTACK	
		
		
;		kATTACK = (kact > 0) ? 0 : 1
;		if kATTACK != 0 then
;			kLamp = 0
;			chnset kLamp, "env_lamp"
;		endif
					
	else								/* OFF */
		kLamp = 0
		kEnv = 0
;		aEnv tablei kEnv, 110, 1	; use custom curve


/* Retriggering ATTACK even if Manual */

if ksyncDown == 1 then
	kgoto ATTACK
endif

	endif
	
;	chnset a(kLamp), "env_lamp"
	outvalue	"env_lamp", kLamp
	
	aEnv = kEnv
	
	xout aEnv
	
	endop 

;---------------------------------------------------------
instr 1 ; Envelope
;---------------------------------------------------------
  
     	ktrigger 	invalue "trigger"
    	
    	kattack 	invalue "attack"
    	kon		invalue "on"
    	kdecay	invalue "decay"
	koff 		invalue "off"  
	

/* Exponential curve mapping */
kattack expcurve kattack, 100
kattack scale kattack, 1, 0.002

kon expcurve kon, 150
kon scale kon, 2.5, 0

kdecay expcurve kdecay, 200
kdecay scale kdecay, 15, 0.003

koff expcurve koff, 200
koff scale koff, 5, 0.01
  
;printk2 ktrigger
	aEnv EnvelopeApe kattack, kon, kdecay, koff, ktrigger
	

aInput1 oscili 1, 1000, 1
    
atrapez_auto = aEnv * 20000
aenvsig_auto = aEnv * aInput1 * 20000

	 outs1 atrapez_auto	; write Signal
	 outs2 aenvsig_auto	; write Signal

endin

</CsInstruments>
<CsScore>

; Table #1, a sine wave.
f1 0 16384 10 1
f2 0 2048 7 0 512 1 512 1 512 0 512 0

f4 0 4097 7 0 4096 1                      	  ; + Ramp
f5 0 8193 7 0 2048 1 2048 1 2048 0 2048 0 0 1 ; Trapezoid

; Play Instrument #1 for five seconds.
i 1 0 5000
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>506</x>
 <y>277</y>
 <width>839</width>
 <height>613</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>22</x>
  <y>186</y>
  <width>798</width>
  <height>190</height>
  <uuid>{96bdc1a9-f9b6-4459-8ca6-427bfe7f19e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>1.00000000</value>
  <type>scope</type>
  <zoomx>20.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>21</x>
  <y>378</y>
  <width>798</width>
  <height>184</height>
  <uuid>{2741f3f0-0cd0-4256-bd07-3b4293f9cfea}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>2.00000000</value>
  <type>scope</type>
  <zoomx>20.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>attack</objectName>
  <x>30</x>
  <y>90</y>
  <width>80</width>
  <height>80</height>
  <uuid>{f47b5e4e-381a-435a-a645-06c75c428a98}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.06000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>on</objectName>
  <x>115</x>
  <y>90</y>
  <width>80</width>
  <height>80</height>
  <uuid>{26bea3c9-2436-4900-b826-1f400c7b6005}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.30000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>decay</objectName>
  <x>199</x>
  <y>90</y>
  <width>80</width>
  <height>80</height>
  <uuid>{2797f110-3d8a-4417-82b9-045a6b38e88e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>off</objectName>
  <x>281</x>
  <y>90</y>
  <width>80</width>
  <height>80</height>
  <uuid>{4ae78cec-6482-4ad5-bc96-6024b5110f63}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>trigger</objectName>
  <x>410</x>
  <y>85</y>
  <width>100</width>
  <height>30</height>
  <uuid>{878322b5-0eec-4a23-8cb1-251629af730a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <type>pictevent</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>ATTACK</text>
  <image>/</image>
  <eventLine/>
  <latch>false</latch>
  <latched>true</latched>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>lamp</objectName>
  <x>1132</x>
  <y>236</y>
  <width>20</width>
  <height>20</height>
  <uuid>{d1327093-66de-4ef1-8647-37c3048f951b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>lamp</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>1.00000000</xValue>
  <yValue>1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>25</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>lamp</objectName>
  <x>1132</x>
  <y>236</y>
  <width>20</width>
  <height>20</height>
  <uuid>{bc26ec11-9b39-423d-8fd5-37a3d5ba4bc6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>lamp</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>1.00000000</xValue>
  <yValue>1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>25</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>lamp</objectName>
  <x>1132</x>
  <y>236</y>
  <width>20</width>
  <height>20</height>
  <uuid>{bd13aefd-2a97-4a9c-a12e-b908835a7b51}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>lamp</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>1.00000000</xValue>
  <yValue>1.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>25</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>trig</objectName>
  <x>1394</x>
  <y>790</y>
  <width>28</width>
  <height>25</height>
  <uuid>{b331b57e-f225-43db-9b51-f4d1ce9bfa7e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>trig</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>point</type>
  <pointsize>13</pointsize>
  <fadeSpeed>351.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>58</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>trig</objectName>
  <x>1394</x>
  <y>790</y>
  <width>28</width>
  <height>25</height>
  <uuid>{29049cae-4cf2-47d1-bd56-840cb56ed51a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>trig</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>point</type>
  <pointsize>13</pointsize>
  <fadeSpeed>351.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>58</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>trig</objectName>
  <x>1394</x>
  <y>790</y>
  <width>28</width>
  <height>25</height>
  <uuid>{d423b77c-60b9-440e-ba91-f81c35b1804e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>trig</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>point</type>
  <pointsize>13</pointsize>
  <fadeSpeed>351.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>58</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>trig</objectName>
  <x>1394</x>
  <y>790</y>
  <width>28</width>
  <height>25</height>
  <uuid>{a5536589-8bcc-4ddb-9207-daa8f3c7212a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>trig</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>point</type>
  <pointsize>13</pointsize>
  <fadeSpeed>351.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>58</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>trig</objectName>
  <x>1394</x>
  <y>790</y>
  <width>28</width>
  <height>25</height>
  <uuid>{acc52e8e-963f-4b87-89e4-c62e6b32d8e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>trig</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>point</type>
  <pointsize>13</pointsize>
  <fadeSpeed>351.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>58</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>trig</objectName>
  <x>1394</x>
  <y>790</y>
  <width>28</width>
  <height>25</height>
  <uuid>{99e01115-e023-4396-a07c-3163cb8b1f66}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>trig</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>point</type>
  <pointsize>13</pointsize>
  <fadeSpeed>351.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>58</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>trig</objectName>
  <x>1394</x>
  <y>790</y>
  <width>28</width>
  <height>25</height>
  <uuid>{11a5d33c-c08e-40d0-9e8a-8005dcfa9652}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <objectName2>trig</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>point</type>
  <pointsize>13</pointsize>
  <fadeSpeed>351.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>58</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>display20</objectName>
  <x>347</x>
  <y>160</y>
  <width>47</width>
  <height>24</height>
  <uuid>{77404c76-2851-4017-b6fb-e76d799b85bb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>manual</label>
  <alignment>left</alignment>
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
  <x>0</x>
  <y>0</y>
  <width>709</width>
  <height>33</height>
  <uuid>{055ea6e8-338e-4a80-92eb-b3be3b0efeca}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>VCS3 Envelope Simulator 2.0</label>
  <alignment>left</alignment>
  <font>Apple Chancery</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>28</r>
   <g>213</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>display20</objectName>
  <x>45</x>
  <y>63</y>
  <width>47</width>
  <height>24</height>
  <uuid>{f625d3d7-f11e-4a6d-acbd-9b52cac38041}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Attack</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>display20</objectName>
  <x>140</x>
  <y>62</y>
  <width>47</width>
  <height>24</height>
  <uuid>{2b66daf1-e40f-4593-9922-749a6cf64675}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>On</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>display20</objectName>
  <x>216</x>
  <y>62</y>
  <width>47</width>
  <height>24</height>
  <uuid>{2a2b647e-af7e-4f66-a2c0-4e277fcaabc7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Decay</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBDisplay">
  <objectName>display20</objectName>
  <x>306</x>
  <y>62</y>
  <width>47</width>
  <height>24</height>
  <uuid>{2d8b3bd3-4ec0-45aa-be2b-5ea46c8a6e13}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Off</label>
  <alignment>left</alignment>
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
 <bsbObject version="2" type="BSBController">
  <objectName>env_lamp</objectName>
  <x>105</x>
  <y>78</y>
  <width>14</width>
  <height>15</height>
  <uuid>{7f7041c5-202b-459f-bfbb-0b98e5e87a9f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <objectName2>env_lamp</objectName2>
  <xMin>0.00000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.00000000</xValue>
  <yValue>0.00000000</yValue>
  <type>fill</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <color>
   <r>255</r>
   <g>0</g>
   <b>0</b>
  </color>
  <randomizable group="0" mode="both">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
