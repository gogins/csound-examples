sr = 44100
kr = 44100
ksmps = 1
nchnls = 2

#define INTERP(a1' am' a2' b1' b2') #(($b2 - $b1)*($am - $a1)/($a2 - $a1)+$b1)#

;
; Gardner reverb uses zaw system audio channel 1
;

	zakinit 300,300

givarpulsetbl_1 ftgen 299, 0, 8193, -7, -1.0, 192, 1.0, 8000, 1.0
givarpulsetbl_2 ftgen 298, 0, 8193, -7, 0.0, 4042, 0.0, 100, -2.0, 4050, -2.0
;  856: c4  614: c5  618: c6 
gifiltdeltabl ftgen   297, 0.0, 8193, -7, 0.000000, 1431, 0.000000, 856, 0.000000, 614, 0.000000, 618, 0.000020, 617, 0.000040, 2008, 0.000000, 2048, 0.000000

;
; Tables for filter delay of mywvguide
;
; Table for frequency 30.000000
gitab ftgen 200, 0.0, 8193, -7, 0.000313, 3817, 0.000313, 822, 0.000156, 822, 0.000052, 822, 0.000052, 822, 0.000000, 822, 0.000000, 265, 0.000000
; Table for frequency 60.000000
gitab ftgen 201, 0.0, 8193, -7, 0.000313, 3817, 0.000313, 822, 0.000156, 822, 0.000078, 822, 0.000026, 822, 0.000000, 822, 0.000000, 265, 0.000000
; Table for frequency 120.000000
gitab ftgen 202, 0.0, 8193, -7, 0.000299, 3817, 0.000299, 822, 0.000143, 822, 0.000065, 822, 0.000026, 822, 0.000013, 822, 0.000000, 265, 0.000000
; Table for frequency 240.000000
gitab ftgen 203, 0.0, 8193, -7, 0.000286, 3817, 0.000286, 822, 0.000143, 822, 0.000072, 822, 0.000033, 822, 0.000013, 822, 0.000007, 265, 0.000007
; Table for frequency 480.000000
gitab ftgen 204, 0.0, 8193, -7, 0.000244, 3817, 0.000244, 822, 0.000137, 822, 0.000068, 822, 0.000029, 822, 0.000013, 822, 0.000007, 265, 0.000007
; Table for frequency 960.000000
gitab ftgen 205, 0.0, 8193, -7, 0.000116, 4591, 0.000116, 822, 0.000067, 822, 0.000031, 822, 0.000013, 822, 0.000005, 313, 0.000005
; Table for frequency 1920.000000
gitab ftgen 206, 0.0, 8193, -7, 0.000053, 5413, 0.000053, 822, 0.000028, 822, 0.000013, 822, 0.000005, 313, 0.000005
; Table for frequency 3840.000000
gitab ftgen 207, 0.0, 8193, -7, 0.000023, 6235, 0.000023, 822, 0.000011, 822, 0.000006, 313, 0.000006


;
; Table for comparator - when looked up with
; 
gicompfn ftgen 250, 0.0, 8193, -7, 1.0, 4000, 1.0,  1, 0.0, 4191,  0.0


;
;
; Table for hamming function
;
gihammtab  ftgen 251, 0.0, 8193, 20, 2, 1
;
; Table for sin function
;
gisin	   ftgen 252, 0.0, 8193, 10, 1

;
; The following for reverb 2314
;
gifeed    =         .5 
gilp1     =         1/10
gilp2     =         1/23
gilp3     =         1/41
giroll    =         3000

;
; for setupham opcode to ensure it does it once
; 
gisetupham = 0

; -----------------------------------------------------------
; Opcode for looking up delay in tables
; -----------------------------------------------------------
opcode lookupdel, k, kki
	kfreq, kcutoff, ibasetbl xin

	; Must convert ifreq into a table number from ibasetbl
	; to ibasetbl + 7
	il30 = log( 30.0 )
	il3840 = log( 3840.0 )
	kfreqlog = log( kfreq )
	ktabfrac = $INTERP(il30'kfreqlog'il3840'ibasetbl'ibasetbl+7')
	ktab1 = int(ktabfrac)
	ktab2 = ktab1 + 1

	; Computing table index.  We must convert the cutoff into
	; a table range from 0 to 1.  Table represents freqs of 20.0
	; to 20000.0 stored logarithmically.
	il20	= log( 20.0 )
	il20k 	= log( 20000.0 )
	kcutlog = log( kcutoff )
	kindx	= $INTERP(il20'kcutlog'il20k'0.0'1.0' )

	kdel1	tableikt kindx, ktab1, 1
	kdel2	tableikt kindx, ktab2, 1
	kdel	= $INTERP(ktab1'ktabfrac'ktab2'kdel1'kdel2')

	xout kdel
endop

; -----------------------------------------------------------
; variable pulse width opcode
; -----------------------------------------------------------
;
;   asig varpulse  kwidth, kfrq
;
;
;  width varies from 0.0 to 1.0 - should probably stay
;  in region 0.05 to 0.5 to be useful
;
opcode varpulse, a, kk

	kwidth, kfrq  xin
	koffset = (1-kwidth)/2.0
	aphs	phasor kfrq
	aindx1  = aphs/2.0
	aindx2	= aphs/2.0 + koffset
	asig1	tablei aindx1, givarpulsetbl_1, 1  ; normalized access
	asig2	tablei aindx2, givarpulsetbl_2, 1
	asig	= asig1 + asig2
		xout asig

endop

; ------------------------------------------------------------
; varhammer - an opcode that makes a variable shaped piano hammer
;             signal
; ------------------------------------------------------------
;
; aout  varhammer  kamp, kfrq, kfrac, kwid, isinfn
;
opcode varhammer, a, kkkki

	kamp, kfrq, kfrac, kwid, isinfn  xin

	; <- 1 - ><-  2    -><-- 3  --><-- 4 -- ><-- 5 -->
	; flat    pos bump   flat      neg bump  flat
	;
	; pos bump:  from -0.25 to +0.75 phase in isinfn table,
	;  with 1.0 added

	ks1 = 0.0
	ks2 = kfrac - kwid/2.0
	ks3 = kfrac + kwid/2.0
	ks4 = 1.0 - kfrac - kwid/2.0
	ks5 = 1.0 - kfrac + kwid/2.0

	; output of phasor in range 0 <= aphs < 1
	aphs	phasor kfrq

	; Compute truth values: aseg1 = 1.0 if we're in segment 1,
	;                          otherwise = 0.0
	; Start by computing difference values: aseg1orless if we're
	; in segment 1 or before it

	;	aseg1orless = aphs <= ks2
	; OR	aseg1orless = ks2 - aphs >= 0
	;  table: normalized, no offset, wraparound mode
	aseg1orless	table (ks2 - aphs)/10.0, gicompfn, 1, 0, 1
	aseg2orless	table (ks3 - aphs)/10.0, gicompfn, 1, 0, 1
	aseg3orless	table (ks4 - aphs)/10.0, gicompfn, 1, 0, 1
	aseg4orless	table (ks5 - aphs)/10.0, gicompfn, 1, 0, 1

	; The states are
	;    variables asegXorless  1    2   3   4  
	; Seg that it's in:
	;   1                       1    1   1   1   
	;   2                       0    1   1   1   
	;   3                       0    0   1   1   
	;   4                       0    0   0   1
	;   5                       0    0   0   0

	ainseg1 = aseg1orless * aseg2orless * aseg3orless * aseg4orless

	; subtract 1 from 1:  in the true state -1 * 1 * 1 * 1
	ainseg2 = (aseg1orless-1) * aseg2orless * aseg3orless * aseg4orless
	ainseg2 = - ainseg2

	; subtract 1 from 1 and 2 : in the true state -1*-1*1*1
	ainseg3 = (aseg1orless-1) * (aseg2orless-1) * aseg3orless*aseg4orless

	; subtract 1 from 1, 2, and 3: in true state -1*-1*-1*1
	ainseg4 = (aseg1orless-1)*(aseg2orless-1)*(aseg3orless-1)*aseg4orless
	ainseg4 = -ainseg4

	; subtract 1 from 1, 2, 3, and 4: in true state -1*-1*-1*-1
	ainseg5 = (aseg1orless-1)*(aseg2orless-1)*(aseg3orless-1)*                                 (aseg4orless-1)

	; Compute first bump
	aphsbump1 = $INTERP(ks2'aphs'ks3'-0.25'0.75')
	abump1	tablei aphsbump1, isinfn, 1, 0, 1
	abump1 = abump1 + 1.0
	
	; Compute second bump
	aphsbump2 = $INTERP(ks4'aphs'ks5'-0.25'0.75')
	abump2	tablei aphsbump2, isinfn, 1, 0, 1
	abump2	= - abump2 - 1

	aout = abump1*ainseg2*kamp + abump2*ainseg4*kamp

		xout aout

endop



; ------------------------------------------------------------
; my better tuned waveguide resonator using wguide1
; ------------------------------------------------------------
;
; aout mywguide1 asig, kfrq, kcutoff, kfdback
;
opcode mywguide1, a, akkk

icalibfn = gifiltdeltabl


	asig, kfrq, kcutoff, kfdback xin

	kfrqlog = log10( kfrq )
	kx = $INTERP(1.0'kfrqlog'5.0'0.0'1.0') 
	kfiltdel tablei kx, icalibfn, 1
	kinfrq = 1/( 1.0/kfrq - kfiltdel )
	aout	wguide1 asig, kinfrq, kcutoff, kfdback

	xout	aout

endop


; ------------------------------------------------------------
; mywvguide - takes delay as parameter for experimentation
; ------------------------------------------------------------
;
; Fundamental will be near kfrq, but should be in tune at
; kfrq * kmult - but we don't need kmult since we would only
; need that to look up delay, and instead we are taking delay
; as a parameter
;
; Use kasdel as the assumed delay of the filter
;
; aout mywvguide ain, kfrq, kcutoff, kfdback, kasdel
;
opcode mywvguide, a, akkkk

	ain, kfrq, kcutoff, kfdback, kasdel xin

	;	kfiltdel lookupdel kfrq, kcutoff, 200
	kfiltdel = kasdel

	kdel	= 1.0 / kfrq - kfiltdel

	adump	delayr 0.1
	asig	deltapi kdel
	asig	dcblock asig
	afilt	tone asig, kcutoff
		delayw afilt * kfdback + ain

		xout asig

endop

; ------------------------------------------------------------
; mywvguide2 - looks up delay
; ------------------------------------------------------------
;
; Fundamental will be near kfrq, but should be in tune at
; kfrq * kmult - but we don't need kmult since we would only
; need that to look up delay, and instead we are taking delay
; as a parameter
;
; Use kasdel as the assumed delay of the filter
;
; aout mywvguide ain, kfrq, kcutoff, kfdback, kasdel
;
opcode mywvguide2, a, akkkk

	ain, kfrq, kcutoff, kfdback, kasdel xin

	kfiltdel lookupdel kfrq, kcutoff, 200

	kdel	= 1.0 / kfrq - kfiltdel

	adump	delayr 0.1
	asig	deltap kdel
	afilt	tone asig, kcutoff
		delayw afilt * kfdback + ain

		xout asig

endop

; ------------------------------------------------------------
; mywvguide3 - pitch-shifts output, no interpolating tap
; ------------------------------------------------------------
;
; Fundamental will be near kfrq, but should be in tune at
; kfrq * krat 
;
; Use kasdel as the assumed delay of the filter
; Shift output frequency by krat
;
;
; aout mywvguide ain, kfrq, kcutoff, kfdback, kasdel, krat
;
opcode mywvguide3, a, akkkkk,

	ain, kfrq, kcutoff, kfdback, kasdel, krat xin

	kfiltdel = kasdel

	kdel	= 1.0 / kfrq - kfiltdel
	; The following phasor needs kr to equal sr (which it does 
	; anyway because this is a waveguide model with feedback)
	aphs	phasor kfrq * (krat-1.0)
	aphs	= 1.0 - aphs

	adump	delayr 0.1

	amov	deltapx kdel * aphs, 8
	amov2	deltapx kdel * (1.0 + aphs), 8


	asig	deltap kdel
	afilt	dcblock asig
	afilt	tone asig, kcutoff
		delayw afilt * kfdback + ain

		xout amov * aphs + amov2 * (1.0 - aphs)

endop

; ------------------------------------------------------------
; opcode mycomb -  a comb filter with fractional tapping
; ------------------------------------------------------------
;  aout  mycomb  asig, kfrq, irvt
;
opcode mycomb, a, aki

	ain, kfrq, irvt xin

	kfdback = exp( log(0.1)/( irvt * kfrq) )

	kdel = 1.0/kfrq

	anull	delayr 1.0
	aout	deltap3 kdel
		delayw ain + aout * kfdback

		xout aout

endop

; ------------------------------------------------------------
; waveshaping opcode
; ------------------------------------------------------------
;  asig  waveshape  ain, koutamp, ifn
;
;  ain - input waveform - assumes an amplitude up to +- 1.0
;  koutamp - multiplier to get output amplitude
;  ifn - function table containing waveshaping waveform
;
opcode waveshape, a, aki

	ain, koutamp, ifn 	xin
		; Normalize to [-0.5,0.5]
		ain = ain / 2.0
	aout	table3  ain, ifn, 1, 0.5, 1
	aout	dcblock aout
	aout 	= aout * koutamp
;	kdclk	linseg 0.0, 0.05, 1.0, p3-0.1, 1.0, 0.05, 0.0
		xout aout 

endop



; --------------------------------------------------------------
;  Piano hammer signal
; --------------------------------------------------------------
;  Makes a signal idur long: puts in a copy of table ifn at offsets 
;  ifrac and 1.0- ifrac, of width wid
;
;  asig pianoham kamp, idur, ifrac, iwid, ifn
;
;opcode pianoham, a, kiiii
;
;	kamp, idur, ifrac, iwid, ifn  xin
;	idel1 = idur * ( ifrac - iwid/2.0 )
;	idel2 = idur * ( 1.0 - ifrac - iwid/2.0 )
;	iimp = iwid * idur
;
;	asig1	oscil1i idel1, kamp, iimp, ifn
;	asig1	= (asig1 + 1.0)/2.0
;	asig2	oscil1i idel2, kamp, iimp, ifn
;	asig2	= - (asig2 + 1.0)/2.0
;		xout asig1 + asig2
;endop




;------------------------------------------------------------------------
; Early reflection simulator opcode
;------------------------------------------------------------------------
; asig  earlyrefl  ain, kcycle
;
; kcycle is the cycle time of the fundamental frquency in the input signal,
; to allow equal frequency response for different frequencies
;
opcode earlyrefl,  a, ak

	ain, kcycle  xin

	anull	delayr  1.0

	atap1	deltapi kcycle * 1.3
	atap1	buthp atap1, 2000.0

	atap2	deltapi kcycle * 3.3
	atap2	buthp atap2, 1500.0

	atap3	deltapi kcycle * 2.23
	atap3	buthp atap3, 4000.0

	atap4 	deltapi kcycle * 0.2

	atap5	deltapi kcycle * 1.87
	atap5   buthp atap5, 800.0
	
		delayw  ain

	asig	= (atap1 + atap2 + atap3 + atap5)/8.0 + atap4

		xout asig

endop

;------------------------------------------------------------------------
; Table updating opcode
;------------------------------------------------------------------------
; asig tabup  kfrq, inumk, ifn1, ifn2
;
; so on k cycle 0 we make ifn2 from ifn1, and set a mixing value to
; indicate table ifn1.  approaching k cycle inumk we mixing toward
; ifn2.  on k cycle inumk we are mixing fully at ifn2 and we make ifn1.
; approach k cycle inumk*2 we mix toward ifn1
;
;
opcode tabup, a, kiii

	kfrq, inumk, ifn1, ifn2 xin
	print ifn1
	print ifn2

	ktime	timeinstk
	ktime  = ktime-1
	kmod	= ktime % (2 * inumk)
	ilen	= ftlen( ifn1 )
	
	ifiltnum = 150

	; How many table indexes is one audio sample?
	kindlen = 1.0/(kfrq* ilen)
	iaudsamp = 1.0/sr
	kindpersamp = iaudsamp/kindlen

	if kmod != 0 kgoto lab1

	; Here we are ready to copy/process table ifn1 toward ifn2
	kindx = 0
loop1:	kcount = 0
	ksum = 0.0
loop3:	ksig table kindx+ kcount, ifn1, 0, 0, 1    ; wraparound mode
	ksum = ksum + ksig
	kcount = kcount + 1
	if kcount < ifiltnum kgoto loop3

	knew = ksum / ifiltnum
	tablew knew, kindx, ifn2
	kindx = kindx + 1
	if kindx < ilen kgoto loop1

lab1:
	if kmod != inumk kgoto lab2
	
	; Here we are ready to copy/process table ifn2 toward ifn1
	kindx = 0
loop2:	kcount = 0
	ksum = 0.0
loop4:	ksig table kindx+ kcount, ifn2, 0, 0, 1    ; wraparound mode
	ksum = ksum + ksig
	kcount = kcount + 1
	if kcount < ifiltnum kgoto loop4

	knew = ksum / ifiltnum
	tablew knew, kindx, ifn1
	kindx = kindx + 1
	if kindx < ilen kgoto loop2

lab2:

	;
	; Now determine mixing value
	;

	if kmod > inumk-1 kgoto lab3 

	; We are in first part.  at k cycle 0 we are fully at ifn1.
	; at k cycle inumk we are fully at ifn2
	kmixing = $INTERP( 0'kmod'inumk'0.0'1.0')
	kgoto lab4

lab3: 
	; We are in second part. At k cycle inumk we are fully at ifn2.
	; At k cycle inumk*2 we are fully at ifn1.
	kmixing = $INTERP( inumk'kmod'2*inumk'1.0'0.0')
lab4:

	aphs1 	phasor kfrq
	aphs2	phasor kfrq

	asig1	table aphs1, ifn1, 1
	asig2	table aphs2, ifn2, 1

	asig	= (1-kmixing) * asig1 + kmixing * asig2

	xout	asig

endop


;------------------------------------------------------------------------
; Opcode for creating brief bump signals at random intervals
;------------------------------------------------------------------------
;  asig  randbump  ilevel, iavgfrq, ifrqvarmag, ifrqvarfrq
;
; 
opcode randbump, a, iiii

	ilevel, iavgfrq, ifrqvarmag, ifrqvarfrq xin

	iseed	random 0.001, 0.999
	kfrq	randi ifrqvarmag, ifrqvarfrq, iseed
	kfrq	= iavgfrq * ( 1 + kfrq )
	asin	oscili 1.0, kfrq, gisin
	asig	tablei (asin - ilevel)/10.0, gicompfn, 1, 0, 1
	aout	= asig * (asin - ilevel ) / ( 1.0 - ilevel )
		xout aout
endop

;------------------------------------------------------------------------
; Instrument 3 - clear all zak k-channels
;------------------------------------------------------------------------
;i3   time  idur
instr 3
	zkcl 1, 300
endin

;------------------------------------------------------------------------
; Instrument 4 - set a zak k-channel to 1.0 for multiplicative mixing
;------------------------------------------------------------------------
;i4   time idur  ichannel
instr 4

idur = p3
ichannel = p4
		zkw 1.0, ichannel
endin

;------------------------------------------------------------------------
; Envelope 11
;
; Five-point, linear or exponential, multiplicative or additive
; mixing
;
; itype = 0 for linear, itype =1 for exponential
; imix = 0 for additive mixing, imix = 1 for multiplicative mixing
;------------------------------------------------------------------------
;i11  time idur  ia1 it2 ia2 it3 ia3 it4 ia4 ia5  itype imix ienvch
instr 11

idur = p3
ia1 = p4
it2 = p5
ia2 = p6
it3 = p7
ia3 = p8
it4 = p9
ia4 = p10
ia5 = p11
itype = p12
imix = p13
ienvch = p14

; 
; Generate the envelope (linear or exponential)
;
		if itype == 1 goto exp

	kenv	linseg  ia1,  it2, ia2,  it3-it2, ia3,  it4-it3, ia4, idur - it4, ia5
		goto doneseg
exp:
	kenv	expseg  ia1,  it2, ia2,  it3-it2, ia3,  it4-it3, ia4, idur - it4, ia5
doneseg:

;
; Get the current value on the zak k channel
;
	kcur	zkr ienvch

;
; Mix (additive or multiplicative)
;
		if imix == 1 goto mult
		kcur = kcur + kenv
		goto donemult
mult:
		kcur = kcur * kenv
donemult:
;
; Write it to the zak channel
; 
		zkw kcur, ienvch
endin

;------------------------------------------------------------------------
; Envelope 12
;
; Seven-point, linear or exponential, multiplicative or additive
; mixing
;
; itype = 0 for linear, itype =1 for exponential
; imix = 0 for additive mixing, imix = 1 for multiplicative mixing
;------------------------------------------------------------------------
;i12 time idur ia1 it2 ia2 it3 ia3 it4 ia4 it5 ia5 it6 ia6 ia7 itype imix 
;    ienvch
instr 12

idur = p3
ia1 = p4
it2 = p5
ia2 = p6
it3 = p7
ia3 = p8
it4 = p9
ia4 = p10
it5 = p11
ia5 = p12
it6 = p13
ia6 = p14
ia7 = p15
itype = p16
imix = p17
ienvch = p18

; 
; Generate the envelope (linear or exponential)
;
		if itype == 1 goto exp

	kenv	linseg  ia1,  it2, ia2,  it3-it2, ia3,  it4-it3, ia4, it5-it4, ia5,  it6-it5, ia6,  idur-it6, ia7
		goto doneseg
exp:
	kenv	expseg  ia1,  it2, ia2,  it3-it2, ia3,  it4-it3, ia4, it5-it4, ia5,  it6-it5, ia6,  idur-it6, ia7
doneseg:

;
; Get the current value on the zak k channel
;
	kcur	zkr ienvch

;
; Mix (additive or multiplicative)
;
		if imix == 1 goto mult
		kcur = kcur + kenv
		goto donemult
mult:
		kcur = kcur * kenv
donemult:
;
; Write it to the zak channel
; 
		zkw kcur, ienvch
endin

;------------------------------------------------------------------------
; Envelope 13 - attack and decay times
;
; Uses additive mixing.
;------------------------------------------------------------------------
;
; Has attack and decay times.  Rises to 1.0
;
;i13  time idur  iatt idec   ienvch
instr 13 

idur = p3
iatt = p4
idec = p5
ienvch = p6

		if idur > 0 igoto skip
	idur	= -idur
skip:
	kenv	linseg  0.0,   iatt, 1.0,   idur-iatt-idec, 1.0,   idec, 0.0
		zkwm	kenv, ienvch

endin

;------------------------------------------------------------------------
; Envelope 16 - 3-point linear
;
; Uses additive mixing.
;------------------------------------------------------------------------
;
;i16 time idur    ia1   it2    ia2    ia3   ienvch
instr 16

idur = p3
ia1  = p4
it2  = p5
ia2  = p6
ia3 =  p7
ienvch = p8

	kenv	linseg ia1,  it2, ia2,  idur-it2, ia3
		zkwm   kenv, ienvch
endin

;------------------------------------------------------------------------
; Envelope 17 - 3-point exponential
;
; Uses multiplicative mixing.
;------------------------------------------------------------------------
;
;i17 time idur    ia1   it2    ia2    ia3   ienvch
instr 17

idur = p3
ia1  = p4
it2  = p5
ia2  = p6
ia3 =  p7
ienvch = p8

	kenv	expseg ia1,  it2, ia2,  idur-it2, ia3
	kcur	zkr	ienvch
	kenv	= kenv * kcur
		zkw   kenv, ienvch
endin


;------------------------------------------------------------------------
; Envelope 33 - four-point linear
;
; Does not mix.
;------------------------------------------------------------------------
;
; pairs (0, ia1), (it2, ia2), (it3, ia3), (idur, ia4) define
; the four points this visitis
;
;i33 time idur    ia1   it2    ia2    it3   ia3   ia4   ienvch
instr 33

idur = p3
ia1  = p4
it2  = p5
ia2  = p6
it3 = p7
ia3 = p8
ia4 = p9
ienvch = p10

	kenv	linseg ia1,    it2, ia2,    it3-it2, ia3,  idur-it3, ia4
		zkw   kenv, ienvch
endin


;------------------------------------------------------------------------
; Envelope 34 - four-point exponential
;
; Does not mix.
;------------------------------------------------------------------------
;
; pairs (0, ia1), (it2, ia2), (it3, ia3), (idur, ia4) define
; the four points this visitis
;
;i34 time idur    ia1   it2    ia2    it3   ia3   ia4   ienvch
instr 34

idur = p3
ia1  = p4
it2  = p5
ia2  = p6
it3 = p7
ia3 = p8
ia4 = p9
ienvch = p10

		if idur > 0.0 igoto skip
		idur = -idur
	skip:
	kenv	expseg ia1,    it2, ia2,    it3-it2, ia3,  idur-it3, ia4
		zkw   kenv, ienvch
endin

;------------------------------------------------------------------------
; Envelope 36 - four-point linear
;
; Uses additive mixing.
;------------------------------------------------------------------------
;
; pairs (0, ia1), (it2, ia2), (it3, ia3), (idur, ia4) define
; the four points this visitis
;
;i36 time idur    ia1   it2    ia2    it3   ia3   ia4   ienvch
instr 36

idur = p3
ia1  = p4
it2  = p5
ia2  = p6
it3 = p7
ia3 = p8
ia4 = p9
ienvch = p10

		if idur > 0.0 igoto skip
		idur = -idur
	skip:
	kenv	linseg ia1,    it2, ia2,    it3-it2, ia3,  idur-it3, ia4
		zkwm   kenv, ienvch
endin

;------------------------------------------------------------------------
; Envelope 37 - four-point linear
;
; Uses multiplicative mixing.
;------------------------------------------------------------------------
;
; pairs (0, ia1), (it2, ia2), (it3, ia3), (idur, ia4) define
; the four points this visitis
;
;i37 time idur    ia1   it2    ia2    it3   ia3   ia4   ienvch
instr 37

idur = p3
ia1  = p4
it2  = p5
ia2  = p6
it3 = p7
ia3 = p8
ia4 = p9
ienvch = p10

		if idur > 0.0 igoto skip
		idur = -idur
	skip:
	kenv	linseg ia1,    it2, ia2,    it3-it2, ia3,  idur-it3, ia4
	kcur	zkr  ienvch
		zkw   kenv*kcur, ienvch
endin

;------------------------------------------------------------------------
; Envelope 46 - five-point linear
;
; Uses additive mixing.
;------------------------------------------------------------------------
;
; pairs (0, ia1), (it2, ia2), (it3, ia3), (it4, ia4) (idur, ia5) define
; the four points this visitis
;
;i46 time idur    ia1   it2    ia2    it3   ia3   it4 ia4  ia5 ienvch
instr 46

idur = p3
ia1  = p4
it2  = p5
ia2  = p6
it3 = p7
ia3 = p8
it4 = p9
ia4 = p10
ia5 = p11
ienvch = p12

		if idur > 0.0 igoto skip
		idur = -idur
	skip:
	kenv	linseg ia1,    it2, ia2,    it3-it2, ia3,  it4-it3, ia4,                                       idur-it4, ia5
		zkwm   kenv, ienvch
endin

;------------------------------------------------------------------------
; table reading envelope - 51
;
; Writes with additive mixing.
;------------------------------------------------------------------------
;i51   time  idur  ifntab  ienvch
instr 51

idur = p3
ifntab = p4
ienvch = p5

	kenv	oscil3 1.0, 1.0/idur, ifntab
		zkwm   kenv, ienvch

endin

;------------------------------------------------------------------------
; Mix a channel into another channel envelope - 99
;------------------------------------------------------------------------
; imix = 0 for additive mixing, imix = 1 for multiplicative mixing
;
;i99 time idur isrcch idestch imix
instr 99

idur = p3
isrcch = p4
idestch = p5
imix = p6

	kin	zkr isrcch
	kdest	zkr idestch

	if imix == 1 goto mult

	kdest	= kdest + kin
		goto done
mult:
	kdest	= kdest * kin
done:
		zkw kdest, idestch
endin



;------------------------------------------------------------------------
; instr 102 - bandpassed noise source for piano hammer
;   additive mixing into audio channel
;------------------------------------------------------------------------

;i102  time  idur  iampdb  iatt  idec  ifrq  ibw ioutch  
instr 102

idur = p3
iampdb = ampdb( p4 )
iatt = p5
idec = p6
ifrq = p7
ibw = p8
ioutch = p9

	asig	trirand iampdb * 10.0
	asig 	butbp asig, ifrq, ibw
	asig 	butbp asig, ifrq, ibw
	kenv	linseg 0.0,  iatt, 1.0,  idec, 0.0,  idur-idec-iatt, 0.0
	asig	= asig * kenv
		zawm  asig, ioutch

endin


;------------------------------------------------------------------------
;
; "basic_pluck" Basic use of pluck opcode
;------------------------------------------------------------------------
; 
;
;i101   t   dur iampdb   ifqhz   ipan  iwet
;instr 101;;;
;
;idur = p3
;iamp = ampdb( p4 )
;ifq = p5
;ipan = p6
;iwet = p7
;
;	kenv 	linseg 1.0, p3 - 0.05, 1.0, 0.05, 0.0
;	a1 	pluck iamp*kenv, ifq, ifq, 0, 1
;	a1	butlp a1, 2000
;	awet	butlp a1, 1000
;		zawm iwet*awet, 1
;		outs (1.0-iwet )*(1.0-ipan) * a1, (1.0-iwet)*ipan * a1
;endin


;------------------------------------------------------------------------
; instrument 111 - use of repluck
;------------------------------------------------------------------------
;i111 time idur iampdb  ifrqpch ipan iwet
instr 111

idur = p3
iamp = ampdb( p4 )
ifrq = cpspch( p5 )
ipan = p6
iwet = p7

ipluck = 0.13 + birnd( 0.01 )
ipickup = 0.07 + birnd( 0.01 )
;ifrq = ifrq * ( 1.0 + birnd( 0.002 ) )
ifrq = ifrq * 1.00

	aexc	= 0.0
	aout 	repluck ipluck, iamp, ifrq, ipickup, 0.6, aexc
	kenv	linseg 0.0, 0.0005, 1.0, idur-0.0505,  1.0, 0.05, 0.0
	aout	= aout * kenv * 5.0
	arvb	butlp aout, 1000.0
		zawm iwet* arvb, 1
		outs (1.0 - iwet )*ipan*aout, (1.0-iwet)*(1.0 - ipan)*aout

endin



;------------------------------------------------------------------------
;
;  instrument 121 "basic wgbowedbar"
;------------------------------------------------------------------------
;i121  time  idur  iamp  ifreq   ipos  ibowpres  ipan  iwet
instr 121

idur  = p3
iamp  = ampdb( p4 )
ifreq = cpspch( p5 )
ipos  = p6
ibowpres = p7
ipan  = p8
iwet  = p9

	igain	= 0.809
	kamp	linseg  0.0,    0.01, iamp,    idur-0.02, iamp,   0.01, 0.0
;	aout 	wgbow kamp, ifreq, ibowpres, ipos, 0, 0, 1
;	aout	wgbowedbar  kamp, ifreq, ipos, ibowpres, igain
	aout	wgclar		 kamp, ifreq, -0.3, 0.1, 0.1, 0.0, 0.0, 0.0,1
		print ifreq
		zaw  aout*iwet, 1
		outs aout, aout
;		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin


;----------------------------------------------------------------------------
; Instrument 141 - waveguide resonator w/random freq modulation
;----------------------------------------------------------------------------
;i141  time   idur  iampdb   ifrq ifeedback   ienvch icutenvch ifiltenvch ifn
;      ipan  iwet
instr 141

idur = p3
iamp = ampdb( p4 )
ifrq = cpspch( p5 )
ifeedback = p6
ienvch    = p7
icutenvch = p8  ; the zak channel used for reading the cutoff envelope
ifiltenvch  = p9
ifn  = p10
ipan  = p11
iwet  = p12


	; Modify amplitude to account for frequency dependence of resonators
	; and to bring into more expected range
	iamp 	= iamp * ifrq / 1000.0

	kmod	randi 0.003, 3.0
;	amod	butlp	amod, 2.0
;	amod 	dcblock	amod

	asig	oscili	iamp, ifrq *(1+ kmod), ifn
        kfiltenv zkr    ifiltenvch
	asig    butlp   asig, kfiltenv
	kcutenv zkr     icutenvch
	;	asig	wguide1	asig, ifrq, kcutenv, ifeedback
	asig	wguide1	asig, ifrq, kcutenv, ifeedback
	kamp	zkr	ienvch
	asig	= asig * kamp
		zaw	asig*iwet, 1
		outs 	(1.0-ipan)*(1.0-iwet)*asig, ipan*(1.0-iwet)*asig

endin

;----------------------------------------------------------------------------
; Instrument 142 - waveguide resonator w/random freq modulation
;   and frequencies controlled through envelopes
;----------------------------------------------------------------------------
;i142  time   idur  iampdb   ifeedback   ienvch icutenvch ifiltenvch 
;      ioscfrqenvch iwvgdfrqenvch ifn  ipan  iwet
instr 142

idur = p3
iamp = ampdb( p4 )
ifeedback = p5
ienvch    = p6
icutenvch = p7  
ifiltenvch  = p8
ioscfrqenvch = p9
iwvgdfrqenvch = p10
ifn  = p11
ipan  = p12
iwet  = p13

	; 
	; Read the oscillator frequency
	;
	koscfrq	zkr	ioscfrqenvch

	; Modify amplitude to account for frequency dependence of resonators
	; and to bring into more expected range
	koscamp	= iamp * koscfrq / 1000.0

	; Oscillate at koscfrq with a small random variation

	kmod	randi 0.001, 3.0
	asig	oscili	koscamp, koscfrq *(1+ kmod), ifn

	; Filter the oscillator output

        kfiltenv zkr    ifiltenvch
	asig    butlp   asig, kfiltenv

	; Run the signal into the waveguide, using kwvgdfrq as the 
	; waveguide frequency and kcutenv as the waveguide cutoff

	kwvgdfrq zkr	iwvgdfrqenvch
	kcutenv zkr     icutenvch
	asig	wguide1	asig, kwvgdfrq, kcutenv, ifeedback

	; Apply amplitude envelope

	kamp	zkr	ienvch
	asig	= asig * kamp
	
	; Write to reverb and direct output channels

		zaw	asig*iwet, 1
		outs 	(1.0-ipan)*(1.0-iwet)*asig, ipan*(1.0-iwet)*asig

endin

;----------------------------------------------------------------------------
; Instrument 143 - waveguide resonator w/random freq modulation
;   and pulse width control and frequencies controlled through env
;----------------------------------------------------------------------------
;i143  time   idur  iampdb   ifeedback   ienvch icutenvch iwidthenvch
;      ioscfrqch iwvgdfrqch ipan  iwet
instr 143

idur = p3
iamp = ampdb( p4 )
ifeedback = p5
ienvch    = p6
icutenvch = p7  ; the zak channel used for reading the cutoff envelope
iwidthenvch  = p8
ioscfrqch    = p9
iwvgdfrqch   = p10
ipan  = p11
iwet  = p12

	koscfrq zkr ioscfrqch

	; Modify amplitude to bring into more expected range
	koscamp	= iamp / 2.5

	iseed   random 0.0, 0.99	
	kmod	randi 0.003, 3.0, iseed 

	kwdth	zkr iwidthenvch
	asig	varpulse kwdth, koscfrq*(1+kmod)
	asig    = asig * koscamp
	asig    butlp   asig, 6000
	kcutenv zkr     icutenvch
	kwgfrq  zkr	iwvgdfrqch
	if kwgfrq > 10.0 goto skip143 
		kwgfrq 	= 10.0
		; p2 = 95.849 is one problem
skip143:
	asig	wguide1	asig, kwgfrq, kcutenv*kwgfrq, ifeedback
	asig	dcblock asig
	;	asig	balance asigo, asig
	kamp	zkr	ienvch
	asig	= asig * kamp
		zawm	asig*iwet, 1
		outs 	(1.0-ipan)*(1.0-iwet)*asig, ipan*(1.0-iwet)*asig

endin

;----------------------------------------------------------------------------
; Instrument 144 - like 143 but modified to have hard-coded envelopes
;   and send wet signal to specified rvbch - and handle accent
;----------------------------------------------------------------------------
; iaccent = 1 means hard attack
; iaccent = 0 means normal attack
;
;i144  time   idur  iampdb   ifrqhz ifeedback  ipan  iwet irvbch iaccent
instr 144

idur = p3
iamp = ampdb( p4 )
ifrqhz = p5
ifeedback = p6
ipan  = p7
iwet  = p8
irvbch = p9
iaccent = p10

if iaccent == 1 then
	iatt = 0.01
else
	iatt = 0.04
endif
itail = 0.06
iaccentatt = 0.2


	iseed   random 0.0, 0.99	
	kmod	randi 0.003, 3.0, iseed 

	;
	; Pulse width envelope
	;
	kwdth	expseg 0.11, idur/3.0, 0.08, 2.0*idur/3.0, 0.11
	;
	; Add modified pulse width for possible accent
	kwdth2	linseg -0.03, iaccentatt, 0.0
	kwdth2  = kwdth2 * iaccent
	kwdth = kwdth + kwdth2


	asig	varpulse kwdth, ifrqhz*(1+kmod)
	asig    = asig * iamp / 5.0
	asig    butlp   asig, 6000

	; Modify amplitude of driving signal for accent
	kenv1	linseg 0.5, iaccentatt * 1.5, 0.0
	kenv1	= (kenv1 * iaccent) + 1.0
	asig	= asig * kenv1
	

	; Cutoff envelope
	kcutenv expseg 2.0, idur/3.0, 6.0, 2.0*idur/3.0, 2.0

	; Modified cutoff envelope for accent
	kcutenv2 linseg 1.0, iaccentatt, 0.0
	kcutenv2 = kcutenv2 * iaccent
	kcutenv = kcutenv * ( 1.0 + kcutenv2 )

	asig	wguide1	asig, ifrqhz, kcutenv*ifrqhz, ifeedback
	asig	dcblock asig

	; Amplitude envelop
	kamp	linseg 0.0, iatt, 1.0, idur-iatt-itail, 1.0, itail, 0.0

	asig	= asig * kamp
		zawm	asig*iwet, irvbch
		outs 	(1.0-ipan)*(1.0-iwet)*asig, ipan*(1.0-iwet)*asig

endin

;----------------------------------------------------------------------------
; waveshaping instrument 201
;
; two tables
;
; Controlled by envelopes for source wave amplitude for each table,output wave 
; amplitude scaling for each table, weighting between tables, frequency
;
; When input on iweightch channel is 0, it weights all the way toward
; table 1, and when input is 1, weights all the way toward table 2.
;----------------------------------------------------------------------------
;i201  time  idur  isrcamp1ch isrcamp2ch ioutamp1ch ioutamp2ch  ifrqch  
;        iweightch ifwvshp1 ifwvshp2 ifn ipan iwet
instr 201

idur = p3
isrcamp1ch = p4
isrcamp2ch = p5
ioutamp1ch = p6
ioutamp2ch = p7
ifrqch = p8
iweightch = p9
ifwvshp1 = p10
ifwvshp2 = p11
ifn = p12
ipan = p13
iwet = p14

	ksrcamp1 zkr isrcamp1ch
	ksrcamp2 zkr isrcamp2ch
	kfrq	zkr ifrqch
	koutamp1 zkr ioutamp1ch
	koutamp2 zkr ioutamp2ch

	aosc	oscili 1.0, kfrq, ifn

	awv1	waveshape aosc*ksrcamp1, koutamp1, ifwvshp1
	;	awv2	waveshape aosc*ksrcamp2, koutamp2, ifwvshp2
	awv2	= 0.0

	kweight	zkr iweightch
	aout	= (1.0-kweight)*awv1 + kweight*awv2
		zawm aout * iwet, 1
		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin

;----------------------------------------------------------------------------
; waveshaping instrument 211
;
; Uses one waveshaping table and has an offset to that table as well
; as an amplitude
;
; Offset and src_amplitude come in zak k channels.  Offset should range
; -1 to 1.  src_Amplitude should range up to 1, and abs value of src_ampl plus
; absolute value offset should not exceed 1
; 
;----------------------------------------------------------------------------
;i211  time idur isrcampch isrcoffsetch ioutampch ifrqch ifwav ifn ipan iwet
instr 211

idur = p3
isrcampch = p4
isrcoffsetch = p5
ioutampch = p6
ifrqch = p7
ifwav = p8
ifn = p9
ipan = p10
iwet = p11

	kfrq	zkr ifrqch
	ksrcamp	zkr isrcampch
	ksrcoffset zkr isrcoffsetch
	koutamp	zkr ioutampch
	ain	oscili    1.0, kfrq, ifn
	ain	= ain + ksrcoffset
	aout	waveshape ain, koutamp, ifwav
		zawm aout * iwet, 1
		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin




;----------------------------------------------------------------------------
; Instrument for generating tones of known frequency
;----------------------------------------------------------------------------
;i317  time  idur  iampdb  ifrqhz  ifn 
instr 317

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ifn = p6

	kenv	linseg 0.0, 0.1,  1.0, idur-0.2,  1.0, 0.1,  0.0
	asig	oscili iamp, ifrq, ifn
	aout	= asig * kenv

		outs aout, aout

endin



; --------------------------------------------------------------
; Set up a piano hammer function in table ifn
; --------------------------------------------------------------
;
;i319 time idur ifrac iwid  ifn
instr 319

idur = p3
ifrac = p4
iwid = p5
ifn = p6

	ktablen = ftlen( ifn )

	kfrac = ifrac
	kwid = iwid
	ktran1 = (kfrac - kwid/2.0) * ktablen
	ktran2 = (kfrac + kwid/2.0) * ktablen
	ktran3 = (1.0 - kfrac - kwid/2.0 ) * ktablen
	ktran4 = (1.0 - kfrac + kwid/2.0 ) * ktablen

	ktime timeinstk 
	if ktime > 1 kgoto d223

	kindx = 0
loop:   ksig = 0.0
	tablew ksig, kindx, ifn
	kindx = kindx + 1
	if kindx < ktran1 kgoto loop

loop2:  ksig = sin( $INTERP(ktran1'kindx'ktran2'-1.570795'4.712385' ) )
	ksig = (ksig + 1.0)/2.0
	tablew ksig, kindx, ifn
	kindx = kindx + 1
	if kindx < ktran2 kgoto loop2


loop3:   ksig = 0.0
	tablew ksig, kindx, ifn
	kindx = kindx + 1
	if kindx < ktran3 kgoto loop3

loop4:  ksig = sin( $INTERP(ktran3'kindx'ktran4'-1.570795'4.712385' ) )
	ksig = -(ksig + 1.0)/2.0
	ksig = 0.0
	tablew ksig, kindx, ifn
	kindx = kindx + 1
	if kindx < ktran4 kgoto loop4

loop5:  ksig = 0.0
	tablew ksig, kindx, ifn
	kindx = kindx + 1
	if kindx < ktablen kgoto loop5

d223:

endin



;----------------------------------------------------------------------------
; 322 - basic fm piano-like
;----------------------------------------------------------------------------
; iinddec - the level to which the index decays after 10.0 seconds
; iampdec - the level to which the amplitude decays after 10.0 seconds
;i322 time  idur  iampdb  ifrqhz  iatt icm  imaxind iinddec 
;     iampdec   ifn  ipan iwet
instr 322

idur = p3
iamp = ampdb( p4 )
ifrq = p5
iatt = p6
icm = p7
imaxind = p8
iinddec = p9
iampdec = p10
ifn = p11
ipan = p12
iwet = p13

idec = 0.05

	kind	expseg imaxind, 10.0, iinddec

	kenv1	linseg 0.0, iatt, 1.0, idur-iatt-idec, 1.0, idec, 0.0
	kenv2	expseg 1.0, iatt, 1.0, 10.0, iampdec
	kenv	= kenv1 * kenv2
	aout	foscil  iamp, ifrq, 1.0, 1.0/icm, kind, ifn
	aout2	foscil  iamp, ifrq*1.00001, 1.0, 1.0/icm, kind, ifn
	aout3	foscil  iamp, ifrq*0.99999, 1.0, 1.0/icm, kind, ifn
	aout4	foscil  iamp, ifrq*1.00003, 1.0, 1.0/icm, kind, ifn
	aout5	foscil  iamp, ifrq*0.99997, 1.0, 1.0/icm, kind, ifn
	aout =  kenv * (aout + aout2 + aout3 + aout4 + aout5) / 5.0

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin

;----------------------------------------------------------------------------
; instr 325 - generate part of piano attack sound for later use in
;             granular synthesis
;----------------------------------------------------------------------------
;i325   time  idur  iampdb  ifrqhz  iratio  icutoff  ifdback ihamfn isinfn 
;       inoifn iatt  itail  ihamamp ifundamp inoiamp ipan  iwet
instr 325

idur = p3
iamp = ampdb( p4 )
ifrq = p5
iratio = p6
icutoff = p7
ifdback = p8
ihamfn = p9
isinfn = p10
inoifn = p11
iatt = p12
itail = p13
ihamamp = p14
ifundamp = p15
inoiamp = p16
ipan = p17
iwet = p18

icycle = iratio/ifrq

	aham	osciln  ihamamp, ifrq/iratio, ihamfn, 1
	afund	osciln  ifundamp, ifrq/iratio, isinfn, 1
	anoi	osciln inoiamp, ifrq/iratio, inoifn, 1
	; noise is now filtered already;	anoi	tone anoi, 10.0
	anoi	butlp anoi, ifrq
	anoi	butlp anoi, ifrq
	anoienv linseg 0.0, icycle/8.0,1.0,3.0*icycle/4.0, 1.0, icycle/8.0, 0.0
	aham	= aham + anoi * anoienv + afund

	asig	mywvguide3 aham, ifrq/iratio, icutoff, ifdback, 0.0, iratio
	kenv	linseg  0.0, iatt, 1.0, idur-itail-iatt, 1.0, itail, 0.0

	aout 	= asig * kenv * iamp

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout


endin


;----------------------------------------------------------------------------
; instr 327 - piano with delicate attacks based on exponential input
;             to comb filter
;----------------------------------------------------------------------------
;i327   time   idur   iampdb  ifrqhz   ihamfn  isinfn   ipan   iwet
instr 327

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ihamfn = p6
isinfn = p7
ipan = p8
iwet = p9

iexpatt = 0.05
iexpatt2 = 0.1
icombfrq1 = ifrq 
itail = 0.05
ifrqvar = 0.02
ifrqvar2 = 0.02
ifrqfrq = 10.0
icycle = 1.0/ifrq
iampmult = sqrt( 440.0/ifrq )

	iseed	random 0.001, 0.999
	krnd	randi ifrqvar, ifrqfrq, iseed
	krnd	= 1.0 + krnd

	aham	oscili 1.0, icombfrq1 * krnd, ihamfn
	aham	butlp aham, 4000.0
	ahamenv1 expseg 1.0, iexpatt, 0.0001, idur -iexpatt, 0.0001
	ahamenv2 linseg 0.0, 0.001, 1.0, idur-0.001, 1.0
	aham	= aham * ahamenv1 * ahamenv2

	iseed	random 0.001, 0.999
	krnd2	randi ifrqvar2, ifrqfrq, iseed
	krnd2 	= 1.0 + krnd2

	aham2	oscili 1.0, icombfrq1 * krnd2, isinfn
	ahamenv21 expseg 1.0, iexpatt2, 0.0001, idur-iexpatt2, 0.0001
	ahamenv22 linseg 0.0, 0.001, 1.0, idur-0.001, 1.0
	aham2 = aham2 * ahamenv21 * ahamenv22 / 3.0

	ahamcomb = (aham + aham2)/2.0
	ahamcomb earlyrefl ahamcomb, icycle

	asig	mycomb  ahamcomb, icombfrq1, 1.0

	ktail	linseg 1.0, idur-itail, 1.0, itail, 0.0
	asig	= asig * ktail

	asig	= asig * iamp * iampmult

	aout	= asig

	aamb 	= aout
	aamb	butlp aamb, 1000.0
;	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin


;----------------------------------------------------------------------------
; instr 348 - piano-like using mywvguide3- the pitch-shifting waveguide
;----------------------------------------------------------------------------
;
; ifn: hammer function
;
;i348   time  idur   iampdb   ifrqhz   icutoff ifdback  iratio  ifn   ipan   
;       iwet
instr 348

idur = p3
iamp = ampdb( p4 )
ifrq = p5
icutoff = p6
ifdback = p7
iratio = p8
ifn = p9
ipan = p10
iwet = p11

itail = 0.05
iatt = 0.002

ionecycle = iratio/ifrq

;	anoienv	linseg 0.0, ionecycle/4.0, 1.0, ionecycle/2.0, 1.0,                                         ionecycle/4.0, 0.0
	anoienv	osciln 1.0, ifrq/iratio, gihammtab, 1
	anoi	gauss 0.2
	anoi	butlp anoi, ifrq


	aham	osciln 1.0, ifrq/iratio, ifn, 1

	aham	tone aham, 2.0 * ifrq

	asig	mywvguide3 (aham+anoi) * anoienv, ifrq/iratio, icutoff, ifdback,                                 0.0, iratio
;	asig	mywvguide2 aham * anoienv, ifrq, icutoff, ifdback, 0.0
;	asig	reson asig, ifrq, ifrq, 1

	asig1	alpass asig, 0.1, 0.001
	asig2	alpass asig, 0.1, 0.0013
	asig3	alpass asig, 0.1, 0.0007
	asigleft = (2*asig1 + asig2 + asig3)/4.0

	asig4	alpass asig, 0.1, 0.0009
	asig5	alpass asig, 0.1, 0.0014
	asig6	alpass asig, 0.1, 0.0006
	asigright = (asig1 + asig2 + 2*asig3)/4.0

	kenv	linseg 0.0, iatt, 1.0, idur-itail-iatt, 1.0, itail, 0.0

	aoutleft = asigleft * kenv * iamp * 10.0
	aoutright = asigright * kenv * iamp * 10.0

	aamb 	= (aoutleft + aoutright)/2.0
	aamb	butlp aamb, 1500.0
	aamb	butlp aamb, 1500.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aoutleft, ipan*(1.0-iwet)*aoutright
endin




;----------------------------------------------------------------------------
; Frequency envelope source instrument for flute
;----------------------------------------------------------------------------
;i400   time idur  ifreq  ivibstart iampl  ioutch ifn
instr 400

idur = p3
ifreq = p4
ivibstart = p5
iampl = p6
ioutch = p7
ifn = p8

ivibfreq = 5.0

;  error line number offset = 5

	kenv	linseg 0.0,   ivibstart, 0.0,  0.1, 1.0,  idur-ivibstart-0.4,                		1.0, 0.3,   0.0
	krnd	randi 0.0, 2.0
	kvibfreq = ivibfreq + krnd
	kphs	phasor kvibfreq
	ksin	tablei kphs, ifn, 1
	ksin   = ksin - 1.0
	kout	= ifreq * ( 1.0 + kenv * iampl * ksin )
		zkw kout, ioutch

endin


;----------------------------------------------------------------------------
; Attempt at flute - 401 - not used now
;----------------------------------------------------------------------------
;i401  time  idur  iampdb  ifrqpch  ifn  ipan  iwet

instr 401

idur = p3
iamp = ampdb( p4 )
ifrq = cpspch( p5 )
ifn = p6
ipan = p7
iwet = p8

	kenv	linseg  0.0, 0.05, 1.0, idur-0.10, 1.0, 0.05, 0

	aout	oscili  iamp, ifrq, ifn
	arnd	trirand 0.5
	arnd	butbp arnd, 6000.0, 12000.0
	arnd	butbp arnd, 6000.0, 12000.0
	arnd	dcblock arnd
	aout	= aout * (1.0 + arnd)
	aout	= aout * kenv

		zawm aout*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin

;----------------------------------------------------------------------------
; Attempt at flute - 402 - this produces one partial
;----------------------------------------------------------------------------
;i402 time  idur  iampdb  ifrq  ifrqmult  inoisewid ienvch inoiseenvch ifn 
;     icutoff ifeedback ipan  iwet
;;instr 402
;;
;;idur = p3
;;iamp = ampdb( p4 )
;;ifrq = p5
;;ifrqmult = p6
;;inoisewid = p7
;;ienvch = p8
;;inoiseenvch = p9
;;ifn  = p10
;;icutoff = p11
;;ifeedback = p12
;;ipan = p13
;;iwet = p14
;;
;;	kfrnd	randi  0.001, 5.0
;;
;;	asin	oscili iamp*0.5, ifrq * ifrqmult * (1 + kfrnd), ifn
;;	knoiseamp zkr inoiseenvch
;;	arnd	randi  knoiseamp, inoisewid
;;	aout	= asin * ( 1.0 + arnd )
;;
;;	aout	wguide1 aout, ifrq, ifrq*icutoff, ifeedback
;;
;;	kenv	zkr ienvch
;;	aout	= aout * kenv
;;
;;		zawm aout*iwet, 1
;;
;;		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
;;endin	


;----------------------------------------------------------------------------
; Attempt at flute - 402 - this produces one partial
;----------------------------------------------------------------------------
;i402 time  idur  iampdb  ifrqmult  inoisewid ienvch inoiseenvch 
;     ifreqch ifn 
;     icutoff ifeedback ipan  iwet
instr 402

idur = p3
iamp = ampdb( p4 )
ifrqmult = p5
inoisewid = p6
ienvch = p7
inoiseenvch = p8
ifreqch = p9
ifn  = p10
icutoff = p11
ifeedback = p12
ipan = p13
iwet = p14

	kfrq	zkr  ifreqch
	if kfrq > 0 goto skip
		kfrq = 1.0
skip:

	asin	oscili iamp*0.5, kfrq * ifrqmult, ifn
	knoiseamp zkr inoiseenvch
	arnd	randi  knoiseamp, inoisewid
	aout	= asin * ( 1.0 + arnd )

	aout	wguide1 aout, kfrq, kfrq*icutoff, ifeedback

	kenv	zkr ienvch
	aout	= aout * kenv

		zawm aout*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin	

;----------------------------------------------------------------------------
; 403 - flute-like with waveguide
;----------------------------------------------------------------------------
;i403  time  dur  ampdb freqhz   ifn1   ifn2  isinfn itremfrq ipan irvbch  iwet
instr 403

idur = p3
iamp = ampdb(p4)
ifrq = p5
ifn1 = p6
ifn2 = p7
isinfn = p8
itremfrq = p9
ipan = p10
irvbch = p11
iwet = p12

idecayt = 0.25
iatt = 0.001
iatt2 = 0.05  ; duration of extra strong beginning
itail = 0.1

	;	iseed	random 0.01, 0.99
	;	kfrq	randi 0.0015, 5.0, iseed
	
	; Frequency envelope
	kfrq linseg 0.99, idur/3.0, 1.0, 2.0*idur/3.0, 0.99

	asig1	oscili 1.0, ifrq*kfrq, ifn1
	asig2	oscili 1.0, ifrq*kfrq, ifn2

	; Tremolo between asig1 and asig2
	iphs	random 0.01, 0.99
	ktrem	oscili 0.3, itremfrq, isinfn, iphs

	; Combine asig1 and asig2
	asig = (0.5-ktrem)*asig1 +  (0.5+ktrem)*asig2

	; Filter asig to make a bit more natural
	asig	butlp asig, 3000.0

	; Envelope on asig
	kenv	linseg 0.0, iatt, 1.0, idur-iatt-itail, 1.0, itail, 0.0
	; figure out how strong to make the attack based on duration
	; of the note
	iattstr = $INTERP(0.1'idur'2.0' 10.0'3.0')
	if iattstr < 3.0 then
		iattstr = 3.0
	endif
	if iattstr > 10.0 then
		iattstr = 10.0
	endif
	kenv2	expseg iattstr, iatt2, 1.0, idur, 1.0
	kenv	= kenv2 * kenv

	asig	mycomb asig*kenv, ifrq*kfrq, idecayt

	; Final envelope making tail
	kenv2	linseg 1.0, idur-itail, 1.0, itail, 0.0

	aout = kenv2 * asig * iamp * 0.02

	; Filter to make more balanced and adjust freq response by
	; volume
	ilowfrq = ifrq/2.0
	ifrqmult = $INTERP( 1.0'log(iamp)'6.0' 1.1'12.0' )
	ihighfrq = ilowfrq * ifrqmult
	icntfrq = ( ilowfrq + ihighfrq ) / 2.0
	iwidth =  abs(icntfrq - ilowfrq)
	aout	reson aout, icntfrq, iwidth, 1.0


	aamb 	= aout
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, irvbch

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin

;----------------------------------------------------------------------------
; 511 - basic fm chime instrument
;----------------------------------------------------------------------------
;i511 time  idur  iampdb  ifrqhz  iatt icm  imaxind ifn  ipan iwet
instr 511

idur = p3
iamp = ampdb( p4 )
ifrq = p5
iatt = p6
icm = p7
imaxind = p8
ifn = p9
ipan = p10
iwet = p11

idec = 0.05

	kind	expseg imaxind, 5.0, 1.0

	kenv1	linseg 0.0, iatt, 1.0, idur-iatt-idec, 1.0, idec, 0.0
	kenv2	expseg 1.0, iatt, 1.0, 5.0, 0.01
	kenv	= kenv1 * kenv2
	aout	foscil  iamp, ifrq, 1.0, 1.0/icm, kind, ifn
	aout2	foscil  iamp, ifrq*1.0001, 1.0, 1.0/icm, kind, ifn
	aout =  kenv * (aout + aout2) * 0.5

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin




;----------------------------------------------------------------------------
; instr 611 - basic adsyn instrument
;----------------------------------------------------------------------------
;i611   time   idur  iampdb  ifmod  ismod  ihetfile
instr 611

idur = p3
iamod = ampdb( p4 )
ifmod = p5
ismod = p6
ihetfile = p7

	asig	adsyn iamod, ifmod, ismod, ihetfile
		outs asig, asig

endin



;----------------------------------------------------------------------------
; We're taking over the 600's for experiments with articulation in waveguide
; instruments
;----------------------------------------------------------------------------


;----------------------------------------------------------------------------
; instr 612 - experiments in articulation with fm driver
;----------------------------------------------------------------------------
;
; iinenvch - the channel of the envelope on the fm oscillator at the input to
;     the waveguide resonator
; ifinench - the envelope on the output of the waveguide resonator
; ifrqdev - the maximum random deviation of frequency as ratio
; ilowpch - the channel of the envelope on the lowpass at the output of the
;        waveguide resonator
;
;i612  time   idur  iampdb  ifrqhz   iinenvch   iindch  icmch  ifrqdev
;  ifinenvch ilowpch  ifn
;instr 612
;
;idur = p3
;iamp =
;ifrq = 
;iinenvch = 
;iindch = 
;icmch = 
;ifrqdev =
;ifinenvch =
;ilowpch = 
;ifn = 
;
;
;irvt = 0.5
;
;	kcm	zkr icmch
;	kind	zkr iindch
;
;	kfrq	randi ifrqdev, 10.0
;	kfrq	= (kfrq + 1) * ifrq
;
;	asig	foscili 1.0, kfrq, 1.0, 1.0/kcm, kind, ifn
;	kinenv 	zkr iinenvch
;	asig 	= asig * kinenv
;
;	asig2	mycomb  asig, ifrq, irvt
;	
;	kfinenvch zkr ifinenvch
;	asig2	= asig2 * kfinenvch
;	klowp	zkr ilowpch
;	asig2	butlp asig2, klowp
;
;
;
;endin
;



;----------------------------------------------------------------------------
; instr 613 - experiment in piano with varying-shaped hammer wave
;        driving a waveguide
;----------------------------------------------------------------------------
; ifn: sin function
;
;i613  time  idur  iampdb  ifrqhz  ifn  ipan  irvbchan iwet
;
instr 613

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ifn = p6
ipan = p7
irvbchan = p8
iwet = p9

iamp = iamp * 440.0 / ifrq


;ifrac = 0.2
;iwid = 0.15
iham1 = 0.1
iham2 = 0.2
ifrac1 = 0.15
ifrac2 = 0.2
ifrac3 = 0.25
iwid1 = 0.15
iwid2 = 0.2
iwid3 = 0.25


irvt = 1.0
itail = 0.05

	kfrq	randi 0.005, 10.0
	kfrq	= (1.0 + kfrq) * ifrq 

	;
	; hammer envelope
	;
	;  <-- iham1 -----> <---- iham2   --->
	;  ifrac1 -->ifrac2 ifrac2 -> ifrac3
	;  iwid1 --> iwid2   iwid2 --> iwid3 
	kfrac	linseg ifrac1, iham1, ifrac2, iham2, ifrac3, idur, ifrac3
	kwid	linseg iwid1,  iham1, iwid2,  iham2, iwid3,  idur, iwid3

	aham	varhammer 1.0, kfrq, kfrac, kwid, ifn
	aham	butlp aham, 3000.0

	; Hammer envelope:
	;  <-  iatt1    -><-  iatt2     -><-- iatt3    ->
	;  0.0 lin-> 1.0  1.0 exp--> ilev1  exp--> ilev2
	iatt1 = 0.002
	iatt2 = 0.1
	iatt3 = 3.0
	ilev1 = 0.05
	ilev2 = 0.02

	khamenv1 linseg 0.0, iatt1, 1.0, idur-iatt1, 1.0
	khamenv2 expseg 1.0, iatt1, 1.0, iatt2, ilev1, iatt3, ilev2
	khamenv = khamenv1 * khamenv2

	aham 	= aham * khamenv
	asig	mycomb aham, ifrq, irvt
;	asig	wguide1 aham, ifrq, 18000.0, 0.99
	asig	= asig * iamp / 50.0

	; tail envelope
	ktail	linseg 1.0, idur-itail, 1.0, itail, 0.0
	asig	= asig * ktail


	aout = asig

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, irvbchan

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout


endin


;----------------------------------------------------------------------------
; instr 711 - sine partial with varying frequency, filtering, etc
;----------------------------------------------------------------------------
;i711   time  idur   iampdb  ifrqhz  ienvch  ifrqch  ilowpch  ihighpch ifn 
;       ipan  iwet
instr 711

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ienvch = p6
ifrqch = p7
ilowpch = p8
ihighpch = p9
ifn = p10
ipan = p11
iwet = p12

	kenv	zkr ienvch
	kfrq	zkr ifrqch
	klowp	zkr ilowpch
	khighp	zkr ihighpch
	asig	oscili iamp, ifrq * kfrq, ifn
        asig	butlp asig, klowp
	asig	buthp asig, khighp
	asig	= asig * kenv

	aout = asig

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin



;----------------------------------------------------------------------------
; instr 712 - noise with varying filtering (24 db/oct filtering)
;----------------------------------------------------------------------------
;i712  time  idur  iampdb   ifrqhz  ienvch  ilowpch  ihighpch ipan  iwet
instr 712

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ienvch = p6
ilowpch = p7
ihighpch = p8
ipan = p9
iwet = p10


	kenv	zkr ienvch
	klowp	zkr ilowpch
	khighp	zkr ihighpch
	asig	random iamp
	asig	butlp asig, klowp
	asig	butlp asig, klowp
	asig	buthp asig, khighp
	asig	buthp asig, khighp
	asig 	= asig * kenv

	aout = asig

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin

;----------------------------------------------------------------------------
; instr 713 - sine partial with varying frequency, amplitude (not filtering)
;----------------------------------------------------------------------------
;i713   time  idur   iampdb  ifrqhz  ienvch  ifrqch ifn  ipan  iwet
instr 713

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ienvch = p6
ifrqch = p7
ifn = p8
ipan = p9
iwet = p10

	kenv	zkr ienvch
	kfrq	zkr ifrqch
	asig	oscili iamp, ifrq * kfrq, ifn
	asig	= asig * kenv

	aout = asig

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin




;----------------------------------------------------------------------------
; 714 - instrument for trying to construct "soft" buzz
;----------------------------------------------------------------------------
;i714  time   idur  iampdb  ifrqhz  iampvar  ifrqvar  ivarrate ienvch 
;      icutoffch ifn   ipan  iwet
instr 714

idur = p3
iamp = ampdb( p4 )
ifrq = p5
iampvar = p6
ifrqvar = p7
ivarrate = p8
ienvch = p9
icutoffch = p10
ifn = p11
ipan = p12
iwet = p13

	iseed   random  0.001, 0.999
	kf	randi ifrqvar, ivarrate, iseed
	kfrq	= ifrq * ( 1.0 + kf )

	iseed2   random  0.001, 0.999
	ka	randi iampvar, ivarrate, iseed2
	kamp	= iamp * ( 1.0 + ka )

	iphs	random 0.001, 0.999

	asig	oscili  kamp,  kfrq, ifn, iphs

	kcutoff zkr icutoffch
	asig	butlp asig, kcutoff

	kenv	zkr ienvch
	asig	= asig * kenv

	aout = asig

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin 



;----------------------------------------------------------------------------
; instr 715 - trying to make nice "bonk" sounds
;----------------------------------------------------------------------------
;i715   time   idur   iampdb   ifrqhz   ipan   iwet
instr 715

idur = p3 
iamp = ampdb( p4 )
ifrq = p5
ipan = p6
iwet = p7

	asig	linseg 0.0,  0.003, 1.0, 0.003, 0.0, idur, 0.0
	asig	= asig* 10.0
	asig	reson asig, ifrq, ifrq/50.0, 1
	asig	= asig * iamp

	aout = asig

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout


endin

;----------------------------------------------------------------------------
; instr 716 - the first few harmonics
;----------------------------------------------------------------------------
;i716   time   idur   iampdb  ifrqhz  icutoffch ifn  ipan   iwet
instr 716

idur = p3
iamp = ampdb( p4 )
ifrq = p5
icutoffch = p6
ifn = p7
ipan = p8
iwet = p9

iatt	= 0.001
itail	= 0.05

	kenv1	linseg 0.0, iatt, 1.0, idur-iatt-itail, 1.0, itail, 0.0
	kenv2	expseg 1.0, iatt, 1.0, 10.0, 0.001

	asig	oscili iamp, ifrq, ifn

	kcutoff zkr icutoffch
	asig	butlp asig, kcutoff

	asig	= asig * kenv1 * kenv2

	aout = asig

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin


;----------------------------------------------------------------------------
; instr 717 - getting complex waveform from time-delayed shifting input
;----------------------------------------------------------------------------
;i717  time  idur  iampdb  ifrqhz    ifn  ipan  iwet
instr 717

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ifn = p6
ipan = p7
iwet = p8

icycle = 1.0/ifrq
iatt = 0.008
itail = 0.05
itapvar = 0.0003
itapvar = icycle/100.0
itapfrq = 50.0

iresctr = ifrq * 2.0
ireswid = ifrq

	if (ifrq >= 300) igoto skip
		iresctr = 600
		ireswid = 600-ifrq
	skip:

	asig	oscili  iamp/2.0, ifrq, ifn
	kaenv	linseg 0.0, iatt, 1.0, idur -iatt , 1.0
	asig	= asig * kaenv
	kdec	expseg 1.0, iatt, 1.0, 10.0, 0.001
	asig	= asig * kdec
	asig	butlp asig, 1000.0
	kfilt	expseg 5000.0, 3.0, 2.0 * ifrq
	asig	butlp asig, kfilt 

	iseed	random 0.001, 0.999
	ktap1	randi itapvar, itapfrq, iseed
	iseed	random 0.001, 0.999
	ktap2	randi itapvar, itapfrq, iseed
	iseed	random 0.001, 0.999
	ktap3	randi itapvar, itapfrq, iseed
	iseed	random 0.001, 0.999
	ktap4	randi itapvar, itapfrq, iseed
	iseed	random 0.001, 0.999
	ktap5	randi itapvar, itapfrq, iseed
	iseed	random 0.001, 0.999
	ktap5	randi itapvar, itapfrq, iseed

	anull	delayr 1.0
	ao1	deltapi 0.0021 + ktap1
	ao2	deltapi 0.0021 + ktap2
	ao3	deltapi 0.0021 + ktap3
	ao4	deltapi 0.0021 + ktap4
	ao5	deltapi 0.0021 + ktap5
		delayw asig

	asig	= (ao1 + ao2 + ao3 + ao4 + ao5) / 5.0

	asig    butlp asig, 3000.0
	asig 	= 5.0 * asig

	asig1	mycomb asig, ifrq, 0.01
;	asig1	reson asig, 3000.0, 1000.0, 1
;	asig1	= asig1 * 5.0
	asig = asig1 

	ktail 	linseg 1.0, idur-itail, 1.0, itail, 0.0
	asig	= asig * ktail

	aout	= asig
	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin


;----------------------------------------------------------------------------
; instr 718 - getting complex waveform from time-delayed shifting input
;               following a sin wave in shifting
;----------------------------------------------------------------------------
;i718  time  idur  iampdb  ifrqhz    ifnham ifnsin  ipan  iwet
instr 718

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ifnham = p6
ifnsin = p7
ipan = p8
iwet = p9

iatt = 0.008
itail = 0.05
itapvar = 0.0005
itapfrq = 2.0

	asig	oscili  iamp, ifrq, ifnham
	kaenv	linseg 0.0, iatt, 1.0, idur -iatt , 1.0
	asig	= asig * kaenv
	kdec	expseg 1.0, iatt, 1.0, 10.0, 0.001
	asig	= asig * kdec
	kfilt	expseg 5000.0, 1.0, 2.0 * ifrq
	asig	butlp asig, kfilt 

	ktap1	oscili 0.0001, 0.3, ifnsin
	ktap2	oscili 0.0001, 0.5, ifnsin	
	ktap3	oscili 0.0001, 0.7, ifnsin	
	ktap4	oscili 0.0001, 1.1, ifnsin	


	anull	delayr 1.0
	ao1	deltapi 0.0021 + ktap1
	ao2	deltapi 0.0021 + ktap2
	ao3	deltapi 0.0021 + ktap3
	ao4	deltapi 0.0021 + ktap4
;	ao5	deltapi 0.0021 + ktap5
		delayw asig

;	asig	= (ao1 + ao2 + ao3 + ao4 + ao5) / 5.0
	asig	= (ao1 + ao2 + ao3 + ao4) /4.0

	
	asig1	reson asig, 2.0*ifrq, ifrq, 1
	asig1	= asig1 * 20.0
	asig2	reson asig, 600.0, 300.0, 1
	asig2 	= asig2 * 10.0
;	asig	= ( asig1 + asig2 ) / 2.0
	asig = asig1

	ktail 	linseg 1.0, idur-itail, 1.0, itail, 0.0
	asig	= asig * ktail

	aout	= asig
	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin

;----------------------------------------------------------------------------
; instr 719 - experiment with slight abberations
;----------------------------------------------------------------------------
;i719  time  idur  iampdb  ifrqhz  ihamfn  isinfn  ipan  iwet
instr 719

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ihamfn = p6
isinfn = p7
ipan = p8
iwet = p9

;  asig  randbump  ilevel, iavgfrq, ifrqvarmag, ifrqvarfrq

	abmp	randbump 0.9999, 10.0, 0.5, 10.0
	aamp	= (1 + 0.3*abmp) * iamp
	asig	oscili aamp, ifrq, ihamfn
	
	aout	= asig
	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin


;----------------------------------------------------------------------------
; instr 720 - time-shifting waveforms, but more controlled shifting
;----------------------------------------------------------------------------
;i720  time  idur   iampdb  ifrqhz  ihamfn   ipan  iwet
instr 720

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ihamfn = p6
ipan = p7
iwet = p8

icycle = 1.0/ifrq
iatt = 0.01
itail = 0.05

	aham	oscili iamp, ifrq, ihamfn
	aham	butlp aham, 4000.0
;	khp	linseg 2000.0, iatt * 12.0, ifrq/2.0, idur-iatt*12.0, ifrq/2.0
;	aham	buthp aham, khp
	; atapspd: "tap spread"
	; itapbase "tap base"
	atapspd linseg icycle/100.0, idur, icycle/20.0
	itapbase = icycle/3.0	
	arndrange = icycle/40.0
	irndfrq = 10.0

	iseed	random 0.001, 0.999
	arnd1	randi arndrange, irndfrq, iseed
	atap1	= itapbase + 0.0 * atapspd + arnd1
	iseed	random 0.001, 0.999
	arnd2	randi arndrange, irndfrq, iseed
	atap2	= itapbase + 1.0 * atapspd + arnd2
	iseed	random 0.001, 0.999
	arnd3	randi arndrange, irndfrq, iseed
	atap3	= itapbase + 2.0 * atapspd + arnd3
	iseed	random 0.001, 0.999
	arnd4	randi arndrange, irndfrq, iseed
	atap4	= itapbase + 3.0 * atapspd + arnd4
	iseed	random 0.001, 0.999
	arnd5	randi arndrange, irndfrq, iseed
	atap5	= itapbase + 4.0 * atapspd + arnd5

	kenvatt	linseg 0.0, iatt, 1.0, idur-iatt, 1.0
	aham	= aham * kenvatt

	anull	delayr 1.0

	asig1	deltapi atap1
	asig2	deltapi atap2
	asig3	deltapi atap3
	asig4	deltapi atap4
	asig5	deltapi atap5

		delayw aham

	asig = ( asig1 + asig2 + asig3 + asig4 + asig5)/5.0
;	asig = asig1
	ares	reson asig, 1000, 500, 1
	ares	= ares*20.0

	ktail	linseg 1.0, idur-itail, 1.0, itail, 0.0
	aout	= ares * ktail

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin


;----------------------------------------------------------------------------
; instr 721 - a decent piano with comb filter
;----------------------------------------------------------------------------
;i721  time  idur  iampdb  ifrqhz  isinfn  iwvshp ipan  iwet
instr 721

idur = p3
iamp = ampdb( p4 )
ifrq = p5
isinfn = p6
iwvshp = p7
ipan = p8
iwet = p9

iatt = 0.008
itail = 0.01
icycle = 1.0/ifrq

	asig	linseg 0.0, icycle/4.0, 1.0, icycle/8.0, 0.0, icycle/8.0, 0.5,                         icycle/8.0, 0.0
	asig	butlp asig, 1000.0	

;	asig1	reson asig, 1200.0, 250.0
;	asig1	= 200.0 * asig1
;	asig2	reson asig, 600.0, 250.0
;	asig2 	= 50.0 * asig2

;	aout = (asig1 + asig2)/2.0


	ac1	mycomb asig, ifrq*0.9999, 1.5
	ac2	mycomb asig, ifrq, 1.5
	ac3	mycomb asig, ifrq*1.00021, 1.5
	ac	= (ac1 + ac2 + ac3)/3.0
	aout	buthp ac, 90.0
	aout	butlp aout, 5000.0
	aout	butlp aout, 8000.0
	aout	= iamp * aout * 5.0

	aout2	reson aout, 1000.0, 500.0, 1
	aout3   reson aout, 3000.0, 500.0, 1
	aout	= (aout + aout2 + 5.0 * aout3)/3.0
;	aout = 10.0 * aout3

	; Waveshaping part
;	aout	waveshape aout/32000.0, 100000000000.0, iwvshp
;	aout	limit aout, -1000, 1000
;	kclk	linseg 0.0, 0.001, 1.0, idur-0.001, 1.0
;	aout	= aout * kclk

	ktail	linseg 1.0, idur-itail, 1.0, itail, 0.0
	aout	= aout * ktail

	aamb 	= aout
	aamb	butlp aamb, 1000.0
	aamb	butlp aamb, 1000.0
	aamb	buthp aamb, 250.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin


;----------------------------------------------------------------------------
; instr 811 - electronic fm-like
;----------------------------------------------------------------------------
; iusereson: =1 or 0: 1 means use the reson filter, 0 means not
; 
; itapspdfrac: the fraction of cycle time
;
;i811  time  idur  iampdb  ifrqhz   icm  ienvch  iindch ilowp  iresctr
;      ireswid  isinfn  iusereson  itapspdfrac  itapfrq  ipan  iwet
instr 811

idur = p3
iamp = ampdb( p4 )
ifrq = p5
icm  = p6
ienvch = p7
iindch = p8
ilowp = p9
iresctr = p10
ireswid = p11
ifn = p12
iusereson = p13
itapspdfrac = p14
itapfrq = p15
ipan = p16
iwet = p17

icycle = 1.0/ifrq
idelbase = 2.0 * icycle
itapspd = icycle * itapspdfrac
imodmult = 1.0 / icm

	kind	zkr iindch
	kenv	zkr ienvch
	kamp	= kenv * iamp 
	afm	foscili kamp, ifrq, 1.0, imodmult, kind, ifn
	afm	butlp afm, ilowp

	iseed	random 0.001, 0.999
	adel1	randi itapspd, itapfrq, iseed
	iseed	random 0.001, 0.999
	adel2	randi itapspd, itapfrq, iseed
	iseed	random 0.001, 0.999
	adel3	randi itapspd, itapfrq, iseed
	iseed	random 0.001, 0.999
	adel4	randi itapspd, itapfrq, iseed
	iseed	random 0.001, 0.999
	adel5	randi itapspd, itapfrq, iseed

	anull	delayr 1.0
	atap1	deltapi adel1 + idelbase
	atap2	deltapi adel2 + idelbase
	atap3	deltapi adel3 + idelbase
	atap4	deltapi adel4 + idelbase
	atap5	deltapi adel5 + idelbase


		delayw afm

	acmb	= ( atap1 + atap2 + atap3 + atap4 + atap5 ) / 5.0

	acmbr	reson acmb, iresctr, ireswid, 1
	acmb	= (1.0 - iusereson) * acmb   +   iusereson * acmbr * 2.0

	aout 	= acmb
	aamb 	= aout
	aamb	butlp aamb, 2000.0
	aamb	butlp aamb, 2000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin

;----------------------------------------------------------------------------
; instr 911 - string multi-purpose
;----------------------------------------------------------------------------
;i911   time  idur  iampdb  ifrqhz  itrifn  ipan  iwet
instr 911

idur = p3
iamp = ampdb( p4 )
ifrq = p5
itrifn = p6
ipan = p7
iwet = p8

isuslevel = 0.02
ipreatt = 0.001
iatt = 0.1
ilowpass = 2000.0
ilowpass2 = 5000.0
irndamp = 0.0005
irndfrq = 3.0
itail = 0.05
iampmult = sqrt( 440.0/ ifrq)

	iseed	random 0.001, 0.999
	kfrq	randi   irndamp, irndfrq, iseed
	kfrq	= ifrq * ( 1.0 + kfrq )

	asig	oscili  1.0, kfrq, itrifn

	kenv1	expseg 1.0, ipreatt, 1.0, iatt, isuslevel, idur-iatt-ipreatt,                          isuslevel
	kenv2	linseg 0.0, ipreatt, 1.0, idur-ipreatt, 1.0
	asig	= asig * kenv1 * kenv2

	asig	tone asig, 800.0
	asig	butlp asig, 3000.0

	asig1	mycomb asig, ifrq * 0.9999, 1.0
	asig2	mycomb asig, ifrq * 1.0001, 1.0
	
	asig1	= asig1 * iamp * iampmult / 3.0
	asig2	= asig2 * iamp * iampmult / 3.0

	ktail	linseg 1.0, idur-itail, 1.0, itail, 0.0
	asig1	= asig1 * ktail
	asig2	= asig2 * ktail
	asigleft = 0.7 * asig1 + 0.3 * asig2
	asigright = 0.3 * asig1 + 0.7 * asig2

	aout 	= (asigleft + asigright)/2.0
	aamb 	= aout
	aamb	butlp aamb, 2000.0
	aamb	butlp aamb, 2000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*asigleft, ipan*(1.0-iwet)*asigright
endin

;----------------------------------------------------------------------------
; instr 913 - granular synthesis on attack
;----------------------------------------------------------------------------
;i913  time idur  iampdb  ifrqhz igraindur igrainorigfrq igrainfn iwfn ipan
;      iwet
instr 913

idur = p3
iamp = ampdb( p4 )
ifrq = p5
igraindur = p6
igrainorigfrq = p7
igrainfn = p8
iwfn = p9
ipan = p10
iwet = p11

igraincps = ( (ifrq/igrainorigfrq) / igraindur)
iphs = 0.0
ifmd = igraincps/10000.0
ipmd = 0.0
imaxdens = 1000.0
iattdur = 0.1  ; overall duration of grain shower
imaxovr = 500
ifrpow = 0.0
iprpow = 0.0
iseed = 0.0
imode = 16
itail = 0.05

	kdens	linseg imaxdens, iattdur, imaxdens, 0.001, 0.1
	krnd	randi 0.01, 10.0
	kdens	= kdens * (krnd + 1.0)
	asig	grain3 igraincps, iphs, ifmd, ipmd, igraindur, kdens, imaxovr,                  igrainfn, iwfn, ifrpow, iprpow, iseed, imode
	ktail	linseg 1.0, idur-itail, 1.0, itail, 0.0
	asig	= asig * ktail

	aout	= asig * iamp

	aamb 	= aout
	aamb	butlp aamb, 2000.0
	aamb	butlp aamb, 2000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin

;----------------------------------------------------------------------------
; opcode drivingrand - making a driving signal with some random fluctuation
;----------------------------------------------------------------------------
; ifrqfrac: the fraction of freq
; icenfrq: center frequency of filter
; iwid: width of filter
;
;  aout  drivingrand   iamp, ifrq, ifn, ifrqfrac, icenfrq, iwid
opcode drivingrand, a, iiiiii

	iamp, ifrq, ifn, ifrqfrac, icenfrq, iwid	xin 

	iseed	random 0.01, 0.99
	kfrac	randi ifrqfrac, 10.0, iseed
	kfrq	= ifrq * ( 1.0 + kfrac )

	asig	oscili iamp, kfrq, ifn
	asig	butbp asig, icenfrq, iwid

		xout asig

endop


;----------------------------------------------------------------------------
; instr 915 - trying to shape tonal balance of attack
;----------------------------------------------------------------------------
;i915 time  idur  iampdb  ifrqhz  isawtoothfn  ipan  iwet
instr 915

idur = p3
iamp = ampdb( p4 )
ifrq = p5
isawtoothfn = p6
ipan = p7
iwet = p8


irvt = 1.0
iwholeatt = 0.1
ifirstatt = 0.01
ipreatt = 0.02
ifinlev = 0.5 ; final level of driving signal
itail = 0.05

	; koverint = "overall intensity"
	koverint linseg 1.0, idur/2.0, 2.0, idur/2.0, 1.0

	; Butterworth filter transistion points
	icut1 = ifrq * 0.8
	icut2 = ifrq * 2.2
	icut3 = ifrq * 4.0
	icut4 = ifrq * 8.0

	asig1	drivingrand 1.0, ifrq, isawtoothfn, 0.0005,                                       (icut1+icut2)/2.0,  icut2-icut1
	asig2	drivingrand 1.0, ifrq, isawtoothfn, 0.0005,                                       (icut2+icut3)/2.0,  icut3-icut2
	asig3	drivingrand 1.0, ifrq, isawtoothfn, 0.0005,                                       (icut3+icut4)/2.0,  icut4-icut3

	imodfrac = 0.1
	ifrq2 = 1.0
	iseed 	random 0.01, 0.99
	kmod1	randi imodfrac, ifrq2, iseed
	asig1	= asig1 * (kmod1 + 1.0)

	iseed 	random 0.01, 0.99
	kmod2	randi imodfrac, ifrq2, iseed
	asig2	= asig2 * (kmod2 + 1.0)

	iseed 	random 0.01, 0.99
	kmod3	randi imodfrac, ifrq2, iseed
	asig3	= asig3 * (kmod3 + 1.0)

	ain	= (asig1 + asig2 + asig3)/3.0
	katt2	linseg 0.0, ipreatt, 1.0, idur-ipreatt, 1.0
	ain	= katt2 * ain
	ain	tone ain, 2000.0
	ain	tone ain, 4000.0

	asig1	reson ain, ifrq, ifrq/2.0, 1
	asig2	reson ain, 4.0*ifrq, 2.0*ifrq, 1
	asig3	reson ain, 8.0*ifrq, 4.0*ifrq, 1
	asig	= (asig1 + asig2 + asig3)/3.0

	ktail	linseg 1.0, idur-itail, 1.0, itail, 0.0
	asig	= asig * ktail * iamp * 8.0
	aout	= asig

	aamb 	= aout
	aamb	butlp aamb, 2000.0
	aamb	butlp aamb, 2000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin



;----------------------------------------------------------------------------
; instr 1011 - wandering input flutes
;----------------------------------------------------------------------------
;i1011  time  idur  iampdb   ifrqhz  ifrqshiftch  ipan  iwet
instr 1011

idur = p3
iamp = ampdb( p4 )
ifrq = p5
ifrqshiftch = p6
ipan = p7
iwet = p8

irvt = 1.0
ihead = 0.002
itail = 1.0

	kfrqshiftch zkr ifrqshiftch
	knoifrq = ifrq * kfrqshiftch

	anoi	random -1.0, 1.0
	khd	linseg 0.0, ihead, 1.0, idur-ihead, 1.0
	anoi	= anoi * khd
	anoi	butbp anoi, knoifrq, knoifrq/10.0
	anoi	butbp anoi, knoifrq, knoifrq/10.0

	asig	mycomb anoi, ifrq, irvt
	aout	= (asig + 3.0 * anoi) * iamp * 3.0

	ktail	linseg 1.0, idur-itail, 1.0, itail, 0.0
	aout	= aout * ktail

	aamb 	= aout
	aamb	butlp aamb, 2000.0
	aamb	butlp aamb, 2000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin

;----------------------------------------------------------------------------
; percussive instrument from amplitude modulation
;----------------------------------------------------------------------------
;i1101  time  idur  iampdb  ifrqhz ifncarr  ifnmod  imaxcm ipan  iwet 
instr 1101

idur = p3
iamp = ampdb(p4)
ifrq = p5
ifncarr = p6
ifnmod = p7
imaxcm = p8
ipan = p9
iwet = p10

        ;        ampl    mp      cmr
	; t=0      0      1      
	; t=32     1     0.1
	; t=96    0.3    ~0.1
        ;   


	kfrq	linseg 1.0, idur, 0.9
	kfrq	= ifrq * kfrq

	icmrt1 = idur * 32.0/512.0
	icmrt2 = idur * (32.0 + 160.0)/512.0
	kcmr	linseg 0.6799, icmrt1, 0.6799, icmrt2-icmrt1, 1.0,                              idur-icmrt2, 0.9808
	kcmr	= kcmr * imaxcm
	;kcmr 	= 0.6799 * imaxcm

	impt1 	= idur * 32.0/ 512.0
	kmp	linseg 1.0, impt1, 0.1, idur-impt1, 0.11
	;	kmp	= 1.0

	iampt1 	= idur * 32.0/ 512.0
	iampt2  = idur * ( 32.0 + 64.0 ) / 512.0
	kamp	linseg 0.0, iampt1, 1.0, iampt2-iampt1, 0.3, idur-iampt2, 0.0
	kamp	= kamp * iamp

	acarr	oscili  1, kfrq, ifncarr
	amod	oscili  1, kfrq/kcmr, ifnmod
	aoutm	= acarr * amod * kmp
	aoutnm  = acarr * (1.0-kmp)
	aout	= kamp * (aoutm + aoutnm)

	aamb 	= aout
	aamb	butlp aamb, 2000.0
		zawm aamb*iwet, 1

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout
endin


;----------------------------------------------------------------------------
; instr 1102 - playing with attacks 
;
; The attack will feature a transition from sound 1 to sound 2
;----------------------------------------------------------------------------
;
;i1102  time  idur  iamp  ifrqhz  isinfn ipan  irvbch  iwet
instr 1102

idur = p3
iamp = ampdb( p4 )
ifrq = p5
isinfn = p6
ipan = p7
irvbch = p8
iwet = p9

icmatt = 0.95
iindatt = 6.0

iindbodymax = 3.0
icmbody = 0.999

iatt = 0.015
itail = 0.06

	; Generate attack sound
	arand	random 0.5, 2.0
	aatt	foscili  1.0, ifrq, 1.0, arand*1.0/icmatt, iindatt, isinfn
	aatt	butlp aatt, ifrq * 4.0

	; Generate body sound
	kindbody expseg 1.0, iatt, 1.0, 10.0, 0.001
	kindbody = kindbody * iindbodymax
	abod1	foscili  1.0, ifrq, 1.0, 1.0/icmbody, kindbody, isinfn
	abod2	foscili  1.0, ifrq*0.9996, 1.0, 1.0/icmbody, kindbody, isinfn
	abod3	foscili  1.0, ifrq*1.0003, 1.0, 1.0/icmbody, kindbody, isinfn
	abod	= (abod1 + abod2 + abod3)/3.0

	; Mix attack and body
	kmix	linseg 0.0, iatt, 1.0, idur, 1.0
	;kmix    = 1.0
	asig	= kmix * abod + (1-kmix) * aatt

	; Overall amplitude envelope
	kenv1	linseg 0.0, iatt, 1.0, idur, 1.0
	kenv2	expseg 1.0, iatt, 1.0, 20.0, 0.001
	kenv3	linseg 1.0, idur-itail, 1.0, itail, 0.0
	kenv	= kenv1 * kenv2 * kenv3
	aout	= asig * kenv * iamp

	aamb 	= aout
	aamb	butlp aamb, 2000.0
		zawm aamb*iwet, irvbch

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin

;----------------------------------------------------------------------------
; instr 1103 - playing with filtering sounds on attack
;----------------------------------------------------------------------------
;i1103  time  idur  iamp  ifrqhz  isinfn ipan  irvbch  iwet
instr 1103

idur = p3
iamp = ampdb( p4 )
ifrq = p5
isinfn = p6
ipan = p7
irvbch = p8
iwet = p9

iatt = 0.01
itail = 0.05

icmatt = 1.0
iindatt = 3.0

icmbod = 1.0
iindbod = 2.0

	; Generate attack sound
	aatt	foscili 1.0, ifrq*0.99, 1.0, 1.0/icmatt, iindatt, isinfn
	aatt	buthp aatt, 2.0*ifrq

	; Generate some modulation on index of body sound
	kindmod oscili 0.3, 6.0, isinfn

	; Generate main body sound
	kind	expseg 1.0, iatt, 1.0, 5.0, 0.001
	kind	= kind * iindbod
	abody	foscili 1.0, ifrq, 1.0, 1.0/icmbod, kind+kindmod, isinfn

	; Fade between sounds
	kfade	linseg 0.0, iatt, 1.0, idur-iatt, 1.0
	;kfade   = 1.0
	asig	= kfade * abody + (1-kfade) * aatt
	asig	reson asig, 2.0*ifrq, ifrq, 1

	; Apply ampl envelope
	kenv1	linseg 0.0, iatt, 1.0, idur, 1.0
	kenv2	expseg 1.0, iatt, 1.0, 10.0, 0.001
	kenv3	linseg 1.0, idur-itail, 1.0, itail, 0.0
	kenv	= kenv1 * kenv2 * kenv3
	asig	= asig * kenv * iamp

	aout	= asig

	aamb 	= aout
	aamb	butlp aamb, 2000.0
		zawm aamb*iwet, irvbch

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin


;----------------------------------------------------------------------------
; instr 1104 - timbre experiments
;
; In the state I left this on April 30, it was a decent electronic-piano
; -like sound
;----------------------------------------------------------------------------
;i1104  time  dur  iampdb  ifrqhz  isinfn  ipan  irvbch  iwet
instr 1104

idur = p3
iamp = ampdb(p4)
ifrq = p5
isinfn = p6
ipan = p7
irvbch = p8
iwet = p9

iatt 	random 0.008, 0.013
iatt2 = 2*iatt
iatt3 = 1.0
itail = 0.05

imaxind = 2.0
ifirstcm = $INTERP(log(20)'log(ifrq)'log(4000)'1.00'0.985')

	kcm	linseg ifirstcm, 5*iatt2, 0.999
	kind	expseg 2*imaxind, iatt2, imaxind, 3.0, 0.001
	kindvib	oscili 0.15, 4.0, isinfn
	kind	= kind * (1.0 + kindvib)

	asig	foscili 1.0, ifrq, 1.0, 1.0/kcm, kind, isinfn

	; Apply distance filtering
	icntfrq = ifrq * 4.0
	kbw	linseg 100.0, iatt2, icntfrq-10.0
	;kbw	= 1700.0
	asig	reson asig, icntfrq, kbw, 1.0

	; A high-freq emph filtering
	khighfrq linseg  4 * ifrq, iatt3, 2*ifrq
	khighbw = ifrq/2.0
	kemph = 2.0
	asig2	reson asig, khighfrq, khighbw, 1.0
	asig	= asig + kemph * asig2

	; amplitude envelope
	kenv	linseg 0.0, iatt, 1.0, idur-iatt-itail, 1.0, itail, 0.0
	kenv2	linseg 1.0, iatt2, 1.0, 1.0, 0.5, 2.0, 0.15
	asig	= asig * kenv * kenv2

	asig	= asig * iamp

	aout	= asig

	aamb 	= aout
	aamb	butlp aamb, 2000.0
		zawm aamb*iwet, irvbch

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin


; ----------------------------------------------------------------------
; opcode hammer 
; ----------------------------------------------------------------------
; aout hammersound ain, kfrq, itime, idur
opcode hammersound, a, akii
	ain, kfrq, itime, idur xin
	
iatt = 0.01

	; Set up steady state filtered noise
	afilt	mycomb ain, kfrq, 0.5
	afilt	dcblock afilt

	kenv	linseg 0.0, itime, 0.0, iatt, 1.0, idur, 0.0
	asig	= afilt * kenv

	asig2	mycomb asig, kfrq, 2.0
	asig2   dcblock asig2
	

		xout asig2
endop

; ----------------------------------------------------------------------
; opcode doublecom - filters through double comb arrangement
; ----------------------------------------------------------------------
;   aout doublecomb ain, kfrq, irvt
opcode doublecomb, a, aki

	ain, kfrq, irvt xin

	asig	mycomb ain, kfrq, irvt
	asig	mycomb asig, kfrq, irvt
	asig	dcblock asig
		xout asig
endop

; ----------------------------------------------------------------------
; opcode multnoise - adds several random opcodes
; ----------------------------------------------------------------------
;  aout multnoise imin, imax
opcode multnoise, a, ii

	imin, imax xin

	anoi1	random imin, imax
	anoi2	random imin, imax
	anoi3 	random imin, imax
	anoi4	random imin, imax
	aout	= anoi1 + anoi2 + anoi3 + anoi4
	aout	dcblock aout
	aout	butlp aout, 100.0
	aout	tone aout, 2000.0

		xout aout
endop


;----------------------------------------------------------------------------
; instr 1105 - a beautiful piano/banjo like instrument
;
;   note: needs extra duration to allow a filter to come to steady
;   state: the note won't start until iextra after the time
;----------------------------------------------------------------------------
;i1105  time  dur  iampdb  ifrqhz  isinfn  iextra ipan  irvbch  iwet
instr 1105

idur = p3
iamp = ampdb( p4 )
ifrq = p5
isinfn = p6
iextra = p7
ipan = p8
irvbch = p9
iwet = p10

iatt = 0.2

;ipow	pow ifrq, -0.8
;iamp2 = iamp * 440.0 * ipow  ; amp needed to scale output of double resonator

	anoi	multnoise -1.0, 1.0

	;inoidur = 0.5 * ifrq / 440.0
	;anoienv linseg 0.0, 0.01, 1.0, inoidur, 0.0, idur, 0.0
	;anoi	= anoi * anoienv

itime = iextra
ihamdur = 3.0/ifrq
	aoutham hammersound anoi, ifrq, itime, ihamdur
	aoutham = aoutham * iamp * 5
	

	aout =  aoutham

	; Declicking envelop
	kclk	linseg 0.0, 0.001, 1.0, idur-0.001-0.05, 1.0, 0.05, 0.0
	aout	= kclk * aout

	aamb 	= aout
	aamb	butlp aamb, 2000.0
		zawm aamb*iwet, irvbch

		outs (1.0-ipan)*(1.0-iwet)*aout, ipan*(1.0-iwet)*aout

endin


;----------------------------------------------------------------------------
; instrument for feeding sine wave into mywvguide
;----------------------------------------------------------------------------
;i1555 time  idur  iampdb  ifrqhz  ifn icutoff ifdback  iasdel
instr 1555

idur = p3
iampdb = ampdb( p4 )
ifrq = p5
ifn = p6
icutoff = p7
ifdback = p8
iasdel = p9

	kinenv	linseg 0.0, 0.1,  1.0, idur-0.1, 1.0
	asig	oscili iampdb, ifrq , ifn	
	asig	mywvguide asig * kinenv, ifrq, icutoff, ifdback, iasdel
	koutenv	linseg 1.0, idur-0.1, 1.0,  0.1, 0.0
	aout	= asig * koutenv
		outs aout, aout
	

endin

;----------------------------------------------------------------------------
; Instrument for querying the peak in a soundfile
;----------------------------------------------------------------------------

instr 1556  time idur 

	ipeak	filepeak "test.wav"
		print ipeak

endin


;----------------------------------------------------------------------------
; Instrument for playing a soundfile
;----------------------------------------------------------------------------
;
;i1557 time  idur  ifilcod
instr 1557 


idur = p3
ifilcod = p4

	aoutl, aoutr soundin p4
	outs aoutl, aoutr

endin

;----------------------------------------------------------------------------
; click instrument for testing reverb
;----------------------------------------------------------------------------
;i2200  time  idur  iampdb iwet
instr 2200

idur = p3
iamp = ampdb( p4 )
iwet = p5

	ksig	trirand iamp
	kenv 	linseg 0.0, 0.01,  1.0, idur-0.02, 1.0, 0.01, 0.0
	aout	= ksig* kenv
		zawm aout * iwet, 1
		outs aout, aout

endin


;----------------------------------------------------------------------------
; Granular synthesis experiment
;----------------------------------------------------------------------------
;i2250  time  idur  iinstr
;;instr 2250
;;
;;	ki = 0
;;startloop:
;;	if ki > 100 goto done
;;
;;; Figure delay and duration
;;	kdelay	random 0.3, 0.7
;;
;;		event "i", iinstr, kdelay, 0.2
;;	ki = ki + 1
;;		goto startloop
;;done:
;;
;;endin

;----------------------------------------------------------------------------
; Reverb experiment
;----------------------------------------------------------------------------
;i2300  time  idur  iinch igain ipause
instr 2300 

idur = p3
iinch = p4
igain = p5
ipause = p6

igain = igain/20.0

	asig	zar iinch
	asig	= asig * 200.0
		zacl iinch, iinch

	afdback = 0.0
	anull	delayr 2.0
	
atap  deltap 0.308317
afdback = afdback + atap * igain * 0.488733
atap  deltap 0.210783
afdback = afdback + atap * igain * 0.002825


	aout 	= afdback
;	afdback	butbp afdback, 1000.0, 500.0
		delayw afdback + asig

	kenv	linseg 0.0, ipause, 0.0, 0.01, 1.0, idur-ipause-0.01, 1.0
	aout	= aout * kenv
		outs aout, aout

endin


;----------------------------------------------------------------------------
; Reverb 2305 - experiment in very long reverb that washes between
;   channels
;----------------------------------------------------------------------------
;i2305  time  idur iinch  
instr 2305

idur = p3
iinch = p4

	asig	zar iinch
	zacl      iinch, iinch             ; clear for next iteration

;	aout	nestedap asig, 3, 2.0, 1.3, 0.99, 0.7, 0.99, 0.5, 0.99
;	aout	nestedap asig, 1, 2.0, 0.1, 0.9999

	aout1	alpass asig, 5.0, 0.2


	asig2	delayr 0.002
		delayw asig
	aout2	alpass asig2, 4.0, 0.17

	asig3	delayr 0.003
		delayw asig
	aout3	alpass asig3, 4.5, 0.167

	asig4	delayr 0.0047
		delayw asig
	aout4	alpass asig4, 5.0, 0.157

	asig5	delayr 0.002
		delayw asig
	aout5	alpass asig5, 4.0, 0.179

	

	aoutl = (2.0* aout1 + aout2 + aout3 + aout4 + aout5)/6.0
	aoutr = (aout1 + aout2 + aout3 + aout4 + 2.0* aout5)/6.0
	outs aoutl, aoutr

endin

;----------------------------------------------------------------------------
; Reverb 2306 - experiment in very long, distant-sounding
;  reverb that washes between
;   channels
;----------------------------------------------------------------------------
;i2306  time  idur iinch  
instr 2306

idur = p3
iinch = p4

irvt = 5.0
ilowp = 6000.0
ileftdel = 0.002
irightdel = 0.001

	asig	zar iinch
	zacl      iinch, iinch             ; clear for next iteration

	asig	butlp asig, 6000.0
	asig	butbr asig, 1000.0, 100.0
	asig  	butbr asig, 2000.0, 100.0

	asig1	= asig

	asig1_out alpass asig1, irvt, 0.024

	asig2 	butlp asig1_out, 6000.0
	;	asig2	= asig1_out

	asig2_out alpass asig2, irvt, 0.057

	asig3	butlp asig2_out, 6000.0
	;asig3  = asig2_out

	asig3_out alpass asig3, irvt, 0.113

	aout = ( asig1_out + asig2_out + asig3_out )/3.0
	aout = asig3_out

	aoutl	delayr ileftdel
		delayw aout

	aoutr	delayr irightdel
		delayw aout

	outs aoutl+ 0.1*aoutr, aoutr + 0.2*aoutl

endin

;----------------------------------------------------------------------------
; Reverb 2310 from csound book
;----------------------------------------------------------------------------

          instr     2310
istretch  =         p4/3
irvt1     =         .2*istretch
irvt2     =         .5*istretch
irvt3     =         2.1*istretch
irvt4     =         3.06*istretch
adrysig	  zar 1
ar1       alpass    adrysig, irvt1, .04
ar2       alpass    ar1, irvt2, .09653
ar3       alpass    ar2, irvt3, .065
ar4       alpass    ar3, irvt4, .043
arl1      butlp      ar1, 5000
arl2      butlp      ar2, 3000
arl3      butlp      ar3, 1500
arl4      butlp      ar4, 500
arev      =         arl1+arl2+arl3+arl4
          outs       arev*3, arev*3
	  zacl 1, 1
          endin      

;----------------------------------------------------------------------------
; reverb 2314 from Csound book
;----------------------------------------------------------------------------

          instr     2314
adrysig	  zar 1

atmp      alpass    adrysig, 1.7, .1
aleft     alpass    atmp, 1.01, .07
atmp      alpass    adrysig, 1.5, .2
aright    alpass    atmp, 1.33, .05
kdel1     randi     .01, 1, .666
kdel1     =         kdel1+.1
addl1     delayr    .3
afeed1    deltapi   kdel1
afeed1    =         afeed1+gifeed*aleft
          delayw    aleft
kdel2     randi     .01,. 95, .777
kdel2     =         kdel2+.1
addl2     delayr    .3
afeed2    deltapi   kdel2
afeed2    =         afeed2+gifeed*aright
          delayw    aright
aglobin   =         (afeed1+afeed2)*.05
atap1     comb      aglobin, 3.3, gilp1
atap2     comb      aglobin, 3.3, gilp2
atap3     comb      aglobin, 3.3, gilp3
aglobrev  alpass    atap1+atap2+atap3, 2.6, .085
aglobrev  tone      aglobrev, giroll
kdel3     randi     .003, 1,. 888
kdel3     =         kdel3+ .05
addl3     delayr    .2
agr1      deltapi   kdel3
          delayw    aglobrev
kdel4     randi     .003, 1, .999
kdel4     =         kdel4+ .05
addl4     delayr    .2
agr2      deltapi   kdel4
          delayw    aglobrev
arevl     =         agr1+afeed1
arevr     =         agr2+afeed2
          outs      arevl, arevr
	  zacl  1, 1
          endin


;----------------------------------------------------------------------------
; Gardner LARGE ROOM REVERB
;-----------------------------------------------------------------------------
          instr     2404

idur      =         p3
iamp      =         p4
iinch     =         p5

aout91    init      0
adel01    init      0
adel11    init      0
adel51    init      0
adel52    init      0
adel91    init      0
adel92    init      0
adel93    init      0

kdclick   linseg    0, .002, iamp, idur-.004, iamp, .002, 0

; INITIALIZE
asig0     zar       iinch
	  zacl      iinch, iinch             ; clear for next iteration
aflt01    butterlp  asig0, 4000              ; PRE-FILTER
aflt02    butterbp  .5*aout91, 1000, 500     ; FEED-BACK FILTER
asum01    =         aflt01+.5*aflt02         ; INITIAL MIX

; ALL-PASS 1
asub01    =         adel01-.3*asum01         ; FEEDFORWARD
adel01    delay     asum01+.3*asub01,.008    ; FEEDBACK

; ALL-PASS 2
asub11    =         adel11-.3*asub01         ; FEEDFORWARD
adel11    delay     asub01+.3*asub11,.012    ; FEEDBACK

adel21    delay     asub11, .004             ; DELAY 1
adel41    delay     adel21, .017             ; DELAY 2

; SINGLE NESTED ALL-PASS
asum51    =         adel52-.25*adel51        ; INNER FEEDFORWARD
aout51    =         asum51-.5*adel41         ; OUTER FEEDFORWARD
adel51    delay     adel41+.5*aout51,   .025 ; OUTER FEEDBACK
adel52    delay     adel51+.25*asum51, .062 ; INNER FEEDBACK

adel61    delay     aout51, .031             ; DELAY 3
adel81    delay     adel61, .003             ; DELAY 4

; DOUBLE NESTED ALL-PASS
asum91    =         adel92-.25*adel91        ; FIRST  INNER FEEDFORWARD
asum92    =         adel93-.25*asum91        ; SECOND INNER FEEDFORWARD
aout91    =         asum92-.5*adel81         ; OUTER FEEDFORWARD
adel91    delay     adel81+.5*aout91, .120   ; OUTER FEEDBACK
adel92    delay     adel91+.25*asum91, .076 ; FIRST  INNER FEEDBACK
adel93    delay     asum91+.25*asum92, .030 ; SECOND INNER FEEDBACK

aout      =         .8*aout91+.8*adel61+1.5*adel21 ; COMBINE OUTPUTS

          outs      aout*kdclick, -aout*kdclick     ; FINAL OUTPUT

endin

;-----------------------------------------------------------------------------
; CLEAR Zac
          instr     2499
          zacl      0,100
          endin




