---
name: tune
description: Analyze recent Claude Code conversations and CLAUDE.md files to suggest improvements. Use when the user says "/tune", "tune my instructions", "improve my claude.md", or "review my instructions".
---

# sys-context-tuner

Analyze recent conversations and relevant markdown files to surface improvements for CLAUDE.md files.

## Step 1 — Determine scope

### If user typed `/tune global`
Confirm with the user:
- "You typed `global`. This will tune the global CLAUDE.md at `~/.claude/CLAUDE.md`."
- Print the full resolved path (e.g. `C:\Users\resti\.claude\CLAUDE.md`)
- Ask: "Is this correct, or did you mean something else? [y/n]"
- If no, ask what they meant and resolve from their answer.

### If user typed `/tune local` or `/tune` with no argument
Determine the most likely local path:
- Look at the current working directory
- Also check recent conversation history to find the most recently discussed or modified project directory
- Default suggestion: the project root of the most recently active project (print full path, e.g. `C:\github\sterkly\BitBoxMedia\FF-extension-template\`)
- Ask: "Tune the local CLAUDE.md at `{path}`? [y/n or enter a different path]"
- If they enter a path, resolve it and confirm before proceeding.

### If user typed `/tune {some/path}`
Attempt to find a CLAUDE.md at that path. Print the resolved full path and ask for confirmation before proceeding.

---

## Step 2 — Discover files to analyze

Find all files that will be read. Include:

**Conversation files:**
- All `.jsonl` files under `~/.claude/projects/{project-dir}/` (most recent 15-20)
- Count them and show the total

**Markdown context files in the scoped directory (recursive):**
- `CLAUDE.md` — the file being tuned
- `README.md`
- `EXTENSION.md`
- Any other `.md` files that appear to contain project conventions, rules, or configuration

**List all files found** with their paths before proceeding. Example output:
```
Files to analyze:

Conversations (18):
  ~/.claude/projects/-c-github-.../abc123.jsonl
  ...

Markdown context (4):
  C:\github\sterkly\BitBoxMedia\FF-extension-template\CLAUDE.md
  C:\github\sterkly\BitBoxMedia\FF-extension-template\README.md
  C:\github\sterkly\BitBoxMedia\FF-extension-template\EXTENSION.md
  C:\github\sterkly\BitBoxMedia\FF-extension-template\.notes\handoff.md
```

Ask: "Analyze these files? [y/n]"
If no, stop.

---

## Step 3 — Focus selection

Present a multiple choice menu:

```
What would you like to focus on?

1. Communication style
2. Code and file conventions
3. Workflow and process rules
4. Extension-specific rules
5. No focus — analyze everything

Enter a number (or press Enter for 5):
```

Store the selection. Pass it as focus context to each subagent.

---

## Step 4 — Spawn parallel subagents

Launch parallel Sonnet subagents to analyze conversations. Each agent reads:
- The CLAUDE.md being tuned
- A batch of conversation files
- The markdown context files

Batch conversations by size:
- Large (>100KB): 1-2 per agent
- Medium (10-100KB): 3-5 per agent
- Small (<10KB): 5-10 per agent

Agent prompt template:

```
You are analyzing Claude Code conversations to improve a CLAUDE.md file.

Focus area: {focus or "all areas"}

Read:
1. CLAUDE.md being tuned: {path}
2. Markdown context files: {list}
3. Conversations: {list of files}

Analyze the conversations against the CLAUDE.md. Find:
1. Instructions that exist but were violated (need reinforcement or rewording)
2. New patterns worth adding that match the focus area
3. Anything that appears outdated or no longer relevant

Output bullet points only. Be specific — quote the conversation and the rule where relevant.
```

---

## Step 5 — Aggregate and present findings

Combine all agent results into four sections:

1. **Instructions violated** — rules that were not followed (need stronger wording)
2. **Suggested additions** — new rules worth adding (scoped to focus area)
3. **Potentially outdated** — items that may no longer apply
4. **No action needed** — patterns that are working well (brief)

---

## Step 6 — Present diff-style suggested edits

For each finding that suggests a change, present a before/after diff:

```
SUGGESTED CHANGE — Communication style

- Never use semicolons in responses.
+ Never use semicolons or em dashes in any response, output, or file.

Reason: 3 conversations showed em dashes being used in responses despite the semicolon rule.
```

After showing all diffs, ask:
"Would you like me to apply any of these changes? Enter the numbers to apply (comma separated), 'all', or 'none'."

Apply only what the user confirms. Show a final summary of what was changed.
