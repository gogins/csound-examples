fof.csd
Written by Iain McCurdy, 2009

<CsoundSynthesizer>

<CsOptions>
-odac -dm0 -M0 -+rtmidi=virtual
</CsOptions>

<CsInstruments>

sr 		= 	44100	;SAMPLE RATE
ksmps 		= 	32	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 		= 	2	;NUMBER OF CHANNELS (2=STEREO)
0dbfs		=	1	;MAXIMUM AMPLITUDE

;FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLcolor	255, 255, 255, 0, 0, 0	;SET INTERFACE COLOURS
;			LABEL | WIDTH | HEIGHT | X | Y
		FLpanel	"fof",   500,     680,   0,  0

;SWITCHES                       				ON | OFF | TYPE | WIDTH | HEIGHT | X | Y | OPCODE | INS | STARTTIM | IDUR
gkOnOff,ihOnOff		FLbutton	"On/Off",		1,    0,    22,    150,     25,    5,  5,    0,      1,      0,      -1
FLsetColor2	255, 255, 50, ihOnOff		;SET SECONDARY COLOUR TO YELLOW

;NUMBER DISPLAY BOXES			WIDTH | HEIGHT | X | Y
idamp			FLvalue	" ",	80,      20,     5,  75
idoct			FLvalue	" ",	80,      20,     5, 455
idband			FLvalue	" ",	80,      20,     5, 505
iddur			FLvalue	" ",	80,      20,     5, 555
idris			FLvalue	" ",	80,      20,     5, 605
iddec			FLvalue	" ",	80,      20,     5, 655

;SLIDERS					      		MIN | MAX | EXP | TYPE |  DISP   | WIDTH | HEIGHT | X   | Y
gkamp, ihamp		FLslider	"Amplitude",  		0,       1,  0,    23,    idamp,     490,     25,    5,    50
gkoct, ihoct		FLslider	"Octaviation Factor",	0,       8,  0,    23,    idoct,     490,     25,    5,   430
gkband, ihband		FLslider	"Bandwidth",		0,     100,  0,    23,    idband,    490,     25,    5,   480
gkdur, ihdur		FLslider	"Duration",		.017,    1,  0,    23,    iddur,     490,     25,    5,   530
gkris, ihris		FLslider	"Rise Time",		.001,  .05,  0,    23,    idris,     490,     25,    5,   580
gkdec, ihdec		FLslider	"Decay Time",		.001,  .05,  0,    23,    iddec,     490,     25,    5,   630

;NUMBER DISPLAY BOXES			WIDTH | HEIGHT | X | Y
idfund			FLvalue	"Fund.",70,      20,     5,  380
idform			FLvalue	"Form.",70,      20,   420,  380

;XY PANELS									MINX | MAXX | MINY | MAXY | EXPX | EXPY | DISPX | DISPY | WIDTH | HEIGHT | X | Y
gkfund, gkform, ihfund, ihform	FLjoy	"X - Fundemental  Y - Formant",	1,     5000,   20,   5000,   -1,    -1,  idfund, idform,   490,    280,    5, 100
FLsetColor2	255, 0, 0, ihfund		;SET SECONDARY COLOUR TO RED
FLsetColor2	255, 0, 0, ihform		;SET SECONDARY COLOUR TO RED

; INITIALISATION OF SLIDERS	VALUE | HANDLE
		FLsetVal_i	0.3, 	ihamp
		FLsetVal_i	60, 	ihfund
		FLsetVal_i	1200, 	ihform
		FLsetVal_i	0, 	ihoct
		FLsetVal_i	50, 	ihband
		FLsetVal_i	.1, 	ihdur
		FLsetVal_i	.003, 	ihris
		FLsetVal_i	.007, 	ihdec

		FLpanel_end	;END OF PANEL CONTENTS

;INSTRUCTIONS AND INFO PANEL

				FLpanel	" ", 515, 700, 512, 0
				FLscroll     515, 700, 0, 0
;TEXT BOXES												TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                            fof                              ", 	1,      5,     14,    490,    20,     5,  0
ih		 	FLbox  	"-------------------------------------------------------------", 	1,      5,     14,    490,    20,     5,  20
ih		 	FLbox  	"FOF (fonction d'onde formantique) is a rather specialised    ", 	1,      5,     14,    490,    20,     5,  40
ih		 	FLbox  	"type of granular synthesis in that its intended use is the   ", 	1,      5,     14,    490,    20,     5,  60
ih		 	FLbox  	"creation of vocal vowel sounds through the use of rapidly    ", 	1,      5,     14,    490,    20,     5,  80
ih		 	FLbox  	"repeated sine wave grains. (The should not be viewed as a    ", 	1,      5,     14,    490,    20,     5, 100
ih		 	FLbox  	"restriction upon it being used less conventionally.)         ", 	1,      5,     14,    490,    20,     5, 120
ih		 	FLbox  	"If the user starts this example the first thing that is heard", 	1,      5,     14,    490,    20,     5, 140
ih		 	FLbox  	"is a stream of repeated pulses in which each pulse is easily ", 	1,      5,     14,    490,    20,     5, 160
ih		 	FLbox  	"discernible. The pitch of each grain is just about           ", 	1,      5,     14,    490,    20,     5, 180
ih		 	FLbox  	"discernible.                                                 ", 	1,      5,     14,    490,    20,     5, 200
ih		 	FLbox  	"If the 'Formant' slider is moved it is heard that the pitch  ", 	1,      5,     14,    490,    20,     5, 220
ih		 	FLbox  	"of each grain is modulated.                                  ", 	1,      5,     14,    490,    20,     5, 240
ih		 	FLbox  	"If the 'Fundemental' slider is slowly moved from left to     ", 	1,      5,     14,    490,    20,     5, 260
ih		 	FLbox  	"right it is heard that the frequency of grain repetition     ", 	1,      5,     14,    490,    20,     5, 280
ih		 	FLbox  	"increases. As we pass about 35 hertz we are no longer able   ", 	1,      5,     14,    490,    20,     5, 300
ih		 	FLbox  	"distinguish individual grains and instead a new tone emerges ", 	1,      5,     14,    490,    20,     5, 320
ih		 	FLbox  	"which is a consequence of the periodically repeating         ", 	1,      5,     14,    490,    20,     5, 340
ih		 	FLbox  	"identical grains.                                            ", 	1,      5,     14,    490,    20,     5, 360
ih		 	FLbox  	"Keep 'Fundemental' at a highish value (say 200 Hz.) and now  ", 	1,      5,     14,    490,    20,     5, 380
ih		 	FLbox  	"move the 'Formant' slider. The effect this time is of a      ", 	1,      5,     14,    490,    20,     5, 400
ih		 	FLbox  	"bandpass filter being applied to the tone. A formant is      ", 	1,      5,     14,    490,    20,     5, 420
ih		 	FLbox  	"really just a peak of energy on a harmonic sound spectrum.   ", 	1,      5,     14,    490,    20,     5, 440
ih		 	FLbox  	"The phenomena just demonstrated are the fundemental          ", 	1,      5,     14,    490,    20,     5, 460
ih		 	FLbox  	"principles behind fof synthesis. To convincingly imitate     ", 	1,      5,     14,    490,    20,     5, 480
ih		 	FLbox  	"vowel sounds of the human voice about six simulataneous fof  ", 	1,      5,     14,    490,    20,     5, 500
ih		 	FLbox  	"signals are needed. The next example demonstrates this.      ", 	1,      5,     14,    490,    20,     5, 520
ih		 	FLbox  	"The amplitude envelope that is applied to each grain is      ", 	1,      5,     14,    490,    20,     5, 540
ih		 	FLbox  	"controlled by a combination of the 'Duration' (kdur), 'Rise  ", 	1,      5,     14,    490,    20,     5, 560
ih		 	FLbox  	"Time' (kris), 'Decay Time' (kdec) and 'Bandwidth' (kband).   ", 	1,      5,     14,    490,    20,     5, 580
ih		 	FLbox  	"Bandwidth controls how an exponential curve defined in a     ", 	1,      5,     14,    490,    20,     5, 600
ih		 	FLbox  	"separate function is applied to the decay of each grain.     ", 	1,      5,     14,    490,    20,     5, 620
ih		 	FLbox  	"'Octaviation Index' (koct) is typically zero but as it tends ", 	1,      5,     14,    490,    20,     5, 640
ih		 	FLbox  	"to 1 every other grain is increasingly attenuated. When it is", 	1,      5,     14,    490,    20,     5, 660
ih		 	FLbox  	"exactly 1 the grain density is effectively halved and the fof", 	1,      5,     14,    490,    20,     5, 680
ih		 	FLbox  	"fundemental is dropped by one octave. From 1 to 2 the process", 	1,      5,     14,    490,    20,     5, 700
ih		 	FLbox  	"is repeated and the density is halved again and so on from 2 ", 	1,      5,     14,    490,    20,     5, 720
ih		 	FLbox  	"to 3 and beyond. This effect is perceived quite differently  ", 	1,      5,     14,    490,    20,     5, 740
ih		 	FLbox  	"for dense and sparse textures.                               ", 	1,      5,     14,    490,    20,     5, 760
ih		 	FLbox  	"This example can also be played from a MIDI keyboard.        ", 	1,      5,     14,    490,    20,     5, 780

				FLscrollEnd
				FLpanel_end

				FLrun	;RUN THE FLTK WIDGET THREAD
;END OF FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gisine	ftgen	0, 0, 4096, 10, 1			;SINE WAVE
giexp	ftgen	0, 0, 1024, 19, 0.5, 0.5, 270, 0.5	;EXPONENTIAL CURVE

instr	1
	iporttime	=	.2			; CREATE A VARIABLE THAT WILL BE USED FOR PORTAMENTO TIME
	kporttime	linseg	0,0.001,iporttime	; CREATE A VARIABLE THAT WILL BE USED FOR PORTAMENTO TIME

	iMIDIActiveValue	=	1		;IF MIDI ACTIVATED
	iMIDIflag		=	0		;IF FLTK ACTIVATED
	mididefault	iMIDIActiveValue, iMIDIflag	;IF NOTE IS MIDI ACTIVATED REPLACE iMIDIflag WITH iMIDIActiveValue 
	icps	cpsmidi		;READ MIDI PITCH VALUES - THIS VALUE CAN BE MAPPED TO GRAIN DENSITY AND/OR PITCH DEPENDING ON THE SETTING OF THE MIDI MAPPING SWITCHES

	if	gkOnOff=0&&iMIDIflag=0	then ;SENSE FLTK ON/OFF SWITCH & WHETHER THIS IS A MIDI NOTE ITS STATUS WILL BE IGNORED
				turnoff	;TURNOFF THIS INSTRUMENT IMMEDIATELY
	endif

	if iMIDIflag=1 then	;IF THIS IS A MIDI ACTIVATED NOTE AND MIDI-TO-DENSITY SWITCH IS ON... 
		kfund	=	icps		;MAP TO MIDI NOTE VALUE TO DENSITY
	else					;OTHERWISE...
		kfund		portk	gkfund, kporttime	;USE THE FLTK SLIDER VALUE
	endif					;END OF THIS CONDITIONAL BRANCH

	kamp	portk	gkamp, kporttime	;APPLY PORTAMENTO TO SELECTED FLTK SLIDER VARIABLE AND CREATE NEW NON-GLOBAL VARIABLES TO BE USED BY THE FOF OPCODE
	kform	portk	gkform, kporttime       ;APPLY PORTAMENTO TO SELECTED FLTK SLIDER VARIABLE AND CREATE NEW NON-GLOBAL VARIABLES TO BE USED BY THE FOF OPCODE
	
	iolaps	=	500		;MAXIMUM ALLOWED NUMBER OF GRAIN OVERLAPS (THE BEST IDEA IS TO SIMPLY OVERESTIMATE THIS VALUE)
	ifna	=	gisine		;WAVEFORM USED BY THE GRAINS (NORMALLY A SINE WAVE)
	ifnb	=	giexp		;WAVEFORM USED IN THE DESIGN OF THE EXPONENTIAL ATTACK AND DECAY OF THE GRAINS
	itotdur	=	3600		;TOTAL DURATION OF THE FOF NOTE. IN NON-REALTIME THIS WILL BE p3. IN REALTIME OVERESTIMATE THIS VALUE, IN THIS CASE 1 HOUR - PERFORMANCE CAN STILL BE INTERRUPTED PREMATURELY
	;THE FOF OPCODE:
	asig 	fof 	gkamp, kfund, kform, gkoct, gkband, gkris, gkdur, gkdec, iolaps, ifna, ifnb, itotdur ;[, iphs] [, ifmode] [, iskip
	aenv	linsegr	0,0.03,1,0.03,0	;ANTI CLICK
		outs	asig*aenv, asig*aenv	;OUTPUT OF fof OPCODE IS SENT TO THE OUTPUTS  
endin

</CsInstruments>

<CsScore>
f 0 3600	;DUMMY SCORE EVENT - PERMITS REALTIME PERFORMANCE FOR 1 HOUR
</CsScore>

</CsoundSynthesizer>