<CsoundSynthesizer>
<CsOptions>
-RWZdo VestigeOfTime.wav
</CsOptions>
<CsInstruments>
sr=44100
ksmps=1
nchnls=2

garvbsig init 0
gasig init 0

instr 1			;filtered saw
irvbgain=p11
iamp=ampdb(p5)
inote=cpspch(p4)
k1 linen iamp,p6,p3,p7
kpan oscili 1,1/p3,p12
a1 oscili k1,inote,p8
a2 oscili k1,inote+.998,p8
a3 oscili k1,inote+1.003,p8
k2 line p9,p3,p10
a4=(a1+a2+a3)/3
aout reson a4,k2,100, 2
outs aout*kpan,aout*(1-kpan)
garvbsig=garvbsig+(aout*irvbgain)
endin
 
instr 2        ;fm bouncing
ifrqrat=p8*p5
iamprat=p4*p9
ibalance=p14
intoe=cpspch(ifrqrat)
iamp2=ampdb(iamprat)
iamp=ampdb(p4*.8)
inote=cpspch(p5)
iamp3=ampdb(75)
irvgain=p15
k3 oscili iamp3,1/p3,p7
krepeat=k3*p16
k1 oscili iamp,(1/p3)*krepeat,p6

k2 linen iamp2,p10,p3,p11

a2 oscili k2,intoe,p13

a1 oscili k1,inote+a2,p12

outs a1*ibalance,a1*(1-ibalance)

garvbsig=garvbsig+(a1*irvgain)

endin
 

instr 3			;filtered noise

iamp=p12

ksweep line p5,p3,p6

kenv oscili iamp,(1/p3)*p7,p8		

kpan oscili 1,(1/p3)*p9,p10

anoise rand 16000

afilt reson anoise,ksweep,p4,2

asig=afilt*kenv 

outs asig*kpan,asig*(1-kpan)

garvbsig=garvbsig+(asig*p11)

endin
 

instr 4			;random pitch 

iamp=ampdb(p5 * .9)

inote=cpspch(p6)

kenv oscili 1,1/p3,p11

krand randh p7,p8

kpan oscili 1,1/p3,p9

asig oscili iamp*kenv,inote+krand,p4

outs asig*kpan,asig*(1-kpan)

garvbsig=garvbsig+(asig*p10)

endin
 

instr 99

asig reverb2 garvbsig,p4,p5

outs asig,asig

garvbsig=0

endin
 

instr 98		;DELAY LINE
 

a1 delay gasig,p4

a2 delay a1*p5,p4

a3 delay a2*p5,p4

a4 delay a3*p5,p4

a5 delay a4*p5,p4

a6 delay a5*p5,p4

outs (a1+a3+a5)/3,(a2+a4+a6)/3

gasig=0

endin
 

instr 5    		;DUAL FOSCIL     

index=p11

iamp=ampdb(p4)

inote=cpspch(p5)

ifmrise=p9*p3

ifmamp=p8

ifmdec=p10*p3

ifmoff=p3-(ifmrise+ifmdec)

kfm linseg 0,ifmrise,ifmamp,ifmdec,0,ifmoff,0

kndx=kfm*index

kpan oscili 1,1/p3,p14

kenv oscili 1,1/p3,p15

a1 foscili iamp,inote,p6,p7,kndx,p12

a2 foscili iamp,inote+1.003,p6,p7,kndx,p12

a3=(a1+a2)/2

a4=a3*kenv

outs a4*kpan,a4*(1-kpan)

garvbsig=garvbsig+(a4*p13)

endin
 
 

instr 6			;RAND PTCH W/ SEND TO DELAY 

iamp=ampdb(p5)

inote=cpspch(p6)

kenv oscil 1,1/p3,p11

krand randh p7,p8

kpan oscili 1,1/p3,p9

asig oscili iamp*kenv,inote+krand,p4

outs asig*kpan,asig*(1-kpan)

gasig=gasig+(asig*p10)

endin
 

instr 7			;PITCH TABLE W/ LFO

ilfort=p5

itablesize=p6

itable=p7

iamp=ampdb(p4)

kindex phasor ilfort 

kpitch tablei kindex*itablesize,itable

knote=cpspch(kpitch)

kenv oscili iamp,1/p3,p8

kpan oscili 1,1/p3,p10

a1 oscili kenv,knote,p9

krtl=sqrt(kpan)

krtr=sqrt(1-kpan)

al=a1*krtl

ar=a1*krtr

outs al,ar 

garvbsig=garvbsig+(a1*p11)

endin
 

instr 8    		;DUAL FOSCIL W/ MODULATING ENV     

index=p11

iamp=ampdb(p4)

inote=cpspch(p5)

ifmrise=p9*p3

ifmamp=p8

ifmdec=p10*p3

ifmoff=p3-(ifmrise+ifmdec)

kfm linseg 0,ifmrise,ifmamp,ifmdec,0,ifmoff,0

kndx=kfm*index

kpan oscili 1,1/p3,p14

krpt oscili 1,1/p3,p16

krepeat=krpt*p17

kenv oscili iamp,(1/p3)*krepeat,p15

a1 foscili kenv,inote,p6,p7,kndx,p12

a2 foscili kenv,inote+1.003,p6,p7,kndx,p12

a3=(a1+a2)/2

outs a3*kpan,a3*(1-kpan)

garvbsig=garvbsig+(a3*p13)

endin
 

instr 9

inote=cpspch(p8)

iamp=ampdb(p9)

kenv oscili 1,1/p3,p4

asig oscili iamp*kenv,inote,19

asig2 oscili (iamp*kenv)*.7,inote,26

kfilt1 oscili 1,1/p3,p5

kfilt2 oscili 1,1/p3,p6

kfilt3 oscili 1,1/p3,p7

 af1   reson   asig, 110*kfilt1, 20, 2

  af2   reson   asig, 220*kfilt2, 30, 2

  af3   reson   asig, 440*kfilt3, 40, 2

aout  balance 0.6*af1+af2+0.6*af3+0.4*asig+2*asig2, asig

        outs     aout,aout

endin
 

instr 10

inote=cpspch(p4)

iamp=ampdb(p5)

kenv oscili 1,1/p3,p7

kvib oscili 1,p9,26

asig oscili iamp*kenv,inote+(kvib*(p10*2)),p11

kfilt oscili 1,1/p3,p6

af1 reson asig,5000*kfilt,50, 2

a2=af1*kenv

outs asig,asig

gasig=gasig+(a2*p8)

endin
 

instr 11				;female OO

iamp=ampdb(p4)

inote=cpspch(p5)

a1 buzz iamp,inote,15,31

a2 buzz iamp,inote+1.003,15,31

afilt1=(a1+a2)/2

afilt2 reson afilt1,280,20, 2

afilt3 reson afilt1,650,25, 2

afilt4 reson afilt1,2200,30, 2

afilt5 reson afilt1,3450,40, 2

afilt6 reson afilt1,4500,50, 2

kenv oscili 1,1/p3,30

aout=(afilt2+afilt3+afilt4+afilt5+afilt6)/5

alp butterlp aout,2000

outs alp*kenv,alp*kenv

gasig=gasig+((alp*kenv)*p6)

endin
 

instr 12			;female AA

iamp=ampdb(p4)

inote=cpspch(p5)

a1 buzz iamp,inote,15,31

a2 buzz iamp,inote+1.003,15,31

afilt1=(a1+a2)/2

afilt2 reson afilt1,650,50, 2

afilt3 reson afilt1,1100,50, 2

afilt4 reson afilt1,2860,50, 2

afilt5 reson afilt1,3300,50, 2

afilt6 reson afilt1,4500,50, 2

kenv oscili 1,1/p3,30

aout=(afilt2+afilt3+afilt4+afilt5+afilt6)/5

alp butterlp aout,2000

outs alp*kenv,alp*kenv

gasig=gasig+((alp*kenv)*p6)

endin
 

instr 13			;female E

iamp=ampdb(p4)

inote=cpspch(p5)

a1 buzz iamp,inote,15,31

a2 buzz iamp,inote+1.003,15,31

afilt1=(a1+a2)/2

afilt2 reson afilt1,500,50, 2

afilt3 reson afilt1,1750,50, 2

afilt4 reson afilt1,2450,50, 2

afilt5 reson afilt1,3350,50, 2

afilt6 reson afilt1,5000,50, 2

kenv oscili 1,1/p3,30

aout=(afilt2+afilt3+afilt4+afilt5+afilt6)/5

alp butterlp aout,2000

outs alp*kenv,alp*kenv

gasig=gasig+((alp*kenv)*p6)

endin
 

instr 14			;female IY

iamp=ampdb(p4)

inote=cpspch(p5)

a1 buzz iamp,inote,15,31

a2 buzz iamp,inote+1.003,15,31

afilt1=(a1+a2)/2

afilt2 reson afilt1,330,50, 2

afilt3 reson afilt1,2000,50, 2

afilt4 reson afilt1,2800,50, 2

afilt5 reson afilt1,3650,50, 2

afilt6 reson afilt1,5000,50, 2

kenv oscili 1,1/p3,30

aout=(afilt2+afilt3+afilt4+afilt5+afilt6)/5

alp butterlp aout,2000

outs alp*kenv,alp*kenv

gasig=gasig+((alp*kenv)*p6)

endin
 

instr 15			;female O

iamp=ampdb(p4)

inote=cpspch(p5)

a1 buzz iamp,inote,15,31

a2 buzz iamp,inote+1.003,15,31

afilt1=(a1+a2)/2

afilt2 reson afilt1,400,50, 2

afilt3 reson afilt1,840,50, 2

afilt4 reson afilt1,2800,50, 2

afilt5 reson afilt1,3250,50, 2

afilt6 reson afilt1,4500,50, 2

kenv oscili 1,1/p3,30

aout=(afilt2+afilt3+afilt4+afilt5+afilt6)/5

alp butterlp aout,2000

outs alp*kenv,alp*kenv

gasig=gasig+((alp*kenv)*p6)

endin
 

instr 16			;female OO w/ vib formerly i8

iamp=ampdb(p4)

inote=cpspch(p5)

kvib oscili 1,p7,29

a1 buzz iamp,inote+(kvib*(p8*2)),15,31

a2 buzz iamp,(inote+1.003)+(kvib*(p8*2)),15,31

afilt1=(a1+a2)/2 

afilt2 reson afilt1,280,50, 2

afilt3 reson afilt1,650,40, 2

afilt4 reson afilt1,2200,40, 2

afilt5 reson afilt1,3450,40, 2

afilt6 reson afilt1,4500,50, 2

kenv oscili 1,1/p3,30

aout=(afilt2+afilt3+afilt4+afilt5+afilt6)/5

alp1 butterlp aout,1800

alp butterlp alp1,3500

outs alp*kenv,alp*kenv

gasig=gasig+((alp*kenv)*p6)

endin
 

instr 17		;DEEP FM 

ibalance=p6

iamp=ampdb(p4)

inote=cpspch(p5)

kmodenv oscili 1,1/p3,32

a3 oscili kmodenv*(iamp*.05),inote,29

a2 oscili iamp*.07,inote,29

a1 oscili iamp,inote+a2+a3,29

kenv oscili 1,1/p3,33

aout=a1*kenv

outs aout*ibalance,aout*(1-ibalance)

gasig=gasig+((aout*kenv)*p7)

endin
 

instr 18		;delay chorus saw

irvbgain=p6

iamp=ampdb(p4 * .9)

inote=cpspch(p5)

kenv oscili 1,1/p3,37

a1 oscili iamp*kenv,inote,36

amod oscili 2,.25,29

adel vdelay a1,amod,20

adel2 vdelay adel,amod,20

adel3 vdelay adel2,amod,20

adel4 vdelay adel3,amod,20

adel5 vdelay adel4,amod,20

aout=(adel3+adel2+adel+adel4+adel5+a1)/6

abal balance aout,a1

outs abal,abal

garvbsig=garvbsig+(abal*irvbgain)

endin
 

instr 19			;AM BELL

iamp=ampdb(p4)

inote=cpspch(p5)

irvbgain=p6

a5 oscili iamp*.25,1729+inote,10

a4 oscili (iamp*.3)+a5,973+inote,10

a1 oscili (iamp*.5)+a4,513+inote,10

a2 oscili a1+iamp,inote,10

a3 oscili iamp,440,10

kenv oscili 1,1/p3,40

am balance a2,a3 

aout=am*kenv

outs aout,aout

garvbsig=garvbsig+(aout*irvbgain)

endin
 

instr 20			;WOW

iamp=ampdb(p4)

inote=cpspch(p5)

a1 buzz iamp,inote,15,31

a2 buzz iamp,inote+1.003,15,31

kmod oscili iamp,1/p3,41

afilt1=(a1+a2)/2

afilt2 reson afilt1,650+kmod,50, 2

afilt3 reson afilt1,1100+kmod,50, 2

afilt4 reson afilt1,2860+kmod,50, 2

afilt5 reson afilt1,3300+kmod,50, 2

afilt6 reson afilt1,4500+kmod,50, 2

kenv oscili 1,1/p3,30

aout=(afilt2+afilt3+afilt4+afilt5+afilt6)/5

alp butterlp aout,2000

outs alp*kenv,alp*kenv

gasig=gasig+((alp*kenv)*p6)

endin
 

instr 21			;random pitch w/ pitch eg and envelope repeat 

iamp=ampdb(p5)

inote=cpspch(p6)

kpitch oscili iamp/2,1/p3,p12

krptfun oscili 100,1/p3,49

kenv oscili iamp,1/p3*krptfun,p11

krand randh p7,p8

kpan oscili 1,1/p3,p9

asig oscili kenv,inote+kpitch,p4

outs asig*kpan,asig*(1-kpan)

garvbsig=garvbsig+(asig*p10)

endin

</CsInstruments>
<CsScore>
f1 0 65536 10 1 .5 .25 .125 .0625 .125 .25 .5 1 1        ;HF WAVE

f2 0 512 -7 .5 512 .5                                   ;CENTER

f3 0 512 7 0 512 1                                      ;L to R

f4 0 512 7 1 512 0                                      ;R to L

f5 0 512 7 0 50 1 50 .5 300 .5 112 0                    ;ADSR

f6 0 512 7 0 16 1 96 0 400 0                            ;PRECUSSIVE ENV 

f7 0 65536 10 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1  ;WAVE

f8 0 65536 10 1 1 1 1                                    ;WAVE

f9 0 65536 10 1 .5 .333 .25 .2 .167 .1428 .125 .111 .1 .0909 .0833 .0769 .0714 .0667 .0625

                                                        ;SAW WAVE

f10 0 65536 10 1                                         ;SINE WAVE

f11 0 512 -5 .001 512 .02                               ;BOUNCE FUNCTION

f12 0 512 7 0 12 1 50 .5 450 0                          ;BOUNCE ENV

f13 0 512 7 0 256 1 256 0                               ;L R L

f14 0 512 -7 0 512 0

f15 0 512 -7 1 512 1

f16 0 65536 10 1 0 .33333 0 .2 0 .142857 0 .11111 0 .090909 0 .076923 0 .066667 0 .058824 0 .526315 0 .047619 0 .04347826 0 .04 0 .037037 0 .034482 0 .032258

                                                        ;SQUARE WAVE

f17 0 512 -7 0 512 2

f18 0 512 -7 0 3 1 250 1 6 0 253 0
 

f19 0 65536 10 1 .1 .1 .278 .245 .3 .352 .846 .669 0 0 0 .1 .1 .1

f20 0 256 7 0.000 11 0.290 15 0.590 21 0.840 34 0.970 32 0.850 36 0.730 39 0.480 31 0.220 37 0.000 

f21 0 256 7 1.000 16 0.950 17 0.830 18 0.680 7 0.530 11 0.390 24 0.200 25 0.120 28 0.050 110 0.000 

f22 0 256 7 0.000 20 0.790 8 0.920 14 0.980 14 0.880 11 0.730 17 0.580 17 0.420 16 0.280 21 0.210 19 0.140 99 0.000 

f23 0 256 7 0.000 46 0.690 14 0.880 22 0.980 17 0.880 17 0.700 14 0.570 19 0.400 16 0.310 25 0.220 30 0.090 36 0.000

f24 0 256 7 0.000 10 1.000 40 0.500 122 0.670 24 0.610 21 0.470 39 0.000

f25 0 65536 10 1 .832 .5 .215 .6 .133 .785 .326 .018 .028 .0647 .0143 .0213 

f26 0 65536 10 1

f27 0 65536 10 .86 .9 .32 .2 0 0 0 0 0 0 0 0 0 .3 .5

f28 0 65536 10 1 0 .33333 0 .2 0 .142857 0 .11111 0 .0909 0 .076923 0 .066667 0 .0588235 0 .05263157 0 .047619 0 .0434782 0 .04 0 .037037 0 .034482
 

;=================MELLOW SECTION FUNCTIONS===================================
 

f29 0 65536 10 1

f30 0 512 7 0 256 1 256 0

f31 0 8192 10 1

f32 0 512 7 0 512 1 

f33 0 512 7 0 12 1 490 1 10 0

f34 0 65536 10 1 1 .1 .2 .156 .02 .02 .02

f35 0 256 7 0.160 39 0.530 26 0.970 125 0.830 66 0.000 

f36 0 65536 10 1 .5 .333 .25 .2 .167 .1428 .125 .111 .1 .0909 .0833 .0769 .0714 .0667 .0625

f37 0 4096 8  0.020000 208 0.780000 3302 0.660000 481 0.220000 105 0.01

f38 0 512 7 0 12 1 100 .5 400 0

f39 0 512 7 1 512 1

f40 0 512 7 0 1 1 50 .6 411 0

f41 0 4096 -8  -0.320000 1261 0.140000 2835 -0.320000   ;WOW

f42 0 512 -7 .3 512 .3

f43 0 512 7 0 156 1 356 0

f44 0 512 -7 .5 350 0 162 0

f45 0 512 -7 .4 350 0 162 0

f46 0 512 -7 .6 350 0 162 0

f47 0 512 -7 .8 350 0 162 0

f48 0 512 -7 -2.5 350 0 162 0

f49 0 4096 8  0.960000 2275 0.100000 1821 0.000001

                                

;------------------------------------------------------------------------------------------
 

t 0 60 45 60 46 30 65 30 66 45 116 50 154 70 167 70 168 60 171 70 171.2 40 175 60 176 65 177 70 178 40 180 60 183.2 48 191 48 192 60

 
 

i99 0 33 2 .2
 

;ins(4) st dur wv amp frq randev randspd panfun rvbsnd envfun
 

i4      0  8   1  70  7.07 20    20       12    0.3      13

i4      4 16   1  70  5.05  0     2       2     0.05      5

i4      4 16   7  70  5.05  0     2       2     0.05      5

i4      4 16   8  80  5.05  0     2       2     0.05      5
 

;ins(2) st dur amp carfrq envfun repfun fmfrq fmamp fmatk fmrel carwv fmwv pan rvsnd rpt#

i2      5   6  68  9.002  4      11     2.01  0.86  0.003  0.99 10    10   0.8  0.15   1
 

;ins(1) st dur frq amp atk rel wv swpst swpend rvbsnd panfun
 

i1      6  10 7.09 55  .9  .9  9  5000    500     .2     4

i1      6  10 8.02 55  .9  .9  9  5000    500     .2     4

i1      6  10 8.07 55  .9  .9  9  5000    500     .2     4

i1      6  10 9.00 55  .9  .9  9  5000    500     .2     4

i1      6  10 9.04 55  .9  .9  9  5000    500     .2     4
 

;ins(3) st dur bndwth swpst swpend envrpt envfun panrpt panfun rvgn amp
 

i3      6  10   100   6000   700    40      6     1       13    .1   .08

i3      16 10   100   5000   600    50      6     1       3     .1   .05

i3      16 10   100   600   5000    40      6     1       4     .1   .05
 

;ins(4) st dur wv amp frq randev randspd panfun rvbsnd envfun

i4     16  10  1  70 5.05    0     2      2     0.05     5

i4     16  10  7  70 5.05    0     2      2     0.05     5

i4     16  10  8  80 5.05    0     2      2     0.05     5

i4     26   6  1  70 5.03    0     2      2     0.05     5

i4     26   6  7  70 5.03    0     2      2     0.05     5

i4     26   6  8  80 5.03    0     2      2     0.05     5
 

;ins(1) st dur frq amp atk rel wv swpst swpend rvbsnd panfun

i1      16  10 7.09 55  .9  .9  9  5000    500     .2     4

i1      16  10 8.02 55  .9  .9  9  5000    500     .2     4

i1      16  10 8.07 55  .9  .9  9  5000    500     .2     4

i1      16  10 9.00 55  .9  .9  9  5000    500     .2     4

i1      16  10 9.04 55  .9  .9  9  5000    500     .2     4

i1      26  6  7.09 55  .5  .9  9  500    5000     .2     4

i1      26  6  8.02 55  .5  .9  9  500    5000     .2     4

i1      26  6  8.07 55  .5  .9  9  500    5000     .2     4

i1      26  6  9.00 55  .5  .9  9  500    5000     .2     4

i1      26  6  9.02 55  .5  .9  9  500    5000     .2     4
 

;ins(2) st dur amp carfrq envfun repfun fmfrq fmamp fmatk fmrel carwv fmwv pan rvsnd rpt#

i2      17   6   58  9.002    4      11   2.01  .86   .003  .99   10    10  .8  .15 1   

i2      18   6   55  8.114    4      11   2.01  .86   .003  .99   10    10  .2  .15 1   

i2      19   6   51  8.108    4      11   2.01  .86   .003  .99   10    10  .2  .15 1 

  

;ins(4) st dur wv amp frq randev randspd panfun rvbsnd envfun
 

i4      17  1   10 85  9.09     0      2      2      0.3    13

i4      18  1   10 85  10.04    0      2      2      0.3    13

i4      19  1   10 85  10.02    0      2      2      0.3    13

i4      20  2   10 85  9.07     0      2      2      0.3    13

i4      22  1   10 85  9.09     0      2      2      0.3    13

i4      23  1   10 80  10.04    0      2      2      0.3    13

i4      24  1   10 80  10.02    2      50     2      0.3    13

i4      25  1   10 80  9.07     0      2      2      0.3    13

i4      25  1   10 80  9.09     0      2      2      0.3    13

i4      26  4   10 80  9.09     4      50     2      0.5    13
 

;ins(2) st dur amp carfrq envfun repfun fmfrq fmamp fmatk fmrel carwv fmwv pan rvsnd rpt#

i2      26 4   67     8.09  4      11   2.01 .86   .003  .99   10    10   .1   .15  1
 

;pseudo section
 

i4      31  2   10  83     9.10    1   2   2    0.3     13

i4      33  4   10  83     9.08    2   50  2    0.3     13

i4      37  8   10  83     9.10    2   50  2    0.3     13
 

i99 30 16 2 .2
 

;ins(1) st dur frq amp atk rel wv swpst swpend rvbsnd panfun
 

i1      31  2   7.10 53 .5  .5  9  500    4000   .1     4

i1      31  2   8.00 53 .5  .5  9  500    4000   .1     4

i1      31  2   8.05 53 .5  .5  9  500    4000   .1     4

i1      33  4   7.10 53 .5  .9  9  4000   500    .1     3

i1      33  4   8.00 53 .5  .9  9  4000   500    .1     3

i1      33  4   8.05 53 .5  .9  9  4000   500    .1     3

i1      37  8   7.05 58 .9  .9  9  1000  3000    .1     4

i1      37  8   7.07 58 .9  .9  9  3000  1000    .1     3

i1      37  8   8.02 58 .9  .9  9  1000  3000    .1     3

i1      37  8   8.03 58 .9  .9  9  3000  1000    .1     4
 

i4  31  2  1    70 6.01 0 2 2 0.05 5

i4  31  2  1    70 6.01 0 2 2 0.05 5

i4  31  2  1    80 6.01 0 2 2 0.05 5

i4  33  4  1    70 6.01 0 2 2 0.05 5

i4  33  4  1    70 6.01 0 2 2 0.05 5

i4  33  4  1    80 6.01 0 2 2 0.05 5

i4  37  8  1    70 6.00 0 2 2 0.05 5

i4  37  8  1    70 6.00 0 2 2 0.05 5

i4  37  8  1    80 6.00 0 2 2 0.05 5
 

;ins(3) st dur bndwth swpst swpend envrpt envfun panrpt panfun rvgn amp

i3      31  2    50     50    3000   1      13     5      13     .01  .05

i3      33  4    50     300   6000   1      13     5      13     .01  .05

i3      37  8   100    6000   7000   1       5     1       2     .5   .02

;ins(2) st dur amp carfrq envfun repfun fmfrq fmamp fmatk fmrel carwv fmwv pan rvsnd rpt#

i2      37   8   68  9.102    4      11   2.01  .86   .003  .99   10    10  .05  .15    1

;pseudo section
 

i99 46 22 2 .2

;ins(1) st dur frq amp atk rel wv swpst swpend rvbsnd panfun

i1      46  5   7.04 55 .9  .9  9   6000  500    .15    4

i1      46  5   7.07 55 .9  .9  9   6000  500    .15    4

i1      46  5   7.11 55 .9  .9  9   6000  500    .15    4

i1      46  5   8.00 55 .9  .9  9   6000  500    .15    4

i1      46  5   8.02 55 .9  .9  9   6000  500    .15    4

i1      46  5   8.06 55 .9  .9  9   6000  500    .15    4

i1      51  5   7.02 55 .9  .9  9   6000  500    .15    4

i1      51  5   7.05 55 .9  .9  9   6000  500    .15    4

i1      51  5   7.09 55 .9  .9  9   6000  500    .15    4

i1      51  5   8.00 55  .9 .9  9   6000  500    .15    4

i1      51  5   8.04 55  .9 .9  9   6000  500    .15    4

i1      51  5   8.07 55  .9 .9  9   6000  500    .15    4

i1     56  6   7.03 55  .9 .9  9   400  6000    .2     3

i1     56  6   7.05 55  .9 .9  9   400  6000    .2     3

i1     56  6   7.10 55  .9 .9  9   400  6000    .2     3

i1     56  6   8.00 55  .9 .9  9   400  6000    .2     3

i1     56  6   8.03 55  .9 .9  9   400  6000    .2     3

i1     56  6   8.07 55  .9 .9  9   400  6000    .2     3  
 

;ins(4) st dur wv amp frq randev randspd panfun rvbsnd envfun
 

i4      46   5  8   85 5.09 0      0        2     .01    13

i4      51   5  8   85 5.07 0      0        2     .01    13

i4     56   6  8   85 5.01 0      0        2     .01    13

i4     56   6  8   85 6.01 0      0        2     .01    13

i4     48   1  10  82 9.07 2      40       2     .2     13

i4     49  1.5 10  82 10.02 0     0        2      .2     13

i4     50.5  .5 10  82 10.04 2     40       2      .2    13

i4     51    2  10  82  9.09 0     0        2       .2   13

i4     52    3  10  82 10.00 3.5   40       2       .2   13

i4     56   1.5  10  82 10.00 0     0        2       .2   13

i4    57.5   .5  10  82 9.10  0     0        2       .2    13

i4     58   1  10  82 10.03 0     0        2       .2    13

i4     59   1  10  82 9.07  4     50       2       .2     13

i4     60   1  10  82 10.02 4     40       2       .2     13

i4     61   2  10  82 10.07 5     50       2       .2     13

i4     46  8   1  70  7.07 20    20       12    .3      13
 

;ins(21) st dur wv amp frq  randev randspd panfun rvbsnd envfun pchwv

i21     60  7  1  56  7.11    2      5      3     .35      13    44

i21     60  7  1  56  7.11    0      0      4     .35      13    45

i21     60  7  1  56  7.11    8      10     3     .35      13    46

i21     60  7  1  56  7.11    10     20     4     .35      13    47

i21     60  7  1  56  7.112   2      5      3     .35      13    44

i21     60  7  1  56  7.112   0      0      4     .35      13    45

i21     60  7  1  56  7.112   8      10     3     .35      13    46

i21     60  7  1  56  7.112   10     20     4     .35      13    47

i21     60  7  1  56  7.108   2      5      3     .35      13    44

i21     60  7  1  56  7.108   0      0      4     .35      13    45

i21     60  7  1  56  7.108   8      10     3     .35      13    46

i21     60  7  1  56  7.108   10     20     4     .35      13    47

i21     60  7  1  56  7.11    0      0      3     .35      13    48

i21     60  7  1  56  7.112   0      0      3     .35      13    48

i21     60  7  1  56  7.108   0      0      3     .35      13    48
 

;ins(3) st dur bndwth swpst swpend envrpt envfun panrpt panfun rvgn amp

i3     47  4    50    6000  500     4      13     4       13    .2  .03

i3     51  5    40    7000  500     5      13     5       13    .2  .035

i3     56  6    30    50    500     3      13     3       13    .15  .0015
 

;mellow sect 66

i98 66 102 1.421 .8

i16 66 3 65 7.11  .6 7 .15

i16 68 3 65 8.06  .6 7 .6

i16 70 3 65 8.04  .6 5 .6

i16 73 3 65 9.01 .6 7 .7

i16 74 3 65 8.09  .6 7 .3

i16 75 3 65 8.05  .6 5 .4

i16 76 2 65 8.03 .6 7 .2

i16 77 3 65 7.10 .6 7 .6

i14 79 2 70 7.09 .4

i14 80 4 70 8.04 .4

i16 81 3 65 9.07 .5 7 .6

i14 82 1 70 8.02

i14 83 6 70 7.07 .4

i16 84 4 65 9.03 .5 5 .7

i14 88 5 70 7.06 .4

i16 87 6 65 9.04 .5 6 .4

i13 89 1 72 8.05 .3

i13 90 1 72 8.09 .3

i13 91 1 72 8.11 .4

f0 93 3

i14 97 5 70 7.04 .4

i16 96 6 65 9.01 .5 6 .4

i13 98 2 72 8.03 .3

i13 99 2 72 8.07 .3

i13 100 2 72 8.09 .4

f0 102 3

i17 105 2 70 5.00 .3 .4 

f0 107 3

i17 110 1 70 5.00 .3 .4

i17 110.5 2 73 4.10 .9 .5

f0 112.5 4.5

i11 116 3  60 9.02  .5

i11 116 10 40 6.07  .5

i12 116 2  60 7.07  .5

i12 117 2  60 7.09  .5

i12 118 5  60 7.11  .5

i11 119 3  60 9.01  .5

i11 120 2  60 9.06  .5

i13 121 2  60 8.01  .5

i14 122 3  60 8.09  .6

i11 125 10 40 6.08  .5

i12 125 10 60 7.08  .5

i11 126 2  60 9.00  .5

i11 127 8  60 9.07  .5

i12 128 2  60 8.00  .5

i12 129 2  60 8.07  .5

i12 130 4  60 8.04  .5

i11 134 5  60 8.07  .5

i11 134 5  60 8.11  .5

i11 134 5  60 9.03  .5

i11 134 5  66 9.06  .5

i12 135 5  60 6.07  .5

i15 136 2  60 10.02 .7

i15 137 2  60 10.01 .7

i15 138 2  60 10.06 .7

i15 139 2  60 10.05 .7

f0 141 3

i17 144 3 77 5.05 .3 .4

f0 147 2

i17 149 2 73 5.05 .5 .4

i17 151 .5 77 5.11 1 .4

f0 151.5 2.5

i17 154 .2 73 5.05 .3 .3

i17 154.2 .2 74 5.11 .4 .3

i17 154.4 .2 75 6.04 .5 .3

i17 154.6 .2 76 6.06 .6 .3

i17 154.8 .2 75 6.03 .7 .3

i17 156   .2 70 6.00 .8 .3

i17 157.4 .2 70 6.02 .4 .3

i17 157.8 .2 70 5.11 .6 .3

i17 158.6 .2 68 6.01 .8 .3

i17 159   .2 64 5.10 .9 .33

i11 158   8  50 5.10 .4 

i17 166 2 65 5.05 .5 .4 
 

i98 168 24 .511 .7

i98 177 8 1.237 .9

i98 191 2 1.116 1.2

i99 168 24 2 .2

i9 168 4 24 21 22 23 5.04 75

i9 + 2 24 23 22 21 5.02 75 

i9 + 3 24 22 21 23 6.00 75

i9 + 3 24 21 23 22 5.11 75

i10 169 1   7.08 50 21 20 .3 0  0 25 

i10 170 1.5 8.03 55 21 20 .3 6 .5 25

i10 + .5  8.01 53 21 20 .3 0  0 25

i10 + 2   7.06 57 23 22 .5 7 .6 25

i10 + 1   7.07 57 21 20 .4 0  0 25

i10 + 1.5 8.04 60 21 20 .4 6 .7 25

i10 + .5  8.02 53 21 20 .4 0  0 25

i10 + 3   7.09 56 23 22 .6 9 .8 25

i9 180 4 24 21 22 23 5.09 85

i9 + 2 24 23 22 21 5.07 85

i9 + 3 24 22 21 23 6.05 85

i9 + 2 24 21 23 22 6.04 85

i9 + 1 24 21 23 22 6.02 85

i10 181 1   8.01 50 21 20 .3 3 .5 25

i10 182 1.5 8.08 55 21 20 .3 7 .6 25

i10 + .5   8.06 53 21 20 .3 0  0 25

i10 +  2   7.11 57 21 20 .5 3 .9 25

i10 + 1    8.00 57 21 20 .4 5 .3 25

i10 + 1.5  8.09 60 21 20 .4 5 .7 25

i10 + .5   8.07 53 21 20 .4 0  0 25

i10 + 3    8.02 56 23 22 .6 6 .8 25

i10 181 1   9.01 50 21 20 .3 3 .5 25

i10 182 1.5 9.08 55 21 20 .3 7 .6 25

i10 + .5   9.06 53 21 20 .3 0  0 25

i10 + 2    8.11 57 23 22 .5 3 .9 25

i10 + 1    9.00 57 21 20 .4 5 .3 25

i10 + 1.5  9.09 60 21 20 .4 5 .7 25

i10 + .5   9.07 53 21 20 .4 0  0 25

i10 + 3    9.02 56 23 22 .6 6 .8 25

;ins(1) st dur frq amp atk rel wv swpst swpend rvbsnd panfun

i1      168  4   7.11 45 .9  .9  9   6000  500    .15    4

i1      168  4   8.06 45 .9  .9  9   6000  500    .15    4

i1      168  4   8.08 45 .9  .9  9   6000  500    .15    4

i1      172  2   7.09 45 .9  .9  9   6000  500    .15    4

i1      172  2   8.04 45 .9  .9  9   6000  500    .15    4

i1      172  2   8.06 45 .9  .9  9   6000  500    .15    4

i1      174  3   8.02 45 .9  .9  9   6000  500    .15    4

i1      174  3   8.04 45 .9  .9  9   6000  500    .15    4

i1      174  3   8.11 45 .9  .9  9   6000  500    .15    4

i1      177  3   8.02 45 .9  .9  9   500  6000    .15    4

i1      177  3   8.06 45 .9  .9  9   500  6000    .15    4

i1      177  3   8.09 45 .9  .9  9   500  6000    .15    4

i1     180  4   8.02 45 .9  .9  9   6000  500    .15    4

i1     180  4   8.06 45 .9  .9  9   6000  500    .15    4

i1     180  4   8.09 45 .9  .9  9   6000  500    .15    4

i1     184  2   8.02 48 .9  .9  9   6000  500    .15    4

i1     184  2   8.06 48 .9  .9  9   6000  500    .15    4

i1     184  2   8.09 48 .9  .9  9   6000  500    .15    4

i1     186  3   8.02 51 .9  .9  9   6000  500    .15    4

i1     186  3   8.07 51 .9  .9  9   6000  500    .15    4

i1     186  3   8.11 51 .9  .9  9   6000  500    .15    4

i1     189  3   8.06 53 .9  .9  9   500  6000    .15    4

i1     189  3   8.09 53 .9  .9  9   500  6000    .15    4

i1     189  3   9.01 53 .9  .9  9   500  6000    .15    4

;192

i99 192 90 4 .3

i98 210 72 .501 .7

i18 192  4   70 5.00 .3

i18 192   4   70 6.00 .3

i18 193   2   75 9.04 .35

i18 193   3   70 8.02 .3

i18 193.5 2.5 70 8.07 .3

i18 194   2   70 8.11 .3

i18 194   2   75 9.00 .3

i18 196   3   70 4.10 .3

i18 196   3   70 5.10 .3

i18 196   3   70 8.02 .3

i18 196   3   70 8.05 .3

i18 196   2   70 8.09 .3

i18 198   1   70 8.07 .3

i18 196   3   75 9.02 .4

f0 199 2

i18 201    4   70 5.00 .3

i18 201    4   70 6.00 .3

i18 202   2   75 9.04 .35

i18 202   3   70 8.02 .3

i18 202.5 2.5 70 8.07 .3

i18 203   2   70 8.11 .3

i18 203   2   75 9.00 .3

i18 205   3   70 4.10 .3

i18 205   3   70 5.10 .3

i18 205  3   70 8.02 .3

i18 205  3   70 8.05 .3

i18 205  2   70 8.09 .3

i18 205  1   70 8.07 .3

i18 205  3   75 9.02 .4

;ins(1) st    dur frq  amp atk rel wv swpst swpend rvbsnd panfun

i1      207.5  3   8.04 35 .9  .9  9   500   6000    .9    4

i1      207.5  3   8.07 35 .9  .9  9   500   6000    .9    4

i1      207.5  3   9.00 35 .9  .9  9   500   6000    .9    4

i18 210 4 70 5.03 .3

i18 210 4 70 6.03 .3

i18 211 2 75 9.07 .35

i18 211 3 70 7.07 .3

i18 211 3 70 7.10 .3

i18 211 3 70 8.02 .3

i18 211 3 70 8.05 .3

i18 214 2 70 4.10 .3

i18 214 2 70 5.10 .3

i18 216 2 70 5.01 .3

i18 216 2 70 6.01 .3

i18 214 3 70 7.05 .3

i18 214 3 70 7.08 .3

i18 214 3 70 8.01 .3

i18 214 3 70 8.03 .3

i18 213 1 75 9.03 .35

i18 214 3 75 9.05 .35

i1      216.5  1.5   8.04 35 .9  .9  9   500   6000    .9    4

i1      216.5  1.5   8.07 35 .9  .9  9   500   6000    .9    4

i1      216.5  1.5   9.00 40 .9  .9  9   500   6000    .9    4

i18 218 4 70 5.03 .3

i18 218 4 70 6.03 .3

i18 219 2 75 9.07 .35

i18 219 3 70 7.07 .3

i18 219 3 70 7.10 .3

i18 219 3 70 8.02 .3

i18 219 3 70 8.05 .3

i18 222 2 70 4.10 .3

i18 222 2 70 5.10 .3

i18 224 1 70 5.01 .3

i18 224 1 70 6.01 .3

i18 222 3 70 7.05 .3

i18 222 3 70 7.08 .3

i18 222 3 70 8.01 .3

i18 222 3 70 8.03 .3

i18 221 1 75 9.03 .35

i18 222 3 75 9.05 .35

i19 210 1 70  9.07 .5

i19 211 2 70 10.02 .5

i19 213 1 70 10.00 .5 

i19 214 3 70  9.05 .5

i19 218 1 70  9.07 .5

i19 219 2 70 10.02 .5

i19 221 1 70 10.00 .5

i19 222 3 70 10.03 .5

i12 211 1 73 7.07 .3

i12 212 1 75 7.08 .3

i12 213 1 77 7.10 .3

i12 214 3 79 8.00 .3

i12 219 1 73 7.07 .3

i12 220 1 75 7.08 .3

i12 221 1 77 7.10 .3

i12 222 3 79 8.05 .3

f0 225 1

i18 226 8 70 4.10 .3

i18 226 8 70 5.10 .3

i18 227 2 60 9.07 .35

i12 227 2 75 9.07 .4

i18 227 3 70 7.07 .3

i18 227 3 70 7.10 .3

i18 227 3 70 8.02 .3

i18 227 3 70 8.05 .3

i18 230 3 70 7.05 .3

i18 230 3 70 7.08 .3

i18 230 3 70 8.01 .3

i18 230 3 70 8.03 .3

i18 229 1 60 9.03 .35

i12 229 1 75 9.03 .4

i18 230 3 60 9.05 .35

i12 230 3 75 9.05 .4

i1      232.5  1.5   8.10 35 .9  .9  9   5000   600    .9    4

i1      232.5  1.5   9.00 35 .9  .9  9   500   6000    .9    4

i1      232.5  1.5   9.03 40 .9  .9  9   5000   600    .9    4

i1      232.5  1.5   9.05 40 .9  .9  9   500   6000    .9    4

i18 234 8 70 4.10 .3

i18 234 8 70 5.10 .3

i18 235 2 60 9.07 .35

i12 235 2 75 9.07 .4

i18 235 3 70 7.07 .3

i18 235 3 70 7.10 .3

i18 235 3 70 8.02 .3

i18 235 3 70 8.05 .3

i18 238 3 70 7.05 .3

i18 238 3 70 7.08 .3

i18 238 3 70 8.01 .3

i18 238 3 70 8.03 .3

i18 237 1 60 9.03 .35

i12 237 1 75 9.03 .35

i18 238 3 60 9.05 .35

i12 238 3 75 9.05 .35

;ins(4) st dur wv amp frq randev randspd  panfun    rvbsnd envfun

i4      226 1   16 77  8.07   5      30       2       .3    13

i4      227 2   16 77  9.02   4      40      2       .3    13

i4      229 1   16 77  9.00   5      30      2       .3    13

i4      230 3   16 77  8.05   5      50      2       .3    13

i4      234 1   16 78  8.07   5      30      2       .3    13

i4      235 2   16 78  9.02   4      40      2       .3    13

i4      237 1   16 78  9.00   5      30      2       .3    13

i4      238 8   16 78  9.03   5      50      2       .3    43

i19 227 2 70  8.05 .5

i19 227 2 70  8.10 .5

i19 229 2 70  8.05 .5

i19 229 2 70  8.10 .5

i19 231 2 70  8.05 .5

i19 231 2 70  8.10 .5

i19 233 2 70  8.05 .5

i19 233 2 70  8.10 .5

i19 235 2 70  8.05 .5

i19 235 2 70  8.10 .5

i19 237 2 70  8.05 .5

i19 237 2 70  8.10 .5

i19 239 2 70  8.05 .5

i19 239 2 70  8.10 .5

;i19 49 2 70  8.05 .5

;i19 49 2 70  8.10 .5

i12 226 1 75 8.02 .3

i12 227 1 75 8.03 .3

i12 228 1 75 8.05 .3

i12 229 1 75 8.10 .3

i12 230 2 75 8.08 .5

i12 231 1 68 8.07 .6

i12 232 1 68 8.05 .6

i12 233 1 68 8.03 .6

i12 234 1 75 8.02 .3

i12 235 1 75 8.03 .3

i12 236 1 75 8.05 .3

i12 237 1 75 8.10 .3

i12 238 3 75 9.00 .5

i12 239 1 68 8.08 .6

i12 240 1 68 8.03 .6

i12 241 1 68 8.00 .6

;ins(3) st dur bndwth swpst swpend envrpt envfun panrpt panfun rvgn amp

i3      226  6   100   6000   300    24      6     1       13    .1   .04

i3      234  6   50    7500   300    24      6     1       3    .1    .04

i3      234  6   50    300    7500   24      6     1       4    .1    .04

i12 244 6 70 7.04 .6

i12 244 6 70 7.07 .6

i12 244 6 70 8.00 .6

i12 249 5 69 7.04 .6

i12 249 5 69 7.09 .6

i12 249 5 69 8.01 .6

i12 253 5 66 7.07 .6

i12 253 5 66 7.11 .6

i12 253 5 66 8.02 .6

i12 257 5 63 7.10 .6

i12 257 5 63 8.01 .6

i12 257 5 63 8.06 .6

i12 261 5 60 7.10 .6

i12 261 5 60 8.03 .6

i12 261 5 60 8.07 .6

i12 266 15 57 8.03 .6

i12 266 15 57 8.07 .6

i12 266 15 57 8.11 .6

i12 266 15 57 9.02 .6

i18 244 6 70 5.10 .3

i18 249 5 69 5.07 .3

i18 253 5 66 5.05 .3

i18 257 5 63 5.04 .3

i18 261 5 60 5.01 .3

i18 266 15 57 5.00 .3

i18 244 6 70 6.05 .3

i18 249 5 69 6.02 .3

i18 253 5 66 6.00 .3

i18 257 5 63 5.11 .3

i18 261 5 60 5.08 .3

i18 266 15 57 5.07 .3

i15 244 6 70 9.02 .3

i15 249 5 69 8.11 .3

i15 253 5 66 8.09 .3

i15 257 5 63 8.08 .3

i15 261 5 60 8.05 .3

i15 266 15 57 8.04 .3

i20 274 4 63 7.11 .5

e

</CsScore>

</CsoundSynthesizer>