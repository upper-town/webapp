# Intro

This file provides guidance to AI agents when working with code in this repository.

## Project Overview

Upper Town is a Rails 8.1 web application for a gaming community, providing features for server voting, stats tracking, and admin management. Production site: https://upper.town

## Tech Stack

- Ruby 3.4.4, Rails 8.1.1
- PostgreSQL (primary database, plus separate databases for queue, cache, cable via Solid*)
- Hotwire (Turbo + Stimulus), ViewComponent, Bootstrap
- Propshaft (asset pipeline), importmap-rails (JS)
- SolidQueue (jobs), SolidCache (caching), SolidCable (WebSockets)
- Kamal (deployment), Puma + Thruster (web server)
- Minitest, Capybara, Selenium, WebMock, VCR (testing)

## Development Commands

```bash
bin/setup           # Initial setup (or --reset to reinitialize)
bin/dev             # Start all services (web, workers, mailcatcher via Overmind)
```

Requires `/etc/hosts` entry: `127.0.0.1 uppertown.test`

Environment variables in `.env` (dev) and `.env.test`. Override locally with `.env.local` or `.env.test.local`.

## Testing

```bash
bin/rails test                              # Run unit/integration tests
bin/rails test:system                       # Run browser tests (Capybara/Selenium)
bin/rails test test/path/to/specific_test.rb  # Run single test file
HEADFUL=true bin/rails test:system          # Run with visible browser
VCR_RECORD_ALL=true bin/rails test test/path  # Re-record HTTP cassettes
COVERAGE=true bin/rails test                # Generate coverage report
```

External HTTP requests are blocked in tests via WebMock. Use WebMock stubs or VCR cassettes for any external calls. Tests run in parallel by default (disabled when COVERAGE=true).

Test setup modules in `test/support/setup/` auto-clear jobs, cache, mailer deliveries, and `Current` attributes between tests.

## Linting & Security

```bash
bin/rubocop        # Code style check
bin/brakeman       # Security vulnerability scan
bin/bundler-audit  # Gem vulnerability audit
bin/ci             # Full CI pipeline (setup, audits, all tests)
```

## Architecture

### Layered Structure

- **Application layer**: Controllers handle HTTP requests, delegate to domain services
- **Domain layer**: Business logic in `app/concepts/` organized by concept
- **Presentation layer**: ERB views, ViewComponents in `app/components/`, helpers
- **Infrastructure layer**: ActiveRecord models, SolidQueue jobs, SolidCache, API clients

### Route Areas

The app has four distinct areas, each with its own base controller and layout:

| Area | Path | Base Controller | Purpose |
|------|------|-----------------|---------|
| Public | `/` | `ApplicationController` | Homepage, server listing, voting, profiles |
| Inside | `/i` | `Inside::BaseController` | Authenticated user dashboard, server CRUD |
| Admin | `/admin` | `Admin::BaseController` | Admin dashboard, user/server management |
| Demo | `/demo` | `Demo::BaseController` | Dev-only webhook testing (development env only) |

Auth routes live under `/users` and `/admin_users` for their respective sign-up/sign-in/password-reset flows.

### Domain Concepts (`app/concepts/`)

Business logic is organized by domain concept, not by technical layer:

```
app/concepts/
├── admin/              # Admin queries (ServersQuery, UsersQuery) and route constraints
├── admin_users/        # Admin user creation, auth, email confirmation, password resets
├── captcha.rb          # hCaptcha verification
├── demo/               # Dev-only constraint and webhook request handler
├── periods.rb          # Year/month/week time period utilities
├── servers/            # Server CRUD, verification, voting, archiving, stats consolidation
│   └── verify_accounts/  # JSON file-based account verification pipeline
├── users/              # User creation, auth, email confirmation, password resets, email changes
│   ├── change_email_confirmations/
│   ├── change_email_reversions/
│   ├── email_confirmations/
│   └── password_resets/
└── webhooks/           # Event creation, batching, HMAC-signed delivery, cleanup
    └── data/           # Webhook event payload builders
```

### Key Patterns

**Services** — Verb-named classes in `app/concepts/`. Include the `Callable` module to enable `MyService.call(args)` class method syntax. The `Callable` module delegates `.call(...)` to `new(...).call`:

```ruby
module Users
  class Create
    include Callable

    def initialize(email)
      @email = email
    end

    def call
      # business logic, returns Result
    end
  end
end

# Usage:
Users::Create.call("user@example.com")
```

**Result objects** — Services return `Result` or a custom `ApplicationResult` subclass. Define custom Result classes nested inside the service when you need specific attributes:

```ruby
class Result < ApplicationResult
  attribute :user
end

# Success:
Result.success(user: user)

# Failure from model errors:
Result.failure(user.errors)

# Failure with field + type:
Result.failure(:email, :invalid)

# Failure with string message:
Result.failure("Something went wrong")

# Check:
result.success?  # true if no errors
result.failure?  # true if any errors
result.add_error(:field, :type)  # add more errors
```

**Queries** — `*Query` suffix classes in `app/concepts/` or `app/queries/`. Include `Callable`. Return `ActiveRecord::Relation` or primitive values. Used for complex read operations.

**Policies** — `*Policy` suffix with `allowed?` method. Check authorization rules:

```ruby
Admin::AccessPolicy.new(admin_account, permission_key).allowed?
```

**Validators** — Two-tier pattern in `app/validators/`:
- `Validate*` classes (e.g., `ValidateEmail`) contain the actual validation logic
- `*Validator` classes (e.g., `EmailValidator`) are ActiveModel validators that delegate to the `Validate*` class

**Normalizers** — `app/normalizers/` for data transformation. Include `Callable`. Used in models via: `normalizes :email, with: NormalizeEmail`

### Models

**`ApplicationRecord`** — Base for all ActiveRecord models. Uses `record_type` as the inheritance column (not the default `type`). Provides `move_errors(from, to)` helper.

**`ApplicationModel`** — Base for non-database models (form objects, Result classes). Includes `ActiveModel::Model`, `ActiveModel::Attributes`, `ActiveModel::Serializers::JSON`, number helpers, and URL helpers. Custom equality based on attributes or id.

**Key model groups:**

- **User auth**: `User` → `Account`, `Session`, `Token`, `Code` (with concerns: `HasPassword`, `HasEmailConfirmation`, `HasChangeEmailConfirmation`, `HasTokens`, `HasCodes`, `HasLock`, `FeatureFlagId`)
- **Admin auth**: `AdminUser` → `AdminAccount`, `AdminSession`, `AdminToken`, `AdminCode` (with RBAC via `AdminRole`, `AdminPermission`, `AdminAccountRole`, `AdminRolePermission`)
- **Gaming**: `Game` → `Server` (with Active Storage banner images, verification, archiving), `ServerVote`, `ServerStat`, `ServerAccount`
- **Webhooks**: `WebhookConfig` (polymorphic source, encrypted secret) → `WebhookEvent`, `WebhookBatch`
- **Infrastructure**: `FeatureFlag` (with env var overrides via `FF_` prefix)

**Form objects** live in `app/models/` under their namespace (e.g., `Users::Session`, `Users::PasswordReset`). They inherit from `ApplicationModel` and use conditional validations based on an `action` attribute.

### Controllers

**Base controllers:**
- `ApplicationController` (`ActionController::Base`) — public/user web controllers
- `ApplicationAdminController` (`ActionController::Base`) — admin web controllers
- `ApplicationApiController` (`ActionController::API`) — JSON API controllers
- `ApplicationApiAdminController` (`ActionController::API`) — admin API controllers

**Auth concerns** in `app/controllers/concerns/auth/` handle authentication, authorization, and session management for each area (user, admin, API, admin API).

**Other concerns**: `AddFlashTypes`, `ManageCaptcha`, `ManageRateLimit`, `JsonCookie`.

### ViewComponents

Components inherit from `ApplicationComponent < ViewComponent::Base` and live in `app/components/`. Key components: `AlertComponent`, `PaginationComponent`, `PaginationCursorComponent`, select components (game, country, period), `Servers::IndexResultComponent`, `Admin::TableComponent`.

### Background Jobs

- `ApplicationJob` — Base class with SolidQueue. Retries on `StandardError` with polynomial backoff (25 attempts). Queue: `default`.
- `ApplicationPollingJob` — Base for recurring/polling jobs (no automatic retries).
- Domain jobs live alongside their concept (e.g., `Servers::VerifyJob`, `Webhooks::PublishBatchJob`).

### Request Context

`Current` (`app/values/current.rb`) provides request-scoped attributes via `ActiveSupport::CurrentAttributes`:
- `Current.user`, `Current.account`, `Current.session` — user context
- `Current.admin_user`, `Current.admin_account`, `Current.admin_session` — admin context
- `Current.api_session`, `Current.admin_api_session` — API context

## Database

Multi-database PostgreSQL setup: primary, queue, cache, cable. Each has its own migrations directory (`db/migrate`, `db/queue_migrate`, `db/cache_migrate`, `db/cable_migrate`). Tests use a single database.

Active Record encryption enabled for sensitive fields (e.g., `encrypts :secret` on `WebhookConfig`). Uses `timestamptz` for all datetime columns.

**Key patterns:**
- Token security: HMAC-SHA256 digest + last 4 chars stored for lookups (uses `TOKEN_SALT` env var)
- UUIDs: UUIDv7 for `accounts.uuid` and `server_votes.uuid`
- JSONB: Flexible data storage on `tokens.data`, `codes.data`, `webhook_events.data`, `servers.metadata`, etc.
- Soft deletes: Timestamp columns (`archived_at`, `marked_for_deletion_at`, `disabled_at`)

## Test Factories

Factories in `test/support/factories/` define minimum-valid records using `ApplicationRecordTestFactoryHelper.define`. Each factory creates `build_<name>` and `create_<name>` helpers available in all test cases:

```ruby
# Factory definition:
ApplicationRecordTestFactoryHelper.define(:user, User,
  email: -> { "user_#{SecureRandom.base58}@upper.town" },
  password: -> { "testpass" }
)

# Usage in tests:
user = create_user                           # with defaults
user = create_user(email: "custom@test.com") # with override
server = build_server                        # unsaved instance
```

Factories can reference other factories in their defaults (e.g., `game: -> { build_game }`).

## Test Support

- `test/support/setup/` — Auto-included modules that reset state between tests (jobs, cache, `Current`, mailer deliveries)
- `test/support/helpers/` — Test helpers (`RequestTestHelper`, `EnvTestHelper`, `RailsEnvTestHelper`)
- `test/support/config/` — WebMock and VCR configuration
- `test/support/extensions/` — Minitest extensions (e.g., `stub_any_instance`)

## Key Environment Variables

- `TOKEN_SALT` — Salt for HMAC token generation
- `APP_PORT` — Application port
- `POSTGRES_*` — Database connection settings
- `FF_*` — Feature flag overrides (e.g., `FF_MY_FLAG=enabled`)
- `HCAPTCHA_SITE_KEY`, `HCAPTCHA_SECRET_KEY` — hCaptcha credentials
