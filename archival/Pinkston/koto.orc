;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         basic koto orchestra file                              ;
;                                                                ;
;         p3 = duration        p4 = amplitude                    ;
;         p5 = pitch in pch    p6 = pitch bend in oct.decimal    ;
;                                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          sr = 44100
          kr = 4410
       ksmps = 10
      nchnls = 1 

         instr 1
	ihz	=	cpspch(p5)
	ihz2	=       ihz * 2.0006
	ihz3	=	ihz * 1.9999
	ihz4	=	ihz * 1.0005
	ihz5	=	ihz * .9998
	koct	init	octcps(ihz)
	koct2	init	octcps(ihz2)
	koct3	init	octcps(ihz3)
	koct4	init	octcps(ihz4)
	koct5	init	octcps(ihz5)
        kbend   oscil1i 0.15,p6,p3,4;   /* p6 in oct.decimal */
        khz	=	cpsoct(koct+kbend)
        khz2	=	cpsoct(koct2+kbend)
        khz3	=	cpsoct(koct3+kbend)
        khz4	=	cpsoct(koct4+kbend)
        khz5	=	cpsoct(koct5+kbend)
      aplk1	pluck	(p4*.42),khz,ihz,6,3,1
		timout	0.0,p3*.2,continue         ;.002 not p3;
koto2:	aplk2	pluck	(p4*.62),khz2,ihz2,6,3,1
		timout	0.0,p3*.4,continue        ; .oo4 not p3;
koto3:	aplk3	pluck	(p4*.62),khz3,ihz3,6,3,1
		timout	0.0,p3*.6,continue       ;  .005 not p3;
koto4:	aplk4	pluck	(p4*.62),khz4,ihz4,6,3,1
		timout	0.0,p3*.8,continue      ;.oo7 not  p3;
koto5:	aplk5	pluck	(p4*.62),khz5,ihz5,6,3,1

continue:
	asignal	=	aplk1+aplk2+aplk3+aplk4+aplk5
	asig	envlpx	asignal,.001,p3,(p3*.001),4,1.02,.008
	;asig	envlpx	asignal,.06,p3,(p3*.1),4,1.02,.008 ;
			out	asig
		endin

