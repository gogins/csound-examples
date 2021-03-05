/*
    iVCS3.csd - by Eugenio Giordani and Alessandro Petrolati
    Copyright 2014 densitygs, all rights reserved

    www.eugenio-giordani.it
    www.alessandro-petrolati.it
    www.densitygs.com

    v. 1.0.9
    fixed VCO/FM

    20.08.2014
*/

<CsoundSynthesizer>
<CsOptions>

-o dac
--realtime
;--sample-accurate
-+rtmidi=null 
-+rtaudio=null 
-d 
-+msg_color=0 
--expression-opt
-M0 
-m0
-i adc

</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 1024

;;;;SR;;;;		//strings replaced from app with own values
;;;;KSMPS;;;;	

nchnls = 2
0dbfs = 1

/* Max Signal is 6V p-p ossia 6/2 = 3V */
#define MAX_VOLT_REF #3.0# 
#define	OUTPUT_RESCALE #1.5#

#define 	GATE_INSTR #1#
#define	MIDI_INSTR_VCS3_LEGATO #99#

/* Envelope Off  (max range is 5) */
#define 	ENVELOPE_MANUAL_THRESHOLD #4.98# 

#define	TRUE	#1#
#define	FALSE	#0#
#define 	POLY	#64#
#define	ALLPASS_MAX_DEL # 0.100 #
#define	SR_MILLI #(sr/1000.0)#
#define	MILLI # 0.001 #

/*
if ZAK is definded, Matrix connections are lazy, it means a delay was introduced every connections
if undefined Matrix is without delay but more CPU expensive

N.B. if MIXER and ZAK both undefined, matrix must be performed in Csound Callback
N.B. AudioDSP.mm must declare/undeclare ZAK according to csd
*/

#define 	MIXER ## 	;if defined, mixer evry ksmps all matrix channels
;#define	ZAK ##	;if defined MIXER | ZAK use zak system for GET_CHANNEL (fast)

;-------------------------------------------------------------------------------
;	Outputs

;00	Oscillator 1 sine
;01 	Oscillator 1 saw
;02	Oscillator 2 pulse
;03	Oscillator 2 ramp
;04 	Oscillator 3 pulse
;05 	Oscillator 3 ramp
;06 	Noise
;07 	Input ch.1
;08	Input ch.2
;09 	Filter
;10 	Trapezoid
;11 	Env signal
;12 	Ring Mod
;13 	Reverb
;14 	Joystick X
;15 	Joystick Y

#ifdef MIXER
	gaSignals[] init 16
	gkMatrix[][] init 16, 16
#end

#ifdef ZAK

	zakinit  32, 1
#end

;-------------------------------------------------------------------------------

gaFeedback	init 0
gaKeybInputCh1 init 0
gaKeybInputCh2 init 0
gkDKVcoFreq init 0
gkDKVcoAmp init 0
gkpitchbend init 0
gaSeqJoyX init 0
gaSeqJoyY init 0
gkPan init 0
gaOUTPUT_CH1 init 0
gaOUTPUT_CH2 init 0
gkIsGateEnabled init 1
;-------------------------------------------------------------------------------


;------------------------------------------------------------
;to make sure iVCS3 does not plays everything...
;------------------------------------------------------------
massign 1,0
massign 2,0
massign 3,0
massign 4,0
massign 5,0
massign 6,0
massign 7,0
massign 8,0
massign 9,0
massign 10,0
massign 11,0
massign 12,0
massign 13,0
massign 14,0
massign 15,0
massign 16,0

;maxalloc 1,16  ;maximum polyphony (0 means unlimited)
;prealloc 1,16  ;preallocate 16 voices (your expected max. polyphony)

maxalloc $GATE_INSTR, $POLY ;ENVELOPE GATE (ATTACK/DK/Seq/MIDI)
maxalloc 2,1  			;VCO KEYBOARD
maxalloc 3,1 	 		;SEQUENCER Sets Joystick Additional Parameters
maxalloc 4,1  			;JOYSTICK
maxalloc 5,1  			;INPUT
maxalloc 6,256 			;MATRIX connections just 16^2 instances

maxalloc 11,1  			;VCO 1
maxalloc 12,1  			;VCO 2
maxalloc 13,1  			;VCO 3
maxalloc 14,1  			;NOISE
maxalloc 16,1			;FILTER
maxalloc 17,1  			;ENVELOPE SHAPER
maxalloc 18,1  			;RM
maxalloc 19,1  			;REVERBERATION
maxalloc 21,1  			;VOLTOMETER

maxalloc 30,10  			;SPRING Rev Crash

maxalloc 50,1  			;OUTPUT CH1
maxalloc 51,1  			;OUTPUT CH2

maxalloc 60,1  			;FLANGER CH1nly 1 instance
maxalloc 61,1  			;FLANGER CH2 only 1 instance
maxalloc 62,1  			;COMPRESSOR CH1
maxalloc 63,1  			;COMPRESSOR CH2

maxalloc 80,1  			;Snapshots Fade
maxalloc 85,1  			;DAC/PAN

maxalloc 97,1  			;ASSIGN MIDI Channel to Keyboard
maxalloc 98,1 	 		;MIDI Panic

;------------------------------------------------------------
; load the 3 basic waveform VCO 1 Sine
;------------------------------------------------------------

givco1_sine_L  ftgen 0, 0, 1024, -1, "sine_LEFT_1024.wav", 0,0,0	; PW at full left position   (positive pulse)
givco1_sine_nextfree_L vco2init -givco1_sine_L, givco1_sine_L+1, 1.05, 128, 1024, givco1_sine_L
givco1_sine_bl_L = -givco1_sine_L ; as manual...

givco1_sine_R  ftgen 0, 0, 1024, -1, "sine_RIGHT_1024.wav", 0,0,0	; PW  at center (quasi sine)
givco1_sine_nextfree_R vco2init -givco1_sine_R, givco1_sine_R+1, 1.05, 128, 1024, givco1_sine_R
givco1_sine_bl_R = -givco1_sine_R ; as manual...

givco1_sine_C  ftgen 0, 0, 1024, -1, "sine_CENTER_1024.wav", 0,0,0	; PW  at full right position (negative pulse)
givco1_sine_nextfree_C vco2init -givco1_sine_C, givco1_sine_C+1, 1.05, 128, 1024, givco1_sine_C
givco1_sine_bl_C = -givco1_sine_C ; as manual...

;------------------------------------------------------------
; load Sawtooth waveform for VCO 1, 2 & 3 (VCO1 use saw for second oscillatorm VCO2 use derive Square and Triangoular)
;------------------------------------------------------------
givco2_saw  ftgen 0, 0, 1024, 7, 1, 1024, -1
givco2_saw_nextfree vco2init -givco2_saw, givco2_saw+1, 1.05, 128, 1024, givco2_saw
givco2_saw_bl = -givco2_saw ; as manual...

;------------------------------------------------------------
;User Defined Opcode for keyboard to cps converter
;------------------------------------------------------------

;-------------------------------------------------
	opcode GET_CHANNEL, a, i
;-------------------------------------------------

;setksmps 1

ichannel  xin

#ifdef MIXER
#ifdef ZAK
ichannel += 16
	asum	zar ichannel
	zacl ichannel, ichannel
#else
asum = 0
kndx = 0

loop:
    
	if (gkMatrix[ichannel][kndx] > 0) then
		asum += gkMatrix[ichannel][kndx] * gaSignals[kndx]
	endif

loop_lt kndx, 1, 16, loop
#end
#else

asum chani input+16

#end

;if (gkMatrix[ichannel][0] > 0) then
;asum += gkMatrix[ichannel][0] * gaSignals[0]
;endif
;if (gkMatrix[ichannel][1] > 0) then
;asum += gkMatrix[ichannel][1] * gaSignals[1]
;endif
;if (gkMatrix[ichannel][2] > 0) then
;asum += gkMatrix[ichannel][2] * gaSignals[2]
;endif
;if (gkMatrix[ichannel][3] > 0) then
;asum += gkMatrix[ichannel][3] * gaSignals[3]
;endif
;if (gkMatrix[ichannel][4] > 0) then
;asum += gkMatrix[ichannel][4] * gaSignals[4]
;endif
;if (gkMatrix[ichannel][5] > 0) then
;asum += gkMatrix[ichannel][5] * gaSignals[5]
;endif
;if (gkMatrix[ichannel][6] > 0) then
;asum += gkMatrix[ichannel][6] * gaSignals[6]
;endif
;if (gkMatrix[ichannel][7] > 0) then
;asum += gkMatrix[ichannel][7] * gaSignals[7]
;endif
;if (gkMatrix[ichannel][8] > 0) then
;asum += gkMatrix[ichannel][8] * gaSignals[8]
;endif
;if (gkMatrix[ichannel][9] > 0) then
;asum += gkMatrix[ichannel][9] * gaSignals[9]
;endif
;if (gkMatrix[ichannel][10] > 0) then
;asum += gkMatrix[ichannel][10] * gaSignals[10]
;endif
;if (gkMatrix[ichannel][11] > 0) then
;asum += gkMatrix[ichannel][11] * gaSignals[11]
;endif
;if (gkMatrix[ichannel][12] > 0) then
;asum += gkMatrix[ichannel][12] * gaSignals[12]
;endif
;if (gkMatrix[ichannel][13] > 0) then
;asum += gkMatrix[ichannel][13] * gaSignals[13]
;endif
;if (gkMatrix[ichannel][14] > 0) then
;asum += gkMatrix[ichannel][14] * gaSignals[14]
;endif
;if (gkMatrix[ichannel][15] > 0) then
;asum += gkMatrix[ichannel][15] * gaSignals[15]
;endif

;asum = 0
;asum sum gaSignals[0], 
;gaSignals[1], 
;gaSignals[2], 
;gaSignals[3], 
;gaSignals[4], 
;gaSignals[5], 
;gaSignals[6], 
;gaSignals[7], 
;gaSignals[8], 
;gaSignals[09], 
;gaSignals[10], 
;gaSignals[11], 
;gaSignals[12], 
;gaSignals[13], 
;gaSignals[14], 
;gaSignals[15]

;asum mac gkMatrix[ichannel][0], gaSignals[0],
;gkMatrix[ichannel][1], gaSignals[1],
;gkMatrix[ichannel][2], gaSignals[2],
;gkMatrix[ichannel][3], gaSignals[3],
;gkMatrix[ichannel][4], gaSignals[4],
;gkMatrix[ichannel][5], gaSignals[5],
;gkMatrix[ichannel][6], gaSignals[6],
;gkMatrix[ichannel][7], gaSignals[7],
;gkMatrix[ichannel][8], gaSignals[8],
;gkMatrix[ichannel][9], gaSignals[9],
;gkMatrix[ichannel][10], gaSignals[10],
;gkMatrix[ichannel][11], gaSignals[11],
;gkMatrix[ichannel][12], gaSignals[12],
;gkMatrix[ichannel][13], gaSignals[13],
;gkMatrix[ichannel][14], gaSignals[14], 
;gkMatrix[ichannel][15], gaSignals[15]

xout asum

	endop
	
;-------------------------------------------------
	opcode ATONE, a, aa
;-------------------------------------------------

setksmps 1

afil, acut  xin

aHP	atonex afil, k(acut), 2
xout aHP

	endop

;-------------------------------------------------
	opcode PORT, a, ak
;-------------------------------------------------
setksmps 1

asig, kglide  xin
ksig = asig
kport	portk ksig, kglide
xout a(kport)
	endop
;-------------------------------------------------
	opcode INTERPOLATE, a, aaaa
;-------------------------------------------------

setksmps 1

apw,asig_L,asig_C,asig_R  xin


if k(apw) < 0  then    		; if PW is from left to center position

	apw = -apw
	asig = (1-apw)*asig_C + (apw)*asig_L  ; interpolate between positive pulse and quasi-sine

else					; if PW is from center to right position

	asig = (1-apw)*asig_C + (apw)*asig_R ;  interpolate between quasi-sine to negative pulse

endif

/*
if k(apw) <= 0 then
	asig_PWM = asig_L
else
	asig_PWM = asig_R
endif
asig ntrpol asig_C, asig_PWM, abs(k(apw)), 0, 1
*/

xout asig

	endop

;-------------------------------------------------
	opcode POWOFTWO, a, a
;-------------------------------------------------

;setksmps 1

apw  xin
;kpw = apw
;apw = powoftwo(kpw)
;xout apw

xout octave(apw)

	endop

;-------------------------------------------------
	opcode VCO, a, iaia
;-------------------------------------------------

setksmps 1

iamp, acps, iwave, apwm xin

aWAVE vco2 iamp, k(acps), iwave, k(apwm)

xout aWAVE

	endop

;-------------------------------------------------
	opcode VCO_APE, aa, aa
;-------------------------------------------------

acps, apwm xin

	aphase phasor acps
	kfn_saw vco2ft k(acps), givco2_saw_bl
	aSAW tableikt aphase, kfn_saw, 1
	
	aphPWM wrap aphase+apwm, 0, 1
	aSAW_DEL tableikt aphPWM, kfn_saw, 1
	
xout (aSAW - aSAW_DEL), aSAW

	endop

/*
; user defined waveform -1: trapezoid wave with default parameters (can be
; accessed at ftables starting from 10000)
itmp    ftgen 100, 0, 16384, 11, 2000, 1, 0.5
ift     vco2init -itmp, 10000, 0, 0, 0, itmp

; user defined waveform
; multiplier == 1.02 (~238 tables)
;itmp    ftgen 2, 0, 16384, 11, 800, 1, 0.5
ift     vco2init -200, ift, 1.05, 256, 16384, itmp

	opcode BLIT_APE, a, kk
;-------------------------------------------------
;setksmps 1

kcps, kmul 	xin

iNyquist 	init sr/2
kfn 		vco2ft kcps, -200, 1
aout    	oscilikt 0.5, kcps, kfn
 
afund   	oscili 0.25, kcps, 1
kmul 		port kmul, 0.1
aout 		tone aout, iNyquist*kmul
aout 		tone aout, iNyquist*kmul

xout (aout * kmul) + (afund * (1-kmul))

	endop
	
*/
	
;-------------------------------------------------
	opcode BLIT_0, a, kkk
;-------------------------------------------------
;APE Optimization
;setksmps 1

kcps,knh,kmul xin

acps interp kcps
;acps tonex acps, 16
a1 gbuzz .5, acps, knh, 1, kmul, 1

xout a1

	endop

;-------------------------------------------------
	opcode MOOG_Ladder, a, akk
;-------------------------------------------------

   setksmps 1

ipi = 4*taninv(1)
az1 init 0             /* filter delays */
az2 init 0
az3 init 0
az4 init 0
az5 init 0
ay4 init 0
amf init 0

asig,kcf,kres  xin

if kres > 1 then
kres = 1
elseif kres < 0 then
kres = 0
endif

i2v = 40000   /* twice the \'thermal voltage of a transistor\' */
 
kfc = kcf/sr  /* sr is half the actual filter sampling rate  */
kf =  kcf/(sr*2)
/* frequency & amplitude correction  */ 
kfcr = 1.8730*(kfc^3) + 0.4955*(kfc^2) - 0.6490*kfc + 0.9988
kacr = -3.9364*(kfc^2) + 1.8409*kfc + 0.9968;
k2vg = i2v*(1-exp(-2*ipi*kfcr*kf)) /* filter tuning  */

/* cascade of 4 1st order sections         */
ay1 = az1 + k2vg*(tanh((asig - 4*kres*amf*kacr)/i2v) - tanh(az1/i2v))
az1 = ay1
ay2 = az2 + k2vg*(tanh(ay1/i2v) - tanh(az2/i2v ))
az2 = ay2
ay3 = az3 + k2vg*(tanh(ay2/i2v) - tanh(az3/i2v))
az3 = ay3
ay4 = az4 + k2vg*(tanh(ay3/i2v) - tanh(az4/i2v))
az4 = ay4
/* 1/2-sample delay for phase compensation  */
amf = (ay4+az5)*0.5
az5 = ay4

/* oversampling  */
ay1 = az1 + k2vg*(tanh((asig - 4*kres*amf*kacr)/i2v) - tanh(az1/i2v))
az1 = ay1
ay2 = az2 + k2vg*(tanh(ay1/i2v) - tanh(az2/i2v ))
az2 = ay2
ay3 = az3 + k2vg*(tanh(ay2/i2v) - tanh(az3/i2v))
az3 = ay3
ay4 = az4 + k2vg*(tanh(ay3/i2v) - tanh(az4/i2v))
az4 = ay4
amf = (ay4+az5)*0.5
az5 = ay4
        
        xout  amf
	
	endop
	
;-------------------------------------------------
	opcode EnvelopeApe, a,kkkkk	;   ENVELOPE UDO 
;-------------------------------------------------
iksmps init 1 ;(ksmps < 512 ? 2 : 1)

        setksmps iksmps      ; need sr=kr

kattack, kon, kdecay, koff, kATTACK xin

kLamp 		init 0
kManual 	init 0
kph 		init 0
asyncin 	init 0
kfreeze 	init 1

kdurLamp = kattack + kon
koffVal = (koff > $ENVELOPE_MANUAL_THRESHOLD ? 0 : koff)
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
	if koff < $ENVELOPE_MANUAL_THRESHOLD then 
	ATTACK:
		kattack_ = kattack
		kdecay_ = kdecay
		kon_ = kon
		koff_ = koffVal ;koff
			
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

		/* If ATTACK occur during on period, freeze phasor */

		if ksyncDown == 1 then
			kgoto ATTACK
		endif

	endif
	
	chnset kLamp, "env_lamp"
	aEnv = kEnv
	
	xout aEnv
	
	endop 
	
;-------------------------------------------------
;	opcode EnvelopeApe, a,kkkk
;-------------------------------------------------
;        setksmps 1      ; need sr=kr
;
;kattack, kon, kdecay, koff xin
;
;asyncin 	init 1
;kATTACK 	init 1
;
;kact 		active 1
;;ktrig 	changed kact
;/* Trigger on ATTACK one once */
;;if (kact > 0) /*&& (ktrig == 1)*/ then
;;;	asyncin = 1	
;;;	kATTACK = 0
;;endif
;
;/* Trigger Off ATTACK one once */
;if (kact < 1) /*&& (ktrig == 1)*/ then
;;	asyncin = 1
;	kATTACK = 1
;endif
;
;kdurLamp = kattack + kon
;
;kdur = kdurLamp + kdecay + (koff > $ENVELOPE_MANUAL_THRESHOLD ? 0 : koff)
;krate = 1/kdur ; Total env time
;
;aphase, asyncout syncphasor krate * kATTACK, asyncin
;
;asyncin = 0
;
;ksyncout downsamp asyncout
;if ksyncout == 1 then
;
;	if (koff < $ENVELOPE_MANUAL_THRESHOLD) /* || (kact > 0)*/ then 
;
;		kattack_ = kattack
;		kdecay_ = kdecay
;		kon_ = kon
;		koff_ = koff
;			
;		kdurLamp_ = kattack_ + kon_
;		kdur_ = kdurLamp_ + kdecay_ + koff_
;	;	krate_ = 1/kdur_ ; Total env time
;		
;	else
;
;		kattack_ = 0
;		kdecay_ = 0
;		kon_ = 0
;		koff_ = 0 ;p3
;		kdurLamp_ = 0
;		kdur_ = 0
;	
;	endif
;
;;	if (kact > 0) then 
;;		kATTACK = 0
;;	endif
;			
;endif
;
;kphase downsamp aphase
;kphTime = kphase * kdur_
;	
;	if(kphTime < kattack_) then 			/* ATTACK */
;
;;		kATTACK = (kact > 0) ? 0 : 1
;		kLamp = 1	
;		chnset kLamp, "env_lamp"
;					
;		kEnv = kphTime/kattack_
;		;aSign table kEnv, 13, 1	; use custom curve
;		
;	elseif(kphTime < kdurLamp_) then			/* ON */
;		
;		/* Freeze/unfreeze phasor when ATTACK is down */
;;		kATTACK = (kact > 0) ? 0 : 1
;		kEnv = 1
;		;aSign = 1;table kEnv, 13, 1	; use custom curve
;	
;	elseif(kphTime < kdurLamp_ + kdecay_) then	/* DECAY */
;
;		kATTACK = (kact > 0) ? 0 : 1
;		if kATTACK != 0 then
;			kLamp = 0
;			chnset kLamp, "env_lamp"
;		endif
;			
;		kNdx = ( (kphTime - kdurLamp_) / kdecay_)
;		kEnv = 1 - kNdx
;		;aSign table kNdx, 14, 1	; use custom curve
;					
;	else								/* OFF */
;;		kATTACK = (kact > 0) ? 0 : 1
;		kEnv = 0
;		;aSign = 0;table kEnv, 14, 1	; use custom curve
;
;	endif
;	
;	aEnv = kEnv
;	
;	xout aEnv;, aSign
;	
;	endop 
	
	
;-------------------------------------------------
	opcode EnvelopeLoopseg, a,kkkk
;-------------------------------------------------
        setksmps 1      ; need sr=kr

kattack, kon, kdecay, koff xin
	   
ktrig init 0
iphase init 0
iThreshHold init 4.9

kdurLamp = kattack + kon
kdur = kdurLamp + kdecay + (koff > iThreshHold ? 0 : koff)
krate   = 1/kdur ; Total env time  	

asyncin init 0
aphase, asyncout syncphasor krate, asyncin

ksyncout downsamp asyncout
if ksyncout == 1 then

	if koff < iThreshHold then 
	
		
		kattack_ = kattack
		kdecay_ = kdecay
		kon_ = kon
		koff_ = koff
			
		kdurLamp_ = kattack_ + kon_
		kdur_ = kdurLamp_ + kdecay_ + koff_
	;	krate_ = 1/kdur_ ; Total env time
		
	else
	
		kattack_ = 0
		kdecay_ = 0
		kon_ = 0
		koff_ = p3
		kdurLamp_ = 0
		kdur_ = 0
	
	endif
	
endif

kphase downsamp aphase

kdr_man loopsegp kphase, ktrig, iphase, 0, kattack_, 1, kon_, 1, kdecay_, 0, koff_
kLamp = (kphase*kdur < kdurLamp) ? 1 : 0

	chnset kLamp, "env_lamp"
   
aEnv = kdr_man

; if local ksmps != 1
;aEnv interp kdr_man   

xout aEnv

	endop 
	
;-------------------------------------------------
	opcode Envelope, a,kkkk
;-------------------------------------------------
        setksmps 1      ; need sr=kr

kattack, kon, kdecay, koff xin
	   
kdurLamp = kattack + kon
kdur = kdurLamp + kdecay + koff
ktrig init 0
iphase init 0
krate   = 1/kdur ; Total env time  	
kphase phasor krate
kdr_man loopsegp kphase, ktrig, iphase, 0, kattack, 1, kon, 1, kdecay, 0, koff
   
kLamp = (kphase*kdur < kdurLamp) ? 1 : 0
chnset kLamp, "env_lamp"
   
aEnv = kdr_man
; if local ksmps != 1
;aEnv interp kdr_man   
xout aEnv

	endop 
	
;-------------------------------------------------
	opcode EnvelopeMan, a,kkk
;-------------------------------------------------
        setksmps 1      ; need sr=kr

ktrigger, kattack, kdecay xin

	kenv portk ktrigger, (ktrigger == 1 ? kattack : kdecay)

xout kenv

	endop 
;-------------------------------------------------
	opcode ALLPASS_K, a,akk
;-------------------------------------------------
        setksmps 1      ; need sr=kr
ain, k1,k2 xin          ; read input parameters : ain=input sig, k1=gain, k2= delay time (ms)
aout    init 0          ; initialize output
;-------------------------------------------------

kgainAP1 = k1			;receive allpass gain (0:1)
kdelaysampAP1 = k2		;receive allpass delay (samples)
  
adummy_AP1 	delayr $ALLPASS_MAX_DEL	;set maximum delay line length
a1 		deltapn  kdelaysampAP1		;tap delay line
aout = a1 + (-kgainAP1 * ain)	
			
	delayw ain + (kgainAP1 * aout  )
	   
	xout aout               ; write ALLPASS output

	endop 
        
;-------------------------------------------------	
	opcode cpsmid, k, k
;-------------------------------------------------
kmid	xin

;#define MIDI2CPS(xmidi) # (440.0*exp(log(2.0)*(($xmidi)-69.0)/12.0)) #
#define MIDI2CPS(xmidi) # (powoftwo(($xmidi-69)/12) * 440) #
kcps	=	$MIDI2CPS(kmid)

	xout	kcps

	endop

; compress function table UDO

;-------------------------------------------------
	opcode	tab_treatment,i,iiii
;-------------------------------------------------
ifn, iCompRat, iCurve, iDir    xin
	
	iTabLen         	=	nsamp(ifn)
	iTabLenComp     	=	int(nsamp(ifn)*iCompRat)
	iTableComp     	ftgen	ifn+200,0,-iTabLenComp,-2, 0
	iAmpScaleTab	ftgen	ifn+300,0,-iTabLenComp,-16, 1,iTabLenComp,iCurve,0
	icount          	= 	0
	loop:
		
		ival		table		icount, ifn
		iAmpScale	table		icount, iAmpScaleTab
	    	
	    		if iDir == 1 then
    		          	tableiw	ival*iAmpScale,iTabLenComp-icount-1,iTableComp
    			else
    	      		tableiw	ival*iAmpScale,icount,iTableComp	
    			endif
	      
	                	loop_lt	icount,1,iTabLenComp,loop
	xout iTableComp
	endop

;-------------------------------------------------
	opcode	tab_reverse,i,i
;-------------------------------------------------
ifn             xin
	
	iTabLen	=		nsamp(ifn)
	iTableRev	ftgen		ifn+400,0,-iTabLen,-2, 0
	icount	=		0
	loop:
	ival		table		iTabLen-icount-1, ifn
			tableiw	ival,icount,iTableRev
			loop_lt	icount,1,iTabLen,loop
	
	xout	iTableRev
	endop

;------------------------------------------------------------


;turnon all instruments

turnon 4, -1
turnon 5, -1

turnon 11, -1
turnon 12, -1
turnon 13, -1
turnon 14, -1
turnon 16, -1
turnon 17, -1
turnon 18, -1
turnon 19, -1
turnon 21, -1

turnon 50, -1
turnon 51, -1

;------------------------------------------------------------

;---------------------------------------------------------
instr $GATE_INSTR ; ENVELOPE GATE (UI DK/Seq or MIDI)
;---------------------------------------------------------

/* Calculate frequency from Voltage Control Keyboard DK or MIDI */

	;p4 = Keyboard Pressed Key Number
	;p5 = Dynamic
	;p6 == 0 MIDI
	;p6 == 1 DK
	;p6 == 2 KS
			
	/* Perform GATE according to iVCS3 UI mode */
	isGATE chnget "seq_gate"
	
	if (p6 == 0) || (p6 == 1) then
		
		if (isGATE == 0) || (isGATE == 1) then
			gkIsGateEnabled = 1
		endif
			
	else

		if (isGATE == 0) || (isGATE == 2) then
			gkIsGateEnabled = 1
		endif
	
	endif
		
	
if (p6 == 1) || (p6 == 2) then ;from UI DK/KS (i.e. p6 flag == 1)

	/* Get Keyboard Key Number from UI DK */
	iKeyNum 	init p4
	
	/* Rescale Key Number in Voltage, 1 Volt per Octave (0 - 3) */
	iKeyVolt 	init iKeyNum / 12
	
	/* Get UI DK Dynamic Voltage Normalized */
	iKeyDyn 	init p5

	/* Clear UI/MIDI flag for next instance */
	p6 = 0 

else ;from MIDI (i.e. p6 flag == 0)

	/* get Pitch Bend from MIDI Keyboard */
			midipitchbend gkpitchbend
	
	/* Get Keyboard Note Number from MIDI */
	iKeyNum 	notnum
	iKeyNum	init iKeyNum - 60
	
	/* Rescale Note Number in Voltage, 1 Volt per Octave (0 - 3) */
	iKeyVolt 	init iKeyNum / 12
	
	/* Get MIDI Keyboard Dynamic Normalized (inpus is inverted) */
	iKeyDyn	ampmidi 1
	
endif


	;-----------------------------------------------------------
	; Route Signal in according to DK Switchs
	;-----------------------------------------------------------
	
	iToggleCh1 		chnget "keyb_ch1_signal_voltage" 
	iToggleCh2		chnget "keyb_ch2_dynamic_voltage" 	
				
	;----------------------------------------------------------------------------------							
	;ToggleCh1 == 1 (down) KEYBOARD VOLTAGE, else (up) SIGNAL (Use the Internal DK VCO)
	;----------------------------------------------------------------------------------	
		
	if iToggleCh1 == 1 then ;KEYBOARD VOLTAGE

		/* Rescale Keyboard Voltage in the Range -+1.5V 1V per octave Middle F# give 0V */	
		iFreq_VC_CH1 init (iKeyVolt - 1.5) / $MAX_VOLT_REF
	
		/* Keyboard Voltage -+1.5V 1V per octave Middle A give 0V */
		gaKeybInputCh1 = iFreq_VC_CH1 + (gkpitchbend/$MAX_VOLT_REF)

	else ;KEYBOARD SIGNAL
	
		/* Rescale Keyboard Voltage in the Range -+1.5V 1V per octave Middle F# give 0V */	
		iFreq_DK_VCO init (iKeyVolt - 1.5)
	
		/* Keyboard Voltage -+1.5V 1V per octave Middle F# give 0V */
		gkDKVcoFreq = iFreq_DK_VCO + gkpitchbend

		/* Dynamic for Internal Keyboard VCO */
		gkDKVcoAmp init iKeyDyn
	
	endif


	;------------------------------------------------------------------	
	;ToggleCh2 == 1 (down) KEYBOARD VOLTAGE, else (up) DYNAMIC VOLTAGE
	;------------------------------------------------------------------
	if iToggleCh2 == 1 then ;KEYBOARD VOLTAGE
	
		/* Rescale Keyboard Voltage in the Range -+1.5V 1V per octave Middle F# give 0V */	
		iFreq_VC_CH2 init (iKeyVolt - 1.5) / $MAX_VOLT_REF

		gaKeybInputCh2 = iFreq_VC_CH2 + (gkpitchbend/$MAX_VOLT_REF)

	else ; DYNAMIC VOLTAGE


		/* rescale Dynamic Voltage -+1.5V mezzoforte ~0V */	
		iDynamicVCNormValue_CH2 init (((iKeyDyn * 3.0) - 1.5) / $MAX_VOLT_REF)

		gaKeybInputCh2 init iDynamicVCNormValue_CH2
	
	endif


	/* GATE from ATTACK/MIDI instr $GATE_INSTR or from chnget */
	;	kflag release
	;	chnset 1-kflag, "GATE"

endin

;------------------------------------------------------------
instr 2 ; VCO KEYBOARD
;------------------------------------------------------------

klev			chnget "keyb_level"
kFrequency		chnget "keyb_frequency" 
kFreqSpread		chnget "keyb_tuning_spread" 		
kDynamicRescale 	chnget "keyb_dynamic_range" 
			
;-----------------------------------------------------------
; Convert Voltage To Hz
;-----------------------------------------------------------	
				
/* Tuning Spread from UI Keyboard 0-1V (i.e. 0.32 * 3 = 0.96) */
;iVoltPerOctave init 0.32	
;kcps = kFrequency * powoftwo((gkDKVcoFreq * kFreqSpread) / iVoltPerOctave)

/*Expressed in +- semitones (original range 1 tone) */
kcps = kFrequency * semitone(gkDKVcoFreq * (12 + kFreqSpread))

iNyquist init sr / 2.0
imaximum_VCO_freq init 16750.0
iMaxLimit init imaximum_VCO_freq > iNyquist ? iNyquist : imaximum_VCO_freq
kfreq_keyb 	limit kcps, 0.6, iMaxLimit
				
/* Signal Output 10V p-p ??? */ ; TODO
kDyn = (gkDKVcoAmp - 0.5) * kDynamicRescale ;from -0.5 to 0.5
kAmp = 0.5 + kDyn

aDK_VCO vco2 kAmp, kfreq_keyb

alev interp klev

/* Meter signal Mixing with DK-VCO */
gaKeybInputCh1 = (aDK_VCO * alev) + gaFeedback

endin

;------------------------------------------------------------
instr 3 ; SEQUENCER Joystick and Pan Additional Parameters
;------------------------------------------------------------

;p4 = Keyboard Voltage
;p5 = Keyboard Dynamic 
;p6 = Panning Ch1
;p7 = Update/Reset

if p7 == 1 then

	/* SEQUENCER Vertical/Horizontal STICK */
	
	krange_h	chnget "joy_range_h"	; rescale for 0.33 i.e. 2V / $MAX_VOLT_REF
	krange_v	chnget "joy_range_v" 	; rescale for 0.33 i.e. 2V / $MAX_VOLT_REF


	/* Keyboard Voltage in the Range -+1.5V 1V per octave Middle F# give 0V */	
	iKeyVolt init p4/12
	iFreq_VC_STICK init (iKeyVolt - 1.5) / $MAX_VOLT_REF

	gaSeqJoyY = -iFreq_VC_STICK * krange_v ;(-p4 / $MAX_VOLT_REF) * krange_v


	/* Dynamic Voltage -+1.5V mezzoforte ~0V */	
	iKeyDyn init p5
	iDynamicVCNormValue_STICK init (((iKeyDyn * 3.0) - 1.5) / $MAX_VOLT_REF)

	gaSeqJoyX = -iDynamicVCNormValue_STICK * krange_h ;(-p5 / $MAX_VOLT_REF) * krange_h	

	/* Panning */
	gkPan = p6
else

	/* STICK and Pan resets value when Sequencer is Stopped*/	
	gaSeqJoyX = 0
	gaSeqJoyY = 0
	gkPan = 0

	/* DK resets value when Sequencer is Stopped*/	
	gaKeybInputCh1 = 0
	gaKeybInputCh2 = 0

endif

	turnoff
endin

;---------------------------------------------------------
instr 4 ; Joystick
;---------------------------------------------------------

/* About the joystick range, is really +-1.5... The old VCS manual don´t have in account that the potentiometers 
attached to the joystick can´t do a full turn, just a fraction of the travel. 
They put the specs for the pots but later they corrected it... ;) */

kjoy_h	chnget "joy_h"		; from -1 to +1
kjoy_v	chnget "joy_v"		; from -1 to +1
krange_h	chnget "joy_range_h"	; rescale for 1.5 i.e. Range in Volts
krange_v	chnget "joy_range_v" 	; rescale for 1.5 i.e. Range in Volts

;TODO Joystick GLIDE in the settings
kjoy_h 	port kjoy_h, 0.08
kjoy_v 	port kjoy_v, 0.08


/* Joystick range is 3V i.e. +- 1.5 */
;iJoyRescale init 3 / $MAX_VOLT_REF ;i.e. 3/3 = 1

kJoy_h_ = (kjoy_h * krange_h) / $MAX_VOLT_REF
kJoy_v_ = (kjoy_v * krange_v) / $MAX_VOLT_REF 
aJoy_hori interp kJoy_h_
aJoy_vert interp kJoy_v_

/* From SEQUENCER Vertical/Horizontal STICK */
aJoy_hori += gaSeqJoyX 
aJoy_vert += gaSeqJoyY


#ifdef MIXER
#ifdef ZAK
	zaw aJoy_hori, 14
	zaw aJoy_vert, 15
#else

	gaSignals[14] = aJoy_hori	; write Signal
	gaSignals[15] = aJoy_vert	; write Signal
#end
#else	
	chano aJoy_hori, 14
  	chano aJoy_vert, 15		
#end	
endin

;---------------------------------------------------------
instr 5 ; Input
;---------------------------------------------------------

/* Get Signal mixed Mic/Sampler from ADC */
aMicSamplerCh1, aMicSamplerCh2 	ins	/* 1.8V (rms) AC or +-2.5V DC */ ; TODO RESCALE

/* Get Signal from VC/VCO from Keyboard (see GATE Envelope DK/ATTACK/MIDI and VCO Keyboard Instruments)*/
aDKSeqInputCh1 = gaKeybInputCh1
aDKSeqInputCh2 = gaKeybInputCh2

/* RESCALE Incoming Signals*/
klevin1	chnget "ext_input_1_level"
klevin2	chnget "ext_input_2_level"
alevin1 	interp klevin1
alevin2 	interp klevin2

kfeedback1 	chnget "feedback_ch1_input"
kfeedback2 	chnget "feedback_ch2_input"
;kfeedback1	expcurve kfeedback1, 10 ;Performed by VCS3_Knob_CURVE
;kfeedback2	expcurve kfeedback2, 10
afdbk1 	interp kfeedback1
afdbk2 	interp kfeedback2

/* Get Signal from SCOPE Jack-socket*/
afeedbackCh1 = gaFeedback * afdbk1
afeedbackCh2 = gaFeedback * afdbk2

kSelectorCh1 	chnget "ext_input_selector_ch1"
kSelectorCh2 	chnget "ext_input_selector_ch2"

if kSelectorCh1 == 0 then 		;DK/Seq
	aMicSamplerCh1 = 0

elseif kSelectorCh1 == 1 then 	;Mute
	aDKSeqInputCh1 = 0
	aMicSamplerCh1 = 0
else						;Mic/Sampler
	aDKSeqInputCh1 = 0

endif

if kSelectorCh2 == 0 then 		;DK/Seq
	aMicSamplerCh2 = 0

elseif kSelectorCh2 == 1 then 	;Mute
	aDKSeqInputCh2 = 0
	aMicSamplerCh2 = 0
else						;Mic/Sampler
	aDKSeqInputCh2 = 0

endif


aSubMixCh1 = (aMicSamplerCh1 + aDKSeqInputCh1 + afeedbackCh1) * alevin1
aSubMixCh2 = (aMicSamplerCh2 + aDKSeqInputCh2 + afeedbackCh2) * alevin2


#ifdef MIXER
#ifdef ZAK
	zaw -aSubMixCh1, 7
	zaw -aSubMixCh2, 8
#else	
	/* Input Signal is Inverted! */
	gaSignals[7] = -aSubMixCh1	; write Signal
	gaSignals[8] = -aSubMixCh2	; write Signal
#end
#else
	chano -aSubMixCh1, 7
	chano -aSubMixCh2, 8
#end
endin

;------------------------------------------------------------
instr 6 ; MATRIX PATCHBOARD
;------------------------------------------------------------

; X = p5 (Input zak 16 - 31)
; Y = p4 (Output zak 0 - 15)
; p6 == 0 pinWhite
; p6 == 1 pinGreen
; p6 == 2 pinRed

; //OLD ain	 zar  p4

;if (p4 == 14) || (p4 == 15) then
;	
;	if (p5 == 4) || (p5 == 5) then
;	
;	/* 
;	NOTE: The control simulated the effect of "bowing" the RM via DC signal (Joystick).  
;	Move slow or fast the slider to hear the effect... 
;	*/
;	
;	kDCINPUT	downsamp ain
;	kDCINPUT port kDCINPUT, 0.05
;	kDCINPUT atonek kDCINPUT, 16
;	kjoy port kDCINPUT * 10, 0.02
;	ain interp kjoy
;	
;	endif
;endif
	
	/* Pins color attenuation */
	
	if p6 == 0 then ;white pins no attenuation
		iAtten init 1
	elseif p6 == 1 then ;green pins attenuate
		iAtten init 0.66
;	elseif p6 == 2 then ;red pins not implemented yet!
;		iAtten init 0.25
	endif
	
;	iAtten init (p6 == 1 ? 0.5 : 1.0) 

; //OLD 	zawm ain * iAtten, p5 + 16, 1

#ifdef MIXER
#ifdef ZAK
	ain	 zar  p4
	zawm ain * iAtten, p5 + 16, 1
#else

	gkMatrix[p5][p4] = (p7 == 1 ? iAtten : 0)
;	turnoff
#end	
#else

;ain	 chani  p4
;aout chani p5
;chano ain+aout, p5+16

#end
endin

;------------------------------------------------------------
instr 11 ; VCO 1
;------------------------------------------------------------

kcps	chnget "vco_1_freq"
kshape	chnget "vco_1_shape"
klsine 	chnget "vco_1_level_sine"
klramp 	chnget "vco_1_level_saw"

alsine 	interp klsine
alramp 	interp klramp

input init 8 ;Oscillator VCO1 Frequency
aControlIn = GET_CHANNEL(input)

;FM issue
;kControlIn downsamp aControlIn

iVoltPerOctave init -0.32 / $MAX_VOLT_REF

;FM issue
;kcps = kcps * powoftwo(kControlIn/iVoltPerOctave)
apower POWOFTWO aControlIn/iVoltPerOctave ;i.e. 2ˆ(aControlIn/iVoltPerOctave)
acps mac kcps, apower

iNyquist init sr / 2.0
imaximum_VCO_freq init 16750.0
iMaxLimit init imaximum_VCO_freq > iNyquist ? iNyquist : imaximum_VCO_freq
;FM issue
acps limit acps, 0.6, iMaxLimit

	/* Max. Out. 3V p-p  ossia 3/2 = 1.5V peak i.e. */
	iampSine init 1.5 / $MAX_VOLT_REF
	
	/* Max. Out. 4V p-p  ossia 4/2 = 2V peak i.e. */
	iampSaw init -2 / $MAX_VOLT_REF
	
;	/* Simulate extreme range of PWM attenuation or enphasis */
;	aShapeAttenuation interp (kshape < 0.5) ? (0.5 + kshape) : (0.5 + (1 - kshape))
	
; start VCO1	

;	kcps  	port kcps, 0.0095	;smooth freq
;	kshape 	port kshape, 0.01 	;smooth PWM

	/* Giordani's VCO SINE */
	kshape 	scale kshape, 1, -1
	;kshape port kshape, 0.01 	;smooth PWM
	;apw 	interp kshape

	; 1st oscillator for positive bandlimited pulse
	kfn_L    	vco2ft k(acps), givco1_sine_bl_L
	asig_L   	oscilikt iampSine, acps, kfn_L  
	
	;2nd oscillator for quasi-sine 
	kfn_C   	vco2ft k(acps), givco1_sine_bl_C
	asig_C   	oscilikt iampSine, acps, kfn_C, 0.11	
	
	;3rd oscillator for negative bandlimited pulse
	kfn_R   	vco2ft k(acps), givco1_sine_bl_R
	asig_R   	oscilikt iampSine, acps, kfn_R, 0.22
	
	;asine		INTERPOLATE apw, asig_L, asig_C, asig_R

	/* APE's fast Interpolation */	
	kL limit kshape, -1, 0
	kL = abs(kL)
	kR limit kshape, 0, 1
	kC = 1 - (kL+kR)
	aC interp kC
	aL interp kL
	aR interp kR
	asine maca asig_C, aC, asig_L, aL, asig_R, aR


	/*  Sine mode 1 */
;	itri 	init 4
;	atri	vco2 0.5, kcps, itri, kshape	
;	asine 	tone atri, 180
;	asine 	balance asine, atri

	
	/*  Sine mode 2 */	
	/*
	kshape 	scale kshape, 0.95, 0.05	
	avco	vco2 0.5, kcps, 2, kshape	; Use a square sawtooth waveform.
	aout1	tonex avco, kcps, 1  		; transform square to sine
	asine   dcblock aout1			; reduce or remove AC component					
;  	asine 	balance  asine, avco*0.5	; then balanced with source
	*/

; FM issue		
	/* OLD Ramp */
;	asaw	vco2 iampSaw, k(acps)

	/* NEW APE VCO SAW */
	kfn   	vco2ft k(acps), givco2_saw_bl
	asaw   	oscilikt iampSaw, acps, kfn
	
	a11_vc_out = asine * alsine	;* aShapeAttenuation	
	a12_vc_out = asaw * alramp 

#ifdef MIXER
#ifdef ZAK
	zaw a11_vc_out, 0
	zaw a12_vc_out, 1
#else
	gaSignals[0] = a11_vc_out	; write Signal in zak 0 (VCO_1 output 1)
	gaSignals[1] = a12_vc_out	; write Signal in zak 1 (VCO_1 output 2)
#end
#else
	chano a11_vc_out, 0
	chano a12_vc_out, 1
#end
endin

;------------------------------------------------------------
instr 12 ; VCO 2
;------------------------------------------------------------
kcps 	chnget "vco_2_freq"
kshape	chnget "vco_2_shape"
klsquare chnget "vco_2_level_square"
klramp 	chnget "vco_2_level_triangle"

alsquare interp klsquare
alramp 	interp klramp

input init 9 ;Oscillator VCO2 Frequency
aControlIn = GET_CHANNEL(input)
;FM issue
;kControlIn downsamp aControlIn

iVoltPerOctave init -0.32 / $MAX_VOLT_REF

;FM issue
;kcps = kcps * powoftwo(kControlIn/iVoltPerOctave)
apower POWOFTWO aControlIn/iVoltPerOctave ;i.e. 2ˆ(aControlIn/iVoltPerOctave)
acps mac kcps, apower

iNyquist init sr / 2.0
iminimum_VCO_freq init 0.6
imaximum_VCO_freq init 16750.0
iMaxLimit init imaximum_VCO_freq > iNyquist ? iNyquist : imaximum_VCO_freq
;FM issue
acps limit acps, 0.6, iMaxLimit

	/* Max. Out. 4V p-p  ossia 4/2 = 2V peak i.e. */
	iampSquare init 2 / $MAX_VOLT_REF
	
	/* Max. Out. 6V p-p  ossia 6/2 = 3V peak i.e. */
	iampTri init 3 / $MAX_VOLT_REF

	/* Simulate extreme range of PWM attenuation or enphasis */
	kShapeAtt_ = (kshape < 0.5) ? (1 - kshape) : kshape
	aShapeAttenuation interp kShapeAtt_


;	kcps  	port kcps, 0.022	;smooth freq
;	kshape 	port kshape, 0.01 	;smooth PWM
	
; 	OLD VCO2
;	FM issue
	kshape 	scale kshape, 0.99, 0.01
;	isquare	init 2
	iramp 	init 4
;	asquare	vco2 iampSquare, k(acps), isquare, kshape /* 4V p-p i.e. 4/6 */
;	aramp	vco2 iampTri, k(acps), iramp, kshape	/* 6V p-p i.e. 6/6 a bit less */
;	asquare	VCO iampSquare, acps, isquare, a(kshape) /* 4V p-p i.e. 4/6 */
	aramp	VCO iampTri, acps, iramp, a(kshape)	/* 6V p-p i.e. 6/6 a bit less */

	ashape interp kshape
	aphase phasor acps
	kfn_saw vco2ft k(acps), givco2_saw_bl
	aSAW tableikt aphase, kfn_saw, 1	
	aphPWM wrap aphase-ashape, 0, 1
	aSAW_DEL tableikt aphPWM, kfn_saw, 1
	asquare = aSAW - aSAW_DEL

;	aTRI_0 	integ asquare
;	aTRI_AC atonex aTRI_0, 1.6, 2	
	; Balance TRIANGLE wave amplitude in respect of RAMP wave
;	aramp	balance aTRI_AC,  aphase

	/* Rescale and copy out */
	a21_vc_out = asquare * alsquare * iampSquare
	a22_vc_out = aramp * alramp * aShapeAttenuation ;* iampTri ;uncomment when not use VCO UDO

#ifdef MIXER
#ifdef ZAK
	zaw a21_vc_out, 2
	zaw a22_vc_out, 3
#else
	gaSignals[2] = a21_vc_out	; write Signal in zak 2 (VCO_2 output 1)
	gaSignals[3] = a22_vc_out	; write Signal in zak 3 (VCO_2 output 2)
#end
#else
	chano a21_vc_out, 2
	chano a22_vc_out, 3
#end
endin

;------------------------------------------------------------
instr 13 ; VCO 3
;------------------------------------------------------------

kcps	chnget "vco_3_freq"
kshape	chnget "vco_3_shape"
klsquare chnget "vco_3_level_square"
klramp 	chnget "vco_3_level_triangle"

alsquare interp klsquare
alramp 	interp klramp

input init 10 ;Oscillator VCO3 Frequency
aControlIn = GET_CHANNEL(input)
;FM issue
;kControlIn downsamp aControlIn

iVoltPerOctave init -0.26 / $MAX_VOLT_REF

;FM issue
;kcps = kcps * powoftwo(kControlIn/iVoltPerOctave)

apower POWOFTWO aControlIn/iVoltPerOctave ;i.e. 2ˆ(aControlIn/iVoltPerOctave)
acps mac kcps, apower

iminimum_VCO_freq init 0.015
imaximum_VCO_freq init 500

acps limit acps, iminimum_VCO_freq, imaximum_VCO_freq

	/* Max. Out. 4V p-p  ossia 4/2 = 2V peak i.e. */
	iampSquare init 2 / $MAX_VOLT_REF
	
	/* Max. Out. 6V p-p  ossia 6/2 = 3V peak i.e. */
	iampTri init 3 / $MAX_VOLT_REF

;	kcps  	port kcps, 0.022	;smooth freq
;	kshape 	port kshape, 0.01 	;smooth PWM

; 	OLD VCO2
;	FM issue
	kshape_square 	scale kshape, 0.99, 0.01
;	isquare init 2
;	iramp 	init 4
;	asquare	vco2 iampSquare, k(acps), isquare, kshape /* 4V p-p i.e. 4/6 */
;	aramp	vco2 iampTri, k(acps), iramp, kshape	/* 6V p-p i.e. 6/6 a bit less */
;	asquare	VCO a(iampSquare), acps, isquare, a(kshape) /* 4V p-p i.e. 4/6 */
;	aramp	VCO a(iampTri), acps, iramp, a(kshape)	/* 6V p-p i.e. 6/6 a bit less */	

	/* Alternative UDO for vco2 (very CPU expensive) */
;	asquare, aramp VCO_APE acps, a(kshape)

	/* NEW APE Square/Ramp with PWM, LFO VCO */
	ashape_square interp kshape_square
	;Generate positive ramp
	aphase phasor acps
	kfn_saw vco2ft k(acps), givco2_saw_bl
	aSAW tableikt aphase, kfn_saw, 1	
	aphPWM wrap aphase-ashape_square, 0, 1
	aSAW_DEL tableikt aphPWM, kfn_saw, 1
	asquare = aSAW - aSAW_DEL

	/* Steven Cook's old Csound EMS/VCS3 Synthi emulator */
	iampTri *= 2
	;Calc DC level shift for ramp
	kshift = abs(.5 - kshape)/2 + .25       
	ashape_tri interp kshape
	;Full wave rectify (ramp + shape)
	aramp    mirror  1 - aphase - ashape_tri, 0, 1 
	aramp = aramp - kshift

	/* Ape's method, same result but a little cryptic */
;	Simulate extreme range of PWM attenuation or enphasis
;	kShapeAtt_ = (kshape < 0.5) ? (1 - kshape) : kshape
;	aShapeAttenuation interp kShapeAtt_
;	Change scale factor for TRIANGOULAR PWM
;	kshape_ramp scale kshape, 1, -1
;	ashape_ramp interp kshape_ramp
;	if kshape_ramp < 0 then
;		ashape_ramp = abs(ashape_ramp)
;		aphase = 1 - aphase
;	endif
;	GENERATE TRIANGOULAR with PWM
;	aextended = aphase * (2 - ashape_ramp)
;	atri mirror aextended, 0, 1
;	aramp = (atri * 2) - 1

	/* Rescale and copy out */
	a31_vc_out = asquare * alsquare * iampSquare
	a32_vc_out = aramp * alramp * iampTri ;* aShapeAttenuation

#ifdef MIXER
#ifdef ZAK
	zaw a31_vc_out, 4
	zaw a32_vc_out, 5
#else
	gaSignals[4] = a31_vc_out	; write Signal in zak 6 (VCO_3 output 1)
	gaSignals[5] = a32_vc_out	; write Signal in zak 6 (VCO_3 output 2)
#end
#else
	chano a31_vc_out, 4
	chano a32_vc_out, 5
#end
endin

;------------------------------------------------------------
instr 14 ; NOISE
;------------------------------------------------------------

/* 3V p-p sampled wave is normalized in according */

kcolor 	chnget "noise_color"
knoiselev	chnget "noise_level"

kcolor port kcolor,0.1

;;anoise	rand 0.915 * knoiselev
;anoise 	linrand  0.915 * knoiselev

iNoiseTable = 12
ifreq = 	ftsr(iNoiseTable)/ftlen(iNoiseTable)
anoise 	oscil knoiselev, ifreq, iNoiseTable

asig_LO pareq anoise, 900, 1-abs(kcolor), 0.5, 2
asig_HI pareq anoise, 900, 1-kcolor, 0.5, 1

if kcolor <=0 then
#ifdef MIXER
#ifdef ZAK
	zaw asig_LO, 6
#else
	gaSignals[6] = asig_LO	; write Signal in zak 6 (Noise)	
#end
#else
	chano asig_LO, 6	
#end
else
#ifdef MIXER
#ifdef ZAK
	zaw asig_HI, 6
#else

	gaSignals[6] = asig_HI	; write Signal in zak 6 (Noise)	
#end
#else
	chano asig_HI, 6	
#end
endif

endin

;---------------------------------------------------------
instr 16 ; Filter
;---------------------------------------------------------

kcutoff 	chnget "filter_cutoff"
kres		chnget "filter_resonance"
kfillev 	chnget "filter_level"
;kcutoff   	port 	kcutoff, 0.066
kres		port	kres, 0.15
afillev		interp	kfillev

input init 7 ;Filter Signal Input
aInput1 = GET_CHANNEL(input)

inputCtrl init 13 ;Filter Control Input
aControlIn = GET_CHANNEL(inputCtrl)
iVoltPerOctave init -0.2 / $MAX_VOLT_REF
iNyquistHalf init sr/4

/* CUTOFF at k */
;kControlIn downsamp aControlIn
;kcut = kcutoff * powoftwo(kControlIn/iVoltPerOctave)
;kcut limit kcut, 1, iNyquistHalf
;kcut port kcut, 0.066 ;TODO in the settings (0.1)

/* CUTOFF at a */
apower POWOFTWO aControlIn/iVoltPerOctave ;i.e. 2ˆ(aControlIn/iVoltPerOctave)
acutoff interp kcutoff
acut maca acutoff, apower
acut limit acut, 1, iNyquistHalf
kcut port k(acut), 0.066
;acut_k interp kcut
;kglide = 0.06 ;TODO in the settings (0.1)
;acut PORT acut, kglide
;acut tone acut, 3

/* This is an hybrid version, the ladder and atone take acut_glide parameter, while the oscillator take full acut */
kglide chnget "filter_glide"
acut_glide = ((kcut * (1-kglide)) + (acut * kglide))
;acut_filter mac kglide, acut_k, (1-kglide), acut
;------------------------------------------------------------------------------------------------------------------

/* Max. Out. 4V p-p  ossia 4/2 = 2V peak i.e. */
ireson_OSC_amp  init 2 / $MAX_VOLT_REF  	 		; Initialize scale factor for whistle effect amount

/* External Filter Processing */
	afil VCS3Filter  aInput1, acut_glide, kres		; VCF
/* moogvcf permit xcut but sound very unlike */
;	afil	moogvcf2  aInput1, acut, kres		; VCF

/* original implementation by adapting moogladder filter */
;	afil	moogladder  aInput1, kcut, kres		; VCF

ares interp kres
amp_exp	tablei ares, 7, 1					; Scale auxiliary whistle oscillator amp with kres value (table 97) 
;FM issue
aosc	oscil ireson_OSC_amp*amp_exp, acut, 6	; Generate auxiliary whistle effect for VCF filter in hi-res setting 
;aHP		atonex afil, kcut, 2					; Hi-pass signal with hi-res setting
;aHP bqrez afil, acut, 0, 1			
aHP ATONE afil, acut_glide

aFILMIX = aHP * ares + afil * (1-ares)
afil =  (0.72 - amp_exp) * aFILMIX  + aosc			;!!!!!!!!!!! add this line for pure OSC effect on VCF
	
afil clip afil, 0, 1

;------------------------------------------------------------------------------------------------------------------
#ifdef MIXER
#ifdef ZAK
	zaw afil*afillev, 9
#else

	gaSignals[9] = afil*afillev	; write Signal
#end
#else 	
 	chano afil*afillev, 9
#end 
endin

;---------------------------------------------------------
instr 17 ; Envelope Shaper
;---------------------------------------------------------

kattack	chnget	"env_attack"
kon		chnget	"env_on"   
kdecay	chnget	"env_decay"
koff		chnget	"env_off"
ktrapezoid 	chnget 	"env_trapezoid"
ksignal	chnget	"env_signal"
;kATTACK	chnget	"trigger_attack"

/* Emphasizes the Env. Signal Output */
iEnvSignalAmplify init 1.33 ;1.4948 ;TODO verify
ksignal *= iEnvSignalAmplify

input init 3 ;Shaper Signal Input
aInput1 = GET_CHANNEL(input)

inputCtrl init 11 ;Shaper Control Input
aControlIn = GET_CHANNEL(inputCtrl)

atrapezoid interp ktrapezoid
asignal interp ksignal

kControlIn downsamp aControlIn

iVoltPerOctave init 0.4 / $MAX_VOLT_REF

kdecay = kdecay * powoftwo(kControlIn/iVoltPerOctave)
kdecay = kdecay < 0.003 ? 0.003 : kdecay	; Low Limiter
    
    
/* GATE from ATTACK/MIDI instr $GATE_INSTR or from chnget */
kact active $GATE_INSTR

if (kact > 0) && (gkIsGateEnabled == 1) then		;IF A NEW LEGATO PHRASE IS BEGINNING...
	kGATE = 1
else
	kGATE chnget "GATE" 
endif	

gkIsGateEnabled = 0

/* External Envelope Generation */
	aTrapezoid VCS3Envelope kattack, kon, kdecay, koff, kGATE
	;aTrapezoid EnvelopeApe kattack, kon, kdecay, koff, kGATE

	aEnvSignal tablei aTrapezoid, 13, 1 ;tablei cause a bad wrap index

/* Trapezoid Range Range -3V(ON) +4V(OFF) */
irange init -7 / $MAX_VOLT_REF
ioffset init 4 / $MAX_VOLT_REF
atrapez = (((aTrapezoid * irange) + ioffset) * atrapezoid)
aenvsig = aEnvSignal * aInput1 * asignal


#ifdef MIXER
#ifdef ZAK
	zaw atrapez, 10
	zaw aenvsig, 11	
#else

	gaSignals[10] = atrapez	; write Signal
	gaSignals[11] = aenvsig	; write Signal
#end
#else
 	chano atrapez, 10
 	chano aenvsig, 11	 
#end
endin

;---------------------------------------------------------
instr 18 ; Ring Modulation
;---------------------------------------------------------

input1 init 4 ;RM Signal 1 Input
aInput1 = GET_CHANNEL(input1)

input2 init 5 ;RM Signal 1 Input
aInput2 = GET_CHANNEL(input2)

/* Digital model of an analogue ring-modulator proposed by Julian Parker. 
(Julian Parker. A Simple Digital Model Of The Diode-Based Ring-Modulator. 
Proc. 14th Int. Conf. Digital Audio Effects, Paris, France, 2011.) */

;ind init 0
;iDiodeFunc init 10
;ilength init ftlen(iDiodeFunc)
;
;ivb = 0.2
;ivl = 0.4
;ih = 1
;
;do:
;if ind > (ilength - 1) igoto continue
;
;iv = (ind - ilength/2) / (ilength/2)
;iv = abs(iv)
;
;if (iv <= ivb) then
;ivalue = 0
;elseif ((ivb < iv) && (iv <= ivl)) then
;ipow1 pow iv-ivb, 2
;ivalue = ih * (ipow1 / (2*ivl - 2*ivb))
;else
;ipow2 pow ivl-ivb, 2
;ivalue = ih*iv - ih*ivl + (ih*((ipow2)/(2*ivl - 2*ivb)))
;endif
;
;tabw_i ivalue, ind, iDiodeFunc
;
;ind = ind + 1
;igoto do
;
;continue:


/* Eugenio Giordani's VCS3 RM -  Gilbert Circuit Simulation */

krmlev 	chnget "rm_level"
ksw 		chnget "rm_mode"
;0 = IDEAL RM
;1 = tanh
;2 = VCS3_RM
;3 = Diode
	
/* 
NOTE: The control simulated the effect of "bowing" the RM via DC signal (Joystick).  
Move slow or fast the slider to hear the effect... 
*/
	
aMOD atone aInput1, 2 /*16*/	;TODO verify amount of BOWING
aCAR atone aInput2, 2 /*16*/	
;aMOD = aInput1
;aCAR = aInput2	
	
/* Max. Input. 1.5V p-p  i.e. 1.5/2 = 0.75 / 3 = 0.25 */
iclipInput init 0.75 ;/// $MAX_VOLT_REF

aMOD clip aMOD, 0, iclipInput /* Input 1.5V p-p i.e. 1.5/ $MAX_VOLT_REF = 0.25 but 0.75 is OK */
aCAR clip aCAR, 0, iclipInput
;aMOD distort aMOD, iclipInput, 15
;aCAR distort aCAR, iclipInput, 15


/* Balace RM Output Level, 6V p-p */
ibalace 	init 2
krmlev_ = krmlev*ibalace
armlevel 	interp krmlev_


	if (ksw == 0) then	
		/* Ideal */
		armod = aMOD * aCAR	
	
;	elseif (ksw == 1) then
;		/* Tanh */	
;		armod = (aMOD * tanh(aCAR)) * armlevel
;	
	elseif(ksw == 1) then	
		
		kage	chnget "rm_age"
		
		ki1 = kage ; default 0.01
		ki2 = kage
		ki3 = kage
		ki4 = kage
		
		/* VCS3 */
		aCAR_t = tanh(aCAR)
		armod = (aMOD + ki1*aCAR_t) * (aCAR_t + ki2*aMOD) + (ki3 * aCAR_t) + (ki4 * aMOD)
 	
;	else		
;			
;		/* Diode */
;		aVc = aInput1			
;		aVinHalf = aInput2 * 0.5
;		aVinNeg = aVinHalf * (-1)
;		aVin = aVinNeg + aVc
;		aVc = aVc + aVinHalf
;;		aVcNeg = aVc * (-1)
;;		aVinNeg = aVin * (-1)
;		aDiodeVcPos table (aVc / 2) + 0.5 , iDiodeFunc, 1
;;		aDiodeVcNeg table (aVcNeg / 2) + 0.5 , iDiodeFunc, 1
;		aDiodeVinPos table (aVin / 2) + 0.5 , iDiodeFunc, 1
;;		aDiodeVinNeg table (aVinNeg / 2) + 0.5 , iDiodeFunc, 1			
;		aDiodeVc = aDiodeVcPos; + aDiodeVcNeg
;		aDiodeVin = aDiodeVinPos; + aDiodeVinNeg			
;		aSum = aDiodeVc + (aDiodeVin * (-1))
;		armod = aSum * 0.5
		  
	endif

;	aout clip armod, 0, 1
	aout = armod * armlevel

#ifdef MIXER
#ifdef ZAK
	zaw aout, 12
#else
	gaSignals[12] = aout	; write Signal
#end
#else
 	chano aout, 12		 	
#end
endin

;---------------------------------------------------------
instr 19 ; Reverberation
;---------------------------------------------------------

if (sr == 22050) then
	S_IR = "impulse_spring_22_synthi.wav"
	S_IR_SHORT = "impulse_spring_short_22_synthi.wav"
elseif (sr == 32000) then
	S_IR = "impulse_spring_32_synthi.wav"
	S_IR_SHORT = "impulse_spring_short_32_synthi.wav"
elseif (sr == 44100) then
	S_IR = "impulse_spring_44_synthi.wav" 	;Josue Arias
	S_IR_SHORT = "impulse_spring_short_44_synthi.wav"
elseif (sr == 48000) then
	S_IR = "impulse_spring_48_synthi.wav"
	S_IR_SHORT = "impulse_spring_short_48_synthi.wav"
endif

iStairwell	ftgen	 0, 0, 131072, 1, S_IR, 0, 0, 0

kwetdry 	chnget "reverb_drywet"
krevlev 	chnget "reverb_level"
kRevMode 	chnget "reverb_mode"


/* Emphasizes the Rev. Signal Output */
iRevAmplify init 1.2 ;1.301 ;TODO verify
krevlev *= iRevAmplify


kwetdry port kwetdry, 0.05
arevlevel interp krevlev

;0 = Schroeder
;1 = Convolve
;2 = Hybrid


input init 6 ;Rev Signal Input
aInput1 = GET_CHANNEL(input)

;aInput1	mpulse 1, 2	

inputCtrl init 12 ;Rev Control Input
aControlIn = GET_CHANNEL(inputCtrl)

kControlIn downsamp aControlIn

;iVoltSensitivity init 2 / $MAX_VOLT_REF ;+-2V sensitivity
;iRange init 2 * iVoltSensitivity
;kControlIn = kControlIn / iRange
;kwetdry -= kControlIn

kControlIn *= -$MAX_VOLT_REF
kwetdry += (kControlIn * kwetdry)
kwetdry limit kwetdry, 0, 1
    
aAP_DEL_FIL init 0
iIRT60 = 1.999;2.166
iIRT60_SHORT = 0.194

aInput1 dcblock2 aInput1
aInput1 clip aInput1, 0, 0.9

/* External CONVOLUTION */
;chnset aInput1, "rev_out"
;goto ext
;convolution is performed in the Csound callback


; FDN Reverberator
if kRevMode == 0 then

;	arev	nreverb aInput1, iIRT60, 0.0
;	arev	reverb aInput1, 3

	a1, a2 reverbsc    aInput1 * 1.8, aInput1 * -1.8, 0.85, 9000
;	aL, aR  freeverb aInput1 * 1.8, aInput1 * -1.8, 0.9, 0.35, sr, 0
;	arev nreverb	aInput1, 2, .3
	arev = a1 + a2


; Eugenio Giordani's Parametric Spring Rev
elseif kRevMode == 1 then

irvt 		= iIRT60
idel 		= 0.173 * 0.001
ifdb_gain	= 0.812 
iFC		= 4720

ainput = aInput1 + (aAP_DEL_FIL*ifdb_gain)

aAP_1 alpass ainput, irvt, idel	; CHIRP FILTER DISPERSION SECTION START
aAP_2 alpass aAP_1, irvt, idel
aAP_3 alpass aAP_2, irvt, idel
aAP_4 alpass aAP_3, irvt, idel
aAP_5 alpass aAP_4, irvt, idel
aAP_6 alpass aAP_5, irvt, idel
aAP_7 alpass aAP_6, irvt, idel
aAP_8 alpass aAP_7, irvt, idel	; CHIRP FILTER DISPERSION SECTION END


;kgain = 0.4
;kdel = 0.173
;kdel_samp = int(kdel*(sr/1000))
;aAP_1 ALLPASS_K ainput, kgain, kdel_samp
;aAP_2 ALLPASS_K aAP_1, kgain, kdel_samp
;aAP_3 ALLPASS_K aAP_2, kgain, kdel_samp
;aAP_4 ALLPASS_K aAP_3, kgain, kdel_samp
;aAP_5 ALLPASS_K aAP_3, kgain, kdel_samp
;aAP_6 ALLPASS_K aAP_3, kgain, kdel_samp
;aAP_7 ALLPASS_K aAP_3, kgain, kdel_samp
;aAP_8 ALLPASS_K aAP_7, kgain, kdel_samp

	
aAP_DEL		delay aAP_8, 0.059				; 59 ms is the VCS3 reverb pulse repetition
aAP_DEL_FIL		tone aAP_DEL, 3000
aSPRING_LOW_SEC	tonex aAP_DEL, iFC-500, 8 
aSPRING_DIFFUSE	nreverb aSPRING_LOW_SEC, 4, 0.15
aSPRING_HI   	atonex aAP_DEL, iFC, 3
aSPRING_HI_DEL	delay aSPRING_HI, 0.002

aSPRING_HI_SEC = aSPRING_DIFFUSE*0.2 + aSPRING_HI_DEL
arev = (aSPRING_LOW_SEC + aSPRING_HI_SEC*0.3) * 2.0

; Pure Convolution (with entire IR)
elseif kRevMode == 2 then

	arev	pconvolve aInput1, S_IR, 1024

; Hybrid 1 Convolution/Schroeder (with short IR)
elseif kRevMode == 3 then

	arev	pconvolve aInput1, S_IR_SHORT, 1024
	
	adel 			delay arev, 0.059 	; 59 ms is the VCS3 reverb pulse repetition
	arevSchroeder	nreverb adel*0.1, 2.166*1.5, 0.77
	arev = arev + arevSchroeder


; Hybrid 2 Convolution/Parametric (with short IR)
elseif kRevMode == 4 then
	
	arev	pconvolve aInput1*0.66, S_IR_SHORT, 1024

	irvt 		= iIRT60
	idel 		= 0.173 * 0.001
	ifdb_gain	= 0.75 
	iFC		= 4000
	
	ainput = arev*0.5 + (aAP_DEL_FIL*ifdb_gain)
	
	aAP_1 alpass ainput, irvt, idel	; CHIRP FILTER DISPERSION SECTION START
	aAP_2 alpass aAP_1, irvt, idel
	aAP_3 alpass aAP_2, irvt, idel
	aAP_4 alpass aAP_3, irvt, idel
	aAP_5 alpass aAP_4, irvt, idel
	aAP_6 alpass aAP_5, irvt, idel
	aAP_7 alpass aAP_6, irvt, idel
	aAP_8 alpass aAP_7, irvt, idel	; CHIRP FILTER DISPERSION SECTION END
		
	aAP_DEL		delay aAP_8, 0.059				; 59 ms is the VCS3 reverb pulse repetition
	aAP_DEL_FIL		tone aAP_DEL, 3000
	aSPRING_LOW_SEC	tonex aAP_DEL, iFC-500, 8 
	aSPRING_DIFFUSE	nreverb aSPRING_LOW_SEC, 4, 0.15
	aSPRING_HI   	atonex aAP_DEL, iFC, 3
	aSPRING_HI_DEL	delay aSPRING_HI, 0.002
	
	aSPRING_HI_SEC = aSPRING_DIFFUSE*0.2 + aSPRING_HI_DEL
	aRevParam = (aSPRING_LOW_SEC + aSPRING_HI_SEC*0.3) * 2.0
			
	arev = arev + aRevParam

; ftconv
elseif kRevMode == 5 then

	kircomp chnget "ftconv_t60"
	kirdir chnget "ftconv_direction"	
	
	kSwitch changed kircomp, kirdir

	if (kSwitch == 1) then
		
		reinit UPDATE			
	
	endif						

	UPDATE:
	iCompMinimumValue init 0.1							;Should be the same of UI control
	iComp		limit i(kircomp), iCompMinimumValue, 1
	iDir 		init i(kirdir)
	iplen = 1024									;BUFFER LENGTH

	iCompNorm 	init (iComp * 1.1) - iCompMinimumValue			;Get Normalized value
	iCurve 	init (iCompNorm - 1) * 10					;Rescale from -10 to 0
	iCurve = iComp < 1 ? iCurve : 20						;Skip curve when IR is't compressed 

	itab tab_treatment iStairwell, iComp, iCurve, iDir			;DERIVE FUNCTION TABLE NUMBER OF CHOSEN IR

	iirlen = nsamp(itab)								;DERIVE THE LENGTH OF THE IMPULSE RESPONSE IN SAMPLES
	iskipsamples = 0									;DERIVE INSKIP INTO IMPULSE FILE

	arev 		ftconv aInput1, itab, iplen, iskipsamples, iirlen	;CONVOLUTE INPUT SOUND
	aInput1 	delay aInput1, abs((iplen/sr) )				;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE

endif


;ext:
/* External CONVOLUTION */
;arev chnget "rev_in"
;printk2 k(arev)

awetdry interp kwetdry

;arevout ntrpol aInput1, arev, kwetdry ;introduce clicks and popos
;arevout = ((arev * awetdry + aInput1* (1-awetdry))  ) * arevlevel
arevout maca arev, awetdry, aInput1, (1-awetdry)

arevout maca arevout, arevlevel

#ifdef MIXER
#ifdef ZAK
	zaw arevout, 13
#else

 	gaSignals[13] = arevout	; write Signal
#end
#else 	
 	chano arevout, 13	
#end
endin


;---------------------------------------------------------
instr 21 ; VOLTOMETER
;---------------------------------------------------------

input init 0 ;Meter Input
#ifdef MIXER
aInput1 = GET_CHANNEL(input)
#else
aInput1 chani input+16
#end

gaFeedback = aInput1

	kACDC	chnget "voltometer_switch"
	
	if kACDC == 1 then

		ktrig	metro	10
		aInput1 atone aInput1, 2
		kpeak	max_k	aInput1, ktrig, 1
		aInput1 = a(kpeak)	
	endif

	chnset aInput1,"voltometer"
			
endin

;------------------------------------------------------------
instr 30 ; Spring Crash
;------------------------------------------------------------
ivoices active 30

krevlev 	chnget "reverb_level"
kwetdry 	chnget "reverb_drywet"
krevlev *= kwetdry

iamp = p4


iRiseTime = (1.05 - (1/ivoices)) * 0.3

kenv linseg 0, iRiseTime, iamp/ivoices, p3-iRiseTime, 0

;ipitch = birnd(.2) + 1
;asig 	diskin "crash_spring.wav", ipitch

;a1, a2 mp3in "crash_spring.mp3"

ipitch = birnd(1) ;pitch deviation
imp3Table init 11
ifreq = ftsr(imp3Table)/ftlen(imp3Table) * semitone(ipitch)
asig osciln kenv * krevlev, ifreq, imp3Table, 1

#ifdef MIXER
#ifdef ZAK
	zawm asig, 13	; write Signal into Reverb Out Channel
#else
 	gaSignals[13] = gaSignals[13] + asig
#end 	
#else
	arev chani 13
	chano arev + asig, 13
#end
endin


;---------------------------------------------------------
instr 50 ; OUTPUT LEVEL 1
;---------------------------------------------------------

/* 2V p-p Output and 10V p-p Headphones */ ; TODO rescale

kcolor 	chnget "out_1_filter"
kmutech chnget "out_1_mute"
klevel 	chnget "out_1_level"
;kpan		chnget "out_1_pan"

kcolor port kcolor, 0.1

input init 1
aSignalIn = GET_CHANNEL(input)

/* VC AMPLITUDE */
inputCtrl init 14
aControlIn = GET_CHANNEL(inputCtrl)

;AM issue
;kControlIn downsamp aControlIn
;klevel += kControlIn
;klevel limit klevel, 0, 1
/* Emphasizes the MASTER Signal Output */
;krescale_ = ((1 - kmutech) * klevel) * $OUTPUT_RESCALE
;arescale interp krescale_

/* Enable AM for Output 2 */
alevel interp klevel
alevel += aControlIn
alevel limit alevel, 0, 1
arescale = ((1 - kmutech) * alevel) * $OUTPUT_RESCALE

/* FILTERING */
asig_LO pareq aSignalIn, 900, 1-abs(kcolor), 0.5, 2
asig_HI pareq aSignalIn, 900, 1-kcolor, 0.5, 1

if kcolor <=0 then
	gaOUTPUT_CH1 = asig_LO * arescale	; write Signal in zak 6 (Noise)	
else
	gaOUTPUT_CH1 = asig_HI * arescale; write Signal in zak 6 (Noise)	
endif

;arescale	interp ((1 - kmutech) * klevel)
;apan 		interp kpan
;
;a1, a2 	pan2 afil*arescale, apan
;;a1 = afil * apan
;;a2 = afil * (1 - apan)
;
;vincr gaOUTPUT_CH1, a1
;vincr gaOUTPUT_CH2, a2
;outs a1, a2

endin

;---------------------------------------------------------
instr 51 ; OUTPUT LEVEL 2
;---------------------------------------------------------

/* 2V p-p Output and 10V p-p Headphones */ ; TODO rescale

kcolor 	chnget "out_2_filter"
kmutech chnget "out_2_mute"
klevel 	chnget "out_2_level"
;kpan 		chnget "out_2_pan"

kcolor port kcolor, 0.1

input init 2
aSignalIn = GET_CHANNEL(input)

/* VC AMPLITUDE */
inputCtrl init 15
aControlIn = GET_CHANNEL(inputCtrl)

; AM issue
;kControlIn downsamp aControlIn
;klevel += kControlIn
;klevel limit klevel, 0, 1
/* Emphasizes the MASTER Signal Output */
;krescale_ = ((1 - kmutech) * klevel) * $OUTPUT_RESCALE
;arescale interp krescale_

/* Enable AM for Output 2 */
alevel interp klevel
alevel += aControlIn
alevel limit alevel, 0, 1
arescale = ((1 - kmutech) * alevel) * $OUTPUT_RESCALE

/* FILTERING */
asig_LO pareq aSignalIn, 900, 1-abs(kcolor), 0.5, 2
asig_HI pareq aSignalIn, 900, 1-kcolor, 0.5, 1

if kcolor <=0 then
	gaOUTPUT_CH2 = asig_LO * arescale
else
	gaOUTPUT_CH2 = asig_HI * arescale	
endif

;arescale	interp ((1 - kmutech) * klevel)
;
;a1, a2 	pan2 afil*arescale, apan
;;a1 = afil * apan
;;a2 = afil * (1 - apan)
;
;vincr gaOUTPUT_CH1, a1
;vincr gaOUTPUT_CH2, a2
;outs a1, a2

endin

;---------------------------------------------------------
instr 60 ; FLANGER Ch.1 (Post Processing)
;---------------------------------------------------------
;release time must be sync with AudioDSP.mm enableFlangerCh1()
kenv linsegr 0, .5, 1, .5, 0
kenvinv = 1. - kenv

kdel	chnget "delay_ch1"
kfdbk	chnget "feedback_ch1"
kfdbk port kfdbk, 0.5
klfo_mix	chnget "lfo_or_mix_ch1"

kmode	chnget  "flanger_delay_toggle_ch1"

if kmode == 1 then 
		
	kdel scale kdel, 0.01, 0.001
	klfo scale klfo_mix, 10, 0.01

	klfo lfo 0.5, klfo
	klfo = 0.5 + klfo
	kdel_ = kdel*klfo
	adel interp kdel_

	aOutCh1 flanger 0.85 * gaOUTPUT_CH1, adel, kfdbk, 1.5
;	aOutCh1 = gaOUTPUT_CH1 + aOutCh1

else

	kdel scale kdel, 2, 0.01
	
	kportime   linseg      0, 0.001, 0.3
	kdel       portk       kdel, kportime
;	kdel		port		kdel, .3
	adel       	interp	kdel		
	aBuffer	delayr    	2	
	aOutCh1	deltap3   	adel
      	    	delayw    	gaOUTPUT_CH1 + (aOutCh1 * kfdbk)
      	    	
;	aOutCh1 ntrpol gaOUTPUT_CH1, aOutCh1, klfo
	
	awetdry interp klfo_mix
	aOutCh1 *= awetdry
	
endif

aOutCh1 = gaOUTPUT_CH1 + aOutCh1
aOutCh1 dcblock aOutCh1
gaOUTPUT_CH1 mac kenv, aOutCh1, kenvinv, gaOUTPUT_CH1
	
endin

;---------------------------------------------------------
instr 61 ; FLANGER Ch.2 (Post Processing)
;---------------------------------------------------------
;release time must be sync with AudioDSP.mm enableFlangerCh2()
kenv linsegr 0, .5, 1, .5, 0
kenvinv = 1. - kenv

kdel	chnget "delay_ch2"
kfdbk	chnget "feedback_ch2"
kfdbk port kfdbk, 0.5
klfo_mix	chnget "lfo_or_mix_ch2"

kmode	chnget  "flanger_delay_toggle_ch2"

if kmode == 1 then 
		
	kdel scale kdel, 0.01, 0.001
	klfo scale klfo_mix, 10, 0.01

	klfo lfo 0.5, klfo
	klfo = 0.5 + klfo
	kdel_ = kdel*klfo
	adel interp kdel_
	
	aOutCh2 flanger 0.85 * gaOUTPUT_CH2, adel, kfdbk, 1.5
;	aOutCh1 = gaOUTPUT_CH2 + aOutCh1

else
	kdel scale kdel, 2, 0.01

	kportime   linseg      0, 0.001, 0.3
	kdel       portk       kdel, kportime	
;	kdel		port		kdel, .3
	adel       	interp	kdel		
	aBuffer	delayr    	2	
	aOutCh2	deltap3   	adel
      	    	delayw    	gaOUTPUT_CH2 + (aOutCh2 * kfdbk)
      	    	
     	awetdry interp klfo_mix
	aOutCh2 *= awetdry

endif

aOutCh2 = gaOUTPUT_CH2 + aOutCh2
aOutCh2 dcblock aOutCh2
gaOUTPUT_CH2 mac kenv, aOutCh2, kenvinv, gaOUTPUT_CH2

endin

;---------------------------------------------------------
instr 62 ; COMPRESSOR Ch.1 (Post Processing)
;---------------------------------------------------------

kenv linsegr 0, .5, 0, .5, 1, .5, 0
kenvinv = 1. - kenv

kthresh	init	0.33
klowknee	init	48
khighknee	init	60
kratio     	chnget "comp_ratio_ch1"
kratio 	scale 1-kratio, 2, 0.5
kratio 	port kratio, 0.2

acomp 	= 1 ; gaOUTPUT_CH1 ;cause clicks & pops

kattack	init	0.100
krel		init	0.500
ilook		init	0.020
aOutCh1 	compress gaOUTPUT_CH1, acomp, kthresh, klowknee, khighknee, kratio, kattack, krel, ilook

;kthres chnget "comp_threshold_ch1"
;icomp1 = 1.4
;icomp2 = 1.6
;irtime = 0.01
;iftime = 0.3

; compressed audio
;kthres = 0.2
;icomp1 = 0.8
;icomp2 = 0.2
;irtime = 0.01
;iftime = 0.5

;expanded audio
;kthres = .5
;icomp1 = 2
;icomp2 = 3
;irtime = 0.01
;iftime = 0.1

;aOutCh1 dam gaOUTPUT_CH1, kthres, icomp1, icomp2, irtime, iftime
gaOUTPUT_CH1 mac kenv, aOutCh1, kenvinv, gaOUTPUT_CH1

endin

;---------------------------------------------------------
instr 63 ; COMPRESSOR Ch.2 (Post Processing)
;---------------------------------------------------------

kenv linsegr 0, .5, 0, .5, 1, .5, 0
kenvinv = 1. - kenv

kthresh	init	0.33
klowknee	init	48
khighknee	init	60
kratio     	chnget "comp_ratio_ch2"
kratio 	scale 1-kratio, 2, 0.5
kratio 	port kratio, 0.2

acomp 	= 1 ; gaOUTPUT_CH2 ;cause clicks & pops

kattack	init	0.100
krel		init	0.500
ilook		init	0.020
aOutCh2  	compress gaOUTPUT_CH2, acomp, kthresh, klowknee, khighknee, kratio, kattack, krel, ilook


;kthres chnget "comp_threshold_ch2"
;icomp1 = 1.4
;icomp2 = 1.6
;irtime = 0.01
;iftime = 0.3


; compressed audio
;kthres = 0.2
;icomp1 = 0.8
;icomp2 = 0.2
;irtime = 0.01
;iftime = 0.5

;expanded audio
;kthres = .5
;icomp1 = 2
;icomp2 = 3
;irtime = 0.01
;iftime = 0.1


;aOutCh2 dam gaOUTPUT_CH2, kthres, icomp1, icomp2, irtime, iftime
gaOUTPUT_CH2 mac kenv, aOutCh2, kenvinv, gaOUTPUT_CH2
	
endin

;------------------------------------------------------------
instr 80 ; Snapshots fade IO
;------------------------------------------------------------

iFadetTime init p3
aenv expsegr 1, iFadetTime, 0.001, iFadetTime, 1

gaOUTPUT_CH1 maca gaOUTPUT_CH1, aenv
gaOUTPUT_CH2 maca gaOUTPUT_CH2, aenv

;to be sure is turned off
;timout 0, iFadetTime * 2, end
;turnoff2 80, 0, 0
end:
endin

;------------------------------------------------------------
instr 85 ; DAC/PAN
;------------------------------------------------------------

kpan1		chnget "out_1_pan"

/* Sequencer Absolute Controls */
kpan1 += gkPan
;kpan1 limit kpan1, 0, 1

apan1 	interp kpan1

kpan2		chnget "out_2_pan"
apan2 	interp kpan2

/* OUTPUT PANNING */
;a1_L, a1_R 	pan2 gaOUTPUT_CH1, apan1
;a2_L, a2_R 	pan2 gaOUTPUT_CH2, apan2

; TODO ARCO SINE CROSSFADE
a1_L = gaOUTPUT_CH1 * (1 - apan1)
a1_R = gaOUTPUT_CH1 * apan1
a2_L = gaOUTPUT_CH2 * (1 - apan2)
a2_R = gaOUTPUT_CH2 * apan2

aL clip a1_L+a2_L, 0, 0.98
aR clip a1_R+a2_R, 0, 0.98

	outs aL, aR
	
endin

;------------------------------------------------------------
instr 97 ; MIDI Channel Assign
;------------------------------------------------------------

iMidiChannel init p4
iMidiLegatoMode init p5

	turnon 98

if(iMidiChannel == -1) then
	massign 0, 0
else
	massign 0, 0
	if iMidiLegatoMode == 1 then
		massign iMidiChannel, $GATE_INSTR	
	else
		massign iMidiChannel, $MIDI_INSTR_VCS3_LEGATO
	endif
endif

turnoff
endin

;------------------------------------------------------------
instr 98 ; MIDI Panic
;------------------------------------------------------------

turnoff2 $GATE_INSTR, 0, 0
turnoff2 $MIDI_INSTR_VCS3_LEGATO, 0, 0
turnoff

endin


;------------------------------------------------------------
instr $MIDI_INSTR_VCS3_LEGATO ; MIDI DK Legato Original VCS3
/* Note: new mode is performed in $GATE_INSTR */
;------------------------------------------------------------
	inum	notnum
	iamp	ampmidi 1

	/* get Pitch Bend from MIDI Keyboard */
			midipitchbend gkpitchbend


	instrument = $GATE_INSTR + (inum * 0.001)

	isDK init 1

	kon init 1
	krel release
	
	if krel == 1 then
;		printk2 k(instrument)
		event "i", -instrument, 0, 0		
	endif

	if (krel == 0) && (kon == 1) then
		
;		printk2 k(instrument)
		kon = 0
		event "i", instrument, 0, -1, inum - 60, iamp, isDK		
	endif
		
endin
</CsInstruments>
<CsScore>

/* gbuzz for BLIT */
f1 0 16384 11 1 									; cosine wave

/* Filter */
f6 0 16384 10 1									; Sine wave
;f7 0 1024 5 0.0001 512 0.0002 256 0.001 128 0.002 128 1			; First release 1.0.1
f7 0 1024 5 0.00001 512 0.0001 256 0.0005 128 0.002 128 1		; First release 1.0.1

/* VCO BLIT */
f8 0 1024 7  0.1 128 1.5  128 2 256 3   512  3			; Sine Amplitude compensation function    
f9 0 16  7 1 1 0.8 6 0.05 7 0.01 2 0					; Band control table

/* Ring Modulation Parker's Diode */
;f10 0	1024	7	1	512	0	512	1

/* Spring Crash Audio */
f11 0 262144 49 "crash_spring.mp3" 0 1

/* Noise Audio */
;f12 0 65536 49 "josue-noise.mp3" 0 0
f12 0 262144 -1 "noise_44.wav" 0 0 0

/* Envelope Attack Shape */
f13 0 4097 -1 "Trapezoid_attack.wav" 0 0 0

/* Envelope Decay Shape */
;f14 0 4097 -1 "Trapezoid_decay.wav" 0 0 0

/* RM Distot Sigmoid Shape  */
;f15 0 257 9 .5 1 270
;f15 0 257 9 .5 1 270,1.5,.33,90,2.5,.2,270,3.5,.143,90,4.5,.111,270

i85 0 360000000000
e
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
