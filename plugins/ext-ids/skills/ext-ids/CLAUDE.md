# ext-ids

Checks, prompts for, and generates Firefox UUID and Chrome Store ID for a Firefox extension. IDs are permanent -- only generates when the value is clearly a placeholder.

## Design decisions

- Placeholder detection is explicit: empty string, contains REPLACE_, EXTID is a short slug, EXTID does not match /^[a-p]{32}$/, FFADDID does not match the UUID braces format
- Generated IDs are shown to the user before writing anything
- gecko.id in manifest.json and FFADDID in config.js must always match -- both are updated together when a Firefox UUID is set
- When both IDs look real, the skill reports and stops with no changes

## ID format rules

- Chrome Store ID: exactly 32 lowercase letters using only a-p (each nibble of 16 random bytes maps to one letter)
- Firefox UUID: {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx} (braces included; generated via PowerShell System.Guid)

## Integration

Called by ext-duplicate after Step 3 when user says "generate" for ExtID or FFADDID.

## Related skills

- `ext-duplicate`: Primary caller
