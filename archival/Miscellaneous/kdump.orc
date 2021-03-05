	sr = 22050
	kr = 2205
	ksmps = 10
	nchnls = 1

	instr	1
k1	oscil	p4, p5, 1
	kdump2   k1, k1 + 1, "kdfile", 5, .1
	endin

