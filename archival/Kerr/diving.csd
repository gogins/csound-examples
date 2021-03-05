<CsoundSynthesizer>
<CsOptions>
csound -RWf -Z -oDiving_I.wav temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr     = 44100
kr     = 44100 ;sorry, gong needs kr==sr
ksmps  = 1
nchnls = 2

zakinit 75, 5
gapinL init 0
gapinR init 0

;---------------------------------------------------------------------------
;bhob rainey's ensemble UDO
;---------------------------------------------------------------------------
	opcode ensembleChorus, aa, akkkkiip
ain, kdelay, kdpth, kmin, kmax, inumvoice, iwave, icount xin
incr = 1/(inumvoice)

if (icount == inumvoice) goto out
ainl, ainr ensembleChorus ain, kdelay, kdpth, kmin, kmax, inumvoice, iwave, icount + 1

out:

max:
imax = i(kmax)
if (kmax != imax) then 
reinit max
endif

iratemax unirand imax
rireturn
alfo oscil kdpth, iratemax + kmin, iwave
adel vdelay3 ain/(inumvoice * .5), (kdelay + alfo) * 1000, 1000
al = ainl + adel * incr * icount
ar = ainr + adel * (1 - incr * icount)
xout al, ar
	endop
;---------------------------------------------------------------------------
;David Akbari's ExpCurve UDO
;---------------------------------------------------------------------------

opcode	ExpCurve, k, kk

kfloat, ksteep	xin

if (ksteep > 1) then
	ksteep = ksteep
elseif (ksteep < 1) then
	ksteep = 1
endif

kout	=	(exp(kfloat * log(ksteep)) - 1)/(ksteep - 1)

	xout	kout

		endop

;---------------------------------------------------------------------------
; Mixer - based originally on Hans Mickelsons mixer instrument
;---------------------------------------------------------------------------
instr 900
idur = p3
ienvelope = p7
ilen init ftlen (ienvelope)

ktempo tempoval ;Tracks tempo: Requires using a 'tempo' modifying instrument
				;in combination with the -t flag. 

asig1     zar   p4   	; Read input channel 1
igl1      init  0     	; Left gain
igr1      init  p6      ; Right gain

asig2     zar   p5    	; Read input channel 2
igl2      init  p6    	; Left gain
igr2      init  0      	; Right gain

kdclick   linseg  0, .001, 1, p3-.002, 1, .001, 0  ; Declick
;			 10th of a second
kphs phasor (10/ilen) * (ktempo/60)					;fader control to 0.1 second resolution
kcontrol tablei kphs, ienvelope, 1					; 

asigl		=		(asig1*igl1 + asig2*igl2)*kcontrol ; Scale and sum
asigr     	=     	(asig1*igr1 + asig2*igr2)*kcontrol

asigl	dcblock	asigl
asigr	dcblock	asigr

amasterl = kdclick*asigl*0.9
amasterr = kdclick*asigr*0.9

amasterl clip amasterl, 0, 30000, 0.8 ;not sure I want this
amasterr clip amasterr, 0, 30000, 0.8 ;this really is just a channel

;outs  amasterl, amasterr   ; Output stereo pair
gapinL = gapinL + amasterl
gapinR = gapinR + amasterr

          endin

; Clear audio & control channels
          instr 910

          zacl  0, 75          ; Clear audio channels 0 to 75
          zkcl  0, 5          ; Clear control channels 0 to 5

          endin

;---------------------------------------------------------------------------
;Vibes with some distortion
;---------------------------------------------------------------------------
instr 18

izoutL = p6
izoutR = p7 

iamp = p4
ifreq = cpsoct(p5)
ihrd = 0.95422
ipos = 0.23
ivibfqc = 0.08
ivibamp = 0.15
idec = 0.9

avib      vibes      iamp, ifreq, ihrd, ipos, 22, ivibfqc, ivibamp, 1, idec

avib distort avib, 0.93, 23
denorm avib
al, ar ensembleChorus avib, 0.077, 0.0002, 0.7, 3, 5, 23

zawm al*0.3, izoutL
zawm ar*0.3, izoutR

endin

;---------------------------------------------------------------------------
;DX7 (Russell Pinkstons work )
;---------------------------------------------------------------------------

                instr   11
   ;             ihold                           ;dont turn on note indefinitely
        idur    =       abs(p3)
        ibase   =       cpsoct(p4)              ;p4 is keyboard pitch
        iroct   =       p4
        irbase  =       octpch(4.09)            ;base of rate scl table
        irrange =       octpch(13.06)-irbase
        iveloc  =       p5                      ;0 <= p5 <= 127
	iSpace	=	p6			;pan -1 to +1
	izoutL 	= 	p7			;zakleft channel
	izoutR	=	p8			;zakright channel
        iop1fn  =       p10                     ;param tables for ops
        iop2fn  =       p11
        iop3fn  =       p12
        iop4fn  =       p13
        iop5fn  =       p14
        iop6fn  =       p15
        iampfn  =       p16                     ;amp/level map function
        ipkamp  =       p17                     ;scale for converter
        irsfn   =       p18                     ;rate scaling function
        idevfn  =       p19                     ;level/pkdev map func
        irisefn =       p20                     ;eg rise rate fn
        idecfn  =       p21                     ;eg decay rate fn
        ivsfn   =       p22                     ;vel sensitivity fn
        ivelfn  =       p23                     ;vel/amp fac map fn
        iveloc  table   iveloc,ivelfn           ;map this note's veloc
        ifeedfn =       p24
        ifeed   table   p25,ifeedfn             ;0 <= p25 <= 7 (feedbk)
        ifeed   =       ifeed/(2 * 3.14159)     ;dev in radians
        idetfac =       4                       ;max detuning divisor
        imap128 =       127/99                  ;mapping constant 99->127
        irscl   table   (iroct-irbase)/irrange*127,irsfn
        irscl   =       irscl*6
        iop     =       1                       ;start loop with op1
        iopfn   =       iop1fn

loop:
;---------------------------------read operator parameters
        ilvl    table   0,iopfn
        ivel    table   1,iopfn
        iegr1   table   2,iopfn
        iegr2   table   3,iopfn
        iegr3   table   4,iopfn
        iegr4   table   5,iopfn
        iegl1   table   6,iopfn
        iegl2   table   7,iopfn
        iegl3   table   8,iopfn
        iegl4   table   9,iopfn
        iams    table   10,iopfn
        imode   table   11,iopfn
        ifreq   table   12,iopfn
        idet    table   13,iopfn
        irss    table   14,iopfn
;----------------------------------initialize operator
        ihz     =       (imode > 0 ? ifreq : ibase * ifreq) + idet/idetfac
 iamp	=	ilvl/99		;rescale to 0 -> 1
        ivfac   table   ivel,ivsfn

        iegl1   =       iamp*iegl1
        iegl2   =       iamp*iegl2
        iegl3   =       iamp*iegl3
        iegl4   =       iamp*iegl4

        iegl1   =       iegl1*(1-ivfac)+iegl1*ivfac*iveloc
        iegl2   =       iegl2*(1-ivfac)+iegl2*ivfac*iveloc
        iegl3   =       iegl3*(1-ivfac)+iegl3*ivfac*iveloc
        iegl4   =       iegl4*(1-ivfac)+iegl4*ivfac*iveloc

        irs     =       irscl*irss
        iegr1   =       (iegr1+irs > 99 ? 99 : iegr1+irs)
        iegr2   =       (iegr2+irs > 99 ? 99 : iegr2+irs)
        iegr3   =       (iegr3+irs > 99 ? 99 : iegr3+irs)
        iegr4   =       (iegr4+irs > 99 ? 99 : iegr4+irs)

        irfn    =       (iegl1 > iegl4 ? irisefn : idecfn)
        iegd1   table   iegr1,irfn               ;convert rate->dur
        ipct1   table   iegl4,irfn+1             ;pct fn is next one
        ipct2   table   iegl1,irfn+1
        iegd1   =       abs(iegd1*ipct1-iegd1*ipct2)
        iegd1   =       (iegd1 == 0 ? .001 : iegd1)

        irfn    =       (iegl2 > iegl1 ? irisefn : idecfn)
        iegd2   table   iegr2,irfn
        ipct1   table   iegl1,irfn+1
        ipct2   table   iegl2,irfn+1
        iegd2   =       abs(iegd2*ipct1-iegd2*ipct2)
        iegd2   =       (iegd2 == 0 ? .001 : iegd2)

        irfn    =       (iegl3 > iegl2 ? irisefn : idecfn)
        iegd3   table   iegr3,irfn
        ipct1   table   iegl2,irfn+1
        ipct2   table   iegl3,irfn+1
        iegd3   =       abs(iegd3*ipct1-iegd3*ipct2)
        iegd3   =       (iegd3 == 0 ? .001 : iegd3)

        iegd4   table   iegr4,idecfn
                if      (iegl3 <= iegl4) igoto continue
        ipct1   table   iegl3,irfn+1
        ipct2   table   iegl4,irfn+1
        iegd4   =       abs(iegd4*ipct1-iegd4*ipct2)
        iegd4   =       (iegd4 == 0 ? .001 : iegd4)
continue:
                if      (iop > 1) igoto op2
op1:
        i1egd1  =       iegd1
        i1egd2  =       iegd2
        i1egd3  =       iegd3
        i1egd4  =       iegd4
        i1egl1  =       iegl1
        i1egl2  =       iegl2
        i1egl3  =       iegl3
        i1egl4  =       iegl4
        i1ams   =       iams
        i1hz    =       ihz
        iop     =       iop + 1
        iopfn   =       iop2fn
                igoto   loop

op2:            if      (iop > 2) igoto op3
        i2egd1  =       iegd1
        i2egd2  =       iegd2
        i2egd3  =       iegd3
        i2egd4  =       iegd4
        i2egl1  =       iegl1
        i2egl2  =       iegl2
        i2egl3  =       iegl3
        i2egl4  =       iegl4
        i2ams   =       iams
        i2hz    =       ihz
        iop     =       iop + 1
        iopfn   =       iop3fn
                igoto   loop

op3:            if      (iop > 3) igoto op4
        i3egd1  =       iegd1
        i3egd2  =       iegd2
        i3egd3  =       iegd3
        i3egd4  =       iegd4
        i3egl1  =       iegl1
        i3egl2  =       iegl2
        i3egl3  =       iegl3
        i3egl4  =       iegl4
        i3ams   =       iams
        i3hz    =       ihz
        iop     =       iop + 1
        iopfn   =       iop4fn
                igoto   loop

op4:            if      (iop > 4) igoto op5
        i4egd1  =       iegd1
        i4egd2  =       iegd2
        i4egd3  =       iegd3
        i4egd4  =       iegd4
        i4egl1  =       iegl1
        i4egl2  =       iegl2
        i4egl3  =       iegl3
        i4egl4  =       iegl4
        i4ams   =       iams
        i4hz    =       ihz
        iop     =       iop + 1
        iopfn   =       iop5fn
                igoto   loop

op5:            if      (iop > 5) igoto op6
        i5egd1  =       iegd1
        i5egd2  =       iegd2
        i5egd3  =       iegd3
        i5egd4  =       iegd4
        i5egl1  =       iegl1
        i5egl2  =       iegl2
        i5egl3  =       iegl3
        i5egl4  =       iegl4
        i5ams   =       iams
        i5hz    =       ihz
        iop     =       iop + 1
        iopfn   =       iop6fn
                igoto   loop

op6:
        i6egd1  =       iegd1
        i6egd2  =       iegd2
        i6egd3  =       iegd3
        i6egd4  =       iegd4
        i6egl1  =       iegl1
        i6egl2  =       iegl2
        i6egl3  =       iegl3
        i6egl4  =       iegl4
        i6ams   =       iams
        i6hz    =       ihz
;=====================================================================
                timout  idur,999,final          ;skip during final decay

        k1sus   linseg  i1egl4,i1egd1,i1egl1,i1egd2,i1egl2,i1egd3,i1egl3,1,i1egl3
        k2sus   linseg  i2egl4,i2egd1,i2egl1,i2egd2,i2egl2,i2egd3,i2egl3,1,i2egl3
        k3sus   linseg  i3egl4,i3egd1,i3egl1,i3egd2,i3egl2,i3egd3,i3egl3,1,i3egl3
        k4sus   linseg  i4egl4,i4egd1,i4egl1,i4egd2,i4egl2,i4egd3,i4egl3,1,i4egl3
        k5sus   linseg  i5egl4,i5egd1,i5egl1,i5egd2,i5egl2,i5egd3,i5egl3,1,i5egl3
        k6sus   linseg  i6egl4,i6egd1,i6egl1,i6egd2,i6egl2,i6egd3,i6egl3,1,i6egl3
        k1phs   =       k1sus
        k2phs   =       k2sus
        k3phs   =       k3sus
        k4phs   =       k4sus
        k5phs   =       k5sus
        k6phs   =       k6sus
                kgoto   output
final:
        k1fin   linseg  0, 0.01, 1,i1egd4,0,1,0
        k1phs   =       i1egl4+(k1sus-i1egl4)*k1fin
        k2fin   linseg  0, 0.01, 1,i2egd4,0,1,0
        k2phs   =       i2egl4+(k2sus-i2egl4)*k2fin
        k3fin   linseg  0, 0.01, 1,i3egd4,0,1,0
        k3phs   =       i3egl4+(k3sus-i3egl4)*k3fin
        k4fin   linseg  0, 0.01, 1,i4egd4,0,1,0
        k4phs   =       i4egl4+(k4sus-i4egl4)*k4fin
        k5fin   linseg  0, 0.01, 1,i5egd4,0,1,0
        k5phs   =       i5egl4+(k5sus-i5egl4)*k5fin
        k6fin   linseg  0, 0.01, 1,i6egd4,0,1,0
        k6phs   =       i6egl4+(k6sus-i6egl4)*k6fin
        
        ;the rest is algorithm specific
;--------------------Algorithm 10----------------------------------;
                if      (k1fin+k4fin) > 0 kgoto output
     ;           turnoff                 ;when carrier oscil(s) done, turn off.
output:                  
        k1gate  table3  k1phs,iampfn    ;use ampfn for any carrier
        k2gate  table3  k2phs,idevfn    ;use devfn for any modulator
 	k3gate	table3	k3phs,idevfn
 	k4gate	table3	k4phs,iampfn
 	k5gate	table3	k5phs,idevfn
 	k6gate	table3	k6phs,idevfn
	     
        a6sig   oscil3  k6gate,i6hz,1

        a5sig   oscil3  k5gate,i5hz,1

	a4phs   phasor  i4hz
        a4sig   table3  a4phs+a5sig+a6sig,1,1,0,1
        a4sig   =       a4sig*k4gate
  
        a3sig   init    0               ;initialize for feedback
        a3phs   phasor  i3hz
        a3sig   table3  a3phs+a3sig*(.2*ifeed),1,1,0,1
        a3sig   =       a3sig*k3gate

	a2phs   phasor  i2hz
        a2sig   table3  a2phs+a3sig,1,1,0,1
        a2sig   =       a2sig*k2gate

        a1phs   phasor  i1hz
        a1sig   table3  a1phs+a2sig,1,1,0,1
        a1sig   =       a1sig*k1gate

aenv linen 1, 0.01, idur, 0.01
		aout = (a1sig+a4sig)*ipkamp

aexit = aout*aenv
;                out     aout

krtl       =      sqrt(2) / 2 * cos(iSpace) + sin(iSpace)
krtr       =      sqrt(2) / 2 * cos(iSpace) - sin(iSpace)

zawm aexit*krtl, izoutL
zawm aexit*krtr, izoutR

		endin

;---------------------------------------------------------------------------
;Alto Flute. A mix of Andrea Valles metallic flute and the c#4 sharc timbre altoflute by Steven Yi. 
;---------------------------------------------------------------------------
     instr 25
idur  = p3
iSpace = p7  ;	 
iamp = ampdb(p4)
ifreq = cpsoct(p5)
kenvamp = iamp
ichuffdur = 0.25
ichuffamount = p6 + 0.001
izoutl = p8
izoutr = p9

krtl       =      sqrt(2) / 2 * cos(iSpace) + sin(iSpace)
krtr       =      sqrt(2) / 2 * cos(iSpace) - sin(iSpace)

kdeclick expseg 0.0000001, 0.08, 1, idur - 0.11, 1, 0.03, 0.0000001

anoise  rand   kenvamp                         ; noise
denorm anoise ;I doubt it makes a difference, but ...
afiltnoise    reson  anoise,  ifreq, ifreq/100, 2    
afiltnoise    linen  afiltnoise, .1, idur, .1
afiltnoise = afiltnoise*kdeclick

; chuff
kbandw = 5
kampscale expseg 0.0000001, 0.08, ichuffamount, 0.03 ,0.1, 0.8, 0.00001

kenv1 expseg 0.001, ichuffdur*0.02, 0.1, ichuffdur*.08, 0.2, ichuffdur*0.1, 0.4, ichuffdur*0.3, 0.1, ichuffdur*0.5, 0.1 
; filter the noise
afilt      reson anoise, ifreq/2, 2 * kenv1, 2
afilt2     reson anoise, ifreq, 5 * kenv1, 2
afilt3     reson anoise, ifreq*1.01, 7 * kenv1, 2
afilt4     reson anoise, ifreq*2.06, 10 * kenv1, 2
afilt5     reson anoise, ifreq*3.12, 25 * kenv1, 2
afilt6     reson anoise, ifreq*4.19, 90 * kenv1,2

ares     =     kampscale*(afilt+afilt2+afilt3+afilt4+afilt5+afilt6)
; mix in sharc tone
kenv linseg 0.0, 0.08, 1, idur*0.9 - 0.08, 1, idur*0.1, 0.17

iamp1	=		ampdb(p4 - 0.0)
a1	oscili  	kenv * iamp1, ifreq *1 , 1, -85.40394302661025
iamp2	=		ampdb(p4 - 9.97085)
a2	oscili  	kenv * iamp2, ifreq *2 , 1, -117.51135195015132
iamp3	=		ampdb(p4 - 24.3044)
a3	oscili  	kenv * iamp3, ifreq *3 , 1, -108.54456245635393
iamp4	=		ampdb(p4 - 22.7844)
a4	oscili  	kenv * iamp4, ifreq *4 , 1, -165.43640672386903
iamp5	=		ampdb(p4 - 41.461)
a5	oscili  	kenv * iamp5, ifreq *5 , 1, 94.01721756081193
iamp6	=		ampdb(p4 - 40.5835)
a6	oscili  	kenv * iamp6, ifreq *6 , 1, -45.20064045787065
iamp7	=		ampdb(p4 - 49.506)
a7	oscili  	kenv * iamp7, ifreq *7 , 1, 142.48543632431364
iamp8	=		ampdb(p4 - 51.8591)
a8	oscili  	kenv * iamp8, ifreq *8 , 1, -32.01344384513962
iamp9	=		ampdb(p4 - 53.9261)
a9	oscili  	kenv * iamp9, ifreq *9 , 1, -134.52418776097085
iamp10	=		ampdb(p4 - 67.1194)
a10	oscili  	kenv * iamp10, ifreq *10 , 1, 22.19638498336809
iamp11	=		ampdb(p4 - 61.8287)
a11	oscili  	kenv * iamp11, ifreq *11 , 1, -94.18165644801446
iamp12	=		ampdb(p4 - 67.7028)
a12	oscili  	kenv * iamp12, ifreq *12 , 1, -5.583473713549872
iamp13	=		ampdb(p4 - 78.2529)
a13	oscili  	kenv * iamp13, ifreq *13 , 1, -126.53371835007638
iamp14	=		ampdb(p4 - 69.2244)
a14	oscili  	kenv * iamp14, ifreq *14 , 1, -51.17315251431435
iamp15	=		ampdb(p4 - 76.9442)
a15	oscili  	kenv * iamp15, ifreq *15 , 1, -25.435315399242633
iamp16	=		ampdb(p4 - 69.199)
a16	oscili  	kenv * iamp16, ifreq *16 , 1, -14.78288407217037
iamp17	=		ampdb(p4 - 83.0135)
a17	oscili  	kenv * iamp17, ifreq *17 , 1, 52.21650865924758

ashfl sum a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17
amix = afiltnoise + (ashfl * 0.5) + ares
;outs    amix * sin(ipan), amix*cos(ipan)
zawm amix * krtl, izoutl
zawm amix * krtr, izoutr

	 endin

;---------------------------------------------------------------------------
;Bass. based on CB_a#1 Sharc Timbre coded by Steven Yi
;---------------------------------------------------------------------------
	instr 12	
idur = p3
ifreq 	= 	cpsoct(p5)
iamp	=	p4; p4 in decibels, although this seems to be a redundant statement.
iSpace	=	p6		;range -1(L) to 1(R)
kenvl 	= 	p7 ;envelopes - 0 == ><, 1 == <>, 2 ==>, 3 == <, 4 == --  
izL = 		p8 
izR = 		p9

if (kenvl == 0) then 				;hammer attack, then swells toward end.
	kenv expseg 0.00001, 0.01, 1, idur*0.83, 0.07, idur * 0.17, 0.47
	kenv  ExpCurve  kenv, 23 
elseif (kenvl == 1) then 			; fade in, fade out 
	kenv linseg 0.0, idur*0.63, 1, idur * 0.37, 0.0	
elseif (kenvl == 2) then 			; fade out
	kenv expseg 0.00001, 0.01, 1, idur*0.83, 0.07, idur * 0.17, 0.00001
	kenv  ExpCurve  kenv, 23
elseif (kenvl == 3) then 			; fade in
	kenv expseg 0.00001, idur, 1
	kenv  ExpCurve  kenv, 23
elseif (kenvl == 4) then 			; flat, no envelope shape.
	kenv = 1
endif

krtl       =      sqrt(2) / 2 * cos(iSpace) + sin(iSpace)
krtr       =      sqrt(2) / 2 * cos(iSpace) - sin(iSpace)

iamp1	=		ampdb(p4 - 9.02954)
a1	oscili  	kenv * iamp1, ifreq *1 , 1, 168.47308303806238
iamp2	=		ampdb(p4 - 3.97036)
a2	oscili  	kenv * iamp2, ifreq *2 , 1, 125.81752110616287
iamp3	=		ampdb(p4 - 0.0)
a3	oscili  	kenv * iamp3, ifreq *3 , 1, 83.24962171691836
iamp4	=		ampdb(p4 - 2.82998)
a4	oscili  	kenv * iamp4, ifreq *4 , 1, 25.2393638333079
iamp5	=		ampdb(p4 - 19.0843)
a5	oscili  	kenv * iamp5, ifreq *5 , 1, 171.31781849088696
iamp6	=		ampdb(p4 - 14.9703)
a6	oscili  	kenv * iamp6, ifreq *6 , 1, -38.333168325432595
iamp7	=		ampdb(p4 - 22.7296)
a7	oscili  	kenv * iamp7, ifreq *7 , 1, 45.072297911761346
iamp8	=		ampdb(p4 - 32.2081)
a8	oscili  	kenv * iamp8, ifreq *8 , 1, 18.638317075605677
iamp9	=		ampdb(p4 - 15.751)
a9	oscili  	kenv * iamp9, ifreq *9 , 1, -141.2444097400603
iamp10	=		ampdb(p4 - 52.8297)
a10	oscili  	kenv * iamp10, ifreq *10 , 1, -125.89888111307145
iamp11	=		ampdb(p4 - 30.7652)
a11	oscili  	kenv * iamp11, ifreq *11 , 1, -166.37376567670307
iamp12	=		ampdb(p4 - 31.2839)
a12	oscili  	kenv * iamp12, ifreq *12 , 1, -69.49748871818834
iamp13	=		ampdb(p4 - 35.3827)
a13	oscili  	kenv * iamp13, ifreq *13 , 1, -82.4583670018427
iamp14	=		ampdb(p4 - 34.8446)
a14	oscili  	kenv * iamp14, ifreq *14 , 1, 138.78928558792472
iamp15	=		ampdb(p4 - 44.1251)
a15	oscili  	kenv * iamp15, ifreq *15 , 1, -113.40439047465358
iamp16	=		ampdb(p4 - 28.3039)
a16	oscili  	kenv * iamp16, ifreq *16 , 1, 61.62676748647622
iamp17	=		ampdb(p4 - 33.973)
a17	oscili  	kenv * iamp17, ifreq *17 , 1, -65.48506527888718
iamp18	=		ampdb(p4 - 41.3956)
a18	oscili  	kenv * iamp18, ifreq *18 , 1, 178.14403766207553
iamp19	=		ampdb(p4 - 36.8457)
a19	oscili  	kenv * iamp19, ifreq *19 , 1, -149.32999014494646
iamp20	=		ampdb(p4 - 49.337)
a20	oscili  	kenv * iamp20, ifreq *20 , 1, 34.25771952866705
iamp21	=		ampdb(p4 - 46.4778)
a21	oscili  	kenv * iamp21, ifreq *21 , 1, -157.86706129239573
iamp22	=		ampdb(p4 - 34.4249)
a22	oscili  	kenv * iamp22, ifreq *22 , 1, 145.93521520879634
iamp23	=		ampdb(p4 - 32.4102)
a23	oscili  	kenv * iamp23, ifreq *23 , 1, -41.94051060357626
iamp24	=		ampdb(p4 - 36.1113)
a24	oscili  	kenv * iamp24, ifreq *24 , 1, 61.30419224781757
iamp25	=		ampdb(p4 - 44.9083)
a25	oscili  	kenv * iamp25, ifreq *25 , 1, 40.034852976971145
iamp26	=		ampdb(p4 - 38.4064)
a26	oscili  	kenv * iamp26, ifreq *26 , 1, -109.33352534024908
iamp27	=		ampdb(p4 - 35.9729)
a27	oscili  	kenv * iamp27, ifreq *27 , 1, 72.49463094451767
iamp28	=		ampdb(p4 - 36.7911)
a28	oscili  	kenv * iamp28, ifreq *28 , 1, 150.64320941138632
iamp29	=		ampdb(p4 - 41.0166)
a29	oscili  	kenv * iamp29, ifreq *29 , 1, 55.96479855499342
iamp30	=		ampdb(p4 - 35.339)
a30	oscili  	kenv * iamp30, ifreq *30 , 1, 5.224802133797977
iamp31	=		ampdb(p4 - 44.4004)
a31	oscili  	kenv * iamp31, ifreq *31 , 1, -88.85257599550268
iamp32	=		ampdb(p4 - 38.1442)
a32	oscili  	kenv * iamp32, ifreq *32 , 1, -107.23420797888976

aout sum a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32

kdeclick linseg 0,0.009,0, 0.003,1,idur-0.015,1,0.003,0

aLeft 	=	(aout * krtl) * kdeclick
aRight	=	(aout * krtr) * kdeclick

;	outs 	aLeft, aRight
zawm aLeft, izL
zawm aLeft, izR

	endin

;---------------------------------------------------------------------------
;Sean Costello's Gong. Seems to need kr==sr
;---------------------------------------------------------------------------
instr 99  

izoutl = p7
izoutr = p8

afilt1 init 0
afilt2 init 0
afilt3 init 0
afilt4 init 0
adel1 init 0
adel2 init 0
adel3 init 0
adel4 init 0
alimit1 init 0
alimit2 init 0
alimit3 init 0
alimit4 init 0
alimita init 0
alimitb init 0
alimitc init 0
alimitd init 0

anoise=0
ipi = 3.141592654
idel1 = 1/p4 
ilooptime = idel1 * 3
idel2 = 1/p4 * 2.25
idel3 = 1/p4 * 3.616
idel4 = 1/p4 * 5.06

iamp=12000
ipitchmod = 0
idur = p3

ilimit1 = (1 - ipi * p5 / sr) / (1 + ipi * p5 / sr)
ilimit2 = (1 - ipi * p6 / sr) / (1 + ipi * p6 / sr)

; "strike" the gong.
krandenv linseg 1, ilooptime, 1, 0, 0, p3-ilooptime, 0
anoise  oscili  krandenv * 1.2, p4, 1

igain = 0.999 * 0.70710678117      ; gain of reverb

k1      randi   .001, 3.1, .06
k2      randi   .0011, 3.5, .9
k3      randi   .0017, 1.11, .7
k4      randi   .0006, 3.973, .3


adum1   delayr  1
adel1a  deltapi idel1 + k1 * ipitchmod
        delayw  anoise + afilt2 + afilt3

kdel1 downsamp adel1a
        if kdel1 < 0 goto or
        klimit1 = ilimit1
        goto next
or:
        klimit1 = ilimit2
        next:
        ax1     delay1  adel1a
        adel1 = klimit1 * (adel1a + adel1) - ax1

; Repeat the above for the next 3 delay lines.
adum2   delayr  1
adel2a  deltapi idel2 + k2 * ipitchmod
        delayw  anoise - afilt1 - afilt4

kdel2 downsamp adel2a
        if kdel2 < 0 goto or2
        klimit2 = ilimit1
        goto next2
or2:
        klimit2 = ilimit2
        next2:
        ax2     delay1  adel2a
        adel2 = klimit2 * (adel2a + adel2) - ax2

adum3   delayr  1
adel3a  deltapi idel3 + k3 * ipitchmod
        delayw  anoise + afilt1 - afilt4

kdel3 downsamp adel3a
        if kdel3 < 0 goto or3
        klimit3 = ilimit1
        goto next3
or3:
        klimit3 = ilimit2
        next3:
        ax3     delay1  adel3a
        adel3 = klimit3 * (adel3a + adel3) - ax3

adum4   delayr  1
adel4a  deltapi idel4 + k4 * ipitchmod
        delayw  anoise + afilt2 - afilt3

kdel4 downsamp adel4a
        if kdel4 < 0 goto or4
        klimit4 = ilimit1
        goto next4
or4:
        klimit4 = ilimit2
        next4:
        ax4     delay1  adel4a
        adel4 = klimit4 * (adel4a + adel4) - ax4

afilt1  tone    adel1 * igain, 20000
afilt2  tone    adel2 * igain, 20000
afilt3  tone    adel3 * igain, 20000
afilt4  tone    adel4 * igain, 20000

aoutl =  (afilt1 + afilt3) * iamp
aoutr =  (afilt2 + afilt4) * iamp

aoutl dcblock aoutl
aoutr dcblock aoutr

kenv linseg 1,idur*0.9,1,idur*0.1,0
aoutl = aoutl*kenv
aoutr = aoutr*kenv
zawm aoutl,izoutl
zawm aoutr,izoutr
;outs aoutl,aoutr
endin

;---------------------------------------------------------------------------
;bank of string resonators, probably from Istvan Varga
;---------------------------------------------------------------------------

instr 101

idur = p3
ifdbk = p4
itfn = p5
isfn = p6
iinscale = 0.3
izin = p7
izout = p8

ain zar izin 
ain = ain * iinscale
denorm ain

#define SOURCE(SNDX) #isource$SNDX table $SNDX, isfn, 0 #

#define TARGET(TNDX) #itarget$TNDX table $TNDX, itfn, 0 #

#define KRING(NUM) #kring$NUM line isource$NUM, idur, itarget$NUM # ;a hack, I removed reference to Ksource

#define STRESON(FREQ) #a$FREQ streson ain, cpsoct(kring$FREQ), ifdbk#


$SOURCE(0)
$SOURCE(1)
$SOURCE(2)
$SOURCE(3)
$SOURCE(4)
$SOURCE(5)
$SOURCE(6)
$SOURCE(7)

$TARGET(0)
$TARGET(1)
$TARGET(2)
$TARGET(3)
$TARGET(4)
$TARGET(5)
$TARGET(6)
$TARGET(7)

$KRING(0)
$KRING(1)
$KRING(2)
$KRING(3)
$KRING(4)
$KRING(5)
$KRING(6)
$KRING(7)

$STRESON(0)
$STRESON(1)
$STRESON(2)
$STRESON(3)
$STRESON(4)
$STRESON(5)
$STRESON(6)
$STRESON(7)
aout sum a0, a1, a2, a3, a4, a5, a6, a7

aexit balance aout, ain 

zawm aexit, izout
;outs aexit, aexit
endin

;---------------------------------------------------------------------------
;fm piano based on ACCCI: 20_10_1.ORC
;---------------------------------------------------------------------------

instr 21  

idur   = p3
iamp   = p4
ifenv  = 51                    ; bell settings:
ifdyn  = 52                    ; amp and index envelopes are exponential

ifq2   = cpsoct(p5)*3			
if2    = 50
ifq1   = cpsoct(p5)*4          ; decreasing, N1:N2 is 5:7, imax=10 (ifq1 = 5, ifq2 = 7)
if1    = 49                     ; duration = 15 sec

imax   = p6
izoutL = p7	
izoutR = p8	

   aenv  oscili  iamp, 1/idur, ifenv             ; envelope

   adyn  oscili  ifq2*imax, 1/idur, ifdyn       ; dynamic
   amod  oscili  adyn, ifq2, if2                 ; modulator

   a1    oscili  aenv, ifq1+amod, if1            ; carrier

kdpth linseg 0.0015, p3, 0.0075
al, ar ensembleChorus a1, 	0.007, kdpth, 0.2, 		1.1, 		17, 	1

zawm al, izoutL 
zawm ar, izoutR 

endin 

;---------------------------------------------------------------------------
;based on sharc vlc_c#3 coded by Steven Yi
;---------------------------------------------------------------------------

	instr 386	;
idur = p3
ifreq 	= 		cpsoct(p5)
iamp	=		p4
iSpace	=	    p6		;range -1(L) to 1(R)
kenvl 	= 		p7 ;0 == ><, 1 == <>, 2 == >, 3 == <, 4 == --  
izoutl = 		p8
izoutr = 		p9

if (kenvl == 0) then 			;hammer attack, then swells toward end.
	kenv expseg 0.00001, 0.01, 1, idur*0.83, 0.07, idur * 0.17, 0.47
	kenv  ExpCurve  kenv, 23 
elseif (kenvl == 1) then 		; fade in, fade out 
	kenv linseg 0.0, idur*0.63, 1, idur * 0.37, 0.0	
elseif (kenvl == 2) then 		; hammer attack, fade out
	kenv expseg 0.00001, 0.01, 1, idur*0.83, 0.07, idur * 0.17, 0.00001
	kenv  ExpCurve  kenv, 23
elseif (kenvl == 3) then 		; linear fade in
	kenv line 0.00001, idur, 1
elseif (kenvl == 4) then 		; flat, no envelope shape.
	kenv = 1
endif

krtl       =      sqrt(2) / 2 * cos(iSpace) + sin(iSpace)
krtr       =      sqrt(2) / 2 * cos(iSpace) - sin(iSpace)

iamp1	=		ampdb(p4 - 3.322)
a1	oscili  	kenv * iamp1, ifreq *1 , 1, 122.2342430554147
iamp2	=		ampdb(p4 - 0.0)
a2	oscili  	kenv * iamp2, ifreq *2 , 1, -32.48613402612255
iamp3	=		ampdb(p4 - 10.2029)
a3	oscili  	kenv * iamp3, ifreq *3 , 1, 51.8675773620129
iamp4	=		ampdb(p4 - 16.0018)
a4	oscili  	kenv * iamp4, ifreq *4 , 1, 147.33953476466198
iamp5	=		ampdb(p4 - 5.91947)
a5	oscili  	kenv * iamp5, ifreq *5 , 1, 120.91472125322841
iamp6	=		ampdb(p4 - 21.6811)
a6	oscili  	kenv * iamp6, ifreq *6 , 1, 117.85741845841034
iamp7	=		ampdb(p4 - 14.194)
a7	oscili  	kenv * iamp7, ifreq *7 , 1, 171.99276277355102
iamp8	=		ampdb(p4 - 20.0842)
a8	oscili  	kenv * iamp8, ifreq *8 , 1, 106.65666652139788
iamp9	=		ampdb(p4 - 29.5864)
a9	oscili  	kenv * iamp9, ifreq *9 , 1, 16.72979466002491
iamp10	=		ampdb(p4 - 19.3068)
a10	oscili  	kenv * iamp10, ifreq *10 , 1, 28.921190624818568
iamp11	=		ampdb(p4 - 20.8182)
a11	oscili  	kenv * iamp11, ifreq *11 , 1, 95.74525827092647
iamp12	=		ampdb(p4 - 25.7879)
a12	oscili  	kenv * iamp12, ifreq *12 , 1, -122.01021655751855
iamp13	=		ampdb(p4 - 25.6864)
a13	oscili  	kenv * iamp13, ifreq *13 , 1, 26.128021373555796
iamp14	=		ampdb(p4 - 31.8981)
a14	oscili  	kenv * iamp14, ifreq *14 , 1, 74.56701928950585
iamp15	=		ampdb(p4 - 40.2342)
a15	oscili  	kenv * iamp15, ifreq *15 , 1, 0.1822005788516018
iamp16	=		ampdb(p4 - 30.1734)
a16	oscili  	kenv * iamp16, ifreq *16 , 1, 95.72176700132611
iamp17	=		ampdb(p4 - 34.0159)
a17	oscili  	kenv * iamp17, ifreq *17 , 1, -179.83311724212123
iamp18	=		ampdb(p4 - 33.6416)
a18	oscili  	kenv * iamp18, ifreq *18 , 1, -142.56851520460762
iamp19	=		ampdb(p4 - 45.9021)
a19	oscili  	kenv * iamp19, ifreq *19 , 1, -66.76505299320944
iamp20	=		ampdb(p4 - 27.1627)
a20	oscili  	kenv * iamp20, ifreq *20 , 1, -114.26268125175955
iamp21	=		ampdb(p4 - 40.2261)
a21	oscili  	kenv * iamp21, ifreq *21 , 1, 13.634103692933069
iamp22	=		ampdb(p4 - 36.4115)
a22	oscili  	kenv * iamp22, ifreq *22 , 1, -71.15734745068232
iamp23	=		ampdb(p4 - 48.7777)
a23	oscili  	kenv * iamp23, ifreq *23 , 1, 50.31543469500351
iamp24	=		ampdb(p4 - 45.6746)
a24	oscili  	kenv * iamp24, ifreq *24 , 1, 56.64489945781371
iamp25	=		ampdb(p4 - 51.2239)
a25	oscili  	kenv * iamp25, ifreq *25 , 1, 86.61975946787787
iamp26	=		ampdb(p4 - 45.8497)
a26	oscili  	kenv * iamp26, ifreq *26 , 1, 62.079404144629564
iamp27	=		ampdb(p4 - 44.244)
a27	oscili  	kenv * iamp27, ifreq *27 , 1, 62.93425717496476
iamp28	=		ampdb(p4 - 54.0526)
a28	oscili  	kenv * iamp28, ifreq *28 , 1, 73.11514423664435
iamp29	=		ampdb(p4 - 48.7439)
a29	oscili  	kenv * iamp29, ifreq *29 , 1, 102.51303574701177
iamp30	=		ampdb(p4 - 55.8329)
a30	oscili  	kenv * iamp30, ifreq *30 , 1, 162.2868577240349
iamp31	=		ampdb(p4 - 52.1085)
a31	oscili  	kenv * iamp31, ifreq *31 , 1, -120.86716575623255
iamp32	=		ampdb(p4 - 56.8172)
a32	oscili  	kenv * iamp32, ifreq *32 , 1, -155.06415175861574

aout sum a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32

kdeclick linseg 0, 0.03, 1, idur - 0.06, 1, 0.03, 0

aLeft 	=	aout * krtl * kdeclick
aRight	=	aout * krtr * kdeclick


zawm aLeft, izoutl
zawm aRight, izoutr
;	outs 	aLeft, aRight
	endin

;---------------------------------------------------------------------------
; Tremelo - based on a tremolo instrument by Hans Mickelson
;---------------------------------------------------------------------------
          instr 387

idur 	= 	  p3		   ; Duration
iamp    =     p4           ; Amplitude
ifqcst  =     p5           ; Frequency start
ifqcend = 	  p6		   ; Frequency end
itab1   =     p7           ; Waveform
idepth  =     p8           ; idepth
izin    =     p9           ; Input channel
izout   =     p10           ; Output channel

asig    zar   izin         ; Read input channel

kfqc	line  ifqcst,idur,ifqcend 
kosc    oscil iamp, kfqc, itab1, 0   ; LFO
;  aout    =     asig*(kosc+1)/2             ; Adjust to 0-1 range and multiply
aout    =     (asig*(kosc))            ; Adjust to 0-1 range and multiply

zawm   aout, izout  ; Write to output channel

          endin
;---------------------------------------------------------------------------
; Ensemble chorus - by Steven Cook
;--------------------------------------------------------------------------- 
instr    388 ; Dual 3-Phase BBD Ensemble.

ilevl    = 0.5    ; Output level
idepth   = p4/1000   ; Depth factor
irate1   = 0.033      ; LFO1 rate
irate2   = 0.041      ; LFO2 rate
irate3   = 0.056      ; LFO3 rate
irate4   = 0.0667      ; LFO4 rate
imin     = 1/kr    ; Minimum delay
izin 	 = p5
izoutl   = p6
izoutr   = p7
ain zar izin
denorm ain
idepth1  = idepth*(1/irate1)
idepth2  = idepth*(1/irate2)
idepth3  = idepth*(1/irate3)
idepth4  = idepth*(1/irate4)
alfo1a   oscili  idepth1, irate1, 61
alfo1b   oscili  idepth1, irate1, 61, .3333
alfo1c   oscili  idepth1, irate1, 61, .6667
alfo2a   oscili  idepth2, irate2, 61
alfo2b   oscili  idepth2, irate2, 61, .3333
alfo2c   oscili  idepth2, irate2, 61, .6667
alfo3a   oscili  idepth3, irate3, 61
alfo3b   oscili  idepth3, irate3, 61, .3333
alfo3c   oscili  idepth3, irate3, 61, .6667
alfo4a   oscili  idepth4, irate4, 61
alfo4b   oscili  idepth4, irate4, 61, .3333
alfo4c   oscili  idepth4, irate4, 61, .6667
ax       delayr  1
abbd1	   deltapi  alfo1a + alfo2a + imin
abbd2	   deltapi  alfo1b + alfo2b + imin
abbd3    deltapi  alfo1c + alfo2c + imin
abbd4    deltapi  alfo3a + alfo4a + imin
abbd5    deltapi  alfo3b + alfo4b + imin
abbd6    deltapi  alfo3c + alfo4c + imin
         delayw  ain
;outs1    (abbd1 + abbd2 + abbd3)*ilevl
;outs2    (abbd4 + abbd5 + abbd6)*ilevl

aouts1  =  (abbd1 + abbd2 + abbd3)*ilevl
aouts2  =  (abbd4 + abbd5 + abbd6)*ilevl

zawm aouts1,izoutl
zawm aouts2,izoutr

endin

;---------------------------------------------------------------------------
; Reverb with Phaser
;--------------------------------------------------------------------------- 

instr 389

idur = p3
;iscale = p4
irevfdbkst = p5
irevfdbkend = p6
iscale = 1 / irevfdbkst

iphswp = p7
iphrate = p8
iphfdbk = p9
iq = p10

izinl = p11
izinr = p12
izoutl = p13
izoutr = p14

ainL zar izinl
ainR zar izinr
denorm ainL, ainR

klfo1 lfo iphswp, iphrate, 0
kphfrq1 = klfo1 + (iphswp + 1500) 

klfo2 lfo 0.5, iphrate*0.63, 1
klfo2 = klfo2 + 0.5

klfo3 lfo iphswp, iphrate*0.77, 0
kphfrq2 = klfo1 + (iphswp + 1500) 

klfo4 lfo 0.5, iphrate*0.53, 1
klfo4 = klfo2 + 0.5

krevfdbk line irevfdbkst, idur, irevfdbkend
;arvL, arvR reverbsc ainL, ainR, irevfdbk, 19000, sr, 2 ;a bit mellow
denorm ainL, ainR
arvL, arvR freeverb ainL, ainR, krevfdbk, 0, sr

aresl phaser2 arvL, kphfrq1, iq, 12, 1, klfo2, iphfdbk
aresr phaser2 arvR, kphfrq1, iq, 12, 1, klfo2, iphfdbk
aresl phaser2 aresl, kphfrq2, iq, 12, 1, klfo4, iphfdbk
aresr phaser2 aresr, kphfrq2, iq, 12, 1, klfo4, iphfdbk

kdeclick linen 1, 0.25, idur-0.1, 0.05 

;aresl = aresl * iscale ;scale signal if using reverbsc				
;aresr = aresr * iscale ;balance doesn't seem to work well with my flute

zawm aresl, izoutl
zawm aresr, izoutr

endin

;---------------------------------------------------------------------------
; Freeverb
;--------------------------------------------------------------------------- 
instr 400

idur = p3
iroomsizest = p4 	;0-1
iroomsizeend = p5 ;0-1
idamp = p6		;0-1
izinL = p7
izinR = p8
izoutL = p9
izoutR = p10

ainL zar izinL
ainR zar izinR
krevline line iroomsizest,idur,iroomsizeend
denorm ainL, ainR
aoutL, aoutR freeverb ainL, ainR, krevline, idamp, sr

zawm aoutL,izoutL 
zawm aoutR,izoutR  

endin

;---------------------------------------------------------------------------
; Post Mixing output
;--------------------------------------------------------------------------- 
instr 980
idur  = p3 
ainL = gapinL
ainR = gapinR

aoutL	compress	ainL, ainL, 0, 68, 79, 1.7, .18, .37, .08	; 
aoutR	compress	ainR, ainR, 0, 68, 79, 1.7, .18, .37, .08	; 

aoutL clip aoutL,0,0dbfs,0.93
aoutR clip aoutR,0,0dbfs,0.93

outs aoutL, aoutR

gapinL = 0
gapinR = 0
 
endin

</CsInstruments>
<CsScore>
;;;Diving Part I
;;;Thorin Kerr 19-07-2006
;;;


f 1 0 8193 10 1
f 22 0 256 1 "marmstk1.wav" 0 0 0
f 23 0 1025 13 1 1 0 -1 0 0.4

;streson pitches
f 26  0  8  -2  7.017921908  7.43295940728 7.65535182861 7.90689059561 8.16992500144
8.49185309633 8.84799690655 8.9772799235
f 27  0  8  -2  8.16992500144 8.49185309633 8.84799690655 8.9772799235 7.017921908
7.43295940728 7.65535182861 7.90689059561 
; bellpno waves
f 49  0  512  10  1		0   0.05  0  0.01
f 50  0  512	10	1		.1		.3  .02  .1		
; bellpno envelopes
f 51 0 512 5 1 513 .0101
f 52 0 512 5 1 513 .1

f 61 0 8193 19 1 1 0 1 ; ENSEMBLE Unipolar sine
f 201 0 65 8 0 8 0 1 1 50 1 1 0 8 0 ;tremolo shape

;dxftables f 2-11
;f01     0       8192     10      1 ;already stated
; operator output level to amp scale function (data from Chowning/Bristow)
f02     0       128     7       0       10      .003    10      .013
        10      .031    10      .079    10      .188    10      .446
        5       .690    5       1.068   5       1.639   5       2.512
        5       3.894   5       6.029   5       9.263   4       13.119
        29      13.119
; rate scaling function
f03     0       128     7       0       128     1
; eg rate rise function for lvl change between 0 and 99 (data from Opcode)
f04     0       128     -7      38      5       22.8    5       12      5
        7.5     5       4.8     5       2.7     5       1.8     5       1.3
        8       .737    3       .615    3       .505    3       .409    3       
        .321    6       .080    6       .055    2       .032    3       .024
        3       .018    3       .014    3       .011    3       .008    3       
        .008    3       .007    3       .005    3       .003    32      .003
; eg rate rise percentage function
f05     0       128     -7      .00001  31      .00001  4       .02     5
        .06     10      .14     10      .24     10      .35     10      .50
        10      .70     5       .86     4       1.0     29      1.0
; eg rate decay function for lvl change between 0 and 99
f06     0       128     -7      318     4       181     5       115     5
        63      5       39.7    5       20      5       11.2    5       7       
        8       5.66    3       3.98    6       1.99    3       1.34    3       
        .99     3       .71     5       .41     3       .15     3       .081
        3       .068    3       .047    3       .037    3       .025    3
        .02     3       .013    3       .008    36      .008
; eg rate decay percentage function
f07     0       128     -7      .00001  10      .25     10      .35     10
        .43     10      .52     10      .59     10      .70     10      .77
        10      .84     10      .92     9       1.0     29      1.0
; eg level to peak deviation mapping function (index in radians = Index / 2PI)
f08     0       128     -7      0       10      .000477 10      .002
        10      .00493  10      .01257  10      .02992  10      .07098
        5       .10981  5       .16997  5       .260855 5       .39979
        5       .61974  5       .95954  5       1.47425 4       2.08795
        29      2.08795
; velocity to amp factor mapping function (rough guess)
f09     0       129     9       .25     1       0
; velocity sensitivity scaling function
f10     0       8       -7      0       8       1
; feedback scaling function
f11     0       8       -7      0       8       7 
;f12 - f17 are specify the tone from the algorithm
;ftables for use with algorithm 10 
        
f12   0    32    -2    99    4   				30   80   27   51   
        										80   80   3   3   
        										0   0   1.0   -4   
        										2   
f13   0    32    -2    79    5   							69   48   27   36   
        												 	97   97   3   3   
        													0   0   1.0   -4   
        													3   
f14   0    32    -2    79    5   				40   81   32   50   
        										29   97   41   3   
        										0   0   2.0   -3   
        										4   
f15   0    32    -2    99    5   							97   45   10   51   
        													97   59   10   50   
        													2   0   1.0   4   
        													2   
f16   0    32    -2    55    4   				50   49   27   36   
        										97   97   3   3   
        										0   0   1   4   
        										3   
f17   0    32    -2    46    3   							50   97   35   50   
        													97   97   3   3   
        													0   0     1   7   
        													4 

;initial dummy note to set pfields
;ins	sta	dur	pit	vel	pan   zakL	zakR
i11	0.0	4	8.01	0	0	3	4	86
	12	13	14	15	16	17	2	18000
	3	8	4	6	10	9	11	7

;MIXER ENVELOPES 
f 80 0 3 27 0 1 2 1 ;FLAT LEVEL
f 81 0 4097 -27 0 1 2300 1 ;DX
f 82 0 4097 -27 0 1 600 0.5 900 1 2300 0.5 ;DXO
f 83 0 4097 -27 0 1 2300 1 ;VIBES
f 84 0 4097 -27 0 1 2300 1 ;VIBESO
f 85 0 4097 -27 0 0.6 599 0.6 600 1 2300 1 ;FLUTE
f 86 0 4097 -27 0 0.8 2000 1 2001 2300 1 ;FLUTEO
f 87 0 4097 -27 0 1.0 600 0.6 900 0.5 2300 0.1 ;BELL
f 88 0 4097 -27 0 0.6 600 1 900 0.5 2300 0.1 ;BELLO
f 89 0 4097 -27 0 1.2 420 1 1140 0.8 1200 0 2300 0 ;Astrings
f 90 0 4097 -27 0 0 419 0 420 1 2300 1 ;CB
f 91 0 8193 -27 0 1 1140 0.6 1600 0.5 2450 0.2 2540 0.35 2620 0.4 2830 1.0 4096 
0.5 7595 1.4 8192 1.4 ;GONG

#define DUR1 # 230 #
#define DURT # 88 # sectiondur is 83, but cbswell extends by 5
#define DUR2 # 220 #
#define DURT2 # 100 #
#define DURC # 202 #

#define MIXDUR1 #i900 0 $DUR1 #
#define MIXDURTRANS #i900 0 $DURT #
#define MIXDUR2 #i900 0 $DUR2 #
#define MIXDURT2 #i900 0 $DURT2 #
#define MIXDURCODA #i900 0 $DURC #

i980 0 780 ;POST mixer instrument
;;;;;;;;;;;;;;;;;;;;;
;PART A
;;;;;;;;;;;;;;;;;;;;;
;Vibes
 i 18 0.00589756765916 6 5000 8.05889 1 2 
 i 18 5.99722747299 6 5000 8.22882 1 2 
 i 18 12.0091602173 6 5000 8.05889 1 2 
 i 18 18.0083531643 6 5000 8.22882 1 2 
 i 18 23.9904373472 6 5000 8.05889 1 2 
 i 18 30.0075515435 6 5000 8.22882 1 2 
 i 18 36.0015454202 6 5000 8.05889 1 2 
 i 18 41.9965880477 6 5000 8.22882 1 2 
 i 18 47.9963794716 6 5000 8.05889 1 2 
 i 18 53.9958565574 6 5000 8.22882 1 2 
 i 18 59.9982532483 6 5000 8.05889 1 2 
 i 18 65.9931443552 6 5000 8.22882 1 2 
 i 18 71.9988689192 6 5000 8.05889 1 2 
 i 18 77.9923397185 6 5000 8.22882 1 2 
 i 18 84.0002065722 6 5000 8.05889 1 2 
 i 18 90.0009305962 6 5000 8.22882 1 2 
 i 18 96.0102269111 6 5000 8.05889 1 2 
 i 18 102.005685373 6 5000 8.22882 1 2 
 i 18 107.993260183 6 5000 8.05889 1 2 
 i 18 113.989769217 6 5000 8.22882 1 2 
 i 18 1.00719736788 6 5000 8.05889 1 2 
 i 18 6.00119993892 6 5000 8.64386 1 2 
 i 18 12.9989826381 6 5000 8.79586 1 2 
 i 18 18.0061591019 6 5000 8.05889 1 2 
 i 18 25.0080714649 6 5000 8.64386 1 2 
 i 18 30.0103016085 6 5000 8.79586 1 2 
 i 18 36.9959576444 6 5000 8.22882 1 2 
 i 18 42.0002862844 6 5000 8.64386 1 2 
 i 18 48.9922607088 6 5000 8.79586 1 2 
 i 18 54.0098018885 6 5000 8.22882 1 2 
 i 18 60.9945408486 6 5000 8.05889 1 2 
 i 18 65.9945819825 6 5000 8.79586 1 2 
 i 18 72.9959894925 6 5000 8.22882 1 2 
 i 18 78.0009453101 6 5000 8.05889 1 2 
 i 18 84.9992283064 6 5000 8.64386 1 2 
 i 18 90.0093224065 6 5000 8.22882 1 2 
 i 18 96.9907675925 6 5000 8.05889 1 2 
 i 18 102.002899317 6 5000 8.64386 1 2 
 i 18 108.995438146 6 5000 8.79586 1 2 
 i 18 113.990159139 6 5000 8.22882 1 2 
 i 18 120.995137058 6 5000 8.38082178394 1 2 
 i 18 1.17245577484 4.5 1234.60798591 8.2288186905 13 14 
 i 18 1.33455744147 4.5 1239.55198391 8.38082178394 13 14 
 i 18 1.49780485761 4.5 1244.49598191 8.96578428466 13 14 
 i 18 1.6682739542 4.5 1249.4399799 8.79585928322 13 14 
 i 18 1.83202243744 4.5 1254.3839779 8.96578428466 13 14 
 i 18 2.01079451586 4.5 1259.3279759 8.79585928322 13 14 
 i 18 2.1708148158 4.5 1264.27197389 8.96578428466 13 14 
 i 18 2.34273536945 4.5 1269.21597189 9.2288186905 13 14 
 i 18 2.49326131878 4.5 1274.15996989 9.38082178394 13 14 
 i 18 2.65644840949 4.5 1279.10396788 9.2288186905 13 14 
 i 18 2.83558500477 4.5 1284.04796588 9.38082178394 13 14 
 i 18 3.00915704745 4.5 1288.99196387 9.96578428466 13 14 
 i 18 3.17448762311 4.5 1293.93596187 9.79585928322 13 14 
 i 18 3.33868875236 4.5 1298.87995987 9.96578428466 13 14 
 i 18 3.49108378362 4.5 1303.82395786 9.79585928322 13 14 
 i 18 3.6687371126 4.5 1308.76795586 9.96578428466 13 14 
 i 18 3.82806607429 4.5 1313.71195386 10.2288186905 13 14 
 i 18 3.99169486274 4.5 1318.65595185 10.3808217839 13 14 
 i 18 4.17640318251 4.5 1323.59994985 10.2288186905 13 14 
 i 18 4.3281161904 4.5 1328.54394785 10.3808217839 13 14 
 i 18 4.5014661354 4.5 1333.48794584 10.9657842847 13 14 
 i 18 4.66232724203 4.5 1338.43194384 10.7958592832 13 14 
 i 18 4.82945489951 4.5 1343.37594183 10.9657842847 13 14 
 i 18 5.00461641832 4.5 1348.31993983 10.7958592832 13 14 
 i 18 5.15970394861 4.5 1353.26393783 10.9657842847 13 14 
 i 18 5.33255329772 4.5 1358.20793582 11.2288186905 13 14 
 i 18 5.50376046581 4.5 1363.15193382 11.3808217839 13 14 
 i 18 5.67169908742 4.5 1368.09593182 11.2288186905 13 14 
 i 18 5.843055499 4.5 1373.03992981 8.05889 13 14 
 i 18 5.99540537907 4.5 1377.98392781 11.3808217839 13 14 
 i 18 6.17349620332 4.5 1382.92792551 8.2288186905 13 14 
 i 18 6.15738784165 4.5 1382.9279258 11.9657842847 13 14 
 i 18 6.32694278405 4.5 1387.8719235 8.05889368905 13 14 
 i 18 6.34053747921 4.5 1387.8719238 11.7958592832 13 14 
 i 18 6.49204630622 4.5 1392.8159215 8.2288186905 13 14 
 i 18 6.49508027234 4.5 1392.8159218 11.9657842847 13 14 
 i 18 6.66941084862 4.5 1397.7599195 8.79585928322 13 14 
 i 18 6.66464550134 4.5 1397.75991979 11.7958592832 13 14 
 i 18 6.82513642835 4.5 1402.70391749 8.64385618977 13 14 
 i 18 6.83252922368 4.5 1402.70391779 8.79585928322 13 14 
 i 18 6.99300031916 4.5 1407.64791549 8.64385618977 13 14 
 i 18 7.17433860952 4.5 1412.59191349 8.79585928322 13 14 
 i 18 7.33953727987 4.5 1417.53591148 9.05889368905 13 14 
 i 18 7.50744511221 4.5 1422.47990948 9.2288186905 13 14 
 i 18 7.66124306386 4.5 1427.42390748 9.05889368905 13 14 
 i 18 7.83369613926 4.5 1432.36790547 9.2288186905 13 14 
 i 18 8.00258042843 4.5 1437.31190347 9.79585928322 13 14 
 i 18 8.15906859917 4.5 1442.25590146 9.64385618977 13 14 
 i 18 8.33107457347 4.5 1447.19989946 9.79585928322 13 14 
 i 18 8.49218061581 4.5 1452.14389746 9.64385618977 13 14 
 i 18 8.65790037741 4.5 1457.08789545 9.79585928322 13 14 
 i 18 8.83460255142 4.5 1462.03189345 10.0588936891 13 14 
 i 18 9.00262304241 4.5 1466.97589145 10.2288186905 13 14 
 i 18 9.17011448865 4.5 1471.91988944 10.0588936891 13 14 
 i 18 9.32557855797 4.5 1476.86388744 10.2288186905 13 14 
 i 18 9.48993832035 4.5 1481.80788543 10.7958592832 13 14 
 i 18 9.66562562502 4.5 1486.75188343 10.6438561898 13 14 
 i 18 9.84084681641 4.5 1491.69588143 10.7958592832 13 14 
 i 18 9.99153674467 4.5 1496.63987942 10.6438561898 13 14 
 i 18 10.1606687817 4.5 1501.58387742 10.7958592832 13 14 
 i 18 10.3304480701 4.5 1506.52787542 11.0588936891 13 14 
 i 18 10.4950927559 4.5 1511.47187341 11.2288186905 13 14 
 i 18 10.6714997145 4.5 1516.41587141 11.0588936891 13 14 
 i 18 10.824637595 4.5 1521.35986941 11.2288186905 13 14 
 i 18 11.0068662408 4.5 1526.3038674 11.7958592832 13 14 
 i 18 11.170453083 4.5 1531.2478654 11.6438561898 13 14 
 i 18 11.3350004935 4.5 1536.19186339 11.7958592832 13 14 
 i 18 11.5029664216 4.5 1541.13586139 11.6438561898 13 14 
 i 18 11.6701726893 4.5 1546.07985939 8.64386 13 14 
 i 18 11.8324856032 4.5 1551.02385738 8.79585928322 13 14 
 i 18 13.1565164002 4.5 1590.57584094 8.64385618977 13 14 
 i 18 13.3297438943 4.5 1595.51983894 8.79585928322 13 14 
 i 18 13.4976996632 4.5 1600.46383693 9.38082178394 13 14 
 i 18 13.6646931611 4.5 1605.40783493 9.2288186905 13 14 
 i 18 13.8419335359 4.5 1610.35183292 9.38082178394 13 14 
 i 18 13.9994121576 4.5 1615.29583092 9.2288186905 13 14 
 i 18 14.1631752966 4.5 1620.23982892 9.38082178394 13 14 
 i 18 14.3263399925 4.5 1625.18382691 9.64385618977 13 14 
 i 18 14.5023221632 4.5 1630.12782491 9.79585928322 13 14 
 i 18 14.6740978617 4.5 1635.07182291 9.64385618977 13 14 
 i 18 14.8364914729 4.5 1640.0158209 9.79585928322 13 14 
 i 18 15.004259835 4.5 1644.9598189 10.3808217839 13 14 
 i 18 15.1585248553 4.5 1649.90381689 10.2288186905 13 14 
 i 18 15.327111433 4.5 1654.84781489 10.3808217839 13 14 
 i 18 15.4957024521 4.5 1659.79181289 10.2288186905 13 14 
 i 18 15.6746052632 4.5 1664.73581088 10.3808217839 13 14 
 i 18 15.8237253024 4.5 1669.67980888 10.6438561898 13 14 
 i 18 15.9955754838 4.5 1674.62380688 10.7958592832 13 14 
 i 18 16.1652442871 4.5 1679.56780487 10.6438561898 13 14 
 i 18 16.3245232284 4.5 1684.51180287 10.7958592832 13 14 
 i 18 16.5101262526 4.5 1689.45580087 11.3808217839 13 14 
 i 18 16.664993117 4.5 1694.39979886 11.2288186905 13 14 
 i 18 16.823469363 4.5 1699.34379686 11.3808217839 13 14 
 i 18 16.9939989359 4.5 1704.28779485 11.2288186905 13 14 
 i 18 17.1643536773 4.5 1709.23179285 11.3808217839 13 14 
 i 18 17.3302208278 4.5 1714.17579085 11.6438561898 13 14 
 i 18 17.4923706041 4.5 1719.11978884 11.7958592832 13 14 
 i 18 17.6766485385 4.5 1724.06378684 11.6438561898 13 14 
 i 18 17.83352 4.5 1729.00778484 8.79586 13 14 
 i 18 17.9976265702 4.5 1733.95178283 11.7958592832 13 14 
 i 18 18.1632467788 4.5 1738.89578053 8.96578428466 13 14 
 i 18 18.1593809107 4.5 1738.89578083 12.3808217839 13 14 
 i 18 18.3391605888 4.5 1743.83977853 8.79585928322 13 14 
 i 18 18.3386699614 4.5 1743.83977883 12.2288186905 13 14 
 i 18 18.5026510091 4.5 1748.78377652 8.96578428466 13 14 
 i 18 18.4940632018 4.5 1748.78377682 12.3808217839 13 14 
 i 18 18.6562867982 4.5 1753.72777452 9.55074678538 13 14 
 i 18 18.6633613805 4.5 1753.72777482 12.2288186905 13 14 
 i 18 18.8346763386 4.5 1758.67177252 9.38082178394 13 14 
 i 18 18.8263853444 4.5 1758.67177281 9.55074678538 13 14 
 i 18 18.995187722 4.5 1763.61577051 9.38082178394 13 14 
 i 18 19.1683152464 4.5 1768.55976851 9.55074678538 13 14 
 i 18 19.3420663535 4.5 1773.50376651 9.79585928322 13 14 
 i 18 19.491465473 4.5 1778.4477645 9.96578428466 13 14 
 i 18 19.6764079031 4.5 1783.3917625 9.79585928322 13 14 
 i 18 19.8237508796 4.5 1788.3357605 9.96578428466 13 14 
 i 18 19.9933949716 4.5 1793.27975849 10.5507467854 13 14 
 i 18 20.157264285 4.5 1798.22375649 10.3808217839 13 14 
 i 18 20.3402930707 4.5 1803.16775448 10.5507467854 13 14 
 i 18 20.5037275781 4.5 1808.11175248 10.3808217839 13 14 
 i 18 20.6689403539 4.5 1813.05575048 10.5507467854 13 14 
 i 18 20.8388921212 4.5 1817.99974847 10.7958592832 13 14 
 i 18 20.9899861256 4.5 1822.94374647 10.9657842847 13 14 
 i 18 21.1561253593 4.5 1827.88774447 10.7958592832 13 14 
 i 18 21.3400507855 4.5 1832.83174246 10.9657842847 13 14 
 i 18 21.5019726683 4.5 1837.77574046 11.5507467854 13 14 
 i 18 21.6689694029 4.5 1842.71973846 11.3808217839 13 14 
 i 18 21.8246757366 4.5 1847.66373645 11.5507467854 13 14 
 i 18 21.9934391147 4.5 1852.60773445 11.3808217839 13 14 
 i 18 22.175404937 4.5 1857.55173244 11.5507467854 13 14 
 i 18 22.3258837122 4.5 1862.49573044 11.7958592832 13 14 
 i 18 22.5064757422 4.5 1867.43972844 11.9657842847 13 14 
 i 18 22.6734348322 4.5 1872.38372643 11.7958592832 13 14 
 i 18 22.8394920218 4.5 1877.32772443 11.9657842847 13 14 
 i 18 23.0049466723 4.5 1882.27172243 12.5507467854 13 14 
 i 18 23.1763137066 4.5 1887.21572042 12.3808217839 13 14 
 i 18 23.3416676108 4.5 1892.15971842 12.5507467854 13 14 
 i 18 23.5076784675 4.5 1897.10371641 12.3808217839 13 14 
 i 18 23.6674611279 4.5 1902.04771441 8.05889 13 14 
 i 18 23.8233329281 4.5 1906.99171241 8.2288186905 13 14 
 i 18 25.1660548113 4.5 1946.54369596 8.05889368905 13 14 
 i 18 25.3302841249 4.5 1951.48769396 8.2288186905 13 14 
 i 18 25.510321912 4.5 1956.43169196 8.79585928322 13 14 
 i 18 25.668071553 4.5 1961.37568995 8.64385618977 13 14 
 i 18 25.8366450301 4.5 1966.31968795 8.79585928322 13 14 
 i 18 26.0057445523 4.5 1971.26368594 8.64385618977 13 14 
 i 18 26.1629339347 4.5 1976.20768394 8.79585928322 13 14 
 i 18 26.3309261445 4.5 1981.15168194 9.05889368905 13 14 
 i 18 26.4910057606 4.5 1986.09567993 9.2288186905 13 14 
 i 18 26.6766572537 4.5 1991.03967793 9.05889368905 13 14 
 i 18 26.8422785819 4.5 1995.98367593 9.2288186905 13 14 
 i 18 27.006147873 4.5 2000.92767392 9.79585928322 13 14 
 i 18 27.1764419413 4.5 2005.87167192 9.64385618977 13 14 
 i 18 27.3382568032 4.5 2010.81566992 9.79585928322 13 14 
 i 18 27.5077602975 4.5 2015.75966791 9.64385618977 13 14 
 i 18 27.6698112434 4.5 2020.70366591 9.79585928322 13 14 
 i 18 27.832898213 4.5 2025.6476639 10.0588936891 13 14 
 i 18 28.0004176775 4.5 2030.5916619 10.2288186905 13 14 
 i 18 28.173312406 4.5 2035.5356599 10.0588936891 13 14 
 i 18 28.3265696951 4.5 2040.47965789 10.2288186905 13 14 
 i 18 28.5033082741 4.5 2045.42365589 10.7958592832 13 14 
 i 18 28.6739722693 4.5 2050.36765389 10.6438561898 13 14 
 i 18 28.8258436175 4.5 2055.31165188 10.7958592832 13 14 
 i 18 29.0066084701 4.5 2060.25564988 10.6438561898 13 14 
 i 18 29.1747683783 4.5 2065.19964787 10.7958592832 13 14 
 i 18 29.3383917196 4.5 2070.14364587 11.0588936891 13 14 
 i 18 29.4983317098 4.5 2075.08764387 11.2288186905 13 14 
 i 18 29.6642188582 4.5 2080.03164186 11.0588936891 13 14 
 i 18 29.831060867 4.5 2084.97563986 8.64386 13 14 
 i 18 30.0057328066 4.5 2089.91963786 11.2288186905 13 14 
 i 18 30.1768365776 4.5 2094.86363556 8.79585928322 13 14 
 i 18 30.1715538185 4.5 2094.86363585 11.7958592832 13 14 
 i 18 30.3312702289 4.5 2099.80763355 8.64385618977 13 14 
 i 18 30.323467819 4.5 2099.80763385 11.6438561898 13 14 
 i 18 30.4953903926 4.5 2104.75163155 8.79585928322 13 14 
 i 18 30.5108083649 4.5 2104.75163185 11.7958592832 13 14 
 i 18 30.666266861 4.5 2109.69562955 9.38082178394 13 14 
 i 18 30.6676995554 4.5 2109.69562984 11.6438561898 13 14 
 i 18 30.8400074537 4.5 2114.63962754 9.2288186905 13 14 
 i 18 30.8285297514 4.5 2114.63962784 9.38082178394 13 14 
 i 18 30.9988660552 4.5 2119.58362554 9.2288186905 13 14 
 i 18 31.1586596406 4.5 2124.52762353 9.38082178394 13 14 
 i 18 31.3317087195 4.5 2129.47162153 9.64385618977 13 14 
 i 18 31.508500549 4.5 2134.41561953 9.79585928322 13 14 
 i 18 31.6766155224 4.5 2139.35961752 9.64385618977 13 14 
 i 18 31.8343073086 4.5 2144.30361552 9.79585928322 13 14 
 i 18 32.0064692308 4.5 2149.24761352 10.3808217839 13 14 
 i 18 32.1700190341 4.5 2154.19161151 10.2288186905 13 14 
 i 18 32.330473999 4.5 2159.13560951 10.3808217839 13 14 
 i 18 32.4999135493 4.5 2164.0796075 10.2288186905 13 14 
 i 18 32.6620341727 4.5 2169.0236055 10.3808217839 13 14 
 i 18 32.8319334755 4.5 2173.9676035 10.6438561898 13 14 
 i 18 33.0014688611 4.5 2178.91160149 10.7958592832 13 14 
 i 18 33.1572895998 4.5 2183.85559949 10.6438561898 13 14 
 i 18 33.3373458484 4.5 2188.79959749 10.7958592832 13 14 
 i 18 33.5102641409 4.5 2193.74359548 11.3808217839 13 14 
 i 18 33.6585662368 4.5 2198.68759348 11.2288186905 13 14 
 i 18 33.844038 4.5 2203.63159148 11.3808217839 13 14 
 i 18 34.004459524 4.5 2208.57558947 11.2288186905 13 14 
 i 18 34.1708797311 4.5 2213.51958747 11.3808217839 13 14 
 i 18 34.3323007129 4.5 2218.46358546 11.6438561898 13 14 
 i 18 34.489329654 4.5 2223.40758346 11.7958592832 13 14 
 i 18 34.6674355255 4.5 2228.35158146 11.6438561898 13 14 
 i 18 34.8328261515 4.5 2233.29557945 11.7958592832 13 14 
 i 18 35.0064448833 4.5 2238.23957745 12.3808217839 13 14 
 i 18 35.1748214764 4.5 2243.18357545 12.2288186905 13 14 
 i 18 35.3316657476 4.5 2248.12757344 12.3808217839 13 14 
 i 18 35.5019917358 4.5 2253.07157144 12.2288186905 13 14 
 i 18 35.6744089238 4.5 2258.01556944 8.79586 13 14 
 i 18 35.8358803481 4.5 2262.95956743 8.96578428466 13 14 
 i 18 37.1698360973 4.5 2302.51155099 8.79585928322 13 14 
 i 18 37.3337421279 4.5 2307.45554898 8.96578428466 13 14 
 i 18 37.4936071925 4.5 2312.39954698 9.55074678538 13 14 
 i 18 37.6689808349 4.5 2317.34354498 9.38082178394 13 14 
 i 18 37.837911796 4.5 2322.28754297 9.55074678538 13 14 
 i 18 37.992796254 4.5 2327.23154097 9.38082178394 13 14 
 i 18 38.1704030518 4.5 2332.17553896 9.55074678538 13 14 
 i 18 38.3258852869 4.5 2337.11953696 9.79585928322 13 14 
 i 18 38.5082304975 4.5 2342.06353496 9.96578428466 13 14 
 i 18 38.6711252132 4.5 2347.00753295 9.79585928322 13 14 
 i 18 38.8294184101 4.5 2351.95153095 9.96578428466 13 14 
 i 18 39.0026611745 4.5 2356.89552895 10.5507467854 13 14 
 i 18 39.1645747858 4.5 2361.83952694 10.3808217839 13 14 
 i 18 39.3405742737 4.5 2366.78352494 10.5507467854 13 14 
 i 18 39.509823297 4.5 2371.72752294 10.3808217839 13 14 
 i 18 39.6769692647 4.5 2376.67152093 10.5507467854 13 14 
 i 18 39.8366995047 4.5 2381.61551893 10.7958592832 13 14 
 i 18 40.0099474863 4.5 2386.55951692 10.9657842847 13 14 
 i 18 40.1681201553 4.5 2391.50351492 10.7958592832 13 14 
 i 18 40.3268256112 4.5 2396.44751292 10.9657842847 13 14 
 i 18 40.5033715435 4.5 2401.39151091 11.5507467854 13 14 
 i 18 40.6757653135 4.5 2406.33550891 11.3808217839 13 14 
 i 18 40.8368631064 4.5 2411.27950691 11.5507467854 13 14 
 i 18 41.0052686959 4.5 2416.2235049 11.3808217839 13 14 
 i 18 41.176459882 4.5 2421.1675029 11.5507467854 13 14 
 i 18 41.3410129595 4.5 2426.1115009 11.7958592832 13 14 
 i 18 41.5045361518 4.5 2431.05549889 11.9657842847 13 14 
 i 18 41.6756856002 4.5 2435.99949689 11.7958592832 13 14 
 i 18 41.8435895634 4.5 2440.94349488 8.22882 13 14 
 i 18 41.9904581101 4.5 2445.88749288 11.9657842847 13 14 
 i 18 42.1751588259 4.5 2450.83149058 8.38082178394 13 14 
 i 18 42.1691690468 4.5 2450.83149088 12.5507467854 13 14 
 i 18 42.3264363597 4.5 2455.77548858 8.2288186905 13 14 
 i 18 42.3246100995 4.5 2455.77548887 12.3808217839 13 14 
 i 18 42.5051071154 4.5 2460.71948657 8.38082178394 13 14 
 i 18 42.4914685183 4.5 2460.71948687 12.5507467854 13 14 
 i 18 42.6649604496 4.5 2465.66348457 8.96578428466 13 14 
 i 18 42.6597456106 4.5 2465.66348487 12.3808217839 13 14 
 i 18 42.825151748 4.5 2470.60748257 8.79585928322 13 14 
 i 18 42.8307661102 4.5 2470.60748286 8.96578428466 13 14 
 i 18 42.9913214568 4.5 2475.55148056 8.79585928322 13 14 
 i 18 43.1722532942 4.5 2480.49547856 8.96578428466 13 14 
 i 18 43.3396290285 4.5 2485.43947655 9.2288186905 13 14 
 i 18 43.5104995417 4.5 2490.38347455 9.38082178394 13 14 
 i 18 43.6567481857 4.5 2495.32747255 9.2288186905 13 14 
 i 18 43.8413759986 4.5 2500.27147054 9.38082178394 13 14 
 i 18 44.000283002 4.5 2505.21546854 9.96578428466 13 14 
 i 18 44.1745686783 4.5 2510.15946654 9.79585928322 13 14 
 i 18 44.3324109545 4.5 2515.10346453 9.96578428466 13 14 
 i 18 44.4952504867 4.5 2520.04746253 9.79585928322 13 14 
 i 18 44.661804865 4.5 2524.99146053 9.96578428466 13 14 
 i 18 44.8394194921 4.5 2529.93545852 10.2288186905 13 14 
 i 18 45.0097781634 4.5 2534.87945652 10.3808217839 13 14 
 i 18 45.1727737722 4.5 2539.82345451 10.2288186905 13 14 
 i 18 45.3294339501 4.5 2544.76745251 10.3808217839 13 14 
 i 18 45.4967451141 4.5 2549.71145051 10.9657842847 13 14 
 i 18 45.6622873904 4.5 2554.6554485 10.7958592832 13 14 
 i 18 45.8362702332 4.5 2559.5994465 10.9657842847 13 14 
 i 18 45.9908380264 4.5 2564.5434445 10.7958592832 13 14 
 i 18 46.1565233987 4.5 2569.48744249 10.9657842847 13 14 
 i 18 46.3288852571 4.5 2574.43144049 11.2288186905 13 14 
 i 18 46.5080683852 4.5 2579.37543848 11.3808217839 13 14 
 i 18 46.6604716722 4.5 2584.31943648 11.2288186905 13 14 
 i 18 46.8357863273 4.5 2589.26343448 11.3808217839 13 14 
 i 18 46.996528666 4.5 2594.20743247 11.9657842847 13 14 
 i 18 47.1754425301 4.5 2599.15143047 11.7958592832 13 14 
 i 18 47.3397585831 4.5 2604.09542847 11.9657842847 13 14 
 i 18 47.4976884058 4.5 2609.03942646 11.7958592832 13 14 
 i 18 47.6598449416 4.5 2613.98342446 8.64386 13 14 
 i 18 47.8269293395 4.5 2618.92742246 8.79585928322 13 14 
 i 18 49.1617289591 4.5 2658.47940601 8.64385618977 13 14 
 i 18 49.3248110382 4.5 2663.42340401 8.79585928322 13 14 
 i 18 49.4891944658 4.5 2668.367402 9.38082178394 13 14 
 i 18 49.6752295184 4.5 2673.3114 9.2288186905 13 14 
 i 18 49.8305085296 4.5 2678.255398 9.38082178394 13 14 
 i 18 49.9890564109 4.5 2683.19939599 9.2288186905 13 14 
 i 18 50.1590086412 4.5 2688.14339399 9.38082178394 13 14 
 i 18 50.3318967623 4.5 2693.08739199 9.64385618977 13 14 
 i 18 50.4894538111 4.5 2698.03138998 9.79585928322 13 14 
 i 18 50.660557849 4.5 2702.97538798 9.64385618977 13 14 
 i 18 50.833540001 4.5 2707.91938597 9.79585928322 13 14 
 i 18 50.9960821808 4.5 2712.86338397 10.3808217839 13 14 
 i 18 51.1572325115 4.5 2717.80738197 10.2288186905 13 14 
 i 18 51.3315852181 4.5 2722.75137996 10.3808217839 13 14 
 i 18 51.5036983334 4.5 2727.69537796 10.2288186905 13 14 
 i 18 51.6668699093 4.5 2732.63937596 10.3808217839 13 14 
 i 18 51.8226499337 4.5 2737.58337395 10.6438561898 13 14 
 i 18 52.0078685067 4.5 2742.52737195 10.7958592832 13 14 
 i 18 52.1750574028 4.5 2747.47136994 10.6438561898 13 14 
 i 18 52.341705706 4.5 2752.41536794 10.7958592832 13 14 
 i 18 52.503736221 4.5 2757.35936594 11.3808217839 13 14 
 i 18 52.6614197227 4.5 2762.30336393 11.2288186905 13 14 
 i 18 52.8338722099 4.5 2767.24736193 11.3808217839 13 14 
 i 18 53.0079410115 4.5 2772.19135993 11.2288186905 13 14 
 i 18 53.1693777995 4.5 2777.13535792 11.3808217839 13 14 
 i 18 53.3350407298 4.5 2782.07935592 11.6438561898 13 14 
 i 18 53.5098522442 4.5 2787.02335392 11.7958592832 13 14 
 i 18 53.672950386 4.5 2791.96735191 11.6438561898 13 14 
 i 18 53.8226073915 4.5 2796.91134991 8.79586 13 14 
 i 18 53.993922013 4.5 2801.8553479 11.7958592832 13 14 
 i 18 54.16179083 4.5 2806.7993456 8.96578428466 13 14 
 i 18 54.1571041989 4.5 2806.7993459 12.3808217839 13 14 
 i 18 54.3417527198 4.5 2811.7433436 8.79585928322 13 14 
 i 18 54.3358053799 4.5 2811.7433439 12.2288186905 13 14 
 i 18 54.4982747145 4.5 2816.6873416 8.96578428466 13 14 
 i 18 54.4905213079 4.5 2816.68734189 12.3808217839 13 14 
 i 18 54.6565767034 4.5 2821.63133959 9.55074678538 13 14 
 i 18 54.6578957975 4.5 2821.63133989 12.2288186905 13 14 
 i 18 54.839491981 4.5 2826.57533759 9.38082178394 13 14 
 i 18 54.8315841346 4.5 2826.57533789 9.55074678538 13 14 
 i 18 55.0055939993 4.5 2831.51933559 9.38082178394 13 14 
 i 18 55.1558080128 4.5 2836.46333358 9.55074678538 13 14 
 i 18 55.3373190679 4.5 2841.40733158 9.79585928322 13 14 
 i 18 55.4987528478 4.5 2846.35132957 9.96578428466 13 14 
 i 18 55.6609575577 4.5 2851.29532757 9.79585928322 13 14 
 i 18 55.8342648754 4.5 2856.23932557 9.96578428466 13 14 
 i 18 56.0073703319 4.5 2861.18332356 10.5507467854 13 14 
 i 18 56.1651728566 4.5 2866.12732156 10.3808217839 13 14 
 i 18 56.3440541092 4.5 2871.07131956 10.5507467854 13 14 
 i 18 56.4956311057 4.5 2876.01531755 10.3808217839 13 14 
 i 18 56.6564767688 4.5 2880.95931555 10.5507467854 13 14 
 i 18 56.8410853497 4.5 2885.90331355 10.7958592832 13 14 
 i 18 57.009407459 4.5 2890.84731154 10.9657842847 13 14 
 i 18 57.1564229989 4.5 2895.79130954 10.7958592832 13 14 
 i 18 57.3255454145 4.5 2900.73530753 10.9657842847 13 14 
 i 18 57.4974724735 4.5 2905.67930553 11.5507467854 13 14 
 i 18 57.6645517344 4.5 2910.62330353 11.3808217839 13 14 
 i 18 57.8346926926 4.5 2915.56730152 11.5507467854 13 14 
 i 18 58.0003214612 4.5 2920.51129952 11.3808217839 13 14 
 i 18 58.1667890402 4.5 2925.45529752 11.5507467854 13 14 
 i 18 58.3440649901 4.5 2930.39929551 11.7958592832 13 14 
 i 18 58.4956251491 4.5 2935.34329351 11.9657842847 13 14 
 i 18 58.6696046026 4.5 2940.28729151 11.7958592832 13 14 
 i 18 58.8432942496 4.5 2945.2312895 11.9657842847 13 14 
 i 18 58.9971318089 4.5 2950.1752875 12.5507467854 13 14 
 i 18 59.1706346151 4.5 2955.11928549 12.3808217839 13 14 
 i 18 59.3257130761 4.5 2960.06328349 12.5507467854 13 14 
 i 18 59.5014863011 4.5 2965.00728149 12.3808217839 13 14 
 i 18 59.6640226554 4.5 2969.95127948 8.22882 13 14 
 i 18 59.8263673669 4.5 2974.89527748 8.38082178394 13 14 
 i 18 61.1684594925 4.5 3014.44726104 8.2288186905 13 14 
 i 18 61.3341605979 4.5 3019.39125903 8.38082178394 13 14 
 i 18 61.4990095018 4.5 3024.33525703 8.96578428466 13 14 
 i 18 61.6599788779 4.5 3029.27925502 8.79585928322 13 14 
 i 18 61.8248090848 4.5 3034.22325302 8.96578428466 13 14 
 i 18 61.9935719568 4.5 3039.16725102 8.79585928322 13 14 
 i 18 62.1598110698 4.5 3044.11124901 8.96578428466 13 14 
 i 18 62.3380444149 4.5 3049.05524701 9.2288186905 13 14 
 i 18 62.4892875587 4.5 3053.99924501 9.38082178394 13 14 
 i 18 62.6567301652 4.5 3058.943243 9.2288186905 13 14 
 i 18 62.8258185659 4.5 3063.887241 9.38082178394 13 14 
 i 18 62.9955934029 4.5 3068.83123899 9.96578428466 13 14 
 i 18 63.1676858988 4.5 3073.77523699 9.79585928322 13 14 
 i 18 63.3331288491 4.5 3078.71923499 9.96578428466 13 14 
 i 18 63.5062567082 4.5 3083.66323298 9.79585928322 13 14 
 i 18 63.6771287294 4.5 3088.60723098 9.96578428466 13 14 
 i 18 63.843849472 4.5 3093.55122898 10.2288186905 13 14 
 i 18 64.0075488901 4.5 3098.49522697 10.3808217839 13 14 
 i 18 64.1708016815 4.5 3103.43922497 10.2288186905 13 14 
 i 18 64.3439175182 4.5 3108.38322297 10.3808217839 13 14 
 i 18 64.5065849361 4.5 3113.32722096 10.9657842847 13 14 
 i 18 64.656594662 4.5 3118.27121896 10.7958592832 13 14 
 i 18 64.8381587519 4.5 3123.21521695 10.9657842847 13 14 
 i 18 64.9992934492 4.5 3128.15921495 10.7958592832 13 14 
 i 18 65.1712958966 4.5 3133.10321295 10.9657842847 13 14 
 i 18 65.3400839821 4.5 3138.04721094 11.2288186905 13 14 
 i 18 65.4947334246 4.5 3142.99120894 11.3808217839 13 14 
 i 18 65.6678261651 4.5 3147.93520694 11.2288186905 13 14 
 i 18 65.8419525705 4.5 3152.87920493 8.05889 13 14 
 i 18 66.0035141553 4.5 3157.82320293 11.3808217839 13 14 
 i 18 66.1754266365 4.5 3162.76720063 8.2288186905 13 14 
 i 18 66.1618520497 4.5 3162.76720092 11.9657842847 13 14 
 i 18 66.3257594279 4.5 3167.71119862 8.05889368905 13 14 
 i 18 66.32678059 4.5 3167.71119892 11.7958592832 13 14 
 i 18 66.5103796183 4.5 3172.65519662 8.2288186905 13 14 
 i 18 66.4927014367 4.5 3172.65519692 11.9657842847 13 14 
 i 18 66.6764039243 4.5 3177.59919462 8.79585928322 13 14 
 i 18 66.6622994639 4.5 3177.59919491 11.7958592832 13 14 
 i 18 66.8423910682 4.5 3182.54319261 8.64385618977 13 14 
 i 18 66.8297980184 4.5 3182.54319291 8.79585928322 13 14 
 i 18 66.9968649844 4.5 3187.48719061 8.64385618977 13 14 
 i 18 67.1750199497 4.5 3192.43118861 8.79585928322 13 14 
 i 18 67.3337533119 4.5 3197.3751866 9.05889368905 13 14 
 i 18 67.5096966122 4.5 3202.3191846 9.2288186905 13 14 
 i 18 67.6631572096 4.5 3207.2631826 9.05889368905 13 14 
 i 18 67.8377656673 4.5 3212.20718059 9.2288186905 13 14 
 i 18 68.0080609838 4.5 3217.15117859 9.79585928322 13 14 
 i 18 68.1627364021 4.5 3222.09517658 9.64385618977 13 14 
 i 18 68.3315601376 4.5 3227.03917458 9.79585928322 13 14 
 i 18 68.5064004531 4.5 3231.98317258 9.64385618977 13 14 
 i 18 68.6608700297 4.5 3236.92717057 9.79585928322 13 14 
 i 18 68.8406352997 4.5 3241.87116857 10.0588936891 13 14 
 i 18 68.9945979878 4.5 3246.81516657 10.2288186905 13 14 
 i 18 69.1604687424 4.5 3251.75916456 10.0588936891 13 14 
 i 18 69.3409097931 4.5 3256.70316256 10.2288186905 13 14 
 i 18 69.5058868979 4.5 3261.64716055 10.7958592832 13 14 
 i 18 69.6724382599 4.5 3266.59115855 10.6438561898 13 14 
 i 18 69.8438223685 4.5 3271.53515655 10.7958592832 13 14 
 i 18 70.0102377646 4.5 3276.47915454 10.6438561898 13 14 
 i 18 70.1756912488 4.5 3281.42315254 10.7958592832 13 14 
 i 18 70.3348049901 4.5 3286.36715054 11.0588936891 13 14 
 i 18 70.4942641036 4.5 3291.31114853 11.2288186905 13 14 
 i 18 70.6735537311 4.5 3296.25514653 11.0588936891 13 14 
 i 18 70.8255296318 4.5 3301.19914453 11.2288186905 13 14 
 i 18 71.0012454337 4.5 3306.14314252 11.7958592832 13 14 
 i 18 71.1610938717 4.5 3311.08714052 11.6438561898 13 14 
 i 18 71.3315829344 4.5 3316.03113851 11.7958592832 13 14 
 i 18 71.5051851167 4.5 3320.97513651 11.6438561898 13 14 
 i 18 71.6558378309 4.5 3325.91913451 8.79586 13 14 
 i 18 71.8362017439 4.5 3330.8631325 8.96578428466 13 14 
 i 18 73.1595184098 4.5 3370.41511606 8.79585928322 13 14 
 i 18 73.3286825808 4.5 3375.35911406 8.96578428466 13 14 
 i 18 73.5101714047 4.5 3380.30311205 9.55074678538 13 14 
 i 18 73.6649297858 4.5 3385.24711005 9.38082178394 13 14 
 i 18 73.8309184112 4.5 3390.19110804 9.55074678538 13 14 
 i 18 73.9959977401 4.5 3395.13510604 9.38082178394 13 14 
 i 18 74.172257074 4.5 3400.07910404 9.55074678538 13 14 
 i 18 74.3246550496 4.5 3405.02310203 9.79585928322 13 14 
 i 18 74.5063730227 4.5 3409.96710003 9.96578428466 13 14 
 i 18 74.6669450865 4.5 3414.91109803 9.79585928322 13 14 
 i 18 74.8377024464 4.5 3419.85509602 9.96578428466 13 14 
 i 18 74.9969314499 4.5 3424.79909402 10.5507467854 13 14 
 i 18 75.169296196 4.5 3429.74309201 10.3808217839 13 14 
 i 18 75.3324945895 4.5 3434.68709001 10.5507467854 13 14 
 i 18 75.5051321834 4.5 3439.63108801 10.3808217839 13 14 
 i 18 75.6644312159 4.5 3444.575086 10.5507467854 13 14 
 i 18 75.8418845182 4.5 3449.519084 10.7958592832 13 14 
 i 18 75.9903325169 4.5 3454.463082 10.9657842847 13 14 
 i 18 76.162029007 4.5 3459.40707999 10.7958592832 13 14 
 i 18 76.3352902657 4.5 3464.35107799 10.9657842847 13 14 
 i 18 76.5057744059 4.5 3469.29507599 11.5507467854 13 14 
 i 18 76.6593789115 4.5 3474.23907398 11.3808217839 13 14 
 i 18 76.8338249836 4.5 3479.18307198 11.5507467854 13 14 
 i 18 77.0012695074 4.5 3484.12706997 11.3808217839 13 14 
 i 18 77.1692129324 4.5 3489.07106797 11.5507467854 13 14 
 i 18 77.3388128117 4.5 3494.01506597 11.7958592832 13 14 
 i 18 77.5037357505 4.5 3498.95906396 11.9657842847 13 14 
 i 18 77.6701894557 4.5 3503.90306196 11.7958592832 13 14 
 i 18 77.8426190526 4.5 3508.84705996 8.22882 13 14 
 i 18 77.9962914032 4.5 3513.79105795 11.9657842847 13 14 
 i 18 78.1760100313 4.5 3518.73505565 8.38082178394 13 14 
 i 18 78.15657416 4.5 3518.73505595 12.5507467854 13 14 
 i 18 78.3227990177 4.5 3523.67905365 8.2288186905 13 14 
 i 18 78.3417186025 4.5 3523.67905395 12.3808217839 13 14 
 i 18 78.5073690155 4.5 3528.62305165 8.38082178394 13 14 
 i 18 78.4961695587 4.5 3528.62305194 12.5507467854 13 14 
 i 18 78.6664941351 4.5 3533.56704964 8.96578428466 13 14 
 i 18 78.667000346 4.5 3533.56704994 12.3808217839 13 14 
 i 18 78.8273340086 4.5 3538.51104764 8.79585928322 13 14 
 i 18 78.8326498071 4.5 3538.51104793 8.96578428466 13 14 
 i 18 79.0010452262 4.5 3543.45504563 8.79585928322 13 14 
 i 18 79.1662560583 4.5 3548.39904363 8.96578428466 13 14 
 i 18 79.3368013678 4.5 3553.34304163 9.2288186905 13 14 
 i 18 79.4986632408 4.5 3558.28703962 9.38082178394 13 14 
 i 18 79.6659339479 4.5 3563.23103762 9.2288186905 13 14 
 i 18 79.8332387632 4.5 3568.17503562 9.38082178394 13 14 
 i 18 79.9898410643 4.5 3573.11903361 9.96578428466 13 14 
 i 18 80.1680837682 4.5 3578.06303161 9.79585928322 13 14 
 i 18 80.3250148934 4.5 3583.0070296 9.96578428466 13 14 
 i 18 80.4932643956 4.5 3587.9510276 9.79585928322 13 14 
 i 18 80.67595437 4.5 3592.8950256 9.96578428466 13 14 
 i 18 80.8336359415 4.5 3597.83902359 10.2288186905 13 14 
 i 18 80.9903893062 4.5 3602.78302159 10.3808217839 13 14 
 i 18 81.1681236045 4.5 3607.72701959 10.2288186905 13 14 
 i 18 81.3419494273 4.5 3612.67101758 10.3808217839 13 14 
 i 18 81.505774993 4.5 3617.61501558 10.9657842847 13 14 
 i 18 81.6736214148 4.5 3622.55901358 10.7958592832 13 14 
 i 18 81.8248831607 4.5 3627.50301157 10.9657842847 13 14 
 i 18 81.9986964222 4.5 3632.44700957 10.7958592832 13 14 
 i 18 82.171517005 4.5 3637.39100756 10.9657842847 13 14 
 i 18 82.3369670782 4.5 3642.33500556 11.2288186905 13 14 
 i 18 82.4910067151 4.5 3647.27900356 11.3808217839 13 14 
 i 18 82.666452072 4.5 3652.22300155 11.2288186905 13 14 
 i 18 82.828958019 4.5 3657.16699955 11.3808217839 13 14 
 i 18 83.005230111 4.5 3662.11099755 11.9657842847 13 14 
 i 18 83.1656536338 4.5 3667.05499554 11.7958592832 13 14 
 i 18 83.339513003 4.5 3671.99899354 11.9657842847 13 14 
 i 18 83.4982234527 4.5 3676.94299153 11.7958592832 13 14 
 i 18 83.674236232 4.5 3681.88698953 8.05889 13 14 
 i 18 83.8337671065 4.5 3686.83098753 8.2288186905 13 14 
 i 18 85.1634457639 4.5 3726.38297108 8.05889368905 13 14 
 i 18 85.3246042679 4.5 3731.32696908 8.2288186905 13 14 
 i 18 85.5076102902 4.5 3736.27096708 8.79585928322 13 14 
 i 18 85.6687422053 4.5 3741.21496507 8.64385618977 13 14 
 i 18 85.8419129297 4.5 3746.15896307 8.79585928322 13 14 
 i 18 86.0048891302 4.5 3751.10296106 8.64385618977 13 14 
 i 18 86.1559185661 4.5 3756.04695906 8.79585928322 13 14 
 i 18 86.3247827069 4.5 3760.99095706 9.05889368905 13 14 
 i 18 86.5047122166 4.5 3765.93495505 9.2288186905 13 14 
 i 18 86.6755736956 4.5 3770.87895305 9.05889368905 13 14 
 i 18 86.8273724728 4.5 3775.82295105 9.2288186905 13 14 
 i 18 87.0095589028 4.5 3780.76694904 9.79585928322 13 14 
 i 18 87.1747749765 4.5 3785.71094704 9.64385618977 13 14 
 i 18 87.3406399012 4.5 3790.65494504 9.79585928322 13 14 
 i 18 87.4924131755 4.5 3795.59894303 9.64385618977 13 14 
 i 18 87.672189679 4.5 3800.54294103 9.79585928322 13 14 
 i 18 87.8258390694 4.5 3805.48693902 10.0588936891 13 14 
 i 18 88.0079328143 4.5 3810.43093702 10.2288186905 13 14 
 i 18 88.1588252843 4.5 3815.37493502 10.0588936891 13 14 
 i 18 88.325824518 4.5 3820.31893301 10.2288186905 13 14 
 i 18 88.4896790363 4.5 3825.26293101 10.7958592832 13 14 
 i 18 88.6740273319 4.5 3830.20692901 10.6438561898 13 14 
 i 18 88.8278937236 4.5 3835.150927 10.7958592832 13 14 
 i 18 89.0063193706 4.5 3840.094925 10.6438561898 13 14 
 i 18 89.1725108312 4.5 3845.03892299 10.7958592832 13 14 
 i 18 89.3397912432 4.5 3849.98292099 11.0588936891 13 14 
 i 18 89.4989167484 4.5 3854.92691899 11.2288186905 13 14 
 i 18 89.66359567 4.5 3859.87091698 11.0588936891 13 14 
 i 18 89.826962318 4.5 3864.81491498 8.64386 13 14 
 i 18 90.0038804863 4.5 3869.75891298 11.2288186905 13 14 
 i 18 90.1629605046 4.5 3874.70291068 8.79585928322 13 14 
 i 18 90.1722864561 4.5 3874.70291097 11.7958592832 13 14 
 i 18 90.340792877 4.5 3879.64690867 8.64385618977 13 14 
 i 18 90.3327193193 4.5 3879.64690897 11.6438561898 13 14 
 i 18 90.5066717124 4.5 3884.59090667 8.79585928322 13 14 
 i 18 90.4891189072 4.5 3884.59090697 11.7958592832 13 14 
 i 18 90.6715098652 4.5 3889.53490467 9.38082178394 13 14 
 i 18 90.6701994021 4.5 3889.53490496 11.6438561898 13 14 
 i 18 90.8347452034 4.5 3894.47890266 9.2288186905 13 14 
 i 18 90.8317246608 4.5 3894.47890296 9.38082178394 13 14 
 i 18 90.991780788 4.5 3899.42290066 9.2288186905 13 14 
 i 18 91.1759563011 4.5 3904.36689865 9.38082178394 13 14 
 i 18 91.328412292 4.5 3909.31089665 9.64385618977 13 14 
 i 18 91.4966892759 4.5 3914.25489465 9.79585928322 13 14 
 i 18 91.6616798512 4.5 3919.19889264 9.64385618977 13 14 
 i 18 91.8442468443 4.5 3924.14289064 9.79585928322 13 14 
 i 18 91.9910509454 4.5 3929.08688864 10.3808217839 13 14 
 i 18 92.1661185503 4.5 3934.03088663 10.2288186905 13 14 
 i 18 92.329299466 4.5 3938.97488463 10.3808217839 13 14 
 i 18 92.4920534367 4.5 3943.91888262 10.2288186905 13 14 
 i 18 92.6556893278 4.5 3948.86288062 10.3808217839 13 14 
 i 18 92.8314169012 4.5 3953.80687862 10.6438561898 13 14 
 i 18 93.0061023016 4.5 3958.75087661 10.7958592832 13 14 
 i 18 93.1678221125 4.5 3963.69487461 10.6438561898 13 14 
 i 18 93.3376692701 4.5 3968.63887261 10.7958592832 13 14 
 i 18 93.4902737102 4.5 3973.5828706 11.3808217839 13 14 
 i 18 93.6646421478 4.5 3978.5268686 11.2288186905 13 14 
 i 18 93.8435791872 4.5 3983.4708666 11.3808217839 13 14 
 i 18 93.9900333524 4.5 3988.41486459 11.2288186905 13 14 
 i 18 94.1695319978 4.5 3993.35886259 11.3808217839 13 14 
 i 18 94.3326344926 4.5 3998.30286058 11.6438561898 13 14 
 i 18 94.4959403304 4.5 4003.24685858 11.7958592832 13 14 
 i 18 94.6760123785 4.5 4008.19085658 11.6438561898 13 14 
 i 18 94.8261374358 4.5 4013.13485457 11.7958592832 13 14 
 i 18 94.9918450917 4.5 4018.07885257 12.3808217839 13 14 
 i 18 95.1675048519 4.5 4023.02285057 12.2288186905 13 14 
 i 18 95.3293842216 4.5 4027.96684856 12.3808217839 13 14 
 i 18 95.4915800674 4.5 4032.91084656 12.2288186905 13 14 
 i 18 95.6702079597 4.5 4037.85484456 8.22882 13 14 
 i 18 95.826013306 4.5 4042.79884255 8.38082178394 13 14 
 i 18 97.160883521 4.5 4082.35082611 8.2288186905 13 14 
 i 18 97.341442682 4.5 4087.2948241 8.38082178394 13 14 
 i 18 97.491709756 4.5 4092.2388221 8.96578428466 13 14 
 i 18 97.6660606946 4.5 4097.1828201 8.79585928322 13 14 
 i 18 97.8261688567 4.5 4102.12681809 8.96578428466 13 14 
 i 18 98.0078613167 4.5 4107.07081609 8.79585928322 13 14 
 i 18 98.173783585 4.5 4112.01481409 8.96578428466 13 14 
 i 18 98.3297857689 4.5 4116.95881208 9.2288186905 13 14 
 i 18 98.4990799953 4.5 4121.90281008 9.38082178394 13 14 
 i 18 98.6636359651 4.5 4126.84680807 9.2288186905 13 14 
 i 18 98.8437640083 4.5 4131.79080607 9.38082178394 13 14 
 i 18 98.9897288644 4.5 4136.73480407 9.96578428466 13 14 
 i 18 99.1740245815 4.5 4141.67880206 9.79585928322 13 14 
 i 18 99.3361724728 4.5 4146.62280006 9.96578428466 13 14 
 i 18 99.4926194311 4.5 4151.56679806 9.79585928322 13 14 
 i 18 99.6711589166 4.5 4156.51079605 9.96578428466 13 14 
 i 18 99.8354993464 4.5 4161.45479405 10.2288186905 13 14 
 i 18 99.9989676541 4.5 4166.39879204 10.3808217839 13 14 
 i 18 100.157428802 4.5 4171.34279004 10.2288186905 13 14 
 i 18 100.322896875 4.5 4176.28678804 10.3808217839 13 14 
 i 18 100.509883992 4.5 4181.23078603 10.9657842847 13 14 
 i 18 100.671001525 4.5 4186.17478403 10.7958592832 13 14 
 i 18 100.823857468 4.5 4191.11878203 10.9657842847 13 14 
 i 18 101.006892229 4.5 4196.06278002 10.7958592832 13 14 
 i 18 101.157227318 4.5 4201.00677802 10.9657842847 13 14 
 i 18 101.334050845 4.5 4205.95077602 11.2288186905 13 14 
 i 18 101.495521927 4.5 4210.89477401 11.3808217839 13 14 
 i 18 101.674138215 4.5 4215.83877201 11.2288186905 13 14 
 i 18 101.823707781 4.5 4220.78277 8.05889 13 14 
 i 18 102.010762897 4.5 4225.726768 11.3808217839 13 14 
 i 18 102.167815419 4.5 4230.6707657 8.2288186905 13 14 
 i 18 102.15783702 4.5 4230.670766 11.9657842847 13 14 
 i 18 102.326733967 4.5 4235.6147637 8.05889368905 13 14 
 i 18 102.324667375 4.5 4235.61476399 11.7958592832 13 14 
 i 18 102.500055651 4.5 4240.55876169 8.2288186905 13 14 
 i 18 102.490092785 4.5 4240.55876199 11.9657842847 13 14 
 i 18 102.67169846 4.5 4245.50275969 8.79585928322 13 14 
 i 18 102.668302644 4.5 4245.50275999 11.7958592832 13 14 
 i 18 102.832166787 4.5 4250.44675769 8.64385618977 13 14 
 i 18 102.832724016 4.5 4250.44675798 8.79585928322 13 14 
 i 18 103.001437501 4.5 4255.39075568 8.64385618977 13 14 
 i 18 103.17119773 4.5 4260.33475368 8.79585928322 13 14 
 i 18 103.342415795 4.5 4265.27875167 9.05889368905 13 14 
 i 18 103.497707805 4.5 4270.22274967 9.2288186905 13 14 
 i 18 103.665281481 4.5 4275.16674767 9.05889368905 13 14 
 i 18 103.833381566 4.5 4280.11074566 9.2288186905 13 14 
 i 18 103.991677907 4.5 4285.05474366 9.79585928322 13 14 
 i 18 104.159645551 4.5 4289.99874166 9.64385618977 13 14 
 i 18 104.342008519 4.5 4294.94273965 9.79585928322 13 14 
 i 18 104.503296199 4.5 4299.88673765 9.64385618977 13 14 
 i 18 104.658988584 4.5 4304.83073565 9.79585928322 13 14 
 i 18 104.829748298 4.5 4309.77473364 10.0588936891 13 14 
 i 18 105.001306439 4.5 4314.71873164 10.2288186905 13 14 
 i 18 105.17748304 4.5 4319.66272963 10.0588936891 13 14 
 i 18 105.332300203 4.5 4324.60672763 10.2288186905 13 14 
 i 18 105.495586633 4.5 4329.55072563 10.7958592832 13 14 
 i 18 105.664944924 4.5 4334.49472362 10.6438561898 13 14 
 i 18 105.834520723 4.5 4339.43872162 10.7958592832 13 14 
 i 18 105.995639629 4.5 4344.38271962 10.6438561898 13 14 
 i 18 106.171750798 4.5 4349.32671761 10.7958592832 13 14 
 i 18 106.328929977 4.5 4354.27071561 11.0588936891 13 14 
 i 18 106.503500178 4.5 4359.2147136 11.2288186905 13 14 
 i 18 106.66006696 4.5 4364.1587116 11.0588936891 13 14 
 i 18 106.84074309 4.5 4369.1027096 11.2288186905 13 14 
 i 18 107.004059415 4.5 4374.04670759 11.7958592832 13 14 
 i 18 107.160305508 4.5 4378.99070559 11.6438561898 13 14 
 i 18 107.338550998 4.5 4383.93470359 11.7958592832 13 14 
 i 18 107.495817157 4.5 4388.87870158 11.6438561898 13 14 
 i 18 107.663699545 4.5 4393.82269958 8.64386 13 14 
 i 18 107.836902662 4.5 4398.76669758 8.79585928322 13 14 
 i 18 109.177143395 4.5 4438.31868113 8.64385618977 13 14 
 i 18 109.334587573 4.5 4443.26267913 8.79585928322 13 14 
 i 18 109.494440957 4.5 4448.20667712 9.38082178394 13 14 
 i 18 109.670303127 4.5 4453.15067512 9.2288186905 13 14 
 i 18 109.834264209 4.5 4458.09467312 9.38082178394 13 14 
 i 18 110.004993253 4.5 4463.03867111 9.2288186905 13 14 
 i 18 110.175231453 4.5 4467.98266911 9.38082178394 13 14 
 i 18 110.32831465 4.5 4472.92666711 9.64385618977 13 14 
 i 18 110.501203244 4.5 4477.8706651 9.79585928322 13 14 
 i 18 110.658070674 4.5 4482.8146631 9.64385618977 13 14 
 i 18 110.827289776 4.5 4487.75866109 9.79585928322 13 14 
 i 18 111.009979433 4.5 4492.70265909 10.3808217839 13 14 
 i 18 111.169110133 4.5 4497.64665709 10.2288186905 13 14 
 i 18 111.33546031 4.5 4462.9200151 10.3808217839 13 14 
 i 18 111.498602024 4.5 4455.50401812 10.2288186905 13 14 
 i 18 111.672679746 4.5 4448.08802114 10.3808217839 13 14 
 i 18 111.822568543 4.5 4440.67202416 10.6438561898 13 14 
 i 18 112.001129779 4.5 4433.25602718 10.7958592832 13 14 
 i 18 112.170543674 4.5 4425.8400302 10.6438561898 13 14 
 i 18 112.324555335 4.5 4418.42403322 10.7958592832 13 14 
 i 18 112.503755006 4.5 4411.00803624 11.3808217839 13 14 
 i 18 112.665769938 4.5 4403.59203926 11.2288186905 13 14 
 i 18 112.831992711 4.5 4396.17604228 11.3808217839 13 14 
 i 18 112.994878124 4.5 4388.7600453 11.2288186905 13 14 
 i 18 113.161517049 4.5 4381.34404833 11.3808217839 13 14 
 i 18 113.339232391 4.5 4373.92805135 11.6438561898 13 14 
 i 18 113.50658924 4.5 4366.51205437 11.7958592832 13 14 
 i 18 113.663825516 4.5 4359.09605739 11.6438561898 13 14 
 i 18 113.830113423 4.5 4351.68006041 8.79586 13 14 
 i 18 113.998896597 4.5 4344.26406343 11.7958592832 13 14 
 i 18 114.168271293 4.5 4336.84806645 8.96578428466 13 14 
 i 18 114.16244673 4.5 4329.43206947 12.3808217839 13 14 
 i 18 114.32242041 4.5 4322.01607249 8.79585928322 13 14 
 i 18 114.328462926 4.5 4314.60007551 12.2288186905 13 14 
 i 18 114.50512473 4.5 4314.60007551 8.96578428466 13 14 
 i 18 114.492957744 4.5 4307.18407853 12.3808217839 13 14 
 i 18 114.667810823 4.5 4307.18407853 9.55074678538 13 14 
 i 18 114.660677129 4.5 4299.76808155 12.2288186905 13 14 
 i 18 114.842165822 4.5 4299.76808155 9.38082178394 13 14 
 i 18 114.843265158 4.5 4292.35208457 9.55074678538 13 14 
 i 18 115.00820523 4.5 4284.93608759 9.38082178394 13 14 
 i 18 115.173653043 4.5 4277.52009061 9.55074678538 13 14 
 i 18 115.334460647 4.5 4270.10409363 9.79585928322 13 14 
 i 18 115.495135667 4.5 4262.68809665 9.96578428466 13 14 
 i 18 115.666671518 4.5 4255.27209967 9.79585928322 13 14 
 i 18 115.834018802 4.5 4247.85610269 9.96578428466 13 14 
 i 18 115.994554928 4.5 4240.44010571 10.5507467854 13 14 
 i 18 116.168063107 4.5 4233.02410873 10.3808217839 13 14 
 i 18 116.331257507 4.5 4225.60811175 10.5507467854 13 14 
 i 18 116.50748352 4.5 4218.19211477 10.3808217839 13 14 
 i 18 116.656388295 4.5 4210.77611779 10.5507467854 13 14 
 i 18 116.8298847 4.5 4203.36012081 10.7958592832 13 14 
 i 18 117.010366686 4.5 4195.94412383 10.9657842847 13 14 
 i 18 117.164522528 4.5 4188.52812685 10.7958592832 13 14 
 i 18 117.32317011 4.5 4181.11212987 10.9657842847 13 14 
 i 18 117.494061032 4.5 4173.69613289 11.5507467854 13 14 
 i 18 117.657252334 4.5 4166.28013591 11.3808217839 13 14 
 i 18 117.831159461 4.5 4158.86413894 11.5507467854 13 14 
 i 18 117.994843275 4.5 4151.44814196 11.3808217839 13 14 
 i 18 118.161768612 4.5 4106.95216008 11.5507467854 13 14 
 i 18 118.330020668 4.5 4099.5361631 11.7958592832 13 14 
 i 18 118.490558655 4.5 4092.12016612 11.9657842847 13 14 
 i 18 118.672003446 4.5 4084.70416914 11.7958592832 13 14 
 i 18 118.824528749 4.5 4077.28817216 11.9657842847 13 14 
 i 18 119.006609136 4.5 4069.87217518 12.5507467854 13 14 
 i 18 119.173245792 4.5 4062.4561782 12.3808217839 13 14 
 i 18 119.326850168 4.5 4055.04018122 12.5507467854 13 14 
 i 18 119.506221219 4.5 4047.62418424 12.3808217839 13 14 
 i 18 119.663263474 4.5 4040.20818726 8.22882 13 14 
 i 18 119.826824999 4.5 4032.79219028 8.05889368905 13 14 
 i 18 1.25045128019 4.5 4025.3761933 8.2288186905 1 2 
 i 18 1.4900076722 4.5 4017.96019632 8.05889368905 1 2 
 i 18 1.74602284764 4.5 4010.54419934 8.64385618977 1 2 
 i 18 1.99783565457 4.5 4003.12820236 8.79585928322 1 2 
 i 18 2.24292915001 4.5 3995.71220538 8.64385618977 1 2 
 i 18 2.5059133579 4.5 3988.2962084 8.79585928322 1 2 
 i 18 2.75756262275 4.5 3980.88021142 9.05889368905 1 2 
 i 18 3.00741956648 4.5 3973.46421444 8.96578428466 1 2 
 i 18 3.24649789499 4.5 3966.04821746 8.79585928322 1 2 
 i 18 3.50395409289 4.5 3958.63222048 8.96578428466 1 2 
 i 18 3.74298156909 4.5 3958.63222048 8.79585928322 1 2 
 i 18 4.00948831903 4.5 3951.2162235 9.38082178394 1 2 
 i 18 4.25241089937 4.5 3951.2162235 9.55074678538 1 2 
 i 18 4.5096189208 4.5 3943.80022652 9.38082178394 1 2 
 i 18 4.75318609209 4.5 3943.80022652 9.55074678538 1 2 
 i 18 4.99980385667 4.5 3936.38422955 9.79585928322 1 2 
 i 18 5.2496581055 4.5 3928.96823257 9.70274987883 1 2 
 i 18 5.49212909389 4.5 3921.55223559 9.55074678538 1 2 
 i 18 5.74505347345 4.5 3914.13623861 8.05889 1 2 
 i 18 5.99999466324 4.5 3906.72024163 9.70274987883 1 2 
 i 18 6.24055802612 4.5 3899.30424465 9.55074678538 1 2 
 i 18 6.25577503645 4.5 3891.88824767 12.7027498788 1 2 
 i 18 6.49758656245 4.5 3884.47225069 8.05889368905 1 2 
 i 18 6.49719501612 4.5 3877.05625371 10.1177873781 1 2 
 i 18 6.75901978389 4.5 3869.64025673 12.7027498788 1 2 
 i 18 6.7431185797 4.5 3862.22425975 8.47393118833 1 2 
 i 18 6.99284851291 4.5 3854.80826277 8.64385618977 1 2 
 i 18 7.25621234747 4.5 3847.39226579 8.47393118833 1 2 
 i 18 7.49886050784 4.5 3839.97626881 8.64385618977 1 2 
 i 18 7.75248930095 4.5 3832.56027183 8.88896868761 1 2 
 i 18 7.9916082728 4.5 3825.14427485 8.79585928322 1 2 
 i 18 8.25904645971 4.5 3817.72827787 8.64385618977 1 2 
 i 18 8.49953188238 4.5 3810.31228089 8.79585928322 1 2 
 i 18 8.74105082647 4.5 3802.89628391 8.64385618977 1 2 
 i 18 8.99679094688 4.5 3795.48028693 9.2288186905 1 2 
 i 18 9.24060805747 4.5 3750.98430505 9.38082178394 1 2 
 i 18 9.48930555703 4.5 3743.56830807 9.2288186905 1 2 
 i 18 9.7580900372 4.5 3736.15231109 9.38082178394 1 2 
 i 18 9.99128293135 4.5 3728.73631411 9.64385618977 1 2 
 i 18 10.2430364697 4.5 3721.32031713 9.55074678538 1 2 
 i 18 10.5012036455 4.5 3713.90432016 9.38082178394 1 2 
 i 18 10.7473485317 4.5 3706.48832318 9.55074678538 1 2 
 i 18 10.9993294457 4.5 3699.0723262 9.38082178394 1 2 
 i 18 11.2521975063 4.5 3691.65632922 9.96578428466 1 2 
 i 18 11.5007765072 4.5 3684.24033224 8.64386 1 2 
 i 18 11.7542840464 4.5 3676.82433526 8.47393118833 1 2 
 i 18 13.2503601271 4.5 3669.40833828 8.64385618977 1 2 
 i 18 13.5085166233 4.5 3661.9923413 8.47393118833 1 2 
 i 18 13.7592554311 4.5 3654.57634432 9.05889368905 1 2 
 i 18 14.008437362 4.5 3647.16034734 9.2288186905 1 2 
 i 18 14.2552276456 4.5 3639.74435036 9.05889368905 1 2 
 i 18 14.4898117766 4.5 3632.32835338 9.2288186905 1 2 
 i 18 14.7572258252 4.5 3624.9123564 9.47393118833 1 2 
 i 18 14.9903004339 4.5 3617.49635942 9.38082178394 1 2 
 i 18 15.2468177758 4.5 3610.08036244 9.2288186905 1 2 
 i 18 15.5032363171 4.5 3602.66436546 9.38082178394 1 2 
 i 18 15.7469111705 4.5 3602.66436546 9.2288186905 1 2 
 i 18 16.0009843866 4.5 3595.24836848 9.79585928322 1 2 
 i 18 16.2514792594 4.5 3595.24836848 9.96578428466 1 2 
 i 18 16.4993613966 4.5 3587.8323715 9.79585928322 1 2 
 i 18 16.7498896261 4.5 3587.8323715 9.96578428466 1 2 
 i 18 17.0009388338 4.5 3580.41637452 10.2288186905 1 2 
 i 18 17.2465696371 4.5 3573.00037754 10.1177873781 1 2 
 i 18 17.4960160896 4.5 3565.58438056 9.96578428466 1 2 
 i 18 17.7546948272 4.5 3558.16838358 8.79586 1 2 
 i 18 18.0086328757 4.5 3550.7523866 10.1177873781 1 2 
 i 18 18.2410111258 4.5 3543.33638962 8.64385618977 1 2 
 i 18 18.2591134316 4.5 3535.92039264 9.96578428466 1 2 
 i 18 18.4986229253 4.5 3528.50439566 8.79585928322 1 2 
 i 18 18.5000764581 4.5 3521.08839868 10.5507467854 1 2 
 i 18 18.7392349335 4.5 3513.6724017 8.64385618977 1 2 
 i 18 18.7569471564 4.5 3506.25640472 9.2288186905 1 2 
 i 18 18.9984537652 4.5 3498.84040774 9.38082178394 1 2 
 i 18 19.2545613617 4.5 3491.42441077 9.2288186905 1 2 
 i 18 19.5073878965 4.5 3484.00841379 9.38082178394 1 2 
 i 18 19.7410215021 4.5 3476.59241681 9.64385618977 1 2 
 i 18 19.989825845 4.5 3469.17641983 9.55074678538 1 2 
 i 18 20.2406812858 4.5 3461.76042285 9.38082178394 1 2 
 i 18 20.4943955223 4.5 3454.34442587 9.55074678538 1 2 
 i 18 20.7554190193 4.5 3446.92842889 9.38082178394 1 2 
 i 18 21.0092205725 4.5 3439.51243191 9.96578428466 1 2 
 i 18 21.239504287 4.5 3395.01645003 10.1177873781 1 2 
 i 18 21.4906788927 4.5 3387.60045305 9.96578428466 1 2 
 i 18 21.7527582561 4.5 3380.18445607 10.1177873781 1 2 
 i 18 21.9985332714 4.5 3372.76845909 10.3808217839 1 2 
 i 18 22.2450235608 4.5 3365.35246211 10.3040061869 1 2 
 i 18 22.4926614479 4.5 3357.93646513 10.1177873781 1 2 
 i 18 22.7508362694 4.5 3350.52046815 10.3040061869 1 2 
 i 18 22.9920708924 4.5 3343.10447117 10.1177873781 1 2 
 i 18 23.2578278268 4.5 3335.68847419 10.7027498788 1 2 
 i 18 23.496674993 4.5 3328.27247721 8.05889 1 2 
 i 18 23.7473291777 4.5 3320.85648023 12.7027498788 1 2 
 i 18 25.250316292 4.5 3313.44048325 8.05889368905 1 2 
 i 18 25.5043634103 4.5 3306.02448627 12.7027498788 1 2 
 i 18 25.7467614306 4.5 3298.60848929 8.47393118833 1 2 
 i 18 25.9950893612 4.5 3291.19249231 8.64385618977 1 2 
 i 18 26.2557519288 4.5 3283.77649533 8.47393118833 1 2 
 i 18 26.5051679415 4.5 3276.36049835 8.64385618977 1 2 
 i 18 26.7483396335 4.5 3268.94450138 8.88896868761 1 2 
 i 18 26.9946661379 4.5 3261.5285044 8.79585928322 1 2 
 i 18 27.2574706848 4.5 3254.11250742 8.64385618977 1 2 
 i 18 27.4982778997 4.5 3246.69651044 8.79585928322 1 2 
 i 18 27.7512441958 4.5 3246.69651044 8.64385618977 1 2 
 i 18 27.9913530017 4.5 3239.28051346 9.2288186905 1 2 
 i 18 28.2521693314 4.5 3239.28051346 9.38082178394 1 2 
 i 18 28.5052883754 4.5 3231.86451648 9.2288186905 1 2 
 i 18 28.7533391631 4.5 3231.86451648 9.38082178394 1 2 
 i 18 28.9987294561 4.5 3224.4485195 9.64385618977 1 2 
 i 18 29.2451833044 4.5 3217.03252252 9.55074678538 1 2 
 i 18 29.4900773055 4.5 3209.61652554 9.38082178394 1 2 
 i 18 29.7455838635 4.5 3202.20052856 8.64386 1 2 
 i 18 30.0063691846 4.5 3194.78453158 9.55074678538 1 2 
 i 18 30.2522133918 4.5 3187.3685346 8.47393118833 1 2 
 i 18 30.2421140481 4.5 3179.95253762 9.38082178394 1 2 
 i 18 30.5057605523 4.5 3172.53654064 8.64385618977 1 2 
 i 18 30.5054630295 4.5 3165.12054366 9.96578428466 1 2 
 i 18 30.7602918611 4.5 3157.70454668 8.47393118833 1 2 
 i 18 30.7444398567 4.5 3150.2885497 9.05889368905 1 2 
 i 18 30.991947879 4.5 3142.87255272 9.2288186905 1 2 
 i 18 31.2595282523 4.5 3135.45655574 9.05889368905 1 2 
 i 18 31.5068629788 4.5 3128.04055876 9.2288186905 1 2 
 i 18 31.7465950594 4.5 3120.62456178 9.47393118833 1 2 
 i 18 32.0052768165 4.5 3113.2085648 9.38082178394 1 2 
 i 18 32.241682222 4.5 3105.79256782 9.2288186905 1 2 
 i 18 32.5019123895 4.5 3098.37657084 9.38082178394 1 2 
 i 18 32.7504440425 4.5 3090.96057386 9.2288186905 1 2 
 i 18 33.0060479864 4.5 3083.54457688 9.79585928322 1 2 
 i 18 33.2600325595 4.5 3039.04859501 9.96578428466 1 2 
 i 18 33.5108864546 4.5 3031.63259803 9.79585928322 1 2 
 i 18 33.7507048879 4.5 3024.21660105 9.96578428466 1 2 
 i 18 33.9930978523 4.5 3016.80060407 10.2288186905 1 2 
 i 18 34.2599220179 4.5 3009.38460709 10.1177873781 1 2 
 i 18 34.5076584796 4.5 3001.96861011 9.96578428466 1 2 
 i 18 34.7607731079 4.5 2994.55261313 10.1177873781 1 2 
 i 18 35.0077817577 4.5 2987.13661615 9.96578428466 1 2 
 i 18 35.2516807602 4.5 2979.72061917 10.5507467854 1 2 
 i 18 35.4907814498 4.5 2972.30462219 8.79586 1 2 
 i 18 35.7390508862 4.5 2964.88862521 8.64385618977 1 2 
 i 18 37.2600318499 4.5 2957.47262823 8.79585928322 1 2 
 i 18 37.5029537496 4.5 2950.05663125 8.64385618977 1 2 
 i 18 37.7547883625 4.5 2942.64063427 9.2288186905 1 2 
 i 18 38.0105637281 4.5 2935.22463729 9.38082178394 1 2 
 i 18 38.2391097089 4.5 2927.80864031 9.2288186905 1 2 
 i 18 38.5040891162 4.5 2920.39264333 9.38082178394 1 2 
 i 18 38.7556320987 4.5 2912.97664635 9.64385618977 1 2 
 i 18 38.9954634493 4.5 2905.56064937 9.55074678538 1 2 
 i 18 39.2467591598 4.5 2898.14465239 9.38082178394 1 2 
 i 18 39.4994382727 4.5 2890.72865541 9.55074678538 1 2 
 i 18 39.7474615234 4.5 2890.72865541 9.38082178394 1 2 
 i 18 40.0075247397 4.5 2883.31265843 9.96578428466 1 2 
 i 18 40.2538229946 4.5 2883.31265843 10.1177873781 1 2 
 i 18 40.5042770399 4.5 2875.89666145 9.96578428466 1 2 
 i 18 40.7517618431 4.5 2875.89666145 10.1177873781 1 2 
 i 18 41.0105314709 4.5 2868.48066447 10.3808217839 1 2 
 i 18 41.2414931778 4.5 2861.06466749 10.3040061869 1 2 
 i 18 41.5089261427 4.5 2853.64867051 10.1177873781 1 2 
 i 18 41.7413701486 4.5 2846.23267353 8.22882 1 2 
 i 18 41.9983208644 4.5 2838.81667655 10.3040061869 1 2 
 i 18 42.2412646867 4.5 2831.40067957 8.05889368905 1 2 
 i 18 42.2453381285 4.5 2823.9846826 10.1177873781 1 2 
 i 18 42.5106352873 4.5 2816.56868562 8.2288186905 1 2 
 i 18 42.5069898743 4.5 2809.15268864 10.7027498788 1 2 
 i 18 42.7454637347 4.5 2801.73669166 8.05889368905 1 2 
 i 18 42.7578997724 4.5 2794.32069468 8.64385618977 1 2 
 i 18 42.9945605278 4.5 2786.9046977 8.79585928322 1 2 
 i 18 43.2496411512 4.5 2779.48870072 8.64385618977 1 2 
 i 18 43.5040924124 4.5 2772.07270374 8.79585928322 1 2 
 i 18 43.7455950081 4.5 2764.65670676 9.05889368905 1 2 
 i 18 44.0032515342 4.5 2757.24070978 8.96578428466 1 2 
 i 18 44.2441225069 4.5 2749.8247128 8.79585928322 1 2 
 i 18 44.5002269028 4.5 2742.40871582 8.96578428466 1 2 
 i 18 44.7507883119 4.5 2734.99271884 8.79585928322 1 2 
 i 18 44.999393843 4.5 2727.57672186 9.38082178394 1 2 
 i 18 45.2560465114 4.5 2683.08073998 9.55074678538 1 2 
 i 18 45.4893423292 4.5 2675.664743 9.38082178394 1 2 
 i 18 45.7572552282 4.5 2668.24874602 9.55074678538 1 2 
 i 18 45.9964408253 4.5 2660.83274904 9.79585928322 1 2 
 i 18 46.2409362137 4.5 2653.41675206 9.70274987883 1 2 
 i 18 46.4974386584 4.5 2646.00075508 9.55074678538 1 2 
 i 18 46.7541287269 4.5 2638.5847581 9.70274987883 1 2 
 i 18 47.0020534886 4.5 2631.16876112 9.55074678538 1 2 
 i 18 47.2438193634 4.5 2623.75276414 10.1177873781 1 2 
 i 18 47.5016043642 4.5 2616.33676716 8.64386 1 2 
 i 18 47.7593037102 4.5 2608.92077018 8.47393118833 1 2 
 i 18 49.2527931763 4.5 2601.50477321 8.64385618977 1 2 
 i 18 49.497792198 4.5 2594.08877623 8.47393118833 1 2 
 i 18 49.7549517017 4.5 2586.67277925 9.05889368905 1 2 
 i 18 49.997236479 4.5 2579.25678227 9.2288186905 1 2 
 i 18 50.2447772129 4.5 2571.84078529 9.05889368905 1 2 
 i 18 50.5088328381 4.5 2564.42478831 9.2288186905 1 2 
 i 18 50.7590339858 4.5 2557.00879133 9.47393118833 1 2 
 i 18 51.0104675342 4.5 2549.59279435 9.38082178394 1 2 
 i 18 51.2538920544 4.5 2542.17679737 9.2288186905 1 2 
 i 18 51.5039415022 4.5 2534.76080039 9.38082178394 1 2 
 i 18 51.7405750218 4.5 2534.76080039 9.2288186905 1 2 
 i 18 51.9978711149 4.5 2527.34480341 9.79585928322 1 2 
 i 18 52.2599099676 4.5 2527.34480341 9.96578428466 1 2 
 i 18 52.4956275231 4.5 2519.92880643 9.79585928322 1 2 
 i 18 52.7600323885 4.5 2519.92880643 9.96578428466 1 2 
 i 18 53.0045230462 4.5 2512.51280945 10.2288186905 1 2 
 i 18 53.2424003968 4.5 2505.09681247 10.1177873781 1 2 
 i 18 53.5088146682 4.5 2497.68081549 9.96578428466 1 2 
 i 18 53.7529373748 4.5 2490.26481851 8.79586 1 2 
 i 18 53.9895267108 4.5 2482.84882153 10.1177873781 1 2 
 i 18 54.2524109252 4.5 2475.43282455 8.64385618977 1 2 
 i 18 54.240769202 4.5 2468.01682757 9.96578428466 1 2 
 i 18 54.4999560029 4.5 2460.60083059 8.79585928322 1 2 
 i 18 54.5011540352 4.5 2453.18483361 10.5507467854 1 2 
 i 18 54.7571963994 4.5 2445.76883663 8.64385618977 1 2 
 i 18 54.7403291101 4.5 2438.35283965 9.2288186905 1 2 
 i 18 54.9943824031 4.5 2430.93684267 9.38082178394 1 2 
 i 18 55.2477571572 4.5 2423.52084569 9.2288186905 1 2 
 i 18 55.5059200054 4.5 2416.10484871 9.38082178394 1 2 
 i 18 55.7607355992 4.5 2408.68885173 9.64385618977 1 2 
 i 18 55.9895997627 4.5 2401.27285475 9.55074678538 1 2 
 i 18 56.2587836571 4.5 2393.85685777 9.38082178394 1 2 
 i 18 56.5002560875 4.5 2386.44086079 9.55074678538 1 2 
 i 18 56.7488139068 4.5 2379.02486382 9.38082178394 1 2 
 i 18 56.9994254957 4.5 2371.60886684 9.96578428466 1 2 
 i 18 57.2456262356 4.5 2327.11288496 10.1177873781 1 2 
 i 18 57.5076936331 4.5 2319.69688798 9.96578428466 1 2 
 i 18 57.7492393219 4.5 2312.280891 10.1177873781 1 2 
 i 18 58.0043434348 4.5 2304.86489402 10.3808217839 1 2 
 i 18 58.2595303148 4.5 2297.44889704 10.3040061869 1 2 
 i 18 58.4903233728 4.5 2290.03290006 10.1177873781 1 2 
 i 18 58.7430631148 4.5 2282.61690308 10.3040061869 1 2 
 i 18 59.0027644846 4.5 2275.2009061 10.1177873781 1 2 
 i 18 59.2606426799 4.5 2267.78490912 10.7027498788 1 2 
 i 18 59.5007469605 4.5 2260.36891214 8.22882 1 2 
 i 18 59.7392597438 4.5 2252.95291516 8.05889368905 1 2 
 i 18 61.2551043042 4.5 2245.53691818 8.2288186905 1 2 
 i 18 61.4995678955 4.5 2238.1209212 8.05889368905 1 2 
 i 18 61.7425276778 4.5 2230.70492422 8.64385618977 1 2 
 i 18 62.0102856689 4.5 2223.28892724 8.79585928322 1 2 
 i 18 62.2487175936 4.5 2215.87293026 8.64385618977 1 2 
 i 18 62.4943260228 4.5 2208.45693328 8.79585928322 1 2 
 i 18 62.7545845783 4.5 2201.0409363 9.05889368905 1 2 
 i 18 63.0056027186 4.5 2193.62493932 8.96578428466 1 2 
 i 18 63.2461947013 4.5 2186.20894234 8.79585928322 1 2 
 i 18 63.5090497018 4.5 2178.79294536 8.96578428466 1 2 
 i 18 63.7594014279 4.5 2178.79294536 8.79585928322 1 2 
 i 18 63.9973871942 4.5 2171.37694838 9.38082178394 1 2 
 i 18 64.2516188862 4.5 2171.37694838 9.55074678538 1 2 
 i 18 64.5013850351 4.5 2163.9609514 9.38082178394 1 2 
 i 18 64.7606958572 4.5 2163.9609514 9.55074678538 1 2 
 i 18 64.9895171823 4.5 2156.54495443 9.79585928322 1 2 
 i 18 65.2459382381 4.5 2149.12895745 9.70274987883 1 2 
 i 18 65.4965376496 4.5 2141.71296047 9.55074678538 1 2 
 i 18 65.7605834734 4.5 2134.29696349 8.05889 1 2 
 i 18 66.0077440464 4.5 2126.88096651 9.70274987883 1 2 
 i 18 66.2454133102 4.5 2119.46496953 9.55074678538 1 2 
 i 18 66.2557678272 4.5 2112.04897255 12.7027498788 1 2 
 i 18 66.5035780349 4.5 2104.63297557 8.05889368905 1 2 
 i 18 66.5051899484 4.5 2097.21697859 10.1177873781 1 2 
 i 18 66.7465363204 4.5 2089.80098161 12.7027498788 1 2 
 i 18 66.7450197108 4.5 2082.38498463 8.47393118833 1 2 
 i 18 67.0010093883 4.5 2074.96898765 8.64385618977 1 2 
 i 18 67.2509999337 4.5 2067.55299067 8.47393118833 1 2 
 i 18 67.5045693375 4.5 2060.13699369 8.64385618977 1 2 
 i 18 67.7471731704 4.5 2052.72099671 8.88896868761 1 2 
 i 18 68.01090687 4.5 2045.30499973 8.79585928322 1 2 
 i 18 68.2463862295 4.5 2037.88900275 8.64385618977 1 2 
 i 18 68.5066172001 4.5 2030.47300577 8.79585928322 1 2 
 i 18 68.7574512749 4.5 2023.05700879 8.64385618977 1 2 
 i 18 68.997859833 4.5 2015.64101181 9.2288186905 1 2 
 i 18 69.2446888446 4.5 1971.14502993 9.38082178394 1 2 
 i 18 69.5086983556 4.5 1963.72903295 9.2288186905 1 2 
 i 18 69.7445071612 4.5 1956.31303597 9.38082178394 1 2 
 i 18 70.0015872876 4.5 1948.89703899 9.64385618977 1 2 
 i 18 70.2483066075 4.5 1941.48104201 9.55074678538 1 2 
 i 18 70.4947730782 4.5 1934.06504504 9.38082178394 1 2 
 i 18 70.7469590242 4.5 1926.64904806 9.55074678538 1 2 
 i 18 71.003576624 4.5 1919.23305108 9.38082178394 1 2 
 i 18 71.2449046121 4.5 1911.8170541 9.96578428466 1 2 
 i 18 71.4932083651 4.5 1904.40105712 8.79586 1 2 
 i 18 71.7531542954 4.5 1896.98506014 8.64385618977 1 2 
 i 18 73.2488476262 4.5 1889.56906316 8.79585928322 1 2 
 i 18 73.4940543983 4.5 1882.15306618 8.64385618977 1 2 
 i 18 73.7482973306 4.5 1874.7370692 9.2288186905 1 2 
 i 18 74.0086731033 4.5 1867.32107222 9.38082178394 1 2 
 i 18 74.2489733491 4.5 1859.90507524 9.2288186905 1 2 
 i 18 74.4925961375 4.5 1852.48907826 9.38082178394 1 2 
 i 18 74.7476194616 4.5 1845.07308128 9.64385618977 1 2 
 i 18 74.997065599 4.5 1837.6570843 9.55074678538 1 2 
 i 18 75.2543844565 4.5 1830.24108732 9.38082178394 1 2 
 i 18 75.4969750666 4.5 1822.82509034 9.55074678538 1 2 
 i 18 75.7575783349 4.5 1822.82509034 9.38082178394 1 2 
 i 18 75.9959964802 4.5 1815.40909336 9.96578428466 1 2 
 i 18 76.2413263175 4.5 1815.40909336 10.1177873781 1 2 
 i 18 76.5049758257 4.5 1807.99309638 9.96578428466 1 2 
 i 18 76.7415126737 4.5 1807.99309638 10.1177873781 1 2 
 i 18 77.0026670269 4.5 1800.5770994 10.3808217839 1 2 
 i 18 77.2514646332 4.5 1793.16110242 10.3040061869 1 2 
 i 18 77.5095562628 4.5 1785.74510544 10.1177873781 1 2 
 i 18 77.7604222117 4.5 1778.32910846 8.22882 1 2 
 i 18 78.0088572487 4.5 1770.91311148 10.3040061869 1 2 
 i 18 78.2609141801 4.5 1763.4971145 8.05889368905 1 2 
 i 18 78.2556835145 4.5 1756.08111752 10.1177873781 1 2 
 i 18 78.5096162034 4.5 1748.66512054 8.2288186905 1 2 
 i 18 78.5038591542 4.5 1741.24912356 10.7027498788 1 2 
 i 18 78.7391995069 4.5 1733.83312658 8.05889368905 1 2 
 i 18 78.7485364759 4.5 1726.4171296 8.64385618977 1 2 
 i 18 78.9947855077 4.5 1719.00113262 8.79585928322 1 2 
 i 18 79.2434243882 4.5 1711.58513565 8.64385618977 1 2 
 i 18 79.5044020892 4.5 1704.16913867 8.79585928322 1 2 
 i 18 79.7400828844 4.5 1696.75314169 9.05889368905 1 2 
 i 18 79.9963483297 4.5 1689.33714471 8.96578428466 1 2 
 i 18 80.2501195301 4.5 1681.92114773 8.79585928322 1 2 
 i 18 80.5077218201 4.5 1674.50515075 8.96578428466 1 2 
 i 18 80.7485114816 4.5 1667.08915377 8.79585928322 1 2 
 i 18 80.9964830206 4.5 1659.67315679 9.38082178394 1 2 
 i 18 81.2555682518 4.5 1615.17717491 9.55074678538 1 2 
 i 18 81.4899288207 4.5 1607.76117793 9.38082178394 1 2 
 i 18 81.7435796169 4.5 1600.34518095 9.55074678538 1 2 
 i 18 82.0109823075 4.5 1592.92918397 9.79585928322 1 2 
 i 18 82.2488606367 4.5 1585.51318699 9.70274987883 1 2 
 i 18 82.504337228 4.5 1578.09719001 9.55074678538 1 2 
 i 18 82.740174749 4.5 1570.68119303 9.70274987883 1 2 
 i 18 82.9911402918 4.5 1563.26519605 9.55074678538 1 2 
 i 18 83.243959858 4.5 1555.84919907 10.1177873781 1 2 
 i 18 83.5002184503 4.5 1548.43320209 8.05889 1 2 
 i 18 83.7589855202 4.5 1541.01720511 12.7027498788 1 2 
 i 18 85.2507764076 4.5 1533.60120813 8.05889368905 1 2 
 i 18 85.4988913085 4.5 1526.18521115 12.7027498788 1 2 
 i 18 85.7418843045 4.5 1518.76921417 8.47393118833 1 2 
 i 18 85.9976572965 4.5 1511.35321719 8.64385618977 1 2 
 i 18 86.2605737222 4.5 1503.93722021 8.47393118833 1 2 
 i 18 86.4994192151 4.5 1496.52122323 8.64385618977 1 2 
 i 18 86.7550576792 4.5 1489.10522626 8.88896868761 1 2 
 i 18 86.9931389938 4.5 1481.68922928 8.79585928322 1 2 
 i 18 87.2497408794 4.5 1474.2732323 8.64385618977 1 2 
 i 18 87.4991285454 4.5 1466.85723532 8.79585928322 1 2 
 i 18 87.7508759265 4.5 1466.85723532 8.64385618977 1 2 
 i 18 88.0093796616 4.5 1459.44123834 9.2288186905 1 2 
 i 18 88.2530320117 4.5 1459.44123834 9.38082178394 1 2 
 i 18 88.4984131565 4.5 1452.02524136 9.2288186905 1 2 
 i 18 88.7538416868 4.5 1452.02524136 9.38082178394 1 2 
 i 18 89.0066598338 4.5 1444.60924438 9.64385618977 1 2 
 i 18 89.2591212843 4.5 1437.1932474 9.55074678538 1 2 
 i 18 89.4934696439 4.5 1429.77725042 9.38082178394 1 2 
 i 18 89.7592662795 4.5 1422.36125344 8.64386 1 2 
 i 18 90.0079159053 4.5 1414.94525646 9.55074678538 1 2 
 i 18 90.2444928148 4.5 1407.52925948 8.47393118833 1 2 
 i 18 90.2528872077 4.5 1400.1132625 9.38082178394 1 2 
 i 18 90.4921853543 4.5 1392.69726552 8.64385618977 1 2 
 i 18 90.4970795564 4.5 1385.28126854 9.96578428466 1 2 
 i 18 90.7458584809 4.5 1377.86527156 8.47393118833 1 2 
 i 18 90.7456517875 4.5 1370.44927458 9.05889368905 1 2 
 i 18 91.004614086 4.5 1363.0332776 9.2288186905 1 2 
 i 18 91.2549890329 4.5 1355.61728062 9.05889368905 1 2 
 i 18 91.4931245105 4.5 1348.20128364 9.2288186905 1 2 
 i 18 91.7401153711 4.5 1340.78528666 9.47393118833 1 2 
 i 18 91.9966774557 4.5 1333.36928968 9.38082178394 1 2 
 i 18 92.2475503937 4.5 1325.9532927 9.2288186905 1 2 
 i 18 92.497354363 4.5 1318.53729572 9.38082178394 1 2 
 i 18 92.7403951854 4.5 1311.12129874 9.2288186905 1 2 
 i 18 92.9898175432 4.5 1303.70530176 9.79585928322 1 2 
 i 18 93.2437071729 4.5 1259.20931989 9.96578428466 1 2 
 i 18 93.5016132384 4.5 1251.79332291 9.79585928322 1 2 
 i 18 93.7488678041 4.5 1244.37732593 9.96578428466 1 2 
 i 18 94.0017663534 4.5 1236.96132895 10.2288186905 1 2 
 i 18 94.2478063124 4.5 1229.54533197 10.1177873781 1 2 
 i 18 94.4987003842 4.5 1222.12933499 9.96578428466 1 2 
 i 18 94.7529410576 4.5 1214.71333801 10.1177873781 1 2 
 i 18 94.9909557876 4.5 1207.29734103 9.96578428466 1 2 
 i 18 95.2562127764 4.5 5000 10.5507467854 1 2 
 i 18 95.4976752388 4.5 5000 8.22882 1 2 
 i 18 95.7452234767 4.5 5000 8.05889368905 1 2 
 i 18 97.2419545697 4.5 5000 8.2288186905 1 2 
 i 18 97.5106568019 4.5 5000 8.05889368905 1 2 
 i 18 97.7449937158 4.5 5000 8.64385618977 1 2 
 i 18 98.0006435519 4.5 5000 8.79585928322 1 2 
 i 18 98.2575109548 4.5 5000 8.64385618977 1 2 
 i 18 98.5005181281 4.5 5000 8.79585928322 1 2 
 i 18 98.742937841 4.5 5000 9.05889368905 1 2 
 i 18 99.0063521297 4.5 5000 8.96578428466 1 2 
 i 18 99.2429239308 4.5 5000 8.79585928322 1 2 
 i 18 99.5010503616 4.5 5000 8.96578428466 1 2 
 i 18 99.7608916389 4.5 5000 8.79585928322 1 2 
 i 18 100.010571683 4.5 5000 9.38082178394 1 2 
 i 18 100.245904826 4.5 5000 9.55074678538 1 2 
 i 18 100.507691202 4.5 5000 9.38082178394 1 2 
 i 18 100.755281485 4.5 5000 9.55074678538 1 2 
 i 18 101.007349802 4.5 1287.36938718 9.79585928322 1 2 
 i 18 101.250968848 4.5 1297.07709687 9.70274987883 1 2 
 i 18 101.496515897 4.5 1306.78480655 9.55074678538 1 2 
 i 18 101.74595157 4.5 1316.49251624 8.05889 1 2 
 i 18 101.998822292 4.5 1326.20022592 9.70274987883 1 2 
 i 18 102.257144864 4.5 1335.90793561 9.55074678538 1 2 
 i 18 102.244347825 4.5 1345.6156453 12.7027498788 1 2 
 i 18 102.492099124 4.5 1355.32335498 8.05889368905 1 2 
 i 18 102.496694028 4.5 1365.03106467 10.1177873781 1 2 
 i 18 102.754205809 4.5 1374.73877436 12.7027498788 1 2 
 i 18 102.748305026 4.5 1384.44648404 8.47393118833 1 2 
 i 18 103.006135564 4.5 1394.15419373 8.64385618977 1 2 
 i 18 103.252342765 4.5 1403.86190342 8.47393118833 1 2 
 i 18 103.501360334 4.5 1413.5696131 8.64385618977 1 2 
 i 18 103.751993553 4.5 1423.27732279 8.88896868761 1 2 
 i 18 104.000127825 4.5 1432.98503248 8.79585928322 1 2 
 i 18 104.241662282 4.5 1442.69274216 8.64385618977 1 2 
 i 18 104.509794489 4.5 1452.40045185 8.79585928322 1 2 
 i 18 104.758433156 4.5 1462.10816154 8.64385618977 1 2 
 i 18 104.993640183 4.5 1471.81587122 9.2288186905 1 2 
 i 18 105.251777105 4.5 1481.52358091 9.38082178394 1 2 
 i 18 105.501935462 4.5 1491.2312906 9.2288186905 1 2 
 i 18 105.742119471 4.5 1500.93900028 9.38082178394 1 2 
 i 18 106.008508175 4.5 1510.64670997 9.64385618977 1 2 
 i 18 106.248121025 4.5 1520.35441966 9.55074678538 1 2 
 i 18 106.492123777 4.5 1530.06212934 9.38082178394 1 2 
 i 18 106.754449349 4.5 1539.76983903 9.55074678538 1 2 
 i 18 107.009138843 4.5 1549.47754872 9.38082178394 1 2 
 i 18 107.26060013 4.5 1559.1852584 9.96578428466 1 2 
 i 18 107.50869265 4.5 1568.89296809 8.64386 1 2 
 i 18 107.752287303 4.5 1578.60067777 8.47393118833 1 2 
 i 18 109.254100717 4.5 1675.67777464 8.64385618977 1 2 
 i 18 109.49456262 4.5 1685.38548433 8.47393118833 1 2 
 i 18 109.754525075 4.5 1695.09319401 9.05889368905 1 2 
 i 18 110.007928601 4.5 1704.8009037 9.2288186905 1 2 
 i 18 110.245158421 4.5 1714.50861339 9.05889368905 1 2 
 i 18 110.490414747 4.5 1724.21632307 9.2288186905 1 2 
 i 18 110.753984089 4.5 1733.92403276 9.47393118833 1 2 
 i 18 111.002318023 4.5 1743.63174245 9.38082178394 1 2 
 i 18 111.243461092 4.5 1753.33945213 9.2288186905 1 2 
 i 18 111.49059102 4.5 1763.04716182 9.38082178394 1 2 
 i 18 111.757640349 4.5 1772.75487151 9.2288186905 1 2 
 i 18 112.010764727 4.5 1782.46258119 9.79585928322 1 2 
 i 18 112.255369504 4.5 1792.17029088 9.96578428466 1 2 
 i 18 112.498268671 4.5 1801.87800056 9.79585928322 1 2 
 i 18 112.757789503 4.5 1811.58571025 9.96578428466 1 2 
 i 18 113.000275144 4.5 1821.29341994 10.2288186905 1 2 
 i 18 113.256180178 4.5 1831.00112962 10.1177873781 1 2 
 i 18 113.503575112 4.5 1840.70883931 9.96578428466 1 2 
 i 18 113.751375443 4.5 1850.416549 8.79586 1 2 
 i 18 113.993493172 4.5 1860.12425868 10.1177873781 1 2 
 i 18 114.249431086 4.5 1869.83196837 8.64385618977 1 2 
 i 18 114.253273622 4.5 1879.53967806 9.96578428466 1 2 
 i 18 114.49910082 4.5 1889.24738774 8.79585928322 1 2 
 i 18 114.49789067 4.5 1898.95509743 10.5507467854 1 2 
 i 18 114.743191773 4.5 1908.66280712 8.64385618977 1 2 
 i 18 114.757246171 4.5 1918.3705168 9.2288186905 1 2 
 i 18 114.995482583 4.5 1928.07822649 9.38082178394 1 2 
 i 18 115.241519102 4.5 1937.78593618 9.2288186905 1 2 
 i 18 115.509341792 4.5 1947.49364586 9.38082178394 1 2 
 i 18 115.756825051 4.5 1957.20135555 9.64385618977 1 2 
 i 18 115.99944538 4.5 1966.90906524 9.55074678538 1 2 
 i 18 116.241660718 4.5 2219.30951709 9.38082178394 1 2 
 i 18 116.505182912 4.5 2229.01722677 9.55074678538 1 2 
 i 18 116.739699193 4.5 2238.72493646 9.38082178394 1 2 
 i 18 116.997368783 4.5 2248.43264615 9.96578428466 1 2 
 i 18 117.243198792 4.5 2258.14035583 10.1177873781 1 2 
 i 18 117.49898298 4.5 2267.84806552 9.96578428466 1 2 
 i 18 117.745467217 4.5 2277.5557752 10.1177873781 1 2 
 i 18 117.991209722 4.5 2287.26348489 10.3808217839 1 2 
 i 18 118.244689397 4.5 2296.97119458 10.3040061869 1 2 
 i 18 118.497503708 4.5 2306.67890426 10.1177873781 1 2 
 i 18 118.739606751 4.5 2316.38661395 10.3040061869 1 2 
 i 18 118.991395145 4.5 2326.09432364 10.1177873781 1 2 
 i 18 119.256923731 4.5 2335.80203332 10.7027498788 1 2 
 i 18 119.5017887 4.5 2345.50974301 7.88897 1 2 
 i 18 119.739946675 4.5 2355.2174527 8.47393 1 2 
 i 18 124.243376826 6 2364.92516238 7.88897 1 2 
 i 18 130.249607362 6 2374.63287207 8.47393 1 2 
 i 18 136.257409826 6 2384.34058176 7.88897 1 2 
 i 18 142.240671986 6 2394.04829144 8.47393 1 2 
 i 18 148.25220019 6 2403.75600113 7.88897 1 2 
 i 18 154.248145407 6 2413.46371082 8.47393 1 2 
 i 18 160.245769986 6 2423.1714205 8.058 1 2 
 i 18 166.254320612 6 2432.87913019 8.64386 1 2 
 i 18 172.257216942 6 2442.58683988 8.88897 1 2 
 i 18 125.256928971 6 2452.29454956 8.64386 1 2 
 i 18 130.240317189 6 2462.00225925 8.88897 1 2 
 i 18 137.241748922 6 2471.70996894 8.058 1 2 
 i 18 142.244645692 6 2481.41767862 8.88897 1 2 
 i 18 149.253287209 6 2491.12538831 8.058 1 2 
 i 18 154.256869427 6 2500.83309799 8.64386 1 2 
 i 18 161.251721629 6 2510.54080768 8.058 1 2 
 i 18 166.248732333 6 2607.61790455 8.47393118833 1 2 
 i 18 173.248569655 6 2617.32561423 8.2288186905 1 2 
 i 18 125.37275282 4.5 2627.03332392 8.05889368905 13 14 
 i 18 125.489385096 4.5 2636.74103361 8.2288186905 13 14 
 i 18 125.63599371 4.5 2646.44874329 8.64385618977 13 14 
 i 18 125.75605168 4.5 2656.15645298 8.38082178394 13 14 
 i 18 125.870353057 4.5 2665.86416267 8.2288186905 13 14 
 i 18 126.010894935 4.5 2675.57187235 8.38082178394 13 14 
 i 18 126.130308225 4.5 2685.27958204 8.79585928322 13 14 
 i 18 126.245379944 4.5 2694.98729173 8.55074678538 13 14 
 i 18 126.373111147 4.5 2704.69500141 8.38082178394 13 14 
 i 18 126.499351388 4.5 2714.4027111 8.55074678538 13 14 
 i 18 126.614040362 4.5 2724.11042079 8.96578428466 13 14 
 i 18 126.749093396 4.5 2733.81813047 8.70274987883 13 14 
 i 18 126.871778105 4.5 2743.52584016 8.55074678538 13 14 
 i 18 127.000772203 4.5 2753.23354984 8.70274987883 13 14 
 i 18 127.13026554 4.5 2762.94125953 9.11778737811 13 14 
 i 18 127.259768545 4.5 2772.64896922 8.88896868761 13 14 
 i 18 127.370480672 4.5 2782.3566789 8.70274987883 13 14 
 i 18 127.4953425 4.5 2792.06438859 8.88896868761 13 14 
 i 18 127.635034248 4.5 2801.77209828 9.30400618689 13 14 
 i 18 127.741732397 4.5 2811.47980796 9.05889368905 13 14 
 i 18 127.874183379 4.5 2821.18751765 8.88896868761 13 14 
 i 18 128.008159361 4.5 2830.89522734 9.05889368905 13 14 
 i 18 128.120040967 4.5 2840.60293702 9.47393118833 13 14 
 i 18 128.249615052 4.5 2850.31064671 9.2288186905 13 14 
 i 18 128.377475279 4.5 2860.0183564 9.05889368905 13 14 
 i 18 128.49509097 4.5 2869.72606608 9.2288186905 13 14 
 i 18 128.615761005 4.5 2879.43377577 9.64385618977 13 14 
 i 18 128.745183683 4.5 2889.14148546 9.38082178394 13 14 
 i 18 128.872749358 4.5 2898.84919514 8.64386 13 14 
 i 18 128.998364897 4.5 3151.24964699 9.05889368905 13 14 
 i 18 129.132102822 4.5 3160.95735668 8.79585928322 13 14 
 i 18 130.365893481 4.5 3170.66506637 8.64385618977 13 14 
 i 18 130.499827537 4.5 3180.37277605 8.79585928322 13 14 
 i 18 130.615018416 4.5 3190.08048574 9.2288186905 13 14 
 i 18 130.752231411 4.5 3199.78819543 8.96578428466 13 14 
 i 18 130.878678508 4.5 3209.49590511 8.79585928322 13 14 
 i 18 130.989952612 4.5 3219.2036148 8.96578428466 13 14 
 i 18 131.132769995 4.5 3228.91132448 9.38082178394 13 14 
 i 18 131.244968476 4.5 3238.61903417 9.11778737811 13 14 
 i 18 131.37592242 4.5 3248.32674386 8.96578428466 13 14 
 i 18 131.49413962 4.5 3258.03445354 9.11778737811 13 14 
 i 18 131.623187839 4.5 3267.74216323 9.55074678538 13 14 
 i 18 131.740463715 4.5 3277.44987292 9.30400618689 13 14 
 i 18 131.883276086 4.5 3287.1575826 9.11778737811 13 14 
 i 18 131.997120718 4.5 3296.86529229 9.30400618689 13 14 
 i 18 132.125979988 4.5 3306.57300198 9.70274987883 13 14 
 i 18 132.246694647 4.5 3316.28071166 9.47393118833 13 14 
 i 18 132.365849532 4.5 3325.98842135 9.30400618689 13 14 
 i 18 132.491926355 4.5 3335.69613104 9.47393118833 13 14 
 i 18 132.620784073 4.5 3345.40384072 9.88896868761 13 14 
 i 18 132.745602739 4.5 3355.11155041 9.64385618977 13 14 
 i 18 132.878631825 4.5 3364.8192601 9.47393118833 13 14 
 i 18 132.99643389 4.5 3374.52696978 9.64385618977 13 14 
 i 18 133.123841737 4.5 3384.23467947 10.0588936891 13 14 
 i 18 133.256716442 4.5 3393.94238916 9.79585928322 13 14 
 i 18 133.37658684 4.5 3403.65009884 9.64385618977 13 14 
 i 18 133.50925944 4.5 3413.35780853 9.79585928322 13 14 
 i 18 133.627145152 4.5 3423.06551822 10.2288186905 13 14 
 i 18 133.758127904 4.5 3432.7732279 9.96578428466 13 14 
 i 18 133.883986698 4.5 3442.48093759 8.88897 13 14 
 i 18 134.005016409 4.5 3539.55803445 9.30400618689 13 14 
 i 18 134.124803639 4.5 3549.26574414 9.05889368905 13 14 
 i 18 137.378333568 4.5 3558.97345383 8.88896868761 13 14 
 i 18 137.50580027 4.5 3568.68116351 9.05889368905 13 14 
 i 18 137.628724206 4.5 3578.3888732 9.47393118833 13 14 
 i 18 137.749446749 4.5 3588.09658289 9.2288186905 13 14 
 i 18 137.868524168 4.5 3597.80429257 9.05889368905 13 14 
 i 18 137.999077831 4.5 3607.51200226 9.2288186905 13 14 
 i 18 138.125616653 4.5 3617.21971195 9.64385618977 13 14 
 i 18 138.245663162 4.5 3626.92742163 9.38082178394 13 14 
 i 18 138.374879658 4.5 3636.63513132 9.2288186905 13 14 
 i 18 138.510077332 4.5 3646.34284101 9.38082178394 13 14 
 i 18 138.62532835 4.5 3656.05055069 9.79585928322 13 14 
 i 18 138.74082175 4.5 3665.75826038 9.55074678538 13 14 
 i 18 138.884115018 4.5 3675.46597006 9.38082178394 13 14 
 i 18 139.00794401 4.5 3685.17367975 9.55074678538 13 14 
 i 18 139.131626864 4.5 3694.88138944 9.96578428466 13 14 
 i 18 139.253461685 4.5 3704.58909912 9.70274987883 13 14 
 i 18 139.364735118 4.5 3714.29680881 9.55074678538 13 14 
 i 18 139.504202553 4.5 3724.0045185 9.70274987883 13 14 
 i 18 139.635976549 4.5 3733.71222818 10.1177873781 13 14 
 i 18 139.7517074 4.5 3743.41993787 9.88896868761 13 14 
 i 18 139.880256378 4.5 3753.12764756 9.70274987883 13 14 
 i 18 139.99630903 4.5 3762.83535724 9.88896868761 13 14 
 i 18 140.120844418 4.5 3772.54306693 10.3040061869 13 14 
 i 18 140.241301618 4.5 3782.25077662 10.0588936891 13 14 
 i 18 140.382023124 4.5 3791.9584863 9.88896868761 13 14 
 i 18 140.496567602 4.5 3801.66619599 10.0588936891 13 14 
 i 18 140.634492513 4.5 3811.37390568 10.4739311883 13 14 
 i 18 140.741506844 4.5 3821.08161536 10.2288186905 13 14 
 i 18 140.866220091 4.5 3830.78932505 8.64386 13 14 
 i 18 141.005735154 4.5 4083.1897769 9.05889368905 13 14 
 i 18 141.123646333 4.5 4092.89748659 8.79585928322 13 14 
 i 18 142.381062216 4.5 4102.60519627 8.64385618977 13 14 
 i 18 142.492580609 4.5 4112.31290596 8.79585928322 13 14 
 i 18 142.621869217 4.5 4122.02061565 9.2288186905 13 14 
 i 18 142.753747462 4.5 4131.72832533 8.96578428466 13 14 
 i 18 142.868685023 4.5 4141.43603502 8.79585928322 13 14 
 i 18 143.009655201 4.5 4151.1437447 8.96578428466 13 14 
 i 18 143.121176423 4.5 4160.85145439 9.38082178394 13 14 
 i 18 143.249976161 4.5 4170.55916408 9.11778737811 13 14 
 i 18 143.369451768 4.5 4180.26687376 8.96578428466 13 14 
 i 18 143.502108379 4.5 4189.97458345 9.11778737811 13 14 
 i 18 143.631099671 4.5 4199.68229314 9.55074678538 13 14 
 i 18 143.739408331 4.5 4209.39000282 9.30400618689 13 14 
 i 18 143.866364867 4.5 4219.09771251 9.11778737811 13 14 
 i 18 143.992084259 4.5 4228.8054222 9.30400618689 13 14 
 i 18 144.117832626 4.5 4238.51313188 9.70274987883 13 14 
 i 18 144.250819245 4.5 4248.22084157 9.47393118833 13 14 
 i 18 144.369853784 4.5 4257.92855126 9.30400618689 13 14 
 i 18 144.496774491 4.5 4267.63626094 9.47393118833 13 14 
 i 18 144.626373288 4.5 4277.34397063 9.88896868761 13 14 
 i 18 144.752706051 4.5 4287.05168032 9.64385618977 13 14 
 i 18 144.877895179 4.5 4296.75939 9.47393118833 13 14 
 i 18 144.991532255 4.5 4306.46709969 9.64385618977 13 14 
 i 18 145.124731789 4.5 4316.17480938 10.0588936891 13 14 
 i 18 145.25299317 4.5 4325.88251906 9.79585928322 13 14 
 i 18 145.365508486 4.5 4335.59022875 9.64385618977 13 14 
 i 18 145.506502669 4.5 4345.29793844 9.79585928322 13 14 
 i 18 145.614816955 4.5 4355.00564812 10.2288186905 13 14 
 i 18 145.746013084 4.5 4364.71335781 9.96578428466 13 14 
 i 18 145.876579472 4.5 4374.4210675 8.88897 13 14 
 i 18 146.005463349 4.5 4471.49816436 9.30400618689 13 14 
 i 18 146.132471709 4.5 4481.20587405 9.05889368905 13 14 
 i 18 149.378900543 4.5 4490.91358373 8.88896868761 13 14 
 i 18 149.509835076 4.5 4409.39470957 9.05889368905 13 14 
 i 18 149.629377373 4.5 4396.45109663 9.47393118833 13 14 
 i 18 149.745198683 4.5 4383.50748368 9.2288186905 13 14 
 i 18 149.885609415 4.5 4370.56387074 9.05889368905 13 14 
 i 18 149.990065572 4.5 4357.6202578 9.2288186905 13 14 
 i 18 150.125071729 4.5 4344.67664486 9.64385618977 13 14 
 i 18 150.244474094 4.5 4331.73303192 9.38082178394 13 14 
 i 18 150.384024423 4.5 4318.78941898 9.2288186905 13 14 
 i 18 150.509090874 4.5 4305.84580604 9.38082178394 13 14 
 i 18 150.619712811 4.5 4292.9021931 9.79585928322 13 14 
 i 18 150.749665107 4.5 4279.95858015 9.55074678538 13 14 
 i 18 150.883159228 4.5 4267.01496721 9.38082178394 13 14 
 i 18 151.005881953 4.5 4254.07135427 9.55074678538 13 14 
 i 18 151.135567764 4.5 4241.12774133 9.96578428466 13 14 
 i 18 151.242472579 4.5 4228.18412839 9.70274987883 13 14 
 i 18 151.380361368 4.5 4215.24051545 9.55074678538 13 14 
 i 18 151.497251039 4.5 4202.29690251 9.70274987883 13 14 
 i 18 151.634531557 4.5 4189.35328957 10.1177873781 13 14 
 i 18 151.747150204 4.5 4176.40967662 9.88896868761 13 14 
 i 18 151.885726822 4.5 4163.46606368 9.70274987883 13 14 
 i 18 151.994930925 4.5 4150.52245074 9.88896868761 13 14 
 i 18 152.127483586 4.5 4137.5788378 10.3040061869 13 14 
 i 18 152.254232202 4.5 4124.63522486 10.0588936891 13 14 
 i 18 152.364277451 4.5 4021.08632211 9.88896868761 13 14 
 i 18 152.50861796 4.5 4008.14270916 10.0588936891 13 14 
 i 18 152.621038474 4.5 3995.19909622 10.4739311883 13 14 
 i 18 152.753207892 4.5 3982.25548328 10.2288186905 13 14 
 i 18 152.872641164 4.5 3969.31187034 8.058 13 14 
 i 18 152.999165919 4.5 3956.3682574 8.47393118833 13 14 
 i 18 153.114188712 4.5 3943.42464446 8.2288186905 13 14 
 i 18 154.377729488 4.5 3930.48103152 8.05889368905 13 14 
 i 18 154.499438075 4.5 3917.53741858 8.2288186905 13 14 
 i 18 154.633222036 4.5 3904.59380563 8.64385618977 13 14 
 i 18 154.742295979 4.5 3891.65019269 8.38082178394 13 14 
 i 18 154.865238941 4.5 3878.70657975 8.2288186905 13 14 
 i 18 154.994385036 4.5 3865.76296681 8.38082178394 13 14 
 i 18 155.123731185 4.5 3852.81935387 8.79585928322 13 14 
 i 18 155.255114512 4.5 3839.87574093 8.55074678538 13 14 
 i 18 155.364781725 4.5 3826.93212799 8.38082178394 13 14 
 i 18 155.49698734 4.5 3813.98851505 8.55074678538 13 14 
 i 18 155.61719442 4.5 3801.0449021 8.96578428466 13 14 
 i 18 155.756768699 4.5 3788.10128916 8.70274987883 13 14 
 i 18 155.868657667 4.5 3775.15767622 8.55074678538 13 14 
 i 18 156.008219043 4.5 3762.21406328 8.70274987883 13 14 
 i 18 156.121474563 4.5 3749.27045034 9.11778737811 13 14 
 i 18 156.246908989 4.5 3736.3268374 8.88896868761 13 14 
 i 18 156.371929211 4.5 3477.45457966 8.70274987883 13 14 
 i 18 156.508162702 4.5 3464.51096672 8.88896868761 13 14 
 i 18 156.62408901 4.5 3451.56735378 9.30400618689 13 14 
 i 18 156.753383346 4.5 3438.62374084 9.05889368905 13 14 
 i 18 156.867508199 4.5 3425.68012789 8.88896868761 13 14 
 i 18 157.005480128 4.5 3412.73651495 9.05889368905 13 14 
 i 18 157.121923842 4.5 3399.79290201 9.47393118833 13 14 
 i 18 157.256139215 4.5 3386.84928907 9.2288186905 13 14 
 i 18 157.383138977 4.5 3373.90567613 9.05889368905 13 14 
 i 18 157.507339911 4.5 3360.96206319 9.2288186905 13 14 
 i 18 157.62031386 4.5 3348.01845025 9.64385618977 13 14 
 i 18 157.755547575 4.5 3335.07483731 9.38082178394 13 14 
 i 18 157.864470715 4.5 3322.13122436 8.88897 13 14 
 i 18 157.999683735 4.5 3309.18761142 9.30400618689 13 14 
 i 18 158.117888292 4.5 3296.24399848 9.05889368905 13 14 
 i 18 161.385108965 4.5 3283.30038554 8.88896868761 13 14 
 i 18 161.496865544 4.5 3270.3567726 9.05889368905 13 14 
 i 18 161.624735934 4.5 3257.41315966 9.47393118833 13 14 
 i 18 161.747259756 4.5 3244.46954672 9.2288186905 13 14 
 i 18 161.871098327 4.5 3231.52593378 9.05889368905 13 14 
 i 18 161.992194632 4.5 3218.58232083 9.2288186905 13 14 
 i 18 162.123963158 4.5 3205.63870789 9.64385618977 13 14 
 i 18 162.258552773 4.5 3192.69509495 9.38082178394 13 14 
 i 18 162.374028168 4.5 3089.1461922 9.2288186905 13 14 
 i 18 162.499262465 4.5 3076.20257926 9.38082178394 13 14 
 i 18 162.63235745 4.5 3063.25896632 9.79585928322 13 14 
 i 18 162.75566431 4.5 3050.31535337 9.55074678538 13 14 
 i 18 162.87756859 4.5 3037.37174043 9.38082178394 13 14 
 i 18 163.009906759 4.5 3024.42812749 9.55074678538 13 14 
 i 18 163.115408701 4.5 3011.48451455 9.96578428466 13 14 
 i 18 163.243268055 4.5 2998.54090161 9.70274987883 13 14 
 i 18 163.377601736 4.5 2985.59728867 9.55074678538 13 14 
 i 18 163.495771249 4.5 2972.65367573 9.70274987883 13 14 
 i 18 163.628837307 4.5 2959.71006279 10.1177873781 13 14 
 i 18 163.752099538 4.5 2946.76644984 9.88896868761 13 14 
 i 18 163.875565678 4.5 2933.8228369 9.70274987883 13 14 
 i 18 163.996429839 4.5 2920.87922396 9.88896868761 13 14 
 i 18 164.114426275 4.5 2907.93561102 10.3040061869 13 14 
 i 18 164.249914712 4.5 2894.99199808 10.0588936891 13 14 
 i 18 164.385321157 4.5 2882.04838514 9.88896868761 13 14 
 i 18 164.490215121 4.5 2869.1047722 10.0588936891 13 14 
 i 18 164.633769591 4.5 2856.16115926 10.4739311883 13 14 
 i 18 164.740578407 4.5 2843.21754631 10.2288186905 13 14 
 i 18 164.875937954 4.5 2830.27393337 8.058 13 14 
 i 18 165.008144565 4.5 2817.33032043 8.47393118833 13 14 
 i 18 165.119973374 4.5 2804.38670749 8.2288186905 13 14 
 i 18 166.380544057 4.5 2545.51444975 8.05889368905 13 14 
 i 18 166.497429967 4.5 2532.57083681 8.2288186905 13 14 
 i 18 166.618483486 4.5 2519.62722387 8.64385618977 13 14 
 i 18 166.742748335 4.5 2506.68361093 8.38082178394 13 14 
 i 18 166.884749022 4.5 2493.73999799 8.2288186905 13 14 
 i 18 166.991630722 4.5 2480.79638505 8.38082178394 13 14 
 i 18 167.130942629 4.5 2467.85277211 8.79585928322 13 14 
 i 18 167.251931468 4.5 2454.90915916 8.55074678538 13 14 
 i 18 167.369078442 4.5 2441.96554622 8.38082178394 13 14 
 i 18 167.50053023 4.5 2429.02193328 8.55074678538 13 14 
 i 18 167.634520514 4.5 2416.07832034 8.96578428466 13 14 
 i 18 167.760954086 4.5 2403.1347074 8.70274987883 13 14 
 i 18 167.879707068 4.5 2390.19109446 8.55074678538 13 14 
 i 18 168.005444864 4.5 2377.24748152 8.70274987883 13 14 
 i 18 168.117745159 4.5 2364.30386858 9.11778737811 13 14 
 i 18 168.248411725 4.5 2351.36025563 8.88896868761 13 14 
 i 18 168.384917738 4.5 2338.41664269 8.70274987883 13 14 
 i 18 168.496425902 4.5 2325.47302975 8.88896868761 13 14 
 i 18 168.614446395 4.5 2312.52941681 9.30400618689 13 14 
 i 18 168.75261405 4.5 2299.58580387 9.05889368905 13 14 
 i 18 168.884134994 4.5 2286.64219093 8.88896868761 13 14 
 i 18 169.009658038 4.5 2273.69857799 9.05889368905 13 14 
 i 18 169.126652722 4.5 2260.75496505 9.47393118833 13 14 
 i 18 169.241663089 4.5 2157.20606229 9.2288186905 13 14 
 i 18 169.367492381 4.5 2144.26244935 9.05889368905 13 14 
 i 18 169.508439292 4.5 2131.31883641 9.2288186905 13 14 
 i 18 169.628962647 4.5 2118.37522347 9.64385618977 13 14 
 i 18 169.75795047 4.5 2105.43161053 9.38082178394 13 14 
 i 18 169.875227018 4.5 2092.48799759 8.64386 13 14 
 i 18 169.996696886 4.5 2079.54438464 9.05889368905 13 14 
 i 18 170.118538748 4.5 2066.6007717 8.79585928322 13 14 
 i 18 173.38147551 4.5 2053.65715876 8.64385618977 13 14 
 i 18 173.497701591 4.5 2040.71354582 8.79585928322 13 14 
 i 18 173.631356027 4.5 2027.76993288 9.2288186905 13 14 
 i 18 173.756237839 4.5 2014.82631994 8.96578428466 13 14 
 i 18 173.875553311 4.5 2001.882707 8.79585928322 13 14 
 i 18 173.992914564 4.5 1988.93909406 8.96578428466 13 14 
 i 18 174.133581679 4.5 1975.99548111 9.38082178394 13 14 
 i 18 174.256799391 4.5 1963.05186817 9.11778737811 13 14 
 i 18 174.385740282 4.5 1950.10825523 8.96578428466 13 14 
 i 18 174.503553895 4.5 1937.16464229 9.11778737811 13 14 
 i 18 174.627985487 4.5 1924.22102935 9.55074678538 13 14 
 i 18 174.759658403 4.5 1911.27741641 9.30400618689 13 14 
 i 18 174.866292363 4.5 1898.33380347 9.11778737811 13 14 
 i 18 175.003423742 4.5 1885.39019053 9.30400618689 13 14 
 i 18 175.134365871 4.5 1872.44657758 9.70274987883 13 14 
 i 18 175.240458149 4.5 1613.57431985 9.47393118833 13 14 
 i 18 175.38484175 4.5 1600.6307069 9.30400618689 13 14 
 i 18 175.508037403 4.5 1587.68709396 9.47393118833 13 14 
 i 18 175.635479067 4.5 1574.74348102 9.88896868761 13 14 
 i 18 175.750804605 4.5 1561.79986808 9.64385618977 13 14 
 i 18 175.882526441 4.5 1548.85625514 9.47393118833 13 14 
 i 18 175.992819495 4.5 1535.9126422 9.64385618977 13 14 
 i 18 176.120765618 4.5 1522.96902926 10.0588936891 13 14 
 i 18 176.242508834 4.5 1510.02541632 9.79585928322 13 14 
 i 18 176.372263977 4.5 1497.08180337 9.64385618977 13 14 
 i 18 176.49433806 4.5 1484.13819043 9.79585928322 13 14 
 i 18 176.616663047 4.5 1471.19457749 10.2288186905 13 14 
 i 18 176.740471302 4.5 1458.25096455 9.96578428466 13 14 
 i 18 176.866599619 4.5 1445.30735161 8.058 13 14 
 i 18 176.993770228 4.5 1432.36373867 8.2288186905 13 14 
 i 18 177.11749058 4.5 1419.42012573 8.64385618977 13 14 
 i 18 125.424731454 4.5 1406.47651279 8.38082178394 1 2 
 i 18 125.593478123 4.5 1393.53289984 8.2288186905 1 2 
 i 18 125.740449597 4.5 1380.5892869 8.05889368905 1 2 
 i 18 125.926527152 4.5 1367.64567396 8.2288186905 1 2 
 i 18 126.075065582 4.5 1354.70206102 8.64385618977 1 2 
 i 18 126.25262504 4.5 1341.75844808 8.38082178394 1 2 
 i 18 126.423533545 4.5 1328.81483514 8.2288186905 1 2 
 i 18 126.576917189 4.5 1225.26593238 8.05889368905 1 2 
 i 18 126.752436472 4.5 1212.32231944 8.2288186905 1 2 
 i 18 126.926655889 4.5 5000 8.64385618977 1 2 
 i 18 127.072389374 4.5 5000 8.38082178394 1 2 
 i 18 127.250969125 4.5 5000 8.2288186905 1 2 
 i 18 127.413755309 4.5 5000 8.05889368905 1 2 
 i 18 127.586259796 4.5 5000 8.2288186905 1 2 
 i 18 127.751996172 4.5 5000 8.64385618977 1 2 
 i 18 127.914072216 4.5 5000 8.38082178394 1 2 
 i 18 128.07708978 4.5 5000 8.2288186905 1 2 
 i 18 128.253746314 4.5 5000 8.05889368905 1 2 
 i 18 128.418342758 4.5 5000 8.2288186905 1 2 
 i 18 128.575692157 4.5 5000 8.64385618977 1 2 
 i 18 128.743639568 4.5 5000 8.64386 1 2 
 i 18 128.921572735 4.5 5000 8.79585928322 1 2 
 i 18 129.080301342 4.5 1336.12824622 9.2288186905 1 2 
 i 18 130.422542015 4.5 1346.59964985 8.96578428466 1 2 
 i 18 130.574138334 4.5 1357.07105348 8.79585928322 1 2 
 i 18 130.756144158 4.5 1367.54245712 8.64385618977 1 2 
 i 18 130.913008015 4.5 1378.01386075 8.79585928322 1 2 
 i 18 131.07744519 4.5 1388.48526438 9.2288186905 1 2 
 i 18 131.247636869 4.5 1398.95666801 8.96578428466 1 2 
 i 18 131.411678481 4.5 1409.42807165 8.79585928322 1 2 
 i 18 131.576979399 4.5 1419.89947528 8.64385618977 1 2 
 i 18 131.755397654 4.5 1430.37087891 8.79585928322 1 2 
 i 18 131.920218098 4.5 1440.84228255 9.2288186905 1 2 
 i 18 132.077780707 4.5 1451.31368618 8.96578428466 1 2 
 i 18 132.253788103 4.5 1461.78508981 8.79585928322 1 2 
 i 18 132.420043283 4.5 1472.25649344 8.64385618977 1 2 
 i 18 132.578061123 4.5 1482.72789708 8.79585928322 1 2 
 i 18 132.759720883 4.5 1493.19930071 9.2288186905 1 2 
 i 18 132.92156572 4.5 1503.67070434 8.96578428466 1 2 
 i 18 133.085570751 4.5 1514.14210797 8.79585928322 1 2 
 i 18 133.257129322 4.5 1524.61351161 8.64385618977 1 2 
 i 18 133.427210344 4.5 1535.08491524 8.79585928322 1 2 
 i 18 133.581811549 4.5 1545.55631887 9.2288186905 1 2 
 i 18 133.760567692 4.5 1556.0277225 8.88897 1 2 
 i 18 133.916122197 4.5 1566.49912614 9.05889368905 1 2 
 i 18 134.088926579 4.5 1964.41245915 9.47393118833 1 2 
 i 18 137.417412811 4.5 1974.88386278 9.2288186905 1 2 
 i 18 137.585925096 4.5 1985.35526642 9.05889368905 1 2 
 i 18 137.754343818 4.5 1995.82667005 8.88896868761 1 2 
 i 18 137.917357033 4.5 2006.29807368 9.05889368905 1 2 
 i 18 138.076016783 4.5 2016.76947731 9.47393118833 1 2 
 i 18 138.25491635 4.5 2027.24088095 9.2288186905 1 2 
 i 18 138.42736899 4.5 2037.71228458 9.05889368905 1 2 
 i 18 138.589523746 4.5 2048.18368821 8.88896868761 1 2 
 i 18 138.758286981 4.5 2058.65509184 9.05889368905 1 2 
 i 18 138.927359055 4.5 2069.12649548 9.47393118833 1 2 
 i 18 139.093015401 4.5 2079.59789911 9.2288186905 1 2 
 i 18 139.252135143 4.5 2090.06930274 9.05889368905 1 2 
 i 18 139.408963388 4.5 2100.54070637 8.88896868761 1 2 
 i 18 139.592908475 4.5 2111.01211001 9.05889368905 1 2 
 i 18 139.744065793 4.5 2121.48351364 9.47393118833 1 2 
 i 18 139.912053 4.5 2131.95491727 9.2288186905 1 2 
 i 18 140.07457961 4.5 2142.4263209 9.05889368905 1 2 
 i 18 140.245793328 4.5 2152.89772454 8.88896868761 1 2 
 i 18 140.416734516 4.5 2163.36912817 9.05889368905 1 2 
 i 18 140.592317133 4.5 2173.8405318 9.47393118833 1 2 
 i 18 140.745134621 4.5 2184.31193544 8.64386 1 2 
 i 18 140.908860941 4.5 2194.78333907 8.79585928322 1 2 
 i 18 141.084554824 4.5 2844.01035725 9.2288186905 1 2 
 i 18 142.423045783 4.5 2854.48176089 8.96578428466 1 2 
 i 18 142.582614957 4.5 2864.95316452 8.79585928322 1 2 
 i 18 142.757910281 4.5 2875.42456815 8.64385618977 1 2 
 i 18 142.91191471 4.5 2885.89597178 8.79585928322 1 2 
 i 18 143.091383261 4.5 2896.36737542 9.2288186905 1 2 
 i 18 143.243730314 4.5 2906.83877905 8.96578428466 1 2 
 i 18 143.421941167 4.5 2917.31018268 8.79585928322 1 2 
 i 18 143.577363177 4.5 2927.78158631 8.64385618977 1 2 
 i 18 143.756205706 4.5 2938.25298995 8.79585928322 1 2 
 i 18 143.913233543 4.5 2948.72439358 9.2288186905 1 2 
 i 18 144.084581848 4.5 2959.19579721 8.96578428466 1 2 
 i 18 144.254188793 4.5 2969.66720085 8.79585928322 1 2 
 i 18 144.417543534 4.5 2980.13860448 8.64385618977 1 2 
 i 18 144.578621909 4.5 2990.61000811 8.79585928322 1 2 
 i 18 144.760551823 4.5 3001.08141174 9.2288186905 1 2 
 i 18 144.915567801 4.5 3011.55281538 8.96578428466 1 2 
 i 18 145.076865391 4.5 3022.02421901 8.79585928322 1 2 
 i 18 145.257200987 4.5 3032.49562264 8.64385618977 1 2 
 i 18 145.424126558 4.5 3042.96702627 8.79585928322 1 2 
 i 18 145.582629077 4.5 3053.43842991 9.2288186905 1 2 
 i 18 145.752495081 4.5 3063.90983354 8.88897 1 2 
 i 18 145.926613095 4.5 3074.38123717 9.05889368905 1 2 
 i 18 146.087023261 4.5 3472.29457019 9.47393118833 1 2 
 i 18 149.410400652 4.5 3482.76597382 9.2288186905 1 2 
 i 18 149.588122226 4.5 3493.23737745 9.05889368905 1 2 
 i 18 149.746857751 4.5 3503.70878108 8.88896868761 1 2 
 i 18 149.919021114 4.5 3514.18018472 9.05889368905 1 2 
 i 18 150.093624417 4.5 3524.65158835 9.47393118833 1 2 
 i 18 150.254584615 4.5 3535.12299198 9.2288186905 1 2 
 i 18 150.40920253 4.5 3545.59439561 9.05889368905 1 2 
 i 18 150.586050191 4.5 3556.06579925 8.88896868761 1 2 
 i 18 150.740153395 4.5 3566.53720288 9.05889368905 1 2 
 i 18 150.910262795 4.5 3577.00860651 9.47393118833 1 2 
 i 18 151.077499902 4.5 3587.48001014 9.2288186905 1 2 
 i 18 151.253786155 4.5 3597.95141378 9.05889368905 1 2 
 i 18 151.412214206 4.5 3608.42281741 8.88896868761 1 2 
 i 18 151.58938261 4.5 3618.89422104 9.05889368905 1 2 
 i 18 151.743362782 4.5 3629.36562467 9.47393118833 1 2 
 i 18 151.906576505 4.5 3639.83702831 9.2288186905 1 2 
 i 18 152.083195251 4.5 3650.30843194 9.05889368905 1 2 
 i 18 152.240395053 4.5 3660.77983557 8.88896868761 1 2 
 i 18 152.415787408 4.5 3671.2512392 9.05889368905 1 2 
 i 18 152.57851195 4.5 3681.72264284 9.47393118833 1 2 
 i 18 152.754524729 4.5 3692.19404647 8.058 1 2 
 i 18 152.913529458 4.5 3702.6654501 8.2288186905 1 2 
 i 18 153.081972854 4.5 4351.89246829 8.64385618977 1 2 
 i 18 154.423645498 4.5 4362.36387192 8.38082178394 1 2 
 i 18 154.586966444 4.5 4372.83527555 8.2288186905 1 2 
 i 18 154.74808 4.5 4383.30667919 8.05889368905 1 2 
 i 18 154.92014374 4.5 4393.77808282 8.2288186905 1 2 
 i 18 155.090317388 4.5 4404.24948645 8.64385618977 1 2 
 i 18 155.256380018 4.5 4414.72089008 8.38082178394 1 2 
 i 18 155.416223888 4.5 4425.19229372 8.2288186905 1 2 
 i 18 155.579627258 4.5 4435.66369735 8.05889368905 1 2 
 i 18 155.746969099 4.5 4446.13510098 8.2288186905 1 2 
 i 18 155.910011146 4.5 4456.60650462 8.64385618977 1 2 
 i 18 156.079877369 4.5 4467.07790825 8.38082178394 1 2 
 i 18 156.255998543 4.5 4477.54931188 8.2288186905 1 2 
 i 18 156.412596341 4.5 4488.02071551 8.05889368905 1 2 
 i 18 156.576523072 4.5 4498.49211915 8.2288186905 1 2 
 i 18 156.74711684 4.5 4358.63605209 8.64385618977 1 2 
 i 18 156.910835226 4.5 4342.92894677 8.38082178394 1 2 
 i 18 157.078185261 4.5 4327.22184144 8.2288186905 1 2 
 i 18 157.245128434 4.5 4311.51473612 8.05889368905 1 2 
 i 18 157.423171308 4.5 4295.8076308 8.2288186905 1 2 
 i 18 157.588833806 4.5 4280.10052547 8.64385618977 1 2 
 i 18 157.745930348 4.5 4264.39342015 8.88897 1 2 
 i 18 157.924696437 4.5 4248.68631483 9.05889368905 1 2 
 i 18 158.076702396 4.5 4232.9792095 9.47393118833 1 2 
 i 18 161.418508518 4.5 4217.27210418 9.2288186905 1 2 
 i 18 161.587536178 4.5 4201.56499886 9.05889368905 1 2 
 i 18 161.758232207 4.5 4185.85789353 8.88896868761 1 2 
 i 18 161.920728536 4.5 4170.15078821 9.05889368905 1 2 
 i 18 162.088829891 4.5 4154.44368289 9.47393118833 1 2 
 i 18 162.242346785 4.5 4138.73657756 9.2288186905 1 2 
 i 18 162.408452331 4.5 3730.35183916 9.05889368905 1 2 
 i 18 162.58545155 4.5 3714.64473384 8.88896868761 1 2 
 i 18 162.753615646 4.5 3698.93762851 9.05889368905 1 2 
 i 18 162.921546715 4.5 3683.23052319 9.47393118833 1 2 
 i 18 163.080264533 4.5 3667.52341787 9.2288186905 1 2 
 i 18 163.244600981 4.5 3651.81631254 9.05889368905 1 2 
 i 18 163.417406182 4.5 3636.10920722 8.88896868761 1 2 
 i 18 163.593774872 4.5 3620.4021019 9.05889368905 1 2 
 i 18 163.754856296 4.5 3604.69499657 9.47393118833 1 2 
 i 18 163.922775926 4.5 3588.98789125 9.2288186905 1 2 
 i 18 164.084844779 4.5 3573.28078593 9.05889368905 1 2 
 i 18 164.245993636 4.5 3557.5736806 8.88896868761 1 2 
 i 18 164.4160037 4.5 3541.86657528 9.05889368905 1 2 
 i 18 164.591274075 4.5 3526.15946996 9.47393118833 1 2 
 i 18 164.747541201 4.5 3510.45236463 8.058 1 2 
 i 18 164.916371821 4.5 2850.75394106 8.2288186905 1 2 
 i 18 165.086209522 4.5 2835.04683573 8.64385618977 1 2 
 i 18 166.427309043 4.5 2819.33973041 8.38082178394 1 2 
 i 18 166.590131399 4.5 2803.63262509 8.2288186905 1 2 
 i 18 166.753824731 4.5 2787.92551976 8.05889368905 1 2 
 i 18 166.918683241 4.5 2772.21841444 8.2288186905 1 2 
 i 18 167.085708834 4.5 2756.51130912 8.64385618977 1 2 
 i 18 167.247190698 4.5 2740.80420379 8.38082178394 1 2 
 i 18 167.427026754 4.5 2725.09709847 8.2288186905 1 2 
 i 18 167.576706117 4.5 2709.38999315 8.05889368905 1 2 
 i 18 167.748959237 4.5 2693.68288782 8.2288186905 1 2 
 i 18 167.92248822 4.5 2677.9757825 8.64385618977 1 2 
 i 18 168.078806361 4.5 2662.26867718 8.38082178394 1 2 
 i 18 168.253263845 4.5 2646.56157185 8.2288186905 1 2 
 i 18 168.412943233 4.5 2630.85446653 8.05889368905 1 2 
 i 18 168.580332516 4.5 2222.46972812 8.2288186905 1 2 
 i 18 168.755109946 4.5 2206.7626228 8.64385618977 1 2 
 i 18 168.925478869 4.5 2191.05551748 8.38082178394 1 2 
 i 18 169.073466835 4.5 2175.34841215 8.2288186905 1 2 
 i 18 169.256584769 4.5 2159.64130683 8.05889368905 1 2 
 i 18 169.40713448 4.5 2143.93420151 8.2288186905 1 2 
 i 18 169.58505565 4.5 2128.22709618 8.64385618977 1 2 
 i 18 169.740920098 4.5 2112.51999086 8.64386 1 2 
 i 18 169.909558384 4.5 2096.81288554 8.79585928322 1 2 
 i 18 170.085515414 4.5 2081.10578021 9.2288186905 1 2 
 i 18 173.407137615 4.5 2065.39867489 8.96578428466 1 2 
 i 18 173.576662604 4.5 2049.69156957 8.79585928322 1 2 
 i 18 173.746968689 4.5 2033.98446424 8.64385618977 1 2 
 i 18 173.905950133 4.5 2018.27735892 8.79585928322 1 2 
 i 18 174.086071933 4.5 2002.5702536 9.2288186905 1 2 
 i 18 174.25426544 4.5 1342.87183002 8.96578428466 1 2 
 i 18 174.420835041 4.5 1327.1647247 8.79585928322 1 2 
 i 18 174.589507533 4.5 1311.45761937 8.64385618977 1 2 
 i 18 174.74822471 4.5 1295.75051405 8.79585928322 1 2 
 i 18 174.925292625 4.5 1280.04340873 9.2288186905 1 2 
 i 18 175.091764181 4.5 1264.3363034 8.96578428466 1 2 
 i 18 175.249014572 4.5 1248.62919808 8.79585928322 1 2 
 i 18 175.419822738 4.5 1232.92209276 8.64385618977 1 2 
 i 18 175.590471887 4.5 1217.21498743 8.79585928322 1 2 
 i 18 175.757873457 4.5 1201.50788211 9.2288186905 1 2 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR1	   1    2  0.8 83 ;
$MIXDUR1	   13   14  0.7 84 ;ornaments

; "dx7.sco"
 i 11 0.00132830790893 6 8.05889 127 -1 3 4 
 i 11 6.00911758308 6 8.22882 127 -1 3 4 
 i 11 11.9943647585 6 8.05889 127 -1 3 4 
 i 11 18.0006151956 6 8.22882 127 -1 3 4 
 i 11 24.0066076662 6 8.05889 127 -1 3 4 
 i 11 29.9925651767 6 8.22882 127 -1 3 4 
 i 11 36.0074740133 6 8.05889 127 -1 3 4 
 i 11 42.0065460789 6 8.22882 127 -1 3 4 
 i 11 48.0009543857 6 8.05889 127 -1 3 4 
 i 11 53.9983622617 6 8.22882 127 -1 3 4 
 i 11 60.0064478928 6 8.05889 127 -1 3 4 
 i 11 65.9921875217 6 8.22882 127 -1 3 4 
 i 11 71.9936243058 6 8.05889 127 -1 3 4 
 i 11 77.9965242703 6 8.22882 127 -1 3 4 
 i 11 84.00102119 6 8.05889 127 -1 3 4 
 i 11 90.0077273889 6 8.22882 127 -1 3 4 
 i 11 96.0038619029 6 8.05889 127 -1 3 4 
 i 11 101.992924608 6 8.22882 127 -1 3 4 
 i 11 108.002711993 6 8.05889 127 -1 3 4 
 i 11 113.992848032 6 8.05889 127 -1 3 4 
 i 11 0.998182077767 6 8.64386 127 1 3 4 
 i 11 6.00015538096 6 8.79586 127 1 3 4 
 i 11 13.0068528218 6 8.22882 127 1 3 4 
 i 11 17.9960242247 6 8.64386 127 1 3 4 
 i 11 24.9904825443 6 8.79586 127 1 3 4 
 i 11 30.0016705146 6 8.22882 127 1 3 4 
 i 11 36.9961177494 6 8.05889 127 1 3 4 
 i 11 42.0077418807 6 8.79586 127 1 3 4 
 i 11 48.9893602973 6 8.22882 127 1 3 4 
 i 11 53.9944545677 6 8.05889 127 1 3 4 
 i 11 60.9979292172 6 8.64386 127 1 3 4 
 i 11 66.0105245432 6 8.22882 127 1 3 4 
 i 11 72.9950458331 6 8.05889 127 1 3 4 
 i 11 78.0079988479 6 8.64386 127 1 3 4 
 i 11 84.9934080914 6 8.79586 127 1 3 4 
 i 11 89.9929887677 6 8.05889 127 1 3 4 
 i 11 97.0027243995 6 8.64386 127 1 3 4 
 i 11 101.995284387 6 8.79586 127 1 3 4 
 i 11 108.991391675 6 8.22882 127 1 3 4 
 i 11 113.993359669 6 8.05889 127 1 3 4 
 i 11 120.997538494 6 8.2288186905 127 1 3 4 
 i 11 1.16676760511 4.5 8.05889368905 70.5977743022 1 15 16 
 i 11 1.33769922316 4.5 8.2288186905 70.6831706312 1 15 16 
 i 11 1.50328911873 4.5 8.79585928322 70.7685669602 1 15 16 
 i 11 1.67385935527 4.5 8.64385618977 70.8539632893 1 15 16 
 i 11 1.827078053 4.5 8.79585928322 70.9393596183 1 15 16 
 i 11 1.99676430141 4.5 8.64385618977 71.0247559473 1 15 16 
 i 11 2.17556652461 4.5 8.79585928322 71.1101522763 1 15 16 
 i 11 2.3276918431 4.5 9.05889368905 71.1955486054 1 15 16 
 i 11 2.50968714705 4.5 9.2288186905 71.2809449344 1 15 16 
 i 11 2.67228651345 4.5 9.05889368905 71.3663412634 1 15 16 
 i 11 2.82894571342 4.5 9.2288186905 71.4517375924 1 15 16 
 i 11 2.99048886032 4.5 9.79585928322 71.5371339215 1 15 16 
 i 11 3.16416663596 4.5 9.64385618977 71.6225302505 1 15 16 
 i 11 3.34200282432 4.5 9.79585928322 71.7079265795 1 15 16 
 i 11 3.49996534197 4.5 9.64385618977 71.7933229086 1 15 16 
 i 11 3.65822052334 4.5 9.79585928322 71.8787192376 1 15 16 
 i 11 3.83767356463 4.5 10.0588936891 71.9641155666 1 15 16 
 i 11 4.00948271411 4.5 10.2288186905 72.0495118956 1 15 16 
 i 11 4.16025358785 4.5 10.0588936891 72.1349082247 1 15 16 
 i 11 4.32690015411 4.5 10.2288186905 72.2203045537 1 15 16 
 i 11 4.49723283438 4.5 10.7958592832 72.3057008827 1 15 16 
 i 11 4.66264959791 4.5 10.6438561898 72.3910972117 1 15 16 
 i 11 4.83544001725 4.5 10.7958592832 72.4764935408 1 15 16 
 i 11 5.00198524199 4.5 10.6438561898 72.5618898698 1 15 16 
 i 11 5.17405769356 4.5 10.7958592832 72.6472861988 1 15 16 
 i 11 5.33015335918 4.5 11.0588936891 72.7326825279 1 15 16 
 i 11 5.50483927986 4.5 11.2288186905 72.8180788569 1 15 16 
 i 11 5.65625376461 4.5 11.0588936891 72.9034751859 1 15 16 
 i 11 5.82396701221 4.5 8.64386 72.9888715149 1 15 16 
 i 11 6.01043822121 4.5 11.2288186905 73.074267844 1 15 16 
 i 11 6.17044107431 4.5 8.79585928322 73.1596641679 1 15 16 
 i 11 6.16546504687 4.5 11.7958592832 73.159664173 1 15 16 
 i 11 6.3330090369 4.5 8.64385618977 73.2450604969 1 15 16 
 i 11 6.33117623285 4.5 11.6438561898 73.245060502 1 15 16 
 i 11 6.49961252183 4.5 8.79585928322 73.3304568259 1 15 16 
 i 11 6.49766662023 4.5 11.7958592832 73.3304568311 1 15 16 
 i 11 6.66968297238 4.5 9.38082178394 73.415853155 1 15 16 
 i 11 6.66955478855 4.5 11.6438561898 73.4158531601 1 15 16 
 i 11 6.82993511832 4.5 9.2288186905 73.501249484 1 15 16 
 i 11 6.83216352438 4.5 9.38082178394 73.5012494891 1 15 16 
 i 11 7.00106787528 4.5 9.2288186905 73.586645813 1 15 16 
 i 11 7.17387207261 4.5 9.38082178394 73.672042142 1 15 16 
 i 11 7.32924887126 4.5 9.64385618977 73.7574384711 1 15 16 
 i 11 7.49066879484 4.5 9.79585928322 73.8428348001 1 15 16 
 i 11 7.67289511221 4.5 9.64385618977 73.9282311291 1 15 16 
 i 11 7.83566634446 4.5 9.79585928322 74.0136274581 1 15 16 
 i 11 7.99354884994 4.5 10.3808217839 74.0990237872 1 15 16 
 i 11 8.16549764144 4.5 10.2288186905 74.1844201162 1 15 16 
 i 11 8.32993982231 4.5 10.3808217839 74.2698164452 1 15 16 
 i 11 8.50254446483 4.5 10.2288186905 74.3552127743 1 15 16 
 i 11 8.66524230133 4.5 10.3808217839 74.4406091033 1 15 16 
 i 11 8.83750187237 4.5 10.6438561898 74.5260054323 1 15 16 
 i 11 8.99351914729 4.5 10.7958592832 74.6114017613 1 15 16 
 i 11 9.16706031613 4.5 10.6438561898 74.6967980904 1 15 16 
 i 11 9.32513552456 4.5 10.7958592832 74.7821944194 1 15 16 
 i 11 9.51063867564 4.5 11.3808217839 74.8675907484 1 15 16 
 i 11 9.66552889431 4.5 11.2288186905 74.9529870774 1 15 16 
 i 11 9.84366881494 4.5 11.3808217839 75.0383834065 1 15 16 
 i 11 10.003419207 4.5 11.2288186905 75.1237797355 1 15 16 
 i 11 10.1583611736 4.5 11.3808217839 75.2091760645 1 15 16 
 i 11 10.3375102925 4.5 11.6438561898 75.2945723936 1 15 16 
 i 11 10.5067027601 4.5 11.7958592832 75.3799687226 1 15 16 
 i 11 10.658555223 4.5 11.6438561898 75.4653650516 1 15 16 
 i 11 10.8315291385 4.5 11.7958592832 75.5507613806 1 15 16 
 i 11 11.0039065997 4.5 12.3808217839 75.6361577097 1 15 16 
 i 11 11.1611975399 4.5 12.2288186905 75.7215540387 1 15 16 
 i 11 11.3304655301 4.5 12.3808217839 75.8069503677 1 15 16 
 i 11 11.4941998642 4.5 12.2288186905 75.8923466968 1 15 16 
 i 11 11.663055732 4.5 8.79586 75.9777430258 1 15 16 
 i 11 11.8413189445 4.5 8.96578428466 76.0631393548 1 15 16 
 i 11 13.1724720655 4.5 8.79585928322 76.7463099799 1 15 16 
 i 11 13.343494207 4.5 8.96578428466 76.8317063089 1 15 16 
 i 11 13.4982454798 4.5 9.55074678538 76.9171026379 1 15 16 
 i 11 13.6574744608 4.5 9.38082178394 77.0024989669 1 15 16 
 i 11 13.8359730825 4.5 9.55074678538 77.087895296 1 15 16 
 i 11 14.0062305096 4.5 9.38082178394 77.173291625 1 15 16 
 i 11 14.1733735523 4.5 9.55074678538 77.258687954 1 15 16 
 i 11 14.3346978639 4.5 9.79585928322 77.344084283 1 15 16 
 i 11 14.4944217688 4.5 9.96578428466 77.4294806121 1 15 16 
 i 11 14.6563436517 4.5 9.79585928322 77.5148769411 1 15 16 
 i 11 14.8345385263 4.5 9.96578428466 77.6002732701 1 15 16 
 i 11 14.9927046953 4.5 10.5507467854 77.6856695992 1 15 16 
 i 11 15.1669846566 4.5 10.3808217839 77.7710659282 1 15 16 
 i 11 15.3258601422 4.5 10.5507467854 77.8564622572 1 15 16 
 i 11 15.5011127198 4.5 10.3808217839 77.9418585862 1 15 16 
 i 11 15.6721496526 4.5 10.5507467854 78.0272549153 1 15 16 
 i 11 15.8342067675 4.5 10.7958592832 78.1126512443 1 15 16 
 i 11 15.9987632371 4.5 10.9657842847 78.1980475733 1 15 16 
 i 11 16.1678023212 4.5 10.7958592832 78.2834439024 1 15 16 
 i 11 16.3250080867 4.5 10.9657842847 78.3688402314 1 15 16 
 i 11 16.5035363408 4.5 11.5507467854 78.4542365604 1 15 16 
 i 11 16.6612921707 4.5 11.3808217839 78.5396328894 1 15 16 
 i 11 16.8399291918 4.5 11.5507467854 78.6250292185 1 15 16 
 i 11 16.9972867933 4.5 11.3808217839 78.7104255475 1 15 16 
 i 11 17.1556989402 4.5 11.5507467854 78.7958218765 1 15 16 
 i 11 17.3373858597 4.5 11.7958592832 78.8812182055 1 15 16 
 i 11 17.4903128678 4.5 11.9657842847 78.9666145346 1 15 16 
 i 11 17.6598119104 4.5 11.7958592832 79.0520108636 1 15 16 
 i 11 17.8249549452 4.5 8.22882 79.1374071926 1 15 16 
 i 11 17.9987451964 4.5 11.9657842847 79.2228035217 1 15 16 
 i 11 18.1652188449 4.5 8.38082178394 79.3081998456 1 15 16 
 i 11 18.1750115132 4.5 12.5507467854 79.3081998507 1 15 16 
 i 11 18.331808323 4.5 8.2288186905 79.3935961746 1 15 16 
 i 11 18.3409784727 4.5 12.3808217839 79.3935961797 1 15 16 
 i 11 18.5098374698 4.5 8.38082178394 79.4789925036 1 15 16 
 i 11 18.5003350845 4.5 12.5507467854 79.4789925087 1 15 16 
 i 11 18.6671889675 4.5 8.96578428466 79.5643888326 1 15 16 
 i 11 18.6714736119 4.5 12.3808217839 79.5643888378 1 15 16 
 i 11 18.8441132977 4.5 8.79585928322 79.6497851617 1 15 16 
 i 11 18.8293883838 4.5 8.96578428466 79.6497851668 1 15 16 
 i 11 19.0032229874 4.5 8.79585928322 79.7351814907 1 15 16 
 i 11 19.1704040262 4.5 8.96578428466 79.8205778197 1 15 16 
 i 11 19.3292077059 4.5 9.2288186905 79.9059741488 1 15 16 
 i 11 19.499673423 4.5 9.38082178394 79.9913704778 1 15 16 
 i 11 19.6726865325 4.5 9.2288186905 80.0767668068 1 15 16 
 i 11 19.8426852473 4.5 9.38082178394 80.1621631358 1 15 16 
 i 11 20.0078831688 4.5 9.96578428466 80.2475594649 1 15 16 
 i 11 20.1707192709 4.5 9.79585928322 80.3329557939 1 15 16 
 i 11 20.3281945672 4.5 9.96578428466 80.4183521229 1 15 16 
 i 11 20.5072832925 4.5 9.79585928322 80.5037484519 1 15 16 
 i 11 20.6578970807 4.5 9.96578428466 80.589144781 1 15 16 
 i 11 20.8377072025 4.5 10.2288186905 80.67454111 1 15 16 
 i 11 21.0108472795 4.5 10.3808217839 80.759937439 1 15 16 
 i 11 21.1737132372 4.5 10.2288186905 80.8453337681 1 15 16 
 i 11 21.3357339432 4.5 10.3808217839 80.9307300971 1 15 16 
 i 11 21.4996550561 4.5 10.9657842847 81.0161264261 1 15 16 
 i 11 21.6748983803 4.5 10.7958592832 81.1015227551 1 15 16 
 i 11 21.8370116843 4.5 10.9657842847 81.1869190842 1 15 16 
 i 11 22.0101302468 4.5 10.7958592832 81.2723154132 1 15 16 
 i 11 22.1719868978 4.5 10.9657842847 81.3577117422 1 15 16 
 i 11 22.336309639 4.5 11.2288186905 81.4431080712 1 15 16 
 i 11 22.4966630528 4.5 11.3808217839 81.5285044003 1 15 16 
 i 11 22.656544786 4.5 11.2288186905 81.6139007293 1 15 16 
 i 11 22.83831472 4.5 11.3808217839 81.6992970583 1 15 16 
 i 11 22.9941415159 4.5 11.9657842847 81.7846933874 1 15 16 
 i 11 23.1556761638 4.5 11.7958592832 81.8700897164 1 15 16 
 i 11 23.3404167579 4.5 11.9657842847 81.9554860454 1 15 16 
 i 11 23.504928213 4.5 11.7958592832 82.0408823744 1 15 16 
 i 11 23.6656239195 4.5 8.64386 82.1262787035 1 15 16 
 i 11 23.8364304596 4.5 8.79585928322 82.2116750325 1 15 16 
 i 11 25.1664067979 4.5 8.64385618977 82.8948456575 1 15 16 
 i 11 25.3392755735 4.5 8.79585928322 82.9802419866 1 15 16 
 i 11 25.499520836 4.5 9.38082178394 83.0656383156 1 15 16 
 i 11 25.6733549646 4.5 9.2288186905 83.1510346446 1 15 16 
 i 11 25.8264807614 4.5 9.38082178394 83.2364309737 1 15 16 
 i 11 25.9930472086 4.5 9.2288186905 83.3218273027 1 15 16 
 i 11 26.1724720515 4.5 9.38082178394 83.4072236317 1 15 16 
 i 11 26.3293569968 4.5 9.64385618977 83.4926199607 1 15 16 
 i 11 26.4937641096 4.5 9.79585928322 83.5780162898 1 15 16 
 i 11 26.6591185099 4.5 9.64385618977 83.6634126188 1 15 16 
 i 11 26.8301466439 4.5 9.79585928322 83.7488089478 1 15 16 
 i 11 26.9897213954 4.5 10.3808217839 83.8342052768 1 15 16 
 i 11 27.1742037572 4.5 10.2288186905 83.9196016059 1 15 16 
 i 11 27.329206921 4.5 10.3808217839 84.0049979349 1 15 16 
 i 11 27.4971780168 4.5 10.2288186905 84.0903942639 1 15 16 
 i 11 27.6725315528 4.5 10.3808217839 84.175790593 1 15 16 
 i 11 27.8397632111 4.5 10.6438561898 84.261186922 1 15 16 
 i 11 28.0076563142 4.5 10.7958592832 84.346583251 1 15 16 
 i 11 28.1737523058 4.5 10.6438561898 84.43197958 1 15 16 
 i 11 28.323815891 4.5 10.7958592832 84.5173759091 1 15 16 
 i 11 28.5034072825 4.5 11.3808217839 84.6027722381 1 15 16 
 i 11 28.6630345497 4.5 11.2288186905 84.6881685671 1 15 16 
 i 11 28.8270868256 4.5 11.3808217839 84.7735648961 1 15 16 
 i 11 29.010823846 4.5 11.2288186905 84.8589612252 1 15 16 
 i 11 29.1604568879 4.5 11.3808217839 84.9443575542 1 15 16 
 i 11 29.3267053374 4.5 11.6438561898 85.0297538832 1 15 16 
 i 11 29.5067511747 4.5 11.7958592832 85.1151502123 1 15 16 
 i 11 29.6754725401 4.5 11.6438561898 85.2005465413 1 15 16 
 i 11 29.8335576788 4.5 8.79586 85.2859428703 1 15 16 
 i 11 30.0040453331 4.5 11.7958592832 85.3713391993 1 15 16 
 i 11 30.1603396437 4.5 8.96578428466 85.4567355232 1 15 16 
 i 11 30.1757056984 4.5 12.3808217839 85.4567355284 1 15 16 
 i 11 30.3303818768 4.5 8.79585928322 85.5421318523 1 15 16 
 i 11 30.3425356429 4.5 12.2288186905 85.5421318574 1 15 16 
 i 11 30.507813648 4.5 8.96578428466 85.6275281813 1 15 16 
 i 11 30.5044811577 4.5 12.3808217839 85.6275281864 1 15 16 
 i 11 30.6632511599 4.5 9.55074678538 85.7129245103 1 15 16 
 i 11 30.6585196601 4.5 12.2288186905 85.7129245155 1 15 16 
 i 11 30.8234528803 4.5 9.38082178394 85.7983208394 1 15 16 
 i 11 30.8312326977 4.5 9.55074678538 85.7983208445 1 15 16 
 i 11 30.9932482429 4.5 9.38082178394 85.8837171684 1 15 16 
 i 11 31.1752072919 4.5 9.55074678538 85.9691134974 1 15 16 
 i 11 31.340877677 4.5 9.79585928322 86.0545098264 1 15 16 
 i 11 31.5049123426 4.5 9.96578428466 86.1399061555 1 15 16 
 i 11 31.6662324066 4.5 9.79585928322 86.2253024845 1 15 16 
 i 11 31.8441498779 4.5 9.96578428466 86.3106988135 1 15 16 
 i 11 32.001344758 4.5 10.5507467854 86.3960951425 1 15 16 
 i 11 32.174248423 4.5 10.3808217839 86.4814914716 1 15 16 
 i 11 32.332166276 4.5 10.5507467854 86.5668878006 1 15 16 
 i 11 32.5067156297 4.5 10.3808217839 86.6522841296 1 15 16 
 i 11 32.6633035908 4.5 10.5507467854 86.7376804587 1 15 16 
 i 11 32.8437607974 4.5 10.7958592832 86.8230767877 1 15 16 
 i 11 32.9986269864 4.5 10.9657842847 86.9084731167 1 15 16 
 i 11 33.1608437629 4.5 10.7958592832 86.9938694457 1 15 16 
 i 11 33.3223720414 4.5 10.9657842847 87.0792657748 1 15 16 
 i 11 33.5103335308 4.5 11.5507467854 87.1646621038 1 15 16 
 i 11 33.6699421938 4.5 11.3808217839 87.2500584328 1 15 16 
 i 11 33.8380265068 4.5 11.5507467854 87.3354547619 1 15 16 
 i 11 33.9896486363 4.5 11.3808217839 87.4208510909 1 15 16 
 i 11 34.1673059297 4.5 11.5507467854 87.5062474199 1 15 16 
 i 11 34.3365626545 4.5 11.7958592832 87.5916437489 1 15 16 
 i 11 34.4949838436 4.5 11.9657842847 87.677040078 1 15 16 
 i 11 34.6755310427 4.5 11.7958592832 87.762436407 1 15 16 
 i 11 34.8266938779 4.5 11.9657842847 87.847832736 1 15 16 
 i 11 35.0024998667 4.5 12.5507467854 87.933229065 1 15 16 
 i 11 35.1667169044 4.5 12.3808217839 88.0186253941 1 15 16 
 i 11 35.3316632119 4.5 12.5507467854 88.1040217231 1 15 16 
 i 11 35.4984090266 4.5 12.3808217839 88.1894180521 1 15 16 
 i 11 35.6739234191 4.5 8.22882 88.2748143812 1 15 16 
 i 11 35.8305859493 4.5 8.38082178394 88.3602107102 1 15 16 
 i 11 37.1559530231 4.5 8.2288186905 89.0433813352 1 15 16 
 i 11 37.324050476 4.5 8.38082178394 89.1287776643 1 15 16 
 i 11 37.491386436 4.5 8.96578428466 89.2141739933 1 15 16 
 i 11 37.6650764609 4.5 8.79585928322 89.2995703223 1 15 16 
 i 11 37.8269311623 4.5 8.96578428466 89.3849666513 1 15 16 
 i 11 37.9992512972 4.5 8.79585928322 89.4703629804 1 15 16 
 i 11 38.1744323312 4.5 8.96578428466 89.5557593094 1 15 16 
 i 11 38.3364338149 4.5 9.2288186905 89.6411556384 1 15 16 
 i 11 38.5059646518 4.5 9.38082178394 89.7265519675 1 15 16 
 i 11 38.6614878625 4.5 9.2288186905 89.8119482965 1 15 16 
 i 11 38.8397678672 4.5 9.38082178394 89.8973446255 1 15 16 
 i 11 39.0012820273 4.5 9.96578428466 89.9827409545 1 15 16 
 i 11 39.1569175521 4.5 9.79585928322 90.0681372836 1 15 16 
 i 11 39.3419769674 4.5 9.96578428466 90.1535336126 1 15 16 
 i 11 39.5081435838 4.5 9.79585928322 90.2389299416 1 15 16 
 i 11 39.6610332151 4.5 9.96578428466 90.3243262706 1 15 16 
 i 11 39.8236603945 4.5 10.2288186905 90.4097225997 1 15 16 
 i 11 39.9933925965 4.5 10.3808217839 90.4951189287 1 15 16 
 i 11 40.1764259399 4.5 10.2288186905 90.5805152577 1 15 16 
 i 11 40.3370780275 4.5 10.3808217839 90.6659115868 1 15 16 
 i 11 40.4982580762 4.5 10.9657842847 90.7513079158 1 15 16 
 i 11 40.6595971641 4.5 10.7958592832 90.8367042448 1 15 16 
 i 11 40.8372042544 4.5 10.9657842847 90.9221005738 1 15 16 
 i 11 40.9983102797 4.5 10.7958592832 91.0074969029 1 15 16 
 i 11 41.1723092727 4.5 10.9657842847 91.0928932319 1 15 16 
 i 11 41.3241289436 4.5 11.2288186905 91.1782895609 1 15 16 
 i 11 41.5098807832 4.5 11.3808217839 91.2636858899 1 15 16 
 i 11 41.656123588 4.5 11.2288186905 91.349082219 1 15 16 
 i 11 41.8349631277 4.5 8.05889 91.434478548 1 15 16 
 i 11 42.0108923284 4.5 11.3808217839 91.519874877 1 15 16 
 i 11 42.1768579029 4.5 8.2288186905 91.6052712009 1 15 16 
 i 11 42.1577229409 4.5 11.9657842847 91.6052712061 1 15 16 
 i 11 42.3277086429 4.5 8.05889368905 91.69066753 1 15 16 
 i 11 42.3354166957 4.5 11.7958592832 91.6906675351 1 15 16 
 i 11 42.496529013 4.5 8.2288186905 91.776063859 1 15 16 
 i 11 42.4951238738 4.5 11.9657842847 91.7760638641 1 15 16 
 i 11 42.6603487288 4.5 8.79585928322 91.861460188 1 15 16 
 i 11 42.6591729821 4.5 11.7958592832 91.8614601931 1 15 16 
 i 11 42.8299224273 4.5 8.64385618977 91.946856517 1 15 16 
 i 11 42.841588986 4.5 8.79585928322 91.9468565222 1 15 16 
 i 11 43.0077864808 4.5 8.64385618977 92.0322528461 1 15 16 
 i 11 43.1590909194 4.5 8.79585928322 92.1176491751 1 15 16 
 i 11 43.3295695891 4.5 9.05889368905 92.2030455041 1 15 16 
 i 11 43.4910086675 4.5 9.2288186905 92.2884418332 1 15 16 
 i 11 43.6737024924 4.5 9.05889368905 92.3738381622 1 15 16 
 i 11 43.8410185574 4.5 9.2288186905 92.4592344912 1 15 16 
 i 11 44.0066767011 4.5 9.79585928322 92.5446308202 1 15 16 
 i 11 44.1665631527 4.5 9.64385618977 92.6300271493 1 15 16 
 i 11 44.3310320036 4.5 9.79585928322 92.7154234783 1 15 16 
 i 11 44.5045585136 4.5 9.64385618977 92.8008198073 1 15 16 
 i 11 44.6715218937 4.5 9.79585928322 92.8862161363 1 15 16 
 i 11 44.8246954767 4.5 10.0588936891 92.9716124654 1 15 16 
 i 11 45.000376409 4.5 10.2288186905 93.0570087944 1 15 16 
 i 11 45.1597605833 4.5 10.0588936891 93.1424051234 1 15 16 
 i 11 45.344214954 4.5 10.2288186905 93.2278014525 1 15 16 
 i 11 45.510397998 4.5 10.7958592832 93.3131977815 1 15 16 
 i 11 45.6682817051 4.5 10.6438561898 93.3985941105 1 15 16 
 i 11 45.8359691755 4.5 10.7958592832 93.4839904395 1 15 16 
 i 11 45.9934034789 4.5 10.6438561898 93.5693867686 1 15 16 
 i 11 46.1767065109 4.5 10.7958592832 93.6547830976 1 15 16 
 i 11 46.3277566768 4.5 11.0588936891 93.7401794266 1 15 16 
 i 11 46.5109817593 4.5 11.2288186905 93.8255757556 1 15 16 
 i 11 46.6586798606 4.5 11.0588936891 93.9109720847 1 15 16 
 i 11 46.8286518365 4.5 11.2288186905 93.9963684137 1 15 16 
 i 11 46.9954733971 4.5 11.7958592832 94.0817647427 1 15 16 
 i 11 47.1703793769 4.5 11.6438561898 94.1671610718 1 15 16 
 i 11 47.3396955986 4.5 11.7958592832 94.2525574008 1 15 16 
 i 11 47.5082548423 4.5 11.6438561898 94.3379537298 1 15 16 
 i 11 47.6686601888 4.5 8.79586 94.4233500588 1 15 16 
 i 11 47.8373188849 4.5 8.96578428466 94.5087463879 1 15 16 
 i 11 49.1618752999 4.5 8.79585928322 95.1919170129 1 15 16 
 i 11 49.3239036975 4.5 8.96578428466 95.2773133419 1 15 16 
 i 11 49.4964712981 4.5 9.55074678538 95.362709671 1 15 16 
 i 11 49.6606351845 4.5 9.38082178394 95.448106 1 15 16 
 i 11 49.8227604988 4.5 9.55074678538 95.533502329 1 15 16 
 i 11 49.9893077712 4.5 9.38082178394 95.6188986581 1 15 16 
 i 11 50.1655134474 4.5 9.55074678538 95.7042949871 1 15 16 
 i 11 50.3377587586 4.5 9.79585928322 95.7896913161 1 15 16 
 i 11 50.4954216758 4.5 9.96578428466 95.8750876451 1 15 16 
 i 11 50.6737234667 4.5 9.79585928322 95.9604839742 1 15 16 
 i 11 50.8394924888 4.5 9.96578428466 96.0458803032 1 15 16 
 i 11 50.9901384725 4.5 10.5507467854 96.1312766322 1 15 16 
 i 11 51.160200691 4.5 10.3808217839 96.2166729612 1 15 16 
 i 11 51.3367498585 4.5 10.5507467854 96.3020692903 1 15 16 
 i 11 51.500003 4.5 10.3808217839 96.3874656193 1 15 16 
 i 11 51.6624967394 4.5 10.5507467854 96.4728619483 1 15 16 
 i 11 51.8241116452 4.5 10.7958592832 96.5582582774 1 15 16 
 i 11 51.9949829967 4.5 10.9657842847 96.6436546064 1 15 16 
 i 11 52.1637462048 4.5 10.7958592832 96.7290509354 1 15 16 
 i 11 52.3368105504 4.5 10.9657842847 96.8144472644 1 15 16 
 i 11 52.4999533669 4.5 11.5507467854 96.8998435935 1 15 16 
 i 11 52.6692597317 4.5 11.3808217839 96.9852399225 1 15 16 
 i 11 52.8397670159 4.5 11.5507467854 97.0706362515 1 15 16 
 i 11 52.9916808369 4.5 11.3808217839 97.1560325806 1 15 16 
 i 11 53.168049954 4.5 11.5507467854 97.2414289096 1 15 16 
 i 11 53.3285598747 4.5 11.7958592832 97.3268252386 1 15 16 
 i 11 53.5047857073 4.5 11.9657842847 97.4122215676 1 15 16 
 i 11 53.6719648292 4.5 11.7958592832 97.4976178967 1 15 16 
 i 11 53.8378256582 4.5 8.22882 97.5830142257 1 15 16 
 i 11 53.9893592524 4.5 11.9657842847 97.6684105547 1 15 16 
 i 11 54.1596511514 4.5 8.38082178394 97.7538068786 1 15 16 
 i 11 54.1606357729 4.5 12.5507467854 97.7538068837 1 15 16 
 i 11 54.3389604079 4.5 8.2288186905 97.8392032076 1 15 16 
 i 11 54.327469163 4.5 12.3808217839 97.8392032128 1 15 16 
 i 11 54.4996241577 4.5 8.38082178394 97.9245995367 1 15 16 
 i 11 54.4969238637 4.5 12.5507467854 97.9245995418 1 15 16 
 i 11 54.6754828576 4.5 8.96578428466 98.0099958657 1 15 16 
 i 11 54.6737124265 4.5 12.3808217839 98.0099958708 1 15 16 
 i 11 54.8266399408 4.5 8.79585928322 98.0953921947 1 15 16 
 i 11 54.8381977302 4.5 8.96578428466 98.0953921999 1 15 16 
 i 11 55.0061558878 4.5 8.79585928322 98.1807885238 1 15 16 
 i 11 55.1603112475 4.5 8.96578428466 98.2661848528 1 15 16 
 i 11 55.3385129474 4.5 9.2288186905 98.3515811818 1 15 16 
 i 11 55.4929735814 4.5 9.38082178394 98.4369775108 1 15 16 
 i 11 55.6590620661 4.5 9.2288186905 98.5223738399 1 15 16 
 i 11 55.8359557516 4.5 9.38082178394 98.6077701689 1 15 16 
 i 11 56.0033148178 4.5 9.96578428466 98.6931664979 1 15 16 
 i 11 56.1726077998 4.5 9.79585928322 98.778562827 1 15 16 
 i 11 56.3341892508 4.5 9.96578428466 98.863959156 1 15 16 
 i 11 56.5087158092 4.5 9.79585928322 98.949355485 1 15 16 
 i 11 56.6657741384 4.5 9.96578428466 99.034751814 1 15 16 
 i 11 56.8350376259 4.5 10.2288186905 99.1201481431 1 15 16 
 i 11 56.9959106768 4.5 10.3808217839 99.2055444721 1 15 16 
 i 11 57.1719571596 4.5 10.2288186905 99.2909408011 1 15 16 
 i 11 57.3286979639 4.5 10.3808217839 99.3763371301 1 15 16 
 i 11 57.5003702807 4.5 10.9657842847 99.4617334592 1 15 16 
 i 11 57.6646894795 4.5 10.7958592832 99.5471297882 1 15 16 
 i 11 57.8354638581 4.5 10.9657842847 99.6325261172 1 15 16 
 i 11 57.9932998756 4.5 10.7958592832 99.7179224463 1 15 16 
 i 11 58.1649556945 4.5 10.9657842847 99.8033187753 1 15 16 
 i 11 58.3438962845 4.5 11.2288186905 99.8887151043 1 15 16 
 i 11 58.4903436266 4.5 11.3808217839 99.9741114333 1 15 16 
 i 11 58.6694879691 4.5 11.2288186905 100.059507762 1 15 16 
 i 11 58.8310609502 4.5 11.3808217839 100.144904091 1 15 16 
 i 11 58.9977691466 4.5 11.9657842847 100.23030042 1 15 16 
 i 11 59.1567161636 4.5 11.7958592832 100.315696749 1 15 16 
 i 11 59.3287762722 4.5 11.9657842847 100.401093078 1 15 16 
 i 11 59.501045093 4.5 11.7958592832 100.486489408 1 15 16 
 i 11 59.6680016023 4.5 8.05889 100.571885737 1 15 16 
 i 11 59.8405545027 4.5 8.2288186905 100.657282066 1 15 16 
 i 11 61.1741574841 4.5 8.05889368905 101.340452691 1 15 16 
 i 11 61.3324322458 4.5 8.2288186905 101.42584902 1 15 16 
 i 11 61.5082524351 4.5 8.79585928322 101.511245349 1 15 16 
 i 11 61.6606101422 4.5 8.64385618977 101.596641678 1 15 16 
 i 11 61.8291284269 4.5 8.79585928322 101.682038007 1 15 16 
 i 11 62.0044047513 4.5 8.64385618977 101.767434336 1 15 16 
 i 11 62.1609165602 4.5 8.79585928322 101.852830665 1 15 16 
 i 11 62.3242169984 4.5 9.05889368905 101.938226994 1 15 16 
 i 11 62.5094574408 4.5 9.2288186905 102.023623323 1 15 16 
 i 11 62.6710799185 4.5 9.05889368905 102.109019652 1 15 16 
 i 11 62.8292463853 4.5 9.2288186905 102.194415981 1 15 16 
 i 11 63.0046544701 4.5 9.79585928322 102.27981231 1 15 16 
 i 11 63.1657345706 4.5 9.64385618977 102.365208639 1 15 16 
 i 11 63.332327251 4.5 9.79585928322 102.450604968 1 15 16 
 i 11 63.5015534675 4.5 9.64385618977 102.536001297 1 15 16 
 i 11 63.6645636864 4.5 9.79585928322 102.621397626 1 15 16 
 i 11 63.8237132077 4.5 10.0588936891 102.706793955 1 15 16 
 i 11 63.9901229534 4.5 10.2288186905 102.792190284 1 15 16 
 i 11 64.1727409926 4.5 10.0588936891 102.877586613 1 15 16 
 i 11 64.3367459581 4.5 10.2288186905 102.962982942 1 15 16 
 i 11 64.5007883262 4.5 10.7958592832 103.048379271 1 15 16 
 i 11 64.6724661071 4.5 10.6438561898 103.1337756 1 15 16 
 i 11 64.8324284012 4.5 10.7958592832 103.219171929 1 15 16 
 i 11 64.9918088841 4.5 10.6438561898 103.304568258 1 15 16 
 i 11 65.1719051031 4.5 10.7958592832 103.389964587 1 15 16 
 i 11 65.3254237917 4.5 11.0588936891 103.475360916 1 15 16 
 i 11 65.4953518876 4.5 11.2288186905 103.560757245 1 15 16 
 i 11 65.6622153246 4.5 11.0588936891 103.646153574 1 15 16 
 i 11 65.8356344903 4.5 8.64386 103.731549903 1 15 16 
 i 11 65.9966931553 4.5 11.2288186905 103.816946232 1 15 16 
 i 11 66.1608050882 4.5 8.79585928322 103.902342556 1 15 16 
 i 11 66.1728140232 4.5 11.7958592832 103.902342561 1 15 16 
 i 11 66.3279904904 4.5 8.64385618977 103.987738885 1 15 16 
 i 11 66.3234998919 4.5 11.6438561898 103.98773889 1 15 16 
 i 11 66.5003384476 4.5 8.79585928322 104.073135214 1 15 16 
 i 11 66.4967110917 4.5 11.7958592832 104.073135219 1 15 16 
 i 11 66.6566720402 4.5 9.38082178394 104.158531543 1 15 16 
 i 11 66.6649958353 4.5 11.6438561898 104.158531549 1 15 16 
 i 11 66.8321082644 4.5 9.2288186905 104.243927872 1 15 16 
 i 11 66.8260524565 4.5 9.38082178394 104.243927878 1 15 16 
 i 11 66.9930486904 4.5 9.2288186905 104.329324201 1 15 16 
 i 11 67.1741676261 4.5 9.38082178394 104.41472053 1 15 16 
 i 11 67.3352722129 4.5 9.64385618977 104.50011686 1 15 16 
 i 11 67.4923230633 4.5 9.79585928322 104.585513189 1 15 16 
 i 11 67.6569783434 4.5 9.64385618977 104.670909518 1 15 16 
 i 11 67.8257624078 4.5 9.79585928322 104.756305847 1 15 16 
 i 11 68.0082643043 4.5 10.3808217839 104.841702176 1 15 16 
 i 11 68.1676859418 4.5 10.2288186905 104.927098505 1 15 16 
 i 11 68.3224932661 4.5 10.3808217839 105.012494834 1 15 16 
 i 11 68.4949761225 4.5 10.2288186905 105.097891163 1 15 16 
 i 11 68.6680187388 4.5 10.3808217839 105.183287492 1 15 16 
 i 11 68.8360731637 4.5 10.6438561898 105.268683821 1 15 16 
 i 11 69.0079012933 4.5 10.7958592832 105.35408015 1 15 16 
 i 11 69.1730079807 4.5 10.6438561898 105.439476479 1 15 16 
 i 11 69.333040539 4.5 10.7958592832 105.524872808 1 15 16 
 i 11 69.5001361506 4.5 11.3808217839 105.610269137 1 15 16 
 i 11 69.6752345323 4.5 11.2288186905 105.695665466 1 15 16 
 i 11 69.8226479902 4.5 11.3808217839 105.781061795 1 15 16 
 i 11 70.0010528416 4.5 11.2288186905 105.866458124 1 15 16 
 i 11 70.1640435812 4.5 11.3808217839 105.951854453 1 15 16 
 i 11 70.3333501094 4.5 11.6438561898 106.037250782 1 15 16 
 i 11 70.5017985302 4.5 11.7958592832 106.122647111 1 15 16 
 i 11 70.6668133391 4.5 11.6438561898 106.20804344 1 15 16 
 i 11 70.8400280615 4.5 11.7958592832 106.293439769 1 15 16 
 i 11 70.9960208031 4.5 12.3808217839 106.378836098 1 15 16 
 i 11 71.163100207 4.5 12.2288186905 106.464232427 1 15 16 
 i 11 71.3291890979 4.5 12.3808217839 106.549628756 1 15 16 
 i 11 71.5105828341 4.5 12.2288186905 106.635025085 1 15 16 
 i 11 71.6571990368 4.5 8.22882 106.720421414 1 15 16 
 i 11 71.8240383838 4.5 8.38082178394 106.805817743 1 15 16 
 i 11 73.1710693783 4.5 8.2288186905 107.488988368 1 15 16 
 i 11 73.3244691256 4.5 8.38082178394 107.574384697 1 15 16 
 i 11 73.4927174092 4.5 8.96578428466 107.659781026 1 15 16 
 i 11 73.6697391124 4.5 8.79585928322 107.745177355 1 15 16 
 i 11 73.8307658206 4.5 8.96578428466 107.830573684 1 15 16 
 i 11 73.9903464573 4.5 8.79585928322 107.915970013 1 15 16 
 i 11 74.1742003158 4.5 8.96578428466 108.001366342 1 15 16 
 i 11 74.3357888569 4.5 9.2288186905 108.086762671 1 15 16 
 i 11 74.4976244113 4.5 9.38082178394 108.172159001 1 15 16 
 i 11 74.6655119773 4.5 9.2288186905 108.25755533 1 15 16 
 i 11 74.8276242972 4.5 9.38082178394 108.342951659 1 15 16 
 i 11 75.0012036156 4.5 9.96578428466 108.428347988 1 15 16 
 i 11 75.1770433225 4.5 9.79585928322 108.513744317 1 15 16 
 i 11 75.3285933784 4.5 9.96578428466 108.599140646 1 15 16 
 i 11 75.5064525635 4.5 9.79585928322 108.684536975 1 15 16 
 i 11 75.6764331996 4.5 9.96578428466 108.769933304 1 15 16 
 i 11 75.8299720301 4.5 10.2288186905 108.855329633 1 15 16 
 i 11 76.0003699413 4.5 10.3808217839 108.940725962 1 15 16 
 i 11 76.1563510935 4.5 10.2288186905 109.026122291 1 15 16 
 i 11 76.3228866398 4.5 10.3808217839 109.11151862 1 15 16 
 i 11 76.5051443807 4.5 10.9657842847 109.196914949 1 15 16 
 i 11 76.6593352982 4.5 10.7958592832 109.282311278 1 15 16 
 i 11 76.8396181071 4.5 10.9657842847 109.367707607 1 15 16 
 i 11 77.002578433 4.5 10.7958592832 109.453103936 1 15 16 
 i 11 77.1570893268 4.5 10.9657842847 109.538500265 1 15 16 
 i 11 77.3243205131 4.5 11.2288186905 109.623896594 1 15 16 
 i 11 77.5096192571 4.5 11.3808217839 109.709292923 1 15 16 
 i 11 77.6685231014 4.5 11.2288186905 109.794689252 1 15 16 
 i 11 77.8337610388 4.5 8.05889 109.880085581 1 15 16 
 i 11 78.0096636603 4.5 11.3808217839 109.96548191 1 15 16 
 i 11 78.164464086 4.5 8.2288186905 110.050878234 1 15 16 
 i 11 78.1766998606 4.5 11.9657842847 110.050878239 1 15 16 
 i 11 78.3439101851 4.5 8.05889368905 110.136274563 1 15 16 
 i 11 78.3431429159 4.5 11.7958592832 110.136274568 1 15 16 
 i 11 78.4979818017 4.5 8.2288186905 110.221670892 1 15 16 
 i 11 78.4942600904 4.5 11.9657842847 110.221670897 1 15 16 
 i 11 78.6600696559 4.5 8.79585928322 110.307067221 1 15 16 
 i 11 78.6683131411 4.5 11.7958592832 110.307067226 1 15 16 
 i 11 78.8259251455 4.5 8.64385618977 110.39246355 1 15 16 
 i 11 78.8339690795 4.5 8.79585928322 110.392463555 1 15 16 
 i 11 79.0096539779 4.5 8.64385618977 110.477859879 1 15 16 
 i 11 79.1595472933 4.5 8.79585928322 110.563256208 1 15 16 
 i 11 79.3313281397 4.5 9.05889368905 110.648652537 1 15 16 
 i 11 79.5004284458 4.5 9.2288186905 110.734048866 1 15 16 
 i 11 79.6664947637 4.5 9.05889368905 110.819445195 1 15 16 
 i 11 79.829514156 4.5 9.2288186905 110.904841524 1 15 16 
 i 11 80.003466042 4.5 9.79585928322 110.990237853 1 15 16 
 i 11 80.1737016211 4.5 9.64385618977 111.075634182 1 15 16 
 i 11 80.3348672877 4.5 9.79585928322 111.161030511 1 15 16 
 i 11 80.4920947168 4.5 9.64385618977 111.24642684 1 15 16 
 i 11 80.6576236378 4.5 9.79585928322 111.331823169 1 15 16 
 i 11 80.8367960403 4.5 10.0588936891 111.417219498 1 15 16 
 i 11 80.9958156396 4.5 10.2288186905 111.502615827 1 15 16 
 i 11 81.1563228875 4.5 10.0588936891 111.588012156 1 15 16 
 i 11 81.3365838024 4.5 10.2288186905 111.673408486 1 15 16 
 i 11 81.4976369443 4.5 10.7958592832 111.758804815 1 15 16 
 i 11 81.6711592883 4.5 10.6438561898 111.844201144 1 15 16 
 i 11 81.8384486214 4.5 10.7958592832 111.929597473 1 15 16 
 i 11 82.0014197794 4.5 10.6438561898 112.014993802 1 15 16 
 i 11 82.1621424913 4.5 10.7958592832 112.100390131 1 15 16 
 i 11 82.3245125925 4.5 11.0588936891 112.18578646 1 15 16 
 i 11 82.4890408144 4.5 11.2288186905 112.271182789 1 15 16 
 i 11 82.6736667629 4.5 11.0588936891 112.356579118 1 15 16 
 i 11 82.8271756421 4.5 11.2288186905 112.441975447 1 15 16 
 i 11 83.0023282298 4.5 11.7958592832 112.527371776 1 15 16 
 i 11 83.1776282154 4.5 11.6438561898 112.612768105 1 15 16 
 i 11 83.3432130805 4.5 11.7958592832 112.698164434 1 15 16 
 i 11 83.4902289742 4.5 11.6438561898 112.783560763 1 15 16 
 i 11 83.6680537214 4.5 8.64386 112.868957092 1 15 16 
 i 11 83.8317836819 4.5 8.79585928322 112.954353421 1 15 16 
 i 11 85.1757127905 4.5 8.64385618977 113.637524046 1 15 16 
 i 11 85.3402896856 4.5 8.79585928322 113.722920375 1 15 16 
 i 11 85.5100979995 4.5 9.38082178394 113.808316704 1 15 16 
 i 11 85.6773050328 4.5 9.2288186905 113.893713033 1 15 16 
 i 11 85.8263346937 4.5 9.38082178394 113.979109362 1 15 16 
 i 11 85.995977007 4.5 9.2288186905 114.064505691 1 15 16 
 i 11 86.1617099956 4.5 9.38082178394 114.14990202 1 15 16 
 i 11 86.3303662321 4.5 9.64385618977 114.235298349 1 15 16 
 i 11 86.5051165855 4.5 9.79585928322 114.320694678 1 15 16 
 i 11 86.6749887331 4.5 9.64385618977 114.406091007 1 15 16 
 i 11 86.8344680914 4.5 9.79585928322 114.491487336 1 15 16 
 i 11 86.9937912015 4.5 10.3808217839 114.576883665 1 15 16 
 i 11 87.1724191394 4.5 10.2288186905 114.662279994 1 15 16 
 i 11 87.3372261465 4.5 10.3808217839 114.747676323 1 15 16 
 i 11 87.4999636631 4.5 10.2288186905 114.833072652 1 15 16 
 i 11 87.6652475792 4.5 10.3808217839 114.918468981 1 15 16 
 i 11 87.8290806525 4.5 10.6438561898 115.00386531 1 15 16 
 i 11 88.0052469066 4.5 10.7958592832 115.089261639 1 15 16 
 i 11 88.1637766527 4.5 10.6438561898 115.174657968 1 15 16 
 i 11 88.3223936518 4.5 10.7958592832 115.260054298 1 15 16 
 i 11 88.498191149 4.5 11.3808217839 115.345450627 1 15 16 
 i 11 88.6562465124 4.5 11.2288186905 115.430846956 1 15 16 
 i 11 88.8352902942 4.5 11.3808217839 115.516243285 1 15 16 
 i 11 89.0076673232 4.5 11.2288186905 115.601639614 1 15 16 
 i 11 89.1685895211 4.5 11.3808217839 115.687035943 1 15 16 
 i 11 89.3258372357 4.5 11.6438561898 115.772432272 1 15 16 
 i 11 89.5029529288 4.5 11.7958592832 115.857828601 1 15 16 
 i 11 89.6762921872 4.5 11.6438561898 115.94322493 1 15 16 
 i 11 89.8342388435 4.5 8.79586 116.028621259 1 15 16 
 i 11 89.9968355729 4.5 11.7958592832 116.114017588 1 15 16 
 i 11 90.1649324299 4.5 8.96578428466 116.199413912 1 15 16 
 i 11 90.1570287425 4.5 12.3808217839 116.199413917 1 15 16 
 i 11 90.332391087 4.5 8.79585928322 116.284810241 1 15 16 
 i 11 90.3304253291 4.5 12.2288186905 116.284810246 1 15 16 
 i 11 90.4976721019 4.5 8.96578428466 116.37020657 1 15 16 
 i 11 90.5079275417 4.5 12.3808217839 116.370206575 1 15 16 
 i 11 90.6593388127 4.5 9.55074678538 116.455602899 1 15 16 
 i 11 90.6596216288 4.5 12.2288186905 116.455602904 1 15 16 
 i 11 90.8357815958 4.5 9.38082178394 116.540999228 1 15 16 
 i 11 90.8406767032 4.5 9.55074678538 116.540999233 1 15 16 
 i 11 91.0096987936 4.5 9.38082178394 116.626395557 1 15 16 
 i 11 91.1572750655 4.5 9.55074678538 116.711791886 1 15 16 
 i 11 91.3328977973 4.5 9.79585928322 116.797188215 1 15 16 
 i 11 91.5098522968 4.5 9.96578428466 116.882584544 1 15 16 
 i 11 91.6672738444 4.5 9.79585928322 116.967980873 1 15 16 
 i 11 91.8279336583 4.5 9.96578428466 117.053377202 1 15 16 
 i 11 92.0062949717 4.5 10.5507467854 117.138773531 1 15 16 
 i 11 92.1757810827 4.5 10.3808217839 117.22416986 1 15 16 
 i 11 92.3382260903 4.5 10.5507467854 117.309566189 1 15 16 
 i 11 92.4921543764 4.5 10.3808217839 117.394962518 1 15 16 
 i 11 92.6634909051 4.5 10.5507467854 117.480358847 1 15 16 
 i 11 92.8349891794 4.5 10.7958592832 117.565755176 1 15 16 
 i 11 92.9899859869 4.5 10.9657842847 117.651151505 1 15 16 
 i 11 93.1729287563 4.5 10.7958592832 117.736547834 1 15 16 
 i 11 93.3281611839 4.5 10.9657842847 117.821944163 1 15 16 
 i 11 93.4946711734 4.5 11.5507467854 117.907340492 1 15 16 
 i 11 93.6604791186 4.5 11.3808217839 117.992736821 1 15 16 
 i 11 93.8354266876 4.5 11.5507467854 118.07813315 1 15 16 
 i 11 94.0060740315 4.5 11.3808217839 118.163529479 1 15 16 
 i 11 94.1644542732 4.5 11.5507467854 118.248925808 1 15 16 
 i 11 94.3251917066 4.5 11.7958592832 118.334322137 1 15 16 
 i 11 94.5078783052 4.5 11.9657842847 118.419718466 1 15 16 
 i 11 94.6623980894 4.5 11.7958592832 118.505114795 1 15 16 
 i 11 94.8416600837 4.5 11.9657842847 118.590511124 1 15 16 
 i 11 94.9937228457 4.5 12.5507467854 118.675907453 1 15 16 
 i 11 95.1677213102 4.5 12.3808217839 118.761303783 1 15 16 
 i 11 95.3360217166 4.5 12.5507467854 118.846700112 1 15 16 
 i 11 95.4956197383 4.5 12.3808217839 118.932096441 1 15 16 
 i 11 95.6776321635 4.5 8.05889 119.01749277 1 15 16 
 i 11 95.8288958548 4.5 8.2288186905 119.102889099 1 15 16 
 i 11 97.1772825447 4.5 8.05889368905 119.786059724 1 15 16 
 i 11 97.3377135852 4.5 8.2288186905 119.871456053 1 15 16 
 i 11 97.4957935698 4.5 8.79585928322 119.956852382 1 15 16 
 i 11 97.6707155796 4.5 8.64385618977 120.042248711 1 15 16 
 i 11 97.8396386882 4.5 8.79585928322 120.12764504 1 15 16 
 i 11 97.9923606708 4.5 8.64385618977 120.213041369 1 15 16 
 i 11 98.165424931 4.5 8.79585928322 120.298437698 1 15 16 
 i 11 98.3300183331 4.5 9.05889368905 120.383834027 1 15 16 
 i 11 98.5038107437 4.5 9.2288186905 120.469230356 1 15 16 
 i 11 98.6694499199 4.5 9.05889368905 120.554626685 1 15 16 
 i 11 98.8227249473 4.5 9.2288186905 120.640023014 1 15 16 
 i 11 99.0036545974 4.5 9.79585928322 120.725419343 1 15 16 
 i 11 99.1764165267 4.5 9.64385618977 120.810815672 1 15 16 
 i 11 99.3377762037 4.5 9.79585928322 120.896212001 1 15 16 
 i 11 99.4956766796 4.5 9.64385618977 120.98160833 1 15 16 
 i 11 99.6572659122 4.5 9.79585928322 121.067004659 1 15 16 
 i 11 99.8442358919 4.5 10.0588936891 121.152400988 1 15 16 
 i 11 100.001326962 4.5 10.2288186905 121.237797317 1 15 16 
 i 11 100.160454276 4.5 10.0588936891 121.323193646 1 15 16 
 i 11 100.333275307 4.5 10.2288186905 121.408589975 1 15 16 
 i 11 100.510513653 4.5 10.7958592832 121.493986304 1 15 16 
 i 11 100.66409542 4.5 10.6438561898 121.579382633 1 15 16 
 i 11 100.831028063 4.5 10.7958592832 121.664778962 1 15 16 
 i 11 101.008015779 4.5 10.6438561898 121.750175291 1 15 16 
 i 11 101.166002631 4.5 10.7958592832 121.83557162 1 15 16 
 i 11 101.326872355 4.5 11.0588936891 121.920967949 1 15 16 
 i 11 101.493734201 4.5 11.2288186905 122.006364278 1 15 16 
 i 11 101.659389875 4.5 11.0588936891 122.091760607 1 15 16 
 i 11 101.838370968 4.5 8.64386 122.177156936 1 15 16 
 i 11 102.010651105 4.5 11.2288186905 122.262553265 1 15 16 
 i 11 102.175613517 4.5 8.79585928322 122.347949589 1 15 16 
 i 11 102.158461395 4.5 11.7958592832 122.347949594 1 15 16 
 i 11 102.326933203 4.5 8.64385618977 122.433345918 1 15 16 
 i 11 102.342965385 4.5 11.6438561898 122.433345924 1 15 16 
 i 11 102.505627987 4.5 8.79585928322 122.518742247 1 15 16 
 i 11 102.491383156 4.5 11.7958592832 122.518742253 1 15 16 
 i 11 102.670834204 4.5 9.38082178394 122.604138576 1 15 16 
 i 11 102.677456288 4.5 11.6438561898 122.604138582 1 15 16 
 i 11 102.828299969 4.5 9.2288186905 122.689534905 1 15 16 
 i 11 102.82863569 4.5 9.38082178394 122.689534911 1 15 16 
 i 11 102.997193311 4.5 9.2288186905 122.774931235 1 15 16 
 i 11 103.168620118 4.5 9.38082178394 122.860327564 1 15 16 
 i 11 103.337381026 4.5 9.64385618977 122.945723893 1 15 16 
 i 11 103.499746389 4.5 9.79585928322 123.031120222 1 15 16 
 i 11 103.662358931 4.5 9.64385618977 123.116516551 1 15 16 
 i 11 103.83291855 4.5 9.79585928322 123.20191288 1 15 16 
 i 11 103.999865694 4.5 10.3808217839 123.287309209 1 15 16 
 i 11 104.16388527 4.5 10.2288186905 123.372705538 1 15 16 
 i 11 104.340821616 4.5 10.3808217839 123.458101867 1 15 16 
 i 11 104.491731175 4.5 10.2288186905 123.543498196 1 15 16 
 i 11 104.663211312 4.5 10.3808217839 123.628894525 1 15 16 
 i 11 104.838689259 4.5 10.6438561898 123.714290854 1 15 16 
 i 11 104.993942519 4.5 10.7958592832 123.799687183 1 15 16 
 i 11 105.167006467 4.5 10.6438561898 123.885083512 1 15 16 
 i 11 105.324273922 4.5 10.7958592832 123.970479841 1 15 16 
 i 11 105.498586247 4.5 11.3808217839 124.05587617 1 15 16 
 i 11 105.6689431 4.5 11.2288186905 124.141272499 1 15 16 
 i 11 105.838991238 4.5 11.3808217839 124.226668828 1 15 16 
 i 11 105.994390465 4.5 11.2288186905 124.312065157 1 15 16 
 i 11 106.156910489 4.5 11.3808217839 124.397461486 1 15 16 
 i 11 106.329512474 4.5 11.6438561898 124.482857815 1 15 16 
 i 11 106.510728482 4.5 11.7958592832 124.568254144 1 15 16 
 i 11 106.666263055 4.5 11.6438561898 124.653650473 1 15 16 
 i 11 106.825024957 4.5 11.7958592832 124.739046802 1 15 16 
 i 11 106.996661213 4.5 12.3808217839 124.824443131 1 15 16 
 i 11 107.159683001 4.5 12.2288186905 124.90983946 1 15 16 
 i 11 107.335845411 4.5 12.3808217839 124.995235789 1 15 16 
 i 11 107.492839673 4.5 12.2288186905 125.080632118 1 15 16 
 i 11 107.673051455 4.5 8.79586 125.166028447 1 15 16 
 i 11 107.836031822 4.5 8.96578428466 125.251424776 1 15 16 
 i 11 109.157150844 4.5 8.79585928322 125.934595401 1 15 16 
 i 11 109.339043525 4.5 8.96578428466 126.01999173 1 15 16 
 i 11 109.506802415 4.5 9.55074678538 126.105388059 1 15 16 
 i 11 109.666543068 4.5 9.38082178394 126.190784388 1 15 16 
 i 11 109.825514298 4.5 9.55074678538 126.276180717 1 15 16 
 i 11 110.008369986 4.5 9.38082178394 126.361577046 1 15 16 
 i 11 110.171451339 4.5 9.55074678538 126.446973376 1 15 16 
 i 11 110.332737948 4.5 9.79585928322 126.532369705 1 15 16 
 i 11 110.500729572 4.5 9.96578428466 126.617766034 1 15 16 
 i 11 110.65829585 4.5 9.79585928322 126.703162363 1 15 16 
 i 11 110.844320717 4.5 9.96578428466 126.788558692 1 15 16 
 i 11 110.997954572 4.5 10.5507467854 126.873955021 1 15 16 
 i 11 111.168235745 4.5 10.3808217839 126.95935135 1 15 16 
 i 11 111.34351382 4.5 10.5507467854 126.871905507 1 15 16 
 i 11 111.489914424 4.5 10.3808217839 126.743811013 1 15 16 
 i 11 111.663968249 4.5 10.5507467854 126.61571652 1 15 16 
 i 11 111.826562751 4.5 10.7958592832 126.487622027 1 15 16 
 i 11 111.991311898 4.5 10.9657842847 126.359527534 1 15 16 
 i 11 112.173663949 4.5 10.7958592832 126.23143304 1 15 16 
 i 11 112.339999894 4.5 10.9657842847 126.103338547 1 15 16 
 i 11 112.507231331 4.5 11.5507467854 125.975244054 1 15 16 
 i 11 112.665430885 4.5 11.3808217839 125.84714956 1 15 16 
 i 11 112.843323679 4.5 11.5507467854 125.719055067 1 15 16 
 i 11 113.005572318 4.5 11.3808217839 125.590960574 1 15 16 
 i 11 113.15711457 4.5 11.5507467854 125.462866081 1 15 16 
 i 11 113.340715024 4.5 11.7958592832 125.334771587 1 15 16 
 i 11 113.502764748 4.5 11.9657842847 125.206677094 1 15 16 
 i 11 113.67585645 4.5 11.7958592832 125.078582601 1 15 16 
 i 11 113.823359311 4.5 8.22882 124.950488107 1 15 16 
 i 11 113.995186227 4.5 11.9657842847 124.822393614 1 15 16 
 i 11 114.161795712 4.5 8.38082178394 124.694299121 1 15 16 
 i 11 114.161783319 4.5 12.5507467854 124.566204628 1 15 16 
 i 11 114.326300709 4.5 8.2288186905 124.438110134 1 15 16 
 i 11 114.329063207 4.5 12.3808217839 124.310015641 1 15 16 
 i 11 114.489187448 4.5 8.38082178394 124.181921148 1 15 16 
 i 11 114.496054184 4.5 12.5507467854 124.053826654 1 15 16 
 i 11 114.655708342 4.5 8.96578428466 123.797637668 1 15 16 
 i 11 114.658057696 4.5 12.3808217839 123.669543175 1 15 16 
 i 11 114.836118709 4.5 8.79585928322 123.541448681 1 15 16 
 i 11 114.828689826 4.5 8.96578428466 123.413354188 1 15 16 
 i 11 114.989262393 4.5 8.79585928322 123.285259695 1 15 16 
 i 11 115.176594398 4.5 8.96578428466 123.157165201 1 15 16 
 i 11 115.326106763 4.5 9.2288186905 123.029070708 1 15 16 
 i 11 115.501616351 4.5 9.38082178394 122.900976215 1 15 16 
 i 11 115.676227109 4.5 9.2288186905 122.772881722 1 15 16 
 i 11 115.823773461 4.5 9.38082178394 122.644787228 1 15 16 
 i 11 115.990745846 4.5 9.96578428466 122.516692735 1 15 16 
 i 11 116.169910983 4.5 9.79585928322 122.388598242 1 15 16 
 i 11 116.32412095 4.5 9.96578428466 122.260503748 1 15 16 
 i 11 116.495090704 4.5 9.79585928322 122.132409255 1 15 16 
 i 11 116.675485702 4.5 9.96578428466 122.004314762 1 15 16 
 i 11 116.839031776 4.5 10.2288186905 121.876220269 1 15 16 
 i 11 116.998790314 4.5 10.3808217839 121.748125775 1 15 16 
 i 11 117.173203638 4.5 10.2288186905 121.620031282 1 15 16 
 i 11 117.331290298 4.5 10.3808217839 121.491936789 1 15 16 
 i 11 117.510320978 4.5 10.9657842847 121.363842295 1 15 16 
 i 11 117.656979873 4.5 10.7958592832 121.235747802 1 15 16 
 i 11 117.822358431 4.5 10.9657842847 121.107653309 1 15 16 
 i 11 117.989586117 4.5 10.7958592832 120.979558816 1 15 16 
 i 11 118.17245513 4.5 10.9657842847 120.723369829 1 15 16 
 i 11 118.324853931 4.5 11.2288186905 120.595275336 1 15 16 
 i 11 118.508195725 4.5 11.3808217839 120.467180842 1 15 16 
 i 11 118.674105181 4.5 11.2288186905 120.339086349 1 15 16 
 i 11 118.82472486 4.5 11.3808217839 120.210991856 1 15 16 
 i 11 119.01043903 4.5 11.9657842847 120.082897363 1 15 16 
 i 11 119.156002388 4.5 11.7958592832 119.954802869 1 15 16 
 i 11 119.33752537 4.5 11.9657842847 119.826708376 1 15 16 
 i 11 119.49996616 4.5 11.7958592832 119.698613883 1 15 16 
 i 11 119.662198752 4.5 8.05889 119.570519389 1 15 16 
 i 11 119.838840318 4.5 12.7027498788 119.442424896 1 15 16 
 i 11 0.245888809536 4.5 8.05889368905 119.314330403 -1 15 16 
 i 11 0.506613642732 4.5 12.7027498788 119.18623591 -1 15 16 
 i 11 0.743833061888 4.5 8.47393118833 119.058141416 -1 15 16 
 i 11 1.00426607845 4.5 8.64385618977 118.930046923 -1 15 16 
 i 11 1.25422389948 4.5 8.47393118833 118.80195243 -1 15 16 
 i 11 1.49822266398 4.5 8.64385618977 118.673857936 -1 15 16 
 i 11 1.75641523962 4.5 8.88896868761 118.545763443 -1 15 16 
 i 11 1.99296073294 4.5 8.79585928322 118.41766895 -1 15 16 
 i 11 2.25837076042 4.5 8.64385618977 118.289574457 -1 15 16 
 i 11 2.50542966468 4.5 8.79585928322 118.161479963 -1 15 16 
 i 11 2.74094396003 4.5 8.64385618977 118.03338547 -1 15 16 
 i 11 3.00871701337 4.5 9.2288186905 117.905290977 -1 15 16 
 i 11 3.24051101508 4.5 9.38082178394 117.64910199 -1 15 16 
 i 11 3.49597526449 4.5 9.2288186905 117.521007497 -1 15 16 
 i 11 3.74931781362 4.5 9.38082178394 117.392913004 -1 15 16 
 i 11 3.99699925605 4.5 9.64385618977 117.26481851 -1 15 16 
 i 11 4.25623222268 4.5 9.55074678538 117.136724017 -1 15 16 
 i 11 4.5017565342 4.5 9.38082178394 117.008629524 -1 15 16 
 i 11 4.75679749528 4.5 9.55074678538 116.88053503 -1 15 16 
 i 11 4.99664704619 4.5 9.38082178394 116.752440537 -1 15 16 
 i 11 5.25339953695 4.5 9.96578428466 116.624346044 -1 15 16 
 i 11 5.5102783183 4.5 8.22882 116.496251551 -1 15 16 
 i 11 5.75272280555 4.5 8.05889368905 116.368157057 -1 15 16 
 i 11 6.24938377651 4.5 8.2288186905 116.240062564 -1 15 16 
 i 11 6.49378814308 4.5 8.05889368905 116.111968071 -1 15 16 
 i 11 6.74524789173 4.5 8.64385618977 115.983873577 -1 15 16 
 i 11 7.00262377652 4.5 8.79585928322 115.855779084 -1 15 16 
 i 11 7.25959293195 4.5 8.64385618977 115.727684591 -1 15 16 
 i 11 7.50477311147 4.5 8.79585928322 115.599590098 -1 15 16 
 i 11 7.74827504276 4.5 9.05889368905 115.471495604 -1 15 16 
 i 11 7.99359186526 4.5 8.96578428466 115.343401111 -1 15 16 
 i 11 8.26086368112 4.5 8.79585928322 115.215306618 -1 15 16 
 i 11 8.49370926335 4.5 8.96578428466 115.087212124 -1 15 16 
 i 11 8.75033834476 4.5 8.79585928322 114.959117631 -1 15 16 
 i 11 9.0055256216 4.5 9.38082178394 114.831023138 -1 15 16 
 i 11 9.25382272471 4.5 9.55074678538 114.574834151 -1 15 16 
 i 11 9.50946153242 4.5 9.38082178394 114.446739658 -1 15 16 
 i 11 9.75447193918 4.5 9.55074678538 114.318645165 -1 15 16 
 i 11 9.99912025275 4.5 9.79585928322 114.190550671 -1 15 16 
 i 11 10.2595986636 4.5 9.70274987883 114.062456178 -1 15 16 
 i 11 10.5007112434 4.5 9.55074678538 113.934361685 -1 15 16 
 i 11 10.7566618926 4.5 9.70274987883 113.806267192 -1 15 16 
 i 11 11.0064176776 4.5 9.55074678538 113.678172698 -1 15 16 
 i 11 11.2569913099 4.5 10.1177873781 113.550078205 -1 15 16 
 i 11 11.5080583343 4.5 8.05889 113.421983712 -1 15 16 
 i 11 11.7603444341 4.5 12.7027498788 113.293889218 -1 15 16 
 i 11 12.2503861419 4.5 8.05889368905 113.165794725 -1 15 16 
 i 11 12.499612462 4.5 12.7027498788 113.037700232 -1 15 16 
 i 11 12.7479327998 4.5 8.47393118833 112.909605739 -1 15 16 
 i 11 12.9965712517 4.5 8.64385618977 112.781511245 -1 15 16 
 i 11 13.2592377728 4.5 8.47393118833 112.653416752 -1 15 16 
 i 11 13.5080924171 4.5 8.64385618977 112.525322259 -1 15 16 
 i 11 13.7520652556 4.5 8.88896868761 112.397227765 -1 15 16 
 i 11 14.0056474612 4.5 8.79585928322 112.269133272 -1 15 16 
 i 11 14.2609828582 4.5 8.64385618977 112.141038779 -1 15 16 
 i 11 14.4982656881 4.5 8.79585928322 112.012944286 -1 15 16 
 i 11 14.7438722904 4.5 8.64385618977 111.884849792 -1 15 16 
 i 11 14.9898241108 4.5 9.2288186905 111.756755299 -1 15 16 
 i 11 15.2419751103 4.5 9.38082178394 111.500566312 -1 15 16 
 i 11 15.4979745865 4.5 9.2288186905 111.372471819 -1 15 16 
 i 11 15.7470273671 4.5 9.38082178394 111.244377326 -1 15 16 
 i 11 16.0078590421 4.5 9.64385618977 111.116282833 -1 15 16 
 i 11 16.2412394228 4.5 9.55074678538 110.988188339 -1 15 16 
 i 11 16.4981302608 4.5 9.38082178394 110.860093846 -1 15 16 
 i 11 16.7399042523 4.5 9.55074678538 110.731999353 -1 15 16 
 i 11 16.9952266406 4.5 9.38082178394 110.60390486 -1 15 16 
 i 11 17.251727178 4.5 9.96578428466 110.475810366 -1 15 16 
 i 11 17.4935455504 4.5 8.22882 110.347715873 -1 15 16 
 i 11 17.7436371691 4.5 8.05889368905 110.21962138 -1 15 16 
 i 11 18.2474125728 4.5 8.2288186905 110.091526886 -1 15 16 
 i 11 18.5011163 4.5 8.05889368905 109.963432393 -1 15 16 
 i 11 18.7526617509 4.5 8.64385618977 109.8353379 -1 15 16 
 i 11 18.9998261297 4.5 8.79585928322 109.707243407 -1 15 16 
 i 11 19.243442846 4.5 8.64385618977 109.579148913 -1 15 16 
 i 11 19.4972148221 4.5 8.79585928322 109.45105442 -1 15 16 
 i 11 19.7460602238 4.5 9.05889368905 109.322959927 -1 15 16 
 i 11 19.9901448171 4.5 8.96578428466 109.194865433 -1 15 16 
 i 11 20.2466160374 4.5 8.79585928322 109.06677094 -1 15 16 
 i 11 20.4956541844 4.5 8.96578428466 108.938676447 -1 15 16 
 i 11 20.7554014583 4.5 8.79585928322 108.810581954 -1 15 16 
 i 11 21.0067559399 4.5 9.38082178394 108.68248746 -1 15 16 
 i 11 21.2406719039 4.5 9.55074678538 108.426298474 -1 15 16 
 i 11 21.5023964241 4.5 9.38082178394 108.29820398 -1 15 16 
 i 11 21.7522304449 4.5 9.55074678538 108.170109487 -1 15 16 
 i 11 22.0094900352 4.5 9.79585928322 108.042014994 -1 15 16 
 i 11 22.2480790032 4.5 9.70274987883 107.913920501 -1 15 16 
 i 11 22.5015005186 4.5 9.55074678538 107.785826007 -1 15 16 
 i 11 22.7596093218 4.5 9.70274987883 107.657731514 -1 15 16 
 i 11 22.9959419033 4.5 9.55074678538 107.529637021 -1 15 16 
 i 11 23.2488464704 4.5 10.1177873781 107.401542527 -1 15 16 
 i 11 23.5070424001 4.5 8.05889 107.273448034 -1 15 16 
 i 11 23.74442411 4.5 12.7027498788 107.145353541 -1 15 16 
 i 11 24.241532338 4.5 8.05889368905 107.017259048 -1 15 16 
 i 11 24.4950691544 4.5 12.7027498788 106.889164554 -1 15 16 
 i 11 24.7502051207 4.5 8.47393118833 106.761070061 -1 15 16 
 i 11 24.9896591543 4.5 8.64385618977 106.632975568 -1 15 16 
 i 11 25.2442432227 4.5 8.47393118833 106.504881074 -1 15 16 
 i 11 25.4907427931 4.5 8.64385618977 106.376786581 -1 15 16 
 i 11 25.7499990546 4.5 8.88896868761 106.248692088 -1 15 16 
 i 11 25.9926348554 4.5 8.79585928322 106.120597595 -1 15 16 
 i 11 26.2429160011 4.5 8.64385618977 105.992503101 -1 15 16 
 i 11 26.4922268106 4.5 8.79585928322 105.864408608 -1 15 16 
 i 11 26.7596691479 4.5 8.64385618977 105.736314115 -1 15 16 
 i 11 27.0061754969 4.5 9.2288186905 105.608219621 -1 15 16 
 i 11 27.2598135296 4.5 9.38082178394 105.352030635 -1 15 16 
 i 11 27.4958679459 4.5 9.2288186905 105.223936142 -1 15 16 
 i 11 27.7451906026 4.5 9.38082178394 105.095841648 -1 15 16 
 i 11 27.9964208607 4.5 9.64385618977 104.967747155 -1 15 16 
 i 11 28.253650013 4.5 9.55074678538 104.839652662 -1 15 16 
 i 11 28.500432571 4.5 9.38082178394 104.711558168 -1 15 16 
 i 11 28.7482111682 4.5 9.55074678538 104.583463675 -1 15 16 
 i 11 28.9942693174 4.5 9.38082178394 104.455369182 -1 15 16 
 i 11 29.2499186359 4.5 9.96578428466 104.327274689 -1 15 16 
 i 11 29.4991682727 4.5 8.22882 104.199180195 -1 15 16 
 i 11 29.7481550399 4.5 8.05889368905 104.071085702 -1 15 16 
 i 11 30.2534919854 4.5 8.2288186905 103.942991209 -1 15 16 
 i 11 30.50737602 4.5 8.05889368905 103.814896715 -1 15 16 
 i 11 30.7586608443 4.5 8.64385618977 103.686802222 -1 15 16 
 i 11 31.0022586 4.5 8.79585928322 103.558707729 -1 15 16 
 i 11 31.2531462592 4.5 8.64385618977 103.430613236 -1 15 16 
 i 11 31.4946438169 4.5 8.79585928322 103.302518742 -1 15 16 
 i 11 31.7463986479 4.5 9.05889368905 103.174424249 -1 15 16 
 i 11 32.0016443464 4.5 8.96578428466 103.046329756 -1 15 16 
 i 11 32.2545138544 4.5 8.79585928322 102.918235262 -1 15 16 
 i 11 32.5106140754 4.5 8.96578428466 102.790140769 -1 15 16 
 i 11 32.7474194765 4.5 8.79585928322 102.662046276 -1 15 16 
 i 11 32.9894597853 4.5 9.38082178394 102.533951783 -1 15 16 
 i 11 33.25466396 4.5 9.55074678538 102.277762796 -1 15 16 
 i 11 33.4890094599 4.5 9.38082178394 102.149668303 -1 15 16 
 i 11 33.7502115956 4.5 9.55074678538 102.021573809 -1 15 16 
 i 11 33.9897190203 4.5 9.79585928322 101.893479316 -1 15 16 
 i 11 34.2443120736 4.5 9.70274987883 101.765384823 -1 15 16 
 i 11 34.4928009089 4.5 9.55074678538 101.63729033 -1 15 16 
 i 11 34.7598276024 4.5 9.70274987883 101.509195836 -1 15 16 
 i 11 35.0068648685 4.5 9.55074678538 101.381101343 -1 15 16 
 i 11 35.2500261302 4.5 10.1177873781 101.25300685 -1 15 16 
 i 11 35.5087669641 4.5 8.05889 101.124912356 -1 15 16 
 i 11 35.7458818758 4.5 12.7027498788 100.996817863 -1 15 16 
 i 11 36.2400451332 4.5 8.05889368905 100.86872337 -1 15 16 
 i 11 36.4986187314 4.5 12.7027498788 100.740628877 -1 15 16 
 i 11 36.7534572083 4.5 8.47393118833 100.612534383 -1 15 16 
 i 11 36.9923923512 4.5 8.64385618977 100.48443989 -1 15 16 
 i 11 37.2547368385 4.5 8.47393118833 100.356345397 -1 15 16 
 i 11 37.5022751406 4.5 8.64385618977 100.228250903 -1 15 16 
 i 11 37.7417217923 4.5 8.88896868761 100.10015641 -1 15 16 
 i 11 38.0003383003 4.5 8.79585928322 99.9720619168 -1 15 16 
 i 11 38.244561954 4.5 8.64385618977 99.8439674235 -1 15 16 
 i 11 38.5105575332 4.5 8.79585928322 99.7158729303 -1 15 16 
 i 11 38.7442578226 4.5 8.64385618977 99.587778437 -1 15 16 
 i 11 38.9934028657 4.5 9.2288186905 99.4596839437 -1 15 16 
 i 11 39.2596774416 4.5 9.38082178394 99.2034949571 -1 15 16 
 i 11 39.5059642865 4.5 9.2288186905 99.0754004638 -1 15 16 
 i 11 39.742688039 4.5 9.38082178394 98.9473059706 -1 15 16 
 i 11 40.003588647 4.5 9.64385618977 98.8192114773 -1 15 16 
 i 11 40.2414356027 4.5 9.55074678538 98.691116984 -1 15 16 
 i 11 40.4971385779 4.5 9.38082178394 98.5630224907 -1 15 16 
 i 11 40.7419544184 4.5 9.55074678538 98.4349279974 -1 15 16 
 i 11 40.9930133891 4.5 9.38082178394 98.3068335041 -1 15 16 
 i 11 41.2453843753 4.5 9.96578428466 98.1787390108 -1 15 16 
 i 11 41.498353544 4.5 8.22882 98.0506445176 -1 15 16 
 i 11 41.7564180205 4.5 8.05889368905 97.9225500243 -1 15 16 
 i 11 42.2405618715 4.5 8.2288186905 97.794455531 -1 15 16 
 i 11 42.5019084625 4.5 8.05889368905 97.6663610377 -1 15 16 
 i 11 42.751133115 4.5 8.64385618977 97.5382665444 -1 15 16 
 i 11 43.0079236524 4.5 8.79585928322 97.4101720511 -1 15 16 
 i 11 43.2412896271 4.5 8.64385618977 97.2820775578 -1 15 16 
 i 11 43.5022290659 4.5 8.79585928322 97.1539830646 -1 15 16 
 i 11 43.7527507412 4.5 9.05889368905 97.0258885713 -1 15 16 
 i 11 44.0010921431 4.5 8.96578428466 96.897794078 -1 15 16 
 i 11 44.2580580512 4.5 8.79585928322 96.7696995847 -1 15 16 
 i 11 44.504591885 4.5 8.96578428466 96.6416050914 -1 15 16 
 i 11 44.7587010986 4.5 8.79585928322 96.5135105981 -1 15 16 
 i 11 44.9980552731 4.5 9.38082178394 96.3854161048 -1 15 16 
 i 11 45.2502954747 4.5 9.55074678538 96.1292271183 -1 15 16 
 i 11 45.5106662198 4.5 9.38082178394 96.001132625 -1 15 16 
 i 11 45.7542153507 4.5 9.55074678538 95.8730381317 -1 15 16 
 i 11 45.9948160958 4.5 9.79585928322 95.7449436384 -1 15 16 
 i 11 46.2486365315 4.5 9.70274987883 95.6168491451 -1 15 16 
 i 11 46.5011821141 4.5 9.55074678538 95.4887546519 -1 15 16 
 i 11 46.7413479705 4.5 9.70274987883 95.3606601586 -1 15 16 
 i 11 47.0057900503 4.5 9.55074678538 95.2325656653 -1 15 16 
 i 11 47.2561064082 4.5 10.1177873781 95.104471172 -1 15 16 
 i 11 47.498817673 4.5 8.05889 94.9763766787 -1 15 16 
 i 11 47.7392250289 4.5 12.7027498788 94.8482821854 -1 15 16 
 i 11 48.256022569 4.5 8.05889368905 94.7201876921 -1 15 16 
 i 11 48.4924295407 4.5 12.7027498788 94.5920931989 -1 15 16 
 i 11 48.7593233856 4.5 8.47393118833 94.4639987056 -1 15 16 
 i 11 48.9940682506 4.5 8.64385618977 94.3359042123 -1 15 16 
 i 11 49.2434751672 4.5 8.47393118833 94.207809719 -1 15 16 
 i 11 49.5079713993 4.5 8.64385618977 94.0797152257 -1 15 16 
 i 11 49.7500592461 4.5 8.88896868761 93.9516207324 -1 15 16 
 i 11 49.9903141025 4.5 8.79585928322 93.8235262391 -1 15 16 
 i 11 50.2517663056 4.5 8.64385618977 93.6954317459 -1 15 16 
 i 11 50.5013383989 4.5 8.79585928322 93.5673372526 -1 15 16 
 i 11 50.7411304366 4.5 8.64385618977 93.4392427593 -1 15 16 
 i 11 50.9931316439 4.5 9.2288186905 93.311148266 -1 15 16 
 i 11 51.2601850593 4.5 9.38082178394 93.0549592794 -1 15 16 
 i 11 51.5023257363 4.5 9.2288186905 92.9268647861 -1 15 16 
 i 11 51.7440077971 4.5 9.38082178394 92.7987702929 -1 15 16 
 i 11 52.0034345492 4.5 9.64385618977 92.6706757996 -1 15 16 
 i 11 52.2514562926 4.5 9.55074678538 92.5425813063 -1 15 16 
 i 11 52.4895489601 4.5 9.38082178394 92.414486813 -1 15 16 
 i 11 52.7579175513 4.5 9.55074678538 92.2863923197 -1 15 16 
 i 11 53.0015855557 4.5 9.38082178394 92.1582978264 -1 15 16 
 i 11 53.2457553379 4.5 9.96578428466 92.0302033332 -1 15 16 
 i 11 53.5009725306 4.5 8.22882 91.9021088399 -1 15 16 
 i 11 53.7552201918 4.5 8.05889368905 91.7740143466 -1 15 16 
 i 11 54.2604116329 4.5 8.2288186905 91.6459198533 -1 15 16 
 i 11 54.495093599 4.5 8.05889368905 91.51782536 -1 15 16 
 i 11 54.7560235731 4.5 8.64385618977 91.3897308667 -1 15 16 
 i 11 55.0034385836 4.5 8.79585928322 91.2616363734 -1 15 16 
 i 11 55.2594916907 4.5 8.64385618977 91.1335418802 -1 15 16 
 i 11 55.5008003871 4.5 8.79585928322 91.0054473869 -1 15 16 
 i 11 55.7390070915 4.5 9.05889368905 90.8773528936 -1 15 16 
 i 11 55.9895315416 4.5 8.96578428466 90.7492584003 -1 15 16 
 i 11 56.2601029531 4.5 8.79585928322 90.621163907 -1 15 16 
 i 11 56.490464229 4.5 8.96578428466 90.4930694137 -1 15 16 
 i 11 56.7514334232 4.5 8.79585928322 90.3649749204 -1 15 16 
 i 11 56.9915973322 4.5 9.38082178394 90.2368804272 -1 15 16 
 i 11 57.2453030165 4.5 9.55074678538 89.9806914406 -1 15 16 
 i 11 57.5098640528 4.5 9.38082178394 89.8525969473 -1 15 16 
 i 11 57.7413398025 4.5 9.55074678538 89.724502454 -1 15 16 
 i 11 57.992934843 4.5 9.79585928322 89.5964079607 -1 15 16 
 i 11 58.2441709591 4.5 9.70274987883 89.4683134675 -1 15 16 
 i 11 58.5002092374 4.5 9.55074678538 89.3402189742 -1 15 16 
 i 11 58.756055355 4.5 9.70274987883 89.2121244809 -1 15 16 
 i 11 58.9952229999 4.5 9.55074678538 89.0840299876 -1 15 16 
 i 11 59.2390462434 4.5 10.1177873781 88.9559354943 -1 15 16 
 i 11 59.5067732547 4.5 8.05889 88.827841001 -1 15 16 
 i 11 59.7464942219 4.5 12.7027498788 88.6997465077 -1 15 16 
 i 11 60.2446714019 4.5 8.05889368905 88.5716520145 -1 15 16 
 i 11 60.4965063406 4.5 12.7027498788 88.4435575212 -1 15 16 
 i 11 60.7589563921 4.5 8.47393118833 88.3154630279 -1 15 16 
 i 11 61.0106132792 4.5 8.64385618977 88.1873685346 -1 15 16 
 i 11 61.2578147857 4.5 8.47393118833 88.0592740413 -1 15 16 
 i 11 61.4993969745 4.5 8.64385618977 87.931179548 -1 15 16 
 i 11 61.754590999 4.5 8.88896868761 87.8030850547 -1 15 16 
 i 11 62.0035326091 4.5 8.79585928322 87.6749905615 -1 15 16 
 i 11 62.2580628437 4.5 8.64385618977 87.5468960682 -1 15 16 
 i 11 62.4945372864 4.5 8.79585928322 87.4188015749 -1 15 16 
 i 11 62.7552507985 4.5 8.64385618977 87.2907070816 -1 15 16 
 i 11 63.0061254032 4.5 9.2288186905 87.1626125883 -1 15 16 
 i 11 63.2511520313 4.5 9.38082178394 86.9064236017 -1 15 16 
 i 11 63.4936584701 4.5 9.2288186905 86.7783291085 -1 15 16 
 i 11 63.7479184676 4.5 9.38082178394 86.6502346152 -1 15 16 
 i 11 63.996964101 4.5 9.64385618977 86.5221401219 -1 15 16 
 i 11 64.2419104273 4.5 9.55074678538 86.3940456286 -1 15 16 
 i 11 64.4899577841 4.5 9.38082178394 86.2659511353 -1 15 16 
 i 11 64.7505249707 4.5 9.55074678538 86.137856642 -1 15 16 
 i 11 65.0107907966 4.5 9.38082178394 86.0097621488 -1 15 16 
 i 11 65.2546631984 4.5 9.96578428466 85.8816676555 -1 15 16 
 i 11 65.5085895525 4.5 8.22882 85.7535731622 -1 15 16 
 i 11 65.7594763431 4.5 8.05889368905 85.6254786689 -1 15 16 
 i 11 66.2486605278 4.5 8.2288186905 85.4973841756 -1 15 16 
 i 11 66.4964826693 4.5 8.05889368905 85.3692896823 -1 15 16 
 i 11 66.7557364549 4.5 8.64385618977 85.241195189 -1 15 16 
 i 11 67.0025663943 4.5 8.79585928322 85.1131006958 -1 15 16 
 i 11 67.24058204 4.5 8.64385618977 84.9850062025 -1 15 16 
 i 11 67.5007425336 4.5 8.79585928322 84.8569117092 -1 15 16 
 i 11 67.7464083954 4.5 9.05889368905 84.7288172159 -1 15 16 
 i 11 67.9931510962 4.5 8.96578428466 84.6007227226 -1 15 16 
 i 11 68.2509896846 4.5 8.79585928322 84.4726282293 -1 15 16 
 i 11 68.4982086554 4.5 8.96578428466 84.344533736 -1 15 16 
 i 11 68.7588604845 4.5 8.79585928322 84.2164392428 -1 15 16 
 i 11 68.9925838036 4.5 9.38082178394 84.0883447495 -1 15 16 
 i 11 69.2395225961 4.5 9.55074678538 83.8321557629 -1 15 16 
 i 11 69.4946172811 4.5 9.38082178394 83.7040612696 -1 15 16 
 i 11 69.7454302155 4.5 9.55074678538 83.5759667763 -1 15 16 
 i 11 70.00717551 4.5 9.79585928322 83.447872283 -1 15 16 
 i 11 70.2557138609 4.5 9.70274987883 83.3197777898 -1 15 16 
 i 11 70.4939125501 4.5 9.55074678538 83.1916832965 -1 15 16 
 i 11 70.7465661321 4.5 9.70274987883 83.0635888032 -1 15 16 
 i 11 71.0085555507 4.5 9.55074678538 82.9354943099 -1 15 16 
 i 11 71.2471761089 4.5 10.1177873781 82.8073998166 -1 15 16 
 i 11 71.510324359 4.5 8.05889 82.6793053233 -1 15 16 
 i 11 71.7444026357 4.5 12.7027498788 82.5512108301 -1 15 16 
 i 11 72.2407927758 4.5 8.05889368905 82.4231163368 -1 15 16 
 i 11 72.4937194946 4.5 12.7027498788 82.2950218435 -1 15 16 
 i 11 72.7523904271 4.5 8.47393118833 82.1669273502 -1 15 16 
 i 11 72.9910921063 4.5 8.64385618977 82.0388328569 -1 15 16 
 i 11 73.2593182702 4.5 8.47393118833 81.9107383636 -1 15 16 
 i 11 73.4944013634 4.5 8.64385618977 81.7826438703 -1 15 16 
 i 11 73.7493904174 4.5 8.88896868761 81.6545493771 -1 15 16 
 i 11 73.9941091889 4.5 8.79585928322 81.5264548838 -1 15 16 
 i 11 74.2546900837 4.5 8.64385618977 81.3983603905 -1 15 16 
 i 11 74.5039088797 4.5 8.79585928322 81.2702658972 -1 15 16 
 i 11 74.7491450836 4.5 8.64385618977 81.1421714039 -1 15 16 
 i 11 74.9913014916 4.5 9.2288186905 81.0140769106 -1 15 16 
 i 11 75.2598266922 4.5 9.38082178394 80.7578879241 -1 15 16 
 i 11 75.5079398462 4.5 9.2288186905 80.6297934308 -1 15 16 
 i 11 75.7601652167 4.5 9.38082178394 80.5016989375 -1 15 16 
 i 11 75.9898940549 4.5 9.64385618977 80.3736044442 -1 15 16 
 i 11 76.2600529512 4.5 9.55074678538 80.2455099509 -1 15 16 
 i 11 76.5105278841 4.5 9.38082178394 80.1174154576 -1 15 16 
 i 11 76.7485277178 4.5 9.55074678538 79.9893209643 -1 15 16 
 i 11 76.9897899329 4.5 9.38082178394 79.8612264711 -1 15 16 
 i 11 77.254240306 4.5 9.96578428466 79.7331319778 -1 15 16 
 i 11 77.5043033312 4.5 8.22882 79.6050374845 -1 15 16 
 i 11 77.7536575736 4.5 8.05889368905 79.4769429912 -1 15 16 
 i 11 78.2397731687 4.5 8.2288186905 79.3488484979 -1 15 16 
 i 11 78.5006294507 4.5 8.05889368905 79.2207540046 -1 15 16 
 i 11 78.7595770781 4.5 8.64385618977 79.0926595114 -1 15 16 
 i 11 79.0013602977 4.5 8.79585928322 78.9645650181 -1 15 16 
 i 11 79.2499811718 4.5 8.64385618977 78.8364705248 -1 15 16 
 i 11 79.4897508223 4.5 8.79585928322 78.7083760315 -1 15 16 
 i 11 79.7581988444 4.5 9.05889368905 78.5802815382 -1 15 16 
 i 11 79.9943368694 4.5 8.96578428466 78.4521870449 -1 15 16 
 i 11 80.2553913203 4.5 8.79585928322 78.3240925516 -1 15 16 
 i 11 80.5059676858 4.5 8.96578428466 78.1959980584 -1 15 16 
 i 11 80.7489962616 4.5 8.79585928322 78.0679035651 -1 15 16 
 i 11 80.9980021423 4.5 9.38082178394 77.9398090718 -1 15 16 
 i 11 81.2400064656 4.5 9.55074678538 77.6836200852 -1 15 16 
 i 11 81.4951242926 4.5 9.38082178394 77.5555255919 -1 15 16 
 i 11 81.7411804547 4.5 9.55074678538 77.4274310986 -1 15 16 
 i 11 82.0041932072 4.5 9.79585928322 77.2993366054 -1 15 16 
 i 11 82.2559961857 4.5 9.70274987883 77.1712421121 -1 15 16 
 i 11 82.5038877836 4.5 9.55074678538 77.0431476188 -1 15 16 
 i 11 82.7515848769 4.5 9.70274987883 76.9150531255 -1 15 16 
 i 11 83.0023548872 4.5 9.55074678538 76.7869586322 -1 15 16 
 i 11 83.2440069255 4.5 10.1177873781 76.6588641389 -1 15 16 
 i 11 83.4973752013 4.5 8.05889 76.5307696457 -1 15 16 
 i 11 83.7461448784 4.5 12.7027498788 76.4026751524 -1 15 16 
 i 11 84.2400064099 4.5 8.05889368905 76.2745806591 -1 15 16 
 i 11 84.4958334536 4.5 12.7027498788 76.1464861658 -1 15 16 
 i 11 84.757633591 4.5 8.47393118833 76.0183916725 -1 15 16 
 i 11 85.0036908658 4.5 8.64385618977 75.8902971792 -1 15 16 
 i 11 85.2530132107 4.5 8.47393118833 75.7622026859 -1 15 16 
 i 11 85.4919755131 4.5 8.64385618977 75.6341081927 -1 15 16 
 i 11 85.7547711973 4.5 8.88896868761 75.5060136994 -1 15 16 
 i 11 86.0041562707 4.5 8.79585928322 75.3779192061 -1 15 16 
 i 11 86.2465850831 4.5 8.64385618977 75.2498247128 -1 15 16 
 i 11 86.4930335742 4.5 8.79585928322 75.1217302195 -1 15 16 
 i 11 86.7486922806 4.5 8.64385618977 74.9936357262 -1 15 16 
 i 11 86.9992261484 4.5 9.2288186905 74.8655412329 -1 15 16 
 i 11 87.2400647904 4.5 9.38082178394 74.6093522464 -1 15 16 
 i 11 87.4947407884 4.5 9.2288186905 74.4812577531 -1 15 16 
 i 11 87.7417361884 4.5 9.38082178394 74.3531632598 -1 15 16 
 i 11 87.9985315879 4.5 9.64385618977 74.2250687665 -1 15 16 
 i 11 88.244954937 4.5 9.55074678538 74.0969742732 -1 15 16 
 i 11 88.5068373336 4.5 9.38082178394 73.9688797799 -1 15 16 
 i 11 88.7452576034 4.5 9.55074678538 73.8407852867 -1 15 16 
 i 11 89.0006624249 4.5 9.38082178394 73.7126907934 -1 15 16 
 i 11 89.241141271 4.5 9.96578428466 73.5845963001 -1 15 16 
 i 11 89.4944461317 4.5 8.22882 73.4565018068 -1 15 16 
 i 11 89.7506671457 4.5 8.05889368905 73.3284073135 -1 15 16 
 i 11 90.2581304102 4.5 8.2288186905 73.2003128202 -1 15 16 
 i 11 90.4964257617 4.5 8.05889368905 73.072218327 -1 15 16 
 i 11 90.747154263 4.5 8.64385618977 72.9441238337 -1 15 16 
 i 11 90.9936357623 4.5 8.79585928322 72.8160293404 -1 15 16 
 i 11 91.2438510762 4.5 8.64385618977 72.6879348471 -1 15 16 
 i 11 91.4948678724 4.5 8.79585928322 72.5598403538 -1 15 16 
 i 11 91.7450392767 4.5 9.05889368905 72.4317458605 -1 15 16 
 i 11 92.0040049854 4.5 8.96578428466 72.3036513672 -1 15 16 
 i 11 92.2543505877 4.5 8.79585928322 72.175556874 -1 15 16 
 i 11 92.500585225 4.5 8.96578428466 72.0474623807 -1 15 16 
 i 11 92.7545474855 4.5 8.79585928322 71.9193678874 -1 15 16 
 i 11 92.9916677328 4.5 9.38082178394 71.7912733941 -1 15 16 
 i 11 93.2465804601 4.5 9.55074678538 71.5350844075 -1 15 16 
 i 11 93.4930933067 4.5 9.38082178394 71.4069899142 -1 15 16 
 i 11 93.7469482114 4.5 9.55074678538 71.278895421 -1 15 16 
 i 11 93.9920788699 4.5 9.79585928322 71.1508009277 -1 15 16 
 i 11 94.2527570482 4.5 9.70274987883 71.0227064344 -1 15 16 
 i 11 94.5004129324 4.5 9.55074678538 70.8946119411 -1 15 16 
 i 11 94.7440524873 4.5 9.70274987883 70.7665174478 -1 15 16 
 i 11 95.0067530041 4.5 9.55074678538 70.6384229545 -1 15 16 
 i 11 95.2498831441 4.5 10.1177873781 70.5103284612 -1 15 16 
 i 11 95.5074863333 4.5 8.05889 70.382233968 -1 15 16 
 i 11 95.7466365065 4.5 12.7027498788 70.2541394747 -1 15 16 
 i 11 96.2535391391 4.5 8.05889368905 70.1260449814 -1 15 16 
 i 11 96.4918577083 4.5 12.7027498788 127 -1 15 16 
 i 11 96.7432970809 4.5 8.47393118833 127 -1 15 16 
 i 11 96.999840252 4.5 8.64385618977 127 -1 15 16 
 i 11 97.2415162383 4.5 8.47393118833 127 -1 15 16 
 i 11 97.4976058813 4.5 8.64385618977 127 -1 15 16 
 i 11 97.7551465995 4.5 8.88896868761 127 -1 15 16 
 i 11 98.003788432 4.5 8.79585928322 127 -1 15 16 
 i 11 98.2416517445 4.5 8.64385618977 127 -1 15 16 
 i 11 98.5066660357 4.5 8.79585928322 127 -1 15 16 
 i 11 98.7466519587 4.5 8.64385618977 127 -1 15 16 
 i 11 98.9907744847 4.5 9.2288186905 127 -1 15 16 
 i 11 99.2453170822 4.5 9.38082178394 127 -1 15 16 
 i 11 99.5095102401 4.5 9.2288186905 127 -1 15 16 
 i 11 99.7497191636 4.5 9.38082178394 127 -1 15 16 
 i 11 100.000028369 4.5 9.64385618977 127 -1 15 16 
 i 11 100.260799312 4.5 9.55074678538 127 -1 15 16 
 i 11 100.499252005 4.5 9.38082178394 127 -1 15 16 
 i 11 100.740008257 4.5 9.55074678538 127 -1 15 16 
 i 11 100.992745402 4.5 9.38082178394 71.5091075967 -1 15 16 
 i 11 101.244227909 4.5 9.96578428466 71.6767862186 -1 15 16 
 i 11 101.502114501 4.5 8.22882 71.8444648404 -1 15 16 
 i 11 101.747879461 4.5 8.05889368905 72.0121434623 -1 15 16 
 i 11 102.240102795 4.5 8.2288186905 72.1798220842 -1 15 16 
 i 11 102.503344197 4.5 8.05889368905 72.347500706 -1 15 16 
 i 11 102.759222371 4.5 8.64385618977 72.5151793279 -1 15 16 
 i 11 103.004040871 4.5 8.79585928322 72.6828579497 -1 15 16 
 i 11 103.244952701 4.5 8.64385618977 72.8505365716 -1 15 16 
 i 11 103.506021599 4.5 8.79585928322 73.0182151934 -1 15 16 
 i 11 103.75639611 4.5 9.05889368905 73.1858938153 -1 15 16 
 i 11 104.005012234 4.5 8.96578428466 73.3535724372 -1 15 16 
 i 11 104.26003023 4.5 8.79585928322 73.521251059 -1 15 16 
 i 11 104.506283275 4.5 8.96578428466 73.6889296809 -1 15 16 
 i 11 104.753216322 4.5 8.79585928322 73.8566083027 -1 15 16 
 i 11 104.990805273 4.5 9.38082178394 74.0242869246 -1 15 16 
 i 11 105.244866403 4.5 9.55074678538 74.1919655465 -1 15 16 
 i 11 105.501722641 4.5 9.38082178394 74.3596441683 -1 15 16 
 i 11 105.739852397 4.5 9.55074678538 74.5273227902 -1 15 16 
 i 11 106.007585978 4.5 9.79585928322 74.695001412 -1 15 16 
 i 11 106.258626446 4.5 9.70274987883 74.8626800339 -1 15 16 
 i 11 106.507898177 4.5 9.55074678538 75.0303586557 -1 15 16 
 i 11 106.749260302 4.5 9.70274987883 75.1980372776 -1 15 16 
 i 11 106.991589865 4.5 9.55074678538 75.3657158995 -1 15 16 
 i 11 107.24843499 4.5 10.1177873781 75.5333945213 -1 15 16 
 i 11 107.499918569 4.5 8.05889 75.7010731432 -1 15 16 
 i 11 107.750883617 4.5 12.7027498788 75.868751765 -1 15 16 
 i 11 108.256167078 4.5 8.05889368905 76.0364303869 -1 15 16 
 i 11 108.491575105 4.5 12.7027498788 76.2041090088 -1 15 16 
 i 11 108.754203968 4.5 8.47393118833 76.3717876306 -1 15 16 
 i 11 109.00483972 4.5 8.64385618977 76.5394662525 -1 15 16 
 i 11 109.250051468 4.5 8.47393118833 78.2162524711 -1 15 16 
 i 11 109.499305257 4.5 8.64385618977 78.3839310929 -1 15 16 
 i 11 109.753308648 4.5 8.88896868761 78.5516097148 -1 15 16 
 i 11 109.994241603 4.5 8.79585928322 78.7192883366 -1 15 16 
 i 11 110.256218641 4.5 8.64385618977 78.8869669585 -1 15 16 
 i 11 110.507634176 4.5 8.79585928322 79.0546455803 -1 15 16 
 i 11 110.743627434 4.5 8.64385618977 79.2223242022 -1 15 16 
 i 11 110.998654046 4.5 9.2288186905 79.3900028241 -1 15 16 
 i 11 111.24507055 4.5 9.38082178394 79.5576814459 -1 15 16 
 i 11 111.507083224 4.5 9.2288186905 79.7253600678 -1 15 16 
 i 11 111.757397451 4.5 9.38082178394 79.8930386896 -1 15 16 
 i 11 111.998803818 4.5 9.64385618977 80.0607173115 -1 15 16 
 i 11 112.246201742 4.5 9.55074678538 80.2283959334 -1 15 16 
 i 11 112.50275403 4.5 9.38082178394 80.3960745552 -1 15 16 
 i 11 112.743223967 4.5 9.55074678538 80.5637531771 -1 15 16 
 i 11 112.989526245 4.5 9.38082178394 80.7314317989 -1 15 16 
 i 11 113.250607639 4.5 9.96578428466 80.8991104208 -1 15 16 
 i 11 113.493513892 4.5 7.88897 81.0667890426 -1 15 16 
 i 11 113.756535605 4.5 8.47393 81.2344676645 -1 15 16 
 i 11 118.260298993 6 7.88897 81.4021462864 -1 3 4 
 i 11 124.245499683 6 8.47393 81.5698249082 -1 3 4 
 i 11 130.243210165 6 7.88897 81.7375035301 -1 3 4 
 i 11 136.245720224 6 8.47393 81.9051821519 -1 3 4 
 i 11 142.248440332 6 7.88897 82.0728607738 -1 3 4 
 i 11 148.240083934 6 8.47393 82.2405393957 -1 3 4 
 i 11 154.240503569 6 8.058 82.4082180175 -1 3 4 
 i 11 160.260102627 6 8.64386 82.5758966394 -1 3 4 
 i 11 166.260114124 6 8.88897 82.7435752612 -1 3 4 
 i 11 119.25810715 6 8.64386 82.9112538831 1 3 4 
 i 11 124.25605391 6 8.88897 83.0789325049 1 3 4 
 i 11 131.245604435 6 8.058 83.2466111268 1 3 4 
 i 11 136.254782461 6 8.88897 87.6062552951 1 3 4 
 i 11 143.249059493 6 8.058 87.773933917 1 3 4 
 i 11 148.249112843 6 8.64386 87.9416125388 1 3 4 
 i 11 155.240129998 6 8.058 88.1092911607 1 3 4 
 i 11 160.252978724 6 8.47393118833 88.2769697825 1 3 4 
 i 11 167.249940935 6 8.2288186905 88.4446484044 1 3 4 
 i 11 119.378944913 4.5 8.05889368905 88.6123270263 1 15 16 
 i 11 119.498373591 4.5 8.2288186905 88.7800056481 1 15 16 
 i 11 119.623859985 4.5 8.64385618977 88.94768427 1 15 16 
 i 11 119.758539853 4.5 8.38082178394 89.1153628918 1 15 16 
 i 11 119.880847114 4.5 8.2288186905 89.2830415137 1 15 16 
 i 11 120.005159014 4.5 8.38082178394 89.4507201356 1 15 16 
 i 11 120.129674206 4.5 8.79585928322 89.6183987574 1 15 16 
 i 11 120.253176073 4.5 8.55074678538 89.7860773793 1 15 16 
 i 11 120.374331511 4.5 8.38082178394 89.9537560011 1 15 16 
 i 11 120.502034101 4.5 8.55074678538 90.121434623 1 15 16 
 i 11 120.627818376 4.5 8.96578428466 90.2891132448 1 15 16 
 i 11 120.756063451 4.5 8.70274987883 90.4567918667 1 15 16 
 i 11 120.876677227 4.5 8.55074678538 90.6244704886 1 15 16 
 i 11 120.999533252 4.5 8.70274987883 90.7921491104 1 15 16 
 i 11 121.118023386 4.5 9.11778737811 90.9598277323 1 15 16 
 i 11 121.243713976 4.5 8.88896868761 91.1275063541 1 15 16 
 i 11 121.367030712 4.5 8.70274987883 91.295184976 1 15 16 
 i 11 121.505249384 4.5 8.88896868761 91.4628635979 1 15 16 
 i 11 121.616082811 4.5 9.30400618689 91.6305422197 1 15 16 
 i 11 121.749107006 4.5 9.05889368905 91.7982208416 1 15 16 
 i 11 121.868085033 4.5 8.88896868761 91.9658994634 1 15 16 
 i 11 122.003867493 4.5 9.05889368905 92.1335780853 1 15 16 
 i 11 122.126879659 4.5 9.47393118833 92.3012567071 1 15 16 
 i 11 122.254360442 4.5 9.2288186905 92.468935329 1 15 16 
 i 11 122.373684791 4.5 9.05889368905 92.6366139509 1 15 16 
 i 11 122.493568934 4.5 9.2288186905 94.3134001694 1 15 16 
 i 11 122.621166779 4.5 9.64385618977 94.4810787913 1 15 16 
 i 11 122.755833168 4.5 9.38082178394 94.6487574132 1 15 16 
 i 11 122.879072291 4.5 8.64386 94.816436035 1 15 16 
 i 11 123.007835713 4.5 9.05889368905 94.9841146569 1 15 16 
 i 11 123.116075211 4.5 8.79585928322 95.1517932787 1 15 16 
 i 11 124.365826566 4.5 8.64385618977 95.3194719006 1 15 16 
 i 11 124.489487337 4.5 8.79585928322 95.4871505225 1 15 16 
 i 11 124.625679666 4.5 9.2288186905 95.6548291443 1 15 16 
 i 11 124.751518569 4.5 8.96578428466 95.8225077662 1 15 16 
 i 11 124.884038363 4.5 8.79585928322 95.990186388 1 15 16 
 i 11 125.010008698 4.5 8.96578428466 96.1578650099 1 15 16 
 i 11 125.133851791 4.5 9.38082178394 96.3255436317 1 15 16 
 i 11 125.260071069 4.5 9.11778737811 96.4932222536 1 15 16 
 i 11 125.365521674 4.5 8.96578428466 96.6609008755 1 15 16 
 i 11 125.491764596 4.5 9.11778737811 96.8285794973 1 15 16 
 i 11 125.627055863 4.5 9.55074678538 96.9962581192 1 15 16 
 i 11 125.753122668 4.5 9.30400618689 97.163936741 1 15 16 
 i 11 125.865457551 4.5 9.11778737811 97.3316153629 1 15 16 
 i 11 126.006121825 4.5 9.30400618689 97.4992939848 1 15 16 
 i 11 126.121620081 4.5 9.70274987883 97.6669726066 1 15 16 
 i 11 126.257827264 4.5 9.47393118833 97.8346512285 1 15 16 
 i 11 126.378507168 4.5 9.30400618689 98.0023298503 1 15 16 
 i 11 126.506337035 4.5 9.47393118833 98.1700084722 1 15 16 
 i 11 126.618935681 4.5 9.88896868761 98.337687094 1 15 16 
 i 11 126.748583898 4.5 9.64385618977 98.5053657159 1 15 16 
 i 11 126.873833115 4.5 9.47393118833 98.6730443378 1 15 16 
 i 11 127.0085976 4.5 9.64385618977 98.8407229596 1 15 16 
 i 11 127.131403112 4.5 10.0588936891 99.0084015815 1 15 16 
 i 11 127.241414937 4.5 9.79585928322 99.1760802033 1 15 16 
 i 11 127.373585647 4.5 9.64385618977 99.3437588252 1 15 16 
 i 11 127.50279599 4.5 9.79585928322 103.703402994 1 15 16 
 i 11 127.624927057 4.5 10.2288186905 103.871081615 1 15 16 
 i 11 127.750449696 4.5 9.96578428466 104.038760237 1 15 16 
 i 11 127.877112797 4.5 8.88897 104.206438859 1 15 16 
 i 11 128.002608491 4.5 9.30400618689 104.374117481 1 15 16 
 i 11 128.12277958 4.5 9.05889368905 104.541796103 1 15 16 
 i 11 131.36755128 4.5 8.88896868761 104.709474725 1 15 16 
 i 11 131.510286391 4.5 9.05889368905 104.877153347 1 15 16 
 i 11 131.635651862 4.5 9.47393118833 105.044831968 1 15 16 
 i 11 131.748865083 4.5 9.2288186905 105.21251059 1 15 16 
 i 11 131.868354782 4.5 9.05889368905 105.380189212 1 15 16 
 i 11 131.991219767 4.5 9.2288186905 105.547867834 1 15 16 
 i 11 132.13088156 4.5 9.64385618977 105.715546456 1 15 16 
 i 11 132.245284302 4.5 9.38082178394 105.883225078 1 15 16 
 i 11 132.376626769 4.5 9.2288186905 106.0509037 1 15 16 
 i 11 132.493285155 4.5 9.38082178394 106.218582321 1 15 16 
 i 11 132.614051627 4.5 9.79585928322 106.386260943 1 15 16 
 i 11 132.76015696 4.5 9.55074678538 106.553939565 1 15 16 
 i 11 132.875640681 4.5 9.38082178394 106.721618187 1 15 16 
 i 11 133.009274792 4.5 9.55074678538 106.889296809 1 15 16 
 i 11 133.121040785 4.5 9.96578428466 107.056975431 1 15 16 
 i 11 133.243231619 4.5 9.70274987883 107.224654053 1 15 16 
 i 11 133.375066975 4.5 9.55074678538 107.392332674 1 15 16 
 i 11 133.492239381 4.5 9.70274987883 107.560011296 1 15 16 
 i 11 133.619206197 4.5 10.1177873781 107.727689918 1 15 16 
 i 11 133.751843501 4.5 9.88896868761 107.89536854 1 15 16 
 i 11 133.866621256 4.5 9.70274987883 108.063047162 1 15 16 
 i 11 134.004163008 4.5 9.88896868761 108.230725784 1 15 16 
 i 11 134.119475967 4.5 10.3040061869 108.398404406 1 15 16 
 i 11 134.241715888 4.5 10.0588936891 108.566083027 1 15 16 
 i 11 134.383310616 4.5 9.88896868761 108.733761649 1 15 16 
 i 11 134.51060951 4.5 10.0588936891 110.410547868 1 15 16 
 i 11 134.614098634 4.5 10.4739311883 110.57822649 1 15 16 
 i 11 134.751106104 4.5 10.2288186905 110.745905112 1 15 16 
 i 11 134.867671881 4.5 8.64386 110.913583733 1 15 16 
 i 11 134.994469516 4.5 9.05889368905 111.081262355 1 15 16 
 i 11 135.119220938 4.5 8.79585928322 111.248940977 1 15 16 
 i 11 136.371649852 4.5 8.64385618977 111.416619599 1 15 16 
 i 11 136.499672811 4.5 8.79585928322 111.584298221 1 15 16 
 i 11 136.615192022 4.5 9.2288186905 111.751976843 1 15 16 
 i 11 136.760673922 4.5 8.96578428466 111.919655465 1 15 16 
 i 11 136.880536729 4.5 8.79585928322 112.087334086 1 15 16 
 i 11 137.004296805 4.5 8.96578428466 112.255012708 1 15 16 
 i 11 137.12329732 4.5 9.38082178394 112.42269133 1 15 16 
 i 11 137.259126674 4.5 9.11778737811 112.590369952 1 15 16 
 i 11 137.384947384 4.5 8.96578428466 112.758048574 1 15 16 
 i 11 137.492321651 4.5 9.11778737811 112.925727196 1 15 16 
 i 11 137.614569578 4.5 9.55074678538 113.093405818 1 15 16 
 i 11 137.758527222 4.5 9.30400618689 113.261084439 1 15 16 
 i 11 137.872372383 4.5 9.11778737811 113.428763061 1 15 16 
 i 11 138.008851262 4.5 9.30400618689 113.596441683 1 15 16 
 i 11 138.12924853 4.5 9.70274987883 113.764120305 1 15 16 
 i 11 138.258545549 4.5 9.47393118833 113.931798927 1 15 16 
 i 11 138.372841336 4.5 9.30400618689 114.099477549 1 15 16 
 i 11 138.506528399 4.5 9.47393118833 114.267156171 1 15 16 
 i 11 138.61425036 4.5 9.88896868761 114.434834792 1 15 16 
 i 11 138.740772778 4.5 9.64385618977 114.602513414 1 15 16 
 i 11 138.872896072 4.5 9.47393118833 114.770192036 1 15 16 
 i 11 139.000432488 4.5 9.64385618977 114.937870658 1 15 16 
 i 11 139.135054801 4.5 10.0588936891 115.10554928 1 15 16 
 i 11 139.247001132 4.5 9.79585928322 115.273227902 1 15 16 
 i 11 139.364635794 4.5 9.64385618977 115.440906524 1 15 16 
 i 11 139.493990915 4.5 9.79585928322 119.800550692 1 15 16 
 i 11 139.629384503 4.5 10.2288186905 119.968229314 1 15 16 
 i 11 139.747217619 4.5 9.96578428466 120.135907936 1 15 16 
 i 11 139.868471321 4.5 8.88897 120.303586557 1 15 16 
 i 11 140.008347254 4.5 9.30400618689 120.471265179 1 15 16 
 i 11 140.127922657 4.5 9.05889368905 120.638943801 1 15 16 
 i 11 143.367913141 4.5 8.88896868761 120.806622423 1 15 16 
 i 11 143.503926074 4.5 9.05889368905 120.974301045 1 15 16 
 i 11 143.62097235 4.5 9.47393118833 121.141979667 1 15 16 
 i 11 143.744045468 4.5 9.2288186905 121.309658289 1 15 16 
 i 11 143.871769373 4.5 9.05889368905 121.47733691 1 15 16 
 i 11 144.007979269 4.5 9.2288186905 121.645015532 1 15 16 
 i 11 144.126286938 4.5 9.64385618977 121.812694154 1 15 16 
 i 11 144.250262006 4.5 9.38082178394 121.980372776 1 15 16 
 i 11 144.383461108 4.5 9.2288186905 122.148051398 1 15 16 
 i 11 144.502760493 4.5 9.38082178394 122.31573002 1 15 16 
 i 11 144.615497429 4.5 9.79585928322 122.483408642 1 15 16 
 i 11 144.744253956 4.5 9.55074678538 122.651087263 1 15 16 
 i 11 144.865789158 4.5 9.38082178394 122.818765885 1 15 16 
 i 11 145.002249566 4.5 9.55074678538 122.986444507 1 15 16 
 i 11 145.129710504 4.5 9.96578428466 123.154123129 1 15 16 
 i 11 145.245772362 4.5 9.70274987883 123.321801751 1 15 16 
 i 11 145.377479834 4.5 9.55074678538 123.489480373 1 15 16 
 i 11 145.489260144 4.5 9.70274987883 123.657158995 1 15 16 
 i 11 145.621867807 4.5 10.1177873781 123.824837616 1 15 16 
 i 11 145.745946167 4.5 9.88896868761 123.992516238 1 15 16 
 i 11 145.881220199 4.5 9.70274987883 124.16019486 1 15 16 
 i 11 146.008538662 4.5 9.88896868761 124.327873482 1 15 16 
 i 11 146.124256599 4.5 10.3040061869 124.495552104 1 15 16 
 i 11 146.258980246 4.5 10.0588936891 124.663230726 1 15 16 
 i 11 146.369551876 4.5 9.88896868761 124.830909348 1 15 16 
 i 11 146.491583888 4.5 10.0588936891 126.507695566 1 15 16 
 i 11 146.630132864 4.5 10.4739311883 126.675374188 1 15 16 
 i 11 146.739273122 4.5 10.2288186905 126.84305281 1 15 16 
 i 11 146.873140395 4.5 8.058 126.776428504 1 15 16 
 i 11 146.990305635 4.5 8.47393118833 126.552857007 1 15 16 
 i 11 147.122273782 4.5 8.2288186905 126.329285511 1 15 16 
 i 11 148.377333066 4.5 8.05889368905 126.105714015 1 15 16 
 i 11 148.497299595 4.5 8.2288186905 125.882142519 1 15 16 
 i 11 148.629940815 4.5 8.64385618977 125.658571022 1 15 16 
 i 11 148.746079335 4.5 8.38082178394 125.434999526 1 15 16 
 i 11 148.880476782 4.5 8.2288186905 125.21142803 1 15 16 
 i 11 149.006007963 4.5 8.38082178394 124.987856534 1 15 16 
 i 11 149.120669239 4.5 8.79585928322 124.764285037 1 15 16 
 i 11 149.256421516 4.5 8.55074678538 124.540713541 1 15 16 
 i 11 149.372203161 4.5 8.38082178394 124.317142045 1 15 16 
 i 11 149.497518142 4.5 8.55074678538 124.093570549 1 15 16 
 i 11 149.623721395 4.5 8.96578428466 123.869999052 1 15 16 
 i 11 149.754678696 4.5 8.70274987883 123.646427556 1 15 16 
 i 11 149.882763852 4.5 8.55074678538 123.42285606 1 15 16 
 i 11 149.992393658 4.5 8.70274987883 123.199284564 1 15 16 
 i 11 150.133221764 4.5 9.11778737811 122.975713067 1 15 16 
 i 11 150.239414682 4.5 8.88896868761 122.752141571 1 15 16 
 i 11 150.375162216 4.5 8.70274987883 122.528570075 1 15 16 
 i 11 150.49662864 4.5 8.88896868761 122.304998579 1 15 16 
 i 11 150.622448856 4.5 9.30400618689 122.081427082 1 15 16 
 i 11 150.741304683 4.5 9.05889368905 121.857855586 1 15 16 
 i 11 150.880703983 4.5 8.88896868761 118.727854655 1 15 16 
 i 11 151.004389831 4.5 9.05889368905 118.504283158 1 15 16 
 i 11 151.132742546 4.5 9.47393118833 118.280711662 1 15 16 
 i 11 151.248379169 4.5 9.2288186905 118.057140166 1 15 16 
 i 11 151.379678691 4.5 9.05889368905 117.83356867 1 15 16 
 i 11 151.491138055 4.5 9.2288186905 117.609997173 1 15 16 
 i 11 151.615476877 4.5 9.64385618977 117.386425677 1 15 16 
 i 11 151.756982584 4.5 9.38082178394 117.162854181 1 15 16 
 i 11 151.885172369 4.5 8.88897 116.939282684 1 15 16 
 i 11 152.008207296 4.5 9.30400618689 116.715711188 1 15 16 
 i 11 152.121749647 4.5 9.05889368905 116.492139692 1 15 16 
 i 11 155.382582279 4.5 8.88896868761 116.268568196 1 15 16 
 i 11 155.492564138 4.5 9.05889368905 116.044996699 1 15 16 
 i 11 155.62622942 4.5 9.47393118833 115.821425203 1 15 16 
 i 11 155.747268359 4.5 9.2288186905 115.597853707 1 15 16 
 i 11 155.870439383 4.5 9.05889368905 115.374282211 1 15 16 
 i 11 155.993259995 4.5 9.2288186905 115.150710714 1 15 16 
 i 11 156.134695203 4.5 9.64385618977 114.927139218 1 15 16 
 i 11 156.252275167 4.5 9.38082178394 114.703567722 1 15 16 
 i 11 156.379555265 4.5 9.2288186905 114.479996226 1 15 16 
 i 11 156.503410838 4.5 9.38082178394 114.256424729 1 15 16 
 i 11 156.622648082 4.5 9.79585928322 114.032853233 1 15 16 
 i 11 156.751397761 4.5 9.55074678538 113.809281737 1 15 16 
 i 11 156.877865825 4.5 9.38082178394 110.679280805 1 15 16 
 i 11 157.005296801 4.5 9.55074678538 110.455709309 1 15 16 
 i 11 157.133895997 4.5 9.96578428466 110.232137813 1 15 16 
 i 11 157.259662737 4.5 9.70274987883 110.008566317 1 15 16 
 i 11 157.383109498 4.5 9.55074678538 109.78499482 1 15 16 
 i 11 157.509845775 4.5 9.70274987883 109.561423324 1 15 16 
 i 11 157.614799393 4.5 10.1177873781 109.337851828 1 15 16 
 i 11 157.75185008 4.5 9.88896868761 109.114280332 1 15 16 
 i 11 157.879654649 4.5 9.70274987883 108.890708835 1 15 16 
 i 11 157.996561663 4.5 9.88896868761 108.667137339 1 15 16 
 i 11 158.133168292 4.5 10.3040061869 108.443565843 1 15 16 
 i 11 158.244029855 4.5 10.0588936891 108.219994347 1 15 16 
 i 11 158.367505324 4.5 9.88896868761 107.99642285 1 15 16 
 i 11 158.506781801 4.5 10.0588936891 107.772851354 1 15 16 
 i 11 158.629459784 4.5 10.4739311883 107.549279858 1 15 16 
 i 11 158.740438605 4.5 10.2288186905 107.325708361 1 15 16 
 i 11 158.873287707 4.5 8.058 107.102136865 1 15 16 
 i 11 159.007057781 4.5 8.47393118833 106.878565369 1 15 16 
 i 11 159.116482537 4.5 8.2288186905 106.654993873 1 15 16 
 i 11 160.369372419 4.5 8.05889368905 106.431422376 1 15 16 
 i 11 160.506120439 4.5 8.2288186905 106.20785088 1 15 16 
 i 11 160.620609222 4.5 8.64385618977 105.984279384 1 15 16 
 i 11 160.753259135 4.5 8.38082178394 105.760707888 1 15 16 
 i 11 160.870293661 4.5 8.2288186905 102.630706956 1 15 16 
 i 11 161.006021942 4.5 8.38082178394 102.40713546 1 15 16 
 i 11 161.115693612 4.5 8.79585928322 102.183563964 1 15 16 
 i 11 161.240519162 4.5 8.55074678538 101.959992467 1 15 16 
 i 11 161.372140179 4.5 8.38082178394 101.736420971 1 15 16 
 i 11 161.510268783 4.5 8.55074678538 101.512849475 1 15 16 
 i 11 161.630870361 4.5 8.96578428466 101.289277979 1 15 16 
 i 11 161.745720819 4.5 8.70274987883 101.065706482 1 15 16 
 i 11 161.871540742 4.5 8.55074678538 100.842134986 1 15 16 
 i 11 161.994734763 4.5 8.70274987883 100.61856349 1 15 16 
 i 11 162.115035661 4.5 9.11778737811 100.394991994 1 15 16 
 i 11 162.256118784 4.5 8.88896868761 100.171420497 1 15 16 
 i 11 162.36483632 4.5 8.70274987883 99.9478490011 1 15 16 
 i 11 162.493825715 4.5 8.88896868761 99.7242775048 1 15 16 
 i 11 162.618443352 4.5 9.30400618689 99.5007060085 1 15 16 
 i 11 162.745297686 4.5 9.05889368905 99.2771345123 1 15 16 
 i 11 162.880667219 4.5 8.88896868761 99.053563016 1 15 16 
 i 11 163.000067854 4.5 9.05889368905 98.8299915198 1 15 16 
 i 11 163.133820686 4.5 9.47393118833 98.6064200235 1 15 16 
 i 11 163.245370888 4.5 9.2288186905 98.3828485273 1 15 16 
 i 11 163.374104768 4.5 9.05889368905 98.159277031 1 15 16 
 i 11 163.51085472 4.5 9.2288186905 97.9357055347 1 15 16 
 i 11 163.618426966 4.5 9.64385618977 97.7121340385 1 15 16 
 i 11 163.755620894 4.5 9.38082178394 94.582133107 1 15 16 
 i 11 163.874848287 4.5 8.64386 94.3585616107 1 15 16 
 i 11 164.008504015 4.5 9.05889368905 94.1349901144 1 15 16 
 i 11 164.1247513 4.5 8.79585928322 93.9114186182 1 15 16 
 i 11 167.375553536 4.5 8.64385618977 93.6878471219 1 15 16 
 i 11 167.502550556 4.5 8.79585928322 93.4642756257 1 15 16 
 i 11 167.622590228 4.5 9.2288186905 93.2407041294 1 15 16 
 i 11 167.752657582 4.5 8.96578428466 93.0171326332 1 15 16 
 i 11 167.871196007 4.5 8.79585928322 92.7935611369 1 15 16 
 i 11 167.998039309 4.5 8.96578428466 92.5699896406 1 15 16 
 i 11 168.124025985 4.5 9.38082178394 92.3464181444 1 15 16 
 i 11 168.256808445 4.5 9.11778737811 92.1228466481 1 15 16 
 i 11 168.371127473 4.5 8.96578428466 91.8992751519 1 15 16 
 i 11 168.496902052 4.5 9.11778737811 91.6757036556 1 15 16 
 i 11 168.627253325 4.5 9.55074678538 91.4521321593 1 15 16 
 i 11 168.74452771 4.5 9.30400618689 91.2285606631 1 15 16 
 i 11 168.870074286 4.5 9.11778737811 91.0049891668 1 15 16 
 i 11 168.998087678 4.5 9.30400618689 90.7814176706 1 15 16 
 i 11 169.116983507 4.5 9.70274987883 90.5578461743 1 15 16 
 i 11 169.251227027 4.5 9.47393118833 90.3342746781 1 15 16 
 i 11 169.367525872 4.5 9.30400618689 90.1107031818 1 15 16 
 i 11 169.503914771 4.5 9.47393118833 89.8871316855 1 15 16 
 i 11 169.630684466 4.5 9.88896868761 89.6635601893 1 15 16 
 i 11 169.756360427 4.5 9.64385618977 86.5335592578 1 15 16 
 i 11 169.871228693 4.5 9.47393118833 86.3099877615 1 15 16 
 i 11 170.006258634 4.5 9.64385618977 86.0864162652 1 15 16 
 i 11 170.127554037 4.5 10.0588936891 85.862844769 1 15 16 
 i 11 170.246377324 4.5 9.79585928322 85.6392732727 1 15 16 
 i 11 170.379372844 4.5 9.64385618977 85.4157017765 1 15 16 
 i 11 170.501733527 4.5 9.79585928322 85.1921302802 1 15 16 
 i 11 170.619905156 4.5 10.2288186905 84.968558784 1 15 16 
 i 11 170.75897818 4.5 9.96578428466 84.7449872877 1 15 16 
 i 11 170.874428537 4.5 7.88897 84.5214157914 1 15 16 
 i 11 171.008861081 4.5 8.2288186905 84.2978442952 1 15 16 
 i 11 171.13027678 4.5 8.64385618977 84.0742727989 1 15 16 
 i 11 118.414938393 4.5 8.38082178394 83.8507013027 -1 15 16 
 i 11 118.583247003 4.5 8.2288186905 83.6271298064 -1 15 16 
 i 11 118.748956396 4.5 8.05889368905 83.4035583102 -1 15 16 
 i 11 118.921341074 4.5 8.2288186905 83.1799868139 -1 15 16 
 i 11 119.09355602 4.5 8.64385618977 82.9564153176 -1 15 16 
 i 11 119.255479642 4.5 8.38082178394 82.7328438214 -1 15 16 
 i 11 119.418994433 4.5 8.2288186905 82.5092723251 -1 15 16 
 i 11 119.588974096 4.5 8.05889368905 82.2857008289 -1 15 16 
 i 11 119.748088651 4.5 8.2288186905 82.0621293326 -1 15 16 
 i 11 119.912139433 4.5 8.64385618977 81.8385578363 -1 15 16 
 i 11 120.073999333 4.5 8.38082178394 81.6149863401 -1 15 16 
 i 11 120.241494552 4.5 8.2288186905 78.4849854086 -1 15 16 
 i 11 120.410695725 4.5 8.05889368905 78.2614139123 -1 15 16 
 i 11 120.590016609 4.5 8.2288186905 78.0378424161 -1 15 16 
 i 11 120.757057331 4.5 8.64385618977 77.8142709198 -1 15 16 
 i 11 120.925339442 4.5 8.38082178394 77.5906994235 -1 15 16 
 i 11 121.078103201 4.5 8.2288186905 77.3671279273 -1 15 16 
 i 11 121.251749784 4.5 8.05889368905 77.143556431 -1 15 16 
 i 11 121.410585938 4.5 8.2288186905 76.9199849348 -1 15 16 
 i 11 121.578366919 4.5 8.64385618977 76.6964134385 -1 15 16 
 i 11 121.754512887 4.5 8.47393 76.4728419422 -1 15 16 
 i 11 121.919634046 4.5 8.64385618977 76.249270446 -1 15 16 
 i 11 122.083709969 4.5 9.05889368905 76.0256989497 -1 15 16 
 i 11 124.415407909 4.5 8.79585928322 75.8021274535 -1 15 16 
 i 11 124.58836045 4.5 8.64385618977 75.5785559572 -1 15 16 
 i 11 124.751465143 4.5 8.47393118833 75.354984461 -1 15 16 
 i 11 124.924643836 4.5 8.64385618977 75.1314129647 -1 15 16 
 i 11 125.091306281 4.5 9.05889368905 74.9078414684 -1 15 16 
 i 11 125.243986507 4.5 8.79585928322 74.6842699722 -1 15 16 
 i 11 125.415443236 4.5 8.64385618977 74.4606984759 -1 15 16 
 i 11 125.57247462 4.5 8.47393118833 74.2371269797 -1 15 16 
 i 11 125.744371073 4.5 8.64385618977 74.0135554834 -1 15 16 
 i 11 125.919729574 4.5 9.05889368905 73.7899839872 -1 15 16 
 i 11 126.081312799 4.5 8.79585928322 73.5664124909 -1 15 16 
 i 11 126.244020396 4.5 8.64385618977 70.4364115594 -1 15 16 
 i 11 126.42595443 4.5 8.47393118833 70.2128400631 -1 15 16 
 i 11 126.587863029 4.5 8.64385618977 127 -1 15 16 
 i 11 126.759335652 4.5 9.05889368905 127 -1 15 16 
 i 11 126.920749765 4.5 8.79585928322 127 -1 15 16 
 i 11 127.078810618 4.5 8.64385618977 127 -1 15 16 
 i 11 127.257896048 4.5 8.47393118833 127 -1 15 16 
 i 11 127.425749697 4.5 8.64385618977 127 -1 15 16 
 i 11 127.574891156 4.5 9.05889368905 127 -1 15 16 
 i 11 127.759184363 4.5 7.88897 127 -1 15 16 
 i 11 127.909627866 4.5 8.2288186905 127 -1 15 16 
 i 11 128.074643221 4.5 8.64385618977 127 -1 15 16 
 i 11 130.417696386 4.5 8.38082178394 127 -1 15 16 
 i 11 130.582374876 4.5 8.2288186905 127 -1 15 16 
 i 11 130.756458259 4.5 8.05889368905 127 -1 15 16 
 i 11 130.927426186 4.5 8.2288186905 72.3513060711 -1 15 16 
 i 11 131.083413885 4.5 8.64385618977 72.5321757702 -1 15 16 
 i 11 131.243577911 4.5 8.38082178394 72.7130454693 -1 15 16 
 i 11 131.418512597 4.5 8.2288186905 72.8939151684 -1 15 16 
 i 11 131.578320503 4.5 8.05889368905 73.0747848675 -1 15 16 
 i 11 131.741160782 4.5 8.2288186905 73.2556545666 -1 15 16 
 i 11 131.913685835 4.5 8.64385618977 73.4365242657 -1 15 16 
 i 11 132.072741797 4.5 8.38082178394 73.6173939648 -1 15 16 
 i 11 132.251125225 4.5 8.2288186905 73.7982636639 -1 15 16 
 i 11 132.418625951 4.5 8.05889368905 73.979133363 -1 15 16 
 i 11 132.581877749 4.5 8.2288186905 74.1600030621 -1 15 16 
 i 11 132.74900043 4.5 8.64385618977 74.3408727613 -1 15 16 
 i 11 132.913500888 4.5 8.38082178394 74.5217424604 -1 15 16 
 i 11 133.07312403 4.5 8.2288186905 74.7026121595 -1 15 16 
 i 11 133.252789189 4.5 8.05889368905 74.8834818586 -1 15 16 
 i 11 133.4210245 4.5 8.2288186905 75.0643515577 -1 15 16 
 i 11 133.576217319 4.5 8.64385618977 75.2452212568 -1 15 16 
 i 11 133.744638558 4.5 8.47393 75.4260909559 -1 15 16 
 i 11 133.920456941 4.5 8.64385618977 75.606960655 -1 15 16 
 i 11 134.091582977 4.5 9.05889368905 75.7878303541 -1 15 16 
 i 11 136.40946444 4.5 8.79585928322 75.9687000532 -1 15 16 
 i 11 136.572871145 4.5 8.64385618977 76.1495697523 -1 15 16 
 i 11 136.742451283 4.5 8.47393118833 76.3304394515 -1 15 16 
 i 11 136.916035709 4.5 8.64385618977 83.2034879308 -1 15 16 
 i 11 137.093649051 4.5 9.05889368905 83.3843576299 -1 15 16 
 i 11 137.258860562 4.5 8.79585928322 83.565227329 -1 15 16 
 i 11 137.414095466 4.5 8.64385618977 83.7460970281 -1 15 16 
 i 11 137.576070761 4.5 8.47393118833 83.9269667272 -1 15 16 
 i 11 137.744085916 4.5 8.64385618977 84.1078364263 -1 15 16 
 i 11 137.914475789 4.5 9.05889368905 84.2887061254 -1 15 16 
 i 11 138.072462342 4.5 8.79585928322 84.4695758245 -1 15 16 
 i 11 138.245892992 4.5 8.64385618977 84.6504455236 -1 15 16 
 i 11 138.426963774 4.5 8.47393118833 84.8313152228 -1 15 16 
 i 11 138.592881519 4.5 8.64385618977 85.0121849219 -1 15 16 
 i 11 138.745977561 4.5 9.05889368905 85.193054621 -1 15 16 
 i 11 138.911436606 4.5 8.79585928322 85.3739243201 -1 15 16 
 i 11 139.082155601 4.5 8.64385618977 85.5547940192 -1 15 16 
 i 11 139.247599645 4.5 8.47393118833 85.7356637183 -1 15 16 
 i 11 139.409113797 4.5 8.64385618977 85.9165334174 -1 15 16 
 i 11 139.593018977 4.5 9.05889368905 86.0974031165 -1 15 16 
 i 11 139.742236385 4.5 7.88897 86.2782728156 -1 15 16 
 i 11 139.905697625 4.5 8.2288186905 86.4591425147 -1 15 16 
 i 11 140.091815578 4.5 8.64385618977 86.6400122138 -1 15 16 
 i 11 142.409130975 4.5 8.38082178394 86.820881913 -1 15 16 
 i 11 142.57581402 4.5 8.2288186905 87.0017516121 -1 15 16 
 i 11 142.744339001 4.5 8.05889368905 87.1826213112 -1 15 16 
 i 11 142.924444433 4.5 8.2288186905 98.3965425344 -1 15 16 
 i 11 143.087631617 4.5 8.64385618977 98.5774122335 -1 15 16 
 i 11 143.255504962 4.5 8.38082178394 98.7582819326 -1 15 16 
 i 11 143.420795173 4.5 8.2288186905 98.9391516317 -1 15 16 
 i 11 143.579537525 4.5 8.05889368905 99.1200213308 -1 15 16 
 i 11 143.74896442 4.5 8.2288186905 99.3008910299 -1 15 16 
 i 11 143.913492881 4.5 8.64385618977 99.481760729 -1 15 16 
 i 11 144.075141584 4.5 8.38082178394 99.6626304281 -1 15 16 
 i 11 144.258524174 4.5 8.2288186905 99.8435001273 -1 15 16 
 i 11 144.416895515 4.5 8.05889368905 100.024369826 -1 15 16 
 i 11 144.593262741 4.5 8.2288186905 100.205239525 -1 15 16 
 i 11 144.741285888 4.5 8.64385618977 100.386109225 -1 15 16 
 i 11 144.920133225 4.5 8.38082178394 100.566978924 -1 15 16 
 i 11 145.086994069 4.5 8.2288186905 100.747848623 -1 15 16 
 i 11 145.244799876 4.5 8.05889368905 100.928718322 -1 15 16 
 i 11 145.422990897 4.5 8.2288186905 101.109588021 -1 15 16 
 i 11 145.575775547 4.5 8.64385618977 101.29045772 -1 15 16 
 i 11 145.755324867 4.5 8.47393 101.471327419 -1 15 16 
 i 11 145.90778797 4.5 8.64385618977 101.652197118 -1 15 16 
 i 11 146.090116324 4.5 9.05889368905 101.833066817 -1 15 16 
 i 11 148.423706485 4.5 8.79585928322 102.013936517 -1 15 16 
 i 11 148.593245395 4.5 8.64385618977 102.194806216 -1 15 16 
 i 11 148.752006813 4.5 8.47393118833 102.375675915 -1 15 16 
 i 11 148.907416046 4.5 8.64385618977 109.248724394 -1 15 16 
 i 11 149.081792997 4.5 9.05889368905 109.429594093 -1 15 16 
 i 11 149.258839684 4.5 8.79585928322 109.610463792 -1 15 16 
 i 11 149.425923289 4.5 8.64385618977 109.791333491 -1 15 16 
 i 11 149.585244233 4.5 8.47393118833 109.972203191 -1 15 16 
 i 11 149.739385707 4.5 8.64385618977 110.15307289 -1 15 16 
 i 11 149.916019447 4.5 9.05889368905 110.333942589 -1 15 16 
 i 11 150.080200972 4.5 8.79585928322 110.514812288 -1 15 16 
 i 11 150.249931824 4.5 8.64385618977 110.695681987 -1 15 16 
 i 11 150.407148689 4.5 8.47393118833 110.876551686 -1 15 16 
 i 11 150.58127539 4.5 8.64385618977 111.057421385 -1 15 16 
 i 11 150.757229058 4.5 9.05889368905 111.238291084 -1 15 16 
 i 11 150.924314414 4.5 8.79585928322 111.419160783 -1 15 16 
 i 11 151.083183232 4.5 8.64385618977 111.600030483 -1 15 16 
 i 11 151.249525304 4.5 8.47393118833 111.780900182 -1 15 16 
 i 11 151.408926466 4.5 8.64385618977 111.961769881 -1 15 16 
 i 11 151.575539737 4.5 9.05889368905 112.14263958 -1 15 16 
 i 11 151.743747754 4.5 7.88897 112.323509279 -1 15 16 
 i 11 151.926036673 4.5 8.2288186905 112.504378978 -1 15 16 
 i 11 152.091541341 4.5 8.64385618977 112.685248677 -1 15 16 
 i 11 154.414990693 4.5 8.38082178394 112.866118376 -1 15 16 
 i 11 154.593596856 4.5 8.2288186905 113.046988075 -1 15 16 
 i 11 154.748842636 4.5 8.05889368905 113.227857775 -1 15 16 
 i 11 154.90708326 4.5 8.2288186905 124.441778998 -1 15 16 
 i 11 155.093536846 4.5 8.64385618977 124.622648697 -1 15 16 
 i 11 155.25772893 4.5 8.38082178394 124.803518396 -1 15 16 
 i 11 155.4240712 4.5 8.2288186905 124.984388095 -1 15 16 
 i 11 155.575622425 4.5 8.05889368905 125.165257794 -1 15 16 
 i 11 155.745154305 4.5 8.2288186905 125.346127493 -1 15 16 
 i 11 155.915523621 4.5 8.64385618977 125.526997192 -1 15 16 
 i 11 156.086538183 4.5 8.38082178394 125.707866891 -1 15 16 
 i 11 156.256528862 4.5 8.2288186905 125.888736591 -1 15 16 
 i 11 156.411568603 4.5 8.05889368905 126.06960629 -1 15 16 
 i 11 156.588723186 4.5 8.2288186905 126.250475989 -1 15 16 
 i 11 156.744173703 4.5 8.64385618977 126.431345688 -1 15 16 
 i 11 156.921422621 4.5 8.38082178394 126.612215387 -1 15 16 
 i 11 157.09091387 4.5 8.2288186905 126.793085086 -1 15 16 
 i 11 157.247689302 4.5 8.05889368905 126.973954785 -1 15 16 
 i 11 157.420844052 4.5 8.2288186905 126.728695454 -1 15 16 
 i 11 157.578355155 4.5 8.64385618977 126.457390907 -1 15 16 
 i 11 157.749968059 4.5 8.47393 126.186086361 -1 15 16 
 i 11 157.924772776 4.5 8.64385618977 125.914781814 -1 15 16 
 i 11 158.090500037 4.5 9.05889368905 125.643477268 -1 15 16 
 i 11 160.419901687 4.5 8.79585928322 125.372172721 -1 15 16 
 i 11 160.574963785 4.5 8.64385618977 125.100868175 -1 15 16 
 i 11 160.745825097 4.5 8.47393118833 124.829563628 -1 15 16 
 i 11 160.919633568 4.5 8.64385618977 124.558259082 -1 15 16 
 i 11 161.086512497 4.5 9.05889368905 124.286954535 -1 15 16 
 i 11 161.258639912 4.5 8.79585928322 124.015649989 -1 15 16 
 i 11 161.413715332 4.5 8.64385618977 123.744345442 -1 15 16 
 i 11 161.590085109 4.5 8.47393118833 123.473040896 -1 15 16 
 i 11 161.748002341 4.5 8.64385618977 123.201736349 -1 15 16 
 i 11 161.915808615 4.5 9.05889368905 122.930431803 -1 15 16 
 i 11 162.081332274 4.5 8.79585928322 113.706077222 -1 15 16 
 i 11 162.246641837 4.5 8.64385618977 113.434772675 -1 15 16 
 i 11 162.426813131 4.5 8.47393118833 113.163468129 -1 15 16 
 i 11 162.58676154 4.5 8.64385618977 112.892163582 -1 15 16 
 i 11 162.744494177 4.5 9.05889368905 112.620859036 -1 15 16 
 i 11 162.917262507 4.5 8.79585928322 112.349554489 -1 15 16 
 i 11 163.082446224 4.5 8.64385618977 112.078249943 -1 15 16 
 i 11 163.250754285 4.5 8.47393118833 111.806945396 -1 15 16 
 i 11 163.421832676 4.5 8.64385618977 111.53564085 -1 15 16 
 i 11 163.593301794 4.5 9.05889368905 111.264336303 -1 15 16 
 i 11 163.74886829 4.5 7.79586 110.993031757 -1 15 16 
 i 11 163.926690334 4.5 8.47393 110.72172721 -1 15 16 
 i 11 164.085477545 4.5 8.38082 110.450422664 -1 15 16 
 i 11 168.580380301 6 7.79586 110.179118117 -1 3 4 
 i 11 174.575387833 6 8.47393 109.907813571 -1 3 4 
 i 11 180.576191721 6 8.64386 100.68345899 -1 3 4 
 i 11 186.583446439 6 8.22882 100.412154444 -1 3 4 
 i 11 192.572385994 6 8.22882 100.140849897 -1 3 4 
 i 11 198.57545461 6 8.64386 99.8695453507 -1 3 4 
 i 11 169.593988878 6 8.64386 99.5982408042 1 3 4 
 i 11 174.573458201 6 8.22882 99.3269362577 1 3 4 
 i 11 181.593545731 6 8.64386 99.0556317112 1 3 4 
 i 11 186.572538691 6 8.79585928322 98.7843271647 1 3 4 
 i 11 193.589520119 6 8.47393118833 98.5130226182 1 3 4 
 i 11 198.57770837 6 8.38082178394 98.2417180717 1 3 4 
 i 11 205.590606041 6 8.55074678538 97.9704135252 1 3 4 
 i 11 169.656582829 4.5 8.2288186905 97.6991089788 1 15 16 
 i 11 169.748141429 4.5 8.11778737811 97.4278044323 1 15 16 
 i 11 169.828602667 4.5 8.30400618689 97.1564998858 1 15 16 
 i 11 169.925019466 4.5 12.7958592832 96.8851953393 1 15 16 
 i 11 170.005821965 4.5 12.7027498788 87.6608407585 1 15 16 
 i 11 170.080032786 4.5 8.05889368905 87.389536212 1 15 16 
 i 11 170.1656007 4.5 12.5507467854 87.1182316655 1 15 16 
 i 11 170.24891332 4.5 12.4739311883 86.846927119 1 15 16 
 i 11 170.332438606 4.5 12.6438561898 86.5756225725 1 15 16 
 i 11 170.419164646 4.5 12.3040061869 86.304318026 1 15 16 
 i 11 170.49177063 4.5 12.2288186905 86.0330134796 1 15 16 
 i 11 170.581104497 4.5 12.3808217839 85.7617089331 1 15 16 
 i 11 170.675599827 4.5 12.0588936891 85.4904043866 1 15 16 
 i 11 170.739070562 4.5 11.9657842847 85.2190998401 1 15 16 
 i 11 170.827884562 4.5 12.1177873781 84.9477952936 1 15 16 
 i 11 170.9135545 4.5 11.7958592832 84.6764907471 1 15 16 
 i 11 170.99625049 4.5 11.7027498788 84.4051862006 1 15 16 
 i 11 171.085806312 4.5 11.8889686876 84.1338816541 1 15 16 
 i 11 171.171731876 4.5 8.22882 83.8625771076 1 15 16 
 i 11 171.25739587 4.5 8.38082178394 74.6382225268 1 15 16 
 i 11 171.334648462 4.5 8.05889368905 74.3669179804 1 15 16 
 i 11 171.409280527 4.5 12.7958592832 74.0956134339 1 15 16 
 i 11 171.498100909 4.5 8.11778737811 73.8243088874 1 15 16 
 i 11 174.666813691 4.5 12.6438561898 73.5530043409 1 15 16 
 i 11 174.740456122 4.5 12.5507467854 73.2816997944 1 15 16 
 i 11 174.823310233 4.5 12.7027498788 73.0103952479 1 15 16 
 i 11 174.910811976 4.5 12.3808217839 72.7390907014 1 15 16 
 i 11 174.990548454 4.5 12.3040061869 72.4677861549 1 15 16 
 i 11 175.083035342 4.5 12.4739311883 72.1964816084 1 15 16 
 i 11 175.173397373 4.5 12.1177873781 71.9251770619 1 15 16 
 i 11 175.256630731 4.5 12.0588936891 71.6538725154 1 15 16 
 i 11 175.326175014 4.5 12.2288186905 71.3825679689 1 15 16 
 i 11 175.411411428 4.5 11.8889686876 71.1112634224 1 15 16 
 i 11 175.492202958 4.5 11.7958592832 70.8399588759 1 15 16 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR1	   3  	4  0.6 	 81 ;base.
$MIXDUR1	   15  	16  0.3  82 ;ornaments

;alto_flute
 i 25 0.00973945139397 6.08 75 8.05889 1 -1 5 6 
 i 25 6.00239610989 6.08 75 8.22882 1 -1 5 6 
 i 25 11.9942840413 6.08 75 8.05889 1 -1 5 6 
 i 25 18.0096183637 6.08 75 8.22882 1 -1 5 6 
 i 25 24.0096638582 6.08 75 8.05889 1 -1 5 6 
 i 25 30.0081833476 6.08 75 8.22882 1 -1 5 6 
 i 25 36.0035669585 6.08 75 8.05889 1 -1 5 6 
 i 25 41.9998082326 6.08 75 8.22882 1 -1 5 6 
 i 25 48.0074555873 6.08 75 8.05889 1 -1 5 6 
 i 25 53.9994510871 6.08 75 8.22882 1 -1 5 6 
 i 25 60.0003244174 6.08 75 8.05889 1 -1 5 6 
 i 25 66.0103299247 6.08 75 8.22882 1 -1 5 6 
 i 25 71.9977843492 6.08 75 8.05889 1 -1 5 6 
 i 25 77.990501301 6.08 75 8.22882 1 -1 5 6 
 i 25 83.9926800703 6.08 75 8.05889 1 -1 5 6 
 i 25 90.009312459 6.08 75 8.22882 1 -1 5 6 
 i 25 96.0022505084 6.08 75 8.05889 1 -1 5 6 
 i 25 102.006527859 6.08 75 8.22882 1 -1 5 6 
 i 25 108.006442051 6.08 75 8.05889 1 -1 5 6 
 i 25 113.996223268 6.08 75 8.64386 1 -1 5 6 
 i 25 0.990363138625 5.08 75 8.79586 0.5 1 5 6 
 i 25 5.98964878606 7.08 75 8.22882 0.5 1 5 6 
 i 25 12.9964181793 5.08 75 8.05889 0.5 1 5 6 
 i 25 18.0103317538 7.08 75 8.79586 0.5 1 5 6 
 i 25 25.0109887112 5.08 75 8.22882 0.5 1 5 6 
 i 25 29.9984519483 7.08 75 8.05889 0.5 1 5 6 
 i 25 36.9996848951 5.08 75 8.64386 0.5 1 5 6 
 i 25 42.0026465358 7.08 75 8.22882 0.5 1 5 6 
 i 25 48.9930695384 5.08 75 8.05889 0.5 1 5 6 
 i 25 53.99042868 7.08 75 8.64386 0.5 1 5 6 
 i 25 60.9940798155 5.08 75 8.79586 0.5 1 5 6 
 i 25 65.9954820155 7.08 75 8.05889 0.5 1 5 6 
 i 25 72.9954264148 5.08 75 8.64386 0.5 1 5 6 
 i 25 78.0021641063 7.08 75 8.79586 0.5 1 5 6 
 i 25 84.9986292068 5.08 75 8.22882 0.5 1 5 6 
 i 25 89.9997299488 7.08 75 8.64386 0.5 1 5 6 
 i 25 96.9917250311 5.08 75 8.79586 0.5 1 5 6 
 i 25 102.005202423 7.08 75 8.22882 0.5 1 5 6 
 i 25 108.995931774 5.08 75 8.05889 0.5 1 5 6 
 i 25 113.99371369 7.08 75 7.88897 0.5 1 5 6 
 i 25 121.006618047 7.08 75 8.47393 0.5 1 5 6 
 i 25 128.082514075 6.08 75 7.88897 1 -1 5 6 
 i 25 134.08340653 6.08 75 8.47393 1 -1 5 6 
 i 25 140.072601633 6.08 75 7.88897 1 -1 5 6 
 i 25 146.074581692 6.08 75 8.47393 1 -1 5 6 
 i 25 152.089885563 6.08 75 7.88897 1 -1 5 6 
 i 25 158.080999647 6.08 75 8.47393 1 -1 5 6 
 i 25 164.081778851 6.08 75 8.058 1 -1 5 6 
 i 25 170.08300315 6.08 75 8.64386 1 -1 5 6 
 i 25 176.083727703 6.08 75 8.88897 1 -1 5 6 
 i 25 129.083266314 5.08 75 8.64386 0.5 1 5 6 
 i 25 134.083475114 7.08 75 8.88897 0.5 1 5 6 
 i 25 141.072754873 5.08 75 8.058 0.5 1 5 6 
 i 25 146.073509532 7.08 75 8.88897 0.5 1 5 6 
 i 25 153.072762125 5.08 75 8.058 0.5 1 5 6 
 i 25 158.089403106 7.08 75 8.64386 0.5 1 5 6 
 i 25 165.078579049 5.08 75 7.79586 0.5 1 5 6 
 i 25 170.082348267 7.08 75 8.47393 0.5 1 5 6 
 i 25 177.08568103 7.08 75 8.38082 0.5 1 5 6 
 i 25 184.154524539 6.08 75 7.79586 1 -1 5 6 
 i 25 190.165292441 6.08 75 8.47393 1 -1 5 6 
 i 25 196.165042533 6.08 75 8.22882 1 -1 5 6 
 i 25 202.157173854 6.08 75 8.64386 1 -1 5 6 
 i 25 208.163775059 6.08 75 8.64386 1 -1 5 6 
 i 25 214.160460879 6.08 75 8.22882 1 -1 5 6 
 i 25 185.169929188 5.08 75 8.22882 0.5 1 5 6 
 i 25 190.155454803 7.08 75 8.64386 0.5 1 5 6 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR1	   5  	6  0.55  85 ;problem with amps on cs32
$MIXDUR1	   17  	18  0.45  86 ;ornaments work ok

;#Section A strings
 i 386 0.00489695763127 6 75 8.05889 -1 0 7 8 
 i 386 6.00181633575 6 75 8.22882 -1 0 7 8 
 i 386 12.0061051399 6 75 8.05889 -1 0 7 8 
 i 386 18.0022069094 6 75 8.22882 -1 0 7 8 
 i 386 24.0097106457 6 75 8.05889 -1 0 7 8 
 i 386 29.990184056 6 75 8.22882 -1 0 7 8 
 i 386 36.0066409421 6 75 8.05889 -1 0 7 8 
 i 386 42.0077994884 6 75 8.22882 -1 0 7 8 
 i 386 47.9918064116 6 75 8.05889 -1 0 7 8 
 i 386 53.9906939557 6 75 8.22882 -1 0 7 8 
 i 386 60.0061694056 6 75 8.05889 -1 0 7 8 
 i 386 65.9912057511 6 75 8.22882 -1 0 7 8 
 i 386 72.0066267999 6 75 8.05889 -1 0 7 8 
 i 386 77.9941307111 6 75 8.22882 -1 0 7 8 
 i 386 83.9942876791 6 75 8.05889 -1 0 7 8 
 i 386 90.0017570235 6 75 8.22882 -1 0 7 8 
 i 386 95.9990485645 6 75 8.05889 -1 0 7 8 
 i 386 101.999578913 6 75 8.22882 -1 0 7 8 
 i 386 108.007791542 6 75 8.05889 -1 0 7 8 
 i 386 114.000730409 6 75 7.22882 -1 0 7 8 
 i 386 0.00424490950899 6 75 8.05889 1 0 7 8 
 i 386 5.99628565274 6 75 7.64386 1 0 7 8 
 i 386 12.0026200512 6 75 7.79586 1 0 7 8 
 i 386 17.9943609536 6 75 8.64386 1 0 7 8 
 i 386 24.0030434731 6 75 7.22882 1 0 7 8 
 i 386 30.0095238295 6 75 8.05889 1 0 7 8 
 i 386 36.0004604758 6 75 7.64386 1 0 7 8 
 i 386 41.9968420147 6 75 7.79586 1 0 7 8 
 i 386 47.9920197001 6 75 8.64386 1 0 7 8 
 i 386 54.0017222955 6 75 7.22882 1 0 7 8 
 i 386 60.0108610688 6 75 8.05889 1 0 7 8 
 i 386 66.0044373697 6 75 7.64386 1 0 7 8 
 i 386 72.0020263676 6 75 7.79586 1 0 7 8 
 i 386 77.9996422492 6 75 8.64386 1 0 7 8 
 i 386 83.9967804332 6 75 7.22882 1 0 7 8 
 i 386 89.991029667 6 75 8.05889 1 0 7 8 
 i 386 96.0090113897 6 75 7.64386 1 0 7 8 
 i 386 102.009949787 6 75 7.79586 1 0 7 8 
 i 386 108.00400718 6 75 7.79586 1 0 7 8 
 i 386 113.996553751 6 75 7.64386 1 0 7 8 
 i 386 0.00111227824245 6 51.0 7.79586 -1.0 4 7 8 
 i 386 6.00457176612 6 52.1865595167 7.64386 -0.892130953023 4 7 8 
 i 386 12.0107351059 6 53.3731190335 7.79586 -0.784261906046 4 7 8 
 i 386 17.9963286762 6 54.5596785502 7.64386 -0.676392859069 4 7 8 
 i 386 23.9923631852 6 55.746238067 7.79586 -0.568523812092 4 7 8 
 i 386 30.0000283083 6 56.9327975837 7.64386 -0.460654765115 4 7 8 
 i 386 35.9986372359 6 58.1193571005 7.79586 -0.352785718138 4 7 8 
 i 386 41.9987386083 6 59.3059166172 7.64386 -0.244916671161 4 7 8 
 i 386 47.9921673036 6 60.492476134 7.79586 -0.137047624184 4 7 8 
 i 386 53.9901559045 6 61.6790356507 7.64386 -0.0291785772073 4 7 8 
 i 386 59.9930707574 6 62.8655951675 7.79586 0.0786904697697 4 7 8 
 i 386 66.0016003286 6 64.0521546842 7.64386 0.186559516747 4 7 8 
 i 386 71.996024779 6 65.238714201 7.79586 0.294428563724 4 7 8 
 i 386 77.9980987273 6 66.4252737177 7.64386 0.402297610701 4 7 8 
 i 386 84.0040074555 6 67.6118332345 7.79586 0.510166657678 4 7 8 
 i 386 90.0101860818 6 68.7983927512 7.64386 0.618035704655 4 7 8 
 i 386 95.9913357952 6 69.9849522679 7.79586 0.725904751632 4 7 8 
 i 386 102.006721445 6 71.1715117847 7.22882 0.833773798608 4 7 8 
 i 386 108.00875625 6 72.3580713014 8.05889 0.941642845585 4 7 8 
 i 386 114.008745296 6 51.0 7.64386 1.0 4 7 8 
 i 386 0.00518315614147 6 52.1865595167 7.79586 0.892130953023 4 7 8 
 i 386 6.00181423782 6 53.3731190335 8.64386 0.784261906046 4 7 8 
 i 386 12.0022586054 6 54.5596785502 7.22882 0.676392859069 4 7 8 
 i 386 17.9959670911 6 55.746238067 8.05889 0.568523812092 4 7 8 
 i 386 24.0085014888 6 56.9327975837 7.64386 0.460654765115 4 7 8 
 i 386 30.0088009472 6 58.1193571005 7.79586 0.352785718138 4 7 8 
 i 386 35.9894508641 6 59.3059166172 8.64386 0.244916671161 4 7 8 
 i 386 41.9985796435 6 60.492476134 7.22882 0.137047624184 4 7 8 
 i 386 48.0024095725 6 61.6790356507 8.05889 0.0291785772073 4 7 8 
 i 386 53.9908424772 6 62.8655951675 7.64386 -0.0786904697697 4 7 8 
 i 386 59.9918041449 6 64.0521546842 7.79586 -0.186559516747 4 7 8 
 i 386 66.0044874193 6 65.238714201 8.64386 -0.294428563724 4 7 8 
 i 386 71.9933017344 6 66.4252737177 7.22882 -0.402297610701 4 7 8 
 i 386 78.0081311609 6 67.6118332345 8.05889 -0.510166657678 4 7 8 
 i 386 84.0012018566 6 68.7983927512 7.64386 -0.618035704655 4 7 8 
 i 386 90.0004957134 6 69.9849522679 7.79586 -0.725904751632 4 7 8 
 i 386 95.9996440519 6 71.1715117847 7.88897 -0.833773798608 4 7 8 
 i 386 102.001332591 6 72.3580713014 8.47393 -0.941642845585 4 7 8 
 i 386 108.005185326 6 75 7.88897 -1 4 7 8 
 i 386 114.001776496 6 75 8.47393 -1 4 7 8 
 i 386 120.005593259 6 75 7.88897 -1 0 7 8 
 i 386 125.99121736 6 75 8.47393 -1 0 7 8 
 i 386 131.992039858 6 75 7.88897 -1 0 7 8 
 i 386 138.003334079 6 75 8.47393 -1 0 7 8 
 i 386 144.009470382 6 75 8.058 -1 0 7 8 
 i 386 150.009339077 6 75 7.64386 -1 0 7 8 
 i 386 156.004366069 6 75 7.88897 -1 0 7 8 
 i 386 161.990432364 6 75 8.058 1 0 7 8 
 i 386 167.99816469 6 75 7.64386 1 0 7 8 
 i 386 119.992560626 6 75 7.88897 1 0 7 8 
 i 386 125.998902546 6 75 8.058 1 0 7 8 
 i 386 132.006386703 6 75 7.64386 1 0 7 8 
 i 386 137.99157714 6 75 8.22882 1 0 7 8 
 i 386 143.989655058 6 75 7.96578 1 0 7 8 
 i 386 149.993872695 6 75 8.22882 1 0 7 8 
 i 386 155.990298641 6 75 7.96578 1 0 7 8 
 i 386 162.003135281 6 51.0 8.22882 -1.0 0 7 8 
 i 386 168.009748292 6 54.1064670997 7.96578 -0.717593900028 0 7 8 
 i 386 120.001134393 6 57.2129341994 8.22882 -0.435187800056 4 7 8 
 i 386 126.003172432 6 60.3194012991 7.96578 -0.152781700085 4 7 8 
 i 386 132.005445084 6 63.4258683988 8.058 0.129624399887 4 7 8 
 i 386 138.00451611 6 66.5323354984 7.64386 0.412030499859 4 7 8 
 i 386 143.994699496 6 69.6388025981 7.88897 0.694436599831 4 7 8 
 i 386 149.993344056 6 72.7452696978 8.058 0.976842699802 4 7 8 
 i 386 155.994425378 6 51.0 7.64386 1.0 4 7 8 
 i 386 162.008700985 6 54.1064670997 7.88897 0.717593900028 4 7 8 
 i 386 168.002852426 6 57.2129341994 8.058 0.435187800056 4 7 8 
 i 386 119.996586213 6 60.3194012991 7.64386 0.152781700085 4 7 8 
 i 386 126.005276379 6 63.4258683988 7.79586 -0.129624399887 4 7 8 
 i 386 131.991229174 6 66.5323354984 8.47393 -0.412030499859 4 7 8 
 i 386 137.999292968 6 69.6388025981 8.38082 -0.694436599831 4 7 8 
 i 386 144.010667829 6 72.7452696978 7.79586 -0.976842699802 4 7 8 
 i 386 150.00845083 6 75 8.47393 -1 4 7 8 
 i 386 155.999359921 6 75 8.22882 -1 4 7 8 
 i 386 162.001430794 6 75 8.64386 -1 4 7 8 
 i 386 168.005019147 6 75 8.22882 -1 4 7 8 
 i 386 174.000433953 6 75 8.64386 -1 0 7 8 
 i 386 180.005312974 6 75 8.22882 -1 0 7 8 
 i 386 186.00393233 6 75 7.96578 1 0 7 8 
 i 386 191.991845959 6 75 7.96578 1 0 7 8 
 i 386 198.007028034 6 75 7.96578 1 0 7 8 
 i 386 204.008294688 6 75 7.96578 1 0 7 8 
 i 386 173.990974613 6 75 7.96578 1 0 7 8 
 i 386 179.999650599 6 75 8.22882 1 0 7 8 
 i 386 185.99833437 6 51.0 8.64386 -1.0 0 7 8 
 i 386 192.008045551 6 56.0262737034 8.22882 -0.543066026959 0 7 8 
 i 386 198.001510952 6 61.0525474069 8.64386 -0.0861320539182 0 7 8 
 i 386 204.00784869 6 66.0788211103 8.22882 0.370801919123 0 7 8 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR1	   7  	8  0.24  89

;#bellpno
 i 21 0.00721176652608 2 15000 7.05889 1.10123 9 10 
 i 21 5.99717313213 2 15000 7.22882 1.10123 9 10 
 i 21 12.0030819405 2 15000 7.05889 1.10123 9 10 
 i 21 17.9906210516 2 15000 7.22882 1.10123 9 10 
 i 21 24.0033944363 2 15000 7.05889 1.10123 9 10 
 i 21 29.9968213335 2 15000 7.22882 1.10123 9 10 
 i 21 36.0083352944 2 15000 7.05889 1.10123 9 10 
 i 21 41.9947505665 2 15000 7.22882 1.10123 9 10 
 i 21 47.9975609922 2 15000 7.05889 1.10123 9 10 
 i 21 53.9927612758 2 15000 7.22882 1.10123 9 10 
 i 21 60.0012676623 2 15000 7.05889 1.10123 9 10 
 i 21 66.0084873233 2 15000 7.22882 1.10123 9 10 
 i 21 72.0067238877 2 15000 7.05889 1.10123 9 10 
 i 21 77.9952077449 2 15000 7.22882 1.10123 9 10 
 i 21 83.9958531152 2 15000 7.05889 1.10123 9 10 
 i 21 90.0055080665 2 15000 7.22882 1.10123 9 10 
 i 21 96.0091299372 2 15000 7.05889 1.10123 9 10 
 i 21 102.002931198 2 15000 7.22882 1.10123 9 10 
 i 21 107.992625558 2 15000 7.05889 1.10123 9 10 
 i 21 114.010497733 2 15000 7.22882 1.10123 9 10 
 i 21 0.991515814492 2 15000 7.05889 1.10123 9 10 
 i 21 6.00401600547 2 15000 7.64386 1.10123 9 10 
 i 21 12.9994210323 2 15000 7.79586 1.10123 9 10 
 i 21 18.0041703634 2 15000 7.05889 1.10123 9 10 
 i 21 24.9947471492 2 15000 7.64386 1.10123 9 10 
 i 21 30.0039407197 2 15000 7.79586 1.10123 9 10 
 i 21 37.0090922745 2 15000 7.22882 1.10123 9 10 
 i 21 41.9957124042 2 15000 7.64386 1.10123 9 10 
 i 21 49.004183051 2 15000 7.79586 1.10123 9 10 
 i 21 53.9995667439 2 15000 7.22882 1.10123 9 10 
 i 21 61.009034336 2 15000 7.05889 1.10123 9 10 
 i 21 65.9979114179 2 15000 7.79586 1.10123 9 10 
 i 21 73.0036623525 2 15000 7.22882 1.10123 9 10 
 i 21 77.9980830721 2 15000 7.05889 1.10123 9 10 
 i 21 84.9978352802 2 15000 7.64386 1.10123 9 10 
 i 21 89.9969093069 2 15000 7.22882 1.10123 9 10 
 i 21 97.0084381447 2 15000 7.05889 1.10123 9 10 
 i 21 102.008531158 2 15000 7.64386 1.10123 9 10 
 i 21 108.99973824 2 15000 7.79586 1.10123 9 10 
 i 21 113.998085518 2 15000 7.22882 1.10123 9 10 
 i 21 121.000049739 2 15000 7.38082178394 1.10123 9 10 
 i 21 1.16671286142 2 1178.2835638 7.2288186905 1.10123 19 20 
 i 21 1.336149475 2 1203.75264439 7.38082178394 1.10123 19 20 
 i 21 1.4953677304 2 1229.22172498 7.96578428466 1.10123 19 20 
 i 21 1.66390627346 2 1254.69080557 7.79585928322 1.10123 19 20 
 i 21 1.83270093159 2 1280.15988615 7.96578428466 1.10123 19 20 
 i 21 2.0012882017 2 1305.62896674 7.79585928322 1.10123 19 20 
 i 21 2.17564896248 2 1331.09804733 7.96578428466 1.10123 19 20 
 i 21 2.32355401556 2 1356.56712791 8.2288186905 1.10123 19 20 
 i 21 2.50882138979 2 1382.0362085 8.38082178394 1.10123 19 20 
 i 21 2.65585738551 2 1407.50528909 8.2288186905 1.10123 19 20 
 i 21 2.83109005958 2 1432.97436968 8.38082178394 1.10123 19 20 
 i 21 3.00135381453 2 1458.44345026 8.96578428466 1.10123 19 20 
 i 21 3.17171976327 2 1483.91253085 8.79585928322 1.10123 19 20 
 i 21 3.34304736465 2 1509.38161144 8.96578428466 1.10123 19 20 
 i 21 3.50791322164 2 1534.85069202 8.79585928322 1.10123 19 20 
 i 21 3.67084351982 2 1560.31977261 8.96578428466 1.10123 19 20 
 i 21 3.82497984927 2 1585.7888532 9.2288186905 1.10123 19 20 
 i 21 4.00092448208 2 1611.25793379 9.38082178394 1.10123 19 20 
 i 21 4.16409514268 2 1636.72701437 9.2288186905 1.10123 19 20 
 i 21 4.32758322569 2 1662.19609496 9.38082178394 1.10123 19 20 
 i 21 4.49410616398 2 1687.66517555 9.96578428466 1.10123 19 20 
 i 21 4.67354162636 2 1713.13425614 9.79585928322 1.10123 19 20 
 i 21 4.83602238845 2 1738.60333672 9.96578428466 1.10123 19 20 
 i 21 4.99777537733 2 1764.07241731 9.79585928322 1.10123 19 20 
 i 21 5.17567322184 2 1789.5414979 9.96578428466 1.10123 19 20 
 i 21 5.33396021692 2 1815.01057848 10.2288186905 1.10123 19 20 
 i 21 5.49746244597 2 1840.47965907 10.3808217839 1.10123 19 20 
 i 21 5.66370711505 2 1865.94873966 10.2288186905 1.10123 19 20 
 i 21 5.83782222159 2 1891.41782025 7.05889 1.10123 19 20 
 i 21 6.00094160114 2 1916.88690083 10.3808217839 1.10123 19 20 
 i 21 6.16405468887 2 1942.35597989 7.2288186905 1.10123 19 20 
 i 21 6.16395272969 2 1942.35598142 10.9657842847 1.10123 19 20 
 i 21 6.33751752349 2 1967.82506048 7.05889368905 1.10123 19 20 
 i 21 6.33468728412 2 1967.82506201 10.7958592832 1.10123 19 20 
 i 21 6.50576100959 2 1993.29414107 7.2288186905 1.10123 19 20 
 i 21 6.48974339218 2 1993.29414259 10.9657842847 1.10123 19 20 
 i 21 6.66004142687 2 2018.76322165 7.79585928322 1.10123 19 20 
 i 21 6.66311915941 2 2018.76322318 10.7958592832 1.10123 19 20 
 i 21 6.82778997171 2 2044.23230224 7.64385618977 1.10123 19 20 
 i 21 6.84308187539 2 2044.23230377 7.79585928322 1.10123 19 20 
 i 21 6.99789297294 2 2069.70138283 7.64385618977 1.10123 19 20 
 i 21 7.17051319861 2 2095.17046341 7.79585928322 1.10123 19 20 
 i 21 7.32317816614 2 2120.639544 8.05889368905 1.10123 19 20 
 i 21 7.50968531428 2 2146.10862459 8.2288186905 1.10123 19 20 
 i 21 7.67364256333 2 2171.57770518 8.05889368905 1.10123 19 20 
 i 21 7.83082648413 2 2197.04678576 8.2288186905 1.10123 19 20 
 i 21 8.0048692657 2 2222.51586635 8.79585928322 1.10123 19 20 
 i 21 8.17196611707 2 2247.98494694 8.64385618977 1.10123 19 20 
 i 21 8.32245437143 2 2273.45402752 8.79585928322 1.10123 19 20 
 i 21 8.50266050286 2 2298.92310811 8.64385618977 1.10123 19 20 
 i 21 8.66695442097 2 2324.3921887 8.79585928322 1.10123 19 20 
 i 21 8.83538653249 2 2349.86126929 9.05889368905 1.10123 19 20 
 i 21 9.00550158692 2 2375.33034987 9.2288186905 1.10123 19 20 
 i 21 9.17669422769 2 2400.79943046 9.05889368905 1.10123 19 20 
 i 21 9.33531060348 2 2426.26851105 9.2288186905 1.10123 19 20 
 i 21 9.4990888207 2 2451.73759163 9.79585928322 1.10123 19 20 
 i 21 9.67647350843 2 2477.20667222 9.64385618977 1.10123 19 20 
 i 21 9.83845504877 2 2502.67575281 9.79585928322 1.10123 19 20 
 i 21 10.0097989246 2 2528.1448334 9.64385618977 1.10123 19 20 
 i 21 10.1625240514 2 2553.61391398 9.79585928322 1.10123 19 20 
 i 21 10.3230810271 2 2579.08299457 10.0588936891 1.10123 19 20 
 i 21 10.4968240569 2 2604.55207516 10.2288186905 1.10123 19 20 
 i 21 10.668553018 2 2630.02115574 10.0588936891 1.10123 19 20 
 i 21 10.8440097148 2 2655.49023633 10.2288186905 1.10123 19 20 
 i 21 11.0067087165 2 2680.95931692 10.7958592832 1.10123 19 20 
 i 21 11.1670638621 2 2706.42839751 10.6438561898 1.10123 19 20 
 i 21 11.3269882355 2 2731.89747809 10.7958592832 1.10123 19 20 
 i 21 11.5032092435 2 2757.36655868 10.6438561898 1.10123 19 20 
 i 21 11.6747779074 2 2782.83563927 7.64386 1.10123 19 20 
 i 21 11.8411761666 2 2808.30471986 7.79585928322 1.10123 19 20 
 i 21 13.1691361833 2 3012.05736241 7.64385618977 1.10123 19 20 
 i 21 13.3394038548 2 3037.526443 7.79585928322 1.10123 19 20 
 i 21 13.492408246 2 3062.99552359 8.38082178394 1.10123 19 20 
 i 21 13.6666913737 2 3088.46460417 8.2288186905 1.10123 19 20 
 i 21 13.8429930297 2 3113.93368476 8.38082178394 1.10123 19 20 
 i 21 13.9890415501 2 3139.40276535 8.2288186905 1.10123 19 20 
 i 21 14.1588314859 2 3164.87184594 8.38082178394 1.10123 19 20 
 i 21 14.3362440837 2 3190.34092652 8.64385618977 1.10123 19 20 
 i 21 14.4902083465 2 3215.81000711 8.79585928322 1.10123 19 20 
 i 21 14.6646858673 2 3241.2790877 8.64385618977 1.10123 19 20 
 i 21 14.8409811171 2 3266.74816828 8.79585928322 1.10123 19 20 
 i 21 14.9991444073 2 3292.21724887 9.38082178394 1.10123 19 20 
 i 21 15.165079205 2 3317.68632946 9.2288186905 1.10123 19 20 
 i 21 15.342706363 2 3343.15541005 9.38082178394 1.10123 19 20 
 i 21 15.5105977743 2 3368.62449063 9.2288186905 1.10123 19 20 
 i 21 15.6621283129 2 3394.09357122 9.38082178394 1.10123 19 20 
 i 21 15.836684526 2 3419.56265181 9.64385618977 1.10123 19 20 
 i 21 16.0092943534 2 3445.03173239 9.79585928322 1.10123 19 20 
 i 21 16.1725750668 2 3470.50081298 9.64385618977 1.10123 19 20 
 i 21 16.3227285213 2 3495.96989357 9.79585928322 1.10123 19 20 
 i 21 16.4981637999 2 3521.43897416 10.3808217839 1.10123 19 20 
 i 21 16.6686259781 2 3546.90805474 10.2288186905 1.10123 19 20 
 i 21 16.8303005912 2 3572.37713533 10.3808217839 1.10123 19 20 
 i 21 17.0037511631 2 3597.84621592 10.2288186905 1.10123 19 20 
 i 21 17.1607268263 2 3623.31529651 10.3808217839 1.10123 19 20 
 i 21 17.3253492653 2 3648.78437709 10.6438561898 1.10123 19 20 
 i 21 17.4944756853 2 3674.25345768 10.7958592832 1.10123 19 20 
 i 21 17.6702408232 2 3699.72253827 10.6438561898 1.10123 19 20 
 i 21 17.8267866695 2 3725.19161885 7.79586 1.10123 19 20 
 i 21 17.9978771665 2 3750.66069944 10.7958592832 1.10123 19 20 
 i 21 18.1573482452 2 3776.1297785 7.96578428466 1.10123 19 20 
 i 21 18.16017716 2 3776.12978003 11.3808217839 1.10123 19 20 
 i 21 18.3336520882 2 3801.59885909 7.79585928322 1.10123 19 20 
 i 21 18.3250909137 2 3801.59886062 11.2288186905 1.10123 19 20 
 i 21 18.5090815979 2 3827.06793967 7.96578428466 1.10123 19 20 
 i 21 18.5058995544 2 3827.0679412 11.3808217839 1.10123 19 20 
 i 21 18.665134742 2 3852.53702026 8.55074678538 1.10123 19 20 
 i 21 18.6775053932 2 3852.53702179 11.2288186905 1.10123 19 20 
 i 21 18.8306103773 2 3878.00610085 8.38082178394 1.10123 19 20 
 i 21 18.8273352957 2 3878.00610238 8.55074678538 1.10123 19 20 
 i 21 19.0015346416 2 3903.47518144 8.38082178394 1.10123 19 20 
 i 21 19.1605410627 2 3928.94426202 8.55074678538 1.10123 19 20 
 i 21 19.3439590949 2 3954.41334261 8.79585928322 1.10123 19 20 
 i 21 19.4928584699 2 3979.8824232 8.96578428466 1.10123 19 20 
 i 21 19.6758949594 2 4005.35150378 8.79585928322 1.10123 19 20 
 i 21 19.8281064033 2 4030.82058437 8.96578428466 1.10123 19 20 
 i 21 19.9911969832 2 4056.28966496 9.55074678538 1.10123 19 20 
 i 21 20.1731455297 2 4081.75874555 9.38082178394 1.10123 19 20 
 i 21 20.3372841312 2 4107.22782613 9.55074678538 1.10123 19 20 
 i 21 20.5012527081 2 4132.69690672 9.38082178394 1.10123 19 20 
 i 21 20.6660736751 2 4158.16598731 9.55074678538 1.10123 19 20 
 i 21 20.8302286173 2 4183.63506789 9.79585928322 1.10123 19 20 
 i 21 21.0074704157 2 4209.10414848 9.96578428466 1.10123 19 20 
 i 21 21.1669530191 2 4234.57322907 9.79585928322 1.10123 19 20 
 i 21 21.3351576315 2 4260.04230966 9.96578428466 1.10123 19 20 
 i 21 21.501923634 2 4285.51139024 10.5507467854 1.10123 19 20 
 i 21 21.6665380605 2 4310.98047083 10.3808217839 1.10123 19 20 
 i 21 21.8328500289 2 4336.44955142 10.5507467854 1.10123 19 20 
 i 21 22.0048112125 2 4361.918632 10.3808217839 1.10123 19 20 
 i 21 22.176978775 2 4387.38771259 10.5507467854 1.10123 19 20 
 i 21 22.3433825618 2 4412.85679318 10.7958592832 1.10123 19 20 
 i 21 22.4977008366 2 4438.32587377 10.9657842847 1.10123 19 20 
 i 21 22.6733290397 2 4463.79495435 10.7958592832 1.10123 19 20 
 i 21 22.839238302 2 4489.26403494 10.9657842847 1.10123 19 20 
 i 21 23.0081111504 2 4514.73311553 11.5507467854 1.10123 19 20 
 i 21 23.1733609458 2 4540.20219611 11.3808217839 1.10123 19 20 
 i 21 23.3351101159 2 4565.6712767 11.5507467854 1.10123 19 20 
 i 21 23.4928924489 2 4591.14035729 11.3808217839 1.10123 19 20 
 i 21 23.6658689676 2 4616.60943788 7.05889 1.10123 19 20 
 i 21 23.8410746309 2 4642.07851846 7.2288186905 1.10123 19 20 
 i 21 25.1726405366 2 4845.83116102 7.05889368905 1.10123 19 20 
 i 21 25.3264469347 2 4871.30024161 7.2288186905 1.10123 19 20 
 i 21 25.4905192307 2 4896.7693222 7.79585928322 1.10123 19 20 
 i 21 25.6602249572 2 4922.23840278 7.64385618977 1.10123 19 20 
 i 21 25.8317155747 2 4947.70748337 7.79585928322 1.10123 19 20 
 i 21 25.9992323414 2 4973.17656396 7.64385618977 1.10123 19 20 
 i 21 26.1741291405 2 4998.64564454 7.79585928322 1.10123 19 20 
 i 21 26.3283755337 2 5024.11472513 8.05889368905 1.10123 19 20 
 i 21 26.497191813 2 5049.58380572 8.2288186905 1.10123 19 20 
 i 21 26.6666568096 2 5075.05288631 8.05889368905 1.10123 19 20 
 i 21 26.8253738766 2 5100.52196689 8.2288186905 1.10123 19 20 
 i 21 26.9995698091 2 5125.99104748 8.79585928322 1.10123 19 20 
 i 21 27.1694046118 2 5151.46012807 8.64385618977 1.10123 19 20 
 i 21 27.3364004956 2 5176.92920865 8.79585928322 1.10123 19 20 
 i 21 27.4963147074 2 5202.39828924 8.64385618977 1.10123 19 20 
 i 21 27.6633375322 2 5227.86736983 8.79585928322 1.10123 19 20 
 i 21 27.8327920213 2 5253.33645042 9.05889368905 1.10123 19 20 
 i 21 27.989105343 2 5278.805531 9.2288186905 1.10123 19 20 
 i 21 28.1564944001 2 5304.27461159 9.05889368905 1.10123 19 20 
 i 21 28.334465478 2 5329.74369218 9.2288186905 1.10123 19 20 
 i 21 28.4941622153 2 5355.21277276 9.79585928322 1.10123 19 20 
 i 21 28.6559429186 2 5380.68185335 9.64385618977 1.10123 19 20 
 i 21 28.8331869504 2 5406.15093394 9.79585928322 1.10123 19 20 
 i 21 28.995326696 2 5431.62001453 9.64385618977 1.10123 19 20 
 i 21 29.1587810212 2 5457.08909511 9.79585928322 1.10123 19 20 
 i 21 29.3354421683 2 5482.5581757 10.0588936891 1.10123 19 20 
 i 21 29.5067971835 2 5508.02725629 10.2288186905 1.10123 19 20 
 i 21 29.6618484078 2 5533.49633688 10.0588936891 1.10123 19 20 
 i 21 29.8265003822 2 5558.96541746 7.64386 1.10123 19 20 
 i 21 30.0069089099 2 5584.43449805 10.2288186905 1.10123 19 20 
 i 21 30.1681614893 2 5609.90357711 7.79585928322 1.10123 19 20 
 i 21 30.1713164848 2 5609.90357864 10.7958592832 1.10123 19 20 
 i 21 30.3293386647 2 5635.3726577 7.64385618977 1.10123 19 20 
 i 21 30.3315123355 2 5635.37265922 10.6438561898 1.10123 19 20 
 i 21 30.5108955581 2 5660.84173828 7.79585928322 1.10123 19 20 
 i 21 30.5095600936 2 5660.84173981 10.7958592832 1.10123 19 20 
 i 21 30.6583244877 2 5686.31081887 8.38082178394 1.10123 19 20 
 i 21 30.6775543264 2 5686.3108204 10.6438561898 1.10123 19 20 
 i 21 30.8317634443 2 5711.77989946 8.2288186905 1.10123 19 20 
 i 21 30.8426787921 2 5711.77990099 8.38082178394 1.10123 19 20 
 i 21 30.9899526598 2 5737.24898004 8.2288186905 1.10123 19 20 
 i 21 31.1652872038 2 5762.71806063 8.38082178394 1.10123 19 20 
 i 21 31.3384086683 2 5788.18714122 8.64385618977 1.10123 19 20 
 i 21 31.4956259613 2 5813.65622181 8.79585928322 1.10123 19 20 
 i 21 31.666819536 2 5839.12530239 8.64385618977 1.10123 19 20 
 i 21 31.8401144136 2 5864.59438298 8.79585928322 1.10123 19 20 
 i 21 31.9949481337 2 5890.06346357 9.38082178394 1.10123 19 20 
 i 21 32.1654737798 2 5915.53254415 9.2288186905 1.10123 19 20 
 i 21 32.3388213031 2 5941.00162474 9.38082178394 1.10123 19 20 
 i 21 32.4986207405 2 5966.47070533 9.2288186905 1.10123 19 20 
 i 21 32.6632318663 2 5991.93978592 9.38082178394 1.10123 19 20 
 i 21 32.8262307128 2 6017.4088665 9.64385618977 1.10123 19 20 
 i 21 32.9905063699 2 6042.87794709 9.79585928322 1.10123 19 20 
 i 21 33.1758241864 2 6068.34702768 9.64385618977 1.10123 19 20 
 i 21 33.3386674489 2 6093.81610826 9.79585928322 1.10123 19 20 
 i 21 33.4985615594 2 6119.28518885 10.3808217839 1.10123 19 20 
 i 21 33.6746879064 2 6144.75426944 10.2288186905 1.10123 19 20 
 i 21 33.8363336039 2 6170.22335003 10.3808217839 1.10123 19 20 
 i 21 34.0049655395 2 6195.69243061 10.2288186905 1.10123 19 20 
 i 21 34.1614676941 2 6221.1615112 10.3808217839 1.10123 19 20 
 i 21 34.3366369759 2 6246.63059179 10.6438561898 1.10123 19 20 
 i 21 34.5043823789 2 6272.09967237 10.7958592832 1.10123 19 20 
 i 21 34.6650244838 2 6297.56875296 10.6438561898 1.10123 19 20 
 i 21 34.83109219 2 6323.03783355 10.7958592832 1.10123 19 20 
 i 21 34.9990693212 2 6348.50691414 11.3808217839 1.10123 19 20 
 i 21 35.1631459331 2 6373.97599472 11.2288186905 1.10123 19 20 
 i 21 35.3359896267 2 6399.44507531 11.3808217839 1.10123 19 20 
 i 21 35.5021171357 2 6424.9141559 11.2288186905 1.10123 19 20 
 i 21 35.656858861 2 6450.38323648 7.79586 1.10123 19 20 
 i 21 35.824195869 2 6475.85231707 7.96578428466 1.10123 19 20 
 i 21 37.1775445766 2 6679.60495963 7.79585928322 1.10123 19 20 
 i 21 37.3316693627 2 6705.07404022 7.96578428466 1.10123 19 20 
 i 21 37.5093130016 2 6730.5431208 8.55074678538 1.10123 19 20 
 i 21 37.6749416336 2 6756.01220139 8.38082178394 1.10123 19 20 
 i 21 37.8319958486 2 6781.48128198 8.55074678538 1.10123 19 20 
 i 21 38.0103851295 2 6806.95036257 8.38082178394 1.10123 19 20 
 i 21 38.1690276691 2 6832.41944315 8.55074678538 1.10123 19 20 
 i 21 38.3407207586 2 6857.88852374 8.79585928322 1.10123 19 20 
 i 21 38.5052802128 2 6883.35760433 8.96578428466 1.10123 19 20 
 i 21 38.6771322815 2 6908.82668491 8.79585928322 1.10123 19 20 
 i 21 38.8293245757 2 6934.2957655 8.96578428466 1.10123 19 20 
 i 21 38.9912213482 2 6959.76484609 9.55074678538 1.10123 19 20 
 i 21 39.1643119036 2 6985.23392668 9.38082178394 1.10123 19 20 
 i 21 39.3325931422 2 7010.70300726 9.55074678538 1.10123 19 20 
 i 21 39.4915908994 2 7036.17208785 9.38082178394 1.10123 19 20 
 i 21 39.6704244753 2 7061.64116844 9.55074678538 1.10123 19 20 
 i 21 39.8297043165 2 7087.11024902 9.79585928322 1.10123 19 20 
 i 21 40.0042232635 2 7112.57932961 9.96578428466 1.10123 19 20 
 i 21 40.1623485017 2 7138.0484102 9.79585928322 1.10123 19 20 
 i 21 40.3398745369 2 7163.51749079 9.96578428466 1.10123 19 20 
 i 21 40.5047128161 2 7188.98657137 10.5507467854 1.10123 19 20 
 i 21 40.6577888538 2 7214.45565196 10.3808217839 1.10123 19 20 
 i 21 40.8273334903 2 7239.92473255 10.5507467854 1.10123 19 20 
 i 21 41.0037358053 2 7265.39381313 10.3808217839 1.10123 19 20 
 i 21 41.1719346428 2 7290.86289372 10.5507467854 1.10123 19 20 
 i 21 41.3389172826 2 7316.33197431 10.7958592832 1.10123 19 20 
 i 21 41.4903600828 2 7341.8010549 10.9657842847 1.10123 19 20 
 i 21 41.6645984034 2 7367.27013548 10.7958592832 1.10123 19 20 
 i 21 41.8310825299 2 7392.73921607 7.22882 1.10123 19 20 
 i 21 41.9975316732 2 7418.20829666 10.9657842847 1.10123 19 20 
 i 21 42.1754930359 2 7443.67737572 7.38082178394 1.10123 19 20 
 i 21 42.1645758392 2 7443.67737725 11.5507467854 1.10123 19 20 
 i 21 42.3342519232 2 7469.1464563 7.2288186905 1.10123 19 20 
 i 21 42.3274385022 2 7469.14645783 11.3808217839 1.10123 19 20 
 i 21 42.5025244783 2 7494.61553689 7.38082178394 1.10123 19 20 
 i 21 42.4906038702 2 7494.61553842 11.5507467854 1.10123 19 20 
 i 21 42.6729246705 2 7520.08461748 7.96578428466 1.10123 19 20 
 i 21 42.6703076392 2 7520.08461901 11.3808217839 1.10123 19 20 
 i 21 42.8265973182 2 7545.55369807 7.79585928322 1.10123 19 20 
 i 21 42.8267223637 2 7545.55369959 7.96578428466 1.10123 19 20 
 i 21 42.9951190291 2 7571.02277865 7.79585928322 1.10123 19 20 
 i 21 43.1556667261 2 7596.49185924 7.96578428466 1.10123 19 20 
 i 21 43.3233373581 2 7621.96093983 8.2288186905 1.10123 19 20 
 i 21 43.4992510563 2 7647.43002041 8.38082178394 1.10123 19 20 
 i 21 43.6676482325 2 7672.899101 8.2288186905 1.10123 19 20 
 i 21 43.836082535 2 7698.36818159 8.38082178394 1.10123 19 20 
 i 21 44.004931577 2 7723.83726218 8.96578428466 1.10123 19 20 
 i 21 44.1609862352 2 7749.30634276 8.79585928322 1.10123 19 20 
 i 21 44.3373525097 2 7774.77542335 8.96578428466 1.10123 19 20 
 i 21 44.4996392792 2 7800.24450394 8.79585928322 1.10123 19 20 
 i 21 44.6728768038 2 7825.71358452 8.96578428466 1.10123 19 20 
 i 21 44.8273863703 2 7851.18266511 9.2288186905 1.10123 19 20 
 i 21 44.9925155681 2 7876.6517457 9.38082178394 1.10123 19 20 
 i 21 45.1665557459 2 7902.12082629 9.2288186905 1.10123 19 20 
 i 21 45.3338110162 2 7927.58990687 9.38082178394 1.10123 19 20 
 i 21 45.5099547087 2 7953.05898746 9.96578428466 1.10123 19 20 
 i 21 45.6695410543 2 7978.52806805 9.79585928322 1.10123 19 20 
 i 21 45.8241339334 2 8003.99714863 9.96578428466 1.10123 19 20 
 i 21 46.0095861046 2 8029.46622922 9.79585928322 1.10123 19 20 
 i 21 46.165592032 2 8054.93530981 9.96578428466 1.10123 19 20 
 i 21 46.3317731786 2 8080.4043904 10.2288186905 1.10123 19 20 
 i 21 46.5026761843 2 8105.87347098 10.3808217839 1.10123 19 20 
 i 21 46.6696305099 2 8131.34255157 10.2288186905 1.10123 19 20 
 i 21 46.8354275238 2 8156.81163216 10.3808217839 1.10123 19 20 
 i 21 47.0102058641 2 8182.28071274 10.9657842847 1.10123 19 20 
 i 21 47.1691809671 2 8207.74979333 10.7958592832 1.10123 19 20 
 i 21 47.3352138174 2 8233.21887392 10.9657842847 1.10123 19 20 
 i 21 47.5041899311 2 8258.68795451 10.7958592832 1.10123 19 20 
 i 21 47.6754800552 2 8284.15703509 7.64386 1.10123 19 20 
 i 21 47.8306013348 2 8309.62611568 7.79585928322 1.10123 19 20 
 i 21 49.1658469938 2 8513.37875824 7.64385618977 1.10123 19 20 
 i 21 49.3237512283 2 8538.84783883 7.79585928322 1.10123 19 20 
 i 21 49.5080599703 2 8564.31691941 8.38082178394 1.10123 19 20 
 i 21 49.6634370677 2 8589.786 8.2288186905 1.10123 19 20 
 i 21 49.8433820215 2 8615.25508059 8.38082178394 1.10123 19 20 
 i 21 49.9912369674 2 8640.72416117 8.2288186905 1.10123 19 20 
 i 21 50.1698037352 2 8666.19324176 8.38082178394 1.10123 19 20 
 i 21 50.3224887501 2 8691.66232235 8.64385618977 1.10123 19 20 
 i 21 50.4929216826 2 8717.13140294 8.79585928322 1.10123 19 20 
 i 21 50.6600398011 2 8742.60048352 8.64385618977 1.10123 19 20 
 i 21 50.8388123039 2 8768.06956411 8.79585928322 1.10123 19 20 
 i 21 51.0054742643 2 8793.5386447 9.38082178394 1.10123 19 20 
 i 21 51.159859884 2 8819.00772528 9.2288186905 1.10123 19 20 
 i 21 51.3271656002 2 8844.47680587 9.38082178394 1.10123 19 20 
 i 21 51.5063001161 2 8869.94588646 9.2288186905 1.10123 19 20 
 i 21 51.6695807298 2 8895.41496705 9.38082178394 1.10123 19 20 
 i 21 51.8306364914 2 8920.88404763 9.64385618977 1.10123 19 20 
 i 21 52.0027643518 2 8946.35312822 9.79585928322 1.10123 19 20 
 i 21 52.1757765707 2 8971.82220881 9.64385618977 1.10123 19 20 
 i 21 52.3235782192 2 8997.29128939 9.79585928322 1.10123 19 20 
 i 21 52.5062565304 2 9022.76036998 10.3808217839 1.10123 19 20 
 i 21 52.6748945541 2 9048.22945057 10.2288186905 1.10123 19 20 
 i 21 52.8289098794 2 9073.69853116 10.3808217839 1.10123 19 20 
 i 21 52.9986497956 2 9099.16761174 10.2288186905 1.10123 19 20 
 i 21 53.1665254381 2 9124.63669233 10.3808217839 1.10123 19 20 
 i 21 53.3388293212 2 9150.10577292 10.6438561898 1.10123 19 20 
 i 21 53.4995972758 2 9175.5748535 10.7958592832 1.10123 19 20 
 i 21 53.6563278755 2 9201.04393409 10.6438561898 1.10123 19 20 
 i 21 53.8317233106 2 9226.51301468 7.79586 1.10123 19 20 
 i 21 54.0073520763 2 9251.98209527 10.7958592832 1.10123 19 20 
 i 21 54.1762898871 2 9277.45117433 7.96578428466 1.10123 19 20 
 i 21 54.1718654446 2 9277.45117585 11.3808217839 1.10123 19 20 
 i 21 54.3299163886 2 9302.92025491 7.79585928322 1.10123 19 20 
 i 21 54.3316717697 2 9302.92025644 11.2288186905 1.10123 19 20 
 i 21 54.5054285705 2 9328.3893355 7.96578428466 1.10123 19 20 
 i 21 54.4891047561 2 9328.38933703 11.3808217839 1.10123 19 20 
 i 21 54.6557068149 2 9353.85841609 8.55074678538 1.10123 19 20 
 i 21 54.6626476334 2 9353.85841762 11.2288186905 1.10123 19 20 
 i 21 54.8365431621 2 9379.32749667 8.38082178394 1.10123 19 20 
 i 21 54.8366374851 2 9379.3274982 8.55074678538 1.10123 19 20 
 i 21 54.9950113766 2 9404.79657726 8.38082178394 1.10123 19 20 
 i 21 55.1580736787 2 9430.26565785 8.55074678538 1.10123 19 20 
 i 21 55.3369668975 2 9455.73473844 8.79585928322 1.10123 19 20 
 i 21 55.4933587412 2 9481.20381902 8.96578428466 1.10123 19 20 
 i 21 55.6568566466 2 9506.67289961 8.79585928322 1.10123 19 20 
 i 21 55.8276912735 2 9532.1419802 8.96578428466 1.10123 19 20 
 i 21 56.0051620456 2 9557.61106078 9.55074678538 1.10123 19 20 
 i 21 56.1630226587 2 9583.08014137 9.38082178394 1.10123 19 20 
 i 21 56.3321443802 2 9608.54922196 9.55074678538 1.10123 19 20 
 i 21 56.5003757523 2 9634.01830255 9.38082178394 1.10123 19 20 
 i 21 56.6770386573 2 9659.48738313 9.55074678538 1.10123 19 20 
 i 21 56.8272657698 2 9684.95646372 9.79585928322 1.10123 19 20 
 i 21 57.0027682914 2 9710.42554431 9.96578428466 1.10123 19 20 
 i 21 57.16036452 2 9735.89462489 9.79585928322 1.10123 19 20 
 i 21 57.3327657842 2 9761.36370548 9.96578428466 1.10123 19 20 
 i 21 57.490177305 2 9786.83278607 10.5507467854 1.10123 19 20 
 i 21 57.6604961246 2 9812.30186666 10.3808217839 1.10123 19 20 
 i 21 57.8386372833 2 9837.77094724 10.5507467854 1.10123 19 20 
 i 21 57.9987663756 2 9863.24002783 10.3808217839 1.10123 19 20 
 i 21 58.1773853306 2 9888.70910842 10.5507467854 1.10123 19 20 
 i 21 58.3325843194 2 9914.178189 10.7958592832 1.10123 19 20 
 i 21 58.4927780203 2 9939.64726959 10.9657842847 1.10123 19 20 
 i 21 58.6724959689 2 9965.11635018 10.7958592832 1.10123 19 20 
 i 21 58.8319069264 2 9990.58543077 10.9657842847 1.10123 19 20 
 i 21 58.9933171867 2 10016.0545114 11.5507467854 1.10123 19 20 
 i 21 59.1645376413 2 10041.5235919 11.3808217839 1.10123 19 20 
 i 21 59.3421236406 2 10066.9926725 11.5507467854 1.10123 19 20 
 i 21 59.4955447005 2 10092.4617531 11.3808217839 1.10123 19 20 
 i 21 59.6747744221 2 10117.9308337 7.22882 1.10123 19 20 
 i 21 59.8311270388 2 10143.3999143 7.38082178394 1.10123 19 20 
 i 21 61.1630350691 2 10347.1525568 7.2288186905 1.10123 19 20 
 i 21 61.3363208716 2 10372.6216374 7.38082178394 1.10123 19 20 
 i 21 61.5003679193 2 10398.090718 7.96578428466 1.10123 19 20 
 i 21 61.6775876805 2 10423.5597986 7.79585928322 1.10123 19 20 
 i 21 61.8262216517 2 10449.0288792 7.96578428466 1.10123 19 20 
 i 21 61.9969729865 2 10474.4979598 7.79585928322 1.10123 19 20 
 i 21 62.1613339615 2 10499.9670404 7.96578428466 1.10123 19 20 
 i 21 62.3433449511 2 10525.436121 8.2288186905 1.10123 19 20 
 i 21 62.5029235888 2 10550.9052015 8.38082178394 1.10123 19 20 
 i 21 62.6759610176 2 10576.3742821 8.2288186905 1.10123 19 20 
 i 21 62.8291367483 2 10601.8433627 8.38082178394 1.10123 19 20 
 i 21 63.0097055593 2 10627.3124433 8.96578428466 1.10123 19 20 
 i 21 63.1708318444 2 10652.7815239 8.79585928322 1.10123 19 20 
 i 21 63.3378492856 2 10678.2506045 8.96578428466 1.10123 19 20 
 i 21 63.4955328893 2 10703.7196851 8.79585928322 1.10123 19 20 
 i 21 63.6710572042 2 10729.1887657 8.96578428466 1.10123 19 20 
 i 21 63.827474831 2 10754.6578462 9.2288186905 1.10123 19 20 
 i 21 63.9960685173 2 10780.1269268 9.38082178394 1.10123 19 20 
 i 21 64.1661162302 2 10805.5960074 9.2288186905 1.10123 19 20 
 i 21 64.3437713812 2 10831.065088 9.38082178394 1.10123 19 20 
 i 21 64.5073230063 2 10856.5341686 9.96578428466 1.10123 19 20 
 i 21 64.6702029014 2 10882.0032492 9.79585928322 1.10123 19 20 
 i 21 64.8359670581 2 10907.4723298 9.96578428466 1.10123 19 20 
 i 21 64.9925763159 2 10932.9414104 9.79585928322 1.10123 19 20 
 i 21 65.1640308369 2 10958.4104909 9.96578428466 1.10123 19 20 
 i 21 65.3300473453 2 10983.8795715 10.2288186905 1.10123 19 20 
 i 21 65.5013291083 2 11009.3486521 10.3808217839 1.10123 19 20 
 i 21 65.6630995493 2 11034.8177327 10.2288186905 1.10123 19 20 
 i 21 65.8375435469 2 11060.2868133 7.05889 1.10123 19 20 
 i 21 66.0070938685 2 11085.7558939 10.3808217839 1.10123 19 20 
 i 21 66.1573286667 2 11111.2249729 7.2288186905 1.10123 19 20 
 i 21 66.1726933645 2 11111.2249745 10.9657842847 1.10123 19 20 
 i 21 66.3224915565 2 11136.6940535 7.05889368905 1.10123 19 20 
 i 21 66.335267515 2 11136.694055 10.7958592832 1.10123 19 20 
 i 21 66.5054241006 2 11162.1631341 7.2288186905 1.10123 19 20 
 i 21 66.4962929954 2 11162.1631356 10.9657842847 1.10123 19 20 
 i 21 66.6605655722 2 11187.6322147 7.79585928322 1.10123 19 20 
 i 21 66.6625778237 2 11187.6322162 10.7958592832 1.10123 19 20 
 i 21 66.8418663223 2 11213.1012953 7.64385618977 1.10123 19 20 
 i 21 66.8438506878 2 11213.1012968 7.79585928322 1.10123 19 20 
 i 21 67.0108184996 2 11238.5703759 7.64385618977 1.10123 19 20 
 i 21 67.156460063 2 11264.0394565 7.79585928322 1.10123 19 20 
 i 21 67.3319915379 2 11289.508537 8.05889368905 1.10123 19 20 
 i 21 67.5005362888 2 11314.9776176 8.2288186905 1.10123 19 20 
 i 21 67.6558214813 2 11340.4466982 8.05889368905 1.10123 19 20 
 i 21 67.8298683681 2 11365.9157788 8.2288186905 1.10123 19 20 
 i 21 67.996352041 2 11391.3848594 8.79585928322 1.10123 19 20 
 i 21 68.1754290573 2 11416.85394 8.64385618977 1.10123 19 20 
 i 21 68.3320954864 2 11442.3230206 8.79585928322 1.10123 19 20 
 i 21 68.5065834634 2 11467.7921012 8.64385618977 1.10123 19 20 
 i 21 68.6558074969 2 11493.2611817 8.79585928322 1.10123 19 20 
 i 21 68.8347256282 2 11518.7302623 9.05889368905 1.10123 19 20 
 i 21 69.0071194012 2 11544.1993429 9.2288186905 1.10123 19 20 
 i 21 69.1716147962 2 11569.6684235 9.05889368905 1.10123 19 20 
 i 21 69.3298479085 2 11595.1375041 9.2288186905 1.10123 19 20 
 i 21 69.5070667606 2 11620.6065847 9.79585928322 1.10123 19 20 
 i 21 69.6771577386 2 11646.0756653 9.64385618977 1.10123 19 20 
 i 21 69.8248516981 2 11671.5447459 9.79585928322 1.10123 19 20 
 i 21 69.9976038999 2 11697.0138264 9.64385618977 1.10123 19 20 
 i 21 70.1738477335 2 11722.482907 9.79585928322 1.10123 19 20 
 i 21 70.3284637389 2 11747.9519876 10.0588936891 1.10123 19 20 
 i 21 70.5053124967 2 11773.4210682 10.2288186905 1.10123 19 20 
 i 21 70.6705490968 2 11798.8901488 10.0588936891 1.10123 19 20 
 i 21 70.843986329 2 11824.3592294 10.2288186905 1.10123 19 20 
 i 21 70.9982806643 2 11849.82831 10.7958592832 1.10123 19 20 
 i 21 71.1575068852 2 11875.2973905 10.6438561898 1.10123 19 20 
 i 21 71.3247828247 2 11900.7664711 10.7958592832 1.10123 19 20 
 i 21 71.5092339356 2 11926.2355517 10.6438561898 1.10123 19 20 
 i 21 71.668649696 2 11951.7046323 7.79586 1.10123 19 20 
 i 21 71.8388800102 2 11977.1737129 7.96578428466 1.10123 19 20 
 i 21 73.1715073695 2 12180.9263555 7.79585928322 1.10123 19 20 
 i 21 73.341508667 2 12206.395436 7.96578428466 1.10123 19 20 
 i 21 73.499652252 2 12231.8645166 8.55074678538 1.10123 19 20 
 i 21 73.6600522597 2 12257.3335972 8.38082178394 1.10123 19 20 
 i 21 73.8235026113 2 12282.8026778 8.55074678538 1.10123 19 20 
 i 21 73.9919817697 2 12308.2717584 8.38082178394 1.10123 19 20 
 i 21 74.1589565557 2 12333.740839 8.55074678538 1.10123 19 20 
 i 21 74.3420960023 2 12359.2099196 8.79585928322 1.10123 19 20 
 i 21 74.4900930114 2 12384.6790002 8.96578428466 1.10123 19 20 
 i 21 74.6692194187 2 12410.1480807 8.79585928322 1.10123 19 20 
 i 21 74.8249508391 2 12435.6171613 8.96578428466 1.10123 19 20 
 i 21 75.0095755853 2 12461.0862419 9.55074678538 1.10123 19 20 
 i 21 75.1727777953 2 12486.5553225 9.38082178394 1.10123 19 20 
 i 21 75.332426424 2 12512.0244031 9.55074678538 1.10123 19 20 
 i 21 75.5069768184 2 12537.4934837 9.38082178394 1.10123 19 20 
 i 21 75.6643370754 2 12562.9625643 9.55074678538 1.10123 19 20 
 i 21 75.8328912876 2 12588.4316449 9.79585928322 1.10123 19 20 
 i 21 75.9930449801 2 12613.9007254 9.96578428466 1.10123 19 20 
 i 21 76.1637855945 2 12639.369806 9.79585928322 1.10123 19 20 
 i 21 76.3335012814 2 12664.8388866 9.96578428466 1.10123 19 20 
 i 21 76.4909584319 2 12690.3079672 10.5507467854 1.10123 19 20 
 i 21 76.6744986777 2 12715.7770478 10.3808217839 1.10123 19 20 
 i 21 76.8351887129 2 12741.2461284 10.5507467854 1.10123 19 20 
 i 21 77.0015764593 2 12766.715209 10.3808217839 1.10123 19 20 
 i 21 77.166839085 2 12792.1842895 10.5507467854 1.10123 19 20 
 i 21 77.3277647945 2 12817.6533701 10.7958592832 1.10123 19 20 
 i 21 77.4984009623 2 12843.1224507 10.9657842847 1.10123 19 20 
 i 21 77.6728345353 2 12868.5915313 10.7958592832 1.10123 19 20 
 i 21 77.8318292723 2 12894.0606119 7.22882 1.10123 19 20 
 i 21 78.0046640369 2 12919.5296925 10.9657842847 1.10123 19 20 
 i 21 78.1681561361 2 12944.9987715 7.38082178394 1.10123 19 20 
 i 21 78.1665293268 2 12944.9987731 11.5507467854 1.10123 19 20 
 i 21 78.3368201586 2 12970.4678521 7.2288186905 1.10123 19 20 
 i 21 78.3440297025 2 12970.4678537 11.3808217839 1.10123 19 20 
 i 21 78.5078774158 2 12995.9369327 7.38082178394 1.10123 19 20 
 i 21 78.503320355 2 12995.9369342 11.5507467854 1.10123 19 20 
 i 21 78.6568178504 2 13021.4060133 7.96578428466 1.10123 19 20 
 i 21 78.6763513009 2 13021.4060148 11.3808217839 1.10123 19 20 
 i 21 78.8394708326 2 13046.8750939 7.79585928322 1.10123 19 20 
 i 21 78.8327571654 2 13046.8750954 7.96578428466 1.10123 19 20 
 i 21 78.9946471073 2 13072.3441745 7.79585928322 1.10123 19 20 
 i 21 79.1737805068 2 13097.8132551 7.96578428466 1.10123 19 20 
 i 21 79.327931931 2 13123.2823357 8.2288186905 1.10123 19 20 
 i 21 79.4919333822 2 13148.7514162 8.38082178394 1.10123 19 20 
 i 21 79.6742164319 2 13174.2204968 8.2288186905 1.10123 19 20 
 i 21 79.8304057186 2 13199.6895774 8.38082178394 1.10123 19 20 
 i 21 80.0030075095 2 13225.158658 8.96578428466 1.10123 19 20 
 i 21 80.1640815796 2 13250.6277386 8.79585928322 1.10123 19 20 
 i 21 80.333877879 2 13276.0968192 8.96578428466 1.10123 19 20 
 i 21 80.4997957499 2 13301.5658998 8.79585928322 1.10123 19 20 
 i 21 80.6594905876 2 13327.0349803 8.96578428466 1.10123 19 20 
 i 21 80.8434018749 2 13352.5040609 9.2288186905 1.10123 19 20 
 i 21 81.0094857513 2 13377.9731415 9.38082178394 1.10123 19 20 
 i 21 81.1744765114 2 13403.4422221 9.2288186905 1.10123 19 20 
 i 21 81.3244209493 2 13428.9113027 9.38082178394 1.10123 19 20 
 i 21 81.5012746082 2 13454.3803833 9.96578428466 1.10123 19 20 
 i 21 81.6688770881 2 13479.8494639 9.79585928322 1.10123 19 20 
 i 21 81.8295960451 2 13505.3185445 9.96578428466 1.10123 19 20 
 i 21 81.9996266233 2 13530.787625 9.79585928322 1.10123 19 20 
 i 21 82.1689811398 2 13556.2567056 9.96578428466 1.10123 19 20 
 i 21 82.3396440818 2 13581.7257862 10.2288186905 1.10123 19 20 
 i 21 82.5045951586 2 13607.1948668 10.3808217839 1.10123 19 20 
 i 21 82.6668869687 2 13632.6639474 10.2288186905 1.10123 19 20 
 i 21 82.8267548969 2 13658.133028 10.3808217839 1.10123 19 20 
 i 21 82.9982314374 2 13683.6021086 10.9657842847 1.10123 19 20 
 i 21 83.1587722276 2 13709.0711892 10.7958592832 1.10123 19 20 
 i 21 83.3299614208 2 13734.5402697 10.9657842847 1.10123 19 20 
 i 21 83.4956277931 2 13760.0093503 10.7958592832 1.10123 19 20 
 i 21 83.6686432513 2 13785.4784309 7.05889 1.10123 19 20 
 i 21 83.8251681537 2 13810.9475115 7.2288186905 1.10123 19 20 
 i 21 85.1734376535 2 14014.7001541 7.05889368905 1.10123 19 20 
 i 21 85.3288999706 2 14040.1692347 7.2288186905 1.10123 19 20 
 i 21 85.4940651688 2 14065.6383152 7.79585928322 1.10123 19 20 
 i 21 85.6729381837 2 14091.1073958 7.64385618977 1.10123 19 20 
 i 21 85.8254196754 2 14116.5764764 7.79585928322 1.10123 19 20 
 i 21 85.9939932479 2 14142.045557 7.64385618977 1.10123 19 20 
 i 21 86.1765260486 2 14167.5146376 7.79585928322 1.10123 19 20 
 i 21 86.3263705804 2 14192.9837182 8.05889368905 1.10123 19 20 
 i 21 86.4924145554 2 14218.4527988 8.2288186905 1.10123 19 20 
 i 21 86.6662163685 2 14243.9218793 8.05889368905 1.10123 19 20 
 i 21 86.8384541491 2 14269.3909599 8.2288186905 1.10123 19 20 
 i 21 86.9991715839 2 14294.8600405 8.79585928322 1.10123 19 20 
 i 21 87.176353846 2 14320.3291211 8.64385618977 1.10123 19 20 
 i 21 87.3354649192 2 14345.7982017 8.79585928322 1.10123 19 20 
 i 21 87.5021009315 2 14371.2672823 8.64385618977 1.10123 19 20 
 i 21 87.6601707368 2 14396.7363629 8.79585928322 1.10123 19 20 
 i 21 87.8397221192 2 14422.2054435 9.05889368905 1.10123 19 20 
 i 21 87.9939684278 2 14447.674524 9.2288186905 1.10123 19 20 
 i 21 88.1772110998 2 14473.1436046 9.05889368905 1.10123 19 20 
 i 21 88.3257833286 2 14498.6126852 9.2288186905 1.10123 19 20 
 i 21 88.4973651567 2 14524.0817658 9.79585928322 1.10123 19 20 
 i 21 88.6773315506 2 14549.5508464 9.64385618977 1.10123 19 20 
 i 21 88.8440205379 2 14575.019927 9.79585928322 1.10123 19 20 
 i 21 89.0041771287 2 14600.4890076 9.64385618977 1.10123 19 20 
 i 21 89.1594482051 2 14625.9580882 9.79585928322 1.10123 19 20 
 i 21 89.3239187711 2 14651.4271687 10.0588936891 1.10123 19 20 
 i 21 89.4934454347 2 14676.8962493 10.2288186905 1.10123 19 20 
 i 21 89.6581220533 2 14702.3653299 10.0588936891 1.10123 19 20 
 i 21 89.835726486 2 14727.8344105 7.64386 1.10123 19 20 
 i 21 89.989437868 2 14753.3034911 10.2288186905 1.10123 19 20 
 i 21 90.1749751239 2 14778.7725702 7.79585928322 1.10123 19 20 
 i 21 90.1693931786 2 14778.7725717 10.7958592832 1.10123 19 20 
 i 21 90.3248278612 2 14804.2416507 7.64385618977 1.10123 19 20 
 i 21 90.3251455679 2 14804.2416523 10.6438561898 1.10123 19 20 
 i 21 90.5090067515 2 14829.7107313 7.79585928322 1.10123 19 20 
 i 21 90.5078712374 2 14829.7107329 10.7958592832 1.10123 19 20 
 i 21 90.6702075785 2 14855.1798119 8.38082178394 1.10123 19 20 
 i 21 90.6615839703 2 14855.1798134 10.6438561898 1.10123 19 20 
 i 21 90.8289469762 2 14880.6488925 8.2288186905 1.10123 19 20 
 i 21 90.8324376829 2 14880.648894 8.38082178394 1.10123 19 20 
 i 21 91.0063016615 2 14906.1179731 8.2288186905 1.10123 19 20 
 i 21 91.1767896196 2 14931.5870537 8.38082178394 1.10123 19 20 
 i 21 91.335153073 2 14957.0561343 8.64385618977 1.10123 19 20 
 i 21 91.4908364192 2 14982.5252148 8.79585928322 1.10123 19 20 
 i 21 91.6656817333 2 15007.9942954 8.64385618977 1.10123 19 20 
 i 21 91.840267318 2 15033.463376 8.79585928322 1.10123 19 20 
 i 21 92.0076085603 2 15058.9324566 9.38082178394 1.10123 19 20 
 i 21 92.1771242203 2 15084.4015372 9.2288186905 1.10123 19 20 
 i 21 92.3339407076 2 15109.8706178 9.38082178394 1.10123 19 20 
 i 21 92.5086730568 2 15135.3396984 9.2288186905 1.10123 19 20 
 i 21 92.6717555755 2 15160.808779 9.38082178394 1.10123 19 20 
 i 21 92.834574059 2 15186.2778595 9.64385618977 1.10123 19 20 
 i 21 92.9916363461 2 15211.7469401 9.79585928322 1.10123 19 20 
 i 21 93.1770375946 2 15237.2160207 9.64385618977 1.10123 19 20 
 i 21 93.3248232888 2 15262.6851013 9.79585928322 1.10123 19 20 
 i 21 93.5065593485 2 15288.1541819 10.3808217839 1.10123 19 20 
 i 21 93.6683201425 2 15313.6232625 10.2288186905 1.10123 19 20 
 i 21 93.8370709603 2 15339.0923431 10.3808217839 1.10123 19 20 
 i 21 94.0109294065 2 15364.5614237 10.2288186905 1.10123 19 20 
 i 21 94.1644125226 2 15390.0305042 10.3808217839 1.10123 19 20 
 i 21 94.3281655815 2 15415.4995848 10.6438561898 1.10123 19 20 
 i 21 94.5041267553 2 15440.9686654 10.7958592832 1.10123 19 20 
 i 21 94.6599057761 2 15466.437746 10.6438561898 1.10123 19 20 
 i 21 94.8332703444 2 15491.9068266 10.7958592832 1.10123 19 20 
 i 21 94.9999589001 2 15517.3759072 11.3808217839 1.10123 19 20 
 i 21 95.156710814 2 15542.8449878 11.2288186905 1.10123 19 20 
 i 21 95.3282817573 2 15568.3140684 11.3808217839 1.10123 19 20 
 i 21 95.4959614918 2 15593.7831489 11.2288186905 1.10123 19 20 
 i 21 95.660979984 2 15619.2522295 7.22882 1.10123 19 20 
 i 21 95.8360040812 2 15644.7213101 7.38082178394 1.10123 19 20 
 i 21 97.1732014597 2 15848.4739527 7.2288186905 1.10123 19 20 
 i 21 97.3315065216 2 15873.9430333 7.38082178394 1.10123 19 20 
 i 21 97.4958678834 2 15899.4121138 7.96578428466 1.10123 19 20 
 i 21 97.675448437 2 15924.8811944 7.79585928322 1.10123 19 20 
 i 21 97.8431610584 2 15950.350275 7.96578428466 1.10123 19 20 
 i 21 98.0109143469 2 15975.8193556 7.79585928322 1.10123 19 20 
 i 21 98.1711197696 2 16001.2884362 7.96578428466 1.10123 19 20 
 i 21 98.3380857603 2 16026.7575168 8.2288186905 1.10123 19 20 
 i 21 98.5027536934 2 16052.2265974 8.38082178394 1.10123 19 20 
 i 21 98.6707308144 2 16077.695678 8.2288186905 1.10123 19 20 
 i 21 98.836322048 2 16103.1647585 8.38082178394 1.10123 19 20 
 i 21 99.0040494078 2 16128.6338391 8.96578428466 1.10123 19 20 
 i 21 99.163856427 2 16154.1029197 8.79585928322 1.10123 19 20 
 i 21 99.3284316007 2 16179.5720003 8.96578428466 1.10123 19 20 
 i 21 99.5052116556 2 16205.0410809 8.79585928322 1.10123 19 20 
 i 21 99.6753887049 2 16230.5101615 8.96578428466 1.10123 19 20 
 i 21 99.8385569634 2 16255.9792421 9.2288186905 1.10123 19 20 
 i 21 100.004787326 2 16281.4483227 9.38082178394 1.10123 19 20 
 i 21 100.161871768 2 16306.9174032 9.2288186905 1.10123 19 20 
 i 21 100.323289328 2 16332.3864838 9.38082178394 1.10123 19 20 
 i 21 100.492757596 2 16357.8555644 9.96578428466 1.10123 19 20 
 i 21 100.670997949 2 16383.324645 9.79585928322 1.10123 19 20 
 i 21 100.831184831 2 16408.7937256 9.96578428466 1.10123 19 20 
 i 21 101.008610612 2 16434.2628062 9.79585928322 1.10123 19 20 
 i 21 101.16342144 2 16459.7318868 9.96578428466 1.10123 19 20 
 i 21 101.337356442 2 16485.2009674 10.2288186905 1.10123 19 20 
 i 21 101.505066689 2 16510.6700479 10.3808217839 1.10123 19 20 
 i 21 101.669680058 2 16536.1391285 10.2288186905 1.10123 19 20 
 i 21 101.839793574 2 16561.6082091 7.05889 1.10123 19 20 
 i 21 101.998552432 2 16587.0772897 10.3808217839 1.10123 19 20 
 i 21 102.174502208 2 16612.5463688 7.2288186905 1.10123 19 20 
 i 21 102.159421493 2 16612.5463703 10.9657842847 1.10123 19 20 
 i 21 102.343054243 2 16638.0154493 7.05889368905 1.10123 19 20 
 i 21 102.334878464 2 16638.0154509 10.7958592832 1.10123 19 20 
 i 21 102.490166225 2 16663.4845299 7.2288186905 1.10123 19 20 
 i 21 102.491814638 2 16663.4845315 10.9657842847 1.10123 19 20 
 i 21 102.666905637 2 16688.9536105 7.79585928322 1.10123 19 20 
 i 21 102.67493758 2 16688.953612 10.7958592832 1.10123 19 20 
 i 21 102.842452026 2 16714.4226911 7.64385618977 1.10123 19 20 
 i 21 102.83464957 2 16714.4226926 7.79585928322 1.10123 19 20 
 i 21 102.995499693 2 16739.8917717 7.64385618977 1.10123 19 20 
 i 21 103.173515408 2 16765.3608523 7.79585928322 1.10123 19 20 
 i 21 103.325520243 2 16790.8299329 8.05889368905 1.10123 19 20 
 i 21 103.494821159 2 16816.2990135 8.2288186905 1.10123 19 20 
 i 21 103.663212671 2 16841.768094 8.05889368905 1.10123 19 20 
 i 21 103.842624024 2 16867.2371746 8.2288186905 1.10123 19 20 
 i 21 103.995356629 2 16892.7062552 8.79585928322 1.10123 19 20 
 i 21 104.162121024 2 16918.1753358 8.64385618977 1.10123 19 20 
 i 21 104.340081674 2 16943.6444164 8.79585928322 1.10123 19 20 
 i 21 104.494308058 2 16969.113497 8.64385618977 1.10123 19 20 
 i 21 104.660847668 2 16994.5825776 8.79585928322 1.10123 19 20 
 i 21 104.824665663 2 17020.0516582 9.05889368905 1.10123 19 20 
 i 21 105.005037528 2 17045.5207387 9.2288186905 1.10123 19 20 
 i 21 105.165063629 2 17070.9898193 9.05889368905 1.10123 19 20 
 i 21 105.341309384 2 17096.4588999 9.2288186905 1.10123 19 20 
 i 21 105.506955838 2 17121.9279805 9.79585928322 1.10123 19 20 
 i 21 105.671073707 2 17147.3970611 9.64385618977 1.10123 19 20 
 i 21 105.834646928 2 17172.8661417 9.79585928322 1.10123 19 20 
 i 21 106.006792786 2 17198.3352223 9.64385618977 1.10123 19 20 
 i 21 106.168956489 2 17223.8043029 9.79585928322 1.10123 19 20 
 i 21 106.322905271 2 17249.2733834 10.0588936891 1.10123 19 20 
 i 21 106.502228992 2 17274.742464 10.2288186905 1.10123 19 20 
 i 21 106.668037748 2 17300.2115446 10.0588936891 1.10123 19 20 
 i 21 106.829522206 2 17325.6806252 10.2288186905 1.10123 19 20 
 i 21 106.997640993 2 17351.1497058 10.7958592832 1.10123 19 20 
 i 21 107.173788023 2 17376.6187864 10.6438561898 1.10123 19 20 
 i 21 107.334338757 2 17402.087867 10.7958592832 1.10123 19 20 
 i 21 107.49937756 2 17427.5569475 10.6438561898 1.10123 19 20 
 i 21 107.668094657 2 17453.0260281 7.64386 1.10123 19 20 
 i 21 107.836087655 2 17478.4951087 7.79585928322 1.10123 19 20 
 i 21 109.170282337 2 17682.2477513 7.64385618977 1.10123 19 20 
 i 21 109.336537805 2 17707.7168319 7.79585928322 1.10123 19 20 
 i 21 109.494507834 2 17733.1859125 8.38082178394 1.10123 19 20 
 i 21 109.669908016 2 17758.654993 8.2288186905 1.10123 19 20 
 i 21 109.844055266 2 17784.1240736 8.38082178394 1.10123 19 20 
 i 21 110.009409316 2 17809.5931542 8.2288186905 1.10123 19 20 
 i 21 110.171401754 2 17835.0622348 8.38082178394 1.10123 19 20 
 i 21 110.339304123 2 17860.5313154 8.64385618977 1.10123 19 20 
 i 21 110.49365124 2 17886.000396 8.79585928322 1.10123 19 20 
 i 21 110.67323085 2 17911.4694766 8.64385618977 1.10123 19 20 
 i 21 110.827205179 2 17936.9385572 8.79585928322 1.10123 19 20 
 i 21 110.992400674 2 17962.4076377 9.38082178394 1.10123 19 20 
 i 21 111.173392805 2 17987.8767183 9.2288186905 1.10123 19 20 
 i 21 111.329511884 2 17961.7963792 9.38082178394 1.10123 19 20 
 i 21 111.507480064 2 17923.5927584 9.2288186905 1.10123 19 20 
 i 21 111.661711767 2 17885.3891376 9.38082178394 1.10123 19 20 
 i 21 111.823954291 2 17847.1855168 9.64385618977 1.10123 19 20 
 i 21 111.991354996 2 17808.981896 9.79585928322 1.10123 19 20 
 i 21 112.161541371 2 17770.7782752 9.64385618977 1.10123 19 20 
 i 21 112.332799752 2 17732.5746544 9.79585928322 1.10123 19 20 
 i 21 112.507656686 2 17694.3710336 10.3808217839 1.10123 19 20 
 i 21 112.661703477 2 17656.1674128 10.2288186905 1.10123 19 20 
 i 21 112.833090551 2 17617.963792 10.3808217839 1.10123 19 20 
 i 21 113.00955516 2 17579.7601712 10.2288186905 1.10123 19 20 
 i 21 113.165498381 2 17541.5565503 10.3808217839 1.10123 19 20 
 i 21 113.339746711 2 17503.3529295 10.6438561898 1.10123 19 20 
 i 21 113.507988161 2 17465.1493087 10.7958592832 1.10123 19 20 
 i 21 113.672446828 2 17426.9456879 10.6438561898 1.10123 19 20 
 i 21 113.826736202 2 17388.7420671 7.79586 1.10123 19 20 
 i 21 114.007879823 2 17350.5384463 10.7958592832 1.10123 19 20 
 i 21 114.16043267 2 17312.3348255 7.96578428466 1.10123 19 20 
 i 21 114.159226371 2 17274.1312047 11.3808217839 1.10123 19 20 
 i 21 114.338349974 2 17235.9275839 7.79585928322 1.10123 19 20 
 i 21 114.343472879 2 17197.7239631 11.2288186905 1.10123 19 20 
 i 21 114.504746835 2 17159.5203423 7.96578428466 1.10123 19 20 
 i 21 114.496424026 2 17121.3167215 11.3808217839 1.10123 19 20 
 i 21 114.668141418 2 17044.9094799 8.55074678538 1.10123 19 20 
 i 21 114.666364168 2 17006.7058591 11.2288186905 1.10123 19 20 
 i 21 114.843337439 2 16968.5022383 8.38082178394 1.10123 19 20 
 i 21 114.833852561 2 16930.2986175 8.55074678538 1.10123 19 20 
 i 21 114.992386157 2 16892.0949967 8.38082178394 1.10123 19 20 
 i 21 115.174506527 2 16853.8913759 8.55074678538 1.10123 19 20 
 i 21 115.328040462 2 16815.6877551 8.79585928322 1.10123 19 20 
 i 21 115.500828909 2 16777.4841343 8.96578428466 1.10123 19 20 
 i 21 115.662379876 2 16739.2805135 8.79585928322 1.10123 19 20 
 i 21 115.828584586 2 16701.0768927 8.96578428466 1.10123 19 20 
 i 21 115.996943305 2 16662.8732718 9.55074678538 1.10123 19 20 
 i 21 116.169844428 2 16624.669651 9.38082178394 1.10123 19 20 
 i 21 116.322874875 2 16586.4660302 9.55074678538 1.10123 19 20 
 i 21 116.510530998 2 16548.2624094 9.38082178394 1.10123 19 20 
 i 21 116.670117646 2 16510.0587886 9.55074678538 1.10123 19 20 
 i 21 116.828062771 2 16471.8551678 9.79585928322 1.10123 19 20 
 i 21 117.003169033 2 16433.651547 9.96578428466 1.10123 19 20 
 i 21 117.160345094 2 16395.4479262 9.79585928322 1.10123 19 20 
 i 21 117.325272499 2 16357.2443054 9.96578428466 1.10123 19 20 
 i 21 117.490210084 2 16319.0406846 10.5507467854 1.10123 19 20 
 i 21 117.663082205 2 16280.8370638 10.3808217839 1.10123 19 20 
 i 21 117.828419219 2 16242.633443 10.5507467854 1.10123 19 20 
 i 21 118.008977181 2 16204.4298222 10.3808217839 1.10123 19 20 
 i 21 118.173316184 2 16128.0225806 10.5507467854 1.10123 19 20 
 i 21 118.341231164 2 16089.8189598 10.7958592832 1.10123 19 20 
 i 21 118.490778029 2 16051.615339 10.9657842847 1.10123 19 20 
 i 21 118.669041573 2 16013.4117182 10.7958592832 1.10123 19 20 
 i 21 118.829657219 2 15975.2080974 10.9657842847 1.10123 19 20 
 i 21 118.993608583 2 15937.0044766 11.5507467854 1.10123 19 20 
 i 21 119.168657689 2 15898.8008558 11.3808217839 1.10123 19 20 
 i 21 119.325844836 2 15860.597235 11.5507467854 1.10123 19 20 
 i 21 119.489178053 2 15822.3936142 11.3808217839 1.10123 19 20 
 i 21 119.657788517 2 15784.1899933 7.05889 1.10123 19 20 
 i 21 119.841428371 2 15745.9863725 12.7027498788 1.10123 19 20 
 i 21 0.241167439423 2 15707.7827517 7.05889368905 1.10123 19 20 
 i 21 0.500884069674 2 15669.5791309 12.7027498788 1.10123 19 20 
 i 21 0.743064514326 2 15631.3755101 7.47393118833 1.10123 19 20 
 i 21 1.00602679868 2 15593.1718893 7.64385618977 1.10123 19 20 
 i 21 1.25560469065 2 15554.9682685 7.47393118833 1.10123 19 20 
 i 21 1.49579601843 2 15516.7646477 7.64385618977 1.10123 19 20 
 i 21 1.7514623079 2 15478.5610269 7.88896868761 1.10123 19 20 
 i 21 2.00113469889 2 15440.3574061 7.79585928322 1.10123 19 20 
 i 21 2.25610742397 2 15402.1537853 7.64385618977 1.10123 19 20 
 i 21 2.50822769128 2 15363.9501645 7.79585928322 1.10123 19 20 
 i 21 2.74758733625 2 15325.7465437 7.64385618977 1.10123 19 20 
 i 21 3.00620288964 2 15287.5429229 8.2288186905 1.10123 19 20 
 i 21 3.25004592378 2 15211.1356813 8.38082178394 1.10123 19 20 
 i 21 3.49898263672 2 15172.9320605 8.2288186905 1.10123 19 20 
 i 21 3.75141824803 2 15134.7284397 8.38082178394 1.10123 19 20 
 i 21 3.99957602011 2 15096.5248189 8.64385618977 1.10123 19 20 
 i 21 4.25912869488 2 15058.3211981 8.55074678538 1.10123 19 20 
 i 21 4.49034116394 2 15020.1175773 8.38082178394 1.10123 19 20 
 i 21 4.7394346031 2 14981.9139565 8.55074678538 1.10123 19 20 
 i 21 4.99203644557 2 14943.7103357 8.38082178394 1.10123 19 20 
 i 21 5.25828855998 2 14905.5067148 8.96578428466 1.10123 19 20 
 i 21 5.5088044227 2 14867.303094 7.22882 1.10123 19 20 
 i 21 5.75932467921 2 14829.0994732 7.05889368905 1.10123 19 20 
 i 21 6.25043938615 2 14790.8958524 7.2288186905 1.10123 19 20 
 i 21 6.48935418127 2 14752.6922316 7.05889368905 1.10123 19 20 
 i 21 6.75902449298 2 14714.4886108 7.64385618977 1.10123 19 20 
 i 21 7.00354168153 2 14676.28499 7.79585928322 1.10123 19 20 
 i 21 7.25138229123 2 14638.0813692 7.64385618977 1.10123 19 20 
 i 21 7.50336896998 2 14599.8777484 7.79585928322 1.10123 19 20 
 i 21 7.76078049401 2 14561.6741276 8.05889368905 1.10123 19 20 
 i 21 8.0035532014 2 14523.4705068 7.96578428466 1.10123 19 20 
 i 21 8.25560544663 2 14485.266886 7.79585928322 1.10123 19 20 
 i 21 8.50867710126 2 14447.0632652 7.96578428466 1.10123 19 20 
 i 21 8.74872390234 2 14408.8596444 7.79585928322 1.10123 19 20 
 i 21 9.00262622346 2 14370.6560236 8.38082178394 1.10123 19 20 
 i 21 9.25080831011 2 14294.248782 8.55074678538 1.10123 19 20 
 i 21 9.49615897367 2 14256.0451612 8.38082178394 1.10123 19 20 
 i 21 9.73911894097 2 14217.8415404 8.55074678538 1.10123 19 20 
 i 21 9.99640332536 2 14179.6379196 8.79585928322 1.10123 19 20 
 i 21 10.2412723555 2 14141.4342988 8.70274987883 1.10123 19 20 
 i 21 10.5035179498 2 14103.230678 8.55074678538 1.10123 19 20 
 i 21 10.7567888659 2 14065.0270572 8.70274987883 1.10123 19 20 
 i 21 11.0042103011 2 14026.8234363 8.55074678538 1.10123 19 20 
 i 21 11.2445243086 2 13988.6198155 9.11778737811 1.10123 19 20 
 i 21 11.4931576827 2 13950.4161947 7.05889 1.10123 19 20 
 i 21 11.7588630914 2 13912.2125739 12.7027498788 1.10123 19 20 
 i 21 12.2489865969 2 13874.0089531 7.05889368905 1.10123 19 20 
 i 21 12.4933234002 2 13835.8053323 12.7027498788 1.10123 19 20 
 i 21 12.7418692174 2 13797.6017115 7.47393118833 1.10123 19 20 
 i 21 13.0069112316 2 13759.3980907 7.64385618977 1.10123 19 20 
 i 21 13.2474793671 2 13721.1944699 7.47393118833 1.10123 19 20 
 i 21 13.5024365511 2 13682.9908491 7.64385618977 1.10123 19 20 
 i 21 13.7529287936 2 13644.7872283 7.88896868761 1.10123 19 20 
 i 21 13.989753809 2 13606.5836075 7.79585928322 1.10123 19 20 
 i 21 14.2460081791 2 13568.3799867 7.64385618977 1.10123 19 20 
 i 21 14.4919037588 2 13530.1763659 7.79585928322 1.10123 19 20 
 i 21 14.753402179 2 13491.9727451 7.64385618977 1.10123 19 20 
 i 21 14.9906798059 2 13453.7691243 8.2288186905 1.10123 19 20 
 i 21 15.2394000968 2 13377.3618827 8.38082178394 1.10123 19 20 
 i 21 15.5088451742 2 13339.1582619 8.2288186905 1.10123 19 20 
 i 21 15.7412550314 2 13300.9546411 8.38082178394 1.10123 19 20 
 i 21 15.9969201289 2 13262.7510203 8.64385618977 1.10123 19 20 
 i 21 16.2497264639 2 13224.5473995 8.55074678538 1.10123 19 20 
 i 21 16.4906643652 2 13186.3437787 8.38082178394 1.10123 19 20 
 i 21 16.7438258107 2 13148.1401578 8.55074678538 1.10123 19 20 
 i 21 17.0059352183 2 13109.936537 8.38082178394 1.10123 19 20 
 i 21 17.2393846057 2 13071.7329162 8.96578428466 1.10123 19 20 
 i 21 17.5008427127 2 13033.5292954 7.22882 1.10123 19 20 
 i 21 17.7589277232 2 12995.3256746 7.05889368905 1.10123 19 20 
 i 21 18.2515784443 2 12957.1220538 7.2288186905 1.10123 19 20 
 i 21 18.4923485921 2 12918.918433 7.05889368905 1.10123 19 20 
 i 21 18.7507578659 2 12880.7148122 7.64385618977 1.10123 19 20 
 i 21 19.003338924 2 12842.5111914 7.79585928322 1.10123 19 20 
 i 21 19.243916873 2 12804.3075706 7.64385618977 1.10123 19 20 
 i 21 19.5044224568 2 12766.1039498 7.79585928322 1.10123 19 20 
 i 21 19.7548817888 2 12727.900329 8.05889368905 1.10123 19 20 
 i 21 19.9987297319 2 12689.6967082 7.96578428466 1.10123 19 20 
 i 21 20.2551274412 2 12651.4930874 7.79585928322 1.10123 19 20 
 i 21 20.5030660598 2 12613.2894666 7.96578428466 1.10123 19 20 
 i 21 20.7565170946 2 12575.0858458 7.79585928322 1.10123 19 20 
 i 21 20.9980902339 2 12536.882225 8.38082178394 1.10123 19 20 
 i 21 21.2511406061 2 12460.4749834 8.55074678538 1.10123 19 20 
 i 21 21.4999802951 2 12422.2713626 8.38082178394 1.10123 19 20 
 i 21 21.7591908688 2 12384.0677418 8.55074678538 1.10123 19 20 
 i 21 21.9962403005 2 12345.864121 8.79585928322 1.10123 19 20 
 i 21 22.239277768 2 12307.6605002 8.70274987883 1.10123 19 20 
 i 21 22.4893349957 2 12269.4568793 8.55074678538 1.10123 19 20 
 i 21 22.7559761159 2 12231.2532585 8.70274987883 1.10123 19 20 
 i 21 23.0084764901 2 12193.0496377 8.55074678538 1.10123 19 20 
 i 21 23.2520669214 2 12154.8460169 9.11778737811 1.10123 19 20 
 i 21 23.5093997197 2 12116.6423961 7.05889 1.10123 19 20 
 i 21 23.7477277126 2 12078.4387753 12.7027498788 1.10123 19 20 
 i 21 24.2599465086 2 12040.2351545 7.05889368905 1.10123 19 20 
 i 21 24.5061871017 2 12002.0315337 12.7027498788 1.10123 19 20 
 i 21 24.7462166957 2 11963.8279129 7.47393118833 1.10123 19 20 
 i 21 25.0055027552 2 11925.6242921 7.64385618977 1.10123 19 20 
 i 21 25.2549725284 2 11887.4206713 7.47393118833 1.10123 19 20 
 i 21 25.5010248693 2 11849.2170505 7.64385618977 1.10123 19 20 
 i 21 25.7439246493 2 11811.0134297 7.88896868761 1.10123 19 20 
 i 21 25.9980701388 2 11772.8098089 7.79585928322 1.10123 19 20 
 i 21 26.2526421122 2 11734.6061881 7.64385618977 1.10123 19 20 
 i 21 26.4916832679 2 11696.4025673 7.79585928322 1.10123 19 20 
 i 21 26.7573712942 2 11658.1989465 7.64385618977 1.10123 19 20 
 i 21 26.9969068208 2 11619.9953257 8.2288186905 1.10123 19 20 
 i 21 27.2602486713 2 11543.5880841 8.38082178394 1.10123 19 20 
 i 21 27.4999893672 2 11505.3844633 8.2288186905 1.10123 19 20 
 i 21 27.7469561328 2 11467.1808425 8.38082178394 1.10123 19 20 
 i 21 27.9954418195 2 11428.9772217 8.64385618977 1.10123 19 20 
 i 21 28.247877024 2 11390.7736008 8.55074678538 1.10123 19 20 
 i 21 28.4986050763 2 11352.56998 8.38082178394 1.10123 19 20 
 i 21 28.7401575569 2 11314.3663592 8.55074678538 1.10123 19 20 
 i 21 29.0062447534 2 11276.1627384 8.38082178394 1.10123 19 20 
 i 21 29.2404592669 2 11237.9591176 8.96578428466 1.10123 19 20 
 i 21 29.5053578816 2 11199.7554968 7.22882 1.10123 19 20 
 i 21 29.7603408404 2 11161.551876 7.05889368905 1.10123 19 20 
 i 21 30.2496141418 2 11123.3482552 7.2288186905 1.10123 19 20 
 i 21 30.490188813 2 11085.1446344 7.05889368905 1.10123 19 20 
 i 21 30.7537801239 2 11046.9410136 7.64385618977 1.10123 19 20 
 i 21 31.0024389124 2 11008.7373928 7.79585928322 1.10123 19 20 
 i 21 31.2404371773 2 10970.533772 7.64385618977 1.10123 19 20 
 i 21 31.5041834579 2 10932.3301512 7.79585928322 1.10123 19 20 
 i 21 31.7589712395 2 10894.1265304 8.05889368905 1.10123 19 20 
 i 21 31.996469173 2 10855.9229096 7.96578428466 1.10123 19 20 
 i 21 32.255969142 2 10817.7192888 7.79585928322 1.10123 19 20 
 i 21 32.4935896322 2 10779.515668 7.96578428466 1.10123 19 20 
 i 21 32.7464616716 2 10741.3120472 7.79585928322 1.10123 19 20 
 i 21 32.9971477536 2 10703.1084264 8.38082178394 1.10123 19 20 
 i 21 33.2479900714 2 10626.7011848 8.55074678538 1.10123 19 20 
 i 21 33.4912003484 2 10588.497564 8.38082178394 1.10123 19 20 
 i 21 33.7524184286 2 10550.2939432 8.55074678538 1.10123 19 20 
 i 21 33.9929440927 2 10512.0903223 8.79585928322 1.10123 19 20 
 i 21 34.2410916293 2 10473.8867015 8.70274987883 1.10123 19 20 
 i 21 34.4992373524 2 10435.6830807 8.55074678538 1.10123 19 20 
 i 21 34.7412385963 2 10397.4794599 8.70274987883 1.10123 19 20 
 i 21 35.0036094884 2 10359.2758391 8.55074678538 1.10123 19 20 
 i 21 35.2399420172 2 10321.0722183 9.11778737811 1.10123 19 20 
 i 21 35.4913518467 2 10282.8685975 7.05889 1.10123 19 20 
 i 21 35.7554558357 2 10244.6649767 12.7027498788 1.10123 19 20 
 i 21 36.2419238207 2 10206.4613559 7.05889368905 1.10123 19 20 
 i 21 36.5059865432 2 10168.2577351 12.7027498788 1.10123 19 20 
 i 21 36.7426813661 2 10130.0541143 7.47393118833 1.10123 19 20 
 i 21 36.9982760599 2 10091.8504935 7.64385618977 1.10123 19 20 
 i 21 37.2501234011 2 10053.6468727 7.47393118833 1.10123 19 20 
 i 21 37.5100472623 2 10015.4432519 7.64385618977 1.10123 19 20 
 i 21 37.7583983182 2 9977.23963109 7.88896868761 1.10123 19 20 
 i 21 37.999393292 2 9939.03601028 7.79585928322 1.10123 19 20 
 i 21 38.253576859 2 9900.83238948 7.64385618977 1.10123 19 20 
 i 21 38.5109339735 2 9862.62876867 7.79585928322 1.10123 19 20 
 i 21 38.7427588563 2 9824.42514787 7.64385618977 1.10123 19 20 
 i 21 38.9894003885 2 9786.22152707 8.2288186905 1.10123 19 20 
 i 21 39.25314435 2 9709.81428546 8.38082178394 1.10123 19 20 
 i 21 39.4917174635 2 9671.61066465 8.2288186905 1.10123 19 20 
 i 21 39.7528094087 2 9633.40704385 8.38082178394 1.10123 19 20 
 i 21 39.9939103291 2 9595.20342304 8.64385618977 1.10123 19 20 
 i 21 40.242187822 2 9556.99980224 8.55074678538 1.10123 19 20 
 i 21 40.4955800395 2 9518.79618144 8.38082178394 1.10123 19 20 
 i 21 40.7444061027 2 9480.59256063 8.55074678538 1.10123 19 20 
 i 21 41.0007636021 2 9442.38893983 8.38082178394 1.10123 19 20 
 i 21 41.2582528908 2 9404.18531902 8.96578428466 1.10123 19 20 
 i 21 41.4976904295 2 9365.98169822 7.22882 1.10123 19 20 
 i 21 41.7485553944 2 9327.77807741 7.05889368905 1.10123 19 20 
 i 21 42.2483318814 2 9289.57445661 7.2288186905 1.10123 19 20 
 i 21 42.5034228952 2 9251.37083581 7.05889368905 1.10123 19 20 
 i 21 42.7608591135 2 9213.167215 7.64385618977 1.10123 19 20 
 i 21 42.9947380504 2 9174.9635942 7.79585928322 1.10123 19 20 
 i 21 43.2589332134 2 9136.75997339 7.64385618977 1.10123 19 20 
 i 21 43.5002516796 2 9098.55635259 7.79585928322 1.10123 19 20 
 i 21 43.7392582479 2 9060.35273178 8.05889368905 1.10123 19 20 
 i 21 44.0014685767 2 9022.14911098 7.96578428466 1.10123 19 20 
 i 21 44.2547251381 2 8983.94549017 7.79585928322 1.10123 19 20 
 i 21 44.5107857711 2 8945.74186937 7.96578428466 1.10123 19 20 
 i 21 44.7499608273 2 8907.53824857 7.79585928322 1.10123 19 20 
 i 21 45.0074387617 2 8869.33462776 8.38082178394 1.10123 19 20 
 i 21 45.2567162375 2 8792.92738615 8.55074678538 1.10123 19 20 
 i 21 45.4942786129 2 8754.72376535 8.38082178394 1.10123 19 20 
 i 21 45.7519954118 2 8716.52014454 8.55074678538 1.10123 19 20 
 i 21 46.0071341165 2 8678.31652374 8.79585928322 1.10123 19 20 
 i 21 46.2482331919 2 8640.11290294 8.70274987883 1.10123 19 20 
 i 21 46.5071538004 2 8601.90928213 8.55074678538 1.10123 19 20 
 i 21 46.7443709856 2 8563.70566133 8.70274987883 1.10123 19 20 
 i 21 47.0095814416 2 8525.50204052 8.55074678538 1.10123 19 20 
 i 21 47.2520736712 2 8487.29841972 9.11778737811 1.10123 19 20 
 i 21 47.5050796597 2 8449.09479891 7.05889 1.10123 19 20 
 i 21 47.7574235008 2 8410.89117811 12.7027498788 1.10123 19 20 
 i 21 48.244210059 2 8372.68755731 7.05889368905 1.10123 19 20 
 i 21 48.5099835166 2 8334.4839365 12.7027498788 1.10123 19 20 
 i 21 48.7460759876 2 8296.2803157 7.47393118833 1.10123 19 20 
 i 21 48.9997771166 2 8258.07669489 7.64385618977 1.10123 19 20 
 i 21 49.2434800162 2 8219.87307409 7.47393118833 1.10123 19 20 
 i 21 49.5016262357 2 8181.66945328 7.64385618977 1.10123 19 20 
 i 21 49.7583336344 2 8143.46583248 7.88896868761 1.10123 19 20 
 i 21 50.0004312788 2 8105.26221168 7.79585928322 1.10123 19 20 
 i 21 50.2607027179 2 8067.05859087 7.64385618977 1.10123 19 20 
 i 21 50.5054787629 2 8028.85497007 7.79585928322 1.10123 19 20 
 i 21 50.7491841972 2 7990.65134926 7.64385618977 1.10123 19 20 
 i 21 50.990045044 2 7952.44772846 8.2288186905 1.10123 19 20 
 i 21 51.248396258 2 7876.04048685 8.38082178394 1.10123 19 20 
 i 21 51.4965948993 2 7837.83686604 8.2288186905 1.10123 19 20 
 i 21 51.755499941 2 7799.63324524 8.38082178394 1.10123 19 20 
 i 21 51.9913065262 2 7761.42962444 8.64385618977 1.10123 19 20 
 i 21 52.244769748 2 7723.22600363 8.55074678538 1.10123 19 20 
 i 21 52.4920692832 2 7685.02238283 8.38082178394 1.10123 19 20 
 i 21 52.748027555 2 7646.81876202 8.55074678538 1.10123 19 20 
 i 21 52.9922024354 2 7608.61514122 8.38082178394 1.10123 19 20 
 i 21 53.2512507465 2 7570.41152041 8.96578428466 1.10123 19 20 
 i 21 53.5039050129 2 7532.20789961 7.22882 1.10123 19 20 
 i 21 53.7455768968 2 7494.00427881 7.05889368905 1.10123 19 20 
 i 21 54.2449442188 2 7455.800658 7.2288186905 1.10123 19 20 
 i 21 54.5075028142 2 7417.5970372 7.05889368905 1.10123 19 20 
 i 21 54.7526772232 2 7379.39341639 7.64385618977 1.10123 19 20 
 i 21 54.9905954282 2 7341.18979559 7.79585928322 1.10123 19 20 
 i 21 55.2427231702 2 7302.98617478 7.64385618977 1.10123 19 20 
 i 21 55.5031109056 2 7264.78255398 7.79585928322 1.10123 19 20 
 i 21 55.7420705526 2 7226.57893318 8.05889368905 1.10123 19 20 
 i 21 56.0041129088 2 7188.37531237 7.96578428466 1.10123 19 20 
 i 21 56.2598702903 2 7150.17169157 7.79585928322 1.10123 19 20 
 i 21 56.5003132791 2 7111.96807076 7.96578428466 1.10123 19 20 
 i 21 56.7458115078 2 7073.76444996 7.79585928322 1.10123 19 20 
 i 21 56.997543558 2 7035.56082915 8.38082178394 1.10123 19 20 
 i 21 57.2457536193 2 6959.15358754 8.55074678538 1.10123 19 20 
 i 21 57.5039386624 2 6920.94996674 8.38082178394 1.10123 19 20 
 i 21 57.7609616817 2 6882.74634594 8.55074678538 1.10123 19 20 
 i 21 58.0109353092 2 6844.54272513 8.79585928322 1.10123 19 20 
 i 21 58.256062921 2 6806.33910433 8.70274987883 1.10123 19 20 
 i 21 58.5037326569 2 6768.13548352 8.55074678538 1.10123 19 20 
 i 21 58.7455728662 2 6729.93186272 8.70274987883 1.10123 19 20 
 i 21 59.009608547 2 6691.72824191 8.55074678538 1.10123 19 20 
 i 21 59.2419949084 2 6653.52462111 9.11778737811 1.10123 19 20 
 i 21 59.5004953428 2 6615.32100031 7.05889 1.10123 19 20 
 i 21 59.7588098281 2 6577.1173795 12.7027498788 1.10123 19 20 
 i 21 60.2516456955 2 6538.9137587 7.05889368905 1.10123 19 20 
 i 21 60.5098309899 2 6500.71013789 12.7027498788 1.10123 19 20 
 i 21 60.7485169666 2 6462.50651709 7.47393118833 1.10123 19 20 
 i 21 61.01013566 2 6424.30289628 7.64385618977 1.10123 19 20 
 i 21 61.2518444832 2 6386.09927548 7.47393118833 1.10123 19 20 
 i 21 61.5051240667 2 6347.89565468 7.64385618977 1.10123 19 20 
 i 21 61.7417003152 2 6309.69203387 7.88896868761 1.10123 19 20 
 i 21 61.9891393041 2 6271.48841307 7.79585928322 1.10123 19 20 
 i 21 62.2588728167 2 6233.28479226 7.64385618977 1.10123 19 20 
 i 21 62.4996096181 2 6195.08117146 7.79585928322 1.10123 19 20 
 i 21 62.756875367 2 6156.87755065 7.64385618977 1.10123 19 20 
 i 21 62.9933486636 2 6118.67392985 8.2288186905 1.10123 19 20 
 i 21 63.254378569 2 6042.26668824 8.38082178394 1.10123 19 20 
 i 21 63.505698396 2 6004.06306744 8.2288186905 1.10123 19 20 
 i 21 63.7544377889 2 5965.85944663 8.38082178394 1.10123 19 20 
 i 21 64.0049109611 2 5927.65582583 8.64385618977 1.10123 19 20 
 i 21 64.2525671061 2 5889.45220502 8.55074678538 1.10123 19 20 
 i 21 64.4984361018 2 5851.24858422 8.38082178394 1.10123 19 20 
 i 21 64.7542591554 2 5813.04496341 8.55074678538 1.10123 19 20 
 i 21 64.9947064958 2 5774.84134261 8.38082178394 1.10123 19 20 
 i 21 65.2504920456 2 5736.63772181 8.96578428466 1.10123 19 20 
 i 21 65.4956872015 2 5698.434101 7.22882 1.10123 19 20 
 i 21 65.7608005701 2 5660.2304802 7.05889368905 1.10123 19 20 
 i 21 66.2533142365 2 5622.02685939 7.2288186905 1.10123 19 20 
 i 21 66.5033344102 2 5583.82323859 7.05889368905 1.10123 19 20 
 i 21 66.7428868838 2 5545.61961778 7.64385618977 1.10123 19 20 
 i 21 67.0109912058 2 5507.41599698 7.79585928322 1.10123 19 20 
 i 21 67.2525060317 2 5469.21237618 7.64385618977 1.10123 19 20 
 i 21 67.4967587705 2 5431.00875537 7.79585928322 1.10123 19 20 
 i 21 67.7503449555 2 5392.80513457 8.05889368905 1.10123 19 20 
 i 21 68.0017184546 2 5354.60151376 7.96578428466 1.10123 19 20 
 i 21 68.255205264 2 5316.39789296 7.79585928322 1.10123 19 20 
 i 21 68.5066366961 2 5278.19427215 7.96578428466 1.10123 19 20 
 i 21 68.7521722658 2 5239.99065135 7.79585928322 1.10123 19 20 
 i 21 68.9915692641 2 5201.78703054 8.38082178394 1.10123 19 20 
 i 21 69.2434796536 2 5125.37978894 8.55074678538 1.10123 19 20 
 i 21 69.4892647291 2 5087.17616813 8.38082178394 1.10123 19 20 
 i 21 69.746251 2 5048.97254733 8.55074678538 1.10123 19 20 
 i 21 69.989459119 2 5010.76892652 8.79585928322 1.10123 19 20 
 i 21 70.2537338674 2 4972.56530572 8.70274987883 1.10123 19 20 
 i 21 70.5014334268 2 4934.36168491 8.55074678538 1.10123 19 20 
 i 21 70.7571562856 2 4896.15806411 8.70274987883 1.10123 19 20 
 i 21 71.0038892269 2 4857.95444331 8.55074678538 1.10123 19 20 
 i 21 71.2394292873 2 4819.7508225 9.11778737811 1.10123 19 20 
 i 21 71.5056711564 2 4781.5472017 7.05889 1.10123 19 20 
 i 21 71.7440265124 2 4743.34358089 12.7027498788 1.10123 19 20 
 i 21 72.2416126827 2 4705.13996009 7.05889368905 1.10123 19 20 
 i 21 72.5004925679 2 4666.93633928 12.7027498788 1.10123 19 20 
 i 21 72.7408614243 2 4628.73271848 7.47393118833 1.10123 19 20 
 i 21 73.005167433 2 4590.52909768 7.64385618977 1.10123 19 20 
 i 21 73.2465240471 2 4552.32547687 7.47393118833 1.10123 19 20 
 i 21 73.5025274422 2 4514.12185607 7.64385618977 1.10123 19 20 
 i 21 73.7455245442 2 4475.91823526 7.88896868761 1.10123 19 20 
 i 21 74.0058177929 2 4437.71461446 7.79585928322 1.10123 19 20 
 i 21 74.2494980001 2 4399.51099365 7.64385618977 1.10123 19 20 
 i 21 74.4934348317 2 4361.30737285 7.79585928322 1.10123 19 20 
 i 21 74.7602156666 2 4323.10375205 7.64385618977 1.10123 19 20 
 i 21 75.0039477733 2 4284.90013124 8.2288186905 1.10123 19 20 
 i 21 75.2468076996 2 4208.49288963 8.38082178394 1.10123 19 20 
 i 21 75.5058208515 2 4170.28926883 8.2288186905 1.10123 19 20 
 i 21 75.7528756728 2 4132.08564802 8.38082178394 1.10123 19 20 
 i 21 75.998373983 2 4093.88202722 8.64385618977 1.10123 19 20 
 i 21 76.2558352804 2 4055.67840641 8.55074678538 1.10123 19 20 
 i 21 76.4976672112 2 4017.47478561 8.38082178394 1.10123 19 20 
 i 21 76.7413621748 2 3979.27116481 8.55074678538 1.10123 19 20 
 i 21 76.9936021787 2 3941.067544 8.38082178394 1.10123 19 20 
 i 21 77.2502480083 2 3902.8639232 8.96578428466 1.10123 19 20 
 i 21 77.5007185709 2 3864.66030239 7.22882 1.10123 19 20 
 i 21 77.7512107778 2 3826.45668159 7.05889368905 1.10123 19 20 
 i 21 78.254303934 2 3788.25306078 7.2288186905 1.10123 19 20 
 i 21 78.5104602881 2 3750.04943998 7.05889368905 1.10123 19 20 
 i 21 78.7560507638 2 3711.84581918 7.64385618977 1.10123 19 20 
 i 21 79.0052772104 2 3673.64219837 7.79585928322 1.10123 19 20 
 i 21 79.2525687864 2 3635.43857757 7.64385618977 1.10123 19 20 
 i 21 79.5052332317 2 3597.23495676 7.79585928322 1.10123 19 20 
 i 21 79.7567330066 2 3559.03133596 8.05889368905 1.10123 19 20 
 i 21 80.0015720492 2 3520.82771515 7.96578428466 1.10123 19 20 
 i 21 80.260240033 2 3482.62409435 7.79585928322 1.10123 19 20 
 i 21 80.4974950409 2 3444.42047355 7.96578428466 1.10123 19 20 
 i 21 80.754436745 2 3406.21685274 7.79585928322 1.10123 19 20 
 i 21 80.9982251241 2 3368.01323194 8.38082178394 1.10123 19 20 
 i 21 81.2442749219 2 3291.60599033 8.55074678538 1.10123 19 20 
 i 21 81.493784617 2 3253.40236952 8.38082178394 1.10123 19 20 
 i 21 81.7457190486 2 3215.19874872 8.55074678538 1.10123 19 20 
 i 21 82.0034981071 2 3176.99512791 8.79585928322 1.10123 19 20 
 i 21 82.2418318912 2 3138.79150711 8.70274987883 1.10123 19 20 
 i 21 82.4927197203 2 3100.58788631 8.55074678538 1.10123 19 20 
 i 21 82.7604877953 2 3062.3842655 8.70274987883 1.10123 19 20 
 i 21 82.9947602863 2 3024.1806447 8.55074678538 1.10123 19 20 
 i 21 83.248764583 2 2985.97702389 9.11778737811 1.10123 19 20 
 i 21 83.5042025733 2 2947.77340309 7.05889 1.10123 19 20 
 i 21 83.7501853527 2 2909.56978228 12.7027498788 1.10123 19 20 
 i 21 84.2495260438 2 2871.36616148 7.05889368905 1.10123 19 20 
 i 21 84.4937507255 2 2833.16254068 12.7027498788 1.10123 19 20 
 i 21 84.7490848707 2 2794.95891987 7.47393118833 1.10123 19 20 
 i 21 85.0104095644 2 2756.75529907 7.64385618977 1.10123 19 20 
 i 21 85.2462737513 2 2718.55167826 7.47393118833 1.10123 19 20 
 i 21 85.5065387228 2 2680.34805746 7.64385618977 1.10123 19 20 
 i 21 85.7462762875 2 2642.14443665 7.88896868761 1.10123 19 20 
 i 21 86.0105094723 2 2603.94081585 7.79585928322 1.10123 19 20 
 i 21 86.2605844952 2 2565.73719505 7.64385618977 1.10123 19 20 
 i 21 86.4948424671 2 2527.53357424 7.79585928322 1.10123 19 20 
 i 21 86.7410982513 2 2489.32995344 7.64385618977 1.10123 19 20 
 i 21 87.0082271785 2 2451.12633263 8.2288186905 1.10123 19 20 
 i 21 87.2533486801 2 2374.71909102 8.38082178394 1.10123 19 20 
 i 21 87.493583259 2 2336.51547022 8.2288186905 1.10123 19 20 
 i 21 87.746040123 2 2298.31184941 8.38082178394 1.10123 19 20 
 i 21 87.9919861873 2 2260.10822861 8.64385618977 1.10123 19 20 
 i 21 88.2578330391 2 2221.90460781 8.55074678538 1.10123 19 20 
 i 21 88.510831753 2 2183.700987 8.38082178394 1.10123 19 20 
 i 21 88.741769555 2 2145.4973662 8.55074678538 1.10123 19 20 
 i 21 88.9904199093 2 2107.29374539 8.38082178394 1.10123 19 20 
 i 21 89.2515662566 2 2069.09012459 8.96578428466 1.10123 19 20 
 i 21 89.5025678692 2 2030.88650378 7.22882 1.10123 19 20 
 i 21 89.7411973574 2 1992.68288298 7.05889368905 1.10123 19 20 
 i 21 90.256756016 2 1954.47926218 7.2288186905 1.10123 19 20 
 i 21 90.4894546729 2 1916.27564137 7.05889368905 1.10123 19 20 
 i 21 90.7560698348 2 1878.07202057 7.64385618977 1.10123 19 20 
 i 21 90.9946013762 2 1839.86839976 7.79585928322 1.10123 19 20 
 i 21 91.2591647995 2 1801.66477896 7.64385618977 1.10123 19 20 
 i 21 91.4990661744 2 1763.46115815 7.79585928322 1.10123 19 20 
 i 21 91.742650568 2 1725.25753735 8.05889368905 1.10123 19 20 
 i 21 92.0095615573 2 1687.05391655 7.96578428466 1.10123 19 20 
 i 21 92.2506435552 2 1648.85029574 7.79585928322 1.10123 19 20 
 i 21 92.5087944211 2 1610.64667494 7.96578428466 1.10123 19 20 
 i 21 92.740441854 2 1572.44305413 7.79585928322 1.10123 19 20 
 i 21 93.0015907146 2 1534.23943333 8.38082178394 1.10123 19 20 
 i 21 93.2435308818 2 1457.83219172 8.55074678538 1.10123 19 20 
 i 21 93.5015467792 2 1419.62857091 8.38082178394 1.10123 19 20 
 i 21 93.751793284 2 1381.42495011 8.55074678538 1.10123 19 20 
 i 21 94.0105481843 2 1343.22132931 8.79585928322 1.10123 19 20 
 i 21 94.2518654179 2 1305.0177085 8.70274987883 1.10123 19 20 
 i 21 94.5101220895 2 1266.8140877 8.55074678538 1.10123 19 20 
 i 21 94.760004126 2 1228.61046689 8.70274987883 1.10123 19 20 
 i 21 94.9925969292 2 1190.40684609 8.55074678538 1.10123 19 20 
 i 21 95.2465332793 2 1152.20322528 9.11778737811 1.10123 19 20 
 i 21 95.495483899 2 1113.99960448 7.05889 1.10123 19 20 
 i 21 95.7426290974 2 1075.79598368 12.7027498788 1.10123 19 20 
 i 21 96.2591025203 2 1037.59236287 7.05889368905 1.10123 19 20 
 i 21 96.5036972153 2 15000 12.7027498788 1.10123 19 20 
 i 21 96.7420541528 2 15000 7.47393118833 1.10123 19 20 
 i 21 96.9958712353 2 15000 7.64385618977 1.10123 19 20 
 i 21 97.242772285 2 15000 7.47393118833 1.10123 19 20 
 i 21 97.5034476585 2 15000 7.64385618977 1.10123 19 20 
 i 21 97.7538397196 2 15000 7.88896868761 1.10123 19 20 
 i 21 97.9908038428 2 15000 7.79585928322 1.10123 19 20 
 i 21 98.2594154572 2 15000 7.64385618977 1.10123 19 20 
 i 21 98.4903577126 2 15000 7.79585928322 1.10123 19 20 
 i 21 98.7601921478 2 15000 7.64385618977 1.10123 19 20 
 i 21 99.0066095158 2 15000 8.2288186905 1.10123 19 20 
 i 21 99.2427464544 2 15000 8.38082178394 1.10123 19 20 
 i 21 99.4940641839 2 15000 8.2288186905 1.10123 19 20 
 i 21 99.7581250625 2 15000 8.38082178394 1.10123 19 20 
 i 21 99.9932717299 2 15000 8.64385618977 1.10123 19 20 
 i 21 100.249061524 2 15000 8.55074678538 1.10123 19 20 
 i 21 100.50392699 2 15000 8.38082178394 1.10123 19 20 
 i 21 100.742627303 2 15000 8.55074678538 1.10123 19 20 
 i 21 101.005152665 2 1450.08472183 8.38082178394 1.10123 19 20 
 i 21 101.246668137 2 1500.09413537 8.96578428466 1.10123 19 20 
 i 21 101.497745181 2 1550.1035489 7.22882 1.10123 19 20 
 i 21 101.754208589 2 1600.11296244 7.05889368905 1.10123 19 20 
 i 21 102.252296595 2 1650.12237598 7.2288186905 1.10123 19 20 
 i 21 102.502454869 2 1700.13178951 7.05889368905 1.10123 19 20 
 i 21 102.755552579 2 1750.14120305 7.64385618977 1.10123 19 20 
 i 21 102.989256905 2 1800.15061659 7.79585928322 1.10123 19 20 
 i 21 103.25565065 2 1850.16003012 7.64385618977 1.10123 19 20 
 i 21 103.496853897 2 1900.16944366 7.79585928322 1.10123 19 20 
 i 21 103.757929069 2 1950.1788572 8.05889368905 1.10123 19 20 
 i 21 104.00476938 2 2000.18827073 7.96578428466 1.10123 19 20 
 i 21 104.249772975 2 2050.19768427 7.79585928322 1.10123 19 20 
 i 21 104.499957404 2 2100.20709781 7.96578428466 1.10123 19 20 
 i 21 104.739569975 2 2150.21651134 7.79585928322 1.10123 19 20 
 i 21 104.995045891 2 2200.22592488 8.38082178394 1.10123 19 20 
 i 21 105.247245341 2 2250.23533842 8.55074678538 1.10123 19 20 
 i 21 105.491027997 2 2300.24475195 8.38082178394 1.10123 19 20 
 i 21 105.755211926 2 2350.25416549 8.55074678538 1.10123 19 20 
 i 21 105.99905175 2 2400.26357903 8.79585928322 1.10123 19 20 
 i 21 106.240875176 2 2450.27299256 8.70274987883 1.10123 19 20 
 i 21 106.510079812 2 2500.2824061 8.55074678538 1.10123 19 20 
 i 21 106.754851462 2 2550.29181964 8.70274987883 1.10123 19 20 
 i 21 107.007520467 2 2600.30123317 8.55074678538 1.10123 19 20 
 i 21 107.258728939 2 2650.31064671 9.11778737811 1.10123 19 20 
 i 21 107.494732546 2 2700.32006025 7.05889 1.10123 19 20 
 i 21 107.753741155 2 2750.32947378 12.7027498788 1.10123 19 20 
 i 21 108.257279328 2 2800.33888732 7.05889368905 1.10123 19 20 
 i 21 108.50172842 2 2850.34830086 12.7027498788 1.10123 19 20 
 i 21 108.739087624 2 2900.35771439 7.47393118833 1.10123 19 20 
 i 21 109.0084971 2 2950.36712793 7.64385618977 1.10123 19 20 
 i 21 109.259431808 2 3450.4612633 7.47393118833 1.10123 19 20 
 i 21 109.505601955 2 3500.47067683 7.64385618977 1.10123 19 20 
 i 21 109.758286707 2 3550.48009037 7.88896868761 1.10123 19 20 
 i 21 110.008420453 2 3600.48950391 7.79585928322 1.10123 19 20 
 i 21 110.251284559 2 3650.49891744 7.64385618977 1.10123 19 20 
 i 21 110.507516399 2 3700.50833098 7.79585928322 1.10123 19 20 
 i 21 110.752013366 2 3750.51774452 7.64385618977 1.10123 19 20 
 i 21 111.006140203 2 3800.52715805 8.2288186905 1.10123 19 20 
 i 21 111.25282754 2 3850.53657159 8.38082178394 1.10123 19 20 
 i 21 111.490871743 2 3900.54598513 8.2288186905 1.10123 19 20 
 i 21 111.755228804 2 3950.55539866 8.38082178394 1.10123 19 20 
 i 21 111.999285973 2 4000.5648122 8.64385618977 1.10123 19 20 
 i 21 112.251261582 2 4050.57422574 8.55074678538 1.10123 19 20 
 i 21 112.496957038 2 4100.58363927 8.38082178394 1.10123 19 20 
 i 21 112.757823805 2 4150.59305281 8.55074678538 1.10123 19 20 
 i 21 113.010091065 2 4200.60246635 8.38082178394 1.10123 19 20 
 i 21 113.240734946 2 4250.61187988 8.96578428466 1.10123 19 20 
 i 21 113.49064317 2 4300.62129342 6.88897 1.10123 19 20 
 i 21 113.75971579 2 4350.63070696 6.47393 1.10123 19 20 
 i 21 115.755618994 2 4400.64012049 6.88897 1.10123 9 10 
 i 21 121.751202331 2 4450.64953403 6.47393 1.10123 9 10 
 i 21 127.748214722 2 4500.65894757 6.88897 1.10123 9 10 
 i 21 133.75377221 2 4550.6683611 6.47393 1.10123 9 10 
 i 21 139.756156811 2 4600.67777464 6.88897 1.10123 9 10 
 i 21 145.743703064 2 4650.68718818 6.47393 1.10123 9 10 
 i 21 151.752800935 2 4700.69660171 7.058 1.10123 9 10 
 i 21 157.754901542 2 4750.70601525 7.64386 1.10123 9 10 
 i 21 163.758616794 2 4800.71542879 7.88897 1.10123 9 10 
 i 21 116.743141607 2 4850.72484232 7.64386 1.10123 9 10 
 i 21 121.755720623 2 4900.73425586 7.88897 1.10123 9 10 
 i 21 128.742742993 2 4950.7436694 7.058 1.10123 9 10 
 i 21 133.755531056 2 6250.98842135 7.88897 1.10123 9 10 
 i 21 140.759864926 2 6300.99783489 7.058 1.10123 9 10 
 i 21 145.75997722 2 6351.00724842 7.64386 1.10123 9 10 
 i 21 152.747973956 2 6401.01666196 7.058 1.10123 9 10 
 i 21 157.746558224 2 6451.0260755 7.47393118833 1.10123 9 10 
 i 21 164.747045015 2 6501.03548903 7.2288186905 1.10123 9 10 
 i 21 116.867920512 2 6551.04490257 7.05889368905 1.10123 19 20 
 i 21 117.008977717 2 6601.05431611 7.2288186905 1.10123 19 20 
 i 21 117.11788981 2 6651.06372964 7.64385618977 1.10123 19 20 
 i 21 117.2539633 2 6701.07314318 7.38082178394 1.10123 19 20 
 i 21 117.367149641 2 6751.08255672 7.2288186905 1.10123 19 20 
 i 21 117.507027057 2 6801.09197025 7.38082178394 1.10123 19 20 
 i 21 117.614318889 2 6851.10138379 7.79585928322 1.10123 19 20 
 i 21 117.740114838 2 6901.11079733 7.55074678538 1.10123 19 20 
 i 21 117.866082132 2 6951.12021086 7.38082178394 1.10123 19 20 
 i 21 118.008167717 2 7001.1296244 7.55074678538 1.10123 19 20 
 i 21 118.114426218 2 7051.13903794 7.96578428466 1.10123 19 20 
 i 21 118.254551146 2 7101.14845147 7.70274987883 1.10123 19 20 
 i 21 118.384226617 2 7151.15786501 7.55074678538 1.10123 19 20 
 i 21 118.493943997 2 7201.16727855 7.70274987883 1.10123 19 20 
 i 21 118.635245925 2 7251.17669208 8.11778737811 1.10123 19 20 
 i 21 118.744116363 2 7301.18610562 7.88896868761 1.10123 19 20 
 i 21 118.870999462 2 7351.19551916 7.70274987883 1.10123 19 20 
 i 21 119.010037995 2 7401.20493269 7.88896868761 1.10123 19 20 
 i 21 119.120477184 2 7451.21434623 8.30400618689 1.10123 19 20 
 i 21 119.239681409 2 7501.22375977 8.05889368905 1.10123 19 20 
 i 21 119.379084054 2 7551.2331733 7.88896868761 1.10123 19 20 
 i 21 119.508817267 2 7601.24258684 8.05889368905 1.10123 19 20 
 i 21 119.632753237 2 7651.25200038 8.47393118833 1.10123 19 20 
 i 21 119.744739616 2 7701.26141391 8.2288186905 1.10123 19 20 
 i 21 119.881726803 2 7751.27082745 8.05889368905 1.10123 19 20 
 i 21 119.993849467 2 8251.36496282 8.2288186905 1.10123 19 20 
 i 21 120.120160879 2 8301.37437635 8.64385618977 1.10123 19 20 
 i 21 120.240299724 2 8351.38378989 8.38082178394 1.10123 19 20 
 i 21 120.379175491 2 8401.39320343 7.64386 1.10123 19 20 
 i 21 120.505022099 2 8451.40261696 8.05889368905 1.10123 19 20 
 i 21 120.622473997 2 8501.4120305 7.79585928322 1.10123 19 20 
 i 21 121.864687889 2 8551.42144404 7.64385618977 1.10123 19 20 
 i 21 121.989966213 2 8601.43085757 7.79585928322 1.10123 19 20 
 i 21 122.125134322 2 8651.44027111 8.2288186905 1.10123 19 20 
 i 21 122.256758794 2 8701.44968465 7.96578428466 1.10123 19 20 
 i 21 122.375424123 2 8751.45909818 7.79585928322 1.10123 19 20 
 i 21 122.508185058 2 8801.46851172 7.96578428466 1.10123 19 20 
 i 21 122.623706861 2 8851.47792526 8.38082178394 1.10123 19 20 
 i 21 122.745918994 2 8901.48733879 8.11778737811 1.10123 19 20 
 i 21 122.879292773 2 8951.49675233 7.96578428466 1.10123 19 20 
 i 21 122.998542695 2 9001.50616587 8.11778737811 1.10123 19 20 
 i 21 123.121776473 2 9051.5155794 8.55074678538 1.10123 19 20 
 i 21 123.246442728 2 9101.52499294 8.30400618689 1.10123 19 20 
 i 21 123.374403088 2 9151.53440648 8.11778737811 1.10123 19 20 
 i 21 123.495050782 2 9201.54382001 8.30400618689 1.10123 19 20 
 i 21 123.618224861 2 9251.55323355 8.70274987883 1.10123 19 20 
 i 21 123.757331742 2 9301.56264709 8.47393118833 1.10123 19 20 
 i 21 123.873875815 2 9351.57206062 8.30400618689 1.10123 19 20 
 i 21 123.99679472 2 9401.58147416 8.47393118833 1.10123 19 20 
 i 21 124.118959348 2 9451.5908877 8.88896868761 1.10123 19 20 
 i 21 124.258396872 2 9501.60030123 8.64385618977 1.10123 19 20 
 i 21 124.380466791 2 9551.60971477 8.47393118833 1.10123 19 20 
 i 21 124.495762916 2 9601.61912831 8.64385618977 1.10123 19 20 
 i 21 124.614465082 2 9651.62854184 9.05889368905 1.10123 19 20 
 i 21 124.760134128 2 9701.63795538 8.79585928322 1.10123 19 20 
 i 21 124.878149562 2 9751.64736892 8.64385618977 1.10123 19 20 
 i 21 125.007032082 2 11051.8921209 8.79585928322 1.10123 19 20 
 i 21 125.127990494 2 11101.9015344 9.2288186905 1.10123 19 20 
 i 21 125.243636002 2 11151.9109479 8.96578428466 1.10123 19 20 
 i 21 125.36479625 2 11201.9203615 7.88897 1.10123 19 20 
 i 21 125.501434834 2 11251.929775 8.30400618689 1.10123 19 20 
 i 21 125.634707496 2 11301.9391886 8.05889368905 1.10123 19 20 
 i 21 128.879019273 2 11351.9486021 7.88896868761 1.10123 19 20 
 i 21 129.002236954 2 11401.9580156 8.05889368905 1.10123 19 20 
 i 21 129.13038771 2 11451.9674292 8.47393118833 1.10123 19 20 
 i 21 129.255323482 2 11501.9768427 8.2288186905 1.10123 19 20 
 i 21 129.375830384 2 11551.9862562 8.05889368905 1.10123 19 20 
 i 21 129.50923582 2 11601.9956698 8.2288186905 1.10123 19 20 
 i 21 129.623214485 2 11652.0050833 8.64385618977 1.10123 19 20 
 i 21 129.759484594 2 11702.0144968 8.38082178394 1.10123 19 20 
 i 21 129.87350007 2 11752.0239104 8.2288186905 1.10123 19 20 
 i 21 129.990195827 2 11802.0333239 8.38082178394 1.10123 19 20 
 i 21 130.132753857 2 11852.0427375 8.79585928322 1.10123 19 20 
 i 21 130.24202771 2 11902.052151 8.55074678538 1.10123 19 20 
 i 21 130.373477381 2 11952.0615645 8.38082178394 1.10123 19 20 
 i 21 130.489993307 2 12002.0709781 8.55074678538 1.10123 19 20 
 i 21 130.61482918 2 12052.0803916 8.96578428466 1.10123 19 20 
 i 21 130.755713953 2 12102.0898051 8.70274987883 1.10123 19 20 
 i 21 130.87970325 2 12152.0992187 8.55074678538 1.10123 19 20 
 i 21 130.99312129 2 12202.1086322 8.70274987883 1.10123 19 20 
 i 21 131.115646729 2 12252.1180457 9.11778737811 1.10123 19 20 
 i 21 131.249147146 2 12302.1274593 8.88896868761 1.10123 19 20 
 i 21 131.373844527 2 12352.1368728 8.70274987883 1.10123 19 20 
 i 21 131.507961821 2 12402.1462864 8.88896868761 1.10123 19 20 
 i 21 131.622342624 2 12452.1556999 9.30400618689 1.10123 19 20 
 i 21 131.740834032 2 12502.1651134 9.05889368905 1.10123 19 20 
 i 21 131.882820152 2 12552.174527 8.88896868761 1.10123 19 20 
 i 21 131.991525907 2 13052.2686623 9.05889368905 1.10123 19 20 
 i 21 132.126269826 2 13102.2780759 9.47393118833 1.10123 19 20 
 i 21 132.256489077 2 13152.2874894 9.2288186905 1.10123 19 20 
 i 21 132.384613981 2 13202.2969029 7.64386 1.10123 19 20 
 i 21 132.503623663 2 13252.3063165 8.05889368905 1.10123 19 20 
 i 21 132.635917579 2 13302.31573 7.79585928322 1.10123 19 20 
 i 21 133.883648592 2 13352.3251436 7.64385618977 1.10123 19 20 
 i 21 134.003704047 2 13402.3345571 7.79585928322 1.10123 19 20 
 i 21 134.117459165 2 13452.3439706 8.2288186905 1.10123 19 20 
 i 21 134.246386357 2 13502.3533842 7.96578428466 1.10123 19 20 
 i 21 134.367457448 2 13552.3627977 7.79585928322 1.10123 19 20 
 i 21 134.498307588 2 13602.3722112 7.96578428466 1.10123 19 20 
 i 21 134.615185685 2 13652.3816248 8.38082178394 1.10123 19 20 
 i 21 134.751187702 2 13702.3910383 8.11778737811 1.10123 19 20 
 i 21 134.884311206 2 13752.4004518 7.96578428466 1.10123 19 20 
 i 21 135.005272581 2 13802.4098654 8.11778737811 1.10123 19 20 
 i 21 135.128094695 2 13852.4192789 8.55074678538 1.10123 19 20 
 i 21 135.243644785 2 13902.4286925 8.30400618689 1.10123 19 20 
 i 21 135.37594046 2 13952.438106 8.11778737811 1.10123 19 20 
 i 21 135.497943844 2 14002.4475195 8.30400618689 1.10123 19 20 
 i 21 135.624990275 2 14052.4569331 8.70274987883 1.10123 19 20 
 i 21 135.742362253 2 14102.4663466 8.47393118833 1.10123 19 20 
 i 21 135.873992861 2 14152.4757601 8.30400618689 1.10123 19 20 
 i 21 135.989501257 2 14202.4851737 8.47393118833 1.10123 19 20 
 i 21 136.119594883 2 14252.4945872 8.88896868761 1.10123 19 20 
 i 21 136.257408129 2 14302.5040008 8.64385618977 1.10123 19 20 
 i 21 136.37149062 2 14352.5134143 8.47393118833 1.10123 19 20 
 i 21 136.499960183 2 14402.5228278 8.64385618977 1.10123 19 20 
 i 21 136.63248435 2 14452.5322414 9.05889368905 1.10123 19 20 
 i 21 136.744587 2 14502.5416549 8.79585928322 1.10123 19 20 
 i 21 136.864299496 2 14552.5510684 8.64385618977 1.10123 19 20 
 i 21 136.990902553 2 15852.7958204 8.79585928322 1.10123 19 20 
 i 21 137.134386059 2 15902.8052339 9.2288186905 1.10123 19 20 
 i 21 137.249586131 2 15952.8146475 8.96578428466 1.10123 19 20 
 i 21 137.382805442 2 16002.824061 7.88897 1.10123 19 20 
 i 21 137.489577669 2 16052.8334745 8.30400618689 1.10123 19 20 
 i 21 137.632070119 2 16102.8428881 8.05889368905 1.10123 19 20 
 i 21 140.88223962 2 16152.8523016 7.88896868761 1.10123 19 20 
 i 21 141.007637854 2 16202.8617151 8.05889368905 1.10123 19 20 
 i 21 141.116297522 2 16252.8711287 8.47393118833 1.10123 19 20 
 i 21 141.242466689 2 16302.8805422 8.2288186905 1.10123 19 20 
 i 21 141.375535713 2 16352.8899558 8.05889368905 1.10123 19 20 
 i 21 141.507808633 2 16402.8993693 8.2288186905 1.10123 19 20 
 i 21 141.626666375 2 16452.9087828 8.64385618977 1.10123 19 20 
 i 21 141.741671819 2 16502.9181964 8.38082178394 1.10123 19 20 
 i 21 141.872302918 2 16552.9276099 8.2288186905 1.10123 19 20 
 i 21 141.991388633 2 16602.9370234 8.38082178394 1.10123 19 20 
 i 21 142.122996902 2 16652.946437 8.79585928322 1.10123 19 20 
 i 21 142.260334331 2 16702.9558505 8.55074678538 1.10123 19 20 
 i 21 142.385991626 2 16752.965264 8.38082178394 1.10123 19 20 
 i 21 142.491705806 2 16802.9746776 8.55074678538 1.10123 19 20 
 i 21 142.625795779 2 16852.9840911 8.96578428466 1.10123 19 20 
 i 21 142.758863787 2 16902.9935047 8.70274987883 1.10123 19 20 
 i 21 142.870151475 2 16953.0029182 8.55074678538 1.10123 19 20 
 i 21 142.989159327 2 17003.0123317 8.70274987883 1.10123 19 20 
 i 21 143.116880451 2 17053.0217453 9.11778737811 1.10123 19 20 
 i 21 143.2488327 2 17103.0311588 8.88896868761 1.10123 19 20 
 i 21 143.371078034 2 17153.0405723 8.70274987883 1.10123 19 20 
 i 21 143.504400355 2 17203.0499859 8.88896868761 1.10123 19 20 
 i 21 143.621683892 2 17253.0593994 9.30400618689 1.10123 19 20 
 i 21 143.743534838 2 17303.068813 9.05889368905 1.10123 19 20 
 i 21 143.875411767 2 17353.0782265 8.88896868761 1.10123 19 20 
 i 21 143.990162115 2 17853.1723619 9.05889368905 1.10123 19 20 
 i 21 144.115560425 2 17903.1817754 9.47393118833 1.10123 19 20 
 i 21 144.240558528 2 17953.1911889 9.2288186905 1.10123 19 20 
 i 21 144.381331676 2 17933.3207818 7.058 1.10123 19 20 
 i 21 144.503738763 2 17866.6415636 7.47393118833 1.10123 19 20 
 i 21 144.620805142 2 17799.9623455 7.2288186905 1.10123 19 20 
 i 21 145.878989951 2 17733.2831273 7.05889368905 1.10123 19 20 
 i 21 146.009291736 2 17666.6039091 7.2288186905 1.10123 19 20 
 i 21 146.12243692 2 17599.9246909 7.64385618977 1.10123 19 20 
 i 21 146.245896908 2 17533.2454727 7.38082178394 1.10123 19 20 
 i 21 146.368871763 2 17466.5662545 7.2288186905 1.10123 19 20 
 i 21 146.498426774 2 17399.8870364 7.38082178394 1.10123 19 20 
 i 21 146.620592525 2 17333.2078182 7.79585928322 1.10123 19 20 
 i 21 146.75533809 2 17266.5286 7.55074678538 1.10123 19 20 
 i 21 146.871458145 2 17199.8493818 7.38082178394 1.10123 19 20 
 i 21 146.992450551 2 17133.1701636 7.55074678538 1.10123 19 20 
 i 21 147.117093107 2 17066.4909454 7.96578428466 1.10123 19 20 
 i 21 147.258580659 2 16999.8117273 7.70274987883 1.10123 19 20 
 i 21 147.377379683 2 16933.1325091 7.55074678538 1.10123 19 20 
 i 21 147.492068976 2 16866.4532909 7.70274987883 1.10123 19 20 
 i 21 147.621365744 2 16799.7740727 8.11778737811 1.10123 19 20 
 i 21 147.741723942 2 16733.0948545 7.88896868761 1.10123 19 20 
 i 21 147.880945473 2 16666.4156364 7.70274987883 1.10123 19 20 
 i 21 148.010245458 2 16599.7364182 7.88896868761 1.10123 19 20 
 i 21 148.117884574 2 16533.0572 8.30400618689 1.10123 19 20 
 i 21 148.243313398 2 16466.3779818 8.05889368905 1.10123 19 20 
 i 21 148.367627283 2 15532.8689321 7.88896868761 1.10123 19 20 
 i 21 148.491843303 2 15466.1897139 8.05889368905 1.10123 19 20 
 i 21 148.616612801 2 15399.5104957 8.47393118833 1.10123 19 20 
 i 21 148.747120852 2 15332.8312775 8.2288186905 1.10123 19 20 
 i 21 148.870286449 2 15266.1520593 8.05889368905 1.10123 19 20 
 i 21 148.995270953 2 15199.4728411 8.2288186905 1.10123 19 20 
 i 21 149.117753453 2 15132.793623 8.64385618977 1.10123 19 20 
 i 21 149.249569678 2 15066.1144048 8.38082178394 1.10123 19 20 
 i 21 149.367342948 2 14999.4351866 7.88897 1.10123 19 20 
 i 21 149.490644395 2 14932.7559684 8.30400618689 1.10123 19 20 
 i 21 149.615524042 2 14866.0767502 8.05889368905 1.10123 19 20 
 i 21 152.882629341 2 14799.3975321 7.88896868761 1.10123 19 20 
 i 21 153.00853022 2 14732.7183139 8.05889368905 1.10123 19 20 
 i 21 153.119103108 2 14666.0390957 8.47393118833 1.10123 19 20 
 i 21 153.254414279 2 14599.3598775 8.2288186905 1.10123 19 20 
 i 21 153.377446436 2 14532.6806593 8.05889368905 1.10123 19 20 
 i 21 153.494741582 2 14466.0014411 8.2288186905 1.10123 19 20 
 i 21 153.635557305 2 14399.322223 8.64385618977 1.10123 19 20 
 i 21 153.758986616 2 14332.6430048 8.38082178394 1.10123 19 20 
 i 21 153.868185911 2 14265.9637866 8.2288186905 1.10123 19 20 
 i 21 154.002600963 2 14199.2845684 8.38082178394 1.10123 19 20 
 i 21 154.1164752 2 14132.6053502 8.79585928322 1.10123 19 20 
 i 21 154.245809679 2 14065.926132 8.55074678538 1.10123 19 20 
 i 21 154.37305741 2 13132.4170823 8.38082178394 1.10123 19 20 
 i 21 154.500002392 2 13065.7378641 8.55074678538 1.10123 19 20 
 i 21 154.632421254 2 12999.0586459 8.96578428466 1.10123 19 20 
 i 21 154.743793559 2 12932.3794278 8.70274987883 1.10123 19 20 
 i 21 154.864532346 2 12865.7002096 8.55074678538 1.10123 19 20 
 i 21 154.994379448 2 12799.0209914 8.70274987883 1.10123 19 20 
 i 21 155.128525128 2 12732.3417732 9.11778737811 1.10123 19 20 
 i 21 155.258454136 2 12665.662555 8.88896868761 1.10123 19 20 
 i 21 155.371726911 2 12598.9833368 8.70274987883 1.10123 19 20 
 i 21 155.501799649 2 12532.3041187 8.88896868761 1.10123 19 20 
 i 21 155.635721745 2 12465.6249005 9.30400618689 1.10123 19 20 
 i 21 155.743027818 2 12398.9456823 9.05889368905 1.10123 19 20 
 i 21 155.871441099 2 12332.2664641 8.88896868761 1.10123 19 20 
 i 21 156.00142104 2 12265.5872459 9.05889368905 1.10123 19 20 
 i 21 156.131228717 2 12198.9080277 9.47393118833 1.10123 19 20 
 i 21 156.250471075 2 12132.2288096 9.2288186905 1.10123 19 20 
 i 21 156.382616019 2 12065.5495914 7.058 1.10123 19 20 
 i 21 156.498044095 2 11998.8703732 7.47393118833 1.10123 19 20 
 i 21 156.63248008 2 11932.191155 7.2288186905 1.10123 19 20 
 i 21 157.870260221 2 11865.5119368 7.05889368905 1.10123 19 20 
 i 21 158.009958785 2 11798.8327187 7.2288186905 1.10123 19 20 
 i 21 158.135412848 2 11732.1535005 7.64385618977 1.10123 19 20 
 i 21 158.246989716 2 11665.4742823 7.38082178394 1.10123 19 20 
 i 21 158.3827598 2 10731.9652325 7.2288186905 1.10123 19 20 
 i 21 158.492363613 2 10665.2860144 7.38082178394 1.10123 19 20 
 i 21 158.618366288 2 10598.6067962 7.79585928322 1.10123 19 20 
 i 21 158.755443703 2 10531.927578 7.55074678538 1.10123 19 20 
 i 21 158.881747888 2 10465.2483598 7.38082178394 1.10123 19 20 
 i 21 158.99100156 2 10398.5691416 7.55074678538 1.10123 19 20 
 i 21 159.130472561 2 10331.8899234 7.96578428466 1.10123 19 20 
 i 21 159.24694808 2 10265.2107053 7.70274987883 1.10123 19 20 
 i 21 159.379196002 2 10198.5314871 7.55074678538 1.10123 19 20 
 i 21 159.506980681 2 10131.8522689 7.70274987883 1.10123 19 20 
 i 21 159.615105648 2 10065.1730507 8.11778737811 1.10123 19 20 
 i 21 159.758593352 2 9998.49383253 7.88896868761 1.10123 19 20 
 i 21 159.881096873 2 9931.81461435 7.70274987883 1.10123 19 20 
 i 21 160.007018444 2 9865.13539617 7.88896868761 1.10123 19 20 
 i 21 160.126959484 2 9798.45617799 8.30400618689 1.10123 19 20 
 i 21 160.239812441 2 9731.7769598 8.05889368905 1.10123 19 20 
 i 21 160.384232774 2 9665.09774162 7.88896868761 1.10123 19 20 
 i 21 160.492466968 2 9598.41852344 8.05889368905 1.10123 19 20 
 i 21 160.624295401 2 9531.73930526 8.47393118833 1.10123 19 20 
 i 21 160.760005609 2 9465.06008708 8.2288186905 1.10123 19 20 
 i 21 160.871990565 2 9398.38086889 8.05889368905 1.10123 19 20 
 i 21 161.003396316 2 9331.70165071 8.2288186905 1.10123 19 20 
 i 21 161.122116585 2 9265.02243253 8.64385618977 1.10123 19 20 
 i 21 161.25933888 2 8331.51338278 8.38082178394 1.10123 19 20 
 i 21 161.364686398 2 8264.8341646 7.64386 1.10123 19 20 
 i 21 161.509878899 2 8198.15494641 8.05889368905 1.10123 19 20 
 i 21 161.62640647 2 8131.47572823 7.79585928322 1.10123 19 20 
 i 21 164.874483882 2 8064.79651005 7.64385618977 1.10123 19 20 
 i 21 165.010579486 2 7998.11729187 7.79585928322 1.10123 19 20 
 i 21 165.132206643 2 7931.43807368 8.2288186905 1.10123 19 20 
 i 21 165.241113472 2 7864.7588555 7.96578428466 1.10123 19 20 
 i 21 165.365292523 2 7798.07963732 7.79585928322 1.10123 19 20 
 i 21 165.498049249 2 7731.40041914 7.96578428466 1.10123 19 20 
 i 21 165.624175838 2 7664.72120096 8.38082178394 1.10123 19 20 
 i 21 165.752898348 2 7598.04198277 8.11778737811 1.10123 19 20 
 i 21 165.874298205 2 7531.36276459 7.96578428466 1.10123 19 20 
 i 21 166.008538759 2 7464.68354641 8.11778737811 1.10123 19 20 
 i 21 166.128769991 2 7398.00432823 8.55074678538 1.10123 19 20 
 i 21 166.245727062 2 7331.32511004 8.30400618689 1.10123 19 20 
 i 21 166.375378511 2 7264.64589186 8.11778737811 1.10123 19 20 
 i 21 166.503888982 2 7197.96667368 8.30400618689 1.10123 19 20 
 i 21 166.632980798 2 7131.2874555 8.70274987883 1.10123 19 20 
 i 21 166.758679794 2 7064.60823732 8.47393118833 1.10123 19 20 
 i 21 166.873107856 2 6997.92901913 8.30400618689 1.10123 19 20 
 i 21 166.998290471 2 6931.24980095 8.47393118833 1.10123 19 20 
 i 21 167.131038473 2 6864.57058277 8.88896868761 1.10123 19 20 
 i 21 167.244556148 2 5931.06153302 8.64385618977 1.10123 19 20 
 i 21 167.368037497 2 5864.38231484 8.47393118833 1.10123 19 20 
 i 21 167.492763254 2 5797.70309665 8.64385618977 1.10123 19 20 
 i 21 167.622354506 2 5731.02387847 9.05889368905 1.10123 19 20 
 i 21 167.757841368 2 5664.34466029 8.79585928322 1.10123 19 20 
 i 21 167.87690016 2 5597.66544211 8.64385618977 1.10123 19 20 
 i 21 168.010503344 2 5530.98622392 8.79585928322 1.10123 19 20 
 i 21 168.135869882 2 5464.30700574 9.2288186905 1.10123 19 20 
 i 21 168.259161939 2 5397.62778756 8.96578428466 1.10123 19 20 
 i 21 168.375797342 2 5330.94856938 6.88897 1.10123 19 20 
 i 21 168.509162479 2 5264.2693512 7.2288186905 1.10123 19 20 
 i 21 168.622095207 2 5197.59013301 7.64385618977 1.10123 19 20 
 i 21 115.913418126 2 5130.91091483 7.38082178394 1.10123 19 20 
 i 21 116.086150652 2 5064.23169665 7.2288186905 1.10123 19 20 
 i 21 116.250601007 2 4997.55247847 7.05889368905 1.10123 19 20 
 i 21 116.423051643 2 4930.87326028 7.2288186905 1.10123 19 20 
 i 21 116.575717188 2 4864.1940421 7.64385618977 1.10123 19 20 
 i 21 116.757082451 2 4797.51482392 7.38082178394 1.10123 19 20 
 i 21 116.921393553 2 4730.83560574 7.2288186905 1.10123 19 20 
 i 21 117.076162239 2 4664.15638756 7.05889368905 1.10123 19 20 
 i 21 117.258497062 2 4597.47716937 7.2288186905 1.10123 19 20 
 i 21 117.414739488 2 4530.79795119 7.64385618977 1.10123 19 20 
 i 21 117.573306436 2 4464.11873301 7.38082178394 1.10123 19 20 
 i 21 117.748327715 2 3530.60968326 7.2288186905 1.10123 19 20 
 i 21 117.916692274 2 3463.93046508 7.05889368905 1.10123 19 20 
 i 21 118.074570339 2 3397.25124689 7.2288186905 1.10123 19 20 
 i 21 118.25723926 2 3330.57202871 7.64385618977 1.10123 19 20 
 i 21 118.421255592 2 3263.89281053 7.38082178394 1.10123 19 20 
 i 21 118.580157072 2 3197.21359235 7.2288186905 1.10123 19 20 
 i 21 118.747228063 2 3130.53437416 7.05889368905 1.10123 19 20 
 i 21 118.917773921 2 3063.85515598 7.2288186905 1.10123 19 20 
 i 21 119.09087659 2 2997.1759378 7.64385618977 1.10123 19 20 
 i 21 119.25256274 2 2930.49671962 6.47393 1.10123 19 20 
 i 21 119.409033616 2 2863.81750144 7.2288186905 1.10123 19 20 
 i 21 119.578312026 2 2797.13828325 7.64385618977 1.10123 19 20 
 i 21 121.910734511 2 2730.45906507 7.38082178394 1.10123 19 20 
 i 21 122.090530481 2 2663.77984689 7.2288186905 1.10123 19 20 
 i 21 122.250710121 2 2597.10062871 7.05889368905 1.10123 19 20 
 i 21 122.4230876 2 2530.42141052 7.2288186905 1.10123 19 20 
 i 21 122.581234675 2 2463.74219234 7.64385618977 1.10123 19 20 
 i 21 122.758500778 2 2397.06297416 7.38082178394 1.10123 19 20 
 i 21 122.909957319 2 2330.38375598 7.2288186905 1.10123 19 20 
 i 21 123.07913821 2 2263.7045378 7.05889368905 1.10123 19 20 
 i 21 123.239308123 2 2197.02531961 7.2288186905 1.10123 19 20 
 i 21 123.410205005 2 2130.34610143 7.64385618977 1.10123 19 20 
 i 21 123.582475331 2 2063.66688325 7.38082178394 1.10123 19 20 
 i 21 123.754275306 2 1130.1578335 7.2288186905 1.10123 19 20 
 i 21 123.912074956 2 1063.47861532 7.05889368905 1.10123 19 20 
 i 21 124.087110046 2 15000 7.2288186905 1.10123 19 20 
 i 21 124.254353458 2 15000 7.64385618977 1.10123 19 20 
 i 21 124.409562694 2 15000 7.38082178394 1.10123 19 20 
 i 21 124.587141917 2 15000 7.2288186905 1.10123 19 20 
 i 21 124.748653386 2 15000 7.05889368905 1.10123 19 20 
 i 21 124.919270621 2 15000 7.2288186905 1.10123 19 20 
 i 21 125.079029547 2 15000 7.64385618977 1.10123 19 20 
 i 21 125.244686826 2 15000 6.88897 1.10123 19 20 
 i 21 125.406710878 2 15000 7.2288186905 1.10123 19 20 
 i 21 125.591200317 2 15000 7.64385618977 1.10123 19 20 
 i 21 127.927198025 2 15000 7.38082178394 1.10123 19 20 
 i 21 128.089210419 2 15000 7.2288186905 1.10123 19 20 
 i 21 128.242751496 2 15000 7.05889368905 1.10123 19 20 
 i 21 128.417551982 2 1701.26672295 7.2288186905 1.10123 19 20 
 i 21 128.587683822 2 1755.21031742 7.64385618977 1.10123 19 20 
 i 21 128.754229335 2 1809.15391189 7.38082178394 1.10123 19 20 
 i 21 128.91176823 2 1863.09750636 7.2288186905 1.10123 19 20 
 i 21 129.092027316 2 1917.04110083 7.05889368905 1.10123 19 20 
 i 21 129.23922374 2 1970.9846953 7.2288186905 1.10123 19 20 
 i 21 129.420437279 2 2024.92828977 7.64385618977 1.10123 19 20 
 i 21 129.586953931 2 2078.87188424 7.38082178394 1.10123 19 20 
 i 21 129.744356371 2 2132.81547871 7.2288186905 1.10123 19 20 
 i 21 129.917293131 2 2186.75907319 7.05889368905 1.10123 19 20 
 i 21 130.085530419 2 2240.70266766 7.2288186905 1.10123 19 20 
 i 21 130.256637898 2 2294.64626213 7.64385618977 1.10123 19 20 
 i 21 130.411012231 2 2348.5898566 7.38082178394 1.10123 19 20 
 i 21 130.584184179 2 2402.53345107 7.2288186905 1.10123 19 20 
 i 21 130.751431656 2 2456.47704554 7.05889368905 1.10123 19 20 
 i 21 130.917790606 2 2510.42064001 7.2288186905 1.10123 19 20 
 i 21 131.081950573 2 2564.36423448 7.64385618977 1.10123 19 20 
 i 21 131.240606796 2 2618.30782895 6.47393 1.10123 19 20 
 i 21 131.409217218 2 2672.25142343 7.2288186905 1.10123 19 20 
 i 21 131.590629324 2 2726.1950179 7.64385618977 1.10123 19 20 
 i 21 133.914605623 2 2780.13861237 7.38082178394 1.10123 19 20 
 i 21 134.087104752 2 2834.08220684 7.2288186905 1.10123 19 20 
 i 21 134.25515653 2 2888.02580131 7.05889368905 1.10123 19 20 
 i 21 134.409872821 2 4937.88236532 7.2288186905 1.10123 19 20 
 i 21 134.577934499 2 4991.82595979 7.64385618977 1.10123 19 20 
 i 21 134.743689012 2 5045.76955426 7.38082178394 1.10123 19 20 
 i 21 134.911620209 2 5099.71314873 7.2288186905 1.10123 19 20 
 i 21 135.081331999 2 5153.6567432 7.05889368905 1.10123 19 20 
 i 21 135.248486776 2 5207.60033767 7.2288186905 1.10123 19 20 
 i 21 135.412183107 2 5261.54393215 7.64385618977 1.10123 19 20 
 i 21 135.580168704 2 5315.48752662 7.38082178394 1.10123 19 20 
 i 21 135.756992047 2 5369.43112109 7.2288186905 1.10123 19 20 
 i 21 135.908504072 2 5423.37471556 7.05889368905 1.10123 19 20 
 i 21 136.080199647 2 5477.31831003 7.2288186905 1.10123 19 20 
 i 21 136.243928682 2 5531.2619045 7.64385618977 1.10123 19 20 
 i 21 136.405922463 2 5585.20549897 7.38082178394 1.10123 19 20 
 i 21 136.577707844 2 5639.14909344 7.2288186905 1.10123 19 20 
 i 21 136.752769712 2 5693.09268791 7.05889368905 1.10123 19 20 
 i 21 136.910088167 2 5747.03628239 7.2288186905 1.10123 19 20 
 i 21 137.090081338 2 5800.97987686 7.64385618977 1.10123 19 20 
 i 21 137.260158449 2 5854.92347133 6.88897 1.10123 19 20 
 i 21 137.424012806 2 5908.8670658 7.2288186905 1.10123 19 20 
 i 21 137.578705532 2 5962.81066027 7.64385618977 1.10123 19 20 
 i 21 139.91217531 2 6016.75425474 7.38082178394 1.10123 19 20 
 i 21 140.076127007 2 6070.69784921 7.2288186905 1.10123 19 20 
 i 21 140.249580882 2 6124.64144368 7.05889368905 1.10123 19 20 
 i 21 140.423844554 2 9469.14426464 7.2288186905 1.10123 19 20 
 i 21 140.578049256 2 9523.08785911 7.64385618977 1.10123 19 20 
 i 21 140.745865364 2 9577.03145358 7.38082178394 1.10123 19 20 
 i 21 140.921386485 2 9630.97504805 7.2288186905 1.10123 19 20 
 i 21 141.076956532 2 9684.91864253 7.05889368905 1.10123 19 20 
 i 21 141.248203756 2 9738.862237 7.2288186905 1.10123 19 20 
 i 21 141.409029832 2 9792.80583147 7.64385618977 1.10123 19 20 
 i 21 141.579232424 2 9846.74942594 7.38082178394 1.10123 19 20 
 i 21 141.747552775 2 9900.69302041 7.2288186905 1.10123 19 20 
 i 21 141.927209492 2 9954.63661488 7.05889368905 1.10123 19 20 
 i 21 142.087632724 2 10008.5802094 7.2288186905 1.10123 19 20 
 i 21 142.24573399 2 10062.5238038 7.64385618977 1.10123 19 20 
 i 21 142.408738887 2 10116.4673983 7.38082178394 1.10123 19 20 
 i 21 142.572669981 2 10170.4109928 7.2288186905 1.10123 19 20 
 i 21 142.743251445 2 10224.3545872 7.05889368905 1.10123 19 20 
 i 21 142.919693878 2 10278.2981817 7.2288186905 1.10123 19 20 
 i 21 143.075063173 2 10332.2417762 7.64385618977 1.10123 19 20 
 i 21 143.23968409 2 10386.1853706 6.47393 1.10123 19 20 
 i 21 143.418997029 2 10440.1289651 7.2288186905 1.10123 19 20 
 i 21 143.584085532 2 10494.0725596 7.64385618977 1.10123 19 20 
 i 21 145.907849281 2 10548.0161541 7.38082178394 1.10123 19 20 
 i 21 146.078435189 2 10601.9597485 7.2288186905 1.10123 19 20 
 i 21 146.241854165 2 10655.903343 7.05889368905 1.10123 19 20 
 i 21 146.412522182 2 12705.759907 7.2288186905 1.10123 19 20 
 i 21 146.591194442 2 12759.7035015 7.64385618977 1.10123 19 20 
 i 21 146.747702894 2 12813.647096 7.38082178394 1.10123 19 20 
 i 21 146.911063558 2 12867.5906904 7.2288186905 1.10123 19 20 
 i 21 147.091867589 2 12921.5342849 7.05889368905 1.10123 19 20 
 i 21 147.252672473 2 12975.4778794 7.2288186905 1.10123 19 20 
 i 21 147.408328969 2 13029.4214738 7.64385618977 1.10123 19 20 
 i 21 147.585796098 2 13083.3650683 7.38082178394 1.10123 19 20 
 i 21 147.745688578 2 13137.3086628 7.2288186905 1.10123 19 20 
 i 21 147.920724914 2 13191.2522573 7.05889368905 1.10123 19 20 
 i 21 148.076467325 2 13245.1958517 7.2288186905 1.10123 19 20 
 i 21 148.250265974 2 13299.1394462 7.64385618977 1.10123 19 20 
 i 21 148.417831172 2 13353.0830407 7.38082178394 1.10123 19 20 
 i 21 148.583425614 2 13407.0266351 7.2288186905 1.10123 19 20 
 i 21 148.751808208 2 13460.9702296 7.05889368905 1.10123 19 20 
 i 21 148.908305743 2 13514.9138241 7.2288186905 1.10123 19 20 
 i 21 149.083452603 2 13568.8574186 7.64385618977 1.10123 19 20 
 i 21 149.260793571 2 13622.801013 6.88897 1.10123 19 20 
 i 21 149.406490437 2 13676.7446075 7.2288186905 1.10123 19 20 
 i 21 149.589989991 2 13730.688202 7.64385618977 1.10123 19 20 
 i 21 151.912950816 2 13784.6317964 7.38082178394 1.10123 19 20 
 i 21 152.092525839 2 13838.5753909 7.2288186905 1.10123 19 20 
 i 21 152.241724908 2 13892.5189854 7.05889368905 1.10123 19 20 
 i 21 152.415385766 2 17237.0218063 7.2288186905 1.10123 19 20 
 i 21 152.578949299 2 17290.9654008 7.64385618977 1.10123 19 20 
 i 21 152.750086339 2 17344.9089953 7.38082178394 1.10123 19 20 
 i 21 152.926779586 2 17398.8525897 7.2288186905 1.10123 19 20 
 i 21 153.08314065 2 17452.7961842 7.05889368905 1.10123 19 20 
 i 21 153.249392899 2 17506.7397787 7.2288186905 1.10123 19 20 
 i 21 153.419868273 2 17560.6833732 7.64385618977 1.10123 19 20 
 i 21 153.583974266 2 17614.6269676 7.38082178394 1.10123 19 20 
 i 21 153.75081353 2 17668.5705621 7.2288186905 1.10123 19 20 
 i 21 153.907015329 2 17722.5141566 7.05889368905 1.10123 19 20 
 i 21 154.078752277 2 17776.457751 7.2288186905 1.10123 19 20 
 i 21 154.260389292 2 17830.4013455 7.64385618977 1.10123 19 20 
 i 21 154.407420622 2 17884.34494 7.38082178394 1.10123 19 20 
 i 21 154.593390765 2 17938.2885345 7.2288186905 1.10123 19 20 
 i 21 154.757703958 2 17992.2321289 7.05889368905 1.10123 19 20 
 i 21 154.910056951 2 17919.0846089 7.2288186905 1.10123 19 20 
 i 21 155.094299198 2 17838.1692179 7.64385618977 1.10123 19 20 
 i 21 155.25169109 2 17757.2538268 6.47393 1.10123 19 20 
 i 21 155.418920765 2 17676.3384358 7.2288186905 1.10123 19 20 
 i 21 155.588456175 2 17595.4230447 7.64385618977 1.10123 19 20 
 i 21 157.91592967 2 17514.5076536 7.38082178394 1.10123 19 20 
 i 21 158.090702906 2 17433.5922626 7.2288186905 1.10123 19 20 
 i 21 158.245378554 2 17352.6768715 7.05889368905 1.10123 19 20 
 i 21 158.426187789 2 17271.7614805 7.2288186905 1.10123 19 20 
 i 21 158.582488407 2 17190.8460894 7.64385618977 1.10123 19 20 
 i 21 158.747043347 2 17109.9306983 7.38082178394 1.10123 19 20 
 i 21 158.914010771 2 17029.0153073 7.2288186905 1.10123 19 20 
 i 21 159.077264819 2 16948.0999162 7.05889368905 1.10123 19 20 
 i 21 159.252389621 2 16867.1845252 7.2288186905 1.10123 19 20 
 i 21 159.426011124 2 16786.2691341 7.64385618977 1.10123 19 20 
 i 21 159.576502182 2 14035.1458381 7.38082178394 1.10123 19 20 
 i 21 159.74081555 2 13954.230447 7.2288186905 1.10123 19 20 
 i 21 159.911256757 2 13873.315056 7.05889368905 1.10123 19 20 
 i 21 160.079838786 2 13792.3996649 7.2288186905 1.10123 19 20 
 i 21 160.250571581 2 13711.4842739 7.64385618977 1.10123 19 20 
 i 21 160.407165965 2 13630.5688828 7.38082178394 1.10123 19 20 
 i 21 160.578261675 2 13549.6534917 7.2288186905 1.10123 19 20 
 i 21 160.751588052 2 13468.7381007 7.05889368905 1.10123 19 20 
 i 21 160.907062835 2 13387.8227096 7.2288186905 1.10123 19 20 
 i 21 161.079553477 2 13306.9073186 7.64385618977 1.10123 19 20 
 i 21 161.247804429 2 13225.9919275 6.79586 1.10123 19 20 
 i 21 161.424003309 2 13145.0765364 7.47393 1.10123 19 20 
 i 21 161.591367887 2 13064.1611454 7.38082 1.10123 19 20 
 i 21 163.592294857 2 12983.2457543 6.79586 1.10123 9 10 
 i 21 169.575566357 2 12902.3303633 7.47393 1.10123 9 10 
 i 21 175.585490188 2 10151.2070672 7.22882 1.10123 9 10 
 i 21 181.572713308 2 10070.2916762 7.64386 1.10123 9 10 
 i 21 187.591039469 2 9989.37628513 7.64386 1.10123 9 10 
 i 21 193.586533201 2 9908.46089407 7.22882 1.10123 9 10 
 i 21 164.589254798 2 9827.54550301 7.22882 1.10123 9 10 
 i 21 169.580233049 2 9746.63011195 7.64386 1.10123 9 10 
 i 21 176.589163658 2 9665.71472089 7.22882 1.10123 9 10 
 i 21 181.58073875 2 9584.79932983 7.38082178394 1.10123 9 10 
 i 21 188.590678521 2 9503.88393877 7.05889368905 1.10123 9 10 
 i 21 193.593721313 2 9422.96854771 12.7958592832 1.10123 9 10 
 i 21 200.587365341 2 9342.05315665 7.11778737811 1.10123 9 10 
 i 21 164.664032081 2 9261.13776559 12.6438561898 1.10123 19 20 
 i 21 164.742259223 2 9180.22237453 12.5507467854 1.10123 19 20 
 i 21 164.835190402 2 9099.30698347 12.7027498788 1.10123 19 20 
 i 21 164.919624077 2 9018.39159241 12.3808217839 1.10123 19 20 
 i 21 165.008022817 2 6267.2682964 12.3040061869 1.10123 19 20 
 i 21 165.074300651 2 6186.35290534 12.4739311883 1.10123 19 20 
 i 21 165.165998638 2 6105.43751428 12.1177873781 1.10123 19 20 
 i 21 165.256711589 2 6024.52212322 12.0588936891 1.10123 19 20 
 i 21 165.328917364 2 5943.60673216 12.2288186905 1.10123 19 20 
 i 21 165.4160031 2 5862.6913411 11.8889686876 1.10123 19 20 
 i 21 165.509914603 2 5781.77595004 11.7958592832 1.10123 19 20 
 i 21 165.583294279 2 5700.86055898 11.9657842847 1.10123 19 20 
 i 21 165.672881249 2 5619.94516792 11.6438561898 1.10123 19 20 
 i 21 165.746285718 2 5539.02977686 11.5507467854 1.10123 19 20 
 i 21 165.837001308 2 5458.1143858 11.7027498788 1.10123 19 20 
 i 21 165.917754075 2 5377.19899475 11.3808217839 1.10123 19 20 
 i 21 165.996566977 2 5296.28360369 11.3040061869 1.10123 19 20 
 i 21 166.089523902 2 5215.36821263 11.4739311883 1.10123 19 20 
 i 21 166.158471136 2 5134.45282157 7.64386 1.10123 19 20 
 i 21 166.258033072 2 2383.32952555 7.79585928322 1.10123 19 20 
 i 21 166.325210894 2 2302.41413449 7.47393118833 1.10123 19 20 
 i 21 166.41673383 2 2221.49874343 7.38082178394 1.10123 19 20 
 i 21 166.501546461 2 2140.58335237 7.55074678538 1.10123 19 20 
 i 21 169.665027169 2 2059.66796131 7.2288186905 1.10123 19 20 
 i 21 169.756700544 2 1978.75257025 7.11778737811 1.10123 19 20 
 i 21 169.841345994 2 1897.83717919 7.30400618689 1.10123 19 20 
 i 21 169.910965566 2 1816.92178813 12.7958592832 1.10123 19 20 
 i 21 170.002032693 2 1736.00639708 12.7027498788 1.10123 19 20 
 i 21 170.086502566 2 1655.09100602 7.05889368905 1.10123 19 20 
 i 21 170.159333139 2 1574.17561496 12.5507467854 1.10123 19 20 
 i 21 170.244474788 2 1493.2602239 12.4739311883 1.10123 19 20 
 i 21 170.341674878 2 1412.34483284 12.6438561898 1.10123 19 20 
 i 21 170.407993178 2 1331.42944178 12.3040061869 1.10123 19 20 
 i 21 170.496421876 2 1250.51405072 12.2288186905 1.10123 19 20 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR1	   9  	10  0.35  87
$MIXDUR1	   19  	20  0.20  88

;bass
 i 12 0.000603542662794 6 91 5.05889 0.0 0 11 12 
 i 12 5.99213272784 6 91 5.22882 0.0 0 11 12 
 i 12 12.0099804885 6 91 5.05889 0.0 0 11 12 
 i 12 18.0062033972 6 91 5.22882 0.0 0 11 12 
 i 12 23.9895733693 6 91 5.05889 0.0 0 11 12 
 i 12 30.0091242452 6 91 5.22882 0.0 0 11 12 
 i 12 35.9896115156 6 91 5.05889 0.0 0 11 12 
 i 12 42.0022658248 6 91 5.22882 0.0 0 11 12 
 i 12 47.9943448071 6 91 5.05889 0.0 0 11 12 
 i 12 53.998714821 6 91 5.22882 0.0 0 11 12 
 i 12 60.0002031045 6 91 5.05889 0.0 0 11 12 
 i 12 65.9912733207 6 91 5.22882 0.0 0 11 12 
 i 12 71.999748831 6 91 5.05889 0.0 0 11 12 
 i 12 77.991349031 6 91 5.22882 0.0 0 11 12 
 i 12 84.0048406758 6 91 5.05889 0.0 0 11 12 
 i 12 90.0071635392 6 91 5.22882 0.0 0 11 12 
 i 12 95.9975144579 6 91 5.05889 0.0 0 11 12 
 i 12 102.002003016 6 91 5.22882 0.0 0 11 12 
 i 12 108.008773541 6 91 5.05889 0.0 0 11 12 
 i 12 114.007855221 6 91 6.22882 0.0 0 11 12 
 i 12 0.995451296151 5 85 6.05889 0.0 0 11 12 
 i 12 6.00828961683 7 85 6.64386 0.0 0 11 12 
 i 12 13.0061947573 5 85 6.79586 0.0 0 11 12 
 i 12 17.9933421265 7 85 6.05889 0.0 0 11 12 
 i 12 25.0017700577 5 85 6.64386 0.0 0 11 12 
 i 12 30.0011680759 7 85 6.79586 0.0 0 11 12 
 i 12 37.0044357805 5 85 6.22882 0.0 0 11 12 
 i 12 42.0074482505 7 85 6.64386 0.0 0 11 12 
 i 12 48.9965014717 5 85 6.79586 0.0 0 11 12 
 i 12 53.9930097374 7 85 6.22882 0.0 0 11 12 
 i 12 61.0096128969 5 85 6.05889 0.0 0 11 12 
 i 12 65.9949374356 7 85 6.79586 0.0 0 11 12 
 i 12 72.9902057054 5 85 6.22882 0.0 0 11 12 
 i 12 78.0085482924 7 85 6.05889 0.0 0 11 12 
 i 12 84.994746326 5 85 6.64386 0.0 0 11 12 
 i 12 89.9966860876 7 85 6.22882 0.0 0 11 12 
 i 12 97.0101854295 5 85 6.05889 0.0 0 11 12 
 i 12 102.005227725 7 85 6.64386 0.0 0 11 12 
 i 12 109.002815421 5 85 6.79586 0.0 0 11 12 
 i 12 113.999920824 7 85 5.88897 0.0 0 11 12 
 i 12 120.992329845 7 85 5.47393 0.0 0 11 12 
 i 12 127.992804834 6 91 5.88897 0.0 0 11 12 
 i 12 133.994526443 6 91 5.47393 0.0 0 11 12 
 i 12 140.007918074 6 91 5.88897 0.0 0 11 12 
 i 12 146.002404127 6 91 5.47393 0.0 0 11 12 
 i 12 151.991874898 6 91 5.88897 0.0 0 11 12 
 i 12 157.989982262 6 91 5.47393 0.0 0 11 12 
 i 12 164.008048315 6 91 6.058 0.0 0 11 12 
 i 12 169.999316783 6 91 6.64386 0.0 0 11 12 
 i 12 175.990899673 6 91 6.88897 0.0 0 11 12 
 i 12 128.991559744 5 85 6.64386 0.0 0 11 12 
 i 12 133.991190372 7 85 6.88897 0.0 0 11 12 
 i 12 140.993663246 5 85 6.058 0.0 0 11 12 
 i 12 145.999141323 7 85 6.88897 0.0 0 11 12 
 i 12 153.01007846 5 85 6.058 0.0 0 11 12 
 i 12 158.004367739 7 85 6.64386 0.0 0 11 12 
 i 12 165.006629421 5 85 5.79586 0.0 0 11 12 
 i 12 169.999779427 7 85 5.47393 0.0 0 11 12 
 i 12 177.006496275 7 85 5.38082 0.0 0 11 12 
 i 12 183.999216628 6 91 5.79586 0.0 0 11 12 
 i 12 190.007223677 6 91 5.47393 0.0 0 11 12 
 i 12 195.995682012 6 91 6.22882 0.0 0 11 12 
 i 12 201.995349859 6 91 6.64386 0.0 0 11 12 
 i 12 207.999518556 6 91 6.64386 0.0 0 11 12 
 i 12 213.996004569 6 91 6.22882 0.0 0 11 12 
 i 12 185.006581739 5 85 6.22882 0.0 0 11 12 
 i 12 189.990175563 7 85 6.64386 0.0 0 11 12 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR1	   11  	12  0.58 90

;ensemble Section A
 i 388 0 180.0 1.77 7 21 21 
 i 388 0 180.0 2.83 8 22 22 
;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR1	   21  	22  0.36  89

;gong
 i 99 0 20 67 55 146 23 24 
 i 99 30 20 67 55 146 23 24 
 i 99 42 20 67 55 146 23 24 
 i 99 61 20 67 55 146 23 24 
 i 99 114 20 67 55 146 23 24 
 i 99 170 20 67 55 146 23 24 
 i 99 245 20 67 55 146 23 24 
 i 99 254 20 67 55 146 23 24 
 i 99 262 20 67 55 146 23 24 
 i 99 283 20 67 55 146 23 24 
 i 99 759.5 20 67 55 146 23 24 
 i 99 0 35 127 50 277 23 24 
 i 99 30 35 127 50 277 23 24 
 i 99 42 35 127 50 277 23 24 
 i 99 61 35 127 50 277 23 24 
 i 99 114 35 127 50 277 23 24 
 i 99 170 35 127 50 277 23 24 
 i 99 245 35 127 50 277 23 24 
 i 99 254 35 127 50 277 23 24 
 i 99 262 35 127 50 277 23 24 
 i 99 283 35 127 50 277 23 24 
 i 99 759.5 20 127 50 277 23 24 
 
i900 0 780	   23   24  1.1 91
i910 0 780

i910 0 $DUR1 ;clear channels for section 1

;;;;;;;;;;;;;;;;
;1st TRANSITION
;;;;;;;;;;;;;;;;;
b 202

f 92 0 1025 -27 0 1 680 0.0 1024 0.0 ;mixer slope down
f 93 0 1025 -27 0 1 480 1.0 810 0.0 1024 0.0 ;mixer --\ late fade

;transition chords
 i 386 0.0 8.5 75 9.47393118833 -1 1 27 28 
 i 386 8.5 8.5 75 10.4739311883 -1 1 27 28 
 i 386 17.0 8.5 75 10.5507467854 -1 1 27 28 
 i 386 25.5 8.5 75 10.4739311883 -1 1 27 28 
 i 386 34.0 8.5 75 10.1177873781 -1 1 27 28 
 i 386 42.5 8.5 75 9.79585928322 -1 1 27 28 
 i 386 51.0 8.5 75 9.38082178394 -1 1 27 28 
 i 386 59.5 8.5 75 10.3808217839 -1 1 27 28 
 i 386 68.0 8.5 75 10.4739311883 -1 1 27 28 
 i 386 0.0 8.5 75 8.64385618977 -0.5 1 27 28 
 i 386 8.5 8.5 75 9.47393118833 -0.5 1 27 28 
 i 386 17.0 8.5 75 9.38082178394 -0.5 1 27 28 
 i 386 25.5 8.5 75 9.2288186905 -0.5 1 27 28 
 i 386 34.0 8.5 75 9.05889368905 -0.5 1 27 28 
 i 386 42.5 8.5 75 8.47393118833 -0.5 1 27 28 
 i 386 51.0 8.5 75 9.30400618689 -0.5 1 27 28 
 i 386 59.5 8.5 75 9.2288186905 -0.5 1 27 28 
 i 386 68.0 8.5 75 9.05889368905 -0.5 1 27 28 
 i 386 0.0 8.5 75 8.2288186905 0.5 1 27 28 
 i 386 8.5 8.5 75 8.79585928322 0.5 1 27 28 
 i 386 17.0 8.5 75 8.64385618977 0.5 1 27 28 
 i 386 25.5 8.5 75 8.64385618977 0.5 1 27 28 
 i 386 34.0 8.5 75 8.38082178394 0.5 1 27 28 
 i 386 42.5 8.5 75 7.79585928322 0.5 1 27 28 
 i 386 51.0 8.5 75 8.38082178394 0.5 1 27 28 
 i 386 59.5 8.5 75 8.2288186905 0.5 1 27 28 
 i 386 68.0 8.5 75 8.2288186905 0.5 1 27 28 
 i 386 0.0 8.5 75 8.05889368905 1 1 27 28 
 i 386 8.5 8.5 75 8.47393118833 1 1 27 28 
 i 386 17.0 8.5 75 8.30400618689 1 1 27 28 
 i 386 25.5 8.5 75 8.2288186905 1 1 27 28 
 i 386 34.0 8.5 75 8.05889368905 1 1 27 28 
 i 386 42.5 8.5 75 7.88896868761 1 1 27 28 
 i 386 51.0 8.5 75 8.30400618689 1 1 27 28 
 i 386 59.5 8.5 75 8.11778737811 1 1 27 28 
 i 386 68.0 8.5 75 8.05889368905 1 1 27 28 
 i 386 0 83 75 9.47393118833 -1 1 25 26 
 i 386 0 83 75 8.64385618977 -0.5 1 25 26 
 i 386 0 83 75 8.2288186905 0.5 1 25 26 
 i 386 0 83 75 8.05889368905 1 1 25 26 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURTRANS  27  	28  0.1 	 93 ; changing chords
$MIXDURTRANS  25  	26  0.1 	 92 ; static chord

 i 99 0 83 127 50 277 29 30 
;gongstrike
;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURTRANS  29  	30  0.9 	 80

;cb swell
 i 12 63 25 81 5.017921908 0.0 1 31 32 
;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURTRANS  31  	32  0.65 	 80

;tremolo
 i 387 0 83 1 14 14 201 1 27 33 
 i 387 0 83 1 14 14 201 1 28 34 
;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURTRANS  33  	34  0.0 	 93

;ensemble
 i 388 0 83 0.42 33 35 36 
 i 388 0 83 0.42 34 35 36 
 i 388 0 83 2.42 25 37 38 
 i 388 0 83 2.42 26 37 38 
 i 388 0 88 2.42 31 39 40 
 i 388 0 88 2.42 32 39 40 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURTRANS  35  	36  0.2  93	; changing chords
$MIXDURTRANS  37  	38  0.246  92	; static chords
$MIXDURTRANS  39  	40  0.6    80	; cbswell

;gong phaserverb
 i 389 0 83 1 0.99 0.99 150 0.18 0.6 0.77 29 30 41 42 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURTRANS  41  	42  1.2  80


i910 0   $DURT ;clear zaks

;;;;;;;;;;;;;
;Section B
;;;;;;;;;;;;;

b 283 

f 94 0 4096 -27 0 0 300 0.0 900 0.5 1970 1.3 2120 1.2 4096 0  ;string fade in, then
steady 

;bellchords
 i 21 0 17 15000 7.84799690655 1.10123 43 44 
 i 21 17 22 15000 8.017921908 1.10123 43 44 
 i 21 39 12 15000 7.9772799235 1.10123 43 44 
 i 21 51 17 15000 8.33985000288 1.10123 43 44 
 i 21 68 22 15000 7.9772799235 1.10123 43 44 
 i 21 90 12 15000 7.9772799235 1.10123 43 44 
 i 21 102 17 15000 8.33985000288 1.10123 43 44 
 i 21 119 22 15000 8.16992500144 1.10123 43 44 
 i 21 141 12 15000 8.43295940728 1.10123 43 44 
 i 21 153 17 15000 8.16992500144 1.10123 43 44 
 i 21 170 22 15000 8.16992500144 1.10123 43 44 
 i 21 192 22 15000 8.43295940728 1.10123 43 44 
 i 21 0 17 15000 7.65535182861 1.10123 43 44 
 i 21 17 22 15000 7.9772799235 1.10123 43 44 
 i 21 39 12 15000 7.75488750216 1.10123 43 44 
 i 21 51 17 15000 7.90689059561 1.10123 43 44 
 i 21 68 22 15000 7.84799690655 1.10123 43 44 
 i 21 90 12 15000 7.90689059561 1.10123 43 44 
 i 21 102 17 15000 8.33985000288 1.10123 43 44 
 i 21 119 22 15000 7.9772799235 1.10123 43 44 
 i 21 141 12 15000 8.16992500144 1.10123 43 44 
 i 21 153 17 15000 8.017921908 1.10123 43 44 
 i 21 170 22 15000 8.16992500144 1.10123 43 44 
 i 21 192 22 15000 8.49185309633 1.10123 43 44 
 i 21 0 17 15000 7.43295940728 1.10123 43 44 
 i 21 17 22 15000 7.75488750216 1.10123 43 44 
 i 21 39 12 15000 7.58496250072 1.10123 43 44 
 i 21 51 17 15000 7.58496250072 1.10123 43 44 
 i 21 68 22 15000 7.49185309633 1.10123 43 44 
 i 21 90 12 15000 7.49185309633 1.10123 43 44 
 i 21 102 17 15000 7.84799690655 1.10123 43 44 
 i 21 119 22 15000 7.65535182861 1.10123 43 44 
 i 21 141 12 15000 7.65535182861 1.10123 43 44 
 i 21 153 17 15000 7.58496250072 1.10123 43 44 
 i 21 170 22 15000 7.58496250072 1.10123 43 44 
 i 21 192 22 15000 7.90689059561 1.10123 43 44 
 i 21 0 17 15000 7.017921908 1.10123 43 44 
 i 21 17 22 15000 7.49185309633 1.10123 43 44 
 i 21 39 12 15000 7.39231742278 1.10123 43 44 
 i 21 51 17 15000 7.33985000288 1.10123 43 44 
 i 21 68 22 15000 7.16992500144 1.10123 43 44 
 i 21 90 12 15000 7.33985000288 1.10123 43 44 
 i 21 102 17 15000 7.65535182861 1.10123 43 44 
 i 21 119 22 15000 7.49185309633 1.10123 43 44 
 i 21 141 12 15000 7.43295940728 1.10123 43 44 
 i 21 153 17 15000 7.39231742278 1.10123 43 44 
 i 21 170 22 15000 7.43295940728 1.10123 43 44 
 i 21 192 22 15000 7.84799690655 1.10123 43 44 
 i 21 0.666567221231 6.125 15000 8.84799690655 1.10123 43 44 
 i 21 15.3729715949 6.125 15000 9.017921908 1.10123 43 44 
 i 21 40.8884978845 6.125 15000 8.9772799235 1.10123 43 44 
 i 21 52.1861615707 6.125 15000 9.33985000288 1.10123 43 44 
 i 21 67.1610317843 6.125 15000 8.9772799235 1.10123 43 44 
 i 21 89.0617803678 6.125 15000 8.9772799235 1.10123 43 44 
 i 21 101.437890146 6.125 15000 9.33985000288 1.10123 43 44 
 i 21 116.415211763 6.125 15000 9.16992500144 1.10123 43 44 
 i 21 138.782723341 6.125 15000 9.43295940728 1.10123 43 44 
 i 21 153.200923328 6.125 15000 9.16992500144 1.10123 43 44 
 i 21 167.929381663 6.125 15000 9.16992500144 1.10123 43 44 
 i 21 193.326682869 6.125 15000 9.43295940728 1.10123 43 44 
 i 21 0.466677743351 6.25 1436.32075472 8.84799690655 1.10123 43 44 
 i 21 2.39332828452 6.25 1457.54716981 8.90689059561 1.10123 43 44 
 i 21 1.06286553449 6.25 1478.77358491 8.84799690655 1.10123 43 44 
 i 21 0.253684127533 6.25 1500.0 8.90689059561 1.10123 43 44 
 i 21 2.3801269413 6.25 1521.22641509 9.58496250072 1.10123 43 44 
 i 21 0.919442140396 6.25 1542.45283019 9.43295940728 1.10123 43 44 
 i 21 0.523317171228 6.25 1563.67924528 9.58496250072 1.10123 43 44 
 i 21 0.262532480324 6.25 1584.90566038 9.43295940728 1.10123 43 44 
 i 21 15.0270501327 6.25 3441.03773585 9.017921908 1.10123 43 44 
 i 21 18.7543198509 6.25 3462.26415094 9.39231742278 1.10123 43 44 
 i 21 19.3995492054 6.25 3483.49056604 9.58496250072 1.10123 43 44 
 i 21 18.2351371108 6.25 3504.71698113 9.65535182861 1.10123 43 44 
 i 21 17.582363184 6.25 3525.94339623 9.58496250072 1.10123 43 44 
 i 21 17.5951636713 6.25 3547.16981132 9.65535182861 1.10123 43 44 
 i 21 16.1389712765 6.25 3568.39622642 10.3923174228 1.10123 43 44 
 i 21 15.5263162212 6.25 3589.62264151 10.1699250014 1.10123 43 44 
 i 21 17.3709547904 6.25 3633.25471698 10.3923174228 1.10123 43 44 
 i 21 19.9720269274 6.25 3676.88679245 10.1699250014 1.10123 43 44 
 i 21 37.9246601923 6.25 6035.37735849 8.9772799235 1.10123 43 44 
 i 21 38.833486743 6.25 6056.60377358 9.16992500144 1.10123 43 44 
 i 21 38.7899759976 6.25 6077.83018868 9.43295940728 1.10123 43 44 
 i 21 39.4790096168 6.25 6099.05660377 9.49185309633 1.10123 43 44 
 i 21 37.6177718071 6.25 6120.28301887 9.43295940728 1.10123 43 44 
 i 21 40.0036241939 6.25 6141.50943396 9.49185309633 1.10123 43 44 
 i 21 38.7296457725 6.25 6162.73584906 10.1699250014 1.10123 43 44 
 i 21 39.7089575935 6.25 6183.96226415 9.9772799235 1.10123 43 44 
 i 21 39.9635313445 6.25 6227.59433962 10.1699250014 1.10123 43 44 
 i 21 39.478346455 6.25 6271.22641509 9.9772799235 1.10123 43 44 
 i 21 40.0471155731 6.25 6314.85849057 9.84799690655 1.10123 43 44 
 i 21 43.3257401211 6.25 6358.49056604 9.9772799235 1.10123 43 44 
 i 21 44.3798058291 6.25 6402.12264151 10.3398500029 1.10123 43 44 
 i 21 52.3491848898 6.25 7450.47169811 9.33985000288 1.10123 43 44 
 i 21 50.4716514943 6.25 7471.69811321 9.16992500144 1.10123 43 44 
 i 21 51.0916634181 6.25 7492.9245283 9.33985000288 1.10123 43 44 
 i 21 50.7632974144 6.25 7514.1509434 9.90689059561 1.10123 43 44 
 i 21 50.6684742003 6.25 7535.37735849 9.75488750216 1.10123 43 44 
 i 21 53.1237090305 6.25 7556.60377358 9.90689059561 1.10123 43 44 
 i 21 52.2841760211 6.25 7577.83018868 10.017921908 1.10123 43 44 
 i 21 51.1958237608 6.25 7599.05660377 9.90689059561 1.10123 43 44 
 i 21 54.900942789 6.25 7642.68867925 10.017921908 1.10123 43 44 
 i 21 54.0067963903 6.25 7686.32075472 10.3923174228 1.10123 43 44 
 i 21 54.9894077169 6.25 7729.95283019 10.4329594073 1.10123 43 44 
 i 21 54.3138617664 6.25 7773.58490566 10.3923174228 1.10123 43 44 
 i 21 52.0225834597 6.25 7817.21698113 10.4329594073 1.10123 43 44 
 i 21 51.6869109112 6.25 7860.8490566 8.39231742278 1.10123 43 44 
 i 21 53.8299226204 6.25 7904.48113208 8.16992500144 1.10123 43 44 
 i 21 56.5064286026 6.25 7948.11320755 10.7548875022 1.10123 43 44 
 i 21 68.0031249313 6.25 9477.59433962 8.9772799235 1.10123 43 44 
 i 21 69.817800903 6.25 9498.82075472 8.84799690655 1.10123 43 44 
 i 21 68.375256411 6.25 9520.04716981 8.9772799235 1.10123 43 44 
 i 21 68.2738900174 6.25 9541.27358491 9.33985000288 1.10123 43 44 
 i 21 66.2010341953 6.25 9562.5 9.39231742278 1.10123 43 44 
 i 21 66.5159688261 6.25 9583.72641509 9.33985000288 1.10123 43 44 
 i 21 68.5742839983 6.25 9604.95283019 9.39231742278 1.10123 43 44 
 i 21 69.5872565447 6.25 9626.17924528 9.9772799235 1.10123 43 44 
 i 21 69.7855492048 6.25 9647.40566038 10.6553518286 1.10123 43 44 
 i 21 70.6443884663 6.25 9691.03773585 10.4918530963 1.10123 43 44 
 i 21 69.1204607282 6.25 9734.66981132 10.6553518286 1.10123 43 44 
 i 21 69.3310370645 6.25 9778.30188679 10.4918530963 1.10123 43 44 
 i 21 72.6535716531 6.25 9821.93396226 10.6553518286 1.10123 43 44 
 i 21 68.6890778519 6.25 9865.56603774 8.16992500144 1.10123 43 44 
 i 21 73.6826418614 6.25 9909.19811321 8.33985000288 1.10123 43 44 
 i 21 73.0401654049 6.25 9952.83018868 8.16992500144 1.10123 43 44 
 i 21 71.9793294789 6.25 9996.46226415 8.33985000288 1.10123 43 44 
 i 21 74.9227975479 6.25 10040.0943396 8.39231742278 1.10123 43 44 
 i 21 73.8250369119 6.25 10061.3207547 8.9772799235 1.10123 43 44 
 i 21 74.2023979451 6.25 10082.5471698 8.84799690655 1.10123 43 44 
 i 21 72.2155473879 6.25 10103.7735849 8.9772799235 1.10123 43 44 
 i 21 74.3343337372 6.25 10125.0 8.84799690655 1.10123 43 44 
 i 21 74.8743791003 6.25 10146.2264151 8.9772799235 1.10123 43 44 
 i 21 87.9465410773 6.25 12071.9339623 8.9772799235 1.10123 43 44 
 i 21 92.4900077313 6.25 12115.5660377 9.017921908 1.10123 43 44 
 i 21 91.5502274893 6.25 12136.7924528 8.9772799235 1.10123 43 44 
 i 21 91.9915413871 6.25 12158.0188679 8.90689059561 1.10123 43 44 
 i 21 91.882472492 6.25 12179.245283 8.9772799235 1.10123 43 44 
 i 21 90.1894843208 6.25 12200.4716981 9.65535182861 1.10123 43 44 
 i 21 88.9612899825 6.25 12221.6981132 9.49185309633 1.10123 43 44 
 i 21 89.1532913055 6.25 12242.9245283 9.65535182861 1.10123 43 44 
 i 21 92.9438506369 6.25 12264.1509434 9.49185309633 1.10123 43 44 
 i 21 92.7724219826 6.25 12285.3773585 9.65535182861 1.10123 43 44 
 i 21 89.8932875141 6.25 12329.009434 9.90689059561 1.10123 43 44 
 i 21 92.3942364668 6.25 12372.6415094 9.9772799235 1.10123 43 44 
 i 21 92.1951228877 6.25 12416.2735849 10.017921908 1.10123 43 44 
 i 21 92.6109426148 6.25 12459.9056604 9.9772799235 1.10123 43 44 
 i 21 94.9458701153 6.25 12503.5377358 10.017921908 1.10123 43 44 
 i 21 95.0120197465 6.25 12547.1698113 10.7548875022 1.10123 43 44 
 i 21 93.591577857 6.25 12590.8018868 10.5849625007 1.10123 43 44 
 i 21 95.426825056 6.25 12634.4339623 10.7548875022 1.10123 43 44 
 i 21 96.3426340736 6.25 12678.0660377 10.5849625007 1.10123 43 44 
 i 21 97.9105199179 6.25 12699.2924528 10.7548875022 1.10123 43 44 
 i 21 96.9260993878 6.25 12720.5188679 8.33985000288 1.10123 43 44 
 i 21 94.720485546 6.25 12741.745283 8.49185309633 1.10123 43 44 
 i 21 98.1388216471 6.25 12762.9716981 8.58496250072 1.10123 43 44 
 i 21 93.7815251044 6.25 12784.1981132 8.49185309633 1.10123 43 44 
 i 21 98.3262718468 6.25 12805.4245283 8.58496250072 1.10123 43 44 
 i 21 94.840427704 6.25 12826.6509434 9.33985000288 1.10123 43 44 
 i 21 98.5269636203 6.25 12847.8773585 9.017921908 1.10123 43 44 
 i 21 98.7541595714 6.25 12891.509434 9.33985000288 1.10123 43 44 
 i 21 95.0487827188 6.25 12935.1415094 9.017921908 1.10123 43 44 
 i 21 101.473831496 6.25 13487.0283019 9.33985000288 1.10123 43 44 
 i 21 101.156925353 6.25 13530.6603774 9.43295940728 1.10123 43 44 
 i 21 101.692788461 6.25 13574.2924528 9.65535182861 1.10123 43 44 
 i 21 105.212255485 6.25 13595.5188679 9.75488750216 1.10123 43 44 
 i 21 101.196538475 6.25 13616.745283 9.65535182861 1.10123 43 44 
 i 21 102.881672933 6.25 13637.9716981 9.75488750216 1.10123 43 44 
 i 21 101.577231784 6.25 13659.1981132 10.4329594073 1.10123 43 44 
 i 21 101.999776902 6.25 13680.4245283 10.3398500029 1.10123 43 44 
 i 21 103.703613643 6.25 13701.6509434 10.4329594073 1.10123 43 44 
 i 21 106.280033566 6.25 13722.8773585 10.3398500029 1.10123 43 44 
 i 21 104.367896832 6.25 13744.1037736 10.017921908 1.10123 43 44 
 i 21 103.68964692 6.25 13787.7358491 10.3398500029 1.10123 43 44 
 i 21 103.456679568 6.25 13831.3679245 10.4918530963 1.10123 43 44 
 i 21 107.238360105 6.25 13875.0 10.5849625007 1.10123 43 44 
 i 21 107.938859379 6.25 13918.6320755 10.4918530963 1.10123 43 44 
 i 21 106.95492254 6.25 13962.2641509 10.5849625007 1.10123 43 44 
 i 21 106.816240522 6.25 14005.8962264 8.49185309633 1.10123 43 44 
 i 21 109.033632943 6.25 14049.5283019 8.39231742278 1.10123 43 44 
 i 21 107.213651317 6.25 14093.1603774 8.49185309633 1.10123 43 44 
 i 21 109.032096548 6.25 14136.7924528 8.65535182861 1.10123 43 44 
 i 21 109.591507831 6.25 14158.0188679 8.49185309633 1.10123 43 44 
 i 21 106.91666925 6.25 14179.245283 8.65535182861 1.10123 43 44 
 i 21 109.23801006 6.25 14200.4716981 8.90689059561 1.10123 43 44 
 i 21 107.182616891 6.25 14221.6981132 8.9772799235 1.10123 43 44 
 i 21 106.013551551 6.25 14242.9245283 8.90689059561 1.10123 43 44 
 i 21 108.219901806 6.25 14264.1509434 8.9772799235 1.10123 43 44 
 i 21 107.085280293 6.25 14285.3773585 9.65535182861 1.10123 43 44 
 i 21 107.610236091 6.25 14306.6037736 9.49185309633 1.10123 43 44 
 i 21 109.04707262 6.25 14350.2358491 9.39231742278 1.10123 43 44 
 i 21 110.000404204 6.25 14393.8679245 9.49185309633 1.10123 43 44 
 i 21 108.226813226 6.25 14437.5 9.39231742278 1.10123 43 44 
 i 21 110.211510185 6.25 14481.1320755 9.49185309633 1.10123 43 44 
 i 21 112.29750299 6.25 14524.7641509 9.75488750216 1.10123 43 44 
 i 21 117.763268495 6.25 15491.745283 9.16992500144 1.10123 43 44 
 i 21 117.801868633 6.25 15535.3773585 9.017921908 1.10123 43 44 
 i 21 119.921990959 6.25 15579.009434 9.16992500144 1.10123 43 44 
 i 21 118.402693584 6.25 15622.6415094 9.84799690655 1.10123 43 44 
 i 21 123.084236259 6.25 15666.2735849 10.4918530963 1.10123 43 44 
 i 21 123.182027101 6.25 15687.5 10.3923174228 1.10123 43 44 
 i 21 120.184794576 6.25 15708.7264151 10.4918530963 1.10123 43 44 
 i 21 119.97403533 6.25 15729.9528302 10.3923174228 1.10123 43 44 
 i 21 120.246354547 6.25 15751.1792453 10.4918530963 1.10123 43 44 
 i 21 123.001519007 6.25 15772.4056604 10.7548875022 1.10123 43 44 
 i 21 123.150448573 6.25 15793.6320755 8.017921908 1.10123 43 44 
 i 21 123.052116116 6.25 15814.8584906 10.7548875022 1.10123 43 44 
 i 21 121.283945182 6.25 15836.0849057 8.017921908 1.10123 43 44 
 i 21 124.809852232 6.25 15879.7169811 8.16992500144 1.10123 43 44 
 i 21 122.907872414 6.25 15923.3490566 8.84799690655 1.10123 43 44 
 i 21 121.81790298 6.25 15966.9811321 8.65535182861 1.10123 43 44 
 i 21 124.847024091 6.25 16010.6132075 8.84799690655 1.10123 43 44 
 i 21 121.490129642 6.25 16054.245283 8.65535182861 1.10123 43 44 
 i 21 125.507630871 6.25 16097.8773585 8.84799690655 1.10123 43 44 
 i 21 127.015240985 6.25 16141.509434 9.017921908 1.10123 43 44 
 i 21 123.130012751 6.25 16185.1415094 9.16992500144 1.10123 43 44 
 i 21 123.027627668 6.25 16228.7735849 9.017921908 1.10123 43 44 
 i 21 124.492593791 6.25 16250.0 8.9772799235 1.10123 43 44 
 i 21 126.778293618 6.25 16271.2264151 9.017921908 1.10123 43 44 
 i 21 126.384821393 6.25 16292.4528302 9.75488750216 1.10123 43 44 
 i 21 125.574606195 6.25 16313.6792453 9.58496250072 1.10123 43 44 
 i 21 126.089596659 6.25 16334.9056604 9.75488750216 1.10123 43 44 
 i 21 127.369803729 6.25 16356.1320755 9.58496250072 1.10123 43 44 
 i 21 125.854897011 6.25 16377.3584906 9.75488750216 1.10123 43 44 
 i 21 128.56472531 6.25 16398.5849057 9.9772799235 1.10123 43 44 
 i 21 127.752750138 6.25 16442.2169811 10.017921908 1.10123 43 44 
 i 21 126.877997309 6.25 16485.8490566 10.1699250014 1.10123 43 44 
 i 21 126.968154664 6.25 16529.4811321 10.017921908 1.10123 43 44 
 i 21 138.372046576 6.25 18086.0849057 9.43295940728 1.10123 43 44 
 i 21 139.905243853 6.25 18129.7169811 10.017921908 1.10123 43 44 
 i 21 141.457129921 6.25 18173.3490566 9.90689059561 1.10123 43 44 
 i 21 144.075990625 6.25 18216.9811321 10.017921908 1.10123 43 44 
 i 21 151.937347349 6.25 19501.1792453 9.16992500144 1.10123 43 44 
 i 21 155.527800886 6.25 19544.8113208 9.39231742278 1.10123 43 44 
 i 21 154.03328729 6.25 19588.4433962 9.58496250072 1.10123 43 44 
 i 21 152.682080989 6.25 19632.0754717 9.84799690655 1.10123 43 44 
 i 21 156.30824113 6.25 19675.7075472 9.90689059561 1.10123 43 44 
 i 21 171.271474675 6.25 21505.8962264 9.16992500144 1.10123 43 44 
 i 21 170.502633082 6.25 21549.5283019 9.33985000288 1.10123 43 44 
 i 21 170.649941456 6.25 21593.1603774 9.90689059561 1.10123 43 44 
 i 21 173.248395182 6.25 21636.7924528 9.75488750216 1.10123 43 44 
 i 21 172.070437933 6.25 21680.4245283 9.90689059561 1.10123 43 44 
 i 21 174.327566918 6.25 21724.0566038 9.75488750216 1.10123 43 44 
 i 21 171.39332705 6.25 21767.6886792 9.90689059561 1.10123 43 44 
 i 21 173.123427957 6.25 21788.9150943 10.017921908 1.10123 43 44 
 i 21 173.379139587 6.25 21810.1415094 10.3923174228 1.10123 43 44 
 i 21 170.978377279 6.25 21831.3679245 10.4329594073 1.10123 43 44 
 i 21 172.106566306 6.25 21852.5943396 10.3923174228 1.10123 43 44 
 i 21 171.293051162 6.25 21873.8207547 10.4329594073 1.10123 43 44 
 i 21 192.248383318 6.25 24100.2358491 9.43295940728 1.10123 43 44 
 i 21 192.207347089 6.25 24143.8679245 9.33985000288 1.10123 43 44 
 i 21 192.297164117 6.25 24187.5 9.43295940728 1.10123 43 44 
 i 21 194.215805195 6.25 24231.1320755 9.33985000288 1.10123 43 44 
 i 21 195.715994894 6.25 24274.7641509 9.017921908 1.10123 43 44 
 i 21 192.226882487 6.25 24318.3962264 9.33985000288 1.10123 43 44 
 i 21 192.032819734 6.25 24362.0283019 9.49185309633 1.10123 43 44 
 i 21 195.084799432 6.25 24383.254717 9.58496250072 1.10123 43 44 
 i 21 193.359206757 6.25 24404.4811321 9.49185309633 1.10123 43 44 
 i 21 195.905175113 6.25 24425.7075472 9.58496250072 1.10123 43 44 
 i 21 194.745755445 6.25 24446.9339623 10.3398500029 1.10123 43 44 
 i 21 197.658346226 6.25 24468.1603774 10.017921908 1.10123 43 44 
 i 21 196.223484009 6.25 24489.3867925 10.3398500029 1.10123 43 44 
 i 21 196.968179848 6.25 24510.6132075 10.4329594073 1.10123 43 44 
 i 21 193.962680403 6.25 24531.8396226 10.3398500029 1.10123 43 44 
 i 21 197.813308363 6.25 24575.4716981 10.4329594073 1.10123 43 44 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR2	   43  	44  0.0  80 ;bellchords and bell jangles

;vlc chords
 i 386 0 17 75 7.84799690655 0 1 45 46 
 i 386 17 22 75 8.017921908 0 1 45 46 
 i 386 39 12 75 7.9772799235 0 1 45 46 
 i 386 51 17 75 8.33985000288 0 1 45 46 
 i 386 68 22 75 7.9772799235 0 1 45 46 
 i 386 90 12 75 7.9772799235 0 1 45 46 
 i 386 102 17 75 8.33985000288 0 1 45 46 
 i 386 119 22 75 8.16992500144 0 1 45 46 
 i 386 141 12 75 8.43295940728 0 1 45 46 
 i 386 153 17 75 8.16992500144 0 1 45 46 
 i 386 170 22 75 8.16992500144 0 1 45 46 
 i 386 192 22 75 8.43295940728 0 1 45 46 
 i 386 0 17 75 7.65535182861 0 1 45 46 
 i 386 17 22 75 7.9772799235 0 1 45 46 
 i 386 39 12 75 7.75488750216 0 1 45 46 
 i 386 51 17 75 7.90689059561 0 1 45 46 
 i 386 68 22 75 7.84799690655 0 1 45 46 
 i 386 90 12 75 7.90689059561 0 1 45 46 
 i 386 102 17 75 8.33985000288 0 1 45 46 
 i 386 119 22 75 7.9772799235 0 1 45 46 
 i 386 141 12 75 8.16992500144 0 1 45 46 
 i 386 153 17 75 8.017921908 0 1 45 46 
 i 386 170 22 75 8.16992500144 0 1 45 46 
 i 386 192 22 75 8.49185309633 0 1 45 46 
 i 386 0 1 75 7.43295940728 0 1 45 46 
 i 386 17 1 75 7.75488750216 0 1 45 46 
 i 386 39 1 75 7.58496250072 0 1 45 46 
 i 386 51 1 75 7.58496250072 0 1 45 46 
 i 386 68 1 75 7.49185309633 0 1 45 46 
 i 386 90 1 75 7.49185309633 0 1 45 46 
 i 386 102 1 75 7.84799690655 0 1 45 46 
 i 386 119 1 75 7.65535182861 0 1 45 46 
 i 386 141 1 75 7.65535182861 0 1 45 46 
 i 386 153 1 75 7.58496250072 0 1 45 46 
 i 386 170 1 75 7.58496250072 0 1 45 46 
 i 386 192 1 75 7.90689059561 0 1 45 46 
 i 386 0 17 75 7.017921908 0 1 45 46 
 i 386 17 22 75 7.49185309633 0 1 45 46 
 i 386 39 12 75 7.39231742278 0 1 45 46 
 i 386 51 17 75 7.33985000288 0 1 45 46 
 i 386 68 22 75 7.16992500144 0 1 45 46 
 i 386 90 12 75 7.33985000288 0 1 45 46 
 i 386 102 17 75 7.65535182861 0 1 45 46 
 i 386 119 22 75 7.49185309633 0 1 45 46 
 i 386 141 12 75 7.43295940728 0 1 45 46 
 i 386 153 17 75 7.39231742278 0 1 45 46 
 i 386 170 22 75 7.43295940728 0 1 45 46 
 i 386 192 22 75 7.84799690655 0 1 45 46 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR2	   45  	46  0.1 	 94

;flute section_b
 i 25 0 0.125 85 8.017921908 0.5 0.0196360491085 47 48 
 i 25 17 0.125 85 8.49185309633 0.5 0.0508281013504 47 48 
 i 25 39 0.125 85 8.39231742278 0.5 0.149318026737 47 48 
 i 25 51 0.125 85 8.33985000288 0.5 0.142413389555 47 48 
 i 25 68 0.125 85 8.16992500144 0.5 0.156623455543 47 48 
 i 25 90 0.125 85 8.33985000288 0.5 0.143917120403 47 48 
 i 25 102 0.125 85 8.65535182861 0.5 0.0541414038774 47 48 
 i 25 119 0.125 85 8.49185309633 0.5 -0.0513058178591 47 48 
 i 25 141 0.125 85 8.43295940728 0.5 -0.112698811657 47 48 
 i 25 153 0.125 85 8.39231742278 0.5 0.0113714944999 47 48 
 i 25 170 0.125 85 8.43295940728 0.5 -0.114510270677 47 48 
 i 25 192 0.125 85 8.84799690655 0.5 0.0155640447299 47 48 
 i 25 0.37 0.44 85 8.017921908 1 0.0434796439393 47 48 
 i 25 0.74 0.44 85 8.16992500144 0 0.166463127215 47 48 
 i 25 1.11 0.44 85 8.017921908 0 -0.222609391694 47 48 
 i 25 1.48 15.96 85 8.16992500144 0 0.0406239345015 47 48 
 i 25 17.37 0.44 85 8.49185309633 0.7 0.174979972719 47 48 
 i 25 17.74 0.44 85 8.39231742278 0.4 -0.0950562116044 47 48 
 i 25 18.11 0.44 85 8.49185309633 0 0.0787715621368 47 48 
 i 25 18.48 0.44 85 8.39231742278 0 -0.0737687199438 47 48 
 i 25 18.85 20.59 85 8.49185309633 0.3 -0.197309684352 47 48 
 i 25 39.37 0.44 85 8.39231742278 0 0.00594031257327 47 48 
 i 25 39.74 0.44 85 8.58496250072 0 0.0159355299654 47 48 
 i 25 40.11 0.44 85 8.65535182861 0 -0.209685509431 47 48 
 i 25 40.48 0.44 85 8.58496250072 0 0.0757429675898 47 48 
 i 25 40.85 0.44 85 8.65535182861 0 0.205220043743 47 48 
 i 25 41.22 0.44 85 9.39231742278 0.7 -0.215856841194 47 48 
 i 25 41.59 0.44 85 9.16992500144 0.4 -0.107229409724 47 48 
 i 25 41.96 0.25 85 9.39231742278 0 -0.0713701577534 47 48 
 i 25 42.14 0.25 85 9.16992500144 0 -0.237248350246 47 48 
 i 25 42.32 0.25 85 9.39231742278 0.3 0.00595272555577 47 48 
 i 25 42.5 8.94 85 9.49185309633 0 -0.185921761308 47 48 
 i 25 51.37 0.44 85 8.33985000288 0 -0.17600912013 47 48 
 i 25 51.74 0.44 85 8.39231742278 1 -0.202576933542 47 48 
 i 25 52.11 0.44 85 8.33985000288 0 -0.11730973932 47 48 
 i 25 52.48 0.44 85 8.39231742278 0 -0.188347543305 47 48 
 i 25 52.85 0.44 85 8.9772799235 0.7 0.205634186335 47 48 
 i 25 53.22 0.44 85 8.84799690655 0.4 0.215348491226 47 48 
 i 25 53.59 0.44 85 8.9772799235 0 0.0761985327033 47 48 
 i 25 53.96 0.25 85 8.84799690655 0 0.0801731824062 47 48 
 i 25 54.14 0.25 85 8.65535182861 0.3 0.123096843127 47 48 
 i 25 54.32 0.25 85 8.84799690655 0 -0.133027785192 47 48 
 i 25 54.5 0.25 85 9.017921908 0 0.190619512795 47 48 
 i 25 54.68 0.25 85 9.16992500144 1 0.0759994810578 47 48 
 i 25 54.86 0.25 85 9.017921908 0 -0.117749345456 47 48 
 i 25 55.04 0.25 85 9.16992500144 0 0.0362484185426 47 48 
 i 25 55.22 0.25 85 9.84799690655 0.7 0.112221435933 47 48 
 i 25 55.4 0.25 85 9.65535182861 0.4 -0.136209869782 47 48 
 i 25 55.58 12.67 85 9.84799690655 0 0.0704293033336 47 48 
 i 25 68.18 0.44 85 8.16992500144 0 0.220476547501 47 48 
 i 25 68.55 0.44 85 10.7548875022 0.3 -0.209217002125 47 48 
 i 25 68.92 0.44 85 8.16992500144 0 -0.042918333299 47 48 
 i 25 69.29 0.44 85 8.43295940728 0 -0.134547159846 47 48 
 i 25 69.66 0.44 85 8.49185309633 1 -0.137436197845 47 48 
 i 25 70.03 0.44 85 8.43295940728 0 0.14155387255 47 48 
 i 25 70.4 0.44 85 8.49185309633 0 -0.213134876096 47 48 
 i 25 70.77 0.44 85 9.16992500144 0.7 -0.0397812662112 47 48 
 i 25 71.14 0.25 85 8.9772799235 0.4 0.0324898494617 47 48 
 i 25 71.32 0.25 85 8.84799690655 0 -0.248483177772 47 48 
 i 25 71.5 0.25 85 8.9772799235 0 -0.0729897004141 47 48 
 i 25 71.68 0.25 85 8.84799690655 0.3 -0.201842448277 47 48 
 i 25 71.86 0.25 85 8.9772799235 0 0.142517635082 47 48 
 i 25 72.04 0.25 85 9.33985000288 0 -0.0800608819357 47 48 
 i 25 72.22 0.25 85 9.39231742278 1 0.118630124196 47 48 
 i 25 72.4 0.25 85 9.33985000288 0 -0.01707005409 47 48 
 i 25 72.58 0.25 85 9.39231742278 0 0.190611784867 47 48 
 i 25 72.76 0.44 85 9.9772799235 0 -0.0473306752261 47 48 
 i 25 73.13 0.44 81 10.6553518286 0.4 0.114840963067 47 48 ;
 i 25 73.5 0.44 60 10.4918530963 0 -0.214851809017 47 48   ;hand edited. 
 i 25 73.87 16.38 81 10.6553518286 0 0.0536676517554 47 48 ;
 i 25 90.18 0.25 85 8.33985000288 0.3 0.109484567869 47 48 
 i 25 90.36 0.44 85 8.43295940728 0 -0.178174580683 47 48 
 i 25 90.73 0.44 85 8.65535182861 0 0.215384278096 47 48 
 i 25 91.1 0.44 85 8.75488750216 1 -0.19727364207 47 48 
 i 25 91.47 0.44 85 8.65535182861 0 -0.0311240013958 47 48 
 i 25 91.84 0.44 85 8.75488750216 0 0.203013171727 47 48 
 i 25 92.21 0.44 85 8.84799690655 0 -0.0462625523348 47 48 
 i 25 92.58 0.44 85 9.49185309633 0.7 0.160126559276 47 48 
 i 25 92.95 0.44 85 9.39231742278 0 0.190176052609 47 48 
 i 25 93.32 0.25 85 9.49185309633 0 0.222431909481 47 48 
 i 25 93.5 0.25 85 9.39231742278 0.3 -0.241970460524 47 48 
 i 25 93.68 0.25 85 9.49185309633 0 -0.245534613935 47 48 
 i 25 93.86 0.25 85 9.75488750216 0 0.243922199701 47 48 
 i 25 94.04 0.25 85 9.84799690655 1 -0.226833048086 47 48 
 i 25 94.22 0.25 85 9.75488750216 0 0.244010384734 47 48 
 i 25 94.4 0.25 85 9.65535182861 0 -0.171979039617 47 48 
 i 25 94.58 0.25 85 9.75488750216 0 -0.236005570326 47 48 
 i 25 94.76 0.25 75 10.4329594073 0.7 0.02181459746 47 48 
 i 25 94.94 0.44 75 10.3398500029 0.4 0.219877708746 47 48 
 i 25 95.31 0.44 72 10.4329594073 0 0.134048881448 47 48 
 i 25 95.68 0.44 75 10.3398500029 0.3 0.0223444412501 47 48 
 i 25 96.05 0.44 75 10.4329594073 0 0.0494854830968 47 48 
 i 25 96.42 0.44 78 10.6553518286 0 0.076290492982 47 48 
 i 25 96.79 0.44 85 10.7548875022 1 0.187293438803 47 48 
 i 25 97.16 0.44 85 8.017921908 0 -0.166515769577 47 48 
 i 25 97.53 4.72 85 10.7548875022 0 0.097501958542 47 48 
 i 25 102.18 0.25 85 8.65535182861 0 -0.221839504647 47 48 
 i 25 102.36 0.25 85 9.39231742278 0.7 0.197732037039 47 48 
 i 25 102.54 0.44 85 9.16992500144 0.4 -0.0461006163534 47 48 
 i 25 102.91 0.44 85 9.39231742278 0 0.163465314743 47 48 
 i 25 103.28 0.44 85 9.16992500144 0.3 0.0187395887869 47 48 
 i 25 103.65 0.44 85 9.39231742278 0 0.183613098769 47 48 
 i 25 104.02 0.44 85 9.58496250072 0 -0.138970179883 47 48 
 i 25 104.39 0.44 85 9.84799690655 1 -0.234312702183 47 48 
 i 25 104.76 0.44 85 9.90689059561 0 0.0756826390535 47 48 
 i 25 105.13 0.44 85 9.84799690655 0 0.139084135251 47 48 
 i 25 105.5 0.25 85 9.90689059561 0 -0.0222927178885 47 48 
 i 25 105.68 0.25 85 10.5849625007 0.7 0.078385627484 47 48 
 i 25 105.86 0.25 85 10.4329594073 0.4 0.104250920081 47 48 
 i 25 106.04 0.25 85 10.5849625007 0 0.138690930137 47 48 
 i 25 106.22 0.25 85 10.4329594073 0 -0.0412240807655 47 48 
 i 25 106.4 0.25 85 10.5849625007 0 -0.163257852768 47 48 
 i 25 106.58 0.25 85 10.7548875022 0 0.119619505029 47 48 
 i 25 106.76 0.25 85 8.33985000288 1 -0.00494588792218 47 48 
 i 25 106.94 0.25 85 8.39231742278 0 -0.0909559084227 47 48 
 i 25 107.12 0.44 85 8.33985000288 0 -0.0271446721383 47 48 
 i 25 107.49 0.44 85 8.39231742278 0 -0.203614127647 47 48 
 i 25 107.86 0.44 85 8.9772799235 0.7 -0.219912205452 47 48 
 i 25 108.23 0.44 85 8.84799690655 0.4 0.242994281054 47 48 
 i 25 108.6 0.44 85 8.9772799235 0 0.0177593935096 47 48 
 i 25 108.97 0.44 85 8.84799690655 0 -0.209708926216 47 48 
 i 25 109.34 0.44 85 8.65535182861 0.3 -0.216992649742 47 48 
 i 25 109.71 0.44 85 8.84799690655 0 0.107730211862 47 48 
 i 25 110.08 0.25 85 9.017921908 1 0.0388442388934 47 48 
 i 25 110.26 0.25 85 9.16992500144 0 -0.00771621379879 47 48 
 i 25 110.44 0.25 85 9.017921908 0 0.154497609728 47 48 
 i 25 110.62 0.25 85 9.16992500144 0 -0.19683529263 47 48 
 i 25 110.8 0.25 85 9.84799690655 0.7 0.0499323529672 47 48 
 i 25 110.98 0.25 85 9.65535182861 0.4 -0.177908002957 47 48 
 i 25 111.16 8.09 85 9.84799690655 0 -0.21302456869 47 48 
 i 25 119.18 0.25 85 8.49185309633 0 -0.00508576889849 47 48 
 i 25 119.36 0.25 85 8.39231742278 0.3 0.237236362233 47 48 
 i 25 119.54 0.25 85 8.49185309633 0 -0.102005951304 47 48 
 i 25 119.72 0.25 85 8.75488750216 1 0.195116712655 47 48 
 i 25 119.9 0.44 85 8.84799690655 0 -0.0966484663193 47 48 
 i 25 120.27 0.44 85 8.75488750216 0 -0.0867553271459 47 48 
 i 25 120.64 0.44 85 8.84799690655 0 -0.0500784922544 47 48 
 i 25 121.01 0.44 85 9.49185309633 0.7 -0.0515623671548 47 48 
 i 25 121.38 0.44 85 9.39231742278 0.4 0.074245037504 47 48 
 i 25 121.75 0.44 85 9.16992500144 0 -0.232107316177 47 48 
 i 25 122.12 0.44 85 9.39231742278 0 0.214050323299 47 48 
 i 25 122.49 0.44 85 9.16992500144 0.3 0.171236288449 47 48 
 i 25 122.86 0.25 85 9.39231742278 0 0.0252985885154 47 48 
 i 25 123.04 0.25 85 9.58496250072 0 -0.0946373170923 47 48 
 i 25 123.22 0.25 85 9.65535182861 0 -0.00700301275137 47 48 
 i 25 123.4 0.25 85 9.58496250072 0 0.0539857664244 47 48 
 i 25 123.58 0.25 85 9.65535182861 0 0.204975139703 47 48 
 i 25 123.76 0.25 85 10.3923174228 0.7 -0.186358538568 47 48 
 i 25 123.94 0.25 85 8.33985000288 0.4 0.226614420563 47 48 
 i 25 124.12 0.25 85 8.017921908 0 -0.193487450164 47 48 
 i 25 124.3 0.25 85 8.33985000288 0 0.229729976511 47 48 
 i 25 124.48 0.44 85 8.017921908 0.3 0.0413077269609 47 48 
 i 25 124.85 0.44 85 8.33985000288 0 0.105905439004 47 48 
 i 25 125.22 0.44 85 8.49185309633 0 -0.0441528085702 47 48 
 i 25 125.59 0.44 85 8.58496250072 1 -0.113567375512 47 48 
 i 25 125.96 0.44 85 8.49185309633 0 0.0973092915082 47 48 
 i 25 126.33 0.44 85 8.58496250072 0 0.0115736016141 47 48 
 i 25 126.7 0.44 85 8.65535182861 0.7 0.0248316661774 47 48 
 i 25 127.07 0.44 85 9.39231742278 0.4 -0.0240976387633 47 48 
 i 25 127.44 0.25 85 9.16992500144 0 0.00889135420745 47 48 
 i 25 127.62 0.25 85 9.39231742278 0 -0.0848983020386 47 48 
 i 25 127.8 0.25 85 9.16992500144 0.3 -0.0196753813996 47 48 
 i 25 127.98 0.25 85 9.39231742278 0 0.248777180668 47 48 
 i 25 128.16 13.09 85 9.58496250072 0 0.0781142190834 47 48 
 i 25 141.18 0.25 85 8.43295940728 1 -0.0468315297422 47 48 
 i 25 141.36 0.25 85 8.39231742278 0 -0.227849845933 47 48 
 i 25 141.54 0.25 85 8.33985000288 0 0.100103666464 47 48 
 i 25 141.72 0.25 85 8.39231742278 0.7 -0.176424865074 47 48 
 i 25 141.9 0.25 85 8.9772799235 0.4 0.239420845125 47 48 
 i 25 142.08 0.25 85 8.84799690655 0 0.0346136554342 47 48 
 i 25 142.26 10.99 85 8.9772799235 0 -0.0253918572563 47 48 
 i 25 153.18 0.25 85 8.39231742278 0.3 0.209190371344 47 48 
 i 25 153.36 0.25 85 8.49185309633 0 0.143130366508 47 48 
 i 25 153.54 0.25 85 8.75488750216 0 0.18798749307 47 48 
 i 25 153.72 0.25 85 8.84799690655 1 0.0153136623487 47 48 
 i 25 153.9 0.25 85 8.90689059561 0 0.0880672813327 47 48 
 i 25 154.08 0.25 85 8.84799690655 0 0.113688618424 47 48 
 i 25 154.26 0.44 85 8.90689059561 0.7 -0.215339624593 47 48 
 i 25 154.63 0.44 85 9.58496250072 0.4 0.216196775734 47 48 
 i 25 155.0 15.25 85 9.43295940728 0 0.00997062203273 47 48 
 i 25 170.18 0.25 85 8.43295940728 0 0.138087579193 47 48 
 i 25 170.36 0.25 85 8.33985000288 0.3 0.0917947696093 47 48 
 i 25 170.54 0.25 85 8.43295940728 0 0.226448855766 47 48 
 i 25 170.72 0.25 85 8.65535182861 0 0.164557520843 47 48 
 i 25 170.9 0.25 85 8.90689059561 1 0.0953245908027 47 48 
 i 25 171.08 0.25 85 8.9772799235 0 -0.165828508715 47 48 
 i 25 171.26 0.44 85 8.90689059561 0 0.0357835020349 47 48 
 i 25 171.63 0.44 85 8.9772799235 0 -0.0639732068633 47 48 
 i 25 172.0 0.44 85 9.65535182861 0.4 -0.150606844146 47 48 
 i 25 172.37 0.44 85 9.49185309633 0 -0.0516541186949 47 48 
 i 25 172.74 0.44 85 9.65535182861 0 0.00359440299637 47 48 
 i 25 173.11 0.44 85 9.49185309633 0.3 0.0127222977917 47 48 
 i 25 173.48 18.77 85 9.65535182861 0 -0.224211092879 47 48 
 i 25 192.18 0.25 85 8.84799690655 0 0.032634565366 47 48 
 i 25 192.36 0.25 85 9.017921908 1 0.189117152527 47 48 
 i 25 192.54 0.25 85 9.16992500144 0 0.178511288277 47 48 
 i 25 192.72 0.25 85 9.017921908 0 0.2490696421 47 48 
 i 25 192.9 0.25 85 9.16992500144 0 0.11039904589 47 48 
 i 25 193.08 0.25 85 9.84799690655 0.7 -0.00130007723161 47 48 
 i 25 193.26 0.44 85 9.65535182861 0 0.188184462226 47 48 
 i 25 193.63 0.44 85 9.84799690655 0 0.108176584966 47 48 
 i 25 194.0 0.44 85 9.65535182861 0.3 -0.156117135176 47 48 
 i 25 194.37 0.44 85 9.49185309633 0 0.125461308279 47 48 
 i 25 194.74 0.44 85 9.65535182861 0 0.182604956219 47 48 
 i 25 195.11 0.44 85 9.90689059561 1 0.0731747022445 47 48 
 i 25 195.48 0.44 85 9.9772799235 0 -0.185175927186 47 48 
 i 25 195.85 0.44 85 9.90689059561 0 0.139430674933 47 48 
 i 25 196.22 0.25 85 9.9772799235 0 -0.0477125373358 47 48 
 i 25 196.4 0.25 85 10.6553518286 0.7 -0.0590855268004 47 48 
 i 25 196.58 0.25 60 10.4918530963 0.4 0.248530834851 47 48 ;and this

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR2	   47  	48  0.2  80

;stresonbank
 i 101 0 6 0.99 26 27 43 49 
 i 101 6 2 0.99 27 26 43 49 
 i 101 8 5 0.99 27 26 43 49 
 i 101 13 4 0.99 26 27 43 49 
 i 101 17 3 0.99 26 27 43 49 
 i 101 20 1 0.99 27 26 43 49 
 i 101 21 6 0.99 27 26 43 49 
 i 101 27 2 0.99 26 27 43 49 
 i 101 29 5 0.99 26 27 43 49 
 i 101 34 4 0.99 27 26 43 49 
 i 101 38 3 0.99 27 26 43 49 
 i 101 41 1 0.99 26 27 43 49 
 i 101 42 6 0.99 26 27 43 49 
 i 101 48 2 0.99 27 26 43 49 
 i 101 50 5 0.99 27 26 43 49 
 i 101 55 4 0.99 26 27 43 49 
 i 101 59 3 0.99 26 27 43 49 
 i 101 62 1 0.99 27 26 43 49 
 i 101 63 6 0.99 27 26 43 49 
 i 101 69 2 0.99 26 27 43 49 
 i 101 71 5 0.99 26 27 43 49 
 i 101 76 4 0.99 27 26 43 49 
 i 101 80 3 0.99 27 26 43 49 
 i 101 83 1 0.99 26 27 43 49 
 i 101 84 6 0.99 26 27 43 49 
 i 101 90 2 0.99 27 26 43 49 
 i 101 92 5 0.99 27 26 43 49 
 i 101 97 4 0.99 26 27 43 49 
 i 101 101 3 0.99 26 27 43 49 
 i 101 104 1 0.99 27 26 43 49 
 i 101 105 6 0.99 27 26 43 49 
 i 101 111 2 0.99 26 27 43 49 
 i 101 113 5 0.99 26 27 43 49 
 i 101 118 4 0.99 27 26 43 49 
 i 101 122 3 0.99 27 26 43 49 
 i 101 125 1 0.99 26 27 43 49 
 i 101 126 6 0.99 26 27 43 49 
 i 101 132 2 0.99 27 26 43 49 
 i 101 134 5 0.99 27 26 43 49 
 i 101 139 4 0.99 26 27 43 49 
 i 101 143 3 0.99 26 27 43 49 
 i 101 146 1 0.99 27 26 43 49 
 i 101 147 6 0.99 27 26 43 49 
 i 101 153 2 0.99 26 27 43 49 
 i 101 155 5 0.99 26 27 43 49 
 i 101 160 4 0.99 27 26 43 49 
 i 101 164 3 0.99 27 26 43 49 
 i 101 167 1 0.99 26 27 43 49 
 i 101 168 6 0.99 26 27 43 49 
 i 101 174 2 0.99 27 26 43 49 
 i 101 176 5 0.99 27 26 43 49 
 i 101 181 4 0.99 26 27 43 49 
 i 101 185 3 0.99 26 27 43 49 
 i 101 188 1 0.99 27 26 43 49 
 i 101 189 6 0.99 27 26 43 49 
 i 101 195 2 0.99 26 27 43 49 
 i 101 197 5 0.99 26 27 43 49 
 i 101 202 4 0.99 27 26 43 49 
 i 101 206 3 0.99 27 26 43 49 
 i 101 209 1 0.99 26 27 43 49 
 i 101 210 1 0.99 26 27 43 49 
 i 101 0 6 0.99 27 26 44 50 
 i 101 6 2 0.99 27 26 44 50 
 i 101 8 5 0.99 27 26 44 50 
 i 101 13 4 0.99 26 27 44 50 
 i 101 17 3 0.99 27 26 44 50 
 i 101 20 1 0.99 26 27 44 50 
 i 101 21 6 0.99 27 26 44 50 
 i 101 27 2 0.99 26 27 44 50 
 i 101 29 5 0.99 27 26 44 50 
 i 101 34 4 0.99 27 26 44 50 
 i 101 38 3 0.99 27 26 44 50 
 i 101 41 1 0.99 27 26 44 50 
 i 101 42 6 0.99 26 27 44 50 
 i 101 48 2 0.99 27 26 44 50 
 i 101 50 5 0.99 26 27 44 50 
 i 101 55 4 0.99 27 26 44 50 
 i 101 59 3 0.99 26 27 44 50 
 i 101 62 1 0.99 27 26 44 50 
 i 101 63 6 0.99 27 26 44 50 
 i 101 69 2 0.99 27 26 44 50 
 i 101 71 5 0.99 27 26 44 50 
 i 101 76 4 0.99 26 27 44 50 
 i 101 80 3 0.99 27 26 44 50 
 i 101 83 1 0.99 26 27 44 50 
 i 101 84 6 0.99 27 26 44 50 
 i 101 90 2 0.99 26 27 44 50 
 i 101 92 5 0.99 27 26 44 50 
 i 101 97 4 0.99 27 26 44 50 
 i 101 101 3 0.99 27 26 44 50 
 i 101 104 1 0.99 27 26 44 50 
 i 101 105 6 0.99 26 27 44 50 
 i 101 111 2 0.99 27 26 44 50 
 i 101 113 5 0.99 26 27 44 50 
 i 101 118 4 0.99 27 26 44 50 
 i 101 122 3 0.99 26 27 44 50 
 i 101 125 1 0.99 27 26 44 50 
 i 101 126 6 0.99 27 26 44 50 
 i 101 132 2 0.99 27 26 44 50 
 i 101 134 5 0.99 27 26 44 50 
 i 101 139 4 0.99 26 27 44 50 
 i 101 143 3 0.99 27 26 44 50 
 i 101 146 1 0.99 26 27 44 50 
 i 101 147 6 0.99 27 26 44 50 
 i 101 153 2 0.99 26 27 44 50 
 i 101 155 5 0.99 27 26 44 50 
 i 101 160 4 0.99 27 26 44 50 
 i 101 164 3 0.99 27 26 44 50 
 i 101 167 1 0.99 27 26 44 50 
 i 101 168 6 0.99 26 27 44 50 
 i 101 174 2 0.99 27 26 44 50 
 i 101 176 5 0.99 26 27 44 50 
 i 101 181 4 0.99 27 26 44 50 
 i 101 185 3 0.99 26 27 44 50 
 i 101 188 1 0.99 27 26 44 50 
 i 101 189 6 0.99 27 26 44 50 
 i 101 195 2 0.99 27 26 44 50 
 i 101 197 5 0.99 27 26 44 50 
 i 101 202 4 0.99 26 27 44 50 
 i 101 206 3 0.99 27 26 44 50 
 i 101 209 1 0.99 26 27 44 50 
 i 101 210 1 0.99 27 26 44 50 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR2	   49  	50  0.95  80

;cb
 i 12 0 17 81 5.017921908 0.0 1 51 52 
 i 12 17 22 81 5.49185309633 0.0 1 51 52 
 i 12 39 12 81 5.39231742278 0.0 1 51 52 
 i 12 51 17 81 5.33985000288 0.0 1 51 52 
 i 12 68 22 81 5.16992500144 0.0 1 51 52 
 i 12 90 12 81 5.33985000288 0.0 1 51 52 
 i 12 102 17 81 5.65535182861 0.0 1 51 52 
 i 12 119 22 81 5.49185309633 0.0 1 51 52 
 i 12 141 12 81 5.43295940728 0.0 1 51 52 
 i 12 153 17 81 5.39231742278 0.0 1 51 52 
 i 12 170 22 81 5.43295940728 0.0 1 51 52 
 i 12 192 22 81 5.84799690655 0.0 1 51 52 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR2	   51  	52  0.65 	 80

;tremolo
 i 387 0 212 1 7 11 201 1 45 53 
 i 387 0 212 1 5 11 201 1 46 54 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR2	   53  	54  0.0 	 80

;ensemble
 i 388 0 212 0.42 53 55 56 
 i 388 0 212 0.42 54 55 56 
 i 388 0 212 0.42 51 57 58 
 i 388 0 212 0.42 52 57 58 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR2	   55  	56  0.233  94 ;input from tremolo z53 z54
$MIXDUR2	   57  	58  0.246  94 ;input from ocb z51 z52

;phaseverb
 i 389 0 222 1 0.37 0.95 150 0.18 0.67 0.87 47 48 59 60 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDUR2	   59  	60  0.7  80 ;input from flute_b z47,z48

i910 0   $DUR2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;2ND TRANSITION
;;;;;;;;;;;;

b 480 ;

f 95 0 2049 -27 0 0 200 1.0 1024 1.0 ;segue fade in, then steady 

;strings
 i 386 0 20 75 7.79585928322 -1 4 61 62 
 i 386 0 20 75 7.38082178394 -0.5 4 61 62 
 i 386 0 20 75 6.64385618977 0.5 4 61 62 
 i 386 0 20 75 6.05889368905 1 4 61 62 

 i 386 20 4 75 7.79585928322 -1 4 63 64 
 i 386 24 6 75 7.79585928322 -1 4 63 64 
 i 386 30 4 75 7.64385618977 -1 4 63 64 
 i 386 34 6 75 7.64385618977 -1 4 63 64 
 i 386 40 4 75 7.47393118833 -1 4 63 64 
 i 386 44 6 75 7.70274987883 -1 4 63 64 
 i 386 50 4 75 7.70274987883 -1 4 63 64 
 i 386 54 6 75 7.53282487739 -1 4 63 64 
 i 386 60 4 75 7.53282487739 -1 4 63 64 
 i 386 64 6 75 7.38082178394 -1 4 63 64 
 i 386 70 4 75 7.64385618977 -1 4 63 64 
 i 386 74 6 75 7.64385618977 -1 4 63 64 
 i 386 80 4 75 7.47393118833 -1 4 63 64 
 i 386 84 6 75 7.47393118833 -1 4 63 64 
 i 386 90 8 77 7.2288186905 -1 4 63 64 

 i 386 20 4 75 7.38082178394 -0.5 4 63 64 
 i 386 24 6 75 7.2108967825 -0.5 4 63 64 
 i 386 30 4 75 7.2108967825 -0.5 4 63 64 
 i 386 34 6 75 7.2288186905 -0.5 4 63 64 
 i 386 40 4 75 7.2108967825 -0.5 4 63 64 
 i 386 44 6 75 7.38082178394 -0.5 4 63 64 
 i 386 50 4 75 7.2108967825 -0.5 4 63 64 
 i 386 54 6 75 7.2108967825 -0.5 4 63 64 
 i 386 60 4 75 7.2288186905 -0.5 4 63 64 
 i 386 64 6 75 7.2108967825 -0.5 4 63 64 
 i 386 70 4 75 7.38082178394 -0.5 4 63 64 
 i 386 74 6 75 7.2108967825 -0.5 4 63 64 
 i 386 80 4 75 7.2108967825 -0.5 4 63 64 
 i 386 84 6 75 7.2288186905 -0.5 4 63 64 
 i 386 90 8 77 7.2108967825 -0.5 4 63 64 

 i 386 20 4 75 6.64385618977 0.5 4 63 64 
 i 386 24 6 75 6.79585928322 0.5 4 63 64 
 i 386 30 4 75 6.64385618977 0.5 4 63 64 
 i 386 34 6 75 6.64385618977 0.5 4 63 64 
 i 386 40 4 75 6.88896868761 0.5 4 63 64 
 i 386 44 6 75 6.79585928322 0.5 4 63 64 
 i 386 50 4 75 6.96578428466 0.5 4 63 64 
 i 386 54 6 75 6.79585928322 0.5 4 63 64 
 i 386 60 4 75 6.79585928322 0.5 4 63 64 
 i 386 64 6 75 7.05889368905 0.5 4 63 64 
 i 386 70 4 75 6.96578428466 0.5 4 63 64 
 i 386 74 6 75 7.11778737811 0.5 4 63 64 
 i 386 80 4 75 6.96578428466 0.5 4 63 64 
 i 386 84 6 75 6.96578428466 0.5 4 63 64 
 i 386 90 8 77 7.2108967825 0.5 4 63 64 

 i 386 20 4 75 6.05889368905 1 4 63 64 
 i 386 24 6 75 6.47393118833 1 4 63 64 
 i 386 30 4 75 6.38082178394 1 4 63 64 
 i 386 34 6 75 6.64385618977 1 4 63 64 
 i 386 40 4 75 6.70274987883 1 4 63 64 
 i 386 44 6 75 6.2108967825 1 4 63 64 
 i 386 50 4 75 6.64385618977 1 4 63 64 
 i 386 54 6 75 6.53282487739 1 4 63 64 
 i 386 60 4 75 6.79585928322 1 4 63 64 
 i 386 64 6 75 6.88896868761 1 4 63 64 
 i 386 70 4 75 6.38082178394 1 4 63 64 
 i 386 74 6 75 6.79585928322 1 4 63 64 
 i 386 80 4 75 6.70274987883 1 4 63 64 
 i 386 84 6 75 6.96578428466 1 4 63 64 
 i 386 90 8 77 7.05889368905 1 4 63 64 

 i 386 20 4 81 9.79585928322 -1 0 63 64 
 i 386 24 6 81 9.79585928322 -1 0 63 64 
 i 386 30 4 81 9.64385618977 -1 0 63 64 
 i 386 34 6 81 9.64385618977 -1 0 63 64 
 i 386 40 4 81 9.47393118833 -1 0 63 64 
 i 386 44 6 81 9.70274987883 -1 0 63 64 
 i 386 50 4 81 9.70274987883 -1 0 63 64 
 i 386 54 6 81 9.53282487739 -1 0 63 64 
 i 386 60 4 81 9.53282487739 -1 0 63 64 
 i 386 64 6 81 9.38082178394 -1 0 63 64 
 i 386 70 4 81 9.64385618977 -1 0 63 64 
 i 386 74 6 81 9.64385618977 -1 0 63 64 
 i 386 80 4 81 9.47393118833 -1 0 63 64 
 i 386 84 6 81 9.47393118833 -1 0 63 64 
 i 386 90 8 84 9.2288186905 -1 3 63 64 

 i 386 20 4 81 9.38082178394 -0.5 0 63 64 
 i 386 24 6 81 9.2108967825 -0.5 0 63 64 
 i 386 30 4 81 9.2108967825 -0.5 0 63 64 
 i 386 34 6 81 9.2288186905 -0.5 0 63 64 
 i 386 40 4 81 9.2108967825 -0.5 0 63 64 
 i 386 44 6 81 9.38082178394 -0.5 0 63 64 
 i 386 50 4 81 9.2108967825 -0.5 0 63 64 
 i 386 54 6 81 9.2108967825 -0.5 0 63 64 
 i 386 60 4 81 9.2288186905 -0.5 0 63 64 
 i 386 64 6 81 9.2108967825 -0.5 0 63 64 
 i 386 70 4 81 9.38082178394 -0.5 0 63 64 
 i 386 74 6 81 9.2108967825 -0.5 0 63 64 
 i 386 80 4 81 9.2108967825 -0.5 0 63 64 
 i 386 84 6 81 9.2288186905 -0.5 0 63 64 
 i 386 90 8 84 9.2108967825 -0.5 3 63 64 

 i 386 20 4 81 8.64385618977 0.5 0 63 64 
 i 386 24 6 81 8.79585928322 0.5 0 63 64 
 i 386 30 4 81 8.64385618977 0.5 0 63 64 
 i 386 34 6 81 8.64385618977 0.5 0 63 64 
 i 386 40 4 81 8.88896868761 0.5 0 63 64 
 i 386 44 6 81 8.79585928322 0.5 0 63 64 
 i 386 50 4 81 8.96578428466 0.5 0 63 64 
 i 386 54 6 81 8.79585928322 0.5 0 63 64 
 i 386 60 4 81 8.79585928322 0.5 0 63 64 
 i 386 64 6 81 9.05889368905 0.5 0 63 64 
 i 386 70 4 81 8.96578428466 0.5 0 63 64 
 i 386 74 6 81 9.11778737811 0.5 0 63 64 
 i 386 80 4 81 8.96578428466 0.5 0 63 64 
 i 386 84 6 81 8.96578428466 0.5 0 63 64 
 i 386 90 8 84 9.2108967825 0.5 3 63 64 

 i 386 20 4 81 8.05889368905 1 0 63 64 
 i 386 24 6 81 8.47393118833 1 0 63 64 
 i 386 30 4 81 8.38082178394 1 0 63 64 
 i 386 34 6 81 8.64385618977 1 0 63 64 
 i 386 40 4 81 8.70274987883 1 0 63 64 
 i 386 44 6 81 8.2108967825 1 0 63 64 
 i 386 50 4 81 8.64385618977 1 0 63 64 
 i 386 54 6 81 8.53282487739 1 0 63 64 
 i 386 60 4 81 8.79585928322 1 0 63 64 
 i 386 64 6 81 8.88896868761 1 0 63 64 
 i 386 70 4 81 8.38082178394 1 0 63 64 
 i 386 74 6 81 8.79585928322 1 0 63 64 
 i 386 80 4 81 8.70274987883 1 0 63 64 
 i 386 84 6 81 8.96578428466 1 0 63 64 
 i 386 90 8 84 9.05889368905 1 3 63 64 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURT2	   61  	62  0.10  95 ; segue
$MIXDURT2	   63  	64  0.08  95 ; chord prog

;cbass
 i 12 20 4 81 5.05889368905 0.0 4 65 66 
 i 12 24 6 81 5.47393118833 0.0 4 65 66 
 i 12 30 4 81 5.38082178394 0.0 4 65 66 
 i 12 34 6 81 5.64385618977 0.0 4 65 66 
 i 12 40 4 81 5.70274987883 0.0 4 65 66 
 i 12 44 6 81 5.2108967825 0.0 4 65 66 
 i 12 50 4 81 5.64385618977 0.0 4 65 66 
 i 12 54 6 81 5.53282487739 0.0 4 65 66 
 i 12 60 4 81 5.79585928322 0.0 4 65 66 
 i 12 64 6 81 5.88896868761 0.0 4 65 66 
 i 12 70 4 81 5.38082178394 0.0 4 65 66 
 i 12 74 6 81 5.79585928322 0.0 4 65 66 
 i 12 80 4 81 5.70274987883 0.0 4 65 66 
 i 12 84 6 81 5.96578428466 0.0 4 65 66 
 i 12 90 4 81 6.05889368905 0.0 4 65 66 
 i 12 94 6 81 5.53282487739 0.0 4 65 66 
 i 12 100 6 81 5.96578428466 0.0 4 65 66 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURT2	   65  	66  0.65  80 ; cb

;tremolo
 i 387 0 110 1 11 11 201 1 63 67 
 i 387 0 110 1 11 11 201 1 64 68 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURT2	   67  	68  0.115  80 ; input is stringC chord prog z63 z64

;ensemble
 i 388 0 110 4.62 61 69 70 
 i 388 0 110 4.62 62 69 70 
 i 388 0 110 2.62 67 69 70 
 i 388 0 110 2.62 68 69 70 
 i 388 0 110 3.62 63 69 70 
 i 388 0 110 3.62 64 69 70 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURT2	   69  	70  0.125  95 ; input is T2tremolo z69 z70

i910 0   $DURT2 ;clear zaks

;----------------------------------------
;CODA
;----------------------------------------

b 577.5	; should segue half a second at end of transition 

f 96 0 2049 -27 0 1.0 1125 1.0 1126 0 1325 0 1328 1.0 2048 1.0 ;flute mixer envelope

;ostinato vibes
 i 18 0 6 12000 8.05889368905 1 2 
 i 18 0.5 6 12000 8.2108967825 1 2 
 i 18 2.5 6 12000 8.2108967825 1 2 
 i 18 3.0 6 12000 8.05889368905 1 2 
 i 18 5.0 6 12000 8.05889368905 1 2 
 i 18 5.5 6 12000 8.47393118833 1 2 
 i 18 7.5 6 12000 8.2108967825 1 2 
 i 18 8.0 6 12000 8.64385618977 1 2 
 i 18 10.0 6 12000 8.05889368905 1 2 
 i 18 10.5 6 12000 8.2108967825 1 2 
 i 18 12.5 6 12000 8.2108967825 1 2 
 i 18 13.0 6 12000 8.05889368905 1 2 
 i 18 15.0 6 12000 8.05889368905 1 2 
 i 18 15.5 6 12000 8.47393118833 1 2 
 i 18 17.5 6 12000 8.2108967825 1 2 
 i 18 18.0 6 12000 8.64385618977 1 2 
 i 18 20.0 6 12000 8.05889368905 1 2 
 i 18 20.5 6 12000 8.2108967825 1 2 
 i 18 22.5 6 12000 8.2108967825 1 2 
 i 18 23.0 6 12000 8.05889368905 1 2 
 i 18 25.0 6 12000 8.05889368905 1 2 
 i 18 25.5 6 12000 8.47393118833 1 2 
 i 18 27.5 6 12000 8.2108967825 1 2 
 i 18 28.0 6 12000 8.64385618977 1 2 
 i 18 30.0 6 12000 8.05889368905 1 2 
 i 18 30.5 6 12000 8.2108967825 1 2 
 i 18 32.5 6 12000 8.2108967825 1 2 
 i 18 33.0 6 12000 8.05889368905 1 2 
 i 18 35.0 6 12000 8.05889368905 1 2 
 i 18 35.5 6 12000 8.47393118833 1 2 
 i 18 37.5 6 12000 8.2108967825 1 2 
 i 18 38.0 6 12000 8.64385618977 1 2 
 i 18 40.0 6 12000 8.05889368905 1 2 
 i 18 40.5 6 12000 8.2108967825 1 2 
 i 18 42.5 6 12000 8.2108967825 1 2 
 i 18 43.0 6 12000 8.05889368905 1 2 
 i 18 45.0 6 12000 8.05889368905 1 2 
 i 18 45.5 6 12000 8.47393118833 1 2 
 i 18 47.5 6 12000 8.2108967825 1 2 
 i 18 48.0 6 12000 8.64385618977 1 2 
 i 18 50.0 6 12000 8.05889368905 1 2 
 i 18 50.5 6 12000 8.2108967825 1 2 
 i 18 52.5 6 12000 8.2108967825 1 2 
 i 18 53.0 6 12000 8.05889368905 1 2 
 i 18 55.0 6 12000 8.05889368905 1 2 
 i 18 55.5 6 12000 8.47393118833 1 2 
 i 18 57.5 6 12000 8.2108967825 1 2 
 i 18 58.0 6 12000 8.64385618977 1 2 
 i 18 60.0 6 12000 8.05889368905 1 2 
 i 18 60.5 6 12000 8.2108967825 1 2 
 i 18 62.5 6 12000 8.2108967825 1 2 
 i 18 63.0 6 12000 8.05889368905 1 2 
 i 18 65.0 6 12000 8.05889368905 1 2 
 i 18 65.5 6 12000 8.47393118833 1 2 
 i 18 67.5 6 12000 8.2108967825 1 2 
 i 18 68.0 6 12000 8.64385618977 1 2 
 i 18 70.0 6 12000 8.05889368905 1 2 
 i 18 70.5 6 12000 8.2108967825 1 2 
 i 18 72.5 6 12000 8.2108967825 1 2 
 i 18 73.0 6 12000 8.05889368905 1 2 
 i 18 75.0 6 12000 8.05889368905 1 2 
 i 18 75.5 6 12000 8.47393118833 1 2 
 i 18 77.5 6 12000 8.2108967825 1 2 
 i 18 78.0 6 12000 8.64385618977 1 2 
 i 18 80.0 6 12000 8.05889368905 1 2 
 i 18 80.5 6 12000 8.2108967825 1 2 
 i 18 82.5 6 12000 8.2108967825 1 2 
 i 18 83.0 6 12000 8.05889368905 1 2 
 i 18 85.0 6 12000 8.05889368905 1 2 
 i 18 85.5 6 12000 8.47393118833 1 2 
 i 18 87.5 6 12000 8.2108967825 1 2 
 i 18 88.0 6 12000 8.64385618977 1 2 
 i 18 90.0 6 12000 8.05889368905 1 2 
 i 18 90.5 6 12000 8.2108967825 1 2 
 i 18 92.5 6 12000 8.2108967825 1 2 
 i 18 93.0 6 12000 8.05889368905 1 2 
 i 18 95.0 6 12000 8.05889368905 1 2 
 i 18 95.5 6 12000 8.47393118833 1 2 
 i 18 97.5 6 12000 8.2108967825 1 2 
 i 18 98.0 6 12000 8.64385618977 1 2 
 i 18 100.0 6 12000 8.05889368905 1 2 
 i 18 100.5 6 12000 8.2108967825 1 2 
 i 18 102.5 6 12000 8.2108967825 1 2 
 i 18 103.0 6 12000 8.05889368905 1 2 
 i 18 105.0 6 12000 8.05889368905 1 2 
 i 18 105.5 6 12000 8.47393118833 1 2 
 i 18 107.5 6 12000 8.2108967825 1 2 
 i 18 108.0 6 12000 8.64385618977 1 2 
 i 18 110.0 6 12000 8.05889368905 1 2 
 i 18 110.5 6 12000 8.2108967825 1 2 
 i 18 112.5 6 12000 8.2108967825 1 2 
 i 18 113.0 6 12000 8.05889368905 1 2 
 i 18 115.0 6 12000 8.05889368905 1 2 
 i 18 115.5 6 12000 8.47393118833 1 2 
 i 18 117.5 6 12000 8.2108967825 1 2 
 i 18 118.0 6 12000 8.64385618977 1 2 
 i 18 120.0 6 12000 8.05889368905 1 2 
 i 18 120.5 6 12000 8.2108967825 1 2 
 i 18 122.5 6 12000 8.2108967825 1 2 
 i 18 123.0 6 12000 8.05889368905 1 2 
 i 18 125.0 6 12000 8.05889368905 1 2 
 i 18 125.5 6 12000 8.47393118833 1 2 
 i 18 127.5 6 12000 8.2108967825 1 2 
 i 18 128.0 6 12000 8.64385618977 1 2 
 i 18 130.0 6 12000 8.05889368905 1 2 
 i 18 130.5 6 12000 8.2108967825 1 2 
 i 18 132.5 6 12000 8.2108967825 1 2 
 i 18 133.0 6 12000 8.05889368905 1 2 
 i 18 135.0 6 12000 8.05889368905 1 2 
 i 18 135.5 6 12000 8.47393118833 1 2 
 i 18 137.5 6 12000 8.2108967825 1 2 
 i 18 138.0 6 12000 8.64385618977 1 2 
 i 18 140.0 6 12000 8.05889368905 1 2 
 i 18 140.5 6 12000 8.2108967825 1 2 
 i 18 142.5 6 12000 8.2108967825 1 2 
 i 18 143.0 6 12000 8.05889368905 1 2 
 i 18 145.0 6 12000 8.05889368905 1 2 
 i 18 145.5 6 12000 8.47393118833 1 2 
 i 18 147.5 6 12000 8.2108967825 1 2 
 i 18 148.0 6 12000 8.64385618977 1 2 
 i 18 150.0 6 12000 8.05889368905 1 2 
 i 18 150.5 6 12000 8.2108967825 1 2 
 i 18 152.5 6 12000 8.2108967825 1 2 
 i 18 153.0 6 12000 8.05889368905 1 2 
 i 18 155.0 6 12000 8.05889368905 1 2 
 i 18 155.5 6 12000 8.47393118833 1 2 
 i 18 157.5 6 12000 8.2108967825 1 2 
 i 18 158.0 6 12000 8.64385618977 1 2 
 i 18 160.0 6 12000 8.05889368905 1 2 
 i 18 160.5 6 12000 8.2108967825 1 2 
 i 18 162.5 6 12000 8.2108967825 1 2 
 i 18 163.0 6 12000 8.05889368905 1 2 
 i 18 165.0 6 12000 8.05889368905 1 2 
 i 18 165.5 6 12000 8.47393118833 1 2 
 i 18 167.5 6 12000 8.2108967825 1 2 
 i 18 168.0 6 12000 8.64385618977 1 2 
 i 18 170.0 6 12000 8.05889368905 1 2 
 i 18 170.5 6 12000 8.2108967825 1 2 
 i 18 172.5 6 12000 8.2108967825 1 2 
 i 18 173.0 6 12000 8.05889368905 1 2 
 i 18 175.0 6 12000 8.05889368905 1 2 
 i 18 175.5 6 12000 8.47393118833 1 2 
 i 18 177.5 6 12000 8.2108967825 1 2 
 i 18 178.0 6 12000 8.64385618977 1 2 
 i 18 180.0 6 12000 8.05889368905 1 2 
 i 18 0 6 6450 8.05889368905 1 2 
 i 18 0.5 6 6450 8.2108967825 1 2 
 i 18 0.75 6 6450 8.05889368905 1 2 
 i 18 1.25 6 6450 8.2108967825 1 2 
 i 18 1.5 6 6450 8.05889368905 1 2 
 i 18 3.0 6 6450 8.2108967825 1 2 
 i 18 3.5 6 6450 8.05889368905 1 2 
 i 18 3.75 6 6450 8.2108967825 1 2 
 i 18 4.25 6 6450 8.05889368905 1 2 
 i 18 4.5 6 6450 8.2108967825 1 2 
 i 18 6.0 6 6450 8.05889368905 1 2 
 i 18 6.5 6 6450 8.2108967825 1 2 
 i 18 6.75 6 6450 8.05889368905 1 2 
 i 18 7.25 6 6450 8.2108967825 1 2 
 i 18 7.5 6 6450 8.05889368905 1 2 
 i 18 9.0 6 6450 8.2108967825 1 2 
 i 18 9.5 6 6450 8.05889368905 1 2 
 i 18 9.75 6 6450 8.2108967825 1 2 
 i 18 10.25 6 6450 8.05889368905 1 2 
 i 18 10.5 6 6450 8.2108967825 1 2 
 i 18 12.0 6 6450 8.05889368905 1 2 
 i 18 12.5 6 6450 8.2108967825 1 2 
 i 18 12.75 6 6450 8.05889368905 1 2 
 i 18 13.25 6 6450 8.2108967825 1 2 
 i 18 13.5 6 6450 8.05889368905 1 2 
 i 18 15.0 6 6450 8.2108967825 1 2 
 i 18 15.5 6 6450 8.05889368905 1 2 
 i 18 15.75 6 6450 8.2108967825 1 2 
 i 18 16.25 6 6450 8.05889368905 1 2 
 i 18 16.5 6 6450 8.2108967825 1 2 
 i 18 18.0 6 6450 8.05889368905 1 2 
 i 18 18.5 6 6450 8.2108967825 1 2 
 i 18 18.75 6 6450 8.05889368905 1 2 
 i 18 19.25 6 6450 8.2108967825 1 2 
 i 18 19.5 6 6450 8.05889368905 1 2 
 i 18 21.0 6 6450 8.2108967825 1 2 
 i 18 21.5 6 6450 8.05889368905 1 2 
 i 18 21.75 6 6450 8.2108967825 1 2 
 i 18 22.25 6 6450 8.05889368905 1 2 
 i 18 22.5 6 6450 8.2108967825 1 2 
 i 18 24.0 6 6450 8.05889368905 1 2 
 i 18 24.5 6 6450 8.2108967825 1 2 
 i 18 24.75 6 6450 8.05889368905 1 2 
 i 18 25.25 6 6450 8.2108967825 1 2 
 i 18 25.5 6 6450 8.05889368905 1 2 
 i 18 27.0 6 6450 8.2108967825 1 2 
 i 18 27.5 6 6450 8.05889368905 1 2 
 i 18 27.75 6 6450 8.2108967825 1 2 
 i 18 28.25 6 6450 8.05889368905 1 2 
 i 18 28.5 6 6450 8.2108967825 1 2 
 i 18 30.0 6 6450 8.05889368905 1 2 
 i 18 30.5 6 6450 8.2108967825 1 2 
 i 18 30.75 6 6450 8.05889368905 1 2 
 i 18 31.25 6 6450 8.2108967825 1 2 
 i 18 31.5 6 6450 8.05889368905 1 2 
 i 18 33.0 6 6450 8.2108967825 1 2 
 i 18 33.5 6 6450 8.05889368905 1 2 
 i 18 33.75 6 6450 8.2108967825 1 2 
 i 18 34.25 6 6450 8.05889368905 1 2 
 i 18 34.5 6 6450 8.2108967825 1 2 
 i 18 36.0 6 6450 8.05889368905 1 2 
 i 18 36.5 6 6450 8.2108967825 1 2 
 i 18 36.75 6 6450 8.05889368905 1 2 
 i 18 37.25 6 6450 8.2108967825 1 2 
 i 18 37.5 6 6450 8.05889368905 1 2 
 i 18 39.0 6 6450 8.2108967825 1 2 
 i 18 39.5 6 6450 8.05889368905 1 2 
 i 18 39.75 6 6450 8.2108967825 1 2 
 i 18 40.25 6 6450 8.05889368905 1 2 
 i 18 40.5 6 6450 8.2108967825 1 2 
 i 18 42.0 6 6450 8.05889368905 1 2 
 i 18 42.5 6 6450 8.2108967825 1 2 
 i 18 42.75 6 6450 8.05889368905 1 2 
 i 18 43.25 6 6450 8.2108967825 1 2 
 i 18 43.5 6 6450 8.05889368905 1 2 
 i 18 45.0 6 6450 8.2108967825 1 2 
 i 18 45.5 6 6450 8.05889368905 1 2 
 i 18 45.75 6 6450 8.2108967825 1 2 
 i 18 46.25 6 6450 8.05889368905 1 2 
 i 18 46.5 6 6450 8.2108967825 1 2 
 i 18 48.0 6 6450 8.05889368905 1 2 
 i 18 48.5 6 6450 8.2108967825 1 2 
 i 18 48.75 6 6450 8.05889368905 1 2 
 i 18 49.25 6 6450 8.2108967825 1 2 
 i 18 49.5 6 6450 8.05889368905 1 2 
 i 18 51.0 6 6450 8.2108967825 1 2 
 i 18 51.5 6 6450 8.05889368905 1 2 
 i 18 51.75 6 6450 8.2108967825 1 2 
 i 18 52.25 6 6450 8.05889368905 1 2 
 i 18 52.5 6 6450 8.2108967825 1 2 
 i 18 54.0 6 6450 8.05889368905 1 2 
 i 18 54.5 6 6450 8.2108967825 1 2 
 i 18 54.75 6 6450 8.05889368905 1 2 
 i 18 55.25 6 6450 8.2108967825 1 2 
 i 18 55.5 6 6450 8.05889368905 1 2 
 i 18 57.0 6 6450 8.2108967825 1 2 
 i 18 57.5 6 6450 8.05889368905 1 2 
 i 18 57.75 6 6450 8.2108967825 1 2 
 i 18 58.25 6 6450 8.05889368905 1 2 
 i 18 58.5 6 6450 8.2108967825 1 2 
 i 18 60.0 6 6450 8.05889368905 1 2 
 i 18 60.5 6 6450 8.2108967825 1 2 
 i 18 60.75 6 6450 8.05889368905 1 2 
 i 18 61.25 6 6450 8.2108967825 1 2 
 i 18 61.5 6 6450 8.05889368905 1 2 
 i 18 63.0 6 6450 8.2108967825 1 2 
 i 18 63.5 6 6450 8.05889368905 1 2 
 i 18 63.75 6 6450 8.2108967825 1 2 
 i 18 64.25 6 6450 8.05889368905 1 2 
 i 18 64.5 6 6450 8.2108967825 1 2 
 i 18 66.0 6 6450 8.05889368905 1 2 
 i 18 66.5 6 6450 8.2108967825 1 2 
 i 18 66.75 6 6450 8.05889368905 1 2 
 i 18 67.25 6 6450 8.2108967825 1 2 
 i 18 67.5 6 6450 8.05889368905 1 2 
 i 18 69.0 6 6450 8.2108967825 1 2 
 i 18 69.5 6 6450 8.05889368905 1 2 
 i 18 69.75 6 6450 8.2108967825 1 2 
 i 18 70.25 6 6450 8.05889368905 1 2 
 i 18 70.5 6 6450 8.2108967825 1 2 
 i 18 72.0 6 6450 8.05889368905 1 2 
 i 18 72.5 6 6450 8.2108967825 1 2 
 i 18 72.75 6 6450 8.05889368905 1 2 
 i 18 73.25 6 6450 8.2108967825 1 2 
 i 18 73.5 6 6450 8.05889368905 1 2 
 i 18 75.0 6 6450 8.2108967825 1 2 
 i 18 75.5 6 6450 8.05889368905 1 2 
 i 18 75.75 6 6450 8.2108967825 1 2 
 i 18 76.25 6 6450 8.05889368905 1 2 
 i 18 76.5 6 6450 8.2108967825 1 2 
 i 18 78.0 6 6450 8.05889368905 1 2 
 i 18 78.5 6 6450 8.2108967825 1 2 
 i 18 78.75 6 6450 8.05889368905 1 2 
 i 18 79.25 6 6450 8.2108967825 1 2 
 i 18 79.5 6 6450 8.05889368905 1 2 
 i 18 81.0 6 6450 8.2108967825 1 2 
 i 18 81.5 6 6450 8.05889368905 1 2 
 i 18 81.75 6 6450 8.2108967825 1 2 
 i 18 82.25 6 6450 8.05889368905 1 2 
 i 18 82.5 6 6450 8.2108967825 1 2 
 i 18 84.0 6 6450 8.05889368905 1 2 
 i 18 84.5 6 6450 8.2108967825 1 2 
 i 18 84.75 6 6450 8.05889368905 1 2 
 i 18 85.25 6 6450 8.2108967825 1 2 
 i 18 85.5 6 6450 8.05889368905 1 2 
 i 18 87.0 6 6450 8.2108967825 1 2 
 i 18 87.5 6 6450 8.05889368905 1 2 
 i 18 87.75 6 6450 8.2108967825 1 2 
 i 18 88.25 6 6450 8.05889368905 1 2 
 i 18 88.5 6 6450 8.2108967825 1 2 
 i 18 90.0 6 6450 8.05889368905 1 2 
 i 18 90.5 6 6450 8.2108967825 1 2 
 i 18 90.75 6 6450 8.05889368905 1 2 
 i 18 91.25 6 6450 8.2108967825 1 2 
 i 18 91.5 6 6450 8.05889368905 1 2 
 i 18 93.0 6 6450 8.2108967825 1 2 
 i 18 93.5 6 6450 8.05889368905 1 2 
 i 18 93.75 6 6450 8.2108967825 1 2 
 i 18 94.25 6 6450 8.05889368905 1 2 
 i 18 94.5 6 6450 8.2108967825 1 2 
 i 18 96.0 6 6450 8.05889368905 1 2 
 i 18 96.5 6 6450 8.2108967825 1 2 
 i 18 96.75 6 6450 8.05889368905 1 2 
 i 18 97.25 6 6450 8.2108967825 1 2 
 i 18 97.5 6 6450 8.05889368905 1 2 
 i 18 99.0 6 6450 8.2108967825 1 2 
 i 18 99.5 6 6450 8.05889368905 1 2 
 i 18 99.75 6 6450 8.2108967825 1 2 
 i 18 100.25 6 6450 8.05889368905 1 2 
 i 18 100.5 6 6450 8.2108967825 1 2 
 i 18 102.0 6 6450 8.05889368905 1 2 
 i 18 102.5 6 6450 8.2108967825 1 2 
 i 18 102.75 6 6450 8.05889368905 1 2 
 i 18 103.25 6 6450 8.2108967825 1 2 
 i 18 103.5 6 6450 8.05889368905 1 2 
 i 18 105.0 6 6450 8.2108967825 1 2 
 i 18 105.5 6 6450 8.05889368905 1 2 
 i 18 105.75 6 6450 8.2108967825 1 2 
 i 18 106.25 6 6450 8.05889368905 1 2 
 i 18 106.5 6 6450 8.2108967825 1 2 
 i 18 108.0 6 6450 8.05889368905 1 2 
 i 18 108.5 6 6450 8.2108967825 1 2 
 i 18 108.75 6 6450 8.05889368905 1 2 
 i 18 109.25 6 6450 8.2108967825 1 2 
 i 18 109.5 6 6450 8.05889368905 1 2 
 i 18 111.0 6 6450 8.2108967825 1 2 
 i 18 111.5 6 6450 8.05889368905 1 2 
 i 18 111.75 6 6450 8.2108967825 1 2 
 i 18 112.25 6 6450 8.05889368905 1 2 
 i 18 112.5 6 6450 8.2108967825 1 2 
 i 18 114.0 6 6450 8.05889368905 1 2 
 i 18 114.5 6 6450 8.2108967825 1 2 
 i 18 114.75 6 6450 8.05889368905 1 2 
 i 18 115.25 6 6450 8.2108967825 1 2 
 i 18 115.5 6 6450 8.05889368905 1 2 
 i 18 117.0 6 6450 8.2108967825 1 2 
 i 18 117.5 6 6450 8.05889368905 1 2 
 i 18 117.75 6 6450 8.2108967825 1 2 
 i 18 118.25 6 6450 8.05889368905 1 2 
 i 18 118.5 6 6450 8.2108967825 1 2 
 i 18 120.0 6 6450 8.05889368905 1 2 
 i 18 120.5 6 6450 8.2108967825 1 2 
 i 18 120.75 6 6450 8.05889368905 1 2 
 i 18 121.25 6 6450 8.2108967825 1 2 
 i 18 121.5 6 6450 8.05889368905 1 2 
 i 18 123.0 6 6450 8.2108967825 1 2 
 i 18 123.5 6 6450 8.05889368905 1 2 
 i 18 123.75 6 6450 8.2108967825 1 2 
 i 18 124.25 6 6450 8.05889368905 1 2 
 i 18 124.5 6 6450 8.2108967825 1 2 
 i 18 126.0 6 6450 8.05889368905 1 2 
 i 18 126.5 6 6450 8.2108967825 1 2 
 i 18 126.75 6 6450 8.05889368905 1 2 
 i 18 127.25 6 6450 8.2108967825 1 2 
 i 18 127.5 6 6450 8.05889368905 1 2 
 i 18 129.0 6 6450 8.2108967825 1 2 
 i 18 129.5 6 6450 8.05889368905 1 2 
 i 18 129.75 6 6450 8.2108967825 1 2 
 i 18 130.25 6 6450 8.05889368905 1 2 
 i 18 130.5 6 6450 8.2108967825 1 2 
 i 18 132.0 6 6450 8.05889368905 1 2 
 i 18 132.5 6 6450 8.2108967825 1 2 
 i 18 132.75 6 6450 8.05889368905 1 2 
 i 18 133.25 6 6450 8.2108967825 1 2 
 i 18 133.5 6 6450 8.05889368905 1 2 
 i 18 135.0 6 6450 8.2108967825 1 2 
 i 18 135.5 6 6450 8.05889368905 1 2 
 i 18 135.75 6 6450 8.2108967825 1 2 
 i 18 136.25 6 6450 8.05889368905 1 2 
 i 18 136.5 6 6450 8.2108967825 1 2 
 i 18 138.0 6 6450 8.05889368905 1 2 
 i 18 138.5 6 6450 8.2108967825 1 2 
 i 18 138.75 6 6450 8.05889368905 1 2 
 i 18 139.25 6 6450 8.2108967825 1 2 
 i 18 139.5 6 6450 8.05889368905 1 2 
 i 18 141.0 6 6450 8.2108967825 1 2 
 i 18 141.5 6 6450 8.05889368905 1 2 
 i 18 141.75 6 6450 8.2108967825 1 2 
 i 18 142.25 6 6450 8.05889368905 1 2 
 i 18 142.5 6 6450 8.2108967825 1 2 
 i 18 144.0 6 6450 8.05889368905 1 2 
 i 18 144.5 6 6450 8.2108967825 1 2 
 i 18 144.75 6 6450 8.05889368905 1 2 
 i 18 145.25 6 6450 8.2108967825 1 2 
 i 18 145.5 6 6450 8.05889368905 1 2 
 i 18 147.0 6 6450 8.2108967825 1 2 
 i 18 147.5 6 6450 8.05889368905 1 2 
 i 18 147.75 6 6450 8.2108967825 1 2 
 i 18 148.25 6 6450 8.05889368905 1 2 
 i 18 148.5 6 6450 8.2108967825 1 2 
 i 18 150.0 6 6450 8.05889368905 1 2 
 i 18 150.5 6 6450 8.2108967825 1 2 
 i 18 150.75 6 6450 8.05889368905 1 2 
 i 18 151.25 6 6450 8.2108967825 1 2 
 i 18 151.5 6 6450 8.05889368905 1 2 
 i 18 153.0 6 6450 8.2108967825 1 2 
 i 18 153.5 6 6450 8.05889368905 1 2 
 i 18 153.75 6 6450 8.2108967825 1 2 
 i 18 154.25 6 6450 8.05889368905 1 2 
 i 18 154.5 6 6450 8.2108967825 1 2 
 i 18 156.0 6 6450 8.05889368905 1 2 
 i 18 156.5 6 6450 8.2108967825 1 2 
 i 18 156.75 6 6450 8.05889368905 1 2 
 i 18 157.25 6 6450 8.2108967825 1 2 
 i 18 157.5 6 6450 8.05889368905 1 2 
 i 18 159.0 6 6450 8.2108967825 1 2 
 i 18 159.5 6 6450 8.05889368905 1 2 
 i 18 159.75 6 6450 8.2108967825 1 2 
 i 18 160.25 6 6450 8.05889368905 1 2 
 i 18 160.5 6 6450 8.2108967825 1 2 
 i 18 162.0 6 6450 8.05889368905 1 2 
 i 18 162.5 6 6450 8.2108967825 1 2 
 i 18 162.75 6 6450 8.05889368905 1 2 
 i 18 163.25 6 6450 8.2108967825 1 2 
 i 18 163.5 6 6450 8.05889368905 1 2 
 i 18 165.0 6 6450 8.2108967825 1 2 
 i 18 165.5 6 6450 8.05889368905 1 2 
 i 18 165.75 6 6450 8.2108967825 1 2 
 i 18 166.25 6 6450 8.05889368905 1 2 
 i 18 166.5 6 6450 8.2108967825 1 2 
 i 18 168.0 6 6450 8.05889368905 1 2 
 i 18 168.5 6 6450 8.2108967825 1 2 
 i 18 168.75 6 6450 8.05889368905 1 2 
 i 18 169.25 6 6450 8.2108967825 1 2 
 i 18 169.5 6 6450 8.05889368905 1 2 
 i 18 171.0 6 6450 8.2108967825 1 2 
 i 18 171.5 6 6450 8.05889368905 1 2 
 i 18 171.75 6 6450 8.2108967825 1 2 
 i 18 172.25 6 6450 8.05889368905 1 2 
 i 18 172.5 6 6450 8.2108967825 1 2 
 i 18 174.0 6 6450 8.05889368905 1 2 
 i 18 174.5 6 6450 8.2108967825 1 2 
 i 18 174.75 6 6450 8.05889368905 1 2 
 i 18 175.25 6 6450 8.2108967825 1 2 
 i 18 175.5 6 6450 8.05889368905 1 2 
 i 18 177.0 6 6450 8.2108967825 1 2 
 i 18 177.5 6 6450 8.05889368905 1 2 
 i 18 177.75 6 6450 8.2108967825 1 2 
 i 18 178.25 6 6450 8.05889368905 1 2 
 i 18 178.5 6 6450 8.2108967825 1 2 
 i 18 180.0 6 6450 8.05889368905 1 2 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURCODA	   1  	2  0.825  80 ; vibes

;ostinato dx7
 i 11 0 6 8.05889368905 127 -0.2 3 4 
 i 11 0.5 6 8.2108967825 127 -0.2 3 4 
 i 11 2.5 6 8.2108967825 127 -0.2 3 4 
 i 11 3.0 6 8.05889368905 127 -0.2 3 4 
 i 11 5.0 6 8.05889368905 127 -0.2 3 4 
 i 11 5.5 6 8.47393118833 127 -0.2 3 4 
 i 11 7.5 6 8.2108967825 127 -0.2 3 4 
 i 11 8.0 6 8.64385618977 127 -0.2 3 4 
 i 11 10.0 6 8.05889368905 127 -0.2 3 4 
 i 11 10.5 6 8.2108967825 127 -0.2 3 4 
 i 11 12.5 6 8.2108967825 127 -0.2 3 4 
 i 11 13.0 6 8.05889368905 127 -0.2 3 4 
 i 11 15.0 6 8.05889368905 127 -0.2 3 4 
 i 11 15.5 6 8.47393118833 127 -0.2 3 4 
 i 11 17.5 6 8.2108967825 127 -0.2 3 4 
 i 11 18.0 6 8.64385618977 127 -0.2 3 4 
 i 11 20.0 6 8.05889368905 127 -0.2 3 4 
 i 11 20.5 6 8.2108967825 127 -0.2 3 4 
 i 11 22.5 6 8.2108967825 127 -0.2 3 4 
 i 11 23.0 6 8.05889368905 127 -0.2 3 4 
 i 11 25.0 6 8.05889368905 127 -0.2 3 4 
 i 11 25.5 6 8.47393118833 127 -0.2 3 4 
 i 11 27.5 6 8.2108967825 127 -0.2 3 4 
 i 11 28.0 6 8.64385618977 127 -0.2 3 4 
 i 11 30.0 6 8.05889368905 127 -0.2 3 4 
 i 11 30.5 6 8.2108967825 127 -0.2 3 4 
 i 11 32.5 6 8.2108967825 127 -0.2 3 4 
 i 11 33.0 6 8.05889368905 127 -0.2 3 4 
 i 11 35.0 6 8.05889368905 127 -0.2 3 4 
 i 11 35.5 6 8.47393118833 127 -0.2 3 4 
 i 11 37.5 6 8.2108967825 127 -0.2 3 4 
 i 11 38.0 6 8.64385618977 127 -0.2 3 4 
 i 11 40.0 6 8.05889368905 127 -0.2 3 4 
 i 11 40.5 6 8.2108967825 127 -0.2 3 4 
 i 11 42.5 6 8.2108967825 127 -0.2 3 4 
 i 11 43.0 6 8.05889368905 127 -0.2 3 4 
 i 11 45.0 6 8.05889368905 127 -0.2 3 4 
 i 11 45.5 6 8.47393118833 127 -0.2 3 4 
 i 11 47.5 6 8.2108967825 127 -0.2 3 4 
 i 11 48.0 6 8.64385618977 127 -0.2 3 4 
 i 11 50.0 6 8.05889368905 127 -0.2 3 4 
 i 11 50.5 6 8.2108967825 127 -0.2 3 4 
 i 11 52.5 6 8.2108967825 127 -0.2 3 4 
 i 11 53.0 6 8.05889368905 127 -0.2 3 4 
 i 11 55.0 6 8.05889368905 127 -0.2 3 4 
 i 11 55.5 6 8.47393118833 127 -0.2 3 4 
 i 11 57.5 6 8.2108967825 127 -0.2 3 4 
 i 11 58.0 6 8.64385618977 127 -0.2 3 4 
 i 11 60.0 6 8.05889368905 127 -0.2 3 4 
 i 11 60.5 6 8.2108967825 127 -0.2 3 4 
 i 11 62.5 6 8.2108967825 127 -0.2 3 4 
 i 11 63.0 6 8.05889368905 127 -0.2 3 4 
 i 11 65.0 6 8.05889368905 127 -0.2 3 4 
 i 11 65.5 6 8.47393118833 127 -0.2 3 4 
 i 11 67.5 6 8.2108967825 127 -0.2 3 4 
 i 11 68.0 6 8.64385618977 127 -0.2 3 4 
 i 11 70.0 6 8.05889368905 127 -0.2 3 4 
 i 11 70.5 6 8.2108967825 127 -0.2 3 4 
 i 11 72.5 6 8.2108967825 127 -0.2 3 4 
 i 11 73.0 6 8.05889368905 127 -0.2 3 4 
 i 11 75.0 6 8.05889368905 127 -0.2 3 4 
 i 11 75.5 6 8.47393118833 127 -0.2 3 4 
 i 11 77.5 6 8.2108967825 127 -0.2 3 4 
 i 11 78.0 6 8.64385618977 127 -0.2 3 4 
 i 11 80.0 6 8.05889368905 127 -0.2 3 4 
 i 11 80.5 6 8.2108967825 127 -0.2 3 4 
 i 11 82.5 6 8.2108967825 127 -0.2 3 4 
 i 11 83.0 6 8.05889368905 127 -0.2 3 4 
 i 11 85.0 6 8.05889368905 127 -0.2 3 4 
 i 11 85.5 6 8.47393118833 127 -0.2 3 4 
 i 11 87.5 6 8.2108967825 127 -0.2 3 4 
 i 11 88.0 6 8.64385618977 127 -0.2 3 4 
 i 11 90.0 6 8.05889368905 127 -0.2 3 4 
 i 11 90.5 6 8.2108967825 127 -0.2 3 4 
 i 11 92.5 6 8.2108967825 127 -0.2 3 4 
 i 11 93.0 6 8.05889368905 127 -0.2 3 4 
 i 11 95.0 6 8.05889368905 127 -0.2 3 4 
 i 11 95.5 6 8.47393118833 127 -0.2 3 4 
 i 11 97.5 6 8.2108967825 127 -0.2 3 4 
 i 11 98.0 6 8.64385618977 127 -0.2 3 4 
 i 11 100.0 6 8.05889368905 127 -0.2 3 4 
 i 11 100.5 6 8.2108967825 127 -0.2 3 4 
 i 11 102.5 6 8.2108967825 127 -0.2 3 4 
 i 11 103.0 6 8.05889368905 127 -0.2 3 4 
 i 11 105.0 6 8.05889368905 127 -0.2 3 4 
 i 11 105.5 6 8.47393118833 127 -0.2 3 4 
 i 11 107.5 6 8.2108967825 127 -0.2 3 4 
 i 11 108.0 6 8.64385618977 127 -0.2 3 4 
 i 11 110.0 6 8.05889368905 127 -0.2 3 4 
 i 11 110.5 6 8.2108967825 127 -0.2 3 4 
 i 11 112.5 6 8.2108967825 127 -0.2 3 4 
 i 11 113.0 6 8.05889368905 127 -0.2 3 4 
 i 11 115.0 6 8.05889368905 127 -0.2 3 4 
 i 11 115.5 6 8.47393118833 127 -0.2 3 4 
 i 11 117.5 6 8.2108967825 127 -0.2 3 4 
 i 11 118.0 6 8.64385618977 127 -0.2 3 4 
 i 11 120.0 6 8.05889368905 127 -0.2 3 4 
 i 11 120.5 6 8.2108967825 127 -0.2 3 4 
 i 11 122.5 6 8.2108967825 127 -0.2 3 4 
 i 11 123.0 6 8.05889368905 127 -0.2 3 4 
 i 11 125.0 6 8.05889368905 127 -0.2 3 4 
 i 11 125.5 6 8.47393118833 127 -0.2 3 4 
 i 11 127.5 6 8.2108967825 127 -0.2 3 4 
 i 11 128.0 6 8.64385618977 127 -0.2 3 4 
 i 11 130.0 6 8.05889368905 127 -0.2 3 4 
 i 11 130.5 6 8.2108967825 127 -0.2 3 4 
 i 11 132.5 6 8.2108967825 127 -0.2 3 4 
 i 11 133.0 6 8.05889368905 127 -0.2 3 4 
 i 11 135.0 6 8.05889368905 127 -0.2 3 4 
 i 11 135.5 6 8.47393118833 127 -0.2 3 4 
 i 11 137.5 6 8.2108967825 127 -0.2 3 4 
 i 11 138.0 6 8.64385618977 127 -0.2 3 4 
 i 11 140.0 6 8.05889368905 127 -0.2 3 4 
 i 11 140.5 6 8.2108967825 127 -0.2 3 4 
 i 11 142.5 6 8.2108967825 127 -0.2 3 4 
 i 11 143.0 6 8.05889368905 127 -0.2 3 4 
 i 11 145.0 6 8.05889368905 127 -0.2 3 4 
 i 11 145.5 6 8.47393118833 127 -0.2 3 4 
 i 11 147.5 6 8.2108967825 127 -0.2 3 4 
 i 11 148.0 6 8.64385618977 127 -0.2 3 4 
 i 11 150.0 6 8.05889368905 127 -0.2 3 4 
 i 11 150.5 6 8.2108967825 127 -0.2 3 4 
 i 11 152.5 6 8.2108967825 127 -0.2 3 4 
 i 11 153.0 6 8.05889368905 127 -0.2 3 4 
 i 11 155.0 6 8.05889368905 127 -0.2 3 4 
 i 11 155.5 6 8.47393118833 127 -0.2 3 4 
 i 11 157.5 6 8.2108967825 127 -0.2 3 4 
 i 11 158.0 6 8.64385618977 127 -0.2 3 4 
 i 11 160.0 6 8.05889368905 127 -0.2 3 4 
 i 11 160.5 6 8.2108967825 127 -0.2 3 4 
 i 11 162.5 6 8.2108967825 127 -0.2 3 4 
 i 11 163.0 6 8.05889368905 127 -0.2 3 4 
 i 11 165.0 6 8.05889368905 127 -0.2 3 4 
 i 11 165.5 6 8.47393118833 127 -0.2 3 4 
 i 11 167.5 6 8.2108967825 127 -0.2 3 4 
 i 11 168.0 6 8.64385618977 127 -0.2 3 4 
 i 11 170.0 6 8.05889368905 127 -0.2 3 4 
 i 11 170.5 6 8.2108967825 127 -0.2 3 4 
 i 11 172.5 6 8.2108967825 127 -0.2 3 4 
 i 11 173.0 6 8.05889368905 127 -0.2 3 4 
 i 11 175.0 6 8.05889368905 127 -0.2 3 4 
 i 11 175.5 6 8.47393118833 127 -0.2 3 4 
 i 11 177.5 6 8.2108967825 127 -0.2 3 4 
 i 11 178.0 6 8.64385618977 127 -0.2 3 4 
 i 11 180.0 6 8.05889368905 127 -0.2 3 4 
 i 11 0 6 8.05889368905 127 0.2 3 4 
 i 11 0.5 6 8.2108967825 127 0.2 3 4 
 i 11 0.75 6 8.05889368905 127 0.2 3 4 
 i 11 1.25 6 8.2108967825 127 0.2 3 4 
 i 11 1.5 6 8.05889368905 127 0.2 3 4 
 i 11 3.0 6 8.2108967825 127 0.2 3 4 
 i 11 3.5 6 8.05889368905 127 0.2 3 4 
 i 11 3.75 6 8.2108967825 127 0.2 3 4 
 i 11 4.25 6 8.05889368905 127 0.2 3 4 
 i 11 4.5 6 8.2108967825 127 0.2 3 4 
 i 11 6.0 6 8.05889368905 127 0.2 3 4 
 i 11 6.5 6 8.2108967825 127 0.2 3 4 
 i 11 6.75 6 8.05889368905 127 0.2 3 4 
 i 11 7.25 6 8.2108967825 127 0.2 3 4 
 i 11 7.5 6 8.05889368905 127 0.2 3 4 
 i 11 9.0 6 8.2108967825 127 0.2 3 4 
 i 11 9.5 6 8.05889368905 127 0.2 3 4 
 i 11 9.75 6 8.2108967825 127 0.2 3 4 
 i 11 10.25 6 8.05889368905 127 0.2 3 4 
 i 11 10.5 6 8.2108967825 127 0.2 3 4 
 i 11 12.0 6 8.05889368905 127 0.2 3 4 
 i 11 12.5 6 8.2108967825 127 0.2 3 4 
 i 11 12.75 6 8.05889368905 127 0.2 3 4 
 i 11 13.25 6 8.2108967825 127 0.2 3 4 
 i 11 13.5 6 8.05889368905 127 0.2 3 4 
 i 11 15.0 6 8.2108967825 127 0.2 3 4 
 i 11 15.5 6 8.05889368905 127 0.2 3 4 
 i 11 15.75 6 8.2108967825 127 0.2 3 4 
 i 11 16.25 6 8.05889368905 127 0.2 3 4 
 i 11 16.5 6 8.2108967825 127 0.2 3 4 
 i 11 18.0 6 8.05889368905 127 0.2 3 4 
 i 11 18.5 6 8.2108967825 127 0.2 3 4 
 i 11 18.75 6 8.05889368905 127 0.2 3 4 
 i 11 19.25 6 8.2108967825 127 0.2 3 4 
 i 11 19.5 6 8.05889368905 127 0.2 3 4 
 i 11 21.0 6 8.2108967825 127 0.2 3 4 
 i 11 21.5 6 8.05889368905 127 0.2 3 4 
 i 11 21.75 6 8.2108967825 127 0.2 3 4 
 i 11 22.25 6 8.05889368905 127 0.2 3 4 
 i 11 22.5 6 8.2108967825 127 0.2 3 4 
 i 11 24.0 6 8.05889368905 127 0.2 3 4 
 i 11 24.5 6 8.2108967825 127 0.2 3 4 
 i 11 24.75 6 8.05889368905 127 0.2 3 4 
 i 11 25.25 6 8.2108967825 127 0.2 3 4 
 i 11 25.5 6 8.05889368905 127 0.2 3 4 
 i 11 27.0 6 8.2108967825 127 0.2 3 4 
 i 11 27.5 6 8.05889368905 127 0.2 3 4 
 i 11 27.75 6 8.2108967825 127 0.2 3 4 
 i 11 28.25 6 8.05889368905 127 0.2 3 4 
 i 11 28.5 6 8.2108967825 127 0.2 3 4 
 i 11 30.0 6 8.05889368905 127 0.2 3 4 
 i 11 30.5 6 8.2108967825 127 0.2 3 4 
 i 11 30.75 6 8.05889368905 127 0.2 3 4 
 i 11 31.25 6 8.2108967825 127 0.2 3 4 
 i 11 31.5 6 8.05889368905 127 0.2 3 4 
 i 11 33.0 6 8.2108967825 127 0.2 3 4 
 i 11 33.5 6 8.05889368905 127 0.2 3 4 
 i 11 33.75 6 8.2108967825 127 0.2 3 4 
 i 11 34.25 6 8.05889368905 127 0.2 3 4 
 i 11 34.5 6 8.2108967825 127 0.2 3 4 
 i 11 36.0 6 8.05889368905 127 0.2 3 4 
 i 11 36.5 6 8.2108967825 127 0.2 3 4 
 i 11 36.75 6 8.05889368905 127 0.2 3 4 
 i 11 37.25 6 8.2108967825 127 0.2 3 4 
 i 11 37.5 6 8.05889368905 127 0.2 3 4 
 i 11 39.0 6 8.2108967825 127 0.2 3 4 
 i 11 39.5 6 8.05889368905 127 0.2 3 4 
 i 11 39.75 6 8.2108967825 127 0.2 3 4 
 i 11 40.25 6 8.05889368905 127 0.2 3 4 
 i 11 40.5 6 8.2108967825 127 0.2 3 4 
 i 11 42.0 6 8.05889368905 127 0.2 3 4 
 i 11 42.5 6 8.2108967825 127 0.2 3 4 
 i 11 42.75 6 8.05889368905 127 0.2 3 4 
 i 11 43.25 6 8.2108967825 127 0.2 3 4 
 i 11 43.5 6 8.05889368905 127 0.2 3 4 
 i 11 45.0 6 8.2108967825 127 0.2 3 4 
 i 11 45.5 6 8.05889368905 127 0.2 3 4 
 i 11 45.75 6 8.2108967825 127 0.2 3 4 
 i 11 46.25 6 8.05889368905 127 0.2 3 4 
 i 11 46.5 6 8.2108967825 127 0.2 3 4 
 i 11 48.0 6 8.05889368905 127 0.2 3 4 
 i 11 48.5 6 8.2108967825 127 0.2 3 4 
 i 11 48.75 6 8.05889368905 127 0.2 3 4 
 i 11 49.25 6 8.2108967825 127 0.2 3 4 
 i 11 49.5 6 8.05889368905 127 0.2 3 4 
 i 11 51.0 6 8.2108967825 127 0.2 3 4 
 i 11 51.5 6 8.05889368905 127 0.2 3 4 
 i 11 51.75 6 8.2108967825 127 0.2 3 4 
 i 11 52.25 6 8.05889368905 127 0.2 3 4 
 i 11 52.5 6 8.2108967825 127 0.2 3 4 
 i 11 54.0 6 8.05889368905 127 0.2 3 4 
 i 11 54.5 6 8.2108967825 127 0.2 3 4 
 i 11 54.75 6 8.05889368905 127 0.2 3 4 
 i 11 55.25 6 8.2108967825 127 0.2 3 4 
 i 11 55.5 6 8.05889368905 127 0.2 3 4 
 i 11 57.0 6 8.2108967825 127 0.2 3 4 
 i 11 57.5 6 8.05889368905 127 0.2 3 4 
 i 11 57.75 6 8.2108967825 127 0.2 3 4 
 i 11 58.25 6 8.05889368905 127 0.2 3 4 
 i 11 58.5 6 8.2108967825 127 0.2 3 4 
 i 11 60.0 6 8.05889368905 127 0.2 3 4 
 i 11 60.5 6 8.2108967825 127 0.2 3 4 
 i 11 60.75 6 8.05889368905 127 0.2 3 4 
 i 11 61.25 6 8.2108967825 127 0.2 3 4 
 i 11 61.5 6 8.05889368905 127 0.2 3 4 
 i 11 63.0 6 8.2108967825 127 0.2 3 4 
 i 11 63.5 6 8.05889368905 127 0.2 3 4 
 i 11 63.75 6 8.2108967825 127 0.2 3 4 
 i 11 64.25 6 8.05889368905 127 0.2 3 4 
 i 11 64.5 6 8.2108967825 127 0.2 3 4 
 i 11 66.0 6 8.05889368905 127 0.2 3 4 
 i 11 66.5 6 8.2108967825 127 0.2 3 4 
 i 11 66.75 6 8.05889368905 127 0.2 3 4 
 i 11 67.25 6 8.2108967825 127 0.2 3 4 
 i 11 67.5 6 8.05889368905 127 0.2 3 4 
 i 11 69.0 6 8.2108967825 127 0.2 3 4 
 i 11 69.5 6 8.05889368905 127 0.2 3 4 
 i 11 69.75 6 8.2108967825 127 0.2 3 4 
 i 11 70.25 6 8.05889368905 127 0.2 3 4 
 i 11 70.5 6 8.2108967825 127 0.2 3 4 
 i 11 72.0 6 8.05889368905 127 0.2 3 4 
 i 11 72.5 6 8.2108967825 127 0.2 3 4 
 i 11 72.75 6 8.05889368905 127 0.2 3 4 
 i 11 73.25 6 8.2108967825 127 0.2 3 4 
 i 11 73.5 6 8.05889368905 127 0.2 3 4 
 i 11 75.0 6 8.2108967825 127 0.2 3 4 
 i 11 75.5 6 8.05889368905 127 0.2 3 4 
 i 11 75.75 6 8.2108967825 127 0.2 3 4 
 i 11 76.25 6 8.05889368905 127 0.2 3 4 
 i 11 76.5 6 8.2108967825 127 0.2 3 4 
 i 11 78.0 6 8.05889368905 127 0.2 3 4 
 i 11 78.5 6 8.2108967825 127 0.2 3 4 
 i 11 78.75 6 8.05889368905 127 0.2 3 4 
 i 11 79.25 6 8.2108967825 127 0.2 3 4 
 i 11 79.5 6 8.05889368905 127 0.2 3 4 
 i 11 81.0 6 8.2108967825 127 0.2 3 4 
 i 11 81.5 6 8.05889368905 127 0.2 3 4 
 i 11 81.75 6 8.2108967825 127 0.2 3 4 
 i 11 82.25 6 8.05889368905 127 0.2 3 4 
 i 11 82.5 6 8.2108967825 127 0.2 3 4 
 i 11 84.0 6 8.05889368905 127 0.2 3 4 
 i 11 84.5 6 8.2108967825 127 0.2 3 4 
 i 11 84.75 6 8.05889368905 127 0.2 3 4 
 i 11 85.25 6 8.2108967825 127 0.2 3 4 
 i 11 85.5 6 8.05889368905 127 0.2 3 4 
 i 11 87.0 6 8.2108967825 127 0.2 3 4 
 i 11 87.5 6 8.05889368905 127 0.2 3 4 
 i 11 87.75 6 8.2108967825 127 0.2 3 4 
 i 11 88.25 6 8.05889368905 127 0.2 3 4 
 i 11 88.5 6 8.2108967825 127 0.2 3 4 
 i 11 90.0 6 8.05889368905 127 0.2 3 4 
 i 11 90.5 6 8.2108967825 127 0.2 3 4 
 i 11 90.75 6 8.05889368905 127 0.2 3 4 
 i 11 91.25 6 8.2108967825 127 0.2 3 4 
 i 11 91.5 6 8.05889368905 127 0.2 3 4 
 i 11 93.0 6 8.2108967825 127 0.2 3 4 
 i 11 93.5 6 8.05889368905 127 0.2 3 4 
 i 11 93.75 6 8.2108967825 127 0.2 3 4 
 i 11 94.25 6 8.05889368905 127 0.2 3 4 
 i 11 94.5 6 8.2108967825 127 0.2 3 4 
 i 11 96.0 6 8.05889368905 127 0.2 3 4 
 i 11 96.5 6 8.2108967825 127 0.2 3 4 
 i 11 96.75 6 8.05889368905 127 0.2 3 4 
 i 11 97.25 6 8.2108967825 127 0.2 3 4 
 i 11 97.5 6 8.05889368905 127 0.2 3 4 
 i 11 99.0 6 8.2108967825 127 0.2 3 4 
 i 11 99.5 6 8.05889368905 127 0.2 3 4 
 i 11 99.75 6 8.2108967825 127 0.2 3 4 
 i 11 100.25 6 8.05889368905 127 0.2 3 4 
 i 11 100.5 6 8.2108967825 127 0.2 3 4 
 i 11 102.0 6 8.05889368905 127 0.2 3 4 
 i 11 102.5 6 8.2108967825 127 0.2 3 4 
 i 11 102.75 6 8.05889368905 127 0.2 3 4 
 i 11 103.25 6 8.2108967825 127 0.2 3 4 
 i 11 103.5 6 8.05889368905 127 0.2 3 4 
 i 11 105.0 6 8.2108967825 127 0.2 3 4 
 i 11 105.5 6 8.05889368905 127 0.2 3 4 
 i 11 105.75 6 8.2108967825 127 0.2 3 4 
 i 11 106.25 6 8.05889368905 127 0.2 3 4 
 i 11 106.5 6 8.2108967825 127 0.2 3 4 
 i 11 108.0 6 8.05889368905 127 0.2 3 4 
 i 11 108.5 6 8.2108967825 127 0.2 3 4 
 i 11 108.75 6 8.05889368905 127 0.2 3 4 
 i 11 109.25 6 8.2108967825 127 0.2 3 4 
 i 11 109.5 6 8.05889368905 127 0.2 3 4 
 i 11 111.0 6 8.2108967825 127 0.2 3 4 
 i 11 111.5 6 8.05889368905 127 0.2 3 4 
 i 11 111.75 6 8.2108967825 127 0.2 3 4 
 i 11 112.25 6 8.05889368905 127 0.2 3 4 
 i 11 112.5 6 8.2108967825 127 0.2 3 4 
 i 11 114.0 6 8.05889368905 127 0.2 3 4 
 i 11 114.5 6 8.2108967825 127 0.2 3 4 
 i 11 114.75 6 8.05889368905 127 0.2 3 4 
 i 11 115.25 6 8.2108967825 127 0.2 3 4 
 i 11 115.5 6 8.05889368905 127 0.2 3 4 
 i 11 117.0 6 8.2108967825 127 0.2 3 4 
 i 11 117.5 6 8.05889368905 127 0.2 3 4 
 i 11 117.75 6 8.2108967825 127 0.2 3 4 
 i 11 118.25 6 8.05889368905 127 0.2 3 4 
 i 11 118.5 6 8.2108967825 127 0.2 3 4 
 i 11 120.0 6 8.05889368905 127 0.2 3 4 
 i 11 120.5 6 8.2108967825 127 0.2 3 4 
 i 11 120.75 6 8.05889368905 127 0.2 3 4 
 i 11 121.25 6 8.2108967825 127 0.2 3 4 
 i 11 121.5 6 8.05889368905 127 0.2 3 4 
 i 11 123.0 6 8.2108967825 127 0.2 3 4 
 i 11 123.5 6 8.05889368905 127 0.2 3 4 
 i 11 123.75 6 8.2108967825 127 0.2 3 4 
 i 11 124.25 6 8.05889368905 127 0.2 3 4 
 i 11 124.5 6 8.2108967825 127 0.2 3 4 
 i 11 126.0 6 8.05889368905 127 0.2 3 4 
 i 11 126.5 6 8.2108967825 127 0.2 3 4 
 i 11 126.75 6 8.05889368905 127 0.2 3 4 
 i 11 127.25 6 8.2108967825 127 0.2 3 4 
 i 11 127.5 6 8.05889368905 127 0.2 3 4 
 i 11 129.0 6 8.2108967825 127 0.2 3 4 
 i 11 129.5 6 8.05889368905 127 0.2 3 4 
 i 11 129.75 6 8.2108967825 127 0.2 3 4 
 i 11 130.25 6 8.05889368905 127 0.2 3 4 
 i 11 130.5 6 8.2108967825 127 0.2 3 4 
 i 11 132.0 6 8.05889368905 127 0.2 3 4 
 i 11 132.5 6 8.2108967825 127 0.2 3 4 
 i 11 132.75 6 8.05889368905 127 0.2 3 4 
 i 11 133.25 6 8.2108967825 127 0.2 3 4 
 i 11 133.5 6 8.05889368905 127 0.2 3 4 
 i 11 135.0 6 8.2108967825 127 0.2 3 4 
 i 11 135.5 6 8.05889368905 127 0.2 3 4 
 i 11 135.75 6 8.2108967825 127 0.2 3 4 
 i 11 136.25 6 8.05889368905 127 0.2 3 4 
 i 11 136.5 6 8.2108967825 127 0.2 3 4 
 i 11 138.0 6 8.05889368905 127 0.2 3 4 
 i 11 138.5 6 8.2108967825 127 0.2 3 4 
 i 11 138.75 6 8.05889368905 127 0.2 3 4 
 i 11 139.25 6 8.2108967825 127 0.2 3 4 
 i 11 139.5 6 8.05889368905 127 0.2 3 4 
 i 11 141.0 6 8.2108967825 127 0.2 3 4 
 i 11 141.5 6 8.05889368905 127 0.2 3 4 
 i 11 141.75 6 8.2108967825 127 0.2 3 4 
 i 11 142.25 6 8.05889368905 127 0.2 3 4 
 i 11 142.5 6 8.2108967825 127 0.2 3 4 
 i 11 144.0 6 8.05889368905 127 0.2 3 4 
 i 11 144.5 6 8.2108967825 127 0.2 3 4 
 i 11 144.75 6 8.05889368905 127 0.2 3 4 
 i 11 145.25 6 8.2108967825 127 0.2 3 4 
 i 11 145.5 6 8.05889368905 127 0.2 3 4 
 i 11 147.0 6 8.2108967825 127 0.2 3 4 
 i 11 147.5 6 8.05889368905 127 0.2 3 4 
 i 11 147.75 6 8.2108967825 127 0.2 3 4 
 i 11 148.25 6 8.05889368905 127 0.2 3 4 
 i 11 148.5 6 8.2108967825 127 0.2 3 4 
 i 11 150.0 6 8.05889368905 127 0.2 3 4 
 i 11 150.5 6 8.2108967825 127 0.2 3 4 
 i 11 150.75 6 8.05889368905 127 0.2 3 4 
 i 11 151.25 6 8.2108967825 127 0.2 3 4 
 i 11 151.5 6 8.05889368905 127 0.2 3 4 
 i 11 153.0 6 8.2108967825 127 0.2 3 4 
 i 11 153.5 6 8.05889368905 127 0.2 3 4 
 i 11 153.75 6 8.2108967825 127 0.2 3 4 
 i 11 154.25 6 8.05889368905 127 0.2 3 4 
 i 11 154.5 6 8.2108967825 127 0.2 3 4 
 i 11 156.0 6 8.05889368905 127 0.2 3 4 
 i 11 156.5 6 8.2108967825 127 0.2 3 4 
 i 11 156.75 6 8.05889368905 127 0.2 3 4 
 i 11 157.25 6 8.2108967825 127 0.2 3 4 
 i 11 157.5 6 8.05889368905 127 0.2 3 4 
 i 11 159.0 6 8.2108967825 127 0.2 3 4 
 i 11 159.5 6 8.05889368905 127 0.2 3 4 
 i 11 159.75 6 8.2108967825 127 0.2 3 4 
 i 11 160.25 6 8.05889368905 127 0.2 3 4 
 i 11 160.5 6 8.2108967825 127 0.2 3 4 
 i 11 162.0 6 8.05889368905 127 0.2 3 4 
 i 11 162.5 6 8.2108967825 127 0.2 3 4 
 i 11 162.75 6 8.05889368905 127 0.2 3 4 
 i 11 163.25 6 8.2108967825 127 0.2 3 4 
 i 11 163.5 6 8.05889368905 127 0.2 3 4 
 i 11 165.0 6 8.2108967825 127 0.2 3 4 
 i 11 165.5 6 8.05889368905 127 0.2 3 4 
 i 11 165.75 6 8.2108967825 127 0.2 3 4 
 i 11 166.25 6 8.05889368905 127 0.2 3 4 
 i 11 166.5 6 8.2108967825 127 0.2 3 4 
 i 11 168.0 6 8.05889368905 127 0.2 3 4 
 i 11 168.5 6 8.2108967825 127 0.2 3 4 
 i 11 168.75 6 8.05889368905 127 0.2 3 4 
 i 11 169.25 6 8.2108967825 127 0.2 3 4 
 i 11 169.5 6 8.05889368905 127 0.2 3 4 
 i 11 171.0 6 8.2108967825 127 0.2 3 4 
 i 11 171.5 6 8.05889368905 127 0.2 3 4 
 i 11 171.75 6 8.2108967825 127 0.2 3 4 
 i 11 172.25 6 8.05889368905 127 0.2 3 4 
 i 11 172.5 6 8.2108967825 127 0.2 3 4 
 i 11 174.0 6 8.05889368905 127 0.2 3 4 
 i 11 174.5 6 8.2108967825 127 0.2 3 4 
 i 11 174.75 6 8.05889368905 127 0.2 3 4 
 i 11 175.25 6 8.2108967825 127 0.2 3 4 
 i 11 175.5 6 8.05889368905 127 0.2 3 4 
 i 11 177.0 6 8.2108967825 127 0.2 3 4 
 i 11 177.5 6 8.05889368905 127 0.2 3 4 
 i 11 177.75 6 8.2108967825 127 0.2 3 4 
 i 11 178.25 6 8.05889368905 127 0.2 3 4 
 i 11 178.5 6 8.2108967825 127 0.2 3 4 
 i 11 180.0 6 8.05889368905 127 0.2 3 4 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURCODA	   3  	4  0.825  80 ; dx (shadows the vibes)

;cb ostinato
 i 12 0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 0.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 2.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 3.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 5.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 5.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 7.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 8.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 10.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 10.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 12.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 13.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 15.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 15.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 17.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 18.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 20.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 20.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 22.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 23.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 25.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 25.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 27.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 28.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 30.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 30.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 32.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 33.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 35.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 35.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 37.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 38.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 40.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 40.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 42.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 43.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 45.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 45.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 47.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 48.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 50.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 50.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 52.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 53.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 55.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 55.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 57.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 58.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 60.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 60.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 62.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 63.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 65.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 65.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 67.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 68.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 70.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 70.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 72.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 73.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 75.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 75.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 77.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 78.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 80.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 80.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 82.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 83.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 85.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 85.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 87.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 88.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 90.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 90.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 92.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 93.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 95.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 95.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 97.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 98.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 100.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 100.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 102.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 103.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 105.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 105.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 107.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 108.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 110.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 110.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 112.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 113.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 115.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 115.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 117.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 118.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 120.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 120.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 122.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 123.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 125.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 125.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 127.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 128.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 130.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 130.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 132.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 133.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 135.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 135.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 137.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 138.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 140.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 140.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 142.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 143.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 145.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 145.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 147.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 148.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 150.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 150.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 152.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 153.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 155.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 155.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 157.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 158.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 160.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 160.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 162.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 163.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 165.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 165.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 167.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 168.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 170.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 170.5 2.0 85 5.2108967825 0.0 2 5 6 
 i 12 172.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 173.0 2.0 85 5.05889368905 0.0 2 5 6 
 i 12 175.0 0.5 85 5.05889368905 0.0 4 5 6 
 i 12 175.5 2.0 85 5.47393118833 0.0 2 5 6 
 i 12 177.5 0.5 85 5.2108967825 0.0 4 5 6 
 i 12 178.0 2.0 85 5.64385618977 0.0 2 5 6 
 i 12 180.0 2.0 85 5.05889368905 0.0 4 5 6 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURCODA	   5  	6  1.05  80 ; bass

;coda bellpiano
 i 21 20.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 20.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 21.0 4.5 15000 8.64385618977 0.213 7 8 
 i 21 21.25 4.5 15000 9.05889368905 0.213 7 8 
 i 21 26.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 26.75 4.5 15000 8.79585928322 0.213 7 8 
 i 21 27.0 4.5 15000 8.2108967825 0.213 7 8 
 i 21 27.25 4.5 15000 8.64385618977 0.213 7 8 
 i 21 30.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 30.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 31.0 4.5 15000 8.64385618977 0.213 7 8 
 i 21 31.25 4.5 15000 9.05889368905 0.213 7 8 
 i 21 36.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 36.75 4.5 15000 8.79585928322 0.213 7 8 
 i 21 37.0 4.5 15000 8.2108967825 0.213 7 8 
 i 21 37.25 4.5 15000 11.6438561898 0.213 7 8 
 i 21 40.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 40.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 41.0 4.5 15000 8.64385618977 0.213 7 8 
 i 21 41.25 4.5 15000 9.05889368905 0.213 7 8 
 i 21 41.5 4.5 15000 8.47393118833 0.213 7 8 
 i 21 41.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 42.0 4.5 15000 9.64385618977 0.213 7 8 
 i 21 46.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 46.75 4.5 15000 8.64385618977 0.213 7 8 
 i 21 47.0 4.5 15000 9.64385618977 0.213 7 8 
 i 21 47.25 4.5 15000 9.2108967825 0.213 7 8 
 i 21 47.5 4.5 15000 9.64385618977 0.213 7 8 
 i 21 47.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 48.0 4.5 15000 8.47393118833 0.213 7 8 
 i 21 50.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 50.75 4.5 15000 11.4739311883 0.213 7 8 
 i 21 51.0 4.5 15000 11.8889686876 0.213 7 8 
 i 21 51.25 4.5 15000 8.88896868761 0.213 7 8 
 i 21 51.5 4.5 15000 8.47393118833 0.213 7 8 
 i 21 51.75 4.5 15000 8.88896868761 0.213 7 8 
 i 21 52.0 4.5 15000 9.2288186905 0.213 7 8 
 i 21 56.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 56.75 4.5 15000 8.79585928322 0.213 7 8 
 i 21 57.0 4.5 15000 8.2108967825 0.213 7 8 
 i 21 57.25 4.5 15000 8.64385618977 0.213 7 8 
 i 21 57.5 4.5 15000 9.64385618977 0.213 7 8 
 i 21 57.75 4.5 15000 9.2108967825 0.213 7 8 
 i 21 58.0 4.5 15000 8.79585928322 0.213 7 8 
 i 21 60.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 60.75 4.5 15000 11.4739311883 0.213 7 8 
 i 21 61.0 4.5 15000 8.05889368905 0.213 7 8 
 i 21 61.25 4.5 15000 11.4739311883 0.213 7 8 
 i 21 61.5 4.5 15000 11.8889686876 0.213 7 8 
 i 21 61.75 4.5 15000 8.88896868761 0.213 7 8 
 i 21 62.0 4.5 15000 9.88896868761 0.213 7 8 
 i 21 62.25 4.5 15000 9.47393118833 0.213 7 8 
 i 21 62.5 4.5 15000 9.88896868761 0.213 7 8 
 i 21 62.75 4.5 15000 9.2288186905 0.213 7 8 
 i 21 63.0 4.5 15000 9.88896868761 0.213 7 8 
 i 21 63.5 4.5 15000 9.2288186905 0.213 7 8 
 i 21 66.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 67.0 4.5 15000 8.64385618977 0.213 7 8 
 i 21 67.25 4.5 15000 9.64385618977 0.213 7 8 
 i 21 67.5 4.5 15000 9.2108967825 0.213 7 8 
 i 21 67.75 4.5 15000 9.64385618977 0.213 7 8 
 i 21 68.0 4.5 15000 9.05889368905 0.213 7 8 
 i 21 68.25 4.5 15000 9.64385618977 0.213 7 8 
 i 21 68.5 4.5 15000 9.05889368905 0.213 7 8 
 i 21 68.75 4.5 15000 8.47393118833 0.213 7 8 
 i 21 69.0 4.5 15000 8.88896868761 0.213 7 8 
 i 21 69.25 4.5 15000 9.88896868761 0.213 7 8 
 i 21 69.5 4.5 15000 9.47393118833 0.213 7 8 
 i 21 70.25 4.5 15000 8.05889368905 0.213 7 8 
 i 21 70.75 4.5 15000 11.4739311883 0.213 7 8 
 i 21 71.25 4.5 15000 8.05889368905 0.213 7 8 
 i 21 71.5 4.5 15000 8.64385618977 0.213 7 8 
 i 21 71.75 4.5 15000 8.05889368905 0.213 7 8 
 i 21 72.0 4.5 15000 8.47393118833 0.213 7 8 
 i 21 72.25 4.5 15000 9.47393118833 0.213 7 8 
 i 21 72.5 4.5 15000 9.05889368905 0.213 7 8 
 i 21 72.75 4.5 15000 9.47393118833 0.213 7 8 
 i 21 73.0 4.5 15000 8.88896868761 0.213 7 8 
 i 21 73.25 4.5 15000 8.2288186905 0.213 7 8 
 i 21 73.5 4.5 15000 8.88896868761 0.213 7 8 
 i 21 76.25 4.5 15000 8.2108967825 0.213 7 8 
 i 21 76.5 4.5 15000 8.64385618977 0.213 7 8 
 i 21 77.0 4.5 15000 9.64385618977 0.213 7 8 
 i 21 77.5 4.5 15000 9.2108967825 0.213 7 8 
 i 21 77.75 4.5 15000 9.64385618977 0.213 7 8 
 i 21 78.0 4.5 15000 10.0588936891 0.213 7 8 
 i 21 78.25 4.5 15000 9.47393118833 0.213 7 8 
 i 21 78.5 4.5 15000 10.0588936891 0.213 7 8 
 i 21 78.75 4.5 15000 9.47393118833 0.213 7 8 
 i 21 79.0 4.5 15000 9.88896868761 0.213 7 8 
 i 21 79.25 4.5 15000 10.8889686876 0.213 7 8 
 i 21 79.5 4.5 15000 10.4739311883 0.213 7 8 
 i 21 79.75 4.5 15000 10.0588936891 0.213 7 8 
 i 21 80.0 4.5 15000 10.4739311883 0.213 7 8 
 i 21 80.25 4.5 15000 8.05889368905 0.213 7 8 
 i 21 80.25 4.5 15000 9.88896868761 0.213 7 8 
 i 21 80.5 4.5 15000 8.47393118833 0.213 7 8 
 i 21 80.75 4.5 15000 9.47393118833 0.213 7 8 
 i 21 80.75 4.5 15000 10.4739311883 0.213 7 8 
 i 21 81.25 4.5 15000 10.4739311883 0.213 7 8 
 i 21 81.75 4.5 15000 10.0588936891 0.213 7 8 
 i 21 82.0 4.5 15000 10.4739311883 0.213 7 8 
 i 21 82.25 4.5 15000 9.88896868761 0.213 7 8 
 i 21 82.5 4.5 15000 10.4739311883 0.213 7 8 
 i 21 82.75 4.5 15000 9.88896868761 0.213 7 8 
 i 21 83.0 4.5 15000 10.2288186905 0.213 7 8 
 i 21 83.25 4.5 15000 10.7027498788 0.213 7 8 
 i 21 83.5 4.5 15000 11.7027498788 0.213 7 8 
 i 21 83.75 4.5 15000 11.2288186905 0.213 7 8 
 i 21 84.0 4.5 15000 11.7027498788 0.213 7 8 
 i 21 84.25 4.5 15000 11.1177873781 0.213 7 8 
 i 21 84.5 4.5 15000 11.7027498788 0.213 7 8 
 i 21 85.0 4.5 15000 11.1177873781 0.213 7 8 
 i 21 86.25 4.5 15000 8.2108967825 0.213 7 8 
 i 21 86.5 4.5 15000 8.64385618977 0.213 7 8 
 i 21 86.75 4.5 15000 9.64385618977 0.213 7 8 
 i 21 87.0 4.5 15000 9.2108967825 0.213 7 8 
 i 21 87.5 4.5 15000 9.64385618977 0.213 7 8 
 i 21 88.0 4.5 15000 9.05889368905 0.213 7 8 
 i 21 88.25 4.5 15000 9.64385618977 0.213 7 8 
 i 21 88.5 4.5 15000 10.2108967825 0.213 7 8 
 i 21 88.75 4.5 15000 9.64385618977 0.213 7 8 
 i 21 89.0 4.5 15000 10.0588936891 0.213 7 8 
 i 21 89.25 4.5 15000 11.0588936891 0.213 7 8 
 i 21 89.5 4.5 15000 10.6438561898 0.213 7 8 
 i 21 89.75 4.5 15000 11.0588936891 0.213 7 8 
 i 21 90.0 4.5 15000 10.4739311883 0.213 7 8 
 i 21 90.25 4.5 15000 8.05889368905 0.213 7 8 
 i 21 90.25 4.5 15000 9.88896868761 0.213 7 8 
 i 21 90.5 4.5 15000 9.05889368905 0.213 7 8 
 i 21 90.5 4.5 15000 10.4739311883 0.213 7 8 
 i 21 90.75 4.5 15000 8.64385618977 0.213 7 8 
 i 21 90.75 4.5 15000 9.88896868761 0.213 7 8 
 i 21 91.0 4.5 15000 9.05889368905 0.213 7 8 
 i 21 91.25 4.5 15000 9.47393118833 0.213 7 8 
 i 21 91.75 4.5 15000 8.88896868761 0.213 7 8 
 i 21 92.25 4.5 15000 9.47393118833 0.213 7 8 
 i 21 92.5 4.5 15000 8.88896868761 0.213 7 8 
 i 21 92.75 4.5 15000 9.2288186905 0.213 7 8 
 i 21 93.0 4.5 15000 10.2288186905 0.213 7 8 
 i 21 93.25 4.5 15000 9.88896868761 0.213 7 8 
 i 21 93.5 4.5 15000 9.47393118833 0.213 7 8 
 i 21 93.75 4.5 15000 9.88896868761 0.213 7 8 
 i 21 94.0 4.5 15000 9.2288186905 0.213 7 8 
 i 21 94.25 4.5 15000 9.88896868761 0.213 7 8 
 i 21 94.5 4.5 15000 9.2288186905 0.213 7 8 
 i 21 94.75 4.5 15000 9.70274987883 0.213 7 8 
 i 21 95.0 4.5 15000 10.7027498788 0.213 7 8 
 i 21 95.5 4.5 15000 11.7027498788 0.213 7 8 
 i 21 96.0 4.5 15000 11.2288186905 0.213 7 8 
 i 21 96.25 4.5 15000 8.2108967825 0.213 7 8 
 i 21 96.25 4.5 15000 11.7027498788 0.213 7 8 
 i 21 96.5 4.5 15000 8.79585928322 0.213 7 8 
 i 21 96.5 4.5 15000 11.1177873781 0.213 7 8 
 i 21 96.75 4.5 15000 8.2108967825 0.213 7 8 
 i 21 96.75 4.5 15000 11.7027498788 0.213 7 8 
 i 21 97.0 4.5 15000 11.1177873781 0.213 7 8 
 i 21 97.0 4.5 15000 11.6438561898 0.213 7 8 
 i 21 97.25 4.5 15000 8.05889368905 0.213 7 8 
 i 21 97.25 4.5 15000 11.5328248774 0.213 7 8 
 i 21 97.5 4.5 15000 9.05889368905 0.213 7 8 
 i 21 97.5 4.5 15000 11.9657842847 0.213 7 8 
 i 21 97.75 4.5 15000 8.64385618977 0.213 7 8 
 i 21 97.75 4.5 15000 8.96578428466 0.213 7 8 
 i 21 98.0 4.5 15000 8.53282487739 0.213 7 8 
 i 21 98.25 4.5 15000 8.96578428466 0.213 7 8 
 i 21 98.25 4.5 15000 9.05889368905 0.213 7 8 
 i 21 98.75 4.5 15000 8.47393118833 0.213 7 8 
 i 21 99.0 4.5 15000 9.05889368905 0.213 7 8 
 i 21 99.25 4.5 15000 9.64385618977 0.213 7 8 
 i 21 99.5 4.5 15000 9.05889368905 0.213 7 8 
 i 21 99.75 4.5 15000 9.47393118833 0.213 7 8 
 i 21 100.0 4.5 15000 10.4739311883 0.213 7 8 
 i 21 100.25 4.5 15000 8.05889368905 0.213 7 8 
 i 21 100.25 4.5 15000 10.0588936891 0.213 7 8 
 i 21 100.5 4.5 15000 10.4739311883 0.213 7 8 
 i 21 100.5 4.5 15000 11.6438561898 0.213 7 8 
 i 21 100.75 4.5 15000 9.88896868761 0.213 7 8 
 i 21 100.75 4.5 15000 11.2108967825 0.213 7 8 
 i 21 101.0 4.5 15000 9.2288186905 0.213 7 8 
 i 21 101.0 4.5 15000 11.6438561898 0.213 7 8 
 i 21 101.25 4.5 15000 9.88896868761 0.213 7 8 
 i 21 101.25 4.5 15000 11.0588936891 0.213 7 8 
 i 21 101.5 4.5 15000 9.2288186905 0.213 7 8 
 i 21 101.5 4.5 15000 11.6438561898 0.213 7 8 
 i 21 101.75 4.5 15000 11.0588936891 0.213 7 8 
 i 21 102.0 4.5 15000 9.70274987883 0.213 7 8 
 i 21 102.0 4.5 15000 11.4739311883 0.213 7 8 
 i 21 102.25 4.5 15000 8.47393118833 0.213 7 8 
 i 21 102.5 4.5 15000 10.7027498788 0.213 7 8 
 i 21 102.75 4.5 15000 9.47393118833 0.213 7 8 
 i 21 102.75 4.5 15000 10.2288186905 0.213 7 8 
 i 21 103.0 4.5 15000 10.7027498788 0.213 7 8 
 i 21 103.25 4.5 15000 9.05889368905 0.213 7 8 
 i 21 103.25 4.5 15000 11.1177873781 0.213 7 8 
 i 21 103.5 4.5 15000 9.47393118833 0.213 7 8 
 i 21 103.5 4.5 15000 10.5328248774 0.213 7 8 
 i 21 103.75 4.5 15000 8.88896868761 0.213 7 8 
 i 21 103.75 4.5 15000 11.1177873781 0.213 7 8 
 i 21 104.0 4.5 15000 9.47393118833 0.213 7 8 
 i 21 104.0 4.5 15000 10.5328248774 0.213 7 8 
 i 21 104.25 4.5 15000 8.88896868761 0.213 7 8 
 i 21 104.25 4.5 15000 10.9657842847 0.213 7 8 
 i 21 104.5 4.5 15000 9.2288186905 0.213 7 8 
 i 21 104.75 4.5 15000 9.70274987883 0.213 7 8 
 i 21 105.0 4.5 15000 10.7027498788 0.213 7 8 
 i 21 105.25 4.5 15000 10.2288186905 0.213 7 8 
 i 21 105.5 4.5 15000 10.7027498788 0.213 7 8 
 i 21 105.75 4.5 15000 10.1177873781 0.213 7 8 
 i 21 106.0 4.5 15000 10.7027498788 0.213 7 8 
 i 21 106.5 4.5 15000 10.1177873781 0.213 7 8 
 i 21 107.0 4.5 15000 9.53282487739 0.213 7 8 
 i 21 107.5 4.5 15000 9.96578428466 0.213 7 8 
 i 21 107.75 4.5 15000 10.9657842847 0.213 7 8 
 i 21 108.0 4.5 15000 10.5328248774 0.213 7 8 
 i 21 108.25 4.5 15000 10.9657842847 0.213 7 8 
 i 21 126.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 126.75 4.5 15000 8.79585928322 0.213 7 8 
 i 21 127.0 4.5 15000 9.38082178394 0.213 7 8 
 i 21 127.25 4.5 15000 8.79585928322 0.213 7 8 
 i 21 130.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 130.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 131.0 4.5 15000 8.64385618977 0.213 7 8 
 i 21 131.25 4.5 15000 9.05889368905 0.213 7 8 
 i 21 136.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 136.75 4.5 15000 11.6438561898 0.213 7 8 
 i 21 137.0 4.5 15000 8.2108967825 0.213 7 8 
 i 21 137.25 4.5 15000 11.6438561898 0.213 7 8 
 i 21 140.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 140.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 141.0 4.5 15000 8.64385618977 0.213 7 8 
 i 21 141.25 4.5 15000 9.05889368905 0.213 7 8 
 i 21 146.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 146.75 4.5 15000 11.6438561898 0.213 7 8 
 i 21 147.0 4.5 15000 8.2108967825 0.213 7 8 
 i 21 147.25 4.5 15000 11.6438561898 0.213 7 8 
 i 21 147.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 147.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 148.0 4.5 15000 8.64385618977 0.213 7 8 
 i 21 150.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 150.75 4.5 15000 8.47393118833 0.213 7 8 
 i 21 151.0 4.5 15000 11.8889686876 0.213 7 8 
 i 21 151.25 4.5 15000 8.47393118833 0.213 7 8 
 i 21 151.5 4.5 15000 11.8889686876 0.213 7 8 
 i 21 151.75 4.5 15000 8.2288186905 0.213 7 8 
 i 21 152.0 4.5 15000 9.2288186905 0.213 7 8 
 i 21 156.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 156.75 4.5 15000 11.7958592832 0.213 7 8 
 i 21 157.0 4.5 15000 8.2108967825 0.213 7 8 
 i 21 157.25 4.5 15000 11.6438561898 0.213 7 8 
 i 21 157.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 157.75 4.5 15000 11.6438561898 0.213 7 8 
 i 21 158.0 4.5 15000 8.05889368905 0.213 7 8 
 i 21 160.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 160.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 161.0 4.5 15000 8.64385618977 0.213 7 8 
 i 21 161.25 4.5 15000 9.05889368905 0.213 7 8 
 i 21 161.5 4.5 15000 8.47393118833 0.213 7 8 
 i 21 161.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 162.0 4.5 15000 8.47393118833 0.213 7 8 
 i 21 166.5 4.5 15000 8.2108967825 0.213 7 8 
 i 21 166.75 4.5 15000 8.64385618977 0.213 7 8 
 i 21 167.0 4.5 15000 9.64385618977 0.213 7 8 
 i 21 167.25 4.5 15000 9.2108967825 0.213 7 8 
 i 21 167.5 4.5 15000 9.64385618977 0.213 7 8 
 i 21 167.75 4.5 15000 9.05889368905 0.213 7 8 
 i 21 168.0 4.5 15000 9.64385618977 0.213 7 8 
 i 21 168.25 4.5 15000 10.2108967825 0.213 7 8 
 i 21 168.5 4.5 15000 9.64385618977 0.213 7 8 
 i 21 168.75 4.5 15000 10.0588936891 0.213 7 8 
 i 21 169.0 4.5 15000 11.0588936891 0.213 7 8 
 i 21 169.5 4.5 15000 10.6438561898 0.213 7 8 
 i 21 170.5 4.5 15000 8.05889368905 0.213 7 8 
 i 21 171.0 4.5 15000 11.4739311883 0.213 7 8 
 i 21 171.25 4.5 15000 10.8889686876 0.213 7 8 
 i 21 171.5 4.5 15000 11.4739311883 0.213 7 8 
 i 21 171.75 4.5 15000 10.8889686876 0.213 7 8 
 i 21 172.0 4.5 15000 11.2288186905 0.213 7 8 
 i 21 172.25 4.5 15000 8.2288186905 0.213 7 8 
 i 21 172.5 4.5 15000 11.8889686876 0.213 7 8 
 i 21 172.75 4.5 15000 8.2288186905 0.213 7 8 
 i 21 173.0 4.5 15000 8.70274987883 0.213 7 8 
 i 21 173.25 4.5 15000 8.11778737811 0.213 7 8 
 i 21 173.5 4.5 15000 8.70274987883 0.213 7 8 
 i 21 176.25 4.5 15000 8.2108967825 0.213 7 8 
 i 21 176.75 4.5 15000 8.64385618977 0.213 7 8 
 i 21 177.25 4.5 15000 9.64385618977 0.213 7 8 
 i 21 177.5 4.5 15000 9.2108967825 0.213 7 8 
 i 21 177.75 4.5 15000 8.79585928322 0.213 7 8 
 i 21 178.0 4.5 15000 9.2108967825 0.213 7 8 
 i 21 178.25 4.5 15000 8.64385618977 0.213 7 8 
 i 21 178.5 4.5 15000 9.2108967825 0.213 7 8 
 i 21 178.75 4.5 15000 8.64385618977 0.213 7 8 
 i 21 179.0 4.5 15000 9.05889368905 0.213 7 8 
 i 21 179.25 4.5 15000 10.0588936891 0.213 7 8 
 i 21 179.5 4.5 15000 11.0588936891 0.213 7 8 
 i 21 180.25 4.5 15000 8.05889368905 0.213 7 8 
 i 21 180.5 4.5 15000 8.47393118833 0.213 7 8 
 i 21 181.0 4.5 15000 11.8889686876 0.213 7 8 
 i 21 181.5 4.5 15000 8.47393118833 0.213 7 8 
 i 21 181.75 4.5 15000 11.8889686876 0.213 7 8 
 i 21 182.0 4.5 15000 8.2288186905 0.213 7 8 
 i 21 182.25 4.5 15000 8.70274987883 0.213 7 8 
 i 21 182.5 4.5 15000 9.70274987883 0.213 7 8 
 i 21 182.75 4.5 15000 9.2288186905 0.213 7 8 
 i 21 183.0 4.5 15000 9.70274987883 0.213 7 8 
 i 21 183.25 4.5 15000 9.11778737811 0.213 7 8 
 i 21 183.5 4.5 15000 9.70274987883 0.213 7 8 
 i 21 183.75 4.5 15000 9.11778737811 0.213 7 8 
 i 21 184.0 4.5 15000 8.53282487739 0.213 7 8 
 i 21 184.25 4.5 15000 8.96578428466 0.213 7 8 
 i 21 184.75 4.5 15000 9.96578428466 0.213 7 8 
 i 21 20.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 20.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 21.08334 1 9000 9.05889368905 0.213 7 8 
 i 21 21.16667 1 9000 8.64385618977 0.213 7 8 
 i 21 21.33334 1 9000 8.47393118833 0.213 7 8 
 i 21 21.41667 1 9000 9.05889368905 0.213 7 8 
 i 21 21.50001 1 9000 8.47393118833 0.213 7 8 
 i 21 21.58334 1 9000 9.2108967825 0.213 7 8 
 i 21 21.66668 1 9000 8.64385618977 0.213 7 8 
 i 21 21.75001 1 9000 9.05889368905 0.213 7 8 
 i 21 21.91668 1 9000 8.88896868761 0.213 7 8 
 i 21 22.08335 1 9000 8.88896868761 0.213 7 8 
 i 21 22.25002 1 9000 8.88896868761 0.213 7 8 
 i 21 22.41669 1 9000 8.88896868761 0.213 7 8 
 i 21 22.58336 1 9000 8.70274987883 0.213 7 8 
 i 21 26.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 26.83334 1 9000 8.38082178394 0.213 7 8 
 i 21 26.91667 1 9000 8.79585928322 0.213 7 8 
 i 21 27.00001 1 9000 8.2108967825 0.213 7 8 
 i 21 27.08334 1 9000 8.79585928322 0.213 7 8 
 i 21 27.16667 1 9000 8.2108967825 0.213 7 8 
 i 21 27.16668 1 9000 8.38082178394 0.213 7 8 
 i 21 27.25001 1 9000 8.79585928322 0.213 7 8 
 i 21 27.33335 1 9000 8.53282487739 0.213 7 8 
 i 21 27.41667 1 9000 8.64385618977 0.213 7 8 
 i 21 27.41668 1 9000 8.64385618977 0.213 7 8 
 i 21 27.50002 1 9000 8.38082178394 0.213 7 8 
 i 21 27.58334 1 9000 8.79585928322 0.213 7 8 
 i 21 27.58335 1 9000 8.64385618977 0.213 7 8 
 i 21 27.66669 1 9000 8.38082178394 0.213 7 8 
 i 21 27.75002 1 9000 8.79585928322 0.213 7 8 
 i 21 27.83336 1 9000 8.38082178394 0.213 7 8 
 i 21 27.91669 1 9000 8.96578428466 0.213 7 8 
 i 21 28.00003 1 9000 8.38082178394 0.213 7 8 
 i 21 28.08336 1 9000 8.79585928322 0.213 7 8 
 i 21 28.1667 1 9000 8.2108967825 0.213 7 8 
 i 21 28.25003 1 9000 8.96578428466 0.213 7 8 
 i 21 28.33337 1 9000 8.2108967825 0.213 7 8 
 i 21 28.4167 1 9000 8.79585928322 0.213 7 8 
 i 21 28.50004 1 9000 8.38082178394 0.213 7 8 
 i 21 28.58337 1 9000 8.79585928322 0.213 7 8 
 i 21 28.66671 1 9000 8.2108967825 0.213 7 8 
 i 21 28.75004 1 9000 8.79585928322 0.213 7 8 
 i 21 28.83338 1 9000 8.05889368905 0.213 7 8 
 i 21 28.91671 1 9000 8.79585928322 0.213 7 8 
 i 21 29.00005 1 9000 8.2108967825 0.213 7 8 
 i 21 29.08338 1 9000 8.64385618977 0.213 7 8 
 i 21 29.16672 1 9000 8.05889368905 0.213 7 8 
 i 21 29.25005 1 9000 8.64385618977 0.213 7 8 
 i 21 29.41672 1 9000 8.64385618977 0.213 7 8 
 i 21 30.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 30.83334 1 9000 8.05889368905 0.213 7 8 
 i 21 30.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 31.00001 1 9000 8.05889368905 0.213 7 8 
 i 21 31.08334 1 9000 8.88896868761 0.213 7 8 
 i 21 31.16667 1 9000 8.64385618977 0.213 7 8 
 i 21 31.16668 1 9000 8.05889368905 0.213 7 8 
 i 21 31.25001 1 9000 8.88896868761 0.213 7 8 
 i 21 31.33334 1 9000 8.64385618977 0.213 7 8 
 i 21 31.41667 1 9000 9.05889368905 0.213 7 8 
 i 21 31.41668 1 9000 9.05889368905 0.213 7 8 
 i 21 31.50001 1 9000 8.64385618977 0.213 7 8 
 i 21 31.58334 1 9000 9.05889368905 0.213 7 8 
 i 21 31.58335 1 9000 8.88896868761 0.213 7 8 
 i 21 31.66668 1 9000 8.47393118833 0.213 7 8 
 i 21 31.75001 1 9000 9.05889368905 0.213 7 8 
 i 21 31.75002 1 9000 9.05889368905 0.213 7 8 
 i 21 31.83335 1 9000 8.47393118833 0.213 7 8 
 i 21 31.91668 1 9000 9.05889368905 0.213 7 8 
 i 21 31.91669 1 9000 8.88896868761 0.213 7 8 
 i 21 32.00002 1 9000 8.64385618977 0.213 7 8 
 i 21 32.08335 1 9000 9.05889368905 0.213 7 8 
 i 21 32.08336 1 9000 8.88896868761 0.213 7 8 
 i 21 32.16669 1 9000 8.47393118833 0.213 7 8 
 i 21 32.25002 1 9000 8.88896868761 0.213 7 8 
 i 21 32.33336 1 9000 8.64385618977 0.213 7 8 
 i 21 32.41669 1 9000 8.88896868761 0.213 7 8 
 i 21 32.58336 1 9000 9.05889368905 0.213 7 8 
 i 21 32.75003 1 9000 8.88896868761 0.213 7 8 
 i 21 32.9167 1 9000 9.05889368905 0.213 7 8 
 i 21 33.08337 1 9000 8.88896868761 0.213 7 8 
 i 21 33.25004 1 9000 8.88896868761 0.213 7 8 
 i 21 33.41671 1 9000 8.88896868761 0.213 7 8 
 i 21 33.58338 1 9000 8.88896868761 0.213 7 8 
 i 21 33.75005 1 9000 8.88896868761 0.213 7 8 
 i 21 33.91672 1 9000 8.70274987883 0.213 7 8 
 i 21 36.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 36.91667 1 9000 8.79585928322 0.213 7 8 
 i 21 37.08334 1 9000 8.64385618977 0.213 7 8 
 i 21 37.16667 1 9000 8.2108967825 0.213 7 8 
 i 21 37.33334 1 9000 8.05889368905 0.213 7 8 
 i 21 37.41667 1 9000 11.6438561898 0.213 7 8 
 i 21 37.50001 1 9000 11.8889686876 0.213 7 8 
 i 21 37.58334 1 9000 11.6438561898 0.213 7 8 
 i 21 37.66668 1 9000 11.8889686876 0.213 7 8 
 i 21 37.75001 1 9000 11.4739311883 0.213 7 8 
 i 21 37.91668 1 9000 11.4739311883 0.213 7 8 
 i 21 40.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 40.83334 1 9000 11.8889686876 0.213 7 8 
 i 21 40.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 41.00001 1 9000 8.05889368905 0.213 7 8 
 i 21 41.08334 1 9000 9.05889368905 0.213 7 8 
 i 21 41.16667 1 9000 8.64385618977 0.213 7 8 
 i 21 41.16668 1 9000 8.2108967825 0.213 7 8 
 i 21 41.25001 1 9000 9.2108967825 0.213 7 8 
 i 21 41.33335 1 9000 8.05889368905 0.213 7 8 
 i 21 41.41667 1 9000 9.05889368905 0.213 7 8 
 i 21 41.41668 1 9000 9.05889368905 0.213 7 8 
 i 21 41.50002 1 9000 8.05889368905 0.213 7 8 
 i 21 41.58334 1 9000 9.05889368905 0.213 7 8 
 i 21 41.58335 1 9000 8.88896868761 0.213 7 8 
 i 21 41.66667 1 9000 8.47393118833 0.213 7 8 
 i 21 41.66669 1 9000 8.05889368905 0.213 7 8 
 i 21 41.75002 1 9000 9.05889368905 0.213 7 8 
 i 21 41.83334 1 9000 8.2288186905 0.213 7 8 
 i 21 41.83336 1 9000 8.05889368905 0.213 7 8 
 i 21 41.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 41.91669 1 9000 8.88896868761 0.213 7 8 
 i 21 42.08334 1 9000 9.05889368905 0.213 7 8 
 i 21 42.08336 1 9000 8.88896868761 0.213 7 8 
 i 21 42.16667 1 9000 9.64385618977 0.213 7 8 
 i 21 42.25001 1 9000 9.2108967825 0.213 7 8 
 i 21 42.25003 1 9000 8.88896868761 0.213 7 8 
 i 21 42.33334 1 9000 9.47393118833 0.213 7 8 
 i 21 42.41668 1 9000 9.05889368905 0.213 7 8 
 i 21 42.4167 1 9000 8.88896868761 0.213 7 8 
 i 21 42.50001 1 9000 9.47393118833 0.213 7 8 
 i 21 42.58337 1 9000 8.70274987883 0.213 7 8 
 i 21 42.66668 1 9000 9.47393118833 0.213 7 8 
 i 21 42.75004 1 9000 8.70274987883 0.213 7 8 
 i 21 42.83335 1 9000 9.47393118833 0.213 7 8 
 i 21 42.91671 1 9000 8.88896868761 0.213 7 8 
 i 21 43.00002 1 9000 9.2288186905 0.213 7 8 
 i 21 43.08338 1 9000 9.05889368905 0.213 7 8 
 i 21 43.16669 1 9000 9.11778737811 0.213 7 8 
 i 21 43.25005 1 9000 8.88896868761 0.213 7 8 
 i 21 43.33336 1 9000 9.11778737811 0.213 7 8 
 i 21 43.41672 1 9000 9.05889368905 0.213 7 8 
 i 21 46.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 46.83334 1 9000 8.05889368905 0.213 7 8 
 i 21 46.91667 1 9000 8.64385618977 0.213 7 8 
 i 21 47.00001 1 9000 8.2108967825 0.213 7 8 
 i 21 47.16667 1 9000 9.64385618977 0.213 7 8 
 i 21 47.16668 1 9000 8.05889368905 0.213 7 8 
 i 21 47.33335 1 9000 8.05889368905 0.213 7 8 
 i 21 47.41667 1 9000 9.2108967825 0.213 7 8 
 i 21 47.50002 1 9000 8.05889368905 0.213 7 8 
 i 21 47.58334 1 9000 9.2108967825 0.213 7 8 
 i 21 47.66667 1 9000 9.64385618977 0.213 7 8 
 i 21 47.66669 1 9000 8.05889368905 0.213 7 8 
 i 21 47.83334 1 9000 9.47393118833 0.213 7 8 
 i 21 47.83336 1 9000 8.05889368905 0.213 7 8 
 i 21 47.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 48.00001 1 9000 9.64385618977 0.213 7 8 
 i 21 48.00003 1 9000 11.8889686876 0.213 7 8 
 i 21 48.08334 1 9000 9.05889368905 0.213 7 8 
 i 21 48.16667 1 9000 8.47393118833 0.213 7 8 
 i 21 48.16668 1 9000 9.47393118833 0.213 7 8 
 i 21 48.1667 1 9000 11.8889686876 0.213 7 8 
 i 21 48.25001 1 9000 9.05889368905 0.213 7 8 
 i 21 48.33334 1 9000 8.2288186905 0.213 7 8 
 i 21 48.33337 1 9000 8.05889368905 0.213 7 8 
 i 21 48.41668 1 9000 9.05889368905 0.213 7 8 
 i 21 48.50001 1 9000 8.11778737811 0.213 7 8 
 i 21 48.50004 1 9000 11.8889686876 0.213 7 8 
 i 21 48.58335 1 9000 8.88896868761 0.213 7 8 
 i 21 48.66668 1 9000 8.11778737811 0.213 7 8 
 i 21 48.66671 1 9000 8.05889368905 0.213 7 8 
 i 21 48.75002 1 9000 8.88896868761 0.213 7 8 
 i 21 48.83335 1 9000 8.11778737811 0.213 7 8 
 i 21 48.83338 1 9000 11.8889686876 0.213 7 8 
 i 21 48.91669 1 9000 9.05889368905 0.213 7 8 
 i 21 49.00002 1 9000 8.11778737811 0.213 7 8 
 i 21 49.00005 1 9000 11.8889686876 0.213 7 8 
 i 21 49.08336 1 9000 8.88896868761 0.213 7 8 
 i 21 49.16669 1 9000 11.9657842847 0.213 7 8 
 i 21 49.16672 1 9000 11.8889686876 0.213 7 8 
 i 21 49.33336 1 9000 11.9657842847 0.213 7 8 
 i 21 49.50003 1 9000 8.11778737811 0.213 7 8 
 i 21 49.6667 1 9000 11.9657842847 0.213 7 8 
 i 21 49.83337 1 9000 8.11778737811 0.213 7 8 
 i 21 50.00004 1 9000 8.2288186905 0.213 7 8 
 i 21 50.16671 1 9000 8.11778737811 0.213 7 8 
 i 21 50.33338 1 9000 8.11778737811 0.213 7 8 
 i 21 50.50005 1 9000 8.11778737811 0.213 7 8 
 i 21 50.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 50.66672 1 9000 8.11778737811 0.213 7 8 
 i 21 50.83334 1 9000 8.05889368905 0.213 7 8 
 i 21 50.91667 1 9000 11.4739311883 0.213 7 8 
 i 21 51.00001 1 9000 8.2108967825 0.213 7 8 
 i 21 51.16667 1 9000 11.8889686876 0.213 7 8 
 i 21 51.16668 1 9000 8.05889368905 0.213 7 8 
 i 21 51.33334 1 9000 11.8889686876 0.213 7 8 
 i 21 51.33335 1 9000 11.8889686876 0.213 7 8 
 i 21 51.41667 1 9000 8.88896868761 0.213 7 8 
 i 21 51.50002 1 9000 8.05889368905 0.213 7 8 
 i 21 51.58334 1 9000 8.70274987883 0.213 7 8 
 i 21 51.66667 1 9000 8.47393118833 0.213 7 8 
 i 21 51.66669 1 9000 11.8889686876 0.213 7 8 
 i 21 51.75001 1 9000 8.70274987883 0.213 7 8 
 i 21 51.83334 1 9000 8.2288186905 0.213 7 8 
 i 21 51.83336 1 9000 11.8889686876 0.213 7 8 
 i 21 51.91667 1 9000 8.88896868761 0.213 7 8 
 i 21 51.91668 1 9000 8.70274987883 0.213 7 8 
 i 21 52.00001 1 9000 8.47393118833 0.213 7 8 
 i 21 52.00003 1 9000 11.8889686876 0.213 7 8 
 i 21 52.08334 1 9000 8.88896868761 0.213 7 8 
 i 21 52.16667 1 9000 9.2288186905 0.213 7 8 
 i 21 52.16668 1 9000 8.2288186905 0.213 7 8 
 i 21 52.1667 1 9000 11.8889686876 0.213 7 8 
 i 21 52.25001 1 9000 9.05889368905 0.213 7 8 
 i 21 52.33334 1 9000 9.2288186905 0.213 7 8 
 i 21 52.33335 1 9000 8.2288186905 0.213 7 8 
 i 21 52.33337 1 9000 11.7027498788 0.213 7 8 
 i 21 52.41668 1 9000 8.88896868761 0.213 7 8 
 i 21 52.50001 1 9000 9.11778737811 0.213 7 8 
 i 21 52.50002 1 9000 8.2288186905 0.213 7 8 
 i 21 52.50004 1 9000 11.7027498788 0.213 7 8 
 i 21 52.58335 1 9000 9.05889368905 0.213 7 8 
 i 21 52.66668 1 9000 9.11778737811 0.213 7 8 
 i 21 52.66669 1 9000 8.2288186905 0.213 7 8 
 i 21 52.66671 1 9000 11.8889686876 0.213 7 8 
 i 21 52.75002 1 9000 8.88896868761 0.213 7 8 
 i 21 52.83335 1 9000 9.2288186905 0.213 7 8 
 i 21 52.83336 1 9000 8.11778737811 0.213 7 8 
 i 21 52.83338 1 9000 8.05889368905 0.213 7 8 
 i 21 52.91669 1 9000 8.88896868761 0.213 7 8 
 i 21 53.00002 1 9000 9.11778737811 0.213 7 8 
 i 21 53.00005 1 9000 11.8889686876 0.213 7 8 
 i 21 53.08336 1 9000 8.88896868761 0.213 7 8 
 i 21 53.16669 1 9000 9.2288186905 0.213 7 8 
 i 21 53.16672 1 9000 8.05889368905 0.213 7 8 
 i 21 53.33336 1 9000 9.11778737811 0.213 7 8 
 i 21 53.50003 1 9000 9.11778737811 0.213 7 8 
 i 21 53.6667 1 9000 9.11778737811 0.213 7 8 
 i 21 53.83337 1 9000 9.11778737811 0.213 7 8 
 i 21 54.00004 1 9000 9.11778737811 0.213 7 8 
 i 21 54.16671 1 9000 8.96578428466 0.213 7 8 
 i 21 54.33338 1 9000 8.96578428466 0.213 7 8 
 i 21 54.50005 1 9000 9.11778737811 0.213 7 8 
 i 21 54.66672 1 9000 8.96578428466 0.213 7 8 
 i 21 56.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 56.91667 1 9000 8.79585928322 0.213 7 8 
 i 21 57.08334 1 9000 8.79585928322 0.213 7 8 
 i 21 57.16667 1 9000 8.2108967825 0.213 7 8 
 i 21 57.33334 1 9000 8.2108967825 0.213 7 8 
 i 21 57.41667 1 9000 8.64385618977 0.213 7 8 
 i 21 57.50001 1 9000 8.2108967825 0.213 7 8 
 i 21 57.58334 1 9000 8.79585928322 0.213 7 8 
 i 21 57.66667 1 9000 9.64385618977 0.213 7 8 
 i 21 57.66668 1 9000 8.05889368905 0.213 7 8 
 i 21 57.75001 1 9000 8.64385618977 0.213 7 8 
 i 21 57.83334 1 9000 9.47393118833 0.213 7 8 
 i 21 57.91667 1 9000 9.2108967825 0.213 7 8 
 i 21 57.91668 1 9000 8.79585928322 0.213 7 8 
 i 21 58.00001 1 9000 9.47393118833 0.213 7 8 
 i 21 58.08334 1 9000 9.38082178394 0.213 7 8 
 i 21 58.16667 1 9000 8.79585928322 0.213 7 8 
 i 21 58.16668 1 9000 9.47393118833 0.213 7 8 
 i 21 58.25001 1 9000 9.53282487739 0.213 7 8 
 i 21 58.33335 1 9000 9.47393118833 0.213 7 8 
 i 21 58.41668 1 9000 9.38082178394 0.213 7 8 
 i 21 58.50002 1 9000 9.2288186905 0.213 7 8 
 i 21 58.58335 1 9000 9.38082178394 0.213 7 8 
 i 21 58.66669 1 9000 9.2288186905 0.213 7 8 
 i 21 58.75002 1 9000 9.38082178394 0.213 7 8 
 i 21 58.83336 1 9000 9.47393118833 0.213 7 8 
 i 21 58.91669 1 9000 9.38082178394 0.213 7 8 
 i 21 59.08336 1 9000 9.2108967825 0.213 7 8 
 i 21 59.25003 1 9000 9.2108967825 0.213 7 8 
 i 21 59.4167 1 9000 9.38082178394 0.213 7 8 
 i 21 59.58337 1 9000 9.2108967825 0.213 7 8 
 i 21 59.75004 1 9000 9.05889368905 0.213 7 8 
 i 21 59.91671 1 9000 9.2108967825 0.213 7 8 
 i 21 60.08338 1 9000 9.05889368905 0.213 7 8 
 i 21 60.25005 1 9000 9.05889368905 0.213 7 8 
 i 21 60.41672 1 9000 9.05889368905 0.213 7 8 
 i 21 60.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 60.83334 1 9000 8.05889368905 0.213 7 8 
 i 21 60.91667 1 9000 11.4739311883 0.213 7 8 
 i 21 61.08334 1 9000 11.6438561898 0.213 7 8 
 i 21 61.16667 1 9000 8.05889368905 0.213 7 8 
 i 21 61.33334 1 9000 8.2108967825 0.213 7 8 
 i 21 61.41667 1 9000 11.4739311883 0.213 7 8 
 i 21 61.50001 1 9000 8.05889368905 0.213 7 8 
 i 21 61.58334 1 9000 11.4739311883 0.213 7 8 
 i 21 61.66667 1 9000 11.8889686876 0.213 7 8 
 i 21 61.66668 1 9000 8.05889368905 0.213 7 8 
 i 21 61.75001 1 9000 11.2288186905 0.213 7 8 
 i 21 61.83334 1 9000 11.8889686876 0.213 7 8 
 i 21 61.91667 1 9000 8.88896868761 0.213 7 8 
 i 21 61.91668 1 9000 11.2288186905 0.213 7 8 
 i 21 62.00001 1 9000 11.8889686876 0.213 7 8 
 i 21 62.08335 1 9000 11.2288186905 0.213 7 8 
 i 21 62.16667 1 9000 9.88896868761 0.213 7 8 
 i 21 62.16668 1 9000 11.8889686876 0.213 7 8 
 i 21 62.25002 1 9000 11.4739311883 0.213 7 8 
 i 21 62.33335 1 9000 11.7027498788 0.213 7 8 
 i 21 62.41667 1 9000 9.47393118833 0.213 7 8 
 i 21 62.41669 1 9000 11.2288186905 0.213 7 8 
 i 21 62.50002 1 9000 11.5328248774 0.213 7 8 
 i 21 62.58334 1 9000 9.64385618977 0.213 7 8 
 i 21 62.58336 1 9000 11.4739311883 0.213 7 8 
 i 21 62.66667 1 9000 9.88896868761 0.213 7 8 
 i 21 62.66669 1 9000 11.5328248774 0.213 7 8 
 i 21 62.83334 1 9000 9.88896868761 0.213 7 8 
 i 21 62.83336 1 9000 11.7027498788 0.213 7 8 
 i 21 62.91667 1 9000 9.2288186905 0.213 7 8 
 i 21 63.00001 1 9000 9.88896868761 0.213 7 8 
 i 21 63.00003 1 9000 11.5328248774 0.213 7 8 
 i 21 63.08334 1 9000 9.11778737811 0.213 7 8 
 i 21 63.16667 1 9000 9.88896868761 0.213 7 8 
 i 21 63.16668 1 9000 9.88896868761 0.213 7 8 
 i 21 63.1667 1 9000 11.7027498788 0.213 7 8 
 i 21 63.25001 1 9000 9.11778737811 0.213 7 8 
 i 21 63.33334 1 9000 9.88896868761 0.213 7 8 
 i 21 63.33337 1 9000 11.5328248774 0.213 7 8 
 i 21 63.41668 1 9000 9.2288186905 0.213 7 8 
 i 21 63.50001 1 9000 9.88896868761 0.213 7 8 
 i 21 63.50004 1 9000 11.5328248774 0.213 7 8 
 i 21 63.58335 1 9000 9.11778737811 0.213 7 8 
 i 21 63.66667 1 9000 9.2288186905 0.213 7 8 
 i 21 63.66668 1 9000 9.70274987883 0.213 7 8 
 i 21 63.66671 1 9000 11.5328248774 0.213 7 8 
 i 21 63.75002 1 9000 9.2288186905 0.213 7 8 
 i 21 63.83334 1 9000 9.47393118833 0.213 7 8 
 i 21 63.83335 1 9000 9.70274987883 0.213 7 8 
 i 21 63.83338 1 9000 11.5328248774 0.213 7 8 
 i 21 63.91669 1 9000 9.11778737811 0.213 7 8 
 i 21 64.00001 1 9000 9.64385618977 0.213 7 8 
 i 21 64.00002 1 9000 9.88896868761 0.213 7 8 
 i 21 64.00005 1 9000 11.5328248774 0.213 7 8 
 i 21 64.08336 1 9000 9.11778737811 0.213 7 8 
 i 21 64.16668 1 9000 9.47393118833 0.213 7 8 
 i 21 64.16669 1 9000 9.70274987883 0.213 7 8 
 i 21 64.16672 1 9000 11.3808217839 0.213 7 8 
 i 21 64.33335 1 9000 9.47393118833 0.213 7 8 
 i 21 64.33336 1 9000 9.88896868761 0.213 7 8 
 i 21 64.50002 1 9000 9.47393118833 0.213 7 8 
 i 21 64.50003 1 9000 9.70274987883 0.213 7 8 
 i 21 64.66669 1 9000 9.47393118833 0.213 7 8 
 i 21 64.6667 1 9000 9.53282487739 0.213 7 8 
 i 21 64.83336 1 9000 9.2288186905 0.213 7 8 
 i 21 64.83337 1 9000 9.53282487739 0.213 7 8 
 i 21 65.00003 1 9000 9.2288186905 0.213 7 8 
 i 21 65.00004 1 9000 9.53282487739 0.213 7 8 
 i 21 65.1667 1 9000 9.47393118833 0.213 7 8 
 i 21 65.16671 1 9000 9.53282487739 0.213 7 8 
 i 21 65.33337 1 9000 9.2288186905 0.213 7 8 
 i 21 65.33338 1 9000 9.38082178394 0.213 7 8 
 i 21 65.50004 1 9000 9.11778737811 0.213 7 8 
 i 21 65.50005 1 9000 9.38082178394 0.213 7 8 
 i 21 65.66671 1 9000 9.2288186905 0.213 7 8 
 i 21 65.66672 1 9000 9.53282487739 0.213 7 8 
 i 21 65.83338 1 9000 9.11778737811 0.213 7 8 
 i 21 66.00005 1 9000 9.11778737811 0.213 7 8 
 i 21 66.16672 1 9000 9.11778737811 0.213 7 8 
 i 21 66.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 67.16667 1 9000 8.64385618977 0.213 7 8 
 i 21 67.33334 1 9000 8.64385618977 0.213 7 8 
 i 21 67.41667 1 9000 9.64385618977 0.213 7 8 
 i 21 67.58334 1 9000 9.79585928322 0.213 7 8 
 i 21 67.66667 1 9000 9.2108967825 0.213 7 8 
 i 21 67.75001 1 9000 9.64385618977 0.213 7 8 
 i 21 67.83334 1 9000 9.2108967825 0.213 7 8 
 i 21 67.91667 1 9000 9.64385618977 0.213 7 8 
 i 21 67.91668 1 9000 9.79585928322 0.213 7 8 
 i 21 68.00001 1 9000 9.2108967825 0.213 7 8 
 i 21 68.08334 1 9000 9.79585928322 0.213 7 8 
 i 21 68.16667 1 9000 9.05889368905 0.213 7 8 
 i 21 68.16668 1 9000 9.2108967825 0.213 7 8 
 i 21 68.25001 1 9000 9.64385618977 0.213 7 8 
 i 21 68.33334 1 9000 9.2108967825 0.213 7 8 
 i 21 68.33335 1 9000 9.05889368905 0.213 7 8 
 i 21 68.41667 1 9000 9.64385618977 0.213 7 8 
 i 21 68.41668 1 9000 9.64385618977 0.213 7 8 
 i 21 68.50001 1 9000 9.05889368905 0.213 7 8 
 i 21 68.50002 1 9000 9.05889368905 0.213 7 8 
 i 21 68.58335 1 9000 9.64385618977 0.213 7 8 
 i 21 68.66667 1 9000 9.05889368905 0.213 7 8 
 i 21 68.66668 1 9000 9.2108967825 0.213 7 8 
 i 21 68.66669 1 9000 9.05889368905 0.213 7 8 
 i 21 68.75002 1 9000 9.64385618977 0.213 7 8 
 i 21 68.83334 1 9000 9.05889368905 0.213 7 8 
 i 21 68.83335 1 9000 9.05889368905 0.213 7 8 
 i 21 68.83336 1 9000 9.2108967825 0.213 7 8 
 i 21 68.91667 1 9000 8.47393118833 0.213 7 8 
 i 21 68.91669 1 9000 9.47393118833 0.213 7 8 
 i 21 69.00002 1 9000 9.05889368905 0.213 7 8 
 i 21 69.08334 1 9000 8.47393118833 0.213 7 8 
 i 21 69.08336 1 9000 9.2288186905 0.213 7 8 
 i 21 69.16667 1 9000 8.88896868761 0.213 7 8 
 i 21 69.16669 1 9000 9.05889368905 0.213 7 8 
 i 21 69.25001 1 9000 8.64385618977 0.213 7 8 
 i 21 69.33334 1 9000 8.70274987883 0.213 7 8 
 i 21 69.33336 1 9000 9.05889368905 0.213 7 8 
 i 21 69.41667 1 9000 9.88896868761 0.213 7 8 
 i 21 69.41668 1 9000 8.47393118833 0.213 7 8 
 i 21 69.50001 1 9000 8.70274987883 0.213 7 8 
 i 21 69.50003 1 9000 9.05889368905 0.213 7 8 
 i 21 69.58334 1 9000 9.88896868761 0.213 7 8 
 i 21 69.66667 1 9000 9.47393118833 0.213 7 8 
 i 21 69.66668 1 9000 8.70274987883 0.213 7 8 
 i 21 69.6667 1 9000 8.88896868761 0.213 7 8 
 i 21 69.75001 1 9000 9.70274987883 0.213 7 8 
 i 21 69.83334 1 9000 9.47393118833 0.213 7 8 
 i 21 69.83337 1 9000 8.88896868761 0.213 7 8 
 i 21 69.91668 1 9000 9.70274987883 0.213 7 8 
 i 21 70.00001 1 9000 9.47393118833 0.213 7 8 
 i 21 70.00004 1 9000 9.05889368905 0.213 7 8 
 i 21 70.08335 1 9000 9.88896868761 0.213 7 8 
 i 21 70.16668 1 9000 9.47393118833 0.213 7 8 
 i 21 70.16671 1 9000 8.88896868761 0.213 7 8 
 i 21 70.25002 1 9000 9.70274987883 0.213 7 8 
 i 21 70.33335 1 9000 9.2288186905 0.213 7 8 
 i 21 70.33338 1 9000 9.05889368905 0.213 7 8 
 i 21 70.41667 1 9000 8.05889368905 0.213 7 8 
 i 21 70.41669 1 9000 9.88896868761 0.213 7 8 
 i 21 70.50002 1 9000 9.2288186905 0.213 7 8 
 i 21 70.50005 1 9000 8.88896868761 0.213 7 8 
 i 21 70.58336 1 9000 9.70274987883 0.213 7 8 
 i 21 70.66669 1 9000 9.47393118833 0.213 7 8 
 i 21 70.66672 1 9000 8.88896868761 0.213 7 8 
 i 21 70.83336 1 9000 9.2288186905 0.213 7 8 
 i 21 70.91667 1 9000 11.4739311883 0.213 7 8 
 i 21 71.00003 1 9000 9.47393118833 0.213 7 8 
 i 21 71.08334 1 9000 11.2288186905 0.213 7 8 
 i 21 71.1667 1 9000 9.64385618977 0.213 7 8 
 i 21 71.33337 1 9000 9.47393118833 0.213 7 8 
 i 21 71.41667 1 9000 8.05889368905 0.213 7 8 
 i 21 71.50004 1 9000 9.47393118833 0.213 7 8 
 i 21 71.58334 1 9000 11.8889686876 0.213 7 8 
 i 21 71.66667 1 9000 8.64385618977 0.213 7 8 
 i 21 71.66671 1 9000 9.47393118833 0.213 7 8 
 i 21 71.83334 1 9000 8.64385618977 0.213 7 8 
 i 21 71.83338 1 9000 9.47393118833 0.213 7 8 
 i 21 71.91667 1 9000 8.05889368905 0.213 7 8 
 i 21 72.00001 1 9000 8.64385618977 0.213 7 8 
 i 21 72.00005 1 9000 9.2288186905 0.213 7 8 
 i 21 72.08334 1 9000 8.2108967825 0.213 7 8 
 i 21 72.16667 1 9000 8.47393118833 0.213 7 8 
 i 21 72.16668 1 9000 8.47393118833 0.213 7 8 
 i 21 72.16672 1 9000 9.2288186905 0.213 7 8 
 i 21 72.25001 1 9000 8.38082178394 0.213 7 8 
 i 21 72.33334 1 9000 8.2288186905 0.213 7 8 
 i 21 72.41667 1 9000 9.47393118833 0.213 7 8 
 i 21 72.41668 1 9000 8.2108967825 0.213 7 8 
 i 21 72.50001 1 9000 8.2288186905 0.213 7 8 
 i 21 72.58335 1 9000 8.38082178394 0.213 7 8 
 i 21 72.66667 1 9000 9.05889368905 0.213 7 8 
 i 21 72.66668 1 9000 8.2288186905 0.213 7 8 
 i 21 72.75002 1 9000 8.2108967825 0.213 7 8 
 i 21 72.83335 1 9000 8.47393118833 0.213 7 8 
 i 21 72.91667 1 9000 9.47393118833 0.213 7 8 
 i 21 72.91669 1 9000 8.2108967825 0.213 7 8 
 i 21 73.00002 1 9000 8.2288186905 0.213 7 8 
 i 21 73.08334 1 9000 9.47393118833 0.213 7 8 
 i 21 73.08336 1 9000 8.2108967825 0.213 7 8 
 i 21 73.16667 1 9000 8.88896868761 0.213 7 8 
 i 21 73.16669 1 9000 8.47393118833 0.213 7 8 
 i 21 73.33334 1 9000 8.88896868761 0.213 7 8 
 i 21 73.33336 1 9000 8.2288186905 0.213 7 8 
 i 21 73.41667 1 9000 8.2288186905 0.213 7 8 
 i 21 73.50001 1 9000 8.70274987883 0.213 7 8 
 i 21 73.50003 1 9000 8.2288186905 0.213 7 8 
 i 21 73.58334 1 9000 8.11778737811 0.213 7 8 
 i 21 73.66667 1 9000 8.88896868761 0.213 7 8 
 i 21 73.66668 1 9000 8.70274987883 0.213 7 8 
 i 21 73.6667 1 9000 8.2288186905 0.213 7 8 
 i 21 73.75001 1 9000 8.2288186905 0.213 7 8 
 i 21 73.83334 1 9000 8.88896868761 0.213 7 8 
 i 21 73.83337 1 9000 8.2288186905 0.213 7 8 
 i 21 73.91668 1 9000 8.11778737811 0.213 7 8 
 i 21 74.00001 1 9000 9.05889368905 0.213 7 8 
 i 21 74.00004 1 9000 8.11778737811 0.213 7 8 
 i 21 74.08335 1 9000 8.11778737811 0.213 7 8 
 i 21 74.16668 1 9000 8.88896868761 0.213 7 8 
 i 21 74.16671 1 9000 11.9657842847 0.213 7 8 
 i 21 74.25002 1 9000 8.11778737811 0.213 7 8 
 i 21 74.33335 1 9000 9.05889368905 0.213 7 8 
 i 21 74.33338 1 9000 11.9657842847 0.213 7 8 
 i 21 74.41669 1 9000 8.11778737811 0.213 7 8 
 i 21 74.50002 1 9000 8.88896868761 0.213 7 8 
 i 21 74.50005 1 9000 8.11778737811 0.213 7 8 
 i 21 74.58336 1 9000 8.11778737811 0.213 7 8 
 i 21 74.66669 1 9000 8.88896868761 0.213 7 8 
 i 21 74.66672 1 9000 11.9657842847 0.213 7 8 
 i 21 74.83336 1 9000 8.88896868761 0.213 7 8 
 i 21 75.00003 1 9000 8.88896868761 0.213 7 8 
 i 21 75.1667 1 9000 8.88896868761 0.213 7 8 
 i 21 75.33337 1 9000 8.70274987883 0.213 7 8 
 i 21 75.50004 1 9000 8.70274987883 0.213 7 8 
 i 21 75.66671 1 9000 8.88896868761 0.213 7 8 
 i 21 75.83338 1 9000 8.70274987883 0.213 7 8 
 i 21 76.00005 1 9000 8.88896868761 0.213 7 8 
 i 21 76.16672 1 9000 8.70274987883 0.213 7 8 
 i 21 76.41667 1 9000 8.2108967825 0.213 7 8 
 i 21 76.58334 1 9000 8.2108967825 0.213 7 8 
 i 21 76.66667 1 9000 8.64385618977 0.213 7 8 
 i 21 76.75001 1 9000 8.2108967825 0.213 7 8 
 i 21 76.91668 1 9000 8.2108967825 0.213 7 8 
 i 21 77.08335 1 9000 8.05889368905 0.213 7 8 
 i 21 77.16667 1 9000 9.64385618977 0.213 7 8 
 i 21 77.25002 1 9000 8.05889368905 0.213 7 8 
 i 21 77.33334 1 9000 9.47393118833 0.213 7 8 
 i 21 77.41669 1 9000 8.2108967825 0.213 7 8 
 i 21 77.58336 1 9000 8.05889368905 0.213 7 8 
 i 21 77.66667 1 9000 9.2108967825 0.213 7 8 
 i 21 77.75003 1 9000 8.2108967825 0.213 7 8 
 i 21 77.83334 1 9000 9.05889368905 0.213 7 8 
 i 21 77.91667 1 9000 9.64385618977 0.213 7 8 
 i 21 77.9167 1 9000 8.38082178394 0.213 7 8 
 i 21 78.00001 1 9000 9.05889368905 0.213 7 8 
 i 21 78.08334 1 9000 9.47393118833 0.213 7 8 
 i 21 78.08337 1 9000 8.2108967825 0.213 7 8 
 i 21 78.16667 1 9000 10.0588936891 0.213 7 8 
 i 21 78.16668 1 9000 9.05889368905 0.213 7 8 
 i 21 78.25001 1 9000 9.47393118833 0.213 7 8 
 i 21 78.25004 1 9000 8.2108967825 0.213 7 8 
 i 21 78.33334 1 9000 10.0588936891 0.213 7 8 
 i 21 78.41667 1 9000 9.47393118833 0.213 7 8 
 i 21 78.41668 1 9000 9.64385618977 0.213 7 8 
 i 21 78.41671 1 9000 8.2108967825 0.213 7 8 
 i 21 78.50001 1 9000 10.0588936891 0.213 7 8 
 i 21 78.58334 1 9000 9.2288186905 0.213 7 8 
 i 21 78.58335 1 9000 9.79585928322 0.213 7 8 
 i 21 78.58338 1 9000 8.2108967825 0.213 7 8 
 i 21 78.66667 1 9000 10.0588936891 0.213 7 8 
 i 21 78.66668 1 9000 9.88896868761 0.213 7 8 
 i 21 78.75001 1 9000 9.2288186905 0.213 7 8 
 i 21 78.75002 1 9000 9.64385618977 0.213 7 8 
 i 21 78.75005 1 9000 8.05889368905 0.213 7 8 
 i 21 78.83335 1 9000 9.88896868761 0.213 7 8 
 i 21 78.91667 1 9000 9.47393118833 0.213 7 8 
 i 21 78.91668 1 9000 9.2288186905 0.213 7 8 
 i 21 78.91669 1 9000 9.79585928322 0.213 7 8 
 i 21 78.91672 1 9000 8.05889368905 0.213 7 8 
 i 21 79.00002 1 9000 9.88896868761 0.213 7 8 
 i 21 79.08334 1 9000 9.64385618977 0.213 7 8 
 i 21 79.08335 1 9000 9.2288186905 0.213 7 8 
 i 21 79.08336 1 9000 9.64385618977 0.213 7 8 
 i 21 79.16667 1 9000 9.88896868761 0.213 7 8 
 i 21 79.16669 1 9000 10.0588936891 0.213 7 8 
 i 21 79.25002 1 9000 9.11778737811 0.213 7 8 
 i 21 79.33334 1 9000 10.0588936891 0.213 7 8 
 i 21 79.33336 1 9000 9.88896868761 0.213 7 8 
 i 21 79.41667 1 9000 10.8889686876 0.213 7 8 
 i 21 79.41669 1 9000 8.96578428466 0.213 7 8 
 i 21 79.50001 1 9000 9.88896868761 0.213 7 8 
 i 21 79.58334 1 9000 10.8889686876 0.213 7 8 
 i 21 79.58336 1 9000 8.96578428466 0.213 7 8 
 i 21 79.66667 1 9000 10.4739311883 0.213 7 8 
 i 21 79.66668 1 9000 9.88896868761 0.213 7 8 
 i 21 79.75001 1 9000 10.8889686876 0.213 7 8 
 i 21 79.75003 1 9000 9.11778737811 0.213 7 8 
 i 21 79.83334 1 9000 10.6438561898 0.213 7 8 
 i 21 79.91667 1 9000 10.0588936891 0.213 7 8 
 i 21 79.91668 1 9000 10.7027498788 0.213 7 8 
 i 21 79.9167 1 9000 8.96578428466 0.213 7 8 
 i 21 80.00001 1 9000 10.4739311883 0.213 7 8 
 i 21 80.08334 1 9000 9.88896868761 0.213 7 8 
 i 21 80.08337 1 9000 9.11778737811 0.213 7 8 
 i 21 80.16667 1 9000 10.4739311883 0.213 7 8 
 i 21 80.16668 1 9000 10.6438561898 0.213 7 8 
 i 21 80.25001 1 9000 9.88896868761 0.213 7 8 
 i 21 80.25004 1 9000 8.96578428466 0.213 7 8 
 i 21 80.33335 1 9000 10.4739311883 0.213 7 8 
 i 21 80.41667 1 9000 8.05889368905 0.213 7 8 
 i 21 80.41667 1 9000 9.88896868761 0.213 7 8 
 i 21 80.41668 1 9000 10.0588936891 0.213 7 8 
 i 21 80.41671 1 9000 8.96578428466 0.213 7 8 
 i 21 80.50002 1 9000 10.4739311883 0.213 7 8 
 i 21 80.58334 1 9000 8.05889368905 0.213 7 8 
 i 21 80.58334 1 9000 9.88896868761 0.213 7 8 
 i 21 80.58335 1 9000 9.88896868761 0.213 7 8 
 i 21 80.58338 1 9000 8.96578428466 0.213 7 8 
 i 21 80.66667 1 9000 8.47393118833 0.213 7 8 
 i 21 80.66669 1 9000 10.4739311883 0.213 7 8 
 i 21 80.75002 1 9000 10.0588936891 0.213 7 8 
 i 21 80.75005 1 9000 8.96578428466 0.213 7 8 
 i 21 80.83334 1 9000 8.47393118833 0.213 7 8 
 i 21 80.83336 1 9000 10.4739311883 0.213 7 8 
 i 21 80.91667 1 9000 9.47393118833 0.213 7 8 
 i 21 80.91667 1 9000 10.4739311883 0.213 7 8 
 i 21 80.91669 1 9000 9.88896868761 0.213 7 8 
 i 21 80.91672 1 9000 8.96578428466 0.213 7 8 
 i 21 81.00001 1 9000 8.64385618977 0.213 7 8 
 i 21 81.08334 1 9000 9.64385618977 0.213 7 8 
 i 21 81.08334 1 9000 10.6438561898 0.213 7 8 
 i 21 81.08336 1 9000 9.70274987883 0.213 7 8 
 i 21 81.16668 1 9000 8.47393118833 0.213 7 8 
 i 21 81.25001 1 9000 9.47393118833 0.213 7 8 
 i 21 81.25001 1 9000 10.4739311883 0.213 7 8 
 i 21 81.25003 1 9000 9.70274987883 0.213 7 8 
 i 21 81.41667 1 9000 10.4739311883 0.213 7 8 
 i 21 81.41668 1 9000 9.47393118833 0.213 7 8 
 i 21 81.41668 1 9000 10.6438561898 0.213 7 8 
 i 21 81.4167 1 9000 9.70274987883 0.213 7 8 
 i 21 81.58335 1 9000 9.47393118833 0.213 7 8 
 i 21 81.58335 1 9000 10.4739311883 0.213 7 8 
 i 21 81.58337 1 9000 9.70274987883 0.213 7 8 
 i 21 81.75002 1 9000 9.47393118833 0.213 7 8 
 i 21 81.75002 1 9000 10.4739311883 0.213 7 8 
 i 21 81.75004 1 9000 9.53282487739 0.213 7 8 
 i 21 81.91667 1 9000 10.0588936891 0.213 7 8 
 i 21 81.91669 1 9000 9.2288186905 0.213 7 8 
 i 21 81.91669 1 9000 10.4739311883 0.213 7 8 
 i 21 81.91671 1 9000 9.53282487739 0.213 7 8 
 i 21 82.08336 1 9000 9.2288186905 0.213 7 8 
 i 21 82.08336 1 9000 10.4739311883 0.213 7 8 
 i 21 82.08338 1 9000 9.70274987883 0.213 7 8 
 i 21 82.16667 1 9000 10.4739311883 0.213 7 8 
 i 21 82.25003 1 9000 10.2288186905 0.213 7 8 
 i 21 82.25005 1 9000 9.53282487739 0.213 7 8 
 i 21 82.33334 1 9000 10.2288186905 0.213 7 8 
 i 21 82.41667 1 9000 9.88896868761 0.213 7 8 
 i 21 82.4167 1 9000 10.2288186905 0.213 7 8 
 i 21 82.41672 1 9000 9.70274987883 0.213 7 8 
 i 21 82.58334 1 9000 10.0588936891 0.213 7 8 
 i 21 82.58337 1 9000 10.2288186905 0.213 7 8 
 i 21 82.66667 1 9000 10.4739311883 0.213 7 8 
 i 21 82.75001 1 9000 9.88896868761 0.213 7 8 
 i 21 82.75004 1 9000 10.4739311883 0.213 7 8 
 i 21 82.83334 1 9000 10.4739311883 0.213 7 8 
 i 21 82.91667 1 9000 9.88896868761 0.213 7 8 
 i 21 82.91668 1 9000 10.0588936891 0.213 7 8 
 i 21 82.91671 1 9000 10.2288186905 0.213 7 8 
 i 21 83.00001 1 9000 10.4739311883 0.213 7 8 
 i 21 83.08334 1 9000 10.0588936891 0.213 7 8 
 i 21 83.08338 1 9000 10.4739311883 0.213 7 8 
 i 21 83.16667 1 9000 10.2288186905 0.213 7 8 
 i 21 83.16668 1 9000 10.4739311883 0.213 7 8 
 i 21 83.25001 1 9000 9.88896868761 0.213 7 8 
 i 21 83.25005 1 9000 10.2288186905 0.213 7 8 
 i 21 83.33334 1 9000 10.1177873781 0.213 7 8 
 i 21 83.33335 1 9000 10.4739311883 0.213 7 8 
 i 21 83.41667 1 9000 10.7027498788 0.213 7 8 
 i 21 83.41668 1 9000 9.88896868761 0.213 7 8 
 i 21 83.41672 1 9000 10.2288186905 0.213 7 8 
 i 21 83.50001 1 9000 10.1177873781 0.213 7 8 
 i 21 83.50002 1 9000 10.2288186905 0.213 7 8 
 i 21 83.58335 1 9000 9.88896868761 0.213 7 8 
 i 21 83.66667 1 9000 11.7027498788 0.213 7 8 
 i 21 83.66668 1 9000 10.2288186905 0.213 7 8 
 i 21 83.66669 1 9000 10.2288186905 0.213 7 8 
 i 21 83.75002 1 9000 9.88896868761 0.213 7 8 
 i 21 83.83334 1 9000 11.7027498788 0.213 7 8 
 i 21 83.83335 1 9000 10.1177873781 0.213 7 8 
 i 21 83.83336 1 9000 10.4739311883 0.213 7 8 
 i 21 83.91667 1 9000 11.2288186905 0.213 7 8 
 i 21 83.91669 1 9000 9.88896868761 0.213 7 8 
 i 21 84.00002 1 9000 10.2288186905 0.213 7 8 
 i 21 84.08334 1 9000 11.2288186905 0.213 7 8 
 i 21 84.08336 1 9000 9.70274987883 0.213 7 8 
 i 21 84.16667 1 9000 11.7027498788 0.213 7 8 
 i 21 84.16669 1 9000 10.1177873781 0.213 7 8 
 i 21 84.25001 1 9000 11.1177873781 0.213 7 8 
 i 21 84.25003 1 9000 9.70274987883 0.213 7 8 
 i 21 84.33334 1 9000 11.5328248774 0.213 7 8 
 i 21 84.33336 1 9000 9.96578428466 0.213 7 8 
 i 21 84.41667 1 9000 11.1177873781 0.213 7 8 
 i 21 84.41668 1 9000 11.1177873781 0.213 7 8 
 i 21 84.4167 1 9000 9.88896868761 0.213 7 8 
 i 21 84.50001 1 9000 11.3808217839 0.213 7 8 
 i 21 84.50003 1 9000 9.96578428466 0.213 7 8 
 i 21 84.58334 1 9000 11.1177873781 0.213 7 8 
 i 21 84.58337 1 9000 9.70274987883 0.213 7 8 
 i 21 84.66667 1 9000 11.7027498788 0.213 7 8 
 i 21 84.66668 1 9000 11.5328248774 0.213 7 8 
 i 21 84.6667 1 9000 9.96578428466 0.213 7 8 
 i 21 84.75001 1 9000 11.2288186905 0.213 7 8 
 i 21 84.75004 1 9000 9.88896868761 0.213 7 8 
 i 21 84.83334 1 9000 11.7027498788 0.213 7 8 
 i 21 84.83335 1 9000 11.3808217839 0.213 7 8 
 i 21 84.83337 1 9000 9.96578428466 0.213 7 8 
 i 21 84.91668 1 9000 11.4739311883 0.213 7 8 
 i 21 84.91671 1 9000 9.70274987883 0.213 7 8 
 i 21 85.00001 1 9000 11.5328248774 0.213 7 8 
 i 21 85.00002 1 9000 11.3808217839 0.213 7 8 
 i 21 85.00004 1 9000 9.79585928322 0.213 7 8 
 i 21 85.08335 1 9000 11.2288186905 0.213 7 8 
 i 21 85.08338 1 9000 9.70274987883 0.213 7 8 
 i 21 85.16667 1 9000 11.1177873781 0.213 7 8 
 i 21 85.16668 1 9000 11.5328248774 0.213 7 8 
 i 21 85.16669 1 9000 11.3808217839 0.213 7 8 
 i 21 85.16671 1 9000 9.79585928322 0.213 7 8 
 i 21 85.25002 1 9000 11.4739311883 0.213 7 8 
 i 21 85.25005 1 9000 9.70274987883 0.213 7 8 
 i 21 85.33335 1 9000 11.5328248774 0.213 7 8 
 i 21 85.33336 1 9000 11.3808217839 0.213 7 8 
 i 21 85.33338 1 9000 9.96578428466 0.213 7 8 
 i 21 85.41669 1 9000 11.2288186905 0.213 7 8 
 i 21 85.41672 1 9000 9.70274987883 0.213 7 8 
 i 21 85.50002 1 9000 11.7027498788 0.213 7 8 
 i 21 85.50005 1 9000 9.79585928322 0.213 7 8 
 i 21 85.58336 1 9000 11.2288186905 0.213 7 8 
 i 21 85.66669 1 9000 11.5328248774 0.213 7 8 
 i 21 85.66672 1 9000 9.96578428466 0.213 7 8 
 i 21 85.83336 1 9000 11.7027498788 0.213 7 8 
 i 21 86.00003 1 9000 11.5328248774 0.213 7 8 
 i 21 86.1667 1 9000 11.5328248774 0.213 7 8 
 i 21 86.33337 1 9000 11.5328248774 0.213 7 8 
 i 21 86.41667 1 9000 8.2108967825 0.213 7 8 
 i 21 86.50004 1 9000 11.5328248774 0.213 7 8 
 i 21 86.58334 1 9000 8.05889368905 0.213 7 8 
 i 21 86.66667 1 9000 8.64385618977 0.213 7 8 
 i 21 86.66671 1 9000 11.3808217839 0.213 7 8 
 i 21 86.83334 1 9000 8.64385618977 0.213 7 8 
 i 21 86.83338 1 9000 11.2108967825 0.213 7 8 
 i 21 86.91667 1 9000 9.64385618977 0.213 7 8 
 i 21 87.00001 1 9000 8.64385618977 0.213 7 8 
 i 21 87.00005 1 9000 11.2108967825 0.213 7 8 
 i 21 87.08334 1 9000 9.64385618977 0.213 7 8 
 i 21 87.16667 1 9000 9.2108967825 0.213 7 8 
 i 21 87.16668 1 9000 8.64385618977 0.213 7 8 
 i 21 87.16672 1 9000 11.3808217839 0.213 7 8 
 i 21 87.25001 1 9000 9.79585928322 0.213 7 8 
 i 21 87.33334 1 9000 9.05889368905 0.213 7 8 
 i 21 87.41668 1 9000 9.64385618977 0.213 7 8 
 i 21 87.50001 1 9000 9.05889368905 0.213 7 8 
 i 21 87.66667 1 9000 9.64385618977 0.213 7 8 
 i 21 87.66668 1 9000 9.05889368905 0.213 7 8 
 i 21 87.83334 1 9000 9.47393118833 0.213 7 8 
 i 21 87.83335 1 9000 9.05889368905 0.213 7 8 
 i 21 88.00001 1 9000 9.64385618977 0.213 7 8 
 i 21 88.00002 1 9000 9.05889368905 0.213 7 8 
 i 21 88.16667 1 9000 9.05889368905 0.213 7 8 
 i 21 88.16668 1 9000 9.47393118833 0.213 7 8 
 i 21 88.16669 1 9000 8.88896868761 0.213 7 8 
 i 21 88.33335 1 9000 9.47393118833 0.213 7 8 
 i 21 88.33336 1 9000 8.88896868761 0.213 7 8 
 i 21 88.41667 1 9000 9.64385618977 0.213 7 8 
 i 21 88.50002 1 9000 9.47393118833 0.213 7 8 
 i 21 88.58334 1 9000 9.47393118833 0.213 7 8 
 i 21 88.66667 1 9000 10.2108967825 0.213 7 8 
 i 21 88.66669 1 9000 9.47393118833 0.213 7 8 
 i 21 88.83334 1 9000 10.3808217839 0.213 7 8 
 i 21 88.83336 1 9000 9.47393118833 0.213 7 8 
 i 21 88.91667 1 9000 9.64385618977 0.213 7 8 
 i 21 89.00003 1 9000 9.2288186905 0.213 7 8 
 i 21 89.08334 1 9000 9.79585928322 0.213 7 8 
 i 21 89.16667 1 9000 10.0588936891 0.213 7 8 
 i 21 89.1667 1 9000 9.2288186905 0.213 7 8 
 i 21 89.25001 1 9000 9.96578428466 0.213 7 8 
 i 21 89.33334 1 9000 10.0588936891 0.213 7 8 
 i 21 89.33337 1 9000 9.47393118833 0.213 7 8 
 i 21 89.41667 1 9000 11.0588936891 0.213 7 8 
 i 21 89.41668 1 9000 9.79585928322 0.213 7 8 
 i 21 89.50001 1 9000 10.0588936891 0.213 7 8 
 i 21 89.50004 1 9000 9.2288186905 0.213 7 8 
 i 21 89.58334 1 9000 10.8889686876 0.213 7 8 
 i 21 89.66667 1 9000 10.6438561898 0.213 7 8 
 i 21 89.66668 1 9000 9.88896868761 0.213 7 8 
 i 21 89.66671 1 9000 9.47393118833 0.213 7 8 
 i 21 89.75001 1 9000 10.8889686876 0.213 7 8 
 i 21 89.83335 1 9000 9.88896868761 0.213 7 8 
 i 21 89.83338 1 9000 9.2288186905 0.213 7 8 
 i 21 89.91667 1 9000 11.0588936891 0.213 7 8 
 i 21 89.91668 1 9000 10.8889686876 0.213 7 8 
 i 21 90.00002 1 9000 10.0588936891 0.213 7 8 
 i 21 90.00005 1 9000 9.11778737811 0.213 7 8 
 i 21 90.08335 1 9000 10.8889686876 0.213 7 8 
 i 21 90.16667 1 9000 10.4739311883 0.213 7 8 
 i 21 90.16669 1 9000 9.88896868761 0.213 7 8 
 i 21 90.16672 1 9000 9.11778737811 0.213 7 8 
 i 21 90.25002 1 9000 10.7027498788 0.213 7 8 
 i 21 90.33334 1 9000 10.2288186905 0.213 7 8 
 i 21 90.33336 1 9000 9.70274987883 0.213 7 8 
 i 21 90.41667 1 9000 8.05889368905 0.213 7 8 
 i 21 90.41667 1 9000 9.88896868761 0.213 7 8 
 i 21 90.41669 1 9000 10.7027498788 0.213 7 8 
 i 21 90.58334 1 9000 9.70274987883 0.213 7 8 
 i 21 90.58334 1 9000 11.8889686876 0.213 7 8 
 i 21 90.58336 1 9000 10.8889686876 0.213 7 8 
 i 21 90.66667 1 9000 9.05889368905 0.213 7 8 
 i 21 90.66667 1 9000 10.4739311883 0.213 7 8 
 i 21 90.75001 1 9000 9.53282487739 0.213 7 8 
 i 21 90.75001 1 9000 11.8889686876 0.213 7 8 
 i 21 90.75003 1 9000 11.0588936891 0.213 7 8 
 i 21 90.83334 1 9000 9.05889368905 0.213 7 8 
 i 21 90.83334 1 9000 10.2288186905 0.213 7 8 
 i 21 90.91667 1 9000 8.64385618977 0.213 7 8 
 i 21 90.91667 1 9000 9.88896868761 0.213 7 8 
 i 21 90.91668 1 9000 9.53282487739 0.213 7 8 
 i 21 90.91668 1 9000 11.8889686876 0.213 7 8 
 i 21 90.9167 1 9000 10.8889686876 0.213 7 8 
 i 21 91.00001 1 9000 9.05889368905 0.213 7 8 
 i 21 91.00001 1 9000 10.4739311883 0.213 7 8 
 i 21 91.08334 1 9000 9.70274987883 0.213 7 8 
 i 21 91.08335 1 9000 9.70274987883 0.213 7 8 
 i 21 91.08337 1 9000 11.0588936891 0.213 7 8 
 i 21 91.16667 1 9000 9.05889368905 0.213 7 8 
 i 21 91.16668 1 9000 9.05889368905 0.213 7 8 
 i 21 91.16668 1 9000 10.2288186905 0.213 7 8 
 i 21 91.25002 1 9000 9.53282487739 0.213 7 8 
 i 21 91.25004 1 9000 10.8889686876 0.213 7 8 
 i 21 91.33334 1 9000 9.2108967825 0.213 7 8 
 i 21 91.33335 1 9000 8.88896868761 0.213 7 8 
 i 21 91.33335 1 9000 10.2288186905 0.213 7 8 
 i 21 91.41667 1 9000 9.47393118833 0.213 7 8 
 i 21 91.41669 1 9000 9.70274987883 0.213 7 8 
 i 21 91.41671 1 9000 10.8889686876 0.213 7 8 
 i 21 91.50001 1 9000 9.05889368905 0.213 7 8 
 i 21 91.50002 1 9000 8.88896868761 0.213 7 8 
 i 21 91.50002 1 9000 10.2288186905 0.213 7 8 
 i 21 91.58334 1 9000 9.2288186905 0.213 7 8 
 i 21 91.58336 1 9000 9.53282487739 0.213 7 8 
 i 21 91.58338 1 9000 10.8889686876 0.213 7 8 
 i 21 91.66668 1 9000 9.2108967825 0.213 7 8 
 i 21 91.66669 1 9000 9.05889368905 0.213 7 8 
 i 21 91.66669 1 9000 10.2288186905 0.213 7 8 
 i 21 91.75001 1 9000 9.2288186905 0.213 7 8 
 i 21 91.75005 1 9000 10.8889686876 0.213 7 8 
 i 21 91.83336 1 9000 8.88896868761 0.213 7 8 
 i 21 91.83336 1 9000 10.2288186905 0.213 7 8 
 i 21 91.91667 1 9000 8.88896868761 0.213 7 8 
 i 21 91.91668 1 9000 9.2288186905 0.213 7 8 
 i 21 91.91672 1 9000 10.7027498788 0.213 7 8 
 i 21 92.00003 1 9000 9.05889368905 0.213 7 8 
 i 21 92.00003 1 9000 10.1177873781 0.213 7 8 
 i 21 92.08334 1 9000 8.70274987883 0.213 7 8 
 i 21 92.08335 1 9000 9.2288186905 0.213 7 8 
 i 21 92.1667 1 9000 8.88896868761 0.213 7 8 
 i 21 92.1667 1 9000 10.1177873781 0.213 7 8 
 i 21 92.25001 1 9000 8.88896868761 0.213 7 8 
 i 21 92.25002 1 9000 9.11778737811 0.213 7 8 
 i 21 92.33337 1 9000 8.88896868761 0.213 7 8 
 i 21 92.33337 1 9000 10.2288186905 0.213 7 8 
 i 21 92.41667 1 9000 9.47393118833 0.213 7 8 
 i 21 92.41668 1 9000 8.70274987883 0.213 7 8 
 i 21 92.41669 1 9000 9.11778737811 0.213 7 8 
 i 21 92.50004 1 9000 8.88896868761 0.213 7 8 
 i 21 92.50004 1 9000 10.1177873781 0.213 7 8 
 i 21 92.58334 1 9000 9.64385618977 0.213 7 8 
 i 21 92.58335 1 9000 8.70274987883 0.213 7 8 
 i 21 92.58336 1 9000 9.2288186905 0.213 7 8 
 i 21 92.66667 1 9000 8.88896868761 0.213 7 8 
 i 21 92.66671 1 9000 8.88896868761 0.213 7 8 
 i 21 92.66671 1 9000 10.2288186905 0.213 7 8 
 i 21 92.75001 1 9000 9.79585928322 0.213 7 8 
 i 21 92.75002 1 9000 8.70274987883 0.213 7 8 
 i 21 92.83338 1 9000 8.88896868761 0.213 7 8 
 i 21 92.83338 1 9000 10.1177873781 0.213 7 8 
 i 21 92.91667 1 9000 9.2288186905 0.213 7 8 
 i 21 92.91668 1 9000 9.64385618977 0.213 7 8 
 i 21 92.91669 1 9000 8.70274987883 0.213 7 8 
 i 21 93.00005 1 9000 8.70274987883 0.213 7 8 
 i 21 93.00005 1 9000 9.96578428466 0.213 7 8 
 i 21 93.08334 1 9000 9.2288186905 0.213 7 8 
 i 21 93.08335 1 9000 9.79585928322 0.213 7 8 
 i 21 93.08336 1 9000 8.53282487739 0.213 7 8 
 i 21 93.16667 1 9000 10.2288186905 0.213 7 8 
 i 21 93.16672 1 9000 8.70274987883 0.213 7 8 
 i 21 93.16672 1 9000 9.96578428466 0.213 7 8 
 i 21 93.25002 1 9000 9.64385618977 0.213 7 8 
 i 21 93.33334 1 9000 10.1177873781 0.213 7 8 
 i 21 93.41667 1 9000 9.88896868761 0.213 7 8 
 i 21 93.41669 1 9000 9.64385618977 0.213 7 8 
 i 21 93.50001 1 9000 10.1177873781 0.213 7 8 
 i 21 93.58334 1 9000 10.0588936891 0.213 7 8 
 i 21 93.58336 1 9000 9.64385618977 0.213 7 8 
 i 21 93.66667 1 9000 9.47393118833 0.213 7 8 
 i 21 93.66668 1 9000 10.2288186905 0.213 7 8 
 i 21 93.75001 1 9000 9.88896868761 0.213 7 8 
 i 21 93.75003 1 9000 9.64385618977 0.213 7 8 
 i 21 93.83334 1 9000 9.47393118833 0.213 7 8 
 i 21 93.91667 1 9000 9.88896868761 0.213 7 8 
 i 21 93.91668 1 9000 9.88896868761 0.213 7 8 
 i 21 93.9167 1 9000 9.47393118833 0.213 7 8 
 i 21 94.00001 1 9000 9.47393118833 0.213 7 8 
 i 21 94.08334 1 9000 9.88896868761 0.213 7 8 
 i 21 94.08337 1 9000 9.47393118833 0.213 7 8 
 i 21 94.16667 1 9000 9.2288186905 0.213 7 8 
 i 21 94.16668 1 9000 9.2288186905 0.213 7 8 
 i 21 94.25001 1 9000 9.88896868761 0.213 7 8 
 i 21 94.25004 1 9000 9.47393118833 0.213 7 8 
 i 21 94.33335 1 9000 9.2288186905 0.213 7 8 
 i 21 94.41667 1 9000 9.88896868761 0.213 7 8 
 i 21 94.41668 1 9000 9.88896868761 0.213 7 8 
 i 21 94.41671 1 9000 9.64385618977 0.213 7 8 
 i 21 94.50002 1 9000 9.47393118833 0.213 7 8 
 i 21 94.58334 1 9000 9.70274987883 0.213 7 8 
 i 21 94.58335 1 9000 9.88896868761 0.213 7 8 
 i 21 94.58338 1 9000 9.47393118833 0.213 7 8 
 i 21 94.66667 1 9000 9.2288186905 0.213 7 8 
 i 21 94.66669 1 9000 9.2288186905 0.213 7 8 
 i 21 94.75002 1 9000 9.70274987883 0.213 7 8 
 i 21 94.75005 1 9000 9.64385618977 0.213 7 8 
 i 21 94.83334 1 9000 9.11778737811 0.213 7 8 
 i 21 94.83336 1 9000 9.47393118833 0.213 7 8 
 i 21 94.91667 1 9000 9.70274987883 0.213 7 8 
 i 21 94.91669 1 9000 9.70274987883 0.213 7 8 
 i 21 94.91672 1 9000 9.47393118833 0.213 7 8 
 i 21 95.08334 1 9000 9.70274987883 0.213 7 8 
 i 21 95.08336 1 9000 9.88896868761 0.213 7 8 
 i 21 95.16667 1 9000 10.7027498788 0.213 7 8 
 i 21 95.25001 1 9000 9.70274987883 0.213 7 8 
 i 21 95.25003 1 9000 9.70274987883 0.213 7 8 
 i 21 95.33334 1 9000 10.7027498788 0.213 7 8 
 i 21 95.41668 1 9000 9.70274987883 0.213 7 8 
 i 21 95.4167 1 9000 9.88896868761 0.213 7 8 
 i 21 95.50001 1 9000 10.8889686876 0.213 7 8 
 i 21 95.58337 1 9000 9.70274987883 0.213 7 8 
 i 21 95.66667 1 9000 11.7027498788 0.213 7 8 
 i 21 95.66668 1 9000 10.7027498788 0.213 7 8 
 i 21 95.75004 1 9000 9.70274987883 0.213 7 8 
 i 21 95.83334 1 9000 11.7027498788 0.213 7 8 
 i 21 95.83335 1 9000 10.8889686876 0.213 7 8 
 i 21 95.91671 1 9000 9.70274987883 0.213 7 8 
 i 21 96.00001 1 9000 11.5328248774 0.213 7 8 
 i 21 96.00002 1 9000 11.0588936891 0.213 7 8 
 i 21 96.08338 1 9000 9.70274987883 0.213 7 8 
 i 21 96.16667 1 9000 11.2288186905 0.213 7 8 
 i 21 96.16668 1 9000 11.5328248774 0.213 7 8 
 i 21 96.16669 1 9000 10.8889686876 0.213 7 8 
 i 21 96.25005 1 9000 9.70274987883 0.213 7 8 
 i 21 96.33335 1 9000 11.7027498788 0.213 7 8 
 i 21 96.33336 1 9000 10.8889686876 0.213 7 8 
 i 21 96.41667 1 9000 8.2108967825 0.213 7 8 
 i 21 96.41667 1 9000 11.7027498788 0.213 7 8 
 i 21 96.41672 1 9000 9.53282487739 0.213 7 8 
 i 21 96.50002 1 9000 11.5328248774 0.213 7 8 
 i 21 96.58334 1 9000 11.7027498788 0.213 7 8 
 i 21 96.66667 1 9000 8.79585928322 0.213 7 8 
 i 21 96.66667 1 9000 11.1177873781 0.213 7 8 
 i 21 96.66669 1 9000 11.3808217839 0.213 7 8 
 i 21 96.83334 1 9000 8.79585928322 0.213 7 8 
 i 21 96.83334 1 9000 11.2288186905 0.213 7 8 
 i 21 96.83336 1 9000 11.5328248774 0.213 7 8 
 i 21 96.91667 1 9000 8.2108967825 0.213 7 8 
 i 21 96.91667 1 9000 11.7027498788 0.213 7 8 
 i 21 97.00001 1 9000 8.64385618977 0.213 7 8 
 i 21 97.00001 1 9000 11.1177873781 0.213 7 8 
 i 21 97.00003 1 9000 11.3808217839 0.213 7 8 
 i 21 97.08334 1 9000 8.05889368905 0.213 7 8 
 i 21 97.08334 1 9000 11.7027498788 0.213 7 8 
 i 21 97.16667 1 9000 11.1177873781 0.213 7 8 
 i 21 97.16667 1 9000 11.6438561898 0.213 7 8 
 i 21 97.16668 1 9000 8.64385618977 0.213 7 8 
 i 21 97.16668 1 9000 11.2288186905 0.213 7 8 
 i 21 97.1667 1 9000 11.3808217839 0.213 7 8 
 i 21 97.25001 1 9000 8.05889368905 0.213 7 8 
 i 21 97.25001 1 9000 11.7027498788 0.213 7 8 
 i 21 97.33334 1 9000 11.4739311883 0.213 7 8 
 i 21 97.33335 1 9000 11.1177873781 0.213 7 8 
 i 21 97.33337 1 9000 11.3808217839 0.213 7 8 
 i 21 97.41667 1 9000 8.05889368905 0.213 7 8 
 i 21 97.41667 1 9000 11.5328248774 0.213 7 8 
 i 21 97.41668 1 9000 8.2108967825 0.213 7 8 
 i 21 97.41668 1 9000 11.7027498788 0.213 7 8 
 i 21 97.50002 1 9000 11.1177873781 0.213 7 8 
 i 21 97.50004 1 9000 11.3808217839 0.213 7 8 
 i 21 97.58334 1 9000 11.5328248774 0.213 7 8 
 i 21 97.58334 1 9000 11.8889686876 0.213 7 8 
 i 21 97.58335 1 9000 8.05889368905 0.213 7 8 
 i 21 97.58335 1 9000 11.7027498788 0.213 7 8 
 i 21 97.66667 1 9000 9.05889368905 0.213 7 8 
 i 21 97.66667 1 9000 11.9657842847 0.213 7 8 
 i 21 97.66669 1 9000 11.1177873781 0.213 7 8 
 i 21 97.66671 1 9000 11.2108967825 0.213 7 8 
 i 21 97.75001 1 9000 11.3808217839 0.213 7 8 
 i 21 97.75001 1 9000 11.7027498788 0.213 7 8 
 i 21 97.75002 1 9000 8.2108967825 0.213 7 8 
 i 21 97.75002 1 9000 11.5328248774 0.213 7 8 
 i 21 97.83334 1 9000 8.11778737811 0.213 7 8 
 i 21 97.83334 1 9000 9.05889368905 0.213 7 8 
 i 21 97.83336 1 9000 11.1177873781 0.213 7 8 
 i 21 97.83338 1 9000 11.2108967825 0.213 7 8 
 i 21 97.91667 1 9000 8.64385618977 0.213 7 8 
 i 21 97.91667 1 9000 8.96578428466 0.213 7 8 
 i 21 97.91668 1 9000 11.3808217839 0.213 7 8 
 i 21 97.91668 1 9000 11.7027498788 0.213 7 8 
 i 21 97.91669 1 9000 8.05889368905 0.213 7 8 
 i 21 97.91669 1 9000 11.5328248774 0.213 7 8 
 i 21 98.00001 1 9000 9.05889368905 0.213 7 8 
 i 21 98.00001 1 9000 11.9657842847 0.213 7 8 
 i 21 98.00005 1 9000 11.3808217839 0.213 7 8 
 i 21 98.08334 1 9000 8.96578428466 0.213 7 8 
 i 21 98.08335 1 9000 11.5328248774 0.213 7 8 
 i 21 98.08336 1 9000 8.05889368905 0.213 7 8 
 i 21 98.08336 1 9000 11.7027498788 0.213 7 8 
 i 21 98.16667 1 9000 8.53282487739 0.213 7 8 
 i 21 98.16668 1 9000 9.05889368905 0.213 7 8 
 i 21 98.16668 1 9000 11.9657842847 0.213 7 8 
 i 21 98.16672 1 9000 11.5328248774 0.213 7 8 
 i 21 98.25002 1 9000 11.3808217839 0.213 7 8 
 i 21 98.25003 1 9000 8.05889368905 0.213 7 8 
 i 21 98.25003 1 9000 11.5328248774 0.213 7 8 
 i 21 98.33334 1 9000 8.38082178394 0.213 7 8 
 i 21 98.33335 1 9000 8.88896868761 0.213 7 8 
 i 21 98.33335 1 9000 11.9657842847 0.213 7 8 
 i 21 98.41667 1 9000 8.96578428466 0.213 7 8 
 i 21 98.41667 1 9000 9.05889368905 0.213 7 8 
 i 21 98.41669 1 9000 11.5328248774 0.213 7 8 
 i 21 98.4167 1 9000 8.05889368905 0.213 7 8 
 i 21 98.4167 1 9000 11.7027498788 0.213 7 8 
 i 21 98.50001 1 9000 8.53282487739 0.213 7 8 
 i 21 98.50002 1 9000 8.88896868761 0.213 7 8 
 i 21 98.50002 1 9000 11.9657842847 0.213 7 8 
 i 21 98.58334 1 9000 8.96578428466 0.213 7 8 
 i 21 98.58334 1 9000 9.05889368905 0.213 7 8 
 i 21 98.58336 1 9000 11.7027498788 0.213 7 8 
 i 21 98.58337 1 9000 8.05889368905 0.213 7 8 
 i 21 98.58337 1 9000 11.5328248774 0.213 7 8 
 i 21 98.66668 1 9000 8.38082178394 0.213 7 8 
 i 21 98.66669 1 9000 9.05889368905 0.213 7 8 
 i 21 98.66669 1 9000 11.7958592832 0.213 7 8 
 i 21 98.75001 1 9000 8.96578428466 0.213 7 8 
 i 21 98.75001 1 9000 9.2108967825 0.213 7 8 
 i 21 98.75004 1 9000 11.5328248774 0.213 7 8 
 i 21 98.75004 1 9000 11.8889686876 0.213 7 8 
 i 21 98.83336 1 9000 8.88896868761 0.213 7 8 
 i 21 98.83336 1 9000 11.7958592832 0.213 7 8 
 i 21 98.91667 1 9000 8.47393118833 0.213 7 8 
 i 21 98.91668 1 9000 8.79585928322 0.213 7 8 
 i 21 98.91668 1 9000 9.05889368905 0.213 7 8 
 i 21 98.91671 1 9000 11.5328248774 0.213 7 8 
 i 21 98.91671 1 9000 11.8889686876 0.213 7 8 
 i 21 99.00003 1 9000 11.9657842847 0.213 7 8 
 i 21 99.08334 1 9000 8.47393118833 0.213 7 8 
 i 21 99.08335 1 9000 9.2108967825 0.213 7 8 
 i 21 99.08338 1 9000 8.05889368905 0.213 7 8 
 i 21 99.08338 1 9000 11.5328248774 0.213 7 8 
 i 21 99.16667 1 9000 9.05889368905 0.213 7 8 
 i 21 99.1667 1 9000 8.11778737811 0.213 7 8 
 i 21 99.25001 1 9000 8.2288186905 0.213 7 8 
 i 21 99.25002 1 9000 9.05889368905 0.213 7 8 
 i 21 99.25005 1 9000 11.5328248774 0.213 7 8 
 i 21 99.25005 1 9000 11.8889686876 0.213 7 8 
 i 21 99.33337 1 9000 11.9657842847 0.213 7 8 
 i 21 99.41667 1 9000 9.64385618977 0.213 7 8 
 i 21 99.41668 1 9000 8.2288186905 0.213 7 8 
 i 21 99.41669 1 9000 9.05889368905 0.213 7 8 
 i 21 99.41672 1 9000 8.05889368905 0.213 7 8 
 i 21 99.41672 1 9000 11.3808217839 0.213 7 8 
 i 21 99.50004 1 9000 8.11778737811 0.213 7 8 
 i 21 99.58334 1 9000 9.64385618977 0.213 7 8 
 i 21 99.58335 1 9000 8.47393118833 0.213 7 8 
 i 21 99.58336 1 9000 9.05889368905 0.213 7 8 
 i 21 99.66667 1 9000 9.05889368905 0.213 7 8 
 i 21 99.66671 1 9000 11.9657842847 0.213 7 8 
 i 21 99.75002 1 9000 8.2288186905 0.213 7 8 
 i 21 99.83334 1 9000 9.05889368905 0.213 7 8 
 i 21 99.83338 1 9000 11.9657842847 0.213 7 8 
 i 21 99.91667 1 9000 9.47393118833 0.213 7 8 
 i 21 99.91669 1 9000 8.47393118833 0.213 7 8 
 i 21 100.00005 1 9000 11.9657842847 0.213 7 8 
 i 21 100.08334 1 9000 9.2288186905 0.213 7 8 
 i 21 100.08336 1 9000 8.2288186905 0.213 7 8 
 i 21 100.16667 1 9000 10.4739311883 0.213 7 8 
 i 21 100.16672 1 9000 11.9657842847 0.213 7 8 
 i 21 100.25001 1 9000 9.2288186905 0.213 7 8 
 i 21 100.25003 1 9000 8.2288186905 0.213 7 8 
 i 21 100.33334 1 9000 10.6438561898 0.213 7 8 
 i 21 100.41667 1 9000 8.05889368905 0.213 7 8 
 i 21 100.41667 1 9000 10.0588936891 0.213 7 8 
 i 21 100.41668 1 9000 9.47393118833 0.213 7 8 
 i 21 100.4167 1 9000 8.2288186905 0.213 7 8 
 i 21 100.50001 1 9000 10.4739311883 0.213 7 8 
 i 21 100.58334 1 9000 8.2108967825 0.213 7 8 
 i 21 100.58337 1 9000 8.2288186905 0.213 7 8 
 i 21 100.66667 1 9000 10.4739311883 0.213 7 8 
 i 21 100.66667 1 9000 11.6438561898 0.213 7 8 
 i 21 100.66668 1 9000 10.2288186905 0.213 7 8 
 i 21 100.75001 1 9000 8.05889368905 0.213 7 8 
 i 21 100.75004 1 9000 8.2288186905 0.213 7 8 
 i 21 100.83334 1 9000 11.4739311883 0.213 7 8 
 i 21 100.83335 1 9000 10.2288186905 0.213 7 8 
 i 21 100.91667 1 9000 9.88896868761 0.213 7 8 
 i 21 100.91667 1 9000 11.2108967825 0.213 7 8 
 i 21 100.91668 1 9000 8.2108967825 0.213 7 8 
 i 21 100.91671 1 9000 8.11778737811 0.213 7 8 
 i 21 101.00002 1 9000 10.2288186905 0.213 7 8 
 i 21 101.08334 1 9000 10.0588936891 0.213 7 8 
 i 21 101.08334 1 9000 11.0588936891 0.213 7 8 
 i 21 101.08335 1 9000 8.38082178394 0.213 7 8 
 i 21 101.08338 1 9000 8.11778737811 0.213 7 8 
 i 21 101.16667 1 9000 9.2288186905 0.213 7 8 
 i 21 101.16667 1 9000 11.6438561898 0.213 7 8 
 i 21 101.16669 1 9000 10.2288186905 0.213 7 8 
 i 21 101.25001 1 9000 10.2108967825 0.213 7 8 
 i 21 101.25001 1 9000 11.0588936891 0.213 7 8 
 i 21 101.25002 1 9000 8.2108967825 0.213 7 8 
 i 21 101.25005 1 9000 8.2288186905 0.213 7 8 
 i 21 101.33334 1 9000 9.11778737811 0.213 7 8 
 i 21 101.33334 1 9000 11.6438561898 0.213 7 8 
 i 21 101.33336 1 9000 10.1177873781 0.213 7 8 
 i 21 101.41667 1 9000 9.88896868761 0.213 7 8 
 i 21 101.41667 1 9000 11.0588936891 0.213 7 8 
 i 21 101.41668 1 9000 10.0588936891 0.213 7 8 
 i 21 101.41668 1 9000 11.0588936891 0.213 7 8 
 i 21 101.41669 1 9000 8.2108967825 0.213 7 8 
 i 21 101.41672 1 9000 8.11778737811 0.213 7 8 
 i 21 101.50001 1 9000 9.2288186905 0.213 7 8 
 i 21 101.50001 1 9000 11.4739311883 0.213 7 8 
 i 21 101.58334 1 9000 11.0588936891 0.213 7 8 
 i 21 101.58335 1 9000 11.0588936891 0.213 7 8 
 i 21 101.58336 1 9000 8.2108967825 0.213 7 8 
 i 21 101.66667 1 9000 9.2288186905 0.213 7 8 
 i 21 101.66667 1 9000 11.6438561898 0.213 7 8 
 i 21 101.66668 1 9000 9.11778737811 0.213 7 8 
 i 21 101.66668 1 9000 11.4739311883 0.213 7 8 
 i 21 101.75002 1 9000 10.8889686876 0.213 7 8 
 i 21 101.75003 1 9000 8.2108967825 0.213 7 8 
 i 21 101.83334 1 9000 9.2288186905 0.213 7 8 
 i 21 101.83334 1 9000 11.7958592832 0.213 7 8 
 i 21 101.83335 1 9000 9.11778737811 0.213 7 8 
 i 21 101.83335 1 9000 11.6438561898 0.213 7 8 
 i 21 101.91667 1 9000 11.0588936891 0.213 7 8 
 i 21 101.91669 1 9000 10.8889686876 0.213 7 8 
 i 21 101.9167 1 9000 8.05889368905 0.213 7 8 
 i 21 102.00001 1 9000 9.2288186905 0.213 7 8 
 i 21 102.00001 1 9000 11.6438561898 0.213 7 8 
 i 21 102.00002 1 9000 9.11778737811 0.213 7 8 
 i 21 102.00002 1 9000 11.4739311883 0.213 7 8 
 i 21 102.08334 1 9000 10.8889686876 0.213 7 8 
 i 21 102.08336 1 9000 10.8889686876 0.213 7 8 
 i 21 102.08337 1 9000 8.05889368905 0.213 7 8 
 i 21 102.16667 1 9000 9.70274987883 0.213 7 8 
 i 21 102.16667 1 9000 11.4739311883 0.213 7 8 
 i 21 102.16668 1 9000 9.11778737811 0.213 7 8 
 i 21 102.16668 1 9000 11.7958592832 0.213 7 8 
 i 21 102.16669 1 9000 9.11778737811 0.213 7 8 
 i 21 102.16669 1 9000 11.6438561898 0.213 7 8 
 i 21 102.25001 1 9000 10.8889686876 0.213 7 8 
 i 21 102.25004 1 9000 8.2108967825 0.213 7 8 
 i 21 102.33334 1 9000 9.70274987883 0.213 7 8 
 i 21 102.33335 1 9000 11.6438561898 0.213 7 8 
 i 21 102.33336 1 9000 8.96578428466 0.213 7 8 
 i 21 102.33336 1 9000 11.4739311883 0.213 7 8 
 i 21 102.41667 1 9000 8.47393118833 0.213 7 8 
 i 21 102.41668 1 9000 11.0588936891 0.213 7 8 
 i 21 102.41671 1 9000 8.05889368905 0.213 7 8 
 i 21 102.50001 1 9000 9.70274987883 0.213 7 8 
 i 21 102.50002 1 9000 11.4739311883 0.213 7 8 
 i 21 102.50003 1 9000 8.79585928322 0.213 7 8 
 i 21 102.50003 1 9000 11.4739311883 0.213 7 8 
 i 21 102.58334 1 9000 8.64385618977 0.213 7 8 
 i 21 102.58335 1 9000 10.8889686876 0.213 7 8 
 i 21 102.58338 1 9000 11.8889686876 0.213 7 8 
 i 21 102.66667 1 9000 10.7027498788 0.213 7 8 
 i 21 102.66668 1 9000 9.53282487739 0.213 7 8 
 i 21 102.66669 1 9000 11.4739311883 0.213 7 8 
 i 21 102.6667 1 9000 8.79585928322 0.213 7 8 
 i 21 102.6667 1 9000 11.4739311883 0.213 7 8 
 i 21 102.75002 1 9000 11.0588936891 0.213 7 8 
 i 21 102.75005 1 9000 8.05889368905 0.213 7 8 
 i 21 102.83334 1 9000 10.7027498788 0.213 7 8 
 i 21 102.83335 1 9000 9.53282487739 0.213 7 8 
 i 21 102.83336 1 9000 11.4739311883 0.213 7 8 
 i 21 102.83337 1 9000 8.96578428466 0.213 7 8 
 i 21 102.83337 1 9000 11.4739311883 0.213 7 8 
 i 21 102.91667 1 9000 9.47393118833 0.213 7 8 
 i 21 102.91667 1 9000 10.2288186905 0.213 7 8 
 i 21 102.91669 1 9000 11.2108967825 0.213 7 8 
 i 21 102.91672 1 9000 11.8889686876 0.213 7 8 
 i 21 103.00001 1 9000 10.7027498788 0.213 7 8 
 i 21 103.00002 1 9000 9.70274987883 0.213 7 8 
 i 21 103.00004 1 9000 8.79585928322 0.213 7 8 
 i 21 103.00004 1 9000 11.4739311883 0.213 7 8 
 i 21 103.08334 1 9000 9.47393118833 0.213 7 8 
 i 21 103.08334 1 9000 10.4739311883 0.213 7 8 
 i 21 103.08336 1 9000 11.0588936891 0.213 7 8 
 i 21 103.16667 1 9000 10.7027498788 0.213 7 8 
 i 21 103.16668 1 9000 10.7027498788 0.213 7 8 
 i 21 103.16669 1 9000 9.53282487739 0.213 7 8 
 i 21 103.16671 1 9000 8.96578428466 0.213 7 8 
 i 21 103.16671 1 9000 11.2288186905 0.213 7 8 
 i 21 103.25001 1 9000 9.47393118833 0.213 7 8 
 i 21 103.25001 1 9000 10.2288186905 0.213 7 8 
 i 21 103.33334 1 9000 10.8889686876 0.213 7 8 
 i 21 103.33336 1 9000 9.38082178394 0.213 7 8 
 i 21 103.33338 1 9000 8.79585928322 0.213 7 8 
 i 21 103.33338 1 9000 11.2288186905 0.213 7 8 
 i 21 103.41667 1 9000 9.05889368905 0.213 7 8 
 i 21 103.41667 1 9000 11.1177873781 0.213 7 8 
 i 21 103.41668 1 9000 9.64385618977 0.213 7 8 
 i 21 103.41668 1 9000 10.2288186905 0.213 7 8 
 i 21 103.50001 1 9000 10.7027498788 0.213 7 8 
 i 21 103.50003 1 9000 9.53282487739 0.213 7 8 
 i 21 103.50005 1 9000 8.79585928322 0.213 7 8 
 i 21 103.50005 1 9000 11.4739311883 0.213 7 8 
 i 21 103.58334 1 9000 11.1177873781 0.213 7 8 
 i 21 103.58335 1 9000 10.2288186905 0.213 7 8 
 i 21 103.66667 1 9000 9.47393118833 0.213 7 8 
 i 21 103.66667 1 9000 10.5328248774 0.213 7 8 
 i 21 103.66668 1 9000 10.8889686876 0.213 7 8 
 i 21 103.6667 1 9000 9.38082178394 0.213 7 8 
 i 21 103.66672 1 9000 8.79585928322 0.213 7 8 
 i 21 103.66672 1 9000 11.2288186905 0.213 7 8 
 i 21 103.75002 1 9000 10.2288186905 0.213 7 8 
 i 21 103.83334 1 9000 9.47393118833 0.213 7 8 
 i 21 103.83334 1 9000 10.3808217839 0.213 7 8 
 i 21 103.83335 1 9000 10.7027498788 0.213 7 8 
 i 21 103.83337 1 9000 9.38082178394 0.213 7 8 
 i 21 103.91667 1 9000 8.88896868761 0.213 7 8 
 i 21 103.91667 1 9000 11.1177873781 0.213 7 8 
 i 21 103.91669 1 9000 10.1177873781 0.213 7 8 
 i 21 104.00001 1 9000 10.5328248774 0.213 7 8 
 i 21 104.00002 1 9000 10.7027498788 0.213 7 8 
 i 21 104.00004 1 9000 9.38082178394 0.213 7 8 
 i 21 104.08334 1 9000 8.88896868761 0.213 7 8 
 i 21 104.08334 1 9000 10.9657842847 0.213 7 8 
 i 21 104.08336 1 9000 9.96578428466 0.213 7 8 
 i 21 104.16667 1 9000 9.47393118833 0.213 7 8 
 i 21 104.16667 1 9000 10.5328248774 0.213 7 8 
 i 21 104.16668 1 9000 10.3808217839 0.213 7 8 
 i 21 104.16669 1 9000 10.7027498788 0.213 7 8 
 i 21 104.16671 1 9000 9.38082178394 0.213 7 8 
 i 21 104.25001 1 9000 8.88896868761 0.213 7 8 
 i 21 104.25001 1 9000 10.7958592832 0.213 7 8 
 i 21 104.33336 1 9000 10.7027498788 0.213 7 8 
 i 21 104.33338 1 9000 9.2108967825 0.213 7 8 
 i 21 104.41667 1 9000 8.88896868761 0.213 7 8 
 i 21 104.41667 1 9000 10.9657842847 0.213 7 8 
 i 21 104.41668 1 9000 8.88896868761 0.213 7 8 
 i 21 104.41668 1 9000 10.7958592832 0.213 7 8 
 i 21 104.50003 1 9000 10.7027498788 0.213 7 8 
 i 21 104.50005 1 9000 9.2108967825 0.213 7 8 
 i 21 104.58334 1 9000 8.70274987883 0.213 7 8 
 i 21 104.58334 1 9000 11.1177873781 0.213 7 8 
 i 21 104.58335 1 9000 8.70274987883 0.213 7 8 
 i 21 104.58335 1 9000 10.7958592832 0.213 7 8 
 i 21 104.66667 1 9000 9.2288186905 0.213 7 8 
 i 21 104.6667 1 9000 10.5328248774 0.213 7 8 
 i 21 104.66672 1 9000 9.38082178394 0.213 7 8 
 i 21 104.75001 1 9000 10.9657842847 0.213 7 8 
 i 21 104.75002 1 9000 8.70274987883 0.213 7 8 
 i 21 104.75002 1 9000 10.7958592832 0.213 7 8 
 i 21 104.83334 1 9000 9.2288186905 0.213 7 8 
 i 21 104.83337 1 9000 10.5328248774 0.213 7 8 
 i 21 104.91667 1 9000 9.70274987883 0.213 7 8 
 i 21 104.91668 1 9000 10.9657842847 0.213 7 8 
 i 21 104.91669 1 9000 8.88896868761 0.213 7 8 
 i 21 104.91669 1 9000 10.6438561898 0.213 7 8 
 i 21 105.00001 1 9000 9.11778737811 0.213 7 8 
 i 21 105.00004 1 9000 10.7027498788 0.213 7 8 
 i 21 105.08334 1 9000 9.70274987883 0.213 7 8 
 i 21 105.08336 1 9000 8.70274987883 0.213 7 8 
 i 21 105.08336 1 9000 10.6438561898 0.213 7 8 
 i 21 105.16667 1 9000 10.7027498788 0.213 7 8 
 i 21 105.16668 1 9000 9.11778737811 0.213 7 8 
 i 21 105.16671 1 9000 10.5328248774 0.213 7 8 
 i 21 105.25001 1 9000 9.70274987883 0.213 7 8 
 i 21 105.25003 1 9000 10.7958592832 0.213 7 8 
 i 21 105.33334 1 9000 10.8889686876 0.213 7 8 
 i 21 105.33335 1 9000 9.2288186905 0.213 7 8 
 i 21 105.33338 1 9000 10.7027498788 0.213 7 8 
 i 21 105.41667 1 9000 10.2288186905 0.213 7 8 
 i 21 105.41668 1 9000 9.70274987883 0.213 7 8 
 i 21 105.4167 1 9000 10.6438561898 0.213 7 8 
 i 21 105.50001 1 9000 10.7027498788 0.213 7 8 
 i 21 105.50002 1 9000 9.47393118833 0.213 7 8 
 i 21 105.50005 1 9000 10.5328248774 0.213 7 8 
 i 21 105.58335 1 9000 9.53282487739 0.213 7 8 
 i 21 105.58337 1 9000 10.7958592832 0.213 7 8 
 i 21 105.66667 1 9000 10.7027498788 0.213 7 8 
 i 21 105.66668 1 9000 10.8889686876 0.213 7 8 
 i 21 105.66669 1 9000 9.2288186905 0.213 7 8 
 i 21 105.66672 1 9000 10.5328248774 0.213 7 8 
 i 21 105.75002 1 9000 9.53282487739 0.213 7 8 
 i 21 105.75004 1 9000 10.9657842847 0.213 7 8 
 i 21 105.83334 1 9000 10.7027498788 0.213 7 8 
 i 21 105.83335 1 9000 10.7027498788 0.213 7 8 
 i 21 105.83336 1 9000 9.47393118833 0.213 7 8 
 i 21 105.91667 1 9000 10.1177873781 0.213 7 8 
 i 21 105.91669 1 9000 9.53282487739 0.213 7 8 
 i 21 105.91671 1 9000 10.7958592832 0.213 7 8 
 i 21 106.00002 1 9000 10.7027498788 0.213 7 8 
 i 21 106.08334 1 9000 10.1177873781 0.213 7 8 
 i 21 106.08336 1 9000 9.70274987883 0.213 7 8 
 i 21 106.08338 1 9000 10.7958592832 0.213 7 8 
 i 21 106.16667 1 9000 10.7027498788 0.213 7 8 
 i 21 106.16669 1 9000 10.7027498788 0.213 7 8 
 i 21 106.25001 1 9000 10.2288186905 0.213 7 8 
 i 21 106.25003 1 9000 9.53282487739 0.213 7 8 
 i 21 106.25005 1 9000 10.7958592832 0.213 7 8 
 i 21 106.33334 1 9000 10.5328248774 0.213 7 8 
 i 21 106.33336 1 9000 10.7027498788 0.213 7 8 
 i 21 106.41668 1 9000 10.1177873781 0.213 7 8 
 i 21 106.4167 1 9000 9.70274987883 0.213 7 8 
 i 21 106.41672 1 9000 10.7958592832 0.213 7 8 
 i 21 106.50001 1 9000 10.5328248774 0.213 7 8 
 i 21 106.50003 1 9000 10.7027498788 0.213 7 8 
 i 21 106.58337 1 9000 9.53282487739 0.213 7 8 
 i 21 106.66667 1 9000 10.1177873781 0.213 7 8 
 i 21 106.66668 1 9000 10.5328248774 0.213 7 8 
 i 21 106.6667 1 9000 10.5328248774 0.213 7 8 
 i 21 106.75004 1 9000 9.53282487739 0.213 7 8 
 i 21 106.83334 1 9000 9.96578428466 0.213 7 8 
 i 21 106.83335 1 9000 10.5328248774 0.213 7 8 
 i 21 106.83337 1 9000 10.5328248774 0.213 7 8 
 i 21 106.91671 1 9000 9.53282487739 0.213 7 8 
 i 21 107.00001 1 9000 10.1177873781 0.213 7 8 
 i 21 107.00002 1 9000 10.5328248774 0.213 7 8 
 i 21 107.00004 1 9000 10.7027498788 0.213 7 8 
 i 21 107.08338 1 9000 9.53282487739 0.213 7 8 
 i 21 107.16667 1 9000 9.53282487739 0.213 7 8 
 i 21 107.16668 1 9000 9.96578428466 0.213 7 8 
 i 21 107.16669 1 9000 10.3808217839 0.213 7 8 
 i 21 107.16671 1 9000 10.5328248774 0.213 7 8 
 i 21 107.25005 1 9000 9.38082178394 0.213 7 8 
 i 21 107.33334 1 9000 9.53282487739 0.213 7 8 
 i 21 107.33335 1 9000 9.79585928322 0.213 7 8 
 i 21 107.33336 1 9000 10.3808217839 0.213 7 8 
 i 21 107.33338 1 9000 10.7027498788 0.213 7 8 
 i 21 107.41672 1 9000 9.2108967825 0.213 7 8 
 i 21 107.50001 1 9000 9.70274987883 0.213 7 8 
 i 21 107.50002 1 9000 9.79585928322 0.213 7 8 
 i 21 107.50005 1 9000 10.5328248774 0.213 7 8 
 i 21 107.66667 1 9000 9.96578428466 0.213 7 8 
 i 21 107.66668 1 9000 9.53282487739 0.213 7 8 
 i 21 107.66669 1 9000 9.79585928322 0.213 7 8 
 i 21 107.66672 1 9000 10.5328248774 0.213 7 8 
 i 21 107.83335 1 9000 9.70274987883 0.213 7 8 
 i 21 107.83336 1 9000 9.79585928322 0.213 7 8 
 i 21 107.91667 1 9000 10.9657842847 0.213 7 8 
 i 21 108.00002 1 9000 9.88896868761 0.213 7 8 
 i 21 108.08334 1 9000 10.9657842847 0.213 7 8 
 i 21 108.16667 1 9000 10.5328248774 0.213 7 8 
 i 21 108.16669 1 9000 9.70274987883 0.213 7 8 
 i 21 108.33334 1 9000 10.3808217839 0.213 7 8 
 i 21 108.33336 1 9000 9.70274987883 0.213 7 8 
 i 21 108.41667 1 9000 10.9657842847 0.213 7 8 
 i 21 108.50001 1 9000 10.3808217839 0.213 7 8 
 i 21 108.50003 1 9000 9.70274987883 0.213 7 8 
 i 21 108.58334 1 9000 10.7958592832 0.213 7 8 
 i 21 108.66668 1 9000 10.5328248774 0.213 7 8 
 i 21 108.6667 1 9000 9.70274987883 0.213 7 8 
 i 21 108.75001 1 9000 10.9657842847 0.213 7 8 
 i 21 108.83337 1 9000 9.53282487739 0.213 7 8 
 i 21 108.91668 1 9000 10.7958592832 0.213 7 8 
 i 21 109.00004 1 9000 9.53282487739 0.213 7 8 
 i 21 109.16671 1 9000 9.70274987883 0.213 7 8 
 i 21 109.33338 1 9000 9.53282487739 0.213 7 8 
 i 21 109.50005 1 9000 9.38082178394 0.213 7 8 
 i 21 109.66672 1 9000 9.53282487739 0.213 7 8 
 i 21 126.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 126.83334 1 9000 8.2108967825 0.213 7 8 
 i 21 126.91667 1 9000 8.79585928322 0.213 7 8 
 i 21 127.00001 1 9000 8.2108967825 0.213 7 8 
 i 21 127.08334 1 9000 8.64385618977 0.213 7 8 
 i 21 127.16667 1 9000 9.38082178394 0.213 7 8 
 i 21 127.16668 1 9000 8.05889368905 0.213 7 8 
 i 21 127.25001 1 9000 8.64385618977 0.213 7 8 
 i 21 127.33335 1 9000 8.05889368905 0.213 7 8 
 i 21 127.41667 1 9000 8.79585928322 0.213 7 8 
 i 21 127.41668 1 9000 8.64385618977 0.213 7 8 
 i 21 127.50002 1 9000 8.05889368905 0.213 7 8 
 i 21 127.58334 1 9000 8.96578428466 0.213 7 8 
 i 21 127.58335 1 9000 8.64385618977 0.213 7 8 
 i 21 127.66669 1 9000 8.2108967825 0.213 7 8 
 i 21 127.75002 1 9000 8.47393118833 0.213 7 8 
 i 21 127.83336 1 9000 8.05889368905 0.213 7 8 
 i 21 127.91669 1 9000 8.2288186905 0.213 7 8 
 i 21 128.08336 1 9000 8.2288186905 0.213 7 8 
 i 21 128.25003 1 9000 8.47393118833 0.213 7 8 
 i 21 128.4167 1 9000 8.2288186905 0.213 7 8 
 i 21 128.58337 1 9000 8.47393118833 0.213 7 8 
 i 21 128.75004 1 9000 8.2288186905 0.213 7 8 
 i 21 128.91671 1 9000 8.2288186905 0.213 7 8 
 i 21 129.08338 1 9000 8.2288186905 0.213 7 8 
 i 21 129.25005 1 9000 8.2288186905 0.213 7 8 
 i 21 129.41672 1 9000 8.2288186905 0.213 7 8 
 i 21 130.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 130.83334 1 9000 8.2108967825 0.213 7 8 
 i 21 130.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 131.08334 1 9000 9.05889368905 0.213 7 8 
 i 21 131.16667 1 9000 8.64385618977 0.213 7 8 
 i 21 131.25001 1 9000 9.05889368905 0.213 7 8 
 i 21 131.33334 1 9000 8.47393118833 0.213 7 8 
 i 21 131.41667 1 9000 9.05889368905 0.213 7 8 
 i 21 131.41668 1 9000 9.05889368905 0.213 7 8 
 i 21 131.50001 1 9000 8.47393118833 0.213 7 8 
 i 21 131.58334 1 9000 9.05889368905 0.213 7 8 
 i 21 131.66668 1 9000 8.64385618977 0.213 7 8 
 i 21 131.75001 1 9000 9.05889368905 0.213 7 8 
 i 21 131.83335 1 9000 8.47393118833 0.213 7 8 
 i 21 131.91668 1 9000 8.88896868761 0.213 7 8 
 i 21 132.00002 1 9000 8.64385618977 0.213 7 8 
 i 21 132.08335 1 9000 8.88896868761 0.213 7 8 
 i 21 132.16669 1 9000 8.47393118833 0.213 7 8 
 i 21 132.25002 1 9000 9.05889368905 0.213 7 8 
 i 21 132.33336 1 9000 8.47393118833 0.213 7 8 
 i 21 132.41669 1 9000 8.88896868761 0.213 7 8 
 i 21 132.58336 1 9000 9.05889368905 0.213 7 8 
 i 21 132.75003 1 9000 8.88896868761 0.213 7 8 
 i 21 132.9167 1 9000 8.70274987883 0.213 7 8 
 i 21 133.08337 1 9000 8.70274987883 0.213 7 8 
 i 21 133.25004 1 9000 8.70274987883 0.213 7 8 
 i 21 133.41671 1 9000 8.70274987883 0.213 7 8 
 i 21 133.58338 1 9000 8.53282487739 0.213 7 8 
 i 21 133.75005 1 9000 8.53282487739 0.213 7 8 
 i 21 133.91672 1 9000 8.70274987883 0.213 7 8 
 i 21 136.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 136.91667 1 9000 11.6438561898 0.213 7 8 
 i 21 137.16667 1 9000 8.2108967825 0.213 7 8 
 i 21 137.33334 1 9000 8.05889368905 0.213 7 8 
 i 21 137.41667 1 9000 11.6438561898 0.213 7 8 
 i 21 137.58334 1 9000 11.6438561898 0.213 7 8 
 i 21 137.75001 1 9000 11.6438561898 0.213 7 8 
 i 21 137.91668 1 9000 11.4739311883 0.213 7 8 
 i 21 140.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 140.83334 1 9000 8.2108967825 0.213 7 8 
 i 21 140.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 141.00001 1 9000 8.05889368905 0.213 7 8 
 i 21 141.08334 1 9000 8.88896868761 0.213 7 8 
 i 21 141.16667 1 9000 8.64385618977 0.213 7 8 
 i 21 141.16668 1 9000 11.8889686876 0.213 7 8 
 i 21 141.25001 1 9000 8.88896868761 0.213 7 8 
 i 21 141.33334 1 9000 8.47393118833 0.213 7 8 
 i 21 141.33335 1 9000 8.05889368905 0.213 7 8 
 i 21 141.41667 1 9000 9.05889368905 0.213 7 8 
 i 21 141.41668 1 9000 9.05889368905 0.213 7 8 
 i 21 141.50001 1 9000 8.47393118833 0.213 7 8 
 i 21 141.50002 1 9000 11.8889686876 0.213 7 8 
 i 21 141.58335 1 9000 9.2108967825 0.213 7 8 
 i 21 141.66668 1 9000 8.47393118833 0.213 7 8 
 i 21 141.66669 1 9000 11.8889686876 0.213 7 8 
 i 21 141.75002 1 9000 9.05889368905 0.213 7 8 
 i 21 141.83335 1 9000 8.47393118833 0.213 7 8 
 i 21 141.83336 1 9000 11.8889686876 0.213 7 8 
 i 21 141.91669 1 9000 9.2108967825 0.213 7 8 
 i 21 142.00002 1 9000 8.2288186905 0.213 7 8 
 i 21 142.08336 1 9000 9.05889368905 0.213 7 8 
 i 21 142.16669 1 9000 8.11778737811 0.213 7 8 
 i 21 142.25003 1 9000 9.05889368905 0.213 7 8 
 i 21 142.33336 1 9000 8.11778737811 0.213 7 8 
 i 21 142.4167 1 9000 9.05889368905 0.213 7 8 
 i 21 142.50003 1 9000 8.2288186905 0.213 7 8 
 i 21 142.58337 1 9000 9.05889368905 0.213 7 8 
 i 21 142.6667 1 9000 8.11778737811 0.213 7 8 
 i 21 142.75004 1 9000 8.88896868761 0.213 7 8 
 i 21 142.83337 1 9000 8.2288186905 0.213 7 8 
 i 21 142.91671 1 9000 8.88896868761 0.213 7 8 
 i 21 143.00004 1 9000 8.11778737811 0.213 7 8 
 i 21 143.08338 1 9000 8.88896868761 0.213 7 8 
 i 21 143.16671 1 9000 8.11778737811 0.213 7 8 
 i 21 143.25005 1 9000 9.05889368905 0.213 7 8 
 i 21 143.33338 1 9000 8.11778737811 0.213 7 8 
 i 21 143.41672 1 9000 8.88896868761 0.213 7 8 
 i 21 143.50005 1 9000 8.11778737811 0.213 7 8 
 i 21 143.66672 1 9000 8.11778737811 0.213 7 8 
 i 21 146.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 146.83334 1 9000 8.38082178394 0.213 7 8 
 i 21 146.91667 1 9000 11.6438561898 0.213 7 8 
 i 21 147.08334 1 9000 11.7958592832 0.213 7 8 
 i 21 147.16667 1 9000 8.2108967825 0.213 7 8 
 i 21 147.25001 1 9000 11.6438561898 0.213 7 8 
 i 21 147.33334 1 9000 8.2108967825 0.213 7 8 
 i 21 147.41667 1 9000 11.6438561898 0.213 7 8 
 i 21 147.41668 1 9000 11.6438561898 0.213 7 8 
 i 21 147.50001 1 9000 8.2108967825 0.213 7 8 
 i 21 147.58334 1 9000 11.6438561898 0.213 7 8 
 i 21 147.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 147.66668 1 9000 8.05889368905 0.213 7 8 
 i 21 147.75001 1 9000 11.6438561898 0.213 7 8 
 i 21 147.83334 1 9000 8.2108967825 0.213 7 8 
 i 21 147.83335 1 9000 8.05889368905 0.213 7 8 
 i 21 147.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 147.91668 1 9000 11.6438561898 0.213 7 8 
 i 21 148.00001 1 9000 8.05889368905 0.213 7 8 
 i 21 148.00002 1 9000 8.2108967825 0.213 7 8 
 i 21 148.08335 1 9000 11.6438561898 0.213 7 8 
 i 21 148.16667 1 9000 8.64385618977 0.213 7 8 
 i 21 148.16668 1 9000 11.8889686876 0.213 7 8 
 i 21 148.16669 1 9000 8.05889368905 0.213 7 8 
 i 21 148.25002 1 9000 11.4739311883 0.213 7 8 
 i 21 148.33334 1 9000 8.64385618977 0.213 7 8 
 i 21 148.33335 1 9000 11.8889686876 0.213 7 8 
 i 21 148.33336 1 9000 8.2108967825 0.213 7 8 
 i 21 148.41669 1 9000 11.4739311883 0.213 7 8 
 i 21 148.50002 1 9000 11.8889686876 0.213 7 8 
 i 21 148.58336 1 9000 11.6438561898 0.213 7 8 
 i 21 148.66669 1 9000 11.8889686876 0.213 7 8 
 i 21 148.83336 1 9000 11.7027498788 0.213 7 8 
 i 21 149.00003 1 9000 11.7027498788 0.213 7 8 
 i 21 149.1667 1 9000 11.8889686876 0.213 7 8 
 i 21 149.33337 1 9000 11.7027498788 0.213 7 8 
 i 21 149.50004 1 9000 11.8889686876 0.213 7 8 
 i 21 149.66671 1 9000 8.05889368905 0.213 7 8 
 i 21 149.83338 1 9000 11.8889686876 0.213 7 8 
 i 21 150.00005 1 9000 11.8889686876 0.213 7 8 
 i 21 150.16672 1 9000 11.8889686876 0.213 7 8 
 i 21 150.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 150.83334 1 9000 11.8889686876 0.213 7 8 
 i 21 150.91667 1 9000 8.47393118833 0.213 7 8 
 i 21 151.00001 1 9000 11.7027498788 0.213 7 8 
 i 21 151.08334 1 9000 8.47393118833 0.213 7 8 
 i 21 151.16667 1 9000 11.8889686876 0.213 7 8 
 i 21 151.16668 1 9000 11.8889686876 0.213 7 8 
 i 21 151.25001 1 9000 8.47393118833 0.213 7 8 
 i 21 151.33334 1 9000 11.8889686876 0.213 7 8 
 i 21 151.41667 1 9000 8.47393118833 0.213 7 8 
 i 21 151.41668 1 9000 8.47393118833 0.213 7 8 
 i 21 151.50001 1 9000 8.05889368905 0.213 7 8 
 i 21 151.58334 1 9000 8.47393118833 0.213 7 8 
 i 21 151.66667 1 9000 11.8889686876 0.213 7 8 
 i 21 151.66668 1 9000 8.2108967825 0.213 7 8 
 i 21 151.75001 1 9000 8.2288186905 0.213 7 8 
 i 21 151.83335 1 9000 8.05889368905 0.213 7 8 
 i 21 151.91667 1 9000 8.2288186905 0.213 7 8 
 i 21 151.91668 1 9000 8.2288186905 0.213 7 8 
 i 21 152.00002 1 9000 8.2108967825 0.213 7 8 
 i 21 152.08334 1 9000 8.11778737811 0.213 7 8 
 i 21 152.08335 1 9000 8.2288186905 0.213 7 8 
 i 21 152.16667 1 9000 9.2288186905 0.213 7 8 
 i 21 152.16669 1 9000 8.05889368905 0.213 7 8 
 i 21 152.25002 1 9000 8.47393118833 0.213 7 8 
 i 21 152.33334 1 9000 9.2288186905 0.213 7 8 
 i 21 152.33336 1 9000 8.05889368905 0.213 7 8 
 i 21 152.41669 1 9000 8.2288186905 0.213 7 8 
 i 21 152.58336 1 9000 8.47393118833 0.213 7 8 
 i 21 152.75003 1 9000 8.2288186905 0.213 7 8 
 i 21 152.9167 1 9000 8.2288186905 0.213 7 8 
 i 21 153.08337 1 9000 8.2288186905 0.213 7 8 
 i 21 153.25004 1 9000 8.2288186905 0.213 7 8 
 i 21 153.41671 1 9000 8.11778737811 0.213 7 8 
 i 21 153.58338 1 9000 11.9657842847 0.213 7 8 
 i 21 153.75005 1 9000 11.9657842847 0.213 7 8 
 i 21 153.91672 1 9000 8.11778737811 0.213 7 8 
 i 21 156.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 156.83334 1 9000 8.2108967825 0.213 7 8 
 i 21 156.91667 1 9000 11.7958592832 0.213 7 8 
 i 21 157.00001 1 9000 8.05889368905 0.213 7 8 
 i 21 157.08334 1 9000 11.6438561898 0.213 7 8 
 i 21 157.16667 1 9000 8.2108967825 0.213 7 8 
 i 21 157.16668 1 9000 8.05889368905 0.213 7 8 
 i 21 157.25001 1 9000 11.7958592832 0.213 7 8 
 i 21 157.33334 1 9000 8.2108967825 0.213 7 8 
 i 21 157.41667 1 9000 11.6438561898 0.213 7 8 
 i 21 157.41668 1 9000 11.6438561898 0.213 7 8 
 i 21 157.50001 1 9000 8.38082178394 0.213 7 8 
 i 21 157.58335 1 9000 11.6438561898 0.213 7 8 
 i 21 157.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 157.66668 1 9000 8.2108967825 0.213 7 8 
 i 21 157.75002 1 9000 11.6438561898 0.213 7 8 
 i 21 157.83335 1 9000 8.38082178394 0.213 7 8 
 i 21 157.91667 1 9000 11.6438561898 0.213 7 8 
 i 21 157.91669 1 9000 11.6438561898 0.213 7 8 
 i 21 158.00002 1 9000 8.2108967825 0.213 7 8 
 i 21 158.08334 1 9000 11.6438561898 0.213 7 8 
 i 21 158.08336 1 9000 11.6438561898 0.213 7 8 
 i 21 158.16667 1 9000 8.05889368905 0.213 7 8 
 i 21 158.16669 1 9000 8.2108967825 0.213 7 8 
 i 21 158.33334 1 9000 8.05889368905 0.213 7 8 
 i 21 158.33336 1 9000 8.2108967825 0.213 7 8 
 i 21 158.50001 1 9000 8.2108967825 0.213 7 8 
 i 21 158.50003 1 9000 8.2108967825 0.213 7 8 
 i 21 158.66668 1 9000 8.05889368905 0.213 7 8 
 i 21 158.6667 1 9000 8.2108967825 0.213 7 8 
 i 21 158.83337 1 9000 8.05889368905 0.213 7 8 
 i 21 159.00004 1 9000 8.05889368905 0.213 7 8 
 i 21 159.16671 1 9000 8.2108967825 0.213 7 8 
 i 21 159.33338 1 9000 8.05889368905 0.213 7 8 
 i 21 159.50005 1 9000 8.2108967825 0.213 7 8 
 i 21 159.66672 1 9000 8.05889368905 0.213 7 8 
 i 21 160.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 160.83334 1 9000 8.2108967825 0.213 7 8 
 i 21 160.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 161.00001 1 9000 8.05889368905 0.213 7 8 
 i 21 161.08334 1 9000 8.88896868761 0.213 7 8 
 i 21 161.16667 1 9000 8.64385618977 0.213 7 8 
 i 21 161.16668 1 9000 8.05889368905 0.213 7 8 
 i 21 161.25001 1 9000 8.70274987883 0.213 7 8 
 i 21 161.33334 1 9000 8.64385618977 0.213 7 8 
 i 21 161.33335 1 9000 8.05889368905 0.213 7 8 
 i 21 161.41667 1 9000 9.05889368905 0.213 7 8 
 i 21 161.41668 1 9000 8.88896868761 0.213 7 8 
 i 21 161.50001 1 9000 8.47393118833 0.213 7 8 
 i 21 161.50002 1 9000 8.05889368905 0.213 7 8 
 i 21 161.58335 1 9000 8.70274987883 0.213 7 8 
 i 21 161.66667 1 9000 8.47393118833 0.213 7 8 
 i 21 161.66668 1 9000 8.47393118833 0.213 7 8 
 i 21 161.66669 1 9000 11.8889686876 0.213 7 8 
 i 21 161.75002 1 9000 8.70274987883 0.213 7 8 
 i 21 161.83334 1 9000 8.2288186905 0.213 7 8 
 i 21 161.83335 1 9000 8.47393118833 0.213 7 8 
 i 21 161.83336 1 9000 11.8889686876 0.213 7 8 
 i 21 161.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 161.91669 1 9000 8.70274987883 0.213 7 8 
 i 21 162.00002 1 9000 8.64385618977 0.213 7 8 
 i 21 162.08334 1 9000 9.05889368905 0.213 7 8 
 i 21 162.08336 1 9000 8.70274987883 0.213 7 8 
 i 21 162.16667 1 9000 8.47393118833 0.213 7 8 
 i 21 162.16669 1 9000 8.47393118833 0.213 7 8 
 i 21 162.25001 1 9000 9.05889368905 0.213 7 8 
 i 21 162.25003 1 9000 8.53282487739 0.213 7 8 
 i 21 162.33334 1 9000 8.47393118833 0.213 7 8 
 i 21 162.33336 1 9000 8.64385618977 0.213 7 8 
 i 21 162.41668 1 9000 9.05889368905 0.213 7 8 
 i 21 162.4167 1 9000 8.53282487739 0.213 7 8 
 i 21 162.50001 1 9000 8.64385618977 0.213 7 8 
 i 21 162.50003 1 9000 8.47393118833 0.213 7 8 
 i 21 162.58337 1 9000 8.70274987883 0.213 7 8 
 i 21 162.66668 1 9000 8.47393118833 0.213 7 8 
 i 21 162.6667 1 9000 8.47393118833 0.213 7 8 
 i 21 162.75004 1 9000 8.88896868761 0.213 7 8 
 i 21 162.83335 1 9000 8.64385618977 0.213 7 8 
 i 21 162.83337 1 9000 8.47393118833 0.213 7 8 
 i 21 162.91671 1 9000 8.70274987883 0.213 7 8 
 i 21 163.00002 1 9000 8.47393118833 0.213 7 8 
 i 21 163.00004 1 9000 8.47393118833 0.213 7 8 
 i 21 163.08338 1 9000 8.88896868761 0.213 7 8 
 i 21 163.16669 1 9000 8.47393118833 0.213 7 8 
 i 21 163.16671 1 9000 8.2288186905 0.213 7 8 
 i 21 163.25005 1 9000 8.70274987883 0.213 7 8 
 i 21 163.33336 1 9000 8.47393118833 0.213 7 8 
 i 21 163.33338 1 9000 8.11778737811 0.213 7 8 
 i 21 163.41672 1 9000 8.70274987883 0.213 7 8 
 i 21 163.50005 1 9000 8.11778737811 0.213 7 8 
 i 21 163.66672 1 9000 8.2288186905 0.213 7 8 
 i 21 166.66667 1 9000 8.2108967825 0.213 7 8 
 i 21 166.83334 1 9000 8.2108967825 0.213 7 8 
 i 21 166.91667 1 9000 8.64385618977 0.213 7 8 
 i 21 167.00001 1 9000 8.05889368905 0.213 7 8 
 i 21 167.08334 1 9000 8.64385618977 0.213 7 8 
 i 21 167.16667 1 9000 9.64385618977 0.213 7 8 
 i 21 167.16668 1 9000 8.05889368905 0.213 7 8 
 i 21 167.25001 1 9000 8.64385618977 0.213 7 8 
 i 21 167.33335 1 9000 8.2108967825 0.213 7 8 
 i 21 167.41667 1 9000 9.2108967825 0.213 7 8 
 i 21 167.41668 1 9000 8.64385618977 0.213 7 8 
 i 21 167.50002 1 9000 8.05889368905 0.213 7 8 
 i 21 167.58334 1 9000 9.38082178394 0.213 7 8 
 i 21 167.58335 1 9000 8.47393118833 0.213 7 8 
 i 21 167.66667 1 9000 9.64385618977 0.213 7 8 
 i 21 167.66669 1 9000 8.2108967825 0.213 7 8 
 i 21 167.75002 1 9000 8.47393118833 0.213 7 8 
 i 21 167.83334 1 9000 9.47393118833 0.213 7 8 
 i 21 167.83336 1 9000 8.05889368905 0.213 7 8 
 i 21 167.91667 1 9000 9.05889368905 0.213 7 8 
 i 21 167.91669 1 9000 8.64385618977 0.213 7 8 
 i 21 168.00001 1 9000 9.47393118833 0.213 7 8 
 i 21 168.08334 1 9000 8.88896868761 0.213 7 8 
 i 21 168.08336 1 9000 8.47393118833 0.213 7 8 
 i 21 168.16667 1 9000 9.64385618977 0.213 7 8 
 i 21 168.16668 1 9000 9.47393118833 0.213 7 8 
 i 21 168.25001 1 9000 8.88896868761 0.213 7 8 
 i 21 168.25003 1 9000 8.64385618977 0.213 7 8 
 i 21 168.33334 1 9000 9.47393118833 0.213 7 8 
 i 21 168.41667 1 9000 10.2108967825 0.213 7 8 
 i 21 168.41668 1 9000 9.05889368905 0.213 7 8 
 i 21 168.4167 1 9000 8.47393118833 0.213 7 8 
 i 21 168.50001 1 9000 9.64385618977 0.213 7 8 
 i 21 168.58334 1 9000 10.3808217839 0.213 7 8 
 i 21 168.58337 1 9000 8.2288186905 0.213 7 8 
 i 21 168.66667 1 9000 9.64385618977 0.213 7 8 
 i 21 168.66668 1 9000 9.47393118833 0.213 7 8 
 i 21 168.75001 1 9000 10.5328248774 0.213 7 8 
 i 21 168.75004 1 9000 8.2288186905 0.213 7 8 
 i 21 168.83335 1 9000 9.47393118833 0.213 7 8 
 i 21 168.91667 1 9000 10.0588936891 0.213 7 8 
 i 21 168.91668 1 9000 10.3808217839 0.213 7 8 
 i 21 168.91671 1 9000 8.2288186905 0.213 7 8 
 i 21 169.00002 1 9000 9.47393118833 0.213 7 8 
 i 21 169.08334 1 9000 10.0588936891 0.213 7 8 
 i 21 169.08335 1 9000 10.5328248774 0.213 7 8 
 i 21 169.08338 1 9000 8.2288186905 0.213 7 8 
 i 21 169.16667 1 9000 11.0588936891 0.213 7 8 
 i 21 169.16669 1 9000 9.47393118833 0.213 7 8 
 i 21 169.25002 1 9000 10.3808217839 0.213 7 8 
 i 21 169.25005 1 9000 8.11778737811 0.213 7 8 
 i 21 169.33334 1 9000 10.8889686876 0.213 7 8 
 i 21 169.33336 1 9000 9.2288186905 0.213 7 8 
 i 21 169.41669 1 9000 10.3808217839 0.213 7 8 
 i 21 169.41672 1 9000 8.11778737811 0.213 7 8 
 i 21 169.58336 1 9000 10.3808217839 0.213 7 8 
 i 21 169.66667 1 9000 10.6438561898 0.213 7 8 
 i 21 169.75003 1 9000 10.3808217839 0.213 7 8 
 i 21 169.83334 1 9000 10.7958592832 0.213 7 8 
 i 21 169.9167 1 9000 10.2108967825 0.213 7 8 
 i 21 170.00001 1 9000 10.6438561898 0.213 7 8 
 i 21 170.08337 1 9000 10.2108967825 0.213 7 8 
 i 21 170.16668 1 9000 10.7958592832 0.213 7 8 
 i 21 170.25004 1 9000 10.2108967825 0.213 7 8 
 i 21 170.41671 1 9000 10.3808217839 0.213 7 8 
 i 21 170.58338 1 9000 10.2108967825 0.213 7 8 
 i 21 170.66667 1 9000 8.05889368905 0.213 7 8 
 i 21 170.75005 1 9000 10.3808217839 0.213 7 8 
 i 21 170.83334 1 9000 8.05889368905 0.213 7 8 
 i 21 170.91672 1 9000 10.2108967825 0.213 7 8 
 i 21 171.00001 1 9000 8.05889368905 0.213 7 8 
 i 21 171.16667 1 9000 11.4739311883 0.213 7 8 
 i 21 171.16668 1 9000 8.05889368905 0.213 7 8 
 i 21 171.33334 1 9000 11.6438561898 0.213 7 8 
 i 21 171.33335 1 9000 8.05889368905 0.213 7 8 
 i 21 171.41667 1 9000 10.8889686876 0.213 7 8 
 i 21 171.50001 1 9000 11.4739311883 0.213 7 8 
 i 21 171.50002 1 9000 11.8889686876 0.213 7 8 
 i 21 171.66667 1 9000 11.4739311883 0.213 7 8 
 i 21 171.66668 1 9000 11.4739311883 0.213 7 8 
 i 21 171.66669 1 9000 11.8889686876 0.213 7 8 
 i 21 171.83335 1 9000 11.4739311883 0.213 7 8 
 i 21 171.83336 1 9000 8.05889368905 0.213 7 8 
 i 21 171.91667 1 9000 10.8889686876 0.213 7 8 
 i 21 172.00002 1 9000 11.4739311883 0.213 7 8 
 i 21 172.08334 1 9000 11.0588936891 0.213 7 8 
 i 21 172.16667 1 9000 11.2288186905 0.213 7 8 
 i 21 172.16669 1 9000 11.4739311883 0.213 7 8 
 i 21 172.33334 1 9000 11.4739311883 0.213 7 8 
 i 21 172.33336 1 9000 11.2288186905 0.213 7 8 
 i 21 172.41667 1 9000 8.2288186905 0.213 7 8 
 i 21 172.50001 1 9000 11.2288186905 0.213 7 8 
 i 21 172.50003 1 9000 11.2288186905 0.213 7 8 
 i 21 172.58334 1 9000 8.2288186905 0.213 7 8 
 i 21 172.66667 1 9000 11.8889686876 0.213 7 8 
 i 21 172.66668 1 9000 11.1177873781 0.213 7 8 
 i 21 172.6667 1 9000 11.4739311883 0.213 7 8 
 i 21 172.75001 1 9000 8.2288186905 0.213 7 8 
 i 21 172.83334 1 9000 11.7027498788 0.213 7 8 
 i 21 172.83337 1 9000 11.2288186905 0.213 7 8 
 i 21 172.91667 1 9000 8.2288186905 0.213 7 8 
 i 21 172.91668 1 9000 8.11778737811 0.213 7 8 
 i 21 173.00001 1 9000 11.7027498788 0.213 7 8 
 i 21 173.00004 1 9000 11.4739311883 0.213 7 8 
 i 21 173.08334 1 9000 8.47393118833 0.213 7 8 
 i 21 173.08335 1 9000 8.11778737811 0.213 7 8 
 i 21 173.16667 1 9000 8.70274987883 0.213 7 8 
 i 21 173.16668 1 9000 11.7027498788 0.213 7 8 
 i 21 173.16671 1 9000 11.2288186905 0.213 7 8 
 i 21 173.25001 1 9000 8.64385618977 0.213 7 8 
 i 21 173.25002 1 9000 8.2288186905 0.213 7 8 
 i 21 173.33335 1 9000 11.7027498788 0.213 7 8 
 i 21 173.33338 1 9000 11.2288186905 0.213 7 8 
 i 21 173.41667 1 9000 8.11778737811 0.213 7 8 
 i 21 173.41668 1 9000 8.47393118833 0.213 7 8 
 i 21 173.41669 1 9000 8.11778737811 0.213 7 8 
 i 21 173.50002 1 9000 11.5328248774 0.213 7 8 
 i 21 173.50005 1 9000 11.2288186905 0.213 7 8 
 i 21 173.58334 1 9000 8.11778737811 0.213 7 8 
 i 21 173.58335 1 9000 8.64385618977 0.213 7 8 
 i 21 173.58336 1 9000 8.2288186905 0.213 7 8 
 i 21 173.66667 1 9000 8.70274987883 0.213 7 8 
 i 21 173.66669 1 9000 11.5328248774 0.213 7 8 
 i 21 173.66672 1 9000 11.2288186905 0.213 7 8 
 i 21 173.75002 1 9000 8.47393118833 0.213 7 8 
 i 21 173.83334 1 9000 8.53282487739 0.213 7 8 
 i 21 173.83336 1 9000 11.7027498788 0.213 7 8 
 i 21 173.91669 1 9000 8.47393118833 0.213 7 8 
 i 21 174.00001 1 9000 8.53282487739 0.213 7 8 
 i 21 174.00003 1 9000 11.5328248774 0.213 7 8 
 i 21 174.08336 1 9000 8.47393118833 0.213 7 8 
 i 21 174.16668 1 9000 8.70274987883 0.213 7 8 
 i 21 174.1667 1 9000 11.3808217839 0.213 7 8 
 i 21 174.25003 1 9000 8.47393118833 0.213 7 8 
 i 21 174.33337 1 9000 11.5328248774 0.213 7 8 
 i 21 174.4167 1 9000 8.2288186905 0.213 7 8 
 i 21 174.50004 1 9000 11.3808217839 0.213 7 8 
 i 21 174.58337 1 9000 8.2288186905 0.213 7 8 
 i 21 174.66671 1 9000 11.3808217839 0.213 7 8 
 i 21 174.75004 1 9000 8.2288186905 0.213 7 8 
 i 21 174.83338 1 9000 11.3808217839 0.213 7 8 
 i 21 174.91671 1 9000 8.47393118833 0.213 7 8 
 i 21 175.00005 1 9000 11.3808217839 0.213 7 8 
 i 21 175.08338 1 9000 8.2288186905 0.213 7 8 
 i 21 175.16672 1 9000 11.2108967825 0.213 7 8 
 i 21 175.25005 1 9000 8.47393118833 0.213 7 8 
 i 21 175.41672 1 9000 8.2288186905 0.213 7 8 
 i 21 176.41667 1 9000 8.2108967825 0.213 7 8 
 i 21 176.58334 1 9000 8.38082178394 0.213 7 8 
 i 21 176.75001 1 9000 8.2108967825 0.213 7 8 
 i 21 176.91667 1 9000 8.64385618977 0.213 7 8 
 i 21 176.91668 1 9000 8.2108967825 0.213 7 8 
 i 21 177.08334 1 9000 8.79585928322 0.213 7 8 
 i 21 177.08335 1 9000 8.2108967825 0.213 7 8 
 i 21 177.25001 1 9000 8.64385618977 0.213 7 8 
 i 21 177.25002 1 9000 8.2108967825 0.213 7 8 
 i 21 177.41667 1 9000 9.64385618977 0.213 7 8 
 i 21 177.41668 1 9000 8.79585928322 0.213 7 8 
 i 21 177.41669 1 9000 8.2108967825 0.213 7 8 
 i 21 177.58334 1 9000 9.47393118833 0.213 7 8 
 i 21 177.58335 1 9000 8.64385618977 0.213 7 8 
 i 21 177.58336 1 9000 8.05889368905 0.213 7 8 
 i 21 177.66667 1 9000 9.2108967825 0.213 7 8 
 i 21 177.75001 1 9000 9.47393118833 0.213 7 8 
 i 21 177.75002 1 9000 8.64385618977 0.213 7 8 
 i 21 177.91667 1 9000 8.79585928322 0.213 7 8 
 i 21 177.91668 1 9000 9.64385618977 0.213 7 8 
 i 21 177.91669 1 9000 8.64385618977 0.213 7 8 
 i 21 178.08334 1 9000 8.79585928322 0.213 7 8 
 i 21 178.08335 1 9000 9.47393118833 0.213 7 8 
 i 21 178.08336 1 9000 8.64385618977 0.213 7 8 
 i 21 178.16667 1 9000 9.2108967825 0.213 7 8 
 i 21 178.25002 1 9000 9.64385618977 0.213 7 8 
 i 21 178.33334 1 9000 9.2108967825 0.213 7 8 
 i 21 178.41667 1 9000 8.64385618977 0.213 7 8 
 i 21 178.41669 1 9000 9.47393118833 0.213 7 8 
 i 21 178.50001 1 9000 9.05889368905 0.213 7 8 
 i 21 178.58334 1 9000 8.47393118833 0.213 7 8 
 i 21 178.58336 1 9000 9.47393118833 0.213 7 8 
 i 21 178.66667 1 9000 9.2108967825 0.213 7 8 
 i 21 178.66668 1 9000 9.05889368905 0.213 7 8 
 i 21 178.75001 1 9000 8.64385618977 0.213 7 8 
 i 21 178.75003 1 9000 9.47393118833 0.213 7 8 
 i 21 178.83334 1 9000 9.2108967825 0.213 7 8 
 i 21 178.91667 1 9000 8.64385618977 0.213 7 8 
 i 21 178.91668 1 9000 8.79585928322 0.213 7 8 
 i 21 178.9167 1 9000 9.47393118833 0.213 7 8 
 i 21 179.00001 1 9000 9.2108967825 0.213 7 8 
 i 21 179.08334 1 9000 8.79585928322 0.213 7 8 
 i 21 179.08337 1 9000 9.47393118833 0.213 7 8 
 i 21 179.16667 1 9000 9.05889368905 0.213 7 8 
 i 21 179.16668 1 9000 9.2108967825 0.213 7 8 
 i 21 179.25001 1 9000 8.64385618977 0.213 7 8 
 i 21 179.25004 1 9000 9.2288186905 0.213 7 8 
 i 21 179.33335 1 9000 9.05889368905 0.213 7 8 
 i 21 179.41667 1 9000 10.0588936891 0.213 7 8 
 i 21 179.41668 1 9000 8.64385618977 0.213 7 8 
 i 21 179.41671 1 9000 9.2288186905 0.213 7 8 
 i 21 179.50002 1 9000 9.05889368905 0.213 7 8 
 i 21 179.58334 1 9000 10.0588936891 0.213 7 8 
 i 21 179.58335 1 9000 8.64385618977 0.213 7 8 
 i 21 179.58338 1 9000 9.47393118833 0.213 7 8 
 i 21 179.66667 1 9000 11.0588936891 0.213 7 8 
 i 21 179.66669 1 9000 9.2108967825 0.213 7 8 
 i 21 179.75002 1 9000 8.64385618977 0.213 7 8 
 i 21 179.75005 1 9000 9.2288186905 0.213 7 8 
 i 21 179.83334 1 9000 10.8889686876 0.213 7 8 
 i 21 179.83336 1 9000 9.05889368905 0.213 7 8 
 i 21 179.91669 1 9000 8.47393118833 0.213 7 8 
 i 21 179.91672 1 9000 9.47393118833 0.213 7 8 
 i 21 180.08336 1 9000 8.47393118833 0.213 7 8 
 i 21 180.25003 1 9000 8.64385618977 0.213 7 8 
 i 21 180.41667 1 9000 8.05889368905 0.213 7 8 
 i 21 180.4167 1 9000 8.79585928322 0.213 7 8 
 i 21 180.58334 1 9000 11.8889686876 0.213 7 8 
 i 21 180.58337 1 9000 8.64385618977 0.213 7 8 
 i 21 180.66667 1 9000 8.47393118833 0.213 7 8 
 i 21 180.75001 1 9000 11.8889686876 0.213 7 8 
 i 21 180.75004 1 9000 8.79585928322 0.213 7 8 
 i 21 180.83334 1 9000 8.2288186905 0.213 7 8 
 i 21 180.91668 1 9000 11.8889686876 0.213 7 8 
 i 21 180.91671 1 9000 8.64385618977 0.213 7 8 
 i 21 181.00001 1 9000 8.11778737811 0.213 7 8 
 i 21 181.08338 1 9000 8.64385618977 0.213 7 8 
 i 21 181.16667 1 9000 11.8889686876 0.213 7 8 
 i 21 181.16668 1 9000 8.11778737811 0.213 7 8 
 i 21 181.25005 1 9000 8.64385618977 0.213 7 8 
 i 21 181.33334 1 9000 11.8889686876 0.213 7 8 
 i 21 181.33335 1 9000 8.2288186905 0.213 7 8 
 i 21 181.41672 1 9000 8.64385618977 0.213 7 8 
 i 21 181.50001 1 9000 11.8889686876 0.213 7 8 
 i 21 181.50002 1 9000 8.11778737811 0.213 7 8 
 i 21 181.66667 1 9000 8.47393118833 0.213 7 8 
 i 21 181.66668 1 9000 11.8889686876 0.213 7 8 
 i 21 181.66669 1 9000 8.2288186905 0.213 7 8 
 i 21 181.83335 1 9000 11.7027498788 0.213 7 8 
 i 21 181.83336 1 9000 8.11778737811 0.213 7 8 
 i 21 181.91667 1 9000 11.8889686876 0.213 7 8 
 i 21 182.00002 1 9000 11.7027498788 0.213 7 8 
 i 21 182.16667 1 9000 8.2288186905 0.213 7 8 
 i 21 182.16669 1 9000 11.8889686876 0.213 7 8 
 i 21 182.33334 1 9000 8.11778737811 0.213 7 8 
 i 21 182.33336 1 9000 11.7027498788 0.213 7 8 
 i 21 182.41667 1 9000 8.70274987883 0.213 7 8 
 i 21 182.50003 1 9000 11.8889686876 0.213 7 8 
 i 21 182.58334 1 9000 8.70274987883 0.213 7 8 
 i 21 182.66667 1 9000 9.70274987883 0.213 7 8 
 i 21 182.6667 1 9000 11.7027498788 0.213 7 8 
 i 21 182.75001 1 9000 8.70274987883 0.213 7 8 
 i 21 182.83334 1 9000 9.70274987883 0.213 7 8 
 i 21 182.83337 1 9000 11.7027498788 0.213 7 8 
 i 21 182.91667 1 9000 9.2288186905 0.213 7 8 
 i 21 182.91668 1 9000 8.70274987883 0.213 7 8 
 i 21 183.00001 1 9000 9.88896868761 0.213 7 8 
 i 21 183.00004 1 9000 11.7027498788 0.213 7 8 
 i 21 183.08334 1 9000 9.2288186905 0.213 7 8 
 i 21 183.16667 1 9000 9.70274987883 0.213 7 8 
 i 21 183.16668 1 9000 9.70274987883 0.213 7 8 
 i 21 183.16671 1 9000 11.7027498788 0.213 7 8 
 i 21 183.25001 1 9000 9.11778737811 0.213 7 8 
 i 21 183.33334 1 9000 9.88896868761 0.213 7 8 
 i 21 183.33335 1 9000 9.88896868761 0.213 7 8 
 i 21 183.33338 1 9000 11.7027498788 0.213 7 8 
 i 21 183.41667 1 9000 9.11778737811 0.213 7 8 
 i 21 183.41668 1 9000 9.11778737811 0.213 7 8 
 i 21 183.50001 1 9000 9.70274987883 0.213 7 8 
 i 21 183.50002 1 9000 9.70274987883 0.213 7 8 
 i 21 183.50005 1 9000 11.5328248774 0.213 7 8 
 i 21 183.58335 1 9000 9.2288186905 0.213 7 8 
 i 21 183.66667 1 9000 9.70274987883 0.213 7 8 
 i 21 183.66668 1 9000 9.70274987883 0.213 7 8 
 i 21 183.66669 1 9000 9.53282487739 0.213 7 8 
 i 21 183.66672 1 9000 11.5328248774 0.213 7 8 
 i 21 183.75002 1 9000 9.11778737811 0.213 7 8 
 i 21 183.83334 1 9000 9.70274987883 0.213 7 8 
 i 21 183.83335 1 9000 9.70274987883 0.213 7 8 
 i 21 183.83336 1 9000 9.53282487739 0.213 7 8 
 i 21 183.91667 1 9000 9.11778737811 0.213 7 8 
 i 21 183.91669 1 9000 9.2288186905 0.213 7 8 
 i 21 184.00002 1 9000 9.70274987883 0.213 7 8 
 i 21 184.08334 1 9000 8.96578428466 0.213 7 8 
 i 21 184.08336 1 9000 9.47393118833 0.213 7 8 
 i 21 184.16667 1 9000 8.53282487739 0.213 7 8 
 i 21 184.16669 1 9000 9.53282487739 0.213 7 8 
 i 21 184.25001 1 9000 9.11778737811 0.213 7 8 
 i 21 184.25003 1 9000 9.2288186905 0.213 7 8 
 i 21 184.33334 1 9000 8.53282487739 0.213 7 8 
 i 21 184.33336 1 9000 9.53282487739 0.213 7 8 
 i 21 184.41667 1 9000 8.96578428466 0.213 7 8 
 i 21 184.41668 1 9000 8.96578428466 0.213 7 8 
 i 21 184.4167 1 9000 9.2288186905 0.213 7 8 
 i 21 184.50001 1 9000 8.53282487739 0.213 7 8 
 i 21 184.50003 1 9000 9.70274987883 0.213 7 8 
 i 21 184.58334 1 9000 8.79585928322 0.213 7 8 
 i 21 184.58337 1 9000 9.2288186905 0.213 7 8 
 i 21 184.66668 1 9000 8.38082178394 0.213 7 8 
 i 21 184.6667 1 9000 9.88896868761 0.213 7 8 
 i 21 184.75001 1 9000 8.79585928322 0.213 7 8 
 i 21 184.75004 1 9000 9.2288186905 0.213 7 8 
 i 21 184.83335 1 9000 8.2108967825 0.213 7 8 
 i 21 184.83337 1 9000 9.70274987883 0.213 7 8 
 i 21 184.91667 1 9000 9.96578428466 0.213 7 8 
 i 21 184.91668 1 9000 8.79585928322 0.213 7 8 
 i 21 184.91671 1 9000 9.11778737811 0.213 7 8 
 i 21 185.00002 1 9000 8.2108967825 0.213 7 8 
 i 21 185.00004 1 9000 9.88896868761 0.213 7 8 
 i 21 185.08334 1 9000 9.79585928322 0.213 7 8 
 i 21 185.08335 1 9000 8.79585928322 0.213 7 8 
 i 21 185.08338 1 9000 9.11778737811 0.213 7 8 
 i 21 185.16669 1 9000 8.38082178394 0.213 7 8 
 i 21 185.16671 1 9000 9.70274987883 0.213 7 8 
 i 21 185.25001 1 9000 9.96578428466 0.213 7 8 
 i 21 185.25002 1 9000 8.79585928322 0.213 7 8 
 i 21 185.25005 1 9000 9.2288186905 0.213 7 8 
 i 21 185.33336 1 9000 8.2108967825 0.213 7 8 
 i 21 185.33338 1 9000 9.70274987883 0.213 7 8 
 i 21 185.41668 1 9000 9.79585928322 0.213 7 8 
 i 21 185.41669 1 9000 8.64385618977 0.213 7 8 
 i 21 185.41672 1 9000 9.11778737811 0.213 7 8 
 i 21 185.50005 1 9000 9.70274987883 0.213 7 8 
 i 21 185.58335 1 9000 9.79585928322 0.213 7 8 
 i 21 185.58336 1 9000 8.64385618977 0.213 7 8 
 i 21 185.66672 1 9000 9.70274987883 0.213 7 8 
 i 21 185.75002 1 9000 9.79585928322 0.213 7 8 
 i 21 185.91669 1 9000 9.79585928322 0.213 7 8 
 i 21 186.08336 1 9000 9.79585928322 0.213 7 8 
 i 21 186.25003 1 9000 9.64385618977 0.213 7 8 
 i 21 186.4167 1 9000 9.64385618977 0.213 7 8 
 i 21 186.58337 1 9000 9.79585928322 0.213 7 8 
 i 21 186.75004 1 9000 9.64385618977 0.213 7 8 
 i 21 186.91671 1 9000 9.79585928322 0.213 7 8 
 i 21 187.08338 1 9000 9.64385618977 0.213 7 8 
 i 21 187.25005 1 9000 9.64385618977 0.213 7 8 
 i 21 187.41672 1 9000 9.64385618977 0.213 7 8 

 i 21  		187.41672	1	9000	9.64385618977	0.213	7	8
 i 21  		187.58339	.	<		.				.		.	.
 i 21		187.75006	.	<	.	.	.	.
 i 21		187.91673	.	<	.	.	.	.
 i 21		188.0834	.	<	.	.	.	.
 i 21		188.25007	.	<	.	.	.	.
 i 21		188.41674	.	<	.	.	.	.
 i 21		188.58341	.	<	.	.	.	.
 i 21		188.75008	.	<	.	.	.	.
 i 21		188.91675	.	<	.	.	.	.
 i 21		189.08342	.	<	.	.	.	.
 i 21		189.25009	.	<	.	.	.	.
 i 21		189.41676	.	<	.	.	.	.
 i 21		189.58343	.	<	.	.	.	.
 i 21		189.7501	.	<	.	.	.	.
 i 21		189.91677	.	<	.	.	.	.
 i 21		190.08344	.	<	.	.	.	.
 i 21		190.25011	.	<	.	.	.	.
 i 21		190.41678	.	<	.	.	.	.
 i 21		190.58345	.	<	.	.	.	.
 i 21		190.75012	.	<	.	.	.	.
 i 21		190.91679	.	<	.	.	.	.
 i 21		191.08346	.	<	.	.	.	.
 i 21		191.25013	.	<	.	.	.	.
 i 21		191.4168	.	<	.	.	.	.
 i 21		191.58347	.	<	.	.	.	.
 i 21		191.75014	.	<	.	.	.	.
 i 21		191.91681	.	<	.	.	.	.
 i 21		192.08348	.	<	.	.	.	.
 i 21		192.25015	.	<	.	.	.	.
 i 21		192.41682	.	<	.	.	.	.
 i 21		192.58349	.	<	.	.	.	.
 i 21		192.75016	.	<	.	.	.	.
 i 21		192.91683	.	<	.	.	.	.
 i 21		193.0835	.	<	.	.	.	.
 i 21		193.25017	.	<	.	.	.	.
 i 21		193.41684	.	<	.	.	.	.
 i 21		193.58351	.	<	.	.	.	.
 i 21		193.75018	.	<	.	.	.	.
 i 21		193.91685	.	<	.	.	.	.
 i 21		194.08352	.	<	.	.	.	.
 i 21		194.25019	.	<	.	.	.	.
 i 21		194.41686	.	<	.	.	.	.
 i 21		194.58353	.	<	.	.	.	.
 i 21		194.7502	.	<	.	.	.	.
 i 21		194.91687	.	<	.	.	.	.
 i 21		195.08354	.	<	.	.	.	.
 i 21		195.25021	.	<	.	.	.	.
 i 21		195.41688	.	<	.	.	.	.
 i 21		195.58355	.	<	.	.	.	.
 i 21		195.75022	.	<	.	.	.	.
 i 21		195.91689	.	<	.	.	.	.
 i 21		196.08356	.	<	.	.	.	.
 i 21		196.25023	.	<	.	.	.	.
 i 21		196.41690	.	<	.	.	.	.
 i 21		196.58357	.	<	.	.	.	.
 i 21		196.75024	.	<	.	.	.	.
 i 21		196.91691	.	<	.	.	.	.
 i 21		197.08358	.	<	.	.	.	.
 i 21		197.25025	.	<	.	.	.	.
 i 21		197.41692	.	<	.	.	.	.
 i 21		197.58359	.	<	.	.	.	.
 i 21		197.75026	.	<	.	.	.	.
 i 21		197.91693	.	<	.	.	.	.
 i 21		198.08360	.	<	.	.	.	.
 i 21		198.25027	.	<	.	.	.	.
 i 21		198.41694	.	<	.	.	.	.
 i 21		198.58361	.	<	.	.	.	.
 i 21		198.75028	.	<	.	.	.	.
 i 21		198.91695	.	<	.	.	.	.
 i 21		199.08362	.	<	.	.	.	.
 i 21		199.25029	.	<	.	.	.	.
 i 21		199.41696	.	<	.	.	.	.
 i 21		199.58363	.	<	.	.	.	.
 i 21		199.7503	.	<	.	.	.	.
 i 21		199.91697	.	0	.	.	.	.

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURCODA	   7  	8  0.68  80 ; bellpno 

;codastrings
 i 386 0 7.25 75 8.05889368905 -1 4 9 10 
 i 386 6 5.25 75 8.2108967825 -1 4 9 10 
 i 386 10 7.25 75 8.2108967825 -1 4 9 10 
 i 386 16 5.25 75 8.05889368905 -1 4 9 10 
 i 386 20 7.25 75 8.05889368905 -1 4 9 10 
 i 386 26 5.25 75 8.47393118833 -1 4 9 10 
 i 386 30 7.25 75 8.2108967825 -1 4 9 10 
 i 386 36 5.25 75 8.64385618977 -1 4 9 10 
 i 386 40 7.25 75 8.05889368905 -1 4 9 10 
 i 386 46 5.25 75 8.2108967825 -1 4 9 10 
 i 386 50 7.25 75 8.2108967825 -1 4 9 10 
 i 386 56 5.25 75 8.05889368905 -1 4 9 10 
 i 386 60 7.25 75 8.05889368905 -1 4 9 10 
 i 386 66 5.25 75 8.47393118833 -1 4 9 10 
 i 386 70 7.25 75 8.2108967825 -1 4 9 10 
 i 386 76 5.25 75 8.64385618977 -1 4 9 10 
 i 386 80 7.25 75 8.05889368905 -1 4 9 10 
 i 386 86 5.25 75 8.2108967825 -1 4 9 10 
 i 386 90 7.25 75 8.2108967825 -1 4 9 10 
 i 386 96 5.25 75 8.05889368905 -1 4 9 10 
 i 386 100 7.25 75 8.05889368905 -1 4 9 10 
 i 386 106 5.25 75 8.47393118833 -1 4 9 10 
 i 386 110 7.25 75 8.2108967825 -1 4 9 10 
 i 386 116 5.25 75 8.64385618977 -1 4 9 10 
 i 386 120 7.25 75 8.05889368905 -1 4 9 10 
 i 386 126 5.25 75 8.2108967825 -1 4 9 10 
 i 386 130 7.25 75 8.2108967825 -1 4 9 10 
 i 386 136 5.25 75 8.05889368905 -1 4 9 10 
 i 386 140 7.25 75 8.05889368905 -1 4 9 10 
 i 386 146 5.25 75 8.47393118833 -1 4 9 10 
 i 386 150 7.25 75 8.2108967825 -1 4 9 10 
 i 386 156 5.25 75 8.64385618977 -1 4 9 10 
 i 386 160 7.25 75 8.05889368905 -1 4 9 10 
 i 386 166 5.25 75 8.2108967825 -1 4 9 10 
 i 386 170 7.25 75 8.2108967825 -1 4 9 10 
 i 386 176 5.25 75 8.05889368905 -1 4 9 10 
 i 386 180 5.25 75 8.05889368905 -1 4 9 10 
 i 386 0 7.25 75 8.05889368905 1 4 9 10 
 i 386 6 5.25 75 8.2108967825 1 4 9 10 
 i 386 10 5.25 75 8.05889368905 1 4 9 10 
 i 386 14 7.25 75 8.2108967825 1 4 9 10 
 i 386 20 5.25 75 8.05889368905 1 4 9 10 
 i 386 24 5.25 75 8.2108967825 1 4 9 10 
 i 386 28 7.25 75 8.05889368905 1 4 9 10 
 i 386 34 5.25 75 8.2108967825 1 4 9 10 
 i 386 38 5.25 75 8.05889368905 1 4 9 10 
 i 386 42 7.25 75 8.2108967825 1 4 9 10 
 i 386 48 5.25 75 8.05889368905 1 4 9 10 
 i 386 52 5.25 75 8.2108967825 1 4 9 10 
 i 386 56 7.25 75 8.05889368905 1 4 9 10 
 i 386 62 5.25 75 8.2108967825 1 4 9 10 
 i 386 66 5.25 75 8.05889368905 1 4 9 10 
 i 386 70 7.25 75 8.2108967825 1 4 9 10 
 i 386 76 5.25 75 8.05889368905 1 4 9 10 
 i 386 80 5.25 75 8.2108967825 1 4 9 10 
 i 386 84 7.25 75 8.05889368905 1 4 9 10 
 i 386 90 5.25 75 8.2108967825 1 4 9 10 
 i 386 94 5.25 75 8.05889368905 1 4 9 10 
 i 386 98 7.25 75 8.2108967825 1 4 9 10 
 i 386 104 5.25 75 8.05889368905 1 4 9 10 
 i 386 108 5.25 75 8.2108967825 1 4 9 10 
 i 386 112 7.25 75 8.05889368905 1 4 9 10 
 i 386 118 5.25 75 8.2108967825 1 4 9 10 
 i 386 122 5.25 75 8.05889368905 1 4 9 10 
 i 386 126 7.25 75 8.2108967825 1 4 9 10 
 i 386 132 5.25 75 8.05889368905 1 4 9 10 
 i 386 136 5.25 75 8.2108967825 1 4 9 10 
 i 386 140 7.25 75 8.05889368905 1 4 9 10 
 i 386 146 5.25 75 8.2108967825 1 4 9 10 
 i 386 150 5.25 75 8.05889368905 1 4 9 10 
 i 386 154 7.25 75 8.2108967825 1 4 9 10 
 i 386 160 5.25 75 8.05889368905 1 4 9 10 
 i 386 164 5.25 75 8.2108967825 1 4 9 10 
 i 386 168 7.25 75 8.05889368905 1 4 9 10 
 i 386 174 5.25 75 8.2108967825 1 4 9 10 
 i 386 178 5.25 75 8.05889368905 1 4 9 10 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURCODA	   9  	10  0.12  80 ; vlc

;coda flute
 i 25 0 2.0 0 0 1 -1.0 11 12 
 i 25 52.16666 0.24666 85 9.05889368905 0 -0.714285714286 11 12 
 i 25 52.33332 0.24666 85 9.05889368905 0.2 -0.428571428571 11 12 
 i 25 52.49998 0.24666 85 9.64385618977 0 -0.142857142857 11 12 
 i 25 52.66664 0.24666 85 9.47393118833 0 0.142857142857 11 12 
 i 25 52.8333 0.24666 85 9.2108967825 1 0.428571428571 11 12 
 i 25 52.99996 0.24666 85 8.96578428466 0 0.714285714286 11 12 
 i 25 53.16662 0.24666 85 8.96578428466 0.2 1.0 11 12 
 i 25 53.33328 0.24666 85 9.53282487739 0 1.0 11 12 
 i 25 53.49994 2.0 85 9.38082178394 0 0.714285714286 11 12 
 i 25 58.16666 0.24666 85 9.2108967825 1 0.428571428571 11 12 
 i 25 58.33332 0.24666 85 9.53282487739 0 0.142857142857 11 12 
 i 25 58.49998 0.24666 85 9.38082178394 0.2 -0.142857142857 11 12 
 i 25 58.66664 0.24666 85 9.2108967825 0 -0.428571428571 11 12 
 i 25 58.8333 0.24666 85 9.53282487739 0 -0.714285714286 11 12 
 i 25 58.99996 0.24666 85 9.88896868761 1 -1.0 11 12 
 i 25 59.16662 0.24666 85 9.70274987883 0 -1.0 11 12 
 i 25 59.33328 0.24666 85 9.53282487739 0.2 -0.714285714286 11 12 
 i 25 59.49994 0.24666 85 9.88896868761 0 -0.428571428571 11 12 
 i 25 59.6666 0.24666 85 10.2108967825 0 -0.142857142857 11 12 
 i 25 59.83326 0.24666 85 10.0588936891 1 0.142857142857 11 12 
 i 25 59.99992 0.24666 85 9.88896868761 0 0.428571428571 11 12 
 i 25 60.16658 2.0 85 10.2108967825 0.2 0.714285714286 11 12 
 i 25 62.16666 0.24666 85 9.2108967825 0 1.0 11 12 
 i 25 62.33332 0.24666 85 9.38082178394 0 1.0 11 12 
 i 25 62.49998 0.24666 85 9.2108967825 1 0.714285714286 11 12 
 i 25 62.66664 2.0 85 9.38082178394 0 0.428571428571 11 12 
 i 25 68.16666 0.24666 85 9.05889368905 0.2 0.142857142857 11 12 
 i 25 68.33332 0.24666 85 9.38082178394 0 -0.142857142857 11 12 
 i 25 68.49998 0.24666 85 9.2108967825 0 -0.428571428571 11 12 
 i 25 68.66664 0.24666 85 9.05889368905 1 -0.714285714286 11 12 
 i 25 68.8333 0.24666 85 9.38082178394 0 -1.0 11 12 
 i 25 68.99996 0.24666 85 9.70274987883 0.2 -1.0 11 12 
 i 25 69.16662 0.24666 85 9.53282487739 0 -0.714285714286 11 12 
 i 25 69.33328 0.24666 85 9.38082178394 0 -0.428571428571 11 12 
 i 25 69.49994 2.0 85 9.70274987883 1 -0.142857142857 11 12 
 i 25 72.16666 0.24666 85 9.05889368905 0 0.142857142857 11 12 
 i 25 72.33332 0.24666 85 9.2108967825 0.2 0.428571428571 11 12 
 i 25 72.49998 0.24666 85 9.05889368905 0 0.714285714286 11 12 
 i 25 72.66664 0.24666 85 9.2108967825 0 1.0 11 12 
 i 25 72.8333 0.24666 85 9.47393118833 1 1.0 11 12 
 i 25 72.99996 0.24666 85 9.64385618977 0 0.714285714286 11 12 
 i 25 73.16662 0.24666 85 9.47393118833 0.2 0.428571428571 11 12 
 i 25 73.33328 0.24666 85 9.64385618977 0 0.142857142857 11 12 
 i 25 73.49994 0.24666 85 9.88896868761 0 -0.142857142857 11 12 
 i 25 73.6666 0.24666 85 9.47393118833 1 -0.428571428571 11 12 
 i 25 73.83326 0.24666 85 9.05889368905 0 -0.714285714286 11 12 
 i 25 73.99992 0.24666 85 8.64385618977 0.2 -1.0 11 12 
 i 25 74.16658 2.0 85 8.79585928322 0 -1.0 11 12 
 i 25 78.16666 0.24666 85 9.47393118833 0 -0.714285714286 11 12 
 i 25 78.33332 0.24666 85 9.2288186905 1 -0.428571428571 11 12 
 i 25 78.49998 0.24666 85 9.05889368905 0 -0.142857142857 11 12 
 i 25 78.66664 2.0 85 9.05889368905 0.2 0.142857142857 11 12 
 i 25 82.16666 0.24666 85 9.2108967825 0 0.428571428571 11 12 
 i 25 82.33332 0.24666 85 8.79585928322 0 0.714285714286 11 12 
 i 25 82.49998 0.24666 85 8.96578428466 1 1.0 11 12 
 i 25 82.66664 0.24666 85 8.79585928322 0 1.0 11 12 
 i 25 82.8333 0.24666 85 8.96578428466 0.2 0.714285714286 11 12 
 i 25 82.99996 0.24666 85 9.2108967825 0 0.428571428571 11 12 
 i 25 83.16662 0.24666 85 9.38082178394 0 0.142857142857 11 12 
 i 25 83.33328 0.24666 85 9.2108967825 1 -0.142857142857 11 12 
 i 25 83.49994 2.0 85 9.38082178394 0 -0.428571428571 11 12 
 i 25 88.16666 0.24666 85 9.64385618977 0.2 -0.714285714286 11 12 
 i 25 88.33332 0.24666 85 9.47393118833 0 -1.0 11 12 
 i 25 88.49998 0.24666 85 9.2108967825 0 -1.0 11 12 
 i 25 88.66664 0.24666 85 9.2108967825 1 -0.714285714286 11 12 
 i 25 88.8333 0.24666 85 9.79585928322 0 -0.428571428571 11 12 
 i 25 88.99996 0.24666 85 10.3808217839 0.2 -0.142857142857 11 12 
 i 25 89.16662 0.24666 85 10.2108967825 0 0.142857142857 11 12 
 i 25 89.33328 0.24666 85 9.96578428466 0 0.428571428571 11 12 
 i 25 89.49994 0.24666 85 9.96578428466 1 0.714285714286 11 12 
 i 25 89.6666 0.24666 85 9.96578428466 0 1.0 11 12 
 i 25 89.83326 0.24666 85 10.5328248774 0.2 1.0 11 12 
 i 25 89.99992 0.24666 85 10.3808217839 0 0.714285714286 11 12 
 i 25 90.16658 2.0 85 10.1177873781 0 0.428571428571 11 12 
 i 25 92.16666 0.24666 85 9.05889368905 1 0.142857142857 11 12 
 i 25 92.33332 0.24666 85 9.38082178394 0 -0.142857142857 11 12 
 i 25 92.49998 0.24666 85 9.2108967825 0.2 -0.428571428571 11 12 
 i 25 92.66664 2.0 85 9.05889368905 0 -0.714285714286 11 12 
 i 25 98.16666 0.24666 85 9.2108967825 0 -1.0 11 12 
 i 25 98.33332 0.24666 85 8.96578428466 1 -1.0 11 12 
 i 25 98.49998 0.24666 85 8.96578428466 0 -0.714285714286 11 12 
 i 25 98.66664 0.24666 85 9.53282487739 0.2 -0.428571428571 11 12 
 i 25 98.8333 0.24666 85 9.38082178394 0 -0.142857142857 11 12 
 i 25 98.99996 0.24666 85 9.2108967825 0 0.142857142857 11 12 
 i 25 99.16662 0.24666 85 8.96578428466 1 0.428571428571 11 12 
 i 25 99.33328 0.24666 85 8.96578428466 0 0.714285714286 11 12 
 i 25 99.49994 2.0 85 9.53282487739 0.2 1.0 11 12 
 i 25 102.16666 0.24666 85 9.2108967825 0 1.0 11 12 
 i 25 102.33332 0.24666 85 9.05889368905 0 0.714285714286 11 12 
 i 25 102.49998 0.24666 85 9.38082178394 1 0.428571428571 11 12 
 i 25 102.66664 0.24666 85 9.70274987883 0 0.142857142857 11 12 
 i 25 102.8333 0.24666 85 9.53282487739 0.2 -0.142857142857 11 12 
 i 25 102.99996 0.24666 85 9.38082178394 0 -0.428571428571 11 12 
 i 25 103.16662 0.24666 85 9.70274987883 0 -0.714285714286 11 12 
 i 25 103.33328 0.24666 85 10.0588936891 1 -1.0 11 12 
 i 25 103.49994 0.24666 85 9.88896868761 0 -1.0 11 12 
 i 25 103.6666 0.24666 85 9.70274987883 0.2 -0.714285714286 11 12 
 i 25 103.83326 0.24666 85 10.0588936891 0 -0.428571428571 11 12 
 i 25 103.99992 0.24666 85 10.3808217839 0 -0.142857142857 11 12 
 i 25 104.16658 2.0 85 10.2108967825 1 0.142857142857 11 12 
 i 25 108.16666 0.24666 85 9.05889368905 0 0.428571428571 11 12 
 i 25 108.33332 0.24666 85 8.64385618977 0.2 0.714285714286 11 12 
 i 25 108.49998 0.24666 85 8.79585928322 0 1.0 11 12 
 i 25 108.66664 2.0 85 8.64385618977 0 1.0 11 12 
 i 25 112.16666 0.24666 85 9.05889368905 1 0.714285714286 11 12 
 i 25 112.33332 0.24666 85 8.88896868761 0 0.428571428571 11 12 
 i 25 112.49998 0.24666 85 9.2108967825 0.2 0.142857142857 11 12 
 i 25 112.66664 0.24666 85 9.53282487739 0 -0.142857142857 11 12 
 i 25 112.8333 0.24666 85 9.38082178394 0 -0.428571428571 11 12 
 i 25 112.99996 0.24666 85 9.2108967825 1 -0.714285714286 11 12 
 i 25 113.16662 0.24666 85 9.53282487739 0 -1.0 11 12 
 i 25 113.33328 0.24666 85 9.88896868761 0.2 -1.0 11 12 
 i 25 113.49994 2.0 85 9.70274987883 0 -0.714285714286 11 12 
 i 25 118.16666 0.24666 85 9.47393118833 0 -0.428571428571 11 12 
 i 25 118.33332 0.24666 85 9.05889368905 1 -0.142857142857 11 12 
 i 25 118.49998 0.24666 85 9.2108967825 0 0.142857142857 11 12 
 i 25 118.66664 0.24666 85 9.05889368905 0.2 0.428571428571 11 12 
 i 25 118.8333 0.24666 85 9.2108967825 0 0.714285714286 11 12 
 i 25 118.99996 0.24666 85 9.47393118833 0 1.0 11 12 
 i 25 119.16662 0.24666 85 9.64385618977 1 1.0 11 12 
 i 25 119.33328 0.24666 85 9.47393118833 0 0.714285714286 11 12 
 i 25 119.49994 0.24666 85 9.64385618977 0.2 0.428571428571 11 12 
 i 25 119.6666 0.24666 85 9.88896868761 0 0.142857142857 11 12 
 i 25 119.83326 0.24666 85 9.47393118833 0 -0.142857142857 11 12 
 i 25 119.99992 0.24666 85 9.05889368905 1 -0.428571428571 11 12 
 i 25 120.16658 2.0 85 8.64385618977 0 -0.714285714286 11 12 
 i 25 122.16666 0.24666 85 9.2108967825 0.2 -1.0 11 12 
 i 25 122.33332 0.24666 85 9.79585928322 0 -1.0 11 12 
 i 25 122.49998 0.24666 85 9.64385618977 0 -0.714285714286 11 12 
 i 25 122.66664 2.0 85 9.38082178394 1 -0.428571428571 11 12 
 i 25 128.16666 0.24666 85 9.64385618977 0 -0.142857142857 11 12 
 i 25 128.33332 0.24666 85 9.2108967825 0.2 0.142857142857 11 12 
 i 25 128.49998 0.24666 85 8.79585928322 0 0.428571428571 11 12 
 i 25 128.66664 0.24666 85 8.96578428466 0 0.714285714286 11 12 
 i 25 128.8333 0.24666 85 8.79585928322 1 1.0 11 12 
 i 25 128.99996 0.24666 85 8.96578428466 0 1.0 11 12 
 i 25 129.16662 0.24666 85 9.2108967825 0.2 0.714285714286 11 12 
 i 25 129.33328 0.24666 85 9.38082178394 0 0.428571428571 11 12 
 i 25 129.49994 2.0 85 9.2108967825 0 0.142857142857 11 12 
 i 25 132.16666 0.24666 85 9.05889368905 1 -0.142857142857 11 12 
 i 25 132.33332 0.24666 85 9.64385618977 0 -0.428571428571 11 12 
 i 25 132.49998 0.24666 85 9.47393118833 0.2 -0.714285714286 11 12 
 i 25 132.66664 0.24666 85 9.2108967825 0 -1.0 11 12 
 i 25 132.8333 0.24666 85 9.2108967825 0 -1.0 11 12 
 i 25 132.99996 0.24666 85 9.2108967825 1 -0.714285714286 11 12 
 i 25 133.16662 0.24666 85 9.79585928322 0 -0.428571428571 11 12 
 i 25 133.33328 0.24666 85 9.64385618977 0.2 -0.142857142857 11 12 
 i 25 133.49994 0.24666 85 9.38082178394 0 0.142857142857 11 12 
 i 25 133.6666 0.24666 85 9.11778737811 0 0.428571428571 11 12 
 i 25 133.83326 0.24666 85 9.11778737811 1 0.714285714286 11 12 
 i 25 133.99992 0.24666 85 9.70274987883 0 1.0 11 12 
 i 25 134.16658 2.0 85 9.53282487739 0.2 1.0 11 12 
 i 25 138.16666 0.24666 85 9.2108967825 0 0.714285714286 11 12 
 i 25 138.33332 0.24666 85 9.05889368905 0 0.428571428571 11 12 
 i 25 138.49998 0.24666 85 9.38082178394 1 0.142857142857 11 12 
 i 25 138.66664 2.0 85 9.70274987883 0 -0.142857142857 11 12 
 i 25 142.16666 0.24666 85 9.2108967825 0.2 -0.428571428571 11 12 
 i 25 142.33332 0.24666 85 9.05889368905 0 -0.714285714286 11 12 
 i 25 142.49998 0.24666 85 8.79585928322 0 -1.0 11 12 
 i 25 142.66664 0.24666 85 8.79585928322 1 -1.0 11 12 
 i 25 142.8333 0.24666 85 9.38082178394 0 -0.714285714286 11 12 
 i 25 142.99996 0.24666 85 9.96578428466 0.2 -0.428571428571 11 12 
 i 25 143.16662 0.24666 85 9.79585928322 0 -0.142857142857 11 12 
 i 25 143.33328 0.24666 85 9.53282487739 0 0.142857142857 11 12 
 i 25 143.49994 2.0 85 9.53282487739 1 0.428571428571 11 12 
 i 25 148.16666 0.24666 85 9.05889368905 0 0.714285714286 11 12 
 i 25 148.33332 0.24666 85 9.38082178394 0.2 1.0 11 12 
 i 25 148.49998 0.24666 85 9.2108967825 0 1.0 11 12 
 i 25 148.66664 0.24666 85 9.05889368905 0 0.714285714286 11 12 
 i 25 148.8333 0.24666 85 9.38082178394 1 0.428571428571 11 12 
 i 25 148.99996 0.24666 85 9.70274987883 0 0.142857142857 11 12 
 i 25 149.16662 0.24666 85 9.53282487739 0.2 -0.142857142857 11 12 
 i 25 149.33328 0.24666 85 9.38082178394 0 -0.428571428571 11 12 
 i 25 149.49994 0.24666 85 9.70274987883 0 -0.714285714286 11 12 
 i 25 149.6666 0.24666 85 10.0588936891 1 -1.0 11 12 
 i 25 149.83326 0.24666 85 9.88896868761 0 -1.0 11 12 
 i 25 149.99992 0.24666 85 9.70274987883 0.2 -0.714285714286 11 12 
 i 25 150.16658 2.0 85 10.0588936891 0 -0.428571428571 11 12 
 i 25 152.16666 0.24666 85 9.05889368905 0 -0.142857142857 11 12 
 i 25 152.33332 0.24666 85 8.64385618977 1 0.142857142857 11 12 
 i 25 152.49998 0.24666 85 8.2108967825 0 0.428571428571 11 12 
 i 25 152.66664 2.0 85 8.38082178394 0.2 0.714285714286 11 12 
 i 25 158.16666 0.24666 85 9.47393118833 0 1.0 11 12 
 i 25 158.33332 0.24666 85 9.79585928322 0 1.0 11 12 
 i 25 158.49998 0.24666 85 9.64385618977 1 0.714285714286 11 12 
 i 25 158.66664 0.24666 85 9.47393118833 0 0.428571428571 11 12 
 i 25 158.8333 0.24666 85 9.79585928322 0.2 0.142857142857 11 12 
 i 25 158.99996 0.24666 85 10.1177873781 0 -0.142857142857 11 12 
 i 25 159.16662 0.24666 85 9.96578428466 0 -0.428571428571 11 12 
 i 25 159.33328 0.24666 85 9.79585928322 1 -0.714285714286 11 12 
 i 25 159.49994 2.0 85 10.1177873781 0 -1.0 11 12 
 i 25 162.16666 0.24666 85 9.2108967825 0.2 -1.0 11 12 
 i 25 162.33332 0.24666 85 8.79585928322 0 -0.714285714286 11 12 
 i 25 162.49998 0.24666 85 8.38082178394 0 -0.428571428571 11 12 
 i 25 162.66664 0.24666 85 8.53282487739 1 -0.142857142857 11 12 
 i 25 162.8333 0.24666 85 8.38082178394 0 0.142857142857 11 12 
 i 25 162.99996 0.24666 85 8.53282487739 0.2 0.428571428571 11 12 
 i 25 163.16662 0.24666 85 8.79585928322 0 0.714285714286 11 12 
 i 25 163.33328 0.24666 85 8.96578428466 0 1.0 11 12 
 i 25 163.49994 0.24666 85 8.79585928322 1 1.0 11 12 
 i 25 163.6666 0.24666 85 8.96578428466 0 0.714285714286 11 12 
 i 25 163.83326 0.24666 85 9.2108967825 0.2 0.428571428571 11 12 
 i 25 163.99992 0.24666 85 9.47393118833 0 0.142857142857 11 12 
 i 25 164.16658 2.0 85 9.05889368905 0 -0.142857142857 11 12 
 i 25 168.16666 0.24666 85 9.64385618977 1 -0.428571428571 11 12 
 i 25 168.33332 0.24666 85 9.64385618977 0 -0.714285714286 11 12 
 i 25 168.49998 0.24666 85 10.2108967825 0.2 -1.0 11 12 
 i 25 168.66664 2.0 85 10.0588936891 0 -1.0 11 12 
 i 25 172.16666 0.24666 85 9.05889368905 0 -0.714285714286 11 12 
 i 25 172.33332 0.24666 85 9.2288186905 1 -0.428571428571 11 12 
 i 25 172.49998 0.24666 85 8.88896868761 0 -0.142857142857 11 12 
 i 25 172.66664 0.24666 85 8.47393118833 0.2 0.142857142857 11 12 
 i 25 172.8333 0.24666 85 8.64385618977 0 0.428571428571 11 12 
 i 25 172.99996 0.24666 85 8.47393118833 0 0.714285714286 11 12 
 i 25 173.16662 0.24666 85 8.64385618977 1 1.0 11 12 
 i 25 173.33328 0.24666 85 8.88896868761 0 1.0 11 12 
 i 25 173.49994 2.0 85 9.05889368905 0.2 0.714285714286 11 12 
 i 25 178.16666 0.24666 85 9.2108967825 0 0.428571428571 11 12 
 i 25 178.33332 0.24666 85 9.2108967825 0 0.142857142857 11 12 
 i 25 178.49998 0.24666 85 9.79585928322 1 -0.142857142857 11 12 
 i 25 178.66664 0.24666 85 9.64385618977 0 -0.428571428571 11 12 
 i 25 178.8333 0.24666 85 9.38082178394 0.2 -0.714285714286 11 12 
 i 25 178.99996 0.24666 85 9.11778737811 0 -1.0 11 12 
 i 25 179.16662 0.24666 85 9.11778737811 0 -1.0 11 12 
 i 25 179.33328 0.24666 85 9.70274987883 1 -0.714285714286 11 12 
 i 25 179.49994 0.24666 85 9.53282487739 0 -0.428571428571 11 12 
 i 25 179.6666 0.24666 85 9.38082178394 0.2 -0.142857142857 11 12 
 i 25 179.83326 0.24666 85 9.11778737811 0 0.142857142857 11 12 
 i 25 179.99992 0.24666 85 9.11778737811 0 0.428571428571 11 12 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURCODA	   11  	12  0.62  96 ; 

;candystrings
 i 386 90 2.5 80 9.88896868761 -1 3 13 14 
 i 386 93.25 2.62638888889 0 9.79585928322 -1 3 13 14 
 i 386 98.25 2.82083333333 0 10.2108967825 -1 1 13 14 
 i 386 99.5 2.86944444444 80 10.2288186905 -1 3 13 14 
 i 386 107.5 3.18055555556 0 10.0588936891 -1 1 13 14 
 i 386 110.75 3.30694444444 0 9.88896868761 -1 3 13 14 
 i 386 115.75 3.50138888889 80 9.79585928322 -1 1 13 14 
 i 386 117.0 3.55 0 10.2108967825 -1 3 13 14 
 i 386 125.0 3.86111111111 0 10.2288186905 -1 3 13 14 
 i 386 128.25 3.9875 80 10.0588936891 -1 3 13 14 
 i 386 133.25 4.18194444444 0 9.88896868761 -1 3 13 14 
 i 386 134.5 4.23055555556 0 9.79585928322 -1 1 13 14 
 i 386 142.5 4.54166666667 80 10.2108967825 -1 3 13 14 
 i 386 145.75 4.66805555556 0 10.2288186905 -1 1 13 14 
 i 386 150.75 4.8625 0 10.0588936891 -1 3 13 14 
 i 386 152.0 4.91111111111 73 9.88896868761 -1 1 13 14 
 i 386 160.0 5.22222222222 80 9.79585928322 -1 3 13 14 
 i 386 163.25 5.34861111111 0 10.2108967825 -1 3 13 14 
 i 386 168.25 5.54305555556 80 10.2288186905 -1 3 13 14 
 i 386 169.5 5.59166666667 0 10.0588936891 -1 3 13 14 
 i 386 177.5 5.90277777778 77 9.88896868761 -1 1 13 14 
 i 386 90 2.5 80 9.47393118833 1 3 13 14 
 i 386 93.25 2.62638888889 0 9.47393118833 1 3 13 14 
 i 386 98.25 2.82083333333 77 9.88896868761 1 1 13 14 
 i 386 99.5 2.86944444444 80 9.96578428466 1 3 13 14 
 i 386 107.5 3.18055555556 80 9.88896868761 1 1 13 14 
 i 386 110.75 3.30694444444 80 9.47393118833 1 3 13 14 
 i 386 115.75 3.50138888889 80 9.47393118833 1 1 13 14 
 i 386 117.0 3.55 0 9.88896868761 1 3 13 14 
 i 386 125.0 3.86111111111 0 9.96578428466 1 3 13 14 
 i 386 128.25 3.9875 80 9.88896868761 1 3 13 14 
 i 386 133.25 4.18194444444 0 9.47393118833 1 3 13 14 
 i 386 134.5 4.23055555556 0 9.47393118833 1 1 13 14 
 i 386 142.5 4.54166666667 80 9.88896868761 1 3 13 14 
 i 386 145.75 4.66805555556 0 9.96578428466 1 1 13 14 
 i 386 150.75 4.8625 0 9.88896868761 1 3 13 14 
 i 386 152.0 4.91111111111 80 9.47393118833 1 1 13 14 
 i 386 160.0 5.22222222222 0 9.47393118833 1 3 13 14 
 i 386 163.25 5.34861111111 0 9.88896868761 1 3 13 14 
 i 386 168.25 5.54305555556 80 9.96578428466 1 3 13 14 
 i 386 169.5 5.59166666667 0 9.88896868761 1 3 13 14 
 i 386 177.5 5.90277777778 0 9.47393118833 1 1 13 14 
 i 386 90 2.5 73 9.2108967825 -1 3 13 14 
 i 386 93.25 2.62638888889 80 9.2288186905 -1 3 13 14 
 i 386 98.25 2.82083333333 0 9.47393118833 -1 1 13 14 
 i 386 99.5 2.86944444444 80 9.64385618977 -1 3 13 14 
 i 386 107.5 3.18055555556 0 9.79585928322 -1 1 13 14 
 i 386 110.75 3.30694444444 77 9.2108967825 -1 3 13 14 
 i 386 115.75 3.50138888889 80 9.2288186905 -1 1 13 14 
 i 386 117.0 3.55 0 9.47393118833 -1 3 13 14 
 i 386 125.0 3.86111111111 77 9.64385618977 -1 3 13 14 
 i 386 128.25 3.9875 80 9.79585928322 -1 3 13 14 
 i 386 133.25 4.18194444444 80 9.2108967825 -1 3 13 14 
 i 386 134.5 4.23055555556 80 9.2288186905 -1 1 13 14 
 i 386 142.5 4.54166666667 80 9.47393118833 -1 3 13 14 
 i 386 145.75 4.66805555556 0 9.64385618977 -1 1 13 14 
 i 386 150.75 4.8625 0 9.79585928322 -1 3 13 14 
 i 386 152.0 4.91111111111 80 9.2108967825 -1 1 13 14 
 i 386 160.0 5.22222222222 0 9.2288186905 -1 3 13 14 
 i 386 163.25 5.34861111111 0 9.47393118833 -1 3 13 14 
 i 386 168.25 5.54305555556 80 9.64385618977 -1 3 13 14 
 i 386 169.5 5.59166666667 0 9.79585928322 -1 3 13 14 
 i 386 177.5 5.90277777778 0 9.2108967825 -1 1 13 14 
 i 386 90 2.5 80 9.05889368905 1 3 13 14 
 i 386 93.25 2.62638888889 0 9.2108967825 1 3 13 14 
 i 386 98.25 2.82083333333 0 9.2288186905 1 1 13 14 
 i 386 99.5 2.86944444444 80 9.38082178394 1 3 13 14 
 i 386 107.5 3.18055555556 0 9.47393118833 1 1 13 14 
 i 386 110.75 3.30694444444 0 9.05889368905 1 3 13 14 
 i 386 115.75 3.50138888889 73 9.2108967825 1 1 13 14 
 i 386 117.0 3.55 80 9.2288186905 1 3 13 14 
 i 386 125.0 3.86111111111 0 9.38082178394 1 3 13 14 
 i 386 128.25 3.9875 80 9.47393118833 1 3 13 14 
 i 386 133.25 4.18194444444 0 9.05889368905 1 3 13 14 
 i 386 134.5 4.23055555556 77 9.2108967825 1 1 13 14 
 i 386 142.5 4.54166666667 80 9.2288186905 1 3 13 14 
 i 386 145.75 4.66805555556 0 9.38082178394 1 1 13 14 
 i 386 150.75 4.8625 77 9.47393118833 1 3 13 14 
 i 386 152.0 4.91111111111 80 9.05889368905 1 1 13 14 
 i 386 160.0 5.22222222222 80 9.2108967825 1 3 13 14 
 i 386 163.25 5.34861111111 80 9.2288186905 1 3 13 14 
 i 386 168.25 5.54305555556 80 9.38082178394 1 3 13 14 
 i 386 169.5 5.59166666667 0 9.47393118833 1 3 13 14 
 i 386 177.5 5.90277777778 0 9.05889368905 1 1 13 14 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURCODA	   13  	14  0.08  80 ; 

;Candy tremolo
 i 387 90 2.5 1 3 4 201 1 13 15 
 i 387 93.25 2.62638888889 1 5 6 201 1 13 15 
 i 387 98.25 2.82083333333 1 7 8 201 1 13 15 
 i 387 99.5 2.86944444444 1 11 12 201 1 13 15 
 i 387 107.5 3.18055555556 1 5 13 201 1 13 15 
 i 387 110.75 3.30694444444 1 7 6 201 1 13 15 
 i 387 115.75 3.50138888889 1 11 8 201 1 13 15 
 i 387 117.0 3.55 1 3 12 201 1 13 15 
 i 387 125.0 3.86111111111 1 7 13 201 1 13 15 
 i 387 128.25 3.9875 1 11 4 201 1 13 15 
 i 387 133.25 4.18194444444 1 3 8 201 1 13 15 
 i 387 134.5 4.23055555556 1 5 12 201 1 13 15 
 i 387 142.5 4.54166666667 1 11 13 201 1 13 15 
 i 387 145.75 4.66805555556 1 3 4 201 1 13 15 
 i 387 150.75 4.8625 1 5 6 201 1 13 15 
 i 387 152.0 4.91111111111 1 7 12 201 1 13 15 
 i 387 160.0 5.22222222222 1 3 13 201 1 13 15 
 i 387 163.25 5.34861111111 1 5 4 201 1 13 15 
 i 387 168.25 5.54305555556 1 7 6 201 1 13 15 
 i 387 169.5 5.59166666667 1 11 8 201 1 13 15 
 i 387 177.5 5.90277777778 1 5 13 201 1 13 15 
 i 387 90 2.5 1 7 4 201 1 14 16 
 i 387 93.25 2.62638888889 1 11 6 201 1 14 16 
 i 387 98.25 2.82083333333 1 3 8 201 1 14 16 
 i 387 99.5 2.86944444444 1 5 12 201 1 14 16 
 i 387 107.5 3.18055555556 1 7 6 201 1 14 16 
 i 387 110.75 3.30694444444 1 11 8 201 1 14 16 
 i 387 115.75 3.50138888889 1 7 12 201 1 14 16 
 i 387 117.0 3.55 1 11 13 201 1 14 16 
 i 387 125.0 3.86111111111 1 5 8 201 1 14 16 
 i 387 128.25 3.9875 1 11 12 201 1 14 16 
 i 387 133.25 4.18194444444 1 5 13 201 1 14 16 
 i 387 134.5 4.23055555556 1 7 6 201 1 14 16 
 i 387 142.5 4.54166666667 1 5 12 201 1 14 16 
 i 387 145.75 4.66805555556 1 7 13 201 1 14 16 
 i 387 150.75 4.8625 1 11 6 201 1 14 16 
 i 387 152.0 4.91111111111 1 7 8 201 1 14 16 
 i 387 160.0 5.22222222222 1 11 13 201 1 14 16 
 i 387 163.25 5.34861111111 1 5 6 201 1 14 16 
 i 387 168.25 5.54305555556 1 11 8 201 1 14 16 
 i 387 169.5 5.59166666667 1 5 12 201 1 14 16 
 i 387 177.5 5.90277777778 1 7 6 201 1 14 16 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURCODA	   15  	16  0.21  80 ; candystrings tremolo

;Sensemble
 i 388 0 180 1.77 9 17 18 
 i 388 0 180 1.63 10 17 18 
 i 388 90 90 1.77 15 19 20 
 i 388 90 90 1.63 16 19 20 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURCODA	   17  	18  0.17  80 ; ensemble
$MIXDURCODA	   19  	20  0.18  80 ; candyensemble

;fluteverb
 i 400 52 133.5 0.1 0.2 0.95 11 12 21 22 

;   Sta  Dur  Ch1  Ch2 Gain  env		
$MIXDURCODA	   21  	22  0.77  96 ; fluteverb

i910 0   $DURC ;clear zaks

e ;the end


</CsScore>
</CsoundSynthesizer>
