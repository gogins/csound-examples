; wguide1.csd
; written by Iain McCurdy 2013

; frequency of the wave guide can be determined either in hertz of as a note number

<Cabbage>
form caption("wguide1") size(415,210)
image           bounds(0, 0, 415,125), colour(125, 95, 55), shape("sharp"), outline("white"), line(2) 
checkbox bounds( 20, 10,120, 20), text("Keyboard Input"), channel("input") fontcolour("white") colour(yellow) value(0)
rslider  bounds( 10, 41, 70, 70),  text("Frequency"),  channel("freq"),      tracker(225,195,155), range(8.2, 12542, 160, 0.25), colour( 85, 55,15), fontcolour(white)
rslider  bounds( 75, 41, 70, 70),  text("Note Num."),  channel("notnum"),    tracker(225,195,155), range(0, 127, 51, 1,1),     colour( 85, 55,15), fontcolour(white)
rslider  bounds(140, 41, 70, 70), text("Cutoff"),     channel("cutoff"),    tracker(225,195,155), range(20,20000,8000,0.25),  colour( 85, 55,15), fontcolour(white)
rslider  bounds(205, 41, 70, 70), text("Feedback"),   channel("feedback"),  tracker(225,195,155), range(-0.99999, 0.99999, 0.8),  colour( 85, 55,15), fontcolour(white)
rslider  bounds(270, 41, 70, 70), text("Mix"),        channel("mix"),       tracker(225,195,155), range(0, 1.00, 0.7),        colour( 85, 55,15), fontcolour(white)
rslider  bounds(335, 41, 70, 70), text("Level"),      channel("level"),     tracker(225,195,155), range(0, 1.00, 0.7),        colour( 85, 55,15), fontcolour(white)
keyboard bounds(  0,126, 415, 84)

label   bounds(259,  7,160, 25), text("WAVEGUIDE"), fontcolour( 40, 20,  0)
label   bounds(260,  8,160, 25), text("WAVEGUIDE"), fontcolour(200,170,130)

</Cabbage>

<CsoundSynthesizer>

<CsOptions>
;-d -n
-dm0 -n -+rtmidi=null -M0
</CsOptions>

<CsInstruments>

sr 		= 	44100	;SAMPLE RATE
ksmps 		= 	32	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 		= 	2	;NUMBER OF CHANNELS (2=STEREO)
0dbfs		=	1
massign	0,2

;Author: Iain McCurdy (2012)


instr	1
	gkinput	chnget	"input"
	gasigL, gasigR	ins
	event_i	"i",2,0,-1
	ktrig	trigger	gkinput,0.5,2
	if ktrig=1 then
	 if gkinput=0 then
	  event	"i",2,0,-1
	 else
	  event	"i",-2,0,0
	 endif
	endif
endin



instr	2
	gkfreq		chnget	"freq"					;READ WIDGETS...
	gknotnum	chnget	"notnum"				;
	ktrig1		changed	gkfreq
	ktrig2		changed	gknotnum

	/* MIDI AND GUI INTEROPERABILITY */
	iMIDIActiveValue	=	1		;IF MIDI ACTIVATED
	iMIDIflag		=	0		;IF NOT MIDI ACTIVATED
	mididefault	iMIDIActiveValue, iMIDIflag	;IF NOTE IS MIDI ACTIVATED REPLACE iMIDIflag WITH iMIDIActiveValue (1)

	if iMIDIflag==1 then				;IF THIS IS A MIDI ACTIVATED NOTE...
	 if gkinput=0 then
	  turnoff
	 endif
	 icps	cpsmidi					;READ MIDI PITCH VALUES - THIS VALUE CAN BE MAPPED TO GRAIN DENSITY AND/OR PITCH DEPENDING ON THE SETTING OF THE MIDI MAPPING SWITCHES
	 gkfreq	=		icps
	else						;OTHERWISE WHEN NON-MIDI
	 if ktrig1=1 then				;DUAL FREQUENCY AND NOTE NUMBER CONTROLS
	  koct	=	octcps(gkfreq)
	  chnset	(koct-3)*12,"notnum"
	 elseif ktrig2=1 then
	  chnset	cpsmidinn(gknotnum),"freq"
	 endif
	endif						;END OF THIS CONDITIONAL BRANCH

	gkcutoff	chnget	"cutoff"				;
	gkfeedback	chnget	"feedback"				;
	gkmix		chnget	"mix"					;
	gklevel		chnget	"level"					;
	kporttime	linseg	0,0.01,0.03				;CREATE A VARIABLE THAT WILL BE USED FOR PORTAMENTO TIME
	gkfreq		portk	gkfreq,kporttime
	afreq		interp	gkfreq
	aresL 		wguide1 gasigL, afreq, gkcutoff, gkfeedback
	aresR 		wguide1 gasigR, afreq, gkcutoff, gkfeedback
	aresL 		dcblock2	aresL
	aresR 		dcblock2	aresR
	gkmix		portk	gkmix,kporttime
	amixL		ntrpol	gasigL,aresL,gkmix
	amixR		ntrpol	gasigR,aresR,gkmix
	gklevel		portk	gklevel,kporttime
	aenv		linsegr	0,0.05,1,0.5,0
			outs	amixL*gklevel*aenv, amixR*gklevel*aenv		;WGUIDE1 OUTPUTS ARE SENT OUT
endin
		
</CsInstruments>

<CsScore>
i 1 0 [3600*24*7]
</CsScore>


</CsoundSynthesizer>



























