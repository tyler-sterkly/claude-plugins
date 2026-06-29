---
name: ext-audit
description: Reviews all code in a Firefox MV3 browser extension and produces a prioritized update plan. Use this skill whenever the user asks to "audit", "plan updates for" an extension, or says things like "plan out changes", "what should I fix first", "prioritize changes". The output is a ranked plan file, not just a summary.
---

# Audit Firefox Extension

Two-phase skill: **Audit** (read and score the extension across six axes) then **Plan** (convert findings into a ranked, actionable update plan).

**NEVER read any file or folder whose name starts with `.` — skip `.assets/`, `.builds/`, `.git/`, and all dotfiles/dotfolders entirely.**

---

## Phase 1 — Audit

### 1.1 Read the project

Scan the root directory tree (skip dotfiles/dotfolders), then read these files:

- `EXTENSION.md` — if present, use as authoritative source for extension name, IDs, domains, and current version. manifest.json is still the authoritative version source; flag a mismatch if the two differ
- `manifest.json` — version, permissions, background, content scripts, gecko id
- `config.js` — extension id, affiliate params, LP URLs, tracking config
- `background.js` / `background-core.js` / any seam background file
- All `content_*.js` files
- `popup.html` / `popup.js` if present
- `newtab.html` / `newtab.js` if present
- `package.json` / `build.js` / any build script
- `landing/` directory or any LP-related files

Read enough of each file to understand its full behavior. Note specifics: event listeners, message types, API calls, async patterns, and anything non-obvious.

### 1.2 Score across six axes

Evaluate the extension against each axis below. For each finding, note:
- The file and line/section where the issue lives
- Severity: **critical** (broken or security risk), **high** (likely to cause bugs or AMO rejection), **medium** (correctness or maintainability risk), **low** (cleanup/style)
- Effort to fix: **small** (< 30 min), **medium** (30 min – 2 hrs), **large** (> 2 hrs)

#### Axis 1 — MV3 Compliance

- Service worker registered correctly in manifest (not persistent background page)
- No use of deprecated MV2 APIs (`chrome.browserAction`, `chrome.tabs.executeScript` without target, etc.)
- `host_permissions` separate from `permissions` (MV3 requirement)
- No use of remote code execution (`eval`, `Function()`, remotely hosted scripts in content_scripts)
- `web_accessible_resources` scoped correctly with `matches`
- `action` used instead of `browser_action` / `page_action`
- Service worker doesn't assume long-lived state (no in-memory caches that survive restarts without fallback)

#### Axis 2 — Security

- CSP in manifest: `extension_pages` policy present and not overly permissive (no `unsafe-eval`, no `unsafe-inline`)
- Permissions principle of least privilege: flag any permission that isn't clearly needed
- `<all_urls>` or broad host permissions — flag if present, verify necessity
- Content scripts: no `innerHTML` with unsanitized external data, no `document.write`
- External data (LP cookies, querystring params, fetch responses) treated as untrusted before use
- No secrets, API keys, or internal org names hardcoded in any file
- No `externally_connectable` unless intentional and scoped

#### Axis 3 — Architecture & Template Alignment

- `background-core.js` present and matches the shared `firefox-extension-template` pattern (seam file + core file split)
- `config.js` present with all expected keys: extension name, IDs, affiliate params, LP URLs, tracking endpoints
- Install/update flow uses `runtime.onInstalled` with `reason` check
- LP cookie logic uses permissive `fillAllMissingFromLp()` merge pattern (not a whitelist filter)
- Attribution: no hash desync risk (all keys present and defined before hashing)
- No Sterkly, BitBoxMedia, or internal org references in any user-visible or packaged file
- If `EXTENSION.md` exists: gecko ID, EXTID, FFADDID, and domains match what is in manifest.json and config.js — flag any mismatch as a medium finding
- Icon conventions: PNGs and source SVGs in `icons/`, `favicon.ico` at root
- Build output goes to `.builds/`, META-INF excluded from zips
- Install button classes: `jle-b-inst-btn` or `ctabtn` (never `le-b-inst-btn`)

#### Axis 4 — Correctness

- Attribution fields: all expected LP cookie fields present and populated before use
- No undefined or null values silently passed to attribution hash or tracking calls
- `runtime.onInstalled` vs `runtime.onStartup` used correctly (install-only logic gated on reason)
- Content scripts: SPA navigation handled if the extension operates on SPAs (e.g. `yt-navigate-finish` for YouTube)
- Message passing: all `sendMessage` calls have corresponding listeners; no unhandled message types
- Any `MutationObserver` has a disconnect path and doesn't leak on page unload
- Alarm handlers registered before alarms fire (not deferred)
- Fetch calls: errors caught, timeouts handled, no assumption of network availability in service worker startup

#### Axis 5 — Code Quality

- Naming: functions and variables named for what they do, not how
- No dead code: unused functions, commented-out blocks, unreachable branches
- Async: consistent use of `async/await` or Promises, no mixed patterns, no floating Promises
- No unnecessary global state in content scripts
- No duplicated logic that should be shared (especially across background and content)
- Comment coverage on non-obvious logic (attribution, timing-sensitive paths, known quirks)
- No `console.log` left in ship-ready code (only in dev/debug paths)

#### Axis 6 — Performance

- Service worker: no synchronous operations that block startup
- Content scripts: no polling loops — use event-driven patterns or `MutationObserver`
- `MutationObserver`: scoped to the narrowest subtree that covers the use case, not `document.body` unless necessary
- No unbounded fetch loops or retry logic without backoff
- `webRequest` / `declarativeNetRequest` rules: no overly broad match patterns if avoidable
- No large inline data blobs in JS files that could be loaded on demand instead

---

## Phase 2 — Plan

Convert all findings from Phase 1 into a structured plan. Group findings by priority tier, not by axis, so the most important work is always at the top regardless of which axis it came from.

### Plan format

Produce a markdown file saved as `AUDIT.md` in the project root (or wherever the user specifies). Structure:

```markdown
# Extension Audit — [Extension Name] [version]

Audited: [date]

## Summary

[2–4 sentence overview: overall health, biggest risk areas, rough scope of work]

## Critical

[Items that are broken, a security risk, or will cause AMO rejection. Fix before anything else.]

### [Short title]
- File(s): `filename.js` (line or section if helpful)
- Axis: [which of the six]
- Issue: [clear description of what's wrong]
- Fix: [specific, actionable — not "improve this" but "replace X with Y" or "add Z to line N"]
- Effort: small / medium / large

[repeat for each critical item]

## High

[Items likely to cause bugs in the field or that create meaningful technical debt.]

[same format]

## Medium

[Correctness or maintainability risks that aren't urgent but should be addressed.]

[same format]

## Low

[Cleanup, style, dead code, minor naming issues. Do these in a batch pass.]

[same format]

## What's Good

[Brief list of things that are solid and shouldn't be touched unnecessarily. Gives confidence about what to leave alone.]

## Recommended Order of Work

[Ordered list of the above items, factoring in dependencies. E.g. if a critical fix unblocks a high fix, reflect that. Keep it as a numbered list of titles from the sections above.]
```

---

## Rules

- Never access dotfiles or dotfolders.
- Never mention Sterkly, BitBoxMedia, or internal org names in AUDIT.md.
- Don't flag things that are intentional patterns (permissive LP merge, seam file split, `fillAllMissingFromLp`). These are correct.
- Don't invent issues. If code is fine, say so in "What's Good."
- Every finding must have a specific, actionable fix — not a vague recommendation.
- If a file is too long to read fully, read enough to cover all six axes for that file's domain. Prioritize manifest, config.js, and background files.
- Save AUDIT.md before responding. Then summarize the top 3–5 findings inline in chat so the user gets the gist without opening the file.
