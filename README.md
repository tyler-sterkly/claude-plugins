# tyler-sterkly Claude Plugins

Claude Code plugins by tyler-sterkly.

## Installation

### Option 1 — Install directly from GitHub (recommended)

```bash
claude plugin install github:tyler-sterkly/claude-plugins --scope user
```

Use `--scope user` to install for all your projects, or `--scope project` to install only for the current project.

### Option 2 — Clone and install locally

```bash
git clone https://github.com/tyler-sterkly/claude-plugins.git
claude plugin install ./claude-plugins --scope user
```

Clone first if you want to inspect or modify skills before installing. Re-run the install command after any edits to pick up changes.

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
