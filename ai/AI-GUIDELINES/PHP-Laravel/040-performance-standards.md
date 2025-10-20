# PHP & Laravel Performance Standards

This document provides detailed performance standards for PHP and Laravel applications.

## 1. Core Principle

All performance optimizations must be measurable, maintainable, and suitable for a junior developer to understand, implement, and monitor. Avoid premature optimization—measure first.

## 2. Database Performance

*   **Prevent N+1 Queries:** Use eager loading (`with()`) in Eloquent queries to prevent the N+1 problem. This is a critical performance requirement.
*   **Indexing:** Implement proper database indexing strategies for all frequently queried columns. Use composite indexes for multi-column queries.
*   **Transaction Management:** Keep database transactions as short as possible to reduce lock times and improve concurrency.
*   **Connection Pooling:** Configure and monitor database connection pool sizes to handle application load efficiently.

## 3. Caching Strategies

*   **Application-Level Caching:** Use Laravel's cache system (`Cache::remember`) for expensive operations and calculations. Use cache tags for organized and efficient cache invalidation.
*   **HTTP Caching:** Implement HTTP response caching for static or semi-static content. Use ETags and Last-Modified headers to allow for conditional requests.
*   **CDN Integration:** Use a Content Delivery Network (CDN) for all static assets (CSS, JS, images).

## 4. Frontend Performance

*   **Asset Optimization:** All JavaScript and CSS files MUST be minified and bundled for production using a tool like Vite.
*   **Code Splitting:** Implement code splitting for large JavaScript applications to only load necessary code on a given page.
*   **Image Optimization:** Use modern, compressed image formats (e.g., WebP, AVIF) and implement lazy loading for images that are off-screen.

## 5. Application & Memory Performance

*   **Memory-Efficient Code:** When processing large datasets, use PHP generators or Eloquent's `chunk()` or `cursor()` methods to minimize memory usage.
*   **Queue for Background Jobs:** Offload any time-consuming or resource-intensive tasks (e.g., sending emails, processing images) to a queue worker for background processing.
*   **Job Optimization:** Configure job timeouts and retry strategies appropriately. Use job batching where applicable.

## 6. Scalability

*   **Horizontal Scaling:** Design the application to be horizontally scalable. This includes stateless application servers and proper load balancing strategies.
*   **Database Scaling:** For read-heavy workloads, implement database read replicas.
*   **Performance Profiling:** Regularly profile the application using tools like Xdebug or Blackfire to identify and eliminate bottlenecks in hot code paths.

## 7. Performance Monitoring

*   **APM:** Implement a comprehensive Application Performance Monitoring (APM) solution to track key metrics like response times, throughput, and error rates.
*   **Load Testing:** Conduct regular load testing on critical application paths to establish performance baselines and identify regressions before they reach production.
