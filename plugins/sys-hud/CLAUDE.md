# sys-terminal

Windows Terminal title manager (winccp) that shows real-time Claude Code status in the Windows Terminal title bar. Shows project name, branch, and current activity (Thinking, Testing, Committed, etc.).

## Design decisions

- winccp is a Windows-native wrapper around the claude CLI -- it updates the title bar in real time as Claude works
- Title format: `project (branch) | status-icon Activity`
- Uses Win32 SetWindowText via Get-Process, not a tree walk
- Launched with -File not -Command for the PowerShell wrapper
- UTF8 encoding required for emoji in the title

## Related skills

None -- standalone Windows-specific utility.
