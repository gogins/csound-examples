<CsoundSynthesizer>
<CsOptions>
-oThePungentGarden.wav --nchnls=2 --0dbfs=1 --nodisplays --sample-rate=48000 --ksmps=10 --sample-accurate --messagelevel=70
</CsOptions>
<CsInstruments>


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   SETUP LIBRARY
;;;;;;;;;;;;;;;;;;;;;;;;
printf_i "beginning SetupLib % f\n", 1, 1
gk_tempo init 60
gk_now init 0
gk_off init 0

chnset 1, "MasterLevel"


;Default scale
gi_SuperScale = 0   ;;gi12coul_12afn

;gi_majorC used as default
;can be changed with the setScale OPCODE
gi_CurrentScale ftgen 0,0,128,-2,7, 2,    263, 0

giTonic_ndx = 0  ;might be better than krate

; Shapes
gi_sine ftgen 0, 0, 16384,10,1
gi_cosine ftgen 0,0,16384,11,1,1

;for bellpno
gicarfn ftgen 0, 0, 512,  10,  1, 0, 0.05, 0, 0.01
gimodfn ftgen 0, 0, 512,  10,  1, 0.1,0.3, 0.02,0.1

;for padoscil
gicusttable ftgen 5, 0, 16384, 8, -1, 2, 1, 4096, 0.1, 4096, -1, 7900, 1, 290, -1
giaftersawfn vco2init 1, 256
giaftertrifn vco2init 16, giaftersawfn
giaftersquarefn vco2init 8, giaftertrifn
giafterpulsefn vco2init 4, giaftersquarefn
giafterisaw vco2init 2, giafterpulsefn
giaftercust vco2init -gicusttable, giafterisaw, 1.05, 128, 2^16, gicusttable

;for basswobbler
gi_cubicb ftgen 0, 0, 512, 8, 0, 128, 1, 128, 0, 256, 0
gienvlpxrrise ftgen 0,0,129,-7,0,128, 1

seed 0

opcode minarray2, i,i[]
iInarray[] xin
iresult = iInarray[0]
indx init 1
until indx == lenarray(iInarray) do
    ival = iInarray[indx]
    if ival < iresult then
       iresult = ival
    endif
    indx += 1
od
xout iresult
endop

opcode minarray2, ii,i[]
iInarray[] xin
indxlow = 0
iresult = iInarray[indxlow]
indx = 1
until indx == lenarray(iInarray) do
    ival = iInarray[indx]
    if ival < iresult then
       iresult = ival
       indxlow = indx
    endif
    indx += 1
od
xout iresult, indxlow
endop

opcode maxarray2, i,i[]
iInarray[] xin
iresult = iInarray[0]
indx init 1
until indx == lenarray(iInarray) do
    ival = iInarray[indx]
    if ival > iresult then
       iresult = ival
    endif
    indx += 1
od
xout iresult
endop

opcode maxarray2, ii,i[]
iInarray[] xin
indxhigh = 0
iresult = iInarray[indxhigh]
indx = 1
until indx == lenarray(iInarray) do
    ival = iInarray[indx]
    if ival > iresult then
       iresult = ival
       indxhigh = indx
    endif
    indx += 1
od
xout iresult, indxhigh
endop

opcode minarray2, k,k[]
kInarray[] xin
kresult = kInarray[0]
kndx init 1
until kndx == lenarray(kInarray) do
    kval = kInarray[kndx]
    if kval < kresult then
       kresult = kval
    endif
    kndx += 1
od
xout kresult
endop

opcode minarray2, kk,k[]
kInarray[] xin
kndxlow init 0
kresult = kInarray[kndxlow]
kndx init 1
until kndx == lenarray(kInarray) do
    kval = kInarray[kndx]
    if kval < kresult then
       kresult = kval
       kndxlow = kndx
    endif
    kndx += 1
od
xout kresult, kndxlow
endop

opcode maxarray2, k,k[]
kInarray[] xin
kresult = kInarray[0]
kndx init 1
until kndx == lenarray(kInarray) do
    kval = kInarray[kndx]
    if kval > kresult then
       kresult = kval
    endif
    kndx += 1
od
xout kresult
endop

opcode maxarray2, kk,k[]
kInarray[] xin
kndxhigh init 0
kresult = kInarray[kndxhigh]
kndx init 1
until kndx == lenarray(kInarray) do
    kval = kInarray[kndx]
    if kval > kresult then
       kresult = kval
       kndxhigh = kndx
    endif
    kndx += 1
od
xout kresult, kndxhigh
endop

;wrapper around buggy sumarray
opcode sumarray2, i,i[]
iArr[] xin
iresult = 0
indx = 0
ilen lenarray iArr
until (indx == ilen) do
    iresult += iArr[indx]
    indx += 1
od
xout iresult
endop

opcode sumarray2, k,k[]
kArr[] xin
kresult init 0
kndx init 0
klen lenarray kArr
until (kndx == klen) do
    kresult += kArr[kndx]
    kndx += 1
od
xout kresult
endop

;a wrapper to for my preferred indexing around slicearray
opcode slicearray2, i[],i[]iip
  iArr[],ibeg,iend,istride xin  
  iend -= 1
iresult[] init (iend <= 0 ? 1:iend)
iresult[] slicearray iArr, ibeg, iend, istride
xout iresult
endop

;a wrapper to fix index 0 slicearray
opcode slicearray2, k[],k[]iip
kArr[],ibeg,iend,istride xin
iend -= 1
kresult[] slicearray kArr, ibeg, iend, istride
xout kresult
endop


;Generates a scale of equidistant degrees per period, usable by the cpstun[i] opcode.
;insteps is number of steps in the scale.
;ibasefreq and ibasekey correspond to the cpstun opcode documentation.  
;ibasefreq defaults to Csounds A4 value. ibasekey defaults to 69.
;iperiod specifies the scale repetition period. Defaults to 2 (octave)
;ifn specifies the ftable no. Defaults to zero (csound generated number).
;Output is the table number. 
;Example:
;generate a 13ed3 (Bohlen Pierce 13ed3 Tritave) scale.
;giscale TBedn 13, 263, 60, 3
opcode TBedn, i, ijjoo
insteps, ibasefreq, ibasekey, iperiod, ifn xin
ibasefreq = (ibasefreq == -1 ? A4 : ibasefreq)
ibasekey = (ibasekey == -1 ? 69 : ibasekey)
iperiod = (iperiod == 0 ? 2 : iperiod)
idummy_ ftgen ifn, 0, -(insteps + 5), -2, insteps, iperiod, ibasefreq, ibasekey, 1
iarrstep init 0
while iarrstep < insteps do
   tableiw iperiod^((iarrstep + 1)/insteps), iarrstep + 5, idummy_
   iarrstep += 1
od
xout idummy_
endop


opcode get2dArr, i[], ii[][]
;returns the array from the 2nd dimension of a 2d array
indx, imulti[][] xin
icount = 0
ilen lenarray imulti, 2
iout[] init ilen
until (icount == ilen) do
    iout[icount] = imulti[indx][icount]
    icount += 1
od
xout iout
endop

;very forgiving array indexing
;indices wrap around array length.
;negative indices count backwards from array kength
;note that just using wrap isn't suitable as wrap(-n,0,n) == n
;example
;iArr fillarray 4.5,4.6,4.7,4.8
;ndxarray(iArr,2.999) => 4.7
;ndxarray(iArr,5) => 4.6
;ndxarray(iArr,-2) => 4.7
opcode ndxarray, i,i[]i
iArr[], indx xin
ilen lenarray iArr
iresult = int(indx)
if (iresult >= ilen) then
   iresult = wrap(iresult, 0, ilen)
elseif (iresult < 0) then
   if (iresult = -ilen) then
      iresult = 0
   else
      iresult = wrap(iresult, 0, ilen)
   endif
endif
xout iArr[iresult]
endop


opcode ndxarray, k,k[]k
kArr[], kndx xin
klen lenarray kArr
kresult = int(kndx)
if (kresult >= klen) then
   kresult = wrap(kresult, 0, klen)
elseif (kresult < 0) then
   if (kresult = -klen) then
      kresult = 0
   else
      kresult = wrap(kresult, 0, klen)
   endif
endif
xout kArr[kresult]
endop


opcode membership, i, ik[]
;returns index position of ival, or  -1 if false
ival, kselection[] xin

iresult = -1
indx = 0
until (indx == lenarray(kselection)) do

if (ival == i(kselection, indx)) then
iresult = indx
endif
indx += 1
od

xout iresult
endop

opcode membership, i, ii[]
ival, iselection[] xin
iresult = -1
indx = 0
until (indx == lenarray(iselection)) do

if (ival == iselection[indx]) then
iresult = indx
endif
indx += 1
od

xout iresult
endop

;converts a karray to an iarray
opcode castarray, i[],k[]
kArr[] xin

iArr[] init lenarray(kArr)
indx = 0
until indx == lenarray:i(iArr) do
   ival = i(kArr, indx)
   iArr[indx] = ival
   indx += 1 
od
xout iArr
endop

opcode sortarray, k[], k[]
;slightly modified from CsUDO repository
kInArr[] xin
  kOutArr[]  init  lenarray(kInArr)
  kMax      maxarray2  kInArr
  kIndx     init  0
  until     kIndx == lenarray(kOutArr) do
      kMin, kMinIndx minarray2 kInArr
      kOutArr[kIndx] = kInArr[kMinIndx]
      kInArr[kMinIndx] = kMax+1
      kIndx += 1
  od
xout       kOutArr
endop

;irate version
opcode sortarray, i[], i[]
;slightly modified from CsUDO repository
iInArr[] xin
  iOutArr[]  init  lenarray(iInArr)
  iMax      maxarray2  iInArr
  iIndx     init  0
  until     iIndx == lenarray(iOutArr) do
      iMin, iMinIndx minarray2 iInArr
      iOutArr[iIndx] = iInArr[iMinIndx]
      iInArr[iMinIndx] = iMax+1
      iIndx += 1
  od
xout       iOutArr
endop

;returns an array of differences between values in an array.
;e.g. arraydeltas(fillarray(2,3,2,1))
;returns an array of 2,1,-1,-1
opcode arraydeltas, k[],k[]
kinArr[] xin
koutArr[] init lenarray(kinArr) - 1
kndx = 1
kval = 0
klastval = kinArr[0]
until (kndx == lenarray(kinArr)) do
    kval = kinArr[kndx]
    koutval = kval - klastval
    koutArr[kndx - 1] = koutval
    klastval = kval
    kndx += 1
od
xout koutArr
endop

opcode arraydeltas, i[],i[]
iinArr[] xin
ioutArr[] init lenarray(iinArr) - 1
indx = 1
ival = 0
ilastval = iinArr[0]
until (indx == lenarray(iinArr)) do
    ival = iinArr[indx]
    ioutval = ival - ilastval
    ioutArr[indx - 1] = ioutval
    ilastval = ival
    indx += 1
od
xout ioutArr
endop

;;
opcode rotatearray, i[],i[]i
iinArr[], ishift  xin

ilen lenarray iinArr
ioutArr[] init ilen
indx = 0
until (indx == ilen) do
;    ioutArr[indx] = iinArr[(indx + ishift) % ilen]
    ioutArr[indx] = ndxarray(iinArr, (indx + ishift))
    indx += 1
od

xout ioutArr
endop

opcode rotatearray, k[],k[]i
kinArr[], ishift  xin
klen init lenarray(kinArr)
koutArr[] init i(klen)
kndx = 0
until (kndx == klen) do
;    koutArr[kndx] = kinArr[(kndx + ishift) % klen]
    koutArr[kndx] = ndxarray(kinArr, (kndx + ishift))
    kndx += 1
od

xout koutArr
endop


;compares the contents of two tables
;returns 1 if the tables are identical, or 0 if there are differences.
opcode tableeqv, i,ii
iaft, ibft xin

ialen tableng iaft
iblen tableng ibft
ishortlen = (ialen < iblen ? ialen : iblen)
iresult = 1
indx = 0
until (indx == ishortlen) do
    iaval tab_i indx, iaft
    ibval tab_i indx, ibft
    cigoto (iaval != ibval), EXITFAIL
    indx += 1
od
igoto EXIT
EXITFAIL:
iresult = 0
EXIT:
xout iresult
endop

;compares values stored in two ftables.
;returns an array of indices where values stored in
;ifta match values in iftb
;iastart, ibstart and iaend, ibend select a sections of the tables to examine.
;defaults are zero - whole tables are compared
opcode matchindices, i[],iioooo
iaft, ibft, iastart, ibstart, iaend, ibend xin
if (iaend == 0) then
   iaend tableng iaft
endif
if (ibend == 0) then
   ibend tableng ibft
endif
iresult[] init (iaend - iastart)
ifound = 0
until (iastart >= iaend) do
    iaval tab_i iastart, iaft
    ibndx = ibstart
    until (ibndx >= ibend) do
        ibval tab_i ibndx, ibft
        if (ibval == iaval) then
           iresult[ifound] = ibndx - ibstart
           ifound += 1
        endif
        ibndx += 1
    od
    iastart += 1
od
xout iresult
endop


;irate version
opcode scalemode, 0, iii[]
;sets the current scale to a mode from superscale
; scalemode gi_12edo, 2, array(0,2,4,5,7,9,11)
;returns position of keyctr in new mode, and sets gk_tonicndx
isuperscale, ikeyctr, iSuperscaleIntervalPattern[] xin

isubpattern[] init lenarray(iSuperscaleIntervalPattern)
isubpattern[0] = 0
isubpndx init 1

until (isubpndx == lenarray(isubpattern)) do
isubpattern[isubpndx] = isubpattern[isubpndx - 1] + iSuperscaleIntervalPattern[isubpndx - 1]
isubpndx += 1
od

inumgrades table 0, isuperscale
iindinums[] init lenarray(isubpattern)
indx init 0
ilast init 0
iscaleroot init 0
iscalekeyctrndx init -1
ival init 0

iindices[] = iindinums

until indx == lenarray(iindices) do
ival = isubpattern[indx]
iindices[indx] = (ival + ikeyctr) % inumgrades
indx += 1
od

ilastvalfromsuper table inumgrades + 4, isuperscale
imodularval table ikeyctr + 4, isuperscale
;ilastval = imodularval * ilastvalfromsuper


isorted[] sortarray iindices ; 
iscaleroot = isorted[0]

ilen init 0
ilen lenarray isorted
tableiw ilen, 0, gi_CurrentScale
;tableiw ilastval, ilen + 4, gi_CurrentScale

indx = 0
until (indx == ilen) do
  isortedndx = isorted[indx]
  irevisedval table isortedndx + 4, isuperscale
  tableiw irevisedval, indx + 4, gi_CurrentScale
  if (irevisedval == imodularval) then
      iscalekeyctrndx = indx
  endif
  indx += 1
od
tableiw table:i(4,gi_CurrentScale) * ilastvalfromsuper, ilen + 4, gi_CurrentScale

giTonic_ndx = iscalekeyctrndx

if (gi_SuperScale == 0) then
   gi_SuperScale = isuperscale
elseif (tableeqv(gi_SuperScale, isuperscale) == 0) then
   gi_SuperScale = isuperscale
   ;tablecopy gi_SuperScale, isuperscalefn
else
   ;pass
endif   
endop

opcode scalemode, 0, iik[]
;This is just a wrapper for the irate array version 
;but is useful when using inline arrays which default to krate.
;e.g. scalemode gi_31edo, 0, array(5,5,3,5,5,5,3)
isuperscale, ikeyctr, kSuperscaleIntervalPattern[] xin
iSuperscaleIntervalPattern[] castarray kSuperscaleIntervalPattern
scalemode isuperscale, ikeyctr, iSuperscaleIntervalPattern
endop

;A modulation opcode, a quirky wrapper around the scalemode opcode.
;scaleModulate changes the current scale by rotating the interval pattern between steps, and 
;shifting the keycentre.
;iinterval = the degree to shift the tonic key to.
;imoderef = The degree of rotation of the scale.
;ichromatic = shifts the keycentre n steps in gi_Superscale.
;examples:
;;Start in C major in 31edo
;scalemode31 0, 1
;;move to D major
;scaleModulate 1
;
;;change to d minor 
;scaleModulate 0,5 ;
;
;;back to C Major
;scaleModulate -1, 2
;
opcode scaleModulate, 0,ioo
iinterval, imoderef, ichromatic xin
iindices[] matchindices gi_CurrentScale, gi_SuperScale, 4, 4, tab_i(0, gi_CurrentScale) + 5, tab_i(0, gi_SuperScale) + 5
;printarray iindices
itestend = -1
ilastval = ndxarray(iindices, itestend)
ilastdiff = 0  
until (ilastval != 0) do
   ilastdiff = (tab_i(0,gi_SuperScale) - ilastval) + iindices[0]
   iindices[lenarray(iindices) + itestend] = ilastdiff
   itestend -= 1
   ilastval = ndxarray(iindices, itestend)
od
iintervalpattern[] arraydeltas iindices
icurrentmode[] rotatearray iintervalpattern, giTonic_ndx
;inewkeyctr = sumarray2(slicearray2(icurrentmode, 0, wrap(iinterval + giTonic_ndx, 0, lenarray(icurrentmode))))
  ;debug inewkeyctr
inewslice[] slicearray2 icurrentmode, 0, wrap(iinterval + giTonic_ndx, 0, lenarray(icurrentmode))
inewkeyctr sumarray2 inewslice
;printarray inewslice
printf_i "==== inewmode = %f\n", 1, inewkeyctr
  
inewmode[] rotatearray icurrentmode, imoderef
scalemode gi_SuperScale, inewkeyctr+ichromatic, inewmode

endop

opcode setbasefreq, 0, ii
ihz,itb xin
tablew ihz, 2, itb
endop


opcode stop, 0, i
inum xin
event_i "i", 1, 0, 1, inum
endop

opcode now, i, 0
xout i(gk_now)
endop

opcode cosr, i, ijo
;translated from impromptu's cosr macro
;does a complete cosine cycle, with multiplier and offset for convenience
;iamp defaults to 0.5
;ioffset defaults to 0.5 if iamp is not set, otherwise defaults to 1
iperiod, iamp, ioffset xin

if (iamp == -1) then
 iamp = 0.5
 ioffset = 0.5
endif

xout cos(divz:i(1,iperiod,0) * (2 * $M_PI) * now()) * iamp + ioffset
endop



;alternative version, doesn't use an event.
opcode temposet, 0, i
ibpm xin
gk_tempo init ibpm
endop

opcode tempoget, i, 0
xout i(gk_tempo)
endop

opcode tempodur, i, p
idur xin
iresult divz 60, i(gk_tempo), -1
xout iresult * idur
endop

opcode tempodur_k, k, k
kdur xin
kresult divz 60, gk_tempo, -1
xout kresult * kdur
endop


opcode nextbeat, i, p
ibeatcount xin
if ibeatcount == 0 then
iresult = 0
else
inow = now()
ibc = frac(ibeatcount)
inudge = int(ibeatcount)
iresult = inudge + ibc + (round(divz(inow, ibc, inow)) * (ibc == 0 ? 1 : ibc)) - inow
endif
xout tempodur(iresult)
endop

opcode onbeat, i, pp
ibeatnum, ibarlen xin

ideltime wrap (ibeatnum % ibarlen) - (now() % ibarlen), 0, ibarlen

if (ideltime < 0.05) then
  ideltime  =  ibarlen - ideltime
endif

xout (tempodur(ideltime))
endop


opcode off, 0, i
insno xin
gk_off init insno
endop

opcode on, 0, i
insno xin
event_i "i", insno, 0, -1
endop

opcode linslide, 0, Siijo
Schan, idur, idest, istart, itype  xin
;like activating an automated slider on a controller.
;Updates the channel (Schan) to move from it's current value to reach idest over idur time. 
;starts on nextbeat(1) unless istart is specified
;duration measured in tempodur(n)
;example usage: linslide "fluteamp1", 10, 0.3
;results in the "fluteamp" channel to linearly change from it's current value to 0.3 over 10 beats. 
;activates at itime, but updates Schan at krate.
;be mindful of activating multiple instances concurrently on the same channel: Might produce unintended results.

ist = nextbeat(abs(istart)) ;default is nextbeat(1)

Sout sprintf "i3 %f %f \"%s\" %f %f", ist, tempodur(idur), Schan, idest, itype
scoreline_i Sout

endop


opcode randint_i, i, ii
;returns a random integer inclusive of min and max
;ok, seems trivial, but I always forget this.
imin, imax xin
xout round(random(imin, imax))
endop

opcode counterChan, i, Spoo
;state saving counter. 
Schan, iincrement, imodulo, ilower  xin
icurrent chnget Schan
if (imodulo != 0) then
   icurrent = wrap(icurrent, ilower, imodulo)
   inewval = wrap((icurrent + iincrement), ilower, imodulo)
else
   inewval = icurrent + iincrement
endif
chnset inewval, Schan
xout icurrent
endop

opcode counterChan, K, SPOO
;state saving counter. mightneed once code
Schan, kincrement, kmodulo, klower  xin
konce init 0
ckgoto (konce == 1), terminate
kcurrent chnget Schan
if (kmodulo != 0) then
   kcurrent = wrap(kcurrent, klower, kmodulo)
   knewval = wrap((kcurrent + kincrement), klower, kmodulo)
else
   knewval = kcurrent + kincrement
endif
chnset knewval, Schan
konce = 1
terminate:
xout kcurrent
endop


;returns successive values in an array on every call
;works with irate arrays
;Sid is a string (any unique string), to store the state of each instance.
opcode iterArr, i,i[]Sp
iArr[], Sid, idirection xin
ival counterChan Sid, idirection, lenarray(iArr); [, iincrement, imodulo, ilower]
iout = iArr[floor(ival)]
xout iout
endop

;version for krate (inline) arrays
opcode iterArr, i,k[]Sp
kArr[], Sid, idirection xin
ival counterChan Sid, idirection, lenarray(kArr); [, iincrement, imodulo, ilower]
iout = i(kArr, floor(ival))
xout iout
endop

opcode walkerChan, i, Spoo
;state saving random walk. One per instrument, unless insnum is specified.
Schan, istepsize, imodulo, ilower xin

icurrent chnget Schan
istepsize = istepsize * signum(rnd31(1,1))

if (imodulo != 0) then
   icurrent = wrap(icurrent, ilower, imodulo)
   inewval = wrap((icurrent + istepsize), ilower, imodulo)
else
   inewval = icurrent + istepsize
endif

chnset inewval, Schan
xout icurrent
endop

opcode randselect_i, i, ijjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
ival1, ival2, ival3, ival4, ival5, ival6, ival7, ival8, ival9, ival10, ival11, ival12, ival13, ival14, ival15, ival16, \
ival17, ival18, ival19, ival20, ival21, ival22, ival23, ival24, ival25, ival26, ival27, ival28, ival29, ival30, ival31, ival32 xin

iargArray[] array ival32, ival31, ival30, ival29, ival28, ival27, ival26, ival25, ival24, ival23, ival22, ival21, ival20, ival19, ival18, ival17, ival16, ival15, ival14, ival13, ival12, ival11, ival10, ival9, ival8, ival7, ival6, ival5, ival4, ival3, ival2, ival1

istart = 0
until (iargArray[istart] != -1) do
istart += 1
od

iout = iargArray[int(random(istart, lenarray(iargArray)))]

xout iout
endop

opcode rescale, i, iiiii
ival, ioldmin, ioldmax, inewmin, inewmax  xin

ioldrange = ioldmax - ioldmin
inewrange = inewmax - inewmin
ioldsize = ival - ioldmin

xout ((inewrange / ioldrange) * ioldsize) + inewmin

endop


opcode rescalek, k, kkkkk
kval, koldmin, koldmax, knewmin, knewmax  xin

koldrange = koldmax - koldmin
knewrange = knewmax - knewmin
koldsize = kval - koldmin

xout ((knewrange / koldrange) * koldsize) + knewmin

endop

;a wrapper around a power curve really. 
;ipower < 0.5 = convex fast to approach 1
;ipower > 0.5 - concave slow to approach 1
;expects ival to be between 0 - 1. Other values allowed, and might be useful...
;if ipower == 0.5 or 1.00 returns the value unchanged (straight line)
;defaults to a straight line.
opcode curve,i,ip
ival, ipower xin

if (ipower == 1) then
ipower = 1
elseif (ipower == 0.5) then
ipower = 1
elseif ipower > 0.5 then
ipower = rescale(ipower, 0.5, 1.0, 1, 3.5)
else
ipower = ipower * 2
endif

xout ival ^ ipower
endop


opcode curvek,K,KK
kval, kpower xin

if (kpower == 1) then
kpower = 1
elseif (kpower == 0.5) then
kpower = 1
elseif kpower > 0.5 then
kpower = rescalek(kpower, 0.5, 1.0, 1, 3.5)
else
kpower = kpower * 2
endif

kresult pow kval, kpower

xout kresult
endop

opcode accumarray, k[], k[]
kArrSrc[] xin

kArrRes[] init lenarray(kArrSrc)

konce init 0
ckgoto (konce == 1), terminate

kndx    init       0

ksum init 0
until (kndx == lenarray(kArrSrc)) do
  kresult   =  ksum + kArrSrc[kndx]
  kArrRes[kndx] = kresult
  ksum      =  kresult
  kndx     = kndx + 1
od

konce = 1

terminate:
xout kArrRes
endop


opcode onsetArrayLength_i, i, k[]KO
;return the the minimum length required to build an onset array, with overlap
kArrSrc[], kdur, koverlap xin
isum = 0
indx = 0

ilenSrc lenarray kArrSrc
until (indx >= ilenSrc) do
  isum      +=        i(kArrSrc, indx)
  indx      +=        1
od

isum = isum + i(koverlap)

iresult = ceil(i(kdur) / isum)
inewlen = iresult * ilenSrc 

isumtruncated = iresult * isum 
istepback = 0

if (isumtruncated > i(kdur)) then 
isumtruncated -= i(koverlap) 
endif

until (isumtruncated <= i(kdur)) do
  istepback +=        1 
  ilook     =  (ilenSrc - istepback) % ilenSrc 
  isumtruncated       -=  i(kArrSrc, ilook)
od
inewlen -= istepback 

xout inewlen
endop


opcode onsetaccum, k[], k[]KO
;return an onset array
kArrSrc[], kdur, koverlap xin
ionsetlength onsetArrayLength_i kArrSrc, kdur, koverlap ;
kArrRes[] init ionsetlength
iSrclen lenarray kArrSrc

kndx init 0
ksum init 0
ktrythisndx init 0  ;must re-init on subsequent calls.

while (kndx < ionsetlength) do
  ktrythisndx = kndx % iSrclen
  ksum      +=        kArrSrc[ktrythisndx]
  kArrRes[kndx] = ksum
  kndx      +=        1
  if ktrythisndx == 0 then
     ksum      +=        koverlap
  endif 
od

xout kArrRes
endop


opcode lazyvent, 0, kkkkkkkkkkkk
knno, ksta, kdur, kamp, kpit, kp6, kp7, kp8, kp9, kp10, kp11, kp12 xin
event "i", 4, ksta, kdur, knno, kamp, kpit, kp6, kp7, kp8, kp9, kp10, kp11, kp12
endop

opcode lazyvent, 0, kkkkkkkkkkk
knno, ksta, kdur, kamp, kpit, kp6, kp7, kp8, kp9, kp10, kp11 xin
event "i", 4, ksta, kdur, knno, kamp, kpit, kp6, kp7, kp8, kp9, kp10, kp11
endop

opcode lazyvent, 0, kkkkkkkkkk
knno, ksta, kdur, kamp, kpit, kp6, kp7, kp8, kp9, kp10 xin
event "i", 4, ksta, kdur, knno, kamp, kpit, kp6, kp7, kp8, kp9, kp10
endop

opcode lazyvent, 0, kkkkkkkkk
knno, ksta, kdur, kamp, kpit, kp6, kp7, kp8, kp9 xin
event "i", 4, ksta, kdur, knno, kamp, kpit, kp6, kp7, kp8, kp9
endop

opcode lazyvent, 0, kkkkkkkk
knno, ksta, kdur, kamp, kpit, kp6, kp7, kp8 xin
event "i", 4, ksta, kdur, knno, kamp, kpit, kp6, kp7, kp8
endop

opcode lazyvent, 0, kkkkkkk
knno, ksta, kdur, kamp, kpit, kp6, kp7 xin
event "i", 4, ksta, kdur, knno, kamp, kpit, kp6, kp7
endop

opcode lazyvent, 0, kkkkkk
knno, ksta, kdur, kamp, kpit, kp6 xin
event "i", 4, ksta, kdur, knno, kamp, kpit, kp6
endop

opcode lazyvent, 0, kkkkk
knno, ksta, kdur, kamp, kpit xin
event "i", 4, ksta, kdur, knno, kamp, kpit
endop

; ornament UDO
;   koriginal[], \
;   kwhens[], kdurs[], kamps[], kintervals[] [, kp6] [,kp7] [,...]\
;   korndur, kscale, koverlap xin

;   also... overloaded versions for convenience...
;   koriginal[], \
;   kwhens[], kamps[], kintervals[] [, kp6] [,kp7] [,...]\
;   korndur, kscale, koverlap xin

;   koriginal[], \
;   kwhens[], kintervals[] [, kp6] [,kp7] [,...]\
;   korndur, kscale, koverlap xin

;   koriginal[], \
;   iwhens, kintervals[] [, kp6] [,kp7] [,...]\
;   korndur, kscale, koverlap xin

; Generates a sequence of score events 
; 
; koriginal[] is an array of values which are treated like pfields in a score event.
; e.g. array(101, 0, 1, 0.8, 5) is equivalent to i101 0 1 0.8 5
;
;kwhens is an array specifying rhythmic intervals between generated events.

;kdurs[], kamps[], kintervals[], kp6[] etc... are numeric arrays. 
;The values in the arrays specify deviations in the generated events from the corresponding pfield in koriginal. 
;The deviations accumulate and are applied in a looped sequence for the length of orndur.
;For example using, kintervals[] array 2,-2, 1  will cause pitches in the generated events to ascend by 2steps, fall by 2steps, then ascend by 1, and repeat until orndur is reached.
;to keep a pfield constant, use array(0). To loop a set of values, ensure the sum of the array values equals zero.

; korndur sets the duration of the entire ornament. Defaults to the calling instruments p3.

; kscale is a table used by cpstun. defaults to gi_CurrentScale

; kpitbound sets upper or lower bounds to pitch generation. 
; If the sum of kintervals is positive an upper bound is set, with the lower bound being the pitch in koriginal.
; The reverse situation operates when the sum of kintervals is negative: i.e. a lower bound is set, with the upper bound being the pitch in koriginal.
; A positive kpitbound refects pitches using mirror. A negative kpitbound uses wrap.
; Default is 0 - no pitch boundaries.
;EXAMPLE
/*
instr 101

ares bellpno p4, p5, p6, p7, p8;kamp, ifrq, imod [, ir1, ir2]

ares declickr ares
chnmix ares, "outputC" 

endin

instr 11

ornament array(101, 0, 0.4, 0.2, -7, 2, 1, 1), array(0.125, 0.125, 0.125, randselect_i(0.125)), array(0), array(0), array(1), array(-0.1),\
array(0), array(1, -1), array(0), array(0),\
1.25,0

schedule p1, nextbeat(3), 5
turnoff
endin

schedule 11, nextbeat(1), 1
*/

opcode ornmaster, 0, k[]k[]k[]k[]k[]k[]k[]k[]k[]k[]OOO
  koriginal[], \
  kwhens[], kdurs[], kamps[], kintervals[], kp6[], kp7[], kp8[], kp9[], kp10[], \
  kpitbound, korndur, kscale xin

; defaults to p3, nb: negative orndur is special and overides durvals  
  if (i(korndur) == 0) then
  korndur init p3
  endif

  kndx      init      0                           
  konce     init      0
  iplen lenarray koriginal
  ckgoto    (konce == 1), terminate     ; one pass... change this to a trigger? extra p. hmmm.

  kscale    =  (kscale == 0 ? gi_CurrentScale : kscale)
  kstarts[] onsetaccum   kwhens, init:k(abs(i(korndur))), 0
  kstartval =  tempodur_k(koriginal[1]) ; I think this is always overwritten... could be removed?
  kdurval   =  (korndur < 0 ? abs(korndur) - kstartval : koriginal[2]) ;if orndur is negative, then generated note durs converge to abs(orndur) - startval.
  kampval   =  koriginal[3]
  kpitval   =  koriginal[4]
  kdurndx   init      0
  kampndx   init      0
  kpitndx   init      0
  
  ;using this modulo purely to save on lots of conditionals
  ;the values are ignored if greater than iplen anyway
  kp6ndx    init      0  
  kp6val   =  koriginal[5 % iplen]
  kp7ndx    init      0
  kp7val   =  koriginal[6 % iplen]
  kp8ndx    init      0
  kp8val   =  koriginal[7 % iplen]
  kp9ndx    init      0
  kp9val   =  koriginal[8 % iplen]
  kp10ndx    init      0
  kp10val   =  koriginal[9 % iplen]

  until     (kndx >= lenarray(kstarts)) do
    kstartval =  tempodur_k(kstarts[kndx])

    if (korndur < 0) then
    kdurval = abs(korndur) - kstartval
    else
    kdurndx = kndx % lenarray(kdurs)
    kdurval   +=        tempodur_k(kdurs[kdurndx])
    endif

    kampndx = kndx % lenarray(kamps)
    kampval   +=        kamps[kampndx]
    kpitndx = kndx % lenarray(kintervals)
    kpitval   +=        kintervals[kpitndx]

    
    if (kpitbound != 0) then
       kdirection sumarray kintervals
       kboundlimit = abs(kpitbound)
       if (kdirection < 0) then
          kupper = maxarray2(kintervals) + koriginal[4]
          klower = koriginal[4] - kboundlimit
       elseif (kdirection > 0) then
          kupper = koriginal[4] + kboundlimit
          klower = minarray2(kintervals) + koriginal[4]
       else
          kupper = koriginal[4] + kboundlimit
          klower = koriginal[4] - kboundlimit
       endif
       if (kpitbound < 0) then
          kpitvalb wrap kpitval, klower, kupper
       elseif (kpitbound > 0) then
          kpitvalb mirror kpitval, klower, kupper
       endif
    else
       kpitvalb = kpitval
    endif


    if (iplen == 5) then
    event     "i", koriginal[0], kstartval, (kdurval <= 0.0001 ? 0.0001 : kdurval), \
                  (kampval < 0 ? 0 : kampval), cpstun(1, kpitvalb, kscale)
    kgoto break
    endif
    kp6ndx = kndx % lenarray(kp6)
    kp6val    +=        kp6[kp6ndx]
    if (iplen == 6) then        
    event     "i", koriginal[0], kstartval, (kdurval <= 0.0001 ? 0.0001 : kdurval), \
                  (kampval < 0 ? 0 : kampval), cpstun(1, kpitvalb, kscale), \
                   kp6val
    kgoto break
    endif
    kp7ndx = kndx % lenarray(kp7)
    kp7val    +=        kp7[kp7ndx]
    if (iplen == 7) then
    event     "i", koriginal[0], kstartval, (kdurval <= 0.0001 ? 0.0001 : kdurval), \
                  (kampval < 0 ? 0 : kampval), cpstun(1, kpitvalb, kscale), \
                   kp6val, kp7val
    kgoto break
    endif
    kp8ndx = kndx % lenarray(kp8)
    kp8val    +=        kp8[kp8ndx]
    if (iplen == 8) then
    event     "i", koriginal[0], kstartval, (kdurval <= 0.0001 ? 0.0001 : kdurval), \
                  (kampval < 0 ? 0 : kampval), cpstun(1, kpitvalb, kscale), \
                   kp6val, kp7val, kp8val
    kgoto break
    endif
    kp9ndx = kndx % lenarray(kp9)
    kp9val    +=        kp9[kp9ndx]
    if (iplen == 9) then
    event     "i", koriginal[0], kstartval, (kdurval <= 0.0001 ? 0.0001 : kdurval), \
                  (kampval < 0 ? 0 : kampval), cpstun(1, kpitval, kscale), \
                   kp6val, kp7val, kp8val, kp9val
    kgoto break
    endif

    kp10ndx = kndx % lenarray(kp10)
    kp10val    +=        kp10[kp10ndx]
    if (iplen == 10) then
    event     "i", koriginal[0], kstartval, (kdurval <= 0.0001 ? 0.0001 : kdurval), \
                  (kampval < 0 ? 0 : kampval), cpstun(1, kpitvalb, kscale), \
                   kp6val, kp7val, kp8val, kp9val, kp10val
    endif
   
    break:
    kndx      +=        1
  od
  konce = 1
  terminate:
endop

;ornament interface opcodes
;2 arrays and constant (i) rhythm
opcode ornament, 0, k[]ik[]OOO
  koriginal[], \
  iwhens, kintervals[], \
  kpitbound, korndur, kscale xin
  ornmaster koriginal, array(iwhens), array(0), array(0), kintervals, array(0), array(0), array(0), array(0), array(0), kpitbound, korndur, kscale
endop

;3 arrays = original, whens, intervals only, durs and amps constant
opcode ornament, 0, k[]k[]k[]OOO
  koriginal[], \
  kwhens[], kintervals[], \
  kpitbound, korndur, kscale xin
  ornmaster koriginal, kwhens, array(0), array(0), kintervals, array(0), array(0), array(0), array(0), array(0), kpitbound, korndur, kscale
endop

;4 arrays = original, whens, amps, intervals only - durs are constant
opcode ornament, 0, k[]k[]k[]k[]OOO
  koriginal[], \
  kwhens[], kamps[], kintervals[], \
  kpitbound, korndur, kscale xin
  ornmaster koriginal, kwhens, array(0), kamps, kintervals, array(0), array(0), array(0), array(0), array(0), kpitbound, korndur, kscale
endop

;p5
opcode ornament, 0, k[]k[]k[]k[]k[]OOO
  koriginal[], \
  kwhens[], kdurs[], kamps[], kintervals[], \
  kpitbound, korndur, kscale xin
  ornmaster koriginal, kwhens, kdurs, kamps, kintervals, array(0), array(0), array(0), array(0), array(0), kpitbound, korndur, kscale
endop


;p6
opcode ornament, 0, k[]k[]k[]k[]k[]k[]OOO
  koriginal[], \
  kwhens[], kdurs[], kamps[], kintervals[], kp6[], \
  kpitbound, korndur, kscale xin
  ornmaster koriginal, kwhens, kdurs, kamps, kintervals, kp6, array(0), array(0), array(0), array(0), kpitbound, korndur, kscale
endop

;p7
opcode ornament, 0, k[]k[]k[]k[]k[]k[]k[]OOO
  koriginal[], \
  kwhens[], kdurs[], kamps[], kintervals[], kp6[], kp7[], \
  kpitbound, korndur, kscale xin
  ornmaster koriginal, kwhens, kdurs, kamps, kintervals, kp6, kp7, array(0), array(0), array(0), kpitbound, korndur, kscale
endop

;p8
opcode ornament, 0, k[]k[]k[]k[]k[]k[]k[]k[]OOO
  koriginal[], \
  kwhens[], kdurs[], kamps[], kintervals[], kp6[], kp7[], kp8[], \
  kpitbound, korndur, kscale xin
  ornmaster koriginal, kwhens, kdurs, kamps, kintervals, kp6, kp7, kp8, array(0), array(0), kpitbound, korndur, kscale
endop

;p9
opcode ornament, 0, k[]k[]k[]k[]k[]k[]k[]k[]k[]OOO
  koriginal[], \
  kwhens[], kdurs[], kamps[], kintervals[], kp6[], kp7[], kp8[], kp9[], \
  kpitbound, korndur, kscale xin
  ornmaster koriginal, kwhens, kdurs, kamps, kintervals, kp6, kp7, kp8, kp9, array(0), kpitbound, korndur, kscale
endop

;p10
opcode ornament, 0, k[]k[]k[]k[]k[]k[]k[]k[]k[]k[]OOO
  koriginal[], \
  kwhens[], kdurs[], kamps[], kintervals[], kp6[], kp7[], kp8[], kp9[], kp10[], \
  kpitbound, korndur, kscale xin
  ornmaster koriginal, kwhens, kdurs, kamps, kintervals, kp6, kp7, kp8, kp9, kp10, kpitbound, korndur, kscale
endop



opcode chordal, 0, k[]k[]opO
;quick chords. koriginal holds the pfields on an event. (limit of 10 pfields)
;kintervals specifies concurrant pitches with that event. 
;idur specifies durastions of the new events
;iampfac is a multiplier for p4 (assumed to be amplitude)
;used cpstun for pitches, with scale specified by kscale (defaults to gi_CurrentScale)
koriginal[],kintervals[],idur,iampfac,kscale xin
  kndx      init      0                           
  konce     init      0  
  ckgoto    (konce == 1), terminate     ; one pass

  kscale    =  (kscale == 0 ? gi_CurrentScale : kscale)
  kpitval init 0
  ilen lenarray kintervals
  iplen lenarray koriginal

  kdur    =  (idur == 0 ? koriginal[2] : idur)

  until     (kndx >= ilen) do
    kpitval   =  koriginal[4] + kintervals[kndx]
    if (iplen == 5) then
      event     "i", koriginal[0], tempodur_k(koriginal[1]), tempodur_k(kdur), koriginal[3]*iampfac,\
                      cpstun(1,kpitval,kscale)
    elseif (iplen == 6) then
      event     "i", koriginal[0], tempodur_k(koriginal[1]), tempodur_k(kdur), koriginal[3]*iampfac,\
                      cpstun(1,kpitval,kscale), koriginal[5]
    elseif (iplen == 7) then
      event     "i", koriginal[0], tempodur_k(koriginal[1]), tempodur_k(kdur), koriginal[3]*iampfac,\
                      cpstun(1,kpitval,kscale), koriginal[5], koriginal[6]
    elseif (iplen == 8) then
      event     "i", koriginal[0], tempodur_k(koriginal[1]), tempodur_k(kdur), koriginal[3]*iampfac,\
                      cpstun(1,kpitval,kscale), koriginal[5], koriginal[6], koriginal[7]
    elseif (iplen == 9) then
      event     "i", koriginal[0], tempodur_k(koriginal[1]), tempodur_k(kdur), koriginal[3]*iampfac,\
                      cpstun(1,kpitval,kscale), koriginal[5], koriginal[6], koriginal[7], koriginal[8]
    elseif (iplen == 10) then
      event     "i", koriginal[0], tempodur_k(koriginal[1]), tempodur_k(kdur), koriginal[3]*iampfac,\
                      cpstun(1,kpitval,kscale), koriginal[5], koriginal[6], koriginal[7], koriginal[8], koriginal[9]
    endif

  kndx      +=        1
  od

  konce = 1
  terminate:

endop

opcode arpeggiates, 0, k[]k[]k[]opo
;spreads notes in a chord by a time interval. 
;koriginal holds pfields of an event.
;kintervals are pitches aobve or below p5 in koriginal
;konsets are time intervals following p2 in koriginal.
;idur has 3 modes: idur = 0 (default) gives each note the value in the event.
;                  idur > 0 all notes expire at the same time: When the original event duration + idur is reached  
;                  negative idur makes a monophonic arpeggiation. durations are cut short so they don't overlap.
;ionsetfac compresses or expands the onset times of the arpeggiation. default is 1 (no compression)
;          negative ionset reduces or expands onset times throughout the duration of an arpeggiation. For example, -0.5 causes
;          an accelerando doubling tempo of notes by p3. A value of -1.5 halves the tempo. -1.0 leaves the tempo unchanged.   
;iampfac, applies a power curve to  p4 values throughout the duration of the arpeggiation.
;         positive values reduce p4 to zero (e.g. fade out).  
;         negative values increase p4 from zero to 1 (e.g. fade in).
;         Steepness of the curve increases as iampfac approaches 1 (or -1).
;         expected range is 0 to +-1, default is 0 (no modification applied).
  koriginal[],kintervals[],konsets[],idur, ionsetfac, iampfac xin
  kndx      init      0                           
  konce     init      0  
  ckgoto    (konce == 1), terminate

  kscale init gi_CurrentScale

  kpitval init 0

  klen lenarray kintervals
  iplen lenarray koriginal
  konsetlength lenarray konsets

  kdur    init 0
  konset init 0
  konsetprogress init 0
  knextonset init 0


  ; initialise kampfac: negative values == fade in, + == fade out, 0 == no change
  kampmode init iampfac
  if (iampfac == 0) then
  kampfac init 1
  elseif (iampfac < 0) then
  kampfac init 0
  else
  kampfac init 1
  endif

  if (ionsetfac < 0) then
      konsetfac init 1
      kaccelmode init 1
  else
      konsetfac init ionsetfac
      kaccelmode init 0
  endif

 ;;BEGIN LOOP
  until (konset > p3) do

  kpitval   =  koriginal[4] + kintervals[kndx % klen]

  if (idur == 0) then
  kdur      =  koriginal[2]
  konset    =  konset + konsets[kndx % konsetlength] * konsetfac
  elseif (idur > 0) then
  konset    =  konset + konsets[kndx % konsetlength] * konsetfac
  kdur      =  idur - konset
  else      
  konset    =  konset + konsets[kndx % konsetlength] * konsetfac
  knextonset   =      konset + konsets[(kndx + 1) % konsetlength] * konsetfac
  kdur      =  knextonset - konset
  endif

  karg1 = koriginal[0]
  karg2 = tempodur_k(koriginal[1] + konset)
  karg4 = koriginal[3]*kampfac
  if (iplen == 5) then
  lazyvent karg1, karg2, kdur, karg4, kpitval
  ;event "i", karg1, karg2, kdur, karg4, cpstun(1, kpitval, gi_CurrentScale)
  elseif (iplen == 6) then
  karg6 = koriginal[5]
  lazyvent karg1, karg2, kdur, karg4, kpitval, karg6
  ;event "i", karg1, karg2, kdur, karg4, cpstun(1, kpitval, gi_CurrentScale), karg6
  elseif (iplen == 7) then
    karg6 = koriginal[5]
    karg7 = koriginal[6]
  lazyvent karg1, karg2, kdur, karg4, kpitval, karg6, karg7
  ;event "i", karg1, karg2, kdur, karg4, cpstun(1, kpitval, gi_CurrentScale), karg6, karg7
  elseif (iplen == 8) then
  karg6 = koriginal[5]
  karg7 = koriginal[6]
  karg8 = koriginal[7]
  lazyvent karg1, karg2, kdur, karg4, kpitval, karg6, karg7, karg8
  ;event "i", karg1, karg2, kdur, karg4, cpstun(1, kpitval, gi_CurrentScale), karg6, karg7, karg8
  elseif (iplen == 9) then
  karg6 = koriginal[5]
  karg7 = koriginal[6]
  karg8 = koriginal[7]
  karg9 = koriginal[8]
  lazyvent karg1, karg2, kdur, karg4, kpitval, karg6, karg7, karg8, karg9
  ;event "i", karg1, karg2, kdur, karg4, cpstun(1, kpitval, gi_CurrentScale), karg6, karg7, karg8, karg9
  elseif (iplen == 10) then
  karg6 = koriginal[5]
  karg7 = koriginal[6]
  karg8 = koriginal[7]
  karg9 = koriginal[8]
  karg10 = koriginal[9]
  lazyvent karg1, karg2, kdur, karg4, kpitval, karg6, karg7, karg8, karg9, karg10
  ;event "i", karg1, karg2, kdur, karg4, cpstun(1, kpitval, gi_CurrentScale), karg6, karg7, karg8, karg9, karg10
  elseif (iplen == 11) then
  karg6 = koriginal[5]
  karg7 = koriginal[6]
  karg8 = koriginal[7]
  karg9 = koriginal[8]
  karg10 = koriginal[9]
  karg11 = koriginal[10]
  lazyvent karg1, karg2, kdur, karg4, kpitval, karg6, karg7, karg8, karg9, karg10, karg11
  ;event "i", karg1, karg2, kdur, karg4, cpstun(1, kpitval, gi_CurrentScale), karg6, karg7, karg8, karg9, karg10, karg11
  elseif (iplen == 12) then
  karg6 = koriginal[5]
  karg7 = koriginal[6]
  karg8 = koriginal[7]
  karg9 = koriginal[8]
  karg10 = koriginal[9]
  karg11 = koriginal[10]
  karg12 = koriginal[11]
  lazyvent karg1, karg2, kdur, karg4, kpitval, karg6, karg7, karg8, karg9, karg10, karg11, karg12
  ;event "i", karg1, karg2, kdur, karg4, cpstun(1, kpitval, gi_CurrentScale), karg6, karg7, karg8, karg9, karg10, karg11, karg12
  endif

  enddo:

  konsetprogress = (konset/p3)

  if (kampmode == 0) then

  kampfac = 1

  elseif (kampmode > 0) then

    if (kampmode > 0.5) then
      kampfac pow (1 - konsetprogress), rescalek(kampmode, 0, 1, 1, 5), 1
    else
      kampfac pow (1 - konsetprogress), (kampmode * 2), 1
    endif

  else

    if (abs(kampmode) > 0.5) then
      kampfac pow konsetprogress, rescalek(abs(kampmode), 0, 1, 1, 5), 1
    else
      kampfac pow konsetprogress, (abs(kampmode) * 2), 1
    endif

  endif
 
  if (kaccelmode == 1) then
     konsetfac = (1 - (konsetprogress * (1 - abs(ionsetfac))))
  endif
  kndx      +=        1
  od

  konce = 1
  terminate:

endop


opcode declick, a, ajjo

ain, irisetime, idectime, itype xin
irisetm = (irisetime == -1 ? 0.0001 : irisetime)
idectm = (idectime == -1 ? 0.05 : idectime)
aenv    transeg 0.0001, irisetm, itype, 1, p3 - (irisetm + idectm), 0, 1, idectm, itype, 0.0001
        xout ain * aenv         ; apply envelope and write output
endop

opcode declickr, a, ajjo
aenv init 1
tigoto tiskip
ain, irisetime, idectime, itype xin
irisetm = (irisetime == -1 ? 0.003 : irisetime)
idectm = (idectime == -1 ? 0.08 : idectime)
aenv    transegr 0, irisetm, itype, 1, 0, 0, 1, idectm, itype, 0
tiskip:
        xout ain * aenv         ; apply envelope and write output
endop

opcode declickrst, aa, aajjo
aenv init 1
tigoto tiskip
ainL, ainR, irisetime, idectime, itype xin
irisetm = (irisetime == -1 ? 0.003 : irisetime)
idectm = (idectime == -1 ? 0.08 : idectime)
aenv    transegr 0, irisetm, itype, 1, 0, 0, 1, idectm, itype, 0
tiskip:
        xout ainL * aenv, ainR * aenv         ; apply envelope and write output
endop

;buzzy brass sounds
opcode dfma, a,kkk
kamp, kcps, kmod xin
kmod limit kmod, 0, 1.15 ; can blow up Csound beyond this.
k1 = kmod*0.78
ksq            =         k1*k1
kmp            =         -2*k1
k2             =         1+ksq
a2             gbuzz     kmp, kcps,3,1,k1*3, gi_cosine
a2 *= linseg(0,0.05,1)
a2 buthp a2, 20
a3             =         a2+k2
k3             =         sqrt((1-ksq)/(1+ksq))              ; AMP NORM. FUNC.
a1             oscili    k3,kcps
kshifter rspline -1 * kmod, kmod, (kmod + 1)*3, (kmod + 1) * 7
a3		pdhalfy	 a3, kshifter * 0.8, 0, 1
a3             =         a1/a3
a3 *= linseg(0,0.05,1)
asig           =         kamp*a3
xout asig
endop

opcode dfmb, a,kkk
kamp, kcps, kmod xin
kmod limit kmod, 0, 1.25
k1 = kmod*0.78
ksq            =         k1*k1
kmp            =         -2*k1
k2             =         1+ksq
knh = ceil((curvek(kmod, 0.9) * 10) + 1)
a2             buzz     kmp, kcps,knh,gi_sine
a2 buthp a2, 20

a3             =         a2+k2
k3             =         sqrt((1-ksq)/(1+ksq))              ; AMP NORM. FUNC.
a1             oscili    k3,kcps
a3             =         a1/a3
kshifter rspline -1 * kmod, kmod, (kmod + 1)*3, (kmod + 1) * 7
a3 pdclip a3, k1*0.8, limit:k(kshifter, -1, 1), 1, 0.8
asig           =         kamp*a3
xout asig
endop


;Modified from Eric Lyons Reverb 1
opcode LyonRev1, aa,aakk
ain1, ain2, kmix, krevlen xin
  ;korig = 0.78 ; mix param
  kgain = limit:k(kmix, 0.13, 1)
  krev = 1 - kmix

  ain1 = ain1*kgain
  ain2 = ain2*kgain
  
  ajunk valpass ain1,1.7 * krevlen,oscil:k(0.003, 0.15) + 0.11, 0.3
  aleft valpass ajunk,1.01 * krevlen,oscil:k(0.0031, 0.11) + 0.0701, 0.1
  ajunk valpass ain2,1.05 * krevlen,oscil:k(0.0022, 0.28) + 0.205, 0.35
  aright valpass ajunk,1.33 * krevlen,oscil:k(0.0016, 0.341) + 0.05, 0.1
  
  kdel1 jspline 0.01, 0.555, 0.777
  kdel1 += 0.03
  kdel1b jspline 0.01, 0.555, 0.777
  kdel1b += 0.03

  addl1 delayr 0.3
  afeed1 deltap3 kdel1
  
  afeed1b deltap3 kdel1b
  
  afeed1 = (afeed1 + afeed1b) + (aleft*0.767)
  delayw aleft
  
  kdel2 jspline 0.01, 0.0555, 0.0877
  kdel2 += 0.02
  kdel2b jspline 0.01, 0.555, 0.777
  kdel2b += 0.03
  
  addl2 delayr 0.3
  afeed2 deltap3 kdel2

  afeed2b deltap3 kdel2b
  
  afeed2 = (afeed2 + afeed2b) + (aright*0.767)
  delayw aright
  
  aglobin = (afeed1+afeed2)*krev*0.5
  atap1 combinv aglobin,0.001,0.0909090909
  atap2 combinv aglobin,0.0021,0.04348
  atap3 combinv aglobin,0.0033,0.02439
  
  aglobrev nestedap atap1+atap2+atap3, 3, 1, 0.063, 0.11, 0.0027, 0.09, 0.0021, 0.07
  
  aglobrev tone aglobrev, 900
  
  kdel3 randi .003,1,0.888
  kdel3 =kdel3 + .05
  addl3 delayr .2
  agr1 deltap3 kdel3
  delayw aglobrev

  kdel4 randi .003,1,0.999
  kdel4 = kdel4 + 0.05
  addl4 delayr 0.2
  agr2 deltap3 kdel4
  delayw aglobrev
  
  arevl = agr1+afeed1
  arevr = agr2+afeed2
  aoutl = (ain1*kmix)+(arevl*krev)
  aoutr = (ain2*kmix)+(arevr*krev)
xout aoutl, aoutr
endop

;Modified from ACCI bell piano
opcode bellpno,a,kiipp
  kamp, ifrq, imod,ir1,ir2 xin

  ifq2   = ifrq*ir1
  ifq1   = ifrq*ir2          

  kvib vibr linseg:k(0, 0.45, 0, 0.01, 4), 5, -1

  aenv transeg 1, p3-0.01, -ir1, 0.01
  adyn  transeg ifq2*imod, p3, -ir1, 0.1
  
  amod  oscili  adyn, ifq2, gimodfn
  a1    oscili  kamp*aenv, (ifq1+amod) + kvib, gicarfn

xout a1
endop

opcode padoscilst, aa,kkki
  kamp, kcps, kwidth, iwave xin
  ;aL, aR padoscil kamp, kcps, kwidth(0 - 1), iwave(0-4,-5)

  ; FM depth in Hz
  kfmd1	=  expcurve(kwidth, 15) * 0.25 * kcps  

  kfnum vco2ft kcps, iwave

  ;ares oscbnk   kcps, kamd, kfmd, kpmd, iovrlap, iseed, kl1minf, kl1maxf, kl2minf, kl2maxf, ilfomode, keqminf, keqmaxf, keqminl, keqmaxl, keqminq, keqmaxq, ieqmode, kfn [, il1fn] [, il2fn] [, ieqffn] [, ieqlfn] [, ieqqfn] [, itabl] [, ioutfn]
  a1    oscbnk   kcps, 1.0,  kfmd1, 0,   45,      200,   0.1,     6.7,     0.15,     0.8,       132,      0.1,       0.3,      0,       0,       0,       0,     -1,       kfnum, -1,        -1
  a2    oscbnk   kcps, 1.0,  kfmd1, 0,   45,      12,   0.1,     6.7,     0.17,     0.8  ,     132,      0.1,       0.3,      0,       0,       0,       0,     -1,       kfnum, -1,        -1

  if (iwave == 0) then
    iwvscale = 0.08
  elseif (iwave == 1) then
    iwvscale = 0.17
  elseif (iwave == 2) then
    iwvscale = 0.0051
  elseif (iwave == 3) then
    iwvscale = 0.05
  else 
    iwvscale = 0.1
  endif

  aoutL	=  a1 * iwvscale * kamp
  aoutR	=  a2 * iwvscale * kamp

  xout aoutL, aoutR

endop


opcode padoscil, a,kkkij
  kamp, kcps, kwidth, iwave, iovrlap xin
  ;ares padoscil kamp, kcps, kwidth(0 - 1), iwave(0-4,-5)

  iovrlap = (iovrlap == -1 ? 45 : iovrlap)

  ; FM depth in Hz
  kfmd1	=  expcurve(kwidth, 15) * 0.25 * kcps  
  kfnum vco2ft kcps, iwave

  ;ares oscbnk   kcps, kamd, kfmd, kpmd, iovrlap, iseed, kl1minf, kl1maxf, kl2minf, kl2maxf, ilfomode, keqminf, keqmaxf, keqminl, keqmaxl, keqminq, keqmaxq, ieqmode, kfn [, il1fn] [, il2fn] [, ieqffn] [, ieqlfn] [, ieqqfn] [, itabl] [, ioutfn]
  a1    oscbnk   kcps, 1.0,  kfmd1, 0,   iovrlap,      200,   0.1,     6.7,     0.15,     0.8,       132,      0.1,       0.3,      0,       0,       0,       0,     -1,       kfnum, -1,        -1

  if (iwave == 0) then
    iwvscale = 0.08
  elseif (iwave == 1) then
    iwvscale = 0.17
  elseif (iwave == 2) then
    iwvscale = 0.0051
  elseif (iwave == 3) then
    iwvscale = 0.05
  else 
    iwvscale = 0.1
  endif

  aout	=  a1 * iwvscale * kamp

xout aout

endop



opcode basswobbler, a,kkk
kamp, kcps, krate xin

  adeclick envlpxr 1, 0.002, 0,  gienvlpxrrise, 1, 0.01

  kwobbler = oscil3(0.5, krate) + 0.5
  ares1      gbuzz    kamp, kcps + jspline:k(kcps*0.00625, 0.2, 7.7), 8, 1, kwobbler, gi_cosine
  ares2      gbuzz    kamp, (kcps/2) + jspline:k(kcps*0.00625, 2.5, 3), 8, 2, kwobbler, gi_cosine
  ares3 distort ares1, (kwobbler + 0.1) * 2.3, gi_cubicb
  ares = (ares1 + (ares2 * 2) + ares3)
  ares = ares * adeclick

xout ares
endop

opcode bassUV, a, kKVVj
kamp, kfrq, kbw, ksep, inum xin

  ksep limit ksep, 0, 1

  inum = ((inum == -1) ? 5:inum)

  ipit = i(kfrq)

  kenv = xadsr(0.015, 0.01, 1, 0.03)*kamp
  asig1    pluck     kenv, kfrq, ipit*4, 0, 4, 0.5, 99
  asig2 vco2 kenv, kfrq, 12

  asig = asig1 + (asig2 * 0.17)

  krespit expseg ipit*4, 1.7, ipit*0.25, p3, ipit*4.25

  af resony asig, krespit, krespit*expcurve(kbw, 48), inum, (logcurve(ksep, 0.01))*20
  aout    balance af, asig

xout aout
endop


instr 1
;private instrument, instantiated by trigger only
;but seems to crash every now and then
turnoff2, p4, 0, 1
turnoff
endin

instr 2
gk_now += (gk_tempo / 60) / kr
endin
event_i "i", 2, 0, -1 

instr 3
;for use by the linslide opcode
Schan = p4
idest = p5
itype = p6
icurrent chnget Schan

if (itype == 0) then
kres linseg icurrent, p3, idest
elseif (itype == 1) then
kres expseg (icurrent == 0 ? 0.0001:icurrent), p3, (idest == 0 ? 0.0001:idest)
else
kres = icurrent
endif

chnset kres, Schan

endin

;lazyvent spawns this, so globals (scale and tempo) are caught at the time the event
;runs, not when scheduled.
instr 4
pset p1, p2, p3, p4, p5, p6, -99999, -99999, -99999, -99999, -99999, -99999


if (p7 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(p6, gi_CurrentScale)
elseif (p8 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(p6, gi_CurrentScale), p7
elseif (p9 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(p6, gi_CurrentScale), p7, p8
elseif (p10 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(p6, gi_CurrentScale), p7, p8, p9
elseif (p11 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(p6, gi_CurrentScale), p7, p8, p9, p10
elseif (p12 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(p6, gi_CurrentScale), p7, p8, p9, p10, p11
else
schedule p4, 0, tempodur(p3), p5, cpstuni(p6, gi_CurrentScale), p7, p8, p9, p10, p11, p12
endif

endin


instr 5
pset p1, p2, p3, p4, p5, p6, -99999, -99999, -99999, -99999, -99999, -99999

if (p7 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(giTonic_ndx + p6, gi_CurrentScale)
elseif (p8 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(giTonic_ndx + p6, gi_CurrentScale), p7
elseif (p9 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(giTonic_ndx + p6, gi_CurrentScale), p7, p8
elseif (p10 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(giTonic_ndx + p6, gi_CurrentScale), p7, p8, p9
elseif (p11 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(giTonic_ndx + p6, gi_CurrentScale), p7, p8, p9, p10
elseif (p12 == -99999) then
schedule p4, 0, tempodur(p3), p5, cpstuni(giTonic_ndx + p6, gi_CurrentScale), p7, p8, p9, p10, p11
else
schedule p4, 0, tempodur(p3), p5, cpstuni(giTonic_ndx + p6, gi_CurrentScale), p7, p8, p9, p10, p11, p12
endif

endin

;;compile instrument, used for generating CSD output.
instr 6

Seval = p4

icompiled compilestr Seval

if (icompiled == 0) then
   printf_i "Compiled: %s\n", 1, Seval
else
   printf_i "!!!Did not compile: %s\n", 1, Seval
endif

endin

;might need to do this to stop a performace.
;scheduled loops may never end.
instr 7

exitnow

endin

instr 8

Seval = strget(p4)
icompiled compilestr Seval

if (icompiled == 0) then
   printf_i "Compiled at time %f: %s\n", 1, p2, Seval
else
   printf_i "!!!Did not compile at time %f: %s\n", 1, p2, Seval
endif

endin

instr 300

if (gk_off == p1) then
   gk_off init 0
   turnoff 
endif

ainL chnget "outputL"
ainR chnget "outputR"
ainCtr chnget "outputC"
ainL += (ainCtr * 0.87)
ainR += (ainCtr * 0.87)

arevL, arevR reverbsc ainL, ainR, 0.15, sr/2, sr, 0.1, 1

ainL = (ainL * 0.4) + arevL
ainR = (ainR * 0.4) + arevR

;ainL compress ainL, ainL, 0, 58, 75, 5.3, 0.05, 0.1, 0.1
;ainR compress ainR, ainR, 0, 58, 55, 5.3, 0.05, 0.1, 0.1

ablank init 1
ainL compress ainL, ablank, 0, 77, 90, 2.5, 0.05, 0.1, 0.1
ainR compress ainR, ablank, 0, 77, 90, 2.5, 0.05, 0.1, 0.1


;ainL = ainL*2.8
;ainR = ainR*2.8

ainL clip ainL, 0, 0.99, 0.8
ainR clip ainR, 0, 0.99, 0.8

;ainL = taninv(taninv(ainL))
;ainR = taninv(taninv(ainR))

kmasterLevel chnget "MasterLevel"
 
outs ainL*kmasterLevel, ainR*kmasterLevel

chnclear "outputL"
chnclear "outputR"
chnclear "outputC"

endin


event_i "i", 300, 0, -1
printf_i "finished loading SetupLib %f\n", 1, 1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;   The Pungent Garden. Thorin Kerr 2018
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gi94edo TBedn 94, 263, 0
gi_SuperScale = gi94edo

gi94Tkerr[] array 16,14,13,12,11,10,9, 9

scalemode  gi_SuperScale, 0, gi94Tkerr

temposet 70

instr 101

  intens = p6
  kline linseg 0.1, p3*0.6667, intens, p3*0.3333, 0.1
  
  aresL dfma p4*0.5, p5, kline;kamp, kcps, ktone
  aresR dfma p4*0.5, p5, kline;kamp, kcps, ktone

  aresL, aresR declickrst aresL, aresR, 0.1, 2
  chnmix aresL*0.3, "rev1"
  chnmix aresR*0.3, "rev1"

  chnmix aresL*0.3, "outputL"
  chnmix aresR*0.3, "outputR"
  
endin


instr 102

ares bellpno p4*0.4, p5, p6, p7, p8;kamp, ifrq, imod [, ir1, ir2]
  
  ares declickr ares
  
  chnmix ares, "outputC"
endin


instr 103

ares bellpno p4*0.4, p5, p6, p7, p8;kamp, ifrq, imod [, ir1, ir2]
  
  ares declickr ares
  
  ;ares *= lineto(expcurve((1/active:k(p1)),0.11), 0.01) ;amp control
  chnmix ares, "outputC"
endin



instr 202
  ain chnget "rev1"
  aresL, aresR LyonRev1 ain, ain, chnget:k("revmix"), chnget:k("revlen")
  
  aresL, aresR declickrst aresL, aresR, 2,2
  chnmix aresL, "outputL"
  chnmix aresR, "outputR"
  chnclear "rev1"
endin

schedule 202, nextbeat(1), -1

linslide "revlen", 3, 7;idur, idest, [istart, itype]
linslide "revmix", 30, 0.2;idur, idest, [istart, itype]

schedule 101, 0, 3, 0.6, cpstuni(7, gi_CurrentScale)

instr 105

if (active:k(p1) > 1) then
              if (timeinstk() > ksmps) then
              turnoff
              endif
           endif
  
  ares basswobbler p4, p5, p6;kamp, kcps, krate

  
ares declickr ares, 0.0001, 0.01
aenv transeg 1,p3*0.75,-1.7,0.2,p3*0.24,1,0
ares *= aenv
  chnmix ares, "outputC"

endin

instr 109

if (active:k(p1) > 1) then
              if (timeinstk() > ksmps) then
              turnoff
              endif
           endif
  
  ares basswobbler p4, p5, p6;kamp, kcps, krate

  
ares declickr ares, 0.0001, 0.01
aenv transeg 1,p3*0.75,-1.7,0.2,p3*0.24,1,0
ares *= aenv
  chnmix ares, "outputC"

endin

instr 106

aresL, aresR padoscilst p4, p5, p6, p7;kamp, kcps, kwidth(0 - 1), iwave(0-4,-5)  
;ares padoscil p4, p5, p6, p7;kamp, kcps, kwidth(0 - 1), iwave(0-4,-5)  

aresL, aresR  declickrst aresL, aresR, 1, 2; [, irisetime, idectime, itype]
  ;aresL *= lineto(expcurve((1/active:k(p1)),0.11), 0.01) ;amp control
  ;aresR *= lineto(expcurve((1/active:k(p1)),0.11), 0.01) ;amp control
  
;ares declickr ares, 1, 1
;aresR declickr aresR, 1, 1
chnmix aresL, "outputL"
chnmix aresR, "outputR"
;chnmix ares, "outputC"
  
endin



strset, 176, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,0,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,1,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.27, 1), array(iseb, 0, 1, 2,3, 5, 4,6,iseb+8, 8)
chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.22, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
;schedule p1, nextbeat(p3), tempodur(iterArr(array(6,2), strget(6)))
  
turnoff
endin
}}
strset, 175, {{
schedule 15, nextbeat(1), tempodur(20)

}}
strset, 174, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,0,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,1,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.27, 1), array(iseb, 0, 1, 2,3, 5, 4,6,iseb+8, 8)
chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.22, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,2), strget(6)))
  
turnoff
endin
}}
strset, 173, {{
instr 11
scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,0,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,1,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.27, 1), array(iseb, 0, 1, 2,3, 5, 4,6,iseb+8, 8)
chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.22, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,2), strget(6)))
  
turnoff
endin
}}
strset, 172, {{
instr 11
scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,0,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,1,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.17, 1), array(iseb, 0, 1, 2,3, 5, 4,6,iseb+8, 8)
chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.22, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,2), strget(6)))
  
turnoff
endin
}}
strset, 171, {{
instr 11
scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,0,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,1,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.07, 1), array(iseb, 0, 1, 2,3, 5, 4,6,iseb+8, 8)
chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.22, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,2), strget(6)))
  
turnoff
endin
}}
strset, 170, {{
instr 11
scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,0,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,1,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.07, 1), array(iseb, 0, 1, 2,3, 5, 4,6,iseb+8, 8)
chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,2), strget(6)))
  
turnoff
endin
}}
strset, 169, {{
instr 11
scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,0,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.07, 1), array(iseb, 0, 1, 2,3, 5, 4,6,iseb+8, 8)
chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,2), strget(6)))
  
turnoff
endin
}}
strset, 168, {{
schedule 15, nextbeat(1), tempodur(20)

}}
strset, 167, {{
instr 15

ornament array(102, 0, p3, 0.08, giTonic_ndx, 0.1,(3/2),2.05), array(randselect_i(0.25, 0.66, 0.5, 1.333), 0.125, 0.125), array(5,-1, -2), -24, 6

  
;arpeggiates array(102, 0, 3.15, 0.1, giTonic_ndx, 0.1, 1, 3), array(0,2, 4,6,7,6,8), array(0.25), 0, -0.25, -0.5; [,idur, ionsetfac, iampfac]
;arpeggiates array(102, 0, 3.5, 0.1, giTonic_ndx, 0.1, 1, 2), array(8,7,5,6,4,5,3,2,1), array(0.125), 0, -1.25, 0.5; [,idur, ionsetfac, iampfac]
;arpeggiates array(102, p3*0.5, 3.3, 0.14, giTonic_ndx + 2, 0.1, 2, 1), array(8,9,8,9,8,9,10,9), array(0.25), 0, -0.21, -0.2; [,idur, ionsetfac, iampfac]
  
turnoff
endin
}}
strset, 166, {{
instr 11
scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.07, 1), array(iseb, 0, 1, 2,3, 5, 4,6,iseb+8, 8)
chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,2), strget(6)))
  
turnoff
endin
}}
strset, 165, {{
schedule 15, nextbeat(1), tempodur(20)

}}
strset, 164, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/2), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,1), strget(40), 1/3)
  
  
;schedule p1, nextbeat(inb), tempodur(inb)

  
turnoff
endin
}}
strset, 163, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/2), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,1), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 162, {{
instr 15

ornament array(102, 0, p3, 0.08, giTonic_ndx, 0.1,(3/2),2.05), array(randselect_i(0.25, 0.66, 0.5, 1.333), 0.125, 0.125), array(5,-1, -2), -24, 6

  
arpeggiates array(102, 0, 3.15, 0.1, giTonic_ndx, 0.1, 1, 3), array(0,2, 4,6,7,6,8), array(0.25), 0, -0.25, -0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, 0, 3.5, 0.1, giTonic_ndx, 0.1, 1, 2), array(8,7,5,6,4,5,3,2,1), array(0.125), 0, -1.25, 0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, p3*0.5, 3.3, 0.14, giTonic_ndx + 2, 0.1, 2, 1), array(8,9,8,9,8,9,10,9), array(0.25), 0, -0.21, -0.2; [,idur, ionsetfac, iampfac]
  
turnoff
endin
}}
strset, 161, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/2), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,1/2, 1), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 160, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/2), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,1/2, 1/2, 1), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 159, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/2), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,1/2, 1/2, 1), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 158, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/2), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,1/2, 1/2, 1), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 157, {{
schedule 15, nextbeat(1), tempodur(20)

}}
strset, 156, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/4), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,1/2, 1/2, 1), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 155, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,1/2, 1/2, 1), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 154, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,1/2, 1/2, 1), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 153, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,1/2, 1/2, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 152, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/2,2/3, 1/2, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 151, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.03, 1), array(iseb, 0, 1, 2,3, 4,iseb+8, 8)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 150, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.01, 1), array(iseb, 0, 1, 2,3, 4,iseb+8, 8)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 149, {{
instr 13

imult = 5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/3,2/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 148, {{
instr 13

imult = 4  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/3,2/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 147, {{
instr 13

imult = 3  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/3,2/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 146, {{
instr 13

imult = 2  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.25, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/3,2/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 145, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.01, 1), array(iseb, 0, 2,4,iseb+8, 8)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 144, {{
instr 13

imult = 2  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/3,2/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 143, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.01, 1), array(iseb, 0, 2,4,iseb+8)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 142, {{
instr 13

imult = 1.5  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/3,2/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 141, {{
instr 13

imult = 1.2  
schedule 102, 0, p3*imult, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*imult, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*imult, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/3,2/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 140, {{
instr 15

ornament array(102, 0, p3, 0.08, giTonic_ndx, 0.1,(3/2),2.05), array(randselect_i(0.25, 0.66, 0.5, 1.333), 0.125, 0.125), array(5,-1, -2), -24, 4

  
arpeggiates array(102, 0, 3.15, 0.1, giTonic_ndx, 0.1, 1, 3), array(0,2, 4,6,7,6,8), array(0.25), 0, -0.25, -0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, 0, 3.5, 0.1, giTonic_ndx, 0.1, 1, 2), array(8,7,5,6,4,5,3,2,1), array(0.125), 0, -1.25, 0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, p3*0.5, 3.3, 0.14, giTonic_ndx + 2, 0.1, 2, 1), array(8,9,8,9,8,9,10,9), array(0.25), 0, -0.21, -0.2; [,idur, ionsetfac, iampfac]
  
turnoff
endin
}}
strset, 139, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.01, 1), array(iseb, 2,4,iseb+8)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 138, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.01, 1), array(iseb, 2,4)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 137, {{
instr 13

  
schedule 102, 0, p3, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 2, 1
schedule 102, tempodur(1/3), p3*1, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*1, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/3,2/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 136, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.01, 1), array(iseb, 2)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 135, {{
instr 13

  
schedule 102, 0, p3, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*1, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*1, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/3,2/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 134, {{
instr 15

;ornament array(102, 0, p3, 0.08, giTonic_ndx, 0.1,(3/2),2.05), array(randselect_i(0.25, 0.66, 0.5, 1.333), 0.125, 0.125), array(5,-1, -2), -24, 4

  
arpeggiates array(102, 0, 3.15, 0.1, giTonic_ndx, 0.1, 1, 3), array(0,2, 4,6,7,6,8), array(0.25), 0, -0.25, -0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, 0, 3.5, 0.1, giTonic_ndx, 0.1, 1, 2), array(8,7,5,6,4,5,3,2,1), array(0.125), 0, -1.25, 0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, p3*0.5, 3.3, 0.14, giTonic_ndx + 2, 0.1, 2, 1), array(8,9,8,9,8,9,10,9), array(0.25), 0, -0.21, -0.2; [,idur, ionsetfac, iampfac]
  
turnoff
endin
}}
strset, 133, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.01, 1), array(2)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 132, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.02, 1), array(2)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 131, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.07, 1), array(2)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 130, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.1, 1), array(2)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 129, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.14, 1), array(2)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 128, {{
instr 13

  
schedule 102, 0, p3, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*1, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*1, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1/3,2/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 127, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.14, 0), array(2)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 126, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.24, 0), array(2)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 125, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.24, 0.7), array(2)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 124, {{
instr 13

  
schedule 102, 0, p3, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*1, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*1, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/3, 1/6, 1/6, 1/6), strget(40), 1/3)
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 123, {{
schedule 15, nextbeat(1), tempodur(20)

}}
strset, 122, {{
instr 15

;ornament array(102, 0, p3, 0.08, giTonic_ndx, 0.1,(3/2),2.05), array(randselect_i(0.25, 0.66, 0.5, 1.333), 0.125, 0.125), array(5,-1, -2), -24, 4

  
arpeggiates array(102, 0, 3.15, 0.1, giTonic_ndx, 0.1, 1, 3), array(0,2, 4,6,7,6,8), array(0.25), 0, -0.25, -0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, 0, 3.5, 0.1, giTonic_ndx, 0.1, 1, 2), array(8,7,5,6,4,5,3,2,1), array(0.125), 0, -1.25, 0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, p3*0.5, 3.3, 0.14, giTonic_ndx + 2, 0.1, 2, 1), array(8,9,8,9,8,9,10,9), array(0.25), 0, -0.21, -0.2; [,idur, ionsetfac, iampfac]
  
turnoff
endin
}}
strset, 121, {{
instr 13

  
schedule 102, 0, p3, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*1, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*1, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/3, 1/6, 1/6, 1/6), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 120, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.34, 0.7), array(2)
;chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 119, {{
instr 13

  
schedule 102, 0, p3, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*1, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*1, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/3, 1/6, 1/3, 1/6), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 118, {{
instr 13

  
schedule 102, 0, p3, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*1.25, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*1.5, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/3, 1/6, 1/3, 1/6), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 117, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*1.25, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*1.5, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/3, 1/6, 1/3, 1/6), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 116, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*1.5, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/3, 1/6, 1/3, 1/6), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 115, {{
schedule 15, nextbeat(1), tempodur(20)

}}
strset, 114, {{
instr 15

;ornament array(102, 0, p3, 0.08, giTonic_ndx, 0.1,(3/2),2.05), array(randselect_i(0.25, 0.66, 0.5, 1.333), 0.125, 0.125), array(5,-1, -2), -24, 4

  
arpeggiates array(102, 0, 3.15, 0.1, giTonic_ndx, 0.1, 1, 3), array(0,2, 4,6,7,6,8), array(0.25), 0, -0.25, -0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, 0, 3.5, 0.1, giTonic_ndx, 0.1, 1, 2), array(8,7,5,6,4,5,3,2,1), array(0.125), 0, -1.25, 0.5; [,idur, ionsetfac, iampfac]
;arpeggiates array(102, p3*0.75, 3.3, 0.14, giTonic_ndx + 2, 0.1, 2, 1), array(8,9,8,9,8,9,10,9), array(0.25), 0, -0.21, -0.2; [,idur, ionsetfac, iampfac]
  
turnoff
endin
}}
strset, 113, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*2, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/3, 1/6, 1/3, 1/6), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 112, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*2, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/3, 1/3, 1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 111, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.0, giTonic_ndx, 0.22, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 110, {{
schedule 15, nextbeat(1), tempodur(20)

}}
strset, 109, {{
instr 15

;ornament array(102, 0, p3, 0.08, giTonic_ndx, 0.1,(3/2),2.05), array(randselect_i(0.25, 0.66, 0.5, 1.333), 0.125, 0.125), array(5,-1, -2), -24, 4

  
arpeggiates array(102, 0, 3.15, 0.1, giTonic_ndx, 0.1, 1, 3), array(0,2, 4,6,7,6,8), array(0.25), 0, -0.25, -0.5; [,idur, ionsetfac, iampfac]
;arpeggiates array(102, 0, 3.5, 0.1, giTonic_ndx, 0.1, 1, 2), array(8,7,5,6,4,5,3,2,1), array(0.125), 0, -1.25, 0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, p3*0.75, 3.3, 0.14, giTonic_ndx + 2, 0.1, 2, 1), array(8,9,8,9,8,9,10,9), array(0.25), 0, -0.21, -0.2; [,idur, ionsetfac, iampfac]
  
turnoff
endin
}}
strset, 108, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.22, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 107, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/3), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(2/3), p3*2, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/2, 1/2, 1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 106, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.03, giTonic_ndx, 0.22, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 105, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.06, giTonic_ndx, 0.22, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 104, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.1, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 103, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0,-1,-1,0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/2, 1/2, 1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 102, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.12, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 101, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.13, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 100, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.15, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 99, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 8 - iterArr(array(0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/2, 1/2, 1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 98, {{
schedule 15, nextbeat(1), tempodur(20)

}}
strset, 97, {{
instr 15

;ornament array(102, 0, p3, 0.08, giTonic_ndx, 0.1,(3/2),2.05), array(randselect_i(0.25, 0.66, 0.5, 1.333), 0.125, 0.125), array(5,-1, -2), -24, 4

  
;arpeggiates array(102, 0, 3.15, 0.1, giTonic_ndx, 0.1, 1, 3), array(0,2, 4,6,7,6,8), array(0.25), 0, -0.25, -0.5; [,idur, ionsetfac, iampfac]
;arpeggiates array(102, 0, 3.5, 0.1, giTonic_ndx, 0.1, 1, 2), array(8,7,5,6,4,5,3,2,1), array(0.125), 0, -1.25, 0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, p3*0.75, 3.3, 0.1, giTonic_ndx + 2, 0.1, 2, 1), array(8,9,8,9,8,9,10,9), array(0.25), 0, -0.21, -0.2; [,idur, ionsetfac, iampfac]
  
turnoff
endin
}}
strset, 96, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/2, 1/2, 1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 95, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.2, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 94, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.25, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 109, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 93, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1,1/2, 1/2, 1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 92, {{
schedule 15, nextbeat(1), tempodur(20)

}}
strset, 91, {{
instr 15

;ornament array(102, 0, p3, 0.08, giTonic_ndx, 0.1,(3/2),2.05), array(randselect_i(0.25, 0.66, 0.5, 1.333), 0.125, 0.125), array(5,-1, -2), -24, 4

  
;arpeggiates array(102, 0, 3.15, 0.1, giTonic_ndx, 0.1, 1, 3), array(0,2, 4,6,7,6,8), array(0.25), 0, -0.25, -0.5; [,idur, ionsetfac, iampfac]
arpeggiates array(102, 0, 3.5, 0.1, giTonic_ndx, 0.1, 1, 2), array(8,7,5,6,4,5,3,2,1), array(0.125), 0, -1.25, 0.5; [,idur, ionsetfac, iampfac]
;arpeggiates array(102, p3*0.75, 3.3, 0.1, giTonic_ndx + 2, 0.1, 2, 1), array(8,9,8,9,8,9,10,9), array(0.25), 0, -0.21, -0.2; [,idur, ionsetfac, iampfac]
  
turnoff
endin
}}
strset, 90, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 89, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3, 0.3 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 88, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3, 0.2 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 87, {{
schedule 15, nextbeat(1), tempodur(20)

}}
strset, 86, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
schedule 102, tempodur(1/2), p3, 0.1 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 85, {{
instr 15

;ornament array(102, 0, p3, 0.08, giTonic_ndx, 0.1,(3/2),2.05), array(randselect_i(0.25, 0.66, 0.5, 1.333), 0.125, 0.125), array(5,-1, -2), -24, 4

  
arpeggiates array(102, 0, 3.15, 0.1, giTonic_ndx, 0.1, 1, 3), array(0,2, 4,6,7,6,8), array(0.25), 0, -0.25, -0.5; [,idur, ionsetfac, iampfac]
;arpeggiates array(102, 0, 3.5, 0.1, giTonic_ndx, 0.1, 1, 2), array(8,7,5,6,4,5,3,2,1), array(0.125), 0, -1.25, 0.5; [,idur, ionsetfac, iampfac]
;arpeggiates array(102, p3*0.75, 3.3, 0.1, giTonic_ndx + 2, 0.1, 2, 1), array(8,9,8,9,8,9,10,9), array(0.25), 0, -0.21, -0.2; [,idur, ionsetfac, iampfac]
  
turnoff
endin
}}
strset, 84, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.3, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(6,4), strget(6)))
  
turnoff
endin
}}
strset, 83, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
;chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.3, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 82, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.3, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 81, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.2, giTonic_ndx, 0.12, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 80, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.34, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.2, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 79, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.28, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.2, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 78, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.28, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.1, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 77, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.23, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.1, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 76, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.23, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.04, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 75, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.23, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 74, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1.3, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 73, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.19, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 72, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1.2, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 71, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6,8), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.19, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 70, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 69, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.19, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6,7)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 68, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.19, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5,6)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 67, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.3, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 66, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.19, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 65, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.2, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 64, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.11, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4,5)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 63, {{
linslide strget(11), 10, 0.6;idur, idest, [istart, itype]

}}
strset, 62, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.11, 1), array(iseb -16, iseb - 8, 0, 1, 2,3,4)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 61, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.1, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 60, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.08, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 59, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.11, 1), array(iseb -16, iseb - 8, 0, 1, 2,3)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 58, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.04, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 57, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.06, 1), array(iseb -16, iseb - 8, 0, 1, 2,3)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 56, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
schedule 102, tempodur(1/2), p3*2, 0.01, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 55, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.18, 0, 0.06, 1), array(iseb -16, iseb - 8, 0, 1, 2)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 54, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.13, 0, 0.06, 1), array(iseb -16, iseb - 8, 0, 1, 2)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 53, {{
instr 13

  
schedule 102, 0, p3*2, 0.3, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
;schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 52, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 1), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 1), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.06, 1), array(iseb -16, iseb - 8, 0, 1, 2)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 51, {{
instr 13

  
schedule 102, 0, p3*2, 0.2, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
;schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 50, {{
linslide strget(12), 30, 3;idur, idest, [istart, itype]

}}
strset, 49, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-2,-4,-6), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.6), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.6), array(iseb-16, iseb -8, 0,4,6), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.06, 1), array(iseb -16, iseb - 8, 0, 1, 2)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 48, {{
instr 13

  
schedule 102, 0, p3*2, 0.1, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
;schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 47, {{
instr 13

  
schedule 102, 0, p3*2, 0.07, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
;schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 46, {{
instr 13

  
schedule 102, 0, p3*2, 0.05, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
;schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 45, {{
instr 13

  
schedule 102, 0, p3*2, 0.03, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
;schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 44, {{
schedule 13, nextbeat(1), tempodur(1)

}}
strset, 43, {{
linslide strget(11), 10, 0.2;idur, idest, [istart, itype]

}}
strset, 42, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.6), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.6), array(-8, 0,3,5), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.06, 1), array(iseb -16, iseb - 8, 0, 1, 2)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset 37, "lowchrd"
strset 38, "topchrd"
strset 39, "lightbass"
strset 40, "belrhm"
strset, 41, {{
instr 13

  
schedule 102, 0, p3*2, 0.01, cpstuni(giTonic_ndx - 0 - iterArr(array(0), strget(37)), gi_CurrentScale), 1, 1, 1
;schedule 102, tempodur(1/2), p3*2, 0.4, cpstuni(giTonic_ndx + 2, gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4)*cosr(16)+0.1, 1, 1
;schedule 102, tempodur(2/3), p3, 0.4 * cosr(2,0.1,1), cpstuni(giTonic_ndx + iterArr(array(4,5,6,5), strget(38), 1/4), gi_CurrentScale), randselect_i(1.3, 1.3, 1.3, 1.3, 4), 0.5, 2

;schedule 105, 0, p3*6, 0.2, cpstuni(giTonic_ndx - 8 - iterArr(array(0,2,4,5,6,8), strget(39), 1/6), gi_CurrentScale), tempodur(randselect_i(1,3,2)) * randselect_i(-1, 1)

  
;inb = iterArr(array(1,1/3, 1/6, 2/3, 1/6), strget(40), 1/3)
inb = iterArr(array(1), strget(40))
  
  
schedule p1, nextbeat(inb), tempodur(inb)

turnoff
endin
}}
strset, 36, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.6), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.6), array(-8, 0,3,5), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.06, 1), array(iseb -16, iseb - 8, 0, 1)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 35, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.6), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.6), array(-8, 0,3,5), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.06, 1), array(iseb -16, iseb - 8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 34, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.6), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.6), array(-8, 0,3,5), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 33, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.6), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.6), array(0,3,5), p3;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 32, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.6), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.6), array(0,3,5), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 31, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.6), array(0,3,5), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 30, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0,3,5), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 29, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0,3,6), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 28, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0,3,6), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 27, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0,3,7), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 26, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0,3,4), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 25, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3)),4,6), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0,2,4), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 24, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3)),4), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0,2,4), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 23, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3))), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0,2,4), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 22, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3))), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0,3,4), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 21, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3))), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0,3,5), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 20, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3))), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 19, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2,3),strget(3))), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 18, {{
schedule 202, nextbeat(1), -1

}}
strset, 17, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iseb, iterArr(array(2),strget(3))), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 16, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iterArr(array(2),strget(3))), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset 10, "rev1"
strset 11, "revmix"
strset 12, "revlen"
strset 13, "outputL"
strset 14, "outputR"
strset, 15, {{
instr 202
  ain chnget strget(10)
  aresL, aresR LyonRev1 ain, ain, chnget:k(strget(11)), chnget:k(strget(12))
  
  aresL, aresR declickrst aresL, aresR, 2,2
  chnmix aresL, strget(13)
  chnmix aresR, strget(14)
  chnclear strget(10)
endin
}}
strset, 9, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iterArr(array(3),strget(3))), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
strset, 8, {{
schedule 11, 0, 4

}}
strset 1, "changes"
strset 2, "seb"
strset 3, "seb2"
strset 4, "pits"
strset 5, "walk"
strset 6, "durs"
strset, 7, {{
instr 11
;scaleModulate iterArr(array(4,-2,1,0,1,0), strget(1)), 4
;scalemode  gi_SuperScale, 0, gi94Tkerr
;scaleModulate 0, 2


iseb = iterArr(array(0,-1,-2,-1), strget(2))
  
chordal array(101,0,p3,0.4, 0, 0.4), array(0,iterArr(array(2),strget(3))), p3 * 0.4;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;chordal array(101,p3*0.5,p3,0.4, giTonic_ndx, 0.4), array(0), p3*0.5;, 0,-1,gi94edo; [,idur ,iampfac ,kscale]
;  
;chordal array(106, 0, p3, 0.1, 0, 0.01, 1), array(iseb -16, iseb - 8, 1,2, 3,4,5,6,7,8)
;chordal array(106, 0, p3, 0.01, giTonic_ndx, 0.01, -5), array(iterArr(array(2,1,0), strget(4), 1/4), 8 + walkerChan(strget(5), randint_i(1,2), 16, 0))

;bass  
;schedule 105, 0, p3*2, 0.4, cpstuni(giTonic_ndx - 16, gi_CurrentScale), -0.5/p3
  
  
schedule p1, nextbeat(p3), tempodur(iterArr(array(8,4), strget(6)))
  
turnoff
endin
}}
schedule 8, 1.5416e-05, 1, 7
schedule 8, 2.6489263530000002, 1, 8
schedule 8, 7.99503708, 1, 9
schedule 8, 9.847841142, 1, 15
schedule 8, 9.91192885, 1, 16
schedule 8, 13.263946661, 1, 17
schedule 8, 14.372599213, 1, 18
schedule 8, 19.95655395, 1, 19
schedule 8, 24.783266553, 1, 20
schedule 8, 33.977044622, 1, 21
schedule 8, 38.782466495, 1, 22
schedule 8, 40.920734672, 1, 23
schedule 8, 47.135792378, 1, 24
schedule 8, 48.783869408, 1, 25
schedule 8, 52.027345657, 1, 26
schedule 8, 53.286043313, 1, 27
schedule 8, 57.090116697, 1, 28
schedule 8, 66.462209922, 1, 29
schedule 8, 73.786022211, 1, 30
schedule 8, 75.581997731, 1, 31
schedule 8, 77.736609345, 1, 32
schedule 8, 81.632408823, 1, 33
schedule 8, 83.714754499, 1, 34
schedule 8, 86.963304237, 1, 35
schedule 8, 88.82777106, 1, 36
schedule 8, 93.571959599, 1, 41
schedule 8, 96.045089442, 1, 42
schedule 8, 98.358781941, 1, 43
schedule 8, 98.609580275, 1, 44
schedule 8, 102.701131106, 1, 45
schedule 8, 104.472495845, 1, 46
schedule 8, 106.232378188, 1, 47
schedule 8, 108.33170475, 1, 48
schedule 8, 109.611846937, 1, 49
schedule 8, 110.649845582, 1, 50
schedule 8, 111.309830582, 1, 51
schedule 8, 113.508940269, 1, 52
schedule 8, 114.077030217, 1, 53
schedule 8, 116.078976622, 1, 54
schedule 8, 117.689477611, 1, 55
schedule 8, 119.768851725, 1, 56
schedule 8, 120.54301662, 1, 57
schedule 8, 121.506778339, 1, 58
schedule 8, 122.326820266, 1, 59
schedule 8, 124.555952504, 1, 60
schedule 8, 125.734940525, 1, 61
schedule 8, 125.950245264, 1, 62
schedule 8, 126.379789014, 1, 63
schedule 8, 127.87149318, 1, 64
schedule 8, 128.876275471, 1, 65
schedule 8, 131.122286148, 1, 66
schedule 8, 132.504088751, 1, 67
schedule 8, 132.658948387, 1, 68
schedule 8, 134.082225574, 1, 69
schedule 8, 134.52315448, 1, 70
schedule 8, 135.715703906, 1, 71
schedule 8, 137.074474218, 1, 72
schedule 8, 137.22087026, 1, 73
schedule 8, 140.069808488, 1, 74
schedule 8, 142.854430779, 1, 75
schedule 8, 144.448173799, 1, 76
schedule 8, 145.466067132, 1, 77
schedule 8, 147.085589683, 1, 78
schedule 8, 148.634561974, 1, 79
schedule 8, 152.362399785, 1, 80
schedule 8, 154.330125826, 1, 81
schedule 8, 156.371051242, 1, 82
schedule 8, 163.213742958, 1, 83
schedule 8, 170.239788633, 1, 84
schedule 8, 170.847105143, 1, 85
schedule 8, 171.316619986, 1, 86
schedule 8, 171.723697643, 1, 87
schedule 8, 173.33581285, 1, 88
schedule 8, 175.042244568, 1, 89
schedule 8, 176.950486286, 1, 90
schedule 8, 189.871235761, 1, 91
schedule 8, 193.932690238, 1, 92
schedule 8, 195.021008727, 1, 93
schedule 8, 201.886983516, 1, 94
schedule 8, 208.760069608, 1, 95
schedule 8, 209.783944763, 1, 96
schedule 8, 213.504258252, 1, 97
schedule 8, 216.71300523, 1, 98
schedule 8, 216.847532, 1, 99
schedule 8, 217.271460958, 1, 100
schedule 8, 221.093899655, 1, 101
schedule 8, 222.59485429, 1, 102
schedule 8, 223.035551581, 1, 103
schedule 8, 224.018265175, 1, 104
schedule 8, 227.475172882, 1, 105
schedule 8, 233.934238556, 1, 106
schedule 8, 234.434611056, 1, 107
schedule 8, 235.259617462, 1, 108
schedule 8, 235.887429076, 1, 109
schedule 8, 237.036380482, 1, 110
schedule 8, 237.52308819, 1, 111
schedule 8, 238.554230482, 1, 112
schedule 8, 246.992304489, 1, 113
schedule 8, 256.653628183, 1, 114
schedule 8, 260.063353598, 1, 115
schedule 8, 265.6045237, 1, 116
schedule 8, 267.793277658, 1, 117
schedule 8, 275.281989686, 1, 118
schedule 8, 278.545882966, 1, 119
schedule 8, 280.153577393, 1, 120
schedule 8, 280.857770986, 1, 121
schedule 8, 281.388043122, 1, 122
schedule 8, 283.661762183, 1, 123
schedule 8, 283.742934683, 1, 124
schedule 8, 285.126887756, 1, 125
schedule 8, 287.145816244, 1, 126
schedule 8, 288.672472494, 1, 127
schedule 8, 288.718139473, 1, 128
schedule 8, 289.432737702, 1, 129
schedule 8, 294.01404744, 1, 130
schedule 8, 294.956348168, 1, 131
schedule 8, 296.225757178, 1, 132
schedule 8, 296.95877697, 1, 133
schedule 8, 297.093543636, 1, 134
schedule 8, 298.113091605, 1, 135
schedule 8, 303.468877488, 1, 136
schedule 8, 305.935589466, 1, 137
schedule 8, 307.015656237, 1, 138
schedule 8, 310.198100923, 1, 139
schedule 8, 311.033403996, 1, 140
schedule 8, 311.749906183, 1, 141
schedule 8, 312.617706078, 1, 142
schedule 8, 313.649030505, 1, 143
schedule 8, 313.993152901, 1, 144
schedule 8, 315.434827067, 1, 145
schedule 8, 315.801882588, 1, 146
schedule 8, 316.404107014, 1, 147
schedule 8, 318.36145118, 1, 148
schedule 8, 319.125933107, 1, 149
schedule 8, 319.535178003, 1, 150
schedule 8, 322.533530293, 1, 151
schedule 8, 322.809931074, 1, 152
schedule 8, 325.727312948, 1, 153
schedule 8, 327.927232114, 1, 154
schedule 8, 329.733909145, 1, 155
schedule 8, 330.794757217, 1, 156
schedule 8, 330.841132738, 1, 157
schedule 8, 332.218732738, 1, 158
schedule 8, 348.616883356, 1, 159
schedule 8, 352.78012773, 1, 160
schedule 8, 356.767112364, 1, 161
schedule 8, 359.303314186, 1, 162
schedule 8, 359.488761685, 1, 163
schedule 8, 384.563363759, 1, 164
schedule 8, 386.527575269, 1, 165
schedule 8, 386.597124175, 1, 166
schedule 8, 415.455557237, 1, 167
schedule 8, 416.335973278, 1, 168
schedule 8, 416.410360674, 1, 169
schedule 8, 421.091099318, 1, 170
schedule 8, 424.255442807, 1, 171
schedule 8, 426.841810462, 1, 172
schedule 8, 431.272398064, 1, 173
schedule 8, 438.760078009, 1, 174
schedule 8, 439.627604103, 1, 175
schedule 8, 444.337078997, 1, 176

schedule 7, 474.228362475, 1
</CsInstruments>
<CsScore>
f0 474.228362475
e
</CsScore>
</CsoundSynthesizer>
