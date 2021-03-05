<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo circle.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 48000
kr        =         48000
ksmps     =         1
nchnls    =         2


          instr     1
     
; CIRCULAR ALGORHYTHM
     
a1   soundin p4,p5       ; THE SIGNAL SOURCE CAN BE REPLACED WITH ANYTHING...:]
k1   oscili p6,p7,1
k2   oscili p6,p7,2
a2   reverb a1,.5   ; THIS LINE CAN BE REPLACE WITH ANY OF THE NEWER REVERB OPCODES...
a2 = a2 * .3   ; YOU CAN ALSO CHOOSE TO USE THE BALANCE OPCODE HERE
k3   oscili p8,p9,3
     a3 = ((a1*k1)+(a2*k3))*k2
     a4 = ((a1*k1)+(a2*k3))*(1-k2)

; ENVELOPE SELECTION TO BE APPLIED TO THE SOURCE  
    if p10 = 1 goto noclick
     if p10 = 2     goto taper
     if p10 = 3     goto hairpin
     if p10 = 4     goto cresc
     if p10 = 5     goto dim

     noclick:
          kenv linseg 0,.01,p11,p3-.02,p11,.01,0  ;noclick
          a3 = a3*kenv
          a4 = a4*kenv
          goto out
     taper:
          kenv linseg 0,.01,p11,(p3*.75)-.01,p11,p3*.25,0   ;taper
          a3 = a3*kenv
          a4 = a4*kenv
          goto out
     hairpin:
          kenv linseg 0,p3*.5,p11,p3*.5,0    ;hairpin
          a3 = a3*kenv
          a4 = a4*kenv
          goto out
     cresc:
          kenv linseg 0,p3-.01,p11,.01,0     ;cresc
          a3 = a3*kenv
          a4 = a4*kenv
          goto out
     dim:
          kenv linseg 0,.01,p11,p3-.01,0     ;dim
          a3 = a3*kenv
          a4 = a4*kenv
     out:
     outs1 a3  
     outs2 a4
endin
</CsInstruments>
<CsScore>
;FTABLES TO CREATE CIRCULAR DATA FOR ORCHESTRA PROCESSING 
;--------------------------------------------------------------------- 
f1   0    8192 7    1    2048 1 2048 1 2048 0 2048 1
f2   0    8192 7    0    2048 .5 2048 1 2048 .5 2048 0
f3   0    8192 7    0    2048 0 2048 0 2048 1 2048 0
;-------------------------------------------------------------------- 
;    p2   p3   p4   p5   p6   p7   p8   p9   p10  p11
;    SNDIN# SKIP AMPREV FREQ  AMPPAN FREQ.ENV.VOL.REVPAN.AMPPAN
;-------------------------------------------------------------------- 
i1   0    34.10     10   0    1    .1   1    .1   0    1


; kamp1 controls overall amplitude of note
kamp1	linseg	.0001, iattack1, iamp1, (idur1 - iattack1), .0001

; kamp2 controls amplitude of feedback




</CsScore>
</CsoundSynthesizer>
