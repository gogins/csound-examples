<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;sr = 44100
;kr = 44100
ksmps = 1

sr = 96000
kr = 96000
; oversampling makes the filter response more reliable

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 1; 24 dB LPF with resonance. Can self-oscillate !
; loosely based on some papers by Stilson & Smith (CCRMA)
; coded by Josep M Comajuncosas / jan98
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

aout init 0
iamp = 10000; intended maximum amplitude
kfreq = 100
ifco = p4; keep it well below sr/4 or less


kenv linen 1, .05, p3, p3-.25
kres = kenv*3.9; resonance (0,4)
;4 for self-oscillation, but be careful
kfco = kfreq + ifco*kenv; filter cutoff frequency

kfcn = kfco/sr; frequency normalized (0, 1/4)
kcorr =1-4*kfcn; some empyrical tuning...
kres = kres/kcorr; more feedback for higher frequencies
;this is to compensate for the worse efficiency of the filter at high kfco
;(phase resp. at kfco goes from pi/4 at ~ 0 Hz to 0 at sr/4 for a 1st order IIR LPF)
;this also makes impossible to use frequencies above sr/4

asig buzz 1,kfreq,sr/(2*kfreq),1; sound source

arez = asig - kres*aout; inverted feedback to the filter
; as ph. resp. of a 4 stage LPF at kfco is 180 but  at DC & sr/2 = 0
; inverting it in the feedback loop causes the filter to emphasize kfco ("corner peaking")
alpf tone arez, kfco; 4 cascaded 1st order IIR LPF
alpf tone alpf, kfco 
alpf tone alpf, kfco
aout tone alpf, kfco

out aout*iamp*kcorr*20; a minimum equalisation
; 20 is empyrical, you may have to remove it for other sound sources
; but even thus the amplitude obviously increases with kfco.
endin

</CsInstruments>
<CsScore>
f1 0  32769 10 1
i1 0 3 380
i1 3 . 570
i1 6 . 1067
i1 9 . 2473
i1 12 . 5062
i1 15 . 7041
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
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
