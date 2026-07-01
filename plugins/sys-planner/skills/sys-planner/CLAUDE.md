# sys-planner

PNR-integrated persistent planning system. Fork of planning-with-files (OthmanAdi).
Stores planning state in .plans\ inside the relevant project directory.
Context injection is gated on PNR_ENABLED=true — the trigger is ext-pnr writing PLAN.md, not a slash command.

## Design decisions

- PNR_ENABLED=true is the gate for context injection. No manual init needed for basic interactive use.
- .plans\ not project root: keeps planning state together and uses the global dot-prefix gitignore.
- All file names uppercase (PLAN.md, FINDINGS.md, PROGRESS.md) for consistency with PNR.
- .plans\.cache\ for timestamped PLAN.md archives (written by ext-pnr).
- PreToolUse injection is OFF in interactive mode (avoids ~68% token overhead). Activates only when .mode file is present (gated/autonomous).
- Gated mode hard-blocks the Stop hook on Claude Code (Tier 1). Degrades to soft nudge on Cursor/Kiro (Tier 2), notify-only on OpenCode/Gemini (Tier 3). This is a platform limitation, not a bug.

## Related skills

- ext-pnr: writes PLAN.md and REPORT.md to .plans\. Its write IS the trigger for sys-planner injection.

## File structure

```
.plans\
  PLAN.md           written by ext-pnr; read and injected by sys-planner
  REPORT.md         written by ext-pnr; not injected
  FINDINGS.md       written by Claude; accumulates
  PROGRESS.md       written by Claude; accumulates
  .cache\
    PLAN_YYYY-MM-DD_HH-MM-SS.md   written by ext-pnr; never overwritten
  .mode             gated/autonomous mode flag; absent = interactive
  .attestation      SHA-256 of PLAN.md
  .stop_blocks      gate block counter
  .nonce            delimiter nonce for security
  .active_plan      pointer to active named plan slug
```

## Version

1.0.0
