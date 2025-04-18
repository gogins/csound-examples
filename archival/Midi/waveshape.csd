<CsoundSynthesizer>
<CsOptions>
DirectCsound -RWdo waveshap.wav -F temp.mid  temp.orc temp.sco
</CsOptions>
<CsInstruments>
sr      =       44100
kr      =       44100
ksmps   =       1

        instr   1
icps    cpsmidi
iamp    ampmidi 512, 100
iscale  =       iamp * 30
kamp    linseg  0, .25, iamp, .25, iamp-100, 5, 0
awtosc  oscil   kamp, icps, 1
aout    table   awtosc + 512, 2
aeg     linenr  iscale, .01, .5, .01
        out     aout * aeg
        endin

instr   2
        icps    cpsmidi
        iamp    ampmidi 8192, 100
        iscale  =       iamp * .5
        k1      expseg  .01, .1, iamp, .03, iamp-1000, 5, .01
        a1      oscili  k1, icps, 1
        a1      tablei  a1, 3
        aeg     linenr  iscale, .01, .5, .01
                out     a1 * aeg
endin

instr   3
        icps     cpsmidi
        iamp     ampmidi 256, 100
        iscale   =       iamp*20
        kamp     linseg  0, .01, iamp, .35, iamp-30, 5, 0
        ktabmov  linseg  0, .01,  512, .35, 1024, 2, 1536, 5, 0
        awtosc   oscil   kamp, icps, 1
        aout     table   awtosc + 256 + ktabmov, 4, 0, 0, 1
        aeg      linenr  iscale, .01, .5, .01
        out      aout * aeg
endin
</CsInstruments>
<CsScore>
f0   600
f1     0  4096 10 1
f2     0  1025 13 1 1 6 4 2 3
f3     0  8193 13 1 1  0 5 -2 -3 0 8 -9 0 2 0 -3 0 2
f4     0   513  3 -1 1 0 0 3 0 -10.5 0 6
f100   0   128  7  0 128 1
e





</CsScore>
<CsMidifile>
<Size>
1622
</Size>
MThd      àMTrk  ? ÿfinal ÿT`     ÿX ÿQ
6 Cd >d :d 7dpC@p:@ 7@ Cd ?d :d 0dp>@ ?@ 0@ >d 2dpC@ :@ >@ 2@ Cd <d 9d 3dp9@ 7dpC@ <@ 3@ 7@ Bd >d 9d 2d`B@ >@ 9@ 2@ >d 9d 6d 0d`>@ 9@ 6@ 0@ Cd >d 7d .dp>@ @dpC@ 7@ .@ @@ Ed Bd <d -d`E@ B@ <@ -@ Fd Cd >d +d`F@ C@ >@ +@ Fd Cd >d 7d`F@ C@ >@ 7@ Hd Ed ?d 6d`H@ E@ ?@ 6@ Fd Cd >d 7d`F@ C@ >@ 7@ Ed Bd >d 2dHE@ B@ >@ 2@XEd Bd >d 2d`E@ B@ >@ 2@ Fd Cd >d 7d`F@ C@ >@ 7@ Hd Ed ?d <d`H@ E@ ?@ <@ Jd Fd Ad :dpJ@ A@ Hd ?dpF@ :@ H@ ?@ Fd Ad >d 8dp>@ <dpF@ A@ 8@ <@ Kd Cd :d 7dpC@ EdpK@ :@ 7@ E@ Kd Fd :d 6dp:@ <dpK@ F@ 6@ <@ Jd Fd >d 5dp>@ :dpJ@ F@ 5@ :@ Id Fd Cd 4dpI@ HdpF@ C@ 4@ H@ Hd Fd Ad 5d`F@ EdpA@ ?dpH@ 5@ E@ ?@ Fd Ad >d .dHF@ A@ >@ .@XFd Cd >d +dpC@ AdpF@ >@ +@ A@ Ed ?d <d 0dp?@ >dpE@ <@ 0@ >@ Cd @d :d 1d`C@ @@ :@ 1@ Ad >d 9d 2d`A@ >@ 9@ >d 9d 5dp2@ >@ ?d 0dp9@ 5@ ?@ 0@ Ad >d :d .dp>@ .@ ?d 0dpA@ :@ ?@ 0@ Ad Ad :d 2dp2@ .dpA@ A@ :@ .@ Cd Ad :d 3dpA@ ?dpC@ :@ 3@ ?@ Ad ?d 9d 5dp?@ >dpA@ 9@ 5@ >@ ?d >d :d 7dp>@ <dx<@ :dx:@ 7@ :@ <d 9d 5d`?@ <@ 9@ 5@ >d :d :d 5dH>@ :@ :@ 5@XJd Fd Ad :d`J@ F@ A@ :@ Hd Ed ?d 6d`H@ E@ ?@ Fd Cd >dp6@ F@ Ed 7dpC@ >@ E@ 7@ Ed Cd @d 1d`C@ @@ 1@ Bd >d 2dp>@ <dpE@ B@ 2@ <@ Cd >d ;d +d C@ >@ ;@ +@ ÿ/ </CsMidifile>
</CsoundSynthesizer>
