# Implementation Plan: Integrated Commerce Platform (v4)

**Branch**: `001-integrated-commerce-platform` | **Date**: 2025-10-20 | **Spec**: [spec.md](./spec.md)

**Note**: This plan (v4) supersedes all previous versions. It has been significantly updated to incorporate a comprehensive suite of production-grade tooling for development, testing, and operations.

## Summary

This plan outlines the implementation strategy for the Integrated Commerce Platform. The project will create a unified system by integrating CRM, ERP, and E-commerce services within a monorepo. The core technical approach is a Service-Oriented Architecture (SOA) using an event-driven model. The stack is built on Laravel 12 and includes a full suite of best-in-class packages for administration, observability, and code quality.

## Architecture

-   **Architectural Style**: Event-Driven SOA.
-   **Core Principles**: Single Source of Truth (SSoT) and Domain-Driven Design (DDD).
-   **Core Services & Packages**:
    -   **CRM Service**: Manages Customers & Leads. **Package: `Liberu CRM`**
    -   **ERP Service**: Manages Products, Inventory & Financials. **Package: `Aureus ERP`**
    -   **E-commerce Service**: Manages Sales Orders & Pricing. **Package: `Lunar`**
-   **Storefront**: A separate, headless frontend application built with a modern JavaScript framework (e.g., React/Vue) located in the `/storefront` directory.

## Technical Context

-   **Language/Version**: PHP 8.4+
-   **Framework**: Laravel 12.x
-   **Admin Panel**: Filament v4.x
-   **Frontend**: Livewire (Volt & Flux) for admin panels; separate JS app for storefront.
-   **Database**: PostgreSQL 16+
-   **JavaScript Management**: pnpm Workspaces

## Core Tooling & Libraries

### Development & Code Quality
-   **Static Analysis**: `larastan/larastan` (PHPStan Level 10)
-   **Automated Refactoring**: `rector/rector`, `driftingly/rector-laravel`
-   **Code Style**: `laravel/pint` (PSR-12)
-   **Debug & Dev Experience**: `laravel/telescope`, `laravel/pail`, `laravel/boost`

### Testing
-   **Framework**: Pest v4 (`pestphp/pest-plugin-laravel`, `pestphp/pest-plugin-arch`, etc.)
-   **Coverage**: 100% test coverage is mandatory.

### Authentication & Authorization
-   **Backend Auth**: `laravel/fortify` (for headless auth)
-   **Permissions**: `spatie/laravel-permission`, `bezhansalleh/filament-shield`

### Asynchronous Processing & Search
-   **Queues**: `laravel/horizon`
-   **Search**: `laravel/scout`

### Operations & Observability
-   **Backups**: `spatie/laravel-backup`, `shuvroroy/filament-spatie-laravel-backup`
-   **Health Monitoring**: `spatie/laravel-health`, `shuvroroy/filament-spatie-laravel-health`
-   **Schedule Monitoring**: `spatie/laravel-schedule-monitor`, `mvenghaus/filament-plugin-schedule-monitor`
-   **Activity Logging**: `spatie/laravel-activitylog`

### General Utilities
-   **Feature Flags**: `laravel/pennant`
-   **Media Management**: `spatie/laravel-medialibrary`, `filament/spatie-laravel-media-library-plugin`
-   **Settings Management**: `spatie/laravel-settings`
-   **Model States**: `spatie/laravel-model-states`, `spatie/laravel-model-status`

## Constitution Check
**Result**: This plan is in full compliance with the Project Constitution v2.0.0.
