<CsoundSynthesizer>

<CsOptions>
-+rtaudio=PortAudio -b4096
</CsOptions>


<CsInstruments>

sr	=	44100
kr	=	44100
ksmps	=	1
nchnls	=	2


	FLpanel	"FM Synthesis: Simple Carrier->Modulator", 500, 250

;                                                      ON | OFF | TYPE | WIDTH | HEIGHT | X | Y | OPCODE | INS | STARTTIM | IDUR
gkOnOff,ihOnOff	FLbutton	"On/Off",		1,  -1,     2,    150,     28,    0,  0,    0,      1,      0,       3600

;VALUE DISPLAY BOXES					WIDTH | HEIGHT | X |  Y
idbasefreq			FLvalue	" ",     	60,       20,    0,   80
idCMratio			FLvalue	" ",     	60,       20,    0,  130
idindex				FLvalue	" ",     	60,       20,    0,  180
idphs				FLvalue	" ",     	60,       20,    0,  230

;					            							MIN  |   MAX | EXP | TYPE |   DISP     | WIDTH | HEIGHT | X | Y
gkbasefreq,ihbasefreq		FLslider 	"Base Frequency",		 			20,    20000,  -1,    5,   idbasefreq,    500,    30,     0, 50
gkCMratio,ihCMratio		FLslider 	"Phase Modulation Frequency (Hertz)???????",			.125,      8,   0,    5,   idCMratio,     500,    30,     0, 100
gkindex,ihindex			FLslider 	"Phase Modulation Depth????????",				0,        10,   0,    5,   idindex,       500,    30,     0, 150
gkphs,ihphs			FLslider 	"Phase",						0,         1,   0,    5,   idphs,         500,    30,     0, 200

			FLsetVal_i	100, 	ihbasefreq
			FLsetVal_i	1, 	ihCMratio
			FLsetVal_i	3, 	ihindex
			FLsetVal_i	0, 	ihphs

			FLpanel_end

;INSTRUCTIONS AND INFO PANEL
				FLpanel	" ", 500, 680, 512, 0
;TEXT BOXES												TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                 Phase Modulation Synthesis                  ", 	1,      5,     14,    490,    15,     5,  0
ih		 	FLbox  	"-------------------------------------------------------------", 	1,      5,     14,    490,    15,     5,  20
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5,  40
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5,  60
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5,  80
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 100
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 120
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 120
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 140
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 160
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 180
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 200
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 220
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 240
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 260
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 280
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 300
                                  
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5,  30+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5,  45+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5,  60+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5,  75+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5,  90+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 105+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 120+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 135+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 150+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 165+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 180+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 195+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 210+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 225+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 240+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 255+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 270+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 285+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 300+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 315+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 330+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 345+300
ih		 	FLbox  	" ", 	1,      5,     14,    490,    15,     5, 360+300

				FLpanel_end

				FLrun	;RUN THE FLTK WIDGET THREAD
;END OF FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	instr 1
if	gkOnOff!=-1	kgoto	CONTINUE
turnoff
CONTINUE:
kpeakdeviation	=	gkbasefreq * gkindex
;aModulator	oscili	kpeakdeviation,gkbasefreq,1
;ares 		osciliktp kcps, kfn, kphs [, istor]
;aModulator 	osciliktp gkbasefreq, 1, gkphs; [, istor]
aModulator	lfo	kpeakdeviation, gkbasefreq, 5
;aModulator	=	aModulator*kpeakdeviation
aCarrier	oscili	30000, (gkbasefreq*gkCMratio)+aModulator,1
	outs	aCarrier, aCarrier
	endin
	
</CsInstruments>


<CsScore>
f 1 0 131072 10 1
f 0 3600

</CsScore>


</CsoundSynthesizer>



























