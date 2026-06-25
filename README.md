# tyler-sterkly Claude Plugins

Claude Code plugins by tyler-sterkly.

## Installation

**Step 1 — Add this marketplace (one-time):**

```
/plugin marketplace add tyler-sterkly/claude-plugins
```

**Step 2 — Install a plugin:**

```
/plugin install logo-designer@tyler-sterkly-claude-plugins
```

Or via the Claude Code CLI:

```bash
claude plugin marketplace add tyler-sterkly/claude-plugins
claude plugin install logo-designer@tyler-sterkly-claude-plugins
```

You can also browse and install interactively: run `/plugin`, open the **Discover** tab, and press Enter on any plugin to choose your install scope (user, project, or local).

## Plugins

| Plugin | Description | Skills |
|--------|-------------|--------|
| `logo-designer` | Design and iterate on logos using SVG | `logo-designer` |

## Usage

After installing, invoke a skill with its slash command:

```
/logo-designer
```

## Adding a Plugin

1. Create `plugins/<name>/` with the structure below
2. Add an entry to `.claude-plugin/marketplace.json`
3. Bump the marketplace version

```
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── <skill-name>/
        ├── SKILL.md
        ├── scripts/       (optional)
        └── references/    (optional)
```

## License

MIT — see [LICENSE](LICENSE).
