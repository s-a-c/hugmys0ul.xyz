# Implementation Plan: Integrated Commerce Platform

**Branch**: `001-integrated-commerce-platform` | **Date**: 2025-10-27 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-integrated-commerce-platform/spec.md`

## Summary

Build a multi-service Laravel 12 commerce platform with three independent services (CRM, E-commerce, ERP) plus a separate storefront frontend. Services communicate via REST APIs for queries and Laravel queues for async data synchronization. All services implement FilamentPHP admin panels. The platform supports 1,000 concurrent users, event-driven product/customer synchronization, comprehensive observability with distributed tracing, and maintains 90%+ test coverage with TDD workflow.

## Technical Context

**Language/Version**: PHP 8.2+ (target 8.4), Laravel 12  
**Primary Dependencies**: Laravel Framework, FilamentPHP, Livewire/Volt, Laravel Folio, spatie/laravel-query-builder, spatie/laravel-data, Laravel Sanctum, Lunar (headless e-commerce)  
**Storage**: PostgreSQL 16 (separate DB per service), Redis (queues/cache)  
**Testing**: Pest/PHPUnit with pestphp/pest-plugin-arch, minimum 90% coverage, PHPStan Level 10  
**Target Platform**: Containerized services (Podman/Docker), orchestrated via podman-compose.yml  
**Project Type**: Multi-service web application (3 backend services + 1 frontend SPA)  
**Performance Goals**: 
- P95 latency <500ms for service-to-service calls
- P95 latency <1s for storefront user-facing operations
- 1,000 sync jobs/minute throughput
- 1,000 concurrent users support

**Constraints**: 
- Event-driven synchronization for data consistency
- Stateless services for horizontal scaling
- PITR database backups (RPO: 15 minutes, RTO: 4 hours)
- PHPStan Level 10 compliance mandatory
- TDD workflow with user approval gates

**Scale/Scope**: 
- 3 backend services + 1 frontend application
- Thousands of products and customers at launch
- Distributed tracing across all service boundaries
- Centralized logging with correlation IDs
- Prometheus metrics for RED/USE monitoring

## Constitution Check

*Note: Project constitution is template-based. Applying pragmatic principles from AI guidelines and spec requirements:*

### I. Test-First Development (NON-NEGOTIABLE)
**Status**: ✅ **PASS** - TDD workflow mandated in spec and AI guidelines
- Tests written → User approved → Tests fail → Implement → Refactor
- 90% coverage minimum enforced
- Architecture tests via Pest plugin

### II. Multi-Service Architecture
**Status**: ✅ **PASS** - Clear service boundaries justified
- CRM: Customer relationship management
- ERP: Product inventory and fulfillment  
- E-commerce: Lunar-based checkout and orders
- Storefront: Separate frontend consuming headless APIs
- Each service has distinct domain responsibility
- Loose coupling via REST + async events

### III. Code Quality Standards
**Status**: ✅ **PASS** - Comprehensive quality gates specified
- PHPStan Level 10 mandatory
- Laravel Pint formatting
- Pest/PHPUnit testing framework
- Architecture testing for layer boundaries

### IV. Observability
**Status**: ✅ **PASS** - Detailed observability requirements
- Structured JSON logging (PSR-3 levels)
- Distributed tracing (W3C Trace Context)
- Prometheus metrics (RED for APIs, USE for resources)
- Centralized logging with correlation IDs

### V. Security & Data Protection
**Status**: ✅ **PASS** - Modern security practices specified
- Data encryption at rest (sensitive fields)
- API token authentication (Laravel Sanctum, scoped permissions)
- RBAC with FilamentShield
- Rate limiting, input validation, CSRF/XSS mitigation

### VI. Performance & Scalability
**Status**: ✅ **PASS** - Measurable targets defined
- Latency targets specified (<500ms service-to-service, <1s user-facing)
- Horizontal scalability via stateless design
- Queue-based async processing (1,000 jobs/min capacity)
- 1,000 concurrent users support

**Overall**: No constitutional violations. All principles aligned with spec requirements.

## Project Structure

### Documentation (this feature)

```text
specs/001-integrated-commerce-platform/
├── plan.md              # This file
├── research.md          # Phase 0: Technology decisions and patterns
├── data-model.md        # Phase 1: Entity schemas and relationships
├── quickstart.md        # Phase 1: Local development setup
├── contracts/           # Phase 1: API specifications (OpenAPI)
│   ├── crm-api.yaml
│   ├── ecommerce-api.yaml
│   ├── erp-api.yaml
│   └── storefront-api.yaml
└── tasks.md             # Phase 2: Hierarchical task breakdown (via /speckit.tasks)
```

### Source Code (repository root)

```text
services/
├── crm/                 # CRM Service (Laravel 12)
│   ├── app/
│   │   ├── Actions/     # Single-purpose operations
│   │   ├── Data/        # DTOs (spatie/laravel-data)
│   │   ├── Events/      # Domain events
│   │   ├── Exceptions/  # Custom domain exceptions
│   │   ├── Filament/    # Admin panel resources
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   ├── Middleware/
│   │   │   ├── Requests/  # Form requests for validation
│   │   │   └── Resources/ # API resources for JSON responses
│   │   ├── Jobs/        # Queue jobs
│   │   ├── Listeners/   # Event listeners
│   │   ├── Models/      # Eloquent models
│   │   ├── Policies/    # Authorization policies
│   │   └── Services/    # Complex business logic
│   ├── database/
│   │   ├── factories/
│   │   ├── migrations/  # One file per table/change
│   │   └── seeders/
│   ├── routes/
│   │   ├── api.php      # Versioned API routes (/api/v1/...)
│   │   └── web.php
│   ├── tests/
│   │   ├── Feature/     # Feature tests
│   │   ├── Unit/        # Unit tests
│   │   └── Architecture/ # Pest architecture tests
│   ├── composer.json
│   ├── phpstan.neon
│   ├── pint.json
│   └── Dockerfile
│
├── ecommerce/           # E-commerce Service (Laravel 12 + Lunar)
│   └── [same structure as CRM]
│
└── erp/                 # ERP Service (Laravel 12)
    └── [same structure as CRM]

storefront/              # Frontend SPA (framework TBD in research.md)
├── src/
│   ├── components/
│   ├── pages/
│   ├── services/        # API client for backend services
│   └── stores/          # State management
├── public/
├── tests/
└── package.json

podman-compose.yml       # Container orchestration (existing)
.github/
└── workflows/
    ├── code-quality.yml # Pint, PHPStan, Rector
    ├── tests.yml        # Pest test suite + coverage
    ├── build.yml        # Container builds → GHCR
    └── deploy.yml       # Staging/production deployment
```

**Structure Decision**: Multi-service web application with clear service boundaries. Each Laravel service is independently deployable with its own database. Storefront is a separate frontend consuming headless Lunar API from e-commerce service. This structure supports horizontal scaling, independent deployment cycles, and clear domain separation (CRM=customers, ERP=products, E-commerce=orders/checkout).

## Complexity Tracking

*No constitutional violations requiring justification.*
