# Copyright 2023 the rules_m4 authors.
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

"""Adds a default m4 toolchain for a bzlmod-enabled workspace."""

_TOOLCHAIN_BUILD = """\
load("@rules_m4//m4/internal:toolchain_info.bzl", "m4_toolchain_info")
load("@rules_m4//m4:toolchain_type.bzl", "M4_TOOLCHAIN_TYPE")

m4_toolchain_info(
    name = "toolchain_info",
    m4_tool = "{m4_tool}",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "toolchain",
    toolchain = ":toolchain_info",
    toolchain_type = M4_TOOLCHAIN_TYPE,
    visibility = ["//visibility:public"],
)
"""

_BIN_BUILD = """\
alias(
    name = "m4",
    actual = "{m4_tool}",
    visibility = ["//visibility:public"],
)
"""

def _m4_bcr_toolchain_repository_impl(ctx):
    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", _TOOLCHAIN_BUILD.format(
        m4_tool = str(ctx.attr.m4_tool),
    ))
    ctx.file("bin/BUILD.bazel", _BIN_BUILD.format(
        m4_tool = str(ctx.attr.m4_tool),
    ))

_m4_bcr_toolchain_repository = repository_rule(
    implementation = _m4_bcr_toolchain_repository_impl,
    attrs = {
        "m4_tool": attr.label(
            doc = "Label of the m4 binary provided by the BCR m4 module.",
            mandatory = True,
        ),
    },
)

def _default_toolchain_ext(module_ctx):
    _m4_bcr_toolchain_repository(
        name = "m4_toolchain",
        m4_tool = "@m4//:m4",
    )
    return module_ctx.extension_metadata(
        root_module_direct_deps = ["m4_toolchain"],
        root_module_direct_dev_deps = [],
    )

default_toolchain_ext = module_extension(_default_toolchain_ext)
