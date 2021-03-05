<CsoundSynthesizer>
<CsOptions>
-RWZdo TextileFunk.wav
</CsOptions>
<CsInstruments>
;Text File Funk
;By Matt Moldover  AKA  Dead Ace
;(617)236-0321   deadace@deadace.com     http://www.deadace.com
;INTERESTING THINGS: a lot of the instruments use a little randomness on amplitude or cutoff
;frequency to add realism.  Several of the beats use instrument 103 which randomly chooses to
;play a kick drum, snare drum or nothing.  I use the index counter ($dex) on many parameter fields
;to create dynamic effects lasting 8 bars even though the repeated sections are usually only 2 bars.
sr = 44100
ksmps = 1
garvb	init	0
gacmb	init	0

;Gverb
	instr 900
idur		=	p3
irvbtim	=	p4
ihiatn	=	p5
arvb	nreverb	garvb, irvbtim, ihiatn
	out arvb
garvb	=	0
	endin

;Gdelay
		instr	901
idur		=		p3
itime 	= 		p4
iloop 	= 		p5
kenv	linen	1, .01, idur, .01
acomb 	comb	gacmb, itime, iloop, 0
		out		acomb*kenv
gacmb	=		0
	endin

;HiHat with variable amp hit-length, freq / rand added to amp and freq
	instr 100
idur = p3
iamp = p4
icutoff = p5
ilength = p6
icutrnd  trirand (icutoff/2.4)
iamprnd  unirand (iamp*.30)
kcutenv linseg 0, ilength*.1, icutoff, ilength*.5, 0
kampenv expseg .001, ilength*.05, 1, ilength*.5, .002
anoise  rand iamp+iamprnd
afilt butterlp anoise, kcutenv+icutrnd
asig = (afilt*kampenv)*.8
	out asig
garvb	=	garvb+(asig*.11)
;gacmb	=	gacmb+(asig*.4)
endin

; Kick drum with variable amp and freq / rand added to amp and freq
	instr 101
idur = p3
iamp = p4
ifreq = p5
iamprnd unirand (iamp*.2)
ifreqrnd1 unirand (ifreq*.2)
ifreqrnd2 unirand (ifreq*.3)
ifreqrnd3 unirand (ifreq*.4)
asin1 oscili iamp, (ifreq)+ifreqrnd1, 1
asin2 oscili iamp, (ifreq*1.1)+ifreqrnd2, 1
asin3 oscili iamp, (ifreq*.9)+ifreqrnd3, 1
asinsum = (asin1+asin2+asin3)/2
anoise rand 10000
anoisefilt butterlp anoise, ifreq*1.2
aampenv expseg .001, .03, 1, .4, .001
asig = (anoisefilt*aampenv*(iamp/600))+(asinsum*aampenv)
	out asig
 garvb	=	garvb+(asig*.03)
 ;gacmb	=	gacmb+(asig*.4)
	endin

; Snare drum with variable amp and freq / rand added to amp and bandW
	instr 102
idur = p3
iamp = p4
ifreq = p5
irndbnd1 unirand ifreq*.5
irndbnd2 unirand ifreq*.3
kfiltenv linseg (ifreq*1.5)+irndbnd1, .7, ifreq+irndbnd2
irndamp unirand iamp*.3
anoise rand (iamp+irndamp)/11
afilt  reson anoise, ifreq+irndbnd1*.7, kfiltenv+(ifreq*.5)
afilt2 butlp anoise, (ifreq*3)-(irndbnd2*.5)
afilt3 buthp afilt2, ifreq
aampenv expseg .001, .01, 1, .07, .4, .3, .001
asig = ((afilt+afilt3)*aampenv)
	out asig
garvb	=	garvb+(asig*.12)
 ;gacmb	=	gacmb+(asig*.4)
	endin

;random silence/kick/snare
	instr 103
;iblah unirand 1234
;seed iblah
idur = p3
iamp = p4
ifreq = p5
iseedread = p6
clockon 1
iclocker readclock 1
iseedme = abs(iclocker)
seed iseedme
ipicker unirand 3
iintpicker = int(ipicker)
if (iintpicker==0) goto  silence
if (iintpicker==1) goto  kick
if (iintpicker==2) goto  snare
silence:
		asoscil oscil 0, 20, 1
		asig = asoscil
goto		contin

kick:
		ifreq = 60
		iamprnd unirand (iamp*.2)
		ifreqrnd1 unirand (ifreq*.2)
		ifreqrnd2 unirand (ifreq*.3)
		ifreqrnd3 unirand (ifreq*.4)
		asin1 oscili iamp, (ifreq)+ifreqrnd1, 1
		asin2 oscili iamp, (ifreq*1.1)+ifreqrnd2, 1
		asin3 oscili iamp, (ifreq*.9)+ifreqrnd3, 1
		asinsum = (asin1+asin2+asin3)/2
		anoise rand 10000
		anoisefilt butterlp anoise, ifreq*1.2
		aampenv expseg .001, .03, 1, .2, .001
		asig = (anoisefilt*aampenv*(iamp/400))+(asinsum*aampenv)

 		garvb	=	garvb+(asig*.02)
 		;gacmb	=	gacmb+(asig*.4)

goto		contin

snare:
		ifreq = 900
		irndbnd1 unirand ifreq*.5
		irndbnd2 unirand ifreq*.3
		kfiltenv linseg (ifreq*1.5)+irndbnd1, .7, ifreq+irndbnd2
		irndamp unirand iamp*.3
		anoise rand (iamp+irndamp)/11
		afilt  reson anoise, ifreq+irndbnd1*.7, kfiltenv+(ifreq*.5)
		afilt2 butlp anoise, (ifreq*3)-(irndbnd2*.5)
		afilt3 buthp afilt2, ifreq
		aampenv expseg .001, .02, 1, .07, .4, .2, .001
		asig = ((afilt+afilt3)*aampenv)
		garvb	=	garvb+(asig*.1)
 		;gacmb	=	gacmb+(asig*.4)
goto		contin
contin:
		out asig
endin

;Sqareish tone with variable pitch slide, filter CO slide, and pseudo-Q
	instr 200
idur = p3
iamp = p4
ifreq1 = cpspch(p5)
ifreq2 = cpspch(p6)
icutoff1 = p7
icutoff2 = p8
iresmix = p9
kcutoff linseg icutoff1, idur, icutoff2
kfreq linseg ifreq1, idur, ifreq2
asqr1 oscili iamp, kfreq, 2
asqr2 oscili iamp, kfreq*1.01, 2
asqr3 oscili iamp, kfreq*.99, 2
asqr4 oscili iamp, kfreq*1.02, 2
asqr5 oscili iamp, kfreq*.98, 2
asqr6 oscili iamp, kfreq, 2
asqr7 oscili iamp, kfreq*1.05, 2
asqr8 oscili iamp, kfreq*.95, 2
asin1 oscili iamp, kfreq+1, 1
asin2 oscili iamp, kfreq, 1
asin3 oscili iamp, kfreq-1, 1
atone1 = ((asqr6+asqr7+asqr8)/3)+((asin1+asin2+asin3)/6)*.66
atone2 = (asqr1+asqr2+asqr3+asqr4+asqr5)/5
aampenv  linseg 0, idur*.03, 1, idur*.07, .9, idur*.85, .7, idur*.05, 0
amix = ((atone1+atone2)/2)*aampenv
afilt1 butlp amix, kcutoff
afilt3 butlp afilt1, kcutoff
afilt2 butbp amix, kcutoff, kcutoff/(7)
adcfix dcblock (afilt3+((afilt2*12)*iresmix))
asig = adcfix
	out asig
	endin

;pluck with FM
	instr 201
idur = p3
iamp = p4
ifreq = cpspch(p5)
ifmdep = p6
ifmratio = p7
ifmfreq = ifmratio*ifreq
afmsin oscili ifmdep, ifmfreq, 1
astring pluck iamp, ifreq, ifreq, 0, 1
kampenv linseg .001, idur*.05, 1, idur*.95, .001
ifiltrnd unirand .5
kfiltenv linseg 1, idur, .2+ifiltrnd
afilt butlp astring, 18000*kfiltenv
;adcfix dcblock (afilt*kampenv)
;asig = adcfix
asig = (afilt*kampenv)
	out asig
garvb	=	garvb+(asig*.11)
;gacmb	=	gacmb+(asig*.4)
	endin

;dynamic FM instrument
            instr 69
kindexenv  		expseg 1, p3/3, p9, p3/3, p9/2, p3/3, 1
kampenv    		linen  p4, p3/12, p3, p3/3
kexpramp   		expon  1, p3, p8
ksinerate  		expon  p10, p3, 1
ksinemod   		oscili  p4, (1/p3)*ksinerate, 1
koctavespike      expseg 1, p3/3, 1.1, p3/6, 10, p3/6, 1
afmout  foscil  (kampenv*ksinemod)/5000, p5/koctavespike, p7, kexpramp, kindexenv, p6
;adcfix dcblock afmout
;asig = adcfix
asig = afmout
		out asig
garvb	=	garvb+(asig*.15)
;gacmb	=	gacmb+(asig*.4)
		endin

;overcomplicated granular with LPF
    instr 420
idur = p3
iamp = ampdb(p6)
ifrq = cpspch(p8)
iatk = p4
irel = p5
ifun = p14
iden1 = p10
iden2 = p11
iampoff = ampdb(p7)
ifrqoff = cpspch(p9)
igdur = p12
igduroff = p13
iranddepth = p15
ilfodepth = p16
ilfoitts = p17
ilfodurmod = p18
ilfofiltmod = p19
imix = p20       ;0=dry
iampatt = p21
kampenv expseg .001, iatk, 1, idur-iatk-irel, .9, irel, .001
kgfrqdev oscili ifrqoff*ifrqoff, 1/idur, 3
kdenexp expseg iden1, idur/8, iden2/2, idur/4, iden2/1.5, idur/16, iden1*2, idur/8, iden2, idur/16, iden2/3, idur/8, iden1*1.4, idur/4, iden1
krandlin linseg 0, idur, iranddepth
klfo oscil ilfodepth, ilfoitts/idur, 1
kfiltenv linseg 0, iatk/2, 1, idur/1.33, .7, idur/3, 0
asig1 grain 3000, ifrq*krandlin, kdenexp, iampoff, ifrqoff*kgfrqdev, igdur+(klfo*ilfodurmod), ifun, 3, igduroff
alpf  butterlp  asig1/2, (kfiltenv*15000+(klfo*kfiltenv)/10)
asig = ((((asig1)+(alpf*imix))*kampenv)/2)*iampatt
		out asig
	garvb	=	garvb+(asig*.1)
	;gacmb	=	gacmb+(asig*.4)
		endin

;Starts a clock based on the CPUs clock
	instr 300
clockon 1
	endin
</CsInstruments>

<CsScore>
;Text File Funk
;By Matt Moldover  AKA  Dead Ace
;(617)236-0321   deadace@deadace.com     http://www.deadace.com
;INTERESTING THINGS: a lot of the instruments use a little randomness on amplitude or cutoff
;frequency to add realism.  Several of the beats use instrument 103 which randomly chooses to
;play a kick drum, snare drum or nothing.  I use the index counter ($dex) on many parameter fields
;to create dynamic effects lasting 8 bars even though the repeated sections are usually only 2 bars.

;f tables -----------------------------------------------------------------
f 1  0 65536 10	1    ;sine
f 2  0 2048 7	0	34	1	990	1	34	0	990	0	;square
f 3  0 65536 20   1  1  							  ;Hamming

;instrument exaples -------------------------------------------------------
;Gverb	strt	dur	time	HFRoll(0-1)
;i 900	0	10	1	.2
;Gcomb	strt	dur	time	LoopT(beats)
;i 901		0	6	7	.5
;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
;i 	100	0 	.25 	10000 10000       .1
;Kick		strt	dur	amp	freq(60)
;i 101 	0	1	10000	60
;Snare	strt	dur	amp	freq(900)
;i 102	.5	1	10000	900
;rndKS	strt	dur	amp	freq(N/A defaults to 60 and 900)
;i 103 	0	.5	10000	600
;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
;i 200	0	1	10000	5.01  5.01	1000	1	.001
;String	strt	dur	amp	pch	fmamp	fmratio
;i 201	0	1	10000	5.01	10	1
;FM		start	dur	amp	frqbas	funct	fc	fmodend	indxmax	sinfreqstrt
;i69		0	8	10000	40		1	2	10		3		.1
;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix
;i 420        	0	   8		.5 	.3	80  	  10		8.04  3.01		10    1000    .005  .01   	  1         10          0        0        0            0          0 1
;gverb	strt	dur	time	HFRoll(0-1)
;i 900		0	14	1	.1
;Gcomb	strt	dur	time	LoopT(beats)
;i 901	0	6	7	.5

i 300 0 .001
s


;INTRO=================================================================
;a 0 0 14
;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	14	1	.1
;FM		start	dur	amp	frqbas	funct	fc	fmodend	indxmax	sinfreqstrt
i69		0	14	5000	40		1	2	2		3		.1
i69		2	12	<	<		.	.	(		<		.
i69		4	10	.	.		.	.	.		.		.
i69		6	8	.	.		.	.	.		.		.
i69		8	6	3000	20		.	.	7		10		.
;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix
i 420        	9	   3		2 	.5	40  	  10		10.04  2.3      	4     600    .003  .0009          1         2          2         60          .0002          30       .5 1
i 420        	11	   3		1 	1	20  	  10		10.04  2.3      	4     600    .003  .0009          1         2          2         60          .0002          30       .5 1
i 420        	10	   4		.2 	.1	60  	  10		2.04   7.01		10    100    .005  .01   	  1         10          2        .        .001            3          .5 1
;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i100		2	.25	100	300		1
i100		+	.	(	<		<
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	.	.		.
i100		.	.	5000	4000		2
s


;4 BAR HH GRAIN GROOVE===================================================
r4 dex
;a 0 0 16
;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	4	1	.1
;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix
i 420        	0	   4		.2 	.3	[80/[$dex*.2]]  	  10		2.04  [4.01*[[5-$dex]*.06]]		10    100    .005  .01   	  1         10          2        $dex        .001            3          .5 1
i 420        	0	   .5		.01 	.01	30  	  10		5.04  1.01		100    1000    .05  .01   	  1         10          2        $dex        .001            3          [$dex/6]  1
;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	0	.25	5000	[3000+[$dex*1000]]	[2/[$dex*2]]
i 	100	+	.	3000	<		<
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	3.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	3.875	.125	.	[4000+$dex*1000]		[2/[[$dex+1]*2]]
;pshhhh on 1
;String	strt	dur	amp	pch	fmamp	fmratio
i 201	0	4	[[[4-$dex]^8]/18]	1.01	500	1000
;FM   start  dur  amp    frqbase    funct    fc   fmodend  indxmax  sinfreqstrt
i69 	     3  1   [$dex^6]  20     	1		1     4   	30   	100
;bendup
;Bass		strt	dur	amp		pch1	pch2	coff1	coff2	resmix(.001-1)
i 200		1.5	2.5	[[[$dex-1]^9]/9] 3.01  10.01	1000	4000	.001



;4 BAR GROOVE KICK ADDED=============================================
r4 dex2
;a 0 0 16
;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	4	1	.1
;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	0	.25	3500	8000		.2
i 	100	+	.	2500	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	[10000+[$dex2*1200]]		.
i 	100	.	.	.	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	3.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	3.875	.125	.	7000		.2
;Kick		strt	dur	amp	freq(60)
i 101 	0	.25	[[[$dex2+1]*[$dex2+1]]*70]	[[[6-$dex2]^2]*70]
i 101       .875	.	<			<
i 101		1.25	.	.			.
i 101		2	.	.			.
i 101		2.75	.	.			.
i 101		2.875	.	.			.
i 101		3.25	.75	[[[$dex2+2]*[$dex2+2]]*80]	[[[5-$dex2]^2]*70]
;FM   start  dur  amp    frqbase    funct    fc   fmodend  indxmax  sinfreqstrt
i69 	     3  1   [$dex2^6]  20     	1		1     4   	45   	100
;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix
i 420        	0	   4		.2 	.3	[50/[$dex2*.3]]  	  10		2.04  [4.01*[[5-$dex2]*.04]]		10    100    .005  .01   	  1         10          2        $dex2        .001            3          .5 .8
i 420        	0	   .5		.01 	.01	20  	  10		5.04  1.01		100    1000    .05  .01   	  1         10          2        4        .001            3          .66 .8
s


;4 BAR SNARE ADDED================================================================
r4 dex
;a 0 0 16
;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	4	1	.1
;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	0	.25	3000	8000		.18
i 	100	+	.	2500	<		<
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.

i 	100	.	.	.	[10000+[$dex*1000]]		.
i 	100	.	.	.	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	3.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	3.875	.125	3000	8000		.2
;Kick		strt	dur	amp	freq(60)
i 101 	0	.25	10000	60
i 101       .875	.	9000	.
i 101		1.25	.	9000	.
i 101		2	.	10000	.
i 101		2.75	.	9000	.
i 101		2.875	.	10000	.
i 101		3.25	.	9000	.
i 101		3.875	.125	[$dex^6]	.
;Snare	strt	dur	amp	freq(900)
i 102		.5	.5	[[$dex*300]+7000]	[400*[[[6-$dex]^2]/3]]
i 102		3.125	.25	[[[$dex-1]^8]*1.02]	400
i 102		+	.25	[[[$dex-1]^8]*1.04]	<
i 102		+	.125	[[[$dex-1]^8]*.98]	.
i 102		+	.125	[[[$dex-1]^8]*1]		.
i 102		+	.125	[[[$dex-1]^8]*1.01]	850
;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
i 200		0	4	3000+[$dex*500]	5.01  4.01	3000	[8000+[$dex*2]]	[1*[[5-$dex]/4]]
;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix ampatt
i 420        	0	   4		.4 	.5	[50/[$dex*.5]]  	  10		2.04  [4.09*[[5-$dex]*.10]]		10    100    .005  .01   	  1         10          2        $dex        .001            3          .5 .5
i 420        	0	   .5		.4 	.01	20  	  10		5.04  1.01		100    1000    .05  .01   	  1         10          2        4        .001            3          .66  .5
;FM   start  dur  amp    frqbase    funct    fc   fmodend  indxmax  sinfreqstrt
i69 	     3  1   [[$dex^6]-2000]  20     	1		1     4   	60   	100
;bendup
;Bass		strt	dur	amp		pch1	pch2	coff1	coff2	resmix(.001-1)
i 200		1.5	2.5	[[[$dex-1]^9]/9] 3.01  10.01	1000	4000	.001
;pshhhh on 1
;String	strt	dur	amp	pch	fmamp	fmratio
i 201	0	3.5	[[[4-$dex]^8]/14]	1.01	2	1000
;i201		0	4	[[[4-$dex]^7]/2]	4.01	2	10
s


;FULL DRUM GROOVE===============================================================
r4 dex
;a 0 0 16

;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	4	1	.1

;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	0	.125	2800	8000		.1
i	100	+	.	2600	<		<
i 	100	.	.	<	.		.
i 	100	.	.	.	.		.
i 	100	.	.25	.	.		.18
i 	100	.	.	.	.		<
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.

i 	100	.	.	.	[10000+[$dex*1000]]		.
i 	100	.	.	.	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	3.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	3.875	.125	3000	8000		.2


;Kick		strt	dur	amp	freq(60)
i 101 	0	.25	10000	60
i 101       .875	.	8000	<
i 101		1.25	.	9000	.
i 101		2	.	12500	63
i 101		2.75	.	9000	<
i 101		2.875	.	11000	.
i 101		3.25	.	10000	.
i 101		3.875	.125	[$dex^6]	59

;Snare	strt	dur	amp	freq(900)
i 102		.5	1	6000	850
i 102		+	.	.	800
i 102		+	.	.	875
i 102		+	.5	.	779


i 102		3.125	.25	[[[$dex-1]^8]*0.72]	300
i 102		+	.25	[[[$dex-1]^8]*0.84]	<
i 102		+	.125	[[[$dex-1]^8]*.88]	.
i 102		+	.125	[[[$dex-1]^8]*1]		.
i 102		+	.125	[[[$dex-1]^8]*1.01]	800

;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
i 200		0	4	1000+[$dex*500]	5.01  4.01	3000	[8000+[$dex*2]]	[1*[[5-$dex]/4]]

;String	strt	dur	amp		pch	fmamp	fmratio
i 201		0	4	[[[4-$dex]^8]/8]	5.01	0	0

;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix ampatt
;i 420        	0	   4		.4 	.5	[50/[$dex*.5]]  	  10		2.04  [4.09*[[5-$dex]*.10]]		10    100    .005  .01   	  1         10          2        $dex        .001            3          .5 .5
i 420        	0	   .5		.4 	.01	20  	  10		5.04  1.01		100    1000    .05  .01   	  1         10          2        4        .001            3          .66  .5

;FM   start	dur	amp	frqbase	funct	fc	fmodend	indxmax	sinfreqstrt
i69	3	1	[[$dex^6]-2000]  	20		1	1	4		60		100

;bendup
;Bass		strt	dur	amp		pch1	pch2	coff1	coff2	resmix(.001-1)
i 200		2	2	[70*[$dex^3]]	[[$dex+4]+.01]  6.01	8000	[$dex*2000]	.001
;[[[$dex-1]^9]/9]
s


;DRUM WITH BASS GROOVE===============================================================
r3 dex
;a 0 0 12

;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	4	1	.1

;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	0	.125	3000	8000		.1
i	100	+	.	2300	<		<
i 	100	.	.	<	.		.
i 	100	.	.	.	.		.
i 	100	.	.25	.	.		.15
i 	100	.	.	.	.		<
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	2500	.		.
i 	100	.	.	<	.		.

i 	100	.	.	.	[10000+[$dex*1000]]		.
i 	100	.	.	.	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	3.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	3.875	.125	2600	8000		.2

;Kick		strt	dur	amp	freq(60)
i 101 	0	.25	12000	60
i 101       .875	.	10000	<
i 101		1.25	.	9000	.
i 101		2	.	15000	63
i 101		2.75	.	8000	<
i 101		2.875	.	11000	.
i 101		3.25	.	10000	.
i 101		3.875	.125	[$dex^6]	59

;Snare	strt	dur	amp	freq(900)
i 102		.5	1	5000	850
i 102		+	.	.	800
i 102		.	.	.	875
i 102		.	.5	.	779

i 102		3.125	.25	[[[$dex-1]^8]*1.02]	300
i 102		+	.25	[[[$dex-1]^8]*1.04]	<
i 102		.	.125	[[[$dex-1]^8]*.98]	.
i 102		.	.125	[[[$dex-1]^8]*1]		.
i 102		.	.125	[[[$dex-1]^8]*1.01]	800

;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
;i 200	0	1	10000	5.01  5.01	1000	1	.001

;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
i 200 	0	.8	11000	6.01	6.01	10000	5000	[.1*[$dex/4]]
i 200       .875	.25	.	6.04	0.04	11000	<	<
i 200		1.25	.75	.	6.06	6.01	13000	500	.
i 200		2	.75	.	6.01	6.01	15000	500	.
i 200		2.75	.125	.	6.06	6.08	8000	1000	[.6*[$dex/4]]
i 200		2.875	.375	.	6.04	6.04	1000	2000	<
i 200		3.25	.625	.	5.11	5.11	<	<	.
i 200		3.875	.125	.	5.11	6.01	800	6000	[.4*[$dex/4]]

;String	strt	dur	amp		pch	fmamp	fmratio
i 201		0	4	[[[4-$dex]^8]/14]	5.01	0	0

;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix ampatt
;i 420        	0	   4		.4 	.5	[50/[$dex*.5]]  	  10		2.04  [4.09*[[5-$dex]*.10]]		10    100    .005  .01   	  1         10          2        $dex        .001            3          .5 .5
i 420        	0	   .5		.4 	.01	20  	  10		5.04  1.01		100    1000    .05  .01   	  1         10          2        4        .001            3          .66  .5
;FM   start	dur	amp	frqbase	funct	fc	fmodend	indxmax	sinfreqstrt
i69	3	1	[[$dex^6]-2000]  	20		1	1	4		60		100
s


;rushes==================================================================
r32 dex
;a 0 0 2
;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	.0625	1	.1
;Snare	strt	dur	amp	freq(900)
i 102		0	.0625	[1000+[$dex*120]]   [500+[[33-$dex]*30]]
;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
i 200 	0	.0625	3000	[5.01+[$dex*.006]]	7.01	2000	[5000+[$dex*200]]	[$dex/30]
s


r16 dex
;a 0 0 1
;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	.0625	1	.1
;Snare	strt	dur	amp	freq(900)
i 102		0	.0625	[8000-[$dex*280]]   [500+[$dex*100]]
;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
i 200 	0	.0625	3000	[7.01+[$dex*.012]]	7.01	5000	[5000+[$dex*300]]	[$dex/25]
s


r16 dex
;a 0 0 1
;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	.0625	1	.1
;Snare	strt	dur	amp	freq(900)
i 102		0	.0625	[3000+[$dex*150]]   [2300-[$dex*100]]
;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
i 200 	0	.0625	3000	[9.01+[$dex*.012]]	7.01	8000	[5000+[$dex*300]]	[$dex/20]
s


;DRUM WITH BASS GROOVE  RANDOM DRUM FILLS===============================================================
r4 dex
;a 0 0 16

;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	4	1	.1

;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	0	.125	2400	7000		.1
i	100	+	.	2300	<		<
i 	100	.	.	<	.		.
i 	100	.	.	.	.		.
i 	100	.	.25	.	.		.15
i 	100	.	.	.	.		<
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	2500	.		.
i 	100	.	.	<	.		.

i 	100	.	.	.	[10000+[$dex*1000]]		.
i 	100	.	.	.	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	3.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	3.875	.125	2600	8000		.2

;Kick		strt	dur	amp	freq(60)
i 101 	0	.25	8000	60
i 101       .875	.	8000	<
i 101		1.25	.	8000	.
i 101		2	.	10000	63
i 101		2.75	.	8000	<
i 101		2.875	.	9000	.

;Snare	strt	dur	amp	freq(900)
i 102		.5	1	3000	850
i 102		+	.	.	800
i 102		.	.	.	875

i 102		3.125	.25	[[[[$dex-1]^8]*1.02]*.7]	350
i 102		+	.25	[[[[$dex-1]^8]*1.04]*.7]	<
i 102		.	.125	[[[[$dex-1]^8]*.98]*.7]	.
i 102		.	.125	[[[[$dex-1]^8]*1]*.7]		.
i 102		.	.125	[[[[$dex-1]^8]*1.01]*.7]	800

;rndKS	strt	dur	amp	freq(N/A defaults to 60 and 900)
i 103 	3	.125	6000	600 $dex
i 103 	+	.	<	.	<
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	6800	.	5

;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
i 200 	0	.8	11000	6.01	6.01	10000	5000	[.1*[$dex/4]]
i 200       .875	.25	.	6.04	0.04	<	<	<
i 200		1.25	.75	.	6.06	6.01	13000	500	.
i 200		2	.75	.	6.01	6.01	15000	500	.
i 200		2.75	.125	.	6.06	6.08	8000	1000	[.6*[$dex/4]]
i 200		2.875	.375	.	6.04	6.04	1000	2000	<
i 200		3.25	.625	.	5.11	5.11	<	<	.
i 200		3.875	.125	.	5.11	6.01	800	6000	[.4*[$dex/4]]

;String	strt	dur	amp		pch	fmamp	fmratio
i 201		0	4	[[[4-$dex]^8]/14]	5.01	0	0

;String	strt	dur	amp	pch	fmamp	fmratio
i 201		0	4	[[[4-$dex]^8]/18]	1.01	50	10000

;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix ampatt
;i 420        	0	   .5		.4 	.01	20  	  10		5.04  1.01		100    1000    .05  .01   	  1         10          2        4        .001            3          .66  .5
;FM   start	dur	amp	frqbase	funct	fc	fmodend	indxmax	sinfreqstrt
i69	3	1	[[$dex^6]-2000]  	20	1	1		4		60		100

i 420        	0	   4		1 	1	30  	  10		10.04  2.3      	4     600    .003  .0009          1         2          2         60          .0002          30       .5  .3
s


;DRUM WITH BASS GROOVE  RANDOM DRUM FILLS===============================================================
r3 dex
;a 0 0 16

;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	4	1	.1

;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	0	.125	2400	8000		.1
i	100	+	.	2300	<		<
i 	100	.	.	<	.		.
i 	100	.	.	.	.		.
i 	100	.	.25	.	.		.18
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	2500	.		.
i 	100	.	.	<	.		.

i 	100	.	.	.	[10000+[$dex*1000]]		.
i 	100	.	.	.	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	3.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	3.875	.125	2600	8000		.2

;Kick		strt	dur	amp	freq(60)
i 101 	0	.25	8000	60
i 101       .875	.	8000	<
i 101		2	.	12000	63
i 101		2.75	.	8000	<
i 101		2.875	.	9000	.
i 101		3.875	.125	[[$dex^6]*.7]	59

;Snare	strt	dur	amp	freq(900)
i 102		.5	1	4300	850
i 102		2.5	.	.	800

i 102		3.125	.25	[[[[$dex-1]^8]*1.02]*.7]	350
i 102		+	.25	[[[[$dex-1]^8]*1.04]*.7]	<
i 102		+	.125	[[[[$dex-1]^8]*.98]*.7]		.
i 102		+	.125	[[[[$dex-1]^8]*1]*.7]		.
i 102		+	.125	[[[[$dex-1]^8]*1.01]*.7]	800

;rndKS	strt	dur	amp	freq(N/A defaults to 60 and 900)
i 103 	1	.125	6000	600 $dex
i 103 	+	.	<	.	<
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	7500	.	5

;rndKS	strt	dur	amp	freq(N/A defaults to 60 and 900)
i 103 	3	.125	6000	600 $dex
i 103 	+	.	<	.	<
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	7500	.	5

;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
;i 200	0	1	10000	5.01  5.01	1000	1	.001

;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
i 200 	2	2	7000	6.01	[6.0+[[[$dex+1]^2]*.01]]	11000	5000	[.1*[$dex/4]]

;String	strt	dur	amp		pch	fmamp	fmratio
i 201		0	2.5	[1000+$dex*200]	3.01		[3*$dex]	[$dex]

;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix ampatt
;i 420        	0	   .5		.4 	.01	20  	  10		5.04  1.01		100    1000    .05  .01   	  1         10          2        4        .001            3          .66  .5
;FM   start	dur	amp	frqbase	funct	fc	fmodend	indxmax	sinfreqstrt
i69	3	1	[[$dex^6]-2000]  	20		1	1	4		60		100

i 420        	0	   4		1 	1	30  	  10		10.04  2.3      	4     600    .003  .0009          1         2          2         60          .0002          30       .5  .3
s


;RANDOM RUSH===============================================================
r64 dex
;a 0 0 1
;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	.0625	1	.1
;rndKS	strt	dur	amp	freq(N/A defaults to 60 and 900)
i 103 	0	.0625	[6000-[$dex*30]] 600 $dex
;String	strt	dur	amp		pch	fmamp	fmratio
i 201		0	.04	[2000-[$dex*10]]	3.01		[$dex/10]	1
s


;INTERLUDE=================================================================
;a 0 0 16

;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	16	1	.1

;FM   start  dur  amp    frqbase    funct    fc   fmodend  indxmax  sinfreqstrt
i69 	     0  16   2000  20     	1		1     8   	500   	100000
i69	0	5	1500	100		1		3	1	200		500
i69	4	.	<	(		.		.	<	.		<
i69	8	.	.	.		.		.	.	.		.
i69	12	4	3000	1000		.		.	7	.		1

;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	0	.25	4000	5000		.2
i 	100	+	.	4000	<		<
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	7000		.
i 	100	.	.	.	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	3.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	3.875	.125	.	6000		.2

;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	4	.25	4000	6000		.2
i 	100	+	.	4000	<		<
i 	100	.	.	<	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	8500		.
i 	100	.	.	.	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	7.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	7.875	.125	6000	8000		.2

;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	0	.25	6000	8000		.2
i 	100	+	.	<	<		<
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	.	10000		.
i 	100	.	.	.	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	11.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	11.875	.125	8000	13000	.2


;Snare	strt	dur	amp	freq(900)
i 102		15.125	.25	10000	7000
i 102		+	.25	<	<
i 102		+	.125	.	.
i 102		+	.125	.	.
i 102		+	.125	11000	1000
s


;ORIGINAL DRUM/BASS GROOVE WITH RANDOM FILLS===============================================================
r4 dex
;a 0 0 16

;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	4	1	.1

;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i	100	0	.125	2000	8000		.1
i	100	+	.	2300	<		<
i 	100	.	.	<	.		.
i 	100	.	.	.	.		.
i 	100	.	.25	.	.		.13
i 	100	.	.	.	.		<
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.	2500	.		.
i 	100	.	.	<	.		.

i 	100	.	.	.	[10000+[$dex*1000]]		.
i 	100	.	.	.	<		.
i 	100	.	.	.	.		.
i 	100	.	.	.	.		.
i 	100	.	.125	.	.		.
i	100	3.125 .25	.	.		.
i 	100	+	.	.	.		.
i 	100	.	.	.	.		.
i 	100	3.875	.125	2600	8000		.2

;Kick		strt	dur	amp	freq(60)
i 101 	0	.25	10000	60
i 101       .875	.	10000	<
i 101		2	.	10000	63
i 101		2.75	.	8000	<
i 101		2.875	.	11000	59

;Snare	strt	dur	amp	freq(900)
i 102		.5	1	4300	850
i 102		2.5	.	.	800

;rndKS	strt	dur	amp	freq(N/A defaults to 60 and 900)
i 103 	1	.125	7000	600 $dex
i 103 	+	.	<	.	<
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	8500	.	5

;rndKS	strt	dur	amp	freq(N/A defaults to 60 and 900)
i 103 	3	.125	7000	600 $dex
i 103 	+	.	<	.	<
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	.	.	.
i 103 	.	.	8500	.	5

;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
;i 200	0	1	10000	5.01  5.01	1000	1	.001


;Bass		strt	dur	amp	pch1	pch2	coff1	coff2	resmix(.001-1)
i 200 	0	.8	10000	6.01	6.01	10000	5000	[.1*[$dex/4]]
i 200       .875	.25	.	6.04	0.04	<	<	<
i 200		1.25	.75	.	6.06	6.01	13000	500	.
i 200		2	.75	.	6.01	6.01	15000	500	.
i 200		2.75	.125	.	6.06	6.08	8000	1000	[.6*[$dex/4]]
i 200		2.875	.375	.	6.04	6.04	1000	2000	<
i 200		3.25	.625	.	5.11	5.11	<	<	.
i 200		3.875	.125	.	5.11	6.01	800	6000	[.4*[$dex/4]]

;String	strt	dur	amp		pch	fmamp	fmratio
i 201		0	4	[[[4-$dex]^8]/14]	5.01	0	1

;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix ampatt
;i 420        	0	   4		.4 	.5	[50/[$dex*.5]]  	  10		2.04  [4.09*[[5-$dex]*.10]]		10    100    .005  .01   	  1         10          2        $dex        .001            3          .5 .5
i 420        	0	   .5		.4 	.01	20  	  10		5.04  1.01		100    1000    .05  .01   	  1         10          2        4        .001            3          .66  .5
;FM   start	dur	amp	frqbase	funct	fc	fmodend	indxmax	sinfreqstrt
i69	3	1	[[$dex^6]-2000]  	20		1	1	4		60		100

;Snare	strt	dur	amp	freq(900)
i 102		2	.125	[[[[$dex]^7]*1.02]*.5]	800
i 102		+	.	[[[[$dex]^7]*1.04]*.5]	<
i 102		.	.	[[[[$dex]^7]*.98]*.5]	.
i 102		.	.	[[[[$dex]^7]*1]*.5]	.
i 102		.	.	[[[[$dex]^7]*1.01]*.5]	.
i 102		.	.	[[[[$dex]^7]*.98]*.5]	.
i 102		.	.	[[[[$dex]^7]*1]*.5]	.
i 102		.	.	[[[[$dex]^7]*1.01]*.5]	.
i 102		.	.	[[[[$dex]^7]*.98]*.5]	.
i 102		.	.	[[[[$dex]^7]*1]*.5]	.
i 102		.	.	[[[[$dex]^7]*1.01]*.5]	.
i 102		.	.	[[[[$dex]^7]*.98]*.5]	.
i 102		.	.	[[[[$dex]^7]*1]*.5]	.
i 102		.	.	[[[[$dex]^7]*1.01]*.5]	.
i 102		.	.	[[[[$dex]^7]*.98]*.5]	.
i 102		.	.	[[[[$dex]^7]*1]*.5]	3000
s


;OUTRO ========================================================
;;a 0 0 14
t 0 60 9 20
;gverb	strt	dur	time	HFRoll(0-1)
i 900		0	9	1	.1

;String	strt	dur	amp	pch	fmamp	fmratio
i 201	0	8	350	1.01	50	500

;grainfilt		strt	  dur	   atk     rel    amp   ampoff	frq  maxfrqoff	dens1 dens2  gdur  gduroff	funct   randPdepth   lfodpth  lfoitts  lfodurmod   lfofiltmod   lpfmix
i 420        	0	   8.5	.5 	.3	160  	  10		8.04  3.01		10    1000    .005  .01   	  1         10          0        0        0            0          0

;HHat		strt	dur	amp	cutoff(10K)	length(0-1)(.2)
i 100		0	.5	6000	8000		1
i 100		+	.	<	<		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	.	.		.
i 100		.	.	1	1		.

;rndKS	strt	dur	amp	freq(N/A defaults to 60 and 900)
i 103 	0	.0625	5000 600 	0
i 103		+	.	<	.	(
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.

i 103 	.	.	.	 600 	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.

i 103 	.	.	. 600 	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.

i 103 	.	.	.	600 	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.

i 103 	.	.	. 600 	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.

i 103 	.	.	.	600 	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.

i 103 	.	.	. 600 	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.

i 103 	.	.	.	600 	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	.	.	.
i 103		.	.	1	.	10000

e

</CsScore>
</CsoundSynthesizer>