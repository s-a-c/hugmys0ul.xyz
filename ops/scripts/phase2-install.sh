#!/usr/bin/env bash
set -euo pipefail
RUNNER=docker
command -v podman >/dev/null 2>&1 && RUNNER=podman
IMG=composer:2
pkgs_common=(
  laravel/sanctum
  laravel/horizon
  laravel/telescope
  filament/filament
  spatie/laravel-permission
  spatie/laravel-activitylog
  spatie/laravel-query-builder
  spatie/laravel-data
  spatie/laravel-model-states
  spatie/laravel-backup
  spatie/laravel-health
)
install_service() {
  svc="$1"
  extra_pkgs=("${@:2}")
  svc_dir="services/${svc}"
  echo "==> ${svc}: scaffolding Laravel app if missing"
  ${RUNNER} run --rm -v "$PWD/${svc_dir}":/app -w /app ${IMG} sh -lc 'test -f artisan || composer create-project laravel/laravel .'
  echo "==> ${svc}: installing dependencies"
  ${RUNNER} run --rm -v "$PWD/${svc_dir}":/app -w /app ${IMG} composer require "${pkgs_common[@]}" "${extra_pkgs[@]:-}"
}
install_service crm
install_service ecommerce lunarphp/lunar
install_service erp
