# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Upper Town is a Rails 8.1 web application for a gaming community, providing features for server voting, stats tracking, and admin management. Production site: https://upper.town

## Tech Stack

- Ruby 3.4.4, Rails 8.1.1
- PostgreSQL (primary database, cache, queue, rate limiting via Solid*)
- Hotwire (Turbo + Stimulus), ViewComponent, Bootstrap
- SolidQueue (jobs), SolidCache (caching), SolidCable (WebSockets)
- Minitest for testing

## Development Commands

```bash
bin/setup                    # Initial setup (or --reset to reinitialize)
bin/dev                      # Start all services (web, workers, mailcatcher)
```

## Testing

```bash
bin/rails test               # Run unit/integration tests
bin/rails test:system        # Run browser tests (Capybara/Selenium)
bin/rails test test/path/to/specific_test.rb  # Run single test file
HEADFUL=true bin/rails test:system            # Run with visible browser
VCR_RECORD_ALL=true bin/rails test test/path  # Re-record HTTP cassettes
COVERAGE=true bin/rails test                  # Generate coverage report
```

External HTTP requests are blocked in tests. Use WebMock to stub requests or VCR to record/replay them. Test setup modules in `test/support/setup/` auto-clear jobs, cache, and Current attributes between tests.

## Linting & Security

```bash
bin/rubocop                  # Code style check
bin/brakeman                 # Security vulnerability scan
bin/bundler-audit            # Gem vulnerability audit
bin/ci                       # Full CI pipeline (setup, audits, all tests)
```

## Architecture

**Layered structure:**

- **Application layer**: Controllers handle request/response, delegate to domain
- **Domain layer**: Business logic in `app/concepts/` organized by concept (users, servers, webhooks, etc.)
- **Presentation layer**: Views, ViewComponents in `app/components/`, Helpers
- **Infrastructure layer**: ActiveRecord, SolidQueue jobs, SolidCache, API clients

**Key patterns:**

- **Services**: Verb-named classes in `app/services/` or `app/concepts/`. Include `Callable` module to enable `MyService.call(args)` class method syntax. Return `true`/`false` or `Result` object.

- **Result objects**: `Result.success(data: value)` or `Result.failure()`. Check with `result.success?` / `result.failure?`. Add errors via `result.add_error(:field, "message")`. You can define your specific `Result` class by inheriting from `ApplicationResult` and defining the attributes.

- **Queries**: `*Query` suffix, return ActiveRecord::Relation or primitives

- **Policies**: `*Policy` suffix with `allowed?` methods

- **Validators**: `*Validator` suffix in `app/validators/` (email, phone, URL, JSON schema)

- **Normalizers**: `app/normalizers/` for data transformation. Usage in models: `normalizes :email, with: NormalizeEmail`

**Domain organization**: Related concepts grouped in `app/concepts/[concept]/` with namespaced modules.
```
app/concepts/users/
├── create.rb                    # Users::Create service
├── email_confirmations/
│   ├── create.rb               # Users::EmailConfirmations::Create
│   └── email_job.rb            # Users::EmailConfirmations::EmailJob
└── password_resets/
    └── create.rb               # Users::PasswordResets::Create
```

**Model base classes:**
- `ApplicationRecord` - standard ActiveRecord models (database-backed)
- `ApplicationModel` - non-database models using ActiveModel (for form objects, Result objects)

## Request Context

`Current` (in `app/values/current.rb`) provides request-scoped attributes via `ActiveSupport::CurrentAttributes`:
- `Current.user`, `Current.account`, `Current.session` - user context
- `Current.admin_user`, `Current.admin_account`, `Current.admin_session` - admin context
- `Current.api_session`, `Current.admin_api_session` - API context

## Controllers

**Web controllers** inherit from `ApplicationController < ActionController::Base`.

**API controllers** inherit from `ApplicationApiController < ActionController::API` (for JSON APIs under `/api/` namespace).

**Auth concerns** in `app/controllers/concerns/auth/`:
- `AuthenticationControl`, `AuthorizationControl` - user auth
- `AdminAuthenticationControl`, `AdminAuthorizationControl` - admin auth
- `ApiAuthenticationControl`, `ApiAuthorizationControl` - API auth
- `ManageSession`, `ManageAdminSession` - session management

## Database

Multi-database PostgreSQL setup: primary, queue, cache, cable (separate databases for SolidQueue, SolidCache, SolidCable). Each has its own migrations directory (`db/migrate`, `db/queue_migrate`, etc.). Tests use a single database.

Active Record encryption enabled for sensitive fields (e.g., `encrypts :secret`). Uses `timestamptz` for all datetime columns (UTC).

## Security Patterns

**Token generation**: `TokenGenerator` creates secure tokens, stores HMAC-SHA256 digest + last 4 chars for lookups (uses `TOKEN_SALT` env var).

## Test Factories

Factories in `test/support/factories/` represent minimum-valid records. Factory helpers like `create_user`, `create_server` are available in all test cases.

## Local Development

Requires `/etc/hosts` entry: `127.0.0.1 uppertown.test`

Environment variables in `.env` (dev) and `.env.test`. Override locally with `.env.local` or `.env.test.local`.

Key env vars: `TOKEN_SALT`, `APP_PORT`, `POSTGRES_*`
