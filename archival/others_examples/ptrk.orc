	sr = 11025
	kr =  441
	ksmps = 25

	instr	1
kvib	oscil	20, 2, 1
asig	oscil	1000, 440 + kvib , 2
dsig	octdown  asig, 6, 178, .1
wsig	noctdft  dsig, .05, 96, 33, 0, 0, 1
	specdisp wsig, .1, 0
koct	specptrk wsig, 8, .8, 0, 1, .1, 0
	display	 (koct > 8 ? koct - 8 : 0), .1, 20
	out	 asig
	endin

