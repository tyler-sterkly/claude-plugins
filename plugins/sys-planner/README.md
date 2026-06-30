# sys-planner

PNR-integrated persistent planning system for Claude Code.

Keeps your plan in Claude's attention throughout a session by injecting it automatically on every turn. No slash command needed — activates as soon as `PNR_ENABLED=true` and `.plans/PLAN.md` exists.

---

## How it works

1. You ask Claude for a plan on a task.
2. ext-pnr writes PLAN.md (and REPORT.md) to `.plans/` inside the project directory.
3. sys-planner hooks fire on every turn. Claude sees the plan head and recent progress automatically.

That is it for interactive use. No init step required.

---

## Files

| File | Written by | Purpose |
|---|---|---|
| `.plans/PLAN.md` | ext-pnr | Live plan — overwritten on each plan presentation |
| `.plans/REPORT.md` | ext-pnr | Snapshot at write time — not injected |
| `.plans/FINDINGS.md` | Claude | Research notes — accumulates |
| `.plans/PROGRESS.md` | Claude | Session log — accumulates |
| `.plans/.cache/PLAN_YYYY-MM-DD_HH-MM-SS.md` | ext-pnr | Timestamped archive — never overwritten |

---

## Slash commands

- `/plan-status` — print phase progress inline
- `/plan-attest` — fingerprint PLAN.md (required for gated/autonomous mode)
- `/plan-goal` — compose a goal condition from the active plan
- `/plan-loop` — run the plan on a loop cadence

---

## Gated mode (long-running tasks)

For autonomous or supervised-but-uninterrupted work. Claude cannot stop while a phase is in_progress.

```bash
# Start a gated session
sh scripts/init-session.sh --gated "Task name"

# Attest the plan before running unattended
/plan-attest
```

Writes `.plans/.mode`, generates a nonce, resets the block counter. Run `/plan-attest` after finalising PLAN.md.

Gated mode requires Claude Code. Other platforms degrade to advisory or notification only — see `docs/knowledge-base.md`.

---

## Checking status

```bash
cat .plans/.mode          # mode: "autonomous gate" / "autonomous" / absent = interactive
cat .plans/.stop_blocks   # gate block count
sh scripts/check-complete.sh  # phase advisory
```

---

## After /clear or compaction

```bash
python3 scripts/session-catchup.py
```

Prints the plan head, recent progress, and ledger summary so Claude can resume without re-reading history.

---

## Templates

Copy from `templates/` to bootstrap a new plan:

| File | Use for |
|---|---|
| `PLAN.md` | Standard multi-phase plans |
| `FINDINGS.md` | Research and discovery notes |
| `PROGRESS.md` | Session logging |
| `PLAN_analytics.md` | Data / metrics-heavy plans |
| `FINDINGS_analytics.md` | SQL and data findings |
| `loop.md` | Copy to `.claude/loop.md` for planning-aware `/loop` |

---

## Requirements

- Claude Code with `PNR_ENABLED=true` in settings.json
- ext-pnr installed (writes PLAN.md to `.plans/`)
- sh (any POSIX shell) for shell scripts
- Python 3 for session-catchup.py and sync-platforms.py
- openssl or python3 for nonce generation (optional — falls back to no-nonce mode)

---

## Origin

Forked from planning-with-files by OthmanAdi. Key differences: PNR_ENABLED gate instead of slash command, .plans/ directory instead of project root, uppercase file names, ext-pnr integration, .cache/ for archives.
