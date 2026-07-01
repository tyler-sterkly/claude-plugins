# ext-context

Examines a Firefox browser extension project and writes a comprehensive `CLAUDE.md` to the project root, covering architecture, API surface, coding conventions, and everything a developer needs to work on the extension.

## When to trigger

Use this skill when the user asks to:
- "Generate context for this extension"
- "Analyze this extension"
- "Write CLAUDE.md for this extension"
- Starting work on an extension that has no CLAUDE.md yet

## How it works

### Step 1: Identify extension type

Reads the root directory and manifest.json to classify the extension:

| Type | Signals |
|---|---|
| Template | config.js + background-core.js; seam pattern |
| VPN | k2vpn.js + proxy.js; no config.js |
| Ad-blocking | adblock/ directory with rules.json; DNR permissions |
| Streaming | Per-service content scripts |
| Utility/Legacy | MV2 or module-based; no config.js or background-core.js |

Most extensions are Template type.

### Step 2: Read EXTENSION.md (if present)

Uses identity data (name, IDs, domains, AMO URLs) from EXTENSION.md to populate the CLAUDE.md. Falls back to manifest.json and config.js if not present.

### Step 3: Read project files

Reads different files depending on extension type. For Template extensions: manifest.json, _locales/en/messages.json, icons listing, config.js, background.js, contentscript.js, popup.html/js, consent.html/js, options.html/js. Does NOT read background-core.js in full -- just confirms its presence.

For VPN extensions: k2vpn.js, proxy.js, background.js, popup.html/js.

For Ad-blocking extensions: adblock/rules.json, youtube-adblock.js, cosmetic.js, background.js (DNR logic).

### Step 4: Write CLAUDE.md

Writes a comprehensive CLAUDE.md to the project root with sections for:
- Extension overview and type
- Project structure (every meaningful file and what it does)
- Manifest details (version, permissions, content scripts, gecko id)
- Config (actual key values in a code block)
- Shared Core API surface (ExtCore.PRODUCT, ExtCore.DOMAINS, storage helpers, lifecycle)
- Background logic (per-extension seam additions)
- Content scripts
- Attribution and cookie system
- LP / two-domain system (only if LPDOMAIN is active)
- Consent gate
- VPN architecture (VPN extensions only)
- Declarative Net Request (ad-blocking only)
- Icons and assets
- Coding conventions
- Do Not Modify section
- Key behaviors and gotchas
- Development workflow

## Rules

- Never access dotfiles or dotfolders
- Identify extension type before reading files
- Do not read background-core.js in full (API surface is standardized)
- Be specific -- name actual functions, storage keys, message action strings, alarm names
- Skip sections that do not apply
- Do not mention internal org names in the output
- Save CLAUDE.md to the project root before responding

## Related skills

- `ext-audit`: Audits the extension and produces a ranked update plan
- `ext-review`: Code quality review saved to docs/review.md
- `ext-duplicate`: Calls ext-context as part of the duplication flow
