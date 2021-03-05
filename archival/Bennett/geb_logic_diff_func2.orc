sr = 44100
ksmps = 4410
nchnls = 1

instr 1
kterm phasor 1 / p3
ireiterate = 100
iamp = p4
istart = p5
iend = p6
iextent = iend - istart
irange = p7 - p8

krvar = kterm * iextent + istart
kcounter = 1
kx = 0.5
jumpback:
if (kcounter == ireiterate) kgoto jump
kx1 = kx * krvar * (1.0 - kx)
kx = kx1
kcounter = kcounter + 1
kgoto jumpback

jump:
kpitch = kx * irange
printk 0.1, krvar
a1 oscili iamp, kpitch, 1

out a1
endin
