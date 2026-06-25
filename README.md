# tyler-sterkly Claude Plugins

Claude Code plugins by tyler-sterkly — skills for browser extension development, design, writing, and code quality.

## Installation

**Step 1 — Add this marketplace (one-time):**

```
/plugin marketplace add tyler-sterkly/claude-plugins
```

**Step 2 — Install a plugin:**

```
/plugin install design-logo@tyler-sterkly-claude-plugins
```

Or via the Claude Code CLI:

```bash
claude plugin marketplace add tyler-sterkly/claude-plugins
claude plugin install design-logo@tyler-sterkly-claude-plugins
```

You can also browse and install interactively: run `/plugin`, open the **Discover** tab, and press Enter on any plugin to choose your install scope (user, project, or local).

## Plugins

### Design / Creative

| Plugin | Description |
|--------|-------------|
| `design-logo` | Design and iterate on logos using SVG |
| `design-svg` | Generate and edit SVG illustrations, icons, and graphics |
| `design-icon-set` | Generate a full icon set and favicon from a single source icon |
| `design-frontend-ui` | Full UI design workflow with aesthetic direction and iteration |

### Writing / Docs

| Plugin | Description |
|--------|-------------|
| `gen-changelog` | Public-facing changelog and commit message from diffs or version notes |
| `gen-privacy` | GDPR/CCPA-ready privacy policy generator |
| `gen-terms` | Terms of service generator |
| `gen-deep-research` | Multi-source web research with adversarially verified, cited report |

### Code Quality

| Plugin | Description |
|--------|-------------|
| `code-review` | Review PRs for bugs and compliance, optionally posts inline comments |
| `code-security-review` | OWASP-focused security audit of changed code |
| `code-simplify` | Dead code removal, simplification, and DRY-ness pass |

## Usage

After installing, invoke a skill with its slash command:

```
/design-logo
/design-svg
/gen-changelog
/code-review
```

## License

MIT — see [LICENSE](LICENSE).
