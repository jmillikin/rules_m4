load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

stardoc(
    name = "m4_md",
    out = "m4.md",
    header_template = ":header.vm",
    input = "//m4:m4_bzl",
    deps = ["//m4:bzl_srcs"],
)

stardoc(
    name = "m4_repository_ext_md",
    out = "m4_repository_ext.md",
    header_template = ":empty.vm",
    input = "//m4/extensions:m4_repository_ext_bzl",
    deps = ["//m4:bzl_srcs"],
)

stardoc(
    name = "m4_toolchains_ext_md",
    out = "m4_toolchains_ext.md",
    header_template = ":empty.vm",
    input = "//m4/extensions:m4_toolchains_ext_bzl",
    deps = ["//m4:bzl_srcs"],
)

genrule(
    name = "rules_m4_md",
    srcs = [
        ":m4_md",
        ":m4_repository_ext_md",
        ":m4_toolchains_ext_md",
    ],
    outs = ["rules_m4.md"],
    cmd = "cat $(SRCS) > $@",
)

filegroup(
    name = "stardoc_outputs",
    srcs = [":rules_m4.md"],
    visibility = ["//:__subpackages__"],
)
