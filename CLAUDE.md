# CLAUDE.md

Guidance for Claude Code when working with this repository.

## Project Overview

Today.Bike — Bicycle service management platform. Manages bicycle intake/repair/fitting/rental workflows, provides a customer portal and bicycle passport (QR) features. Full-stack Rails 8 application.

## Repository Structure

- `app/models/` — 20 domain models (Bicycle, ServiceOrder, Customer, etc.)
- `app/controllers/admin/` — Admin CRUD controllers (17)
- `app/controllers/portal/` — Customer self-service portal
- `app/views/` — ERB templates (Tailwind + Stimulus)
- `app/services/` — Business logic service objects
- `app/jobs/` — Solid Queue background jobs
- `db/migrate/` — SQLite migrations
- `test/` — Minitest test suite
- `kanban-board/` — Kanban board configuration

## Tech Stack

- **Framework**: Ruby on Rails 8.1.2 (Hotwire: Turbo + Stimulus)
- **Database**: SQLite (primary, cache, queue, cable — 4 instances)
- **Frontend**: Tailwind CSS, Stimulus Controllers, ImportMap (ESM)
- **Auth**: Devise (admin), Kakao OAuth (customer portal)
- **Background Jobs**: Solid Queue (Rails 8 default)
- **Caching**: Solid Cache (DB-backed)
- **WebSocket**: Solid Cable
- **Asset Pipeline**: Propshaft
- **Deployment**: Kamal (Docker), Thruster (HTTP compression)

## Architecture

```
Browser → Rails 8 (Puma, port 3000)
       → SQLite (4 databases: primary, cache, queue, cable)
       → Kakao API (OAuth + notification messages)
```

### Core Domain Models
- **Bicycle**: Individual bike (road/MTB/gravel/hybrid), frame number, passport token
- **Customer**: Bicycle owner (phone-based identity)
- **ServiceOrder**: Service request (6 types)
  - `overhaul`, `repair`, `parts`, `upgrade`, `fitting`, `frame_change`
  - Status workflow: received → diagnosis → in_progress → completed → delivered
- **ServiceProgress**: Status transition audit log
- **BicycleSpec**: Detailed component specifications

### Key Patterns
- **MVC Layers**: Model (domain logic) → Controller (actions) → View (ERB rendering)
- **Service Object**: Complex business logic extracted to `app/services/`
- **Stimulus Controller**: JavaScript interactions handled via Stimulus
- **Namespace Routing**: `/admin/*` (staff), `/portal/*` (customers), `/` (public)

## Commands

```bash
# Development
bin/rails server              # Puma on :3000
bin/rails db:migrate          # Run migrations
bin/rails db:seed             # Load seed data

# Testing
bin/rails test                # All unit/integration tests
bin/rails test:system         # System tests (Capybara + Selenium)

# Code Quality
bin/rubocop                   # RuboCop linting (omakase)
bin/rake brakeman             # Security vulnerability scan
bin/rake bundler-audit        # Gem vulnerability audit

# Deployment
kamal deploy                  # Deploy via Docker
```

## Dependency Direction (Must Not Violate)

```
Controller → Service → Model
View → Helper → Model (read-only)
```

- Controllers must not perform complex model operations directly — delegate to Services
- Views must not execute DB queries — use `@variables` prepared by Controllers/Helpers
- No circular dependencies between Models

## Forbidden Patterns

- ❌ Business logic in Controllers (extract to Service if >10 lines of logic)
- ❌ Direct DB queries in Views (use `@variables` only)
- ❌ N+1 queries (always use `includes`/`eager_load`)
- ❌ Bypassing authentication without `skip_before_action`
- ❌ Inline JavaScript (extract to Stimulus controllers)

## Required Patterns

- ✅ New models must include migration + test + fixture together
- ✅ Status changes must be recorded in ServiceProgress (audit trail)
- ✅ Monetary fields stored as integers (KRW, no decimals)
- ✅ Customer phone numbers validated in Korean format (010-XXXX-XXXX)
- ✅ Images managed via Active Storage (max 10 per service order)

## CI/CD

GitHub Actions (`.github/workflows/ci.yml`):
- Brakeman security scan
- Bundler Audit
- ImportMap JS audit
- RuboCop linting
- Full test suite
- System tests (screenshot artifacts)
