# ext-pnr

Automatically writes plan and report files whenever a plan is presented, when PNR_ENABLED=true in settings.json. Writes 4 files: PLAN.md and REPORT.md at C:\github\ (overwritten each time) plus timestamped snapshots in C:\github\PNR\ (never overwritten).

## Design decisions

- Triggered automatically before every plan presentation -- not user-invoked
- PNR_ENABLED is checked via PowerShell $env:PNR_ENABLED -- if not "true", the skill exits immediately with no files written and no notice
- Timestamps are always PST, always via PowerShell -- never guessed or assumed from session clock
- The PNR notice is printed in both chat (always) and terminal dim gray (best-effort, silent on failure)
- PLAN.md and REPORT.md are always overwritten; timestamped PNR\ snapshots are never overwritten

## Notice format

The notice uses Unicode small caps characters and is printed exactly as defined in the skill -- do not change the character set or format.

## File naming

Timestamped snapshots use the format: PLAN_YYYY-MM-DD_HH-MM-SS.md (24h, PST, no timezone suffix in filename).
