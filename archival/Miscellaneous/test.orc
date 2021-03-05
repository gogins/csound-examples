kr        =         4410
ksmps     =         10
nchnls    =         1

                                                  ;SOUSTRACTIF PAR TABLES

;p1       =         ins
;P2       =         date
;p3       =         dur
;1        =         n¡ table d'env d'amplitude
;2        =         n¡ table freq 
;p6       =         amplitude globale
     
          instr     1

idur      =         p3 
kfreq     oscil1i   p2,1,p3,2
kenvamp   oscil1i   p2,300,p3,1
anoise    rand      kenvamp                       ; WHITE NOISE
a1        reson     anoise,  kfreq, kfreq/100, 2  ; FILTER
a1        linen     a1, .1, idur, .1

          out       a1
 
          endin
