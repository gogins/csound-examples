			sr =   22050
			kr =    882
			ksmps = 25

			instr	1
	ioct	= 	octpch(p5)
	ktime	line	0, p3, p3	; normal
;	ktime	expon	.1, p3, p3	; changing speed
;	kptvh   expon   .1, p3, .1+p4
	aout	pvoc	ktime, 1.0, "pv.pv"
		display aout, .01, 1, 1
;	aout	pvoc	ktime, 1.0, "pv.medlab"
;	aout	pvoc	ktime, cpsoct(ioct+.2-.3*kptvh)/440, "pv.medlab6"
;		dispdft aout, .2, 4, 12, 16, 0, 0
;		dispfft aout, .2, 2048, 1, 0 
		out	aout
		endin
