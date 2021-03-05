sr = 44100
kr        =    4410
ksmps     =    10
nchnls    =    1

; BAND
          
          instr 1
          bassguitarpastorioso:

kamp      line      8000,p3,5500
a1        oscil     kamp,cpspch(p4),1
a2        buzz      kamp,cpspch(p4),6,1
a3        pluck     kamp,cpspch(p4),440,0,1
          out       a1+a2+a3
          endin

          
          instr 2
flutenpoopensker:

a1        oscil     10000,cpspch(p4),2
          out       a1
          endin


          instr 3
glockenschpeeel1:

kamp      line      3000,p3,500
a1        oscil     kamp,cpspch(p4),1
a2        buzz      kamp*.81,cpspch(p4),8,1
a3        pluck     kamp,cpspch(p4),880,0,3,.5
          out       a1+a2+a3
          endin


          instr 4
glockenklinkinzerklanker2:

kamp      line      4000,p3,500
a1        oscil     kamp,cpspch(p4),3
a2        buzz      kamp,cpspch(p4),6,3
a3        pluck     kamp,cpspch(p4),660,0,1
          out       a1+a2+a3
          endin

          instr 5
snareonabadhairday:
itablesize =        6
kindx     phasor    p5*p6
kpch      table     kindx*itablesize,4
kamp      line      10000,p3,1100
a1        pluck     kamp*1.5,cpspch(kpch),p4,0,1
          out       a1
          endin

