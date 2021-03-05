<CsoundSynthesizer>
<CsOptions>
directcsound  -RWm7o ./block.wav ./temp.orc ./temp.sco
</CsOptions>
<CsInstruments>
;-------------------------------------------------
;Centre for Music Technology - Glasgow University
;Software Synthesis and Composition Systems
;Tutor: Dr Miranda
;Student Name: Neal Wade
;Instrument: block.orc
;-------------------------------------------------
        sr=44100
        kr=44100
        ksmps=1
        nchnls=1
garev   init 0

        instr 1
kenv    linseg 0,0.01,1,p3-0.02,1,0.01,0
krat1   oscili 300,50,1
krat2   oscili 5,2,1
krat3   oscili 1,15+krat2,1
k1      oscili 300,krat1*krat3,1
a1      oscili p4,p5+k1,1
out     a1*kenv
        endin

;==============

        instr 2
kenv    linseg 0,0.01,1,p3-0.02,1,0.01,0
krat1   oscili 300,50,1
krat2   oscili 5,2,1
krat3   oscili 1,15+krat2,1
k1      oscili 300,krat1*krat3,1
a1      oscili p4,p5+k1,1
a2      =      a1*kenv
        out    a2
garev   =      a2
endin
;===============

        instr  3 ; reverb
a1      comb   garev,p4,p5
        out    a1/2
garev   =      0
        endin
</CsInstruments>
<CsScore>
;-------------------------------------------------
;Centre for Music Technology - Glasgow University
;Software Synthesis and Composition Systems
;Tutor: Dr Miranda
;Student Name: Neal Wade
;Score for: block.orc
;-------------------------------------------------
f1 0  4096  10  1
;
;pfields:
;p4 = amplitude
;p5 = frequency
;
i1  0    6    10000  1200
i2  6.5  0.3  10000  1200
;
;pfields:
;p4 = reverb time
;p5 = echo density
;
i3  6.5  5  4  0.7
e

</CsScore>
</CsoundSynthesizer>
