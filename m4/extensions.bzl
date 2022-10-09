load("@rules_m4//m4/internal:repository.bzl", "m4_repository")
load("@rules_m4//m4/internal:versions.bzl", "DEFAULT_VERSION", "check_version")

def _m4_extension_impl(module_ctx):
    registered_configs = []
    for module in module_ctx.modules:
        for config in module.tags.configure_toolchain:
            check_version(config.version)
            registered_versions = [
                version
                for (version, _) in registered_configs
            ]
            if config.version not in registered_versions:
                registered_configs.append((config.version, config.extra_copts))

    for (version, extra_copts) in registered_configs:
        m4_repository(
            name = "m4_v{}".format(version),
            version = version,
            extra_copts = extra_copts,
        )

m4_extension = module_extension(
    implementation = _m4_extension_impl,
    tag_classes = {
        "configure_toolchain": tag_class(
            attrs = {
                "version": attr.string(default = DEFAULT_VERSION),
                "extra_copts": attr.string_list(),
            },
        ),
    },
)
