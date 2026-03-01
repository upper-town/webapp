# Bootstrap 5.3 & UI Guidelines

This file provides guidance for AI agents when working with Bootstrap, layouts, views, and UI in this repository. See the project root `AGENTS.md` for full architecture.

## Bootstrap Version & Resources

- **Bootstrap 5.3** — CSS in `app/assets/stylesheets/bootstrap.min.css`, JS in `vendor/javascript/bootstrap.bundle.min.js`
- **Bootstrap Icons** — `app/assets/stylesheets/bootstrap-icons.min.css`; use `<i class="bi bi-*"></i>`
- **Official docs**: [getbootstrap.com/docs/5.3](https://getbootstrap.com/docs/5.3/)

## Core Principles

### Mobile-first & Responsive

- Use `min-width` breakpoints to progressively enhance layout as viewports expand
- Prefer Bootstrap grid (`row`, `col-*`) and utilities (`d-flex`, `gap-*`, `flex-wrap`) over custom CSS
- Test layouts at narrow widths; use `col-12 col-md-6 col-lg-4` patterns for responsive columns

### Utilities Over Custom Styles

- Prefer Bootstrap utility classes (`mb-3`, `text-body-secondary`, `d-flex`, `gap-2`) over custom CSS
- Use `application.css` and `admin.css` only for app-specific overrides (e.g. pagination, admin sidebar)
- Avoid inline `style` attributes except when necessary (e.g. `object-fit: cover` for images)

### Class-based Styling

- Use base + modifier classes (e.g. `btn btn-primary`, `alert alert-danger`) rather than type selectors
- Combine utilities for layout: `d-flex justify-content-between align-items-center gap-2`

## Layout Structure

### Route Areas

| Area | Layout | Main wrapper |
|------|--------|--------------|
| Public | `application.html.erb` | `<main><div class="container pt-3">` |
| Inside | Same | Same |
| Admin (signed in) | `application_admin.html.erb` | Sidebar + `<main class="admin-main"><div class="container-fluid pt-3">` |
| Admin (signed out) | Same | `<main><div class="container pt-3">` |

### Theming

- Public/Inside: `data-bs-theme="dark"` on `<html>`
- Admin: `data-bs-theme="light"` on `<html>`

## Accessibility (WCAG 2.2)

### Skip Link

- Add a skip-to-main-content link at the top of the body for keyboard users
- Use `visually-hidden-focusable` (Bootstrap 5) — **not** `visually-hidden` — so it appears on focus
- Target the main content container with `id="main"` and `tabindex="-1"` for programmatic focus

```html
<a class="visually-hidden-focusable" href="#main">Skip to main content</a>
```

```html
<main id="main" tabindex="-1">...</main>
```

### Visually Hidden Content

- Use `.visually-hidden` for screen-reader-only text (e.g. contextual labels for icons, "Danger:" before error text)
- Use `.visually-hidden-focusable` for skip links only — it is a standalone class, do not combine with `.visually-hidden`

### Semantic HTML

- Use `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<footer>` appropriately
- Use heading hierarchy (`h1` → `h2` → `h3`) without skipping levels
- Use `<nav>` with `aria-label` for landmark navigation (e.g. `aria-label="Main navigation"`)

### Interactive Components

- Navbar toggler: include `aria-controls`, `aria-expanded`, `aria-label="Toggle navigation"`
- Alerts: include `role="alert"`; close buttons need `aria-label="Close"`
- Pagination: wrap in `<nav role="navigation" aria-label="Pagination">` (or similar descriptive label)
- Forms: associate labels with inputs via `form.label`; use `form.check_box` + `form.label` for checkboxes

### Color & Meaning

- Do not rely on color alone to convey meaning; add text or `.visually-hidden` context
- Test color contrast (WCAG 4.5:1 for text, 3:1 for non-text); Bootstrap defaults may need adjustment in some contexts

### Reduced Motion

- Bootstrap respects `prefers-reduced-motion`; avoid adding custom animations that ignore it

## Navigation

### Public Navbar

- Use `navbar navbar-expand-lg bg-body-tertiary` with `navbar-toggler` for mobile collapse
- Structure: `navbar-brand` + `collapse navbar-collapse` with `navbar-nav`
- Ensure toggler has correct `data-bs-target` and `aria-controls` matching the collapse `id`

### Admin Sidebar

- Uses custom `.admin-sidebar` styles in `admin.css`
- Section labels: `.admin-sidebar-section` with `.admin-sidebar-section-label`
- Links use `nav-link` and `active` for current page (via `nav_link_class` helper)

## Forms

### Structure

- Use `form_with`; wrap fields in `mb-3` for spacing
- Use `form.label` with `class: "form-label"` for consistency
- Use `form.text_field`, `form.email_field`, etc. with `class: "form-control"`
- Use `form.check_box` + `form.label` with `form-check-input` and `form-check-label` for checkboxes

### Validation

- `field_error_proc` wraps invalid fields in `field-with-errors` and adds `invalid-feedback`
- `form_error_messages_handler_controller` adds `is-invalid` to inputs when form has errors
- Ensure `aria-invalid="true"` and `aria-describedby` point to error message when invalid (Rails/Bootstrap handle this when using standard patterns)

### Select Components

- Use `GameSelectComponent`, `CountrySelectComponent`, `PeriodSelectComponent` with `form.select` and `form-select`

## Cards & Content

### Cards

- Use `card`, `card-body`, `card-title`, `card-text` for content blocks
- Add `shadow-sm`, `border-0` when appropriate for visual hierarchy
- Use `h-100` on cards in grids for equal height

### Empty States

- Use `card` with `text-center py-5`, icon (`bi-*`), title, description, and primary CTA
- Example: `card border-0 shadow-sm bg-body-secondary bg-opacity-25`

## Tables

### Admin Tables

- Use `Admin::TableComponent` for index tables; `Admin::DetailsTableComponent` for show/detail views
- Tables use `table table-hover table-striped`; header `thead.table-light`
- Use `scope="col"` on `<th>` for column headers

### Copy Buttons

- Copyable cells use `visually-hidden` span for clipboard content (screen reader access)
- Copy button needs `title` (tooltip) and `aria-label` or descriptive `title` for accessibility

## Buttons & Links

### Buttons

- Primary action: `btn btn-primary`
- Secondary: `btn btn-outline-secondary`
- Use `btn-sm` for compact contexts; `btn-lg` for prominent CTAs
- Use `d-grid gap-2` for stacked full-width buttons on mobile; `d-md-flex` to switch to row on larger screens

### Links as Buttons

- Use `link_to(..., class: "btn btn-primary")` for navigation that looks like a button
- Add `target="_blank"` with `rel="noopener noreferrer"` for external links

### Icon + Text

- Use `bi bi-*` with `me-1` or `ms-1` for spacing: `<i class="bi bi-plus-lg me-1"></i>`
- Decorative icons: consider `aria-hidden="true"`; for meaningful icons, pair with visible text or `visually-hidden` label

## Alerts & Flash

- Use `AlertComponent` with variants (`:success`, `:danger`, `:info`, etc.)
- Include `role="alert"`; close button: `aria-label="Close"`
- Flash items rendered via `FlashItemComponent` → `AlertComponent`

## Pagination

- Use `PaginationComponent` (offset) or `PaginationCursorComponent` (cursor)
- Wrap in `<nav role="navigation" aria-label="Pagination">` (or "Results navigation")
- Disabled items use `<span class="page-link">` not `<a>`

## Footer

- Public footer: minimal; use semantic `<footer>` and list for links
- Add `rel="noopener noreferrer"` for external links

## Images

- Use `img-fluid` for responsive images; add `rounded`, `shadow-sm` as needed
- Use `object-fit: cover` with fixed height for banner/card images to avoid distortion
- Provide `alt` text for meaningful images; empty `alt=""` for decorative images

## Checklist for New Pages

- [ ] Skip link targets main content; main has `id="main" tabindex="-1"`
- [ ] Single `h1` per page; logical heading hierarchy
- [ ] Nav/tabs have `aria-label` where helpful
- [ ] Forms have proper labels; errors use `invalid-feedback` and `is-invalid`
- [ ] Buttons/links have discernible text or `aria-label`
- [ ] Color not sole indicator of meaning
- [ ] Responsive at narrow widths
- [ ] Uses Bootstrap utilities and components; minimal custom CSS
