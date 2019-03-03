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

_MIRRORS = [
    "https://mirror.bazel.build/ftp.gnu.org/gnu/m4/",
    "https://mirrors.kernel.org/gnu/m4/",
    "https://ftp.gnu.org/gnu/m4/",
]

def _urls(filename):
    return [m + filename for m in _MIRRORS]

DEFAULT_VERSION = "1.4.18"

VERSION_URLS = {
    "1.4.18": {
        "urls": _urls("m4-1.4.18.tar.xz"),
        "sha256": "f2c1e86ca0a404ff281631bdc8377638992744b175afb806e25871a24a934e07",
    },
}

def check_version(version):
    if version not in VERSION_URLS:
        fail("GNU M4 version {} not supported by rules_m4.".format(repr(version)))
