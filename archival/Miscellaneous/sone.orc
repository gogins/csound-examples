;-------SONETEST.ORC--------------------------- 

sr		=		44100
kr		=		441
ksmps	=		100
nchnls	=		2

		instr 1

ifq		=		cpspch(p4+4)
isones	=		p5
asones	expseg	.1, .1, isones, p3-.11, isones, .01, .1
ares1	pow		asones/ifq, 3, 1
ires2	pow		10, -12
adb		=		10 * ((log((ares1) / ires2)) /log(10))
ampenv	=		ampdb(adb)
amp		=		ampenv
asig	oscili	amp, ifq, 1

		outs	asig, asig

		endin
