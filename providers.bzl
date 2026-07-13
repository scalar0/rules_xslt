"""Canonical providers for processor-independent XML and XSLT rules."""

visibility("private")

XsltLibraryInfo = provider(
    "Reusable XSLT library closure.",
    fields = ["stylesheet", "uri", "files", "catalog"],
)
XsltStageInfo = provider(
    "Executable XSLT stage declaration.",
    fields = [
        "label",
        "stylesheet",
        "files",
        "catalog",
        "capabilities",
        "output_mode",
    ],
)
XsltToolchainInfo = provider(
    "Processor adapter execution metadata.",
    fields = ["adapter", "capabilities"],
)
