<CsoundSynthesizer>
<CsOptions>
csound -RWfo ./message.wav ./temp.orc ./temp.sco



</CsOptions>
<CsInstruments>
;	Message From Another Planet  (Spring 1999)
;
;	Composed By  Jacob Joaquin
;	You can Contact me via e-mail @ jake.ke@ix.netcom.com
;
;
;
;
;	To search for extraterrestrial intelligence from your home computer visit
;	http://www.seti.org/setiathome.html




sr=44100
kr=4410
ksmps=10
nchnls=2

instr 2
ipch	=	cpspch(p5)

imult	=	((p6+1) / p6) * .5
iseed	=	(rnd(100)+100)/200

	k2	expseg	.0625, 15, .0625, 113, 3.75, 113, .03125, 15, .0625
	k3	linseg	1, 240, 1, 16, 0
	k1	phasor	p7 * k2
	k1	tablei	256 * k1 , 100, 0, 0, 1
	krand	randi	30000, p7 * 5, iseed
	krand	=	(krand + 30000) / 60000
	a1	oscil	p4 * imult * k1 * k3, ipch * p6, 1
	outs	a1 * sqrt(krand), a1 * (sqrt(1-krand))

endin



</CsInstruments>
<CsScore>
;	Message From Another Planet  (Spring 1999)
;
;	Composed By  Jacob Joaquin
;	You can Contact me via e-mail @ jake.ke@ix.netcom.com
;
;
;
;
;	To search for extraterrestrial intelligence from your home computer visit
;	http://www.seti.org/setiathome.html




f1	0	8192	10	1
f100	0	256	-7	0	16	1	240	0

t	0	60

i2	0	256	3000	8.00	1	1.24	
i2	0	.	.	.	1.0666	1.23	
i2	0	.	.	.	1.125	1.22	
i2	0	.	.	.	1.14285	1.21	
i2	0	.	.	.	1.23076	1.20	
i2	0	.	.	.	1.28571	1.19	
i2	0	.	.	.	1.333	1.18	
i2	0	.	.	.	1.4545	1.17	
i2	0	.	.	.	1.5	1.16	
i2	0	.	.	.	1.6	1.15	
i2	0	.	.	.	1.777	1.14	
i2	0	.	.	.	1.8	1.13	
i2	0	.	.	.	2	1.12	
i2	0	.	.	.	2.25	1.10	
i2	0	.	.	.	2.28571	1.09	
i2	0	.	.	.	2.666	1.08	
i2	0	.	.	.	3	1.07	
i2	0	.	.	.	3.2	1.06	
i2	0	.	.	.	4	1.05	
i2	0	.	.	.	4.5	1.04	
i2	0	.	.	.	5.333	1.03	
i2	0	.	.	.	8	1.02	
i2	0	.	1000	.	9	1.01	
i2	0	.	500	.	16	1.00	




</CsScore>
<CsArrangement>
</CsArrangement>
</CsoundSynthesizer>
