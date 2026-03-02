# Queries Directory Guide

This file provides guidance for AI agents working in `app/queries/`. See the project root `AGENTS.md` for full architecture. Domain-specific queries live in `app/concepts/`.

## Overview

`app/queries/` contains **shared** query logic used across multiple concepts. Domain-specific queries (e.g. `Admin::ServersQuery`, `Servers::IndexQuery`) live in `app/concepts/`.

## Directory Structure

| Path | Purpose |
|------|---------|
| `app/queries/search/` | `Search::Base` and search scope mixins for admin list filtering |
| `app/queries/filter/` | `Filter::Base` and filter scope mixins for admin list filtering |
| `app/queries/sort/` | `Sort::Base` for reusable relation ordering |
| `app/queries/country_select_options_query.rb` | Options for country dropdowns |
| `app/queries/game_select_options_query.rb` | Options for game dropdowns |
| `app/queries/period_select_options_query.rb` | Options for period dropdowns |
| `app/queries/time_zone_select_options_query.rb` | Options for timezone dropdowns |

## Coordinator Pattern (Admin Lists)

Admin list pages use a **coordinator** that orchestrates filter and search:

1. **Coordinator** — `Admin::ServersQuery`, `Admin::ServerVotesQuery`, etc. in `app/concepts/admin/` accept all params (filters, search_term, sort_key) and return the final `ActiveRecord::Relation`
2. **Filter query** — `Admin::ServersFilterQuery`, `Admin::ServerVotesFilterQuery`, etc. extend `Filter::Base` and apply AND-composed filters
3. **Search query** — `Admin::ServersSearchQuery`, `Admin::ServerVotesSearchQuery`, etc. extend `Search::Base` and apply OR-composed search

Flow: base relation → filter → search → sort. The controller calls the coordinator once with all params; pagination receives the final relation.

## Filter Module (`app/queries/filter/`)

### Filter::Base

- Accepts `(relation, params = {})` in `initialize`; `params` is a hash of filter options
- Runs `relation.scoping { scopes }`; subclasses implement `scopes` (private)
- Filters compose with AND logic (each mixin narrows the scope)

### Filter Mixins

| Mixin | Use case |
|-------|----------|
| `Filter::ByValues` | Filter by values in a column (`by_values(scope, values, column:)`) |
| `Filter::ByDateRange` | Filter by date range (`by_date_range(scope, start_date, end_date, time_zone)`) |

Domain-specific filters (e.g. `by_status`, `by_account`) are implemented in the filter query class, not as shared mixins.

**Adding a new admin filter query**: Create a class in `app/concepts/admin/` that extends `Filter::Base`, implements private `scopes`, and mixes in the appropriate `Filter::*` modules. The coordinator passes the base relation and a hash of filter params.

## Sort Module (`app/queries/sort/`)

### Sort::Base

- Accepts `(relation, sort_key: nil, sort_dir: nil)` in `initialize`
- Subclasses must implement `sort_key_columns` (private); `id_column` (default `"id"`) is the fallback column and secondary order; callers pass defaults when sort params are nil (e.g. `sort_key: @sort_key.presence || "reference_date"`)
- No class methods; always used via subclass (e.g. `Admin::ServersSortQuery.call(relation, sort_key:, sort_dir:)`)

## Search Module (`app/queries/search/`)

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

Example: `Admin::ServersSearchQuery` extends `Search::Base` and includes `Search::ById`, `Search::ByName`.

**Adding a new admin search query**: Create a class in `app/concepts/admin/` that extends `Search::Base`, implements private `scopes` method, and mixes in the appropriate `Search::*` modules. The coordinator passes the base relation and search term.

## Select Options Queries

`CountrySelectOptionsQuery`, `GameSelectOptionsQuery`, `PeriodSelectOptionsQuery` return arrays of `[label, value]` for use with `form.select`. Include `Callable` and use `.call` to invoke.

**Adding a new select options query**: Create a class in `app/queries/` that includes `Callable`, returns `[[label, value], ...]`, and follows the pattern of existing `*_select_options_query.rb` files.
