---
name: run-tests
description: Runs the project test suite using Rails Minitest. Use when the user asks to run tests, run the test suite, run a specific test file, or run a specific test case.
---

# Run Tests

## Commands

**Full test suite** (unit + integration):

```bash
bin/rails test
```

**System tests** (browser tests via Capybara/Selenium):

```bash
bin/rails test:system
```

**Both suites:**

```bash
bin/rails test && bin/rails test:system
```

**Single test file:**

```bash
bin/rails test test/path/to/file_test.rb
```

**Specific test by line number:**

```bash
bin/rails test test/path/to/file_test.rb:42
```

## Useful flags

| Flag | Purpose |
|------|---------|
| `HEADFUL=true` | Show browser window for system tests |
| `VCR_RECORD_ALL=true` | Re-record VCR HTTP cassettes |
| `COVERAGE=true` | Generate test coverage report |

Example combining flags:

```bash
VCR_RECORD_ALL=true bin/rails test test/concepts/servers/sync_test.rb
```

## Guidelines

- When the user asks to run tests for code you just changed, identify the corresponding test file(s) and run those specifically rather than the full suite.
- Test files live under `test/` and mirror the app structure (e.g., `app/concepts/users/create.rb` → `test/concepts/users/create_test.rb`).
- If a test fails, read the failure output carefully, inspect the relevant source and test code, then fix the issue.
- When running the full suite, use `block_until_ms: 120000` or higher since it can take a while.
- When running a single test file, `block_until_ms: 60000` is usually sufficient.
