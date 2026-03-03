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
- **Return `ApplicationResult`** — Define nested `Result` class with `attribute :record` (or domain-specific names like `attribute :user`, `attribute :server`) when the service returns a created/updated record. For services that return nothing (e.g. archive), use `Result.success` or a minimal Result with no attributes.
- **Form positional, context keyword** — `def initialize(form, account:)` not `def initialize(account:, form:)`.
- **Record + form for updates** — `def initialize(server, form)` for `Servers::Update`, `Admin::Servers::Update`.

## Admin Concept

`admin/` contains:

- **Update/Create services** — `Admin::Servers::Update`, `Admin::Games::Create`, etc.
- **Coordinator queries** — `Admin::ServersQuery`, `Admin::ServerVotesQuery`, etc. at top level orchestrate filter + search + sort; return final `ActiveRecord::Relation`
- **Filter queries** — `Admin::ServersFilterQuery`, `Admin::ServerVotesFilterQuery`, etc. extend `Filter::Base` from `app/queries/filter/` and apply AND-composed filters
- **Search queries** — `Admin::ServersSearchQuery`, `Admin::GamesSearchQuery`, `Admin::WebhookConfigsSearchQuery`, etc. extend `Search::Base` from `app/queries/search/` and apply OR-composed search
- **Sort queries** — `Admin::ServersSortQuery`, `Admin::GamesSortQuery`, etc. extend `Sort::Base` from `app/queries/sort/` and implement `sort_key_columns`; coordinator queries pass default `sort_key`/`sort_dir` when params are nil (e.g. `AdminRolesQuery` passes `"key"`/`"asc"`)
- **Dashboard** — `Admin::DashboardStats`
- **Constraints** — `Admin::Constraint`, `Admin::JobsConstraint`

Admin services typically receive the record and form (or form only for create), and perform updates with authorization already enforced by the controller.

**Jobs**: Use `ApplicationJob` for one-off or retried jobs (polynomial backoff). Use `ApplicationPollingJob` for recurring jobs that should not retry on failure (e.g. cleanup, consolidation).

## Adding a New Admin Index (List) Resource

When adding a new admin list page with filters and search:

1. **Coordinator query** — `Admin::<Resource>Query` in `app/concepts/admin/`; accepts `status:`, `country_codes:`, `game_ids:` (or domain-specific), `search_term:`, `sort_key:`, `sort_dir:`; chains filter → search → sort; returns `ActiveRecord::Relation`.
2. **Filter query** — `Admin::<Resource>FilterQuery` extends `Filter::Base`; implements private `scopes`; use `Filter::ByValues`, `Filter::ByDateRange` mixins as needed.
3. **Search query** — `Admin::<Resource>SearchQuery` extends `Search::Base`; implements private `scopes`; mix in `Search::ById`, `Search::ByEmail`, `Search::ByName`, etc.
4. **Sort query** — `Admin::<Resource>SortQuery` extends `Sort::Base`; implements `sort_key_columns` (private).
5. **Controller** — Call coordinator with params; wrap relation in `Pagination.new(relation, request, per_page: 50)`.
6. **View** — Use `Admin::FilterComponent`, `Admin::SearchFormComponent`, `Admin::TableComponent`; wire filter form with `data-controller="admin-filter"` or appropriate multi-select controller. Use `RequestHelper#url_with_query` for sort links; pass `hidden_params` to SearchFormComponent to preserve filter params. See `app/views/admin/servers/index.html.erb`.
7. **Locales** — Add keys under `admin.<resource>.*` for columns, filters, actions.

See `app/concepts/admin/servers_query.rb` and `Admin::ServersController#index` as reference.

## Adding New Concepts

When adding a new concept: create the service/query/job under the appropriate directory, include `Callable`, return `ApplicationResult` from services, add a form object in `app/models/` if the service needs user input (see `app/models/AGENTS.md`), and add tests in `test/concepts/` mirroring the structure. See `test/AGENTS.md` for test patterns.
