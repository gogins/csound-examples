; SPIRITUS SANCTUS (2015) for realtime Android Csound - by Arthur B. Hunkins
; Includes HTML5 performance GUI for all size Android smartphones and tablets
;   GUI is at bottom of file, and contains 9 sliders and 12 momentary-contact buttons
; Requires Android OS 4.2.2+, and Csound6[.05].apk or higher
;   Downloadable from http://sourceforge.net/projects/csound/files/csound6/Csound6.05/
;   Run Csound6, and Browse to (Open) this file
;   In case of audio glitches, reduce the value of sr (Sample Rate, see below)
;    progressively to 32000, 22050, 11025 or 8000 until glitching disappears.

<CsoundSynthesizer>
<CsOptions>

-odac -m0d --expression-opt -b512 -B2048

</CsOptions>
<CsInstruments>

sr      =	44100 ; Sample Rate
ksmps	=	100
nchnls  =       2

	instr 1
   
gktset  init     1
k1      chnget   "but1"
k1a     trigger  k1, .5, 0
        if k1a == 1 then
gktset  =        1
        endif
k2      chnget   "but2"
k2a     trigger  k2, .5, 0
        if k2a == 1 then
gktset  =        2
        endif
k3      chnget   "but3"
k3a     trigger  k3, .5, 0
        if k3a == 1 then
gktset  =        3
        endif
k4      chnget   "but4"
k4a     trigger  k4, .5, 0
        if k4a == 1 then
gktset  =        4
        endif
k5      chnget   "but5"
k5a     trigger  k5, .5, 0
        if k5a == 1 then
gktset  =        5
        endif
k6      chnget   "butt6"
k6a     trigger  k6, .5, 0
        if k6a == 1 then
gktset  =        6
        endif
kstart  changed  gktset
	if kstart == 1 then
        event "i", -2, 0, 0
        event "i", -3, 0, 0
        event "i", 2, 0, -1
        event "i", 3, 0, -1
	endif

        endin

        instr 2
   
gitset  =      i(gktset)
	if gitset == 1 then
gi1a	= 	 0
gi1b 	= 	 .12	
gi1c 	= 	 .17	
gi1d 	= 	 .4
gi1e 	= 	 400
gi1f 	= 	 1
gi1g 	= 	 1
gi2a 	= 	 .6
gi2b 	= 	 400.25
	elseif gitset == 2 then
gi1a 	= 	 0	
gi1b 	= 	 .25	
gi1c 	= 	 .2	
gi1d 	= 	 .2
gi1e 	= 	 200
gi1f 	= 	 2
gi1g 	= 	 2
gi2a 	= 	 .3
gi2b 	=  	 200.125
	elseif gitset == 3 then
gi1a 	=	 0	
gi1b 	=	 .25	
gi1c 	=	 .2	
gi1d 	=	 .1
gi1e 	=	 133
gi1f 	=	 3
gi1g 	=	 2
gi2a 	=	 .15
gi2b 	=	 133.0833
	elseif gitset == 4 then
gi1a 	=	 0	
gi1b 	=	 .25	
gi1c 	=	 .2	
gi1d 	=	 .1
gi1e 	=	 100
gi1f 	=	 4
gi1g 	=	 3
gi2a 	=	 .15
gi2b 	=	 100.0625
	elseif gitset == 5 then
gi1a 	=	 .5	
gi1b 	=	 .8	
gi1c 	=	 .1	
gi1d 	=	 .2
gi2a 	=	 .3
gi2b 	=	 400.25
	elseif gitset == 6 then
gi1a 	=	 .5	
gi1b 	=	 .8	
gi1c 	=	 .1	
gi1d 	=	 .2
gi2a 	=	 .3
gi2b 	=	 400.25
        endif
gkamp	chnget   "slider1"
gkamp   port     gkamp, .2
gktimb  chnget   "slider2"
gktimb  =        (gktimb * (gi1b - gi1a)) + gi1a
gktimb  port     gktimb, .2
gktimb2 chnget   "slider3"
gktimb2 port     gktimb2, .2
gkmod   chnget   "slider4"
gkmod   =        (gkmod * 2) + .5 
kmod2   rspline  0, gi1c, gkmod, gkmod * 2.5
kjit    jitter   gi1d, 100, 150
        if gitset < 5 then
aout    gbuzz    15000 * gkamp, gi1e + kjit, 50, gi1f, gktimb + (kmod2 * gktimb2), gi1g
        else
aout    vco2     15000 * gkamp, 400 + kjit, 4, gktimb + (kmod2 * gktimb2), 0, (gitset == 5? .25: .085)
        endif
        outs     aout, aout * .6

        endin
        
        instr 3
        
krand   init     0
ktrack  init     0
kfreq3  init     0
kamp    chnget   "slider5"
kamp    port     kamp, .2
ktimb   chnget   "slider6"
ktimb   =        (ktimb * (gi1b - gi1a)) + gi1a
ktimb   port     ktimb, .2
ktimb2  chnget   "slider7"
ktimb2  port     ktimb2, .2
kmod    chnget   "slider8"
kmod    =        (kmod * 2) + .5 
kmod2   rspline  0, gi1c, kmod, kmod * 2.5
kfreq   chnget   "slider9"
kfreq2  rspline  0, frac(gi2b) * 6, 1, 1.75
k1      chnget   "butt7"
k1a     trigger  k1, .5, 0
        if k1a == 1 then
kfreq3  =        0
        endif
k2      chnget   "butt8"
k2a     trigger  k2, .5, 0
        if k2a == 1 then
kfreq3  =        .25
        endif
k3      chnget   "butt9"
k3a     trigger  k3, .5, 0
        if k3a == 1 then
kfreq3  =        .5
        endif
k4      chnget   "butt10"
k4a     trigger  k4, .5, 0
        if k4a == 1 then
kfreq3  =        .75
        endif
k5      chnget   "butt11"
k5a     trigger  k5, .5, 0
        if k5a == 1 then
kfreq3  =        1
        endif
k6      chnget   "butt12"
k6a     trigger  k6, .5, 0
        if k6a == 1 then
ktrack  =        (ktrack == 0? 1: 0)
        endif
kfreq3a port     kfreq3, .2
kjit    jitter   gi2a, 100, 150
kamp2   =        gkamp
kamp    =        (ktrack == 0? kamp: kamp2)
        if gitset < 5 then
aout    gbuzz    15000 * kamp, gi2b + kjit + (kfreq * frac(gi2b) * 4) + (kfreq2 * kfreq3a), 50, gi1f, ktimb + (kmod2 * ktimb2), gi1g
        else
aout    vco2     15000 * kamp, gi2b + kjit + (kfreq * frac(gi2b) * 4) + (kfreq2 * kfreq3a), 4, ktimb + (kmod2 * ktimb2), 0, (gitset == 5? .25: .085)
        endif
        outs     aout * .6, aout

        endin

</CsInstruments>
<CsScore>

f1 0 16384 11 1
f2 0 16384 11 20 1 .01
f3 0 16384 11 50 1 .01

i1 0 3600
i2 0 -1
i3 0 -1

</CsScore>
</CsoundSynthesizer>

<html>
<head>
<style type="text/css">

.noselect {
        -webkit-user-select: none;
}

/* this is the actual slider */
input[type='range'] {
	-webkit-appearance: none;
	background-color: silver; /* user choice */
        height: 100%;
    	width: 100%;
}
/* this is the slider knob */
input[type='range']::-webkit-slider-thumb {
    	-webkit-appearance: none;
    	height: 92%; /* 84% for one-line labels */
    	width: 7px;  /* user choice */
    	background: yellow; /* user choice */
}
.sliders {
        width: 100%;
}        
.sliders td {
        padding: 0% 0 0% 0; /* 0 0 0 0 to 2% 0 2% 0 or more */
/* adding "-condensed" to font name reduces label length slightly,
   while also requiring a bit more vertical space */
        font-family: sans-serif;
        font-size: 100%; /* 100% and up */ 
        text-align: center;
	border-width: 2px; /* 0px to 2px recommended */
	border-style: solid;
	border-color: transparent;
    	color: white; /* user choice */
	background-color: teal; /* user choice */
}

/* buttons are momentary-contact; they send Csound a 1 upon touch
   and after a 30ms wait, a 0 */
.buttons {
        width: 100%; /* 100% or less, horizontally centered */
}        
.buttons td {
        padding: 0% 0 0% 0; /* 0 0 0 0 to 2% 0 2% 0 or more */
        text-align: center;
	background-color: cadetblue; /* user choice */
}
.button {
/* adding "-condensed" to font name can permit more label characters,
   while also requiring a bit more vertical space */
        font-family: sans-serif;
	font-size: 100%; 
    	color: teal;
}
</style>

<script>

function wait() {
        var ms = 30;  
        ms += new Date().getTime();        
        while (new Date() < ms){};
        return;
}

function slider1(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider1', numberValue);
}
function slider2(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider2', numberValue);
}
function slider3(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider3', numberValue);
}
function slider4(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider4', numberValue);
}
function slider5(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider5', numberValue);
}
function slider6(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider6', numberValue);
}
function slider7(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider7', numberValue);
}
function slider8(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider8', numberValue);
}
function slider9(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider9', numberValue);
}

function wait() {
        var ms = 30;  
        ms += new Date().getTime();        
        while (new Date() < ms){};
        return;
}

function butt1() {
        csound.setControlChannel('but1', 1);
        wait();
        csound.setControlChannel('but1', 0);
}
function butt2() {
        csound.setControlChannel('but2', 1);
        wait();
        csound.setControlChannel('but2', 0);
}
function butt3() {
        csound.setControlChannel('but3', 1);
        wait();
        csound.setControlChannel('but3', 0);
}
function butt4() {
        csound.setControlChannel('but4', 1);
        wait();
        csound.setControlChannel('but4', 0);
}
function butt5() {
        csound.setControlChannel('but5', 1);
        wait();
        csound.setControlChannel('but5', 0);
}
function butt6() {
        csound.setControlChannel('butt6', 1);
        wait();
        csound.setControlChannel('butt6', 0);
}
function butt7() {
        csound.setControlChannel('butt7', 1);
        wait();
        csound.setControlChannel('butt7', 0);
}
function butt8() {
        csound.setControlChannel('butt8', 1);
        wait();
        csound.setControlChannel('butt8', 0);
}
function butt9() {
        csound.setControlChannel('butt9', 1);
        wait();
        csound.setControlChannel('butt9', 0);
}
function butt10() {
        csound.setControlChannel('butt10', 1);
        wait();
        csound.setControlChannel('butt10', 0);
}
function butt11() {
        csound.setControlChannel('butt11', 1);
        wait();
        csound.setControlChannel('butt11', 0);
}
function butt12() {
        csound.setControlChannel('butt12', 1);
        wait();
        csound.setControlChannel('butt12', 0);
}

</script>
</head>
<body>
<div class="noselect">

<b>SPIRITUS SANCTUS (2015)</b> &nbsp; Art Hunkins

<table class="sliders">
<colgroup>
  <col width="">
  <col width="100%">
</colgroup>
<tr>
<td>
<label for=slider1>1 Amplitude1</label>
<td>
<input type=range min=0 max=1 value=0 id=slider1 step=0.001 oninput="slider1(value)">
<tr>
<td>
<label for=slider2>2 Timbre1/1</label>
<td>
<input type=range min=0 max=1 value=0 id=slider2 step=0.001 oninput="slider2(value)">
<tr>
<td>
<label for=slider3>3 Timbre1/2</label>
<td>
<input type=range min=0 max=1 value=0 id=slider3 step=0.001 oninput="slider3(value)">
</tr>
<tr>
<td>
<label for=slider4>4 Mod Factor1</label>
<td>
<input type=range min=0 max=1 value=0 id=slider4 step=0.001 oninput="slider4(value)">
</tr>
<tr>
<td>
<label for=slider5>5 Amplitude2</label>
<td>
<input type=range min=0 max=1 value=0 id=slider5 step=0.001 oninput="slider5(value)">
</tr>
<tr>
<td>
<label for=slider6>6 Timbre2/1</label>
<td>
<input type=range min=0 max=1 value=0 id=slider6 step=0.001 oninput="slider6(value)">
</tr>
<tr>
<td>
<label for=slider7>7 Timbre2/2</label>
<td>
<input type=range min=0 max=1 value=0 id=slider7 step=0.001 oninput="slider7(value)">
</tr>
<tr>
<td>
<label for=slider8>8 Mod Factor2</label>
<td>
<input type=range min=0 max=1 value=0 id=slider8 step=0.001 oninput="slider8(value)">
<tr>
<td>
<label for=slider9>9 Beat Frequency</label>
<td>
<input type=range min=0 max=1 value=0 id=slider9 step=0.001 oninput="slider9(value)">
</tr>
</table>

<table class="buttons" style="margin: auto;">
<tr>
<!-- # of maximum characters per label depends on button font-size & family --!>
<!-- # of characters should be the same for each button per row --!>
<td>
<button class="button" onclick="butt1()">TS1</button>
<td>
<button class="button" onclick="butt2()">TS2</button>
<td>
<button class="button" onclick="butt3()">TS3</button>
<td>
<button class="button" onclick="butt4()">TS4</button>
<td>
<button class="button" onclick="butt5()">TS5</button>
<td>
<button class="button" onclick="butt6()">TS6</button>
</tr>
<tr>
<td>
<button class="button" onclick="butt7()">Rd1</button>
<td>
<button class="button" onclick="butt8()">Rd2</button>
<td>
<button class="button" onclick="butt9()">Rd3</button>
<td>
<button class="button" onclick="butt10()">Rd4</button>
<td>
<button class="button" onclick="butt11()">Rd5</button>
<td>
<button class="button" onclick="butt12()"><b>1M?</b></button>
</tr>
</table>

</div>

</body>
</html> 