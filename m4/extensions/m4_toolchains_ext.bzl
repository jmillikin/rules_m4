# Copyright 2026 the rules_m4 authors.
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

"""Definition of the `m4_toolchains_ext` module extension."""

_BUILD = """
load("@rules_m4//m4:toolchain_type.bzl", "M4_TOOLCHAIN_TYPE")
load("@rules_m4//m4/rules:m4_toolchain_info.bzl", "m4_toolchain_info")

m4_toolchain_info(
    name = "toolchain_info",
    m4_tool = {m4_tool},
    m4_env = {m4_env},
)

toolchain(
    name = "toolchain",
    toolchain = ":toolchain_info",
    toolchain_type = M4_TOOLCHAIN_TYPE,
    visibility = ["//visibility:public"],
)
"""

def _m4_toolchains_repo_impl(ctx):
    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", "")
    for (toolchain_name, m4_tool) in ctx.m4_tools.items():
        m4_env_json = ctx.attr.m4_envs.get(toolchain_name, "{}")
        ctx.file(toolchain_name + "/BUILD.bazel", _BUILD.format(
            m4_tool = repr(str(m4_tool)),
            m4_env = json.decode(m4_env_json),
        ))

_m4_toolchains_repo = repository_rule(
    implementation = _m4_toolchains_repo_impl,
    attrs = {
        "m4_tools": attr.string_keyed_label_dict(),
        "m4_envs": attr.string_dict(),
    },
)

def _m4_toolchains_ext(module_ctx):
    root_direct_dep = False
    root_direct_dev_dep = False

    m4_tools = {}
    m4_envs = {}
    for module in module_ctx.modules:
        for config in module.tags.toolchain:
            m4_tools[config.name] = config.m4_tool
            if config.m4_env:
                m4_envs[config.name] = json.encode(config.m4_env)
            if module.is_root:
                if module_ctx.is_dev_dependency(config):
                    root_direct_dev_dep = True
                else:
                    root_direct_dep = True

    _m4_toolchains_repo(
        name = "m4_toolchains",
        m4_tools = m4_tools,
        m4_envs = m4_envs,
    )

    root_direct_deps = []
    if root_direct_dep:
        root_direct_deps.append("m4_toolchains")
    root_direct_dev_deps = []
    if root_direct_dev_dep:
        root_direct_dev_deps.append("m4_toolchains")

    return module_ctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = root_direct_deps,
        root_module_direct_dev_deps = root_direct_dev_deps,
    )

_TOOLCHAIN_TAG_ATTRS = {
    "name": attr.string(
        doc = "The name of the toolchain repository to create.",
        mandatory = True,
    ),
    "m4_tool": attr.label(
        doc = "The label of an `m4` executable target.",
        mandatory = True,
    ),
    "m4_env": attr.string_dict(
        doc = "Additional environment variables to set when running `m4_tool`.",
    ),
}

m4_toolchains_ext = module_extension(
    implementation = _m4_toolchains_ext,
    doc = """
Module extension for declaring M4 toolchains with custom target binaries.

The resulting repository will have one subdirectory per named module tag, which
contains a `:toolchain` target that can be registered with Bazel.

### Example

```starlark
m4_toolchains = use_extension(
    "@rules_m4//m4/extensions:m4_toolchains_ext.bzl",
    "m4_toolchain_ext",
)

m4_toolchains.toolchain(name = "custom", m4_tool = "//custom_m4:m4")
use_repo(m4_toolchains, "m4_toolchains")
register_toolchains("@m4_toolchains//custom:toolchain")
```
""",
    tag_classes = {
        "toolchain": tag_class(
            attrs = _TOOLCHAIN_TAG_ATTRS,
        ),
    },
)
