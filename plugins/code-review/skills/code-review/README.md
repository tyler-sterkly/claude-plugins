# code-review

Reviews a pull request for bugs and CLAUDE.md compliance using parallel agents, then posts findings as a PR comment.

## When to trigger

Use this skill when the user asks to:
- Review a PR or pull request
- Check a pull request
- Run a code review
- "Review PR #123"
- "Can you code review this?"
- "Check this PR before I merge"

Always use this skill for PR review tasks even if the request seems simple.

## How it works

1. **Eligibility check** (Haiku agent): Confirms the PR is open, non-draft, non-trivial, and hasn't already been reviewed. Skips if any condition fails.
2. **CLAUDE.md discovery** (Haiku agent): Finds the root CLAUDE.md and any CLAUDE.md files in directories touched by the PR.
3. **PR summary** (Haiku agent): Reads the pull request and returns a plain summary of the change.
4. **Parallel review** (5 Sonnet agents running concurrently):
   - Agent 1: Audits changes against CLAUDE.md guidelines
   - Agent 2: Shallow scan for obvious bugs in the changed lines only
   - Agent 3: Reads git blame and history for bugs surfaced by historical context
   - Agent 4: Reads previous PRs that touched the same files, checks for recurring comments
   - Agent 5: Reads code comments in modified files and checks for compliance issues
5. **Confidence scoring** (parallel Haiku agents, one per issue): Each issue gets a 0-100 score. Issues scoring below 80 are dropped.
6. **Second eligibility check** (Haiku agent): Re-confirms the PR is still open and eligible before posting.
7. **Post comment** (gh CLI): Posts a formatted comment back on the PR with findings or a clean pass.

## Inputs

- A PR number or URL (provided by the user or inferred from context)
- The target GitHub repository (detected from the local git remote or provided explicitly)
- CLAUDE.md files in the repo (auto-discovered)

## Outputs

A comment posted directly on the pull request. Format depends on findings:

With issues found:
```
### Code review

Found N issues:

1. <description> (CLAUDE.md says "...")
   https://github.com/owner/repo/blob/<full-sha>/path/to/file.ts#L10-L14

2. ...

Generated with Claude Code
```

With no issues:
```
### Code review

No issues found. Checked for bugs and CLAUDE.md compliance.

Generated with Claude Code
```

## False positives (what gets filtered out)

The scoring step explicitly drops:
- Pre-existing issues (not introduced by this PR)
- Linter/typechecker/compiler catches (assumed to run in CI)
- Pedantic nitpicks a senior engineer wouldn't raise
- General code quality issues unless required by CLAUDE.md
- Issues silenced in-code (e.g. lint ignore comments)
- Likely intentional behavior changes
- Real issues on lines the PR didn't touch

## Edge cases and limitations

- Closed or draft PRs are skipped automatically
- Automated or trivially simple PRs are skipped
- PRs already reviewed in this session are skipped
- The skill does not build or typecheck the project
- All GitHub interaction uses `gh` CLI, not web fetch
- Code links require a full SHA and exact line range format or Markdown won't render correctly

## Code link format

Every cited finding links to a specific file and line range using the full commit SHA:

```
https://github.com/owner/repo/blob/1d54823877c4de72b2316a64032a54afc404e619/src/file.ts#L10-L14
```

Requirements: full SHA (not HEAD), correct repo name, `#` before line range, format `L[start]-L[end]`, at least one line of context above and below the flagged lines.

## Related skills

- `code-security-review`: Focused OWASP security audit instead of general review
- `code-simplify`: Quality and cleanup pass on changed code
