# ext-pnr

Automatically writes plan and report files whenever a plan is presented in Claude Code.

## What it does

When enabled, every plan presentation writes 4 files:

| File | Location | Behavior |
|---|---|---|
| `PLAN.md` | `C:\github\` | Overwritten each time |
| `REPORT.md` | `C:\github\` | Overwritten each time |
| `PLAN_YYYY-MM-DD_HH-MM-SS.md` | `C:\github\PNR\` | New file, never overwritten |
| `REPORT_YYYY-MM-DD_HH-MM-SS.md` | `C:\github\PNR\` | New file, never overwritten |

A notice line is printed in the terminal in dim gray with the file count and timestamp.

## Toggle

| Command | Effect |
|---|---|
| `/ext-pnr-on` | Enable PNR — persists via `PNR_ENABLED=true` in settings.json |
| `/ext-pnr-off` | Disable PNR — no files written, no notice shown |

State persists across sessions via the `PNR_ENABLED` env var in `.claude/settings.json`.

## Notice format

```
ɴᴏᴛɪᴄᴇ: ᴘɴʀ ʀᴇǫᴜᴇsᴛᴇᴅ  —  ᴘʟᴀɴ.ᴍᴅ & ʀᴇᴘᴏʀᴛ.ᴍᴅ sᴀᴠᴇᴅ [4 ᶠᴵᴸᴱˢ] ᴛᴏ "ᴄ:\ɢɪᴛʜᴜʙ\" ᴀᴛ 16:15:26 26-06-28  *** ᴵᶠ ɴᴏᴛ ᴡᴏʀᴋɪɴɢ ᴛᴇʟʟ ᴍᴇ ***
```

## Requirements

- Windows + PowerShell (uses PST timezone conversion)
- `C:\github\` as the project root
