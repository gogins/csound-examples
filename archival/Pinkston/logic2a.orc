sr        =         44100
kr        =         22050
ksmps     =         2
nchnls    =         1

            instr       1
klfodur     oscil1      0, p9, p3, 3
reinitstart:
kmicro      oscil1i     0, p4, .1, 2
idur        =           i(klfodur)
            timout      0, idur, continue
            reinit      reinitstart
continue:
            rireturn                
kmacro      linen       1, p3*.1, p3, p3*.9
ifund       =           cpspch(p5)
kindexv     =           (p8)*(kmicro/p4)
kindex      =           (kmacro)*(kindexv)
kamp        =           (kmacro)*(kmicro)
aw2         foscili     kamp, ifund, p6, p7, kindex, 1
            out         aw2
            endin       
