; HTML5 Slider GUI demo for all size Android smartphones and tablets
; Requires Android OS 4.2.2+, and Csound6[.05].apk or higher
;   Downloadable from http://sourceforge.net/projects/csound/files/csound6/Csound6.05/
; Minimal Csound code just allows Csound to run for an hour and activates display

<CsoundSynthesizer>
<CsOptions>

-odac

</CsOptions>
<CsInstruments>

        instr 1

        endin
        
</CsInstruments>
<CsScore>

i 1 0 3600

e

</CsScore>
</CsoundSynthesizer>

; Suggestion: place all HTML outside Csound code at beginning or end of .csd.
; Doing so will happily eliminate it from Csound console output

<html>
<head>
<style type="text/css">

/* eliminates accidental text selection by user in performance */
.noselect {
        -webkit-user-select: none;
}

/* this is the actual slider ['range'] for table1 */
/* the name field is required to identify the two styles of slider used here*/
input[name='style1'][type='range'] {
	-webkit-appearance: none;
	background-color: silver; /* user choice */
        height: 100%; /* = default size */
    	width: 100%; /* we always need the full available width for sliders */
}
/* this is the slider knob for table1 */
/* style1 is designed for one-line labels */
input[name='style1'][type='range']::-webkit-slider-thumb {
    	-webkit-appearance: none;
    	height: 84%; /* 92% for two-line labels */
    	width: 7px;  /* user choice */
    	background: yellow; /* user choice */
}

/* this is the actual slider for table2 */
input[name='style2'][type='range'] {
	-webkit-appearance: none;
	background-color: silver; /* user choice */
        height: 100%;
    	width: 100%;
}
/* this is the slider knob for table2 */
/* style2 is designed for two-line labels */
input[name='style2'][type='range']::-webkit-slider-thumb {
    	-webkit-appearance: none;
    	height: 92%; /* 84% for one-line labels */
    	width: 7px;  /* user choice */
    	background: yellow; /* user choice */
}

.sliders1 td {
/* for when you have plenty of extra space and want to visually separate: */
/* note: padding and border areas are not draggable */
        padding: 1% 0 1% 0; /* 0 0 0 0 to 2% 0 2% 0 or more */
/* adding "-condensed" to font name reduces label length slightly - giving slider
   more room, while also requiring a bit more vertical space */
        font-family: sans-serif;
/* font-size enlarged for single-line label - to thicken slider */
/* note that relative font-size (here 120%) and # of lines for label
   are the only ways of controlling slider thickness and thus "playability"
   Suggestion: keep them as thick as possible; padding/borders are not draggable */
        font-size: 120%; /* 100% and up */ 
        text-align: center;
	border-width: 2px; /* 0px to 2px recommended; they visually separate only */
	border-style: solid;
	border-color: transparent;
    	color: white; /* user choice */
	background-color: teal; /* user choice */
}
    
.sliders2 td {
        padding: 0% 0 0% 0; /* 0 0 0 0 to 2% 0 2% 0 or more */
        font-family: sans-serif-condensed;
/* font-size left at 100% since slider is already double thickness */
        font-size: 100%; /* 100% and up */ 
        text-align: center;
	border-width: 1px; /* 0px to 2px recommended */
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
function fader3(value) {
	var numberValue = parseFloat(value);
	csound.setControlChannel('fader3', numberValue);
}
function fader4(value) {
	var numberValue = parseFloat(value);
/* value of fader is displayed in column3; toFixed(2) rounds # to two decimal points */
/* this is not MIDI, and raw output could display many, and varied decimal places */
/* the # of fixed decimal places of displayed values, same table, should be identical */
	document.querySelector('#displayfader4Output').value = numberValue.toFixed(2);
	csound.setControlChannel('displayfader4', numberValue);
}

</script>
</head>
<body>
<!-- enclose entire body within a single <div> tag
so that all text is protected against accidental selection --!>
<div class="noselect">

<!-- avoid headline fonts; they take up valuable vertical space --!>
<!-- use *relative*, not absolute font-sizes; relative sizes scale to display --!>
<big><b>HTML5 SLIDER GUI</b></big><br>
<br><br>

<table class="sliders1">
<colgroup>
  <col width="">
  <col width="100%">
</colgroup>
<tr>
<td>
<label for=slider1>Slider1</label>
</td>
<td>
<!-- note the name field, due to the two slider styles --!>
<!-- step=0.001 simulates infinite, smooth slider movement --!>
<input name="style1" type=range min=0 max=1 value=0 id=slider1 step=0.001 oninput="slider1(value)">
</td>
</tr>
<tr>
<td>
<label for=slider2>Slider2</label>
</td>
<td>
<!-- though the normal Csound Android slider range is 0 to 1, webkit default is actually 0 to 100 --!>
<!-- range can actually be anything; value = initial slider placement,
     though *there is no actual output until slider is moved* --!>
<input name="style1" type=range min=0 max=100 value=0 id=slider2 step=0.001 oninput="slider2(value)">
</td>
</tr>
</table>
<br>

<table class="sliders2">
<colgroup>
  <col width=""> <!-- = space autoadjusts to that required by the longest string in the label --!>
<!-- NOTE: strings are separated by spaces, dashes and forward slashes only --!>  
  <col width="100%">
  <col width=""> <!-- space autoadjusts to the # of digits displayed in this column --!>
<!-- all data in this column and table should contain the same # of digits --!>
</colgroup>
<tr>
<td>
<label for=fader3>Slider 3</label>
<td>
<input name="style2" type=range min=0 max=1 value=0 id=fader3 step=0.001 oninput="fader3(value)">
<!-- column three [displayed value] is omitted for this slider --!>
</tr>
<tr>
<td>
<label for=fader4>Slider 4</label>
<td>
<!-- note that min value and (start) value do not have to be 0; but if start value <> 0, this variable
     must be initialized by Csound to start value, as its value is only sent once slider is moved.
     Example for fader4 below: in Csound, "kamp chnget displayfader4" must be preceeded by "kamp init 1" --!>
<!-- also note: chnget must be placed within an instrument, and chnset and chnexport are not implemented --!> 
<!-- keep max value < 10.00 --!>
<input name="style2" type=range min=1 max=3.8 value=1 id=displayfader4 step=0.001 oninput="fader4(value)">
<td>
<!-- # of digits in initial output = fixed decimal places + 1 (3) --!>
<output for=fader4 id=displayfader4Output>1.00</output>
</tr>
<tr>
</table>

</div>

</body>
</html>