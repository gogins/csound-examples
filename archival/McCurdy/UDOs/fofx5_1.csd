fofx5udoexample.csd
Written by Iain McCurdy, 2012

<CsoundSynthesizer>

<CsOptions>
-odac -M0 -+rtmidi=virtual -dm0 -b800
;--displays
</CsOptions>

<CsInstruments>
sr 	= 	44100
ksmps 	= 	32
nchnls 	= 	1
0dbfs	=	1

;FLTK INTERFACE CODE---------------------------------------------------------------------------------------------------------------------------------------------------------------------
FLcolor	255, 255, 255, 0, 0, 0
		FLpanel	"FOFx5 UDO Example", 630, 660, 0, 0


;VALUE DISPLAY BOXES	LABEL | WIDTH | HEIGHT | X  | Y
idvibdep		FLvalue	"",	 50,      18,    5,   35
idvowel			FLvalue	"",	 50,      18,    5,   85
idoct			FLvalue	"",	 50,      18,    5,  135                                                    
                                                  
;SLIDERS							MIN   |  MAX | EXP | TYPE |  DISP   | WIDTH | HEIGHT | X  | Y
gkvibdep, ihvibdep	FLslider 	"Vibrato Depth",	0,       0.4,   0,   23,   idvibdep,   620,     25,    5,   10
gkvowel, ihvowel	FLslider 	"Vowel (A-E-I-O-U)",	0,         1,   0,   23,   idvowel,    620,     25,    5,   60
gkoct, ihoct		FLslider 	"Octave Division",	0,         4,   0,   23,   idoct,      620,     25,    5,  110

;COUNTERS					MIN | MAX | STEP1 | STEP2 | TYPE | WIDTH | HEIGHT | X | Y | OPCODE
gkvoice, ihvoice 	FLcount  "Voice", 	0,     4,     1,      1,      2,   100,      25,   265,160,   -1
;TEXT BOXES										TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"0=Bass 1=Tenor 2=Countertenor 3=Alto 4=Soprano", 	1,      5,     14,    620,    20,     5, 200

;CREATE A FLTK VIRTUAL KEYBOARD WITHIN THIS WINDOW
FLvkeybd "", 624, 120, 3, 230

;TEXT BOXES														TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                                UDO - fofx5                                  ", 	1,      6,     14,    620,    20,     5,  360
ih		 	FLbox  	"-----------------------------------------------------------------------------", 	1,      5,     14,    620,    20,     5,  380
ih		 	FLbox  	"This UDO is a basic implementation of the algorithm implemented in the       ", 	1,      5,     14,    620,    20,     5,  400
ih		 	FLbox  	"example 'fofx5.csd'.                                                         ", 	1,      5,     14,    620,    20,     5,  420
ih		 	FLbox  	"Note that the FLTK virtual keyboard can be played from the computer's        ", 	1,      5,     14,    620,    20,     5,  440
ih		 	FLbox  	"alphanumeric keyboard when it has focus.                                     ", 	1,      5,     14,    620,    20,     5,  460
ih		 	FLbox  	"                                                                             ", 	1,      5,     14,    620,    20,     5,  480
ih		 	FLbox  	"asig   fofx5   kfund,kvowel,koct,ivoice                                      ", 	1,      5,     14,    620,    20,     5,  500
ih		 	FLbox  	"                                                                             ", 	1,      5,     14,    620,    20,     5,  520
ih		 	FLbox  	"Performance                                                                  ", 	1,      8,     14,    620,    20,     5,  540
ih		 	FLbox  	"kfund  -  fundemental frequency                                              ", 	1,      5,     14,    620,    20,     5,  560
ih		 	FLbox  	"kvowel -  vowel (A - E - I - O - U), range 0 - 1                             ", 	1,      5,     14,    620,    20,     5,  580
ih		 	FLbox  	"koct   -  octave division, normally zero                                     ", 	1,      5,     14,    620,    20,     5,  600
ih		 	FLbox  	"ivoice -  integer in the range 0 to 4 corresponding to voice type:           ", 	1,      5,     14,    620,    20,     5,  620
ih		 	FLbox  	"           0=bass, 1=tenor, 2=countertenor, 3=alto, 4=soprano                ", 	1,      5,     14,    620,    20,     5,  640

;SET INITIAL VALUES FOR VALUATORS 	VALUE | HANDLE
			FLsetVal_i	0, 	ihvibdep
			FLsetVal_i	0, 	ihvowel
			FLsetVal_i	0, 	ihoct
			FLsetVal_i	0, 	ihvoice

		FLpanel_end	; END OF PANEL CONTENTS
		FLrun		;RUN THE WIDGET THREAD

opcode 		fofx5, a, kkki
	kfund,kvowel,koct,ivoice	xin
	
	isine		ftgenonce	0, 0, 4096, 10, 1				;SINE WAVE
	iexp		ftgenonce	0, 0, 1024, 19, 0.5, 0.5, 270, 0.5		;EXPONENTIAL CURVE USED TO DEFINE THE ENVELOPE SHAPE OF FOF PULSES
	
	;FUNCTION TABLES STORING DATA FOR VARIOUS VOICE FORMANTS
	;THE FIRST VALUE OF EACH TABLE DEFINES THE NUMBER OF DATA ELEMENTS IN THE TABLE
	;THIS IS NEEDED BECAUSE TABLES SIZES MUST BE POWERS OF 2 TO FACILITATE INTERPOLATED TABLE READING (tablei) 
	;BASS
	iBF1		ftgentmp	0,  0, 8, -2,	4, 600,		400,	250,	350	;FREQ
	iBF2		ftgentmp	0,  0, 8, -2,	4, 1040,	1620,	1750,	600	;FREQ
	iBF3		ftgentmp	0,  0, 8, -2,	4, 2250,	2400,	2600,	2400	;FREQ
	iBF4		ftgentmp	0,  0, 8, -2,	4, 2450,	2800,	3050,	2675	;FREQ
	iBF5		ftgentmp	0,  0, 8, -2,	4, 2750,	3100,	3340,	2950	;FREQ
	        	
	iBDb1		ftgentmp	0, 0, 8, -2,	4, 0,	0,	0,	0	;dB
	iBDb2		ftgentmp	0, 0, 8, -2,	4, -7,	-12,	-30,	-20	;dB
	iBDb3		ftgentmp	0, 0, 8, -2,	4, -9,	-9,	-16,	-32	;dB
	iBDb4		ftgentmp	0, 0, 8, -2,	4, -9,	-12,	-22,	-28	;dB
	iBDb5		ftgentmp	0, 0, 8, -2,	4, -20,	-18,	-28,	-36	;dB
	        	
	iBBW1		ftgentmp	0, 0, 8, -2,	4, 60,	40,	60,	40	;BAND WIDTH
	iBBW2		ftgentmp	0, 0, 8, -2,	4, 70,	80,	90,	80	;BAND WIDTH
	iBBW3		ftgentmp	0, 0, 8, -2,	4, 110,	100,	100,	100	;BAND WIDTH
	iBBW4		ftgentmp	0, 0, 8, -2,	4, 120,	120,	120,	120	;BAND WIDTH
	iBBW5		ftgentmp	0, 0, 8, -2,	4, 130,	120,	120,	120	;BAND WIDTH
	;TENOR  	
	iTF1		ftgentmp	0, 0, 8, -2,	5, 650, 	400,	290,	400,	350	;FREQ
	iTF2		ftgentmp	0, 0, 8, -2,	5, 1080, 	1700,   1870,	800,	600	;FREQ
	iTF3		ftgentmp	0, 0, 8, -2,	5, 2650,	2600,   2800,	2600,	2700	;FREQ
	iTF4		ftgentmp	0, 0, 8, -2,	5, 2900,	3200,   3250,	2800,	2900	;FREQ
	iTF5		ftgentmp	0, 0, 8, -2,	5, 3250,	3580,   3540,	3000,	3300	;FREQ
	        	
	iTDb1		ftgentmp	0, 0, 8, -2,	5, 0,	0,	0,	0,	0	;dB
	iTDb2		ftgentmp	0, 0, 8, -2,	5, -6,	-14,	-15,	-10,	-20	;dB
	iTDb3		ftgentmp	0, 0, 8, -2,	5, -7,	-12,	-18,	-12,	-17	;dB
	iTDb4		ftgentmp	0, 0, 8, -2,	5, -8,	-14,	-20,	-12,	-14	;dB
	iTDb5		ftgentmp	0, 0, 8, -2,	5, -22,	-20,	-30,	-26,	-26	;dB
	        	
	iTBW1		ftgentmp	0, 0, 8, -2,	5, 80,	70,	40,	40,	40	;BAND WIDTH
	iTBW2		ftgentmp	0, 0, 8, -2,	5, 90,	80,	90,	80,	60	;BAND WIDTH
	iTBW3		ftgentmp	0, 0, 8, -2,	5, 120,	100,	100,	100,	100	;BAND WIDTH
	iTBW4		ftgentmp	0, 0, 8, -2,	5, 130,	120,	120,	120,	120	;BAND WIDTH                                         
	iTBW5		ftgentmp	0, 0, 8, -2,	5, 140,	120,	120,	120,	120	;BAND WIDTH
	;COUNTER TENOR
	iCTF1		ftgentmp	0, 0, 8, -2,	5, 660,	440,	270,	430,	370	;FREQ
	iCTF2		ftgentmp	0, 0, 8, -2,	5, 1120,	1800,	1850,	820,	630	;FREQ
	iCTF3		ftgentmp	0, 0, 8, -2,	5, 2750,	2700,	2900,	2700,	2750	;FREQ
	iCTF4		ftgentmp	0, 0, 8, -2,	5, 3000,	3000,	3350,	3000,	3000	;FREQ
	iCTF5		ftgentmp	0, 0, 8, -2,	5, 3350,	3300,	3590,	3300,	3400	;FREQ
	        	
	iTBDb1		ftgentmp	0, 0, 8, -2,	5, 0,	0,	0,	0,	0	;dB
	iTBDb2		ftgentmp	0, 0, 8, -2,	5, -6,	-14,	-24,	-10,	-20	;dB
	iTBDb3		ftgentmp	0, 0, 8, -2,	5, -23,	-18,	-24,	-26,	-23	;dB
	iTBDb4		ftgentmp	0, 0, 8, -2,	5, -24,	-20,	-36,	-22,	-30	;dB
	iTBDb5		ftgentmp	0, 0, 8, -2,	5, -38,	-20,	-36,	-34,	-30	;dB
	        	
	iTBW1		ftgentmp	0, 0, 8, -2,	5, 80,	70,	40,	40,	40	;BAND WIDTH
	iTBW2		ftgentmp	0, 0, 8, -2,	5, 90,	80,	90,	80,	60	;BAND WIDTH
	iTBW3		ftgentmp	0, 0, 8, -2,	5, 120,	100,	100,	100,	100	;BAND WIDTH
	iTBW4		ftgentmp	0, 0, 8, -2,	5, 130,	120,	120,	120,	120	;BAND WIDTH
	iTBW5		ftgentmp	0, 0, 8, -2,	5, 140,	120,	120,	120,	120	;BAND WIDTH
	;ALTO   	
	iAF1		ftgentmp	0, 0, 8, -2,	5, 800,	400,	350,	450,	325	;FREQ
	iAF2		ftgentmp	0, 0, 8, -2,	5, 1150,	1600,	1700,	800,	700	;FREQ
	iAF3		ftgentmp	0, 0, 8, -2,	5, 2800,	2700,	2700,	2830,	2530	;FREQ
	iAF4		ftgentmp	0, 0, 8, -2,	5, 3500,	3300,	3700,	3500,	2500	;FREQ
	iAF5		ftgentmp	0, 0, 8, -2,	5, 4950,	4950,	4950,	4950,	4950	;FREQ
	        	
	iADb1		ftgentmp	0, 0, 8, -2,	5, 0,	0,	0,	0,	0	;dB
	iADb2		ftgentmp	0, 0, 8, -2,	5, -4,	-24,	-20,	-9,	-12	;dB
	iADb3		ftgentmp	0, 0, 8, -2,	5, -20,	-30,	-30,	-16,	-30	;dB
	iADb4		ftgentmp	0, 0, 8, -2,	5, -36,	-35,	-36,	-28,	-40	;dB
	iADb5		ftgentmp	0, 0, 8, -2,	5, -60,	-60,	-60,	-55,	-64	;dB
	        	
	iABW1		ftgentmp	0, 0, 8, -2,	5, 50,	60,	50,	70,	50	;BAND WIDTH
	iABW2		ftgentmp	0, 0, 8, -2,	5, 60,	80,	100,	80,	60	;BAND WIDTH
	iABW3		ftgentmp	0, 0, 8, -2,	5, 170,	120,	120,	100,	170	;BAND WIDTH
	iABW4		ftgentmp	0, 0, 8, -2,	5, 180,	150,	150,	130,	180	;BAND WIDTH
	iABW5		ftgentmp	0, 0, 8, -2,	5, 200,	200,	200,	135,	200	;BAND WIDTH
	;SOPRANO
	iSF1		ftgentmp	0, 0, 8, -2,	5, 800,	350,	270,	450,	325	;FREQ
	iSF2		ftgentmp	0, 0, 8, -2,	5, 1150,	2000,	2140,	800,	700	;FREQ
	iSF3		ftgentmp	0, 0, 8, -2,	5, 2900,	2800,	2950,	2830,	2700	;FREQ
	iSF4		ftgentmp	0, 0, 8, -2,	5, 3900,	3600,	3900,	3800,	3800	;FREQ
	iSF5		ftgentmp	0, 0, 8, -2,	5, 4950,	4950,	4950,	4950,	4950	;FREQ
	        	
	iSDb1		ftgentmp	0, 0, 8, -2,	5, 0,	0,	0,	0,	0	;dB
	iSDb2		ftgentmp	0, 0, 8, -2,	5, -6,	-20,	-12,	-11,	-16	;dB
	iSDb3		ftgentmp	0, 0, 8, -2,	5, -32,	-15,	-26,	-22,	-35	;dB
	iSDb4		ftgentmp	0, 0, 8, -2,	5, -20,	-40,	-26,	-22,	-40	;dB
	iSDb5		ftgentmp	0, 0, 8, -2,	5, -50,	-56,	-44,	-50,	-60	;dB
	        	
	iSBW1		ftgentmp	0, 0, 8, -2,	5, 80,	60,	60,	70,	50	;BAND WIDTH
	iSBW2		ftgentmp	0, 0, 8, -2,	5, 90,	90,	90,	80,	60	;BAND WIDTH
	iSBW3		ftgentmp	0, 0, 8, -2,	5, 120,	100,	100,	100,	170	;BAND WIDTH
	iSBW4		ftgentmp	0, 0, 8, -2,	5, 130,	150,	120,	130,	180	;BAND WIDTH
	iSBW5		ftgentmp	0, 0, 8, -2,	5, 140,	200,	120,	135,	200	;BAND WIDTH
	
	ivoice		limit		ivoice,0,4	; PROTECT AGAINST OUT OF RANGE VALUES FOR ivoice
	;CREATE A MACRO FOR EACH FORMANT TO REDUCE CODE REPETITION
#define	FORMANT(N)
	#
	invals	table	0, iBF1+(ivoice*15)+$N-1					;NUMBER OF DATA ELEMENTS IN EACH TABLE
	invals		=		invals-1								;
	k$N.form 	tablei		1+(kvowel*invals), iBF1+(ivoice*15)+$N-1	;READ FORMANT FREQUENCY FROM TABLE
	k$N.db 		tablei		1+(kvowel*invals), iBDb1+(ivoice*15)+$N-1	;READ DECIBEL VALUE FROM TABLE
	k$N.amp		=		ampdb(k$N.db)					;CONVERT TO AN AMPLITUDE VALUE                                                
	k$N.band 	tablei		1+(kvowel*invals), iBBW1+(ivoice*15)+$N-1	;READ BANDWIDTH FROM TABLE
	#
	;EXECUTE MACRO MULTIPLE TIMES
	$FORMANT(1)                                                                                      
	$FORMANT(2)                                                                                      
	$FORMANT(3)                                                                                        
	$FORMANT(4)
	$FORMANT(5)
	;======================================================================================================================================================================
	iris		=		0.003
	idur		=		0.02
	idec		=		0.007
	iolaps		=		14850
	ifna		=		isine
	ifnb		=		iexp
	itotdur		=		3600
	;FOF===================================================================================================================================================================
	a1 		fof 		k1amp, kfund, k1form, koct, k1band, iris, idur, idec, iolaps, ifna, ifnb, itotdur
	a2 		fof 		k2amp, kfund, k2form, koct, k2band, iris, idur, idec, iolaps, ifna, ifnb, itotdur
	a3 		fof 		k3amp, kfund, k3form, koct, k3band, iris, idur, idec, iolaps, ifna, ifnb, itotdur
	a4 		fof 		k4amp, kfund, k4form, koct, k4band, iris, idur, idec, iolaps, ifna, ifnb, itotdur
	a5 		fof 		k5amp, kfund, k5form, koct, k5band, iris, idur, idec, iolaps, ifna, ifnb, itotdur
	;======================================================================================================================================================================

	;OUT===================================================================================================================================================================
	asig		=		(a1+a2+a3+a4+a5)/5
	xout		asig
endop

instr	1
	icps	cpsmidi							; INTERPRET MIDI NOTE AS A FREQUENCY VALUE
	kvib	lfo	gkvibdep,5,0					; VIBRATO FUNCTION
	kporttime	linseg	0,0.001,0.01
	kvowel	portk	gkvowel,kporttime
	asig	fofx5	icps*semitone(kvib), kvowel, gkoct, i(gkvoice)	; CALL fofx5 UDO
	kenv	linsegr	0,0.1,1,0.1,0          				; AMPLITUDE ENVELOPE
		out	asig*kenv					; SEND AUDIO TO OUTPUT
endin

</CsInstruments>

<CsScore>
f 0 3600
</CsScore>

</CsoundSynthesizer>

