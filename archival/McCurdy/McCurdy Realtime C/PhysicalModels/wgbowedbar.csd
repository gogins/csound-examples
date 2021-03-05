;Written by Iain McCurdy, 2006

;BOWED BAR PHYSICAL MODEL - RATHER UNSTABLE

<CsoundSynthesizer>

<CsOptions>
-odevaudio -b400 -M0 -+rtmidi=virtual
</CsOptions>

<CsInstruments>

sr 		= 	44100	;SAMPLE RATE
kr 		= 	441	;CONTROL RATE
ksmps 		= 	100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 		= 	2	;NUMBER OF CHANNELS (2=STEREO)

;FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLcolor	255, 255, 255, 0, 0, 0

;			LABEL |      WIDTH | HEIGHT | X | Y
		FLpanel	"wgbowedbar", 500,    500,    0,  0

;				FLBUTBANK 	TYPE | NUMX | NUMY | WIDTH | HEIGHT | X | Y | IOPCODE | P1 | P2 | P3
gkFLTK_MIDI, ihFLTK_MIDI	FLbutBank	4,      1,     2,     20,      40,    5,  5,     0,     2,    0,  -1
;TEXT BOXES					TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"MIDI", 	1,      6,     17,     50,     20,   23,   4
ih		 	FLbox  	"FLTK", 	1,      6,     17,     50,     20,   23,  24

;VALUE DISPLAY BOXES	LABEL  | WIDTH | HEIGHT | X |  Y
idamp		FLvalue	" ",      80,      18,    5,   75
idfreq		FLvalue	" ",      80,      18,    5,  125
idpos		FLvalue	" ",      80,      18,    5,  175
idbowpres	FLvalue	" ",      80,      18,    5,  225
idgain		FLvalue	" ",      80,      18,    5,  275
idconst		FLvalue	" ",      80,      18,    5,  325
idbowpos	FLvalue	" ",      80,      18,    5,  425
idlow		FLvalue	" ",      80,      18,    5,  475

;SLIDERS				            						MIN |   MAX  | EXP | TYPE |  DISP    | WIDTH | HEIGHT | X  | Y
gkamp, ihamp			FLslider	"Amplitude",					0,    30000,    0,    23,   idamp,      490,     25,    5,   50
gkfreq, ihfreq			FLslider	"Frequency",					20,   20000,   -1,    23,   idfreq,     490,     25,    5,  100
gkpos, ihpos			FLslider	"Bow Position On Bar",				0,        1,    0,    23,   idpos,      490,     25,    5,  150
gkbowpres, ihbowpres		FLslider	"Bow Pressure",					1,        5,    0,    23,   idbowpres,  490,     25,    5,  200
gkgain,ihgain			FLslider 	"Gain Of Filter",  				.8,       2,    0,    23,   idgain,     490,     25,    5,  250
gkconst,ihconst			FLslider 	"Integration Constant",				-1,       1,    0,    23,   idconst,    490,     25,    5,  300
gkbowpos,ihbowpos		FLslider 	"Bow Position Affecting Velocity Trajectory",	-1,       1,    0,    23,   idbowpos,   490,     25,    5,  400
gklow,ihlow			FLslider 	"Lowest Frequency Required",			0,     2000,    0,    23,   idlow,      490,     25,    5,  450

;COUNTERS							MIN | MAX | STEP1 | STEP2 | TYPE | WIDTH | HEIGHT | X | Y | OPCODE 
gktvel, ihtvel	FLcount  "Bow Velocity: 0=ADSR 1=Exponential",	0,     1,    1,       1,     2,     235,     30,   150,350,   -1


;SET_INITIAL_VALUES		VALUE | HANDLE
		FLsetVal_i	10000, 	ihamp
		FLsetVal_i	400, 	ihfreq
		FLsetVal_i	.7, 	ihpos
		FLsetVal_i	3,	ihbowpres
		FLsetVal_i	.95, 	ihgain
		FLsetVal_i	0.2, 	ihconst
		FLsetVal_i	0, 	ihtvel
		FLsetVal_i	0, 	ihbowpos
		FLsetVal_i	0, 	ihlow

		FLpanel_end

;INSTRUCTIONS AND INFO PANEL
				FLpanel	" ", 500, 240, 512, 0
;TEXT BOXES												TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                       wgbowedbar                            ", 	1,      5,     14,    490,     20,    5,   0
ih		 	FLbox  	"-------------------------------------------------------------", 	1,      5,     14,    490,     20,    5,  20
ih		 	FLbox  	"wgbowedbar is a wave guide physical model of a bowed bar     ", 	1,      5,     14,    490,     20,    5,  40
ih		 	FLbox  	"based on work by Perry Cook but re-coded for Csound by John  ", 	1,      5,     14,    490,     20,    5,  60
ih		 	FLbox  	"ffitch.                                                      ", 	1,      5,     14,    490,     20,    5,  80
ih		 	FLbox  	"The results from experimentation with this example can be    ", 	1,      5,     14,    490,     20,    5, 100
ih		 	FLbox  	"unpredictable with 'exploding' feedback loops a common       ", 	1,      5,     14,    490,     20,    5, 120
ih		 	FLbox  	"occurence. It is recommended that you proceed with caution in", 	1,      5,     14,    490,     20,    5, 140
ih		 	FLbox  	"order to protect your ears and speakers.                     ", 	1,      5,     14,    490,     20,    5, 160
ih		 	FLbox  	"Interesting results are possible although I'm not sure       ", 	1,      5,     14,    490,     20,    5, 180
ih		 	FLbox  	"whether anything that really resembles the sound of a bowed  ", 	1,      5,     14,    490,     20,    5, 200
ih		 	FLbox  	"bar is possible.                                             ", 	1,      5,     14,    490,     20,    5, 220
		FLpanel_end

				FLrun	;RUN THE FLTK WIDGET THREAD
;END OF FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

instr	1	;MIDI INPUT INSTRUMENT
	if	gkFLTK_MIDI=1	then	;IF FLTK/MIDI SWITCH IS SET TO 'FLTK'...
		turnoff			;TURN THIS INSTRUMENT OFF
	endif				;END OF CONDITIONAL BRANCHING
	icps	cpsmidi			;READ CYCLES PER SECOND VALUE FROM MIDI INPUT
	iamp	ampmidi	1		;READ IN A NOTE VELOCITY VALUE FROM THE MIDI INPUT
	;				P1 | P4 | P5
	aoutL, aoutR	subinstr	2,  icps, iamp	;ACTIVATE A SUB-INSTRUMENT
		outs	aoutL, aoutR	;SEND AUDIO TO SPEAKERS
endin

instr	2		;wgbowedbar INSTRUMENT
	kactive1	active	1	;SENSE NUMBER OF ACTIVE INSTANCES OF INSTRUMENT 1 (I.E. MIDI ACTIVATED INSTRUMENT) 
	if	gkFLTK_MIDI=0&&kactive1=0	then	;IF FLTK/MIDI SWITCH IS SET TO 'MIDI' AND NO MIDI NOTES ARE ACTIVE...
		turnoff					;TURN THIS INSTRUMENT
	endif						;END OF CONDITIONAL BRANCHING
	if	gkFLTK_MIDI = 1	then			;IF FLTK/MIDI SWITCH IS SET TO 'FLTK'...
		kamp = gkamp			;SET kamp TO FLTK SLIDER VALUE gkamp
		kfreq = gkfreq			;SET FUNDEMENTAL TO FLTK SLIDER gkfund
	else						;OTHERWISE...
		kfreq = p4				;SET FUNDEMENTAL TO RECEIVED p4 RECEIVED FROM INSTR 1. I.E. MIDI PITCH
		kamp = p5 * gkamp			;SET AMPLITUDE TO RECEIVED p5 RECEIVED FROM INSTR 1 (I.E. MIDI VELOCITY) MULTIPLIED BY FLTK SLIDER gkamp.
	endif						;END OF CONDITIONAL BRANCHING

	kSwitch		changed		gkconst, gktvel, gkbowpos, gklow
	if	kSwitch=1	then		;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	UPDATE			;BEGIN A REINITIALISATION PASS FROM LABEL 'UPDATE'
	endif
	UPDATE:
	abowedbar      	wgbowedbar 	kamp, kfreq, gkpos, gkbowpres, gkgain, i(gkconst), i(gktvel), i(gkbowpos), i(gklow)
	rireturn	;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
	aenv	linsegr	1, 0.05, 0		;ANTI-CLICK ENVELOPE
	outs 		abowedbar * aenv, abowedbar * aenv
endin

</CsInstruments>

<CsScore>
f 0 3600	;DUMMY SCORE EVENT SUSTAINS REALTIME PERFORMANCE FOR 1 HOUR
</CsScore>

</CsoundSynthesizer>