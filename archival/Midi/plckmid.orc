sr = 44100
kr = 4410
ksmps = 10
nchnls = 2

garvbsigl init 0  
garvbsigr init 0

instr 1                    ; pluckmidi.orc

iamp     ampmidi  32000, 6
inote    octmidi
icps     cpsmidi
ilfodel  = .2
ilfodepth = .005
ilfofunc = 1
ilfofreq = 2.000

kamp  linseg   0,.01,1,.5,1,4,0,.01,0   
kamp2 linenr   kamp*iamp, .01, .333, .05

timout 0, ilfodel, output
   klfoctl linenr 1,.05,.5,.01
   krandz randi .005, 15, .5
   klfo oscil klfoctl*ilfodepth+krandz,ilfofreq*klfoctl,ilfofunc
output:

   asig1 pluck kamp2, cpsoct(inote + klfo), icps, 0, 1
   asig2 pluck kamp2, cpsoct(inote + klfo - .0008), icps, 0, 1
   asig3 pluck kamp2, cpsoct(inote + klfo + .0008), icps, 0, 1
   
   asig4 pluck    kamp2, icps*3, icps*3, 0, 2,2
   
   aflt1 reson asig1 + asig2 + asig3, 110, 80
   aflt2 reson asig1 + asig2 + asig3, 220, 100
   aflt3 reson asig1 + asig2 + asig3, 440, 80

   amixl balance .5*aflt1 + aflt2 + 1.5*aflt3 + asig1 + asig2 + .5*asig4, asig1 
   amixr balance .5*aflt1 + aflt2 + 1.5*aflt3 + asig1 + asig3 + .5*asig4, asig1
   
      
   outs  amixl,amixr
endin
              
