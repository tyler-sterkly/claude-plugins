# ext-review

Performs a comprehensive code quality review of a Firefox browser extension covering code quality, security, AMO policy compliance, performance, and architecture. Saves output to `docs/review.md` with a timestamp.

## When to trigger

Use this skill when the user asks to:
- "Review extension"
- "Code quality review"
- "Check AMO compliance"
- "Review before submitting"
- Says "ext-review" explicitly

## Review dimensions

### Code Quality
Clean, readable, consistent code; well-named functions; dead code; async handling; error handling; obvious bugs.

### Security
Minimal permissions; safe user data handling; hardcoded URLs; XSS risk in DOM manipulation; correctly scoped content scripts; no exposed secrets.

### AMO Policy Compliance
Justified and minimal permissions; no remote code execution (eval, remote scripts); correct match patterns; honest about what the extension does; no practices that trigger AMO review flags.

### Performance
Unnecessary listeners or observers; blocking or expensive operations; lean service worker; content scripts injected only where needed; memory leak risk.

### Architecture and Structure
Logical file structure; centralized shared logic; correct background-core.js / seam pattern; appropriate config.js use; clean build process.

### Manifest and Metadata
Correct version; required fields present; correctly declared icons; correct browser_specific_settings. If EXTENSION.md exists, checks that version, gecko ID, EXTID, and domains match manifest.json and config.js -- flags any mismatches.

## Inputs

A Firefox extension project directory (all non-dotfile files are read).

## Output

Saves `docs/review.md` to the project directory (creates docs/ if it does not exist) with:

- Extension name and generated timestamp
- Summary (3-5 sentences covering overall state and most important issues)
- Issue Counts by severity (Critical, Major, Minor, Suggestion)
- Detailed findings per dimension
- All Issues table (Severity, Area, File, Issue, Recommendation)

Severity definitions:
- Critical -- will cause a bug, security issue, or AMO rejection
- Major -- should be fixed before next release
- Minor -- worth fixing but not urgent
- Suggestion -- improvement idea, not a problem

## Rules

- Never access any file or folder whose name starts with `.`
- Be specific -- reference actual file names, function names, and line numbers where possible
- Do not pad the review -- if an area looks good, say so briefly
- Do not mention internal org names in the output
- Save docs/review.md before responding
- Confirm the file was saved and give a brief summary of the most important findings in chat

## Related skills

- `ext-audit`: Produces a prioritized update plan (AUDIT.md) with different focus
- `ext-context`: Generates a CLAUDE.md context file for the extension
