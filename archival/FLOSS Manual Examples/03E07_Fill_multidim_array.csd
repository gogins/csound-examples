<CsoundSynthesizer>
<CsOptions>
-nm0
</CsOptions>
<CsInstruments>

instr 1
iArr[][] init   2,3
iArr     array  1,2,3,7,6,5
iRow     =      0
until iRow == 2 do
iColumn  =      0
  until iColumn == 3 do
  prints "iArr[%d][%d] = %d\n", iRow, iColumn, iArr[iRow][iColumn]
  iColumn +=    1
  od
iRow      +=    1
od
endin

</CsInstruments>
<CsScore>
i 1 0 0
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
