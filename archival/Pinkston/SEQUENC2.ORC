        sr      =       22050
        kr      =       2205
        ksmps   =       10
        nchnls  =       2
;======================================================================;
; Two instruments which demonstrate how to create phrases or entire    ;
; pieces with very few i-cards.  RP                                    ;
;======================================================================;
;
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
        iprise  =       p6                      ;phrase rise
        ipdec   =       p7                      ;phrase decay
        inrise  =       p8
        indec   =       p9
        indxris =       (p10 == 0 ? inrise : p10)
        indxdec =       (p11 == 0 ? indec : p11)
        indxmax =       p12
        icfac   =       p13
        imfac   =       p14
        inext   =       0                       ;initialize table index
;--------------------- The Phrase Envelope ----------------------------;
        kphrase expseg  .001,iprise,1,p3-iprise-ipdec,1,ipdec,.001
;----------------------------------------------------------------------;
noteinit:
        ipch    table   inext,iseqfn
        iampfac table   inext+1,iseqfn
        idur    table   inext+2,iseqfn
        icps    =       cpspch(ipch)
        iamp    =       ipkamp*iampfac
        indx    =       indxmax*iampfac         ;map index to amp
        inext   =       inext + 3               ;set for next note
		print	ipch,iamp,idur,icps,indx,inext
        kenv    linen   iamp,inrise*idur,idur,indec*idur
        kindex  linen	indx,indxris*idur,idur,indxdec*idur
        asig    foscili kenv*kphrase,icps,icfac,imfac,kindex,1
                outs    asig,asig
                timout  0,idur,continue
                reinit  noteinit
                rireturn
continue:
                endin

;============================================================================;
;                  Controlled Random Sequence Instrument                     ;
;                                                                            ;
; p3 = seq dur  p4 = peak amp   p5 = dur fno    p6 = pch fno    p7 = amp fno ;
; p8 = phrase rise p9 = phrase decay  p10 = noteris   p11 = notedec          ;
; p12 = durseed p13 = pchseed   p14 = panseed                                ;
;============================================================================;
                instr   2
;------------------------------------------------;initialization block:
        istart   =      p2                      ;current start time
        ipkamp  =       p4
        idurfn  =       p5
        ipchfn  =       p6
        iampfn  =       p7
        iprise  =       p8                      ;phrase rise time
        ipdec   =       p9                      ;phrase decay time
        inrise  =       p10                     ;note amp rise
        indec   =       p11                     ;note amp decay
        iseed1  =       p12                     ;rand dur seed
        iseed2  =       p13                     ;rand pch seed
        iseed3  =       p14                     ;rand pan seed
	ibase	=	6.00			;lowest expected pch
        irange  =       11.25 - ibase           ;range of expected pchs
        ipkdur  =       .2501                   ;used in amp mapping
;--------------------- The Phrase Envelope ----------------------------;
        kphrase expseg  .001,iprise,1,p3-iprise-ipdec,1,ipdec,.001
;----------------------------------------------------------------------;
        kdurloc rand    .5,iseed1               ;get random table indices
        kpchloc rand    .5,iseed2               ;between -.5 and +.5
        kpan    rand    .5,iseed3
noteinit:
        idurloc =       .5+i(kdurloc)           ;make a positive i-time var
        idur    table   idurloc,idurfn,1        ;select from dur table
        iamp    table   idur/ipkdur,iampfn,1    ;relate amp to dur
        iamp    =       .25 + .75 * iamp        ;range from .25 to 1
        ipchloc =       .5+i(kpchloc)           ;make a positive i-time var
        ipch    table   ipchloc,ipchfn,1        ;select from pch table
        icps    =       (ipch == 0 ? 0 : cpspch(ipch)) ;convert to both cps...
        ioct    =       octpch(ipch)            ;and octave formats
        ilfac   =       i(kpan)+.5              ;positive left channel factor
        ileft   =       sqrt(ilfac)
        iright  =       sqrt(1-ilfac)
continue:
                if      (icps == 0) goto rest
        knote   expseg  .001,inrise*idur,1,idur-idur*(inrise+indec),1,indec*idur,.001
        asig    pluck   knote*iamp*ipkamp,icps,icps,0,1,0,0
	asig	=	asig*kphrase
                outs    asig*ileft,asig*iright
rest:           timout  0,idur,exit
                reinit  noteinit
                print   istart,ipch,idur,iamp
istart          =       istart+idur
                rireturn
exit:
                endin
