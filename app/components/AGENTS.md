# Components Directory Guide

This file provides guidance for AI agents working with ViewComponents in `app/components/`. See the project root `AGENTS.md` for full architecture. For Bootstrap usage, accessibility, and UI patterns, see `app/assets/stylesheets/AGENTS.md`.

## Overview

All components inherit from `ApplicationComponent < ViewComponent::Base`. Use Bootstrap for layout and styling; Bootstrap Icons (`<i class="bi bi-*"></i>`) for icons—no external imports needed.

## Conventions

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
| `GameSelectComponent`, `CountrySelectComponent`, `PeriodSelectComponent` | Select dropdowns |
| `Servers::IndexResultComponent` | Server listing result row/card |
| `Servers::IndexFilterComponent` | Server index filter form (game, period, country) |
| `Inside::ServerCardComponent` | Server card for Inside dashboard |
| `Admin::TableComponent` | Admin data tables; includes `Admin::CopyableCell` for copyable columns |
| `Admin::DetailsTableComponent` | Admin key-value detail views with optional copy; includes `Admin::CopyableCell` |
| `Admin::CopyableCell` | Module (not a component) providing `copy_cell_wrapper` and `copy_button_html`; included by `Admin::TableComponent` and `Admin::DetailsTableComponent` |
| `Admin::SearchFormComponent` | Admin search/filter forms |
| `Admin::FilterComponent` | Reusable admin filter wrapper (fields via block, hidden params, clear button); used by `ServersFilterComponent`, `ServerStatsFilterComponent` |
| `Admin::ServerStatusBadgesComponent` | Server status badges (verified, archived, etc.) |
| `Admin::IndexActionsComponent`, `Admin::ShowActionsComponent` | Admin action buttons |

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
