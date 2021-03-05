	sr = 44100
	kr = 4410
	ksmps = 10
	nchnls = 1

	instr	1
icps	cpsmidi
iamp	ampmidi	5000, 2
kamp	expon	iamp, 5, iamp/icps   ;freq-dependent overall decay
amp	linenr	kamp, .01, .333, .05
a1	oscil	amp, icps, 1
	out	a1
	endin

