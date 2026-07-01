# sys-handoff

Writes a structured session handoff note so the next session resumes with zero re-explaining. Saves to `.notes/handoff.md` in the current project root.

## When to trigger

Use this skill when the user says:
- "Handoff session"
- "Handoff chat"
- "Write handoff"
- "Save session"
- "Switching accounts"
- "Hitting my limit"
- Done for the day and wants to preserve context

## How it works

1. **Gather context** from the current session: active task, completed work, in-progress items, tried-and-rejected approaches, non-obvious context, and next steps. If working on a Firefox extension, reads EXTENSION.md for name, version, and AMO slug.
2. **Write the handoff file** to `.notes/handoff.md` (creates `.notes/` directory if it does not exist)
3. **Update auto memory** (if enabled) with a brief session summary so it persists even if the handoff file is deleted
4. **Confirm** to the user with the save location and resume instructions

## Handoff file structure

```markdown
# Session Handoff
Date: <YYYY-MM-DD HH-MM-SS PST>
Account: <home or work>
Model: <model used>

## Extension (if applicable)
Name: <name> | Version: <version> | AMO Slug: <slug>

## Active Task
<one sentence>

## Completed This Session
## In Progress (not done)
## Tried and Rejected
## Decisions Made
## Non-Obvious Context
## Next Steps
## Resume Instructions
```

## Rules

- `.notes/` is a local-only dotfolder; it is not committed to GitHub
- Next Steps must be specific -- vague instructions like "continue the task" are not useful
- If there were multiple tasks, list each with its individual state under In Progress

## Output

File saved at `.notes/handoff.md`. User is told to open Claude Code in the same folder and say "read .notes/handoff.md and continue from there" in the new session.
