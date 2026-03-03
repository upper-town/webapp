# Models Directory Guide

This file provides guidance for AI agents working with models in `app/models/`. See the project root `AGENTS.md` for full architecture and patterns.

## Overview

Models include ActiveRecord records, form objects, and concerns. Form objects live under domain namespaces (e.g. `Users::SessionForm`, `Servers::CreateForm`, `Admin::Servers::EditForm`). Validators and normalizers live in `app/validators/` and `app/normalizers/`.

## Base Classes

| Class | Purpose |
|-------|---------|
| `ApplicationRecord` | Base for ActiveRecord models; uses `record_type` as inheritance column |
| `ApplicationModel` | Base for form objects and Result classes; includes ActiveModel::Model, ActiveModel::Attributes |

## Form Object Layout

| Namespace | Examples |
|-----------|----------|
| `users/` | `SessionForm`, `PasswordResetForm`, `EmailConfirmationForm`, `ChangeEmailConfirmationForm`, `ChangeEmailReversionForm` |
| `admin_users/` | `SessionForm`, `PasswordResetForm`, `EmailConfirmationForm` |
| `servers/` | `CreateForm`, `VoteForm` |
| `admin/` | `Admin::Servers::EditForm`, `Admin::Games::Form`, `Admin::WebhookConfigs::Form`, `Admin::FeatureFlags::Form`, `Admin::AdminRoles::UpdateForm`, `Admin::AdminAccounts::UpdateRolesForm`, `Admin::AdminUsers::EditForm` |

Form objects use `attribute` for fields, validate with `validates` and custom `validate` callbacks, and define `model_name` (via `self.model_name`) when the form should bind to a different param key.

**`model_name` and param key**: The form's `model_name.param_key` determines the params key. By default, `Users::SessionForm` → `users_session_form`; `Servers::CreateForm` with custom `model_name` → `server`. To submit under `server` params (for `params.require(:server).permit(...)`), use:

```ruby
def self.model_name
  ActiveModel::Name.new(Server, nil, "Server")
end
```

Pass form objects whole to services—never splat attributes.

## Validators (`app/validators/`)

Two-tier pattern:

- **`Validate*`** — Contains validation logic; exposes `valid?` / `invalid?` and `errors` array
- **`*Validator`** — ActiveModel validator that delegates to `Validate*`

Use `validates :attr, email: true` (or similar) in models/forms; the `*Validator` class is registered in Rails and invoked by the option name.

## Normalizers (`app/normalizers/`)

Include `Callable`. Used in models via `normalizes :attr, with: NormalizeEmail` or `with: ->(str) { ... }`. Class normalizers are invoked as `NormalizeEmail.call(str)` by Rails; lambdas receive the raw value.

## Key Model Groups

- **User auth**: `User` → `Account`, `Session`, `Token`, `Code` (concerns: `HasPassword`, `HasEmailConfirmation`, `HasChangeEmailConfirmation`, `HasTokens`, `HasCodes`, `HasLock`, `FeatureFlagId`)
- **Admin auth**: `AdminUser` → `AdminAccount`, `AdminSession`, `AdminToken`, `AdminCode` (RBAC: `AdminRole`, `AdminPermission`, `AdminAccountRole`, `AdminRolePermission`)
- **Gaming**: `Game` → `Server` (Active Storage, verification, archiving), `ServerVote`, `ServerStat`, `ServerAccount`
- **Webhooks**: `WebhookConfig` → `WebhookEvent`, `WebhookBatch`

## Adding New Form Objects

When adding a new create/update flow: create the form under the appropriate namespace (`users/`, `servers/`, `admin/`, etc.), use `attribute` for fields, define `model_name` if param key differs from default, expose extracted data via methods (e.g. `server_attributes`), and pass the form whole to the service. The controller must validate the form (`form.invalid?`) before calling the service. Controller extracts params with `params.expect(key: [:attr1, :attr2])`; key = `form.model_name.param_key`. See root `AGENTS.md` for Controller–Service–Form flow.

## Adding New Validators

1. Create `Validate*` class in `app/validators/` with validation logic (`valid?`, `invalid?`, `errors`).
2. Create `*Validator` extending `ActiveModel::EachValidator` that delegates to it. Rails auto-loads from `app/validators/`; the option name (e.g. `email: true`) maps to `EmailValidator`.
3. Use in model/form: `validates :attr, email: true` (or your option name). See `EmailValidator` and `ValidateEmail` as reference.

## Other

- **`ImageUploadedFileForm`** — Form object for file uploads (e.g. server banner images)
- **`Dummy`** — Placeholder model for tests and edge cases
- **`DemoWebhookEvent`** — Demo-only webhook event model (development env)
