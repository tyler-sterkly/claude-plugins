---
name: sys-hud
description: "Windows-native Claude Code HUD: live terminal title manager that shows real-time status in Windows Terminal as Claude works. Use when the user asks about terminal titles, ccp, sys-hud, or live status updates in the title bar. Also use proactively when the user asks how to start Claude Code with a descriptive title."
user-invocable: true
allowed-tools: "Bash"
---

# sys-terminal — Claude Code Pulse for Windows

`winccp` is a Windows-native wrapper around `claude` that updates the Windows Terminal title bar in real time as Claude works.

## Title format

```
project (branch) | 💭 Thinking
github (main) | 🧪 Testing
github (feat/auth) | ✅ Tests passed
github | fix the login bug | 💾 Committed
```

## Status icons

| Icon | Meaning |
|------|---------|
| 💭 Thinking | Claude is processing a prompt |
| ✏️ Editing | Writing or editing files |
| 📖 Reading | Reading files, searching |
| 🧪 Testing | Running tests |
| 🔨 Building | Running build commands |
| 📦 Installing | Installing packages |
| ⬆️ Pushing | git push |
| 💾 Committed | git commit completed |
| ✅ Tests passed | Test run succeeded |
| ❌ Tests failed | Test run failed |
| 🐛 Error | Tool failure |
| 🌐 Browsing | Web fetch/search |
| 🤖 Delegating | Spawning a subagent |
| 📡 Monitoring | Background agents running |
| 💤 Idle | Claude is waiting for input |

## Usage

```bash
ccp                          # auto-detect title from git branch
ccp "fixing the auth bug"    # custom title
ccp --pr 89 "Fix auth"       # PR format → "PR #89 - Fix auth"
ccp --issue 42 "Crash"       # Issue format → "Issue #42 - Crash"
ccp --feature "Dark mode"    # → "Feature: Dark mode"
ccp --bug "Login crash"      # → "Bug: Login crash"
ccp --refactor "API layer"   # → "Refactor: API layer"
ccp -c                       # resume last conversation
ccp --model opus             # pass flags straight through to claude
ccp --list                   # show active ccp sessions
ccp --goto "PR #89"          # re-open a previous session
ccp --no-dynamic             # static title only (no live updates)
ccp --status-profile verbose # show more status events
ccp --ai-context             # summarize tasks via claude-haiku (opt-in)
```

Any flag not consumed by ccp is forwarded to `claude` directly.

## How it works

1. `ccp` injects Claude Code hooks into `.claude/settings.local.json` for the current project
2. A background PowerShell daemon watches a temp title file
3. Hooks fire on every tool call, writing status to a shared file
4. The bash monitor loop composes the full title string and updates the temp file
5. The PS daemon calls Win32 `SetWindowText` on Windows Terminal's HWND
6. On exit, hooks are removed and all temp files are cleaned up

## Installation

```bash
bash ~/.local/share/ccp/install.sh
# Then restart terminal or: source ~/.bashrc
```

**Requirements:** Git Bash, jq (`winget install jqlang.jq`), Claude Code CLI, powershell.exe

## Troubleshooting

**Title not changing:**
Run `ccp --no-dynamic "Test"` first. If that sets the title, the issue is in the dynamic monitor.
Check if another process holds a lock on the title file: `ls /tmp/ccp_title_*.txt`

**Emojis showing as boxes:**
Windows Terminal supports emoji. Ensure the font in your terminal profile supports Unicode (Cascadia Code, JetBrains Mono, etc.).

**Hooks not firing:**
Check `.claude/settings.local.json` exists while `ccp` is running. If missing, `jq` may not be installed.

**ccp not found:**
Run `source ~/.bashrc` or restart the terminal after install.

## Files

| Path | Purpose |
|------|---------|
| `~/.local/share/ccp/` | Install location |
| `~/.config/claude-code-pulse/sessions.json` | Session history |
| `/tmp/ccp_title_<pid>.txt` | Live title file (per session) |
| `/tmp/ccp_done_<pid>.txt` | Daemon shutdown signal |
| `<project>/.claude/settings.local.json` | Hook injection target |

## Source

Upstream: `github.com/brianruggieri/claude-code-pulse` (rebuilt for Windows)
Installed: `~/.local/share/ccp/`
