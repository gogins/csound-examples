sr = 20050
kr = 20050
ksmps = 1

instr 1
;Synthesis by Functional Iterations
; instrument based on an article by Di Scipio & Prignano
; Journal of New Music Research, vol.25 (1996), pp. 31-46
;Coded to Csound by Josep M Comajuncosas / 1998

kcount= 0; counter for iterations. Keep inb small to reduce processing time!
ifreq = cpspch(p4)
inb = p5
ir1= p6
irf = p7
ix1= p8
ixf = p9
imaxvol=10000; you´d better normalize it for r>3.14

arenv linseg 0,.01,1,p3-.11,.6,.1,0
aosc oscili 1, ifreq, 1
aosc = (1+ aosc)/2
ar = ir1 + (irf-ir1)*arenv*aosc; cyclic ar to get an arbitrary pitched wave

avibosc oscili 1, 5, 1
avibosc = (1+avibosc)/2
axenvibr linseg 0, .5, 0, .5, 1, p3-1, 1; timbral modulation by changing initial conditions
ax = ix1+(ixf-ix1)*axenvibr*avibosc

iter: ax = sin(ar * ax); doesn´t really matter the function used... try others as well!
kcount = kcount + 1
if kcount < inb goto iter
out: 
out 20000* ax*arenv-10000
endin
