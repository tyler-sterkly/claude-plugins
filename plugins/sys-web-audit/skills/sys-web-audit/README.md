# sys-web-audit

Reviews UI files for compliance with Web Interface Guidelines fetched fresh from the Vercel source. Outputs findings in a terse `file:line` format.

## When to trigger

Use this skill when the user asks to:
- "Review my UI"
- "Check accessibility"
- "Audit design"
- "Review UX"
- "Check my site against best practices"

## Inputs

- A file path or glob pattern to review
- If no files are specified, the skill asks the user which files to review

## How it works

1. **Fetch** the latest guidelines from the Vercel source URL (always fresh, never cached)
2. **Read** the specified files
3. **Check** against all rules in the fetched guidelines
4. **Output** findings using the format specified in the guidelines (`file:line` terse format)

## Guidelines source

```
https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
```

The fetched content contains both the rules and the output format instructions. The skill follows the output format exactly as defined in the fetched guidelines.

## Notes

- Guidelines are fetched fresh on every run -- this keeps the skill in sync with any upstream updates without requiring a skill update
- The output format and rules are defined by the upstream guidelines document, not hardcoded in the skill
