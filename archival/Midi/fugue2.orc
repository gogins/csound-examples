sr=44100
kr=4410
ksmps=10
nchnls=2

instr 1
	; A semitone 2^(1/12)
	isem	=		.059463094

	; Get midi note
	inote	cpsmidi

	; Get pitch bend and find the 2 semitone bend cps
	kpbend	pchbend ;		(2 * isem * inote)

	; Mod wheel
	kmodw	midictrl	1

	; Ctl 6 for pan scaled to 1
	kctl6	midictrl	6
	kctl6 = kctl6 / 127

	; Ctl 4 for vibrato speed
	kctl4	midictrl	4
	kctl4 = kctl4 / 127

	; Ctl 5 for mod index
	kctl5	midictrl	5
	kctl5 = kctl5 / 127

	; After touch scaled to 1
	kafter	chpress		1

	; Velocity
	ivel	veloc

	; Keyboard gate
	kgate	linenr		ivel / 127, 0, .5, .01

	; LFO oscilator
	klfo	oscil		kmodw * inote / 2400, 10 * kctl4, 1

	; Audio oscilator
	aoscm	oscil		1000 * kctl5, inote + kpbend, 1
	aosc	oscil		2500, inote + kpbend + klfo + aoscm, 1

	; Set up and execute a lowpass filter
	ilofr	=		100
	ihifr	=		sr/2 - ilofr
	kafter	port		kafter, 2/kr
	afilt	tone		aosc, (kafter * ihifr) + ilofr
	aq	reson		aosc, (kafter * ihifr) + ilofr, 100

	; Mixer and output
	aout	=	(afilt + aq/10)/10
	outs	aout * kgate * kctl6, aout * kgate * (1 - kctl6)
endin
