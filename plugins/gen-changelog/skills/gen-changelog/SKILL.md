---
name: gen-changelog
description: Generates a clean, public-facing changelog and GitHub commit message for a browser extension release or update. Use this skill whenever the user asks to write a changelog, release notes, version notes, or a GitHub commit title and description for any extension. Also triggers when the user says "write a changelog", "changelog for this release", "changelog between these versions", "write a commit message", or provides a diff/list of changes and wants them documented. Always use this skill for changelog and commit generation even if the request seems simple.
---

# Generate Changelog

Write a clean, public-facing changelog for a browser extension release or update.

## Step 0 — Read EXTENSION.md (optional)

Check for `EXTENSION.md` in the project root. The skill works fully without it -- it is supplementary context only.

If it exists, read it and use:
- **Name** — use as the extension name if manifest.json only has an i18n placeholder (e.g. `__MSG_extName__`); otherwise prefer the resolved name from _locales/en/messages.json
- **Current Version** — for reference only; manifest.json is always the authoritative version source. If the two differ, flag the mismatch to the user but use the manifest.json value
- **AMO Slug** — available if the changelog or release file needs to reference the listing URL

If the file does not exist, derive the extension name from manifest.json / _locales/en/messages.json as normal.

## Standalone vs. invoked mode

**Invoked from publish-new-version:** The following are passed in -- do not re-ask any of them:
- Q1 answer (version handling choice)
- Which doc files to produce (changelog, commits, release file -- derived from the Q4 doc output option)
- Timestamp (PST, 12-hour, no seconds) -- use this for all file headers
- `diffSource`: either `"uncommitted"` (use `git diff HEAD`) or `"last-commit"` (use standard git log)

Skip Q1, Q4, the repo/uncommitted check, and Q5 entirely. Go straight to **Source diff** using the passed-in `diffSource` value.

**Called standalone (directly by user):** Ask Q1 and Q4 below before doing anything else. Get the current timestamp in PST for file headers by running this PowerShell command -- never use system local time or any other timezone:

```powershell
[System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([System.DateTime]::UtcNow, 'Pacific Standard Time').ToString('yyyy-MM-dd hh:mm tt') + ' PST'
```

### Q1 -- Version handling (standalone only)

- Bump version (auto-increment using rollover rules below)
- Enter a custom version (user provides the exact version string)
- Keep the current version as-is

Rollover rules for auto-increment:

The version string is ALWAYS exactly three single-digit numbers separated by periods: `major.minor.patch`. Each part is always one digit (0-9). Never produce a version with two-digit parts, missing periods, or fewer than three parts.

To bump:
1. Parse the version string by splitting on `.` into exactly three parts: `[major, minor, patch]`
2. Increment `patch` by 1
3. If `patch` > 9: set `patch` = 0, increment `minor` by 1
4. If `minor` > 9: set `minor` = 0, increment `major` by 1
5. Rejoin with periods: `major.minor.patch`

Examples: 1.0.8 -> 1.0.9, 1.0.9 -> 1.1.0, 1.9.9 -> 2.0.0, 2.0.0 -> 2.0.1

**Validation:** After computing the new version, verify it matches the regex `^\d\.\d\.\d$` (exactly three single digits separated by periods). If it does not match, something went wrong -- stop and report the error.

After Q1 is answered, read `manifest.json` and apply the version choice:
- **Bump:** apply rollover rules, write the new version back to `manifest.json`. If `EXTENSION.md` exists, update the `Current Version:` line to match. If `CLAUDE.md` exists in the project root, update the `- Version:` line in the Manifest section to match.
- **Custom:** replace the version with the user-provided string, write it back. If `EXTENSION.md` exists, update the `Current Version:` line to match. If `CLAUDE.md` exists in the project root, update the `- Version:` line in the Manifest section to match.
- **Keep:** read the current version for use in naming, make no changes

### Q4 -- Outputs (standalone only, multi-select)

- CHANGELOG.md -- prepend entry to `.docs/CHANGELOG.md` *(pre-selected by default)*
- COMMITS.md -- prepend entry to `.docs/COMMITS.md` *(pre-selected by default)*
- RELEASE_v{version}.md -- save to `.builds/` *(pre-selected by default)*


## Repo and uncommitted files check

**If invoked from publish-new-version: skip this entire section.** The repo check and diff source decision were already handled there; use the passed-in `diffSource` value and go straight to Source diff.

**Standalone only:** Run this check only if at least one of CHANGELOG.md, COMMITS.md, or RELEASE file was selected in Q4. Skip entirely if none of those were selected.

### Find the GitHub repo

1. The project root folder name is already known (used for zip naming in publish-new-version, or derived from cwd in standalone). Use that as the candidate repo name.
2. Read `CLAUDE.md` in the project root (if it exists) and scan for a GitHub URL matching the pattern `github.com/{owner}/{repo}`. If found, that is the repo -- extract `{owner}/{repo}`.
3. If no URL was found in `CLAUDE.md`, use `mcp__github__search_repositories` to search for a repo whose name matches the root folder name. Pick the top result if one matches exactly; otherwise skip.

### Check for uncommitted files

If a GitHub repo was identified (either from CLAUDE.md or search), run `git status --short` in the project root to get the list of locally modified, added, or deleted files that have not yet been committed.

- If no uncommitted files are found, proceed normally. Q5 is not asked.
- If one or more uncommitted files are found, ask Q5.

### Q5 -- Use uncommitted file diffs

**Only ask Q5 when all three conditions are met:**
1. At least one of CHANGELOG.md, COMMITS.md, or RELEASE file was selected in Q4
2. A GitHub repo was identified
3. Uncommitted files were found

Present the list of uncommitted files to the user, then ask:

> "Uncommitted changes were found in the files above. Should the changelog, commits, and release notes be generated using the diffs from these uncommitted files?"

- Yes -- use the diffs of all uncommitted files as the source for documentation generation
- No -- use the standard diff approach (git log / last commit diff)

## Source diff

**If invoked from publish-new-version:** use the passed-in `diffSource` value directly:
- `"uncommitted"` -- run `git diff HEAD` and use the combined diff as source material
- `"last-commit"` -- use the standard approach (git log / last commit diff)

**If standalone:** use the Q5 answer:
- Q5 = Yes -- run `git diff HEAD` and use the combined diff as source material
- Q5 = No, or Q5 not asked -- use the standard approach (git log / last commit diff)
- No repo found at all -- prompt the user to provide the changes manually (a release description, list of changes, or before/after diff)

## Input

When no repo is found, one of:
- A release description or list of changes (single version)
- Two versions worth of changes to diff (before/after)

## Rules (enforce strictly)

### Forbidden terms -- never appear anywhere in output

- Version numbers of any kind
- "lines" or line count references
- "search", "search functionality", "default search", or any reference to search behavior
- "Yahoo"
- Internal codenames: "template", "shared template", "shared core", "background-core", "seam", or similar
- Any other product in the suite besides the one this changelog is for (ATUM / Access To User Manuals, AIO / All-in-One Productivity, K2VPN, PDFify Pro, Metric Unit Conversion Calculator, Ad Cleanse, Manual Rack)
- Cross-product or suite references of any kind

### Character set

Use only standard US keyboard characters. No special characters:
- No arrows (->  =>  ->)
- No em dash or en dash
- No curly/smart quotes (" " ' ')
- No bullet symbols other than plain hyphens (-)

### Style

- Concise and itemized
- Group entries by category, for example: Features, Fixes, Under the Hood
- Each entry is one line, starting with a plain hyphen
- Benefit-first, plain language, active voice
- No version numbers, dates, or metadata in the body

## Manifest version bump detection

If given two builds to compare, check the manifest.json version field in both:
- If the version has bumped, treat that as a release boundary and generate a changelog entry covering all changes since the last version.
- If no bump is detected, flag it and suggest the version should be incremented before shipping.

## Output

Write to `.docs/CHANGELOG.md` in the project root (create the `.docs/` directory if it does not exist):
- If `.docs/CHANGELOG.md` already exists, prepend the new entry to the top of the file. Insert `\n\n---\n\n` between the new entry and the existing content so entries are visually separated.
- If it does not exist, create it.
- Each entry starts with a date and time header: `## YYYY-MM-DD hh:mm AM/PM PST` (12-hour format, PST timezone, no seconds, passed in from publish-new-version, or current time if called standalone)
- Follow the date header with the categorized entries.

Write the commit title and description to `.docs/COMMITS.md` in the project root (create the `.docs/` directory if it does not exist):
- If `.docs/COMMITS.md` already exists, prepend the new entry. Insert `\n\n---\n\n` between the new entry and the existing content so entries are visually separated.
- If it does not exist, create it.
- Each entry starts with a date header: `## YYYY-MM-DD hh:mm AM/PM PST` (12-hour format, PST timezone, no seconds)
- Follow with the commit title and full description.

The `\n\n---\n\n` separator (a blank line, a `---` rule, and another blank line) applies whenever a new entry is prepended to any `.md` file this skill writes to.

Write both files by default.
When called from publish-new-version, write only the files specified in the passed-in doc file list (all 3 if version was bumped/custom, changelog + commits only if version was kept).

## GitHub commit message

Write alongside the changelog whenever the user asks, or always include it by default.

Commit messages are internal developer-facing artifacts. They are NOT subject to the changelog redaction rules. You can and should use:
- Version numbers
- Real file names and function names
- Technical terms like "search", "cookie", "template", "background-core", etc.
- References to other products in the suite if relevant

### Title

- Format: `update v{version} - {summary of all changes}`
- Example: `update v1.0.6 - fix cookie sync, add dark mode toggle, bump min Firefox version`
- The summary should cover all major areas of change in a brief comma-separated list
- Keep it under 72 characters total (GitHub truncates beyond that)
- No emojis
- Keep it concise but do not omit significant changes

### Description

- Group by area (e.g. Consent flow, Background, Housekeeping)
- Use real file names and function names
- Each bullet is one line starting with a plain hyphen
- Technical and precise

## Self-check before delivering

Scan the full output for every forbidden term before finishing:
- [ ] No version numbers
- [ ] No "lines"
- [ ] No "search" or "Yahoo"
- [ ] No internal codenames (template, background-core, shared core, seam, etc.)
- [ ] No other product names from the suite
- [ ] No non-US-keyboard characters
- [ ] .docs/CHANGELOG.md new entry prepended with 12h timestamp header, existing content preserved, `---` separator between new and old entries
- [ ] .docs/COMMITS.md new entry prepended with 12h timestamp header, existing content preserved, `---` separator between new and old entries
- [ ] Only the files selected in Q4 were written
- [ ] If EXTENSION.md exists: name used as fallback for i18n placeholders; manifest.json version used (mismatch flagged if versions differ)
- [ ] If standalone and version was bumped or set custom and CLAUDE.md exists: `- Version:` line in Manifest section updated to match
- [ ] If standalone: Q1 and Q4 were asked before any work began; manifest.json updated per Q1; repo check and Q5 ran as normal
- [ ] If invoked: Q1, Q4, timestamp, and diffSource were NOT re-asked -- all passed values used directly; repo check and Q5 skipped entirely
- [ ] Diff source is correct: git diff HEAD if diffSource="uncommitted" or Q5=yes; git log if diffSource="last-commit" or Q5=no/not asked
