<CsoundSynthesizer>
<CsOptions>
csound -RWdfo ./Nuclear.wav ./temp.orc ./temp.sco

</CsOptions>
<CsInstruments>
;	Nuclear Energy - Our "Misunderstood" Friend     (May 6, 1998)
;
;	Composed By  Jacob Joaquin
;	e-mail jake.ke@ix.netcom.com




sr	=	44100
kr	=	4410
ksmps	=	10
nchnls	=	2

gidrum	=	.4
ga100	init	0
ga101	init	0
ga102	init	0
ga103	init	0


instr 1
idur	=	p3
ipch	=	p4
iamp	=	p5
ifn	=	p6
ipat	=	p7
iacc	=	p8
ienv	=	p9
ifilter	=	p10
ipan	=	p11
iwet	=	p12

it	=	16 / idur

	kosc	oscil1	0, 1, idur, ipat
	kosc	=	cpspch((ipch-2) + .24 + (kosc * .01))

	kosc2	oscil1	0, 1, idur, iacc
	kosc2	=	iamp * (kosc2)

	kosc3	oscil	1, it, ienv

	aosc	oscil	kosc2, kosc, ifn, -1
	aosc2	oscil	kosc2, kosc * .004, ifn, -1
	aosc3	oscil	kosc2, kosc * .996, ifn, -1

	asig	=	(aosc+aosc2+aosc3)*.333*kosc3

	kosc5	oscil	.9, it, ifilter
	kosc5	=	kosc5 + .1

	asig	butterlp	asig * kosc5,	5000

	knin	oscil1	0, 1, idur, ipan
	aleft	=	asig * (sqrt(1 - knin))
	aright	=	asig * (sqrt(knin))
	outs	aleft, aright
	ga100	=	(ga100 + asig) * iwet
endin


instr 2
idur	=	p3
ipch	=	cpspch(p4)
iamp	=	p5
ipan	=	p6

	kenv	linseg	1, .01, iamp, idur - .01 , 1
	aosc	oscil	kenv, 440, 4

	kenv	expon	2, idur, .01
	aosc2	butterbp	aosc, ipch, ipch * kenv
	aosc2	butterbp	aosc2, ipch, ipch * kenv

	aosc	balance	aosc2, aosc
	aosc	=	aosc * .5

	aleft	=	aosc * (sqrt(1-ipan))
	aright	=	aosc * (sqrt(ipan))
	outs	aleft, aright
	ga101	=	ga101 + aosc
endin


instr 3
idur	=	p3
ipch	=	cpspch(p4)
iamp	=	p5
ipan	=	p6

	kenv	linseg	0, .01, iamp, idur - .02, iamp * .5, .01, 0

	kenv2	expon	19, idur, 1
	kenv2	=	kenv2 - 1

	afm	foscil	kenv, ipch, 1, .5, kenv2, 1

	aleft	=	afm * (sqrt(1-ipan))
	aright	=	afm * (sqrt(ipan))
	outs	aleft, aright
	ga102	=	ga102 + afm
endin


instr 4
idur	=	p3
ipch	=	cpspch(p4)
ipch2	=	cpspch(p5)
iamp	=	p6
iamp2	=	p7
ires	=	p8

ifn	=	4

	kenv2	expon	ipch, idur, ipch2
	kenv3	line	iamp, idur, iamp2

	aosc	oscil	kenv3, 440, ifn
	abp	butterbp	aosc, kenv2, kenv2 * ires
	abp	butterbp	abp, kenv2, kenv2 * ires

	aosc	balance	abp, aosc

	kenv	linseg	0, idur * .125, 1, idur * .875, 0
	aosc	=	aosc * kenv

	outs	aosc, aosc
endin


instr 5
idur	=	p3
ipch	=	cpspch(p4)
ipch2	=	cpspch(p5)
iamp	=	p6 + 1
iamp2	=	p7 + 1
iport	=	p8
	
	kenv	expseg	ipch2, iport, ipch, idur - iport, ipch
	kenv2	expseg	iamp, idur * .25, iamp2, idur * .75, iamp2
	kenv2	=	kenv2 - 1

	kosc	oscil	.5, 6, 1, -1
	kosc	=	kosc + .5

	afm	foscili	kenv2, kenv, 1, .5, 2 + kosc, 1, -1
	afm2	foscili	kenv2, kenv * .004, 1, .5, 2 + kosc, 1, -1
	afm3	foscili	kenv2, kenv * .996, 1, .5, 2 + kosc, 1, -1

	amix	=	(afm + afm2 + afm3) * .333
	ga103	=	ga103 + amix
endin


instr 6
isnd	=	p4
ilvl	=	p5

	asig	soundin	isnd
	asig	=	asig * ilvl * gidrum
	outs	asig, asig
endin


instr	100
idur	=	p3
iwet	=	p4
idecay1	=	p5
idecay2	=	p6

	asig	=	ga100 * iwet

	aleft	reverb2	asig, idecay1, .5
	aright	reverb	asig, idecay2

	outs	aleft, aright
	ga100	=	0
endin


instr	101
idur	=	p3
iwet	=	p4
idecay1	=	p5
idecay2	=	p6
idelay	=	p7

	asig	=	ga101 * iwet

	aleft	reverb2	asig, idecay1, .5
	aright	reverb	asig, idecay2

	aright	delay	aright, idelay

	outs	aleft, aright
	ga101	=	0
endin


instr	102
idur	=	p3
iwet	=	p4
idecay	=	p5
idecay2	=	p6
idelay	=	p7
idelay2	=	p8

	asig	=	ga102 * iwet

	aleft	reverb	asig, idecay
	aright	reverb2	asig, idecay2, .5

	aleft	delay	aleft, idelay
	aright	delay	aright, idelay2

	outs	aleft, aright
	ga102	=	0
endin


instr 103
	asig	=	ga103
	asig2	delay	asig, .05

	outs	asig, asig2
	ga103	=	0
endin
</CsInstruments>
<CsScore>
;	Nuclear Energy - Our "Misunderstood" Friend     (May 6, 1998)
;
;	Composed By  Jacob Joaquin
;	e-mail jake.ke@ix.netcom.com




f1	0	8192	10	1
f2	0	8192	7	-1	8192	1
f3	0	8192	7	1	4096	1	0	-1	4096	-1
f4	0	8192	21	1

;Pan
f20	0	16	-2	.5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5  .5
f21	0	16	-2	1   0   1   0   1   0   1   0   1   0   1   0   1   0   1   0
f22	0	16	-2	.5  .6  .4  .7  .3  .8  .2  .9  .1  .8  .2  .7  .3  .6  .4  .5
f23	0	16	-2	0   .25 .5  .75 1   .75 .5  .25 0   .25 .5  .75 1   .75 .5  .25  

;Envelopes
f50	0	256	7	1	256	1
f51	0	256	7	0	128	1	128	0
f52	0	256	7	0	256	1
f53	0	256	7	1	200	1	56	0
f54	0	256	7	0	16	1	240	0
f55	0	256	7	0	10	1	190	1	56	0
f56	0	256	5	.01	10	1	246	.01

;Accent Tables
f80	0	16	-2	1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1
f81	0	16	-2	2   1   1   2   1   2   1   1   2   1   1   2   1   1   2   1 
f82	0	16	-2	2   1   2   1   2   1   1   2   1   1   2   1   1   2   2   2
f83	0	16	-2	2   1   1   2   1   2   1   1   1   2   1   2   1   1   2   1
f84	0	16	-2	2   1   2   1   1   2   1   2   1   1   2   1   1   2   1   1 	
f85	0	16	-2	1   2   1   2   1   1   2   1   1   2   1   1 	2   1   2   1
f86	0	16	-2	2   1   1   2   1   1 	2   1   2   1   2   1   1   2   1   2

;Pattern Tables
f100	0	16	-2	12  0   13  12  0   10  0   4   5   0   10  4   0   0   -2  10
f101	0	16	-2	12  0   10  12  0   13  0   5   4   0   4   10  0   0   -2  13
f102	0	16	-2	12  0   13  10  0   12  0   10  5   0   4   5   0   0   -2  0
f103	0	16	-2	12  0   10  -2  0   4   0   10  5   0   4   19  0   0   10  13


t	0	90

i100	0	205	.05	1.5	1.7
i101	0	205	.2	2.1	2	.25
i102	0	205	.3	2	2.2	.15	.175
i103	0	205

		Dur	Root	Amp	Shape	Pat	Acc	Env	Filter	Pan	Wet
;1	2	3	4	5	6	7	8	9	10	11	12
i1	0	4	6.04	15000	2	100	81	50	56	20	1
i1	+	.	.	.	.	101	.	.	.	.	.
i1	+	.	5.04	.	.	100	.	.	.	.	.
i1	+	.	.	.	.	101	.	.	.	.	.
i1	+	.	6.04	.	2	100	.	.	.	.	.
i1	+	.	.	.	.	101	.	.	.	.	.
i1	+	.	5.04	.	.	100	.	.	.	.	.
i1	+	.	.	.	.	101	.	.	.	.	.
i1	+	.	6.04	10000	2	100	.	.	55	22	.
i1	+	.	.	.	.	101	.	.	.	.	.
i1	+	.	5.04	.	.	100	.	.	.	.	.
i1	+	.	.	.	.	101	.	.	.	.	.
i1	+	.	6.04	.	2	100	.	.	.	.	.
i1	+	.	.	.	.	101	.	.	.	.	.
i1	+	.	5.04	.	.	100	.	.	.	.	.
i1	+	.	.	.	.	101	.	.	.	.	.
i1	+	.	6.04	15000	2	102	.	.	56	20	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	+	.	5.04	.	.	102	.	.	.	.	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	+	.	6.04	.	2	102	.	.	.	.	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	+	.	5.04	.	.	102	.	.	.	.	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	+	.	6.04	10000	2	102	.	.	55	22	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	+	.	5.04	.	.	102	.	.	.	.	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	+	.	6.04	10000	2	102	.	.	.	.	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	+	.	5.04	.	.	102	.	.	.	.	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	128	8	6.04	18000	2	102	.	.	56	20	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	+	.	5.04	.	.	102	.	.	.	.	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	+	.	6.04	10000	2	102	.	51	55	22	.
i1	+	.	.	.	.	103	.	.	.	.	.
i1	+	.	5.04	.	.	102	.	.	.	.	.
i1	+	.	.	.	.	103	.	.	.	.	.

i2	32	1	9.00	8000	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	56	1	9.00	.	0
i2	+	.	10.00	.	1
i2	60	1	9.00	.	0
i2	+	.	10.00	.	1
i2	64	8	9.00	5000	.8
i2	+	.	10.00	.	.4
i2	+	.	9.00	5000	.8
i2	+	.	10.00	.	.4
i2	96	1	9.00	8000	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	106	1	9.00	.	0
i2	+	.	10.00	.	1
i2	108	1	9.00	.	0
i2	+	.	10.00	.	1
i2	112	1	9.00	8000	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	122	1	9.00	.	0
i2	+	.	10.00	.	1
i2	126	1	9.00	.	0
i2	+	.	10.00	.	1
i2	128	16	9.00	5000	.8
i2	+	.	10.00	.	.4
i2	160	1	9.00	8000	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	+	.	9.00	.	0
i2	+	.	10.00	.	1
i2	192	8	10.00	8000	.2
i2	192	8	10.01	8000	.8

i3	16	4	6.04	4000	.5
i3	+	2	6.09	.	.5
i3	+	2	6.02	.	.5
i3	+	4	7.04	.	.5
i3	+	2	7.09	.	.5
i3	+	2	7.02	.	.5
i3	+	4	6.04	.	.5
i3	+	2	6.09	.	.5
i3	+	2	6.02	.	.5
i3	+	4	7.04	.	.5
i3	+	2	7.09	.	.5
i3	+	2	7.02	.	.5
i3	+	4	6.04	.	.5
i3	+	2	6.09	.	.5
i3	+	2	6.02	.	.5
i3	+	4	7.04	.	.5
i3	+	2	7.09	.	.5
i3	+	2	7.02	.	.5
i3	+	4	6.04	.	.5
i3	+	2	6.09	.	.5
i3	+	2	6.02	.	.5
i3	+	4	7.04	.	.5
i3	+	2	7.09	.	.5
i3	+	2	7.02	.	.5
i3	+	4	6.04	.	.5
i3	+	2	6.09	.	.5
i3	+	2	6.02	.	.5
i3	+	4	7.04	.	.5
i3	+	2	7.09	.	.5
i3	+	2	7.02	.	.5
i3	+	4	6.04	.	.5
i3	+	2	6.09	.	.5
i3	+	2	6.02	.	.5
i3	+	4	7.04	.	.5
i3	+	2	7.09	.	.5
i3	+	2	7.02	.	.5
i3	+	4	6.04	.	.5
i3	+	2	6.09	.	.5
i3	+	2	6.02	.	.5
i3	+	4	7.04	.	.5
i3	+	2	7.09	.	.5
i3	+	2	7.02	.	.5
i3	128	8	6.04	.	.5
i3	+	4	6.09	.	.5
i3	+	4	6.02	.	.5
i3	+	8	7.04	.	.5
i3	+	4	7.09	.	.5
i3	+	4	7.02	.	.5
i3	+	8	6.04	.	.5
i3	+	4	6.09	.	.5
i3	+	4	6.02	.	.5
i3	+	8	7.04	.	.5
i3	+	4	7.09	.	.5
i3	+	4	7.02	.	.5
i3	192	8	6.04	4000	.4
i3	192	12	5.04	4000	.6

i4	184	8	12.04	6.04	2000	8000	.1

i5	16	.5	9.16	9.12	5000	5000	.02
i5	+	.25	9.17	pp4	pp7	.	.
i5	+	.5	9.16	.	.	.	.
i5	+	.5	9.14	.	.	.	.
i5	+	.25	9.08	.	.	.	.
i5	+	.5	9.09	.	.	.	.
i5	+	.25	9.14	.	.	.	.
i5	+	.75	9.08	.	.	.	.
i5	+	.25	9.02	.	.	.	.
i5	+	.25	9.14	.	.	.	.
i5	+	.5	9.16	.	.	.	.
i5	+	.25	9.14	.	.	.	.
i5	+	.5	9.16	.	.	.	.
i5	+	.5	9.17	.	.	.	.
i5	+	.25	9.09	.	.	.	.
i5	+	.75	9.08	.	.	.	.
i5	+	.75	9.14	.	.	.	.
i5	+	.25	9.02	.	.	.	.
i5	+	.25	9.17	.	.	.	.
i5	24	.5	9.16	9.12	5000	5000	.01
i5	+	.25	9.17	pp4	pp7	.	.
i5	+	.5	9.16	.	.	.	.
i5	+	.5	9.14	.	.	.	.
i5	+	.25	9.08	.	.	.	.
i5	+	.5	9.09	.	.	.	.
i5	+	.25	9.14	.	.	.	.
i5	+	.75	9.08	.	.	.	.
i5	+	.25	9.02	.	.	.	.
i5	+	.25	9.14	.	.	.	.
i5	+	.5	9.16	.	.	.	.
i5	+	.25	9.14	.	.	.	.
i5	+	.5	9.16	.	.	.	.
i5	+	.5	9.17	.	.	.	.
i5	+	.25	9.09	.	.	.	.
i5	+	.75	9.08	.	.	.	.
i5	+	.75	9.14	.	.	.	.
i5	+	.25	9.02	.	.	.	.
i5	+	.25	9.17	.	.	.	.
i5	64	4	9.04	9.04	0	5000	.1
i5	+	2	9.11	pp4	pp7	.	.
i5	+	2	9.14	.	.	.	.
i5	+	4	9.04	.	.	.	.
i5	+	2	9.11	.	.	.	.
i5	+	2	9.16	.	.	.	.
i5	+	4	9.04	.	.	.	.
i5	+	2	9.11	.	.	.	.
i5	+	2	9.14	.	.	.	.
i5	+	4	9.04	.	.	.	.
i5	+	2	9.11	.	.	.	.
i5	+	2	9.16	.	.	.	.
i5	+	4	9.04	.	.	.	.
i5	+	2	9.11	.	.	.	.
i5	+	2	9.14	.	.	.	.
i5	+	4	9.04	.	.	.	.
i5	+	2	9.11	.	.	.	.
i5	+	2	9.16	.	.	.	.
i5	159.9	.1	9.16	9.16	0	5000	.1
i5	160	1	9.16	9.16	5000	5000	.05
i5	+	.5	9.17	pp4	pp7	.	.
i5	+	1	9.14	.	.	.	.
i5	+	1	9.16	.	.	.	.
i5	+	.5	9.14	.	.	.	.
i5	+	1	9.09	.	.	.	.
i5	+	.5	9.08	.	.	.	.
i5	+	1.5	9.09	.	.	.	.
i5	+	1	9.02	.	.	.	.
i5	+	1	9.16	.	.	.	.
i5	+	1.5	9.14	.	.	.	.
i5	+	1	9.08	.	.	.	.
i5	+	.5	9.14	.	.	.	.
i5	+	1	9.09	.	.	.	.
i5	+	.5	9.08	.	.	.	.
i5	+	1.5	9.23	.	.	.	.
i5	+	.5	9.14	.	.	.	.
i5	+	.5	9.17	.	.	.	.
i5	+	1	9.16	.	.	.	.01
i5	+	.5	9.17	.	.	.	.
i5	+	1	9.14	.	.	.	.
i5	+	1	9.16	.	.	.	.
i5	+	.5	9.14	.	.	.	.
i5	+	1	9.09	.	.	.	.
i5	+	.5	9.08	.	.	.	.
i5	+	.5	9.09	.	.	.	.
i5	+	.5	9.04	.	.	.	.
i5	+	.5	9.09	.	.	.	.
i5	+	1	9.02	.	.	.	.
i5	+	1	9.16	.	.	.	.
i5	+	.5	9.14	.	.	.	.
i5	+	.5	9.16	.	.	.	.
i5	+	.5	9.14	.	.	.	.
i5	+	1	9.08	.	.	.	.
i5	+	.5	9.14	.	.	.	.
i5	+	1	9.09	.	.	.	.
i5	+	.5	9.08	.	.	.	.
i5	+	1.5	9.23	.	.	.	.
i5	+	.5	9.14	.	.	.	.
i5	+	.5	9.17	.	.	.	.
i5	+	4	9.16	.	.	.	.
i5	+	4	9.04	.	.	.	.
i5	+	4	8.04	.	.	0	.

i6	32	1	1	1	;Kick
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	33	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	32.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	32	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	40	1	1	1	;Kick
i6	+	.75	.	.
i6	+	.25	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	+	1	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	41	2	2	1.2	;Snare
i6	+	.5	.	.
i6	+	1.5	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	40.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	40	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	48	1	1	1	;Kick
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	49	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	48.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	48	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	56	1	1	1	;Kick
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	57	2	2	1.2	;Snare
i6	+	.5	.	.
i6	+	1.5	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	56.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	56	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	64	1	1	1	;Kick
i6	+	.75	.	.
i6	+	.25	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	+	1	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	65	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	64.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	64	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	72	1	1	1	;Kick
i6	+	.75	.	.
i6	+	.25	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	+	1	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	73	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	72.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	72	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	80	1	1	1	;Kick
i6	+	.75	.	.
i6	+	.25	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	+	1	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	81	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	80.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	80	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	96	1	1	1	;Kick
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	97	2	2	1.2	;Snare
i6	+	.5	.	.
i6	+	1.5	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	96.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	96	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	104	1	1	1	;Kick
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	105	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	104.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	104	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	112	1	1	1	;Kick
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	113	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	112.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	112	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	120	1	1	1	;Kick
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	121	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	120.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	120	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	128	1	1	1	;Kick
i6	+	.75	.	.
i6	+	.25	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	+	1	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	129	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	128.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	128	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	136	1	1	1	;Kick
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	137	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	136.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	136	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	144	1	1	1	;Kick
i6	+	.75	.	.
i6	+	.25	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	+	1	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	145	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	144.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	144	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	152	1	1	1	;Kick
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	153	2	2	1.2	;Snare
i6	+	.	.	.
i6	+	.	.	.
i6	+	.5	.	.
i6	+	.25	.	.
i6	+	1.25	.	.
i6	152.5	1	3	1.3	;Open Hi-hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	152	1	4	.8	;Closed Hi-Hat
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.
i6	+	.	.	.



</CsScore>
<CsArrangement>
</CsArrangement>
</CsoundSynthesizer>
