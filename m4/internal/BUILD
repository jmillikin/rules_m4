load("//m4:m4.bzl", "m4_common", "m4_toolchain_info")

[m4_toolchain_info(
    name = "toolchain_v{}".format(version),
    m4 = "@m4_v{}//bin:m4".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in m4_common.VERSIONS]

cc_binary(
    name = "capture_stdout",
    srcs = ["capture_stdout.c"],
    visibility = ["//m4:__pkg__"],
)

cc_binary(
    name = "deny_shell",
    srcs = ["deny_shell.c"],
    visibility = ["//m4:__pkg__"],
)
