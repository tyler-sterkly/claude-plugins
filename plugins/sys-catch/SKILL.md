---
name: sys-catch
description: Searches all past conversations for every instance where the AI responded with "Good catch", extracts the context and what was caught, then creates or updates GOOD_CATCH.md in the current working directory. Use when asked to "run good catch audit", "update good catch", "find good catches", or "audit good catches".
---

# Good Catch Audit

Searches past conversations for every instance where the AI said "Good catch", extracts context, and writes or updates `GOOD_CATCH.md` in the current working directory.

---

## Step 1 — Search Past Conversations

Use `conversation_search` with the query `Good catch` and max_results 10. Then run a second search with `good catch that's right missed` and a third with `good catch noticed that` to maximize coverage. Deduplicate results by chat URL across all three searches.

---

## Step 2 — Extract Instances

For each chat result, scan the snippets for any AI response that begins with or contains "Good catch". For each instance found:

- Note the chat title and URL
- Note the `updated_at` date
- Identify what the user pointed out (the human message immediately before the "Good catch" response)
- Identify what the underlying issue or insight was (summarize from the AI's explanation following "Good catch")

If a chat appears in results but the snippet does not contain a clear "Good catch" moment, skip it.

---

## Step 3 — Check for Existing GOOD_CATCH.md

Check if `GOOD_CATCH.md` exists in the current working directory.

**If it does not exist:** create it fresh with all found instances.

**If it does exist:** read the file and compare existing entries against the newly found instances by chat URL and catch description. Only append entries that are not already present. Do not duplicate or rewrite existing entries. Preserve all existing content exactly.

---

## Step 4 — Write GOOD_CATCH.md

Format each entry as:

```markdown
## N. [Short title describing what was caught]
**Date:** [Month Year from updated_at]
**Chat:** [Chat title]
**What was caught:** [One sentence — what was pointed out]
**The catch:** [2–4 sentences — what the actual underlying issue or insight was and why it mattered]

---
```

Start the file with:
```markdown
# GOOD_CATCH.md

Instances where the AI responded "Good catch" to something pointed out, with context.

---
```

Number entries chronologically oldest first. When updating an existing file, new entries are appended at the bottom with continuing numbers.

---

## Rules

- Never duplicate an entry that already exists in the file.
- Never rewrite or reformat existing entries when updating.
- If a chat snippet is ambiguous about whether "Good catch" was said, skip it rather than guess.
- Date format: Month YYYY (e.g. June 2026).
- Keep "The catch" focused on the technical or factual insight, not just a restatement of what was said.
- Save the file to the current working directory as `GOOD_CATCH.md` before responding.
- After saving, report how many new entries were added and how many already existed.
