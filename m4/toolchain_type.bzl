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

"""Helpers for depending on m4 as a toolchain."""

M4_TOOLCHAIN_TYPE = "@rules_m4//m4:toolchain_type"

def m4_toolchain(ctx):
    """Returns the current [`M4ToolchainInfo`](#M4ToolchainInfo).

    Args:
        ctx: A rule context, where the rule has a toolchain dependency
          on [`M4_TOOLCHAIN_TYPE`](#M4_TOOLCHAIN_TYPE).

    Returns:
        An [`M4ToolchainInfo`](#M4ToolchainInfo).
    """
    return ctx.toolchains[M4_TOOLCHAIN_TYPE].m4_toolchain
