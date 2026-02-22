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
| Webhook events, batching | `webhooks/` | `Webhooks::CreateEvents`, `Webhooks::PublishBatchJob` |
| Dev-only webhook testing | `demo/` | `Demo::WebhookEvents::Create` |
| Shared time utilities | `periods.rb` | `Periods` |
| hCaptcha verification | `captcha.rb` | `Captcha` |

## Naming Conventions

- **Services**: Verb names (`Create`, `Update`, `Archive`, `AuthenticateSession`)
- **Queries**: `*Query` suffix (`Servers::IndexQuery`, `Admin::ServersQuery`)
- **Jobs**: `*Job` suffix (`Servers::VerifyJob`, `Webhooks::PublishBatchJob`)
- **Nested concepts**: Subdirectory under parent (`users/password_resets/`, `servers/verify_accounts/`)

## Key Patterns

- **Include `Callable`** — Enables `MyService.call(args)` class method.
- **Return `ApplicationResult`** — Define nested `Result` class with `attribute :record` when needed.
- **Form positional, context keyword** — `def initialize(form, account:)` not `def initialize(account:, form:)`.
- **Record + form for updates** — `def initialize(server, form)` for `Servers::Update`, `Admin::Servers::Update`.

## Admin Concept

`admin/` contains:

- **Update/Create services** — `Admin::Servers::Update`, `Admin::Games::Create`, etc.
- **Queries** — `Admin::ServersQuery`, `Admin::UsersQuery`, etc. in `admin/queries/`
- **Dashboard** — `Admin::DashboardStats`
- **Constraints** — `Admin::Constraint`, `Admin::JobsConstraint`

Admin services typically receive the record and form (or form only for create), and perform updates with authorization already enforced by the controller.
