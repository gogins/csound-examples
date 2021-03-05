CsoundIsListening.csd
WRITTEN BY IAIN MCCURDY, 2011

This example exemplifies the technique of opcode iteration using UDOs to create a mass of oscillators using a small amount of code.
This technique is introduced and explained in detail by Steven Yi in his article 'Control Flow - Part II' in the summer 2006 issue of the Csound Journal (http://www.csounds.com/journal/2006summer/controlFlow_part2.html).

In this example 100 vco2 oscillators are created but you can change this number in instrument 1 if you like, increasing it if your system permits it in realtime.
Each oscillator exhibits its own unique behaviour in terms of its pitch, pulse width and panning.
The entire mass morphs from a state in which the oscillator pitches slowly glide about randomly to a state in which they hold a fixed pitch across a range of octaves.

Some commercial synthesizers offer oscillators called 'mega-saws' or something similar. These are normally just clusters of detuned sawtooth waveforms so this is the way in which this could be emulated in Csound.

The example emulates a familiar sound ident. It is for educational purposes and no breach of copyright is intended.

<CsoundSynthesizer>

<CsOptions>
-odac -dm0
</CsOptions>

<CsInstruments>
sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1	;MAXIMUM AMPLITUDE

;FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLcolor	255, 255, 255, 0, 0, 0
;		LABEL         | WIDTH | HEIGHT | X | Y
	FLpanel	"times timek",   500,    130,    0,  0
;                                                      ON | OFF | TYPE | WIDTH | HEIGHT | X | Y | OPCODE | INS | STARTTIM | IDUR
gkOnOff,ihOnOff	FLbutton	"On/Off",		1,   0,    22,    140,     30,    5,  5,    0,      1,      0,       -1
gkExit,ihExit	FLbutton	"Exit",			1,   0,    21,    140,     30,  345,  5,    0,    999,      0,       0.001
FLsetColor2	255, 255, 50, ihOnOff		;SET SECONDARY COLOUR TO YELLOW

;VALUE DISPLAY BOXES						WIDTH | HEIGHT | X |  Y
gidtimes			FLvalue	"Time (secs.)",     	 120,     25,   120,  60
gidtimek			FLvalue	"Time (k-cycles)",     	 120,     25,   260,  60

FLsetVal_i	1,ihOnOff
			FLpanel_end

;INSTRUCTIONS AND INFO PANEL
				FLpanel	" ", 500, 220, 512, 0
;TEXT BOXES												TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                         times timek                         ", 	1,      5,     14,    490,    20,     5,   0
ih		 	FLbox  	"-------------------------------------------------------------", 	1,      5,     14,    490,    20,     5,  20
ih		 	FLbox  	"'times' and 'timek' are very similar to 'timeinsts' and      ", 	1,      5,     14,    490,    20,     5,  40
ih		 	FLbox  	"'timeinstk' except that instead of providing measures of time", 	1,      5,     14,    490,    20,     5,  60
ih		 	FLbox  	"since a note began they measure time since the Csound        ", 	1,      5,     14,    490,    20,     5,  80
ih		 	FLbox  	"performance began. Therefore the clocks that they use        ", 	1,      5,     14,    490,    20,     5, 100
ih		 	FLbox  	"continue to increment even when no instruments are active.   ", 	1,      5,     14,    490,    20,     5, 120
ih		 	FLbox  	"'times' measures time in seconds, 'timek' measures time in   ", 	1,      5,     14,    490,    20,     5, 140
ih		 	FLbox  	"terms of the number of elapsed control cycles.               ", 	1,      5,     14,    490,    20,     5, 160
ih		 	FLbox  	"In this example kr=100 so that after 1 second of performance ", 	1,      5,     14,    490,    20,     5, 180
ih		 	FLbox  	"time, the k-cycle clock will output a value of 100 and so on.", 	1,      5,     14,    490,    20,     5, 200

			FLpanel_end

;			FLrun	;RUN THE FLTK WIDGET THREAD


;INITIALISE REVERB SEND VARIABLES
gasendL	init	0
gasendR	init	0

;DEFINE A UDO FOR AN OSCILLATOR VOICE
opcode	vcomodule, aa, ii										;DEFINE OPCODE FORMAT
	icount,inum  xin										;DEFINE NAMES FOR INPUT ARGUMENTS
	kvar	jspline	15,0.1,0.2									;RANDOM JITTERING OF PITCH
	kpw	rspline	0.05,0.5,0.4,0.8								;RANDOM MOVEMENT OF PULSE WIDTH FOR vco2
	imorphtime	random	5.5,6.5									;TIME TO MORPH FROM GLIDING PITCHES TO STATIC PITCHES WILL DIFFER SLIGHTLY FROM VOICE TO VOICE
	kxfade	linseg	0,7, 0,imorphtime, 0.999,2, 0.999						;FUNCTION DEFINING MORPH FROM GLIDING TO STATIC VOICES IS CREATED				
	ioct	wrap	icount,0,8									;BASIC OCTAVE FOR EACH VOICE IS DERIVED FROM VOICE COUNT NUMBER (WRAPPED BETWEEN 0 AND 8 TO PREVENT RIDICULOUSLY HIGH TONES)
	iinitoct	random	0,2									;DEFINES THE SPREAD OF VOICES DURING THE GLIDING VOICES SECTION
	kcps	ntrpol	200*semitone(kvar)*octave(iinitoct),cpsoct(3+ioct+octpch(0.025)),kxfade		;PITCH (IN CPS) OF EACH VOICE - MORPHING BETWEEN A RANDOMLY GLIDING STAGE AND A STATIC STAGE
	koct	=	octcps(kcps)									;PITCH CONVERTED TO OCT FORMAT
	kdb	=	(5-koct)*4									;DECIBEL VALUE DERIVED FROM OCT VALUE - THIS WILL BE USED FOR 'AMPLITUDE SCALING' TO PREVENT EMPHASIS OF HIGHER PITCHED TONES
	a1	vco2	ampdb(kdb)*(1/(inum^0.5)),kcps,4,kpw,0							;THE OSCILLATOR IS CREATED
	kPanDep	linseg	0,5,0,6,0.5									;RANDOM PANNING DEPTH WILL MOVE FROM ZERO (MONOPHONIC) TO FULL STEREO AT THE END OF THE NOTE
	kpan	rspline 0.5+kPanDep,0.5-kPanDep,0.3,0.5							;RANDOM PANNING FUNCTION
	aL,aR	pan2	a1,kpan										;MONO OSCILLATOR IS RANDOMLY PANNED IN A SMOOTH GLIDING MANNER
	icount	=	icount + 1									;INCREMENT VOICE COUNT COUNTER
	amixL,amixR	init	0
	if	icount <= inum	then									;IF TOTAL VOICE LIMIT HAS NOT YET BEEN REACHED...
		amixL,amixR	vcomodule	icount, inum						;...CALL THE UDO AGAIN (WITH THE INCREMENTED COUNTER)
	endif												;END OF THIS CONDITIONAL BRANCH
		xout	amixL+a1,amixR+aR
endop

instr	1
	prints	"See .csd for explanation..."
	inum	=		10								;NUMBER OF VOICES
	icount	init		0								;INITIALISE VOICE COUNTER
	aoutL,aoutR	vcomodule	icount,inum							;CALL vcomodule UDO (SUBSEQUENT CALLS WILL BE MADE WITHIN THE UDO ITSELF)
		aoutL	dcblock	aoutL								;REMOVE DC OFFSET FROM AUDIO (LEFT CHANNEL)
		aoutR	dcblock	aoutR								;REMOVE DC OFFSET FROM AUDIO (RIGHT CHANNEL)
		kenv		linseg	-90,(1), -50,(6), -20,(6), 0,(p3-16),  0,(3), -90	;AMPLITUDE ENVELOPE THAT WILL BE APPLIED TO THE MIX OF ALL VOICES
		aoutL	=	aoutL*ampdb(kenv)						;APPLY ENVELOPE (LEFT CHANNEL)
		aoutR	=	aoutR*ampdb(kenv)						;APPLY ENVELOPE (RIGHT CHANNEL)
		outs		aoutL,aoutR							;SEND AUDIO TO OUTPUTS
		gasendL	=	gasendL+(aoutL*0.5)						;MIX SOME AUDIO INTO THE REVERB SEND VARIABLE (LEFT CHANNEL)
		gasendR	=	gasendR+(aoutR*0.5)						;MIX SOME AUDIO INTO THE REVERB SEND VARIABLE (RIGHT CHANNEL)
endin

instr	2	;REVERB INSTRUMENT
	aRvbL,aRvbR	reverbsc	gasendL,gasendR,0.82,10000
	outs	aRvbL,aRvbR
	clear	gasendL,gasendR
endin
</CsInstruments>

<CsScore>
i 1 0 20	;SYNTH VOICES GENERATING INSTRUMENT
i 2 0 25	;REVERB INSTRUMENT
</CsScore>

</CsoundSynthesizer>