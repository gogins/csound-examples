	sr = 11025
	kr = 441
	ksmps = 25
	nchnls = 2

	instr	1
inum	notnum
ifno	table	inum, 11	;do keyboard mapping to ftables (1-10)
ibasno	table	ifno, 12
ibasoct	=	ibasno/12. + 3.
icps	cpsmidi
iamp	ampmidi	2000, 99
amp	linenr	iamp, 0, .2, .03
a1,a2	loscil	amp, icps, ifno, cpsoct(ibasoct)
	outs	a1,a2
	endin
