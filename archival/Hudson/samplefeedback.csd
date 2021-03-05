<CsoundSynthesizer>
<CsOptions>
DirectCsound -RWdo test.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr      =       44100
kr      =       4410
ksmps   =       10
nchnls 	=		2

instr 1 ; feedback fm
	iamp=	p4      			      ;max amplitude
	ifc=    p5      			      ;center frq
	indx=   p6      			      ;max. modulation index
	itime= (p3-(p3*p8))/3

asmpl	soundin	p7,2				  ;calls Sample
afrq    init    ifc     			  ;init. oscil frq to center frq
kOsgt   expseg  .001,p3*p8,.001,itime,p9,itime,p10,itime,p11;line
a1      oscil   kOsgt,afrq+asmpl,1    ;oscillator, normalized to 1
kndx    line    0,p3,indx    	   	  ;vary modulation index
afm  =  afrq * a1       			  ;calculate modulation frq
adev =  afm * kndx      			  ;calculate deviation frq
afrq =  ifc + adev      			  ;calculate oscil frq
kamp    linseg  0,.1,iamp,p3-.2,iamp,.1,0
aout1=   a1 * kamp
aout2=	aout1+asmpl
outs     aout2,aout2

endin
</CsInstruments>
<CsScore>

f1      0       8192    10      1

;instr  start	dur		amp		center	mod		samplename		% of wait	Points on expseg
i1      0       50     	10000    880    .9		"heart.aiff"	  .617		.25 .5 1




</CsScore>
</CsoundSynthesizer>
