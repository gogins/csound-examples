 	tulip.orc  �
��  8"��J  J�� `�
�t�ňާ�   � ֍TEXTR*ch ����      �  
��Wδ"                       ��6�  sr        =         44100
kr        =         4410
ksmps     =         10
nchnls    =         2
          
; TULIPS

          instr 1
itablesize =        12        
kindex    phasor    p5*p6                    ; VARIES PHASE OF LFO VS BEAT
                                             ; THUS CREATING MELODIC PATTERNS

plantatulip:
kenv      linen     1,.001,1/p5,1/p5*.9
ipitch    table     i(kindex)*itablesize,2
          timout    0,1/p5,pluckatulip
          reinit    plantatulip
               
pluckatulip:
a1        pluck    ampdb(p4)*kenv,cpspch(ipitch+p7),p8,0,1
          outs      a1,a1
          endin

                                                                                                                                    	�  �   Z��e"�����8�B�br
���2rj�=!�P�	tulip.orcscoco.fixk & Dot packe  TEXTR*ch ����          �       ��t  �  � B�Qz�����/%�--�uٸ�Ri�֖T��g:0�b�^K^ފ &�<��$�o�F�m>�Q�� s��ӻ&�Ӄ^w�U��佣BE���Ǎ CJ9�� 8�/������834�m��v>]Q�E��  R*ch �                                                                                                                         Monaco�                                                                                                                                                                                                                                                         	   	HelveticaM                                                                                                                                                                                                                                                    Confidential	H                                                                                                                                                                                                                                                         �   �   �   �                                                                                                                       <R*ch ( ��               	  Monaco                                                              H H    �(�����FG(�    H H    �(    d       '              ` �                                 Monaco�                                                                                                                                                                                                                                                         	   	HelveticaM                                                                                                                                                                                                                                                    Confidential	H                                                                                                                                                                                                                                                         �   �   �   �                                                H          H 	Monaco ��BR�LRVR��   R�h     - 	N ( �?��                  	�  �   ZR��9�    Z BBST   BBSR   &MPSR   2 ���        ��      ���  \R��                                                                                                                              