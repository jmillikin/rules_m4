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

"""Bazel toolchain for the m4 macro expander."""

M4_TOOLCHAIN_TYPE = "@rules_m4//m4:toolchain_type"

M4ToolchainInfo = provider(
    doc = "Provider for an m4 toolchain.",
    fields = {
        "all_files": """A `depset` containing all files comprising this
m4 toolchain.
""",
        "m4_tool": """A `FilesToRunProvider` for the `m4` binary.""",
        "m4_env": """
Additional environment variables to set when running `m4_tool`.
""",
    },
)

def _template_vars(toolchain):
    return platform_common.TemplateVariableInfo({
        "M4": toolchain.m4_tool.executable.path,
    })

def _m4_toolchain_info(ctx):
    m4_runfiles = ctx.attr.m4_tool[DefaultInfo].default_runfiles.files
    toolchain = M4ToolchainInfo(
        all_files = depset(
            direct = [ctx.executable.m4_tool],
            transitive = [m4_runfiles],
        ),
        m4_tool = ctx.attr.m4_tool.files_to_run,
        m4_env = ctx.attr.m4_env,
    )
    return [
        platform_common.ToolchainInfo(m4_toolchain = toolchain),
        _template_vars(toolchain),
    ]

m4_toolchain_info = rule(
    _m4_toolchain_info,
    attrs = {
        "m4_tool": attr.label(
            mandatory = True,
            executable = True,
            cfg = "host",
        ),
        "m4_env": attr.string_dict(),
    },
    provides = [
        platform_common.ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)

def _m4_toolchain_alias(ctx):
    toolchain = ctx.toolchains[M4_TOOLCHAIN_TYPE].m4_toolchain
    return [
        DefaultInfo(files = toolchain.all_files),
        _template_vars(toolchain),
    ]

m4_toolchain_alias = rule(
    _m4_toolchain_alias,
    toolchains = [M4_TOOLCHAIN_TYPE],
    provides = [
        DefaultInfo,
        platform_common.TemplateVariableInfo,
    ],
)
