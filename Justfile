flags := ""

# Query every target in this Bazel module.
query:
  bazel query {{flags}} //...

# Build every target in this Bazel module.
build:
  bazel build {{flags}} //...

# Test every target in this Bazel module.
test:
  #!/usr/bin/env bash
  bazel test {{flags}} //... || test $? -eq 4

# Check BUILD and Starlark formatting and lint findings.
lint:
  buildifier -mode=check -lint=warn -r .

# Run query, build, test, and lint for this module.
check: query build test lint
