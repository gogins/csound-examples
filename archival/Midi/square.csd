<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo square.wav -F temp.mid temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr      =       48000
kr      =       48000
ksmps   =       1

instr   1
        icps    cpsmidi
        iamp    ampmidi 10000, 100
        iscale  =       iamp / 2000
        iattk   =       .1
        keg     expseg  .001, iattk, 1, .1, .6, .2, .9, .3, .6, 1, .001, 999, .001
        keg     linenr  iamp * keg, iattk, .5, .25
        kmeg    expseg  .001, iattk, iscale, .3, .9, .1, .6, 1, .001, 999, .001
        a1      foscili  keg - .001, icps, 1, 2.002, kmeg - .001, 1
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
</CsInstruments>
<CsScore>
f0     180
f1	0	16384 	10  	1
f2     	0    	128  	7  	0   1  1  30  .7  30  .3  67  0
f3     	0    	128  	7  	0   1  1  50  .8  40  .2  37  0
f4     	0	128  	7  	0   1  1  40  .9  50  .1  37  0
f5     	0    	128  	7  	0   1  1  50  .6  50  .2  27  0
f6     	0    	128  	7  	0   1  1    7  .5    20  .35  60  .25  40   0
f7     	0    	128  	7  	0   1  1    7  .5    20  .25  60  .45  40  .9
f8     	0    	128  	7  	1  18  0  110   0

f100   0    128  7  0 128  1
e










</CsScore>
<CsMidifile>
<Size>
322
</Size>
MThd      àMTrk  , ÿpluckmidi.midi ÿT`     +@ ÿX ÿQB@d+@2@l2@;@l;@0@l0@7@l7@@@l@@.@d.@5@l5@>@l>@'@l'@.@l.@7@l7@%@d%@,@l,@5@l5@*@l*@1@l1@:@l:@(@d(@/@l/@8@l8@-@l-@4@l4@=@l=@+@d+@2@l2@;@l;@*@l*@2@l2@;@l;@(@n(@*ÿ/ </CsMidifile>
</CsoundSynthesizer>
