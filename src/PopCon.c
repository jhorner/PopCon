#include <stdlib.h>
#include "PopCon.h"

static SEXP pcTB = NULL;

Rboolean pc_exists(const char * const name, Rboolean *canCache, R_ObjectTable *tb){
	SEXP obj, fun, val, e;
	int errorOccurred = FALSE;

	fun = (SEXP)tb->privateData;
	if(!fun || fun == R_NilValue) {
		return(FALSE);
	}

	PROTECT(e = allocVector(LANGSXP,2));
	SETCAR(e, fun);
	SETCAR(CDR(e), val = NEW_CHARACTER(1));
	SET_STRING_ELT(val, 0, COPY_TO_USER_STRING(name));
	val = R_tryEval(e, NULL, &errorOccurred);
	UNPROTECT(1);
	return FALSE;
}

static SEXP pc_get(const char * const name, Rboolean *canCache, R_ObjectTable *tb){
	pc_exists(name,canCache,tb);
	return R_UnboundValue;
}

static int pc_remove(const char * const name, R_ObjectTable *tb){
	return 0;
}

static SEXP pc_assign(const char * const name, SEXP value, R_ObjectTable *tb){
	return value;
}

static SEXP pc_objects(R_ObjectTable *tb){
	return allocVector(STRSXP,0);
}

static Rboolean pc_canCache(const char * const name, R_ObjectTable *tb){
	return FALSE;
}

static void     pc_onDetach(R_ObjectTable *tb){
}
static void     pc_onAttach(R_ObjectTable *tb){
}

SEXP activate_popcon(SEXP yesno){
	R_ObjectTable *tb = (R_ObjectTable *) R_ExternalPtrAddr(pcTB);
	tb->active = (LOGICAL(yesno)[0] == TRUE)? TRUE: FALSE;
	return R_NilValue;
}

SEXP init_popcon(SEXP symHandler)
{
	R_ObjectTable *tb;
	SEXP klass;

	if (pcTB != NULL){
		if (symHandler != R_NilValue){
			tb = (R_ObjectTable*) R_ExternalPtrAddr(pcTB);
			R_ReleaseObject((SEXP)tb->privateData);
			R_PreserveObject(symHandler);
			tb->privateData = symHandler;
		}
	   	return pcTB;
	}

	tb = (R_ObjectTable *) calloc(1,sizeof(R_ObjectTable));
	tb->active = TRUE;
	R_PreserveObject(symHandler);
	tb->privateData = (void *)symHandler;

	tb->exists = pc_exists;
	tb->get = pc_get;
	tb->remove = pc_remove;
	tb->assign = pc_assign;
	tb->objects = pc_objects;
	tb->canCache = pc_canCache;
	tb->onAttach = pc_onAttach;
	tb->onDetach = pc_onDetach;

	PROTECT(pcTB = R_MakeExternalPtr(tb, Rf_install("UserDefinedDatabase"), R_NilValue));
	PROTECT(klass = NEW_CHARACTER(1));
	SET_STRING_ELT(klass, 0, COPY_TO_USER_STRING("UserDefinedDatabase"));
	SET_CLASS(pcTB, klass);
	UNPROTECT(2);

	R_PreserveObject(pcTB);
	return(pcTB);
}

static R_CallMethodDef callMethods[]  = {
	{"activate_popcon", (DL_FUNC)&activate_popcon, 1},
	{"init_popcon", (DL_FUNC)&init_popcon, 1},
	{NULL, NULL, 0}
};

static void R_init_PopCon(DllInfo *info){
	R_registerRoutines(info, NULL, callMethods, NULL, NULL);
}

static void R_unload_PopCon(DllInfo *info){
	R_ObjectTable *tb = (R_ObjectTable *) R_ExternalPtrAddr(pcTB);
	R_ReleaseObject(pcTB);
	pcTB = NULL;
	free(tb);
}
