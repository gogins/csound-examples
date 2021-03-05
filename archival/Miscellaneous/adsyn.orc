	sr = 11025
	kr = 735
	ksmps = 15

;	sr = 10000
;	kr = 1000
;	ksmps = 10
	instr 1
a1	adsyn	1, 1, 1, "ads.medlab.28.256.150"
;a1	adsyn	1, 1, 1, "ads.boseyC#4"
;a1	adsyn	1, 1, 1, "ads.cello.pizz"
;a1	adsyn	1, 1, 1, "ads.violin"
;a1	adsyn	1, 1, 1, "ads.guit"
;a1	adsyn	1, 1, 1, "ads.sine440"
	out	a1
;	display a1, .02, 1
	endin
