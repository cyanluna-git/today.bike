# Today.bike Domain Model Audit

## Purpose

This document explains the current domain model and major data flows of `today.bike` from the codebase, with emphasis on ownership, side effects, and public/customer exposure paths.

Primary evidence:
- `app/models/*.rb`
- `app/controllers/admin/service_orders_controller.rb`
- `app/controllers/portal/bicycles_controller.rb`
- `app/controllers/portal/service_orders_controller.rb`
- `app/controllers/portal/fitting_records_controller.rb`
- `app/services/*.rb`
- `app/jobs/kakao_notification_job.rb`
- `db/schema.rb`

## Domain Backbone

The operational core is a three-step ownership chain:

```text
Customer
  └── Bicycle
        ├── BicycleSpec
        ├── FittingRecord
        └── ServiceOrder
              ├── ServiceProgress
              ├── ServicePhoto
              ├── RepairLog
              ├── PartsReplacement
              ├── Upgrade
              ├── FrameChange
              └── Notification
```

This matches both the implemented associations in models and the PRD relationship framing.

## Core Entities

### Customer

Role:
- Root identity for shop customers
- Owns bicycles
- Receives notifications
- Can be matched to portal login via Kakao UID or phone number

Evidence:
- `app/models/customer.rb`

Important behaviors:
- `has_many :bicycles`
- `has_many :service_orders, through: :bicycles`
- `has_many :notifications`
- `find_for_kakao_auth` links Kakao identity to an existing customer record rather than creating a separate portal-only user model

Implication:
- The customer portal is not backed by a separate account domain. It is an access layer over the shop CRM customer record.

### Bicycle

Role:
- Primary asset under management
- Connects customer identity to specs, service history, fitting history, photos, and passport visibility

Evidence:
- `app/models/bicycle.rb`

Important behaviors:
- Belongs to a customer
- Owns current specs, fitting records, and service orders
- Stores attached photos
- Generates and preserves a `passport_token`
- Exposes `passport_url` through `QrCodeService`

Implication:
- The bicycle is the core trust object in the system. It is both an admin-managed record and a customer/public exposure object.

### BicycleSpec

Role:
- Snapshot of the bicycle's current configuration by component

Evidence:
- `app/models/bicycle_spec.rb`
- `app/services/bicycle_spec_updater.rb`

Important behaviors:
- Belongs to a bicycle
- Uses grouped categories to structure UI display
- Is automatically updated by part replacement, upgrade, and frame change callbacks

Implication:
- `BicycleSpec` is not just data entry. It is the derived “current state” of the bike after service history mutates it.

### ServiceOrder

Role:
- Aggregate root for actual shop work
- Connects an intake/service event to progress, media, repair data, parts, upgrades, frame changes, notifications, and customer exposure

Evidence:
- `app/models/service_order.rb`
- `app/controllers/admin/service_orders_controller.rb`

Important behaviors:
- Belongs to a bicycle, derives customer through bicycle
- Owns service progresses, photos, repair logs, part replacements, upgrades, frame changes, notifications
- Generates `order_number`
- Creates `ServiceProgress` when status changes
- Creates `Notification` records and enqueues `KakaoNotificationJob` for relevant status changes
- Broadcasts portal-facing Turbo updates on status changes

Implication:
- `ServiceOrder` is the most important aggregate in the application. Most workflow complexity and most customer trust features converge here.

### FittingRecord

Role:
- Historical fitting measurements associated with a bicycle, optionally linked to a service order

Evidence:
- `app/models/fitting_record.rb`

Important behaviors:
- Belongs to a bicycle
- Optionally belongs to a service order
- Stores photos
- Supports diffing against previous fitting records

Implication:
- Fitting is modeled as a durable measurement history, not as a single mutable profile.

## Service Artifact Children

These models exist as children of `ServiceOrder` and describe specific classes of work.

| Model | Role | Side effect |
|---|---|---|
| `ServiceProgress` | Workflow transition history | Auto-created on service order status change |
| `ServicePhoto` | Before/during/after/diagnosis media | Attached image + portal-visible service evidence |
| `RepairLog` | Symptom, diagnosis, treatment records | Adds diagnostic narrative |
| `PartsReplacement` | Part swap history | Updates current `BicycleSpec` via callback |
| `Upgrade` | Upgrade history | Updates current `BicycleSpec` via callback |
| `FrameChange` | Frame swap / bike identity mutation | Updates bicycle brand/model and prunes specs |
| `Notification` | Outbound customer communication record | Created from service order status changes |

Evidence:
- `app/models/service_progress.rb`
- `app/models/service_photo.rb`
- `app/models/repair_log.rb`
- `app/models/parts_replacement.rb`
- `app/models/upgrade.rb`
- `app/models/frame_change.rb`
- `app/models/notification.rb`

## Adjacent Domains

### Content domain

| Model | Role | Evidence |
|---|---|---|
| `BlogPost` | Public content and migrated Naver posts | `app/models/blog_post.rb`, `app/services/naver_blog_migration_service.rb` |

Notes:
- Uses Action Text and Active Storage
- Has import path from Naver blog content
- Lives adjacent to shop operations, not inside the service-order aggregate

### Commerce domain

| Model | Role | Evidence |
|---|---|---|
| `Product` | Parts catalog | `app/models/product.rb` |
| `Rental` | Rental inventory | `app/models/rental.rb` |
| `RentalBooking` | Reservation records | `app/models/rental_booking.rb` |

Notes:
- These domains are public-facing but not tightly coupled to `Customer -> Bicycle -> ServiceOrder`
- `RentalBooking` can optionally attach to a customer, which creates a bridge back to the CRM side

### Authentication/admin domain

| Model | Role | Evidence |
|---|---|---|
| `AdminUser` | Backoffice authentication identity | `app/models/admin_user.rb` |

Notes:
- Admin authentication is fully separate from customer identity
- Customer access is session-based against `Customer`, not a second Devise model

## Relationship Map

```text
AdminUser
  └── authenticates admin surface only

Customer
  ├── has_many Bicycles
  ├── has_many ServiceOrders through Bicycles
  ├── has_many Notifications
  └── has_many RentalBookings (optional link)

Bicycle
  ├── belongs_to Customer
  ├── has_many BicycleSpecs
  ├── has_many FittingRecords
  ├── has_many ServiceOrders
  ├── has_many photos (Active Storage)
  └── exposes Passport via passport_token

ServiceOrder
  ├── belongs_to Bicycle
  ├── has_one Customer through Bicycle
  ├── has_many ServiceProgresses
  ├── has_many ServicePhotos
  ├── has_many RepairLogs
  ├── has_many PartsReplacements
  ├── has_many Upgrades
  ├── has_many FrameChanges
  ├── has_many FittingRecords (nullable back-reference)
  └── has_many Notifications

BlogPost
  └── independent content aggregate

Product
  └── independent catalog aggregate

Rental
  └── has_many RentalBookings
```

## Major Data Flows

### 1. Customer intake and bicycle registration

```text
Admin customer form
  -> Customer record
  -> Admin bicycle form
  -> Bicycle record
  -> Optional BicycleSpec and FittingRecord flows
```

Evidence:
- `app/controllers/admin/customers_controller.rb`
- `app/controllers/admin/bicycles_controller.rb`
- `app/controllers/admin/bicycle_specs_controller.rb`
- `app/controllers/admin/fitting_records_controller.rb`

Meaning:
- The CRM side begins with a customer record, but bicycle registration is what unlocks most downstream value.

### 2. Service lifecycle flow

```text
Admin creates ServiceOrder
  -> ServiceOrder persists under Bicycle
  -> Status changes create ServiceProgress rows
  -> Detail tabs accumulate photos, repairs, parts, upgrades, frame changes
  -> Some child records mutate current BicycleSpec
```

Evidence:
- `app/controllers/admin/service_orders_controller.rb`
- `app/models/service_order.rb`
- `app/models/parts_replacement.rb`
- `app/models/upgrade.rb`
- `app/models/frame_change.rb`

Meaning:
- Historical work records and current bike state are connected. This is not just an append-only log.

### 3. Portal exposure flow

```text
Customer session
  -> current_customer
  -> bicycles / service_orders / fitting_records filtered by ownership
  -> service order detail includes progress, photos, repairs, parts
```

Evidence:
- `app/controllers/portal/base_controller.rb`
- `app/controllers/portal/bicycles_controller.rb`
- `app/controllers/portal/service_orders_controller.rb`
- `app/controllers/portal/fitting_records_controller.rb`

Meaning:
- Customer exposure is read-only and ownership-filtered. The portal is a window into CRM data, not a separate workflow system.

### 4. Notification flow

```text
ServiceOrder status update
  -> create Notification row
  -> enqueue KakaoNotificationJob
  -> job builds variables and calls KakaoAlimtalkService
  -> notification marked sent / failed / skipped
```

Evidence:
- `app/models/service_order.rb`
- `app/jobs/kakao_notification_job.rb`
- `app/services/kakao_alimtalk_service.rb`
- `app/services/notification_template.rb`

Meaning:
- Notifications are first-class records with delivery state, not just transient API side effects.

### 5. Public trust flow

```text
Bicycle passport token
  -> passport URL
  -> public passport page

Service order updates
  -> Turbo broadcast replace
  -> portal service order detail refresh
```

Evidence:
- `app/models/bicycle.rb`
- `app/services/qr_code_service.rb`
- `app/controllers/passports_controller.rb`
- `app/models/service_order.rb`

Meaning:
- The codebase explicitly turns internal service records into trust artifacts for customers and even public viewers.

### 6. Content and commerce flows

```text
Admin blog management or Naver import
  -> BlogPost
  -> public blog pages

Admin product/rental CRUD
  -> Product / Rental / RentalBooking
  -> public product/rental pages
```

Evidence:
- `app/controllers/admin/blog_posts_controller.rb`
- `app/controllers/blog_controller.rb`
- `app/services/naver_blog_migration_service.rb`
- `app/controllers/admin/products_controller.rb`
- `app/controllers/products_controller.rb`
- `app/controllers/admin/rentals_controller.rb`
- `app/controllers/admin/rental_bookings_controller.rb`
- `app/controllers/rentals_controller.rb`

## Aggregate Notes

### Strongest aggregate roots

- `Customer`
- `Bicycle`
- `ServiceOrder`
- `BlogPost`
- `Product`
- `Rental`

### Most operationally important aggregate

- `ServiceOrder`

Reason:
- It owns the service workflow, most nested work artifacts, customer notifications, and real-time portal exposure.

### Most brand/trust important entity

- `Bicycle`

Reason:
- It is the unit customers identify with, the object behind the passport feature, and the container for both current spec and service history.

## Follow-Up Notes for Gap Analysis

- `Notification` exists as a domain object, but there is no visible customer notification inbox surface yet.
- `BicycleSpec` is a derived current-state model; any future migration or reporting work needs to preserve those callback-based updates.
- `FrameChange` is the most structurally invasive child model because it mutates bicycle identity and deletes non-transferred specs.
- The portal reads from operational aggregates directly, which is efficient now but also means any schema drift in the core models will surface to customer views quickly.
