PrePiano.csd
Written by Iain McCurdy
**NOT WORKING ON WINDOWS**

<CsoundSynthesizer>

<CsOptions>
-odac
</CsOptions>

<CsInstruments>

sr 		= 	44100	;SAMPLE RATE
ksmps 		= 	32	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 		= 	2	;NUMBER OF CHANNELS (2=STEREO)

;FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		FLcolor		255, 255, 240, 0, 0, 0

;			LABEL       | WIDTH | HEIGHT | X | Y
		FLpanel	"prepiano",   1000,    710,    5,  5

;BORDERS				TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	" ", 	8,      9,     15,    490,   120,   505, 25	;RATTLE 1
ih		 	FLbox  	" ", 	8,      9,     15,    490,   120,   505, 170	;RUBBER 1
ih		 	FLbox  	" ", 	8,      9,     15,    240,   120,   505, 315	;BOUNDARY CONDITION L
ih		 	FLbox  	" ", 	8,      9,     15,    240,   120,   755, 315	;BOUNDARY CONDITION R
;BORDERS				                                                                                                                                             	TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ihtitle		 	FLbox  	"Physical model of a Cageian prepared piano. Algorithm written by Stefan Bilbao. Opcode ported for Csound by John ffitch. Example written by Iain McCurdy.", 	8,      2,     24,    490,    200,   505, 500	;TITLE

;TEXT BOXES						TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"Rattle 1",		1,      4,     14,     70,     10,   510, 35
ih		 	FLbox  	"Rubber 1",		1,      4,     14,     70,     10,   510, 180
ih		 	FLbox  	"Boundary Condition L",	1,      4,     14,    150,     10,   510, 325
ih		 	FLbox  	"Boundary Condition R",	1,      4,     14,    150,     10,   760, 325
ih		 	FLbox  	"Clamped ",		1,      2,    11,     50,     10,   560, 358
ih		 	FLbox  	"Pivoting",		1,      2,    11,     50,     10,   560, 383
ih		 	FLbox  	"Free    ",		1,      2,    11,     50,     10,   560, 408
ih		 	FLbox  	"Clamped ",		1,      2,    11,     50,     10,   810, 358
ih		 	FLbox  	"Pivoting",		1,      2,    11,     50,     10,   810, 383
ih		 	FLbox  	"Free    ",		1,      2,    11,     50,     10,   810, 408


;BUTTONS						ON | OFF | TYPE | WIDTH | HEIGHT | X | Y | OPCODE | INS | STARTTIM | DUR
gkOnOff,ihOnOff		FLbutton	"Note On/Off",	1,    0,    22,    150,     30,    25, 10,    0,     2,      0,      -1
gkrattle1,ihrattle1	FLbutton	"On/Off",	1,    0,     4,     60,     30,   525, 60,    -1
gkrubber1,ihrubber1	FLbutton	"On/Off",	1,    0,     4,     60,     30,   525, 205,   -1
FLsetColor2	255, 255, 50, ihOnOff		;SET SECONDARY COLOUR TO YELLOW

;VALUE DISPLAY BOXES	LABEL  | WIDTH | HEIGHT | X |  Y
idfreqS		FLvalue	" ",      50,     20,    25,   50
idD		FLvalue	" ",      50,     20,    25,  100
idK		FLvalue	" ",      50,     20,    25,  150
idT30		FLvalue	" ",      50,     20,    25,  200
idB		FLvalue	" ",      50,     20,    25,  250
idmass		FLvalue	" ",      50,     20,    25,  300
idfreqH		FLvalue	" ",      50,     20,    25,  350
idinit		FLvalue	" ",      50,     20,    25,  400
idpos		FLvalue	" ",      50,     20,    25,  450
idvel		FLvalue	" ",      50,     20,    25,  500
idsfreq		FLvalue	" ",      50,     20,    25,  550
idsspread	FLvalue	" ",      50,     20,    25,  600
idOutGain	FLvalue	" ",      50,     20,    25,  650

;TEXT BOX INPUT 					MIN | MAX |  STEP | TYPE | WIDTH | HEIGHT | X | Y
gkposRat1, ihposRat1	FLtext	"Position",		0,     1,   .0001,    1,    50,     25,   610, 60 
gkMDRRat1, ihMDRRat1	FLtext	"Mass Density Ratio",	0,     1,   .0001,    1,    50,     25,   680, 60 
gkFrqRat1, ihFrqRat1	FLtext	"Frequency",		0,  1000,       1,    1,    50,     25,   750, 60 
gkLenRat1, ihLenRat1	FLtext	"Length",		0,     1,   0.001,    1,    50,     25,   820, 60 

gkposRub1, ihposRub1	FLtext	"Position",		0,     1,   .0001,    1,    50,     25,   610, 205 
gkMDRRub1, ihMDRRub1	FLtext	"Mass Density Ratio",	0,     1,   .0001,    1,    50,     25,   680, 205 
gkFrqRub1, ihFrqRub1	FLtext	"Frequency",		0,  1000,       1,    1,    50,     25,   750, 205 
gkLosRub1, ihLosRub1	FLtext	"Loss",			0,     1,   0.001,    1,    50,     25,   820, 205 

;SET INITIAL VALUES		VALUE | HANDLE
		FLsetVal_i	1,      ihrattle1
		FLsetVal_i	.6,     ihposRat1
		FLsetVal_i	.1,     ihMDRRat1
		FLsetVal_i	100,    ihFrqRat1
		FLsetVal_i	.1,     ihLenRat1

		FLsetVal_i	1,      ihrubber1
		FLsetVal_i	.7,     ihposRub1
		FLsetVal_i	.1,     ihMDRRub1
		FLsetVal_i	500,    ihFrqRub1
		FLsetVal_i	.1,     ihLosRub1

;SLIDERS				            					MIN |   MAX   | EXP | TYPE |   DISP    | WIDTH | HEIGHT | X  | Y
gkfreqS, ihfreqS		FLslider	"String Frequency (i-rate)",		20,   10000,    -1,    23,   idfreqS,     400,    20,    75,   50
gkD, ihD			FLslider	"Detuning (i-rate)",			0,     5000,     0,    23,   idD,         400,    20,    75,  100
gkK, ihK			FLslider	"Stiffness (i-rate)",			-100,   100,     0,    23,   idK,         400,    20,    75,  150
gkT30, ihT30			FLslider	"30 dB Decay time (i-rate)",		.1,      30,     0,    23,   idT30,       400,    20,    75,  200
gkB, ihB			FLslider	"High Frequency Loss (i-rate)",		.0001,    1,     0,    23,   idB,         400,    20,    75,  250
gkmass, ihmass			FLslider	"Hammer Mass (i-rate)",			.0001,   10,     0,    23,   idmass,      400,    20,    75,  300
gkfreqH, ihfreqH		FLslider	"Hammer Frequency (i-rate)",		20,   20000,    -1,    23,   idfreqH,     400,    20,    75,  350
gkinit, ihinit			FLslider	"Hammer Initial Position (i-rate)",	-1,       1,     0,    23,   idinit,      400,    20,    75,  400
gkpos, ihpos			FLslider	"Hammer Position Along String (i-rate)",.004,  .996,     0,    23,   idpos,       400,    20,    75,  450
gkvel, ihvel			FLslider	"Normalised String Velocity (i-rate)",	0,      100,     0,    23,   idvel,       400,    20,    75,  500
gksfreq, ihsfreq		FLslider	"Scanning Frequency (i-rate)",		0,      100,     0,    23,   idsfreq,     400,    20,    75,  550
gksspread, ihsspread		FLslider	"Scanning Frequency Spread (i-rate)",	0,        1,     0,    23,   idsspread,   400,    20,    75,  600
gkOutGain, ihOutGain		FLslider	"Output Gain",				0,        1,     0,    23,   idOutGain,   400,    20,    75,  650

;COUNTERS								MIN | MAX | STEP1 | STEP2 | TYPE | WIDTH | HEIGHT | X | Y | OPCODE
gkNS, ihNS 			FLcount  "Number of Strings", 		1,    50,    1,       1,     2,     120,     20,   300, 10,    -1

FLcolor2	255, 255, 50		;SET SECONDARY COLOUR TO YELLOW

;;;;;;;;;;;;;;;;;;;BOUNDARY CONDITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GENERAL_TEXT_SETTINGS			isize, ifont, ialign, ired, igreen, iblue
			FLlabel		13,      1,       1,   255,  255,    240		;NUMBERS MADE INVISIBLE

;			FLBUTBANK 	TYPE | NUMX | NUMY | WIDTH | HEIGHT | X | Y | IOPCODE | P1 | P2 | P3
gkbcL, ihbcL		FLbutBank	12,     1,     3,     25,    75,    525, 350,    -1	;-1 = OPCODE FUNCTION NOT USED 
gkbcR, ihbcR		FLbutBank	12,     1,     3,     25,    75,    775, 350,    -1	;-1 = OPCODE FUNCTION NOT USED

;GENERAL_TEXT_SETTINGS			isize, ifont, ialign, ired, igreen, iblue
			FLlabel		13,      5,      4,   0,      0,     0		;LABELS MADE VISIBLE AGAIN

;SET INITIAL VALUES OF FLTK VALUATORS
;				VALUE | HANDLE
		FLsetVal_i	100, 	ihfreqS
		FLsetVal_i	3, 	ihNS
		FLsetVal_i	0, 	ihD
		FLsetVal_i	1, 	ihK
		FLsetVal_i	3, 	ihT30
		FLsetVal_i	.002, 	ihB
		FLsetVal_i	2, 	ihbcL
		FLsetVal_i	2, 	ihbcR
		FLsetVal_i	1, 	ihmass
		FLsetVal_i	5000, 	ihfreqH
		FLsetVal_i	-.01, 	ihinit
		FLsetVal_i	.09, 	ihpos
		FLsetVal_i	50, 	ihvel
		FLsetVal_i	0, 	ihsfreq
		FLsetVal_i	.1, 	ihsspread
		FLsetVal_i	.5, 	ihOutGain

		FLpanel_end

		FLcolor2	255, 255, 240

;INSTRUCTIONS AND INFO PANEL
;				                WIDTH | HEIGHT | X | Y
				FLpanel	" ", 	515,      700,  900,10
				FLscroll     	515,      700,  0, 0
;TEXT BOXES												TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                         prepiano                            ", 	1,      5,     14,    490,    20,     5,  0
ih		 	FLbox  	"-------------------------------------------------------------", 	1,      5,     14,    490,    20,     5,  20
ih		 	FLbox  	"The prepiano opcode implments a physical model of a Cagian   ", 	1,      5,     14,    490,    20,     5,  40
ih		 	FLbox  	"prepared piano. The user has control of the base frequency of", 	1,      5,     14,    490,    20,     5,  60
ih		 	FLbox  	"a string (or group of strings), the number of strings beneath", 	1,      5,     14,    490,    20,     5,  80
ih		 	FLbox  	"the hammer, the amount of detuning between a group of        ", 	1,      5,     14,    490,    20,     5, 100
ih		 	FLbox  	"strings, the stiffness of the strings, the time for a note to", 	1,      5,     14,    490,    20,     5, 120
ih		 	FLbox  	"decay by 30 dB, the amount of high frequency damping that    ", 	1,      5,     14,    490,    20,     5, 140
ih		 	FLbox  	"occurs during a note's decay, the mass of the hammer, the    ", 	1,      5,     14,    490,    20,     5, 160
ih		 	FLbox  	"frequency of the hammer's natural vibrations, the location   ", 	1,      5,     14,    490,    20,     5, 180
ih		 	FLbox  	"along the string's length at which the hammer strikes and the", 	1,      5,     14,    490,    20,     5, 200
ih		 	FLbox  	"velocity of the hammer as it moves to strike the string.     ", 	1,      5,     14,    490,    20,     5, 220
ih		 	FLbox  	"The user can choose the method of restraint applied to the   ", 	1,      5,     14,    490,    20,     5, 240
ih		 	FLbox  	"string independently for its left and right extremities.     ", 	1,      5,     14,    490,    20,     5, 260
ih		 	FLbox  	"Choosing 'clamped' reflects the normal method of binding a   ", 	1,      5,     14,    490,    20,     5, 280
ih		 	FLbox  	"piano string, 'pivoting' reflects the method used to bind a  ", 	1,      5,     14,    490,    20,     5, 300
ih		 	FLbox  	"note on a marimba and 'free' means that the string extremity ", 	1,      5,     14,    490,    20,     5, 320
ih		 	FLbox  	"is not bound at all.                                         ", 	1,      5,     14,    490,    20,     5, 340
ih		 	FLbox  	"To imbue the sound with some movement the author has         ", 	1,      5,     14,    490,    20,     5, 360
ih		 	FLbox  	"imagined the sound being received by a pick-up that moves to ", 	1,      5,     14,    490,    20,     5, 380
ih		 	FLbox  	"and fro along the length of the string. 'Scanning Spread'    ", 	1,      5,     14,    490,    20,     5, 400
ih		 	FLbox  	"controls the amplitude of this movement and 'Scanning        ", 	1,      5,     14,    490,    20,     5, 420
ih		 	FLbox  	"Frequency' controls the frequency of this movement.          ", 	1,      5,     14,    490,    20,     5, 440
ih		 	FLbox  	"The methods of Cagian piano preparation that are implemented ", 	1,      5,     14,    490,    20,     5, 460
ih		 	FLbox  	"in this opcode are the addition of hard objects that vibrate ", 	1,      5,     14,    490,    20,     5, 480
ih		 	FLbox  	"in sympathy with the string but are not firmly attached to   ", 	1,      5,     14,    490,    20,     5, 500
ih		 	FLbox  	"it rattles and soft objects that damp the string (rubbers).  ", 	1,      5,     14,    490,    20,     5, 520
ih		 	FLbox  	"For rattles the user is able to define its position along the", 	1,      5,     14,    490,    20,     5, 540
ih		 	FLbox  	"string, the mass/density ratio between rattle and string, its", 	1,      5,     14,    490,    20,     5, 560
ih		 	FLbox  	"frequency and its length.                                    ", 	1,      5,     14,    490,    20,     5, 580
ih		 	FLbox  	"For rubbers the user can define position, mass/density ratio,", 	1,      5,     14,    490,    20,     5, 600
ih		 	FLbox  	"frequency and loss.                                          ", 	1,      5,     14,    490,    20,     5, 620
ih		 	FLbox  	"By using function tables for the definition of rubbers and   ", 	1,      5,     14,    490,    20,     5, 640
ih		 	FLbox  	"rattles it is possible to have any amount of them applied to ", 	1,      5,     14,    490,    20,     5, 660
ih		 	FLbox  	"the same string. Unfortunately the rattles and rubbers part  ", 	1,      5,     14,    490,    20,     5, 680
ih		 	FLbox  	"of the Csound implementation of this physical model do not   ", 	1,      5,     14,    490,    20,     5, 700
ih		 	FLbox  	"appear to work so I have only supplied user control for one  ", 	1,      5,     14,    490,    20,     5, 720
ih		 	FLbox  	"rattle and one rubber (which don't work anyway).             ", 	1,      5,     14,    490,    20,     5, 740
ih		 	FLbox  	"As with many physical models we have the opportunity to      ", 	1,      5,     14,    490,    20,     5, 760
ih		 	FLbox  	"specify conditions that would not be possible in the real    ", 	1,      5,     14,    490,    20,     5, 780
ih		 	FLbox  	"world, for this reason it is easily to produce mathematical  ", 	1,      5,     14,    490,    20,     5, 800
ih		 	FLbox  	"procedures that quickly 'blow up' and produce extremely loud ", 	1,      5,     14,    490,    20,     5, 820
ih		 	FLbox  	"and distorted sounds. Approach parameter changes with caution", 	1,      5,     14,    490,    20,     5, 840
ih		 	FLbox  	"and protect your ears and speakers.                          ", 	1,      5,     14,    490,    20,     5, 860

				FLscrollEnd
				FLpanel_end

		FLrun	;RUN THE FLTK WIDGET THREAD
;END OF FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

instr	tables
;DEFINE FUNCTION TABLES FOR RATTLES AND RUBBERS
;	 				COUNT | POSITION | MASS DENSITY RATIO OF RATTLE/STRING | FREQUENCY OF RATTLE | VERTICAL LENGTH OF THE RATTLE/ RUBBER LOSS
girattles	ftgen	0, 0, 8, -2,   	1,        .6,                    .1,                          100,                       10
girubbers	ftgen	0, 0, 8, -2,   	1,        .7,                    .1,                          500,                       .1
endin


instr	1	;(ALWAYS ON - SEE SCORE) PLAYS FILE AND SENSES FADER MOVEMENT AND RESTARTS INSTR 2 FOR I-RATE CONTROLLERS
		
	;;;THE FOLLOWING LINES OF CODE UPDATE THE FUNCTION TABLE CONTENTS FOR RATTLES AND RUBBERS - UNFORTUNATELY THIS FEATURE DOESN'T SEEM TO WORK AT PRESENT IN CSOUND
#define		VAR		#gkrattle1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+2, 0, .001, $VAR
	
#define		VAR		#gkposRat1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+3, 0, .001, $VAR
	
#define		VAR		#gkMDRRat1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+4, 0, .001, $VAR
	
#define		VAR		#gkFrqRat1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+5, 0, .001, $VAR
	
#define		VAR		#gkLenRat1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+6, 0, .001, $VAR
	
#define		VAR		#gkrubber1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+7, 0, .001, $VAR
	
#define		VAR		#gkposRub1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+8, 0, .001, $VAR
	
#define		VAR		#gkMDRRub1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+9, 0, .001, $VAR
	
#define		VAR		#gkFrqRub1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+10, 0, .001, $VAR
	
#define		VAR		#gkLosRub1#
	ktrigger$VAR	changed		$VAR
			schedkwhen	ktrigger$VAR, 0, 0, p1+11, 0, .001, $VAR
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ktrigger		changed	gkfreqS, gkD, gkK, gkT30, gkB, gkmass, gkfreqH, gkinit, gkpos, gkvel, gksfreq, gksspread, gkNS, gkrattle1, gkposRat1, gkMDRRat1, gkFrqRat1, gkLenRat1, gkrubber1, gkposRub1, gkMDRRub1, gkFrqRub1, gkLosRub1	;GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
;			TRIGGER  | IMINTIM | IMAXNUM | IINSNUM | IWHEN | IDUR (-1 MEANS A NOTE OF INFINITE DURATION)
	schedkwhen	ktrigger,     0,        0,        2,        0,    -1	;RESTART INSTRUMENT 2 WITH A SUSTAINED (HELD) NOTE WHENEVER kSwitch=1
endin

instr	2	;SOUND PRODUCING INSTRUMENT
	if	gkOnOff!=0	kgoto	CONTINUE	;IF FLTK ON/OFF SWITCH IS *NOT* OFF, SKIP TO 'CONTINUE' LABEL
				turnoff			;TURNOFF THIS INSTRUMENT IMMEDIATELY
	CONTINUE:  					;LABEL

	;OUTPUTS OPCODE		BASE-FREQ  | NUM_OF_STRINGS | DETUNING | STIFFNESS | 30 DB DECAY TIME | HIGH_FREQUENCY_LOSS | LEFT_BOUNDARY_CONDITION | RIGHT_BOUNDARY_CONDITION | HAMMER_MASS | HAMMER_FREQUENCY | HAMMER_INITIAL_POSITION | POSITION_ALONG_STRING | HAMMER_VELOCITY | SCANNING_FREQ | SCANNING_FREQ_SPREAD | RATTLES_FUNCTION_TABLE | RUBBERS_FUNCTION_TABLE             
	al,ar 	prepiano 	i(gkfreqS),     i(gkNS),       i(gkD),     i(gkK),      i(gkT30),             i(gkB),                 gkbcL+1,                   gkbcR+1,            i(gkmass),     i(gkfreqH),             i(gkinit),              i(gkpos),            i(gkvel),       i(gksfreq),        i(gksspread),            girattles,               girubbers
		outs 		al * gkOutGain, ar * gkOutGain
endin


instr	3,4,5,6,7	;UPDATE RATTLES FUNCTION TABLE
	tableiw 	p4, p1-3, girattles
endin

instr	8,9,10,11,12	;UPDATE RUBBERS FUNCTION TABLE
	tableiw 	p4, p1-8, girubbers
endin

</CsInstruments>

<CsScore>
i "tables" 0 3600
i 1 0 3600	;INSTR 1 (SCANNING FOR I-RATE PARAMETER CHANGES) PLAYS A NOTE FOR 1 HOUR (AND KEEPS PERFORMANCE GOING)
</CsScore>

</CsoundSynthesizer>