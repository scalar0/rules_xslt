"""Public API for target-based, processor-independent XSLT execution."""

load(
    ":providers.bzl",
    "XsltLibraryInfo",
    "XsltStageInfo",
)

visibility("public")

_XSLT_TOOLCHAIN = "@rules_xslt//:xslt_toolchain_type"

def _library_impl(ctx):
    transitive_files = [d[XsltLibraryInfo].files for d in ctx.attr.deps]
    transitive_catalog = [d[XsltLibraryInfo].catalog for d in ctx.attr.deps]
    uri_files = [target.files.to_list()[0] for target in ctx.attr.uri_mappings]
    direct_catalog = [
        (uri, target.files.to_list()[0])
        for target, uri in ctx.attr.uri_mappings.items()
    ]
    files = depset(
        [ctx.file.stylesheet] + ctx.files.srcs + uri_files,
        transitive = transitive_files,
    )
    catalog = depset(
        [(ctx.attr.uri, ctx.file.stylesheet)] + direct_catalog,
        transitive = transitive_catalog,
    )
    return [
        DefaultInfo(files = files),
        XsltLibraryInfo(
            stylesheet = ctx.file.stylesheet,
            uri = ctx.attr.uri,
            files = files,
            catalog = catalog,
        ),
    ]

_xslt_library = rule(
    implementation = _library_impl,
    doc = "Declares a reusable stylesheet and its transitive logical URI catalog.",
    attrs = {
        "stylesheet": attr.label(mandatory = True, allow_single_file = True, doc = "Public stylesheet entry point."),
        "uri": attr.string(mandatory = True, doc = "Stable logical URI used by xsl:include or xsl:import."),
        "srcs": attr.label_list(allow_files = True, doc = "Private files included by relative URI from this component."),
        "deps": attr.label_list(providers = [XsltLibraryInfo], doc = "Libraries referenced through logical XSLT URIs."),
        "uri_mappings": attr.label_keyed_string_dict(allow_files = True, doc = "Fixed files mapped to logical document URIs."),
    },
)

def xslt_library(
        name,
        stylesheet,
        uri,
        srcs = [],
        deps = [],
        uri_mappings = {},
        **kwargs):
    """Publishes a reusable XSLT library.

    Args:
      name: Target name.
      stylesheet: Public stylesheet entry-point label.
      uri: Stable logical URI for cross-library inclusion.
      srcs: Private relative include files.
      deps: Provider-backed XSLT library dependencies.
      uri_mappings: Logical document URIs mapped to fixed file labels.
      **kwargs: Common Bazel rule attributes.
    """
    _xslt_library(
        name = name,
        stylesheet = stylesheet,
        uri = uri,
        srcs = srcs,
        deps = deps,
        uri_mappings = {label: uri for uri, label in uri_mappings.items()},
        **kwargs
    )

def _stage_impl(ctx):
    libraries = [d[XsltLibraryInfo] for d in ctx.attr.deps]
    files = depset([ctx.file.stylesheet], transitive = [d.files for d in libraries])
    catalog = depset(transitive = [d.catalog for d in libraries])
    uri_files = [target.files.to_list()[0] for target in ctx.attr.uri_mappings]
    direct_catalog = [
        (uri, target.files.to_list()[0])
        for target, uri in ctx.attr.uri_mappings.items()
    ]
    files = depset(uri_files, transitive = [files])
    catalog = depset(direct_catalog, transitive = [catalog])
    inferred_capabilities = []
    if ctx.attr.output_mode == "multi":
        inferred_capabilities.append("secondary-result-document")
    if ctx.attr.uri_mappings:
        inferred_capabilities.append("xml-catalog")
    return [
        DefaultInfo(
            files = files,
        ),
        XsltStageInfo(
            label = ctx.label,
            stylesheet = ctx.file.stylesheet,
            files = files,
            catalog = catalog,
            capabilities = tuple(sorted(ctx.attr.capabilities + inferred_capabilities)),
            output_mode = ctx.attr.output_mode,
        ),
    ]

_xslt_stage = rule(
    implementation = _stage_impl,
    doc = "Declares a completely predefined executable XSLT stage.",
    attrs = {
        "stylesheet": attr.label(mandatory = True, allow_single_file = True, doc = "Executable stylesheet entry point."),
        "deps": attr.label_list(providers = [XsltLibraryInfo], doc = "Libraries forming the stylesheet compilation closure."),
        "uri_mappings": attr.label_keyed_string_dict(allow_files = True, doc = "Fixed files mapped to logical document URIs."),
        "capabilities": attr.string_list(doc = "Exceptional processor capabilities not inferred from the stage shape."),
        "output_mode": attr.string(values = ["single", "multi"], doc = "Whether the stage emits one principal XML file or declared secondary files."),
    },
)

def xslt_stage(
        name,
        stylesheet,
        deps = [],
        uri_mappings = {},
        capabilities = [],
        output_mode = "single",
        **kwargs):
    """Declares an executable stage.

    Args:
      name: Target name.
      stylesheet: Entry-point stylesheet label.
      deps: XSLT library targets.
      uri_mappings: Logical URIs mapped to fixed file labels.
      capabilities: Required processor capabilities.
      output_mode: Either single or multi.
      **kwargs: Common Bazel rule attributes.
    """
    _xslt_stage(
        name = name,
        stylesheet = stylesheet,
        deps = deps,
        uri_mappings = {label: uri for uri, label in uri_mappings.items()},
        capabilities = capabilities,
        output_mode = output_mode,
        **kwargs
    )

def _single_source(
        ctx,
        owner):
    files = ctx.attr.src.files.to_list()
    if len(files) != 1:
        fail("%s %s: src must contain exactly one file" % (owner, ctx.label))
    return files[0]

def _transform(
        actions,
        toolchain,
        src,
        stage,
        out,
        mnemonic):
    args = actions.args()
    args.add_all(
        [
            "--source",
            src.path,
            "--stylesheet",
            stage.stylesheet.path,
            "--output",
            out.path,
        ],
    )
    for uri, file in sorted(stage.catalog.to_list()):
        args.add_all(["--uri-map", uri, file.path])
    actions.run(
        executable = toolchain.adapter,
        tools = [toolchain.adapter],
        inputs = depset([src], transitive = [stage.files]),
        outputs = [out],
        arguments = [args],
        mnemonic = mnemonic,
    )

def _number(value):
    if value < 10:
        return "00%d" % value
    if value < 100:
        return "0%d" % value
    return str(value)

def _chain_impl(ctx):
    if not ctx.attr.stages:
        fail("xslt_chain %s: stages must be non-empty" % ctx.label)
    src = _single_source(ctx, "xslt_chain")
    xslt = ctx.toolchains[_XSLT_TOOLCHAIN].xslt
    intermediates = []
    for index, target in enumerate(ctx.attr.stages):
        position = index + 1
        stage = target[XsltStageInfo]
        if stage.output_mode != "single":
            fail(
                "xslt_chain %s: stage %d %s must use output_mode single" %
                (ctx.label, position, stage.label),
            )
        missing_caps = [c for c in stage.capabilities if c not in xslt.capabilities]
        if missing_caps:
            fail(
                "xslt_chain %s: stage %d %s requires missing capabilities %s" %
                (ctx.label, position, stage.label, missing_caps),
            )
        out = (
            ctx.outputs.out if position == len(ctx.attr.stages) else ctx.actions.declare_file(
                "%s.stage_%s.xml" % (ctx.label.name, _number(position)),
            )
        )
        _transform(
            ctx.actions,
            xslt,
            src,
            stage,
            out,
            "XsltTransform",
        )
        if position < len(ctx.attr.stages):
            intermediates.append(out)
        src = out
    return [
        DefaultInfo(files = depset([ctx.outputs.out])),
        OutputGroupInfo(intermediates = depset(intermediates)),
    ]

_xslt_chain = rule(
    implementation = _chain_impl,
    doc = "Executes a non-empty ordered sequence of single-output XSLT stages.",
    attrs = {
        "src": attr.label(mandatory = True, allow_files = True, doc = "Single source XML file."),
        "stages": attr.label_list(providers = [XsltStageInfo], doc = "Ordered single-output stages."),
        "out": attr.output(mandatory = True, doc = "Final XML output."),
    },
    toolchains = [_XSLT_TOOLCHAIN],
)

def xslt_chain(
        name,
        src,
        stages,
        out,
        **kwargs):
    """Executes an ordered linear XSLT pipeline.

    Args:
      name: Target name.
      src: Label producing exactly one source XML file.
      stages: Non-empty ordered list of predefined single-output stage targets.
      out: Final output filename.
      **kwargs: Common Bazel rule attributes.
    """
    _xslt_chain(
        name = name,
        src = src,
        stages = stages,
        out = out,
        **kwargs
    )

def _multi_impl(ctx):
    src = _single_source(ctx, "xslt_transform_multi")
    stage = ctx.attr.stage[XsltStageInfo]
    if stage.output_mode != "multi":
        fail(
            "xslt_transform_multi %s: stage %s must use output_mode multi" %
            (ctx.label, stage.label),
        )
    if not ctx.outputs.outs:
        fail("xslt_transform_multi %s: outs must be non-empty" % ctx.label)
    dirs = {o.dirname: True for o in ctx.outputs.outs}
    if len(dirs) != 1:
        fail(
            "xslt_transform_multi %s: every output must share one directory" % ctx.label,
        )
    xslt = ctx.toolchains[_XSLT_TOOLCHAIN].xslt
    missing_caps = [c for c in stage.capabilities if c not in xslt.capabilities]
    if missing_caps:
        fail(
            "xslt_transform_multi %s: missing capabilities %s" %
            (ctx.label, missing_caps),
        )
    output_parts = ctx.outputs.outs[0].short_path.split("/")[:-1]
    output_prefix = "/".join(output_parts)
    stamp = ctx.actions.declare_file(
        (output_prefix + "/" if output_prefix else "") +
        ".%s.principal.xml" % ctx.label.name,
    )
    args = ctx.actions.args()
    args.add_all(
        [
            "--source",
            src.path,
            "--stylesheet",
            stage.stylesheet.path,
            "--output",
            stamp.path,
        ],
    )
    for uri, file in sorted(stage.catalog.to_list()):
        args.add_all(["--uri-map", uri, file.path])
    ctx.actions.run(
        executable = xslt.adapter,
        tools = [xslt.adapter],
        inputs = depset([src], transitive = [stage.files]),
        outputs = [stamp] + ctx.outputs.outs,
        arguments = [args],
        mnemonic = "XsltTransformMulti",
    )
    return [DefaultInfo(files = depset(ctx.outputs.outs))]

_xslt_transform_multi = rule(
    implementation = _multi_impl,
    doc = "Executes one predefined stage that emits declared secondary XML files.",
    attrs = {
        "src": attr.label(mandatory = True, allow_files = True, doc = "Single source XML file."),
        "stage": attr.label(mandatory = True, providers = [XsltStageInfo], doc = "Predefined multi-output stage."),
        "outs": attr.output_list(mandatory = True, doc = "Expected secondary XML outputs in one directory."),
    },
    toolchains = [_XSLT_TOOLCHAIN],
)

def xslt_transform_multi(
        name,
        src,
        stage,
        outs,
        **kwargs):
    """Executes a predefined multi-output XSLT stage.

    Args:
      name: Target name.
      src: Label producing exactly one source XML file.
      stage: Stage target declared with output_mode set to multi.
      outs: Non-empty expected output filenames sharing one directory.
      **kwargs: Common Bazel rule attributes.
    """
    _xslt_transform_multi(
        name = name,
        src = src,
        stage = stage,
        outs = outs,
        **kwargs
    )
