# ext-ids

Checks, prompts for, and optionally generates Firefox and Chrome extension IDs for a Firefox extension project. Integrates with the ext-duplicate flow.

## When to trigger

Use this skill when the user asks to:
- "Generate extension IDs"
- "Generate a Firefox ID"
- "Set extension IDs"
- When EXTID or FFADDID are missing or placeholder in an extension

## Inputs

- A Firefox extension project directory (asked for if not already known)

## How it works

1. **Locate** the extension directory (already known if called from ext-duplicate)
2. **Read** EXTID and FFADDID from js/config.js; cross-check gecko.id in manifest.json
3. **Detect** placeholders -- a value is a placeholder if it's empty, contains REPLACE_, is a short slug, or does not match the expected format
4. **Prompt** the user for each placeholder ID with three options: enter existing, generate new, or skip
5. **Generate** IDs if requested (PowerShell commands for both UUID and Chrome-format ID)
6. **Write** IDs to the extension files and confirm no old placeholders remain
7. **Report** what was set, what files were updated, what was skipped

## ID formats

**Chrome Store ID (EXTID):** 32 lowercase letters, a-p only (maps each nibble of 16 random bytes to a letter via Chrome's alphabet)

**Firefox UUID (FFADDID):** `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}` -- generated via PowerShell `[System.Guid]::NewGuid()`

## Important rule

IDs are permanent. Once real IDs are set, never regenerate or replace them. Only generate when the value is clearly a placeholder or missing. When in doubt, ask.

## What gets updated

- `js/config.js`: FFADDID and EXTID fields
- `manifest.json`: browser_specific_settings.gecko.id (Firefox UUID only)

The gecko.id in manifest.json and FFADDID in config.js must always match exactly.

## Outputs

Report of what was done:
- Which IDs were set and to what values
- Which files were updated
- Which IDs were skipped and why
- Reminder to save the Firefox UUID if it was newly generated

## Related skills

- `ext-duplicate`: Calls ext-ids after scaffolding when user says "generate" for ExtID/FFADDID
