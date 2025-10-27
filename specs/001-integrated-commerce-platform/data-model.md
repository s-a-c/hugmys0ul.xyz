# Data Model

**Feature**: Integrated Commerce Platform  
**Date**: 2025-10-27 (Updated with Clarifications)

This document outlines the key data entities, their authoritative sources per the Single Source of Truth (SSoT) principle, and integration patterns based on clarifications from Sessions 2025-10-20 and 2025-10-27.

## Entity Ownership & Synchronization

| Data Domain | Authoritative System (SSoT) | Synchronization Method | Key Attributes (Initial) | Relationships |
| :--- | :--- | :--- | :--- | :--- |
| **Product** | **ERP Service** | Event-driven (Laravel queues) | `sku` (string, 255, unique), `name` (string, 255), `description` (text), `images` (json), `base_price` (decimal, 10, 2), `cost` (decimal, 10, 2), `supplier_info` (text) | A Product has one Inventory record. |
| **Inventory** | **ERP Service** | Event-driven (Laravel queues) | `sku` (foreign key), `quantity_on_hand` (integer) | Belongs to one Product. |
| **Customer** | **CRM Service** | Event-driven (Laravel queues) | `id` (ulid, unique), `full_name` (string, 255, encrypted), `email` (string, 255, unique, encrypted), `shipping_address` (text, encrypted), `billing_address` (text, encrypted) | A Customer can have many Sales Orders. |
| **Sales Order**| **E-commerce Service** | Synchronous API + Events | `id` (ulid, unique), `customer_id` (foreign key), `order_date` (datetime), `status` (enum), `shipping_info` (text), `total_price` (decimal, 10, 2) | Belongs to one Customer. Has many Order Items. |
| **Order Item** | **E-commerce Service** | Part of Sales Order | `order_id` (foreign key), `product_sku` (foreign key), `quantity` (integer), `price_at_purchase` (decimal, 10, 2) | Belongs to one Sales Order. |
| **Invoice** | **ERP Service** | Created from Sales Order | `id` (ulid, unique), `order_id` (foreign key), `invoice_date` (date), `due_date` (date), `amount` (decimal, 10, 2), `status` (enum) | Belongs to one Sales Order. |

## Essential Sync Fields (Clarification 2025-10-20)

When Customer records synchronize from CRM to other services, these fields are transmitted:
- `id` (ULID)
- `full_name` 
- `email`
- `shipping_address`
- `billing_address`

## State Machines & Transitions

### Sales Order States

Using `spatie/laravel-model-states` for type-safe state management:

```
pending → processing → shipped → completed
              ↓
          cancelled (terminal state)
```

**Business Rules**:
- Orders can be cancelled from `pending` or `processing` states only
- Once `shipped`, orders cannot be cancelled (only refunded via separate flow)
- `completed` requires confirmation of delivery

### Invoice States

```
draft → sent → paid (terminal state)
          ↓
        void (terminal state)
```

**Business Rules**:
- Invoices generated automatically when order reaches `processing` state
- Invoices can only be voided from `draft` or `sent` states
- Payment webhooks transition invoices from `sent` to `paid`

## Data Encryption (Security Requirement)

Sensitive fields MUST be encrypted at rest using Laravel's encrypted casting:

**Encrypted Fields**:
- Customer: `full_name`, `email`, `shipping_address`, `billing_address`
- Payment methods (if stored): all fields
- Any PII (Personally Identifiable Information)

**Implementation**:
```php
use Illuminate\Database\Eloquent\Casts\Attribute;

protected function fullName(): Attribute
{
    return Attribute::make(
        get: fn ($value) => decrypt($value),
        set: fn ($value) => encrypt($value),
    );
}
```

## Validation Rules

### Database Constraints
- All unique identifiers (`id`, `sku`, `email`) MUST be unique within their respective tables
- `email` MUST match RFC 5322 email format
- `quantity_on_hand` CANNOT be negative (check constraint)
- `total_price` and `amount` MUST be positive numeric values (check constraint)
- Foreign keys MUST have proper indexes for query performance

### Application-Level Validation

**Form Requests** (mandatory for all API inputs):
```php
// app/Http/Requests/StoreCustomerRequest.php
public function rules(): array
{
    return [
        'full_name' => ['required', 'string', 'max:255'],
        'email' => ['required', 'email', 'unique:customers,email'],
        'shipping_address' => ['nullable', 'string'],
        'billing_address' => ['nullable', 'string'],
    ];
}
```

## Migration Organization (Clarification 2025-10-27)

**Standard**: One migration per table/change with descriptive timestamps:

```
database/migrations/
├── 2025_10_27_000001_create_customers_table.php
├── 2025_10_27_000002_create_products_table.php
├── 2025_10_27_000003_create_inventory_table.php
├── 2025_10_27_000004_create_sales_orders_table.php
├── 2025_10_27_000005_create_order_items_table.php
└── 2025_10_27_000006_create_invoices_table.php
```

**Migration Requirements**:
- Atomic (wrapped in transaction via `DB::transaction()`)
- Reversible (functional `down()` method)
- Single responsibility (one table or logical change per file)

## Inter-Service Data Flows

### Pattern: Hybrid REST + Events (Clarification 2025-10-27)

**Synchronous (REST APIs for Queries)**:
- GET customer by ID from CRM
- GET product availability from ERP
- POST order to E-commerce (checkout flow)

**Asynchronous (Events for Sync)**:
- Product created/updated in ERP → ProductSyncJob → E-commerce
- Customer created/updated in CRM → CustomerSyncJob → E-commerce, ERP
- Order created in E-commerce → OrderNotificationJob → CRM, ERP

**Event Payload Example**:
```php
class ProductUpdated implements ShouldQueue
{
    public function __construct(
        public string $sku,
        public string $name,
        public string $description,
        public float $price,
        public int $stock,
    ) {}
}
```

## Query Optimization

### Eager Loading (N+1 Prevention)
```php
// Load orders with items and products
$orders = Order::with(['items.product', 'customer'])->paginate();
```

### Indexes Required
- `customers.email` (unique index for login queries)
- `products.sku` (unique index for lookups)
- `sales_orders.customer_id` (foreign key index)
- `order_items.order_id` (foreign key index)
- `order_items.product_sku` (foreign key index)
- Composite index: `(entity_type, entity_id)` for polymorphic relationships

### API Filtering with spatie/laravel-query-builder

```php
use Spatie\QueryBuilder\QueryBuilder;

$products = QueryBuilder::for(Product::class)
    ->allowedFilters(['name', 'sku', 'category'])
    ->allowedSorts(['name', 'price', 'created_at'])
    ->allowedIncludes(['inventory', 'category'])
    ->paginate(50);

// Query: GET /api/v1/products?filter[category]=electronics&sort=-price&include=inventory
```

## Exception Handling (Clarification 2025-10-27)

**Custom Domain Exceptions**:
```php
// app/Exceptions/CustomerNotFoundException.php
class CustomerNotFoundException extends DomainException
{
    public function __construct(string $customerId)
    {
        parent::__construct("Customer {$customerId} not found", 404);
    }
}

// app/Exceptions/ProductOutOfStockException.php
class ProductOutOfStockException extends DomainException
{
    public function __construct(string $sku, int $requested, int $available)
    {
        parent::__construct(
            "Product {$sku} out of stock. Requested: {$requested}, Available: {$available}",
            409
        );
    }
}
```

## Data Seeding Requirements

**Volume** (from spec clarification):
- **Products**: Thousands of records
- **Customers**: Thousands of records
- **Completion Time**: Must complete in <30 minutes

**Seeder Strategy**:
```php
// Use chunking for large datasets
Product::factory()
    ->count(5000)
    ->create()
    ->chunk(500)
    ->each(fn ($chunk) => /* process batch */);
```

## Soft Deletes

**Requirement**: When records are deleted in SSoT service, replicas MUST be soft-deleted (not hard-deleted).

**Implementation**:
```php
use Illuminate\Database\Eloquent\SoftDeletes;

class Customer extends Model
{
    use SoftDeletes;
    
    protected $dates = ['deleted_at'];
}
```

## Reconciliation Jobs

**Data Integrity**: Beyond event-driven sync, implement scheduled reconciliation:

1. **Nightly Batch**: Sync all records modified in last 24 hours from SSoT
2. **Manual Command**: Admin-triggered full resync for specific entity type

```bash
# Reconcile customers from CRM to all services
php artisan sync:reconcile customers --from=crm
```
