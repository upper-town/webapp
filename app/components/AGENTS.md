# Components Directory Guide

This file provides guidance for AI agents working with ViewComponents in `app/components/`. See the project root `AGENTS.md` for full architecture. For Bootstrap usage, accessibility, and UI patterns, see `app/assets/stylesheets/AGENTS.md`.

## Overview

All components inherit from `ApplicationComponent < ViewComponent::Base`. Use Bootstrap for layout and styling; Bootstrap Icons (e.g. `<i class="bi bi-plus-lg"></i>`) for icons—no external imports needed.

## Conventions

- **Template location** — Template lives next to the component: `alert_component.html.erb` for `AlertComponent`, `admin/table_component.html.erb` for `Admin::TableComponent`.
- **`attr_reader`** — Define readers for instance variables and use them in templates (e.g. `variant` instead of `@variant`).
- **Method calls with args** — Usually add parentheses: `row_value(value)`.
- **`render?`** — Override when the component should render nothing (e.g. when `content.blank?`).

## Key Components

| Component | Purpose |
|-----------|---------|
| `AlertComponent` | Flash-style alerts with variants (primary, success, danger, etc.) |
| `FlashItemComponent` | Renders individual flash items |
| `PaginationComponent` | Offset-based pagination; supports `align: :center` (default) or `align: :start` |
| `PaginationCursorComponent` | Cursor-based pagination |
| `GameSelectComponent`, `CountrySelectComponent`, `PeriodSelectComponent` | Select dropdowns; `PeriodSelectComponent` accepts optional `data_action` for auto-submit (e.g. `change->servers#filter`) |
| `MultiSelectFilterComponent` | Multi-select with client-side filtering; used by `GameMultiSelectFilterComponent`, `CountryMultiSelectFilterComponent` |
| `GameMultiSelectFilterComponent`, `CountryMultiSelectFilterComponent` | Game/country multi-select wrappers for public server index filter |
| `Servers::IndexResultComponent` | Server listing result row/card |
| `Servers::IndexFilterComponent` | Server index filter form (game, period, country) |
| `Inside::ServerCardComponent` | Server card for Inside dashboard |
| `Admin::TableComponent` | Admin data tables; `columns:` is array of `[label, value_proc, { copyable:, sortable: }]`; pass `sort_url_builder`, `sort_key`, `sort_dir` for sortable headers |
| `Admin::DetailsTableComponent` | Admin key-value detail views; `sections:` is array of rows, each row `[label, value, { copyable: }]`; value can be Proc |
| `Admin::CopyableCell` | Module (not a component) providing `copy_cell_wrapper` and `copy_button_html`; included by `Admin::TableComponent` and `Admin::DetailsTableComponent` |
| `Admin::SearchFormComponent` | Admin search/filter forms |
| `Admin::FilterComponent` | Reusable admin filter wrapper (fields via block, hidden params); used by `Admin::ServersFilterComponent`, `Admin::ServerStatsFilterComponent`, `Admin::ServerVotesFilterComponent` |
| `Admin::DateRangeFilterComponent` | Reusable start_date/end_date date inputs; optional `param_prefix` for multiple date ranges on one page; used by `Admin::ServerVotesFilterComponent` |
| `Admin::ServersFilterComponent` | Admin servers index filter (status, game, country); uses `Admin::FilterComponent` |
| `Admin::ServerStatsFilterComponent` | Admin server stats index filter (period); uses `Admin::FilterComponent` |
| `Admin::ServerVotesFilterComponent` | Admin server votes index filter (date range, game, server, account); uses `Admin::FilterComponent` |
| `Admin::MultiSelectFilterComponent` | Multi-select with client-side filtering; static options only; used by `Admin::GameMultiSelectFilterComponent`, `Admin::ServerMultiSelectFilterComponent`, etc. |
| `Admin::FetchableMultiSelectFilterComponent` | Multi-select with backend fetch; options built dynamically as user searches; used only by `Admin::AccountMultiSelectFilterComponent` on admin server votes |
| `Admin::GameMultiSelectFilterComponent` | Game-specific wrapper for `MultiSelectFilterComponent`; used on admin servers and server votes index |
| `Admin::StatusMultiSelectFilterComponent` | Status-specific wrapper for `MultiSelectFilterComponent`; used on admin servers index |
| `Admin::CountryMultiSelectFilterComponent` | Country-specific wrapper for `MultiSelectFilterComponent`; used on admin servers index |
| `Admin::PeriodMultiSelectFilterComponent` | Period-specific wrapper for `MultiSelectFilterComponent`; used on admin server stats index |
| `Admin::ServerMultiSelectFilterComponent` | Server-specific wrapper for `MultiSelectFilterComponent`; used on admin server votes index |
| `Admin::AccountMultiSelectFilterComponent` | Account-specific wrapper for `FetchableMultiSelectFilterComponent`; used on admin server votes index |
| `Admin::ServerStatusBadgesComponent` | Server status badges (verified, archived, etc.) |
| `Admin::IndexActionsComponent`, `Admin::ShowActionsComponent` | Admin action buttons |

## Adding New Components

When adding a component that is not an admin filter: inherit from `ApplicationComponent`, define `attr_reader` for instance variables, use reader methods in the template (not `@var`), override `render?` when the component should render nothing, and add it to the Key Components table above if it is reusable. See `app/assets/stylesheets/AGENTS.md` for Bootstrap and accessibility.

## Adding Admin Filters

When adding a new admin index filter:

1. **Wrapper** — Use `Admin::FilterComponent` with a block for the filter fields. Pass `form:`, `params_to_remove:` (array of param keys to strip on submit, e.g. `["page"]` to reset pagination when filters change), and optionally `request:`.
2. **Static multi-select** — Use `Admin::MultiSelectFilterComponent` (or a wrapper like `Admin::GameMultiSelectFilterComponent`) when options are known and finite. The `admin-multi-select-filter` Stimulus controller submits the form when the user applies selections.
3. **Dynamic fetch multi-select** — Use `Admin::FetchableMultiSelectFilterComponent` (or `Admin::AccountMultiSelectFilterComponent`) when options come from an API. Wired to `admin-fetchable-multi-select-filter` Stimulus controller.
4. **Simple select auto-submit** — For a native `<select>` that should submit on change: add `data-controller="admin-filter"` to the form and `data-action="change->admin-filter#filter"` to the select.
5. **Date range** — Use `Admin::DateRangeFilterComponent` for start_date/end_date inputs. Add `data-controller="admin-filter"` to the form; the component provides an Apply button that submits the form.

See `app/javascript/AGENTS.md` for the Stimulus controllers.

## Example

```ruby
class AlertComponent < ApplicationComponent
  attr_reader :variant, :dismissible

  def initialize(variant: :info, dismissible: true)
    super()
    @variant = variant
    @dismissible = dismissible
  end

  def render?
    content.present?
  end
end
```

```erb
<%# alert_component.html.erb %>
<div class="alert alert-<%= variant %>" ...>
  <%= content %>
</div>
```

## Locales

Use `t("key")` for user-facing strings. Define keys in `config/locales/`.
