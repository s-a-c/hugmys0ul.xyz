# Quickstart Guide

**Feature**: Integrated Commerce Platform  
**Date**: 2025-10-27 (Updated)

This guide provides the steps for setting up the local development environment with all services.

## Prerequisites

- **PHP**: 8.2+ (target 8.4)
- **Composer**: Latest stable
- **Podman** or **Docker**: For container orchestration
- **Node.js**: 20+ (for frontend tooling)
- **Git**: For version control

## 1. Repository Structure

The monorepo contains three independent Laravel services plus a separate storefront:

```text
/
├── services/
│   ├── crm/         # CRM Service (Laravel 12)
│   ├── ecommerce/   # E-commerce Service (Laravel 12 + Lunar)
│   └── erp/         # ERP Service (Laravel 12)
├── storefront/      # Frontend application (Livewire/Volt or Vue SPA)
├── podman-compose.yml
└── .github/
    └── workflows/   # CI/CD pipelines
```

## 2. Initial Setup

### Clone and Install Dependencies

```bash
# Clone the repository
git clone <repository-url>
cd hugmys0ul.xyz

# Install each service's dependencies
cd services/crm && composer install && cd ../..
cd services/ecommerce && composer install && cd ../..
cd services/erp && composer install && cd ../..

# Install storefront dependencies (if using Livewire, this is part of Laravel)
cd storefront && npm install && cd ..
```

### Configure Environment Files

Each service needs its own `.env` file based on `.env.example`:

```bash
# Copy environment files
cp services/crm/.env.example services/crm/.env
cp services/ecommerce/.env.example services/ecommerce/.env
cp services/erp/.env.example services/erp/.env
cp storefront/.env.example storefront/.env

# Generate application keys
podman-compose exec crm php artisan key:generate
podman-compose exec ecommerce php artisan key:generate
podman-compose exec erp php artisan key:generate
```

## 3. Container Orchestration

The existing `podman-compose.yml` defines all services with isolated PostgreSQL 16 databases:

**Key Services**:
- **CRM**: `http://localhost:8001` (DB: port 5431)
- **E-commerce**: `http://localhost:8002` (DB: port 5432)
- **ERP**: `http://localhost:8003` (DB: port 5433)
- **Storefront**: `http://localhost:3000`

### Start All Services

```bash
# Start all containers in detached mode
podman-compose up -d

# View logs for a specific service
podman-compose logs -f crm

# Access a service container
podman exec -it hugmys0ul-crm-1 bash
```

## 4. Database Setup

### Run Migrations

Each service manages its own database schema:

```bash
# Run migrations for all services
podman-compose exec crm php artisan migrate
podman-compose exec ecommerce php artisan migrate
podman-compose exec erp php artisan migrate
```

### Seed Test Data

```bash
# Seed thousands of products and customers as specified
podman-compose exec erp php artisan db:seed --class=ProductSeeder
podman-compose exec crm php artisan db:seed --class=CustomerSeeder
```

## 5. Service Authentication Setup

Generate API tokens for service-to-service communication using Laravel Sanctum:

```bash
# Inside each service container, create API tokens
podman-compose exec crm php artisan tinker
>>> $user = User::first();
>>> $token = $user->createToken('crm-to-ecommerce')->plainTextToken;
>>> echo $token; // Copy this token

# Add tokens to .env files
# services/crm/.env
ECOMMERCE_API_TOKEN=<token-from-ecommerce>
ERP_API_TOKEN=<token-from-erp>

# Repeat for other services
```

## 6. FilamentPHP Admin Panels

Access admin panels for each service:

- **CRM Admin**: `http://localhost:8001/admin`
- **E-commerce Admin**: `http://localhost:8002/admin`
- **ERP Admin**: `http://localhost:8003/admin`

Create admin users:

```bash
podman-compose exec crm php artisan make:filament-user
podman-compose exec ecommerce php artisan make:filament-user
podman-compose exec erp php artisan make:filament-user
```

## 7. Development Commands

### Code Quality

```bash
# Format code with Laravel Pint
podman-compose exec crm ./vendor/bin/pint

# Run PHPStan Level 10 analysis
podman-compose exec crm ./vendor/bin/phpstan analyse

# Run Rector for automated refactoring
podman-compose exec crm ./vendor/bin/rector process
```

### Testing

```bash
# Run Pest test suite with coverage
podman-compose exec crm php artisan test --coverage --min=90

# Run architecture tests
podman-compose exec crm php artisan test --filter Architecture

# Run specific test file
podman-compose exec crm php artisan test tests/Feature/CustomerApiTest.php
```

### Queue Workers

```bash
# Start queue worker for async job processing
podman-compose exec crm php artisan queue:work --tries=3

# Monitor queue with Laravel Horizon (if installed)
# Access at http://localhost:8001/horizon
```

## 8. Storefront Development

```bash
# If using Livewire/Volt (server-side)
podman-compose exec storefront npm run dev

# If using Vue SPA
cd storefront
npm run dev  # Vite dev server on http://localhost:5173
```

## 9. Inter-Service Communication Patterns

### Synchronous API Call (Query)

```php
// From E-commerce service, get customer from CRM
use Illuminate\Support\Facades\Http;

$response = Http::withToken(config('services.crm.token'))
    ->get('http://crm-service/api/v1/customers/' . $customerId)
    ->throw();

$customer = $response->json();
```

### Asynchronous Event (Data Sync)

```php
// From ERP service, notify e-commerce of product update
use App\Events\ProductUpdated;

event(new ProductUpdated($product)); // Dispatches queued listener
```

## 10. Troubleshooting

### Database Connection Issues

```bash
# Check database container is running
podman-compose ps

# Test database connection
podman-compose exec crm php artisan db:show
```

### Queue Not Processing

```bash
# Check Redis is running
podman-compose exec crm php artisan queue:monitor

# Restart queue worker
podman-compose restart crm
```

### API Authentication Failures

```bash
# Verify token in .env
cat services/crm/.env | grep API_TOKEN

# Test API endpoint with token
curl -H "Authorization: Bearer <token>" http://localhost:8001/api/v1/customers
```

## 11. Next Steps

1. **Review Documentation**: Read `spec.md` and `plan.md` for architecture details
2. **Run `/speckit.tasks`**: Generate task breakdown for TDD implementation
3. **Start with Priority 1 Tasks**: Begin with customer/product synchronization
4. **Follow TDD Workflow**: Test Plan → User Approval → Write Tests → Implement → Refactor

## Useful Links

- **API Contracts**: See `contracts/` directory for OpenAPI specifications
- **Data Model**: See `data-model.md` for entity schemas
- **AI Guidelines**: See `/ai/AI-GUIDELINES/` for coding standards
- **Constitution**: See `.specify/memory/constitution.md` for project principles
