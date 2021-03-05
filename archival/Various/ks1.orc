sr = 44100
kr = 44100
ksmps = 1

instr 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Low level implementation
; of the classic Karplus-Strong algorithm
; fixed pitches : no vibratos or glissandi !
; implemented by Josep M Comajuncosas / Aug´98
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ipluck = p5; pluck position ( 0 to 1 )
ifreq = cpspch(p4)
idlts = int(kr/ifreq-.5); set waveguide length (an integer number of samples)
idlt = idlts/kr; convert so seconds
kdlt init idlts; counter for string initialisation

irems = kr/ifreq - idlts +.5;remaining time in fractions of a sample
; set phase delay induced by the FIR lowpass filter
; and the fractional delay in the waveguide

iph = (1-irems)/(1+irems); allpass filter parameter
; approximation valid at low frequencies relative to sr

awgout init 0

;timout 0, idlt, initialise
;timout caused problems with delay initialisation
;so I used kdlt as a counter...

if kdlt < 0 goto continue

initialise:

anoise gauss 32000
; fill the buffer with random numbers

anoise butterlp anoise, p6, 1
; smooth a bit the noise burst
; harmonic richness grows with volume
; final volume determined by the filter gain

acomb delay anoise, ipluck/idlt
anoize = anoise - acomb
; implement pluck point as a FIR comb filter


continue:


areturn delayr idlt
ainput = anoize + areturn


alpf filter2 ainput, 2, 0, .5, .5
; lowpass filter to simulate energy losses
; could be variable to allow damping control

awgout filter2 alpf, 2, 1, iph, 1, iph
; allpass filter to fine tune the instrument

delayw awgout

out awgout

kdlt = kdlt - 1
anoize = 0; supress last impulse when waveguide is loaded
;tricky but easy...

endin


