iafno ftgen 1, 0, 65537, 10, 1 ; Sine wave.
sr = 44100
kr        =         44100
ksmps     =         1
          instr 1
          ; LOGISTIC CURVE APPLIED TO SOUND GENERATION
p3        =         2 * p3
ipitch    =         cpspch(p4)
iatt      =         .08                      ; ATTACK AS PERCENTAGE (%1) OF TABLE WITH CHAOTIC BEHAVIOUR
isize     =         ftlen(1)
kndx      init      0
kx2       init      0.01
idur      =         isize/sr
ichaos    =         3.5699456                ; LIMIT BETWEEN PERIODIC AND CHAOTIC BEHAVIOUR
ku        linseg     4, iatt*idur, ichaos , idur*(1-iatt), 3

fill:
          if        (kndx > isize) kgoto contin

kx        =         kx2
kx2       =         ku * kx * (1-kx)         ; SIMPLE LOGISTIC (MAY) CURVE
          tablew    (kx2-.65), kndx, 1
kndx      =         kndx + 1


contin:
          if        (kndx < isize) kgoto endin
aphase    line      0, 1000/ipitch, isize    ; NOT TUNED YET!...
asig      tablei    aphase,1                 ; <- YOU=B4LL GET TRIANGLE WAVES AT THE END
          out       20000*(asig)

endin:
          endin
