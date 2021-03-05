gi2p01	ftgen	0, 0, 64, -2, \
2, .667, .333, 80, \
2, 1, .667, 84, \
2, 1.667, .333, 80, \
2, 2, 1, 86, \
2, 3, 1.667, 86, \
2, 4.667, .333, 80, \
2, 5, .667, 84, \
2, 5.667, 1, 80, \
2, 6.667, .333, 80, \
2, 7, 1, 84, -1, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
gi3p01	ftgen	0, 0, 32, -2, \
3, 0, .65, 90, \
3, 2, .65, 90, \
3, 3, .65, 90, \
3, 4, .65, 90, \
3, 6, .65, 90, \
3, 8, .65, 90, -1, 8, -1, -1, -1, -1, -1, -1;, -1, -1, -1, -1
gi4p01	ftgen	0, 0, 32, -2, \
4, 0, .667, 74, \
4, .667, .333, 69, \
4, 1, .667, 74, \
4, 1.667, .333, 69, \
4, 2, .667, 74, -1, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1;, -1, -1, -1, -1
;gi2pat01	ftgen	0, 0, 64, -2, 2, 0, .25, 2, .6667, .25, 2, 1, .25, 2, 1.6667, .25, 2, 2, .25, 2, 4, .25, 2, 6, .25, 2, 8, .25, 2, 8.6667, .25, 2, 9, .25, 2, 9.6667, .25, 2, 10, .25, 2, 12, .25, 2, 14, .25, -1, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
gisnare ftgen   0, 0, 512, 10, 1

	instr 1
	ihold
ktrig2  init    0
ktrig3  init    0
ktrig4  init    0
ktrig5  init    0
ktrig6  init    0
ktrig7  init    0
ktrig8  init    0
ktrig9  init    0

k2p1	init	0
k2p2	init	0
k2p3	init	0
k2p4	init	0
k3p1	init	0
k3p2	init	0
k3p3	init	0
k3p4	init	0
k4p1	init	0
k4p2	init	0
k4p3	init	0
k4p4	init	0
;kptr	chnget	"ptr"
;kplayin	chnget	"play"
;kplayin init    1
kplayin init    0
kpat    init    0
kplay   =       (kplayin & 1)
km2     =       1-((kplayin & 2)/2)
km3     =       1-((kplayin & 4)/4)
km4     =       1-((kplayin & 8)/8)
km5     =       1-((kplayin & 16)/16)
km6     =       1-((kplayin & 32)/32)
km7     =       1-((kplayin & 64)/64)
km8     =       1-((kplayin & 128)/128)
km9     =       1-((kplayin & 256)/256)

;kpat    init    1
if (kplay==0) goto noseq
if (kpat!=1) goto not01

kptr    init    0
;kptr    =       gitcursor
;        printk  60, kptr
;        printk2 kptr

ktr2	timedseq kptr, gi2p01, k2p1, k2p2, k2p3, k2p4
ktr3	timedseq kptr, gi3p01, k3p1, k3p2, k3p3, k3p4
ktr4	timedseq kptr, gi4p01, k4p1, k4p2, k4p3, k4p4
ktr2    =       ktr2 * km2
ktr3    =       ktr3 * km3
ktr4    =       ktr4 * km4
not01:

;if (kpat!=2) goto not02
;ktr2	timedseq kptr, gi2p02, k2p1, k2p2, k2p3, k2p4
;ktr3    timedseq kptr, gi3p02, k3p1, k3p2, k3p3, k3p4
;ktr4	timedseq kptr, gi4p02, k4p1, k4p2, k4p3, k4p4
;ktr2    =       ktr2 * km2
;ktr3    =       ktr3 * km3
;ktr4    =       ktr4 * km4
;not02:

	schedkwhen ktr2, 0, 20, 2, 0, k2p3, k2p4
	schedkwhen ktr3, 0, 20, 3, 0, k3p3, k3p4
	schedkwhen ktr4, 0, 20, 4, 0, k4p3, k4p4
;kout	changed	k2p2

noseq:
	endin

	instr 2         ;snarish
iamp	=	ampdb(p4)* .25
;iamp	=	ampdb(90)
aenv	transeg	0, .001, 0, iamp, .1, 2, 0, p3-.152, 0, 0
ans	noise	1, .2
ans     atone   ans, 500
kfreq	transeg	80, p3, 1, 50
;aosc	oscil	1, kfreq + ans, 2
asnare  pluck   1, kfreq, 400, gisnare, 3, .65
;amix	=	aosc + ans * .08
amix    =       asnare + ans * .8
alim	limit	amix, -.3, .3
afilt	atone	alim, 300
ascl	=	aenv * afilt * 1.5

adel	delayr	.2
atap1	deltap	.003
atap2	deltap	.005
atap3	deltap	.006
atap4	deltap	.007

	delayw	ascl
al	=	atap1*.35 + atap3*.15
ar	=	atap2*.7 + atap4*.3
anull   init    0
        outs    al, ar
;        out32   anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,al,ar,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull
;	outrg	17, al, ar
;        outrg   1, al, ar
;aenv	transeg	0, .01, 1, 1, .2, 1, 0
;ans	noise	0dbfs, .7
;ascl	=	ans * aenv
;	outrg	1, ascl, ascl
	endin

	instr 3         ;bass drumish

ans	noise	1, .99
iamp	=	ampdb(p4) * .2
aamp	transeg	0, .002, 1, iamp, p3-.002, 2, 0
anse	transeg	0, .002, 1, iamp, p3-.01, 1, 0, .008, 0, 0
kfreq	expseg	80, p3, 60
kfreq2  expseg  60, p3, 50
asin	oscil	1, kfreq + ans * 20, 3
asin2   oscil   1, kfreq2 + ans * 20, 3
;aenv	=	asin * anse
asin    =       .5 * (asin + asin2)
adist	distort1 asin, .3, .2, 1, -.5
afilt	rezzy	adist, 100, 10
aenv	=	afilt * aamp
att	=	ans * anse
katt	init	.02
kfilt	init	1
klow	=	-.4 * 0dbfs
khigh	=	.04 * 0dbfs

amix	=	katt * att + kfilt * aenv
aclip	limit	amix, klow, khigh
ascl	=	aclip * 9
anull   init    0
        outs    ascl, ascl
;        out32   anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,ascl,ascl,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull
;	outrg	19, ascl, ascl
;        outrg   1, ascl, ascl
	endin

	instr 4         ;rideish

iamp	=	ampdb(p4) * .25
anos	noise	1, 0
aenv	transeg	0, .002, 1, iamp, .02, 1, iamp * .1, p3-.022, 2, 0
aenvh	transeg	0, .005, 1, iamp, .025, 1, iamp * .2, p3-.025, 1, 0
ah	reson	anos, 3000, 30
al	reson	anos, 800, 80
am      reson   anos, 3800, 30
ah      atone   anos, 100
ahi	=	ah * aenvh * .03
alo	=	al * aenv * .05
amid    =       am * aenvh * .05
acym	=	.333 * (ahi + alo + amid)
anull   init    0
        outs    acym, acym
;        out32   anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull,acym,acym,anull,anull,anull,anull,anull,anull,anull,anull,anull,anull
;	outrg	21, acym, acym
;        outrg   1, acym, acym
	endin
