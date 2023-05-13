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
    "@rules_m4//m4/internal:repository.bzl",
    _m4_repository = "m4_repository",
    _m4_toolchain_repository = "m4_toolchain_repository",
)
load(
    "@rules_m4//m4/internal:toolchain.bzl",
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

def m4_toolchain(ctx):
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
    check_version(version)
    repo_name = "m4_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        m4_repository(
            name = repo_name,
            version = version,
            extra_copts = extra_copts,
        )
    native.register_toolchains("@rules_m4//m4/toolchains:v{}".format(version))
