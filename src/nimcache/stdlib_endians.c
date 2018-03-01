/* Generated by Nim Compiler v0.17.3 */
/*   (c) 2018 Andreas Rumpf */
/* The generated code is subject to the original license. */
/* Compiled for: Windows, amd64, gcc */
/* Command for C compiler:
   gcc.exe -c  -w -mno-ms-bitfields -DWIN32_LEAN_AND_MEAN  -IC:\nim\lib -o C:\Users\Desktop-P1NKA\Desktop\nimengine\src\nimcache\stdlib_endians.o C:\Users\Desktop-P1NKA\Desktop\nimengine\src\nimcache\stdlib_endians.c */
#define NIM_NEW_MANGLING_RULES
#define NIM_INTBITS 64

#include "nimbase.h"
#include <string.h>
#undef LANGUAGE_C
#undef MIPSEB
#undef MIPSEL
#undef PPC
#undef R3000
#undef R4000
#undef i386
#undef linux
#undef mips
#undef near
#undef powerpc
#undef unix
static N_INLINE(void, swapEndian64_IzdisrH4sYnsItUtxSkomAendians)(void* outp, void* inp);
static N_INLINE(void, nimFrame)(TFrame* s);
N_LIB_PRIVATE N_NOINLINE(void, stackOverflow_II46IjNZztN9bmbxUD8dt8g)(void);
static N_INLINE(void, popFrame)(void);
static N_INLINE(void, swapEndian32_IzdisrH4sYnsItUtxSkomA_2endians)(void* outp, void* inp);
static N_INLINE(void, swapEndian16_IzdisrH4sYnsItUtxSkomA_3endians)(void* outp, void* inp);
static N_INLINE(void, littleEndian64_IzdisrH4sYnsItUtxSkomA_4endians)(void* outp, void* inp);
static N_INLINE(void, copyMem_E1xtACub5WcDa3vbrIXbwgsystem)(void* dest, void* source, NI size);
static N_INLINE(void, littleEndian32_IzdisrH4sYnsItUtxSkomA_5endians)(void* outp, void* inp);
static N_INLINE(void, littleEndian16_IzdisrH4sYnsItUtxSkomA_6endians)(void* outp, void* inp);
static N_INLINE(void, bigEndian64_IzdisrH4sYnsItUtxSkomA_7endians)(void* outp, void* inp);
static N_INLINE(void, bigEndian32_IzdisrH4sYnsItUtxSkomA_8endians)(void* outp, void* inp);
static N_INLINE(void, bigEndian16_IzdisrH4sYnsItUtxSkomA_9endians)(void* outp, void* inp);
extern TFrame* framePtr_HRfVMH3jYeBJz6Q6X9b6Ptw;

static N_INLINE(void, nimFrame)(TFrame* s) {
	NI T1_;
	T1_ = (NI)0;
	{
		if (!(framePtr_HRfVMH3jYeBJz6Q6X9b6Ptw == NIM_NIL)) goto LA4_;
		T1_ = ((NI) 0);
	}
	goto LA2_;
	LA4_: ;
	{
		T1_ = ((NI) ((NI16)((*framePtr_HRfVMH3jYeBJz6Q6X9b6Ptw).calldepth + ((NI16) 1))));
	}
	LA2_: ;
	(*s).calldepth = ((NI16) (T1_));
	(*s).prev = framePtr_HRfVMH3jYeBJz6Q6X9b6Ptw;
	framePtr_HRfVMH3jYeBJz6Q6X9b6Ptw = s;
	{
		if (!((*s).calldepth == ((NI16) 2000))) goto LA9_;
		stackOverflow_II46IjNZztN9bmbxUD8dt8g();
	}
	LA9_: ;
}

static N_INLINE(void, popFrame)(void) {
	framePtr_HRfVMH3jYeBJz6Q6X9b6Ptw = (*framePtr_HRfVMH3jYeBJz6Q6X9b6Ptw).prev;
}

static N_INLINE(void, swapEndian64_IzdisrH4sYnsItUtxSkomAendians)(void* outp, void* inp) {
	NU64* i;
	NU64* o;
	nimfr_("swapEndian64", "endians.nim");
	nimln_(48, "endians.nim");
	i = ((NU64*) (inp));
	nimln_(49, "endians.nim");
	o = ((NU64*) (outp));
	nimln_(50, "endians.nim");
	(*o) = __builtin_bswap64((*i));
	popFrame();
}

static N_INLINE(void, swapEndian32_IzdisrH4sYnsItUtxSkomA_2endians)(void* outp, void* inp) {
	NU32* i;
	NU32* o;
	nimfr_("swapEndian32", "endians.nim");
	nimln_(53, "endians.nim");
	i = ((NU32*) (inp));
	nimln_(54, "endians.nim");
	o = ((NU32*) (outp));
	nimln_(55, "endians.nim");
	(*o) = __builtin_bswap32((*i));
	popFrame();
}

static N_INLINE(void, swapEndian16_IzdisrH4sYnsItUtxSkomA_3endians)(void* outp, void* inp) {
	NU16* i;
	NU16* o;
	nimfr_("swapEndian16", "endians.nim");
	nimln_(58, "endians.nim");
	i = ((NU16*) (inp));
	nimln_(59, "endians.nim");
	o = ((NU16*) (outp));
	nimln_(60, "endians.nim");
	(*o) = __builtin_bswap16((*i));
	popFrame();
}

static N_INLINE(void, copyMem_E1xtACub5WcDa3vbrIXbwgsystem)(void* dest, void* source, NI size) {
	void* T1_;
	T1_ = (void*)0;
	T1_ = memcpy(dest, source, ((size_t) (size)));
}

static N_INLINE(void, littleEndian64_IzdisrH4sYnsItUtxSkomA_4endians)(void* outp, void* inp) {
	nimfr_("littleEndian64", "endians.nim");
	nimln_(103, "endians.nim");
	copyMem_E1xtACub5WcDa3vbrIXbwgsystem(outp, inp, ((NI) 8));
	popFrame();
}

static N_INLINE(void, littleEndian32_IzdisrH4sYnsItUtxSkomA_5endians)(void* outp, void* inp) {
	nimfr_("littleEndian32", "endians.nim");
	nimln_(104, "endians.nim");
	copyMem_E1xtACub5WcDa3vbrIXbwgsystem(outp, inp, ((NI) 4));
	popFrame();
}

static N_INLINE(void, littleEndian16_IzdisrH4sYnsItUtxSkomA_6endians)(void* outp, void* inp) {
	nimfr_("littleEndian16", "endians.nim");
	nimln_(105, "endians.nim");
	copyMem_E1xtACub5WcDa3vbrIXbwgsystem(outp, inp, ((NI) 2));
	popFrame();
}

static N_INLINE(void, bigEndian64_IzdisrH4sYnsItUtxSkomA_7endians)(void* outp, void* inp) {
	nimfr_("bigEndian64", "endians.nim");
	nimln_(106, "endians.nim");
	swapEndian64_IzdisrH4sYnsItUtxSkomAendians(outp, inp);
	popFrame();
}

static N_INLINE(void, bigEndian32_IzdisrH4sYnsItUtxSkomA_8endians)(void* outp, void* inp) {
	nimfr_("bigEndian32", "endians.nim");
	nimln_(107, "endians.nim");
	swapEndian32_IzdisrH4sYnsItUtxSkomA_2endians(outp, inp);
	popFrame();
}

static N_INLINE(void, bigEndian16_IzdisrH4sYnsItUtxSkomA_9endians)(void* outp, void* inp) {
	nimfr_("bigEndian16", "endians.nim");
	nimln_(108, "endians.nim");
	swapEndian16_IzdisrH4sYnsItUtxSkomA_3endians(outp, inp);
	popFrame();
}
NIM_EXTERNC N_NOINLINE(void, stdlib_endiansInit000)(void) {
	nimfr_("endians", "endians.nim");
	popFrame();
}

NIM_EXTERNC N_NOINLINE(void, stdlib_endiansDatInit000)(void) {
}
