load("@rules_m4//m4/internal:toolchain_alias.bzl", "m4_toolchain_alias")

filegroup(
    name = "bzl_srcs",
    srcs = glob(["*.bzl"]) + [
        "//m4/internal:bzl_srcs",
        "//m4/rules:bzl_srcs",
    ],
    visibility = ["//:__subpackages__"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

m4_toolchain_alias(
    name = "current_m4_toolchain",
    visibility = ["//visibility:public"],
)
