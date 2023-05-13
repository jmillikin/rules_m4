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
    sha256 = "81964fe578e9bd7c94dfdb09c8e4d6e6759e19967e397dbea48d1c10e45d0df2",
    strip_prefix = "googletest-release-1.12.1",
    urls = ["https://github.com/google/googletest/archive/release-1.12.1.tar.gz"],
)
