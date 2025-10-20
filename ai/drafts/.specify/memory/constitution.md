# Project Constitution

This document outlines the foundational principles and mandatory technical standards for the project. All development, whether human or AI-assisted, must adhere to these rules.

## 1. Core Principles

- **Clarity for Junior Developers**: All code, documentation, and specifications must be clear, actionable, and suitable for a junior developer to understand and implement.
- **Single Source of Truth (SSoT)**: Every critical piece of data (e.g., Products, Customers, Orders) must have a single, authoritative service that owns it. Other services may hold read-only copies, but the SSoT is the master record.
- **Service-Oriented Architecture (SOA)**: The project is composed of independent, decoupled services that communicate exclusively through well-defined, versioned, ReSTful APIs. Direct service-to-service code calls or database access are strictly forbidden.
- **Domain-Driven Design (DDD)**: Services shall be designed around specific business domains (e.g., CRM, ERP, E-commerce), with clear boundaries and responsibilities.

## 2. Architecture Mandates

- **Services**: The project shall consist of three core services: a CRM, an ERP, and an E-commerce platform.
- **Monorepo Structure**: The codebase for all services will be managed within a single monorepo, but each service must remain a separate, independent application within its own directory (e.g., `/services/crm`).
- **Database Isolation**: Each service MUST have its own dedicated, isolated PostgreSQL database instance. There will be no shared databases.
- **Containerization**: The entire development and production environment MUST be managed via containerization, using Laravel Sail with Podman and `podman-compose`.

## 3. Technology Stack

- **Backend Framework**: Laravel 12.x
- **Frontend Framework**: Livewire (Volt) & Filament 4.x
- **Database**: PostgreSQL 16+
- **PHP Version**: PHP 8.4+

## 4. Quality and Development Standards

- **Static Analysis**: All PHP code must pass PHPStan Level 10 analysis. No exceptions.
- **Code Style**: All code must adhere to the PSR-12 standard, enforced automatically by Laravel Pint.
- **Testing**: A minimum of 90% test coverage is required for all new code. The testing suite will include unit, feature, integration, and architecture tests.
- **Version Control**: All commit messages MUST follow the Conventional Commits specification. The branching model will be GitHub Flow.

## 5. AI & Human Collaboration Model

- **AI Role**: The AI assistant acts as a senior technical advisor, responsible for generating specifications, code, and tests in accordance with this constitution. It is also responsible for asking clarifying questions to resolve ambiguity.
- **Human Role**: The user acts as the project owner and final decision-maker, responsible for providing initial requirements, answering clarifying questions, and approving all AI-generated work.
