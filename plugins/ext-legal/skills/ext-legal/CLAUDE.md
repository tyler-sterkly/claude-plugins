# ext-legal

Generates a US (CCPA) + GDPR compliant privacy policy and California-governed terms of service for a Firefox extension and its website. Called standalone or from ext-website.

## Design decisions

- When called from ext-website, all required info is passed in automatically -- the skill skips the gather step
- The generated documents are written to the paths ext-website specifies (privacy/index.html, terms/index.html inside .website/)
- Standalone mode writes to the project root or wherever the user specifies

## Related skills

- `ext-website`: Primary caller; passes all required info and the output paths
