;Westkreuz28.orc - Computer Music Instruments
;Copyright (C) 2004  Radu Grigorovici
;
;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

sr=44100
ksmps=2
nchnls=2

;=========================================================================================
;Westkreuz28
;for csoundAV
;=========================================================================================

gibpm	   init 100

instr 1
ibpm	   =p4
gibpm	   =ibpm
endin

instr 2
;=========================================================================================
idur	   =p3
iamp	   =280*(exp(p4*0.046151205)-1)
	   ;pitch
ipch1	   =(p5<=p6 ? p5 : p6)
ipch2	   =(p5> p6 ? p5 : p6)
ipchx	   =p7
	   ;envelope
iamp1	   =(p8<=p9 ? p8 : p9)/100
iamp2	   =(p8> p9 ? p8 : p9)/100
iampx	   =p10
	   ;cutoff
icut1	   =50+(15950/100)*(exp((p11<=p12 ? p11 : p12)*0.046151205)-1)
icut2	   =50+(15950/100)*(exp((p11> p12 ? p11 : p12)*0.046151205)-1)
icutx	   =p13
	   ;cutoff resonance
ires1	   =1+(99/100)*(p14<=p15 ? p14 : p15)
ires2	   =1+(99/100)*(p14> p15 ? p14 : p15)
iresx	   =p16
	   ;distort
idis1	   =0.001+(9.999/100)*(p17<=p18 ? p17 : p18)
idis2	   =0.001+(9.999/100)*(p17> p18 ? p17 : p18)
idisx	   =p19
	   ;sequencer density
isqd1	   =(p20<=p21 ? p20 : p21)
isqd2	   =(p20> p21 ? p20 : p21)
isqdx	   =p22
	   ;sequencer level
isql1	   =1-(p23<=p24 ? p23 : p24)/100
isql2	   =1-(p23> p24 ? p23 : p24)/100
isqlx	   =p25
	   ;sequencer filter
isqf1	   =1-(p26<=p27 ? p26 : p27)/100
isqf2	   =1-(p26> p27 ? p26 : p27)/100
isqfx	   =p28
	   ;sequencer envelope
isqv1	   =-((p29<=p30 ? p29 : p30)-50)/5
isqv2	   =-((p29> p30 ? p29 : p30)-50)/5
isqvx	   =p31
	   ;sequencer amplitude table
iampt	   =p32
	   ;sequencer notes table
inott	   =p33
	   ;highpass cutoff
ihpass	   =(p34=0 ? 0:20+(9980/100)*(exp(p34*0.046151205)-1))
	   ;wave
iwave	   =p35
	   ;noise/signal ratio
inoise	   =p36/100
	   ;pan
ipan	   =1-p37/100
;=========================================================================================
	   ;frequency for 1 beat
ibeat	   =gibpm/60
	   ;declick envelope
kdecl	   transeg 0, 0.004, -10, 1, idur-0.012, 0, 1, 0.008, 10, 0
	   ;control envelopes
istep	   =idur/16
;=========================================================================================
#define    READENVELOPE(ENVELOPE ) #
	    tb0_init i$ENVELOPE.x
k$ENVELOPE. linseg tb0(00), istep, tb0(01), istep, tb0(02), istep, tb0(03), istep\
		  ,tb0(04), istep, tb0(05), istep, tb0(06), istep, tb0(07), istep\
		  ,tb0(08), istep, tb0(09), istep, tb0(10), istep, tb0(11), istep\
		  ,tb0(12), istep, tb0(13), istep, tb0(14), istep, tb0(15) #
;=========================================================================================
$READENVELOPE(amp )
kamp	   =iamp1+kamp*(iamp2-iamp1)
$READENVELOPE(pch )
kptc	   =kpch
kpch	   =ipch1+kptc*(ipch2-ipch1)
kptc	   =cpspch(ipch1)+kptc*(cpspch(ipch2)-cpspch(ipch1))
$READENVELOPE(cut )
kcut	   =icut1+kcut*(icut2-icut1)
$READENVELOPE(res )
kres	   =ires1+kres*(ires2-ires1)
$READENVELOPE(dis )
kdis	   =1+idis1+kdis*(idis2-idis1)
$READENVELOPE(sqd )
ksqd	   =ibeat/isqd1+ksqd*((ibeat/isqd2)-(ibeat/isqd1))
$READENVELOPE(sql )
ksql	   =(isql1+ksql*(isql2-isql1))
$READENVELOPE(sqf )
ksqf	   =(isqf1+ksqf*(isqf2-isqf1))
$READENVELOPE(sqv )
ksqv	   =isqv1+ksqv*(isqv2-isqv1)
;=========================================================================================
	   ;sequencer envelope
kseqv0	   phasor ksqd/ftlen(iampt)
kseqv1	   table kseqv0*ftlen(iampt), iampt
	   ;sequencer notes
kpch1	   =octcps(kptc)
kpch2	   =pchoct(kpch1)
kseqn0	   phasor ksqd/ftlen(inott)
kseqn1	   table kseqn0*ftlen(inott), inott
kseqn2	   =kseqn1/100
kseqn4	   =cpspch(kpch2+kseqn2)
	   ;blip envelope
ksqdv0	   poscil 1, ksqd, 2
ksqdv1	   =(tan(tan(ksqdv0)*0.642093)*0.642093+1)/2
ksqdv2	   =(ksqv=0 ? ksqdv1 : (1-exp(ksqdv1*ksqv))/(1-exp(ksqv)))
ksqdv3	   =(1-abs(ksqdv2*2-1))*(1-ksql)*kseqv1+ksql
ksqdv4	   limit ksqdv3, 0, 1
	   ;blip filter envelope
ksqdf3	   =(1-abs(ksqdv2*2-1))*(1-ksqf)*kseqv1+ksqf
ksqdf4	   limit ksqdf3, 0, 1
;=========================================================================================
	   ;dry signal
asig01	   oscil3 kamp*iamp, kseqn4, 1
asig02	   vco kamp*iamp, kseqn4, iwave, 1
asig0	   =(iwave=0 ? asig01 : asig02)
	   ;noise
asig1	   noise kamp*iamp, kpch/100
asig2	   =asig0*(1-inoise)+asig1*inoise
;=========================================================================================
	   ;cutoff resonance filter
asigcut    rezzy asig2, 50+kcut*ksqdf4, kres
asigbal    balance asigcut, asig2
	   ;distortion
asigdis    distort1 asigcut, kdis, 1, 0, 0
	   ;sequencer envelope
asigseq    =asigdis*ksqdv4
asighi	   butterhp asigseq, ihpass
;=========================================================================================
	   ;declick
asigout    =asighi*kdecl
	   ;pan
asigou21   =asigout*sin(1.570796*ipan)
asigou22   =asigout*cos(1.570796*ipan)
	   ;output
outs	   asigou21, asigou22

endin
