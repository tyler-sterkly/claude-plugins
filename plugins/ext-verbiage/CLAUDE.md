# ext-verbiage

Writes all public-facing copy for browser extension listings: manifest description, listing summary, full description (1500+ chars), tags, categories, and optional notes to reviewer. Hard rules on forbidden terms and character set.

## Design decisions

- Standalone mode writes .docs/LISTING.txt and updates _locales/en/messages.json extDescription (or manifest.json description for non-i18n products)
- Invoked mode (from ext-duplicate or ext-publish) returns all outputs; the calling skill handles file placement
- EXTENSION.md is the authoritative source for name, domains, and branding when present
- Notes to reviewer is generated only when necessary (test credentials needed, permissions need explaining) -- not by default

## Hard rules (enforced by self-check)

- Forbidden words: version numbers, "lines", "template"
- Search claims: describe the function plainly; never claim forced default-search-engine replacement
- US keyboard characters only: no em/en dashes, curly quotes, accented letters, emoji
- No unverifiable claims ("guaranteed", "100%", "instantly")
- Full listing description: minimum 1500 characters, must follow the 6-part structure
- Manifest description: 250 characters maximum

## Related skills

- `ext-publish`: Calls ext-verbiage for listing verbiage refresh
- `ext-duplicate`: Calls ext-verbiage to write listing copy for new extension
