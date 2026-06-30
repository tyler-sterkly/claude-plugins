Run the active plan on a loop cadence until all phases are complete.

Steps:
1. Find the active plan directory and read PLAN.md.
2. Check that gated or autonomous mode is active (.plans/.mode exists). If not, warn the user: without a .mode file the Stop hook is advisory only and loops may exit early.
3. If attestation is not set, prompt the user to run /plan-attest first.
4. Compose a loop instruction from templates/loop.md (adapt the phase and task list to the current plan).
5. Present the loop instruction to the user and ask for confirmation before starting.
6. On confirmation, begin the first iteration: read PLAN.md, execute one task, write to PROGRESS.md, update PLAN.md status, then stop to let the gate evaluate.

The loop continues automatically via the gate until all phases are complete or the cap is reached.
