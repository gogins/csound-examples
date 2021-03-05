; Paste a .csd designed for "canonical" Android Csound5 or 6 here
; Of course you must be running Csound6.05+ to handle the HTML5
: Change the (chnget) channel names in your .csd from butt1-5 to but1-5
; Note; no trackpad is implemented in HTML5 at this point
; Otherwise your .csd  should run like "canonical", if with greater latency

<html>
<head>
<style type="text/css">

.noselect {
        -webkit-user-select: none;
}

input[type='range'] {
	-webkit-appearance: none;
	background-color: silver;
        height: 100%;
    	width: 100%;
}
input[type='range']::-webkit-slider-thumb {
    	-webkit-appearance: none;
    	height: 84%;
    	width: 7px;
    	background: yellow;
}
.sliders {
        width: 100%;
}        
.sliders td {
        padding: 2% 0 2% 0;
        font-family: sans-serif;
        font-size: 100%; 
        text-align: center;
	border-width: 2px;
	border-style: solid;
	border-color: transparent;
    	color: white;
	background-color: teal;
}

.buttons {
        width: 100%;
}        
.buttons td {
        padding: 2% 0 2% 0;
        text-align: center;
	background-color: cadetblue;
}
.button {
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

</script>
</head>
<body>
<div class="noselect">

<b>Csound6 HTML5 GUI Clone</b>
<br><br>

<table class="sliders">
<colgroup>
  <col width="">
  <col width="100%">
</colgroup>
<tr>
<td>
<label for=slider1>Slider1</label>
<td>
<input type=range min=0 max=1 value=0 id=slider1 step=0.001 oninput="slider1(value)">
<tr>
<td>
<label for=slider2>Slider2</label>
<td>
<input type=range min=0 max=1 value=0 id=slider2 step=0.001 oninput="slider2(value)">
<tr>
<td>
<label for=slider3>Slider3</label>
<td>
<input type=range min=0 max=1 value=0 id=slider3 step=0.001 oninput="slider3(value)">
</tr>
<tr>
<td>
<label for=slider4>Slider4</label>
<td>
<input type=range min=0 max=1 value=0 id=slider4 step=0.001 oninput="slider4(value)">
</tr>
<tr>
<td>
<label for=slider5>Slider5</label>
<td>
<input type=range min=0 max=1 value=0 id=slider5 step=0.001 oninput="slider5(value)">
</tr>
<tr>
</table>

<table class="buttons" style="margin: auto;">
<tr>
<!-- # of maximum characters per label depends on button font-size & family --!>
<!-- # of characters should be the same for each button per row --!>
<td>
<button class="button" onclick="butt1()"> Butt1 </button>
<td>
<button class="button" onclick="butt2()"> Butt2 </button>
<td>
<button class="button" onclick="butt3()"> Butt3 </button>
<td>
<button class="button" onclick="butt4()"> Butt4 </button>
<td>
<button class="button" onclick="butt5()"> Butt5 </button>
</tr>
</table>

</div>

</body>
</html> 