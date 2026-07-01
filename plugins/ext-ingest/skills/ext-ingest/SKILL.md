---
name: ext-ingest
description: Build a new Firefox MV3 extension by ingesting a template zip and one or more reference extension zips. Triggered by "ingest extension" followed by 2 or more paths to zip files. One zip is the template, the rest are reference extensions to learn from. Produces a finished, zipped extension ready for AMO.
---

# Ingest Extension

Reads a template zip and one or more reference extension zips, collects any missing product details, then builds a new extension on top of the template using the reference extensions as the feature/implementation guide.

**NEVER access any file or folder whose name starts with `.` — skip `.assets/`, `.builds/`, `.git/`, and all dotfiles/dotfolders entirely. Exception: `.tools/check-setup.js` may be run via `node .tools/check-setup.js` in Step 13 — it is the pre-zip validation script that checks manifest file references and scans for REPLACE_ tokens.**

---

## Step 0 — Identify the Zips

The user provides 2 or more zip paths. Identify which is the template:
- If one path contains the word `template`, that is the template zip
- If ambiguous, ask the user which zip is the template before proceeding

Extract all zips into separate working directories. Read the template's `CLAUDE.md` and `README.md` if present — they define the architecture rules for this suite.

---

## Step 1 — Read the Template

From the template zip, read:
- `manifest.json` — note all fields, permissions, existing content_scripts, chrome_settings_overrides, gecko id, strict_min_version
- `js/config.js` — note all keys including APIDOMAIN, SEARCHDOMAIN, WWWDOMAIN and the EXT_DOMAINS IIFE at the bottom
- `js/background.js` — note the seam structure and section comments
- `js/background-core.js` — confirm present only; do not read in full. It is the shared drop-in core, byte-identical across the suite
- `js/contentscript.js` — confirm it is the standard relay
- `js/consent.js` — note the handleChoice function and the openApp / closeCurrentTab paths
- `js/script.js` — note the `REPLACE_NTSEARCH_TAG` placeholder and the element ID `main-search-input` (must be replaced with the actual search input ID, or delete the file if the product has no inline search box)
- `consent.html` — note the required element IDs: `consent_search`, `acceptConsent`, `declineConsent`
- `options.html` — note the required element ID: `editSettings`
- `_locales/en/messages.json` — note all keys and their REPLACE_* placeholders
- List all other files present

---

## Step 2 — Read the Reference Extensions

For each reference zip, read all files. Understand:
- What the extension does and how it is structured
- What new files it adds beyond a template baseline (content scripts, popup, CSS, etc.)
- What manifest entries it uses (permissions, content_scripts, host_permissions, web_accessible_resources)
- What the popup UI looks like and what storage keys it reads/writes
- How content scripts are architected (single world vs two-world MAIN + isolated, MutationObserver vs polling, postMessage bridge, etc.)
- What DOM selectors, timing, and detection logic it uses
- What CSS it uses to hide elements

Do not copy files from references. Use them only to understand what to build.

---

## Step 3 — Collect Product Details

Before building, the following values are required. If not provided in the trigger or conversation, ask for all missing ones in a single message:

- Extension display name (full, e.g. "Rudder VPN: Free Private Search VPN")
- Short name (e.g. "Rudder VPN")
- AMO description (one line)
- AMO slug (e.g. "rudder-vpn")
- App domain (e.g. "ruddervpn.com")
- Gecko ID (Firefox addon UUID, without braces)
- Chrome Store ID (internal extension ID)
- Extension type: **popup** (toolbar opens a popup) or **page-opening** (toolbar opens a new tab)
- Search name — the exact string used for the search engine override (must match the short name you will set as `NAME` in config.js; see placeholder reference below)
- Search keyword (for `chrome_settings_overrides.search_provider.keyword`)
- Search URL (for `chrome_settings_overrides.search_provider.search_url`)

Do not invent values for these. Do not proceed until all are known.

---

## Placeholder Reference

All template placeholders use `REPLACE_SCREAMING_SNAKE_CASE`. Every token must be filled before the extension loads in Firefox. After wiring all values, grep the project for `REPLACE_` to confirm nothing was missed.

| Token | File(s) | Set to |
|---|---|---|
| `REPLACE_PRODUCT_NAME` | `_locales/en/messages.json` (`extName`) | Full display name (e.g. "Rudder VPN: Free Private Search VPN") |
| `REPLACE_SHORT_NAME` | `js/config.js` (`NAME`), `_locales/en/messages.json` (`extShortName`) | Short name shown in toolbar/store (e.g. "Rudder VPN") — config.js `NAME` uses this value so it matches `extSearchName` |
| `REPLACE_DESCRIPTION` | `_locales/en/messages.json` (`extDescription`) | AMO description (one line) |
| `REPLACE_AMO_SLUG` | `_locales/en/messages.json` (`extSlug`) | AMO addon slug (e.g. "rudder-vpn") |
| `REPLACE_SEARCH_NAME` | `_locales/en/messages.json` (`extSearchName`) | Exact search engine name — **must be identical to `NAME` in config.js** (both should equal the short name), otherwise the `SearchEngineAccepted` tracking event will never fire |
| `REPLACE_KEYWORD` | `_locales/en/messages.json` (`extKeyword`) | Omnibox/search keyword shortcut (e.g. "vpn") |
| `REPLACE_PRODUCT_DOMAIN` | `js/config.js` (`DOMAIN`), `manifest.json` (content_scripts matches ×2, search_url) | Primary product domain without scheme (e.g. "ruddervpn.com") |
| `REPLACE_CHROME_STORE_ID` | `js/config.js` (`EXTID`) | Chrome Web Store extension ID |
| `REPLACE_FIREFOX_UUID` | `js/config.js` (`FFADDID`), `manifest.json` (`gecko.id`) | Firefox addon UUID — both files wrap it in `{...}` already |
| `REPLACE_NTSEARCH_TAG` | `js/script.js` | Search origin tag (e.g. "nt") — delete `script.js` entirely if the product has no inline search box |

**Critical wiring notes:**
- `REPLACE_SEARCH_NAME` must equal `NAME` in config.js character-for-character. The background script calls `browser.search.get()` and compares against `PRODUCT.NAME`. Any mismatch means `SearchEngineAccepted` never fires. Set both `NAME` and `extSearchName` to the short name (same value as `REPLACE_SHORT_NAME`).
- `REPLACE_PRODUCT_DOMAIN` appears in **three places** in `manifest.json`: both `content_scripts.matches` entries and `search_url`. All three must be updated.
- `REPLACE_FIREFOX_UUID` appears in **two files**: `js/config.js` as `"{REPLACE_FIREFOX_UUID}"` and `manifest.json` `gecko.id` as `"{REPLACE_FIREFOX_UUID}"`.

---

## Step 4 — Plan the File Changes

Based on the template structure and reference extensions, determine:

**Files to add** (new, not in template):
- Any new content scripts derived from the references (e.g. `content.js`, `content-main.js`)
- Any new CSS files derived from the references (e.g. `content.css`)
- `popup.html` and `js/popup.js` if this is a popup product
- Any other product-specific files the references suggest are needed
- For any `web_accessible_resources` entries you plan to add, verify each listed file path will exist on disk before finalizing the plan

**Files to delete:**
- `js/script.js` — only if the product has no inline search box (the template comment explicitly says to delete it in this case). If deleted, also remove its `<script>` tag from `index.html`.
- `index.html` — only if this is a popup product with no app page

**Files to edit (targeted edits only — never rewrite entirely):**
- `manifest.json`
- `js/config.js`
- `js/background.js`
- `js/script.js` (if kept) — replace `main-search-input` with the actual search input element ID and fill `REPLACE_NTSEARCH_TAG`
- `js/consent.js` (popup products only)
- `consent.html` — add product branding and copy; the required element IDs (`consent_search`, `acceptConsent`, `declineConsent`) must remain
- `options.html` — add any product-specific options UI; the required `#editSettings` button must remain
- `_locales/en/messages.json`

---

## Step 5 — Build: _locales/en/messages.json

Edit the `message` values only — do not change structure or `description` fields. Fill in all six keys:

| Key | Token | Set to |
|---|---|---|
| `extName` | `REPLACE_PRODUCT_NAME` | Full display name |
| `extShortName` | `REPLACE_SHORT_NAME` | Short name |
| `extDescription` | `REPLACE_DESCRIPTION` | AMO description |
| `extSlug` | `REPLACE_AMO_SLUG` | AMO slug |
| `extSearchName` | `REPLACE_SEARCH_NAME` | Search engine name — must match `NAME` in config.js exactly (both should be the short name) |
| `extKeyword` | `REPLACE_KEYWORD` | Search keyword shortcut |

---

## Step 6 — Build: manifest.json

Do not rewrite. Make targeted edits only:

**Popup products:** Add `"default_popup": "[popup filename]"` inside the `action` block alongside the existing `default_title` and `default_icon`.

**Leave `host_permissions` untouched** — the existing `<all_urls>` entry covers everything needed.

**Update** the existing `content_scripts` entry (the `js/contentscript.js` one) — replace its `matches` patterns with the real product domain (filling `REPLACE_PRODUCT_DOMAIN`):
```json
"matches": [
  "*://[domain]/*",
  "*://[*.]domain/*"
]
```

**Add** any new content_scripts entries to the existing array — do not remove the existing entry.

**Add** any new `web_accessible_resources` entries if the references use them — do not remove existing entries.

**Update** `browser_specific_settings.gecko.id` → product Gecko ID (filling `REPLACE_FIREFOX_UUID`).

**Update** `chrome_settings_overrides.search_provider.search_url` → search URL (replace the `REPLACE_PRODUCT_DOMAIN` portion).

**Note:** `chrome_settings_overrides.search_provider.name` uses `__MSG_extSearchName__` and `search_provider.keyword` uses `__MSG_extKeyword__` — both are already wired in the template. They resolve from the `extSearchName` and `extKeyword` keys you set in Step 5.

Leave everything else in the manifest untouched.

---

## Step 7 — Build: js/config.js

Edit values only — keep the full file structure and the EXT_DOMAINS IIFE at the bottom intact. Do not remove any fields:

| Field | Token | Set to |
|---|---|---|
| `NAME` | `REPLACE_SHORT_NAME` | Short name (e.g. "Rudder VPN") — must match `extSearchName` in messages.json exactly |
| `DOMAIN` | `REPLACE_PRODUCT_DOMAIN` | App domain without scheme |
| `EXTID` | `REPLACE_CHROME_STORE_ID` | Chrome Store ID |
| `FFADDID` | `REPLACE_FIREFOX_UUID` | Gecko UUID wrapped in `{...}` |

Leave `APIDOMAIN`, `SEARCHDOMAIN`, `WWWDOMAIN` as `"api"`, `"search"`, `"www"` unless overrides are needed.

---

## Step 8 — Build: js/background.js

Follow the template seam pattern exactly. Do not rewrite the file.

**Popup products:** Delete the entire `action.onClicked` block (section 1 in the template comments). The template comment explicitly instructs this.

**Page-opening products:** Keep the `action.onClicked` block as-is.

Add any product-specific background logic into section 4 (the marked paste area), derived from the reference extensions. Do not re-implement anything already provided by `background-core.js` — use `ExtCore.*` helpers instead. Leave all template section comments intact.

---

## Step 9 — Build: js/consent.js

**Popup products only:** Edit `handleChoice` so both accept and decline paths call `closeCurrentTab()` instead of `openApp()` on the accept path. The template comment explicitly instructs this. Leave everything else in consent.js as-is.

**Page-opening products:** Leave consent.js untouched.

---

## Step 10 — Build: consent.html

Add product-specific branding and copy to `consent.html`. Do not rename or remove these required element IDs — `js/consent.js` references them by ID and they cannot be changed:
- `consent_search` — the search/product area visible on the consent page
- `acceptConsent` — the accept button
- `declineConsent` — the decline button

Replace any placeholder text and visual stubs with real product copy derived from the reference extensions or product details collected in Step 3. Leave the `<script>` tags and overall page structure intact.

---

## Step 11 — Build: options.html

Add any product-specific options UI to `options.html`. The `#editSettings` button is required — `js/options.js` binds to it and it cannot be removed or renamed. Everything else on the page can be customized for the product.

If the product has no additional settings, leave the page as-is (the Edit consent button is sufficient).

---

## Step 12 — Build: New Files

Write all new files derived from the reference extensions. For each new file:

- Plain uncompiled JS, no bundler, no webpack output
- `var browser = window.browser || window.chrome` guard at top of every isolated-world script
- MAIN world scripts (world: "MAIN") do not use this guard — they have no access to extension APIs
- Single IIFE wrapping all logic
- No `console.log` or `console.debug` in production output
- No `eval`, no `new Function`, no remote fetches

Derive the full implementation from the reference extensions — selectors, timing, detection logic, UI structure, storage keys, postMessage protocols, CSS rules. Reproduce the logic faithfully, adapted for the template architecture and coding conventions.

If the references use a two-world content script pattern (MAIN world + isolated world communicating via `window.postMessage`), preserve that architecture exactly.

---

## Step 13 — Verify Before Zipping

Run from the project root:
```
node .tools/check-setup.js
node --check js/config.js
node --check js/background-core.js
node --check js/background.js
node --check js/consent.js
node --check js/contentscript.js
node --check js/options.js
```

Also run `node --check` on every new JS file added.

Then confirm:
- No file contains `eval`, `new Function`, Sterkly, or BitBoxMedia
- `js/background-core.js` is byte-identical to the template version
- Grep the project for `REPLACE_` — zero matches remaining
- `manifest.json` has `chrome_settings_overrides` present and fully filled (unless search was explicitly excluded from this product)
- `chrome_settings_overrides.search_provider.name` is `__MSG_extSearchName__` and `extSearchName` in messages.json matches `NAME` in config.js exactly (both should be the short name)
- If `js/script.js` was kept: `main-search-input` has been replaced with the actual search input element ID
- All files listed in `web_accessible_resources` in `manifest.json` exist on disk
- All new content script files are at the correct path (root vs `js/` as appropriate)
- All IDs and values in `js/config.js` and `manifest.json` match the collected product details from Step 3

Zip the output excluding `META-INF` and any `.map` files. Name it `FF-[ExtensionName].zip`.

---

## Rules

- Never rewrite a template file from scratch. Always make targeted edits to the existing file.
- Never replace an array in manifest.json (content_scripts, host_permissions, permissions, web_accessible_resources). Always add to existing arrays. Only the `matches` patterns inside the existing `contentscript.js` entry are replaced — because they contain `REPLACE_PRODUCT_DOMAIN` placeholders that must be filled in.
- Never remove template files unless the template's own documentation explicitly says to (script.js with no search box, index.html for a popup product with no app page).
- Never strip fields from config.js. Keep the full structure including APIDOMAIN, SEARCHDOMAIN, WWWDOMAIN, and the EXT_DOMAINS IIFE.
- Never edit `js/background-core.js`. It is drop-in and byte-identical across the suite.
- Never edit `js/contentscript.js` beyond what is described above.
- Do not copy code verbatim from reference extensions. Derive the logic and rewrite it cleanly for the template architecture.
- Do not invent product detail values (name, domain, IDs). Ask if not provided.
- Do not access any dotfile or dotfolder (except `.tools/check-setup.js` in Step 13).
