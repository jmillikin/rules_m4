<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# rules_m4

Bazel rules for the m4 macro expander.

<a id="m4"></a>

## m4

<pre>
load("@rules_m4//m4:m4.bzl", "m4")

m4(<a href="#m4-name">name</a>, <a href="#m4-srcs">srcs</a>, <a href="#m4-data">data</a>, <a href="#m4-freeze_state">freeze_state</a>, <a href="#m4-m4_options">m4_options</a>, <a href="#m4-output">output</a>, <a href="#m4-reload_state">reload_state</a>)
</pre>

Perform macro expansion to produce an output file.

This rule blocks the of execution shell commands (such as `syscmd`) by default.
To enable expansion of a file containing shell commands, set the `m4_syscmd`
target feature.

### Example

```starlark
load("@rules_m4//m4:m4.bzl", "m4")

m4(
    name = "m4_example.txt",
    srcs = ["m4_example.in.txt"],
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="m4-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="m4-srcs"></a>srcs |  List of source files to macro-expand.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="m4-data"></a>data |  List of additional files to m4.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="m4-freeze_state"></a>freeze_state |  Optional output file for GNU M4 frozen state. Must have extension `.m4f`.   | <a href="https://bazel.build/concepts/labels">Label</a>; <a href="https://bazel.build/reference/be/common-definitions#configurable-attributes">nonconfigurable</a> | optional |  `None`  |
| <a id="m4-m4_options"></a>m4_options |  Additional options to pass to the `m4` command.<br><br>These will be added to the command args immediately before the source files.   | List of strings | optional |  `[]`  |
| <a id="m4-output"></a>output |  File to write output to. If unset, defaults to the rule name.   | <a href="https://bazel.build/concepts/labels">Label</a>; <a href="https://bazel.build/reference/be/common-definitions#configurable-attributes">nonconfigurable</a> | optional |  `None`  |
| <a id="m4-reload_state"></a>reload_state |  Optional input file for GNU M4 frozen state. Must have extension `.m4f`.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="M4ToolchainInfo"></a>

## M4ToolchainInfo

<pre>
load("@rules_m4//m4:m4.bzl", "M4ToolchainInfo")

M4ToolchainInfo(<a href="#M4ToolchainInfo-all_files">all_files</a>, <a href="#M4ToolchainInfo-m4_tool">m4_tool</a>, <a href="#M4ToolchainInfo-m4_env">m4_env</a>)
</pre>

Provider for an m4 toolchain.

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="M4ToolchainInfo-all_files"></a>all_files |  A `depset` containing all files comprising this m4 toolchain.    |
| <a id="M4ToolchainInfo-m4_tool"></a>m4_tool |  A `FilesToRunProvider` for the `m4` binary.    |
| <a id="M4ToolchainInfo-m4_env"></a>m4_env |  Additional environment variables to set when running `m4_tool`.    |


<a id="m4_register_toolchains"></a>

## m4_register_toolchains

<pre>
load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")

m4_register_toolchains(<a href="#m4_register_toolchains-version">version</a>, <a href="#m4_register_toolchains-extra_copts">extra_copts</a>)
</pre>

A helper function for m4 toolchains registration.

This workspace macro will create a [`m4_repository`](#m4_repository) named
`m4_v{version}` and register it as a Bazel toolchain.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="m4_register_toolchains-version"></a>version |  A supported version of GNU M4.   |  `"1.4.18"` |
| <a id="m4_register_toolchains-extra_copts"></a>extra_copts |  Additional C compiler options to use when building GNU M4.   |  `[]` |


<a id="m4_toolchain"></a>

## m4_toolchain

<pre>
load("@rules_m4//m4:m4.bzl", "m4_toolchain")

m4_toolchain(<a href="#m4_toolchain-ctx">ctx</a>)
</pre>

Returns the current [`M4ToolchainInfo`](#M4ToolchainInfo).

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="m4_toolchain-ctx"></a>ctx |  A rule context, where the rule has a toolchain dependency on [`M4_TOOLCHAIN_TYPE`](#M4_TOOLCHAIN_TYPE).   |  none |

**RETURNS**

An [`M4ToolchainInfo`](#M4ToolchainInfo).


<a id="m4_repository"></a>

## m4_repository

<pre>
load("@rules_m4//m4:m4.bzl", "m4_repository")

m4_repository(<a href="#m4_repository-name">name</a>, <a href="#m4_repository-extra_copts">extra_copts</a>, <a href="#m4_repository-extra_linkopts">extra_linkopts</a>, <a href="#m4_repository-repo_mapping">repo_mapping</a>, <a href="#m4_repository-version">version</a>)
</pre>

Repository rule for GNU M4.

The resulting repository will have a `//bin:m4` executable target.

### Example

```starlark
load("@rules_m4//m4:m4.bzl", "m4_repository")

m4_repository(
    name = "m4_v1.4.18",
    version = "1.4.18",
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="m4_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="m4_repository-extra_copts"></a>extra_copts |  Additional C compiler options to use when building GNU M4.   | List of strings | optional |  `[]`  |
| <a id="m4_repository-extra_linkopts"></a>extra_linkopts |  Additional linker options to use when building GNU M4.   | List of strings | optional |  `[]`  |
| <a id="m4_repository-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |
| <a id="m4_repository-version"></a>version |  A supported version of GNU M4.   | String | required |  |


<a id="m4_toolchain_repository"></a>

## m4_toolchain_repository

<pre>
load("@rules_m4//m4:m4.bzl", "m4_toolchain_repository")

m4_toolchain_repository(<a href="#m4_toolchain_repository-name">name</a>, <a href="#m4_toolchain_repository-m4_repository">m4_repository</a>, <a href="#m4_toolchain_repository-repo_mapping">repo_mapping</a>)
</pre>

Toolchain repository rule for m4 toolchains.

Toolchain repositories add a layer of indirection so that Bazel can resolve
toolchains without downloading additional dependencies.

The resulting repository will have the following targets:
- `//bin:m4` (an alias into the underlying [`m4_repository`](#m4_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
load("@rules_m4//m4:m4.bzl", "m4_repository", "m4_toolchain_repository")

m4_repository(
    name = "m4_v1.4.18",
    version = "1.4.18",
)

m4_toolchain_repository(
    name = "m4",
    m4_repository = "@m4_v1.4.18",
)

register_toolchains("@m4//:toolchain")
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="m4_toolchain_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="m4_toolchain_repository-m4_repository"></a>m4_repository |  The name of an [`m4_repository`](#m4_repository).   | String | required |  |
| <a id="m4_toolchain_repository-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |



<a id="m4_repository_ext"></a>

## m4_repository_ext

<pre>
m4_repository_ext = use_extension("@rules_m4//m4/extensions:m4_repository_ext.bzl", "m4_repository_ext")
m4_repository_ext.repository(<a href="#m4_repository_ext.repository-name">name</a>, <a href="#m4_repository_ext.repository-extra_copts">extra_copts</a>, <a href="#m4_repository_ext.repository-extra_linkopts">extra_linkopts</a>, <a href="#m4_repository_ext.repository-version">version</a>)
</pre>

Module extension for declaring dependencies on GNU M4.

The resulting repository will have the following targets:
- `//bin:m4` (an alias into the underlying [`m4_repository`](#m4_repository))
- `//:toolchain`, which can be registered with Bazel.

### Example

```starlark
m4 = use_extension(
    "@rules_m4//m4/extensions:m4_repository_ext.bzl",
    "m4_repository_ext",
)

m4.repository(name = "m4", version = "1.4.18")
use_repo(m4, "m4")
register_toolchains("@m4//:toolchain")
```


**TAG CLASSES**

<a id="m4_repository_ext.repository"></a>

### repository

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="m4_repository_ext.repository-name"></a>name |  An optional name for the repository.<br><br>The name must be unique within the set of names registered by this extension. If unset, the repository name will default to `"m4_v{version}"`.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | optional |  `""`  |
| <a id="m4_repository_ext.repository-extra_copts"></a>extra_copts |  Additional C compiler options to use when building GNU M4.   | List of strings | optional |  `[]`  |
| <a id="m4_repository_ext.repository-extra_linkopts"></a>extra_linkopts |  Additional linker options to use when building GNU M4.   | List of strings | optional |  `[]`  |
| <a id="m4_repository_ext.repository-version"></a>version |  A supported version of GNU M4.   | String | optional |  `"1.4.18"`  |


