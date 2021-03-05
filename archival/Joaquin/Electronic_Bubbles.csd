<CsoundSynthesizer>
<CsOptions>
DirectCsound -RWo bubbles.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
;	Electronic Bubbles  (Spring 1998)
;
;	Composed By  Jacob Joaquin
;	e-mail jake.ke@ix.netcom.com




sr= 44100
kr= 4410
ksmps= 10
nchnls= 2

ga100	init	0


instr 1
idur	=	p3
igain	=	p4
ipan	=	(p5 + 100)/200
ibw	=	p6
ibubble	=	p7
iseed	=	p8
iattack	=	p9
idecay	=	p10

ires1	=	925
ires2	=	950
ires3	=	975

	kenv1	line	0, idur, 10000

	arand1	randh	10000, ibubble, iseed
	aosc1	oscil	10000, arand1, 1
	kgain	linseg	.1, iattack, igain, idur-(iattack+idecay), igain, idecay, .1

	asig1	reson	aosc1, ires1, ibw
	asig2	reson	aosc1, ires2, ibw
	asig3	reson	aosc1, ires3, ibw

	again1	gain	asig1, kgain
	again2	gain	asig2, kgain
	again3	gain	asig3, kgain
	
	amix	=	again1+again2+again3
	alpf1	butterlp amix, 5000	
	alpf1	butterlp amix, 5000

	aleft	=	alpf1 * (1-ipan)
	aright	=	alpf1 * ipan
	outs	aleft, aright
	ga100	=	ga100 + alpf1
endin


instr 2
idur	=	p3
iamp	=	p4
iattack	=	p5
idecay	=	idur - iattack

	kenv1	expseg	.1, iattack, iamp, idecay, .1
	aosc1	oscil	kenv1, 440, 2

	kenv2	line	500, idur, 1250
	kenv3	expon	.5, idur, .05
	ares	reson	aosc1, kenv2, kenv2 * kenv3, 1
	ares	reson	ares, kenv2, kenv2 * .5, 1

	ares	balance	ares, aosc1

	outs	ares, ares
endin


instr	100
idur	=	p3

	asig	=	ga100

	kfn	oscil1i	0, 1, idur, 100
	kfn	=	kfn * .1

	kfn2	oscil1i	0, 1, idur, 101
	kfn3	oscil1i	0, 1, idur, 102

	arev	reverb	asig * kfn, kfn2
	arev2	reverb2	asig * kfn, kfn3, .5

	outs	arev, arev2
	ga100	=	100
endin
</CsInstruments>
<CsScore>
;	Electronic Bubbles  (Spring 1998)
;
;	Composed By  Jacob Joaquin
;	e-mail jake.ke@ix.netcom.com




f1 0 8192 10 1
f2 0 8192 21 1

f100	0	16	-2	1  1  2  2  3  3  1  1  6  2  4  3  3  2  2  4
f101	0	16	-2	.5 1  .7 .6 .5 .2 .1 .1 2  1  .5 .4 .3 .2 .3 .5
f102	0	16	-2	.2 .1 .1 .5 1 .7 .6 .5  2  1  .4 .3 .2 .3 .4 .5


;1	2	3	4	5	6	7	8	9	10

i1	0	40	800	0	15	200	1	15	15

i1	30	35	650	-100	17	188	.1	5	10
i1	30	40	650	100	16	185	.2	10	5

i1	50	40	900	0	5	115	.3	15	5

i1	75	47	300	-100	10	190	.4	10	2
i1	75	45	300	0	7	135	.5	2	5
i1	75	43	300	100	11	207	.6	5	10

i1	115	40	900	0	15.5	145	.7	15	5

i2	150	25	20000	8	12

i1	160	55	500	-75	13	200	.8	9	20
i1	160	55	500	0	14	150	.9	7	15
i1	160	55	500	75	18	200	.0	8	25

i1	200	40	500	0	15	200	.1	10	25

i1	205	25	1100	-100	.15	200	.1	15	10
i1	205	28	1100	0	.25	200	.1	15	10
i1	205	30	1100	100	.14	200	.1	15	10

i100	0	240





</CsScore>
</CsoundSynthesizer>
