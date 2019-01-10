#include <fcntl.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdlib.h>

extern char **environ;

#ifndef O_BINARY
# define O_BINARY 0
# define O_TEXT 0
#endif

#define _GNU_SOURCE

#define PACKAGE "m4"
#define PACKAGE_BUGREPORT "bug-m4@gnu.org"
#define PACKAGE_NAME "GNU M4"
#define PACKAGE_STRING "GNU M4 {VERSION}"
#define VERSION "{VERSION}"

#define _GL_ARG_NONNULL(x)
#define _GL_ATTRIBUTE_FORMAT_PRINTF(x,y)
#define _GL_ATTRIBUTE_PURE __attribute__ ((__pure__))
#define _GL_EXTERN_INLINE extern inline
#define _GL_INLINE inline
#define _GL_INLINE_HEADER_BEGIN
#define _GL_INLINE_HEADER_END

#if __GNUC__
# define _Noreturn __attribute__ ((__noreturn__))
#endif

#define GNULIB_CLOSE_STREAM 1
#define GNULIB_FILENAMECAT 1

#define HAVE_DECL_STRERROR_R 1
#define HAVE_STACK_T 1
#define HAVE_WORKING_O_NOFOLLOW 1
#define RENAME_OPEN_FILE_WORKS 0

#define SYSCMD_SHELL m4_syscmd_shell()

static inline const char* m4_syscmd_shell() {
    const char *from_env = getenv("M4_SYSCMD_SHELL");
    if (from_env) { return from_env; }
    return "/bin/sh";
}

char *secure_getenv (char const *name);
int vasprintf(char **strp, const char *fmt, va_list ap);
