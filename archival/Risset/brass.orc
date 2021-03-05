; Risset Instrument #200.orc 
; Brass-like Sounds through independent control of harmonics
sr          =           44100
kr          =           4410
ksmps       =           10
nchnls      =           1

            instr       1               ; random frequency modulation
i1          =           .1*p4*p5
gk1         randi       i1, p6
            endin       

            instr       2               ; instruments 2-6 = partials 1-5 with
i1          =           1/p3            ; different envelopes f2-f6
k1          oscil       p4, i1, 2
a1          oscili      k1, p5+gk1, 1
            out         a1*8

gk1         =           0
gk1         init        0
            endin       

            instr       3
i1          =           1/p3
k1          oscil       p4, i1, 3
a1          oscili      k1, p5+gk1, 1
            out         a1*8

gk1         =           0
gk1         init        0
            endin       

            instr       4
i1          =           1/p3
k1          oscil       p4, i1, 4
a1          oscili      k1, p5+gk1, 1
            out         a1*8

gk1         =           0
gk1         init        0
            endin       

            instr       5
i1          =           1/p3
k1          oscil       p4, i1, 5
a1          oscili      k1, p5+gk1, 1
            out         a1*8

gk1         =           0
gk1         init        0
            endin       

            instr       6
i1          =           1/p3
k1          oscil       p4, i1, 6
a1          oscili      k1, p5+gk1, 1
            out         a1*8

gk1         =           0
gk1         init        0
            endin       

            instr       7
i1          =           p6/12500
i2          =           p7/12500

a1          linen       p4, i1, p3, i2
a2          oscili      a1, p5+gk1, 1
            out         a2*8

gk1         =           0
gk1         init        0
            endin       
