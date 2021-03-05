	sr = 44100
	kr = 1764
	ksmps = 25
	nchnls = 1

	instr	1,2,3,4
icps	=	cpsoct(p4)
kenv	envlpx	p5, .02, p3, .1, 2, .3, .01
a1	oscil	kenv, icps, 3
	out	a1
	endin

	instr	5,6,7
icps	=	cpspch(p4)
kenv	envlpx	p5, .02, p3, .1, 2, .3, .01
a1	oscil	kenv, icps, 3
	out	a1
	endin
