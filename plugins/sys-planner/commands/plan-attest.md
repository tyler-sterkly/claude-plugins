Fingerprint the active PLAN.md and write the SHA-256 hash to .attestation.

Steps:
1. Find the active plan directory: check .plans\.active_plan for a slug, fall back to .plans\.

2. Compute the SHA-256 hash using PowerShell:
   ```powershell
   (Get-FileHash "<plan-dir>\PLAN.md" -Algorithm SHA256).Hash.ToLower()
   ```

3. Write the hash (lowercase, no newline) to `<plan-dir>\.attestation`:
   ```powershell
   $hash = (Get-FileHash "<plan-dir>\PLAN.md" -Algorithm SHA256).Hash.ToLower()
   Set-Content -Path "<plan-dir>\.attestation" -Value $hash -NoNewline
   ```

4. Print the hash and confirm the file was written.

5. Remind the user: re-run /plan-attest after any intentional edit to PLAN.md, or the hook will block injection with [PLAN TAMPERED].

Non-Windows fallback (Git Bash / Linux / Mac):
  sh path/to/sys-planner/scripts/attest-plan.sh
