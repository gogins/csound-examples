; PEACE BE WITH YOU (2015) for realtime Csound6 - by Arthur B. Hunkins
; Includes HTML5 performance GUI for all size Android smartphones and tablets
;   GUI is at bottom of file, and contains 12 sliders and 9 momentary-contact buttons
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

sr      = 44100 ; Sample Rate
ksmps   = 100
nchnls  = 2

        seed 0

        instr 1

gkmod   init 121
gkpan   init 0
kmod	chnget "but1"
kmoda   trigger  kmod, .5, 0
        if kmoda == 1 then
gkmod	= 121
        endif
kmod2	chnget "but2"
kmod2a  trigger  kmod2, .5, 0
        if kmod2a == 1 then
gkmod	= 140
        endif
kmod3	chnget "but3"
kmod3a  trigger  kmod3, .5, 0
        if kmod3a == 1 then
gkmod	= 148
        endif
kmod4	chnget "but4"
kmod4a  trigger  kmod4, .5, 0
        if kmod4a == 1 then
gkmod	= 174
        endif
kmod5	chnget "but5"
kmod5a  trigger  kmod5,` .5, 0
        if kmod5a == 1 then
gkmod	= 184
        endif
kpan2   chnget "butt7"
kpan2a  trigger  kpan2, .5, 0
        if kpan2a == 1 then
gkpan   = 1
        endif
kpan3   chnget "butt8"
kpan3a  trigger  kpan3, .5, 0
        if kpan3a == 1 then
gkpan   = 2
        endif
kpan4   chnget "butt9"
kpan4a  trigger  kpan4, .5, 0
        if kpan4a == 1 then
gkpan   = 3
        endif
kpan1   chnget "butt6"
kpan1a  trigger  kpan1, .5, 0
        if kpan1a == 1 then
gkpan   = 0
        endif
kamp    chnget "slider1"
kamp2   chnget "slider4"
kamp3   chnget "slider7"
gkcps   chnget "slider2"
gkcps2  chnget "slider5"
gkcps3  chnget "slider8"
gkndx   chnget "slider3"
gkndx2  chnget "slider6"
gkndx3  chnget "slider9"
kstart  trigger kamp + kamp2 + kamp3, 0, 0
        if kstart > 0 then
        event "i", 2, 0, 3600, gkmod, gkpan
        event "i", 3, 0, 3600, gkmod, gkpan
        event "i", 4, 0, 3600, gkmod, gkpan
        turnoff
        endif
        
        endin
        
        instr 2
        
kpan    init 0
kamp    chnget "slider1"
kamp    port kamp * 10000, .05
krand   rspline .6, 1, .3, .8
kfreq	rspline .5, 2.5, 2, 2
gkndx   chnget "slider3"
gkndx   port gkndx * 8, .05
kndx2   jitter .5, .8, 1
gkcps   chnget "slider2"
gkcps   = (gkcps == 0? gkcps + 1: gkcps)
a1	foscil kamp * krand, gkcps, 400 + (kfreq/gkcps), p4, gkndx * (abs(kndx2) + 1), 1
a2      atonex a1, 250 * gkcps, 6
        if p5 > 0 then
        if p5 == 3 then
kpan    rspline -.1, .5, .25, .4
kpan    = (kpan < 0? 0: kpan)
        else
ktrig   trigger kamp, 1, 0
        if ktrig > 0 then
        if p5 == 1 then
kpan    chnget "slider10"
        else
kpan    rnd31 .5, .8
kpan    = kpan + .5
        endif
        endif
        endif
        endif
a3, a4  pan2 a2, kpan
        outs a3, a4

        endin

        instr 3

kpan    init .5
kamp    chnget "slider4"
kamp    port kamp * 10000, .05
krand   rspline .6, 1, .3, .8
kfreq	rspline .5, 2.5, 2, 2
gkndx2  chnget "slider6"
gkndx2  port gkndx2 * 8, .05
kndx2   jitter .5, .8, 1
kadd	jspline .15, .7, 1
gkcps2  chnget "slider5"
gkcps2  = (gkcps2 == 0? gkcps2 + 1: gkcps2)
a1	foscil kamp * krand, gkcps2, 400 + (kfreq/gkcps2), p4 + kadd, gkndx2 * (abs(kndx2) + 1), 1
a2      atonex a1, 250 * gkcps2, 6
        if p5 > 0 then
        if p5 == 3 then
kpan    rspline .25, .75, .25, .4
        else
ktrig   trigger kamp, 1, 0
        if ktrig > 0 then
        if p5 == 1 then
kpan    chnget "slider11"
        else
kpan    rnd31 .5, .8
kpan    = kpan + .5
        endif
        endif
        endif
        endif
a3, a4  pan2 a2, kpan
        outs a3, a4

        endin

        instr 4

kpan    init 1
kamp    chnget "slider7"
kamp    port kamp * 10000, .05
krand   rspline .6, 1, .3, .8
kfreq	rspline .5, 2.5, 2, 2
gkndx3  chnget "slider9"
gkndx3  port gkndx3 * 8, .05
kndx2   jitter .5, .8, 1
kadd	jspline .15, .7, 1
gkcps3  chnget "slider8"
gkcps3  = (gkcps3 == 0? gkcps3 + 1: gkcps3)
a1	foscil kamp * krand, gkcps3, 400 + (kfreq/gkcps3), p4 + kadd, gkndx3 * (abs(kndx2) + 1), 1
a2      atonex a1, 250 * gkcps3, 6
        if p5 > 0 then
        if p5 == 3 then
kpan    rspline .5, 1.1, .25, .4
kpan    = (kpan > 1? 1: kpan)
        else
ktrig   trigger kamp, 1, 0
        if ktrig > 0 then
        if p5 == 1 then
kpan    chnget "slider12"
        else
kpan    rnd31 .5, .8
kpan    = kpan + .5
        endif
        endif
        endif
        endif
a3, a4  pan2 a2, kpan
        outs a3, a4
            
        endin

</CsInstruments>
<CsScore>

f 1 0 16384 10 1 .0005 .001
i 1 0 3600

e

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
    	height: 84%; /* 92% for two-line labels */
    	width: 7px;  /* user choice */
    	background: yellow; /* user choice */
}
.sliders {
        width: 100%;
}        
.sliders td {
        padding: 1.5% 0 1.5% 0; /* 0 0 0 0 to 2% 0 2% 0 or more */
/* adding "-condensed" to font name reduces label length slightly,
   while also requiring a bit more vertical space */
        font-family: sans-serif;
        font-size: 120%; /* 100% and up */ 
        text-align: center;
	border-width: 0px; /* 0px to 2px recommended */
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

function slider1(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider1', numberValue);
}
function slider2(value) {
	var numberValue = parseFloat(value);
	document.querySelector('#slider2Output').value = numberValue.toFixed(2);
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
	document.querySelector('#slider5Output').value = numberValue.toFixed(2);
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
	document.querySelector('#slider8Output').value = numberValue.toFixed(2);
	csound.setControlChannel('slider8', numberValue);
}
function slider9(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider9', numberValue);
}
function slider10(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider10', numberValue);
}
function slider11(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider11', numberValue);
}
function slider12(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('slider12', numberValue);
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

</script>
</head>
<body>
<div class="noselect">

<b>PEACE BE WITH YOU (2015)</b> &nbsp; Art Hunkins

<table class="sliders">
<colgroup>
  <col width="">
  <col width="100%">
  <col width="">
</colgroup>
<tr>
<td>
<label for=slider1>1 Amplitd1</label>
<td>
<input type=range min=0 max=1 value=0 id=slider1 step=0.001 oninput="slider1(value)">
</tr>
<tr>
<td>
<label for=slider2>2 FreqFac1</label>
<td>
<input type=range min=1 max=3.8 value=1 id=slider2 step=0.001 oninput="slider2(value)">
<td>
<output for=slider2 id=slider2Output>1.00</output>
</tr>
<tr>
<td>
<label for=slider3>3 Timbre1</label>
<td>
<input type=range min=0 max=1 value=0 id=slider3 step=0.001 oninput="slider3(value)">
</tr>
<tr>
<td>
<label for=slider4>4 Amplitd2</label>
<td>
<input type=range min=0 max=1 value=0 id=slider4 step=0.001 oninput="slider4(value)">
</tr>
<tr>
<td>
<!-- Note use of dot in the following label, making it a single string;
     as the longest single string, it determines the length of this field for all sliders --!>
<label for=slider5>5.FreqFac2</label>
<td>
<input type=range min=1 max=3.8 value=1 id=slider5 step=0.001 oninput="slider5(value)">
<td>
<output for=slider5 id=slider5Output>1.00</output>
</tr>
<tr>
<td>
<label for=slider6>6 Timbre2</label>
<td>
<input type=range min=0 max=1 value=0 id=slider6 step=0.001 oninput="slider6(value)">
</tr>
<tr>
<td>
<label for=slider7>7 Amplitd3</label>
<td>
<input type=range min=0 max=1 value=0 id=slider7 step=0.001 oninput="slider7(value)">
</tr>
<tr>
<td>
<label for=slider8>8 FreqFac3</label>
<td>
<input type=range min=1 max=3.8 value=1 id=slider8 step=0.001 oninput="slider8(value)">
<td>
<output for=slider8 id=slider8Output>1.00</output>
</tr>
<tr>
<td>
<label for=slider9>9 Timbre3</label>
<td>
<input type=range min=0 max=1 value=0 id=slider9 step=0.001 oninput="slider9(value)">
</tr>
<tr>
<td>
<label for=slider10>10 Pan1</label>
<td>
<input type=range min=0 max=1 value=0 id=slider10 step=0.001 oninput="slider10(value)">
</tr>
<tr>
<td>
<label for=slider11>11 Pan2</label>
<td>
<input type=range min=0 max=1 value=0 id=slider11 step=0.001 oninput="slider11(value)">
</tr>
<tr>
<td>
<label for=slider12>12 Pan3</label>
<td>
<input type=range min=0 max=1 value=0 id=slider12 step=0.001 oninput="slider12(value)">
</tr>
</table>

<table class="buttons" style="margin: auto;">
<tr>
<!-- # of maximum characters per label depends on button font-size & family --!>
<!-- # of characters should be the same for each button per row --!>
<td>
<button class="button" onclick="butt1()">MdF1</button>
<td>
<button class="button" onclick="butt2()">MdF2</button>
<td>
<button class="button" onclick="butt3()">MdF3</button>
<td>
<button class="button" onclick="butt4()">MdF4</button>
<td>
<button class="button" onclick="butt5()">MdF5</button>
</tr>
<tr>
<td>
<button class="button" onclick="butt6()">PnM1</button>
<td>
<button class="button" onclick="butt7()">PnM2</button>
<td>
<button class="button" onclick="butt8()">PnM3</button>
<td>
<button class="button" onclick="butt9()">PnM4</button>
</tr>
</table>
</div>

</body>
</html>