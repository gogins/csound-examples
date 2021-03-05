	sr = 22050
	kr = 441
	ksmps = 50
	nchnls = 2

	instr	1
icps	cpsmidi
iamp	ampmidi	5000, 99
kamp	expon	iamp, 5, iamp/icps   ;freq-dependent overall decay
amp	linenr	kamp, .01, .333, .05
a1	oscil	amp, icps, 100
	outs	a1, a1
	endin

	instr	2
inum	notnum
ifno	table	inum, 9 	;do keyboard mapping to ftables (1-8)
ibasno	table	ifno, 10	;get basnot for each ftable
ibasoct =  	ibasno/12. + 3.
icps	cpsmidi
iamp	ampmidi	4000, 99
amp	linenr	iamp, 0, .2, .03
a1,a2	loscil	amp, icps, ifno, cpsoct(ibasoct)  ;read an AIFF-defined sampled instr
	outs	a1, a2
	endin

	instr	3
inum	notnum
ifno	table	inum, 21	;do keyboard mapping to ftables (1-10)
ibasno	table	ifno, 22
ibasoct	=	ibasno/12. + 3.
icps	cpsmidi
iamp	ampmidi	4000, 99
amp	linenr	iamp, 0, .2, .03
a1,a2	loscil	amp, icps, ifno+10, cpsoct(ibasoct)
	outs	a1,a2
	endin

