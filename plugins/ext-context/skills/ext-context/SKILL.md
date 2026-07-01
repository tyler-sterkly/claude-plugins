---
name: ext-context
description: Examine a Firefox browser extension project and generate a CLAUDE.md file saved to the project root. Use when asked to "generate context" or "analyze this extension". Covers extension type, structure, manifest, background/content scripts, shared core API, attribution system, build process, icons, permissions, coding conventions, and anything else relevant to working on the extension.
---

# Generate Firefox Extension Context (CLAUDE.md)

Examine the project and write a comprehensive `CLAUDE.md` to the project root.

**NEVER access any file or folder whose name starts with `.` (dot). This includes `.assets/`, `.builds/`, `.git/`, `.tools/`, `.notes/`, `.vscode/`, and any other dotfile or dotfolder. Skip them entirely.**

---

## Step 1 — Identify the Extension Type

Read the root directory listing (excluding dot entries), then read `manifest.json` and check for the presence of `js/config.js`, `js/k2vpn.js`, and `js/background-core.js`. Determine which type this extension is — this governs what to read and what sections to generate.

| Type | Signals |
|------|---------|
| **Template** | `js/config.js` + `js/background-core.js` present; background uses seam pattern |
| **VPN** | `js/k2vpn.js` (or `k2vpn.js`) + `js/proxy.js` present; no `config.js` |
| **Ad-blocking** | `adblock/` directory with `rules.json`; DNR permissions in manifest |
| **Streaming** | Per-service content scripts (netflix-loader.js, amazon-loader.js, etc.) |
| **Utility/Legacy** | MV2 manifest or module-based background; no config.js or background-core.js |

Most extensions are **Template** type. VPN extensions (K2VPN, Rudder-VPN) are their own type. Ad-blocking extensions (Ad-Cleanse, Ditch-Ads) are Template + Ad-blocking. Streaming extensions (Netflix-Prime-Auto-Skip, JustClickSkip) are Utility/Legacy.

---

## Step 2 — Read EXTENSION.md (if present)

Check for `EXTENSION.md` in the project root. If it exists, read it and use its data to populate the CLAUDE.md (extension name, short name, IDs, domains, AMO URLs, search config, branding). If it does not exist, derive what you can from manifest.json and config.js as normal.

## Step 3 — Read the Project Files

**Always read:**
- `manifest.json` — MV, version, permissions, content scripts (run_at, world, matches), chrome_settings_overrides, browser_specific_settings gecko id + strict_min_version, any `REPLACE_*` placeholders (signals incomplete setup)
- `_locales/en/messages.json` — the three keys: extName, extShortName, extDescription
- `icons/` listing — confirm sizes present (standard: icon16, icon32, icon48, icon64, icon128), note extras (logo.png, logo.svg)
- `favicon.ico` — confirm present at root (required for search_provider.favicon_url)

**For Template extensions, also read:**
- `js/config.js` — all keys: NAME, DOMAIN, EXTID, FFADDID, and LPDOMAIN if uncommented (two-domain signal)
- `js/background-core.js` — **DO NOT read the full file**. Just confirm it's present. It's the shared drop-in core (byte-identical across the extension suite). Note it exposes `window.ExtCore` (see Section 4 below for the standard API surface).
- `js/background.js` — read fully: look for activation block (action.onClicked), EXT_HOOKS, product-specific `runtime.onMessage` handler, DNR sync logic, any VPN/proxy calls
- `js/contentscript.js` — check if it's the standard relay (postMessage bridge for `extInstalled`, `searchEngineAccepted`, `searchEngineNotAccepted`) — if so, note it as standard and don't summarize further
- `popup.html` / `js/popup.js` — if present: consent gate, dark mode, whitelist toggles, product-specific UI
- `consent.html` / `js/consent.js` — if present: element IDs (`consent_search`, `acceptConsent`, `declineConsent`), save path
- `options.html` / `js/options.js` — if present: what settings it manages
- `index.html` — if present: the product app page

**For VPN extensions, also read:**
- `js/k2vpn.js` (or `k2vpn.js`) — CONFIG.regions, CONFIG.regular (country→proxy mappings), CREDENTIALS, AUTO_DISCONNECT, ONBOARDING
- `js/proxy.js` — proxy activation/deactivation logic
- `js/background.js` — VPN seam: connect/disconnect handlers, country selection, status tracking
- `popup.html` / `js/popup.js` — connect button, country picker, status display, auto-disconnect toggle

**For Ad-blocking extensions, also read:**
- `adblock/rules.json` — note rule count
- `adblock/youtube-adblock.js` — presence and purpose
- `adblock/cosmetic.js` — presence and purpose
- `js/background.js` — DNR rule ID spaces (domain rules 10001-19999, session/tab rules 20001+), whitelist → DNR sync

**For Streaming extensions, also read:**
- Each content script file — which platform it handles, what logic it performs
- `js/shared-functions.js` or similar — any shared utilities
- `web_accessible_resources` in manifest — what's injected

**Also read if present:**
- `newtab.html` / `js/newtab.js` — if manifest has `chrome_url_overrides.newtab`
- `package.json` — note if present (unusual — most extensions have no build process)
- Any `build.js` or `build.sh` — if present, read to document build process

---

## Step 4 — Write CLAUDE.md

Save to the project root as `CLAUDE.md`. Use only the sections that apply to this extension. Skip any section with nothing meaningful to say.

---

```markdown
# [Extension Name]

[One paragraph: what this extension does, who it's for, what problem it solves. Be specific.]

## Extension Type

[One of: Template | VPN | Ad-blocking | Streaming | Utility]

[One sentence on what that means for this project — e.g., "Uses the standard config.js + background-core.js seam pattern shared across the extension suite."]

## Project Structure

[Every meaningful file and folder. Not just names — say what each one does.]

- `manifest.json` — MV3, version x.x.x, permissions: [list]
- `js/config.js` — extension config (NAME, DOMAIN, EXTID, FFADDID[, LPDOMAIN])
- `js/background-core.js` — shared drop-in core; never edit; exposes `window.ExtCore`
- `js/background.js` — per-extension seam: [what it adds/overrides]
- `js/contentscript.js` — standard relay (postMessage bridge); identical across suite
- `js/popup.js` + `popup.html` — [if present: what the popup does]
- `js/consent.js` + `consent.html` — consent gate; required before popup renders
- `js/options.js` + `options.html` — [if present: what settings are managed]
- `index.html` — [if present: product app page]
- `newtab.html` — [if present: new tab override]
- `icons/` — PNG icons at: 16, 32, 48, 64, 128px [+ any extras]
- `favicon.ico` — multi-size ICO at root, required for search_provider
- `_locales/en/messages.json` — i18n keys: extName, extShortName, extDescription
- `adblock/` — [if present: rules.json (N rules), youtube-adblock.js, cosmetic.js]

## Manifest

- Manifest Version: [2 or 3]
- Version: x.x.x
- Gecko ID: `{uuid}` (strict_min_version: 140.0)
- Permissions: [list each and why needed]
- Content scripts: [file → matches → run_at → world if non-default]
- Background: [service worker files in load order, or module type for MV2]
- Search provider override: [name, keyword, search_url]
- [Note any REPLACE_* placeholders if present — signals incomplete setup]

## Config (config.js)

```javascript
window.EXT_CONFIG = {
  NAME: "[display name]",
  DOMAIN: "[app-domain.com]",
  EXTID: "[chrome extension id]",
  FFADDID: "{[firefox gecko uuid]}",
  // LPDOMAIN: "[lp-domain.com]"  ← uncommented only for two-domain products
};
```

[Note if LPDOMAIN is active — means LP cookie sync is enabled. See LP System section.]

## Shared Core (background-core.js)

`background-core.js` is the **shared drop-in core** used across all template extensions. Never edit it per-extension.

It exposes `window.ExtCore` with:
- `ExtCore.PRODUCT` — `{ NAME, DOMAIN, EXTID, FFADDID, LPDOMAIN }` from EXT_CONFIG
- `ExtCore.DOMAINS` — derived URLs: `WEB`, `API`, `HOME`, `SEARCH`, `WWW`, `COOKIE`, `HOST`, `LPHOST`, `LPWEB`
- `ExtCore.CLIENT_OBJECT.KEYS` — all attribution/user field names (guid, sessionGuid, ebid_id, aff_id, aff_sub 1–5, gclid, msclkid, fbclid, source, offer_id, installDate, country_code, etc.)
- `ExtCore.CHROME_STORAGE.KEYS` — storage key constants: `USER` ("userObj"), `FIRST_DEFAULT_SEARCH`, `FIRST_OPEN`, `SEARCH_PROMPT`, `DID_SEARCH`, `SITELIST`, `EXT_DATA_PREFIX`
- `ExtCore.COOKIE_STORAGE.KEYS` — `USER: "{EXTID}_userInfo"`
- `ExtCore.getStoredValue(key)` / `ExtCore.setStoredValue(key, val)` — chrome.storage.local helpers
- `ExtCore.setExtSetting(name, val)` — storage + cookie sync combined
- `ExtCore.logExtEvent(name, userObj)` — image beacon to API

**Core lifecycle (initialize()):**
1. Read userObj from chrome.storage.local
2. Read user cookie from app domain
3. Merge LP cookie if two-domain (syncLpUserCookieToApp)
4. Fill required fields (UUID, source, install date, etc.)
5. Persist to storage + cookie
6. Start alarms: `hb` (heartbeat, 60 min) + `cookieCheck` (sync, 1 min)
7. Set up cookie change listener

**Shared message handler** answers: `setExtSetting`, `getUserObj`, `getManifestInfo`, `isFirstOpen`, `alreadyInstalled`.

## Background Logic (background.js)

[Describe what the per-extension seam adds:]

**Activation:** [page-opening products only] `browser.action.onClicked` → opens `index.html` (or `consent.html`) in a new tab. Not present in popup products (they use `action.default_popup` in manifest).

**Product-specific messages:** [list any `runtime.onMessage` handlers added, what actions they handle]

[Ad-blocking: DNR sync logic — domain rules (IDs 10001–19999) and session/tab rules (IDs 20001+)]

[VPN: proxy activation/deactivation, country selection, status tracking]

**Pattern:** product handler returns `undefined` for unrecognized actions so the core handler still catches shared messages.

## Content Scripts

[For each content script:]

**`js/contentscript.js`** — Standard relay. Converts `runtime.onMessage` → `window.postMessage` for three signals: `extInstalled`, `searchEngineAccepted`, `searchEngineNotAccepted`. Matches: `[list domains]`. Identical across suite — do not modify.

[Any specialized content scripts:]

**`adblock/youtube-adblock.js`** — [if present] Runs at document_start in MAIN world on YouTube. [What it does.]

**`adblock/cosmetic.js`** — [if present] Runs at document_start in all frames. [What it does.]

## Attribution & Cookie System

**Cookie name:** `{EXTID}_userInfo` (e.g., `hcmeaijalhffpmbmjiooghkealpbcmdn_userInfo`)
**Domain:** `.app-domain.com` (dot-prefixed, covers all subdomains)
**Expiry:** 10 years
**Format:** JSON string with HASH field for validation

**Tracked fields** (from `CLIENT_OBJECT.KEYS`):
- Identity: `guid`, `sessionGuid`
- Attribution: `ebid_id`, `offer_id`, `aff_id`, `affid`, `offer_url_id`, `source`
- Affiliate sub-params: `aff_sub` through `aff_sub5`
- Click IDs: `gclid` (Google), `msclkid` (Bing), `fbclid` (Facebook)
- Search: `searchAccepted`, `searchEngine`
- Device/install: `country_code`, `installDate`, `extensionId`, `extensionName`, `extensionVersion`
- Consent: `dataConsent`

## LP / Two-Domain System

[Include ONLY if LPDOMAIN is active in config.js]

This extension uses two domains: `[LP domain]` (landing page) → `[app domain]` (app).

On first install: background-core.js reads the cookie from `[LP domain]` (both http/https variants) and merges all attribution fields into the app domain cookie. On subsequent visits: only click ID fields (gclid, msclkid, fbclid) are re-merged to avoid overwriting app-side data.

## Consent Gate

All popup products gate on `dataConsent` before rendering. If not `'accepted'`, popup opens `consent.html` in a new tab and closes itself.

**consent.html required element IDs:**
- `#consent_search` — checkbox (data collection opt-in)
- `#acceptConsent` — accept button
- `#declineConsent` — decline button

**Values:** `'accepted'` (user accepted) or `'declined'` (rejected or unchecked search box). Stored via `ExtCore.setExtSetting('dataConsent', value)`.

[Page-opening products: accept → opens index.html; decline → closes tab]
[Popup products: both paths close the tab]

## VPN Architecture

[Include ONLY for VPN extensions]

Config lives in `k2vpn.js` (not config.js):
- `CONFIG.regions` — array of region names
- `CONFIG.regular` — country-keyed object with `{ active, fullName, region, proxy: { scheme, host, port } }`
- `CREDENTIALS` — `{ username, password, retryCount, obfuscateLevels }`
- `AUTO_DISCONNECT` — `{ enabled, minutes }`
- `ONBOARDING` — `{ storageKey, completeValue, slides: [...] }`

**proxy.js** manages Firefox proxy API: activate, deactivate, handle `webRequestAuthProvider` credential challenges.

**Storage keys used:**
- `status` — "connected" / "disconnected"
- `activeCountry` — currently connected country code
- `chosenCountry` — user-selected country
- `latestCountries` — recently used country list
- `autoDisconnect` — timer config

## Declarative Net Request (Ad-blocking)

[Include ONLY for ad-blocking extensions]

**Static rules:** `adblock/rules.json` ([N] rules)

**Dynamic rules (domain whitelist):**
- IDs 10001–19999: domain-level allow rules (initiatorDomains, resourceTypes: all)
- Persisted to storage via `ExtCore.setStoredValue()`

**Session rules (page whitelist):**
- IDs 20001+: tab-specific allow rules (tabIds, cleared on tab close)
- Not persisted (session-only)

**URL normalization:** strips query string and trailing slash before matching whitelist entries.

## Popup

[Include only if popup.html is present]

[Describe the popup UI: what it shows, what controls it has, what storage keys it reads/writes]

**Flow:**
1. Gate on `dataConsent` — redirect to consent.html if not accepted
2. [Describe the rest of the flow]

**Dark mode:** toggle stored as `darkMode` boolean; applied as body class before first render.

**Guard:** whitelist toggles are disabled for browser-internal pages (`about:`, `moz-extension:`, `chrome:`, `file:`).

## Icons & Assets

- PNG icons in `icons/`: icon16.png, icon32.png, icon48.png, icon64.png, icon128.png
- [Any extras: logo.png (horizontal lockup), logo.svg (source), icon.svg]
- `favicon.ico` at root — multi-size (16/32/48), required by `chrome_settings_overrides.search_provider.favicon_url`

[VPN: `assets/icons/` instead of `icons/`; includes flag icons in `assets/icons/flags/`]

## Version Format

`major.minor.patch` — increment patch per change. Patch rolls at 9: `1.0.9 → 1.1.0`. Never skip versions.

## Coding Conventions

- **IIFE:** all JS files wrap in `(function () { 'use strict'; })();`
- **Cross-browser:** `var browser = window.browser || window.chrome;` at top of every script
- **Variables:** `var` preferred over `let` for compatibility; `const` for true constants
- **Async:** `.then().catch()` in background-core.js; `async/await` in newer extension code
- **Messages:** handlers return a `Promise` for async replies, or `undefined` to pass through to the core handler
- **Storage:** always use `ExtCore.setStoredValue()` / `ExtCore.getStoredValue()` — not raw `chrome.storage` calls — so changes sync to the cookie
- **No build process:** plain JavaScript, no transpilation or bundling. Validate with `node --check file.js`.
- **Comments:** single-line `//` for intent notes; `/* */` blocks in config headers only

## Do Not Modify

- **`js/background-core.js`** — shared across the entire extension suite, byte-identical. Any fix must go to the shared source.
- **`js/contentscript.js`** — standard relay, identical across suite. Do not add product logic here.
- **Cookie name format** (`{EXTID}_userInfo`) — hardcoded in background-core.js and matched server-side. Never change.
- **`CLIENT_OBJECT.KEYS` field names** — server-side contract for attribution data. Adding fields is fine; renaming or removing breaks ingestion.

## Key Behaviors & Gotchas

[Non-obvious things a developer needs to know:]

- [Any timing-sensitive logic]
- [Known quirks or workarounds]
- [Things that look wrong but are intentional]
- [Cross-extension shared code gotchas]
- [Hardcoded values that must stay hardcoded]

## Development

**Load in Firefox:** about:debugging → This Firefox → Load Temporary Add-on → select `manifest.json`

**Test install flow:** unload → reload extension → background service worker install event fires → check storage for `userObj`, check cookie for `{EXTID}_userInfo`

**Debug background:** about:debugging → Inspect (service worker) → Console

**Packaging for AMO:** zip extension directory contents. Always exclude: `META-INF/` and all dot-directories (`.assets/`, `.builds/`, `.tools/`, `.notes/`, `.vscode/`).
```

---

## Rules

- **Never access any file or folder whose name starts with `.` — skip them entirely.**
- Identify extension type before reading files — it determines which sections to generate.
- **Do not read `background-core.js` in full.** Its API surface is standardized and documented in the template above. Just confirm it's present.
- Be specific throughout. Vague entries like "handles background tasks" are useless. Name the actual functions, storage keys, message action strings, and alarm names.
- If `config.js` is present, list all its actual key values in a code block.
- If contentscript.js is the standard relay, say so once and don't summarize further.
- If a section doesn't apply to this extension (no popup, no VPN, no LP system), skip it entirely.
- Don't mention internal org names in the output.
- Keep prose tight — this is a reference doc, not an essay.
- Save the file as `CLAUDE.md` at the project root before responding.
