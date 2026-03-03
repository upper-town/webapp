# JavaScript & Stimulus Guide

This file provides guidance for AI agents when working with JavaScript in this repository. See the project root `AGENTS.md` for full architecture.

## Overview

The app uses **Stimulus** (Hotwire) for JavaScript behavior. All JavaScript lives under `app/javascript/`. Inline JavaScript in HTML (e.g. `onclick`, `href="javascript:..."`) does not work—security checks block it.

**Style**: Use double quotes for strings in `.js` files (imports, string literals, etc.). Single quotes are not preferred.

## Structure

| Path | Purpose |
|------|---------|
| `app/javascript/controllers/` | Stimulus controllers |
| `app/javascript/lib/` | Shared utilities (e.g. `navigate.js`, `cookies.js`) |
| `app/javascript/application.js` | Main entry point |

Controllers are loaded via importmap (`config/importmap.rb`). No external npm packages for UI behavior—Bootstrap JS and Stimulus are sufficient.

## Stimulus Conventions

- **Naming**: Controllers use kebab-case in HTML (`data-controller="copy-to-clipboard"`) and snake_case in filenames (`copy_to_clipboard_controller.js`). The filename maps to the controller name: `servers` → `servers_controller.js`, `admin-filter` → `admin_filter_controller.js`.
- **Values**: Use `data-<controller>-<value>-value` for config (e.g. `data-copy-to-clipboard-value`)
- **Targets**: Use `data-<controller>-target="<name>"` for DOM elements
- **Actions**: Use `data-action="click->copy-to-clipboard#copy"` for event handlers

## Key Controllers

| Controller | Purpose |
|------------|---------|
| `copy-to-clipboard` | Copy text to clipboard; used by `Admin::CopyableCell` |
| `form-error-messages-handler` | Adds `is-invalid` to inputs in `field-with-errors`; removes on input |
| `search-form` | Admin search form behavior |
| `admin-filter` | Admin filter form auto-submit on change (native selects) |
| `servers` | Public server index filter form auto-submit on change (e.g. period select); `change->servers#filter` |
| `back-link` | Cancel/back button; navigates to `history.back()` when clicked; used by `Admin::ShowActionsComponent` |
| `captcha` | hCaptcha widget integration |
| `game-select`, `country-select`, `period-select` | Select component behavior |
| `admin-multi-select-filter` | Multi-select with client-side filtering; static options (admin) |
| `multi-select-filter` | Multi-select with client-side filtering; static options (public server index) |
| `admin-fetchable-multi-select-filter` | Multi-select with backend fetch; used for account filter on admin server votes |
| `navigate` | Turbo navigation helpers |
| `browser-time-zone` | Sends time zone to server |
| `select-text` | Select text on click; used in pagination |

## Adding New Behavior

1. Create a new controller in `app/javascript/controllers/<name>_controller.js` (e.g. `my_feature_controller.js` for `data-controller="my-feature"`)
2. Export default class extending Stimulus `Controller`
3. Use `static values` and `static targets` as needed
4. Wire in views via `data-controller`, `data-action`, `data-*-target`, `data-*-value`
5. Controllers are auto-loaded from `app/javascript/controllers/` via importmap; no manual registration needed

## Bootstrap JS

Bootstrap's JS (dropdowns, modals, toggles) is in `vendor/javascript/bootstrap.bundle.min.js`. Use `data-bs-*` attributes for Bootstrap components. No custom JS needed for standard Bootstrap behavior.

## Turbo

Turbo Drive handles full-page navigations; Turbo Frames handle partial updates. Forms submit via Turbo by default. Use `data-turbo-frame="_top"` on links to break out of a frame and load the full page.
