; FIVE BANDPASS FILTERS IN PARALLEL IMITATE THE FILTERING CHARACTERISTICS OF THE MOUTH AND VOCAL TRACT WHEN EXPRESSING VOWELS.
; ain    -  Audio input to filters.
; kx     -  x-position in a vowel selection grid (A-E-I/U-O).
; ky     -  y-position in a vowel selection grid (A-E-I/U-O).
; kBWMlt -  Factor by which all filter bandwidths will be scaled.
; ivoice -  Integer in the range 0 to 4 corresponding to voice type: 0=bass, 1=tenor, 2=countertenor, 3=alto, 4=soprano

opcode	vowel_filter,a,akkki
	ain,kx,ky,kBWMlt,ivoice	xin
	;FUNCTION TABLES STORING DATA FOR VARIOUS VOICE FORMANTS
	;THE FIRST VALUE OF EACH TABLE DEFINES THE NUMBER OF DATA ELEMENTS IN THE TABLE
	; THIS IS NEEDED BECAUSE TABLES SIZES MUST BE POWERS OF 2 TO FACILITATE INTERPOLATED TABLE READING (tablei) 
	;BASS
	iBFA	ftgentmp	0,  0, 8, -2,	4, 600,		400,	250,	350	;FREQ
	iBFE	ftgentmp	0,  0, 8, -2,	4, 1040,	1620,	1750,	600	;FREQ
	iBFI	ftgentmp	0,  0, 8, -2,	4, 2250,	2400,	2600,	2400	;FREQ
	iBFO	ftgentmp	0,  0, 8, -2,	4, 2450,	2800,	3050,	2675	;FREQ
	iBFU	ftgentmp	0,  0, 8, -2,	4, 2750,	3100,	3340,	2950	;FREQ

	iBDbA	ftgentmp	0, 0, 8, -2,	4, 0,	0,	0,	0	;dB
	iBDbE	ftgentmp	0, 0, 8, -2,	4, -7,	-12,	-30,	-20	;dB
	iBDbI	ftgentmp	0, 0, 8, -2,	4, -9,	-9,	-16,	-32	;dB
	iBDbO	ftgentmp	0, 0, 8, -2,	4, -9,	-12,	-22,	-28	;dB
	iBDbU	ftgentmp	0, 0, 8, -2,	4, -20,	-18,	-28,	-36	;dB

	iBBWA	ftgentmp	0, 0, 8, -2,	4, 60,	40,	60,	40	;BAND WIDTH                  
	iBBWE	ftgentmp	0, 0, 8, -2,	4, 70,	80,	90,	80	;BAND WIDTH
	iBBWI	ftgentmp	0, 0, 8, -2,	4, 110,	100,	100,	100	;BAND WIDTH
	iBBWO	ftgentmp	0, 0, 8, -2,	4, 120,	120,	120,	120	;BAND WIDTH
	iBBWU	ftgentmp	0, 0, 8, -2,	4, 130,	120,	120,	120	;BAND WIDTH
	;TENOR
	iTFA	ftgentmp	0, 0, 8, -2,	5, 650, 	400,	290,	400,	350	;FREQ
	iTFE	ftgentmp	0, 0, 8, -2,	5, 1080, 	1700,   1870,	800,	600	;FREQ
	iTFI	ftgentmp	0, 0, 8, -2,	5, 2650,	2600,   2800,	2600,	2700	;FREQ
	iTFO	ftgentmp	0, 0, 8, -2,	5, 2900,	3200,   3250,	2800,	2900	;FREQ
	iTFU	ftgentmp	0, 0, 8, -2,	5, 3250,	3580,   3540,	3000,	3300	;FREQ

	iTDbA	ftgentmp	0, 0, 8, -2,	5, 0,	0,	0,	0,	0	;dB
	iTDbE	ftgentmp	0, 0, 8, -2,	5, -6,	-14,	-15,	-10,	-20	;dB
	iTDbI	ftgentmp	0, 0, 8, -2,	5, -7,	-12,	-18,	-12,	-17	;dB
	iTDbO	ftgentmp	0, 0, 8, -2,	5, -8,	-14,	-20,	-12,	-14	;dB
	iTDbU	ftgentmp	0, 0, 8, -2,	5, -22,	-20,	-30,	-26,	-26	;dB

	iTBWA	ftgentmp	0, 0, 8, -2,	5, 80,	70,	40,	40,	40	;BAND WIDTH
	iTBWE	ftgentmp	0, 0, 8, -2,	5, 90,	80,	90,	80,	60	;BAND WIDTH
	iTBWI	ftgentmp	0, 0, 8, -2,	5, 120,	100,	100,	100,	100	;BAND WIDTH
	iTBWO	ftgentmp	0, 0, 8, -2,	5, 130,	120,	120,	120,	120	;BAND WIDTH                                         
	iTBWU	ftgentmp	0, 0, 8, -2,	5, 140,	120,	120,	120,	120	;BAND WIDTH
	;COUNTER TENOR
	iCTFA	ftgentmp	0, 0, 8, -2,	5, 660,	440,	270,	430,	370	;FREQ
	iCTFE	ftgentmp	0, 0, 8, -2,	5, 1120,	1800,	1850,	820,	630	;FREQ
	iCTFI	ftgentmp	0, 0, 8, -2,	5, 2750,	2700,	2900,	2700,	2750	;FREQ
	iCTFO	ftgentmp	0, 0, 8, -2,	5, 3000,	3000,	3350,	3000,	3000	;FREQ
	iCTFU	ftgentmp	0, 0, 8, -2,	5, 3350,	3300,	3590,	3300,	3400	;FREQ

	iTBDbA	ftgentmp	0, 0, 8, -2,	5, 0,	0,	0,	0,	0	;dB
	iTBDbE	ftgentmp	0, 0, 8, -2,	5, -6,	-14,	-24,	-10,	-20	;dB
	iTBDbI	ftgentmp	0, 0, 8, -2,	5, -23,	-18,	-24,	-26,	-23	;dB
	iTBDbO	ftgentmp	0, 0, 8, -2,	5, -24,	-20,	-36,	-22,	-30	;dB
	iTBDbU	ftgentmp	0, 0, 8, -2,	5, -38,	-20,	-36,	-34,	-30	;dB

	iTBWA	ftgentmp	0, 0, 8, -2,	5, 80,	70,	40,	40,	40	;BAND WIDTH
	iTBWE	ftgentmp	0, 0, 8, -2,	5, 90,	80,	90,	80,	60	;BAND WIDTH
	iTBWI	ftgentmp	0, 0, 8, -2,	5, 120,	100,	100,	100,	100	;BAND WIDTH
	iTBWO	ftgentmp	0, 0, 8, -2,	5, 130,	120,	120,	120,	120	;BAND WIDTH
	iTBWU	ftgentmp	0, 0, 8, -2,	5, 140,	120,	120,	120,	120	;BAND WIDTH
	;ALTO
	iAFA	ftgentmp	0, 0, 8, -2,	5, 800,	400,	350,	450,	325	;FREQ
	iAFE	ftgentmp	0, 0, 8, -2,	5, 1150,	1600,	1700,	800,	700	;FREQ
	iAFI	ftgentmp	0, 0, 8, -2,	5, 2800,	2700,	2700,	2830,	2530	;FREQ
	iAFO	ftgentmp	0, 0, 8, -2,	5, 3500,	3300,	3700,	3500,	2500	;FREQ
	iAFU	ftgentmp	0, 0, 8, -2,	5, 4950,	4950,	4950,	4950,	4950	;FREQ

	iADbA	ftgentmp	0, 0, 8, -2,	5, 0,	0,	0,	0,	0	;dB
	iADbE	ftgentmp	0, 0, 8, -2,	5, -4,	-24,	-20,	-9,	-12	;dB
	iADbI	ftgentmp	0, 0, 8, -2,	5, -20,	-30,	-30,	-16,	-30	;dB
	iADbO	ftgentmp	0, 0, 8, -2,	5, -36,	-35,	-36,	-28,	-40	;dB
	iADbU	ftgentmp	0, 0, 8, -2,	5, -60,	-60,	-60,	-55,	-64	;dB

	iABWA	ftgentmp	0, 0, 8, -2,	5, 50,	60,	50,	70,	50	;BAND WIDTH
	iABWE	ftgentmp	0, 0, 8, -2,	5, 60,	80,	100,	80,	60	;BAND WIDTH
	iABWI	ftgentmp	0, 0, 8, -2,	5, 170,	120,	120,	100,	170	;BAND WIDTH
	iABWO	ftgentmp	0, 0, 8, -2,	5, 180,	150,	150,	130,	180	;BAND WIDTH
	iABWU	ftgentmp	0, 0, 8, -2,	5, 200,	200,	200,	135,	200	;BAND WIDTH
	;SOPRANO
	iSFA	ftgentmp	0, 0, 8, -2,	5, 800,	350,	270,	450,	325	;FREQ
	iSFE	ftgentmp	0, 0, 8, -2,	5, 1150,	2000,	2140,	800,	700	;FREQ
	iSFI	ftgentmp	0, 0, 8, -2,	5, 2900,	2800,	2950,	2830,	2700	;FREQ
	iSFO	ftgentmp	0, 0, 8, -2,	5, 3900,	3600,	3900,	3800,	3800	;FREQ
	iSFU	ftgentmp	0, 0, 8, -2,	5, 4950,	4950,	4950,	4950,	4950	;FREQ

	iSDbA	ftgentmp	0, 0, 8, -2,	5, 0,	0,	0,	0,	0	;dB
	iSDbE	ftgentmp	0, 0, 8, -2,	5, -6,	-20,	-12,	-11,	-16	;dB
	iSDbI	ftgentmp	0, 0, 8, -2,	5, -32,	-15,	-26,	-22,	-35	;dB
	iSDbO	ftgentmp	0, 0, 8, -2,	5, -20,	-40,	-26,	-22,	-40	;dB
	iSDbU	ftgentmp	0, 0, 8, -2,	5, -50,	-56,	-44,	-50,	-60	;dB
                                                                                                       
	iSBWA	ftgentmp	0, 0, 8, -2,	5, 80,	60,	60,	70,	50	;BAND WIDTH
	iSBWE	ftgentmp	0, 0, 8, -2,	5, 90,	90,	90,	80,	60	;BAND WIDTH
	iSBWI	ftgentmp	0, 0, 8, -2,	5, 120,	100,	100,	100,	170	;BAND WIDTH
	iSBWO	ftgentmp	0, 0, 8, -2,	5, 130,	150,	120,	130,	180	;BAND WIDTH
	iSBWU	ftgentmp	0, 0, 8, -2,	5, 140,	200,	120,	135,	200	;BAND WIDTH
		
	;A TEXT MACRO IS DEFINED THAT WILL BE THE CODE FOR DERIVING DATA FOR EACH FORMANT. A MACRO IS USED TO AVOID HAVING TO USING CODE REPETITION AND TO EASIER FACICLITATE CODE MODIFICATION
#define	FORMANT_DATA(N)	
	#
	invals		table		0, iBFA+(ivoice*15)+$N-1					;NUMBER OF DATA ELEMENTS IN EACH TABLE
	invals	=	invals-1									;
	kfreq$N_U	tablei		1+(kx*(3/5)*invals),iBFA+(ivoice*15)+$N-1			;READ DATA FOR FREQUENCY (UPPER EDGE OF PANEL)
	kfreq$N_L	tablei		1+(((1-kx)*(1/5))+(4/5)*invals),iBFA+(ivoice*15)+$N-1		;READ DATA FOR FREQUENCY (LOWER EDGE OF PANEL)
	kfreq$N		ntrpol		kfreq$N_L, kfreq$N_U, ky					;INTERPOLATE BETWEEN UPPER VALUE AND LOWER VALUE (DETERMINED BY Y-LOCATION ON PANEL)                          
	kdbamp$N_U	tablei		1+(kx*(3/5)*invals),iBDbA+(ivoice*15)+$N-1			;READ DATA FOR INTENSITY (UPPER EDGE OF PANEL)                                      
	kdbamp$N_L	tablei		1+(((1-kx)*(1/5))+(4/5)*invals),iBDbA+(ivoice*15)+$N-1		;READ DATA FOR INTENSITY (LOWER EDGE OF PANEL)                                      
	kdbamp$N	ntrpol		kdbamp$N_L, kdbamp$N_U, ky                   			;INTERPOLATE BETWEEN UPPER VALUE AND LOWER VALUE (DETERMINED BY Y-LOCATION ON PANEL)
	kbw$N_U		tablei		1+(kx*(3/5)*invals),iBBWA+(ivoice*15)+$N-1			;READ DATA FOR BANDWIDTH (UPPER EDGE OF PANEL)                                      
	kbw$N_L		tablei		1+(((1-kx)*(1/5))+(4/5)*invals),iBBWA+(ivoice*15)+$N-1		;READ DATA FOR BANDWIDTH (LOWER EDGE OF PANEL)                                      
	kbw$N		ntrpol		kbw$N_L, kbw$N_U, ky						;INTERPOLATE BETWEEN UPPER VALUE AND LOWER VALUE (DETERMINED BY Y-LOCATION ON PANEL)
	#												;END OF MACRO!

;READING DATA FOR FORMANTS (MACROS IMPLEMENTED)
	$FORMANT_DATA(1)
	$FORMANT_DATA(2)
	$FORMANT_DATA(3)
	$FORMANT_DATA(4)
	$FORMANT_DATA(5)

	aBPF1	butbp	ain, kfreq1, kbw1*kBWMlt		;FORMANT 1
	aBPF2	butbp	ain, kfreq2, kbw1*kBWMlt		;FORMANT 2
	aBPF3	butbp	ain, kfreq3, kbw1*kBWMlt		;FORMANT 3
	aBPF4	butbp	ain, kfreq4, kbw1*kBWMlt		;FORMANT 4
	aBPF5	butbp	ain, kfreq5, kbw1*kBWMlt		;FORMANT 5
	
	;FORMANTS ARE MIXED AND MULTIPLIED BOTH BY INTENSITY VALUES DERIVED FROM TABLES 
	aMix	sum	aBPF1*(ampdbfs(kdbamp1)),aBPF2*(ampdbfs(kdbamp2)),aBPF3*(ampdbfs(kdbamp3)),aBPF4*(ampdbfs(kdbamp4)),aBPF5*(ampdbfs(kdbamp5))

		xout	aMix
endop

