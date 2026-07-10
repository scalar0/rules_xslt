"""Generic XML/XSLT provider contracts shared by transform modules."""

XsltTransformInfo = provider(
    doc = "Metadata for a module-scoped XML/XSLT transform role; actions are created by consumers.",
    fields = {
        "input_schema": "Primary input XSD file.",
        "input_schema_deps": "Depset of input schema include/import files.",
        "stylesheet": "Primary XSLT stylesheet.",
        "deps": "Depset of XSLT include/import files.",
        "resources": "Depset of transform resource files.",
        "output_schema": "Primary output XSD file.",
        "output_schema_deps": "Depset of output schema include/import files.",
        "default_params": "String dictionary of default XSLT parameters.",
        "required_params": "Tuple/list of parameter names required from consumers.",
        "output_kind": "Semantic output kind, e.g. workbooks, workbook, wordprocessingml.",
    },
)
