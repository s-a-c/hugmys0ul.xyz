# Checklist: Implementation Process Quality

**Purpose**: To ensure the implementation process strictly adheres to the project's constitution and established TDD workflow. This checklist is a self-assessment for the AI assistant during the `/implement` phase.
**Created**: 2025-10-20
**Feature**: [Integrated Commerce Platform](../spec.md)

## 1. Pre-Implementation Gates

- [x] CHK001 - Have all prerequisite checklists (e.g., `readiness.md`, `api.md`, `security.md`) been completed and all critical gaps addressed? [Process]
- [x] CHK002 - Has the `test-plan.md` been formally and explicitly approved by the user before starting the first implementation task? [Process, TDD]

## 2. Per-Task TDD Workflow

> Note: To be verified for each implementation task.

- [ ] CHK003 - Was a failing test written *before* the corresponding implementation code? [Methodology, TDD]
- [ ] CHK004 - Does the implementation code exist only to make the corresponding test pass? [Methodology, TDD]
- [ ] CHK005 - Was the code refactored for clarity and style *after* the tests were passing? [Methodology, TDD]

## 3. Per-Task Quality & Constitutional Compliance

> Note: To be verified for each completed task.

- [ ] CHK006 - Does all new and modified PHP code pass PHPStan Level 10 analysis? [Compliance, Constitution §4]
- [ ] CHK007 - Has the `composer pint` command been run to enforce PSR-12 code style on all changed files? [Compliance, Constitution §4]
- [ ] CHK008 - Does the test suite for the completed task achieve 100% code coverage? [Compliance, Constitution §4]
- [ ] CHK009 - Is `declare(strict_types=1);` present at the top of every new PHP file? [Compliance, Constitution §4]

## 4. Workflow & Version Control

- [ ] CHK010 - Is only one task from `tasks.md` being worked on at a time? [Process]
- [ ] CHK011 - Is the corresponding task in `tasks.md` marked as `[x]` immediately upon successful completion and verification? [Process]
- [ ] CHK012 - Are all commit messages formatted according to the Conventional Commits specification? [Compliance, Constitution §4]
- [ ] CHK013 - Is all work being performed on the correct, designated feature branch? [Process]
