<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo delpuls.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
	sr = 10000
	kr = 10000
	ksmps = 1

	instr	1
k1	init	0
a1	= 	(k1 < p5 ? p4 : 0)
a2	delay	a1, p7
	out	a1 + a2
k1	=	(k1 < p6 ? k1 + .0001 : 0)
	endin
</CsInstruments>
<CsScore>
i1 0  .5 10000 .0001 .25 .0018
i1 .5  .   .     .    .  .0015
i1 1   .   .     .    .  .0012
i1 1.5 .25 .     .    .  .0015
e

</CsScore>
</CsoundSynthesizer>
