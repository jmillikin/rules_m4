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

"""Definition of the `m4_repository` repository rule."""

load("//m4/internal:gnulib/gnulib.bzl", "gnulib_overlay")
load(
    "//m4/internal:versions.bzl",
    "VERSION_URLS",
    "custom_version_urls",
)

_M4_BUILD = """
load("@rules_cc//cc:cc_library.bzl", "cc_library")

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

config_setting(
    name = "cc_compiler_msvc",
    flag_values = {{"@bazel_tools//tools/cpp:compiler": "msvc-cl"}},
    visibility = ["//:__subpackages__"],
)
"""

_M4_BIN_BUILD = """
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")

M4_LINKOPTS = select({{
    "//:cc_compiler_msvc": [
        # LNK4001: no object files specified; libraries used
        "/IGNORE:4001",
    ],
    "//conditions:default": [],
}})

cc_binary(
    name = "m4",
    features = ["-default_link_libs"],
    linkopts = M4_LINKOPTS + {EXTRA_LINKOPTS},
    visibility = ["//visibility:public"],
    deps = ["//:m4_lib"],
)
"""

_RULES_M4_INTERNAL_BUILD = """
load("@rules_m4//m4/rules:m4_toolchain_info.bzl", "m4_toolchain_info")

m4_toolchain_info(
    name = "toolchain_info",
    m4_tool = "//bin:m4",
    visibility = ["//visibility:public"],
)
"""

def _m4_repository(ctx):
    version = ctx.attr.version
    version_urls = VERSION_URLS
    if ctx.attr.http_mirrors or ctx.attr.extra_http_mirrors:
        version_urls = custom_version_urls(
            ctx.attr.http_mirrors,
            ctx.attr.extra_http_mirrors,
        )
    source = version_urls[version]

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
    ctx.file("bin/BUILD.bazel", _M4_BIN_BUILD.format(
        EXTRA_LINKOPTS = ctx.attr.extra_linkopts,
    ))
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
        # Include the relocated header to avoid conflicts with libc.
        # Please see //m4/internal/gnulib/gnulib.bzl#gnulib_overlay for more context.
        '#include "error.h"': '#include "gnulib-error.h"',
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
        "extra_linkopts": attr.string_list(
            doc = "Additional linker options to use when building GNU M4.",
        ),
        "extra_http_mirrors": attr.string_list(
            doc = """
Additional HTTP mirrors of the GNU M4 source archives.

These mirrors will be appended to the list of default GNU mirrors.
""",
        ),
        "http_mirrors": attr.string_list(
            doc = """
If set then this value will be used instead of the default HTTP mirror list.

The `extra_http_mirrors` attribute will be appended to this list.
""",
        ),
        "_gnulib_build": attr.label(
            default = Label("//m4/internal:gnulib/gnulib.BUILD"),
            allow_single_file = True,
        ),
        "_gnulib_config_darwin_h": attr.label(
            default = Label("//m4/internal:gnulib/config-darwin.h"),
            allow_single_file = True,
        ),
        "_gnulib_config_linux_h": attr.label(
            default = Label("//m4/internal:gnulib/config-linux.h"),
            allow_single_file = True,
        ),
        "_gnulib_config_windows_h": attr.label(
            default = Label("//m4/internal:gnulib/config-windows.h"),
            allow_single_file = True,
        ),
        "_gnulib_config_openbsd_h": attr.label(
            default = Label("//m4/internal:gnulib/config-openbsd.h"),
            allow_single_file = True,
        ),
        "_gnulib_config_freebsd_h": attr.label(
            default = Label("//m4/internal:gnulib/config-freebsd.h"),
            allow_single_file = True,
        ),
    },
)
