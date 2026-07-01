# winccp

Windows-native port of [claude-code-pulse](https://github.com/brianruggieri/claude-code-pulse) that updates the Windows Terminal title bar in real time as Claude works. Uses Win32 `SetWindowText` via a persistent PowerShell daemon instead of OSC escape sequences.

## When to trigger

Use this skill when the user asks about:
- Terminal titles in Windows Terminal
- `ccp` or `winccp` commands
- Live status updates in the title bar
- How to start Claude Code with a descriptive title
- Why the terminal title isn't updating

## How it works

1. The user runs `ccp` instead of `claude` to start a session
2. `ccp` sets an initial title based on the git branch or a custom note
3. Claude Code hooks are injected into `.claude/settings.local.json`
4. A background PowerShell daemon (`title_daemon.ps1`) watches a temp file for title changes
5. On every tool call, a hook fires and updates the title with the current status icon
6. On exit, hooks are removed and all temp files are cleaned up

## Architecture

```
ccp (bash)
├── injects hooks into settings.local.json
├── starts title_daemon.ps1 (PowerShell, background)
│   └── watches /tmp/ccp_title_<pid>.txt
│   └── calls Win32 SetWindowText on WindowsTerminal.exe HWND
└── starts monitor loop (bash, background)
    └── reads hook status files
    └── composes title string
    └── writes to /tmp/ccp_title_<pid>.txt
```

## Status priority

Higher-priority statuses override lower ones when multiple events fire close together:

| Priority | Status |
|----------|--------|
| 100 | Error |
| 90 | Tests failed |
| 80 | Building |
| 65 | Editing |
| 60 | Installing |
| 55 | Pushing |
| 50 | Testing |
| 40 | Reading |
| 30 | Browsing |
| 20 | Delegating |
| 10 | Thinking |
| 5 | Monitoring |
| 0 | Idle |

## Technical notes

- Win32 title setting requires `CharSet=CharSet.Unicode` on `SetWindowText` for emoji support
- `Get-Content -Encoding UTF8` is required when reading the title file — the default encoding corrupts emoji
- `Get-Process -Name 'WindowsTerminal'` must be used to find the HWND; process tree walk breaks when `powershell.exe` is spawned from inside a bash script
- Each PS invocation needs a unique C# class name to avoid `Add-Type` collisions across calls

## Installation

```bash
bash /c/github/claude-code-pulse/install.sh
source ~/.bashrc
ccp "my task"
```

**Requirements:** Git Bash, jq, Claude Code CLI, powershell.exe

## Related

- [claude-code-pulse](https://github.com/brianruggieri/claude-code-pulse) — the original macOS version this was ported from
