<CsoundSynthesizer>
<CsOptions>
csound -RWfo dac

</CsOptions>
<CsInstruments>
iafno ftgen 1, 0, 65537, 10, 1 ; Sine wave.

sr = 44100
kr             =         4410
ksmps          =         10
nchnls         =         2


;=====================================
; REVERB INITIALIZATION
;=====================================

garvbsig       init      0


;=================================================
; INSTRUMENT 2 --- A NOISE BAND GLISSANDO
;=================================================

               instr     2

ipanfrq        =         p6
kfreq          =         p5
irandfrq       =         p7
irandamp       =         p8                                         
kramp          linseg    0,p3*.8,p4,p3*.2,0            ; THIS CONTROLS THE AMP OF RANDI
kenv1          linen     p4,0, p3,10                   ; THIS CONTROLS THE FRQ OF RANDI
krndmod        randh     irandamp,irandfrq
an             randi     kramp,kenv1
ao             oscil     an,kfreq,11                   ; ANOISE IS FED TO THE A INPUT OF AOSC
kpan           oscil     1,.09*ipanfrq,1
aosc2          reson     ao,kpan+100+krndmod,100,2     ; KPAN+100 IS OFFSET FOR FILTER SWEEP INPUT
               outs      aosc2*kpan,aosc2*(1-kpan)
garvbsig       =         garvbsig+(aosc2*.2)
               endin
          
;===================
; GLOBAL REVERB
;===================

               instr     99

a1             reverb2   garvbsig, p4, p5
               outs      a1,a1

garvbsig       =         0

               endin

</CsInstruments>
<CsScore>
f11 0 2048 10 1								;SINE WAVE hi-res

;THIS IS FOR REVERB SETTINGS
;===========================
;p1		 p2	 p3	 p4		 p5
;instr	strt dur	 rvbtime	 hfdif
i99		0	33	6		.2

;p1		p2		p3	p4		p5	  p6		 p7		 p8
;instr	strt		dur	envamp	kfreq  ipanfrq	 randfrq	 randamp
i2		0.000	10	4000		1000	  10		 15		 20000

i2		8.000	10	8000		1000	  0		 0	      0



</CsScore>
<CsArrangement>
</CsArrangement>
</CsoundSynthesizer>
