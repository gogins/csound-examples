<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo eventime.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
        sr      =       44100
        kr      =       4410
        ksmps   =       10
        nchnls  =       1

;==============================================================================;
;                 Eventide Harmonizer Emulation Instrument                     ;
;                                                                              ;
; p4 = n seconds delay  p5 = n semitones shift  p6 = soundin #  p7 = feedfac   ;
; p8 = optional gain factor  p9 = lfo hz  p10 = dry %  p11 = initial gain      ;
;                                                                              ;
; If p9 != 0, a varying delay is applied                                       ;
;                                                                              ;
; Written by Russell Pinkston, 10-21-93                                        ;
;==============================================================================;

        instr   1
ilevel  =       (p11 == 0 ? 1 : p11)            ;initial gain control for source
igain   =       (p8 > 0 ? p8/2 : .5)            ;default to .5 gain per delay
idelay  =       p4                              ;n seconds delay
ioctpct =       p5/12                           ;percentage of an octave
iratio  =       cpsoct(8+ioctpct)/cpsoct(8)     ;ratio of new freq to orig
irate   =       (iratio-1)/idelay               ;ratio of one = no shift
krate   init    irate                           ;initialize to irate
        if      (p9 == 0) goto continue         ;if no lfo, skip next line
krate   oscili  irate,p9,1,.25                  ;lfo cosine
continue:
kntrl1  oscili  1,krate,2,0                     ;f02 has linear decay 1 - 0
kgate1  tablei  kntrl1,3,1,0,1                  ;window func = 1 - X^6
kgate1  =       kgate1*igain                    ;rescale
kntrl2  oscili  1,krate,2,.5                    ;offset 180 deg from kntrl1
kgate2  tablei  kntrl2,3,1,0,1                  ;window func = 1 - X^6
kgate2  =       kgate2*igain                    ;rescale
avary1  interp  kntrl1
avary2  interp  kntrl2
asrce   soundin p6                              ;p6 is soundin.nnn
asrce   =       asrce*ilevel                    ;initial gain control
asum    init    0
ajunk   delayr  idelay                          ;first delay line
asig1   deltapi avary1*idelay                   ;variable length taps
asig2   deltapi avary2*idelay
        delayw  asrce+asum*p7                   ;p7 is feedback factor
asig1   =       asig1*kgate1
asig2   =       asig2*kgate2
asum    =       asig1+asig2
        out     asrce*p10+asum*(1-p10)          ;output mix of source, asum
        endin
</CsInstruments>
<CsScore>
f01     0       512     10      1                       ;sine wave
f02     0       513     7       1       513     0       ;linear decay
;Amp gating function:  f(x) = 1 - x^6, x -> -1, 1
f03     0       513     3       -1      1       1       0       0       0
        0       0       -1
; Soundin 40 is a single cello note - Pitch shift original sound up and down
;                       delay   nsemis  soundin feedfac gainfac lfohz dryfac lvl
i01     0       1       .1      0       40      0       1      0      0      0
i01     +      .5       .       2
i01     +       .       .       4
i01     +       .       .       5
i01     +       .       .       7
i01     +       .       .       9
i01     +       .       .       11
i01     +       1       .       12
i01     +       .5      .       -1
i01     +       .       .       -3
i01     +       .       .       -5
i01     +       .       .       -7
i01     +       .       .       -8
i01     +       .       .       -10
i01     +       1       .       -12
s
f0      .5
s
; Play pitch shifted chord
i01     0       2       .1      -12     40      0       .75
i01     .       .       .       -5
i01     .       .       .       4
i01     .       .       .       12
;
s
; Use feedback with longer delay to generate "harmonizer" effect
;                       delay   nsemis  soundin feedfac gainfac lfohz dryfac lvl
i01     0       3       .33     2       40      .99     .9      0     0      0
i01     +       .       .       5       40      .99     .9
i01     +       .       .       7       40      .99     .9
i01     +       4       .       -12     40      .99     .9
s
f0      1
s
; Create chorus effect by using small pitch shift with lfo plus big feedback
;                       delay   nsemis  soundin feedfac gainfac lfohz dryfac lvl
i01     0       4       .1      .05     40      1.35    1       2     .5
i01     +       .       .       .1
i01     +       .       .       .2
i01     +       .       .       .4
s
f0      .5
s
; Monster feedback!
;                       delay   nsemis  soundin feedfac gainfac lfohz dryfac lvl
i01     0       5       .05     .1      40      1.85    .96     1       .5
i01     +       5       .1      .05     .       .       .       2
i01     +      10       .25     .25     .       .       .       1.5
e

</CsScore>
</CsoundSynthesizer>
