"""# rules_m4

Bazel rules for the m4 macro expander.
"""

load(
    "//m4:m4.bzl",
    _M4ToolchainInfo = "M4ToolchainInfo",
    _m4 = "m4",
    _m4_register_toolchains = "m4_register_toolchains",
    _m4_repository = "m4_repository",
    _m4_toolchain = "m4_toolchain",
    _m4_toolchain_repository = "m4_toolchain_repository",
)

m4 = _m4
m4_register_toolchains = _m4_register_toolchains
m4_repository = _m4_repository
m4_toolchain = _m4_toolchain
m4_toolchain_repository = _m4_toolchain_repository
M4ToolchainInfo = _M4ToolchainInfo
