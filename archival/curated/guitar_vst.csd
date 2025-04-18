<CsoundSynthesizer>
<CsOptions>
directcsound -nhm0  ./temp.orc  ./temp.sco

</CsOptions>
<CsInstruments>
sr = 44100
kr = 44100
ksmps = 1

instr 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Midi controlled Acoustic Guitar
; commuted waveguide synthesis
; linear interp. for fractional delays (*biquad*) by now...
; Guitar loop filter from Tero Tolonen (*filter2*)
; Impulse response from Dr. Julius Smith 
; implemented by Josep M Comajuncosas / Aug�98-Feb�99
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; note there is no compensation yet
; for the phase delay induced by the loop filter.
; Anyway the guitar is not terribly out of tune ;-)

; Model parameters : better not touch them !
iatt1   = .996;  attenuation
ifco1   = -.058; freq dependent decay

iatt2   = .992;  attenuation
ifco2   = -.053; freq dependent decay 
ichorus = 1.002; detuning factor ~1

iamp = 8000 ;expected maximum output amplitude

; MIDI setup
ifrequency pchmidi
print 	ifrequency; displays current note being played
ifreq cpsmidi

iampn ampmidi 1;normalised amplitude
print iampn

ipluck = .5*(1.05-iampn);    pluck point (dependent on note loudness)
 
kmp linsegr 1, 10, 1, .04 ,0; add some release

kfreq cpsmidib;+ range in semitones (+-2?)

;table lookup for fine tuning up to .08*sr (about 3500Hz at sr=44100, enough for a guitar)
;kfreqn = kfreq/sr
;kfreqncorr tablei kfreqn/.08,2,1,0,0
;kfreq = kfreq*kfreqncorr

kdlt1 = 1/kfreq
kdlt2 = kdlt1/ichorus

;calculations for fractional delay interpolation filter
;delay time *in samples* (integer)
kdltn1 = int(sr*kdlt1)
kdltn2 = int(sr*kdlt2)
;remainig fractional delay *in fractions of a sample*
kdltf1 = frac(sr*kdlt1);note than time=int(time)+frac(time) ;-)
kdltf2 = frac(sr*kdlt2)

;string excitation (single impulse) convolved w.IR of the body
;= IR of the body of course...

knoise oscil1i 0, 1, ftlen(3)/sr, 3
anoise upsamp knoise

; lowpass filter the excitation signal
; at low amplitude levels
anoise butterlp anoise,iampn*iampn*sr/2; tune this at your own taste

; filtering caused by plucking point

acomb delay anoise, ipluck*ifreq
anoize = anoise - acomb

; Set waveguide 
; w. Loop filter and Fractional delay filter
; 2 parallel structures to simulate coupling of vertical & horizontal polarisations

awgout1 init 0
awgout2 init 0

ainput = anoize

imp = .5
ainput1 = ainput*imp
ainput2 = ainput*(1-imp)

atemp1 delayr 1/20
awg1 deltapn kdltn1
alpf1 filter2 awg1, 1, 1, 1+ifco1, ifco1
afdf1 biquad alpf1, 1-kdltf1, kdltf1,0,1,0,0
awgout1   = iatt1*afdf1
delayw ainput1+awgout1

igc = .01

atemp2 delayr 1/20
awg2 deltapn kdltn2
alpf2 filter2 awg2, 1, 1, 1+ifco2, ifco2
afdf2 biquad alpf2, 1-kdltf2, kdltf2,0,1,0,0
awgout2   = .97*iatt2*alpf2
delayw ainput2+igc*awgout1+awgout2

ainput2 = awgout2

imo = .5

aout = imo*awgout1 + (1-imo)*awgout2

;sound output
out iamp*iampn*kmp*aout
endin
</CsInstruments>
<CsScore>
f1 0 4096 10 1; sine wave
; tuning table calibrated from 220 Hz up to 3520 Hz (4 octaves)
;this table goes from DC to 0.08*sr only !
f2 0 8193 -27 0 1 512 1.0092 1024 1.0092 2048 1.0221 4096 1.0396 8192 1.0798
f3 0 16384 1 "guitar.wav" 0 0 0; normalized IR

;data used for this table :
;expected freq.   -> corr. factor (multiply expected freq. by this)
;220  =  0.005*sr ->  * 1.0092 (at  0.0625th of the table length):point 512
;440  =  0.01*sr  ->  * 1.0092 (id. at  0.125):point 1024
;880  =  0.02*sr  ->  * 1.0221 (id. at  0.25):point 2048
;1760 =  0.04*sr  ->  * 1.0396 (id. at 0.5):point 4096
;3520 =  0.08*sr  ->  * 1.0798 (id. at 1):point 8192

f0 100; listen to incoming MIDI events for 100 sec.


e



</CsScore>
<CsArrangement>
</CsArrangement>
<CsMidifile>
<Size>
3488
</Size>
MThd      �MTrk  � �untitled �GM Device  1
 �X �Y   �Q�% �d 
 C� @�2RS� P@Z!P_Edj5opUp#%p#Eoeo uo+p-uo5ouo�2 �5p&Up @�@c��0B- @SEAB# @_B( @]ZA @WpA( @?�@ �0ABn @�>[�4> ]@k�9�pD0EJE
F5F�@ (� @�>\��K9EK7�> � @�<Nx�v;F<V;*;;+;{:�< � @�<XW� A( @��< >R#�&5:0Z�> 
� @
�<j��BC`C0jB @�
BEB2PA @-�< !�AB7 @ZZB @!�9779 /9k�z9 C;a��UEEUEeEFUEEE2UE25E&�; � @�<`��`A: @R5B%B  @dB( @S A2 @auA( @]@A0A @R@A�< 7� @�<&> @�C�1D5� :2 @�1  /j�./  0G�0 3^P� EP @�3 6ON6  7m��@KL @0�7 6Ud6 7T7 
9:b�*C**G K�T�9 � E�;-K� @� A( @KApA+ @_@A0A @RA�; �PA! @\PA+ @�'�/H_/ 4`W� K]�4 � @�7AX7 7gd�jJ@J!PJ�7 
� @�;CX; 4<b�< 2;<�n; <:�%< A9L�Z�
KjJ
KzJjJ @�9  ;D�<js; � ;5#< � 5D @�;  7877 6_�� EZ�6 �w� 5�9F� � @�J�;Yz9 �	; 29:�Z9 ;:�; _7>�Y7 9]�9 �c9\N�25C�9 � @�6I26 4PN� KH�4 
� @�7E/7 9i�975U7 �67S6 9 n7S�J9R�7 29  6C�Z6 74�M7 4>�Y4 6?�0[]6 �`�PA7 @�9�0 2cM2 4KZ� K9�4 � @�7[W�`JK-�7 � @�;V7; *<p�6< �];E*@L(; ;ml; <Fl>OW@ @JD< <OP@  � E�> � KZ @�@Q< k@ @Fi;XU@ �UE&F#�; � @�9Sv�K:KK*KjJ�9 � @�<b�O�ABEB5BuA @}5B*CpC`CB @�< d�B
C`C#PC@CuA @dA5BCpC`C#@CjB @�uAZB55B @bAPA%@A- @�E�9E*@L(9 9ml9 ;Fi; ;OW@ @JX7OP@  � E�; � KZ @�;Q7 n@Fi6X; I@ �UE& E#�6 � @�4Sv�J:JK*K�4  � @�7i�j�; 6[0# +f%K !#�7 � @2�/Pp/ !0b�)0 C/T�H/ 0NH�A;;P @Xf;< @Z;< A @S;;W @�.R0 ��BpBK @�B@B: @�AeA4 @�ZA2 @a�. !.G(. -`�- �+I�p� K�4 @x K_ @K K9 @2 K: @> K7 @5 K9 @&�+ *I�* /E(/ 9/:0/ /k�8�UE�_�/  � @�3>�3 73]q�EE7UE4�3  � @�6EZ6 6XF�UEW @�6 9EA9 9_U� KP @�9  =Di= ?o�dE:�;.i@.5? ; :@ E  @PnE@x;.!E @ F?Ei;  E7{;.<? /=AUE &E3F= /; ;3<E /?B_? E12E ; 9=GnC;� ;4n@2#= ; G'<>@MC C/IG 7;2> b=BCC -C;D; -;24@ = -@?P@  ; ;2R; =?KC C;_= C 
;2n7?P7 -6Op7?{@;>6 ; &4SH7 @ 7?u@;� 2VK4 
7 @ 7?};;>7 ?1\F2 ; 4?z;;&4 P4OR1 ; :?54 >1cs4?-: F78s/g7 1 A4 4NK4 !7F}.m#7 / ?4?P4 -7TA. /�@�4bU7 �@K} @
�:O4 P: 9\x� 5Z�9 6f � @z Eg�6 4L� @s65v @�1cK4 -4F{79}0i44 
1 54KP7 *7Fv/n<4 0 
7 %4V{7Q94 / -.u_7 4`A4 . #7Zg7 4Fs�uE*K5K:K @�4  :UF: 29HH9 27AU7 &6<n6 79K7 045P4 #22R2 !1<}7Fz:P?7 1 7Zl: �uE*K5K:K @�7  =ZF= 2<_x�65H�< 2� @�9in�REx�9  � @
�7nn� 5Z�7 � @�,�9V�ZDPE @��:n9 ]�I0P�: %� @�9Ff9 :hX: #;_C; 7=B<= :>6<> 9@U<@ 7Ani�%DZJjO%%UI5UA%U5UU%U!U
U!5U@U5Uf%U
U�A � @��CXaC !EUi�0D/E�E 2� @�CXv�J %J+�C /� @�ANk�0;7;K:(�A 
� @�CO�1�:A! @9UAEB @�-%A @:>�C � @�C�@aC�0E2 @g�@ >B<> 2=W}�5F 5�= �5 @�>an�[:Z�>  �k: @�@hf�A{505/[:EeJPO:OPO0EOPO2`OP Q
Q5P*O&jOJQ5uOjOZP*PO @�@ �/_%�{:;F;5p45�/ � @ �.BU. (+@N+ --BW- .Di. 
1Q_1 2@z�
KU�2 � @�5^�\� A*B eA @s*BeA @UeA2 @Z A! @i
A @H�5 �C_�IA9C -I EdxI5WE I A;uI7NA I CY}IO<I C !>bxI@UI > @[xIJ@ I NAj�j� AF @q AzA2 @�zA*B2PA @_zA> @#�A 7� A:A @� �@XzF]v>U4@ F 4E^2> D=]WE #Ca0= F:dAC 9Amd: 9`UA %@e29 D7V4@ �7 05V��zA@B*B @I
A@B#zA @H�5 �:A( @�c�A]MA >HA> AjR�&0I�A � @�98S9 >hA�@%P�>  � @�5HP5 9T(� ;t+N @�9 2JU2 5dI�%0R�5 � @�-I�0- �+=j9�2P? @�Cc4=  �2P0 @�C G{�e�pA`A @U0B0 @F�G Ff��H:�  @�F  DY]�2:R�D  � @�B\RB A<HA @9M@ ?dK�?:M�?  � @�=QA= <hI�O:C5A @�< 9CA9 8dC8 7:>7 6l<�(:A�6  � @�4C<�:< @�4 2T?2 1:7� :: 54 @�1 .^M. -w�e� E�Y @� Es @Z EF @< EF @K ED @> EF @�0�- �p/3�^� K�m @�  K�  @a KN @A KM @S KK @C KN @�  5��/  �/ </CsMidifile>
</CsoundSynthesizer>
