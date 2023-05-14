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

"""Shim rule for using m4 in a genrule."""

load(
    "@rules_m4//m4:toolchain_type.bzl",
    "M4_TOOLCHAIN_TYPE",
    "m4_toolchain",
)

def _template_vars(toolchain):
    return platform_common.TemplateVariableInfo({
        "M4": toolchain.m4_tool.executable.path,
    })

def _m4_toolchain_alias(ctx):
    toolchain = m4_toolchain(ctx)
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
