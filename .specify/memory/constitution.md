<!--
    Sync Impact Report:
    - Version change: 1.2.0 -> 2.0.0
    - Changed sections: Quality and Development Standards
    - Rationale: Increased test coverage to 100% and mandated a formal TDD process. This is a backward-incompatible change to the development workflow.
-->
# Project Constitution

**Version**: 2.0.0  
**Ratification Date**: 2025-10-20  
**Last Amended**: 2025-10-20  

This document outlines the foundational principles and mandatory technical standards for the project. All development, whether human or AI-assisted, must adhere to these rules.

## 1. Core Principles

- **Clarity for Junior Developers**: All code, documentation, and specifications must be clear, actionable, and suitable for a junior developer to understand and implement.
- **Single Source of Truth (SSoT)**: Every critical piece of data must have a single, authoritative service that owns it.
- **Service-Oriented Architecture (SOA)**: The project is composed of independent, decoupled services that communicate exclusively through well-defined, versioned, ReSTful APIs.
- **Domain-Driven Design (DDD)**: Services shall be designed around specific business domains with clear boundaries and responsibilities.

## 2. Architecture Mandates

- **Services**: The project shall consist of three core services: a CRM, an ERP, and an E-commerce platform.
- **Monorepo Structure**: The codebase for all services will be managed within a single monorepo, but each service must remain a separate, independent application.
- **Database Isolation**: Each service MUST have its own dedicated, isolated PostgreSQL database instance.
- **Containerization**: The entire development and production environment MUST be managed via containerization, using Laravel Sail with Podman and `podman-compose`.

## 3. Technology Stack

- **Backend Framework**: Laravel 12.x
- **Frontend Framework**: Livewire (Volt) & Filament 4.x
- **Database**: PostgreSQL 16+
- **PHP Version**: PHP 8.4+

## 4. Quality and Development Standards

- **Test-Driven Development (TDD)**: All code MUST be developed using a strict TDD workflow. A comprehensive test plan must be created and approved before any implementation begins.
- **100% Test Coverage**: All new code MUST achieve 100% test coverage. No exceptions.
- **Testing Framework**: All tests MUST be written using pure Pest syntax.
- **100% Type Safety**: All PHP code MUST be strictly typed. `declare(strict_types=1);` is mandatory in all PHP files.
- **Static Analysis**: All PHP code must pass PHPStan Level 10 analysis.
- **Code Style**: All code must adhere to the PSR-12 standard, enforced automatically by Laravel Pint.
- **Version Control**: All commit messages MUST follow the Conventional Commits specification. The branching model will be GitHub Flow.

## 5. Security, Performance, and Documentation

- **Security**: All security standards defined in the previous version remain in effect (Authentication, Data Protection, Input Validation, API Security).
- **Performance**: All performance standards defined in the previous version remain in effect (N+1 Prevention, Caching, Asset Optimization, Background Jobs).
- **Documentation**: All documentation standards defined in the previous version remain in effect (Accessibility, Formatting, Link Integrity, Mermaid Diagrams).

## 6. AI & Human Collaboration Model

- **AI Role**: The AI assistant acts as a senior technical advisor, responsible for generating work in accordance with this constitution, including the creation of test plans prior to implementation.
- **Human Role**: The user acts as the project owner and final decision-maker, responsible for providing requirements, approving test plans, and approving all AI-generated work.

## 7. Governance

- **Amendment Process**: Amendments can be proposed via a pull request and must be approved by the project owner.
- **Versioning**: This constitution follows Semantic Versioning 2.0.0.
- **Compliance**: All work must comply with the constitution version active at the time of its creation.