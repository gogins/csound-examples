;==============================================================================;
;          Score to generate random "popcorn" texture with popcorn2.orc        ;
;==============================================================================;
f1      0       512     10      1
;gate function
f2      0       513     5       .01     12      1       100     1       400     .001
;grain duration function
f3      0       9      -7       .03     9       .03
;gap duration fn
f4      0       9      -7       .1      9       .1
;Gen 3 example from Vercoe:     xval1   xval2   c0/5    c1/6    c3/7    c4/8
f 5     0       1025    3       -1      1       5       4       3       2
                                                2       1
;Gen 6 example from Vercoe:     a/c/e   n1/3/5  b/d/f   n2/4/6
f 6     0       65      6       0       16      .5      16
                                1       16      0       16
                               -1
;Gen 8 examples from Vercoe:    a/c/e   n1/3/5  b/d/f   n2/4/6
f 7     0       65      8       0       16      0       16
                                1       16      0       16
                                0
f 8     0       65      8       0       16      0       .1
                                0       15.9    1       15.9
                                0       .1      0       16
                                0
;Gen 3 example: f(x) = x^2      xval1   xval2   c0/5    c1/6    c3/7    c4/8
f 9     0       513     3       -1      1       0       0       1
;Gen 3 example: f(x) = 1 - x^2
f10     0       513     3       -1      1       1       0      -1
;Gen 3 example: f(x) = 1 + 2x
f11     0       513     3       -1      1       1       2
;Gen 3 example: f(x) = 1 + 2x - x^3
f12     0       513     3       -1      1       1       2       0       -1
;Center Pitch function:
f13     0       9       -7      8.5     9       8.5
;Var Pitch function:
f14     0       9       -7      3       9       3
;                   amp    cpchfn vpchfn gapfn grnfn prbfn gatefn cpanfn vpanfn
i1      0       60  10000  13     14     4     3     8     2      6      5
; seed1   2   3   4
      0   0   0   0
i1      .       .   .      .      .      .     .     8     .      .      .
     .1  .1  .1  .1
i1      .       .   .      .      .      .     .     10    .      .      .
     .2  .2  .2  .2
i1      .       .   .      .      .      .     .     10    .      .      .
     .3  .3  .3  .3
e
