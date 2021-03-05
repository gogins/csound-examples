	sr = 44100
	kr = 441
	ksmps = 100
	nchnls = 1

	instr	1
inum	notnum
ifno	table	inum, 19	;do keyboard mapping to ftables (13-18)
ibasno	table	inum, 20	;do keyboard mapping to ftables (13-18)
ibasoct =  	ibasno/12. + 3.
icps	cpsmidi
iamp	ampmidi	3000, 12		;amp warping, table 12
amp	linenr	iamp, 0, .2, .03
a1	loscil	amp, icps, ifno, cpsoct(ibasoct)  ;read an AIFF-defined sampled instr
	out	a1
	endin
