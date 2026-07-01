# sys-code-review

Reviews a GitHub pull request using parallel agents across five dimensions (CLAUDE.md compliance, obvious bugs, git history context, prior PR comments, code comments compliance), then posts all findings as a single PR comment.

## Design decisions

- Initial Haiku agent skips closed/draft/automated/already-reviewed PRs before doing any heavy work
- Five parallel Sonnet agents run independently to avoid cross-contamination of findings
- Each agent has a distinct lens: CLAUDE.md adherence, shallow bug scan, git blame context, prior PR comments, code comment compliance
- Findings are deduplicated and posted as one PR comment (not multiple)
- Uses gh CLI for all GitHub operations

## Related skills

None -- standalone PR review utility.
