<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1

instr 1; PWM and Saw to Ramp mod. for control signals
; coded by Josep M Comajuncosas / Aug96

iamp = 10000
ilfoamp = 2000
iamp = iamp - ilfoamp

;pitch and wave shape control
klfofreq linseg 3, .7*p3, 10, .3*p3, 5
kratio line  .01, p3,  .99

cycle:					

idur   = i(1/klfofreq)
iratio = i(kratio)
irise =  idur * iratio

	timout 0, idur, shape
	reinit cycle

shape:

if p4 = 1 goto s2t; Ramp/Saw mod.
if p4 = 2 goto vwp; Pulse Width mod.

s2t:
kshape linseg -1, irise, 1, idur-irise, -1;saw or triangle
goto contin

vwp:
kshape linseg  1, irise, 1, 1/sr, -1, idur-irise, -1;variable width pulse
goto contin


contin:
	rireturn
kamp linen iamp, .1, p3, .2;		      amplitude envelope
asig oscili kamp+kshape*ilfoamp, 110, 1

	out asig

endin

</CsInstruments>
<CsScore>
f1 0 65537 10 1; asine wave

t 0 30

; p4 = 1 for Ramp/Saw
; p4 = 2 for PWM
i1 0  10 1
i1 10 10 2
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
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
