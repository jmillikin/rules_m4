load("@rules_m4//m4/internal:repository.bzl", "m4_repository")
load("@rules_m4//m4/internal:versions.bzl", "DEFAULT_VERSION", "check_version")

def _initialize_m4_toolchains_impl(module_ctx):
    # Override extra_copts with the values in the user-specified MODULE.bazel.
    # This corresponds to the first entry in this list. If a user does not
    # manually configure the repo via initialize_m4_toolchain.configure, the
    # empty default values are used.
    extra_copts = []
    for module in module_ctx.modules:
        extra_copts = module.tags.configure[0].extra_copts
        break

    # Enabling non-default versions requires complicated version resolution and
    # encapsulation of toolchains. Bzlmod users will most likely want to use the
    # latest available version of m4 without thinking too much about it.
    check_version(DEFAULT_VERSION)
    repo_name = "m4_v{}".format(DEFAULT_VERSION)
    if repo_name not in native.existing_rules().keys():
        m4_repository(
            name = repo_name,
            version = DEFAULT_VERSION,
            extra_copts = extra_copts,
        )

initialize_m4_toolchains = module_extension(
    implementation = _initialize_m4_toolchains_impl,
    tag_classes = {
        "configure": tag_class(
            attrs = {
                "extra_copts": attr.string_list(),
            },
        ),
    },
)
