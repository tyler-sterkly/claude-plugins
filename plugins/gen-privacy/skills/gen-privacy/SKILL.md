---
name: gen-privacy
description: Generate a privacy policy for a Firefox browser extension and its website. Use this skill whenever the user says "generate a privacy policy", "write a privacy policy", "create a privacy policy", or when called from generate-website or generate-terms. Always use this skill for privacy policy generation even if the request seems simple.
---

# Generate Privacy Policy

Generate a US + GDPR compliant privacy policy for a Firefox browser extension and its associated website.

---

## Step 1 -- Gather required info

If called from generate-website, all required info is passed in automatically -- skip to Step 2.

If called standalone, ask for the following in one message:

| Field | Required | Notes |
|---|---|---|
| Extension project directory | Yes | Used to scan for data collection and permissions |
| Extension Name | Yes | Used throughout the document |
| Developer/Company Name | No | If not provided, use Extension Name |
| Website domain | Yes | Used for contact email and document references |
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

1. `manifest.json` -- permissions array, host_permissions, extension description
2. `CLAUDE.md` -- any data collection notes, cookie/attribution details
3. `README.md` -- project overview
4. `.docs/LISTING.txt` -- what the extension does
5. Any background JS files for cookie, storage, or tracking patterns

From this scan, identify:
- What browser permissions are requested (storage, cookies, tabs, activeTab, etc.)
- Whether attribution/tracking cookies are set
- Whether any external APIs or endpoints are called
- Whether user consent is collected
- Any personally identifiable data touched

After scanning, present the user with a summary of what was found and what will be included in the policy beyond the boilerplate. Ask if they want to add anything else before generating.

---

## Step 4 -- Generate the privacy policy

Generate a US + GDPR compliant privacy policy using the template structure below. Fill in all placeholders from gathered info.

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

## Step 5 -- Output

### If called from generate-website:
- Write the policy as a complete HTML page to `privacy/index.html` inside `.website/`
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
- Jurisdiction: US (CCPA) + EU (GDPR)
- Effective date used
- Contact email used
- What data collection was found in the scan and included
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
- [ ] "We do not sell personal data" statement present
- [ ] GDPR rights section complete (all 6 rights listed)
- [ ] CCPA section complete
- [ ] Legal basis stated (legitimate interest and/or consent)
- [ ] No DPO mentioned, support email used as contact point
- [ ] No internal names (Sterkly, BitBoxMedia) appear anywhere
- [ ] Review pause completed before finishing
