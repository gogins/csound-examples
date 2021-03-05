	sr	=	22050
	kr	=	2205
	ksmps	=	10
	nchnls	=	1

;=============================================================================
;               Karplus Strong Algorithm Demonstration                       
;                                                                            
;This is a crude implementation of the Karplus-Strong Plucked String Algorithm
;It simply fills a delay line with noise, then feeds the output through a tone
;filter and back into the delay line.  The pitch produced is determined by the
;length of the delay line, and the "pluck" effect caused by the lowpass filter
;in the feedback loop, which gradually removes the high frequencies from the  
;noise, eventually leaving nothing but the fundamental frequency of the line. 
;Study this to see how the basic algorithm works, but use Pluck in real life. 
;RP                                                                           
;=============================================================================
	instr	1
; roll your own pluck instrument
icps    =       cpspch(p5)              ;desired pitch in PCH
asig    init    0                       ;initialize asig variable
kcount  init    1/icps*kr               ;and loop counter (see below)

;---------------------- use a delay line of length 1/cps:

adel    delayr  1/icps			;delay of 1/cps seconds
asig    tone    adel,sr/2               ;filter the output

;---------------------- but at the first k, fill the delay line with noise:

        if (kcount < 0) kgoto continue  ;skip over after line filled
kloop:                                  ;loop to fill delay
asig    rand    p4,-1                   ;with white noise
kcount  =       kcount - 1              ;decrement loop counter
;-----------------------------------------------------------------------------

continue:
        delayw  asig                    ;delay line input (always get here)

        if      (kcount >= 0) kgoto kloop ;loop only kcount times at start 

        out     asig
        endin
