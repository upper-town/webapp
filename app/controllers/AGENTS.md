# Controllers Directory Guide

This file provides guidance for AI agents working with controllers in `app/controllers/`. See the project root `AGENTS.md` for full architecture and route areas.

## Overview

Controllers are organized by route area. Base controllers and auth concerns define authentication and layout. Controllers delegate to domain services; they do not call models directly for create/update/destroy.

## Base Controllers

| Controller | Extends | Purpose |
|------------|---------|---------|
| `ApplicationController` | `ActionController::Base` | Public and Inside web controllers |
| `Inside::BaseController` | `ApplicationController` | Authenticated user area; adds `authenticate_user!` |
| `ApplicationAdminController` | `ActionController::Base` | Admin web controllers (sign-in, sign-up) |
| `Admin::BaseController` | `ApplicationAdminController` | Admin dashboard; requires signed-in admin |
| `ApplicationApiController` | `ActionController::API` | JSON API (e.g. demo webhooks) |
| `ApplicationApiAdminController` | `ActionController::API` | Admin API controllers |
| `Demo::BaseController` | `ApplicationController` | Dev-only demo area |

## Directory Structure

| Path | Purpose |
|------|---------|
| (root) | Public controllers: `ServersController`, `ServerVotesController`, `AccountsController` — extend `ApplicationController` |
| `admin/` | Admin dashboard controllers (users, servers, games, webhooks, etc.) |
| `inside/` | Authenticated user controllers (dashboard, servers, accounts, webhook configs) |
| `users/` | User auth (sessions, email confirmations, password resets, change email) |
| `admin_users/` | Admin user auth (sessions, email confirmations, password resets) |
| `demo/` | Dev-only webhook testing (`Demo::WebhookEventsController` uses `ApplicationApiController`) |
| `concerns/auth/` | Auth concerns for each area (ManageSession, ManageCaptcha, etc.) |

## Key Patterns

- **Controller–Service–Form flow**: Build form from params → validate form → call service with form object → handle result (redirect or re-render with errors). See root `AGENTS.md` for the full flow.
- **Admin index flow**: Call coordinator query with filter/search/sort params → wrap in `Pagination.new` → render. See `app/concepts/AGENTS.md` for "Adding a New Admin Index (List) Resource".
- **Strong parameters**: Use `params.expect(key: [...])` (Rails 8) for form params; the key matches the form's `model_name.param_key`. Extract with `(filtered[:key] || filtered["key"] || {}).to_h.symbolize_keys`.
- **Auth**: Use `authenticate_user!`, `authenticate_admin!`, etc. from concerns. Policies checked in controllers before calling services.
- **Flash**: Use `redirect_to(..., success: "...")` for create/update success (sets `flash[:success]`); use `flash[:notice]` for admin success messages; use `flash.now[:alert]` for validation/error messages when re-rendering. Flash types: `success`, `notice`, `alert`, `primary`, `danger`, etc. (see `AddFlashTypes`).

## Route Areas

| Area | Path | Base |
|------|------|------|
| Public | `/` | `ApplicationController` |
| Inside | `/i` | `Inside::BaseController` |
| Admin | `/admin` | `Admin::BaseController` |
| Demo | `/demo` | `Demo::BaseController` (dev only) |

Auth routes: `/users` (user sign-up/sign-in), `/admin_users` (admin sign-up/sign-in). Public profiles at `/u/:id`.

Views live in `app/views/` under matching structure (`admin/`, `inside/`, `users/`, etc.). Use the layout for each area (`application.html.erb`, `application_admin.html.erb`). See `app/views/AGENTS.md` for view structure and conventions.
