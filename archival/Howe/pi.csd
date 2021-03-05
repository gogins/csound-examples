<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;pi orchestra:  sound based on pi
; adapted from Sqrt(2)
        sr = 44100
        kr = 4410
        ksmps = 10
        nchnls = 2
	giamp = 4000
	ginyq = sr/2
	gifnq = ginyq/1024
;
; instrs
;	1	fm
;	2	complex envelope
;	3	shift
;	4	individual attacks
;
        instr   1              ;pi fm instr
;p4 = pitch
;p7 = mod. indx
;p8 = spectral function
;icps    =       cpspch(p5)
ipi      =       3.141596       ;pi
ioct    =       int(p4)
ifr     =       (p4-int(p4))*100/12
;icps    =       ipi^(ioct+ifr)*.9986382
ipw	pow	ipi,ioct+ifr
icps	=	.9986382*ipw
ir      =       4/icps
id      =       ir
ist	=	p3-ir-id
indx	=	10-ioct/2
ia      table   icps/gifnq,3
k1      oscil1  0,1,p3,5
k2      linen   2*giamp*ia*k1,ir,p3,id
a1      foscil  k2,icps,1,ipi,k1*indx,1
;k2      expseg  .001,ir,1,ist,.1,id,.001
        outs    a1*p6,a1*(1-p6)
        endin
;
        instr   2               ;pi complex envelope
;individual partial generation
;9 partials in pi relationship (goes to 28.27)
;p4 = pitch, p5=0/1 (pi-1/pi), p6=loc (0/1), p7=amp factor
ipi      =       3.141596       ;pi
iamp	=	giamp*p7
ioct    =       int(p4)
ifr     =       (p4-int(p4))*100/12
;icps    =       ipi^(ioct+ifr)
icps	pow	ipi,ioct+ifr
	if	p5=1 goto sinv
i2      =       icps*ipi*2
i3      =       icps*ipi*3
i4      =       icps*ipi*4
i5      =       icps*ipi*5
i6      =       icps*ipi*6
i7      =       icps*ipi*7
i8      =       icps*ipi*8
i9      =       icps*ipi*9
	goto	sfok
sinv:
i2      =       icps*2/ipi
i3      =       icps*3/ipi
i4      =       icps*4/ipi
i5      =       icps*5/ipi
i6      =       icps*6/ipi
i7      =       icps*7/ipi
i8      =       icps*8/ipi
i9      =       icps*9/ipi
sfok:
ia1     table   icps/gifnq,3
ia2     table   i2/gifnq,3
ia3     table   i3/gifnq,3
ia4     table   i4/gifnq,3
ia5     table   i5/gifnq,3
ia6     table   i6/gifnq,3
ia7     table   i7/gifnq,3
ia8     table   i8/gifnq,3
ia9     table   i9/gifnq,3
ird     =       4/icps
ist     =       p3/12
	if	p6=1 goto s1
ip1	=	0	;locations when p6=0
ip2	=	.125
ip3	=	.25
ip4	=	.375
ip5	=	.5
ip6	=	.625
ip7	=	.75
ip8	=	.875
ip9	=	1
	goto	s2
s1:ip1	=	1	;locations when p6=1
ip2	=	.875
ip3	=	.75
ip4	=	.625
ip5	=	.5
ip6	=	.375
ip7	=	.25
ip8	=	.125
ip9	=	0
s2:
;
k1      expseg  .001,ird,1,ist*3,1,9*ist-ird,.001
a1      oscil   iamp*ia1*k1,icps,1
	outs	a1*ip1,a1*(1-ip1)
k2      expseg  .001,ird+ist,1,ist*3,1,8*ist-ird,.001
a2      oscil   iamp*ia2*k2,i2,1
	outs	a2*ip2,a2*(1-ip2)
k3      expseg  .001,ird+2*ist,1,ist*3,1,7*ist-ird,.001
a3      oscil   iamp*ia3*k3,i3,1
	outs	a3*ip3,a3*(1-ip3)
k4      expseg  .001,ird+3*ist,1,ist*3,1,6*ist-ird,.001
a4      oscil   iamp*ia4*k4,i4,1
	outs	a4*ip4,a4*(1-ip4)
k5      expseg  .001,ird+4*ist,1,ist*3,1,5*ist-ird,.001
a5      oscil   iamp*ia5*k5,i5,1
	outs	a5*ip5,a5*(1-ip5)
	if	i6 > ginyq goto s3
k6      expseg  .001,ird+5*ist,1,ist*3,1,4*ist-ird,.001
a6      oscil   iamp*ia6*k6,i6,1
	outs	a6*ip6,a6*(1-ip6)
	if	i7 > ginyq goto s3
k7      expseg  .001,ird+6*ist,1,ist*3,1,3*ist-ird,.001
a7      oscil   iamp*ia7*k7,i7,1
	outs	a7*ip7,a7*(1-ip7)
	if	i8 > ginyq goto s3
k8      expseg  .001,ird+7*ist,1,ist*3,1,2*ist-ird,.001
a8      oscil   iamp*ia8*k8,i8,1
	outs	a8*ip8,a8*(1-ip8)
	if	i9 > ginyq goto s3
k9      expseg  .001,ird+8*ist,1,ist*3,1,ist-ird,.001
a9      oscil   iamp*ia9*k9,i9,1
	outs	a9*ip9,a9*(1-ip9)
s3:
        endin
;
        instr   3               ;pi shift
;shifting function instr
;9 partials in pi relationship
;p4 = pitch, p5=switch, p6=loc, p7=amp
ipi      =       3.141596       ;pi
iamp	=	giamp*p7
ioct    =       int(p4)
ifr     =       (p4-int(p4))*100/12
;icps    =       ipi^(ioct+ifr)
icps	pow	ipi,ioct+ifr
	if	p5=1 goto sinv
i2      =       icps*ipi*2
i3      =       icps*ipi*3
i4      =       icps*ipi*4
i5      =       icps*ipi*5
i6      =       icps*ipi*6
i7      =       icps*ipi*7
i8      =       icps*ipi*8
i9      =       icps*ipi*9
	goto	sfok
sinv:
i2      =       icps*2/ipi
i3      =       icps*3/ipi
i4      =       icps*4/ipi
i5      =       icps*5/ipi
i6      =       icps*6/ipi
i7      =       icps*7/ipi
i8      =       icps*8/ipi
i9      =       icps*9/ipi
sfok:
ia1     table   icps/gifnq,3
ia2     table   i2/gifnq,3
ia3     table   i3/gifnq,3
ia4     table   i4/gifnq,3
ia5     table   i5/gifnq,3
ia6     table   i6/gifnq,3
ia7     table   i7/gifnq,3
ia8     table   i8/gifnq,3
ia9     table   i9/gifnq,3
iph1    =       0
iph2    =       .8888
iph3    =       .7777
iph4    =       .6666
iph5    =       .55555
iph6    =       .4444
iph7    =       .3333
iph8    =       .2222
iph9    =       .1111
irt     =       3/p3
ird     =       20/icps
icr     =       p3/3
	if	p6=1 goto s1
ip1	=	0	;locations when p6=0
ip2	=	.125
ip3	=	.25
ip4	=	.375
ip5	=	.5
ip6	=	.625
ip7	=	.75
ip8	=	.875
ip9	=	1
	goto	s2
s1:ip1	=	1	;locations when p6=1
ip2	=	.875
ip3	=	.75
ip4	=	.625
ip5	=	.5
ip6	=	.375
ip7	=	.25
ip8	=	.125
ip9	=	0
s2:
;
kenv    expseg  .001,ird,.2,icr,1,p3-2*icr-2*ird,1,icr,.2,ird,.001
k1      oscil   1,irt,2,iph1
a1      oscil   iamp*ia1*k1,icps,1
	outs	a1*ip1,a1*(1-ip1)
k2      oscil   1,irt,2,iph2
a2      oscil   iamp*ia2*k2,i2,1
	outs	a2*ip2,a2*(1-ip2)
k3      oscil   1,irt,2,iph3
a3      oscil   iamp*ia3*k3,i3,1
	outs	a3*ip3,a3*(1-ip3)
k4      oscil   1,irt,2,iph4
a4      oscil   iamp*ia4*k4,i4,1
	outs	a4*ip4,a4*(1-ip4)
k5      oscil   1,irt,2,iph5
a5      oscil   iamp*ia5*k5,i5,1
	outs	a5*ip5,a5*(1-ip5)
k6      oscil   1,irt,2,iph6
a6      oscil   iamp*ia6*k6,i6,1
	outs	a6*ip6,a6*(1-ip6)
k7      oscil   1,irt,2,iph7
a7      oscil   iamp*ia7*k7,i7,1
	outs	a7*ip7,a7*(1-ip7)
k8      oscil   1,irt,2,iph8
a8      oscil   iamp*ia8*k8,i8,1
	outs	a8*ip8,a8*(1-ip8)
k9      oscil   1,irt,2,iph9
a9      oscil   iamp*ia9*k9,i9,1
	outs	a9*ip9,a9*(1-ip9)
        endin
;
        instr   4               ;1/pi individual attacks
;individual partial generation
;9 partials in pi relationship (goes to 28.27)
;p4 = pitch, p5=switch, p6=loc, p7=amp
ipi      =       3.141596       ;pi
iamp	=	giamp*p7
ioct    =       int(p4)
ifr     =       (p4-int(p4))*100/12
;icps    =       ipi^(ioct+ifr)
icps	pow	ipi,ioct+ifr
	if	p5=1 goto sinv
i2      =       icps*ipi*2
i3      =       icps*ipi*3
i4      =       icps*ipi*4
i5      =       icps*ipi*5
i6      =       icps*ipi*6
i7      =       icps*ipi*7
i8      =       icps*ipi*8
i9      =       icps*ipi*9
	goto	sfok
sinv:
i2      =       icps*2/ipi
i3      =       icps*3/ipi
i4      =       icps*4/ipi
i5      =       icps*5/ipi
i6      =       icps*6/ipi
i7      =       icps*7/ipi
i8      =       icps*8/ipi
i9      =       icps*9/ipi
sfok:
ia1     table   icps/gifnq,3
ia2     table   i2/gifnq,3
ia3     table   i3/gifnq,3
ia4     table   i4/gifnq,3
ia5     table   i5/gifnq,3
ia6     table   i6/gifnq,3
ia7     table   i7/gifnq,3
ia8     table   i8/gifnq,3
ia9     table   i9/gifnq,3
ird     =       4/icps
ist     =       p3/3
ih02	=	p3/27	;=3*9
ih03	=	2*p3/27
ih04	=	3*p3/27
ih05	=	4*p3/27
ih06	=	5*p3/27
ih07	=	6*p3/27
ih08	=	7*p3/27
ih09	=	8*p3/27
	if	p6=1 goto s1
ip1	=	0	;locations when p6=0
ip2	=	.125
ip3	=	.25
ip4	=	.375
ip5	=	.5
ip6	=	.625
ip7	=	.75
ip8	=	.875
ip9	=	1
	goto	s2
s1:ip1	=	1	;locations when p6=1
ip2	=	.875
ip3	=	.75
ip4	=	.625
ip5	=	.5
ip6	=	.375
ip7	=	.25
ip8	=	.125
ip9	=	0
s2:
;
k1      expseg  .001,ird,1,ist,1,p3-ist-ird,.001
a1      oscil   iamp*ia1*k1,icps,1
	outs	a1*ip1,a1*(1-ip1)
k2      expseg  .001,ih02,1,ist,1,p3-ist-ih02,.001
a2      oscil   iamp*ia2*k2,i2,1
	outs	a2*ip2,a2*(1-ip2)
k3      expseg  .001,ih03,1,ist,1,p3-ist-ih03,.001
a3      oscil   iamp*ia3*k3,i3,1
	outs	a3*ip3,a3*(1-ip3)
k4      expseg  .001,ih04,1,ist,1,p3-ist-ih04,.001
a4      oscil   iamp*ia4*k4,i4,1
	outs	a4*ip4,a4*(1-ip4)
k5      expseg  .001,ih05,1,ist,1,p3-ist-ih05,.001
a5      oscil   iamp*ia5*k5,i5,1
	outs	a5*ip5,a5*(1-ip5)
	if	i6 > ginyq goto s3
k6      expseg  .001,ih06,1,ist,1,p3-ist-ih06,.001
a6      oscil   iamp*ia6*k6,i6,1
	outs	a6*ip6,a6*(1-ip6)
	if	i7 > ginyq goto s3
k7      expseg  .001,ih06,1,ist,1,p3-ist-ih07,.001
a7      oscil   iamp*ia7*k7,i7,1
	outs	a7*ip7,a7*(1-ip7)
	if	i8 > ginyq goto s3
k8      expseg  .001,ih08,1,ist,1,p3-ist-ih08,.001
a8      oscil   iamp*ia8*k8,i8,1
	outs	a8*ip8,a8*(1-ip8)
	if	i9 > ginyq goto s3
k9      expseg  .001,ih09,1,ist,1,p3-ist-ih09,.001
a9      oscil   iamp*ia9*k9,i9,1
	outs	a9*ip9,a9*(1-ip9)
s3:
        endin
</CsInstruments>
<CsScore>
f1 0 8192 9 1 1 0
; shift function
f2 0 1024 5 1 92 1 840 .2 92 1
;freq. resp. curve for sr=44100
f3 0 1025 5 1 138 .4 886 .4	
f1 0 8192 9 1 1 0
; shift function
f2 0 1024 5 1 92 1 840 .2 92 1
;freq. resp. curve for sr=44100
f3 0 1025 5 1 138 .4 886 .4	
s
t0 62.1137
; pi score
; 3-12 #5 t11
i2   0 12 4.00 0 0 .5
i2   3  . 3.11 . 1
i2   3  . 5.03 . 0
i2  14  . 3.01 . 1
i2  17  . 5.06 . 0  
i2  23  . 4.10 . 1
i2  24  . 3.04 . 0
i2  32  . 5.08 . 1
i2  33  . 4.07 . 0
i2  42  . 3.09 . 1
i2  42  . 5.05 . 0
i2  46  . 4.02 . 1
; 5-12 #87
i4  48 12 4.00 0 0 1
i4  50  . 5.03 . 1
i4  53  . 3.11 . 0
i4  53  . 4.06 . 1
i4  56  . 5.02 . 0
i4  60  . 5.01 . 1
i4  62  . 5.03 . 0
i4  62  . 4.07 . 1
i4  65  . 4.06 . 0
i4  71  . 3.10 . 1
i4  72  . 3.04 . 0
i4  72  . 5.01 . 1
i4  74  . 4.07 . 0
i4  78  . 4.08 . 1
i4  79  . 5.05 . 0
i4  84  . 4.00 . 1
i4  90  . 4.08 . 0
i4  91  . 5.05 . 1
i4  92  . 3.09 . 0
i4  92  . 5.02 . 1
; 3-8 #21
i2  96 12 3.11 1 0 .5
i2  99  3 4.03 . 1
i2 101  . 5.03 . 0
i2 102  . 3.00 . 1
i2 102  . 5.03 . 0
i2 103  . 5.00 . 1
i2 103  . 4.03 . 0
i2 105  . 5.00 . 1
i2 107  . 3.00 . 0
i2 108  3 4.07 . 1
i2 110  . 5.07 . 0
i2 111  . 5.07 . 1
i2 111  . 4.03 . 0
i2 111 12 3.10 . 1
i2 112  3 4.07 . 0
i2 113  . 5.03 . 1
i2 114  . 5.03 . 0
i2 115  . 4.03 . 1
i2 120  3 4.07 . 0
i2 120  . 5.08 . 1
i2 132  . 5.07 . 0
i2 122  . 3.08 . 1
i2 123  . 5.07 . 0
i2 124  . 4.07 . 1
i2 126 12 4.04 . 0
i2 129  3 3.08 . 1
i2 130  . 5.08 . 0
i2 132  3 5.08 . 1
i2 134  . 3.08 . 0
i2 138  . 3.00 . 1
i2 139  . 5.00 . 0
i2 141 12 4.05 . 1
i2 141  3 3.08 . 0
i2 141  . 5.00 . 1
i2 142  . 5.08 . 0
i2 143  . 3.00 . 1
; 5-12 #87 again
i4 144 12 4.00 0 0 1
i4 146  . 5.03 . 1
i4 148  . 5.06 . 0
i4 149  . 3.11 . 1
i4 153  . 4.02 . 0
i4 158  . 3.01 . 1
i4 158  . 4.07 . 0
i4 158  . 5.03 . 1
i4 160  . 5.06 . 0
i4 166  . 4.10 . 1
i4 168  . 3.04 . 0
i4 170  . 3.00 . 1
i4 170  . 4.07 . 0
i4 173  . 5.08 . 1
i4 175  . 5.05 . 0
i4 180  . 4.00 . 1
i4 185  . 5.08 . 0
i4 187  . 5.05 . 1
i4 188  . 3.09 . 0
i4 189  . 4.02 . 1
e
; test notes
i2  0 5 4.00 0 0
i2  5 5 4.07 . 1
i2 10 5 4.11 . 0
s
i2  0 5 4.00 1 0
i2  5 5 4.07 . 1
i2 10 5 4.11 . 0
s
i3  0 5 3.00 0 0
i3  5 5 3.07 . 1
i3 10 5 3.11 . 0
s
i3  0 5 5.00 1 0
i3  5 5 5.07 . 1
i3 10 5 5.11 . 0
s
i4  0 5 4.00 0 0
i4  5 5 4.07 . 1
i4 10 5 4.11 . 0
s
i4  0 5 4.00 1 0
i4  5 5 4.07 . 1
i4 10 5 4.11 . 0
s
; test music
i4  0 12 4.00 0 0
i4  3  . 3.11 . 1
i4  3  . 5.03 . 0
i4 21  . 3.11 . 1
i4 15  . 4.06 . 0
i4 12  . 5.01 . 1
i4 24  . 3.04 . 0
i4 30  . 4.08 . 1
i4 35  . 5.07 . 0
i4 42  . 3.04 . 1
i4 43  . 4.05 . 0
i4 45  . 5.02 . 1
e
</CsScore>
</CsoundSynthesizer><bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>724</x>
 <y>276</y>
 <width>400</width>
 <height>140</height>
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
