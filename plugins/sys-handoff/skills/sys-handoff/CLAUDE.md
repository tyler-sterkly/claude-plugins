# sys-handoff

Writes a structured session handoff note to .notes/handoff.md before a session ends, hits usage limits, or switches accounts. Goal is zero re-explaining in the next session.

## Design decisions

- .notes/ is a dotfolder -- it is never committed to GitHub; it is purely local session state
- Next Steps must be specific and actionable; vague entries like "continue the task" are explicitly prohibited
- If working on a Firefox extension, reads EXTENSION.md for name/version/slug to include in the handoff
- Also updates auto memory if enabled, so context persists even if the handoff file is deleted

## Related skills

None -- standalone utility skill.
