<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo haunt.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 44100
kr        =         44100
ksmps     =         1
nchnls    =         2

          instr     1

i1        =         cpspch(p4)
i2        =         cpspch(p5)
i3        =         cpspch(p6)
kvib1     oscil     2,i1/50,1
kvib2     oscil     3,i1/30,4
kvlow     oscil     2,cpspch(p4-1)/15,5
khp1      =         cpspch(p4)/2
khp2      =         cpspch(p4)*0.01
kamp      envlpx    5000,.01,p3,.008,2,2,.01
klamp     linenr    kamp,p3,.005,.05
krimp     linenr    5000,.0005,p3,.05
klip1     line      5000,p3,7000
klip2     line      7000,p3,0
kiss      line      0,p3,5000
kbend     expseg    i1,p3/4,i1*2,p3/4,i1,p3/4,i1*2,p3/4,i1 
kp        phasor    1
ktab      table     kp*6,8
a1        oscil     klamp,(p3<1.99?i1:kbend),1
a2        oscil     klamp*0.67,(p3>1.99?i1*1.875:i1*1.67)+kvib1,3 
a3        oscil     klamp*0.33,(i1*1.5)+kvib2,4
a4        oscil     krimp,(p3<1.99?i1:kbend),1
a5        oscil     krimp*0.67,(p3>1.99?i1*1.875:i1*1.67)+kvib1,3 
a6        oscil     krimp*0.33,(i1*1.5)+kvib2,4
a7        pluck     klip1,cpspch(p4-2),i1,5,4,1,2
aa        pluck     klip2,cpspch(p4-1)*0.997+kvlow,i1,6,4,1,2 
ab        pluck     klip2,i2,i2,5,1
ac        pluck     klip2,i3,i3,6,1
az1       buzz      kiss,cpspch(ktab),6,7
az2       buzz      kiss,cpspch(ktab+1),6,7
at        pluck     klip2,50,20,5,4,.5,2
all       =         a1+a2+a3+aa+ab+az1+at
arr       =         a4+a5+a6+a7+ac+az2+at
     
          outs      all,arr
          endin
</CsInstruments>
<CsScore>

f1 0 512 9 1 5 290 2 3 28 3 2 126 4 3 89 5 2 207 
f2 0 512 -2 1 2 3 4 5 6 7 8 9
f3 0 512 10 5 4 9 4 8 3 7 2 9 1
f4 0 512 10 3 1 5 2 6 3 5
f5 0 4096 10 5 1 9 3 2 9
f6 0 4096 10 5 2 7 1 3 6
f7 0 8192 7 1 2023 2 2023 3 2023 4 2023
f8 0 16 -2 10.08 9.08 10.07 9.11 10.08 10.03 

t 0 60 1 50 3 40 4 57

i1 0 1 6.08 5.08 5.08
i1 0 .5 5.08 4.08 4.08
i1 1 2 7.07 5.07 4.07
i1 3 .5 6.11 5.03 4.03
i1 3.5 .72 6.08 5.03 4.03
i1 4 3 7.08 5.03 4.03

</CsScore>
</CsoundSynthesizer>
