	sr = 22050
        kr = 2205
        ksmps = 10
        nchnls = 1

;======================================================
;	Simple demo instrument for pluck        
;======================================================

        instr   1
icps    =       (p10 == 0 ? cpspch(p5) : cpspch(p10))
asig    pluck   p4,cpspch(p5),icps,p6,p7,p8,p9
        out     asig
        endin

