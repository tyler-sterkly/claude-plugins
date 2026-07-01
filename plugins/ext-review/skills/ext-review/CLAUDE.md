# ext-review

Comprehensive code quality review of a Firefox extension across five dimensions plus manifest/metadata. Saves output to docs/review.md with a timestamp. Uses plain text severity labels (Critical, Major, Minor, Suggestion) -- no emoji.

## Design decisions

- Never accesses dotfiles or dotfolders
- Plain text severity labels only -- no emoji in issue counts, severity table, or severity definitions
- If EXTENSION.md exists, verifies that version, gecko ID, EXTID, and domains match manifest.json and config.js; any mismatch is flagged as a finding
- Saves docs/review.md before responding -- confirmation and brief inline summary follow after save
- Does not mention internal org names (Sterkly, BitBoxMedia) in the output

## Difference from ext-audit

ext-review produces docs/review.md with a consistent six-section format and severity table. ext-audit produces AUDIT.md at the project root with a priority-tier plan and Recommended Order of Work. They cover similar ground but serve different purposes (review vs planning).

## Related skills

- `ext-audit`: Different output format; produces a ranked update plan
- `ext-context`: Generates CLAUDE.md context for the extension
