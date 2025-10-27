# hugmys0ul.xyz Constitution

## Core Principles

### I. Test-First Development (NON-NEGOTIABLE)

**TDD is mandatory for all production code.** No implementation code may be written before tests exist and have been approved by the user.

**Workflow**:

1. Write test plan describing expected behavior
2. Present test plan to user for approval
3. Write failing tests that validate the behavior
4. Run tests to confirm they fail (Red)
5. Implement minimal code to pass tests (Green)
6. Refactor while keeping tests passing (Refactor)
7. User approval required before committing

**Coverage Requirements**:

- Minimum 90% code coverage across all services
- 100% coverage for critical paths (authentication, payment processing, data synchronization)
- Architecture tests using `pestphp/pest-plugin-arch` to enforce layer boundaries

**Test Organization**:

```text
tests/
├── Architecture/   # Layer boundaries, naming conventions, dependency rules
├── Feature/        # HTTP endpoints, queue jobs, full user flows
└── Unit/           # Individual classes, pure functions, business logic
```

**Violations**: Code submitted without corresponding approved tests will be rejected at CI stage. No exceptions.

### II. Multi-Service Architecture with Clear Boundaries

**Services must have distinct domain responsibilities.** Each service owns its data and exposes it via well-defined APIs.

**Service Boundaries**:

- **CRM Service**: Customer relationship management, contact history, customer lifecycle
- **E-commerce Service**: Product catalog (Lunar), shopping cart, checkout, order management
- **ERP Service**: Product inventory (SSoT for products), fulfillment, invoicing, supplier management
- **Storefront**: Public-facing frontend consuming headless Lunar API

**Communication Rules**:

- Services communicate via RESTful HTTP APIs for synchronous queries (e.g., "get customer by ID")
- Services use Laravel queues for asynchronous data synchronization (e.g., product updates)
- No direct database access across service boundaries
- Each service has its own PostgreSQL database
- API contracts defined in OpenAPI 3.0 specifications

**Rationale**: Loose coupling enables independent scaling, deployment, and technology evolution per service.

### III. Code Quality Standards (NON-NEGOTIABLE)

**All code must pass strict static analysis before merge.**

**Quality Gates**:

- **PHPStan Level 10**: Maximum strictness, complete type coverage
- **Laravel Pint**: Automatic code formatting (Laravel preset)
- **Rector**: Automated refactoring and code modernization
- **Pest Architecture Tests**: Enforce naming conventions, layer boundaries, dependency rules

**CI Pipeline Requirements**:

```yaml
# .github/workflows/code-quality.yml
- PHPStan analysis (Level 10) MUST pass
- Pint formatting check MUST pass
- Pest test suite MUST pass with 90%+ coverage
- Architecture tests MUST pass
- No merge without green CI
```

**Violations**: Any code failing PHPStan Level 10 or architecture tests will be blocked at CI. Fix immediately or revert.

### IV. Observability (Required for Production)

**All services must be fully observable for debugging and performance monitoring.**

**Logging**:

- Structured JSON logs (PSR-3 log levels)
- Default log level: `INFO` (production), `DEBUG` (staging/local)
- Centralized logging via configurable backend (ELK, Loki, CloudWatch)
- Security events logged at `WARNING` or higher

**Distributed Tracing**:

- W3C Trace Context standard for propagation across service boundaries
- OpenTelemetry for vendor-neutral instrumentation
- Unique correlation ID on every request (propagated via HTTP headers and queue jobs)

**Metrics**:

- Prometheus-compatible exposition format
- **RED Metrics** for APIs: Rate (requests/sec), Errors (error rate), Duration (latency P50/P95/P99)
- **USE Metrics** for resources: Utilization, Saturation, Errors
- Queue depths and throughput for all async queues

**Rationale**: Text-based logs and structured metrics enable rapid debugging across distributed services.

### V. Security & Data Protection

**Security is a first-class concern, not an afterthought.**

**Encryption**:

- Sensitive data encrypted at rest (customer: `full_name`, `email`, `shipping_address`, `billing_address`)
- Laravel's encrypted casting for PII fields
- TLS/HTTPS mandatory for all inter-service communication

**Authentication & Authorization**:

- **Service-to-Service**: Laravel Sanctum API tokens with scoped permissions (principle of least privilege)
- **Storefront Users**: Socialite OAuth (Google, GitHub)
- **Admin Users**: Email/password + optional MFA

**RBAC**:

- FilamentShield for admin panel permissions
- Minimum roles: Administrator, Editor, Product Manager, Order Manager
- Granular permissions per resource action (view, create, update, delete)

**Input Validation**:

- Laravel Form Requests for all API inputs (strict schema validation)
- Sanitize output to prevent XSS
- CSRF protection enabled for web routes
- Rate limiting on authentication endpoints

**Violations**: Storing PII without encryption, exposing admin endpoints without auth, or missing input validation will fail security audit and block deployment.

### VI. Performance & Scalability

**The platform must handle specified load without degradation.**

**Performance Targets**:

- P95 latency <500ms for service-to-service API calls
- P95 latency <1 second for storefront user-facing operations
- 1,000 concurrent users supported
- Queue processing: 1,000 jobs/minute throughput

**Scalability Design**:

- All services are stateless (no in-memory session storage)
- Horizontal scaling via container replication
- Database connection pooling
- Redis for caching and queue backend (with Laravel Horizon)

**Optimization Requirements**:

- Eager loading to prevent N+1 queries (`with()` on Eloquent models)
- Database indexes on foreign keys and frequently queried fields
- Query result caching where appropriate
- Async processing for non-critical operations (email, notifications)

**Violations**: Adding session state, using inefficient queries without indexes, or blocking operations on main request thread will fail performance review.

## Additional Standards

### Database Conventions

**Migrations**:

- One migration per table or logical change (single responsibility)
- Descriptive timestamp naming: `2025_10_27_000001_create_customers_table.php`
- Atomic (wrapped in transaction)
- Reversible (functional `down()` method)

**Models**:

- Type hints on all properties and methods
- Use `spatie/laravel-data` for DTOs
- Custom domain exceptions (e.g., `CustomerNotFoundException`)
- Soft deletes for all entity records

**Queries**:

- Use `spatie/laravel-query-builder` for API filtering/sorting
- Eager load relationships to prevent N+1
- Use repository pattern only when multiple data sources or complex query logic requires abstraction

### Exception Handling

**Custom domain exceptions with centralized handler.**

**Pattern**:

```php
// app/Exceptions/CustomerNotFoundException.php
class CustomerNotFoundException extends DomainException {
    public function __construct(string $customerId) {
        parent::__construct("Customer {$customerId} not found", 404);
    }
}

// app/Exceptions/Handler.php
public function render($request, Throwable $e) {
    if ($e instanceof CustomerNotFoundException) {
        return response()->json([
            'error' => 'Customer not found',
            'message' => $e->getMessage(),
            'trace_id' => request()->header('X-Correlation-ID'),
        ], 404);
    }
}
```

### API Design

**RESTful conventions with versioning.**

- Base path: `/api/v1/`
- Resource-oriented URLs: `/api/v1/customers/{id}`
- Standard HTTP verbs: GET (read), POST (create), PUT/PATCH (update), DELETE (soft delete)
- JSON request/response bodies
- Pagination for list endpoints (50 items per page default)
- Use `spatie/laravel-query-builder` for filtering: `?filter[email]=example.com&sort=-created_at`

### Deployment

**Containerized services with CI/CD.**

- Dockerfiles for each service
- GitHub Container Registry (GHCR) for image storage
- Semantic versioning + commit SHA tags: `ghcr.io/<owner>/hugmys0ul-crm:v1.2.3`, `ghcr.io/<owner>/hugmys0ul-crm:sha-abc123`
- GitHub Actions workflows for CI/CD
- Staging environment for automatic deploys on main branch merge
- Production requires manual approval gate

## Development Workflow

### Feature Development

1. **Specification**: Write or update feature spec in `specs/###-feature/spec.md`
2. **Clarification**: Use `/speckit.clarify` to resolve ambiguities
3. **Planning**: Use `/speckit.plan` to generate implementation plan
4. **Tasks**: Use `/speckit.tasks` to create hierarchical task breakdown
5. **TDD Cycle**: For each task:
   - Write test plan → User approval
   - Write failing tests → Red
   - Implement minimal code → Green
   - Refactor → Keep tests passing
   - User approval before commit

### Git Workflow

- Feature branches: `###-feature-name` (e.g., `001-integrated-commerce-platform`)
- Commit messages: Conventional Commits format (`feat:`, `fix:`, `docs:`, `test:`)
- PR requires: Green CI, code review approval, user acceptance
- Squash merge to main

### Review Requirements

**All PRs must pass:**

- CI pipeline (tests, PHPStan, Pint)
- Architecture tests (layer boundaries)
- Code review (at least one approval)
- User acceptance for functional changes

## Governance

**This constitution supersedes all other practices and opinions.** Any conflict between this document and external advice must be resolved in favor of the constitution.

**Amendments**:

- Require documentation of rationale
- Require approval from project stakeholders
- Require migration plan for existing code

**Enforcement**:

- All PRs and code reviews must verify constitutional compliance
- CI pipeline enforces code quality gates
- Complexity and violations must be justified in writing

**Guidance**:

- See `/ai/AI-GUIDELINES/` for detailed coding standards
- See `specs/###-feature/plan.md` for feature-specific architecture decisions
- Constitution principles are non-negotiable; implementation details are flexible within these constraints

---

**Version**: 1.0.0  
**Ratified**: 2025-10-27  
**Last Amended**: 2025-10-27  
**Scope**: hugmys0ul.xyz integrated commerce platform
