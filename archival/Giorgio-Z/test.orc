
sr=44100
ksmps=100
nchnls=2

instr 1
k1 randomi  20,400,1
a1 oscil 10000,k1,1
a2 oscil a1,100,1
outs  a2,a2

endin
 