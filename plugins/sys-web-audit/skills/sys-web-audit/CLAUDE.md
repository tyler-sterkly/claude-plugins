# sys-web-audit

Reviews UI files for compliance with Web Interface Guidelines fetched fresh from the Vercel source URL on every run. Outputs findings in the terse file:line format defined by the guidelines document.

## Design decisions

- Guidelines are fetched fresh on every run -- never cached; this keeps the skill in sync with upstream updates without requiring a skill update
- Output format is defined by the fetched guidelines document, not hardcoded in the skill
- The skill is a thin orchestrator: fetch, read files, apply rules from fetched content, output
