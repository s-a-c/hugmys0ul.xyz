# Data Model

**Feature**: Integrated Commerce Platform
**Date**: 2025-10-20

This document outlines the key data entities and their authoritative sources, as defined by the Single Source of Truth (SSoT) principle in the project constitution.

| Data Domain | Authoritative System (SSoT) | Key Attributes (Initial) | Relationships |
| :--- | :--- | :--- | :--- |
| **Product** | **ERP Service** | `sku` (string, 255, unique), `name` (string, 255), `description` (text), `images` (json), `base_price` (decimal, 10, 2), `cost` (decimal, 10, 2), `supplier_info` (text) | A Product has one Inventory record. |
| **Inventory** | **ERP Service** | `sku` (foreign key), `quantity_on_hand` (integer) | Belongs to one Product. |
| **Customer** | **CRM Service** | `id` (ulid, unique), `full_name` (string, 255), `email` (string, 255, unique), `shipping_address` (text), `billing_address` (text) | A Customer can have many Sales Orders. |
| **Sales Order**| **E-commerce Service** | `id` (ulid, unique), `customer_id` (foreign key), `order_date` (datetime), `status` (string), `shipping_info` (text), `total_price` (decimal, 10, 2) | Belongs to one Customer. Has many Order Items. |
| **Order Item** | **E-commerce Service** | `order_id` (foreign key), `product_sku` (foreign key), `quantity` (integer), `price_at_purchase` (decimal, 10, 2) | Belongs to one Sales Order. |
| **Invoice** | **ERP Service** | `id` (ulid, unique), `order_id` (foreign key), `invoice_date` (date), `due_date` (date), `amount` (decimal, 10, 2), `status` (string) | Belongs to one Sales Order. |

## State Transitions

- **Sales Order**: `pending` -> `processing` -> `shipped` -> `completed` / `cancelled`
- **Invoice**: `draft` -> `sent` -> `paid` / `void`

## Validation Rules

- All unique identifiers (`id`, `sku`, `email`) must be unique within their respective tables.
- `email` must be a valid email format.
- `quantity_on_hand` cannot be negative.
- `total_price` and `amount` must be positive numeric values.
