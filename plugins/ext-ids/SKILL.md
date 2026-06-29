---
name: ext-ids
description: Check, prompt for, and optionally generate Firefox and Chrome extension IDs for a FF extension project. Integrates with the ext-duplicate flow. Use when the user asks to "generate extension IDs", "generate a Firefox ID", "set extension IDs", or when EXTID/FFADDID are missing or placeholder in an extension.
---

# Generate Extension IDs

Check an extension's current EXTID (Chrome Store ID) and FFADDID (Firefox UUID), prompt the user when either is missing or placeholder, and generate new IDs on request using the same algorithm as the `.tools/Extension ID Generator.py` script in the extension directory.

**Rule: IDs are permanent.** Once real IDs are set, never regenerate or replace them. Only generate when the value is clearly a placeholder or missing. When in doubt, ask.

## Step 1 -- Locate the extension directory

If called from `ext-duplicate`, the directory is already known. Otherwise, ask the user which extension directory to operate on.

## Step 2 -- Read current ID values

Read `js/config.js` and extract:
- `EXTID` -- Chrome Web Store extension ID (should be 32 lowercase letters using only a-p)
- `FFADDID` -- Firefox addon UUID (should be `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}`)

Also read `browser_specific_settings.gecko.id` from `manifest.json` to cross-check the Firefox UUID.

## Step 3 -- Detect placeholder vs. real values

A value is a **placeholder** if any of the following are true:
- Empty string (`""`)
- Contains `REPLACE_` (leftover template token)
- EXTID is a short product slug (e.g. `"breeze-past"`, `"ad-cleanse"`) -- Chrome IDs are always exactly 32 letters a-p
- EXTID does not match `/^[a-p]{32}$/`
- FFADDID is `{REPLACE_FIREFOX_UUID}` or does not match `^\{[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\}$`

If both IDs look real, report them to the user and stop -- no changes needed.

## Step 4 -- Prompt the user for each placeholder ID

For each placeholder ID, present the options clearly. Never silently fill in a value.

**For EXTID (Chrome Store ID):**
> `EXTID` is currently `"<current value>"` which looks like a placeholder.
>
> Options:
> 1. **Enter an existing ID** -- paste your Chrome Web Store extension ID (32 letters, a-p only)
> 2. **Generate a new ID** -- creates a random ID following Chrome's ID format (use this if you haven't submitted to the Chrome Web Store yet)
> 3. **Skip for now** -- leave the placeholder in place

**For FFADDID (Firefox UUID):**
> `FFADDID` is currently `"<current value>"` which looks like a placeholder.
>
> Options:
> 1. **Enter an existing UUID** -- paste your Firefox addon UUID (format: `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}`)
> 2. **Generate a new UUID** -- creates a random GUID following AMO's recommended format
> 3. **Skip for now** -- leave the placeholder in place

Ask for both in one message if both are placeholders. Wait for the user's response before proceeding.

## Step 5 -- Generate IDs if requested

### Firefox UUID generation

Run this PowerShell command to generate a UUID and wrap it in braces:

```powershell
"{" + [System.Guid]::NewGuid().ToString() + "}"
```

### Chrome Store ID generation

Run this PowerShell command to generate a 32-character ID using Chrome's a-p alphabet (maps each nibble of 16 random bytes to a letter):

```powershell
$bytes = [byte[]]::new(16)
[System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
-join ($bytes | ForEach-Object { [char]([byte][char]'a' + ($_ -shr 4)); [char]([byte][char]'a' + ($_ -band 0x0F)) })
```

Show the generated IDs to the user before writing anything.

## Step 6 -- Write IDs to the extension files

For each ID that was provided (by the user) or generated:

**FFADDID / Firefox UUID:**
- Write to `js/config.js`: update `FFADDID: "{uuid}"`
- Write to `manifest.json`: update `browser_specific_settings.gecko.id` to `"{uuid}"`
- The gecko.id in manifest.json and FFADDID in config.js must always match exactly

**EXTID / Chrome Store ID:**
- Write to `js/config.js`: update `EXTID: "chromeid"`

After writing, grep the extension directory for the old placeholder values to confirm they were fully replaced.

## Step 7 -- Report

Report what was done:
- Which IDs were set and to what values
- Which files were updated
- Which IDs were skipped and why

If the Firefox UUID was newly generated and the user hasn't submitted to AMO yet, remind them:
> This Firefox UUID is now locked to this extension. Save it. AMO ties the extension to this UUID and it cannot be changed after first submission.
