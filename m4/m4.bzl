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

"""Bazel build rules for the m4 macro expander."""

load(
    "@rules_m4//m4/internal:repository.bzl",
    _m4_repository = "m4_repository",
    _m4_toolchain_repository = "m4_toolchain_repository",
)
load(
    "@rules_m4//m4/internal:toolchain.bzl",
    _M4ToolchainInfo = "M4ToolchainInfo",
    _M4_TOOLCHAIN_TYPE = "M4_TOOLCHAIN_TYPE",
)
load(
    "@rules_m4//m4/internal:versions.bzl",
    "DEFAULT_VERSION",
    "check_version",
)

M4_TOOLCHAIN_TYPE = _M4_TOOLCHAIN_TYPE
m4_repository = _m4_repository
m4_toolchain_repository = _m4_toolchain_repository
M4ToolchainInfo = _M4ToolchainInfo

def m4_toolchain(ctx):
    """Returns the current [`M4ToolchainInfo`](#M4ToolchainInfo).

    Args:
        ctx: A rule context, where the rule has a toolchain dependency
          on [`M4_TOOLCHAIN_TYPE`](#M4_TOOLCHAIN_TYPE).

    Returns:
        An [`M4ToolchainInfo`](#M4ToolchainInfo).
    """
    return ctx.toolchains[M4_TOOLCHAIN_TYPE].m4_toolchain

def _m4(ctx):
    m4 = m4_toolchain(ctx)

    stdout = ctx.outputs.output
    if stdout == None:
        stdout = ctx.actions.declare_file(ctx.attr.name)

    inputs = list(ctx.files.srcs)
    outputs = [stdout]

    args = ctx.actions.args()
    args.add_all([
        stdout.path,
        m4.m4_tool.executable.path,
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

    tools = [m4.m4_tool]
    env = dict(m4.m4_env)
    if "m4_syscmd" not in ctx.attr.features:
        tools.append(ctx.executable._deny_shell)
        env["M4_SYSCMD_SHELL"] = ctx.executable._deny_shell.path

    ctx.actions.run(
        executable = ctx.executable._capture_stdout,
        arguments = [args],
        inputs = depset(direct = inputs),
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
    implementation = _m4,
    doc = """Perform macro expansion to produce an output file.

This rule blocks the of execution shell commands (such as `syscmd`) by default.
To enable expansion of a file containing shell commands, set the `m4_syscmd`
target feature.

### Example

```starlark
load("@rules_m4//m4:m4.bzl", "m4")

m4(
    name = "m4_example.txt",
    srcs = ["m4_example.in.txt"],
)
```
""",
    attrs = {
        "srcs": attr.label_list(
            doc = "List of source files to macro-expand.",
            allow_empty = False,
            mandatory = True,
            allow_files = True,
        ),
        "output": attr.output(
            doc = """File to write output to. If unset, defaults to the rule
name.
""",
        ),
        "freeze_state": attr.output(
            doc = """Optional output file for GNU M4 frozen state. Must have
extension `.m4f`.
""",
            # Valid file extensions: [".m4f"]
            #
            # https://github.com/bazelbuild/bazel/issues/7409
        ),
        "reload_state": attr.label(
            doc = """Optional input file for GNU M4 frozen state. Must have
extension `.m4f`.
""",
            allow_single_file = [".m4f"],
        ),
        "m4_options": attr.string_list(
            doc = """
Additional options to pass to the `m4` command.

These will be added to the command args immediately before the source files.
""",
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
    toolchains = [M4_TOOLCHAIN_TYPE],
)

# buildifier: disable=unnamed-macro
def m4_register_toolchains(version = DEFAULT_VERSION, extra_copts = []):
    """A helper function for m4 toolchains registration.

    This workspace macro will create a [`m4_repository`](#m4_repository) named
    `m4_v{version}` and register it as a Bazel toolchain.

    Args:
        version: A supported version of GNU M4.
        extra_copts: Additional C compiler options to use when building GNU M4.
    """
    check_version(version)
    repo_name = "m4_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        m4_repository(
            name = repo_name,
            version = version,
            extra_copts = extra_copts,
        )
    native.register_toolchains("@rules_m4//m4/toolchains:v{}".format(version))
