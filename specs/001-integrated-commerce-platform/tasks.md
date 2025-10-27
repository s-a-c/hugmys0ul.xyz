# Task List: Integrated Commerce Platform (v4)

**Feature**: Integrated Commerce Platform
**Branch**: `001-integrated-commerce-platform`
**Date**: 2025-10-27
**Input**: Generated from plan.md, spec.md, data-model.md, and contracts/

**Note**: This task list (v4) includes all P1 user stories (US1-7) with complete storefront integration and proper dependency ordering.

## Phase 1: Core Project & Service Setup

**Purpose**: Create monorepo structure, initialize services, and configure container orchestration

- [ ] T001 Create monorepo directory structure: `/services/crm`, `/services/ecommerce`, `/services/erp`, and `/storefront`
- [ ] T002 Create base `podman-compose.yml` defining backend services (CRM:8001, E-commerce:8002, ERP:8003), PostgreSQL databases (ports 5431-5433), Redis, and observability stack (Grafana, Prometheus)
- [ ] T003 [P] Create a base Laravel 12 project in `/services/crm` with PHP 8.2+ support
- [ ] T004 [P] Create a base Laravel 12 project in `/services/ecommerce` with PHP 8.2+ support
- [ ] T005 [P] Create a base Laravel 12 project in `/services/erp` with PHP 8.2+ support
- [ ] T006 [P] Initialize pnpm workspace in root with storefront project in `/storefront`

---

## Phase 2: Backend Dependencies & Configuration (Parallel)

**Purpose**: Install all required packages and publish configurations across all services

### Dependency Installation

- [ ] T007 [P] **CRM**: `composer require` Filament, Spatie packages (permission, activity-log, query-builder, data, model-states), Horizon, Telescope, Sanctum in `/services/crm`
- [ ] T008 [P] **E-commerce**: `composer require` Filament, Spatie packages, Horizon, Telescope, Sanctum, lunarphp/lunar in `/services/ecommerce`
- [ ] T009 [P] **ERP**: `composer require` Filament, Spatie packages, Horizon, Telescope, Sanctum in `/services/erp`

### Package Configuration

- [ ] T010 [P] **All Services**: Publish configuration files for `filament`, `horizon`, `telescope`, `sanctum`, `spatie/laravel-permission`, `spatie/laravel-query-builder`
- [ ] T011 [P] **All Services**: Run installation commands for `filament-shield` (RBAC integration)
- [ ] T012 [P] **All Services**: Configure `laravel/horizon` as queue driver with Redis connection
- [ ] T013 [P] **All Services**: Configure structured JSON logging (PSR-3 levels) with correlation ID middleware
- [ ] T014 [P] **All Services**: Configure distributed tracing infrastructure (W3C Trace Context standard)

### Quality & Observability Setup

- [ ] T015 [P] **All Services**: Configure PHPStan Level 10 in `phpstan.neon` per service
- [ ] T016 [P] **All Services**: Configure Laravel Pint with project code style in `pint.json`
- [ ] T017 [P] **All Services**: Install Pest with Architecture plugin and configure in `tests/Pest.php`
- [ ] T018 [P] **All Services**: Configure Prometheus metrics endpoints at `/metrics` per service

**Checkpoint**: Foundation infrastructure complete - all services have base packages and tooling configured

---

## Phase 3: Foundational - Database & Core Models

**Purpose**: Create database schemas, base models, and shared infrastructure required by all user stories

### Database Migrations (Per Service)

- [ ] T019 [P] **ERP**: Create migration `create_products_table` in `/services/erp/database/migrations/` (sku unique, name, description, images json, base_price, cost, supplier_info)
- [ ] T020 [P] **ERP**: Create migration `create_inventory_table` in `/services/erp/database/migrations/` (sku FK, quantity_on_hand)
- [ ] T021 [P] **CRM**: Create migration `create_customers_table` in `/services/crm/database/migrations/` (ulid primary, full_name encrypted, email encrypted unique, shipping_address encrypted, billing_address encrypted)
- [ ] T022 [P] **E-commerce**: Create migration `create_orders_table` in `/services/ecommerce/database/migrations/` (ulid primary, customer_id FK, order_date, status enum, shipping_info, total_price)
- [ ] T023 [P] **E-commerce**: Create migration `create_order_items_table` in `/services/ecommerce/database/migrations/` (order_id FK, product_sku FK, quantity, price_at_purchase)
- [ ] T024 [P] **ERP**: Create migration `create_invoices_table` in `/services/erp/database/migrations/` (ulid primary, order_id FK, invoice_date, due_date, amount, status enum)

### Base Models & Data Transfer Objects

- [ ] T025 [P] **ERP**: Create `Product` model in `/services/erp/app/Models/Product.php` with spatie/laravel-data DTO for sync payloads
- [ ] T026 [P] **ERP**: Create `Inventory` model in `/services/erp/app/Models/Inventory.php` with relationship to Product
- [ ] T027 [P] **CRM**: Create `Customer` model in `/services/crm/app/Models/Customer.php` with encrypted casts and sync DTO
- [ ] T028 [P] **E-commerce**: Create `Order` model with spatie/laravel-model-states in `/services/ecommerce/app/Models/Order.php` (states: pending→processing→shipped→completed, cancellable from pending/processing only)
- [ ] T029 [P] **E-commerce**: Create `OrderItem` model in `/services/ecommerce/app/Models/OrderItem.php`
- [ ] T030 [P] **ERP**: Create `Invoice` model with spatie/laravel-model-states in `/services/erp/app/Models/Invoice.php` (states: draft→sent→paid, voidable from draft/sent only)

### Shared Infrastructure

- [ ] T031 [P] **All Services**: Create base `ApiController` with query-builder integration in `app/Http/Controllers/Api/` per service
- [ ] T032 [P] **All Services**: Create custom exception handler for domain exceptions in `app/Exceptions/Handler.php` per service
- [ ] T033 [P] **All Services**: Create correlation ID middleware in `app/Http/Middleware/CorrelationId.php` per service
- [ ] T034 [P] **All Services**: Create base Filament resource classes with shield authorization in `app/Filament/Resources/` per service

### Data Seeding (SSoT-compliant)

- [ ] T035 **CRM**: Create `CustomerSeeder` in `/services/crm/database/seeders/CustomerSeeder.php` (generate thousands of customers with encrypted PII)
- [ ] T036 **ERP**: Create `ProductSeeder` in `/services/erp/database/seeders/ProductSeeder.php` (generate thousands of products with inventory)
- [ ] T037 Create master seeder orchestrating SSoT-compliant seeding: CRM→Customers, ERP→Products

**Checkpoint**: Database schemas exist, base models created, shared infrastructure ready - user story implementation can begin

---

## Phase 4: User Story 1 - Product Synchronization (Priority: P1) 🎯

**Goal**: Admin creates/updates a product in ERP → Product syncs to E-commerce service via event-driven queue job

**Independent Test**: Create product in ERP Filament panel → Verify product appears in E-commerce database with matching data

### Implementation

- [ ] T038 [US1] Create `ProductUpdated` event in `/services/erp/app/Events/ProductUpdated.php` with product DTO payload
- [ ] T039 [US1] Create `ProductUpdatedListener` in `/services/erp/app/Listeners/ProductUpdatedListener.php` that dispatches sync job
- [ ] T040 [US1] Create `SyncProductToEcommerce` job in `/services/erp/app/Jobs/SyncProductToEcommerce.php` with retry backoff (10s, 1m, 10m, 1hr, 3hr) and API client logic
- [ ] T041 [US1] Register event-listener binding in `/services/erp/app/Providers/EventServiceProvider.php`
- [ ] T042 [US1] Create API endpoint `POST /api/v1/products` in `/services/ecommerce/app/Http/Controllers/Api/ProductController.php` with Sanctum auth and validation
- [ ] T043 [US1] Add product sync route to `/services/ecommerce/routes/api.php` with token scope check
- [ ] T044 [US1] Create `ProductResource` Filament panel in `/services/erp/app/Filament/Resources/ProductResource.php` for CRUD operations
- [ ] T045 [US1] Add activity logging to Product model observer in `/services/erp/app/Observers/ProductObserver.php`
- [ ] T046 [US1] Configure inter-service API token for ERP→E-commerce in `.env` files

**Checkpoint**: Products created in ERP automatically sync to E-commerce service - MVP core functionality working

---

## Phase 5: User Story 2 - Customer Synchronization (Priority: P1)

**Goal**: Admin creates/updates customer in CRM → Customer syncs to E-commerce service for order association

**Independent Test**: Create customer in CRM Filament panel → Verify customer record in E-commerce database with encrypted PII

### Implementation

- [ ] T047 [US2] Create `CustomerUpdated` event in `/services/crm/app/Events/CustomerUpdated.php` with customer DTO (id, full_name, email, addresses)
- [ ] T048 [US2] Create `CustomerUpdatedListener` in `/services/crm/app/Listeners/CustomerUpdatedListener.php` dispatching sync job
- [ ] T049 [US2] Create `SyncCustomerToEcommerce` job in `/services/crm/app/Jobs/SyncCustomerToEcommerce.php` with retry backoff
- [ ] T050 [US2] Create API endpoint `POST /api/v1/customers` in `/services/ecommerce/app/Http/Controllers/Api/CustomerController.php` with validation
- [ ] T051 [US2] Add customer sync route to `/services/ecommerce/routes/api.php`
- [ ] T052 [US2] Create `CustomerResource` Filament panel in `/services/crm/app/Filament/Resources/CustomerResource.php`
- [ ] T053 [US2] Configure inter-service API token for CRM→E-commerce in `.env` files

**Checkpoint**: Customers created in CRM automatically sync to E-commerce - bidirectional data flow established

---

## Phase 6: User Story 3 - Order-to-Invoice Flow (Priority: P1)

**Goal**: Order reaches 'processing' state in E-commerce → Invoice auto-generated in ERP

**Independent Test**: Create order in E-commerce and transition to 'processing' → Verify invoice created in ERP

### Implementation

- [ ] T054 [US3] Create `OrderStateChanged` event in `/services/ecommerce/app/Events/OrderStateChanged.php`
- [ ] T055 [US3] Create `CreateInvoiceForOrder` job in `/services/ecommerce/app/Jobs/CreateInvoiceForOrder.php` (triggered on order→processing transition)
- [ ] T056 [US3] Create API endpoint `POST /api/v1/invoices` in `/services/erp/app/Http/Controllers/Api/InvoiceController.php`
- [ ] T057 [US3] Add invoice creation route to `/services/erp/routes/api.php`
- [ ] T058 [US3] Create `InvoiceResource` Filament panel in `/services/erp/app/Filament/Resources/InvoiceResource.php`
- [ ] T059 [US3] Configure inter-service API token for E-commerce→ERP in `.env` files

**Checkpoint**: Backend services fully integrated - product/customer sync + order-invoice workflow complete

---

## Phase 7: User Story 4 - Inventory Management (Priority: P1)

**Goal**: Admin manages inventory in ERP → Real-time stock levels available for e-commerce operations

**Independent Test**: Update inventory quantity in ERP → Verify quantity reflects in e-commerce product availability checks

### Implementation

- [ ] T060 [US4] Create `InventoryUpdated` event in `/services/erp/app/Events/InventoryUpdated.php`
- [ ] T061 [US4] Create `SyncInventoryToEcommerce` job in `/services/erp/app/Jobs/SyncInventoryToEcommerce.php`
- [ ] T062 [US4] Create API endpoint `PATCH /api/v1/products/{sku}/inventory` in `/services/ecommerce/app/Http/Controllers/Api/InventoryController.php`
- [ ] T063 [US4] Add inventory sync route to `/services/ecommerce/routes/api.php`
- [ ] T064 [US4] Add inventory management to `ProductResource` in ERP Filament panel
- [ ] T065 [US4] Create stock availability check helper in `/services/ecommerce/app/Services/InventoryService.php`

**Checkpoint**: Backend services complete with real-time inventory synchronization

---

## Phase 8: Storefront Setup & Infrastructure (Priority: P1)

**Purpose**: Initialize frontend application and configure API integration

- [ ] T066 [P] Create Next.js 14+ project in `/storefront` with App Router and TypeScript
- [ ] T067 [P] Install frontend dependencies: TanStack Query, Axios, Zod, React Hook Form, Tailwind CSS in `/storefront`
- [ ] T068 [P] Configure API client with correlation ID headers in `/storefront/lib/api-client.ts`
- [ ] T069 [P] Create authentication context using Laravel Sanctum cookie-based auth in `/storefront/contexts/AuthContext.tsx`
- [ ] T070 [P] Configure environment variables for E-commerce API URL in `/storefront/.env.local`
- [ ] T071 [P] Create base layout components in `/storefront/components/layout/`
- [ ] T072 [P] Configure CORS in E-commerce service for storefront origin in `/services/ecommerce/config/cors.php`

**Checkpoint**: Storefront project initialized and connected to E-commerce API

---

## Phase 9: User Story 5 - Product Discovery (Priority: P1) 🎯 Storefront MVP

**Goal**: Customer browses paginated product list, filters by category, searches products

**Independent Test**: Visit `/products` → See product list → Use search → Use filters → Verify results update

### Backend API (E-commerce Service)

- [ ] T073 [US5] Create `GET /api/v1/products` endpoint in `/services/ecommerce/app/Http/Controllers/Api/ProductController.php` using spatie/laravel-query-builder with filters (`?filter[category]=electronics`), sorting (`?sort=-created_at`), field selection (`?fields[products]=name,price`), relationship includes (`?include=category,inventory`)
- [ ] T074 [US5] Add product listing route to `/services/ecommerce/routes/api.php` (public, no auth)
- [ ] T075 [US5] Create product search indexes if using Scout in `/services/ecommerce/config/scout.php`

### Frontend (Storefront)

- [ ] T076 [P] [US5] Create product list page in `/storefront/app/products/page.tsx` with server-side data fetching
- [ ] T077 [P] [US5] Create `ProductCard` component in `/storefront/components/products/ProductCard.tsx`
- [ ] T078 [P] [US5] Create `ProductFilters` component in `/storefront/components/products/ProductFilters.tsx`
- [ ] T079 [P] [US5] Create `ProductSearch` component in `/storefront/components/products/ProductSearch.tsx`
- [ ] T080 [US5] Create product API hooks using TanStack Query in `/storefront/hooks/useProducts.ts`
- [ ] T081 [US5] Implement pagination UI in product list page

**Checkpoint**: Customers can browse, search, and filter products - core storefront discovery working

---

## Phase 10: User Story 6 - Account Management (Priority: P1)

**Goal**: Customer registers via Socialite, logs in, views order history

**Independent Test**: Register with OAuth provider → Login → Visit account page → See order list

### Backend API (E-commerce Service)

- [ ] T082 [US6] Install and configure Laravel Socialite in `/services/ecommerce/composer.json` with OAuth providers
- [ ] T083 [US6] Create Socialite callback routes in `/services/ecommerce/routes/web.php`
- [ ] T084 [US6] Create `GET /api/v1/orders` endpoint in `/services/ecommerce/app/Http/Controllers/Api/OrderController.php` with Sanctum auth filtering by authenticated customer
- [ ] T085 [US6] Create `GET /api/v1/user` endpoint returning authenticated customer data in `/services/ecommerce/app/Http/Controllers/Api/AuthController.php`

### Frontend (Storefront)

- [ ] T086 [P] [US6] Create login page in `/storefront/app/login/page.tsx` with OAuth provider buttons
- [ ] T087 [P] [US6] Create registration flow in `/storefront/app/register/page.tsx`
- [ ] T088 [P] [US6] Create account page in `/storefront/app/account/page.tsx` with order history
- [ ] T089 [P] [US6] Create `OrderList` component in `/storefront/components/account/OrderList.tsx`
- [ ] T090 [US6] Implement protected route middleware in `/storefront/middleware.ts`
- [ ] T091 [US6] Create authentication API hooks in `/storefront/hooks/useAuth.ts`

**Checkpoint**: Customer authentication and account management working - users can register and view their data

---

## Phase 11: User Story 7 - Checkout Flow (Priority: P1) 🎯 Complete MVP

**Goal**: Customer adds product to cart, proceeds to checkout, enters shipping/payment, completes purchase

**Independent Test**: Add product to cart → Go to checkout → Fill shipping/billing → Submit payment → See confirmation

### Backend API (E-commerce Service)

- [ ] T092 [US7] Install Lunar cart and checkout packages in `/services/ecommerce/composer.json`
- [ ] T093 [US7] Create `POST /api/v1/cart/items` endpoint in `/services/ecommerce/app/Http/Controllers/Api/CartController.php`
- [ ] T094 [US7] Create `GET /api/v1/cart` endpoint returning current cart with items
- [ ] T095 [US7] Create `DELETE /api/v1/cart/items/{id}` endpoint for removing cart items
- [ ] T096 [US7] Create `POST /api/v1/checkout` endpoint in `/services/ecommerce/app/Http/Controllers/Api/CheckoutController.php` with payment gateway integration
- [ ] T097 [US7] Implement payment webhook handler in `/services/ecommerce/app/Http/Controllers/Api/WebhookController.php`
- [ ] T098 [US7] Create order confirmation email notification in `/services/ecommerce/app/Notifications/OrderConfirmation.php`
- [ ] T099 [US7] Implement external payment retry logic (3 attempts) in checkout controller

### Frontend (Storefront)

- [ ] T100 [P] [US7] Create cart context for global state in `/storefront/contexts/CartContext.tsx`
- [ ] T101 [P] [US7] Create cart page in `/storefront/app/cart/page.tsx`
- [ ] T102 [P] [US7] Create checkout page in `/storefront/app/checkout/page.tsx` with multi-step form
- [ ] T103 [P] [US7] Create `CheckoutForm` component in `/storefront/components/checkout/CheckoutForm.tsx` with validation (React Hook Form + Zod)
- [ ] T104 [P] [US7] Create `PaymentForm` component in `/storefront/components/checkout/PaymentForm.tsx`
- [ ] T105 [P] [US7] Create order confirmation page in `/storefront/app/orders/[id]/confirmation/page.tsx`
- [ ] T106 [US7] Create cart API hooks in `/storefront/hooks/useCart.ts`
- [ ] T107 [US7] Implement "Add to Cart" button in product pages
- [ ] T108 [US7] Add loading states and error handling for checkout flow

**Checkpoint**: Complete e-commerce flow working - customers can purchase products end-to-end 🎉 FULL MVP COMPLETE

---

## Phase 12: Polish & Cross-Cutting Concerns

**Purpose**: Production readiness, performance optimization, comprehensive error handling

### Error Handling & Resilience

- [ ] T109 [P] **All Services**: Implement soft-delete for all sync operations (never hard-delete via sync)
- [ ] T110 [P] **All Services**: Add validation error logging and admin notifications for sync payload rejections
- [ ] T111 [P] **E-commerce**: Implement fallback UI for external service failures in storefront
- [ ] T112 Create failed jobs dashboard in Horizon for manual intervention

### Observability & Monitoring

- [ ] T113 [P] **All Services**: Add RED metrics collection (Rate, Errors, Duration) for all API endpoints
- [ ] T114 [P] **All Services**: Verify distributed tracing working across all service boundaries
- [ ] T115 Configure Grafana dashboards for system health monitoring
- [ ] T116 Create alerting rules for critical errors and performance degradation

### Testing & Quality

- [ ] T117 [P] Run Architecture tests across all services (layer boundaries, naming conventions)
- [ ] T118 [P] Run PHPStan Level 10 analysis on all services
- [ ] T119 [P] Run Laravel Pint formatting on all services
- [ ] T120 Verify 90% test coverage threshold met (if tests were written)

### Documentation & Deployment

- [ ] T121 Update quickstart.md with complete local development setup in `/specs/001-integrated-commerce-platform/quickstart.md`
- [ ] T122 Create API documentation from OpenAPI contracts in `/docs/api/`
- [ ] T123 Document deployment procedures for container registry (GHCR) in `/docs/deployment.md`
- [ ] T124 Verify database backup/restore procedures in staging environment

**Checkpoint**: Production-ready platform with complete observability, error handling, and documentation

---

## Dependencies & Execution Order

### Phase Dependencies

1. **Setup (Phase 1)** → No dependencies - start immediately
2. **Backend Dependencies (Phase 2)** → Depends on Phase 1 completion
3. **Foundational (Phase 3)** → Depends on Phase 2 completion - BLOCKS all user stories
4. **User Stories 1-4 (Phases 4-7)** → Depend on Phase 3 - Backend integration stories
5. **Storefront Setup (Phase 8)** → Depends on Phase 3 - Can run parallel to US1-4
6. **User Stories 5-7 (Phases 9-11)** → Depend on Phase 8 AND relevant backend APIs
7. **Polish (Phase 12)** → Depends on all desired user stories complete

### User Story Dependencies

**Backend Stories (Can run in parallel after Phase 3)**:
- US1 (Product Sync): Independent
- US2 (Customer Sync): Independent  
- US3 (Order-Invoice): Requires US1 and US2 complete
- US4 (Inventory): Requires US1 complete

**Storefront Stories (Sequential after Phase 8)**:
- US5 (Product Discovery): Requires US1 API complete
- US6 (Account Management): Requires US2 API complete
- US7 (Checkout): Requires US1, US2, US3, US4 APIs complete

### Parallel Opportunities

- Phase 2: All service configuration tasks [P] can run simultaneously
- Phase 3: All migrations [P], all models [P], all seeders can run parallel within their groups
- Phases 4-7: US1, US2, US4 can be worked on in parallel by different developers
- Phase 9-11: Frontend component tasks [P] within each story can run parallel

---

## Implementation Strategy

### MVP-First (Recommended)

**Iteration 1 - Backend Core**:
1. Complete Phases 1-3 (Setup + Foundational)
2. Complete Phase 4 (US1 - Product Sync)
3. **VALIDATE**: Create product in ERP → Verify in E-commerce DB
4. MVP backend achieved - single data flow working

**Iteration 2 - Full Backend Integration**:
1. Complete Phase 5 (US2 - Customer Sync)
2. Complete Phase 6 (US3 - Order-Invoice)
3. Complete Phase 7 (US4 - Inventory)
4. **VALIDATE**: Full backend workflow - products, customers, orders, inventory, invoices
5. Backend platform complete

**Iteration 3 - Storefront MVP**:
1. Complete Phase 8 (Storefront Setup)
2. Complete Phase 9 (US5 - Product Discovery)
3. **VALIDATE**: Public can browse products
4. Minimal viable storefront achieved

**Iteration 4 - Complete E-commerce**:
1. Complete Phase 10 (US6 - Account Management)
2. Complete Phase 11 (US7 - Checkout)
3. **VALIDATE**: End-to-end purchase flow
4. 🎉 **FULL PLATFORM MVP COMPLETE** - customers can browse and purchase products

**Iteration 5 - Production Ready**:
1. Complete Phase 12 (Polish)
2. Production deployment

### Parallel Team Strategy

With 3 developers available:

**After Phase 3 complete**:
- Developer A: US1 + US4 (Product & Inventory - same service)
- Developer B: US2 (Customer Sync)
- Developer C: Storefront Setup (Phase 8)

**After Backend APIs complete**:
- Developer A: US5 (Product Discovery frontend)
- Developer B: US6 (Account Management frontend)
- Developer C: US3 (Order-Invoice backend)

**Final Sprint**:
- All developers: US7 (Checkout - complex, benefits from pairing)
- All developers: Phase 12 (Polish - distributed tasks)

---

## Success Metrics

### MVP Completion Criteria (Phases 1-11)

- [ ] Product created in ERP appears in E-commerce database
- [ ] Customer created in CRM appears in E-commerce database
- [ ] Order in 'processing' state generates invoice in ERP
- [ ] Inventory update in ERP reflects in E-commerce availability
- [ ] Public can browse and search products on storefront
- [ ] Customer can register, login, view order history
- [ ] Customer can add to cart, checkout, complete purchase
- [ ] All services logging to centralized system with correlation IDs
- [ ] Distributed tracing working across all service calls
- [ ] PHPStan Level 10 passes on all services

### Production Readiness Criteria (Phase 12)

- [ ] Failed job retry backoff working (10s, 1m, 10m, 1hr, 3hr)
- [ ] Soft-delete working for all sync operations
- [ ] External payment retry (3 attempts) working
- [ ] Grafana dashboards showing RED metrics for all services
- [ ] Database backups configured and tested
- [ ] API documentation generated from contracts
- [ ] Deployment procedures documented

---

## Task Summary

- **Total Tasks**: 124
- **Phase 1 (Setup)**: 6 tasks (4 parallelizable)
- **Phase 2 (Dependencies)**: 12 tasks (all parallelizable)
- **Phase 3 (Foundational)**: 19 tasks (most parallelizable)
- **Phase 4 (US1)**: 9 tasks
- **Phase 5 (US2)**: 7 tasks
- **Phase 6 (US3)**: 6 tasks
- **Phase 7 (US4)**: 6 tasks
- **Phase 8 (Storefront Setup)**: 7 tasks (all parallelizable)
- **Phase 9 (US5)**: 9 tasks (5 parallelizable)
- **Phase 10 (US6)**: 10 tasks (5 parallelizable)
- **Phase 11 (US7)**: 17 tasks (8 parallelizable)
- **Phase 12 (Polish)**: 16 tasks (10 parallelizable)

**Parallel Opportunities**: 49 tasks marked [P] can run simultaneously within their phase
**User Story Tasks**: 64 tasks directly implement user stories (marked with [US1]-[US7])

---

## Notes

- All tasks follow format: `- [ ] [TaskID] [P?] [Story?] Description with file path`
- [P] indicates tasks can run in parallel (different files, no dependencies)
- [Story] label maps task to specific user story for traceability
- Tests are referenced but not generated as individual tasks (TDD process applies at execution time)
- Stop at any checkpoint to validate independently
- Commit after each task or logical group
- Use correlation IDs to trace requests across services
- Validate backoff strategies and retry logic work correctly
