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

"""Bazel rules for the m4 macro expander."""

load(
    "@rules_m4//m4:providers.bzl",
    _M4ToolchainInfo = "M4ToolchainInfo",
)
load(
    "@rules_m4//m4:toolchain_type.bzl",
    _M4_TOOLCHAIN_TYPE = "M4_TOOLCHAIN_TYPE",
    _m4_toolchain = "m4_toolchain",
)
load(
    "@rules_m4//m4/internal:versions.bzl",
    "DEFAULT_VERSION",
    "check_version",
)
load(
    "@rules_m4//m4/rules:m4.bzl",
    _m4 = "m4",
)
load(
    "@rules_m4//m4/rules:m4_repository.bzl",
    _m4_repository = "m4_repository",
)
load(
    "@rules_m4//m4/rules:m4_toolchain_repository.bzl",
    _m4_toolchain_repository = "m4_toolchain_repository",
)

M4_TOOLCHAIN_TYPE = _M4_TOOLCHAIN_TYPE
m4 = _m4
m4_toolchain = _m4_toolchain
m4_repository = _m4_repository
m4_toolchain_repository = _m4_toolchain_repository
M4ToolchainInfo = _M4ToolchainInfo

# buildifier: disable=unnamed-macro
def m4_register_toolchains(version = DEFAULT_VERSION, extra_copts = []):
    """A helper function for m4 toolchains registration.

    This workspace macro will create a [`m4_repository`](#m4_repository) named
    `m4_v{version}` and register it as a Bazel toolchain.

    Args:
        version: A supported version of GNU M4.
        extra_copts: Additional C compiler options to use when building GNU M4.
    """
    check_version(version)
    repo_name = "m4_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        m4_repository(
            name = repo_name,
            version = version,
            extra_copts = extra_copts,
        )
    native.register_toolchains("@rules_m4//m4/toolchains:v{}".format(version))
