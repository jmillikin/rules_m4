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

"""Bazel build rules for GNU M4.

```python
load("@io_bazel_rules_m4//:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()
```
"""

_LATEST = "1.4.18"

_VERSION_URLS = {
    "1.4.18": {
        "urls": ["https://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.xz"],
        "sha256": "f2c1e86ca0a404ff281631bdc8377638992744b175afb806e25871a24a934e07",
    },
}

M4_TOOLCHAIN = "@io_bazel_rules_m4//m4:toolchain_type"

M4_VERSIONS = list(_VERSION_URLS)

_TemplateInfo = provider(fields = ["state_file"])

def _m4_expansion(ctx):
    toolchain = ctx.toolchains[M4_TOOLCHAIN]
    m4 = toolchain.m4
    wrapper = toolchain._internal.capture_stdout
    out = ctx.actions.declare_file(ctx.attr.name)
    opts = []
    inputs = m4.inputs + ctx.files.srcs
    if ctx.attr.template:
        tmpl = ctx.attr.template[_TemplateInfo].state_file
        opts.append("--reload-state=" + tmpl.path)
        inputs.append(tmpl)
    ctx.actions.run(
        executable = wrapper,
        arguments = [out.path, m4.executable.path] + opts + [f.path for f in ctx.files.srcs],
        inputs = inputs,
        input_manifests = m4.input_manifests,
        outputs = [out],
        env = m4.env(ctx),
        mnemonic = "ExpandTemplate",
        progress_message = "Expanding M4 template {} ({} files)".format(ctx.label, len(ctx.files.srcs)),
    )
    return DefaultInfo(
        files = depset([out]),
    )

m4_expansion = rule(
    _m4_expansion,
    attrs = {
        "srcs": attr.label_list(
            allow_empty = False,
            mandatory = True,
            allow_files = True,
        ),
        "template": attr.label(
            mandatory = False,
            single_file = True,
            providers = [_TemplateInfo],
        ),
    },
    toolchains = [M4_TOOLCHAIN],
)
"""Expand a set of M4 sources.

```python
load("@io_bazel_rules_m4//:m4.bzl", "m4_expansion")
m4_expansion(
    name = "hello.txt",
    srcs = ["hello.in.txt"],
)
```
"""

def _m4_template(ctx):
    m4 = ctx.toolchains[M4_TOOLCHAIN].m4
    out = ctx.actions.declare_file(ctx.attr.name + ".m4f")
    opts = ["--freeze-state=" + out.path]
    inputs = m4.inputs + ctx.files.srcs
    if ctx.attr.base:
        base = ctx.attr.base[_TemplateInfo].state_file
        opts.append("--reload-state=" + base.path)
        inputs.append(base)
    ctx.actions.run(
        executable = m4.executable,
        arguments = opts + [f.path for f in ctx.files.srcs],
        inputs = inputs,
        input_manifests = m4.input_manifests,
        outputs = [out],
        env = m4.env(ctx),
        mnemonic = "ParseTemplate",
        progress_message = "Parsing M4 template {} ({} files)".format(ctx.label, len(ctx.files.srcs)),
    )
    return [
        DefaultInfo(files = depset([out])),
        _TemplateInfo(state_file = out),
    ]

m4_template = rule(
    _m4_template,
    attrs = {
        "srcs": attr.label_list(
            allow_empty = False,
            mandatory = True,
            allow_files = [".m4"],
        ),
        "base": attr.label(
            mandatory = False,
            single_file = True,
            providers = [_TemplateInfo],
        ),
    },
    toolchains = [M4_TOOLCHAIN],
)
"""Compile a set of M4 sources into a shared template.

```python
load("@io_bazel_rules_m4//:m4.bzl", "m4_expansion", "m4_template")
m4_template(
    name = "tmpl",
    srcs = ["tmpl.m4"],
)
m4_expansion(
    name = "hello.txt",
    srcs = ["hello.in.txt"],
    template = ":tmpl",
)
```
"""

def _m4_env(ctx):
    return {
        # Prevent m4 from loading charset data from outside the sandbox.
        "CHARSETALIASDIR": "/dev/null",
    }

def _m4_toolchain(ctx):
    (inputs, _, input_manifests) = ctx.resolve_command(
        command = "m4",
        tools = [ctx.attr.m4],
    )
    return [
        platform_common.ToolchainInfo(
            m4 = struct(
                executable = ctx.executable.m4,
                inputs = inputs,
                input_manifests = input_manifests,
                env = _m4_env,
            ),
            _internal = struct(
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
            default = "//internal:capture_stdout",
            cfg = "host",
        ),
    },
)

def _check_version(version):
    if version not in _VERSION_URLS:
        fail("GNU M4 version {} not supported by rules_m4.".format(repr(version)))

def _m4_download(ctx):
    version = ctx.attr.version
    _check_version(version)
    source = _VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "m4-{}".format(version),
    )

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(name = repr(ctx.name)))
    ctx.symlink(ctx.attr._overlay_BUILD, "BUILD.bazel")
    ctx.symlink(ctx.attr._overlay_bin_BUILD, "bin/BUILD.bazel")
    ctx.symlink(ctx.attr._overlay_configmake_h, "stub-config/configmake.h")
    ctx.template("stub-config/config.h", ctx.attr._overlay_config_h, {
        "version": version,
    })

m4_download = repository_rule(
    _m4_download,
    attrs = {
        "version": attr.string(mandatory = True),
        "_overlay_BUILD": attr.label(
            default = "@io_bazel_rules_m4//internal:overlay/m4_BUILD",
            single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "@io_bazel_rules_m4//internal:overlay/m4_bin_BUILD",
            single_file = True,
        ),
        "_overlay_config_h": attr.label(
            default = "@io_bazel_rules_m4//internal:overlay/config.h",
            single_file = True,
        ),
        "_overlay_configmake_h": attr.label(
            default = "@io_bazel_rules_m4//internal:overlay/configmake.h",
            single_file = True,
        ),
    },
)

def m4_register_toolchains(version = _LATEST):
    _check_version(version)
    repo_name = "m4_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        m4_download(
            name = repo_name,
            version = version,
        )
    native.register_toolchains("@io_bazel_rules_m4//toolchains:v{}_toolchain".format(version))
