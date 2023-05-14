load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

bzl_library(
    name = "rules_m4_bzl_srcs",
    srcs = ["//m4:bzl_srcs"],
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
