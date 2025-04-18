<CsoundSynthesizer>
<CsOptions>
-nm0
</CsOptions>
<CsInstruments>

;an 'empty' function table with 10 points
giTable ftgen   0, 0, -10, 2, 0


  instr 1

;print inital values of giTable
        puts    "\nInitial table content:", 1
indx    =       0
  until indx == ftlen(giTable) do
iVal    table   indx, giTable
        printf_i "Table index %d = %f\n", 1, indx, iVal
indx += 1
  od

;create array with values 1..10
kArr[]  genarray_i 1, 10

;print array values
        printf  "%s", 1, "\nArray content:\n"
kndx    =       0
  until kndx == lenarray(kArr) do
        printf  "kArr[%d] = %f\n", kndx+1, kndx, kArr[kndx]
kndx    +=      1
  od

;copy array values to table
        copya2ftab kArr, giTable

;print modified values of giTable
        printf  "%s", 1, "\nModified table content after copya2ftab:\n"
kndx    =       0
  until kndx == ftlen(giTable) do
kVal    table   kndx, giTable
        printf  "Table index %d = %f\n", kndx+1, kndx, kVal
kndx += 1
  od

;turn instrument off
        turnoff
  endin

</CsInstruments>
<CsScore>
i 1 0 0.1
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
