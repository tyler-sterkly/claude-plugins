# sys-context-tuner

Analyzes your recent Claude Code conversations and suggests improvements to your `CLAUDE.md` files. Run it periodically to keep your instructions sharp based on how sessions actually went.

## Command

```
/tune                        → tune local CLAUDE.md (auto-detects project path)
/tune local                  → same, with explicit path confirmation
/tune global                 → tune ~/.claude/CLAUDE.md
/tune C:\path\to\project\    → tune CLAUDE.md at a specific path
```

## What it does

1. Determines the scope and confirms the path with you
2. Discovers all files to analyze — conversation history and markdown context files — and lists them for your approval
3. Presents a focus menu (communication style, code conventions, workflow rules, extension rules, or everything)
4. Spawns parallel subagents to analyze conversations against your CLAUDE.md
5. Returns findings across four categories:
   - Instructions that were violated and need stronger wording
   - Patterns worth adding (scoped to your focus area)
   - Items that appear outdated or no longer relevant
   - Patterns that are working well
6. Shows diff-style before/after for every suggested edit
7. Asks which changes to apply — nothing is written until you confirm

## Requirements

- `jq` must be installed:
  - Mac: `brew install jq`
  - Linux: `apt install jq`
  - Windows (Git Bash): `winget install jqlang.jq`
