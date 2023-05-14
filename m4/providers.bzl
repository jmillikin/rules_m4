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

"""Providers produced by rules_m4 rules."""

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
