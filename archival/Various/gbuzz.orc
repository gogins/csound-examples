 	gbuzz.orc  �
��  8"��J  J�� `�
�t�ň��p   � ֎TEXTR*ch ����      J  ҳ`ܺ�"                       ��g�  sr        =         44100
kr        =         4410
ksmps     =         10
nchnls    =         2
  
  
          instr 2                               ; p6 = amp   
ifreq     =        cpspch(p5)                   ; p7 = reverb send factor
                                             ; p8 = lfo freq 
k1        randi    1, 30                        ; p9 = number of harmonic      
k2        linseg   0, p3 * .5, 1, p3 * .5, 0    ; p10 = sweep rate   
k3        linseg   .005, p3 * .71, .015, p3 * .29, .01
k4        oscil    k2, p8, 1,.2                   
k5        =        k4 + 2

ksweep    linseg   p9, p3 * p10, 1, p3 * (p3 - (p3 * p10)), 1
     
kenv      expseg   .001, p3 * .01, p6, p3 * .99, .001
asig      gbuzz    kenv, ifreq + k3, k5, ksweep, k1, 15

          outs     asig, asig
          
          endin
                                                           �  �   Fǣ��5I�v�eg���K�>���>��c������_�����W�S���V�������Vڙ�����/��{7���� �C�j���*�h&:#����N �&}������p���i�	���*��	R���/���M�M�G�Z�����h�Q� �������\"�e������a�-�T�L�������[���_�Y."k�@r��x��y�$  <R*ch x 
��               	  Monaco                                                              H H    �(�����FG(�    H H    �(    d       '              ` �                                 Monaco�                                                                                                                                                                                                                                                         	   	HelveticaM                                                                                                                                                                                                                                                    Confidential	H                                                                                                                                                                                                                                                         �   �   �   �                                                H           H 	Monaco ^�b�l�8�to{o��o{   - 	N x 
���j                  �  �   F��,p    F BBSR   MPSR   ��        ���  @�t                                              