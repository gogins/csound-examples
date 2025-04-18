;Written by Iain McCurdy, 2006

<CsoundSynthesizer>

<CsOptions>
-+rtaudio=PortAudio -b4096
</CsOptions>

<CsInstruments>

;DEMONSTRATION OF THE FLcount OPCODE
;CLICKING ON THE SINGLE ARROW BUTTONS INCREMENTS THE OSCILLATOR IN SEMITONE STEPS
;CLICKING ON THE DOUBLE ARROW BUTTONS INCREMENTS THE OSCILLATOR IN OCTAVE STEPS

sr		=	44100
kr		=	4410
ksmps		=	10
nchnls		=	2

;		OPCODE	LABEL       | WIDTH | HEIGHT | X | Y
		FLpanel	"Counter",     900,     400,  50,  50

imin		=	5	;MINIMUM VALUE OUTPUT BY COUNTER
imax		=	12	;MAXIMUM VALUE OUTPUT BY COUNTER
istep1		=	.01	;SINGLE ARROW STEP SIZE (SEMITONES)
istep2		=	1	;DOUBLE ARROW STEP SIZE (OCTAVE)
itype		=	1	;COUNTER TYPE (1=DOUBLE ARROW COUNTER)
iwidth		=	200	;WIDTH OF THE COUNTER IN PIXELS
iheight		=	30	;HEIGHT OF THE COUNTER IN PIXELS
ix		=	50	;DISTANCE OF THE LEFT EDGE OF THE COUNTER FROM THE LEFT EDGE OF THE PANEL
iy		=	50	;DISTANCE OF THE TOP EDGE OF THE COUNTER FROM THE TOP EDGE OF THE PANEL
iopcode		=	-1	;SCORE EVENT TYPE (-1=IGNORED)
gkpch,ihandle 	FLcount  "pitch in pch format", imin, imax, istep1, istep2, itype, iwidth, iheight, ix, iy, iopcode

		FLpanel_end	;END OF PANEL CONTENTS
		FLrun		;RUN THE WIDGET THREAD

		instr 	1
iamp		=	15000
ifn		=	1
;OUTPUT		OPCODE	AMPLITUDE |  FREQUENCY   | FUNCTION_TABLE
asig		oscili	iamp,      cpspch(gkpch),       ifn	;cpsoct() CONVERTS A pch FORMAT PITCH EXPRESSION TO A cps FORMAT PITCH EXPRESSION
		outs	asig, asig
		endin
		
</CsInstruments>

<CsScore>
f 1 0 129 10 1		;FUNCTION TABLE THAT DEFINES A SINGLE CYCLE OF A SINE WAVE
i 1 0 3600		;INSTRUMENT 1 WILL PLAY A NOTE FOR 1 HOUR
</CsScore>

</CsoundSynthesizer>