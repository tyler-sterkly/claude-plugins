# sys-context-clone

Two conversation cloning skills for Claude Code. Clones the current session into a new resumable conversation so you can branch off or shed early context.

## Skills

- `clone` (SKILL.md) — full clone, all history preserved
- `clone-half` (SKILL-HALF.md) — partial clone, keeps a configurable percentage from the end (default 50%, range 10-90%)

## Shell scripts

Both skills rely on shell scripts in `scripts/`:

- `scripts/clone-conversation.sh` — used by `clone`
- `scripts/half-clone-conversation.sh` — used by `clone-half`

The skills find these scripts via `find ~/.claude -name "*.sh"` so they must be installed somewhere under `~/.claude`.

## Installation note

After installing this plugin, the shell scripts need to be executable:

```bash
chmod +x ~/.claude/plugins/cache/*/sys-context-clone/*/scripts/*.sh
```

## Design decisions

- Scripts are pure bash with no Python or Node dependencies
- Works on macOS (bash 3.2+), Linux, and Git Bash on Windows
- `clone-half` uses ceiling division for keep count — rounds up, never down
- `clone-half` accepts `--keep-percent N` (10-90); defaults to 50
- `clone-half` also halves token counts and strips thinking blocks to avoid API errors on resume
- Both scripts detect and exclude the `/clone` or `/clone-half` command itself so it does not appear in the branched conversation
- Date formatting uses `%-d` with a `%e` + sed fallback for systems that do not support `%-d` (Git Bash on Windows)
- Both skills require `jq` and check for it upfront with clear install instructions per platform
- Command detection regex matches both `dx:clone`/`dx:half-clone` (legacy ykdojo) and `clone`/`clone-half` (this plugin)
