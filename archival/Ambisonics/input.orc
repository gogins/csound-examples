sr = 48000
kr = 480
ksmps = 100

	instr 1
kfreq	linseg	10,p3,1000
k1	oscil	15000,4,1
a1	pluck	15000+k1,kfreq,10,0,1
	out a1
	endin
