;====================================================================;
;       Rachet instrument                                            ;
;                                                                    ;
;       p4      p5      p6      p7      p8      p9      p10     p11  ;
;       amp     pch     lfohz   gatefn  envfn   panfn   cutoff  Q    ;
;                                                                    ;
;====================================================================;
;sine
f01     0       512     10      1
;gatefn
f02     0       512     7       0       64      1       16      0
;envfn  (exp rise)
f03     0       513     5       .05     512     1
;pan right func (lin rise)
f04     0       129     7      -1       129     1
;pan left func (lin decay)
f05     0       129     7       1       129     -1
;
;               p4      p5      p6      p7      p8      p9      p10     p11  ;
;               amp     pch     lfohz   gatefn  envfn   panfn   cutoff  Q    ;
i1 0    1       20000   13.08   16      2       3       4       0       12
i1 1    1       20000     .     20      2       3       5       .       16
i1 2    1       20000     .     10      2       3       1       .       20
e
