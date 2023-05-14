# Copyright 2019 the rules_m4 authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

"""Helpers and shims for building the GNU anti-portability library."""

_GNULIB_VERSION = "788db09a9f88abbef73c97e8d7291c40455336d8"
_GNULIB_SHA256 = "27ef79e649c95856e05f82414977f5e05d009310f91916b64806d1c61f913485"

_URL_BASE = "https://github.com/jmillikin/rules_m4/releases/download/v0.1/m4-gnulib-{}.tar.xz"

_CONFIG_HEADER = """
#include "gnulib/lib/config.in.h"
#include "gnulib/lib/arg-nonnull.h"

#define PRODUCT "m4"
#define PACKAGE "m4"
#define PACKAGE_BUGREPORT "bug-m4@gnu.org"
#define PACKAGE_NAME "GNU M4"
#define PACKAGE_STRING "GNU M4 {M4_VERSION}"
#define PACKAGE_TARNAME "m4"
#define PACKAGE_URL "http://www.gnu.org/software/m4/"
#define PACKAGE_VERSION "{M4_VERSION}"
#define VERSION "{M4_VERSION}"

#define RENAME_OPEN_FILE_WORKS 0
#define HAVE_TMPFILE 1
#define HAVE_SIGNAL_H 1
#define RETSIGTYPE void
"""

_CONFIG_FOOTER = """
#include <stdlib.h>

/* Allow SYSCMD_SHELL to be injected at runtime, for users that don't
 * want arbitrary code execution in their template expansions.
**/
#define SYSCMD_SHELL m4_syscmd_shell()

static inline const char* m4_syscmd_shell() {
    const char *from_env = getenv("M4_SYSCMD_SHELL");
    if (from_env) { return from_env; }
    return "/bin/sh";
}

#if HAVE_DECL_PROGRAM_INVOCATION_SHORT_NAME
extern char *program_invocation_short_name;
#endif

#if HAVE_DECL_PROGRAM_INVOCATION_NAME
extern char *program_invocation_name;
#endif

#if HAVE_SECURE_GETENV
char *secure_getenv(char const *name);
#endif
"""

def gnulib_overlay(ctx, m4_version, extra_copts = []):
    """Download the gnulib overlay and apply compatibility patches.

    Args:
        ctx: A `repository_ctx`.
        m4_version: Which version of GNU M4 is being built.
        extra_copts: Additional C compiler options to use when building gnulib.

    """
    ctx.download_and_extract(
        url = [_URL_BASE.format(_GNULIB_VERSION)],
        sha256 = _GNULIB_SHA256,
        output = "gnulib",
        stripPrefix = "gnulib-" + _GNULIB_VERSION,
    )
    ctx.template("gnulib/BUILD.bazel", ctx.attr._gnulib_build, substitutions = {
        "{GNULIB_EXTRA_COPTS}": str(extra_copts),
    }, executable = False)

    config_header = _CONFIG_HEADER.format(
        M4_VERSION = m4_version,
    )
    ctx.template("gnulib/config-darwin/config.h", ctx.attr._gnulib_config_darwin_h, substitutions = {
        "{GNULIB_CONFIG_HEADER}": config_header,
        "{GNULIB_CONFIG_FOOTER}": _CONFIG_FOOTER,
    }, executable = False)
    ctx.template("gnulib/config-linux/config.h", ctx.attr._gnulib_config_linux_h, substitutions = {
        "{GNULIB_CONFIG_HEADER}": config_header,
        "{GNULIB_CONFIG_FOOTER}": _CONFIG_FOOTER,
    }, executable = False)
    ctx.template("gnulib/config-windows/config.h", ctx.attr._gnulib_config_windows_h, substitutions = {
        "{GNULIB_CONFIG_HEADER}": config_header,
        "{GNULIB_CONFIG_FOOTER}": _CONFIG_FOOTER,
    }, executable = False)
    ctx.template("gnulib/config-openbsd/config.h", ctx.attr._gnulib_config_openbsd_h, substitutions = {
        "{GNULIB_CONFIG_HEADER}": config_header,
        "{GNULIB_CONFIG_FOOTER}": _CONFIG_FOOTER,
    }, executable = False)

    for shim in _WINDOWS_STDLIB_SHIMS:
        in_h = "gnulib/lib/{}.in.h".format(shim.replace("/", "_"))
        out_h = "gnulib/config-windows/shim-libc/gnulib/{}.h".format(shim)
        ctx.template(out_h, in_h, substitutions = _WINDOWS_AC_SUBST, executable = False)

    # Older versions of M4 expect gnulib shims for exit() and strstr()
    ctx.file("gnulib/lib/exit.h", "#include <stdlib.h>")
    ctx.file("gnulib/lib/strstr.h", "#include <string.h>")

    # gnulib inspects inner details of FILE* based on hard-coded structs defined
    # for a handful of target platforms. Disable the whole mess so M4 can be
    # built with musl libc.
    #
    # Context:
    # * https://wiki.musl-libc.org/faq.html#Q:-I'm-getting-a-gnulib-error
    # * https://github.com/jmillikin/rules_m4/issues/4
    ctx.file("gnulib/lib/fpending.c", "#include <stdio.h>\nsize_t __fpending(FILE *fp) { return 1; }")
    ctx.file("gnulib/lib/freadahead.c", "#include <stdio.h>\nsize_t freadahead(FILE *fp) { return 1; }")

    # Stub out the sandbox-escaping charset alias loader.
    ctx.template("gnulib/lib/localcharset.c", "gnulib/lib/localcharset.c", substitutions = {
        "get_charset_aliases (void)": '''
get_charset_aliases (void) { return ""; }
#define LIBDIR ""
static const char * _replaced_get_charset_aliases (void) _GL_UNUSED;
static const char * _replaced_get_charset_aliases (void)
''',
    }, executable = False)

    # Fix a mismatch between _Noreturn and __attribute_noreturn__ when
    # building with a C11-aware GCC.
    ctx.template("gnulib/lib/obstack.c", "gnulib/lib/obstack.c", substitutions = {
        "static _Noreturn void": "static _Noreturn __attribute_noreturn__ void",
    })

    # If _GNU_SOURCE is defined, some versions of GNU libc define SIGSTKSZ to
    # be a function call. This breaks an assumption in gnulib that SIGSTKSZ is
    # a macro constant.
    #
    # If undefined, gnulib sets it to a reasonable default instead of failing
    # to compile.
    #
    # https://github.com/jmillikin/rules_m4/issues/9
    ctx.template("gnulib/lib/c-stack.c", "gnulib/lib/c-stack.c", substitutions = {
        "SIGSTKSZ": "GNULIB_SIGSTKSZ",
    })

    # Some platforms have alloca() but not <alloca.h>.
    ctx.file("gnulib/stub-alloca/alloca.h", "")

    # Silence warning about unused variable when HAVE_SNPRINTF is defined 0.
    ctx.template("gnulib/lib/vasnprintf.c", "gnulib/lib/vasnprintf.c", substitutions = {
        "int flags = dp->flags;": "int flags = dp->flags; (void)flags;",
    })

_WINDOWS_STDLIB_SHIMS = [
    "alloca",
    "errno",
    "fcntl",
    "getopt",
    "getopt-cdefs",
    "langinfo",
    "locale",
    "signal",
    "stdio",
    "string",
    "sys/stat",
    "sys/time",
    "sys/types",
    "sys/wait",
    "unistd",
    "wchar",
    "wctype",
]

_WINDOWS_AC_SUBST = {
    "@PRAGMA_SYSTEM_HEADER@": "",
    "@PRAGMA_COLUMNS@": "",
    "@INCLUDE_NEXT@": "include",
    "@GUARD_PREFIX@": "GL_M4",
    "@ASM_SYMBOL_PREFIX@": '""',
    "/* The definitions of _GL_FUNCDECL_RPL etc. are copied here.  */": '#include "gnulib/lib/c++defs.h"',
    "/* The definition of _GL_ARG_NONNULL is copied here.  */": '#include "gnulib/lib/arg-nonnull.h"',
    "/* The definition of _GL_WARN_ON_USE is copied here.  */": '#include "gnulib/lib/warn-on-use.h"',

    # alloca.h

    # errno.h
    "@NEXT_ERRNO_H@": "<gnulib-system-libc/errno.h>",
    "@EMULTIHOP_HIDDEN@": "0",
    "@EMULTIHOP_VALUE@": "EMULTIHOP",
    "@ENOLINK_HIDDEN@": "0",
    "@ENOLINK_VALUE@": "ENOLINK",
    "@EOVERFLOW_HIDDEN@": "0",
    "@EOVERFLOW_VALUE@": "EOVERFLOW",

    # fcntl.h
    "@NEXT_FCNTL_H@": "<gnulib-system-libc/fcntl.h>",
    "@GNULIB_FCNTL@": "1",
    "@REPLACE_FCNTL@": "0",
    "@HAVE_FCNTL@": "0",
    "@GNULIB_OPEN@": "1",
    "@REPLACE_OPEN@": "0",
    "@GNULIB_OPENAT@": "0",
    "@REPLACE_OPENAT@": "0",
    "@HAVE_OPENAT@": "1",
    "@GNULIB_NONBLOCKING@": "0",

    # getopt.h
    "@HAVE_GETOPT_H@": "0",
    "@NEXT_GETOPT_H@": "<gnulib-system-libc/getopt.h>",

    # getopt-cdefs.h
    "@HAVE_SYS_CDEFS_H@": "0",

    # langinfo.h
    "@NEXT_LANGINFO_H@": "<gnulib-system-libc/langinfo.h>",
    "@HAVE_LANGINFO_H@": "0",
    "@HAVE_LANGINFO_CODESET@": "0",
    "@HAVE_LANGINFO_T_FMT_AMPM@": "0",
    "@HAVE_LANGINFO_ERA@": "0",
    "@HAVE_LANGINFO_YESEXPR@": "0",
    "@GNULIB_NL_LANGINFO@": "1",
    "@REPLACE_NL_LANGINFO@": "0",
    "@HAVE_NL_LANGINFO@": "0",

    # locale.h
    "@NEXT_LOCALE_H@": "<gnulib-system-libc/locale.h>",
    "@HAVE_XLOCALE_H@": "0",
    "@REPLACE_STRUCT_LCONV@": "1",
    "@GNULIB_LOCALECONV@": "1",
    "@REPLACE_LOCALECONV@": "1",
    "@GNULIB_SETLOCALE@": "IN_M4_GNULIB_TESTS",
    "@REPLACE_SETLOCALE@": "0",
    "@GNULIB_DUPLOCALE@": "0",
    "@REPLACE_DUPLOCALE@": "0",
    "@HAVE_DUPLOCALE@": "1",
    "@GNULIB_LOCALENAME@": "0",
    "@HAVE_NEWLOCALE@": "1",
    "@HAVE_FREELOCALE@": "1",

    # signal.h
    "@NEXT_SIGNAL_H@": "<gnulib-system-libc/signal.h>",
    "@GNULIB_PTHREAD_SIGMASK@": "0",
    "@HAVE_TYPE_VOLATILE_SIG_ATOMIC_T@": "1",
    "@HAVE_SIGSET_T@": "0",
    "@HAVE_SIGHANDLER_T@": "0",
    "@GNULIB_SIGNAL_H_SIGPIPE@": "1",
    "@REPLACE_PTHREAD_SIGMASK@": "0",
    "@HAVE_PTHREAD_SIGMASK@": "1",
    "@GNULIB_RAISE@": "1",
    "@REPLACE_RAISE@": "1",
    "@HAVE_RAISE@": "1",
    "@GNULIB_SIGPROCMASK@": "1",
    "@HAVE_POSIX_SIGNALBLOCKING@": "0",
    "@GNULIB_SIGACTION@": "1",
    "@HAVE_SIGACTION@": "0",
    "@HAVE_SIGINFO_T@": "0",
    "@HAVE_STRUCT_SIGACTION_SA_SIGACTION@": "1",

    # stdio.h
    "@NEXT_STDIO_H@": "<gnulib-system-libc/stdio.h>",
    "@GNULIB_RENAMEAT@": "0",
    "@GNULIB_PERROR@": "0",
    "@GNULIB_REMOVE@": "0",
    "@GNULIB_RENAME@": "1",
    "@GNULIB_DPRINTF@": "0",
    "@REPLACE_DPRINTF@": "0",
    "@HAVE_DPRINTF@": "1",
    "@GNULIB_FCLOSE@": "1",
    "@REPLACE_FCLOSE@": "1",
    "@GNULIB_FDOPEN@": "IN_M4_GNULIB_TESTS",
    "@REPLACE_FDOPEN@": "1",
    "@GNULIB_FFLUSH@": "1",
    "@REPLACE_FFLUSH@": "1",
    "@GNULIB_FGETC@": "1",
    "@REPLACE_STDIO_READ_FUNCS@": "0",
    "@GNULIB_STDIO_H_NONBLOCKING@": "0",
    "@GNULIB_FGETS@": "1",
    "@GNULIB_FOPEN@": "1",
    "@REPLACE_FOPEN@": "0",
    "@GNULIB_FPRINTF_POSIX@": "0",
    "@GNULIB_FPRINTF@": "1",
    "@REPLACE_FPRINTF@": "0",
    "@REPLACE_STDIO_WRITE_FUNCS@": "1",
    "@GNULIB_STDIO_H_SIGPIPE@": "1",
    "@GNULIB_VFPRINTF_POSIX@": "0",
    "@GNULIB_FPURGE@": "1",
    "@REPLACE_FPURGE@": "0",
    "@HAVE_DECL_FPURGE@": "0",
    "@GNULIB_FPUTC@": "1",
    "@GNULIB_FREAD@": "1",
    "@GNULIB_FREOPEN@": "0",
    "@REPLACE_FREOPEN@": "0",
    "@GNULIB_FSCANF@": "1",
    "@GNULIB_FSEEK@": "1",
    "@REPLACE_FSEEK@": "1",
    "@GNULIB_FSEEKO@": "1",
    "@REPLACE_FSEEKO@": "0",
    "@HAVE_DECL_FSEEKO@": "0",
    "@GNULIB_FTELL@": "1",
    "@REPLACE_FTELL@": "1",
    "@GNULIB_FTELLO@": "1",
    "@REPLACE_FTELLO@": "0",
    "@HAVE_DECL_FTELLO@": "0",
    "@GNULIB_FWRITE@": "1",
    "@GNULIB_GETC@": "1",
    "@GNULIB_GETCHAR@": "1",
    "@GNULIB_GETDELIM@": "0",
    "@REPLACE_GETDELIM@": "0",
    "@HAVE_DECL_GETDELIM@": "1",
    "@GNULIB_GETLINE@": "0",
    "@REPLACE_GETLINE@": "0",
    "@HAVE_DECL_GETLINE@": "1",
    "@GNULIB_OBSTACK_PRINTF@": "0",
    "@GNULIB_OBSTACK_PRINTF_POSIX@": "0",
    "@REPLACE_OBSTACK_PRINTF@": "0",
    "@HAVE_DECL_OBSTACK_PRINTF@": "1",
    "@GNULIB_PCLOSE@": "0",
    "@HAVE_PCLOSE@": "1",
    "@REPLACE_PERROR@": "0",
    "@GNULIB_POPEN@": "0",
    "@REPLACE_POPEN@": "0",
    "@HAVE_POPEN@": "1",
    "@GNULIB_PRINTF_POSIX@": "0",
    "@GNULIB_PRINTF@": "1",
    "@REPLACE_PRINTF@": "0",
    "@GNULIB_PUTC@": "1",
    "@GNULIB_PUTCHAR@": "1",
    "@GNULIB_PUTS@": "1",
    "@REPLACE_RENAME@": "1",
    "@REPLACE_RENAMEAT@": "0",
    "@HAVE_RENAMEAT@": "1",
    "@GNULIB_SCANF@": "1",
    "@GNULIB_SNPRINTF@": "1",
    "@REPLACE_SNPRINTF@": "1",
    "@HAVE_DECL_SNPRINTF@": "1",
    "@GNULIB_SPRINTF_POSIX@": "0",
    "@REPLACE_SPRINTF@": "0",
    "@GNULIB_TMPFILE@": "0",
    "@REPLACE_TMPFILE@": "0",
    "@GNULIB_VASPRINTF@": "1",
    "@REPLACE_VASPRINTF@": "0",
    "@HAVE_VASPRINTF@": "0",
    "@GNULIB_VDPRINTF@": "0",
    "@REPLACE_VDPRINTF@": "0",
    "@HAVE_VDPRINTF@": "1",
    "@GNULIB_VFSCANF@": "0",
    "@GNULIB_FPUTS@": "1",
    "@REPLACE_REMOVE@": "0",
    "@GNULIB_VFPRINTF@": "1",
    "@REPLACE_VFPRINTF@": "0",
    "@GNULIB_VPRINTF_POSIX@": "0",
    "@GNULIB_VSCANF@": "0",
    "@GNULIB_VSNPRINTF@": "0",
    "@REPLACE_VSNPRINTF@": "0",
    "@HAVE_DECL_VSNPRINTF@": "1",
    "@GNULIB_VSPRINTF_POSIX@": "0",
    "@REPLACE_VSPRINTF@": "0",
    "@GNULIB_VPRINTF@": "1",
    "@REPLACE_VPRINTF@": "0",

    # string.h
    "@NEXT_STRING_H@": "<gnulib-system-libc/string.h>",
    "@GNULIB_MBSLEN@": "0",
    "@GNULIB_STRSIGNAL@": "1",
    "@GNULIB_FFSL@": "0",
    "@HAVE_FFSL@": "1",
    "@GNULIB_FFSLL@": "0",
    "@HAVE_FFSLL@": "1",
    "@GNULIB_MEMCHR@": "1",
    "@REPLACE_MEMCHR@": "0",
    "@HAVE_MEMCHR@": "1",
    "@GNULIB_MEMMEM@": "0",
    "@REPLACE_MEMMEM@": "0",
    "@HAVE_DECL_MEMMEM@": "1",
    "@GNULIB_MEMPCPY@": "0",
    "@HAVE_MEMPCPY@": "1",
    "@GNULIB_MEMRCHR@": "0",
    "@HAVE_DECL_MEMRCHR@": "1",
    "@GNULIB_RAWMEMCHR@": "1",
    "@HAVE_RAWMEMCHR@": "0",
    "@GNULIB_STPCPY@": "0",
    "@HAVE_STPCPY@": "1",
    "@GNULIB_STPNCPY@": "0",
    "@REPLACE_STPNCPY@": "0",
    "@HAVE_STPNCPY@": "1",
    "@GNULIB_STRCHRNUL@": "1",
    "@REPLACE_STRCHRNUL@": "0",
    "@HAVE_STRCHRNUL@": "0",
    "@GNULIB_STRDUP@": "IN_M4_GNULIB_TESTS",
    "@REPLACE_STRDUP@": "1",
    "@HAVE_DECL_STRDUP@": "1",
    "@GNULIB_STRNCAT@": "0",
    "@REPLACE_STRNCAT@": "0",
    "@GNULIB_STRNDUP@": "1",
    "@REPLACE_STRNDUP@": "0",
    "@HAVE_DECL_STRNDUP@": "0",
    "@GNULIB_STRNLEN@": "1",
    "@REPLACE_STRNLEN@": "0",
    "@HAVE_DECL_STRNLEN@": "1",
    "@GNULIB_STRPBRK@": "0",
    "@HAVE_STRPBRK@": "1",
    "@GNULIB_STRSEP@": "0",
    "@HAVE_STRSEP@": "1",
    "@GNULIB_STRSTR@": "1",
    "@REPLACE_STRSTR@": "1",
    "@GNULIB_STRCASESTR@": "0",
    "@REPLACE_STRCASESTR@": "0",
    "@HAVE_STRCASESTR@": "1",
    "@GNULIB_STRTOK_R@": "0",
    "@REPLACE_STRTOK_R@": "0",
    "@UNDEFINE_STRTOK_R@": "0",
    "@HAVE_DECL_STRTOK_R@": "1",
    "@HAVE_MBSLEN@": "0",
    "@GNULIB_MBSNLEN@": "0",
    "@GNULIB_MBSCHR@": "0",
    "@GNULIB_MBSRCHR@": "0",
    "@GNULIB_MBSSTR@": "0",
    "@GNULIB_MBSCASECMP@": "0",
    "@GNULIB_MBSNCASECMP@": "0",
    "@GNULIB_MBSPCASECMP@": "0",
    "@GNULIB_MBSCASESTR@": "0",
    "@GNULIB_MBSCSPN@": "0",
    "@GNULIB_MBSPBRK@": "0",
    "@GNULIB_MBSSPN@": "0",
    "@GNULIB_MBSSEP@": "0",
    "@GNULIB_MBSTOK_R@": "0",
    "@GNULIB_STRERROR@": "1",
    "@REPLACE_STRERROR@": "1",
    "@GNULIB_STRERROR_R@": "0",
    "@REPLACE_STRERROR_R@": "0",
    "@HAVE_DECL_STRERROR_R@": "1",
    "@REPLACE_STRSIGNAL@": "0",
    "@HAVE_DECL_STRSIGNAL@": "0",
    "@GNULIB_STRVERSCMP@": "0",
    "@HAVE_STRVERSCMP@": "1",
    "@GNULIB_EXPLICIT_BZERO@": "0",
    "@HAVE_EXPLICIT_BZERO@": "1",

    # sys/stat.h
    "@NEXT_SYS_STAT_H@": "<gnulib-system-libc/sys/stat.h>",
    "@WINDOWS_64_BIT_ST_SIZE@": "1",
    "@GNULIB_FCHMODAT@": "0",
    "@HAVE_FCHMODAT@": "1",
    "@GNULIB_FSTAT@": "1",
    "@REPLACE_FSTAT@": "1",
    "@GNULIB_FSTATAT@": "0",
    "@REPLACE_FSTATAT@": "0",
    "@HAVE_FSTATAT@": "1",
    "@GNULIB_FUTIMENS@": "0",
    "@REPLACE_FUTIMENS@": "0",
    "@HAVE_FUTIMENS@": "1",
    "@GNULIB_LCHMOD@": "0",
    "@HAVE_LCHMOD@": "1",
    "@GNULIB_LSTAT@": "1",
    "@HAVE_LSTAT@": "0",
    "@REPLACE_LSTAT@": "0",
    "@REPLACE_MKDIR@": "0",
    "@GNULIB_MKDIRAT@": "0",
    "@HAVE_MKDIRAT@": "1",
    "@GNULIB_MKFIFO@": "0",
    "@REPLACE_MKFIFO@": "0",
    "@HAVE_MKFIFO@": "1",
    "@GNULIB_MKFIFOAT@": "0",
    "@HAVE_MKFIFOAT@": "1",
    "@GNULIB_MKNOD@": "0",
    "@REPLACE_MKNOD@": "0",
    "@HAVE_MKNOD@": "1",
    "@GNULIB_MKNODAT@": "0",
    "@HAVE_MKNODAT@": "1",
    "@GNULIB_STAT@": "1",
    "@REPLACE_STAT@": "0",
    "@GNULIB_UTIMENSAT@": "0",
    "@REPLACE_UTIMENSAT@": "0",
    "@HAVE_UTIMENSAT@": "1",
    "@GNULIB_OVERRIDES_STRUCT_STAT@": "0",

    # sys/time.h
    "@NEXT_SYS_TIME_H@": "<gnulib-system-libc/sys/time.h>",
    "@HAVE_SYS_TIME_H@": "0",
    "@REPLACE_STRUCT_TIMEVAL@": "1",
    "@HAVE_WINSOCK2_H@": "1",
    "@HAVE_STRUCT_TIMEVAL@": "1",
    "@GNULIB_GETTIMEOFDAY@": "1",
    "@REPLACE_GETTIMEOFDAY@": "0",
    "@HAVE_GETTIMEOFDAY@": "0",

    # sys/types.h
    "@NEXT_SYS_TYPES_H@": "<gnulib-system-libc/sys/types.h>",
    "@WINDOWS_STAT_INODES@": "0",

    # sys/wait.h
    "@NEXT_SYS_WAIT_H@": "<gnulib-system-libc/sys/wait.h>",
    "@GNULIB_WAITPID@": "1",

    # unistd.h
    "@NEXT_UNISTD_H@": "<gnulib-system-libc/unistd.h>",
    "@HAVE_UNISTD_H@": "0",
    "@GNULIB_GETHOSTNAME@": "0",
    "@UNISTD_H_HAVE_WINSOCK2_H@": "1",
    "@GNULIB_UNLINK@": "0",
    "@GNULIB_SYMLINKAT@": "0",
    "@GNULIB_UNLINKAT@": "0",
    "@GNULIB_CHDIR@": "1",
    "@GNULIB_CLOSE@": "1",
    "@GNULIB_DUP@": "IN_M4_GNULIB_TESTS",
    "@GNULIB_DUP2@": "1",
    "@GNULIB_ISATTY@": "0",
    "@GNULIB_LSEEK@": "1",
    "@GNULIB_READ@": "0",
    "@GNULIB_WRITE@": "IN_M4_GNULIB_TESTS",
    "@GNULIB_GETDOMAINNAME@": "0",
    "@WINDOWS_64_BIT_OFF_T@": "1",
    "@GNULIB_READLINK@": "1",
    "@HAVE_READLINK@": "0",
    "@GNULIB_READLINKAT@": "0",
    "@GNULIB_PREAD@": "0",
    "@GNULIB_PWRITE@": "0",
    "@GNULIB_UNISTD_H_GETOPT@": "1",
    "@GNULIB_CHOWN@": "0",
    "@REPLACE_CHOWN@": "0",
    "@HAVE_CHOWN@": "1",
    "@REPLACE_CLOSE@": "1",
    "@UNISTD_H_HAVE_WINSOCK2_H_AND_USE_SOCKETS@": "0",
    "@REPLACE_DUP@": "1",
    "@REPLACE_DUP2@": "1",
    "@GNULIB_DUP3@": "0",
    "@HAVE_DUP3@": "1",
    "@GNULIB_ENVIRON@": "1",
    "@HAVE_DECL_ENVIRON@": "1",
    "@GNULIB_EUIDACCESS@": "0",
    "@HAVE_EUIDACCESS@": "1",
    "@GNULIB_FACCESSAT@": "0",
    "@HAVE_FACCESSAT@": "1",
    "@GNULIB_FCHDIR@": "0",
    "@HAVE_FCHDIR@": "1",
    "@HAVE_DECL_FCHDIR@": "1",
    "@GNULIB_FCHOWNAT@": "0",
    "@REPLACE_FCHOWNAT@": "0",
    "@HAVE_FCHOWNAT@": "1",
    "@GNULIB_FDATASYNC@": "0",
    "@HAVE_FDATASYNC@": "1",
    "@HAVE_DECL_FDATASYNC@": "1",
    "@GNULIB_FSYNC@": "0",
    "@HAVE_FSYNC@": "1",
    "@GNULIB_FTRUNCATE@": "0",
    "@HAVE_FTRUNCATE@": "1",
    "@GNULIB_GETCWD@": "IN_M4_GNULIB_TESTS",
    "@REPLACE_GETCWD@": "1",
    "@REPLACE_GETDOMAINNAME@": "0",
    "@HAVE_DECL_GETDOMAINNAME@": "1",
    "@GNULIB_GETDTABLESIZE@": "1",
    "@REPLACE_GETDTABLESIZE@": "0",
    "@HAVE_GETDTABLESIZE@": "0",
    "@GNULIB_GETGROUPS@": "0",
    "@HAVE_GETGROUPS@": "1",
    "@HAVE_GETHOSTNAME@": "1",
    "@GNULIB_GETLOGIN@": "0",
    "@HAVE_DECL_GETLOGIN@": "1",
    "@GNULIB_GETLOGIN_R@": "0",
    "@REPLACE_GETLOGIN_R@": "0",
    "@HAVE_DECL_GETLOGIN_R@": "1",
    "@GNULIB_GETPAGESIZE@": "IN_M4_GNULIB_TESTS",
    "@REPLACE_GETPAGESIZE@": "0",
    "@HAVE_GETPAGESIZE@": "0",
    "@HAVE_OS_H@": "0",
    "@HAVE_SYS_PARAM_H@": "0",
    "@HAVE_DECL_GETPAGESIZE@": "0",
    "@GNULIB_GETUSERSHELL@": "0",
    "@HAVE_DECL_GETUSERSHELL@": "1",
    "@GNULIB_GROUP_MEMBER@": "0",
    "@HAVE_GROUP_MEMBER@": "1",
    "@REPLACE_ISATTY@": "0",
    "@GNULIB_LCHOWN@": "0",
    "@REPLACE_LCHOWN@": "0",
    "@HAVE_LCHOWN@": "1",
    "@GNULIB_LINK@": "0",
    "@REPLACE_LINK@": "0",
    "@HAVE_LINK@": "0",
    "@GNULIB_LINKAT@": "0",
    "@REPLACE_LINKAT@": "0",
    "@HAVE_LINKAT@": "1",
    "@REPLACE_LSEEK@": "0",
    "@GNULIB_PIPE@": "0",
    "@HAVE_PIPE@": "1",
    "@GNULIB_PIPE2@": "1",
    "@HAVE_PIPE2@": "0",
    "@REPLACE_PREAD@": "0",
    "@HAVE_PREAD@": "1",
    "@REPLACE_PWRITE@": "0",
    "@HAVE_PWRITE@": "1",
    "@REPLACE_READ@": "0",
    "@REPLACE_READLINK@": "0",
    "@REPLACE_READLINKAT@": "0",
    "@HAVE_READLINKAT@": "1",
    "@GNULIB_RMDIR@": "1",
    "@REPLACE_RMDIR@": "1",
    "@GNULIB_SETHOSTNAME@": "0",
    "@HAVE_SETHOSTNAME@": "1",
    "@HAVE_DECL_SETHOSTNAME@": "1",
    "@GNULIB_SLEEP@": "IN_M4_GNULIB_TESTS",
    "@REPLACE_SLEEP@": "0",
    "@HAVE_SLEEP@": "0",
    "@GNULIB_SYMLINK@": "IN_M4_GNULIB_TESTS",
    "@REPLACE_SYMLINK@": "0",
    "@HAVE_SYMLINK@": "0",
    "@REPLACE_SYMLINKAT@": "0",
    "@HAVE_SYMLINKAT@": "1",
    "@GNULIB_TTYNAME_R@": "0",
    "@REPLACE_TTYNAME_R@": "0",
    "@HAVE_DECL_TTYNAME_R@": "1",
    "@REPLACE_UNLINK@": "0",
    "@REPLACE_UNLINKAT@": "0",
    "@HAVE_UNLINKAT@": "1",
    "@GNULIB_USLEEP@": "0",
    "@REPLACE_USLEEP@": "0",
    "@HAVE_USLEEP@": "1",
    "@REPLACE_WRITE@": "1",
    "@GNULIB_GETPASS@": "0",
    "@GNULIB_TRUNCATE@": "0",

    # wchar.h
    "@HAVE_WCHAR_H@": "1",
    "@NEXT_WCHAR_H@": "<gnulib-system-libc/wchar.h>",
    "@HAVE_FEATURES_H@": "0",
    "@HAVE_WINT_T@": "1",
    "@GNULIB_OVERRIDES_WINT_T@": "1",
    "@HAVE_MBSINIT@": "0",
    "@HAVE_MBRTOWC@": "1",
    "@REPLACE_MBSTATE_T@": "1",
    "@GNULIB_BTOWC@": "1",
    "@REPLACE_BTOWC@": "0",
    "@HAVE_BTOWC@": "1",
    "@GNULIB_WCTOB@": "IN_M4_GNULIB_TESTS",
    "@REPLACE_WCTOB@": "1",
    "@HAVE_DECL_WCTOB@": "1",
    "@GNULIB_MBSINIT@": "1",
    "@REPLACE_MBSINIT@": "1",
    "@GNULIB_MBRTOWC@": "1",
    "@REPLACE_MBRTOWC@": "1",
    "@GNULIB_MBRLEN@": "0",
    "@REPLACE_MBRLEN@": "0",
    "@HAVE_MBRLEN@": "1",
    "@GNULIB_MBSRTOWCS@": "0",
    "@REPLACE_MBSRTOWCS@": "0",
    "@HAVE_MBSRTOWCS@": "1",
    "@GNULIB_MBSNRTOWCS@": "0",
    "@REPLACE_MBSNRTOWCS@": "0",
    "@HAVE_MBSNRTOWCS@": "1",
    "@GNULIB_WCRTOMB@": "1",
    "@REPLACE_WCRTOMB@": "1",
    "@HAVE_WCRTOMB@": "1",
    "@GNULIB_WCSRTOMBS@": "0",
    "@REPLACE_WCSRTOMBS@": "0",
    "@HAVE_WCSRTOMBS@": "1",
    "@GNULIB_WCSNRTOMBS@": "0",
    "@REPLACE_WCSNRTOMBS@": "0",
    "@HAVE_WCSNRTOMBS@": "1",
    "@GNULIB_WCWIDTH@": "0",
    "@REPLACE_WCWIDTH@": "0",
    "@HAVE_DECL_WCWIDTH@": "1",
    "@GNULIB_WMEMCHR@": "0",
    "@HAVE_WMEMCHR@": "1",
    "@GNULIB_WMEMCMP@": "0",
    "@HAVE_WMEMCMP@": "1",
    "@GNULIB_WMEMCPY@": "0",
    "@HAVE_WMEMCPY@": "1",
    "@GNULIB_WMEMMOVE@": "0",
    "@HAVE_WMEMMOVE@": "1",
    "@GNULIB_WMEMSET@": "0",
    "@HAVE_WMEMSET@": "1",
    "@GNULIB_WCSLEN@": "0",
    "@HAVE_WCSLEN@": "1",
    "@GNULIB_WCSNLEN@": "0",
    "@HAVE_WCSNLEN@": "1",
    "@GNULIB_WCSCPY@": "0",
    "@HAVE_WCSCPY@": "1",
    "@GNULIB_WCPCPY@": "0",
    "@HAVE_WCPCPY@": "1",
    "@GNULIB_WCSNCPY@": "0",
    "@HAVE_WCSNCPY@": "1",
    "@GNULIB_WCPNCPY@": "0",
    "@HAVE_WCPNCPY@": "1",
    "@GNULIB_WCSCAT@": "0",
    "@HAVE_WCSCAT@": "1",
    "@GNULIB_WCSNCAT@": "0",
    "@HAVE_WCSNCAT@": "1",
    "@GNULIB_WCSCMP@": "0",
    "@HAVE_WCSCMP@": "1",
    "@GNULIB_WCSNCMP@": "0",
    "@HAVE_WCSNCMP@": "1",
    "@GNULIB_WCSCASECMP@": "0",
    "@HAVE_WCSCASECMP@": "1",
    "@GNULIB_WCSNCASECMP@": "0",
    "@HAVE_WCSNCASECMP@": "1",
    "@GNULIB_WCSCOLL@": "0",
    "@HAVE_WCSCOLL@": "1",
    "@GNULIB_WCSXFRM@": "0",
    "@HAVE_WCSXFRM@": "1",
    "@GNULIB_WCSDUP@": "0",
    "@HAVE_WCSDUP@": "1",
    "@GNULIB_WCSCHR@": "0",
    "@HAVE_WCSCHR@": "1",
    "@GNULIB_WCSRCHR@": "0",
    "@HAVE_WCSRCHR@": "1",
    "@GNULIB_WCSCSPN@": "0",
    "@HAVE_WCSCSPN@": "1",
    "@GNULIB_WCSSPN@": "0",
    "@HAVE_WCSSPN@": "1",
    "@GNULIB_WCSPBRK@": "0",
    "@HAVE_WCSPBRK@": "1",
    "@GNULIB_WCSSTR@": "0",
    "@HAVE_WCSSTR@": "1",
    "@GNULIB_WCSTOK@": "0",
    "@HAVE_WCSTOK@": "1",
    "@GNULIB_WCSWIDTH@": "0",
    "@REPLACE_WCSWIDTH@": "0",
    "@HAVE_WCSWIDTH@": "1",
    "@HAVE_CRTDEFS_H@": "1",
    "@GNULIB_WCSFTIME@": "0",

    # wctype.h
    "@NEXT_WCTYPE_H@": "<gnulib-system-libc/wctype.h>",
    "@HAVE_WCTYPE_H@": "1",
    "@HAVE_ISWCNTRL@": "1",
    "@REPLACE_ISWCNTRL@": "0",
    "@REPLACE_TOWLOWER@": "0",
    "@GNULIB_ISWBLANK@": "0",
    "@HAVE_ISWBLANK@": "1",
    "@REPLACE_ISWBLANK@": "0",
    "@HAVE_WCTYPE_T@": "1",
    "@GNULIB_WCTYPE@": "1",
    "@GNULIB_ISWCTYPE@": "0",
    "@HAVE_WCTRANS_T@": "1",
    "@GNULIB_WCTRANS@": "0",
    "@GNULIB_TOWCTRANS@": "0",
}
