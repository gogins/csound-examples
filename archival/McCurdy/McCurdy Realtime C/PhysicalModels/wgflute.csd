;Written by Iain McCurdy, 2006

;DEMONSTRATION OF THE wgflute OPCODE WHICH IS BASED ON PERRY COOK'S PHYSICAL MODEL OF A FLUTE

;THIS OPCODE OFFERS A LOT OF INPUT PARAMETERS

;kamp - AMPLITUDE

;kfreq - THE FUNDEMENTAL OF THE TONE PRODUCED

;KJET - A PARAMETER CONTROLLING THE AIR JET. VALUES SHOULD BE POSITIVE, AND ABOUT 0.3. THE USEFUL RANGE IS APPROXIMATELY 0.08 TO 0.56
;LOW SETTINGS FOR KJET FORCE OVERTONES FROM THE INSTRUMENT
;THIS IS PROBABLY THE MOST INSTERESTING PARAMETER IN THIS OPCODE

;iatt/idek - ATTACK AND DECAY TIMES APPARENTLY BUT THEY DON'T SEEM TO DO ANYTHING AT ALL AS FAR AS I CAN SEE!

;kngain - AMPLITUDE OF BREATH/WIND NOISE. THE FLUTE SOUND CONSISTS OF 2 MAIN ELEMENTS:
;	THE RESONANT TONE AND THE BREATH NOISE. 
;	THIS PARAMETER CONTROLS THE STRENGTH OF THE BREATH/WIND NOISE.
;	A USEFUL RANGE FOR THIS IS ABOUT 0-1
;	0=NO BREATH NOISE, 1=BREATH NOISE ONLY

;kvibf/kvibamp - THIS OPCODE IMPLEMENTS VIBRATO THAT GOES BEYOND JUST FREQUENCY MODULATION AND INCLUDES MODULATION 
;	-UPON SEVERAL OTHER ASPECTS OF THE SOUND INCLUDING AMPLITUDE MODULATION
;	A USEFUL RANGE FOR kvibamp (AMPLITUDE OF VIBRATO) IS 0-.25 WHERE 0=NO VIBRATO AND .25=A LOT OF VIBRATO
;	kvibf IS USED TO CONTROL VIBRATO FREQUENCY, A NATURAL VIBRATO FREQUENCY IS ABOUT 5 HZ

;ifn - A FUNCTION TABLE WAVEFORM MUST BE GIVEN TO DEFINE THE SHAPE OF THE VIBRATO, 
;	-THIS SHOULD NORMALLY BE A SINE WAVE.

;THE OPCODE OFFERS 3 FURTHER *OPTIONAL* PARAMETERS:

;iminfreq - A MINIMUM FREQUENCY SETTING GIVEN TO THE ALGORITHM
;	- TYPICALLY THIS IS SET TO A VALUE BELOW THE FREQUENCY SETTING GIVEN BY kfreq
;	- IF kfreq GOES BELOW iminfreq IS CAN HAVE A STRANGE EFFECT ON THE SOUND AND THE SETTING FOR kfreq NO LONGER 
;	-REFLECTS THE PITCH THAT IS ACTUALLY HEARD.

;ijetrf - AMOUNT OF REFLECTION OF THE BREATH JET. I.E. RESISTANCE OF THE AIR COLUMN ON THE FLUTE (I-RATE ONLY)

;iendrf - BREATH JET REFLECTION COEFFICIENT (I-RATE ONLY) THIS CONTROLS HOW THE BREATH JET INTERACTS WITH THE RESONANT SOUND
;	- 0=BREATH JET DOMINATES 1=RESONANCE DOMINATES

<CsoundSynthesizer>

<CsOptions>
-odevaudio -idevaudio -M0 -+rtmidi=virtual -b400	;VIRTUAL MIDI CONTROL
</CsOptions>

<CsInstruments>

sr 		= 	44100	;SAMPLE RATE
ksmps 		= 	100	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 		= 	2	;NUMBER OF CHANNELS (2=STEREO)
0dbfs		=	1	;MAXIMUMAMPLITUDE REGARDLESS OF BIT DEPTH

;FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLcolor	255, 255, 255, 0, 0, 0	;SET INTERFACE COLOURS

;			LABEL   | WIDTH | HEIGHT | X | Y
		FLpanel	"wgflute", 500,    600,    0,  0

;BUTTONS                              				ON | OFF | TYPE | WIDTH | HEIGHT | X | Y | OPCODE | INS | STARTTIM | DUR
gkOnOff,ihOnOff	FLbutton	"On (FLTK) / Off (MIDI) ",	1,    0,    22,    190,     25,    5,  5,    0,      2,      0,      -1
FLsetColor2	255, 255, 50, ihOnOff	;SET SECONDARY COLOUR TO YELLOW

;VALUE DISPLAY BOXES	LABEL  | WIDTH | HEIGHT | X |  Y
idamp		FLvalue	" ",      100,    18,     5,   75
idfreq		FLvalue	" ",      100,    18,     5,  125
idjet		FLvalue	" ",      100,    18,     5,  175
idatt		FLvalue	" ",      100,    18,     5,  225
iddek		FLvalue	" ",      100,    18,     5,  275
idngain		FLvalue	" ",      100,    18,     5,  325
idvibf		FLvalue	" ",      100,    18,     5,  375
idvibamp	FLvalue	" ",      100,    18,     5,  425
idminfreq	FLvalue	" ",      100,    18,     5,  475
idjetrf		FLvalue	" ",      100,    18,     5,  525
idendrf		FLvalue	" ",      100,    18,     5,  575

;SLIDERS				            						MIN |   MAX  | EXP | TYPE |  DISP    | WIDTH | HEIGHT | X  | Y
gkamp, ihamp			FLslider	"Amplitude",					0,        1,    0,    23,   idamp,      490,     25,    5,   50
gkfreq, gihfreq			FLslider	"Frequency",					20,   20000,   -1,    23,   idfreq,     490,     25,    5,  100
gkjet, ihjet			FLslider	"Air Jet",					0.02,    10,    0,    23,   idjet,      490,     25,    5,  150
gkatt, ihatt			FLslider	"Attack Time (i-rate in seconds)",		0,    	  1,    0,    23,   idatt,      490,     25,    5,  200
gkdek,ihdek			FLslider 	"Decay Time (i-rate in seconds)",  		0,        1,    0,    23,   iddek,      490,     25,    5,  250
gkngain,ihngain			FLslider 	"Amplitude of Breath Noise",  			0,        1,    0,    23,   idngain,    490,     25,    5,  300
gkvibf,ihvibf			FLslider 	"Vibrato Frequency",  				0,       30,    0,    23,   idvibf,     490,     25,    5,  350
gkvibamp,ihvibamp		FLslider 	"Vibrato Amplitude",  				0,       .3,    0,    23,   idvibamp,   490,     25,    5,  400
gkminfreq,ihminfreq		FLslider 	"Minimum Frequency (i-rate)",			20,   20000,   -1,    23,   idminfreq,  490,     25,    5,  450
gkjetrf,ihjetrf			FLslider 	"Amount of Reflection of Breath Jet (i-rate)",	0,        1,    0,    23,   idjetrf,    490,     25,    5,  500
gkendrf,ihendrf			FLslider 	"Breath Jet Reflection Coefficient (i-rate)",	0,        1,    0,    23,   idendrf,    490,     25,    5,  550

;SET_INITIAL_VALUES		VALUE | HANDLE
		FLsetVal_i	0.2, 	ihamp
		FLsetVal_i	750, 	gihfreq
		FLsetVal_i	.34, 	ihjet
		FLsetVal_i	.1, 	ihatt
		FLsetVal_i	.1, 	ihdek
		FLsetVal_i	.1, 	ihngain
		FLsetVal_i	5, 	ihvibf
		FLsetVal_i	.1, 	ihvibamp
		FLsetVal_i	20, 	ihminfreq
		FLsetVal_i	.5, 	ihjetrf
		FLsetVal_i	.5, 	ihendrf

		FLpanel_end

;INSTRUCTIONS AND INFO PANEL
				FLpanel	" ", 500, 600, 512, 0
;TEXT BOXES												TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                         wgflute                             ", 	1,      5,     14,    490,    20,     5,   0
ih		 	FLbox  	"-------------------------------------------------------------", 	1,      5,     14,    490,    20,     5,  20
ih		 	FLbox  	"wgflute is a wave guide physical model of a flute based on   ", 	1,      5,     14,    490,    20,     5,  40
ih		 	FLbox  	"work by Perry Cook but re-coded for Csound by John ffitch.   ", 	1,      5,     14,    490,    20,     5,  60
ih		 	FLbox  	"Attack time is the time taken to reach full blowing pressure.", 	1,      5,     14,    490,    20,     5,  80
ih		 	FLbox  	"The author suggests that 0.1 corresponds to normal playing.  ", 	1,      5,     14,    490,    20,     5, 100
ih		 	FLbox  	"Decay time is the time taken for the system to stop producing", 	1,      5,     14,    490,    20,     5, 120
ih		 	FLbox  	"sound after blowing has stopped. The author suggests that 0.1", 	1,      5,     14,    490,    20,     5, 140
ih		 	FLbox  	"produces a smooth natural sounding end to a note.            ", 	1,      5,     14,    490,    20,     5, 160
ih		 	FLbox  	"Air jet defines the strength of the air jet blown into the   ", 	1,      5,     14,    490,    20,     5, 160
ih		 	FLbox  	"flute and therefore controls the playing of overtones.       ", 	1,      5,     14,    490,    20,     5, 180
ih		 	FLbox  	"Values for air jet should be positive and the useful range is", 	1,      5,     14,    490,    20,     5, 200
ih		 	FLbox  	"approximately 0.08 to 0.56. The author suggests a value of   ", 	1,      5,     14,    490,    20,     5, 200
ih		 	FLbox  	"0.3 as representing an air jet of typical strength. A value  ", 	1,      5,     14,    490,    20,     5, 220
ih		 	FLbox  	"of 0.34 seems to provide the most accurate tuning.           ", 	1,      5,     14,    490,    20,     5, 240
ih		 	FLbox  	"Amplitude of breath noise controls the amount of simulated   ", 	1,      5,     14,    490,    20,     5, 260
ih		 	FLbox  	"wind noise in the composite tone produced. The suggested     ", 	1,      5,     14,    490,    20,     5, 280
ih		 	FLbox  	"range is 0 to 0.5.                                           ", 	1,      5,     14,    490,    20,     5, 300
ih		 	FLbox  	"Vibrato is implemented within the opcode and does not need to", 	1,      5,     14,    490,    20,     5, 320
ih		 	FLbox  	"be applied separately to the frequency parameter. Natural    ", 	1,      5,     14,    490,    20,     5, 340
ih		 	FLbox  	"vibrato occurs at about 5 hertz.                             ", 	1,      5,     14,    490,    20,     5, 360
ih		 	FLbox  	"Minimum frequency (optional) defines the lowest frequency at ", 	1,      5,     14,    490,    20,     5, 380
ih		 	FLbox  	"which the model will play.                                   ", 	1,      5,     14,    490,    20,     5, 400
ih		 	FLbox  	"Amount of Reflection of Breath Jet (optional, default=0.5)   ", 	1,      5,     14,    490,    20,     5, 420
ih		 	FLbox  	"defines the amount of reflection in the breath jet that.     ", 	1,      5,     14,    490,    20,     5, 440
ih		 	FLbox  	"powers the flute.                                            ", 	1,      5,     14,    490,    20,     5, 460
ih		 	FLbox  	"Breath Jet Reflection Coefficient (optional, default=0.5) is ", 	1,      5,     14,    490,    20,     5, 480
ih		 	FLbox  	"used in conjunction with the Amount of Reflection of Breath  ", 	1,      5,     14,    490,    20,     5, 500
ih		 	FLbox  	"Jet in the calculation of the pressure differential.         ", 	1,      5,     14,    490,    20,     5, 520
ih		 	FLbox  	"This example can also be triggered via MIDI. MIDI note       ", 	1,      5,     14,    490,    15,     5, 540
ih		 	FLbox  	"number, velocity and pitch bend are interpreted              ", 	1,      5,     14,    490,    15,     5, 560
ih		 	FLbox  	"appropriately.                                               ", 	1,      5,     14,    490,    15,     5, 580

		FLpanel_end

				FLrun	;RUN THE FLTK WIDGET THREAD
;END OF FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gisine	ftgen	0, 0, 131072, 10, 1	;SINE WAVE (USED FOR VIBRATO)

instr	1	;MIDI ACTIVATED INSTRUMENT
	if	gkOnOff=1	then ; SENSE FLTK ON/OFF SWITCH
			turnoff	;TURNOFF THIS INSTRUMENT IMMEDIATELY
	endif
	ioct	octmidi		;READ NOTE VALUES FROM MIDI INPUT IN THE 'OCT' FORMAT
	iamp	ampmidi	1	;AMPLITUDE IS READ FROM INCOMING MIDI NOTE
	;kpres	aftouch	1, 5		;AFTERTOUCH CONTROL OF BOW PRESSURE
	;kpres	ctrl7	1, 1, 1, 5	;MOD. WHEEL CONTROL OF BOW PRESSURE
	;kpres	=	gkpres
	;PITCH BEND INFORMATION IS READ
	iSemitoneBendRange = 2		;PITCH BEND RANGE IN SEMITONES (WILL BE DEFINED FURTHER LATER) - SUGGESTION - THIS COULD BE CONTROLLED BY AN FLTK COUNTER
	imin = 0			;EQUILIBRIUM POSITION
	imax = iSemitoneBendRange * .0833333	;MAX PITCH DISPLACEMENT (IN oct FORMAT)
	kbend	pchbend	imin, imax	;PITCH BEND VARIABLE (IN oct FORMAT)
	kfreq	=	cpsoct(ioct+ kbend)
	ifn		=	1	;WAVEFORM FUNCTION TABLE FOR THE SHAPE OF THE VIBRATO - SHOULD NORMALLY JUST BE A SINE WAVE OR SOMETHING SIMILAR
	kSwitch		changed		gkminfreq, gkjetrf, gkendrf, gkatt, gkdek	;GENERATE A MOMENTARY '1' VALUE THROUGH VARIABLE kSwitch IF ANY OF ITS INPUT VARIABLE CHANGE
	if	kSwitch=1	then		;IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
		reinit	UPDATE			;BEGIN A REINITIALISATION PASS FROM LABEL 'UPDATE'
	endif
	UPDATE:
	;AN AUDIO SIGNAL IS CREATED USING THE wgflute OPCODE. NOTE THAT I-RATE VARIABLES MUST BE CONVERTED TO I-RATE FROM K-RATE SLIDERS
	aflute		wgflute	gkamp*iamp, kfreq, gkjet, i(gkatt), i(gkdek), gkngain, gkvibf, gkvibamp, gisine, i(gkminfreq), i(gkjetrf), i(gkendrf)
	rireturn				;RETURN FROM A REINITIALIZATION PASS TO PERFORMANCE TIME PASSES
	aenv		linsegr	1,i(gkdek),0		;THIS ENVELOPE, ALTHOUGH NOT USED AS A CONTROL SIGNAL FOR ANYTHING, SERVES TO KEEP THE INSTRUMENT RUNNING AFTER A NOTE OF HAS BEEN RECEIVED TO FACILITATE THE DECCAY TIME FOR wgclar
	outs 	aflute * aenv, aflute * aenv	;SEND AUDIO OUTPUTS
endin

instr	2	;FLTK ACTIVATED INSTRUMENT
	if		gkOnOff=0	then		;IF ON/OFF SWITCH IS OFF AND NO MIDI NOTES ARE ACTIVE...
		turnoff					;...TURN THIS INSTRUMENT OFF
	endif						;END OF CONDITIONAL BRANCHING
	aenv		linsegr	1,i(gkdek),0		;THIS ENVELOPE, ALTHOUGH NOT USED AS A CONTROL SIGNAL FOR ANYTHING, SERVES TO KEEP THE INSTRUMENT RUNNING AFTER A NOTE OF HAS BEEN RECEIVED TO FACILITATE THE DECCAY TIME FOR wgclar
	kSwitch		changed		gkminfreq, gkjetrf, gkendrf, gkatt, gkdek	;GENERATE A MOMENTARY '1' VALUE THROUGH VARIABLE kSwitch IF ANY OF ITS INPUT VARIABLE CHANGE
	if	kSwitch=1	then	;IF kSwitch=1 THEN...
		reinit	UPDATE		;BEGIN A REINITIALIZATION PASS FROM THE GIVEN LABEL
	endif				;LABEL
	UPDATE:
	;AN AUDIO SIGNAL IS CREATED USING THE wgflute OPCODE. NOTE THAT I-RATE VARIABLES MUST BE CONVERTED TO I-RATE FROM K-RATE SLIDERS
	aflute		wgflute	gkamp, gkfreq, gkjet, i(gkatt), i(gkdek), gkngain, gkvibf, gkvibamp, gisine, i(gkminfreq), i(gkjetrf), i(gkendrf)
	rireturn				;RETURN FROM A REINITIALIZATION PASS TO PERFORMANCE TIME PASSES
	outs 	aflute * aenv, aflute * aenv	;SEND AUDIO OUTPUTS
endin

</CsInstruments>

<CsScore>
f 0 3600	;DUMMY SCORE EVENT
</CsScore>

</CsoundSynthesizer>