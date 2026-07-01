# ext-legal

Generates a US (CCPA) + GDPR compliant privacy policy and a California-governed terms of service for a Firefox browser extension and its associated website. One scan, one effective date, both documents in a single run.

## When to trigger

- "generate privacy policy"
- "generate terms of service"
- "generate legal docs"
- "write privacy and terms"
- "create privacy policy for my extension"
- Called automatically from `ext-website` with all context passed in

## How it works

1. **Gather info** — asks for extension directory, extension name, company name, website domain, contact email, output format, and which documents to generate. If called from `ext-website`, all of this is passed in automatically.
2. **Calculate effective date** — takes today's date, subtracts 1 year plus 1–12 random months, formats as month + year only (e.g. "March 2025"). Used in both documents.
3. **Scan extension project** — reads `manifest.json`, `CLAUDE.md`, `README.md`, `.docs/LISTING.txt`, and background JS files to identify: permissions, storage/cookie usage, external API calls, consent collection, and any PII-touching behavior.
4. **Present scan summary** — shows what was found before generating, lets you add anything missing.
5. **Generate documents** — produces privacy policy and/or terms of service using fixed section structures (see SKILL.md for full outlines).
6. **Review pause** — summarizes what was generated and asks for confirmation or changes before finishing.

## Inputs

| Field | Required | Notes |
|---|---|---|
| Extension project directory | Yes | Scanned for permissions and data behavior |
| Extension name | Yes | Used throughout both documents |
| Developer/company name | No | Defaults to extension name if omitted |
| Website domain | Yes | Used for contact email and document references |
| Contact email | No | Defaults to `support@{domain}` |
| Output format | Yes (standalone) | plain text, markdown, or html |
| Which documents | Yes (standalone) | privacy policy, terms, or both |

## Outputs

**Standalone mode:**
- Privacy policy and/or terms of service in the requested format (plain text, markdown, or HTML)
- Delivered as files in the conversation

**Called from `ext-website`:**
- `privacy/index.html` → written inside `.website/`
- `terms/index.html` → written inside `.website/`
- Both use the site's shared CSS and include the shared nav/footer
- Tracking script is excluded from both pages

## Edge cases

- **No EXTENSION.md or manifest.json found** — skill will ask for extension name and behavior manually rather than failing
- **No external APIs detected** — Third-Party Services section is kept minimal; Mozilla/AMO is always listed as the distribution platform
- **EU-only or US-only needed** — the skill always generates both CCPA and GDPR coverage; you can ask it to strip one jurisdiction after generation
- **sys-web-audit dependency** — the Vercel guidelines URL this skill links to in the HTML output is fetched live; if you are offline the HTML version will have a dead link

## Related skills

- `ext-website` — calls `ext-legal` automatically when building a full extension website
- `ext-duplicate` — may call `ext-legal` when scaffolding a new extension that needs legal docs
