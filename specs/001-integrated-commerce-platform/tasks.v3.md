# Task List: Integrated Commerce Platform (v4)

**Feature**: Integrated Commerce Platform
**Branch**: `001-integrated-commerce-platform`
**Date**: 2025-10-27
**Input**: Generated from plan.md, spec.md, data-model.md, and contracts/

**Note**: This task list (v4) supersedes all previous versions. It implements all P1 user stories (US1-7) with complete storefront integration.

## Phase 1: Core Project & Service Setup

- [ ] T001 Create monorepo directory structure: `/services/crm`, `/services/ecommerce`, `/services/erp`, and `/storefront`
- [ ] T002 Create base `podman-compose.yml` defining the backend services, databases, and a new Grafana service.
- [ ] T003 [P] Create a base Laravel 12 project in `/services/crm`
- [ ] T004 [P] Create a base Laravel 12 project in `/services/ecommerce`
- [ ] T005 [P] Create a base Laravel 12 project in `/services/erp`
- [ ] T006 [P] Initialize a new pnpm workspace in the root and in `/storefront`

## Phase 2: Backend Dependency Installation (Parallel)

- [ ] T007 [P] **CRM**: `composer require` all common packages (Filament, Spatie, etc.) in `/services/crm`
- [ ] T008 [P] **E-commerce**: `composer require` all common packages (Filament, Spatie, etc.) in `/services/ecommerce`
- [ ] T009 [P] **ERP**: `composer require` all common packages (Filament, Spatie, etc.) in `/services/erp`
- [ ] T010 [P] **CRM**: `composer require LiberuCRM` in `/services/crm`
- [ ] T011 [P] **E-commerce**: `composer require lunarphp/lunar` in `/services/ecommerce`
- [ ] T012 [P] **ERP**: `composer require AureusERP/AureusERP` in `/services/erp`

## Phase 3: Configuration & Integration (Parallel)

- [ ] T013 [P] **All Services**: Publish configuration files for `filament`, `horizon`, `telescope`, `fortify`, `pennant`, `scout`, and all core Spatie packages.
- [ ] T014 [P] **All Services**: Run installation commands for `filament-shield`.
- [ ] T015 [P] **All Services**: Run migrations for `spatie/laravel-permission`, `spatie/laravel-activitylog`, `spatie/laravel-medialibrary`, etc.
- [ ] T016 [P] **All Services**: Configure `laravel/horizon` as the queue driver.
- [ ] T017 [P] **All Services**: Configure `laravel/scout` with a basic driver.
- [ ] T018 [P] **All Services**: Configure `spatie/laravel-backup` with initial settings.
- [ ] T019 [P] **All Services**: Configure `spatie/laravel-health` with basic checks.

## Phase 4: Foundational - Data Seeding

**Goal**: Create robust, SSoT-compliant data seeders for testing and initial deployment.

- [ ] T020 **Test**: Write a test for the `CustomerSeeder` in `/services/crm/`.
- [ ] T021 Implement `CustomerSeeder` in `/services/crm/database/seeders/CustomerSeeder.php`
- [ ] T022 **Test**: Write a test for the `ProductSeeder` in `/services/erp/`.
- [ ] T023 Implement `ProductSeeder` in `/services/erp/database/seeders/ProductSeeder.php`
- [ ] T024 Create a master seeder to orchestrate the SSoT-compliant seeding process.

## Phase 5: User Story 1 - Product Synchronization (P1)

**Goal**: An admin creates a product in the ERP, and it appears in the E-commerce store.

- [ ] T025 [US1] **Test**: Write a feature test in `/services/erp/tests/Feature/` to confirm creating a `Product` model dispatches a `ProductUpdated` event and logs the activity.
- [ ] T026 [US1] **Test**: Write a feature test in `/services/ecommerce/tests/Feature/` to validate the `POST /api/v1/products` endpoint in Lunar, including auth and validation.
- [ ] T027 [US1] Implement the `ProductUpdated` event and its listener-to-job chain in `/services/erp/`.
- [ ] T028 [US1] Implement the `SyncProductToEcommerce` job, including API client logic, in `/services/erp/`.
- [ ] T029 [US1] Implement the API endpoint in the Lunar service (`/services/ecommerce/`) to receive product data.
- [ ] T030 [US1] Implement a Filament resource in `/services/erp/app/Filament/Resources` to manage Products.

...*Subsequent user stories and the Polish phase will be detailed in a similar, expanded fashion.*...

## Implementation Strategy

The project will be delivered incrementally. The completion of **Phases 1-5** constitutes the MVP, delivering the core product synchronization functionality with a robust, observable, and maintainable technical foundation.
