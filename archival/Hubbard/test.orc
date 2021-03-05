sr     = 44100
ksmps  =   100
nchnls =     2
0dbfs  =    40.0

instr 1
iamplitude              =                       dbamp(p5)
ifrequency              =                       cpsmidinn(p4)
aenvelope               transeg                 1.0, 10.0, -10, 0.0
ipluckpoint             =                       .9
ipickup                 =                       .1
ireflection             =                       .1
asignal                 wgpluck2                ipluckpoint, iamplitude, ifrequency, ipickup, ireflection
                        ; Sharp exponential decay.
adamping                linsegr                 0, 0.001, 1.0, p3, 1.0, 0.05, 0.0
asignal                 =                       asignal * aenvelope * adamping
                        outs                    asignal, asignal
endin
