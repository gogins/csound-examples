;==================================================================
;===								===
;===			"THE LEGEND of AMBER"			===
;===			 -------------------			===
;===		 	(c) Luca Pavan - 2002			===
;===								===
;===								===
;===		  	   Duration: 9'19"			===
;===								===
;==================================================================

sr = 48000
ksmps  = 1
nchnls = 2

ga1 init 0
ga2 init 0
ga3 init 0
ga4 init 0
ga5 init 0
ga6 init 0
ga7 init 0
ga8 init 0
ga9 init 0
gaa init 0
gab init 0
gac init 0
gad init 0
gae init 0
gaf init 0
gag init 0
gah init 0
gai init 0
gal init 0
gam init 0
gan init 0
gao init 0
gap init 0
gaq init 0
gar init 0
gas init 0
gat init 0

instr 1
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

ka  linen 1,p3*.25,p3,p3*.25
ke  line 100, p3, 5000
kv  line 5000, p3, 100
kx  randi p4, 5
ky  randi p5, 10
k2  gauss 50
k3  randi 1, abs(k2)
a1  rand 10000
a2  delay a1, .005
a3 = a1+a2
a4  butterbp a3, ke, abs(kx)
a5  butterbp a3, kv, abs(ky)
a6 = a4+a5
as  delay a6, .1
al = ((as*.3*abs(k3))+as*.5)*ka
ar = ((as*.3*(1-abs(k3)))+as*.5)*ka
ga1= ga1+al*p6
ga2= ga2+ar*p6
  outs al*(1-p6), ar*(1-p6)
   endin

instr 2
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

an linen 9000, .2, p3, 4
k2 expseg 100,p3*.75,12000,p3*.15,12000
k1 randh k2, 5
a1 rand an
k1 = abs(k1)
a2 reson a1, k1, 250
a3 reson a1, k1*2, 175
a4 reson a1, k1*1.7, 150
a5 reson a1, k1*3, 100
a6 reson a1, k1*3.2, 75
as = a2+(a3*.8)+(a4*.6)+(a5*.4)+(a6*.2)
ab balance as, a1
al = ab*.7*(1-p4)
ar = ab*.7*p4
ga3= ga3+al*p5
ga4= ga4+ar*p5
  outs al*(1-p5), ar*(1-p5)
   endin

instr 3
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

ke linen p4*1.5, 4, p3, 5
k1 expseg 150,p3*.25,180,p3*.25,200,p3*.25,300,p3*.25,150
k2 expseg 40,p3*.25,120,p3*25,350,p3*.25,350,p3*.25,250
a1 rand 15000
a2 butterbp a1, k1, k2
a3 tone a2, 600
al = a3*ke*(1-p5)
ar = a3*ke*p5
ga5= ga5+al*p6
ga6= ga6+ar*p6
  outs al*(1-p6), ar*(1-p6)
   endin

instr 4
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

#define M # .003,.02,.007,2000,1,3,p3#

if p82=1 goto cnt1
kf1 = cpspch(p5)
kf2 = cpspch(p5)
kf3 = cpspch(p5)
kf4 = cpspch(p5)

if p82!=1 goto cnt2

cnt1:
kv1  randi 179,5,.5,1
kv2  randi 204,8,.8,1
kv3  randi 183,10,.2,1
kv4  randi 660,15,.3,1

kf1 = 66 +abs(kv1)
kf2 = 124+abs(kv2)
kf3 = 165+abs(kv3)
kf4 = 220+abs(kv4)

cnt2:
ka  linen p6*1.9, .25, p3, p7
ke  linen 1, .25, p3, .1
kc  randi 1, 1
k1  oscili 1, 1/p3*p80, p81

if p79 = 1 goto outa
if p79 = 2 goto oute
if p79 = 3 goto outi
if p79 = 4 goto outo
if p79 = 5 goto outu

outa:
a1  fof p4,     kf1, p9,  kc, p14, $M
a2  fof p4*p19, kf1, p10, kc, p15, $M
a3  fof p4*p20, kf1, p11, kc, p16, $M
a4  fof p4*p21, kf1, p12, kc, p17, $M
a5  fof p4*p22, kf1, p13, kc, p18, $M
a6 = a1+a2+a3+a4+a5
as = (a6*k1)*ka
goto end

oute:
a7  fof p4,     kf2, p23, kc, p28, $M
a8  fof p4*p33, kf2, p24, kc, p29, $M
a9  fof p4*p34, kf2, p25, kc, p30, $M
a10 fof p4*p35, kf2, p26, kc, p31, $M
a11 fof p4*p36, kf2, p27, kc, p32, $M
a12 = a7+a8+a9+a10+a11
as = (a12*k1)*ka
goto end

outi:
a13 fof p4,     kf1, p37, kc, p42, $M
a14 fof p4*p47, kf1, p38, kc, p43, $M
a15 fof p4*p48, kf1, p39, kc, p44, $M
a16 fof p4*p49, kf1, p40, kc, p45, $M
a17 fof p4*p50, kf1, p41, kc, p46, $M
a18 = a13+a14+a15+a16+a17
as = (a18*k1)*ka
goto end

outo:
a19 fof p4,     kf3, p51, kc, p56, $M
a20 fof p4*p61, kf3, p52, kc, p57, $M
a21 fof p4*p62, kf3, p53, kc, p58, $M
a22 fof p4*p63, kf3, p54, kc, p59, $M
a23 fof p4*p64, kf3, p55, kc, p60, $M
a24 = a19+a20+a21+a22+a23
as = (a24*k1)*ka
goto end

outu:
a25 fof p4,     kf4, p65, kc, p70, $M
a26 fof p4*p75, kf4, p66, kc, p71, $M
a27 fof p4*p76, kf4, p67, kc, p72, $M
a28 fof p4*p77, kf4, p68, kc, p73, $M
a29 fof p4*p78, kf4, p69, kc, p74, $M
a30 = a25+a26+a27+a28+a29
as = (a30*k1)*ka

end:
ad delay as, .06
as = as*(1-p8)
ad = ad*ke*p8
ga7 = ga7+as*.15
ga8 = ga8+ad*.15
  outs as*.75, ad*.75
   endin

instr 5
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

ke   linen 1.5, 5, p3, 5
kd   oscili 1, 1/p3, 4
k1   randh p5, 10
k2   expseg 60,p3*.5,850,p3*.25,550,p3*.25,60
kj1  randh 10, 10
a1   foscili p4, 40+abs(k1), 10, 2, 1, 1
a2   oscili 1, k2+abs(kj1), 1
al = a1*a2*kd*ke*(1-p6)
ar = a1*a2*kd*ke*p6
ga9= ga9+al*p7
gaa= gaa+ar*p7
  outs al*(1-p7), ar*(1-p7)
   endin

instr 6
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

#define F # k7, 1, 1, 1#

ke linen 1.5, .02, p3, .02
k1 expseg .001,1,p4*.2,p3-1,.001
k2 expseg .001,1.5,p4*.2,p3-1.5,.001
k3 expseg .001,2,p4*.2,p3-2,.001
k4 expseg .001,2.5,p4*.2,p3-2.5,.001
k5 expseg .001,3,p4*.2,p3-3,.001
k6 randi 1, 2
k7 line p6, p3, p7
a1 foscili k1, p5,   $F
a2 foscili k2, p5-2, $F
a3 foscili k3, p5-3, $F
a4 foscili k4, p5+10,$F
a5 foscili k5, p5+9, $F
a6 = a1+a2+a3+a4+a5
al = a6*(1-abs(k6))*ke
ar = a6*abs(k6)*ke
gab= gab+al*p8
gac= gac+ar*p8
  outs al*(1-p8), ar*(1-p8)
   endin

instr 7
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

a4 init 0

ke linen 1.2, .01, p3, .01
k1 linseg 0,.05,1,.05,.5,p3*.1-.1,.5,p3*.05,0
k2 line 1, p3, cpspch(p8)
k4 randi 1, 3 
a1 oscili k1*p4, cpspch(p5)+k2, 1
a2 oscili 1, cpspch(p6), 1
a3 = a1*a2
a4 delay (a3+a4)*.7, p7
al = (a3+a4)*ke*abs(k4)
ar = (a3+a4)*ke*(1-abs(k4))
gad= gad+al*p9
gae= gae+ar*p9
  outs al*(1-p9), ar*(1-p9)
   endin

instr 8
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

ke  linen 1.3, .01, p3, .01
k1  linen p4, p3*.35, p3, p3*.3
k2  line  10, p3, 4
k3  randi k2, 1
k4  randi 100, 1.5
k5  randi 200, 2
k6  linseg .01,p3*.5,100,p3*.5,.01
k7  randi 1, k6
ki1 expon .001, p3, 10
ki2 expon 10, p3, .001
ki3 linseg 0, p3*.5, 5, p3*.5, 0
am1 oscili ki1*(p6+k3), p6, 1
am2 oscili ki2*(p7+k4), p7, 1
am3 oscili ki3*(p8+k5), p8, 1
ac1 oscili k1, p5+am1+am2+am3, 1
aff butterbp ac1, 4000, 19000
af1 butterhp aff, 75
al = af1*abs(k7)*ke
ar = af1*(1-abs(k7))*ke
gaf= gaf+al*p9
gag= gag+ar*p9
  outs al*(1-p9), ar*(1-p9)
   endin

instr 9
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

k3 linseg p7,p3*.25,p7,0,p8,p3*.25,p8,0,p7,p3*.25,p7,0,p8,p3*.25,p8
k2 randi 1, 2
ke linen 1.2, .01, p3, .2
if p9 !=0 goto c1
k1 oscili p4, 1/p3*k3, 2
goto c2
c1:
k1 oscili p4, 1/p3, 2
c2:
a2 oscili 1, p5, 1
a3 oscili 1, p6, 1
a4 = a2*a3
a5 butterhp a4, 70
al = a5*k1*ke*abs(k2)
ar = a5*k1*ke*(1-abs(k2))
az delay al, .07
  outs az, ar
   endin

instr 10
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

ke linen p4, .05, p3, .5
k1 linseg p6,p3*.5,p6+2000,p3*.5,p6
k2 randi 1000, 2
ka line p7, p3, p8
k3 oscili 1, 1/p3*ka, 5
k4 oscili 1, 1/p3*ka, 6
k5 expon 50, p3, 200
a1 foscili ke, 1, p5, p6, 5, 1
a2 butterbp a1, k1, k5
a3 butterbp a1, k1*2, k5*2
a4 = a2+a3
if p9 != 0 goto inv
gah= gah+(((a4*k4)+(a4*k3))*.4)*p10
 outs a4*k4*(1-p10), a4*k3*(1-p10)
   goto end
inv:
gah= gah+(((a4*k4)+(a4*k3))*.5)*p10
 outs a4*k3*(1-p10), a4*k4*(1-p10)
end:
   endin

instr 11
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

kn linen 1.4, .01, p3, .01
kc expseg 1,p3*.5,p6,p3*.5,1
kg line 8000, p3, 1
ke oscili p4, 1/p3+kc, 2
kp expseg .001,.02,1,p3-.02,.001
k1 line 6, p3, 1
k2 randh kg, 14
k3 randi 30, 2
k4 randi 1, 10
k5 oscili 1, 1/p3*k3, 1
a1 oscili k1*k2, p5+k2, 1
a2 oscili ke*kp, abs(k2)*3+a1+k5, 1
a3 butterhp a2, 11000
al = a3*kn*abs(k4)
ar = a3*kn*(1-abs(k4))
gai= gai+al*p7
gal= gal+ar*p7
  outs al*(1-p7), ar*(1-p7)
   endin

instr 12
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

ka  expseg .001,p3*.1,p4,p3-.1,.001
kb  expseg .001,p3*.1,1,p3-.1,.001
k1  expon  100, 1/p3*10, 200
k2  expon  200, p3, 1000
k3  oscili 1, 1/p3, 1
k4  randi  50, 1/p3
k5  oscili 1, 1/p3, 5
k6  oscili 1, 1/p3, 6
kf  expon  p5, p3, p6
a1  oscili 1, 60, 1
a2  oscili 1, 1+k1, 1
a3  oscili ka, kf, 1
a4  rand 10000
a5  butterbp a4, k2, k3+abs(k4)
al = (a1*a2*a3+a5*kb)*k5
ar = (a1*a2*a3+a5*kb)*k6
alx butterbp al, 10000, 19900
ary butterbp ar, 10000, 19900
all reverb2 alx, 2, 0
alr reverb2 ary, 2.1, 0
if p7 !=0 goto c2
gam= gam+(al+ar)*.3
  outs alx+all*.7, ary+alr*.7
  goto end
c2:
gam= gam+(al+ar)*.3
  outs ary+alr*.7, alx+all*.7
end:
   endin

instr 13
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

kn linen 1, .01, p3, .01
ke expseg .001,p9,p4,p3-p9,.001
kv linseg 0,.3,0,.1,1,p3-.7,1,.3,0
k1 oscili p6, 1/p3, 7
k2 oscili p8, 1/p3, 7
k3 randi 1, p10
a1 rand 15000
a2 butterbp a1, p5+k1, p7+k2
a3 oscili 1, 1/p3, 7
a4 = a2*a3
a5 comb a4, .1, .05
ax balance a4, a1
ay balance a5, a1
al = ax*ke*kn*abs(k3)
ar = ay*ke*kn*kv*(1-abs(k3))
gan= gan+al*p11
gao= gao+ar*p11
  outs al*(1-p11), ar*(1-p11)
   endin

instr 14
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

ke  line p6, p3, p7
ka  linen 1.2, .02, p3, .02
k1  expseg .001,p3*.1,1,p3-p3*.1,.001
k2  expseg .001,p3*.25,1,p3-p3*.25,.001
k3  expseg .001,p3*.4,1,p3-p3*.4,.001
k4  expseg .001,p3*.65,1,p3-p3*.65,.001
k5  expseg .001,p3*.8,1,p3-p3*.8,.001
k6  expseg .001,p3*.95,1,p3-p3*.95,.001
k7  randi 40, 1
k8  randi 30, 1
k9  randi 20, 1
k10 randi 10, 1
k11 randi 5, 1
a1  oscili p4*k1,p5+ke,1
a2  oscili p4*k2,p5+k7+ke,1
a3  oscili p4*k3,p5-k8+ke,1
a4  oscili p4*k4,p5+k9+ke,1
a5  oscili p4*k5,p5-k10+ke,1
a6  oscili p4*k6,p5+k11+ke,1
a7 = a1+a2+a3+a4+a5+a6
a8  oscili 1, p5*2+ke, 1
a9 = a7*a8
af  reson a9, 4000, 1000
aff reson af, 4000, 1000
ab balance af, a1
az butterhp ab, 70
az = az*ka
gap= gap+az*.4*p8
  outs az*(1-p8), az*(1-p8)
   endin

instr 15
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

ke linen p4*1.8, .02, p3, 1.5
kp line 8, p3, 1/p3
kv randh 240, kp
k1 line 4000, p3, 1
k2 randi k1, 1
k3 oscili 1, (1/p3)*abs(kv), 8
k4 expon 1, p3, 1/p3
k5 randi 1, k4
k6 expon p5, p3, p6
a1 rand 10000
a2 butterbp a1, k6+abs(k2), 20
ab balance a2, a1
az comb ab, .1, .05
ar reverb2 ab, 2, .5
al = ab*k3*ke*abs(k5)+(ar*.009)
ar = az*k3*ke*(1-abs(k5))+(ar*.008)
gaq= gaq+al*p7
gar= gar+ar*p7
  outs al*(1-p7), ar*(1-p7)
   endin

instr 16
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

p5 = cpspch(p5)
ke linen  1, p8, p3, p9
k1 expon  p4, p3, .001
k2 expon  p4, p3*p7*.94,.001
k3 expon  p4, p3*p7*.9,.001
k4 expon  p4, p3*p7*.86,.001
k5 expon  p4, p3*p7*.84,.001
k6 expon  p4, p3*p7*.8,.001
k7 expon  p4, p3*p7*.74,.001
k8 expon  p4, p3*p7*.7,.001
a1 oscili k1, p5, 1
a2 oscili k2*.6, p5*2, 1
a3 oscili k3, p5*2.37, 1
a4 oscili k4*1.76, p5*3, 1
a5 oscili k5*2.6, p5*4, 1
a6 oscili k6*1.6, p5*5.2, 1
a7 oscili k7*1.43, p5*5.3, 1
a8 oscili k8*1.33, p5*6, 1
at = (a1+a2+a3+a4+a5+a6+a7+a8)*ke
as butterhp at, 50
gas= gas+as*p10
gat= gat+as*p10
  outs as*(1-p6)*(1-p10), as*p6*(1-p10)
   endin

instr 99
prints "instr %9.4f p2 %9.4f p3 %9.4f p4 %9.4f p5 %9.4f p6 %9.4f p7 %9.4f #%3d\n", p1, p2, p3, p4, p5, p7, active(p1)

ad1  delayr  .25
at1  deltapi .0231
at2  deltapi .0222
at3  deltapi .0132
at4  deltapi .0134
at5  deltapi .1051
at6  deltapi .1024
at7  deltapi .0353
at8  deltapi .0324
at9  deltapi .0232
at10 deltapi .0232
at11 deltapi .1134
at12 deltapi .1123
at13 deltapi .0345
at14 deltapi .0345
at15 deltapi .0673
at16 deltapi .1233
at17 deltapi .1312
at18 deltapi .0637
at19 deltapi .0684
at20 deltapi .1163
at21 deltapi .1173
at22 deltapi .0275
at23 deltapi .0282
at24 deltapi .0297
     delayw ga1+ga2+ga3+ga4+ga5+ga6+ga7+ga8+ga9+gaa\
     +gab+gac+gad+gae+gaf+gag+gah+gai+gal+gam+gan+gao\
     +gap+gaq+gar+gas+gat     
as1 = at1+at2+at3+at4+at5+at6+at7+at8+at9+at10+at11+at12
as2 = at13+at14+at15+at16+at17+at18+at19+at20+at21+at22+at23+at24
arl  nreverb as1*.083, p4, 0
arr  nreverb as2*.083, p4, 0
km1  oscili 280, .02, 1
km2  oscili 250, .023, 1, .2
al1  butterlp arl, 17500+km1
ar1  butterlp arr, 16800+km2
al   balance al1, arl
ar   balance ar1, arr
kd   linseg .9,400.5,.9,1,1,155,1
a1   butterbp al,50,60
ad1  alpass   a1,0,.01
a2   butterbp al,200,240
a3   butterbp al,800,960
ad3  alpass   a3,0,.01
a4   butterbp al,3200,3840
a5   butterbp al,12800,15360
ad5  alpass   a5,0,.01
a1a  butterbp ar,50,60
a2a  butterbp ar,200,240
ad2a alpass   a2a,0,.01
a3a  butterbp ar,800,960
a4a  butterbp ar,3200,3840
ad4a alpass   a4a,0,.01
a5a  butterbp ar,12800,15360
a1l = ad1+a2+ad3+a4+ad5
a2r = a1a+ad2a+a3a+ad4a+a5a
aoutl = (al*(1-kd))+(a1l*kd)
aoutr = (ar*(1-kd))+(a2r*kd)
  outs aoutl*1.3, aoutr*1.3
ga1= 0
ga2= 0
ga3= 0
ga4= 0
ga5= 0
ga6= 0
ga7= 0
ga8= 0
ga9= 0
gaa= 0
gab= 0
gac= 0
gad= 0
gae= 0
gaf= 0
gag= 0
gah= 0
gai= 0
gal= 0
gam= 0
gan= 0
gao= 0
gap= 0
gaq= 0
gar= 0
gas= 0
gat= 0
   endin

; Compilation time: about 20'
; with a Pentium III 1133 Mhz
; and 512 MB of RAM
