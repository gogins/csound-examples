sr = 44100
kr = 4410
ksmps = 10
nchnls = 1

instr 1                                   ; pldmidi.orc

iamp     ampmidi  8000, 3                 ; convert velocity to amp, remap to table
irand    ampmidi  .5, 3                   ; fluctuation
ifrnd    cpsmidi                          ; convert midi note number to Hz
ifrnd1   = ifrnd + irand
ifrnd2   =  ifrnd1 * 2           
ifrnd3   =  ifrnd1 * 3           

icps = 261.6                              ; constant pitch
iband =  ifrnd1/10
kamp linenr iamp, .001, .5, .001          ; gate

asig  pluck kamp, icps, icps, 2, 3,.5     ; method 3, drum

aflt1 reson asig, ifrnd2, iband
aflt2 reson aflt1, ifrnd2, iband * 1.2
aflt3 reson aflt2, ifrnd3, iband * 2.1
abal  balance aflt3, asig
out abal

endin
