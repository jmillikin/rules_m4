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

TOOLCHAIN_TYPE = "@rules_m4//m4:toolchain_type"

ToolchainInfo = provider(fields = ["files", "vars", "m4_executable"])

def _m4_toolchain_info(ctx):
    toolchain = ToolchainInfo(
        m4_executable = ctx.executable.m4,
        files = depset(direct = [ctx.executable.m4]),
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
            mandatory = True,
            executable = True,
            cfg = "host",
        ),
    },
    provides = [
        platform_common.ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)

def _m4_toolchain_alias(ctx):
    toolchain = ctx.toolchains[TOOLCHAIN_TYPE].m4_toolchain
    return [
        DefaultInfo(files = toolchain.files),
        toolchain,
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

m4_toolchain_alias = rule(
    _m4_toolchain_alias,
    toolchains = [TOOLCHAIN_TYPE],
    provides = [
        DefaultInfo,
        ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)
