# Bazel build rules for GNU M4

The [m4] macro processing language is commonly used as an intermediate format
for text-based Unix development tools such as [Bison] and [Flex].

This Bazel ruleset allows [GNU M4] to be integrated into a Bazel build. It can
be used to perform macro expansion with the `//m4:m4.bzl%m4` build rule, or as
a dependency in other rules via the Bazel toolchain system.

Currently, the only implementation of m4 supported by this ruleset is [GNU M4].

API reference: [docs/rules_m4.md](docs/rules_m4.md)

[m4]: https://en.wikipedia.org/wiki/M4_(computer_language)
[Bison]: https://www.gnu.org/software/bison/
[Flex]: https://github.com/westes/flex
[GNU M4]: https://www.gnu.org/software/m4/

## Setup

Add the following to your `MODULE.bazel`:

```python
bazel_dep(name = "rules_m4", version = "0.3.1")
```

To specify a version or build with additional C compiler options, use the
`m4_repository_ext` module extension:

```python
m4 = use_extension(
    "@rules_m4//m4/extensions:m4_repository_ext.bzl",
    "m4_repository_ext",
)
m4.repository(
    name = "m4",
    version = "1.4.17",
    extra_copts = ["-O3"],
)
use_repo(m4, "m4")
register_toolchains("@m4//:toolchain")
```

Note that repository names registered with a given bzlmod module extension must
be unique within the scope of that extension. See the [Bazel module extensions]
documentation for more details.

[Bazel module extensions]: https://bazel.build/external/extension

## Examples

Macro expansion with the `//m4:m4.bzl%m4` build rule:

```python
load("@rules_m4//m4:m4.bzl", "m4")

m4(
    name = "hello_world",
    srcs = ["hello_world.in.txt"],
    output = "hello_world.txt",
)
```

Macro expansion in a `genrule`:

```python
genrule(
    name = "hello_world_gen",
    srcs = ["hello_world.in.txt"],
    outs = ["hello_world_gen.txt"],
    cmd = "$(M4) $(SRCS) > $@",
    toolchains = ["@rules_m4//m4:current_m4_toolchain"],
)
```

Writing a custom rule that depends on `m4` as a toolchain:

```python
load("@rules_m4//m4:m4.bzl", "M4_TOOLCHAIN_TYPE", "m4_toolchain")

def _my_rule(ctx):
    m4 = m4_toolchain(ctx)
    ctx.actions.run(
        tools = [m4.m4_tool],
        env = m4.m4_env,
        # ...
    )

my_rule = rule(
    implementation = _my_rule,
    toolchains = [M4_TOOLCHAIN_TYPE],
)
```
