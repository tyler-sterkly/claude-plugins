# gen-terms

Generates Terms of Service for a Firefox browser extension and its associated website, governed by California law.

## When to trigger

Use this skill when the user says:
- "Generate terms"
- "Write terms of service"
- "Create terms of use"

Also called automatically from `generate-website`.

Always use this skill for terms of service generation even if the request seems simple.

## Two modes

**Called from `generate-website`:** All required info is passed in automatically. Outputs to `.website/terms/index.html` using the site's shared CSS, nav, and footer.

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
- `manifest.json`: permissions, host_permissions, description
- `CLAUDE.md`: project context, behaviors, data notes
- `README.md`: project overview
- `.docs/LISTING.txt`: what the extension does and its features
- Background JS files: scanned for notable behaviors

From this scan identifies: what the extension does, any subscription/payment/premium features, user-generated content, external services, and behaviors that warrant specific clauses.

Presents the user with a scan summary and asks if anything should be added before generating.

### Step 4: Generate the terms of service

Thirteen-section document:

1. Acceptance of Terms
2. Description of Service (what the extension does, Mozilla AMO distribution, website)
3. Permitted Use (personal non-commercial use, no reverse engineering, no unlawful use)
4. Intellectual Property (developer retains all rights)
5. Privacy (references the privacy policy at {domain}/privacy/)
6. Disclaimer of Warranties ("as is", no uptime guarantee)
7. Limitation of Liability (no indirect/incidental/consequential damages; total liability limited to $0 for free extensions)
8. Indemnification
9. Third-Party Services (derived from scan)
10. Termination
11. Governing Law (California, United States; GDPR rights explicitly not waived for EU users)
12. Changes to These Terms
13. Contact Us

### Step 5: Output

- **From `generate-website`**: writes to `.website/terms/index.html` with shared CSS, nav, and footer. No tracking script on this page.
- **Standalone**: outputs in the user's requested format (plain text, markdown, or complete standalone HTML)

### Step 6: Review pause

After generating, presents a summary:
- Governing law (California, United States)
- Effective date used
- Contact email used
- Extension behaviors found in scan and included
- File path (if from generate-website)

Then asks the user to confirm or request changes. Applies section edits or regenerates as instructed.

## Inputs

- Extension project directory (for scanning)
- Extension name, developer/company name, website domain, contact email
- Or: all of the above passed in automatically from `generate-website`

## Outputs

| Context | Output |
|---|---|
| From generate-website | `.website/terms/index.html` |
| Standalone HTML | Complete standalone HTML file |
| Standalone markdown | Markdown document in conversation |
| Standalone plain text | Plain text document in conversation |

## Edge cases and limitations

- No internal developer/company names (e.g., Sterkly, BitBoxMedia) appear anywhere in the output
- The GDPR rights not waived clause is always included in the governing law section, even though California law governs
- The effective date is intentionally backdated (1 year + 1-12 random months) to appear as a pre-existing policy
- Liability is capped at $0 for free extensions; this is adjusted if the scan reveals paid features
- If called from `generate-website`, the output format is always HTML and matches the site's shared structure

## Related skills

- `gen-privacy`: Generates the Privacy Policy, often used alongside this skill
- `generate-website` (not in this plugin set): calls this skill as part of a full website generation flow
