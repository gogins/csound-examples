<CsoundSynthesizer>

<CsOptions>

--output=dac --nodisplays

</CsOptions>

<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1.0
girgfree_vco = 103
ir11 = girgfree_vco
ir13 vco2init 1, ir11
girgfree_vco = ir13
ir16 = girgfree_vco
ir18 vco2init 8, ir16
girgfree_vco = ir18
ir21 = girgfree_vco
ir23 vco2init 16, ir21
girgfree_vco = ir23
giPort init 1
opcode FreePort, i, 0
xout giPort
giPort = giPort + 1
endop


; Zero Delay Feedback Filters
; 
; Based on code by Will Pirkle, presented in:
;
; http://www.willpirkle.com/Downloads/AN-4VirtualAnalogFilters.2.0.pdf
; 
; and in his book "Designing software synthesizer plug-ins in C++ : for 
; RackAFX, VST3, and Audio Units"
;
; ZDF using Trapezoidal integrator by Vadim Zavalishin, presented in "The Art 
; of VA Filter Design" (https://www.native-instruments.com/fileadmin/ni_media/
; downloads/pdf/VAFilterDesign_1.1.1.pdf)
;
; UDO versions by Steven Yi (2016.xx.xx)


;; 1-pole (6dB) lowpass/highpass filter
;; takes in a a-rate signal and cutoff value in frequency
opcode zdf_1pole, aa, ak
  ain, kcf  xin

  ; pre-warp the cutoff- these are bilinear-transform filters
  kwd = 2 * $M_PI * kcf
  iT  = 1/sr 
  kwa = (2/iT) * tan(kwd * iT/2) 
  kg  = kwa * iT/2 

  ; big combined value
  kG  = kg / (1.0 + kg)

  ahp init 0
  alp init 0

  ;; state for integrators
  kz1 init 0

  kindx = 0
  while kindx < ksmps do
    ; do the filter, see VA book p. 46 
    ; form sub-node value v(n) 
    kin = ain[kindx]
    kv = (kin - kz1) * kG 

    ; form output of node + register 
    klp = kv + kz1 
    khp = kin - klp 

    ; z1 register update
    kz1 = klp + kv  

    alp[kindx] = klp
    ahp[kindx] = khp
    kindx += 1
  od

  xout alp, ahp
endop


;; 1-pole (6dB) lowpass/highpass filter
;; takes in a a-rate signal and cutoff value in frequency
opcode zdf_1pole, aa, aa
  ain, acf  xin

  ; pre-warp the cutoff- these are bilinear-transform filters
  iT  = 1/sr 

  ahp init 0
  alp init 0

  ;; state for integrators
  kz1 init 0

  kindx = 0
  while kindx < ksmps do
    ; pre-warp the cutoff- these are bilinear-transform filters
    kwd = 2 * $M_PI * acf[kindx]
    kwa = (2/iT) * tan(kwd * iT/2) 
    kg  = kwa * iT/2 

    ; big combined value
    kG  = kg / (1.0 + kg)

    ; do the filter, see VA book p. 46 
    ; form sub-node value v(n) 
    kin = ain[kindx]
    kv = (kin - kz1) * kG 

    ; form output of node + register 
    klp = kv + kz1 
    khp = kin - klp 

    ; z1 register update
    kz1 = klp + kv  

    alp[kindx] = klp
    ahp[kindx] = khp
    kindx += 1
  od

  xout alp, ahp
endop

;; 1-pole allpass filter
;; takes in an a-rate signal and corner frequency where input
;; phase is shifted -90 degrees
opcode zdf_allpass_1pole, a, ak
  ain, kcf xin
  alp, ahp zdf_1pole ain, kcf
  aout = alp - ahp
  xout aout
endop


;; 1-pole allpass filter
;; takes in an a-rate signal and corner frequency where input
;; phase is shifted -90 degrees
opcode zdf_allpass_1pole, a, aa
  ain, acf xin
  alp, ahp zdf_1pole ain, acf
  aout = alp - ahp
  xout aout
endop


;; 2-pole (12dB) lowpass/highpass/bandpass filter
;; takes in a a-rate signal, cutoff value in frequency, and
;; Q factor for resonance
opcode zdf_2pole,aaa,aKK

  ain, kcf, kQ     xin

  ; pre-warp the cutoff- these are bilinear-transform filters
  kwd = 2 * $M_PI * kcf
  iT  = 1/sr 
  kwa = (2/iT) * tan(kwd * iT/2) 
  kG  = kwa * iT/2 
  kR  = 1 / (2 * kQ)

  ;; output signals
  alp init 0
  ahp init 0
  abp init 0

  ;; state for integrators
  kz1 init 0
  kz2 init 0

  ;;
  kindx = 0
  while kindx < ksmps do
    khp = (ain[kindx] - (2 * kR + kG) * kz1 - kz2) / (1 + (2 * kR * kG) + (kG * kG))
    kbp = kG * khp + kz1
    klp = kG * kbp + kz2

    ; z1 register update
    kz1 = kG * khp + kbp  
    kz2 = kG * kbp + klp  

    alp[kindx] = klp
    ahp[kindx] = khp
    abp[kindx] = kbp
    kindx += 1
  od

  xout alp, abp, ahp

endop


;; 2-pole (12dB) lowpass/highpass/bandpass filter
;; takes in a a-rate signal, cutoff value in frequency, and
;; Q factor for resonance
opcode zdf_2pole,aaa,aaa

  ain, acf, aQ     xin

  iT  = 1/sr 

  ;; output signals
  alp init 0
  ahp init 0
  abp init 0

  ;; state for integrators
  kz1 init 0
  kz2 init 0

  ;;
  kindx = 0
  while kindx < ksmps do

    ; pre-warp the cutoff- these are bilinear-transform filters
    kwd = 2 * $M_PI * acf[kindx]
    kwa = (2/iT) * tan(kwd * iT/2) 
    kG  = kwa * iT/2 

    kR = 1 / (2 * aQ[kindx]) 

    khp = (ain[kindx] - (2 * kR + kG) * kz1 - kz2) / (1 + (2 * kR * kG) + (kG * kG))
    kbp = kG * khp + kz1
    klp = kG * kbp + kz2

    ; z1 register update
    kz1 = kG * khp + kbp  
    kz2 = kG * kbp + klp 

    alp[kindx] = klp
    ahp[kindx] = khp
    abp[kindx] = kbp
    kindx += 1
  od

  xout alp, abp, ahp

endop

;; 2-pole (12dB) lowpass/highpass/bandpass/notch filter
;; takes in a a-rate signal, cutoff value in frequency, and
;; Q factor for resonance
opcode zdf_2pole_notch,aaaa,aKK

  ain, kcf, kQ     xin

  ; pre-warp the cutoff- these are bilinear-transform filters
  kwd = 2 * $M_PI * kcf
  iT  = 1/sr 
  kwa = (2/iT) * tan(kwd * iT/2) 
  kG  = kwa * iT/2 
  kR  = 1 / (2 * kQ)

  ;; output signals
  alp init 0
  ahp init 0
  abp init 0
  anotch init 0

  ;; state for integrators
  kz1 init 0
  kz2 init 0

  ;;
  kindx = 0
  while kindx < ksmps do
    kin = ain[kindx]
    khp = (kin - (2 * kR + kG) * kz1 - kz2) / (1 + (2 * kR * kG) + (kG * kG))
    kbp = kG * khp + kz1
    klp = kG * kbp + kz2
    knotch = kin - (2 * kR * kbp)

    ; z1 register update
    kz1 = kG * khp + kbp  
    kz2 = kG * kbp + klp  

    alp[kindx] = klp
    ahp[kindx] = khp
    abp[kindx] = kbp
    anotch[kindx] = knotch
    kindx += 1
  od

  xout alp, abp, ahp, anotch

endop

;; 2-pole (12dB) lowpass/highpass/bandpass/notch filter
;; takes in a a-rate signal, cutoff value in frequency, and
;; Q factor for resonance
opcode zdf_2pole_notch,aaaa,aaa

  ain, acf, aQ     xin

  iT  = 1/sr 

  ;; output signals
  alp init 0
  ahp init 0
  abp init 0
  anotch init 0

  ;; state for integrators
  kz1 init 0
  kz2 init 0

  ;;
  kindx = 0
  while kindx < ksmps do

    ; pre-warp the cutoff- these are bilinear-transform filters
    kwd = 2 * $M_PI * acf[kindx]
    kwa = (2/iT) * tan(kwd * iT/2) 
    kG  = kwa * iT/2 

    kR = 1 / (2 * aQ[kindx])

    kin = ain[kindx]
    khp = (kin - (2 * kR + kG) * kz1 - kz2) / (1 + (2 * kR * kG) + (kG * kG))
    kbp = kG * khp + kz1
    klp = kG * kbp + kz2
    knotch = kin - (2 * kR * kbp)

    ; z1 register update
    kz1 = kG * khp + kbp  
    kz2 = kG * kbp + klp 

    alp[kindx] = klp
    ahp[kindx] = khp
    abp[kindx] = kbp
    anotch[kindx] = knotch
    kindx += 1
  od

  xout alp, abp, ahp, anotch

endop

;; moog ladder

opcode zdf_ladder, a, akk

  ain, kcf, kres     xin
  aout init 0

  kR = limit(1 - kres, 0.025, 1)

  kQ = 1 / (2 * kR) 

  kwd = 2 * $M_PI * kcf
  iT  = 1/sr 
  kwa = (2/iT) * tan(kwd * iT/2) 
  kg  = kwa * iT/2 

  kk = 4.0*(kQ - 0.707)/(25.0 - 0.707)

  kg_2 = kg * kg
  kg_3 = kg_2 * kg

  ; big combined value
  ; for overall filter
  kG  = kg_2 * kg_2  
  ; for individual 1-poles
  kG_pole = kg/(1.0 + kg)

  ;; state for each 1-pole's integrator 
  kz1 init 0
  kz2 init 0
  kz3 init 0
  kz4 init 0

  kindx = 0
  while kindx < ksmps do
    ;; processing
    kin = ain[kindx]

    kS = kg_3 * kz1 + kg_2 * kz2 + kg * kz3 + kz4
    ku = (kin - kk *  kS) / (1 + kk * kG)

    ;; 1st stage
    kv = (ku - kz1) * kG_pole 
    klp = kv + kz1
    kz1 = klp + kv

    ;; 2nd stage
    kv = (klp - kz2) * kG_pole 
    klp = kv + kz2
    kz2 = klp + kv

    ;; 3rd stage
    kv = (klp - kz3) * kG_pole 
    klp = kv + kz3
    kz3 = klp + kv

    ;; 4th stage
    kv = (klp - kz4) * kG_pole 
    klp = kv + kz4
    kz4 = klp + kv

    aout[kindx] = klp

    kindx += 1
  od

  xout aout
endop


opcode zdf_ladder, a, aaa

  ain, acf, ares     xin
  aout init 0

  iT  = 1/sr 

  ;; state for each 1-pole's integrator 
  kz1 init 0
  kz2 init 0
  kz3 init 0
  kz4 init 0

  kindx = 0
  while kindx < ksmps do

    kR = limit(1 - ares[kindx], 0.025, 1)

    kQ = 1 / (2 * kR) 

    kwd = 2 * $M_PI * acf[kindx]
    kwa = (2/iT) * tan(kwd * iT/2) 
    kg  = kwa * iT/2 

    kk = 4.0*(kQ - 0.707)/(25.0 - 0.707)

    kg_2 = kg * kg
    kg_3 = kg_2 * kg

    ; big combined value
    ; for overall filter
    kG  = kg_2 * kg_2  
    ; for individual 1-poles
    kG_pole = kg/(1.0 + kg)

    ;; processing
    kin = ain[kindx]

    kS = kg_3 * kz1 + kg_2 * kz2 + kg * kz3 + kz4
    ku = (kin - kk *  kS) / (1 + kk * kG)

    ;; 1st stage
    kv = (ku - kz1) * kG_pole 
    klp = kv + kz1
    kz1 = klp + kv

    ;; 2nd stage
    kv = (klp - kz2) * kG_pole 
    klp = kv + kz2
    kz2 = klp + kv

    ;; 3rd stage
    kv = (klp - kz3) * kG_pole 
    klp = kv + kz3
    kz3 = klp + kv

    ;; 4th stage
    kv = (klp - kz4) * kG_pole 
    klp = kv + kz4
    kz4 = klp + kv

    aout[kindx] = klp

    kindx += 1
  od

  xout aout
endop

;; 4-pole

opcode zdf_4pole, aaaaaa, akk
  ain, kcf, kres xin

  alp2, abp2, ahp2 zdf_2pole ain, kcf, kres

  abp4 init 0
  abl4 init 0
  alp4 init 0

  xout alp2, abp2, ahp2, alp4, abl4, abp4
endop

opcode zdf_4pole, aaaaaa, aaa
  ain, acf, ares xin

  alp2, abp2, ahp2 zdf_2pole ain, acf, ares
  abp4 init 0
  abl4 init 0
  alp4 init 0

  xout alp2, abp2, ahp2, alp4, abl4, abp4
endop


opcode zdf_4pole_hp, aaaaaa, akk
  ain, kcf, kres xin

  alp2, abp2, ahp2 zdf_2pole ain, kcf, kres

  ahp4 init 0
  abh4 init 0
  abp4 init 0

  xout alp2, abp2, ahp2, abp4, abh4, ahp4
endop

opcode zdf_4pole_hp, aaaaaa, aaa
  ain, acf, ares xin

  alp2, abp2, ahp2 zdf_2pole ain, acf, ares

  ahp4 init 0
  abh4 init 0
  abp4 init 0

  xout alp2, abp2, ahp2, abp4, abh4, ahp4
endop

;; TODO - implement
opcode zdf_peak_eq, a, akkk
  ain, kcf, kres, kdB xin

  aout init 0

  xout aout
endop

opcode zdf_high_shelf_eq, a, akk
  ain, kcf, kdB xin

  ;; TODO - convert db to K, check if reusing zdf_1pole is sufficient
  kK init 0

  alp, ahp zdf_1pole ain, kcf

  aout = ain + kK * ahp

  xout aout
endop

opcode zdf_low_shelf_eq, a, akk
  ain, kcf, kdB xin

  ;; TODO - convert db to K, check if reusing zdf_1pole is sufficient
  kK init 0

  alp, ahp zdf_1pole ain, kcf

  aout = ain + kK * alp

  xout aout
endop



instr 21

endin

instr 20
 event_i "i", 19, 604800.0, 1.0e-2
endin

instr 19
 turnoff2 18, 0.0, 0.0
 exitnow 
endin

instr 18
ar0 delayr 1.5
ir3 = 1.5
ar1 deltap3 ir3
ir6 = 5.0e-2
ir7 = 0.0
ir8 = 1.0
ar2 upsamp k(ir8)
kr0 lpshold ir6, ir7, 0.0, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir8, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8
ir10 = 1.0e-3
kr1 portk kr0, ir10
ar3 upsamp kr1
ar4 = (0.4 * ar3)
ir13 = 1210.0
kr0 vco2ft ir13, 4
ar3 oscilikt ir8, ir13, kr0
ar5 = (ar4 * ar3)
ar4 = (0.75 * ar1)
ar6 = (ar5 + ar4)
 delayw ar6
arl0 init 0.0
arl1 init 0.0
kr0 loopseg ir6, ir7, 0.0, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir8, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7
kr1 portk kr0, ir10
ar4 upsamp kr1
ar6 = (0.35 * ar4)
ir28 = 1430.0
kr0 vco2ft ir28, 4
ar4 oscilikt ir8, ir28, kr0
ir31 = 8.0
kr0 vco2ft ir31, 3
ar7 oscilikt ir8, ir31, kr0
ar8 = (0.5 * ar7)
ar7 = (0.5 + ar8)
ir36 = 1650.0
kr0 vco2ft ir36, 4
ar8 oscilikt ir8, ir36, kr0
ar9 = (ar7 * ar8)
ar8 = (ar4 + ar9)
ar4 = (ar6 * ar8)
ir42 = 0.15
ar6 oscil3 ir8, ir42, 2
ar8 = (0.5 * ar6)
ar6 = (0.5 + ar8)
ar8 = (0.25 * ar6)
ar9 = (0.2 + ar8)
ar8, ar10 pan2 ar4, ar9
ir50 = 0.125
kr0 lpshold ir50, ir7, 0.0, ir8, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir42, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8, ir7, ir8
kr1 portk kr0, ir10
ar4 upsamp kr1
ar9 = (0.2 * ar4)
ir54 = 770.0
kr0 vco2ft ir54, 4
ar4 oscilikt ir8, ir54, kr0
ar11 = (ar9 * ar4)
ar4 = (0.10000000000000003 * ar6)
ar6 = (0.45 + ar4)
ar4, ar9 pan2 ar11, ar6
ar6 = (ar8 + ar4)
ar4 = (0.36 * ar5)
ar8 = (ar1 * 1.0)
ar1 = (ar5 + ar8)
ar5 = (0.64 * ar1)
ar1 = (ar4 + ar5)
kr0 oscil3 ir8, ir8, 2
kr1 = (0.5 * kr0)
kr0 = (0.5 + kr1)
ar4 upsamp kr0
ar5 = (0.39999999999999997 * ar4)
ar8 = (0.3 + ar5)
ar5, ar11 pan2 ar1, ar8
ar1 = (ar6 + ar5)
ir76 = 3.8461538461538464e-2
ir77 = 0.5
ir78 = 0.2
kr1 loopseg ir76, ir7, 0.0, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir77, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir78, ir7
kr2 portk kr1, ir10
ar5 upsamp kr2
ar6 = (0.35 * ar5)
kr1 vco2ft ir31, 4
ar5 oscilikt ir8, ir31, kr1
ar8 = (0.5 * ar5)
ar5 = (0.5 + ar8)
ir86 = 1540.0
kr1 vco2ft ir86, 4
ar8 oscilikt ir8, ir86, kr1
ar12 = (ar5 * ar8)
ar5 = (ar3 + ar12)
ir91 = 9.0
kr1 vco2ft ir91, 4
ar3 oscilikt ir8, ir91, kr1
ar8 = (0.5 * ar3)
ar3 = (0.5 + ar8)
ir96 = 1760.0
kr1 vco2ft ir96, 4
ar8 oscilikt ir8, ir96, kr1
ar12 = (ar3 * ar8)
ar3 = (ar5 + ar12)
ar5 = (ar6 * ar3)
ir102 = 0.25
kr1 oscil3 ir8, ir102, 2
kr2 = (0.5 * kr1)
kr1 = (0.5 + kr2)
ar3 upsamp kr1
ar6 = (0.1499999999999999 * ar3)
ar8 = (0.8 + ar6)
ar6, ar12 pan2 ar5, ar8
ar5 = (ar1 + ar6)
ir111 = 2.9411764705882353e-2
ir112 = 0.75
kr2 loopseg ir111, ir7, 0.0, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir112, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir7, ir7, ir7, ir8, ir78, ir7, ir7, ir8, ir7, ir7
kr3 portk kr2, ir10
ar1 upsamp kr3
ir115 = 6.0
kr2 vco2ft ir115, 3
ar6 oscilikt ir8, ir115, kr2
ar8 = (0.5 * ar6)
ar6 = (0.5 + ar8)
kr2 vco2ft ir13, 0
ar8 oscilikt ir8, ir13, kr2
ar13 = (ar6 * ar8)
kr2 vco2ft ir36, 0
ar6 oscilikt ir8, ir36, kr2
ar8 = (ar7 * ar6)
ar6 = (ar13 + ar8)
ir127 = 7.0
kr2 vco2ft ir127, 3
ar7 oscilikt ir8, ir127, kr2
ar8 = (0.5 * ar7)
ar7 = (0.5 + ar8)
kr2 vco2ft ir96, 3
ar8 oscilikt ir8, ir96, kr2
ar13 = (ar7 * ar8)
ar7 = (ar6 + ar13)
ar6 = (ar1 * ar7)
ir137 = 0.18
ar1 oscil3 ir8, ir137, 2
ar7 = (0.5 * ar1)
ar1 = (0.5 + ar7)
ar7 = (0.15000000000000002 * ar1)
ar1 = (0.5 + ar7)
ar7, ar8 pan2 ar6, ar1
ar1 = (ar5 + ar7)
ir146 = 0.1
ar5 oscil3 ir8, ir146, 2
ar6 = (0.5 * ar5)
ar5 = (0.5 + ar6)
ar6 = (0.8 * ar5)
ar5 = (0.2 + ar6)
ar6 = (1.0 - ar5)
ir153 = 0.12
ar7 oscil3 ir8, ir153, 2, 0.3
ar13 = (0.5 * ar7)
ar7 = (0.5 + ar13)
ar13 = (0.8 * ar7)
ar7 = (0.2 + ar13)
ar13 = (1.0 - ar7)
ar14 = (ar6 * ar13)
ir161 = 43.0
ar15 oscil3 ir8, ir161, 2
ir163 = 23.0
ar16 oscil3 ir8, ir163, 2
ir165 = 85.0
ar17 oscil3 ir8, ir165, 2
ir167 = 60.0
ar18 oscil3 ir8, ir167, 2
kr2 loopseg ir112, ir7, 0.0, ir7, ir8, ir8, ir8, ir7, ir8, ir77, ir8, ir7, ir8, ir78, ir8, ir7, ir8, ir146, ir8, ir7, ir7, ir7
kr3 portk kr2, ir10
ar19 upsamp kr3
ir171 = 220.0
ar20 oscil3 ir8, ir171, 2
ar21 oscil3 ir8, ir78, 2
ar22 = (1.3 * ar21)
ar21 = (220.0 + ar22)
ar22 oscil3 ir8, ar21, 2
ar21 = (ar20 + ar22)
ar20 = (6.0 * ar4)
ar4 = (220.0 + ar20)
ar20 oscil3 ir8, ar4, 2
ar4 = (ar21 + ar20)
ir182 = 223.5
ar20 oscil3 ir8, ir182, 2
ar21 = (ar4 + ar20)
ar4 = (ar21 / 4.0)
ar20 = (ar19 * ar4)
ar4 = (ar18 * ar20)
ar18 = (ar17 * ar4)
ar4 = (ar16 * ar18)
ar16 = (ar15 * ar4)
ir191 = 110.0
kr2 vco2ft ir191, 4
ar4 oscilikt ir8, ir191, kr2
ar15 = (1.0e-2 * ar4)
ar4 = (ar16 + ar15)
ar15 = (ar14 * ar4)
ar14 = (ar5 * ar13)
ir198 = 750.0
ar13 moogvcf ar4, ir198, ir146
ar16 = (ar14 * ar13)
ar13 = (ar15 + ar16)
ar14 = (ar5 * ar7)
ir203 = 450.0
ar5 moogladder ar4, ir203, ir78
ar15 = (ar14 * ar5)
ar5 = (ar13 + ar15)
ar13 = (ar6 * ar7)
ir208 = 1660.0
kr2 lpshold ir6, ir7, 0.0, ir7, ir8, ir7, ir8, ir8, ir8, ir7, ir8, ir7, ir8
kr3 portk kr2, ir10
kr2 = (0.2 * kr0)
kr0 = (0.2 + kr2)
kr2 = (kr3 * kr0)
kr0 = (kr2 * kr1)
kr1 = (0.7 + kr0)
kr0 = (3.5 * kr1)
kr1 = (0.5 + kr0)
ar6 tbvcf ar4, ir208, ir77, kr1, ir77
ar4 = (ar13 * ar6)
ar6 = (ar5 + ar4)
ar4 = (ar1 + ar6)
ir222 = 0.27
ar1 oscil3 ir8, ir222, 2
ar5 = (0.5 * ar1)
ar1 = (0.5 + ar5)
ar5 = (ar3 + ar1)
ar1 = (100.0 * ar5)
ar3 = (350.0 + ar1)
ir229 = 0.17
ar1 oscil3 ir8, ir229, 2
ar5 = (0.5 * ar1)
ar1 = (0.5 + ar5)
ar5 = (0.3 * ar1)
ar1 = (0.2 + ar5)
ar5 zdf_ladder ar4, ar3, ar1
ir236 = 95.0
ar4 buthp ar5, ir236
ar5 = (0.75 * ar4)
ar7 = (ar10 + ar9)
ar9 = (ar7 + ar11)
ar7 = (ar9 + ar12)
ar9 = (ar7 + ar8)
ar7 = (ar9 + ar6)
ar6 zdf_ladder ar7, ar3, ar1
ar1 buthp ar6, ir236
ir251 = 0.99
ir252 = 12000.0
ar3, ar6 reverbsc ar4, ar1, ir251, ir252
ar7 = (ar4 + ar3)
ar3 = (0.25 * ar7)
ar4 = (ar5 + ar3)
ar3 = (5.5 * ar4)
ir259 = 90.0
ir260 = 100.0
ar4 compress ar3, ar2, ir7, ir259, ir259, ir260, ir7, ir7, 0.0
ar3 = (ar4 * 0.8)
arl0 = ar3
ar3 = (0.75 * ar1)
ar4 = (ar1 + ar6)
ar1 = (0.25 * ar4)
ar4 = (ar3 + ar1)
ar1 = (5.5 * ar4)
ar3 compress ar1, ar2, ir7, ir259, ir259, ir260, ir7, ir7, 0.0
ar1 = (ar3 * 0.8)
arl1 = ar1
ar1 = arl0
ar2 = arl1
 outs ar1, ar2
endin

</CsInstruments>

<CsScore>

f2 0 8192 10  1.0

f0 604800.0

i 21 0.0 -1.0 
i 20 0.0 -1.0 
i 18 0.0 -1.0 

</CsScore>



</CsoundSynthesizer>