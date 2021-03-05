	sr = 20000
	kr = 1000
	ksmps = 20

	instr	1
ktime	line	0, p3, p3
krmsr,krmso,kerr,kcps	lpread	ktime, "lp2data"
kcps	=	(kcps == 0 ? 220 : kcps)
avoice	buzz	krmso, kcps, int(sr/880), 1
aunvoc	rand	krmso
asig	=	(kerr < .3 ? avoice : aunvoc)
aout	lpreson	asig
	out	aout
	endin
