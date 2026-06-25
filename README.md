# tylersterkly Claude Plugins

Claude Code plugins by tylersterkly.

## Installation

### Option 1 — Plugin install (recommended)

Install directly from GitHub without cloning:

```bash
claude plugin install github:tylersterkly/claude-plugins
```

This fetches the latest version and registers all plugins automatically.

### Option 2 — Fork and install locally

Fork this repo on GitHub, clone it, then install from the local path:

```bash
git clone https://github.com/<your-username>/claude-plugins
claude plugin install ./claude-plugins
```

This lets you customize skills before installing. After editing, re-run the install command to pick up changes.

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
