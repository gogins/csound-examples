<CsoundSynthesizer>
<CsOptions>
-RWZdo TheHeartbeat.wav
</CsOptions>
<CsInstruments>
;JULIE FRIEDMAN MS107CSOUND BERKLEE COLLEGE OF MUSIC
 

;THE HEARTBEAT
sr = 44100
ksmps = 1
nchnls = 2

instr 1			;CRACKLE
;p4=amp
;p5=freq
;p6=attack time
;p7=release time
kpan oscil 1,(p3*5),1
k1 linen p4, p6, p3, p7
a1 oscili k1, p5, 11
a2 fof	a1,p5+a1, a1*(p4/50), k1, 200, .003, .017, .005, 20, 1,2, p5
arev reverb2	a2, 5, 1
outs ((arev+a2)*.2)*kpan,((arev+a2)*.2)*(1-kpan)
endin
 
instr 2			;HEARTBEAT
idur = p3
iamp = p4/2
ifq  = 4
if1  = 12
if2  = 13
a2  oscili  iamp, 1/idur, 72
a2  oscili  a2, ifq, if2   
a1  oscili  iamp, 1/idur, 71
a1  oscili  a1, ifq, if1          
outs (a1+a2) * 4.5, (a1+a2) * 4.5
endin

instr 3			;SUPER CHORUSING
iamp=ampdb(p4)
irise=p5 
idur=p3
idec=p6
inote=cpspch(p7)
k1  linen     iamp, irise, idur, idec
k2 	line 10000, idur, 0
k3 	oscili  1, 	2,	1
k4 	oscili  .5, 2, 1
a1 	oscili  k1, (inote-1)+k3, 2
a2 	oscili  k1, (inote+1)+k4, 9
a3 	oscili  k1, (inote-.5), 9
a4 	oscili  k1, (inote+.5), 2
a5 	oscili  k1, (inote-2)+k4, 2
a6 	oscili  k1, (inote+2)+k3, 9
a7 	oscili  k1, (inote-1.5)+k3, 9
a8 	oscili  k1, (inote+1.5)+k3, 2
a9 		oscili  k1, (inote-.25), 2
a10 	oscili  k1, (inote+.25), 9
a11 	oscili  k1, (inote-.8)+k4, 9
a12 	oscili  k1, (inote+.8)+k4, 2
ar1 areson a1,k2, 10, 1
ar2 areson a2,(k2*k3), 20, 1
ar3 areson a3,k2, 30, 1
ar4 areson a4,k2, 40, 1
ar5 areson a5,k2, 50, 1
ar6 areson a6,k2, 60, 1
ar7 areson a7,k2, 70, 1
ar8 areson a8,k2, 80, 1
ar9  areson a9,k2, 50, 1
ar10 areson a10,k2, 60, 1
ar11 areson a11,k2, 70, 1
ar12 areson a12,k2, 80, 1
asig1=(ar1+ar4+ar6+ar8+ar9)/5.5
asig2=(ar2+ar3+ar5+ar7+ar10)/5.5
asig3=(ar11+ar12)/2
outs  (asig1+asig3)/2, (asig2+asig3)/2
endin 

instr 4			;PANNING PLUCK
idur=p3
iplk=p7
iam=ampdb(p4)
inote=cpspch(p5)
kpick=p6
k1   linen    ( iam/2), (idur*.2), idur,( idur*.8)
a2 oscili k1, inote+2, 1
ar1    repluck   iplk, iam, inote+1, kpick, .5, a2
a4 oscili k1, inote-2, 1
ar3    repluck   iplk, iam, inote-1, kpick, .5, a4
asig1=(ar1+ar3)/2
arev	reverb2 asig1, 1.5, 1
afin=(asig1+(arev*.6))/1.6
outs	afin*p8, afin*(1-p8)
endin 
</CsInstruments>
<CsScore>
;JULIE FRIEDMAN MS107CSOUND BERKLEE COLLEGE OF MUSIC
;THE HEARTBEAT
f1 0 65536 10 1 								; SINE WAVE

f2 0 65536 10 1 .5 .3 .25 .2 .167 .14 .111 	; SAWTOOTH

f3 0 65536 10 1 0 .3 0 .2 0 .14 0 .111 		; SQUARE

f4 0 65536 10 1 1 1 1 .7 .5 .3 .1			; PULSE

f9  0   65536  10 .28 1 .74 .66 .78 .48 .05 .33 .12 .08 .01 .54 .19 .08 .05 .16 .01 .11 .3 .02 .2

f19 0 65536  19 .5 .5 270 .5

f11  0   512   9  1  1  0f12  0   512   9  10 1 0  16 1.5 0  22 2.  0  23 1.5 0

f13  0   512   9  25 1 0  29  .5 0  32  .2 0

f14  0   512   9  16 1 0  20 1.  0  22 1   0  34 2   0  38 1 0   47 1 0

f15  0   512   9  50 2 0  53 1   0  65 1   0  70 1   0  77 1 0  100 1 0

f71  0   513   5  4096 512 1 ; equals '1 512 .0024' 

f72  0   513   5   128 512 1 ; equals '1 512 .0078'
 

:PANNING PLUCK

;inst 	start idur 	xam 	inote 	kpick iplk		pan

i4      8     .5    0  		8      .8     .3		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	<		.		.		.		.2

i4		+		.	<		.		.		.		.8

i4		+		.	75		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

i4		+		.	.		.		.		.		.8

i4		+		.	.		.		.		.		.2

		
 
 

;SUPER CHORUSING

; inst	start	idur	iamp	irise	idec	inote

i3		5		15		80		10		5		7

i3		.		.		.		.		.		8

i3		.		.		.		.		.		7.07

i3		.		.		.		.		.		6	

i3		18		17		80		8		9		6	

i3		.		.		.		.		.		7

i3		.		.		.		.		.		7.07

i3		.		.		.		.		.		8.02

i3		.		.		.		.		.		8.03

i3		.		.		.		.		.		5

i3		34		21		75		8		8		6

i3		40		15		75		7		7		6.07

i3		48		7		75		3.5		3.5		7.05

i3		55		10		75		5		8		7

i3		.		.		.		.		.		8

i3		.		.		.		.		.		7.07

i3		.		.		.		.		.		6	
 
 

;HEARTBEAT	

; 		start   idur    iamp   	

i2		0    	.2    	6000   	

i2		.25   	.4		8000

i2		2		.2		6000

i2   	2.25   	.4		8000

i2		4    	.2    	6000   	

i2	    4.25   	.4		8000

i2		6		.2		6000

i2   	6.25   	.4		8000

i2		8    	.2    	6000   	

i2		8.25   	.4		8000

i2		10		.2		6000

i2   	10.25   .4		8000

i2		12    	.2    	6000   	

i2		12.25   .4		8000

i2		14		.2		6000

i2   	14.25   .4		8000

i2		16    	.2    	6000   	

i2		16.25   .4		8000

i2		18		.2		6000

i2   	18.25   .4		8000

i2		20		.2		6000

i2   	20.25   .4		8000

i2		22		.2		6000

i2   	22.25   .4		8000

i2		24		.2		6000

i2   	24.25   .4		8000

i2		26		.2		6000

i2   	26.25   .4		8000

i2		28		.2		6000

i2   	28.25   .4		8000

i2		30		.2		6000

i2   	30.25   .4		8000

i2		32		.2		6000

i2   	32.25   .4		8000

i2		34		.2		6000

i2   	34.25   .4		8000

i2		36		.2		6000

i2   	36.25   .4		8000

i2		38		.2		6000

i2   	38.25   .4		8000

i2		40		.2		6000

i2   	40.25   .4		8000

i2		42		.2		6000

i2   	42.25   .4		8000

i2		44		.2		6000

i2   	44.25   .4		8000

i2		46		.2		6000

i2   	46.25   .4		8000

i2		48		.2		6000

i2   	48.25   .4		8000

i2		50		.2		6000

i2   	50.25   .4		8000

i2		52		.2		6000

i2   	52.25   .4		8000

i2		54		.2		6000

i2   	54.25   .4		8000

i2		56		.2		6000

i2   	56.25   .4		8000

i2		58		.2		6000

i2   	58.25   .4		8000

i2		60		.2		6000

i2   	60.25   .4		8000

i2		62		.2		6000

i2   	62.25   .4		8000

i2		64		.2		6000

i2   	64.25   .4		8000
 
 
 
 

;CRACKLE

;		START	DUR		AMP		FREQ	ATTACK TIME		RELEASE TIME

i1		40		8		5000	100		12				20

i1		53		5		5000	 50		12				20
 
 
 

e

</CsScore>

</CsoundSynthesizer>