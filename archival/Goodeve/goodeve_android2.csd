<CsoundSynthesizer>
<CsLicense>
  tst8ng  this
</CsLicense>
<CsOptions>
    -o dac -m0
</CsOptions>
<CsInstruments>
    sr = 44100
        ksmps = 4410
        ksmps = 10
        nchnls = 1
        0dbfs = 1.0

    instr 1
;       asig oscil 1.0, 440
        asig   soundin "fox.wav"
        out asig
        endin

</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>
