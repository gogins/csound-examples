<CsoundSynthesizer>
<CsOptions>
csound -RWo csoundpiece.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
kr	=		44100
ksmps	=		1
nchnls	=		2

garvbsig init 0
gaol init 0
gaor init 0

instr    1 ; Random 64Hz to 1024Hz step generator:-)
idur     =		p3
ilevl    = 		p4 										; Output level
irate    = 		p5       								; Rate
iseed    = 		p6      									; Seed
itabl    = 		p7       								; Table for volume envelope
ilowest  = 		p8      									; lowest frequency
inumber  = 		p9       								; max number of steps
istep    = 		p10      								; steps in freq

k0       linseg  0, .1, 1, p3-.2, 1, .1, 0 			; Overall env
k1       randh  inumber/2, irate, iseed            	; 'Sample and hold'
k2       = 		int(k1 + inumber/2+1)                    ; Convert to whole numbers
a3       oscil  1, irate, itabl            			; Read table for volume envelope
a4       oscil  a3, ilowest+istep*k2, 1             ; Generate random notes 128Hz apart
kpan     line 	0,idur*.7,1
aol		=		a4*k0*ilevl*kpan
aor		=		a4*k0*ilevl*(1-kpan)
		outs    aol*k0, aor*k0          					; Output and envelope
asoundz	=		aol*k0+aor*k0		
garvbsig=		garvbsig+asoundz
		endin

instr    2 ; Random 64Hz to 1024Hz step generator:-)
idur     =p3
ilevl    = p4 										; Output level
irate    = p5       								; Rate
iseed    = p6       								; Seed
itabl    = p7      									; Table for volume envelope
ilowest  = p8      									; lowest frequency
inumber  = p9       								; max number of steps
istep    = p10     									; steps in freq

k0       linseg  0, .2, 1, p3-.2, 1, .2, 0 		    ; Overall env
k1       randh  inumber/2, irate, iseed           	; 'Sample and hold'
k2       = int(k1 + inumber/2+1)                    ; Convert to whole numbers
a3       oscil  1, irate, itabl            			; Read table for volume envelope
a4       oscil  a3, ilowest+istep*k2/2, 1           ; Generate random notes 64Hz apart
kpan     line 0,idur*.8,1
aol=a4*k0*ilevl*kpan
aor=a4*k0*ilevl*(1-kpan)
outs     aol*k0, aor*k0          					; Output and envelope
astuff=aol*k0+aor*k0
garvbsig=garvbsig+astuff
endin

instr 3;Begin: Untitled1
kpan  = p8
     aamp expseg .5,p3-.01,1,.01,.1
     kenv1   linseg 500, p5, 495, p3, 475, p6, 500
     asig1   oscili kenv1, p7, p4
     krtl =sqrt(2)/2*cos(kpan)+sin(kpan)
     krtr =sqrt(2)/2*cos(kpan)-sin(kpan)
     aol=(asig1*aamp)*krtl
     aor=(asig1*aamp)*krtr
     gaol=gaol+aol
     gaor=gaor+aor
     outs aol*aamp,aor*aamp
endin    ;
instr    4; Random 64Hz to 1024Hz step generator:-)
idur     =p3
ilevl    = p4 ; Output level
irate    = p5       ; Rate
iseed    = p6       ; Seed
itabl    = p7       ; Table for volume envelope
ilowest  = p8       ; lowest frequency
inumber  = p9       ; max number of steps
istep    = p10      ; steps in freq

k0       linseg  0, .1, 1, p3-.2, 1, .1, 0 			; Overall env
k1       randh  inumber/2, irate, iseed            	; 'Sample and hold'
k2       = int(k1 + inumber/2+1)                    ; Convert to whole numbers
a3       oscil  1, irate, itabl            			; Read table for volume envelope
a4       oscil  a3, ilowest+istep*k2, 1             ; Generate random notes 128Hz apart
kpan     line 0,idur*.7,1
aol=a4*k0*ilevl*kpan
aor=a4*k0*ilevl*(1-kpan)
outs     aol*k0, aor*k0         					; Output and envelope
asoundz=aol*k0+aor*k0
garvbsig=garvbsig+asoundz
endin

instr  50
idur=p3
igainl=p4
itiml=p5

igainr=p6
itimr=p7


afltl init 0
afltr init 0
aamp linseg 0,.005,1,idur-.01,1,.005,0
adell delay (gaol+afltl)*igainl,itiml*2
adelr delay (gaor+afltr)*igainr,itimr*2
gaol=0
gaor=0
outs adell*aamp,adelr*aamp
endin


instr 98

a1 reverb2 garvbsig, p4, p5
 outs     a1,a1

garvbsig=0

endin
</CsInstruments>
<CsScore>
;TABLES FOR VOLUME ENVELOPES (NOT PITCHES)
f1 0 4096 10 1          ; SINE
f2 0 1024 5 1 1024 .001 ; EXPONENTIAL DECAY
f3 0 1024 7 1 1024 0    ; LINEAR DECAY
f4 0 1024 20 2          ; HANNING
f5 0 1024 20 6          ; GAUSSIAN
f6 0 1024 21 10 1 2     ; WEIBULL

;=====================================================================
;     Start Leng  Level Rate  Seed  Table  ilowest inumber  istep
;=====================================================================
i1    0     8     400   8    .00007   4      64     20      256
i1    1     .     410   .    ~     .         .       .       .
i1    2     .     420   .    ~     .         .       .       .
i1    3     .     430   .    ~     .         .       .       .
i1    4     .     440   .    ~     .         .       .       .
i1    5     .     400   .    .99   .         64              .
i1    0     30    400   2    .001   5       128     15       64
i1    1     12    .     .    ~     .         .       .       .
i1    2     15    .     .    ~     .         .       .       .
i1    3     31    .     .    ~     .         .       .       .
i1    4     31    .     .    ~     .         .       .       .
i1    5     29    .     .   .85    .         .       .       .

;=====================================================================
;     Start Leng  Level Rate  Seed  Table   ilowest inumber  istep
;=====================================================================
i2    .2     8     300   7    .0009     4      128      20        64
i2    1.2   20      .     .     ~     .          .       2        .
i2    2.2   .       .     .     ~     .          .       2        .
i2    3.2   .       .     .     ~     .          .       4        .
i2    4.2   15      .     .     ~     .          .       4        .
i2    5     .       .     .   .79     .          .       7        .
i2    .2     8      .     .    .7     .         64       2        .
i2    1.2   31      .     .     ~     .          .      20        .
i2    2.2   .       .     .     ~     .          .      20        .
i2    3.2   .       .     .     ~     .          .       4        .
i2    4.2   25      .     .     ~     .          .       2        .
i2    5     30      .     .   .95     .       1024      24        .

;=====================================================================
; p1=Instr  p2:Start  p3:Duration  p4:User  p5:User  p6:User  p7:User
;=====================================================================
p8
i3              5          8         1       0.9      0.9       64           0
i3              7         14         .    0.5      0.9         128           1
i3             13          4         .    0.9      0.9         192           1
i3             17          1         .    0.7      0.9         224           0
i3             17.3        1         .    0.7      0.9         256           0
i3             17.5        1         .    0.9      0.9         272           1
i3             17.6        1         .    0.9      0.9         336           1
i3             17.8        1         .    0.8      0.9         128           0
i3              8.4        9         .    0.7      0.9         384           1
i3              9.4        6         .    0.6      0.9         341.3         0
i3             10.5        6         .    0.5      0.8         512           0
i3             11.55       7         .    0.8      0.9         544           0
i3             12.6        7         .    0.9      0.9         272           1
i3             13.65       8         .    0.9      0.9         192           0
i3             14.7        8         .    0.9      0.9         128           0
i3             15.75       8         .    0.6      0.8         341.3         1
i3             16.8        9         .    0.7      0.8         384           0
i3             17.85       9         .    0.8      0.4         496           1
i3             18.9        9         .    0.6      0.9         544           0
i3             19.95      10         .    0.9      0.5         682.6         1
i3             21         10         .    0.9      0.1         672           0

i4    10     8    400   8   .00007  4        64      20      512
i4    +     .     410   .    ~      .         .       .       .
i4    .     .     420   .    ~      .         .       .       .
i4    .     .     430   .    ~      .         .       .       .
i4    .     .     440   .    ~      .         .       .       .
i4    .     .     400   .   .99     .        64               .
i4    .     30    400   2   .001    5       256      15      64
i4    .     12    .     .    ~      .         .       .       .
i4    .     15    .     .    ~      .         .       .       .
i4    .     31    .     .    ~      .         .       .       .
i4    .     31    .     .    ~      .         .       .       .
i4    .     29    .     .   .85     .         .       .       .

;     Start Leng  Level Rate  Seed  Table   ilowest inumber  istep
i4    20    8     300   7    .0009   4      128      20        64
i4    +    20     .     .     ~      .        .       2        .
i4    .     .     .     .     ~      .        .       2        .
i4    .     .     .     .     ~      .        .       4        .
i4    .    15     .     .     ~      .        .       4        .
i4    .     .     .     .    .79     .        .       7        .
i4    .     8     .     .    .7      .       64       2        .
i4    .    31     .     .     ~      .        .      20        .
i4    .     .     .     .     ~      .        .      20        .
i4    .     .     .     .     ~      .        .       4        .
i4    .    25     .     .     ~      .        .       2        .
i4    .    30     .     .    .95     .      448      24        .

i50  0  286 9  .90  8 .90

;THIS IS FOR REVERB SETTINGS
;=================================
;p1     p2   p3      p4      p5
;=================================
;instr strt  dur  rvbtime   hfdif
;=================================
i98     0    286     10      .7


e


</CsScore>
</CsoundSynthesizer>
