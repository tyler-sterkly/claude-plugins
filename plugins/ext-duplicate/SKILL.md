---
name: ext-duplicate
description: Duplicate an existing Firefox extension into a new project directory, wiring in new config values and verifying against the FF-extension-Template. Use this skill whenever the user says "duplicate a firefox extension", "clone an extension", "create a new extension from an existing one", "copy extension project", or any variation of duplicating or bootstrapping a new extension from an existing one.
---

# Duplicate a Firefox Extension

Scaffold a new Firefox extension by duplicating an existing one and wiring in new config values.

## Step 1 -- Gather required info

Ask the user for the following. LP Domain, ExtID, and FF ExtID are optional at this stage -- the user can provide them, say "generate" to have them created, or say "skip" to leave placeholders for now.

| Field | Description | Required |
|---|---|---|
| Source directory | Path to the existing extension to duplicate from | Yes |
| New project directory | Path/name for the new extension project | Yes |
| Extension Name | Human-readable name of the new extension | Yes |
| Domain | Primary domain (e.g. myextension.com) | Yes |
| LP Domain | Landing page domain if different from Domain | No |
| ExtID | Chrome Web Store extension ID | No -- say "generate", paste an existing ID, or "skip" |
| FF ExtID | Firefox addon UUID | No -- say "generate", paste an existing UUID, or "skip" |
| Icons | Provide a source file, say "generate" to have icons created, or say "skip" to keep existing icons | Yes |

Ask for all fields in one message. Do not proceed until Source, New directory, Extension Name, Domain, and Icons are provided. ExtID and FF ExtID can be resolved after scaffolding via the `ext-ids` skill.

**ExtID / FF ExtID field behavior:**
- If the user provides a value: use it as-is
- If the user says "generate": invoke the `ext-ids` skill after Step 3 to generate both IDs and write them in
- If the user says "skip": leave placeholder values in place; remind the user to run `ext-ids` before shipping

Icon field behavior:
- If the user provides a file (SVG or PNG): pass it to ext-icons as the source
- If the user says "generate": ext-icons will generate 4 concept options using the Extension Name
- If the user says "skip": leave existing icons in place, skip Step 6

## Step 2 -- Create the new project directory

- Create the new project directory if it does not already exist.
- Copy all files from the source extension directory into it.
- Exclude: anything starting with `.`, `node_modules/`, `META-INF/`, `.builds/`, `__MACOSX/`.

## Step 3 -- Wire in the new config values

Replace every `REPLACE_*` placeholder across all files. The full list is below. After wiring, grep the project for `REPLACE_` to confirm no token was missed.

### Placeholder reference

All placeholder tokens use `REPLACE_SCREAMING_SNAKE_CASE`. Every token that appears in the template must be filled in before the extension can be loaded in Firefox.

| Token | File(s) | What to set |
|---|---|---|
| `REPLACE_PRODUCT_NAME` | `js/config.js` (`NAME`), `_locales/en/messages.json` (`extName`) | Full product display name (e.g. "Rudder VPN: Free Private Search VPN") |
| `REPLACE_SHORT_NAME` | `_locales/en/messages.json` (`extShortName`) | Short display name shown in toolbar/store (e.g. "Rudder VPN") |
| `REPLACE_DESCRIPTION` | `_locales/en/messages.json` (`extDescription`) | AMO listing description (1-2 sentences) |
| `REPLACE_AMO_SLUG` | `_locales/en/messages.json` (`extSlug`) | AMO addon slug (e.g. "rudder-vpn") |
| `REPLACE_SEARCH_NAME` | `_locales/en/messages.json` (`extSearchName`) | Exact search engine name -- **must be identical to `NAME` in config.js**, otherwise `SearchEngineAccepted` will never fire |
| `REPLACE_KEYWORD` | `_locales/en/messages.json` (`extKeyword`) | Omnibox/search keyword shortcut (e.g. "vpn") |
| `REPLACE_PRODUCT_DOMAIN` | `js/config.js` (`DOMAIN`), `manifest.json` (content_scripts matches x2, search_url) | Primary product domain without scheme (e.g. "ruddervpn.com") |
| `REPLACE_CHROME_STORE_ID` | `js/config.js` (`EXTID`) | Chrome Web Store extension ID |
| `REPLACE_FIREFOX_UUID` | `js/config.js` (`FFADDID`), `manifest.json` (`gecko.id`) | Firefox addon UUID without braces (e.g. "afa4db78-36b1-4ad0-9ec9-99c9aaea7827") -- note: config.js wraps it in `{...}` already |
| `REPLACE_NTSEARCH_TAG` | `js/script.js` | Search origin tag (e.g. "nt", "ni") -- delete `script.js` entirely if the product has no inline search box |

### Wiring notes

- **`REPLACE_SEARCH_NAME` must exactly equal `NAME` in config.js.** The background script uses `PRODUCT.NAME` to find the registered search engine via `browser.search.get()`. A mismatch means `SearchEngineAccepted` never fires.
- **`REPLACE_PRODUCT_DOMAIN` must also be updated in `manifest.json` as a literal string** -- the manifest cannot read from config.js at runtime. It appears in three places: both `content_scripts.matches` entries and `search_url`.
- **`REPLACE_FIREFOX_UUID` appears in two files**: `js/config.js` as `"{REPLACE_FIREFOX_UUID}"` (braces included) and `manifest.json` `gecko.id` as `"{REPLACE_FIREFOX_UUID}"` (braces included).
- **LP Domain:** if LP Domain is not provided or is the same as Domain, set LPDOMAIN equal to DOMAIN or omit it per single-domain mode. This activates single-domain mode in the shared core.

## Step 4 -- Genericize source-extension identifiers

After wiring config, sweep the copied code for identifiers and strings derived from the SOURCE extension's brand and rename them to generic, brand-neutral names. These ride along during duplication and are easy to miss because the extension still works with them.

Search the new project's `js/`, HTML, and CSS for the source brand name and its short forms (e.g. for a source named "K2VPN", search `k2`, `k2vpn`, `K2`). Look for:
- Class names (e.g. `K2ProxyController`)
- Global / window bindings (e.g. `window.K2Proxy`) and every consumer that reads them
- Local variable names (e.g. `k2Config`)
- Log / console prefixes (e.g. `[k2vpn proxy]`)
- Code comments mentioning the source brand
- Any other source-brand token baked into an identifier

Rename to generic, function-describing names (e.g. `ProxyController`, `window.VpnProxy`, `config`). Rename a window binding and ALL of its consumers together in the same pass so nothing breaks.

Do NOT touch:
- Real config placeholders meant to be filled in later (proxy hosts, credentials, server URLs). Those are values, not brand identifiers, and renaming them would be wrong.
- The NEW extension's own brand name / domain / IDs that Step 3 just wired in.
- The historical `Duplicated from: {source}` provenance notes in README / CLAUDE.

After renaming, run `node --check` on each edited JS file, then re-grep for the source brand token to confirm only the intended placeholders remain.

## Step 5 -- Verify and update against FF-extension-Template

Locate the `FF-extension-Template` directory. Check these locations in order:
- `C:\github\sterkly\BitBoxMedia\FF-extension-Template` (default Windows path)
- Sibling directory named `FF-extension-Template` relative to the new project directory
- If not found in either location, ask the user for the path before continuing.

Compare the new project's shared files against the template:
- `background-core.js` or equivalent shared background logic
- Any seam files
- Shared utility files

Flag any files in the new project that are outdated vs the template and update them. Preserve extension-specific seam logic -- only update shared/core sections.

Also check `browser_specific_settings.gecko.strict_min_version` in the new project's `manifest.json`. It should be `142.0`. If it is anything else, change it to `142.0`. Adblock extensions need 142.0 to clear the Android lint warning, so any duplicate should start there.

## Step 6 -- Build icon set and replace existing icons

Behavior depends on the icon answer from Step 1:

- If "skip": leave all existing icons in place and skip this step entirely.
- If file provided: pass the file to ext-icons as the source SVG or PNG.
- If "generate": trigger ext-icons with no source -- it will generate 4 icon concepts using the Extension Name and let the user pick before rendering the full set.

After ext-icons completes (file or generate path), replace all matching files in the project's `icons/` directory:
- Target any `.png` or `.ico` file whose name contains "icon" or "logo" (case-insensitive) -- do not target SVG files, icons/ is a published directory
- Overwrite them with the newly generated files of the same name
- If a generated file has no matching existing file, write it into `icons/` anyway
- If icons were generated (not user-supplied): also save the approved source SVG to `icons/icon.svg`

Icons are written into the new project directory before continuing.

## Step 7 -- Write extension verbiage

Trigger the ext-verbiage skill to produce all three copy outputs for the new extension using the Extension Name and any purpose notes provided by the user.

After ext-verbiage completes, take the `MANIFEST DESCRIPTION:` output and write it into the `description` field in `manifest.json` of the new project.

The `LISTING SUMMARY:` and `LISTING DESCRIPTION:` outputs are for the listing -- save them to `.docs/LISTING.txt` in the project root (create the `.docs/` directory if it does not exist).

## Step 8 -- Write README.md and CLAUDE.md

Create or update both `README.md` and `CLAUDE.md` in the new project root with all the config data collected in Step 1:

```
# {Extension Name}

## Project Config

- Extension Name: {Extension Name}
- Domain: {Domain}
- LP Domain: {LP Domain or "same as Domain"}
- ExtID: {ExtID}
- FF ExtID: {FF ExtID}
- Duplicated from: {Source directory}
```

`CLAUDE.md` is for Claude Code context -- include the same data plus any notes about the extension's purpose if the user provides them.

## Step 8b -- Write EXTENSION.md

Check if `EXTENSION.md` exists in the source extension directory. If it does, copy it into the new project and update all fields with the new extension's values from Step 1. Ask the user for any fields that are blank or cannot be derived from Step 1 data (AMO Slug, AMO Listing URL, AMO Developer Hub URL, AMO Reviewer Notes, Brand Color, Icon Style).

If `EXTENSION.md` does not exist in the source directory, check for it in `FF-extension-template`. Use that as the base. Ask the user for all required fields: Name, Short Name, AMO Slug, Firefox Extension ID, Chrome Extension ID, AMO Listing URL, AMO Developer Hub URL, Primary Domain, Search Domain, Search URL, Search Keyword, Brand Color, Icon Style, and AMO Reviewer Notes.

Write the completed `EXTENSION.md` to the new project root.

## Step 9 -- List unused / unreferenced files

Scan the new project for files that nothing references and list them for the user, since duplicated projects often carry assets and scripts the new extension never uses. Do NOT delete anything -- only present the list and let the user decide.

How to find them:
- Build the set of referenced paths by scanning `manifest.json`, all HTML (`src` / `href`), CSS (`url(...)`), and JS (path strings, including dynamically built paths).
- Compare that set against the actual files on disk under the project. Exclude dot-dirs (which includes `.docs/`), docs at root (README, CLAUDE), and the build/source dirs.
- Account for dynamically constructed paths (e.g. `/imgs/flags/${code}.svg`): treat a whole folder as used if any code builds paths into it, and say so rather than flagging each file in it.

Output a plain list grouped by directory, marking confidence (clearly unused vs possibly referenced dynamically). If unsure whether something is referenced, say so instead of calling it unused.

## Step 10 -- Make a plan

Output a clear plan summarizing:
- What was created and where
- What config values were applied
- What identifiers were genericized
- What template files were updated
- The unused-file list from Step 9
- What still needs to be done (e.g. listing, icon set, landing page)

## Self-check

- [ ] All required fields collected before proceeding
- [ ] New directory created and source files copied
- [ ] Excluded dirs/files not copied (.git, node_modules, META-INF, etc.)
- [ ] All 10 REPLACE_* placeholders filled across config.js, messages.json, manifest.json, and script.js (or script.js deleted)
- [ ] REPLACE_SEARCH_NAME exactly matches NAME in config.js
- [ ] REPLACE_PRODUCT_DOMAIN replaced in both manifest.json content_scripts matches AND search_url
- [ ] Grepped project for `REPLACE_` after wiring -- no tokens remain
- [ ] Single-domain mode handled correctly if LP Domain not provided
- [ ] Source-extension brand identifiers genericized (class names, window globals, local vars, log prefixes, comments); config placeholders left intact; edited JS re-checked with node --check
- [ ] Shared files verified and updated against FF-extension-Template
- [ ] manifest.json strict_min_version is 142.0 (changed if it was not)
- [ ] Icon set generated and icons/ files with "icon" or "logo" in name replaced
- [ ] Extension verbiage written, manifest description written into manifest.json, .docs/LISTING.txt saved
- [ ] README.md and CLAUDE.md written with all config data
- [ ] EXTENSION.md written with all fields filled (copied from source or template, updated with new values, missing fields asked from user)
- [ ] Unused / unreferenced files listed for the user (nothing auto-deleted)
- [ ] Plan delivered at the end
