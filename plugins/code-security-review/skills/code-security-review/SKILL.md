---
name: code-security-review
description: OWASP-focused security audit of code changes. Use when the user asks for a security review, security audit, vulnerability check, or to find security issues in code. Reviews diffs and changed files for injection flaws, broken authentication, XSS, insecure deserialization, exposed secrets, misconfigured permissions, and other OWASP Top 10 vulnerabilities. Always use this skill for security review tasks even if the request seems simple.
version: 1.0.0
license: MIT
---

# Code Security Review

Audit code changes for security vulnerabilities using the OWASP Top 10 as a baseline.

## Scope

Review the provided diff, file, or codebase area for:

| Category | What to look for |
|---|---|
| Injection | SQL injection, command injection, XSS, template injection |
| Broken auth | Hardcoded credentials, weak tokens, missing auth checks |
| Sensitive data exposure | API keys, passwords, tokens committed to code; unencrypted PII |
| Security misconfiguration | Overly permissive CORS, missing security headers, debug mode left on |
| Insecure deserialization | Untrusted data passed to deserializers without validation |
| Vulnerable dependencies | Outdated packages with known CVEs (flag, do not exhaustively enumerate) |
| Broken access control | Missing authorization checks, privilege escalation paths |
| Insufficient logging | Security-relevant events not logged |
| SSRF | User-controlled URLs fetched server-side without validation |
| Prototype pollution | Unsafe object merges in JS |

## Process

1. Read the diff or specified files
2. For each file changed, scan for patterns matching the categories above
3. For each finding, note:
   - **Location**: file and line number
   - **Category**: which OWASP category
   - **Severity**: Critical / High / Medium / Low
   - **Description**: what the vulnerability is and how it could be exploited
   - **Fix**: concrete remediation recommendation
4. Filter out false positives -- only report real issues a real attacker could exploit
5. Do not report issues on lines the user did not change (unless they are directly triggered by the changed code)

## Severity Definitions

- **Critical**: Directly exploitable, high impact (RCE, auth bypass, data exfiltration)
- **High**: Exploitable with moderate effort or limited impact
- **Medium**: Requires specific conditions to exploit
- **Low**: Defense-in-depth issue, hardening recommendation

## Output Format

```
## Security Review

Found N issues:

### [Severity] [Category] -- brief title
**Location:** `path/to/file.js:42`
**Description:** What the vulnerability is and how it could be exploited.
**Fix:** Specific remediation steps.

---
```

If no issues are found:

```
## Security Review
No security issues found. Reviewed for OWASP Top 10 vulnerabilities.
```
