---
name: ext-verbiage
description: Write and review public-facing copy for browser extensions. Covers listing summaries, full descriptions, feature lists, and any user-visible marketing text. Use this skill WHENEVER drafting, rewriting, editing, polishing, or reviewing any text that an extension's end users will see in a listing or product page, even if the request just says "write a description," "tighten this listing," "write the summary," or names a specific extension. Do NOT use this for code comments, commit messages, internal docs, dev chat, or any text only a developer reads.
---

# Write Extension Verbiage

How to write public-facing verbiage for browser extensions (listings and anything users see). This style is deliberate and the opposite of casual dev chat: it is polished, professional, and complete.

## Step 0 — Read EXTENSION.md

Before writing any copy, check for `EXTENSION.md` in the project root. If it exists, read it and use its data (Name, Short Name, Domains, AMO Slug, Search URL, Branding notes) to inform the copy. If it does not exist, derive what you can from manifest.json and _locales/en/messages.json.

## When this applies

Apply this skill to any user-visible text for an extension:
- Manifest description
- Listing summary
- Full listing description
- Feature lists
- Privacy or data notes shown to users
- Any product-page or marketing copy

Do not apply it to developer-facing text (chat, code, commit messages, internal notes). That text follows a separate casual style and is out of scope here.

## Voice and tone

- Clean, professional, plain. Proper grammar and full sentences.
- Confident but never hypey. Do not use "best," "amazing," "revolutionary," or similar puffery.
- Address the user directly as "you."
- Active voice.
- Warm but not chatty.

## What to say

- Lead benefit-first. Open with what the user gets, not how it works.
- Frame features as outcomes for the user, not mechanics.
- Make only honest, verifiable claims. Never use "guaranteed," "100%," "instantly," or any claim that cannot be backed up. Unverifiable claims get rejected in review.
- Never expose internals: no architecture, code structure, or implementation detail. Users care about outcomes.
- Include a brief privacy or data note when relevant.

## Output fields

This skill produces the pieces of copy below. Keep them clearly separated and labeled.

### 1. Manifest description (for manifest.json)

A plain text string for the `description` field in `manifest.json`. This shows in the browser's about:addons UI.

Rules specific to this field:
- Plain text only -- no HTML, no markdown, no formatting
- 250 characters maximum (cross-browser safe limit)
- One sentence, benefit-first
- Must accurately describe what the extension does so users are not surprised after installing
- All hard rules apply: no forbidden words, US-keyboard characters only, no puffery, honest claims only, no internals exposed

Return this labeled as: `MANIFEST DESCRIPTION:`

### 2. Listing Summary

A short tagline for the listing summary field.

Rules:
- 250 characters maximum
- Plain text, one or two sentences
- Benefit-first, scannable at a glance

Return this labeled as: `LISTING SUMMARY:`

### 3. Listing Full Description

The full listing description. **Minimum 1500 characters** -- make it rich and complete; thin descriptions read as low-effort and underperform in the listing.

Follow this structure:
1. Benefit-first intro (2-3 sentences) -- what the user gets.
2. "What [Product] does" -- a short paragraph in plain user terms.
3. Feature list -- benefit-driven; each item is a short phrase followed by a brief explanation of the outcome (not bare one-liners).
4. "Who it's for" -- a few real use cases or scenarios.
5. Privacy or data note.
6. Short closing line.

Return this labeled as: `LISTING DESCRIPTION:`

### 4. Listing Tags / Keywords

About 5-10 relevant, honest discoverability terms for the listing. Plain, comma-separated. Same honesty rules apply -- no competitor or other-product names, nothing misleading.

Return this labeled as: `LISTING TAGS:`

### 5. Listing Categories

Select up to 3 categories from the fixed AMO list below that honestly describe the extension. Only pick categories that genuinely fit -- do not select extras to game discoverability.

Valid AMO categories (choose up to 3):
- Alerts & Updates
- Appearance
- Bookmarks
- Download Management
- Feeds, News & Blogging
- Games & Entertainment
- Language Support
- Photos, Music & Videos
- Privacy & Security
- Search Tools
- Shopping
- Social & Communication
- Tabs
- Web Development
- My add-on doesn't fit into any of the categories

Return this labeled as: `LISTING CATEGORIES:`

### 6. Notes to reviewer (optional)

Generate this **only when necessary** -- for example, when the extension needs test credentials or a login to exercise, or its permissions/network behavior need explaining for AMO human review. It is reviewer-facing and factual, so it is **not** subject to the marketing rules below (it may name technical details, settings, permissions, etc.). Omit it entirely when nothing needs explaining.

If `EXTENSION.md` exists and has content under `## AMO Reviewer Notes`, include that content here as the base. Expand or clarify as needed.

Return this labeled as: `NOTES TO REVIEWER:`

### Character counts

Report the character count alongside each length-bound field: manifest description (<=250), listing summary (<=250), and full description (>=1500). This makes the limits verifiable at a glance.

### Output destination

- **Standalone:** write `.docs/LISTING.txt` (create the `.docs/` directory if it does not exist) containing the listing summary, full description, tags, categories, and the notes-to-reviewer (if generated). Put the manifest description into `_locales/en/messages.json` `extDescription` (i18n products) or `manifest.json` `description` (non-i18n products).
- **Called from ext-duplicate / ext-publish:** return all outputs; those skills handle placement.

## Product naming

Always use the full product name, spelled and capitalized exactly the same way every time within a listing. Pick one form and stay consistent.

## Hard rules (never break)

These are absolute and override stylistic preference:

- Forbidden words, never use any of them in public copy: version numbers, "lines," "template."
- **Search claims (scoped, not banned):** you may describe the product's private browsing / search function plainly. You must NOT make misleading or unverifiable claims about replacing, hijacking, or silently changing the browser's default search engine or other settings -- that language gets rejected in review (and violates AMO search-settings policy). Describe what the user gets, not a forced settings change.
- US-keyboard characters only. No em dashes, en dashes, curly quotes, accented letters, or emoji. Plain ASCII punctuation only.

## Self-check before delivering

- Did I lead with a user benefit in every output?
- Is the manifest description 250 characters or under? (report the count)
- Is the listing summary 250 characters or under? (report the count)
- Is the full description at least 1500 characters and following the 6-part structure? (report the count)
- Did I produce listing tags, and notes-to-reviewer only if actually needed?
- Did I select at most 3 listing categories and are they all honest fits for this extension?
- Is every claim honest and verifiable?
- Did I avoid the forbidden words (version numbers, "lines," "template")?
- For any search wording: did I describe the function without claiming a forced default-search-engine change?
- Are all characters available on a US keyboard?
- Is the product name consistent throughout?
- Did I keep internals and implementation detail out?
- Did I apply all hard rules to the manifest description too (forbidden words, US keyboard, no puffery, no internals)?
