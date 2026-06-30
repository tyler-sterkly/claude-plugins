Cross-project plan overview. Shows all active and completed plans under C:\github\, then offers to clean up completed ones.

Steps:

1. Run PowerShell to find all PLAN.md files nested inside a .plans directory under C:\github\:
   ```powershell
   Get-ChildItem "C:\github" -Recurse -Filter "PLAN.md" -ErrorAction SilentlyContinue |
     Where-Object { $_.FullName -like '*\.plans*' }
   ```

2. For each PLAN.md found:
   - Read the file
   - Count lines matching `Status:.*complete`, `Status:.*in_progress`, `Status:.*pending`
   - Total = complete + in_progress + pending
   - Classify:
     - All complete (and total > 0) → "done"
     - Any in_progress → "active"
     - All pending → "not started"
     - Total = 0 (no Status lines) → "unknown"

3. Print a table with one row per plan:
   ```
   | Plan | Phases | Complete | Status |
   |------|--------|----------|--------|
   | C:\github\sterkly\BitBoxMedia\.plans\PLAN.md | 3 | 2/3 | active |
   | C:\github\sterkly\claude-plugins\.plans\PLAN.md | 4 | 4/4 | done   |
   ```
   Sort: active first, then not started, then done.

4. If no plans found anywhere, say so and stop.

5. If any plans are classified as "done", list them explicitly and ask the user:
   ```
   The following plans are fully complete:
   - C:\github\sterkly\claude-plugins\.plans\PLAN.md

   Delete completed plan files? PLAN.md, REPORT.md, FINDINGS.md, and PROGRESS.md
   will be removed. .cache\ archives are kept permanently. (y/n)
   ```
   Wait for the user to reply before doing anything.

6. On "y":
   - For each completed plan directory, delete: PLAN.md, REPORT.md, FINDINGS.md, PROGRESS.md
   - If .plans\.active_plan exists and points to a slug whose directory is now empty of plan files, delete .active_plan
   - Print exactly what was deleted, one file per line
   - Do not delete: .cache\, .mode, .attestation, .nonce, .stop_blocks, ledger-*.jsonl, or the directory itself

7. On "n":
   - Print: "No files deleted."
   - Stop.
