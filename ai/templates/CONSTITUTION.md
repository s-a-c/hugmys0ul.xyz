<!--
    Sync Impact Report:
    - Version change: 1.1.0 -> 1.2.0
    - Added sections: Security, Performance, Documentation, JS/TS, Shell, R&D
    - Templates requiring updates: None
-->
# Project Constitution

**Version**: 1.2.0  
**Ratification Date**: 2025-10-20  
**Last Amended**: 2025-10-20  

This document outlines the foundational principles and mandatory technical standards for the project. All development, whether human or AI-assisted, must adhere to these rules.

## 1. Core Principles

- **Clarity for Junior Developers**: All code, documentation, and specifications must be clear, actionable, and suitable for a junior developer to understand and implement.
- **Single Source of Truth (SSoT)**: Every critical piece of data (e.g., Products, Customers, Orders) must have a single, authoritative service that owns it.
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

- **Static Analysis**: All PHP code must pass PHPStan Level 10 analysis.
- **Code Style**: All code must adhere to the PSR-12 standard, enforced automatically by Laravel Pint.
- **Testing**: A minimum of 90% test coverage is required for all new code. The testing suite will include unit, feature, integration, and architecture tests.
- **Version Control**: All commit messages MUST follow the Conventional Commits specification. The branching model will be GitHub Flow.
- **JavaScript & TypeScript**: All JS/TS code should be clear, type-safe, and suitable for junior developers to understand, implement, and maintain.
- **Shell & CLI (ZSH)**: All ZSH scripts MUST be executable with `zsh -f` (no startup files) and respect the project's layering architecture.

## 5. Security Standards

- **Authentication and Authorization**: Use Laravel's built-in authentication and a dedicated package like `FilamentShield` for resource-level permission management.
- **Data Protection**: Use Laravel's built-in `encrypted` cast on Eloquent models for all sensitive data fields.
- **Input Validation**: Use Laravel's Form Request validation for all user inputs.
- **API Security**: Use Laravel Sanctum for all API authentication, implementing proper token scoping and expiration.

## 6. Performance Standards

- **Prevent N+1 Queries**: Use eager loading (`with()`) in Eloquent queries to prevent the N+1 problem.
- **Caching**: Use Laravel's cache system (`Cache::remember`) for expensive operations.
- **Asset Optimization**: All JavaScript and CSS files MUST be minified and bundled for production using Vite.
- **Background Jobs**: Offload any time-consuming or resource-intensive tasks to a queue worker for background processing.

## 7. Documentation Standards

- **Accessibility (WCAG 2.1 AA)**: All documentation MUST be clear, actionable, and suitable for a junior developer.
- **Structure and Formatting**: All documentation must be written in Markdown with hierarchical numbering and a Table of Contents.
- **Link Integrity**: The **TOC-Heading Synchronization Methodology** MUST be used to ensure 100% link integrity.
- **Mermaid Diagrams**: All Mermaid diagrams MUST be created with accessibility in mind, using high-contrast themes.

## 8. AI & Human Collaboration Model

- **AI Role**: The AI assistant acts as a senior technical advisor, responsible for generating work in accordance with this constitution and asking clarifying questions to resolve ambiguity.
- **Human Role**: The user acts as the project owner and final decision-maker, responsible for providing requirements, answering questions, and approving all AI-generated work.

## 9. Governance

- **Amendment Process**: Amendments can be proposed via a pull request and must be approved by the project owner.
- **Versioning**: This constitution follows Semantic Versioning 2.0.0.
- **Compliance**: All work must comply with the constitution version active at the time of its creation.
