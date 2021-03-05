<CsoundSynthesizer>
<CsOptions>
; The --displays option is required in order for the Pianoteq GUI to dispatch events and display properly.
csound -m3 --displays -odac temp.orc temp.sco
</CsOptions>
<CsInstruments>
/* orc */

sr = 44100
; My test computer does not have low-latency audio;
; for low latency, set ksmps to 15 or 20.
ksmps = 441
nchnls = 2
gihandle1 vstinit "C:\\Program Files\\Steinberg\\VstPlugins\\Pianoteq 3.0 Trial\\Pianoteq30 Trial.dll",1
vstinfo gihandle1
vstedit gihandle1

instr 1 ; Send notes to Pianoteq.
; Duration of notes in Csound is always in pfield 3 (p3).
; The instrument should be driven by the score.
vstnote gihandle1, 0, p4, p5, p3
endin

instr 2 ; Send parameter changes to Pianoteq.
; p4 is the parameter number, p5 is the parameter value.
print p4, p5
vstparamset gihandle1, p4, p5 
endin

instr 3 ; Receive audio from Pianoteq.
ain1 = 0
aoutleft, aoutright vstaudio gihandle1, ain1, ain1
; There is no reason not to send audio directly out here, 
; unless you are sending the audio to a buss for further processing
; before output.
outs aoutleft, aoutright
endin

</CsInstruments>
<CsScore>
; Turn on the instrument that receives audio from the Pianoteq indefinitely.
i 3 0 -1
; Send parameter changes to Pianoteq before sending any notes.
; NOTE: All parameters must be between 0.0 and 1.0.
; Length of strings:
i 2 0 1 33 0.5
; Hammer noise:
i 2 0 1 25 0.1
; Send a C major 7th arpeggio to the Pianoteq.
i 1 1 10 60 76
i 1 2 10 64 73
i 1 3 10 67 70 
i 1 4 10 71 67
; End the performance, leave some time for the Pianoteq to finish sending out its audio
; or for the user to play with the Pianoteq virtual keyboard.
e 20
</CsScore>
</CsoundSynthesizer>
