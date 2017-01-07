//#include "../ff.h"

#if _USE_LFN != 0

#if   _CODE_PAGE == 932	/* Japanese Shift_JIS */
#include "cc932_avr.c"
#else					/* Single Byte Character-Set */
#include "ccsbcs_avr.c"
#endif

#endif
