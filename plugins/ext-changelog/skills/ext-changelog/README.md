# ext-changelog

Generates a clean, public-facing changelog and GitHub commit message for a browser extension release or update.

## When to trigger

Use this skill when the user asks to:
- Write a changelog or release notes
- Write version notes or a GitHub commit message
- "Changelog for this release"
- "Changelog between these versions"
- "Write a commit message"
- Provides a diff or list of changes and wants them documented

Always use this skill for changelog and commit generation even if the request seems simple.

## Two modes

**Standalone (called directly by user):** Asks Q1 (version handling) and Q4 (output file selection) before starting. Gets the current PST timestamp via PowerShell.

**Invoked from `publish-new-version`:** Q1 and Q4 answers are passed in. Does not re-ask them. Uses the timestamp passed in from the calling skill.

## How it works

### Step 0: Read EXTENSION.md (if present)

Reads the extension name, current version reference, and AMO slug. `manifest.json` is always the authoritative version source. If `EXTENSION.md` and `manifest.json` versions differ, the mismatch is flagged and the manifest value is used.

### Q1: Version handling (standalone only)

- **Bump version**: auto-increment using rollover rules (patch increments, rolls over at 9)
- **Custom version**: user provides exact string
- **Keep current**: no change

Version format is always exactly `major.minor.patch` with single digits in each part. Examples: 1.0.8 -> 1.0.9, 1.0.9 -> 1.1.0, 1.9.9 -> 2.0.0.

When bumping or setting a custom version, `manifest.json` is updated. If `EXTENSION.md` exists, `Current Version:` is updated. If `CLAUDE.md` exists with a `- Version:` line in the Manifest section, that is also updated.

### Q4: Output file selection (standalone only, multi-select)

- CHANGELOG.md (prepend to `.docs/CHANGELOG.md`) -- pre-selected
- COMMITS.md (prepend to `.docs/COMMITS.md`) -- pre-selected
- RELEASE_v{version}.md (save to `.builds/`) -- pre-selected

### Repo and uncommitted files check

Runs only if at least one doc output was selected. Finds the GitHub repo by reading `CLAUDE.md` for a github.com URL, or searching by repo name. Then runs `git status --short` to check for uncommitted changes.

**Q5** (asked only when: doc output selected AND repo found AND uncommitted files exist): Asks whether to use diffs from uncommitted files or the standard git log/last commit diff as the source for generation.

### Source diff

- Q5 answered Yes: uses `git diff HEAD` (staged + unstaged)
- Q5 not asked or answered No: uses git log / last commit diff
- No repo found: user provides changes manually

### Output generation

Generates two artifacts:

**Changelog** (public-facing):
- Written to `.docs/CHANGELOG.md`, prepended with a `---` separator
- Date/time header: `## YYYY-MM-DD hh:mm AM/PM PST`
- Entries grouped by category (Features, Fixes, Under the Hood)
- Each entry is one line starting with a hyphen
- Subject to all forbidden terms and character set rules (see below)

**Commit message** (developer-facing, not subject to changelog redaction rules):
- Written to `.docs/COMMITS.md`, prepended with a `---` separator
- Title format: `update v{version} - {summary of all changes}` (under 72 characters)
- Description grouped by area, using real file names and function names
- Technical and precise

## Forbidden terms (changelog only)

These terms must never appear in changelog output:
- Version numbers of any kind
- "lines" or line count references
- "search", "search functionality", "default search", or any reference to search behavior
- "Yahoo"
- Internal codenames: "template", "shared template", "shared core", "background-core", "seam"
- Any other product in the suite (ATUM, AIO, K2VPN, PDFify Pro, Metric Unit Conversion Calculator, Ad Cleanse, Manual Rack)
- Cross-product or suite references

## Character set (changelog only)

US keyboard characters only:
- No arrows
- No em dash or en dash
- No curly/smart quotes
- Bullets use plain hyphens only

## Inputs

- A project directory with `manifest.json`
- Optionally: `EXTENSION.md`, `CLAUDE.md`, git history
- Or: a manually provided release description or before/after diff (when no repo is found)

## Outputs

| File | Location | Description |
|---|---|---|
| CHANGELOG.md | `.docs/` | Public-facing release notes, new entry prepended |
| COMMITS.md | `.docs/` | GitHub commit title and description, new entry prepended |
| RELEASE_v{version}.md | `.builds/` | Standalone release file |

Only the files selected in Q4 are written.

## Edge cases and limitations

- If called from `publish-new-version`, Q1 and Q4 are never re-asked
- The `.docs/` directory is created if it doesn't exist
- New entries are always prepended, never appended; existing content is preserved
- Manifest version bump detection: if comparing two builds and no version bump is found, the skill flags it and suggests incrementing before shipping
- The commit message is intentionally unrestricted (version numbers, file names, internal terms are all fine there)

## Related skills

- `publish-new-version`: Calls this skill as part of a full release flow (bump version, package, generate docs)
