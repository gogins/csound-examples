/*
NOTE: ADJUST INCLUDE PATHS ETC. AS REQUIRED.

Compile on Linux with:
    gcc -O2 -g -shared -fPIC csound_poscil.c -DUSE_DOUBLE -I/home/mkg/csound/csound/include -ocsound_poscil.so
Compile for mingw64 in the msys64 shell with:
    gcc -O2 -g -shared -fPIC csound_poscil.c -DUSE_DOUBLE -I/D:/msys64/home/restore/csound/include -ocsound_poscil.dll
Compile for Microsoft Visual Studio 2015 in the vcvars64 shell with:
    cl csound_poscil.c /Ox /DUSE_DOUBLE /IC:/Program_Files/Csound6_x64/include/csound /LD /link /out:csound_poscil.dll
Run on Linux with:
    csound --opcode-lib=csound_poscil.so csound_poscil.csd
Run on Windows with:
    csound --opcode-lib=csound_poscil.dll csound_poscil.csd
*/
#include <csdl.h>

typedef struct  {
    OPDS        h;
    MYFLT       *out, *amp, *freq, *ift,				 *iphs;
    FUNC        *ftp;
    int32	tablen;
    double      tablenUPsr;
    double      phs;
} CSOUND_POSCIL;

static int csound_poscil_set(CSOUND *csound, CSOUND_POSCIL *p)   //  static = only one "posc_set"
{
     FUNC *ftp; /* function table struct pointer */
    if ((ftp = csound->FTnp2Find(csound, p->ift)) == NULL)
     return csound->InitError(csound, Str("table not found in poscil: %f"), *p->ift); //table is founded or not
    p->ftp        = ftp;//pointer to the function tabl
    p->tablen     = ftp->flen; //"flen" is a member of func structure (size of the table).
    p->tablenUPsr = p->tablen * (1./csound->GetSr(csound));
    p->phs        = *p->iphs * p->tablen;//actual phase = beggining phase * (table length)
    return OK;
}

static int posckk(CSOUND *csound, CSOUND_POSCIL *p)  //variable declarations for krate function
{
    FUNC         *ftp = p->ftp; //pointer to ftp variable
    MYFLT       *out = p->out, *ft; // pointer to to output
    MYFLT       fract; //variable declaration
    double      phs = p->phs; //phs receives the actual phase
    uint32_t n, nsmps = CS_KSMPS; // variables declaration
    MYFLT       amp = *p->amp; // amp gets the actual amplitude
    if (ftp==NULL)
      return csound->PerfError(csound, p->h.insdshead,Str("poscil: not initialised"));// something is not found in h.inshead
    ft = p->ftp->ftable;
    double      si = *p->freq * p->tablenUPsr; //frequency * (table length)/sr
	for (n=0; n<nsmps; n++)
{
      fract     = (MYFLT)(phs - (int32)phs);// fraction between two positions in the table
      out[n]    = amp * (ft[(int)phs] +(ft[(int)phs+1] - ft[(int)phs])*fract); //interpolated value
      phs      += si; //increment
      while (phs >= p->tablen)
        phs -= p->tablen;  // reads backwards if phs >= p->tablen
      while (phs < 0.0) // reads forwardd if phs <= p->tablen
        phs += p->tablen; //increment
    }
    p->phs = phs; //new actual phase
    return OK;
}

#define S(x)    sizeof(x)

static OENTRY localops[] = {
{ "csound_poscil.a", S(CSOUND_POSCIL), 0,5, "a", "kkjo", (SUBR)csound_poscil_set,(SUBR)NULL,(SUBR)posckk }
};

LINKAGE
