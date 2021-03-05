; SPIRITUS SANCTUS 2 (2015) for realtime Android Csound - by Arthur B. Hunkins
; Includes HTML5 performance GUI for all size Android smartphones and tablets
;   GUI is at bottom of file, and contains 8 sliders and no momentary-contact buttons
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
   
gkamp	chnget   "slider1"
gkamp   tab      gkamp * 511, 2
gkamp   =        gkamp * 12000
gkamp   port     gkamp, .2
kmul	chnget   "slider2"
kmul    =        kmul * .82
kmul    port     kmul, .2
knh	chnget   "slider3"
knh     =        (knh * 16) + 4
knh     port     knh, .2
gklh    chnget   "slider4"
gklh    =        (gklh * 6.1) + 4
gkamp2  chnget   "slider8"
gkamp2  =        gkamp2 * .6
gkamp2  port     gkamp2, .2
kamp2   rspline  -gkamp2, gkamp2, .6 * gklh, gklh
aout    gbuzz    gkamp + (kamp2 * gkamp), 200, knh, gklh, kmul, 1
        outs     aout, aout * .7
        
        endin
        
        instr 2
   
kmul	chnget   "slider5"
kmul    =        kmul * .82
kmul    port     kmul, .2
knh	chnget   "slider6"
knh     =        (knh * 16) + 4
knh     port     knh, .2
kfreq   chnget   "slider7"
kfreq   =        kfreq * .15
kfreq   port     kfreq, .2 
kamp2   rspline  -gkamp2, gkamp2, .6 * gklh, gklh
aout    gbuzz    gkamp + (kamp2 * gkamp), 200.05 + kfreq, knh, gklh, kmul, 1
        outs     aout * .7, aout
        
        endin

</CsInstruments>

<CsScore>

f1 0 16384 11 16 1 .012
f2 0 512 16 0 512 .8 1

i1 0 3600
i2 0 3600
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
    	height: 92%; /* 84% for one-line labels */
    	width: 7px;  /* user choice */
    	background: yellow; /* user choice */
}

.sliders {
        width: 100%;
}        
.sliders td {
        padding: 1% 0 1% 0; /* 0 0 0 0 to 2% 0 2% 0 or more */
/* adding "-condensed" to font name reduces label length slightly,
   while also requiring a bit more vertical space */
        font-family: sans-serif;
        font-size: 120%; /* 100% and up */ 
        text-align: center;
	border-width: 2px; /* 0px to 2px recommended */
	border-style: solid;
	border-color: transparent;
    	color: white; /* user choice */
	background-color: teal; /* user choice */
}

</style>

<script>

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

</script>
</head>
<body>
<div class="noselect">

<big><b>SPIRITUS SANCTUS 2 (2015)</big></b><br>
 &nbsp; Arthur B. Hunkins (arthunkins.com)

<table class="sliders">
<colgroup>
  <col width="">
  <col width="100%">
</colgroup>
<tr>
<td>
<label for=slider1>1 Amplitude1</label>
</td>
<td>
<input type=range min=0 max=1 value=0 id=slider1 step=0.001 oninput="slider1(value)">
</td>
</tr>
<tr>
<td>
<label for=slider2>2 Mult Factor1</label>
</td>
<td>
<input type=range min=0 max=1 value=0 id=slider2 step=0.001 oninput="slider2(value)">
</td>
</tr>
<tr>
<td>
<label for=slider3>3 # of Harmonics1</label>
</td>
<td>
<input type=range min=0 max=1 value=0 id=slider3 step=0.001 oninput="slider3(value)">
</td>
</tr>
<tr>
<td>
<label for=slider4>4 Lowest Harmonic</label>
</td>
<td>
<input type=range min=0 max=1 value=0 id=slider4 step=0.001 oninput="slider4(value)">
</td>
</tr>
<tr>
<td>
<label for=slider5>5 Mult Factor2</label>
</td>
<td>
<input type=range min=0 max=1 value=0 id=slider5 step=0.001 oninput="slider5(value)">
</td>
</tr>
<tr>
<td>
<label for=slider6>6 # of Harmonics2</label>
</td>
<td>
<input type=range min=0 max=1 value=0 id=slider6 step=0.001 oninput="slider6(value)">
</td>
</tr>
<tr>
<td>
<label for=slider7>7 Beat Frequency</label>
</td>
<td>
<input type=range min=0 max=1 value=0 id=slider7 step=0.001 oninput="slider7(value)">
</td>
</tr>
<tr>
<td>
<label for=slider8>8 Rand Beat Frequency</label>
</td>
<td>
<input type=range min=0 max=1 value=0 id=slider8 step=0.001 oninput="slider8(value)">
</td>
</tr>
</table>

</div>

</body>
</html>