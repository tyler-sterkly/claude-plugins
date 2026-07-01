# sys-optiprompt

A Claude Code hook that rewrites prompts on demand. Append `--optimize` to any prompt
and Claude will show you an optimized version side by side with your original and ask
which to use.

## How to use

Add `--optimize` to the end of any prompt:

```
explain how async/await works in JavaScript --optimize
```

Claude will show:

```
ORIGINAL PROMPT:
explain how async/await works in JavaScript

OPTIMIZED PROMPT:
Explain how async/await works in JavaScript, including how it relates to Promises and
common pitfalls.

Which version would you like to use?
```

Reply with your choice. Claude proceeds with the version you pick.

## Requirements

- Node.js installed (the `node` executable must be on PATH or at `C:/Program Files/nodejs/node.exe`)
- `ANTHROPIC_API_KEY` environment variable set

## Installation

### Step 1 — Copy the hook script

Copy `hooks/optiprompt.mjs` to your Claude Code hooks directory:

```
C:\Users\<you>\.claude\hooks\optiprompt.mjs   (user scope)
C:\<your-project>\.claude\hooks\optiprompt.mjs (project scope)
```

### Step 2 — Register the hook in settings.json

Open your `settings.json` (user scope: `C:\Users\<you>\.claude\settings.json`, or project
scope: `C:\<your-project>\.claude\settings.json`) and add the `UserPromptSubmit` entry
inside the `hooks` object:

```json
"hooks": {
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "\"C:/Program Files/nodejs/node.exe\" \"<path-to-hooks>/optiprompt.mjs\""
        }
      ]
    }
  ]
}
```

Replace `<path-to-hooks>` with the directory where you placed `optiprompt.mjs`.

If a `hooks` object already exists in your settings.json, add `UserPromptSubmit` as a
new key alongside the existing ones.

### Step 3 — Set your API key

Make sure `ANTHROPIC_API_KEY` is available in your shell environment:

```powershell
# PowerShell — add to your profile for persistence
$env:ANTHROPIC_API_KEY = "sk-ant-..."
```

```bash
# Bash/zsh — add to .bashrc or .zshrc
export ANTHROPIC_API_KEY="sk-ant-..."
```

### Step 4 — Restart Claude Code

Reload the session for the new hook to take effect.

## Behavior details

| Condition | Result |
|---|---|
| Prompt has `--optimize` | Hook calls Haiku, shows both versions, asks which to use |
| Haiku returns same text | Passes through silently, no optimizer UI |
| No `ANTHROPIC_API_KEY` | Passes through silently |
| API call fails | Passes through silently |
| No `--optimize` in prompt | Hook does nothing, zero overhead |

The `--optimize` flag is always stripped from the prompt before it reaches Claude,
so it never appears in the conversation.

## Node.js path

The default command uses `C:/Program Files/nodejs/node.exe`. If your Node.js is
installed elsewhere, find the path with:

```powershell
(Get-Command node).Source
```

Then update the `command` value in settings.json accordingly.
