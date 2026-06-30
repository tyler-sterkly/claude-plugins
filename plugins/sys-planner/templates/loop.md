You are running in an autonomous loop to complete the active plan.

Before each iteration:
0. Resolve the active plan directory:
   - Read .plans/.active_plan (if it exists) to get the active slug.
   - Use .plans/<slug>/ as the plan directory.
   - If .active_plan does not exist or the slug directory is missing, fall back to .plans/.
1. Read <plan-dir>/PLAN.md — identify the current in_progress phase and its remaining tasks.
2. Read <plan-dir>/PROGRESS.md (last 20 lines) — understand what was done last iteration.
3. Complete one task from the in_progress phase.
4. Write what you did to <plan-dir>/PROGRESS.md.
5. If the phase is now fully complete, update the Status in PLAN.md from in_progress to complete, and set the next phase to in_progress.
6. If all phases are complete, write a final summary to <plan-dir>/PROGRESS.md and stop.

Rules:
- Never skip updating PROGRESS.md — it is how the next iteration knows where to resume.
- Never invent progress — only write what you actually did.
- Never start a new task without finishing the current one.
- If you encounter an error, log it to .plans/PROGRESS.md and the error log in PLAN.md, then try one alternative approach before stopping.
