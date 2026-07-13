"""Helpers for constructing implementations of the canonical toolchains."""

load(":providers.bzl", "XsltToolchainInfo")

visibility("public")

def _xslt_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            xslt = XsltToolchainInfo(
                adapter = ctx.attr.adapter[DefaultInfo].files_to_run,
                capabilities = tuple(sorted(ctx.attr.capabilities)),
            ),
        ),
    ]

xslt_toolchain = rule(
    implementation = _xslt_impl,
    doc = "Wraps a processor adapter as the canonical rules_xslt toolchain.",
    attrs = {
        "adapter": attr.label(mandatory = True, executable = True, cfg = "exec", doc = "Executable implementing the rules_xslt adapter protocol."),
        "capabilities": attr.string_list(doc = "Processor capabilities advertised for analysis-time stage checks."),
    },
)
