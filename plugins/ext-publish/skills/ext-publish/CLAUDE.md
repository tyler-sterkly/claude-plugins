# ext-publish

Full release pipeline: version bump, comment stripping, linting, zip packaging, and documentation generation. The most complex skill in the extension suite -- it orchestrates ext-changelog, ext-verbiage, and sys-commit.

## Design decisions

- Template project detection is a hard fork: FF-extension-template skips Steps 1-3 entirely; no zip, no version bump, no verbiage refresh, no RELEASE file
- "republish" shortcut runs Step 0 but skips all questions: keep version, no strip, no lint, no docs
- Q1-Q3 are asked together; Q4 is asked separately after the uncommitted files check
- Exclusion rules come from C:\github\.claude\.gitignore_global -- that file is the single source of truth; never hardcode exclusions in the skill
- Comment stripping happens inside the zip only -- working tree is never modified
- The -hascom suffix signals "comments not stripped" in the zip filename

## Comment stripping rules

Strip from .js, .css, .html only. Never touch .json or binary assets. String-safe: never strip // or /* inside string literals, URLs (https://), regexes, or template literals. Collapse runs of 3+ newlines to 2 after stripping. Re-verify after stripping -- re-strip any file where comments survived.

## EXTENSION.md display

Key fields shown in a Unicode box table (not markdown pipes): Name, Short Name, Current Version, AMO Slug, Firefox Extension ID, Chrome Extension ID, Primary Domain, Search Domain, Search URL, Search Keyword. No other fields are shown.

## Report format

Final report is always a markdown table (Item / Result) -- never prose or bullets.

## Related skills

- `ext-changelog`: Called in Step 4 with Q1 answer, doc file list, PST timestamp, and diffSource
- `ext-verbiage`: Called when listing verbiage refresh is selected in Q4
- `sys-commit`: Called by ext-changelog at the end of the flow
