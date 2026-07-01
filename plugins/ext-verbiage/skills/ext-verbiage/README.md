# ext-verbiage

Writes and reviews all public-facing copy for browser extensions: manifest description, listing summary, full listing description, tags, categories, and optional notes to reviewer.

## When to trigger

Use this skill whenever drafting, rewriting, editing, polishing, or reviewing any text an extension's end users will see in a listing or product page -- even if the request just says:
- "Write a description"
- "Tighten this listing"
- "Write the summary"
- Names a specific extension and asks for copy

Do NOT use this skill for code comments, commit messages, internal docs, dev chat, or any text only a developer reads.

## How it works

1. **Read EXTENSION.md** (if present in the project root) for name, domains, AMO slug, search URL, and branding notes. Falls back to manifest.json and _locales/en/messages.json if not present.
2. **Write all six output fields** (see below)
3. **Write outputs** to .docs/LISTING.txt and manifest description to _locales/en/messages.json or manifest.json

## Output fields

| Field | Label | Limit |
|---|---|---|
| Manifest description | MANIFEST DESCRIPTION: | 250 chars max |
| Listing tagline | LISTING SUMMARY: | 250 chars max |
| Full listing description | LISTING DESCRIPTION: | 1500 chars min |
| Discoverability terms | LISTING TAGS: | 5-10 terms |
| AMO categories | LISTING CATEGORIES: | Up to 3 from fixed list |
| Notes to reviewer | NOTES TO REVIEWER: | Only when necessary |

Character counts are reported alongside each length-bound field.

## Voice and tone

Clean, professional, plain. Benefit-first, active voice, addresses the user as "you." Confident but never hypey -- no "best," "amazing," "revolutionary." Warm but not chatty.

## Hard rules (never break)

- **Forbidden words:** version numbers, "lines," "template"
- **Search claims:** may describe private browsing / search function plainly; must NOT claim replacing or silently changing the browser's default search engine
- **Characters:** US keyboard only -- no em dashes, en dashes, curly quotes, accented letters, or emoji
- **Honesty:** never use "guaranteed," "100%," "instantly," or unverifiable claims
- **No internals:** no architecture, code structure, or implementation details

## Outputs

- **Standalone:** writes .docs/LISTING.txt (creates .docs/ if needed); writes manifest description to _locales/en/messages.json extDescription or manifest.json description
- **Called from ext-duplicate / ext-publish:** returns all outputs for the calling skill to place

## Related skills

- `ext-publish`: Calls ext-verbiage for listing verbiage refresh during the release flow
- `ext-duplicate`: Calls ext-verbiage to write listing copy for the new extension
