load("@rules_m4//m4/internal:toolchain.bzl", "M4_TOOLCHAIN_TYPE")
load("@rules_m4//m4/internal:versions.bzl", "VERSION_URLS")

[toolchain(
    name = "v{}".format(version),
    toolchain = "@m4_v{}//rules_m4_internal:toolchain_info".format(version),
    toolchain_type = M4_TOOLCHAIN_TYPE,
) for version in VERSION_URLS]
