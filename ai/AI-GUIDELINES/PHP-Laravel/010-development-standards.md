# PHP & Laravel Development Guidelines

This document provides a comprehensive set of guidelines for AI-assisted development in PHP and Laravel projects, with a strong focus on Laravel Zero for console applications.

## 1. Core Development Principle

All code, comments, and technical documentation should be clear, actionable, and suitable for a junior developer to understand and implement.

## 2. Code Style and Quality

### 2.1. PHP Standards

- **PSR-12:** All code must follow the PSR-12 coding standard.
- **Strict Types:** All PHP files MUST start with `declare(strict_types=1);`.
- **Formatting:** Use Laravel Pint for automated code formatting (`composer pint`).
- **Static Analysis:** All code must pass **PHPStan Level 10** analysis. No violations are permitted in the main application code (`app/`).

### 2.2. Type Safety (PHPStan Level 10)

- **Zero Mixed Types:** Avoid `mixed` types. When unavoidable, they must be handled with explicit type-checking and casting.
- **Complete Annotations:** All properties, parameters, and return values must have explicit, complete type annotations.
- **Array Shapes:** Complex arrays must have their structure defined using array shape annotations (e.g., `array<string, array{url: string, text: string, line: int}>`).
- **Readonly ValueObjects:** Use `readonly` classes for immutable data transfer objects to enforce type safety and immutability.

### 2.3. Static Analysis Tooling

- **PHPStan:** Configured to `level: 10` in `phpstan.neon` for maximum strictness.
- **Rector:** Configured for PHP 8.4+ modernization, code quality, and type declaration improvements.
- **Pint / PHP-CS-Fixer:** Configured to enforce PSR-12 and strict type declarations, while preserving PHPDoc annotations required by PHPStan.

## 3. Architecture Patterns (Laravel Zero)

### 3.1. Layered Architecture

Maintain a clear separation of concerns between layers:

1. **Command Layer (`app/Commands/`):** Entry points for user interaction. Responsible for input validation and orchestrating calls to the service layer.
2. **Service Layer (`app/Services/`):** Contains the core business logic. Services are injected into commands and are responsible for executing tasks.
3. **ValueObject Layer (`app/Services/ValueObjects/`):** Immutable data structures for passing data between layers.
4. **Presentation Layer (`app/Services/Formatters/`):** Responsible for formatting output (e.g., console tables, JSON reports).

### 3.2. Dependency Injection

- **Constructor Injection:** All dependencies (e.g., services) MUST be injected into the constructor of commands and other services.
- **Service Provider Registration:** Bind all service interfaces to their concrete implementations in a `ServiceProvider` (e.g., `ValidateLinksServiceProvider.php`).

### 3.3. Configuration

- **Configuration ValueObjects:** Use dedicated, `readonly` ValueObject classes (e.g., `ValidationConfig`) to manage and pass around configuration, ensuring type safety.
- **Configuration Files:** Store default configuration in the `config/` directory, and allow for overrides via environment variables.

### 3.4. Domain-Driven Design (DDD)

- **Principles:** Follow Domain-Driven Design principles to maintain a clear separation between layers.
- **Layers:**
  - **Presentation Layer:** (e.g., FilamentPHP Resources, Commands) - Handles user interaction.
  - **Application Layer:** (e.g., Controllers, Actions) - Orchestrates domain logic.
  - **Domain Layer:** (e.g., Services, Models, ValueObjects) - Contains the core business logic.
  - **Infrastructure Layer:** (e.g., Database access, external API clients) - Handles external concerns.

### 3.5. UI and Component Development

- **Volt Single File Components (SFC):** When implementing Livewire UI components, they should be created as Volt Single File Components to co-locate the class and template logic.
- **Blade Directive Prefixes:** Ensure any custom Blade directives you create include a unique prefix in their names to avoid conflicts with other packages or future Laravel features.

### 3.6. Quality Assurance

- **Cyclomatic Complexity:** Monitor the cyclomatic complexity of methods and classes to keep them simple and maintainable. High complexity is a sign that a class or method should be refactored.
- **Duplicate Code:** Actively look for and eliminate duplicate code. Use traits, services, or helper functions to promote code reuse.
- **Technical Debt:** Track known technical debt. Create issues or TODOs with clear explanations of the problem and potential solutions.
- **Code Audits:** Participate in regular code audits to ensure adherence to standards and identify areas for improvement.

## 4. Testing Standards

### 4.1. Core Principles

- **Test Behavior, Not Implementation:** Focus on what the code does, not how it does it.
- **PHPStan Level 10 Compliance:** Test code should also strive for PHPStan Level 10 compliance.
- **Minimum 90% Coverage:** All new code must be accompanied by tests that achieve at least 90% code coverage.

### 4.2. Test Organization

Tests are organized by type and mirror the application structure:

- `tests/Unit/`: For testing individual components in isolation.
- `tests/Feature/`: For testing features from a command-line or HTTP perspective.
- `tests/Integration/`: For testing the interaction between multiple components.
- `tests/E2E/`: For end-to-end tests that simulate a complete user scenario.
- `tests/Architecture/`: For enforcing architectural rules using `pest-plugin-arch`.

### 4.3. Test Data

- **Factories:** Use Laravel factories as the primary method for creating test data.
- **Data Builders:** For complex test data, use the Builder pattern in `tests/Support/DataBuilders/`.
- **Isolation:** Use the `DatabaseTransactions` trait to ensure test data isolation.

### 4.4. Mocking

- **Mockery:** Use Mockery for creating test doubles.
- **Typed Mocks:** Create typed mocks to maintain PHPStan compliance in tests.
- **Lifecycle Management:** Always call `Mockery::close()` in the `tearDown()` or `afterEach()` method to verify expectations.

### 4.5. Test Categories

- Use `#[Group]` attributes to categorize tests (e.g., `unit`, `feature`, `database`, `api`, `security`, `performance`). This allows for running specific subsets of the test suite.

---
*This document is a consolidation of multiple source files. More detailed sections on Testing, Static Analysis, and specific Laravel Zero patterns will be added in subsequent steps.*
