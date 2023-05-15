load("//m4:toolchain_type.bzl", "M4_TOOLCHAIN_TYPE")
load("//m4/internal:versions.bzl", "VERSION_URLS")

[toolchain(
    name = "v{}".format(version),
    toolchain = "@m4_v{}//rules_m4_internal:toolchain_info".format(version),
    toolchain_type = M4_TOOLCHAIN_TYPE,
) for version in VERSION_URLS]
