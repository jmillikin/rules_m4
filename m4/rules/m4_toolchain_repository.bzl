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

"""Definition of the `m4_toolchain_repository` repository rule."""

_TOOLCHAIN_BUILD = """
load("@rules_m4//m4:toolchain_type.bzl", "M4_TOOLCHAIN_TYPE")

toolchain(
    name = "toolchain",
    toolchain = {m4_repo} + "//rules_m4_internal:toolchain_info",
    toolchain_type = M4_TOOLCHAIN_TYPE,
    visibility = ["//visibility:public"],
)
"""

_TOOLCHAIN_BIN_BUILD = """
alias(
    name = "m4",
    actual = {m4_repo} + "//bin:m4",
    visibility = ["//visibility:public"],
)
"""

def _m4_toolchain_repository(ctx):
    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", _TOOLCHAIN_BUILD.format(
        m4_repo = repr(ctx.attr.m4_repository),
    ))
    ctx.file("bin/BUILD.bazel", _TOOLCHAIN_BIN_BUILD.format(
        m4_repo = repr(ctx.attr.m4_repository),
    ))

m4_toolchain_repository = repository_rule(
    implementation = _m4_toolchain_repository,
    doc = """
Toolchain repository rule for m4 toolchains.

Toolchain repositories add a layer of indirection so that Bazel can resolve
toolchains without downloading additional dependencies.

The resulting repository will have the following targets:
- `//bin:m4` (an alias into the underlying [`m4_repository`](#m4_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
load("@rules_m4//m4:m4.bzl", "m4_repository", "m4_toolchain_repository")

m4_repository(
    name = "m4_v1.4.18",
    version = "1.4.18",
)

m4_toolchain_repository(
    name = "m4",
    m4_repository = "@m4_v1.4.18",
)

register_toolchains("@m4//:toolchain")
```
""",
    attrs = {
        "m4_repository": attr.string(
            doc = "The name of an [`m4_repository`](#m4_repository).",
        ),
    },
)
