# Database Directory Guide

This file provides guidance for AI agents working with migrations and seeds in `db/`. See the project root `AGENTS.md` for full architecture.

## Migrations

### Multi-Database Setup

| Database | Migrations | Schema |
|----------|------------|--------|
| Primary | `db/migrate/` | `db/schema.rb` |
| Queue (SolidQueue) | `db/queue_migrate/` | `db/queue_schema.rb` |
| Cache (SolidCache) | `db/cache_migrate/` | `db/cache_schema.rb` |
| Cable (SolidCable) | `db/cable_migrate/` | `db/cable_schema.rb` |

**Tests use a single database** — migrations from all paths are applied to the test DB.

### Conventions

- **Datetime columns** — Use `t.datetime`; the app configures `ActiveRecord::Base.datetime_type = :timestamptz` for PostgreSQL.
- **Soft deletes** — Timestamp columns: `archived_at`, `marked_for_deletion_at`, `disabled_at`.
- **UUIDs** — UUIDv7 for `accounts.uuid` and `server_votes.uuid` (via `pgcrypto` extension).
- **JSONB** — Use for flexible data: `metadata`, `data` on events, etc.
- **Encryption** — Sensitive fields use `encrypts :secret` (e.g. `WebhookConfig`).

### Indexes

Add indexes for foreign keys and frequently queried columns. Use `add_index` explicitly when needed (e.g. `add_index :servers, :verified_at`).

## Seeds

- **Entry point**: `db/seeds.rb` loads `db/seeds/runner.rb`.
- **Modular seeds**: `db/seeds/create_*.rb` — each module includes `Callable` (same pattern as concepts).
- **Order**: `Runner` orchestrates: admin roles and permissions → admin users → admin accounts → users → accounts → games → servers → webhook configs.

### Seed Module Pattern

```ruby
module Seeds
  class CreateGames
    include Callable

    def call
      Game.insert_all(game_hashes)
      # return IDs if needed by other seeds
    end
  end
end
```

## Running

```bash
bin/rails db:migrate           # Run primary migrations
bin/rails db:seed              # Run seeds
bin/rails db:seed:replant      # Truncate and re-seed (used in CI)
```
