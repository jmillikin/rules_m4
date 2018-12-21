#include <stdint.h>
#include <fcntl.h>

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
#define _GL_ATTRIBUTE_PURE __attribute__ ((pure))
#define _GL_EXTERN_INLINE extern inline
#define _GL_INLINE inline
#define _GL_INLINE_HEADER_BEGIN
#define _GL_INLINE_HEADER_END

#define GNULIB_CLOSE_STREAM 1
#define GNULIB_FILENAMECAT 1

#define HAVE_DECL_STRERROR_R 1
#define HAVE_STACK_T 1
#define HAVE_WORKING_O_NOFOLLOW 1
#define RENAME_OPEN_FILE_WORKS 0

#define SYSCMD_SHELL "/bin/false"

char *secure_getenv (char const *name);
