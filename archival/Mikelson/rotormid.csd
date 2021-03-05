<CsoundSynthesizer>
<CsOptions>
csound -RWm7o ./rotormid.wav -F temp.mid ./temp.orc ./temp.sco
</CsOptions>
<CsInstruments>
;------------------------------------------------------------------------
; Tone Wheel Organ with Rotating Speaker
;------------------------------------------------------------------------

sr     = 44100
kr     = 44100
ksmps  = 1
nchnls = 2

;------------------------------------------------------------------------
; Global Rotor Speed/Drawbar Initialization
;------------------------------------------------------------------------

           instr 1
gispeedf   init p4
gksubfund  init p5
gksub3rd   init p6
gkfund     init p7
gk2nd      init p8
gk3rd      init p9
gk4th      init p10
gk5th      init p11
gk6th      init p12
gk8th      init p13
giclick    init p14
giperc2    init p15
giperc3    init p16

; Central Shaft
gkphase  oscili 1, 1, 7

         endin
        
;------------------------------------------------------------------------
; This instrument acts as the foot switch controlling rotor speeds.
;------------------------------------------------------------------------
         instr 2

gispeedi init   gispeedf    ;Save old speed
gispeedf init   p4          ;update new speed

gkenv    linseg gispeedi*.8,1,gispeedf*.8,.01,gispeedf*.8 ;High freq. rotor acceleration
gkenvlow linseg gispeedi*.7,2,gispeedf*.7,.01,gispeedf*.7 ;Low freq. rotor acceleration

         endin

;------------------------------------------------------------------------
; Tone Wheel Organ
;------------------------------------------------------------------------
         instr 3

  inn  notnum
  iamp veloc
  iamp = (iamp = 0 ? 0 : 100)
  ipch = int(inn/12)+frac(inn/12)*12/100+3

gaorgan  init  0                       ;Global send to speaker
ikey     init  12*int(ipch-6)+100*(ipch-6) ;Keyboard key pressed.
ifqc     init  cpspch(ipch)              ;Convert to cycles/sec.
iwheel1  init  ((ikey-12) > 12 ? 1:2)  ;The lower 12 tone wheels have
iwheel2  init  ((ikey+7)  > 12 ? 1:2)  ;increased odd harmonic content.
iwheel3  init  (ikey      > 12 ? 1:2)
iwheel4  init  1                       
  
;------------------------------------------------------------------------
kamp linenr iamp, .01, .01, .01

; Percussion
kpercenv linseg 0, .01, 8, .2, 0, .01, 0
gk2nd = (giperc2 = 1 ? kpercenv : gk2nd)   ; If percussion is on envelope the second.
gk3rd = (giperc3 = 1 ? kpercenv : gk3rd)   ; If percussion is on envelope the third.

;------------------------------------------------------------------------
asubfund oscili  gksubfund, .5*ifqc,      iwheel1, i(gkphase)/(ikey-12)  ;The organ tone is
asub3rd  oscili  gksub3rd,  1.4983*ifqc,  iwheel2, i(gkphase)/(ikey+7)   ;made from adding
afund    oscili  gkfund,    ifqc,         iwheel3, i(gkphase)/ikey       ;the weighted output
a2nd     oscili  gk2nd,     2*ifqc,       iwheel4, i(gkphase)/(ikey+12)  ;of 9 equal temperament
a3rd     oscili  gk3rd,     2.9966*ifqc,  iwheel4, i(gkphase)/(ikey+19)  ;tone wheels.
a4th     oscili  gk4th,     4*ifqc,       iwheel4, i(gkphase)/(ikey+24)
a5th     oscili  gk5th,     5.0397*ifqc,  iwheel4, i(gkphase)/(ikey+28)
a6th     oscili  gk6th,     5.9932*ifqc,  iwheel4, i(gkphase)/(ikey+31)
a8th     oscili  gk8th,     8*ifqc,       iwheel4, i(gkphase)/(ikey+36)

; Key Click
kclickenv linseg 0, .005, giclick, .01, 0, .01, 0
anoise   rand   kclickenv
aclick   tone   anoise, 10000

gaorgan  =      gaorgan+kamp*(asubfund+asub3rd+afund+a2nd+a3rd+a4th+a5th+a6th+a8th+aclick)

         endin

;------------------------------------------------------------------------
;Rotating Speaker
;------------------------------------------------------------------------
         instr  4

ioff     init   p4
isep     init   p5             ;Phase separation between right and left
iradius  init   .00025         ;Radius of the rotating horn.
iradlow  init   .00035         ;Radius of the rotating scoop.
ideleng  init   .02            ;Length of delay line.

;------------------------------------------------------------------------
asig     =      gaorgan        ;Global input from organ

;------------------------------------------------------------------------
asig     =      asig/40000     ;Distortion effect using waveshaping.
aclip    tablei asig,5,1,.5    ;A lazy "S" curve, use table 6 for increased
aclip    =      aclip*16000    ;distortion.

;------------------------------------------------------------------------
aleslie delayr  ideleng,1      ;Put "clipped" signal into a delay line.
        delayw  aclip

;------------------------------------------------------------------------
koscl   oscili   1,gkenv,1,ioff            ;Doppler effect is the result
koscr   oscili   1,gkenv,1,ioff+isep       ;of delay taps oscillating
kdopl   =       ideleng/2-koscl*iradius   ;through the delay line.  Left
kdopr   =       ideleng/2-koscr*iradius   ;and right are slightly out of phase
aleft   deltapi kdopl                     ;to simulate separation between ears
aright  deltapi kdopr                     ;or microphones

;------------------------------------------------------------------------
koscllow  oscili   1,gkenvlow,1,ioff           ;Doppler effect for the
koscrlow  oscili   1,gkenvlow,1,ioff+isep      ;lower frequencies.
kdopllow  =       ideleng/2-koscllow*iradlow
kdoprlow  =       ideleng/2-koscrlow*iradlow
aleftlow  deltapi kdopllow
arightlow deltapi kdoprlow

;------------------------------------------------------------------------
alfhi     butterbp aleft,5000,4000     ;Divide the frequency into three
arfhi     butterbp aright,5000,4000    ;groups and modulate each with a
alfmid    butterbp aleft,2000,1500     ;different width pulse to account
arfmid    butterbp aright,2000,1500    ;for different  dispersion
alflow    butterlp aleftlow,500        ;of different frequencies.
arflow    butterlp arightlow,500

kflohi    oscili    1,gkenv,3,ioff
kfrohi    oscili    1,gkenv,3,ioff+isep
kflomid   oscili    1,gkenv,4,ioff
kfromid   oscili    1,gkenv,4,ioff+isep
  
;------------------------------------------------------------------------
; Amplitude Effect on Lower Speaker
kalosc    = koscllow*.4+1
karosc    = koscrlow*.4+1

; Add all frequency ranges and output the result.
outs alfhi*kflohi+2*alfmid*kflomid+alflow*kalosc, arfhi*kfrohi+2*arfmid*kfromid+arflow*karosc

endin

;------------------------------------------------------------------------
;Rotating Speaker without Deflectors
;------------------------------------------------------------------------
         instr  5

ioff     init   p4
isep     init   p5             ;Phase separation between right and left
iradius  init   .00025         ;Radius of the rotating horn.
iradlow  init   .00035         ;Radius of the rotating scoop.
ideleng  init   .02            ;Length of delay line.

;------------------------------------------------------------------------
asig     =      gaorgan        ;Global input from organ

;------------------------------------------------------------------------
asig     =      asig/40000     ;Distortion effect using waveshaping.
aclip    tablei asig,5,1,.5    ;A lazy "S" curve, use table 6 for increased
aclip    =      aclip*16000    ;distortion.

;------------------------------------------------------------------------
aleslie delayr  ideleng,1      ;Put "clipped" signal into a delay line.
        delayw  aclip

;------------------------------------------------------------------------
koscl   oscili   1,gkenv,1,ioff            ;Doppler effect is the result
koscr   oscili   1,gkenv,1,ioff+isep       ;of delay taps oscillating
kdopl   =       ideleng/2-koscl*iradius   ;through the delay line.  Left
kdopr   =       ideleng/2-koscr*iradius   ;and right are slightly out of phase
aleft   deltapi kdopl                     ;to simulate separation between ears
aright  deltapi kdopr                     ;or microphones

;------------------------------------------------------------------------
koscllow  oscili   1,gkenvlow,1,ioff           ;Doppler effect for the
koscrlow  oscili   1,gkenvlow,1,ioff+isep      ;lower frequencies.
kdopllow  =       ideleng/2-koscllow*iradlow
kdoprlow  =       ideleng/2-koscrlow*iradlow
aleftlow  deltapi kdopllow
arightlow deltapi kdoprlow

;------------------------------------------------------------------------
alfhi     butterbp aleft,5000,4000     ;Divide the frequency into three
arfhi     butterbp aright,5000,4000    ;groups and modulate each with a
alfmid    butterbp aleft,2000,1500     ;different width pulse to account
arfmid    butterbp aright,2000,1500    ;for different  dispersion
alflow    butterlp aleftlow,500        ;of different frequencies.
arflow    butterlp arightlow,500

; Note Tables 13 & 14 are for no deflectors.
kflohi    oscili    1,gkenv,13,ioff
kfrohi    oscili    1,gkenv,13,ioff+isep
kflomid   oscili    1,gkenv,14,ioff
kfromid   oscili    1,gkenv,14,ioff+isep
  
;------------------------------------------------------------------------
; Amplitude Effect on Lower Speaker
kalosc    = koscllow*.4+1
karosc    = koscrlow*.4+1

; Add all frequency ranges and output the result.
outs alfhi*kflohi+2*alfmid*kflomid+alflow*kalosc, arfhi*kfrohi+2*arfmid*kfromid+arflow*karosc

endin

;------------------------------------------------------------------------
;Rotating Speaker
;------------------------------------------------------------------------
         instr  6

ioff     init   p4
isep     init   p5             ;Phase separation between right and left
iradius  init   .00025         ;Radius of the rotating horn.
iradlow  init   .00035         ;Radius of the rotating scoop.
ideleng  init   .02            ;Length of delay line.

;------------------------------------------------------------------------
asig     =      gaorgan        ;Global input from organ

;------------------------------------------------------------------------
asig     =      asig/40000     ;Distortion effect using waveshaping.
aclip    tablei asig,5,1,.5    ;A lazy "S" curve, use table 6 for increased
aclip    =      aclip*16000    ;distortion.

;------------------------------------------------------------------------
aleslie delayr  ideleng,1      ;Put "clipped" signal into a delay line.
        delayw  aclip

;------------------------------------------------------------------------
koscl   oscili   1,gkenv,1,ioff            ;Doppler effect is the result
koscr   oscili   1,gkenv,1,ioff+isep       ;of delay taps oscillating
kdopl   =       ideleng/2-koscl*iradius   ;through the delay line.  Left
kdopr   =       ideleng/2-koscr*iradius   ;and right are slightly out of phase
aleft   deltapi kdopl                     ;to simulate separation between ears
aright  deltapi kdopr                     ;or microphones

;------------------------------------------------------------------------
koscllow  oscili   1,gkenvlow,1,ioff           ;Doppler effect for the
koscrlow  oscili   1,gkenvlow,1,ioff+isep      ;lower frequencies.
kdopllow  =       ideleng/2-koscllow*iradlow
kdoprlow  =       ideleng/2-koscrlow*iradlow
aleftlow  deltapi kdopllow
arightlow deltapi kdoprlow

;------------------------------------------------------------------------
alfhi     butterbp aleft,5000,4000     ;Divide the frequency into three
arfhi     butterbp aright,5000,4000    ;groups and modulate each with a
alfmid    butterbp aleft,2000,1500     ;different width pulse to account
arfmid    butterbp aright,2000,1500    ;for different  dispersion
alflow    butterlp aleftlow,500        ;of different frequencies.
arflow    butterlp arightlow,500

kflohi    oscili    1,gkenv,3,ioff
kfrohi    oscili    1,gkenv,3,ioff+isep
kflomid   oscili    1,gkenv,4,ioff
kfromid   oscili    1,gkenv,4,ioff+isep
  
;------------------------------------------------------------------------
; Amplitude Effect on Lower Speaker
kalosc    = koscllow*.4+1
karosc    = koscrlow*.4+1

; Add all frequency ranges and output the result.
outs alfhi*kflohi+2*alfmid*kflomid+alflow*kalosc, arfhi*kfrohi+2*arfmid*kfromid+arflow*karosc

gaorgan = 0

endin
</CsInstruments>
<CsScore>
;-------------------------------------------------------------------
; Tone Wheel Organ with Rotating Speaker rev. 4
; by Hans Mikelson
;-------------------------------------------------------------------
; GEN functions
;-------------------------------------------------------------------
f0  50         ; Continue running for midi data input.

; Sine
f1  0   16384  10   1 .02 .01
f2  0   16384  10   1 0 .2 0 .1 0 .05 0 .02

; Rotating Speaker Filter Envelopes
; Deflectors Removed
f13   0    1024   8  .2    440 .4 72 1 72 .4  440 .2
f14   0    1024   8  .4    320 .6 64 1 256 1   64  .6 320 .4
; With Deflectors
f3   0    1024   8  .95 24 .85 24 1 24 .85 24 1 24 .85 248 .9  72 .8 72 1 72 .8  72 .9 248 .85 24 1 24 .85 24 1 24 .85 24 .95
f4   0    1024   8  .95 48 .85 96 .75 240 .8 64 1 128 1 64 .8 240 .75 96 .85 48 .95

; Distortion Tables
; Slight Distortion
f5 0 8192   8 -.8 336 -.78  800 -.7 5920 .7  800 .78 336 .8
; Heavy Distortion
;f5 4 8192   8 -.8 336 -.76 3000 -.7 1520 .7 3000 .76 336 .8

; Central Shaft Table
f7 0 256    7  0  256  1

; Score
;-------------------------------------------------------------------
;  Tone Wheel Organ
; Initializes global variables and drawbars.
;       Speed SubFund Sub3rd Fund 2nd 3rd 4th 5th 6th 8th  KeyClick(0-70)  2ndPerc  3rdPerc
i1 0  1 1      8       8     8    0   0   0   0   0   0    0               0        0
i1 18 1 1      6       8     8    6   0   0   0   0   0    1               1        0
i1 32 1 1      8       8     5    3   2   4   5   8   8    10              0        0

; Rotating Speaker start/stop
;ins  sta  dur  speed
i2    0    2     1
i2    +    2     10
i2    .    4     1
i2    .    2     10
i2    .    2     1
i2    .    4     10
i2    .    2     1
i2    .    2     10
i2    .    2     1
i2    .    4     10
i2    .    2     1
i2    .    2     10
i2    .    2     1
i2    .    4     10
i2    .    2     1
i2    .    2     10
i2    .    2     1
i2    .    4     10
i2    .    2     1
i2    .    2     10
i2    .    2     1
i2    .    4     10

; Rotor Organ Instrument 3 is controlled by MIDI

;   3 Different Rotating Speakers (i6 must be used or it won't reset the organ)
;   Start  Dur   Offset  Sep
i4    0    50.2  .5     .1
i5    0    50.2  .2     .12
i6    0    50.2  .6     .095


;Popular Settings (from the Hammond Leslie FAQ)
;      Gospel:               88 8000 008
;      Blues:                88 5324 588
;      Rod Argent (Argent)   88 0000 000
;      Brian Auger:          88 8110 000 2nd Percussion, C3 Vibrato
;      Tom Coster (Santana)  88 8800 000
;      Jesse Crawford        80 0800 000      Setting (theatre organ sound)
;      ELP (Keith Emerson)   88 8000 000
;                            88 8400 080
;      Joey De Francesco     83 8000 000 C3 Vibrato
;      Booker T Jones:       88 8800 000 (1st chorus)
;      (Green Onions)        80 8800 008 (2nd chorus) 2nd Percussion
;      Jon Lord:             88 8000 000 2nd Percussion
;      Matthew Fisher        68 8600 000 2nd Percussion, soft Percussion, short decay (A Whiter Shade of Pale)
;      Jimmy Smith:          88 8000 000 3rd Percussion, C3 Vibrato
;                            84 8848 448
;      Steve Winwood:        88 8888 888
;                            80 0008 888 J.Smith can be heard playing this Errol Garner style registration on Crazy Baby, "Mack the Knife", "Makin' Whoppee".

;------------------------------------------------------
;Hammond Presets ( I messed some of these up a bit so if you have corrections let me know.)
;                                 Standard Voices
;                 Upper Manual                       Lower Manual
;       Key Registration       Name        Key  Registration      
;Name
;       C   -- ---- ---    Cancel          C    -- ---- ---  Cancel
;       C#  00 5320 000    Stopped Flute   C#   00 4545 440  Cello
;       D   00 4432 000    Dulciana        D    00 4432 220  Flute & String
;       D#  00 8740 000    French Horn     D#   00 7373 430  Clarinet
;       E   00 4544 222    Salicional      E    00 4544 222  Salicional
;       F   00 5403 000    Flutes 8' &  Great, no 4' F    00 6644 322 reeds
;       F#  00 4675 300    Oboe Horn       F#   00 5642 200  Open Diaposon
;       G   00 5644 320    Swell           G    00 6845 433  Full Great Diapason
;       G#  00 6876 540    Trumpet         G#   00 8030 000  Tibia Clausa
;       A   32 7645 222    Full Swell      A    42 7866 244  Full Great with 16'
;       A#  1st Group Drawbars Upper       A#   1st Group Drawbars Lower
;       B   2nd Group Drawbars Upper       B    2nd Group Drawbars Lower
;
;                                Theatrical Voices
;               Upper Manual                        Lower Manual
;       Key Registration       Name        Key  Registration      Name
;       C   -- ---- ---    Cancel          C    -- ---- ---  Cancel
;       C#  00 8740 000    French Horn 8'  C#  00 4545 440  Cello 8'
;       D   00 4432 000  Dulciana 8'       D   00 8408 004  Tibias 8' & 2'
;       D#  00 4800 000  Vibraharp 8'      D#  00 8080 840    Clarinet 8'
;       E   00 3800 460                    E   08 8800 880    Novel Solo 8'
;       F   60 8088 000    Theatre Solo 8' F   00 6554 322 Accomp. 16'
;       F#  00 4685 300    Oboe Horn 8'    F#  00 5642 200 Openm Diaposon 8'
;       G   60 8807 006    Full Tibias 16' G   43 5434 334 Full Accomp. 16'                                                                          16'
;       G#  00 6888 654    Trumpet 8'      G#  00 8030 000 Tibia 8'
;       A   76 8878 667    Full Theatre    A   84 7767 666  Bombarde 16' Brass 16'
;       A#  1st Group Drawbars Upper       A#  1st Group Drawbars Lower
;       B   2nd Group Drawbars Upper       B   2nd Group Drawbars Lower


</CsScore>
<CsMidifile>
<Size>
4904
</Size>
MThd       xMTrk   ˇY   ˇT`     ~	˜ Å%  da*PT3Q5 p?q	xw
~Opo<; !`?h8TJ@<%0p1 y
$cs;b ~s}FG_D|g3 /xOw)^}UpO)}!#`?^ywcB@<	po/1 y bqOLb ~s9GcE|gG?2
xOdp˜ É   dN$	6,A#F9@6lc0l@?
0SAe86 @1c0 @1c  @1c dF Fqx @^0t%HG         r FPXFs: 	06lX1FaX1 `8
&7=0Jpl
  cFa
  cFA  cFH+ cq1 2<& =	`hK8          6d  0Vfu `lX1cC1c ~)@-DLnza?	  FC  F  FV Fcc dxLt@q1#         lH @qa
l2Lk1  [1cF=cF|S ; h'	tiQk(  l#+  2   6,0GG<0ZP"c W( K4         X˜ É   f"+%c`	1 *A)#F@ 6lc0l@?JkOQr `  F@1@  4r  @1c  @1c dF Fqx #S1@qT	 6 0G     HNNNNN` jTcE+: 6lX1FaXP W#	d@1 0  c   hpA  cFA  c<H+ cq1 F&c c)3@l a     A!(vFt r9lX1cC1c ~).?FHCd `  F  P!
 F  FV Fcc X6FFSf$ Y1 B1      :::::CS
l2i1 dsX1cFcF|S\~%H@1 0 .   k (2   6,0GG0e'MI 2c  c8     @ttttt˜ É   D+'_$c(Ba #F@F6lX1;l@?J @n" `5W F@1P @1dx@1c  @4c    Fqx Y1@1 6' 0G 
#(-r  0jkE3< 6lX1cvX1 3  ]E @1j.  c   cHq  cF  hF  ( cq1 2c
 c8<@lN ` 
(2<FPZdA !pX6fx >lX1c*n1c ~)f  : cT]"E  FA  Fc@ F  
P  P Fcc dT   px Y@1 (<Pdx!5IAAhl2Lq1 4lX1cF[cF|SL t F);E 0 -  #F/       0GGH+ cq1 2; c8 (Px IqBj˜ É   V%3 f/@`xCM#F%FF6lc;l@?Yqo |A F@1r @Jm@ @1c@ @1c dF Fax @1|@
0 
G 
#(-r AqKpEK:6lX1FwX1 2!b_Ax7=  cd  [  cF  cF@   Cq1 2 c4, `  
(2<FPZd"`  VU8lX1cxA1c ~eBXD?qoz  FI  6
  F
  F P cc <
$1q* G( (<Pdx!5ID   L2,*,pX1cFqcF|K1Z_	t% 0 /  <l    p 0FG,xHbb1T P8 (Px IqBj˜ É   f%% @H0,A=*F9%  6lc;l@? 0gRe\!&=)>90 @;w0 @1c  @1c B  Fax@o!+@1<,+0LG    @G Z ahX;Ws, 6lX1FwX1  `N%!J9=B:L zR|r`
  wna
  cFA  cF( C_1 _CV c*x XV"a     ((((b0+fuX  0lX1co1c ~@KBszuAt%ycA  n]C  F  FV cc >-FUp]@0-EB1     >PPPPc
,[2Lk1 `X1cF^cF| ;%)fu!j1iKrK+  \;+  2   6,0FG|Z+a;aZ
 c<     <| !!!˜ É   V%3 F2`y @#F@ 6lc0l@?
  c `  F@1p @;cp @1cp @1c dF Fqx Y1@1&&6,0G 
#(-r@s3< @F3< 6lX1FaX1   F@1 0  c`  wFa  cFa  cFH+ cq1 2c
 c8<,KlX` 
(2<FPZd"`x  6fx 8lX1cC1c ~) 0  c `  FA  nC  FC  FV Fcc dF Fqx Y1@1 (<Pdx!5ID@q l2Lq1 pX1cFcF|S `  F@1 0 /  \/  /   6,0GGH+ cq1 2c
 c8 (Px IqBj˜ É   V%3 f/%@pxCM#F%  6lc;l@?Yqo |A F@1r @Jm@ @1c@ @1c dF Fax  @1@
0 
G 
#(-r aqKpEK:  6lX1FwX1 2!b_Ax7=  cd  [  cF  cF@   Cq1 "  c8< `  
(2<FPZd"`  VU8lX1cxA1c ~eBXD?qoz  FI  6
  F
  F P cc <
$1q* G( (<Pdx!5ID   L2,*,pX1cFqcF|K1Z_	t% 0 /  <l    p 0FG,xHbb1T P8 (Px IqBj˜ R             	 FF0R@P0 =yF!10`vsxS&w f
 4
  l -HY%  69/   ˜   ˜ ˇQf¸ ˇX íPN:P QIQ  PNNXP :KNN ,K I\HI I]J]I K^J !K N^8N I_J_I J I`I G`'D`G !Ga KaD 6DbG  K D  BcB  ?d<?  =g?= ;i(; 
Dk<P|&P D Z| N| U| Bo<Z  N  U  P| ?qB  P W| S| =s? 6W  S  P|8= ?wP .P| By?  P W| R| ?{B 6W  R  N| =|? N W| P| ;|= *W  P K| W| 8|; 66|8 06 6|<8|6 94|8 K W 3|4 6R| ?|3 4R P| D|? 7P K| I|D 9K  P| G|I 6P  N| B|G 4N I| =|B 7I K| D|= 9K  L| G|D 6L  N| E|G )N P| D|E 2P Q| B|D 4Q  S| @|B 1S  X| ?|@ /X W| =|? 2W S| ;|= 4S  U| :|; U U| ?|: U \| =|? 98|= 9=|8 /:|= &\ U| 6|: U U| 8|6 !U \| 3|8 73  3|3 &6|<\  U| 1|6 U U| 8|1 U U| 5|8 U \| 1|5 )3|1 )4|3 $\ \| 6|4 $\ Z| 8|6 'Z W| :|8 )W  X| ;|: &X  U| @|; $U S| ?|@ 'S Q| ;|? 'Q I| U| L|; )I  L  N|N  G| W| N|U 2G N  P|P  W  E| X| P|<E  P  Q|Q X D| Y| Q|:D Q  S|S (Y ÉE0 J. N.;ˇQ(mÅíE G1ÅWG 91N 7J  S.S O.9 	O @1 G. N.N L.L J.J I.I J.@  G 	J @1 E. I.kI G.G E.PE (@  E ˇQ° ÅíScLU VV“9a'|uk^QF?71( 
 Ü]íV L S LJQbUVIQ U L 
VbS`L0“ íV S L L:Qe Uj8Q U L LR PlSiÑnP O=S M;L L>O JEM HML GYJ EbH CeG AgE @jC >lA <l@ ;p> 9r< 7r; 5p9 4r7 2p5 0p4 /r2 -t0 +n/ )l- (j+ &j) $g( #e& !`$ ># 
!  ÅLN RQSiR ÅL S LHQiVO^Q Å,O L BLSR[NSrR JQ]S 6L Q L`Oj“ XíL )JMO PK[J 
K  Lj?JEL -J KXLnK 9L aLgRjSjR nL S "LbQlNOcQ Å)L  O 4L[ReOStR <S Qb1Q L  LgOnÇzO L Å@QFVGpF ÅG E[NCXE V4b“17'íC @  “ $í4 S@JFS]F  GjFE[G CE C`Å:2cC @ ;2 4nH4 2`B2 4jÅ@?FU4 GcF ÅG EeSC[E N4nC @ Å4 @OFiXF  Gn;G EiE @ 5@gCp“
 Çi í@ C  ˇ/ </CsMidifile>
</CsoundSynthesizer>
