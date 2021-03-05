;Written by Iain McCurdy

<CsoundSynthesizer>

<CsOptions>
-+rtaudio=PortAudio -b4096
</CsOptions>

<CsInstruments>
sr			=	44100
kr			=	4410
ksmps			=	10
nchnls			=	2

;FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			LABEL                                       | WIDTH | HEIGHT | X | Y
			FLpanel	"Randomly Moving X-Y Panel Cursor",    500,     650,   0,  0

;VALUE_DISPLAY_BOXES			 	WIDTH | HEIGHT | X | Y
idFreq				FLvalue	" ",     50,      18,    0, 580

;XY PANELS				MINX | MAXX | MINY | MAXY | EXPX | EXPY | DISPX | DISPY | WIDTH | HEIGHT | X | Y
gkx, gky, gihx, gihy	FLjoy	" ", 	0,       1,    0,       1,   0,     0,      -1,     -1,    470,    470,    0,  0

;SLIDER					        				MIN | MAX | EXP | TYPE | DISP | WIDTH | HEIGHT |  X  | Y
gkMinX,	ihMinX		FLslider 	" ",					0,     1,    0,    3,     -1,    470,     15,     0,  470
gkMaxX,	ihMaxX		FLslider 	" ",					0,     1,    0,    3,     -1,    470,     15,     0,  485
gkMinY,	ihMinY		FLslider 	" ",					0,     1,    0,    4,     -1,     15,    470,   470,    0
gkMaxY,	ihMaxY		FLslider 	" ",					0,     1,    0,    4,     -1,     15,    470,   485,    0
gkFreq,	ihFreq		FLslider 	"Frequency",				.001, 10,    0,    3,    idFreq, 500,     30,    0,   550
gki_h,	ihi_h		FLslider 	"Interpolating <-> Sample and Hold",	0,     1,    0,    3,        -1, 500,     30,    0,   600

;SET_INITIAL_VALUES		VALUE | HANDLE
		FLsetVal_i	0, 	ihMinX
		FLsetVal_i	1, 	ihMaxX
		FLsetVal_i	0, 	ihMinY
		FLsetVal_i	1, 	ihMaxY
		FLsetVal_i	1, 	ihFreq

			FLpanel_end
			FLrun
			
			instr 1
kxi			randomi		gkMinX, gkMaxX, gkFreq	;GENERATE INTERPOLATING RANDOM VALUES
kyi			randomi		gkMinY, gkMaxX, gkFreq  ;GENERATE INTERPOLATING RANDOM VALUES
kxh			randomh		gkMinX, gkMaxX, gkFreq	;GENERATE SAMPLE AND HOLD TYPE RANDOM VALUES
kyh			randomh		gkMinY, gkMaxX, gkFreq  ;GENERATE SAMPLE AND HOLD TYPE RANDOM VALUES
kx			ntrpol		kxi, kxh, gki_h		;CROSSFADE BETWEEN INTERPOLATING AND SAMPLE AND HOLD TYPE RANDOM VALUES
ky			ntrpol		kyi, kyh, gki_h         ;CROSSFADE BETWEEN INTERPOLATING AND SAMPLE AND HOLD TYPE RANDOM VALUES
ktrigx			changed		kx			;CREATE A TRIGGER (MOMENTARY 1 VALUE) EACH TIME kx CHANGES
ktrigy			changed		ky                      ;CREATE A TRIGGER (MOMENTARY 1 VALUE) EACH TIME ky CHANGES
			FLsetVal	ktrigx, kx, gihx	;SEND VALUE kx TO X DIRECTION OF X-Y PANEL
			FLsetVal	ktrigy, 1-ky, gihy      ;SEND VALUE ky TO Y DIRECTION OF X-Y PANEL
			endin

</CsInstruments>

<CsScore>   
i 1 0 3600     	;INSTRUMENT 1 PLAYS FOR 1 HOUR
</CsScore>

</CsoundSynthesizer>