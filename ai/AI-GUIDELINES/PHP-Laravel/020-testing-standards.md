# PHP & Laravel Testing Standards

This document provides a comprehensive set of standards for testing PHP and Laravel applications, with a strong focus on achieving PHPStan Level 10 compliance in test code.

## 1. Testing Philosophy

- **Test Behavior, Not Implementation:** Focus on what the code does, not how it does it.
- **Test at the Right Level:** Use the appropriate test type (Unit, Feature, Integration, E2E) for the functionality being tested.
- **Fast & Independent:** Tests should be fast and should not depend on the state of other tests.
- **Readable & Maintainable:** Tests are code. They must be clear, concise, and easy to maintain.

## 2. Test Organization

Tests MUST be organized in a directory structure that mirrors the application's `app/` directory.

- `tests/Unit/`: For testing individual components (Models, Services, etc.) in isolation.
- `tests/Feature/`: For testing features from a command-line or HTTP perspective.
- `tests/Integration/`: For testing the interaction between multiple components.
- `tests/E2E/`: For end-to-end tests that simulate a complete user scenario from start to finish.
- `tests/Architecture/`: For enforcing architectural rules using `pest-plugin-arch`.
- `tests/Support/`: Contains test helpers, data builders, and other support classes.

## 3. PHPStan Level 10 Compliance in Tests

- **Core Requirement:** All test files MUST strive for PHPStan Level 10 compliance. While some complex mocking or reflection scenarios may require temporary ignores, the goal is zero errors.
- **Strict Types:** All test files MUST start with `declare(strict_types=1);`.
- **Typed Mocks:** Use typed mocks to ensure that mock objects adhere to the contracts of the classes they are mocking.
- **Explicit Annotations:** Provide explicit type annotations for test properties and data providers.

```php
// tests/Unit/MyServiceTest.php

declare(strict_types=1);

use App\Services\MyService;
use App\Contracts\DependencyInterface;
use Mockery\MockInterface;

// Correct: Typed mock and explicit return types
it('does something correctly', function (): void {
    /** @var MockInterface&DependencyInterface $dependency */
    $dependency = Mockery::mock(DependencyInterface::class);
    $dependency->shouldReceive('someMethod')->andReturn(true);

    $service = new MyService($dependency);

    expect($service->doSomething())->toBeTrue();
});
```

## 4. Test Categories and Grouping

Tests MUST be categorized using `#[Group]` attributes. This allows for running specific subsets of the test suite.

### 4.1. Standard Categories

- **Test Type (Required):** `unit`, `feature`, `integration`, `e2e`, `arch`. Every test must have one.
- **Technical Area (Optional):** `database`, `api`, `cli`, `events`, `cache`, `queue`, `security`, `validation`.
- **Domain (Optional):** `invoicing`, `payments`, `products`, `users`.
- **Cross-Cutting (Optional):** `performance`, `smoke`, `regression`, `edge-case`.

### 4.2. Example Usage

```php
// tests/Feature/Api/ProductApiTest.php

#[Test]
#[Group('feature')]
#[Group('api')]
#[Group('products')]
#[Group('security')]
public function test_unauthenticated_user_cannot_create_product()
{
    // ...
}
```

## 5. Test Coverage

- **Minimum Requirement:** A minimum of **90% code coverage** is required for all new and modified code.
- **Enforcement:** This is enforced automatically via Codecov in the CI/CD pipeline. Pull requests that lower coverage below the threshold will be blocked.
- **Focus:** Prioritize testing critical business logic over simple getters and setters.

## 6. Test Data Management

- **Factories:** Use Laravel factories as the primary method for creating test model instances. Define states for common variations.
- **Isolation:** The `Illuminate\Foundation\Testing\DatabaseTransactions` trait MUST be used in tests that interact with the database to ensure that all changes are rolled back after the test runs.
- **Data Builders:** For creating complex object graphs for tests, use the Builder pattern. These builders should reside in `tests/Support/DataBuilders/`.

## 7. Test Helpers and Attributes

### 7.1. Custom PHP Attributes

Use custom PHP attributes to add metadata to tests.

- `#[PluginTest('PluginName')]`: Indicates which plugin is being tested.
- `#[RequiresDatabase]`: Marks a test as requiring a database connection.

### 7.2. Helper Utilities

A suite of test helpers is available in `tests/Helpers/TestHelpers.php` and through various traits in `tests/Traits/`. These provide common functionalities like creating test files, generating random data, and making common assertions.

## 8. Test Linting

Custom PHPStan rules are used to enforce testing standards, such as requiring every test to have `#[Group]` and `#[CoversClass]` attributes. This is run as part of the CI pipeline.
