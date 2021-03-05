<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo fm105.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 44100
kr        =         44100
ksmps     =         1
nchnls    =         1

; FM INSTRUMENT 5
; ONE CARRIER AND A FOUR MODULATOR STACK
; FIVE INDEPENDENT ENVELOPE GENERATORS
; FOUR INDEPENDENT MODULATION INDEX

          instr 5

idur      =         p3

icaramp   =         ampdb(p4) 
icarfreq  =         p5
 
imod1freq =         p6
imod2freq =         p7
imod3freq =         p8
imod4freq =         p9

index1    =         p10
index2    =         p11
index3    =         p12
index4    =         p13

imod1index =        imod1freq * index1
imod2index =        imod2freq * index2
imod3index =        imod3freq * index3
imod4index =        imod4freq * index4

icarrise  =         p14
icardec   =         p15

imod1rise =         p16
imod1dec  =         p17
imod2rise =         p18
imod2dec  =         p19
imod3rise =         p20
imod3dec  =         p21
imod4rise =         p22
imod4dec  =         p23

 

kmod4amp  linen     imod4index, imod4rise, idur,  imod4dec 
amod4sig  oscil     kmod4amp, imod4freq, 1

kmod3amp  linen     imod3index, imod3rise, idur, imod3dec 
amod3sig  oscil     kmod3amp, imod3freq + amod4sig, 1
 
kmod2amp  linen     imod2index, imod2rise, idur, imod2dec 
amod2sig  oscil     kmod2amp, imod2freq + amod3sig, 1
                
kmod1amp  linen     imod1index, imod1rise, idur, imod1dec 
amod1sig  oscil     kmod1amp, imod1freq + amod2sig, 1

kcaramp   linen     icaramp, icarrise, idur, icardec 
acarsig   oscil     kcaramp, icarfreq + amod1sig, 1

          out       acarsig

dispfft   acarsig,  .25, 1024

          endin
</CsInstruments>
<CsScore>
; One Carrier and a Four Modulator Stack
; Five Independent Envelope Generators
; Four Independent Modulation Index

;  idur = p3

;  icaramp =  ampdb(p4) 
;    icarfreq = p5
 
;  imod1freq = p6
;  imod2freq = p7
;  imod3freq = p8
;  imod4freq = p9

;  index1 = p10
;  index2 = p11
;  index3 = p12
;  index4 = p13

;  icarrise = p14
;  icardec =  p15

;  imod1rise =  p16
;  imod1dec =   p17
;  imod2rise =  p18
;  imod2dec =   p19
;  imod3rise =  p20
;  imod3dec =   p21
;  imod4rise =  p22
;  imod4dec =   p23

f1 0  4096  10  1
   
i5 0  .5  80 100 102  97 1327 1486  4  1 4 6  .001  .002  .25  .05  .01 .09 .024 .06 .02 .1 
i5 +  .     80     >     >     >       >        >   >  > > >        >      >       >    >  .01 .09 .024 .06 .02 .1 
i5 +  .    80   50  51   47 1876   196  8 4 1 1       .1    2        5   3  .01 .09 .024 .06 .02 .1 
s
i5 0  10  80 100 100 200 300 400 4 3 2 1  .1  2   3  5  8 10 12 6 14 6 
e



</CsScore>
</CsoundSynthesizer>
