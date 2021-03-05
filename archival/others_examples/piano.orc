	sr = 22050
	kr = 441
	ksmps = 50
	nchnls = 2

	instr	1
inum	notnum
ifno	table	inum, 10 	;do keyboard mapping to ftables (1-9)
ibasno	table	ifno, 11	;get basnot for each ftable
ibasoct =  	ibasno/12. + 3.
icps	cpsmidi
iamp	ampmidi	2000, 9
amp	linenr	iamp, 0, .2, .03
a1,a2	loscil	amp, icps, ifno, cpsoct(ibasoct)  ;read an AIFF-defined sampled instr
	outs	a1, a2
	endin
