Read the active .plans/PLAN.md and print a concise phase status summary inline.

Steps:
1. Run the resolve-plan-dir.sh script (or replicate its logic) to find the active plan directory.
2. Read PLAN.md from that directory.
3. Count phases by status: in_progress, complete, pending.
4. List each phase with its status on one line.
5. Print the overall count: X of Y phases complete.
6. If no PLAN.md exists, say so and note that ext-pnr writes it when a plan is presented.

Keep the output tight — one line per phase, totals on the last line. No prose.
