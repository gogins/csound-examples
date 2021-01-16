<CsoundSynthesizer>
<CsLicense>

gendyc etude (2021) by Richard Boulanger

Based on the extreme noise instrument from 'On it's Dark Side' by John ffitch.

</CsLicense>
<CsOptions>
-odac -dm0
</CsOptions>
<CsInstruments>

sr = 96000
ksmps = 20
nchnls = 2
0dbfs = 1

garvbL init 0
garvbR init 0

alwayson 99

instr 6

ibottom init 1000

iamp = p4
irate = p5
iLowL = p6
iHighL = p7
iLowR = p8
iHighR = p9

  kbi init 0
 
  kbi += birnd(p5)
  if (kbi < 0) then
      kbi += ibottom
  endif
  if kbi > ibottom then
      kbi -= ibottom
  endif
 
  ilowerL = ibottom+iLowL
  iupperL = ibottom+iHighL
  ilowerR = ibottom+iLowR
  iupperR = ibottom+iHighR
 
 ; printk2 kbi  
 ; printk2 (28+ilowerL/kbi)
 
 aoutL gendyc iamp, 1, 1, 1, 1, 28+ilowerL/kbi, 39+iupperL/kbi, 1, 1, 100, 12
 aoutR gendyc iamp, 1, 1, 1, 1, 28+ilowerR/kbi, 39+iupperR/kbi, 1, 1, 100, 11
 
 vincr garvbL, aoutL
 vincr garvbR, aoutR
 
endin

         
instr 99
        denorm garvbL, garvbR
aL, aR  freeverb garvbL, garvbR, 0.8765, 0.01
        outs garvbL+(aL*.56), garvbR+(aR*.56)    
        clear garvbL, garvbR
endin  

</CsInstruments>
<CsScore>
 
i6 0    .88   .22  0.1    5000  10000   1000   2000
i6 0    .78   .22  .81   1000  5000   100   500

i6 .1    33   .18  0.003    1 10   1   100

s ;2

i6 0     1   .12  0.09   100  1000   10   200
i6 .21   2   .22  0.02    10  1000    1   100
i6 .53   3   .22  0.1    500  100    300  1000

s ;3

i6 0    18  .16  4.10    10   100    1   200
i6 8    1   .19  0.17    10  1000    400  800
i6 12   1   .11  0.17    10  1000    400  800

s ;4

i6 0    1   .32  0.08    10  1000    1   100
i6 .01 9.9  .02  13.01   10  1000    40  400
i6 3    1   .22  0.07    10  1000    40  400
i6 5    1   .12  0.07    10  1000    400  800
i6 8    1   .12  0.07    10  1000    400  800

s ;5

i6 0     1  .22   0.08    10  1000    1   100
i6 .01 9.9  .09   0.001   10  1000    40  400
i6 8    .9  .22   0.02    10  1000    1   100
i6 8.1  13  .02   13.01   10  1000   1000 2000

s ;6

i6     0    1   .32  0.09    10   200    1   100
i6    .02  40   .02  4.73    10   200    1   100
i6    12    1   .32  0.09    10   200    1   100
i6    22    1   .42  0.09    5     50    2   20
i6    23    2   .11  0.03    40  4000   21  8000

s ;7

i6 0    1   .32  3.1   5000  10000   1000   2000
i6 1    1   .32  1.91   1000  5000   100    500
i6 1.01  8  .06 10.08    10  1000    1      100

s ;8

i6 0    .6   .28  2.1   5000  10000   1000   2000
i6 1    .6   .28  0.91   1000  5000   100   500
i6 1.01  8   .05  10.08    10  1000    1   100

s ;9

i6 0    1   .12  1.1   5000  10000   1000   2000
i6 0    1   .12  0.51   1000  5000   100   500
i6 0.2  33  .13  0.005    1 10   1   100

s ;10

i6 0    .6   .28  2.1   5000  10000   1000   2000
i6 1    .6   .28  0.91   1000  5000   100   500
i6 1.01  8   .04  10.08    10  1000    1   100

s ;11

i6 0    1   .32  1.1   5000  10000   1000   2000
i6 0    1   .32  .91   1000  5000   100   500

s ;12

i6 0    .68   .2  1.91   2000  3000   10   20
i6 0    .78   .2  1.91   2000  3000   10   20
i6 .1   60   .09  14.10    300   400  30   40
i6 28    .7   .35  0.91   2000  3000   10   20
i6 28.1 23.9  .18  0.1   10  1000    40  400

s ;13

i6  0    .8   .32  .1    5000  10000   1000   2000

i6  0.1  53   .13  0.009    .1 .2 .3 .4
i6  0.1  92   .13  0.003    1 10   1   100

i6 9    .8   .21  1.91   2000  3000   10   20
i6 9    .8   .21  1.91   2000  3000   10   20
i6 9.1   18  .04  13.10    300   400  30   40

i6  33     1   .22  0.1    5000  10000   1000   2000
i6  33     1   .22  0.2    5000  10000   1000   2000
i6  33.1   30  .06  9.05    1 10   1   100

s ;14

i6 0    1   .11  0.19    10  1000    400  800
i6 0    1   .11  0.19    100  500    200  1200
i6 0.1  8   .02  4.10    10   100    1   200

i6 8    1   .11  0.17    10  1000    400  800
i6 8    1   .11  0.17    10  1000    400  800
i6 8.1  8   .04  4.09    10   100    1   200

i6 16   1   .20  0.17    10  1000    400  800
i6 16.1 8   .02  4.10    10   100    1   200

i6 24   1   .2  0.17    10  1000    400  800
i6 24.1 10   .03  4.08    10   100    1   200

i6 34   1   .1  0.15    10  1000    400  800

s
f0 6
s
 
e
</CsScore>
</CsoundSynthesizer>