sr = 44100
kr = 44100
ksmps = 1

instr 1 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Roland TB-303 bassline emulator
; coded by Josep Mª Comajuncosas , Sept 1997 to Oct 1998
; please send your comments, scores (and money ;-)) to
; to gelida@intercom.es
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; initial settings; control the overall character of the sound
imaxfreq      = 5000; max.filter cutoff freq. when ienvmod = 0
imaxsweep     = sr/2; ... max.filter freq. at kenvmod & kaccent= 1
iratio        = 20; "compression" ratio for the distorter. Must be > 0

; init variables; don´t touch this!
itranspose   = p15; 1 raise the whole seq. 1 octave, etc.
iseqfn       = p16
iaccfn       = p17
idurfn       = p18
imaxamp      = p19; maximum amplitude. Max 32768 for 16 bit output monophonic
ibpm         = p14; 4/4 bars per minute (or beats?)
inotedur     = 15/ibpm
icount       init 0; sequence counter (for notes)
icount2      init 0; id. for durations
ipcount2     init 0
idecaydur    = inotedur
imindecay    = (idecaydur<.2 ? .2 : idecaydur); set minimum decay to .2 or inotedur
ipitch table 0,iseqfn; first note in the sequence
ipitch       = cpspch(itranspose + 6 + ipitch/100)
kaccurve     init 0

; twisting the knobs from the score (simple lines to test)
kfco       line p4, p3, p5
kres       line p6, p3, p7
kenvmod    line p8, p3, p9
kdecay     line p10, p3, p11
kaccent    line p12, p3, p13

start:
;pitch & portamento from the sequence
ippitch = ipitch
ipitch table ftlen(iseqfn)*frac(icount/ftlen(iseqfn)),iseqfn
ipitch  = cpspch(itranspose + 6 + ipitch/100)

if ipcount2 != icount2 goto noslide
kpitch linseg ippitch, .06, ipitch, inotedur-.06, ipitch
goto next

noslide:
kpitch = ipitch

next:
ipcount2 = icount2
timout 0,inotedur,contin
icount   = icount + 1
reinit start
rireturn

contin:
; accent detector
iacc table ftlen(iaccfn)*frac((icount-1)/ftlen(iaccfn)), iaccfn
if iacc == 0 goto noaccent
ienvdecay = 0; accented notes are the shortest ones
iremacc   = i(kaccurve)
kaccurve oscil1i 0, 1, .4, 3
kaccurve  = kaccurve+iremacc;successive accents cause hysterical raising cutoff

goto sequencer

noaccent:
kaccurve  = 0; no accent & "discharges" accent curve
ienvdecay = i(kdecay)

sequencer:
aremovedc init 0; set feedback to 0 at every event
imult table ftlen(idurfn)*frac(icount2/ftlen(idurfn)),idurfn
if imult != 0 goto noproblemo; compensate for zero padding in the sequencer
icount2   = icount2 + 1
goto sequencer

noproblemo:
ieventdur = inotedur*imult
; note than the envelope is sensitive to note duration
; in fact, to the duration of a stream of slided notes
; this is richer than setting a static envelope time
; but it works different from a real TB-303

; two envelopes
kmeg expseg 1, imindecay+(3.4*ienvdecay), ienvdecay+.000001; <- fixed time
kmeg expseg 1, imindecay+((ieventdur-imindecay)*ienvdecay), ienvdecay+.000001
kveg linen 1, .004, ieventdur, .016

; amplitude envelope
kamp = kveg*((1-i(kenvmod)) + kmeg*i(kenvmod)*(.5+.5*iacc*kaccent))

; filter envelope: 2 options
; 1:soft sustained (requires higher kenvmod)
;ksweep = imaxfreq + (.7*kmeg+.3*kaccurve*kaccent)*kenvmod*(imaxsweep-imaxfreq)
;kfco = 50 + kfco * ksweep; cutoff always greater than 50 Hz ...
; 2:extreme sweep (more "acid")
kfco = 50 + imaxfreq*kfco*(1-kenvmod)+imaxsweep*kenvmod*(.7*kmeg +.3*kaccurve*kaccent)

kfco = (kfco > sr/2 ? sr/2 : kfco); could be necessary

timout 0, ieventdur, out
icount2 = icount2 + 1
reinit contin

out:
; generate bandlimited sawtooth wave
abuzz buzz kamp, kpitch, sr/(4*kpitch), 1 ,0;bandlimited pulse
asawdc filter2 abuzz, 1, 1, 1, -.99; leaky integrator
asaw = asawdc; a leaky integrator "forgets" DC transients

; resonant 4-pole LPF
ax = asaw
ay1 init 0
ay2 init 0
ay3 init 0
ay4 init 0

kfcon = kfco/(sr/2); use freq normalized DC to Nyquist
kp tablei kfcon, 21, 1; (approximated) tuning table
kscale tablei (kp+1)/2, 20, 1; adjust feedback (approximation)
kk = kres*kscale

; inverted feedback for corner peaking
ax = ax - kk*ay4

; 4 cascaded onepole filters (bilinear transform)
ax1  delay1 ax
ay1  = ax * (kp+1)/2 + ax1 * (kp+1)/2 - kp*ay1
ay11 delay1 ay1
ay2  = ay1 * (kp+1)/2 + ay11 * (kp+1)/2 - kp*ay2
ay21 delay1 ay2
ay3  = ay2 * (kp+1)/2 + ay21 * (kp+1)/2 - kp*ay3
ay31 delay1 ay3
ay4  = ay3 * (kp+1)/2 + ay31 * (kp+1)/2 - kp*ay4

; clipper/distorter via waveshaping
; to allow autooscillation without overdriving
; certainly more efficient with table look-up,
; wait for next release ;-)
;ay4 = ay4-ay4*ay4*ay4/6; bandlimited sigmoid (Taylor expansion)
ay4 = tanh(ay4); ~ ay4 at small values, but limited to +-1
;ay4 = ay4 - ay4*ay4*ay4

; resonance controlled arctan() or tanh() distortion
; note this distortion is after the filter, not inside the loop
;ay5 = (taninv(kres*ay4*iratio))/(taninv(kres*iratio)); distorter
ay5 = (tanh(kres*ay4*iratio))/(tanh(kres*iratio))

;final output

	out imaxamp*kamp*ay5
endin

