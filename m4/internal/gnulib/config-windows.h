{GNULIB_CONFIG_HEADER}

#define WINDOWS_NATIVE

#define secure_getenv getenv
#define getpid _getpid
#define popen _popen
#define pclose _pclose

char *mkdtemp(char *template);
int mkstemp(char *template);

#include <process.h>

/* Disable MSVC's assertions that language keywords aren't being
 * shadowed by macros.
**/
#define _XKEYCHECK_H

#pragma include_alias( <gnulib-system-libc/alloca.h>, <alloca.h> )
#pragma include_alias( <alloca.h>, <gnulib/alloca.h> )

#pragma include_alias( <gnulib-system-libc/errno.h>, <errno.h> )
#pragma include_alias( <errno.h>, <gnulib/errno.h> )

#pragma include_alias( <gnulib-system-libc/fcntl.h>, <fcntl.h> )
#pragma include_alias( <fcntl.h>, <gnulib/fcntl.h> )

#pragma include_alias( <gnulib-system-libc/getopt.h>, <getopt.h> )
#pragma include_alias( <getopt.h>, <gnulib/getopt.h> )
#pragma include_alias( "getopt.h", "gnulib/getopt.h" )

#pragma include_alias( <getopt-cdefs.h>, <gnulib/getopt-cdefs.h> )

#pragma include_alias( <gnulib-system-libc/langinfo.h>, <langinfo.h> )
#pragma include_alias( <langinfo.h>, <gnulib/langinfo.h> )

#pragma include_alias( <gnulib-system-libc/locale.h>, <locale.h> )
#pragma include_alias( <locale.h>, <gnulib/locale.h> )

#pragma include_alias( <gnulib-system-libc/sched.h>, <sched.h> )
#pragma include_alias( <sched.h>, <gnulib/sched.h> )

#pragma include_alias( <gnulib-system-libc/signal.h>, <signal.h> )
#pragma include_alias( <signal.h>, <gnulib/signal.h> )

#pragma include_alias( <gnulib-system-libc/spawn.h>, <spawn.h> )
#pragma include_alias( <spawn.h>, <gnulib/spawn.h> )

#pragma include_alias( <gnulib-system-libc/stdio.h>, <stdio.h> )
#pragma include_alias( <stdio.h>, <gnulib/stdio.h> )

#pragma include_alias( <gnulib-system-libc/string.h>, <string.h> )
#pragma include_alias( <string.h>, <gnulib/string.h> )

#pragma include_alias( <gnulib-system-libc/sys/stat.h>, <sys/stat.h> )
#pragma include_alias( <sys/stat.h>, <gnulib/sys/stat.h> )

#pragma include_alias( <gnulib-system-libc/sys/time.h>, <sys/time.h> )
#pragma include_alias( <sys/time.h>, <gnulib/sys/time.h> )

#pragma include_alias( <gnulib-system-libc/sys/types.h>, <sys/types.h> )
#pragma include_alias( <sys/types.h>, <gnulib/sys/types.h> )

#pragma include_alias( <gnulib-system-libc/sys/wait.h>, <sys/wait.h> )
#pragma include_alias( <sys/wait.h>, <gnulib/sys/wait.h> )

#pragma include_alias( <gnulib-system-libc/unistd.h>, <unistd.h> )
#pragma include_alias( <unistd.h>, <gnulib/unistd.h> )

#pragma include_alias( <gnulib-system-libc/wchar.h>, <wchar.h> )
#pragma include_alias( <wchar.h>, <gnulib/wchar.h> )

#pragma include_alias( <gnulib-system-libc/wctype.h>, <wctype.h> )
#pragma include_alias( <wctype.h>, <gnulib/wctype.h> )

/******************************************************************************/

#define CHECK_PRINTF_SAFE 1
#define DBL_EXPBIT0_BIT 20
#define DBL_EXPBIT0_WORD 1
#define DOUBLE_SLASH_IS_DISTINCT_ROOT 1
#define FAULT_YIELDS_SIGBUS 0
#define FLT_EXPBIT0_BIT 23
#define FLT_EXPBIT0_WORD 0
#define FUNC_FFLUSH_STDIN 0
#define FUNC_MKDIR_DOT_BUG 1
#define GETTIMEOFDAY_TIMEZONE void
#define GNULIB_CANONICALIZE_LGPL 1
#define GNULIB_CLOSE_STREAM 1
#define GNULIB_DIRNAME 1
#define GNULIB_FD_SAFER_FLAG 1
#define GNULIB_FFLUSH 1
#define GNULIB_FILENAMECAT 1
#define GNULIB_FOPEN_SAFER 1
#define GNULIB_FSCANF 1
#define GNULIB_LOCK 1
#define GNULIB_MSVC_NOTHROW 1
#define GNULIB_PIPE2_SAFER 1
#define GNULIB_SCANF 1
#define GNULIB_SIGPIPE 1
#define GNULIB_SNPRINTF 1
#define GNULIB_STRERROR 1
#define HAVE_ALLOCA 1
#define HAVE_BTOWC 1
#define HAVE_CRTDEFS_H 1
#define HAVE_DECL_ALARM 0
#define HAVE_DECL_CLEARERR_UNLOCKED 0
#define HAVE_DECL_FEOF_UNLOCKED 0
#define HAVE_DECL_FERROR_UNLOCKED 0
#define HAVE_DECL_FFLUSH_UNLOCKED 0
#define HAVE_DECL_FGETS_UNLOCKED 0
#define HAVE_DECL_FPURGE 0
#define HAVE_DECL_FPUTC_UNLOCKED 0
#define HAVE_DECL_FPUTS_UNLOCKED 0
#define HAVE_DECL_FREAD_UNLOCKED 0
#define HAVE_DECL_FSEEKO 0
#define HAVE_DECL_FTELLO 0
#define HAVE_DECL_FWRITE_UNLOCKED 0
#define HAVE_DECL_GETCHAR_UNLOCKED 0
#define HAVE_DECL_GETC_UNLOCKED 0
#define HAVE_DECL_GETDTABLESIZE 0
#define HAVE_DECL_ISBLANK 1
#define HAVE_DECL_MBSINIT 1
#define HAVE_DECL_PROGRAM_INVOCATION_NAME 0
#define HAVE_DECL_PROGRAM_INVOCATION_SHORT_NAME 0
#define HAVE_DECL_PUTCHAR_UNLOCKED 0
#define HAVE_DECL_PUTC_UNLOCKED 0
#define HAVE_DECL_SIGALTSTACK 0
#define HAVE_DECL_SNPRINTF 1
#define HAVE_DECL_STRERROR_R 0
#define HAVE_DECL_STRNDUP 0
#define HAVE_DECL_STRNLEN 1
#define HAVE_DECL_STRSIGNAL 0
#define HAVE_DECL_SYS_SIGLIST 0
#define HAVE_DECL__FSEEKI64 1
#define HAVE_DECL__SNPRINTF 1
#define HAVE_DECL__SYS_SIGLIST 0
#define HAVE_DECL___ARGV 1
#define HAVE_DUP2 1
#define HAVE_ENVIRON_DECL 1
#define HAVE_FREXP_IN_LIBC 1
#define HAVE_GETCWD 1
#define HAVE_INTMAX_T 1
#define HAVE_INTTYPES_H 1
#define HAVE_INTTYPES_H_WITH_UINTMAX 1
#define HAVE_ISBLANK 1
#define HAVE_ISNAND_IN_LIBC 1
#define HAVE_ISWCNTRL 1
#define HAVE_ISWCTYPE 1
#define HAVE_LDEXPL_IN_LIBC 1
#define HAVE_LDEXP_IN_LIBC 1
#define HAVE_LIMITS_H 1
#define HAVE_LONG_LONG_INT 1
#define HAVE_MALLOC_H 1
#define HAVE_MATH_H 1
#define HAVE_MBRTOWC 1
#define HAVE_MBSTATE_T 1
#define HAVE_MBTOWC 1
#define HAVE_MEMORY_H 1
#define HAVE_MSVC_INVALID_PARAMETER_HANDLER 1
#define HAVE_RAISE 1
#define HAVE_SAME_LONG_DOUBLE_AS_DOUBLE 1
#define HAVE_SIG_ATOMIC_T 1
#define HAVE_SNPRINTF_RETVAL_C99 1
#define HAVE_STDINT_H 1
#define HAVE_STDINT_H_WITH_UINTMAX 1
#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_STRNLEN 1
#define HAVE_STRUCT_LCONV_DECIMAL_POINT 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_TOWLOWER 1
#define HAVE_UNSIGNED_LONG_LONG_INT 1
#define HAVE_WCHAR_H 1
#define HAVE_WCHAR_T 1
#define HAVE_WCRTOMB 1
#define HAVE_WCSLEN 1
#define HAVE_WCSNLEN 1
#define HAVE_WCTYPE_H 1
#define HAVE_WINSOCK2_H 1
#define HAVE_WINT_T 1
#define HAVE_WORKING_O_NOATIME 0
#define HAVE_WORKING_O_NOFOLLOW 0
#define HAVE__BOOL 1
#define HAVE__FSEEKI64 1
#define HAVE__FTELLI64 1
#define HAVE__SET_INVALID_PARAMETER_HANDLER 1
#define HAVE___INLINE 1
#define LDBL_EXPBIT0_BIT 20
#define LDBL_EXPBIT0_WORD 1
#define MALLOC_0_IS_NONNULL 1
# define __USE_MINGW_ANSI_STDIO 1
#define NEED_PRINTF_DIRECTIVE_A 1
#define NEED_PRINTF_DOUBLE 1
#define NEED_PRINTF_ENOMEM 1
#define NEED_PRINTF_FLAG_GROUPING 1
#define NEED_PRINTF_LONG_DOUBLE 1
#define PROMOTED_MODE_T mode_t
#define RENAME_DEST_EXISTS_BUG 1
#define RENAME_TRAILING_SLASH_DEST_BUG 1
#define REPLACE_POSIX_SPAWN 1
#define SIGNAL_SAFE_LIST 1
#define STDC_HEADERS 1
#define USER_LABEL_PREFIX
# define _ALL_SOURCE 1
# define _DARWIN_C_SOURCE 1
# define _GNU_SOURCE 1
# define _NETBSD_SOURCE 1
# define _OPENBSD_SOURCE 1
# define _POSIX_PTHREAD_SEMANTICS 1
# define __STDC_WANT_IEC_60559_ATTRIBS_EXT__ 1
# define __STDC_WANT_IEC_60559_BFP_EXT__ 1
# define __STDC_WANT_IEC_60559_DFP_EXT__ 1
# define __STDC_WANT_IEC_60559_FUNCS_EXT__ 1
# define __STDC_WANT_IEC_60559_TYPES_EXT__ 1
# define __STDC_WANT_LIB_EXT2__ 1
# define __STDC_WANT_MATH_SPEC_FUNCS__ 1
# define _TANDEM_SOURCE 1
# define _HPUX_ALT_XOPEN_SOCKET_API 1
# define __EXTENSIONS__ 1
#define USE_UNLOCKED_IO 1
#define _DARWIN_USE_64_BIT_INODE 1
#define _NETBSD_SOURCE 1
#define _REGEX_INCLUDE_LIMITS_H 1
#define _REGEX_LARGE_OFFSETS 1
#define _USE_STD_STAT 1
#define __GETOPT_PREFIX rpl_
#define gid_t int
#define mode_t int
#define nlink_t int
#define pid_t int
#define re_comp rpl_re_comp
#define re_compile_fastmap rpl_re_compile_fastmap
#define re_compile_pattern rpl_re_compile_pattern
#define re_exec rpl_re_exec
#define re_match rpl_re_match
#define re_match_2 rpl_re_match_2
#define re_search rpl_re_search
#define re_search_2 rpl_re_search_2
#define re_set_registers rpl_re_set_registers
#define re_set_syntax rpl_re_set_syntax
#define re_syntax_options rpl_re_syntax_options
#define regcomp rpl_regcomp
#define regerror rpl_regerror
#define regexec rpl_regexec
#define regfree rpl_regfree
#define restrict /**/
#define ssize_t int
#define uid_t int

{GNULIB_CONFIG_FOOTER}
