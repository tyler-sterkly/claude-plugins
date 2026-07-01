# ext-changelog

Generates a public-facing changelog entry and a developer-facing commit message for a browser extension release. Can be called standalone (asks Q1 and Q4) or invoked from ext-publish (receives all parameters, skips all questions).

## Design decisions

- Standalone vs invoked mode is a hard fork: invoked mode must not re-ask Q1, Q4, Q5, or the timestamp -- all are passed in
- CHANGELOG.md entries are public-facing and subject to strict forbidden-terms rules; COMMITS.md entries are developer-facing and unrestricted
- New entries are always prepended, never appended; `\n\n---\n\n` separator between entries
- Version format enforced at `^\d\.\d\.\d$` -- no two-digit parts ever
- sys-commit handles the actual git commit; ext-changelog stops after generating the title and body

## Forbidden terms (changelog output only)

Version numbers, "lines", "search", "Yahoo", internal codenames (template, background-core, seam), other product names from the suite. These are enforced by self-check before delivering.

## Character set

US keyboard only in changelog output -- no arrows, em/en dashes, curly quotes, or emoji.

## Key integration

Called by ext-publish with: Q1 answer, doc file list, PST timestamp, diffSource ("uncommitted" or "last-commit"). ext-changelog passes title + body + repo_path to sys-commit.

## Related skills

- `ext-publish`: Primary caller in the release flow
- `sys-commit`: Called at the end to handle the git commit
