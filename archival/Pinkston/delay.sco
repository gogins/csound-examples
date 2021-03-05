;==========================================================================;
;               Example Delay Line Instrument                              ;
;                                                                          ;
;       p4 = ampfac     p5 = soundin#   p6 = maxdel     p7 = basedel       ;
;       p8 = pkvardel   p9 = vardelhz  p10 = vardelfn  p11 = feedfac       ;
;==========================================================================;
;
f01     0       513     10      1
;
;       start   dur     ampfac  soundin maxdel  basedel pkvar   varhz   varfn
i01     0       4         2       5       .25     .005    .004    2       1
;       feedfac srcfac  delfac
        0       1      1
s
f0 1
s
i01     0       4         2       5       .5     .005    .004    2       1
        0       1      1
s
f0 1
s

i01     0       4         2       5       .75     .005    .004    2       1
        0       1      1
s
f0 1
s
;       start   dur     ampfac  soundin maxdel  basedel pkvar   varhz   varfn
i01     0       4         2       5       .25     .05    .004    2       1
;       feedfac srcfac  delfac
        0       1      1
s
f0 1
s
i01     0       4         2       5       .75     .05    .004    2       1
        0       1      1
s
f0 1
s
i01     0       4         2       5       1      .05    .004    2       1
        0       1      1
s
f0 1
s
;       start   dur     ampfac  soundin maxdel  basedel pkvar   varhz   varfn
i01     0       4         2       5       .25    .005    .004    2       1
;       feedfac srcfac  delfac
        0       1      1
s
f0 1
s
i01     0       4         2       5       .5     .010    .004    2       1
        0       1      1
s
f0 1
s

i01     0       4         2       5       .75     .02    .004    2       1
        0       1      1
s
f0 1
s

i01     0       4         2       5       1      .040    .004    2       1
        0       1      1
s
f0 1
s

i01     0       4         2       5       1      .080    .004    2       1
        0       1      1
s
f0 1
s

i01     0       4         2       5       1      .160    .004    2       1
        0       1      1
s
f0 1
s

;       start   dur     ampfac  soundin maxdel  basedel pkvar   varhz   varfn
i01     0       4         2       5       .25    .005    .004    2       1
;       feedfac srcfac  delfac
        0       1      1
s
f0 1
s
i01     0       4         2       5       .5     .010    .009    2       1
        0       1      1
s
f0 1
s

i01     0       4         2       5       .75     .02    .019    2       1
        0       1      1
s
f0 1
s

i01     0       4         2       5       1      .040    .039    2       1
        0       1      1
s
f0 1
s

i01     0       4         2       5       1      .080    .079    2       1
        0       1      1
s
f0 1
s

i01     0       4         2       5       1      .160    .159    2       1
        0       1      1
e
