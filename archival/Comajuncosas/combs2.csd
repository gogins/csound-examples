<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1

; Assortment of Analog-like filters
; coded by Josep M Comajuncosas dec./jan98
; send comments to gelida@intercom.es


instr 1; noisy wave to test the filters
kamp linen 1, .02, p3, .01
gkfreq linseg 100, p3/2, 2000, p3/2, 100

anoise rand 1
gasig = anoise*kamp
endin


instr 2; Resonant LPF
; 24 dB LPB -> reson at fco
; works great with white noise

kres line 0, p3, 1
kres = gkfreq*(1-kres)

alpf tone gasig, gkfreq
alpf tone alpf, gkfreq
alpf tone alpf, gkfreq
alpf tone alpf, gkfreq
ares reson alpf, gkfreq, kres, 2

out ares*5000
endin

instr 3; comb filter with reson at fco

iminfreq = 20; lowest expected comb frequency
anoize init 0
kres line 0, p3, .85; careful!

adel delayr 1/iminfreq
acomb0 deltapi 1/(2*gkfreq)

arez reson acomb0, gkfreq, (1-kres)*gkfreq, 1
afeed = (gasig-arez)
delayw afeed

aout balance arez, gasig
out aout*5000
endin	



instr 4; low pass comb filter

iminfreq = 20; lowest expected comb frequency
kres line 0, p3, .85

adel delayr 1/iminfreq
acomb0 deltapi 1/(2*gkfreq)

alpf tone acomb0, gkfreq
afeed = gasig - alpf*kres 
delayw afeed

out afeed*5000
endin	

</CsInstruments>
<CsScore>
f1 0 8193 10 1
i1 0 10
i2 0 10
s
i1 0 10
i3 0 10
s
i1 0 10
i4 0 10
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
 <height>4</height>
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
