# Project Specification: Integrated Commerce Platform v2

**Version**: 2.0
**Date**: 2025-10-20
**Status**: Draft - Review & Clarification Needed

**Reviewer's Note**: This revised specification elevates the original technical plan into a more complete feature specification. It introduces business context, user-centric scenarios, and measurable success criteria, which are essential for guiding development and ensuring the final product meets business needs. Key areas requiring clarification are marked with `[NEEDS CLARIFICATION]`.

---

## 1. Business Goals & Overview

This document outlines the specification for a unified commerce platform for a startup business. The primary goal is to create a cohesive, single view of business operations by integrating a Customer Relationship Management (CRM) system, an Enterprise Resource Planning (ERP) system, and an E-commerce storefront.

**Success of this project will be measured by:**
-   Reducing manual data entry and reconciliation between systems.
-   Providing a single, accurate view of customers, orders, and inventory.
-   Automating the entire order-to-fulfillment lifecycle.

## 2. User Stories & Scenarios

### User Persona(s):
-   **Admin User**: An employee responsible for managing products, inventory, and customer data.
-   **End Customer**: A user browsing and purchasing products from the E-commerce storefront.

### Core Scenarios:
1.  **Product & Inventory Management**: As an **Admin User**, I want to manage all product information and stock levels exclusively within the ERP, so that changes are automatically reflected on the E-commerce storefront, ensuring it is always accurate.
2.  **Unified Customer View**: As an **Admin User**, I want a single, authoritative record for every customer in the CRM, so that I have a complete history of their interactions and orders, regardless of where the data was first entered.
3.  **Automated Order Fulfillment**: As an **End Customer**, when I place an order on the E-commerce site, I expect the system to automatically process it, deduct inventory, and initiate the fulfillment process in the ERP without manual intervention.

## 3. Functional Requirements & Data Ownership

To ensure data integrity, each service is designated as the authoritative source for specific data domains.

| Data Domain | Authoritative System (SSoT) | Description |
| :--- | :--- | :--- |
| **Products** | **ERP Service** | The ERP is the master record for all product information, including SKU, cost, supplier, and base details. |
| **Inventory/Stock** | **ERP Service** | The ERP owns the definitive "quantity on hand" for all products. |
| **Customers & Leads** | **CRM Service** | The CRM is the master record for all people, including their contact details, addresses, and interaction history. |
| **Sales Orders** | **E-commerce Service** | The storefront captures the initial sales order, including items purchased, pricing, and shipping information. |
| **Sales Pricing** | **E-commerce Service** | The storefront owns the customer-facing price, including all dynamic discounts and promotions. |
| **Invoices & Financials**| **ERP Service** | The ERP is the system of record for all financial data, including finalized invoices and accounting. |

## 4. Non-Functional Requirements & Clarifications

### 4.1. Data Synchronization & Reliability
The system will use a combination of direct API calls and queued jobs.

-   **[NEEDS CLARIFICATION - Error Handling]**: What is the expected behavior when a destination service is offline during a synchronization attempt?
    -   **Option A**: The source service should retry the API call a fixed number of times (e.g., 5 retries over 10 minutes) before marking the job as failed.
    -   **Option B**: The job remains in the queue indefinitely until the destination service is back online.
    -   **Option C**: A notification is sent to a system administrator after the first failure.

-   **[NEEDS CLARIFICATION - Data Seeding]**: How will the initial data (e.g., existing products, customers) be imported and synchronized when the system first goes live? Is there a required order for data import?

-   **[NEEDS CLARIFICATION - Conflict Resolution]**: The SSoT model is clear for new data. But what is the process for resolving conflicts if data for the same entity (e.g., a customer with the same email) already exists in multiple systems before they are integrated?
    -   **Option A**: The data in the designated SSoT (e.g., CRM for customers) overwrites all others.
    -   **Option B**: A manual review process is triggered for an administrator to merge the records.

### 4.2. Security
-   **[NEEDS CLARIFICATION - API Security]**: How will the services authenticate with each other?
    -   **Option A**: API Keys/Tokens passed in headers.
    -   **Option B**: OAuth2 client credentials flow.
    -   **Option C**: Mutual TLS (mTLS) for service-to-service communication.

## 5. Success Criteria

-   **SC-01**: Product and inventory updates made in the ERP must be reflected on the E-commerce storefront in **under 2 minutes**.
-   **SC-02**: A new sales order placed on the storefront must be created in the ERP and CRM in **under 1 minute**.
-   **SC-03**: The system must maintain **99.9% uptime** for all public-facing services.
-   **SC-04**: Under normal load, API response times for synchronization calls must be **less than 500ms**.

---
## 6. Proposed Technical Implementation (Original Spec)

*(This section contains the original technical details, preserved for architectural reference.)*

- **System Architecture**: Monorepo with 3 decoupled services (`/services/crm`, `/services/erp`, `/services/ecommerce`).
- **Technology Stack**: Laravel 12.x, PHP 8.4+, Livewire/Volt, Filament 4.x, PostgreSQL 16+.
- **Containerization**: Laravel Sail with Podman and `podman-compose`.
- **Base Packages**: `krayin/laravel-crm`, `aureuserp/aureuserp`, `bagisto/bagisto`.
- **API Endpoints**:
    - **Product Sync**: `POST /api/v1/products` on E-commerce.
    - **Inventory Sync**: `PUT /api/v1/products/{sku}/stock` on E-commerce.
    - **Customer Sync**: `POST /api/v1/customers` on ERP & E-commerce.
    - **Order Sync**: `POST /api/v1/orders` on CRM & ERP.
