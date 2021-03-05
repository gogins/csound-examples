	sr = 44100
	kr =  100
	ksmps = 441

	instr	1
asig	in
dsig	octdown  asig, 7, 178, 0
wsig	noctdft  dsig, .01, 96, 33, 0, 0, 1
	specdisp wsig, .2, 0
koct	specptrk wsig, 8, .8, 0, 1, .2, 0
koct	=	(koct < 7.75 ? 7.75 : koct)
koct	=	(koct > 9.25 ? 9.25 : koct)
	display	 koct - 7.75, .2, 20
	kdump	(koct - 3) * 2048, "pt.bhimp3", 7, .01
	out	 asig
	endin

