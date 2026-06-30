Switch the active named plan. Lists all named plans under .plans\, shows their status, and lets you pick one.

Steps:
1. Scan .plans\ for subdirectories (exclude dot-prefix dirs like .cache):
   ```powershell
   Get-ChildItem ".plans" -Directory | Where-Object { $_.Name -notmatch '^\.' }
   ```
2. For each named plan directory found:
   - Check if PLAN.md exists inside it
   - If yes: count Status: complete / in_progress / pending lines
   - Note which one is currently active (.plans\.active_plan contents)
3. Print the list:
   ```
   Named plans in .plans\:

     * build-pipeline     [ACTIVE]  2/3 phases complete
       auth-refactor                1/4 phases complete
       ff-extension-search          not started
   ```
   If no named plans exist, say so and suggest /plan-start to create one.

4. Ask the user which plan to switch to.

5. On selection:
   - Write the chosen slug to .plans\.active_plan
   - Confirm: "Active plan switched to: <slug>  (.plans\<slug>\)"
   - Remind: "The next turn will inject this plan's context automatically."
