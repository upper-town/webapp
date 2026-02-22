# Intro

This file provides guidance to AI agents when working with code in this repository. When adding new features, follow existing patterns: place business logic in `app/concepts/` under the appropriate domain, use `Callable` for services/queries, return `ApplicationResult` from services, use form objects for user input and pass them (not splatted attributes) to services, and add tests in `test/concepts/` mirroring the concept structure.

## Project Overview

Upper Town is a Rails 8.1 web application for a gaming community, providing features for server voting, stats tracking, and admin management. Production site: https://upper.town

## Tech Stack

- Ruby 3.4.4, Rails 8.1.1
- PostgreSQL (primary database, plus separate databases for queue, cache, cable via Solid*)
- Hotwire (Turbo + Stimulus), ViewComponent, Bootstrap, Bootstrap Icons
- Propshaft (asset pipeline), importmap-rails (JS)

**Bootstrap & Bootstrap Icons**: Bootstrap (CSS, JS) and Bootstrap Icons are available in the codebase via `app/assets/stylesheets/` and `vendor/javascript/`. Default to Bootstrap components and Bootstrap Icons (`<i class="bi bi-*"></i>`) when possible—no external imports needed.

**JavaScript**: Inline JavaScript in HTML (e.g. `onclick`, `href="javascript:..."`) does not work—security checks block it. Put all JavaScript in separate files under `app/javascript/` (e.g. Stimulus controllers in `app/javascript/controllers/`).

- SolidQueue (jobs), SolidCache (caching), SolidCable (WebSockets)
- Kamal (deployment), Puma + Thruster (web server)
- Minitest, Capybara, Selenium, WebMock, VCR (testing)

## Development Commands

```bash
bin/setup           # Initial setup (or --reset to reinitialize)
bin/dev             # Start all services (web, workers, mailcatcher via Overmind)
```

`bin/dev` runs `Procfile.dev`: web (Rails server), workers (SolidQueue), mailcatcher.

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
bin/ci             # Full CI pipeline (see config/ci.rb)
```

**CI pipeline** (`bin/ci`): setup, bundler-audit, importmap audit, Brakeman, `bin/rails test`, `bin/rails test:system`, `db:seed:replant` (test env).

## Key File Locations

| Purpose | Path |
|---------|------|
| Callable module | `app/services/callable.rb` |
| ApplicationResult | `app/services/application_result.rb` |
| AppUtil (env helpers, webapp_host) | `app/lib/app_util.rb` |
| Current (request context) | `app/values/current.rb` |
| Locales (i18n) | `config/locales/` |
| Recurring job schedules | `config/recurring.yml` |
| CI pipeline definition | `config/ci.rb` |

## Locales

The app uses Rails i18n with locale files in `config/locales/`. Use `t("key")` in views and `I18n.t("key")` elsewhere for user-facing strings instead of hardcoding text.

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

Auth routes live under `/users` and `/admin_users` for their respective sign-up/sign-in/password-reset flows. Public account profiles at `/u/:id`. Mission Control Jobs UI at `/admin/jobs` (requires `Admin::JobsConstraint`).

### Domain Concepts (`app/concepts/`)

Business logic is organized by domain concept, not by technical layer:

```
app/concepts/
├── admin/              # Admin queries, update/create services, dashboard_stats, route constraints
│   └── queries/        # Domain-specific admin queries
├── admin_users/        # Admin user creation, auth, email confirmation, password resets
├── captcha.rb          # hCaptcha verification
├── demo/               # Dev-only constraint and webhook request handler
│   └── webhook_events/ # Demo webhook event creation
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

**Services** — Verb-named classes in `app/concepts/`. Include the `Callable` module to enable `MyService.call(args)` class method syntax. The `Callable` module delegates `.call(...)` to `new(...).call`.

**Service arguments** — Use positional arguments for the primary/required inputs and keyword arguments for extra context or optional parameters. Form is always positional when present (it is important enough to not be just a keyword arg). Apply this pattern mindfully:

- **Single primary input**: `def initialize(email)` → `Users::Create.call("user@example.com")`
- **Record + form (update)**: `def initialize(server, form)` → `Servers::Update.call(@server, @form)`
- **Form + context (create)**: `def initialize(form, account:)` → `Servers::Create.call(@form, account: current_account)`
- **Form + request context**: `def initialize(form, server_id:, remote_ip:, account_id: nil)` → `Servers::CreateVote.call(@form, server_id: ..., remote_ip: ..., account_id: ...)`
- **Optional filters only** (e.g. queries): all keyword args is fine when there is no single primary input

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

**Queries** — `*Query` suffix classes in `app/concepts/` (domain-specific) or `app/queries/` (shared, e.g., `CountrySelectOptionsQuery`, `GameSelectOptionsQuery`). Include `Callable`. Return `ActiveRecord::Relation` or primitive values. Used for complex read operations.

**Policies** — `*Policy` suffix with `allowed?` method. Live in `app/policies/` (e.g., `Admin::AccessPolicy`, `ServerBannerImagePolicy`). Check authorization rules:

```ruby
Admin::AccessPolicy.new(admin_account, permission_key).allowed?
```

**Validators** — Two-tier pattern in `app/validators/`:
- `Validate*` classes (e.g., `ValidateEmail`) contain the actual validation logic
- `*Validator` classes (e.g., `EmailValidator`) are ActiveModel validators that delegate to the `Validate*` class

**Normalizers** — `app/normalizers/` for data transformation. Include `Callable`. Used in models via: `normalizes :email, with: NormalizeEmail`

**Controller–Service–Form flow** — Controllers do not call models directly to save, update, or destroy. Instead:

1. **Collect input**: Build a form object from params (e.g. `Servers::CreateForm.new(server_form_params)`).
2. **Validate form**: If `form.invalid?`, render the form with errors and return.
3. **Call service**: Pass the **form object** to the service (not splatted attributes), plus any request context (e.g. `account:`, `server_id:`, `remote_ip:`).
4. **Handle result**: On success, redirect. On failure, merge service errors into the form and re-render.

```ruby
# Controller — pass form object, not attributes
def create
  @form = Servers::CreateForm.new(server_form_params)

  if @form.invalid?
    render(:new, status: :unprocessable_entity)
    return
  end

  result = Servers::Create.call(@form, account: current_account)

  if result.success?
    redirect_to(inside_servers_path, success: "...")
  else
    @form.errors.merge!(result.errors)
    flash.now[:alert] = result.errors
    render(:new, status: :unprocessable_entity)
  end
end

# Service — form positional, context as keyword
def initialize(form, account:)
  @form = form
  @account = account
end

def call
  server = Server.new(form.server_attributes)
  # ...
end
```

**Exception**: Calling methods on ActiveRecord instances returned from a service result (e.g. `result.user.generate_token!`) is acceptable. Auth session management (ManageSession, etc.) may create/destroy sessions directly.

### Models

**`ApplicationRecord`** — Base for all ActiveRecord models. Uses `record_type` as the inheritance column (not the default `type`). Provides `move_errors(from, to)` helper.

**`ApplicationModel`** — Base for non-database models (form objects, Result classes). Includes `ActiveModel::Model`, `ActiveModel::Attributes`, `ActiveModel::Serializers::JSON`, number helpers, and URL helpers. Custom equality based on attributes or id.

**Key model groups:**

- **User auth**: `User` → `Account`, `Session`, `Token`, `Code` (with concerns: `HasPassword`, `HasEmailConfirmation`, `HasChangeEmailConfirmation`, `HasTokens`, `HasCodes`, `HasLock`, `FeatureFlagId`)
- **Admin auth**: `AdminUser` → `AdminAccount`, `AdminSession`, `AdminToken`, `AdminCode` (with RBAC via `AdminRole`, `AdminPermission`, `AdminAccountRole`, `AdminRolePermission`)
- **Gaming**: `Game` → `Server` (with Active Storage banner images, verification, archiving), `ServerVote`, `ServerStat`, `ServerAccount`
- **Webhooks**: `WebhookConfig` (polymorphic source, encrypted secret) → `WebhookEvent`, `WebhookBatch`
- **Infrastructure**: `FeatureFlag` (with env var overrides via `FF_` prefix)

**Form objects** — Live in `app/models/` under their domain namespace (e.g. `Users::SessionForm`, `Servers::CreateForm`, `Servers::VoteForm`). They:

- Inherit from `ApplicationModel` (ActiveModel::Model + ActiveModel::Attributes)
- Use `attribute` for fields; validate with `validates` and custom `validate` callbacks
- Define `model_name` (via `self.model_name`) when the form should bind to a different param key (e.g. `Servers::CreateForm` → `server` params for `form_with model: @form`)
- Expose extracted data to services via methods (e.g. `server_attributes`, `reference`)
- Are passed as a whole to services — controllers never splat form attributes into service calls

Use form objects for any user input that drives a create/update flow. Forms validate before the service runs; the service may perform additional validation and return errors to merge into the form.

### Controllers

**Base controllers:**
- `ApplicationController` (`ActionController::Base`) — public/user web controllers; `Inside::BaseController` extends it with `authenticate_user!`
- `ApplicationAdminController` (`ActionController::Base`) — admin web controllers; `Admin::BaseController` extends it
- `ApplicationApiController` (`ActionController::API`) — JSON API (e.g., demo webhooks at `POST /demo/webhook_events`)
- `ApplicationApiAdminController` (`ActionController::API`) — admin API controllers

**Auth concerns** in `app/controllers/concerns/auth/` handle authentication, authorization, and session management for each area (user, admin, API, admin API).

**Other concerns**: `AddFlashTypes`, `ManageCaptcha`, `ManageRateLimit`, `JsonCookie`.

### ViewComponents

Components inherit from `ApplicationComponent < ViewComponent::Base` and live in `app/components/`. Key components: `AlertComponent`, `FlashItemComponent`, `PaginationComponent`, `PaginationCursorComponent`, select components (`GameSelectComponent`, `CountrySelectComponent`, `PeriodSelectComponent`), `Servers::IndexResultComponent`, `Admin::TableComponent`, `Admin::DetailsTableComponent`, `Admin::SearchFormComponent`, `Admin::ServerStatusBadgesComponent`, `Admin::IndexActionsComponent`, `Admin::ShowActionsComponent`.

Define `attr_reader` for instance variables and use the reader methods in templates (e.g. `url` instead of `@url`). Usually add parentheses around method calls with arguments; omit them only when it makes sense.

### Background Jobs

- `ApplicationJob` — Base class with SolidQueue. Retries on `StandardError` with polynomial backoff (25 attempts). Queue: `default`.
- `ApplicationPollingJob` — Base for recurring/polling jobs (no automatic retries).
- Domain jobs live alongside their concept (e.g., `Servers::VerifyJob`, `Webhooks::PublishBatchJob`).
- Recurring schedules defined in `config/recurring.yml` (stats consolidation, verification, cleanup, etc.).

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

Factory files are named `*_test_factory.rb` (e.g., `user_test_factory.rb`). The first argument to `define` is the symbol used for `create_<name>` and `build_<name>`.

## Seeds

`db/seeds.rb` loads `db/seeds/runner.rb`, which runs modular seed files in `db/seeds/` (e.g., `create_admin_users.rb`, `create_users.rb`, `create_games.rb`). Seed modules use the same `Callable` pattern as concepts.

## Test Structure

- `test/concepts/` — Mirrors `app/concepts/` (e.g., `test/concepts/servers/create_test.rb`)
- `test/models/`, `test/requests/`, `test/system/` — Standard Rails test locations
- `test/support/setup/` — Auto-included modules that reset state between tests (jobs, cache, `Current`, mailer deliveries)
- `test/support/helpers/` — Test helpers (`RequestTestHelper`, `EnvTestHelper`, `RailsEnvTestHelper`)
- `test/support/config/` — WebMock and VCR configuration
- `test/support/extensions/` — Minitest extensions (e.g., `stub_any_instance`)

## Key Environment Variables

**Required for app boot** (except during `assets:precompile` when `SECRET_KEY_BASE_DUMMY` is set):
- `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`, `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY`, `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT` — Active Record encryption

**Common:**
- `TOKEN_SALT` — Salt for HMAC token generation
- `APP_HOST`, `APP_PORT` — Host and port (via `AppUtil.webapp_host`, `AppUtil.webapp_port`)
- `POSTGRES_*` — Database connection settings
- `FF_*` — Feature flag overrides (e.g., `FF_MY_FLAG=enabled`)
- `HCAPTCHA_SITE_KEY`, `HCAPTCHA_SECRET_KEY` — hCaptcha credentials
