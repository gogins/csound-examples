; HTML5 Button GUI demo for all size Android smartphones and tablets
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

/* 30ms delay before turning buttons off */
function wait() {
        var ms = 30;  
        ms += new Date().getTime();        
        while (new Date() < ms){};
        return;
}

/* Csound receives on: chnget "but1" */
/* channels named "butt1-5" are currently unavailable */
function butt1() {
        csound.setControlChannel('but1', 1);
        wait();
        csound.setControlChannel('but1', 0);
}
/* Csound receives on: chnget "but2" */
function butt2() {
        csound.setControlChannel('but2', 1);
        wait();
        csound.setControlChannel('but2', 0);
}
/* Csound receives on: chnget "button3" */
function butt3() {
        csound.setControlChannel('button3', 1);
        wait();
        csound.setControlChannel('button3', 0);
}
/* Csound receives on: chnget "4button" */
function button4() {
        csound.setControlChannel('4button', 1);
        wait();
        csound.setControlChannel('4button', 0);
}
/* Csound receives on: chnget "5" */
function another5() {
        csound.setControlChannel('5', 1);
        wait();
        csound.setControlChannel('5', 0);
}
/* Csound receives on: chnget "butt6" */
/* Only butt1-5 channel names currently unavailable */
function another() {
        csound.setControlChannel('butt6', 1);
        wait();
        csound.setControlChannel('6+', 0);
}
/* Csound receives on: chnget "77" */
function yetanother7() {
        csound.setControlChannel('77', 1);
        wait();
        csound.setControlChannel('77', 0);
}

</script>
</head>
<body>
<!-- enclose entire body within a single <div> tag
     so that all text is protected against accidental selection --!>
<div class="noselect">

<!-- avoid headline fonts; they take up valuable vertical space --!>
<!-- use *relative*, not absolute font-sizes; relative scales to display size --!>
<big><big><big><b>HTML5 BUTTON GUI</b></big></big></big><br>
<br><br>

<!-- columns center and auto-align, & adjust to accommodate maximum number --!>
<table class="buttons" style="margin: auto;">
<tr>
<!-- # of maximum characters per label depends on font-size & family -->
<!-- # of characters should be the same for each button per row --!>
<!-- button is only clickable in text area, not in padding --!>
<!-- text area can be elongated by adding spaces and non-blanking spaces [&nbsp:] --!>
<!-- vertical clickable space can be expanded via multi-line labels - use <br> --!>
<!-- additional *blank* lines below actual text must include &nbsp; --!>
<td>
<button class="button" onclick="butt1()"> Butt1 </button>
<td>
<button class="button" onclick="butt2()"> Butt2 </button>
<td>
<button class="button" onclick="butt3()"> Butt3 </button>
<td>
<!-- with buttons, longer strings don't auto-make multiple lines
     buttons just expand in size, making them unequal; not a good idea --!>
<button class="button" onclick="button4()"> Button 4 </button>
</tr>
<tr>
<td>
<!-- *multi-line* labels expand clickable area vertically --!>
<button class="button" onclick="another5()"><br>Button<br>5</button>
<td>
<button class="button" onclick="another()"><br>Button<br>6</button>
<td>
<button class="button" onclick="yetanother7()"><br>Button<br>7</button>
</tr>
</table>

</div>

</body>
</html>