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

M4_TOOLCHAIN = "@io_bazel_rules_m4//m4:toolchain_type"

def _m4_toolchain(ctx):
    (inputs, _, input_manifests) = ctx.resolve_command(
        command = "m4",
        tools = [ctx.attr.m4],
    )
    return [
        platform_common.ToolchainInfo(
            _m4_internal = struct(
                executable = ctx.executable.m4,
                inputs = depset(inputs),
                input_manifests = input_manifests,
                capture_stdout = ctx.executable._capture_stdout,
            ),
        ),
    ]

m4_toolchain = rule(
    _m4_toolchain,
    attrs = {
        "m4": attr.label(
            executable = True,
            cfg = "host",
        ),
        "_capture_stdout": attr.label(
            executable = True,
            default = "//m4/internal:capture_stdout",
            cfg = "host",
        ),
    },
)

def m4_context(ctx):
    toolchain = ctx.toolchains[M4_TOOLCHAIN]
    impl = toolchain._m4_internal
    return struct(
        toolchain = toolchain,
        executable = impl.executable,
        inputs = impl.inputs,
        input_manifests = impl.input_manifests,
        env = {
            # Prevent m4 from loading charset data from outside the sandbox.
            "CHARSETALIASDIR": "/dev/null",
        },
    )
