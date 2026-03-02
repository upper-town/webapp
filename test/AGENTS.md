# Test Directory Guide

This file provides guidance to AI agents when working with tests in this repository. See the project root `AGENTS.md` for general architecture and patterns.

## Overview

The test suite uses **Minitest** with spec-style `describe`/`it` blocks, **Capybara** for system tests, **WebMock** for HTTP stubbing, and **VCR** (optional) for recording HTTP interactions. Tests run in parallel by default.

**Data setup**: Prefer explicit setup in each test case. Use `let`, `before`, `around` sparingly—only for small shared setup (e.g. `described_class`).

## Commands

```bash
bin/rails test                              # Run unit/integration tests
bin/rails test:system                       # Run browser tests (Capybara/Selenium)
bin/rails test test/path/to/specific_test.rb # Run single test file
HEADFUL=true bin/rails test:system          # Run with visible browser
VCR_RECORD_ALL=true bin/rails test test/path # Re-record HTTP cassettes
COVERAGE=true bin/rails test                # Generate coverage (disables parallel)
```

## Directory Structure

| Directory | Purpose | Base Class |
|-----------|---------|------------|
| `test/concepts/` | Domain logic (services, queries, jobs) | `ActiveSupport::TestCase` |
| `test/models/` | Model behavior, validators, form objects | `ActiveSupport::TestCase` |
| `test/requests/` | HTTP request/response (integration) | `ActionDispatch::IntegrationTest` |
| `test/system/` | Browser-driven end-to-end tests | `ApplicationSystemTestCase` |
| `test/components/` | ViewComponent rendering | `ViewComponent::TestCase` |
| `test/controllers/` | Controller concerns | `ActiveSupport::TestCase` |
| `test/helpers/` | Helper methods | `ActiveSupport::TestCase` |
| `test/mailers/` | Mailer delivery | `ActionMailer::TestCase` |
| `test/jobs/` | Job behavior | `ActiveSupport::TestCase` |
| `test/policies/` | Policy authorization | `ActiveSupport::TestCase` |
| `test/services/` | Shared services | `ActiveSupport::TestCase` |
| `test/queries/` | Shared queries | `ActiveSupport::TestCase` |
| `test/validators/` | Validator logic | `ActiveSupport::TestCase` |
| `test/normalizers/` | Normalizer logic | `ActiveSupport::TestCase` |
| `test/lib/` | App library code | `ActiveSupport::TestCase` |

**Concepts tests** mirror `app/concepts/` structure (e.g., `test/concepts/servers/create_test.rb` for `Servers::Create`).

## Test Support Layout

| Path | Purpose |
|------|---------|
| `test/support/setup/` | Auto-included modules that reset state between tests |
| `test/support/helpers/` | Test helpers (`ApplicationRecordTestFactoryHelper`, `RequestTestHelper`, `EnvTestHelper`, `RailsEnvTestHelper`) |
| `test/support/config/` | WebMock, VCR configuration |
| `test/support/factories/` | Factory definitions |
| `test/support/extensions/` | Minitest extensions (e.g., `stub_any_instance`) |

## Auto-Included Setup

Every test gets these setup modules (from `test_helper.rb`):

- **ActiveJobTestSetup** — Clears enqueued and performed jobs
- **CacheTestSetup** — Clears `Rails.cache`
- **CurrentTestSetup** — Resets `Current` attributes
- **MailerTestSetup** — Clears `ActionMailer::Base.deliveries`

Integration tests also get **RequestTestSetup** (sets `host!`). System tests get **CapybaraTestSetup** (driver, app_host).

## Factories

Use `ApplicationRecordTestFactoryHelper` factories. No fixtures are used. Concept tests often define `*_attributes` helper methods (e.g. `server_attributes`) locally for building form params.

```ruby
# Create persisted record
user = create_user
user = create_user(email: "custom@upper.town", password: "secret")

# Build unsaved record
server = build_server

# Factories can reference other factories
server = create_server  # builds game via game: -> { build_game }
```

Factory files: `test/support/factories/*_test_factory.rb`. Define with:

```ruby
ApplicationRecordTestFactoryHelper.define(:user, User,
  email: -> { "user_#{SecureRandom.base58}@upper.town" },
  password: -> { "testpass" }
)
```

## Common Patterns

### Concept Tests

Mirror `app/concepts/` structure. Set up data explicitly in each `it` block:

```ruby
class Servers::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Servers::Create }

  describe "#call" do
    describe "when form is invalid" do
      it "returns failure and does not create server" do
        form = Servers::CreateForm.new(server_attributes(name: ""))
        result = described_class.call(form, account: create_account)

        assert(result.failure?)
        assert_nil(result.server)
        assert(result.errors.key?(:name))
      end
    end

    describe "when form is valid" do
      it "creates server and returns success" do
        form = Servers::CreateForm.new(server_attributes)
        result = nil

        assert_difference(-> { Server.count }, 1) do
          result = described_class.call(form, account: create_account)
        end

        assert(result.success?)
        assert_equal(Server.last, result.server)
      end
    end
  end
end
```

### Time-Sensitive Tests

Use `freeze_time` from ActiveSupport:

```ruby
freeze_time do
  user = create_user
  # Time.current is frozen; use travel, etc. as needed
end
```

### Stubbing

Do not use `Minitest::Mock.new`. Prefer `.stub` (and `stub_any_instance` for instance methods).

**Instance methods** — Use `stub_any_instance` (from `test/support/extensions/`):

```ruby
Server.stub_any_instance(:save!, -> { raise ActiveRecord::ActiveRecordError }) do
  result = described_class.call(form, account:)
  # ...
end
```

**HTTP requests** — Use WebMock (external HTTP is blocked by default):

```ruby
stub_request(:post, "https://hcaptcha.com/siteverify")
  .with(body: hash_including("response" => "token"))
  .to_return(status: 200, body: { "success" => true }.to_json)

result = Captcha.call(request)
assert_requested(:post, "https://hcaptcha.com/siteverify")
```

### Environment Variables

Use `EnvTestHelper` to isolate env changes:

```ruby
env_with_values("DEMO_WEBHOOK_SECRET" => "secret") do
  # test code that reads ENV["DEMO_WEBHOOK_SECRET"]
end
```

### Request Objects

Use `RequestTestHelper#build_request` for controller-like requests:

```ruby
request = build_request(
  method: "POST",
  url: "http://example.com/",
  params: { "h-captcha-response" => "token" },
  remote_ip: "8.8.8.8"
)
```

### Integration Tests

Use `request_headers` for realistic User-Agent. Set host via `RequestTestSetup` (automatic for `ActionDispatch::IntegrationTest`):

```ruby
post(users_sessions_url, headers: request_headers, params: { users_session_form: { ... } })
assert_redirected_to(inside_dashboard_url)
```

### System Tests

Use Capybara matchers. `ApplicationSystemTestCase` uses Selenium (headless by default; `HEADFUL=true` for visible browser):

```ruby
visit(servers_path)
assert_text("No results")
assert_selector("span.badge.bg-success", text: "Verified")
```

### Component Tests

Use ViewComponent's `render_inline` and matchers:

```ruby
render_inline(Admin::ServerStatusBadgesComponent.new(server:))
assert_selector("span.badge.bg-success", text: "Verified")
```

## HTTP and VCR

- **WebMock** blocks all external HTTP except localhost, `hcaptcha.com`, and the app host.
- Use `stub_request` for external APIs. Do not allow real HTTP in tests.
- **VCR** is configured but turned off by default. Use `VCR.use_cassette("name") { ... }` when needed. Re-record with `VCR_RECORD_ALL=true bin/rails test test/path`.

## Adding New Tests

1. **New concept** — Add `test/concepts/<domain>/<service>_test.rb` mirroring `app/concepts/`.
2. **New model** — Add `test/models/<model>_test.rb` or `test/models/<namespace>/<model>_test.rb`.
3. **New component** — Add `test/components/<namespace>/<component>_test.rb` mirroring `app/components/`.
4. **New route/controller** — Add request test in `test/requests/` or system test in `test/system/`.
5. **New factory** — Add `test/support/factories/<name>_test_factory.rb` and call `ApplicationRecordTestFactoryHelper.define`.

## Assertions

Prefer Minitest assertions:

- `assert(result.success?)` / `assert(result.failure?)` for `ApplicationResult`
- `assert(result.errors.key?(:field))` for field errors
- `assert(result.errors.of_kind?(:base, "message"))` for base errors with message
- `assert_difference` / `assert_no_difference` for side effects
- `assert_enqueued_with` / `assert_no_enqueued_jobs` for jobs
- `assert_response`, `assert_redirected_to` for integration tests

## Coverage

Run with `COVERAGE=true bin/rails test`. Coverage config is in `config/coverage.rb`. Parallelization is disabled when coverage is enabled.
