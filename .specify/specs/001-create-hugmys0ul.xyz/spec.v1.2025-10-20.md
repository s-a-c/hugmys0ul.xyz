# Project Specification: Integrated Commerce Platform

## 1. Overview

This document outlines the technical specification for a unified commerce platform for a startup business. The platform will integrate a Customer Relationship Management (CRM) system, an Enterprise Resource Planning (ERP) system, and an E-commerce storefront into a cohesive whole using a Service-Oriented Architecture (SOA).

## 2. System Architecture

The system will be developed as a monorepo containing three distinct, decoupled services.

- **Services Structure**:
    - `/services/crm`: The customer management service.
    - `/services/erp`: The inventory and accounting service.
    - `/services/ecommerce`: The public-facing sales channel.

- **Technology Stack**:
    - **Core Framework**: Laravel 12.x with PHP 8.4+
    - **UI/Admin Panels**: Livewire (Volt) and Filament 4.x
    - **Containerization**: Laravel Sail with Podman and `podman-compose`.
    - **Database**: Each service will have its own isolated PostgreSQL 16+ database.

- **Core Service Implementations**:
    - **CRM Service**: To be implemented using the `krayin/laravel-crm` open-source package as a base.
    - **ERP Service**: To be implemented using the `aureuserp/aureuserp` open-source package as a base.
    - **E-commerce Service**: To be implemented using the `bagisto/bagisto` open-source package as a base.

## 3. Domain Ownership & Single Source of Truth (SSoT)

To ensure data integrity, each service is designated as the authoritative source for specific data domains.

| Data Domain | Authoritative System (SSoT) | Description |
| :--- | :--- | :--- |
| **Products** | **ERP Service** | The ERP is the master record for all product information, including SKU, cost, supplier, and base details. |
| **Inventory/Stock** | **ERP Service** | The ERP owns the definitive "quantity on hand" for all products. |
| **Customers & Leads** | **CRM Service** | The CRM is the master record for all people, including their contact details, addresses, and interaction history. |
| **Sales Orders** | **E-commerce Service** | The storefront captures the initial sales order, including items purchased, pricing, and shipping information. |
| **Sales Pricing** | **E-commerce Service** | The storefront owns the customer-facing price, including all dynamic discounts and promotions. |
| **Invoices & Financials**| **ERP Service** | The ERP is the system of record for all financial data, including finalized invoices and accounting. |

## 4. Service Integration & API Endpoints

Services MUST communicate only via ReSTful APIs. The following data flows and initial API endpoints are defined to facilitate this.

### 4.1. Product Synchronization
- **Flow**: ERP -> E-commerce
- **Trigger**: A product is created or updated in the ERP.
- **Mechanism**: The ERP service will call an API endpoint on the E-commerce service to create or update the product listing.
- **API Endpoint**: `POST /api/v1/products` on **E-commerce Service**.
    - **Payload**: Product SKU, name, description, images, base price.

### 4.2. Inventory Synchronization
- **Flow**: ERP -> E-commerce
- **Trigger**: Stock level for a product changes in the ERP.
- **Mechanism**: The ERP service will call an API endpoint on the E-commerce service to update the stock quantity.
- **API Endpoint**: `PUT /api/v1/products/{sku}/stock` on **E-commerce Service**.
    - **Payload**: `{ "quantity": 120 }`

### 4.3. Customer Synchronization
- **Flow**: CRM -> ERP & E-commerce
- **Trigger**: A customer is created or updated in the CRM.
- **Mechanism**: The CRM will publish an event, and listeners will call APIs on the ERP and E-commerce services to create or update the customer record. This ensures a unified customer ID across the ecosystem.
- **API Endpoints**:
    - `POST /api/v1/customers` on **ERP Service**.
    - `POST /api/v1/customers` on **E-commerce Service**.

### 4.4. Order Synchronization
- **Flow**: E-commerce -> CRM & ERP
- **Trigger**: A customer places a new order on the E-commerce site.
- **Mechanism**: The E-commerce service will call APIs on the CRM and ERP to record the sale and begin the fulfillment process.
- **API Endpoints**:
    - `POST /api/v1/orders` on **CRM Service** (to log the interaction).
    - `POST /api/v1/orders` on **ERP Service** (to deduct stock and create the invoice).

## 5. Data Synchronization Strategy

A combination of direct API calls and queued jobs will be used to manage data consistency.

- **Webhooks & Events**: For real-time updates (e.g., a new order), the source service will immediately call the target service's API.
- **Queued Jobs**: To ensure reliability, these API calls will be dispatched as queued jobs within the source service. This provides retry mechanisms in case a target service is temporarily unavailable.
- **Scheduled Tasks**: For less critical, batch-style updates (e.g., a nightly full product catalog sync), scheduled tasks will be used.

## 6. Next Steps

1.  **Project Scaffolding**: Create the monorepo structure with the `/services` directory.
2.  **Podman & Sail Configuration**: Create the `podman-compose.yml` file defining the three services and their isolated PostgreSQL databases.
3.  **Service Installation**: Install Krayin, AureusERP, and Bagisto into their respective service directories.
4.  **Initial API Implementation**: Develop the first critical API endpoint (`POST /api/v1/products` on the E-commerce service) and the corresponding job on the ERP service to test the integration pattern.
