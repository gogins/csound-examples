<CsoundSynthesizer>
<CsOptions>
; realtime:
;-+rtaudio=jack -d -m0 -g -f -odac:alsa_pcm:playback_ -M0 -b128 --expression-opt temp.orc temp.sco
; offline render:
-d -m0 -g -o p04-080517.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 64.0
nchnls = 2 

zakinit 4, 4

massign 1, 0
gkchLayer1 init 0
gkchLayer1 chnexport "chLayer1",2 ; 
gkchLayer2 init 0
gkchLayer2 chnexport "chLayer2",2 ; 
gkchLayer3 init 0
gkchLayer3 chnexport "chLayer3",2 ; 
gkchLayer4 init 0
gkchLayer4 chnexport "chLayer4",2 ; 

gkchrms300 chnexport "CHRMS300",2 ; RMS 
gkch300_1 chnexport "CH300_1",2 
gkch300_2 chnexport "CH300_2",2 
gkch300_3 chnexport "CH300_3",2 
gkch300_4 chnexport "CH300_4",2 
gkch300_5 chnexport "CH300_5",2 
gkch300_6 chnexport "CH300_6",2 
gkch300_7 chnexport "CH300_7",2 
gkch300_8 chnexport "CH300_8",2 

gkchvol300 chnexport "CHVOL300",2 ; VOL Eno 


gkchrms301 chnexport "CHRMS301",2 ; RMS 
gkch301_1 chnexport "CH301_1",2 
gkch301_2 chnexport "CH301_2",2 
gkch301_3 chnexport "CH301_3",2 
gkch301_4 chnexport "CH301_4",2 
gkch301_5 chnexport "CH301_5",2 
gkch301_6 chnexport "CH301_6",2 
gkch301_7 chnexport "CH301_7",2 
gkch301_8 chnexport "CH301_8",2 

gkchvol301 chnexport "CHVOL301",2 ; VOL Eno 


gkchrms302 chnexport "CHRMS302",2 ; RMS 
gkch302_1 chnexport "CH302_1",2 
gkch302_2 chnexport "CH302_2",2 
gkch302_3 chnexport "CH302_3",2 
gkch302_4 chnexport "CH302_4",2 
gkch302_5 chnexport "CH302_5",2 
gkch302_6 chnexport "CH302_6",2 
gkch302_7 chnexport "CH302_7",2 
gkch302_8 chnexport "CH302_8",2 

gkchvol302 chnexport "CHVOL302",2 ; VOL Eno 


gkchrms303 chnexport "CHRMS303",2 ; RMS 
gkch303_1 chnexport "CH303_1",2 
gkch303_2 chnexport "CH303_2",2 
gkch303_3 chnexport "CH303_3",2 
gkch303_4 chnexport "CH303_4",2 
gkch303_5 chnexport "CH303_5",2 
gkch303_6 chnexport "CH303_6",2 
gkch303_7 chnexport "CH303_7",2 
gkch303_8 chnexport "CH303_8",2 

gkchvol303 chnexport "CHVOL303",2 ; VOL Eno 


opcode hpkcEnv, k, iki
iamp, klength, ifn xin
ktrigger metro klength
reset:
if (ktrigger < 1) goto contin
reinit reset
contin:
kenv poscil3 iamp, klength, ifn
rireturn
xout kenv
endop

opcode hpkcEnvSeq, aa, kii
klength, ifn1, ifn2 xin
ktrigger metro klength
reset:
if (ktrigger < 1) goto contin
reinit reset
contin:
aenv1 poscil3 1, klength, ifn1
aenv2 poscil3 1, klength, ifn2
rireturn
xout aenv1, aenv2
endop

opcode hpkcPluck, a, kkii
klength, kpitch, icps, imode xin
ktrigger metro klength
reset:
if (ktrigger < 1) goto contin
reinit reset
contin:
apluck pluck 1, kpitch, icps, 0, imode
rireturn
xout apluck
endop

opcode hpkcSeq4, kk, kkkkkkkkk
kfreq, kval1, kamp1, kval2, kamp2, kval3, kamp3, kval4, kamp4 xin
kstep lfo 1, kfreq, 3
klaststep  init  0
kclock     init  0
if (kclock == 1) then
  kval = kval1
  kamp = kamp1
elseif (kclock == 2) then
  kval = kval2
  kamp = kamp2
elseif (kclock == 3) then
  kval = kval3
  kamp = kamp3
elseif (kclock == 4) then
  kval = kval4
  kamp = kamp4
endif
if (klaststep == 0 && kstep == 1) then
  kclock = kclock + 1
endif
if (kclock == 5) then
  kclock = 1
endif
klaststep = kstep
kpo = cpspch(kval)
xout kpo, kamp
endop

opcode hpkcSeq12, kk, kkkkkkkkkkkkkkkkkkkkkkkkk
kfreq, kval1, kamp1, kval2, kamp2, kval3, kamp3, kval4, kamp4, kval5, kamp5, kval6, kamp6, kval7, kamp7, kval8, kamp8, kval9, kamp9, kval10, kamp10, kval11, kamp11, kval12, kamp12 xin
kstep lfo 1, kfreq, 3
klaststep  init  0
kclock     init  0
if (kclock == 1) then
  kval = kval1
  kamp = kamp1
elseif (kclock == 2) then
  kval = kval2
  kamp = kamp2
elseif (kclock == 3) then
  kval = kval3
  kamp = kamp3
elseif (kclock == 4) then
  kval = kval4
  kamp = kamp4
elseif (kclock == 5) then
  kval = kval5
  kamp = kamp5
elseif (kclock == 6) then
  kval = kval6
  kamp = kamp6
elseif (kclock == 7) then
  kval = kval7
  kamp = kamp7
elseif (kclock == 8) then
  kval = kval8
  kamp = kamp8
elseif (kclock == 9) then
  kval = kval9
  kamp = kamp9
elseif (kclock == 10) then
  kval = kval10
  kamp = kamp10
elseif (kclock == 11) then
  kval = kval11
  kamp = kamp11
elseif (kclock == 12) then
  kval = kval12
  kamp = kamp12
endif
if (klaststep == 0 && kstep == 1) then
  kclock = kclock + 1
endif
if (kclock == 13) then
  kclock = 1
endif
klaststep = kstep
kpo = cpspch(kval)
xout kpo, kamp
endop

opcode hpkWildGrain, a, akkkkiiii
  setksmps 1
asig, kfreq,kpitch,kgrsize,kprate,ifun1,ifun2,ienv,iolaps xin
kwp init 0
awp = kwp
ilen = ftlen(ifun1)
kcrx table kwp, ifun2
asig = asig*kcrx+asig*(kcrx-1)
tablew asig, awp, ifun1
ar  syncgrain 1, kfreq, kpitch, kgrsize, kprate, ifun1, ienv, iolaps
amix = ar
kwp = kwp + 1
if kwp > ilen then
kwp = 0
endif
xout amix
endop



instr 300
gkchLayer1 linseg 0.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,0.0,60.0,0

gkch300_1 loopseg 1.0,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch300_2 loopseg 1.0,0 , 0.0,0.0, 0.155,0.9962, 0.845,0.0
gkch300_3 loopseg 0.0167,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch300_4 loopseg 0.0167,0 , 0.0,0.0, 0.155,0.9962, 0.845,0.0
gkch300_5 loopseg 0.05,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch300_6 loopseg 0.05,0 , 0.0,0.0, 0.3575,0.0802, 0.1425,1.0, 0.18,0.084, 0.32,0.0
gkch300_7 loopseg 0.05,0 , 0.0,0.0, 0.185,0.0687, 0.315,1.0, 0.3025,0.1565, 0.1975,0.0
gkch300_8 loopseg 0.05,0 , 0.0,0.0, 0.155,0.9962, 0.845,0.0
if gkchLayer1 == 0 goto noplay
kfseq_1 = 0.01
kfseqvar_1 = 1.5
kbaseA_1 = gkch300_5 * 1.888020945868151+5.836892393112391
kbaseB_1 = gkch300_6 * 1.453993142220301+6.021354209662728
kbaseC_1 = gkch300_7 * 1.5407987029498713+7.507899437156617
krandr_1 = gkch300_4 * 12.118332710961463+11.881667289038537
kpitch1A_1 = 0.7981643080359531
kamp1A_1 = 1.0
kpitch1B_1 = 3.5504581027435416
kamp1B_1 = 1.0
kpitch1C_1 = 5.807339014403765
kamp1C_1 = 1.0
kpitch2A_1 = 0.6055037424064214
kamp2A_1 = 1.0
kpitch2B_1 = 3.7431186683730724
kamp2B_1 = 1.0
kpitch2C_1 = 7.568807043016621
kamp2C_1 = 1.0
kpitch3A_1 = 0.3027514249885872
kamp3A_1 = 1.0
kpitch3B_1 = 8.256880491693519
kamp3B_1 = 1.0
kpitch3C_1 = 10.541284341300816
kamp3C_1 = 1.0
kpitch4A_1 = 3.49541222684939
kamp4A_1 = 1.0
kpitch4B_1 = 8.393258834664806
kamp4B_1 = 1.0
kpitch4C_1 = 0.27522848704151137
kamp4C_1 = 1.0
ifenv_1 ftgen 0, 0, 8192, 7, 0, 2788, 1, 1487, 0.332568788406033, 3917, 0
ifenvf_1 ftgen 0, 0, 8192, 7, 0, 3028, 1, 1480, 0.2362385161265557, 3684, 0
kdrywet_1 = gkch300_3 * 0.3493923819365201+0.36685760353484687
kfseq randomi kfseq_1, kfseqvar_1 * kfseq_1, .31
aenv, aenvf hpkcEnvSeq kfseq, ifenv_1, ifenvf_1
kenv  downsamp aenv
kenvf downsamp aenvf
kbasea = int(kbaseA_1)
kbaseb = int(kbaseB_1)
kbasec = int(kbaseC_1)
kgate metro kfseq
krand exprand krandr_1
krand limit krand, 0, krandr_1
kpr samphold  krand, kgate
kpri = int(kpr) * 0.01
kbasea = kbasea + kpri
kbaseb = kbasea + kpri
kbasec = kbasec + kpri
kvar1a = kbasea + int(kpitch1A_1) * 0.01
kvar1b = kbaseb + int(kpitch1B_1) * 0.01
kvar1c = kbasec + int(kpitch1C_1) * 0.01
kvar2a = kbasea + int(kpitch2A_1) * 0.01
kvar2b = kbaseb + int(kpitch2B_1) * 0.01
kvar2c = kbasec + int(kpitch2C_1) * 0.01
kvar3a = kbasea + int(kpitch3A_1) * 0.01
kvar3b = kbaseb + int(kpitch3B_1) * 0.01
kvar3c = kbasec + int(kpitch3C_1) * 0.01
kvar4a = kbasea + int(kpitch4A_1) * 0.01
kvar4b = kbaseb + int(kpitch4B_1) * 0.01
kvar4c = kbasec + int(kpitch4C_1) * 0.01
kpitchA, kampA hpkcSeq4 kfseq, kvar1a, kamp1A_1, kvar2a, kamp2A_1, kvar3a, kamp3A_1, kvar4a, kamp4A_1
kpitchB, kampB hpkcSeq4 kfseq, kvar1b, kamp1B_1, kvar2b, kamp2B_1, kvar3b, kamp3B_1, kvar4b, kamp4B_1
kpitchC, kampC hpkcSeq4 kfseq, kvar1c, kamp1C_1, kvar2c, kamp2C_1, kvar3c, kamp3C_1, kvar4c, kamp4C_1
asigel = 0
asiger = 0
asigelsum = 0
asigersum = 0
kpluckfv_1 = gkch300_4 * 8.029514367485245+4.802083261931922
kjit_1 = 0.0
kjits_1 = 10.0
kfj jitter kjit_1, 3, kjits_1
kpan_1 = gkch300_3 * 0.8203125488944382+0.09142361298410433
kpan_1 limit kpan_1, 0, 1
an1 hpkcPluck kfseq, kpitchA + kfj + kpluckfv_1, 440.0, 1
an2 hpkcPluck kfseq, kpitchB + kfj + kpluckfv_1, 440.0, 1
an3 hpkcPluck kfseq, kpitchC + kfj + kpluckfv_1, 440.0, 1
am sum an1*kampA, an2*kampB, an3*kampC
aom  = am * aenv * 0.333333
aom = aom * 1.0
asigel, asiger pan2 aom, kpan_1, 1
asigelg = asigel
asigerg = asiger
kwgc_1 = gkch300_4 * 1215.2778502139824+1469.8611248119007
kwgfreq_1 = gkch300_5 * 75.34722671326695+58.35902906279598
kwgfee_1 = gkch300_8 * 0.023479167529692258+0.8
asigel wguide1 asigel, kwgfreq_1, kwgc_1, kwgfee_1
asiger wguide1 asiger, kwgfreq_1, kwgc_1, kwgfee_1
asigel = asigel * kdrywet_1 + asigelg * (1-kdrywet_1)
asiger = asiger * kdrywet_1 + asigerg * (1-kdrywet_1)
kampout = gkchLayer1 * 0.7546296701019256
asigMixL = asigel * kampout
asigMixR = asiger * kampout
kampreverb = gkchLayer1 * 0.7121335561435539
asigMixLReverb = asigel * kampreverb
asigMixRReverb = asiger * kampreverb
zawm asigMixLReverb, 1
zawm asigMixRReverb, 2
zawm asigMixL, 3
zawm asigMixR, 4
krms rms (asigMixL + asigMixLReverb + asigMixR + asigMixRReverb) * 22502.51782255662
krms portk krms, 0.5
gkchrms300 = krms / 4687.499575316922
noplay:
endin

instr 301
gkchLayer2 linseg 0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,1.0,10.0,0.0,10.0,0.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,0.0,40.0,0.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,0.0,120.0,0

gkch301_1 loopseg 1.0,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch301_2 loopseg 1.0,0 , 0.0,0.0, 0.155,0.9962, 0.845,0.0
gkch301_3 loopseg 0.05,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch301_4 loopseg 0.05,0 , 0.0,0.0, 0.3575,0.0802, 0.1425,1.0, 0.18,0.084, 0.32,0.0
gkch301_5 loopseg 0.05,0 , 0.0,0.0, 0.185,0.0687, 0.315,1.0, 0.3025,0.1565, 0.1975,0.0
gkch301_6 loopseg 0.0167,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch301_7 loopseg 0.0167,0 , 0.0,0.0, 0.3575,0.0802, 0.1425,1.0, 0.18,0.084, 0.32,0.0
gkch301_8 loopseg 0.0167,0 , 0.0,0.0, 0.185,0.0687, 0.315,1.0, 0.3025,0.1565, 0.1975,0.0
if gkchLayer2 == 0 goto noplay
kfseq_1 = 0.01
kfseqvar_1 = gkch301_6 * 0.5+1.0
kbaseA_1 = gkch301_6 * 2.2082467766220084+6.791753561137664
kbaseB_1 = gkch301_7 * 1.9748265065977222+5.880295173477176
kbaseC_1 = gkch301_8 * 1.5625000931322637+7.7140626438893465
krandr_1 = gkch301_6 * 12.343750735744877+6.82958365457755
kpitch1A_1 = 22.526300670058333
kamp1A_1 = 1.0
kpitch1B_1 = 14.957492734612465
kamp1B_1 = 1.0
kpitch1C_1 = 8.119382407426446
kamp1C_1 = 1.0
kpitch2A_1 = 20.003364691576373
kamp2A_1 = 1.0
kpitch2B_1 = 6.581460931395651
kamp2B_1 = 1.0
kpitch2C_1 = 10.141854485494338
kamp2C_1 = 1.0
kpitch3A_1 = 7.4494385315664555
kamp3A_1 = 1.0
kpitch3B_1 = 6.0126406594390565
kamp3B_1 = 1.0
kpitch3C_1 = 13.160856507511676
kamp3C_1 = 1.0
kpitch4A_1 = 5.561797925369755
kamp4A_1 = 1.0
kpitch4B_1 = 18.359633675292677
kamp4B_1 = 1.0
kpitch4C_1 = 7.234550873271743
kamp4C_1 = 1.0
ifenv_1 ftgen 0, 0, 8192, 7, 0, 329, 1, 3931, 0.5, 3932, 0
ifenvf_1 ftgen 0, 0, 8192, 7, 0, 442, 1, 3875, 0.5, 3875, 0
kdrywet_1 = 0.9859551139483519
kfseq randomi kfseq_1, kfseqvar_1 * kfseq_1, .31
aenv, aenvf hpkcEnvSeq kfseq, ifenv_1, ifenvf_1
kenv  downsamp aenv
kenvf downsamp aenvf
kbasea = int(kbaseA_1)
kbaseb = int(kbaseB_1)
kbasec = int(kbaseC_1)
kgate metro kfseq
krand weibull krandr_1 , 1
krand limit krand, 0, krandr_1
kpr samphold  krand, kgate
kpri = int(kpr) * 0.01
kbasea = kbasea + kpri
kbaseb = kbasea + kpri
kbasec = kbasec + kpri
kvar1a = kbasea + int(kpitch1A_1) * 0.01
kvar1b = kbaseb + int(kpitch1B_1) * 0.01
kvar1c = kbasec + int(kpitch1C_1) * 0.01
kvar2a = kbasea + int(kpitch2A_1) * 0.01
kvar2b = kbaseb + int(kpitch2B_1) * 0.01
kvar2c = kbasec + int(kpitch2C_1) * 0.01
kvar3a = kbasea + int(kpitch3A_1) * 0.01
kvar3b = kbaseb + int(kpitch3B_1) * 0.01
kvar3c = kbasec + int(kpitch3C_1) * 0.01
kvar4a = kbasea + int(kpitch4A_1) * 0.01
kvar4b = kbaseb + int(kpitch4B_1) * 0.01
kvar4c = kbasec + int(kpitch4C_1) * 0.01
kpitchA, kampA hpkcSeq4 kfseq, kvar1a, kamp1A_1, kvar2a, kamp2A_1, kvar3a, kamp3A_1, kvar4a, kamp4A_1
kpitchB, kampB hpkcSeq4 kfseq, kvar1b, kamp1B_1, kvar2b, kamp2B_1, kvar3b, kamp3B_1, kvar4b, kamp4B_1
kpitchC, kampC hpkcSeq4 kfseq, kvar1c, kamp1C_1, kvar2c, kamp2C_1, kvar3c, kamp3C_1, kvar4c, kamp4C_1
asigel = 0
asiger = 0
asigelsum = 0
asigersum = 0
kcar_1 = 1.0
kmod_1 = 1.0
kind_1 = gkch301_6 * 5.101448149568727+0.1
kjit_1 = 0.0
kjits_1 = 10.0
kfj jitter kjit_1, 3, kjits_1
kpan_1 = gkch301_1 * 0.38845488426482666+0.32145834891746516
kpan_1 limit kpan_1, 0, 1
afm1 foscili kampA, kpitchA + kfj, kcar_1, kmod_1, kind_1, 10
afm2 foscili kampB, kpitchB + kfj, kcar_1, kmod_1, kind_1, 10
afm3 foscili kampC, kpitchC + kfj, kcar_1, kmod_1, kind_1, 10
aom = aenv * (afm1+afm2+afm3) * .33333333333
aom = aom * 1.0
asigel, asiger pan2 aom, kpan_1, 1
asigelg = asigel
asigerg = asiger
kbaseshift_1 = gkch301_6 * 221.1805687389447+65.43125155158353
kmodshift_1 = gkch301_7 * 98.74132532988597+188.94098169584294
kmodfreqshift_1 = gkch301_8 * 3.028531359346593+0.1
kshift_1 hpkcEnv 1, kmodfreqshift_1, 20
kshift_1 =  kshift_1 * kmodshift_1 + kbaseshift_1
kbaselowfreq_1 = gkch301_3 * 1602.6910677500541+834.3896146251519
kmodlowfreq_1 = gkch301_4 * 944.0104729340746+1108.159770392299
kmodfreqlowfreq_1 = gkch301_5 * 7.586528851116761+12.41347114888324
klowfreq_1 hpkcEnv 1, kmodfreqlowfreq_1, 20
klowfreq_1 =  klowfreq_1 * kmodlowfreq_1 + kbaselowfreq_1
fsigl_1 pvsanal asigel, 4096, 1024.0, 4096, 0
ftpsl_1 pvshift fsigl_1, kshift_1, klowfreq_1, 0
asigel  pvsynth   ftpsl_1
fsigr_1 pvsanal  asiger, 4096, 1024.0, 4096, 0
ftpsr_1 pvshift fsigr_1, kshift_1, klowfreq_1,0
asiger pvsynth ftpsr_1
asigel = asigel * kdrywet_1 + asigelg * (1-kdrywet_1)
asiger = asiger * kdrywet_1 + asigerg * (1-kdrywet_1)
kampout = gkchLayer2 * 0.39166661931408964
asigMixL = asigel * kampout
asigMixR = asiger * kampout
kampreverb = gkchLayer2 * 0.4333333386315251
asigMixLReverb = asigel * kampreverb
asigMixRReverb = asiger * kampreverb
zawm asigMixLReverb, 1
zawm asigMixRReverb, 2
zawm asigMixL, 3
zawm asigMixR, 4
krms rms (asigMixL + asigMixLReverb + asigMixR + asigMixRReverb) * 22502.51782255662
krms portk krms, 0.5
gkchrms301 = krms / 1999.9996821085751
noplay:
endin

instr 302
gkchLayer3 linseg 0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,1.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,70.0,0

gkch302_1 loopseg 0.4686,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch302_2 loopseg 0.2412,0 , 0.0,0.0, 0.155,0.9962, 0.845,0.0
gkch302_3 loopseg 0.05,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch302_4 loopseg 0.05,0 , 0.0,0.0, 0.3575,0.0802, 0.1425,1.0, 0.18,0.084, 0.32,0.0
gkch302_5 loopseg 0.05,0 , 0.0,0.0, 0.185,0.0687, 0.315,1.0, 0.3025,0.1565, 0.1975,0.0
gkch302_6 loopseg 0.0167,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch302_7 loopseg 0.0167,0 , 0.0,0.0, 0.155,0.9962, 0.845,0.0
gkch302_8 loopseg 0.0167,0 , 0.0,0.0, 0.155,0.9962, 0.3225,0.1183, 0.5225,0.0
if gkchLayer3 == 0 goto noplay
kfseq_1 = 0.06499911264535196
kfseqvar_1 = 1.5
kbaseA_1 = gkch302_1 * 1.519097312767478+5.337760418917362
kbaseB_1 = gkch302_1 * 1.649305653861835+6.650694524952111
kbaseC_1 = gkch302_1 * 1.3454861913083391+8.137239752446
krandr_1 = gkch302_1 * 24.0
kpitch1A_1 = 2.7303370160747056
kamp1A_1 = 1.0
kpitch1B_1 = 19.12415972937812
kamp1B_1 = 1.0
kpitch1C_1 = 9.64403665871865
kamp1C_1 = 1.0
kpitch2A_1 = 5.08988777382058
kamp2A_1 = 1.0
kpitch2B_1 = 16.4100922373748
kamp2B_1 = 1.0
kpitch2C_1 = 5.123595641788379
kamp2C_1 = 1.0
kpitch3A_1 = 11.555351793932253
kamp3A_1 = 1.0
kpitch3B_1 = 2.393258336396723
kamp3B_1 = 1.0
kpitch3C_1 = 7.280899191727466
kamp3C_1 = 1.0
kpitch4A_1 = 13.8107036534843
kamp4A_1 = 1.0
kpitch4B_1 = 8.393258834664806
kamp4B_1 = 1.0
kpitch4C_1 = 2.2247189965577308
kamp4C_1 = 1.0
ifenv_1 ftgen 0, 0, 8192, 7, 0, 2788, 1, 2702, 0.5, 2702, 0
ifenvf_1 ftgen 0, 0, 8192, 7, 0, 3028, 1, 2582, 0.5, 2582, 0
kdrywet_1 = gkch302_6 * 0.17361112145914048+0.8052256852191761
kfseq randomi kfseq_1, kfseqvar_1 * kfseq_1, .31
aenv, aenvf hpkcEnvSeq kfseq, ifenv_1, ifenvf_1
kenv  downsamp aenv
kenvf downsamp aenvf
kbasea = int(kbaseA_1)
kbaseb = int(kbaseB_1)
kbasec = int(kbaseC_1)
kgate metro kfseq
krand exprand krandr_1
krand limit krand, 0, krandr_1
kpr samphold  krand, kgate
kpri = int(kpr) * 0.01
kbasea = kbasea + kpri
kbaseb = kbasea + kpri
kbasec = kbasec + kpri
kvar1a = kbasea + int(kpitch1A_1) * 0.01
kvar1b = kbaseb + int(kpitch1B_1) * 0.01
kvar1c = kbasec + int(kpitch1C_1) * 0.01
kvar2a = kbasea + int(kpitch2A_1) * 0.01
kvar2b = kbaseb + int(kpitch2B_1) * 0.01
kvar2c = kbasec + int(kpitch2C_1) * 0.01
kvar3a = kbasea + int(kpitch3A_1) * 0.01
kvar3b = kbaseb + int(kpitch3B_1) * 0.01
kvar3c = kbasec + int(kpitch3C_1) * 0.01
kvar4a = kbasea + int(kpitch4A_1) * 0.01
kvar4b = kbaseb + int(kpitch4B_1) * 0.01
kvar4c = kbasec + int(kpitch4C_1) * 0.01
kpitchA, kampA hpkcSeq4 kfseq, kvar1a, kamp1A_1, kvar2a, kamp2A_1, kvar3a, kamp3A_1, kvar4a, kamp4A_1
kpitchB, kampB hpkcSeq4 kfseq, kvar1b, kamp1B_1, kvar2b, kamp2B_1, kvar3b, kamp3B_1, kvar4b, kamp4B_1
kpitchC, kampC hpkcSeq4 kfseq, kvar1c, kamp1C_1, kvar2c, kamp2C_1, kvar3c, kamp3C_1, kvar4c, kamp4C_1
asigel = 0
asiger = 0
asigelsum = 0
asigersum = 0
kmoogf_2 = gkch302_5 * 1230.4688233416578+669.8906373912474
kmfres_2 = gkch302_7 * 0.08222569684208272+0.1
kmoogfb_2 = 500.0
kjit_2 = 2.0
kjits_2 = 10.0
kfj jitter kjit_2, 3, kjits_2
kpan_2 = gkch302_8 * 0.39279516230130473+0.06538194476523337
kpan_2 limit kpan_2, 0, 1
an1 vco2 kampA, kpitchA + kfj, 0, .5
an2 vco2 kampB, kpitchB + kfj, 0, .5
an3 vco2 kampC, kpitchC + kfj, 0, .5
am = aenv * (an1+an2+an3) * .333333333333333
aom moogladder am, kmoogfb_2 + kmoogf_2 * kenvf, kmfres_2
aom = aom * 1.0
asigel, asiger pan2 aom, kpan_2, 1
asigelsum = asigelsum + asigel * 1.0
asigersum = asigersum + asiger * 1.0
kbasemoogf_3 = 1000.0
kmodmoogf_3 = 1655.9632844108583
kmodfreqmoogf_3 = 0.373851752628239
kmoogf_3 hpkcEnv 1, kmodfreqmoogf_3, 13
kmoogf_3 =  kmoogf_3 * kmodmoogf_3 + kbasemoogf_3
kmfres_3 = 0.3
kmoogfb_3 = 500.0
kjit_3 = 2.0
kjits_3 = 10.0
kfj jitter kjit_3, 3, kjits_3
kpan_3 = gkch302_7 * 0.418836830520176+0.44949655099358116
kpan_3 limit kpan_3, 0, 1
an1 vco2 kampA, kpitchA + kfj, 0, .5
an2 vco2 kampB, kpitchB + kfj, 0, .5
an3 vco2 kampC, kpitchC + kfj, 0, .5
am = aenv * (an1+an2+an3) * .333333333333333
aom moogladder am, kmoogfb_3 + kmoogf_3 * kenvf, kmfres_3
aom = aom * 1.0
asigel, asiger pan2 aom, kpan_3, 1
asigelsum = asigelsum + asigel * 1.0
asigersum = asigersum + asiger * 1.0
asigel = asigelsum / 2
asiger = asigersum / 2
asigelg = asigel
asigerg = asiger
kmgfc_1 = gkch302_7 * 2344.546979340731+100.0
kmgfr_1 = gkch302_4 * 0.1196354202212146
kmgfcenv_1 = gkch302_8 * 1107.263937363196+100.0
kmgfc_1 = kenvf * kmgfcenv_1 + kmgfc_1
kmgfrenv_1 = gkch302_5 * 0.1196354202212146
kmgfr_1 = kenvf * kmgfrenv_1 + kmgfr_1
kmgfr_1 limit kmgfr_1, 0, .99
denorm asigel, asiger
asigel moogladder asigel, kmgfc_1, kmgfr_1
asiger moogladder asiger, kmgfc_1, kmgfr_1
asigel = asigel * kdrywet_1 + asigelg * (1-kdrywet_1)
asiger = asiger * kdrywet_1 + asigerg * (1-kdrywet_1)
kampout = gkchLayer3 * 0.7546296701019256
asigMixL = asigel * kampout
asigMixR = asiger * kampout
kampreverb = gkchLayer3 * 0.7121335561435539
asigMixLReverb = asigel * kampreverb
asigMixRReverb = asiger * kampreverb
zawm asigMixLReverb, 1
zawm asigMixRReverb, 2
zawm asigMixL, 3
zawm asigMixR, 4
krms rms (asigMixL + asigMixLReverb + asigMixR + asigMixRReverb) * 22502.51782255662
krms portk krms, 0.5
gkchrms302 = krms / 3374.9996274709847
noplay:
endin

instr 303
gkchLayer4 linseg 0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,1.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,1.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,0.0,10.0,1.0,10.0,1.0,10.0,0.0,10.0,0.0,60.0,0

gkch303_1 loopseg 1.0,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch303_2 loopseg 1.0,0 , 0.0,0.0, 0.155,0.9962, 0.845,0.0
gkch303_3 loopseg 0.05,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch303_4 loopseg 0.0499,0 , 0.0,0.0, 0.3575,0.0802, 0.1425,1.0, 0.18,0.084, 0.32,0.0
gkch303_5 loopseg 0.05,0 , 0.0,0.0, 0.185,0.0687, 0.315,1.0, 0.3025,0.1565, 0.1975,0.0
gkch303_6 loopseg 0.0167,0 , 0.0,0.0, 0.5,1.0, 0.5,0.0
gkch303_7 loopseg 0.0167,0 , 0.0,0.0, 0.155,0.9962, 0.845,0.0
gkch303_8 loopseg 0.0167,0 , 0.0,0.0, 0.155,0.9962, 0.3225,0.1183, 0.5225,0.0
if gkchLayer4 == 0 goto noplay
kfseq_1 = 0.01
kfseqvar_1 = 1.5
kbaseA_1 = gkch303_6 * 2.5065105660663365+6.585590354404935
kbaseB_1 = gkch303_7 * 2.0616320673272917+6.900260512049625
kbaseC_1 = gkch303_8 * 1.7469619096825992+7.06302093841757
krandr_1 = gkch303_5 * 11.354167343427775+5.735833589384968
kpitch1A_1 = 2.7303370160747056
kamp1A_1 = 1.0
kpitch1B_1 = 11.096636161480985
kamp1B_1 = 1.0
kpitch1C_1 = 17.633333923911508
kamp1C_1 = 1.0
kpitch2A_1 = 5.08988777382058
kamp2A_1 = 1.0
kpitch2B_1 = 7.17977558782407
kamp2B_1 = 1.0
kpitch2C_1 = 15.339755761655187
kamp2C_1 = 1.0
kpitch3A_1 = 7.4494385315664555
kamp3A_1 = 1.0
kpitch3B_1 = 11.593578096636522
kamp3B_1 = 1.0
kpitch3C_1 = 7.280899191727466
kamp3C_1 = 1.0
kpitch4A_1 = 14.766361221091104
kamp4A_1 = 1.0
kpitch4B_1 = 8.393258834664806
kamp4B_1 = 1.0
kpitch4C_1 = 2.2247189965577308
kamp4C_1 = 1.0
ifenv_1 ftgen 0, 0, 8192, 7, 0, 2788, 1, 1214, 0.35550456752019427, 4190, 0
ifenvf_1 ftgen 0, 0, 8192, 7, 0, 3028, 1, 1480, 0.2568807173293008, 3684, 0
kdrywet_1 = 1.0
kfseq randomi kfseq_1, kfseqvar_1 * kfseq_1, .31
aenv, aenvf hpkcEnvSeq kfseq, ifenv_1, ifenvf_1
kenv  downsamp aenv
kenvf downsamp aenvf
kbasea = int(kbaseA_1)
kbaseb = int(kbaseB_1)
kbasec = int(kbaseC_1)
kgate metro kfseq
krand weibull krandr_1 , 1
krand limit krand, 0, krandr_1
kpr samphold  krand, kgate
kpri = int(kpr) * 0.01
kbasea = kbasea + kpri
kbaseb = kbasea + kpri
kbasec = kbasec + kpri
kvar1a = kbasea + int(kpitch1A_1) * 0.01
kvar1b = kbaseb + int(kpitch1B_1) * 0.01
kvar1c = kbasec + int(kpitch1C_1) * 0.01
kvar2a = kbasea + int(kpitch2A_1) * 0.01
kvar2b = kbaseb + int(kpitch2B_1) * 0.01
kvar2c = kbasec + int(kpitch2C_1) * 0.01
kvar3a = kbasea + int(kpitch3A_1) * 0.01
kvar3b = kbaseb + int(kpitch3B_1) * 0.01
kvar3c = kbasec + int(kpitch3C_1) * 0.01
kvar4a = kbasea + int(kpitch4A_1) * 0.01
kvar4b = kbaseb + int(kpitch4B_1) * 0.01
kvar4c = kbasec + int(kpitch4C_1) * 0.01
kpitchA, kampA hpkcSeq4 kfseq, kvar1a, kamp1A_1, kvar2a, kamp2A_1, kvar3a, kamp3A_1, kvar4a, kamp4A_1
kpitchB, kampB hpkcSeq4 kfseq, kvar1b, kamp1B_1, kvar2b, kamp2B_1, kvar3b, kamp3B_1, kvar4b, kamp4B_1
kpitchC, kampC hpkcSeq4 kfseq, kvar1c, kamp1C_1, kvar2c, kamp2C_1, kvar3c, kamp3C_1, kvar4c, kamp4C_1
asigel = 0
asiger = 0
asigelsum = 0
asigersum = 0
kmoogf_2 = 783.0273601746011
kmfres_2 = gkch303_5 * 0.12476042159957215+0.1
kmoogfb_2 = gkch303_4 * 1552.5174536483614+856.3524581139094
kjit_2 = 2.0
kjits_2 = 10.0
kfj jitter kjit_2, 3, kjits_2
kpan_2 = gkch303_6 * 0.31250001862645227+0.5731944750332189
kpan_2 limit kpan_2, 0, 1
an1 vco2 kampA, kpitchA + kfj, 0, .5
an2 vco2 kampB, kpitchB + kfj, 0, .5
an3 vco2 kampC, kpitchC + kfj, 0, .5
am = aenv * (an1+an2+an3) * .333333333333333
aom moogladder am, kmoogfb_2 + kmoogf_2 * kenvf, kmfres_2
aom = aom * 1.0
asigel, asiger pan2 aom, kpan_2, 1
asigelsum = asigelsum + asigel * 1.0
asigersum = asigersum + asiger * 1.0
kbasemoogf_3 = gkch303_7 * 714.8437926080096+664.031262042002
kmodmoogf_3 = 348.62373192475354
kmodfreqmoogf_3 = 0.373851752628239
kmoogf_3 hpkcEnv 1, kmodfreqmoogf_3, 20
kmoogf_3 =  kmoogf_3 * kmodmoogf_3 + kbasemoogf_3
kmfres_3 = gkch303_6 * 0.12000868770863071+0.5331371760913702
kmoogfb_3 = gkch303_8 * 1626.9532219739688+1685.7795908849514
kjit_3 = 2.0
kjits_3 = 10.0
kfj jitter kjit_3, 3, kjits_3
kpan_3 = gkch303_6 * 0.40581599641074073+0.05887152771051542
kpan_3 limit kpan_3, 0, 1
an1 vco2 kampA, kpitchA + kfj, 0, .5
an2 vco2 kampB, kpitchB + kfj, 0, .5
an3 vco2 kampC, kpitchC + kfj, 0, .5
am = aenv * (an1+an2+an3) * .333333333333333
aom moogladder am, kmoogfb_3 + kmoogf_3 * kenvf, kmfres_3
aom = aom * 1.0
asigel, asiger pan2 aom, kpan_3, 1
asigelsum = asigelsum + asigel * 1.0
asigersum = asigersum + asiger * 1.0
asigel = asigelsum / 2
asiger = asigersum / 2
asigelg = asigel
asigerg = asiger
kwgc_1 = gkch303_8 * 1585.6943148457276+3414.3056851542724
kbasewgfreq_1 = gkch303_7 * 89.93056091583468+75.37291896579175
kmodwgfreq_1 = 73.6697246221448
kmodfreqwgfreq_1 = 1.0
kwgfreq_1 randomi kbasewgfreq_1, kmodwgfreq_1 + kbasewgfreq_1, kmodfreqwgfreq_1
kwgfee_1 = gkch303_6 * 0.01566666706403097+0.8
asigel wguide1 asigel, kwgfreq_1, kwgc_1, kwgfee_1
asiger wguide1 asiger, kwgfreq_1, kwgc_1, kwgfee_1
kbasechodepth_2 = gkch303_6 * 1.8945313629228702+4.244687661211945
kmodchodepth_2 = 5.830275093502744
kmodfreqchodepth_2 = 2.938943993721498
kchodepth_2 hpkcEnv 1, kmodfreqchodepth_2, 20
kchodepth_2 =  kchodepth_2 * kmodchodepth_2 + kbasechodepth_2
kchorate_2 = gkch303_3 * 0.816406298661609+4.356656468311336
kchodepth_2 = kchodepth_2 * 0.0001
amodL osciliktp kchorate_2, 10, 0
amodL		=		(((amodL*kchodepth_2)+kchodepth_2)*.5)+.01
amodR osciliktp kchorate_2, 10, 0.15
amodR		=		(((amodR*kchodepth_2)+kchodepth_2)*.5)+.01
abufferL	delayr	1.2
adelsigL 	deltap3	amodL
		delayw	asigel
abufferR	delayr	1.2
adelsigR 	deltap3	amodR
		delayw	asiger
asigel = adelsigL
asiger = adelsigR
asigel = asigel * kdrywet_1 + asigelg * (1-kdrywet_1)
asiger = asiger * kdrywet_1 + asigerg * (1-kdrywet_1)
kampout = gkchLayer4 * 0.5749999692042683
asigMixL = asigel * kampout
asigMixR = asiger * kampout
kampreverb = gkchLayer4 * 0.2755556367944758
asigMixLReverb = asigel * kampreverb
asigMixRReverb = asiger * kampreverb
zawm asigMixLReverb, 1
zawm asigMixRReverb, 2
zawm asigMixL, 3
zawm asigMixR, 4
krms rms (asigMixL + asigMixLReverb + asigMixR + asigMixRReverb) * 22502.51782255662
krms portk krms, 0.5
gkchrms303 = krms / 4937.4995653828155
noplay:
endin

instr 400
asigl zar 1
asigr zar 2
denorm asigl, asigr
ao1, ao2 reverbsc	asigl, asigr, 0.9224999927481018, 8000
zawm ao1, 3
zawm ao2, 4
zacl 0, 2
endin

instr 401
asigl zar 3
asigr zar 4
asigld dcblock asigl
asigrd dcblock asigr
asigl = asigld * 22502.51782255662
asigr = asigrd * 22502.51782255662
asiglo clip asigl, 2, 32000
asigro clip asigr, 2, 32000
outs asiglo, asigro
zacl 2, 4
endin


</CsInstruments>

<CsScore>
f1 0 4096 7 0 512.0 1.0 512.0 0.0
f2 0 4096 7 0 368.64 0.084 143.35999999999999 1.0 512.0 0.0
f3 0 4096 7 0 366.08000000000004 0.0802 145.92 1.0 184.32 0.084 327.68 0.0
f4 0 4096 7 0 158.72 0.9962 865.28 0.0
f5 0 4096 7 0 158.72 0.9962 330.24000000000007 0.1183 535.04 0.0
f6 0 4096 7 0 125.44000000000001 0.9618 386.56 1.0 427.5200000000001 0.9427 84.47999999999993 0.0
f7 0 4096 7 0 125.44000000000001 0.9618 386.56 1.0 186.88000000000002 0.2939 325.12 0.0
f8 0 4096 7 0 189.44 0.0687 322.56 1.0 309.76000000000005 0.1565 202.23999999999995 0.0
f10 0 65536 10 1
f11 0 131072 19 1 1 270 1
f12 0 4096 6 0 64 1 448 0
f13 0 4096 6 0 128 1 384 0
f14 0 8192 5 1 1024 100 7168 1
f15 0 8192 5 1 2048 100 6144 1
f16 0 8192 5 1 6144 100 2048 1
f17 0 8192 5 1 1024 100 1024 50 6144 1
f18 0 8192 5 1 2048 100 1024 50 5120 1
f19 0 8192 5 1 3072 100 1024 50 4096 1
f20 0 8192 5 1 4096 100 1024 50 3072 1
f21 0 8192 19 1 1 270 1
f22 0 16384 19 1 1 260 1
i300 0 240.0
i301 0 240.0
i302 0 240.0
i303 0 240.0
i400 0 240.0
i401 0 240.0
</CsScore>

</CsoundSynthesizer>
