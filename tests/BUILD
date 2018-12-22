load("//:m4.bzl", "m4", "m4_template")

m4(
    name = "expansion_test",
    srcs = ["expansion_test.in"],
    out = "expansion_test.txt",
    opts = ["--synclines"],
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

m4(
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
