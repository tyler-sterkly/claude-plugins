# ext-ingest

Builds a new Firefox MV3 extension from a template zip and one or more reference zips. Applies product details, wires all REPLACE_* tokens, adapts reference extension logic to the template architecture, and produces a verified zip.

## Design decisions

- Always makes targeted edits to template files -- never rewrites from scratch
- Reference extensions are read to understand logic but never copied verbatim -- the implementation is derived and rewritten cleanly for the template architecture
- Script.js is deleted if no inline search box; index.html is deleted only for popup products with no app page
- Popup vs page-opening is a fundamental fork: popup products delete the action.onClicked block from background.js and edit consent.js so both paths call closeCurrentTab()
- .tools/check-setup.js is the only dotfolder file that may be accessed (Step 13 validation)

## Critical wiring rule

extSearchName in messages.json and NAME in config.js must be the same string. The background script calls browser.search.get() and compares against PRODUCT.NAME. Any mismatch means SearchEngineAccepted never fires.

## Verification before zip

check-setup.js, node --check on all JS, grep for REPLACE_ tokens, no eval/org names in any file, all web_accessible_resources files exist on disk.

## Related skills

- `ext-duplicate`: Duplicates from an existing project rather than template + reference zips
- `ext-ids`: Can be run after ingest to set or generate IDs
