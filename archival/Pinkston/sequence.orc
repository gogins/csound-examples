        sr      =       44100
        kr      =       4410
        ksmps   =       10
        nchnls  =       2
;======================================================================;
;                     Basic "Sequencer" Instrument                     ;
;                                                                      ;
; p3 = sequence dur  p4 = peak amp       p5 = fno for note information ;
; p6 = overall rise  p7 = overall decay  p8 = note rise  p9 = note dec ;
; p10 = ndx rise p11 = ndx dec p12 = max ndx p13 = carfac p14 = modfac ;
; note info format: pch, amp, dur; pch, amp, dur; ...                  ;
;======================================================================;
                instr   1
;------------------------------------------------;initialization block:
        ipkamp  =       p4
        iseqfn  =       p5
        irise   =       p6
        idecay  =       p7
        inrise  =       p8
        indec   =       p9
        indxris =       (p10 == 0 ? inrise : p10)
        indxdec =       (p11 == 0 ? indec : p11)
        indxmax =       p12
        icfac   =       p13
        imfac   =       p14
        inext   =       0                       ;initialize table index
noteinit:
        ipch    table   inext,iseqfn
        iampfac table   inext+1,iseqfn
        idur    table   inext+2,iseqfn
icps    =       cpspch(ipch)
        iamp    =       ipkamp*iampfac
        indx    =       indxmax*iampfac         ;map index to amp
        inext   =       inext + 3               ;set for next note
                print   ipch,iamp,idur,icps,indx
        kenv    linen   iamp,inrise*idur,idur,indec*idur
        kindex  linen	indx,indxris*idur,idur,indxdec*idur
        asig    foscili kenv,icps,icfac,imfac,kindex,1
                outs    asig,asig
                timout  0,idur,continue
                reinit  noteinit
                rireturn
continue:
                endin

;======================================================================;
;               Controlled Random Sequence Instrument                  ;
;                                                                      ;
; p3 = seq dur  p4 = dur fno   p5 = pch fno   p6 = amp fno             ;
; p7 = seq rise p8 = seq decay p9 = noteris p10 = notedec p11 = ndxmax ;
; p12 = pkamp p13 = carfac p14 = modfac p15 = dur seed p16 = pch seed  ;
; p17 = pan seed p18 = seed pch                                        ;
;======================================================================;
                instr   2
;------------------------------------------------;initialization block:
	idurfn	=	p4
        iintfn  =       p5
	iampfn	=	p6
	isrise	=	p7			;sequence rise time
	isdec	=	p8 			;sequence decay time
 	inrise	=	p9 			;note amp and ndx rise
	indec 	=	p10			;note amp and ndx decay
	ipkndx	=	p11
	ipkamp	=	p12
	icfac	=	p13
	imfac	=	p14
	iseed1	=	p15
	iseed2	=	p16
	iseed3	=	p17
        ioct    =       (p18 == 0 ? 8.00 : octpch(p18))  ;seed pitch
	ibase	=	6.00			;lowest expected pch
        irange  =       11.00 - ibase           ;range of expected pchs
        ipkdur  =       .5001                   ;used in amp mapping
;----------------------------------------------------------------------;
	kphrase	linen	1,isrise,p3,isdec	;phrase envelope
;----------------------------------------------------------------------;
noteinit:
        kdurloc rand    .5,iseed1               ;-.5 < kdurloc < +.5
        idurloc =       i(kdurloc)+.5           ;force an i-time value
        idur    table   idurloc,idurfn,1        ;select from dur table
        iamp    table   idur/ipkdur,iampfn,1    ;relate amp to dur
        kintloc rand    .5,iseed2               ;-.5 < kintloc < +.5
        iintloc =       i(kintloc)+.5           ;= 0 < kintloc < 1
        intrvl  table   iintloc,iintfn,1        ;get interval to next pitch
        ioct    =       ioct + octpch(intrvl)   ;convert to oct notation
        icps    =       cpsoct(ioct)            ;and cps for foscil
        kpan    rand    .5,iseed3               ;-.5 < kpan < +.5
        ipan    =       i(kpan)+.5
        iseed1  =       -1              ;after first note, don't restart rands
        iseed2  =       -1
        iseed3  =       -1

        ilfac   =       ipan
        ileft   =       sqrt(ilfac)
        iright  =       sqrt(1-ilfac)
        indx    =       (irange-(ioct-ibase))*ipkndx ;map ndx inv of pch
continue:
                if      (intrvl == 0) goto rest
        knote   envlpx  1,inrise*idur,idur,indec*idur,7,.5,.01,-.9
        asig    foscili knote*iamp*ipkamp,icps,icfac,imfac,knote*indx,1
        asig    =       asig*kphrase
                outs    asig*ileft,asig*iright
rest:           timout  0,idur,exit             ;wait idur secs, then reinit...
                reinit  noteinit
                print   idur,iamp,intrvl,ioct,ipan
                rireturn
exit:
                endin
