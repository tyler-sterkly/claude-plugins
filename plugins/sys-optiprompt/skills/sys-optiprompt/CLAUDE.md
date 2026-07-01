# sys-optiprompt

Hook-based prompt optimizer. Triggered by `--optimize` appended to any user message.
Calls Haiku to rewrite the prompt, then Claude presents both versions and asks which to use.

## Design decisions

- Opt-in via `--optimize` flag — never runs automatically, zero overhead on every other prompt
- The `--optimize` flag is always stripped before the prompt reaches Claude, even on pass-through
- Uses `transformedPrompt` in hook stdout to inject both versions as a system note
- Claude handles the accept/decline UX natively — the hook does not interact with the user
- Similarity gate (>90% word overlap) prevents showing trivially different rewrites
- All failure paths (no API key, network error, empty response) pass through silently
- Model: `claude-haiku-4-5-20251001` — fast and cheap, sufficient for prompt rewriting

## Hook contract

- Hook type: `UserPromptSubmit`
- Stdout: `{ "transformedPrompt": "..." }` always when --optimize is present (either the note+both versions, or just the cleaned prompt on pass-through); nothing when --optimize is absent
- Exit code: always 0 — non-zero exits are errors in Claude Code hook handling

## Integration

Standalone only. No other skills invoke this hook.
