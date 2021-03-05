sr = 44100          ; audio sampling rate is 44.1kHz
kr = 882            ; control rate is 882 Hz
ksmps = 50          ; number of samples in a control period (sr/kr)
nchnls = 2          ; number of channels of audio output

        instr   1
idb =   p5/127 * 90                                 ; rescale MIDI velocity to 90db
iamp    =   ampdb(idb)
ipitch  =   (p4+32)/12                              ; convert Midi notenum to pitch 
kctrl   linseg  0, p3/3, iamp, p3/3, iamp, p3/3, 0  ; amplitude envelope (double length & slow attack)
afund   oscil   kctrl, cpsoct(ipitch), 1            ; audio oscillator
acel1   oscil   kctrl, cpsoct(ipitch - .008), 1     ; audio oscillator - flat
acel2   oscil   kctrl, cpsoct(ipitch + .012), 1     ; audio oscillator - sharp
asig    =   afund + acel1 + acel2
kpan    =   (ipitch - 4)                            ; spread notes across stereo field
asig1, asig2, a3, a4  pan   asig, kpan, 1, 2, 1     ; function table 2 holds panning characteristics
        outs    asig1, asig2                        ; send signal to stereo channel
        endin   
