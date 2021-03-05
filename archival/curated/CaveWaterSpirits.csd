<CsoundSynthesizer>
<CsOptions>
-RWZdo CaveWaterSpirits.wav
</CsOptions>
<CsInstruments>
;=======================
;Cave, Water and Spirits
;Man Kei Lee
;4/28/03
;=======================
sr = 44100
ksmps = 1
nchnls = 2

garvbsig init 0

 instr 4
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
gkpit rand .005
 endin

 instr 1 ;borrowed from Jean Pich
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
ilast = 2
iseed = p6 ;a pre-generated random number
ivib = .03*iseed
ivoi = p8
krik rand 8,.38413*iseed ;a random number that controls idu; rhythm index
kpik rand 2,.5765*iseed ;pitch index
newvalue:
idu tablei i(krik) ,34,0,0,1 ;random table lookup to control portamento speed
;ipi table i(kpik+ilast),33,0,0,1 ;table lookup for melody pitches
ipi = 6.00
kpi = cpspch(ipi+p11)
;kcp linseg 0, p3, 0.10
ipo = cpspch(ipi+p11)
kvibenv expseg ipo*.001,1.5,ipo*ivib,idu-2,ipo*ivib, .5, ipo*.015 
kbend rand .3,.89*iseed
kford rand 1.5,.0345*iseed
ktemp = kbend + .33
ibend = i(ktemp)*i(ktemp)+.02
igli = (idu/2)+.2 ;portamento speed
ktemp1 = kford+1.5
ishifsp = (i(ktemp1)*i(ktemp1)/idu)+.2
ktemp3 = kpik+ilast
ilast = i(ktemp3)
ioct = p13
 timout 0,idu,go
 reinit newvalue
rireturn
go:
kpi port kpi,ibend,cpspch(ipi+p11) 
kam randh .45, 1,.46543*iseed ;generate random number to control fof's amplitude
kam port kam+.55,.5,p7
kshif randh 5,ishifsp,-.4478*iseed
kshif = int(kshif+5)*9
kind = kshif
kif0 = kpi *(1+i(gkpit)) ;always a little bit off-pitch (fundamental pitch)
iind = (p5*9)-9
;ivoi=p8, voice (male/female/infant)
;iind is a pre-generated random integer from 1 to 10 that's scaled to 0 to 81
; table index, fn, raw/normalized
ifif1 tablei iind,ivoi,0
ifif2 tablei iind+1,ivoi,0
ifif3 tablei iind+2,ivoi,0
iria1 tablei iind+3,ivoi,0
iria2 tablei iind+4,ivoi,0
iria3 tablei iind+5,ivoi,0
kdev1 tablei kind+6,ivoi,0
kdev2 tablei kind+7,ivoi,0
kdev3 tablei kind+8,ivoi,0
kdev1 randh kdev1/2,ishifsp,.0980*iseed
kdev2 randh kdev2/2,ishifsp,.6983*iseed
kdev3 randh kdev3/2,ishifsp,.4*iseed
kfif1 tablei kind,ivoi,0 ;
kfif2 tablei kind+1,ivoi,0
kfif3 tablei kind+2,ivoi,0
kria1 tablei kind+3,ivoi,0
kria2 tablei kind+4,ivoi,0
kria3 tablei kind+5,ivoi,0
kif1 port kfif1+kdev1,igli,ifif1 ;formant frequency with portamento
kif2 port kfif2+kdev2,igli,ifif2
kif3 port kfif3+kdev3,igli,ifif3
;kif1 expseg 440, p3/2, 1300, p3/2, 440
;kif2 = kif1*(1+i(gkpit))
;kif3 = kif1*(1+i(gkpit))
kia1 port kria1-10,igli,iria1 ;control fof's amp
kia2 port kria2,igli,iria2
kia3 port kria3,igli,iria3
;-----------------------
;FM on fundamental pitch
;-----------------------
krandvib randi .2,3.5,iseed*.123
; kvibenv expseg p4*.001,1.5,p4*ivib,p3-.35,p4*ivib,1,p4*.015
kvib oscil kvibenv,5.5*(1+krandvib),4
;---------------------
;envelop for amplitude
;---------------------
kenv linseg 0.001,.1+p3*.1,1,p3-(.2+p3*.25),1,.1+p3*.15,0.001 
;---------------------------------
;control fundamental pitch
;---------------------------------
kdev randi .009,12,iseed*.765
kdev = 1+kdev ;unsteady sustain voice
kpit linseg .95,.1,1,p3-.2,1,.1,0.92 ;human intonation
kpitch = kdev*kif0*kpit+kvib 
;k1 expseg 220, p3, 500
;kpitch = k1*kpit*kdev+kvib
koct linseg 0, p3*p14, ioct, p3*p15, 0, p3*(1-p14-p15), 0
;ioutch = p12
;koct = 0
;------------
;core of fof
;------------
; overall amplitude xfnd xform koct kband kris kdur kdec iolaps ifna ifnb idur
ar fof ampdb(kia1)*kenv*kam, kpitch, kif1, koct, 50, .0025, .025, .007, 50, 1, 2, p3
ar1 fof ampdb(kia2)*kenv*kam*kam, kpitch, kif2, koct, 100, .0025, .025, .007, 50, 1, 2, p3
ar2 fof ampdb(kia3)*kenv*kam*kam*kam, kpitch, kif3, koct, 150, .0025, .025, .007, 50, 1, 2, p3
ar3 fof ampdb(kia3)*kenv*kam*kam*kam*.7, kpitch, kif3+1000, koct, 150, .0025, .025, .007, 50, 1, 2, p3
ipan = (p12+1)/2
 outs (ar+ar1+ar2+ar3)*ipan, (ar+ar1+ar2+ar3)*(1-ipan)
garvbsig = garvbsig+((ar+ar1+ar2+ar3)*.14)
 endin
;=================================================
; INSTRUMENT 2 --- a noise band glissando
;=================================================
 instr 2
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
kfreq = p5
kramp linseg 0,p3*.8,p4,p3*.2,0 ; THIS CONTROLS THE AMP OF RANDI
kenv1 linen p4,0, p3,10 ; THIS CONTROLS THE FRQ OF RANDI
anoise randi kramp,kenv1
aosc oscili anoise,kfreq,11 ; ANOISE IS FED TO THE A INPUT OF AOSC
kpan oscili 1,.07,1
aosc2 reson aosc,kpan+100,100,2 ; KPAN+100 IS OFFSET FOR FILTER SWEEP INPUT
 outs aosc2*kpan,aosc2*(1-kpan)
garvbsig = garvbsig+(aosc2*.2)
 endin
;===================
; GLOBAL REVERB
;===================
 instr 99
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)
a1 reverb2 garvbsig, p4, p5
 outs a1,a1
garvbsig = 0
 endin
; instr 15
;kmod expseg p5,.0151,p5*.1,p3*0.9,.005
;asid foscil ampdb(p5),cpspch(p4),2.380,3.967,kmod,1 
;agon expseg 0.001,.0151,1,.1,.7,p3*0.9,.005 
; out (asid)*agon
; endin
</CsInstruments>
<CsScore>
f1 0 65536 9 1 1 0 ;sine lo-res
;f1 0 65536 10 1
f2 0 65536 19 .25 1 0 0
f3 0 65536 10 2 0 0 0 0 0 0 0 0 .1 .1 0 0 .1 
f4 0 65536 7 0 2048 1 4096 -1 2048 0
f11 0 65536 10 1 ;SINE WAVE hi-res
;man's formant
f99 0 128 -2 738 1115 2450 80 70 60 73 110 266 677 1717 2404 80 70 55 80 162 183 634 1217 2388 80 70 50 58 144 230 543 789 2384 80 70 30 73 146 323 535 1868 2498 80 70 60 65 150 168 489 1358 1706 80 65 40 80 146 233 386 1977 2564 80 70 50 94 196 155 267 2290 2933 80 65 60 53 233 266 440 1032 2241 80 60 40 76 185 246 304 870 2239 80 65 40 63 250 483 
;woman's formant
f89 0 128 -2 877.324 1235.11 2749.51 80 70 60 103.0 118.333 296.667 901.136 2024.02 2832.39 80 70 65 123.333 175.333 243.333 756.886 1418.48 2768.64 80 70 50 100.667 176.0 290.0 583.646 906.042 2735.29 80 50 40 113.333 173.333 350.0 607.167 2367.79 3016.24 70 60 60 100.0 156.667 200.0 503.704 1632.04 1969.39 80 60 50 97.3333 266.667 333.333 437.378 2498.78 3082.44 80 60 50 71.6667 160.0 200.0 307.792 2782.17 3316.23 80 55 60 62.0 246.667 318.333 459.023 1141.84 2673.75 80 60 50 78.3333 215.333 296.667 378.113 962.245 2659.72 80 65 40 66.6667 266.667 280.0 
;child's formant
f79 0 128 -2 1089.17 1402.5 3175.0 80 70 60 96.6667 133.333 616.667 1047.89 2288.15 3342.96 80 70 55 164.0 250.0 473.333 858.304 1589.13 3302.61 80 70 50 146.667 130.0 386.667 702.187 1074.37 3230.62 80 70 30 130.0 136.667 450.0 684.312 2613.44 3448.75 80 70 60 95.0 208.333 186.667 569.276 1808.1 2184.83 80 65 40 125.0 266.667 400.0 534.412 2795.88 3528.24 80 64 40 100.0 256.667 413.333 360.2 3177.83 3763.0 80 65 50 105.0 293.333 306.667 553.889 1400.19 3312.22 80 55 40 93.3333 166.667 400.0 423.964 1177.14 3245.0 80 65 40 106.667 350.0 366.667 
;melody table
f33 0 32 -2 6.0 6.02 6.03 6.05 6.07 6.09 6.10 7.0 6.10 6.07 7.0 7.02 7.03 7.05 7.07 7.03 7.0 6.10 6.09 6.07 6.05 6.04 6.0 6.03 6.05 6.10 6.05 6.07 6.03 6.02 6.0 5.10 
;rhythm table
f34 0 16 -2 .50 .0375 .0375 .0625 8 .0375 3 .125 .125 4 2 .0625 .25 1 .125 
t 0 60
;instr strt dur rvbtime hfdif
i99 0 120 6 .2
i4 0.0 10
i1 0.0 .50 100 3 .17 .260 89 2 3 2.07
i1 0.5 .48 100 3 .25 .260 89 2 3 2.10
i1 3.5 .6 100 3 .21 .260 99 2 3 1.04 -.3
i1 5.0 .7 100 3 .33 .260 79 2 3 2.08 .2
i1 8.0 20 100 3 .15 .260 79 2 3 2.03 1
i1 8.0 20 100 3 .29 .260 89 2 3 2.07 0
i1 8.0 20 100 3 .31 .260 99 2 3 2.02 -1
i1 30.0 .50 100 3 .17 .260 89 2 3 2.08 0 2 1
i1 30.5 .48 100 3 .25 .260 89 2 3 2.11 0 2 1
i1 33.5 .6 100 3 .21 .260 99 2 3 1.05 -.3 2 1
i1 35.0 .7 100 3 .33 .260 79 2 3 2.09 .2 2 1
i1 38.0 40 100 3 .15 .260 79 2 3 2.07 1 8 .4 .3
i1 38.0 40 100 3 .29 .260 89 2 3 2.10 0 8 .4 .3
i1 38.0 40 100 3 .31 .260 99 2 3 2.02 -1 8 .4 .3
i1 82.47 .17 100 3 .17 .260 89 2 3 3.01 -.2 0
i1 + . 100 3 .17 .260 89 2 3 2.07 .
i1 + . 100 3 .17 .260 89 2 3 2.06 .
i1 + . 100 3 .17 .260 89 2 3 2.11 .
i1 + . 100 3 .17 .260 89 2 3 2.00 .
i1 . . 100 3 .17 .260 89 2 3 1.09 .6
i1 . . 100 3 .17 .260 89 2 3 1.04 .
i1 . . 100 3 .17 .260 89 2 3 2.02 .
i1 . . 100 3 .17 .260 89 2 3 2.03 .
i1 . . 100 3 .17 .260 89 2 3 2.08 -.6
i1 . . 100 3 .17 .260 89 2 3 3.01 -.2
i1 + . 100 3 .17 .260 89 2 3 2.07 .
i1 + . 100 3 .17 .260 89 2 3 2.06 .
i1 + . 100 3 .17 .260 89 2 3 2.11 .
i1 + . 100 3 .17 .260 89 2 3 2.00 .
i1 . . 100 3 .17 .260 89 2 3 1.09 .6
i1 . . 100 3 .17 .260 89 2 3 1.04 .
i1 . . 100 3 .17 .260 89 2 3 2.02 .
i1 . . 100 3 .17 .260 89 2 3 2.03 .
i1 . 5 100 3 .17 .260 89 2 3 2.05 -.6
i1 82.33 .2 100 3 .17 .260 79 2 3 2.00 -.9 0
i1 + . 100 3 . .260 . 2 3 2.02 .
i1 + . 100 3 . .260 . 2 3 2.03 .
i1 + . 100 3 . .260 . 2 3 2.05 .
i1 + . 100 3 . .260 . 2 3 2.07 .
i1 . . 100 3 . .260 . 2 3 2.08 .8
i1 . . 100 3 . .260 . 2 3 2.09 .
i1 . . 100 3 . .260 . 2 3 2.11 .
i1 . . 100 3 . .260 . 2 3 3.01 .
i1 . . 100 3 . .260 . 2 3 2.09 -.7
i1 . . 100 3 . .260 79 2 3 2.00 -.9
i1 + . 100 3 . .260 . 2 3 2.02 .
i1 + . 100 3 . .260 . 2 3 2.03 .
i1 + . 100 3 . .260 . 2 3 2.05 .
i1 + . 100 3 . .260 . 2 3 2.07 .
i1 . . 100 3 . .260 . 2 3 2.08 .8
i1 . . 100 3 . .260 . 2 3 2.09 .
i1 . . 100 3 . .260 . 2 3 2.10 .
i1 . . 100 3 . .260 . 2 3 3.01 .
i1 . 5 100 3 .61 .260 . 2 3 2.09 -.7
i1 82.0 .23 100 3 .19 .260 99 2 3 2.00 .9 0
i1 + . 100 3 . .260 . 2 3 1.07 .
i1 + . 100 3 . .260 . 2 3 1.10 .
i1 + . 100 3 . .260 . 2 3 1.09 .
i1 + . 100 3 . .260 . 2 3 1.08 .
i1 . . 100 3 . .260 . 2 3 1.07 -.8
i1 . . 100 3 . .260 . 2 3 1.05 .
i1 . . 100 3 . .260 . 2 3 1.04 .
i1 . . 100 3 . .260 . 2 3 1.02 .
i1 . . 100 3 . .260 . 2 3 1.00 .7 
i1 . . 100 3 . .260 79 2 3 2.01 .
i1 + . 100 3 . .260 . 2 3 1.11 .
i1 + . 100 3 . .260 . 2 3 1.10 .
i1 + . 100 3 . .260 . 2 3 1.09 .
i1 + . 100 3 . .260 . 2 3 1.08 .
i1 . . 100 3 . .260 . 2 3 1.07 -.8
i1 . . 100 3 . .260 . 2 3 1.05 .
i1 . . 100 3 . .260 . 2 3 1.04 .
i1 . . 100 3 . .260 . 2 3 1.01 .
i1 . 5 100 3 .41 .260 . 2 3 1.03 .7
i1 90.0 20 100 3 .15 .260 79 2 3 2.03 1 10 1
i1 90.0 20 100 3 .29 .260 89 2 3 2.07 0 10 1
i1 90.0 20 100 3 .31 .260 99 2 3 2.02 -1 10 1
i2 4.200 110 2000 1000
e
</CsScore>
</CsoundSynthesizer>