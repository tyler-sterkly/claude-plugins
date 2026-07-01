# sys-context-clone

Clone the current Claude Code conversation into a new resumable session. Use it to branch off and try a different approach, or to shed early context when a conversation gets too long.

## Commands

### /clone

Full clone. Copies the entire conversation into a new session with all history intact.

```
/clone
```

Shows a preview (first message, last message, key highlights summary) and asks for confirmation before cloning. After confirming, use `claude -r` and look for `[CLONED <timestamp>]`.

### /clone-half

Partial clone. Copies a percentage of the conversation (from the end), discarding earlier messages. A reference note is appended to the new session linking back to the original.

```
/clone-half          → keep last 50% (default)
/clone-half 30       → keep last 30%
/clone-half 75       → keep last 75%
```

Valid range: 10-90. Shows a preview of the cut point and asks for confirmation before cloning. After confirming, use `claude -r` and look for `[HALF-CLONE <timestamp>]`.

## Requirements

- `jq` must be installed:
  - Mac: `brew install jq`
  - Linux: `apt install jq`
  - Windows (Git Bash): `winget install jqlang.jq`
- Shell scripts must be executable after install:

```bash
chmod +x ~/.claude/plugins/cache/*/sys-context-clone/*/scripts/*.sh
```

## How it works

Both commands read the current session ID from `~/.claude/history.jsonl`, find the conversation JSONL file, and produce a new JSONL file with fresh UUIDs and an updated history entry. The original session is never modified. `clone-half` additionally halves token counts and strips thinking blocks to avoid API errors when resuming.
