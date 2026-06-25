---
name: gen-terms
description: Generate terms of service for a Firefox browser extension and its website. Use this skill whenever the user says "generate terms", "write terms of service", "create terms of use", or when called from generate-website. Always use this skill for terms of service generation even if the request seems simple.
---

# Generate Terms of Service

Generate terms of service for a Firefox browser extension and its associated website, governed by California law, covering both the extension and the website.

---

## Step 1 -- Gather required info

If called from generate-website, all required info is passed in automatically -- skip to Step 2.

If called standalone, ask for the following in one message:

| Field | Required | Notes |
|---|---|---|
| Extension project directory | Yes | Used to scan for relevant behaviors and permissions |
| Extension Name | Yes | Used throughout the document |
| Developer/Company Name | No | If not provided, use Extension Name |
| Website domain | Yes | Used for contact and document references |
| Contact email | No | If not provided, use support@{domain} |
| Output format | Yes (standalone only) | plain text, markdown, or html |

---

## Step 2 -- Calculate effective date

Calculate the effective date as follows:
- Take today's date
- Subtract 1 year
- Subtract a random number of months between 1 and 12
- Format as month and year only, no day (e.g. "March 2025")

Use this as the Effective Date in the document.

---

## Step 3 -- Scan extension project

Read the following files from the extension project directory:

1. `manifest.json` -- permissions, host_permissions, description
2. `CLAUDE.md` -- project context, behaviors, data notes
3. `README.md` -- project overview
4. `.docs/LISTING.txt` -- what the extension does and its features
5. Any background JS files for notable behaviors

From this scan, identify:
- What the extension does and what it modifies in the browser
- Any subscription, payment, or premium features (note if none found)
- Any user-generated content or input
- External services or APIs called
- Any behaviors that warrant specific terms clauses

After scanning, present the user with a summary of what was found and what will be included beyond boilerplate. Ask if they want to add anything else before generating.

---

## Step 4 -- Generate the terms of service

Generate terms of service using the template structure below. Fill in all placeholders from gathered info.

### Document structure

```
Terms of Service

Effective Date: {calculated month and year}

1. Acceptance of Terms
   - By using {Extension Name} or visiting {website domain}, you agree to these terms
   - If you do not agree, do not use the extension or website
   - {Developer/Company Name} reserves the right to update these terms

2. Description of Service
   - What {Extension Name} does (derived from scan and listing)
   - That it is distributed via the Mozilla Firefox Add-ons Marketplace (AMO)
   - That the website at {website domain} supports the extension

3. Permitted Use
   - Extension is for personal, non-commercial use
   - You agree not to reverse engineer, modify, or redistribute the extension
   - You agree not to use the extension for unlawful purposes

4. Intellectual Property
   - {Developer/Company Name} retains all rights to the extension and website
   - Extension name, logo, and assets are proprietary
   - Nothing in these terms transfers ownership to the user

5. Privacy
   - Use of the extension and website is subject to our Privacy Policy
   - Link/reference to privacy policy at {website domain}/privacy/

6. Disclaimer of Warranties
   - Extension and website provided "as is" without warranty of any kind
   - No guarantee of uninterrupted or error-free operation
   - {Developer/Company Name} does not warrant fitness for a particular purpose

7. Limitation of Liability
   - {Developer/Company Name} not liable for indirect, incidental, or consequential damages
   - Total liability limited to the greater of $0 (free extension) or amounts paid
   - Some jurisdictions do not allow limitation of liability -- those local laws may apply

8. Indemnification
   - You agree to indemnify {Developer/Company Name} from claims arising from your use
   - Covers violation of these terms or applicable law

9. Third-Party Services
   - Extension may interact with third-party services (derived from scan)
   - {Developer/Company Name} not responsible for third-party content or services
   - Use of third-party services subject to their own terms

10. Termination
    - {Developer/Company Name} may terminate or suspend access at any time
    - You may stop using the extension at any time by uninstalling it

11. Governing Law
    - These terms governed by the laws of the State of California, United States
    - Disputes subject to the exclusive jurisdiction of courts in California
    - GDPR rights not waived for EU users by this clause

12. Changes to These Terms
    - We may update these terms at any time
    - Continued use constitutes acceptance of updated terms
    - Material changes will be noted with an updated effective date

13. Contact Us
    - {Developer/Company Name}
    - {contact email}
    - {website domain}
```

---

## Step 5 -- Output

### If called from generate-website:
- Write the terms as a complete HTML page to `terms/index.html` inside `.website/`
- HTML should use the site's shared CSS (`../../css/style.css`)
- Include the shared nav and footer
- Do not include the tracking script on this page
- Report the file path and a summary of what was included

### If called standalone:
- Output in the format the user requested (plain text, markdown, or html)
- If html: output a complete standalone HTML file with minimal inline CSS, ready to drop into any project
- If plain text or markdown: output the document directly in the conversation as a file

---

## Step 6 -- Review pause

After generating, pause and tell the user:

Summary of what was generated:
- Governing law: California, United States
- Effective date used
- Contact email used
- What extension behaviors were found in the scan and included
- Sections included beyond boilerplate
- File path (if called from generate-website)

Then ask:
- Does this look correct?
- Do you want to change specific sections or regenerate the full document?

If the user requests changes: apply section edits or regenerate as instructed, then repeat this step.

---

## Self-check

- [ ] Effective date calculated correctly (today minus 1 year minus 1-12 random months, month and year only)
- [ ] Extension project scanned before generating
- [ ] Scan summary presented to user before generating
- [ ] Limitation of liability clause present
- [ ] Governing law set to California
- [ ] GDPR rights not waived clause present in governing law section
- [ ] Privacy policy referenced in terms
- [ ] No internal names (Sterkly, BitBoxMedia) appear anywhere
- [ ] Review pause completed before finishing
