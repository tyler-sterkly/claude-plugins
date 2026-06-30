Disable the sys-planner / PNR system by setting PNR_ENABLED=false in settings.json.

Steps:
1. Read `C:\github\.claude\settings.json`.
2. Set `PNR_ENABLED` to `"false"` under the `env` object.
3. Write the file back.
4. Confirm in chat: "PNR disabled. No plan files will be written and no context will be injected until /plan-arm is run."

Note: existing .plans\ files are not touched. Run /plan-arm to re-enable.
