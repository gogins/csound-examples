<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;=============================================================================
;
; *** BLUECUBE ***
; Kim Cascone
;
;=============================================================================

sr = 48000
ksmps = 1
nchnls = 2

;=====================================
; reverb initialization
;=====================================
garvbsig init 0


;=====================================
; delay initialization
;=====================================
gasig init 0

;==================================
; INSTRUMENT 1 - three branch instr
;==================================
instr 1
i1 = p5*.3
i2 = p4*.98
i3 = 1/p3
i4 = p5*.6
i5 = p4
kfreq1 = p6
kfreq2 = p7
akamp2 = p8
;=============================================
; 1 - noise branch
;=============================================
a1 randi i4, p9 ;i4 WAS p5
a1 poscil3 a1, i3, 10
a1 poscil3 a1, 3000, 11 ;a1 IS THE NOISE OUTPUT
;===========================================
; 2 - RM branch
;===========================================
akamp1 linen akamp2, p3*.2, p3, p3*.2
asig1 poscil3 akamp1, kfreq1, 11 ; AMP IS CONTROLLED BY LINEN, FREQ IS CONTROLLED BY p6
asig2 poscil3 akamp2, kfreq2, 3 ; AMP IS CONTROLLED BY p8, FREQ IS CONTROLLED BY p7
aosc2 = asig1*asig2
a2 = aosc2*.085 ; THE OUTPUT a2 IS SCALED
;================================
; 3 - low sine branch
;================================
k3 poscil3 i4, i3, 8 ; f8 = EXP ENV
a3 poscil3 k3, i5, 4 ; f4 = SINE WAVE (LO RES)
a3 = a3*.5 ; a3 PROVIDES THE LOW SINE TONE
;output to filter, reverb and panning
;=====================================
iamp = p8*.4
aout = a1+a2+a3
kcf linseg 0,p3/2,850,p3/2,0 ; THIS CONTROLS THE FILTER FRQ
akpan poscil3 1,0.1,17 ; TRIANGLE WITH OFFSET (0-1) CONTROLS PANNING
alp butterlp aout, kcf ; THREE BRANCHES ARE MIXED & FED THROUGH BUTTERLP
akenv linen iamp,p3*.8,p3,p3*.2 ; THIS IS THE MAIN ENV ON THE OUTPUT
alpout = akenv*alp
outs alpout*akpan,alpout*(1-akpan) ; STEREO OUTS 
garvbsig = garvbsig+(alpout*.2) ; SEND .2 OF THE SIG TO RVB
prints "Three branch   p1 %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
endin

;=================================================
; INSTRUMENT 2 --- a noise band glissando
;=================================================
instr 2
kfreq = p5
akramp linseg 0,p3*.8,p4,p3*.2,0 ; THIS CONTROLS THE AMP OF RANDI
akenv1 linen p4,0, p3,10 ; THIS CONTROLS THE FRQ OF RANDI
anoise randi akramp,akenv1
aosc poscil3 anoise,kfreq,11 ; ANOISE IS FED TO THE A INPUT OF AOSC
akpan poscil3 1,.09,1
aosc2 reson aosc,akpan+100,100,2 ; KPAN+100 IS OFFSET FOR FILTER SWEEP INPUT
outs aosc2*akpan,aosc2*(1-akpan)
garvbsig = garvbsig+(aosc2*.2)
prints "Noise band gli p1 %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
endin

;===============================================
; INSTRUMENT 3 - a sinewave instrument
;===============================================
instr 3
akpan = p6
i1 = p5*3
ak1 poscil3 i1, 1/p3, 10 ; ADSR
a2 poscil3 ak1, p4, 11 ; SINE
outs a2*akpan,a2*(1-akpan)
garvbsig = garvbsig+(a2*.1)
prints "Sinewave       p1 %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
endin

;=================================================================
; INSTRUMENT 4 - SAMPLE & HOLD
;=================================================================
instr 4
krt = p6 ; THIS IS THE FRQ OF THE RANDH OUTPUT & CLK OSC
isd =p4 ; p4 HOLDS THE VALUE OF THE SEED OF RANDH UG
krn randh 1000,krt,isd ; NOISE INPUT TO S&H
kclk poscil3 100,krt,14 ; KCLK CLOCKS THE S&H -- f14 IS A DUTY CYCLE WAVE
ksh samphold krn, kclk ;S&H
a2 poscil3 600, ksh,11 ; SINE OSC CONTROLLED BY S&H;;;amp=600
a3 poscil3 a2,1/p3,10 ; f10=ADSR -- a3 IS THE OUTPUT
akpan poscil3 1,.04,17
asig1 = a3*akpan
asig2 = a3*(1-akpan)
outs asig1,asig2
garvbsig = garvbsig+(a3*.2)
prints "Sample & Hold  p1 %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
endin

;======================================================
; INSTRUMENT 5 - FM w/reverse env
;======================================================
; CHANGES TO INSTR 5
;____________ _______________________
;make A arg in fposcil3 = 10
;put fposcil3 out into osc w/f18
;the effect I want is a cascade of short b'wards FM sounds that go from
;right to left...subtle yet present...like a flock of metal birds
;========================================================================
instr 5
kcps = p4
kcar = p5
kmod = p6
kpan = p7 ; SCORE DETERMINES PAN POSITION
kndx = p8 
kamp = p9
krvb = p10
;kcar line 2,p3*.9,0
;kenv poscil3 3,1/p3,10
afm foscili kamp,kcps,kcar,kmod,kndx,11 ; f11 = HIRES SINE WAVE
afm1 poscil3 afm,1/p3,18
afm2 = afm1*400 ; THIS INCERASES THE GAIN OF THE FOSCILI OUTx400
;krtl = sqrt(kpan) ; SQRT PANNING TECHNIQUE
;krtr = sqrt(1-kpan) ; pg 247,FIG.7.20 DODGE/JERSE BOOK
krtl = sqrt(2)/2*cos(kpan)+sin(kpan) ; CONSTANT POWER PANNING
krtr = sqrt(2)/2*cos(kpan)-sin(kpan) ; FROM C.ROADS "CM TUTORIAL" pp460
al = afm2*krtl
ar = afm2*krtr
outs al,ar
;outs afm2*kpan,afm2*(1-kpan)
garvbsig = garvbsig+(afm2*krvb) ; SEND AMOUNT WAS .2
prints "FM Rev Env     p1 %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
endin

;==================================================
; INSTRUMENT 6 - clicky filter sweep w/pan
;
; take a noise source and bp filter
; pass to amp => lp filter
; then pan across stereo field 
;=================================================
instr 6
aclk = p3*4.3 ; THIS IS THE FRQ FOR THE FILTER AND ADSR
; [THIS COMMENT ABOVE DIDN'T HAVE A ";" BEFORE IT
; AND MIGHT HAVE NOT HAD AN EFFECT ON THE CODE] 2/16
;arnd randi 7000, 5000 ; NOT USING THIS NOISE SOURCE::USING PULSE INSTEAD
apls poscil3 7000,aclk,2 ; THIS GENERATES A SMALL SPIKE SHAPED LIKE A EXP ENV f2
abp butterbp apls,2500,200 ; THIS FILTERS THE SPIKE SO ITS MORE CLICKY SOUNDING
abp = abp*3 ; THIS BOOSTS THE LEVEL OF THE FILTER OUT
anoise poscil3 abp,aclk,8 ; THIS GIVES THE FILTERED SIGNAL THE SAME ENV AS THE WAVEFORM 
akswp line 1800,p3,180 ; THIS CONTROLS THE RESON FILTER::STRT frq=1800, END frq=180
;kswp expon 2600,p3,300
afilt reson anoise,akswp,20 ; RESON CREATES A FILTER SWEEP
;afilt = afilt*.4
afilt2 poscil3 afilt,1/p3,10 ; THIS ENVELOPES THE FILTER OUTPUT
akpan line 0,p3*.8,1 ; THIS IS USED FOR THE PANNING OF THE OUTPUT
afilt2 = afilt2*.05 ; tHIS SCALES THE OUTPUT OF THE FILTER 
outs afilt2*akpan,afilt2*(1-akpan)
garvbsig = garvbsig+(afilt2*.02)
gasig = gasig+(afilt2*.6)
prints "Clicky sweep p 1 %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
endin

;======================================================
; INSTR 8 -- CASCADE HARMONICS
; [borrowed instr from Risset]
;======================================================
instr 8
i1 = p6 ; INIT VALUES CORRESPOND TO FREQ.
i2 = 2*p6 ; OFFSETS FOR OSCILLATORS BASED ON ORIGINAL p6
i3 = 3*p6
i4 = 4*p6
ampenv linen p5,30,p3,30 ; ENVELOPE
a1 poscil3 ampenv,p4,20
a2 poscil3 ampenv,p4+i1,20 ; NINE OSCILLATORS WITH THE SAME AMPENV
a3 poscil3 ampenv,p4+i2,20 ; AND WAVEFORM, BUT SLIGHTLY DIFFERENT
a4 poscil3 ampenv,p4+i3,20 ; FREQUENCIES TO CREATE THE BEATING EFFECT
a5 poscil3 ampenv,p4+i4,20
a6 poscil3 ampenv,p4-i1,20 ; p4 = fREQ OF FUNDAMENTAL (Hz)
a7 poscil3 ampenv,p4-i2,20 ; p5 = AMP
a8 poscil3 ampenv,p4-i3,20 ; p6 = INITIAL OFFSET OF FREQ - .03 Hz
a9 poscil3 ampenv,p4-i4,20
asnd = (a1+a2+a3+a4+a5+a6+a7+a8+a9)/9
;outs a1+a2+a3+a4,a5+a6+a7+a8+a9
outs a1+a3+a5+a7+a9,a2+a4+a6+a8
garvbsig = garvbsig+(asnd*.85)
prints "Risset Cascade p1 %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
endin

;=================================================================
; INSTRUMENT 9 -- WATER
;=================================================================
instr 9
krt = p6 ; THIS IS THE FRQ OF THE RANDH OUTPUT & CLK OSC
isd = p4 ; p4 HOLDS THE VALUE OF THE SEED OF RANDH UG
krn randh 10000,krt,isd ; NOISE INPUT TO S&H
kclk poscil3 100,krt,14 ; KCLK CLOCKS THE S&H -- f14 IS A DUTY CYCLE WAVE
ksh samphold krn, kclk ; S&H
a2 poscil3 2, 100,11 ;; SINE OSC (11) CONTROLLED BY S&H;;;AMP=600
ksh = ksh*.50
a4 reson a2,ksh,50 ; FILTER WITH S&H CONTROLING THE Fc
a3 poscil3 a4,1/p3,10 ; f10=ADSR -- a3 IS THE OUTPUT
a3 = a3*.15
akpan poscil3 1,.14,17
asig1 = a3*akpan
asig2 = a3*(1-akpan)
outs asig1,asig2
garvbsig = garvbsig+(a3*.4) ; .2
prints "Water          p1 %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
endin

;===================
; GLOBAL REVERB
;===================
instr 99
a1 reverb2 garvbsig, p4, p5
outs a1,a1
garvbsig = 0
prints "Global Reverb  p1 %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
endin

;====================
; GLOBAL DELAY
;====================
instr 98 ; THIS DELAY IS IN PARALLEL CONFIG
a1 delay gasig,p4 ; DELAY=1.25
a2 delay gasig,p4*2 ; DELAY=2.50
outs a1,a2
gasig = 0
prints "Global Delay   p1 %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
endin

</CsInstruments>
<CsScore>
;================================================================
; bluecube.sco
;===============================================================

f1 0 65537 9 1 1 0 ;sine lo-res
f2 0 512 5 4096 512 1 ;exp env
f3 0 65537 9 10 1 0 16 1.5 0 22 2 0 23 1.5 0 ;inharm wave
f4 0 65537 9 1 1 0 ;sine
f8 0 512 5 256 512 1 ;exp env
f9 0 512 5 1 512 1 ;constant value of 1
f10 0 512 7 0 50 1 50 .5 300 .5 112 0 ;ADSR
f11 0 65537 10 1 ;SINE WAVE hi-res
f13 0 1024 7 0 256 1 256 0 256 -1 256 0 ;triangle
f14 0 512 7 1 17 1 0 0 495 ;pulse for S&H clk osc
f15 0 512 7 0 512 1 0 ;ramp up;;;left=>right
f16 0 512 7 1 512 0 0 ;ramp down;;;right=>left
f17 0 1024 7 .5 256 1 256 .5 256 0 256 .5 ;triangle with offset
f18 0 512 5 1 512 256 ;reverse exp env
f20 0 65537 10 1 0 0 0 .7 .7 .7 .7 .7 .7 ;approaching square
;------------------------------------------------------------------------

;this is for reverb settings
;===========================
;p1 p2 p3 p4 p5
;instr strt dur rvbtime hfdif
i99 0 190 6 .2

;this is for the delay line
;==========================
;p1 p2 p3 p4
;instr strt dur dltime
i98 0 190 .66 

 ;straight line
; f.losin namp| ring mod__________| noisefrq
;p1 p2 p3 p4 p5 p6 p7 p8 p9
;instr strt dur freq amp kfreq1 kfreq2 kamp2 nfrq
i1 5.00 40 200 6000 60 134 50 70
i1 10.00 10 300 6000 32 83 . 2000 
i1 23.00 20 400 5000 863 638 . 350
i1 45.00 15 100 6000 400 210 . 100
i1 50 10 440 3500 60 120 . 440
i1 60 20 500 5000 500 450 . 1000
i1 75 30 220 4000 250 700 . 660
i1 90 10 300 2600 385 187 . 345
i1 100 23 230 2300 320 567 . 777
i1 120 30 440 4400 765 974 . 958
i1 140 30 300 3500 250 120 . 458
i1 160 20 450 4500 385 700 30 600
i1 175 15 220 4000 550 320 10 1200
i1 180 10 240 3450 430 340 3 2000

;p1 p2 p3 p4 p5
;instr strt dur envamp kfreq
i2 0.000 60 1500 1000
i2 10.00 50 . 1700
i2 20.00 40 . 2100
i2 30 60 . 1997 ;this i was strt=0.000 but was changed to 20
i2 50 40 . 1250
i2 70 30 . 2300 ;this starts new notes
i2 90 50 1000 3000
i2 120 20 700 2400
i2 160 30 500 1600
i2 170 20 200 2600

;p1 p2 p3 p4 p5 p6
;instr strt dur frq amp kpan
i3 0 .125 100 2000 1
i3 0.5 .125 200 1000 0.5
i3 0.75 . 400 1000 0
i3 0.85 . 800 900 1
i3 10 . 400 800 0 
i3 10.25 . 800 800 0.5
i3 10.50 . 400 700 0
i3 35 .10 800 1000 1
i3 35.25 . 880 3000 0.5
i3 35.50 . 900 3000 1
i3 35.75 . 940 3000 0
i3 35.90 . 1250 3000 0.5
i3 45 1 600 3000 0
i3 46.5 .9 400 3000 0.5
i3 47.5 .7 200 3000 0
i3 48.5 .5 100 3000 1
i3 186 .2 100 1500 0
i3 186.1 .2 200 . .25
i3 186.2 .2 400 . .5
i3 186.3 .2 800 . .75
i3 186.4 .2 1600 . 1

;============================================
; SAMPLE AND HOLD INSTR
;============================================
;p1 p2 p3 p4 p5 p6
;i strt dur iseed amp clk
i4 30 3 .3 2.5 7
i4 65 5 .456 9 8.5
i4 79 6 .334 7 10
i4 175 10 .625 2 7 ;new note

;==============================================
; FM INSTR
;==============================================
;p1 p2 p3 p4 p5 p6 p7 p8 p9 p10
;instr strt dur frq car mod kpan kndx kamp rvbsnd
i5 61 .8 4500 3.25 1.10 0 9.7 4 .09
i5 61.85 . 5040 2.3 2.25 1 8.3 4 .
i5 62.00 1 6340 3.3 1.35 0 8.2 4 .
i5 62.75 . 2600 3.6 1.26 1 3.2 3.5 .
i5 63.25 . 2750 2.74 1.33 0 2.33 3.25 .
i5 76 . 5000 4 2.23 1 7.5 3 .5
i5 77 1.5 6000 5.25 2.76 0 8.9 3 .5

;====================================
; Clicky filter w/pan
;====================================
;p1 p2 p3
;instr strt dur
i6 100 3.5 ;was @70
i6 180 5

;============================================
; CASCADE HARMONICS
;=============================================
;instr start dur freq amp offset
;p1 p2 p3 p4 p5 p6

i8 80 80 93 375 .03 ;.075

;============================================
; S&H WATER INSTR
;============================================
;p1 p2 p3 p4 p5 p6
;i strt dur iseed amp krt
i9 120 40 .3 2.5 60

</CsScore>
</CsoundSynthesizer>
