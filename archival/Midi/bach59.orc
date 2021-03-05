sr          =           44100
kr          =           4410
ksmps       =           10
nchnls      =           1

garvbsig    init        0                       ; a global "a" variable
  
 ;*************************************************
            instr       1                       ; Saprano
itab        =           2                       ; saprano table values
iattack     =           .4
irelease    =           .2
iatdec      =           .01
ifund       cpsmidi     
iamp        ampmidi     1500, 27
inh         =           sr/2/ifund              ; creates a bandlimited pulse
ifun        =           1
icutoff     =           ifund
;********************
;    Vibrato            -    **I    knowthisstillneedswork!*****
idur        =           2
kvibrate    randh       1, 1                    ;randomize rate from 4 to 6 Hz 
iv1         =           ifund*.03
iv2         =           ifund*.04
iv3         =           ifund*.05
iv4         =           ifund*.06
kvibf       linseg      0, idur/4, iv1, idur/4, iv2, idur/4, iv3, idur/4, iv4
kvib        oscil       kvibf, (kvibrate+5), 1
;********************
;Table Access 
;********************
icfreqf1    table       0, itab
icfreqf2    table       1, itab
icfreqf3    table       2, itab
icfreqf4    table       3, itab
icfreqf5    table       4, itab

ibwf1       table       5, itab
ibwf2       table       6, itab
ibwf3       table       7, itab
ibwf4       table       8, itab
ibwf5       table       9, itab

iampf1      table       10, itab
iampf2      table       11, itab
iampf3      table       12, itab
iampf4      table       13, itab
iampf5      table       14, itab

 ;print iampf1, iampf2,iampf3, iampf4, iampf5

iampf1      =           iampf1+dbamp(iamp)
iampf2      =           iampf2+dbamp(iamp)
iampf3      =           iampf3+dbamp(iamp)
iampf4      =           iampf4+dbamp(iamp)
iampf5      =           iampf5+dbamp(iamp)

 ;print iampf1, iampf2, iampf3, iampf4, iampf5

iampf1      =           ampdb(iampf1)+iamp
iampf2      =           ampdb(iampf2)+iamp
iampf3      =           ampdb(iampf3)+iamp
iampf4      =           ampdb(iampf4)+iamp
iampf5      =           ampdb(iampf5)+iamp

; print iampf1, iampf2, iampf3, iampf4, iampf5
; print icfreqf1,icfreqf2, icfreqf3, icfreqf4, icfreqf5 
; print ibwf1, ibwf2, ibwf3, ibwf4, ibwf5
 
  
;**********************                  
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf1, ibwf1
afltsigout  tone        asig2, icutoff
asigf1      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf2, ibwf2
afltsigout  tone        asig2, icutoff
asigf2      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf3, ibwf3
afltsigout  tone        asig2, icutoff
asigf3      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf4, ibwf4
afltsigout  tone        asig2, icutoff
asigf4      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf5, ibwf5
afltsigout  tone        asig2, icutoff
asigf5      =           kamp*afltsigout
;**********************

asigt       =           asigf1+asigf2+asigf3+asigf4+asigf5

;**********************
garvbsig    =           asigt*.4

            out         asigt

            endin       
;****************************************************
            instr       2                       ; Alto
itab        =           7                       ; alto table values
iattack     =           .4
irelease    =           .2
iatdec      =           .01
ifund       cpsmidi     
iamp        ampmidi     1500, 27
inh         =           sr/2/ifund              ; creates a bandlimited pulse
ifun        =           1
icutoff     =           ifund
;********************
    ;  Vibrato-    **I know this still needs work!*****
idur        =           2
kvibrate    randh       1, 1                    ;randomize rate from 4 to 6 Hz 
iv1         =           ifund*.03
iv2         =           ifund*.04
iv3         =           ifund*.05
iv4         =           ifund*.06
kvibf       linseg      0, idur/4, iv1, idur/4, iv2, idur/4, iv3, idur/4, iv4
kvib        oscil       kvibf, (kvibrate+5), 1
;********************
;Table Access 
;********************
icfreqf1    table       0, itab
icfreqf2    table       1, itab
icfreqf3    table       2, itab
icfreqf4    table       3, itab
icfreqf5    table       4, itab

ibwf1       table       5, itab
ibwf2       table       6, itab
ibwf3       table       7, itab
ibwf4       table       8, itab
ibwf5       table       9, itab

iampf1      table       10, itab
iampf2      table       11, itab
iampf3      table       12, itab
iampf4      table       13, itab
iampf5      table       14, itab

 ;print iampf1, iampf2,iampf3, iampf4, iampf5

iampf1      =           iampf1+dbamp(iamp)
iampf2      =           iampf2+dbamp(iamp)
iampf3      =           iampf3+dbamp(iamp)
iampf4      =           iampf4+dbamp(iamp)
iampf5      =           iampf5+dbamp(iamp)

 ;print iampf1, iampf2, iampf3, iampf4, iampf5

iampf1      =           ampdb(iampf1)+iamp
iampf2      =           ampdb(iampf2)+iamp
iampf3      =           ampdb(iampf3)+iamp
iampf4      =           ampdb(iampf4)+iamp
iampf5      =           ampdb(iampf5)+iamp

; print iampf1, iampf2, iampf3, iampf4, iampf5
; print icfreqf1,icfreqf2, icfreqf3, icfreqf4, icfreqf5
; print ibwf1, ibwf2, ibwf3, ibwf4, ibwf5
 
  
;**********************                  
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf1, ibwf1
afltsigout  tone        asig2, icutoff
asigf1      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf2, ibwf2
afltsigout  tone        asig2, icutoff
asigf2      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf3, ibwf3
afltsigout  tone        asig2, icutoff
asigf3      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf4, ibwf4
afltsigout  tone        asig2, icutoff
asigf4      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf5, ibwf5
afltsigout  tone        asig2, icutoff
asigf5      =           kamp*afltsigout
;**********************

asigt       =           asigf1+asigf2+asigf3+asigf4+asigf5

;**********************
garvbsig    =           asigt*.4

            out         asigt

            endin       
;***************************************************
            instr       3                       ; Tenor
itab        =           17                      ; tenor table values
iattack     =           .4
irelease    =           .2
iatdec      =           .01
ifund       cpsmidi     
iamp        ampmidi     1500, 27
inh         =           sr/2/ifund              ; creates a bandlimited pulse
ifun        =           1
icutoff     =           ifund
;********************
    ;  Vibrato-    **I know this still needs work!*****
idur        =           2
kvibrate    randh       1, 1                    ;randomize rate from 4 to 6 Hz 
iv1         =           ifund*.03
iv2         =           ifund*.04
iv3         =           ifund*.05
iv4         =           ifund*.06
kvibf       linseg      0, idur/4, iv1, idur/4, iv2, idur/4, iv3, idur/4, iv4
kvib        oscil       kvibf, (kvibrate+5), 1
;********************
;Table Access 
;********************
icfreqf1    table       0, itab
icfreqf2    table       1, itab
icfreqf3    table       2, itab
icfreqf4    table       3, itab
icfreqf5    table       4, itab

ibwf1       table       5, itab
ibwf2       table       6, itab
ibwf3       table       7, itab
ibwf4       table       8, itab
ibwf5       table       9, itab

iampf1      table       10, itab
iampf2      table       11, itab
iampf3      table       12, itab
iampf4      table       13, itab
iampf5      table       14, itab

 ;print iampf1, iampf2,iampf3, iampf4, iampf5

iampf1      =           iampf1+dbamp(iamp)
iampf2      =           iampf2+dbamp(iamp)
iampf3      =           iampf3+dbamp(iamp)
iampf4      =           iampf4+dbamp(iamp)
iampf5      =           iampf5+dbamp(iamp)

 ;print iampf1, iampf2, iampf3, iampf4, iampf5

iampf1      =           ampdb(iampf1)+iamp
iampf2      =           ampdb(iampf2)+iamp
iampf3      =           ampdb(iampf3)+iamp
iampf4      =           ampdb(iampf4)+iamp
iampf5      =           ampdb(iampf5)+iamp

; print iampf1, iampf2, iampf3, iampf4, iampf5
; print icfreqf1,icfreqf2, icfreqf3, icfreqf4, icfreqf5
; print ibwf1, ibwf2, ibwf3, ibwf4, ibwf5
 
  
;**********************                  
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf1, ibwf1
afltsigout  tone        asig2, icutoff
asigf1      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf2, ibwf2
afltsigout  tone        asig2, icutoff
asigf2      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf3, ibwf3
afltsigout  tone        asig2, icutoff
asigf3      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf4, ibwf4
afltsigout  tone        asig2, icutoff
asigf4      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf5, ibwf5
afltsigout  tone        asig2, icutoff
asigf5      =           kamp*afltsigout
;**********************

asigt       =           asigf1+asigf2+asigf3+asigf4+asigf5

;**********************
garvbsig    =           asigt*.4

            out         asigt

            endin       
;****************************************
            instr       4                       ; Bass
itab        =           22                      ; Bass table values
iattack     =           .4
irelease    =           .2
iatdec      =           .01
ifund       cpsmidi     
iamp        ampmidi     1500, 27
inh         =           sr/2/ifund              ; creates a bandlimited pulse
ifun        =           1
icutoff     =           ifund
;********************
   ;   Vibrato-    **I know this still needs work!*****
idur        =           2
kvibrate    randh       1, 1                    ;randomize rate from 4 to 6 Hz 
iv1         =           ifund*.03
iv2         =           ifund*.04
iv3         =           ifund*.05
iv4         =           ifund*.06
kvibf       linseg      0, idur/4, iv1, idur/4, iv2, idur/4, iv3, idur/4, iv4
kvib        oscil       kvibf, (kvibrate+5), 1
;********************
;Table Access 
;********************
icfreqf1    table       0, itab
icfreqf2    table       1, itab
icfreqf3    table       2, itab
icfreqf4    table       3, itab
icfreqf5    table       4, itab

ibwf1       table       5, itab
ibwf2       table       6, itab
ibwf3       table       7, itab
ibwf4       table       8, itab
ibwf5       table       9, itab

iampf1      table       10, itab
iampf2      table       11, itab
iampf3      table       12, itab
iampf4      table       13, itab
iampf5      table       14, itab

 ;print iampf1, iampf2,iampf3, iampf4, iampf5

iampf1      =           iampf1+dbamp(iamp)
iampf2      =           iampf2+dbamp(iamp)
iampf3      =           iampf3+dbamp(iamp)
iampf4      =           iampf4+dbamp(iamp)
iampf5      =           iampf5+dbamp(iamp)

 ;print iampf1, iampf2, iampf3, iampf4, iampf5

iampf1      =           ampdb(iampf1)+iamp
iampf2      =           ampdb(iampf2)+iamp
iampf3      =           ampdb(iampf3)+iamp
iampf4      =           ampdb(iampf4)+iamp
iampf5      =           ampdb(iampf5)+iamp

; print iampf1, iampf2, iampf3, iampf4, iampf5
; print icfreqf1,icfreqf2, icfreqf3, icfreqf4, icfreqf5
; print ibwf1, ibwf2, ibwf3, ibwf4, ibwf5
 
  
;**********************                  
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf1, ibwf1
afltsigout  tone        asig2, icutoff
asigf1      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf2, ibwf2
afltsigout  tone        asig2, icutoff
asigf2      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf3, ibwf3
afltsigout  tone        asig2, icutoff
asigf3      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf4, ibwf4
afltsigout  tone        asig2, icutoff
asigf4      =           kamp*afltsigout
;**********************
kamp        linenr      iampf1, iattack, irelease, iatdec
asig        buzz        1, ifund+kvib, inh, ifun
asig2       reson       asig, icfreqf5, ibwf5
afltsigout  tone        asig2, icutoff
asigf5      =           kamp*afltsigout
;**********************

asigt       =           asigf1+asigf2+asigf3+asigf4+asigf5

;**********************
garvbsig    =           asigt*.4

            out         asigt

            endin       
;********************************************



            instr       99
garvbsig    init        0
idur        =           p3
irvbtime    =           p4
asig        reverb      garvbsig, irvbtime
            out         asig
            endin       

