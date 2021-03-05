;	Peter Child, 2nd mvt. of Three Brief Impressions, summer 79

	sr=22050
	kr=1050		;originally 20000, 1000, 20
	ksmps=21
	nchnls=2        ;originally quad

; gbuzz knh & kr now swapped (new format)

	ga1	init	0

	instr 1 		;celeste1
	;p6 is ampl.
	;p7 bf.rl   0<bf<4  0<rl<4
	;p8 is 'damper pedal' flag
	;p9 is attn for rvb
	i1	=	cpspch(p5)
	p3	=	(p8==0?.5:p8)
;	i3	=	int(p7) 	;0.x back, 4.x front
	i4	=	frac(p7)*10	;x.0 left, x.4 right
	p6	=	p6/16
	a2	expseg	.01,.01,1,.2,.01,p3,.001
	a1	rand	p6
	a1	reson	a1,200+(i1-200)/2,5,2
	a1	=	a1*a2
	a2	linseg	0,.015,p6,p3-.015,0
	a2	oscili	a2,i1,1
	a1	=	a1+a2
		outs	i4*a1,(4-i4)*a1
	ga1	=	ga1+a1*p9
	endin


	instr 2 	;tabla1
	;p6 is amplitude
	;p7 is attn for rvb
	;p8 is bf.rl 0<bf<4 0<rl<4
	p3	=	.5
	i1	=	cpspch(p5)
	i2	=	(p3>.5?.5:p3/2)
;	i3	=	int(p8) 	;0.x back, 4.x front
	i4	=	frac(p8)*10	;x.0 left, x.4 right
	a1	linseg	1,i2,0,p3-i2,0
	k1	linseg	1,.025,0,p3-.025,0
	a1	foscili a1*p6,i1,1.4,1,k1*25,1
	a1	=	a1/16
		outs	i4*a1,(4-i4)*a1
	ga1	=	a1*p7
	endin

	instr 3,4	;small.gong1
	;p6 is amplitude
	;p7 is lowest harmonic
	;p8 is starting kr (also 'alternate' flag):1 or .01
	;p9 is ending kr: .01 or .2
	;p10 is attn for rvb
	;p11 is 'vib' rate
	;p12 bf.rl 0<bf<4 0<rl<4
	i1	=	octpch(p5)
;	i3	=	int(p12)	;0.x back, 4.x front
	i4	=	frac(p12)*10	 ;x.0 left, x.4 right
	i5	=	int(20000/(2*cpspch(p5)))
	p3	=	1.5
	if p8 = 1 goto envlp2
	k1	expseg	.01,.075,1,p3-.075,.01
	goto next
envlp2: k1	expon	1,p3,.01
next:	k2	expon	p8,p3,p9
	k3	oscil	.25,p11,1
	a1	oscili	1,cpsoct((i1/3)+k3),1
	a2	gbuzz	1,cpsoct(i1),i5,p7,k2,5  ;new format
	k1	=	k1*p6
	a1	=	(1+a1)*a2*k1
	a1	=	a1/16
		outs	i4*a1,(4-i4)*a1
	ga1	=	ga1+(p10*a1)
	endin


	instr 5 	;medium.gong1
	;p6 is ampl
	;p7 is lowest harmonic (N.B.:0 yields zero pitch definition)
	;p8 is starting kr (also 'alternate' flag): 1 or .01 only
	;p9 is ending kr: .01 or .2 {N.B.} only
	;p10 is attn for rvb
	;p11 is envlp attn for slurrer
	;p12 is beat rate
	;p13 is bf.rl 0<bf<4 0<rl<4
	p6	=	p6/32
	i1	=	octpch(p5)
	i2	=	(p4>1?1:0)	;entering slur & phase flag for oscils
	i3	=	(p4-(2*i2))	;leaving slur flag
	if i2 > 0 igoto stet45		;if slurred into
	i4	=	i1		;  don't update i4,i5
	i5	=	.001*p6
stet45:	i6	=	(i3==1?.2:.001)
;	i7	=	int(p13)	;0.x back, 4.x front
	i8	=	frac(p13)*10	 ;x.0 left, x.4 right
	i9	=	int(20000/(2*cpspch(p5)))
	if i3 = 0 goto nohold
	ihold
nohold: if p8 = 1 goto envlp2
	if p3 <= .175 goto envlp3
	a6	expseg	i5,.075,p6,p3-.175,p11*p6,.1,i6*p6
	goto next
envlp2: a6	expon	p6,p3,.001*p6
	goto next
envlp3: a6	expseg	i5,p3/2,p6,p3/2,i6*p6
next:	k2	expon	p8,p3,p9
	a1	oscil	1,.7*cpsoct(i1),1,-i2
	if p8 = 1 goto gong
	k4	linseg	i4,.1,i1,p3-.1,i1
gong:	k4	=	(p8==.01?k4:i1)
	a2	gbuzz	a6,cpsoct(k4),i9,p7,k2,5,-i2     ;new format
	a3	gbuzz	a6,p12+cpsoct(k4),i9,p7,k2,5,-i2 ;new format
	a1	=	(a2+a3)*(1+a1)
	i4	=	i1
	i5	=	.2*p6
		outs	i8*a1,(4-i8)*a1
	ga1	=	ga1+a1*p10
	endin

	instr 9 	;reverb
	ga1	init	0
	a1	reverb	ga1,2
		outs	a1,a1
	ga1	=	0
	endin
