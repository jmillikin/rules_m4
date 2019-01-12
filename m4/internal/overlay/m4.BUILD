# Copyright 2018 the rules_m4 authors.
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

load("@io_bazel_rules_m4//m4/internal:gnulib.bzl", "gnulib_windows_shims")

cc_library(
    name = "config_h",
    hdrs = glob(["stub-config/*.h"]) + select({
        "@bazel_tools//src/conditions:darwin": [
            "gnulib-darwin/config/config.h",
        ],
        "@bazel_tools//src/conditions:windows": [
            "gnulib-windows/config/config.h",
        ],
        "//conditions:default": [
            "gnulib-linux/config/config.h",
        ],
    }),
    includes = ["stub-config"] + select({
        "@bazel_tools//src/conditions:darwin": [
            "gnulib-darwin/config",
        ],
        "@bazel_tools//src/conditions:windows": [
            "gnulib-windows/config",
        ],
        "//conditions:default": [
            "gnulib-linux/config",
        ],
    }),
)

gnulib_windows_shims(
    name = "gnulib_windows_shims_h",
)

cc_library(
    name = "build_aux_snippets",
    srcs = glob(["build-aux/snippet/*.h"]),
    hdrs = [
        "build-aux/snippet/unused-parameter.h",
    ],
    strip_include_prefix = "build-aux/snippet",
    textual_hdrs = [
        "build-aux/snippet/arg-nonnull.h",
        "build-aux/snippet/c++defs.h",
        "build-aux/snippet/warn-on-use.h",
    ],
)

cc_library(
    name = "gnulib_windows_shims",
    hdrs = [":gnulib_windows_shims_h"],
    includes = ["gnulib-windows/shim-libc"],
    deps = [
        ":build_aux_snippets",
        ":config_h",
    ],
)

_GNULIB_HDRS = glob([
    "lib/*.h",
    "lib/glthread/*.h",
])

_GNULIB_SRCS = [
    "lib/basename-lgpl.c",
    "lib/c-stack.c",
    "lib/c-strcasecmp.c",
    "lib/clean-temp.c",
    "lib/cloexec.c",
    "lib/close-stream.c",
    "lib/closein.c",
    "lib/closeout.c",
    "lib/dup-safer.c",
    "lib/error.c",
    "lib/execute.c",
    "lib/exitfail.c",
    "lib/fatal-signal.c",
    "lib/fd-safer.c",
    "lib/filenamecat-lgpl.c",
    "lib/filenamecat.c",
    "lib/fopen-safer.c",
    "lib/fpending.c",
    "lib/freadahead.c",
    "lib/gl_avltree_oset.c",
    "lib/gl_linkedhash_list.c",
    "lib/localcharset.c",
    "lib/malloca.c",
    "lib/memchr2.c",
    "lib/mkstemp-safer.c",
    "lib/obstack.c",
    "lib/pipe-safer.c",
    "lib/printf-args.c",
    "lib/printf-parse.c",
    "lib/progname.c",
    "lib/quotearg.c",
    "lib/regex.c",
    "lib/secure_getenv.c",
    "lib/spawn-pipe.c",
    "lib/tmpdir.c",
    "lib/vasnprintf.c",
    "lib/vasprintf.c",
    "lib/verror.c",
    "lib/version-etc-fsf.c",
    "lib/version-etc.c",
    "lib/wait-process.c",
    "lib/xalloc-die.c",
    "lib/xasprintf.c",
    "lib/xmalloc.c",
    "lib/xmalloca.c",
    "lib/xprintf.c",
    "lib/xstrndup.c",
    "lib/xvasprintf.c",
]

_GNULIB_DARWIN_SRCS = []

_GNULIB_LINUX_SRCS = [
    "lib/c-ctype.c",
    "lib/getprogname.c",
    "lib/gl_list.c",
    "lib/gl_oset.c",
    "lib/gl_xlist.c",
    "lib/gl_xoset.c",
    "lib/sig-handler.c",
    "lib/xsize.c",
]

_GNULIB_WINDOWS_SRCS = [
    "lib/close.c",
    "lib/dup-safer-flag.c",
    "lib/dup2.c",
    "lib/fclose.c",
    "lib/fcntl.c",
    "lib/fd-safer-flag.c",
    "lib/fflush.c",
    "lib/fpurge.c",
    "lib/freading.c",
    "lib/fseeko.c",
    "lib/fstat.c",
    "lib/ftello.c",
    "lib/getdtablesize.c",
    "lib/getopt.c",
    "lib/getopt1.c",
    "lib/getprogname.c",
    "lib/gettimeofday.c",
    "lib/localeconv.c",
    "lib/malloc.c",
    "lib/mbrtowc.c",
    "lib/mbsinit.c",
    "lib/mkdtemp.c",
    "lib/mkstemp.c",
    "lib/msvc-inval.c",
    "lib/msvc-nothrow.c",
    "lib/nl_langinfo.c",
    "lib/pipe2-safer.c",
    "lib/pipe2.c",
    "lib/printf-frexp.c",
    "lib/printf-frexpl.c",
    "lib/raise.c",
    "lib/rename.c",
    "lib/rmdir.c",
    "lib/sigaction.c",
    "lib/sigprocmask.c",
    "lib/snprintf.c",
    "lib/stdio-write.c",
    "lib/strerror-override.c",
    "lib/strerror.c",
    "lib/strsignal.c",
    "lib/strstr.c",
    "lib/tempname.c",
    "lib/waitpid.c",
    "lib/wcrtomb.c",
]

# https://github.com/bazelbuild/bazel/issues/6337
_GNULIB_WINDOWS_SRCS.extend(_GNULIB_HDRS)

cc_library(
    name = "gnulib",
    srcs = _GNULIB_SRCS + select({
        "@bazel_tools//src/conditions:darwin": _GNULIB_DARWIN_SRCS,
        "@bazel_tools//src/conditions:windows": _GNULIB_WINDOWS_SRCS,
        "//conditions:default": _GNULIB_LINUX_SRCS,
    }),
    hdrs = _GNULIB_HDRS,
    strip_include_prefix = "lib",
    textual_hdrs = [
        "lib/regex_internal.c",
        "lib/regcomp.c",
        "lib/regexec.c",
    ],
    deps = [
        ":config_h",
        ":build_aux_snippets",
    ] + select({
        "@bazel_tools//src/conditions:windows": [":gnulib_windows_shims"],
        "//conditions:default": [],
    }),
)

cc_library(
    name = "m4_lib",
    srcs = glob([
        "src/*.c",
        "src/*.h",
    ]),
    copts = ["-UDEBUG"],
    visibility = ["//bin:__pkg__"],
    deps = [
        ":config_h",
        ":gnulib",
    ],
)
