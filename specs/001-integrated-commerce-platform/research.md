# Research & Decisions

**Feature**: Integrated Commerce Platform
**Date**: 2025-10-20

This document outlines the key decisions and research findings that will guide the implementation plan.

## 1. Core Technology Integration Patterns

### Decision: Laravel Events & Queued Jobs for Service Communication

- **Rationale**: The project constitution mandates a Service-Oriented Architecture (SOA) where services communicate via APIs. The feature specification clarifies this should be an event-driven model. The most robust and idiomatic way to achieve this in Laravel is to use its built-in event and queue system.
- **Workflow**:
    1. The source service (e.g., ERP) will dispatch an event (e.g., `ProductUpdated`).
    2. A listener for that event will be configured to dispatch a queued job.
    3. The job will be responsible for making the authenticated API call to the target service (e.g., E-commerce).
- **Benefits**: This decouples the services, provides high reliability via queue retries (as specified), and allows for asynchronous communication, which improves performance.
- **Alternatives Considered**: Direct API calls from the controller/model. This was rejected as it would create tight coupling and make the system less resilient to temporary service outages.

## 2. Open-Source Package Integration Assumptions

The implementation will be based on three core open-source packages. The plan assumes these packages follow standard Laravel conventions.

### Decision: Assume Standard Laravel API and Event Capabilities

- **Rationale**: Without performing a full code audit of each package at the planning stage, we must proceed with reasonable assumptions. Mature Laravel packages typically provide either dedicated API endpoints or are extensible enough to add them. They also typically fire standard Eloquent model events (`created`, `updated`, `deleted`) which can be used as hooks for our synchronization listeners.
- **Validation**: The very first implementation task for each service will be to verify these assumptions.
  - **Task 1 (CRM)**: Confirm `krayin/laravel-crm` fires model events for Customer creation/updates and has an API or can have one added.
  - **Task 2 (ERP)**: Confirm `aureuserp/aureuserp` fires model events for Product/Inventory changes and has an API or can have one added.
  - **Task 3 (E-commerce)**: Confirm `bagisto/bagisto` fires model events for Order creation and has APIs for receiving product and customer data.
- **Contingency**: If a package does not provide the necessary hooks, the first task will be to implement them, likely by using model observers to capture changes and dispatch the necessary events.

## 3. API Authentication

### Decision: Use Laravel Sanctum for Service-to-Service Authentication

- **Rationale**: The specification requires API token authentication. Laravel Sanctum is the official, light-weight, and secure way to handle this for first-party API consumers. Each service will be treated as a "first-party" client of the others.
- **Implementation**: Each service will have an API token generated for it to use when communicating with the other two services. These tokens will be stored securely in the environment configuration.
- **Alternatives Considered**: Laravel Passport (OAuth2). This was deemed overly complex for the immediate needs of internal, trusted service-to-service communication.
