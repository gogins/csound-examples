sr=20000
kr=1000
ksmps=20
nchnls=1

;		      Risset's Ring-modulation Instrument                 ;


instr 5
   a1 expseg .001,p7,1,p3-p7,.001
   a1 oscili a1,p4,1
   a2 oscili p5,p6,2
   out a1*a2
endin

;		  Risset's Endless Glissando Instrument                   ;


instr	9
   ifreq   =	   p5

if (ifreq >= 20) igoto continue

   ifreq   =	   cpspch(p5)	      ;Note: p5 must be in oct.pch

continue:
				      ;All "kamp" tables use f2
   kphase  phasor  1/p6 	      ;a floating point bell shaped
   kenvlp  linen   p4,1,p3,1	      ;function specified by Risset in Dodge:
				      ;exp(-4.8283*(1-cos(2*pi*(x-255.5)/511)))
   kamp1   table   kphase,2,1,0,1
   kcps1   tablei  kphase,3,1,0,1
   asig1   oscili  kamp1,kcps1*ifreq,1

   kamp2   table   kphase+.1,2,1,0,1
   kcps2   tablei  kphase+.1,3,1,0,1
   asig2   oscili  kamp2,kcps2*ifreq,1

   kamp3   table   kphase+.2,2,1,0,1
   kcps3   tablei  kphase+.2,3,1,0,1
   asig3   oscili  kamp3,kcps3*ifreq,1

   kamp4   table   kphase+.3,2,1,0,1
   kcps4   tablei  kphase+.3,3,1,0,1
   asig4   oscili  kamp4,kcps4*ifreq,1

   kamp5   table   kphase+.4,2,1,0,1
   kcps5   tablei  kphase+.4,3,1,0,1
   asig5   oscili  kamp5,kcps5*ifreq,1

   kamp6   table   kphase+.5,2,1,0,1
   kcps6   tablei  kphase+.5,3,1,0,1
   asig6   oscili  kamp6,kcps6*ifreq,1

   kamp7   table   kphase+.6,2,1,0,1
   kcps7   tablei  kphase+.6,3,1,0,1
   asig7   oscili  kamp7,kcps7*ifreq,1

   kamp8   table   kphase+.7,2,1,0,1
   kcps8   tablei  kphase+.7,3,1,0,1
   asig8   oscili  kamp8,kcps8*ifreq,1

   kamp9   table   kphase+.8,2,1,0,1
   kcps9   tablei  kphase+.8,3,1,0,1
   asig9   oscili  kamp9,kcps9*ifreq,1

   kamp10  table   kphase+.9,2,1,0,1
   kcps10  tablei  kphase+.9,3,1,0,1
   asig10  oscili  kamp10,kcps10*ifreq,1

   asum  =  asig1+asig2+asig3+asig4+asig5+asig6+asig7+asig8+asig9+asig10
        
   out	   asum*kenvlp
endin
