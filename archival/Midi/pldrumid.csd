<CsoundSynthesizer>
<CsOptions>
directcsound -RWdo pldrumid.wav -F temp.mid  temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr = 44100
kr = 4410
ksmps = 10
nchnls = 1

instr 1                                   ; pldmidi.orc

iamp     ampmidi  8000, 3                 ; convert velocity to amp, remap to table
irand    ampmidi  .5, 3                   ; fluctuation
ifrnd    cpsmidi                          ; convert midi note number to Hz
ifrnd1   = ifrnd + irand
ifrnd2   =  ifrnd1 * 2           
ifrnd3   =  ifrnd1 * 3           

icps = 261.6                              ; constant pitch
iband =  ifrnd1/10
kamp linenr iamp, .001, .5, .001          ; gate

asig  pluck kamp, icps, icps, 2, 3,.5     ; method 3, drum

aflt1 reson asig, ifrnd2, iband
aflt2 reson aflt1, ifrnd2, iband * 1.2
aflt3 reson aflt2, ifrnd3, iband * 2.1
abal  balance aflt3, asig
out abal

endin
</CsInstruments>
<CsScore>
f1 0 256 10 1
f2 0 4096 8  0.00 273 0.620 702 0.860 1508 0.870 676 0.620 351 -0.010 286 -0.760 300 0.00
f3 0 128 5 1 128 8      ;for veloc to non-linear amp

i1 	0 	    60
e



</CsScore>
<CsMidifile>
<Size>
1332
</Size>
MThd      àMTrk   ÿT`     $9 ÿX ÿQ	hH$@h$Cc$@$>+$@=$@g$@a$9:$@>$9W$@$9?$@9$<y$@w$J.$@:9 O/O@IO
0O@HO	'O@QO	O@^O*O@NO*O@NO(O@PO0O@@O@O@TC O%O@SO"O@I@O/O@I> O%O@SO(O@@EOO@Y@ O*O@NO)O@OO(O@PO%O@SO/O@IO'O@QO@O@M9 O,O@@>9W@!O%O@S9 O(O@@9< OO@YO@/O@HJ O*O@NO$O@@BO'O@E974<'7@j<@#C7p<p7<@QC@A'@7@QC<W@7%<@A@L><"L7@,C7&<@@=@7*<C@4<F7@2A*<<@4< @@A@!97 +<@@>9W@-C7!7@K9A#3@9<<)C@#A@F@72'<@EJ<+7@^7(*@<@;7@Ax0V <V ^V(5LA@^@:0@7# :* ^*<@5@^@H5< ^7@%^@:@J7( 0> ^5@^@^>@ ^7@)^@0@L7- ^*^@D>@
5% ^7@$^@P72 07 ^.5@^@H:P7@d7' ^$^@0@C5 ^7@:@^@S72 01 ^5@^@87@<E<> ^/^@I5* 7$ ^<@ <@0@^@S^7@^@P5@ 73 ^^@R7@0X ^X(5N^@&::0@^5@^@O56 ^(^@2:@0@ ^%^@5@?>9 ^/^@I^'^@.0@#0$ 5# ^>@^@M5 02 ^0@ 0@%^@5@ 5@D75 :Px02 ^7@^@G0@5! 5& ^(^@:@N08 <- ^5@ 5@^@Y<@ ^0^@0@<5 ^*^@D<@ <@
0- ^$^@5@M7. ^0@"^@Q9 9f7@b@ @hC Cc@ @> >+@ @=@ @g@ @a9 9:@ @>9 9W@ @9 9?@ @9< <y@ @wJ J.@ @:	9  9 9 9H	@  @ @ @8ÿ/ </CsMidifile>
</CsoundSynthesizer>
