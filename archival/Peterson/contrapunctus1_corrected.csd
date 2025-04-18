<CsoundSynthesizer>
/******************************************
 Contrapunctus I
 Julian Peterson
 May 2007
 julianpeterson@mac.com
 
 This work is licensed under a Creative Commons 
 Attribution-Noncommercial-Share Alike 3.0 
 United States License
 http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 ******************************************/
<CsOptions>
csound -f -h -M0 -d -m99 --midi-key=4 --midi-velocity=5 -RWfo contrapunctus.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 88200
ksmps = 1
nchnls = 2
0dbfs = 1.0

; Try various seeds at compile-time with
; --omacro:SEED=N, where N is some number 1-2^32

#ifdef SEED
	seed $SEED
#else
	seed 1
#end

zakinit 16,16

gi_sine ftgen 0,0,32769,10,1
gi_tri ftgen 0,0,32769,7,-1,16384,1,16384,-1,1,-1

gi_pitches ftgen 0,0,128,-2,0

gk_VoxDistance init 8
gk_PulseDistance init 2.5
gk_BellGain init ampdbfs(-96)

opcode CreatePitchTable,i,iiiiiiiio
	; Creates a table of pitches in all octaves for use with the PitchMapper
	i1,i2,i3,i4,i5,i6,i7,i8,itabnum xin
	itemptable ftgen 0,0,8,-2,i1,i2,i3,i4,i5,i6,i7,i8
	ii = 0
	_lowLoop:
		ival table ii,itemptable
		id = 0
		_divisionLoop:
			if ival*(2^id)<40 igoto _exitdivisionLoop
			id = id-1
			igoto _divisionLoop
		_exitdivisionLoop:
		tableiw ival*(2^(id+1)),ii,itemptable
		ii = ii+1
		if ii==8 igoto _exitlowLoop
		igoto _lowLoop
	_exitlowLoop:

	iouttable ftgen itabnum,0,128,-2,0
	ioct = 0
	ii = 0
	_octaveLoop:
		ipitch = 0
		_pitchLoop:
			ival table ipitch,itemptable
			if ival !=0 then
				tableiw ival*(2^ioct),ii,iouttable
				ii = ii+1
			endif
			ipitch = ipitch+1
			if ipitch==8 igoto _exitpitchLoop
			igoto _pitchLoop
		_exitpitchLoop:
		ioct = ioct+1
		if ioct==8 igoto _exitoctaveLoop
		igoto _octaveLoop
	_exitoctaveLoop:
	xout iouttable
	ftfree itemptable,0
endop

opcode PitchMapper,i,ii
	; maps the pitch to the closest acceptable neighbor...
	; kmapped PitchMapper kfrq,itableOfPitches
	ifrq,itable xin

	idiff = 22050
	ivalue table 0,itable
	ii = 0
	_loop:
		itest table ii,itable
		if abs(ifrq-itest)<idiff then
			idiff = abs(ifrq-itest)
			ivalue = itest
		endif
		ii = ii+1
		if ii==ftlen(itable) igoto _exit
		igoto _loop
	_exit:
	xout ivalue
endop

opcode PitchMapperK,k,ki
	; maps the pitch to the closest acceptable neighbor...
	; kmapped PitchMapper kfrq,itableOfPitches
	kfrq,itable xin

	kdiff = 22050
	kvalue table 0,itable
	ki = 0
	_loop:
		ktest table ki,itable
		if abs(kfrq-ktest)<kdiff then
			kdiff = abs(kfrq-ktest)
			kvalue = ktest
		endif
		ki = ki+1
		if ki==ftlen(itable) kgoto _exit
		kgoto _loop
	_exit:
	xout kvalue
endop

opcode PolarFilter,k,kkk
	; kval PolarFilter kinput,kstrength (where 1=complete attraction to poles and 0=no attraction), kdrag (general lowpass resistance 0->1)
	kin,kstr,kdrag xin
	kout init 0.5
	if (kout<=0.5)&&(kin<=0.5) then
		kout = kout*kdrag + kin*(1-kdrag)
	elseif (kout<=0.5)&&(kin>0.5) then
		kout = kout*kstr + kin*(1-kstr)
	elseif (kout>0.5)&&(kin<=0.5) then
		kout = kout*kstr + kin*(1-kstr)
	elseif (kout>0.5)&&(kin>0.5) then
		kout = kout*kdrag + kin*(1-kdrag)
	endif
	xout kout
endop

instr VoxDistance
	; p3 = duration of change
	; p4 = target
	gk_VoxDistance expseg i(gk_VoxDistance),p3,p4
endin

instr PulseDistance
	; p3 = duration of change
	; p4 = target
	gk_PulseDistance expseg i(gk_PulseDistance),p3,p4
endin

instr BellGain
	; p3 = duration of change
	; p4 = target in db
	gk_BellGain linseg i(gk_BellGain),p3,ampdbfs(p4)
endin

instr AlterPitchTable
	iset init 0
	kcd init 0
	kcd = kcd-(1/kr)
	if kcd<=0 then
		igoto _skipfirsttimethrough
		reinit _pitchset
			_pitchset:
			if iset==0 then
				gi_pitches CreatePitchTable cpspch(6.00),cpspch(6.02),cpspch(6.03),cpspch(6.07),cpspch(6.10),0,0,0,gi_pitches
			elseif iset==1 then
				gi_pitches CreatePitchTable cpspch(6.00),cpspch(6.02),cpspch(6.03),cpspch(6.07),cpspch(6.08),0,0,0,gi_pitches
			elseif iset==2 then
				gi_pitches CreatePitchTable cpspch(6.02),cpspch(6.03),cpspch(6.07),cpspch(6.08),cpspch(6.10),0,0,0,gi_pitches
			elseif iset==3 then
				gi_pitches CreatePitchTable cpspch(6.02),cpspch(6.03),cpspch(6.05),cpspch(6.08),cpspch(6.11),0,0,0,gi_pitches
			endif
			iset = (iset+1)%4
			rireturn
		_skipfirsttimethrough:
		kcd random 8,12
	endif
endin

instr AlterPitchTableB
	iset init 0
	kcd init 0
	kcd = kcd-(1/kr)
	if kcd<=0 then
		igoto _skipfirsttimethrough
		reinit _pitchset
			_pitchset:
			if iset==0 then
				gi_pitches CreatePitchTable cpspch(6.00),cpspch(6.02),cpspch(6.03),cpspch(6.07),cpspch(6.08),0,0,0,gi_pitches
			elseif iset==1 then
				gi_pitches CreatePitchTable cpspch(6.002),cpspch(6.02),cpspch(6.028),cpspch(6.06),cpspch(6.087),0,0,0,gi_pitches
			elseif iset==2 then
				gi_pitches CreatePitchTable cpspch(5.11),cpspch(6.02),cpspch(6.028),cpspch(6.06),cpspch(6.087),0,0,0,gi_pitches
			elseif iset==3 then
				gi_pitches CreatePitchTable cpspch(5.11),cpspch(6.002),cpspch(6.028),cpspch(6.04),cpspch(6.071),0,0,0,gi_pitches
			elseif iset==4 then
				gi_pitches CreatePitchTable cpspch(5.10),cpspch(6.01),cpspch(6.028),cpspch(6.071),cpspch(6.087),0,0,0,gi_pitches
			elseif iset==5 then
				gi_pitches CreatePitchTable cpspch(5.11),cpspch(6.02),cpspch(6.03),cpspch(6.05),cpspch(6.09),0,0,0,gi_pitches
			endif
			iset = (iset+1)%6
			rireturn
		_skipfirsttimethrough:
		kcd random 3,6
	endif
endin

instr AutoPoint
	xtratim (2/kr)
	iname nstrnum "SpectralGhost"
	inameplus random 0.1,0.9
	knameplus init inameplus
	kcd init 0
	kcd = kcd - (1/kr)
	if kcd<=0 then
		krand random 0,1
		krand PolarFilter krand,0.8,0.3
		kfrq PitchMapperK krand*900 + 40,gi_pitches
		krand random 0,1
		krand PolarFilter krand,0.8,0.5
		kamp = ampdbfs(krand*-16 - 8)
		kfilt = krand*0.8 + 0.7
		konoff random 0,1
		event "i",iname+knameplus,0,(konoff<0.1?1.4:-1),kamp,kfrq,kfilt
		if konoff<0.1 then
			knameplus random 0.1,0.9
			kcd random 8,16
			kcd = int(kcd)*0.2
		else
			kcd random 0,1
			kcd PolarFilter kcd,0.9,0
			kcd = int(kcd*8 + 1)*0.2
		endif
	endif

	ktime timeinsts
	if ktime>p3 then
		event "i",iname+knameplus,0,4.4,ampdbfs(-48),kfrq,kfilt
		turnoff
	endif
endin

instr +SpectralGhost
	; p3 = duration, x<0 for note on, x>0 for note off
	; p4 = amplitude
	; p5 = baseFrequency
	; p6 = cutoff as multiple of fundamental

	itie tival
	if itie==0 && p3<0 then
		kenv linseg 0,0.2,p4,1,p4
		klfoenv linseg 0,0.6,0.005,1,0.005
	elseif itie==0 && p3>0 then
		kenv linseg 0,p3*0.2,p4,p3*0.6,p4,p3*0.2,0
		klfoenv linseg 0,0.6,0.005,1,0.005
	elseif itie==1 && p3<0 then
		kenv linseg i(kenv),0.7,p4,1,p4
	elseif itie==1 && p3>0 then
		kenv linseg i(kenv),p3,0
	endif

	tigoto _skiptie
		itie random -1,1
		iL = (sqrt(2)/2)*(cos(itie)-sin(itie))
		iR = (sqrt(2)/2)*(cos(itie)+sin(itie))
		aenv interp kenv
		kfrq port p5,0.005,p5
		kcf port p6,0.2,p6
		kshape randi 0.1,0.15
		kspr = 0

		kdist port gk_VoxDistance,0.2,i(gk_VoxDistance)

		klfospd randi 1,0.2
		klfo oscil klfoenv,klfospd+4,gi_sine
		asaw1 vco 0.2,kfrq*(1+klfo)+(kspr*0),3,0.11+kshape,gi_sine
		asaw2 vco 0.2,kfrq*(1+klfo)+(kspr*1.1),3,0.11+kshape,gi_sine
		asaw3 vco 0.2,kfrq*(1+klfo)+(kspr*1.9),3,0.11+kshape,gi_sine
		asaw4 vco 0.2,kfrq*(1+klfo)+(kspr*3.1),3,0.11+kshape,gi_sine
		asaw5 vco 0.2,kfrq*(1+klfo)+(kspr*3.9),3,0.11+kshape,gi_sine
		asaw = asaw1+asaw2+asaw3+asaw4+asaw5
		aflt butterlp asaw,kcf*kfrq
		aflt balance aflt,asaw
		aflt = aflt*aenv
		adry = aflt/(kdist^2)
		awet = aflt/kdist
		afltL,afltR hilbert adry

		aL = adry*iL
		aR = adry*iR
		outs aL,aR
		awetL,awetR hilbert awet
		zawm awetL,14
		zawm awetR,15
	_skiptie:
endin

instr PulseController
	kcd init 0
	kcd = kcd-(1/kr)
	if kcd<=0 then
		kbass random 40,80
		kbass PitchMapperK kbass,gi_pitches
		kamp random 0,1
		kamp PolarFilter kamp,0.8,0.3
		kamp = ampdbfs(kamp*-12 -12)
		kfrq random 300,800
		kband random 300,400
		kcd random 0,1
		kcd PolarFilter kcd,0.3,0
		kcd = int(kcd*8+6)*0.4
		event "i","ChordPulse",0,kcd,kamp,kbass,kfrq,kband
	endif
endin
		

instr +ChordPulse
	; p3 = duration of pulsed event
	; p4 = amplitude
	; p5 = frequency of pluck 
	; p6 = center frequency of pulse
	; p7 = bandwidth

	; pluck component
	aexcite linseg 0,0.002,1,0.004,-1,0.006,0,1,0
	kfrq linseg p5*1.01,0.05,p5,1,p5
	astr streson aexcite,kfrq,0.995
	alp butterlp astr,p5*8
	astr balance alp,astr*p4*0.5
	kclip linseg 1,p3-0.02,1,0.02,0
	astr = astr*kclip

	; pulse component
	ifrq1 random p7/-2,p7/2
	ifrq1 PitchMapper ifrq1+p6,gi_pitches
	ifrq2 random p7/-2,p7/2
	ifrq2 PitchMapper ifrq2+p6,gi_pitches
	ifrq3 random p7/-2,p7/2
	ifrq3 PitchMapper ifrq3+p6,gi_pitches
	ifrq4 random p7/-2,p7/2
	ifrq4 PitchMapper ifrq4+p6,gi_pitches
	ifrq5 random p7/-2,p7/2
	ifrq5 PitchMapper ifrq5+p6,gi_pitches

	apulse phasor 10
	apulse butterlp 1-apulse,20
	aenv linseg 0,0.001,p4*0.5,p3-0.001,0
	avox1 vco 0.2,ifrq1,1,0.5,gi_sine
	avox1 butterlp avox1,ifrq1*2
	avox2 vco 0.2,ifrq2,1,0.5,gi_sine
	avox2 butterlp avox2,ifrq2*2
	avox3 vco 0.2,ifrq3,1,0.5,gi_sine
	avox3 butterlp avox3,ifrq3*2
	avox4 vco 0.2,ifrq4,1,0.5,gi_sine
	avox4 butterlp avox4,ifrq4*2
	avox5 vco 0.2,ifrq5,1,0.5,gi_sine
	avox5 butterlp avox5,ifrq5*2

	avox = (avox1+avox2+avox3+avox4+avox5)*apulse*aenv
	amix = avox+astr
	adry = amix/(gk_PulseDistance^2)
	awet = amix/(gk_PulseDistance^2)
	outs adry,adry
	zawm awet,14
endin

instr HarmBellController
	; p3 = duration
	; p4 = fundamental pitch
	; p5 = mode (determines possible transpositions of pitch index)
	; p6 = db level of loudest harmonic per series

	idominant ftgen 0,0,4,-2,0.00,0.04,0.07,0.10 ; the terms dominant and minor
	iminor ftgen 0,0,4,-2,0.00,0.03,0.07,0.12 ; are no longer really valid...
	
	iFemale = 1	; zak channels for panning control
	iMale = 2
	iNumTones = 32
	idetune = 1.01

	kmal init 0
	kmal = kmal-(1/kr)
	kfem init 0
	kfem = kfem-(1/kr)

	if kmal <=0 then
		if p5==0 then
			kfund = cpspch(p4)
		elseif p5==1 then
			ktrans random -4,4
			ktrans table int(ktrans),idominant
			kfund = cpspch(p4+ktrans)
		elseif p5==2 then
			ktrans random -4,4
			ktrans table int(ktrans),iminor
			kfund = cpspch(p4+ktrans)
		endif
		kdir random 0,1
		ki = 0
		ktim random 1,4
		ktim = int(ktim)*0.1
		_maleLoop:
			if kdir<0.5 then
				kfrq = ki+1
				if kfrq>=1 then
					if p5==0 then
						kfreq PitchMapperK kfund*kfrq,gi_pitches
					else
						kfreq = kfund*kfrq
					endif
					event "i","SineBells",ki*ktim,5,ampdbfs(p6-ki),kfreq,iMale
				elseif kfrq<1 then
					if p5==0 then
						kfreq PitchMapperK kfund*kfrq,gi_pitches
					else
						kfreq = kfund*kfrq
					endif
					kfrq = 1/(kfrq-2)
					event "i","SineBells",ki*ktim,5,ampdbfs(p6-ki),kfreq,iMale
				endif
			elseif kdir>=0.5 then
				kfrq = ki+1
				if kfrq>=1 then
					if p5==0 then
						kfreq PitchMapperK kfund*kfrq,gi_pitches
					else
						kfreq = kfund*kfrq
					endif
					event "i","SineBells",(iNumTones-ki)*ktim,5,ampdbfs(p6-ki),kfreq,iMale
				elseif kfrq<1 then
					if p5==0 then
						kfreq PitchMapperK kfund*kfrq,gi_pitches
					else
						kfreq = kfund*kfrq
					endif
					kfrq = 1/(kfrq-2)
					event "i","SineBells",(iNumTones-ki)*ktim,5,ampdbfs(p6-ki),kfreq,iMale
				endif
			endif
			ki=ki+1
			if ki==iNumTones kgoto _exitMaleLoop
			kgoto _maleLoop
		_exitMaleLoop:
		kmal random 8,15
		kmal = int(kmal)*0.6
	endif

	if kfem <=0 then
		if p5==0 then
			kfund = cpspch(p4)
		elseif p5==1 then
			ktrans random -4,4
			ktrans table int(ktrans),idominant
			kfund = cpspch(p4+ktrans)
		elseif p5==2 then
			ktrans random -4,4
			ktrans table int(ktrans),iminor
			kfund = cpspch(p4+ktrans)
		endif
		kdir random 0,1
		ki = 0
		ktim random 1,4
		ktim = int(ktim)*0.1
		_femaleLoop:
			if kdir<0.5 then
				kfrq = ki+1
				if kfrq>=1 then
					if p5==0 then
						kfreq PitchMapperK kfund*kfrq,gi_pitches
					else
						kfreq = kfund*kfrq
					endif
					event "i","SineBells",ki*ktim,5,ampdbfs(p6-ki),kfreq*idetune,iFemale
				elseif kfrq<1 then
					if p5==0 then
						kfreq PitchMapperK kfund*kfrq,gi_pitches
					else
						kfreq = kfund*kfrq
					endif
					kfrq = 1/(kfrq-2)
					event "i","SineBells",ki*ktim,5,ampdbfs(p6-ki),kfreq*idetune,iFemale
				endif
			elseif kdir>=0.5 then
				kfrq = ki+1
				if kfrq>=1 then
					if p5==0 then
						kfreq PitchMapperK kfund*kfrq,gi_pitches
					else
						kfreq = kfund*kfrq
					endif
					event "i","SineBells",(iNumTones-ki)*ktim,5,ampdbfs(p6-ki),kfreq*idetune,iFemale
				elseif kfrq<1 then
					if p5==0 then
						kfreq PitchMapperK kfund*kfrq,gi_pitches
					else
						kfreq = kfund*kfrq
					endif
					kfrq = 1/(kfrq-2)
					event "i","SineBells",(iNumTones-ki)*ktim,5,ampdbfs(p6-ki),kfreq*idetune,iFemale
				endif
			endif
			ki=ki+1
			if ki==iNumTones kgoto _exitFemaleLoop
			kgoto _femaleLoop
		_exitFemaleLoop:
		kfem random 8,15
		kfem = int(kfem)*0.6
	endif

	kpan random 0,1
	if kpan<0.005 then
		kpan random -1,1
		zkw kpan,iMale
		zkw -1*kpan,iFemale
	endif
endin


instr +SineBells
	; p3 = duration
	; p4 = amplitude
	; p5 = frequency
	; p6 = zak channel for panning location

	ipan zir p6
	kpan zkr p6
	kpan port kpan,1,ipan
	irt2o2 = sqrt(2)/2
	kL = irt2o2*(cos(kpan)-sin(kpan))
	kR = irt2o2*(cos(kpan)+sin(kpan))

	aenv expseg 0.001,0.005,p4,p3-0.005,0.0001
	asnd oscili aenv*i(gk_BellGain),p5,gi_sine
	outs asnd*kL,asnd*kR
endin

instr +Reverb
	; p3 = duration
	; p4 = feedback level
	; p5 = lowpass filter cutoff in hz
	; p6 = post-gain in db

	afadein linseg 0,0.001,1,1,1
	ainL zar 14
		ainL=ainL*afadein
	ainR zar 15
		ainR=ainR*afadein
	zacl 14,15

	ainL atone ainL,100
	ainR atone ainR,100

	ainL tone ainL,12000
	ainR tone ainR,12000

	aoutL,aoutR reverbsc ainL,ainR,p4,p5
	outs aoutL*ampdbfs(p6),aoutR*ampdbfs(p6)
endin	

	


</CsInstruments>
<CsScore>

; MIXING BOARD
	i "Reverb" 0 450 0.94 2000 -24	; turn on global reverb
	i "VoxDistance" 0.001 30 2	; fade in vox
	i "PulseDistance" 59 30 1.5	; fade in pulse
	i "VoxDistance" 200 60 4	; fade out vox
	i "PulseDistance" 220 40 3	; fade out pulse
	i "BellGain" 200 60 -2		; fade in bells
	i "BellGain" 332 80 -48		; fade out bells
	i "VoxDistance" 300 1 2		; quietly fade in vox
	i "PulseDistance" 300 1 2 	; quietly fade in pulse

; HAMONIC CONSTRUCTION
	i "AlterPitchTable" 0 260
	i "AlterPitchTableB" 266 64
	i "AlterPitchTable" 330 90
	i "AlterPitchTable" 410 1

; INSTRUMENT ACTIVATION
	i "AutoPoint" 0 260
	i "AutoPoint" 20 240
	i "AutoPoint" 30 230
	i "PulseController" 60 200

	i "HarmBellController" 200 30 7.00 0 -32
	i .                    230 30 7.04 0 .
	i .                    260 30 7.04 0 .
	i .                    262 30 7.04 0 .
	i .                    290 15 6.09 0 .
	i .                    292 15 6.09 0 .
	i .                    305 25 6.03 0 .
	i .                    307 25 6.00 0 .
	i .                    330 60 7.03 0 .
	i .                    332 40 7.00 0 .
	i .                    372 40 7.00 0 .

	i "PulseController" 329 60
	i "AutoPoint" 329 90
	i "AutoPoint" 329 100
	i "AutoPoint" 330 110

; EOF

</CsScore>
</CsoundSynthesizer>
