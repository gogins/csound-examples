distort.csd
Written by Iain McCurdy, 2009

<CsoundSynthesizer>

<CsOptions>
-odac -dm0
</CsOptions>

<CsInstruments>

sr 		= 	44100	;SAMPLE RATE
ksmps 		= 	4	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 		= 	1	;NUMBER OF CHANNELS (2=STEREO)
0dbfs		=	1	;MAXIMUM AMPLITUDE

;FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLcolor	255, 255, 255, 0, 0, 0	;SETUP BASIC COLOURS
;			LABEL     | WIDTH | HEIGHT | X | Y
		FLpanel	"distort",   500,    325,    0,  0

;SWITCHES  	                                  		ON | OFF | TYPE | WIDTH | HEIGHT | X | Y | OPCODE | INS | STARTTIM | DUR
gkOnOff,ihOnOff			FLbutton	"On/Off",	1,    0,    22,    100,     25,    5,  5,     0,     1,      0,      3600

FLsetColor2	255, 255, 50, ihOnOff	;SET SECONDARY COLOUR TO YELLOW

;VALUE DISPLAY BOXES	LABEL | WIDTH | HEIGHT | X | Y
iddist      	FLvalue	" ",	 70,      20,    5,  75
idhp		FLvalue	" ",	 70,      20,    5, 125
idoutgain	FLvalue	" ",	 70,      20,    5, 300

;SLIDERS     				LABEL                 	MIN   | MAX | EXP | TYPE |  DISP      | WIDTH | HEIGHT | X  | Y
gkdist, ihdist		FLslider	"Distortion Amount",    0,         2,   0,   23,   iddist,       490,    25,     5,   50
gkhp,ihhp		FLslider	"Half Point (i-rate)",	0.0001,20000,  -1,   23,   idhp,         490,    25,     5,  100
gkoutgain,ihoutgain	FLslider	"Output Gain",		0.0001,   50,  -1,   23,   idoutgain,    490,    25,     5,  275

;GENERAL_TEXT_SETTINGS			SIZE | FONT |  ALIGN | RED | GREEN | BLUE
			FLlabel		13,      4,      1,    255,   255,   255		;LABELS MADE INVISIBLE (I.E. SAME COLOR AS PANEL)

;BUTTON BANKS				 TYPE | NUMX | NUMY | WIDTH | HEIGHT | X | Y | OPCODE
gkfn, ihfn		FLbutBank	 13,     1,     6,      18,    120,   370,150,   -1
gkinput, ihinput	FLbutBank	 13,     1,     3,      18,     60,    70,150,   -1

;GENERAL_TEXT_SETTINGS			SIZE | FONT |  ALIGN | RED | GREEN | BLUE
			FLlabel		13,      4,      3,     0,     0,     0			;LABELS MADE VISIBLE AGAIN

;TEXT BOXES						TYPE | FONT | SIZE | WIDTH | HEIGHT | X |  Y
ih		 	FLbox  	"Input:",		1,       6,    12,    50,      25,    12, 147
ih		 	FLbox  	"Drum Loop       ", 	1,       5,    12,   120,      25,    90, 147
ih		 	FLbox  	"Classical Guitar", 	1,       5,    12,   120,      25,    90, 167
ih		 	FLbox  	"Sine            ", 	1,       5,    12,   120,      25,    90, 187
ih		 	FLbox  	"Function:",		1,       6,    12,    50,      25,   312, 147
ih		 	FLbox  	"Sawtooth Up ", 	1,       5,    12,    95,      25,   390, 147
ih		 	FLbox  	"Sine Tone   ", 	1,       5,    12,    95,      25,   390, 167
ih		 	FLbox  	"Odd Partials", 	1,       5,    12,    95,      25,   390, 187
ih		 	FLbox  	"Noise       ", 	1,       5,    12,    95,      25,   390, 207
ih		 	FLbox  	"Half Sine   ", 	1,       5,    12,    95,      25,   390, 227
ih		 	FLbox  	"Square Wave ", 	1,       5,    12,    95,      25,   390, 247

;SLIDERS     				LABEL		MIN   | MAX | EXP | TYPE | DISP | WIDTH | HEIGHT | X  | Y
gkfreq, ihfreq		FLslider	"Freq.",    	20,    2000,   -1,   23,    -1,    120,    12,    140, 195

;SET INITIAL VALUES FOR SLIDERS |VALUE | HANDLE
		FLsetVal_i	0.5,    ihdist
		FLsetVal_i	2,      ihhp
		FLsetVal_i	2,      ihfn
		FLsetVal_i	2,      ihoutgain
		FLsetVal_i	200,    ihfreq

		FLpanel_end	;END OF PANEL CONTENTS

;INSTRUCTIONS AND INFO PANEL                 WIDTH | HEIGHT | X | Y
				FLpanel	" ", 500,     200,   512, 0
;TEXT BOXES												TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                          distort                            ", 	1,      5,     14,    490,    15,     5,  0
ih		 	FLbox  	"-------------------------------------------------------------", 	1,      5,     14,    490,    15,     5,  20
ih		 	FLbox  	"The 'distort' opcode performs waveshaping and clipping on an ", 	1,      5,     14,    490,    15,     5,  40
ih		 	FLbox  	"audio signal according to a waveform supplied by the user.   ", 	1,      5,     14,    490,    15,     5,  60
ih		 	FLbox  	"In this example I have provided six waveform functions to    ", 	1,      5,     14,    490,    15,     5,  80
ih		 	FLbox  	"provide some ideas.                                          ", 	1,      5,     14,    490,    15,     5, 100
ih		 	FLbox  	"'Half Point' provides the half point of an internal low-pass ", 	1,      5,     14,    490,    15,     5, 120
ih		 	FLbox  	"filter in cycles per second.                                 ", 	1,      5,     14,    490,    15,     5, 140
ih		 	FLbox  	"An output gain control can be used to compensate for a loss  ", 	1,      5,     14,    490,    15,     5, 160
ih		 	FLbox  	"in power when half point is low and distortion level is high.", 	1,      5,     14,    490,    15,     5, 180
				FLpanel_end
                                                                                        
				FLrun	;RUN THE FLTK WIDGET THREAD
;END OF FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


0dbfs	=	1	;MAXIMUM AMPLITUDE WILL BE 1

;WAVESHAPING FUNCTIONS
gifn1	ftgen	1,0,128,7,-1,128,1		;SAWTOOTH UP
gifn2	ftgen	2,0,128,10,1			;SINE WAVE
gifn3	ftgen	3,0,128,10,1,0,1,0,1,0,1,0,1	;ODD PARTIALS
gifn4	ftgen	4,0,128,21,1			;WHITE NOISE
gifn5	ftgen	5,0,128,9,.5,1,0		;HALF SINE
gifn6	ftgen	6,0,128,7,1,64,1,0,-1,64,-1	;SQUARE WAVE
gisine	ftgen	0,0,4096,10,1

instr	1		;DISTORT INSTRUMENT
	if gkOnOff=0	then		;...IF 'On/Off' BUTTON IS 'OFF'...
		turnoff			;...TURNOFF THIS INSTRUMENT IMMEDIATLEY
	endif				;END OF CONDIIONAL BRANCHING
	if gkinput==0 then
	 asig		diskin2		"808loopMono.wav", 1, 0, 1
	elseif gkinput==1 then
	 asig,ar		diskin2 		"ClassicalGuitar.wav", 1, 0, 1
	else
	 asig	oscili	0.5,gkfreq,gisine
	endif

	kSwitch		changed		gkhp, gkfn	;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then	;IF A VARIABLE CHANGE INDICATOR IS RECEIVED...
		reinit	START		;...BEGIN A REINITIALISATION PASS FROM LABEL 'START' 
	endif				;END OF CONDITIONAL BRANCHING
	START:				;LABEL
	ar 		distort asig, gkdist, i(gkfn)+1, i(gkhp);, istor]
	rireturn			;RETURN TO PERFORMANCE PASSES FROM INITIALISATION PASS
			out		ar * gkoutgain	;SEND AUDIO TO OUTPUTS AND MULTIPLY BY OUTPUT GAIN FLTK SLIDER
endin
		
</CsInstruments>

<CsScore>
f 0 3600	;DUMMY SCORE EVENT
</CsScore>

</CsoundSynthesizer>