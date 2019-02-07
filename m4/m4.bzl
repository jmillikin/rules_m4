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

"""Bazel build rules for GNU M4.

```python
load("@io_bazel_rules_m4//m4:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()
```
"""

# region Versions {{{

_LATEST = "1.4.18"

_MIRRORS = [
    "https://mirror.bazel.build/ftp.gnu.org/gnu/m4/",
    "https://mirrors.kernel.org/gnu/m4/",
    "https://ftp.gnu.org/gnu/m4/",
]

def _urls(filename):
    return [m + filename for m in _MIRRORS]

_VERSION_URLS = {
    "1.4.18": {
        "urls": _urls("m4-1.4.18.tar.xz"),
        "sha256": "f2c1e86ca0a404ff281631bdc8377638992744b175afb806e25871a24a934e07",
        "overwrite": ["vasnprintf.c", "xalloc-oversized.h"],
    },
}

def _check_version(version):
    if version not in _VERSION_URLS:
        fail("GNU M4 version {} not supported by rules_m4.".format(repr(version)))

# endregion }}}

# region Toolchain {{{

_TOOLCHAIN_TYPE = "@io_bazel_rules_m4//m4:toolchain_type"

_ToolchainInfo = provider(fields = ["files", "vars", "m4_executable"])

_Internal = provider()

def _m4_toolchain_info(ctx):
    toolchain = _ToolchainInfo(
        m4_executable = ctx.executable.m4,
        files = depset([ctx.executable.m4]),
        vars = {"M4": ctx.executable.m4.path},
    )
    return [
        platform_common.ToolchainInfo(m4_toolchain = toolchain),
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

m4_toolchain_info = rule(
    _m4_toolchain_info,
    attrs = {
        "m4": attr.label(
            executable = True,
            cfg = "host",
        ),
    },
)

def _m4_toolchain_alias(ctx):
    toolchain = ctx.toolchains[_TOOLCHAIN_TYPE].m4_toolchain
    return [
        DefaultInfo(files = toolchain.files),
        toolchain,
        platform_common.TemplateVariableInfo(toolchain.vars),
        _Internal(
            capture_stdout = ctx.executable._capture_stdout,
            deny_shell = ctx.executable._deny_shell,
        ),
    ]

m4_toolchain_alias = rule(
    _m4_toolchain_alias,
    toolchains = [_TOOLCHAIN_TYPE],
    attrs = {
        "_capture_stdout": attr.label(
            executable = True,
            default = "//m4/internal:capture_stdout",
            cfg = "host",
        ),
        "_deny_shell": attr.label(
            executable = True,
            default = "//m4/internal:deny_shell",
            cfg = "host",
        ),
    },
)

def m4_register_toolchains(version = _LATEST):
    _check_version(version)
    repo_name = "m4_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        m4_repository(
            name = repo_name,
            version = version,
        )
    native.register_toolchains("@io_bazel_rules_m4//m4/toolchains:v{}".format(version))

# endregion }}}

m4_common = struct(
    VERSIONS = list(_VERSION_URLS),
    ToolchainInfo = _ToolchainInfo,
    TOOLCHAIN_TYPE = _TOOLCHAIN_TYPE,
)

# region Build Rules {{{

def _m4_env(internal):
    return {
        "M4_SYSCMD_SHELL": internal.deny_shell.path,
    }

# region rule(m4) {{{

def _m4(ctx):
    toolchain = ctx.attr._m4_toolchain[m4_common.ToolchainInfo]
    internal = ctx.attr._m4_toolchain[_Internal]
    out = ctx.outputs.out
    if out == None:
        out = ctx.actions.declare_file(ctx.attr.name)

    args = ctx.actions.args()
    args.add_all([out, toolchain.m4_executable.path])
    inputs = toolchain.files + ctx.files.srcs + depset([
        internal.capture_stdout,
        internal.deny_shell,
    ])
    if ctx.attr.reload_state:
        args.add("--reload-state", ctx.file.reload_state.path)
        inputs += depset([ctx.file.reload_state])
    args.add_all(ctx.attr.opts)
    args.add_all(ctx.files.srcs)
    ctx.actions.run(
        executable = internal.capture_stdout,
        arguments = [args],
        inputs = inputs,
        outputs = [out],
        env = _m4_env(internal),
        mnemonic = "M4",
        progress_message = "Expanding {}".format(ctx.label),
    )
    return DefaultInfo(
        files = depset([out]),
    )

m4 = rule(
    _m4,
    attrs = {
        "srcs": attr.label_list(
            allow_empty = False,
            mandatory = True,
            allow_files = True,
        ),
        "reload_state": attr.label(
            mandatory = False,
            allow_single_file = [".m4f"],
        ),
        "opts": attr.string_list(
            allow_empty = True,
        ),
        "out": attr.output(),
        "_m4_toolchain": attr.label(
            default = "//m4:toolchain",
        ),
    },
)
"""Expand a set of M4 sources.

```python
load("@io_bazel_rules_m4//m4:m4.bzl", "m4")
m4(
    name = "hello.txt",
    srcs = ["hello.in.txt"],
)
```
"""

# endregion }}}

# region rule(m4_frozen_state) {{{

def _m4_frozen_state(ctx):
    m4_toolchain = ctx.attr._m4_toolchain[m4_common.ToolchainInfo]
    internal = ctx.attr._m4_toolchain[_Internal]

    out = ctx.actions.declare_file(ctx.attr.name + ".m4f")

    args = ctx.actions.args()
    args.add_all(["m4-stdout", m4_toolchain.m4_executable.path])

    args.add("--freeze-state", out.path)
    inputs = m4_toolchain.files + ctx.files.srcs + depset([
        internal.capture_stdout,
        internal.deny_shell,
    ])
    if ctx.attr.reload_state:
        args.add("--reload-state", ctx.file.reload_state.path)
        inputs += depset([ctx.file.reload_state])
    args.add_all(ctx.attr.opts)
    args.add_all(ctx.files.srcs)
    ctx.actions.run(
        executable = internal.capture_stdout,
        arguments = [args],
        inputs = inputs,
        outputs = [out],
        env = _m4_env(internal),
        mnemonic = "M4",
        progress_message = "Freezing {}".format(ctx.label),
    )
    return DefaultInfo(files = depset([out]))

m4_frozen_state = rule(
    _m4_frozen_state,
    attrs = {
        "srcs": attr.label_list(
            allow_empty = False,
            mandatory = True,
            allow_files = [".m4"],
        ),
        "reload_state": attr.label(
            mandatory = False,
            allow_single_file = [".m4f"],
        ),
        "opts": attr.string_list(
            allow_empty = True,
        ),
        "_m4_toolchain": attr.label(
            default = "//m4:toolchain",
        ),
    },
)
"""Compile a set of M4 sources into a shared template.

```python
load("@io_bazel_rules_m4//m4:m4.bzl", "m4", "m4_frozen_state")
m4_frozen_state(
    name = "tmpl",
    srcs = ["tmpl.m4"],
)
m4(
    name = "hello.txt",
    srcs = ["hello.in.txt"],
    reload_state = ":tmpl",
)
```
"""

# endregion }}}

# endregion }}}

# region Repository Rules {{{

def _m4_repository(ctx):
    version = ctx.attr.version
    _check_version(version)
    source = _VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "m4-{}".format(version),
    )

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(name = repr(ctx.name)))
    ctx.symlink(ctx.attr._overlay_BUILD, "BUILD.bazel")
    ctx.symlink(ctx.attr._overlay_bin_BUILD, "bin/BUILD.bazel")
    ctx.file("stub-config/configmake.h", "")
    ctx.symlink(ctx.attr._m4_syscmd_shell_h, "stub-config/m4_syscmd_shell.h")
    ctx.template("stub-config/gnulib_common_config.h", ctx.attr._common_config_h, {
        "{VERSION}": version,
    })

    ctx.symlink(ctx.attr._darwin_config_h, "gnulib-darwin/config/config.h")
    ctx.symlink(ctx.attr._linux_config_h, "gnulib-linux/config/config.h")
    ctx.symlink(ctx.attr._windows_config_h, "gnulib-windows/config/config.h")

    # Overwrite m4's vasnprintf.c to pick up two important bug fixes.
    #
    # * Fix heap overflow in float formatting
    #
    #   http://git.savannah.gnu.org/cgit/gnulib.git/commit/lib/vasnprintf.c?id=278b4175c9d7dd47c1a3071554aac02add3b3c35
    #
    # * Fix crash on macOS 10.13 due to '%n' in a writable format string
    #   passed to `sprintf()`.
    #
    #   http://git.savannah.gnu.org/cgit/gnulib.git/commit/lib/vasnprintf.c?id=c41f233c4c38e84023a16339782ee306f03e7f59
    #
    # Current vendor copy is @ e6633650a245a4e5bfe2e3de92be93a623eef7a9 (2018-12-31)
    if "vasnprintf.c" in source["overwrite"]:
        ctx.template("lib/vasnprintf.c", ctx.attr._vasnprintf_c)

    # Overwrite m4's xalloc-oversized.h to pick up a bug fix for Clang on Linux.
    #
    # Context:
    # * https://llvm.org/bugs/show_bug.cgi?id=16404
    # * https://github.com/jmillikin/rules_m4/issues/4
    #
    # Current vendor copy is @ e6633650a245a4e5bfe2e3de92be93a623eef7a9 (2018-12-31)
    if "xalloc-oversized.h" in source["overwrite"]:
        ctx.template("lib/xalloc-oversized.h", ctx.attr._xalloc_oversized_h)

    # gnulib inspects inner details of FILE* based on hard-coded structs defined
    # for a handful of target platforms. Disable the whole mess so M4 can be
    # built with musl libc.
    #
    # Context:
    # * https://wiki.musl-libc.org/faq.html#Q:-I'm-getting-a-gnulib-error
    # * https://github.com/jmillikin/rules_m4/issues/4
    ctx.file("lib/fpending.c", "#include <stdio.h>\nsize_t __fpending(FILE *fp) { return 1; }")
    ctx.file("lib/freadahead.c", "#include <stdio.h>\nsize_t freadahead(FILE *fp) { return 1; }")

    # error.c depends on the gnulib libc shims to inject gnulib macros. Fix this
    # by injecting explicit include directives.
    ctx.template("lib/error.c", "lib/error.c", substitutions = {
        '#include "error.h"\n': "\n".join([
            '#include "error.h"',
            '#include "build-aux/snippet/arg-nonnull.h"',
        ]),
    }, executable = False)

    # Stub out the sandbox-escaping charset alias loader.
    ctx.template("lib/localcharset.c", "lib/localcharset.c", substitutions = {
        "get_charset_aliases (void)": '''
get_charset_aliases (void) { return ""; }
#define LIBDIR ""
static const char * _replaced_get_charset_aliases (void) _GL_UNUSED;
static const char * _replaced_get_charset_aliases (void)
''',
    }, executable = False)

    # Fix a mismatch between _Noreturn and __attribute_noreturn__ when
    # building with a C11-aware GCC.
    ctx.template("lib/obstack.c", "lib/obstack.c", substitutions = {
        "static _Noreturn void": "static _Noreturn __attribute_noreturn__ void",
    })

    # Prevent LF -> CRLF conversion on Windows. This deviates from the OS
    # standard behavior to fit with the generally UNIX-ish assumptions made
    # by M4 clients (notably Bison).
    ctx.template("src/output.c", "src/output.c", substitutions = {
        "output_file = stdout;": """
output_file = stdout;
SET_BINARY(STDOUT_FILENO);
""",
    })

m4_repository = repository_rule(
    _m4_repository,
    attrs = {
        "version": attr.string(mandatory = True),
        "_overlay_BUILD": attr.label(
            default = "//m4/internal:overlay/m4.BUILD",
            single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "//m4/internal:overlay/m4_bin.BUILD",
            single_file = True,
        ),
        "_m4_syscmd_shell_h": attr.label(
            default = "//m4/internal:overlay/m4_syscmd_shell.h",
            single_file = True,
        ),
        "_common_config_h": attr.label(
            default = "//m4/internal:overlay/gnulib_common_config.h",
            single_file = True,
        ),
        "_darwin_config_h": attr.label(
            default = "//m4/internal:overlay/gnulib-darwin/config.h",
            single_file = True,
        ),
        "_linux_config_h": attr.label(
            default = "//m4/internal:overlay/gnulib-linux/config.h",
            single_file = True,
        ),
        "_windows_config_h": attr.label(
            default = "//m4/internal:overlay/gnulib-windows/config.h",
            single_file = True,
        ),
        "_vasnprintf_c": attr.label(
            default = "//m4/internal:overlay/gnulib/vasnprintf.c",
            single_file = True,
        ),
        "_xalloc_oversized_h": attr.label(
            default = "//m4/internal:overlay/gnulib/xalloc-oversized.h",
            single_file = True,
        ),
    },
)

# endregion }}}
