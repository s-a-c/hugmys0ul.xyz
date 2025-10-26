# PR: chore(markdown) — markdownlint baseline, ignores, and fixes

Summary
- Added a markdownlint baseline and ignore list, then fixed remaining violations across non-generated docs.
- Goal: achieve zero markdownlint errors while preserving intended meaning and formatting and minimizing churn.
- Lint result after changes: 0 errors across repository-scoped targets.

Tools and versions
- markdownlint-cli2 v0.18.1 (markdownlint v0.38.0)
- Config files introduced/updated:
  - [`.markdownlint.jsonc`](.markdownlint.jsonc)
  - [`.markdownlint-cli2.jsonc`](.markdownlint-cli2.jsonc)
  - [`.markdownlintignore`](.markdownlintignore)

Key configuration decisions
- MD013/line-length: relaxed to 500 to avoid mass reflows and preserve readability; still ignores code blocks, tables, URLs [`.markdownlint.jsonc`](.markdownlint.jsonc:25).
- MD029/ol-prefix: set to style "ordered" to respect explicit ordered numbering and reduce churn [`.markdownlint.jsonc`](.markdownlint.jsonc:16).
- Headings and structure:
  - Prefer ATX-style headings (MD003) where feasible; allow multiple H1s (MD025=false) to reduce churn [`.markdownlint.jsonc`](.markdownlint.jsonc:5).
  - Require a space after heading markers (MD018=true).
- Code blocks:
  - Require language hints for fenced code blocks (MD040=true).
  - Prefer fenced style and backticks (MD046, MD048).
- Spacing:
  - Preserve two-space hard line breaks; otherwise trim trailing spaces (MD009) [`.markdownlint.jsonc`](.markdownlint.jsonc:20).
  - Collapse multiple blank lines (MD012).
- Allow inline HTML (MD033=false) to avoid disrupting badges/layouts.
- Ignores: robust exclusions for vendor and generated content in [`.markdownlintignore`](.markdownlintignore) and [`.markdownlint-cli2.jsonc`](.markdownlint-cli2.jsonc) to prevent false positives and upstream file churn.

Scope and notable file fixes
- Fixed invalid TOC anchor fragments generated from “&” in:
  - [ai/AI-GUIDELINES/000-index.md](ai/AI-GUIDELINES/000-index.md:12)
- Normalized nested fenced blocks and added languages for code fences:
  - [ai/AI-GUIDELINES/Documentation/060-templates/020-documentation-template.md](ai/AI-GUIDELINES/Documentation/060-templates/020-documentation-template.md:108) — used quadruple-backtick outer fence for nested ```php```.
  - [ai/AI-GUIDELINES/PHP-Laravel/010-project-overview.md](ai/AI-GUIDELINES/PHP-Laravel/010-project-overview.md:31) — directory tree fenced with ```text```.
  - [ai/AI-GUIDELINES/PHP-Laravel/030-testing-standards.md](ai/AI-GUIDELINES/PHP-Laravel/030-testing-standards.md:85) — fixed malformed nested fences; unified to ```text```.
  - [specs/001-integrated-commerce-platform/quickstart.md](specs/001-integrated-commerce-platform/quickstart.md:12) — directory tree fenced with ```text```.
- Replaced emphasis-as-heading (MD036) with neutral notes:
  - [specs/001-integrated-commerce-platform/checklists/implementation-process.md](specs/001-integrated-commerce-platform/checklists/implementation-process.md:14)
- Fixed heading-level increments (MD001) and fenced language hints:
  - [ai/drafts/plans/010-monorepo-laravel-migration-plan.md](ai/drafts/plans/010-monorepo-laravel-migration-plan.md:7)

Commands to reproduce
- Lint with centralized globs (recommended):
  - npx markdownlint-cli2 --fix
- Or explicit patterns (equivalent to cli2 config):
  - npx markdownlint-cli2 "**/*.md" "**/*.mdx" --fix --config .markdownlint.jsonc --ignore-path .markdownlintignore

Result
- After fixes and ignores: 0 errors across 104 files.
- Command output: “Summary: 0 error(s)”.

CI and docs
- Prose content preserved; no mass line-wrap changes introduced.
- Code blocks and front matter untouched besides adding language identifiers.
- Documentation rendering verified for key docs (index and templates).

Notes and next steps
- No Git remotes detected, so a PR could not be opened automatically. The branch is created locally:
  - Branch: chore/markdownlint-cleanup
  - Commit includes configs and targeted fixes.
- To push and open PR:
  1) git remote add origin <REMOTE_URL>
  2) git push -u origin chore/markdownlint-cleanup
  3) Open a PR in your VCS UI with this body.

Change list (primary)
- [`.markdownlint.jsonc`](.markdownlint.jsonc)
- [`.markdownlint-cli2.jsonc`](.markdownlint-cli2.jsonc)
- [`.markdownlintignore`](.markdownlintignore)
- [ai/AI-GUIDELINES/000-index.md](ai/AI-GUIDELINES/000-index.md)
- [ai/AI-GUIDELINES/Documentation/060-templates/020-documentation-template.md](ai/AI-GUIDELINES/Documentation/060-templates/020-documentation-template.md)
- [ai/AI-GUIDELINES/PHP-Laravel/010-project-overview.md](ai/AI-GUIDELINES/PHP-Laravel/010-project-overview.md)
- [ai/AI-GUIDELINES/PHP-Laravel/030-testing-standards.md](ai/AI-GUIDELINES/PHP-Laravel/030-testing-standards.md)
- [ai/drafts/plans/010-monorepo-laravel-migration-plan.md](ai/drafts/plans/010-monorepo-laravel-migration-plan.md)
- [specs/001-integrated-commerce-platform/checklists/implementation-process.md](specs/001-integrated-commerce-platform/checklists/implementation-process.md)
- [specs/001-integrated-commerce-platform/quickstart.md](specs/001-integrated-commerce-platform/quickstart.md)
