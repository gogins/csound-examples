<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
/*
Transversal Meditation
For six voice flute choir
Lee Zakian
4/3/2003 9:44:56 PM

Based on the sonority exercise of Marcel Moyse (1934, Leduc)
A descending chromatic scale, modulating every two measures,
is present throughout. At times it is in the forefront, and at times
it is obscured with other material.

INSTRUMENTS		SIGNAL FLOW		PANNED OUTPUT

1	Piccolo		Instr	1/91/97-L/101		Mixer Channel 1/Out: L-R
2	Flute 1			2/92/97-R/101		Mixer Channel 2/Out: L-R
3	Flute 2			3/93/98-L/101		Mixer Channel 3/Out: L-R
4	Alto Flute		4/78/94/98-R/101	Mixer Channel 4/Out: L-R
5	Bass Flute		5/79/95/99-L/101	Mixer Channel 5/Out: L-R
6	Contrabass Flute	6/96/99-R/101		Mixer Channel 6/Out: L-R
7	Fl 1 octave harmony	7/92/100/101		Mixer Channel 7/Out: L-R	

===============
78	Chorus Effect	(Alto Flute)
79	Flanger Effect	(Bass Flute)	
===============	

===================	
90	EQ piccolo		
91	EQ flute 1		
92	EQ flute 2	
93	EQ alto flute		
94	EQ bass flute		
95	EQ contrabass flute
96	EQ flute 1 octave harmony	
===================	

======================================
97	Stereo Reverb L=piccolo, R=flute 1		
98	Stereo Reverb L=flute 2, R=alto flute		
99	Stereo Reverb L=bass flute, R=contrabass flute
100	Reverb flute 1 octave harmony				
======================================	

==================
101	MIXER: 7 in 2 out	
==================

*****EDITING PARMETERS OF THE FLUTE CHOIR

1.) Attack, decay, high partial trim, and vibrato depth are assigned
to variable tables, set to the specific range of each instrument.
2.) Dynamics should be adjusted with P8 & P9. These are the
amplitude ramp and the peak volume, respectively.
3.) Equalization and reverb are assigned to each instrument, with
several variable settings for each.
4.) Portamento is assigned with a conditional statement, which at present
offers the choice between a minimal connection or a sharp glissando.
5.) P values are used to vary pitch, amplitude, and vibrato speed.
6.) Chiff and breath noise are used minimally, but may be increased in the
orchestra, or in the score tables.
*/

sr 		= 44100
kr 		= 4410
ksmps 		= 10
nchnls 		= 2
zakinit   	30, 30

;=====================
	instr 1	;Piccolo
;range:	9.02 - 11.11	D5 - B7
;=====================
idur    	=       	abs(p3)	;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	(p6=0 ? 0.005 : 0.35)	
		;portamento:glissando from P6 pitch, minimal pitch ramp when P6=0
iamp    	=       	p4	;tied note starts at amp ramp
;=====================
;VARIABLE TABLES
;=====================
iatkfn	=	6	;attack	
idecfn	=	7	;decay
icutfn	=	8	;high partials trim
ivdfn	=	10	;vibrato depth
;=====================
;ATTACK
;===================== 
ioctat	=	octpch(p5)
iminat	=	octpch(11.11)
imaxat	=	octpch(9.02)
irngat	=	iminat-imaxat
indxat	=	(ioctat-iminat)/irngat
iatt	tablei	indxat, iatkfn, 1
;=====================
;DECAY
;=====================
ioctdc	=	octpch(p5)
imndc	=	octpch(9.02)
imxdc	=	octpch(11.11)
irngdc	=	imndc-imxdc
indxd	=	idur
indxdc	=	indxd+(ioctdc-imndc)/irngdc
idec	tablei	indxdc, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	1
irise   	=       	idur*p9	;0.1 = decresendo, 0.9 = crescendo, 0.5 = peak in middle
i1      	=       	-1	;tied note phase
i2      	=       	-1       	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival              	;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0           	;reset phase for 1st note
i2      	=       	0.25      	;vibrato phase offset
iamp    	=       	0           	;set start amp
iatt    	=       	0.01      	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust		;create amplitude ramp
amp    		linseg  	iamp, iatt, iamp, ilen, iamp, idec, iamp
if      	ir == 1 goto pitch  			;no chiff on tied notes
ichiff  		=       	p8*.2	               	;chiff set to 20% of amp ramp
ifac1   		=       	(p5 >11.00 ? 2.0 : 0.05)	;balance chiff with register
ifac2   		=       	(p5 >11.00 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp*.5, amp
achiff1		reson	anoise, 2000, 200, 1, 1	;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 400, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
kpramp	linseg  	ipch1, iport, ipch2, idur-iport, ipch2
kpch  	=       	kpramp
;=====================
;EXPRESSION 
;rise/fall, vibrato
;=====================
expr:
irise	=	(p9 >0 ? irise : iatt)
ifall	=	idur-irise
p8	=	((p8+p4) >0 ? p8 : -p4)
aslur   	linseg  	0, irise, p8, ifall, 0	;make vibrato
;=====================
;VIBRATO DEPTH
;=====================
ioctvd	=	octpch(p5)
iminvd	=	octpch(9.02)
imaxvd	=	octpch(11.11)
irngvd	=	iminvd-imaxvd
indxvd	=	(ioctvd-iminvd)/irngvd
ivibd	tablei	indxvd, ivdfn, 1
avib	oscili	ivibd*3.5, p10, 5, 0.25	;vibrato depth, speed, table, phase
avib	=	avib+0.5
aslur   	=       	aslur*avib
;=====================
;HIGH PARTIAL TRIM
;===================== 
ioct	=	octpch(p5)
imin	=	octpch(9.02)
imax	=	octpch(11.11)
irange	=	imin-imax
index	=	(ioct-imin)/irange
icut	tablei	index, icutfn, 1
;=====================
;PLAY 
;output to EQ instr
;=====================
play:			;waveform tables
apic1	oscil3  		amp+aslur, kpch, 17, i1		;fundamental		
apic2	oscil3  		(amp*1.5)+aslur, kpch, 18, i1	;partials 2, 3
apic3	oscil3  		(amp*2.5)+aslur, kpch, 19, i1	;partials 4, 5, 6, 7
apic4	oscil3  		(amp*3)+aslur, kpch, 20, i1	;partials 8, 9
apic5	oscil3  		(amp*1.5)+aslur, kpch, 21, i1	;partials 2, 3		
apic6	oscil3  		(amp*2)+aslur, kpch, 22, i1	;partials 4, 5
apic7	oscil3  		(amp*1.5)+aslur, kpch, 23, i1	;partials 2, 3
apic8	oscil3  		(amp*2)+aslur, kpch, 24, i1	;partials 4, 5
apic9	oscil3  		(amp*1.5)+aslur, kpch, 25, i1	;partials 2, 3
apic10	oscil3  		(amp*1.5)+aslur, kpch, 26, i1	;partials 2, 3
asig   	butterlp 	(apic1+apic2+apic3+apic4+apic5+apic6+apic7+apic8+apic9+apic10), icut, 1
	zawm		asig+achiff*kdclk, iout
	endin       

;=====================
	instr 2	;Flute 1
;range:	7.11 - 11.02	B3 - D7 
;=====================
idur    	=       	abs(p3)	;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	(p6=0 ? 0.005 : 0.35)
	    	;portamento:glissando from P6 pitch, minimal pitch ramp when P6=0
iamp    	=       	p4	;tied note starts at amp ramp
;=====================
;VARIABLE TABLES
;=====================
iatkfn	=	6	;attack	
idecfn	=	7	;decay
icutfn	=	8	;high partials trim
ibrthfn	=	9	;breath
ivdfn	=	10	;vibrato depth
;=====================
;ATTACK
;=====================   
ioctat	=	octpch(p5)
iminat	=	octpch(11.02)
imaxat	=	octpch(7.11)
irngat	=	iminat-imaxat
indxat	=	(ioctat-iminat)/irngat
iatt	tablei	indxat, iatkfn, 1
;=====================
;DECAY
;=====================
;index	=	idur
;idec	tablei	index, idecfn, 1

ioctdc	=	octpch(p5)
imndc	=	octpch(7.11)
imxdc	=	octpch(11.02)
irngdc	=	imndc-imxdc
indxd	=	idur
indxdc	=	indxd+(ioctdc-imndc)/irngdc
idec	tablei	indxdc, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	2
irise   	=       	idur*p9  ;0.1 = decresendo, 0.9 = crescendo, 0.5 = peak in middle
i1      	=       	-1         	;tied note phase
i2      	=       	-1          	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               	;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0           	;reset phase for 1st note
i2      	=       	0.25      	;vibrato phase offset
iamp    	=       	0           	;set start amp
iatt    	=       	0.05      	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust		;create amplitude ramp
amp     		linseg  	iamp, iatt, iamp, ilen, iamp, idec, iamp
if      	ir == 1 goto pitch  			;no chiff on tied notes
ichiff  		=       	p8*.1 			;chiff set to 10% of amp ramp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05)  	;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1	;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
kpramp	linseg  	ipch1, iport, ipch2, idur-iport, ipch2
kpch  	=       	kpramp
;=====================
;EXPRESSION 
;rise/fall, vibrato, breath
;=====================
expr:
irise	=	(p9 >0 ? irise : iatt)
ifall	=	idur-irise
p8	=	((p8+p4) >0 ? p8 : -p4)
aslur   	linseg  	0, irise, p8, ifall, 0	;make vibrato
;=====================
;VIBRATO DEPTH
;=====================
ioctvd	=	octpch(p5)
iminvd	=	octpch(7.11)
imaxvd	=	octpch(11.02)
irngvd	=	iminvd-imaxvd
indxvd	=	(ioctvd-iminvd)/irngvd
ivibd	tablei	indxvd, ivdfn, 1
avib	oscili	ivibd*2.5, p10, 5, 0.25	;vibrato depth, speed, table, phase
avib	=	avib+0.5
;=====================
;BREATH
;=====================
ioctbr	=	octpch(p5)
imnbr	=	octpch(7.11)
imxbr	=	octpch(11.02)
irngbr	=	imnbr-imxbr
indxbr	=	(ioctbr-imnbr)/irngbr
ibrth	tablei		indxbr, ibrthfn, 1
kenv1	linseg		0, .06, .9, .2, .9, p3-.16, .9, .02, 0
kenv2	linseg		0, .01, 1, p3-.02, 1, .01, 0
aflow	pinkish	kenv1*(p4/40)
asum	=	(ibrth+aflow+kenv1)*avib
aslur   	=       	(aslur*avib)+asum
;=====================
;HIGH PARTIAL TRIM
;===================== 
ioct	=	octpch(p5)
imin	=	octpch(7.11)
imax	=	octpch(11.02)
irange	=	imin-imax
index	=	(ioct-imin)/irange
icut	tablei	index, icutfn, 1
;=====================
;PLAY 
;output to EQ instr
;=====================
play:			;waveform tables
aflu1	oscil3  		amp+aslur, kpch, 1, i1		;fundamental		
aflu2	oscil3  		(amp*1.5)+aslur, kpch, 27, i1	;partials 2, 3
aflu3	oscil3  		(amp*2.5)+aslur, kpch, 28, i1	;partials 4, 5, 6
aflu4	oscil3  		(amp*1.5)+aslur, kpch, 29, i1	;partials 2, 3
aflu5	oscil3  		(amp*2)+aslur, kpch, 30, i1	;partials 4, 5
aflu6	oscil3  		(amp*1.5)+aslur, kpch, 31, i1	;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

;=====================
	instr 3	;Flute 2
;range:	7.11 - 11.02	B3 - D7 
;=====================
idur    	=       	abs(p3)	;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	(p6=0 ? 0.005 : 0.35) 
	  	;portamento:glissando from P6 pitch, minimal pitch ramp when P6=0
iamp    	=       	p4	;tied note starts at amp ramp
;=====================
;VARIABLE TABLES
;=====================
iatkfn	=	6	;attack	
idecfn	=	7	;decay
icutfn	=	8	;high partials trim
ibrthfn	=	9	;breath
ivdfn	=	10	;vibrato depth
;=====================
;ATTACK
;===================== 
ioctat	=	octpch(p5)
iminat	=	octpch(11.02)
imaxat	=	octpch(7.11)
irngat	=	iminat-imaxat
indxat	=	(ioctat-iminat)/irngat
iatt	tablei	indxat, iatkfn, 1
;=====================
;DECAY
;=====================
;index	=	idur/8
;idec	tablei	index, idecfn, 1

ioctdc	=	octpch(p5)
imndc	=	octpch(7.11)
imxdc	=	octpch(11.02)
irngdc	=	imndc-imxdc
indxd	=	idur
indxdc	=	indxd+(ioctdc-imndc)/irngdc
idec	tablei	indxdc, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	3
irise   	=       	idur*p9	;0.1 = decresendo, 0.9 = crescendo, 0.5 = peak in middle
i1      	=       	-1          	;tied note phase
i2      	=       	-1          	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               	;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0           	;reset phase for 1st note
i2      	=       	0.25      	;vibrato phase offset
iamp    	=       	0           	;set start amp
iatt    	=       	0.05      	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust		;create amplitude ramp
amp    		linseg  	iamp, iatt, iamp, ilen, iamp, idec, iamp
if      	ir == 1 goto pitch  			;no chiff on tied notes
ichiff  		=       	p8*.1 			;chiff set to 10% of amp ramp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05) 	;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1	;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
kpramp	linseg  	ipch1, iport, ipch2, idur-iport, ipch2
kpch  	=       	kpramp
;=====================
;EXPRESSION 
;rise/fall, vibrato, breath
;=====================
expr:
irise	=	(p9 >0 ? irise : iatt)
ifall	=	idur-irise
p8	=	((p8+p4) >0 ? p8 : -p4)
aslur   	linseg  	0, irise, p8, ifall, 0	;make vibrato
;=====================
;VIBRATO DEPTH
;=====================
ioctvd	=	octpch(p5)
iminvd	=	octpch(7.11)
imaxvd	=	octpch(11.02)
irngvd	=	iminvd-imaxvd
indxvd	=	(ioctvd-iminvd)/irngvd
ivibd	tablei	indxvd, ivdfn, 1
avib	oscili	ivibd*2.5, p10, 5, 0.25	;vibrato depth, speed, table, phase
avib	=	avib+0.5
;=====================
;BREATH
;=====================
ioctbr	=	octpch(p5)
imnbr	=	octpch(7.11)
imxbr	=	octpch(11.02)
irngbr	=	imnbr-imxbr
indxbr	=	(ioctbr-imnbr)/irngbr
ibrth	tablei		indxbr, ibrthfn, 1
kenv1	linseg		0, .06, .9, .2, .9, p3-.16, .9, .02, 0
kenv2	linseg		0, .01, 1, p3-.02, 1, .01, 0
aflow	pinkish	kenv1*(p4/40)
asum	=	(ibrth+aflow+kenv1)*avib
aslur   	=       	(aslur*avib)+asum
;=====================
;HIGH PARTIAL TRIM
;===================== 
ioct	=	octpch(p5)
imin	=	octpch(7.11)
imax	=	octpch(11.02)
irange	=	imin-imax
index	=	(ioct-imin)/irange
icut	tablei	index, icutfn, 1
;=====================
;PLAY 
;output to EQ instr
;=====================
play:			;waveform tables
aflu1	oscil3  		amp+aslur, kpch, 1, i1		;fundamental		
aflu2	oscil3  		(amp*1.5)+aslur, kpch, 27, i1	;partials 2, 3
aflu3	oscil3  		(amp*2.5)+aslur, kpch, 28, i1	;partials 4, 5, 6
aflu4	oscil3  		(amp*1.5)+aslur, kpch, 29, i1	;partials 2, 3
aflu5	oscil3  		(amp*2)+aslur, kpch, 30, i1	;partials 4, 5
aflu6	oscil3  		(amp*1.5)+aslur, kpch, 31, i1	;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

;=====================
	instr 4	;Alto Flute
;range:	7.05 - 10.05	F3 - F6 
;=====================
idur    	=       	abs(p3)	;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	(p6=0 ? 0.005 : 0.3)    	
		;portamento:glissando from P6 pitch, minimal pitch ramp when P6=0
iamp    	=       	p4	;tied note starts at amp ramp
;=====================
;VARIABLE TABLES
;=====================
iatkfn	=	6	;attack	
idecfn	=	7	;decay
icutfn	=	8	;high partials trim
ibrthfn	=	9	;breath
ivdfn	=	10	;vibrato depth
;=====================
;ATTACK
;=====================           
ioctat	=	octpch(p5)
iminat	=	octpch(10.05)
imaxat	=	octpch(7.05)
irngat	=	iminat-imaxat
indxat	=	(ioctat-iminat)/irngat
iatt	tablei	indxat, iatkfn, 1
;=====================
;DECAY
;=====================
;index	=	idur/8
;idec	tablei	index, idecfn, 1

ioctdc	=	octpch(p5)
imndc	=	octpch(7.05)
imxdc	=	octpch(10.05)
irngdc	=	imndc-imxdc
indxd	=	idur
indxdc	=	indxd+(ioctdc-imndc)/irngdc
idec	tablei	indxdc, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	4
irise   	=       	idur*p9 ;0.1 = decresendo, 0.9 = crescendo, 0.5 = peak in middle
i1      	=       	-1          	;tied note phase
i2      	=       	-1          	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               	;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0           	;reset phase for 1st note
i2      	=       	0.25      	;vibrato phase offset
iamp    	=       	0           	;set start amp
iatt    	=       	0.05     	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust		;create amplitude ramp
amp     		linseg  	iamp, iatt, iamp, ilen, iamp, idec, iamp
if      	ir == 1 goto pitch  			;no chiff on tied notes
ichiff  		=       	p8*.05 			;chiff set to 5% of amp ramp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05)  	;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1	;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
kpramp	linseg  	ipch1, iport, ipch2, idur-iport, ipch2
kpch  	=       	kpramp
;=====================
;EXPRESSION 
;rise/fall, vibrato, breath
;=====================
expr:
irise	=	(p9 >0 ? irise : iatt)
ifall	=	idur-irise
p8	=	((p8+p4) >0 ? p8 : -p4)
aslur   	linseg  	0, irise, p8, ifall, 0	;make vibrato
;=====================
;VIBRATO DEPTH
;=====================
ioctvd	=	octpch(p5)
iminvd	=	octpch(7.05)
imaxvd	=	octpch(10.05)
irngvd	=	iminvd-imaxvd
indxvd	=	(ioctvd-iminvd)/irngvd
ivibd	tablei	indxvd, ivdfn, 1
avib	oscili	ivibd*2, p10*2, 5, 0.25	;vibrato depth, speed, table, phase
avib	=	avib+0.5
;=====================
;BREATH
;=====================
ioctbr	=	octpch(p5)
imnbr	=	octpch(7.05)
imxbr	=	octpch(10.05)
irngbr	=	imnbr-imxbr
indxbr	=	(ioctbr-imnbr)/irngbr
ibrth	tablei		indxbr, ibrthfn, 1
kenv1	linseg		0, .06, .9, .2, .9, p3-.16, .9, .02, 0
kenv2	linseg		0, .01, 1, p3-.02, 1, .01, 0
aflow	pinkish	kenv1*(p4/25)
asum	=	(ibrth+aflow+kenv1)*avib
aslur   	=       	(aslur*avib)+asum
;=====================
;HIGH PARTIAL TRIM
;===================== 
ioct	=	octpch(p5)
imin	=	octpch(7.05)
imax	=	octpch(10.05)
irange	=	imin-imax
index	=	(ioct-imin)/irange
icut	tablei	index, icutfn, 1
;=====================
;PLAY 
;output to EQ instr
;=====================
play:			;waveform tables
aflu1	oscil3  		amp+aslur, kpch, 1, i1		;fundamental		
aflu2	oscil3  		(amp*1.5)+aslur, kpch, 27, i1	;partials 2, 3
aflu3	oscil3  		(amp*2.5)+aslur, kpch, 28, i1	;partials 4, 5, 6
aflu4	oscil3  		(amp*1.5)+aslur, kpch, 29, i1	;partials 2, 3
aflu5	oscil3  		(amp*2)+aslur, kpch, 30, i1	;partials 4, 5
aflu6	oscil3  		(amp*1.5)+aslur, kpch, 31, i1	;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

;=====================
	instr 5	;Bass Flute
;range:	7.00 - 10.00	C3 - C6
;=====================
idur    	=       	abs(p3)	;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	(p6=0 ? 0.005 : 0.2)
	    	;portamento:glissando from P6 pitch, minimal pitch ramp when P6=0
iamp    	=       	p4	;tied note starts at amp ramp
;=====================
;VARIABLE TABLES
;=====================
iatkfn	=	6	;attack	
idecfn	=	7	;decay
icutfn	=	8	;high partials trim
ibrthfn	=	9	;breath
ivdfn	=	10	;vibrato depth
;=====================
;ATTACK
;=====================     
ioctat	=	octpch(p5)
iminat	=	octpch(10.00)
imaxat	=	octpch(7.00)
irngat	=	iminat-imaxat
indxat	=	(ioctat-iminat)/irngat
iatt	tablei	indxat, iatkfn, 1
;=====================
;DECAY
;=====================
;index	=	idur/8
;idec	tablei	index, idecfn, 1

ioctdc	=	octpch(p5)
imndc	=	octpch(7.00)
imxdc	=	octpch(10.00)
irngdc	=	imndc-imxdc
indxd	=	idur
indxdc	=	indxd+(ioctdc-imndc)/irngdc
idec	tablei	indxdc, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	5
irise   	=       	idur*p9 ;0.1 = decresendo, 0.9 = crescendo, 0.5 = peak in middle
i1      	=       	-1          	;tied note phase
i2      	=       	-1          	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               	;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0           	;reset phase for 1st note
i2      	=       	0.25      	;vibrato phase offset
iamp    	=       	0           	;set start amp
iatt    	=       	0.05      	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust		;create amplitude ramp
amp     		linseg  	iamp, iatt, iamp, ilen, iamp, idec, iamp
if      	ir == 1 goto pitch  			;no chiff on tied notes
ichiff  		=       	p8*.03 			;chiff set to 3% of amp ramp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05)	;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1	;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
kpramp	linseg  	ipch1, iport, ipch2, idur-iport, ipch2
kpch  	=       	kpramp
;=====================
;EXPRESSION 
;rise/fall, vibrato, breath
;=====================
expr:
irise	=	(p9 >0 ? irise : iatt)
ifall	=	idur-irise
p8	=	((p8+p4) >0 ? p8 : -p4)
aslur   	linseg  	0, irise, p8, ifall, 0	;make vibrato
;=====================
;VIBRATO DEPTH
;=====================
ioctvd	=	octpch(p5)
iminvd	=	octpch(7.00)
imaxvd	=	octpch(10.00)
irngvd	=	iminvd-imaxvd
indxvd	=	(ioctvd-iminvd)/irngvd
ivibd	tablei	indxvd, ivdfn, 1
avib	oscili	ivibd*.7, p10, 5, 0.25	;vibrato depth, speed, table, phase
avib	=	avib+0.5
;=====================
;BREATH
;=====================
ioctbr	=	octpch(p5)
imnbr	=	octpch(7.00)
imxbr	=	octpch(10.00)
irngbr	=	imnbr-imxbr
indxbr	=	(ioctbr-imnbr)/irngbr
ibrth	tablei		indxbr, ibrthfn, 1
kenv1	linseg		0, .06, .9, .2, .9, p3-.16, .9, .02, 0
kenv2	linseg		0, .01, 1, p3-.02, 1, .01, 0
aflow	pinkish	kenv1*(p4/25)
asum	=	(ibrth+aflow+kenv1)*avib
aslur   	=       	(aslur*avib)+asum
;=====================
;HIGH PARTIAL TRIM
;===================== 
ioct	=	octpch(p5)
imin	=	octpch(7.00)
imax	=	octpch(10.00)
irange	=	imin-imax
index	=	(ioct-imin)/irange
icut	tablei	index, icutfn, 1
;=====================
;PLAY 
;output to EQ instr
;=====================
play:			;waveform tables
aflu1	oscil3  		amp+aslur, kpch, 1, i1		;fundamental		
aflu2	oscil3  		(amp*1.5)+aslur, kpch, 27, i1	;partials 2, 3
aflu3	oscil3  		(amp*2.5)+aslur, kpch, 28, i1	;partials 4, 5, 6
aflu4	oscil3  		(amp*1.5)+aslur, kpch, 29, i1	;partials 2, 3
aflu5	oscil3  		(amp*2)+aslur, kpch, 30, i1	;partials 4, 5
aflu6	oscil3  		(amp*1.5)+aslur, kpch, 31, i1	;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

;=====================
	instr 6	;Contrabass Flute
;range: 	6.00 to 9.00	C2 - C5
;===================== 
idur    	=       	abs(p3)	;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	(p6=0 ? 0.005 : 0.1)
	    	;portamento:glissando from P6 pitch, minimal pitch ramp when P6=0
iamp    	=       	p4	;tied note starts at amp ramp
;=====================
;VARIABLE TABLES
;=====================
iatkfn	=	6	;attack	
idecfn	=	7	;decay
icutfn	=	8	;high partials trim
ibrthfn	=	9	;breath
ivdfn	=	10	;vibrato depth
;=====================
;ATTACK
;=====================           
ioctat	=	octpch(p5)
iminat	=	octpch(9.00)
imaxat	=	octpch(6.00)
irngat	=	iminat-imaxat
indxat	=	(ioctat-iminat)/irngat
iatt	tablei	indxat, iatkfn, 1
;=====================
;DECAY
;=====================
;index	=	idur/8
;idec	tablei	index, idecfn, 1

ioctdc	=	octpch(p5)
imndc	=	octpch(6.00)
imxdc	=	octpch(9.00)
irngdc	=	imndc-imxdc
indxd	=	idur
indxdc	=	indxd+(ioctdc-imndc)/irngdc
idec	tablei	indxdc, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	6
irise   	=       	idur*p9 ;0.1 = decresendo, 0.9 = crescendo, 0.5 = peak in middle
i1      	=       	-1          	;tied note phase
i2      	=       	-1          	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               	;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0     	;reset phase for 1st note
i2      	=       	0.25      	;vibrato phase offset
iamp    	=       	0          	;set start amp
iatt    	=       	0.05      	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust		;create amplitude ramp
amp    		linseg  	iamp, iatt, iamp, ilen, iamp, idec, iamp
if      	ir == 1 goto pitch  			;no chiff on tied notes
ichiff  		=       	p8*.02 			;chiff set to 2% of amp ramp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05)	;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1	;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
kpramp	linseg  	ipch1, iport, ipch2, idur-iport, ipch2
kpch  	=       	kpramp
;=====================
;EXPRESSION 
;rise/fall, vibrato, breath
;=====================
expr:
irise	=	(p9 >0 ? irise : iatt)
ifall	=	idur-irise
p8	=	((p8+p4) >0 ? p8 : -p4)
aslur   	linseg  	0, irise, p8, ifall, 0	;make vibrato
;=====================
;VIBRATO DEPTH
;=====================
ioctvd	=	octpch(p5)
iminvd	=	octpch(6.00)
imaxvd	=	octpch(9.00)
irngvd	=	iminvd-imaxvd
indxvd	=	(ioctvd-iminvd)/irngvd
ivibd	tablei	indxvd, ivdfn, 1
avib	oscili	ivibd*.5, p10, 5, 0.25	;vibrato depth, speed, table, phase
avib	=	avib+0.5
;=====================
;BREATH
;=====================
ioctbr	=	octpch(p5)
imnbr	=	octpch(6.00)
imxbr	=	octpch(9.00)
irngbr	=	imnbr-imxbr
indxbr	=	(ioctbr-imnbr)/irngbr
ibrth	tablei		indxbr, ibrthfn, 1
kenv1	linseg		0, .06, .9, .2, .9, p3-.16, .9, .02, 0
kenv2	linseg		0, .01, 1, p3-.02, 1, .01, 0
aflow	pinkish	kenv1*(p4/25)
asum	=	(ibrth+aflow+kenv1)*avib
aslur   	=       	(aslur*avib)+asum
;=====================
;HIGH PARTIAL TRIM
;===================== 
ioct	=	octpch(p5)
imin	=	octpch(6.00)
imax	=	octpch(9.00)
irange	=	imin-imax
index	=	(ioct-imin)/irange
icut	tablei	index, icutfn, 1
;=====================
;PLAY 
;output to EQ instr
;=====================
play:			;waveform tables
aflu1	oscil3  		amp+aslur, kpch, 1, i1		;fundamental		
aflu2	oscil3  		(amp*1.2)+aslur, kpch, 27, i1	;partials 2, 3
aflu3	oscil3  		(amp*1.7)+aslur, kpch, 28, i1	;partials 4, 5, 6
aflu4	oscil3  		(amp*1.2)+aslur, kpch, 29, i1	;partials 2, 3
aflu5	oscil3  		(amp*1.5)+aslur, kpch, 30, i1	;partials 4, 5
aflu6	oscil3  		(amp*1.2)+aslur, kpch, 31, i1	;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

;=====================
	instr 7	;Flute 1 Octave Harmony
	;range:	7.11 - 11.02	B3 - D7 
;=====================
idur    	=       	abs(p3)	;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	(p6=0 ? 0.005 : 0.35)
	    	;portamento:glissando from P6 pitch, minimal pitch ramp when P6=0
iamp    	=       	p4	;tied note starts at amp ramp
;=====================
;VARIABLE TABLES
;=====================
iatkfn	=	6	;attack	
idecfn	=	7	;decay
icutfn	=	8	;high partials trim
ibrthfn	=	9	;breath
ivdfn	=	10	;vibrato depth
;=====================
;ATTACK
;=====================   
ioctat	=	octpch(p5)
iminat	=	octpch(11.02)
imaxat	=	octpch(7.11)
irngat	=	iminat-imaxat
indxat	=	(ioctat-iminat)/irngat
iatt	tablei	indxat, iatkfn, 1
;=====================
;DECAY
;=====================
;index	=	idur
;idec	tablei	index, idecfn, 1

ioctdc	=	octpch(p5)
imndc	=	octpch(7.11)
imxdc	=	octpch(11.02)
irngdc	=	imndc-imxdc
indxd	=	idur
indxdc	=	indxd+(ioctdc-imndc)/irngdc
idec	tablei	indxdc, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	7
irise   	=       	idur*p9  ;0.1 = decresendo, 0.9 = crescendo, 0.5 = peak in middle
i1      	=       	-1         	;tied note phase
i2      	=       	-1          	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               	;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0           	;reset phase for 1st note
i2      	=       	0.25      	;vibrato phase offset
iamp    	=       	0           	;set start amp
iatt    	=       	0.05      	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust		;create amplitude ramp
amp     		linseg  	iamp, iatt, iamp, ilen, iamp, idec, iamp
if      	ir == 1 goto pitch  			;no chiff on tied notes
ichiff  		=       	p8*.1 			;chiff set to 10% of amp ramp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05)  	;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1	;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
kpramp	linseg  	ipch1, iport, ipch2, idur-iport, ipch2
kpch  	=       	kpramp
;=====================
;EXPRESSION 
;rise/fall, vibrato, breath
;=====================
expr:
irise	=	(p9 >0 ? irise : iatt)
ifall	=	idur-irise
p8	=	((p8+p4) >0 ? p8 : -p4)
aslur   	linseg  	0, irise, p8, ifall, 0	;make vibrato
;=====================
;VIBRATO DEPTH
;=====================
ioctvd	=	octpch(p5)
iminvd	=	octpch(7.11)
imaxvd	=	octpch(11.02)
irngvd	=	iminvd-imaxvd
indxvd	=	(ioctvd-iminvd)/irngvd
ivibd	tablei	indxvd, ivdfn, 1
avib	oscili	ivibd*2.5, p10, 5, 0.25	;vibrato depth, speed, table, phase
avib	=	avib+0.5
;=====================
;BREATH
;=====================
ioctbr	=	octpch(p5)
imnbr	=	octpch(7.11)
imxbr	=	octpch(11.02)
irngbr	=	imnbr-imxbr
indxbr	=	(ioctbr-imnbr)/irngbr
ibrth	tablei		indxbr, ibrthfn, 1
kenv1	linseg		0, .06, .9, .2, .9, p3-.16, .9, .02, 0
kenv2	linseg		0, .01, 1, p3-.02, 1, .01, 0
aflow	pinkish	kenv1*(p4/40)
asum	=	(ibrth+aflow+kenv1)*avib
aslur   	=       	(aslur*avib)+asum
;=====================
;HIGH PARTIAL TRIM
;===================== 
ioct	=	octpch(p5)
imin	=	octpch(7.11)
imax	=	octpch(11.02)
irange	=	imin-imax
index	=	(ioct-imin)/irange
icut	tablei	index, icutfn, 1
;=====================
;PLAY 
;output to EQ instr
;=====================
play:			;waveform tables
aflu1	oscil3  		amp+aslur, kpch, 1, i1		;fundamental		
aflu2	oscil3  		(amp*1.5)+aslur, kpch, 27, i1	;partials 2, 3
aflu3	oscil3  		(amp*2.5)+aslur, kpch, 28, i1	;partials 4, 5, 6
aflu4	oscil3  		(amp*1.5)+aslur, kpch, 29, i1	;partials 2, 3
aflu5	oscil3  		(amp*2)+aslur, kpch, 30, i1	;partials 4, 5
aflu6	oscil3  		(amp*1.5)+aslur, kpch, 31, i1	;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

	instr 78		;CHORUS, alto flute

idlyml		=		20	;delay in milliseconds
iinch		=		p4
ioutch		=		p5
kdclk		linseg  		0, .2, 1, p3-.4, 1, .2, 0
asig		zar		iinch
k1		oscili		idlyml/10, 1, 32
ar1		vdelay3	asig, idlyml/5+k1, 900	;delayed sound 1
k2		oscili		idlyml/10, .995, 32
ar2		vdelay3	asig, idlyml/5+k2, 700	;delayed sound 2
k3		oscili		idlyml/10, 1.05, 32
ar3		vdelay3	asig, idlyml/5+k3, 700	;delayed sound 3
k4		oscili		idlyml/10, 1, 32
ar4		vdelay3	asig, idlyml/5+k4, 900	;delayed sound 4
aout		=		ar1+ar2+ar3+ar4
		zawm		aout/2*kdclk, ioutch
	endin

	instr 79		;FLANGER, bass flute

idlyml		=	35	;delay in milliseconds
iinfl		=	p4
ioutfl		=	p5
kdclk		linseg  	0, .2, 1, p3-.4, 1, .2, 0		;declick envelope
asig		zar	iinfl
k1		oscili	idlyml, .2, 33			;delay time modulated by sine wave
ar		vdelay3	asig, idlyml+k1, 1000	;variable delay
ar1		delay	asig, idlyml/1000		;fixed delay
aout		=	ar+ar1				;delay+variable
		zawm	aout*kdclk, ioutfl
	endin

	instr   90 	;EQ 1	Piccolo 

ilg1 		=	p4	;low gain1
ilg2 		=	p5	;low gain2
img 		=      	p6	;mid gain      
ihg1 		=       	p7	;high gain1
ihg2		=	p8	;high gain2
	
iin		=	p9
iout		=	p10

ilc1		table	0, 11	
ilc2		table	1, 11
ihc1		table	2, 11	
ihc2		table	3, 11

asig		zar		iin
alsig1		butterlp	asig, ilc1		;low cut 1
alsig2		butterlp 	asig, ilc2	      	;low cut 2
atemp	 	butterhp 	asig, ilg2-ilc2/4		;mid range temp
amsig 		butterlp 	atemp, ihg1+ihc1/4	;mid cut
ahsig1 		butterhp 	asig, ihc1	       	;high cut 1
ahsig2 		butterhp 	asig, ihc2		;high cut 2

				;mac opcode multiplies & accumulates signals
aout		mac		ilg1, alsig1, ilg2, alsig2, img, amsig, ihg1, ahsig1, ihg2, ahsig2	
		zawm		aout, iout
		endin

	instr   91 	;EQ 2	Flute 1 

ilg1 		=	p4	;low gain1
ilg2 		=	p5	;low gain2
img 		=      	p6	;mid gain      
ihg1 		=       	p7	;high gain1
ihg2		=	p8	;high gain2
	
iin		=	p9
iout		=	p10

ilc1		table	0, 12
ilc2		table	1, 12
ihc1		table	2, 12
ihc2		table	3, 12

asig		zar		iin
alsig1		butterlp	asig, ilc1		;low cut 1
alsig2		butterlp 	asig, ilc2	      	;low cut 2
atemp	 	butterhp 	asig, ilg2-ilc2/4		;mid range temp
amsig 		butterlp 	atemp, ihg1+ihc1/4	;mid cut
ahsig1 		butterhp 	asig, ihc1	       	;high cut 1
ahsig2 		butterhp 	asig, ihc2		;high cut 2

				;mac opcode multiplies & accumulates signals
aout		mac		ilg1, alsig1, ilg2, alsig2, img, amsig, ihg1, ahsig1, ihg2, ahsig2	
		zawm		aout, iout
		endin

	instr   92 	;EQ 3 	Flute 2 

ilg1 		=	p4	;low gain1
ilg2 		=	p5	;low gain2
img 		=      	p6	;mid gain      
ihg1 		=       	p7	;high gain1
ihg2		=	p8	;high gain2
	
iin		=	p9
iout		=	p10	;out to reverb L

ilc1		table	0, 13	
ilc2		table	1, 13	
ihc1		table	2, 13	
ihc2		table	3, 13

asig		zar		iin
alsig1		butterlp	asig, ilc1		;low cut 1
alsig2		butterlp 	asig, ilc2	      	;low cut 2
atemp	 	butterhp 	asig, ilg2-ilc2/4		;mid range temp
amsig 		butterlp 	atemp, ihg1+ihc1/4	;mid cut
ahsig1 		butterhp 	asig, ihc1	       	;high cut 1
ahsig2 		butterhp 	asig, ihc2		;high cut 2

				;mac opcode multiplies & accumulates signals
aout		mac		ilg1, alsig1, ilg2, alsig2, img, amsig, ihg1, ahsig1, ihg2, ahsig2	
		zawm		aout, iout
		endin

	instr   93 	;EQ 4	Alto Flute 

ilg1 		=	p4	;low gain1
ilg2 		=	p5	;low gain2
img 		=      	p6	;mid gain      
ihg1 		=       	p7	;high gain1
ihg2		=	p8	;high gain2
	
iin		=	p9
iout		=	p10

ilc1		table	0, 14
ilc2		table	1, 14
ihc1		table	2, 14
ihc2		table	3, 14

asig		zar		iin
alsig1		butterlp	asig, ilc1		;low cut 1
alsig2		butterlp 	asig, ilc2	      	;low cut 2
atemp	 	butterhp 	asig, ilg2-ilc2/4		;mid range temp
amsig 		butterlp 	atemp, ihg1+ihc1/4	;mid cut
ahsig1 		butterhp 	asig, ihc1	       	;high cut 1
ahsig2 		butterhp 	asig, ihc2		;high cut 2

				;mac opcode multiplies & accumulates signals
aout		mac		ilg1, alsig1, ilg2, alsig2, img, amsig, ihg1, ahsig1, ihg2, ahsig2	
		zawm		aout, iout
		endin

	instr   94 	;EQ 5	Bass Flute

ilg1 		=	p4	;low gain1
ilg2 		=	p5	;low gain2
img 		=      	p6	;mid gain      
ihg1 		=       	p7	;high gain1
ihg2		=	p8	;high gain2
	
iin		=	p9
iout		=	p10

ilc1		table	0, 15	
ilc2		table	1, 15	
ihc1		table	2, 15	
ihc2		table	3, 15

asig		zar		iin
alsig1		butterlp	asig, ilc1		;low cut 1
alsig2		butterlp 	asig, ilc2	      	;low cut 2
atemp	 	butterhp 	asig, ilg2-ilc2/4		;mid range temp
amsig 		butterlp 	atemp, ihg1+ihc1/4	;mid cut
ahsig1 		butterhp 	asig, ihc1	       	;high cut 1
ahsig2 		butterhp 	asig, ihc2		;high cut 2

				;mac opcode multiplies & accumulates signals
aout		mac		ilg1, alsig1, ilg2, alsig2, img, amsig, ihg1, ahsig1, ihg2, ahsig2	
		zawm		aout, iout
		endin

	instr   95 	;EQ 6	Contrabass Flute 

ilg1 		=	p4	;low gain1
ilg2 		=	p5	;low gain2
img 		=      	p6	;mid gain      
ihg1 		=       	p7	;high gain1
ihg2		=	p8	;high gain2
	
iin		=	p9
iout		=	p10

ilc1		table	0, 16
ilc2		table	1, 16
ihc1		table	2, 16
ihc2		table	3, 16

asig		zar		iin
alsig1		butterlp	asig, ilc1		;low cut 1
alsig2		butterlp 	asig, ilc2	      	;low cut 2
atemp	 	butterhp 	asig, ilg2-ilc2/4		;mid range temp
amsig 		butterlp 	atemp, ihg1+ihc1/4	;mid cut
ahsig1 		butterhp 	asig, ihc1	       	;high cut 1
ahsig2 		butterhp 	asig, ihc2		;high cut 2

				;mac opcode multiplies & accumulates signals
aout		mac		ilg1, alsig1, ilg2, alsig2, img, amsig, ihg1, ahsig1, ihg2, ahsig2	
		zawm		aout, iout
		endin

	instr   96 	;EQ 7	Flute 1 Octave Harmony

ilg1 		=	p4	;low gain1
ilg2 		=	p5	;low gain2
img 		=      	p6	;mid gain      
ihg1 		=       	p7	;high gain1
ihg2		=	p8	;high gain2
	
iin		=	p9
iout		=	p10

ilc1		table	0, 12
ilc2		table	1, 12
ihc1		table	2, 12
ihc2		table	3, 12

asig		zar		iin
alsig1		butterlp	asig, ilc1		;low cut 1
alsig2		butterlp 	asig, ilc2	      	;low cut 2
atemp	 	butterhp 	asig, ilg2-ilc2/4		;mid range temp
amsig 		butterlp 	atemp, ihg1+ihc1/4	;mid cut
ahsig1 		butterhp 	asig, ihc1	       	;high cut 1
ahsig2 		butterhp 	asig, ihc2		;high cut 2

				;mac opcode multiplies & accumulates signals
aout		mac		ilg1, alsig1, ilg2, alsig2, img, amsig, ihg1, ahsig1, ihg2, ahsig2	
		zawm		aout, iout
		endin

	instr 97		;REVERB 1	L=piccolo, R=flute 1

iinL		=	p4
iinR		=	p5	
ioutL		=	p6
ioutR		=	p7	
irvbtimeL	=	p8
irvbtimeR	=	p9	
iwetL		=	p10
idryL		=	1-p10
iwetR		=	p11
idryR		=	1-p11
ihfrollL	=	p12	;low pass filter: high frequency rolloff
ihfrollR	=	p13
ihfdiffL	=	p14	;high frequency diffusion
ihfdiffR	=	p15
kdclk		linseg  	0, .2, 1, p3-.4, 1, .2, 0	;declick envelope

asigL		zar	iinL	;piccolo
asigR		zar	iinR	;flute 1

aoutrevL	nreverb	asigL*iwetL, p8, p14
aoutrevR	nreverb	asigR*iwetR, p9, p15
aoutL		tone	aoutrevL, p12
aoutR		tone	aoutrevR, p13
		zawm	(aoutL+(asigL*idryL))*kdclk, ioutL	;to MIXER CHANNEL 1
		zawm	(aoutR+(asigR*idryR))*kdclk, ioutR	;to MIXER CHANNEL 2
		endin

	instr 98		;REVERB 2	L=flute 2, R=alto

iinL		=	p4
iinR		=	p5	
ioutL		=	p6
ioutR		=	p7	
irvbtimeL	=	p8
irvbtimeR	=	p9	
iwetL		=	p10
idryL		=	1-p10
iwetR		=	p11
idryR		=	1-p11
ihfrollL	=	p12	;low pass filter: high frequency rolloff
ihfrollR	=	p13
ihfdiffL	=	p14	;high frequency diffusion
ihfdiffR	=	p15
kdclk		linseg  	0, .2, 1, p3-.4, 1, .2, 0	;declick envelope

asigL		zar	iinL	;flute 2
asigR		zar	iinR	;alto

aoutrevL	nreverb	asigL*iwetL, p8, p14
aoutrevR	nreverb	asigR*iwetR, p9, p15
aoutL		tone	aoutrevL, p12
aoutR		tone	aoutrevR, p13
		zawm	(aoutL+(asigL*idryL))*kdclk, ioutL	;to MIXER CHANNEL 3
		zawm	(aoutR+(asigR*idryR))*kdclk, ioutR	;to MIXER CHANNEL 4
		endin

	instr 99		;REVERB 3	L=bass, R=contrabass

iinL		=	p4
iinR		=	p5	
ioutL		=	p6
ioutR		=	p7	
irvbtimeL	=	p8
irvbtimeR	=	p9	
iwetL		=	p10
idryL		=	1-p10
iwetR		=	p11
idryR		=	1-p11
ihfrollL	=	p12	;low pass filter: high frequency rolloff
ihfrollR	=	p13
ihfdiffL	=	p14	;high frequency diffusion
ihfdiffR	=	p15
kdclk		linseg  	0, .2, 1, p3-.4, 1, .2, 0	;declick envelope

asigL		zar	iinL	;bass
asigR		zar	iinR	;contrabass

aoutrevL	nreverb	asigL*iwetL, p8, p14
aoutrevR	nreverb	asigR*iwetR, p9, p15
aoutL		tone	aoutrevL, p12
aoutR		tone	aoutrevR, p13
		zawm	(aoutL+(asigL*idryL))*kdclk, ioutL	;to MIXER CHANNEL 5
		zawm	(aoutR+(asigR*idryR))*kdclk, ioutR	;to MIXER CHANNEL 6
		endin

	instr 100	;REVERB 4	Flute Harmony

iin		=	p4
iout		=	p5
irvbtime	=	p6
iwet		=	p7
idry		=	1-p7
ihfroll		=	p8	;low pass filter: high frequency rolloff
ihfdiff		=	p9	;high frequency diffusion
kdclk		linseg  	0, .2, 1, p3-.4, 1, .2, 0	;declick envelope

asig		zar	iin

aoutrev		nreverb	asig*iwet, p6, p9
aout		tone	aoutrev, p8
		zawm	(aout+(asig*idry))*kdclk, iout	;to MIXER CHANNEL 7
		endin

	instr 101	;MIXER: 7 in 2 out 

;=====CHANNEL 1	=================================	;|
a1		zar	p4		;IN	piccolo			;|
igL1		init	p5*p6		;GAIN				;|
igR1		init	p5*(1-p6)	;PAN	1=left, 0=right		;|
;=====CHANNEL 2	=================================	;|
a2		zar	p7		;IN	flute 1			;|
igL2		init	p8*p9		;GAIN				;|
igR2		init	p8*(1-p9)	;PAN	1=left, 0=right		;|
;=====CHANNEL 3	=================================	;|
a3		zar	p10		;IN	flute 2			;|
igL3		init	p11*p12	;GAIN				;|
igR3		init	p11*(1-p12)	;PAN	1=left, 0=right		;|
;=====CHANNEL 4	=================================	;|
a4		zar	p13		;IN	alto			;|
igL4		init	p14*p15	;GAIN				;|
igR4		init	p14*(1-p15)	;PAN	1=left, 0=right		;|
;=====CHANNEL 5	=================================	;|
a5		zar	p16		;IN	bass			;|
igL5		init	p17*p18	;GAIN				;|
igR5		init	p17*(1-p18)	;PAN	1=left, 0=right		;|
;=====CHANNEL 6	=================================	;|
a6		zar	p19		;IN	contrabass		;|
igL6		init	p20*p21	;GAIN				;|
igR6		init	p20*(1-p21)	;PAN	1=left, 0=right		;|
;=====CHANNEL 7	=================================	;|
a7		zar	p22		;IN	Flute 1 Octave Harmony	;|
igL7		init	p23*p24	;GAIN				;|
igR7		init	p23*(1-p24)	;PAN	1=left, 0=right		;|


			;mac opcode multiplies & accumulates signals
aoutL		mac	igL1, a1, igL2, a2, igL3, a3, igL4, a4, igL5, a5, igL6, a6, igL7, a7 
aoutR		mac	igR1, a1, igR2, a2, igR3, a3, igR4, a4, igR5, a5, igR6, a6, igR7, a7 
		outs	aoutL, aoutR
		zacl	0, 30	;clear audio channels 0 to 30
		endin


</CsInstruments>
<CsScore>
/*
Transversal Meditation
For six voice flute choir
Lee Zakian
4/3/2003 9:44:56 PM

=======================================================	|
*****P fields									|
Negative P3 values indicate slurs						|
P4=arbitrary starting amplitude value: (P8 & P9 control dynamics)		|
P5=Pitch									|
P6=pitch ramp: values other than 0 indicate ramp from P6 to P5 value		|
P7=amp to value: np4 for slurred or tied notes, 0 for separated notes		|
P8=amplitude ramp, in conjunction with P9					|
P9=amplitude peak: 0.1=decres., 0.9=cresc., 0.5=peak in middle of duration	|
P10=vibrato speed								|
=======================================================	|
*/

;FLUTE TABLES	flute 1&2/alto/bass/contrabass
f1  0  8193  -9  1  2  0		;fundamental
f27 0 8193 -9 2 0.260 0 3 0.118 0 
f28 0 8193 -9 4 0.085 0 5 0.017 0 6 0.014 0 
f29 0 8193 -9 2 0.090 0 3 0.078 0 
f30 0 8193 -9 4 0.010 0 5 0.013 0 
f31 0 8193 -9 2 0.029 0 3 0.011 0

;PICCOLO TABLES
f17  0  16385  -9  1  2  0	;fundamental
f18 0 16385 -9 2 0.151 0 3 0.234 0 
f19 0 16385 -9 4 0.145 0 5 0.039 0 6 0.022 0 7 0.014 0 
f20 0 16385 -9 8 0.012 0 9 0.022 0 
f21 0 16385 -9 2 0.078 0 3 0.159 0 
f22 0 16385 -9 4 0.039 0 5 0.028 0 
f23 0 16385 -9 2 0.040 0 3 0.079 0 
f24 0 16385 -9 4 0.020 0 5 0.012 0 
f25 0 16385 -9 2 0.030 0 3 0.015 0 
f26 0 16385 -9 2 0.019 0 3 0.009 0

;VIBRATO
;	Start	Size	GEN
f5  	0   	1024    	10  	1

;==============
;VARIABLE TABLES
;==============

;ATTACK
;	Start	Size	GEN	High/Low pitch
f6	0	257	-7	.2 257 .033

;DECAY
;	Start	Size	GEN	Duration, Low/High pitch
f7	0	257	-7	.25 257 .05

;HIGH PARTIALS TRIM	
;	Start	Size	GEN	Low/High pitch	
f8	0	513	-7	1000 513 4000

;BREATH NOISE
;	Start	Size	GEN	Low/High pitch
f9	0	129 	-7	.4 129 .05

;VIBRATO DEPTH
;	Start	Size	GEN	Low/High pitch
f10	0 	129 	-7 	.2 129 .5

;==============
;TEMPO
;==============

;bpm= 40	accel. 42-100	a tempo		accel. 42-100		rit. to 40
t 0 40		86 42 98 100 	98 40		184 42 191 100	194 40
	
;*****SPACES BETWEEN SCORE LINES INDICATE RESTS
;*****SPACES BETWEEN SCORE LINES FOR MEASURE NUMBERS DO NOT
									
;=====PICCOLO==============================================
;p1	p2		p3	p4	p5	p6	p7	p8	p9	p10	
;Instr   	Start		Dur	Amp	Pitch	Pitch	Amp	Amp	Peak	Vibrato
;==============================	From	To	Swell	Time	Speed (3.0-5.25)

i1	4.608		-0.256	200	9.10	0	np4	6000	.5	3.25				
i1	+		0.256	200	9.11	0	0	8000	.5	3.25				
i1	+		-1.536	200	10.01	0	np4	12000	.6	4.25
i1	+		0.512	200	10.06	pp5	0	15000	.7	3.5				
i1	+		-0.768	200	10.08	0	np4	18000	.8	3.75				
i1	+		-0.128	200	10.06	0	np4	12000	.3	3.0				
i1	+		-0.128	200	10.05	0	np4	12000	.3	3.0				
i1	+		0.256	200	10.06	0	0	12000	.5	3.25				
i1	+		-0.256	200	10.01	0	np4	13000	.5	3.25
i1	+		-0.256	200	10.03	0	np4	14000	.5	3.25				
i1	+		0.256	200	10.05	0	0	15000	.5	3.25				
i1	+		-0.256	200	10.06	0	np4	16000	.5	3.25				
i1	+		-0.256	200	10.01	0	np4	17000	.5	3.25
i1	+		-0.256	200	10.06	0	np4	18000	.5	3.25				
i1	+		0.256	200	10.11	0	0	18000	.5	3.25				
i1	+		-2.048	200	10.10	0	np4	19000	.8	5.0				
i1	+		3.072	200	10.09	pp5	0	15000	.1	5.25				
i1	+		-1.024	200	10.10	0	np4	19000	.8	4.0
;|||||=MEASURE 5				
i1	+		3.072	200	10.09	pp5	0	15000	.1	5.25
i1	+		-1.024	200	10.09	0	np4	19000	.8	4.0				
i1	+		3.072	200	10.08	pp5	0	15000	.1	5.25

i1	25.344		-0.256	200	10.09	0	np4	12000	.7	3.25				
i1	+		0.512	200	10.08	pp5	0	10000	.15	3.5
				
i1	26.368		-0.256	200	10.03	0	np4	12000	.7	3.25				
i1	+		1.024	200	10.04	pp5	0	10000	.15	4.0
				
i1	29.44		-0.256	200	10.08	0	np4	12000	.7	3.25				
i1	+		0.512	200	10.07	pp5	0	10000	.15	3.5
				
i1	30.464		-0.256	200	10.02	0	np4	12000	.7	3.25				
i1	+		1.024	200	10.03	pp5	0	10000	15	4.0
				
i1	32.768		1.024	200	9.10	11.10	0	15000	.5	4.0
				
i1	34.048		-0.256	200	10.08	0	np4	11000	.5	3.25				
i1	+		-0.256	200	10.07	0	np4	12000	.5	3.25				
i1	+		0.256	200	11.00	0	0	13000	.5	3.25				
i1	+		1.024	200	10.10	0	0	14000	.5	4.0
				
i1	37.632		-0.256	200	10.07	0	np4	12000	.7	3.25				
i1	+		0.512	200	10.06	pp5	0	10000	.15	3.5
				
i1	38.656		-0.256	200	10.01	0	np4	12000	.7	3.25	
i1	+		1.024	200	10.02	pp5	0	10000	.15	4.0

;||||=|MEASURE 11				
i1	40.96		1.024	200	9.09	11.09	0	15000	.5	4.0
				
i1	42.24		-0.256	200	10.07	0	np4	11000	.5	3.25				
i1	+		-0.256	200	10.06	0	np4	12000	.5	3.25				
i1	+		0.256	200	10.11	0	0	13000	.5	3.25				
i1	+		1.024	200	10.09	0	0	14000	.5	4.0
				
i1	45.056		1.024	200	9.08	11.08	0	15000	.5	4.0
				
i1	46.336		-0.256	200	10.06	0	np4	11000	.5	3.25				
i1	+		-0.256	200	10.05	0	np4	12000	.5	3.25				
i1	+		0.256	200	10.10	0	0	13000	.5	3.25				
i1	+		1.024	200	10.08	0	0	14000	.5	4.0
				
i1	49.152		0.512	200	9.08	0	0	10000	.5	3.5				
i1	+		1.024	200	10.01	pp5	0	11000	.7	4.0
i1	+		-0.256	200	10.05	0	np4	12000	.5	3.25				
i1	+		0.256	200	10.06	0	0	13000	.5	3.25				
i1	+		0.512	200	10.08	0	0	14000	.5	3.5				
i1	+		-0.512	200	11.01	0	np4	15000	.5	3.5				
i1	+		0.512	200	11.00	pp5	0	16000	.3	3.5				
i1	+		1.024	200	11.05	0	0	17000	.2	4.0				
i1	+		1.024	200	11.04	0	0	18000	.2	4.0

i1	57.856		-0.256	200	10.04	0	np4	10000	.5	3.25				
i1	+		0.256	200	10.05	0	0	11000	.5	3.25				
i1	+		0.768	200	10.07	0	0	12000	.5	3.75				
i1	+		-0.256	200	11.00	0	np4	14000	.5	3.25				
i1	+		-0.256	200	10.11	0	np4	13000	.5	3.25				
i1	+		0.256	200	10.09	0	0	12000	.5	3.25				
i1	+		1.536	200	10.07	0	0	11000	.5	4.25

i1	71.168		-0.256	200	10.02	0	np4	6000	.5	3.25				
i1	+		0.256	200	10.03	0	0	8000	.5	3.25				
i1	+		-1.536	200	10.05	0	np4	12000	.6	4.25				
i1	+		0.512	200	10.10	pp5	0	15000	.7	3.5
;|||||=MEASURE 19				
i1	+		-0.768	200	11.00	0	np4	18000	.8	3.75				
i1	+		-0.128	200	10.10	0	np4	12000	.3	3.0				
i1	+		-0.128	200	10.09	0	np4	12000	.3	3.0				
i1	+		0.256	200	10.10	0	0	12000	.5	3.25				
i1	+		-0.256	200	10.05	0	np4	13000	.5	3.25				
i1	+		-0.256	200	10.07	0	np4	14000	.5	3.25				
i1	+		0.256	200	10.09	0	0	15000	.5	3.25				
i1	+		-0.256	200	10.10	0	np4	16000	.5	3.25				
i1	+		-0.256	200	10.05	0	np4	17000	.5	3.25				
i1	+		-0.256	200	10.10	0	np4	18000	.5	3.25				
i1	+		0.256	200	11.03	0	0	18000	.5	3.25				
i1	+		1.024	200	11.02	pp5	0	19000	.2	4.0				

i1	79.36		-0.256	200	10.01	0	np4	6000	.5	3.25				
i1	+		0.256	200	10.02	0	0	8000	.5	3.25				
i1	+		-1.536	200	10.04	0	np4	12000	.6	4.25				
i1	+		0.512	200	10.09	pp5	0	15000	.7	3.5				
i1	+		-0.768	200	10.11	0	np4	18000	.8	3.75				
i1	+		-0.128	200	10.09	0	np4	12000	.3	3.0				
i1	+		-0.128	200	10.08	0	np4	12000	.3	3.0				
i1	+		0.256	200	10.09	0	0	12000	.5	3.25				
i1	+		-0.256	200	10.04	0	np4	13000	.5	3.25				
i1	+		-0.256	200	10.06	0	np4	14000	.5	3.25				
i1	+		0.256	200	10.08	0	0	15000	.5	3.25				
i1	+		-0.256	200	10.09	0	np4	16000	.5	3.25				
i1	+		-0.256	200	10.04	0	np4	17000	.5	3.25				
i1	+		-0.256	200	10.09	0	np4	18000	.5	3.25				
i1	+		0.256	200	11.02	0	0	18000	.5	3.25				
i1	+		1.024	200	11.01	0	0	19000	.2	4.0				

i1	99.84		-0.256	200	9.11	0	np4	14000	.5	3.25				
i1	+		0.256	200	10.00	0	0	12000	.5	3.25				
i1	+		1.024	200	10.02	0	0	10000	.5	4.0
				
i1	102.912	-0.256	200	9.10	0	np4	6000	.5	3.25				
i1	+		0.256	200	9.11	0	0	8000	.5	3.25				
i1	+		-1.536	200	10.01	0	np4	12000	.6	4.25
i1	+		0.512	200	10.06	pp5	0	15000	.7	3.5				
i1	+		-0.768	200	10.08	0	np4	18000	.8	3.75				
i1	+		-0.128	200	10.06	0	np4	12000	.3	3.0				
i1	+		-0.128	200	10.05	0	np4	12000	.3	3.0
;|||||=MEASURE 27				
i1	+		0.256	200	10.06	0	0	12000	.5	3.25				
i1	+		-0.256	200	10.01	0	np4	13000	.5	3.25
i1	+		-0.256	200	10.03	0	np4	14000	.5	3.25				
i1	+		0.256	200	10.05	0	0	15000	.5	3.25				
i1	+		-0.256	200	10.06	0	np4	16000	.5	3.25				
i1	+		-0.256	200	10.01	0	np4	17000	.5	3.25
i1	+		-0.256	200	10.06	0	np4	18000	.5	3.25				
i1	+		0.256	200	10.11	0	0	18000	.5	3.25				
i1	+		-2.048	200	10.10	0	np4	19000	.8	5.0				
i1	+		3.072	200	10.09	pp5	0	15000	.1	5.25				
i1	+		-1.024	200	10.10	0	np4	19000	.8	4.0				
i1	+		3.072	200	10.09	pp5	0	15000	.1	5.25
i1	+		-1.024	200	10.09	0	np4	19000	.8	4.0				
i1	+		3.072	200	10.08	pp5	0	15000	.1	5.25
				
i1	123.648	-0.256	200	10.09	0	np4	12000	.7	3.25				
i1	+		0.512	200	10.08	pp5	0	10000	.15	3.5
				
i1	124.672	-0.256	200	10.03	0	np4	12000	.7	3.25				
i1	+		1.024	200	10.04	pp5	0	10000	.15	4.0
				
i1	127.744	-0.256	200	10.08	0	np4	12000	.7	3.25				
i1	+		0.512	200	10.07	pp5	0	10000	.15	3.5
				
i1	128.768	-0.256	200	10.02	0	np4	12000	.7	3.25				
i1	+		1.024	200	10.03	pp5	0	10000	15	4.0

;|||||=MEASURE 33				
i1	131.072	1.024	200	9.10	11.10	0	15000	.5	4.0
				
i1	132.352	-0.256	200	10.08	0	np4	11000	.5	3.25				
i1	+		-0.256	200	10.07	0	np4	12000	.5	3.25				
i1	+		0.256	200	11.00	0	0	13000	.5	3.25				
i1	+		1.024	200	10.10	0	0	14000	.5	4.0
				
i1	135.936	-0.256	200	10.07	0	np4	12000	.7	3.25				
i1	+		0.512	200	10.06	pp5	0	10000	.15	3.5
				
i1	136.96		-0.256	200	10.01	0	np4	12000	.7	3.25				
i1	+		1.024	200	10.02	pp5	0	10000	.15	4.0
				
i1	139.264	1.024	200	9.09	11.09	0	15000	.5	4.0
				
i1	140.544	-0.256	200	10.07	0	np4	11000	.5	3.25				
i1	+		-0.256	200	10.06	0	np4	12000	.5	3.25				
i1	+		0.256	200	10.11	0	0	13000	.5	3.25				
i1	+		1.024	200	10.09	0	0	14000	.5	4.00
				
i1	143.36		1.024	200	9.08	11.08	0	15000	.5	4.0
				
i1	144.64		-0.256	200	10.06	0	np4	11000	.5	3.25				
i1	+		-0.256	200	10.05	0	np4	12000	.5	3.25				
i1	+		0.256	200	10.10	0	0	13000	.5	3.25				
i1	+		1.024	200	10.08	0	0	14000	.5	4.0
	
;|||||=MEASURE 37			
i1	147.456	0.512	200	9.08	0	0	10000	.5	3.5				
i1	+		1.024	200	10.01	pp5	0	11000	.7	4.0
i1	+		-0.256	200	10.05	0	np4	12000	.5	3.25				
i1	+		0.256	200	10.06	0	0	13000	.5	3.25				
i1	+		0.512	200	10.08	0	0	14000	.5	3.5				
i1	+		-0.512	200	11.01	0	np4	15000	.5	3.5				
i1	+		0.512	200	11.00	pp5	0	16000	.3	3.5				
i1	+		1.024	200	11.05	0	0	17000	.2	4.0				
i1	+		1.024	200	11.04	0	0	18000	.2	4.0
				
i1	156.16		-0.256	200	10.04	0	np4	10000	.5	3.25				
i1	+		0.256	200	10.05	0	0	11000	.5	3.25				
i1	+		0.768	200	10.07	0	0	12000	.5	3.75				
i1	+		-0.256	200	11.00	0	np4	14000	.5	3.25				
i1	+		-0.256	200	10.11	0	np4	13000	.5	3.25				
i1	+		0.256	200	10.09	0	0	12000	.5	3.25				
i1	+		1.536	200	10.07	0	0	11000	.5	4.25				

i1	171.52		-0.256	200	10.02	0	np4	17000	.3	3.25				
i1	+		0.256	200	10.03	0	0	16000	.3	3.25
;|||||=MEASURE 43
i1	+		0.512	200	10.05	0	0	15000	.5	3.5				
i1	+		-0.256	200	10.02	0	np4	14000	.3	3.25				
i1	+		0.256	200	10.03	0	0	13000	.3	3.25				
i1	+		0.512	200	10.05	0	0	12000	.5	3.5				
i1	+		-0.256	200	10.02	0	np4	11000	.3	3.25				
i1	+		0.256	200	10.03	0	0	10000	.3	3.25				
i1	+		1.024	200	10.05	0	0	9000	.5	4.0
				
i1	177.664	-0.256	200	10.01	0	np4	6000	.5	3.25				
i1	+		0.256	200	10.02	0	0	8000	.5	3.25				
i1	+		-1.536	200	10.04	0	np4	12000	.6	4.25				
i1	+		0.512	200	10.09	pp5	0	15000	.7	3.5				
;|||||=MEASURE 45
i1	+		-0.768	200	10.11	0	np4	18000	.8	3.75				
i1	+		-0.128	200	10.09	0	np4	12000	.3	3.0				
i1	+		-0.128	200	10.08	0	np4	12000	.3	3.0				
i1	+		0.256	200	10.09	0	0	12000	.5	3.25				
i1	+		-0.256	200	10.04	0	np4	13000	.5	3.25				
i1	+		-0.256	200	10.06	0	np4	14000	.5	3.25				
i1	+		0.256	200	10.08	0	0	15000	.5	3.25				
i1	+		-0.256	200	10.09	0	np4	16000	.5	3.25				
i1	+		-0.256	200	10.04	0	np4	17000	.5	3.25				
i1	+		-0.256	200	10.09	0	np4	18000	.5	3.25				
i1	+		0.256	200	11.02	0	0	18000	.5	3.25				
i1	+		1.024	200	11.01	0	0	19000	.2	4.0				

i1	184.832	-0.512	200	10.01	0	np4	6000	.7	3.5
i1	+		0.512	200	10.00	pp5	0	7000	.15	3.5				
i1	+		-0.512	200	10.02	0	np4	8000	.7	3.5				
i1	+		0.512	200	10.01	pp5	0	9000	.15	3.5
i1	+		-0.512	200	10.03	0	np4	10000	.7	3.5				
i1	+		0.512	200	10.02	pp5	0	11000	.15	3.5				
i1	+		-0.512	200	10.04	0	np4	12000	.7	3.5				
i1	+		0.512	200	10.03	pp5	0	13000	.15	3.5				
i1	+		-0.512	200	10.05	0	np4	14000	.7	3.5				
i1	+		0.512	200	10.04	pp5	0	15000	.15	3.5				
i1	+		-0.512	200	10.06	0	np4	15500	.7	3.5				
i1	+		0.512	200	10.05	pp5	0	16000	.15	3.5				
i1	+		-0.512	200	10.07	0	np4	16500	.7	3.5				
i1	+		0.512	200	10.06	pp5	0	17000	.15	3.5				
i1	+		-0.512	200	10.08	0	np4	17500	.7	3.5				
i1	+		0.512	200	10.07	pp5	0	18000	.15	3.5				
i1	+		-0.512	200	10.09	0	np4	18500	.7	3.5				
i1	+		0.512	200	10.08	pp5	0	18600	.15	3.5				
i1	+		-0.512	200	10.10	0	np4	18700	.7	3.5				
i1	+		0.512	200	10.09	pp5	0	18800	.15	3.5				
i1	+		-0.512	200	10.11	0	np4	18900	.7	3.5				
i1	+		0.512	200	10.10	pp5	0	19000	.15	3.5				
i1	+		-0.512	200	11.00	0	np4	19100	.7	3.5				
i1	+		3.072	200	10.11	pp5	0	19200	.15	5.25

;=====FLUTE 1===============================================
;p1	p2		p3	p4	p5	p6	p7	p8	p9	p10	
;Instr   	Start		Dur	Amp	Pitch	Pitch	Amp	Amp	Peak	Vibrato
;==============================	From	To	Swell	Time	Speed (3.00-5.25)

i2	3.072		-1.024	300	9.11	0	np4	19000	.8	4.0
i2	+		3.072	300	9.10	pp5	0	15000	.1	5.25
i2	+		-1.024	300	9.11	0	np4	19000	.8	4.0				
i2	+		3.072	300	9.10	pp5	0	15000	.1	5.25

				
i2	12.8		-0.256	300	8.09	0	np4	6000	.5	3.25				
i2	+		0.256	300	8.10	0	0	8000	.5	3.25				
i2	+		-1.536	300	9.00	0	np4	12000	.6	4.25				
i2	+		0.512	300	9.05	pp5	0	15000	.7	3.5				
i2	+		-0.768	300	9.07	0	np4	18000	.8	3.75				
i2	+		-0.128	300	9.05	0	np4	12000	.3	3.0				
i2	+		-0.128	300	9.04	0	np4	12000	.3	3.0				
;|||||=MEASURE 5
i2	+		0.256	300	9.05	0	0	13000	.5	3.25				
i2	+		-0.256	300	9.00	0	np4	14000	.5	3.25				
i2	+		-0.256	300	9.02	0	np4	15000	.5	3.25				
i2	+		0.256	300	9.04	0	0	16000	.5	3.25				
i2	+		-0.256	300	9.05	0	np4	17000	.5	3.25				
i2	+		-0.256	300	9.00	0	np4	18000	.5	3.25				
i2	+		-0.256	300	9.05	0	np4	18500	.5	3.25				
i2	+		0.256	300	9.10	0	0	18700	.5	3.25				
i2	+		0.512	300	9.09	0	0	18900	.5	3.5				
i2	+		-0.512	300	10.02	0	np4	19100	.5	3.5				
i2	+		0.512	300	10.01	pp5	0	19100	.3	3.5				
i2	+		0.768	300	10.06	0	0	19100	.5	3.75				
i2	+		0.256	300	10.04	0	0	19000	.5	3.25				
i2	+		0.256	300	9.11	0	0	18800	.5	3.25				
i2	+		-0.256	300	10.04	0	np4	18600	.5	3.25				
i2	+		0.256	300	10.03	pp5	0	18400	.3	3.25				
i2	+		-0.256	300	10.08	0	np4	18200	.5	3.25				
i2	+		0.256	300	10.06	0	0	18000	.5	3.25				
i2	+		0.512	300	10.04	0	0	17000	.5	3.5				
i2	+		0.256	300	10.03	0	0	16000	.5	3.25				
i2	+		0.256	300	10.01	0	0	15500	.5	3.25				
i2	+		0.512	300	9.11	0	0	15400	.5	3.5				
i2	+		0.256	300	9.09	0	0	15300	.5	3.25				
i2	+		0.256	300	9.08	0	0	15200	.5	3.25				
i2	+		0.256	300	9.06	0	0	15100	.5	3.25			
i2	+		0.256	300	9.04	0	0	14900	.5	3.25				
i2	+		-0.256	300	8.11	0	np4	14800	.5	3.25				
i2	+		-0.256	300	9.01	0	np4	14700	.5	3.25				
i2	+		0.256	300	9.03	0	0	14600	.5	3.25				
i2	+		0.256	300	9.04	0	0	14500	.5	3.25				
i2	+		-0.256	300	8.11	0	np4	14400	.5	3.25				
i2	+		-0.256	300	9.04	0	np4	14300	.5	3.25				
i2	+		0.256	300	9.09	0	0	14200	.5	3.25				
i2	+		1.024	300	9.08	0	0	14100	.2	4.0				

i2	28.672		-0.256	300	9.07	0	np4	15000	.5	3.25				
i2	+		0.256	300	9.08	0	0	15000	.5	3.25				
i2	+		0.512	300	9.10	0	0	15000	.5	3.5				
i2	+		0.512	300	10.03	0	0	15000	.5	3.5				
i2	+		1.024	300	9.10	0	0	15000	.5	4.0				
i2	+		-0.256	300	9.07	0	np4	15000	.5	3.25				
i2	+		0.256	300	9.08	0	0	15000	.5	3.25				
i2	+		0.512	300	9.10	0	0	15000	.5	3.5				
i2	+		0.512	300	10.03	0	0	15000	.5	3.5
				
i2	33.024		-0.256	300	10.03	0	np4	15000	.5	3.25				
i2	+		-0.256	300	10.02	0	np4	14000	.5	3.25				
i2	+		-0.256	300	10.00	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.10	0	np4	12000	.5	3.25				
i2	+		-0.256	300	9.08	0	np4	11000	.5	3.25				
i2	+		-0.256	300	9.07	0	np4	10000	.5	3.25				
i2	+		0.256	300	9.05	0	0	9000	.5	3.25				
i2	+		1.024	300	9.03	0	0	8000	.5	4.0

;|||||=MEASURE 10					
i2	36.864		-0.256	300	9.06	0	np4	15000	.5	3.25				
i2	+		0.256	300	9.07	0	0	15000	.5	3.25				
i2	+		0.512	300	9.09	0	0	15000	.5	3.5				
i2	+		0.512	300	10.02	0	0	15000	.5	3.5				
i2	+		1.024	300	9.09	0	0	15000	.5	4.0
i2	+		-0.256	300	9.06	0	np4	15000	.5	3.25				
i2	+		0.256	300	9.07	0	0	15000	.5	3.25				
i2	+		0.512	300	9.09	0	0	15000	.5	3.5				
i2	+		0.512	300	10.02	0	0	15000	.5	3.5				

i2	41.216		-0.256	300	10.02	0	np4	15000	.5	3.25				
i2	+		-0.256	300	10.01	0	np4	14000	.5	3.25				
i2	+		-0.256	300	9.11	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.09	0	np4	12000	.5	3.25				
i2	+		-0.256	300	9.07	0	np4	11000	.5	3.25				
i2	+		-0.256	300	9.06	0	np4	10000	.5	3.25				
i2	+		0.256	300	9.04	0	0	9000	.5	3.25				
i2	+		1.024	300	9.02	0	0	8000	.5	4.0
				
i2	45.312		-0.256	300	10.01	0	np4	15000	.5	3.25				
i2	+		-0.256	300	10.00	0	np4	14000	.5	3.25				
i2	+		-0.256	300	9.10	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.08	0	np4	12000	.5	3.25				
i2	+		-0.256	300	9.06	0	np4	11000	.5	3.25				
i2	+		-0.256	300	9.05	0	np4	10000	.5	3.25				
i2	+		0.256	300	9.03	0	0	9000	.5	3.25				
i2	+		1.024	300	9.01	0	0	8000	.5	4.0				

i2	49.152		-0.256	300	10.05	0	np4	15000	.5	3.25				
i2	+		0.256	300	10.06	0	0	15000	.5	3.25				
i2	+		0.512	300	10.08	0	0	15000	.5	3.5				
i2	+		0.512	300	10.05	0	0	15000	.5	3.5				
i2	+		1.024	300	10.01	0	0	15000	.3	4.0				

i2	53.248		0.512	300	9.04	8.04	0	17000	.5	3.5				
i2	+		-0.512	300	9.09	0	np4	11000	.7	3.5				
i2	+		0.512	300	9.07	pp5	0	12000	.2	3.5				
i2	+		-0.512	300	10.00	0	np4	13000	.7	3.5				
i2	+		0.512	300	9.11	pp5	0	14000	.2	3.5				
i2	+		-0.512	300	10.04	0	np4	15000	.7	3.5				
i2	+		1.024	300	10.02	pp5	0	16000	.2	4.0
;|||||=MEASURE 15				
i2	+		-0.256	300	9.04	0	np4	10000	.5	3.25				
i2	+		0.256	300	9.05	0	0	11000	.5	3.25				
i2	+		0.768	300	9.07	0	0	12000	.5	3.75				
i2	+		-0.256	300	10.00	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.11	0	np4	12000	.5	3.25				
i2	+		0.256	300	9.09	0	0	11000	.5	3.25				
i2	+		1.024	300	9.07	0	0	10000	.5	4.0				

i2	61.952		-0.256	300	9.03	0	np4	6000	.5	3.25				
i2	+		0.256	300	9.04	0	0	8000	.5	3.25				
i2	+		-1.536	300	9.06	0	np4	12000	.6	4.25				
i2	+		0.512	300	9.11	pp5	0	15000	.7	3.5				
i2	+		-0.768	300	10.01	0	np4	18000	.8	3.75				
i2	+		-0.128	300	9.11	0	np4	12000	.3	3.0				
i2	+		-0.128	300	9.10	0	np4	12000	.3	3.0				
i2	+		0.256	300	9.11	0	0	12000	.5	3.25				
i2	+		-0.256	300	9.06	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.08	0	np4	14000	.5	3.25				
i2	+		0.256	300	9.10	0	0	15000	.5	3.25				
i2	+		-0.256	300	9.11	0	np4	16000	.5	3.25				
i2	+		-0.256	300	9.06	0	np4	17000	.5	3.25				
i2	+		-0.256	300	9.11	0	np4	18000	.5	3.25				
i2	+		0.256	300	10.04	0	0	18000	.5	3.25				
i2	+		1.024	300	10.03	0	0	19000	.2	4.0
				
i2	76.8		-1.024	300	9.02	0	np4	19000	.8	4.0
;|||||=MEASURE 20					
i2	+		3.072	300	9.01	pp5	0	15000	.1	5.25				
i2	+		-1.024	300	9.02	0	np4	19000	.8	4.0				
i2	+		3.072	300	9.01	pp5	0	15000	.1	5.25
				
i2	86.528		-0.512	300	9.01	0	np4	8000	.7	3.5				
i2	+		0.512	300	9.00	pp5	0	6000	.2	3.5				
i2	+		-0.512	300	9.02	0	np4	9000	.7	3.5				
i2	+		0.512	300	9.01	pp5	0	7000	.2	3.5				
i2	+		-0.512	300	9.03	0	np4	10000	.7	3.5				
i2	+		0.512	300	9.02	pp5	0	8000	.2	3.5				
i2	+		-0.512	300	9.04	0	np4	11000	.7	3.5				
i2	+		0.512	300	9.03	pp5	0	9000	.2	3.5				
i2	+		-0.512	300	9.05	0	np4	12000	.7	3.5				
i2	+		0.512	300	9.04	pp5	0	10000	.2	3.5				
i2	+		-0.512	300	9.06	0	np4	13000	.7	3.5				
i2	+		0.512	300	9.05	pp5	0	11000	.2	3.5				
i2	+		-0.512	300	9.07	0	np4	14000	.7	3.5				
i2	+		0.512	300	9.06	pp5	0	12000	.2	3.5				
i2	+		-0.512	300	9.08	0	np4	15000	.7	3.5				
i2	+		0.512	300	9.07	pp5	0	13000	.2	3.5				
i2	+		-0.512	300	9.09	0	np4	16000	.7	3.5				
i2	+		0.512	300	9.08	pp5	0	14000	.2	3.5				
i2	+		-0.512	300	9.10	0	np4	16500	.7	3.5				
i2	+		0.512	300	9.09	pp5	0	15100	.2	3.5				
i2	+		-0.512	300	9.11	0	np4	17500	.7	3.5				
i2	+		0.512	300	9.10	pp5	0	16500	.2	3.5				
i2	+		-0.512	300	10.00	0	np4	18000	.7	3.5
;|||||=MEASURE 25					
i2	+		3.072	300	9.11	pp5	0	17000	.2	5.25
				
i2	111.104	-0.256	300	8.09	0	np4	6000	.5	3.25				
i2	+		0.256	300	8.10	0	0	8000	.5	3.25				
i2	+		-1.536	300	9.00	0	np4	12000	.6	4.25				
i2	+		0.512	300	9.05	pp5	0	15000	.7	3.5				
i2	+		-0.768	300	9.07	0	np4	18000	.8	3.75				
i2	+		-0.128	300	9.05	0	np4	12000	.3	3.0				
i2	+		-0.128	300	9.04	0	np4	12000	.5	3.0				
i2	+		0.256	300	9.05	0	0	12000	.5	3.25				
i2	+		-0.256	300	9.00	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.02	0	np4	14000	.5	3.25				
i2	+		0.256	300	9.04	0	0	15000	.5	3.25				
i2	+		-0.256	300	9.05	0	np4	16000	.5	3.25				
i2	+		-0.256	300	9.00	0	np4	17000	.5	3.25				
i2	+		-0.256	300	9.05	0	np4	18000	.5	3.25				
i2	+		0.256	300	9.10	0	0	18500	.5	3.25				
i2	+		0.512	300	9.09	0	0	18900	.5	3.5				
i2	+		-0.512	300	10.02	0	np4	19100	.5	3.5				
i2	+		0.512	300	10.01	pp5	0	19100	.3	3.5				
i2	+		0.768	300	10.06	0	0	19100	.5	3.75				
i2	+		0.256	300	10.04	0	0	19000	.5	3.25				
i2	+		0.256	300	9.11	0	0	18800	.5	3.25				
i2	+		-0.256	300	10.04	0	np4	18600	.5	3.25				
i2	+		0.256	300	10.03	pp5	0	18400	.3	3.25				
i2	+		-0.256	300	10.08	0	np4	18200	.5	3.25				
i2	+		0.256	300	10.06	0	0	18000	.5	3.25				
i2	+		0.512	300	10.04	0	0	17000	.5	3.5				
i2	+		0.256	300	10.03	0	0	16000	.5	3.25				
i2	+		0.256	300	10.01	0	0	15500	.5	3.25				
i2	+		0.512	300	9.11	0	0	15400	.5	3.5				
i2	+		0.256	300	9.09	0	0	15300	.5	3.25				
i2	+		0.256	300	9.08	0	0	15200	.5	3.25				
i2	+		0.256	300	9.06	0	0	15100	.5	3.25
;|||||=MEASURE 31					
i2	+		0.256	300	9.04	0	0	14900	.5	3.25				
i2	+		-0.256	300	8.11	0	np4	14800	.5	3.25				
i2	+		-0.256	300	9.01	0	np4	14700	.5	3.25				
i2	+		0.256	300	9.03	0	0	14600	.5	3.25				
i2	+		0.256	300	9.04	0	0	14500	.5	3.25				
i2	+		-0.256	300	8.11	0	np4	14400	.5	3.25				
i2	+		-0.256	300	9.04	0	np4	14300	.5	3.25				
i2	+		0.256	300	9.09	0	0	14200	.5	3.25				
i2	+		1.024	300	9.08	0	0	14100	.2	4.0				

i2	126.976	-0.256	300	9.07	0	np4	15000	.5	3.25				
i2	+		0.256	300	9.08	0	0	15000	.5	3.25				
i2	+		0.512	300	9.10	0	0	15000	.5	3.5				
i2	+		0.512	300	10.03	0	0	15000	.5	3.5				
i2	+		1.024	300	9.10	0	0	15000	.5	4.0				
i2	+		-0.256	300	9.07	0	np4	15000	.5	3.25				
i2	+		0.256	300	9.08	0	0	15000	.5	3.25				
i2	+		0.512	300	9.10	0	0	15000	.5	3.5				
i2	+		0.512	300	10.03	0	0	15000	.5	3.5
				
i2	131.328	-0.256	300	10.03	0	np4	15000	.5	3.25				
i2	+		-0.256	300	10.02	0	np4	14000	.5	3.25				
i2	+		-0.256	300	10.00	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.10	0	np4	12000	.5	3.25				
i2	+		-0.256	300	9.08	0	np4	11000	.5	3.25				
i2	+		-0.256	300	9.07	0	np4	10000	.5	3.25				
i2	+		0.256	300	9.05	0	0	9000	.5	3.25				
i2	+		1.024	300	9.03	0	0	8000	.5	4.0				

;|||||=MEASURE 34
i2	135.168	-0.256	300	9.06	0	np4	15000	.5	3.25				
i2	+		0.256	300	9.07	0	0	15000	.5	3.25				
i2	+		0.512	300	9.09	0	0	15000	.5	3.5				
i2	+		0.512	300	10.02	0	0	15000	.5	3.5				
i2	+		1.024	300	9.09	0	0	15000	.5	4.0
i2	+		-0.256	300	9.06	0	np4	15000	.5	3.25				
i2	+		0.256	300	9.07	0	0	15000	.5	3.25				
i2	+		0.512	300	9.09	0	0	15000	.5	3.5				
i2	+		0.512	300	10.02	0	0	15000	.5	3.5				

i2	139.52		-0.256	300	10.02	0	np4	15000	.5	3.25				
i2	+		-0.256	300	10.01	0	np4	14000	.5	3.25				
i2	+		-0.256	300	9.11	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.09	0	np4	12000	.5	3.25				
i2	+		-0.256	300	9.07	0	np4	11000	.5	3.25				
i2	+		-0.256	300	9.06	0	np4	10000	.5	3.25				
i2	+		0.256	300	9.04	0	0	9000	.5	3.25				
i2	+		1.024	300	9.02	0	0	8000	.5	4.0
				
i2	143.616	-0.256	300	10.01	0	np4	15000	.5	3.25				
i2	+		-0.256	300	10.00	0	np4	14000	.5	3.25				
i2	+		-0.256	300	9.10	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.08	0	np4	12000	.5	3.25				
i2	+		-0.256	300	9.06	0	np4	11000	.5	3.25				
i2	+		-0.256	300	9.05	0	np4	10000	.5	3.25				
i2	+		0.256	300	9.03	0	0	9000	.5	3.25				
i2	+		1.024	300	9.01	0	0	8000	.5	4.0				

i2	147.456	-0.256	300	10.05	0	np4	15000	.5	3.25				
i2	+		0.256	300	10.06	0	0	15000	.5	3.25				
i2	+		0.512	300	10.08	0	0	15000	.5	3.5				
i2	+		0.512	300	10.05	0	0	15000	.5	3.5				
i2	+		1.024	300	10.01	0	0	15000	.3	4.0				

i2	151.552	0.512	300	9.04	8.04	0	17000	.5	3.5				
i2	+		-0.512	300	9.09	0	np4	11000	.7	3.5				
i2	+		0.512	300	9.07	pp5	0	12000	.2	3.5				
i2	+		-0.512	300	10.00	0	np4	13000	.7	3.5				
i2	+		0.512	300	9.11	pp5	0	14000	.2	3.5				
i2	+		-0.512	300	10.04	0	np4	15000	.7	3.5				
i2	+		1.024	300	10.02	pp5	0	16000	.2	4.0
;|||||=MEASURE 39					
i2	+		-0.256	300	9.04	0	np4	10000	.5	3.25				
i2	+		0.256	300	9.05	0	0	11000	.5	3.25				
i2	+		0.768	300	9.07	0	0	12000	.5	3.75				
i2	+		-0.256	300	10.00	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.11	0	np4	12000	.5	3.25				
i2	+		0.256	300	9.09	0	0	11000	.5	3.25				
i2	+		1.024	300	9.07	0	0	10000	.5	4.0				

i2	160.256	-0.256	300	9.03	0	np4	6000	.5	3.25				
i2	+		0.256	300	9.04	0	0	8000	.5	3.25				
i2	+		-1.536	300	9.06	0	np4	12000	.6	4.25				
i2	+		0.512	300	9.11	pp5	0	15000	.7	3.5				
i2	+		-0.768	300	10.01	0	np4	18000	.8	3.75				
i2	+		-0.128	300	9.11	0	np4	12000	.3	3.0				
i2	+		-0.128	300	9.10	0	np4	12000	.3	3.0				
i2	+		0.256	300	9.11	0	0	12000	.5	3.25				
i2	+		-0.256	300	9.06	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.08	0	np4	14000	.5	3.25				
i2	+		0.256	300	9.10	0	0	15000	.5	3.25				
i2	+		-0.256	300	9.11	0	np4	16000	.5	3.25				
i2	+		-0.256	300	9.06	0	np4	17000	.5	3.25				
i2	+		-0.256	300	9.11	0	np4	18000	.5	3.25				
i2	+		0.256	300	10.04	0	0	18000	.5	3.25				
i2	+		1.024	300	10.03	0	0	19000	.2	4.0				

i2	169.472	-0.256	300	9.02	0	np4	6000	.5	3.25				
i2	+		0.256	300	9.03	0	0	8000	.5	3.25				
i2	+		-1.536	300	9.05	0	np4	12000	.6	4.25				
i2	+		0.512	300	9.10	pp5	0	15000	.7	3.5
;|||||=MEASURE 43					
i2	+		-0.768	300	10.00	0	np4	18000	.8	3.75				
i2	+		-0.128	300	9.10	0	np4	12000	.3	3.0				
i2	+		-0.128	300	9.09	0	np4	12000	.3	3.0				
i2	+		0.256	300	9.10	0	0	12000	.5	3.25				
i2	+		-0.256	300	9.05	0	np4	13000	.5	3.25				
i2	+		-0.256	300	9.07	0	np4	14000	.5	3.25				
i2	+		0.256	300	9.09	0	0	15000	.5	3.25				
i2	+		-0.256	300	9.10	0	np4	16000	.5	3.25				
i2	+		-0.256	300	9.05	0	np4	17000	.5	3.25				
i2	+		-0.256	300	9.10	0	np4	18000	.5	3.25				
i2	+		0.256	300	10.03	0	0	18000	.5	3.25				
i2	+		1.024	300	10.02	0	0	19000	.2	4.0				

i2	176.64		-0.256	300	9.01	0	np4	17000	.5	3.25				
i2	+		0.256	300	9.02	0	0	16000	.5	3.25				
i2	+		0.512	300	9.04	0	0	15000	.5	3.5				
i2	+		-0.256	300	9.01	0	np4	14000	.5	3.25				
i2	+		0.256	300	9.02	0	0	13000	.5	3.25				
i2	+		0.512	300	9.04	0	0	12000	.5	3.5				
i2	+		-0.256	300	9.01	0	np4	11000	.5	3.25				
i2	+		0.256	300	9.02	0	0	10000	.5	3.25				
i2	+		1.024	300	9.04	0	0	9000	.2	4.0				

i2	184.32		-1.024	300	9.08	7.08	np4	15000	.5	4.0				
i2	+		-1.024	300	9.09	pp5	np4	10000	.5	4.0				
i2	+		-1.024	300	9.10	pp5	np4	11000	.5	4.0				
i2	+		-1.024	300	9.11	pp5	np4	12000	.5	4.0				
i2	+		-1.024	300	10.00	pp5	np4	13000	.5	4.0				
i2	+		-1.024	300	10.01	pp5	np4	14000	.5	4.0				
i2	+		-1.024	300	10.02	pp5	np4	15000	.5	4.0				
i2	+		1.024	300	10.03	0	0	16000	.5	4.0				
i2	+		-1.024	300	10.04	pp5	np4	17000	.3	4.0				
i2	+		-1.024	300	10.05	pp5	np4	18000	.5	4.0				
i2	+		1.024	300	10.06	pp5	0	19000	.5	4.0				
i2	+		4.096	300	10.07	0	0	19000	.2	5.25		

;=====FLUTE 2===============================================
;p1	p2		p3	p4	p5	p6	p7	p8	p9	p10	
;Instr   	Start		Dur	Amp	Pitch	Pitch	Amp	Amp	Peak	Vibrato
;==============================	From	To	Swell	Time	Speed (3.00-5.25)

i3	3.072		4.096	300	9.06	0	0	15000	.5	5.25				
i3	+		-1.024	300	9.05	0	np4	19000	.8	4.0				
i3	+		3.072	300	9.06	pp5	0	15000	.1	5.25				
i3	+		4.096	300	9.05	0	0	15000	.5	5.25				
i3	+		-1.024	300	9.04	0	np4	19000	.8	4.0				
i3	+		3.072	300	9.05	pp5	0	15000	.1	5.25				
i3	+		4.096	300	9.04	0	0	15000	.5	5.25				
i3	+		-1.024	300	9.03	0	np4	19000	.8	4.0				
i3	+		3.072	300	9.04	pp5	0	15000	.1	5.25				

i3	28.672		-0.256	300	9.03	0	np4	15000	.5	3.25				
i3	+		0.256	300	9.05	0	0	15000	.5	3.25				
i3	+		0.512	300	9.07	0	0	15000	.5	3.5				
i3	+		0.512	300	9.10	0	0	15000	.5	3.5				
i3	+		1.024	300	9.07	0	0	15000	.5	4.0				
i3	+		-0.256	300	9.03	0	np4	15000	.5	3.25				
i3	+		0.512	300	9.05	0	0	15000	.5	3.5				
i3	+		-0.256	300	9.08	0	np4	15000	.5	3.25				
i3	+		-0.256	300	9.07	0	np4	15000	.5	3.25				
i3	+		0.256	300	9.05	0	0	15000	.5	3.25				
i3	+		0.512	300	9.03	0	0	15000	.5	3.5				
i3	+		-0.512	300	9.08	0	np4	16000	.7	3.5				
i3	+		0.512	300	9.07	pp5	0	13000	.2	3.5				
i3	+		-0.512	300	10.00	0	np4	16000	.7	3.5				
i3	+		0.512	300	9.10	pp5	0	13000	.2	3.5				
i3	+		-0.512	300	10.03	0	np4	16000	.7	3.5				
i3	+		1.024	300	10.02	pp5	0	15000	.2	4.0				
;|||||=MEASURE 10
i3	+		-0.256	300	9.02	0	np4	15000	.5	3.25				
i3	+		0.256	300	9.04	0	0	15000	.5	3.25				
i3	+		0.512	300	9.06	0	0	15000	.5	3.5				
i3	+		0.512	300	9.09	0	0	15000	.5	3.5				
i3	+		1.024	300	9.06	0	0	15000	.5	4.0				
i3	+		-0.256	300	9.02	0	np4	15000	.5	3.25				
i3	+		0.512	300	9.04	0	0	15000	.5	3.5				
i3	+		-0.256	300	9.07	0	np4	15000	.5	3.25				
i3	+		-0.256	300	9.06	0	np4	15000	.5	3.25				
i3	+		0.256	300	9.04	0	0	15000	.5	3.25				
i3	+		0.512	300	9.02	0	0	15000	.5	3.5				
i3	+		-0.512	300	9.07	0	np4	16000	.7	3.5				
i3	+		0.512	300	9.06	pp5	0	13000	.2	3.5				
i3	+		-0.512	300	9.11	0	np4	16000	.7	3.5				
i3	+		0.512	300	9.09	pp5	0	13000	.2	3.5				
i3	+		-0.512	300	10.02	0	np4	16000	.7	3.5				
i3	+		1.024	300	10.01	pp5	0	13000	.2	4.0				
i3	+		0.512	300	9.01	0	0	15000	.5	3.5				
i3	+		-0.512	300	9.06	0	np4	16000	.7	3.5				
i3	+		0.512	300	9.05	pp5	0	13000	.2	3.5				
i3	+		-0.512	300	9.10	0	np4	16000	.7	3.5				
i3	+		0.512	300	9.08	pp5	0	13000	.2	3.5				
i3	+		-0.512	300	10.01	0	np4	16000	.7	3.5				
i3	+		1.024	300	10.00	pp5	0	13000	.2	4.0				
i3	+		-0.256	300	10.01	0	np4	15000	.5	3.25				
i3	+		0.256	300	10.03	0	0	15000	.5	3.25				
i3	+		0.512	300	10.05	0	0	15000	.5	3.5				
i3	+		0.512	300	10.01	0	0	15000	.5	3.5				
i3	+		1.024	300	9.08	0	0	15000	.3	4.0				

i3	52.224		-1.024	300	9.05	0	np4	16000	.8	4.0				
i3	+		3.072	300	9.04	pp5	0	13000	.1	5.25				
i3	+		-1.024	300	9.05	0	np4	16000	.8	4.0				
;|||||=MEASURE 15
i3	+		3.072	300	9.04	pp5	0	13000	.1	5.25				
i3	+		-1.024	300	9.04	0	np4	16000	.8	4.0				
i3	+		3.072	300	9.03	pp5	0	13000	.1	5.25				
i3	+		-1.024	300	9.04	0	np4	16000	.8	4.0				
i3	+		3.072	300	9.03	pp5	0	13000	.1	5.25				
i3	+		-1.024	300	9.03	0	np4	16000	.8	4.0				
i3	+		3.072	300	9.02	pp5	0	13000	.1	5.25				
i3	+		-1.024	300	9.03	0	np4	16000	.8	4.0				
i3	+		3.072	300	9.02	pp5	0	13000	.1	5.25				
i3	+		4.096	300	8.09	0	0	11000	.5	4.5				
i3	+		-1.024	300	8.08	0	np4	16000	.8	4.0				
i3	+		3.072	300	8.09	pp5	0	13000	.1	5.25				

;|||||=MEASURE 22
i3	86.016		-1.024	300	9.08	10.08	np4	16000	.75	4.0				
i3	+		1.024	300	9.03	pp5	0	13000	.25	4.0				
i3	+		-1.024	300	9.09	10.09	np4	16000	.75	4.0				
i3	+		1.024	300	9.05	pp5	0	13000	.25	4.0				
i3	+		-1.024	300	9.11	10.11	np4	16000	.75	4.0				
i3	+		1.024	300	9.07	pp5	0	13000	.25	4.0				
i3	+		-1.024	300	10.01	11.01	np4	16000	.75	4.0				
i3	+		1.024	300	9.09	pp5	0	13000	.25	4.0				
i3	+		-1.024	300	10.02	11.02	np4	16000	.75	4.0				
i3	+		1.024	300	9.11	pp5	0	13000	.25	4.0				
i3	+		1.024	300	10.05	0	0	15000	.5	4.0				
i3	+		-1.024	300	10.06	11.06	np4	13000	.7	4.0				
i3	+		3.072	300	10.07	pp5	0	15000	.2	5.25				

i3	103.936	-0.256	300	8.10	0	np4	6000	.5	3.25				
i3	+		0.256	300	8.11	0	0	8000	.5	3.25				
i3	+		-1.536	300	9.01	0	np4	12000	.6	4.25				
i3	+		0.512	300	9.06	pp5	0	15000	.7	3.5				
i3	+		-0.768	300	9.08	0	np4	18000	.8	3.75				
i3	+		-0.128	300	9.06	0	np4	12000	.3	3.0				
i3	+		-0.128	300	9.05	0	np4	12000	.3	3.0				
i3	+		0.256	300	9.06	0	0	12000	.5	3.25				
i3	+		-0.256	300	9.01	0	np4	13000	.5	3.25				
i3	+		-0.256	300	9.03	0	np4	14000	.5	3.25				
i3	+		0.256	300	9.05	0	0	15000	.5	3.25				
i3	+		1.024	300	9.06	0	0	15000	.2	4.0				

i3	112.128	-0.256	300	8.09	0	np4	6000	.5	3.25				
i3	+		0.256	300	8.10	0	0	8000	.5	3.25				
i3	+		-1.536	300	9.00	0	np4	12000	.6	4.25				
i3	+		0.512	300	9.05	pp5	0	15000	.7	3.5				
;|||||=MEASURE 29
i3	+		-0.768	300	9.07	0	np4	18000	.8	3.75				
i3	+		-0.128	300	9.05	0	np4	12000	.3	3.0				
i3	+		-0.128	300	9.04	0	np4	12000	.3	3.0				
i3	+		0.256	300	9.05	0	0	12000	.5	3.25				
i3	+		-0.256	300	9.00	0	np4	13000	.5	3.25				
i3	+		-0.256	300	9.02	0	np4	14000	.5	3.25				
i3	+		0.256	300	9.04	0	0	15000	.5	3.25				
i3	+		-0.256	300	9.05	0	np4	16000	.5	3.25				
i3	+		-0.256	300	9.00	0	np4	17000	.5	3.25				
i3	+		-0.256	300	9.05	0	np4	18000	.3	3.25				
i3	+		0.256	300	9.10	0	0	18000	.5	3.25				
i3	+		0.512	300	9.09	0	0	19000	.2	3.5				

i3	138.24		-1.024	300	9.01	0	np4	16000	.7	4.0				
i3	+		3.072	300	9.02	pp5	0	13000	.2	5.25				
i3	+		4.096	300	9.01	0	0	15000	.5	5.25				
i3	+		-1.024	300	9.00	0	np4	16000	.7	4.0				
;|||||=MEASURE 37
i3	+		3.072	300	9.01	pp5	0	13000	.2	5.25				
i3	+		-1.024	300	8.05	0	np4	8000	.7	4.0				
i3	+		3.072	300	8.04	pp5	0	5000	.2	5.25				
i3	+		-1.024	300	8.05	0	np4	8000	.7	4.0				
i3	+		3.072	300	8.04	pp5	0	5000	.2	5.25				
i3	+		-1.024	300	8.04	0	np4	8000	.7	4.0				
i3	+		3.072	300	8.03	pp5	0	5000	.2	5.25				
i3	+		-1.024	300	8.04	0	np4	8000	.7	4.0				
i3	+		3.072	300	8.03	pp5	0	5000	.2	5.25				
i3	+		-1.024	300	8.03	0	np4	8000	.7	4.0				
i3	+		3.072	300	8.02	pp5	0	5000	.2	5.25				
i3	+		-1.024	300	8.03	0	np4	8000	.7	4.0				
i3	+		3.072	300	8.02	pp5	0	5000	.2	5.25				

i3	178.688	-0.256	300	9.01	0	np4	6000	.5	3.25				
i3	+		0.256	300	9.02	0	0	8000	.5	3.25				
i3	+		-1.536	300	9.04	0	np4	12000	.6	4.25				
i3	+		0.512	300	9.09	0	0	15000	.7	3.5				
i3	+		-0.768	300	9.11	0	np4	12000	.8	3.75				
i3	+		-0.128	300	9.09	0	np4	12000	.3	3.0				
i3	+		-0.128	300	9.08	0	np4	12000	.3	3.0				
i3	+		0.256	300	9.09	0	0	13000	.5	3.25				
i3	+		-0.256	300	9.04	0	np4	14000	.5	3.25				
i3	+		-0.256	300	9.06	0	np4	15000	.5	3.25				
i3	+		0.256	300	9.08	0	0	16000	.5	3.25				
i3	+		-0.256	300	9.08	0	np4	17000	.5	3.25				
i3	+		-0.256	300	9.03	0	np4	18000	.5	3.25				
i3	+		-0.256	300	9.08	0	np4	18000	.5	3.25				
i3	+		0.256	300	10.01	0	0	19000	.2	3.25
;|||||=MEASURE 46				
i3	+		1.024	300	10.00	0	0	15000	.5	4.0				

i3	187.392	-1.024	300	8.01	10.01	np4	6500	.7	4.0				
i3	+		3.072	300	8.00	pp5	0	3000	.2	5.25				
i3	+		-1.024	300	8.00	9.00	np4	5500	.7	4.0				
i3	+		3.072	300	7.11	pp5	0	2500	.2	5.25				
i3	+		-1.024	300	8.00	0	np4	3000	.7	4.0				
i3	+		3.072	300	7.11	pp5	0	1750	.2	5.25

;=====ALTO FLUTE============================================
;p1	p2		p3	p4	p5	p6	p7	p8	p9	p10	
;Instr   	Sta		Dur	Amp	Pitch	Pitch	Amp	Amp	Peak	Vibrato
;==============================	From	To	Swell	Time	Speed (2.0-4.0)

i4	2.048		5.12	150	8.06	0	0	8000	.5	4.0
				
i4	8.192		-1.024	150	9.01	10.01	np4	9000	.6	3.0				
i4	+		2.048	150	9.06	pp5	0	6000	.3	3.5				
i4	+		2.048	150	9.05	0	0	8000	.5	3.5				
i4	+		2.048	150	9.05	0	0	8000	.5	3.5				

i4	17.408		2.048	150	9.05	0	0	8000	.5	3.5				

i4	21.504		2.048	150	9.04	0	0	8000	.5	3.5				
i4	+		-1.024	150	9.09	0	np4	9000	.6	3.0
;|||||=MEASURE 7				
i4	+		3.072	150	9.08	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	9.08	0	np4	9000	.6	3.0				
i4	+		3.072	150	9.07	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	9.08	0	np4	9000	.6	3.0				
i4	+		3.072	150	9.07	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	9.07	0	np4	9000	.6	3.0				
i4	+		3.072	150	9.06	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	9.07	0	np4	9000	.6	3.0				
i4	+		3.072	150	9.06	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	9.06	0	np4	9000	.6	3.0				
i4	+		3.072	150	9.05	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	9.06	0	np4	9000	.6	3.0				
i4	+		3.072	150	9.05	pp5	0	6000	.3	4.0				
i4	+		4.096	150	9.00	0	0	8000	.5	4.0				
i4	+		-1.024	150	8.11	0	np4	9000	.6	3.0
;|||||=MEASURE 15				
i4	+		3.072	150	9.00	pp5	0	6000	.3	4.0
i4	+		4.096	150	8.11	0	0	8000	.5	4.0				
i4	+		-1.024	150	8.10	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.11	pp5	0	6000	.3	4.0				
i4	+		4.096	150	8.10	0	0	8000	.5	4.0				
i4	+		-1.024	150	8.09	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.10	pp5	0	6000	.3	4.0				

i4	78.336		-0.256	150	9.01	0	np4	3000	.5	2.0				
i4	+		0.256	150	9.02	0	0	4000	.5	2.0				
i4	+		-1.536	150	9.04	0	np4	6000	.6	3.25				
i4	+		0.512	150	9.09	pp5	0	7500	.7	2.5				
i4	+		-0.768	150	9.11	0	np4	9000	.8	2.75				
i4	+		-0.128	150	9.09	0	np4	6000	.3	2.0				
i4	+		-0.128	150	9.08	0	np4	6000	.3	2.0
;|||||=MEASURE 21				
i4	+		0.256	150	9.09	0	0	6000	.5	2.0				
i4	+		-0.256	150	9.04	0	np4	6500	.5	2.0				
i4	+		-0.256	150	9.06	0	np4	7000	.5	2.0				
i4	+		0.256	150	9.08	0	0	7500	.5	2.0				
i4	+		-0.256	150	9.09	0	np4	8000	.5	2.0				
i4	+		-0.256	150	9.04	0	np4	8500	.5	2.0				
i4	+		-0.256	150	9.09	0	np4	9000	.5	2.0				
i4	+		0.256	150	10.02	0	0	9000	.5	2.0				
i4	+		1.024	150	10.01	0	0	9500	.2	3.0				
i4	+		-1.024	150	9.01	pp5	np4	9000	.6	3.0				
i4	+		3.072	150	9.00	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	9.01	0	np4	9000	.6	3.0				
i4	+		3.072	150	9.00	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	9.00	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.11	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	9.00	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.11	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.11	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.10	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.11	0	np4	9000	.6	3.0				
;|||||=MEASURE 27
i4	+		3.072	150	8.10	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.10	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.09	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.10	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.09	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.09	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.08	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.09	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.08	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.08	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.07	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.08	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.07	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.07	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.06	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.07	0	np4	9000	.6	3.0				
;|||||=MEASURE 35
i4	+		3.072	150	8.06	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.06	0	np4	9000	.6	3.0				
i4	+		3.072	150	8.05	pp5	0	6000	.3	4.0				
i4	+		-1.024	150	8.06	0	np4	9000	.6	3.0				
i4	+		2.048	150	8.05	pp5	0	6000	.3	3.5				

i4	150.528	4.096	150	8.00	0	0	4000	.5	4.0				
i4	+		-1.024	150	7.11	0	np4	5000	.6	3.0				
i4	+		3.072	150	8.00	pp5	0	4000	.3	4.0				
i4	+		4.096	150	7.11	0	0	4000	.5	4.0				
i4	+		-1.024	150	7.10	0	np4	5000	.6	3.0				
i4	+		3.072	150	7.11	pp5	0	4000	.3	4.0				
i4	+		4.096	150	7.10	0	0	4000	.5	4.0				
i4	+		-1.024	150	7.09	0	np4	4000	.6	3.0				
i4	+		3.072	150	7.10	pp5	0	3000	.3	4.0				
i4	+		4.096	150	7.09	0	0	4000	.5	4.0				
i4	+		-1.024	150	7.08	0	np4	4000	.6	3.0				
;|||||=MEASURE 45
i4	+		3.072	150	7.09	pp5	0	3000	.3	4.0				
i4	+		4.096	150	7.08	0	0	4000	.5	4.0				
i4	+		-1.024	150	7.07	0	np4	4000	.6	3.0				
i4	+		3.072	150	7.08	pp5	0	3000	.3	4.0				
i4	+		4.096	150	7.07	0	0	3000	.5	4.0				
i4	+		-1.024	150	7.06	0	np4	2000	.6	3.0				
i4	+		3.072	150	7.07	pp5	0	1500	.3	4.0

;=====BASS FLUTE============================================
;p1	p2		p3	p4	p5	p6	p7	p8	p9	p10	
;Instr   	Start		Dur	Amp	Pitch	Pitch	Amp	Amp	Peak	Vibrato
;==============================		From	To	Swell	Time (3.0 - 4.5)

i5	1.024		6.144	125	7.01	0	0	7000	.5	4.5
				
i5	8.192		-1.024	125	7.06	8.06	np4	8000	.6	4.5				
i5	+		2.048	125	8.01	pp5	0	4000	.3	3.75				
i5	+		2.048	125	8.00	0	0	7000	.5	3.75
i5	+		2.048	125	8.00	0	0	7000	.5	3.75
				
i5	17.408		2.048	125	8.00	0	0	7000	.5	3.75				

i5	21.504		2.048	125	7.11	0	0	7000	.5	3.75
				
i5	27.648		4.096	125	8.03	0	0	7000	.5	4.5				
i5	+		-1.024	125	8.02	0	np4	8000	.6	3.0				
i5	+		3.072	125	8.03	pp5	0	4000	.3	4.5				
i5	+		4.096	125	8.02	0	0	7000	.5	4.5				
i5	+		-1.024	125	8.01	0	np4	8000	.6	3.0				
;|||||=MEASURE 11
i5	+		3.072	125	8.02	pp5	0	4000	.3	4.5				
i5	+		4.096	125	8.01	0	0	7000	.5	4.5				
i5	+		-1.024	125	8.00	0	np4	8000	.6	3.5				
i5	+		3.072	125	8.01	pp5	0	4000	.3	4.5				

i5	57.856		1.024	125	7.07	0	0	6000	.5	3.0				
i5	+		1.024	125	8.00	0	0	7000	.5	3.0				
i5	+		0.512	125	8.04	0	0	8000	.5	3.0				
i5	+		-1.024	125	8.07	0	np4	9000	.75	3.0				
i5	+		1.024	125	8.06	pp5	0	10000	.2	3.0				

i5	70.144		-0.256	125	7.02	0	np4	6000	.5	3.0				
i5	+		0.256	125	7.03	0	0	7000	.5	3.0				
i5	+		-1.536	125	7.05	0	np4	8000	.6	3.75				
i5	+		0.512	125	7.10	pp5	0	10000	.7	3.0				
i5	+		-0.768	125	8.00	0	np4	11000	.8	3.0				
i5	+		-0.128	125	7.10	0	np4	9000	.3	3.0				
i5	+		-0.128	125	7.09	0	np4	9000	.3	3.0				
;|||||=MEASURE 19
i5	+		0.256	125	7.10	0	0	9000	.5	3.0				
i5	+		-0.256	125	7.05	0	np4	9200	.5	3.0				
i5	+		-0.256	125	7.07	0	np4	9400	.5	3.0				
i5	+		0.256	125	7.09	0	0	9600	.5	3.0				
i5	+		-0.256	125	7.10	0	np4	9800	.5	3.0				
i5	+		-0.256	125	7.05	0	np4	10000	.5	3.0				
i5	+		-0.256	125	7.10	0	np4	10200	.5	3.0				
i5	+		0.256	125	8.03	0	0	10400	.5	3.0				
i5	+		1.024	125	8.02	0	0	10600	.2	3.0				

i5	84.992		4.096	125	7.08	0	0	7000	.5	4.5				
i5	+		-1.024	125	7.07	0	np4	8000	.6	3.0				
i5	+		3.072	125	7.08	pp5	0	4000	.3	4.5				
i5	+		4.096	125	7.07	0	0	7000	.5	4.5				
i5	+		-1.024	125	7.06	0	np4	8000	.6	2.0				
i5	+		3.072	125	7.07	pp5	0	4000	.3	4.5				
i5	+		4.096	125	8.06	0	0	7000	.5	4.5				
i5	+		-1.024	125	8.05	0	np4	8000	.6	3.0				
i5	+		3.072	125	8.06	pp5	0	4000	.6	4.5				
i5	+		4.096	125	8.05	0	0	7000	.5	4.5				
i5	+		-1.024	125	8.04	0	np4	8000	.6	3.0				
;|||||=MEASURE 29
i5	+		3.072	125	8.05	pp5	0	4000	.3	4.5				
i5	+		4.096	125	8.04	0	0	7000	.5	4.5				
i5	+		-1.024	125	8.03	0	np4	8000	.6	3.0				
i5	+		2.048	125	8.04	pp5	0	4000	.3	4.5				

i5	125.952	4.096	125	8.03	0	0	7000	.5	3.0				
i5	+		-1.024	125	8.02	0	np4	8000	.6	3.0				
i5	+		3.072	125	8.03	pp5	0	4000	.3	3.0				
i5	+		4.096	125	8.02	0	0	8000	.5	4.5				

i5	139.264	0.512	125	7.02	8.02	0	6000	.5	2.0				
i5	+		-0.512	125	7.07	0	np4	8000	.6	3.0				
i5	+		0.512	125	7.06	pp5	0	6000	.3	3.0				
i5	+		-0.512	125	7.11	0	np4	9000	.6	3.0				
i5	+		0.512	125	7.09	pp5	0	7000	.3	3.0				
i5	+		-0.512	125	8.02	0	np4	10000	.6	3.0				
i5	+		1.024	125	8.01	pp5	0	8000	.2	3.0				
;|||||=MEASURE 36
i5	+		0.512	125	7.01	0	0	6000	.5	3.0				
i5	+		-0.512	125	7.06	0	np4	8000	.6	3.0				
i5	+		0.512	125	7.05	pp5	0	6000	.3	3.0				
i5	+		-0.512	125	7.10	0	np4	9000	.6	3.0				
i5	+		0.512	125	7.08	pp5	0	7000	.3	3.0				
i5	+		-0.512	125	8.01	0	np4	10000	.6	3.0				
i5	+		1.024	125	8.00	pp5	0	8000	.3	3.0			
i5	+		0.512	125	7.08	0	0	5000	.5	3.0				
i5	+		1.024	125	8.01	0	0	7000	.5	3.0				
i5	+		-0.512	125	8.06	0	np4	9000	.6	3.0				
i5	+		0.512	125	8.05	pp5	0	7000	.3	3.0				
i5	+		-0.512	125	8.10	0	np4	10000	.6	3.0				
i5	+		0.512	125	8.09	pp5	0	8000	.3	3.0				
i5	+		1.024	125	9.02	0	0	11000	.5	3.0				
i5	+		1.024	125	9.00	0	0	9000	.2	3.0				

i5	156.16		1.024	125	7.07	0	0	5000	.5	3.0				
i5	+		1.024	125	8.00	0	0	7000	.5	3.0				
i5	+		0.512	125	8.04	0	0	9000	.5	3.0				
i5	+		-1.024	125	8.07	0	np4	10000	.6	3.0				
i5	+		1.024	125	8.06	pp5	0	8000	.25	3.0				

i5	161.28		-0.256	125	7.03	0	np4	6000	.5	3.0				
i5	+		0.256	125	7.04	0	0	7000	.5	3.0				
i5	+		-1.536	125	7.06	0	np4	8000	.6	3.75				
i5	+		0.512	125	7.11	pp5	0	10000	.7	3.0				
i5	+		-0.768	125	8.01	0	np4	11000	.8	3.0				
i5	+		-0.128	125	7.11	0	np4	9000	.3	3.0				
i5	+		-0.128	125	7.10	0	np4	9000	.3	3.0				
i5	+		0.256	125	7.11	0	0	9000	.5	3.0				
i5	+		-0.256	125	7.06	0	np4	10000	.5	3.0				
i5	+		-0.256	125	7.08	0	np4	10500	.5	3.0				
i5	+		0.256	125	7.10	0	0	11000	.5	3.0				
i5	+		-0.256	125	7.11	0	np4	11500	.5	3.0				
i5	+		-0.256	125	7.06	0	np4	12000	.5	3.0				
i5	+		-0.256	125	7.11	0	np4	12500	.5	3.0				
i5	+		0.256	125	8.04	0	0	12500	.5	3.0				
i5	+		1.024	125	8.03	0	0	13000	.2	3.0				

i5	168.448	-0.256	125	7.02	0	np4	6000	.5	2.0				
i5	+		0.256	125	7.03	0	0	7000	.5	3.0				
i5	+		-1.536	125	7.05	0	np4	8000	.6	3.75				
i5	+		0.512	125	7.10	pp5	0	10000	.7	3.0				
i5	+		-0.768	125	8.00	0	np4	11000	.8	3.0				
i5	+		-0.128	125	7.10	0	np4	9000	.3	3.0				
i5	+		-0.128	125	7.09	0	np4	9000	.3	3.0				
i5	+		0.256	125	7.10	0	0	9000	.5	3.0				
i5	+		-0.256	125	7.05	0	np4	10000	.5	3.0				
i5	+		-0.256	125	7.07	0	np4	10500	.5	3.0				
i5	+		0.256	125	7.09	0	0	11000	.5	3.0				
i5	+		-0.256	125	7.10	0	np4	11500	.5	3.0				
i5	+		-0.256	125	7.05	0	np4	12000	.5	3.0				
i5	+		-0.256	125	7.10	0	np4	12500	.5	3.0				
i5	+		0.256	125	8.03	0	0	12500	.5	3.0
i5	+		-2.048	125	8.02	0	np4	6000	.6	4.5				
;|||||=MEASURE 44
i5	+		3.072	125	8.01	pp5	0	3000	.3	4.5				
i5	+		-1.024	125	8.02	0	np4	6000	.6	3.0				
i5	+		3.072	125	8.01	pp5	0	3000	.3	4.5				
i5	+		-1.024	125	8.01	0	np4	6000	.6	3.0				
i5	+		3.072	125	8.00	pp5	0	3000	.3	4.5				
i5	+		-1.024	125	8.01	0	np4	5000	.6	3.0				
i5	+		3.072	125	8.00	pp5	0	2500	.3	4.5				
i5	+		-1.024	125	8.00	0	np4	4000	.6	3.0				
i5	+		3.072	125	7.11	pp5	0	2000	.3	4.5				
i5	+		-1.024	125	8.00	0	np4	3500	.6	3.0				
i5	+		3.072	125	7.11	pp5	0	1000	.2	4.5
		
;=====CONTRABASS FLUTE=====================================
;p1	p2		p3	p4	p5	p6	p7	p8	p9	p10	
;Instr   	Sta		Dur	Amp	Pitch	Pitch	Amp	Amp	Peak	Vibrato
;==============================		From	To	Swell	Time (2.5 - 4.0)

i6	0		4.608	100	6.06	0	0	5000	.2	4.0				
i6	+		0.512	100	7.01	0	0	5000	.5	2.5				
i6	+		1.024	100	7.06	0	0	5000	.5	3.0				
i6	+		2.048	100	7.01	0	0	5000	.5	4.0				
i6	+		-0.512	100	6.06	0	np4	5000	.5	2.5				
i6	+		-0.512	100	6.10	0	np4	5000	.5	2.5				
i6	+		-0.512	100	7.01	0	np4	5000	.5	2.5				
i6	+		1.536	100	7.06	0	0	5000	.5	3.5				
i6	+		0.512	100	7.05	0	0	5000	.5	2.5				
i6	+		1.024	100	7.00	0	0	5000	.5	3.0				
i6	+		-0.256	100	7.05	0	np4	5000	.3	2.5				
i6	+		0.256	100	7.07	0	0	5000	.5	2.5				
i6	+		1.024	100	7.09	0	0	5000	.5	3.0				
i6	+		2.048	100	7.00	0	0	5000	.2	4.0				
;|||||=MEASURE 5
i6	+		-0.512	100	6.05	0	np4	7000	.5	2.5				
i6	+		-0.512	100	6.09	0	np4	7000	.5	2.5				
i6	+		-0.512	100	7.00	0	np4	7000	.5	2.5				
i6	+		1.536	100	7.05	0	0	7000	.2	3.5				
i6	+		1.536	100	7.04	0	0	7000	.5	3.5				
i6	+		0.512	100	7.08	0	0	7000	.5	2.5				
i6	+		1.024	100	7.11	0	0	7000	.5	3.0				
i6	+		1.536	100	6.11	0	0	7000	.2	3.5				
i6	+		0.512	100	6.11	0	0	7000	.5	2.5				
i6	+		-0.512	100	7.04	0	np4	7000	.5	2.5				
i6	+		-0.512	100	7.08	0	np4	7000	.5	2.5				
i6	+		-0.512	100	7.11	0	np4	7000	.5	2.5				
i6	+		1.536	100	8.04	0	0	7000	.5	3.5				
i6	+		0.512	100	8.03	0	0	7000	.5	2.5				
i6	+		1.024	100	7.10	0	0	7000	.5	3.0				
i6	+		0.512	100	8.03	0	0	7000	.5	2.5				
i6	+		1.024	100	7.07	0	0	7000	.5	3.0				
i6	+		1.536	100	7.10	0	0	7000	.2	3.5				
i6	+		0.512	100	7.10	0	0	7000	.5	2.5				
i6	+		-0.512	100	7.03	0	np4	7000	.5	2.5				
i6	+		-0.512	100	7.07	0	np4	7000	.5	2.5				
i6	+		-0.512	100	7.10	0	np4	7000	.5	2.5				
i6	+		1.536	100	8.03	0	0	7000	.2	3.5				
i6	+		0.512	100	8.02	0	0	7000	.5	2.5				
i6	+		1.024	100	7.09	0	0	7000	.5	3.0				
i6	+		0.512	100	8.02	0	0	7000	.5	2.5				
i6	+		1.024	100	7.06	0	0	7000	.5	3.0				
i6	+		1.536	100	7.09	0	0	7000	.5	3.5				
i6	+		0.512	100	7.09	0	0	7000	.5	2.5				
;|||||=MEASURE 11
i6	+		-0.512	100	7.02	0	np4	8000	.5	2.5				
i6	+		-0.512	100	7.06	0	np4	8000	.5	2.5				
i6	+		-0.512	100	7.09	0	np4	8000	.5	2.5				
i6	+		1.536	100	8.02	0	0	8000	.5	3.5				
i6	+		0.512	100	8.01	0	0	8000	.5	2.5				
i6	+		1.024	100	7.08	0	0	8000	.5	3.0				
i6	+		0.512	100	8.01	0	0	8000	.5	2.5				
i6	+		1.024	100	7.05	0	0	8000	.5	3.0				
i6	+		1.536	100	7.08	0	0	8000	.5	3.5				
i6	+		0.512	100	7.08	0	0	8000	.5	2.5				
i6	+		1.024	100	7.01	0	0	8000	.5	3.0				
i6	+		-0.256	100	7.05	0	np4	8000	.5	2.5				
i6	+		0.256	100	7.08	0	0	8000	.5	2.5				
i6	+		1.536	100	8.01	0	0	8000	.2	3.5				
i6	+		0.512	100	8.00	0	0	8000	.5	2.5				
i6	+		1.024	100	7.07	0	0	8000	.5	3.0				
i6	+		0.512	100	8.00	0	0	8000	.5	2.5				
i6	+		1.024	100	7.04	0	0	8000	.5	3.0				
i6	+		1.536	100	7.07	0	0	8000	.2	3.5				
i6	+		0.512	100	7.07	0	0	8000	.5	2.5				
i6	+		1.024	100	7.00	0	0	8000	.5	3.0				
i6	+		-0.256	100	7.04	0	np4	8000	.5	2.5				
i6	+		0.256	100	7.07	0	0	8000	.5	2.5				
i6	+		1.536	100	8.00	0	0	8000	.2	3.5				
i6	+		0.512	100	7.11	0	0	8000	.5	2.5				
i6	+		1.024	100	7.06	0	0	8000	.5	3.0				
i6	+		0.512	100	7.11	0	0	8000	.5	2.5				
i6	+		1.024	100	7.03	0	0	8000	.5	3.0				
i6	+		2.048	100	7.06	0	0	8000	.2	4.0				
;|||||=MEASURE 17
i6	+		-0.512	100	6.11	0	np4	9000	.5	2.5				
i6	+		-0.512	100	7.03	0	np4	9000	.5	2.5				
i6	+		-0.512	100	7.06	0	np4	9000	.5	2.5				
i6	+		1.536	100	7.11	0	0	9000	.2	3.5				
i6	+		0.512	100	7.10	0	0	9000	.5	2.5				
i6	+		1.024	100	7.05	0	0	9000	.5	3.0				
i6	+		0.512	100	7.10	0	0	9000	.5	2.5				
i6	+		1.024	100	7.02	0	0	9000	.5	3.0				
i6	+		1.792	100	7.05	0	0	9000	.5	3.5				
i6	+		0.256	100	7.05	0	0	9000	.5	2.5				
i6	+		-0.512	100	6.10	0	np4	9000	.5	2.5				
i6	+		-0.512	100	7.02	0	np4	9000	.5	2.5				
i6	+		-0.512	100	7.05	0	np4	9000	.5	2.5				
i6	+		1.536	100	7.10	0	0	9000	.2	3.5				
i6	+		0.512	100	7.09	0	0	9000	.5	2.5				
i6	+		1.024	100	7.04	0	0	9000	.5	3.0				
i6	+		0.512	100	7.09	0	0	9000	.5	2.5				
i6	+		1.024	100	7.01	0	0	9000	.5	3.0				
i6	+		2.048	100	7.04	0	0	9000	.2	4.0				
i6	+		-0.512	100	6.09	0	np4	9000	.5	2.5				
i6	+		-0.512	100	7.01	0	np4	9000	.5	2.5				
i6	+		-0.512	100	7.04	0	np4	9000	.5	2.5				
i6	+		-0.512	100	7.09	0	np4	9000	.5	2.5				
i6	+		-0.512	100	8.01	0	np4	9000	.5	2.5				
i6	+		1.024	100	8.04	0	0	9000	.5	3.0				
i6	+		2.048	100	7.08	0	0	9000	.5	4.0				
i6	+		1.536	100	7.09	pp5	0	9000	.5	3.5				
i6	+		1.536	100	7.10	pp5	0	9000	.5	3.5				
i6	+		1.024	100	7.11	pp5	0	9000	.5	3.0				
i6	+		0.512	100	8.00	pp5	0	9000	.5	2.5				
i6	+		1.024	100	8.01	pp5	0	9000	.5	3.0				
i6	+		2.048	100	8.02	pp5	0	9000	.5	4.0				
i6	+		-0.512	100	8.03	pp5	np4	9000	.5	2.5				
i6	+		0.512	100	8.04	pp5	0	9000	.5	2.5				
i6	+		1.024	100	8.05	pp5	0	9000	.5	3.0				
i6	+		1.024	100	8.06	pp5	0	9000	.5	3.0				
;|||||=MEASURE 25
i6	+		0.512	100	8.07	0	0	5000	.5	2.5				
i6	+		-0.256	100	7.11	0	np4	5000	.3	2.5				
i6	+		0.256	100	8.00	0	0	5000	.5	2.5				
i6	+		-1.536	100	8.02	0	np4	5000	.5	3.5				
i6	+		0.512	100	7.07	0	0	5000	.5	2.5				
i6	+		2.048	100	7.06	0	0	5000	.5	4.0				
i6	+		1.024	100	7.10	0	0	5000	.5	3.0				
i6	+		2.048	100	7.01	0	0	5000	.2	4.0				
i6	+		1.536	100	6.06	0	0	5000	.2	3.5				
i6	+		1.536	100	7.06	0	0	5000	.5	3.5				
i6	+		0.512	100	7.05	0	0	5000	.5	2.5				
i6	+		1.024	100	7.00	0	0	5000	.5	3.0				
i6	+		0.512	100	7.05	0	0	5000	.5	2.5				
i6	+		1.024	100	7.09	0	0	5000	.5	3.0				
i6	+		2.048	100	7.00	0	0	5000	.2	4.0				
i6	+		-0.512	100	6.05	0	np4	5000	.5	2.5				
i6	+		-0.512	100	6.09	0	np4	5000	.5	2.5				
i6	+		-0.512	100	7.00	0	np4	5000	.5	2.5				
i6	+		1.536	100	7.05	0	0	5000	.2	3.5				
i6	+		0.512	100	7.04	0	0	5000	.5	2.5				
i6	+		1.024	100	6.11	0	0	5000	.5	3.0				
i6	+		0.512	100	7.04	0	0	5000	.5	2.5				
i6	+		1.024	100	7.08	0	0	5000	.5	3.0				
i6	+		1.536	100	6.11	0	0	5000	.2	3.5				
i6	+		0.512	100	6.11	0	0	5000	.5	2.5				
i6	+		-0.512	100	7.04	0	np4	5000	.5	2.5				
i6	+		-0.512	100	7.08	0	np4	5000	.5	2.5				
i6	+		-0.512	100	7.11	0	np4	5000	.5	2.5				
i6	+		1.536	100	8.04	0	0	5000	.2	3.5				
i6	+		0.512	100	8.03	0	0	5000	.5	2.5				
i6	+		1.024	100	7.10	0	0	5000	.5	3.0				
i6	+		0.512	100	8.03	0	0	5000	.5	2.5				
i6	+		1.024	100	7.07	0	0	5000	.5	3.0				
i6	+		1.536	100	7.10	0	0	5000	.2	3.5				
i6	+		0.512	100	7.10	0	0	5000	.5	2.5				
;|||||=MEASURE 33
i6	+		-0.512	100	7.03	0	np4	7000	.5	2.5				
i6	+		-0.512	100	7.07	0	np4	7000	.5	2.5				
i6	+		-0.512	100	7.10	0	np4	7000	.5	2.5				
i6	+		1.536	100	8.03	0	0	7000	.2	3.5				
i6	+		0.512	100	8.02	0	0	7000	.5	2.5				
i6	+		1.024	100	7.09	0	0	7000	.5	3.0				
i6	+		0.512	100	8.02	0	0	7000	.5	2.5				
i6	+		1.024	100	7.06	0	0	7000	.5	3.0				
i6	+		1.536	100	7.09	0	0	7000	.2	3.5				
i6	+		0.512	100	7.09	0	0	7000	.5	2.5				
i6	+		1.024	100	7.02	0	0	7000	.5	3.0				
i6	+		-0.256	100	7.06	0	np4	7000	.5	2.5				
i6	+		-0.256	100	7.09	0	np4	7000	.5	2.5				
i6	+		1.536	100	8.02	0	0	7000	.2	3.5				
i6	+		0.512	100	8.01	0	0	7000	.5	2.5				
i6	+		1.024	100	7.08	0	0	7000	.5	3.0				
i6	+		0.512	100	8.01	0	0	7000	.5	2.5				
i6	+		1.024	100	7.05	0	0	7000	.5	3.0				
i6	+		1.536	100	7.08	0	0	7000	.2	3.5				
i6	+		0.512	100	7.08	0	0	7000	.5	2.5				
i6	+		1.024	100	7.01	0	0	7000	.5	3.0				
i6	+		-0.256	100	7.05	0	np4	7000	.3	2.5				
i6	+		-0.256	100	7.08	0	np4	7000	.5	2.5				
i6	+		1.536	100	8.01	0	0	7000	.2	3.5				
i6	+		0.512	100	8.00	0	0	7000	.5	2.5				
i6	+		1.024	100	7.07	0	0	7000	.5	3.0				
i6	+		0.512	100	8.00	0	0	7000	.5	2.5				
i6	+		1.024	100	7.04	0	0	7000	.5	3.0				
i6	+		1.536	100	7.07	0	0	7000	.2	3.5				
i6	+		0.512	100	7.07	0	0	7000	.5	2.5				
i6	+		1.024	100	7.00	0	0	7000	.5	3.0				
i6	+		-0.256	100	7.04	0	np4	7000	.5	2.5				
i6	+		-0.256	100	7.07	0	np4	7000	.5	2.5				
i6	+		1.536	100	8.00	0	0	7000	.5	3.5				
i6	+		0.512	100	7.11	0	0	7000	.5	2.5				
i6	+		1.024	100	7.06	0	0	7000	.5	3.0				
i6	+		0.512	100	7.11	0	0	7000	.5	2.5				
i6	+		1.024	100	7.03	0	0	7000	.5	3.0				
i6	+		2.048	100	7.06	0	0	7000	.2	4.0				
;|||||=MEASURE 41
i6	+		-0.512	100	6.11	0	np4	8000	.5	2.5				
i6	+		-0.512	100	7.03	0	np4	8000	.5	2.5				
i6	+		-0.512	100	7.06	0	np4	8000	.5	2.5				
i6	+		1.536	100	7.11	0	0	8000	.2	3.5				
i6	+		0.512	100	7.10	0	0	8000	.5	2.5				
i6	+		1.024	100	7.05	0	0	8000	.5	3.0				
i6	+		0.512	100	7.10	0	0	8000	.5	2.5				
i6	+		1.024	100	7.02	0	0	8000	.5	3.0				
i6	+		2.048	100	7.05	0	0	8000	.2	4.0				
i6	+		-0.512	100	6.10	0	np4	8000	.5	2.5				
i6	+		-0.512	100	7.02	0	np4	8000	.5	2.5				
i6	+		-0.512	100	7.05	0	np4	8000	.5	2.5				
i6	+		1.536	100	7.10	0	0	8000	.2	3.5				
i6	+		0.512	100	7.09	0	0	8000	.5	2.5				
i6	+		1.024	100	7.04	0	0	8000	.5	3.0				
i6	+		0.512	100	7.09	0	0	8000	.5	2.5				
i6	+		1.024	100	7.01	0	0	8000	.5	3.0				
i6	+		2.048	100	7.04	0	0	8000	.2	2.0				
i6	+		-0.512	100	6.09	0	np4	8000	.5	2.5				
i6	+		-0.512	100	7.01	0	np4	8000	.5	2.5				
i6	+		-0.512	100	7.04	0	np4	8000	.5	3.5				
i6	+		1.536	100	7.09	0	0	8000	.2	3.5				
i6	+		1.024	100	6.08	0	0	8000	.5	3.0				
i6	+		1.024	100	7.08	pp5	0	10000	.5	3.0				
i6	+		1.024	100	7.00	pp5	0	11000	.5	3.0				
i6	+		1.536	100	7.03	pp5	0	8000	.2	3.5
i6	+		0.512	100	7.03	0	0	7000	.2	3.5				
i6	+		1.536	100	6.08	pp5	0	6000	.5	3.5				
i6	+		1.536	100	7.08	pp5	0	5000	.5	3.5				
i6	+		1.536	100	6.07	pp5	0	4000	.5	3.5				
i6	+		2.048	100	7.07	pp5	0	3000	.2	4.0				
i6	+		-1.536	100	7.02	pp5	np4	2000	.5	3.5				
i6	+		3.072	100	6.07	pp5	0	1750	.2	4.0

;=====FLUTE 1 Octave Harmony===================================
;p1	p2		p3	p4	p5	p6	p7	p8	p9	p10	
;Instr   	Start		Dur	Amp	Pitch	Pitch	Amp	Amp	Peak	Vibrato
;==============================	From	To	Swell	Time	Speed (3.00-5.25)

i7	3.072		-1.024	200	8.11	0	np4	9500	.8	4.0
i7	+		3.072	200	8.10	pp5	0	7500	.1	5.25
i7	+		-1.024	200	8.11	0	np4	9500	.8	4.0				
i7	+		3.072	200	8.10	pp5	0	7500	.1	5.25

i7	33.024		-0.256	200	9.03	0	np4	7500	.5	3.25				
i7	+		-0.256	200	9.02	0	np4	7000	.5	3.25				
i7	+		-0.256	200	9.00	0	np4	6500	.5	3.25				
i7	+		-0.256	200	8.10	0	np4	6000	.5	3.25				
i7	+		-0.256	200	8.08	0	np4	5500	.5	3.25				
i7	+		-0.256	200	8.07	0	np4	5000	.5	3.25				
i7	+		0.256	200	8.05	0	0	4500	.5	3.25				
i7	+		1.024	200	8.03	0	0	4000	.5	4.0

i7	41.216		-0.256	200	9.02	0	np4	7500	.5	3.25				
i7	+		-0.256	200	9.01	0	np4	7000	.5	3.25				
i7	+		-0.256	200	8.11	0	np4	6500	.5	3.25				
i7	+		-0.256	200	8.09	0	np4	6000	.5	3.25				
i7	+		-0.256	200	8.07	0	np4	5500	.5	3.25				
i7	+		-0.256	200	8.06	0	np4	5000	.5	3.25				
i7	+		0.256	200	8.04	0	0	4500	.5	3.25				
i7	+		1.024	200	8.02	0	0	4000	.5	4.0
				
i7	45.312		-0.256	200	9.01	0	np4	7500	.5	3.25				
i7	+		-0.256	200	9.00	0	np4	7000	.5	3.25				
i7	+		-0.256	200	8.10	0	np4	6500	.5	3.25				
i7	+		-0.256	200	8.08	0	np4	6000	.5	3.25				
i7	+		-0.256	200	8.06	0	np4	6500	.5	3.25				
i7	+		-0.256	200	8.05	0	np4	5000	.5	3.25				
i7	+		0.256	200	8.03	0	0	4500	.5	3.25				
i7	+		1.024	200	8.01	0	0	4000	.5	4.0				

i7	131.328	-0.256	200	10.03	0	np4	7500	.5	3.25				
i7	+		-0.256	200	10.02	0	np4	7000	.5	3.25				
i7	+		-0.256	200	10.00	0	np4	6500	.5	3.25				
i7	+		-0.256	200	9.10	0	np4	6000	.5	3.25				
i7	+		-0.256	200	9.08	0	np4	5500	.5	3.25				
i7	+		-0.256	200	9.07	0	np4	5000	.5	3.25				
i7	+		0.256	200	9.05	0	0	4500	.5	3.25				
i7	+		1.024	200	9.03	0	0	4000	.5	4.0				

i7	139.52		-0.256	200	9.02	0	np4	7500	.5	3.25				
i7	+		-0.256	200	9.01	0	np4	7000	.5	3.25				
i7	+		-0.256	200	8.11	0	np4	6500	.5	3.25				
i7	+		-0.256	200	8.09	0	np4	6000	.5	3.25				
i7	+		-0.256	200	8.07	0	np4	5500	.5	3.25				
i7	+		-0.256	200	8.06	0	np4	5000	.5	3.25				
i7	+		0.256	200	8.04	0	0	4500	.5	3.25				
i7	+		1.024	200	8.02	0	0	4000	.5	4.0
				
i7	143.616	-0.256	200	9.01	0	np4	7500	.5	3.25				
i7	+		-0.256	200	9.00	0	np4	7000	.5	3.25				
i7	+		-0.256	200	8.10	0	np4	6500	.5	3.25				
i7	+		-0.256	200	8.08	0	np4	6000	.5	3.25				
i7	+		-0.256	200	8.06	0	np4	5500	.5	3.25				
i7	+		-0.256	200	8.05	0	np4	5000	.5	3.25				
i7	+		0.256	200	8.03	0	0	4500	.5	3.25				
i7	+		1.024	200	8.01	0	0	4000	.5	4.0				

i7	147.456	-0.256	200	9.05	0	np4	7500	.5	3.25				
i7	+		0.256	200	9.06	0	0	7500	.5	3.25				
i7	+		0.512	200	9.08	0	0	7500	.5	3.5				
i7	+		0.512	200	9.05	0	0	7500	.5	3.5				
i7	+		1.024	200	9.01	0	0	7500	.3	4.0				

i7	184.32		-1.024	200	8.08	7.08	np4	7500	.5	4.0				
i7	+		-1.024	200	8.09	pp5	np4	5000	.5	4.0				
i7	+		-1.024	200	8.10	pp5	np4	5500	.5	4.0				
i7	+		-1.024	200	8.11	pp5	np4	6000	.5	4.0				
i7	+		-1.024	200	9.00	pp5	np4	6500	.5	4.0				
i7	+		-1.024	200	9.01	pp5	np4	7000	.5	4.0				
i7	+		-1.024	200	9.02	pp5	np4	7500	.5	4.0				
i7	+		1.024	200	9.03	0	0	8000	.5	4.0				
i7	+		-1.024	200	9.04	pp5	np4	8500	.3	4.0				
i7	+		-1.024	200	9.05	pp5	np4	9000	.5	4.0				
i7	+		1.024	200	9.06	pp5	0	9500	.5	4.0				
i7	+		4.096	200	9.07	0	0	9500	.2	5.25		

;|||||||||||||||||SIGNAL PROCESSING|||||||||||||||||

;==========================	;|
;CHORUS, alto flute		    	;|
f32	0	4096	10	1	;|
;	Start	Dur	In	Out	;|
i78	0	202	4	24	;|
;==========================	;|

;==========================	;|
;FLANGER, bass flute		    	;|
f33	0	4096	10	1	;|
;	Start	Dur	In	Out	;|
i79	0	202	5	25	;|
;==========================	;|

;		||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;		5 BAND EQ FOR EACH INSTRUMENT	
;		||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;======================================================	;|
;PICCOLO	Lcut1	Lcut2	Hcut1	Hcut2					;|
f11  0  4  -2	1000	2000	4000	8000					;|				
										;|
;Instr	Sta	Dur    	Lgain1	Lgain2	Mgain	Hgain1	Hgain2	IN	OUT	;|
;p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	;|
i90	0      	202       	.3        	.2       	.1      	.1        	.1        	1        	7	;|
;======================================================	;|
;FLUTE  1	Lcut1	Lcut2	Hcut1	Hcut2					;|
f12  0  4  -2	300	1000	2500	5000					;|
										;|
;Instr	Sta	Dur    	Lgain1	Lgain2	Mgain	Hgain1	Hgain2	IN	OUT	;|
;p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	;|
i91	0      	202       	.2        	.4       	.5      	.2        	.1        	2        	8	;|
;======================================================	;|
;FLUTE  2	Lcut1	Lcut2	Hcut1	Hcut2					;|
f13  0  4  -2	300	1000	2500	5000					;|
										;|
;Instr	Sta	Dur    	Lgain1	Lgain2	Mgain	Hgain1	Hgain2	IN	OUT	;|
;p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	;|
i92	0      	202       	.2        	.4       	.5      	.2        	.1        	3        	9	;|
;======================================================	;|
;ALTO FLUTE	Lcut1	Lcut2	Hcut1 	Hcut2					;|
f14  0  4  -2	250	750	2000	4000					;|
										;|
;Instr	Sta	Dur    	Lgain1	Lgain2	Mgain	Hgain1	Hgain2	IN	OUT	;|
;p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	;|
i93	0      	202       	.2        	.2       	.2      	.2        	.1        	24        	10	;|
;======================================================	;|
;BASS FLUTE	Lcut1 	Lcut2	Hcut1	Hcut2					;|
f15  0  4  -2	200	500	1250	2500					;|
										;|
;Instr	Sta	Dur    	Lgain1	Lgain2	Mgain	Hgain1	Hgain2	IN	OUT	;|
;p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	;|
i94	0      	202       	.1        	.2       	.2      	.2        	.1        	25        	11	;|
;|======================================================	;|	
;CB FLUTE	Lcut1	Lcut2 	Hcut1 	Hcut2					;|
f16  0  4  -2	100	350	1000	1500					;|
										;|
;Instr	Sta	Dur    	Lgain1	Lgain2	Mgain	Hgain1	Hgain2	IN	OUT	;|
;p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	;|
i95	0      	202       	.2        	.2       	.3      	.2        	.1        	6        	12	;|
;======================================================	;|
;Fl Harmony	Lcut1	Lcut2	Hcut1	Hcut2					;|
f12  0  4  -2	275	900	2250	4500					;|
										;|
;Instr	Sta	Dur    	Lgain1	Lgain2	Mgain	Hgain1	Hgain2	IN	OUT	;|
;p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	;|
i96	0      	202       	.25        	.3       	.4      	.2        	.1        	19        	20	;|
;======================================================	;|
;Comment any EQ instrument line(s) to mute or solo instrument(s)

;					||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;				           	6 DISCREET REVERB PROCESSORS
;					||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;REVERB 1		CH 1	CH 2
;			PICC	FL 1
;instr	sta	dur	inL	inR	outL	outR	rvbL	rvbR	wetL	wetR	rollL	rollR	diffL	diffR
;p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	p11	p12	p13	p14	p15
i97	0	202	7	8	13	14	2	1.5	.2	.25	5000	3000	.3	.5

;REVERB 2		CH 3	CH 4
;			FL 2	ALTO
;instr	sta	dur	inL	inR	outL	outR	rvbL	rvbR	wetL	wetR	rollL	rollR	diffL	diffR
;p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	p11	p12	p13	p14	p15
i98	0	202	9	10	15	16	1.5	1	.25	.2	3000	1000	.5	.7

;REVERB 3		CH 5	CH 6
;			BASS	C-BASS
;instr	sta	dur	inL	inR	outL	outR	rvbL	rvbR	wetL	wetR	rollL	rollR	diffL	diffR
;p1	p2	p3	p4	p5	p6	p7	p8	p9	p10	p11	p12	p13	p14	p15
i99	0	202	11	12	17	18	1	.5	.15	.1	750	375	.8	.9

;REVERB 4		Flute 1 Harmony
;			
;instr	sta	dur	in	outL	rvb	wet	roll	diff	
;p1	p2	p3	p4	p5	p6	p7	p8	p9
i100	0	202	20	21	1.5	.25	3000	.5


;						|||||||||||||||||||||||||||||||||||||||||||||||||
;						7 CHANNEL MIXER
;						|||||||||||||||||||||||||||||||||||||||||||||||||
;========================================================================================;|
;7 CHANNEL	  piccolo            	flute 1       	flute 2               	alto               	bass                  	contrabass	Fl 1 harmony	;|
;MIXER	  |CH 1               	|CH 2            	|CH 3           	|CH 4                 	|CH 5                	|CH 6   				;|  
;In/Gain/Pan       i      g      p       	i      g     p       	i        g        p 	i        g       p       	i        g        p      	i        g        p	i      g       p	;|        
;p1    p2  p3	  p4   p5   p6    	p7   p8   p9     	p10   p11   p12	p13   p14   p15  	p16   p17   p18	p19   p20   p21  p22  p23  p24	;|    
;ins   sta dur    															;|
i101 0    202	13   .85   .7	14  .5   .3    	15    .5       .7    	16    .4      .3   	17    .55       .5	18    .75      .5	21   .25     .7	;|
;========================================================================================	;|
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
