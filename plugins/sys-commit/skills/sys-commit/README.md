# sys-commit

Generates a git commit title and body, gets user approval, then commits. Works standalone
or invoked by another skill. Never pushes.

## Modes

**Standalone** — called directly by the user. Asks:
1. Which repo to commit in
2. New changes or already committed?
3. If new: reads the diff or accepts a manual description
4. If already committed: accepts SHA(s), GitHub URL, or date range — resolves to commits,
   shows the list for confirmation, then builds the message from them

**Invoked** — called by ext-changelog or another skill. Receives `title`, `body`, and
`repo_path` directly. Skips all questions, goes straight to approval.

## Approval gate

Always shows the commit title and body to the user before committing. User can approve,
edit inline, or cancel. Nothing is committed without approval.

## Date range inputs (standalone, already-committed)

Accepts any of:
- Exact SHAs: `abc1234 def5678`
- GitHub URL: `https://github.com/owner/repo/commit/abc1234`
- Explicit range: `June 1 to June 15` / `2026-06-01 to 2026-06-15`
- Relative: `today`, `yesterday`, `last week`, `last 3 days`, `last month`
- Single day: `June 10`, `Monday`

Matched commits are shown to the user for confirmation before the message is built.

## Rules

- Never pushes under any circumstances
- Stops at `git commit`
- Confirms the commit hash after a successful commit

## Used by

- `ext-changelog` — receives the generated commit title + body and handles the commit step
