<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr		=		44100
kr		=		4410
ksmps	=		10
nchnls	=		2

		instr 1
iamp		=		ampdb(p4)/2				
inote	=		cpspch(p5)
ibal		=		p8 
if1		=		0
if2		=		0	
ind1		=		35
ind2		=		30
k1		linseg	0,p3/2,iamp,p3/2, 0
a3		pluck	k1,inote*.997,ind1,if1,1		
a2		pluck	k1,inote*1.003,ind1,if1,1			
; a1		pluck	k1,inote,ind1,if1,1			
aplk1	=		a2+a3

k2 		linseg	0,p3*.66,iamp*1.2,p3/3,0
a6		pluck	k2,inote*.995,ind2,if2,1		
a5		pluck	k2,inote*1.005,ind2,if2,1			
; a4		pluck	k2,inote,ind2,if2,1			
aplk2	=		a5+a6
apluck	=		aplk1+aplk2
		outs		apluck*ibal,apluck*(1-ibal)
		endin


</CsInstruments>
<CsScore>
                         
f1 0 65536 10 1               		; sine
f2 0 65536 19 .5 1 270 1            ; sigmoid rise

  
;  st  dur   p4    p5    p6   p7  p8    p9   p10  p11  p12  p13

i1  0   15   75   6.02    8   5   .4
i.  .1  .    .    6.04    .   .   .5
i.  .2  .    .    6.07    .   .   .6
i. 13   16   80   6.02    7   6   .3
i. 13.1  .    .   6.04    .   .   .5
i. 13.2  .    .   6.07    .   .   .7
i. 27   20   82   6.02    6   12  .2   
i. 27.1  .    .   6.04    .   .   .5   
i. 27.2  .    .   6.09    .   .   .8   

e  
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView nobackground {0, 0, 0}
</MacGUI>
