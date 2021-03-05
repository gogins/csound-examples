	sr = 22050
	kr =  441
	ksmps = 50

	instr	1
asig	in
dsig	octdown  asig, 7, 178, 0
wsig	noctdft  dsig, .1, 12, 33, 0, 0, 1
	specdisp wsig, .2, 0
koct	specptrk wsig, 8, .8, 0, 1, .2, 0
koct	=	(koct < 6.75 ? 0 : koct - 6.75)
koct	=	(koct > 2 ? 2 : koct)
	display	 koct, .2, 20
	kdump	koct * 1024, "koctfile", 7, .05
	out	 asig
	endin

