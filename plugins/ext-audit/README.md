# ext-audit

Two-phase skill that audits a Firefox MV3 extension across six quality axes and converts findings into a ranked, actionable update plan saved as `AUDIT.md`.

## When to trigger

Use this skill when the user asks to:
- "Audit this extension"
- "Plan updates for this extension"
- "Plan out changes" or "what should I fix first"
- "Prioritize changes"

The output is a ranked plan file, not just a summary.

## Two phases

**Phase 1 -- Audit:** Reads all project files (excluding dotfiles/dotfolders) and scores the extension across six axes.

**Phase 2 -- Plan:** Converts findings into a structured AUDIT.md grouped by priority tier (Critical, High, Medium, Low).

## Six audit axes

1. **MV3 Compliance** -- service worker registration, deprecated APIs, host_permissions, remote code execution, web_accessible_resources scoping
2. **Security** -- CSP, least-privilege permissions, broad host permissions, XSS risk in DOM manipulation, exposed secrets
3. **Architecture & Template Alignment** -- background-core.js seam pattern, config.js keys, LP cookie logic, org names in packaged files
4. **Correctness** -- attribution fields, install vs startup logic, SPA navigation handling, message passing, alarms
5. **Code Quality** -- naming, dead code, async consistency, global state, duplicated logic
6. **Performance** -- blocking startup operations, polling vs event-driven, MutationObserver scoping, fetch loops

## What it reads

All non-dotfile project files including manifest.json, config.js, background.js, background-core.js (presence only), contentscript.js, popup.html/js, newtab.html/js, package.json, build scripts, and landing page files.

If `EXTENSION.md` exists in the project root, it is used as the authoritative source for extension name, IDs, and domains. Any mismatch with manifest.json or config.js is flagged.

## Output

Saves `AUDIT.md` to the project root (or wherever the user specifies). Structure:

- Summary (2-4 sentences on overall health)
- Critical section (broken, security risk, or AMO rejection risk)
- High section (likely bugs or significant technical debt)
- Medium section (correctness or maintainability risks)
- Low section (cleanup, style, dead code)
- What's Good (solid things that should not be touched)
- Recommended Order of Work (numbered, dependency-aware)

After saving, summarizes the top 3-5 findings inline in chat.

## Inputs

- A Firefox extension project directory (any structure)
- Optionally: EXTENSION.md for authoritative identity data

## Rules

- Never access dotfiles or dotfolders
- Never mention Sterkly, BitBoxMedia, or internal org names in AUDIT.md
- Do not flag intentional patterns (permissive LP merge, seam file split, fillAllMissingFromLp)
- Every finding must have a specific, actionable fix -- not a vague recommendation
- Save AUDIT.md before responding

## Related skills

- `ext-review`: Code quality review with a different focus (AMO policy compliance, security findings saved to docs/review.md)
- `ext-context`: Generates a CLAUDE.md context file for the extension
