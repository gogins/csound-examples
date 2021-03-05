<CsoundSynthesizer>
<CsOptions>

-o dac12
--midi-device=8

</CsOptions>

<CsInstruments>

sr	    	=  48000
ksmps	=  32
nchnls  =  2

0dbfs = 1
massign 0,0

pyinit

;;; ***********
;;; 24 BIT SINE

gisine 	ftgen 1, 0, 16777216, 10, 1


;;; ***********
opcode MIDI2cpsi, i, i

imidi xin     

	inotexpo = (imidi-69)/12

	i2x = powoftwo (inotexpo)

	icps = i2x*440
	
	xout icps
	
endop


;;; ***********
instr 01

kstatus, kchan, kdata1, kdata2 midiin

if kstatus == 144 then
	
    if kdata2 != 0 then
    
        pycall	"midiNoteInput", kdata1
        
    endif
    
endif

endin

instr 10

  ipitch MIDI2cpsi p4
  
  a1 oscil .25, ipitch, gisine
  outs a1,a1
  
endin

</CsInstruments>

<CsScore>

i 1 0 360 

</CsScore>

</CsoundSynthesizer>
