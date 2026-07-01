---
name: ext-publish
description: Bump the manifest version, package the extension for publishing, and generate a changelog entry. Use this skill whenever the user says "publish new version", "publish this version", "package for release", "bump version and publish", or any variation of publishing or releasing a new build of an extension. Always use this skill for publish/release tasks even if the request seems simple.
---

# Publish New Version

Package the extension for publishing with interactive options for version handling, comment stripping, linting, and documentation.

## Step 0 -- Read EXTENSION.md and detect template

Before anything else, look for `EXTENSION.md` in the project root.

**If the file exists:** Read it and store all values. Then check if this is the template project: the `Dir:` field is `FF-extension-template`, or the root folder name is `FF-extension-template`.

**If the file does not exist:** Check if the root folder name is `FF-extension-template`.

### Template project path

If this is the template project, follow these rules and skip Steps 1-3 entirely:

- Do NOT display EXTENSION.md fields or ask the user to verify them
- Do NOT ask Q1, Q2, Q3, or Q4
- Do NOT bump the version or modify manifest.json
- Do NOT run the linter
- Do NOT create a zip
- Do NOT create a RELEASE file
- Do NOT trigger ext-verbiage
- Fixed outputs: CHANGELOG.md and COMMITS.md only

**If EXTENSION.md exists:** Read it silently and proceed directly to Step 4 using the fixed outputs above.

**If EXTENSION.md does not exist:** Notify the user that `EXTENSION.md` was not found, ask for the extension Name (needed for changelog generation), then proceed to Step 4.

### Non-template project path

**If the file exists:** Display the following fields in a Unicode box table (exactly this format — use box-drawing characters, not markdown pipes):

```
┌──────────────────────┬──────────────────────────────────────────┐
│        Field         │                  Value                   │
├──────────────────────┼──────────────────────────────────────────┤
│ Name                 │ {Name}                                   │
├──────────────────────┼──────────────────────────────────────────┤
│ Short Name           │ {Short Name}                             │
├──────────────────────┼──────────────────────────────────────────┤
│ Current Version      │ {Current Version}                        │
├──────────────────────┼──────────────────────────────────────────┤
│ AMO Slug             │ {AMO Slug}                               │
├──────────────────────┼──────────────────────────────────────────┤
│ Firefox Extension ID │ {Firefox Extension ID}                   │
├──────────────────────┼──────────────────────────────────────────┤
│ Chrome Extension ID  │ {Chrome Extension ID}                    │
├──────────────────────┼──────────────────────────────────────────┤
│ Primary Domain       │ {Primary Domain}                         │
├──────────────────────┼──────────────────────────────────────────┤
│ Search Domain        │ {Search Domain}                          │
├──────────────────────┼──────────────────────────────────────────┤
│ Search URL           │ {Search URL}                             │
├──────────────────────┼──────────────────────────────────────────┤
│ Search Keyword       │ {Search Keyword}                         │
└──────────────────────┴──────────────────────────────────────────┘
```

Show only these fields, in this order. Do not show any other fields from EXTENSION.md (no AMO URLs, no branding, no notes). After the table, ask the user to confirm the data is correct before proceeding.

If Name or AMO Slug are missing or blank, ask the user to provide them before proceeding. Current Version is read from `manifest.json` (authoritative source) — do not ask for it.

**If the file does not exist:** Ask the user to provide Name and AMO Slug before proceeding.

Store all retrieved/provided values for use in later steps.

## Step 0b -- Detect "republish" shortcut

If the user's prompt is exactly "republish" (case-insensitive, no other words), still run Step 0 (read EXTENSION.md and verify data), then skip all questions in Step 1 and use these defaults:

- Version: keep current (no bump)
- Comment stripping: no (zip gets `-hascom` suffix)
- Linter: skip
- Outputs: none (no CHANGELOG, no COMMITS, no RELEASE file, no verbiage refresh)

Jump directly to Step 3 (Package the extension).

## Step 1 -- Ask upfront questions

Use AskUserQuestion. Ask Q1, Q2, and Q3 together in one call, then check GitHub, then ask Q4 separately.

### Q1 -- Version handling
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

### Q2 -- Comment stripping
- Yes, strip comments from code files in the zip
- No, keep comments in the zip

If the user chooses NOT to strip comments, append `-hascom` to the zip filename (before `.zip`). The `-hascom` suffix signals "has comments" -- comments were not removed from this build.

### Q3 -- Run linter
- Yes, run `web-ext lint` after packaging
- No, skip linting

### GitHub uncommitted check (before Q4)

Before asking Q4, check the project for uncommitted changes:

1. Read `CLAUDE.md` in the project root and scan for a GitHub URL matching `github.com/{owner}/{repo}`. If found, that is the repo.
2. Run `git status --short` in the project root.
3. If uncommitted files are found, store the list — Q4 will include an extra option.
4. If no repo URL was found in CLAUDE.md or no uncommitted files exist, Q4 has no extra option.

### Q4 -- Outputs (multi-select)

Ask Q4 in a separate AskUserQuestion call after the GitHub check. Build the options based on Q1 and the uncommitted check:

**Doc output option** (always shown, pre-selected by default):
- If Q1 = bump or custom: label is `Generate changelog, commits entry, and release file` — produces all three: `.docs/CHANGELOG.md`, `.docs/COMMITS.md`, `.builds/RELEASE_v{version}.md`
- If Q1 = keep: label is `Generate changelog and commits entry` — produces only `.docs/CHANGELOG.md` and `.docs/COMMITS.md` (no release file)

**Verbiage option** (always shown, not pre-selected):
- `Write new listing verbiage` — trigger ext-verbiage skill

**Uncommitted changes option** (only shown if uncommitted files were found):
- `Use uncommitted file changes as source for changelog content` — uses `git diff HEAD` as the diff source instead of the last commit. Pre-selected by default when shown.

## Step 2 -- Handle version

Based on Q1:

- **Bump:** read `manifest.json`, apply the rollover rules, write the new version back to `manifest.json`. If `EXTENSION.md` exists, update the `Current Version:` line to match. If `CLAUDE.md` exists in the project root, update the `- Version:` line in the Manifest section to match.
- **Custom:** read `manifest.json`, replace the version with the user-provided string, write it back. If `EXTENSION.md` exists, update the `Current Version:` line to match. If `CLAUDE.md` exists in the project root, update the `- Version:` line in the Manifest section to match.
- **Keep:** do nothing. Read the current version from `manifest.json` for use in naming.

## Step 3 -- Package the extension

Zip all project files needed for publishing.

### Exclusion rules

Read `C:\github\.claude\.gitignore_global` and apply every pattern in it as an exclusion. In addition to whatever is in that file, also always exclude:

- `META-INF/` and anything inside it
- `node_modules/`
- `__MACOSX/`

The gitignore_global file is the single source of truth for what does not ship. If a pattern is missing from it, add it there rather than hardcoding exclusions in this skill.

### Pre-zip audit

Before creating the zip, list every file that will be included. Scan the list and **stop with an error** if any of the following appear:

- Any file or directory matching a pattern from `.gitignore_global`
- Any dotfile or dotfolder (name starts with `.`)
- `META-INF/`, `node_modules/`, `__MACOSX/`
- Any `.md` file (CLAUDE.md, README.md, EXTENSION.md, CHANGELOG.md, COMMITS.md, LISTING.md, or any other)
- `Thumbs.db`, `desktop.ini`, `.DS_Store`
- Any `.vscode/` directory content

If the audit finds excluded files, report them and do not proceed until they are removed from the staging set.

### Zip naming

Produce ONE zip:

- If comments were stripped (Q2 = yes): `{project-name}-{version}.zip`
- If comments were kept (Q2 = no): `{project-name}-{version}-hascom.zip`

Where `{project-name}` is the root folder name of the project and `{version}` is the version from manifest.json (after any bump/change in Step 3).

Output the zip to `.builds/` in the project root. Create `.builds/` if it does not exist.

### Comment stripping (when Q2 = yes)

Strip comments from code files INSIDE the zip only. Never modify the actual project files. The working tree keeps all comments.

Strip comments from these file types only:
- `.js` -- line comments (`// ...`) and block comments (`/* ... */`)
- `.css` -- block comments (`/* ... */`)
- `.html` -- HTML comments (`<!-- ... -->`), including comments inside inline `<script>` and `<style>` blocks

Do NOT alter:
- `.json` files -- JSON has no comments, and `messages.json` `description` fields are data, not comments
- Images, fonts, or any binary asset

Stripping must be string-safe. Never remove a `//` or `/*` that lives inside a string literal, a URL such as `https://`, a regex, or a template literal. If safe stripping of a given file is uncertain, keep that file's comments rather than risk corrupting it.

**Collapse blank lines after stripping:** After all comment removal on a file, replace runs of 3 or more consecutive newlines with exactly 2 newlines (one blank line). This prevents large gaps from appearing where multi-line comments or comment blocks were removed. Single blank lines between code blocks are preserved as-is.

**Validate the stripped build before finishing:**
- `node --check` every `.js` file in the stripped set
- If Q3 = yes: run `web-ext lint` on the stripped build. If the linter returns errors, stop and report them. Warnings are reported but do not block packaging.
- If any check fails, the stripping corrupted something. Fix it or fall back to keeping comments in the offending file, then re-validate. Do not output a zip with corrupted files.

**Verify comments were actually removed:**

After stripping and before zipping, scan every stripped file to confirm no comments survived. For each file type, grep for comment patterns:

- **`.js` files:** search for `//` (that is not inside a string or URL) and `/*`. Use a pattern like `^\s*//` for line comments and `/\*` for block comment openers. Ignore matches inside string literals (between quotes) and URLs (`://`).
- **`.css` files:** search for `/*`.
- **`.html` files:** search for `<!--`.

For each file where comments are found:
1. Report the file name and the comment lines found.
2. Re-strip that file (a second, targeted pass).
3. Re-check. If comments still remain after the second pass, flag the file for manual review and report it in Step 5, but do not block the build -- some edge cases (comments inside strings, data URIs, conditional comments) are false positives.

**What counts as a false positive (do not flag these):**
- `://` inside URLs (e.g. `https://example.com`)
- `//` or `/*` inside string literals (quoted with `'`, `"`, or backtick)
- Conditional comments in HTML (e.g. `<!--[if IE]>`)
- CDATA sections in HTML
- `sourceMappingURL` comments (`//# sourceMappingURL=...`) -- these are tooling directives, not developer comments, but should still be stripped if present

The comment verification must pass before the zip is created. Report the result (clean / files re-stripped / false positives noted) in Step 5.

### Post-zip audit

After the zip is created, list its contents (e.g. `unzip -l` or equivalent) and verify:

1. **No excluded files leaked in** -- scan the file list against the same exclusion rules from the pre-zip audit. If any excluded file is found inside the zip, report it as an error and rebuild.
2. **manifest.json is present** -- the zip must contain `manifest.json` at the root level.
3. **No empty directories** -- flag any directories with zero files (some zip tools include them).

Report the post-zip audit result in Step 5. If the audit fails, do not report the zip as ready.

### Linting when comments are kept (Q2 = no)

If Q2 = no (comments kept) and Q3 = yes (run linter): run `web-ext lint` directly on the project source now. If the linter returns errors, stop and report them. Warnings are reported but do not block packaging.

## Step 3b -- Scan for placeholder text

After the zip is confirmed ready, scan every file that was included in the zip for leftover placeholder text.

Search for these patterns (case-insensitive) in all included files:
- `REPLACE`
- `PLACEHOLDER`

For each match found, report:
- File path (relative to project root)
- Line number
- The matching line (trimmed)

If any matches are found, **stop and report them to the user** before proceeding to Step 5. Do not continue until the user confirms the placeholders are intentional or fixes them.

If no matches are found, note it briefly in the Step 5 report ("Placeholder scan: clean") and continue.

## Step 3c -- Check publishing rules

After the placeholder scan, check for extension-specific publishing rules in the project root:

1. Look for a `## Publishing Rules` section in `CLAUDE.md`
2. If not found there, look for it in `README.md`
3. If a Publishing Rules section is found, read it and follow every rule listed before proceeding to Step 4. These are project-level overrides and requirements specific to this extension (e.g. additional files that must be included, pre-zip steps, special AMO notes).
4. If no Publishing Rules section is found in either file, continue normally.

## Step 4 -- Generate documentation (conditional)

Only produce the items the user selected in Q4. Skip entirely if nothing was selected.

Pass the following to ext-changelog when triggering it:
- Q1 answer (version handling choice and any custom version string)
- Which doc files to produce (derived from Q4 doc output option: all 3 if bump/custom, changelog+commits only if keep)
- Current timestamp in PST, 12-hour format, no seconds (see Timestamp Format below)
- Diff source decision: if user selected the uncommitted changes option in Q4, pass `diffSource: "uncommitted"` so ext-changelog uses `git diff HEAD` and skips its own Q5. If not selected, pass `diffSource: "last-commit"` so ext-changelog uses the standard git log approach and also skips Q5.

ext-changelog must NOT ask Q5 when called from this skill — the diff source decision was already made in Q4 above.

### CHANGELOG.md

Trigger the ext-changelog skill. It will prepend the new entry to `.docs/CHANGELOG.md`.

### COMMITS.md

ext-changelog also handles prepending the commit title and description to `.docs/COMMITS.md`. Only triggered if the user selected it in Q4.

### RELEASE_v{version}.md

Pull the new entry that was just prepended to `.docs/CHANGELOG.md` and save it as `RELEASE_v{version}.md` in `.builds/`. Example: `RELEASE_v1.0.5.md`.

If CHANGELOG.md was not selected but RELEASE was, generate the changelog entry content directly (without writing to `.docs/CHANGELOG.md`) and save it to the RELEASE file.

This file contains the changelog entry for the AMO version submission.

### Listing verbiage refresh

If selected: trigger the ext-verbiage skill to regenerate the listing copy. After it completes, remind the user to update the manifest description in manifest.json if it changed.

## Step 5 -- Confirm

**If template project**, report:

- Version: kept at {version} (template -- no bump)
- Zip: skipped (template)
- Which documentation files were created/updated (or "none")

**If non-template project**, output the report as a markdown table with two columns: Item and Result. Use exactly this structure:

| Item | Result |
|---|---|
| **Version** | old -> new (or "kept at {version}" if unchanged) |
| **Linter** | Passed / warnings only / errors found / skipped (include warning count and brief description if any) |
| **Zip** | `.builds/{zip-filename}` ({size} KB) |
| **Comments** | Stripped (node --check passed, web-ext lint passed, comment scan: clean / re-stripped / false positives noted) OR Kept (`-hascom` suffix applied) |
| **Placeholder scan** | Clean OR Issues found: {detail} |
| **CHANGELOG.md** | Prepended to `.docs/CHANGELOG.md` OR Skipped |
| **COMMITS.md** | Prepended to `.docs/COMMITS.md` OR Skipped |
| **RELEASE file** | `.builds/RELEASE_v{version}.md` OR Skipped |
| **Listing verbiage** | Refreshed OR Skipped |

Do not use prose, bullets, or any other format for this report -- the table is the required format. Do NOT add any note that the AMO upload is manual, that the upload must be done by the user, or that you cannot upload to AMO. End the report once the table is output.

## Timestamp Format

All timestamps throughout this skill and in generated documentation use 12-hour format, PST timezone:

`YYYY-MM-DD hh:mm AM/PM PST`

Example: `2026-06-23 02:42 PM PST`

**Getting the current time in PST:** Always run this PowerShell command to get the timestamp -- never use system local time or any other timezone:

```powershell
[System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([System.DateTime]::UtcNow, 'Pacific Standard Time').ToString('yyyy-MM-dd hh:mm tt') + ' PST'
```

Pass the result to ext-changelog so headers in CHANGELOG.md and COMMITS.md use the same format.

## Self-check

- [ ] Template detected correctly (Dir field or root folder name = FF-extension-template)
- [ ] If template: Steps 1-3 skipped, proceeded to Step 4, no zip, no RELEASE file, no verbiage refresh, no version bump, CHANGELOG + COMMITS only
- [ ] If template and EXTENSION.md missing: user notified, Name asked before proceeding
- [ ] If template and EXTENSION.md exists: read silently, no verification prompt shown
- [ ] If non-template: EXTENSION.md read at start, all found fields shown to user for verification
- [ ] If non-template: EXTENSION.md fields displayed as Unicode box table (Name, Short Name, Current Version, AMO Slug, Firefox Extension ID, Chrome Extension ID, Primary Domain, Search Domain, Search URL, Search Keyword — no URLs, no branding, no notes)
- [ ] If non-template: missing required fields (Name, AMO Slug) asked for if blank or file absent
- [ ] "republish" shortcut detected and handled correctly (Step 0 still runs; no bump, no strip, no lint, no docs)
- [ ] Q1, Q2, Q3 asked together in one AskUserQuestion call; Q4 asked separately after GitHub check
- [ ] GitHub uncommitted check ran before Q4: git status --short executed, repo found via CLAUDE.md
- [ ] Q4 doc option is one combined choice: all 3 files if bumping/custom, changelog+commits only if keeping version
- [ ] Q4 uncommitted changes option shown only if uncommitted files were found; hidden otherwise
- [ ] Q4 doc option pre-selected by default; uncommitted changes option pre-selected if shown
- [ ] Linter runs once, after comment stripping, only if user chose yes in Q3
- [ ] manifest.json version handled correctly per Q1 choice
- [ ] If version was bumped or set custom and EXTENSION.md exists: Current Version updated to match
- [ ] If version was bumped or set custom and CLAUDE.md exists: `- Version:` line in Manifest section updated to match
- [ ] Exclusion rules read from `C:\github\.claude\.gitignore_global` (single source of truth)
- [ ] Pre-zip audit ran: no excluded files in the staging set
- [ ] ONE zip produced with correct name (plain or `-hascom` suffix)
- [ ] Post-zip audit ran: listed zip contents, confirmed no excluded files leaked in, manifest.json present, no empty dirs
- [ ] Publishing rules check ran (Step 3c): CLAUDE.md and README.md scanned for "## Publishing Rules"; any rules found were followed before proceeding
- [ ] If comments stripped: blank lines collapsed (no runs of 3+ newlines), validated with node --check and web-ext lint
- [ ] If comments stripped: post-strip comment scan ran on all JS/CSS/HTML files, surviving comments re-stripped or flagged as false positives
- [ ] If comments kept: `-hascom` appended to zip filename
- [ ] Placeholder scan (Step 3b) ran on all included files; any REPLACE/PLACEHOLDER matches reported and user confirmed before continuing
- [ ] Only the documentation files selected in Q4 were created
- [ ] RELEASE file named `RELEASE_v{version}.md` (not RELEASE_NOTES.md)
- [ ] RELEASE file contains changelog entry only — no AMO URLs or reviewer notes appended
- [ ] All timestamps use 12h PST format (hh:mm AM/PM PST)
- [ ] Q1, doc file selections, timestamp, and diffSource passed to ext-changelog when triggered
- [ ] ext-changelog did NOT ask Q5 -- diff source was decided in Q4 and passed in
- [ ] Report does NOT mention that the AMO upload is manual or that you cannot upload to AMO
