workspace(name = "rules_m4")

load("@rules_m4//m4:m4.bzl", "m4_register_toolchains", "m4_repository")

# buildifier: disable=bzl-visibility
load("@rules_m4//m4/internal:testutil.bzl", "rules_m4_testutil")

# buildifier: disable=bzl-visibility
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

http_archive(
    name = "bazel_skylib",
    sha256 = "f7be3474d42aae265405a592bb7da8e171919d74c16f082a5457840f06054728",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
    ],
)

http_archive(
    name = "io_bazel_stardoc",
    sha256 = "ca933f39f2a6e0ad392fa91fd662545afcbd36c05c62365538385d35a0323096",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.8.0/stardoc-0.8.0.tar.gz",
        "https://github.com/bazelbuild/stardoc/releases/download/0.8.0/stardoc-0.8.0.tar.gz",
    ],
)
