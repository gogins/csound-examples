<CsoundSynthesizer>
<CsOptions>
-RWZfo risset-flute-mkg.wav
</CsOptions>
<CsInstruments>
sr = 88200
ksmps = 1
nchnls = 1

ga1 init 0

; ========================================== ;
; ============ Flute-like #100 ============= ;
; ========================================== ;

instr 1
  if p12 = 12 igoto dc1
	i1 = .6
  goto start

  dc1:
	i1 = .74
  goto start

  start:
	k1	 randi (p4*.01),p9
	k1 = k1 + p4
	k2	 oscili k1,1/p11,p12
	k2 = k2 + i1
	k3	 oscili k2,1/p6,p9
	a1	 oscili k3,p5,p10
	a2 = a1*10
	ga1 = ga1+(p13*a2)			  ;p13 = rvb send level
	out  a2
endin


instr 2
	k1 oscili p4,1/p6,p7
	k2 oscili p5,1/p6,p8
	a1 oscili k1,k2,1
	a2=a1*10
	ga1 = ga1+(p9*a2)			 ;p9 = rvb send level
	out a2
endin

; ========================================== ;
; =======  Global Reverb Instrument  ======= ;
; ========================================== ;

 instr 6
   ga1	init 0
	a1	 reverb ga1,p4		   ;p4=reverb time in seconds
	a2 = a1*p5				   ;p5=reverb return level
	out a2
   ga1 = 0
 endin
</CsInstruments>
<CsScore>
; ================================================================== ;
; ========	Score for Risset's "Flute-Like" Instrument(s)  ========= ;
; ================================================================== ;

  ; Waveforms: Instrument 1

f1 0 65537 9 1 1 0					; fundamental
f2 0 65537 10 1 .2 .08 .07			; four harmonics
f3 0 65537 10 1 .4 .2 .1 .1 .05		; six harmonics

   ; Amplitude Envelope Functions: Instrument 1

f4 0 512 7 0 1 0 49 .2 90 .6 40 .99 25 .9 45 .5 50 .25 50 .12 50 .06 50 .02 62 0
f5 0 512 7 0 1 0 49 .2 100 .6 50 .99 150 .2 162 0
f6 0 512 7 0 1 0 49 .2 200 .5 100 .2 162 0
f7 0 512 7 0 1 0 79 .5 60 .5 20 .99 120 .4 140 .6 92 0

   ; Amplitude Envelope Fynctions: Instrument 2

f8 0 512 7 0 1 0 149 .4 200 .99 50 .5 50 .24 62 0

   ; Pitch Envelope Functions: Instrument 2

f9 0 512 7 0 1 .895 511 .99
f10 0 512 7 0 1 .99 511 .99

	; DC bias functions

f12 0 512 9 1 .26 0
f13 0 512 9 1 .3 0

; ================ "Flute-like" Score =============== ;

i6	0	   17	  1.3	.5	  ; Turn on Reverb

i2	 .88   .12	 1200	988   .12	8	10	  .5
i1	1	  2 	  800  1109  2	   20	60	 5	 2	.24   12  .5
i2	1	   .7	  300  1107   .7	8	10	  .5
i1	3	   .9	  300	784   .9   30	50	 4	 2	.24   13  .5
i2	4.5    .15	 1200  1397   .2	4	10	  .5
i2	4.85   .15	 1200	992   .15	8	 9	  .5
i2	5.01   .7	  300  1100   .7	8	 9	  .5
i1	5.01  2 	 1200  1109  2	   30	80	 6	 2	.24   13  .5
i1	7	   .2	  400	784   .2   40	70	 7	 2	.24   13  .5
i1	7.2    .3	  300	698   .3   30	60	 5	 2	.24   13  .5
i1	7.51  1 	  300	370  1	   30	50	 6	 3	.24   13  .5
i2	7.5    .5	  150	368   .5	8	 9
i1	8.5    .5	  400	415   .5   50	60	 5	 3	.24   13  .5
i1	9	   .12	  900  1396   .12  30	80	 4	 2	.24   13  .5
i1	9.1   1.2	  900  1568  1.2   30	90	 4	 2	.24   13  .5
i1	10.25 1 	  900	277  1.08  40	60	 7	 3	.31   13  .5
i2	10.25 1 	  200	275  1 6   10
i1	11.35  .36	  500	329   .36  30	60	 5	 2	.28   13  .5
i1	11.72  .36	  800	528   .36  30	60	 5	 2	.28   13  .5
i2	12.09  .2	  950  2217   .2 6	9
i1	12.10  .15	  700  1975   .15  40	90	 5	 1	.28   13  .5
i1	12.25 2.5	  999  2217  2.5   40	90	 4	 1	.28   13  .5
e
</CsScore>
</CsoundSynthesizer>
