---
name: run-ci
description: Runs the full CI pipeline defined in config/ci.rb. Use when the user asks to run CI, run the CI pipeline, run continuous integration checks, or verify the build before merging.
---

# Run CI

## Command

```bash
bin/ci
```

This runs the full pipeline defined in `config/ci.rb`:

1. **Setup** — `bin/setup --skip-server`
2. **Security: Gem audit** — `bin/bundler-audit`
3. **Security: Importmap vulnerability audit** — `bin/importmap audit`
4. **Security: Brakeman code analysis** — `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`
5. **Tests: Rails** — `bin/rails test`
6. **Tests: System** — `bin/rails test:system`
7. **Tests: Seeds** — `env RAILS_ENV=test bin/rails db:seed:replant`

Steps run sequentially. The pipeline stops on the first failure.

## Guidelines

- Use `block_until_ms: 0` to immediately background the command since the full pipeline takes several minutes.
- Monitor the terminal output by polling the terminal file. The CI runner logs each step with its name, so you can track progress.
- If a step fails, read the output to identify the failing step and its error, then report it to the user with actionable details.
- Individual steps can also be run standalone if the user only wants to check a specific part (e.g., `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error` for security analysis only).
