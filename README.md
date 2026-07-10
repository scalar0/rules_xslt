# xslt

Shared low-level XSLT helpers used by transform packages.

## Helper boundaries

- `xml_utils/LIB_FLAT_ROWS.xslt`: generic row field access (`f:field`, `f:first-non-empty`).
- `wordprocessingml/LIB_WORDML_STYLES.xslt`: style-map loading/lookup and style emitters (`EmitParagraphStyle`, `EmitRunFormatting`, table/cell style helpers).
- `wordprocessingml/LIB_WORDML_TEXT.xslt`: plain text/run/line-break and paragraph helpers.
- `wordprocessingml/LIB_WORDML_CONTENT_CONTROLS.xslt`: generic content-control ID/tag/alias and repeating-row wrappers.
- `wordprocessingml/LIB_WORDML_TABLES.xslt`: generic table properties, static header helpers, and checkbox cell primitive.
- `wordprocessingml/LIB_WORDML_DOCUMENT.xslt`: `EmitWordDocument` wrapper for `w:document` / `w:body` shell.
- `wordprocessingml/MERGE_TO_TEMPLATE.xslt`: reusable merge transform that appends generated WordML content into a template `word/document.xml`.
- `contract/defs.bzl`, `contract/providers.bzl`: shared Starlark provider/rule contract (`XsltTransformInfo`, `xslt_transform_def`).
- `xml_utils/LIB_SPLIT_XML.xslt`: generic array-item fanout transform contract (`@xslt//xml_utils:transform`).

## Dependency notes

- `wordprocessingml/LIB_WORDML_STYLES.xslt` expects a style-map XML via `StyleMapUri` (defaults to `../../djd_workbook_to_wordml/WORD_STYLE_MAP.xml`). Concrete style keys stay in the consuming package.
- `wordprocessingml/LIB_WORDML_TEXT.xslt` calls `RenderSegmentContent` and `EmitBodyParagraphProperties`; consumers provide domain-specific segment behavior and paragraph style context.
- `wordprocessingml/LIB_WORDML_TABLES.xslt` relies on style/content-control templates provided by the style/content-control helpers.

## Non-goals

This package does **not** define:

- workbook/SSS/requirement/evidence/reference/compliance semantics
- section layout, heading text, or column definitions
- control-ID allocation policies
- descriptor/config-driven rendering models

## Guidance for future transforms (without descriptor/config)

- Keep transform entrypoints and domain mapping/layout logic in the document-specific package.
- Include only the common helper libraries needed for boilerplate WordML/row primitives.
- Keep style maps, style keys, token parsing, and domain rules local.
- Prefer explicit templates over a generic descriptor/config layer.
