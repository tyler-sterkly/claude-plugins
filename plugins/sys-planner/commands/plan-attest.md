Fingerprint the active PLAN.md and write the SHA-256 hash to .attestation.

Steps:
1. Find the active plan directory (check .plans/.active_plan, then .plans/).
2. Run attest-plan.sh (or attest-plan.ps1 on Windows) from the sys-planner scripts directory.
   - On Windows with Git Bash: sh path/to/attest-plan.sh
   - On Windows with PowerShell: .\path\to\attest-plan.ps1
3. Print the resulting SHA-256 hash and the path it was written to.
4. Remind the user to re-run /plan-attest after any intentional edit to PLAN.md.

If sha256sum / shasum is not available, compute the hash using PowerShell:
  (Get-FileHash ".plans/PLAN.md" -Algorithm SHA256).Hash.ToLower()
and write the result to .plans/.attestation manually.
