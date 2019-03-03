load("@rules_m4//m4/internal:versions.bzl", "VERSION_URLS")
load("@rules_m4//m4/internal:toolchain.bzl", "m4_toolchain_info")

[m4_toolchain_info(
    name = "toolchain_v{}".format(version),
    m4 = "@m4_v{}//bin:m4".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in VERSION_URLS]

cc_binary(
    name = "capture_stdout",
    srcs = ["capture_stdout.c"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "deny_shell",
    srcs = ["deny_shell.c"],
    visibility = ["//visibility:public"],
)
