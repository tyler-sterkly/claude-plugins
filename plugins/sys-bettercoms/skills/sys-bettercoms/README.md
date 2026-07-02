# sys-bettercoms

Developer communication style skill for Claude Code. Governs tone, formatting, brevity, and delivery format for all developer-facing interactions.

## When it activates

This skill is invoked automatically on every developer-facing interaction:
- Chat replies
- Code and file delivery
- Extension reviews, fixes, and conversions

It does NOT apply to public-facing copy. For user-visible text, use `ext-verbiage` instead.

## What it enforces

- Short and casual replies by default
- No bold, underline, or headers in chat
- No semicolons or dashes of any kind
- Code delivered as downloadable files (not inline) unless requested otherwise
- Extension fixes return a full project zip
- Extension reviews raise technical issues only
