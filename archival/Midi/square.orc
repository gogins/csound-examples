sr      =       44100
kr      =       4410
ksmps   =       10

instr   1
        icps    cpsmidi
        iamp    ampmidi 10000, 100
        iscale  =       iamp / 2000
        iattk   =       .1
        keg     expseg  .001, iattk, 1, .1, .6, .2, .9, .3, .6, 1, .001, 999, .001
        keg     linenr  iamp * keg, iattk, .5, .25
        kmeg    expseg  .001, iattk, iscale, .3, .9, .1, .6, 1, .001, 999, .001
        a1      foscil  keg, icps, 1, 2.002, kmeg, 1
        out     a1
endin

instr  2
        icps   cpsmidi
        iamp   ampmidi 500, 100
        im1frq =      12*icps
        idur   =      1/p3

        kc1eg  oscil  900, idur, 2
        kc1eg  linenr kc1eg*iamp, .01, .333, .05
        kc2eg  oscil  850, idur, 4
        kc2eg  linenr kc2eg*iamp, .01, .333, .05

        km1eg  oscil  850, idur, 3
        km1eg  linenr km1eg*iamp, .01, .333, .05
        km2eg  oscil  800, idur, 5
        km2eg  linenr km2eg*iamp, .01, .333, .05

        am1    oscil  km1eg, im1frq, 1
        am2    oscil  km2eg, icps, 1
        ac1    oscil  kc1eg, icps + am1, 1
        ac2    oscil  kc2eg, icps + am2, 1

        out    (ac1 + ac2) * 2
endin

instr   3
        icps    cpsmidi
        iamp    ampmidi 1000, 100
        imodrat =       icps * 1.015
        idur    =       1 / p3

        kenv    oscil   1000,  idur,  6
        kenv    linenr  kenv * iamp,  .001, .5, .25
        kmen    oscil      9,  idur,  7
        kmen    linenr  kmen * iamp,  .001, .5, .25

        kpeg    oscil   -200,  idur,  8
        kpeg    linenr  kpeg * iamp,  .001, .5, .25

        klfo    oscil      2,     6,  1

        amod    oscil   kmen, imodrat,  1

        a1      oscil   kenv, icps + amod + kpeg,  1
        a2      oscil   kenv, icps + amod + kpeg + klfo,  1

        out     (a1 + a2) * .5
endin

instr   4
        icps    cpsmidi
        iamp    ampmidi 10000, 100
        iscale  =       iamp / 1000
        keg     expseg  .001, .01, 1, .1, .8, 999, .001
        keg     linenr  keg * iamp, .01, .333, .05
        kmeg    expseg  .001, .01, iscale, .25, .2, 999, .001
        a1      foscili keg, icps, 1, 1.4, kmeg, 1
                out     a1
endin

                instr   5
        iamp    =       15000
        ifc            cpsmidi      ;S = fc +- ifm1 +- kfm2 +- lfm3
        ifm1    =       ifc
        ifm2    =       ifc*3
        ifm3    =       ifc*4
        indx1   =       7.5/log(ifc)    ;range from ca 2 to 1
        indx2   =       15/sqrt(ifc)    ;range from ca 2.6 to .5
        indx3   =       1.25/sqrt(ifc)  ;range from ca .2 to .038
        kvib    init    0                

                timout  0,.75,transient  ;delays vibrato for p8 seconds
        kvbctl  linen   1,.5,10,.1   ;vibrato control envelope
        krnd    randi   .0075,15        ;random deviation in vib width        
        kvib    oscili  kvbctl*.03+krnd,5.5*kvbctl,1 ;vibrato generator
        
transient:
        timout  .2,10,continue          ;execute for .2 secs only
        ktrans  linseg  1,.2,0,1,0      ;transient envelope 
        anoise  randi   ktrans,.2*ifc   ;noise... 
        attack  oscil   anoise,2000,1   ;...centered around 2kHz

continue:      
        amod1   oscili  ifm1*(indx1+ktrans),ifm1,1
        amod2   oscili  ifm2*(indx2+ktrans),ifm2,1
        amod3   oscili  ifm3*(indx3+ktrans),ifm3,1
        asig    oscili  iamp,(ifc+amod1+amod2+amod3)*(1+kvib),1
        asig    linen   asig+attack,.26,10,.2
        imax ampmidi 1, 100
        kgate linenr imax, 0, 1, .01
                out     asig * kgate
        
                endin
