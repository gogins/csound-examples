	sr = 16000
	kr = 1000
	ksmps = 16

	instr	1
;ktime	line	0, p3, p3
kx,ky	xyin	.02, 0,1, 0,400
;krmsr,krmso,kerr,kcps	lpread	ktime, "hellotest.lp"
krmsr,krmso,kerr,kcps	lpread	kx, "hellotest.lp"
kcps	=	(kcps == 0 ? 220 : kcps)
avoice	buzz	krmso, kcps, int(sr/880), 1
;avoice	buzz	krmso, ky, int(sr/880), 1
aunvoc	rand	krmso
asig	=	(kerr < .3 ? avoice : aunvoc)
aout	lpreson	asig
	out	aout
	endin
