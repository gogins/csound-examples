	sr = 8192
	kr = 512
	ksmps = 16

	instr	1
i1	=	cpspch(p5)
k1	expon	i1, p3, i1*2
ksig	oscil	10000, k1/16, 1
asig	oscil	10000, k1, 1
dsig	octdown  ksig, 6, 100, .1
wsig	noctdft  dsig, .1, 24, 16
wacum	specaccm wsig
	specdisp wsig, .1, 0
	specdisp wacum, .1, 0
;	dispfft	asig, .2, 2048, 1, 0
	out	asig
	endin
