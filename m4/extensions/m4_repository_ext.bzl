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

"""Definition of the `m4_repository_ext` module extension."""

load(
    "//m4/internal:versions.bzl",
    "DEFAULT_VERSION",
    "VERSION_URLS",
)
load(
    "//m4/rules:m4_repository.bzl",
    "m4_repository",
)
load(
    "//m4/rules:m4_toolchain_repository.bzl",
    "m4_toolchain_repository",
)

def _m4_repo_name(version, extra_copts):
    # copts_key = "{:08X}".format(hash(repr(extra_copts)))
    copts_key = "%X" % (hash(repr(extra_copts)),)
    if len(copts_key) < 8:
        copts_key = "00000000"[:8 - len(copts_key)] + copts_key
    return "m4_v{}__cfg{}".format(version, copts_key)

def _m4_repository_ext(module_ctx):
    root_direct_deps = []
    root_direct_dev_deps = []
    m4_repo_names = {}

    for module in module_ctx.modules:
        for config in module.tags.repository:
            name = config.name
            if not name:
                name = "m4_v{}".format(config.version)

            m4_repo_name = _m4_repo_name(config.version, config.extra_copts)

            m4_toolchain_repository(
                name = name,
                m4_repository = "@" + m4_repo_name,
            )

            if module.is_root:
                if module_ctx.is_dev_dependency(config):
                    root_direct_dev_deps.append(name)
                else:
                    root_direct_deps.append(name)

            if m4_repo_name not in m4_repo_names:
                m4_repo_names[m4_repo_name] = True
                m4_repository(
                    name = m4_repo_name,
                    version = config.version,
                    extra_copts = config.extra_copts,
                )

    return module_ctx.extension_metadata(
        root_module_direct_deps = root_direct_deps,
        root_module_direct_dev_deps = root_direct_dev_deps,
    )

_REPOSITORY_TAG_ATTRS = {
    "name": attr.string(
        doc = """An optional name for the repository.

The name must be unique within the set of names registered by this extension.
If unset, the repository name will default to `"m4_v{version}"`.
""",
    ),
    "version": attr.string(
        doc = "A supported version of GNU M4.",
        default = DEFAULT_VERSION,
        values = sorted(VERSION_URLS),
    ),
    "extra_copts": attr.string_list(
        doc = "Additional C compiler options to use when building GNU M4.",
    ),
}

m4_repository_ext = module_extension(
    implementation = _m4_repository_ext,
    doc = """
Module extension for declaring dependencies on GNU M4.

The resulting repository will have the following targets:
- `//bin:m4` (an alias into the underlying [`m4_repository`](#m4_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
m4 = use_extension(
    "@rules_m4//m4/extensions:m4_repository_ext.bzl",
    "m4_repository_ext",
)

m4.repository(name = "m4", version = "1.4.18")
use_repo(m4, "m4")
register_toolchains("@m4//:toolchain")
```
""",
    tag_classes = {
        "repository": tag_class(
            attrs = _REPOSITORY_TAG_ATTRS,
        ),
    },
)
