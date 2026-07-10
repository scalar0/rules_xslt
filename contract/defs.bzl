"""Contract Bazel rules for publishing XML/XSLT transform targets."""

load("//contract:providers.bzl", "XsltTransformInfo")

def _xslt_transform_def_impl(ctx):
    input_schema_deps = depset(ctx.files.input_schema_deps)
    deps = depset(ctx.files.deps)
    resources = depset(ctx.files.resources)
    output_schema_deps = depset(ctx.files.output_schema_deps)

    files = depset(
        [ctx.file.input_schema, ctx.file.stylesheet, ctx.file.output_schema],
        transitive = [input_schema_deps, deps, resources, output_schema_deps],
    )

    return [
        DefaultInfo(files = files),
        XsltTransformInfo(
            input_schema = ctx.file.input_schema,
            input_schema_deps = input_schema_deps,
            stylesheet = ctx.file.stylesheet,
            deps = deps,
            resources = resources,
            output_schema = ctx.file.output_schema,
            output_schema_deps = output_schema_deps,
            default_params = ctx.attr.default_params,
            required_params = tuple(ctx.attr.required_params),
            output_kind = ctx.attr.output_kind,
        ),
    ]

xslt_transform_def = rule(
    implementation = _xslt_transform_def_impl,
    doc = "Describes a versioned XSLT transform role without executing it.",
    attrs = {
        "input_schema": attr.label(mandatory = True, allow_single_file = True),
        "input_schema_deps": attr.label_list(allow_files = True),
        "stylesheet": attr.label(mandatory = True, allow_single_file = True),
        "deps": attr.label_list(allow_files = True),
        "resources": attr.label_list(allow_files = True),
        "output_schema": attr.label(mandatory = True, allow_single_file = True),
        "output_schema_deps": attr.label_list(allow_files = True),
        "default_params": attr.string_dict(),
        "required_params": attr.string_list(),
        "output_kind": attr.string(mandatory = True),
    },
)
