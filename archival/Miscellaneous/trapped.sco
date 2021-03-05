
;---------------------------------------------

; TRAPPED IN CONVERT - Richard Boulanger

; written July 1979 in music11
; M.I.T. Experimental Music Studio

; revised June 1986 in Csound
; M.I.T. Media Lab

; revised  May 1989 in PCsound
; for the M.T.U. Digisound 16

;----------------------------------

;f1  0 1024   10    1

;f2  0  512   10   10  8  0  6  0  4  0	1
;f3  0  512   10   10  0  5  5  0  4  3	0  1
;f4  0  512   10   10  0  9  0  0  8  0	7  0  4  0  2  0  1	 0
;f5  0  512   10    5  3  2  1  0
;f6  0  512   10    8 10  7  4  3  1  0
;f7  0  512   10    7  9 11  4  2  0  1	1
;f8  0  512   10    0  0  0  0  7  0  0	0  0  2  0  0  0  1  1	0
;f9  0  512   10   10  9  8  7  6  5  4	3  2  1
;f10 0  512   10   10  0  9  0  8  0  7	0  6  0  5
;f11 0  512   10   10 10  9  0  0  0  3	2  0  0  1
;f12 0  512   10   10  0  0  0  5  0  0	0  0  0  3
;f13 0  512   10   10  0  0  0  0  3  1

;f14 0  512    9    1  3  0  3  1  0  9	.333  180
;f15 0 1024    9    1  1  90
;f16 0  512    9    1  3  0  3  1  0  6	1  0

;f17 0	 9    5   .1  8  1
;f18 0	17    5   .1 10  1  6 .4

;f19 0	16    2   10  7  6  5  4  3  2	1  0  0  0  0  0  0  0	0
f19 0	16    2   1   4  7  6  5  4  3  2  1  1  1  1  1  1  1  1

;f20 0	16   -2    0	30   40   45   50   40	 30   20  10  5  4  3  2  1  0	0  0
;f21 0	16   -2    0	20   15   10	9    8	  7    6   5  4  3  2  1  0  0
;f22 0	 9   -2  .001 .004 .007 .003 .002 .005 .009 .006

;============================== Parameters ===============================;

;i1:  p6=amp,p7=vib rate,p8=del time (default < 1),p9=freq drop

;i2:  p6=amp,p7=rvb attn,p8=lfo frq,p9=num of harmonics,p10=sweep rate

;i3:  p6=amp,p7=rvb attn,p8=rand frq

;i4:  p6=amp,p7=fltr swp:strt val,p8=fltr swp:end val,p9=bdwth,p10=rvb attn

;i5:  p4=cps of pan

;i6:  p6=amp,p7=rvb attn,p8=balnce,p9=carfrq,p10=modfrq,p11=modindex,p12=rndfrq

;i7:  p5=swp frq:strt val,p6=swp frq:end val,p7=bndwth,p8=rvb attn,p9=amp

;i8:  p4=amp,p5=frq,p6=strtphse,p7=endphse,p8=ctrlamp(.1-1),p9=ctrl fnc
;i8:	p10=aud fnc(f2/f3):fnclngth must be 512!,p11=rvb attn

;i9:  p4=del attn,p5=frq,p6=amp,p7=rvb attn,p8=rndamp,p9=rndfrq,p10=1 for space

;i10: p4=amp,p5=swp beg,p6=swp end,p7=bndwt,p8=rnd1:cps,p9=rnd2:cps,p10=rvb attn

;i11: p2=strt,p3=dur
      
;i12: p5=frq,p6=amp

;i13: p6=amp,p7=swp strt,p8=swp peak,p9=bndwth,p10=rvb attn
      
;i14: p6=amp,p7=vib rt,p8=frq of drop

;========================= Section 2: 46 seconds ========================;

;i5   0	    4.5      1
;i9   0	    5	      .4     10.01    1200	.2   28    39
;i9   0	    5	      .3      9.119   1200	.5   29    37
;i5   4.5    2	     8
;i11  0	   26.7
;i8   6.5    3.2   7000	      5.023	  .2	.7    .6  1    3  .2

;i7   4.5    4.3     17	   6000       9000   700.0    .5    3
;i5   2    9.9       .7

i7   0    5     17	   6000       9000   700.0    .5    3
f0   1
f0   2
f0   3
f0   4
e
