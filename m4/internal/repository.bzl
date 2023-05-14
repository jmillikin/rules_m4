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

"""Bazel repository rules for GNU M4."""

load("@rules_m4//m4/internal:versions.bzl", "VERSION_URLS")
load("@rules_m4//m4/internal:gnulib/gnulib.bzl", "gnulib_overlay")

_M4_BUILD = """
cc_library(
    name = "m4_lib",
    srcs = glob([
        "src/*.c",
        "src/*.h",
    ], exclude = [
        "src/stackovf.c",
        "src/ansi2knr.c",
    ]),
    copts = ["-DHAVE_CONFIG_H", "-UDEBUG"] + {EXTRA_COPTS},
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

_RULES_M4_INTERNAL_BUILD = """
load("@rules_m4//m4/internal:toolchain.bzl", "m4_toolchain_info")

m4_toolchain_info(
    name = "toolchain_info",
    m4_tool = "//bin:m4",
    visibility = ["//visibility:public"],
)
"""

def _m4_repository(ctx):
    version = ctx.attr.version
    source = VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "m4-{}".format(version),
    )

    extra_copts = ctx.attr.extra_copts
    gnulib_overlay(ctx, m4_version = version, extra_copts = extra_copts)

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", _M4_BUILD.format(EXTRA_COPTS = extra_copts))
    ctx.file("bin/BUILD.bazel", _M4_BIN_BUILD)
    ctx.file("rules_m4_internal/BUILD.bazel", _RULES_M4_INTERNAL_BUILD)

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
    implementation = _m4_repository,
    doc = """
Repository rule for GNU M4.

The resulting repository will have a `//bin:m4` executable target.

### Example

```starlark
load("@rules_m4//m4:m4.bzl", "m4_repository")

m4_repository(
    name = "m4_v1.4.18",
    version = "1.4.18",
)
```
""",
    attrs = {
        "version": attr.string(
            doc = "A supported version of GNU M4.",
            mandatory = True,
            values = sorted(VERSION_URLS),
        ),
        "extra_copts": attr.string_list(
            doc = "Additional C compiler options to use when building GNU M4.",
        ),
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
        "_gnulib_config_openbsd_h": attr.label(
            default = "//m4/internal:gnulib/config-openbsd.h",
            allow_single_file = True,
        ),
    },
)

_TOOLCHAIN_BUILD = """
load("@rules_m4//m4/internal:toolchain.bzl", "M4_TOOLCHAIN_TYPE")

toolchain(
    name = "toolchain",
    toolchain = {m4_repo} + "//rules_m4_internal:toolchain_info",
    toolchain_type = M4_TOOLCHAIN_TYPE,
    visibility = ["//visibility:public"],
)
"""

_TOOLCHAIN_BIN_BUILD = """
alias(
    name = "m4",
    actual = {m4_repo} + "//bin:m4",
    visibility = ["//visibility:public"],
)
"""

def _m4_toolchain_repository(ctx):
    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", _TOOLCHAIN_BUILD.format(
        m4_repo = repr(ctx.attr.m4_repository),
    ))
    ctx.file("bin/BUILD.bazel", _TOOLCHAIN_BIN_BUILD.format(
        m4_repo = repr(ctx.attr.m4_repository),
    ))

m4_toolchain_repository = repository_rule(
    implementation = _m4_toolchain_repository,
    doc = """
Toolchain repository rule for m4 toolchains.

Toolchain repositories add a layer of indirection so that Bazel can resolve
toolchains without downloading additional dependencies.

The resulting repository will have the following targets:
- `//bin:m4` (an alias into the underlying [`m4_repository`](#m4_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
load("@rules_m4//m4:m4.bzl", "m4_repository", "m4_toolchain_repository")

m4_repository(
    name = "m4_v1.4.18",
    version = "1.4.18",
)

m4_toolchain_repository(
    name = "m4",
    m4_repository = "@m4_v1.4.18",
)

register_toolchains("@m4//:toolchain")
```
""",
    attrs = {
        "m4_repository": attr.string(
            doc = "The name of an [`m4_repository`](#m4_repository).",
        ),
    },
)
