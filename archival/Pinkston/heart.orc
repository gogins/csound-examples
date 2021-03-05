        sr      =       44100
        kr      =       4410
        ksmps   =       10
        nchnls  =       1

                instr   1
	anoise	randi	p4,360
	kbw1	oscil1	p7,p5,p3,p6
	kbw	=	kbw1+30
	aflt	reson	anoise,0,kbw,2
	abal	balance	aflt,anoise
	asig	linen	abal,.01,p3,.01
                out     asig
                endin
