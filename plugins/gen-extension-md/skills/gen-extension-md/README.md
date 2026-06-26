# gen-extension-md

Creates or updates the `EXTENSION.md` identity file for a Firefox MV3 browser extension in the BitBoxMedia suite. `EXTENSION.md` is the canonical identity reference for an extension and should be filled out completely before any other work begins.

## When to trigger

Use this skill when the user asks to:
- Create or generate an EXTENSION.md
- Fill out or update an EXTENSION.md
- Set up a new extension (EXTENSION.md is missing)
- "Write the extension md"
- "Create the identity file"

## What it reads

The skill reads four sources from the project directory to fill in all fields:

| File | Fields sourced from it |
|------|----------------------|
| `manifest.json` | Extension name, version, search keyword, search URL |
| `config.js` | FFADDID, EXTID, domains, search URL, API/redirect endpoints |
| `_locales/en_US/messages.json` | Short name |
| `icons/*.png` | Brand color scheme, icon style |

## Output

A completed `EXTENSION.md` file in the project root with these sections:

- **Identity** - name, short name, dir, AMO slug, FFADDID, EXTID, version
- **Domains** - primary, search, API (if applicable), WWW (if applicable), landing page
- **Firefox / AMO** - listing URL, developer hub URL
- **Search / Redirect** - search URL (with `{searchTerms}`), keyword
- **Branding** - hex color scheme, icon style description
- **Notes** - left blank for dev notes over time

## Key rules

- FFADDID must have curly braces: `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}`
- EXTID is 32 characters, no braces
- AMO Slug is all lowercase, hyphens only
- Search URL must use `{searchTerms}` placeholder, not `%s`
- Dir must match the actual folder name on disk exactly
- API/WWW domain lines are only included if those domains exist in `config.js`
- AMO Reviewer Notes section must not appear in the file
- Notes section is left blank on first creation

## Related skills

- `gen-changelog` - generates changelogs and commit messages for extension releases
