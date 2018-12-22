load("//:m4.bzl", "M4_VERSIONS")
load("//m4:toolchain.bzl", "m4_toolchain")

[m4_toolchain(
    name = "v{}".format(version),
    m4 = "@m4_v{}//bin:m4".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in M4_VERSIONS]

[toolchain(
    name = "v{}_toolchain".format(version),
    toolchain = ":v{}".format(version),
    toolchain_type = "//m4:toolchain_type",
) for version in M4_VERSIONS]
