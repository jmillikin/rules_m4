# Bazel build rules for GNU M4

## Overview

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_m4",
    # See https://github.com/jmillikin/rules_m4/releases for copy-pastable
    # URLs and checksums.
)

load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")

m4_register_toolchains()
```

```python
load("@rules_m4//m4:m4.bzl", "m4")

m4(
    name = "hello_world",
    srcs = ["hello_world.in.txt"],
    output = "hello_world.txt",
)
```

```python
genrule(
    name = "hello_world_gen",
    srcs = ["hello_world.in.txt"],
    outs = ["hello_world_gen.txt"],
    cmd = "$(M4) $(SRCS) > $@",
    toolchains = ["@rules_m4//m4:current_m4_toolchain"],
)
```

## Toolchains

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
    _my_rule,
    toolchains = [M4_TOOLCHAIN_TYPE],
)
```
