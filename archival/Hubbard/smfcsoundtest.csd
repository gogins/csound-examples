<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>
sr=44100
ksmps=16
nchnls=2

#include "ratsmfperc.orc"

	instr 11

aleft	init	0
aright	init	0

idur	=	p3
iamp	=	ampdb(p4)
ifreq	=	p5
kfreq	init	ifreq
;kswitch	=	(kfreq > 294 ? 1 : 0)
aenv	transeg	0, .004, 1, iamp, p3-.01, 1, .8*iamp, .006, 1, 0
aplk1	pluck	1, kfreq, ifreq, 11, 3, 0.0001
;aplk2	pluck	1, kfreq * 1.001, ifreq, 11, 3, .0003
;aplk3	pluck	1, kfreq * .995, ifreq, 11, 3, .0004
;aosc	oscil	1, ifreq, 11
;afilt	rezzy	aosc, 350, 20
kfc	=	ifreq * 1.15
;kfc	=	500
;aplk	=	(aplk1+aplk2+aplk3)/3
afilt	rezzy	aplk1, kfc, 50
afilt	resonr	aplk1, kfc, 40, 2
afilt2	resonr	afilt, kfc, 40, 1
adist	distort1 afilt2, .16, .4, .2, -.03
ascl	=	adist * aenv
aleft	=	ascl
aright	=	aleft

	outrg	1, aleft, aright
	endin


	instr 22

aleft	init	0
aright	init	0
idur	=	p3
iamp	=	ampdb(p4)
ifreq	=	p5
kenv	transeg	0, .003, 1, iamp, idur-.013, 2, iamp * .8, .01, 1, 0
kfreq	init	p5
imeth	=	1
;aplk	pluck	kenv, kfreq, ifreq, 22, imeth;, .7, .3

;ktrans	init	4
ktrans	expseg	6, idur, 5.6
aspd	init	0
koct	init	.35
koct	linseg	0, idur, .1
kband	init	100
kband	expseg	20, idur, 100
kris	init	.001
kdur	init	.02
;kdur	init	.02
kdec	init	.002
iolaps	=	250
ia	=	22
ib	=	23

afogl	fog	1, kfreq, ktrans, aspd, koct, kband, kris, kdur, kdec, iolaps, ia, ib, idur, 0, 1
afogh	fog	1, kfreq, ktrans*3, aspd, koct, kband, kris, kdur, kdec, iolaps, ia, ib, idur, 0, 1
afog	=	(afogl + afogh) / 2
kfog	downsamp afog, 8
;kfog	=	k(afog) * .2
kplkf	=	kfog*kfreq*.25 + kfreq
afmplk	pluck	1, kplkf, ifreq, 22, 1

;adist	distort1 afog, .8, .2, .4, -.02
;adist	distort1 afog, 1.8, .2, .004, -.2
adel	delayr	.02
adel1	deltap3	.003
adel2	deltap3	.0047
adel3	deltap3	.0055
adel4	deltap3	.0062
adel5	deltap3	.007
adel6	deltap3	.0081
	delayw	afog

adell	=	(adel + adel1 + adel3 + adel5)/4
adelr	=	(adel + adel2 + adel4 + adel6)/4
;alim	limit	aplk, -.1 * 0dbfs, .1 * 0dbfs
;ares	resonr	alim, 800, 30, 1
ascll	=	adell * kenv
asclr	=	adelr * kenv
aleft	=	adell * kenv
aright	=	adelr * kenv
adistl	distort1 ascll, 1.8, .1, .4, -.2
adistr	distort1 asclr, 1.8, .1, .4, -.2
aleft	=	adistl
aright	=	adistr
	outrg	1, aleft, aright
	endin


	instr 33

aleft	init	0
aright	init	0
idur	=	p3
iamp	=	ampdb(p4) ;* .8
ifreq	=	p5
kfreq	init	ifreq
;kswitch	=	(kfreq > 294 ? 1 : 0)
aenv	transeg	0, .004, 1, iamp, p3-.01, 1, .8*iamp, .006, 1, 0
aplk1	pluck	1, kfreq, ifreq, 11, 3, 0.0001
;aplk2	pluck	1, kfreq * 1.001, ifreq, 11, 3, .0003
;aplk3	pluck	1, kfreq * .995, ifreq, 11, 3, .0004
;aosc	oscil	1, ifreq, 11
;afilt	rezzy	aosc, 350, 20
kfc	=	ifreq * 3
;kfc	=	250
;aplk	=	(aplk1+aplk2+aplk3)/3
afilt	rezzy	aplk1, kfc, 5
adist	distort1 afilt, 1.6, .4, .2, -.03
ascl	=	adist * aenv
aleft	=	ascl
aright	=	aleft

	outrg	1, aleft, aright
	endin


	instr 44
	endin


	instr 55

aleft	init	0
aright	init	0
	outrg	1, aleft, aright
	endin


	instr 66

aleft	init	0
aright	init	0
	outrg	1, aleft, aright
	endin


	instr 77

aleft	init	0
aright	init	0
	outrg	1, aleft, aright
	endin


	instr 88

aleft	init	0
aright	init	0
	outrg	1, aleft, aright
	endin




</CsInstruments>
<CsScore>
f1 3600 8 10 1
f2 0 512 10 1 1 1 1
f3 0 512 10 1 .2 .4
f11 0 512 10 1 .3 .1 .07
;f22 0 512 -7 0 16 1 224 1 32 -1 224 -1 16 0
f22 0 512 10 1 .2 .3; .12 ;.5
f23 0 512 19 .5 .5 270 .5
;q11 0
;q22 0
;q33 0
#define I2P01(T) #
i2 [$T + 6.667] .333 74
i2 [$T + 7] .667 77
i2 [$T + 7.667] .333 80
#
#define I2P02(T) #
i2 [$T + .667] .333 80
i2 [$T + 1] .667 84
i2 [$T + 1.667] .333 80
i2 [$T + 2] 1 86
i2 [$T + 3] 1.667 86
i2 [$T + 4.667] .333 80
i2 [$T + 5] .667 84
i2 [$T + 5.667] 1 80
i2 [$T + 6.667] .333 80
i2 [$T + 7] 1 84
#

#define I3P01(T) #
i3 [$T + 0] .65 90
i3 [$T + 2] .65 90
i3 [$T + 3] .65 90
i3 [$T + 4] .65 90
i3 [$T + 6] .65 90
#

#define I4P01(T) #
i4 [$T + 0] .667 74
i4 [$T + .667] .333 69
i4 [$T + 1] .667 74
i4 [$T + 1.667] .333 69
i4 [$T + 2] .667 74
i4 [$T + 2.667] .333 69
i4 [$T + 3] .667 74
i4 [$T + 3.667] .333 69
i4 [$T + 4] .667 74
i4 [$T + 4.667] .333 69
i4 [$T + 5] .667 74
i4 [$T + 5.667] .333 69
i4 [$T + 6] .667 74
i4 [$T + 6.667] .333 69
i4 [$T + 7] .667 74
i4 [$T + 7.667] .333 69
#
#define P01(T) #
i2 [$T + .667]     .333    80
i2 [$T + 1] .667 84
i2 [$T + 1.667] .333 80
i2 [$T + 2] 1 86
i2 [$T + 3] 1.667 86
i2 [$T + 4.667] .333 80
i2 [$T + 5] .667 84
i2 [$T + 5.667] 1 80
i2 [$T + 6.667] .333 80
i2 [$T + 7] 1 84

i3 [$T + 0] .65 90
i3 [$T + 2] .65 90
i3 [$T + 3] .65 90
i3 [$T + 4] .65 90
i3 [$T + 6] .65 90

i4 [$T + 0] .667 74
i4 [$T + .667] .333 69
i4 [$T + 1] .667 74
i4 [$T + 1.667] .333 69
i4 [$T + 2] .667 74
i4 [$T + 2.667] .333 69
i4 [$T + 3] .667 74
i4 [$T + 3.667] .333 69
i4 [$T + 4] .667 74
i4 [$T + 4.667] .333 69
i4 [$T + 5] .667 74
i4 [$T + 5.667] .333 69
i4 [$T + 6] .667 74
i4 [$T + 6.667] .333 69
i4 [$T + 7] .667 74
i4 [$T + 7.667] .333 69
#

;i1	0	1

i44 [$RATSTART * 60/116] 400

$I3P01(0)
$I3P01(8)
$I2P01(8)
$P01(16)
$P01(24)
$P01(32)
$P01(40)
$P01(48)
$P01(56)
$P01(64)
$P01(72)
$P01(80)
$P01(88)
$P01(96)
$P01(104)
$P01(112)
$P01(120)
$P01(128)
$P01(136)
$P01(144)
$P01(152)
$P01(160)
$P01(168)
$P01(176)
$P01(184)
$P01(192)
$P01(200)
$P01(208)
$P01(216)
$P01(224)
$P01(232)
$P01(240)
$P01(248)
$P01(256)
$P01(264)
$P01(272)
$P01(280)
$P01(288)
$P01(296)
$P01(304)
$P01(312)
$P01(320)
$P01(328)
$P01(336)
$P01(344)
$P01(352)
$P01(360)
$P01(368)


</CsScore>
</CsoundSynthesizer>
