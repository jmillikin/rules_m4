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

"""Supported versions of GNU M4."""

_DEFAULT_HTTP_MIRRORS = [
    "https://ftpmirror.gnu.org/m4/",
    "https://mirrors.kernel.org/gnu/m4/",
    "https://ftp.gnu.org/gnu/m4/",
]

DEFAULT_VERSION = "1.4.18"

_VERSIONS = [
    ("1.4.18", "m4-1.4.18.tar.xz", "f2c1e86ca0a404ff281631bdc8377638992744b175afb806e25871a24a934e07"),
    ("1.4.17", "m4-1.4.17.tar.xz", "f0543c3beb51fa6b3337d8025331591e0e18d8ec2886ed391f1aade43477d508"),
    ("1.4.16", "m4-1.4.16.tar.xz", "d5b5d51cf8f5b18f3bac39bc2f6b1e61f34d400136ae1a87d075e26a38028d5d"),
    ("1.4.15", "m4-1.4.15.tar.xz", "ec26b4ef8037286b36bc5af9893f0da63bf8615bbf478a587aa6cab927b0349d"),
    ("1.4.14", "m4-1.4.14.tar.xz", "16a0c091fc1b532b53560c4c5c1efe650e8c6df41bb120c5f57523e512d14b82"),
    ("1.4.13", "m4-1.4.13.tar.xz", "a69ce082cdbd732204c36059c18b2a671c5eb92f4453bcc5ea1ab12dc6f88ed0"),
    ("1.4.12", "m4-1.4.12.tar.gz", "47e8f9a33ba06fa6710b42d6f6ded41f45027f6f4039b0a3ed887c5116bc2173"),
    ("1.4.11", "m4-1.4.11.tar.gz", "c67b759d96471c9337d3b9f0ab2e1308f461a7dba445cfe0c3750db15b7ca77f"),
    ("1.4.10", "m4-1.4.10.tar.gz", "197fcb73c346fa669f143c3f0ec3144271f133647df00b2258bff1fd485cabe0"),
    ("1.4.9", "m4-1.4.9.tar.gz", "815ce53853fbf6493617f467389b799208b1ec98296b95be44a683f8bcfd7c47"),
    ("1.4.8", "m4-1.4.8.tar.gz", "0f4e55d362408e189d0c0f4e6929f4b5be7eb281e46cbf0ce3f035370c00bc7e"),
    ("1.4.7", "m4-1.4.7.tar.gz", "093c993767f563a11e41c1cf887f4e9065247129679d4c1e213d0544d16d8303"),
    ("1.4.6", "m4-1.4.6.tar.gz", "130402a5751721771a3f3d5a71189ae744df9deb3f9988e15087c8b16a135310"),
    ("1.4.5", "m4-1.4.5.tar.gz", "85427df4ad38b078f68c16f235f2cd2733256149854b7ee699f6d5a7f8d38610"),
    ("1.4.4", "m4-1.4.4.tar.gz", "a116c52d314c8e3365756cb1e14c6b460d6bd28769121f92373a362497359d88"),
    ("1.4.3", "m4-1.4.3.tar.gz", "7a00383003f94509ffdceec54033527c700fe87207ce5c0bc9b7199eab8a8428"),
    ("1.4.2", "m4-1.4.2.tar.gz", "bf651842b8f97a35aa6111a64771527a18dc5beda98b3bc12c4afd3fa132a7d6"),
    ("1.4.1", "m4-1.4.1.tar.gz", "6a2c6ce147b6f7a81cc0b9489100605775c107d2c1210a23d9906545535d3caf"),
]

# buildifier: disable=function-docstring
def custom_version_urls(http_mirrors, extra_http_mirrors):
    if http_mirrors == []:
        http_mirrors = _DEFAULT_HTTP_MIRRORS
    all_mirrors = http_mirrors + extra_http_mirrors
    urls = {}
    for (version, filename, sha256) in _VERSIONS:
        urls[version] = dict(
            urls = [m + filename for m in all_mirrors],
            sha256 = sha256,
        )
    return urls

VERSION_URLS = custom_version_urls([], [])

def check_version(version):
    if version not in VERSION_URLS:
        fail("GNU M4 version {} not supported by rules_m4.".format(repr(version)))
