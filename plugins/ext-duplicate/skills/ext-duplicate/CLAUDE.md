# ext-duplicate

Scaffolds a new Firefox extension from an existing one. Copies source files, fills all REPLACE_* placeholders, genericizes source-brand identifiers, verifies against FF-extension-Template, builds icons, writes verbiage, and produces README, CLAUDE.md, and EXTENSION.md.

## Design decisions

- IDs (EXTID / FFADDID) are optional at gather time -- user can say "generate", paste an existing ID, or "skip"; ext-ids is called post-Step-3 if "generate" was chosen
- Genericizing source-brand identifiers (Step 4) is separate from wiring new values (Step 3) -- the goal is to rename source-brand class names, window globals, variable names, and log prefixes without touching config values
- strict_min_version is always set to 142.0 regardless of source extension value
- The FF-extension-Template check in Step 5 only updates shared/core sections -- per-extension seam logic is preserved
- script.js is deleted if the product has no inline search box; index.html is deleted only for popup products with no app page

## Critical wiring rule

REPLACE_SEARCH_NAME must equal NAME in config.js character-for-character. The background script calls browser.search.get() and compares against PRODUCT.NAME. Any mismatch means SearchEngineAccepted never fires.

## Related skills

- `ext-ids`: Called when user says "generate" for ExtID/FFADDID
- `ext-icons`: Called in Step 6 to build the icon set
- `ext-verbiage`: Called in Step 7 to write listing copy
- `ext-ingest`: Alternative approach (template + reference zips instead of existing project)
