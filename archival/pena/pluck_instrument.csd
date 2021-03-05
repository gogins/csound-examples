<CsoundSynthesizer>
<CsOptions>
-odac -m0 -d
</CsOptions>

<CsInstruments>

;------------------------
;------------------------
; 2007 Luis Antunes Pena
;------------------------
;------------------------

  sr        =  44100
  ksmps     =  128
  nchnls    =  2

  gktime    init      1
  gkmeth    init      1
  gkrandicps   init   0
  garsend1  init      0
  garsend2  init      0

            FLpanel   "pluck", 550, 270, 500, 50

  idisp_v_slider1     FLvalue                     "amp", 45, 17, 38, 170
  gkamp, idisp_slider1  FLslider                  "", 1, 0.001,  -1, 24, idisp_v_slider1, 20, 150, 50, 10

  ixshift   =  60

  idisp_v_slider2     FLvalue                     "cps", 45, 17, 38+ixshift, 170
  gkcps, idisp_slider2  FLslider                  "", 40, 1000,  -1, 24, idisp_v_slider2, 20, 150, 50+ixshift, 10
  

  gkrand, idisp_rand  FLbutton                    "rand", 1, 0, 22, 55, 25,  35+ixshift, 205, -1
  gidisp_v_rand       FLvalue                     "r cps", 45, 17, 38+ixshift, 235


  idisp_v_slider3     FLvalue                     "icps", 45, 17, 38+ixshift*2, 170
  gkicps, idisp_slider3 FLslider                  "", 20, 10000,  -1, 24, idisp_v_slider3, 20, 150, 50+ixshift*2, 10

  gkrandicps, idisp_randicps  FLbutton            "rand", 1, 0, 22, 55, 25,  35+ixshift*2, 205, -1
  gidisp_v_randicps   FLvalue                     "r cps", 45, 17, 38+ixshift*2, 235

  gkmeth, idisp_counter FLcount                   "meth", 1, 6, 1, 2, 1, 100, 30, 38+ixshift*3, 50, -1

  idisp_v_slider4     FLvalue                     "time", 45, 17, 38+ixshift*5, 170
  gktime, idisp_slider4 FLslider                  "", 0.01, 3,  -1, 24, idisp_v_slider4, 20, 150, 50+ixshift*5, 10

  idisp_v_slider5     FLvalue                     "parm 1", 45, 17, 38+ixshift*6, 170
  gkparm1, idisp_slider5  FLslider                "", 0.001, 1,  0, 24, idisp_v_slider5, 20, 150, 50+ixshift*6, 10

  idisp_v_slider6     FLvalue                     "parm 2", 45, 17, 38+ixshift*7, 170
  gkparm2, idisp_slider6  FLslider                "", 0.001, 1,  0, 24, idisp_v_slider6, 20, 150, 50+ixshift*7, 10


  idisp_v_slider7     FLvalue                     "", 48, 17, 50+ixshift*5, 240
  gkrsend, idisp_slider7  FLslider                "rev send", 0.001, 1,  0, 3, idisp_v_slider7, 150, 20, 50+ixshift*5, 220


            FLpanelEnd  
            FLrun     


    instr 1


prints "%n---------------------------------%n------------P L U C K------------%n---- 2007 Luis Antunes Pena ----%n---------------------------------%n"

  kamp      =  gkamp * 10000
  kcps      =  gkcps

reset:

  icps      =  i(gkicps)
  ifn       =  0
  imeth     =  i(gkmeth)
  iparm1    =  i(gkparm1)            
  iparm2    =  i(gkparm2)            

  itime1     =  i(gktime) 
itime = itime1+ birnd(itime1*.05)
  gitime    =  itime

if imeth == 1 then
  iparm1    =  1
elseif    imeth == 2 then
  iparm1    =  1
elseif    imeth == 3 then
  iparm2    =  1
elseif    imeth == 4 then
  iparm2    =  1
elseif    imeth == 5 then
     if ((iparm1+iparm2) > 0.5) then
          iparm1    =  0.1
          iparm2    =  0.1
      endif
elseif    imeth == 6 then
  iparm2    =  1
endif

            ; random freq
if gkrand == 1 then
  irand_max =  i(kcps)
  kcps_r    randomh   20,       irand_max, 1/itime
  kcps_p    =  i(kcps_r)
            FLprintk2   kcps_p, gidisp_v_rand
elseif gkrand == 0 then
  kcps_p    =  kcps
            FLprintk2   kcps_p, gidisp_v_rand

endif

            ; random i freq
if gkrandicps == 0 goto noirand
irand:
  iricps_max   =      i (gkicps)
  kicps     randomh   20, iricps_max, 1/itime
  icps      =  i(kicps)
            goto      contirand

noirand:
  icps      =  i (gkicps)
  
contirand:

            FLprintk2   icps, gidisp_v_randicps


            timout    0, itime, continue
            reinit    reset

continue:

  a1        pluck     kamp, kcps_p, icps, ifn, imeth, iparm1, iparm2

            ; random pan
  ipan1     =  rnd (1)
  ipan2     =  1-ipan1

  aout1     =  a1 * ipan1
  aout2     =  a1 * ipan2


            outs      aout1, aout2

            ; reverb send
irrand =  int(rnd  (2))   
  garsend1  =  aout1 * gkrsend * irrand
  garsend2  =  aout2 * gkrsend * irrand


            rireturn  

    endin

    instr 2
; kout trigger ksig, kthreshold, kmode
; schedwhen ktrigger, kinsnum, kwhen, kdur [, ip4] [, ip5] [...]
; schedkwhen ktrigger, kmintim, kmaxnum, kinsnum, kwhen, kdur
  idur      =  0.1
  iwhen     =  0

  kout1a     trigger   gkmeth, 0.5, 0
            schedkwhen  kout1a, 0, 1, 11, iwhen, idur
  kout1b     trigger   gkmeth, 1.5, 1
            schedkwhen  kout1b, 0, 1, 11, iwhen, idur

  kout2a    trigger   gkmeth, 1.5, 0
            schedkwhen  kout2a, 0, 1,  12, iwhen, idur
  kout2b    trigger   gkmeth, 2.5, 1
            schedkwhen  kout2b, 0, 1,  12, iwhen, idur

  kout3a    trigger   gkmeth, 2.5, 0
            schedkwhen  kout3a, 0, 1,  13, iwhen, idur
  kout3b    trigger   gkmeth, 3.5, 1
            schedkwhen  kout3b, 0, 1,  13, iwhen, idur

  kout4a    trigger   gkmeth, 3.5, 0
            schedkwhen  kout4a, 0, 1,  14, iwhen, idur
  kout4b    trigger   gkmeth, 4.5, 1
            schedkwhen  kout4b, 0, 1,  14, iwhen, idur

  kout5a    trigger   gkmeth, 4.5, 0
            schedkwhen  kout5a, 0, 1,  15, iwhen, idur
  kout5b    trigger   gkmeth, 5.5, 1
            schedkwhen  kout5b, 0, 1,  15, iwhen, idur

  kout6a     trigger   gkmeth, 5.5, 0
            schedkwhen  kout6a, 0, 1,  16, iwhen, idur


    endin


    instr 11
            prints    "%n---------%nsimple averaging%nignore iparm 1 and 2%n---------%n" 
    endin


    instr 12
            prints    "%n---------%nstretched averaging%nparm 1 set to 1 / ignore parm 2%n---------%n"
    endin


    instr 13
             prints    "%n---------%nsimple drum%nparm1: roughness factor%n---------%n"
    endin


    instr 14
            prints    "%n---------%nstretched drum%nparm1: roughness factor / parm2: strech factor set to 1%n---------%n"
    endin


    instr 15
            prints    "%n---------%nweighted averaging%nparm1: roughness factor / parm2: strech factor set to 1%n(iparm1 + iparm2must be <= 1)%n---------%n"
    endin


    instr 16
            prints    "%n---------%n1st order recursive filter, with coefs .5. Unaffected by parameter values.%n---------%n"
    endin



    instr 99

  kfblvl    randomh   0.5, 0.95, 1/gitime
  ifco      =  sr/2
  ar1, ar2  reverbsc  garsend1, garsend2, kfblvl, ifco

            outs      ar1, ar2

  garsend1  =  0
  garsend2  =  0


    endin
</CsInstruments>

<CsScore>
i1  0  600
i2  0  600
i99 0  600

</CsScore>
</CsoundSynthesizer>
