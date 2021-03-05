sr = 44100
kr = 44100
ksmps = 1
zakinit 2,2

instr 1
idur = 1/150
timout 0,idur,noise
turnoff
noise:
kamp linen 1,idur/5,idur,idur/5
anoise rand kamp
;anoise oscili kamp,150,1; see how a PNF corrupts
; an innocent sine wave ;-)

zaw anoise,0
endin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 2; Passive nonlinear filter
;after J.Pierce & Scott V. Duyne / US Patent 5,703,313
;coded by Josep M Comajuncosas /Nov´98
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iatt1   = .998;  attenuation
ifco1   = -.058; freq dependent decay

aback init 0
afdbk init 0

anoise zar 0
ainput1 = anoise + aback
aout1 delay ainput1,1/150
alpf filter2 aout1*iatt1, 1, 1, 1+ifco1, ifco1

;Passive nonlinear filter : a variable allpass filter
;requires sr = kr to run the conditional

;compute some parameters
au = alpf - afdbk
;au = adcrem - afdbk;??????sona millor!!!
ku downsamp au
if ku < 0 goto or
kstiff = p4
goto next
or:
kstiff = p5
next:
afdbk delay1 kstiff*au
;the filter itself
alpf2 biquad alpf,kstiff,1,0,1,kstiff,0

ainput2 = alpf2
aback delay ainput2,1/150

out aout1*10000
zacl 0,2
endin