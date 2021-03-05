<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo anmod.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
;----------------------------------------------
; Real Time Midi Controlled Csound
; by Hans Mikelson  March 1999
; Tested with Maldonado's Csound on a 300 MHz Pentium
; I use the following one line batch file csm.bat:
; csound -+K -+q -b512 -+O %1.orc %1.sco
; Called as follows for anmod.orc & anmod.sco:
; csm anmod
;----------------------------------------------

sr=44100
kr=2205
ksmps=20
nchnls=2

;-----------------------------------------------------------
; Analog modelling
;-----------------------------------------------------------
       instr 1

iwave  =        1                         ; Sine
iamp   veloc                              ; Velocity
iamp   =        iamp*300+10000            ; Convert to Amp
ifqc   cpsmidi
ifqcl  =        ifqc*.998
ifqcr  =        ifqc*1.002
;               Amp   Rise, Dec, AtDec
kamp   linenr   iamp, .05,  .05, .05      ; Declick envelope
kfce   expseg   .2, .1, 1, .2, .8, .1, .8 
kfcs   midictrl 50, 20
krzs   midictrl 56, 20
krezm  =        krzs*.01
krezr  =        krzs
kfco   port     kfce*kfcs*sqrt(ifqc),.01

;             Amp Fqc     Wave PW Sine Delay
asigl  vco     1,  ifqcl, 1,   1, 1,   1/ifqc ; Oscillator
aoutl  moogvcf asigl, kfco, krezm             ; Filter
asigr  vco     1,  ifqcr, 1,   1, 1,   1/ifqc ; Oscillator
aoutr  moogvcf asigr, kfco, krezm             ; Filter
       outs    aoutl*kamp, aoutr*kamp         ; Output

      endin


</CsInstruments>
<CsScore>
;----------------------------------------------
; Real Time Midi Controlled Csound
; Tested with Maldonado's Csound
;----------------------------------------------
f0  60                 ; Runs for 60 seconds
f1  0 65536 10 1       ; Sine


</CsScore>
</CsoundSynthesizer>
