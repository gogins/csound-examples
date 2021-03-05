; sine wave for foscil
f01     0       512     10      1
; sequence function -- format:  pch1, amp1, dur1, pch2, amp2, dur2,...
f02     0       32      -2      8.00  .75   .1    7.01  .25   .1
        7.04  .3  .1  6.10  .25  .2  7.09 .5 .5
; pitch function 1
f04     0        8      -2      6.00    6.07    7.00    7.07
        8.00    8.03    8.07    8.10
; amp factor function (quarter sine wave)
f05	0	129	9	.25	1	0
; duration function 1
f06     0       8       -2      .25     .25     .25     .25     .125
        .125    .125    .125
; duration function 2
f07     0       8       -2      .25     .25     .125   .125   .125
        .125    .0625   .0625
; pitch function 2
f08     0       32      -2      9.05    9.05    9.05    9.05   9.05
        10.05   10.05   10.05   8.05    8.05    9.055   9.055 10.055
        9.045   9.045  10.045   8.055   8.055   10.055 10.055 9.0525
        9.0525  9.0525 9.0475   9.0475  9.0475
;
; pitch function 3
f09     0       8       -2      7.03    7.03    7.03    7.03
                                7.05    7.05    6.10    0
;
; dur function 3
f10     0       4       -2      .0625   .0625   .125
;======================================================================;
;                     Basic "Sequencer" Instrument                     ;
;                                                                      ;
; p3 = sequence dur  p4 = peak amp       p5 = fno for note information ;
; p6 = overall rise  p7 = overall decay  p8 = note rise  p9 = note dec ;
; p10 = ndx rise p11 = ndx dec p12 = max ndx p13 = carfac p14 = modfac ;
; note info format: pch, amp, dur; pch, amp, dur; ...                  ;
;======================================================================;
; Play a little ditty...
;       st      dur     pkamp   fno     rise    decay   nrise   ndec
i1      0       1       20000  2        .01     .2      .1      .1
;       irise   idec    pkndx   carfac  modfac
        .2      .2      5       1       1
;============================================================================;
;                  Controlled Random Sequence Instrument                     ;
;                                                                            ;
; p3 = seq dur  p4 = peak amp   p5 = dur fno    p6 = pch fno    p7 = amp fno ;
; p8 = seq rise p9 = seq decay  p10 = noteris   p11 = notedec                ;
; p12 = durseed p13 = pchseed   p14 = panseed                                ;
;                                                                            ;
;============================================================================;
; Quick and dirty Lansky...                                                  ;
;       st      dur     pkamp   durfn   pchfn   ampfn   seqrise seqdec
i2      3       40      16000   6       4       5       .001    3
;       notris  notdec  durseed pchseed panseed
        .001    .1      .030251 .071983 .022186
;       st      dur     pkamp   durfn   pchfn   ampfn   seqrise seqdec
i2      5       38      16000   6       4       5       .001    3
;       notris  notdec  pchseed panseed seed2
        .001    .1      .070703 .012719 .081447
;       st      dur     pkamp   durfn   pchfn   ampfn   seqrise seqdec
i2      15      12      18000   7       8       5       2       3
;       notris  notdec  pchseed panseed seed2
        .001    .1      .010149 .100153 .012345
;       st      dur     pkamp   durfn   pchfn   ampfn   seqrise seqdec
i2      28.125  10      12000   10      9       5       2       3
;       notris  notdec  durseed pchseed panseed
        .001    .1      .030251 .071983 .022186
e
