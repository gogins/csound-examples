	sr = 22050
	kr = 441
	ksmps = 50
	nchnls = 1

	instr	1
icps	cpsmidi
iamp	ampmidi	5000, 2
kamp	expon	iamp, 5, iamp/icps   ;freq-dependent overall decay
amp	linenr	kamp, .01, .333, .05
a1	oscil	amp, icps, 1
	out	a1
	endin

	instr	2
inum	notnum
ifno	table	inum, 99	;map notnum to ftables (3-11)
ibasno	table	inum, 98	;map notnum to ftable basenot
ibasoct  =  	ibasno/12. + 3.
icps	cpsmidi
iamp	ampmidi	8000, 95	;non-linear amps
amp	linenr	iamp, 0, .2, .03
a1	loscil	amp, icps, ifno, cpsoct(ibasoct)  ;read AIFF samps, give freq
	out	a1
	endin

	instr	3
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