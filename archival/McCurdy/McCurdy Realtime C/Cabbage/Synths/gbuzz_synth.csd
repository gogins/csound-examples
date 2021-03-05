<Cabbage>
form caption("gbuzz Synth") size(655, 450), pluginID("wtsy")
image   bounds( 10,  6,365, 90), colour("DarkSlateGrey"), outline("white"), line(2)	;main
image   bounds(380,  6,140, 90), colour("DarkSlateGrey"), outline("white"), line(2)	;polyphony
image   bounds(525,  6,120, 90), colour("DarkSlateGrey"), outline("white"), line(2)	;reverb
image   bounds( 10,101,365, 90), colour("DarkSlateGrey"), outline("white"), line(2)	;main
image pos(0, 0), size(655, 450), colour("DarkSlateGrey"), outline("MediumSlateBlue"), line(3)

label   bounds(190, 11,100, 15), text("Main"), fontcolour(white)
label   bounds(415, 11,100, 15), text("Polyphony"), fontcolour(white)
label   bounds(555, 11,100, 15), text("Reverb"), fontcolour(white)
label   bounds(125,106,160, 15), text("Multiplier Envelope"), fontcolour(white)

;MAIN
rslider  bounds( 10, 29, 62, 62), text("Level"),  colour(SlateGrey) channel("level"),range(0,20, 1,0.5,0.001), fontcolour(white)
rslider  bounds( 70, 29, 62, 62), text("Power"),  colour(SlateGrey) channel("mul"), range(0, 0.90, 0.6), fontcolour(white)
rslider  bounds(130, 29, 62, 62), text("Lowest"), colour(SlateGrey)  channel("lh"), range(1, 40, 1,1,1), fontcolour(white)
rslider  bounds(190, 29, 62, 62), text("Number"), colour(SlateGrey)  channel("nh"), range(1,200,80,1,1), fontcolour(white)
rslider  bounds(250, 29, 62, 62), text("Jitter"), colour(SlateGrey) channel("jitter"),range(0, 1, 0.4), fontcolour(white)
rslider  bounds(310, 29, 62, 62), text("Pan"),    colour(SlateGrey) channel("pan"),range(0, 1, 0.5), fontcolour(white)

;MULTIPLIER ENVELOPE
rslider  bounds( 10,124, 62, 62), text("Att"),  colour(SlateGrey) channel("MAtt"),range(0, 5.000, 0.01, 0.375,0.0001), fontcolour(white)
rslider  bounds( 70,124, 62, 62), text("Lev"),  colour(SlateGrey) channel("MLev"),range(0, 1.000, 0), fontcolour(white)
rslider  bounds(130,124, 62, 62), text("Dec"),  colour(SlateGrey) channel("MDec"),range(0, 5.000, 0.1,  0.375,0.0001), fontcolour(white)
rslider  bounds(190,124, 62, 62), text("Sus"),  colour(SlateGrey) channel("MSus"),range(0, 1.000, 0.6), fontcolour(white)
rslider  bounds(250,124, 62, 62), text("Rel"),  colour(SlateGrey) channel("MRel"),range(0, 5.000, 0.1,  0.375,0.0001), fontcolour(white)

;POLYPHONY
button   bounds(390, 40, 70, 25), text("mono", "poly"), channel("monopoly"), value(1), fontcolour("lime") 
rslider  bounds(460, 32, 60, 60), text("Leg.Time"), channel("LegTim"), range(0.01, 15, 0.002, 0.25, 0.00001), fontcolour(white) colour(SlateGrey)

;REVERB
rslider bounds(525, 29, 60, 60), text("Mix"), channel("RvbMix"), range(0, 1, 0.3), fontcolour(white) colour(SlateGrey)
rslider bounds(585, 29, 60, 60), text("Size"), channel("RvbSize"), range(0.3, 1, 0.7), fontcolour(white) colour(SlateGrey)


;FILTERS
checkbox bounds( 10,200, 90, 15), text("Active") channel("Filt1Active"), FontColour("White"), colour("lime")  value(0)
xypad    bounds( 10,220,200,130),                channel("Filt1Freq", "Filt1BW"), rangex(0, 1.00, 0), rangey(0, 1,00, 0);, text("Freq/BW")
checkbox bounds(220,200, 90, 15), text("Active") channel("Filt2Active"), FontColour("White"), colour("lime")  value(0)
xypad    bounds(220,220,200,130),                channel("Filt2Freq", "Filt2BW"), rangex(0, 1.00, 0), rangey(0, 1.00, 0);, text("Freq/BW")
checkbox bounds(430,200, 90, 15), text("Active") channel("Filt3Active"), FontColour("White"), colour("lime")  value(0)
xypad    bounds(430,220,200,130),                channel("Filt3Freq", "Filt3BW"), rangex(0, 1.00, 0), rangey(0, 1.00, 0);, text("Freq/BW")

keyboard pos(10, 360), size(635, 80)

</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-dm0 -n -+rtmidi=null -M0
</CsOptions>

<CsInstruments>

sr 		= 	44100
ksmps 		= 	16
nchnls 		= 	2
0dbfs		=	1	;MAXIMUM AMPLITUDE
seed	0
massign	0,2

;Author: Iain McCurdy (2012)

gisine	ftgen	0,0,131072,10,1			;A SINE WAVE. USED BY THE LFOs.
gicos	ftgen	0,0,131072,9,1,1,90		;FUNCTION TABLE THAT STORES A SINGLE CYCLE OF A COSINE WAVE

gasendL,gasendR	init	0

;FUNCTION TABLE USED TO RE-MAP THE RELATIONSHIP BETWEEN VELOCITY AND ATTACK TIME 
giattscl	ftgen	0,0,128,-16,2,128,-10,0.005
giNAttScl	ftgen	0,0,128,-16,8,128,-4,0.25

opcode	butlpsr,a,aa
	setksmps	1
	ain,afreq	xin
	kfreq	downsamp	afreq
	aout	butlp	ain,kfreq
	xout	aout
endop

opcode	sspline,k,Kiii
	kdur,istart,iend,icurve	xin										;READ IN INPUT ARGUMENTS
	imid	=	istart+((iend-istart)/2)								;SPLINE MID POINT VALUE
	isspline	ftgentmp	0,0,4096,-16,istart,4096*0.5,icurve,imid,(4096/2)-1,-icurve,iend	;GENERATE 'S' SPLINE
	kspd	=	i(kdur)/kdur										;POINTER SPEED AS A RATIO (WITH REFERENCE TO THE ORIGINAL DURATION)
	kptr	init	0											;POINTER INITIAL VALUE	
	kout	tablei	kptr,isspline										;READ VALUE FROM TABLE
	kptr	limit	kptr+((ftlen(isspline)/(i(kdur)*kr))*kspd), 0, ftlen(isspline)-1			;INCREMENT THE POINTER BY THE REQUIRED NUMBER OF TABLE POINTS IN ONE CONTROL CYCLE AND LIMIT IT BETWEEN FIRST AND LAST TABLE POINT - FINAL VALUE WILL BE HELD IF POINTER ATTEMPTS TO EXCEED TABLE DURATION
		xout	kout											;SEND VALUE BACK TO CALLER INSTRUMENT
endop

instr	1
	gkmul		chnget	"mul"
	gklh		chnget	"lh"
	gknh		chnget	"nh"
	
	gkmonopoly	chnget	"monopoly"
	gkLegTim	chnget	"LegTim"

	gkpan		chnget	"pan"
	gklevel		chnget	"level"
	gkRvbMix	chnget	"RvbMix"
	gkRvbSize	chnget	"RvbSize"

	gkFilt1Active	chnget	"Filt1Active"
	gkFilt1Freq	chnget	"Filt1Freq"
	gkFilt1BW	chnget	"Filt1BW"

	gkFilt2Active	chnget	"Filt2Active"
	gkFilt2Freq	chnget	"Filt2Freq"
	gkFilt2BW	chnget	"Filt2BW"

	gkFilt3Active	chnget	"Filt3Active"
	gkFilt3Freq	chnget	"Filt3Freq"
	gkFilt3BW	chnget	"Filt3BW"

	gkMAtt	chnget	"MAtt"
	gkMLev	chnget	"MLev"
	gkMDec	chnget	"MDec"
	gkMSus	chnget	"MSus"
	gkMRel	chnget	"MRel"

endin

instr	2	;triggered via MIDI
	gkNoteTrig	init	1	;at the beginning of a new note set note trigger flag to '1'
	inum		notnum		;read in midi note number
	givel		veloc	0,1	;read in midi note velocity
	gknum	=	inum		;update a global krate variable for note pitch

	if i(gkmonopoly)==0 then		;if we are *not* in legato mode...
	 inum	notnum						; read midi note number (0 - 127)
	 	event_i	"i",p1+1+(inum*0.001),0,-1,inum		; call sound producing instr
	 krel	release						; release flag (1 when note is released, 0 otherwise)
	 if krel==1 then					; when note is released...
	  turnoff2	p1+1+(inum*0.001),4,1			; turn off the called instrument
	 endif							; end of conditional
	else				;otherwise... (i.e. legato mode)
	 iactive	active p1+1	;check to see if there is already a note active...
	 if iactive==0 then		;...if not...
	  event_i	"i",p1+1,0,-1	;...start a new held note
	 endif
	endif
endin

instr	3	;gbuzz instrument. MIDI notes are directed here.
	kporttime	linseg	0,0.001,1		;portamento time function rises quickly from zero to a held value
	kglisstime	=	kporttime*gkLegTim	;scale portamento time function with value from GUI knob widget


	if i(gkmonopoly)==1 then			;if we are in legato mode...
	 gkoldnum	init	i(gknum)
	 ktrig	changed	gknum
	 if ktrig==1 then
	  reinit PORTAMENTO
	 endif
	 PORTAMENTO:
	 icurve	=	1
	 knum	sspline kglisstime, i(gkoldnum),i(gknum),icurve
	 rireturn
	 gkoldnum	=	gknum
	 kactive	active	p1-1			;...check number of active midi notes (previous instrument)
	 if kactive==0 then				;if no midi notes are active...
	  turnoff					;... turn this instrument off
	 endif
	else						;otherwise... (polyphonic / non-legato mode)
	 knum	=	p4		 		;pitch equal to the original note pitch
	endif
	ivel	init	givel
	
	kporttime	linseg		0,0.001,0.02		;CREATE A FUNCTION  THAT RISES RAPIDLY FROM ZERO TO A FIXED VALUE THAT WILL BE USED FOR PORTAMENTO TIME 
	kjitter		chnget		"jitter"
	
	;------------------------------------------------------------------------------------------------------------
	;PITCH JITTER (THIS WILL BE USED TO ADD HUMAN-PLAYER REALISM)
	;------------------------------------------------------------------------------------------------------------
	;				AMP | MIN_FREQ. | MAX_FREQ
	kPitchJit	jitter		0.05*kjitter*4,     1,         20

	;------------------------------------------------------------------------------------------------------------
	;AMPLITUDE JITTER (THIS WILL BE USED TO ADD HUMAN-PLAYER REALISM)
	;------------------------------------------------------------------------------------------------------------
	;				AMP | MIN_FREQ. | MAX_FREQ
	kAmpJit		jitter		0.1*kjitter*4,     0.2,        1
	kAmpJit		=		kAmpJit+1			;OFFSET SO IT MODULATES ABOUT '1' INSTEAD OF ABOUT ZERO
	
	knum		=		knum+kPitchJit			;DERIVE K-RATE NOTE NUMBER VALUE INCORPORATING PITCH BEND, VIBRATO, AND PITCH JITTER	

	/* OSCILLATOR */
	kmul		portk		gkmul, kporttime*0.5
	if i(gkMLev)>i(kmul)||i(gkMSus)<i(kmul) then
	 kmul	linsegr	0, i(gkMAtt)+0.0001, i(gkMLev), i(gkMDec)+0.0001, i(gkMSus), i(gkMRel)+0.0001, 0
	endif
	asig		gbuzz		(kAmpJit*0.1), cpsmidinn(knum), gknh, gklh, kmul, gicos
	
	;asig	pinkish	0.2
	
	
	/* FILTERS */
	amix	=	0
	
#define	FILTER(N)#
	if gkFilt$NActive==1 then
	 gkFilt$NFreq	portk	gkFilt$NFreq*7,kporttime*0.03
	 kcf	=	cpsoct(6+gkFilt$NFreq)
	 gkFilt$NBW	portk	gkFilt1BW,kporttime*0.03
	 gkFilt$NBW	expcurve	gkFilt$NBW,24
	 kbw	scale	1-gkFilt$NBW, 5, 0.001
	 aFlt$N	resonr	asig,kcf,kcf*kbw ,1
	 amix	=	amix + aFlt$N
	endif#
	$FILTER(1)
	$FILTER(2)
	$FILTER(3)
	
	if gkFilt1Active+gkFilt2Active+gkFilt3Active>0 then
	 ;asig	balance	amix,asig
	 asig	=	amix
	endif



	iatt		=		0.05
	aenv		linsegr		0,iatt,1,0.05,0			;AMPLITUDE ENVELOPE
	asig		=		asig * aenv
	aL,aR		pan2		asig*gklevel,gkpan		;scale amplitude level and create stereo panned signal
			outs		aL*(1-gkRvbSize), aR*(1-gkRvbSize)		;SEND AUDIO TO THE OUTPUTS
	gasendL		=		gasendL+aL*gkRvbMix
	gasendR		=		gasendR+aR*gkRvbMix
	gkNoteTrig	=	0					;reset new-note trigger (in case it was '1')
endin

instr	5	;reverb
	if gkRvbMix==0 kgoto SKIP_REVERB
	aL,aR	reverbsc	gasendL,gasendR,gkRvbSize,12000
		outs		aL,aR
		clear		gasendL,gasendR
	SKIP_REVERB:
endin

</CsInstruments>

<CsScore>
;i "UpdateTableNumbers" 0 3600
i 1 0 3600			;reverb
i 5 0 3600			;reverb
</CsScore>

</CsoundSynthesizer>