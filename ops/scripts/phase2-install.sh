#!/usr/bin/env bash
set -euo pipefail
RUNNER=docker
command -v podman >/dev/null 2>&1 && RUNNER=podman
IMG=composer:2
pkgs_common=(
  laravel/sanctum:^4.0
  laravel/horizon:^5.0
  laravel/telescope:^5.0
  filament/filament:^3.2
  spatie/laravel-permission:^6.0
  spatie/laravel-activitylog:^4.8
  spatie/laravel-query-builder:^5.5
  spatie/laravel-data:^4.0
  spatie/laravel-model-states:^2.8
  spatie/laravel-backup:^10.0
  spatie/laravel-health:^1.30
)
install_service() {
  svc="$1"
  extra_pkgs=("${@:2}")
  svc_dir="services/${svc}"
  echo "==> ${svc}: scaffolding Laravel app if missing"
  ${RUNNER} run --rm -v "$PWD/${svc_dir}":/app -w /app ${IMG} sh -lc 'test -f artisan || composer create-project laravel/laravel .'
  echo "==> ${svc}: updating composer.json requirements only"
  ${RUNNER} run --rm -v "$PWD/${svc_dir}":/app -w /app ${IMG} composer require --no-update "${pkgs_common[@]}" "${extra_pkgs[@]:-}"
}
install_service crm
install_service ecommerce lunarphp/lunar:^0.11
install_service erp
