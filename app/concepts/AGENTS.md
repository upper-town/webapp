# Concepts Directory Guide

This file provides guidance for AI agents working in `app/concepts/`. See the project root `AGENTS.md` for full architecture and patterns.

## Overview

Business logic lives here, organized by **domain concept** (not by technical layer). Each concept is a module with services, queries, jobs, and sometimes nested sub-concepts.

## Where to Put New Code

| If you're adding… | Put it in… | Example |
|-------------------|------------|---------|
| Server CRUD, voting, archiving | `servers/` | `Servers::Create`, `Servers::Update`, `Servers::CreateVote` |
| User auth, email, password | `users/` or `admin_users/` | `Users::Create`, `AdminUsers::AuthenticateSession` |
| Admin list/filter/update for X | `admin/` | `Admin::Servers::Update`, `Admin::UsersQuery` |
| Inside (authenticated user) dashboard stats | `inside/` | `Inside::DashboardStats` |
| Webhook events, batching | `webhooks/` | `Webhooks::CreateEvents`, `Webhooks::PublishBatchJob` |
| Dev-only webhook testing | `demo/` | `Demo::WebhookEvents::Create`, `Demo::Webhooks::Request` |
| Shared time utilities | `periods.rb` | `Periods` |
| hCaptcha verification | `captcha.rb` | `Captcha` |

## Naming Conventions

- **Services**: Verb names (`Create`, `Update`, `Archive`, `AuthenticateSession`)
- **Queries**: `*Query` suffix (`Servers::IndexQuery`, `Admin::ServersQuery`)
- **Jobs**: `*Job` suffix (`Servers::VerifyJob`, `Webhooks::PublishBatchJob`)
- **Nested concepts**: Subdirectory under parent (`users/password_resets/`, `servers/verify_accounts/`)

## Key Patterns

- **Include `Callable`** — Enables `MyService.call(args)` class method.
- **Return `ApplicationResult`** — Define nested `Result` class with `attribute :record` (or domain-specific names like `attribute :user`, `attribute :server`) when the service returns a created/updated record.
- **Form positional, context keyword** — `def initialize(form, account:)` not `def initialize(account:, form:)`.
- **Record + form for updates** — `def initialize(server, form)` for `Servers::Update`, `Admin::Servers::Update`.

## Admin Concept

`admin/` contains:

- **Update/Create services** — `Admin::Servers::Update`, `Admin::Games::Create`, etc.
- **Base queries** — `Admin::ServersQuery`, `Admin::UsersQuery`, etc. at top level (return base `ActiveRecord::Relation`)
- **Search queries** — `Admin::Queries::ServersQuery`, `Admin::Queries::UsersQuery`, etc. in `admin/queries/` extend `Search::Base` from `app/queries/search/` and mix in search scopes (`Search::ById`, `Search::ByEmail`, `Search::ByName`, `Search::ByUuid`, `Search::ByLastFour`, `Search::ByRemoteIp`) to filter the base relation by search term
- **Dashboard** — `Admin::DashboardStats`
- **Constraints** — `Admin::Constraint`, `Admin::JobsConstraint`

Admin services typically receive the record and form (or form only for create), and perform updates with authorization already enforced by the controller.

## Adding New Concepts

When adding a new concept: create the service/query/job under the appropriate directory, include `Callable`, return `ApplicationResult` from services, add a form object in `app/models/` if the service needs user input (see `app/models/AGENTS.md`), and add tests in `test/concepts/` mirroring the structure. See `test/AGENTS.md` for test patterns.
