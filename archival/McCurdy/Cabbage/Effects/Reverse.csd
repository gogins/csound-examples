Reverse.csd
Iain McCurdy [2012]

INSTRUCTIONS
------------
Time L  --	length of the left channel delay buffer 
Time R  --	length of the right channel delay buffer
Spread	--	stereo spread of the two channel. 1 = hard left and right
Mix	--	dry/wet mix
Level	--	output level
Reverse --	(switch) between reversing and forwards
Link L&R--	pair the left and right Time controls

<Cabbage>
form caption("Reverse") size(455, 95), pluginID("rvrs")
image           bounds(0, 0, 455, 95), colour("darkslategrey"), shape("rounded"), outline("white"), line(4)
rslider  bounds( 10, 10,  75, 75), text("Time L"),   channel("timeL"),   range(0.10, 4, 1, 0.5),colour(200,255,255)  fontcolour(255,255,200)
rslider  bounds( 80, 10,  75, 75), text("Time R"),   channel("timeR"),   range(0.10, 4, 1, 0.5),colour(200,255,255)  fontcolour(255,255,200)
rslider  bounds(150, 10, 75, 75),  text("Spread"),   channel("spread"),  range(0, 1.00, 1),colour(200,255,255) fontcolour(255,255,200)
rslider  bounds(220, 10, 75, 75),  text("Mix"),      channel("mix"),     range(0, 1.00, 1),colour(200,255,255) fontcolour(255,255,200)
rslider  bounds(290, 10, 75, 75),  text("Level"),    channel("level"),   range(0, 1.00, 1, 0.5),colour(200,255,255) fontcolour(255,255,200)
checkbox bounds(370, 15, 100, 15), text("Reverse"),  channel("reverse"),  value(1), colour(255,255,  50)      fontcolour(255,255,200)
checkbox bounds(370, 35, 100, 15), text("Forward"),  channel("forward"),  value(0), colour(255,255,  50)      fontcolour(255,255,200)
checkbox bounds(370, 55, 100, 15), text("Link L&R"), channel("link"),  value(0), colour(255,255,  50)      fontcolour(255,255,200)
}
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-d -n
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

;Author: Iain McCurdy (2012)
;http://iainmccurdy.org/csound.html

opcode	Reverse, a, aKkk			;nb. CAPITAL K CREATE A K-RATE VARIABLE THAT HAS A USEFUL VALUE ALSO AT I-TIME
	ain,ktime,kreverse,kforward	xin			;READ IN INPUT ARGUMENTS
	;four windowing envelopes. An appropriate one will be chosen based on the reversed chunk duration
	ienv1	ftgenonce			0, 0, 131072, 7, 0, 1024,           1, 131072-(1024*2),            1,  1024,      0	;for longest chunk times
	ienv2	ftgenonce			0, 0, 131072, 7, 0, 4096,           1, 131072-(4096*2),           1,  4096,       0
	ienv3	ftgenonce			0, 0, 131072, 7, 0,16384,           1, 131072-(16384*2),          1, 16384,       0
	ienv4	ftgenonce			0, 0, 131072, 7, 0,32768,           1, 131072-(32768*2),          1, 32768,       0	;for shortest chunk times
	ktrig	changed	ktime			;IF ktime CONTROL IS MOVED GENERATE A MOMENTARY '1' IMPULSE
	if ktrig=1 then				;IF A TRIGGER HAS BEEN GENERATED IN THE LINE ABOVE...
		reinit	UPDATE			;...BEGIN A REINITILISATION PASS FROM LABEL 'UPDATE'
	endif					;END OF CONDITIONAL BRANCH
	UPDATE:					;LABEL CALLED 'UPDATE'
	itime	=	i(ktime)		;CREATE AN I-TIME VERSION OF ktime
	
	iratio	=	octave(1)
	aptr	phasor	(2/itime)		;CREATE A MOVING PHASOR THAT WITH BE USED TO TAP THE DELAY BUFFER
	if itime<0.2 then			;if chunk time is less than 0.2... (very short) 
	 aenv	table3	aptr,ienv4,1		;create amplitude envelope
	elseif itime<0.4 then
	 aenv	table3	aptr,ienv3,1
	elseif itime<2 then
	 aenv	table3	aptr,ienv2,1
	else					;other longest bracket of delay times
	 aenv	table3	aptr,ienv1,1
	endif
	aptr	=	aptr*itime		;SCALE PHASOR ACCORDING TO THE LENGTH OF THE DELAY TIME CHOSEN BY THE USER
 	abuffer	delayr	itime+.01		;CREATE A DELAY BUFFER
	atap	deltap3	aptr			;READ AUDIO FROM A TAP WITHIN THE DELAY BUFFER
	afwd	deltap	itime			;FORWARD DELAY
		delayw	ain			;WRITE AUDIO INTO DELAY BUFFER
	
	rireturn				;RETURN FROM REINITIALISATION PASS
	xout	(atap*aenv*kreverse)+(afwd*kforward)	;SEND AUDIO BACK TO CALLER INSTRUMENT. APPLY AMPLITUDE ENVELOPE TO PREVENT CLICKS.
endop


instr 1
ktimeL   chnget "timeL"
ktimeR   chnget "timeR"
kspread  chnget "spread"
kmix     chnget "mix"
klevel   chnget "level"
kreverse chnget "reverse"
kforward chnget "forward"

/* LINK */
klink chnget "link"
if klink=1 then
 ktrigL	changed	ktimeL,klink
 ktrigR	changed	ktimeR
 if ktrigL=1 then
  chnset	ktimeL,"timeR"
 elseif ktrigR=1 then
  chnset	ktimeR,"timeL"
 endif
endif

a1,a2	ins
arev1	Reverse	a1,ktimeL,kreverse,kforward
arev2	Reverse	a2,ktimeR,kreverse,kforward
kreverse	port	kreverse,0.5	;reverse switch will smoothly crossfade between forward and backward modes
a1	ntrpol	a1,arev1,kmix
a2	ntrpol	a2,arev2,kmix
a1	=	a1 * klevel
a2	=	a2 * klevel
kspread	scale	kspread,1,0.5 			; rescale from range 0 - 1 to 0.5 - 1
aL	sum	a1*kspread,a2*(1-kspread)	; create stereo mix according to Spread control
aR	sum	a2*kspread,a1*(1-kspread)	; create stereo mix according to Spread control
	outs	aL,aR
endin

</CsInstruments>

<CsScore>
i 1 0 [60*60*24*7]
</CsScore>

</CsoundSynthesizer>