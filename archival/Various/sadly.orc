 	sadly.orc  �
��  8"��J  J�� `�
�t�ň�_�   � ֍TEXTR*ch ����      �  ҳ�e{�"                       ��ZY  sr        =         44100
kr        =         4410
ksmps     =         10
nchnls    =         1


          instr     1
;p4=AMP
;p5=FREQ
;p6=ATTACK TIME
;p7=RELEASE TIME
k1        linen     p4, p6, p3, p7
a1        oscil     k1, p5, 1
          out       a1
          endin


          instr     2
iamp      =         ampdb(p4)
iscale    =         iamp*.333
inote     =         cpspch(p5)
k1        linen     iscale, p6, p3, p7
a3        oscil     k1, inote*.996, 1
a2        oscil     k1, inote*1.004, 1
a1        oscil     k1, inote, 1
a1        =         a1 + a2 + a3
          out       a1
          endin

          instr     3
irel      =         .01
idel1     =         p3 - (p10 * p3)
isus      =         p3 - (idel1 - irel)
iamp      =         ampdb(p4)
iscale    =         iamp * .333
inote     =         cpspch(p5)
k3        linseg    0, idel1, p9, isus, p9, irel, 0
k2        oscil     k3, p8, 1
k1        linen     iscale, p6, p3, p7
a3        oscil     k1, inote*.995+k2, 1
a2        oscil     k1, inote*1.005+k2, 1
a1        oscil     k1, inote+2, 1
          out       a1 + a2 + a3
          endin

          instr     4
ifunc     =         p11
irel      =         .01
idel1     =         p3 - (p10 * p3)
isus      =         p3 - (idel1 - irel)
iamp      =         ampdb(p4)
iscale    =         iamp * .333
inote     =         cpspch(p5)
k3        linseg    0, idel1, p9, isus, p9, irel, 0
k2        oscil     k3, p8, 1
k1        linen     iscale, p6, p3, p7
a3        oscil     k1, inote*.999+k2, ifunc
a2        oscil     k1, inote*1.001+k2, ifunc
a1        oscil     k1, inote+k2, ifunc
          out       a1 + a2 + a3
          endin

          instr     5
ifunc1    =         p11
ifunc2    =         p12
ifad1     =         p3 - (p13*p3)
ifad2     =         p3 - ifad1
irel      =         .01
idel1     =         p3 - (p10*p3)
isus      =         p3 - (idel1-irel)
iamp      =         ampdb(p4)
iscale    =         iamp * .166
inote     =         cpspch(p5)
k3        linseg    0, idel1, p9, isus, p9, irel, 0
k2        oscil     k3, p8, 1
k1        linen     iscale, p6, p3, p7
a6        oscil     k1, inote * .998+k2, ifunc2
a5        oscil     k1, inote*1.002+k2, ifunc2
a4        oscil     k1, inote+k2, ifunc2
a3        oscil     k1, inote*.997+k2, ifunc1
a2        oscil     k1, inote*1.003+k2, ifunc1
a1        oscil     k1, inote+k2, ifunc1
kfade     linseg    1, ifad1, 0, ifad2, 1
afunc1    =         kfade * (a1 + a2 +a3)
afunc2    =         (1-kfade) * (a4+a5+a6)
          out       afunc1 + afunc2
          endin


          instr     6
idur      =         p3
ifqm      =         400
imax      =         2
aform     line      400, idur, 800       ; CONTOUR OF FORMANT
amod      oscili    imax*ifqm, ifqm, 1   ; FM MODULATOR STABLE AT 400 Hz
;KOCT     IFNA      IDUR IFMODE
;XAMP     XFUND  XFORM    KBAND KRIS KDUR KDEC IOLAPS IFNB  IPHS
a1        fof       8000,  p4, aform+amod,0, 1, .0003, .5,  7,    3,  1, 19,idur,0, 1
          out       a1
          endin

          instr     7
idur      =         p3
iamp      =         p4/3
ifq       =         p5
if1       =         p6
if2       =         p7
a3        oscili    iamp, 1/idur, 52
a3        rand      a3, 400
a3        oscili    a3, 500, 11
a2        oscili    iamp, 1/idur, 52
a2        oscili    a2, ifq, if2     
a1        oscili    iamp, 1/idur, 51
a1        oscili    a1, ifq, if1            
          out       (a1+a2+a3) * 6
          endin

                          �  �   F  �Utility Dialogs   CPnlCMgr         �R    *  �     �  � �v��v�                      >�         >�                �Web Browser UI    CPnlCMgr         �Q    6T  �       � �v��v�                      >�         >�         <R*ch L 9�            L  	  Monaco                                                              H H    �(�����FG(�    H H    �(    d       '              ` �                                 Monaco�                                                                                                                                                                                                                                                         	   	HelveticaM                                                                                                                                                                                                                                                    Confidential	H                                                                                                                                                                                                                                                         �   �   �   �                                                H          H 	Monaco P�"r,F��Ms��   - 	N L 9T��e{           L      �  �   F��*�    F BBSR   MPSR   ��        ���  @�                                              