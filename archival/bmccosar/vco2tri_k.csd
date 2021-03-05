<CsoundSynthesizer>

;
;	vco2sqr: keys derivative.
;	Bruce H. McCosar
;
;	$Id: vco2tri_k.csd 23 2008-05-11 17:49:49Z mccosar $
;

<CsOptions>

; Standard file output, from a numeric score
; ---------------------------------------------------------------------------
; -Wdo test.wav

; Realtime midi & JACK audio output
; ---------------------------------------------------------------------------
-d -+rtaudio=jack -o dac:system:playback_ -+rtmidi=alsa -M hw:1,0,1 -b 256 -B 512

</CsOptions>

<CsInstruments>

; ==================================================================== HEADER

sr	=	44100
kr	=	4410
ksmps	=	10
nchnls	=	2

; ============================================================ MACRO CONTROLS

#define	MAXVOL	#50#

; =============================================================== INSTRUMENTS

	instr	1
	;
	;	vco2 instrument
	;	---------------
	;	With increasing note velocity:
	;	* the release time increases slightly.
	;	* the pulse width and phase variation increases.
	;
ivel	veloc
icps	cpsmidi
	;
	;	kamp,         irise, idec,       iatdec
kamp	linenr	ivel*$MAXVOL, 0.01,  0.001*ivel, 0.01
	;	kamp, kcps,  itype
kpw	lfo	0.004*ivel,  1.947, 1
kphs	lfo	0.004*ivel,  2.193, 1
	;	iamp, icps, imode
a0	vco2	kamp, icps, 12
	;	kamp, kcps,       imode, kpw,     kphs
a1	vco2	kamp, icps*1.007, 20,    kpw+0.5, kphs+0.5
a2	vco2	kamp, icps*0.993, 20,    kpw+0.5, kphs+0.5
	;
kcf1	lfo	ivel, 4.544, 0
kcf2	expon	ivel*6, ivel*0.01, ivel*2
aL	moogladder a0+a1, kcf1+kcf2+icps, 0.3
aR	moogladder a0+a1, kcf1+kcf2+icps, 0.3
	;
	outs	aL, aR
	;
	endin

</CsInstruments>

<CsScore>

; ================================================================== F-TABLES

; #	time	size	GEN	parameters
f 0	9999

</CsScore>

</CsoundSynthesizer>

