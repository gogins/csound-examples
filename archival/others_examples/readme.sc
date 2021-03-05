This directory contains orchestra and score files (.orc/ & .sco),
runnable in pairs under the csound command:

		csound [flags] test.orc test.sco

The JD, JN, PC and RB files are fragments of original pieces by composers Jim
Dashow, Jon Nelson, Peter Child and Richard Boulanger -- all expert Csound users.
Fragments are about a minute each, and will take a few minutes to synthesize.
Usual copyrights apply.
The other scores are transciptions of traditional works, kept simple enough to
perhaps run in realtime if your machine has audio output and is fast enough
(3 Mflops or so).

Orchestra files are seen to specify sample_rates of 44100, 22050, 11025 or 8192.
The higher rates will suit those works with the most demanding frequency ranges;
the lower rates will favor realtime performance -- achievable on RISC machines
like the DECstation 5000 or Sparcstation II.
You may edit the orchestra SR, KR & KSMPS values to suit your machine,
but note that if the SR value is reduced some aliasing may occur.

To synthesize one of these pieces (write a soundfile for later playback),
type something like:

		csound -o soundfilename JD.orc JD.sco
	or	csound -o soundfilename JD.*

You would then hear this by running a 'play' program such as:

		play soundfilename

If your machine can manage realtime software synthesis and has an audio
output device (taking, say, u-law data), type something like:

		csound -uho stdout bach.* > /dev/audio
	or	csound -uho /dev/audio bach.*

If you have DEC or SGI 16-bit DAC's and appropriate drivers, type

		csound -o devaudio bach.*

You may have to experiment to get enough cycles for realtime synthesis at an
adequate sampling rate.   To this end, however, note that suppressing displays
and note_amp message output with flag -dm6 will save a few cycles.

Refer to the Csound manual for a more complete description of these commands.

