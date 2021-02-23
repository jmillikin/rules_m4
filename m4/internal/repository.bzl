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

load(
    "@rules_m4//m4/internal:versions.bzl",
    _VERSION_URLS = "VERSION_URLS",
    _check_version = "check_version",
)
load(
    "@rules_m4//m4/internal:gnulib/gnulib.bzl",
    _gnulib_overlay = "gnulib_overlay",
)

_M4_BUILD = """
cc_library(
    name = "m4_lib",
    srcs = glob([
        "src/*.c",
        "src/*.h",
    ], exclude = ["src/stackovf.c"]),
    copts = ["-DHAVE_CONFIG_H", "-UDEBUG"] + %s,
    visibility = ["//bin:__pkg__"],
    deps = [
        "//gnulib:config_h",
        "//gnulib",
    ],
)
"""

_M4_BIN_BUILD = """
cc_binary(
    name = "m4",
    visibility = ["//visibility:public"],
    deps = ["//:m4_lib"],
)
"""

def _m4_repository(ctx):
    version = ctx.attr.version
    _check_version(version)
    source = _VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "m4-{}".format(version),
    )

    extra_copts = ctx.attr.extra_copts
    _gnulib_overlay(ctx, m4_version = version, extra_copts = extra_copts)

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(name = repr(ctx.name)))
    ctx.file("BUILD.bazel", _M4_BUILD % str(extra_copts))
    ctx.file("bin/BUILD.bazel", _M4_BIN_BUILD)

    # Let M4 v1.4.15 build with contemporary Gnulib.
    ctx.template("src/builtin.c", "src/builtin.c", substitutions = {
        '#include "pipe.h"': '#include "spawn-pipe.h"',
        "extern FILE *popen ();": "#include <stdio.h>",
    }, executable = False)

    # Let M4 v1.4.14 build with contemporary Gnulib.
    ctx.template("src/m4.h", "src/m4.h", substitutions = {
        "\n".join([
            "#include <string.h>",
            "#include <sys/types.h>",
        ]): "\n".join([
            "#include <string.h>",
            "#include <sys/stat.h>",
            "#include <sys/types.h>",
        ]),
    }, executable = False)

    # Let M4 v1.4.13 build with contemporary Gnulib.
    ctx.template("src/output.c", "src/output.c", substitutions = {
        '#include "gl_avltree_oset.h"\n\n': "\n".join([
            '#include "gl_avltree_oset.h"',
            '#include "gl_xoset.h"',
        ]),
        "diversion_table = gl_oset_create_empty (GL_AVLTREE_OSET, cmp_diversion_CB);": "diversion_table = gl_oset_create_empty (GL_AVLTREE_OSET, cmp_diversion_CB, NULL);",
    }, executable = False)

    # Prevent LF -> CRLF conversion on Windows. This deviates from the OS
    # standard behavior to fit with the generally UNIX-ish assumptions made
    # by M4 clients (notably Bison).
    ctx.template("src/output.c", "src/output.c", substitutions = {
        "output_file = stdout;": "\n".join([
            "output_file = stdout;",
            "#ifdef SET_BINARY",
            "SET_BINARY(STDOUT_FILENO);",
            "#endif",
        ]),
    }, executable = False)

    # Older versions of M4 define a stub `mktemp` that conflicts
    # with the system version on Windows.
    ctx.template("src/m4.h", "src/m4.h", substitutions = {
        "char *mktemp ();": "",
    }, executable = False)

    # Older versions of M4 don't use the gnulib copy of <signal.h>.
    ctx.template("src/m4.c", "src/m4.c", substitutions = {
        "#include <sys/signal.h>": "#include <signal.h>",
    }, executable = False)

    # M4 assumes __STDC__ means "compiler supports ISO C", but MSVC
    # uses it to mean "does not have Microsoft extensions enabled".
    #
    # Note that gnulib treats it differently, and enabling it globally
    # will break the build.
    ctx.template("src/debug.c", "src/debug.c", substitutions = {
        "__STDC__": "__LINE__",
    }, executable = False)


m4_repository = repository_rule(
    _m4_repository,
    attrs = {
        "version": attr.string(mandatory = True),
        "extra_copts": attr.string_list(),
        "_gnulib_build": attr.label(
            default = "@rules_m4//m4/internal:gnulib/gnulib.BUILD",
            allow_single_file = True,
        ),
        "_gnulib_config_darwin_h": attr.label(
            default = "//m4/internal:gnulib/config-darwin.h",
            allow_single_file = True,
        ),
        "_gnulib_config_linux_h": attr.label(
            default = "//m4/internal:gnulib/config-linux.h",
            allow_single_file = True,
        ),
        "_gnulib_config_windows_h": attr.label(
            default = "//m4/internal:gnulib/config-windows.h",
            allow_single_file = True,
        ),
    },
)
