;=======================================================================;
; FILTERDEMO        Score for Filter Demo Orchestra by Russell Pinkston ;
;=======================================================================;
; The Original Sound                            Soundin #5
i1    0     2.5     5
; Simple Moving Average Filter                  Low-Pass with Fc at SR/4
i2    2.5   2.5     5     0
; Simple Difference Filter                      High-Pass with Fc at SR/4
i3    5     2.5     5     15
; Second-Order Notch Filter                     Null at SR/4,...
i4    7.5   2.5     5     .75                  ;...Flat at 0 and Nyquist
; Second-Order Band-Pass Filter
i5    10    2.5     5     10
; Second-Order Notch with Variable Center Frequency and Bandwidth
i6    12.5  2.5     5     1000     100      .6
; First-Order Recursive Filter with Low-Pass Characteristics (p5 = cutoff)
i7    15    2.5     5     100      2
; First-Order Recursive Filter with High-Pass Characteristics (p5 = cutoff)
i8    17.5  2.5     5     500      9
; Second-Order All-Pole Filter (p5 = center freq, p6 = bandwidth)
i9    20    2.5     5     300      30     1       3
e

