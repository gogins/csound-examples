<CsoundSynthesizer>

<CsLicence>

=====================================
   *** "Close Encounters" ***
Original public-domain MIDI borrowed
from the MIDIcsv Distribution
=====================================

</CsLicence>

<CsOptions>
# These options select audio output
# and suppress displays
-odac -d -m155
</CsOptions>

<CsInstruments>

; Initialize the global variables.
sr = 48000      ; Sample Rate
ksmps = 100      ; Samples/Buffer (sr/kr) -- optional
nchnls = 2      ; Mono output


; Sine table here rather than in Score
giSine0  ftgen 1, 0, 65536, 10, 1


; Instrument #1 - a basic oscillator.
instr 1

  ; convert pitch input (score param 5) to frequency
  icps = cpspch(p5)
  
  ; create an envelope from amplitude param 4  
  aamp linen p4, 0.01, p3 - (.01 +.05), 0.05

  ; run the oscillator
  a1 poscil aamp, icps, giSine0
  ; and send the wave out
  outs a1, a1

endin

</CsInstruments>

<CsScore>
; The notes to be played:
;Instr Start    Duration Amplitude  Pitch (octave.pitchclass)
 i1    0.000    1.000    8100.00    9.07
 i1    1.000    1.000    8100.00    9.09
 i1    2.000    1.000    8100.00    9.05
 i1    3.000    1.000    8100.00    8.05
 i1    4.000    1.000    8100.00    9.00
</CsScore>

</CsoundSynthesizer>
