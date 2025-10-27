# Monorepo Migration Plan: Laravel Projects

## 1. Core Tooling

We will use `symplify/monorepo-builder`, a popular tool for managing PHP monorepos. It helps with:

- Merging `composer.json` files from sub-packages into the root.
- Maintaining a single `vendor` directory.
- Automating dependency version synchronization.
- Validating the monorepo setup.

---

## 2. Proposed Directory Structure

The final structure will be organized as follows:

```text
/hugmys0ul.xyz
├── apps/
│   ├── bagisto/            # Existing Bagisto Laravel project
│   │   └── composer.json
│   ├── aureuserp/          # Existing AureusERP Laravel project
│   │   └── composer.json
│   └── ...                 # Future applications
│
├── packages/
│   ├── shared-auth/        # Example of a shared package (e.g., for SSO)
│   │   └── composer.json
│   └── ...                 # Future shared libraries
│
├── docs/
│   └── planning/
│       └── 010-monorepo-laravel-migration-plan.md
│
├── .gitignore
├── composer.json           # Root composer.json for managing the monorepo
└── monorepo-builder.php    # Configuration for the monorepo builder tool
```

---

## 3. Migration Steps

### Step 1: Initial Setup & Tooling

1. **Create Root `composer.json`**:
    This file will manage the monorepo tooling and define the workspace. Create a `composer.json` file in the project root:

    ```json
    {
        "name": "hugmysoul/monorepo",
        "type": "project",
        "description": "Monorepo for hugmysoul.xyz projects.",
        "require-dev": {
            "symplify/monorepo-builder": "^11.2"
        },
        "autoload": {
            "psr-4": {
                "App\\": "src/"
            }
        },
        "config": {
            "sort-packages": true
        }
    }
    ```

2. **Install Monorepo Builder**:
    Run `composer install` in the root directory. This will install `symplify/monorepo-builder` and create the root `vendor` directory and `composer.lock` file.

### Step 2: Configure Monorepo Builder

1. **Create `monorepo-builder.php`**:
    Create the configuration file in the root:

    ```php
    <?php

    declare(strict_types=1);

    use Symplify\MonorepoBuilder\Config\MBConfig;

    return static function (MBConfig $mbConfig): void {
        // Location of packages/applications
        $mbConfig->packageDirectories([
            __DIR__ . '/apps',
            __DIR__ . '/packages',
        ]);

        // The "main" package - useful for CI and release workflows
        $mbConfig->defaultBranch('main');

        // Sync dependencies from packages to the root composer.json
        $mbConfig->packageDirectoriesExcludes([]);
        $mbConfig->dataToAppend([
            'require-dev' => [
                'pestphp/pest' => '^2.0',
                'laravel/pint' => '^1.0',
            ],
        ]);
    };
    ```

### Step 3: Relocate and Integrate Projects

1. **Create `apps` Directory**:
    Create the `apps` directory in the root if it doesn't exist.

2. **Move Projects**:
    Move the entire `bagisto` and `aureuserp` project folders into the `apps/` directory.

3. **Clean Sub-Project Dependencies**:
    **Crucially, delete the `vendor` directory and `composer.lock` file from within each individual Laravel project (`apps/bagisto`, `apps/aureuserp`).** The monorepo will now manage a single set of dependencies at the root level.

4. **Merge Dependencies**:
    From the root directory, run the following command:

    ```bash
    vendor/bin/monorepo-builder merge
    ```

    This command will read the `composer.json` from each project in `apps/` and merge their dependencies into the root `composer.json`.

5. **Install All Dependencies**:
    Run `composer install` from the root directory again. This will install all dependencies for all projects into the single, root `vendor` directory.

### Step 4: Autoloading & Shared Packages

1. **Configure Autoloading for Shared Packages**:
    To make code from `packages/` available to your Laravel apps, add it to the `autoload` section of the root `composer.json`:

    ```json
    "autoload": {
        "psr-4": {
            "HugMySoul\\SharedAuth\\": "packages/shared-auth/src/"
        }
    },
    ```

    After adding a new path, you must run `composer dump-autoload` from the root.

2. **Using a Shared Package**:
    You can now `use HugMySoul\SharedAuth\MyClass;` in any of the Laravel applications.

---

## 4. Workflow in the Monorepo

- **Running Artisan Commands**: To run a command for a specific project, `cd` into its directory:

    ```bash
    cd apps/bagisto
    php artisan migrate
    ```

- **Running Tests**: You can run tests for all projects from the root or for a specific project:

    ```bash
    # Run all tests
    vendor/bin/pest

    # Run tests for a single app
    vendor/bin/pest --filter "Bagisto"
    ```

- **CI/CD**: Your CI pipeline (e.g., GitHub Actions) should be configured to detect which `apps/` or `packages/` have changed in a commit/PR to only run tests and deployments for the affected projects.

---
