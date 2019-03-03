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

cc_library(
    name = "config_h",
    hdrs = select({
        "@bazel_tools//src/conditions:darwin": [
            "config-darwin/config.h",
        ],
        "@bazel_tools//src/conditions:windows": [
            "config-windows/config.h",
        ],
        "//conditions:default": [
            "config-linux/config.h",
        ],
    }),
    includes = select({
        "@bazel_tools//src/conditions:darwin": [
            "config-darwin",
        ],
        "@bazel_tools//src/conditions:windows": [
            "config-windows",
        ],
        "//conditions:default": [
            "config-linux",
        ],
    }),
    visibility = ["//:__pkg__"],
)

cc_library(
    name = "gnulib_windows_shims",
    hdrs = glob(["config-windows/shim-libc/**/*"]),
    includes = ["config-windows/shim-libc"],
    deps = [":config_h"],
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

_GNULIB_DARWIN_SRCS = [
    "lib/printf-frexp.c",
    "lib/printf-frexpl.c",
    "lib/isnanl.c",
]

_GNULIB_LINUX_SRCS = [
    "lib/binary-io.c",
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
    "lib/isnanl.c",
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
    "lib/stat-w32.c",
    "lib/stdio-write.c",
    "lib/strerror-override.c",
    "lib/strerror.c",
    "lib/strsignal.c",
    "lib/strstr.c",
    "lib/tempname.c",
    "lib/waitpid.c",
    "lib/wcrtomb.c",
]

_COPTS = select({
    "@bazel_tools//src/conditions:windows_msvc": [
        # By default, MSVC doesn't fail or even warn when an undefined function
        # is called. This check is vital when building gnulib because of how it
        # shims in its own malloc functions.
        #
        # C4013: 'function' undefined; assuming extern returning int
        "/we4013",

        # Silence this style lint because gnulib freely violates it, and chances
        # of the GNU developers ever caring about MSVC style guidelines are low.
        #
        # C4116: unnamed type definition in parentheses
        "/wd4116",
    ],
    "//conditions:default": [],
})

cc_library(
    name = "gnulib",
    # Include _GNULIB_HDRS in the sources list to work around a bug in C++
    # strict header inclusion checking when building without a sandbox.
    #
    # https://github.com/bazelbuild/bazel/issues/3828
    # https://github.com/bazelbuild/bazel/issues/6337
    srcs = _GNULIB_SRCS + _GNULIB_HDRS + select({
        "@bazel_tools//src/conditions:darwin": _GNULIB_DARWIN_SRCS,
        "@bazel_tools//src/conditions:windows": _GNULIB_WINDOWS_SRCS,
        "//conditions:default": _GNULIB_LINUX_SRCS,
    }),
    hdrs = _GNULIB_HDRS,
    copts = _COPTS + ["-DHAVE_CONFIG_H"],
    strip_include_prefix = "lib",
    textual_hdrs = [
        "lib/regex_internal.c",
        "lib/regcomp.c",
        "lib/regexec.c",
        "lib/printf-frexp.c",
        "lib/isnan.c",
    ],
    visibility = ["//:__pkg__"],
    deps = [":config_h"] + select({
        "@bazel_tools//src/conditions:windows": [":gnulib_windows_shims"],
        "//conditions:default": [],
    }),
)
