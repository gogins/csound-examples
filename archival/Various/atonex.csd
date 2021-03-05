<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo atonex.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr	= 44100
kr        =         44100
ksmps     =         1
nchnls    =         1

          instr     1


a1        oscili    30000,p4,1
kenv      expseg    p4,p3/2,3000,p3/2,p4
a1        atonex    a1,kenv,8
          out       a1
          endin
</CsInstruments>
<CsScore>
i1 0 5 100 
i1 5 5 80 
i1 10 5 440
</CsScore>
</CsoundSynthesizer>
