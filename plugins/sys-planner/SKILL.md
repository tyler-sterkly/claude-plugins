---
name: sys-planner
description: "PNR-integrated persistent planning system. Keeps PLAN.md, FINDINGS.md, and PROGRESS.md in a project-specific .plans\\ directory and injects plan context automatically on every turn. Gated on PNR_ENABLED=true — use /plan-arm to enable, /plan-disarm to disable. Use /plan-status to check phase progress, /plan-check for a cross-project overview and cleanup, /plan-attest to fingerprint the plan, /plan-goal and /plan-loop for long-running tasks."
user-invocable: false
allowed-tools: "Read Write Edit Bash Glob Grep"
hooks:
  UserPromptSubmit:
    - hooks:
        - type: command
          command: "SH=\"${CLAUDE_SKILL_DIR}/scripts/inject-plan.sh\"; [ -f \"$SH\" ] || SH=\"$HOME/.claude/skills/sys-planner/scripts/inject-plan.sh\"; [ -f \"$SH\" ] && sh \"$SH\" --context=userprompt; exit 0"
  PreToolUse:
    - matcher: "Write|Edit|Bash|Read|Glob|Grep"
      hooks:
        - type: command
          command: "SH=\"${CLAUDE_SKILL_DIR}/scripts/inject-plan.sh\"; [ -f \"$SH\" ] || SH=\"$HOME/.claude/skills/sys-planner/scripts/inject-plan.sh\"; [ -f \"$SH\" ] && sh \"$SH\" --context=pretool; exit 0"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "if [ -f \".plans/PLAN.md\" ] || [ -f \".plans/.active_plan\" ]; then echo '[sys-planner] Update PROGRESS.md with what you just did. If a phase is now complete, update PLAN.md status from in_progress to complete.'; fi"
  Stop:
    - hooks:
        - type: command
          command: "SH=\"${CLAUDE_SKILL_DIR}/scripts/gate-stop.sh\"; [ -f \"$SH\" ] || SH=\"$HOME/.claude/skills/sys-planner/scripts/gate-stop.sh\"; [ -n \"${SH:-}\" ] && [ -f \"$SH\" ] && sh \"$SH\"; exit 0"
  PreCompact:
    - matcher: "*"
      hooks:
        - type: command
          command: "SH=\"${CLAUDE_SKILL_DIR}/scripts/inject-plan.sh\"; [ -f \"$SH\" ] || SH=\"$HOME/.claude/skills/sys-planner/scripts/inject-plan.sh\"; [ -f \"$SH\" ] && sh \"$SH\" --context=precompact; exit 0"
metadata:
  version: "1.0.0"
---

# sys-planner

Persistent planning system integrated with PNR. Keeps your plan in Claude's attention throughout a session by injecting it automatically — no need to re-paste or re-reference it manually.

## How it activates

No slash command needed. sys-planner activates automatically when both of these are true:

1. `PNR_ENABLED=true` is set in settings.json
2. `.plans/PLAN.md` exists in the project directory (written by ext-pnr when you present a plan)

ext-pnr writing the plan IS the trigger. Once PLAN.md exists, every message you send includes the plan head and recent progress automatically.

## Files maintained

All files live in `.plans/` inside the relevant project directory. The directory is chosen by ext-pnr when it writes the plan.

| File | Written by | Purpose |
|---|---|---|
| `.plans/PLAN.md` | ext-pnr | Live plan; overwritten on each plan presentation; injected each turn |
| `.plans/REPORT.md` | ext-pnr | Same content as PLAN at write time; not injected |
| `.plans/FINDINGS.md` | Claude | Research notes; accumulates across session |
| `.plans/PROGRESS.md` | Claude | Session log; accumulates across session |
| `.plans/.cache/PLAN_YYYY-MM-DD_HH-MM-SS.md` | ext-pnr | Timestamped archive; PST; never overwritten |

## Hook behavior

**UserPromptSubmit** — fires once per turn when you send a message. Injects top 50 lines of PLAN.md plus last 20 lines of PROGRESS.md. Silent if PNR_ENABLED is not set or PLAN.md does not exist.

**PreToolUse** — fires before each tool call. Active only in gated/autonomous mode. Injects top 30 lines of PLAN.md. Off in interactive mode to avoid the token cost.

**PostToolUse** — fires after Write or Edit. Reminds Claude to update PROGRESS.md and mark completed phases in PLAN.md.

**Stop** — fires when Claude finishes a turn. In interactive mode: advisory only, always allows stop. In gated mode: may block if a phase is still in_progress.

**PreCompact** — fires before context compaction. Reminds Claude to flush notes to PROGRESS.md before context is summarized.

## Slash commands

- `/plan-arm` — enable PNR (sets PNR_ENABLED=true in settings.json)
- `/plan-disarm` — disable PNR (sets PNR_ENABLED=false in settings.json)
- `/plan-status` — print current phase progress inline
- `/plan-check` — cross-project plan table; prompts to delete completed plans
- `/plan-attest` — fingerprint PLAN.md; hooks will reject it if it changes unexpectedly
- `/plan-goal` — set a goal condition composed from the active plan (composes with /goal)
- `/plan-loop` — run the plan on a loop cadence (composes with /loop)

## Gated and autonomous mode

For long-running or unsupervised tasks. Requires explicit activation:

```bash
# Gated: Claude cannot stop while a phase is in_progress
sh scripts/init-session.sh --gated "Task name"

# Autonomous: low recitation (no PreToolUse injection), no hard gate
sh scripts/init-session.sh --autonomous "Task name"
```

This creates a named plan directory `.plans/<slug>/` and writes `.mode`. Without this step, sys-planner runs in interactive mode: context injection on turn-start only, Stop hook advisory only.

## Checking gated status

```bash
cat .plans/.mode          # "autonomous gate" / "autonomous" / absent = interactive
cat .plans/.stop_blocks   # current gate block count (cap default 20)
```

## Exiting gated mode

- Mark the in_progress phase complete in PLAN.md — next stop is allowed
- Delete `.plans/.mode` — gate disables immediately
- Cap exhaustion (20 blocks, configurable via PWF_GATE_CAP) — gate allows stop automatically
- Stall detection (no new ledger lines since last block) — gate allows stop automatically

## Platform gate behavior

The hard gate ({"decision":"block"}) is Claude Code only. Other platforms degrade:

- Cursor, Kiro, Pi: soft nudge after stop — not a true gate
- OpenCode, Gemini CLI: notification only — no enforcement

See `docs/knowledge-base.md` for full platform tier details.

## Security

For unattended runs, run `/plan-attest` after finalising PLAN.md. The hook will SHA-256 fingerprint the file and block injection if it changes unexpectedly. Required in gated/autonomous mode — the hook enforces this automatically.

## Templates

Copy from `templates/` to start a new plan:

- `PLAN.md` — standard phase-tracking template
- `FINDINGS.md` — research and discovery notes
- `PROGRESS.md` — session log
- `PLAN_analytics.md` — alternate template for data/metrics-heavy plans
- `FINDINGS_analytics.md` — alternate findings template with SQL/metrics sections
- `loop.md` — copy to `.claude/loop.md` to make bare `/loop` planning-aware
