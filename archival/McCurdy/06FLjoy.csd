;Written by Iain McCurdy, 2006

<CsoundSynthesizer>

<CsOptions>
-+rtaudio=PortAudio -b4096
</CsOptions>

<CsInstruments>

;DEMONSTRATION OF THE FLpanel OPCODE
;HORIZONTAL CLICK-AND-DRAGGING CONTROLS THE FREQUENCY OF THE OSCILLATOR
;VERTICAL CLICK-AND-DRAGGING CONTROLS THE AMPLITUDE OF THE OSCILLATOR

sr		=	44100
kr		=	4410
ksmps		=	10
nchnls		=	2

;		OPCODE	LABEL       | WIDTH | HEIGHT | X | Y
		FLpanel	"X Y Panel",   900,    400,   50,  50

iminx		=	200	;MINIMUM VALUE OUTPUT BY X MOVEMENT (FREQUENCY)
imaxx		=	5000	;MAXIMUM VALUE OUTPUT BY X MOVEMENT (FREQUENCY)
iminy		=	0	;MINIMUM VALUE OUTPUT BY Y MOVEMENT (AMPLITUDE)
imaxy		=	15000	;MAXIMUM VALUE OUTPUT BY Y MOVEMENT (AMPLITUDE)
iexpx		=	-1	;LOGARITHMIC CHANGE IN X DIRECTION
iexpy		=	0	;LINEAR CHANGE IN Y DIRECTION
idispx		=	-1	;DISPLAY HANDLE X DIRECTION (-1=NOT USED)
idispy		=	-1	;DISPLAY HANDLE Y DIRECTION (-1=NOT USED)
iwidth		=	800	;WIDTH OF THE X Y PANEL IN PIXELS
iheight		=	300	;HEIGHT OF THE X Y PANEL IN PIXELS
ix		=	50	;DISTANCE OF THE LEFT EDGE OF THE X Y PANEL FROM THE LEFT EDGE OF THE PANEL
iy		=	50	;DISTANCE OF THE TOP EDGE OF THE X Y PANEL FROM THE TOP EDGE OF THE PANEL
gkfreqx,gkampy,ihandlex,ihandley	FLjoy	"X - Frequency  Y - Amplitude", iminx, imaxx, iminy, imaxy, iexpx, iexpy, idispx, idispy, iwidth, iheight, ix, iy

		FLpanel_end	;END OF PANEL CONTENTS
		FLrun		;RUN THE WIDGET THREAD!

		instr 	1
ifn		=	1
asig		oscili	gkampy, gkfreqx, ifn
		outs	asig, asig
		endin	

</CsInstruments>

<CsScore>
f 1 0 1024 10 1		;FUNCTION TABLE THAT DEFINES A SINGLE CYCLE OF A SINE WAVE
i 1 0 3600		;INSTRUMENT 1 WILL PLAY A NOTE FOR 1 HOUR
</CsScore>

</CsoundSynthesizer>