# Today.bike IA Audit

## Purpose

This document reconstructs the current information architecture of `today.bike` from the live route tree, controller surface, and view inventory rather than from proposal copy alone.

Primary evidence:
- `config/routes.rb`
- `app/controllers/admin/*`
- `app/controllers/portal/*`
- `app/controllers/blog_controller.rb`
- `app/controllers/gallery_controller.rb`
- `app/controllers/pages_controller.rb`
- `app/controllers/products_controller.rb`
- `app/controllers/rentals_controller.rb`
- `app/views/**/*`
- `docs/REQUIREMENTS_v0.md`
- `docs/prod_req.md`

## Access Boundaries

| Surface | Access | Entry points | Evidence |
|---|---|---|---|
| Public site | Open | `/`, `/services/:service_type`, `/blog`, `/gallery`, `/products`, `/rentals`, `/passport/:token` | `config/routes.rb`, `app/views/pages`, `app/views/blog`, `app/views/gallery`, `app/views/products`, `app/views/rentals`, `app/views/passports` |
| Customer portal | Session-based customer login required | `/portal/login`, `/portal`, `/portal/bicycles`, `/portal/service_orders`, `/portal/fitting_records` | `config/routes.rb`, `app/controllers/portal/base_controller.rb`, `app/views/portal/**/*` |
| Admin | Devise-authenticated admin only | `/admin`, `/admin/*`, `/admin_users/sign_in` | `config/routes.rb`, `app/controllers/admin/base_controller.rb`, `app/views/admin/**/*`, `app/views/admin_users/**/*` |

## Top-Level Screen Tree

```text
today.bike
├── Public
│   ├── Home
│   ├── Service detail pages
│   ├── Blog
│   │   ├── Blog index
│   │   └── Blog detail
│   ├── Gallery
│   ├── Products
│   │   ├── Product index
│   │   └── Product detail
│   ├── Rentals
│   │   ├── Rental index
│   │   ├── Rental detail
│   │   └── Booking confirmation
│   ├── Bicycle passport
│   └── Sitemap / health
├── Portal
│   ├── Login
│   ├── My bicycles
│   │   ├── Bicycle index
│   │   └── Bicycle detail
│   ├── My service orders
│   │   ├── Service order index
│   │   └── Service order detail
│   └── My fitting records
│       ├── Fitting record index
│       └── Fitting record detail
└── Admin
    ├── Dashboard
    ├── Customers
    │   ├── Index / search
    │   ├── New / edit
    │   ├── Detail
    │   └── Customer bicycles
    ├── Bicycles
    │   ├── Index / search
    │   ├── New / edit
    │   ├── Detail
    │   ├── QR code / print
    │   ├── Bicycle specs
    │   └── Fitting records
    ├── Service orders
    │   ├── Index
    │   ├── Kanban board
    │   ├── New / edit
    │   ├── Detail
    │   ├── Progress tab
    │   ├── Photos tab
    │   ├── Repairs tab
    │   ├── Parts tab
    │   ├── Upgrades tab
    │   └── Frame changes tab
    ├── CSV imports
    ├── Blog posts
    ├── Products
    ├── Rentals
    │   └── Rental bookings
    └── Admin auth screens
```

## Public IA

### 1. Brand and discovery

| Screen | Route | Main action | View/controller evidence |
|---|---|---|---|
| Home | `/` | Introduce shop, services, and entry into other public pages | `config/routes.rb`, `app/controllers/pages_controller.rb`, `app/views/pages/home.html.erb` |
| Service detail | `/services/:service_type` | Explain a specific service type such as maintenance, repair, fitting, or upgrade | `config/routes.rb`, `app/controllers/pages_controller.rb`, `app/views/pages/service.html.erb` |
| Blog index | `/blog` | Browse published posts by content category | `config/routes.rb`, `app/controllers/blog_controller.rb`, `app/views/blog/index.html.erb` |
| Blog detail | `/blog/:slug` | Read a single post | `config/routes.rb`, `app/controllers/blog_controller.rb`, `app/views/blog/show.html.erb` |
| Gallery | `/gallery` | Browse before/after visual portfolio | `config/routes.rb`, `app/controllers/gallery_controller.rb`, `app/views/gallery/index.html.erb` |

### 2. Commerce and inquiry

| Screen | Route | Main action | View/controller evidence |
|---|---|---|---|
| Product index | `/products` | Browse parts catalog | `config/routes.rb`, `app/controllers/products_controller.rb`, `app/views/products/index.html.erb` |
| Product detail | `/products/:id` | Inspect product detail and likely move toward Kakao inquiry or purchase intent | `config/routes.rb`, `app/controllers/products_controller.rb`, `app/views/products/show.html.erb` |
| Rental index | `/rentals` | Browse available rental items | `config/routes.rb`, `app/controllers/rentals_controller.rb`, `app/views/rentals/index.html.erb` |
| Rental detail | `/rentals/:id` | Review a rental item and submit a booking request | `config/routes.rb`, `app/controllers/rentals_controller.rb`, `app/views/rentals/show.html.erb` |
| Booking confirmation | `/rentals/:id/booking_confirmation` | Confirm booking submission | `config/routes.rb`, `app/controllers/rentals_controller.rb`, `app/views/rentals/booking_confirmation.html.erb` |

### 3. Trust surfaces

| Screen | Route | Main action | View/controller evidence |
|---|---|---|---|
| Bicycle passport | `/passport/:token` | Show a bike-specific public service history via tokenized link | `config/routes.rb`, `app/controllers/passports_controller.rb`, `app/views/passports/show.html.erb`, `app/views/layouts/passport.html.erb` |
| Sitemap | `/sitemap.xml` | Expose public crawlable URLs | `config/routes.rb`, `app/controllers/sitemap_controller.rb`, `app/views/sitemap/index.xml.builder` |
| Health check | `/up` | Operational health endpoint, not user navigation | `config/routes.rb` |

## Portal IA

Portal screens are protected by `Portal::BaseController`, which redirects unauthenticated users to `/portal/login` and applies the `portal` layout.

| Screen | Route | Main action | Evidence |
|---|---|---|---|
| Portal login | `/portal/login` | Start customer authentication flow | `config/routes.rb`, `app/controllers/portal/sessions_controller.rb`, `app/views/portal/sessions/new.html.erb` |
| Kakao callback | `/portal/auth/kakao/callback` | Complete social login and session binding | `config/routes.rb`, `app/controllers/portal/sessions_controller.rb` |
| Portal home | `/portal` | Lands on bicycle index rather than a separate dashboard | `config/routes.rb` |
| My bicycles | `/portal/bicycles` | Browse owned bicycles | `app/controllers/portal/bicycles_controller.rb`, `app/views/portal/bicycles/index.html.erb` |
| Bicycle detail | `/portal/bicycles/:id` | Review current bike detail | `app/controllers/portal/bicycles_controller.rb`, `app/views/portal/bicycles/show.html.erb` |
| My service orders | `/portal/service_orders` | Review service history timeline / list | `app/controllers/portal/service_orders_controller.rb`, `app/views/portal/service_orders/index.html.erb` |
| Service order detail | `/portal/service_orders/:id` | Review a specific service order, photos, and progress detail | `app/controllers/portal/service_orders_controller.rb`, `app/views/portal/service_orders/show.html.erb`, `app/views/portal/service_orders/_service_order_detail.html.erb` |
| My fitting records | `/portal/fitting_records` | Browse fitting history | `app/controllers/portal/fitting_records_controller.rb`, `app/views/portal/fitting_records/index.html.erb` |
| Fitting record detail | `/portal/fitting_records/:id` | Review a specific fitting record | `app/controllers/portal/fitting_records_controller.rb`, `app/views/portal/fitting_records/show.html.erb` |

## Admin IA

Admin screens are protected by Devise via `authenticate_admin_user!` in `Admin::BaseController` and rendered with the `admin` layout.

### 1. Operations core

| Screen group | Routes | Main action | Evidence |
|---|---|---|---|
| Dashboard | `/admin` | Shop summary, recent work, stats | `app/controllers/admin/dashboard_controller.rb`, `app/views/admin/dashboard/index.html.erb` |
| Customers | `/admin/customers/*` | CRUD customer records and inspect linked bicycles | `app/controllers/admin/customers_controller.rb`, `app/views/admin/customers/*` |
| Bicycles | `/admin/bicycles/*` | CRUD bicycles, manage photos, QR output, nested specs and fitting | `app/controllers/admin/bicycles_controller.rb`, `app/views/admin/bicycles/*`, `app/views/admin/bicycle_specs/*`, `app/views/admin/fitting_records/*` |
| Service orders | `/admin/service_orders/*` | Create and track service work, status changes, and nested work artifacts | `app/controllers/admin/service_orders_controller.rb`, `app/views/admin/service_orders/*` |
| Service order status board | `/admin/service_orders/kanban` | Track and move service order state on kanban | `app/controllers/admin/service_orders_controller.rb`, `app/views/admin/service_orders/kanban.html.erb`, `app/views/admin/service_orders/update_status.turbo_stream.erb` |
| CSV imports | `/admin/imports/*` | Import customers and bicycles from CSV | `app/controllers/admin/imports_controller.rb`, `app/views/admin/imports/*` |

### 2. Service order detail sub-IA

The service order detail page behaves as a mini-application with multiple task tabs and nested create/edit flows.

| Detail area | Evidence | Notes |
|---|---|---|
| Basic info | `app/views/admin/service_orders/_tab_basic_info.html.erb` | Core order metadata |
| Progress | `app/views/admin/service_orders/_tab_progress.html.erb` | Tracks workflow stage |
| Photos | `app/views/admin/service_orders/_tab_photos.html.erb`, `app/views/admin/service_photos/*` | Upload and classify service photos |
| Repairs | `app/views/admin/service_orders/_tab_repairs.html.erb`, `app/views/admin/repair_logs/*` | Diagnosis and treatment logs |
| Parts | `app/views/admin/service_orders/_tab_parts.html.erb`, `app/views/admin/parts_replacements/*` | Parts replacement history |
| Upgrades | `app/views/admin/service_orders/_tab_upgrades.html.erb`, `app/views/admin/upgrades/*` | Upgrade records |
| Frame changes | `app/views/admin/service_orders/_tab_frame_changes.html.erb`, `app/views/admin/frame_changes/*` | Frame swap records |

### 3. Content and revenue surfaces

| Screen group | Routes | Main action | Evidence |
|---|---|---|---|
| Blog posts | `/admin/blog_posts/*` | Create and publish editorial content | `app/controllers/admin/blog_posts_controller.rb`, `app/views/admin/blog_posts/*` |
| Products | `/admin/products/*` | CRUD parts catalog entries | `app/controllers/admin/products_controller.rb`, `app/views/admin/products/*` |
| Rentals | `/admin/rentals/*` | CRUD rental items | `app/controllers/admin/rentals_controller.rb`, `app/views/admin/rentals/*` |
| Rental bookings | `/admin/rentals/:rental_id/rental_bookings/*` | Manage reservation records per rental item | `app/controllers/admin/rental_bookings_controller.rb`, `app/views/admin/rental_bookings/*` |

### 4. Admin auth surface

Devise-generated admin auth screens exist under `app/views/admin_users/**/*`. These support sign-in and password management but are not represented as custom product pages.

## Cross-Surface User Flows

### Visitor flow

1. Visitor lands on `Home`.
2. Visitor branches into `Services`, `Blog`, `Gallery`, `Products`, or `Rentals`.
3. Visitor converts through inquiry, booking, or trust surfaces such as `Passport`.

Evidence:
- `config/routes.rb`
- `app/views/pages/home.html.erb`
- `app/views/blog/index.html.erb`
- `app/views/products/show.html.erb`
- `app/views/rentals/show.html.erb`

### Customer flow

1. Customer enters via `Portal login`.
2. Authentication establishes session via portal sessions controller and Kakao callback path.
3. Customer browses owned bicycles, service orders, and fitting records from the portal home.
4. Customer drills into a service order or fitting record to inspect details.

Evidence:
- `app/controllers/portal/sessions_controller.rb`
- `app/controllers/portal/base_controller.rb`
- `app/controllers/portal/bicycles_controller.rb`
- `app/controllers/portal/service_orders_controller.rb`
- `app/controllers/portal/fitting_records_controller.rb`

### Admin flow

1. Admin signs in through Devise.
2. Admin lands on `Dashboard`.
3. Admin moves into customer intake, bicycle registration, service order tracking, imports, or content/commerce management.
4. Admin performs nested work inside service orders and bicycles rather than through a separate workflow engine.

Evidence:
- `app/controllers/admin/base_controller.rb`
- `app/controllers/admin/dashboard_controller.rb`
- `app/controllers/admin/customers_controller.rb`
- `app/controllers/admin/bicycles_controller.rb`
- `app/controllers/admin/service_orders_controller.rb`

## Implemented vs Unclear Surfaces

### Clearly implemented in code

- Public home and service pages
- Public blog, gallery, products, rentals
- Public bicycle passport
- Portal login and customer history views
- Admin CRUD for customers, bicycles, service orders, blog posts, products, rentals
- Admin import flow
- Admin service-order kanban and nested repair/photo/parts/upgrade/frame-change flows

### Present in docs but unclear or only partially visible from route/view inventory

| Doc expectation | Current signal | Notes |
|---|---|---|
| Portal dashboard as a separate entry screen | Not found | `/portal` resolves to bicycle index, not a distinct dashboard |
| Public shopping cart / full checkout | Not found | Public products have index/show only; no cart routes |
| Portal quote/estimate confirmation | Unclear from codebase | Service order views exist, but explicit estimate approval route is not visible |
| Customer notification center | Not found | Notifications exist in schema, but no user-facing notification route is visible |
| Public reservation board beyond rental booking | Not found | Rental reservation exists, broader booking/appointment UI is not visible |
| PWA entry points | Commented out | PWA files exist, but the routes are commented in `config/routes.rb` |

## IA Notes for Follow-Up Work

- The app is not three apps; it is one Rails monolith with clear access partitions. Later audits should preserve that framing.
- `ServiceOrder` detail is the densest screen cluster in the system and should be treated as a sub-IA when reviewing complexity.
- The portal currently behaves as a history viewer rooted in bicycles, not as a broader customer dashboard.
- The public site already combines brand, portfolio, commerce, and trust surfaces in one tree, which matters for later gap analysis.
