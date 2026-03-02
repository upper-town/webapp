# Config Directory Guide

This file provides guidance for AI agents working with configuration in `config/`. See the project root `AGENTS.md` for full architecture.

## Overview

Configuration is split across application settings, environments, database configs, and initializers. Key files are referenced from the root `AGENTS.md` Key File Locations table.

## Key Files

| File | Purpose |
|------|---------|
| `config/application.rb` | Application-wide settings |
| `config/routes.rb` | Route definitions |
| `config/database.yml` | Primary and Solid* database connections |
| `config/queue.yml`, `config/cache.yml`, `config/cable.yml` | SolidQueue, SolidCache, SolidCable configs |
| `config/ci.rb` | CI pipeline definition (run via `bin/ci`) |
| `config/recurring.yml` | SolidQueue recurring job schedules |
| `config/deploy.yml` | Kamal deployment configuration |
| `config/coverage.rb` | Test coverage (used when `COVERAGE=true`) |
| `config/importmap.rb` | JavaScript import map (Stimulus, Bootstrap) |
| `config/locales/` | i18n translations (`en.yml`, etc.) |
| `config/storage.yml` | Active Storage (local disk, etc.) |
| `config/puma.rb` | Web server configuration |
| `config/brakeman.yml`, `config/bundler-audit.yml` | Security tool configs |

## CI Pipeline (`config/ci.rb`)

Run with `bin/ci`. Steps include: setup, bundler-audit, importmap audit, Brakeman, `bin/rails test`, `bin/rails test:system`, `db:seed:replant`.

## Recurring Jobs (`config/recurring.yml`)

Defines cron-like schedules for SolidQueue. Examples: webhook publishing, stats consolidation, server verification, cleanup jobs. Edit this file to add or change recurring jobs.

## Initializers

| Initializer | Purpose |
|-------------|---------|
| `field_error_proc.rb` | Wraps invalid form fields in `field-with-errors` |
| `content_security_policy.rb` | CSP headers |
| `cors.rb` | CORS configuration |
| `inflections.rb` | Custom pluralization/singularization |
| `date_formats.rb`, `time_formats.rb` | i18n date/time formats |
| `phonelib.rb` | Phone number validation (Phonelib) |

## Environments

`config/environments/` contains `development.rb`, `test.rb`, `production.rb`. Override locally with `.env`, `.env.local`, or `.env.test.local`.
