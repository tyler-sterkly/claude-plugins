# sys-catch

Searches past conversations for "Good catch" AI responses, extracts context, and writes or updates GOOD_CATCH.md in the current working directory. Uses three search queries to maximize coverage.

## Design decisions

- Three queries run to maximize coverage: "Good catch", "good catch that's right missed", "good catch noticed that"
- Deduplication is by chat URL across all three searches
- When updating an existing file, only new entries (not already present by chat URL and catch description) are appended -- existing content is preserved exactly as-is
- Entries are numbered chronologically oldest first; new entries append at the bottom with continuing numbers

## Related skills

None -- standalone utility skill.
