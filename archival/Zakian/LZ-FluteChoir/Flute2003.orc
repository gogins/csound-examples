/*
FLUTE CHOIR
Lee Zakian
1/7/03 10:56:01 PM
*/

sr 		= 44100
kr 		= 4410
ksmps 		= 10
nchnls 		= 2
zakinit   	30, 30

;=====================
	instr 1	;PICCOLO
;	range: 	9.02 - 11.11
;		D5 - B7
;=====================
idur    	=       	abs(p3)		;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	0.005		;portamento, slurred notes: 0.001 = cleanest, 0.99 = glissando
iamp    	=       	p4		;tied note starts at amp ramp
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
irise   	=       	idur*p9             	;0.01 = sharp accent, 0.9 = crescendo
idovib 	=       	1           		;vibrato, except on short notes
i1      	=       	-1                  	;tied note phase
i2      	=       	-1                  	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               		;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0                   	;reset phase for 1st note
i2      	=       	0.25                	;vibrato phase offset
iamp    	=       	0                   	;set start amp
iatt    	=       	0.01                	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
idovib 	=       	0           			;no vibrato on short notes
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    	=       	idur-iadjust				;create amplitude ramp
amp     	linseg  	iamp, iatt, p4, ilen, p4, idec, p7
if      	ir == 1 goto pitch  				;no chiff on tied notes
ichiff  		=       	p4/40               			;chiff set to 2.5% of amp
ifac1   		=       	(p5 >11.00 ? 2.0 : 0.05)  	;balance chiff with register
ifac2   		=       	(p5 >11.00 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp*.5, amp
achiff1		reson	anoise, 2000, 200, 1, 1		;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 400, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1	;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
if      	ir == 0 || 	p6 == p5 kgoto expr  	;skip pitchramp on 1st note or tie
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
if     	idovib == 0 goto play   		;no vibrato on short notes
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
	instr 2	;FLUTE 1
;	range: 	7.11 - 11.02
;		B3 - D7 
;=====================
idur    	=       	abs(p3)		;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	0.009    	;portamento, slurred notes: 0.001 = cleanest, 0.99 = glissando
iamp    	=       	p4		;tied note starts at amp ramp
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
iminat	=	octpch(7.11)
imaxat	=	octpch(11.02)
irngat	=	iminat-imaxat
indxat	=	(ioctat-iminat)/irngat
iatt	tablei	indxat, iatkfn, 1
;=====================
;DECAY
;=====================
index	=	idur
idec	tablei	index, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	2
irise   	=       	idur*p9             	;0.01 = sharp accent, 0.9 = crescendo
idovib 	=       	1           		;vibrato, except on short notes
i1      	=       	-1                  	;tied note phase
i2      	=       	-1                  	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               		;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0                   	;reset phase for 1st note
i2      	=       	0.25                	;vibrato phase offset
iamp    	=       	0                   	;set start amp
iatt    	=       	0.05                	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
idovib 	=       	0           			;no vibrato on short notes
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust			;create amplitude ramp
amp     		linseg  	iamp, iatt, p4, ilen, p4, idec, p7
if      	ir == 1 goto pitch  				;no chiff on tied notes
ichiff  		=       	p4/20               			;chiff set to 5% of amp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05)  		;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1		;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1	;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
if      	ir == 0 || 	p6 == p5 kgoto expr  	;skip pitchramp on 1st note or tie
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
if     	idovib == 0 goto play   		;no vibrato or breath on short notes
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
aflu1	oscil3  		amp+aslur, kpch, 1, i1				;fundamental		
aflu2	oscil3  		(amp*1.5)+aslur, kpch, 27, i1			;partials 2, 3
aflu3	oscil3  		(amp*2.5)+aslur, kpch, 28, i1			;partials 4, 5, 6
aflu4	oscil3  		(amp*1.5)+aslur, kpch, 29, i1			;partials 2, 3
aflu5	oscil3  		(amp*2)+aslur, kpch, 30, i1			;partials 4, 5
aflu6	oscil3  		(amp*1.5)+aslur, kpch, 31, i1			;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

;=====================
	instr 3	;FLUTE 2
;	range: 	7.11 - 11.02
;		B3 - D7 
;=====================
idur    	=       	abs(p3)		;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	0.009    	;portamento, slurred notes: 0.001 = cleanest, 0.99 = glissando
iamp    	=       	p4		;tied note starts at amp ramp
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
iminat	=	octpch(7.11)
imaxat	=	octpch(11.02)
irngat	=	iminat-imaxat
indxat	=	(ioctat-iminat)/irngat
iatt	tablei	indxat, iatkfn, 1
;=====================
;DECAY
;=====================
index	=	idur/8
idec	tablei	index, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	3
irise   	=       	idur*p9             	;0.01 = sharp accent, 0.9 = crescendo
idovib 	=       	1           		;vibrato, except on short notes
i1      	=       	-1                  	;tied note phase
i2      	=       	-1                  	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               		;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0                   	;reset phase for 1st note
i2      	=       	0.25                	;vibrato phase offset
iamp    	=       	0                   	;set start amp
iatt    	=       	0.05                	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
idovib 	=       	0           			;no vibrato on short notes
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust			;create amplitude ramp
amp     		linseg  	iamp, iatt, p4, ilen, p4, idec, p7
if      	ir == 1 goto pitch  				;no chiff on tied notes
ichiff  		=       	p4/20               			;chiff set to 5% of amp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05)  		;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1		;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1	;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
if      	ir == 0 || 	p6 == p5 kgoto expr  	;skip pitchramp on 1st note or tie
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
if     	idovib == 0 goto play   		;no vibrato or breath on short notes
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
aflu1	oscil3  		amp+aslur, kpch, 1, i1				;fundamental		
aflu2	oscil3  		(amp*1.5)+aslur, kpch, 27, i1			;partials 2, 3
aflu3	oscil3  		(amp*2.5)+aslur, kpch, 28, i1			;partials 4, 5, 6
aflu4	oscil3  		(amp*1.5)+aslur, kpch, 29, i1			;partials 2, 3
aflu5	oscil3  		(amp*2)+aslur, kpch, 30, i1			;partials 4, 5
aflu6	oscil3  		(amp*1.5)+aslur, kpch, 31, i1			;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

;=====================
	instr 4	;ALTO
;	range: 	7.05 - 10.05
;		F3 - F6 
;=====================
idur    	=       	abs(p3)		;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	0.011    	;portamento, slurred notes: 0.001 = cleanest, 0.99 = glissando
iamp    	=       	p4		;tied note starts at amp ramp
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
index	=	idur/8
idec	tablei	index, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	4
irise   	=       	idur*p9             	;0.01 = sharp accent, 0.9 = crescendo
idovib 	=       	1           		;vibrato, except on short notes
i1      	=       	-1                  	;tied note phase
i2      	=       	-1                  	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               		;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0                   	;reset phase for 1st note
i2      	=       	0.25                	;vibrato phase offset
iamp    	=       	0                   	;set start amp
iatt    	=       	0.05                	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
idovib 	=       	0           			;no vibrato on short notes
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust			;create amplitude ramp
amp     		linseg  	iamp, iatt, p4, ilen, p4, idec, p7
if      	ir == 1 goto pitch  				;no chiff on tied notes
ichiff  		=       	p4/20               			;chiff set to 5% of amp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05)  		;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1		;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1	;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
if      	ir == 0 || 	p6 == p5 kgoto expr  	;skip pitchramp on 1st note or tie
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
if     	idovib == 0 goto play   		;no vibrato or breath on short notes
;=====================
;VIBRATO DEPTH
;=====================
ioctvd	=	octpch(p5)
iminvd	=	octpch(7.05)
imaxvd	=	octpch(10.05)
irngvd	=	iminvd-imaxvd
indxvd	=	(ioctvd-iminvd)/irngvd
ivibd	tablei	indxvd, ivdfn, 1
avib	oscili	ivibd*2, p10, 5, 0.25	;vibrato depth, speed, table, phase
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
aflu1	oscil3  		amp+aslur, kpch, 1, i1				;fundamental		
aflu2	oscil3  		(amp*1.5)+aslur, kpch, 27, i1			;partials 2, 3
aflu3	oscil3  		(amp*2.5)+aslur, kpch, 28, i1			;partials 4, 5, 6
aflu4	oscil3  		(amp*1.5)+aslur, kpch, 29, i1			;partials 2, 3
aflu5	oscil3  		(amp*2)+aslur, kpch, 30, i1			;partials 4, 5
aflu6	oscil3  		(amp*1.5)+aslur, kpch, 31, i1			;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

;=====================
	instr 5	;BASS
;	range: 	7.00 - 10.00
;		C3 - C6
;=====================
idur    	=       	abs(p3)		;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	0.013    	;portamento, slurred notes: 0.001 = cleanest, 0.99 = glissando
iamp    	=       	p4		;tied note starts at amp ramp
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
index	=	idur/8
idec	tablei	index, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	5
irise   	=       	idur*p9             	;0.01 = sharp accent, 0.9 = crescendo
idovib 	=       	1           		;vibrato, except on short notes
i1      	=       	-1                  	;tied note phase
i2      	=       	-1                  	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               		;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0                   	;reset phase for 1st note
i2      	=       	0.25                	;vibrato phase offset
iamp    	=       	0                   	;set start amp
iatt    	=       	0.05                	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
idovib 	=       	0           			;no vibrato on short notes
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust			;create amplitude ramp
amp     		linseg  	iamp, iatt, p4, ilen, p4, idec, p7
if      	ir == 1 goto pitch  				;no chiff on tied notes
ichiff  		=       	p4/20               			;chiff set to 5% of amp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05)  		;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1		;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1	;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
if      	ir == 0 || 	p6 == p5 kgoto expr  	;skip pitchramp on 1st note or tie
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
if     	idovib == 0 goto play   		;no vibrato or breath on short notes
;=====================
;VIBRATO DEPTH
;=====================
ioctvd	=	octpch(p5)
iminvd	=	octpch(7.00)
imaxvd	=	octpch(10.00)
irngvd	=	iminvd-imaxvd
indxvd	=	(ioctvd-iminvd)/irngvd
ivibd	tablei	indxvd, ivdfn, 1
avib	oscili	ivibd*1.5, p10, 5, 0.25	;vibrato depth, speed, table, phase
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
aflu1	oscil3  		amp+aslur, kpch, 1, i1				;fundamental		
aflu2	oscil3  		(amp*1.5)+aslur, kpch, 27, i1			;partials 2, 3
aflu3	oscil3  		(amp*2.5)+aslur, kpch, 28, i1			;partials 4, 5, 6
aflu4	oscil3  		(amp*1.5)+aslur, kpch, 29, i1			;partials 2, 3
aflu5	oscil3  		(amp*2)+aslur, kpch, 30, i1			;partials 4, 5
aflu6	oscil3  		(amp*1.5)+aslur, kpch, 31, i1			;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

;=====================
	instr 6	;CONTRABASS
;	range: 	6.00 to 9.00
;		C2 - C5
;===================== 
idur    	=       	abs(p3)		;absolute duration value
ipch1   =       	cpspch(p6)
ipch2   =       	cpspch(p5) 
kpch    	=       	ipch2
iport   	=       	0.015    	;portamento, slurred notes: 0.001 = cleanest, 0.99 = glissando
iamp    	=       	p4		;tied note starts at amp ramp
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
index	=	idur/8
idec	tablei	index, idecfn, 1
;=====================
;PEAK/SWELL
;=====================
iout	=	6
irise   	=       	idur*p9             	;0.01 = sharp accent, 0.9 = crescendo
idovib 	=       	1           		;vibrato, except on short notes
i1      	=       	-1                  	;tied note phase
i2      	=       	-1                  	;vibrato phase
kdclk	linseg  	0, .001, 2, p3-.5, 2, .01, 1, .001, 0	;declick envelope
;=====================
;TIED NOTES
;=====================
ir      	tival               		;tied note conditional init block
        	tigoto  	tie 
i1      	=       	0                   	;reset phase for 1st note
i2      	=       	0.25                	;vibrato phase offset
iamp    	=       	0                   	;set start amp
iatt    	=       	0.05                	;attack for 1st note of tie
tie:            
iadjust 	=       	iatt+idec
if      	idur >= iadjust igoto doamp	;adjust ramp duration on short notes, 10ms limit
iatt    	=       	(idur/2)-0.005
iadjust 	=       	idur-0.01           		;ensure ilen != 0 for linseg)
idovib 	=       	0           			;no vibrato on short notes
iport   	=       	0.002               		;smoother portamento on tied notes
;=====================
;AMPLITUDE RAMP 
;chiff, low pass filters
;=====================
doamp:          
ilen    		=       	idur-iadjust			;create amplitude ramp
amp     		linseg  	iamp, iatt, p4, ilen, p4, idec, p7
if      	ir == 1 goto pitch  				;no chiff on tied notes
ichiff  		=       	p4/20               			;chiff set to 5% of amp
ifac1   		=       	(p5 >8.06 ? 3.0 : 0.05)  		;balance chiff with register
ifac2   		=       	(p5 >8.06 ? 0.1 : 0.02)
aramp   	linseg  	0, 0.05, ichiff, 0.02, ichiff*0.5, 0.05, 0, 0, 0
anoise  	randi    aramp, amp
achiff1		reson	anoise, 2000, 400, 1, 1		;fixed hi freq filters, wide bandwidths
achiff2		reson	anoise, 4000, 800, 1, 1
achiff3 	reson   	anoise, ipch2*2, 30, 0, 1	;pitched chiff filter, narrow bandwidth
achiff  		=       	(achiff1+achiff2)*ifac1+(achiff3*ifac2)
;=====================
;PITCH
;=====================
pitch:
if      	ir == 0 || 	p6 == p5 kgoto expr  	;skip pitchramp on 1st note or tie
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
if     	idovib == 0 goto play   		;no vibrato or breath on short notes
;=====================
;VIBRATO DEPTH
;=====================
ioctvd	=	octpch(p5)
iminvd	=	octpch(6.00)
imaxvd	=	octpch(9.00)
irngvd	=	iminvd-imaxvd
indxvd	=	(ioctvd-iminvd)/irngvd
ivibd	tablei	indxvd, ivdfn, 1
avib	oscili	ivibd, p10, 5, 0.25	;vibrato depth, speed, table, phase
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
aflu1	oscil3  		amp+aslur, kpch, 1, i1				;fundamental		
aflu2	oscil3  		(amp*1.2)+aslur, kpch, 27, i1			;partials 2, 3
aflu3	oscil3  		(amp*1.7)+aslur, kpch, 28, i1			;partials 4, 5, 6
aflu4	oscil3  		(amp*1.2)+aslur, kpch, 29, i1			;partials 2, 3
aflu5	oscil3  		(amp*1.5)+aslur, kpch, 30, i1			;partials 4, 5
aflu6	oscil3  		(amp*1.2)+aslur, kpch, 31, i1			;partials 2, 3
asig   	butterlp 	(aflu1+aflu2+aflu3+aflu4+aflu5+aflu6), icut, 1	;add tables, trim high partials
	zawm		asig+asum+achiff*kenv2*kdclk, iout
	endin

	instr   91 	;EQ 1	PICCOLO 

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

	instr   92 	;EQ 2	FLUTE 1 

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

	instr   93 	;EQ 3 	FLUTE 2 

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

	instr   94 	;EQ 4	ALTO FLUTE 

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

	instr   95 	;EQ 5	BASS FLUTE 

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

	instr   96 	;EQ 6	CONTRABASS FLUTE 

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

	instr 100	;MIXER: 6 in 2 out 

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
;=================================================	;|

			;mac opcode multiplies & accumulates signals
aoutL		mac	igL1, a1, igL2, a2, igL3, a3, igL4, a4, igL5, a5, igL6, a6 
aoutR		mac	igR1, a1, igR2, a2, igR3, a3, igR4, a4, igR5, a5, igR6, a6 
		outs	aoutL, aoutR
		zacl	0, 30	;clear audio channels 0 to 30
		endin

