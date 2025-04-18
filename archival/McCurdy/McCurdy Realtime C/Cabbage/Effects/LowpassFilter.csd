<Cabbage>
form caption("Lowpass Filter") size(435, 90), pluginID("LPFl")
image pos(0, 0),               size(435, 90), colour(  70, 90,100), shape("rounded"), outline("white"), line(4) 
label    bounds( 22, 22, 60, 11), text("INPUT"), fontcolour("white")
combobox bounds( 10, 33, 60, 20), channel("input"), value(1), text("Live","Tone","Noise")
rslider  bounds( 75, 11, 70, 70), channel("cf"),        text("Freq."), colour(  0, 40, 50), tracker(200,240,250), 		fontcolour("white"), 		range(20, 20000, 20000, 0.333)
rslider  bounds(140, 11, 70, 70), channel("res"),       text("Res."),  colour(  0, 40, 50), tracker(200,240,250), 		fontcolour("white"),		range(0,1.00,0)
rslider  bounds(205, 11, 70, 70), channel("mix"),       text("Mix"),   colour(  0, 40, 50), tracker(200,240,250),		fontcolour("white"), 	range(0,1.00,1)
button   bounds(280, 10, 80, 20), channel("steepness"), text("24dB/oct", "12dB/oct"), value(0)
label    bounds(290, 30, 80, 12), text("Steepness"), FontColour("white")
checkbox bounds(280, 50, 80, 15), channel("ResType"), FontColour("white"),  value(0), text("Resonant"), colour(yellow)
rslider  bounds(360, 11, 70, 70), text("Level"),                       colour(  0, 40, 50), tracker(200,240,250),		fontcolour("white"), 		channel("level"), 	range(0, 1.00, 1)
}
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-d -n
</CsOptions>

<CsInstruments>

sr 		= 	44100	;SAMPLE RATE
ksmps 		= 	32	;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls 		= 	2	;NUMBER OF CHANNELS (2=STEREO)
0dbfs		=	1

;Author: Iain McCurdy (2012)

instr	1
	kcf		chnget	"cf"				;
	kres		chnget	"res"				;
	kmix		chnget	"mix"				;
	ksteepness	chnget	"steepness"			;
	kResType	chnget	"ResType"			;
	klevel		chnget	"level"				;
	kporttime	linseg	0,0.001,0.02
	kcf	portk	kcf,kporttime
	/* INPUT */
	kinput		chnget	"input"
	if kinput=1 then
	 aL,aR	ins
	elseif kinput=2 then
	 aL	vco2	0.2, 300
	 aR	=	aL
	else
	 aL	pinkish	0.2
	 aR	pinkish	0.2
	endif
	if ksteepness==0&&kResType!=1 then
	 aFiltL	tone	aL,kcf
	 aFiltR	tone	aR,kcf
        elseif ksteepness==1&&kResType!=1 then
	 aFiltL	butlp	aL,kcf
	 aFiltR	butlp	aR,kcf
        elseif kResType==1 then
	 aFiltL	moogladder	aL,kcf,kres
	 aFiltR	moogladder	aR,kcf,kres        
	endif
	aL	ntrpol	aL,aFiltL,kmix
	aR	ntrpol	aR,aFiltR,kmix
		outs	aL*klevel,aR*klevel
endin
		
</CsInstruments>

<CsScore>
i 1 0 [3600*24*7]
</CsScore>

</CsoundSynthesizer>
