# Today.bike Implementation vs Product Docs Gap Analysis

## Purpose

This document compares the implemented `today.bike` codebase against the current product docs and sprint plan, then classifies each major area as:
- `Implemented`
- `Partial`
- `Missing`
- `Drifted`

Primary evidence:
- `docs/prod_req.md`
- `docs/REQUIREMENTS_v0.md`
- `docs/sprint_plan.md`
- `config/routes.rb`
- `app/controllers/**/*`
- `app/models/*.rb`
- `app/views/**/*`
- `config/storage.yml`
- `config/environments/production.rb`
- current kanban board state for remaining todo items `#715`, `#749`, `#773`, `#800`

## Executive Read

The product is much further along than a normal early-stage spec repository. The core operating system for the shop is implemented, including customer/bicycle/service-order management, fitting history, portal browsing, notifications scaffolding, QR passports, blog, public catalog, rentals, and public landing/SEO surfaces.

The main remaining gaps are not in the core CRUD backbone. They are concentrated in:
- infrastructure completion (`#715`, `#800`)
- real Kakao OAuth completion (`#749`)
- payment completion (`#773`)
- a few document/code drifts such as R2 media storage, Hetzner vs Oracle, and Ransack vs custom search

## Epic Matrix

| Epic | Doc expectation | Current state | Classification | Evidence |
|---|---|---|---|---|
| E1 프로젝트 셋업 & 인프라 | Rails 8, Docker, Kamal, DNS, Litestream backup | Rails/Docker/Kamal are present; DNS and Litestream/R2 completion remain open on kanban | Partial | `Gemfile`, `Dockerfile`, `config/deploy.yml`, `docs/sprint_plan.md`, pending tasks `#715`, `#800` |
| E2 고객 & 자전거 관리 | Customer/Bicycle CRUD, bike specs, search | Implemented with CRUD, search scopes, photos, specs | Implemented | `app/controllers/admin/customers_controller.rb`, `app/controllers/admin/bicycles_controller.rb`, `app/models/customer.rb`, `app/models/bicycle.rb`, `app/models/bicycle_spec.rb` |
| E3 정비 이력 시스템 | Service orders, kanban, photos, repairs, parts, upgrades, frame changes | Implemented across models, controllers, tabs, and nested flows | Implemented | `app/controllers/admin/service_orders_controller.rb`, `app/models/service_order.rb`, `app/views/admin/service_orders/*`, `app/models/service_photo.rb`, `app/models/repair_log.rb`, `app/models/parts_replacement.rb`, `app/models/upgrade.rb`, `app/models/frame_change.rb` |
| E4 피팅 관리 | Fitting records, comparisons, photos | Implemented | Implemented | `app/models/fitting_record.rb`, `app/controllers/admin/fitting_records_controller.rb`, `app/views/admin/fitting_records/*`, `app/controllers/portal/fitting_records_controller.rb` |
| E5 관리자 대시보드 & 검색 | Dashboard, search/filter, CSV import | Dashboard and import are implemented; search exists but is not Ransack-based as docs say | Drifted / Partial | `app/controllers/admin/dashboard_controller.rb`, `app/services/csv_import_service.rb`, `app/models/customer.rb`, `app/models/bicycle.rb`, `app/models/service_order.rb`, `Gemfile` |
| E6 고객 포털 | Kakao login, bicycle/spec view, service history, realtime, fitting | Portal browsing is implemented; login exists but is phone/session + Kakao stub, not finished OmniAuth-Kakao | Partial | `app/controllers/portal/sessions_controller.rb`, `app/controllers/portal/bicycles_controller.rb`, `app/controllers/portal/service_orders_controller.rb`, `app/controllers/portal/fitting_records_controller.rb`, pending task `#749` |
| E7 카카오 알림톡 | Notification model, job, template, outbound send | Notifications, job, and template exist; actual external Kakao integration remains stubbed | Partial | `app/models/notification.rb`, `app/jobs/kakao_notification_job.rb`, `app/services/kakao_alimtalk_service.rb` |
| E8 자전거 디지털 패스포트 | QR generation, print, public passport page | Implemented | Implemented | `app/services/qr_code_service.rb`, `app/controllers/admin/bicycles_controller.rb`, `app/controllers/passports_controller.rb`, `app/views/passports/show.html.erb` |
| E9 블로그 & 콘텐츠 | Blog CRUD, public blog, migration, gallery | Implemented | Implemented | `app/models/blog_post.rb`, `app/controllers/admin/blog_posts_controller.rb`, `app/controllers/blog_controller.rb`, `app/services/naver_blog_migration_service.rb`, `app/controllers/gallery_controller.rb` |
| E10 파츠 판매 & 대여 | Product CRUD, public shop, rentals, reservation, Toss payment | Product/rental surfaces are implemented; payment is still missing | Partial | `app/models/product.rb`, `app/models/rental.rb`, `app/models/rental_booking.rb`, `app/controllers/products_controller.rb`, `app/controllers/rentals_controller.rb`, pending task `#773` |
| E11 SEO & 공개 페이지 | Sitemap, meta, landing, service pages, responsive QA | Implemented | Implemented | `app/controllers/pages_controller.rb`, `app/views/pages/*`, `app/controllers/sitemap_controller.rb`, `app/views/shared/_meta_tags.html.erb` |

## What Is Clearly Implemented

### Internal shop operating system

Implemented:
- admin authentication
- customer records
- bicycle records and photos
- bicycle specs
- service order CRUD
- service-order kanban/status handling
- repair, parts, upgrade, frame change logging
- fitting history
- dashboard and CSV import

Why this matters:
- The original “replace Excel with a web operating system” goal is already substantially achieved.

### Customer-facing trust surfaces

Implemented:
- portal bicycle pages
- portal service-order history/detail
- portal fitting pages
- realtime service-order update broadcasting
- QR passport public page
- visible cost/progress/photo exposure in portal views

Evidence:
- `app/controllers/portal/*`
- `app/models/service_order.rb`
- `app/views/portal/**/*`
- `app/controllers/passports_controller.rb`

### Public growth surfaces

Implemented:
- home page
- service detail pages
- blog
- gallery
- products
- rentals
- SEO sitemap/meta

Evidence:
- `config/routes.rb`
- `app/controllers/pages_controller.rb`
- `app/controllers/blog_controller.rb`
- `app/controllers/gallery_controller.rb`
- `app/controllers/products_controller.rb`
- `app/controllers/rentals_controller.rb`
- `app/views/shared/_meta_tags.html.erb`

## Partial or Missing Areas

### 1. Kakao OAuth login is not actually finished

Docs expect:
- OmniAuth-Kakao based portal authentication

Current reality:
- `Portal::SessionsController#create` logs in by phone number
- `kakao_callback` is explicitly marked as a future stub
- `Gemfile` does not show OmniAuth-Kakao
- kanban still has `#749` open

Classification:
- `Partial`

Why it matters:
- Portal access works, but the intended low-friction customer login experience is not yet live.

### 2. Kakao notification delivery is scaffolded, not fully externalized

Docs expect:
- Kakao Alimtalk API integration

Current reality:
- notification model, background job, and templates exist
- service layer falls back to stub mode unless env vars exist
- actual API call is placeholder logic

Evidence:
- `app/services/kakao_alimtalk_service.rb`
- `app/jobs/kakao_notification_job.rb`

Classification:
- `Partial`

### 3. Payment is still absent

Docs expect:
- Toss Payments integration for phase 3 commerce

Current reality:
- no payment routes, webhook routes, or payment models are visible
- pending kanban task `#773` remains open

Classification:
- `Missing`

### 4. Cloudflare R2 media storage is not implemented in runtime config

Docs expect:
- Active Storage + R2

Current reality:
- production uses `config.active_storage.service = :local`
- `config/storage.yml` only defines local disk for active use

Classification:
- `Missing` for media storage
- `Partial` for R2 overall because Litestream backup config exists

### 5. Public shop still stops at browse/inquiry

Docs allow a staged approach:
- inquiry first, checkout later

Current reality:
- product browsing is implemented
- product detail links to Kakao inquiry
- no cart/checkout routes exist

Evidence:
- `app/controllers/products_controller.rb`
- `app/views/products/show.html.erb`

Classification:
- `Partial`, but acceptable relative to phased product intent

## Drift Items

These are areas where code exists, but it does not match the documented implementation story cleanly.

### 1. Search exists, but not as Ransack

Docs say:
- Ransack-based search/filter

Current reality:
- `Gemfile` has no `ransack`
- search is implemented through model scopes and controller filtering

Evidence:
- `docs/sprint_plan.md`
- `Gemfile`
- `app/models/customer.rb`
- `app/models/bicycle.rb`
- `app/models/service_order.rb`

Classification:
- `Drifted`

Meaning:
- Functionality exists, implementation approach differs from docs and done-task naming.

### 2. Infra docs say Hetzner, current ops say Oracle

Docs say:
- Hetzner in PRD/deployment narrative

Current reality:
- Oracle Cloud is documented as the actual production server

Evidence:
- `docs/prod_req.md`
- `docs/oracle_server_info.md`

Classification:
- `Drifted`

### 3. Portal login exists, but user-auth model differs from PRD intent

Docs say:
- customer portal uses Kakao social login

Current reality:
- portal works off `Customer` session and phone login first
- Kakao callback remains a bridge stub

Evidence:
- `app/controllers/portal/sessions_controller.rb`
- `app/models/customer.rb`

Classification:
- `Drifted / Partial`

## Structural Observations

### The core product promise is already present

The strongest product promise in the docs is:
- operational transparency
- persistent service records
- customer trust through visible history

That promise is already visible in code through:
- service order status history
- service photos
- portal detail pages
- QR passport exposure
- fitting history

This means the project is no longer “spec only” or “landing page only”. It is an operational product with real customer-facing trust mechanics.

### Remaining gaps are mostly integration and polish gaps

The largest unfinished items are:
- true Kakao OAuth completion
- true Kakao API delivery confidence
- payment
- R2 media storage completion
- infra/doc cleanup

That is a very different risk profile from “core CRUD not built”.

## Recommended Backlog Priorities

### Highest priority

1. Finish Kakao OAuth (`#749`)
2. Finish Litestream/R2 backup verification and close infra completion (`#715`)
3. Decide and implement canonical media storage strategy if R2 is still intended
4. Finish Toss Payments (`#773`) only if commerce monetization is active now

### Medium priority

1. Refresh deployment docs to reflect Oracle reality and local-vs-R2 storage truth
2. Decide whether to keep custom search or align docs/task history with the non-Ransack implementation
3. Add a customer-visible notification/history surface if notifications should become a product feature rather than just outbound messages

### Lower priority

1. Separate portal dashboard if the customer experience needs a stronger landing screen
2. Consider cart/checkout only if inquiry-based conversion stops being sufficient

## Suggested Follow-Up Questions

- Is phone-based portal login acceptable as a temporary production path, or must Kakao OAuth land before broader release?
- Is R2 intended only for DB backup now, or also for all uploaded media?
- Should the search story be documented as “custom scoped search” instead of “Ransack”?
- Is payment a near-term business priority, or should operational reliability/integrations come first?
