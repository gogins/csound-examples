<CsoundSynthesizer>
<CsOptions>
-RWZdo You_Know_I_Know.wav
</CsOptions>

<CsInstruments>
;;; Csound Orchestra for Knowing, a.k.a. You Know I Know.
;;; John D. Ramsdell -- February 2001

;;; Some nice features of these instruments are: (1) here is a global
;;; volume control, (2) each instrument has an on/off switch, and (3)
;;; legato instruments ignore the next amplitude field when the note
;;; is the last one of a slur, and ignore the previous pitch field
;;; when the note is not tied to a previous one.

;;; Orchestra References

;;; [1] Vercoe, Barry, and contributors, "The Public Csound Reference
;;; Manual", Canonical Version 4.07.

;;; [2] Boulanger, Richard, Ed., "The Csound Book", MIT Press, 2000.

;;; This orchestra produces and then mixes three channels.  Instrument
;;; 40 is the mixer.
  sr        =           44100
  ksmps     =           1
  nchnls    =           2

;;; global volume
  givol     =           0.9

;;; instrument flags.  Set to zero to turn off one.
  givol10   =           1
  givol20   =           1
  givol25   =           1
  givol30   =           1
  givol35   =           1
  givol40   =           1

;;; constant used for stereo
  gisr2b2   =           sqrt(2.0)/2.0
;;; the constant pi/2
  gipib2    =           2.0*taninv(1.0)

;;; SINE WAVE
  gisine    ftgen       0, 0, 8192, 10, 1
;;; QUASI SQUARE WAVE
  giqsqr    ftgen       0, 0, 8192, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

;;; The three channels
  gaout1    init        0
  gaout2    init        0
  gaout3    init        0

;;; Channel 1

instr 10

;;; Rhythm instrument--a combination of a pluck and an FM bell.
;;; p3--duration
;;; p4--pitch
;;; p5--amplitude
;;; p6--mix between plucks and bells--range 0 to 1
;;; p7--bell vibrato depth

  idur      =           abs(p3)
  icps      =           cpspch(p4)
  iamp      =           ampdb(p5)
  imix      =           p6*gipib2
  ivibdepth =           p7

  if        givol10<=0  goto done
  iatt      =           0.02
  idec      =           0.5*idur
  kenv      linen       iamp, iatt, idur, idec  ; AMPLITUDE ENVELOPE
  abell     fmbell      kenv, icps, 0, 0, ivibdepth, 6, gisine, gisine, gisine, gisine, gisine
  apluck    pluck       iamp, icps, icps, 0, 1
  aout      =           apluck*cos(imix)+abell*sin(imix)
  gaout1    =           gaout1+aout
done:
endin 

;;; Channel 2 -- Legato instruments 

;;; The design of these instruments was strongly influenced by Richard
;;; W. Dobson, "Designing Legato Instruments in Csound", Chapter 7,
;;; in [2].
          
instr 20 

;;; A legato instrument based on the vco opcode, following Rasmun
;;; Ekman in [1], section 69.8 on the i-statement, page 69-13.

;;; p3--duration
;;; p4--pitch
;;; p5--amplitude
;;; p6--previous pitch
;;; p7--next amplitude

  idur      =           abs(p3)
  icps      =           cpspch(p4)
  iamp      =           ampdb(p5)
  iprevcps  =           cpspch(p6)
  iampdec   =           ampdb(p7)

  if        givol20<=0  goto done
;;; constants
  iatt      =           0.02
  iport     =           0.03
  idec      =           0.8
;;; conditional initial values
;;; assume tied and not last note
  iampatt   =           idec*iamp
  iampdec   =           idec*iampdec
            tigoto      notfirst
;;; assume first note
  iampatt   =           0
  iprevcps  =           icps
  kcps      init        icps
notfirst:
  if        p3<0        igoto notlast
;;; assume last note
  iampdec   =           0
notlast:
  if        iatt<=0.5*idur igoto attok
  iatt      =           0.5*idur
attok:
  if        iport<=0.5*idur igoto portok
  iport     =           0.5*idur
portok:
;;; Now do amp from the set values: 
  kenv      linseg      iampatt, iatt, iamp, idur-iatt, iampdec
  kcps      linseg      iprevcps, iport, icps, idur-iport, icps
;;; Skip rest of initialization on tied note:
            tigoto      tieskip
  kpw       oscil       .4, .4, gisine ; A simple triangle-saw oscil
  aout      vco         kenv, kcps, 3, kpw+.5, gisine, 1/icps
  gaout2    =           gaout2+aout
tieskip:                                        ; Skip some initialization on tied note
done:
endin 

instr 25

;;; p3--duration
;;; p4--pitch
;;; p5--amplitude
;;; p6--previous pitch
;;; p7--next amplitude

  idur      =           abs(p3)
  icps      =           cpspch(p4)
  iamp      =           ampdb(p5)
  iprevcps  =           cpspch(p6)
  iampdec   =           ampdb(p7)

  if        givol25<=0  goto done
;;; constants
  iatt      =           0.02
  iport     =           0.03
  idec      =           0.9
  ifc1      =           400                     ; Fc OF RESON 1
  iq1       =           5                       ; Q OF RESON 1
  ifc2      =           1100                    ; Fc OF RESON 2
  iq2       =           3                       ; Q OF RESON 2
;;; conditional initial values
;;; assume tied and not last note
  iampatt   =           idec*iamp
  iampdec   =           idec*iampdec
            tigoto      notfirst
;;; assume first note
  iampatt   =           0
  iprevcps  =           icps
  kcps      init        icps
notfirst:
  if        p3<0        igoto notlast
;;; assume last note
  iampdec   =           0
notlast:
  if        iatt<=0.5*idur igoto attok
  iatt      =           0.5*idur
attok:
  if iport<=0.5*idur    igoto portok
  iport     =           0.5*idur
portok:
;;; Now do amp from the set values: 
  kenv      linseg      iampatt, iatt, iamp, idur-iatt, iampdec
  kcps      linseg      iprevcps, iport, icps, idur-iport, icps
;;; Skip rest of initialization on tied note:
            tigoto      tieskip
;;    asig      oscil       kenv, kcps, giqsqr      ; OSCILLATOR
  asig      foscil      kenv, 0.5*kcps, 2, 3, kenv/iamp, gisine ; OSCILLATOR
  ares1     reson       asig, ifc1, ifc1/iq1    ; RESON1 - BANDWIDTH = Fc/Q
  ares2     reson       asig, ifc2, ifc2/iq2    ; RESON2 - BANDWIDTH = Fc/Q
  aout      =           ares1+ares2             ; ADD FILTERED SIGNALS
  adel      oscil       .0004, 6, gisine
  adel      flanger     aout, adel+.0005, 0.2, .001
  aout      =           aout+adel
  aout      balance     aout, asig              ; BALANCE AGAINST ORIGINAL
  gaout2    =           gaout2+aout
tieskip:                                        ; Skip some initialization on tied note
done:
endin 

;;; Channel 3

instr 30

;;; This is instrument 601 from Stephen David Beck, "Designing
;;; Acoustically Viable Instruments in Csound", Chapter 6, in [2].

;;; p3--duration
;;; p4--pitch
;;; p5--amplitude

  idur      =           abs(p3)
  icps      =           cpspch(p4)
  iamp      =           ampdb(p5)

  if        givol30<=0  goto done
  iatt      =           p3*.1                   ; ATTACK IS 10% OF DURATION
  idec      =           p3*.1                   ; DECAY IS 10% OF DURATION
  ifc1      =           200                     ; Fc OF RESON 1
  iq1       =           5                       ; Q OF RESON 1
  ifc2      =           550                     ; Fc OF RESON 2
  iq2       =           3                       ; Q OF RESON 2
  kenv      linen       iamp, iatt, idur, idec  ; AMPLITUDE ENVELOPE
  asig      oscil       kenv, icps, giqsqr      ; OSCILLATOR
  ares1     reson       asig, ifc1, ifc1/iq1    ; RESON1 - BANDWIDTH = Fc/Q
  ares2     reson       asig, ifc2, ifc2/iq2    ; RESON2 - BANDWIDTH = Fc/Q
  areso     =           ares1+ares2             ; ADD FILTERED SIGNALS
  aout      balance     areso, asig             ; BALANCE AGAINST ORIGINAL
  gaout3    =           gaout3+aout
done:
endin 

instr 35

;;; A snare drum

;;; p4--pitch
;;; p5--amplitude

  icps      =           cpspch(p4)
  iamp      =           ampdb(p5)

  if        givol35<=0  goto done
  aout      pluck       iamp, icps, icps, gisine, 3, 0.5
  gaout3    =           gaout3+aout
done:
endin

;;; Channel mixer

instr 40

;;; Mixer with reverb

;;; p4--reverb time
;;; p5--reverb amplitude fraction--range 0 to 1
;;; p6--high frequency decay

  irevtime  =           p4
  iamp      =           p5
  ihdif     =           p6

  aout1     =           gaout1*givol
  aout2     =           gaout2*givol
  aout3     =           gaout3*givol
  gaout1    =           0
  gaout2    =           0
  gaout3    =           0
  acntr     =           aout3*gisr2b2
            outs        aout1+acntr, aout2+acntr

  if        givol40<=0  goto done
  aout1     =           aout1+aout2+aout3
  aout2     =           aout1*iamp*gisr2b2

;  aout3     reverb2     aout2, irevtime, ihdif
;            outs        aout3, aout3
;            goto        done

;;; Add a stereo diffusion of echoes.  This is essentially instrument
;;; 2305 from Eric Lyon, "An Introduction to Reverberation Design with
;;; Csound", Chapter 23 in [2].

  aout3     =           aout2/6
  adelline  delayr      0.2
  amtap1    deltap      0.0430
  amtap2    deltap      0.0320
  amtap3    deltap      0.1458
  amtap4    deltap      0.1423
  amtap5    deltap      0.0103
  amtap6    deltap      0.0239
  amtap7    deltap      0.0446
  amtap8    deltap      0.1035
  amtap9    deltap      0.1067
  amtap10   deltap      0.0087
  amtap11   deltap      0.0837
  amtap12   deltap      0.1676
            delayw      aout3
  arev1     =           amtap1+amtap2+amtap3+amtap4+amtap5+amtap6
  arev2     =           amtap7+amtap8+amtap9+amtap10+amtap11+amtap12
  aout1     reverb2     arev1, irevtime, ihdif
  aout2     reverb2     arev2, irevtime, ihdif
            outs        aout1, aout2
done:
endin
</CsInstruments>
<CsScore>
;;; Csound Score for Knowing, a.k.a. You Know I Know.
;;; John D. Ramsdell -- February 2001

;;; This score renders a piece written for piano in 1973 for a music
;;; course at Cornell University.  I think the title was chosen as a
;;; message to the instructor that I knew how to score music.  The
;;; piano score is available on the Internet.

;;; The score was created from a MIDI file and then edited.  The
;;; conversion process showed errors in the MIDI file near beat 83.0!
;;; The score was also changed at beat 26.0.  Other changes were
;;; made to take advantage of the fact that the instruments are not
;;; limited to piano-like behaviors.

;; KNOWING.MID - Csound score
;; created by Midi2Cs 0.95
;; Tue Jan 16 17:27:14 2001

;; time: 05/04 beats 0-40, 84-127
;; time: 02/04 beats 40-84
;; beat 83 has been elongated.
t 0 70.0 83.0 70.0 83.0 65.0 84.0 65.0 84.0 70.0
;;a 0 0 35.0                              ; Start of bridge
;;a 0 0 82.0                              ; End of bridge
;;a 0 0 104.0                             ; Last few bars of song

;;;--------------------------------------------
;;; Channel 1 -- Rhythm 
;;;--------------------------------------------

;;; p1--instrument
;;; p2--start
;;; p3--duration
;;; p4--pitch
;;; p5--amplitude
;;; p6--mix between plucks and bells--range 0 to 1
;;; p7--bell vibrato depth

;; time: 05/04 beat
i10    0.00   1.00  8.03 79.0 0.25 0.2; D#3 ch01 
i10    0.00   1.00  9.00 ;  C4 ch01 
i10    1.00   1.00  8.03 ; D#3 ch01 
i10    1.00   1.00  9.03 ; D#4 ch01 
i10    2.00   1.00  8.07 ;  G3 ch01 
i10    2.00   1.00  9.03 ; D#4 ch01 
i10    3.00   2.00  9.02 ;  D4 ch01 
i10    3.00   2.00  8.05 ;  F3 ch01 
;; bar 1
i10    5.00   1.00  8.07 ;  G3 ch01 
i10    5.00   1.00  9.03 ; D#4 ch01 
i10    6.00   1.00  8.10 ; A#3 ch01 
i10    6.00   1.00  9.07 ;  G4 ch01 
i10    7.00   1.00  9.07 ;  G4 ch01 
i10    7.00   1.00  9.02 ;  D4 ch01 
i10    8.00   2.00  9.05 ;  F4 ch01 
i10    8.00   2.00  9.02 ;  D4 ch01 
;; bar 2
i10   10.00   1.00  9.08 ; G#4 ch01 
i10   10.00   1.00  9.00 ;  C4 ch01 
i10   10.00   1.00  8.08 ; G#3 ch01 
i10   11.00   1.00  9.07 ;  G4 ch01 
i10   11.00   1.00  8.10 ; A#3 ch01 
i10   11.00   1.00  8.07 ;  G3 ch01 
i10   12.00   1.00  9.05 ;  F4 ch01 
i10   12.00   1.00  8.08 ; G#3 ch01 
i10   12.00   1.00  8.05 ;  F3 ch01 
i10   13.00   2.00  9.03 ; D#4 ch01 
i10   13.00   2.00  8.07 ;  G3 ch01 
i10   13.00   2.00  8.03 ; D#3 ch01 
;; bar 3
i10   15.00   1.00  8.03 ; D#3 ch01 
i10   15.00   1.00  9.00 ;  C4 ch01 
i10   16.00   1.00  8.07 ;  G3 ch01 
i10   16.00   1.00  9.03 ; D#4 ch01 
i10   17.00   1.00  9.03 ; D#4 ch01 
i10   17.00   1.00  8.08 ; G#3 ch01 
i10   17.00   1.00  8.03 ; D#3 ch01 
i10   18.00   2.00  9.03 ; D#4 ch01 
i10   18.00   2.00  8.07 ;  G3 ch01 
i10   18.00   2.00  8.03 ; D#3 ch01 
;; bar 4
i10   20.00   1.00  9.02 ;  D4 ch01 
i10   21.00   1.00  9.05 ;  F4 ch01 
i10   22.00   1.00  9.05 ;  F4 ch01 
i10   23.00   2.00  9.03 ; D#4 ch01 
;; bar 5
i10   25.00   1.00  9.05 ;  F4 ch01 
i10   26.00   1.00  9.09 ;  A4 ch01 
i10   27.00   1.00  9.09 ;  A4 ch01 
i10   28.00   2.00  9.07 ;  G4 ch01 
;; bar 6
i10   30.00   1.00  9.02 ;  D4 ch01 
i10   30.00   1.00  9.10 ; A#4 ch01 
i10   31.00   1.00  9.08 ; G#4 ch01 
i10   31.00   1.00  9.00 ;  C4 ch01 
i10   32.00   1.00  9.05 ;  F4 ch01 
i10   32.00   1.00  8.10 ; A#3 ch01 
i10   33.00   2.00  9.07 ;  G4 ch01 
i10   33.00   2.00  9.02 ;  D4 ch01 
;; bar 7
i10   35.00   1.00  9.00 ;  C4 ch01 
i10   35.00   1.00  8.08 ; G#3 ch01 
i10   36.00   1.00  9.03 ; D#4 ch01 
i10   36.00   1.00  8.07 ;  G3 ch01 
i10   37.00   1.00  9.02 ;  D4 ch01 
i10   37.00   1.00  8.05 ;  F3 ch01 
i10   38.00   2.00  9.10 . 0.90 0.5; A#4 ch01 
i10   38.00   2.00  9.03 ; D#4 ch01 
i10   38.00   2.00  8.10 ; A#3 ch01 
;; time: 02/04 beat
;; bar 8
i10   40.00   0.50  8.08 ; G#3 ch01 
i10   40.00   0.50  9.08 ; G#4 ch01 
i10   40.00   0.50  9.04 ;  E4 ch01 
;; bar 9
i10   42.00   2.00  8.03 ; D#3 ch01 
i10   42.00   2.00  8.10 ; A#3 ch01 
i10   42.00   2.00  9.03 ; D#4 ch01 
;; bar 10
i10   44.00   0.50  8.04 ;  E3 ch01 
i10   44.00   0.50  8.08 ; G#3 ch01 
i10   44.00   0.50  9.04 ;  E4 ch01 
;; bar 11
i10   46.00   2.00  8.03 ; D#3 ch01 
i10   46.00   2.00  8.10 ; A#3 ch01 
i10   46.00   2.00  9.03 ; D#4 ch01 
;; bar 12
i10   48.00   0.50  9.04 ;  E4 ch01 
i10   48.00   0.50  8.08 ; G#3 ch01 
i10   48.00   0.50  8.04 ;  E3 ch01 
;; bar 13
i10   50.00   2.00  8.03 ; D#3 ch01 
i10   50.00   2.00  8.10 ; A#3 ch01 
i10   50.00   2.00  9.03 ; D#4 ch01 
;; bar 14
;; bar 15
i10   54.00   2.00  8.10 ; A#3 ch01 
i10   54.00   2.00  9.03 ; D#4 ch01 
i10   54.00   2.00  9.10 ; A#4 ch01 
;; bar 8
i10   56.00   0.50  8.08 ; G#3 ch01 
i10   56.00   0.50  9.08 ; G#4 ch01 
i10   56.00   0.50  9.04 ;  E4 ch01 
;; bar 9
i10   58.00   2.00  8.03 ; D#3 ch01 
i10   58.00   2.00  8.10 ; A#3 ch01 
i10   58.00   2.00  9.03 ; D#4 ch01 
;; bar 10
i10   60.00   0.50  8.04 ;  E3 ch01 
i10   60.00   0.50  8.08 ; G#3 ch01 
i10   60.00   0.50  9.04 ;  E4 ch01 
;; bar 11
i10   62.00   2.00  8.03 ; D#3 ch01 
i10   62.00   2.00  8.10 ; A#3 ch01 
i10   62.00   2.00  9.03 ; D#4 ch01 
;; bar 12
i10   64.00   0.50  9.04 ;  E4 ch01 
i10   64.00   0.50  8.08 ; G#3 ch01 
i10   64.00   0.50  8.04 ;  E3 ch01 
;; bar 13
i10   66.00   2.00  8.03 ; D#3 ch01 
i10   66.00   2.00  8.10 ; A#3 ch01 
i10   66.00   2.00  9.03 ; D#4 ch01 
;; bar 14
;; bar 15
i10   70.00   2.00  8.10 ; A#3 ch01 
i10   70.00   2.00  9.03 ; D#4 ch01 
i10   70.00   2.00  9.10 ; A#4 ch01 
;; bar 16
i10   72.00   0.50  8.08 ; G#3 ch01 
i10   72.00   0.50  9.08 ; G#4 ch01 
i10   72.00   0.50  9.04 ;  E4 ch01 
;; bar 17
i10   74.00   2.00  8.10 ; A#3 ch01 
i10   74.00   2.00  9.03 ; D#4 ch01 
i10   74.00   2.00  9.10 ; A#4 ch01 
;; bar 18
i10   76.00   0.50  9.02 ;  D4 ch01 
i10   76.00   0.50  8.11 ;  B3 ch01 
;; bar 19
i10   78.00   2.00  8.03 ; D#3 ch01 
i10   78.00   2.00  8.10 ; A#3 ch01 
i10   78.00   2.00  9.03 ; D#4 ch01 
;; bar 20
i10   80.00   0.50  8.08 ; G#3 ch01 
i10   80.00   0.50  9.04 ;  E4 ch01 
;; bar 21
i10   82.00   1.00  9.00 . 0.5;  C4 ch01 
i10   82.00   1.00  9.04 ;  E4 ch01 
i10   82.00   1.00 10.00 ;  C5 ch01 
i10   83.00   1.00  9.10 ; A#4 ch01 
i10   83.00   1.00  9.07 ;  G4 ch01 
i10   83.00   1.00  9.04 ;  E4 ch01 
i10   83.00   1.00  9.01 ; C#4 ch01 
;; bar 22
;; time: 05/04 beat
i10   84.00   1.00  9.08 77.0 0.25 0.2; G#4 ch01 
i10   84.00   1.00  9.05 ;  F4 ch01 
i10   84.00   1.00  8.08 ; G#3 ch01 
i10   85.00   1.00  9.07 ;  G4 ch01 
i10   85.00   1.00  9.03 ; D#4 ch01 
i10   85.00   1.00  8.07 ;  G3 ch01 
i10   86.00   1.00  9.05 ;  F4 ch01 
i10   86.00   1.00  8.10 ; A#3 ch01 
i10   87.00   1.00  9.02 ;  D4 ch01 
i10   87.00   1.00  8.08 ; G#3 ch01 
i10   88.00   1.00  9.04 ;  E4 ch01 
i10   88.00   1.00  8.07 ;  G3 ch01 
;; bar 23
i10   89.00   1.00  9.05 ;  F4 ch01 
i10   89.00   1.00  9.01 ; C#4 ch01 
i10   89.00   1.00  8.05 ;  F3 ch01 
i10   90.00   1.00  9.00 ;  C4 ch01 
i10   90.00   1.00  8.03 ; D#3 ch01 
i10   91.00   1.00  8.08 ; G#3 ch01 
i10   91.00   1.00  8.02 ;  D3 ch01 
i10   92.00   1.00  8.03 ; D#3 ch01 
i10   92.00   1.00  8.07 ;  G3 ch01 
i10   93.00   1.00  8.05 ;  F3 ch01 
i10   93.00   1.00  8.08 ; G#3 ch01 
;; bar 24
i10   94.00   0.50  8.07 ;  G3 ch01 
i10   94.00   0.50  8.10 ; A#3 ch01 
i10   94.50   0.50  8.08 ; G#3 ch01 
i10   94.50   0.50  9.00 ;  C4 ch01 
i10   95.00   0.50  8.10 ; A#3 ch01 
i10   95.00   0.50  9.02 ;  D4 ch01 
i10   95.50   1.50  9.03 ; D#4 ch01 
i10   95.50   1.50  9.00 ;  C4 ch01 
i10   95.50   1.50  8.07 ;  G3 ch01 
i10   97.00   0.50  9.05 ;  F4 ch01 
i10   97.00   0.50  9.00 ;  C4 ch01 
i10   97.00   0.50  8.08 ; G#3 ch01 
i10   97.50   1.50  9.03 ; D#4 ch01 
i10   97.50   1.50  9.00 ;  C4 ch01 
i10   97.50   1.50  8.07 ;  G3 ch01 
;; bar 25
i10   99.00   1.00  9.02 ;  D4 ch01 
i10   99.00   1.00  8.11 ;  B3 ch01 
i10   99.00   1.00  8.05 ;  F3 ch01 
i10  100.00   2.00  9.00 ;  C4 ch01 
i10  100.00   2.00  8.07 ;  G3 ch01 
i10  100.00   2.00  8.04 ;  E3 ch01 
i10  102.00   2.00  8.03 79.0 ; D#3 ch01 
;; bar 26
i10  104.00   1.00  8.03 ; D#3 ch01 
i10  104.00   1.00  9.00 ;  C4 ch01 
i10  105.00   1.00  8.03 ; D#3 ch01 
i10  105.00   1.00  9.03 ; D#4 ch01 
i10  106.00   1.00  8.07 ;  G3 ch01 
i10  106.00   1.00  9.03 ; D#4 ch01 
i10  107.00   2.00  9.02 ;  D4 ch01 
i10  107.00   2.00  8.05 ;  F3 ch01 
;; bar 27
i10  109.00   1.00  8.07 ;  G3 ch01 
i10  109.00   1.00  9.03 ; D#4 ch01 
i10  110.00   1.00  8.10 ; A#3 ch01 
i10  110.00   1.00  9.07 ;  G4 ch01 
i10  111.00   1.00  9.07 ;  G4 ch01 
i10  111.00   1.00  9.02 ;  D4 ch01 
i10  112.00   2.00  9.05 ;  F4 ch01 
i10  112.00   2.00  9.02 ;  D4 ch01 
;; bar 28
i10  114.00   1.00  9.08 ; G#4 ch01 
i10  114.00   1.00  9.00 ;  C4 ch01 
i10  114.00   1.00  8.08 ; G#3 ch01 
i10  115.00   1.00  9.07 ;  G4 ch01 
i10  115.00   1.00  8.10 ; A#3 ch01 
i10  115.00   1.00  8.07 ;  G3 ch01 
i10  116.00   1.00  9.05 ;  F4 ch01 
i10  116.00   1.00  8.08 ; G#3 ch01 
i10  116.00   1.00  8.05 ;  F3 ch01 
i10  117.00   2.00  9.03 ; D#4 ch01 
i10  117.00   2.00  8.07 ;  G3 ch01 
i10  117.00   2.00  8.03 ; D#3 ch01 
;; bar 29
i10  119.00   1.00  8.03 ; D#3 ch01 
i10  119.00   1.00  9.00 ;  C4 ch01 
i10  120.00   1.00  8.07 ;  G3 ch01 
i10  120.00   1.00  9.03 ; D#4 ch01 
i10  121.00   2.00  9.02 ;  D4 ch01 
i10  121.00   2.00  8.05 ;  F3 ch01 
i10  123.00   3.00  8.03 ; D#3 ch01 
i10  123.00   3.00  8.07 ;  G3 ch01 
i10  123.00   3.00  9.03 ; D#4 ch01 
;; bar 30
;; bar 31

;;;--------------------------------------------
;;; Channel 2 -- Lead
;;;--------------------------------------------

;;; p1--instrument
;;; p2--start
;;; p3--duration
;;; p4--pitch
;;; p5--amplitude
;;; p6--previous pitch
;;; p7--next amplitude

;; time: 05/04 beat
i20    0.50  -0.50  7.03 84.0 0.0 np5; D#2 ch02 
i20    1.00  -0.50  7.07   .  pp4 np5;  G2 ch02 
i20    1.50  -0.50  7.08 ; G#2 ch02 
i20    2.00  -0.50  7.07 ;  G2 ch02 
i20    2.50   1.00  7.05 ;  F2 ch02 
i20    3.50  -0.50  7.10 ; A#2 ch02 
i20    4.00  -0.50  7.08 ; G#2 ch02 
i20    4.50   0.50  7.05 ;  F2 ch02 
;; bar 1
i20    5.00  -0.50  7.07 ;  G2 ch02 
i20    5.50  -0.50  8.00 ;  C3 ch02 
i20    6.00  -0.50  8.03 ; D#3 ch02 
i20    6.50  -0.50  8.00 ;  C3 ch02 
i20    7.00  -0.50  7.11 ;  B2 ch02 
i20    7.50   1.00  7.10 ; A#2 ch02 
i20    8.50  -0.50  7.08 ; G#2 ch02 
i20    9.00  -0.50  7.05 ;  F2 ch02 
i20    9.50   0.50  7.07 ;  G2 ch02 
;; bar 2
i20   10.00  -0.50  7.03 ; D#2 ch02 
i20   10.50  -0.50  7.05 ;  F2 ch02 
i20   11.00  -0.50  7.03 ; D#2 ch02 
i20   11.50  -0.50  7.00 ;  C2 ch02 
i20   12.00  -0.50  6.10 ; A#1 ch02 
i20   12.50   1.00  7.02 ;  D2 ch02 
i20   13.50  -0.50  7.00 ;  C2 ch02 
i20   14.00  -0.50  6.10 ; A#1 ch02 
i20   14.50   0.50  6.07 ;  G1 ch02 
;; bar 3
i20   15.00  -0.50  7.00 ;  C2 ch02 
i20   15.50  -0.50  7.02 ;  D2 ch02 
i20   16.00  -0.50  7.03 ; D#2 ch02 
i20   16.50  -0.50  7.08 ; G#2 ch02 
i20   17.00  -0.50  7.00 ;  C2 ch02 
i20   17.50   1.00  7.02 ;  D2 ch02 
i20   18.50  -0.50  7.03 ; D#2 ch02 
i20   19.00  -0.50  7.05 ;  F2 ch02 
i20   19.50   0.50  8.00 ;  C3 ch02 
;; bar 4
i20   20.00  -0.50  8.02 ;  D3 ch02 
i20   20.50  -0.50  8.05 ;  F3 ch02 
i20   21.00  -0.50  8.09 ;  A3 ch02 
i20   21.50  -0.50  8.10 ; A#3 ch02 
i20   22.00  -0.50  8.09 ;  A3 ch02 
i20   22.50  -0.50  8.07 ;  G3 ch02 
i20   23.00   0.50  8.07 ;  G3 ch02 
i20   23.50  -0.50  9.00 ;  C4 ch02 
i20   24.00  -0.50  8.10 ; A#3 ch02 
i20   24.50   0.50  8.07 ;  G3 ch02 
;; bar 5
i20   25.00  -0.50  8.09 ;  A3 ch02 
i20   25.50  -0.50  9.02 ;  D4 ch02 
;;; Change from Score!  Original
;;; i20   26.00  -0.50  8.05 ;  F3 ch02 
;;; Became (Note lifted an octave)
i20   26.00  -0.50  9.05 ;  F4 ch02 
i20   26.50  -0.50  9.02 ;  D4 ch02 
i20   27.00  -0.50  9.00 ;  C4 ch02 
i20   27.50  -0.50  8.10 ; A#3 ch02 
i20   28.00   0.50  8.10 ; A#3 ch02 
i20   28.50  -0.50  9.00 ;  C4 ch02 
i20   29.00  -0.50  8.07 ;  G3 ch02 
i20   29.50   0.50  8.09 ;  A3 ch02 
;; bar 6
i20   30.00  -0.50  8.05 ;  F3 ch02 
i20   30.50  -0.50  8.07 ;  G3 ch02 
i20   31.00  -0.50  8.05 ;  F3 ch02 
i20   31.50  -0.50  8.02 ;  D3 ch02 
i20   32.00  -0.50  8.02 ;  D3 ch02 
i20   32.50  -0.50  7.10 ; A#2 ch02 
i20   33.00   0.50  7.10 ; A#2 ch02 
i20   33.50  -0.50  7.07 ;  G2 ch02 
i20   34.00  -0.50  7.05 ;  F2 ch02 
i20   34.50   0.50  7.02 ;  D2 ch02 
;; bar 7
i20   35.00  -0.50  7.03 ; D#2 ch02 
i20   35.50  -0.50  7.05 ;  F2 ch02 
i20   36.00  -0.50  7.03 ; D#2 ch02 
i20   36.50  -0.50  7.00 ;  C2 ch02 
i20   37.00  -0.50  6.10 ; A#1 ch02 
i20   37.50   0.50  7.02 ;  D2 ch02 
;; rest 2 beats
;; time: 02/04 beat
;; bar 8
i25   40.50  -0.25  8.07 84.0 0.0 np5;  G3 ch02 
i25   40.75  -0.25  8.08   .  pp4 np5; G#3 ch02 
i25   41.00  -0.25  8.10 ; A#3 ch02 
i25   41.25  -0.25  8.08 ; G#3 ch02 
i25   41.50  -0.25  8.07 ;  G3 ch02 
i25   41.75  -0.25  8.08 ; G#3 ch02 
;; bar 9
i25   42.00   2.00  8.03 ; D#3 ch02 
;; bar 10
i25   44.50  -0.25  8.04 ;  E3 ch02 
i25   44.75  -0.25  8.05 ;  F3 ch02 
i25   45.00  -0.25  8.08 ; G#3 ch02 
i25   45.25  -0.25  8.05 ;  F3 ch02 
i25   45.50  -0.25  8.04 ;  E3 ch02 
i25   45.75  -0.25  8.05 ;  F3 ch02 
;; bar 11
i25   46.00   2.00  8.03 ; D#3 ch02 
;; bar 12
i25   48.50  -0.25  8.04 ;  E3 ch02 
i25   48.75  -0.25  8.05 ;  F3 ch02 
i25   49.00  -0.25  8.08 ; G#3 ch02 
i25   49.25  -0.25  8.11 ;  B3 ch02 
i25   49.50  -0.25  8.08 ; G#3 ch02 
i25   49.75  -0.25  8.05 ;  F3 ch02 
;; bar 13
i25   50.00   2.00  8.03 ; D#3 ch02 
;; bar 14
i25   52.50  -0.25  8.04 ;  E3 ch02 
i25   52.75  -0.25  8.05 ;  F3 ch02 
i25   53.00  -0.25  8.08 ; G#3 ch02 
i25   53.25  -0.25  8.11 ;  B3 ch02 
i25   53.50  -0.25  9.02 ;  D4 ch02 
i25   53.75  -0.25  9.05 ;  F4 ch02 
;; bar 15
i25   54.00   2.00  9.03 ; D#4 ch02 
;; bar 8
i25   56.50  -0.25  8.07 ;  G3 ch02 
i25   56.75  -0.25  8.08 ; G#3 ch02 
i25   57.00  -0.25  8.10 ; A#3 ch02 
i25   57.25  -0.25  8.08 ; G#3 ch02 
i25   57.50  -0.25  8.07 ;  G3 ch02 
i25   57.75  -0.25  8.08 ; G#3 ch02 
;; bar 9
i25   58.00   2.00  8.03 ; D#3 ch02 
;; bar 10
i25   60.50  -0.25  8.04 ;  E3 ch02 
i25   60.75  -0.25  8.05 ;  F3 ch02 
i25   61.00  -0.25  8.08 ; G#3 ch02 
i25   61.25  -0.25  8.05 ;  F3 ch02 
i25   61.50  -0.25  8.04 ;  E3 ch02 
i25   61.75  -0.25  8.05 ;  F3 ch02 
;; bar 11
i25   62.00   2.00  8.03 ; D#3 ch02 
;; bar 12
i25   64.50  -0.25  8.04 ;  E3 ch02 
i25   64.75  -0.25  8.05 ;  F3 ch02 
i25   65.00  -0.25  8.08 ; G#3 ch02 
i25   65.25  -0.25  8.11 ;  B3 ch02 
i25   65.50  -0.25  8.08 ; G#3 ch02 
i25   65.75  -0.25  8.05 ;  F3 ch02 
;; bar 13
i25   66.00   2.00  8.03 ; D#3 ch02 
;; bar 14
i25   68.50  -0.25  8.04 ;  E3 ch02 
i25   68.75  -0.25  8.05 ;  F3 ch02 
i25   69.00  -0.25  8.08 ; G#3 ch02 
i25   69.25  -0.25  8.11 ;  B3 ch02 
i25   69.50  -0.25  9.02 ;  D4 ch02 
i25   69.75  -0.25  9.05 ;  F4 ch02 
;; bar 15
i25   70.00   2.00  9.03 ; D#4 ch02 
;; bar 16
i25   72.50  -0.25  8.04 ;  E3 ch02 
i25   72.75  -0.25  8.05 ;  F3 ch02 
i25   73.00  -0.25  8.08 ; G#3 ch02 
i25   73.25  -0.25  8.11 ;  B3 ch02 
i25   73.50  -0.25  9.02 ;  D4 ch02 
i25   73.75  -0.25  9.05 ;  F4 ch02 
;; bar 17
i25   74.00   2.00  9.03 ; D#4 ch02 
;; bar 18
i25   76.50  -0.25  9.00 ;  C4 ch02 
i25   76.75  -0.25  9.02 ;  D4 ch02 
i25   77.00  -0.25  8.10 ; A#3 ch02 
i25   77.25  -0.25  9.00 ;  C4 ch02 
i25   77.50  -0.25  8.08 ; G#3 ch02 
i25   77.75  -0.25  8.10 ; A#3 ch02 
;; bar 19
i25   78.00   2.00  8.03 ; D#3 ch02 
;; bar 20
i25   80.50  -0.25  8.10 ; A#3 ch02 
i25   80.75  -0.25  8.11 ;  B3 ch02 
i25   81.00  -0.25  9.02 ;  D4 ch02 
i25   81.25  -0.25  9.05 ;  F4 ch02 
i25   81.50  -0.25  9.08 ; G#4 ch02 
i25   81.75  -0.25  9.11 ;  B4 ch02 
;; bar 21
i25   82.00   1.00 10.00 ;  C5 ch02 
i25   83.00   1.00  9.10   . pp4 0.0; A#4 ch02 
;; bar 22
;; time: 05/04 beat
i20   84.00  -0.50  7.05 ;  F2 ch02 
i20   84.50   0.50  7.03 ; D#2 ch02 
i20   85.00  -0.50  7.10 ; A#2 ch02 
i20   85.50   0.50  7.08 ; G#2 ch02 
i20   86.00  -0.50  7.07 ;  G2 ch02 
i20   86.50   0.50  7.04 ;  E2 ch02 
i20   87.00  -0.50  7.10 ; A#2 ch02 
i20   87.50  -0.50  7.08 ; G#2 ch02 
i20   88.00  -0.50  7.10 ; A#2 ch02 
i20   88.50   0.50  7.08 ; G#2 ch02 
;; bar 23
i20   89.00  -0.50  7.05 ;  F2 ch02 
i20   89.50   0.50  7.03 ; D#2 ch02 
i20   90.00  -0.50  7.07 ;  G2 ch02 
i20   90.50   0.50  7.08 ; G#2 ch02 
i20   91.00  -0.50  7.05 ;  F2 ch02 
i20   91.50  -0.50  7.02 ;  D2 ch02 
i20   92.00  -0.50  7.00 ;  C2 ch02 
i20   92.50  -0.50  7.03 ; D#2 ch02 
i20   93.00  -0.50  7.02 ;  D2 ch02 
i20   93.50   0.50  7.05 ;  F2 ch02 
;; bar 24
i20   94.00  -0.50  7.07 ;  G2 ch02 
i20   94.50  -0.50  7.05 ;  F2 ch02 
i20   95.00  -0.50  7.07 ;  G2 ch02 
i20   95.50   0.50  7.03 ; D#2 ch02 
i20   96.00  -0.50  7.07 ;  G2 ch02 
i20   96.50   0.50  7.10 ; A#2 ch02 
i20   97.00  -0.50  7.05 ;  F2 ch02 
i20   97.50  -0.50  7.03 ; D#2 ch02 
i20   98.00   0.50  7.00 ;  C2 ch02 
i20   98.50  -0.50  7.07 ;  G2 ch02 
;; bar 25
i20   99.00  -0.50  7.05 ;  F2 ch02 
i20   99.50   0.50  7.02 ;  D2 ch02 
i20  100.00   0.50  7.00 ;  C2 ch02 
i20  100.50   0.50  7.04 ;  E2 ch02 
i20  101.00   0.50  7.07 ;  G2 ch02 
i20  101.50   0.50  7.04 ;  E2 ch02 
i20  102.00   0.50  7.00 ;  C2 ch02 
i20  102.50   0.50  7.03 ; D#2 ch02 
i20  103.00   0.50  7.07 ;  G2 ch02 
i20  103.50   0.50  7.03 ; D#2 ch02 
;; bar 26
i20  104.00  -0.50  7.00 ;  C2 ch02 
i20  104.50  -0.50  7.03 ; D#2 ch02 
i20  105.00  -0.50  7.07 ;  G2 ch02 
i20  105.50  -0.50  7.08 ; G#2 ch02 
i20  106.00  -0.50  7.07 ;  G2 ch02 
i20  106.50   1.00  7.05 ;  F2 ch02 
i20  107.50  -0.50  7.10 ; A#2 ch02 
i20  108.00  -0.50  7.08 ; G#2 ch02 
i20  108.50   0.50  7.05 ;  F2 ch02 
;; bar 27
i20  109.00  -0.50  7.07 ;  G2 ch02 
i20  109.50  -0.50  8.00 ;  C3 ch02 
i20  110.00  -0.50  8.03 ; D#3 ch02 
i20  110.50  -0.50  8.00 ;  C3 ch02 
i20  111.00  -0.50  7.11 ;  B2 ch02 
i20  111.50   1.00  7.10 ; A#2 ch02 
i20  112.50  -0.50  7.08 ; G#2 ch02 
i20  113.00  -0.50  7.05 ;  F2 ch02 
i20  113.50   0.50  7.07 ;  G2 ch02 
;; bar 28
i20  114.00  -0.50  7.03 ; D#2 ch02 
i20  114.50  -0.50  7.05 ;  F2 ch02 
i20  115.00  -0.50  7.03 ; D#2 ch02 
i20  115.50  -0.50  7.00 ;  C2 ch02 
i20  116.00  -0.50  6.10 ; A#1 ch02 
i20  116.50   1.00  7.02 ;  D2 ch02 
i20  117.50  -0.50  7.00 ;  C2 ch02 
i20  118.00  -0.50  6.10 ; A#1 ch02 
i20  118.50   0.50  6.07 ;  G1 ch02 
;; bar 29
i20  119.00  -0.50  7.00 ;  C2 ch02 
i20  119.50  -0.50  7.02 ;  D2 ch02 
i20  120.00  -0.50  7.03 ; D#2 ch02 
i20  120.50  -0.50  7.08 ; G#2 ch02 
i20  121.00  -0.50  6.10 ; A#1 ch02 
i20  121.50  -0.50  7.02 ;  D2 ch02 
i20  122.00  -0.50  7.05 ;  F2 ch02 
i20  122.50  -0.50  7.03 ; D#2 ch02 
i20  123.00   3.00  7.03   . pp4 0.0; D#2 ch02 
;; bar 30
;; bar 31

;;;--------------------------------------------
;;; Channel 3 -- Bass and Drums
;;;--------------------------------------------

;;; p1--instrument
;;; p2--start
;;; p3--duration
;;; p4--pitch
;;; p5--amplitude

;; time: 05/04 beat
i30    0.00   2.00  6.08 85.0 ; G#1 ch03 
i30    2.00   3.00  6.10 ; A#1 ch03 
;; bar 1
i30    5.00   2.00  7.00 ;  C2 ch03 
i30    7.00   3.00  7.02 ;  D2 ch03 
;; bar 2
i30   10.00   2.00  6.08 ; G#1 ch03 
i30   12.00   3.00  6.03 ; D#1 ch03 
;; bar 3
i30   15.00   2.00  6.08 ; G#1 ch03 
i30   17.00   3.00  6.03 ; D#1 ch03 
;; bar 4
i30   20.00   2.00  7.10 ; A#2 ch03 
i30   22.00   3.00  8.00 80.0;  C3 ch03 
;; bar 5
i30   25.00   2.00  8.02 ;  D3 ch03 
i30   27.00   3.00  8.03 ; D#3 ch03 
;; bar 6
i30   30.00   2.00  7.10 85.0; A#2 ch03 
i30   32.00   3.00  7.07 ;  G2 ch03 
;; bar 7
i30   35.00   2.00  6.08 ; G#1 ch03 
i30   37.00   1.00  6.03 ; D#1 ch03 
i30   38.00   0.75  6.03 84.0; D#1 ch03 
i30   38.75   0.25  6.10 ; A#1 ch03 
i30   39.00   0.50  7.03 ; D#2 ch03 
i30   39.50   0.50  6.10 ; A#1 ch03 
;; time: 02/04 beat
;; bar 8
i30   40.00   0.75  6.04 ;  E1 ch03 
i30   40.75   0.25  6.11 ;  B1 ch03 
i30   41.00   0.50  7.04 ;  E2 ch03 
i30   41.50   0.50  6.11 ;  B1 ch03 
;; bar 9
i30   42.00   0.75  6.03 ; D#1 ch03 
i30   42.75   0.25  6.10 ; A#1 ch03 
i30   43.00   0.50  7.03 ; D#2 ch03 
i30   43.50   0.50  6.10 ; A#1 ch03 
;; bar 10
i30   44.00   0.75  6.04 ;  E1 ch03 
i30   44.75   0.25  6.11 ;  B1 ch03 
i30   45.00   0.50  7.04 ;  E2 ch03 
i30   45.50   0.50  6.11 ;  B1 ch03 
;; bar 11
i30   46.00   0.75  6.03 ; D#1 ch03 
i30   46.75   0.25  6.10 ; A#1 ch03 
i30   47.00   0.50  7.03 ; D#2 ch03 
i30   47.50   0.50  6.10 ; A#1 ch03 
;; bar 12
i30   48.00   0.75  6.04 ;  E1 ch03 
i30   48.75   0.25  6.11 ;  B1 ch03 
i30   49.00   0.50  7.04 ;  E2 ch03 
i30   49.50   0.50  6.11 ;  B1 ch03 
;; bar 13
i30   50.00   0.75  6.03 ; D#1 ch03 
i30   50.75   0.25  6.10 ; A#1 ch03 
i30   51.00   0.50  7.03 ; D#2 ch03 
i30   51.50   0.50  6.10 ; A#1 ch03 
;; bar 14
i30   52.00   0.75  6.04 ;  E1 ch03 
i30   52.75   0.25  6.11 ;  B1 ch03 
i30   53.00   0.50  7.04 ;  E2 ch03 
i30   53.50   0.50  6.11 ;  B1 ch03 
;; bar 15
i30   54.00   0.75  6.03 ; D#1 ch03 
i30   54.75   0.25  6.10 ; A#1 ch03 
i30   55.00   0.50  7.03 ; D#2 ch03 
i30   55.50   0.50  6.10 ; A#1 ch03 
;; bar 8
i30   56.00   0.75  6.04 ;  E1 ch03 
i30   56.75   0.25  6.11 ;  B1 ch03 
i30   57.00   0.50  7.04 ;  E2 ch03 
i30   57.50   0.50  6.11 ;  B1 ch03 
;; bar 9
i30   58.00   0.75  6.03 ; D#1 ch03 
i30   58.75   0.25  6.10 ; A#1 ch03 
i30   59.00   0.50  7.03 ; D#2 ch03 
i30   59.50   0.50  6.10 ; A#1 ch03 
;; bar 10
i30   60.00   0.75  6.04 ;  E1 ch03 
i30   60.75   0.25  6.11 ;  B1 ch03 
i30   61.00   0.50  7.04 ;  E2 ch03 
i30   61.50   0.50  6.11 ;  B1 ch03 
;; bar 11
i30   62.00   0.75  6.03 ; D#1 ch03 
i30   62.75   0.25  6.10 ; A#1 ch03 
i30   63.00   0.50  7.03 ; D#2 ch03 
i30   63.50   0.50  6.10 ; A#1 ch03 
;; bar 12
i30   64.00   0.75  6.04 ;  E1 ch03 
i30   64.75   0.25  6.11 ;  B1 ch03 
i30   65.00   0.50  7.04 ;  E2 ch03 
i30   65.50   0.50  6.11 ;  B1 ch03 
;; bar 13
i30   66.00   0.75  6.03 ; D#1 ch03 
i30   66.75   0.25  6.10 ; A#1 ch03 
i30   67.00   0.50  7.03 ; D#2 ch03 
i30   67.50   0.50  6.10 ; A#1 ch03 
;; bar 14
i30   68.00   0.75  6.04 ;  E1 ch03 
i30   68.75   0.25  6.11 ;  B1 ch03 
i30   69.00   0.50  7.04 ;  E2 ch03 
i30   69.50   0.50  6.11 ;  B1 ch03 
;; bar 15
i30   70.00   0.75  6.03 ; D#1 ch03 
i30   70.75   0.25  6.10 ; A#1 ch03 
i30   71.00   0.50  7.03 ; D#2 ch03 
i30   71.50   0.50  6.10 ; A#1 ch03 
;; bar 16
i30   72.00   0.75  6.04 ;  E1 ch03 
i30   72.75   0.25  6.11 ;  B1 ch03 
i30   73.00   0.50  7.04 ;  E2 ch03 
i30   73.50   0.50  6.11 ;  B1 ch03 
;; bar 17
i30   74.00   0.75  6.03 ; D#1 ch03 
i30   74.75   0.25  6.10 ; A#1 ch03 
i30   75.00   0.50  7.03 ; D#2 ch03 
i30   75.50   0.50  6.10 ; A#1 ch03 
;; bar 18
i30   76.00   0.75  6.04 ;  E1 ch03 
i30   76.75   0.25  6.11 ;  B1 ch03 
i30   77.00   0.50  7.04 ;  E2 ch03 
i30   77.50   0.50  6.11 ;  B1 ch03 
;; bar 19
i30   78.00   0.75  6.03 ; D#1 ch03 
i30   78.75   0.25  6.10 ; A#1 ch03 
i30   79.00   0.50  7.03 ; D#2 ch03 
i30   79.50   0.50  6.10 ; A#1 ch03 
;; bar 20
i30   80.00   0.75  6.04 ;  E1 ch03 
i30   80.75   0.25  6.11 ;  B1 ch03 
i30   81.00   0.50  7.04 ;  E2 ch03 
i30   81.50   0.50  6.11 ;  B1 ch03 
;; bar 21
i30   82.00   1.00  6.00 ;  C1 ch03 
i30   82.00   0.75  7.00 ;  C2 ch03 
i30   82.75   0.25  6.07 ;  G1 ch03 
i30   83.00   1.00  7.03 ; D#2 ch03 
i30   83.00   1.00  7.07 ;  G2 ch03 
i30   84.00   2.00  6.08 85.0; G#1 ch03 
i30   86.00   3.00  7.00 ;  C2 ch03 
;; bar 23
i30   89.00   2.00  6.08 ; G#1 ch03 
i30   91.00   3.00  6.05 ;  F1 ch03 
;; bar 24
i30   94.00   2.00  6.10 ; A#1 ch03 
i30   96.00   1.00  7.00 ;  C2 ch03 
i30   97.00   2.00  6.08 ; G#1 ch03 
;; bar 25
i30   99.00   1.00  6.07 ;  G1 ch03 
i30  100.00   4.00  6.00 ;  C1 ch03 
;; bar 26
i30  104.00   2.00  6.08 ; G#1 ch03 
i30  106.00   3.00  6.10 ; A#1 ch03 
;; bar 27
i30  109.00   2.00  7.00 ;  C2 ch03 
i30  111.00   3.00  7.02 ;  D2 ch03 
;; bar 28
i30  114.00   2.00  6.08 ; G#1 ch03 
i30  116.00   3.00  6.03 ; D#1 ch03 
;; bar 29
i30  119.00   2.00  6.08 ; G#1 ch03 
i30  121.00   3.00  6.03 ; D#1 ch03 
;; bar 30
i30  124.00   2.00  6.03 ; D#1 ch03 
;; bar 31

;;; Drums 

;; time: 05/04 beat
;; bar 7
;; rest 3 beats
i35   38.25   0.75  7.00  72.0
i35     +     0.50
i35     +     0.75
;; time: 02/04 beat
;; bar 8
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 9
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 10
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 11
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 12
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 13
i35     +     0.75
i35     +     0.50
i35     +     1.50
;; bar 14
i35     +     0.50
i35     +     0.75
;; bar 15
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 8
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 9
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 10
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 11
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 12
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 13
i35     +     0.75
i35     +     0.50
i35     +     1.50
;; bar 14
i35     +     0.50
i35     +     0.75
;; bar 15
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 16
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 17
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 18
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 19
i35     +     0.75
i35     +     0.50
i35     +     0.75
;; bar 20
i35     +     0.75
i35     +     0.50
i35     +     0.50
;; bar 21
i35     +     1.00
i35     +     1.00
;; bar 22
;; time: 05/04 beat

;;; After writing the drum section, I decided there must be a better
;;; way to avoid all the repetition.  My solution is Scheme Score.

;;; Scheme Score is a Csound score preprocessor.  Scheme Score
;;; translates a score file augmented with Scheme code into a Scheme
;;; program.  When the generated program is executed by a Scheme
;;; interpreter, it produces a processed score file for input to
;;; Csound.  Scheme Score is available on the Internet.

;;;--------------------------------------------
;;; Channel Mixer -- Reverberation
;;;--------------------------------------------

;;; p1--instrument
;;; p2--start
;;; p3--duration
;;; p4--reverb time
;;; p5--reverb amplitude fraction--range 0 to 1
;;; p6--high frequency decay

;;                  time  vol  hf decay
i40    0.00 127.00  2.5  0.1  0.3
;; end of score
e
</CsScore>

</CsoundSynthesizer>