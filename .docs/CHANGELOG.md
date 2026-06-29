## 2026-06-29 06:11 AM PST

### New Skills

- ext-context: examines a Firefox extension project and generates a CLAUDE.md file with full architecture, API surface, and coding conventions
- ext-duplicate: scaffolds a new extension from an existing one, wires config, genericizes brand identifiers, builds icons and verbiage
- ext-ids: checks, prompts for, and generates Chrome Store ID and Firefox UUID for an extension
- ext-ingest: builds a new extension from a template zip and reference zips with full placeholder wiring and verification
- ext-publish: full release pipeline covering version bump, comment stripping, linting, zip packaging, and changelog generation
- ext-verbiage: writes all public-facing AMO listing copy including manifest description, summary, full description, tags, and categories
- sys-catch: searches past conversations for "Good catch" moments and writes or updates GOOD_CATCH.md
- sys-handoff: writes a structured session handoff note so the next session resumes with zero re-explaining
- sys-web-audit: reviews UI files against Web Interface Guidelines fetched from the Vercel source

### Updates

- ext-duplicate: cross-references updated to use current skill names (ext-ids, ext-icons, ext-verbiage)
- ext-publish: cross-references updated to use current skill names (ext-changelog, ext-verbiage, sys-commit)
- ext-website: cross-references updated to use ext-legal and ext-icons instead of old skill names
