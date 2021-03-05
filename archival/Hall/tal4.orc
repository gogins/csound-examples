 ;tal4a - the orc for "Talisman IV"          by Jeffrey Hall
 ;this orc has 24 instrs
 ;1,6,19,20:fofm1 line 12
 ;13,14:fofm2 line 112
 ;21,22:old truncated swan; line 221
 ;2,4,15,16:new truncated swan with fm; line 349
 ;3,5,17,18:reworked old swan now more percussive line 500
 ;7,10,26,27:fmvibin2 the horn from TalII line 700
 ;24,25:new fm instr with 2 mods & 2 cars line 856
 ;9:reverb line 918

     sr = 44100                                
     kr = 1050                     ;has rise time dependent on octpch
 ksmps  = 42                       ;has harmonic fm which varies with amp inputs
nchnls  = 2
instr   1,6,19,20

isp1    = cpspch(p5)               ;both modulator freq and carrier freq; i.e., harm.
isp1.1  = (isp1/800)
isp2    = (isp1/10)                ;goes to kvib;(cps of p5)/10
isp2.1  = (isp1/1800)
isp2.2  = (p5>9.00? isp2.1:isp2)
isp2.3  = (p5= 10.00? isp1.1:isp2.2)
ifoct   = octpch(p5)                     ;linoct version of p5; goes to vibwid and rise
ifoct1  = (ifoct*.000001)                ;cuts vibwid down for short notes
ifoct2  = (ifoct*.02)                    ;(linoct * .02) gives proportional vibwidth
ifoct3  = (p3<=.19? ifoct1:ifoct2)       ;to narrow vibwidth for short notes
isp3    = cpsoct(ifoct3)                 ;converts vibwidth calc to cps

iwiq    = p5+p9                          ;init code for low note envlp
          if iwiq<=7.07 igoto next       ;goes to cresc rise for low notes
ie      = (p3*(1/ifoct))                 ;((reciprocal of linoct) * p3) gives rise
ief     = (p3-ie)*.618034                ;takes (leftover part of p3)*.618etc.
          igoto contin                   ;these for notes neither low nor short
        if p3>.2 igoto contin            ;goes to rise&dec for nonshort &nonlow notes
ie      = .0381966                       ;fastrise for short notes         ;.0381966
ief     = .0618034                       ;fastdec for short notes         ;.0618034
          igoto contin                   ;these for notes .2 of beat or smaller
next:ie = p3*.9381     ;                 ;cresc rise for low notes
ief     = (p3-ie)        ;*.618034       ;short dec for low notes


contin:iamp1 = (p4*2400)+1               ;inputamp 1
ispan1  = (iamp1*.618034)+1              ;this group is for factoring the rampamps
ispan2  = (p8>0? ispan1:iamp1)           ;ispan2 is input amp for iamp1
iamp2   = (p6*2400)+1                    ;inputamp 2
ispan3  = (iamp2*.618034)+1
ispan4  = (p8>0? ispan3:iamp2)           ;ispan4 is input amp for iamp2
iamp3   = (p10*2400)+1          
ispan5  = (iamp3*.618034)+1
ispan6  = (p8>0? ispan5:iamp3)           ;ispan6 is input amp for iamp3

ikong1  = ((int(p4)+1)*.0001)            ;int part of inputamp 1 factored down
iqoo    = abs(p3)
ikongi  = (iqoo<=.1114285? .01666:(1/isp1)*3)
ikongh  = (iqoo=.1158285? (1/isp1*2):ikongi)
ikongj  = (iqoo>=.3? .01666:ikongh)                                  
ikong2  = ((int(p6)+1)*ikongj)
ikong3  = ((int(p10)+1) *.0015)          ;same for inputamp 3     factored down
    
iwar1   = p5*110
iwar2   = p5*19.64285714
iwa     = (p5>=9.09? iwar1:iwar2)

kamp    expseg  ispan2,ie,ispan4,ief,ispan6       ;1st exp curve for kenvl
kamp1   expseg ikong1,ie,ikong2,ief,ikong3        ;2nd exp curve for kenv2
kenv    envlpx kamp,ie,p3,ief,16,1,.0038,-1       ;envl for carrier amp
kenva   = kenv*4
kenvl   = ((p2>=69.2 && p3<=.1158285)? kenva:kenv)
kenv2   envlpx kamp1,ie,p3,ief,16,1,.0038         ;envl to vary modulator freq
kwaq    = (p8*kenv2)*(1/ifoct)
kvib    oscil  (isp2.3+isp3),isp1+kenv2,1         ;modamp has vibamp varied by cps/10
akenvl  envlpx kvib,ie,p3,ief,33,.6,.003819       ;envl to vary carrier freq;
arx1    = isp1
arx2    = isp1+akenvl
arg     = (p5>8.05 && p5<9.01? arx1:arx2)
arf     fof  kenvl,arg,arg,kwaq,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,1 ;
arf1    fof  kenvl*.618034,(isp1*2),arg,kwaq,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.618
arf2    fof  kenvl*.381966025,(isp1*3),arg,kwaq,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.381
arf3    fof  kenvl*.23606799,(isp1*4),arg,kwaq,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.236
arf4    fof  kenvl*.145898044,(isp1*5),arg,kwaq,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.145
arf5    fof  kenvl*.090169951,(isp1*6),arg,kwaq,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.090
arf6    fof  kenvl*.055728094,(isp1*7),arg,kwaq,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.055
arf7    fof  kenvl*.034441856,(isp1*8),arg,kwaq,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.034
arf8    fof  kenvl*.021286238,(isp1*9),arg,kwaq,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.021
arf9    = arf+arf1+arf2+arf3+arf4+arf5+arf6+arf7+arf8

astr    = arf9*.34
astr2   = arf9*1.2
adur    = (p3<=.116? astr:astr2)                  ;to get shortnote amps down

 ;igoo    = abs(p2)           ;this is for isolating score segments for tweaking
 ;ida1    = 1
 ;ida2    = .4               ;.4 is norm
 ;idam    = (((igoo>=131.284076 && igoo<137.770472) && p1=1)? ida1:ida2) 
 ;aout    = adur*idam


aouts1  = adur*0;use aout when in
aouts2  = adur*.28
about1  = (p1=1? aouts2:aouts1) 
about2  = (p1=6? aouts2:aouts1)
about3  = (p1=19? aouts2:aouts1) 
about4  = (p1=20? aouts2:aouts1)
        outs  about1+about3,about2+about4
gabal1  = (about1+about3)
gabal2  = (about2+about4)
        endin


 
;fofm2;fofm2 is a fof variant of fofm

instr   13,14

isp1    = cpspch(p5)                     ;both modulator freq and carrier freq; i.e., harm.

isp2.1  = (isp1/1800)

ifoct   = octpch(p5)                     ;linoct version of p5; goes to vibwid and rise
ifocta  = (ifoct*.00001)                 ;cuts vibwid down 
isp3    = cpsoct(ifocta)                 ;converts vibwidth calc to cps


iwiq    = p5+p9                          ;init code for low note envlp
          if iwiq<=7.07 igoto next       ;goes to cresc rise for low notes
ie      = (p3*(1/ifoct))                 ;((reciprocal of linoct) * p3) gives rise
ief     = (p3-ie)*.618034                ;takes (leftover part of p3)*.618etc.
          igoto contin                   ;these for notes neither low nor short
next:ie = p3*.9381     ;                 ;cresc rise for low notes
ief     = (p3-ie)        ;*.618034       ;short dec for low notes

contin:iamp1  = (p4*2400)+1              ;inputamp 1
ispan1  = log((iamp1*.618034)+1)         ;this group is for factoring the rampamps
ispan2  = (p8=1? ispan1:iamp1)           ;ispan2 is input amp for iamp1
iamp2   = (p6*2400)+1                    ;inputamp 2
ispan3  = log((iamp2*.618034)+1)
ispan4  = (p8=1? ispan3:iamp2)           ;ispan4 is input amp for iamp2
iamp3   = (p10*2400)+1          
ispan5  = log((iamp3*.618034)+1)
ispan6  = (p8=1? ispan5:iamp3)           ;ispan6 is input amp for iamp3

ikong1  = (int(p4)+1)*.0001              ;int part of inputamp 1 factored down
iqoo    = abs(p3)
ikongi  = (iqoo<=.1114285? .01666:(1/isp1)*3)
ikongh  = (iqoo=.1158285? (1/isp1*2):ikongi)
ikongj  = (iqoo>=.3? .01666:ikongh)                                  
ikong2  = (int(p6)+1)*ikongj
ikong3  = (int(p10)+1) *.0015            ;same for inputamp 3  factored down
    
iwar1   = p5*110
iwar2   = p5*19.64285714
iwa     = (p5>=9.09? iwar1:iwar2)



kamp    expseg ispan2,ie,ispan4,ief,ispan6        ;1st exp curve for kenvl
kamp1   expseg ikong1,ie,ikong2,ief,ikong3        ;2nd exp curve for kenv2
kenv    envlpx kamp,ie,p3,ief,16,1,.0038,-1       ;envl for carrier amp
kfoct1  = ifocta*kenv
kenva   = kenv*4
kenvl   = ((p2>=69.2 && p3<=.1158285)? kenva:kenv)
kenv2   envlpx kamp1,ie,p3,ief,16,1,.0038         ;envl to vary modulator freq

   kt2 expon ispan1,ispan6,p3; 
  ktex = kt2            
  kdur = p3                       
  kram = kdur/ktex                
   kww = (exp(1/12))*((1/(int(p5)))*4)   ;check               
 kampr = kww*isp1                 
 isee  = .015*p2                     

  kap1 randi kampr,kram,isee 
 
  kap  = (kap1*.005)

kramp  = kenv2*200;450

kvib    oscil  (isp2.1+isp3),(isp1+kramp),1   ;isp1+kenv2; 2modamp has vibamp varied by cps/10
akenvl  envlpx kvib,ie,p3,ief,33,.6,.003819   ;envl to vary carrier freq;

arg    = (isp1+akenvl)+kap

akviba  = (p7=1? arg+(kvib*100):arg)
iwa     =(p5>=9.09? iwar1:iwar2)

kvud    = kfoct1
arf     fof  kenvl,akviba,arg,p8*kenv2,kvud,ikong1,ikong2,ikong3,iwa,1,18,p3,0,1 ;
arf1    fof  kenvl*.618034,(isp1*2),arg,p8*kvud,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.618
arf2    fof  kenvl*.381966025,(isp1*3),arg,p8*kvud,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.381
arf3    fof  kenvl*.23606799,(isp1*4),arg,p8*kvud,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.236
arf4    fof  kenvl*.145898044,(isp1*5),arg,p8*kvud,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.145
arf5    fof  kenvl*.090169951,(isp1*6),arg,p8*kvud,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.090
arf6    fof  kenvl*.055728094,(isp1*7),arg,p8*kvud,kenv2,ikong1,ikong2,ikong3,iwa,1,18,p3,0,.055
arf7    = arf+arf1+arf2+arf3+arf4+arf5+arf6

astr    = arf7*.34
astr2   = arf7*1.2
adur    = (p3<=.116? astr:astr2)     ;to get shortnote amps down


 igoo    = abs(p2)           ;this is for isolating score segments for tweaking
 ida1    = 1
 ida2    = 3.               ;.
 idam    = (((igoo>=459.6 && igoo<476.4272) && p1=13)? ida2:ida1) ;476.4272
 aout    = adur*idam


aouts1  = aout*0
aouts2  = aout*.18   ;.18
about1  = (p1=13? aouts2:aouts1) 
about2  = (p1=14? aouts2:aouts1)
 
        outs  about1,about2         ;13 out I;14 out II
;gabal1  = about1
;gabal2  = about2
        endin



;tar6.orc(from ar3; the old truncated swan)
instr 21,22
sr    = 44100
kr    =  1050
ksmps =  42
kcf   = cpspch(p5)                      ;kcf goes to kbw & 1st reson (arbas)
ifoct = octpch(p5)                      ;ifoct goes to icfs & icfa1 & im
icfs  = cpsoct(ifoct)                   ;center freq for oscili (ao) for bass boost
  as  init 1
  ks  init 1
  ax  init 1                            ;ival for alternate expseg branch (takes place of AA)
  kx  init 1
 ibq1 = 14.833
 ibq2 = 12.833
  ibq = (p5>12.03? ibq1:ibq2)
  ib  = ((ibq-ifoct)*.618034)*.38196      ;upper limit for filter deck; goes to icfa1
icfa1 = ifoct+ib                          ;goes to kcfa;adds the above to the cf
 kcfa = cpsoct(icfa1)                     ;goes to kbwa & 2nd reson (ares);1st filter above cf
icfb1 = ((icfa1-ifoct) * .618034) +icfa1  ;takes pos diff ;goes to kcfb
 kcfb = cpsoct(icfb1)                     ;goes to 3rd reson
icfc1 = ((icfb1-icfa1) * .618034) +icfb1
 kcfc = cpsoct(icfc1)                     ;goes to 4th reson                                  ;goes to 9th reson
icfd1 = ((icfc1-icfb1) * .618034) +icfc1
 kcfd = cpsoct(icfd1)
  idv =.008                               ;goes to kbw
  kbw = kcf*idv
  arj   expon .02378*p4,.0623*p6,p3       ;goes to kh only if cresc
 arjj   expon .095*p4,.0059*p6,p3         ;goes to kh only if dimin
   ah = (p6>p4? arj:arjj)
   kh   downsamp ah*.052                  ;goes to ktex to flucit
   im   init 0
  ipc = p5
          if ipc>6.09 igoto next   ;branch to incrementally boost the bass below 6.09
  im1 = (1/ifoct)*18
   im = im1
          igoto contin
next:im2 = ((1/ifoct)*.5)
   im    = im2                     ;im goes to oscili to boost bass below 6.09
          igoto contin
  kfi    = (kcf*.000411)*1/ifoct
contin:kbwa = ((kcfa-kcf)*kfi)     ;from here down to iamp1 come the bandwidths
kbwb2  = ((kcfb-kcfa) * kfi)       ;bws without kh are not fluctuators
kbwc   = ((kcfc-kcfb) * kfi)       ;(check)bws with kh are fluctuators
kbwd2  = ((kcfd-kcfc) * kfi)
iamp1  = ((p4*2400)+1)             ;goes to iampy,as, at(after next1), & at2
iamp2  = ((p6*2400)+1)             ;goes to iampy,iampz,as,& at
iamp3  = ((p10*2400)+1)            ;goes to iampz & as
iampy  = (p4>p6? iamp1:iamp2)      ;picks whichever is higher
iampz  = (p10<=0? iamp2:iamp3)     ;old ampLL,if p10 is 0 or neg, it takes the amp of p6, if p10 is pos int,it takes that val;goes to kt2 (after contin1)
iamph  = (p6<p10? iamp1:iamp3)     ;ival for ks expseg ????
 ites  = p3 *.38197                ;tes  ;goes to as
itess  = p3 *.618034               ;tess ;goes to as
  ipd  = p12                       ;p12 has 0 or 1; if 1 it has dim from peak in iamp2
       if ipd=0 igoto next1        ;if p12 is 1, it gets an explicit hairpin, by going to as/ks
   as  expseg iamp1, ites, iamp2, itess, iamp3                   ;goes to ax
   ks  expseg iamp1, ites, iamp2, itess, iamp3
   ax  = as                        ;as ax, expseg goes aenvl
   kx  = ks                        ;as kx, goes to kenvl
             igoto contin1
next1:at expon iamp1,iamp2,p3     ;gets sent to aenvl;cresc or dim from p4 to p6
      kt    expon iamp1,iamp2,p3
            igoto contin1
contin1:kt2 expon iamp1,iampz,p3  ;gets sent to ktex and on to rand and randi
 ktex    = kt2*kh                    ;goes to rand and on to randi via kram
 kdur    = p3                        ;goes to rand and on to randi
 kram    = kdur/ktex                 ;goes to randi
  kww    = 1/icfa1                   ;gets multiplied by kh and sent to ampr input of randi
kampr    = kww*kfi                   ;goes to randi
 isee    = .015                      ;seed val for randi
   ie    = p3*.00038197              ;a rise time for aenvl
   ig    = (p3-ie)*.618034           ;a decay time for aenvl
aenvl    envlpx ax+at,ie,p3,ig,21,32,.003819,.01                   ;-.01                       ;goes to rand

kenvl    envlpx kx+kt,ie,p3,ig,21,32,.006180,.01                   ;-.00618                                  ;goes to randi
   aq    = aenvl                     ;as aq, aenvl goes to rand (asig), this for souce rand input
   kq    = kenvl                     ;as kq, kenvl goes to rand (ksig), this for oscil1 input
  kap    randi kampr,kram,isee       ;goes to fluxing cfs in alternate resons
             if p1 =21 igoto next2
iseea    = -1
             igoto contin2
next2:iseea = -.015
contin2:asig rand aq,iseea        ;white noise source for all filters, sent to reson(arbas)
ksig2     downsamp asig
             if ksig2 = 0 kgoto next3
 ksig      rand kq,-1
             if ksig = 0 kgoto next4
next3:ksig2 = .002
asig1     upsamp ksig2
next4:ksig  = .01                                ;more explaining here
arba      reson asig+asig1,kcf,kbw+kap,p7,0
arbas     = arba* 3
 kvib     oscil  p5*.0618,p4,33
   ao     oscili arbas*im,icfs+kvib,15              ;bass booster;
   ap     oscili arbas*im,(icfs*2)+kvib,15          ;goes to aa
   aa     = ao+(ap*.381)                            ;goes to az & boosts fund
   k1     = ksig*.33333
 ide1     = p3*.985
ksig1     oscil1 ide1,k1,p3-(p3*.32),32
asig1     upsamp ksig1
  ar1     reson  asig+asig1,kcfa+kap,kbwa,p7,0      ;check cf & amps
 ar11     = ar1*.381966025
   k2     = ksig*.20601
 ide2     = p3*.975
;ksig2     oscil1 ide2,k2,p3-(p3*.025),32
;asig2     upsamp ksig2
  ar2     reson asig+asig1,kcfb+kap,kbwb2+kap,p7,0          ;check cf                       ;;;;kcfb+kap ?
 ar21     = ar2*.23606799
   k3     = ksig*.12732
 ide3     = p3*.96
;ksig3     oscil1 ide3,k3,p3-(p3*.04),32
;asig3     upsamp ksig3
  ar3     reson asig+asig1,kcfc+kap,kbwc,p7,0               ;check cf
 ar31     = ar3*.145898044
  az1     = (ar11+ar21+ar31)
   az     = az1+aa+arbas
 awad     balance az,asig
 astr     = awad*.059                   ; .059       ?.039
astr2     = awad*.314552                ; .474552  ?   (.094745552)                   ;(.0474552)?
adur2     = (p3<=.333333? astr2:astr)
 aout     = adur2*.015
aout1     = aout*0
aout2     = aout
abou1     = (p1=21? aout2:aout1)
abou2     = (p1=22? aout2:aout1)
              outs abou2,abou1
              endin


;tar6.orc(from ar3; new truncated swan)
instr    2,4,15,16
sr       =  44100
kr       =  1050
ksmps    =  42
kcf      = cpspch(p5)                       ;kcf goes to kbw & 1st reson (arbas)
ifoct    = octpch(p5)                       ;ifoct goes to icfs & icfa1 & im
icfs     = cpsoct(ifoct)                    ;center freq for oscili (ao) for bass boost
  as     init 1
  ks     init 1
  ax     init 1                             ;ival for alternate expseg branch (takes place of AA)
  kx     init 1
 ibq1    = 14.833
 ibq2    = 12.833
  ibq    = (p5>12.03? ibq1:ibq2)
  ib     = ((ibq-ifoct)*.618034)*.38196     ;upper limit for filter deck; goes to icfa1
icfa1    = ifoct+ib                         ;goes to kcfa;adds the above to the cf
 kcfa    = cpsoct(icfa1)                    ;goes to kbwa & 2nd reson (ares);1st filter above cf
icfb1    = ((icfa1-ifoct) * .618034) +icfa1  ; * .618034  ;takes pos diff ;goes to kcfb
 kcfb    = cpsoct(icfb1)                         ;goes to 3rd reson
icfc1    = ((icfb1-icfa1) * .618034) +icfb1  ; * .618034
 kcfc    = cpsoct(icfc1)                         ;goes to 4th reson                                  ;goes to 9th reson
icfd1    = ((icfc1-icfb1) * .618034) +icfc1  ; * .618034
 kcfd    = cpsoct(icfd1)
  idv    = .00008;1/icfs                     ;.00008    ;goes to kbw     ;.008  ;????????
  kbw    = kcf*idv
  arj    expon .02378*p4,.0623*p6,p3         ;goes to kh only if cresc
 arjj    expon .095*p4,.0059*p6,p3           ;goes to kh only if dimin
   ah    = (p6>p4? arj:arjj)
   kh    downsamp ah  ;;;;;*.052             ;goes to ktex to flucit
   im    init 0
  ipc    = p5
         if ipc>6.09 igoto next  ;branch to incrementally boost the bass below 6.09
  im1    = (1/ifoct)*18
   im    = im1
         igoto contin
next:im2 = ((1/ifoct)*.00005)
   im    = im2                   ;im goes to oscili to boost bass below 6.09
         igoto contin
contin:kfi = (kcf*.000411)*1/ifoct   ;extra 00 place here to cut bw 
kbwa     = ((kcfa-kcf)*kfi)          ;from here down to iamp1 come the bandwidths
kbwb2    = ((kcfb-kcfa) * kfi)       ;bws without kh are not fluctuators
kbwc     = ((kcfc-kcfb) * kfi)       ;(check)bws with kh are fluctuators
kbwd2    = ((kcfd-kcfc) * kfi)

iamp1    = ((p4*2400)+1)             
ispan1   = ((sqrt(iamp1))*21)        ;this group is for factoring the rampamps
ispan2   = (p8=1? ispan1:iamp1)      ;ispan2 is input amp for iamp1
iamp2    = (p6*2400)+1               ;inputamp 2
ispan3   = ((sqrt(iamp2))*21)
ispan4   = (p8=1? ispan3:iamp2)      ;ispan4 is input amp for iamp2
iamp3    = (p10*2400)+1          
ispan5   = ((sqrt(iamp3))*21)
ispan6   = (p8=1? ispan5:iamp3)      ;ispan6 is input amp for iamp3
iampz    = (p11=0? iamp2:iamp3)      ;old ampLL,if p11 is 0, it takes the amp of p6, if p10 is pos int,it takes that val;goes to kt2 (after contin1)
 ites    = p3 *.38197                ;tes  ;goes to as
itess    = p3 *.618034               ;tess ;goes to as


  ipd    = p12                       ;p12 has 0 or 1; if 1 it has dim from peak in iamp2
                                     ;?if p12 is 1, it gets an explicit hairpin, by going to as/ks
   as    expseg ispan2,ites,ispan4,itess,ispan6                   ;goes to ax
   ks    expseg ispan2,ites,ispan4,itess,ispan6
         
   at    expon ispan2,ispan6,p3      ;gets sent to aenvl;cresc or dim from p4 to p6;goes to ax
   kt    expon ispan2,ispan6,p3
         
  kt2    expon iamp1,iampz,p3        ;gets sent to ktex and on to rand and randi
   ax    = (ipd<1? at:as)            ;as ax, expseg goes aenvl
   kx    = (ipd<1? kt:ks)            ;as kx, goes to kenvl


 ktex    = kt2*kh                    ;goes to rand and on to randi via kram
 kdur    = p3                        ;goes to rand and on to randi
 kram    = kdur/ktex                 ;goes to randi
  kww    = 1/icfa1                   ;gets multiplied by kh and sent to ampr input of randi
kampr    = kww*kfi                   ;goes to randi
 isee    = p2*.00618       ;.015     ;seed val for randi
   ie1    = p3*.00038197 
   ie2    = (p3*.98)*p9 
   ie    = (p9>0? ie1:ie2)           ;a rise time for aenvl
   
   ig    = (p3-ie)*.618034           ;a decay time for aenvl
aenvl    envlpx ax,ie,p3,ig,21,32,.003819,.01                   ;goes to rand
kenvl    envlpx kx,ie,p3,ig,21,32,.006180,.01                   ; .00618                       ;goes to randi
   aq    = aenvl                     ;as aq, aenvl goes to rand (asig), this for souce rand input
   kq    = kenvl                     ;as kq, kenvl goes to rand (ksig), this for oscil1 input
  kap    randi kampr,kram,isee       ;goes to fluxing cfs in alternate resons
         if p1 = 2 igoto next2
iseea    = p2*(-.0038) ;-1
         igoto contin2
next2:iseea = p2*(-.015)
contin2:asig rand aq,iseea    ;white noise source for all filters, sent to reson(arbas)
ksig2    downsamp asig
         if ksig2 = 0 kgoto next3
 ksig    rand kq,-1
         if ksig = 0 kgoto next4
next3:ksig2 = .002
asig1    upsamp ksig2
next4:ksig = .01                                   ;more explaining here
arba     reson asig+asig1,kcf,kbw+kap,p7,0         ;
arbas    = arba*3
 kvib    oscili  kenvl*.000618,1/p5,33               ;
   ao    oscili  kvib+kap,icfs,15   ;bass booster;kvib+(arbas*.0000618),icfs*2,15 
   ap    oscili arbas+im,icfs+ao,15                ;goes to aa
   aa    = ap                                      ;goes to az & boosts fund

 kvic    oscil  p5*.0618,p4,33
  aov    oscili arbas*im,icfs+kvic,15              ;bass booster;
  aow    oscili arbas*im,(icfs*2)+kvic,15          ;
  aoy    = aov+(aow*.381)                          ;goes to az

   k1    = ksig*.33333
 ide1    = p3*.985
ksig1    oscil1 ide1,k1,p3-(p3*.0179),32
asig1    upsamp ksig1
  ar1    reson  asig+asig1,kcfa+kap,kbwa,p7,0      ;check cf & amps
 ar11    = ar1*.381966025
   k2    = ksig*.20601
 ide2    = p3*.975
;ksig2    oscil1 ide2,k2,p3-(p3*.0289),32
;asig2    upsamp ksig2
  ar2    reson asig+asig1,kcfb+kap,kbwb2+kap,p7,0  ;check cf                       ;;;;kcfb+kap ?
 ar21    = ar2*.23606799
   k3    = ksig*.12732
 ide3    = p3*.96
;ksig3    oscil1 ide3,k3,p3-(p3*.046),32
;asig3    upsamp ksig3
  ar3    reson asig+asig1,kcfc+kap,kbwc,p7,0       ;check cf
 ar31    = ar3*.145898044
  az1    = (ar11+ar21+ar31);+ar41)
   az    = az1+aoy+aa+arbas                        
 awad    balance az,asig
 astr    = awad*.009
astr2    = awad*.0474552
adur2    = (p3<=.333333? astr2:astr)
 igoo    = abs(p2)
 ida1    = 2
 ida2    = .4                                      ;.4 is norm
 idam    = (((igoo>=216.358608 && igoo<265.) && p1=2)? ida1:ida2) 
 aout    = adur2*idam;.4
aout1    = aout*0
aout2    = aout
abou1    = (p1=2? aout2:aout1)
abou2    = (p1=4? aout2:aout1)
abou3    = (p1=15? aout2:aout1)    
abou4    = (p1=16? aout2:aout1)
         outs abou2+abou4,abou1+abou3              ;2 out chii;4 out chi
         endin


;ar41.orc; The 1982 filter instrument called Swan now changed in funcs and envs
    instr 3,5,17,18

  itp = int(p5)
iqspt = frac(p5)
itran = p5               
ifact = p14               ;to trans down add -increment to itp, and put in .0 for frac? 
 itra = ((p13 = 1)? ((itp)+(iqspt+ifact)):itran)
 iinv = ((p11 = 1)? ((itp-p15)+(.12-iqspt)):itra);to trans inv at pch use -1,for oct low use -2, for oct abov use + 1, etc.
itrap = (((p13 = 1) && (p11 = 1))? (iinv+ifact):iinv)
iftra = itrap
ifoct = octpch(iftra)
   as init 1 
   ks init 1
   at init 1
   kt init 1
   ax init 1                            ;ival for alternate expseg branch (takes place of AA)                                                  ifoct = octpch(p5)
   ib = ((12.833-ifoct)*.618034)*.38196 ;upper limit for filter deck; goes to icfa1
 icfs = cpsoct(ifoct)                   ;center freq for oscili (ao) for bass boost
  kcf = cpspch(iftra)
icfa1 = ifoct+ib                        ;goes to kcfa;adds the above to the cf
 kcfa = cpsoct(icfa1)                   ;goes to kbwa & 2nd reson (ares);1st filter above cf
icfb1 = ((icfa1-ifoct) * .618034) +icfa1          ;takes pos diff ;goes to kcfb
 kcfb = cpsoct(icfb1)                             ;goes to 3rd reson
icfc1 = ((icfb1-icfa1) * .618034) +icfb1
 kcfc = cpsoct(icfc1)                             ;goes to 4th reson
icfd1 = ((icfc1-icfb1) * .618034) +icfc1
 kcfd = cpsoct(icfd1)                             ;goes to 5th reson
icfe1 = ((icfd1-icfc1) * .618034) +icfd1
 kcfe = cpsoct(icfe1)                             ;goes to 6th reson
icff1 = ((icfe1-icfd1) * .618034) +icfe1
 kcff = cpsoct(icff1)                             ;goes to 7th reson
icfg1 = ((icff1-icfe1) * .618034) +icff1
 kcfg = cpsoct(icfg1)                             ;goes to 8th reson
icfh1 = ((icfg1-icff1) * .618034) +icfg1
 kcfh = cpsoct(icfh1)                             ;goes to 9th reson
  idv =.008    ;goes to kbw
  kbw = kcf*idv
  arj expon .02378*p4,.0623*p6,p3    ;goes to kh only if cresc
 arjj expon .095*p4,.0059*p6,p3      ;goes to kh only if dimin                
   ah = (p6>p4? arj:arjj)      ;goes to kbwa to fluc bws & then to xamp of randi
  ah1 = ah*.381  
   kh downsamp ah1
   im init 0
  ipc = p5
      if ipc>6.09 igoto next1  ;branch to incrementally boost the bass below 6.09
  im1 = (1/ifoct)*18
   im = im1
      igoto contin
next1:im2 = ((1/ifoct)*.5)
     im = im2                  ;im goes to oscili to boost bass below 6.09
     igoto contin
contin:kfi =  (kcf*.000411)*1/ifoct ;factors for the bws;kfi is larger because it has fluc
kbwa  = ((kcfa-kcf)*kfi)            ;from here down to iamp1 come the bandwidths 
kbwb2 = ((kcfb-kcfa) * kfi)         ;bws without kh are not fluctuators
kbwc  = ((kcfc-kcfb) * kfi)         ;(check)bws with kh are fluctuators
kbwd2 = ((kcfd-kcfc) * kfi)
kbwe  = ((kcfe-kcfd) * kfi)
kbwf2 = ((kcff-kcfe) * kfi)
kbwg  = ((kcfg-kcff) * kfi)
kbwh2 = ((kcfh-kcfg) * kfi)
iamp1 = ((p4*2400)+1)             ;goes to iampy,as, at(after next1), & at2
iamp2 = ((p6*2400)+1)             ;goes to iampy,iampz,as,& at
iamp3 = ((p10*2400)+1)            ;goes to iampz & as
iampz    = (p11=0? iamp2:iamp3)   ;old ampLL,if p11 is 0, it takes the amp of p6, if p11 is pos int,it takes that val;goes to kt2 (after contin1)             
ispan1   = ((sqrt(iamp1))*21)     ;this group is for factoring the rampamps
ispan2   = (p8=1? ispan1:iamp1)   ;ispan2 is input amp for iamp1
ispan3   = ((sqrt(iamp2))*21)
ispan4   = (p8=1? ispan3:iamp2)   ;ispan4 is input amp for iamp2         
ispan5   = ((sqrt(iamp3))*21)
ispan6   = (p8=1? ispan5:iamp3)   ;ispan6 is input amp for iamp3

 ites = p3 *.6                    ;tes  ;goes to as
itess = p3 *.4                    ;tess ;goes to as
  ipd = p12                       ;p12 has 0 or 1; if 1 it has dim from peak in iamp2
      if ipd>0 goto next2         ;if p12 is 1, it gets an explicit hairpin, by going to as/ks
   as expseg ispan2, ites, ispan4, itess, ispan6                   ;goes to ax  
   ks expseg ispan2, ites, ispan4, itess, ispan6 
   ax = as                        ;as ax, expseg goes aenvl
   kx = ks                        ;as kx, goes to kenvl
      igoto contin1
next2:at expon ispan2,ispan6,p3   ;gets sent to aenvl;cresc or dim from p4 to p6
      kt expon ispan2,ispan6,p3
      goto contin2
contin1:kt2 expon iamp1,iampz,p3  ;gets sent to ktex and on to rand and randi
contin2:ktex = kt2*kh             ;goes to rand and on to randi
 kdur = p3                        ;goes to rand and on to randi
 kram = kdur/ktex                 ;goes to randi
  kww = 1/icfa1                   ;gets multiplied by kh and sent to ampr input of randi
kampr = kww*kfi                   ;goes to randi                       
isee  = .015                      ;seed val for randi
  ie1 = p3*.1
  ie2 = p3*.00038197
   ie = (p3<.5? ie1:ie2)          ;a rise time for aenvl
  ig1 = p3*.26
  ig2 = (p3-ie);*.618034
   ig = (p3<.5? ig1:ig2)          ;a decay time for aenvl 
  
aenvl envlpx ax+at,ie,p3,ig,17,.006,.01           ;goes to rand;   17,33         

kenvl envlpx kx+kt,ie,p3,ig,17,.006,.00618        ;goes to randi;  17,33
   aq = aenvl                     ;as aq, aenvl goes to rand (asig), this for souce rand input         
   kq = kenvl                     ;as kq, kenvl goes to rand (ksig), this for oscil1 input
  kap randi kampr,kram,isee       ;goes to fluxing cfs in alternate resons
      if (p2 > 3 || p2 > 5) igoto next3
iseea = -1
      igoto contin3
next3:iseea = -.015

contin3:asig rand aq,iseea        ;white noise source for all filters, sent to reson(arbas)
ksig2 downsamp asig
      if ksig2 = 0 kgoto next4
 ksig rand kq,-1
      if ksig = 0 kgoto next5
next4:ksig2 = .002
asig1 upsamp ksig2 
next5:ksig = .01                              ;more explaining here
arba  reson asig+asig1,kcf,kbw,p7,0
arbas = arba* 3
   ao oscili arbas*im,icfs,15                 ;bass booster;
   ap oscili arbas*im,icfs*2,15               ;goes to aa
   aa = ao+(ap*.381)                          ;check funcs
   k1 = ksig*.33333
 ide1 = p3*.985
ksig1 oscil1 ide1,k1,p3-(p3*.0179),33;.0179
asig1 upsamp ksig1
  ar1 reson  asig+asig1,kcfa,kbwa,p7,0        ;check cf & amps
   k2 = ksig*.20601
 ide2 = p3*.975
ksig2 oscil1 ide2,k2,p3-(p3*.0289),33
asig2 upsamp ksig2
  ar2 reson asig+asig1,kcfb+kap,kbwb2,p7,0    ;check cf
   k3 = ksig*.12732
 ide3 = p3*.96
ksig3 oscil1 ide3,k3,p3-(p3*.046),33
asig3 upsamp ksig3
  ar3 reson asig+asig1,kcfc,kbwc,p7,0         ;check cf
   k4 = ksig*.07868
 ide4 = p3*.92
ksig4 oscil1 ide4,k4,p3-(p3*.075),33
asig4 = ksig4
  ar4 reson asig+asig1,kcfd+kap,kbwd2,p7,0    ;check cf
   k5 = ksig*.04863
 ide5 = p3*.88
ksig5 oscil1 ide5,k5,p3-(p3*.12),33
asig5 upsamp ksig5
  ar5 reson asig+asig1,kcfe,kbwe,p7,0         ;check cf
   k6 = ksig*.03005 
 ide6 = p3*.8
ksig6 oscil1 ide6,k6,p3-(p3*.2),33
asig6 upsamp ksig6
  ar6 reson asig+asig6,kcff+kap,kbwf2,p7,0    ;check cf
   k7 = ksig*.01857
 ide7 = p3*.68
ksig7 oscil1 ide7,k7,p3-(p3*.32),33
asig7 upsamp ksig6
  ar7 reson asig+asig7,kcfg,kbwg,p7,0         ;check cf
   k8 = ksig*.01148
 ide8 = p3*.48
ksig8 oscil1 ide8,k8,p3-(p3*.52),33
asig8 upsamp ksig8
  ar8 reson asig+asig8,kcfh+kap,kbwh2,p7,0    ;check cf
  az1 = (ar8+ar7+ar6+ar5+ar4+ar3+ar2+ar1) *.618034   
   az = az1+aa+arbas      
 awad balance az,asig
anstr3= awad*.09        ;.009
anstr2= awad*.474552      ;.0474552
anstr1= awad*.065        ;.00065
adur2 = (p3>=2? anstr1:anstr3)
adur1 = (p3<=.5? anstr2:adur2)
adur  = adur1+adur2

aout  = ((((p2 > 58.8 && p2 < 59.8) && p1=5))? adur*.18:adur*.29)
aouta = ((  (p2 >= 116.5  && p2 < 123.) && p1=17  )?  adur*.1:aout)   

aout1    = aouta*0
aout2    = aouta*.85
 ;aout3    = (p8=1? aout2*100:aout2)
abou1    = (p1=3? aout2:aout1)
abou2    = (p1=5? aout2:aout1)
abou3    = (p1=17? aout2:aout1)    
abou4    = (p1=18? aout2:aout1)
 
 igoo    = abs(p2)
 ida1    = 0
 ida2    = 1               ;.4 is norm
 idam    =(((igoo>=57.2 && igoo<=61.)&& (p1=5))? ida1:ida2)
       ;above is a routine to isolate score segments for ampout 
       ;& channel change
 ida3    = 1.2
 ida4    = 1
 idam1   =(((igoo>=22. && igoo<=23.) && (p1=3 || p1=5))? ida3:ida4); 

aout  = ((((p2 > 58.8 && p2 < 59.) && p1=5))? adur*.08:adur*.29)

      outs ((abou1*.4)*idam1)+((abou2*.6)*idam1)+((abou3*.4)+(abou4*.6)),((abou1*.6)*idam1)+((abou2*idam)*idam1)+((abou3*.6)+(abou4*.4)) ;ch1=5&18, ch2=3&17     
      endin  



;fmvibin2;fmins has a vib/wobble that varies with the amp inputs; it´s from Talisman II

instr  7,10

iftra  = p5
isp1   = cpspch(iftra)              ;cps of p5; both modulator freq and carrier freq; i.e., for harm. spectrum
isp1.1 = (isp1/800)                 ;cps of p5/800; goes to isp2.3 if p5=10.00
isp2   = (isp1/10)                  ;cps of p5/10; goes to kvib; used when p5<9.00
isp2.1 = (isp1/1800)                ;cps of p5/1800; used when p5>9.00 
isp2.2 = (p5>9.00? isp2.1:isp2)     ;choice between when p5 is above or below 9.00
isp2.3 = (p5= 10.00? isp1.1:isp2.2) ;separates 10.00 from all other pitches
ifoct  = octpch(p5)                 ;linoct version of p5; goes to vibwid and rise
ifoct1 = (ifoct*.000001)            ;cuts vibwidth down for short notes
ifoct2 = (ifoct*.09)                ;(linoct * .02) gives proportional vibwidth; normal vibwidth
ifoct3 = (p3<=.19? ifoct1:ifoct2)   ;to narrow vibwidth for short notes
isp3   = cpsoct(ifoct3)             ;converts vibwidth calc to cps

iwiq   = p5+p9                      ;init code for low note envlp
       if iwiq<=7.07 igoto next     ;goes to cresc rise for low notes
ie     = (p3*(1/ifoct))             ;((reciprocal of linoct) * p3 (dur)); gives rise
ief    = (p3-ie)*.618034            ;takes (leftover part of p3)*.618, etc.
       igoto contin                 ;these for notes neither low nor short
       if p3>.2 igoto contin        ;goes to rise&dec for nonshort &nonlow notes
ie     = .0381966                   ;fastrise for short notes  ;.0381966
ief    = .0618034                   ;fastdec for short notes   ;.0618034
       igoto contin                 ;these for notes .2 of beat or smaller
next:ie = p3*.9381                  ;cresc rise for low notes
ief    = (p3-ie)                    ;short dec for low notes
ieg    = p3*(log(isp1))             ;rise for wobble factor
ieh    = (p3-ieg)*.618034           ;decay for wobble factor
contin:iamp1 = ((p4*2400)+1)        ;simple inputamp 1
iamp2  = ((p6*2400)+1)              ;simple inputamp 2
iamp3  = ((p10*2400)+1)             ;simple inputamp 3

ispan1   = ((sqrt(iamp1))*21)       ;this group is for factoring the rampamps
ispan2   = (p8=1? ispan1:iamp1)     ;ispan2 is sub input amp for iamp1
ispan3   = ((sqrt(iamp2))*21)
ispan4   = (p8=1? ispan3:iamp2)     ;ispan4 is sub input amp for iamp2         
ispan5   = ((sqrt(iamp3))*21)
ispan6   = (p8=1? ispan5:iamp3)     ;ispan6 is sub input amp for iamp3

ikong1 = (log(p4))+1                ;(log part of p4(ampfield)) + 1
ikong2 = p6+1                       ;    
ikong3 = p10+1                      ;     


   kt2 expon ispan1,ispan2,p3       ; 
  ktex = kt2            
  kdur = p3                       
  kram = kdur/ktex                
   kww = 1/ifoct   ;check               
 kampr = kww*isp1                 
 isee  = .015*p2                    ;

   kap randi kampr,kram,isee        ; kap is for adding some quasi random flucs to modulator


kamp   expseg ispan2,ie,ispan4,ief,ispan6                  ;1st exp curve for kenvl
kamp1  expseg ikong1,ie,ikong2,ief,ikong3                  ;2nd exp curve for kenv2
kenvl  envlpx kamp,ie,p3,ief,16,1,.0038,-1                 ;envl for carrier amp
kenv2  envlpx kamp1,ie,p3,ief,16,1,.0038                   ;envl to vary modulator freq
kvia   envlpx log(isp3*p3),ieg,p3,ieh,16,1,.0038  
kviba  oscil  kvia,(isp1+(kap*10)),1                       ;(isp1)*3 ;(isp2.3)*2;isp1
kvib   oscil  ((isp2.3+kvia)*(kenv2)),isp1+(isp2.3+kviba),1;2nd in kviamodamp has vibamp varied
akenvl envlpx kvib,ie,p3,ief,33,.6,.003819                 ;envl to vary carrier freq;try to add kvia
asig   oscili kenvl,(isp1+akenvl),1                        ;carrier has kenvl amp and cpsp5+akenvl freq.
astr   = asig*.38       ;.34
astr2  = asig*3.2         ;3.2      ;1.2
adur   = (p3<=.083? astr:astr2)     ;to get shortnote amps down
aouts1 = adur*0
aouts2 = adur
about1 = (p1=7? aouts2:aouts1)
about2 = (p1=10? aouts2:aouts1)
       outs  about1, about2         ;7 out 1; 10 out 2 
gabal3 = about1
gabal4 = about2
       endin


instr  26,27 ; replica of i07/i10;


iftra  = p5
isp1   = cpspch(iftra)              ;cps of p5; both modulator freq and carrier freq; i.e., for harm. spectrum
isp1.1 = (isp1/800)                 ;cps of p5/800; goes to isp2.3 if p5=10.00
isp2   = (isp1/10)                  ;cps of p5/10; goes to kvib; used when p5<9.00
isp2.1 = (isp1/1800)                ;cps of p5/1800; used when p5>9.00 
isp2.2 = (p5>9.00? isp2.1:isp2)     ;choice between when p5 is above or below 9.00
isp2.3 = (p5= 10.00? isp1.1:isp2.2) ;separates 10.00 from all other pitches
ifoct  = octpch(p5)                 ;linoct version of p5; goes to vibwid and rise
ifoct1 = (ifoct*.000001)            ;cuts vibwidth down for short notes
ifoct2 = (ifoct*.09)                ;(linoct * .02) gives proportional vibwidth; normal vibwidth
ifoct3 = (p3<=.19? ifoct1:ifoct2)   ;to narrow vibwidth for short notes
isp3   = cpsoct(ifoct3)             ;converts vibwidth calc to cps

iwiq   = p5+p9                      ;init code for low note envlp
       if iwiq<=7.07 igoto next     ;goes to cresc rise for low notes
ie     = (p3*(1/ifoct))             ;((reciprocal of linoct) * p3 (dur)); gives rise
ief    = (p3-ie)*.618034            ;takes (leftover part of p3)*.618, etc.
       igoto contin                 ;these for notes neither low nor short
       if p3>.2 igoto contin        ;goes to rise&dec for nonshort &nonlow notes
ie     = .0381966                   ;fastrise for short notes  ;.0381966
ief    = .0618034                   ;fastdec for short notes   ;.0618034
       igoto contin                 ;these for notes .2 of beat or smaller
next:ie = p3*.9381                  ;cresc rise for low notes
ief    = (p3-ie)                    ;short dec for low notes
ieg    = p3*(log(isp1))             ;rise for wobble factor
ieh    = (p3-ieg)*.618034           ;decay for wobble factor
contin:iamp1 = ((p4*2400)+1)        ;simple inputamp 1
iamp2  = ((p6*2400)+1)              ;simple inputamp 2
iamp3  = ((p10*2400)+1)             ;simple inputamp 3

ispan1   = ((sqrt(iamp1))*21)       ;this group is for factoring the rampamps
ispan2   = (p8=1? ispan1:iamp1)     ;ispan2 is sub input amp for iamp1
ispan3   = ((sqrt(iamp2))*21)
ispan4   = (p8=1? ispan3:iamp2)     ;ispan4 is sub input amp for iamp2         
ispan5   = ((sqrt(iamp3))*21)
ispan6   = (p8=1? ispan5:iamp3)     ;ispan6 is sun input amp for iamp3

ikong1 = (log(p4))+1                ;(log part of p4(ampfield)) + 1
ikong2 = p6+1                       ;    
ikong3 = p10+1                      ;     


   kt2 expon ispan1,ispan2,p3       ; 
  ktex = kt2            
  kdur = p3                       
  kram = kdur/ktex                
   kww = 1/ifoct   ;check               
 kampr = kww*isp1                 
 isee  = .015*p2                     

   kap randi kampr,kram,isee        ; kap is for adding some quasi random flucs to modulator


kamp   expseg ispan2,ie,ispan4,ief,ispan6                  ;1st exp curve for kenvl
kamp1  expseg ikong1,ie,ikong2,ief,ikong3                  ;2nd exp curve for kenv2
kenvl  envlpx kamp,ie,p3,ief,16,1,.0038,-1                 ;envl for carrier amp
kenv2  envlpx kamp1,ie,p3,ief,16,1,.0038                   ;envl to vary modulator freq
kvia   envlpx log(isp3*p3),ieg,p3,ieh,16,1,.0038  
kviba  oscil  kvia,(isp1+(kap*10)),1                       ;(isp1)*3 ;(isp2.3)*2;isp1
kvib   oscil  ((isp2.3+kvia)*(kenv2)),isp1+(isp2.3+kviba),1;2nd in kviamodamp has vibamp varied
akenvl envlpx kvib,ie,p3,ief,33,.6,.003819                 ;envl to vary carrier freq;try to add kvia
asig   oscili kenvl,(isp1+akenvl),1                        ;carrier has kenvl amp and cpsp5+akenvl freq.
astr    = asig*.38                                         ;.34
astr2   = asig*3.2                                         ;3.2 ;1.2
adur    = (p3<=.083? astr:astr2)                           ;to get shortnote amps down
aouts1  = adur*0
aouts2  = adur
about1  = (p1=26? aouts2:aouts1)    ;26 out 1; 27 out 2 
about2  = (p1=27? aouts2:aouts1)
        outs  about1, about2 
gabal1  = about1
gabal2  = about2
        endin

instr  24,25 ;a goofy double carrier and double modulator isntr
             ;works for some situations
iamp1  =(p4*1000)    ;amps are Nums in p4, p6, &p10 that
iamp2  =(p6*1000)    ;are factored up by 1000  
iamp3  =(p10*1000)   ;these give us 3 input amps seriatim
  ita  =(p3*.18)
 itas  =(p3-ita)
  ito  =(p3*.89)
 itos  =(p3-ito);(p3-itas)*.618
  ite  =(p3*.382966) ;frac of the dur p-field for amprise of note
 ites  =(p3-ite)     ;this takes the remainder of the above for 1st ampdecay of note
itest  =(p3-ites)*.618    ;ditto for 2nd ampdecay
 itq1  =(p3*.618)
 itq2  =(p3-itq1)
 itq3  =(p3-itq2)*.618
iqoct  = octpch(p5)  ;this converts octpch notation to linear octaves
 icqy  = cpspch(p5)  ;this converts octpch notation to cps
icqy1  =icqy*2
icqy2  =icqy*3
icqy3  =icqy*4
icqy4  =icqy*5
icqy5  =icqy*1.5     ;;6.5 is sweet
iqpit  =sqrt(iqoct)  ;this takes sqrt of iqoct to go to the final amp of kamp

ispan1 =(int(p4)+1)        
ispan2 =(int(p6)+1)
ispan3 =(int(p10)+1)

   kt2 expon ispan1,ispan3,p3 ;expseg ispan1,ite,ispan2,ites,ispan3 
  ktex = kt2            
  kdur = p3                       
  kram = kdur/ktex                
   kww = (exp(1/12))*((1/(int(p5)))*4)   ;check               
 kampr = kww*icqy                 
 isee  = .015*p2                     

   kap randi kampr,kram,isee 

 kamp  expseg iamp1,ite,iamp2,ites,iamp3,itest,iqpit ;this exponentiates thru 3 amp p-fields & 1/pitch-field
kenvl  envlpx kamp,ite,p3,itest,16,1,.002514,1 ;envlp for mod & car oscils
kenv2  envlpx kamp,itq1,p3,itq3,16,1,.003,1 ;envlp for mod & car oscils
 akod  oscili (log(kenv2))*400,icqy2+(kap*.05),1 ;ampin*400 best
akod1  oscili (log(kenv2))*400,icqy4+(kap*.05),1 
aknvl  envlpx akod,ita,p3,itas,16,1,.03,1
 amod  oscili (log(kenvl))*200,((icqy1+aknvl)+(kap*.05)),1 ;ampin*200 best
amod1  oscili (log(kenvl))*200,((icqy3+akod1)+(kap*.05)),1 
aqnvl  envlpx amod,ito,p3,itos,16,1,.00618034,1 
 acar  oscili kenvl,icqy+aqnvl,1 ; car oscil uses fund pitch(icqy) + mod oscil 
acar1  oscili kenvl,icqy5+amod1,1 
aenvl  envlpx acar1,ite,p3,itest,16,1,.00618034,1 
     
aouts1  = (acar+(aenvl*.618))*0
aouts2  = (acar+(aenvl*.618))*4
about1  = (p1=24? aouts2:aouts1) 
about2  = (p1=25? aouts2:aouts1)
 
        outs  about1,about2
;gabal1  = about1
;gabal2  = about2
        endin


instr   9 ;   an alpass reverberator
iexp1   = p3*.4
iexp2   = p3*.6

 ;kt      expon  iexp1,p3,iexp2
ktq     = p5        ;kt  ;alternative to envlp rev time

               ;asig  ktq=reverbtime p6=looptime
arev1   alpass gabal1,ktq*.618034,(1/p6),0;*p4 ;
arev2   alpass gabal2,ktq*.381966025,(1/p7),0;*p4;p6 is looptime for echo density
arev3   alpass gabal1,ktq*.23606799,(1/p8),0;*p4
arev4   alpass gabal2,ktq*.145898044,(1/p9),0;*p4
ar1     = arev1
ar2     = arev2
ar3     = arev3
ar4     = arev4
ar5     = (ar1+ar3)
ar6     = (ar2+ar4)
        outs ar5, ar6
        endin

           













