---
name: sys-commit
description: Generates a git commit title and body, shows the user for approval, then commits. Works standalone (asks the user for context) or invoked by another skill (receives title, body, and repo path directly). Always stops at commit — never pushes. Use this skill whenever a commit needs to be made in any repo, standalone or as part of a larger workflow.
---

# sys-commit

Handles the final git commit step for any repo. Generates or receives a commit title and
body, shows the user for approval, then commits. Never pushes.

---

## Invoked mode

Called by ext-changelog or another skill. The caller passes:

- `title` — commit title string, ready to use
- `body` — commit body string, ready to use
- `repo_path` — absolute path to the repo root
- `already_committed` — always false when invoked

Skip all questions. Go straight to the Approval step.

---

## Standalone mode

Called directly by the user. Ask questions in this order.

### Q1 — Repo path

Ask which repo to commit in. Accept:
- An absolute path typed directly
- A short name matched against known repos under `C:\github\` (e.g. "claude-plugins"
  resolves to `C:\github\sterkly\claude-plugins\`)

Run `git status --short` in the resolved path to confirm it is a git repo and show the
user what is staged/unstaged.

### Q2 — Already committed or new changes?

- **New** — unstaged or staged changes exist, need a new commit. Go to Q3.
- **Already committed** — changes are already in one or more commits. Go to Q4.

### Q3 — Diff source (new commit only)

Options:
- Use current diff (`git diff HEAD`) — read automatically, no further input needed
- Describe manually — user types a description of the changes

Read the diff or description, generate title + body following the format rules below.
Go to Approval step.

### Q4 — Which commits? (already committed only)

Accept any of the following. Show the user what was resolved before continuing.

**Exact SHA(s)**
One or more commit hashes, space or comma separated. Run `git show <sha>` for each.

**GitHub commit URL**
Parse `owner`, `repo`, `sha` from the URL. Fetch via GitHub MCP (`mcp__github__get_commit`).
Fall back to `git show` if MCP is unavailable.

**Date / range**
Resolve to absolute PST dates, then run `git log` with `--after` and `--before`.
Accept all of:
- Explicit: "June 1 to June 15", "2026-06-01 to 2026-06-15"
- Relative: "today", "yesterday", "last week", "last 3 days", "last month"
- Single day: "June 10", "Monday"

Show the user the list of matched commits (SHA + title + date) and ask them to confirm
before building the commit message from them.

Build title + body from the resolved commit content. Go to Approval step.

---

## Commit title + body format rules

### Title
- Format: `verb noun — detail` (match the style of the target repo's git log)
- Under 72 characters
- No emojis
- Lowercase, plain language
- Cover all major areas of change in a brief summary

### Body
- Group by area
- Each bullet starts with a plain hyphen
- Use real file names and function names
- Technical and precise
- No forbidden terms (inherited from caller context if invoked by ext-changelog)

---

## Approval step

Display the following before committing:

```
Commit title:
  <title>

Commit body:
  <body>

Approve? (yes / edit / cancel)
```

- **yes** — run `git add -A && git commit -m "<title>" -m "<body>"` in `repo_path`. Done.
  Do not push. Confirm the commit hash to the user.
- **edit** — user provides changes inline. Rebuild and re-display. Re-confirm.
- **cancel** — abort with no changes. Tell the user nothing was committed.

---

## Never push

sys-commit always stops after `git commit`. It does not run `git push` under any
circumstances, does not suggest pushing in the same response, and does not offer it
as a next step.
