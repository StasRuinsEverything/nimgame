/* Generated by Nim Compiler v0.17.3 */
/*   (c) 2018 Andreas Rumpf */
/* The generated code is subject to the original license. */
/* Compiled for: Windows, amd64, gcc */
/* Command for C compiler:
   gcc.exe -c  -w -mno-ms-bitfields -DWIN32_LEAN_AND_MEAN  -IC:\nim\lib -o C:\Users\Desktop-P1NKA\Desktop\nimengine\src\nimcache\stdlib_algorithm.o C:\Users\Desktop-P1NKA\Desktop\nimengine\src\nimcache\stdlib_algorithm.c */
#define NIM_NEW_MANGLING_RULES
#define NIM_INTBITS 64

#include "nimbase.h"
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
typedef struct NimStringDesc NimStringDesc;
typedef struct TGenericSeq TGenericSeq;
typedef struct tySequence_qwqHTkRvwhrRyENtudHQ7g tySequence_qwqHTkRvwhrRyENtudHQ7g;
typedef struct TNimType TNimType;
typedef struct TNimNode TNimNode;
typedef NU8 tyEnum_SortOrder_8iBc6wlNqBa9cju9cUAhUAxA;
struct TGenericSeq {
NI len;
NI reserved;
};
struct NimStringDesc {
  TGenericSeq Sup;
NIM_CHAR data[SEQ_DECL_SIZE];
};
typedef struct {
N_NIMCALL_PTR(NI, ClP_0) (NI x, NI y, void* ClE_0);
void* ClE_0;
} tyProc_fDD7zVPPl59bNBu4ChTEQeQ;
typedef NU8 tyEnum_TNimKind_jIBKr1ejBgsfM33Kxw4j7A;
typedef NU8 tySet_tyEnum_TNimTypeFlag_v8QUszD1sWlSIWZz7mC4bQ;
typedef N_NIMCALL_PTR(void, tyProc_ojoeKfW4VYIm36I9cpDTQIg) (void* p, NI op);
typedef N_NIMCALL_PTR(void*, tyProc_WSm2xU5ARYv9aAR4l0z9c9auQ) (void* p);
struct TNimType {
NI size;
tyEnum_TNimKind_jIBKr1ejBgsfM33Kxw4j7A kind;
tySet_tyEnum_TNimTypeFlag_v8QUszD1sWlSIWZz7mC4bQ flags;
TNimType* base;
TNimNode* node;
void* finalizer;
tyProc_ojoeKfW4VYIm36I9cpDTQIg marker;
tyProc_WSm2xU5ARYv9aAR4l0z9c9auQ deepcopy;
};
typedef NU8 tyEnum_TNimNodeKind_unfNsxrcATrufDZmpBq4HQ;
struct TNimNode {
tyEnum_TNimNodeKind_unfNsxrcATrufDZmpBq4HQ kind;
NI offset;
TNimType* typ;
NCSTRING name;
NI len;
TNimNode** sons;
};
typedef N_CLOSURE_PTR(NI, TM_JdC9c6SaUkvO1XjYuWP1JWQ_10) (NI x, NI y);
typedef N_CLOSURE_PTR(NI, TM_JdC9c6SaUkvO1XjYuWP1JWQ_14) (NI x, NI y);
struct tySequence_qwqHTkRvwhrRyENtudHQ7g {
  TGenericSeq Sup;
  NI data[SEQ_DECL_SIZE];
};
static N_INLINE(NI, star__mciSqxUij8SrsZknIQqvwwalgorithm)(NI x, tyEnum_SortOrder_8iBc6wlNqBa9cju9cUAhUAxA order);
static N_INLINE(NI, subInt)(NI a, NI b);
N_NOINLINE(void, raiseOverflow)(void);
static N_INLINE(void, nimFrame)(TFrame* s);
N_LIB_PRIVATE N_NOINLINE(void, stackOverflow_II46IjNZztN9bmbxUD8dt8g)(void);
static N_INLINE(void, popFrame)(void);
N_LIB_PRIVATE N_NIMCALL(void, reverse_XQiN4wExsmIg8NFBmG3ObA)(NimStringDesc** a, NI aLen_0, NI first, NI last);
N_NOINLINE(void, raiseIndexError)(void);
N_NIMCALL(void, unsureAsgnRef)(void** dest, void* src);
static N_INLINE(NI, addInt)(NI a, NI b);
static N_INLINE(NI, chckRange)(NI i, NI a, NI b);
N_NOINLINE(void, raiseRangeError)(NI64 val);
static N_INLINE(NI, divInt)(NI a, NI b);
N_NOINLINE(void, raiseDivByZero)(void);
N_NIMCALL(void*, newSeq)(TNimType* typ, NI len);
N_LIB_PRIVATE N_NIMCALL(void, merge_3YlxpxWbu7ggyWNi6G1FdQ)(NI* a, NI aLen_0, NI* b, NI bLen_0, NI lo, NI m, NI hi, tyProc_fDD7zVPPl59bNBu4ChTEQeQ cmp, tyEnum_SortOrder_8iBc6wlNqBa9cju9cUAhUAxA order);
N_LIB_PRIVATE N_NIMCALL(void, failedAssertImpl_aDmpBTs9cPuXp0Mp9cfiNeyA)(NimStringDesc* msg);
N_NIMCALL(NI, mulInt)(NI a, NI b);
extern TFrame* framePtr_HRfVMH3jYeBJz6Q6X9b6Ptw;
extern TNimType NTI_qwqHTkRvwhrRyENtudHQ7g_;
STRING_LITERAL(TM_JdC9c6SaUkvO1XjYuWP1JWQ_11, "j <= m ", 7);

static N_INLINE(NI, subInt)(NI a, NI b) {
	NI result;
{	result = (NI)0;
	result = (NI)((NU64)(a) - (NU64)(b));
	{
		NIM_BOOL T3_;
		T3_ = (NIM_BOOL)0;
		T3_ = (((NI) 0) <= (NI)(result ^ a));
		if (T3_) goto LA4_;
		T3_ = (((NI) 0) <= (NI)(result ^ (NI)((NU64) ~(b))));
		LA4_: ;
		if (!T3_) goto LA5_;
		goto BeforeRet_;
	}
	LA5_: ;
	raiseOverflow();
	}BeforeRet_: ;
	return result;
}

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

static N_INLINE(NI, star__mciSqxUij8SrsZknIQqvwwalgorithm)(NI x, tyEnum_SortOrder_8iBc6wlNqBa9cju9cUAhUAxA order) {
	NI result;
	NI y;
	NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_2;
	NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_3;
	nimfr_("*", "algorithm.nim");
	result = (NI)0;
	nimln_(24, "algorithm.nim");
	TM_JdC9c6SaUkvO1XjYuWP1JWQ_2 = subInt(order, ((NI) 1));
	y = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_2);
	nimln_(25, "algorithm.nim");
	TM_JdC9c6SaUkvO1XjYuWP1JWQ_3 = subInt((NI)(x ^ y), y);
	result = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_3);
	popFrame();
	return result;
}

static N_INLINE(NI, addInt)(NI a, NI b) {
	NI result;
{	result = (NI)0;
	result = (NI)((NU64)(a) + (NU64)(b));
	{
		NIM_BOOL T3_;
		T3_ = (NIM_BOOL)0;
		T3_ = (((NI) 0) <= (NI)(result ^ a));
		if (T3_) goto LA4_;
		T3_ = (((NI) 0) <= (NI)(result ^ b));
		LA4_: ;
		if (!T3_) goto LA5_;
		goto BeforeRet_;
	}
	LA5_: ;
	raiseOverflow();
	}BeforeRet_: ;
	return result;
}

N_LIB_PRIVATE N_NIMCALL(void, reverse_XQiN4wExsmIg8NFBmG3ObA)(NimStringDesc** a, NI aLen_0, NI first, NI last) {
	NI x;
	NI y;
	nimfr_("reverse", "algorithm.nim");
	nimln_(40, "algorithm.nim");
	x = first;
	nimln_(41, "algorithm.nim");
	y = last;
	{
		nimln_(42, "algorithm.nim");
		while (1) {
			NimStringDesc* T3_;
			NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_4;
			NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_5;
			if (!(((NI) (x)) < ((NI) (y)))) goto LA2;
			nimln_(43, "algorithm.nim");
			T3_ = (NimStringDesc*)0;
			if ((NU)(x) >= (NU)(aLen_0)) raiseIndexError();
			if ((NU)(y) >= (NU)(aLen_0)) raiseIndexError();
			T3_ = a[x];
			unsureAsgnRef((void**) (&a[x]), a[y]);
			unsureAsgnRef((void**) (&a[y]), T3_);
			nimln_(44, "algorithm.nim");
			TM_JdC9c6SaUkvO1XjYuWP1JWQ_4 = subInt(y, ((NI) 1));
			if (TM_JdC9c6SaUkvO1XjYuWP1JWQ_4 < 0 || TM_JdC9c6SaUkvO1XjYuWP1JWQ_4 > IL64(9223372036854775807)) raiseOverflow();
			y = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_4);
			nimln_(45, "algorithm.nim");
			TM_JdC9c6SaUkvO1XjYuWP1JWQ_5 = addInt(x, ((NI) 1));
			if (TM_JdC9c6SaUkvO1XjYuWP1JWQ_5 < 0 || TM_JdC9c6SaUkvO1XjYuWP1JWQ_5 > IL64(9223372036854775807)) raiseOverflow();
			x = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_5);
		} LA2: ;
	}
	popFrame();
}

static N_INLINE(NI, chckRange)(NI i, NI a, NI b) {
	NI result;
{	result = (NI)0;
	{
		NIM_BOOL T3_;
		T3_ = (NIM_BOOL)0;
		T3_ = (a <= i);
		if (!(T3_)) goto LA4_;
		T3_ = (i <= b);
		LA4_: ;
		if (!T3_) goto LA5_;
		result = i;
		goto BeforeRet_;
	}
	goto LA1_;
	LA5_: ;
	{
		raiseRangeError(((NI64) (i)));
	}
	LA1_: ;
	}BeforeRet_: ;
	return result;
}

N_LIB_PRIVATE N_NIMCALL(void, reverse_LoixoqZetR6FfezoPedx8w)(NimStringDesc** a, NI aLen_0) {
	nimfr_("reverse", "algorithm.nim");
	nimln_(49, "algorithm.nim");
	reverse_XQiN4wExsmIg8NFBmG3ObA(a, aLen_0, ((NI) 0), ((NI)chckRange(((((NI) 0) >= (aLen_0-1)) ? ((NI) 0) : (aLen_0-1)), ((NI) 0), ((NI) IL64(9223372036854775807)))));
	popFrame();
}

static N_INLINE(NI, divInt)(NI a, NI b) {
	NI result;
{	result = (NI)0;
	{
		if (!(b == ((NI) 0))) goto LA3_;
		raiseDivByZero();
	}
	LA3_: ;
	{
		NIM_BOOL T7_;
		T7_ = (NIM_BOOL)0;
		T7_ = (a == ((NI) (IL64(-9223372036854775807) - IL64(1))));
		if (!(T7_)) goto LA8_;
		T7_ = (b == ((NI) -1));
		LA8_: ;
		if (!T7_) goto LA9_;
		raiseOverflow();
	}
	LA9_: ;
	result = (NI)(a / b);
	goto BeforeRet_;
	}BeforeRet_: ;
	return result;
}

N_LIB_PRIVATE N_NIMCALL(void, merge_3YlxpxWbu7ggyWNi6G1FdQ)(NI* a, NI aLen_0, NI* b, NI bLen_0, NI lo, NI m, NI hi, tyProc_fDD7zVPPl59bNBu4ChTEQeQ cmp, tyEnum_SortOrder_8iBc6wlNqBa9cju9cUAhUAxA order) {
	NI j;
	NI bb;
	NI i;
	NI k;
	nimfr_("merge", "algorithm.nim");
{	nimln_(130, "algorithm.nim");
	{
		NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_9;
		NI T3_;
		NI T4_;
		if ((NU)(m) >= (NU)(aLen_0)) raiseIndexError();
		TM_JdC9c6SaUkvO1XjYuWP1JWQ_9 = addInt(m, ((NI) 1));
		if ((NU)((NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_9)) >= (NU)(aLen_0)) raiseIndexError();
		T3_ = (NI)0;
		T3_ = cmp.ClE_0? cmp.ClP_0(a[m], a[(NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_9)], cmp.ClE_0):((TM_JdC9c6SaUkvO1XjYuWP1JWQ_10)(cmp.ClP_0))(a[m], a[(NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_9)]);
		T4_ = (NI)0;
		T4_ = star__mciSqxUij8SrsZknIQqvwwalgorithm(T3_, order);
		if (!(T4_ <= ((NI) 0))) goto LA5_;
		goto BeforeRet_;
	}
	LA5_: ;
	nimln_(131, "algorithm.nim");
	j = lo;
	nimln_(133, "algorithm.nim");
	{
		if (!!((j <= m))) goto LA9_;
		failedAssertImpl_aDmpBTs9cPuXp0Mp9cfiNeyA(((NimStringDesc*) &TM_JdC9c6SaUkvO1XjYuWP1JWQ_11));
	}
	LA9_: ;
	nimln_(135, "algorithm.nim");
	bb = ((NI) 0);
	{
		nimln_(136, "algorithm.nim");
		while (1) {
			NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_12;
			NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_13;
			if (!(j <= m)) goto LA12;
			if ((NU)(bb) >= (NU)(bLen_0)) raiseIndexError();
			nimln_(137, "algorithm.nim");
			if ((NU)(j) >= (NU)(aLen_0)) raiseIndexError();
			b[bb] = a[j];
			nimln_(138, "algorithm.nim");
			TM_JdC9c6SaUkvO1XjYuWP1JWQ_12 = addInt(bb, ((NI) 1));
			bb = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_12);
			nimln_(139, "algorithm.nim");
			TM_JdC9c6SaUkvO1XjYuWP1JWQ_13 = addInt(j, ((NI) 1));
			j = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_13);
		} LA12: ;
	}
	nimln_(143, "algorithm.nim");
	i = ((NI) 0);
	nimln_(144, "algorithm.nim");
	k = lo;
	{
		nimln_(146, "algorithm.nim");
		while (1) {
			NIM_BOOL T15_;
			NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_17;
			T15_ = (NIM_BOOL)0;
			T15_ = (k < j);
			if (!(T15_)) goto LA16_;
			T15_ = (j <= hi);
			LA16_: ;
			if (!T15_) goto LA14;
			nimln_(147, "algorithm.nim");
			{
				NI T19_;
				NI T20_;
				NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_15;
				if ((NU)(i) >= (NU)(bLen_0)) raiseIndexError();
				if ((NU)(j) >= (NU)(aLen_0)) raiseIndexError();
				T19_ = (NI)0;
				T19_ = cmp.ClE_0? cmp.ClP_0(b[i], a[j], cmp.ClE_0):((TM_JdC9c6SaUkvO1XjYuWP1JWQ_14)(cmp.ClP_0))(b[i], a[j]);
				T20_ = (NI)0;
				T20_ = star__mciSqxUij8SrsZknIQqvwwalgorithm(T19_, order);
				if (!(T20_ <= ((NI) 0))) goto LA21_;
				if ((NU)(k) >= (NU)(aLen_0)) raiseIndexError();
				nimln_(148, "algorithm.nim");
				if ((NU)(i) >= (NU)(bLen_0)) raiseIndexError();
				a[k] = b[i];
				nimln_(149, "algorithm.nim");
				TM_JdC9c6SaUkvO1XjYuWP1JWQ_15 = addInt(i, ((NI) 1));
				i = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_15);
			}
			goto LA17_;
			LA21_: ;
			{
				NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_16;
				if ((NU)(k) >= (NU)(aLen_0)) raiseIndexError();
				nimln_(151, "algorithm.nim");
				if ((NU)(j) >= (NU)(aLen_0)) raiseIndexError();
				a[k] = a[j];
				nimln_(152, "algorithm.nim");
				TM_JdC9c6SaUkvO1XjYuWP1JWQ_16 = addInt(j, ((NI) 1));
				j = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_16);
			}
			LA17_: ;
			nimln_(153, "algorithm.nim");
			TM_JdC9c6SaUkvO1XjYuWP1JWQ_17 = addInt(k, ((NI) 1));
			k = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_17);
		} LA14: ;
	}
	{
		nimln_(156, "algorithm.nim");
		while (1) {
			NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_18;
			NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_19;
			if (!(k < j)) goto LA25;
			if ((NU)(k) >= (NU)(aLen_0)) raiseIndexError();
			nimln_(157, "algorithm.nim");
			if ((NU)(i) >= (NU)(bLen_0)) raiseIndexError();
			a[k] = b[i];
			nimln_(158, "algorithm.nim");
			TM_JdC9c6SaUkvO1XjYuWP1JWQ_18 = addInt(k, ((NI) 1));
			k = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_18);
			nimln_(159, "algorithm.nim");
			TM_JdC9c6SaUkvO1XjYuWP1JWQ_19 = addInt(i, ((NI) 1));
			i = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_19);
		} LA25: ;
	}
	}BeforeRet_: ;
	popFrame();
}

N_LIB_PRIVATE N_NIMCALL(void, sort_84EnBzTXl9c1maQcyvYsKBQ)(NI* a, NI aLen_0, tyProc_fDD7zVPPl59bNBu4ChTEQeQ cmp, tyEnum_SortOrder_8iBc6wlNqBa9cju9cUAhUAxA order) {
	NI n;
	tySequence_qwqHTkRvwhrRyENtudHQ7g* b;
	NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_6;
	NI s;
	nimfr_("sort", "algorithm.nim");
	nimln_(192, "algorithm.nim");
	n = aLen_0;
	b = (tySequence_qwqHTkRvwhrRyENtudHQ7g*)0;
	nimln_(194, "algorithm.nim");
	TM_JdC9c6SaUkvO1XjYuWP1JWQ_6 = divInt(n, ((NI) 2));
	b = (tySequence_qwqHTkRvwhrRyENtudHQ7g*) newSeq((&NTI_qwqHTkRvwhrRyENtudHQ7g_), ((NI)chckRange((NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_6), ((NI) 0), ((NI) IL64(9223372036854775807)))));
	nimln_(195, "algorithm.nim");
	s = ((NI) 1);
	{
		nimln_(196, "algorithm.nim");
		while (1) {
			NI m;
			NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_7;
			NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_8;
			NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_25;
			if (!(s < n)) goto LA2;
			nimln_(197, "algorithm.nim");
			TM_JdC9c6SaUkvO1XjYuWP1JWQ_7 = subInt(n, ((NI) 1));
			TM_JdC9c6SaUkvO1XjYuWP1JWQ_8 = subInt((NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_7), s);
			m = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_8);
			{
				nimln_(198, "algorithm.nim");
				while (1) {
					NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_20;
					NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_21;
					NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_22;
					NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_23;
					NI TM_JdC9c6SaUkvO1XjYuWP1JWQ_24;
					if (!(((NI) 0) <= m)) goto LA4;
					nimln_(199, "algorithm.nim");
					TM_JdC9c6SaUkvO1XjYuWP1JWQ_20 = subInt(m, s);
					TM_JdC9c6SaUkvO1XjYuWP1JWQ_21 = addInt((NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_20), ((NI) 1));
					TM_JdC9c6SaUkvO1XjYuWP1JWQ_22 = addInt(m, s);
					merge_3YlxpxWbu7ggyWNi6G1FdQ(a, aLen_0, b->data, b->Sup.len, (((NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_21) >= ((NI) 0)) ? (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_21) : ((NI) 0)), m, (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_22), cmp, order);
					nimln_(200, "algorithm.nim");
					TM_JdC9c6SaUkvO1XjYuWP1JWQ_23 = mulInt(s, ((NI) 2));
					TM_JdC9c6SaUkvO1XjYuWP1JWQ_24 = subInt(m, (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_23));
					m = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_24);
				} LA4: ;
			}
			nimln_(201, "algorithm.nim");
			TM_JdC9c6SaUkvO1XjYuWP1JWQ_25 = mulInt(s, ((NI) 2));
			s = (NI)(TM_JdC9c6SaUkvO1XjYuWP1JWQ_25);
		} LA2: ;
	}
	popFrame();
}
NIM_EXTERNC N_NOINLINE(void, stdlib_algorithmInit000)(void) {
	nimfr_("algorithm", "algorithm.nim");
	popFrame();
}

NIM_EXTERNC N_NOINLINE(void, stdlib_algorithmDatInit000)(void) {
}

