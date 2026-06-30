Enable the sys-planner / PNR system by setting PNR_ENABLED=true in settings.json.

Steps:
1. Read `C:\github\.claude\settings.json`.
2. Set `PNR_ENABLED` to `"true"` under the `env` object. Create the `env` key if it does not exist.
3. Write the file back.
4. Confirm in chat: "PNR enabled. ext-pnr will write plan files and sys-planner will inject context on every turn."

Note: this setting persists across sessions. You only need to run /plan-arm once per machine.
