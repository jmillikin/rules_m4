load("@rules_m4//m4:m4.bzl", "m4_common")

[toolchain(
    name = "v{}".format(version),
    toolchain = "@rules_m4//m4/internal:toolchain_v{}".format(version),
    toolchain_type = m4_common.TOOLCHAIN_TYPE,
) for version in m4_common.VERSIONS]
