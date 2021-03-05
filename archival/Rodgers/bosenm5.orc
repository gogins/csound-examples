; Orc file for MIT samples from ftp://sound.media.mit.edu/pub/Csound/Samples/
;
; from Csound mailing list post by
;  name=jpff@maths.bath.ac.uk
;  subject=Re: How to use Samples files?
;  date=Fri, 27 Oct 95 17:17:46 BST
;
;
      sr     = 44100
;     ksmps  =     5      ; any higher than 10 and I hear clicks
;     kr     =  8820      ; any lower than 4410 and I hear clicks
     ksmps  =    20      ; any higher than 10 and I hear clicks
     kr     =  2205      ; any lower than 4410 and I hear clicks
      nchnls =     2

      instr   1

; p1 is always 1
; p2 start time
; p3 duration
; p4 velocity, 60-80 works best
; p5 tone - which tone is this note - 1-43 for Partch scale
; p6 Octave
; p7 voice - piano = 0 - Guitar = 1 - Violin = 2 - trumpet = 3 - perc1 = 4 - perc2 = 5
; p8 stereo - pan from left = 0 to right = 16
; p9 envelope - one of several function tables for envelopes 1 - 16
;
ifunc    table   p7,1             ; find the location of the sample wave tables
iwavchan table   p7,2             ; is it mono (iwavchan = 1) or stereo sample file (iwavchan = 2)
                                  ; or are sustain points in separate table iwavchan=3
ioct     =       p6+3             ; I am used to Middle C = 6
inum     =       (ioct-3)*12 + int(p5/53*12) ; convert to MIDI note number to pick ftable
ifno     table   inum, ifunc      ; map midi note number to ftables
ibasno   table   ifno-(2+ifunc), 1  + ifunc     ; get basnot for each ftable
icent    table   ifno-(2+ifunc), 2  + ifunc     ; get cents to flatten each note
ibasoct  =       ibasno/12 + 3    ; find the base octave
ibascps  =       cpsoct(ibasoct+(icent/1200))
ipitch   table   p5, 3            ; convert note number 1-43 to oct.fract format
icps     =       cpspch(ioct+ipitch)  ; convert oct.fract to Hz
iamp     =       ampdb(p4)        ; velocity input is 60-80 - convert to amplitude
i9       =       198-p9           ; valid envelope table number are 198, 197, 196, 195 etc.
kamp1    oscili  iamp, 1/p3, i9   ; create an envelope from a function table
kamp2    linseg  .0001,.001*p3,1,p3*.998,1,.001*p3,.0001
kamp     =   kamp1*kamp2
kpanl    tablei  p8/16, 4, 1      ; pan with a sine wave
kpanr    tablei  1.0 - p8/16, 4, 1;
; some samples are stereo, some are mono, some have sustain points in function table
; use a different form of locsil depending on this
;
if iwavchan = 3 goto sustain
if iwavchan = 2 goto stereo
    a1       loscil  kamp, icps, ifno, ibascps ;read an AIFF-defined sampled instr
    outs     a1 * kpanl ,a1 * kpanr
    goto skipstereo
stereo:
    a1,a2   loscil  kamp, icps, ifno, ibascps ;read an AIFF-defined sampled instr
    outs     a1 * kpanl ,a2 * kpanr
    goto skipstereo
    ; ifunc = 113 start of tables for acoustic bass
    ; ifno = 116
    ; ibeg = 4398
    ; iend = 4796
sustain:
    ibeg   table  ifno-(2+ifunc), 9 + ifunc ; get begin point of sustain in sample 9 for 6 samples per instrument
    iend   table  ifno-(2+ifunc), 10+ ifunc ; get end point of sustain in sample 10 for 6 samples per instrument
    imodlp  = (iend = ibeg+1 ? 0 : 1)
    a1       loscil  kamp, icps, ifno, ibascps, imodlp,ibeg,iend ;read an WAV-defined sampled instr
    outs     a1 * kpanl ,a1 * kpanr
skipstereo:
    endin
