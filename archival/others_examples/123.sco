; instr 1

f1 0 1024 10 1
f2 0 128 5 1 128 8   ;for veloc to non-linear amp

; instr 2

f3 0 0 1 "Guitar/Nylon Gtr Sus E1" 0 4 0	;e1 40	Set SSDIR = /ti/sound/bv/Samples
f4 0 0 1 "Guitar/Nylon Gtr Sus A1" 0 4 0	;a1 45
f5 0 0 1 "Guitar/Nylon Gtr Sus D2" 0 4 0	;d2 50
f6 0 0 1 "Guitar/Nylon Gtr Sus G2" 0 4 0	;g2 55
f7 0 0 1 "Guitar/Nylon Gtr Sus B2" 0 4 0	;b2 59
f8 0 0 1 "Guitar/Nylon Gtr Sus E3" 0 4 0	;e3 64
f9 0 0 1 "Guitar/Nylon Gtr Sus A3" 0 4 0	;a3 69
f10 0 0 1 "Guitar/Nylon Gtr Sus D4" 0 4 0	;d4 74
f11 0 0 1 "Guitar/Nylon Gtr Sus G4" 0 4 0	;g4 79

f95 0 128 5 1 128 10		;veloc to non-linear amp
f98 0 128 -17 0 40 43 45 48 50 53 55 57 59 62 64 67 69 72 74 77 79 ;map to basenot
f99 0 128 -17 0  3 43  4 48  5 53  6 57  7 62  8 67  9 72 10 77 11 ;map to tables

; instr 3

f12 0 128 5 1 128 10	;for veloc to non-linear amp
f13 0 0 1 "TRUMP/TRUMPET SUS MF A3 LP AIFF" 0 4 0   ;find with SSDIR = /ti/sound/bv/Samples
f14 0 0 1 "TRUMP/TRUMPET SUS MF D4 LP AIFF" 0 4 0
f15 0 0 1 "TRUMP/TRUMPET SUS MF G4 LP AIFF" 0 4 0
f16 0 0 1 "TRUMP/TRUMPET SUS MF C5 LP AIFF" 0 4 0
f17 0 0 1 "TRUMP/TRUMPET SUS MF F5 LP AIFF" 0 4 0
f18 0 0 1 "TRUMP/TRUMPET SUS MF A#5 LP AIFF" 0 4 0

f19 0 128 -17 0 13 60 14 65 15 71 16 76 17 81 18	;mapping to tables
f20 0 128 -17 0 57 60 62 65 67 71 72 76 77 81 82	;baseFreq
f0 600
e

