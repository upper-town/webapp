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
| (root) | Public controllers: `HomeController`, `ServersController`, `ServerVotesController`, `AccountsController` — extend `ApplicationController` |
| `admin/` | Admin dashboard controllers (users, servers, games, webhooks, etc.) |
| `inside/` | Authenticated user controllers (dashboard, servers, accounts, webhook configs) |
| `users/` | User auth (sessions, email confirmations, password resets, change email) |
| `admin_users/` | Admin user auth (sessions, email confirmations, password resets) |
| `demo/` | Dev-only webhook testing (`Demo::WebhookEventsController` uses `ApplicationApiController`) |
| `concerns/auth/` | Auth concerns for each area (ManageSession, ManageCaptcha, etc.) |

## Key Patterns

- **Controller–Service–Form flow**: Build form from params → validate form → call service with form object → handle result (redirect or re-render with errors).
- **Strong parameters**: Use `params.require(:key).permit(...)` for form params; the param key matches the form's `model_name` (e.g. `server` for `Servers::CreateForm`).
- **Auth**: Use `authenticate_user!`, `authenticate_admin!`, etc. from concerns. Policies checked in controllers before calling services.
- **Flash**: Use `redirect_to(..., success: "...")` or `flash.now[:alert]` for errors.

## Route Areas

| Area | Path | Base |
|------|------|------|
| Public | `/` | `ApplicationController` |
| Inside | `/i` | `Inside::BaseController` |
| Admin | `/admin` | `Admin::BaseController` |
| Demo | `/demo` | `Demo::BaseController` (dev only) |

Auth routes: `/users` (user sign-up/sign-in), `/admin_users` (admin sign-up/sign-in). Public profiles at `/u/:id`.

Views live in `app/views/` under matching structure (`admin/`, `inside/`, `users/`, etc.). Use the layout for each area (`application.html.erb`, `application_admin.html.erb`).
