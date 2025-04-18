<CsoundSynthesizer>
<CsOptions>
directcsound -+X1 -+K1 -b200 miditest.orc miditest.sco
</CsOptions>
<CsInstruments>
sr = 44100
kr = 4410
ksmps = 10
nchnls = 1

instr 1
	knote	cpsmidib
	iveloc	ampmidi	1
	kgate	linenr	iveloc/2, 0, .2, .01
	
	kva	line	0, 3, .02
	kv	oscil	knote*kva, 4, 3

	kf	linseg	2200, 1.5, 1200, .5, 880, 5, 440
	
	k1	linseg	8000, .5, 8000, 5, 2000
	k2	line	700, .5, 700
	
	a5	oscil	k2, knote, 3
	a6	oscil	k2, knote*1.499, 3

	a1	oscil	k1, knote*2.001 + a5 + kv, 3
	a2	oscil	k1, knote*1.502 + a6 + kv, 3
	a2	butterlp	a2 + a1, kf

		out	    a2 * kgate
endin

; substitute knote for all audio oscillator frequency arguments
; multiply the output by kgate
; insert knote ...  iveloc... and kgate .... at the start of each instrument
;	knote	cpsmidib
;	iveloc	ampmidi	1
;	kgate	linenr	iveloc, 0, .2, .01
</CsInstruments>
<CsScore>
f0 15

f3 0 1024 10 1
f7 0 1024 8 0.001 300 .2 212 1 212 .2 300 0.001
f9 0 1024 8 1 512 .6 512 1

;i01     0.00    0.9     20000   9.06    0.00    0.01    0.002   10      2
;i01     1       1.2     .       9.07    0.10    0.00    0.779   .       .
;i01     2.2     0.3     .       9.08    -0.22   0.01    0.5     5       1
;i01     2.5     0.5     .       9.09    0.2     0.03    0.03    .       .
;i01     3       .       .       9.10    -0.5    0.05    0.99    .       .


e

; leave in all f statements
; comment out all notes from the score
; add an f0 line at top of score



</CsScore>
<CsMidifile>
<Size>
1005
</Size>
MThd       `MTrk  ׁ~�<g�7O�0W(�0 �< �7 6�?[�:T�3_,�:  �? �3 5�A_�<_�5W�� ]�5 
�A �< 3�<_�7T�0O,�0 �< �7 4�?W�:L�3I*�: �? �3 �B�B �B[�6c �=L7�Ac�B �<W�5W�= �6 ���� R�5 �A �< g�<_�7L�0W�/>�/ �0 �< �7 6�?W�:W�3L(�: �3 �? :�AL�<R�5W�� \�A  �5 �< G�?_�:[�3c(�3 	�:  �? 4�<g�7W�0W�	������ �=� ;� 7� 2� /� +� &� "� � � � � � � � �  � "� #� %� &� (� +� -� 0� 2� 8� @� >� :� 6� 1� .� *� &� #� !� � � � "� #� &� (� +� .� 0� 2� 5� 7� :� <� >� ?� @� ?� >� <� ;� :� 8� 6� 5� 4� 3� 2� 1	� 2� 4� 5� 6� 8� :� ;� <� ;� 9� 8� 6� 5� 3� 1� /� .� ,� +� *� (	� *� ,� -� .� 1� 2� 3� 5
� 4� 3� 1� /� -� ,� +� *� (� '� &� $� #� !�  � � � 	� � � !� "� #� %� '� (� *� ,� -� /� 0� 1� 2� 4� 5� 6� 8� 9� :� ;� =� >� ?� @!� >� =� ;� :� ;� =� ?� @� ?� >� <� ;� 9� :� ;� =� ?� @4�0 �< �7  �/ </CsMidifile>
</CsoundSynthesizer>
