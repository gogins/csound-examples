;----------------------------------------------
;          moog.orc 
;	    Code by 
;      Timo Tossavainen
;        tt56361@uta.fi
;----------------------------------------------
	sr = 44100
	kr = 44100
	ksmps = 1
	nchnls = 1
;----------------------------------------------
; Analoguish Bassline Synth using the Moog VCF
;----------------------------------------------
	instr	1
;----------------------------------------------
; p2 = start
; p3 = duration
;----------------------------------------------
; p4 = pitch
; p5 = vel
; p6 = cutoff (0..1)
; p7 = resonance (0..4)
; p6 = env to cutoff
;----------------------------------------------

imax	init ampdb(90)

; controllers

idur	= p3
kpit	= p4
kvel	= p5
kcut	= p6
krez	= p7
kenvtof = p8

kf	init 0
kfb	init 0
kscale	init 0

aout1	init 0	; Moog VCF vars
aout2	init 0
aout3	init 0
aout4	init 0
aout	init 0
ain1	init 0
ain2	init 0
ain3	init 0
ain4	init 0

;---------- K update

kenv	expon	1, idur, 0.1 ; envelope to cutoff and amp
kf 	= 1.16 * (kcut + kenv * kenvtof) ; cutoff 
kf	= (kf > 1.16 ? 1.16 : kf) 	 ; (limit <= 1.16)
kfb	= krez * (1.0 - 0.15 * kf * kf)  ; resonance
kscale	= kf / 1.3			 ; onepole scaling coeff

;---------- A update

aosc	oscili imax, cpspch(kpit), 1

	;---------- the Moog VCF ----

api	= aosc - (kfb * aout4)

at1	= kscale * api	
aout1	= at1 + 0.3 * ain1 + (1.0 - kf) * aout1 ; pole 1
ain1	= at1
at2	= kscale * aout1
aout2	= at2 + 0.3 * ain2 + (1.0 - kf) * aout2 ; pole 2
ain2	= at2
at3	= kscale * aout2
aout3	= at3 + 0.3 * ain3 + (1.0 - kf) * aout3 ; pole 3
ain3	= at3
at4	= kscale * aout3
aout4	= at4 + 0.3 * ain4 + (1.0 - kf) * aout4 ; pole 4
ain4	= at4

aout	= aout4 * kenv;

	out	aout
endin






