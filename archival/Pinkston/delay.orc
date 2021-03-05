        sr      =       44100
        kr      =       4410
        ksmps   =       10
        nchnls  =       1

;==========================================================================;
;               Example Delay Line Instrument                              ;
;                                                                          ;
;       p4 = ampfac     p5 = soundin#   p6 = maxdel     p7 = basedel       ;
;       p8 = pkvardel   p9 = vardelhz  p10 = vardelfn  p11 = feedfac       ;
;==========================================================================;

                instr   1
        iampfac =       (p4 == 0 ? 1 : p4)
        imaxdel =       p6
        ibase   =       p7
        ivary   =       p8
        ivarhz  =       p9
        ivarfn  =       p10
        ifeed   =       p11
        isrcfac =       (p12 == 0 ? 1 : p12)
        idelfac =       (p13 == 0 ? 1 : p13)

        avarsig init    0

	avardel oscili  ivary,ivarhz,ivarfn
	avardel =       ibase+avardel
        asource soundin p5

        ainsig  =       asource+avarsig*ifeed

	adelsig delayr  imaxdel
	avarsig deltapi avardel
		delayw  ainsig
	aoutsig =       asource*isrcfac+avarsig*idelfac

		out     aoutsig*iampfac
		endin

