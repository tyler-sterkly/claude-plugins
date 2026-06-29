# ext-publish

Full release pipeline for Firefox extensions: version bump, comment stripping, linting, zip packaging, and changelog/commit documentation generation.

## When to trigger

Use this skill when the user asks to:
- "Publish new version"
- "Publish this version"
- "Package for release"
- "Bump version and publish"
- Any variation of publishing or releasing a new build of a Firefox extension

## Inputs

- A Firefox extension project directory
- Optionally: EXTENSION.md for identity data

## Special modes

**Template project:** If the project is FF-extension-template (detected via Dir field in EXTENSION.md or root folder name), Steps 1-3 are skipped. Only CHANGELOG.md and COMMITS.md are produced -- no version bump, no zip, no RELEASE file, no verbiage refresh.

**Republish shortcut:** If the user's prompt is exactly "republish", runs Step 0 (read/verify EXTENSION.md) then skips all questions and uses defaults (keep version, no stripping, no lint, no docs). Goes straight to packaging.

## Questions asked

Q1-Q3 are asked together, Q4 separately after the GitHub uncommitted check:

- **Q1:** Version handling -- bump, custom, or keep
- **Q2:** Comment stripping -- yes (strip) or no (keep; appends -hascom to zip filename)
- **Q3:** Run linter -- yes or skip
- **Q4 (multi-select):** Outputs -- changelog/commits/release file, new listing verbiage, use uncommitted file diffs (shown only when uncommitted files exist)

## How it works

1. Read EXTENSION.md and display key fields in a Unicode box table for verification
2. Ask Q1-Q4
3. Apply version change to manifest.json (and EXTENSION.md / CLAUDE.md if they exist)
4. Package the extension:
   - Read exclusion rules from C:\github\.claude\.gitignore_global
   - Pre-zip audit: confirm no excluded files in staging set
   - Strip comments from JS/CSS/HTML inside the zip only (never modifies working tree)
   - Validate with node --check and web-ext lint
   - Verify comments were actually removed (re-strip any that survived)
   - Scan for REPLACE/PLACEHOLDER tokens
   - Check for "## Publishing Rules" in CLAUDE.md or README.md
   - Post-zip audit: confirm no excluded files leaked in, manifest.json present
5. Generate documentation via ext-changelog (if selected in Q4)

## Zip naming

- Comments stripped: `{project-name}-{version}.zip`
- Comments kept: `{project-name}-{version}-hascom.zip`

Output goes to `.builds/` in the project root.

## Comment stripping rules

Strips from .js (// and /* */), .css (/* */), and .html (<!-- -->) only. Never modifies .json files or binary assets. String-safe: never strips // or /* inside string literals, URLs (https://), regexes, or template literals. Collapses runs of 3+ consecutive newlines to 2 after stripping.

## Outputs

| File | Location | Description |
|---|---|---|
| {project-name}-{version}.zip | .builds/ | Packaged extension |
| CHANGELOG.md | .docs/ | Public-facing release notes (if selected) |
| COMMITS.md | .docs/ | Commit title and description (if selected) |
| RELEASE_v{version}.md | .builds/ | Standalone release file (if selected) |

## Related skills

- `ext-changelog`: Called to produce CHANGELOG.md and COMMITS.md
- `ext-verbiage`: Called when listing verbiage refresh is selected
- `sys-commit`: Called by ext-changelog to handle the git commit
