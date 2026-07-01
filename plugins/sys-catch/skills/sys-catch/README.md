# sys-catch

Searches all past conversations for every instance where the AI responded with "Good catch", extracts the context and what was caught, then creates or updates `GOOD_CATCH.md` in the current working directory.

## When to trigger

Use this skill when the user asks to:
- "Run good catch audit"
- "Update good catch"
- "Find good catches"
- "Audit good catches"

## How it works

1. **Search** past conversations with three queries to maximize coverage: "Good catch", "good catch that's right missed", "good catch noticed that" -- deduplicates results by chat URL across all three
2. **Extract** instances -- for each chat result, identifies the AI response containing "Good catch", the human message that preceded it, and the underlying issue or insight
3. **Check** for existing GOOD_CATCH.md -- if it exists, reads it and compares against new findings; only appends entries not already present; preserves all existing content exactly
4. **Write** GOOD_CATCH.md with all instances in chronological order (oldest first)

## Output format

Each entry in GOOD_CATCH.md:

```markdown
## N. [Short title describing what was caught]
**Date:** [Month Year from updated_at]
**Chat:** [Chat title]
**What was caught:** [One sentence -- what was pointed out]
**The catch:** [2-4 sentences -- what the actual underlying issue or insight was and why it mattered]

---
```

## Rules

- Never duplicate an entry that already exists in the file
- Never rewrite or reformat existing entries when updating
- If a chat snippet is ambiguous, skip it rather than guess
- Date format: Month YYYY (e.g. June 2026)
- Keep "The catch" focused on the technical or factual insight
- Save GOOD_CATCH.md before responding
- After saving, report how many new entries were added and how many already existed
