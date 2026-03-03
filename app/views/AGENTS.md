# Views Directory Guide

This file provides guidance for AI agents working with views in `app/views/`. See the project root `AGENTS.md` for architecture. For components, see `app/components/AGENTS.md`. For Bootstrap and UI, see `app/assets/stylesheets/AGENTS.md`.

## Overview

Views mirror the controller/route structure. Use ViewComponents for reusable UI; use ERB for page structure and layout. Prefer `t("key")` for user-facing strings.

## Directory Structure

| Path | Purpose |
|------|---------|
| (root) | Public pages: `servers/`, `server_votes/`, `accounts/` |
| `admin/` | Admin dashboard views; mirrors `Admin::*` controllers |
| `inside/` | Authenticated user area: dashboards, servers, accounts, webhook configs |
| `users/` | User auth: sessions, email confirmations, password resets |
| `admin_users/` | Admin user auth |
| `demo/` | Dev-only demo pages |
| `layouts/` | `application.html.erb` (public/inside), `application_admin.html.erb` (admin) |
| `shared/` | Shared partials: `_header`, `_nav`, `_main`, `_footer`, `_flash`, `_noscript`, `_dev_info` |

## Layouts

- **Public/Inside**: `application.html.erb` — `data-bs-theme="dark"`, `<main id="main" tabindex="-1">` for skip link
- **Admin**: `application_admin.html.erb` — `data-bs-theme="light"`, sidebar + main content

## Conventions

- Use `form_with` for forms; param key matches form's `model_name.param_key` (e.g. `server` for `Servers::CreateForm`, `users_session_form` for `Users::SessionForm`)
- Use `render(Component.new(...))` for ViewComponents
- Use `turbo_frame_tag` for Turbo Frame partial updates (see admin nested index views)
- Use `link_to` with `data: { turbo_frame: "_top" }` when navigating out of a frame to full page

## Adding a New Page

When adding a controller action: create the view at `app/views/<controller_path>/<action>.html.erb`. For namespaced controllers (e.g. `Admin::ServersController`), use `app/views/admin/servers/<action>.html.erb`. Use the layout for that area (`application.html.erb` or `application_admin.html.erb`).

## Mailer Views

Mailer templates live in `app/views/<mailer_name>/` (e.g. `app/views/user_mailer/`, `app/views/admin_user_mailer/`). Use the same ERB and `t()` patterns as regular views.

## Helpers

Helpers live in `app/helpers/`; `ApplicationHelper` is available in all views. Use `nav_link_class(*paths)` for admin sidebar active state; `current_page_for_nav?(path)` for path matching.
