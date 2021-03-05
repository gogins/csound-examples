;=======================================================================;
; WAVSHAPE        Score for the General Purpose Waveshaping Instrument  ; 
;                 This demonstrates the use of high partials, sometimes ;
;                 without a fundamental, to get quasi-inharmonic        ;
;                 spectra from waveshaping.                             ;
;=======================================================================;
; sine
f1 0 512 10  1
; transfer func1: h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15 h16
f4 0 513 13  1  1  0  1 -.8 0 .6  0  0  0 .4  0   0   0   0  .1 -.2 -.3  .5
; normalizing function with midpoint bipolar offset:
f5 0 257  4  4  1
;=======================================================================;
; WAVSHAPE        p4       p5                                           ;
;                 amp      pch                                          ;
;=======================================================================;
i1    0     4     10000    5.00   
i1    4     4     10000    6.00   
i1    8     4     10000    7.00   
s
f0    1
s
; transfer func2: h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15 h16
f4 0 513 13  1  1  0  0  0 -.1 0 .3  0 -.5 0 .7   0 -.9   0   1   0  -1   0
i1    0     4     10000    5.00  
i1    4     4     10000    6.00    
i1    8     4     10000    7.00    
s
f0    1
s
; transfer func3: h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15 h16
f4 0 513 13  1  1  0  0  0  0  0  0  0 -1  0  1   0   0 -.1   0  .1   0 -.2
;                  h17 h18 h19 h20 h21 h22 h23
                   .3   0 -.7   0  .2   0 -.1                        
i1    0     4     10000    5.00  
i1    4     4     10000    5.06   
i1    8     4     10000    6.00   
e
