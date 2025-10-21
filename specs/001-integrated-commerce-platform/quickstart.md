# Quickstart Guide

**Feature**: Integrated Commerce Platform
**Date**: 2025-10-20

This guide provides the initial steps for setting up the project structure and services.

## 1. Monorepo Structure

Create the following directory structure at the root of the repository:

```
/
└── services/
    ├── crm/
    ├── ecommerce/
    └── erp/
```

## 2. Containerization Setup

Create a `podman-compose.yml` file in the root of the repository with the following structure. This will define the three services and their isolated databases.

```yaml
version: '3.8'

services:
  crm:
    build:
      context: ./services/crm
      dockerfile: Dockerfile
    ports:
      - "8001:80"
    volumes:
      - ./services/crm:/var/www/html
    depends_on:
      - crm_db
    environment:
      DB_CONNECTION: pgsql
      DB_HOST: crm_db
      # ... other env vars

  crm_db:
    image: postgres:16
    environment:
      POSTGRES_DB: crm
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - crm_postgres_data:/var/lib/postgresql/data

  # ... similar service definitions for ecommerce and erp ...

volumes:
  crm_postgres_data:
  ecommerce_postgres_data:
  erp_postgres_data:
```
*(Note: This is a template. Final `Dockerfile` and environment configurations will be created during implementation.)*

## 3. Service Installation

Navigate into each service directory and install the respective base package using Composer:

```bash
# From repo root
cd services/crm
composer require krayin/laravel-crm

cd ../ecommerce
composer require bagisto/bagisto

cd ../erp
composer require aureuserp/aureuserp
```

## 4. Next Steps

With the basic structure in place, the next phase is to begin the TDD workflow for the first user story: **Product Synchronization**. This will involve creating a test plan to validate the API communication between the ERP and E-commerce services.
