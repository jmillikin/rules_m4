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

"""Adds a default `m4_toolchain_repository` for a bzlmod-enabled workspace."""

load("//m4/internal:versions.bzl", "DEFAULT_VERSION")
load("//m4/rules:m4_repository.bzl", "m4_repository")
load(
    "//m4/rules:m4_toolchain_repository.bzl",
    "m4_toolchain_repository",
)

def _default_toolchain_ext(module_ctx):
    m4_repo_name = "m4_v{}".format(DEFAULT_VERSION)
    m4_repository(
        name = m4_repo_name,
        version = DEFAULT_VERSION,
    )
    m4_toolchain_repository(
        name = "m4",
        m4_repository = "@" + m4_repo_name,
    )
    return module_ctx.extension_metadata(
        root_module_direct_deps = ["m4"],
        root_module_direct_dev_deps = [],
    )

default_toolchain_ext = module_extension(_default_toolchain_ext)
