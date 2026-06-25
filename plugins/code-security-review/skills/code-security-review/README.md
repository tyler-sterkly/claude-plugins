# code-security-review

OWASP-focused security audit of code changes. Scans diffs and changed files for injection flaws, broken auth, exposed secrets, misconfigured permissions, and other OWASP Top 10 vulnerabilities.

## When to trigger

Use this skill when the user asks for:
- A security review or security audit
- Vulnerability check
- "Find security issues in this code"
- "Is this code secure?"
- "Check for XSS / injection / auth issues"
- "Run a security pass on this PR"

Always use this skill for security review tasks even if the request seems simple.

## How it works

1. Read the diff or specified files
2. For each changed file, scan for patterns matching the OWASP Top 10 categories
3. For each finding, record location, category, severity, description, and a concrete fix
4. Filter out false positives: only real issues a real attacker could exploit
5. Do not report issues on unchanged lines unless directly triggered by the change
6. Output a structured report (or a clean pass if nothing found)

## OWASP categories covered

| Category | What is checked |
|---|---|
| Injection | SQL injection, command injection, XSS, template injection |
| Broken auth | Hardcoded credentials, weak tokens, missing auth checks |
| Sensitive data exposure | API keys, passwords, tokens in code; unencrypted PII |
| Security misconfiguration | Overly permissive CORS, missing security headers, debug mode left on |
| Insecure deserialization | Untrusted data passed to deserializers without validation |
| Vulnerable dependencies | Outdated packages with known CVEs (flagged, not exhaustively enumerated) |
| Broken access control | Missing authorization checks, privilege escalation paths |
| Insufficient logging | Security-relevant events not logged |
| SSRF | User-controlled URLs fetched server-side without validation |
| Prototype pollution | Unsafe object merges in JS |

## Inputs

- A diff, file, or codebase area to review (provided by the user or inferred from context)
- A PR number, file path, or code snippet

## Outputs

A security report posted in the conversation or as a PR comment. Format:

With issues:
```
## Security Review

Found N issues:

### [Severity] [Category] -- brief title
Location: path/to/file.js:42
Description: What the vulnerability is and how it could be exploited.
Fix: Specific remediation steps.

---
```

With no issues:
```
## Security Review
No security issues found. Reviewed for OWASP Top 10 vulnerabilities.
```

## Severity levels

- **Critical**: Directly exploitable, high impact (RCE, auth bypass, data exfiltration)
- **High**: Exploitable with moderate effort or limited impact
- **Medium**: Requires specific conditions to exploit
- **Low**: Defense-in-depth or hardening recommendation

## Edge cases and limitations

- Only reports issues on lines the user changed (unless directly triggered by the change)
- Does not exhaustively enumerate every outdated dependency, just flags categories with known CVEs
- Does not run builds, linters, or automated scanners
- False positives are filtered: theoretical issues with no realistic exploit path are excluded

## Related skills

- `code-review`: General bug and CLAUDE.md compliance review
- `code-simplify`: Code quality and cleanup pass
