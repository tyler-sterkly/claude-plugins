---
name: gen-extension-md
description: Creates or updates the EXTENSION.md identity file for a Firefox MV3 browser extension in the BitBoxMedia suite. Use when the user asks to create, generate, fill out, or update an EXTENSION.md file for an extension. Also triggers when setting up a new extension or when EXTENSION.md is missing or incomplete.
allowed-tools: Read, Bash, Edit, Write, Glob
---

# Create and Fill Out an EXTENSION.md File

You are helping set up or update an EXTENSION.md file for a Firefox MV3 browser extension in the BitBoxMedia suite. This file is the canonical identity reference for the extension. It lives in the project root and should be filled out completely and accurately before any other work begins on the extension.

Before filling in any field, read the following files from the project directory. They contain almost everything needed:

- `manifest.json` — version, search keyword, search URL, extension name
- `config.js` — FFADDID, EXTID, domains, search URL, any API or redirect endpoints
- `_locales/en_US/messages.json` — short name
- `icons/` — PNG icon files (inspect for brand color and style)

Use the template below. Fill in every field. Instructions for each field follow the template.

---

## Template

```md
# [Extension Full Name]

## Identity
- Name: [Extension Full Name]
- Short Name: [Short Name]
- Dir: FF-extension-[name]
- AMO Slug: [amo-slug]
- Firefox Extension ID (FFADDID): {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}
- Chrome Extension ID (EXTID): xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Current Version: [x.x.x]

## Domains
- Primary Domain: [domain.com]
- Search Domain: search.[domain.com]
- Landing Page Domain: [N/A or domain if applicable]

## Firefox / AMO
- AMO Listing URL: https://addons.mozilla.org/en-US/firefox/addon/[amo-slug]/
- AMO Developer Hub URL: https://addons.mozilla.org/en-US/developers/addon/[amo-slug]/edit

## Search / Redirect
- Search URL: https://search.[domain.com]/search?q={searchTerms}
- Search Keyword: [keyword]

## Branding
- Brand Color Scheme: [#primary, #secondary, #accent or N/A]
- Icon Style: [description or leave blank]

## Notes
```

---

## Field-by-Field Instructions

### H1 Title
The top-level heading is the full marketing name of the extension, exactly as it appears on AMO. Match capitalization and punctuation precisely.

Where to find it: `manifest.json` → `name` field. Cross-check against the AMO listing if the extension has been submitted.

Examples from the suite:
- `# Ad Cleanse & Search`
- `# K2VPN: Free Private Search VPN`
- `# Rudder VPN: Free Private Search VPN`
- `# Metric Unit Conversion Calculator`

---

### Identity

**Name**
Same as the H1 title. The full display name as it appears on AMO and in the browser extension manager.

Where to find it: `manifest.json` → `name`

**Short Name**
A compact 1-2 word version for toolbar and space-limited contexts.

Where to find it: `_locales/en_US/messages.json` (or the equivalent locale folder) - look for a `shortName` or `appShortName` message key and use its `message` value. Examples from the suite: `Ad Cleanse`, `K2VPN`, `Rack`, `Unit`, `AIOP`.

**Dir**
The project folder name within the BitBoxMedia org. Format: `FF-extension-[PascalOrKebab]`.

Where to find it: Look at the actual folder name on disk. Do not derive it - copy it exactly. Examples: `FF-extension-Ad-Cleanse`, `FF-extension-K2Vpn`, `FF-extension-Metric-Unit-Conversion-Calculator`.

**AMO Slug**
The URL slug for the AMO listing. All lowercase, hyphens only, no underscores.

This is determined at the time of first AMO submission and does not exist in the project files yet. Leave as the placeholder for now.

**Firefox Extension ID (FFADDID)**
The GUID assigned by Firefox/AMO. Format: `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}` - curly braces required.

Where to find it: `config.js` - look for a constant like `FFADDID`, `FIREFOX_EXT_ID`, or similar. This is always defined there.

**Chrome Extension ID (EXTID)**
The 32-character lowercase alphanumeric ID from the Chrome Web Store. No dashes, no curly braces.

Where to find it: `config.js` - look for a constant like `EXTID`, `CHROME_EXT_ID`, or similar. This is always defined there.

**Current Version**
Three-digit version string.

Where to find it: `manifest.json` → `version`. Always keep this in sync after any release. Third digit increments per change and rolls to 0 (bumping the second digit) at 9: 1.0.9 → 1.1.0.

---

### Domains

**Primary Domain**
The main brand domain for the extension's website.

Where to find it: `config.js` - look for a constant like `PRIMARY_DOMAIN`, `BASE_URL`, or the root of any redirect or homepage URL. Also visible in the post-install landing page HTML if one exists. Examples: `ad-cleanse.com`, `k2vpn.net`, `ruddervpn.com`, `manualrack.com`.

**Search Domain**
The subdomain used for the search relay. The value can be recorded either as a full `subdomain.domain.tld` (e.g. `search.ad-cleanse.com`) or as just the subdomain portion with its trailing period (e.g. `search.`), whichever makes more sense for the extension. Almost always starts with `search.`.

Where to find it: `config.js` → `SEARCH_URL` or similar constant. Pull just the host portion from that URL.

**API Domain** (include this line only if applicable)
A separate subdomain used for API calls. Record as a full `subdomain.domain.tld` (e.g. `api.accessusermanuals.com`) or just the subdomain with its period (e.g. `api.`) if the domain is implied by context. Only add this line to EXTENSION.md if it actually exists.

Where to find it: `config.js` - look for any `API_URL`, `API_BASE`, or endpoint constants pointing to a subdomain other than `search.`.

**WWW Domain** (include this line only if applicable)
A separate view or www subdomain. Same format rules as above - full `subdomain.domain.tld` or just `subdomain.`. Only add this line if it exists.

Where to find it: `config.js` or any redirect/referral URLs in the background script.

**Landing Page Domain**
The domain for the post-install or consent landing page. Unlike the other domain fields, this is typically a completely different domain from the primary domain - not a subdomain of it. It is a standalone domain the user is sent to after installing the extension. For most extensions in the suite this is `N/A`.

Where to find it: `config.js` → any `LP_URL`, `LANDING_URL`, or post-install redirect constant. Also check `background.js` or `background-core.js` for the URL passed to `tabs.create` on install. Extract just the domain from that URL.

---

### Firefox / AMO

Both URLs are constructed by slotting the AMO Slug into a fixed pattern. Since the slug is not yet known, leave both URLs as placeholders using the template format below. Fill them in once the extension is submitted to AMO and the slug is assigned.

**AMO Listing URL**
Format: `https://addons.mozilla.org/en-US/firefox/addon/[amo-slug]/`

**AMO Developer Hub URL**
Format: `https://addons.mozilla.org/en-US/developers/addon/[amo-slug]/edit`

---

### Search / Redirect

**Search URL**
The full search redirect URL template including the `{searchTerms}` placeholder.

Where to find it: `manifest.json` → `chrome_settings_overrides.search_provider.search_url`. Cross-check with `config.js` → `SEARCH_URL`. The value must use `{searchTerms}` as the query placeholder, not `%s` or anything else.

**Search Keyword**
The address bar keyword that triggers the extension's search engine.

Where to find it: `manifest.json` → `chrome_settings_overrides.search_provider.keyword`. Examples from the suite: `adcleanse`, `k2vpn`, `units`, `manualrack`, `ruddervpn`.

---

### Branding

**Brand Color Scheme**
Hex values for the extension's primary colors. Format: `#primary, #secondary, #accent`.

Where to find it: Open the PNG icon files in `icons/`. If you can read the files directly, look for the dominant colors. If the icons are not yet created or colors cannot be determined from the PNGs alone, check any CSS files in the extension's popup or new tab page for color variables or hex values. If no colors have been defined yet, write `N/A`.

**Icon Style**
A short plain-text description of the icon's visual design.

Where to find it: Look at the PNG files in `icons/`. List what sizes are present (e.g. 16, 32, 48, 96, 128) and describe the visual: shape, subject, style. Examples: `flat shield with gradient`, `circular badge with magnifier`, `document with wrench`. Leave blank if icons do not exist yet.

---

### AMO Reviewer Notes

This section does not belong in EXTENSION.md. If it is present in an existing file, remove it entirely.

---

### Notes

Leave blank. This section is for dev notes added over time as work on the extension progresses. On first creation of the file there is nothing to put here.

---

## Things to Double-Check Before Saving

- H1 title matches `manifest.json` → `name` exactly, including capitalization and punctuation.
- FFADDID has curly braces: `{...}` and came from `config.js`.
- EXTID is 32 characters with no braces and came from `config.js`.
- Current Version matches `manifest.json` → `version`.
- AMO Slug is all lowercase, hyphens only, no underscores.
- Search URL uses `{searchTerms}` - not `%s` or any other placeholder.
- Dir matches the actual folder name on disk exactly.
- Extra domain fields (API, WWW) are only present if those domains actually exist in `config.js` or the background script.
- Landing Page Domain is `N/A` if there is no separate standalone landing page domain.
- All domain values have no trailing slash and no `https://` prefix.
- AMO Reviewer Notes and Notes sections are left blank.
