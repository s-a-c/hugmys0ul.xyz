# Test Plan: Integrated Commerce Platform

**Feature**: Integrated Commerce Platform
**Branch**: `001-integrated-commerce-platform`

This document outlines the test plan for the feature. As per the Project Constitution v2.0.0, this plan must be approved before implementation begins.

## User Story 1: Product Synchronization (P1)

-   **Test**: Write a feature test in `/services/erp/tests/Feature/` to confirm that creating a `Product` model dispatches a `ProductUpdated` event.
-   **Test**: Write a feature test in `/services/ecommerce/tests/Feature/` to validate the `POST /api/v1/products` endpoint.

## User Story 2: Inventory Synchronization (P1)

-   **Test**: Write a feature test in `/services/erp/tests/Feature/` to confirm that updating an `Inventory` model dispatches an `InventoryUpdated` event.
-   **Test**: Write a feature test in `/services/ecommerce/tests/Feature/` to validate the `PUT /api/v1/products/{sku}/stock` endpoint.

## User Story 3: Customer Unification (P2)

-   **Test**: Write a feature test in `/services/crm/tests/Feature/` to confirm creating a `Customer` dispatches a `CustomerUpdated` event.
-   **Test**: Write a feature test in `/services/erp/tests/Feature/` to validate the `POST /api/v1/customers` endpoint.
-   **Test**: Write a feature test in `/services/ecommerce/tests/Feature/` to validate the `POST /api/v1/customers` endpoint.

## User Story 4: Order Fulfillment (P2)

-   **Test**: Write a feature test in `/services/ecommerce/tests/Feature/` to confirm creating a `SalesOrder` dispatches an `OrderCreated` event.
-   **Test**: Write a feature test in `/services/erp/tests/Feature/` to validate the `POST /api/v1/orders` endpoint.
-   **Test**: Write a feature test in `/services/crm/tests/Feature/` to validate the `POST /api/v1/orders` endpoint.

## Edge Case & Failure Scenarios

-   **Test**: Write a feature test to confirm that sending an invalid payload (e.g., a product with a missing `name`) to a synchronization endpoint results in a `422 Unprocessable Entity` response and the data is not saved.
-   **Test**: Write a feature test to confirm that a request to a protected API endpoint without a valid token is rejected with a `401 Unauthorized` response.
-   **Test**: Write a feature test to confirm that a request to an API endpoint with a token that lacks the required scope is rejected with a `403 Forbidden` response.
-   **Test**: Write a feature test to confirm that when a record is soft-deleted in its SSoT service, the corresponding records in the replica services are also soft-deleted.
-   **Test**: Write an integration test to verify that a failed synchronization job is retried according to the defined backoff strategy (10s, 1m, 10m, 1hr, 3hr).
-   **Test**: Write a feature test to confirm that after all retries are exhausted, a failed job is moved to the `failed_jobs` table.
