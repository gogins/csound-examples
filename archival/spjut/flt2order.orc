  sr        =  44100
  kr        =  4410
  ksmps     =  10
  nchnls    =  1
          
; two instruments to do second order digital filtering
; score data:  p5 = center freq,   p6 = bandwidth  (cps)

instr   1
  ayt1      init      0
  ayt2      init      0

  
  
  i3        =  exp(-6.283185*p6/10000)
  i2        =  4*i3*cos(6.283185*p5/10000)/(1+i3)
  i1        =  (1-i3)*sqrt(1-i2*i2/(4*i3))        ; FOR SCALE 1

; i4      =         (i3+1)                   
; i1      =         sqrt((1-i3)/i4*(i4*i4-i2*i2)  ; FOR SCALE 2

  asig      rand      p4

  afilt     =  i1*asig + i2*ayt1 - i3*ayt2
  ayt2      =  ayt1
  ayt1      =  afilt

  aout      linen     afilt, .01, p3, .01
            out       aout*20000
endin

instr   2
  asig      rand      p4
  afilt     reson     asig, p5, p6, 1
  aout      linen     afilt, .01, p3, .01
            out       aout*20000
endin
