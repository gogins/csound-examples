<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; Jim Dashow:	orchestra for beginning of In Winter Shine
sr		=		48000
ksmps	=		1
nchnls	=		2

ga15	   	init	 	0
ga16	   	init		0

		instr 15			; NOISE MOD

p12 		= 		(p12=0?  1.3807 : p12)

	;  this code puts together zvfmult pch table, rand control and
	;  zvfmult rthm table, output of this is aimed at zvsi, zvamph,
	;  zvsi with phs controlled reinit. i5 thru i20, i35-i38,
	;  kk1 thru kk6 are reserved for these units.  kk3 and kk4 are now
	;  unused; kk5=stereo left, kk6=stereo right, i9=zvfmult output,
	;  i8=cps dev from pch. Also k1 thru k4, a5 as envlpx
	;  output.  i1 thru i4 are available for synching tables with
	;  envlpx.

i35 		= 		int(frac(abs(p9))*100+.5)
i20 		= 		(i35-int(abs(p9))-.02)*.5 ; RAND RANGE INIT
i5 		= 		int(abs(p9))+i20		; RND CENTER INIT
i20 		= 		i20+1
i6 		= 		i35+1				; OLD RND NUM INIT
i7 		= 		(p5<0? 1.021975/cpspch(abs(p5)) : cpspch(p5)/1.021975) ; TRNS INIT
i16 		= 		p3/int(p14)			; ATAX INIT
i19 		= 		p4	;amp
kk1   	randi	i20,437,p10
; series 	zvfmult 	inits
i10 		= 		int(abs(p9))-1 ;loc1 pointer
i11 		= 		(p10=0? i10 : p10-1) 	; RECYC INIT
; rthm 	zvfmult 	inits
i12 		= 		int(p20)-1	   ;loc2 pointer
i13 		= 		(p21=0? i12 : p21-1) 	; RECYC INIT
i14 		= 		0		    			; ATAX
i15 		= 		0		    			; TOTAL
; zvamph inits
		if 		p24=0 goto  env
i18 		= 		int(p24)-1			; POINTER INIT
i17 		= 		ftlen(int(frac(p24)*100+.5))
kk2   	init	 	int(p24)/i17
kk2   	phasor	p23/p3,i(kk2) 			; FOR POS p23 CPS
; envlpx init
env:	  
i36 		= 		(frac(p15)=0?  1 : frac(p15)*10)  ; ATTEN FACTOR OF SS
	  
rinit:

i9 		= 		p9					; INIT CONSTANT PITCH
		if 		p11=0 igoto nt1
		if 		i11>=0 igoto skp1
rnd: 
i10 		= 		int(i5+i(kk1))
i10 		= 		(i10<int(p9)? int(p9):i10)
i10 		= 		i10+(i10=i6? 1 : 0)
i10 		= 		(i10>i35?  int(p9) : i10)
i6 		=	 	i10
skp1: 
i9		tablei   	i10,p11
i10 		= 		i10+1
		if 		i10<i35	  igoto nt1
i10 		= 		i11
nt1: 
i9 		= 		cpspch(i9)*i7	  		; i9=sipch
i8 		= 		p6*i9				; SET MAX DEVIATION FOR RAND INPUT
						

; rthm zvfmult

j30:	 
		if 		p22=0	 igoto nt2
; i16 MUST BE INIT TO P3/P14 BEFORE HERE
skp2: 
it3	 	tablei   	i12,p22
i12 		= 		i12+1
		if 		i12<int(frac(p20)*100+.5)	  igoto to2
i12 		= 		i13
to2:	 
		if 		i14>=int(p14)  igoto j35
; LOOP FOR RTHM VALUES
i15 		= 		i15+it3
i14 		= 		i14+1
		if 		i14<int(p14)  igoto skp2
; EXIT FROM LOOP AND SET LOC POINTER FOR FIRST ATTACK
i12 		= 		int(p20)-1
		igoto 	skp2
j35: 
i16 		= 		p3*it3/i15 			; DUR VALUE TO SENT TO envlpx, timout & linseg

nt2:	 
		if 		p24=0	 igoto nt3 	; zvamph
i18 		= 		i18+1
		if 		i18<abs(p23) igoto j40
i18 		= 		int(p24)
j40: 
i18 		= 		(p23<0? i18 : i(kk2)*i17)
i19  	tablei	i18,int(frac(p24)*100+.5)
i19 		=		i19*p4				; FINAL AMP

; envosc
nt3: 
k2		linseg  	0,p13,.25,i16-p13,1		; ENV FOLLOWER CONTROL
a5		envlpx  	i19,p13,i16,frac(p14)*10,int(p15),i36,1/p16
		timout  	0,i16,j50

		reinit	rinit
		rireturn

j50:									; STEREO CONTROL

kk5		init	  	p17					; LEFT PROP
kk6		init	   	1-p17				; RIGHT PROP
		if 		p19=0   goto  j60
it1		=   		(p17=1?  1 : int(p17)*.1)
i37		=   		frac(p17)				; MIN
i38		=   		it1-i37				; dif
k4		oscili   	i38,p18/p3,frac(p19)*100+.5,int(p19) ; WRONG PHASE
kk5		=	   	i37+k4
kk6		=   	1-kk5
; AT END OF INSTR, WRITE OUTS sig*kk5,sig*kk6

j60: 
a1  		=  		0
		if 		p25=0  goto j70
kk7  	init	 	p25
		if 		p28=0  goto j65
i1   	=    	int(frac(p28)*100+.5)	; NF
i2   	=    	ftlen(i1)
k5   	phasor   	p27/p3,int(p28)/i2
k5   	=    	(p27=0?  k2 : k5)
k5   	tablei	k5*i2,i1
kk7		=   		p25+k5*(p26-p25)
j65: 
a5		randi   	a5,kk7,frac(p12)	 	; RMOD
j70:	   
		if 		p8=0   goto j80
a1   	rand	   	i8,frac(p12)
i3   	=    	int(frac(p8)*100+.5)	; NF
i4   	=    	ftlen(i3)
k6   	phasor   	p7/p3,int(p8)/i4
k6   	=    	(p7=0?  k2 : k6)
k6   	tablei	   k6*i4,i3
a1   	=    	a1*k6
j80: 
a1		oscili  	a5,i9+a1,int(p12),0
ga15		=   		ga15+a1
		outs    	a1*kk5,a1*kk6
		endin

		instr	16		; OSCILM...3, 5, or 7 OSCILS

i7 		= 		int(frac(p12)*100+.5)	; NF SIG INIT
i8 		= 		(p6<0? (cpspch(abs(p6))/1.021975)-1 : p6) ; ADDINTRVAL MIN
p7 		= 		(p6<0? (cpspch(p7)/1.021975)-1 : p7)  ; ADDINT MAX
kk7		init   	i8					; ADDHZ INIT
i22 		= 		p7-i8				; ADDHZ DIF
p28 		= 		(p28=0?	 2/int(p12) : p28/int(p12))  ; AMP ADJUST
p4 		= 		p4*p28
i21 		= 		int(p12+.5)			; NOSC
		

	;  this code puts together zvfmult pch table, rand control and
	;  zvfmult rthm table, output of this is aimed at timout,envlpx,
	;  and linseg; timout sets reinit. i5 thru i20, i35-i38,
	;  kk1 thru kk6 are reserved for these units.  kk3, kk4 now unused.
	;  kk5=stereo left, kk6=stereo right, i9=zvfmult output, a5 is envlpx
	;  output;  k1 thru k4 reserved.

i35 		= 		int(frac(abs(p10))*100+.5)
i20 		= 		(i35-int(abs(p10))-.02)*.5 ; RAND RANGE INIT
i5 		= 		int(abs(p10))+i20		; RND CENTER INIT
i20 		= 		i20+1
i6 		= 		i35+1				; OLD RND NUM INIT
i16 		= 		p3/int(p14)	   		; ATAX INIT
i19 		= 		p4	;amp
kk1   	randi	i20,431,frac(p11)
; series zvfmult inits
i10 		= 		int(abs(p10))-1	   	; loc1 POINTER
it1 		= 		int(frac(abs(p11))*100+.5)
i11 		= 		(it1=0? i10 : it1-1) 	; RECYC INIT
; rthm zvfmult inits 
i12 		= 		int(p20)-1	   		; loc2 POINTER
i13 		= 		(p21=0? i12 : p21-1) 	; RECYC INIT
i14 		= 		0		    			; ATAX
i15 		= 		0		    			; TOTAL
;zvamph inits
		if 		p24=0 igoto  env
i18 		= 		int(p24)-1	  		; POINTER INIT
i17 		= 		ftlen(int(frac(p24)*100+.5))
kk2   	init	 	int(p24)/i17
kk2   	phasor	p23/p3,i(kk2)   		; FOR POS p23 CPS
; envlpx init
env:	  
i36 		= 		(frac(p15)=0?  1 : frac(p15)*10)  ; ATTEN FACTOR OF SS
; nf zvfmult inits
i23 		= 		int(p25)-1
i24 		= 		(p26=0? i23 : p26-1)	; RECYC
			

rinit:

i9 		= 		p10					; CONSTANT PCH INIT
		if 		p11=0 igoto j30
		if 		p11>0 igoto skp1
rnd: 	
i10 		= 		int(i5+i(kk1))
it1 		= 		int(abs(p9))
i10 		= 		(i10<it1? it1 : i10)
i10 		= 		i10+(i10=i6? 1 : 0)
i10 		= 		(i10>i35?  it1 : i10)
i6 		=	 	i10
skp1: 
i9		tablei   	i10,int(abs(p11))
i10 		= 		i10+1
		if 		i10<i35	  igoto j30
i10 		= 		i11

j30: 
i9 		= 		cpspch(i9)
it1 		= 		i8*i9
		if 		p6>=0  igoto j33
kk7		init	  	it1					; MIN INTERVAL
i22 		= 		p7*i9-it1				; INTRVAL DIF
j33: 
kk8		init	  	i9+p5*it1				; INIT REAL PCH+OFFSET
    
; nfsig zvfmult

		if 		p27=0  igoto nt1
i7  		tablei	i23,p27
i23 		= 		i23+1
i23 		= 		(i23<int(frac(abs(p25))*100+.5)?  i23 : i24)

; rthm zvfmult

nt1:	 
		if 		p22=0	 igoto nt2
; i16 MUST BE INIT TO p14 BEFORE HERE
skp2: 
it3	 	tablei   	i12,p22
i12 		= 		i12+1
		if 		i12<int(frac(p20)*100+.5)	  igoto to2
i12 		= 		i13
to2:	 
		if 		i14>=int(p14)  igoto j35
; LOOP FOR RTHM VALUES
i15 		= 		i15+it3
i14 		= 		i14+1
		if 		i14<int(p14)  igoto skp2
; EXIT FROM LOOP AND SET LOC POINTER FOR FIRST ATTACK
i12 		= 		int(p20)-1
		igoto 	skp2
j35: 
i16 		= 		p3*it3/i15			; DUR VALUE SENT TO envlpx, timout, linseg

nt2:	 
		if 		p24=0	 igoto nt3  ;zvamph
i18 		= 		i18+1
		if 		i18<abs(p23) igoto j40
i18 		= 		int(p24)
j40: 
i18 		= 		(p23<0? i18 : i(kk2)*i17)
i19  	tablei	   i18,frac(p24)*100+.5
i19 		= 		i19*p4	;final amp

; ENVLOP
nt3: 
k2		linseg  	0,p13,.25,i16-p13,1		; ENV FOLLOWER CONTROL
a5		envlpx  	i19,p13,i16,frac(p14)*10,p15,i36,1/p16  ; ENV TABLE
		timout  	0,i16,j50

		reinit	rinit
		rireturn

j50:									; STEREO CONTROL

kk5		init	   	p17					; LEFT PROP
kk6		init	   	1-p17		 		; RIGHT PROP
	  	if 		p19=0   goto  j60
it1		=   		(p17=1?  1 : int(p17)*.1)
i37		=   		frac(p17)	  			; MIN
i38		=   		it1-i37	  			; DIF
k4		oscili   	i38,p18/p3,frac(p19)*100+.5,int(p19) ; WRONG PHASE
kk5		=	   	i37+k4
kk6		=   		1-kk5
; AT END OF INSTR, WRITE OUTS sig*kk5,sig*kk6

j60:	  
		if 		p9=0   goto j70
i1   	=    	int(frac(p9)*100+.5)	; NF
i2   	=    	ftlen(i1)
k5   	phasor   	p8/p3,int(p9)/i2
k5   	=    	(p8=0?  k2 : k5)
k5   	tablei   	k5*i2,i1
kk7  	=    	i8+i22*k5
kk8  	=    	i9+p5*kk7

j70: 
a1		oscili   	a5,kk8,i7,0
a2		oscili   	a5,kk8+kk7,i7,.3/i21
a3		oscili   	a5,kk8+kk7+kk7,i7,.6/i21
a4		=		a1+a2+a3
		if 		i21<5	goto j80
a1		oscili   	a5,kk8+3*kk7,i7,.9/i21
a2		oscili  	a5,kk8+4*kk7,i7,1.2/i21
a4		=		a4+a1+a2
		if 		i21<7	goto j80
a1		oscili   	a5,kk8+5*kk7,i7,1.5/i21
a2		oscili   	a5,kk8+6*kk7,i7,1.8/i21
a4		=		a4+a1+a2

j80: 
ga16 	= 		ga16+a4
		outs  	a4*kk5,a4*kk6
		endin

		instr	13		; i13 CHORUS DELAY LINE


; GLOBAL VARIABLE INITS

ga1  	init	  	0
ga3  	init	  	0
ga5  	init	  	0
ga6  	init	  	0
ga8  	init	  	0
ga11	 	init	 	0
ga13 	init	  	0
ga15 	init	  	0
ga16 	init	  	0
; SIGNAL INPUT
a3	   	=	 	ga1+ga3+ga5+ga6+ga8+ga11+ga15+ga16
	  	if 		p16!=0 goto j00
ga1   	=		0			    ; RESET GLOBAL TO 0.
ga3   	=		0			    ; RESET GLOBAL TO 0.
ga5   	=		0			    ; RESET GLOBAL TO 0.
ga6   	=		0			    ; RESET GLOBAL TO 0.
ga8   	=		0			    ; RESET GLOBAL TO 0.
ga11  	=		0			    ; RESET GLOBAL TO 0.
ga15  	=		0			    ; RESET GLOBAL TO 0.
ga16  	=		0			    ; RESET GLOBAL TO 0.
					   

j00:	  
al1  	init	  	0

i1		=		(p7>0?  p7 : abs(p7)/((p6-p5)*2))	   ; CPS OR MSEC/SEC
; INIT MSECS

p5		=		p5*.001
p6	   	=		p6*.001


k1	   	oscili	p6-p5,i1,int(frac(p8)*100+.5),int(p8)
k1	   	=		p5+k1
; for feedback
kk3   	init	 	(p9=0?  .001	:  p9)	; min rvrb
	  	if 		p12=0 goto j10
kk3	  	oscili  	p10-p9,p11,int(frac(p12)*100+.5),int(p12)
kk3	  	=	   	 p9+kk3				; variable rvt
j10:	  
p20   	=	  	(p20=0? 1 : -1)		; p20=pos rvtfac if 0, NEG IF ne 0
k2	   	=	  	p20*exp(-6.9075*k1/kk3)	; rvt fac = e**lpt/rvt
al2   	init		1			   		; p21=RATE/DUR FOR OSCIL al2
	 	if 		p22=0 goto j20		   	; p22=nf FOR al2
al2   	oscili	1,p21/p3,p22,0	 		; OSCIL TRA +&-rvtfac
j20:	  	a2	   	=		 al2*k2*al1	; FEEDBACK

; 		pipdef	(p6>p5? p6 : p5)		; DISCONTINUED:
; 		pipadv	a3*p4+a2,k1		 	; CODE NO LONGER
; 		a1	   	piprd			  	; SUPPORTED

a1   	delayr 	(p6>p5? p6 : p5)	 	; SUBSTITUTED:
adel 	upsamp 	k1		   			; BUT NOT YET DOING
a1   	deltapi	adel					; THE SAME
		delayw 	a3*p4+a2

al1   	linen	a1,p13,p3,p14
a1	   	=		al1
	  	if p24=0  goto j30
a1	   	oscili	a1,p23/p3,int(frac(p24)*100+.5),int(p24)  ; zvamp

j30:									; STEREO CONTROL

kk5		init	   	p17		 			; LEFT PROP
kk6		init	   	1-p17				; RIGHT PROP
		if 		p19=0   goto  j60
it1		=   		(p17=1?  1 : int(p17)*.1)
i31		=   		frac(p17)				; MIN
i32		=   		it1-i31	  			; DIF
k4		oscili   	i32,p18/p3,frac(p19)*100+.5,int(p19)	 ; WRONG PHASE
kk5		=	   	i31+k4
kk6		=   		1-kk5
j60:	   
		outs		a1*kk5,a1*kk6
		endin
</CsInstruments>
<CsScore>
; Jim Dashow: In Winter Shine  CH 1-3   SECTION 1   FILE = ws1.13f
;          compile i16 + i15 + i13
; this score currently has i13 (reverb) disabled (see below)

f1 0  65536   10   1
f2 0  65536   10   1   -.5    -.25   .1
f3 0  65536   10   1   .05    -.5   .05    .5    .05   -.3   .05   1
f4 0  128    7   0   64       1    64     0
f5 0  65536   10   1   .05    -.6
f6 0  65536   10   1   -.6     .15
f7 0  17    5    1   16     50
f8 0  17    5    1   16     16
f9  0   64    5   .0001   32    .16    5     1    27    1
f10 0   64    5   1    16    1000    24   1    24    1
f11 50  32    5     20    32      1
f9  15  128   5    .001    50    .16   5    1    20   .8    7   .001   7   1
20   .8   7    .001    7   1    5    1
f9 31   128   7    0   40   .1   24   1    40    .85   24   0
f3 31   65536    10    1    .15   -.6   .2   -.5   .3    -.4   .3    .3
f9 39.5    64    7   1    30    1    2   0   30   0    2    1
f12  46   64     7   0     12     .05    20   1    12   .9    20   0
f14  0   64   -2   7.05   8.06   9.07   10.08   8.03   9.02    10.04  11.01
7.10    8.11   10.00   10.09   4   6   9   5   1   1   3   2   7  2   1   2   2
9   4   7   3   2   2  4   2   8   3   7   6   5   2   1   1
c
f-1 50
f-5 50
f-9 50
c
i15   .11   2.39  16000 0     .33   0     .10   8.06  0     0     2.3807
 .01  1.219 7.01  50    1     0     0     0 0     0     0     0
0     0     0     0
i15   .22   2.28  . .     .1    .     . 10.08 .     .     1.5808
 .    1.208 .     .     0
c
i15   36.11 1.89  .     .     .25   .     .     9.07  .     .     6.8085
 .    1.169 .     . 1
c
i15   36.22 1.78  .     .     .5    .     .     7.05  .     .     2.7083
 .    1.158 .     . 0

i15   6.0   6     12000 .     .15   .     .     1.08  .7038 14    6.5808
 .    36.005 7.005 70   1     3.3   .04   13.41 .     14    1     .08
c
i15   .     .     . .     .     .     . .     .3078 .     2.5667
 .    31.005 .    . .     .     64.04 31.41 13
c
i15   12    4     .     .     .     .     .     5.08  .     .     .
 .    21.005 .    . .     .     .     . .     .     0     0
c
i15   .     .     . .     .     .     . .     .7038 .     6.5808
 .    24.005 .    .     .     .     .04   13.41
c
i15   19    6     .     .     .     .     .     5.12  .     .     .
 .    33.005 .    .     .     4.3   .     19.41 .     .     1     .08
c
i15   .     .     . .     .     .     . .     .3078 .     2.5667
 .   38.005 .     . .     .     64.04 35.41

i15   25    4     . .     .     .     . 9.12  .     .     .
 .    22.005 .    . .     .     .     . .     .     0     0
c
i15   .     .     . .     .     .     . .     .7038 .     6.5808
 .    25.005 .    . .     .     .04   19.41

i15   50    .     14000 .     .2    .     .     1.12  .8508 .     .
 .    41.005 .    . 8.2   3.3   .     0 0     0     1     .11
c
i15   .     .     .     .     .     .     .     .     .0855 .     .
 .    33.005 .    . .     .     64.04
c
i16   .44   13.56 5000  0     .04   .75   1     .09   8.06  0     7.02
 3.5  1.007 8     70    1     0     0     0 0     0     0     0
 0    0     0     0
i16   .     .     .     .     .     .     .     .     10.08 .     5.06
 .    .     .     .     0
c
i16   15    12    .     .     .     .8    .     .     10.04 .     7.02
c
i16   .     .     . .     .     .     . .     9.02  .     7.03
 .    .     .     .     1
c
i16   27    4     . .     .     .     .6    50.09 7.10  .     .
 .03  .     7     20
c
i16   27.12 .     .     .     .     .     .     .     10.00 .     .
 .    .     .     . 0
c
i16   31.12 5.5   .     .     .     .     3     .09   10.09 .     7.02
c
i16   31.0  .     .     .     .     .     .     .     8.11  .     7.03
 .    .     .     .     1
c
i16   36.5  .     3000  .     -1.00 1.0005 22   .02   9.06  .     5.02
c
i16   36.62 .     . .     .     .     28    255.06 7.05 .     5.03
 .    .     .     . 0
c
i16   38.5  1     .     .     -.07  1.00  1     .07   9.02  .     5.02
c
i16   .     .     .     .     .     .     .     .     8.03  .     .
 .    .     .     .     1
c
i16   39.5  6.75  . .     .     .     8 .09   .     .     5.03
c
i16   .     6.5   .     .     .     .     6.5   .     9.02  .     .
 .    .     .     . 0
c
i16   42.12 4.65  .     .     .     .     .     .     10.09 .     5.02
c
i16   42    4.88  .     .     .     .     8     .     10.00 .     5.03
 .    .     .     .     1
c
i16   46.88 7.12  5000  .     .04   .8    6.5   .12   .     .     7.03
 .    1.4   .     16    .75
c
i16   46.77 7.23  . .     .     .     7.8   .     10.09 .     7.02
 .    .     .     .     .25
c
i16   46    8     . .     .     .     5.5   .     9.02  .     7.03
 .    .     .     . 0
c
i16   46.25 7.75  . .     .     .     6 .     8.03  .     .
 .    .     .     . 1
c
i13   0     54.1  .63   3     15    -6    .04   .005  .05   29    .04
 .02  .02   0     0 .5    0     0     0 58    1     0     0
c
s
f0 1
c end section 1 Ch# 1-3
e
</CsScore>
</CsoundSynthesizer>
