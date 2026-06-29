# ext-ingest

Builds a new Firefox MV3 extension by ingesting a template zip and one or more reference extension zips. Produces a finished, zipped extension ready for AMO.

## When to trigger

Use this skill when the user provides 2 or more zip file paths and says:
- "Ingest extension"
- Followed by paths to zip files (one template + one or more references)

## Inputs

- 2+ zip paths -- one is the template (identified by the word "template" in the path; ask if ambiguous)
- Product details collected via Step 3 before building starts

## Product details required (asked if not provided)

- Extension display name (full and short)
- AMO description and slug
- App domain
- Gecko ID (Firefox UUID, without braces)
- Chrome Store ID
- Extension type: popup or page-opening
- Search name (must match short name / NAME in config.js exactly)
- Search keyword and search URL

## How it works

1. **Identify** which zip is the template; extract all zips into separate working dirs
2. **Read** the template -- manifest, config.js, background.js, consent.js, script.js, consent.html, options.html, messages.json, list all other files
3. **Read** each reference extension -- understand what it does, what files it adds, how it's architectured; do not copy verbatim
4. **Collect** product details (Step 3)
5. **Plan** what files to add, delete, and edit
6. **Build** each file in order: messages.json, manifest.json, config.js, background.js, consent.js, consent.html, options.html, then new files
7. **Verify** -- run check-setup.js and node --check on all JS; grep for REPLACE_ tokens; confirm no eval/org names; confirm search name match
8. **Zip** the output as FF-{ExtensionName}.zip, excluding META-INF and .map files

## Wiring notes

- `REPLACE_SEARCH_NAME` must equal `NAME` in config.js character-for-character
- `REPLACE_PRODUCT_DOMAIN` appears in three places in manifest.json
- `REPLACE_FIREFOX_UUID` appears in both config.js and manifest.json
- For popup products: delete the action.onClicked block from background.js; edit consent.js so both accept and decline call closeCurrentTab()
- For page-opening products: keep the action.onClicked block; accept path in consent.js calls openApp()
- script.js: fill REPLACE_NTSEARCH_TAG and replace main-search-input with the real input ID, or delete the file if no inline search box

## Output

A single zip file at the project root: `FF-{ExtensionName}.zip`

## Rules

- Never rewrite a template file from scratch -- make targeted edits only
- Never replace arrays in manifest.json -- always add to existing arrays
- Never remove template files unless the template's own docs say to
- Never edit background-core.js or contentscript.js
- Do not copy code verbatim from reference extensions -- derive and rewrite cleanly
- Never invent product detail values -- ask if not provided
- Never access dotfiles or dotfolders (exception: .tools/check-setup.js in Step 13)

## Related skills

- `ext-duplicate`: Duplicates from an existing project rather than building from template + reference zips
- `ext-ids`: Check and generate extension IDs after ingest
