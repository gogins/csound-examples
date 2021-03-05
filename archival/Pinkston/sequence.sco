; sine wave for foscil
f01     0       512     10      1
; sequence function -- format:  pch1, amp1, dur1, pch2, amp2, dur2,...
f02     0       32      -2      8.00  .75   .1    7.01  .25   .1
        7.04  .3  .1  6.10  .25  .2  7.09 .5 .5
; interval function (with some locations zero for rests)
f03     0       16      -2      .01     -.01    .11     -.11    1.01    -1.01
       .06      -.06    .07     -.07    .05     -.05
; amp factor function (quarter sine wave)
f04	0	129	9	.25	1	0
; duration function 1
f05     0       8       -2      .5      .25     .25     .125    .125
        .125    .0625   .0625
; duration function 2
f06     0       8       -2      .5      .33333  .33333  .16667  .16667
        .16667  .08333  .08333
; envlpx rise func
f07     0       513     5       .01     512     1
;======================================================================;
;                     Basic "Sequencer" Instrument                     ;
;                                                                      ;
; p3 = sequence dur  p4 = peak amp       p5 = fno for note information ;
; p6 = overall rise  p7 = overall decay  p8 = note rise  p9 = note dec ;
; p10 = ndx rise p11 = ndx dec p12 = max ndx p13 = carfac p14 = modfac ;
; note info format: pch, amp, dur; pch, amp, dur; ...                  ;
;======================================================================;
;       st      dur     pkamp   fno     rise    decay   nrise   ndec
i1      0       1       20000  2        .01     .2      .1      .1
;       irise   idec    pkndx   carfac  modfac
        .2      .2      5       1       1
;======================================================================;
;               Controlled Random Sequence Instrument                  ;
;                                                                      ;
; p3 = sequence dur  p4 = duration fno p5 = interval fno  p6 = amp fno ;
; p7 = seq rise p8 = seq decay p9 = noteris p10 = notedec p11 = ndxmax ;
; p12 = pkamp p13 = carfac p14 = modfac p15 = dur seed p16 = pch seed  ;
; p17 = pan seed p18 = seed pitch                                      ;
;======================================================================;
; This will generate a short musical abomination featuring the intervals 1,6,7
;  ...change the seed values and/or contents of the dur, intvl, and amp fns
; for new and different abominations.  Still, something good might come of it...?
;       st      dur     durfn   intfn   ampfn   seqrise seqdec
i2      3       5       5       3       4       .5      .5
;       notris  notdec  ndxmax  pkamp   carfac  modfac  durseed pchseed panseed seedpch
        .05    .25      4       16000   1       1       .010149 .071983 .022186 7.00
;       st      dur     durfn   intfn   ampfn   seqrise seqdec
i2      3       5       6       3       4      .5      .5
;       notris  notdec  ndxmax  pkamp   carfac  modfac  durseed pchseed panseed seedpch
        .1     .25      4       16000   3       2      .070703 .012719 .030251  8.00
e
