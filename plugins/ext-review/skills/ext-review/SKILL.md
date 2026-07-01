---
name: ext-review
description: Perform a comprehensive code quality review of a Firefox browser extension covering code quality, security, AMO policy compliance, performance, and architecture. Saves output to docs/review.md with a timestamp. Use when the user says "review extension", "code quality review", "check AMO compliance", "review before submitting", or explicitly says "ext-review".
---

Perform a comprehensive review of the Firefox browser extension in the current project directory and save the results to `docs/review.md`, creating the `docs/` folder if it doesn't exist.

**NEVER access any file or folder whose name starts with `.` — skip them entirely.**

## Step 1 — Read the project

Scan the root directory tree (excluding anything starting with `.`), then read all of the following if present:

- `EXTENSION.md` — if present, use its data (name, IDs, domains, AMO URLs, version) as the authoritative source for extension identity throughout the review

- `manifest.json`
- `config.js`
- `background.js` / `background-core.js` / any seam background file
- All `content_*.js` files
- `popup.html` / `popup.js`
- `newtab.html` / `newtab.js`
- `package.json` / `build.js` / any build script
- `icons/` folder
- `landing/` folder and any LP-related files
- `_locales/` if present
- Any `*.test.js` or test files

Read every file thoroughly — not just structure but actual logic, event listeners, API calls, message passing, and anything non-obvious.

## Step 2 — Review across all dimensions

Evaluate the extension across each of the following areas:

### Code Quality
- Is the code clean, readable, and consistent?
- Are functions well-named and appropriately scoped?
- Is there dead code, unused variables, or redundant logic?
- Are async operations handled correctly?
- Is error handling present and appropriate?
- Are there any obvious bugs or logic errors?

### Security
- Are permissions in manifest.json minimal and justified?
- Is any user data handled safely?
- Are external URLs or API endpoints hardcoded safely?
- Is there any XSS risk in DOM manipulation?
- Are content scripts scoped correctly?
- Is any sensitive data (keys, tokens) exposed?

### AMO Policy Compliance
- Are all permissions justified and minimal?
- Is there any remote code execution risk (eval, remote scripts)?
- Are content scripts restricted to appropriate match patterns?
- Is the extension honest about what it does?
- Are there any practices that would trigger AMO review flags?

### Performance
- Are there unnecessary listeners or observers?
- Are any operations blocking or expensive?
- Is the background service worker kept lean?
- Are content scripts injected only where needed?
- Is there any memory leak risk (listeners not cleaned up, etc.)?

### Architecture & Structure
- Is the file structure logical and consistent?
- Is shared logic properly centralized or duplicated across files?
- Does it follow the background-core.js / seam pattern correctly if applicable?
- Is config.js used appropriately?
- Is the build process clean?

### Manifest & Metadata
- Is the version correct and following the versioning convention?
- Are all required fields present?
- Are icons declared correctly?
- Is browser_specific_settings correct?
- If `EXTENSION.md` exists: do the version, gecko ID, EXTID, and domains match what's in manifest.json and config.js? Flag any mismatches.

## Step 3 — Write docs/review.md

Save the review to `docs/review.md` with the following structure:

---

```markdown
# Extension Review — [Extension Name]

**Generated:** [YYYY-MM-DD HH-MM-SS PST]

## Summary

[3-5 sentences covering the overall state of the extension. Call out the most important issues and the general health of the codebase.]

**Issues:** Critical: [n] | Major: [n] | Minor: [n] | Suggestions: [n]

---

## Code Quality

[Detailed findings. For each issue include: what it is, where it is (file + line if possible), why it matters, and what to do about it.]

## Security

[Detailed findings.]

## AMO Policy Compliance

[Detailed findings. Flag anything that could cause a rejection.]

## Performance

[Detailed findings.]

## Architecture & Structure

[Detailed findings.]

## Manifest & Metadata

[Detailed findings.]

---

## All Issues

| Severity | Area | File | Issue | Recommendation |
|----------|------|------|-------|----------------|
| Critical | ... | ... | ... | ... |
| Major | ... | ... | ... | ... |
| Minor | ... | ... | ... | ... |
| Suggestion | ... | ... | ... | ... |
```

---

## Rules

- **Never access any file or folder whose name starts with `.`**
- Be specific. Reference actual file names, function names, and line numbers where possible.
- Don't pad the review. If an area looks good, say so briefly and move on.
- Don't mention Sterkly, BitBoxMedia, or any internal org names in the output.
- Severity: Critical = bug/security/AMO rejection | Major = fix before release | Minor = not urgent | Suggestion = improvement idea
- Save to `docs/review.md` before responding.
- Confirm the file was saved and give a brief summary of the most important findings in chat.
