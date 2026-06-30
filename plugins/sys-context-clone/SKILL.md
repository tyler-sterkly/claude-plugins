---
name: clone
description: Clone the current conversation so the user can branch off and try a different approach. Use when the user says "clone session", "clone conversation", "branch off", or "/clone".
---

Clone the current conversation into a new resumable session with full history preserved.

## Steps

1. Check that `jq` is installed: `command -v jq`. If missing, stop and tell the user:
   - Mac: `brew install jq`
   - Linux: `apt install jq`
   - Windows (Git Bash): `winget install jqlang.jq`

2. Get the current session ID and project path:
   ```bash
   tail -1 ~/.claude/history.jsonl | jq -r '[.sessionId, .project] | @tsv'
   ```

3. Find clone-conversation.sh:
   ```bash
   find ~/.claude -name "clone-conversation.sh" 2>/dev/null | sort -V | tail -1
   ```

4. Show a confirmation preview:
   - Total message count in the session
   - First user message (truncated to 120 chars)
   - Last user message (truncated to 120 chars)
   - A 3-4 sentence summary of the key highlights between first and last
   - Ask: "Clone this full conversation into a new session? [y/n]"
   - If no, stop with no action taken.

5. Run the clone:
   ```bash
   <script-path> <session-id> <project-path>
   ```
   Always pass the project path from the history entry, not the current working directory.

6. Tell the user the clone is ready. Use `claude -r` and look for `[CLONED <timestamp>]`.
