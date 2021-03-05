;---------------------------------------------------------
; Terrain Mapping with Dynamical Modulation
; Coded by Hans Mikelson October 1998
;---------------------------------------------------------
sr      =        44100                      ; Sample rate
kr      =        4410                       ; Kontrol rate
ksmps   =        10                         ; Samples/Kontrol period
nchnls  =        2                          ; Normal stereo

;---------------------------------------------------------
; Advanced Waveguide Instrument
;---------------------------------------------------------
        instr    14

idur    =	p3		; Duration
iamp    =	p4		; Amplitude
ifqc    =	cpspch(p5)	; Frequency
ipanl   =	sqrt(p6)	; Pan left
ipanr   =	sqrt(1-p6)	; Pan right
ipsta	=	p7		; Pitch start
ipend	=	p8		; Pitch End

ard2	init	0		; Have to initialize this first
atb2	init	0		; Have to initialize this first

kamp    linseg   0, .1*idur, 1, .7*idur, 1, .2*idur, 0
kbrth	linseg   0, .1, 1, .3, .1, idur-.4, .1
kfqc    linseg   ipsta, .5*idur, ipend, .5*idur, ipsta

aos1	oscil	1, ifqc, 1

anoiz	pinkish	kbrth

ard1	vdelay3	anoiz-tanh(ard2), 1, 1000	; Reed WG dir 1
ard2	vdelay3	ard1-atb2, 1, 1000
atb1	vdelay3	tanh(ard1-atb2), 1000/ifqc/kfqc, 1000
atb2	vdelay3	atb1, 1000/ifqc/kfqc, 1000


asig	butterhp	atb2, 10	; Block DC
aout	butterlp	asig, ifqc*4

       outs     aout*iamp*ipanl*kamp, aout*iamp*ipanr*kamp

       endin

