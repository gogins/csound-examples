/* bass_02.sco - written by Istvan Varga, 2002 */

; harmonic number	1	2	3	4	5	6
f 1 0 4096  10    1.5   0.5   1.0   0.25  0.125 1.0
; sine wave
f 2 0 4096  10    1  

t       0       140   

; bass

i 1 0.520     0.340  32     124 
i 1 1.520     0.360  32     120 
i 1 2.520     0.340  32     127 
i 1 3.520     0.340  32     120 

i 1 4.520     0.320  32     124 
i 1 5.520     0.340  32     120 
i 1 6.520     0.320  32     127 
i 1 7.520     0.320  32     120 

i 1 4.520     0.320  44     112 
i 1 5.520     0.340  44     120 
i 1 6.520     0.320  44     116 
i 1 7.520     0.320  44     112 

; bass drum

i 2 0.000     0.320  32     127 
i 2 1.000     0.320  .      120  
i 2 2.000     0.320  .      124  
i 2 3.000     0.320  .      120  

i 2 4.000     0.320  .      127  
i 2 5.000     0.320  .      120  
i 2 6.000     0.320  .      124  
i 2 7.000     0.320  .      120  

e
