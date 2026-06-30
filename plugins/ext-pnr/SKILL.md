---
name: ext-pnr
description: Writes plan and report files automatically whenever a plan is presented. When PNR_ENABLED=true, saves PLAN.md and REPORT.md to <project-dir>\.plans\ (overwritten each time) plus a timestamped PLAN snapshot to .plans\.cache\ (never overwritten). Asks for project directory confirmation before writing. Prints a dim-gray notice line in the terminal with file count, path, and timestamp. Toggle on/off with /ext-pnr-on and /ext-pnr-off — state persists via PNR_ENABLED env var in settings.json.
---

# ext-pnr — Plan & Report File Writing

Triggered automatically whenever you finish drafting a plan and are about to present it (including when asking clarifying questions). Only activates when `PNR_ENABLED=true`.

## Step 1 — Check if PNR is enabled

Run PowerShell:
```powershell
$env:PNR_ENABLED
```

If the value is not `true`, stop immediately. Do not write any files, do not print any notice. Continue normally.

## Step 1.5 — Resolve project directory

Infer the project directory from context: active files being edited, extension being discussed, directories mentioned in conversation. Then ask for confirmation before writing anything.

Present the inference as a question (fill in the inferred path):

```
Where should I store the plan? Is `C:\github\sterkly\BitBoxMedia\FF-extension-example\` correct?
```

If there is nothing to infer from, ask with the current working directory as the example:

```
Where should I store the plan? (working directory: `C:\github\`)
```

Wait for the user to confirm or correct. Do not write any files until confirmed.

The confirmed directory is `<project-dir>`. All plan files go inside `<project-dir>\.plans\`.

## Step 2 — Get current time

Run PowerShell to get PST time. Never guess.
```powershell
[System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::UtcNow, 'Pacific Standard Time') | ForEach-Object {
    $_.ToString("HH:mm:ss") + " " + $_.ToString("yy-MM-dd")
}
```

From this, derive two values:
- **Notice timestamp**: `HH:MM:SS YY-MM-DD` (for the notice line)
- **Filename timestamp**: `YYYY-MM-DD_HH-MM-SS` (full year, for filenames)

## Step 3 — Write 3 files

Create `<project-dir>\.plans\` and `<project-dir>\.plans\.cache\` if they do not exist.

1. `<project-dir>\.plans\PLAN.md` — overwrite with full plan content
2. `<project-dir>\.plans\REPORT.md` — overwrite with full plan content
3. `<project-dir>\.plans\.cache\PLAN_YYYY-MM-DD_HH-MM-SS.md` — new timestamped file, never overwrite

Count how many files were successfully written (target: 3).

## Step 4 — Print the PNR notice

In your chat response, print the first 5 lines of PLAN.md, then `...`, then the last 5 lines of PLAN.md.

Then on its own line (replace N, PATH, and timestamps with real values):

```
ɴᴏᴛɪᴄᴇ: ᴘɴʀ ʀᴇǫᴜᴇsᴛᴇᴅ  —  ᴘʟᴀɴ.ᴍᴅ & ʀᴇᴘᴏʀᴛ.ᴍᴅ sᴀᴠᴇᴅ [N ᶠᴵᴸᴱˢ] ᴛᴏ "PATH\.plans\" ᴀᴛ HH:MM:SS YY-MM-DD  *** ᴵᶠ ɴᴏᴛ ᴡᴏʀᴋɪɴɢ ᴛᴇʟʟ ᴍᴇ ***
```

Also attempt dim gray output in terminal via PowerShell (silent on failure):
```powershell
try { Write-Host 'ɴᴏᴛɪᴄᴇ: ᴘɴʀ ʀᴇǫᴜᴇsᴛᴇᴅ  —  ᴘʟᴀɴ.ᴍᴅ & ʀᴇᴘᴏʀᴛ.ᴍᴅ sᴀᴠᴇᴅ [N ᶠᴵᴸᴱˢ] ᴛᴏ "PATH\.plans\" ᴀᴛ HH:MM:SS YY-MM-DD  *** ᴵᶠ ɴᴏᴛ ᴡᴏʀᴋɪɴɢ ᴛᴇʟʟ ᴍᴇ ***' -ForegroundColor DarkGray } catch {}
```

If PowerShell fails, the plain text notice in chat is the fallback — always print it regardless.

## /ext-pnr-on

Sets `PNR_ENABLED=true` in `C:\github\.claude\settings.json` under the `env` object. Persists across sessions. Confirms in chat.

## /ext-pnr-off

Sets `PNR_ENABLED=false` in `C:\github\.claude\settings.json` under the `env` object. Persists across sessions. No files written, no notice shown until re-enabled. Confirms in chat.
