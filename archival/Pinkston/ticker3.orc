sr        =         44100
kr        =         4410
ksmps     =         10
nchnls    =         2


          instr     1
iamp      =         p4
ipch      =         p5
irise     =         p6
idecay    =         p7
ipkhz     =         p8
iamfn     =         p9
isinefn   =         p10
ihzfn     =         p11
ipanfn    =         p12
ibend     =         p13
ibendfn   =         p14


klfohz    oscil1i   0,ipkhz,p3,ihzfn
kpanfac   oscil1i   0,1,p3,ipanfn
kbendfac  oscil1i   0,ibend,p3,ibendfn
klfohz    init      ipkhz
reinitstart:
ilfodur   =         1/25
kmicro    oscil1i   0,iamp,ilfodur,iamfn
          timout    0,1/i(klfohz),continue
          reinit    reinitstart
continue:
          rireturn
aw1       linen     kmicro,irise,p3,idecay
icps      =         cpspch(ipch)
kcps      =         (kbendfac) * (icps) + (icps)
aw2       oscili    aw1,kcps,isinefn
aw4       =         (aw2) * (sqrt(1-kpanfac))
aw3       =         (sqrt(kpanfac)) * (aw2)
          outs      aw3,aw4
          endin
