; ARRANGEMENT ./test.orc
sr = 48000
kr = 48000
ksmps = 1
nchnls = 2



instr 1 ; i13chorus delay line


	   ;global variable inits

       ga1	init	  0
       ga3	init	  0
       ga5	init	  0
       ga6	init	  0
       ga8	init	  0
       ga11     init      0
       ga13	init	  0
       ga15	init	  0
       ga16	init	  0
	    ;signal input
       a3    =	ga1+ga3+ga5+ga6+ga8+ga11+ga15+ga16
	   if p16!=0 goto j00
       ga1   =	       0		       ;reset global to 0.
       ga3   =	       0		       ;reset global to 0.
       ga5   =	       0		       ;reset global to 0.
       ga6   =	       0		       ;reset global to 0.
       ga8   =	       0		       ;reset global to 0.
       ga11  =	       0		       ;reset global to 0.
       ga15  =	       0		       ;reset global to 0.
       ga16  =	       0		       ;reset global to 0.
                            

j00:   al1	init	  0

       i1    =	    (p7>0?  p7 : abs(p7)/((p6-p5)*2))	  ;cps or msec/sec
	   ;init msecs

       p5    =	    p5*.001
       p6    =	    p6*.001


       k1    oscili  p6-p5,i1,int(frac(p8)*100+.5),int(p8)
       k1    =	     p5+k1
   ;for feedback
       kk3   init    (p9=0?  .001  :  p9)    ;min rvrb
	   if p12=0 goto j10
	  kk3	oscil  p10-p9,p11,int(frac(p12)*100+.5),int(p12)
	  kk3	=      p9+kk3	  ;variable rvt
j10:   p20   =	 (p20=0? 1 : -1)	      ;p20=pos rvtfac if 0, neg if ne 0
       k2    =	 p20*exp(-6.9075*k1/kk3)      ;rvt fac = e**lpt/rvt
       al2   init   1			      ;p21=rate/dur for oscil al2
	  if p22=0 goto j20		      ;p22=nf for al2
       al2   oscil   1,p21/p3,p22,0		 ;oscil tra +&-rvtfac
j20:   a2    =	     al2*k2*al1 	      ;feedback

;	     pipdef   (p6>p5? p6 : p5)		;discontinued:
;	     pipadv   a3*p4+a2,k1		; code no longer
;      a1    piprd				; supported

	a1   delayr	(p6>p5? p6 : p5)	;substituted:
	adel upsamp	k1			; but not yet doing
	a1   deltapi	adel			; the same
	     delayw	a3*p4+a2

       al1   linen    a1,p13,p3,p14
       a1    =	      al1
	   if p24=0   goto j30
       a1    oscil    a1,p23/p3,int(frac(p24)*100+.5),int(p24)	;zvamp

j30:	 ;stereo control

    kk5   init	  p17		   ;left prop
    kk6   init	  1-p17 	   ;right prop
       if p19=0   goto	j60
    it1   =	  (p17=1?  1 : int(p17)*.1)
    i31   =	  frac(p17)	   ;min
    i32   =	  it1-i31	   ;dif
    k4	  oscil   i32,p18/p3,frac(p19)*100+.5,int(p19)	;wrong phase
    kk5   =       i31+k4
    kk6   =	  1-kk5
     j60:    outs      a1*kk5,a1*kk6
	     endin

