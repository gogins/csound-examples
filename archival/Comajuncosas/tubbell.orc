sr = 44100
kr = 44100
ksmps = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 1; simple FM Tubular Bell
; from Nicky Hind´s CLM tutorials (CCRMA, 1995)
; ported to Csound by Josep M Comajuncosas / Aug´98
; better if you avoid playing low pitches and/or high amps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ifreq = cpspch(p4)

; amplitude controlled by a gaussian noise generator
seed p2*ifreq; rounded to a 16 bit integer
iamp igauss 1
iamp = .25+iamp/4; I like amplitudes till ~.5 max.

iamp1 = .5
iamp2 = .25
iamp3 = .25

indexmin = .15

index1scl = 3
index2scl = 2
index3scl = 1

ic1ratio = 2
ic2ratio = .6
ic3ratio = .22

im1ratio = 5
im2ratio = 4.8
im3ratio = .83

kampenv   oscil1i 0, 1, p3, 2
kindexenv oscil1i 0, 1, p3, 3

ifactor ipow (261.5/ifreq),3
index1max = iamp*index1scl*ifactor
index2max = iamp*index2scl*ifactor
index3max = iamp*index3scl*ifactor

kindexenv1 = indexmin + (index1max-indexmin)*kindexenv*im1ratio
kindexenv2 = indexmin + (index2max-indexmin)*kindexenv*im2ratio
kindexenv3 = indexmin + (index3max-indexmin)*kindexenv*im3ratio

a1 foscili iamp*iamp1*kampenv, ifreq, ic1ratio, im1ratio, kindexenv1, 1
a2 foscili iamp*iamp2*kampenv, ifreq, ic2ratio, im2ratio, kindexenv2, 1
a3 foscili iamp*iamp3*kampenv, ifreq, ic3ratio, im3ratio, kindexenv3, 1

	out 32000*(a1+a2+a3)

endin