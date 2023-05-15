load("//m4:m4.bzl", "m4")

m4(
    name = "expansion_test",
    srcs = ["expansion_test.in"],
    m4_options = ["--synclines"],
    output = "expansion_test.txt",
)

genrule(
    name = "genrule_test",
    srcs = ["expansion_test.in"],
    outs = ["genrule_test.txt"],
    cmd = """
cp $(location expansion_test.in) genrule_test.in
$(M4) --synclines genrule_test.in > $@
""",
    toolchains = ["//m4:current_m4_toolchain"],
)

m4(
    name = "template_1",
    srcs = ["template_1.m4"],
    freeze_state = "template_1.m4f",
)

m4(
    name = "template_2",
    srcs = ["template_2.m4"],
    freeze_state = "template_2.m4f",
    reload_state = ":template_1.m4f",
)

m4(
    name = "template_test",
    srcs = ["template_test.in"],
    reload_state = ":template_2.m4f",
)

filegroup(
    name = "testdata",
    srcs = [
        ":expansion_test",
        ":genrule_test",
        ":template_test",
    ],
)

cc_test(
    name = "m4_test",
    srcs = ["m4_test.cc"],
    data = [":testdata"],
    linkstatic = True,
    local_defines = [
        "'EXPANSION_TEST_IN=\"" + package_name() + "/expansion_test.in\"'",
    ],
    deps = [
        "@bazel_tools//tools/cpp/runfiles",
        "@com_google_googletest//:gtest",
        "@com_google_googletest//:gtest_main",
    ],
)

alias(
    name = "all_versions",
    actual = "@rules_m4_testutil//:all_versions",
    tags = ["manual"],
)

sh_test(
    name = "docs_test",
    srcs = ["docs_test.sh"],
    data = [
        "//docs",
        "//tools/stardoc:stardoc_outputs",
    ],
    tags = ["manual"],
)
