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
instr 2; Lowpass loop filter
;coded by Josep M Comajuncosas /Feb´98
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iatt1   = .998;  attenuation
ifco1   = -.058; freq dependent decay

aback init 0

anoise zar 0
ainput1 = anoise + aback
aout1 delay ainput1,1/150
alpf filter2 aout1*iatt1, 1, 1, 1+ifco1, ifco1

ainput2 = alpf
aback delay ainput2,1/150

out aout1*10000
zacl 0,2
endin