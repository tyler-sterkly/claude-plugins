# ext-audit

Two-phase Firefox extension auditor: reads all non-dotfile project files, scores across six axes (MV3 Compliance, Security, Architecture, Correctness, Code Quality, Performance), then converts findings into a ranked AUDIT.md plan.

## Design decisions

- Six-axis scoring separates concerns so findings can be prioritized cross-axis (Critical from any axis beats High from any axis)
- EXTENSION.md is the authoritative identity source -- mismatches with manifest.json or config.js are flagged as findings
- background-core.js is presence-only; its API surface is documented in the template and treated as a known-good baseline
- Intentional patterns (fillAllMissingFromLp, seam file split, permissive LP merge) are explicitly excluded from findings

## Key constraint

Never mention Sterkly, BitBoxMedia, or internal org names in AUDIT.md output. The file may be shared outside the org.

## Related skills

- `ext-review`: Different skill, different output format (docs/review.md vs AUDIT.md at root); ext-review focuses more on AMO policy compliance
- `ext-context`: Read this before auditing an unfamiliar extension
