# PHP & Laravel Security Standards

This document provides detailed security standards for PHP and Laravel applications.

## 1. Core Principle

All security implementations must be clear, verifiable, and suitable for a junior developer to understand, implement, and maintain.

## 2. Authentication and Authorization

*   **Laravel's Auth System:** Use Laravel's built-in authentication system (Breeze or Jetstream) as the foundation. Do not build custom authentication from scratch.
*   **Multi-Factor Authentication (MFA):** Implement MFA for all administrative accounts, preferably using Laravel Fortify for TOTP support. Provide recovery codes.
*   **Password Security:** Enforce strong password policies (12+ characters, mixed types, no common words) using Laravel's built-in validation rules. Implement password history and expiration.
*   **Role-Based Access Control (RBAC):** Use a dedicated package like `FilamentShield` for comprehensive, resource-level permission management based on business roles, not technical access.

## 3. Session Management

*   **Secure Configuration:** In production, session cookies MUST be configured as `SESSION_SECURE=true`, `SESSION_HTTP_ONLY=true`, and `SESSION_SAME_SITE=strict`.
*   **Session Invalidation:** Sessions MUST be invalidated on any authentication state change (e.g., password change, logout). Implement concurrent session limits for high-security accounts.

## 4. Data Protection

*   **Encryption at Rest:** Use Laravel's built-in `encrypted` cast on Eloquent models for all sensitive data fields, especially Personally Identifiable Information (PII).
*   **Encryption in Transit:** Enforce HTTPS for all connections. Use TLS 1.3 or higher for all external API communications.
*   **Input Validation:** Use Laravel's Form Request validation for all user inputs. Employ a whitelist-based approach, defining only what is allowed.
*   **Output Sanitization:** Rely on Blade's automatic escaping (`{{ }}`). Only use `{!! !!}` with extreme caution and pre-sanitized data.

## 5. Web Application Security

*   **XSS Prevention:** Implement a strict Content Security Policy (CSP) header.
*   **CSRF Protection:** Ensure Laravel's built-in CSRF middleware is enabled for all state-changing web routes.
*   **Security Headers:** Implement a comprehensive set of security headers, including `X-Content-Type-Options`, `X-Frame-Options`, `Strict-Transport-Security`, and `Referrer-Policy`.

## 6. API Security

*   **Authentication:** Use Laravel Sanctum for all API authentication, implementing proper token scoping and expiration.
*   **Rate Limiting:** Implement strict rate limiting on all API endpoints, with different limits based on authentication status.

## 7. File Upload Security

*   **Validation:** Validate all file uploads by MIME type (not just extension) and enforce strict file size limits.
*   **Malware Scanning:** Scan all uploaded files for malware using an integrated antivirus solution.
*   **Storage:** Store uploaded files outside the public web root directory, using Laravel's filesystem abstraction for access.

## 8. Logging and Incident Response

*   **Security Event Logging:** Log all critical security events, including authentication attempts (successful and failed), authorization failures, and sensitive data access.
*   **Incident Response:** Establish a clear incident response procedure, including automated alerts for security incidents and regular drills.
*   **Data Privacy (GDPR):** Implement privacy-by-design. Ensure the application can handle data export and deletion requests and maintains audit trails for data processing.
