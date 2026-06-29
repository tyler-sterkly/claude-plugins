# ext-md

Creates or updates the EXTENSION.md identity file for a Firefox MV3 extension. EXTENSION.md is the canonical identity reference for the extension -- it should be filled out completely before other extension skills run.

## Design decisions

- Reads manifest.json, config.js, _locales/en_US/messages.json, and icons/ before filling any field
- Fills every field -- no blank or placeholder values in the output
- EXTENSION.md lives in the project root

## Role in the suite

Many other skills (ext-audit, ext-context, ext-duplicate, ext-publish, ext-verbiage, ext-changelog) read EXTENSION.md as their authoritative identity source. When EXTENSION.md exists and a skill finds a mismatch with manifest.json or config.js, the mismatch is flagged.

## Related skills

- `ext-context`: Generates CLAUDE.md for the extension (different file, different purpose)
- `ext-duplicate`: Writes EXTENSION.md for the new extension in Step 8b
