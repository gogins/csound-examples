<CsoundSynthesizer>
<CsVersion>
5.09
</CsVersion>
<CsOptions>
-RWdfo ModFM.wav
</CsOptions>

<CsInstruments>
sr = 88200
ksmps = 64
nchnls = 2

garev1 init 0
garev2 init 0
 
opcode ModFM,a,aakkkki

acos,aph,kamp,kfo,kfc,kbw,itab xin

itm = 14
icor = 4.*exp(-1)

ktrig changed kbw
if ktrig == 1 then
 k2 = exp(-kfo/(.29*kbw*icor)) 
 kg2 = 2*sqrt(k2)/(1.-k2)
 kndx = kg2*kg2/2.
endif

kf = kfc/kfo
kfin = int(kf)
ka = kf  - kfin
aexp table kndx*(1-acos)/itm,3,1

ioff = 0.25
acos1 tablei aph*kfin, itab, 1, ioff, 1
acos2 tablei aph*(kfin+1), itab, 1, ioff, 1
asig = (ka*acos2 + (1-ka)*acos1)*aexp

    xout asig*kamp

endop

instr 7

iol     = 30                   ; max overlaps
ifun    = p5                   ; fundamental 1
iamp     = p4*0.6               ; overall amp
isecs     = p3                 ; note duration in secs
irshape  = 13                   ; envlpx rise shape
isine    = 11                   ; sinewave
itxshape = 12                   ; FOF granules tex shape

seed 0
idtu gauss ifun/100
kndx phasor ifun/50 + idtu, p6*2

kform1   tablei kndx, 101, 1, 0, 1                  ; 5 formant regions
kform2   tablei kndx, 102, 1, 0, 1  
kform3   tablei kndx, 103, 1, 0, 1  
kform4   tablei kndx, 104, 1, 0, 1  

; formant amplitudes
kaf2     tablei kndx, 112, 1, 0, 1                    
kaf3      tablei kndx, 113, 1, 0, 1  
kaf4      tablei kndx, 114, 1, 0, 1  
kaf5      tablei kndx, 115, 1, 0, 1  

kscal   = 1/(1+ampdb(kaf3)+ampdb(kaf2)+ampdb(kaf4)+ampdb(kaf5)) ; scale output

kbw1    tablei kndx, 121, 1, 0, 1  
kbw2    tablei kndx, 122, 1, 0, 1  
kbw3    tablei kndx, 123, 1, 0, 1  
kbw4    tablei kndx, 124, 1, 0, 1  
kbw5    tablei kndx, 125, 1, 0, 1  

ivib     =   .9*log(ifun)       ; vibrato intensity

kvib    =  ivib*0.5


      ;jitter & vibr 
kj     randi  kvib, 15, 2
kv     linen  1, 1, p3,1
iph  rnd31  1, 0
kv     oscili  kvib*kv, 3.8+kv, 1, iph

      ;fundamental + jitter + vibr

kfun   =   (cpspch(ifun)+kj+kv+idtu)
iadj = 1.5
iadj2 = 2

aph   phasor kfun
acos tablei aph, 1, 1, 0.25, 1

if kform1 <= kfun then
kform1 = kfun
endif

a1 ModFM acos,aph,1,kfun,kform1,kbw1,1
a2 ModFM acos,aph,ampdb(kaf2),kfun,kform2,kbw2*iadj,1
a3 ModFM acos,aph,ampdb(kaf3),kfun,kform3,kbw3*iadj2,1
a4 ModFM acos,aph,ampdb(kaf4),kfun,kform4,kbw4*iadj2,1
a5 ModFM acos,aph,ampdb(kaf5),kfun,4950,kbw5*iadj2,1

kenv linseg  0, p8, iamp, p3-p8-p9, iamp, p9, 0
asuml   =     (a3+a4+a5+a2+a1)*kscal*kenv             ; mix all formant regions

asuml dcblock  asuml
asuml delay asuml, rnd(0.005) 
garev1 = asuml*p7 + garev1
garev2 = asuml*p7 + garev2

      outs   asuml*(1-p7),asuml*(1-p7)

endin


instr 1

iamp = p4
ilow = cpspch(p5)
ispeed = p6
ibas = ispeed/8
itm = 14
icor = log(2)
ioff = 0.25

kph phasor ibas/16
kmod tablei kph*1.1,1,1,p8,1
kmod = ((kmod+1)/2)*ilow*17 + ilow*3

kfrq table kph,2,1,0,1
kfrq pow   2, kfrq/12
kfo  = kfrq*ilow

kint table kph*16.1,2,1,0,1
kint pow  2, kint/12

k1    phasor -ispeed
kfade linseg  0,3,1,p3-6,1,3,0
kamp  portk k1*iamp*kfade, 0.05

aph phasor kfo*kint
acos tablei  aph,1,1,ioff,1
asig ModFM acos,aph,kamp,kfo,kmod,(kmod-kfo)*2,1

   outs asig*(1-p7),asig*p7

endin

instr 200

arev1,arev2 freeverb garev1, garev2, 0.3, 0.3
     outs arev1,arev2

garev2  = 0
garev1 = 0
endin
</CsInstruments>

<CsScore>

f1 0 2048 10 1
f3 0 131072 "exp" 0 -14 1
 
f101 0 4 -2  800 325 350 450    
f102 0 4 -2  1150 700 2000 800  
f103 0 4 -2  2900 2700 2800 2830 
f104 0 4 -2  3900 3800 3600 3800 

f112 0 4 -2  -6  -16 -20 -11 
f113 0 4 -2  -32 -35 -15 -22 
f114 0 4 -2  -20 -40 -40 -22 
f115 0 4 -2  -50 -60 -56 -50 

f121 0 4 -2  80 50 60 70 
f122 0 4 -2  90 60 90 80 
f123 0 4 -2  120 170 100 100 
f124 0 4 -2  130 180 150 130 
f125 0 4 -2  140 200 200 135 

f2 0 8 -2  0 5 10 0 9 2 7 5

t 0 90
i200 0 60

i1 0 57 10000 7.00 8      0  0.75
i1 0 58 10000 6.00 8.025 0.25 0.75
i1 0 59 10000 8.00 8.05  0.5 0.75
i1 0 61 10000 6.00 8.075 0.75 0.75
i1 0 63 10000 7.00 8.1   1  0.75

i1 30 102 10000 5.00 8     0 0
i1 30 57 10000 6.00 8.025 0.25 0.25
i1 30 58 10000 7.00 8.05  0.5   0.5
i1 30 59 10000 6.00 8.075 0.75 0.75
i1 30 61 10000 5.00 8.1   1 0

i1 114 30 10000 6.00 8      0  0.0
i1 114 31 10000 7.00 8.025 0.25 0.125
i1 114 32 10000 8.00 8.05  0.5 0.25
i1 114 60 10000 7.00 8.075 0.75 0.375
i1 114 34 10000 6.00 8.1   1  0.5

i7  20  23  10000  9.00  0.1 0.5 5 5
i7  20  23  10000  9.05   0.2 0.5 . .
i7  42  22  20000 8.10  0.1 0.8 2 1
i7  59  11  12000 8.00   0.2 0.6 . .
i7  64  14  10000 8.09  0.1 0.5 . .
i7  70  12  8000  9.02 0.4 0.4 2 1
i7  78  11  8000  8.07  0.1 0.3 . .
i7  82  16  10000 9.05 0.4 0.2 . .
i7  87  18  10000 9.00  0.1 0.5 . 1
i7  94  20  12000 8.07  0.1 0.5 . 1
i7  107  25  20000 9.00  0.1 0.8 . 6


i7  20  23  10000  9.00  0.1 0.5 5 5
i7  20  23  10000  9.05   0.2 0.5 . .
i7  42  22  20000 8.10  0.1 0.8 2 1
i7  59  11  12000 8.00   0.2 0.6 . .
i7  64  14  10000 8.09  0.1 0.5 . .
i7  70  12  8000  9.02 0.4 0.4 2 1
i7  78  11  8000  8.07  0.1 0.3 . .
i7  82  16  10000 9.05 0.4 0.2 . .
i7  87  18  10000 9.00  0.1 0.5 . 1
i7  94  20  12000 8.07  0.1 0.5 . 1
i7  107  25  20000 9.00  0.1 0.8 . 6


i7  20  23  10000  9.00  0.1 0.5 5 5
i7  20  23  10000  9.05   0.2 0.5 . .
i7  42  22  20000 8.10  0.1 0.8 2 1
i7  59  11  12000 8.00   0.2 0.6 . .
i7  64  14  10000 8.09  0.1 0.5 . .
i7  70  12  8000  9.02 0.4 0.4 2 1
i7  78  11  8000  8.07  0.1 0.3 . .
i7  82  16  10000 9.05 0.4 0.2 . .
i7  87  18  10000 9.00  0.1 0.5 . 1
i7  94  20  12000 8.07  0.1 0.5 . 1
i7  107  25  20000 9.00  0.1 0.8 . 6

i7  20  23  10000  9.00  0.1 0.5 5 5
i7  20  23  10000  9.05   0.2 0.5 . .
i7  42  22  20000 8.10  0.1 0.8 2 1
i7  59  11  12000 8.00   0.2 0.6 . .
i7  64  14  10000 8.09  0.1 0.5 . .
i7  70  12  8000  9.02 0.4 0.4 2 1; 50
i7  78  11  8000  8.07  0.1 0.3 . .; 58
i7  82  16  10000 9.05 0.4 0.2 . .; 62
i7  87  18  10000 9.00  0.1 0.5 . 1
i7  94  20  12000 8.07  0.1 0.5 . 1
i7  107  25  20000 9.00  0.1 0.8 . 6

e 6
</CsScore>

</CsoundSynthesizer>
