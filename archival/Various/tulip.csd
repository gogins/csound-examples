<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo tulip.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 44100
kr        =         44100
ksmps     =         1
nchnls    =         2
          
; TULIPS

          instr 1
itablesize =        12        
kindex    phasor    p5*p6                    ; VARIES PHASE OF LFO VS BEAT
                                             ; THUS CREATING MELODIC PATTERNS

plantatulip:
kenv      linen     1,.001,1/p5,1/p5*.9
ipitch    table     i(kindex)*itablesize,2
          timout    0,1/p5,pluckatulip
          reinit    plantatulip
               
pluckatulip:
a1        pluck    ampdb(p4)*kenv,cpspch(ipitch+p7),p8,0,1
          outs      a1,a1
          endin


</CsInstruments>
<CsScore>
f1 0 8192 10 1
f2 0 16 -2 6.0 6.06 6.03 6.07 7.01 5.05 6.04 7.02 6.02 7.08 6.05 6.10
;p4=amplitude
;p5=cycle speed
;p6=transposition
;p8=pluck buffer size

i1 0 20 70              4       1.1     0       400
i1 2 18 70              2       1.15    -1      800
i1 4 16 70              8       1.7     1       200
i1 8 16 70              12      1.3     2       400
i1 19 1 80              8       2.45    3.05    128
i1 20 4 70              2       2.65    1.05    128
i1 20 5 80              .25     1.45    3.05    128
i1 25 5 80              .25     1.25    3.05    128
i1 25 4 70              4       1.1     0       480
i1 25 1 80              8       2.45    3.05    128
i1 25 4 70              10      1.65    2.07    1000
i1 25 4 70              11      1.55    2.08    1000
i1 25 4 70              12      1.45    2.09    1000
i1 29 1 70              8       1.3     4       4000
i1 30 4 70              .25     51.3    3       200
e

</CsScore>
</CsoundSynthesizer>
