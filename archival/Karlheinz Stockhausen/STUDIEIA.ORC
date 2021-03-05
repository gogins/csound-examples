; studie no 2 orchestra file
; each instrument is based on a simple composite instrument with 5 oscillators
;	each oscillator is tuned based on the 'giscaler1', as well as an instrument
;	multiplier. ie;
;		instrument 1
;			osc 1 freq = inputfreq
;			osc 2 freq = osc 1 freq * giscaler1
;			osc 3 freq = osc 2 freq * giscaler1
;			osc 4 freq = osc 3 freq * giscaler1
;			osc 5 freq = osc 4 freq * giscaler1

; dependancies
;	1. requires function table number one to be set up with the waveform to be used for the oscillators

sr = 44100
kr = 4410
ksmps = 10
nchnls = 1

; the scalers are used to generate the frequencies for the oscillators
;	above the base frequency taken from p4
giscaler1	=	1.066494942
giscaler2	=	giscaler1 * giscaler1
giscaler3	=	giscaler2 * giscaler1
giscaler4	=	giscaler3 * giscaler1
giscaler5	=	giscaler4 * giscaler1

; p1 ins
; p2 time
; p3 duration
; p4 pitch
; p5 startamp
; p6 endamp

instr	1, 11, 21, 31, 41
; this, and all variations, use a multiplier of 1 to generate the scale steps
	ifreq1		=	p4
	ifreq2		=	ifreq1 * giscaler1
	ifreq3		=	ifreq2 * giscaler1
	ifreq4		=	ifreq3 * giscaler1
	ifreq5		=	ifreq4 * giscaler1

	iampstart	=	ampdb(p5 + 74)
	iampend		=	ampdb(p6 + 74)

	iatt		=	.01
	irel		=	.01
	idur		=	p3 - (iatt + irel)

;	print		ifreq1, ifreq2, ifreq3, ifreq4, ifreq5
;	print		iampstart, iampend
;	print		iatt, idur, irel

	kenv		linseg		0, iatt, iampstart, idur, iampend, irel, 0

	aosc1		oscili		kenv, ifreq1, 1
	aosc2		oscili		kenv, ifreq2, 1
	aosc3		oscili		kenv, ifreq3, 1
	aosc4		oscili		kenv, ifreq4, 1
	aosc5		oscili		kenv, ifreq5, 1

	out			aosc1 + aosc2 + aosc3 + aosc4 + aosc5
endin

instr	2, 12, 22, 32, 42
	ifreq1		=	p4
	ifreq2		=	ifreq1 * giscaler2
	ifreq3		=	ifreq2 * giscaler2
	ifreq4		=	ifreq3 * giscaler2
	ifreq5		=	ifreq4 * giscaler2

	iampstart	=	ampdb(p5 + 74)
	iampend		=	ampdb(p6 + 74)

	iatt		=	.01
	irel		=	.01
	idur		=	p3 - (iatt + irel)

;	print		ifreq1, ifreq2, ifreq3, ifreq4, ifreq5
;	print		iampstart, iampend
;	print		iatt, idur, irel

	kenv		linseg		0, iatt, iampstart, idur, iampend, irel, 0

	aosc1		oscili		kenv, ifreq1, 1
	aosc2		oscili		kenv, ifreq2, 1
	aosc3		oscili		kenv, ifreq3, 1
	aosc4		oscili		kenv, ifreq4, 1
	aosc5		oscili		kenv, ifreq5, 1

	out			aosc1 + aosc2 + aosc3 + aosc4 + aosc5
endin

instr	3, 13, 23, 33, 43
	ifreq1		=	p4
	ifreq2		=	ifreq1 * giscaler3
	ifreq3		=	ifreq2 * giscaler3
	ifreq4		=	ifreq3 * giscaler3
	ifreq5		=	ifreq4 * giscaler3

	iampstart	=	ampdb(p5 + 74)
	iampend		=	ampdb(p6 + 74)

	iatt		=	.01
	irel		=	.01
	idur		=	p3 - (iatt + irel)

;	print		ifreq1, ifreq2, ifreq3, ifreq4, ifreq5
;	print		iampstart, iampend
;	print		iatt, idur, irel

	kenv		linseg		0, iatt, iampstart, idur, iampend, irel, 0

	aosc1		oscili		kenv, ifreq1, 1
	aosc2		oscili		kenv, ifreq2, 1
	aosc3		oscili		kenv, ifreq3, 1
	aosc4		oscili		kenv, ifreq4, 1
	aosc5		oscili		kenv, ifreq5, 1

	out			aosc1 + aosc2 + aosc3 + aosc4 + aosc5
endin

instr	4, 14, 24, 34, 44
	ifreq1		=	p4
	ifreq2		=	ifreq1 * giscaler4
	ifreq3		=	ifreq2 * giscaler4
	ifreq4		=	ifreq3 * giscaler4
	ifreq5		=	ifreq4 * giscaler4

	iampstart	=	ampdb(p5 + 74)
	iampend		=	ampdb(p6 + 74)

	iatt		=	.01
	irel		=	.01
	idur		=	p3 - (iatt + irel)

;	print		ifreq1, ifreq2, ifreq3, ifreq4, ifreq5
;	print		iampstart, iampend
;	print		iatt, idur, irel

	kenv		linseg		0, iatt, iampstart, idur, iampend, irel, 0

	aosc1		oscili		kenv, ifreq1, 1
	aosc2		oscili		kenv, ifreq2, 1
	aosc3		oscili		kenv, ifreq3, 1
	aosc4		oscili		kenv, ifreq4, 1
	aosc5		oscili		kenv, ifreq5, 1

	out			aosc1 + aosc2 + aosc3 + aosc4 + aosc5
endin

instr	5, 15, 25, 35, 45
	ifreq1		=	p4
	ifreq2		=	ifreq1 * giscaler5
	ifreq3		=	ifreq2 * giscaler5
	ifreq4		=	ifreq3 * giscaler5
	ifreq5		=	ifreq4 * giscaler5

	iampstart	=	ampdb(p5 + 74)
	iampend		=	ampdb(p6 + 74)

	iatt		=	.01
	irel		=	.01
	idur		=	p3 - (iatt + irel)

;	print		ifreq1, ifreq2, ifreq3, ifreq4, ifreq5
;	print		iampstart, iampend
;	print		iatt, idur, irel

	kenv		linseg		0, iatt, iampstart, idur, iampend, irel, 0

	aosc1		oscili		kenv, ifreq1, 1
	aosc2		oscili		kenv, ifreq2, 1
	aosc3		oscili		kenv, ifreq3, 1
	aosc4		oscili		kenv, ifreq4, 1
	aosc5		oscili		kenv, ifreq5, 1

	out			aosc1 + aosc2 + aosc3 + aosc4 + aosc5
endin


