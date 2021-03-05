	sr = 25600
	kr = 256
	ksmps = 100

	instr	1

ksig	oscil	10000, 20, 1
	display ksig, 1
	dispfft ksig, 1, 256, p4, 0

asig	buzz	10000, 400, 2, 1
;	display asig, .04
;	dispfft	asig, .04, 512, p4, 0
	out	asig

	endin
