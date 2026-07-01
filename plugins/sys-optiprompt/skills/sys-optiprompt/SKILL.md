---
name: sys-optiprompt
description: A UserPromptSubmit hook that intercepts prompts containing --optimize, sends them to claude-haiku-4-5-20251001 for rewriting, then presents the original and optimized versions side by side and asks the user which to use. Requires Node.js and ANTHROPIC_API_KEY. Triggered manually per-prompt with --optimize — never runs automatically.
---

# sys-optiprompt

A Claude Code hook that rewrites prompts on demand. Append `--optimize` to any prompt
to trigger it. The hook calls Haiku to produce a cleaner version, then Claude presents
both and asks which to use before acting on either.

---

## How it works

1. User appends `--optimize` to their prompt
2. Hook strips the flag from the prompt
3. Hook sends the cleaned prompt to `claude-haiku-4-5-20251001`
4. If the rewrite is meaningfully different (less than 90% word overlap), Claude receives
   both versions with a system note
5. Claude shows both side by side and asks the user which to use
6. If user accepts the optimized version, Claude proceeds with it
7. If user declines, Claude proceeds with the original
8. If user asks questions or redirects, respond naturally without using either version

---

## Pass-through cases

The hook passes the prompt through (--optimize flag always stripped) when:
- Haiku returns the same text or >90% word overlap
- `ANTHROPIC_API_KEY` is not set
- API call fails for any reason

In all pass-through cases, there is no optimizer UI — Claude just receives the prompt
and responds normally.

---

## When Claude receives the optimizer note

Claude must:
1. Show the user the ORIGINAL PROMPT and OPTIMIZED PROMPT clearly labeled
2. Ask which version they want to use before doing anything else
3. Wait for the user's explicit choice
4. On accept: proceed using the optimized prompt as the instruction
5. On decline: proceed using the original prompt as the instruction
6. On anything else (questions, edits, silence): respond to what the user said without
   acting on either prompt version

---

## Installation

See README.md for full installation steps.

---

## Related skills

None — this skill operates as a standalone hook with no cross-skill dependencies.
