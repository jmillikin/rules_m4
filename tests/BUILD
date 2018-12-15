load("//:m4.bzl", "m4_expansion", "m4_template")

m4_expansion(
    name = "expansion_test",
    srcs = ["expansion_test.in"],
)

m4_template(
    name = "template_test_1",
    srcs = ["template_test_1.m4"],
)

m4_template(
    name = "template_test_2",
    srcs = ["template_test_2.m4"],
    base = ":template_test_1",
)

m4_expansion(
    name = "recovery_test",
    srcs = ["recovery_test.in"],
    template = ":template_test_2",
)
