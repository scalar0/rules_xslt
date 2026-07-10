# xslt contract

Shared Bazel Starlark contract embedded in the `@xslt` module for XML/XSLT transform modules.

This package owns:

- `XsltTransformInfo` provider
- `xslt_transform_def(...)` rule

It does not execute transforms. Consumer modules compose this metadata with their own execution rules.
