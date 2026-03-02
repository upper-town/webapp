# Queries Directory Guide

This file provides guidance for AI agents working in `app/queries/`. See the project root `AGENTS.md` for full architecture. Domain-specific queries live in `app/concepts/`.

## Overview

`app/queries/` contains **shared** query logic used across multiple concepts. Domain-specific queries (e.g. `Admin::ServersQuery`, `Servers::IndexQuery`) live in `app/concepts/`.

## Directory Structure

| Path | Purpose |
|------|---------|
| `app/queries/search/` | `Search::Base` and search scope mixins for admin list filtering |
| `app/queries/country_select_options_query.rb` | Options for country dropdowns |
| `app/queries/game_select_options_query.rb` | Options for game dropdowns |
| `app/queries/period_select_options_query.rb` | Options for period dropdowns |

## Search Module (`app/queries/search/`)

Admin list pages use a two-step query pattern:

1. **Base query** — `Admin::ServersQuery`, `Admin::UsersQuery`, etc. in `app/concepts/admin/` return the base `ActiveRecord::Relation`
2. **Search query** — `Admin::Queries::ServersQuery`, `Admin::Queries::UsersQuery`, etc. in `app/concepts/admin/queries/` extend `Search::Base` and mix in scope modules to filter by search term

### Search::Base

- Accepts `(base_model, relation, term)` in `initialize`
- Returns `relation` when `term` is blank
- Subclasses implement `scopes` (private) to merge search conditions
- Provides `term_for_like(left:, right:)` for SQL `LIKE` patterns
- Provides `sanitized_table_column(table_column)` for safe table.column identifiers (Brakeman-safe)

### Search Mixins

| Mixin | Use case |
|-------|----------|
| `Search::ById` | Numeric ID search |
| `Search::ByEmail` | Email search |
| `Search::ByName` | Name search |
| `Search::ByUuid` | UUID search |
| `Search::ByLastFour` | Last 4 chars (e.g. token suffix) |
| `Search::ByRemoteIp` | IP address search |

Example: `Admin::Queries::UsersQuery` extends `Search::Base` and includes `Search::ById`, `Search::ByEmail`.

**Adding a new admin search**: Create a class in `app/concepts/admin/queries/` that extends `Search::Base`, implements private `scopes` method, and mixes in the appropriate `Search::*` modules. The controller passes the base relation from `Admin::*Query` (e.g. `Admin::ServersQuery`) and the search term; the search query filters and returns the relation.

## Select Options Queries

`CountrySelectOptionsQuery`, `GameSelectOptionsQuery`, `PeriodSelectOptionsQuery` return arrays of `[label, value]` for use with `form.select`. Include `Callable` and use `.call` to invoke.

**Adding a new select options query**: Create a class in `app/queries/` that includes `Callable`, returns `[[label, value], ...]`, and follows the pattern of existing `*_select_options_query.rb` files.
