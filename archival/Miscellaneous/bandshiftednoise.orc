sr = 44100
kr        =         4410
ksmps     =         10
nchnls    =         1
		instr 3
kenv		linseg	0, p3 * .5, 1, p3 * .5, 0 ; UP-DOWN RAMP ENVELOPE
kran 	randh 	50, kr				 ; PRODUCE VALUES BETWEEN -50 AND 50
kcent 	line 	1000, p3, 200			 ; RAMPCENTRE FREQENCY 1000 TO 200
kran 	=  		kran + kcent			 ; SHIFT RAND VALUES TO BASE FREQUENCY
asig 	oscil 	kenv * p4, kran, 1		 ; GENERATE A BAND OF NOISE
		out 		asig
																	
		endin
