<CsoundSynthesizer>
<CsOptions>
-RWZdo Maple7.wav
</CsOptions>
<CsInstruments>
sr 		= 		44100
ksmps 	= 		1
nchnls 	= 		2

garvb init 0
gadelay init 0
gadelay2 init 0
gamousy init 0
gamousy2 init 0
gamousy3 init 0
gamousy4 init 0
gklfo init 0


;drums
instr 101
ilevel = 1
idrum = p6
irvbsend = 0
idelsend = .2
if (idrum == 1) kgoto kick
if (idrum == 2) kgoto snare
if (idrum == 3) kgoto hihat

kick:
kpenv linseg 60, 1, 40 
kampenv expseg .001, .01, p4, 1, .001
a1 foscil kampenv, kpenv, 1, 4, p5, 1
kgoto contin

snare: 
kampenv expseg p4, .5, .001
a1 oscili kampenv, p5, 2
kgoto contin

hihat:
kampenv linseg p4+5000, .2, 0
asig oscili kampenv, p5, 2
afilt2 atone asig, 8000
afilt1 atone afilt2, 8000
a1 = afilt2
kgoto contin

contin:
a1 = a1 * ilevel
outs a1, a1
garvb = garvb+a1 * irvbsend
gadelay = gadelay + a1 * idelsend 
endin


;sine
instr 102
ilevel = .8
istay = .2
ifall = 1
ifrq = cpspch(p5)
ipan = (p6/128)
irvbsend = .1
idelsend = .5

if (p7 == 0) kgoto contin
kvib oscil 100, 8, 1       ; if anything other than 0 is in p7, vibrato

contin:
kampenv linseg 0, .01, p4, .05, (p4/2), 1, 0
kpenv   linseg  ifrq, ifall, cpspch((p5 - .01))
asound oscili kampenv, kpenv + kvib, 1
a1 = 2 * asound * ipan
a2 = 2 * asound * (1 - ipan)
a1 = a1 * ilevel
a2 = a2 * ilevel
outs a2, a1
garvb = garvb + asound * irvbsend
gadelay = gadelay + asound * idelsend
kampenv = 0
endin

; guitar
instr 103
ilevel = .8
iamp = p4 * .7
iwhoneedsthis = p6
idur = p3
ifrq = cpspch(p5)
idelsend = .4
irvbsend = 0
kampenv linseg iamp, idur, 0
a1 pluck kampenv, ifrq, ifrq / 2, 0, 1

a1 = a1 * ilevel
;outs a1, a1
garvb = garvb + a1 * irvbsend
gadelay2 = gadelay2 + a1 * idelsend
endin

;grain dive
instr 104
ilevel = 1
ifrq = p5
idur = p3
iamp = p4
idens = 1100
iampdeviation = 0
ipitchoff = 880
igraindur = .01

idelsend = .1
irvbsend = .1

kampenv linseg 0, .01, p4, idur - .1, 0
ktrem oscili 1, 5, 1
kpitchoffc linseg ifrq * 2, idur, 0

asig grain kampenv * ktrem, kpitchoffc, idens, iampdeviation, kpitchoffc, igraindur, 1, 1, 1

kpanenv linseg .8, idur, .2    ; do some cool panning
a1 = asig * kpanenv
a2 = asig * (1 - kpanenv)
a1 = a1 * ilevel
a2 = a2 * ilevel
outs a1, a2
gadelay = gadelay + asig * idelsend
garvb = garvb + asig * irvbsend
endin

; bass
instr 105
iamp = p4
idur = p3
iwhoneedsthis = p6
ifrq = cpspch(p5)
kfiltenv linseg 5000, idur, 60
kampenv  linseg 0, .01, iamp, idur - .05, 0
asig oscili kampenv, ifrq, 3       ; triangle wave, biatch
afilt3 tone asig, kfiltenv
afilt2 tone afilt3, kfiltenv
afilt1 reson afilt2, kfiltenv, 1000
afilt  reson afilt1, 80, 300
afin balance afilt, asig 

outs afin, afin
endin

; sawtooth
instr 106
idur = p3
iamp = p4 / 3
idelsend = .8
irvbsend = 0
ifrq = cpspch(p5)
kfiltenv linseg 1000, idur, 100
kampenv linseg 0, .01, iamp, idur - .01, 0
;asig oscil kampenv, ifrq, 4
asig pluck kampenv, ifrq, ifrq, 4, 6
afilt2 butterlp asig, gklfo * 8000 + kfiltenv
afilt1 butterbp asig, gklfo * 8000 + kfiltenv, 100
afin balance afilt1, asig

a1 = afilt2
outs a1, a1
gadelay = gadelay + a1 * idelsend
garvb = garvb + a1 * irvbsend
endin

;-------------------EFFECTS
;global lfo
instr 197
gklfo expseg .001, 6, 1, 6, .001
endin

;globle dillay 2   ; eigth notes
instr 196
idellevel = .5
ideltime =  1 * (60/150)
idelstereospread = .3                           ; (MAX = .5)
gadelay2 = gadelay2 * idellevel
asec delay gadelay2, ideltime                  ; setup the offset to go to asig2
anit delay gadelay2 + gamousy3, ideltime          ; calculate the first delay
asig delay gadelay2 + gamousy4, (ideltime * 2)    ; start the chain for asig
asig2 delay asec + gamousy3, (ideltime *2)       ; start the chain for asig2
gamousy3 = asig * .5
gamousy4 = asig2 * .5                             ; multiplier for loop

;a1 = asig * (.5 + idelstereospread) + ((asig2 + anit) * (.5 - idelstereospread))
;a2 = (asig2 * (.5 + idelstereospread)) + (asig * (.5 - idelstereospread))
outs asig, asig2 + anit
gadelay2 = 0
endin

;globle dillay   
instr 198
idellevel = .5
ideltime =  1 * (60/200)
idelstereospread = .3                           ; (MAX = .5)
gadelay = gadelay * idellevel
asec delay gadelay, ideltime                  ; setup the offset to go to asig2
anit delay gadelay + gamousy, ideltime          ; calculate the first delay
asig delay gadelay + gamousy2, (ideltime * 2)    ; start the chain for asig
asig2 delay asec + gamousy, (ideltime *2)       ; start the chain for asig2
gamousy = asig * .5
gamousy2 = asig2 * .5                             ; multiplier for loop

;a1 = asig * (.5 + idelstereospread) + ((asig2 + anit) * (.5 - idelstereospread))
;a2 = (asig2 * (.5 + idelstereospread)) + (asig * (.5 - idelstereospread))
outs asig, asig2 + anit
gadelay = 0
endin

; globle revarb
instr 199
irvbtim = .5
ihiatn = .5
arvb nreverb  garvb, irvbtim, ihiatn
outs arvb, arvb
garvb = 0
endin
;------------------------
</CsInstruments>
<CsScore>
f 1 0 65536 10 1                           ; sine
f 2 0 65536 21 6 1                         ; noise
f 3 0 65536 7  0 1024 1 2048 -1 1024 0     ; triangle wave
f 4 0 65536 7  -1 4096 1                   ; sawtooth

t 0 150    ;set tempo to 135

;a 0 0 164

#define REGDRUMS # 
;drums
;inst st dr   amp   crzy  idrum
i101  0  1  15000   0     1
i101  0  1   5000   1289  3
i101  .5  1  10000   0     1
i101 1.5 1  10000    0     1
i101  2  1  20000   1289   2
i101 3.5  1  15000    0     1
i101  4   1   5000  1289    3
i101  5   1  10000    0     1
i101 5.5  1  10000    .3     1
i101  6   1  20000   1289   2 #

#define DRUMSBECOMINGFM #
; drums becoming fm
i101  0  1  15000   .4     1
i101  0  1   5000   1289  3
i101  .5  1  10000  .5     1
i101 1.5 1  10000    1     1
i101  2  1  20000   1289   2
i101 3.5  1 10000  1.5     1
i101  4   1   5000  1289   3
i101  5   1  8000   2      1
i101 5.5  1  6000   2.5     1
i101  6   1  20000   1000   2
i101 6.5   1 1000   1000   2
i101  7  1   5000   1000   2 #

#define DRUMS3 #
;inst st dr   amp   crzy  idrum
i101  0  1  15000   0     1
i101  0  1   5000   1289  3
i101  .5  1  10000   0     1
i101 1.5 1  10000    .2     1
i101  2  1  20000   1289   2
i101 3.5  1  15000   .5     1
i101  4   1   5000  1289    3
i101  5   1  10000    1    1
i101 5.5  1  10000    2     1
i101  6   1  20000   1289   2 #

#define DRUMS4 #
i101 0  1  15000  0     1
i101 0  1   6000  3     1
i101 0  1   5000  1289  3
i101 .5 1   4000  3.5   1
i101 1  1  5000  1289  2
i101 2  1  20000  1287  2
i101 2.5  1 5000  4     1
i101  3   1 3000  5     1
i101  3  1  5000  1000  3 
i101 3.5  1 5000  6     1
i101  4  1  5000  7     1
i101 5.5 1 10000  940   2
i101  6  1 20000  1000  2
i101 6.5 1 10000  1000  2
i101 7   1 10000   950  2 #

#define BORINGDRUMS #
;drums
;inst st dr   amp   crzy  idrum
i101  0  1  15000   0     1
i101  0  1   5000   1289  3
i101  .5  1  10000   0     1
i101 1.5 1  10000    0     1
i101  2  1  20000   1289   2
i101 3.5  1  15000    0     1
i101  4   1   5000  1289    3
i101  5   1  10000    0     1
i101 5.5  1  10000    .3     1
i101  6   1  20000   1289   2 #

#define SINETHEME1 #
;sine
i102  0  4  3000  8.18  90   0
i102 1.5  4  3000  8.21  30
i102  3   4  3000 8.15  90
i102  5   4  3000 8.25  20  1 #

#define SINETHEME2 #
;sine part 2
i102  0  4  3000  8.18  90   0
i102 1.5  4  3000  8.21  30
i102  3   4  3000 8.15  90 #


#define SAWTOOTHCHORDS # 
;sawtooth chords
i106  0  .2  5000 8.09
i106  .  .2    .  8.04
i106  .  .2    .  8.01
i106  .5 .2    .  8.09
i106  .  .2    .  8.04
i106  .  .2    .  8.01
i106  1  .2  5000 8.09
i106  .  .2    .  8.04
i106  .  .2    .  8.01
i106 1.5 .2    .  8.09
i106  .  .2    .  8.04
i106  .  .2    .  8.01
i106  2  .2  5000 8.09
i106  .  .2    .  8.04
i106  .  .2    .  8.01
i106 2.5 .2    .  8.09
i106  .  .2    .  8.04
i106  .  .2    .  8.01
i106  3  .2  5000 8.09
i106  .  .2    .  8.04
i106  .  .2    .  8.01
i106 3.5 .2    .  8.09
i106  .  .2    .  8.04
i106  .  .2    .  8.01 #

#define GUITARI # ;guit I-
i103  .02   1   5000   8.06
i103  .05   .     .    8.09
i103  0   .     .    8.01
i103 .49   .     .    8.06
i103  .52   .     .    8.09
i103  .5   .     .    8.01
i103 1.5  .     .    8.06
i103 1.47   .     .    8.09
i103 1.53   .     .    8.01
i103 3.51  .     .    8.06
i103 3.5   .     .    8.09
i103 3.52   .     .    8.01
i103 4.5  .     .    8.06
i103 4.46   .     .    8.09
i103 4.51   .     .    8.01
i103  7   .     .    8.06
i103 7.02   .     .    8.09
i103 6.99   .     .    8.01
i103 7.5  .     .    8.06
i103 7.47   .     .    8.09
i103 7.51   .     .    8.01 
#

#define GUITARV # ;guit  V-
i103 .02   1   5000   8.04
i103 .05   .     .    8.08
i103  0   .     .    8.01
i103 .49   .     .    8.04
i103 .52   .     .    8.08
i103  .5   .     .    8.01
i103 1.5  .     .    8.04
i103 1.47   .     .    8.08
i103 1.53   .     .    8.01
i103 3.51  .     .    8.04
i103 3.5   .     .    8.08
i103 3.52   .     .    8.01
i103 4.5  .     .    8.04
i103 4.46   .     .    8.08
i103 4.51   .     .    8.01
i103  7  .     .     8.04
i103 7.02   .     .    8.08
i103 6.99   .     .    8.01
i103 7.5  .     .    8.04
i103 7.47   .     .    8.08
i103 7.51   .     .    8.01 
#

#define GUITARIV # ;guit  IV-
i103 .02   1   5000   8.02
i103 .05   .     .    8.06
i103  0   .     .    7.99
i103 .49   .     .    8.02
i103 .52   .     .    8.06
i103  .5   .     .    7.99
i103 1.5  .     .    8.02
i103 1.47   .     .    8.06
i103 1.53   .     .    7.99
i103 3.51  .     .    8.02
i103 3.5   .     .    8.06
i103 3.52   .     .    7.99
i103 4.5  .     .    8.02
i103 4.46   .     .    8.06
i103 4.51   .     .    7.99
i103  7  .     .     8.02
i103 7.02   .     .    8.06
i103 6.99   .     .    7.99
i103 7.5  .     .    8.02
i103 7.47   .     .    8.06
i103 7.51   .     .    7.99 
#

#define GUITARII # ;guit II-
i103  .02   1   5000   8.08
i103  .05   .     .    8.11
i103  0   .     .    8.02
i103 .49   .     .    8.08
i103  .52   .     .    8.11
i103  .5   .     .    8.02
i103 1.5  .     .    8.08
i103 1.47   .     .    8.11
i103 1.53   .     .    8.02
i103 3.51  .     .    8.08
i103 3.5   .     .    8.11
i103 3.52   .     .    8.02
i103 4.5  .     .    8.08
i103 4.46   .     .    8.011
i103 4.51   .     .    8.02
i103  7   .     .    8.08
i103 7.02   .     .    8.11
i103 6.99   .     .    8.02
i103 7.5  .     .    8.08
i103 7.47   .     .    8.11
i103 7.51   .     .    8.03 
#



#define BASSI #
;bass
i105  0  .8  2000  6.04
i105  .5  1    .   6.06
i105 1.5  .    .   6.06
i105 3.5  .    .   6.04
i105  6   .    .   6.04
i105  6.5 .    .   6.06 #

#define BASSV #
;bass
i105  0  .8  2000  6.04
i105  .5  1    .   6.01
i105 1.5  .    .   6.04
i105 3.5  .    .   6.04
i105 4.5   .    .   6.01 #

#define BASSIV #
;bass
i105  0  .8  2000  6.02
i105  .5  1    .   6.02
i105 1.5  .    .   6.02
i105  3.5 .    .   6.02
i105  4.5 .    .   6.02

#

#define CHILLBASS #
;bass
i105  0  .8  4000  6.04
i105  1  1    .    6.06
i105 3.5  1   .    6.04
i105  5   1   .    6.06 #

#define CHILLV #
;bass
i105  0  .8  4000  6.04
i105  1  1    .    6.01
i105 3.5  1   .    6.04
i105  5   1   .    6.01 #

#define BREAKITDOWN #
;break it down
i101 0 1 5000 950   2
i101 .5 1 5000 9000  2
i101 1 1  5000  940   2
i101 5 1 5000  930   2
i101 5.5 1  5000  8800   2
i101 6 1 5000  910   2
i101 6.5  1  5000  9000   2 #

#define BREAKITDOWN2 #
;break it down 2
i101 0 1 5000 950   2
i101 .5 1 5000 9000  2
i101 1 1  5000  940   2
i101 5 1 5000  930   2
i101 5.5 1  5000  8800   2
i101 6 1 5000  910   2
i101 6.5  1  5000  9000   2 #

#define DRUMHIT #
i101  0  1  15000   0     1
i101  0  1   5000   1289  3
i101  .5  1  10000   0     1
i101 1.5 1  10000    0     1
i101  2  1  20000   1289   2 #


;start song-------------------

i199  0  240
i198  0  240
i197  0  16
i196  0  240

$SAWTOOTHCHORDS.

b 8

$SAWTOOTHCHORDS.

b 16
i197  0  16
$SAWTOOTHCHORDS.
$REGDRUMS.

b 24

$DRUMSBECOMINGFM.
$SAWTOOTHCHORDS.
b 32

$DRUMS3.

b 40

$DRUMS4.

b 48
$BREAKITDOWN.
$SINETHEME1.

b 56
$BREAKITDOWN2.
$SINETHEME2.

b 64
$REGDRUMS.
$SINETHEME1.

b 72
$REGDRUMS.
$SINETHEME2.

b 80
$SINETHEME1.
$REGDRUMS.

b 88
$DRUMSBECOMINGFM.
$SINETHEME2.

b 96
$SINETHEME1.
$DRUMS3.

b 104
$SINETHEME2.
$DRUMS4.

b 112
$BREAKITDOWN.

b 120
$BREAKITDOWN2.

b 128
$GUITARI.

b 136
$GUITARV.

b 144
$GUITARIV.

b 152

b 160
$GUITARI-.
$BASSI-.

b 168
$GUITARV-.
$BASSV-.

b 176
$GUITARIV-.
$BASSIV.

b 184
;grain
i104 0 8 500  1000

b 192
$GUITAR-.
i197  0  16
$SAWTOOTHCHORDS.
$REGDRUMS.
$BASSI-.

b 200
$GUITARV.
$SAWTOOTHCHORDS.
$REGDRUMS.
$BASSV-.

b 208
$GUITARIV.
i197  0  16
$SAWTOOTHCHORDS.
$REGDRUMS.
$BASSIV-.

b 216
$DRUMS4.
</CsScore>

</CsoundSynthesizer>