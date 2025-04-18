 
noise6.orc  �
��  8"��J  J�� `�
�t�ň�`   � ֎TEXTR*ch ����      �  ҳ�W̴"                       ��[3  ;Casti, John L. "Complexification: Explaining a Paradoxical 
;World Through The Science Of Surprise",
;New York, HarperCollins, 1994.
;from "White, Brown and Pink Music" pp. 245-249 "A fractal process, on the other ;hand, has no characteristic frequency or scale, and its frequencies form what's ;called an inverse power spectrum."

;Here is an instrument utilizing tables that offer a variety of percussive 1/f ;accompaniment to Casti's "White Music." Casti's notated score is on page 247 of ;'Complexification.'

;ORKIE
sr        =         44100
kr        =         4410
ksmps     =         10
nchnls    =         2

          instr 1

i1        =         p4/2

k1        phasor    .9
k2        phasor    1.33
i2        table     p5,3
kp1       table     k1*6,4
kp2       table     k2*6,5
ip3       table     p6,6
ip4       table     p7,7
ip5       table     p8,8
ksweep    line      ip4,p3,ip5
kvib      oscil     2.75,cpspch(p4),1
kamp      linen     ampdb(i2),p3*.1,p3,p3*.9
asing1    oscil     kamp/4,cpspch(p4),2
asing2    oscil     kamp/4,cpspch(p4)+kvib,1
abari     oscil     kamp/4,cpspch(kp1)+kvib,1
abass     oscil     kamp/4,cpspch(kp2),2
a1        =         asing1+abari+asing2+abass
asig      rand      10000
afilt     reson     asig,ksweep,ip3
arampsig =          .05*afilt
afin      balance   arampsig,a1
          outs      a1+afin,a1+afin
          endin

                                                                                                                              �  �   F��`�� ^HAUAf0/ �Pd p 0( Nr
noise6.orcderlanger 98foforingX TEXTR*ch  n �                  �(�~  v  � / N� < Nu"/  / H� * jD�,jD�N� J�jD���jD�L� `Nu"/  / H�8 $HBJBf6 B@H@g��4 HB0��4 "B@H@`"$ B@H@HBBB&r xԂрҁ�  <R*ch ( "x              	  Monaco                                                              H H    �(�����FG(�    H H    �(    d     � '                �     @                     "    Monaco�                                                                                                                                                                                                                                                         	   	HelveticaM                                                                                                                                                                                                                                                    Confidential	H                                                                                                                                                                                                                                                         �   �   �   �                                               H           H 	Monaco ��BR�LRVR��4R�,    - 	N ( �@�@:�                 �  �   FR��7�    F BBSR   MPSR   ��        ���  @R��                                              