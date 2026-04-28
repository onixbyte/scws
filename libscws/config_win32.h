#ifndef CONFIG_W32_H
#define CONFIG_W32_H

#include <windows.h>
#include <io.h>

/* Configuration for Windows - undefine features not available */
#ifdef HAVE_MMAP
#undef HAVE_MMAP
#endif
#ifdef HAVE_FLOCK
#undef HAVE_FLOCK
#endif
#ifdef HAVE_STRUCT_FLOCK
#undef HAVE_STRUCT_FLOCK
#endif

#ifndef inline
#	define inline   __inline
#endif

#define strcasecmp(s1, s2) _stricmp(s1, s2)
#define strncasecmp(s1, s2, n) strnicmp(s1, s2, n)

#ifndef S_ISREG 
#define S_ISREG(m) (((m) & S_IFMT) == S_IFREG)
#endif

#ifndef logf 
/* MinGW provides logf function, so we don't need to redefine it */
#if !defined(__MINGW32__) && !defined(__MINGW64__)
#define logf(x)     ((float)log((double)(x)))
#endif
#endif

#endif
