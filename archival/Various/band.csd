<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo band.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 44100
kr        =    44100
ksmps     =    1
nchnls    =    1

; BAND
          
          instr 1
          bassguitarpastorioso:

kamp      line      8000,p3,5500
a1        oscil     kamp,cpspch(p4),1
a2        buzz      kamp,cpspch(p4),6,1
a3        pluck     kamp,cpspch(p4),440,0,1
          out       a1+a2+a3
          endin

          
          instr 2
flutenpoopensker:

a1        oscil     10000,cpspch(p4),2
          out       a1
          endin


          instr 3
glockenschpeeel1:

kamp      line      3000,p3,500
a1        oscil     kamp,cpspch(p4),1
a2        buzz      kamp*.81,cpspch(p4),8,1
a3        pluck     kamp,cpspch(p4),880,0,3,.5
          out       a1+a2+a3
          endin


          instr 4
glockenklinkinzerklanker2:

kamp      line      4000,p3,500
a1        oscil     kamp,cpspch(p4),3
a2        buzz      kamp,cpspch(p4),6,3
a3        pluck     kamp,cpspch(p4),660,0,1
          out       a1+a2+a3
          endin

          instr 5
snareonabadhairday:
itablesize =        6
kindx     phasor    p5*p6
kpch      table     kindx*itablesize,4
kamp      line      10000,p3,1100
a1        pluck     kamp*1.5,cpspch(kpch),p4,0,1
          out       a1
          endin

</CsInstruments>
<CsScore>
f1 0 8192 10 1
f2 0 512 10 -1
f3 0 256 10  1
f4 0 8192 2 6.00 6.05 7.00 7.05 8.00 8.05
t    0    70
i1 0 .12   6.00
i1 .13 .12 6.03
i1 .26 .15 6.00
i1 .42 .12 6.05
i1 .55 .15 6.00
i1 .71 .12 6.07
i1 .84 .15 6.00
i1 1   .12 6.09
i1 1.13 .15 6.11
i1 1.29 .12 6.00
i1 1.41 .12 5.03
i1 1.54 .12 6.00
i1 1.67 .12 5.05
i1 1.80 .12 6.00 
i1 1.93 .12 5.07
i1 2.05 .12 6.00
i1 2.18 .12 5.09
i1 2.30 .12 6.00
i1 2.42 .12 5.11
i1 2.55 .12 6.00
i1 2.67 .24 6.00
i1 2.92 .24 6.00 
i1 3  0.12   6.00
i1 3.13 .12 6.03
i1 3.26 .15 6.00
i1 3.42 .12 6.05
i1 3.55 .15 6.00
i1 3.71 .12 6.07
i1 3.84 .15 6.00
i1 4   .12 6.09
i1 4.13 .15 6.11
i1 4.29 .12 6.00
i1 4.41 .12 5.03
i1 4.54 .12 6.00
i1 4.67 .12 5.05
i1 4.80 .12 6.00 
i1 4.93 .12 5.07
i1 5.05 .12 6.00
i1 5.18 .12 5.09
i1 5.30 .12 6.00
i1 5.42 .12 5.11
i1 5.55 .12 6.00
i1 5.67 .33 6.00
i2 0    .48 9.00
i2 .49  .96 9.03
i2 1.46 .48 9.00
i2 1.95 .97 9.03
i2 3    .48 9.00
i2 3.49 .96 9.03
i2 4.46 .48 9.00
i2 5    1   9.00
i3 0    .24 10.00
i3 .25  .24 11.03
i3 .50  .24 10.07
i3 .75  .24 10.00
i3 1    .24 10.03
i3 1.25 .24 11.03
i3 1.50 .24 10.07
i3 1.75 .24 10.00
i3 2    .24 10.07
i3 2.25 .24 11.03
i3 2.50 .24 10.07
i3 2.75 .24 10.00
i3 3    .24 10.05
i3 3.25 .24 11.03
i3 3.50 .24 10.07
i3 3.75 .24 10.00
i3 4    .24 10.09
i3 4.25 .24 11.03
i3 4.50 .24 10.07
i3 4.75 .24 10.00
i3 5    .24 10.11
i3 5.25 .24 11.03
i3 5.50 .24 10.07
i3 5.75 .24 10.00
i4 0   .18  11.00
i4 .19 .18  10.09
i4 .38 .18  10.07
i4 .57 .18  10.05
i4 .76 .24  10.03
i4 1   .18  10.00
i4 1.19 .18  10.03
i4 1.38 .18  10.05
i4 1.57 .18  10.07
i4 1.76 .24  10.09
i4 2   .18  11.00
i4 2.19 .18  10.09
i4 2.38 .18  10.07
i4 2.57 .18  10.05
i4 2.76 .24  10.03
i4 3   .18  10.00
i4 3.19 .18  10.07
i4 3.38 .18  10.07
i4 3.57 .18  10.05
i4 3.76 .24  10.05
i4 4   .18  10.00
i4 4.19 .18  10.01
i4 4.38 .18  10.07
i4 4.57 .18  10.05
i4 4.76 .24  10.03
i4 5   .18  11.00
i4 5.19 .18  10.09
i4 5.38 .18  10.07
i4 5.57 .18  10.05
i4 5.76 .24  10.03
i5 0    1.5  6.00   4   1
i5 1.51 1.5  7.00   4  .97
i5 3    1.5  8.00   6  .95
i5 4.51 1.5  7.00   8  .89

</CsScore>
</CsoundSynthesizer>
