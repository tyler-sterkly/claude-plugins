---
name: sys-handoff
description: Write a structured handoff note before ending a session or switching accounts due to usage limits. Use this skill when the user says "handoff session", "handoff chat", "write handoff", "save session", "switching accounts", or "hitting my limit". Writes a handoff file so the next session picks up exactly where this one left off.
---

# Session Handoff Skill

Use this skill to create a handoff note before ending a session, hitting a usage limit, or switching to a different claude code account. The goal is for the next session to pick up exactly where this one left off with zero re-explaining.

## When to invoke

- User says "handoff session", "handoff chat", "write handoff", "save session"
- User says they are done for the day and want to save context
- Usage warning appears and user wants to preserve state

## Step 1 — gather context

If the session was working on a Firefox extension, check for `EXTENSION.md` in the project root. If it exists, read it and include the extension Name, Current Version, and AMO Slug in the handoff so the next session has immediate context without re-reading the codebase.

Before writing anything, review the current session to extract:

- what was being worked on (the active task and its current state)
- what was completed this session (finished tasks, merged changes, decisions made)
- what is in progress but not done (partial work, open files, half-finished changes)
- what was tried and rejected (approaches that did not work and why)
- any non-obvious context that is not in the code or CLAUDE.md (verbal agreements, reasoning behind decisions, gotchas discovered)
- what the next steps are (exactly what to do next when resuming)
- current model and effort level if relevant

## Step 2 — write the handoff file

Write the handoff to `.notes/handoff.md` in the current project root. Create the `.notes/` directory if it does not exist.

Use this structure:

```markdown
# Session Handoff
Date: <YYYY-MM-DD HH-MM-SS PST>
Account: <home or work>
Model: <model used>

## Extension (if applicable)
Name: <name> | Version: <version> | AMO Slug: <slug>

## Active Task
<one sentence describing what was being worked on>

## Completed This Session
- <item>
- <item>

## In Progress (not done)
<describe any partial work, what state it is in, what files are open or modified>

## Tried and Rejected
<anything that was attempted and did not work, and why, so the next session does not repeat it>

## Decisions Made
<any decisions made mid session that are not captured in code or CLAUDE.md>

## Non-Obvious Context
<anything the next session needs to know that is not in the codebase>

## Next Steps
1. <exact next action>
2. <following step>
3. <etc>

## Resume Instructions
To resume: open claude code in <project path>, read this file, then continue with the next steps above.
```

## Step 3 — also update auto memory if enabled

If auto memory is on (`/memory` shows it enabled), write a brief summary of the session to auto memory so it persists even if the handoff file gets deleted. One paragraph max covering the active task and key decisions.

## Step 4 — confirm to user

After writing the file, tell the user:
- the handoff was saved to `.notes/handoff.md`
- how to resume: in the new session, open claude code in the same folder and say "read .notes/handoff.md and continue from there"
- remind them to run loginwork or loginhome with the correct account before resuming

## Notes

- `.notes/` is a local only dot directory, it will not be committed to github
- be specific in next steps, vague instructions like "continue the task" are not useful
- if there were multiple tasks, list them all under in progress with their individual states
