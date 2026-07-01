---
name: ext-legal
description: Generate a privacy policy and terms of service for a Firefox browser extension and its website. Use whenever the user says "generate privacy policy", "generate terms", "generate legal docs", "write privacy and terms", or when called from generate-website. Always use this skill for legal document generation even if the request seems simple.
---

# Generate Legal Documents

Generate a US (CCPA) + GDPR compliant privacy policy and California-governed terms of service for a Firefox browser extension and its associated website.

---

## Step 1 -- Gather required info

If called from generate-website, all required info is passed in automatically -- skip to Step 2.

If called standalone, ask for the following in one message:

| Field | Required | Notes |
|---|---|---|
| Extension project directory | Yes | Used to scan for data collection and permissions |
| Extension Name | Yes | Used throughout both documents |
| Developer/Company Name | No | If not provided, use Extension Name |
| Website domain | Yes | Used for contact email and document references |
| Contact email | No | If not provided, use support@{domain} |
| Output format | Yes (standalone only) | plain text, markdown, or html |
| Which documents | Yes (standalone only) | privacy policy, terms of service, or both |

---

## Step 2 -- Calculate effective date

Calculate once and use in both documents:
- Take today's date
- Subtract 1 year
- Subtract a random number of months between 1 and 12
- Format as month and year only, no day (e.g. "March 2025")

---

## Step 3 -- Scan extension project

Read the following files from the extension project directory:

1. `manifest.json` -- permissions array, host_permissions, extension description
2. `CLAUDE.md` -- data collection notes, cookie/attribution details, project behaviors
3. `README.md` -- project overview
4. `.docs/LISTING.txt` -- what the extension does and its features
5. Any background JS files for cookie, storage, tracking, or notable behavior patterns

From this scan, identify:
- What browser permissions are requested (storage, cookies, tabs, activeTab, etc.)
- Whether attribution/tracking cookies are set
- Whether any external APIs or endpoints are called
- Whether user consent is collected
- Any personally identifiable data touched
- Any subscription, payment, or premium features (note if none found)
- Any user-generated content or input
- Any behaviors that warrant specific terms clauses

After scanning, present the user with a summary of what was found and what will be included in both documents beyond the boilerplate. Ask if they want to add anything else before generating.

---

## Step 4a -- Generate the privacy policy

Generate a US + GDPR compliant privacy policy using the structure below.

### Document structure

```
Privacy Policy

Effective Date: {calculated month and year}

1. Introduction
   - Who we are ({Developer/Company Name}, operating {Extension Name})
   - What this policy covers (the extension and the website)
   - Contact: {contact email}

2. Information We Collect
   - Automatically collected data (browser type, general usage patterns)
   - Attribution data (referral source, campaign parameters if applicable)
   - Any permissions-derived data found in scan
   - What is NOT collected (no name, address, payment info unless found otherwise)

3. How We Use Your Information
   - To operate and improve the extension
   - To understand how users find and install the extension (attribution)
   - Legal basis under GDPR: legitimate interest and/or consent

4. Cookies and Tracking
   - Whether cookies are set (derived from scan)
   - Purpose of cookies (attribution, session, preferences)
   - How to disable cookies

5. We Do Not Sell Your Personal Data
   - Explicit statement: we do not sell, rent, or trade personal data
   - CCPA compliance statement

6. Data Retention
   - How long data is kept
   - How to request deletion

7. Your Rights
   GDPR rights section:
   - Right to access
   - Right to rectification
   - Right to erasure
   - Right to restrict processing
   - Right to data portability
   - Right to object
   - How to exercise rights: contact {contact email}
   - Contact point for data matters: {contact email} (no DPO required)

   CCPA rights section:
   - Right to know what data is collected
   - Right to delete
   - Right to opt-out of sale (not applicable -- we do not sell data)
   - Non-discrimination statement

8. Third-Party Services
   - Mozilla/AMO as distribution platform
   - Any external endpoints found in scan
   - Links to their privacy policies where applicable

9. Children's Privacy
   - Extension not directed at children under 13
   - No knowing collection of data from children

10. Changes to This Policy
    - We may update this policy
    - Continued use constitutes acceptance

11. Contact Us
    - {Developer/Company Name}
    - {contact email}
    - {website domain}
```

---

## Step 4b -- Generate the terms of service

Generate terms of service using the structure below.

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
- Write privacy policy as a complete HTML page to `privacy/index.html` inside `.website/`
- Write terms of service as a complete HTML page to `terms/index.html` inside `.website/`
- Both HTML files use the site's shared CSS (`../../css/style.css`)
- Include the shared nav and footer in both
- Do not include the tracking script on either page

### If called standalone:
- Output in the format the user requested (plain text, markdown, or html)
- If html: output complete standalone HTML files with minimal inline CSS
- If plain text or markdown: output documents directly in the conversation as files

---

## Step 6 -- Review pause

After generating, pause and tell the user:

Summary of what was generated:
- Documents produced (privacy policy, terms, or both)
- Jurisdiction: US (CCPA) + EU (GDPR) for privacy; California for terms
- Effective date used
- Contact email used
- What data collection / extension behaviors were found in the scan and included
- File paths (if called from generate-website)

Then ask:
- Does this look correct?
- Do you want to change specific sections or regenerate either document?

If the user requests changes: apply edits or regenerate as instructed, then repeat this step.

---

## Self-check

- [ ] Effective date calculated once and used in both documents
- [ ] Extension project scanned before generating
- [ ] Scan summary presented to user before generating
- [ ] Privacy: "We do not sell personal data" statement present
- [ ] Privacy: GDPR rights section complete (all 6 rights listed)
- [ ] Privacy: CCPA section complete
- [ ] Privacy: Legal basis stated (legitimate interest and/or consent)
- [ ] Terms: Limitation of liability clause present
- [ ] Terms: Governing law set to California
- [ ] Terms: GDPR rights not waived clause present in governing law section
- [ ] Terms: Privacy policy referenced
- [ ] No internal names (Sterkly, BitBoxMedia) appear anywhere
- [ ] Review pause completed before finishing
