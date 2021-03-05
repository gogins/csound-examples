sr= 22050
kr = 441;22050
ksmps = 50;1

zakinit 10,10

instr 1; "Solina" String Ensemble as the carrier
kamp  linen 1, 1,p3,1
kamp2 linen 1, 2,p3,1
kpitch init cpspch(p4)

alfo1 lfo .001,.8
alfo2 lfo .001,.56

abuzz1 buzz kamp, kpitch*(1+alfo1), sr/(2*kpitch), 1 ,0
asaw1 filter2 abuzz1, 1, 1, 1, -.95; weak bass response
abuzz2 buzz kamp, kpitch*(1-alfo2), sr/(2*kpitch), 1 ,0
asaw2 filter2 abuzz2, 1, 1, 1, -.95; weak bass response
abuzz3 buzz kamp2, 2*kpitch, sr/(4*kpitch), 1 ,0; 8th higher
asaw3 filter2 abuzz3, 1, 1, 1, -.999

amix = .25*(asaw1+asaw2+2*asaw3)

;add some chorus
adel1 lfo .01, .8
adel1 = .04*(1+adel1)
adel2 lfo .03, .7
adel2 = .04*(1+adel2)
adel3 lfo .02, .9
adel3 = .04*(1+adel3)
aflanger1 flanger amix, adel1, 0, .1
aflanger2 flanger amix, adel2, 0, .1
aflanger3 flanger amix, adel3, 0, .1

amix2 = .5*amix + .2*(aflanger1+aflanger2+aflanger3)
;amix2 gauss 1;test with noise carrier
zawm amix2,0
;out amix2*4000
endin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 2; Another Analog Vocoder
;coded by Josep M Comajuncosas / Nov´98
; features : 8 bands with assignable carrier & modulator inputs
; flexible routing with the zak system and selectable freq. with table l.u.
; improved freq. response with the addition of an unvocoded hi.freq. signal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;to get the most of this instrument
;record your voice slowly and clearly
;reduct noise, compress a lot and normalise
;adding reverb to your voice
;before vocoding can be really cool. Try it!

;User settings here ********
;routing table
irft = 2
;freq table
ichfft = 6
;filter poles
ipoles = 6
;rms tracking
iperiod = 60;123
;hp dry mix
ihpdry = .4

;modulator input
amod soundin "f:\drums.wav"
amod butterhp amod,30
;carrier input
acarr zar 0
;***************************

;channels freq. setup
if0 table 0,ichfft
if1 table 1,ichfft
if2 table 2,ichfft
if3 table 3,ichfft
if4 table 4,ichfft
if5 table 5,ichfft
if6 table 6,ichfft
if7 table 7,ichfft

;if0 = cpspch(if0)
;if1 = cpspch(if1)
;if2 = cpspch(if2)
;if3 = cpspch(if3)
;if4 = cpspch(if4)
;if5 = cpspch(if5)
;if6 = cpspch(if6)
;if7 = cpspch(if7)

;compute bandwidths
ibw1 = if2-if0
ibw2 = if3-if1
ibw3 = if4-if2
ibw4 = if5-if3
ibw5 = if6-if4
ibw6 = if7-if3

;analyse modulator
am0  tonex amod,if0,ipoles
am1 resonx amod,if1,ibw1,ipoles,1
am2 resonx amod,if2,ibw2,ipoles,1
am3 resonx amod,if3,ibw3,ipoles,1
am4 resonx amod,if4,ibw4,ipoles,1
am5 resonx amod,if5,ibw5,ipoles,1
am6 resonx amod,if6,ibw6,ipoles,1
am7 atonex amod,if7,ipoles

;get rms from each mod. band
krms0 rms am0, iperiod
krms1 rms am1, iperiod
krms2 rms am2, iperiod
krms3 rms am3, iperiod
krms4 rms am4, iperiod
krms5 rms am5, iperiod
krms6 rms am6, iperiod
krms7 rms am7, iperiod

;write rms to zak space
zkw krms0,0
zkw krms1,1
zkw krms2,2
zkw krms3,3
zkw krms4,4
zkw krms5,5
zkw krms6,6
zkw krms7,7

;analyse carrier
ac0  tonex acarr,if0,ipoles
ac1 resonx acarr,if1,ibw1,ipoles,1
ac2 resonx acarr,if2,ibw2,ipoles,1
ac3 resonx acarr,if3,ibw3,ipoles,1
ac4 resonx acarr,if4,ibw4,ipoles,1
ac5 resonx acarr,if5,ibw5,ipoles,1
ac6 resonx acarr,if6,ibw6,ipoles,1
ac7 atonex acarr,if7,ipoles

;routing setup
ir0 table 0,irft
ir1 table 1,irft
ir2 table 2,irft
ir3 table 3,irft
ir4 table 4,irft
ir5 table 5,irft
ir6 table 6,irft
ir7 table 7,irft

;band routing
krmsr0 zkr ir0
krmsr1 zkr ir1
krmsr2 zkr ir2
krmsr3 zkr ir3
krmsr4 zkr ir4
krmsr5 zkr ir5
krmsr6 zkr ir6
krmsr7 zkr ir7

;balance carrier w. mod. signal
ab0 gain ac0, krmsr0,iperiod
ab1 gain ac1, krmsr1,iperiod
ab2 gain ac2, krmsr2,iperiod
ab3 gain ac3, krmsr3,iperiod
ab4 gain ac4, krmsr4,iperiod
ab5 gain ac5, krmsr5,iperiod
ab6 gain ac6, krmsr6,iperiod
ab7 gain ac7, krmsr7,iperiod

;mix all balanced bands
; + some of the original 7th channel
;for better inteligibility
amix = .125*(ab0+ab1+ab2+ab3+ab4+ab5+ab6+ab7+ihpdry*am7)

out amix*10

zacl 0,0;clear before next pass
endin