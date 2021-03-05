<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo granular.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr          =           44100
kr          =           44100
ksmps       =           1

instr 1
	ims	=		100
	ifr	=		2*1.3113
	a1	linseg	2000, 5, 100, p3 - 5, 100
	k1	linseg	.0005, 5, .3, p3 -  5, .3
	a3	grain	4000,ifr, a1, 0, 0, k1, 3, 2, .4
	out a3
	gafx1	=	a3
endin

instr 2
	a1	line	100, p3, 0
	k1	line	20000, p3, 0	
	a2	grain	k1, 4000+p4, a1, 0, 100, .005, 1, 2, .005
	out	a2
	gafx2	=	a2
endin

instr 3
	a1	linseg	0, p3/2, 50, p3/2, 0
	k1	line	1000, p3, 20000
	a2	grain	k1, 3000, a1, 1000, 1000, .01, 1, 4, .01
	out	a2
	gafx3	=	a2
endin

instr 4
	k1	line	.01, p3, .0001
	a1	line	100, p3, 0
	a2	grain	15000, 3000, a1, 1000, 10, k1, 1, 2, .01
	out	a2
	gafx4	=	a2
endin

instr 5
	ifr	=	4*1.3113
	a1	=		4
	a2	grain	3000, p4*ifr, a1, 3000, ifr / 2, .3, 3, 4, .3
	out	a2
	gafx5 = a2
endin

instr 6
	k1	line	.001, p3, .01
	a1	line	10, p3, 100
	a2	grain	15000, 3000+p4, a1, 1000, 10, k1, 1, 2, .01
	out	a2
	gafx6	=	a2
endin

instr 99
	afx	=	(gafx1+gafx2+gafx3+gafx4+gafx5+gafx6)/12
	a1	reverb	afx, 2
	out	a1
endin
</CsInstruments>
<CsScore>
f1 0 8192 10 1
f2 0 8192 20 6
f3 0 65536 1 5 0 4 0
f4 0 8192 7 0 192 1 8000 0
f5 0 8192 8  0.010000 3822 0.810000 4370 0.000000
f6 0 8192 8  0.930000 3770 0.010000 4422 0.960000
f7 0 8192 8  0.930000 8192 0.010000
f8 0 8192 8  0.000000 8192 1.000000

t 0 30

;i99 0 12
;i2 0 2 0

i2 0 1.5 0
i2 2 1.5 -1000
i3 3.5 2.5
i2 4 1.5 2000
s
f0 1
s
t 0 30
i2 0 2 0
i2 1.5 2 -500
i2 2.5 2 500
i3 2.2 2
i2 4 1 0
i4 0 2
s
f 0 .5
s
t 0 30
i2 0 2 0
i2 1.5 2 -500
i2 2.5 2 500
i3 2.2 2
i2 4 1 0
i4 0 2
s
f0 2
s
i1 0 12
i5 4 6 1
i5 8 4 1
i5 10 2 2

;i6 11 .4 0
;i6 11.75 .4 -500
;i6 12.75 .4 -1000
;i4 13.5	1.5
;i4 15 .5
;i6 15.75 .4 -1000
;i4 16.75 .5
;i6 17.5 1.5 -500

e

</CsScore>
</CsoundSynthesizer>
