# gen-privacy

Generates a US (CCPA) + EU (GDPR) compliant privacy policy for a Firefox browser extension and its associated website.

## When to trigger

Use this skill when the user says:
- "Generate a privacy policy"
- "Write a privacy policy"
- "Create a privacy policy"

Also called automatically from `generate-website` and `generate-terms`.

Always use this skill for privacy policy generation even if the request seems simple.

## Two modes

**Called from `generate-website`:** All required info is passed in automatically. Outputs to `.website/privacy/index.html` using the site's shared CSS, nav, and footer.

**Called standalone:** Asks for required info first, then outputs in the user's chosen format (plain text, markdown, or HTML).

## How it works

### Step 1: Gather required info (standalone only)

Asks in one message for:
- Extension project directory
- Extension Name
- Developer/Company Name (optional, defaults to Extension Name)
- Website domain
- Contact email (optional, defaults to support@{domain})
- Output format (plain text, markdown, or HTML)

### Step 2: Calculate effective date

Takes today's date, subtracts 1 year, then subtracts a random number of months between 1 and 12. Formatted as month and year only (e.g., "March 2025"). No day included.

### Step 3: Scan extension project

Reads these files from the extension project directory:
- `manifest.json`: permissions array, host_permissions, extension description
- `CLAUDE.md`: data collection notes, cookie/attribution details
- `README.md`: project overview
- `.docs/LISTING.txt`: what the extension does
- Background JS files: scanned for cookie, storage, and tracking patterns

From this scan identifies: browser permissions requested, attribution/tracking cookies, external API calls, user consent collection, and any PII touched.

Presents the user with a scan summary and asks if anything should be added before generating.

### Step 4: Generate the privacy policy

Eleven-section document:

1. Introduction (who we are, what the policy covers, contact)
2. Information We Collect (permissions-derived data, attribution data, what is NOT collected)
3. How We Use Your Information (operation, improvement, attribution; GDPR legal basis)
4. Cookies and Tracking (derived from scan, how to disable)
5. We Do Not Sell Your Personal Data (explicit CCPA no-sale statement)
6. Data Retention (how long, how to request deletion)
7. Your Rights: GDPR (access, rectification, erasure, restriction, portability, object) and CCPA (know, delete, opt-out, non-discrimination)
8. Third-Party Services (Mozilla/AMO, any external endpoints found in scan)
9. Children's Privacy (not directed at under-13, no knowing collection)
10. Changes to This Policy
11. Contact Us

### Step 5: Output

- **From `generate-website`**: writes to `.website/privacy/index.html` with shared CSS, nav, and footer. No tracking script on this page.
- **Standalone**: outputs in the user's requested format (plain text, markdown, or complete standalone HTML)

### Step 6: Review pause

After generating, presents a summary:
- Jurisdiction covered
- Effective date used
- Contact email used
- What data collection was found and included
- File path (if from generate-website)

Then asks the user to confirm or request changes. Applies section edits or regenerates as instructed.

## Inputs

- Extension project directory (for scanning)
- Extension name, developer/company name, website domain, contact email
- Or: all of the above passed in automatically from `generate-website`

## Outputs

| Context | Output |
|---|---|
| From generate-website | `.website/privacy/index.html` |
| Standalone HTML | Complete standalone HTML file |
| Standalone markdown | Markdown document in conversation |
| Standalone plain text | Plain text document in conversation |

## Edge cases and limitations

- No internal developer/company names (e.g., Sterkly, BitBoxMedia) appear anywhere in the output
- No DPO is mentioned; the support email serves as the GDPR contact point
- The effective date is intentionally backdated (1 year + 1-12 random months) to appear as a pre-existing policy
- If called from `generate-website`, the output format is always HTML and matches the site's shared structure

## Related skills

- `gen-terms`: Generates the Terms of Service, often used alongside this skill
- `generate-website` (not in this plugin set): calls this skill as part of a full website generation flow
