;GIVEN: THERE EXIST TRADE-OFFS WHEN FILTERING NOISE IN AN EFFORT TO MAKE USABLE 
;SOUNDS.
;THAT DOES NOT MEAN IT CAN'T BE FUN.
;NEARLY ANY VARIABLE EFFECTS OUTPUT (AMPLITUDE). 
;I FIND THIS TALK OF NOISE CARVING ARTISTICALLY FASCINATING. 

sr        =         44100
kr        =         4410
ksmps     =         10
nchnls    =         2

          instr 1

kamp      linen     .01,.01,p3,.2
kpass     line      p4,p3,p5
arand     rand      10000
afilter   reson     arand,kpass,0.048
asculpt   =         kamp*afilter
amold     envlpx    .00005,.03,p3,.06,1,.5,.01,0.8 
          outs      asculpt*amold,asculpt*amold
          endin

