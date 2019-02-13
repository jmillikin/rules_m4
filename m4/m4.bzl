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
    "@rules_m4//m4/internal:toolchain.bzl",
    _TOOLCHAIN_TYPE = "TOOLCHAIN_TYPE",
    _ToolchainInfo = "M4ToolchainInfo",
)

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

def m4_register_toolchains(version = _LATEST):
    _check_version(version)
    repo_name = "m4_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        m4_repository(
            name = repo_name,
            version = version,
        )
    native.register_toolchains("@rules_m4//m4/toolchains:v{}".format(version))

m4_common = struct(
    VERSIONS = list(_VERSION_URLS),
    ToolchainInfo = _ToolchainInfo,
    TOOLCHAIN_TYPE = _TOOLCHAIN_TYPE,
)

# region Build Rules {{{

def _m4(ctx):
    m4_toolchain = ctx.attr._m4_toolchain[m4_common.ToolchainInfo]

    stdout = ctx.outputs.output
    if stdout == None:
        stdout = ctx.actions.declare_file(ctx.attr.name)

    inputs = list(ctx.files.srcs)
    outputs = [stdout]

    args = ctx.actions.args()
    args.add_all([
        stdout.path,
        m4_toolchain.m4_executable.path,
    ])

    if ctx.outputs.freeze_state:
        freeze_state = ctx.outputs.freeze_state
        if freeze_state.extension != "m4f":
            fail("output file {} is misplaced here (expected .m4f)".format(ctx.attr.freeze_state), "freeze_state")
        outputs.append(freeze_state)
        args.add_all([
            "--freeze-state",
            freeze_state.path,
        ])

    if ctx.attr.reload_state:
        inputs.append(ctx.file.reload_state)
        args.add_all([
            "--reload-state",
            ctx.file.reload_state.path,
        ])

    args.add_all(ctx.attr.m4_options)
    args.add_all(ctx.files.srcs)

    tools = [ctx.executable._capture_stdout]
    env = {}
    if "m4_syscmd" not in ctx.attr.features:
        tools.append(ctx.executable._deny_shell)
        env["M4_SYSCMD_SHELL"] = ctx.executable._deny_shell.path

    ctx.actions.run(
        executable = ctx.executable._capture_stdout,
        arguments = [args],
        inputs = depset(
            direct = inputs,
            transitive = [m4_toolchain.files],
        ),
        outputs = outputs,
        tools = tools,
        env = env,
        mnemonic = "M4",
        progress_message = "Expanding {}".format(ctx.label),
    )

    return DefaultInfo(
        files = depset(direct = outputs),
    )

m4 = rule(
    _m4,
    attrs = {
        "srcs": attr.label_list(
            allow_empty = False,
            mandatory = True,
            allow_files = True,
        ),
        "output": attr.output(),
        "freeze_state": attr.output(
            # Valid file extensions: [".m4f"]
            #
            # https://github.com/bazelbuild/bazel/issues/7409
        ),
        "reload_state": attr.label(
            allow_single_file = [".m4f"],
        ),
        "m4_options": attr.string_list(),
        "_m4_toolchain": attr.label(
            default = "@rules_m4//m4:toolchain",
        ),
        "_capture_stdout": attr.label(
            executable = True,
            default = "@rules_m4//m4/internal:capture_stdout",
            cfg = "host",
        ),
        "_deny_shell": attr.label(
            executable = True,
            default = "@rules_m4//m4/internal:deny_shell",
            cfg = "host",
        ),
    },
)

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
            allow_single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "//m4/internal:overlay/m4_bin.BUILD",
            allow_single_file = True,
        ),
        "_m4_syscmd_shell_h": attr.label(
            default = "//m4/internal:overlay/m4_syscmd_shell.h",
            allow_single_file = True,
        ),
        "_common_config_h": attr.label(
            default = "//m4/internal:overlay/gnulib_common_config.h",
            allow_single_file = True,
        ),
        "_darwin_config_h": attr.label(
            default = "//m4/internal:overlay/gnulib-darwin/config.h",
            allow_single_file = True,
        ),
        "_linux_config_h": attr.label(
            default = "//m4/internal:overlay/gnulib-linux/config.h",
            allow_single_file = True,
        ),
        "_windows_config_h": attr.label(
            default = "//m4/internal:overlay/gnulib-windows/config.h",
            allow_single_file = True,
        ),
        "_vasnprintf_c": attr.label(
            default = "//m4/internal:overlay/gnulib/vasnprintf.c",
            allow_single_file = True,
        ),
        "_xalloc_oversized_h": attr.label(
            default = "//m4/internal:overlay/gnulib/xalloc-oversized.h",
            allow_single_file = True,
        ),
    },
)

# endregion }}}
