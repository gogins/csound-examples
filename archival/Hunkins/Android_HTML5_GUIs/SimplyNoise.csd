; SIMPLY NOISE (2015) for realtime Csound6
; Demo of HTML5 "drumset" performance GUI for all size Android smartphones and tablets
; Note the very significant, inherent latency issue.
;   GUI is at bottom of file, and contains 12 momentary-contact buttons (no sliders)
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

        instr 1

kamp    init 8000
ktrig1	chnget "noise1"
ktrig1a trigger  ktrig1, .5, 0
        if ktrig1a == 1 then
kpch	= 8.00
        kgoto note
        endif
ktrig2	chnget "noise2"
ktrig2a trigger  ktrig2, .5, 0
        if ktrig2a == 1 then
kpch	= 8.02
        kgoto note
        endif
ktrig3	chnget "noise3"
ktrig3a trigger  ktrig3, .5, 0
        if ktrig3a == 1 then
kpch	= 8.04
        kgoto note
        endif
ktrig4	chnget "noise4"
ktrig4a trigger  ktrig4, .5, 0
        if ktrig4a == 1 then
kpch	= 8.05
        kgoto note
        endif
ktrig5	chnget "noise5"
ktrig5a trigger  ktrig5, .5, 0
        if ktrig5a == 1 then
kpch	= 8.07
        kgoto note
        endif
ktrig6	chnget "noise6"
ktrig6a trigger  ktrig6, .5, 0
        if ktrig6a == 1 then
kpch	= 8.09
        kgoto note
        endif
ktrig7	chnget "noise7"
ktrig7a trigger  ktrig7, .5, 0
        if ktrig7a == 1 then
kpch	= 8.11
        kgoto note
        endif
ktrig8	chnget "noise8"
ktrig8a trigger  ktrig8, .5, 0
        if ktrig8a == 1 then
kpch	= 9.00
        kgoto note
        endif
kamp1   chnget "amp1"
kamp1a  trigger  kamp1, .5, 0
        if kamp1a == 1 then
kamp    = 5000
        endif
kamp2   chnget "amp2"
kamp2a  trigger  kamp2, .5, 0
        if kamp2a == 1 then
kamp    = 8000
        endif
kamp3   chnget "amp3"
kamp3a  trigger  kamp3, .5, 0
        if kamp3a == 1 then
kamp    = 14000
        endif
kamp4   chnget "amp4"
kamp4a  trigger  kamp4, .5, 0
        if kamp4a == 1 then
kamp    = 25000
        endif
        goto end        

note:   event "i", 2, 0, 1.5, kamp, kpch

end:    endin
        
        instr 2
        
kamp    expseg 10, .05, p4, p3 - .05, 10
anoise  noise kamp, 0
ifreq   = cpspch(p5)
a1      reson anoise, ifreq, ifreq * .1, 2
        outs a1, a1
        
        endin

</CsInstruments>
<CsScore>

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

/* buttons are momentary-contact; they send Csound a 1 upon touch
   and after a 30ms wait, a 0 */
.buttons {
        width: 80%; /* 100% or less, horizontally centered */
}        
.buttons td {
/* padding contributes to button size, but is not clickable */
        padding: 5% 0 5% 0; /* 0 0 0 0 to 2% 0 2% 0 *or more* */
        text-align: center;
	background-color: cadetblue; /* user choice */
}
.button {
/* font condensed for label so it takes minimal space from buttons
   on smartphones, leaving room for more characters */
/* adding "-condensed" to font name can permit more label characters,
   while also requiring a bit more vertical space */
        font-family: sans-serif;
/* font-size, # of characters (including leading/trailing spaces)
   and # of lines of text determine clickable area of buttons */
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

function noise1() {
        csound.setControlChannel('noise1', 1);
        wait();
        csound.setControlChannel('noise1', 0);
}
function noise2() {
        csound.setControlChannel('noise2', 1);
        wait();
        csound.setControlChannel('noise2', 0);
}
function noise3() {
        csound.setControlChannel('noise3', 1);
        wait();
        csound.setControlChannel('noise3', 0);
}
function noise4() {
        csound.setControlChannel('noise4', 1);
        wait();
        csound.setControlChannel('noise4', 0);
}
function noise5() {
        csound.setControlChannel('noise5', 1);
        wait();
        csound.setControlChannel('noise5', 0);
}
function noise6() {
        csound.setControlChannel('noise6', 1);
        wait();
        csound.setControlChannel('noise6', 0);
}
function noise7() {
        csound.setControlChannel('noise7', 1);
        wait();
        csound.setControlChannel('noise7', 0);
}
function noise8() {
        csound.setControlChannel('noise8', 1);
        wait();
        csound.setControlChannel('noise8', 0);
}
function amp1() {
        csound.setControlChannel('amp1', 1);
        wait();
        csound.setControlChannel('amp1', 0);
}
function amp2() {
        csound.setControlChannel('amp2', 1);
        wait();
        csound.setControlChannel('amp2', 0);
}
function amp3() {
        csound.setControlChannel('amp3', 1);
        wait();
        csound.setControlChannel('amp3', 0);
}
function amp4() {
        csound.setControlChannel('amp4', 1);
        wait();
        csound.setControlChannel('amp4', 0);
}

</script>
</head>
<body>
<div class="noselect">

<big><big><big><b>SIMPLY NOISE</b></big></big></big><br>
 &nbsp; Demo HTML5 "drumset" GUI
<br><br>

<table class="buttons" style="margin: auto;">
<tr>
<!-- # of maximum characters per label depends on font-size & family -->
<!-- # of characters should be the same for each button per row --!>
<td>
<!-- button is only clickable in text area, not in padding --!>
<!-- text area can be elongated by adding spaces and non-blanking spaces [&nbsp:] --!>
<!-- vertical clickable space can be expanded via multi-line labels - use <br> --!>
<!-- additional *blank* lines below actual text must include &nbsp; --!>
<button class="button" onclick="noise1()"><br> Noise <br>1</button>
<td>
<button class="button" onclick="noise2()"><br> Noise <br>2</button>
<td>
<button class="button" onclick="noise3()"><br> Noise <br>3</button>
<td>
<button class="button" onclick="noise4()"><br> Noise <br>4</button>
</tr>
<tr>
<td>
<button class="button" onclick="noise5()"><br> Noise <br>5</button>
<td>
<button class="button" onclick="noise6()"><br> Noise <br>6</button>
<td>
<button class="button" onclick="noise7()"><br> Noise <br>7</button>
<td>
<button class="button" onclick="noise8()"><br> Noise <br>8</button>
</tr>
</table><br>
<center>8 "Drums" (Noises)</center><br>

<table class="buttons" style="margin: auto;">
<tr>
<td>
<button class="button" onclick="amp1()"><br> Amp <br>1</button>
<td>
<button class="button" onclick="amp2()"><br> Amp <br>2</button>
<td>
<button class="button" onclick="amp3()"><br> Amp <br>3</button>
<td>
<button class="button" onclick="amp4()"><br> Amp <br>4</button>
</tr>
</table><br>
<center>4 Amplitude Levels</center>
</div>

</body>
</html>