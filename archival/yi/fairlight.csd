<CsoundSynthesizer>
<CsOptions>
</CsOptions>
; ==============================================
<CsInstruments>

sr	=	44100
ksmps	=	1
nchnls	=	2
0dbfs	=	1

instr 1	

;; table to play
itab = p4

;; desired pitch
ipch = cps2pch(p5, 12)

;; base pitch: using A4 instead of A3 as samples are recorded
;; one octave higher than base  
ifreq = ipch / cps2pch(8.10, 12) 

;; Using loscil3 to playback the files
asig loscil3 0.25, ifreq, p4, 1

asig *= xadsr(0.02, 0.1, 1, 0.01)

  outc asig, asig 

endin

instr Mix



endin

</CsInstruments>
; ==============================================
<CsScore>

f1 0 0 1 "FAIRLIGHT CMI IIX LIBRARY/CHORAL/ARR1.WAV" 0 0 0
f2 0 0 1 "FAIRLIGHT CMI IIX LIBRARY/STRINGS4/ORCH5.WAV" 0 0 0

t 0 136


i1 0 0.5 1 8.01
i1 1 0.5 1 8.01
i1 2 0.5 1 8.01
i1 3 0.5 1 8.01
i1 4 0.5 1 8.08
i1 5 0.5 1 8.08
i1 6 0.5 1 8.08
i1 7 0.5 1 8.06
i1 8 0.5 1 8.08
i1 9 0.5 1 8.08
i1 10 0.5 1 8.08
i1 11 0.5 1 8.08
i1 12 0.5 1 8.08
i1 13 0.5 1 8.08
i1 14 0.5 1 8.08
i1 15 0.5 1 8.08

s 16

t 0 136

i1 0 0.5 1 8.01
i1 1 0.5 1 8.01
i1 2 0.5 1 8.01
i1 3 0.5 1 8.01
i1 4 0.5 1 8.08
i1 5 0.5 1 8.08
i1 6 0.5 1 8.08
i1 7 0.5 1 8.06
i1 8 0.5 1 8.08
i1 9 0.5 1 8.08
i1 10 0.5 1 8.08
i1 11 0.5 1 8.08
i1 12 0.5 1 8.08
i1 13 0.5 1 8.08
i1 14 0.5 1 8.08
i1 15 0.5 1 8.08

i1 0 3 2 8.01 
i1 4 3 2 8.08
i1 7 3 2 8.06
i1 8 3 2 8.08


</CsScore>
</CsoundSynthesizer>

