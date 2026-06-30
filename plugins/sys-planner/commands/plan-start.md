Start a named planning session. Creates a .plans\<slug>\ directory, sets it as the active plan, and optionally enables gated or autonomous mode.

Usage: /plan-start <name> [--gated | --autonomous]

Examples:
  /plan-start Build Pipeline --gated
  /plan-start Auth Refactor
  /plan-start FF Extension Search

Steps:
1. Take everything before the flag (or the full input if no flag) as the plan name.
2. Derive the slug: lowercase, replace non-alphanumeric with hyphens, collapse consecutive hyphens, trim leading/trailing hyphens.
   "Build Pipeline" -> "build-pipeline"
   "FF Extension Search" -> "ff-extension-search"
3. Find the sys-planner scripts directory via $CLAUDE_SKILL_DIR or common install paths.
4. Run init-session.sh with the slug and mode flag:
   ```powershell
   sh "$CLAUDE_SKILL_DIR/scripts/init-session.sh" [--gated|--autonomous] "<slug>"
   ```
   On Windows if sh is unavailable, replicate the logic directly:
   - Create .plans\<slug>\ and .plans\.cache\ if they don't exist
   - Write the mode to .plans\<slug>\.mode if --gated or --autonomous was passed
   - Write the slug to .plans\.active_plan
   - Copy PLAN.md, FINDINGS.md, PROGRESS.md templates into .plans\<slug>\ if they don't exist
5. Confirm in chat:
   "Started plan: <name>
    Directory: .plans\<slug>\
    Mode: gated / autonomous / interactive
    Active plan set. ext-pnr will write to this directory on the next plan presentation."
6. If --gated was passed, remind the user to run /plan-attest after finalising PLAN.md.
