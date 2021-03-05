<CsoundSynthesizer>
<CsOptions>
csound -RWdo bassdrum.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 44100
kr        =    44100
ksmps     =    1
nchnls    =    1


          ;BASS DRUM

          instr 1

; - SOME VALUES TO START WITH

imixt     init      0.005
igain     init      p4

; - LOW OSC ADSR

ilat1     init      p5
ilat2     init      p6
ilat3     init      p7
ilav1     init      p8

; - LOW OSC FREQ

ilfv1     init      p9
ilft1     init      p10
ilfv2     init      p11
ilfv3     init      p12

; - NOIZE OSC ADSR

inat1     init      p13
inav1     init      p14
inat2     init      p15

; - NOIZ OSC FREQ

infv1     init      16


; - LOW OSC

alamp     linseg    0,ilat1,1,ilat2,1,ilat3,ilav1,p3-ilat1-ilat2-ilat3,0
alfrq     expseg    ilfv1,ilft1,ilfv2,p3-ilft1,ilfv3
alow      oscil     alamp*igain,alfrq,1

; - NOIZE OSC

anamp     linseg    0,inat1,inav1,inat2,0,p3,0
anfrq     =         infv1

anrnd     rand      anamp
anoiz     oscil     anrnd*igain,anfrq,1

; - GENERATE OUTPUT

          out       alow+anoiz
          endin


</CsInstruments>
<CsScore>
f 1 0 4096 10 1 0 ; basic wave table ( sine wave )

; PARAMETERS

; inum  start duration  gain ilat1 ilat2 ilat3 ilav1 ilfv1 ilft1 ilfv2 ilfv3 inat1 inav1 inat2 infv1

 i1 	  0     0.15   20000 0.005 0.01  0.01  0.4   200   0.07   30   25 0.005  0.8  0.005  100
e

</CsScore>
</CsoundSynthesizer>
