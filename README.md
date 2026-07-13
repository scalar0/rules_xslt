# rules_xslt

`rules_xslt` is the processor-independent rules and provider module.
It contains no Saxon runtime and no OOXML-specific assets.

## Consumer setup

Add the module dependency and register a compatible processor implementation in the root module.

```starlark
bazel_dep(name = "rules_xslt", version = "1.0.0")
bazel_dep(name = "saxon_toolchain", version = "1.0.0")

register_toolchains("@saxon_toolchain//:saxon")
```

Load all public APIs from one entry point.

```starlark
load(
    "@rules_xslt//:defs.bzl",
    "xslt_chain",
    "xslt_library",
    "xslt_stage",
    "xslt_transform_multi",
)
```

## Execute a linear chain

Every stage is predefined by its publishing module.
The source label must produce exactly one file, and every selected stage must use `output_mode = "single"`.

```starlark
xslt_chain(
    name = "result",
    src = "input.xml",
    stages = [
        "@transform_assets//stages:normalize",
        "@transform_assets//stages:render",
    ],
    out = "result.xml",
)
```

`DefaultInfo` exposes only `result.xml`.
Non-final files are available through the `intermediates` output group.

```bash
bazel build //:result --output_groups=+intermediates
```

## Execute a fan-out stage

Every expected secondary result must be declared under one output directory.
The stylesheet determines the filenames, so the `outs` list must match them exactly.

```starlark
xslt_transform_multi(
    name = "parts",
    src = "array.xml",
    stage = "@transform_assets//stages:split",
    outs = [
        "parts/Alpha.xml",
        "parts/Beta.xml",
    ],
)
```

## Publish transformation assets

Use `xslt_library` for reusable stylesheet boundaries referenced by logical `xsl:include` or `xsl:import` URIs.
Use `xslt_stage` only for complete executable entry points.

```starlark
xslt_library(
    name = "styles",
    stylesheet = "styles.xslt",
    uri = "urn:example:styles:1",
    uri_mappings = {
        "urn:example:style-map": "style-map.xml",
    },
)

xslt_stage(
    name = "render",
    stylesheet = "render.xslt",
    deps = [":styles"],
    capabilities = ["xslt-3.0"],
)
```

`output_mode = "multi"` automatically requires `secondary-result-document`.
Non-empty `uri_mappings` automatically require `xml-catalog`.
