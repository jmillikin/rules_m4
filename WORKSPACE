workspace(name = "rules_m4")

load("@rules_m4//m4:m4.bzl", "m4_register_toolchains", "m4_repository")
load("@rules_m4//m4/internal:testutil.bzl", "rules_m4_testutil")
load("@rules_m4//m4/internal:versions.bzl", "VERSION_URLS")

rules_m4_testutil(name = "rules_m4_testutil")

m4_register_toolchains()

[m4_repository(
    name = "m4_v" + version,
    version = version,
) for version in VERSION_URLS]

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "com_google_googletest",
    sha256 = "9bf1fe5182a604b4135edc1a425ae356c9ad15e9b23f9f12a02e80184c3a249c",
    strip_prefix = "googletest-release-1.8.1",
    urls = ["https://github.com/google/googletest/archive/release-1.8.1.tar.gz"],
)
