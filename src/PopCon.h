#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
#include <R_ext/Callbacks.h>
#include <R_ext/Rdynload.h>

/* Object Table functions */
static Rboolean pc_exists(const char * const name, Rboolean *canCache, R_ObjectTable *);
static SEXP     pc_get(const char * const name, Rboolean *canCache, R_ObjectTable *);
static int      pc_remove(const char * const name, R_ObjectTable *);
static SEXP     pc_assign(const char * const name, SEXP value, R_ObjectTable *);
static SEXP     pc_objects(R_ObjectTable *);
static Rboolean pc_canCache(const char * const name, R_ObjectTable *);

static void     pc_onDetach(R_ObjectTable *);
static void     pc_onAttach(R_ObjectTable *);

/* .Call(s) from R */
SEXP activate_popcon(SEXP yesno);
SEXP init_popcon(SEXP symHandler);
