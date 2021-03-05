<CsoundSynthesizer>
<CsOptions>
-o dac -m35 -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 1
nchnls = 2

instr 1  
  kamp = p4
  kcps = p5
  ifn = 1
  a1 poscil kamp, kcps, ifn
  adeclick linseg 0, 0.003, 1, p3 - .01, 1, .007, 0
  a1 = a1 * adeclick
  chnmix a1, "buss"
endin

instr 10
  kaz	linseg 720, p3, 0
  kel	linseg -10, p3, 0
  abuss chnget "buss"
  aleft, aright hrtfmove2 abuss, kaz, kel, "hrtf-44100-left.dat","hrtf-44100-right.dat"
  outs	aleft, aright
  chnclear "buss"
endin

</CsInstruments>
<CsScore>

f1 	0 	65536 	10 	1 	

m v1

i1 	0.0 	0.2 	15000 	440.0 	
i1 	0.2 	0.2 	15000 	466.16 	
i1 	0.4 	0.2 	15000 	493.88 	
i1 	0.6 	0.2 	15000 	523.25 	
i1 	0.8 	0.2 	15000 	587.33 	
i1 	1.0 	1.5 	15000 	659.25 	
i1 	2.5 	1.5 	15000 	698.46 	
i1 	4.0 	1.5 	15000 	783.99 	
i1 	5.5 	1.5 	15000 	880.0 	
i1 	7.0 	1.5 	15000 	830.6 	
i1 	8.5 	1.5 	15000 	783.99 	
i1.1 	10.0 	1.5 	14500 	987.77 	
i1.2 	10.0 	1.5 	500 	783.99 	
i1.1 	11.5 	4.0 	7500 	659.25 	
i1.2 	11.5 	4.0 	7500 	783.99 	

i10 	0 	15.5 	

s
n v1

e
</CsScore>
</CsoundSynthesizer>