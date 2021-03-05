	sr = 10240
	kr = 1024
	ksmps = 10

	instr	1
;a1	buzz	20000, 100, 50, 1
a1	rand	20000
	dispfft	a1, .1, 4096
a2	reson	a1, 1000, 500, 2
	dispfft	a2, .1, 4096
a3	areson	a1, 1000, 500, 2
	dispfft	a3, .1, 4096
a4	=	a2 + a3
	dispfft	a4, .1, 4096
	out	a4
	endin
