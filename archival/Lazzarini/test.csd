<CsoundSynthesizer>
<CsOptions>
csound -d ./temp.orc ./temp.sco
</CsOptions>
<CsInstruments>
sr=44100
ksmps=100
nchnls=2

gip init 100

FLpanel "demix", 400,220, 400,100
iv1 FLvalue  " ", 40,20,340 ,10
iv2 FLvalue  " ", 40,20,340 ,60
iv3 FLvalue  " ", 40,20,340 ,110
gk1, ih1 FLslider  "azimuth discrimination",-1,1,0,5,iv1,300,20,10,10
gk2, ih2 FLslider  "subspace width",1,gip,0,5,iv2,300,20,10,60
gk3, ih3 FLslider   "threshold",0,90,0,5,iv3,300,20,10,110
gk4, ih4 FLslider   "gain",0,2,0,5,-1,300,20,10,160
gk5, ih5 FLbutton   "bypass",0,1, 2, 64, 28, 330,160,-1

FLsetVal_i -0.75, ih1
FLsetVal_i 25, ih2
FLsetVal_i 0, ih3
FLsetVal_i 1.5, ih4
FLpanelEnd

; FLrun

instr 1

ifftsize = 2048
iwtype = 1    /* cleaner with hanning window */
kpos = gk1
kwidth = gk2

al,ar  diskin "C:\utah\home\mkg\projects\music\copyrighted\GardenOfAlgorithms\ChaoticSquares\ChaoticSquares.wav", 1, 0, 1
flc  pvsanal   al, ifftsize, ifftsize/4, ifftsize, iwtype
frc  pvsanal   ar, ifftsize, ifftsize/4, ifftsize, iwtype
fdm  pvsdemix  flc, frc, kpos, kwidth,gip /* mystery opcode */
fst  pvstencil fdm, 0, ampdb(gk3), 1
adm  pvsynth   fst
aout = adm*gk4*(gk5) + (al+ar)*0.5*(1-gk5)
        outs    aout,aout

endin
</CsInstruments>
<CsScore>
f1 0 1025 7  0.01 1024 1
i1 0 360



</CsScore>
</CsoundSynthesizer>
