---
name: clone-half
description: Clone a portion of the current conversation, discarding earlier context to reduce token usage. Defaults to keeping the last 50%. Use when the user says "clone half", "trim context", "half clone", or "/clone-half". Accepts an optional percentage like "/clone-half 30".
---

Clone a portion of the current conversation into a new session, discarding the earlier part to reduce token usage.

## Arguments

Optional percentage (10-90) of the conversation to KEEP. Defaults to 50.

```
/clone-half        → keep last 50%
/clone-half 30     → keep last 30%
/clone-half 75     → keep last 75%
```

If the user provides a value outside 10-90, tell them the valid range and ask them to try again.

## Steps

1. Check that `jq` is installed: `command -v jq`. If missing, stop and tell the user:
   - Mac: `brew install jq`
   - Linux: `apt install jq`
   - Windows (Git Bash): `winget install jqlang.jq`

2. Parse the percentage argument. Default to 50 if not provided. Validate 10-90 range.

3. Get the current session ID and project path:
   ```bash
   tail -1 ~/.claude/history.jsonl | jq -r '[.sessionId, .project] | @tsv'
   ```

4. Find half-clone-conversation.sh:
   ```bash
   find ~/.claude -name "half-clone-conversation.sh" 2>/dev/null | sort -V | tail -1
   ```

5. Run the preview to get conversation stats:
   ```bash
   <script-path> --preview <session-id> <project-path>
   ```

6. Calculate the cut point from the percentage and show a confirmation preview:
   - Total message count and how many will be kept vs discarded
   - First message that will be KEPT (truncated to 120 chars) — this is the new start
   - Last message in the session (truncated to 120 chars)
   - A 3-4 sentence summary of the key highlights in the kept portion
   - Show clearly: "Keeping last X% (~N messages). Discarding first ~N messages."
   - Ask: "Clone with these settings? [y/n]"
   - If no, stop with no action taken.

7. Pass the percentage to the script:
   ```bash
   <script-path> --keep-percent <percent> <session-id> <project-path>
   ```
   Always pass the project path from the history entry, not the current working directory.

8. Tell the user the clone is ready. Use `claude -r` and look for `[HALF-CLONE <timestamp>]`. The cloned session includes a note linking back to the original.
