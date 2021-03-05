<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 100
nchnls = 1
0dbfs = 10

opcode Stop, a, ai
ain, iin xin
ke linseg 1,iin,1,0,0,p3-iin,0
ain *= ke
xout ain
endop


ga0 init 0

gkval0 init 0
gkval1 init 0
gkval2 init 0

gihandle0 init 0
gihandle1 init 0
gihandle2 init 0

FLpanel "Instrument 3", 600, 300, 80, 80, 1, 1
gkval0, gihandle0 FLslider "Waveset factor on output", 1, 800, 0, 1, -1, 420, 40, 80, 80
gkval1, gihandle1 FLslider "Pitchshift", 0, 8, 0, 1, -1, 420, 40, 80, 140
gkval2, gihandle2 FLslider "Delay tail length", 0, 8, 0, 1, -1, 420, 40, 80, 200
FLpanelEnd
FLrun 

instr 1
am init 0
ac init 0
an init 0
aphs linseg 0, p4, 1, p3-p4, 1
aphs mpulse .5481, 98
aphs Stop aphs, 1
al tablei aphs, -1, 1, 0, 1
am tablei aphs, -1, 1, 0, 1
ac tablei am+ac, -1, 1, 0, 1
printk .1, gkval1, 45
ga0 = ac
endin

instr 2
ke linseg 0,.005,1,p3-.02,1,.015,0
ares waveset ga0, table:k(phasor:k(1/p3),p4,1)
fsigA pvsanal ares, 2048, 256, 1024, 1
ares pvsadsyn fsigA, p6, p5
out ares*ke
endin


instr 3
ip4 = p4
ke linseg 0,.05,1,p3-.1,1,.05,0
ares waveset ga0, gkval0
ifftsize = 1024
fsigA pvsanal ares, ifftsize, ifftsize/4, ifftsize, 1
ares pvsadsyn fsigA, p6, p5*gkval1
ares dcblock ares
acmb init 0
acmb comb ares+tone(.25*acmb,1000), gkval2, p7
out acmb*ke
endin

</CsInstruments>
<CsScore>
t 0 145
f 32 0 16384 -7 1 16384 8
f 33 0 16384 -7 64 16384 64

i1 0 5 .0002
i3 0 .25 1 [.123] 48 .07

;i1 16 1638247 .0002
;i3 16 1638247 80 [.123] 32

i1 16 1200 .0002
i3 16 1200 80 1 64 [60/145]

e
</CsScore>
</CsoundSynthesizer>