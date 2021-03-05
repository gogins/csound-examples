;Written by Iain McCurdy, 2006

;DEMONSTRATION OF THE wgbow OPCODE. THIS IS A PHYSICALLY MODELLED BOWED STRING INSTRUMENT BASED ON WORK BY PERRY COOK

;kamp - AMPLITUDE

;kfreq - THE FUNDEMENTAL OF THE TONE PRODUCED

;kpres - PRESSURE OF THE BOW UPON THE STRING
;	THE OPCODE AUTHOR, JOHN FFITCH, SUGGESTS THAT WE CHOOSE VALUES WITHIN THE RANGE 1 to 5
;	HE ALSO SUGGESTS THAT A VALUE OF 3 REFLECTS NORMAL PLAYING PRESSURE

;krat - POSITION OF THE BOW ALONG THE LENGTH OF THE STRING
;	THE OPCODE AUTHOR SUGGESTS THAT WE CHOOSE VALUES WITHIN THE RANGE .025 to 0.23
;	HE ALSO SUGGESTS THAT A VALUE OF .127236 REFLECTS A NORMAL BOWING POSITION
;	STRING EFFECTS SUCH AS 'SUL PONTICELLO' (AT THE BRIDGE) AND 'FLAUTANDO' (OVER THE NECK) CAN BE IMITATED USING THIS PARAMETER
;	A VALUE OF .025 REFLECTS A 'SUL PONTICELLO' STYLE OF PLAYING AND PRODUCES A THINNER TONE
;	A VALUE OF .23 REFLECTS A 'FLAUTANDO' STYLE OF PLAYING AND PRODUCES A FLUTE-LIKE TONE
;	THESE SUGGESTED SETTINGS FOR krat ARE BASED UPON A CONVENTIONAL PLAYING TECHNIQUE OF A BOWED INSTRUMENT.
;	IF VALUES ARE CHOSEN BEYOND THESE LIMITS OTHER UNCONVENTIONAL SOUNDS ARE POSSIBLE.
;	0 = THE STRING BEING BOWED AT THE NUT (NECK), 1 = THE STRING BEING BOWED AT THE BRIDGE
;	IN ACTUALITY VALUES OF 0 AND 1 WILL PRODUCE SILENCE
;	VALUES CLOSE TO ZERO OR CLOSE TO 1 WILL PRODUCE A THIN, HARD SOUND (BOWED NEAR THE NECK END OR NEAR THE BRIDGE)
;	A VALUE OF .5 WILL PRODUCE A SOFT FLUTEY SOUND (STRING BOWED HALFWAY ALONG ITS LENGTH)

;kvibf/kvibamp - THIS OPCODE IMPLEMENTS VIBRATO THAT GOES BEYOND JUST FREQUENCY MODULATION AND INCLUDES MODULATION 
;	-UPON SEVERAL OTHER ASPECTS OF THE SOUND INCLUDING AMPLITUDE MODULATION
;	A USEFUL RANGE FOR kvibamp (AMPLITUDE OF VIBRATO) IS 0-.1 WHERE 0=NO VIBRATO AND .1=A LOT OF VIBRATO
;	kvibf IS USED TO CONTROL VIBRATO FREQUENCY, A NATURAL VIBRATYO FREQUENCY IS ABOUT 5 HZ

;ifn - A FUNCTION TABLE WAVEFORM MUST BE GIVEN TO DEFINE THE SHAPE OF THE VIBRATO, 
;	-THIS SHOULD NORMALLY BE A SINE WAVE.

;THE OPCODE OFFERS 1 FURTHER *OPTIONAL* PARAMETER:

;iminfreq - A MINIMUM FREQUENCY SETTING GIVEN TO THE ALGORITHM
;	- TYPICALLY THIS IS SET TO A VALUE BELOW THE FREQUENCY SETTING GIVEN BY kfreq (IF OMITTED IT DEFAULTS TO 50HZ)
;	- IF kfreq GOES BELOW iminfreq THE SETTING FOR kfreq NO LONGER REFLECTS THE PITCH THAT IS ACTUALLY HEARD.

<CsoundSynthesizer>

<CsOptions>
-odac -M0 -+rtmidi=virtual -dm0	;VIRTUAL MIDI DEVICE
</CsOptions>

<CsInstruments>

sr 		= 	44100	;SAMPLE RATE
ksmps 		= 	100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 		= 	2	;NUMBER OF CHANNELS (2=STEREO)
0dbfs		=	1	;MAXIMUM AMPLITUDE = 1, REGARDLESS OF BIT DEPTH

;FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLcolor	255, 255, 255, 0, 0, 0

;			LABEL | WIDTH | HEIGHT | X | Y
		FLpanel	"wgbow", 500,    400,    0,  0

;BUTTONS                              			ON | OFF | TYPE | WIDTH | HEIGHT | X | Y | OPCODE | INS | STARTTIM | DUR
gkOnOff,ihOnOff	FLbutton	"Bow / Off (MIDI)",	1,    0,    22,    200,     25,    5,  5,    0,      2,      0,      -1
FLsetColor2	255, 255, 50, ihOnOff		;SET SECONDARY COLOUR TO YELLOW

;VALUE DISPLAY BOXES	LABEL  | WIDTH | HEIGHT | X |  Y
idamp		FLvalue	" ",      100,     18,    5,   75
idfreq		FLvalue	" ",      100,     18,    5,  125
idpres		FLvalue	" ",      100,     18,    5,  175
idrat		FLvalue	" ",      100,     18,    5,  225
idvibf		FLvalue	" ",      100,     18,    5,  275
idvibamp	FLvalue	" ",      100,     18,    5,  325
idminfreq	FLvalue	" ",      100,     18,    5,  375

;SLIDERS				            						MIN |   MAX   | EXP | TYPE |   DISP    | WIDTH | HEIGHT | X  | Y
gkamp, ihamp			FLslider	"Amplitude",					0,        1,     0,    23,    idamp,      490,     25,    5,   50
gkfreq, ihfreq			FLslider	"Frequency",					20,    4000,    -1,    23,    idfreq,     490,     25,    5,  100
gkpres, ihpres			FLslider	"Bow Pressure",					0.01,    90,    -1,    23,    idpres,     490,     25,    5,  150
gkrat, ihrat			FLslider	"Bow Position",					.006,  .988,     0,    23,    idrat,      490,     25,    5,  200
gkvibf,ihvibf			FLslider 	"Vibrato Frequency",  				0,       30,     0,    23,    idvibf,     490,     25,    5,  250
gkvibamp,ihvibamp		FLslider 	"Vibrato Amplitude",  				0,       .1,     0,    23,    idvibamp,   490,     25,    5,  300
gkminfreq,ihminfreq		FLslider 	"Minimum Frequency (i-rate and optional)",	20,   20000,    -1,    23,    idminfreq,  490,     25,    5,  350

;SET INITIAL VALUES FOR SLIDERS
		FLsetVal_i	0.3, 	ihamp
		FLsetVal_i	170, 	ihfreq
		FLsetVal_i	3, 	ihpres
		FLsetVal_i	.127236,ihrat
		FLsetVal_i	4.5, 	ihvibf
		FLsetVal_i	.008, 	ihvibamp
		FLsetVal_i	20, 	ihminfreq

		FLpanel_end

;INSTRUCTIONS AND INFO PANEL
				FLpanel	" ", 500, 560, 512, 0
;TEXT BOXES												TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                           wgbow                             ", 	1,      5,     14,    490,    15,     5,   0
ih		 	FLbox  	"-------------------------------------------------------------", 	1,      5,     14,    490,    15,     5,  20
ih		 	FLbox  	"wgbow is a wave guide physical model of a bowed string based ", 	1,      5,     14,    490,    15,     5,  40
ih		 	FLbox  	"on work by Perry Cook but re-coded for Csound by John ffitch.", 	1,      5,     14,    490,    15,     5,  60
ih		 	FLbox  	"Bow pressure represents the downward pressure of the bow upon", 	1,      5,     14,    490,    15,     5,  80
ih		 	FLbox  	"the string and should be a value between 1 and 5. The author ", 	1,      5,     14,    490,    15,     5, 100
ih		 	FLbox  	"suggests a value of about 3 to represent normal bow pressure.", 	1,      5,     14,    490,    15,     5, 120
ih		 	FLbox  	"Bow position represents the position of the bow along the    ", 	1,      5,     14,    490,    15,     5, 140
ih		 	FLbox  	"length of the string.                                        ", 	1,      5,     14,    490,    15,     5, 160
ih		 	FLbox  	"Bow position represents the position of the bow along the    ", 	1,      5,     14,    490,    15,     5, 160
ih		 	FLbox  	"length of the string. The opcode author suggests that we     ", 	1,      5,     14,    490,    15,     5, 180
ih		 	FLbox  	"choose values within the range .025 to 0.23. He also suggests", 	1,      5,     14,    490,    15,     5, 200
ih		 	FLbox  	"that a value of .127236 reflects a normal bowing position.   ", 	1,      5,     14,    490,    15,     5, 220
ih		 	FLbox  	"String effects such as 'sul ponticello' (at the bridge) and  ", 	1,      5,     14,    490,    15,     5, 240
ih		 	FLbox  	"'flautando' (over the neck) can be imitated using this       ", 	1,      5,     14,    490,    15,     5, 260
ih		 	FLbox  	"parameter. A value of .025 reflects a 'sul ponticello' style ", 	1,      5,     14,    490,    15,     5, 280
ih		 	FLbox  	"of playing and produces a thinner tone. A value of .23       ", 	1,      5,     14,    490,    15,     5, 300
ih		 	FLbox  	"reflects a 'flautando' style of playing and produces a flute-", 	1,      5,     14,    490,    15,     5, 320
ih		 	FLbox  	"-like tone.                                                  ", 	1,      5,     14,    490,    15,     5, 340
ih		 	FLbox  	"Vibrato is implemented within the opcode and does not need to", 	1,      5,     14,    490,    15,     5, 360
ih		 	FLbox  	"be applied separately to the frequency parameter. Vibrato is ", 	1,      5,     14,    490,    15,     5, 380
ih		 	FLbox  	"implemented so that it only takes effect after a short time  ", 	1,      5,     14,    490,    15,     5, 400
ih		 	FLbox  	"delay. This time delay is retriggered if bow position is     ", 	1,      5,     14,    490,    15,     5, 420
ih		 	FLbox  	"changed during note performance.                             ", 	1,      5,     14,    490,    15,     5, 440
ih		 	FLbox  	"Minimum frequency (optional) defines the lowest frequency at ", 	1,      5,     14,    490,    15,     5, 460
ih		 	FLbox  	"which the model will play.                                   ", 	1,      5,     14,    490,    15,     5, 480
ih		 	FLbox  	"This example can also be triggered via MIDI. MIDI note       ", 	1,      5,     14,    490,    15,     5, 500
ih		 	FLbox  	"number, velocity and pitch bend are interpreted              ", 	1,      5,     14,    490,    15,     5, 520
ih		 	FLbox  	"appropriately.                                               ", 	1,      5,     14,    490,    15,     5, 540

		FLpanel_end

				FLrun	;RUN THE FLTK WIDGET THREAD
;END OF FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gisine	ftgen	0, 0, 4096, 10, 1	;SINE WAVE (USED FOR VIBRATO)

instr	1	;MIDI ACTIVATED INSTRUMENT
	if	gkOnOff=1	then ; SENSE FLTK ON/OFF SWITCH
			turnoff	;TURNOFF THIS INSTRUMENT IMMEDIATELY
	endif
	ioct	octmidi		;READ NOTE VALUES FROM MIDI INPUT IN THE 'OCT' FORMAT
	iamp	ampmidi	1	;AMPLITUDE IS READ FROM INCOMING MIDI NOTE
	;kpres	aftouch	1, 5		;AFTERTOUCH CONTROL OF BOW PRESSURE
	;kpres	ctrl7	1, 1, 1, 5	;MOD. WHEEL CONTROL OF BOW PRESSURE
	kpres	=	gkpres
	;PITCH BEND INFORMATION IS READ
	iSemitoneBendRange = 2		;PITCH BEND RANGE IN SEMITONES (WILL BE DEFINED FURTHER LATER) - SUGGESTION - THIS COULD BE CONTROLLED BY AN FLTK COUNTER
	imin = 0			;EQUILIBRIUM POSITION
	imax = iSemitoneBendRange * .0833333	;MAX PITCH DISPLACEMENT (IN oct FORMAT)
	kbend	pchbend	imin, imax	;PITCH BEND VARIABLE (IN oct FORMAT)
	kfreq	=	cpsoct(ioct+ kbend)
	aenv	linsegr		1,3600,1,0.01,0		;ANTI-CLICK ENVELOPE
	abow	wgbow	gkamp*iamp, kfreq, kpres, gkrat, gkvibf, gkvibamp, gisine, i(gkminfreq)
		outs		abow * aenv, abow * aenv	;SEND AUDIO TO OUTPUTS
endin

instr	2	;FLTK TRIGGERED INSTRUMENT
	if	gkOnOff=0	then ; SENSE FLTK ON/OFF SWITCH
			turnoff	;TURNOFF THIS INSTRUMENT IMMEDIATELY
	endif
	kSwitch		changed		gkminfreq	;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
	if	kSwitch=1	then
		reinit	START
	endif
	iporttime	=	0.01
	kporttime	linseg	0,0.01,iporttime,1,iporttime
	krat		portk	gkrat, kporttime
	kpres		portk	gkpres, kporttime
	kfreq		portk	gkfreq, kporttime
	START:
	abow	wgbow	gkamp, kfreq, kpres, krat, gkvibf, gkvibamp, gisine, i(gkminfreq)
	rireturn
		outs 	abow, abow
endin

</CsInstruments>

<CsScore>
f 0 3600	;DUMMY SCORE EVENT SUSTAINS REALTIME PERFORMANCE FOR 1 HOUR
</CsScore>

</CsoundSynthesizer>