	sr = 22050
	kr = 2205
	ksmps = 10
ga2	oscil	p4, p5, 1
	nchnls = 1

	instr	1
a1	oscil	p4, p5, 1
a2	oscil	p4, p5, 1
a3	oscil	p4, p5, 1
ga1	oscil	p4, p5, 1
	out	a1
	endin

