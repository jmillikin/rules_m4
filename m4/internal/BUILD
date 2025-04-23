load("@rules_cc//cc:cc_binary.bzl", "cc_binary")

filegroup(
    name = "bzl_srcs",
    srcs = glob([
        "*.bzl",
        "gnulib/*.bzl",
    ]),
    visibility = ["//:__subpackages__"],
)

cc_binary(
    name = "capture_stdout",
    srcs = ["capture_stdout.c"],
    features = ["-default_link_libs"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "deny_shell",
    srcs = ["deny_shell.c"],
    features = ["-default_link_libs"],
    visibility = ["//visibility:public"],
)
