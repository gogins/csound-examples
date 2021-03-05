; This instrument implements simple frequency modulation to produce
;        time-varying spectra.
;The specific values and instrument design come from John M. Chowning's article
;"The Synthesis of Complex Audio Spectra by Means of Frequency Modulation"

sr          =           44100
kr          =           4410
ksmps       =           10
nchnls      =           1

            instr       1

; p4  = amplitude of output wave
; p5  = carrier frequency specified in Hz
; p6  = modulating frequency specified in Hz
; p7  = modulation index 1
; p8  = modulation index 2
; p9  = carrier envelope function
; p10 = modulator envelope function

i1          =           1/p3               ; one cycle per duration of note
i2          =           p7*p6              ; calculates deviation for index 1
i3          =           (p8-p7)*p6         ; calculates deviation for index 2

ampcar      oscil       p4, i1, p9         ; amplitude envelope for the carrier
ampmod      oscil       i3, i1, p10        ; amplitude envelope for the modulator

amod        oscili      ampmod+i2, p6, 1   ; modulating oscillator
asig        oscili      ampcar, p5+amod, 1 ; carrier oscillator
            out         asig
            endin       

; This is a double carrier FM instrument used to place a formant peak
; in the spectrum.  The specific values and instrument design come
; from John M. Chowning's article "The Synthesis of Complex Audio
; Spectra by Means of Frequency Modulation"

            instr       2

; p4  = amplitude of output wave
; p5  = carrier frequency specified in Hz
; p6  = modulating frequency specified in Hz
; p7  = modulation index 1
; p8  = modulation index 2
; p9  = carrier envelope function
; p10 = modulator envelope function
; p11 = amplitude scaler for second carrier
; p12 = modulation index scaler for second carrier
; p13 = frequency of second carrier specified in Hz

i1          =           1/p3               ; one cycle per duration of note
i2          =           p7*p6              ; calculates deviation for index 1
i3          =           (p8-p7)*p6         ; calculates deviation for index 2

ampcar      oscil       p4, i1, p9         ; amplitude envelope for the carrier
ampmod      oscil       i3, i1, p10        ; amplitude envelope for the modulator

amod        oscili      ampmod+i2, p6, 1   ; modulating oscillator
asig1       oscili      ampcar, p5+amod, 1 ; carrier oscillator
asig2       oscili      ampcar*p11, p13+(amod*p12), 1
                                            ; second carrier oscillator
            out         asig1+asig2
            endin       
