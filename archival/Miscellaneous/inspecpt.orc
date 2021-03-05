	sr = 11025
	kr =  441
	ksmps = 25

	instr	1
asig	in
dsig	octdown  asig, 7, 178, 0
wsig1	noctdft  dsig, .05, 24, 33, 0, 0, 1
	specdisp wsig1, .1, 0
koct	specptrk wsig1, 8, .8, 0, 0, .1, 0
	display	 (koct > 4 ? koct - 4 : 0), .1, 20
	out	 asig
	endin




	instr	2
;k1	oscil	.1, .1, 3
;ksum2	oscil    1000, 2+k1, 1
;ksum2	specsum	 wsig2, 1
;	display  kout, 2
;	dispfft	 asig, .2, 2048, 1, 0
	endin