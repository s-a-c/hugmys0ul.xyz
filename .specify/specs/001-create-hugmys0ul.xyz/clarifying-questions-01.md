# Clarifying Questions for hugmys0ul.xyz Development Standards

**Date**: 2025-10-27
**Purpose**: Document architectural and convention decisions for spec-kit processing
**Related**: AI Guidelines update for PHP-Laravel conventions

## 1. API Architecture

### 1.1. API Type
- **Question**: Will services expose REST APIs, GraphQL, or both?
- **Answer**: REST

### 1.2. API Best Practices
- **Question**: Do you want API versioning (e.g., `/api/v1/`)?
- **Answer**: Best practice / Yes

### 1.3. API Resources
- **Question**: Should we use Laravel API Resources for transformations?
- **Answer**: Yes

### 1.4. Form Request Validation
- **Question**: Form Request validation for all API inputs?
- **Answer**: Yes

## 2. Code Organization

### 2.1. Service Layer
- **Question**: Should we document Service Layer for business logic (e.g., `app/Services/`)?
- **Answer**: Service

### 2.2. Action Classes
- **Question**: Should we use single-purpose action classes (e.g., `app/Actions/CreateCustomerAction`)?
- **Answer**: Action

### 2.3. Repository Pattern
- **Question**: Repository Pattern for database abstraction or use Eloquent directly?
- **Answer**: Eloquent by default with repository pattern when benefits of further abstraction are clear; include advice on how to determine

### 2.4. Data Transfer Objects (DTOs)
- **Question**: Should we use DTOs with packages like `spatie/laravel-data`?
- **Answer**: DTO

## 3. Laravel-Specific Patterns

### 3.1. Form Requests
- **Question**: Mandatory for all validation?
- **Answer**: Yes

### 3.2. Policies
- **Question**: For all authorization logic?
- **Answer**: Yes

### 3.3. Resources
- **Question**: API Resources for all JSON responses?
- **Answer**: Yes

### 3.4. Events & Listeners
- **Question**: For cross-cutting concerns?
- **Answer**: Yes

### 3.5. Jobs & Queues
- **Question**: Async processing standards?
- **Answer**: Yes

### 3.6. Middleware
- **Question**: Custom middleware conventions?
- **Answer**: Yes

## 4. Frontend Integration

### 4.1. FilamentPHP
- **Question**: Will you use FilamentPHP for admin panels?
- **Answer**: Yes

### 4.2. Livewire
- **Question**: Livewire for interactive components?
- **Answer**: Livewire/Volt SFC/Folio

### 4.3. Inertia.js
- **Question**: Inertia.js with Vue/React?
- **Answer**: [Not specified - TBD]

### 4.4. Blade Templates
- **Question**: Traditional Blade only or API-only with separate frontend?
- **Answer**: [Covered by Livewire/Volt/Folio answer]

## 5. Database Conventions

### 5.1. Migration Organization
- **Question**: Migration naming and organization standards?
- **Answer**: One migration per table/change with descriptive timestamps (e.g., `2025_10_27_000001_create_customers_table.php`)
- **Status**: ✅ Resolved (Session 2025-10-27)

### 5.2. Model Relationships
- **Question**: Model relationships documentation requirements?
- **Answer**: [TBD - spec-kit process]

### 5.3. Seeders and Factories
- **Question**: Seeders and Factories organization conventions?
- **Answer**: [TBD - spec-kit process]

### 5.4. Query Builder
- **Question**: Should we use `spatie/laravel-query-builder` for API filtering?
- **Answer**: Yes - `spatie/laravel-query-builder` for standardized filtering, sorting, and field selection
- **Status**: ✅ Resolved (Session 2025-10-27)

## 6. Inter-Service Communication

### 6.1. Communication Method
- **Question**: HTTP API calls between services?
- **Answer**: RESTful HTTP APIs for queries/commands + async events for data synchronization
- **Status**: ✅ Resolved (Session 2025-10-27)

### 6.2. Event-Driven Architecture
- **Question**: Event-driven with a message queue?
- **Answer**: Covered by 6.1 - Laravel queues for async events

### 6.3. Database Sharing
- **Question**: Shared database access (generally discouraged)?
- **Answer**: [TBD - spec-kit process]

### 6.4. Service Contracts
- **Question**: What about service contracts/interfaces?
- **Answer**: [TBD - spec-kit process]

## 7. Deployment & CI/CD

### 7.1. GitHub Actions Workflows
- **Question**: Should I create workflow templates for:
  - Running tests (PHPUnit/Pest)?
  - Code quality checks (Pint, PHPStan)?
  - Deployment automation?
  - Container builds?
- **Answer**: [TBD - spec-kit process]

### 7.2. Deployment Targets
- **Question**: What's your deployment target (staging, production environments)?
- **Answer**: [TBD - spec-kit process]

### 7.3. Container Registry
- **Question**: Where should container images be pushed (Docker Hub, GHCR, private registry)?
- **Answer**: GitHub Container Registry (GHCR) - integrated with this repository
- **Status**: ✅ Resolved (Session 2025-10-27)

## 8. Error Handling

### 8.1. Custom Exceptions
- **Question**: Custom exception classes standards?
- **Answer**: Custom domain exceptions with centralized handler (e.g., `CustomerNotFoundException`, `PaymentFailedException`)
- **Status**: ✅ Resolved (Session 2025-10-27)

### 8.2. Exception Strategy
- **Question**: Exception handling strategy (report vs. render)?
- **Answer**: [TBD - spec-kit process]

### 8.3. Error Tracking
- **Question**: Should we use packages like `spatie/laravel-ignition` enhancements or external services?
- **Answer**: [TBD - spec-kit process]

## Next Steps

1. Process answered items (1-4) to update `ai/AI-GUIDELINES/PHP-Laravel/`
2. Use spec-kit to clarify items 5-8
3. Document finalized conventions in AI guidelines
4. Create code examples and templates

## Notes

- Answers marked [TBD - spec-kit process] will be determined through github/spec-kit processes
- This document serves as input for architectural decision records
- Update this document as decisions are made through spec-kit workflow
