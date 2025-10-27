# <a id="development-standards"></a>Development Standards

## 1. Core Development Principle

**All code, comments, and technical documentation should be clear, actionable, and suitable for a junior developer to understand and implement.**

This principle should guide all development work in the project:

- Write code that is easy to read and understand
- Document complex logic with clear comments
- Break down complex functionality into smaller, manageable parts
- Use descriptive variable and function names
- Include examples and explanations for non-obvious implementations
- Provide context for architectural decisions

## 2. Code Style

### 2.1. PHP Standards

- Follow **PSR-12** coding standards
- Use Laravel Pint for code formatting (`composer pint`)
- Maintain consistent naming conventions across plugins
- Use type declarations and PHP 8.4+ features appropriately
- All PHP files must start with:

```php
<?php

declare(strict_types=1);

```

- All files must end with a blank last line

### 2.2. Configuration Files

**Code Style:**

- `.editorconfig` - Editor standards
- `.prettierrc.js` - Prettier configuration
- `pint.json` - Laravel Pint settings

**Static Analysis:**

- `phpstan.neon` - PHPStan configuration
- `rector.php` - Rector configuration

**Testing:**

- `phpunit.xml` - PHPUnit configuration
- `pest.config.php` - Pest settings
- `reports/coverage/` - Coverage reports

**CI/CD:**

- `.github/workflows/code-quality.yml` - GitHub Actions workflow

## 3. Architecture Patterns

### 3.1. Domain-Driven Design

- Follow **Domain-Driven Design** principles
- Maintain clear separation between layers:
  - Application Layer (Controllers, Middleware)
  - Domain Layer (Business Logic)
  - Infrastructure Layer (Database, External Services)
  - Presentation Layer (FilamentPHP Resources)

### 3.2. State and Feature Management

- Implement status/state-machine using `spatie/laravel-model-states` and `spatie/laravel-model-status`
- Use `spatie/laravel-model-flags` for feature flags backed by flags enum
- Consolidate functionality into `HasAdditionalFeatures` trait rather than separate traits

### 3.3. UI and Component Development

- Implement Livewire UI components as Volt Single File Components (SFC)
- Ensure custom Blade directives include suitable prefixes in names for uniqueness

## 4. Testing Requirements

> **Note:** For comprehensive testing standards, please refer to the [Testing Standards](030-testing-standards.md) document.

### 4.1. Coverage and Frameworks

- Achieve 90% code coverage
- Implement Pest/PHPUnit
- Use mutation testing
- Enable stress testing

### 4.2. Test Types

- Unit tests for individual components
- Feature tests for application features
- Integration tests for component interactions
- Browser tests using Laravel Dusk
- Architecture tests using PEST's architecture plugin

### 4.3. Architecture Testing

- Use PEST architecture tests (`pestphp/pest-plugin-arch`) to enforce architectural boundaries
- Define and enforce layer dependencies (e.g., controllers should not depend on repositories directly)
- Test that classes implement required interfaces and extend correct base classes
- Verify namespace organization and adherence to architectural patterns
- Example:

```php
test('controllers reside in correct namespace and follow naming convention', function () {
    expect('App\Http\Controllers')
        ->toHaveClasses(function ($class) {
            return $class->toExtend('App\Http\Controllers\Controller')
                ->andToHaveSuffix('Controller');
        });
});
```

### 4.4. State Test Type Safety

- All state-related tests (e.g., for Spatie Model States) must:
  - Use only available methods and properties on state classes
  - Avoid static `make()` calls unless the method exists and is type-safe
  - When calling `transitionTo()`, always pass a new state instance (not a raw enum or string)
  - Ensure all tests are strictly type-safe and compatible with the current state class API
  - Update all existing and future tests to comply with this rule

## 5. Laravel Development Standards

### 5.1. Data Access and ORM

**Default Approach: Eloquent ORM**

- Use Eloquent as the primary ORM for all database interactions
- Avoid raw SQL queries unless absolutely necessary for performance
- Use Eloquent relationships for all associations
- Follow Laravel naming conventions for models, relationships, and database tables

**Repository Pattern: When to Use**

The repository pattern adds abstraction between your business logic and data access. Use repositories when:

- **Multiple data sources**: Need to switch between different storage mechanisms (database, cache, API)
- **Complex queries**: Business logic requires sophisticated query building that would pollute models
- **Testing isolation**: Need to mock data layer independently of Eloquent
- **Team structure**: Large teams benefit from clear data access contracts

**When NOT to use repositories:**

- Simple CRUD operations
- Single data source applications
- Small to medium projects with straightforward data access
- When Eloquent scopes and query builders are sufficient

**Example: Eloquent (Default)**

```php
// app/Actions/CreateCustomerAction.php
class CreateCustomerAction
{
    public function execute(array $data): Customer
    {
        return Customer::create([
            'name' => $data['name'],
            'email' => $data['email'],
        ]);
    }
}
```

**Example: Repository Pattern (When Needed)**

```php
// app/Contracts/CustomerRepositoryInterface.php
interface CustomerRepositoryInterface
{
    public function create(array $data): Customer;
    public function findByEmail(string $email): ?Customer;
}

// app/Repositories/EloquentCustomerRepository.php
class EloquentCustomerRepository implements CustomerRepositoryInterface
{
    public function create(array $data): Customer
    {
        return Customer::create($data);
    }
    
    public function findByEmail(string $email): ?Customer
    {
        return Customer::where('email', $email)->first();
    }
}
```

### 5.2. Code Organization Patterns

This project uses a layered architecture with specific patterns for organizing code:

#### 5.2.1. Service Classes

Use service classes for complex business logic that spans multiple models or requires coordination:

```php
// app/Services/CustomerManagementService.php
declare(strict_types=1);

namespace App\Services;

use App\Models\Customer;
use App\Models\Order;

class CustomerManagementService
{
    public function createCustomerWithOrder(array $customerData, array $orderData): Customer
    {
        $customer = Customer::create($customerData);
        $customer->orders()->create($orderData);
        
        // Additional business logic here
        
        return $customer;
    }
}
```

#### 5.2.2. Action Classes

Use single-purpose action classes for discrete operations following the Single Responsibility Principle:

```php
// app/Actions/CreateCustomerAction.php
declare(strict_types=1);

namespace App\Actions;

use App\Models\Customer;

class CreateCustomerAction
{
    public function execute(array $data): Customer
    {
        return Customer::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'] ?? null,
        ]);
    }
}
```

**When to use Actions vs Services:**

- **Actions**: Single discrete operation (create, update, delete one thing)
- **Services**: Multiple operations or complex orchestration across domains

#### 5.2.3. Data Transfer Objects (DTOs)

Use DTOs with `spatie/laravel-data` for type-safe data transfer between layers:

```php
// app/Data/CustomerData.php
declare(strict_types=1);

namespace App\Data;

use Spatie\LaravelData\Data;

class CustomerData extends Data
{
    public function __construct(
        public string $name,
        public string $email,
        public ?string $phone = null,
    ) {}
}
```

Usage in controllers:

```php
public function store(CustomerData $data): JsonResponse
{
    $customer = Customer::create($data->toArray());
    
    return response()->json($customer, 201);
}
```

### 5.3. API Development Standards

#### 5.3.1. API Versioning

All API routes must be versioned using URI versioning:

```php
// routes/api.php
Route::prefix('v1')->group(function () {
    Route::apiResource('customers', CustomerController::class);
    Route::apiResource('orders', OrderController::class);
});
```

API structure: `/api/v1/{resource}`

#### 5.3.2. API Resources

Use Laravel API Resources for all JSON responses to ensure consistent transformation:

```php
// app/Http/Resources/CustomerResource.php
declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class CustomerResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at->toIso8601String(),
            'orders' => OrderResource::collection($this->whenLoaded('orders')),
        ];
    }
}
```

Usage in controllers:

```php
public function show(Customer $customer): CustomerResource
{
    return new CustomerResource($customer->load('orders'));
}

public function index(): AnonymousResourceCollection
{
    return CustomerResource::collection(Customer::paginate());
}
```

#### 5.3.3. Form Requests

All API endpoints that accept input must use Form Requests for validation:

```php
// app/Http/Requests/StoreCustomerRequest.php
declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCustomerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', Customer::class);
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:customers,email'],
            'phone' => ['nullable', 'string', 'max:20'],
        ];
    }
}
```

### 5.4. Authorization with Policies

All authorization logic must be encapsulated in Policy classes:

```php
// app/Policies/CustomerPolicy.php
declare(strict_types=1);

namespace App\Policies;

use App\Models\Customer;
use App\Models\User;

class CustomerPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view customers');
    }

    public function create(User $user): bool
    {
        return $user->hasPermissionTo('create customers');
    }

    public function update(User $user, Customer $customer): bool
    {
        return $user->hasPermissionTo('update customers');
    }

    public function delete(User $user, Customer $customer): bool
    {
        return $user->hasPermissionTo('delete customers');
    }
}
```

Register in `AuthServiceProvider`:

```php
protected $policies = [
    Customer::class => CustomerPolicy::class,
];
```

### 5.5. Events and Listeners

Use events and listeners for cross-cutting concerns and decoupled communication:

```php
// app/Events/CustomerCreated.php
declare(strict_types=1);

namespace App\Events;

use App\Models\Customer;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CustomerCreated
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public Customer $customer
    ) {}
}
```

```php
// app/Listeners/SendWelcomeEmail.php
declare(strict_types=1);

namespace App\Listeners;

use App\Events\CustomerCreated;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendWelcomeEmail implements ShouldQueue
{
    public function handle(CustomerCreated $event): void
    {
        // Send welcome email logic
    }
}
```

### 5.6. Jobs and Queues

Use queued jobs for async processing, long-running tasks, and background operations:

```php
// app/Jobs/ProcessCustomerImport.php
declare(strict_types=1);

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class ProcessCustomerImport implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        private string $filePath
    ) {}

    public function handle(): void
    {
        // Process import logic
    }
}
```

Dispatch jobs using:

```php
ProcessCustomerImport::dispatch($filePath);
```

### 5.7. Middleware

Create custom middleware for request filtering, transformation, or validation:

```php
// app/Http/Middleware/EnsureApiVersion.php
declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class EnsureApiVersion
{
    public function handle(Request $request, Closure $next, string $version): mixed
    {
        if ($request->route('version') !== $version) {
            return response()->json(['error' => 'Invalid API version'], 400);
        }

        return $next($request);
    }
}
```

Register in `app/Http/Kernel.php` or `bootstrap/app.php` (Laravel 11+).

### 5.8. Frontend: Livewire, Volt SFC, and Folio

#### 5.8.1. Livewire Volt Single File Components

Use Volt SFCs for interactive UI components:

```php
// resources/views/livewire/customer-form.blade.php
<?php

use function Livewire\Volt\{state, rules};

state(['name', 'email', 'phone']);

rules(['name' => 'required|string|max:255', 'email' => 'required|email']);

$save = function () {
    $this->validate();
    
    Customer::create([
        'name' => $this->name,
        'email' => $this->email,
        'phone' => $this->phone,
    ]);
    
    $this->redirect('/customers');
};

?>

<div>
    <form wire:submit="save">
        <input type="text" wire:model="name" />
        <input type="email" wire:model="email" />
        <input type="tel" wire:model="phone" />
        <button type="submit">Save</button>
    </form>
</div>
```

#### 5.8.2. Laravel Folio

Use Folio for page-based routing when appropriate:

```php
// resources/views/pages/customers/[id].blade.php
<?php

use App\Models\Customer;
use function Laravel\Folio\name;

name('customers.show');

?>

@volt
<?php
$customer = Customer::findOrFail($id);
?>

<div>
    <h1>{{ $customer->name }}</h1>
    <p>{{ $customer->email }}</p>
</div>
@endvolt
```

#### 5.8.3. FilamentPHP Admin Panels

Use FilamentPHP for admin interfaces with declarative resource definitions:

```php
// app/Filament/Resources/CustomerResource.php
declare(strict_types=1);

namespace App\Filament\Resources;

use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Tables;

class CustomerResource extends Resource
{
    protected static ?string $model = Customer::class;

    public static function form(Forms\Form $form): Forms\Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')->required(),
                Forms\Components\TextInput::make('email')->email()->required(),
                Forms\Components\TextInput::make('phone'),
            ]);
    }

    public static function table(Tables\Table $table): Tables\Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable(),
                Tables\Columns\TextColumn::make('email')->searchable(),
                Tables\Columns\TextColumn::make('created_at')->dateTime(),
            ]);
    }
}
```

### 5.2. Modern PHP and Laravel Features

- Use PHP 8 attributes over PHPDocs for robust type safety:
  - Use attributes for route definitions (`#[Route]`)
  - Use attributes for validation rules (`#[Rule]`)
  - Use attributes for middleware (`#[Middleware]`)
  - Use attributes for dependency injection (`#[Inject]`)
  - Use attributes for event listeners (`#[ListensTo]`)
  - Use attributes for policies (`#[Policy]`)
  - Example:

  ```php
  #[Route('users/{id}', methods: ['GET'])]
  #[Middleware(['auth', 'verified'])]
  public function show(#[FromRoute] int $id): View
  {
      // Method implementation
  }
  ```

- Use PHP 8's match expression over traditional if-else statements
- Target Laravel 12 and PHP 8.4 for all implementations
- Adhere to Laravel 12 best practice and custom
- Prefer the latest Laravel 12 patterns, tools, techniques

## 6. PHP Code Quality Standards

### 6.1. Static Analysis and Tooling

- **PHPStan Level 10 Compliance**: All PHP code must pass PHPStan analysis at the maximum strictness level (level 10)
- **Larastan Integration**: Use Larastan for Laravel-specific static analysis
- **Laravel Pint**: Use Laravel Pint for consistent code formatting
- **Editor Configuration**: Maintain `.editorconfig` for consistent development environment

#### 6.1.1. PHPStan Level 10 Requirements

**Core Application Code:**

- All production code in `app/` directory must achieve 0 PHPStan level 10 errors
- Use strict type declarations: `declare(strict_types=1);` in all PHP files
- Provide complete type annotations for all properties, parameters, and return values
- Handle mixed types explicitly with proper type checking and casting
- Use typed arrays with specific key-value type annotations (e.g., `array<string, mixed>`)

**Type Safety Standards:**

```php
// ✅ Correct: Explicit type handling
public function processData(array $data): array
{
    $context = $data['context'] ?? [];
    if (is_array($context)) {
        $typedContext = [];
        foreach ($context as $key => $value) {
            $typedContext[(string) $key] = $value;
        }
        return $typedContext;
    }
    return [];
}

// ❌ Incorrect: Mixed type assignment without validation
public function processData(array $data): array
{
    return $data['context'] ?? []; // PHPStan error: mixed type
}
```

**Property Type Annotations:**

```php
// ✅ Correct: Complete type annotation
/**
 * @var array<string, mixed>
 */
protected array $context = [];

// ❌ Incorrect: Missing or incomplete type annotation
protected array $context = []; // PHPStan error: missing type info
```

**Boolean Logic Validation:**

- Avoid redundant boolean conditions that PHPStan can detect as always true/false
- Use early returns to eliminate impossible conditions
- Example:

```php
// ✅ Correct: Simplified logic after early return
if (str_starts_with($url, '#')) {
    return LinkType::ANCHOR;
}
// At this point, we know URL doesn't start with '#'
if (str_contains($url, '#')) {
    return LinkType::CROSS_REFERENCE;
}

// ❌ Incorrect: Redundant condition
if (str_contains($url, '#') && ! str_starts_with($url, '#')) {
    // PHPStan error: condition always true after early return
}
```

### 6.2. Development Dependencies

Key development dependencies include:

```json
{
    "require-dev": {
        "alebatistella/duskapiconf": "^1.2",
        "barryvdh/laravel-debugbar": "^3.15",
        "barryvdh/laravel-ide-helper": "^3.5",
        "brianium/paratest": "^7.8",
        "driftingly/rector-laravel": "^2.0",
        "ergebnis/composer-normalize": "^2.47",
        "fakerphp/faker": "^1.24",
        "jasonmccreary/laravel-test-assertions": "^2.8",
        "larastan/larastan": "^3.4",
        "laravel-shift/blueprint": "^2.12",
        "laravel/dusk": "^8.3",
        "laravel/pint": "^1.22",
        "laravel/sail": "^1.43",
        "laravel/telescope": "^5.8",
        "mockery/mockery": "^1.6",
        "nunomaduro/collision": "^8.8",
        "nunomaduro/phpinsights": "^2.13",
        "peckphp/peck": "^0.1",
        "pestphp/pest": "^3.8",
        "pestphp/pest-plugin": "^3.x-dev",
        "pestphp/pest-plugin-arch": "^3.1",
        "pestphp/pest-plugin-faker": "^3.0",
        "pestphp/pest-plugin-laravel": "^3.2",
        "pestphp/pest-plugin-livewire": "^3.0",
        "pestphp/pest-plugin-stressless": "^3.1",
        "pestphp/pest-plugin-type-coverage": "^3.5",
        "php-parallel-lint/php-parallel-lint": "^1.4",
        "rector/rector": "^2.0",
        "rector/type-perfect": "^2.1",
        "roave/security-advisories": "dev-latest",
        "soloterm/solo": "^0.5",
        "spatie/laravel-blade-comments": "^1.4",
        "spatie/laravel-horizon-watcher": "^1.1",
        "spatie/laravel-ray": "^1.40",
        "spatie/laravel-web-tinker": "^1.10",
        "spatie/pest-plugin-snapshots": "^2.2",
        "symfony/polyfill-php84": "^1.32",
        "symfony/var-dumper": "^7.3"
    }
}
```

### 6.3. Quality Assurance

- Set up CI/CD checks
- Monitor cyclomatic complexity
- Check duplicate code
- Validate security
- Weekly code audits
- Generate quality reports
- Track technical debt
- Plan refactoring

## 7. Security Standards

### 7.1. Authentication and Authorization

- Use Laravel's built-in authentication system
- Implement FilamentShield for permission management
- Follow role-based access control (RBAC) principles
- Implement proper middleware for route protection

### 7.2. Data Protection

- Encrypt sensitive data at rest
- Use HTTPS for all connections
- Implement proper input validation
- Protect against common web vulnerabilities (XSS, CSRF, SQL Injection)
- Follow OWASP security best practices

### 7.3. API Security

- Use Laravel Sanctum for API authentication
- Implement rate limiting
- Validate all API inputs
- Use proper HTTP status codes
- Document API security requirements

## 8. Performance Optimization

### 8.1. Database Optimization

- Optimize database queries with proper indexing
- Use eager loading to prevent N+1 query problems
- Implement caching for expensive operations
- Use database transactions appropriately

### 8.2. Frontend Optimization

- Optimize asset loading for production
- Minimize JavaScript and CSS
- Use lazy loading for images and components
- Implement proper caching strategies

### 8.3. Application Performance

- Use queues for background processing
- Implement caching for expensive operations
- Monitor application performance
- Optimize memory usage

## 9. Code Organization and Structure

### 9.1. Namespace Standards

- Ensure all classes have correct and complete namespace declarations
- Follow PSR-4 autoloading standard
- Organize namespaces to reflect the application's domain structure
- Use consistent namespace prefixes across plugins
- Avoid deeply nested namespaces (maximum 4 levels recommended)
- Example namespace structure:

  ```text
  App\Domain\Module\Submodule\ClassName
  ```

### 9.2. Traits and Attributes Implementation

- Ensure classes implement all required traits for their functionality
- Use PHP attributes instead of PHPDocs to document trait usage and class properties:
  - Replace `@property` PHPDocs with proper property declarations
  - Replace `@method` PHPDocs with interface implementations
  - Use attributes for trait behavior configuration
  - Use attributes for validation, casting, and other metadata
- Avoid trait conflicts by carefully managing method names
- Implement traits in a consistent order:
  1. Framework traits (e.g., `HasFactory`)
  2. Authentication traits (e.g., `Authenticatable`)
  3. Domain-specific traits (e.g., `HasUserTracking`)
  4. Feature traits (e.g., `HasAdditionalFeatures`)
- Use architecture tests to verify correct trait implementation
- Example of trait usage:

  ```php
  use HasFactory;
  use Authenticatable;
  use HasUserTracking;
  use HasAdditionalFeatures;
  ```

- Example of attribute usage over PHPDocs:

  ```php
  // Instead of:
  /**
   * @property string $name
   * @property Carbon $created_at
   */

  // Use proper property declarations:
  public string $name;
  public Carbon $created_at;

  // Instead of:
  /**
   * @method void sendNotification(string $message)
   */

  // Implement the interface:
  #[Override]
  public function sendNotification(string $message): void
  {
      // Implementation
  }

  // Use attributes for validation, casting, etc.:
  #[Cast('array')]
  #[Rule('required|array')]
  public $options;
  ```

## 9. Deployment and CI/CD

### 9.1. Container Architecture

This project uses containerized services with Podman/Docker orchestration:

**Service Structure:**
- Each service (CRM, E-commerce, ERP) is independently containerized
- Services use PostgreSQL 16 databases in separate containers
- All services built from `services/{service}/Dockerfile`
- Orchestration via `podman-compose.yml` at project root

**Container Commands:**

```bash
# Start all services
podman-compose up -d

# Start specific service
podman-compose up -d crm

# Access service container
podman exec -it hugmys0ul-crm-1 bash

# View logs
podman-compose logs -f crm

# Stop services
podman-compose down
```

### 9.2. GitHub Actions Workflows

**Required Workflows:** (TBD - spec-kit process)

The following workflows should be implemented:

1. **Code Quality** (`.github/workflows/code-quality.yml`)
   - Run Laravel Pint
   - Execute PHPStan Level 10
   - Rector checks
   - PHP Parallel Lint

2. **Testing** (`.github/workflows/tests.yml`)
   - Run Pest/PHPUnit tests
   - Generate coverage reports
   - Architecture tests
   - Mutation testing

3. **Container Builds** (`.github/workflows/build.yml`)
   - Build container images per service
   - Tag with commit SHA and branch
   - Push to container registry

4. **Deployment** (`.github/workflows/deploy.yml`)
   - Deploy to staging on merge to `develop`
   - Deploy to production on merge to `main`
   - Run migrations
   - Health checks

### 9.3. Environment Management

**Environment Files:**

Each service maintains its own `.env` file based on `.env.example`:

```bash
# services/crm/.env
APP_NAME="CRM Service"
APP_ENV=production
APP_KEY=base64:...
APP_DEBUG=false

DB_CONNECTION=pgsql
DB_HOST=crm_db
DB_PORT=5432
DB_DATABASE=crm
DB_USERNAME=user
DB_PASSWORD=<secure-password>

QUEUE_CONNECTION=redis
CACHE_DRIVER=redis
```

**Never commit:**
- `.env` files with real credentials
- Database dumps with sensitive data
- API keys or tokens
- SSH keys or certificates

### 9.4. Deployment Checklist

Before deploying to production:

1. ✅ All tests passing (90%+ coverage)
2. ✅ PHPStan Level 10 with 0 errors
3. ✅ Laravel Pint formatting applied
4. ✅ Architecture tests passing
5. ✅ Security audit completed
6. ✅ Performance benchmarks met
7. ✅ Database migrations reviewed
8. ✅ Environment variables configured
9. ✅ Container builds successful
10. ✅ Rollback plan documented

### 9.5. Service-Specific Deployment

Each service can be deployed independently:

```bash
# Deploy single service
podman-compose up -d --build crm

# Run migrations for specific service
podman exec -it hugmys0ul-crm-1 php artisan migrate --force

# Clear caches
podman exec -it hugmys0ul-crm-1 php artisan optimize:clear
podman exec -it hugmys0ul-crm-1 php artisan config:cache
```

### 9.6. Monitoring and Health Checks

**Laravel Telescope:** Installed for development monitoring

**Health Check Endpoint:** Implement for each service:

```php
// routes/web.php
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'service' => config('app.name'),
        'timestamp' => now()->toIso8601String(),
    ]);
});
```

**Note:** Detailed deployment targets, container registry configuration, and CI/CD pipeline specifications will be determined through the spec-kit process.

## 10. See Also

### Related Guidelines

- **[Project Overview](010-project-overview.md)** - Understanding project architecture and plugin structure
- **[Documentation Standards](../Documentation/010-documentation-standards.md)** - Code documentation and comment standards
- **[Security Standards](040-security-standards.md)** - Security implementation requirements
- **[Performance Standards](050-performance-standards.md)** - Performance optimization techniques
- **[Testing Standards](030-testing-standards.md)** - Comprehensive testing requirements
- **[Workflow Guidelines](../Workflows/020-workflow-guidelines.md)** - Git workflow and development processes

### Development Decision Guide for Junior Developers

#### "I'm starting a new feature - which development pattern should I use?"

1. **Domain Logic**: Follow section 3.1 Domain-Driven Design principles
2. **State Management**: Use section 3.2 Spatie packages for state/feature management
3. **UI Components**: Implement section 3.3 Volt Single File Components for Livewire
4. **Testing**: Apply section 4 testing requirements (90% coverage minimum)

#### "I need to choose between different Laravel features - what's preferred?"

- **PHP Version**: Target PHP 8.4 (section 5.2) with modern features
- **Laravel Version**: Use Laravel 12 patterns and tools (section 5.2)
- **Attributes vs PHPDocs**: Prefer PHP 8 attributes (section 5.2) for type safety
- **ORM**: Use Eloquent exclusively, avoid raw SQL (section 5.1)

#### "I'm implementing security features - what standards apply?"

- **Authentication**: See [Security Standards](040-security-standards.md) section 9.2
- **Data Protection**: Follow [Security Standards](040-security-standards.md) section 9.3
- **API Security**: Apply [Security Standards](040-security-standards.md) section 9.5
- **Input Validation**: Use Laravel Form Requests with whitelist validation

#### "I need to optimize performance - where do I start?"

- **Database**: See [Performance Standards](050-performance-standards.md) section 10.2
- **Caching**: Apply [Performance Standards](050-performance-standards.md) section 10.3
- **Frontend**: Follow [Performance Standards](050-performance-standards.md) section 10.4
- **Monitoring**: Implement [Performance Standards](050-performance-standards.md) section 10.6

#### "I'm writing tests - what types and coverage do I need?"

- **Test Types**: Follow section 4.2 (Unit, Feature, Integration, Browser, Architecture)
- **Coverage**: Achieve 90% minimum (section 4.1)
- **Architecture Tests**: Use section 4.3 PEST architecture plugin
- **State Testing**: Apply section 4.4 type-safe state testing requirements

## 11. Navigation

**← Previous:** [Project Overview](010-project-overview.md) | **Next →** [Testing Standards](030-testing-standards.md) | **[Top](#development-standards)**
