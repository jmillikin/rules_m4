load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

# TODO: Required due to https://github.com/bazelbuild/rules_cc/issues/279
bzl_library(
    name = "rules_cc_bzl_lib",
    srcs = ["@rules_cc//cc:bzl_srcs"],
    deps = [
        "@rules_cc//cc/common",
    ],
)

bzl_library(
    name = "rules_m4_bzl_srcs",
    srcs = ["//m4:bzl_srcs"],
    deps = [":rules_cc_bzl_lib"],
)

stardoc(
    name = "rules_m4_md",
    out = "rules_m4.md",
    input = "rules_m4_md.bzl",
    deps = [":rules_m4_bzl_srcs"],
)

filegroup(
    name = "stardoc_outputs",
    srcs = [":rules_m4.md"],
    visibility = ["//:__subpackages__"],
)
