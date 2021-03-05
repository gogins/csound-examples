f01     0       512     10      1                       ;sine wave
f02     0       513     7       1       513     0       ;linear decay
;Amp gating function:  f(x) = 1 - x^6, x -> -1, 1
f03     0       513     3       -1      1       1       0       0       0
        0       0       -1
; Soundin 40 is a single cello note - Pitch shift original sound up and down
;                       delay   nsemis  soundin feedfac gainfac lfohz dryfac lvl
i01     0       1       .1      0       40      0       1      0      0      0
i01     +      .5       .       2
i01     +       .       .       4
i01     +       .       .       5
i01     +       .       .       7
i01     +       .       .       9
i01     +       .       .       11
i01     +       1       .       12
i01     +       .5      .       -1
i01     +       .       .       -3
i01     +       .       .       -5
i01     +       .       .       -7
i01     +       .       .       -8
i01     +       .       .       -10
i01     +       1       .       -12
s
f0      .5
s
; Play pitch shifted chord
i01     0       2       .1      -12     40      0       .75
i01     .       .       .       -5
i01     .       .       .       4
i01     .       .       .       12
;
s
; Use feedback with longer delay to generate "harmonizer" effect
;                       delay   nsemis  soundin feedfac gainfac lfohz dryfac lvl
i01     0       3       .33     2       40      .99     .9      0     0      0
i01     +       .       .       5       40      .99     .9
i01     +       .       .       7       40      .99     .9
i01     +       4       .       -12     40      .99     .9
s
f0      1
s
; Create chorus effect by using small pitch shift with lfo plus big feedback
;                       delay   nsemis  soundin feedfac gainfac lfohz dryfac lvl
i01     0       4       .1      .05     40      1.35    1       2     .5
i01     +       .       .       .1
i01     +       .       .       .2
i01     +       .       .       .4
s
f0      .5
s
; Monster feedback!
;                       delay   nsemis  soundin feedfac gainfac lfohz dryfac lvl
i01     0       5       .05     .1      40      1.85    .96     1       .5
i01     +       5       .1      .05     .       .       .       2
i01     +      10       .25     .25     .       .       .       1.5
e
