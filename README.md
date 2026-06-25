# Tyler-Sterkly Claude Plugins

<br>

Claude Code plugins by tyler-sterkly - skills for browser extension development, design, writing, and coding.

![Claude Code Starting Session ASCii Art](startup_screen.svg)


## Installation

**Step 1 - Add Marketplace:**

```
/plugin marketplace add tyler-sterkly/claude-plugins
```

**Step 2 - Install Plugin:**

```
/plugin install design-logo@tyler-sterkly-claude-plugins
```

Or via the Claude Code CLI:

```bash
claude plugin marketplace add tyler-sterkly/claude-plugins
claude plugin install design-logo@tyler-sterkly-claude-plugins
```

You can also browse and install interactively: run `/plugin`, open the **Discover** tab, and press Enter on any plugin to choose your install scope (user, project, or local).

<br>
<br>

## Plugins

### Design / Creative

| Plugin | Description |
|--------|-------------|
| `design-logo` | Design and iterate on logos using SVG |
| `design-svg` | Generate and edit SVG illustrations, icons, and graphics |
| `design-icon-set` | Generate a full icon set and favicon from a single source icon |
| `design-frontend-ui` | Full UI design workflow with aesthetic direction and iteration |

<br>

### Writing / Docs

| Plugin | Description |
|--------|-------------|
| `gen-changelog` | Public-facing changelog and commit message from diffs or version notes |
| `gen-privacy` | GDPR/CCPA-ready privacy policy generator |
| `gen-terms` | Terms of service generator |
| `gen-deep-research` | Multi-source web research with adversarially verified, cited report |

<br>

### Code Quality

| Plugin | Description |
|--------|-------------|
| `code-review` | Review PRs for bugs and compliance, optionally posts inline comments |
| `code-security-review` | OWASP-focused security audit of changed code |
| `code-simplify` | Dead code removal, simplification, and DRY-ness pass |

<br>
<br>

## Usage

After installing, invoke a skill with its slash command:

```
/design-logo
/design-svg
/gen-changelog
/code-review
```

<br>
<br>

## Skill Reference

### <u>design-logo</u>

Design and iterate on logos using SVG, with structured phases from brief to exported PNGs.

**Workflow:**
- **Interview** - Gathers context automatically from the repo (README, package.json, existing branding) then asks structured questions about format (icon, wordmark, or combination mark), style direction, color mood, and use cases. Skips questions already answered by context.
- **Explore** - Generates 3-5 distinct SVG concepts displayed side-by-side for comparison. Each concept has a distinct visual direction so there is a real choice to make.
- **Refine** - Iterates on the chosen concept. Accepts plain-language feedback and applies changes per round until approved.
- **Export** - Renders final PNGs at standard sizes: 16, 32, 48, 192, 512, 1024, and 2048px. Requires one of: `resvg` (recommended), Inkscape, or librsvg.

<br>

---
<br>

### <u>design-svg</u>

Generates and edits SVG files by hand - treating SVGs as code rather than exported blobs.

**Covers:**
- Path commands (`M`, `L`, `C`, `A`, `Z`) and shape primitives
- Styling via CSS and presentation attributes
- Accessibility (`aria-label`, `role`, `title`)
- Gradients, masks, clip paths, and filters
- Icon sprites and symbol systems
- SVG optimization (removing redundant attributes, minimizing path data)
- Animation via CSS keyframes with GPU-accelerated properties, staggering, and SVG-specific easing

**Approach:** Every element and attribute must earn its place. Output is clean, minimal, and semantically meaningful - not the noise that exporters produce.

<br>

---
<br>

### <u>design-icon-set</u>

Generates a complete browser-extension icon set from a single square source icon (SVG or PNG).

**Output:**
- `icon16.png`, `icon32.png`, `icon48.png`, `icon64.png`, `icon128.png` - standard extension icon sizes
- `favicon.ico` - multi-size Windows ICO (16/32/48px) for `search_provider.favicon_url`
- `logo.svg` + `logo.png` - horizontal lockup with product name (when a name is provided)
- `icon.svg` - source SVG preserved alongside the PNGs

**How it works:** Orchestrates `design-svg` for SVG authoring when available, runs concept and approval gates before rendering, then places all output files in the Firefox extension layout convention (`icons/`). Supports custom output lists if the defaults do not fit.

<br>

---
<br>

### <u>design-frontend-ui</u>

Full UI design workflow focused on distinctive, opinionated visual direction - not templated defaults.

**Approach:**
- Grounds every design in the actual subject matter: its materials, artifacts, vocabulary, and world. Generic choices are rejected in favour of choices that could only belong to this brief.
- The hero is a thesis - opens with the most characteristic thing about the product, not a stock gradient and stat block.
- Typography carries personality. Display and body faces are paired deliberately with a full type scale that is itself a memorable part of the design.
- Takes one real aesthetic risk per design and justifies it.

**Workflow:** Reads any existing project context (memory, prior designs, CLAUDE.md), designs the UI, critiques it against the brief, iterates, and delivers with a rationale for every non-obvious choice.

<br>

---
<br>

### <u>gen-changelog</u>

Generates clean, public-facing changelogs and GitHub commit messages for browser extension releases.

**What it reads:**
- `manifest.json` - authoritative version source
- `EXTENSION.md` - extension name and AMO slug (optional)
- `_locales/en/messages.json` - resolves i18n name tokens
- Git diff or a user-supplied list of changes

**Output:**
- A structured changelog entry with version heading, date, and categorised bullets (New, Improved, Fixed, Removed)
- A GitHub commit title and body formatted for the release commit
- Delivered as a `.md` file

**Rules:** Never invents changes not present in the diff. Flags version mismatches between `manifest.json` and `EXTENSION.md`. Derives the extension name from locale files when the manifest uses `__MSG_extName__`.

<br>

---
<br>

### <u>gen-privacy</u>

Generates a US + GDPR compliant privacy policy for a Firefox browser extension and its associated website.

**What it scans:** The extension directory - permissions in `manifest.json`, storage usage, cookie names, data collection patterns - to produce a policy that accurately reflects what the extension actually does rather than a generic template.

**Gathers:** Extension name, developer/company name, website domain, contact email, and output format (plain text, Markdown, or HTML). Can be called standalone or from `gen-terms` with context passed automatically.

**Covers:** Data collected and why, storage and retention, third-party services, user rights (GDPR/CCPA), contact details, and effective date. California and EU law compliant.

<br>

---
<br>

### <u>gen-terms</u>

Generates terms of service for a Firefox browser extension and its website, governed by California law.

**Scope:** Covers both the browser extension and the associated website in a single document - acceptable use, prohibited conduct, intellectual property, disclaimers, limitation of liability, termination, and governing law.

**Gathers:** Same inputs as `gen-privacy` (extension dir, name, company, domain, email, format). Integrates automatically when called from `gen-website`.

**Output:** A complete ToS document in plain text, Markdown, or HTML. Effective date calculated from the current date.

<br>

---
<br>

### <u>gen-deep-research</u>

Multi-source research harness that fans out searches, fetches primary sources, adversarially verifies claims, and synthesizes a cited report.

**Phases:**
1. **Pre-flight** - If the question is underspecified (no budget, region, constraints), asks 2-3 clarifying questions before searching. Narrow questions produce better reports.
2. **Search fan-out** - Runs 3-5 parallel searches from different angles: direct question, skeptical/opposing angle, adjacent context, primary sources (official docs, studies), and recent developments.
3. **Source fetch** - Reads the full content of each source page and extracts key claims, data points, and citations.
4. **Adversarial verification** - Each major claim is challenged from a skeptical angle. Claims that do not survive are flagged or dropped.
5. **Synthesis** - Produces a structured report with inline citations, a confidence level per key claim, and a source list.

Minimum 6 distinct sources per report.

<br>

---
<br>

### <u>code-review</u>

Multi-agent PR review that runs 5 parallel reviewers, scores findings by confidence, and posts results as a PR comment.

**Review agents (run in parallel):**
1. CLAUDE.md compliance - checks the diff against project coding instructions
2. Shallow bug scan - looks for obvious bugs in the changed lines only, skips nitpicks
3. Git blame and history - reads the history of touched files for context that makes bugs visible
4. Prior PR comments - checks past PRs on the same files for recurring issues that may apply
5. Code comment compliance - ensures changes do not contradict guidance in existing comments

**Confidence scoring:** Each finding is scored 0-100. Only findings scored 80+ are posted. This filters out false positives before the comment is written.

**Eligibility checks:** Skips closed PRs, drafts, automated PRs, trivially simple changes, and PRs already reviewed. Runs a second check before posting to catch PRs closed mid-review.

<br>

---
<br>

### <u>code-security-review</u>

OWASP Top 10 focused security audit of code changes or a codebase area.

**What it checks:**

| Category | Examples |
|----------|---------|
| Injection | SQL injection, XSS, command injection, template injection |
| Broken auth | Hardcoded credentials, weak tokens, missing auth checks |
| Sensitive data exposure | API keys or passwords in code, unencrypted PII |
| Security misconfiguration | Permissive CORS, missing security headers, debug mode on |
| Insecure deserialization | Untrusted data passed to deserializers without validation |
| Vulnerable dependencies | Packages with known CVEs (flagged, not exhaustively listed) |
| Broken access control | Missing authorization checks, privilege escalation paths |
| Insufficient logging | Security-relevant events not logged |
| SSRF | User-controlled URLs fetched server-side without validation |
| Prototype pollution | Unsafe object merges in JavaScript |

**Output:** Findings listed by severity with file references and a recommended fix for each.

<br>

---
<br>

### <u>code-simplify</u>

Reviews changed code for unnecessary complexity and applies cleanups directly. Quality-only - does not hunt for bugs.

**What it removes or replaces:**

| Pattern | Action |
|---------|--------|
| Duplicated logic | Extract to shared function |
| Abstraction with no benefit | Inline it |
| Dead code (unused vars, functions, imports) | Delete it |
| Over-engineered solution | Replace with simpler equivalent |
| Single-use intermediate variables | Inline the expression |
| Nested conditionals | Flatten with early returns |
| Manual loops | Replace with map / filter / reduce / find |
| Comments explaining what (not why) | Delete them |

**Hard rules:** Does not change behavior, does not add error handling, does not introduce new abstractions - only removes ones that are not earning their place.


<br>
<br>

## License

MIT - see [LICENSE](LICENSE).
