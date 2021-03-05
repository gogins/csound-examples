
;---------------------------------------------

; TRAPPED IN CONVERT - Richard Boulanger

; written July 1979 in music11
; M.I.T. Experimental Music Studio

; revised June 1986 in Csound
; M.I.T. Media Lab

; revised  May 1989 in PCsound
; for the M.T.U. Digisound 16

;----------------------------------

   sr=16000
   kr=1000
   ksmps=16
   nchnls=2

   ga1 init 0
   ga2 init 0

instr 5 				 ;p4=cps of pan
   ga1 init 0
   k1 oscili .5,p4,1
   k2 = .5+k1
   k3 = 1-k2
   a1 reverb ga1,2.1
   outs k2*a1,(k3*a1)*(-1)
   ga1=0
endin

instr 7 				 ;p9=amp
   k1 phasor p4 			 ;p8=rvb attn
   k2 tablei k1*8,19			 ;p7=bndwth
   a1 rand  10000			 ;p6=swp frq:end val
   k3 expon p5,p3,p6			 ;p5=swp frq:strt val
;  display k3,5,1,1
   a2 reson a1,k3*k2,k3/p7,1
  display a2,5,1,1
;   a2 reson a1,p5*k2,p5/p7,1
;   k5 linen p9,.01,p3,.05
;   a3=k5*a2
;   ga1=ga1+(p8*a2)
   outs a2,a2
;   outs a3,a3
endin

