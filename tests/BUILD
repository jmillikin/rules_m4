load("//:m4.bzl", "m4_expansion", "m4_template")

m4_expansion(
    name = "expansion_test",
    srcs = ["expansion_test.in"],
)

m4_template(
    name = "template_1",
    srcs = ["template_1.m4"],
)

m4_template(
    name = "template_2",
    srcs = ["template_2.m4"],
    base = ":template_1",
)

m4_expansion(
    name = "template_test",
    srcs = ["template_test.in"],
    template = ":template_2",
)

filegroup(
    name = "testdata",
    srcs = [
        ":expansion_test",
        ":template_test",
    ],
)

cc_test(
    name = "m4_test",
    srcs = ["m4_test.cc"],
    data = [":testdata"],
    deps = [
        "@com_google_googletest//:gtest",
        "@com_google_googletest//:gtest_main",
    ],
)
