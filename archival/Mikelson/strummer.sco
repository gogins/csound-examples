f1 0 8192 10 1
f2 0 1024 7  1 1024 -1
f3 0 1024 7 0 16 1 368 .6 512 .4 128 0

; Temperaments I can't figure out how to get the temperaments to work.
f4 0 16 -2 1.000 1.067 1.121 1.196 1.273 1.344 1.422 1.496 1.600 1.703 1.798 1.903 2.000 ; Werkmeister III
f5 0 16 -2 1.000 1.059 1.122 1.189 1.260 1.335 1.414 1.498 1.587 1.682 1.782 1.888 2.000 ; Equal
f6 0 16 -2 1.000 2.000 3.000 4.000 1.260 1.335 1.414 1.498 1.587 1.682 1.782 1.888 2.000 ; Equal

; Chords
f10 0 4 -2  0  4  7 12    ; Major
f11 0 4 -2  0  3  7 12    ; Minor
f12 0 4 -2  0  5  7 12    ; Sus4
f13 0 4 -2  0  2  7 12    ; Sus2
f14 0 4 -2  0  4  7 10    ; 7th
f15 0 4 -2  0  3  7 10    ; Minor7th
f16 0 4 -2  0  3  7 11    ; Min/maj7th
f17 0 4 -2  0  4  7 11    ; Maj7th
f18 0 4 -2  0  4  7  9    ; Major6th
f19 0 4 -2  0  3  7  9    ; Minor6th
f20 0 4 -2  0  4 10 14    ; 9th
f21 0 4 -2  0  4 10 17    ; 11th
f22 0 4 -2  0  4 10 21    ; 13th
f23 0 4 -2  0  3  6 12    ;

;6/9:            0  4  7  9 14
;Min9th:         0  3  7 10 14
;Min11th:        0  3  7 10 17
;Min13th:        0  3  7 10 21
;Maj9th:         0  4  7 11 14
;Maj11th:        0  4  7 11 17
;Maj13th:        0  4  7 11 21
;add2:           0  2  4  7

;   Sta  Dur  Amp   Root  Chord  Wave  Repeat  Env  Phase  Temperament
i1  0    1.6  8000  7.02  10     1     2       3    .20    4
i1  +    1.6  .     7.04  11     .     2       .    .      .
i1  .    0.8  .     6.09  10     .     1       .    .      .
i1  .    1.6  .     7.07  10     .     2       .    .10    .
i1  .    1.6  .     7.02  10     .     1       .    .20    .
;
i1  .    0.8  .     7.02  10     .     1       .    .05    .
i1  .    0.8  .     7.02  11     .     1       .    .05    .
i1  .    0.8  .     7.02  12     .     1       .    .00    .
i1  .    0.8  .     7.02  13     .     1       .    .00    .
i1  .    0.8  .     7.02  23     .     1       .    .05    .
i1  .    1.6  .     7.02  10     .     1       .    .10    .

;   Sta  Dur  Amp   Pitch  Wave  Env  Temperament
;i2  0    .2   8000  7.00   1     3    4
;i2  +    .    .     7.01   .     .    .
;i2  .    .    .     7.02   .     .    .
;i2  .    .    .     7.03   .     .    .
;i2  .    .    .     7.04   .     .    .
;i2  .    .    .     7.05   .     .    .
;i2  .    .    .     7.06   .     .    .
;i2  .    .    .     7.07   .     .    .
;i2  .    .    .     7.08   .     .    .
;i2  .    .    .     7.09   .     .    .
;i2  .    .    .     7.10   .     .    .
;i2  .    .    .     7.11   .     .    .
;i2  .    .    .     7.12   .     .    .
                                                
