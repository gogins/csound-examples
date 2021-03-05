<CsoundSynthesizer>
<CsOptions>
csound -RWm7o ./moog.wav ./temp.orc ./temp.sco
</CsOptions>
<CsInstruments>
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






</CsInstruments>
<CsScore>
; moog.sco
; by Timo Tossavainen, tt56361@uta.fi
; saw table

f1 0 4096 7 1 4096 -1
t 0 160

; score
;ins beg  dur  pit   vel  cut  rez  env
i1   0.0  0.6  7.03  0.9  0.02 3.6  0.01
i1   0.5  0.6  6.07  .    .    .    .
i1   1.0  0.6  7.00  .    .    .    .
i1   1.5  0.6  7.03  .    .    .    0.02
i1   2.0  0.6  7.03  .    .    .    .
i1   2.5  0.6  6.07  .    .    .    .
i1   3.0  0.6  7.00  .    0.02 .    0.03
i1   3.5  0.6  7.03  .    .    .    .

i1   4.0  0.6  7.03  0.9  0.02 3.6  0.04
i1   4.5  0.6  6.08  .    .    .    .
i1   5.0  0.6  7.00  .    0.03 .    .
i1   5.5  0.6  7.03  .    .    .    .
i1   6.0  0.6  7.03  .    0.05 .    .
i1   6.5  0.6  6.08  .    .    .    .
i1   7.0  0.6  7.00  .    0.07 .    .
i1   7.5  0.6  7.03  .    .    .    .

i1   8.0  0.6  7.05  0.9  0.1 3.6  0.08
i1   8.5  0.6  6.08  .    0.11 .    .
i1   9.0  0.6  7.00  .    0.12 .   0.1
i1   9.5  0.6  7.05  .    0.13 .    .
i1  10.0  0.6  7.05  .    0.15 .   0.15
i1  10.5  0.6  6.08  .    0.16 .    .
i1  11.0  0.6  7.00  .    0.17 .   0.2
i1  11.5  0.6  7.05  .    0.18 .    .

i1  12.0  0.6  7.03  0.9  0.2 3.6  0.3
i1  12.5  0.6  6.08  .    .    .    .
i1  13.0  0.6  7.00  .    .    .    .
i1  13.5  0.6  7.03  .    0.4 3.65  .
i1  14.0  0.6  7.02  .    .    .    .
i1  14.5  0.6  6.07  .    0.45 .    .
i1  15.0  0.6  6.10  .    .   3.7   .
i1  15.5  0.6  7.02  .    0.6 3.8   .

i1  16.0  0.6  7.03  0.9  0.7 3.9  0.3
i1  16.5  0.6  6.07  .    .    .    .
i1  17.0  0.6  7.00  .    .    .    .
i1  17.5  0.6  7.03  .    .    .    .
i1  18.0  0.6  7.03  .    .    .    .
i1  18.5  0.6  6.07  .    0.6  .    .
i1  19.0  0.6  7.00  .    0.55 .    .
i1  19.5  0.6  7.03  .    0.50 .    .

i1  20.0  0.6  7.03  0.9  0.45 3.95  0.3
i1  20.5  0.6  6.08  .    0.40 .    .
i1  21.0  0.6  7.00  .    0.37 .    .
i1  21.5  0.6  7.03  .    0.34 .    .
i1  22.0  0.6  7.03  .    0.30 .    .
i1  22.5  0.6  6.08  .    0.27 .    .
i1  23.0  0.6  7.00  .    0.24 .    .
i1  23.5  0.6  7.03  .    0.20 .    .

i1  24.0  0.6  7.05  0.9  0.19 4.0 0.3
i1  24.5  0.6  6.08  .    0.17 .    .
i1  25.0  0.6  7.00  .    0.16 .    .
i1  25.5  0.6  7.05  .    0.15 .   0.25
i1  26.0  0.6  7.05  .    0.14 .    .
i1  26.5  0.6  6.08  .    0.13 .    .
i1  27.0  0.6  7.00  .    0.12 .   0.1
i1  27.5  0.6  7.05  .    0.11 .    .

i1  28.0  0.6  7.03  0.9  0.10 3.9 0.1
i1  28.5  0.6  6.08  .    0.09 .   0.08
i1  29.0  0.6  7.00  .    0.08 .   0.06
i1  29.5  0.6  7.03  .    0.07 .   0.05
i1  30.0  0.6  7.02  .    0.06 .   0.04
i1  30.5  0.6  6.07  .    0.05 .    .
i1  31.0  0.6  6.10  .     .   .    .
i1  31.5  0.6  6.02  .     .   .    .

i1  32.0  5.0  6.00  0.9  0.06 .   0.04
e



























</CsScore>
</CsoundSynthesizer>
