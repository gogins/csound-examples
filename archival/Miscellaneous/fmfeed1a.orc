 fmfeed1a.orc�
��  8"��J  J�� `�
�t�ňݮ�   � ֎TEXTR*ch ����      �  
��W˴"                       ����  sr        =         44100
kr        =         4410
ksmps     =         10
nchnls    =         1

          instr 1
afm1      init      0
afm2      init      0    
isine     =         1
icaramp   =         p4
icarfreq  =         p5
ifeedscale =        p6   
kamp      linseg    0, p3*.01,1, p3*.98, 1,p3*.01,0
kfeedamp  linseg    0, p3*.03,1, p3*.97, 0
kfeedampinv linseg  1, p3*.03,0, p3*.97, 1
afm1      oscili    icaramp, (icarfreq+afm2)+kfeedampinv,isine
afm2      =         (afm1*ifeedscale)*kfeedamp
asig      =         afm1*kamp
;         display   afm1, .25
;         display   afm2, .25
          out       asig
          endin
                                                                                                                   	�  �   Z�)gn (#y&G(�*�+�,�-�.H.x./-�feedback 1a.orcsentsfserrbsinge TEXTR*ch ����                  ��C{  �  
 B��'	~������U!h#B$�&�(�*�,�.�0q1�33�4a4�4v4,3�2�1]/�-b*�'�$� v�[���C����������l�G�������[�Q��8�����4  R*ch �                                                                                                                         Monaco�                                                                                                                                                                                                                                                         	   	HelveticaM                                                                                                                                                                                                                                                    Confidential	H                                                                                                                                                                                                                                                         �   �   �   �                                                                                                                       <R*ch ( �               	  Monaco                                                              H H    �H����V,(�   hh    �h   d        '               0         ����F�                Monaco�                                                                                                                                                                                                                                                         	   	HelveticaM                                                                                                                                                                                                                                                    Confidential	H                                                                                                                                                                                                                                                         �   �   �   �                                                H          H 	Monaco q��2Z�2/�2��w�w2�(w�   3 	O ( 0 �<��                  	�  �   Z2�P!    Z BBST   BBSR   &MPSR   2 ���        ��      ���  \2��                                                                                                                              