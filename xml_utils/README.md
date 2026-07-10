# xml_utils

Transform contract module for splitting any XML array root (`/*/*`) into
multiple item files in one Saxon action.

Entrypoints exposed from this module root package:

- `INPUT.xsd`
- `LIB_SPLIT_XML.xslt`
- `OUTPUT.xsd`
- `:input_schema_deps`
- `:output_schema_deps`
- `:libxslt`
- `:resources`
- module transform contract via `xslt_transform_def(name = "transform", ...)`

Contract parameters:

- `itemIds` (required): comma-separated IDs to extract
- `idElement` (default: `id`): child element name containing each item ID
- `itemElement` (default: empty): optional item element local-name under root
- `outFileSuffix` (default: `.xml`): output filename suffix appended to each ID

Consumers should pass `transform = "@xslt//xml_utils:transform"` to
`xslt_transform_multi(...)` in a Saxon-backed execution toolchain.
