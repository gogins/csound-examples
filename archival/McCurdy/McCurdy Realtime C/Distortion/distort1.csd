distort1.csd
Written by Iain McCurdy, 2006

<CsoundSynthesizer>

<CsOptions>
-odac -dm0
</CsOptions>

<CsInstruments>

sr 		= 	44100	;SAMPLE RATE
ksmps 		= 	10	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 		= 	2	;NUMBER OF CHANNELS (2=STEREO)

;FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLcolor	255, 255, 255, 0, 0, 0
;			LABEL      | WIDTH | HEIGHT | X | Y
		FLpanel	"Distort1",   500,    250,    0,  0

;SWITCHES  	                                  	ON | OFF | TYPE | WIDTH | HEIGHT | X | Y | OPCODE | INS | STARTTIM | DUR
gkOnOff,ihOnOff	FLbutton	"On/Off",		1,    0,    22,    100,     25,    5,  5,     0,     1,      0,      -1
FLsetColor2	255, 255, 50, ihOnOff	;SET SECONDARY COLOUR TO YELLOW

;VALUE DISPLAY BOXES	LABEL | WIDTH | HEIGHT | X | Y
idpregain      	FLvalue	" ",	 70,      20,    5,  75
idpostgain	FLvalue	" ",	 70,      20,    5, 125
idshape1	FLvalue	" ",	 70,      20,    5, 175
idshape2	FLvalue	" ",	 70,      20,    5, 225

;            				LABEL                 | MIN | MAX | EXP | TYPE |  DISP      | WIDTH | HEIGHT | X  | Y
gkpregain, ihpregain	FLslider	"Pregain",               0,   100,   0,    23,   idpregain,    490,    25,     5,  50
gkpostgain,ihpostgain	FLslider	"Postgain",              .001,  1,  -1,    23,   idpostgain,   490,    25,     5, 100
gkshape1,  ihshape1	FLslider	"Shape 1",               0,     1,   0,    23,   idshape1,     490,    25,     5, 150
gkshape2,  ihshape2	FLslider	"Shape 2",               0,     1,   0,    23,   idshape2,     490,    25,     5, 200

;SET INITIAL VALUES FOR SLIDERS |VALUE | HANDLE
		FLsetVal_i	10, ihpregain	
		FLsetVal_i	.4, ihpostgain	
		FLsetVal_i	0, ihshape1	
		FLsetVal_i	0, ihshape2	

		FLpanel_end	;END OF PANEL CONTENTS

;INSTRUCTIONS AND INFO PANEL                 WIDTH | HEIGHT | X | Y
				FLpanel	" ", 500,     340,   512, 0
;TEXT BOXES												TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                          distort1                           ", 	1,      5,     14,    490,    15,     5,  0
ih		 	FLbox  	"-------------------------------------------------------------", 	1,      5,     14,    490,    15,     5,  20
ih		 	FLbox  	"Distort1 implements modified hyperbolic tangent distortion.  ", 	1,      5,     14,    490,    15,     5,  40
ih		 	FLbox  	"Distort1 can be used to generate wave shaping distortion     ", 	1,      5,     14,    490,    15,     5,  60
ih		 	FLbox  	"based on a modification of the tanh function.                ", 	1,      5,     14,    490,    15,     5,  80
ih		 	FLbox  	"'Pregain' determines the amount of gain that is applied to   ", 	1,      5,     14,    490,    15,     5, 100
ih		 	FLbox  	"the audio signal before waveshaping. A value of 1 gives a    ", 	1,      5,     14,    490,    15,     5, 120
ih		 	FLbox  	"slight distortion. 'Postgain' controls the gain of the signal", 	1,      5,     14,    490,    15,     5, 140
ih		 	FLbox  	"after waveshaping. Increasing 'pregain' increases the amount ", 	1,      5,     14,    490,    15,     5, 160
ih		 	FLbox  	"of distortion of the signal. High values for 'pregain' may   ", 	1,      5,     14,    490,    15,     5, 180
ih		 	FLbox  	"require compensating low values for 'postgain' in order to   ", 	1,      5,     14,    490,    15,     5, 200
ih		 	FLbox  	"prevent csound producing samples out of range.               ", 	1,      5,     14,    490,    15,     5, 220
ih		 	FLbox  	"'Shape 1' shapes the positive part of the signal. A value of ", 	1,      5,     14,    490,    15,     5, 240
ih		 	FLbox  	"zero produces flat clipping of the positive part of the      ", 	1,      5,     14,    490,    15,     5, 260
ih		 	FLbox  	"signal. Values slightly above zero produce sloped shaping.   ", 	1,      5,     14,    490,    15,     5, 280
ih		 	FLbox  	"'Shape 2' gives similar shaping control of the negative part ", 	1,      5,     14,    490,    15,     5, 300
ih		 	FLbox  	"of the signal.                                               ", 	1,      5,     14,    490,    15,     5, 320

				FLpanel_end

				FLrun	;RUN THE FLTK WIDGET THREAD
;END OF FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

instr 1
	if	gkOnOff=0	then	;IF ON/OFF SWITCH IS OFF...
		turnoff			;TURN THIS INSTRUMENT OFF
	endif				;END OF CONDITIONAL BRANCHING
	asigL, asigR	diskin2		"808loop.wav", 1, 0, 1	;AUDIO SIGNAL READ FROM DISC
	adistortL	distort1	asigL, gkpregain, gkpostgain, gkshape1, gkshape2	;CREATE 'distort1' SIGNAL
	adistortR	distort1	asigR, gkpregain, gkpostgain, gkshape1, gkshape2	;CREATE 'distort1' SIGNAL
			outs		adistortL, adistortR					;SEND AUDIO TO OUTPUTS
endin
		
</CsInstruments>

<CsScore>
f 0 3600
</CsScore>

</CsoundSynthesizer>