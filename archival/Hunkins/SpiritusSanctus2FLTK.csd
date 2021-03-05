; SPIRITUS SANCTUS 2 (2013) for realtime Csound5/6 - by Arthur B. Hunkins
;  requires MIDI device with 8 knobs/sliders
;  version with FLTK GUI

<CsoundSynthesizer>
<CsOptions>

; for Windows, Mac
-odac -M0  -m0d --expression-opt -b128 -B2048 -+raw_controller_mode=1
; for Linux
;-odac -+rtaudio=alsa -+rtmidi=alsa -M hw:1,0 -m0d --expression-opt -b128 -B2048 -+raw_controller_mode=1

</CsOptions>
<CsInstruments>

sr	=	44100
ksmps	=	100
nchnls  =       2   

        FLpanel "Spiritus Sanctus 2 {2013} for Csound5/6 - Arthur B. Hunkins", 413, 115, 100, 100
gkchan,i0	FLcount	"MIDI Channel #  0=CC7, channels 1-8", 0, 16, 1, 1, 2, 140, 30, 52, 20, -1
	FLsetVal_i	1, i0
gkcont,i1	FLcount	"1st Controller # (of 8)", 0, 120, 1, 10, 1, 140, 30, 222, 20, -1
	FLsetVal_i	20, i1
i2      FLbox   "Zero controllers, set counters above, then adjust controllers", 1, 1, 14, 380, 20, 15, 84
        FLpanelEnd      
        FLrun

        instr 1
   
kstart  changed  gkchan, gkcont       
	if kstart == 1 then
        event    "i", -2, 0, 0
        event    "i", -3, 0, 0
        event    "i", 2, 0, -1, gkchan, gkcont
        event    "i", 3, 0, -1, gkchan, gkcont
	endif
         
        endin

        instr 2
   
gkamp	ctrl7    (p4 == 0? 1: p4), (p4 == 0? 7: p5), 0, 1
gkamp   tab      gkamp * 511, 2
gkamp   =        gkamp * 12000
gkamp   port     gkamp, .1
kmul    ctrl7    (p4 == 0? 2: p4), (p4 == 0? 7: p5 + 1), 0, .82
knh     ctrl7    (p4 == 0? 3: p4), (p4 == 0? 7: p5 + 2), 4, 20
knh     port     knh, .1
gklh    ctrl7    (p4 == 0? 4: p4), (p4 == 0? 7: p5 + 3), 4, 10.1
gkamp2  ctrl7    (p4 == 0? 8: p4), (p4 == 0? 7: p5 + 7), 0, .6
kamp2   rspline  -gkamp2, gkamp2, .6 * gklh, gklh
kamp2   port     kamp2, .01 
aout    gbuzz    gkamp + (kamp2 * gkamp), 200, knh, gklh, kmul, 1
        outs     aout, aout * .7
        
        endin
        
        instr 3
   
kmul    ctrl7    (p4 == 0? 5: p4), (p4 == 0? 7: p5 + 4), 0, .82
knh     ctrl7    (p4 == 0? 6: p4), (p4 == 0? 7: p5 + 5), 4, 20
knh     port     knh, .1
kfreq   ctrl7    (p4 == 0? 7: p4), (p4 == 0? 7: p5 + 6), 0, .15
kfreq   port     kfreq, .01 
kamp2   rspline  -gkamp2, gkamp2, .6 * gklh, gklh
kamp2   port     kamp2, .01 
aout    gbuzz    gkamp + (kamp2 * gkamp), 200.05 + kfreq, knh, gklh, kmul, 1
        outs     aout * .7, aout
        
        endin
                
</CsInstruments>
<CsScore>

f1 0 16384 11 16 1 .012
f2 0 512 16 0 512 .8 1

i1 0 3600
i2 0 -1
i3 0 -1
e

</CsScore>
</CsoundSynthesizer> 